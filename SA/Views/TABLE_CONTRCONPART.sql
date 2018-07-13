CREATE OR REPLACE FORCE VIEW sa.table_contrconpart (objid,con_objid,first_name,s_first_name,last_name,s_last_name,contr_id,s_contr_id,part_num,s_part_num,part_description,s_part_description,quantity,price,create_date,expire_date,issue_date,part_family,part_line) AS
select table_contr_itm.objid, table_contact.objid,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_contract.id, table_contract.S_id, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_contr_itm.quantity,
 table_contr_itm.net_prc, table_contract.create_dt,
 table_contract.expire_date, table_contract.q_issue_dt,
 table_part_num.family, table_part_num.line
 from table_contr_itm, table_contact, table_contract,
  table_part_num, table_mod_level, table_contr_schedule
 where table_contact.objid = table_contract.primary2contact
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_contract.objid = table_contr_schedule.schedule2contract
 AND table_mod_level.objid = table_contr_itm.contr_itm2mod_level
 AND table_contr_schedule.objid = table_contr_itm.contr_itm2contr_schedule
 ;