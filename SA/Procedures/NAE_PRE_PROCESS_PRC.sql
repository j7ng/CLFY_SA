CREATE OR REPLACE PROCEDURE sa."NAE_PRE_PROCESS_PRC"
(ip_esn IN VARCHAR2,
is_non_advanced_exchange out boolean,
Proc_result OUT VARCHAR2,
Proc_Error_Num  OUT NUMBER,
Proc_Error_Text OUT varchar2)
IS
/*
CR21968: Check for Non Advanced Exchange (NAE) cases in CLFY
    If Not NAE - Reset the ESN
    ElseIf: NAE: If there is active Line, Reserve it, keep cases open, for Activation Info
            and to allow for phone to ship,
        If Multiple WEX Cases,OR case closed OR case older than 1 month, OR part request already Shipped
                then Create Warranty Services Report
        ElseIf NAE but no Case then: create 'Phone Received' case to save activation info
        end if.
    ElseIf no Case AND No Active line THEN
    Reset the ESN.
    end if.
*/
------------------------------- DECLARATION --------------------------------

v_sqlerrm varchar2(300);
airbill_count number := 0;
line_objid    varchar2(30);--MIN objid
line_min      varchar2 (20) := 0; --min, line attached to esn
line_count    number :=0;
sa_user TABLE_USER.objid%type;
v_id_number table_case.id_number%type;
email_text clob;
email_result varchar2(100);
---- Update Case Variables -----------------
strhistory           VARCHAR2(100);
p_error_no          number :=0;
p_error_str         VARCHAR2 (20) := 'SUCESS';
-- Warranty Services Exception Report-----------------
  type excp_record_ty is record( esn varchar2(30),
                               exception_text varchar2(100));
  type excp_tab_ty is TABLE of excp_record_ty index by binary_integer;
  l_excp_tab excp_tab_ty;
  l_tab_ctr number := 0;
-- Procedures and Functions ------------------
procedure add_case_detail(ip_case_objid in number, ip_line_objid in number)
is
begin
   insert into table_x_case_detail(objid,x_name,x_value,detail2case)
    values (seq('x_case_detail'),'LINE_OBJID',line_objid,ip_case_objid);
end;
procedure insert_temp( ip_esn varchar2, ip_exception varchar2) is
pragma autonomous_transaction;
begin
    insert into temp_nae_excp_table (esn,exception_text)
                  values ( ip_esn,ip_exception);
                  commit;

end;
function create_phone_recieve_case(ip_user_objid in number,
                                    ip_esn in varchar2,
                                    ip_contact_objid in number,
                                    ip_first_name in varchar2,
                                    ip_last_name in varchar2,
                                    ip_email in varchar2,
                                   ip_address1 in varchar2,
                                    ip_address2 in varchar2,
                                    ip_city     in varchar2,
                                    ip_state in varchar2,
                                    ip_zipcode   in varchar2,
                                    line_min in varchar2 ,
                                    op_case_objid out number
                                    ) return boolean is
    OP_ID_NUMBER table_case.id_number%type;
    OP_ERROR_NO number;
    OP_ERROR_STR varchar2(100);
begin
     sa.CLARIFY_CASE_PKG.CREATE_CASE(
        P_TITLE => 'Reserve Returned Phone Line',
        P_CASE_TYPE => 'Line Management',
        P_STATUS => 'Closed',
        P_PRIORITY => NULL,
        P_ISSUE => NULL,
        P_SOURCE => NULL,
        P_POINT_CONTACT => NULL,
        P_CREATION_TIME => sysdate,
        P_TASK_OBJID => NULL,
        P_CONTACT_OBJID => ip_contact_objid,
        P_USER_OBJID => ip_user_objid,
        P_ESN => ip_esn,
        P_PHONE_NUM => line_min,--min of esn
        P_FIRST_NAME => ip_first_name,
        P_LAST_NAME => ip_last_name,
        P_E_MAIL => ip_email,
        P_DELIVERY_TYPE => null,
        P_ADDRESS => substr(trim(ip_address1)||' '||trim(ip_address2),1,200),
        P_CITY => ip_city,
        P_STATE => substr(ip_state,1,30),
        P_ZIPCODE => ip_zipcode,
        P_REPL_UNITS => null,
        P_FRAUD_OBJID => null,
        P_CASE_DETAIL => 'NAE CASE',
        P_PART_REQUEST => null,
        P_ID_NUMBER => OP_ID_NUMBER,
        P_CASE_OBJID => OP_CASE_OBJID,
        P_ERROR_NO => OP_ERROR_NO,
        P_ERROR_STR => OP_ERROR_STR
    );
     if OP_ERROR_NO <> 0     then
       return false;
     else
        return true;
     end if;
