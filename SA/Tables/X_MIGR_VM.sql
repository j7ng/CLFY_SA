CREATE TABLE sa.x_migr_vm (
  status VARCHAR2(100 BYTE),
  flag VARCHAR2(4 BYTE),
  new_flag VARCHAR2(4 BYTE)
);
ALTER TABLE sa.x_migr_vm ADD SUPPLEMENTAL LOG GROUP dmtsora1508492954_0 (flag, new_flag, status) ALWAYS;