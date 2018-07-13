CREATE TABLE sa.x_crm_perms2priv_class_hist (
  permission_objid NUMBER,
  priv_class_objid NUMBER,
  osuser VARCHAR2(30 BYTE),
  change_by VARCHAR2(30 BYTE),
  change_date DATE,
  trig_event VARCHAR2(1 BYTE)
);