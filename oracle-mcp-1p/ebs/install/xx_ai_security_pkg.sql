-- =============================================================================
-- xx_ai_security_pkg: EBS Context Initialization & MCP Logging for MCP Tools
-- =============================================================================
--
--Run as `APPS` in SQL*Plus or SQLcl (EBS R12.2 on Oracle Database 19c), through the site's normal process for custom code (on R12.2, an adop hotpatch or patch cycle, because `APPS` code objects are editioned)[cite: 1, 2]. See `ebs/install/README.md`.
--
--## Overview
--
--What it creates (all read-only or session execution at run time):
--* **Logging Procedure (`MCP_TOOLBOX_LOG`)**: Autonomous logging procedure that writes diagnostic messages directly to `APPS.XX_GGLTOOLBOX$MCP_LOG` without impacting the caller's main transaction.
--* **Session Security Package (`APPS.XX_AI_SECURITY_PKG`)**: Contains security and session-initialization logic to establish Oracle E-Business Suite (EBS) global context (`fnd_global.apps_initialize`, `MO_GLOBAL.INIT`, and `mo_global.set_policy_context`) for Model Context Protocol (MCP) tool executions.
--
--## Prerequisites
--
--* Active Oracle E-Business Suite R12.2 instance running on Oracle Database 19c[cite: 1].
--* Target table `APPS.XX_GGLTOOLBOX$MCP_LOG` must exist for logging execution traces.
--* standard EBS tables/views (`fnd_user`, `fnd_responsibility_vl`, `fnd_application`, `hr_operating_units`, `fnd_security_groups_vl`, `fnd_user_resp_groups_direct`, `org_organization_definitions`) must be accessible.


create or replace editionable package apps.xx_ai_security_pkg
as

PROCEDURE MCP_TOOLBOX_LOG (
    p_log_message  VARCHAR2,
    p_log_level    VARCHAR2 DEFAULT 'INFO',
    p_username     VARCHAR2 DEFAULT NULL,
    p_program_unit VARCHAR2 DEFAULT NULL
);

function ebs_initialize_context (
    p_email_address             VARCHAR2,
    p_operating_unit            VARCHAR2 DEFAULT NULL,
    p_responsibility            VARCHAR2 DEFAULT NULL,
    p_application_short_name    VARCHAR2 DEFAULT NULL
) return VARCHAR2;

-- The contract every system's xx_ai_security_pkg shares (the PL/SQL wrapper calls it first in every tool):

-- Sets the EBS security context (apps_initialize, MOAC) for the user whose e-mail address (or, for
-- tests, FND user name) is p_user_id, and records it for audit (DBMS_SESSION.SET_IDENTIFIER). Raises
-- an error if the user cannot be resolved or the setup fails, so a failed setup stops the query
-- (fail closed): -20010 no user id, -20011 no active user, -20012 several users, -20013 setup failed.
PROCEDURE init_user_session(p_user_id IN VARCHAR2);

-- The FND user name that p_user_id resolves to (same rules and errors as init_user_session).
FUNCTION resolve_user(p_user_id IN VARCHAR2) RETURN VARCHAR2;

end xx_ai_security_pkg;
/

--drop  package apps.xx_ai_security_pkg

create or replace editionable package body apps.xx_ai_security_pkg
as

PROCEDURE MCP_TOOLBOX_LOG (
    p_log_message  VARCHAR2,
    p_log_level    VARCHAR2 DEFAULT 'INFO',
    p_username     VARCHAR2 DEFAULT NULL,
    p_program_unit VARCHAR2 DEFAULT NULL
) IS
    PRAGMA autonomous_transaction;
BEGIN
    INSERT INTO APPS.XX_GGLTOOLBOX$MCP_LOG (
        mcp_client,
        log_message,
        log_level,
        username,
        program_unit
    ) VALUES ( 'Google MCP Toolbox',
               p_log_message,
               p_log_level,
               p_username,
               p_program_unit );

    COMMIT;

