CREATE OR REPLACE FORCE VIEW sa.adfcrm_esn_structure_view (part_serial_no,iccid,zipcode,install_date,contact_objid,part_number,part_class,org_id,part_status,upg_sts_eligible,"MIN",service_end_dt,days_left,sp_objid,svc_plan_id,sb_rate,mkt_name) AS
select i.part_serial_no,
       i.x_iccid iccid,
       s.x_zipcode zipcode,
       s.install_date,
       i.x_part_inst2contact contact_objid,
       pn.part_number part_number,
       pc.name part_class,
       b.org_id org_id,
       i.x_part_inst_status part_status,
       decode(i.x_part_inst_status,'50','YES','51','YES','52','YES','54','YES','150','YES','NO') upg_sts_eligible,
       s.x_min min,
       s.service_end_dt,
       trunc(s.x_expire_dt-trunc(sysdate)) days_left,
       s.objid sp_objid,
       p.x_service_plan_id svc_plan_id,
       p.x_switch_base_rate sb_rate,
       sp.mkt_name
from   table_part_inst i,
       table_site_part s,
       x_service_plan_site_part p,
       table_mod_level m,
       table_part_num pn,
       table_part_class pc,
       table_bus_org b,
       x_service_plan sp
where  1=1
and    i.x_domain = 'PHONES'
and    i.x_part_inst2site_part = s.objid(+)
and    s.objid = p.table_site_part_id(+)
and    i.n_part_inst2part_mod = m.objid
and    pn.objid = m.part_info2part_num
and    pn.part_num2bus_org = b.objid
and    pn.part_num2part_class = pc.objid
and    p.x_service_plan_id = sp.objid(+);