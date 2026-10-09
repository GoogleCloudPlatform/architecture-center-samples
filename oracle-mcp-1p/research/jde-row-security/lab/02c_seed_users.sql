-- Run once as JDE_RS_LAB (already applied: do not rerun, it would duplicate the rows).
-- lab users: BORKUR (the project owner's own e-mail), plus role + role membership
INSERT INTO f0092 (uluser, ulan8) VALUES (N'BORKUR', 999001);
INSERT INTO f01151 (eaan8, eaidln, eaemal) VALUES (999001, 0, N'borkur@pythian.com');
INSERT INTO f95921 (rlfrrole, rltorole) VALUES (N'BORKUR', N'LABROLE');
COMMIT;
EXIT
