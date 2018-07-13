CREATE OR REPLACE PROCEDURE sa."REGISTER_BRM_ACCT" ( p_BRM_EMS_objid in number,
                                               p_BRM_BAN IN VARCHAR2 ,
                                               p_BRM_Groupid IN VARCHAR2,
                                               p_esn   in varchar2,
                                               p_status  in VARCHAR2 )
AS
--------------------------------------------------------------------------------------------
--$RCSfile: register_brm_acct.sql,v $
--$Revision: 1.3 $
--$Author: aganesan $
--$Date: 2016/05/04 19:30:48 $
-- Asim version 1.1
--$ $Log: register_brm_acct.sql,v $
--$ Revision 1.3  2016/05/04 19:30:48  aganesan
--$ CR41846
--$
--$ Revision 1.2  2016/05/02 19:17:11  aganesan
--$ CR41846
--$
--$ Revision 1.1  2016/05/02 17:49:48  aganesan
--$ CR41846
--$
--------------------------------------------------------------------------------------------
    event2send q_payload_t;
    v_msg varchar2(300);
    v_where varchar2(100);
Begin

  if p_BRM_BAN is not null and p_BRM_Groupid is not null then
       update x_subscriber_enrollments
       set bill_acct_num = p_BRM_BAN,
           BILL_GRP_NUM = p_BRM_Groupid,
           updated_by = 'BRM'
       where objid = p_BRM_EMS_objid;
   end if;


   update x_enroll_event_log
   set event_send_status = p_status
   where x_esn = p_esn
   and EVENT_SEND_STATUS = 'I';

   --if p_status = 'C' then
       update x_enroll_event_log
       set event_send_status = 'I'
       where (x_esn,event_generate_date)
          in ( select x_esn, min(event_generate_date)
               from x_enroll_event_log
               where x_esn = p_esn
               and event_send_status = 'P'
               group by x_esn)
       returning event into event2send;

       if sql%rowcount > 0 then
          IF not (sa.queue_pkg.enq(i_q_name => 'SA.CLFY_MAIN_Q',
                       io_q_payload =>  event2send,
                       o_op_msg     => v_msg)) THEN
             v_where := 'Writing queue: CLFY_MAIN_Q';
          END IF;
       end if;
   --end if;



Exception
when others then
 util_pkg.insert_error_tab( v_where,
                            p_ESN,
                            'Register_brm_acct',
                            nvl(v_msg,substr(sqlerrm, 1, 280)) );


End;
/