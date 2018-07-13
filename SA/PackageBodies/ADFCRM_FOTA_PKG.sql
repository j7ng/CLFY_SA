CREATE OR REPLACE PACKAGE BODY sa.ADFCRM_FOTA_PKG
AS
  --------------------------------------------------------------------------------------------
  --$RCSfile: ADFCRM_FOTA_PKB.sql,v $
  --------------------------------------------------------------------------------------------
  PROCEDURE load_fota_members(
      ip_fota_objid IN VARCHAR2,
      op_err_code OUT VARCHAR2,
      op_err_msg OUT VARCHAR2)
  AS

  rows_inserted NUMBER;

  BEGIN
            IF ip_fota_objid IS NULL THEN
              op_err_code    :='-10';
            op_err_msg       :='ERROR: FOTA Campaign has need to be select';
            RETURN;
          END IF;


          delete ADFCRM_FOTA_CAMP_MEMBERS where FOTA_CAMP_OBJID = ip_fota_objid;

          INSERT
          INTO ADFCRM_FOTA_CAMP_MEMBERS
            (
              OBJID,
              FOTA_CAMP_OBJID,
              ESN,
              STATUS,
              CAL_TRANS_OBJID,
              insert_date,
              modify_date
            )
          SELECT SEQU_ADFCRM_FOTA_CAMP_MEMBERS.nextval,
            FC.FOTA_HDR_OBJID,
            PI.PART_SERIAL_NO, --PI.OBJID,
            'PENDING',
            NULL,
            sysdate,
            sysdate
          FROM sa.TABLE_PART_INST PI ,
            sa.TABLE_MOD_LEVEL ML ,
            sa.TABLE_PART_NUM PN ,
            sa.TABLE_PART_CLASS PC,
            sa.ADFCRM_FOTA_CAMP2PART_CLASS FC
          WHERE PI.X_DOMAIN       = 'PHONES'
          AND FC.FOTA_HDR_OBJID   = ip_fota_objid
          AND FC.PART_CLASS_OBJID = PC.OBJID
          AND ML.OBJID            = PI.N_PART_INST2PART_MOD
          AND PN.OBJID            = ML.PART_INFO2PART_NUM
          AND PC.OBJID            = PN.PART_NUM2PART_CLASS;

		  rows_inserted := sql%rowcount;

          COMMIT;

          op_err_code:='0';
          op_err_msg :='SUCCESS: ' || rows_inserted  ||' - FOTA Campaign Members has been processed.';
          RETURN;

    EXCEPTION
    WHEN OTHERS THEN
          op_err_code:=SQLCODE;
          op_err_msg :='ERROR: '||SUBSTR(SQLERRM,1,3990);

END load_fota_members;

END ADFCRM_FOTA_PKG;
/