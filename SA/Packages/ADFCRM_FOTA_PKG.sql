CREATE OR REPLACE PACKAGE sa.ADFCRM_FOTA_PKG
AS
  --------------------------------------------------------------------------------------------
  --$RCSfile: ADFCRM_FOTA_PKG.sql,v $
  --------------------------------------------------------------------------------------------
  PROCEDURE load_fota_members(
      ip_fota_objid IN VARCHAR2,
      op_err_code OUT VARCHAR2,
      op_err_msg OUT VARCHAR2);
END ADFCRM_FOTA_PKG;
/