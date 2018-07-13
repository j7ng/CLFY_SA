CREATE OR REPLACE FORCE VIEW sa.table_v_rscrqtscr (objid,r_rqst_objid,rsrc_objid,rsrc_focus_type,rsrc_focus_lowid) AS
select table_rsc_rqt_scr.objid, table_rsc_rqt_scr.rsc_rqt_scr2r_rqst,
 table_rsrc.objid, table_rsrc.focus_type,
 table_rsrc.focus_lowid
 from table_rsc_rqt_scr, table_rsrc
 where table_rsc_rqt_scr.rsc_rqt_scr2r_rqst IS NOT NULL
 AND table_rsrc.objid = table_rsc_rqt_scr.rsc_rqt_scr2rsrc
 ;
COMMENT ON TABLE sa.table_v_rscrqtscr IS 'Used by skills based routing server';
COMMENT ON COLUMN sa.table_v_rscrqtscr.objid IS 'rsc_rqt_scr internal record number';
COMMENT ON COLUMN sa.table_v_rscrqtscr.r_rqst_objid IS 'r_rqst internal record number';
COMMENT ON COLUMN sa.table_v_rscrqtscr.rsrc_objid IS 'rsrc internal record number';
COMMENT ON COLUMN sa.table_v_rscrqtscr.rsrc_focus_type IS 'Type ID of the resource; i.e., 4=queue, 20=user';
COMMENT ON COLUMN sa.table_v_rscrqtscr.rsrc_focus_lowid IS 'Internal record number of the resource';