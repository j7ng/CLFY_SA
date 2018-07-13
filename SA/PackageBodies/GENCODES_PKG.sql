CREATE OR REPLACE PACKAGE BODY sa.GENCODES_PKG
IS
  ---------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------------------
PROCEDURE INSERT_X_GENCODES_BRKD_HDR(
    IP_ESN              IN sa.X_GENCODES_BREAKDOWN_HEADER.X_ESN%TYPE ,
    IP_CONFIG_ID        IN sa.X_GENCODES_BREAKDOWN_HEADER.X_CONFIG_ID%TYPE ,
    IP_STATUS           IN sa.X_GENCODES_BREAKDOWN_HEADER.X_STATUS%TYPE ,
    IP_IDN_USER_CREATED IN sa.X_GENCODES_BREAKDOWN_HEADER.X_IDN_USER_CREATED%TYPE ,
    OP_GENCODES_B_HDR_OBJID OUT sa.X_GENCODES_BREAKDOWN_HEADER.OBJID%TYPE ,
    OP_STATUS_CODE OUT VARCHAR2 ,
    OP_STATUS_MESSAGE OUT VARCHAR2 )
AS
  V_OBJID sa.X_GENCODES_BREAKDOWN_HEADER.OBJID%TYPE;
  V_ACTION VARCHAR2(1000);
  V_EXIST PLS_INTEGER :=0 ;
BEGIN
  OP_STATUS_CODE    := '0';
  OP_STATUS_MESSAGE := 'SUCCESS';
  V_ACTION          := 'Inserting record';
  IF IP_STATUS NOT IN( 'COMPLETED', 'PENDING') THEN
    V_ACTION := 'Data issue: Input status is not set to COMPLETED or PENDING';
    RAISE user_exception;
  END IF;
  SELECT COUNT(*)
  INTO V_EXIST
  FROM  sa.X_GENCODES_BREAKDOWN_HEADER H
        ,sa.X_GENCODES_BREAKDOWN_DETAILS D
  WHERE H.X_ESN       = IP_ESN
  AND H.X_CONFIG_ID   = IP_CONFIG_ID
  AND H.OBJID         = D.X_DETAILS_2_GENCODES_HDR_OBJID
  AND D.X_CMD_STATUS IN ('Y','P') ;
  IF V_EXIST          = 0 THEN
    SELECT sa.SEQU_X_GENCODES_BRKD_HDR.NEXTVAL INTO V_OBJID FROM DUAL;
    INSERT
    INTO sa.X_GENCODES_BREAKDOWN_HEADER
      (
        OBJID ,
        X_ESN ,
        X_CONFIG_ID ,
        X_STATUS ,
        X_IDN_USER_CREATED ,
        X_DTE_CREATED ,
        X_IDN_USER_CHANGE_LAST ,
        X_DTE_CHANGE_LAST
      )
      VALUES
      (
        V_OBJID
        ,IP_ESN
        ,IP_CONFIG_ID
        ,IP_STATUS
        ,IP_IDN_USER_CREATED --X_IDN_USER_CREATED
        ,SYSDATE --X_DTE_CREATED
        ,IP_IDN_USER_CREATED --X_IDN_USER_CHANGE_LAST
        ,SYSDATE --X_DTE_CHANGE_LAST
      );
  END IF;
  OP_GENCODES_B_HDR_OBJID := V_OBJID;
EXCEPTION
WHEN OTHERS THEN
  OP_STATUS_CODE          := '1';
  OP_STATUS_MESSAGE       := 'FAILURE';
  OP_GENCODES_B_HDR_OBJID := 0;
  ROLLBACK;
  OTA_UTIL_PKG.ERR_LOG ( 'Error '||V_ACTION||' for IP_ESN:'||IP_ESN||'; IP_CONFIG_ID:'||IP_CONFIG_ID||'; IP_STATUS:' ||IP_STATUS,         --p_action
  SYSDATE,                                                                                                                                --p_error_date
  IP_ESN,                                                                                                                                 --p_key
  'INSERT_X_GENCODES_BRKD_HDR',                                                                                                           --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
  );
