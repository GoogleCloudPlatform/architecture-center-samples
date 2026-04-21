
select ID,PROGRAM_UNIT, LOG_LEVEL, USERNAME, LOG_MESSAGE,CREATED_ON
from  "APPS"."GGLTOOLBOX$MCP_LOG" 
where 1=1
order by id desc  ;
  
SELECT
OS_USERNAME,
CLIENT_IDENTIFIER,
    event_timestamp,
    dbusername,
    action_name,
    sql_text,
    OBJECT_NAME
FROM
    unified_audit_trail
WHERE 1=1
    AND dbusername = 'APPS_AI' 
    AND UNIFIED_AUDIT_POLICIES = 'APPS_AI_STATEMENTS_AUDIT_POLICY'
and CLIENT_PROGRAM_NAME='toolbox'
ORDER BY event_timestamp desc;
