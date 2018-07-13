CREATE OR REPLACE FORCE VIEW sa.table_object2clone (birth_lowid,focus_lowid,remote_lowid,focus_type,"VERSION",remote_ver,dist_birth_srvr_id,dist_srvr_id,dist_obj_objid,dist_birth_objid,dist_srvr_objid,birth_srvr_objid,error_ind,error_msg,birth_srvr_id) AS
select table_dist_birth.focus_lowid, table_dist_obj.focus_lowid,
 table_dist_obj.remote_obj, table_dist_obj.focus_type,
 table_dist_obj.version, table_dist_obj.remote_ver,
 table_dist_birth_srvr.srvr_id, table_dist_obj_srvr.srvr_id,
 table_dist_obj.objid, table_dist_birth.objid,
 table_dist_obj_srvr.objid, table_dist_birth_srvr.objid,
 table_dist_obj.error_ind, table_dist_obj.error_msg,
 table_birth_srvr.srvr_id
 from table_dist_srvr table_dist_birth_srvr, table_dist_srvr table_dist_obj_srvr, table_dist_srvr table_birth_srvr, table_dist_birth, table_dist_obj
 where table_dist_birth_srvr.objid = table_dist_birth.dist_birth2dist_srvr
 AND table_birth_srvr.objid = table_dist_birth.birth_srvr2dist_srvr
 AND table_dist_obj_srvr.objid = table_dist_obj.dist_obj2dist_srvr
 AND table_dist_birth.objid = table_dist_obj.dist_obj2dist_birth
 ;
COMMENT ON TABLE sa.table_object2clone IS 'Used by Replication Engine';
COMMENT ON COLUMN sa.table_object2clone.birth_lowid IS 'Internal record number of the birth object';
COMMENT ON COLUMN sa.table_object2clone.focus_lowid IS 'Internal record number of the replicated object';
COMMENT ON COLUMN sa.table_object2clone.remote_lowid IS 'Internal record number of the remote object';
COMMENT ON COLUMN sa.table_object2clone.focus_type IS 'Type_id of the birth object';
COMMENT ON COLUMN sa.table_object2clone."VERSION" IS 'Version number replicated';
COMMENT ON COLUMN sa.table_object2clone.remote_ver IS 'Remote version number replicated';
COMMENT ON COLUMN sa.table_object2clone.dist_birth_srvr_id IS 'Server ID the object replicated from';
COMMENT ON COLUMN sa.table_object2clone.dist_srvr_id IS 'Server ID replicated in between';
COMMENT ON COLUMN sa.table_object2clone.dist_obj_objid IS 'Internal record number of the dist obj object';
COMMENT ON COLUMN sa.table_object2clone.dist_birth_objid IS 'Internal record number of the dist birth object';
COMMENT ON COLUMN sa.table_object2clone.dist_srvr_objid IS 'Internal record number of the dist srvr object';
COMMENT ON COLUMN sa.table_object2clone.birth_srvr_objid IS 'Internal record number of the dist birth srvr object';
COMMENT ON COLUMN sa.table_object2clone.error_ind IS 'Replication error indicator; i.e., 0=no error,1=replication error';
COMMENT ON COLUMN sa.table_object2clone.error_msg IS 'Text of replication error message';
COMMENT ON COLUMN sa.table_object2clone.birth_srvr_id IS 'Server ID the object first created on';