CREATE OR REPLACE PACKAGE sa.ACTIVE_SAFELINK_REPL_PHONES
AS
  ---------------------------------------------------------------------------------------------
  l_b_debug BOOLEAN := TRUE;
  PROCEDURE SP_active_safelink_phones(
      P_case_id IN VARCHAR2 ,
      P_OLD_ESN IN VARCHAR2,
      P_NEW_ESN IN VARCHAR2,
      P_REPL_UNITS OUT VARCHAR2,
      P_REQUEST_PLAN OUT VARCHAR2,
      P_LID OUT VARCHAR2,
      P_CONT_PART_INST OUT VARCHAR2,
      P_MIN OUT VARCHAR2,
      P_ACTIVE_ESN OUT VARCHAR2,
      p_active_esn_status OUT VARCHAR2,
      P_LOGIN_NAME OUT VARCHAR2,
      P_WEB_USER_ID OUT VARCHAR2,
      P_STATE OUT VARCHAR2,
      P_FLAG OUT VARCHAR2,
      P_OBJID OUT VARCHAR2,
      p_carrier_flag OUT VARCHAR2,
      P_ERROR_NO OUT VARCHAR2,
      P_ERROR_STR OUT VARCHAR2 );
  PROCEDURE SP_MOVE_RESERVED_LINE(
      P_CASE_OBJID              IN VARCHAR2 ,
      P_OLD_ESN                 IN VARCHAR2 ,
      P_NEW_ESN                 IN VARCHAR2 ,
      P_NEW_ESN_PART_INST_OBJID IN sa.TABLE_PART_INST.OBJID%TYPE ,
      P_ERROR_NO OUT VARCHAR2 ,
      P_ERROR_STR OUT VARCHAR2 );
  PROCEDURE SP_MANAGE_ACCT(
      P_CASE_OBJID              IN VARCHAR2 ,
      P_OLD_ESN                 IN VARCHAR2 ,
      P_NEW_ESN                 IN VARCHAR2 ,
      P_NEW_ESN_PART_INST_OBJID IN sa.TABLE_PART_INST.OBJID%TYPE ,
      P_ERROR_NO OUT VARCHAR2 ,
      P_ERROR_STR OUT VARCHAR2 );
  PROCEDURE SP_NON_ACTIVE_ESN_NO_SHIPED_PH(
      P_CASE_OBJID IN VARCHAR2 ,
      P_OLD_ESN    IN VARCHAR2 ,
      P_NEW_ESN    IN VARCHAR2 ,
      P_ERROR_NO OUT VARCHAR2 ,
      P_ERROR_STR OUT VARCHAR2 );
    PROCEDURE OTA_PENDING_PROCESS
(P_ESN VARCHAR2,
P_ERROR_NO OUT VARCHAR2 ,
P_ERROR_STR OUT VARCHAR2);
END ACTIVE_SAFELINK_REPL_PHONES;
/