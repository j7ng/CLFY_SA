CREATE OR REPLACE PACKAGE sa."SAFELINK_MAINTENANCE_PKG" AS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SAFELINK_MAINTENANCE_PKG_SPEC.sql,v $
  --$Revision: 1.1 $
  --$Author: kacosta $
  --$Date: 2012/03/02 19:35:58 $
  --$ $Log: SAFELINK_MAINTENANCE_PKG_SPEC.sql,v $
  --$ Revision 1.1  2012/03/02 19:35:58  kacosta
  --$ CR19754 Safelink Family Plan
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  -- Global Package Variables
  --
  l_b_debug BOOLEAN := FALSE;
  --
  --********************************************************************************
  -- Procedure to enrolled non-SafeLink ESN to the SafeLink Family Plan
  -- Procedure was created for CR19754
  --********************************************************************************
  --
  PROCEDURE referral_benefits_enrollment
  (
    p_enrolled_esn                IN sa.x_sl_referral_benefits_plan.enrolled_esn%TYPE
   ,p_safelink_min                IN sa.table_part_inst.part_serial_no%TYPE
   ,p_enrolled_into_double_minute OUT VARCHAR2
   ,p_error_code                  OUT PLS_INTEGER
   ,p_error_message               OUT VARCHAR2
  );
  --
END safelink_maintenance_pkg;
/