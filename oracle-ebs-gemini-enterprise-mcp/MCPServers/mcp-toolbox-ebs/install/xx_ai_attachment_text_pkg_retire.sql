-- Retires the old package that xx_ai_attachment_pkg.sql replaces. Run as APPS, only after
-- ebs_get_attachment_text uses xx_ai_attachment_pkg (see ebs/install/README.md). It does NOT drop
-- the Oracle Text policy and preference: the new package uses the same ones.
DROP PACKAGE xx_ai_attachment_text_pkg;
