CREATE TABLE sa.ricky_pd (
  deact_mdn VARCHAR2(30 BYTE),
  deact_esn VARCHAR2(30 BYTE),
  deact_date DATE,
  x_reason VARCHAR2(20 BYTE),
  x_call_trans2carrier NUMBER
);
ALTER TABLE sa.ricky_pd ADD SUPPLEMENTAL LOG GROUP dmtsora2006711572_0 (deact_date, deact_esn, deact_mdn, x_call_trans2carrier, x_reason) ALWAYS;