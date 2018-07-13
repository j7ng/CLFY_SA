CREATE TABLE sa.x_load_iccid_stg (
  sim VARCHAR2(50 BYTE),
  qty VARCHAR2(5 BYTE),
  pin1 VARCHAR2(25 BYTE),
  puk1 VARCHAR2(25 BYTE),
  pin2 VARCHAR2(25 BYTE),
  puk2 VARCHAR2(25 BYTE),
  inserted_on DATE,
  inserted_by VARCHAR2(50 BYTE),
  sd_ticket VARCHAR2(30 BYTE),
  mnc VARCHAR2(30 BYTE),
  purchase_order VARCHAR2(30 BYTE),
  insert_flag VARCHAR2(3 BYTE) DEFAULT 'N',
  part_number VARCHAR2(30 BYTE),
  imsi VARCHAR2(30 BYTE)
);
COMMENT ON COLUMN sa.x_load_iccid_stg.imsi IS 'IMSI OF THE SIM';