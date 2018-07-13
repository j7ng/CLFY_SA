CREATE TABLE sa.x_special_instructions_list (
  x_esn VARCHAR2(30 BYTE),
  x_instruc_code VARCHAR2(5 BYTE),
  x_insert_date DATE,
  x_process_date DATE
);
ALTER TABLE sa.x_special_instructions_list ADD SUPPLEMENTAL LOG GROUP dmtsora280834305_0 (x_esn, x_insert_date, x_instruc_code, x_process_date) ALWAYS;