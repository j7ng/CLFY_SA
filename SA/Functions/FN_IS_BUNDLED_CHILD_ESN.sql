CREATE OR REPLACE FUNCTION sa.FN_IS_BUNDLED_CHILD_ESN(
    IP_X_CHARGE_TYPE              IN  sa.X_PROGRAM_ENROLLED.X_CHARGE_TYPE%TYPE
    , IP_PGM_ENROLL2PROG_HDR      IN  sa.X_PROGRAM_ENROLLED.PGM_ENROLL2PROG_HDR%TYPE)
  RETURN NUMBER
AS
BEGIN
-- Created this function for temporary purpose. Fixing a bug in BI reports.
-- BI will be removing this funtion as soon as we add dicount column in X_PROGRAM_PURCH_DTL and fix all flows to populate data into
-- these columns.
  IF NVL(IP_X_CHARGE_TYPE,'NULL') = 'BUNDLE' AND IP_PGM_ENROLL2PROG_HDR IS NOT NULL THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END FN_IS_BUNDLED_CHILD_ESN;
/