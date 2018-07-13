CREATE TABLE sa.table_cam_per_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  cam_role2person NUMBER(*,0),
  cam_role2campaign NUMBER(*,0)
);
ALTER TABLE sa.table_cam_per_role ADD SUPPLEMENTAL LOG GROUP dmtsora101827544_0 ("ACTIVE", cam_role2campaign, cam_role2person, dev, focus_type, objid, role_name) ALWAYS;