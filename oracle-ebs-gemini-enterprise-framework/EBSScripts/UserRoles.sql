/* this sql provides the list of responsibilities assigned for a given user including OU operating units*/
SELECT DISTINCT
                fu.user_name,
                fu.user_id,
                fa.application_short_name,
                fa.application_name,
                fr.responsibility_name,
                hou.organization_id AS operating_unit_id,
                hou.name            AS operating_unit_name
            FROM
                    fnd_user fu
                JOIN fnd_user_resp_groups_direct furg ON fu.user_id = furg.user_id
                JOIN fnd_responsibility_vl       fr ON furg.responsibility_id = fr.responsibility_id AND furg.responsibility_application_id = fr.application_id
                JOIN fnd_application_vl          fa ON fr.application_id = fa.application_id
                JOIN fnd_profile_option_values   fpov ON fpov.level_value = furg.responsibility_id AND fpov.level_id = 10003 -- Level 10003 is 'Responsibility' level
                JOIN fnd_profile_options         fp ON fpov.profile_option_id = fp.profile_option_id
                JOIN hr_operating_units          hou ON hou.organization_id = TO_NUMBER(fpov.profile_option_value)
            WHERE
                    fp.profile_option_name = 'ORG_ID'
                AND fu.email_address LIKE :1
                AND fa.application_short_name NOT IN ( 'SYSADMIN', 'FND', 'XDO', 'ALR' )
            ORDER BY
                fu.user_name,
                fr.responsibility_name;




/* this sql provides the distinct list of application short name and appliation name assigned for a given user */
SELECT DISTINCT 
       fu.user_name,
       fu.user_id,
       fa.application_short_name,
       fa.application_name 
FROM   fnd_user fu
JOIN   fnd_user_resp_groups_direct furg ON fu.user_id = furg.user_id
JOIN   fnd_responsibility_vl fr         ON furg.responsibility_id = fr.responsibility_id
                                        AND furg.responsibility_application_id = fr.application_id
JOIN   fnd_application_vl fa            ON fr.application_id = fa.application_id
WHERE  1=1
AND fu.email_address like :l_email_address  
AND    fa.application_short_name NOT IN ('SYSADMIN', 'FND', 'XDO', 'ALR')
ORDER BY fu.user_name; --, fr.responsibility_name;
