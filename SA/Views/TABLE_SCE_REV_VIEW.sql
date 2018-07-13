CREATE OR REPLACE FORCE VIEW sa.table_sce_rev_view (objid,old_cl_sch_rev,old_cl_eff_date,old_cust_sch_rev,old_cust_eff_date,old_db_hist,new_cl_sch_rev,new_cl_eff_date,new_cust_sch_rev,new_cust_eff_date,new_db_hist) AS
select table_sce_revision.objid, table_sce_revision.cl_sch_rev,
 table_sce_revision.cl_eff_date, table_sce_revision.cust_sch_rev,
 table_sce_revision.cust_eff_date, table_sce_revision.db_hist,
 table_sce_revision.cl_sch_rev, table_sce_revision.cl_eff_date,
 table_sce_revision.cust_sch_rev, table_sce_revision.cust_eff_date,
 table_sce_revision.db_hist
 from table_sce_revision;
COMMENT ON TABLE sa.table_sce_rev_view IS 'Dummy View that will hold revision number, for display only. Used by form Upgrade Database (908)';
COMMENT ON COLUMN sa.table_sce_rev_view.objid IS 'Sce_revision internal record number';
COMMENT ON COLUMN sa.table_sce_rev_view.old_cl_sch_rev IS 'Clarify schema s revision number';
COMMENT ON COLUMN sa.table_sce_rev_view.old_cl_eff_date IS 'Clarify schema s effective date';
COMMENT ON COLUMN sa.table_sce_rev_view.old_cust_sch_rev IS 'Customer schema s revision number';
COMMENT ON COLUMN sa.table_sce_rev_view.old_cust_eff_date IS 'Customer schema s effective date';
COMMENT ON COLUMN sa.table_sce_rev_view.old_db_hist IS 'History of database changes';
COMMENT ON COLUMN sa.table_sce_rev_view.new_cl_sch_rev IS 'New Clarify schema s revision number';
COMMENT ON COLUMN sa.table_sce_rev_view.new_cl_eff_date IS 'New Clarify schema s effective date';
COMMENT ON COLUMN sa.table_sce_rev_view.new_cust_sch_rev IS 'New customer schema s revision number';
COMMENT ON COLUMN sa.table_sce_rev_view.new_cust_eff_date IS 'New customer schema s effective date';
COMMENT ON COLUMN sa.table_sce_rev_view.new_db_hist IS 'New history of database changes';