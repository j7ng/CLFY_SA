CREATE OR REPLACE FORCE VIEW sa.table_exch_site_v (objid,site_objid,site_id,site_name,s_site_name,dis_role_name,exch_indicator,exch_state,dist_role,ref_id,s_ref_id,current_state,xref_last,xref_first,xref_phone,xref_email) AS
select table_exchange.objid, table_site.objid,
 table_site.site_id, table_site.name, table_site.S_name,
 table_site.depot, table_site.contr_login,
 table_site.contr_passwd, table_exchange.dist_role,
 table_exchange.ref_id, table_exchange.S_ref_id, table_exchange.current_state,
 table_exchange.xref_last, table_exchange.xref_first,
 table_exchange.xref_phone, table_exchange.xref_email
 from table_exchange, table_site
 where table_site.objid = table_exchange.partner2site
 ;
COMMENT ON TABLE sa.table_exch_site_v IS 'Used by form e.link Partner Selection (8890)';
COMMENT ON COLUMN sa.table_exch_site_v.objid IS 'Internal reference number of the exchange object';
COMMENT ON COLUMN sa.table_exch_site_v.site_objid IS 'Internal reference number of the site object';
COMMENT ON COLUMN sa.table_exch_site_v.site_id IS 'Selected partner site id';
COMMENT ON COLUMN sa.table_exch_site_v.site_name IS 'Selected partner site name';
COMMENT ON COLUMN sa.table_exch_site_v.dis_role_name IS 'Used for display only--of exchange.role_id in encoded form';
COMMENT ON COLUMN sa.table_exch_site_v.exch_indicator IS 'Used for display only--of whether there is exchange object for this site';
COMMENT ON COLUMN sa.table_exch_site_v.exch_state IS 'Used for display only-of current exchange state';
COMMENT ON COLUMN sa.table_exch_site_v.dist_role IS 'Indicates role in the distribution of the object.i.e.,0=initiator 1=recipient';
COMMENT ON COLUMN sa.table_exch_site_v.ref_id IS 'Partner s reference number for the exchange object';
COMMENT ON COLUMN sa.table_exch_site_v.current_state IS 'current state of the distributed object in the state machine';
COMMENT ON COLUMN sa.table_exch_site_v.xref_last IS 'Last name of the current user of the exchange case in the partners system';
COMMENT ON COLUMN sa.table_exch_site_v.xref_first IS 'First name of the currentuse on the exchange case in the partner s system';
COMMENT ON COLUMN sa.table_exch_site_v.xref_phone IS 'Phone of the current user working on the exchange in the partner s system';
COMMENT ON COLUMN sa.table_exch_site_v.xref_email IS 'Email address of the current user working on the exchange in the partner s system';