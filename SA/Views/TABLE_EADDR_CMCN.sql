CREATE OR REPLACE FORCE VIEW sa.table_eaddr_cmcn (objid,dlg_title,s_dlg_title,cmcn_objid,cmcn_from_address,cmcn_to_list,cmcn_direction,cmcn_delivery_status,cmcn_subject,s_cmcn_subject,edrcomrole_objid,edrcomrole_role_type,eaddr_objid,eaddr_e_num,s_eaddr_e_num) AS
select table_dialogue.objid, table_dialogue.title, table_dialogue.S_title,
 table_communication.objid, table_communication.from_address,
 table_communication.to_list, table_communication.direction,
 table_communication.delivery_status, table_communication.title, table_communication.S_title,
 table_edr_com_role.objid, table_edr_com_role.role_type,
 table_e_addr.objid, table_e_addr.e_num, table_e_addr.S_e_num
 from table_dialogue, table_communication, table_edr_com_role,
  table_e_addr
 where table_dialogue.objid = table_communication.communication2dialogue
 AND table_communication.objid = table_edr_com_role.edr_role2communication
 AND table_e_addr.objid = table_edr_com_role.edr_role2e_addr
 ;
COMMENT ON TABLE sa.table_eaddr_cmcn IS 'Displays all the E_addr for Communications of a Dialogue. Used by form View Email Address List(15510)';
COMMENT ON COLUMN sa.table_eaddr_cmcn.objid IS 'Dialogue internal record number';
COMMENT ON COLUMN sa.table_eaddr_cmcn.dlg_title IS 'Dialogue title or subject';
COMMENT ON COLUMN sa.table_eaddr_cmcn.cmcn_objid IS 'Communication internal record number';
COMMENT ON COLUMN sa.table_eaddr_cmcn.cmcn_from_address IS 'For Email, contains the email address of the sender';
COMMENT ON COLUMN sa.table_eaddr_cmcn.cmcn_to_list IS 'Contains the list of TO addresses';
COMMENT ON COLUMN sa.table_eaddr_cmcn.cmcn_direction IS 'The direction of the communication i.e., 0=unknown, 1=inbound, 2=outbound, 3=both, default=0';
COMMENT ON COLUMN sa.table_eaddr_cmcn.cmcn_delivery_status IS 'The delivery status of the communication; i.e., 0=draft, 1=pending, 2=delivered, default=0';
COMMENT ON COLUMN sa.table_eaddr_cmcn.cmcn_subject IS 'Title or subject of the communication';
COMMENT ON COLUMN sa.table_eaddr_cmcn.edrcomrole_objid IS 'Edr_com_role internal record number';
COMMENT ON COLUMN sa.table_eaddr_cmcn.edrcomrole_role_type IS 'Customer-defined type of electronic address';
COMMENT ON COLUMN sa.table_eaddr_cmcn.eaddr_objid IS 'E_addr internal record number';
COMMENT ON COLUMN sa.table_eaddr_cmcn.eaddr_e_num IS 'Full electronic address number';