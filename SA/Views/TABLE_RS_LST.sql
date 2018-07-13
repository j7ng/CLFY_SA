CREATE OR REPLACE FORCE VIEW sa.table_rs_lst (objid,con_objid,rsrc_objid,usr_objid,first_name,s_first_name,last_name,s_last_name,request_state,login_name,s_login_name,source_type,"TYPE",dest_type) AS
select table_r_rqst.objid, table_contact.objid,
 table_rsrc.objid, table_user.objid,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_r_rqst.request_state, table_user.login_name, table_user.S_login_name,
 table_r_rqst.source_type, table_r_rqst.type,
 table_r_rqst.dest_type
 from table_r_rqst, table_contact, table_rsrc,
  table_user
 where table_contact.objid = table_r_rqst.r_contact2contact
 AND table_rsrc.objid = table_r_rqst.r_rqst2rsrc
 AND table_user.objid = table_rsrc.focus_lowid 
 AND table_rsrc.focus_type = 20
 ;
COMMENT ON TABLE sa.table_rs_lst IS 'Used for <form ID and names>';
COMMENT ON COLUMN sa.table_rs_lst.objid IS 'Routing request internal record number';
COMMENT ON COLUMN sa.table_rs_lst.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_rs_lst.rsrc_objid IS 'Resource internal record number';
COMMENT ON COLUMN sa.table_rs_lst.usr_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_rs_lst.first_name IS 'Contact s first name';
COMMENT ON COLUMN sa.table_rs_lst.last_name IS 'Contact s last name';
COMMENT ON COLUMN sa.table_rs_lst.request_state IS 'State of the routing request; 0=new, 1=routed, 2=cancelled, 3=pending, 4=assigned, default=0';
COMMENT ON COLUMN sa.table_rs_lst.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_rs_lst.source_type IS 'Type ID of the object represented by the routing request; i.e., 0=case, 86=contract, 5200=dialog';
COMMENT ON COLUMN sa.table_rs_lst."TYPE" IS ' Cross-locale ID of the medium; i.e. 0=generic, 1=e-mail, 2=phone, 3=fax, 4-9999 (Reserved), Default=0';
COMMENT ON COLUMN sa.table_rs_lst.dest_type IS 'Type ID desired to be routed to; i.e., 4=queue, 20=user, default=4';