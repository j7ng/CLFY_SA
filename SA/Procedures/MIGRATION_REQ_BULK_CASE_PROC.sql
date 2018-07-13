CREATE OR REPLACE PROCEDURE sa."MIGRATION_REQ_BULK_CASE_PROC" (ip_source_file varchar2)
is
  v_err_code  varchar2(300);
  v_err_msg   varchar2(3000);

-- NOTE TO RETENTION TEAM
-- OBJECTIVE TO GENERALIZE THE MIGRATION TO ALL TYPES OF MIGRATION.
-- ALL REFERNCES TO 2G MIGRATION CASES OR SIM EXCHANGE CASES WERE REMOVED
-- ALL REFERENCES TO 2G MIGRATION FROM ALERTS REMOVED
-- ALERTS WILL EXPIRE ON SPECFIED DAY OR UNLESS SQL QUERY RETURNS A PART REQUEST WAS SHIPPED
-- DEPLOYMENT PROTOCOL BY MEANS OF TICKET REQUEST IS STILL IN PLACE
-- THE USE OF THE EXCHANGE_TYPE COLUMN TO DETERMINE THE TYPE OF CASE IS NO LONGER APPLICABLE
-- RETENTION WILL NOW SPECIFY CASE TYPE AND TITLE IN THEIR TABLE
-- RETENTION MUST ADD NEW COLUMNS TO THEIR SOURCE TABLE - (CASE_TYPE, CASE_TITLE, ALERT_TITLE)
-- FOR CREATION OF CASES A CASE TYPE+TITLE+PART NUMBER IS REQUIRED OR NO CASE WILL BE CREATED
-- CASES ARE STILL CREATED AS BAD ADDRESS
-- CASES ARE CREATED UNDER TAS
-- CASES ARE CREATED W/USER CBO
-- CASES ARE CREATED WITH NO TRANSFER SERVICE TO PREVENT THE SHIP CONFIRM FROM ACTIVATIVATING THE LINE ON THE NEW DEVICE AND DISCONNECTING IT FROM THE OLD DEVICE
-- ALERTS ARE STILL CAPPED TO 2000 CHARACTERS
-- ALERT TEMP (0=COLD,1=HOT)
-- HOW TO TEST (REQUIRED FIELDS)
-- TO CREATE JUST A CASE (TYPICAL CASE TYPES AND TITLES BELOW) -- CASE SHOULD NOT MATTER
-- insert into migration_2g_cases (source_file,esn,case_type,case_title,part_request_num,alert_title,alert_tas_text,alert_web_text_en,alert_web_text_es,sms_msg,ivr_scpt_id,temp,alert_days) values ('TEST_SF','011555003873254','Technology Exchange','SIM Card Exchange','TFMIGSP',null,null,null,null,null,null,null,null);
-- insert into migration_2g_cases (source_file,esn,case_type,case_title,part_request_num,alert_title,alert_tas_text,alert_web_text_en,alert_web_text_es,sms_msg,ivr_scpt_id,temp,alert_days) values ('TEST_SF','011555003873254','WAREHOUSE','2G Migration','TFMIGSP',null,null,null,null,null,null,null,null);
-- TO CREATE JUST AN ALERT
-- insert into migration_2g_cases (source_file,esn,case_type,case_title,part_request_num,alert_title,alert_tas_text,alert_web_text_en,alert_web_text_es,sms_msg,ivr_scpt_id,temp,alert_days) values ('TEST_SF','011555003873254',null,null,null,'ALERT TITLE','This is what TAS displays','This is web in english','This is web in spanish','SMS Msg','1009',0,360);
-- TO CREATE JUST A CASE AND ALERT
-- insert into migration_2g_cases (source_file,esn,case_type,case_title,part_request_num,alert_title,alert_tas_text,alert_web_text_en,alert_web_text_es,sms_msg,ivr_scpt_id,temp,alert_days) values ('TEST_SF','011555003873254','WAREHOUSE','2G Migration','TFMIGSP','ALERT TITLE','This is what TAS displays','This is web in english','This is web in spanish','SMS Msg','1009',0,360);
-- THIS IS HOW TO VIEW THE ENTRIES RELATED TO YOUR SOURCE FILE
-- SELECT * FROM migration_2g_cases WHERE source_file = 'TEST_SF';
-- HOW TO PROCESS YOUR ENTRIES
-- begin migration_req_bulk_case_proc (ip_source_file => 'TEST_SF'); commit; end;

  procedure alert_ins (ip_esn_objid varchar2, ip_alert_title varchar2, ip_alert_text varchar2, ip_text_en varchar2, ip_text_es varchar2, ip_sms_msg varchar2,ip_ivr_scpt varchar2, ip_temp number, ip_alert_days number)
  is
   v_cancel_sql varchar2(4000) := 'select count(*)
                                   from (select (select start_date
                                                  from table_alert ta,
                                                       table_part_inst pi
                                                  where alert2contract = pi.objid
                                                  and pi.part_serial_no = c.x_esn) alert_start_date,
                                                  c.creation_time case_start_date,
                                                  pr.x_ship_date part_ship_date,
                                                  c.id_number,
                                                  pr.*
                                          from  table_x_part_request pr,
                                                table_case c
                                          where pr.request2case = c.objid
                                          and c.x_esn  = :esn
                                          and pr.x_status in (''SHIPPED'',''PROCESSED'')
                                          and pr.x_tracking_no is not null
                                          and pr.x_part_serial_no is not null)
                                    where 1=1
                                    and :START_DATE is not null
                                    and :END_DATE is not null
                                    and part_ship_date>alert_start_date';

  begin
    merge into sa.table_alert ta
    using (select 1 from dual)
    on (ta.title = ip_alert_title -- NO LONGER REFERENCING '2G Migration Exchange'
    and ta.alert2contract = ip_esn_objid)
    when not matched then
    insert (objid,type,alert_text,start_date,end_date,active,title,hot,last_update2user,alert2contract,modify_stmp,x_web_text_english,x_web_text_spanish,sms_message,x_ivr_script_id,x_step,x_tts_english,x_tts_spanish,x_cancel_sql)
    values (sa.seq('alert'),'SQL',ip_alert_text,sysdate,sysdate+nvl(ip_alert_days,90),1,ip_alert_title /*'2G Migration Exchange'*/,ip_temp,268435556,ip_esn_objid,sysdate,ip_text_en,ip_text_es,ip_sms_msg,ip_ivr_scpt,'0','.','.',v_cancel_sql)
    when matched then
    update set alert_text = ip_alert_text,
               hot = ip_temp,
               x_web_text_english= ip_text_en,
               x_web_text_spanish = ip_text_es,
               sms_message = ip_sms_msg,
               x_ivr_script_id = ip_ivr_scpt,
               x_tts_english = '.',
               x_tts_spanish = '.',
               end_date = sysdate+nvl(ip_alert_days,90)
    ;

  exception
    when others then
      null;
  end alert_ins;

  procedure create_request (p_case_type      in varchar2,
                            p_case_title     in varchar2,
                            p_source_system  in varchar2 DEFAULT 'TAS',
                            p_login_name     in varchar2 DEFAULT 'CBO',
                            p_language       in   varchar2 DEFAULT 'EN',
                            p_esn            in   varchar2,
                            p_min            in   varchar2,
                            p_first_name in varchar2,
                            p_last_name in varchar2,
                            p_address_1 in varchar2,
                            p_address_2 in varchar2,
                            p_city in varchar2,
                            p_state in varchar2,
                            p_zipcode in varchar2,
                            p_email in varchar2,
                            p_contact_phone in varchar2,
                            p_units_to_transfer in varchar2,
                            p_call_trans_objid in varchar2,  -- OBJID OTA Balance Inquiry (THIS IS NOW A DEAD INPUT AS OF 4/6/2016. BECAUSE THE OBJID THE CBO RETURNS IS NOT MEANT FOR A DB LOOK UP. IT'S TO PASS THROUGH TO ANOTHER CBO BALANCE CALL)
                            p_part_number in varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2)
  as
    new_case_id_format    varchar2 (100) := null;

    -- added for verify eligiblity
    op_result varchar2(2000);
    op_purchase_link varchar2(2000);
    op_ticket_id varchar2(2000);
    op_brand varchar2(2000);

    --	added for Get Replacement
    v_case_conf_objid varchar2(30);
    v_case_type       varchar2(30)  := upper(p_case_type); -- NO LONGER REFERENCING 'WAREHOUSE'
    v_title           varchar2(100) := upper(p_case_title); -- NO LONGER REFERENCING '2G Migration'
    v_repl_logic      varchar2(300) := '';
    v_part_number     varchar2(3000) := p_part_number;
    v_sim_suffix      varchar2(3000);
    v_x_part_inst2contact sa.table_part_inst.x_part_inst2contact%type;
    v_op_case_objid   sa.table_case.objid%type;
    -- added for Contact Creation
    v_u_objid sa.table_user.objid%type;
    v_p_repl_units number;
    v_case_detail  sa.table_x_case_detail.x_value%type;
    -- added for Case Dispatch
    v_queue sa.table_queue.title%type;
    v_ticket_id table_case.id_number%type;
    v_id_number varchar2(30);
  begin

    -- THE VALIDATION CHECK IF CASE TYPE AND TITLE EXISTS NATALIO WANTED WAS ALREADY HERE
    select objid,x_case_type,x_title,x_repl_logic
    into   v_case_conf_objid,v_case_type,v_title,v_repl_logic
    from   table_x_case_conf_hdr
    where s_x_case_type = v_case_type
    and s_x_title = v_title;

    -- THIS NOW CHECKS BASED ON CASE TYPE AND TITLE AND NOT THE EXCHANGE TYPE ANYMORE
    select max(id_number)
    into v_id_number
    from table_case c,
         table_condition co
    where 1=1
    and co.objid = c.case_state2condition
    and c.s_title = v_title --'2G Migration'
    and c.x_case_type = v_case_type --'Warehouse'
    and co.s_title like 'OPEN%'
    and c.x_esn = p_esn;

    if v_id_number is null then -- NO CASE EXISTS CREATE THE CASE
        -- Get the User Info
        begin
          select objid
          into  v_u_objid
          from table_user
          where s_login_name = p_login_name;
        exception
          when others then
            null;
        end;

        -- Get the Contact Info
        begin
          select x_part_inst2contact
          into v_x_part_inst2contact
          from table_part_inst
          where part_serial_no = p_esn;
        exception
          when others then
            null; -- create the contact        v_x_part_inst2contact
        end;

        dbms_output.put_line('CONTACT OBJID  ==> '||v_x_part_inst2contact||' <==');

        v_case_detail := 'NO_SERVICE_TRANSFER||NO_SERVICE_TRANSFER'; -- THIS IS TO PREVENT THE SHIP CONFIRM FROM TRYING TO ACTIVATE THE LINE ON THE NEW DEVICE

        dbms_output.put_line('RIGHT BEFORE CREATING THE CASE ESN  ==> '||p_esn||' <==');
        --	Create Case
        sa.clarify_case_pkg.create_case(P_TITLE => v_title,
                                        p_case_type => v_case_type,
                                        p_status => 'Pending',
                                        p_priority => 'High', --Options are Low,Medium,High, or Urgent
                                        p_issue => v_title,
                                        p_source => v_title, -- maps to case_type_lvl3
                                        P_POINT_CONTACT => p_source_system, --customer_code
                                        P_CREATION_TIME => sysdate,
                                        P_TASK_OBJID => null,
                                        p_contact_objid => v_x_part_inst2contact,
                                        P_USER_OBJID => v_u_objid,
                                        P_ESN => p_esn,
                                        P_PHONE_NUM => p_contact_phone,
                                        P_FIRST_NAME => p_first_name,
                                        P_LAST_NAME => p_last_name,
                                        P_E_MAIL => p_email,
                                        P_DELIVERY_TYPE => null,
                                        P_ADDRESS => p_address_1||'||'||p_address_2,
                                        P_CITY => p_city,
                                        p_state => p_state,
                                        p_zipcode => p_zipcode,
                                        P_REPL_UNITS => v_p_repl_units,
                                        p_fraud_objid => null,
                                        p_case_detail => v_case_detail,
                                        p_part_request => v_part_number, --v_part_req,
                                        P_ID_NUMBER => op_ticket_id,
                                        P_CASE_OBJID => v_op_case_objid,
                                        P_ERROR_NO => p_err_code,
                                        P_ERROR_STR => p_err_msg);

        dbms_output.put_line('REPL PART NUMBER   = ' || v_part_number);
        dbms_output.put_line('CASE OBJID         = ' || v_op_case_objid);
        dbms_output.put_line('CASE ID            = ' || op_ticket_id);
        dbms_output.put_line('p_err_code       = ' || p_err_code);
        dbms_output.put_line('OP_ERROR_MSG       = ' || p_err_msg);

        begin
          select table_queue.title
          into   v_queue
          from table_x_case_dispatch_conf
                ,table_x_case_conf_hdr
                ,table_queue
           where dispatch2conf_hdr = table_x_case_conf_hdr.objid
           and table_x_case_dispatch_conf.priority2gbst_elm=-1
           and table_x_case_dispatch_conf.status2gbst_elm=-1
           and table_x_case_conf_hdr.objid = v_case_conf_objid
           and table_queue.objid = table_x_case_dispatch_conf.dispatch2queue;
        exception
        when others then
          dbms_output.put_line('QUEUE IS EMPTY       = ' || v_queue|| ' - '||sqlerrm);
          p_err_code := '-100000';
        end;

        if p_err_code != '-100000' then
          --	Dispatch Case
          sa.clarify_case_pkg.dispatch_case (p_case_objid => v_op_case_objid,
                                             p_user_objid => v_u_objid,
                                             p_queue_name => v_queue,
                                             p_error_no => p_err_code,
                                             p_error_str => p_err_msg);

          dbms_output.put_line('p_err_code       = ' || p_err_code);
          dbms_output.put_line('OP_ERROR_MSG       = ' || p_err_msg);

          --	Return Info.
          p_err_code := '0';
          p_err_msg := 'SUCCESS';
        end if;

        if p_err_code = '0' then
          clarify_case_pkg.update_status (p_case_objid => v_op_case_objid,
                                          p_user_objid => v_u_objid,
                                          p_new_status => 'BadAddress',
                                          p_status_notes => '2G Migration auto status change',
                                          p_error_no => p_err_code,
                                          p_error_str => p_err_msg);

          dbms_output.put_line('P_ERROR_NO = ' || p_err_code);
          dbms_output.put_line('P_ERROR_STR = ' || p_err_msg);
        end if;

    end if;

  exception
    when others then
      p_err_code := '-2';
      p_err_msg := sqlerrm;
  end create_request;

begin

  -- UPDATE ALL ESNS W/ESN OBJID
  update migration_2g_cases m2c
  set m2c.esn_objid = (select objid
                       from table_part_inst
                       where part_serial_no = m2c.esn)
  where source_file = ip_source_file;
  commit;

  -- ADD ALERTS
  -- NEW ADD ALERT TITLE
  -- THE INSERT WILL NOW BE DRIVEN BY ALERT TITLE, NOT TAS TEXT
  for i in (select * from migration_2g_cases where source_file = ip_source_file)
  loop
    if i.alert_title is not null then
      alert_ins (ip_esn_objid => i.esn_objid, ip_alert_title => i.alert_title, ip_alert_text => i.alert_tas_text, ip_text_en => i.alert_web_text_en, ip_text_es => i.alert_web_text_es, ip_sms_msg => i.sms_msg, ip_ivr_scpt => i.ivr_scpt_id, ip_temp => i.temp, ip_alert_days => i.alert_days);
      commit;
    end if;
  end loop;

  -- UPDATE ALL ESNS W/ALERT OBJID
  update migration_2g_cases m2c
  set m2c.alert_objid = (select objid
                         from table_alert
                         where title = m2c.alert_title -- NO LONGER REFERENCING '2G Migration Exchange'
                         and alert2contract = m2c.esn_objid)
  where source_file = ip_source_file;
  commit;

  -- CASE TYPE AND TITLE WILL NOW BE PASSED FROM THE MIGRATION TABLE
  for i in (select * from migration_2g_cases where source_file = ip_source_file)
  loop
    if i.case_type is not null and i.case_title is not null and i.part_request_num is not null then -- EXCHANGE TYPE NO LONGER USED
        create_request (p_case_type         => i.case_type,
                        p_case_title        => i.case_title,
                        p_source_system     => 'TAS',
                        p_login_name        => 'CBO',
                        p_language          => 'EN',
                        p_esn               => i.esn,
                        -- p_exchange_type     => i.exchange_type, -- REMOVE EXHCANGE TYPE NO LONGER NEEDED
                        p_min               => null,
                        p_first_name        => null,
                        p_last_name         => null,
                        p_address_1         => null,
                        p_address_2         => null,
                        p_city              => null,
                        p_state             => null,
                        p_zipcode           => null,
                        p_email             => null,
                        p_contact_phone     => null,
                        p_units_to_transfer => null,
                        p_call_trans_objid  => null,
                        p_part_number       => i.part_request_num,
                        --p_ticket_id         => v_ticket_id, -- NOT DOING ANYTHING W/THIS TICKET ID
                        p_err_code          => v_err_code,
                        p_err_msg           => v_err_msg);
    end if;
  end loop;
  commit;

  update migration_2g_cases m2c
  set m2c.case_id = (select max(c.id_number)
                      from table_case c,
                           table_condition co
                      where 1=1
                      and co.objid = c.case_state2condition
                      and c.title = m2c.case_title --'2G Migration'
                      and c.x_case_type =  m2c.case_type --'Warehouse'
                      and co.s_title like 'OPEN%'
                      and c.x_esn = m2c.esn
                      )
  where source_file = ip_source_file;
  commit;

  for i in (select
                (select count(1)
                 from migration_2g_cases
                 where source_file = ip_source_file) ttl_count,
                (select count(1)
                 from migration_2g_cases
                 where alert_objid is not null
                 and source_file = ip_source_file) alert_count,
                (select count(1)
                 from migration_2g_cases
                 where case_id is not null
                 and source_file = ip_source_file) case_count
            from dual
            )
   loop
     dbms_output .put_line('TOTAL PROCESSED: '||i.ttl_count||' TOTAL ALERTS CREATED: '||i.alert_count||' TOTAL CASES CREATED/FOUND: '||i.case_count);
   end loop;

end migration_req_bulk_case_proc;
/