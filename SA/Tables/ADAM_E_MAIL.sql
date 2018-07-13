CREATE TABLE sa.adam_e_mail (
  x_service_id VARCHAR2(30 BYTE),
  x_expire_dt DATE,
  part_status VARCHAR2(40 BYTE),
  e_mail VARCHAR2(80 BYTE)
);
ALTER TABLE sa.adam_e_mail ADD SUPPLEMENTAL LOG GROUP dmtsora1284472308_0 (e_mail, part_status, x_expire_dt, x_service_id) ALWAYS;