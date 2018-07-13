CREATE TABLE sa.x_posa_audit2 (
  smp VARCHAR2(30 BYTE),
  out1 VARCHAR2(15 BYTE),
  out2 VARCHAR2(15 BYTE),
  datein DATE
);
ALTER TABLE sa.x_posa_audit2 ADD SUPPLEMENTAL LOG GROUP dmtsora1096762419_0 (datein, out1, out2, smp) ALWAYS;