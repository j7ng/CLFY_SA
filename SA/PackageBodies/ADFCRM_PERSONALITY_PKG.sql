CREATE OR REPLACE PACKAGE BODY sa.ADFCRM_PERSONALITY_PKG
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_PERSONALITY_PKB.sql,v $
--$Revision: 1.21 $
--$Author: nguada $
--$Date: 2017/03/14 12:58:17 $
--$ $Log: ADFCRM_PERSONALITY_PKB.sql,v $
--$ Revision 1.21  2017/03/14 12:58:17  nguada
--$ clear mms logic added
--$
--$ Revision 1.20  2017/02/15 20:48:35  nguada
--$ CR47838 Personality updates for SL phones
--$
--$ Revision 1.19  2015/04/20 21:43:52  mmunoz
--$ CR29505 function ACCEPT_PERS_CODES update table_site_part for safelink
--$
--$ Revision 1.18  2015/04/20 20:46:24  mmunoz
--$ CR29505 removing condition for new_config2x_data_config when updating table_x_ota_features
--$
--$ Revision 1.17  2015/04/17 21:59:57  mmunoz
--$ CR29505 added more values in free.. procedures
--$
--$ Revision 1.16  2015/04/17 18:55:39  mmunoz
--$ added new procedure update_before_ota
--$
--$ Revision 1.15  2015/04/15 22:56:47  mmunoz
--$ Added Clicks
--$
--$ Revision 1.14  2015/04/14 21:43:41  mmunoz
--$ Added FREE_1611 and Free Dial 1 in Cmd_Cursor
--$
--$ Revision 1.13  2015/04/13 16:48:48  mmunoz
--$ CR29505
--$
--$ Revision 1.12  2015/04/07 16:05:52  mmunoz
--$ Free Dial setting in data_9
--$
--$ Revision 1.11  2015/03/24 21:54:04  mmunoz
--$ Added clicks_611 and free_dial
--$
--$ Revision 1.10  2015/02/05 20:51:07  nguada
--$ restrictions added
--$
--$ Revision 1.9  2014/07/22 13:14:30  hcampano
--$ TAS_2014_06 - Page Plus
--$
--$ Revision 1.8  2014/07/21 14:20:11  hcampano
--$ PagePlus backend release CR26767
--$
--$ Revision 1.7  2014/07/21 14:03:16  hcampano
--$ PagePlus backend release CR26767
--$
--$ Revision 1.6  2014/07/15 15:09:14  hcampano
--$ TAS_2014_06 - Page Plus
--$
--$ Revision 1.5  2013/02/04 16:45:07  mmunoz
--$ CR23043 ADF Oracle Application - Third Release
--$

--------------------------------------------------------------------------------------------
  -- Procedure Parameters
  v_send_ota number;
  v_esn varchar2(30);

  -- Constants
  v_ota_init_status varchar2(20) := 'MSGPENDING';
  v_ota_send_status varchar2(20) := 'OTA SEND';
  v_seq_update varchar2(10):=1;
  v_action_type varchar2(20):='7';
  v_action_text varchar2(20):='PERSGENCODE';
  v_result varchar2(20):='Completed';
  v_ota_action_type varchar2(10):= '262';

  --Service Info
  v_dll number;
  v_site_part_objid number;
  v_iccid  varchar2(30);
  v_org_id  varchar2(40);
  v_min varchar2(30);
  v_msid varchar2(30);
  v_sequence number;
  v_orig_sequence number;
  v_technology varchar2(5);
  v_due_date date;
  v_st_mt number:=0;  --(0=No,1=Yes)
  v_tech_num number;
  v_lid number;

  --Clicks
  v_click_local number;
  v_click_rl number;
  v_click_ld number;
  v_click_rld number;
  v_home_inbound number;
  v_roam_inound number;
  v_click_home_intl number;
  v_click_roam_intl number;
  v_click_in_sms number;
  v_click_out_sms number;
  v_grace_period number;
  v_click_611 number;
  v_free_dial number;
  v_plan_objid number;

  --Carrier Personality
  v_parent varchar2(40);
  v_carrier_id varchar2(30);
  v_carrier_objid number;
  v_home_sid number;
  v_local_sid_1 number;
  v_local_sid_2 number;
  v_local_sid_3 number;
  v_local_sid_4 number;
  v_psms_address varchar2(10);
  v_restrict_ld number;
  v_restrict_intl number;
  v_restrict_callop number;
  v_restrict_roam number;
  v_restrict_inbound number;
  v_restrict_outbound number;

  --Transaction Variables
  v_call_trans_objid number;
  v_pergencode sa.ADFCRM_PERGENCODES.code_id%type;
  v_ota_stmt varchar2(200);
  v_ota_full_stmt varchar2(2000);
  v_union_flag number:=0;

  --Carrier Data Settings
  v_ip1 number;
  v_ip2 number;
  v_ip3 number;
  v_ip4 number;
  v_port number;
  v_apn varchar2(100);
  v_homepage varchar2(100);
  v_mmsc varchar2(100);

  --DLL Cmd Variables
  v_dll_cmd     sa.ADFCRM_PERGENCODES.CODE_CMD%type;
  v_data_1      sa.adfcrm_gen_code_template.data1%type;
  v_data_2      sa.adfcrm_gen_code_template.data2%type;
  v_data_3      sa.adfcrm_gen_code_template.data3%type;
  v_data_4      sa.adfcrm_gen_code_template.data4%type;
  v_data_5      sa.adfcrm_gen_code_template.data5%type;
  v_data_6      sa.adfcrm_gen_code_template.data6%type;
  v_data_7      sa.adfcrm_gen_code_template.data7%type;
  v_data_8      sa.adfcrm_gen_code_template.data8%type;
  v_data_9      varchar2(100);
  v_data_10     sa.adfcrm_gen_code_template.data10%type;
  v_data_11     varchar2(100);

  -----------------------------------------
PROCEDURE GET_PERSONALITY_CODES(
    Ip_Esn           IN VARCHAR2,
    Ip_Source_System IN VARCHAR2,
    Ip_User_Objid    IN NUMBER,
    Ip_Cmd_List      IN VARCHAR2, --(Comma separated command list)
    Ip_Send_Ota      IN NUMBER,   --(0 No,1=Yes)
    Op_Call_Trans_Objid OUT NUMBER,
    op_ota_stmt         OUT VARCHAR2,
    op_orig_seq  OUT NUMBER,
    op_new_seq   OUT NUMBER,
    OP_TECH_NUM  OUT number,
    op_trans_id  out number,
    Op_Error OUT VARCHAR2,
    op_message OUT VARCHAR2)
IS

  --Cursor for Commands Required
  CURSOR Cmd_Cursor
  IS
    SELECT *
    FROM sa.ADFCRM_PERGENCODES
    WHERE CODE_ID IN
      (SELECT Regexp_Substr(Ip_Cmd_List,'[^,]+', 1, Level)
      FROM Dual
        CONNECT BY Regexp_Substr(Ip_Cmd_List, '[^,]+', 1, Level) IS NOT NULL
      )
    UNION
    --Generate FREE_1611 when FREE_611 is selected
    SELECT *
    FROM sa.ADFCRM_PERGENCODES
    WHERE CODE_ID = 'FREE_1611'
    AND 'FREE_611' IN
      (SELECT Regexp_Substr(Ip_Cmd_List,'[^,]+', 1, Level)
      FROM Dual
        CONNECT BY Regexp_Substr(Ip_Cmd_List, '[^,]+', 1, Level) IS NOT NULL
      )
    UNION
    --Generate 'Free Dial 1' when 'Free Dial' is selected
    SELECT *
    FROM sa.ADFCRM_PERGENCODES
    WHERE CODE_ID = 'Free Dial 1'
    AND  'Free Dial' IN
      (SELECT Regexp_Substr(Ip_Cmd_List,'[^,]+', 1, Level)
      FROM Dual
        CONNECT BY Regexp_Substr(Ip_Cmd_List, '[^,]+', 1, Level) IS NOT NULL
      )
    ;
  Cmd_Rec Cmd_Cursor%Rowtype;

  v_ota_trans_objid number;
  v_psms_counter number;
  stmt varchar2(200);


