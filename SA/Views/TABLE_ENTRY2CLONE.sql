CREATE OR REPLACE FORCE VIEW sa.table_entry2clone (to_do_objid,"OPCODE","VERSION",reverse_ind,birth_lowid,focus_lowid,birth_type,remote_obj,remote_srvr,remote_sobj,entry_objid,dist_objid,start_time,end_time,entry_time,remote_ver,status,error_ind,rec_level,birth_srvr) AS
select table_to_do_entry.objid, table_to_do_entry.opcode,
 table_to_do_entry.version, table_to_do_entry.reverse_ind,
 table_dist_birth.focus_lowid, table_dist_obj.focus_lowid,
 table_dist_birth.focus_type, table_dist_obj.remote_obj,
 table_dist_obj_srvr.srvr_id, table_dist_obj_srvr.objid,
 table_to_do_entry.to_do_entry2act_entry, table_dist_obj.objid,
 table_to_do_entry.start_time, table_to_do_entry.end_time,
 table_to_do_entry.entry_time, table_dist_obj.remote_ver,
 table_dist_obj_srvr.status, table_dist_obj.error_ind,
 table_to_do_entry.rec_level, table_dist_birth_srvr.srvr_id
 from table_dist_srvr table_dist_obj_srvr, table_dist_srvr table_dist_birth_srvr, table_to_do_entry, table_dist_birth, table_dist_obj
 where table_dist_obj.objid = table_to_do_entry.to_do_entry2dist_obj
 AND table_dist_birth.objid = table_dist_obj.dist_obj2dist_birth
 AND table_to_do_entry.to_do_entry2act_entry IS NOT NULL
 AND table_dist_obj_srvr.objid = table_dist_obj.dist_obj2dist_srvr
 AND table_dist_birth_srvr.objid = table_dist_birth.birth_srvr2dist_srvr
 ;
COMMENT ON TABLE sa.table_entry2clone IS 'Used by Replication Engine';
COMMENT ON COLUMN sa.table_entry2clone.to_do_objid IS 'Internal record number of the to_do_entry';
COMMENT ON COLUMN sa.table_entry2clone."OPCODE" IS 'Replication service provided';
COMMENT ON COLUMN sa.table_entry2clone."VERSION" IS 'Version number replicated';
COMMENT ON COLUMN sa.table_entry2clone.reverse_ind IS 'Indicates whether replication had to be reversed; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_entry2clone.birth_lowid IS 'Internal record number of the birth object';
COMMENT ON COLUMN sa.table_entry2clone.focus_lowid IS 'Internal record number of the replicated object';
COMMENT ON COLUMN sa.table_entry2clone.birth_type IS 'Type_id of the birth object';
COMMENT ON COLUMN sa.table_entry2clone.remote_obj IS 'Internal record number of the remote object';
COMMENT ON COLUMN sa.table_entry2clone.remote_srvr IS 'Server ID of the remote server';
COMMENT ON COLUMN sa.table_entry2clone.remote_sobj IS 'Internal record number of the remote server';
COMMENT ON COLUMN sa.table_entry2clone.entry_objid IS 'Internal record number of the triggering event';
COMMENT ON COLUMN sa.table_entry2clone.dist_objid IS 'Internal record number of the triggering event';
COMMENT ON COLUMN sa.table_entry2clone.start_time IS 'Time replication started';
COMMENT ON COLUMN sa.table_entry2clone.end_time IS 'Time replication started';
COMMENT ON COLUMN sa.table_entry2clone.entry_time IS 'Time task received';
COMMENT ON COLUMN sa.table_entry2clone.remote_ver IS 'Remote version';
COMMENT ON COLUMN sa.table_entry2clone.status IS 'Link status';
COMMENT ON COLUMN sa.table_entry2clone.error_ind IS 'Error indicator';
COMMENT ON COLUMN sa.table_entry2clone.rec_level IS 'Order of replication on recovery, higher level before lower level';
COMMENT ON COLUMN sa.table_entry2clone.birth_srvr IS 'Server ID of the birth server';