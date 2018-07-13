CREATE OR REPLACE FORCE VIEW sa.table_site_sup_prog (objid,title,response_time,units_used,units_avail,unit_measure,description,s_description,prog_name,s_prog_name,quantity,start_date,end_date,resp,ent_objid,units_purch) AS
select table_contr_itm.objid, table_biz_cal.title,
 table_entitlement.response_time, table_contr_itm.units_used,
 table_contr_itm.units_avail, table_part_num.unit_measure,
 table_part_num.description, table_part_num.S_description, table_part_num.part_number, table_part_num.S_part_number,
 table_contr_itm.quantity, table_contr_itm.start_date,
 table_contr_itm.end_date, table_entitlement.name,
 table_entitlement.objid, table_contr_itm.units_purch
 from table_contr_itm, table_biz_cal, table_entitlement,
  table_part_num, table_mod_level, table_biz_cal_hdr
 where table_mod_level.objid = table_contr_itm.contr_itm2mod_level
 AND table_biz_cal_hdr.objid = table_biz_cal.biz_cal2biz_cal_hdr
 AND table_biz_cal_hdr.objid = table_entitlement.cover_hrs2biz_cal_hdr
 AND table_mod_level.objid = table_entitlement.service2mod_level
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;