BEGIN
  DBMS_OUTPUT.PUT_LINE('Start');
  ----------------------------------------------------
  -- Check if Cursor for Commands returns any record
  ----------------------------------------------------
  open Cmd_Cursor;
  fetch Cmd_Cursor into Cmd_Rec;
  if Cmd_Cursor%notfound then
    Op_Error            := -10;
    Op_Message          := TRIM(SUBSTR('ERR-00010: SA.ADFCRM_PERSONALITY_PKG.GET_PERSONALITY_CODES Cmd_Cursor'||Chr(10)
                                     ||'Command Not Found for command list: '||Ip_Cmd_List
                                ,1,4000));
    close Cmd_Cursor;
	return;
  else
    close Cmd_Cursor;
  end if;

  v_esn := ip_esn;
  v_send_ota := ip_send_ota;

  -- Find Values Service / Carrier / Line
  -------------------------
  -- Find Data / Parameters
  -------------------------
  Find_Parameters(Op_Error,Op_Message);
  If Op_Error <> 0 Then
     Return;
  end if;

  --------------------
  --Insert Call Trans
  --------------------
  v_call_trans_objid:= sa.seq('x_call_trans');
  INSERT INTO sa.table_x_call_trans
  (
    objid, call_trans2site_part, x_action_type, x_call_trans2carrier, x_call_trans2user,
    x_min,x_service_id, x_sourcesystem,x_transact_date,x_total_units,x_action_text,
    x_reason,x_result,x_sub_sourcesystem,x_iccid,update_stamp
  )
  VALUES
  (
    v_call_trans_objid, v_site_part_objid, v_action_type, v_carrier_objid, ip_user_objid,
    v_min, ip_esn, ip_source_system, sysdate, 0, v_action_text,
    Ip_Cmd_List, v_result, v_org_id, v_iccid, sysdate
  );
  ---------------------------
  --Insert OTA Transaction --
  ---------------------------
  if Ip_Send_Ota = 1 then

     DBMS_OUTPUT.PUT_LINE('OTA');

     v_ota_trans_objid:= sa.seq('x_ota_transaction');

     select max(x_counter)+1 into v_psms_counter
     from sa.table_x_ota_transaction
     where X_Esn = ip_esn;

     INSERT INTO sa.table_x_ota_transaction
     (
       objid, x_transaction_date, x_status, x_esn, x_min, x_action_type, x_mode,
       x_counter, x_carrier_code,  x_ota_trans2x_call_trans
     )
     VALUES
     (
       v_ota_trans_objid, SYSDATE, v_ota_init_status ,ip_esn, v_min, v_action_type,ip_source_system,
       v_psms_counter, v_carrier_id, v_call_trans_objid
     );

     insert into sa.table_x_ota_trans_dtl(objid,x_psms_text,x_ota_message_direction,x_action_type,x_ota_trans_dtl2x_ota_trans)
     VALUES (sa.SEQ('x_ota_trans_dtl'),NULL,'MT',V_OTA_ACTION_TYPE,V_OTA_TRANS_OBJID );

  end if;
  --------------------------
  -- LOOP Comands Required--
  --------------------------
  DBMS_OUTPUT.PUT_LINE('Before Loop');
  delete from sa.adfcrm_gen_code_template
  where esn = v_esn;
  v_union_flag:=0;
  v_ota_full_stmt:=null;
  commit;

  FOR Cmd_Rec IN Cmd_Cursor
  LOOP

    DBMS_OUTPUT.PUT_LINE('In Loop');
    ------------------------------
    -- Generate Code Parameters --
    ------------------------------
    v_dll_cmd :=cmd_rec.code_cmd;
    v_pergencode:=Cmd_Rec.code_id;
    DBMS_OUTPUT.PUT_LINE('v_dll_cmd:'||v_dll_cmd);
    DBMS_OUTPUT.PUT_LINE('v_pergencode:'||v_pergencode);

    CLEAN_COMMAND_PARAMETERS;
    stmt:= 'begin sa.ADFCRM_PERSONALITY_PKG.'||replace(cmd_rec.code_id,' ','_')||'; end;';
    DBMS_OUTPUT.PUT_LINE(stmt);
    Execute Immediate Stmt;

    Insert_Command_Parameters(Op_Error,Op_Message);
    If Op_Error <> 0 Then
       EXIT;
    end if;
    v_sequence:=v_sequence + v_seq_update;
    DBMS_OUTPUT.PUT_LINE('v_sequence:'||v_sequence);

  END LOOP;

  If Op_Error = 0 Then
     Op_Message := 'Template Generated';
     Commit;
  Else
     Rollback;
  End If;

  -----------
  -- Return--
  -----------
  Op_Call_Trans_Objid := v_call_trans_objid;
  op_ota_stmt := v_ota_full_stmt;
  op_orig_seq := v_orig_sequence;
  op_new_seq := v_sequence;
  OP_TECH_NUM := V_TECH_NUM;
  op_trans_id := sa.ota_util_pkg.get_next_esn_counter(Ip_Esn);
  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
end;
----------------------------------------------------------------------------------------------------------------------------------------
function ota_pending(esn varchar2)
return number
is
 n_ret number;
begin
  select objid
  into   n_ret
  from   table_x_ota_transaction
  where  x_esn = esn
  and    x_status in ('MSGPENDING','OTA SEND');

  return n_ret;
exception
  when others then
  return 0;
end ota_pending;
----------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE PAGE_PLUS_GET_PERSNLTY_CODES(
    ip_esn           in varchar2,
    ip_min           in number,
    ip_seq           in number,
    Ip_Source_System IN VARCHAR2,
    ip_user_name    in varchar2,
--    Ip_Send_Ota      IN NUMBER,   --(0 No,1=Yes) -- KILL THIS PARAMETER
    Op_Call_Trans_Objid OUT NUMBER,
    op_ota_stmt         OUT VARCHAR2,
    op_orig_seq  OUT NUMBER,
    op_new_seq   OUT NUMBER,
    OP_TECH_NUM  OUT number,
    op_trans_id  out number,
    Op_Error OUT VARCHAR2,
    op_message out varchar2)
is
  ip_cmd_list varchar2(40) := 'PROD_SELECTION';
  n_ota_pending number;
  n_user_objid number;
  pp_carrier table_x_parameters.x_param_value%type;
  --Cursor for Commands Required
  CURSOR Cmd_Cursor
  IS
    SELECT *
    FROM sa.ADFCRM_PERGENCODES
    WHERE CODE_ID IN
      (SELECT Regexp_Substr(Ip_Cmd_List,'[^,]+', 1, Level)
      FROM Dual
        CONNECT BY Regexp_Substr(Ip_Cmd_List, '[^,]+', 1, Level) IS NOT NULL
      );
  Cmd_Rec Cmd_Cursor%Rowtype;

  v_ota_trans_objid number;
  v_psms_counter number;
  stmt varchar2(200);

  cursor pc_eligibility(ip_esn varchar2)
  is
  select pgc.code_id, esn_pn.PART_CLASS_ID part_class_id, pgc.code_description||decode(pgc.delivery,'MANUAL',' (Manual Only)','OTA',' (OTA Only)','') code_description,
         pgc.code_active, pgc.code_cmd, pgc.code_priority, pgc.clears, pgc.delivery
  from   sa.adfcrm_pergencodes pgc,
         (
         SELECT DISTINCT MTM.PART_CLASS_ID, DECODE(X_TECHNOLOGY,'CDMA',-2,'GSM',-3,-1) DEFAULT_PART_CLASS
         FROM   sa.ADFCRM_MTM_PGCODES2PARTCLASS MTM,
                sa.TABLE_PART_NUM PN,
                sa.TABLE_MOD_LEVEL ML,
                sa.table_part_inst pi,
                sa.table_bus_org bo
         WHERE  MTM.PART_CLASS_ID (+) = PN.PART_NUM2PART_CLASS
         AND    PN.OBJID = ML.PART_INFO2PART_NUM
         and    ml.objid = pi.n_part_inst2part_mod
         and    pn.part_num2bus_org = bo.objid
         AND    PI.PART_SERIAL_NO = ip_esn
         AND    PI.X_DOMAIN = 'PHONES'
         AND    PN.X_DLL>= 10
         ) esn_pn
  where 1=1
  and pgc.code_id = 'PROD_SELECTION';

  pc_eligibility_rec pc_eligibility%rowtype;

  procedure ins_ota_and_dtl(ip_ota_trans_objid number,
                            ip_ota_init_status varchar2,
                            ip_esn varchar2,
                            ip_min varchar2,
                            ip_action_type varchar2,
                            ip_source_system varchar2,
                            ip_psms_counter number,
                            ip_carrier_id varchar2,
                            ip_call_trans_objid number,
                            out_err out varchar2)
  as
  begin
    insert into sa.table_x_ota_transaction
      (objid, x_transaction_date, x_status, x_esn, x_min, x_action_type, x_mode,x_counter, x_carrier_code,  x_ota_trans2x_call_trans)
    values
      (ip_ota_trans_objid, SYSDATE, ip_ota_init_status ,ip_esn, ip_min, ip_action_type,ip_source_system,ip_psms_counter, ip_carrier_id, ip_call_trans_objid);

    insert into sa.table_x_ota_trans_dtl
      (objid,x_psms_text,x_ota_message_direction,x_action_type,x_ota_trans_dtl2x_ota_trans)
    values
      (sa.seq('x_ota_trans_dtl'),null,'MT',v_ota_action_type,ip_ota_trans_objid );

    out_err := '0';
    commit;
  exception
    when others then
      out_err := '1';
  end ins_ota_and_dtl;

