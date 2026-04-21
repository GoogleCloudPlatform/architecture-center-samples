/* This SQL provides the current user, responsibility, operating unit, security group for a session,  usuly this sql runs to vlaidate the session after apps initilise is done*/
SELECT 
    fu.user_name,
    fr.responsibility_name,
    fsg.security_group_name,     -- Added Security Group Name
    fa.application_short_name,
    hou.name AS operating_unit_name,
    fu.user_id current_user_id,
    fr.responsibility_id current_resp_id,
    fnd_global.org_id AS current_org_id,
    fnd_global.security_group_id AS security_group_id
FROM 
    fnd_user fu,
    fnd_responsibility_vl fr,
    fnd_application fa,
    hr_operating_units hou,
    fnd_security_groups_vl fsg   -- Added Security Groups View
WHERE 
    fu.user_id = fnd_global.user_id
    AND fr.responsibility_id = fnd_global.resp_id
    AND fr.application_id = fnd_global.resp_appl_id
    AND fa.application_id = fnd_global.resp_appl_id
    AND fsg.security_group_id = fnd_global.security_group_id -- Join for Security Group
    AND hou.organization_id(+) = fnd_global.org_id;



begin
ge_ebs_mcp_tools.ebs_initialize_context('BORKUR');
end;
/

          SELECT *
--                hou.organization_id AS operating_unit_id,
--                hou.name            AS operating_unit_name
--            INTO
--               l_ou_id,
--               l_organization_name
            FROM fnd_user fu
            JOIN fnd_user_resp_groups_direct furg ON fu.user_id = furg.user_id
            JOIN fnd_responsibility_vl       fr ON furg.responsibility_id = fr.responsibility_id AND furg.responsibility_application_id = fr.application_id
            JOIN fnd_application_vl          fa ON fr.application_id = fa.application_id
            JOIN fnd_profile_option_values   fpov ON fpov.level_value = furg.responsibility_id AND fpov.level_id = 10003 -- Level 10003 is 'Responsibility' level
            JOIN fnd_profile_options         fp ON fpov.profile_option_id = fp.profile_option_id
            JOIN hr_operating_units          hou ON hou.organization_id = TO_NUMBER(fpov.profile_option_value)
            WHERE fp.profile_option_name = 'ORG_ID'
                AND fu.email_address = :l_email_address
                AND fa.application_short_name NOT IN ( 'SYSADMIN', 'FND', 'XDO', 'ALR' )
            ORDER BY hou.organization_id 
--            FETCH FIRST 1 ROW ONLY
            ;
    