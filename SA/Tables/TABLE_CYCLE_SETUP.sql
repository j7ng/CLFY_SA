CREATE TABLE sa.table_cycle_setup (
  objid NUMBER,
  dev NUMBER,
  abc_cd_cls VARCHAR2(8 BYTE),
  abc_cd_desc VARCHAR2(80 BYTE),
  s_abc_cd_desc VARCHAR2(80 BYTE),
  abc_cd_rank NUMBER,
  abc_pct NUMBER,
  abc_global NUMBER,
  frequency NUMBER,
  pct_tolerance NUMBER,
  ct_per_day NUMBER,
  val_freq NUMBER,
  val_from NUMBER(19,4),
  val_to NUMBER(19,4),
  cost_tolerance NUMBER(19,4),
  last_ct_per_day NUMBER,
  num_cc_parts NUMBER,
  csetup2cycle_count NUMBER
);
ALTER TABLE sa.table_cycle_setup ADD SUPPLEMENTAL LOG GROUP dmtsora255905561_0 (abc_cd_cls, abc_cd_desc, abc_cd_rank, abc_global, abc_pct, cost_tolerance, csetup2cycle_count, ct_per_day, dev, frequency, last_ct_per_day, num_cc_parts, objid, pct_tolerance, s_abc_cd_desc, val_freq, val_from, val_to) ALWAYS;