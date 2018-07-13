CREATE TABLE sa.table_qry_grp (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  icon_id NUMBER,
  sharable NUMBER,
  dev NUMBER,
  qry_grp_owner2user NUMBER(*,0)
);
ALTER TABLE sa.table_qry_grp ADD SUPPLEMENTAL LOG GROUP dmtsora907226891_0 (dev, icon_id, objid, qry_grp_owner2user, sharable, title) ALWAYS;