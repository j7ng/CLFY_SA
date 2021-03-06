CREATE TABLE sa.table_frcst_itm (
  objid NUMBER,
  eff_date DATE,
  quantity NUMBER,
  amount NUMBER(19,4),
  split_percent NUMBER,
  comments VARCHAR2(255 BYTE),
  conf_amt NUMBER,
  conf_cls NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  line VARCHAR2(20 BYTE),
  probability NUMBER,
  discount NUMBER,
  status VARCHAR2(40 BYTE),
  close_date DATE,
  "FAMILY" VARCHAR2(20 BYTE),
  id_number VARCHAR2(32 BYTE),
  arch_ind NUMBER,
  dev NUMBER,
  item2opportunity NUMBER(*,0),
  frcst_itm2territory NUMBER(*,0),
  frcst_itm2currency NUMBER(*,0),
  originator2user NUMBER(*,0),
  item2bus_org NUMBER,
  itm_owner2usr_ter_role NUMBER
);
ALTER TABLE sa.table_frcst_itm ADD SUPPLEMENTAL LOG GROUP dmtsora525381303_0 (amount, arch_ind, close_date, comments, conf_amt, conf_cls, dev, discount, eff_date, "FAMILY", frcst_itm2currency, frcst_itm2territory, id_number, item2bus_org, item2opportunity, itm_owner2usr_ter_role, line, "NAME", objid, originator2user, probability, quantity, split_percent, status) ALWAYS;