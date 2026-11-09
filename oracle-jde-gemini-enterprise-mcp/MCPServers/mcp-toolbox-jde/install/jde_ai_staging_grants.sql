-- Gives JDE_AI the right to insert into (and read) the seven JDE batch interface tables that
-- xx_ai_staging_pkg writes. Run as the owner of the JDE data schema (or a DBA) BEFORE xx_ai_staging_pkg.sql.
-- JDE_AI needs the grants directly, not through a role, because the package runs with definer's rights.
-- The MCP Toolbox user does NOT get these: it only gets EXECUTE on the package.
@@jde_install_config.sql
-- journal entry batch file
GRANT INSERT, SELECT ON &&jde_data_schema..f0911z1 TO jde_ai;
-- voucher transactions batch upload
GRANT INSERT, SELECT ON &&jde_data_schema..f0411z1 TO jde_ai;
-- sales order header, unedited transactions
GRANT INSERT, SELECT ON &&jde_data_schema..f4201z1 TO jde_ai;
-- sales order detail, unedited transactions
GRANT INSERT, SELECT ON &&jde_data_schema..f4211z1 TO jde_ai;
-- purchase order header, unedited transactions
GRANT INSERT, SELECT ON &&jde_data_schema..f4301z1 TO jde_ai;
-- purchase order detail, unedited transactions
GRANT INSERT, SELECT ON &&jde_data_schema..f4311z1 TO jde_ai;
-- address book, unedited transactions
GRANT INSERT, SELECT ON &&jde_data_schema..f0101z2 TO jde_ai;
exit;
