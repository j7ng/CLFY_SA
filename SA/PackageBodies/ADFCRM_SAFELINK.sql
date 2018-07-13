CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_SAFELINK" is
--------------------------------------------------------------------------------------------
--$RCSfile: CR####.sql,v $
--$Revision: 1.5 $
--$Author: userId $
--$Date: 2011/12/12 19:09:44 $
--$ $Log: CR####.sql,v $
--------------------------------------------------------------------------------------------

    cursor get_esn_info (p_esn in varchar2) is
        select
            pi.part_serial_no,
            pi.objid,
            pi.x_part_inst2contact,
            pn.x_manufacturer,
            pn.part_number,
            Pi.Warr_End_Date,
            bo.org_id,
            pc.name part_class_name,
            pc.objid part_class_objid,
			pi.x_part_inst_status, --CR35135
			pn.part_num2bus_org  --CR35135
        from
             sa.table_part_inst           pi
            ,sa.TABLE_MOD_LEVEL           ML
            ,sa.TABLE_PART_NUM            PN
            ,sa.TABLE_BUS_ORG             BO
            ,sa.table_part_class          pc
        where pi.part_serial_no = p_esn
        and pi.x_domain = 'PHONES'
        and ml.objid = pi.n_part_inst2part_mod
        AND PN.OBJID = ML.PART_INFO2PART_NUM
        and bo.objid = pn.part_num2bus_org
        and pc.objid = pn.part_num2part_class;

/***************************************************************/
--CR35135	Attach ESN to Safelink ID in TAS
	cursor get_subs_info (p_lid in number) is
        select sl.lid, wu.web_user2bus_org
		from sa.x_sl_subs sl, sa.table_web_user wu
		where sl.lid = p_lid
		and wu.objid = sl.sl_subs2web_user;

---------------------------------------------------------------------------
  function get_lid(ip_esn varchar2) return number
  is
    v_lid x_sl_subs.lid%type;
  begin
    select lid into v_lid from x_sl_currentvals where x_current_esn = ip_esn;
    -- and x_current_active = 'Y' and x_current_enrolled ='Y'; REMOVED VALIDATION BASED OFF GONZALO'S EMAIL 8.25.14
    return v_lid;
  exception
    when too_many_rows then
       begin
         select lid into v_lid from x_sl_currentvals where x_current_esn = ip_esn and x_current_enrolled ='Y';
         return v_lid;
       exception
         when others then
              return null;
       end;
    when others then
      return null;
  end get_lid;
---------------------------------------------------------------------------
  function get_lid(ip_table varchar2, ip_esn varchar2) return number
  is
    v_lid x_sl_subs.lid%type;
  begin
    if ip_table = 'x_sl_hist' then
       select lid into v_lid from (select lid from sa.x_sl_hist where x_esn = ip_esn order by x_insert_dt desc)
       where rownum < 2;
    end if;
    return v_lid;
  exception
    when others then
      return null;
  end get_lid;
---------------------------------------------------------------------------
  function get_lid(ip_contact_objid varchar2, ip_wu_objid varchar2, ip_cust_id varchar2) return number
  is
    v_lid x_sl_subs.lid%type;
  begin
    for i in (Select Part_Serial_No,nvl(Cpi.x_is_default,0) primary
              From
              sa.Table_Web_User wu,
              sa.Table_X_Contact_Part_Inst Cpi,
              sa.Table_Contact C,
              sa.Table_Part_Inst Pi,
              sa.Table_Mod_Level Ml,
              sa.Table_Part_Num Pn,
              sa.table_bus_org bo,
              sa.table_x_code_table ct
              where wu.objid =  ip_wu_objid --:web_user_objid
              And Cpi.X_Contact_Part_Inst2contact = Wu.Web_User2contact
              And Cpi.X_Contact_Part_Inst2part_Inst= Pi.Objid
              and Pi.X_Part_Inst2contact = c.objid (+)
              And Pi.N_Part_Inst2part_Mod=Ml.Objid
              And Ml.Part_Info2part_Num=Pn.Objid
              And Pn.Part_Num2bus_Org=Bo.Objid
              And Ct.X_Code_Number=Pi.X_Part_Inst_Status
              Union
              Select Part_Serial_No,nvl(cpi2.x_is_default,0) primary
              From
              sa.Table_Contact C,
              sa.Table_Part_Inst Pi,
              sa.Table_Mod_Level Ml,
              sa.Table_Part_Num Pn,
              sa.Table_Bus_Org Bo,
              sa.table_x_code_table ct,
              sa.table_x_contact_part_inst cpi2,
              sa.table_contact c2,
              sa.table_web_user wu2
              where (pi.x_part_inst2contact  = ip_contact_objid --:contact_objid
              or  pi.x_part_inst2contact  = (select objid from table_contact where x_cust_id = ip_cust_id))
              and Pi.X_Part_Inst2contact = c.objid
              And Pi.N_Part_Inst2part_Mod=Ml.Objid
              And Ml.Part_Info2part_Num=Pn.Objid
              And Pn.Part_Num2bus_Org=Bo.Objid
              And Ct.X_Code_Number=Pi.X_Part_Inst_Status
              And Pi.Objid Not In (Select cpi3.X_CONTACT_PART_INST2PART_INST From sa.Table_X_Contact_Part_Inst cpi3,sa.table_web_user wu3
              where cpi3.x_contact_part_inst2contact = wu3.web_user2contact
              and wu3.objid = ip_wu_objid) --:web_user_objid)
              and pi.objid = cpi2.x_contact_part_inst2part_inst (+)
              and cpi2.x_contact_part_inst2contact=c2.objid (+)
              and c2.objid = wu2.web_user2contact (+))
      loop
          v_lid := get_lid(ip_esn =>i.part_serial_no);
        if v_lid is not null then
          dbms_output.put_line('using lid: '||v_lid);
          return v_lid;
        end if;
      end loop;
    return v_lid;
  exception
    when others then
      return null;
  end get_lid;
