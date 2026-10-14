-- Master installation script for Oracle PeopleSoft FSCM 9.2 (EP92U055) MCP Server & Government Skills
-- Note: PSFTScripts/install_gov_psft_mcp_and_seed.sql (108 KB) is committed and tracked in this directory
-- (GitHub omits files >100 KB from unified PR diff views).
@create_psft_ai.sql "&1"
@ge_psft_mcp_tools.sql
@install_gov_psft_mcp_and_seed.sql
@install_gov_public_sector_views.sql