end;

function handle_cases(ip_user_objid in number,
                       ip_esn in varchar2,
                       line_objid in number,
                       line_min in varchar2,
                       excp_tab in out excp_tab_ty,
                       tab_ctr in out number)
return boolean is
  more_than_mo_cnt number;
  less_than_mo_cnt number;
  total_cases number;
  case_shipped number;
  op_case_objid number;
  case_not_created exception;
  v_contact_row table_contact%rowtype;
  v_case_id table_case.id_number%type;
  v_replacement_esn  table_part_inst.part_serial_no%type;
  v_age constant number := 30; -- variable for case age check, 30 days

------ find the number of open or pending cases, and case age ------------
begin
    select  sum(decode(substr(creation_time - (sysdate - v_age),1,1),'-',1,0)),
            sum(decode(substr(creation_time - (sysdate - v_age),1,1),'-',0,1)),
            count(*)
    into more_than_mo_cnt, less_than_mo_cnt, total_cases
    from table_case tc, table_condition con
    where con.objid = tc.case_state2condition
    and tc.s_title NOT IN ('SIM CARD EXCHANGE','SIM EXCHANGE')
    AND tc.x_case_type IN ('Technology Exchange','Warranty','Warehouse','GOODWILL','Port In','Handset Program','Retailer')
    AND SUBSTR(con.s_title,1,4) IN ('OPEN', 'PEND')
    AND tc.x_esn = ip_esn;
    -- Look for the right senario: only one open case which is less than a month old AND the replacement is NOT shipped
    if total_cases = 1 and less_than_mo_cnt = 1 then
                  -- check if the replacement phone is shipped -----------------
                    select sum(decode(x_status,'SHIPPED',1,0))
                    into  case_shipped
                    from table_case tc, table_x_part_request PR
                    where tc.objid  = PR.REQUEST2CASE
                    and tc.x_esn = ip_esn
                    and tc.creation_time > trunc(sysdate) - v_age
                    and x_status  not like '%CANCEL%'
                    and x_part_num_domain = 'PHONES';
                    if case_shipped = 0  then
                    -- If not shipped: 1. Attach line to the replacement phone if it exists,
                    --                 2. Update the Case,
                    --                 3. update Part Request to 'PENDING'. --------------------
                              select id_number, pr.x_part_serial_no
                              into v_case_id,v_replacement_esn
                              from table_case tc, table_x_part_request PR
                              where tc.objid  = PR.REQUEST2CASE
                              and tc.x_esn = ip_esn
                              and x_part_num_domain = 'PHONES'
                              and x_status not like '%CANCEL%'
                              and rownum < 2;

                              update table_part_inst
                              set part_to_esn2part_inst =
                                     (select objid
                                      from table_part_Inst
                                      where part_serial_no = v_replacement_esn)
                              where objid = line_objid;
                      --2. Also update the case status to ESN Received:
                      -- This will trigger a Part Request status update from Onhold to Pending. trigger :  table_case_a_iu  ----------------
                              strhistory := 'Old ESN received - Ready to ship replacement';
                              CLARIFY_CASE_PKG.UPDATE_STATUS (v_id_number,sa_user,'ESN Received',strhistory, p_error_no, p_error_str);
                              if p_error_no <> 0 then
                                   insert_temp(ip_esn, 'Case Update to ESN Received Failed');
                              end if;  -- case_shipped = 0
              --if replacement shipped then insert a row into the Warranty Services exception report
                    elsif case_shipped > 0 then
                              insert_temp(ip_esn, 'Replacement already shipped');
                    end if;
-- if case is older than a month then insert a row into Warranty Services exception report
    elsif total_cases = 1 and more_than_mo_cnt > 0 then
           insert_temp(ip_esn, 'Case older than a month');
