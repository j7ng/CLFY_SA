CREATE OR REPLACE FORCE VIEW sa.table_lit_req_view (objid,lit_req_id,title,s_title,comments,ship_via,create_date,required_date,fulfilled_date,status,s_status,send_type,s_send_type,"OWNER",s_owner,owner_objid) AS
select table_lit_req.objid, table_lit_req.lit_req_id,
 table_lit_req.title, table_lit_req.S_title, table_lit_req.comments,
 table_lit_req.ship_via, table_lit_req.create_date,
 table_lit_req.required_date, table_lit_req.fulfilled_date,
 table_gse_status.title, table_gse_status.S_title, table_gse_sendtype.title, table_gse_sendtype.S_title,
 table_user.login_name, table_user.S_login_name, table_user.objid
 from table_gbst_elm table_gse_sendtype, table_gbst_elm table_gse_status, table_lit_req, table_user
 where table_gse_status.objid = table_lit_req.lit_status2gbst_elm
 AND table_gse_sendtype.objid = table_lit_req.lit_send2gbst_elm
 AND table_user.objid = table_lit_req.lit_owner2user
 ;
COMMENT ON TABLE sa.table_lit_req_view IS 'Literature request details. Used by form My Clarify (12000), Opportunity (13000), Account (11650), Lead (11610) and Generic Query (20000)';
COMMENT ON COLUMN sa.table_lit_req_view.objid IS 'Lit_req internal record number';
COMMENT ON COLUMN sa.table_lit_req_view.lit_req_id IS 'Unique ID number of the template; assigned acording to auto-numbering definition';
COMMENT ON COLUMN sa.table_lit_req_view.title IS 'Title of the literature request';
COMMENT ON COLUMN sa.table_lit_req_view.comments IS 'Comments about the literature request';
COMMENT ON COLUMN sa.table_lit_req_view.ship_via IS 'Requested means of shipment. This is from a Clarify-defined popup list with default name SHIP_VIA';
COMMENT ON COLUMN sa.table_lit_req_view.create_date IS 'Date the template was created';
COMMENT ON COLUMN sa.table_lit_req_view.required_date IS 'Date that shipment to the addressees is required(lit_ship_req)';
COMMENT ON COLUMN sa.table_lit_req_view.fulfilled_date IS 'Date that shipment to the addressees was completed';
COMMENT ON COLUMN sa.table_lit_req_view.status IS 'The status of the template';
COMMENT ON COLUMN sa.table_lit_req_view.send_type IS 'The sending method for the template';
COMMENT ON COLUMN sa.table_lit_req_view."OWNER" IS 'Login_name of the user owning the template';
COMMENT ON COLUMN sa.table_lit_req_view.owner_objid IS 'User internal record number of the user owning the template';