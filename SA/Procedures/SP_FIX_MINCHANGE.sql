CREATE OR REPLACE PROCEDURE sa."SP_FIX_MINCHANGE" ( p_low_date date,
                             p_hi_date  date)
IS

   /************************************************************************************************|
   |    Copyright   Tracfone  Wireless Inc. All rights reserved                          	         |
   |                                                                                                |
   | NAME     :       sp_fix_minchange procedure                                                    |
   | PURPOSE  :                                                                                     |
   | FREQUENCY:       every two hours                                                               |
   | PLATFORM :                                                                                     |
   |                                                                                                |
   | REVISIONS:                                                                                     |
   | VERSION  DATE        WHO              PURPOSE                                                  |
   | -------  ---------- -----             ------------------------------------------------------	  |
   | 1.0      06/30/05   SL                Initial revision  (CR4251)                               |
   | 1.1      10/17/05   NLalovic          Cingular Next Available project changes:                 |
   |                                       Removed the condition to not execute                     |
   |                                       IGATE.SP_CREATE_ACTION_ITEM stored procedure if the      |
   |                                       carrier is not CINGULAR.                                 |
   | 1.2      12/23/05   NLalovic          Modified proc to use Deactivation instead of Suspense as |
   |                                       the value of p_order_type parameter in the following     |
   |                                       procedure calls: IGATE.SP_CREATE_ACTION_ITEM and         |
   |                                       IGATE.SP_DETERMINE_TRANS_METHOD                          |
   |************************************************************************************************/

   cursor c_main is
   select *
   from table_x_call_trans a
   where 1=1
   and x_action_type||''='2'
   and x_reason ='MINCHANGE'
   and x_transact_date between p_low_date and p_hi_date;
   -- and x_transact_date between sysdate-1 -4/24 and sysdate-1 -2/24

   cursor c_min (v_min varchar2) is
     select * from table_part_inst
     where part_serial_no = v_min
     and x_domain||'' = 'LINES';
   c_min_rec c_min%rowtype;

   cursor c_esn (v_esn varchar2) is
     select * from table_part_inst
     where part_serial_no = v_esn
     and x_domain||'' = 'PHONES';
   c_esn_rec c_esn%rowtype;

   cursor c_carrier ( v_carr_objid number) is
     select c.*, cp.x_parent_name
     from  table_x_parent cp,
           table_x_carrier_group cg,
           table_x_carrier c
     where 1=1
     and cp.x_status||'' = 'ACTIVE'
     and cg.x_carrier_group2x_parent = cp.objid
     and cg.x_status||'' ='ACTIVE'
     and c.carrier2carrier_group = cg.objid
     and c.objid = v_carr_objid;

   c_carrier_rec c_carrier%rowtype;

   v_status varchar2(30);
   v_actionitem_obj number;
   v_queue number;
   v_no_react number;                -- no reactivation after MINCHANGE
   v_react number;                   -- reactivation with different SIM after MINCHANGE

   l_procedure_name CONSTANT VARCHAR2(100) := 'sp_fix_minchange';
   l_start_date                 DATE                               := SYSDATE;
   l_recs_processed             NUMBER                             := 0;
BEGIN

   IF p_low_date is null or  p_hi_date is null then
      raise_application_error(-20001,'Invalid input date. Date range can not be null');
   ELSE
      IF p_hi_date < p_low_date THEN
         raise_application_error(-20002,'Invalid input date. High date should greater than low date.');
      END IF;
   END IF;

   FOR c_main_rec in c_main LOOP

      BEGIN

         v_status := null;
         v_actionitem_obj := 0;
         v_no_react := 0;
         v_react := 0;

         select count(1)
         into v_no_react
         from table_x_call_trans b
         where 1=1
         and b.x_action_type||'' = '3'
         and b.x_transact_date > c_main_rec.x_transact_date
         and b.x_service_id = c_main_rec.x_service_id
         ;

         select count(1) into  v_react
         from table_x_call_trans b
         where 1=1
         and c_main_rec.x_iccid <> b.x_iccid
         and b.x_action_type||'' = '3'
         and b.x_transact_date > c_main_rec.x_transact_date
         and c_main_rec.x_service_id=b.x_service_id
         ;

         open c_min (c_main_rec.x_min);
         fetch c_min into c_min_rec;
         close c_min;

         open c_esn (c_main_rec.x_service_id);
         fetch c_esn into c_esn_rec;
         close c_esn;

         IF c_min_rec.objid is null or c_esn_rec.objid is null THEN
           goto loop_end;
         END IF;

         IF ( ( v_no_react =0 or v_react > 0 ) and  c_min_rec.x_part_inst_status = '17' ) THEN

             dbms_output.put_line('call trans objid: '||c_main_rec.objid);
             open c_carrier (c_min_rec.part_inst2carrier_mkt);
             fetch c_carrier into c_carrier_rec;
             close c_carrier;

             IGATE.SP_CREATE_ACTION_ITEM(P_CONTACT_OBJID=>c_esn_rec.x_part_inst2contact,
                                    P_CALL_TRANS_OBJID=> c_main_rec.objid,
                                    P_ORDER_TYPE=>'Deactivation',
                                    P_BYPASS_ORDER_TYPE=>'',
                                    P_CASE_CODE=>0,
                                    P_STATUS_CODE=>v_status,
                                    P_ACTION_ITEM_OBJID=>v_actionitem_obj);

             IF v_actionitem_obj > 0 THEN
                IGATE.SP_DETERMINE_TRANS_METHOD(P_ACTION_ITEM_OBJID=>v_actionitem_obj,
                                          P_ORDER_TYPE=>'Deactivation',
                                          P_TRANS_METHOD=>null,
                                          P_DESTINATION_QUEUE=>v_queue);



                insert into x_fixed_minchange (
                min,
                esn,
                actionitem_objid,
                fix_date) values (
                c_main_rec.x_min,
                c_main_rec.x_service_id,
                v_actionitem_obj,
                sysdate
                );
	  l_recs_processed := l_recs_processed + 1;
             END IF;

         END IF;

         COMMIT;


         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               toss_util_pkg.insert_error_tab_proc ( ip_action       => 'Fix MINCHANGE'
                                                    ,ip_key          => c_main_rec.x_service_id
                                                    ,ip_program_name => 'SP_FIX_MINCHANGE'
                                                    ,ip_error_text   => SQLERRM);

      END;

      <<loop_end>>

      NULL;

   END LOOP;

   IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                               l_start_date,
                                               SYSDATE,
                                               l_recs_processed,
                                               'SUCCESS',
                                               l_procedure_name
                                              )
   THEN
      	COMMIT;
   END IF;
END;
/