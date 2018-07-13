CREATE TABLE sa.table_dist_obj (
  objid NUMBER,
  focus_type NUMBER,
  focus_lowid NUMBER,
  "VERSION" NUMBER,
  remote_obj NUMBER,
  remote_ver NUMBER,
  error_ind NUMBER,
  error_msg VARCHAR2(255 BYTE),
  dev NUMBER,
  dist_obj2dist_srvr NUMBER(*,0),
  dist_obj2dist_birth NUMBER(*,0)
);
ALTER TABLE sa.table_dist_obj ADD SUPPLEMENTAL LOG GROUP dmtsora1415915989_0 (dev, dist_obj2dist_birth, dist_obj2dist_srvr, error_ind, error_msg, focus_lowid, focus_type, objid, remote_obj, remote_ver, "VERSION") ALWAYS;