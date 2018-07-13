CREATE OR REPLACE FUNCTION sa.LL_ENROLLMENT_EXIST_FUN(ip_min sa.ll_subscribers.current_min%TYPE)
RETURN BOOLEAN
IS
 /*****************************************************************
 * Purpose : To get liefeline enrollment status for the provided min
 *			 This function is specific for LifeLine for Others - WFM project
 * 			 (not applicable to regular Safelink enrollments)
 * CR : CR48065
 * Platform : Oracle 8.0.6 and newer versions.
 * Created by : Maulik Dave (mdave)
 * Date : 06/26/2017
 * History
 * REVISIONS VERSION DATE WHO PURPOSE
 * ------------------------------------------------------------- */
  l_exists BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF ip_min IS NULL THEN
    RETURN l_exists;
  END IF;

  FOR c1 IN
  ( SELECT 1
           FROM sa.LL_SUBSCRIBERS
           WHERE current_min = ip_min
           AND   NVL(enrollment_status, 'ENROLLED') = 'ENROLLED'
           AND   TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE)
           and rownum = 1
  )
  LOOP
    l_exists := TRUE;
    EXIT; -- exit if one active record found
  END LOOP;
  RETURN l_exists;
    EXCEPTION WHEN OTHERS THEN
       RETURN l_exists; -- If no records found return false.
END ll_enrollment_exist_fun;
/