begin
  -- CARRIER OBJID MUST EXIST (NEW 7/21/14)
  begin
    select x_param_value
    into   pp_carrier
    from   table_x_parameters
    where  x_param_name = 'ADFCRM_PAGE_PLUS_CARRIER_OBJID';

    select objid,x_carrier_id
    into   v_carrier_objid,v_carrier_id
    from   table_x_carrier
    where  objid = pp_carrier;

  exception
    when others then
      op_error            := -98;
      op_message          := trim(substr('ERR'||op_error||': SA.ADFCRM_PERSONALITY_PKG.PAGE_PLUS_GET_PERSNLTY_CODES '||chr(10)
                                       ||'The internal carrier objid parameter is required '
                                  ,1,4000));
  end;
  -- GET USER OBJID
  -- VALIDATIONS - USER OBJID REQUIRED
  begin
    select objid
    into   n_user_objid
    from table_user
    where s_login_name = ip_user_name;
  exception
    when others then
      op_error            := -99;
      Op_Message          := TRIM(SUBSTR('ERR'||op_error||': SA.ADFCRM_PERSONALITY_PKG.PAGE_PLUS_GET_PERSNLTY_CODES '||Chr(10)
                                       ||'A user objid is required '
                                  ,1,4000));
  end;

  -- VALIDATIONS - ESN REQUIRED
  if ip_esn is null then
    op_error            := -100;
    Op_Message          := TRIM(SUBSTR('ERR'||op_error||': SA.ADFCRM_PERSONALITY_PKG.PAGE_PLUS_GET_PERSNLTY_CODES '||Chr(10)
                                     ||'An ESN is required '
                                ,1,4000));
    return;
  end if;

  -- VALIDATIONS - MIN REQUIRED AND MUST BE 10 DIGITS
  if length(ip_min) > 10 or length(ip_min) < 10 or ip_min is null then
    op_error            := -200;
    op_message          := trim(substr('ERR'||op_error||': SA.ADFCRM_PERSONALITY_PKG.PAGE_PLUS_GET_PERSNLTY_CODES '||chr(10)
                                     ||'Min must be 10 digits ('||nvl(length(ip_min),'0')||')'
                                ,1,4000));
    return;
  end if;

  -- START CHECKING THE PARTCLASS OF THE ESN HAS THIS PARAMETER AND ESN IS A PAGE PLUS BRAND
  open pc_eligibility(ip_esn);
  fetch pc_eligibility into pc_eligibility_rec;
  if pc_eligibility%notfound then
    op_error            := -101;
    op_message          := trim(substr('ERR'||op_error||': SA.ADFCRM_PERSONALITY_PKG.PAGE_PLUS_GET_PERSNLTY_CODES '||chr(10)
                                     ||'Part Class not configured for PROD_SELECTION or incompatible brand'
                                ,1,4000));
    close pc_eligibility;
	  return;
  else
    close pc_eligibility;
  end if;

  -- END CHECKING THE PARTCLASS OF THE ESN HAS THIS PARAMETER


  DBMS_OUTPUT.PUT_LINE('Start');
  ----------------------------------------------------
  -- Check if Cursor for Commands returns any record
  ----------------------------------------------------
  open Cmd_Cursor;
  fetch Cmd_Cursor into Cmd_Rec;
  if Cmd_Cursor%notfound then
    Op_Error            := -10;
    Op_Message          := TRIM(SUBSTR('ERR-00010: SA.ADFCRM_PERSONALITY_PKG.GET_PERSONALITY_CODES Cmd_Cursor'||Chr(10)
                                     ||'Command Not Found for command list: '||Ip_Cmd_List
                                ,1,4000));
    close Cmd_Cursor;
	return;
  else
    close Cmd_Cursor;
  end if;

  v_esn := ip_esn;
  v_send_ota := 1; --nvl(ip_send_ota,'1');
  v_min := ip_min;

  -- VALIDATE THE MIN IS NOT ASSIGNED TO A DIFFERENT BRAND
  validate_page_plus_min(op_error,op_message);
  If Op_Error <> 0 Then
     return;
  end if;

  -- COLLECT PARAMETER DATA
  FIND_PAGE_PLUS_PARAMETERS(Op_Error,Op_Message);
  If Op_Error <> 0 Then
     Return;
  end if;

  -- CHECK IF THERE IS AN OTA PENDING (RETURNS TABLE_X_OTA_TRANSACTION OBJID)
  n_ota_pending := ota_pending(ip_esn);

  --------------------------------------------------------------------------------
  -- IF THERE IS A PROD_SELECTION OTA PENDING, SET CALL TRANS TO FAILED AND RECREATE
  -- WIPE OUT adfcrm_gen_code_template AND table_x_code_hist_temp
  if n_ota_pending >0 then
    for i in (select objid
              from table_x_call_trans
              where x_service_id = ip_esn
              and x_reason = 'PROD_SELECTION')
    loop
      update table_x_ota_transaction
      set    x_status = 'Failed'
      where x_ota_trans2x_call_trans = i.objid;

      reject_pers_codes(ip_call_trans_objid => i.objid,
                         op_error  => op_error,
                         op_message => op_message);
    end loop;

    commit;

    update table_x_call_trans
    set    x_result = 'Failed'
    where  x_service_id = ip_esn
    and x_reason = 'PROD_SELECTION';

  end if;

  commit;
--------------------------------------------------------------------------------
  -- SEQ VALIDATIONS
  -- IF NO OTA PENDING, SEQ IS OPTIONAL, IF USER ENTERS SEQ, USE THE USER'S SEQ
  if ip_seq is not null then
    dbms_output.put_line('NO OTA PENDING, USE USER SEQ ENTERED ('||ip_seq||')');
    v_sequence := ip_seq;
  else
    v_sequence := v_orig_sequence;
  end if;

  -- CREATE CALL TRANS RECORD
  v_call_trans_objid:= sa.seq('x_call_trans');
  <<retry_call_trans>>
  begin
  insert into sa.table_x_call_trans
    (objid, call_trans2site_part, x_action_type, x_call_trans2carrier, x_call_trans2user,
     x_min,x_service_id, x_sourcesystem,x_transact_date,x_total_units,x_action_text,
     x_reason,x_result,x_sub_sourcesystem,x_iccid,update_stamp)
  values
    (v_call_trans_objid, v_site_part_objid, v_action_type, v_carrier_objid, n_user_objid,
     v_min, ip_esn, ip_source_system, sysdate, 0, v_action_text,
    ip_cmd_list, v_result, v_org_id, v_iccid, sysdate);

  exception
    when others then
      goto retry_call_trans;
  end;
  -- ALWAYS INSERT OTA TRANS
   DBMS_OUTPUT.PUT_LINE('OTA');

   v_ota_trans_objid:= sa.seq('x_ota_transaction');

   select max(x_counter)+1 into v_psms_counter
   from sa.table_x_ota_transaction
   where x_esn = ip_esn;

   <<retry_ota>>
   ins_ota_and_dtl(ip_ota_trans_objid => v_ota_trans_objid,
                   ip_ota_init_status => v_ota_init_status,
                   ip_esn => ip_esn,
                   ip_min => v_min,
                   ip_action_type => v_action_type,
                   ip_source_system => ip_source_system,
                   ip_psms_counter => v_psms_counter,
                   ip_carrier_id => v_carrier_id,
                   ip_call_trans_objid => v_call_trans_objid,
                   out_err => op_error);
  if op_error != '0' then
    goto retry_ota;
  end if;

  --------------------------
  -- LOOP Comands Required--
  --------------------------
  DBMS_OUTPUT.PUT_LINE('Before Loop');
  delete from sa.adfcrm_gen_code_template
  where esn = v_esn;
  v_union_flag:=0;
  v_ota_full_stmt:=null;
  commit;

  FOR Cmd_Rec IN Cmd_Cursor
  LOOP

    DBMS_OUTPUT.PUT_LINE('In Loop');
    ------------------------------
    -- Generate Code Parameters --
    ------------------------------
    v_dll_cmd :=cmd_rec.code_cmd;
    v_pergencode:=Cmd_Rec.code_id;
    DBMS_OUTPUT.PUT_LINE('v_dll_cmd:'||v_dll_cmd);
    DBMS_OUTPUT.PUT_LINE('v_pergencode:'||v_pergencode);

    CLEAN_COMMAND_PARAMETERS;
    stmt:= 'begin sa.ADFCRM_PERSONALITY_PKG.'||cmd_rec.code_id||'; end;';
    DBMS_OUTPUT.PUT_LINE(stmt);
    Execute Immediate Stmt;

    Insert_Command_Parameters(Op_Error,Op_Message);
    If Op_Error <> 0 Then
       EXIT;
    end if;
    v_sequence:=v_sequence + v_seq_update;
    DBMS_OUTPUT.PUT_LINE('v_sequence:'||v_sequence);

  END LOOP;

  if op_error = 0 then
     Op_Message := 'Template Generated';
     commit;
  Else
     Rollback;
  End If;

  -----------
  -- Return--
  -----------
  Op_Call_Trans_Objid := v_call_trans_objid;
  op_ota_stmt := v_ota_full_stmt;
  op_orig_seq := v_orig_sequence;

  if ip_seq is not null then
    dbms_output.put_line('NO OTA PENDING, USE USER SEQ ENTERED ('||ip_seq||')');
    op_new_seq := ip_seq;
  else
    op_new_seq := v_orig_sequence;
  end if;

  OP_TECH_NUM := V_TECH_NUM;
  op_trans_id := sa.ota_util_pkg.get_next_esn_counter(ip_esn);
  exception
    when others then
      rollback;
      if instr(sqlerrm,'SA.IND_CALL_TRANS')>0 then
       op_error    := sqlcode;
       OP_MESSAGE  := TRIM(SUBSTR('ERROR X_CALL_TRANS INDEX (X_SERVICE_ID, X_MIN, X_TRANSACT_DATE, X_ACTION_TYPE)' ||CHR(10) ||
                             DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                      ,1,4000));
      else
       OP_ERROR    := SQLCODE;
       OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                             DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                      ,1,4000));
      end if;
     return;
