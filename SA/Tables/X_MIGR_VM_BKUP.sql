CREATE TABLE sa.x_migr_vm_bkup (
  status VARCHAR2(100 BYTE),
  flag VARCHAR2(4 BYTE),
  new_flag VARCHAR2(4 BYTE)
);
ALTER TABLE sa.x_migr_vm_bkup ADD SUPPLEMENTAL LOG GROUP dmtsora1235912629_0 (flag, new_flag, status) ALWAYS;