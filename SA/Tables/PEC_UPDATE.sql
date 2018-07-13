CREATE TABLE sa.pec_update (
  esn VARCHAR2(11 BYTE),
  amount_due NUMBER(10,2),
  x_program_name VARCHAR2(25 BYTE),
  x_program_type NUMBER,
  x_part_inst_status VARCHAR2(20 BYTE),
  account_status VARCHAR2(1 BYTE)
);
ALTER TABLE sa.pec_update ADD SUPPLEMENTAL LOG GROUP dmtsora1151011417_0 (account_status, amount_due, esn, x_part_inst_status, x_program_name, x_program_type) ALWAYS;