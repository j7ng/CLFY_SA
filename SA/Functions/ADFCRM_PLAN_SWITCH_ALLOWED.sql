CREATE OR REPLACE FUNCTION sa."ADFCRM_PLAN_SWITCH_ALLOWED" (ip_esn in varchar2,
                                        ip_sp_objid in varchar2)
return varchar2 is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_PLAN_SWITCH_ALLOWED.sql,v $
--$Revision: 1.1 $
--$Author: mmunoz $
--$Date: 2014/05/29 16:35:42 $
--$ $Log: ADFCRM_PLAN_SWITCH_ALLOWED.sql,v $
--$ Revision 1.1  2014/05/29 16:35:42  mmunoz
--$ TAS_2014_03B
--$
--------------------------------------------------------------------------------------------
---------------------------------------------
-- PAYGO Plans not allowed if cards in queue.
---------------------------------------------

cards_in_queue number;

begin

  if ip_esn is null or ip_sp_objid is null then
     return 'false';
  end if;

  if nvl(sa.get_serv_plan_value(ip_sp_objid,'SERVICE_PLAN_GROUP'),'PAY_GO') = 'PAY_GO' then
     select count('1')
     into cards_in_queue
     from table_part_inst
     where Part_To_Esn2part_Inst in (select objid from table_part_inst where part_serial_no = ip_esn and x_domain = 'PHONES')
     and x_domain = 'REDEMPTION CARDS'
     and x_part_inst_status = '400';

     if cards_in_queue > 0 then
         return 'false';
     else
         return 'true';
     end if;
  else
     return 'true';
  end if;


end ADFCRM_PLAN_SWITCH_ALLOWED;
/