CREATE TABLE sa.xsu_vmbc_response (
  responseto VARCHAR2(200 BYTE),
  requestid VARCHAR2(200 BYTE),
  lid VARCHAR2(200 BYTE),
  enrollrequest VARCHAR2(200 BYTE),
  errorcode VARCHAR2(200 BYTE),
  errormsg VARCHAR2(200 BYTE),
  activatedate VARCHAR2(200 BYTE),
  phoneesn VARCHAR2(200 BYTE),
  phonenumber VARCHAR2(200 BYTE),
  trackingnumber VARCHAR2(200 BYTE),
  ticketnumber VARCHAR2(200 BYTE),
  batchdate DATE,
  data_source VARCHAR2(50 BYTE)
);
COMMENT ON COLUMN sa.xsu_vmbc_response.data_source IS 'Indicates data source as VMBC, SOLIX';