END INSERT_X_GENCODES_BRKD_HDR;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_X_GENCODES_BRKD_HDR
  (
    IP_ESN                  IN sa.X_GENCODES_BREAKDOWN_HEADER.X_ESN%TYPE ,
    IP_CONFIG_ID            IN sa.X_GENCODES_BREAKDOWN_HEADER.X_CONFIG_ID%TYPE ,
    IP_STATUS               IN sa.X_GENCODES_BREAKDOWN_HEADER.X_STATUS%TYPE ,
    IP_IDN_USER_CHANGE_LAST IN sa.X_GENCODES_BREAKDOWN_HEADER.X_IDN_USER_CHANGE_LAST%TYPE ,
    OP_STATUS_CODE OUT VARCHAR2 ,
    OP_STATUS_MESSAGE OUT VARCHAR2
  )
AS
  V_ACTION VARCHAR2
  (
    1000
  )
  ;
  V_OBJID sa.X_GENCODES_BREAKDOWN_HEADER.OBJID%TYPE;
  V_PI_OBJID sa.TABLE_PART_INST.OBJID%TYPE;
  V_OTA_FEAT_OBJID sa.TABLE_X_OTA_FEATURES.OBJID%TYPE;
  V_CURRENT_CONFIG2X_DATACONFIG sa.TABLE_X_OTA_FEATURES.CURRENT_CONFIG2X_DATA_CONFIG%TYPE;
  V_NEW_CONFIG2X_DATA_CONFIG sa.TABLE_X_OTA_FEATURES.NEW_CONFIG2X_DATA_CONFIG%TYPE;
BEGIN
  OP_STATUS_CODE    := '0';
  OP_STATUS_MESSAGE := 'SUCCESS';
  V_ACTION          := 'Updating record in X_GENCODES_BREAKDOWN_HEADER';
  IF IP_STATUS NOT IN( 'COMPLETED', 'PENDING') THEN
    V_ACTION := 'Data issue: Input status is not set to COMPLETED or PENDING';
    RAISE user_exception;
  END IF;
  BEGIN
    SELECT OBJID
    INTO V_OBJID
    FROM
      (SELECT OBJID,
        ROW_NUMBER() OVER (PARTITION BY X_ESN, X_CONFIG_ID order by OBJID DESC) r
      FROM sa.X_GENCODES_BREAKDOWN_HEADER
      WHERE X_ESN     = IP_ESN
      AND X_CONFIG_ID = IP_CONFIG_ID
      )
    WHERE R=1 ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    V_ACTION := 'Data issue: No data exist to update';
    RAISE;
  WHEN OTHERS THEN
    V_ACTION := 'Error while retrieving records from SA.X_GENCODES_BREAKDOWN_HEADER';
    RAISE;
  END;
  IF V_OBJID IS NOT NULL THEN
    UPDATE sa.X_GENCODES_BREAKDOWN_HEADER
    SET X_STATUS             = IP_STATUS ,
      X_IDN_USER_CHANGE_LAST = IP_IDN_USER_CHANGE_LAST ,
      X_DTE_CHANGE_LAST      = SYSDATE
    WHERE OBJID              = V_OBJID;
  END IF;
  IF IP_STATUS = 'COMPLETED' THEN
    V_ACTION  := 'Select data from TABLE_PART_INST; Updating record in TABLE_X_OTA_FEATURES';
    SELECT OBJID
    INTO V_PI_OBJID
    FROM sa.TABLE_PART_INST
    WHERE PART_SERIAL_NO=IP_ESN
    AND X_DOMAIN        ='PHONES' ;
    V_ACTION           := 'Select data from TABLE_X_OTA_FEATURES';
    SELECT OBJID ,
      CURRENT_CONFIG2X_DATA_CONFIG ,
      NEW_CONFIG2X_DATA_CONFIG
    INTO V_OTA_FEAT_OBJID ,
      V_CURRENT_CONFIG2X_DATACONFIG ,
      V_NEW_CONFIG2X_DATA_CONFIG
    FROM sa.TABLE_X_OTA_FEATURES
    WHERE X_OTA_FEATURES2PART_INST = V_PI_OBJID ;
    V_ACTION                      := 'Updating record in TABLE_X_OTA_FEATURES';
    UPDATE sa.TABLE_X_OTA_FEATURES
    SET CURRENT_CONFIG2X_DATA_CONFIG = V_NEW_CONFIG2X_DATA_CONFIG ,
      NEW_CONFIG2X_DATA_CONFIG       = NULL
    WHERE OBJID                      = V_OTA_FEAT_OBJID ;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  OP_STATUS_CODE    := '1';
  OP_STATUS_MESSAGE := 'FAILURE';
  ROLLBACK;
  OTA_UTIL_PKG.ERR_LOG ( 'Error '||V_ACTION||' for IP_ESN:'||IP_ESN||'; IP_CONFIG_ID:'||IP_CONFIG_ID||'; IP_STATUS:' ||IP_STATUS,         --p_action
  SYSDATE,                                                                                                                                --p_error_date
  IP_ESN,                                                                                                                                 --p_key
  'UPDATE_X_GENCODES_BRKD_HDR',                                                                                                           --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
  );
