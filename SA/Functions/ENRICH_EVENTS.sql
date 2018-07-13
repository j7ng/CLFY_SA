CREATE OR REPLACE FUNCTION sa."ENRICH_EVENTS" (ip_q q_payload_t) return q_payload_t is

--------------------------------------------------------------------------------------------
--$RCSfile: enrich_events.sql,v $
--$Revision: 1.6 $
--$Author: aganesan $
--$Date: 2016/02/05 19:59:57 $
--$ $Log: enrich_events.sql,v $
--$ Revision 1.6  2016/02/05 19:59:57  aganesan
--$ Added grants to this function
--$
--$ Revision 1.5  2015/12/28 19:39:11  akhan
--$ adding sa to the queue_pkg
--$
--$ Revision 1.4  2015/12/28 19:36:59  akhan
--$ incorrect checkin corected
--$
--$ Revision 1.3  2015/12/28 19:34:42  akhan
--$ checking  in
--$
--$ Revision 1.1  2015/12/08 19:04:29  akhan
--$ created trransformation function and object
--$
--------------------------------------------------------------------------------------------
  op_q q_payload_t := ip_q;
  v_objid number := 0;
  --v_event varchar2(100);
  v_event_addl_info varchar2(100);
begin

   for i in 1..ip_q.nameval.count
   loop
    if (ip_q.nameval(i).fld = 'CT_OBJID') then
        v_objid := ip_q.nameval(i).val;
    end if;
   end loop;
   if v_objid is null then
         return op_q;
   end if;

   select  IGO.X_ACTUAL_ORDER_TYPE  addl_info
   into  v_event_addl_info
   from table_x_call_trans ct, table_task tt, ig_transaction ig , X_IG_ORDER_TYPE igo
   where tt.x_task2x_call_trans(+) = ct.objid
   and x_programme_name(+)  = 'SP_INSERT_IG_TRANSACTION'
   and x_sql_text is null
   and (tt.objid is null or
        tt.objid in ( select max(objid) from table_task where x_task2x_call_trans = ct.objid))
   and tt.task_id = ig.action_item_id (+)
   and IG.ORDER_TYPE  = IGO.X_IG_ORDER_TYPE (+)
   and ct.objid = v_objid;


   sa.queue_pkg.add_nameval_elmt('EVENT_ADDL_INFO',v_event_addl_info,op_q.nameval);

   return op_q;
exception
  when others then
    return ip_q;
end;
/