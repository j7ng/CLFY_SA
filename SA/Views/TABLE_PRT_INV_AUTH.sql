CREATE OR REPLACE FORCE VIEW sa.table_prt_inv_auth (objid,mod_objid,part_objid,inv_bin_objid,mod_level,s_mod_level,part_rol,part_good_qoh,part_bad_qoh,opn_ord_qty,part_roq,repl_queue) AS
select table_part_auth.objid, table_mod_level.objid,
 table_mod_level.part_info2part_num, table_part_auth.part_auth2inv_bin,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_part_auth.part_rol,
 table_part_auth.part_good_qoh, table_part_auth.part_bad_qoh,
 table_part_auth.opn_ord_qty, table_part_auth.part_roq,
 table_part_auth.repl_queue
 from table_part_auth, table_mod_level
 where table_part_auth.part_auth2inv_bin IS NOT NULL
 AND table_mod_level.objid = table_part_auth.n_auth_parts2part_mod
 AND table_mod_level.part_info2part_num IS NOT NULL
 ;
COMMENT ON TABLE sa.table_prt_inv_auth IS 'Selects part authorization details';
COMMENT ON COLUMN sa.table_prt_inv_auth.objid IS 'Displays part_auth object ID number';
COMMENT ON COLUMN sa.table_prt_inv_auth.mod_objid IS 'Displays mod_level object ID number';
COMMENT ON COLUMN sa.table_prt_inv_auth.part_objid IS 'Displays part_num object ID number';
COMMENT ON COLUMN sa.table_prt_inv_auth.inv_bin_objid IS 'Displays inv_bin object ID number';
COMMENT ON COLUMN sa.table_prt_inv_auth.mod_level IS 'Displays mod_level name';
COMMENT ON COLUMN sa.table_prt_inv_auth.part_rol IS 'Displays reorder level';
COMMENT ON COLUMN sa.table_prt_inv_auth.part_good_qoh IS 'Displays good quantity on hand';
COMMENT ON COLUMN sa.table_prt_inv_auth.part_bad_qoh IS 'Displays bad quantity on hand';
COMMENT ON COLUMN sa.table_prt_inv_auth.opn_ord_qty IS 'Displays quantity ordered on last replenishment parts request';
COMMENT ON COLUMN sa.table_prt_inv_auth.part_roq IS 'The quantity of parts ordered when a replenishment order is generated';
COMMENT ON COLUMN sa.table_prt_inv_auth.repl_queue IS 'Title of the queue to which demands generated via auto-replenishment will be dispatched';