--exception when others then null; -- we gobble the error to make sure we don't crash the caller

END mcp_toolbox_log;

function get_email 
return varchar2
is
PRAGMA AUTONOMOUS_TRANSACTION;
l_email_address       VARCHAR2(240);
begin
  if nvl(apps.fnd_global.user_id,-1) = -1
  then
    return null;
  end if;
  
  begin
    select email_address
      into l_email_address
      from apps.fnd_user
     where user_id = apps.fnd_global.user_id;
  exception
    when OTHERS then return null;
  end;
  
  return l_email_address;
end get_email;


function ebs_initialize_context (
    p_email_address             VARCHAR2,
    p_operating_unit            VARCHAR2 DEFAULT NULL,
    p_responsibility            VARCHAR2 DEFAULT NULL,
    p_application_short_name    VARCHAR2 DEFAULT NULL
) return VARCHAR2 IS 
PRAGMA AUTONOMOUS_TRANSACTION;
    
    l_program_unit varchar2(100) := 'ebs_initialize_context';

    l_email_address       VARCHAR2(240) := p_email_address;
    l_operating_unit VARCHAR2(240) := p_operating_unit;
    l_responsibility VARCHAR2(240) := p_responsibility;
    l_application_short_name VARCHAR2(240) := p_application_short_name;
    l_user_id             NUMBER := -1;
    l_resp_id             NUMBER := -1;
    l_resp_appl_id        NUMBER := -1;
    l_ou_id               NUMBER := -1;
    l_user_name           VARCHAR2(100);
    l_actual_resp_name    VARCHAR2(100);

    l_return_value         VARCHAR2(4000);
    l_errm                 VARCHAR2(4000);

BEGIN
    -- Set any necessary session parameters for EBS
