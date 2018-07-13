CREATE TABLE sa.adfcrm_gen_code_template (
  code_temp_objid NUMBER(22) NOT NULL,
  intdlltouse VARCHAR2(4000 BYTE),
  esn VARCHAR2(30 BYTE),
  "SEQUENCE" NUMBER(22),
  phone_technology NUMBER(22),
  dllcode NUMBER(22,4),
  data1 NUMBER(22,4),
  data2 NUMBER(22,4),
  data3 NUMBER(22,4),
  data4 NUMBER(22,4),
  data5 NUMBER(22,4),
  data6 NUMBER(22,4),
  data7 NUMBER(22,4),
  data8 NUMBER(22,4),
  data9 VARCHAR2(4000 BYTE),
  data10 NUMBER(22,4),
  data11 VARCHAR2(4000 BYTE),
  CONSTRAINT adfcrm_gen_code_template_pk PRIMARY KEY (code_temp_objid)
);
COMMENT ON TABLE sa.adfcrm_gen_code_template IS 'Holds data required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.code_temp_objid IS 'References to table_x_code_hist_temp.objid';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.intdlltouse IS 'DLL related with the phone''s part number';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.esn IS 'Phone serial number';
COMMENT ON COLUMN sa.adfcrm_gen_code_template."SEQUENCE" IS 'Sequence related to the phone';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.phone_technology IS 'Phone technology';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.dllcode IS 'DLL command related with the code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data1 IS 'Holds data 1 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data2 IS 'Holds data 2 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data3 IS 'Holds data 3 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data4 IS 'Holds data 4 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data5 IS 'Holds data 5 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data6 IS 'Holds data 6 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data7 IS 'Holds data 7 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data8 IS 'Holds data 8 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data9 IS 'Holds data 9 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data10 IS 'Holds data 10 required to generate personality code';
COMMENT ON COLUMN sa.adfcrm_gen_code_template.data11 IS 'Holds data 11 required to generate personality code';