END UPDATE_X_GENCODES_BRKD_HDR;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
PROCEDURE INSERT_X_GENCODES_BRKD_DTL(
    IP_DTL_2_GENCODE_HDR_OBJID IN sa.X_GENCODES_BREAKDOWN_DETAILS.X_DETAILS_2_GENCODES_HDR_OBJID%TYPE ,
    IP_CMD_NAME                IN sa.X_GENCODES_BREAKDOWN_DETAILS.X_CMD_NAME%TYPE ,
    IP_CMD_STATUS              IN sa.X_GENCODES_BREAKDOWN_DETAILS.X_CMD_STATUS%TYPE ,
    IP_IDN_USER_CREATED        IN sa.X_GENCODES_BREAKDOWN_DETAILS.X_IDN_USER_CREATED%TYPE ,
    OP_GENCODES_B_DTL_OBJID OUT sa.X_GENCODES_BREAKDOWN_DETAILS.OBJID%TYPE ,
    OP_STATUS_CODE OUT VARCHAR2 ,
    OP_STATUS_MESSAGE OUT VARCHAR2 )
AS
  V_OBJID sa.X_GENCODES_BREAKDOWN_DETAILS.OBJID%TYPE;
  V_ACTION VARCHAR2(1000);
BEGIN
  OP_STATUS_CODE    := '0';
  OP_STATUS_MESSAGE := 'SUCCESS';
  V_ACTION          := 'Inserting record';
  --Valid status--
  --'Y'-- NEED TO PROCESS
  --'P'-- PENDING ACKNOWLEDMENT
  --'A'-- ACKNOWLEDGED
  IF IP_CMD_STATUS NOT IN( 'Y', 'P', 'A') THEN
    V_ACTION := 'Data issue:Input CMD status is not set to Y or P or A';
    RAISE user_exception;
  END IF;
  SELECT sa.SEQU_X_GENCODES_BREAKDOWN_DTL.NEXTVAL INTO V_OBJID FROM DUAL;
  INSERT
  INTO sa.X_GENCODES_BREAKDOWN_DETAILS
    (
      OBJID ,
      X_DETAILS_2_GENCODES_HDR_OBJID ,
      X_CMD_NAME ,
      X_CMD_STATUS ,
      X_IDN_USER_CREATED ,
      X_DTE_CREATED ,
      X_IDN_USER_CHANGE_LAST ,
      X_DTE_CHANGE_LAST
    )
    VALUES
    (
      V_OBJID ,
      IP_DTL_2_GENCODE_HDR_OBJID ,
      IP_CMD_NAME ,
      IP_CMD_STATUS ,
      IP_IDN_USER_CREATED --X_IDN_USER_CREATED
      ,
      SYSDATE --X_DTE_CREATED
      ,
      IP_IDN_USER_CREATED --X_IDN_USER_CHANGE_LAST
      ,
      SYSDATE --X_DTE_CHANGE_LAST
    );
  OP_GENCODES_B_DTL_OBJID := V_OBJID;