END;

PROCEDURE FIND_PARAMETERS (
    op_error OUT VARCHAR2,
    op_message OUT VARCHAR2)
IS

  cursor service_cur (esn varchar2) is
  Select Pn.X_Technology,
         decode(pn.x_technology,'GSM',3,'CDMA',2) tech_num,
         Pn.X_Dll,
         Pc.Name Part_Class,
         pc.objid class_objid,
         Bo.Org_Id,
         sp.objid site_part_objid,
         sp.x_iccid,
         sp.x_min,
         sp.x_msid,
         Sp.Site_Part2x_Plan,
         Sp.Site_Part2x_New_Plan,
         ca.objid carrier_objid,
         ca.x_carrier_id,
         cp.x_parent_id,
         cp.x_parent_name,
         cp.x_ota_psms_address,
         pi.x_sequence,
         sp.warranty_date,
         Ca.Carrier2personality,
         nvl(ota.new_config2x_data_config,current_config2x_data_config) data_config_objid,
         per.x_restrict_ld,
         per.x_restrict_intl,
         per.x_restrict_callop,
         per.x_restrict_roam,
         per.x_restrict_inbound,
         per.x_restrict_outbound,
         ota.x_611_clicks
  From sa.Table_Part_Num pn
  ,sa.table_part_class pc
  ,sa.table_bus_org bo
  ,sa.Table_Mod_Level ml
  ,sa.Table_Part_Inst pi
  ,sa.table_site_part sp
  ,sa.table_part_inst linepi
  ,sa.table_x_parent cp
  ,sa.table_x_carrier_group cg
  ,sa.table_x_carrier ca
  ,sa.table_x_ota_features ota
  ,sa.table_x_carr_personality per
  Where Pn.Objid = ml.Part_Info2part_Num
  and pi.n_part_inst2part_mod =ml.objid
  and pi.part_serial_no = esn
  and pi.x_domain = 'PHONES'
  and pn.part_num2part_class = pc.objid
  and pn.part_num2bus_org = bo.objid
  and sp.x_service_id = pi.part_serial_no
  and sp.part_status = 'Active'
  and linepi.part_serial_no = sp.x_min
  and linepi.x_domain = 'LINES'
  and Linepi.Part_Inst2carrier_Mkt = ca.objid
  and Ca.Carrier2carrier_Group=cg.objid
  and Cg.X_Carrier_Group2x_Parent=cp.objid
  and pi.objid = ota.x_ota_features2part_inst (+);

  service_rec service_cur%rowtype;

  cursor clicks_cur (click_objid number) is
  select * from sa.table_x_click_plan
  where objid = click_objid;

  clicks_rec clicks_cur%rowtype;

  cursor click_cur_default (class_objid varchar2) is
  select * from sa.table_x_click_plan
  where x_plan_id = ( select x_param_value  from sa.table_x_part_class_values v, sa.table_x_part_class_params n
                      where value2class_param = n.objid and n.x_param_name = 'DEFAULT_CLICK_ID'  and v.value2part_class=class_objid);

  cursor click_cur_by_plan (plan_objid varchar2) is
  select * from sa.table_x_click_plan
  where objid = plan_objid;

  cursor master_sid_cur (personality_objid number, technology varchar2) is
  select * from table_x_sids
  where Sids2personality = personality_objid
  and x_sid_type = technology;

  master_sid_rec master_sid_cur%rowtype;

  cursor local_sid_cur (personality_objid number) is
  select * from table_x_sids
  where Sids2personality = personality_objid
  and X_Sid_Type = 'LOCAL'
  order by x_index asc;

  local_sid_rec local_sid_cur%rowtype;
  sid_counter number:=0;

  cursor data_config_cur (data_config_objid number) is
  select * from sa.table_x_data_config
  where objid =data_config_objid;

  data_config_rec data_config_cur%rowtype;

  cursor ip_parser_cur (ip_port varchar2) is
  SELECT Regexp_Substr(ip_port,'[^.:]+', 1, Level) ipelement
  FROM Dual
  CONNECT BY Regexp_Substr(ip_port, '[^.:]+', 1, Level) IS NOT NULL;
  ip_parser_rec ip_parser_cur%rowtype;

  ip_element_counter number:=0;
