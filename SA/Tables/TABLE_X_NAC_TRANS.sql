CREATE TABLE sa.table_x_nac_trans (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_brand VARCHAR2(40 BYTE),
  x_nac_flag VARCHAR2(10 BYTE),
  nac2partinst NUMBER
);
COMMENT ON COLUMN sa.table_x_nac_trans.objid IS 'INTERNAL UNIQUE IDENTIFIER FROM SEQUENCE SA.SEQU_NAC_TRANS';
COMMENT ON COLUMN sa.table_x_nac_trans.x_esn IS 'BRANDED ESN  ';
COMMENT ON COLUMN sa.table_x_nac_trans.x_brand IS 'TABLE BUSINESS ORG ID';
COMMENT ON COLUMN sa.table_x_nac_trans.x_nac_flag IS 'NAC TRANSFER OR NOT WHILE REGISTERING';
COMMENT ON COLUMN sa.table_x_nac_trans.nac2partinst IS 'PART INST OBJID FOR ESN ';