--------------------------------------------------------------------------------
  procedure service_history(ip_search_field varchar2,
                            ip_search_value varchar2,
                            ip_recordset out sys_refcursor)
  is
    sqlstr varchar2(4000);
    srch_criteria varchar2(100);
    lid_from_esn number;
  begin
    if upper(ip_search_field) = 'LID' then
      srch_criteria := 'and   h.lid = '||ip_search_value;
    elsif upper(ip_search_field) = 'ESN' then
      lid_from_esn := get_lid(ip_esn =>ip_search_value);
      if lid_from_esn is null then
        lid_from_esn := '-100';
      end if;
      -- REMOVED ESN VALUE PER GONZALO 8.27.14
      srch_criteria := 'and   h.lid = '|| lid_from_esn;
    else
      lid_from_esn := '-100';
    end if;

    if ip_search_value is null or
       ip_search_value = '' or
       lid_from_esn = -100 then
      sqlstr := 'select null x_event_dt, null x_esn, null lid, null event_desc, null prog_name, null prog_minutes, null x_sourcesystem, null status_desc, null x_event_data from dual where rownum <1';
    else
      sqlstr := ' select h.x_event_dt,
                         decode(h.x_esn,''-1'',null,h.x_esn) x_esn,
                         h.lid,
                         c.x_code_name as event_desc,
                         case h.x_src_table when ''x_program_enrolled'' then pp.x_program_name else '''' end as prog_name,
                         nvl(case h.x_src_table when ''x_program_enrolled'' then ''''||pr.x_units else null end,
                         case h.x_src_table when ''x_program_gencode'' then ''''||ct.x_total_units else '''' end) as prog_minutes,
                         h.x_sourcesystem,
                         case nvl(h.x_code_number,''.'') when ''0'' then '''' when ''700'' then ''-'' else h.x_code_number end as status_desc,
                         decode(h.x_event_value,null,null,h.x_event_value||''/'')||h.x_event_data
                  from   x_sl_hist h,
                         table_x_code_table c,
                         x_program_parameters pp,
                         x_program_enrolled pe,
                         table_x_promotion pr,
                         x_program_gencode pg,
                         table_x_call_trans ct
                  where  1=1
                  '||srch_criteria||'
                  and    h.x_event_code = c.x_code_number
                  and    c.x_code_type=''SL''
                  and    h.x_src_objid = pe.objid(+)
                  and    pe.pgm_enroll2pgm_parameter = pp.objid(+)
                  and    h.x_src_objid = pg.objid(+)
                  and    pg.gencode2call_trans = ct.objid(+)
                  and    pp.x_promo_incl_min_at = pr.objid(+)
                  order by x_event_dt desc ';
    end if;

    dbms_output.put_line(sqlstr);

    open ip_recordset for sqlstr;

  exception
    when others then
      null;
  end service_history;
--------------------------------------------------------------------------------
  function service_history(ip_search_field varchar2,
                           ip_search_value varchar2)
  return service_history_tab
  pipelined
  is
    rc sys_refcursor;
  begin
    service_history(ip_search_field => ip_search_field,
                    ip_search_value => ip_search_value,
                    ip_recordset => rc);
    loop
      fetch rc into service_history_rslt;
      exit when rc%notfound;
      pipe row(service_history_rslt);
    end loop;
  end service_history;
--------------------------------------------------------------------------------
 function ret_info(ip_esn varchar2)
  return adfcrm_esn_structure
  is
    esn_tab  sa.adfcrm_esn_structure := sa.adfcrm_esn_structure();
    v_lid   sa.x_sl_subs.lid%type;
  begin
    --lid := sa.adfcrm_safelink.get_lid(ip_table => 'x_sl_hist', ip_esn => ip_esn);
    v_lid := sa.adfcrm_safelink.get_lid(ip_esn => ip_esn);
    for i in (select pe.x_enrollment_status,
                     s.x_requested_plan x_program_name, cv.x_current_enrolled, cv.x_deenroll_reason,
                     (select df.x_description
                      from sa.x_sl_deenroll_flag df
                      where cv.x_deenroll_reason like (case
                                         when regexp_like(df.x_deenroll_flag,'^[0-9]*$')  --if number
                                         then (trim(df.x_bill_flag)||trim(to_char(trim(df.x_deenroll_flag),'00')))||'%'
                                         else (trim(df.x_bill_flag)||trim(df.x_deenroll_flag))||'%'
                                         end)
                      and rownum < 2
                      ) x_description,
                      s.X_AV_DUE_DATE verification_due_date,
                      s.X_LAST_AV_DATE latest_verify_date,
                      case
                      when (select count(*)
                            from sa.xsu_vmbc_request  xs
                            where lid = to_char(nvl(v_lid,0))
                            and TO_DATE(BATCHDATE,'DD-MON-YY HH24:MI:SS') >=
                                case
                                when to_char(sysdate,'dd') >= 26 then to_date('26-'||trim(to_char(sysdate,'mm-yyyy')),'dd-mm-yyyy')
                                else to_date('26-'||trim(to_char(add_months(sysdate,-1),'mm-yyyy')),'dd-mm-yyyy')
                                end
                            and TO_DATE(BATCHDATE,'DD-MON-YY HH24:MI:SS') <
                                case
                                when to_char(sysdate,'dd') >= 26 then add_months(to_date('26-'||trim(to_char(sysdate,'mm-yyyy')),'dd-mm-yyyy'),1)
                                else to_date('26-'||trim(to_char(sysdate,'mm-yyyy')),'dd-mm-yyyy')
                                end
                            and REQUESTTYPE = 'ProgramChange') > 0
                       then     case
                                when to_char(sysdate,'dd') >= 26 then add_months(to_date('26-'||trim(to_char(sysdate,'mm-yyyy')),'dd-mm-yyyy'),1)
                                else to_date('26-'||trim(to_char(sysdate,'mm-yyyy')),'dd-mm-yyyy')
                                end
                       else null
                       end new_plan_effective_date,
                       trim(to_char(pe.x_next_delivery_date,'mm/dd/yyyy')) x_next_delivery_date
--null new_plan_effective_date,
--null x_next_delivery_date
             from (select pe.x_enrollment_status, pp.x_program_name, dense_rank() over(partition by pe.x_esn order by decode(pe.x_enrollment_status,'ENROLLED',1,'READYTOREENROLL',2,3), pe.x_insert_date desc) x_rank
                          ,pe.x_next_delivery_date
                      from x_program_enrolled pe,
                           x_program_parameters pp
                      where 1=1
                      and pe.x_esn = ip_esn
                      and pe.x_sourcesystem = 'VMBC'
                      and pp.x_prog_class = 'LIFELINE'
                      and pe.pgm_enroll2pgm_parameter = pp.objid) pe,
                      sa.x_sl_currentvals cv,
                      sa.x_sl_subs s
              where x_rank = 1
              and cv.lid  = nvl(v_lid,0)
              and cv.x_current_esn (+) = ip_esn
              and s.lid = nvl(v_lid,0)
              )
    loop
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('x_enrollment_status', i.x_enrollment_status);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('x_program_name', i.x_program_name);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('x_current_enrolled', i.x_current_enrolled);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('x_deenroll_reason', i.x_deenroll_reason);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('lifeline_status', i.x_description);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('verification_due_date', i.verification_due_date);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('latest_verify_date', i.latest_verify_date);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('new_plan_effective_date', i.new_plan_effective_date);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('next_delivery_date', i.x_next_delivery_date);
    end loop;
    esn_tab.extend;
    --CR29505 Sl Imp. code commented, the esn in section can not be the latest associated with the lid so it is not in the currenval table.
    --esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('lid', sa.adfcrm_safelink.get_lid(ip_esn => ip_esn));
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('lid', v_lid);
    return esn_tab;
  end ret_info;
--------------------------------------------------------------------------------
 function get_slEsn_Enrolled(ip_lid varchar2)
  return adfcrm_esn_structure
 is
   esn_tab  sa.adfcrm_esn_structure := sa.adfcrm_esn_structure();
 begin
    for i in
           (select pe.objid enroll_objid, pe.x_esn, p.objid program_objid, pe.x_enrollment_status
            --from  x_sl_hist slh,
            from  x_sl_currentvals cv,
                  x_program_enrolled pe,
                  x_program_parameters p
            --where slh.lid = ip_lid
            --and pe.x_esn = slh.x_esn
            where cv.lid = ip_lid
            and pe.x_esn = cv.x_current_esn
            and pe.x_enrollment_status = 'ENROLLED'
            and p.objid = pe.pgm_enroll2pgm_parameter
            and p.x_prog_class = 'LIFELINE'
            and rownum < 2)
    loop
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('esn', i.x_esn);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('enrollment_status', i.x_enrollment_status);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('enroll_objid', i.enroll_objid);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('program_objid', i.program_objid);
    end loop;
    return esn_tab;
  end get_slEsn_Enrolled;
--------------------------------------------------------------------------------
 function get_Enroll_record(ip_esn varchar2)
  return adfcrm_esn_structure
 is
   esn_tab  sa.adfcrm_esn_structure := sa.adfcrm_esn_structure();
 begin
    for i in  --Grab auto-refill programs no safelink
           (select pe.objid enroll_objid, pe.x_esn,
                   pe.pgm_enroll2web_user, pe.pgm_enroll2contact,
                   p.objid program_objid, pe.x_enrollment_status,
                   (select org_id from table_bus_org where objid = p.prog_param2bus_org) brand_name
            from  x_program_enrolled pe,
                  x_program_parameters p
            where pe.x_esn = ip_esn
            and pe.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
            and p.objid = pe.pgm_enroll2pgm_parameter
            and nvl(p.x_prog_class,'###') not in ('LIFELINE','HMO','WARRANTY')
            and rownum < 2)
    loop
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('esn', i.x_esn);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('web_user_id', i.pgm_enroll2web_user);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('enroll_objid', i.enroll_objid);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('contact_objid', i.pgm_enroll2contact);
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('brand_name', i.brand_name);
    end loop;
    return esn_tab;
  end get_Enroll_record;
--------------------------------------------------------------------------------
 procedure validateSlEsn(
  ip_esn in varchar2,
  ip_min in varchar2,
  ip_lid in varchar2,
  ip_web_user_id varchar2,
  ip_action varchar2,
  ip_org_id varchar2,
  op_error_no out varchar2,
  op_error_msg out varchar2)
 is
   cursor get_sitepart_info (ip_esn varchar2) is
      select sp.part_status, sp.x_min, sp.x_service_id
      from table_site_part sp
      where sp.x_service_id = ip_esn
      order by sp.install_date desc;

   cursor get_sitepart2_info (ip_min varchar2) is
      select sp.part_status, sp.x_min, sp.x_service_id
      from table_site_part sp
      where sp.x_min = ip_min
      order by sp.install_date desc;
   get_sitepart_rec get_sitepart_info%rowtype;

   cursor get_esn_info_acct (ip_esn in table_part_inst.part_serial_no%type) is
        select
             pi.objid,
             web.objid web_user_objid
        from table_part_inst pi,
             table_x_contact_part_inst conpi,
             table_web_user web
        where pi.part_serial_no = ip_esn
        and   pi.x_domain = 'PHONES'
        and   conpi.x_contact_part_inst2part_inst (+) = pi.objid
        and   web.web_user2contact (+) = conpi.x_contact_part_inst2contact;
   get_esn_info_acct_rec  get_esn_info_acct%rowtype;

   get_esn_info_rec  get_esn_info%rowtype;
   cnt  number := 0;
   v_esn_lid number;
 begin
   op_error_no := '0';
   op_error_msg := 'Transaction executed successfully.';

   if ip_esn is null or ip_min is null then
         op_error_no := '-1001';
         op_error_msg := 'ESN and MIN must be provided.';
         return;
   end if;

   if ip_esn is not null then
      open  get_sitepart_info(ip_esn);
      fetch get_sitepart_info into get_sitepart_rec;
      close  get_sitepart_info;
   elsif ip_min is not null then
      open  get_sitepart2_info(ip_min);
      fetch get_sitepart2_info into get_sitepart_rec;
      close  get_sitepart2_info;
   end if;

   if get_sitepart_rec.x_service_id is null then
      op_error_no := '0102';
      op_error_msg := 'ESN/MIN is invalid';
      return;
   end if;

   if ip_esn is not null and
      ip_min is not null and
      (get_sitepart_rec.x_service_id <> ip_esn or
       get_sitepart_rec.x_min <> ip_min)
   then
      op_error_no := '0103';
      op_error_msg := 'ESN/MIN does not match.';
      return;
   end if;

   if nvl(get_sitepart_rec.part_status,'empty') != 'Active' then
      if ip_action = 'Re-Enroll' then
         op_error_no := '0101';
         op_error_msg := 'Phone reactivation is required before proceeding with the reenrollment';
      else
         op_error_no := '0100';
         op_error_msg := 'Esn/Min is not Active';
      end if;
      return;
   end if;

   v_esn_lid := nvl(sa.adfcrm_safelink.get_lid(ip_esn => get_sitepart_rec.x_service_id),-1);
   if v_esn_lid != -1 and v_esn_lid != to_number(nvl(ip_lid,-1)) then
      op_error_no := '0115';
      op_error_msg := 'ESN does belong to another Lifeline ID';
      return;
   end if;

/********************************************************************************************************************************************
   open  get_esn_info_acct(get_sitepart_rec.x_service_id);
   fetch get_esn_info_acct into get_esn_info_acct_rec;
   close  get_esn_info_acct;
   if ip_web_user_id != nvl(get_esn_info_acct_rec.web_user_objid,ip_web_user_id) then
      op_error_no := '0120';
      op_error_msg := 'Esn does not belong to the same Account';
      return;
   end if;
********************************************************************************************************************************************/

    if ip_action = 'Re-Enroll' then
       select count(1)
       into cnt
       from x_sl_hist
       where x_esn = ip_esn;
       if cnt = 0 then
          op_error_no := '0125';
          op_error_msg := 'Esn does not have a record in the history table';
      return;
       end if;
    end if;

    if ip_action = 'Transfer' then
       --check brand for toESN
       open  get_esn_info(get_sitepart_rec.x_service_id);
       fetch get_esn_info into get_esn_info_rec;
       close  get_esn_info;
       if ip_org_id != get_esn_info_rec.org_id then
          op_error_no := '0130';
          op_error_msg := 'Esn does not have the same brand';
          return;
       end if;
   end if;
   EXCEPTION
   WHEN OTHERS THEN
      op_error_no := sqlcode;
      op_error_msg := substr(sqlerrm,1,4000);
      return;
 end validateSlEsn;

procedure process_hmo_enrollment (
   ip_old_esn in sa.table_part_inst.part_serial_no%type,   --old esn
   ip_esn in sa.table_part_inst.part_serial_no%type,   --target esn
   ip_min in sa.table_site_part.x_min%type,   --target min
   ip_lid in sa.x_sl_subs.lid%type,
   ip_user_name in sa.table_user.login_name%type,  --user that performs the transaction
   ip_reason in sa.x_program_enrolled.x_reason%type, --reason from TAS is 'SAFELINK TAS ENROLLMENT'
   ip_pgm_enroll2site_part  in number,
   ip_pgm_enroll2part_inst  in number,
   ip_pgm_enroll2contact  in number,
   ip_pgm_enroll2web_user  in number,
   ip_external_account in varchar2,
   op_err_code        out varchar2,
   op_err_msg         out varchar2
) IS
   CURSOR c1 (ip_external_account varchar2)
   IS
      SELECT
             (select max(x_retail_price) from table_x_pricing pr where PR.X_PRICING2PART_NUM = PP.PROG_PARAM2PRTNUM_MONFEE
                        and PR.X_START_DATE < sysdate
                        and PR.X_END_DATE > sysdate
             )   x_amount,
             pp.objid pgm_enroll2pgm_parameter
        FROM sa.x_program_parameters pp
       WHERE x_prog_class='HMO'
        and x_program_name like 'HMO -%'
        and ip_external_account LIKE substr(x_program_name,7,4)||'%';

   c_rec  c1%rowtype;
   l_enroll_seq          NUMBER;
   l_purch_hdr_seq       NUMBER;
   l_purch_hdr_dtl_seq   NUMBER;
   l_program_trans_seq   NUMBER;
   l_tax                 NUMBER := 0;
   l_e911_tax            NUMBER := 0;
BEGIN
   op_err_code:= '0';

   open c1(ip_external_account);
   fetch c1 into c_rec;
   if c1%found then
      close c1;
      BEGIN
      select max(objid)
      into l_enroll_seq
      from sa.x_program_enrolled
      where x_esn = ip_esn
      and pgm_enroll2pgm_parameter = c_rec.pgm_enroll2pgm_parameter;

       if nvl(l_enroll_seq,0) != 0 then
          update sa.x_program_enrolled
          set
               x_amount = c_rec.x_amount,
               x_sourcesystem = 'HMO',
               x_charge_date = sysdate,
               x_enrolled_date  = sysdate,
               x_start_date  = sysdate,
               x_reason = ip_reason,
               x_delivery_cycle_number = 1,
               x_enroll_amount = 0,
               x_enrollment_status = 'ENROLLED',
               x_is_grp_primary = 1,
               x_next_delivery_date = (LAST_DAY (ADD_MONTHS (TRUNC (SYSDATE), 0)) + 1),
               x_next_charge_date = null,
               x_update_stamp = sysdate,
               x_update_user = ip_user_name,
               pgm_enroll2site_part = ip_pgm_enroll2site_part,
               pgm_enroll2part_inst = ip_pgm_enroll2part_inst,
               pgm_enroll2contact = ip_pgm_enroll2contact,
               pgm_enroll2web_user = ip_pgm_enroll2web_user,
               x_termscond_accepted = 1,
               x_wait_exp_date = null,  --CR38544
               x_exp_date = null,       --CR38544
               x_cooling_exp_date = null--CR38544
          where objid = l_enroll_seq;
      else
          l_enroll_seq := sa.billing_seq ('X_PROGRAM_ENROLLED');
          INSERT INTO x_program_enrolled
                      (objid, x_esn, x_amount, x_type,
                       x_sourcesystem, x_insert_date, x_charge_date,
                       x_enrolled_date, x_start_date, x_reason,
                       x_delivery_cycle_number, x_enroll_amount, x_language,
                       x_enrollment_status, x_is_grp_primary,
                       x_next_delivery_date, x_update_stamp,
                       x_update_user, pgm_enroll2pgm_parameter,
                       pgm_enroll2site_part, pgm_enroll2part_inst,
                       pgm_enroll2contact, pgm_enroll2web_user,
                       x_termscond_accepted
                      )
               VALUES (l_enroll_seq, ip_esn, c_rec.x_amount, 'INDIVIDUAL',
                       'HMO', SYSDATE, SYSDATE,
                       SYSDATE, SYSDATE, ip_reason,
                       1, 0, 'ENGLISH',
                       'ENROLLED', 1,
                       (LAST_DAY (ADD_MONTHS (TRUNC (SYSDATE), 0)) + 1), SYSDATE,
                       ip_user_name, c_rec.pgm_enroll2pgm_parameter,
                       ip_pgm_enroll2site_part, ip_pgm_enroll2part_inst,
                       ip_pgm_enroll2contact, ip_pgm_enroll2web_user,
                       1
                      );
      end if;

      INSERT
      INTO sa.X_SL_HIST
        (
          objid,
          lid,
          x_esn,
          x_event_dt,
          x_insert_dt,
          x_event_value,
          x_event_code,
          x_event_data,
          x_min,
          username,
          x_sourcesystem,
          x_code_number,
          x_SRC_table,
          x_SRC_objid
        )
        VALUES
        (
          sa.SEQ_X_SL_HIST.nextval,
          ip_lid,
          ip_esn,
          sysdate,
          SYSDATE,
          'ENROLLED',
          607,
          ip_esn
            ||','
            ||'ENROLLED'
            ||','
            ||ip_reason,
          ip_min,
          NVL(ip_user_name,'SYSTEM'),
          'HMO',
          0,
          'x_program_enrolled',
          l_enroll_seq
        );

      l_purch_hdr_seq := sa.billing_seq ('X_PROGRAM_PURCH_HDR');
      l_purch_hdr_dtl_seq := sa.billing_seq ('X_PROGRAM_PURCH_DTL');
      l_program_trans_seq := sa.billing_seq ('X_PROGRAM_TRANS');

      INSERT INTO x_program_purch_hdr
                  (objid, x_rqst_source, x_rqst_type, x_rqst_date,
                   x_merchant_ref_number, x_ignore_avs, x_ics_rcode,
                   x_ics_rflag, x_ics_rmsg, x_auth_rcode, x_auth_rflag,
                   x_auth_rmsg, x_bill_rcode, x_bill_rflag,
                   x_bill_rmsg,
                   x_customer_email, x_status, x_bill_country,
                   x_amount, x_tax_amount, x_e911_tax_amount, x_user,
                   prog_hdr2web_user, x_payment_type
                  )
           VALUES (l_purch_hdr_seq, 'HMO', 'LIFELINE_PURCH', SYSDATE,
                   'BPSAFELINK', 'YES', '1',
                   'SOK', 'Request was processed successfully.', '1', 'SOK',
                   'Request was processed successfully.', '1', 'SOK',
                   'Request was processed successfully.',
                   'NULL@CYBERSOURCE.COM', 'LIFELINEPROCESSED', 'USA',
                   c_rec.x_amount, l_tax, l_e911_tax, ip_user_name,
                   ip_pgm_enroll2web_user, 'LL_ENROLL'
                  );


      INSERT INTO x_program_purch_dtl
                  (objid, x_esn, x_amount, x_tax_amount,
                   x_e911_tax_amount, x_charge_desc,
                   x_cycle_start_date, x_cycle_end_date,
                   pgm_purch_dtl2pgm_enrolled, pgm_purch_dtl2prog_hdr
                  )
           VALUES (l_purch_hdr_dtl_seq, ip_esn, c_rec.x_amount, l_tax,
                   l_e911_tax, ip_reason,
                   TRUNC (SYSDATE), TRUNC (SYSDATE) + 30,
                   l_enroll_seq, l_purch_hdr_seq
                  );


      INSERT INTO x_program_trans
                  (objid, x_enrollment_status, x_enroll_status_reason,
                   x_trans_date, x_action_text, x_action_type,
                   x_reason, x_sourcesystem,
                   x_esn, x_update_user, pgm_tran2pgm_entrolled,
                   pgm_trans2web_user, pgm_trans2site_part
                  )
           VALUES (l_program_trans_seq, 'ENROLLED', 'FIRST TIME ENROLLMENT',
                   SYSDATE, 'ENROLLMENT ATTEMPT', 'ENROLLMENT',
                   ip_reason, 'TAS', --'SYSTEM',
                   ip_esn, ip_user_name, l_enroll_seq,
                   ip_pgm_enroll2web_user, ip_pgm_enroll2site_part
                  );

        COMMIT;
        op_err_msg := 'ESN enrolled successfully';
      EXCEPTION
      WHEN OTHERS then
          ROLLBACK;
          op_err_code := -110;
          op_err_msg := 'process_hmo_enrollment: '||sqlerrm;
          return;  --Procedure stops here
      END;
   else
      close c1;
   end if;
END process_hmo_enrollment;

procedure process_enrollment (
   ip_esn in sa.table_part_inst.part_serial_no%type,   --target esn
   ip_lid in sa.x_sl_subs.lid%type,
   ip_user_name in sa.table_user.login_name%type,  --user that performs the transaction
   ip_reason in sa.x_program_enrolled.x_reason%type, --reason from TAS is 'SAFELINK TAS ENROLLMENT'
   op_err_code        out varchar2,
   op_err_msg         out varchar2
) IS
   CURSOR c1
   IS
      SELECT
             ip_esn x_esn,
             (select max(sp.objid) from table_site_part sp where sp.x_service_id = ip_esn and part_status = 'Active') pgm_enroll2site_part,
             (select max(pi.objid) from table_part_inst pi where pi.part_serial_no = ip_esn and pi.x_domain = 'PHONES') pgm_enroll2part_inst,
             (select web_user2contact from table_web_user where objid =  SL.SL_SUBS2WEB_USER) pgm_enroll2contact,
             SL.SL_SUBS2WEB_USER pgm_enroll2web_user,
             SL.ZIP, SL.STATE,
             (select max(x_retail_price) from table_x_pricing pr where PR.X_PRICING2PART_NUM = PP.PROG_PARAM2PRTNUM_MONFEE
                        and PR.X_START_DATE < sysdate
                        and PR.X_END_DATE > sysdate
             )   x_amount,
             pp.objid pgm_enroll2pgm_parameter,
             sl.x_external_account
        FROM sa.x_sl_subs sl,
             sa.x_program_parameters pp
       WHERE 1=1
       and sl.lid = ip_lid
       and SL.X_REQUESTED_PLAN = pp.x_program_name;

   l_enroll_seq          NUMBER;
   l_purch_hdr_seq       NUMBER;
   l_purch_hdr_dtl_seq   NUMBER;
   l_program_trans_seq   NUMBER;
   l_web_user_id         NUMBER;
   l_tax                 NUMBER := 0;
   l_e911_tax            NUMBER := 0;
   l_esn_check           NUMBER := 0;
   l_web_user_objid      number := 0;
   l_current_esn         varchar2(100);
   l_min                 varchar2(100);
BEGIN
   op_err_code:= '0';

   FOR c_rec IN c1
   LOOP
   BEGIN
      begin
          select x_current_esn
          into   l_current_esn
          from  sa.x_sl_currentvals cv
          where cv.lid = ip_lid;
      exception
          when others then
             op_err_code := -110;
             op_err_msg := 'process_enrollment: '||sqlerrm;
          return;  --Procedure stops here
      end;

      BEGIN
          --Check the esn does not belong to another LID
          select count(*)
          into   l_esn_check
          from  sa.x_sl_currentvals cv
          where cv.x_current_esn = ip_esn
          and cv.lid != ip_lid;

          if l_esn_check > 0 then
           op_err_code := -100;
           op_err_msg := 'ERROR-00100 process_enrollment: ESN belongs to another lifeline Id';
           return;  --Procedure stops here
          end if;
      END;

      if c_rec.pgm_enroll2part_inst is null then
           op_err_code := -210;
           op_err_msg := 'ERROR-00100 process_enrollment: ESN does not exist';
           return;  --Procedure stops here
      end if;

      if c_rec.pgm_enroll2site_part is null then
           op_err_code := -210;
           op_err_msg := 'ERROR-00100 process_enrollment: ESN is not active';
           return;  --Procedure stops here
      end if;

      l_esn_check := 0;
      BEGIN
          --Check if the esn belongs to any account
          SELECT x_contact_part_inst2contact, web.objid
            INTO l_esn_check, l_web_user_objid
            FROM table_x_contact_part_inst conpi, table_web_user web
          WHERE 1 = 1
             AND conpi.x_contact_part_inst2part_inst = c_rec.pgm_enroll2part_inst
             and web.web_user2contact = conpi.x_contact_part_inst2contact
             ;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN l_esn_check := 0;
             WHEN OTHERS then
                 op_err_code := -130;
                 op_err_msg := 'process_enrollment: '||sqlerrm;
                 return;  --Procedure stops here
      END;

     --check if the esn is already linked to the account then continue else detach from current account
         if l_esn_check != 0 and l_esn_check != c_rec.pgm_enroll2contact
         then
           --Detach ESN from existing my account
           sa.ADFCRM_ESN_ACCOUNT.REMOVE_ESN_FROM_ACCOUNT(
                      ip_web_user_objid  => l_web_user_objid,
                      ip_ESN             => ip_esn,
                      op_err_code        => op_err_code,
                      op_err_msg         => op_err_msg);
           if op_err_code != 0 then
              return;  --Procedure stops here
           end if;
         end if;

         if (l_esn_check != 0 and l_esn_check != c_rec.pgm_enroll2contact) or
             l_esn_check = 0
         then
               --link the esn to the account
             INSERT INTO sa.table_x_contact_part_inst (
                 objid,
                 x_contact_part_inst2contact,
                 x_contact_part_inst2part_inst,
                 x_esn_nick_name,
                 x_is_default,
                 x_transfer_flag,
                 x_verified
                 )
                  VALUES ((sa.seq ('X_CONTACT_PART_INST')),
                          c_rec.pgm_enroll2contact, c_rec.pgm_enroll2part_inst,
                          NULL, 1, 0, NULL);
         end if;

         -- set as primary esn
         update sa.table_x_contact_part_inst
         set x_is_default = 1
         where x_contact_part_inst2contact = c_rec.pgm_enroll2contact
         and x_contact_part_inst2part_inst = c_rec.pgm_enroll2part_inst;

         -- set as not primary other esns
         update sa.table_x_contact_part_inst
         set x_is_default = 0
         where x_contact_part_inst2contact = c_rec.pgm_enroll2contact
         and x_contact_part_inst2part_inst != c_rec.pgm_enroll2part_inst;

          select max(objid)
          into l_enroll_seq
          from sa.x_program_enrolled
          where x_esn = c_rec.x_esn
          and pgm_enroll2pgm_parameter = c_rec.pgm_enroll2pgm_parameter;

       if nvl(l_enroll_seq,0) != 0 then
          update sa.x_program_enrolled
          set
               x_amount = c_rec.x_amount,
               x_sourcesystem = 'VMBC',
               x_charge_date = sysdate,
               x_enrolled_date  = sysdate,
               x_start_date  = sysdate,
               x_reason = ip_reason,
               x_delivery_cycle_number = 1,
               x_enroll_amount = 0,
               x_enrollment_status = 'ENROLLED',
               x_is_grp_primary = 1,
               x_next_delivery_date = (LAST_DAY (ADD_MONTHS (TRUNC (SYSDATE), 0)) + 1),
               x_next_charge_date = null,
               x_update_stamp = sysdate,
               x_update_user = ip_user_name,
               pgm_enroll2site_part = c_rec.pgm_enroll2site_part,
               pgm_enroll2part_inst = c_rec.pgm_enroll2part_inst,
               pgm_enroll2contact = c_rec.pgm_enroll2contact,
               pgm_enroll2web_user = c_rec.pgm_enroll2web_user,
               x_termscond_accepted = 1
          where objid = l_enroll_seq;
      else
        l_enroll_seq := sa.billing_seq ('X_PROGRAM_ENROLLED');
          INSERT INTO x_program_enrolled
                      (objid, x_esn, x_amount, x_type,
                       x_sourcesystem, x_insert_date, x_charge_date,
                       x_enrolled_date, x_start_date, x_reason,
                       x_delivery_cycle_number, x_enroll_amount, x_language,
                       x_enrollment_status, x_is_grp_primary,
                       x_next_delivery_date, x_update_stamp,
                       x_update_user, pgm_enroll2pgm_parameter,
                       pgm_enroll2site_part, pgm_enroll2part_inst,
                       pgm_enroll2contact, pgm_enroll2web_user,
                       x_termscond_accepted
                      )
               VALUES (l_enroll_seq, c_rec.x_esn, c_rec.x_amount, 'INDIVIDUAL',
                       'VMBC', SYSDATE, SYSDATE,
                       SYSDATE, SYSDATE, ip_reason,
                       1, 0, 'ENGLISH',
                       'ENROLLED', 1,
                       (LAST_DAY (ADD_MONTHS (TRUNC (SYSDATE), 0)) + 1), SYSDATE,
                       ip_user_name, c_rec.pgm_enroll2pgm_parameter,
                       c_rec.pgm_enroll2site_part, c_rec.pgm_enroll2part_inst,
                       c_rec.pgm_enroll2contact, c_rec.pgm_enroll2web_user,
                       1
                      );
      end if;

      select x_min
      into  l_min
      from table_site_part
      where objid = c_rec.pgm_enroll2site_part;

      INSERT
      INTO sa.X_SL_HIST
        (
          objid,
          lid,
          x_esn,
          x_event_dt,
          x_insert_dt,
          x_event_value,
          x_event_code,
          x_event_data,
          x_min,
          username,
          x_sourcesystem,
          x_code_number,
          x_SRC_table,
          x_SRC_objid
        )
        VALUES
        (
          sa.SEQ_X_SL_HIST.nextval,
          ip_lid,
          c_rec.x_esn,
          sysdate,
          SYSDATE,
          'ENROLLED',
          607,
          c_rec.x_esn
            ||','
            ||'ENROLLED'
            ||','
            ||ip_reason,
          l_min,
          NVL(ip_user_name,'SYSTEM'),
          'VMBC',
          0,
          'x_program_enrolled',
          l_enroll_seq
        );

      l_purch_hdr_seq := sa.billing_seq ('X_PROGRAM_PURCH_HDR');
      l_purch_hdr_dtl_seq := sa.billing_seq ('X_PROGRAM_PURCH_DTL');
      l_program_trans_seq := sa.billing_seq ('X_PROGRAM_TRANS');

      INSERT INTO x_program_purch_hdr
                  (objid, x_rqst_source, x_rqst_type, x_rqst_date,
                   x_merchant_ref_number, x_ignore_avs, x_ics_rcode,
                   x_ics_rflag, x_ics_rmsg, x_auth_rcode, x_auth_rflag,
                   x_auth_rmsg, x_bill_rcode, x_bill_rflag,
                   x_bill_rmsg,
                   x_customer_email, x_status, x_bill_country,
                   x_amount, x_tax_amount, x_e911_tax_amount, x_user,
                   prog_hdr2web_user, x_payment_type
                  )
           VALUES (l_purch_hdr_seq, 'VMBC', 'LIFELINE_PURCH', SYSDATE,
                   'BPSAFELINK', 'YES', '1',
                   'SOK', 'Request was processed successfully.', '1', 'SOK',
                   'Request was processed successfully.', '1', 'SOK',
                   'Request was processed successfully.',
                   'NULL@CYBERSOURCE.COM', 'LIFELINEPROCESSED', 'USA',
                   c_rec.x_amount, l_tax, l_e911_tax, ip_user_name,
                   c_rec.pgm_enroll2web_user, 'LL_ENROLL'
                  );


      INSERT INTO x_program_purch_dtl
                  (objid, x_esn, x_amount, x_tax_amount,
                   x_e911_tax_amount, x_charge_desc,
                   x_cycle_start_date, x_cycle_end_date,
                   pgm_purch_dtl2pgm_enrolled, pgm_purch_dtl2prog_hdr
                  )
           VALUES (l_purch_hdr_dtl_seq, c_rec.x_esn, c_rec.x_amount, l_tax,
                   l_e911_tax, ip_reason,
                   TRUNC (SYSDATE), TRUNC (SYSDATE) + 30,
                   l_enroll_seq, l_purch_hdr_seq
                  );


      INSERT INTO x_program_trans
                  (objid, x_enrollment_status, x_enroll_status_reason,
                   x_trans_date, x_action_text, x_action_type,
                   x_reason, x_sourcesystem,
                   x_esn, x_update_user, pgm_tran2pgm_entrolled,
                   pgm_trans2web_user, pgm_trans2site_part
                  )
           VALUES (l_program_trans_seq, 'ENROLLED', 'FIRST TIME ENROLLMENT',
                   SYSDATE, 'ENROLLMENT ATTEMPT', 'ENROLLMENT',
                   ip_reason, 'TAS', --'SYSTEM',
                   c_rec.x_esn, ip_user_name, l_enroll_seq,
                   c_rec.pgm_enroll2web_user, c_rec.pgm_enroll2site_part
                  );

       --Transfer HMO program if it exists
       if c_rec.x_external_account is not null then
        process_hmo_enrollment (
           ip_old_esn => l_current_esn,
           ip_esn => ip_esn,
           ip_min => l_min,
           ip_lid => ip_lid,
           ip_user_name => ip_user_name,
           ip_reason => ip_reason,
           ip_pgm_enroll2site_part  => c_rec.pgm_enroll2site_part,
           ip_pgm_enroll2part_inst  => c_rec.pgm_enroll2part_inst,
           ip_pgm_enroll2contact  => c_rec.pgm_enroll2contact,
           ip_pgm_enroll2web_user => c_rec.pgm_enroll2web_user,
           ip_external_account => c_rec.x_external_account,
           op_err_code        => op_err_code,
           op_err_msg         => op_err_msg
        );
      end if;

      if op_err_code != 0 then
         rollback;
         return;
      end if;

      UPDATE X_SL_CURRENTVALS
      set X_CURRENT_ESN = '-1'
      where X_CURRENT_ESN = ip_esn
      and LID <> ip_lid;


      UPDATE X_SL_CURRENTVALS
      set   X_CURRENT_ESN = '-1'
      where X_CURRENT_ESN <> ip_esn
      and LID = ip_lid;

      UPDATE X_SL_CURRENTVALS
      set   X_CURRENT_ESN = ip_esn
           ,x_current_min = l_min
           ,X_CURRENT_PE_ID = l_enroll_seq
           ,x_current_enrolled = 'Y'
           ,x_current_active = 'Y'
           ,x_current_enrolled_date = sysdate
           ,x_current_pgm_start_date = sysdate
           ,x_deenroll_reason = ''
      where LID = ip_lid;

      op_err_msg := 'ESN enrolled successfully';
      COMMIT;
   EXCEPTION
      WHEN OTHERS then
          ROLLBACK;
          op_err_code := -150;
          op_err_msg := 'process_enrollment: '||sqlerrm;
          return;  --Procedure stops here
      END;
   END LOOP;

   COMMIT;
END process_enrollment;

procedure enrollment (
   ip_esn in varchar2,
   ip_lid in varchar2,
   ip_user_name in varchar2,
   ip_reason in varchar2,
   op_err_code out varchar2,
   op_err_msg  out varchar2
) IS
begin
   process_enrollment (
          ip_esn,
          ip_lid,
          ip_user_name,
          ip_reason,
          op_err_code,
          op_err_msg);
end enrollment;

procedure de_enrollment (
   ip_esn in varchar2,
   ip_lid in varchar2,
   ip_enroll_id in varchar2,  --x_program_enrolled.objid
   ip_user_name in varchar2,
   ip_reason in varchar2,
   op_err_code out varchar2,
   op_err_msg  out varchar2
) IS
   get_esn_info_rec  get_esn_info%rowtype;
begin
open get_esn_info(ip_esn);
fetch get_esn_info into get_esn_info_rec;
close get_esn_info;

op_err_code := '0';
op_err_msg := 'ESN De-enrolled successfully';

sa.safelink_services_pkg.p_deenroll_job(
          ip_esn   => ip_esn,
          ip_source_system => 'TAS',
          ip_deenroll_reason => ip_reason,
          op_err_no  => op_err_code,
          op_err_msg => op_err_msg);

/*************************************************************************
CR29505 new procedure signature will take care of De-enroll from HMO

sa.safelink_services_pkg.p_deneroll_job(
    ip_esn   => ip_esn,
    ip_lid   => ip_lid,
    ip_reason  => ip_reason,
    ip_phone_part_num => get_esn_info_rec.part_number,
    ip_enroll_objid => ip_enroll_id,
    op_err_no => op_err_code,
    op_err_msg => op_err_msg);


if op_err_code = 0 then
    --if ESN is enrolled in HMO program then de-enroll HMO as well
    for rec in (
     Select enroll.objid, param.x_program_name
     from x_program_enrolled enroll, x_program_parameters param
     where 1 = 1
     and enroll.x_esn = ip_esn
     and enroll.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
     and param.x_prog_class = 'HMO'
     and enroll.pgm_enroll2pgm_parameter = param.objid
    )
    loop
        sa.safelink_services_pkg.p_deneroll_job(
                ip_esn   => ip_esn,
                ip_lid   => ip_lid,
                ip_reason  => ip_reason,
                ip_phone_part_num => get_esn_info_rec.part_number,
                ip_enroll_objid => rec.objid,
                op_err_no => op_err_code,
                op_err_msg => op_err_msg);
    end loop;
end if;
*****************/
if op_err_code = 0 then  op_err_msg := 'ESN De-enrolled successfully'; end if;

end de_enrollment;


/***************************************************************/
--CR35135	Attach ESN to Safelink ID in TAS
procedure assign_esn_to_lid (
   ip_esn in varchar2,
   ip_lid in number,
   ip_userName in varchar2, -- CR 36487 Add hist record for Attach ESN to LID
   op_err_code out varchar2,
   op_err_msg  out varchar2
) is
   get_esn_info_rec  get_esn_info%rowtype;
   get_subs_info_rec get_subs_info%rowtype;
   v_old_lid x_sl_subs.lid%type; -- CR 36487 Add hist record for Attach ESN to LID
begin
      op_err_code := '-1';

      open get_esn_info(ip_esn);
      fetch get_esn_info into get_esn_info_rec;
      close get_esn_info;

	--CR51309 - We need to enable attaching LID to NEW and PASTDUE ESN's as well. Hence commenting the below code.
--      if get_esn_info_rec.x_part_inst_status != '52'then
--           op_err_code := '-600';
--           op_err_msg := 'ERROR-00600 Assign_esn_to_lid: ESN is not active';
--           return;  --Procedure stops here
--      end if;

	  open get_subs_info(ip_lid);
      fetch get_subs_info into get_subs_info_rec;
      if get_subs_info%notfound then
	       close get_subs_info;
           op_err_code := '-605';
           op_err_msg := 'ERROR-00605 Assign_esn_to_lid: Safelink ID provided is invalid';
           return;  --Procedure stops here
	  end if;
      close get_subs_info;

      if get_esn_info_rec.part_num2bus_org != get_subs_info_rec.web_user2bus_org then
           op_err_code := '-610';
           op_err_msg := 'ERROR-00610 Assign_esn_to_lid: Brand does not match for ESN and Safelink ID provided';
           return;  --Procedure stops here
      end if;

	  -- Getting old LID
      v_old_lid := get_lid(ip_esn =>ip_esn);

	  -- If ESN already attached to some old LID, first update ESN value as -1 for that old LID,
	  -- and then update the ESN to the new LID (in current vals)
      UPDATE X_SL_CURRENTVALS
      set X_CURRENT_ESN = '-1'
      where X_CURRENT_ESN = ip_esn
	  and LID <> ip_lid;

      UPDATE X_SL_CURRENTVALS
      set   X_CURRENT_ESN = ip_esn
      where LID = ip_lid;

	   -- Start : CR 36487 Add hist record for Attach ESN to LID

	   -- For old LID inserting ESN as -1 and x_event_value as 'Enrollment Esn Removal'
      if v_old_lid is not null then
          dbms_output.put_line('old lid: '||v_old_lid);
          INSERT INTO x_sl_hist
          ( OBJID, LID, X_ESN, X_EVENT_DT, X_INSERT_DT, X_EVENT_VALUE,
            X_EVENT_CODE, X_EVENT_DATA, X_MIN, USERNAME, X_SOURCESYSTEM,
            X_CODE_NUMBER, X_SRC_TABLE, X_SRC_OBJID, X_PROGRAM_ENROLLED_ID
          )
          VALUES
          ( sa.seq_x_sl_hist.nextval, v_old_lid, '-1', sysdate, sysdate, 'Enrollment Esn Removal',
            700, NULL, NULL, ip_userName, 'TAS',
            NULL, NULL, NULL, NULL
          );
      end if;

     -- For new LID
      INSERT INTO x_sl_hist
        ( OBJID, LID, X_ESN, X_EVENT_DT, X_INSERT_DT, X_EVENT_VALUE,
          X_EVENT_CODE, X_EVENT_DATA, X_MIN, USERNAME, X_SOURCESYSTEM,
          X_CODE_NUMBER, X_SRC_TABLE, X_SRC_OBJID, X_PROGRAM_ENROLLED_ID
        )
        VALUES
        ( sa.seq_x_sl_hist.nextval, ip_lid, ip_esn, sysdate, sysdate, 'Enrollment Esn Assignment',
          700, NULL, NULL, ip_userName, 'TAS',
          NULL, NULL, NULL, NULL
        );
      -- End : CR 36487 Add hist record for Attach ESN to LID

	  op_err_code := '0';
      op_err_msg := 'ESN attached to Safelink ID successfully';
      COMMIT;
EXCEPTION
      WHEN OTHERS then
          ROLLBACK;
          op_err_code := -700;
          op_err_msg := substr('ERROR-00700 Assign_esn_to_lid: '||sqlerrm,1,4000);
          return;  --Procedure stops here
end assign_esn_to_lid;

/***************************************************************/

  function is_phone_safelink (ip_esn varchar2) return varchar2
  as
    cnt number;
  begin
    select count(*)
    into   cnt
    from x_program_enrolled enroll, sa.x_program_parameters param
    where enroll.x_esn = ip_esn
    and enroll.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
    and param.x_prog_class = 'LIFELINE'
    and enroll.pgm_enroll2pgm_parameter = param.objid;

    if cnt > 0 then
      return 'true';
    else
      return 'false';
    end if;

  end is_phone_safelink;

  --********************Check if the ESN is SafeLink enrolled in the past*******************--
FUNCTION is_past_safelink_enrolled(
    ip_esn VARCHAR2)
  RETURN VARCHAR2
AS
  ret_val VARCHAR2(5) := 'false';
  cnt     NUMBER;
BEGIN
  SELECT COUNT(1)
  INTO cnt
  FROM sa.x_program_enrolled pe,
    sa.x_program_parameters pgm,
    sa.x_sl_currentvals slcur,
    sa.x_sl_subs slsub
  WHERE 1                     = 1
  AND pgm.objid               = pe.pgm_enroll2pgm_parameter
  AND slcur.x_current_esn     = pe.x_esn
  AND slcur.lid               = slsub.lid
  AND pgm.x_prog_class        = 'LIFELINE'
  AND pe.x_sourcesystem      IN ('VMBC', 'WEB')
  AND pgm.x_is_recurring      = 1
  AND pe.x_esn                = ip_esn
  AND pe.x_enrollment_status <> 'ENROLLED'
  AND pe.x_enrolled_date      =
    (SELECT MAX(i_pe.x_enrolled_date)
    FROM sa.x_program_enrolled i_pe,
      sa.x_program_parameters i_pgm
    WHERE i_pe.X_ESN         = pe.x_esn
    AND i_pgm.objid          = i_pe.pgm_enroll2pgm_parameter
    AND i_pgm.x_prog_class   = 'LIFELINE'
    AND i_pgm.x_is_recurring = 1
    )
  AND NOT EXISTS
    (SELECT 1
    FROM sa.x_program_enrolled i_pe,
      sa.x_program_parameters i_pgm
    WHERE i_pe.X_ESN             = pe.x_esn
    AND i_pgm.objid              = i_pe.pgm_enroll2pgm_parameter
    AND i_pgm.x_prog_class       = 'LIFELINE'
    AND i_pgm.x_is_recurring     = 1
    AND i_pe.x_enrollment_status = 'ENROLLED'
    ) ;
  IF cnt     > 0 THEN
    ret_val := 'true';
  END IF;
  RETURN ret_val;
EXCEPTION
WHEN OTHERS THEN
  RETURN ret_val;
END is_past_safelink_enrolled;

--********************************************************************************************************************--
  function is_still_safelink (ip_esn varchar2, ip_org_id varchar2) return varchar2
  as
    ret_val VARCHAR2(5) := 'false';
  begin
     if (ip_org_id in ('NET10','TRACFONE') and sa.adfcrm_safelink.is_phone_safelink(ip_esn) = 'true') or
        (ip_org_id in ('TRACFONE') and sa.adfcrm_safelink.is_past_safelink_enrolled(ip_esn) = 'true')
     then
        ret_val := 'true';
     end if;
     return ret_val;
  end;


--**  This function is to fetch the safelink LID details based on zipcode, address, fullname and brand asociated with LID
FUNCTION fetch_safelink_id_info(
    ip_zipcode     VARCHAR2,
    ip_address     VARCHAR2,
    ip_full_name   VARCHAR2,
    ip_org_id VARCHAR2)
  RETURN safe_link_lid_tab pipelined
IS
  CURSOR sf_lid
  IS
    SELECT *
    FROM
      (SELECT x.*,
        row_number() over(partition BY zip
        ||upper(address_1)
        ||upper(REGEXP_REPLACE(FULL_NAME,'[^a-zA-Z]')) order by DECODE(x_current_enrolled,'Y',1,2), sl_hist_dt DESC) x_rank
      FROM
        (SELECT sls.lid,
          sls.full_name,
          sls.address_1,
          sls.CITY,
          sls.STATE,
          sls.zip,
          sls.COUNTRY,
          sls.E_MAIL,
          sls.X_HOMENUMBER,
          cv.x_current_esn,
          cv.x_current_enrolled,
          cv.x_current_enrolled_date,
          (SELECT MAX(slh.x_event_Dt)
          FROM x_sl_hist slh
          WHERE slh.lid         = sls.lid
          AND slh.x_event_code IN (602,607,700,611,613, 616, 617)
          ) sl_hist_dt
      FROM x_sl_subs sls,
        x_sl_currentvals cv
      WHERE sls.lid IN
        (SELECT XSlSubs.LID
        FROM X_SL_SUBS XSlSubs,
          sa.table_web_user wu,
          sa.table_bus_org bus
        WHERE wu.objid   = sls.SL_SUBS2WEB_USER
        AND bus.objid    = wu.WEB_USER2BUS_ORG
        AND bus.org_id   = ip_org_id
        AND zip          = ip_zipcode
        AND upper(address_1) LIKE upper(ip_address ||'%')
        AND (ip_full_name IS NULL
        OR upper(full_name) LIKE upper('%'
          ||ip_full_name
          ||'%'))
        )
      AND cv.lid = sls.lid
        ) x
      )
    ORDER BY zip,
      address_1,
      full_name,
      x_rank;
    safe_link_lid_rslt safe_link_lid_rec;
  BEGIN

    --validation - ip_zipcode and address are mandatory fields
    if ip_zipcode is null or ip_address is null then
      return;
    end if;

    -- initialize
    safe_link_lid_rslt.LID                     := NULL;
    safe_link_lid_rslt.FULL_NAME               := NULL;
    safe_link_lid_rslt.ADDRESS_1               := NULL;
    safe_link_lid_rslt.CITY                    := NULL;
    safe_link_lid_rslt.STATE                   := NULL;
    safe_link_lid_rslt.ZIP                     := NULL;
    safe_link_lid_rslt.COUNTRY                 := NULL;
    safe_link_lid_rslt.E_MAIL                  := NULL;
    safe_link_lid_rslt.X_HOMENUMBER            := NULL;
    safe_link_lid_rslt.X_CURRENT_ESN           := NULL;
    safe_link_lid_rslt.X_CURRENT_ENROLLED      := NULL;
    safe_link_lid_rslt.X_CURRENT_ENROLLED_DATE := NULL;
    safe_link_lid_rslt.X_SL_HIST_DATE          := NULL;
    safe_link_lid_rslt.X_RANK                  := NULL;
    FOR sf_lid_rec IN sf_lid
    LOOP
      safe_link_lid_rslt.LID                     := sf_lid_rec.LID;
      safe_link_lid_rslt.FULL_NAME               := sf_lid_rec.FULL_NAME;
      safe_link_lid_rslt.ADDRESS_1               := sf_lid_rec.ADDRESS_1;
      safe_link_lid_rslt.CITY                    := sf_lid_rec.CITY;
      safe_link_lid_rslt.STATE                   := sf_lid_rec.STATE;
      safe_link_lid_rslt.ZIP                     := sf_lid_rec.ZIP;
      safe_link_lid_rslt.COUNTRY                 := sf_lid_rec.COUNTRY;
      safe_link_lid_rslt.E_MAIL                  := sf_lid_rec.E_MAIL;
      safe_link_lid_rslt.X_HOMENUMBER            := sf_lid_rec.X_HOMENUMBER;
      safe_link_lid_rslt.X_CURRENT_ESN           := sf_lid_rec.X_CURRENT_ESN;
      safe_link_lid_rslt.X_CURRENT_ENROLLED      := sf_lid_rec.X_CURRENT_ENROLLED;
      safe_link_lid_rslt.X_CURRENT_ENROLLED_DATE := sf_lid_rec.X_CURRENT_ENROLLED_DATE;
      safe_link_lid_rslt.X_SL_HIST_DATE          := sf_lid_rec.SL_HIST_DT;
      safe_link_lid_rslt.X_RANK                  := sf_lid_rec.X_RANK;
      pipe row (safe_link_lid_rslt);
    END LOOP;
    RETURN;
  END fetch_safelink_id_info;


end adfcrm_safelink;
/