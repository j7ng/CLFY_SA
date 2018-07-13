CREATE OR REPLACE package body sa.adfcrm_purchase is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_PURCHASE_PKB.sql,v $
--$Revision: 1.11 $
--$Author: mmunoz $
--$Date: 2017/03/17 15:47:34 $
--$ $Log: ADFCRM_PURCHASE_PKB.sql,v $
--$ Revision 1.11  2017/03/17 15:47:34  mmunoz
--$ CR46822 :  removing update for pymt_src2web_user in create_payment_source
--$
--$ Revision 1.10  2017/03/16 21:18:02  mmunoz
--$ CR46822: Adding x_update_date in update for x_payment_source
--$
--$ Revision 1.9  2017/02/23 22:56:05  mmunoz
--$ CR46822 New parameter in create_payment_source
--$
--$ Revision 1.8  2016/08/02 21:51:03  rpednekar
--$ CR41745 - Changed parameter names in call to getcartmetadata and calctax procedures inside calculate_taxes_prc procedure.
--$
--$ Revision 1.7  2016/08/01 22:05:30  mmunoz
--$ CR41745 updated sa.sp_taxes.calctax parameters
--$
--$ Revision 1.6  2016/08/01 19:47:23  mmunoz
--$ CR41745 Updated due the neew signature in getacartmetadata procedure and that output will be input to calctax procedure
--$
--$ Revision 1.5  2015/04/17 18:50:18  hcampano
--$ CR32572 - Changed stored proc calls affected by db signature change
--$
--$ Revision 1.4  2015/02/04 21:50:35  mmunoz
--$ CR30286/29021 Safelink e911 added new parameter in sp_taxes.calctax
--$
--$ Revision 1.3  2014/07/14 18:57:04  mmunoz
--$ added function create_payment_source_ach
--$
--$ Revision 1.2  2014/04/02 19:32:29  mmunoz
--$ CR27269: Updating signature for sa.sp_metadata.getcartmetadata and  sa.sp_taxes.calctax
--$
--$ Revision 1.1  2013/12/06 22:21:30  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------

  function activation_failed(ip_min varchar2,
                                    ip_esn varchar2,
                                    ip_task_objid number,
                                    ip_user varchar2,
                                    ip_call_trans_objid varchar2,
                                    ip_order_type varchar2,
                                    ip_error_code_dd varchar2 -- drop down list
                                    )
  return varchar2
  as
    u_objid number;
    v_user_name varchar2(30);
    v_s_login_name varchar2(30);
    n_line_exists number := 0;
    v_dummy number;
    v_case_objid number;
    v_result boolean;
    v_queue varchar2(100) :='Digital Action Re-Work';
    op_return varchar2(200);
    op_returnmsg varchar2(200);
    v_out_msg varchar2(1000) := null;
  begin

    -- COLLECT USER INFO
    begin
      u_objid := ip_user;
      select login_name,s_login_name
      into   v_user_name,v_s_login_name
      from   table_user
      where  objid = u_objid;
    exception
      when others then
        begin
          select objid,login_name,s_login_name
          into   u_objid,v_user_name,v_s_login_name
          from   table_user
          where  s_login_name = upper(ip_user);
        exception
          when others then
            return 'ERROR - User not found';
        end;
    end;

    if ip_error_code_dd = 'Please Specify' then
      v_out_msg := 'ERROR - Please Select An Error Message';
    end if;

    -- SET ORDER TYPE FLAG (DEFAULT FALSE)
    if ip_order_type = 'Deactivation' or
       ip_order_type = 'Suspend' or
       ip_order_type = 'Return'
    then
      if ip_error_code_dd = 'Non Tracfone #' then
        v_out_msg := 'ERROR - You cannot choose NTN for a '||ip_order_type;
      elsif ip_error_code_dd='RETAIL ESN' then
        v_out_msg := 'ERROR - You cannot choose Retail ESN for a '||ip_order_type;
      else
        v_queue:='Line Management Re-work';
      end if;
    end if;

    if v_out_msg is null then
      -- PROCESS ERROR CODE
      if ip_error_code_dd = 'Non Tracfone #' then
        ----------------------------------------------------------------------------
        -- NON-TRACFONE (deact service, create case and close task)
        ----------------------------------------------------------------------------

        select count(*)
        into   n_line_exists
        from   table_part_inst
        where  part_serial_no = ip_min
        and    x_domain = 'LINES'
        and    x_part_inst_status = '13';

        if n_line_exists = 0 then
          v_out_msg := 'The Line Has Already Been Deactivated';
        else
          service_deactivation.deactservice(ip_sourcesystem => 'APEX',
                                            ip_userobjid => u_objid,
                                            ip_esn => ip_esn,
                                            ip_min => ip_min,
                                            ip_deactreason => 'NON TOPP LINE',
                                            intbypassordertype => 0,
                                            ip_newesn => null,
                                            ip_samemin => null,
                                            op_return => op_return, -- out
                                            op_returnmsg => op_returnmsg -- out
                                            );

          if op_return = 'true' then
            v_out_msg := ' ESN and Line were successfully deactivated';
          else
            v_out_msg := op_returnmsg;
          end if;

          update table_part_inst
          set x_part_inst_status = '60',
              status2x_code_table = (select objid
                                     from table_x_code_table
                                     where x_code_number = 60)
          where part_serial_no = ip_min
          and x_domain = 'LINES';
          commit;

          v_result:= toss_util_pkg.insert_pi_hist_fun(ip_part_serial_no => ip_min,
                                                      ip_domain => 'LINES',
                                                      ip_action => 'NTN',
                                                      ip_prog_caller => 'APEX');

          igate.sp_create_case(p_call_trans_objid => ip_call_trans_objid,
                               p_task_objid => ip_task_objid,
                               p_queue_name => 'Line Activation',
                               p_type => 'Line Activation',
                               p_title => 'Non Tracfone #',
                               p_case_objid => v_case_objid -- out
                               );

          sa.apex_crm_pkg.sp_apex_close_action_item(ip_task_objid,3,v_s_login_name,v_dummy);

          v_out_msg := v_out_msg || chr(10) || ' A Case has been created and sent to the Line Activation Queue for Processing';

        end if;

        update table_task
        set x_task2x_topp_err_codes= (select objid
                                      from   table_x_topp_err_codes
                                      where  x_code_name = 'Non Tracfone #')
        where objid = ip_task_objid;
        commit;

      elsif ip_error_code_dd='RETAIL ESN' then
        --------------------------------------------------------------------------
        -- RETAIL ESN (update status and close task)
        --------------------------------------------------------------------------
        update table_task
        set task_sts2gbst_elm = (select table_gbst_elm.objid
                                 from   table_gbst_elm,
                                        table_gbst_lst
                                 where  table_gbst_elm.title = 'Failed - Retail ESN'
                                 and    gbst_elm2gbst_lst = table_gbst_lst.objid
                                 and    table_gbst_lst.title = 'Closed Action Item')
        where objid = ip_task_objid;
        commit;

        sa.igate.sp_close_action_item(ip_task_objid,2,v_dummy);

       if v_dummy = 1 then
          v_out_msg := 'Task is already closed';
        else
          v_out_msg := v_dummy;
       end if;

      else
        --------------------------------------------------------------------------
        -- ALL OTHERS  (update status and dispatch task)
        --------------------------------------------------------------------------
        update table_task
        set task_sts2gbst_elm = (select table_gbst_elm.objid
                                 from table_gbst_elm,table_gbst_lst
                                 where table_gbst_elm.title = 'Failed - Open'
                                 and gbst_elm2gbst_lst = table_gbst_lst.objid
                                 and table_gbst_lst.title = 'Open Action Item')
        where objid = ip_task_objid;
        commit;

        igate.sp_dispatch_task(p_task_objid => ip_task_objid,
                               p_queue_name => v_queue,
                               p_dummy_out => v_dummy);

        v_out_msg := 'The Action Item Has Been Sent To '||v_queue;

      end if;
    end if;

    return v_out_msg;

  end activation_failed;
  --------------------------------------------------------------------------------------------
  function activation_successful(ip_min varchar2,
                                        ip_esn varchar2,
                                        ip_technology varchar2,
                                        ip_task_id varchar2,
                                        ip_task_objid number,
                                        ip_status varchar2,
                                        ip_user varchar2,
                                        ip_call_trans_objid varchar2,
                                        ip_order_type varchar2,
                                        ip_carrier_objid number) return varchar2
  as
    u_objid number;
    v_user_name varchar2(30);
    v_s_login_name varchar2(30);

    v_status_code varchar2(100);
    v_task_objid number := 0;
    v_task_id varchar2(30);

    v_case_queue varchar2(30);
    v_order_type varchar2(30);
    v_port_status varchar2(30);
    v_notes varchar2(500);
    v_dispatch_action_item boolean := false;

    v_order_type_objid number;
    v_black_out_code number;
    v_destination_queue varchar2(30);

    v_status varchar2(100);
    v_message varchar2(100);
    v_error_no varchar2(100);
    v_error_str varchar2(100);
    v_dummy varchar2(100);

    cursor port_case_cur is
      select table_case.objid,
             table_case.id_number
      from   table_case,
             table_condition
      where  x_esn = ip_esn
      and    x_min = ip_min
      and    x_case_type = 'Port In'
      and    case_state2condition = table_condition.objid
      and    table_condition.title like 'Open%';

  begin
    -- COLLECT USER INFO
    begin
      u_objid := ip_user;
      select login_name,s_login_name
      into   v_user_name,v_s_login_name
      from   table_user
      where  objid = u_objid;
    exception
      when others then
        begin
          select objid,login_name
          into   u_objid,v_user_name
          from   table_user
          where  s_login_name = upper(ip_user);
        exception
          when others then
            return 'User not found';
        end;
    end;

    if ip_status = 'Succeeded' then
      return 'Action Item Already Completed';
    end if;

    -- UPDATE TASK
    update table_task
    set x_task2x_topp_err_codes = null
    where objid = ip_task_objid;

    -- CLOSE ACTION ITEM
    sa.apex_crm_pkg.sp_apex_close_action_item(ip_task_objid,
                                              0,
                                              v_s_login_name,
                                              v_dummy -- out
                                              );

    for port_case_rec in port_case_cur loop

      if ip_order_type = 'Internal Port In' then
        v_case_queue:='Internal Port Approval';
        v_order_type := 'Int Port Approval';
        v_port_status :='To be Authorized';
        v_notes:='Internal Port Approval Action item: '||ip_task_id;
        v_notes:=v_notes|| Chr(10) || Chr(13) ||'closed sucessfully.';
        v_notes:=v_notes||Chr(10) || Chr(13) || 'Sent for Port Approval Action item: ';
        v_dispatch_action_item:=true;
      end if;

      if ip_order_type = 'Int Port Approval' then
        v_case_queue:='Internal Port Status';
        v_order_type := 'Internal Port Status';
        v_port_status :='Approved OSP';
        v_notes:='Internal Port Approval Action item: '||ip_task_id;
        v_notes:=v_notes|| Chr(10) || Chr(13) ||'closed sucessfully.';
        v_notes:=v_notes||Chr(10) || Chr(13) || 'Sent for Port Status Action item: ';
        v_dispatch_action_item:=true;
      end if;

      if ip_order_type = 'Internal Port Status' then
        v_port_status:= 'Port Successful';
        v_notes:='Internal Port Approval Action item: '||ip_task_id;
        v_notes:=v_notes|| Chr(10) || Chr(13) ||'closed sucessfully.';

        igate.sp_close_case(p_case_id => port_case_rec.id_number,
                            p_user_login_name => v_s_login_name,
                            p_source => 'APEX',
                            p_resolution_code => 'Resolution Given',
                            p_status => v_status, -- out
                            p_msg => v_message -- out
                            );
      end if;

      -- DISPATCH (Internal Port In AND Int Port Approval) ORDER TYPES
      if v_dispatch_action_item then
        sa.igate.sp_dispatch_case(port_case_rec.objid,
                                  v_case_queue,
                                  v_dummy -- out
                                  );

        sa.igate.sp_create_action_item(p_contact_objid => u_objid,
                                       p_call_trans_objid => ip_call_trans_objid,
                                       p_order_type => v_order_type,
                                       p_bypass_order_type => 1,
                                       p_case_code => 0,
                                       p_status_code => v_status_code, -- out
                                       p_action_item_objid => v_task_objid -- out
                                       );

        if v_task_objid >0 then

          select task_id
          into v_task_id
          from table_task
          where objid = v_task_objid;

          v_notes:=v_notes||v_task_id;

          update table_case
          set case_type_lvl3 = v_port_status,
              x_case2task = v_task_objid
          where objid = port_case_rec.objid;

          commit;

          clarify_case_pkg.log_notes(p_case_objid => port_case_rec.objid,
                                     p_user_objid => u_objid,
                                     p_notes => v_notes,
                                     p_action_type => 'Action Item',
                                     p_error_no => v_error_no,
                                     p_error_str => v_error_str);

          igate.sp_get_ordertype(p_min => ip_min,
                                 p_order_type => v_order_type,
                                 p_carrier_objid => ip_carrier_objid,
                                 p_technology => ip_technology,
                                 p_order_type_objid => v_order_type_objid -- out v_order_type_objid
                                 );

          igate.sp_check_blackout(p_task_objid => v_task_objid,
                                  p_order_type_objid => v_order_type_objid, -- in v_order_type_objid
                                  p_black_out_code => v_black_out_code -- out
                                  );

          if v_black_out_code = 0 then
            igate.sp_determine_trans_method(p_action_item_objid => v_task_objid,
                                            p_order_type => v_order_type,
                                            p_trans_method => '',
                                            p_destination_queue => v_destination_queue, -- out
                                            p_application_system => 'APEX');
          elsif v_black_out_code = 1 then
            igate.sp_dispatch_task(v_task_objid,
                                   'BlackOut',
                                   v_dummy -- out
                                   );
          else
            igate.sp_dispatch_task(v_task_objid,
                                   'Line Management Re-work',
                                   v_dummy -- out
                                   );
          end if;
        end if;
      end if;
    end loop;

    return 'Action Item Completed';

  end activation_successful;
  --------------------------------------------------------------------------------------------
  procedure calculate_taxes_prc (ip_zipcode          in varchar2,
                                        ip_partnumbers      in varchar2,
                                        ip_esn              in varchar2,
                                        ip_cc_id            in number, --Credit Card objid
                                        ip_promo            in varchar2,
                                        ip_brand_name       in varchar2,
                                        ip_transaction_type in varchar2, --'ACTIVATION', 'REACTIVATION','REDEMPTION','PURCHASE', 'PROMOENROLLMENT'
                                        op_combstaxamt     out number,
                                        op_e911amt         out number,
                                        op_usfamt          out number,
                                        op_rcrfamt         out number,
                                        op_subtotalamount  out number,
                                        op_totaltaxamount  out number,
                                        op_totalcharges    out number,
                                        op_combstaxrate    out number,
                                        op_e911rate        out number,
                                        op_usfrate         out number,
                                        op_rcrfrate        out number,
                                        op_result          out number,
                                        op_msg             out varchar2)
  is
    ip_purchaseamt number;
    ip_airtimeamt number;
    ip_warrantyamt number;
    ip_dataonly number; --CR26033/ CR26274
    ip_totaldiscountamt number;
    ip_txtonlyamt number;
    p_tota_pn number;
    p_tota_air number;
    op_count number;
    v_promo varchar2(40);
    v_fp_discount number:=0;  --Monetary Discount
    v_fp_count number:=0;  --Previously Enrolled ESNs in Family Plan
    v_fp_flag boolean:=false;
    v_total_discount number:=0;
    v_sourcesystem varchar2(10);
    p_model_type varchar2(4000);
    p_tot_model_type number;
    op_salestaxonly_b_amt number;
    op_salestaxonly_a_amt number;
    op_activation_chrg_b_amt number;
    op_activation_chrg_a_amt number;
    ip_servicedaysonly_amt number;
    ip_nac_activation_chrg number;
  begin

    begin
       select x_param_value
       into v_sourcesystem
       from table_x_parameters
       where x_param_name = 'ADFCRM_SOURCE_SYSTEM';

       exception
          when others then
          v_sourcesystem:='WEBCSR';
    end;

    begin

    if substr(ip_promo,1,7) = 'NTUNLFM' then
      v_fp_count:= nvl(to_number(substr(ip_promo,8)),0);
      v_promo:=null;
      v_fp_flag:=true;
    else
       v_promo:= ip_promo;
    end if;

    exception
       when others then
            v_promo:= ip_promo;
    end;

    sa.sp_metadata.getcartmetadata(
      p_partnumbers => ip_partnumbers,
      p_promos => v_promo,
      v_esn => ip_esn,
      p_cc_id => ip_cc_id,
      p_source => v_sourcesystem,
      p_type => ip_transaction_type,
      p_brand_name => ip_brand_name,
      p_itemprice => null,
      p_totb_pn => ip_purchaseamt,        --IP_PURCHASEAMT
      p_tota_pn => p_tota_pn,
      p_totb_air => ip_airtimeamt,        --IP_AIRTIMEAMT
      p_tota_air => p_tota_air,
      p_totb_wty => ip_warrantyamt,       --IP_WARRANTYAMT
      p_totb_dta => ip_dataonly,  --CR26033 / CR26274
      p_totb_txt => ip_txtonlyamt, -- CR32572
      P_TOT_MODEL_TYPE => p_tot_model_type, --CR27269 -- CR27270 (alert car)
      P_MODEL_TYPE => p_model_type, --CR27269 -- CR27270 (alert car)
      p_tot_disc => ip_totaldiscountamt,  --IP_TOTALDISCOUNTAMT
      op_count => op_count,
      op_result => op_result,
      op_msg => op_msg,
      op_salestaxonly_b_amt => op_salestaxonly_b_amt,
      op_salestaxonly_a_amt => op_salestaxonly_a_amt,
      op_activation_chrg_b_amt => op_activation_chrg_b_amt,
      op_activation_chrg_a_amt => op_activation_chrg_a_amt
    );
    if op_result = 0
    then

    if v_fp_flag then
       if v_fp_count = 0 then
          v_total_discount := (nvl(op_count,0)-1)*10+5;
       else
          v_total_discount := nvl(op_count,0)*10;
       end if;

    else
       v_total_discount := ip_totaldiscountamt;
    end if;

    sa.sp_taxes.calctax(
      ip_zipcode => ip_zipcode,
      ip_purchaseamt => ip_purchaseamt,
      ip_airtimeamt => ip_airtimeamt,
      ip_warrantyamt => ip_warrantyamt,
      ip_dataonlyamt => ip_dataonly, --CR26033/ CR26274
      ip_txtonlyamt => ip_txtonlyamt, -- CR32572
      IP_shipamt =>  0, -- CR27857 to be decided
      IP_MODEL_TYPE => p_model_type,
      IP_tot_model_type => p_tot_model_type,
      ip_totaldiscountamt => v_total_discount,
      ip_language => null,
      ip_source => v_sourcesystem,
      ip_country => null,
      op_combstaxamt => op_combstaxamt,
      op_e911amt => op_e911amt,
      op_usfamt => op_usfamt,
      op_rcrfamt => op_rcrfamt,
      op_subtotalamount => op_subtotalamount,
      op_totaltaxamount => op_totaltaxamount,
      op_totalcharges => op_totalcharges,
      op_result => op_result,
      op_combstaxrate => op_combstaxrate,
      op_e911rate => op_e911rate,
      op_usfrate => op_usfrate,
      op_rcrfrate => op_rcrfrate,
      op_msg => op_msg,
      ip_partnumbers => ip_partnumbers,
      ip_salestaxonly_amt => nvl(op_salestaxonly_b_amt,0),
      ip_nac_activation_chrg => nvl(op_activation_chrg_b_amt,0)
    );
   end if;

  /**
  DBMS_OUTPUT.PUT_LINE('OP_COMBSTAXAMT = ' || OP_COMBSTAXAMT);
  DBMS_OUTPUT.PUT_LINE('OP_E911AMT = ' || OP_E911AMT);
  DBMS_OUTPUT.PUT_LINE('OP_USFAMT = ' || OP_USFAMT);
  DBMS_OUTPUT.PUT_LINE('OP_RCRFAMT = ' || OP_RCRFAMT);
  DBMS_OUTPUT.PUT_LINE('OP_SUBTOTALAMOUNT = ' || OP_SUBTOTALAMOUNT);
  DBMS_OUTPUT.PUT_LINE('OP_TOTALTAXAMOUNT = ' || OP_TOTALTAXAMOUNT);
  DBMS_OUTPUT.PUT_LINE('OP_TOTALCHARGES = ' || OP_TOTALCHARGES);
  DBMS_OUTPUT.PUT_LINE('OP_COMBSTAXRATE = ' || OP_COMBSTAXRATE);
  DBMS_OUTPUT.PUT_LINE('OP_E911RATE = ' || OP_E911RATE);
  DBMS_OUTPUT.PUT_LINE('OP_USFRATE = ' || OP_USFRATE);
  DBMS_OUTPUT.PUT_LINE('OP_RCRFRATE = ' || OP_RCRFRATE);
  DBMS_OUTPUT.PUT_LINE('OP_RESULT = ' || OP_RESULT);
  DBMS_OUTPUT.PUT_LINE('OP_MSG = ' || OP_MSG);
  **/

  end calculate_taxes_prc;
  --------------------------------------------------------------------------------------------
  function create_payment_source (p_cc_objid in varchar2,
                                  p_web_user_objid in varchar2,
                                  p_link_to_web_user in varchar2 DEFAULT 'Y') return varchar2
  as
    cursor c1 is
    select objid
    from sa.x_payment_source
    where pymt_src2x_credit_card = p_cc_objid
     and  pymt_src2web_user = p_web_user_objid
     and x_status = 'ACTIVE';

    r1 c1%rowtype;

    cursor c2 is
      select cc.*
      from sa.table_x_credit_card cc
      where  cc.objid = p_cc_objid;

    r2 c2%rowtype;

    cursor c3 is
    select objid
    from sa.table_web_user
    where objid = p_web_user_objid;

    r3 c3%rowtype;

    result_str varchar2(30):=null;
    ps_objid number;

  begin
    open c1;
    fetch c1 into r1;

    if c1%found then
       update sa.x_payment_source
       set x_update_date = sysdate
       where objid = r1.objid;
       result_str:= r1.objid;
    else
       open c2;
       fetch c2 into r2;
       if c2%found then
          open c3;
          fetch c3 into r3;
          if c3%found then
            select sa.seq_x_payment_source.nextval into ps_objid  from dual;

            insert
            into sa.x_payment_source (
                objid,
                x_pymt_type,
                x_pymt_src_name,
                x_status,
                x_is_default,
                x_insert_date,
                x_update_date,
                x_sourcesystem,
                x_changedby,
                pymt_src2web_user,
                pymt_src2x_credit_card,
                pymt_src2x_bank_account,
                x_billing_email
              )
              values
              (
                ps_objid,
                'CREDITCARD',
                r2.x_cc_type||'_'||substr(r2.x_customer_cc_number,-4),
                'ACTIVE',
                null,
                sysdate,
                sysdate,
                'WEBCSR',
                null,
                decode(p_link_to_web_user, 'N', null, p_web_user_objid),
                p_cc_objid,
                null,
                null
              );


              result_str:= ps_objid;
         end if;  --valid p_web_user_objid
       end if;  --valid p_cc_objid
       close c2;
    end if;
    close c1;
    commit;
    return result_str;

  end create_payment_source;
  --------------------------------------------------------------------------------------------
  function create_payment_source_ach(p_ach_objid in varchar2,
                                     p_web_user_objid in varchar2) return varchar2
  as
    cursor c1 is
    select objid
    from sa.x_payment_source
    where pymt_src2x_bank_account = p_ach_objid
     and  pymt_src2web_user = p_web_user_objid
     and x_status = 'ACTIVE';

    r1 c1%rowtype;

    cursor c2 is
      select ach.*
      from sa.table_x_bank_account ach
      where  ach.objid = p_ach_objid;

    r2 c2%rowtype;

    cursor c3 is
    select objid
    from sa.table_web_user
    where objid = p_web_user_objid;

    r3 c3%rowtype;

    result_str varchar2(30):=null;
    ps_objid number;

  begin
    open c1;
    fetch c1 into r1;

    if c1%found then
       result_str:= r1.objid;
    else
       open c2;
       fetch c2 into r2;
       if c2%found then
          open c3;
          fetch c3 into r3;
          if c3%found then
            select sa.seq_x_payment_source.nextval into ps_objid  from dual;

            insert
            into sa.x_payment_source (
                objid,
                x_pymt_type,
                x_pymt_src_name,
                x_status,
                x_is_default,
                x_insert_date,
                x_update_date,
                x_sourcesystem,
                x_changedby,
                pymt_src2web_user,
                pymt_src2x_credit_card,
                pymt_src2x_bank_account,
                x_billing_email
              )
              values
              (
                ps_objid,
                'ACH',
                r2.x_aba_transit,
                'ACTIVE',
                null,
                sysdate,
                sysdate,
                'WEBCSR',
                null,
                p_web_user_objid,
                null,
                p_ach_objid,
                null
              );

              commit;
              result_str:= ps_objid;
         end if;  --valid p_web_user_objid
       end if;  --valid p_cc_objid
       close c2;
    end if;
    close c1;

    return result_str;

  end create_payment_source_ach;
--------------------------------------------------------------------------------------------
end adfcrm_purchase;
/