BEGIN
  Op_Error := 0;
  op_message := 'Transaction Completed Successfully';

  open service_cur(v_esn);
  fetch service_cur into service_rec;
  if service_cur%found then
     v_dll := service_rec.X_Dll;
     v_site_part_objid := service_rec.site_part_objid;
     v_iccid := service_rec.x_iccid;
     v_org_id := service_rec.org_id;
     v_min := service_rec.x_min;
     v_msid := service_rec.x_msid;
     v_sequence := service_rec.x_sequence;
     v_orig_sequence := service_rec.x_sequence;
     v_sequence := service_rec.x_sequence;
     v_technology := service_rec.x_technology;
     v_due_date :=service_rec.warranty_date;
     v_parent := service_rec.x_parent_name;
     v_carrier_id := service_rec.x_carrier_id;
     v_carrier_objid := service_rec.carrier_objid;
     v_tech_num := service_rec.tech_num;
     v_psms_address := service_rec.x_ota_psms_address;
     v_restrict_ld :=service_rec.x_restrict_ld;
     v_restrict_intl := service_rec.x_restrict_intl;
     v_restrict_callop := service_rec.x_restrict_callop;
     v_restrict_roam := service_rec.x_restrict_roam;
     v_restrict_inbound := service_rec.x_restrict_inbound;
     v_restrict_outbound := service_rec.x_restrict_outbound;

     ------------
     v_st_mt :=  sa.PHONE_PKG.Sf_Is_Multitank_Mode(v_esn);
     -------------
     v_lid := nvl(sa.adfcrm_safelink.get_lid(ip_esn => v_esn),0);
     if v_lid != 0 then
        MHEALTH_PROCESS.get_cust_free_dial(ip_esn => v_esn, op_phone => v_free_dial);
        MHEALTH_PROCESS.get_cust_favored_sms(ip_esn => v_esn, op_plan_id => v_plan_objid);
     end if;
  Else
     Close Service_Cur;
     Op_Error    := -100;
     OP_MESSAGE  := TRIM(SUBSTR('ERR-00100: SA.ADFCRM_PERSONALITY_PKG.FIND_PARAMETERS service_cur'||Chr(10)
                         ||'Service Not Found for ESN: '||v_esn
                    ,1,4000));
     RETURN;
  end if;
  close service_cur;

  -- Not Prepaid Engine or Obsolete Technology
  if nvl(v_dll,0)<=10 or v_technology='ANALOG' or v_technology='TDMA' then
     Op_Error    := -101;
     OP_MESSAGE  := TRIM(SUBSTR('ERR-00101: SA.ADFCRM_PERSONALITY_PKG.FIND_PARAMETERS '||Chr(10)
                         ||'Not Prepaid Phone or Obsolete Technology: '||v_esn
                    ,1,4000));

     RETURN;

  end if;

  if v_lid != 0 and v_plan_objid is not null then
     --clicks for safelink phones
     open click_cur_by_plan (v_plan_objid);
     fetch click_cur_by_plan into clicks_rec;
     if click_cur_by_plan%notfound then
        close click_cur_by_plan;
        Op_Error    := -102;
        OP_MESSAGE  := TRIM(SUBSTR('ERR-00101: SA.ADFCRM_PERSONALITY_PKG.FIND_PARAMETERS click_cur_by_plan'||Chr(10)
                            ||'Clicks Not Found for Plan: '||v_plan_objid
                       ,1,4000));
        Return;
     end if;

  else

      open clicks_cur(nvl(service_rec.Site_Part2x_New_Plan,service_rec.Site_Part2x_Plan));
      fetch clicks_cur into clicks_rec;
      if clicks_cur%notfound then
         Close clicks_cur;
         open click_cur_default (service_rec.class_objid);
         fetch click_cur_default into clicks_rec;
         if click_cur_default%notfound then
            close click_cur_default;
            Op_Error    := -102;
            OP_MESSAGE  := TRIM(SUBSTR('ERR-00101: SA.ADFCRM_PERSONALITY_PKG.FIND_PARAMETERS clicks_cur'||Chr(10)
                                ||'Clicks Not Found for Plan: '||nvl(service_rec.Site_Part2x_New_Plan,service_rec.Site_Part2x_Plan)
                           ,1,4000));
            Return;
         end if;
      end if;

  end if;

  --Clicks
  v_click_local := clicks_rec.X_CLICK_LOCAL;
  v_click_rl := clicks_rec.X_CLICK_RL;
  v_click_ld := clicks_rec.X_CLICK_LD;
  v_click_rld := clicks_rec.X_CLICK_RLD;
  v_home_inbound := clicks_rec.X_HOME_INBOUND;
  v_roam_inound := clicks_rec.X_ROAM_INBOUND;
  v_click_home_intl := clicks_rec.X_CLICK_HOME_INTL;
  v_click_roam_intl := clicks_rec.X_CLICK_ROAM_INTL;
  v_click_in_sms := clicks_rec.X_CLICK_IN_SMS;
  v_click_out_sms := clicks_rec.X_CLICK_OUT_SMS;
  v_grace_period := clicks_rec.X_GRACE_PERIOD_IN;

  if clicks_cur%isopen then
     close clicks_cur;
  end if;
  if click_cur_default%isopen then
     close click_cur_default;
  end if;

  if click_cur_by_plan%isopen then
     close click_cur_by_plan;
  end if;

  --Carrier Personality
  open master_sid_cur (service_rec.Carrier2personality,service_rec.x_technology);
  fetch master_sid_cur into master_sid_rec;
  if master_sid_cur%found then
     V_Home_Sid:=Master_Sid_Rec.X_Sid;
  Else
     null;
     --Close master_sid_cur;
     --Op_Error    := -103;
     --OP_MESSAGE  := TRIM(SUBSTR('ERR-00102: SA.ADFCRM_PERSONALITY_PKG.FIND_PARAMETERS master_sid_cur'||Chr(10)
     --                    ||'Carrier Personality Not Found for personality: '||Service_Rec.Carrier2personality
     --                    ||' technology: '||service_rec.x_technology
     --               ,1,4000));
     --Return;
  end if;
  close master_sid_cur;

  for local_sid_rec in local_sid_cur(service_rec.Carrier2personality) loop
     sid_counter:=sid_counter+1;
     if sid_counter = 1 then
       v_local_sid_1 := local_sid_rec.x_sid;
     elsif sid_counter = 2 then
       v_local_sid_2 := local_sid_rec.x_sid;
     elsif sid_counter = 3 then
       v_local_sid_3 := local_sid_rec.x_sid;
     elsif sid_counter = 4 then
       v_local_sid_4 := local_sid_rec.x_sid;
     end if;
  end loop;

  -- Data Config data
  open data_config_cur(service_rec.data_config_objid);
  fetch data_config_cur into data_config_rec;
  if data_config_cur%found then

     for ip_parser_rec in ip_parser_cur(data_config_rec.x_ip_address) loop
        ip_element_counter:=ip_element_counter+1;
        if ip_element_counter=1 then
           v_ip1:=ip_parser_rec.ipelement;
        elsif ip_element_counter= 2 then
           v_ip2 :=ip_parser_rec.ipelement;
        elsif ip_element_counter= 3 then
           v_ip3:=ip_parser_rec.ipelement;
        elsif ip_element_counter = 4 then
           v_ip4:=ip_parser_rec.ipelement;
        elsif ip_element_counter = 5 then
           v_port:=ip_parser_rec.ipelement;
        end if;

     end loop;
     v_apn:= data_config_rec.x_apn;
     v_homepage:= data_config_rec.x_homepage;
     v_mmsc:=data_config_rec.x_mmsc;
   Else
     null;
     --Close data_config_cur;
     --Op_Error    := -104;
     --OP_MESSAGE  := TRIM(SUBSTR('ERR-00103: SA.ADFCRM_PERSONALITY_PKG.FIND_PARAMETERS data_config_cur'||Chr(10)
     --                    ||'Data Config data Not Found for id: '||service_rec.data_config_objid
     --               ,1,4000));
     --Return;
  end if;
  close data_config_cur;


  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
end;
---------------------------------------------------------------------------------------------------------------------------------------------
procedure validate_page_plus_min (
    op_error out varchar2,
    op_message OUT VARCHAR2)
is
  sp_objid        table_site_part.objid%type;
  esn_assigned    table_part_inst.part_serial_no%type;

  cursor get_min_info(ip_min varchar2)
  is
  select * from table(adfcrm_ret_min_info(ip_min));

  min_info_rec get_min_info%rowtype;

  cursor service_cur (esn varchar2) is
  select b.org_id,
         n.x_technology,
         n.x_dll,
         decode(n.x_technology,'GSM',3,'CDMA',2) tech_num,
         p.x_part_inst_status pis,
         p.x_iccid,
         p.x_sequence
  from   table_part_inst p,
         table_mod_level m,
         table_part_num n,
         table_bus_org b
  where  1=1
  and    p.n_part_inst2part_mod = m.objid
  and    m.part_info2part_num = n.objid
  and    n.part_num2bus_org = b.objid
  and    p.part_serial_no = esn;

  service_rec service_cur%rowtype;

begin
  open get_min_info(v_min);
  loop
    fetch get_min_info into min_info_rec;
    exit when get_min_info%notfound;
    if min_info_rec.col = 'SP_OBJID' then
      sp_objid := min_info_rec.val; -- CLEAN DOESN'T LOOK LIKE I'M USING THIS
    end if;
    if min_info_rec.col = 'ESN' then
      esn_assigned := min_info_rec.val; -- LOOKING FOR A MARRIAGE THOUGH SITE PART
    end if;
  end loop;
  close get_min_info;

  -- VALIDATIONS - IF MIN HAS ESN ASSIGNED
  -- CHECK BRAND COMPATIBLILITY
  open service_cur(esn_assigned);
  loop
    fetch service_cur into service_rec;
    exit when service_cur%notfound;
    if service_rec.org_id not in ('PAGE_PLUS','STRAIGHT_TALK') then
     op_error    := -300;
     OP_MESSAGE  := TRIM(SUBSTR('ERR-00101: SA.ADFCRM_PERSONALITY_PKG.VALIDATE_PAGE_PLUS_MIN '||Chr(10)
                         ||'Min is assigned to an ESN that is not compatible with PagePlus. ('||service_rec.org_id||')'
                    ,1,4000));
      return;
    end if;
  end loop;
  close service_cur;



end validate_page_plus_min;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FIND_PAGE_PLUS_PARAMETERS (
    op_error OUT VARCHAR2,
    op_message OUT VARCHAR2)
IS

  v_pis table_part_inst.x_part_inst_status%type;

  cursor service_cur (esn varchar2) is
  select b.org_id,
         n.x_technology,
         n.x_dll,
         decode(n.x_technology,'GSM',3,'CDMA',2) tech_num,
         p.x_part_inst_status pis,
         p.x_iccid,
         p.x_sequence
  from   table_part_inst p,
         table_mod_level m,
         table_part_num n,
         table_bus_org b
  where  1=1
  and    p.n_part_inst2part_mod = m.objid
  and    m.part_info2part_num = n.objid
  and    n.part_num2bus_org = b.objid
  and    p.part_serial_no = esn;

  service_rec service_cur%rowtype;

  cursor clicks_cur (click_objid number) is
  select * from sa.table_x_click_plan
  where objid = click_objid;

  clicks_rec clicks_cur%rowtype;

  cursor click_cur_default (class_objid varchar2) is
  select * from sa.table_x_click_plan
  where x_plan_id = ( select x_param_value  from sa.table_x_part_class_values v, sa.table_x_part_class_params n
                      where value2class_param = n.objid and n.x_param_name = 'DEFAULT_CLICK_ID'  and v.value2part_class=class_objid);

  cursor master_sid_cur (personality_objid number, technology varchar2) is
  select * from table_x_sids
  where Sids2personality = personality_objid
  and x_sid_type = technology;

  master_sid_rec master_sid_cur%rowtype;

  cursor local_sid_cur (personality_objid number) is
  select * from table_x_sids
  where Sids2personality = personality_objid
  and X_Sid_Type = 'LOCAL'
  order by x_index asc;

  local_sid_rec local_sid_cur%rowtype;
  sid_counter number:=0;

  cursor data_config_cur (data_config_objid number) is
  select * from sa.table_x_data_config
  where objid =data_config_objid;

  data_config_rec data_config_cur%rowtype;

  cursor ip_parser_cur (ip_port varchar2) is
  SELECT Regexp_Substr(ip_port,'[^.:]+', 1, Level) ipelement
  FROM Dual
  CONNECT BY Regexp_Substr(ip_port, '[^.:]+', 1, Level) IS NOT NULL;
  ip_parser_rec ip_parser_cur%rowtype;

  ip_element_counter number:=0;