-- if Multiple open cases then insert a row into Warranty Services exception report
    elsif total_cases > 1 then
           insert_temp(ip_esn, 'Multiple open cases found');

-- if no case found then Create 'Phone Received' case -------------
    elsif total_cases =  0 then
      begin
          select c.*
          into v_contact_row
          from table_part_inst pi, table_contact c
          where pi.x_part_inst2contact = c.objid
          and pi.part_serial_no = ip_esn;
          if not create_phone_recieve_case(ip_user_objid,
                                    ip_esn,
                                    v_contact_row.objid,
                                    v_contact_row.first_name,
                                    v_contact_row.last_name,
                                   v_contact_row.e_mail,
                                    v_contact_row.address_1,
                                    v_contact_row.address_2,
                                    v_contact_row.city,
                                    v_contact_row.state,
                                    v_contact_row.zipcode,
                                    v_contact_row.phone,
                                     op_case_objid) then
               raise  case_not_created;
          else
            add_case_detail(op_case_objid, line_objid);
          end if;
      exception
        when no_data_found then
-- if contact not found then insert a row into Warranty Services exception report
           insert_temp(ip_esn, 'Did not find the contact');
        when others then
-- if could not create a case then insert a row into Warranty Services exception report
           insert_temp(ip_esn, 'Could not create case');
      end;
    end if;
    return true;

exception
   when others then
     return false;
end;

--oooooooooooooooooooooooooooooooooooooooooooo MAIN Procedure oooooooooooooooooooooooooooooooo

BEGIN  -- Start of Main NAE_Pre_Process_Prc

is_non_advanced_exchange := true;
-- Check if AirBill exist indicating a NAE case if NOT exit -------
    SELECT count (*)
    into airbill_count
    FROM sa.table_x_class_exch_options, sa.table_part_num pn, TABLE_MOD_LEVEL ml, TABLE_PART_INST pi
    WHERE part_num2part_class = source2part_class
    AND ML.PART_INFO2PART_NUM  = pn.objid
    and pi.n_part_inst2part_mod = ML.OBJID
    and pi.part_serial_no = ip_esn
    AND x_airbil_part_number IS NOT NULL;

                if airbill_count < 1 then
                -- EXIT POINT: No airbill found then not an NAE case. Return to reset_esn
                 Proc_result := 'SUCCESS';
                 is_non_advanced_exchange := false;
                 Proc_Error_Num :=  0;
                 Proc_Error_Text:= 'No airbill found then not an NAE case';
       return;
    end if;
-- airbill found for NAE -----------------------------
    begin
    -- get the line info from the ESN ----------------------
        SELECT OBJID, part_serial_no, count(*)
        into line_objid, line_min, line_count
        FROM table_part_inst
        WHERE part_to_esn2part_inst IN
               (SELECT objid
                FROM table_part_inst
                WHERE part_serial_no = ip_esn
                AND x_domain = 'PHONES')
        AND x_domain = 'LINES'
        AND x_part_inst_status = '13'
        group by OBJID, part_serial_no;
     ------- if no line then rest the ESN. Exit point
        if line_count <1 then
          Proc_result := 'SUCCESS';
          is_non_advanced_exchange := true;
          Proc_Error_Num := 0;
          Proc_Error_Text:= 'No Line found. OK to reset ESN';
          return;
        end if;
     -- Reserve the Line --------------------------------------------
        update table_part_inst
        set x_part_inst_status = '39',
            status2x_code_table = (select objid from table_x_code_table
                                   where x_code_type = 'LS'
                                   and x_code_number = '39')
        where objid = line_objid;
-- Get the sa user objid for 'Phone Received' case create or update---------
    select OBJID
    into sa_user
    from TABLE_USER
    where S_LOGIN_NAME = 'SA'
    and rownum < 2;
-- Proceed to handle case scenarios -----------------
     if not (handle_cases(sa_user,ip_esn,line_objid,line_min,l_excp_tab, l_tab_ctr))
      then
       dbms_output.put_line('Handle case failed');
       Proc_result := 'FAILED';
       is_non_advanced_exchange := false;
       Proc_Error_Num := 0;
       Proc_Error_Text:= 'Handle case failed';
    end if;

exception
     when no_data_found then
          return;
     when others then
          line_objid := null;
    end;
--End of Main NAE_Pre_Process_Prc
end;
/