CREATE OR REPLACE FORCE VIEW sa.table_gl_sum_view (summary_objid,sum_log_objid,to_name,to_desc,fm_name,fm_desc,credit,debit) AS
select table_gl_summary.objid, table_gl_summary.gl_summary2gl_sum_log,
 table_to_gl.location_name, table_to_gl.location_descr,
 table_fm_gl.location_name, table_fm_gl.location_descr,
 table_gl_summary.credit_amt, table_gl_summary.debit_amt
 from table_inv_locatn table_fm_gl, table_inv_locatn table_to_gl, table_gl_summary
 where table_gl_summary.gl_summary2gl_sum_log IS NOT NULL
 AND table_fm_gl.objid = table_gl_summary.fm_summary2inv_locatn
 AND table_to_gl.objid = table_gl_summary.to_summary2inv_locatn
 ;
COMMENT ON TABLE sa.table_gl_sum_view IS 'Used in server process GL summary calculations';
COMMENT ON COLUMN sa.table_gl_sum_view.summary_objid IS 'GL summary internal record number';
COMMENT ON COLUMN sa.table_gl_sum_view.sum_log_objid IS 'GL summary parent log internal record number';
COMMENT ON COLUMN sa.table_gl_sum_view.to_name IS 'Name of the transfer TO GL account';
COMMENT ON COLUMN sa.table_gl_sum_view.to_desc IS 'Description of the transfer TO GL account';
COMMENT ON COLUMN sa.table_gl_sum_view.fm_name IS 'Name of the transfer FROM GL account';
COMMENT ON COLUMN sa.table_gl_sum_view.fm_desc IS 'Description of the transfer FROM GL account';
COMMENT ON COLUMN sa.table_gl_sum_view.credit IS 'Credit amount for this summary record';
COMMENT ON COLUMN sa.table_gl_sum_view.debit IS 'Debit amount for this summary record';