BEGIN
  Op_Error := 0;
  op_message := 'Transaction Completed Successfully';

  open service_cur(v_esn);
  fetch service_cur into service_rec;
  if service_cur%found then
     v_dll := service_rec.x_dll;
     v_iccid := service_rec.x_iccid;
     v_org_id := service_rec.org_id;
     v_pis := service_rec.pis;
     v_sequence := service_rec.x_sequence;
     v_orig_sequence := service_rec.x_sequence;
     v_sequence := service_rec.x_sequence;
     v_technology := service_rec.x_technology;
     v_tech_num := service_rec.tech_num;
     ------------
     v_st_mt :=  sa.PHONE_PKG.Sf_Is_Multitank_Mode(v_esn);
     -------------
  Else
     Close Service_Cur;
     Op_Error    := -100;
     OP_MESSAGE  := TRIM(SUBSTR('ERR-00100: SA.ADFCRM_PERSONALITY_PKG.FIND_PAGE_PLUS_PARAMETERS service_cur'||Chr(10)
                         ||'Service Not Found for ESN: '||v_esn
                    ,1,4000));
     RETURN;
  end if;
  close service_cur;

  -- Not Prepaid Engine or Obsolete Technology
  if nvl(v_dll,0)<=10 or v_technology='ANALOG' or v_technology='TDMA' then
     Op_Error    := -101;
     OP_MESSAGE  := TRIM(SUBSTR('ERR-00101: SA.ADFCRM_PERSONALITY_PKG.FIND_PAGE_PLUS_PARAMETERS '||Chr(10)
                         ||'Not Prepaid Phone or Obsolete Technology: '||v_esn
                    ,1,4000));

     RETURN;
  end if;

  -- INCOMPATIBLE BRAND
  if v_org_id not in ('PAGE_PLUS','STRAIGHT_TALK') then
     Op_Error    := -102;
     OP_MESSAGE  := TRIM(SUBSTR('ERR-00101: SA.ADFCRM_PERSONALITY_PKG.FIND_PAGE_PLUS_PARAMETERS '||Chr(10)
                         ||'ESN is a non compatible brand. ('||v_org_id||')'
                    ,1,4000));
  end if;

  -- INCOMPATIBLE STATUS
  if v_pis not in ('50','151') then
     Op_Error    := -103;
     OP_MESSAGE  := TRIM(SUBSTR('ERR-00101: SA.ADFCRM_PERSONALITY_PKG.FIND_PAGE_PLUS_PARAMETERS '||Chr(10)
                         ||'ESN has a non compatible status. ('||v_pis||')'
                    ,1,4000));
  end if;

  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           dbms_utility.format_error_backtrace
                    ,1,4000));
     return;
END FIND_PAGE_PLUS_PARAMETERS;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_CODE_HIST_TEMP (
    Ip_code_temp_objid  IN NUMBER,
    Ip_gen_code         IN VARCHAR2,
    Op_Error           out VARCHAR2,
    op_message         out VARCHAR2)
IS
BEGIN
   Op_Error := 0;
   op_message := 'Transaction Completed Successfully';
    ------------------------------
    -- Check input parameters --
    ------------------------------
   if Ip_code_temp_objid is null
   then
      Op_Error := -200;
      Op_message := TRIM(SUBSTR('ERR-00200: SA.ADFCRM_PERSONALITY_PKG.UPDATE_CODE_HIST_TEMP '||Chr(10)
                         ||'Ip_code_temp_objid is missing'
                    ,1,4000));
	  return;
   end if;

   if Ip_gen_code is null
   then
      Op_Error := -210;
      Op_message := TRIM(SUBSTR('ERR-00210: SA.ADFCRM_PERSONALITY_PKG.UPDATE_CODE_HIST_TEMP '||Chr(10)
                         ||'Ip_gen_code is missing'
                    ,1,4000));
	  return;
   end if;

    -----------------------------------
    -- Update table_x_code_hist_temp --
    -----------------------------------
   update sa.table_x_code_hist_temp
   set X_CODE = ip_gen_code
   where objid = Ip_code_temp_objid;

   delete from sa.adfcrm_gen_code_template
   where CODE_TEMP_OBJID =Ip_code_temp_objid;

   Commit;
  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
END;


PROCEDURE REJECT_PERS_CODES (
    ip_call_trans_objid NUMBER,
    op_Error           out VARCHAR2,
    op_message         out VARCHAR2)
IS
BEGIN
    Op_Error := 0;
    op_message := 'Transaction Completed Successfully';
    ------------------------------
    -- Check input parameters --
    ------------------------------
   if ip_call_trans_objid is null
   then
      Op_Error := -300;
      Op_message := TRIM(SUBSTR('ERR-00300: SA.ADFCRM_PERSONALITY_PKG.REJECT_PERS_CODES '||Chr(10)
                         ||'ip_call_trans_objid is missing'
                    ,1,4000));
	  return;
   end if;

    delete from sa.adfcrm_gen_code_template
    where code_temp_objid in (select objid
    from sa.table_x_code_hist_temp
    where X_Code_Temp2x_Call_Trans=ip_call_trans_objid);

    delete from sa.table_x_code_hist_temp
    where X_Code_Temp2x_Call_Trans = ip_call_trans_objid;

    Commit;
  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
END;

PROCEDURE ACCEPT_PERS_CODES (
    ip_call_trans_objid NUMBER,
    op_Error           out VARCHAR2,
    op_message         out VARCHAR2)
IS
    cursor temp_cur is
    select * from sa.table_x_code_hist_temp hist,sa.ADFCRM_PERGENCODES pgc
    where hist.X_Code_Temp2x_Call_Trans = ip_call_trans_objid
    and hist.x_type = pgc.code_id;

    temp_rec temp_cur%rowtype;
    max_seq number:=0;

    clear_click varchar2(10):='false';
    clear_data varchar2(10):='false';
    clear_611 varchar2(10):='false';
    clear_dial varchar2(10):='false';
    clear_free_mms varchar2(10):='false';
BEGIN
    Op_Error := 0;
    op_message := 'Transaction Completed Successfully';
    ------------------------------
    -- Check input parameters --
    ------------------------------
   if ip_call_trans_objid is null
   then
      Op_Error := -400;
      Op_message := TRIM(SUBSTR('ERR-00400: SA.ADFCRM_PERSONALITY_PKG.ACCEPT_PERS_CODES '||Chr(10)
                         ||'ip_call_trans_objid is missing'
                    ,1,4000));
	  return;
   end if;

    for temp_rec in temp_cur loop
       insert into sa.table_x_code_hist (objid,x_gen_code,x_sequence,
       code_hist2call_trans,x_code_accepted,x_code_type,x_seq_update)
       values (sa.seq('x_code_hist'),temp_rec.x_code,temp_rec.x_seq ,
       ip_call_trans_objid,'YES',temp_rec.x_type,temp_rec.x_seq_update);

       if max_seq< to_number(temp_rec.x_seq) then
          max_seq := to_number(temp_rec.x_seq);
       end if;
       if temp_rec.clears = 'CLICKS' then
          clear_click:='true';
       end if;
       if temp_rec.clears  = 'DATA' then
          clear_data:='true';
       end if;
       if temp_rec.clears = '611' then
           clear_611 := 'true';
       end if;
       if temp_rec.clears = 'FREE_DIAL' then
           clear_dial := 'true';
       end if;

       if temp_rec.clears = 'FREE_MMS' then
           clear_free_mms := 'true';
       end if;

    end loop;

    select x_service_id
    into v_esn
    from sa.table_x_call_trans
    where objid = ip_call_trans_objid;
    v_lid := nvl(sa.adfcrm_safelink.get_lid(ip_esn => v_esn),0);

    if max_seq>=0 then
       update sa.table_part_inst
       set X_Sequence = max_seq+1
       where part_serial_no in (select x_service_id from sa.table_x_call_trans
                                where objid = ip_call_trans_objid);
    end if;

    ------------------------
    -- CLEAR FLAG LOGIC HERE
    -------------------------
   if clear_dial= 'true' and v_lid != 0 then
      MHEALTH_PROCESS.get_cust_free_dial(ip_esn => v_esn, op_phone => v_free_dial);
   end if;

   if clear_click= 'true' and v_lid != 0 then
      MHEALTH_PROCESS.get_cust_favored_sms(ip_esn => v_esn, op_plan_id => v_plan_objid);
   end if;

   if clear_free_mms = 'true' then
     update sa.table_site_part
     set SITE_PART2X_PLAN = 5024,   --Free MMS and Browsing
         SITE_PART2X_NEW_PLAN = null
     where x_service_id  in (select x_service_id
                             from sa.table_x_call_trans where objid = ip_call_trans_objid)
     and part_status = 'Active';
   end if;

   if (clear_data= 'true' or clear_611= 'true' or clear_dial= 'true') then
      update sa.table_x_ota_features
      set  x_611_clicks = decode(clear_611,'true',1,x_611_clicks),
           x_free_dial = decode(clear_dial,'true',v_free_dial,x_free_dial),
           current_config2x_data_config = decode(new_config2x_data_config,null,current_config2x_data_config,
                      decode(clear_data,'true',new_config2x_data_config,current_config2x_data_config)),
           new_config2x_data_config =  decode(new_config2x_data_config,null,null,
                      decode(clear_data,'true',null,new_config2x_data_config))
      where x_ota_features2part_inst in (select objid
      from sa.table_part_inst where part_serial_no in (select x_service_id
      from sa.table_x_call_trans where objid = ip_call_trans_objid)
      --and new_config2x_data_config is not null
      and x_domain = 'PHONES');
   end if;
   if clear_click= 'true' then
     update sa.table_site_part
     set SITE_PART2X_PLAN = decode(v_lid,0,SITE_PART2X_NEW_PLAN,v_plan_objid),
         SITE_PART2X_NEW_PLAN = null
     where x_service_id  in (select x_service_id
     from sa.table_x_call_trans where objid = ip_call_trans_objid)
     and (SITE_PART2X_NEW_PLAN is not null or
          v_lid != 0)
     and part_status = 'Active';

   end if;

   --clearOtaPendingTemp
   delete from sa.table_x_code_hist_temp hist
   where hist.X_Code_Temp2x_Call_Trans = ip_call_trans_objid;

   commit;
  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