--    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''YYYY-MM-DD HH24:MI:SS''';
    mcp_toolbox_log('Session parameters set. Starting EBS initialization.','DEBUG',l_email_address,l_program_unit);
    mcp_toolbox_log('Input parameters - '
                    || 'p_email_address: '|| l_email_address
                    || ', p_operating_unit: '|| nvl(l_operating_unit, 'NULL')
                    || ', p_responsibility_name: '|| nvl(l_responsibility, 'NULL')
                    || ', p_application_short_name: '||nvl(l_application_short_name, 'NULL')
                   ,'DEBUG',l_email_address,l_program_unit)
                    ;
    --Check if this session has already been initialised

    BEGIN
        SELECT 
        JSON_ARRAY(
         JSON_object('user_name' value l_email_address),
         JSON_object('responsibility_name' value fr.responsibility_name),
         JSON_object('security_group_name' value fsg.security_group_name),     -- Added Security Group Name
         JSON_object('application_short_name' value fa.application_short_name),
         JSON_object('operating_unit_name' value hou.name  )
         ) MESSAGE,
         apps.fnd_global.user_id
    INTO l_return_value,
         l_user_id
    FROM 
        apps.fnd_user fu,
        apps.fnd_responsibility_vl fr,
        apps.fnd_application fa,
        apps.hr_operating_units hou,
        apps.fnd_security_groups_vl fsg   -- Added Security Groups View
    WHERE 
        fu.user_id = apps.fnd_global.user_id
        and fu.email_address = l_email_address
        AND fr.responsibility_id = apps.fnd_global.resp_id
        AND fr.application_id = apps.fnd_global.resp_appl_id
        AND fa.application_id = apps.fnd_global.resp_appl_id
        AND fsg.security_group_id = apps.fnd_global.security_group_id -- Join for Security Group
        AND hou.organization_id(+) = apps.fnd_global.org_id
        AND fr.application_id = 800;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Session not initialised: '||l_email_address,'DEBUG',l_email_address,l_program_unit);
            
    END;

    IF l_user_id != -1 and l_email_address = get_email() --session is initialised
       AND coalesce(l_operating_unit,l_responsibility,l_application_short_name) is null --No arguments given
    THEN
        mcp_toolbox_log('Session already initialised: '||l_email_address,'DEBUG',l_email_address,l_program_unit);
        l_return_value := '{"STATUS":"SUCCESS","MESSAGE":'||l_return_value||'}';
        return l_return_value;
    END IF;
    
    -- Check if user actually exists;
    BEGIN

        select 
            u.user_id,
            u.user_name
          INTO
            l_user_id,
            l_user_name
          FROM apps.fnd_user u
          WHERE upper(u.email_address) = upper(l_email_address)
           AND ( u.end_date IS NULL OR u.end_date > sysdate );
          -- (u.email_address = l_email_address or to_char(u.user_id) = l_email_address or u.user_name = l_email_address)
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Username not found '||l_email_address,'ERROR',l_email_address,l_program_unit);
            ROLLBACK;
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Username not found '||l_email_address||'"}';
            return l_return_value;
    END;
    
    -- Fetch User Responsibility
    BEGIN
        SELECT
            r.responsibility_id,
            r.application_id,
            r.responsibility_name
        INTO
            l_resp_id,
            l_resp_appl_id,
            l_actual_resp_name
            
        FROM
            apps.fnd_user_resp_groups_direct urg,
            apps.fnd_responsibility_vl       r
        WHERE 1=1
                
            AND urg.user_id = l_user_id
            AND urg.responsibility_id = r.responsibility_id
            AND urg.responsibility_application_id = r.application_id
                        -- Filter for Inventory responsibility
            AND ( upper(r.responsibility_name) = upper(l_responsibility) OR l_responsibility IS NULL )
                        -- Ensure Responsibility assignment is active
            AND ( urg.end_date IS NULL
                  OR urg.end_date > sysdate )
                        -- Ensure Responsibility definition is active
            AND ( r.end_date IS NULL
                  OR r.end_date > sysdate )
            ORDER BY r.responsibility_id
            FETCH FIRST 1 ROW ONLY ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('No responsibility found for '||l_email_address||'/'||'"'||l_responsibility||'"','ERROR',l_email_address,l_program_unit);
            ROLLBACK;
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Responsibility not found '||NVL(l_responsibility,'No Responsibility provided')||'"}';
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20001,'Username not found '||l_email_address);
        WHEN OTHERS THEN
            mcp_toolbox_log('ERROR: Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong '||sqlerrm||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20101,'Something went wrong '||l_email_address);
        
    
    END;
    -- 2. Perform Apps Initialize
    APPS.fnd_global.apps_initialize(
        user_id      => l_user_id,
        resp_id      => l_resp_id,
        resp_appl_id => l_resp_appl_id
    );

    -- If no shortname provided
    if l_application_short_name is null 
    THEN
    BEGIN
        SELECT DISTINCT 
           fa.application_short_name
         into l_application_short_name
         FROM   apps.fnd_user_resp_groups_direct furg  
         JOIN   apps.fnd_responsibility_vl fr         ON furg.responsibility_id = fr.responsibility_id
                                                    AND furg.responsibility_application_id = fr.application_id
         JOIN   apps.fnd_application_vl fa            ON fr.application_id = fa.application_id
         WHERE  1=1
           AND furg.user_id = l_user_id
           AND    fa.application_short_name NOT IN ('SYSADMIN', 'FND', 'XDO', 'ALR','PER')
           ORDER BY application_short_name
           FETCH FIRST 1 ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Application not found for '||l_application_short_name,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Application not found for '||l_application_short_name||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20002,'Application not found for '||l_application_short_name);
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong: '||sqlerrm||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20202,'Something went wrong '||l_application_short_name);
    END;    
    END IF;

    -- 2.1 Initialize Multi-Org for Inventory
    -- This sets up the access map based on your responsibility's profile options
    BEGIN

    apps.MO_GLOBAL.INIT(l_application_short_name);
    EXCEPTION
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong initi for '||l_application_short_name||' -  '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong: '||sqlerrm||'"}';
            ROLLBACK;
            return l_return_value;
    --  2.2 Set Policy Context
    -- to work within one specific Operating Unit, find its ID first
    -- Example: Finding the OU linked to a specific Inventory Org (Chicago)
    END;
    
    IF l_operating_unit is null
    THEN
    BEGIN
          SELECT DISTINCT
                hou.organization_id AS operating_unit_id,
                hou.name            AS operating_unit_name
            INTO
               l_ou_id,
               l_operating_unit
            FROM apps.fnd_user_resp_groups_direct furg 
            JOIN apps.fnd_responsibility_vl       fr ON furg.responsibility_id = fr.responsibility_id AND furg.responsibility_application_id = fr.application_id
            JOIN apps.fnd_application_vl          fa ON fr.application_id = fa.application_id
            JOIN apps.fnd_profile_option_values   fpov ON fpov.level_value = furg.responsibility_id AND fpov.level_id = 10003 -- Level 10003 is 'Responsibility' level
            JOIN apps.fnd_profile_options         fp ON fpov.profile_option_id = fp.profile_option_id
            JOIN apps.hr_operating_units          hou ON hou.organization_id = TO_NUMBER(fpov.profile_option_value)
            WHERE fp.profile_option_name = 'ORG_ID'
                AND furg.user_id = l_user_id
                AND fa.application_short_name NOT IN ( 'SYSADMIN', 'FND', 'XDO', 'ALR' )
            ORDER BY operating_unit_id
            FETCH FIRST 1 ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Organization not found for '||l_email_address,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Organization not found for '||l_email_address||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20003,'Organization not found for '||l_email_address);
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong for '||l_email_address||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20303,'Something went wrong '||l_email_address);
        
    END;
    ELSE
    BEGIN
        SELECT
            operating_unit
        INTO l_ou_id
        FROM
            apps.org_organization_definitions
        WHERE
            upper(organization_name) = upper(l_operating_unit)
            FETCH FIRST 1 ROW ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            mcp_toolbox_log('Organization not found '||l_operating_unit,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Organization not found for '||l_operating_unit||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20004,'Organization not found for '||l_operating_unit);
        WHEN OTHERS THEN
            mcp_toolbox_log('Something went wrong '||sqlerrm,'ERROR',l_email_address,l_program_unit);
            l_return_value := '{"STATUS":"ERROR","MESSAGE":"Something went wrong for '||l_operating_unit||'"}';
            ROLLBACK;
            return l_return_value;
--            RAISE_APPLICATION_ERROR(-20404,'Something went wrong '||l_operating_unit);
        
    END;
    END IF;
    
    -- Set the context to 'S' (Single) for that specific OU
    apps.mo_global.set_policy_context('S', l_ou_id);
    
    mcp_toolbox_log('EBS session initialized successfully for user '
                    || l_email_address
                    || ' with responsibility '
                    || l_actual_resp_name,
                    'INFO',
                    l_email_address,l_program_unit);
    SELECT JSON_ARRAY(
        JSON_object('user_name' value l_email_address),
        JSON_object('responsibility_name' value fr.responsibility_name),
        JSON_object('security_group_name' value fsg.security_group_name),     -- Added Security Group Name
        JSON_object('application_short_name' value fa.application_short_name),
        JSON_object('operating_unit_name' value hou.name  )
        ) j
    INTO l_return_value
    FROM 
        apps.fnd_user fu,
        apps.fnd_responsibility_vl fr,
        apps.fnd_application fa,
        apps.hr_operating_units hou,
        apps.fnd_security_groups_vl fsg   -- Added Security Groups View
    WHERE 
        fu.user_id = apps.fnd_global.user_id
        AND fr.responsibility_id = apps.fnd_global.resp_id
        AND fr.application_id = apps.fnd_global.resp_appl_id
        AND fa.application_id = apps.fnd_global.resp_appl_id
        AND fsg.security_group_id = apps.fnd_global.security_group_id -- Join for Security Group
        AND hou.organization_id(+) = apps.fnd_global.org_id
    ;
    
    l_return_value := '{"STATUS":"SUCCESS","MESSAGE":'||l_return_value||'}';
    
--    "MESSAGE":"EBS session initialized successfully for user '
--                    || l_email_address
--                    || '","RESPONSIBILITY":"'
--                    || l_actual_resp_name
--                    || '","OPERATING_UNIT_NAME":"'
--                    || l_operating_unit
--                    ||'"}';
    COMMIT;
    RETURN l_return_value;
EXCEPTION
    WHEN OTHERS THEN
        l_errm := sqlerrm;
        ROLLBACK;
        mcp_toolbox_log('Failed to initialize EBS session - ' || l_errm,'ERROR',null,l_program_unit);
        l_return_value := '{"STATUS":"ERROR","MESSAGE":"Failed to initialize EBS session - ' || l_errm||'"}';
        return l_return_value;
END ebs_initialize_context;

function resolve_user(p_user_id IN VARCHAR2) RETURN VARCHAR2 IS
    l_id    VARCHAR2(240) := TRIM(p_user_id);
    l_count NUMBER;
    l_user  VARCHAR2(100);
BEGIN
    IF l_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'No user id was supplied');
    END IF;
    -- Same rule as ebs_initialize_context: an active FND user (not end-dated) with that e-mail address
    SELECT COUNT(*), MIN(u.user_name) INTO l_count, l_user
      FROM apps.fnd_user u
     WHERE (u.end_date IS NULL OR u.end_date > SYSDATE)
       AND ( (INSTR(l_id, '@') > 0 AND UPPER(u.email_address) = UPPER(l_id))
          OR (INSTR(l_id, '@') = 0 AND u.user_name = UPPER(l_id)) );
    IF l_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'No active EBS user for ' || SUBSTR(l_id, 1, 100));
    ELSIF l_count > 1 THEN
        RAISE_APPLICATION_ERROR(-20012, 'More than one active EBS user for ' || SUBSTR(l_id, 1, 100));
    END IF;
    RETURN l_user;
END resolve_user;

PROCEDURE init_user_session(p_user_id IN VARCHAR2) IS
    l_user    VARCHAR2(100) := resolve_user(p_user_id);   -- also refuses unknown and ambiguous users
    l_email   VARCHAR2(240);
    l_json    VARCHAR2(4000);
    l_status  VARCHAR2(200);
    l_message VARCHAR2(4000);
BEGIN
    SELECT u.email_address INTO l_email FROM apps.fnd_user u WHERE u.user_name = l_user;
    IF l_email IS NULL THEN
        RAISE_APPLICATION_ERROR(-20013, 'EBS user ' || l_user || ' has no e-mail address, so its context cannot be set');
    END IF;
    l_json := ebs_initialize_context(l_email);   -- {"STATUS":"SUCCESS"|"ERROR","MESSAGE":...}
    SELECT JSON_VALUE(l_json, '$.STATUS'), JSON_VALUE(l_json, '$.MESSAGE') INTO l_status, l_message FROM dual;
    IF UPPER(NVL(l_status, 'NONE')) <> 'SUCCESS' THEN
        RAISE_APPLICATION_ERROR(-20013, 'EBS security setup failed for ' || l_user || ': '
                                        || SUBSTR(NVL(l_message, NVL(l_status, 'unreadable answer')), 1, 300));
    END IF;
    DBMS_SESSION.SET_IDENTIFIER(SUBSTR(TRIM(p_user_id), 1, 64));   -- shows who the session works for (audit)
END init_user_session;

end xx_ai_security_pkg;
/

SHOW ERRORS PACKAGE BODY apps.xx_ai_security_pkg

-- Access for the MCP Toolbox user (change the grantee if yours has another name). Without it the
-- Toolbox reports "apps.xx_ai_security_pkg.init_user_session not found (or no EXECUTE privilege)".
GRANT EXECUTE ON apps.xx_ai_security_pkg TO apps_ai;