EXCEPTION
WHEN OTHERS THEN
  OP_STATUS_CODE          := '1';
  OP_STATUS_MESSAGE       := 'FAILURE';
  OP_GENCODES_B_DTL_OBJID := 0;
  ROLLBACK;
  OTA_UTIL_PKG.ERR_LOG ( 'Error '||V_ACTION||' for IP_DTL_2_GENCODE_HDR_OBJID:'||IP_DTL_2_GENCODE_HDR_OBJID||'; IP_CMD_NAME:'||IP_CMD_NAME||'; IP_CMD_STATUS:' ||IP_CMD_STATUS, --p_action
  SYSDATE,                                                                                                                                                                      --p_error_date
  IP_DTL_2_GENCODE_HDR_OBJID,                                                                                                                                                   --p_key
  'INSERT_X_GENCODES_BRKD_DTL',                                                                                                                                                 --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()                                      --p_error_text
  );
END INSERT_X_GENCODES_BRKD_DTL;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
PROCEDURE update_x_gencodes_brkd_dtl ( ip_dtl_2_gencode_hdr_objid IN  sa.x_gencodes_breakdown_details.x_details_2_gencodes_hdr_objid%type ,
                                       ip_cmd_name                IN  sa.x_gencodes_breakdown_details.x_cmd_name%type ,
                                       ip_cmd_status              IN  sa.x_gencodes_breakdown_details.x_cmd_status%type ,
                                       ip_idn_user_change_last    IN  sa.x_gencodes_breakdown_details.x_idn_user_change_last%type ,
                                       op_status_code             OUT VARCHAR2 ,
                                       op_status_message          OUT VARCHAR2 )
AS

	--Changes for CR53392 start
  v_objid sa.x_gencodes_breakdown_details.objid%TYPE;

BEGIN

  op_status_code    := '0';
  op_status_message := 'SUCCESS';

  --Valid status
  --'Y'-- NEED TO PROCESS
  --'P'-- PENDING ACKNOWLEDMENT
  --'A'-- ACKNOWLEDGED

  --
  IF ip_cmd_status NOT IN ( 'Y', 'P', 'A') THEN
    --
	  op_status_code := '1';
	  op_status_message := 'FAILURE - Data issue:Input CMD status is not set to Y or P or A';
	  RETURN;
  END IF;

  --
  BEGIN
    SELECT objid
    INTO   v_objid
    FROM   sa.x_gencodes_breakdown_details
    WHERE  x_details_2_gencodes_hdr_objid = ip_dtl_2_gencode_hdr_objid
    AND    x_cmd_name = ip_cmd_name;
   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
     --
	   op_status_code    := '1';
	   op_status_message := 'FAILURE - Data issue: No data exist to update';
	   RETURN;
   WHEN OTHERS
   THEN
     --
     op_status_code    := '1';
        op_status_message := 'FAILURE - Error while retrieving records from SA.X_GENCODES_BREAKDOWN_DETAILS: '|| SQLERRM;
     RETURN;
  END;
  --
  IF v_objid IS NOT NULL
  THEN
    UPDATE sa.x_gencodes_breakdown_details
    SET    x_cmd_status           = ip_cmd_status ,
           x_idn_user_change_last = ip_idn_user_change_last ,
           x_dte_change_last      = SYSDATE
    WHERE  objid = v_objid;
  END IF;

 EXCEPTION
 WHEN OTHERS
 THEN
   op_status_code    := '1';
	 op_status_message := 'FAILURE-' || SQLERRM;
	 --Changes for CR53392 end

END update_x_gencodes_brkd_dtl;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
END GENCODES_PKG;
/