END;

PROCEDURE UPDATE_OTA_TRANSACTION (
     ip_call_trans_objid IN NUMBER,
     ip_psms_text        IN VARCHAR2,
     Op_Error            out VARCHAR2,
     op_message          out VARCHAR2)
IS
BEGIN
   Op_Error := 0;
   op_message := 'Transaction Completed Successfully';
    ------------------------------
    -- Check input parameters --
    ------------------------------
   if ip_call_trans_objid is null
   then
      Op_Error := -500;
      Op_message := TRIM(SUBSTR('ERR-00500: SA.ADFCRM_PERSONALITY_PKG.ACCEPT_PERS_CODES '||Chr(10)
                         ||'ip_call_trans_objid is missing'
                    ,1,4000));
	  return;
   end if;

   if ip_psms_text is null
   then
      Op_Error := -510;
      Op_message := TRIM(SUBSTR('ERR-00510: SA.ADFCRM_PERSONALITY_PKG.ACCEPT_PERS_CODES '||Chr(10)
                         ||'ip_psms_text is missing'
                    ,1,4000));
	  return;
   end if;

   update sa.table_x_ota_trans_dtl
   set X_Psms_Text = ip_psms_text
   where X_Ota_Trans_Dtl2x_Ota_Trans in (select objid from table_x_ota_transaction
                                         where X_Ota_Trans2x_Call_Trans = ip_call_trans_objid
                                         and X_Status = v_ota_init_status)
   and X_Psms_Text is null;


   update sa.table_x_ota_transaction
   set X_Status = v_ota_send_status
   where  X_Ota_Trans2x_Call_Trans = ip_call_trans_objid
   and X_Status = v_ota_init_status;

   commit;

   Accept_Pers_Codes(Ip_Call_Trans_Objid,Op_Error,Op_Message);

  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
END;


--Commad Specific Code
PROCEDURE CLICKS
IS
BEGIN
  v_data_1:=v_click_in_sms;
  v_data_2:=v_click_out_sms;
END;
PROCEDURE CLICKS_19
IS
BEGIN
  v_data_1 := v_click_local;
  v_data_2 := v_click_rl;
END;
PROCEDURE CLICKS_20
IS
BEGIN
  v_data_1:= v_click_ld;
  v_data_2:= v_click_rld;

END;
PROCEDURE CLICKS_21
IS
BEGIN
  v_data_1:=v_home_inbound;
  v_data_2:=v_roam_inound;
  DBMS_OUTPUT.PUT_LINE('CLICK_21');
END;
PROCEDURE CLICKS_22
IS
BEGIN
  v_data_1:=v_click_home_intl;
  v_data_2:=v_click_roam_intl;
  DBMS_OUTPUT.PUT_LINE('CLICK_22');
END;
PROCEDURE CLICKS_23
IS
BEGIN
  v_data_1:=v_click_in_sms;
  v_data_2:=v_click_out_sms;
END;

PROCEDURE LOCAL_SID_32
IS
BEGIN
  v_data_1:=v_local_sid_1;
END;
PROCEDURE LOCAL_SID_33
IS
BEGIN
  v_data_1:=v_local_sid_2;
END;
PROCEDURE LOCAL_SID_34
IS
BEGIN
  v_data_1:=v_local_sid_3;
END;
PROCEDURE LOCAL_SID_35
IS
BEGIN
  v_data_1:=v_local_sid_4;
END;

PROCEDURE RED_MENU_ON
IS
BEGIN
  v_data_2:= 1;
  if v_org_id = 'TRACFONE' then
     v_data_5:=1;
  else
     v_data_5:=0;
  end if;
  v_data_7:=1;
  v_data_8:=1;
END;
PROCEDURE RED_MENU_OFF
IS
BEGIN
  v_data_2:=0;
  v_data_5:=0;
  v_data_7:=1;
  v_data_8:=1;
END;
PROCEDURE MO_ADDRESS
IS
BEGIN
  v_data_9:=v_psms_address;
END;

PROCEDURE MASTER_SID
Is
    Op_Error   Varchar2(4000);
    Op_Message Varchar2(4000);
BEGIN
  Op_Error := 0;
  op_message := 'Transaction Completed Successfully';

  if v_technology = 'GSM' then
     v_data_2:=0;
     v_data_9:=v_min;
  elsif v_technology = 'CDMA' then
     v_data_1 := v_home_sid;
     if v_min = v_msid  then
        v_data_2:=2;
        v_data_9:=v_msid;
     else
        v_data_2:=0;
        V_Data_9:=V_Min;
        INSERT_COMMAND_PARAMETERS(Op_Error,Op_Message);
        v_sequence:=v_sequence + v_seq_update;
        v_data_2:=2;
        v_data_9:=v_msid;
     end if;
  end if;
END;

PROCEDURE MASTER_SID_GSM IS
BEGIN
   MASTER_SID;
END;

PROCEDURE PRL_SID
IS
BEGIN
   v_data_1 := 0;
END;
PROCEDURE PSMS_UNLOCK2
IS
BEGIN
  v_data_1:=1;
END;
PROCEDURE TIME_CODE
IS
BEGIN
  v_data_1:=0;
  v_data_2:=to_number(to_char(v_due_date,'MM'));
  v_data_3:=to_number(to_char(v_due_date,'DD'));
  v_data_4:=to_number(to_char(v_due_date,'YYYY'));
  v_data_5:=0;

END;

PROCEDURE GATEWAY_IP_UPDATE
IS
BEGIN
  v_data_1:=2;
  v_data_2:=v_ip1;
  v_data_3:=v_ip2;
  v_data_4:=v_ip3;
  v_data_5:=v_ip4;
END;
PROCEDURE GATEWAY_PORT_UPDATE
IS
BEGIN
  v_data_1:=4;
  v_data_6:=v_port;
END;
PROCEDURE CLEAR_PROXY
IS
BEGIN
  NULL;
  -- No Parameters required
END;

PROCEDURE CARRIER_DATA_SWITCH
IS
BEGIN
  if upper(v_parent) like '%AT'||'&'||'T%'
     or upper(v_parent) like '%VERIZON%'
     or upper(v_parent) like '%CINGULAR%' then
     v_data_1:=0;
  elsif upper(v_parent) like '%T-MOBILE%'
     or upper(v_parent) like '%ALLTEL%' then
     v_data_1:=1;
  elsif upper(v_parent) like '%CLARO%'
     or upper(v_parent) like '%US CELLULAR%' then
     v_data_1:=2;
  else
     v_data_1:=0;
  end if;
END;
PROCEDURE PROD_SELECTION
IS
BEGIN
  if v_org_id = 'TRACFONE' then
     v_data_1:=0;
  elsif v_org_id = 'NET10' then
     v_data_1:=1;
  elsif v_org_id = 'STRAIGHT_TALK' then
     if v_st_mt = 1 then
       v_data_1:=4;
     else
       v_data_1:=2;
     end if;
  end if;

END;
PROCEDURE PRL
IS
BEGIN
  if  upper(v_parent) like '%VERIZON%' then
     v_data_1:=1;
  elsif upper(v_parent) like '%ALLTEL%' then
     v_data_1:=2;
  elsif upper(v_parent) like '%US CELLULAR%' then
     v_data_1:=3;
  else
     v_data_1:=0;
  end if;
END;
PROCEDURE GPRS_APN
IS
BEGIN
  v_data_1:=3;
  v_data_9:=v_apn;
END;
PROCEDURE GATEWAY_HOME
IS
BEGIN
  v_data_1:=9;
  v_data_9:=v_homepage;
END;
PROCEDURE MMSC_UPDATE
IS
BEGIN
  v_data_1:=6;
  v_data_9:=v_mmsc;
END;
PROCEDURE FREE_611
IS
BEGIN
  v_data_1:=4;
  v_data_3:=0;
  v_data_9:=611;
