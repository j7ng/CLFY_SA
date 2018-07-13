CREATE OR REPLACE FUNCTION sa."BALANCE_METERING_FOR_COMP_REPL" (
   p_esn varchar2,
   p_action varchar2,  --COMPENSATION / REPLACEMENT
   p_serv_plan_group varchar2
)
return varchar2 is
cursor get_esn_info is
   select pc.name part_class,
		  bo.org_id
   from table_part_inst pi
       ,sa.table_mod_level ml
       ,sa.table_part_num pn
	   ,sa.table_bus_org bo
       ,sa.table_part_class pc
  where 1 = 1
  and   pi.part_serial_no = p_esn
  and   pi.x_domain = 'PHONES'
  and   ml.objid = pi.n_part_inst2part_mod
  and   pn.objid = ml.part_info2part_num
  and   bo.objid = pn.part_num2bus_org
  and   pc.objid = pn.part_num2part_class
 ;

cursor get_carrier is
		 select caparent.x_queue_name
         from table_part_inst pi
              ,table_x_carrier ca
              ,table_part_inst piline
              ,table_x_carrier_group cagrp
              ,table_x_parent caparent
         where ca.objid = piline.part_inst2carrier_mkt
         and   ca.carrier2carrier_group = cagrp.objid
         and   cagrp.x_carrier_group2x_parent = caparent.objid
         and   piline.objid = (select max(objid)
                               from   table_part_inst maxline
                               where  maxline.part_to_esn2part_inst = pi.objid)
         and   pi.part_serial_no = p_esn
         and   pi.x_domain = 'PHONES'
		 ;

get_carrier_rec get_carrier%rowtype;
get_esn_info_rec get_esn_info%rowtype;
v_bal_metering  varchar2(100);
begin
   open get_esn_info;
   fetch get_esn_info into get_esn_info_rec;
   if get_esn_info%found then
      v_bal_metering := sa.get_param_by_name_fun(get_esn_info_rec.part_class,'BALANCE_METERING');
   end if;
   close get_esn_info;

   open get_carrier;
   fetch get_carrier into get_carrier_rec;
   if get_carrier%found then

      if get_carrier_rec.x_queue_name = 'VERIZON' and
	     get_esn_info_rec.org_id = 'STRAIGHT_TALK' and
	     p_action = 'COMPENSATION' and
	     NOT(p_serv_plan_group  like '%UNLIMITED%' OR p_serv_plan_group  like 'VOICE_ONLY%' OR p_serv_plan_group  like 'DATA_ONLY%')
	  then
	     v_bal_metering := 'SUREPAY';
	  end if;
   end if;
   close get_carrier;
   return v_bal_metering;
end;
/