--  DBMS_OUTPUT.PUT_LINE('FREE_611');
END;
PROCEDURE FREE_1611
IS
BEGIN
  v_data_1:=4;
  v_data_3:=0;
  v_data_9:=1611;
  --DBMS_OUTPUT.PUT_LINE('FREE_1611');
END;
PROCEDURE FREE_DIAL
IS
BEGIN
  v_data_1:=4;
  v_data_3:=0;
  v_data_9:= case
             when TRIM(TO_CHAR(v_free_dial)) like '1%' then substr(TRIM(TO_CHAR(v_free_dial)),2)
             else TRIM(TO_CHAR(v_free_dial))
             end;
  DBMS_OUTPUT.PUT_LINE('FREE_DIAL '||v_data_9);
END;
PROCEDURE FREE_DIAL_1
IS
BEGIN
  v_data_1:=4;
  v_data_3:=0;
  v_data_9 :=
             case
             when TRIM(TO_CHAR(v_free_dial)) like '1%' then TRIM(TO_CHAR(v_free_dial))
             else '1'||TRIM(TO_CHAR(v_free_dial))
             end;
  DBMS_OUTPUT.PUT_LINE('FREE_DIAL '||v_data_9);
END;
PROCEDURE CLEAN_COMMAND_PARAMETERS IS
BEGIN
  v_data_1    := 0;
  v_data_2    := 0;
  v_data_3    := 0;
  v_data_4    := 0;
  v_data_5    := 0;
  v_data_6    := 0;
  v_data_7    := 0;
  v_data_8    := 0;
  v_data_9    :='';
  v_data_10   :=0;
  v_data_11   :='';
END;

PROCEDURE RESTRICTIONS IS
BEGIN
  v_data_1    := v_restrict_callop;
  v_data_2    := v_restrict_intl;
  v_data_3    := v_restrict_LD;
  v_data_4    := v_restrict_roam;
  v_data_5    := v_restrict_inbound;
  v_data_6    := v_restrict_outbound;
  v_data_7    := 0;
END;



PROCEDURE FREE_MT_MMS IS --Command 126
BEGIN
  v_data_1    := '3';
  v_data_4    := 0;
END;

PROCEDURE FREE_MO_MMS IS --Command 126
BEGIN
  v_data_1    := '4';
  v_data_4    := 0;
END;

PROCEDURE FREE_BROWSING IS --Command 128
BEGIN
   --All zeros
   null;

END;



PROCEDURE INSERT_COMMAND_PARAMETERS (
    op_error OUT Varchar2,
    op_message OUT VARCHAR2)
IS

  v_code_temp_objid number;
  str9 varchar2(100);
  str11 varchar2(100);
BEGIN
    Op_Error := 0;
    op_message := 'Transaction Completed Successfully';
    -------------------------------
    --insert_code_hist_temp_record
    -------------------------------
    v_code_temp_objid := sa.seq('x_code_hist_temp');
    insert into sa.table_x_code_hist_temp (objid,x_seq,x_code,x_seq_update,x_type,x_code_temp2x_call_trans)
    values (v_code_temp_objid,to_char(v_sequence),null,v_seq_update,v_pergencode,v_call_trans_objid);
    -----------------------
    -- Insert Code Template
    -----------------------
    insert into sa.adfcrm_gen_code_template(CODE_TEMP_OBJID,INTDLLTOUSE,ESN,SEQUENCE,PHONE_TECHNOLOGY,DLLCODE,
    DATA1,DATA2,DATA3,DATA4,DATA5,DATA6,DATA7,DATA8,DATA9,DATA10,DATA11 ) values
    (v_code_temp_objid,v_dll,v_esn,v_sequence, v_tech_num ,v_dll_cmd,
    v_data_1,v_data_2,v_data_3,v_data_4,v_data_5,v_data_6,v_data_7,v_data_8,v_data_9,v_data_10,v_data_11);

    ------------------------
    -- Prepare OTA Call Stmt
    ------------------------
    if v_send_ota = 1 then

      if v_data_9 is null then
         str9:= 'null';
      else
         str9:=''''||v_data_9||'''';
      end if;
      if v_data_11 is null then
         str11:= 'null';
      else
         str11:=''''||v_data_11||'''';
      end if;

      v_ota_stmt:='select '||to_char(v_sequence-v_orig_sequence)||','||v_dll_cmd||','||v_data_1||','||v_data_2;-- Numeric Parameters
      v_ota_stmt:=v_ota_stmt||','||v_data_3||','||v_data_4||','||v_data_5;-- Numeric Parameters
      v_ota_stmt:=v_ota_stmt||','||v_data_6||','||v_data_7||','||v_data_8;-- Numeric Parameters
      v_ota_stmt:=v_ota_stmt||','||v_data_10||',0'; -- Numeric Parameters
      v_ota_stmt:=v_ota_stmt||','||str9||','||str11;--String Parameters
      v_ota_stmt:=v_ota_stmt||',null ,null ,null ,null ,null ,null ,null ,null from dual';--String Parameters

      IF v_union_flag   = 0 THEN
          v_ota_full_stmt:=v_ota_stmt;
          v_union_flag   := 1;
      ELSE
          v_ota_full_stmt:= v_ota_full_stmt||' union '||v_ota_stmt;
      END IF;

    end if;
  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
END;

PROCEDURE UPDATE_BEFORE_OTA(
    ip_call_trans_objid NUMBER,
    Ip_Cmd_List  VARCHAR2,
    op_Error           out VARCHAR2,
    op_message         out VARCHAR2)
IS
    cursor temp_cur is
    SELECT *
    FROM sa.ADFCRM_PERGENCODES
    WHERE CODE_ID IN
      (SELECT Regexp_Substr(Ip_Cmd_List,'[^,]+', 1, Level)
      FROM Dual
        CONNECT BY Regexp_Substr(Ip_Cmd_List, '[^,]+', 1, Level) IS NOT NULL
      );

    temp_rec temp_cur%rowtype;

    clear_click varchar2(10):='false';
    clear_data varchar2(10):='false';
    clear_611 varchar2(10):='false';
    clear_dial varchar2(10):='false';
BEGIN
    Op_Error := 0;
    op_message := 'Transaction Completed Successfully';
    ------------------------------
    -- Check input parameters --
    ------------------------------
   if ip_call_trans_objid is null
   then
      Op_Error := -400;
      Op_message := TRIM(SUBSTR('ERR-00900: SA.ADFCRM_PERSONALITY_PKG.UPDATE_BEFORE_OTA '||Chr(10)
                         ||'ip_call_trans_objid is missing'
                    ,1,4000));
      return;
   end if;

    for temp_rec in temp_cur loop
       if temp_rec.clears = 'CLICKS' then
          clear_click:='true';
       end if;
       if temp_rec.clears  = 'DATA' then
          clear_data:='true';
       end if;
       if temp_rec.clears = '611' then
           clear_611 := 'true';
       end if;
       if temp_rec.clears = 'FREE_DIAL' then
           clear_dial := 'true';
       end if;
    end loop;

    select x_service_id
    into v_esn
    from sa.table_x_call_trans
    where objid = ip_call_trans_objid;
    v_lid := nvl(sa.adfcrm_safelink.get_lid(ip_esn => v_esn),0);

    ------------------------
    -- CLEAR FLAG LOGIC HERE
    -------------------------
   if clear_dial= 'true' and v_lid != 0 then
      MHEALTH_PROCESS.get_cust_free_dial(ip_esn => v_esn, op_phone => v_free_dial);
   end if;

   if clear_click= 'true' and v_lid != 0 then
      MHEALTH_PROCESS.get_cust_favored_sms(ip_esn => v_esn, op_plan_id => v_plan_objid);
   end if;

   if (clear_611= 'true' or clear_dial= 'true') then
      update sa.table_x_ota_features
      set  x_611_clicks = decode(clear_611,'true',1,x_611_clicks),
           x_free_dial = decode(clear_dial,'true',v_free_dial,x_free_dial)
           --current_config2x_data_config = decode(clear_data,'true',new_config2x_data_config,current_config2x_data_config),
           --new_config2x_data_config = decode(clear_data,'true',null,new_config2x_data_config)
      where x_ota_features2part_inst in (select objid
      from sa.table_part_inst where part_serial_no in (select x_service_id
      from sa.table_x_call_trans where objid = ip_call_trans_objid)
      --and new_config2x_data_config is not null
      and x_domain = 'PHONES');
   end if;
   if clear_click= 'true' then
     update sa.table_site_part
     set SITE_PART2X_NEW_PLAN = decode(v_lid,0,SITE_PART2X_NEW_PLAN,v_plan_objid)
     where x_service_id  in (select x_service_id
     from sa.table_x_call_trans where objid = ip_call_trans_objid)
     and part_status = 'Active';
   end if;
   commit;
  EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     OP_ERROR    := SQLCODE;
     OP_MESSAGE  := TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
END;

END ADFCRM_PERSONALITY_PKG;
/