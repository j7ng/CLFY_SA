CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_UNLOCK_BUYBACK_PKG" AS
  -- CR39592 Start PMistry 03/01/2016
  function insert_log (login_name in varchar2, overwrite in varchar2,esn in varchar2,mdn in varchar2,check_result in varchar2,trade_value in number,paid_days in number,active_days in number,err_code in varchar2,err_msg in varchar2)
  return number is

  begin

     insert into sa.unlock_verify_log (login_name,overwrite,esn,mdn,check_result,trade_value,paid_days,active_days,err_code,err_msg)
     values (login_name,nvl(overwrite,'false'),esn,mdn,check_result,trade_value,paid_days,active_days,err_code,err_msg);

     commit;
     return 1;

     exception
        when others then
           return 0;
  end;

  function get_install_date(i_part_serial_no varchar2)
    return date
    as
      install_date date;
      n_is_refurb number;
    begin
      select count(1)
      into   n_is_refurb
      from   table_site_part sp_a
      where  sp_a.x_service_id = i_part_serial_no
      and    sp_a.x_refurb_flag = 1;

      if n_is_refurb = 0 then
        select min(install_date)
        into   install_date
        from   sa.table_site_part
        where  x_service_id = i_part_serial_no
        and    part_status || '' in ('Active','Inactive');
      else
        select min(install_date)
        into   install_date
        from   table_site_part sp_b
        where  sp_b.x_service_id = i_part_serial_no
        and    sp_b.part_status || '' in ('Active','Inactive')
        and    nvl(sp_b.x_refurb_flag,0) <> 1;
      end if;

      return install_date;
    exception
      when others then
        return null;
    end get_install_date;

  -- CR39592 End PMistry 03/01/2016

function sl_enroll_fn(p_esn in varchar2) return number is

 l_prog_class CONSTANT varchar2(30) := 'LIFELINE';
 l_enrollment CONSTANT varchar2(30) := 'ENROLLED';
 l_part_status CONSTANT varchar2(30) := 'Active';
 l_date CONSTANT DATE := to_date('11-FEB-2014' ,'DD-MON-YYYY');
			 l_enrolled number;

		begin

 		if p_esn is null then

				return 0;

 else
			 --looking for the Life line customers activation date after the 11-FEB-2014 date as per FCC.
		 select 1 INTO l_enrolled
 from x_program_enrolled pe, x_program_parameters pgm, x_sl_currentvals slcur, table_site_part tsp
 where 1 = 1
 and pgm.objid = pe.pgm_enroll2pgm_parameter
 and slcur.x_current_esn = pe.x_esn
 and sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
 and pgm.x_prog_class = l_prog_class
 and pe.x_esn = p_esn
 and pe.x_enrollment_status = l_enrollment
 and tsp.x_service_id = pe.x_esn
 and tsp.part_status||'' = l_part_status
 and tsp.install_date > l_date;

			 return l_enrolled;

			end if;

		exception

 when others then

			 	return 0;

end sl_enroll_fn;

function unlock_case_fn( p_esn in varchar2 ,
                        p_min in varchar2 ) return varchar2 is

                                    l_case_type   CONSTANT  varchar2(30)  :='Unlock Policy';
       l_case_title            varchar2(30)  :='Unlock Phone Request';
       l_case_title_iphone     varchar2(30)  :='Unlock iPhone Request';
       l_case_title_tmo        varchar2(30)  :='Unlock TMO WL Request'; --CR40342 added for TMO
       v_case_id                number;
       v_unlock_type           varchar2(100);
       l_safelink_esn          number;        -- CR39592 PMistry 03/04/2016
       v_esn                   varchar2(50);

       --Service By Min Cursor
       cursor service_by_min_cur (v_min varchar2) is
               select x_service_id
               from sa.table_site_part sp
               where sp.x_min = v_min
               order by install_date desc;

       service_by_min_rec service_by_min_cur%rowtype;
begin
      v_esn := p_esn;
       if p_esn is null and p_min is null then
                return null;
       else
         if p_esn is null then
              open service_by_min_cur(p_min);
              fetch service_by_min_cur into service_by_min_rec;
              if service_by_min_cur%found then
                  v_esn := service_by_min_rec.x_service_id;
              end if;
              close service_by_min_cur;
         end if;
                                    --Looking for the Unlock case.

          l_safelink_esn := sl_enroll_fn(p_esn);     -- CR39592 PMistry 03/04/3026 Added for Safe link check.
          select id_number  into v_case_id
           from sa.table_case
           where (x_esn = v_esn)
            and ( (x_case_type = l_case_type            -- CR39592 PMistry 03/04/2016 modify the condition to add Unlock exchange case for Safelink ESN.
                  and (title = l_case_title or title = l_case_title_iphone or title=l_case_title_tmo))
                or
                 ( l_safelink_esn =  1 and x_case_type = 'Warehouse' and title = 'Unlock Exchange' )
                ); --CR40342 added for TMO

            return v_case_id;

      end if;

exception
  when others then
      return null;

end unlock_case_fn;

procedure VERIFY_ELEGIBILITY(p_esn in varchar2,
 p_min in varchar2,
 p_overwrite in varchar2 DEFAULT 'false',
 p_result out varchar2, -- (NOT ELIGIBLE, UNLOCKED, BUY BACK PROGRAM, UNLOCKABLE)
 p_trade_value out number,
 p_paid_days out number,
 p_active_days out number,
 p_err_code out varchar2,
 p_err_msg out varchar2) IS

BEGIN

 VERIFY_ELEGIBILITY(p_esn => p_esn,
 p_min => p_min,
 p_overwrite => p_overwrite,
 p_result => p_result,
 p_trade_value => p_trade_value,
 p_paid_days => p_paid_days,
 p_active_days => p_active_days,
 p_err_code => p_err_code,
 p_err_msg => p_err_msg,
				 p_login_name => 'CBO');

END;


 procedure VERIFY_ELEGIBILITY(p_esn in varchar2,
                              p_min in varchar2,
                              p_overwrite in varchar2 DEFAULT 'false',
                              p_source_system in varchar2 DEFAULT 'WEB',        -- CR39592 PMistry 03/07/2016 added new parameter for FCC project
                              p_result out varchar2, -- (NOT ELIGIBLE, UNLOCKED, BUY BACK PROGRAM, UNLOCKABLE)
                              p_trade_value out number,
                              p_paid_days out number,
                              p_active_days out number,
                              p_err_code out varchar2,
                              p_err_msg  out varchar2,
						      p_login_name  in  varchar2) IS

PRAGMA AUTONOMOUS_TRANSACTION;

 --Part Class Cursorz
 cursor part_class_cur (v_esn varchar2) is
 select pc.*, pi.x_part_inst_status
 from sa.table_part_class pc,
 sa.table_part_num pn,
 sa.table_mod_level ml,
 sa.table_part_inst pi
 where pi.part_serial_no = v_esn
 and pi.x_domain = 'PHONES'
 and PI.N_PART_INST2PART_MOD = ml.objid
 and ML.PART_INFO2PART_NUM = pn.objid
 and pc.objid = PN.PART_NUM2PART_CLASS;

 part_class_rec part_class_cur%rowtype;

 --Service By Min Cursor
 cursor service_by_min_cur (v_min varchar2) is
 select x_service_id
 from sa.table_site_part sp
 where sp.x_min = v_min
 and sp.part_status in ('Active','CarrierPending');

 service_by_min_rec service_by_min_cur%rowtype;

 --Cursor to find total days for current Active Service.
 cursor current_active_days_cur (v_esn varchar2) is
 select count(*) rec_count
 FROM sa.table_site_part
 where x_service_id = v_esn
 and (part_status in ('Active','CarrierPending')
 or (nvl(x_refurb_flag,0) = 0 and part_status = 'Inactive' and service_end_dt > sysdate - 60));

 current_active_days_rec current_active_days_cur%rowtype;

  -- CR39592 Start PMistry 03/01/2016 Modify the package to make is parameterize to use it with other cases.
  cursor case_conf_cur (c_param_name sa.table_x_parameters.x_param_name%TYPE) is
    select *
    from sa.table_x_case_conf_hdr
    where objid in (select x_param_value
                    from sa.table_x_parameters
                    where x_param_name = c_param_name );  --'ADFCRM_UNLOCK_BUYBACK_CASE_CONF');
  case_conf_rec case_conf_cur%rowtype;



  -- CR39592 PMistry 03/01/2016 Modify the cursor to add status.
  cursor case_search_cur (v_esn varchar2, v_case_type varchar2, v_title varchar2)
  is
  select id_number, gb.title
  from sa.table_case c, sa.table_gbst_elm gb
  where c.x_esn = v_esn
  and c.x_case_type = v_case_type
  and c.title = v_title
  and gb.objid = c.casests2gbst_elm;

  case_search_rec case_search_cur%rowtype;

  l_repl_zip_code   varchar2(10);
  -- CR39592 End PMistry 03/01/2016


 cursor safelink_dealer_cur (v_esn varchar2) is
 Select Site.Site_Id Dealer_Id,Site.Name dealer_name
 from sa.table_part_inst pi,
 sa.Table_Site site,
 sa.Table_Inv_Bin Ib,
 sa.Table_Inv_Locatn Il
 where pi.part_serial_no = v_esn
 and pi.x_domain = 'PHONES'
 And Ib.Objid = Pi.Part_Inst2inv_Bin
 And Il.Objid = Ib.Inv_Bin2inv_Locatn
 And Site.Objid = Il.Inv_Locatn2site
 and Site.Site_id in ('24920','27468');
 --Safelink Dealers
 --24920 USAC - SAFE-LINK
 --27468 SAFELINK EXCHANGE
 safelink_dealer_rec safelink_dealer_cur%rowtype;

  cursor part_inst_cur (v_esn varchar2, v_hex varchar2) is
  select part_serial_no, x_iccid
  from sa.table_part_inst
  where (part_serial_no = v_esn or part_serial_no = v_hex)
  and x_domain = 'PHONES';

 part_inst_rec part_inst_cur%rowtype;

--CR39303:- Checking for Iphone Unlock request case status
CURSOR c_case_status (c_esn VARCHAR2)
IS
 SELECT tcase.x_esn,
 tcond.title as case_status
 FROM table_case tcase
 JOIN table_condition tcond ON tcase.case_state2condition=tcond.objid
 JOIN table_gbst_elm gb ON gb.objid = tcase.casests2gbst_elm
 WHERE tcase.x_esn = c_esn
 AND tcase.x_case_type = 'Unlock Policy'
 AND tcase.title IN('Unlock iPhone Request','Unlock TMO WL Request'); --CR40342 added for TMO
case_status_rec c_case_status%ROWTYPE;
--CR39303 ends

  v_min_paid_days number:=0;
  v_start_date date := '11-feb-2014';
  v_min_active_days number:=0;
  v_device_type varchar2(100);
  v_esn varchar2(30);
  v_class_name varchar2(100);
  v_unlock_elegible varchar2(30);
  v_unlock_state varchar2(30);
  v_trade_in_value number:=0;
  v_days_paid number:=0;
  v_total_days number:=0;
  v_active_days number:=0;
  v_pi_status varchar2(30);
  v_old_act_count number;
  v_lid varchar2(30);
  v_case_type varchar2(30);
  v_title varchar2(80);
  v_case_conf_objid   sa.table_x_case_conf_hdr.objid%type;
  v_zipcode   varchar2(10);
  v_Return varchar2(100);
  v_log number;
  v_hex varchar2(30);
  l_sl_enrolled number := 0;
  l_case_id  varchar2(30);
  v_unlock_type varchar2(100);
  v_unlock_count number:=0;
  v_unlock_ready_count    number := 0;


  v_real_install_date   date;
  v_part_number varchar2(200);
  v_sim_profile varchar2(200);
  v_sim_suffix  varchar2(200);
  v_repl_logic  varchar2(30);

/*  CR39592 04/06/2016 PMistry Made this function local to package so that it can be used in other procedure in the package.
  function insert_log (login_name in varchar2, overwrite in varchar2,esn in varchar2,mdn in varchar2,check_result in varchar2,trade_value in number,paid_days in number,active_days in number,err_code in varchar2,err_msg in varchar2)
  return number is

  begin

     insert into sa.unlock_verify_log (login_name,overwrite,esn,mdn,check_result,trade_value,paid_days,active_days,err_code,err_msg)
     values (login_name,nvl(overwrite,'false'),esn,mdn,check_result,trade_value,paid_days,active_days,err_code,err_msg);

     commit;
     return 1;

     exception
        when others then
           return 0;
  end;
*/
BEGIN



 -- Find ADFCRM_UNLOCK_MIN_PAID_SERVICE_DAYS configuration
 Begin
 select to_number(x_param_value)
 into v_min_paid_days
 from sa.table_x_parameters where x_param_name = 'ADFCRM_UNLOCK_MIN_PAID_SERVICE_DAYS';
 exception
 when others then
 v_min_paid_days := 360;
 end;

 --Find ADFCRM_UNLOCK_MIN_ACTIVE_DAYS configuration
 Begin
 select to_number(x_param_value)
 into v_min_active_days
 from sa.table_x_parameters where x_param_name = 'ADFCRM_UNLOCK_MIN_ACTIVE_DAYS';
 exception
 when others then
 v_min_active_days := 360;
 end;

 if p_esn is null and p_min is null then
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1000';
 p_err_msg:='ERROR: Missing Serial Number and/or MIN';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;

 --Find ESN from MIN
 if p_esn is null then
 open service_by_min_cur(p_min);
 fetch service_by_min_cur into service_by_min_rec;
 if service_by_min_cur%found then
 close service_by_min_cur;
 v_esn := service_by_min_rec.x_service_id;
 else
 close service_by_min_cur;
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1010';
 p_err_msg:='ERROR: Device not found in inventory';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;
 else
 begin
 v_hex := sa.HEX2DEC(HEXVAL => p_esn);
 exception
 when others then
 v_hex := p_esn;
 end;

 open part_inst_cur(p_esn,v_hex);
 fetch part_inst_cur into part_inst_rec;

 if part_inst_cur%found then
 close part_inst_cur;
 v_esn := part_inst_rec.part_serial_no;
 else
 close part_inst_cur;
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '2010';
 p_err_msg:='ERROR: Device not found in inventory';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;
 end if;

  -- CR39592 Start PMistry 03/14/2016 Added Unlock Ready condition check.
  Select count(*) into v_unlock_ready_count
  from unlock_esn_status
  where ESN=v_esn
  and upper(unlock_status)='UNLOCK-READY'
  and rownum=1;
  if v_unlock_ready_count =1 then
        p_result := 'UNLOCKABLE';
        p_err_code:= 0;
        p_err_msg:='Success';
        return ;
  end if;

 --Safelink Check --> Not Allowed
 v_lid := sa.ADFCRM_SAFELINK.GET_LID(IP_ESN => v_esn);
 if v_lid is not null then

 --verify Dealer in Case Customer Bought the handset
 open safelink_dealer_cur(v_esn);
 fetch safelink_dealer_cur into safelink_dealer_rec;
 if safelink_dealer_cur%found then
 close safelink_dealer_cur;

         l_sl_enrolled := sl_enroll_fn(v_esn);
--   CR39592 Start 03/01/2016 PMistry Commented to allow Safe-link customer.

--       if l_sl_enrolled =1 then
--        p_result := 'UNLOCKABLE';
--        p_err_code:= 0;
--        p_err_msg:='Success';
--        else
--        p_result := 'NOT ELIGIBLE';
--        p_err_code:= '1023';
--        p_err_msg:='ERROR: Safelink Customer';
--        v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
--        return;
--        end if;
-- CR39592 End PMistry 03/01/2016
     else
        close safelink_dealer_cur;
     end if;
  end if;

  -- CR39592 End PMistry 03/14/2016
  --Days Paid
  select sa.buyback_pkg.fn_get_paid_days_by_esn(v_esn) into v_days_paid from dual;--CR40287

 --Active Days
 if l_sl_enrolled = 0 then
    select sa.buyback_pkg.fn_get_active_days_by_esn(v_esn)  into v_active_days from dual;--CR40287
 else
    v_real_install_date := get_install_date(v_esn) ;
    v_active_days  := round(sysdate - v_real_install_date,0);
 end if;
 --v_total_days:= nvl(v_days_paid,0) + nvl(v_days_paid_sl,0);
 v_total_days:= nvl(v_days_paid,0);
 p_paid_days:=v_total_days;
 p_active_days:= round(v_active_days,2);

 --Inventory Check
 open part_class_cur(v_esn);
 fetch part_class_cur into part_class_rec;

 if part_class_cur%found then
 v_class_name := part_class_rec.name;
 v_pi_status := part_class_rec.x_part_inst_status;
 close part_class_cur;
 else
 close part_class_cur;
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1020';
 p_err_msg:='ERROR: Device not found in inventory';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;

 end if;


 --Phone Status Check
 if v_pi_status not in ('50','51','52','54','150','65') then
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1025';
 p_err_msg:='ERROR: Invalid Status';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;

 --Find Device Type, Only Phones are allowed.
 v_device_type := sa.GET_PARAM_BY_NAME_FUN(
 IP_PART_CLASS_NAME => v_class_name,
 IP_PARAMETER => 'DEVICE_TYPE');

 if v_device_type <> 'FEATURE_PHONE' and v_device_type <> 'SMARTPHONE' and v_device_type <> 'NOT FOUND' then
--CR39303 - If BYOP and there is already a case then set as reprocess
 IF v_class_name = 'TFBYOPC' and v_device_type='BYOP' and unlock_case_fn(v_esn,p_min) is not null
 THEN
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1110';
 p_err_msg := 'CDMA Feature Phone already Unlocked';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 END IF;
--CR39303 ends here

 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1030';
 p_err_msg:='ERROR: Device not elegible';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;

  --If the Past Class Allowed??  Parameter or New Activation after 02/11/2015
  if l_sl_enrolled =  1 then            -- CR39592 PMistry 04/14/2016 Added for safe link customer to ignore refurbish scenario.
    if v_real_install_date < v_start_date then
      v_old_act_count := 1;
    else
      v_old_act_count := 0;
    end if;
  else
    select count(*)
    into v_old_act_count
    from sa.table_site_part
    where x_service_id = v_esn
    and install_date < v_start_date;
  end if;
 --dbms_output.put_line('v_old_act_count: '||v_old_act_count);
 --dbms_output.put_line('v_class_name: '||v_class_name);
 v_unlock_elegible := sa.GET_PARAM_BY_NAME_FUN(
 IP_PART_CLASS_NAME => v_class_name,
 IP_PARAMETER => 'UNLOCK_ELEGIBLE');
 --dbms_output.put_line('v_unlock_elegible: '||v_unlock_elegible);
 if v_unlock_elegible <> 'Y' and v_old_act_count > 0 then
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1040';
 p_err_msg:='ERROR: Device not eligible';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;

 --UNLOCK Capabilities
 v_unlock_state := sa.GET_PARAM_BY_NAME_FUN(
 IP_PART_CLASS_NAME => v_class_name,
 IP_PARAMETER => 'DEVICE LOCK STATE');
 if v_unlock_state = 'UNLOCKED' then
 p_result := 'UNLOCKED';
 p_err_code:= '1050';
 p_err_msg:='ERROR: Device already unlocked';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;
 if v_unlock_state = 'UNLOCKABLE' then

 --p_result := 'UNLOCKABLE';
 --p_err_code:= '1060';
 --p_err_msg:='ERROR: Device is unlockable';
 --v_log := insert_log(v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 --return;
	 null;

 else
	 --BUY BACK
	 begin
		 p_trade_value := to_number(sa.GET_PARAM_BY_NAME_FUN(
		 IP_PART_CLASS_NAME => v_class_name,
		 IP_PARAMETER => 'TRADE_IN_VALUE'));
		 --dbms_output.put_line('p_trade_value: '||p_trade_value);
	 exception
		 when others then
        if  l_sl_enrolled = 0 then        -- CR39592 PMistry 04/16/2016 to skip trade in value check for Safe link customer.
           p_result := 'NOT ELIGIBLE';
           p_err_code:= '1070';
           p_err_msg:='ERROR: Trade In Value not defined';
           v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
           return;
        end if;
	  end;
	  --Verify Previous Buy Back Case


	  open case_conf_cur('ADFCRM_UNLOCK_BUYBACK_CASE_CONF');
	  fetch case_conf_cur into case_conf_rec;
	  if case_conf_cur%found then
		 v_case_type := case_conf_rec.x_case_type;
		 v_title := case_conf_rec.x_title;
	 end if;
	 close case_conf_cur;

      open case_search_cur(v_esn,v_case_type,v_title);
      fetch case_search_cur into case_search_rec;

      if case_search_cur%found then
        -- CR39592 Start PMistry 03/01/2016 Return new error code and message is the case is exist with BadAddress.
        close case_search_cur;
        if case_search_rec.title = 'BadAddress' then
          p_result := 'NOT ELIGIBLE';
          p_err_code:= '1150';
          p_err_msg:='ERROR: Case in Bad Address Status';
        else
           p_result := 'NOT ELIGIBLE';
           p_err_code:= '1027';
           p_err_msg:='ERROR: Case already exists';
        end if;
        v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
      -- CR39592 End PMistry 03/01/2016
        return;
      else
         close case_search_cur;
      end if;

    -- CR39592 Start 03/01/2016 PMistry Verify previous UNLOCK EXCHANGE case.
	  open case_conf_cur('ADFCRM_UNLOCK_CASE_CONF');
	  fetch case_conf_cur into case_conf_rec;

		 v_case_type := NULL;
		 v_title := NULL;

	  if case_conf_cur%found then
		 v_case_type := case_conf_rec.x_case_type;
		 v_title := case_conf_rec.x_title;
     v_case_conf_objid := case_conf_rec.objid;
	  end if;
	  close case_conf_cur;

	  open case_search_cur(v_esn,v_case_type,v_title);
      fetch case_search_cur into case_search_rec;
      if case_search_cur%found then
        close case_search_cur;
        if case_search_rec.title = 'BadAddress' then
          p_result := 'NOT ELIGIBLE';
          p_err_code:= '1151';
          p_err_msg:='ERROR: Unlock Exchange Bad Address';
        elsif case_search_rec.title = 'Shipped' then
          p_result := 'NOT ELIGIBLE';
          p_err_code:= '1152';
          p_err_msg:='ERROR: Unlock Exchange Shipped';
        elsif case_search_rec.title = 'Closed' then
          p_result := 'NOT ELIGIBLE';
          p_err_code:= '1027';
          p_err_msg:='ERROR: Case already exists';
        else
          p_result := 'NOT ELIGIBLE';
          p_err_code:= '1153';
          p_err_msg:='ERROR: Unlock Exchange Request Created';
        end if;
        v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);

        return;
      else
        close case_search_cur;
      end if;

      -- CR39592 End PMistry 03/01/2016
  end if;


 --dbms_output.put_line('v_total_days: '||v_total_days);
 --dbms_output.put_line('v_min_paid_days: '||v_min_paid_days);
 --dbms_output.put_line('v_min_active_days: '||v_min_active_days);
 --dbms_output.put_line('v_active_days: '||v_active_days);

--CR39303 - If there is a unlock case already exists then bypass below checks
 if unlock_case_fn(v_esn,p_min) is null then
 --if nvl(p_overwrite,'false') <> 'true' then
 if upper(nvl(p_overwrite,'false')) NOT IN ('TRUE','TEST','ESCALATION') then --CR45269 Unlocking Solution ? 2 new flags
 --dbms_output.put_line('Alidating Days/ overwrite false');

 if v_total_days < v_min_paid_days then
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1080';
 p_err_msg:='ERROR: Device not eligible, Not 12 months paid';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;

 if v_active_days < v_min_active_days then
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1090';
 p_err_msg := 'ERROR: Device not eligible, Not 12 months active';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;

 open current_active_days_cur(v_esn);
 fetch current_active_days_cur into current_active_days_rec;
 if current_active_days_cur%found then
 close current_active_days_cur;
 if current_active_days_rec.rec_count = 0 then
 p_result := 'NOT ELIGIBLE';
 p_err_code:= '1100';
 p_err_msg := 'ERROR: Not active recently';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;
 else
 close current_active_days_cur;
 end if;
 end if;
 end if; --CR39303


 if v_unlock_state = 'UNLOCKABLE' then

 l_case_id := unlock_case_fn(v_esn,p_min);

---CR39303 If there is no case exists but an entry present in unlock_spc_encrypt with Unlocked status, return Unlocked
 Select count(*) into v_unlock_count from unlock_spc_encrypt where ESN=v_esn and upper(unlock_status)='UNLOCKED' and rownum=1;

 if l_case_id is null and v_unlock_count>0 then
 p_result := 'UNLOCKED';
 p_err_code:= '1050';
 p_err_msg:='ERROR: Device already unlocked';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;
--- CR39303 Ends

 if l_case_id is not null then

--CR39303:- Check if there is a case pending for Iphone, return request pending
 v_unlock_type := sa.GET_PARAM_BY_NAME_FUN(
 IP_PART_CLASS_NAME => v_class_name,
 IP_PARAMETER => 'UNLOCK_TYPE');
 IF v_unlock_type IN ('IPHONE','TMO_WL') then --CR40342 added for TMO
 OPEN c_case_status(v_esn);
 FETCH c_case_status INTO case_status_rec;

 IF c_case_status%FOUND and upper(case_status_rec.case_status)<>'CLOSED'
 THEN
 p_result:= 'ELIGIBLE - REQUEST PENDING';
 p_err_code:= '3022';
 p_err_msg := 'ELIGIBLE - REQUEST PENDING';
 CLOSE c_case_status;
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 RETURN;
 END IF;
 CLOSE c_case_status;
        -- CR39592 Start PMistry 03/28/2016 modified for IPHONE.
        elsIF v_unlock_type IN ('IPHONE') then --CR40342 added for TMO
           OPEN c_case_status(v_esn);
           FETCH c_case_status INTO case_status_rec;

           IF c_case_status%FOUND and upper(case_status_rec.case_status)<>'CLOSED'
           THEN
              p_result:= 'Not eligible';
              p_err_code:= '1154';
              p_err_msg := 'iPhone Unlock Pending';
              CLOSE c_case_status;
              v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
              RETURN;
            END IF;
          CLOSE c_case_status;
          -- CR39592 End.
 END IF;
--CR39303 Ends Here

 p_result:= 'REPROCESS';
 else
 p_result:= 'UNLOCKABLE';
 p_err_code:= 0;
 p_err_msg:='Success';
 v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
 return;
 end if;

   else
      -- CR39592 Start PMistry 03/01/2016 for Safe Link and UNLACKABLE replacement return UNLOCK EXCHANGE.
      if l_sl_enrolled = 1 then
        p_result := 'UNLOCK EXCHANGE';
        -- Get Replacement part number
        sa.ADFCRM_CASE.get_repl_part_number (ip_case_conf_objid   => v_case_conf_objid,
                                           ip_case_type           => v_case_type,
                                           ip_title               => v_title,
                                           ip_esn                 => v_esn,
                                           ip_sim                 => NULL,
                                           ip_repl_logic          => v_repl_logic, -- NULL, NAP_DIGITAL,  DEFECTIVE_PHONE, DEFECTIVE_SIM, GOODWILL
                                           ip_zipcode             => l_repl_zip_code,      -- CR42603 05/02/2016 PMistry passing zip code as NULL
                                           op_part_number         => v_part_number,
                                           op_sim_profile         => v_sim_profile,
                                           op_sim_suffix          => v_sim_suffix);
        if v_part_number is null and p_source_system <> 'TAS' then
            p_err_code:= '1120';
            p_err_msg:='ERROR: Replacement part not found';
        else
            p_err_code:= 0;
            p_err_msg := 'SUCCESS';
        end if;
        v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);
        return;
      else
        p_result := 'BUY BACK PROGRAM';
      end if;
      -- CR39592 End PMistry 03/01/2016
   end if;

   p_err_code:= 0;
   p_err_msg := 'SUCCESS';
   v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,p_result,p_trade_value,p_paid_days,p_active_days,p_err_code,p_err_msg);


END VERIFY_ELEGIBILITY;

 procedure CREATE_REQUEST(p_esn in varchar2,
                          p_min in varchar2,
                          p_overwrite in varchar2 DEFAULT 'false',
                          p_login_name in varchar2 DEFAULT 'CBO',
                          p_source_system in varchar2 DEFAULT 'TAS',
                          p_first_name in varchar2,
                          p_last_name in varchar2,
                          p_address_1 in varchar2,
                          p_address_2 in varchar2,
                          p_city in varchar2,
                          p_state in varchar2,
                          p_zipcode in varchar2,
                          p_email in varchar2,
                          p_contact_phone in varchar2,
                          p_airbill in varchar2, --ELECTRONIC, PHYSICAL
                          p_keep_service in varchar2 DEFAULT 'false',   --CR39592 PMistry 03/03/2016 FCC SL UNLOCK
                          p_repl_part_number in out varchar2,           --CR39592 PMistry 03/03/2016 FCC SL UNLOCK
                          p_coupon in varchar2 DEFAULT '', --CR44455 Upgrade credit
                          p_id_number out varchar2,
                          p_err_code out varchar2,
                          p_err_msg  out VARCHAR2) IS

PRAGMA AUTONOMOUS_TRANSACTION;

  --Part Int Cursor
  cursor part_inst_cur (v_esn varchar2) is
  select pi.x_part_inst2contact, bo.COLLECTN_STS gl_account, pc.name part_class_name, pi.x_iccid, pc.objid  part_class_objid
  from sa.table_part_inst pi,
       sa.table_mod_level ml,
       sa.table_part_num pn,
       sa.table_bus_org bo,
       sa.table_part_class pc
  where pi.part_serial_no =  v_esn
  and pi.x_domain = 'PHONES'
  and PI.N_PART_INST2PART_MOD = ml.objid
  and ML.PART_INFO2PART_NUM = pn.objid
  and PN.PART_NUM2BUS_ORG = bo.objid
  and pc.objid = pn.part_num2part_class;

 part_inst_rec part_inst_cur%rowtype;

 --Service By Min Cursor
 cursor service_by_min_cur (v_min varchar2) is
 select x_service_id
 from sa.table_site_part sp
 where sp.x_min = v_min
 and sp.part_status in ('Active','CarrierPending');

 service_by_min_rec service_by_min_cur%rowtype;

 cursor user_cur is
 select * from sa.table_user
 where s_login_name = upper(p_login_name);

 user_rec user_cur%rowtype;

  -- CR39592 Start PMistry 03/01/2016 Modify the package to make is parameterize to use it with other cases.
  cursor case_conf_cur (c_param_name sa.table_x_parameters.x_param_name%TYPE) is
    select *
    from sa.table_x_case_conf_hdr
    where objid in (select x_param_value
                    from sa.table_x_parameters
                    where x_param_name = c_param_name );  --'ADFCRM_UNLOCK_BUYBACK_CASE_CONF');
  case_conf_rec case_conf_cur%rowtype;

  -- CR39592 PMistry 03/01/2016 Added case cursor to get case id.
  cursor case_search_cur (v_esn varchar2, v_case_type varchar2, v_title varchar2)
  is
  select id_number, gb.title, c.objid
  from sa.table_case c, sa.table_gbst_elm gb
  where c.x_esn = v_esn
  and c.x_case_type = v_case_type
  and c.title = v_title
  and gb.objid = c.casests2gbst_elm
  order by c.objid desc;

  case_search_rec case_search_cur%rowtype;


  cursor class_exch_option_cur (c_part_class_objid   varchar2,
                                c_new_part_number    varchar2,  --BASE PART NUM
                                c_sim_suffix         varchar2)
  is
      select  X_SIM_PART_NUMBER, X_upd_PART_NUMBER
      from sa.table_x_class_exch_options exch, sa.table_part_num pn
      where x_exch_type = 'UNLOCK'
      and source2part_class = c_part_class_objid
      and pn.part_number = exch.X_SIM_PART_NUMBER
      and pn.prog_type = c_sim_suffix
      and (x_new_part_num = c_new_part_number or x_used_part_num = c_new_part_number);

  class_exch_option_rec     class_exch_option_cur%rowtype;

  cursor SL_subscriber_cur (c_esn    varchar2) is
        select slc. X_CURRENT_ESN, sls.FULL_NAME, sls.ADDRESS_1, sls.CITY, sls.STATE, sls.ZIP
        from sa.X_SL_CURRENTVALS slc, sa.X_SL_SUBS sls
        where slc. X_CURRENT_ESN = c_esn
        and   slc.LID = sls.LID
        and   upper(regexp_replace(sls.FULL_NAME,'[^A-Za-z]','')) =
              upper(regexp_replace((p_first_name||p_last_name),'[^A-Za-z]','')) --CR44350 Safelink Special Characters Update, Excluding period when comparing
        ;

  SL_subscriber_rec SL_subscriber_cur%rowtype;

  l_repl_zip_code   varchar2(10);
  -- CR39592 End PMistry 03/01/2016


 cursor part_inst_cur2 (v_esn varchar2,v_hex varchar2) is
 select part_serial_no
 from sa.table_part_inst
 where (part_serial_no = v_esn or part_serial_no = v_hex)
 and x_domain = 'PHONES';

 part_inst_rec2 part_inst_cur2%rowtype;

  v_result varchar2(30);
  v_err_code varchar2(200);
  v_err_msg varchar2(200);
  v_trade_in_value number;
  v_paid_days number;
  v_active_days number;
  v_esn varchar2(30);
  v_contact_objid number;
  v_case_type varchar2(30);
  v_title varchar2(80);
  v_case_conf_objid   sa.table_x_case_conf_hdr.objid%type;
  v_user_objid number;
  v_address varchar2(300);
  v_case_objid varchar2(30);
  v_ele_airbill varchar2(30):='BB-EX-AIRBILL';
  v_airbill varchar2(30):='BP-EX-SHIPAIRBILL';
  v_part_request varchar2(100);
  v_buyback_pn varchar2(30):='BUYBACKCHECK';
  v_address_check_count number;
  v_duplicate_case number;
  v_hex varchar2(30);
  v_case_id  varchar2(30);
  l_esn varchar2(30);
  l_min varchar2(30);
  v_case_detail     varchar2(400);
  v_issue           varchar2(100);
  v_sim_profile     varchar2(100);
  v_sim_suffix      varchar2(100);
  v_zipcode         varchar2(10);
  v_message         varchar2(400);            -- CR39592 PMistry 03/04/2016
  l_sl_enrolled     number := 0;              -- CR39592 PMistry 04/06/2016
  v_log number;                               -- CR39592 PMistry 04/06/2016
  v_repl_logic		varchar2(30);

 function valid_email(p_email in varchar2)
 return number
 is
 cemailregexp constant varchar2(1000) := '^[a-z0-9!#$%&''*+/=?^_`{|}~-]+(\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+([A-Z]{2}|arpa|biz|com|info|intww|name|net|org|pro|aero|asia|cat|coop|edu|gov|jobs|mil|mobi|museum|pro|tel|travel|post)$';

 begin
 if regexp_like(p_email,cemailregexp,'i') then
 return 1;
 else
 return 0;
 end if;

 exception
 when others then return 0;
 end;

BEGIN
 if p_airbill='ELECTRONIC' then
     --CR44455 Create case only with AIRBILL for return of device.
    if length(trim(nvl(p_coupon,''))) > 0 then
		v_part_request := v_ele_airbill;
	else
		v_part_request:=v_buyback_pn||'||'||v_ele_airbill;
	end if;

 if valid_email(p_email=>p_email) = 0 then
 p_err_code:= '2005';
 p_err_msg:='ERROR: Valid email is required for ELECTRONIC Airbill';
 return;
 end if;

 else
    --CR44455 Create case only with AIRBILL for return of device.
    if length(trim(nvl(p_coupon,''))) > 0 then
		v_part_request := v_airbill;
	else
		v_part_request:=v_buyback_pn||'||'||v_airbill;
	end if;
 end if;

 --Find ESN from MIN
 if p_esn is null then
 open service_by_min_cur(p_min);
 fetch service_by_min_cur into service_by_min_rec;
 if service_by_min_cur%found then
 close service_by_min_cur;
 v_esn := service_by_min_rec.x_service_id;
 else
 close service_by_min_cur;
 p_err_code:= '2010';
 p_err_msg:='ERROR: Device not found in inventory';
 return;
 end if;
 else
 begin
 v_hex := sa.HEX2DEC(HEXVAL => p_esn);
 exception
 when others then
 v_hex := p_esn;
 end;
 open part_inst_cur2(p_esn,v_hex);
 fetch part_inst_cur2 into part_inst_rec2;
 if part_inst_cur2%found then
 close part_inst_cur2;
 v_esn := part_inst_rec2.part_serial_no;
 else
 close part_inst_cur2;
 p_err_code:= '2010';
 p_err_msg:='ERROR: Device not found in inventory';
 return;
 end if;

 end if;

 --Verify Valid Names
 if not (p_first_name is not null and regexp_like(p_first_name,'^[a-zA-Z ]+$') and
			p_last_name is not null and regexp_like(p_last_name,'^[a-zA-Z ]+$')) then

 p_err_code:= '2022';
 p_err_msg:='ERROR: Invalid First or Last Name';
 return;

 end if;

 if p_address_1 is null then

 p_err_code:= '2023';
 p_err_msg:='ERROR: Invalid Address';
 return;

 end if;

 if not (p_city is not null and regexp_like(p_city,'^[a-zA-Z ]+$')) then

 p_err_code:= '2024';
 p_err_msg:='ERROR: Invalid City';
 return;

 end if;

 if p_zipcode is null then
 p_err_code:= '2025';
 p_err_msg:='ERROR: Invalid Zipcode';
 return;
 end if;


 --Find User
 --IF NVL(p_source_system, 'TAS') <> 'WEB' -- Adding this if condition as this fails always for WEB
 --THEN
 open user_cur;
 fetch user_cur into user_rec;
 if user_cur%found then
 close user_cur;
 v_user_objid := user_rec.objid;
 else
 close user_cur;
 p_err_code:= '2030';
 p_err_msg:='ERROR: User not found';
 return;
 END IF;
 --END IF;



 VERIFY_ELEGIBILITY(
 P_ESN => p_esn,
 P_MIN => p_min,
 P_OVERWRITE => P_OVERWRITE,
 P_RESULT => v_result,
 P_TRADE_VALUE => v_trade_in_value,
 P_PAID_DAYS => v_paid_days,
 P_ACTIVE_DAYS => v_active_days,
 P_ERR_CODE => v_err_code,
 P_ERR_MSG => v_err_msg
 );

  -- CR39592 Start PMistry 03/02/2016 If eligibility returns bad address then update the address and update the case status.
    if p_address_2 is not null then
       v_address:=p_address_1||'||'||p_address_2;
    else
       v_address:=p_address_1;
    end if;

  if v_result = 'NOT ELIGIBLE' and v_err_code in ('1150','1151') then
    if v_err_code = '1151' then
      open case_conf_cur('ADFCRM_UNLOCK_CASE_CONF');
    else
      open case_conf_cur('ADFCRM_UNLOCK_BUYBACK_CASE_CONF');
    end if;
    -- CR39592 End PMistry 03/01/2016
    fetch case_conf_cur into case_conf_rec;
    if case_conf_cur%found then
       v_case_type := case_conf_rec.x_case_type;
       v_title := case_conf_rec.x_title;
    end if;

    close case_conf_cur;

    open case_search_cur(v_esn,v_case_type,v_title);
    fetch case_search_cur into case_search_rec;
    v_case_objid := case_search_rec.objid;
    p_id_number := case_search_rec.id_number;
    close case_search_cur;

    update sa.table_case
    set alt_address     = v_address,
        alt_city        = p_city,
        alt_state       = p_state,
        alt_zipcode     = p_zipcode
    where objid = v_case_objid;

      sa.clarify_case_pkg.update_status(  p_case_objid      => v_case_objid ,
                                           p_user_objid     => v_user_objid ,
                                           p_new_status     => 'Address Updated' ,
                                           p_status_notes   => 'New Status received with Buy Back / Unlock exchange' ,
                                           p_error_no       => v_err_code ,
                                           p_error_str      => v_err_msg );
      p_err_code:= '0';
      p_err_msg := 'SUCCESS';
     return;
  end if;
  -- CR39592 Start PMistry 03/02/2016 Select the case based on Eligibility
  if v_result =  'UNLOCK EXCHANGE' then
    open case_conf_cur('ADFCRM_UNLOCK_CASE_CONF');
  else
    open case_conf_cur('ADFCRM_UNLOCK_BUYBACK_CASE_CONF');
  end if;
  -- CR39592 End PMistry 03/01/2016
  fetch case_conf_cur into case_conf_rec;
  v_case_type := null;
  v_title     := null;
  if case_conf_cur%found then
     v_case_type := case_conf_rec.x_case_type;
     v_title := case_conf_rec.x_title;
  end if;
  close case_conf_cur;


      open case_search_cur(v_esn,v_case_type,v_title);
      fetch case_search_cur into case_search_rec;
  -- CR39592 PMistry 03/01/2016 modify to include UNLOCK EXCHANGE.
  if v_result in ('BUY BACK PROGRAM', 'UNLOCK EXCHANGE')  then

 --Find Contact
 open part_inst_cur(v_esn);
 fetch part_inst_cur into part_inst_rec;
 if part_inst_cur%found then
 close part_inst_cur;
 v_contact_objid := part_inst_rec.x_part_inst2contact;
 else
 close part_inst_cur;
 p_err_code:= '2020';
 --p_err_msg:='ERROR: Not contact associated to device';
 p_err_msg:= 'ERROR: Device not eligible';
 return;
 end if;

 /*   CR42344 Modify the query to look from MV inplace for case table to avoid full table scan on it.
 select count(*)
 into v_address_check_count
 from sa.table_case
 where x_case_type = v_case_type
 and title = v_title
 and creation_time >= sysdate - 365
 and trim(upper(alt_first_name))= trim(upper(p_first_name))
 and trim(upper(alt_last_name)) = trim(upper(p_last_name))
 and ( trim(upper(alt_address)) = trim(upper(p_address_1)) or trim(upper(alt_address))= trim(upper(p_address_1))||'||'||trim(upper(p_address_2)))
 and trim(alt_zipcode) = trim(p_zipcode);
 */

  SELECT COUNT(1)
  INTO v_address_check_count
  FROM sa.ADFCRM_UNLOCK_CASE_MATVIEW
  WHERE x_case_type              = v_case_type
  AND title                      = v_title
  --AND creation_time             >= sysdate - 365
  AND alt_first_name= trim(upper(p_first_name))
  AND alt_last_name = trim(upper(p_last_name))
  AND ( alt_address = trim(upper(p_address_1))  OR alt_address    = trim(upper(p_address_1)) ||'||' ||trim(upper(p_address_2)))
  AND alt_zipcode = trim(p_zipcode);


 if v_address_check_count>0 then
 p_err_code:= '2040';
 p_err_msg:='ERROR: Previous case created for same name and address within 12 months';
 return;
 end if;

 select count(*)
 into v_duplicate_case
 from sa.table_case
 where x_esn = v_esn
 and x_case_type = v_case_type
 and title = v_title;

    if v_duplicate_case>0 then
       p_err_code:= '2050';
       p_err_msg:='ERROR: Case already exists';
       return;
    end if;
    -- CR39592 Start PMistry 03/02/2016 Get replacement part number for Unlock Exchange.
    if v_result = 'UNLOCK EXCHANGE' then
      l_sl_enrolled := sl_enroll_fn(v_esn);
      if l_sl_enrolled = 1 then
        open SL_subscriber_cur(v_esn);
        fetch SL_subscriber_cur into SL_subscriber_rec;

        if SL_subscriber_cur%notfound then
          p_err_code:= '2060';
          p_err_msg:='ERROR: The information provided does not match with our Safelink records';
          v_log := insert_log(p_login_name,p_overwrite,v_esn,p_min,v_result,v_trade_in_value,v_paid_days,v_active_days,p_err_code,p_err_msg);

          return;

        end if;
        close SL_subscriber_cur;
      end if;
      if p_repl_part_number is null then
      -- Get Replacement part number
        sa.ADFCRM_CASE.get_repl_part_number (ip_case_conf_objid   => v_case_conf_objid,
                                             ip_case_type           => v_case_type,
                                             ip_title               => v_title,
                                             ip_esn                 => v_esn,
                                             ip_sim                 => NULL,
                                             ip_repl_logic          => v_repl_logic, -- NULL, NAP_DIGITAL,  DEFECTIVE_PHONE, DEFECTIVE_SIM, GOODWILL
                                             ip_zipcode             => l_repl_zip_code,      -- CR42603 05/02/2016 PMistry passing zip code as NULL
                                             op_part_number         => p_repl_part_number,
                                             op_sim_profile         => v_sim_profile,
                                             op_sim_suffix          => v_sim_suffix);

        if p_repl_part_number is null then
          p_err_code:= '2020';
          p_err_msg:='ERROR: Replacement part not found';
          return;
        end if;
      end if;
        v_part_request := p_repl_part_number||v_sim_suffix;
        if  v_sim_suffix is not null then
		  open class_exch_option_cur( part_inst_rec.part_class_objid,
                                      p_repl_part_number,
                                      v_sim_suffix);
          fetch class_exch_option_cur into class_exch_option_rec;
          close class_exch_option_cur;

          if class_exch_option_rec.X_SIM_PART_NUMBER is not null then
            v_part_request := p_repl_part_number||v_sim_suffix||'||'||class_exch_option_rec.X_SIM_PART_NUMBER;
          end if;
        end if;
        v_issue  := 'UNLOCK EXCHANGE';
    else
      v_case_detail := 'TRADE_IN_VALUE||'||v_trade_in_value||'||GL_ACCOUNT||'||part_inst_rec.GL_ACCOUNT;
      v_issue  := 'UNLOCK BUY BACK';
    end if;

    -- CR39592 End PMistry 03/01/2016

	-- CR44455 Add the promo code/coupon in case detail
    if length(trim(nvl(p_coupon,''))) > 0 then
		if v_case_detail is null then
			v_case_detail := 'PROMO_CODE||'||trim(p_coupon);
		else
			v_case_detail := v_case_detail||'||PROMO_CODE||'||trim(p_coupon);
		end if;
		v_issue := 'UPGRADE CREDIT';
	end if;

    sa.CLARIFY_CASE_PKG.CREATE_CASE(
        P_TITLE => v_title,
        P_CASE_TYPE => v_case_type,
        P_STATUS => 'Pending',
        P_PRIORITY => 'Low',
        P_ISSUE => v_issue,
        P_SOURCE => p_source_system,
        P_POINT_CONTACT => null,
        P_CREATION_TIME => sysdate,
        P_TASK_OBJID => null,
        P_CONTACT_OBJID => v_contact_objid,
        P_USER_OBJID => v_user_objid,
        P_ESN => v_esn,
        P_PHONE_NUM => p_contact_phone,
        P_FIRST_NAME => P_FIRST_NAME,
        P_LAST_NAME => P_LAST_NAME,
        P_E_MAIL => p_email,
        P_DELIVERY_TYPE => null,
        P_ADDRESS => v_address,
        P_CITY => p_city,
        P_STATE => p_state,
        P_ZIPCODE => p_zipcode,
        P_REPL_UNITS => null,
        P_FRAUD_OBJID => null,
        P_CASE_DETAIL => v_case_detail,   -- CR39592 PMistry 03/02/2016 Pass the case detail from input parameter for Unlock Exchange --*** i_KEEP SERVICE value pair
        P_PART_REQUEST => v_part_request,  --*** Part number to the customer
        P_ID_NUMBER => p_id_number,
        P_CASE_OBJID => v_case_objid,
        P_ERROR_NO => v_err_code,
        P_ERROR_STR => v_err_msg
      );
       -- CR39592 Start PMistry 03/30/2016 Added to update Keep Service for Unlock Exchange.
       if p_keep_service <> 'false' and v_result = 'UNLOCK EXCHANGE' then
          sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL( P_CASE_OBJID => v_case_objid,--esn_info_rec.case_objid,
                                               P_USER_OBJID => v_user_objid,
                                               P_CASE_DETAIL => 'KEEP_SERVICE'||'||'||p_keep_service,
                                               P_ERROR_NO => p_err_code,
                                               P_ERROR_STR => p_err_msg );

       end if;
       -- CR39592 End.
	-- CR39592 PMistry 03/18/2016 Added to skip for Unlock Exchange.
      if v_result = 'BUY BACK PROGRAM' then
        update sa.table_x_part_request
        set X_STATUS = 'ONHOLDST'
        where REQUEST2CASE = v_case_objid
        and X_REPL_PART_NUM = v_buyback_pn;
      end if;

 commit;

 if v_err_code = '0' then
 CLARIFY_CASE_PKG.DISPATCH_CASE(
 P_CASE_OBJID => v_case_objid,
 P_USER_OBJID => v_user_objid,
 P_QUEUE_NAME => null,
 P_ERROR_NO => v_err_code,
 P_ERROR_STR => v_err_msg
 );
 end if;
 end if;

   p_err_code := v_err_code;
   p_err_msg := v_err_msg;
   if p_err_code = '0' then
      commit;         -- CR39592 PMistry 03/28/2016
   end if;
END;

--CR39303 - New procedure to update email and reprocess count

PROCEDURE UNLOCK_REPROCESS_PRC (p_case_id in varchar2,p_esn in varchar2,p_email in varchar2,p_err_code out varchar2,p_err_msg out varchar2)
IS
 v_case_id varchar2(100);

 CURSOR c_reprocess IS
 SELECT tcd.x_value,tc.objid FROM table_case tc,table_x_case_detail tcd
 WHERE tc.objid=tcd.detail2case
 and tcd.x_name='REPROCESS_COUNT'
 and tc.id_number =v_case_id;

 c_reprocess_rec c_reprocess%rowtype;
 re_count varchar2(30);

BEGIN
 v_case_id:=p_case_id;

 IF p_case_id is null
 THEN
 v_case_id:= unlock_case_fn(p_esn,NULL);
 END IF;

 IF v_case_id is NULL
 THEN
 p_err_code:='1';
 p_err_msg:='Unable to find the case_id';
 return;
 END IF;

 OPEN c_reprocess;
 FETCH c_reprocess INTO c_reprocess_rec;
 CLOSE c_reprocess;

 re_count := nvl(c_reprocess_rec.x_value,0) +1;

 UPDATE table_x_case_detail
 SET x_value =re_count
 WHERE detail2case=c_reprocess_rec.objid --p_case_id
 AND x_name='REPROCESS_COUNT';

 UPDATE table_case
 SET alt_e_mail =p_email
 WHERE id_number=v_case_id;

 p_err_code:='0';
 p_err_msg:='Success';

 exception
 When others then
 p_err_code := '1';
 p_err_msg :='Error in updating Reprocess Count';

END UNLOCK_REPROCESS_PRC;
--CR39303 ends




FUNCTION REPROCESS_COUNT_FN ( p_case_id in varchar2) return varchar2
 IS

 CURSOR c_reprocess IS
 SELECT tcd.x_value FROM table_case tc,table_x_case_detail tcd
 WHERE tc.objid=tcd.detail2case
 and tcd.x_name='REPROCESS_COUNT'
 and tc.objid =p_case_id;

 c_reprocess_rec c_reprocess%rowtype;
 re_count varchar2(30);

 BEGIN

 OPEN c_reprocess;
 FETCH c_reprocess INTO c_reprocess_rec;
 CLOSE c_reprocess;

 re_count := nvl(c_reprocess_rec.x_value,0) +1;

 UPDATE table_x_case_detail
 SET x_value =re_count
 WHERE detail2case=p_case_id
 AND x_name='REPROCESS_COUNT';

 RETURN re_count;

END REPROCESS_COUNT_FN;


procedure UNLOCK_SPC_ENCRYPT_PRC (
 p_esn in out varchar2,
 p_po out varchar2,
 p_spc out varchar2,
 p_encryptedcode1 out varchar2,
 p_encryptedcode2 out varchar2,
 p_encryptedcode3 out varchar2,
 p_encryptedsessionkey out varchar2,
 p_cryptocert out varchar2,
 p_keytransportalgorithm out varchar2,
 p_decryptalgorithm out varchar2,
		 p_unlock_status out varchar2,
 p_err_code out varchar2,
 p_err_msg out varchar2)

                                  is
      Cursor c_unlock
        is
      select *
      from  unlock_spc_encrypt
      where esn= p_esn
      and   ( encryptedcode1 is not null or             -- CR39592 PMistry 03/22/2016 to avoid unlocking process without encryption codes
              encryptedcode2 is not null or
              encryptedcode3 is not null );
       o_unlock  c_unlock%rowtype;

 BEGIN

 if p_esn is null then
 p_err_code :=1080;
 p_err_msg := 'Esn is null';
 end if;

 open c_unlock;
 fetch c_unlock into o_unlock;
 if c_unlock%found then


 p_po := o_unlock.po;
 p_spc := o_unlock.spc;
 p_encryptedcode1 := o_unlock.encryptedcode1;
 p_encryptedcode2 := o_unlock.encryptedcode2;
 p_encryptedcode3 := o_unlock.encryptedcode3;
 p_encryptedsessionkey := o_unlock.encryptedsessionkey ;
 p_cryptocert := o_unlock.cryptocert;
 p_keytransportalgorithm := o_unlock.keytransportalgorithm;
 p_decryptalgorithm := o_unlock.decryptalgorithm;
		 p_unlock_status := o_unlock.unlock_status;
 p_err_code := 0;
 p_err_msg := 'SUCCESS';

 close c_unlock;
 elsif c_unlock%notfound then
 p_err_code := 1081;
 p_err_msg := 'No Unlocking codes found';
 end if;


 exception
 when others then
 p_err_code := 2;
 p_err_msg :='No encryption codes found';


END UNLOCK_SPC_ENCRYPT_PRC;


procedure UNLOCKING_CODE_REQUEST(
 p_esn in varchar2,
 p_min in varchar2,
 p_login_name in varchar2 DEFAULT 'CBO',
 p_sourcesystem in varchar2,
 p_regen_flag in varchar2,
 p_ota_trans_id in varchar2,
 p_first_name in varchar2,
 p_last_name in varchar2,
 p_email in varchar2,
 p_address in varchar2,
 p_city in varchar2,
 p_state in varchar2,
 p_zipcode in varchar2,
 p_contact_phone in varchar2,
 p_overwrite in varchar2,
 p_unlocking_code1 in out varchar2,
								p_unlocking_code2 in out varchar2,
								p_unlocking_code3 in out varchar2,
 p_gencode in out varchar2, --Comma delimited output from SP_CODEGEN.
 p_spccode in out varchar2,
 p_id_number in out varchar2,
 p_call_trans in out varchar2,
 p_err_code out varchar2,
 p_err_msg out varchar2)

IS


 v_case_type CONSTANT varchar2(30) :='Unlock Policy';
 v_case_title CONSTANT varchar2(30) :='Unlock Phone Request';
 v_iphone_case_title CONSTANT varchar2(30) :='Unlock iPhone Request';
 v_tmo_case_title CONSTANT varchar2(30) :='Unlock TMO WL Request'; --CR40342 added for TMO

cursor esn_info_cur (p_esn in varchar2) is
select c.objid case_objid, c.x_esn, pi.x_sequence, bo.org_id, pi.x_iccid, sp.x_min,sp.objid site_part_objid,pi.x_part_inst_status,elm.title case_status,pi.n_part_inst2part_mod,pi.x_part_inst2contact,
pi.objid pi_objid,                  -- CR39592 PMistry 03/31/2016
pc.name,pn.part_number,
c.id_number,
(select pi2.part_inst2carrier_mkt from sa.table_part_inst pi2 where pi2.part_serial_no = sp.x_min and pi2.x_domain = 'LINES') carrier_objid
from sa.table_case c, sa.table_part_inst pi, sa.table_site_part sp, sa.table_mod_level ml, sa.table_part_num pn, sa.table_bus_org bo, sa.table_gbst_elm elm,table_part_class pc
where
--c.id_number = v_id_number and
pi.part_serial_no=p_esn
and c.x_esn = pi.part_serial_no
and pi.x_domain = 'PHONES'
and sp.x_service_id = c.x_esn
and sp.part_status in ('Active','CarrierPending','Inactive')
and pi.n_part_inst2part_mod = ml.objid
and ml.part_info2part_num = pn.objid
and pn.part_num2bus_org = bo.objid
and c.casests2gbst_elm = elm.objid
and pn.part_num2part_class=pc.objid
and c.x_case_type = v_case_type
and c.title in (v_case_title,v_iphone_case_title,v_tmo_case_title) --CR40342 added for TMO
order by sp.install_date asc;


esn_info_rec esn_info_cur%rowtype;

cursor user_cur is
select * from sa.table_user
where s_login_name = upper(p_login_name);

user_rec user_cur%rowtype;

    -- CR39592 Start PMistry 03/17/2016 added new cursor for FCC.
    CURSOR new_esn_info_cur (p_esn IN VARCHAR2)
    IS
			SELECT  c.objid case_objid,
					c.x_esn,
					pi.x_sequence,
					bo.org_id,
					pi.x_iccid,
					null x_min,
					null site_part_objid,
					pi.x_part_inst_status,
					elm.title case_status,
					pi.n_part_inst2part_mod,
					pi.x_part_inst2contact,
					pi.objid pi_objid, -- CR39592 PMistry 03/31/2016
					pc.name,
					pn.part_number,
					c.id_number,
					NULL carrier_objid
			FROM  sa.table_case c,
				  sa.table_part_inst pi,
				  sa.table_mod_level ml,
				  sa.table_part_num pn,
				  sa.table_bus_org bo,
				  sa.table_gbst_elm elm,
				  table_part_class pc
			WHERE
			  --c.id_number = v_id_number and
			  pi.part_serial_no         =p_esn
			AND c.x_esn                 = pi.part_serial_no
			AND pi.x_domain             = 'PHONES'
			AND pi.n_part_inst2part_mod = ml.objid
			AND ml.part_info2part_num   = pn.objid
			AND pn.part_num2bus_org     = bo.objid
			AND c.casests2gbst_elm      = elm.objid
			AND pn.part_num2part_class  =pc.objid
			AND c.x_case_type           = v_case_type
			AND c.title                IN (v_case_title,v_iphone_case_title,
			  v_tmo_case_title) --CR40342 added for TMO
			;

      new_esn_info_rec   new_esn_info_cur%rowtype;

      cursor class_exch_options_cur (c_new_esn                  varchar2,
                                     c_new_esn_part_number      varchar2 ) IS
            select exch.X_UPD_PART_NUMBER
            from sa.TABLE_X_CLASS_EXCH_OPTIONS exch,
                  ( select pn.part_num2part_class source_esn_part_class, c.objid case_objid ,
                          ( select   pn_sim.part_number new_sim_part_num
                            from sa.table_x_part_request pr_sim,
                                  sa.table_part_num pn_sim,
                                  sa.table_mod_level ml_sim,
                                  sa.table_x_sim_inv si
                            where pr_sim.request2case = c.objid
                            and   si.x_sim_serial_no = pr_sim.x_part_serial_no
                            and   ml_sim.objid = si.x_sim_inv2part_mod
                            and   pn_sim.objid = ml_sim.part_info2part_num
                            and   pn_sim.domain = 'SIM CARDS'
                            and   rownum <= 1) new_sim_part_num
                    from  table_x_part_request pr, table_case c, sa.table_part_inst pi, sa.table_mod_level ml, sa.table_part_num pn
                    where x_part_serial_no = c_new_esn
                    and   c.objid = pr.request2case
                    and   pi.part_serial_no = c.x_esn
                    and   ml.objid = pi.n_part_inst2part_mod
                    and   pn.objid = ml.part_info2part_num ) esn_values
            where exch.x_sim_part_number = esn_values.new_sim_part_num
            and  ( X_NEW_PART_NUM = c_new_esn_part_number or x_used_part_num = c_new_esn_part_number)
            and   exch.x_exch_type = 'UNLOCK'
            and   exch.source2part_class  = esn_values.source_esn_part_class;

      class_exch_opetions_rec    class_exch_options_cur%rowtype;

-- CR39592 End.


v_call_trans_objid varchar2(30);
v_action_text varchar2(20):='PERSGENCODE';
v_result varchar2(20):='Completed';
v_results VARCHAR2(300);
--Verify Eligibility Variables

P_OVERWRITES VARCHAR2(30);
v_trade_in_value VARCHAR2(30);
v_paid_days VARCHAR2(30);
v_active_days VARCHAR2(30);
v_err_code VARCHAR2(300);
v_err_msg VARCHAR2(300);
v_cmd_list varchar2(30):='UNLOCKING CODES';
v_action_type varchar2(50):='7';
v_user_objid number;
--v_array apex_application_global.vc_arr2;
v_sequence number;
v_gencode varchar2(32767);
v_code_count number:='1';
v_return varchar2(100);
v_message varchar2(100);
v_change_model_err_code VARCHAR2(300);
v_class_name varchar2(100);

--Case Creation Variables.
l_title varchar2(30) := 'Unlock Phone Request';
l_case_type CONSTANT varchar2(30) := 'Unlock Policy';
l_status CONSTANT VARCHAR2(3) := '65';
l_part_status CONSTANT varchar2(100) := 'UNLOCK_INACTIVE';
l_feature CONSTANT varchar2(30) :='FEATURE_PHONE';
l_device_type CONSTANT varchar2(20) :='DEVICE_TYPE';
l_technology CONSTANT varchar2(20) :='TECHNOLOGY';
l_tech_gsm CONSTANT varchar2(30):='GSM';
l_tech_cdma CONSTANT varchar2(30):='CDMA';
l_part_class CONSTANT varchar2(30):='TFBYOPC';
l_unlocked CONSTANT varchar2(30):='UNLOCKED';
l_mod number;
v_case_objid number;
l_case_id varchar2(30);
v_contact_objid number;
l_rep_count number;
l_esn varchar2(30);
l_min varchar2(30);
v_code number :=1;
p_err_code2 VARCHAR2(100);
p_err_msg2 varchar2(100);
v_unlock_type varchar2(100);
v_case_id_number number;
v_unlock_ready_count    number := 0;	-- CR39592 PMistry 03/04/2016
--Comma Delimit
l_input varchar2(32767) ;
--l_count binary_integer;
--l_array dbms_utility.lname_array;
seq varchar2(1000);
 cursor c(p_gen in varchar2) is
with t as
(select p_gen txt from dual)
select regexp_substr ( txt, '[^,]+', 1, level) data from t CONNECT BY level <= length (txt) - length (replace (txt, ',')) + 1;
 --Procedure for the Unlock status.
--CR39303 - Parameterised below procedure
 Procedure part_unlock_status(p_esn in varchar2,p_status IN varchar2 DEFAULT '65',p_part_status in Varchar2 DEFAULT 'UNLOCK_INACTIVE' ) is

 begin

 update table_part_inst
 set x_part_inst_status = p_status, part_status= p_part_status
 where part_serial_no =p_esn;

 exception
 		 when others then
 		 NULL;

 end part_unlock_status;

 --Function for the mod level of byop pc.
 function byop_mod return number is

 l_mod_objid number;
 begin
 select objid into l_mod_objid from table_part_num
 where part_num2part_class=( select objid
 from table_part_class
 where name =l_part_class);
 return l_mod_objid;

 exception
 when others then
 null;
 end byop_mod;

 --Proc for the mod level.
 procedure part_mod_level is

 byop_v number;
 begin

 		 byop_v := byop_mod;

 update sa.table_mod_level
 set part_info2part_num = byop_v
 where objid =l_mod;

 Exception
 		 when others then
 		 NULL;

 end part_mod_level;

 procedure up_unlock_sp_encrypt(p_esn in varchar2) is

 begin
 update unlock_spc_encrypt
 set unlock_status=l_unlocked
 where esn=p_esn;

 -- CR42871 Added to update the status in new table for unlock esn status.
 update unlock_esn_status
 set unlock_status=l_unlocked
 where esn=p_esn;

 exception
 when others then
 -- insert into error_table( error_text, error_date,action,key,program_name)
 -- values( 'unlock_spc_encrypt', sysdate, 'esn is not updated to the', 'p_esn','adfcrm_unlock_buyback_pkg.unlock_update');
 null;
 end up_unlock_sp_encrypt;



BEGIN

open user_cur;
fetch user_cur into user_rec;
if user_cur%found then
 close user_cur;
 v_user_objid := user_rec.objid;
else
 close user_cur;
 p_err_code:= '3010';
 p_err_msg:='ERROR: User not found';
 return;

end if;

p_overwrites := p_overwrite || '';

 if p_overwrites = '1' or p_overwrites = 'true'
 then
 p_overwrites :='true';
 elsif upper(p_overwrites) in ('TEST','ESCALATION') then --CR45269 Unlocking Solution ? 2 new flags
 Null;
 else
 p_overwrites :='false';
 end if;



 --verify the Eligibility for the unlocking
 sa.ADFCRM_UNLOCK_BUYBACK_PKG.VERIFY_ELEGIBILITY(P_LOGIN_NAME => p_login_name, P_ESN => p_esn,P_MIN => p_min,P_OVERWRITE => p_overwrites, P_RESULT => v_results, P_TRADE_VALUE => v_trade_in_value, P_PAID_DAYS => v_paid_days,
 P_ACTIVE_DAYS => v_active_days, P_ERR_CODE => v_err_code, P_ERR_MSG => v_err_msg );



 if v_results ='NOT ELIGIBLE' then
 p_err_code:= '3022';
 p_err_msg:='ERROR: NOT Eligible for the Unlocking';
 return;
 end if;

--CR39303 - For Iphone, if a case already open and not in close status
 if v_results ='ELIGIBLE - REQUEST PENDING' then
 v_case_id_number := unlock_case_fn(p_esn,null);
 SELECT max(objid) into v_case_objid FROM table_case WHERE id_number=v_case_id_number;
 -- Update the notes
 sa.CLARIFY_CASE_PKG.LOG_NOTES(P_CASE_OBJID => v_case_objid,
 P_USER_OBJID => v_user_objid,
 P_NOTES => 'Case in Request Pending',
 P_ACTION_TYPE => Null,
 P_ERROR_NO => v_err_code,
 P_ERROR_STR => v_err_msg
 );
 --Update reprocess Count
 UNLOCK_REPROCESS_PRC (p_case_id => v_case_id_number,
 p_esn => Null,
 p_email => p_email,
 p_err_code=> v_err_code,
 p_err_msg => v_err_msg);

 p_err_code:= '3022';
 p_err_msg:='ERROR: ELIGIBLE - REQUEST PENDING';
 return;
 end if;
--CR39303 - ends



 --Part Inst to Part Mod.

 l_mod := esn_info_rec.N_PART_INST2PART_MOD;
 dbms_output.put_line ('v_results :'||v_results);

--CR 39303- Check if Iphone, then change title to Unlock iPhone Request
 Begin
 SELECT pc.name into v_class_name
 FROM table_part_class pc,
 table_part_num pn,
 table_mod_level ml,
 table_part_inst pi
 WHERE pn.part_num2part_class= pc.objid
 AND ml.part_info2part_num =pn.objid
 AND pi.n_part_inst2part_mod = ml.objid
 AND PI.PART_SERIAL_NO = p_esn;
 exception
 when others then
 dbms_output.put_line ('Part Class not found');
 end;

 v_unlock_type := sa.GET_PARAM_BY_NAME_FUN(
 IP_PART_CLASS_NAME => v_class_name,
 IP_PARAMETER => 'UNLOCK_TYPE'
 );
 IF v_unlock_type='IPHONE'
 THEN
 l_title:='Unlock iPhone Request';
 ELSIF v_unlock_type= 'TMO_WL' THEN --CR40342 added for TMO
 l_title:='Unlock TMO WL Request';
 END IF;
--CR 39303 ends here


 if v_results ='UNLOCKABLE' then

 Begin
 select x_part_inst2contact into v_contact_objid from table_part_inst where part_serial_no=p_esn;
 exception
 when others then
 dbms_output.put_line ('No Contact for the ESN');
 end;
 dbms_output.put_line ('Contact :'||v_contact_objid);

 sa.CLARIFY_CASE_PKG.CREATE_CASE(
 P_TITLE => l_title,
 P_CASE_TYPE => l_case_type,
 P_STATUS => 'Pending',
 P_PRIORITY => 'Low',
 P_ISSUE => 'UNLOCKABLE',
 P_SOURCE => p_sourcesystem,
 P_POINT_CONTACT => null,
 P_CREATION_TIME => sysdate,
 P_TASK_OBJID => null,
 P_CONTACT_OBJID => v_contact_objid,
 P_USER_OBJID => v_user_objid,
 P_ESN => p_esn,
 P_PHONE_NUM => p_contact_phone,
 P_FIRST_NAME => P_FIRST_NAME,
 P_LAST_NAME => P_LAST_NAME,
 P_E_MAIL => p_email,
 P_DELIVERY_TYPE => null,
 P_ADDRESS => p_address,
 P_CITY => p_city,
 P_STATE => p_state,
 P_ZIPCODE => p_zipcode,
 P_REPL_UNITS => null,
 P_FRAUD_OBJID => null,
 P_CASE_DETAIL => null,
 P_PART_REQUEST => null,
 P_ID_NUMBER => p_id_number,
 P_CASE_OBJID => v_case_objid,
 P_ERROR_NO => v_err_code,
 P_ERROR_STR => v_err_msg );

 if v_err_code = '0' then

 sa.CLARIFY_CASE_PKG.DISPATCH_CASE(
 P_CASE_OBJID => v_case_objid,
 P_USER_OBJID => v_user_objid,
 P_QUEUE_NAME => null,
 P_ERROR_NO => v_err_code,
 P_ERROR_STR => v_err_msg
 );


--CR39303 - For Iphone there is no unlocking code but need to insert an entry in unlock_spc_encrypt
 IF v_unlock_type IN ('IPHONE','TMO_WL') --CR40342 added for TMO
 THEN
 INSERT INTO unlock_spc_encrypt (ESN,unlock_status) VALUES (p_esn,'LOCKED');
 COMMIT;
 END IF;

--CR39303 - Insert a record with 0 as resprocess count
 sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL( P_CASE_OBJID => v_case_objid,--esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_CASE_DETAIL => 'REPROCESS_COUNT'||'||'||'0',
 P_ERROR_NO => p_err_code,
 P_ERROR_STR => p_err_msg );

--CR39303 ends

 end if;
 end if; --Case Create completion.

 open esn_info_cur (p_esn);
 fetch esn_info_cur into esn_info_rec;

        if esn_info_cur%notfound then
            -- CR39592 Start PMistry 03/07/2016 modify the code to update the status NEW for safe link and also update the part num for GSM safe link.
            SELECT COUNT(*)
            INTO v_unlock_ready_count
            FROM unlock_esn_status
            WHERE ESN               =p_esn
            AND upper(unlock_status)='UNLOCK-READY'
            AND rownum              =1;
            -- CR39592 End.

            --if v_unlock_ready_count = 1 then
			if v_unlock_ready_count = 1 or ( upper(p_overwrites) in ('TEST','ESCALATION') ) then  ----CR45269 Unlocking Solution ? 2 new flags
              open new_esn_info_cur(p_esn);
              fetch new_esn_info_cur into esn_info_rec;
              close new_esn_info_cur;
            else
               close esn_info_cur;
               p_err_code:= '3022';
               p_err_msg:='ERROR: case not found';
               return;
            end if;

         end if;

 close esn_info_cur;

--CR39303- Check if Iphone, and it is a reprocess, reopen the case.
 v_unlock_type := sa.GET_PARAM_BY_NAME_FUN(
 IP_PART_CLASS_NAME => v_class_name,
 IP_PARAMETER => 'UNLOCK_TYPE'
 );

 IF v_unlock_type in ('IPHONE','TMO_WL') and v_results ='REPROCESS' and upper(esn_info_rec.case_status)='CLOSED' --CR40342 added for TMO
 THEN
 sa.CLARIFY_CASE_PKG.reopen_case(p_case_objid=>esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_ERROR_NO => v_err_code,
 P_ERROR_STR => v_err_msg );
 p_id_number := esn_info_rec.id_number;

 -- Update the notes
 sa.CLARIFY_CASE_PKG.LOG_NOTES(P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_NOTES => 'Case Reprocessed',
 P_ACTION_TYPE => Null,
 P_ERROR_NO => v_err_code,
 P_ERROR_STR => v_err_msg
 );

 --Update reprocess Count
 UNLOCK_REPROCESS_PRC (p_case_id => esn_info_rec.id_number,
 p_esn => Null,
 p_email => p_email,
 p_err_code=> v_err_code,
 p_err_msg => v_err_msg);

 if v_err_code='0' then
 p_err_code:= '0';
 p_err_msg:='SUCCESS';
 end if;
 RETURN;
 END IF;
--CR39303 Ends

 --Only in TAS we will get regenrated codes for the reprocess.
 if (nvl(v_results,'X') ='REPROCESS' and nvl(p_regen_flag,0) =1 and p_sourcesystem ='TAS' ) or ( nvl(v_results,'X') ='UNLOCKABLE')
 then
 -- Create Call Trans
 select sa.seq('x_call_trans') into v_call_trans_objid from dual;
 -- p_call_trans := v_call_trans_objid;
 begin
 insert into sa.table_x_call_trans
 (objid, call_trans2site_part, x_action_type, x_call_trans2carrier, x_call_trans2user,
 x_min,x_service_id, x_sourcesystem,x_transact_date,x_total_units,x_action_text,
 x_reason,x_result,x_sub_sourcesystem,x_iccid,update_stamp)
 values(v_call_trans_objid, esn_info_rec.site_part_objid, v_action_type, esn_info_rec.carrier_objid, v_user_objid,
 esn_info_rec.x_min, esn_info_rec.x_esn, p_sourcesystem, sysdate, 0, v_action_text,
 v_cmd_list, v_result, esn_info_rec.org_id, esn_info_rec.x_iccid, sysdate);

 exception
 when others then
 p_err_code:= '3030';
 p_err_msg:='ERROR: Failed to create transaction';
 return;
 end; --END OF CALL TRANS


 IF p_gencode IS NOT NULL THEN

 l_input := p_gencode;
-- dbms_utility.comma_to_table(list=>regexp_replace(l_input,'(^|,)','\1x'),tablen=>l_count,tab=> l_array );
 for i in c(l_input)
		 		 loop
 with t1 as (select i.data as txt from dual)
 select to_number(''||regexp_substr ( txt, '[^:]+', 1, level)) into seq
 from t1 CONNECT BY level <= length (txt) - length (replace (txt, ',')) + 1;

 IF i.data IS NOT NULL THEN
 --Insert Code Hist
 insert into sa.table_x_code_hist (objid,code_hist2call_trans,x_code_accepted,x_code_type,x_gen_code,x_seq_update,x_sequence)
 values (sa.seq('x_code_hist'),v_call_trans_objid,'YES','UNLOCK_'||v_code,i.data,'1',seq);

 --Update Unlocking Gencodes Case Details
 sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL( P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_CASE_DETAIL => 'UNLOCK_GENCODE_'||v_code||'||'||i.data,
 P_ERROR_NO => p_err_code,
 P_ERROR_STR => p_err_msg );
 if p_err_code <> '0' then
 return;
 end if;

 v_sequence := seq;
 v_code := v_code +1;
								 END IF;
 end loop;
 ELSE
 NULL;
 END IF;
 BEGIN
 v_sequence := v_sequence + 1;
 -- Update Sequence ESN
 update sa.table_part_inst
 set x_sequence = v_sequence
 where part_serial_no = esn_info_rec.x_esn
 and x_domain = 'PHONES';
 Exception
 when others then
 dbms_output.put_line ('Sequece is not updated');
 END;
 -- Insert Unlock Code in Case Details
 sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL(P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_CASE_DETAIL => 'UNLOCK_CODE1'||'||'||p_unlocking_code1,
 P_ERROR_NO => p_err_code,
 P_ERROR_STR => p_err_msg);
 if p_err_code <> '0' then
 return;
 end if;

 -- Insert Unlock Code in Case Details
 sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL(P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_CASE_DETAIL => 'UNLOCK_CODE2'||'||'||p_unlocking_code2,
 P_ERROR_NO => p_err_code,
 P_ERROR_STR => p_err_msg);
 if p_err_code <> '0' then
 return;
 end if;

 -- Insert Unlock Code in Case Details
 sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL(P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_CASE_DETAIL => 'UNLOCK_CODE3'||'||'||p_unlocking_code3,
 P_ERROR_NO => p_err_code,
 P_ERROR_STR => p_err_msg);
 if p_err_code <> '0' then
 return;
 end if;

 -- Insert Call_Trans_objid in Case Details
 sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL(P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_CASE_DETAIL => 'Call Trans'||'||'||v_call_trans_objid,
 P_ERROR_NO => p_err_code,
 P_ERROR_STR => p_err_msg );

				 if p_err_code <> '0' then
 return;
 end if;

				 -- Insert SPC codes in Case Details

 sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL( P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_CASE_DETAIL => 'SPC CODE'||'||'||NVL(p_spccode,'NULL'),
 P_ERROR_NO => p_err_code,
 P_ERROR_STR => p_err_msg );

 if p_err_code <> '0' then
 return;
 end if;


 -- Insert Part Number in Case Details

 sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL( P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_CASE_DETAIL => 'OLD_PART_NUMBER'||'||'||NVL(esn_info_rec.part_number,'NULL'),
 P_ERROR_NO => p_err_code,
 P_ERROR_STR => p_err_msg );

 if p_err_code <> '0' then
 return;
 end if;


 --Update Status of the Case solving
-- SA.CLARIFY_CASE_PKG.UPDATE_STATUS( P_CASE_OBJID => esn_info_rec.case_objid,
-- P_USER_OBJID => v_user_objid,
-- P_NEW_STATUS => 'Solving',
-- P_STATUS_NOTES => 'Unlocking Codes Generated',
-- P_ERROR_NO => p_err_code,
-- P_ERROR_STR => p_err_msg
-- );
 -- Close Case after codes are generated
 --CR39303 if UNLOCK_TYPE if Iphone, do not close the case. Added below If statement
 v_unlock_type := sa.GET_PARAM_BY_NAME_FUN( IP_PART_CLASS_NAME => v_class_name, IP_PARAMETER => 'UNLOCK_TYPE' );
 IF UPPER(NVL(v_unlock_type,'X')) NOT IN ('IPHONE','TMO_WL') --CR40342 added for TMO
 THEN
 sa.CLARIFY_CASE_PKG.CLOSE_CASE(
 P_CASE_OBJID => esn_info_rec.case_objid,
 P_USER_OBJID => v_user_objid,
 P_SOURCE => 'TAS',
 P_RESOLUTION => null,
 P_STATUS => 'Closed',
 P_ERROR_NO => p_err_code2,
 P_ERROR_STR => p_err_msg2);
 END IF;
 --CR39303 Ends

 end if; --End of codes

 if(nvl(v_results,'X') ='REPROCESS') then
 --Reprocess the count.
 l_rep_count:= REPROCESS_COUNT_FN(esn_info_rec.case_objid);

 else
 null;

 end if; --Reprocess


--CR39303 - Only Feature phones should be deactivited. Commenting below

--Deactivate Phone with past due
/*
		 if esn_info_rec.x_part_inst_status = '52' then

 SA.SERVICE_DEACTIVATION.DEACTSERVICE(
 ip_sourcesystem => p_sourcesystem,
 ip_userObjId => v_user_objid,
 ip_esn => esn_info_rec.x_esn,
 ip_min => esn_info_rec.x_min,
 ip_DeactReason => 'PASTDUE',
 intByPassOrderType => 0,
 ip_newESN => null,
 ip_samemin => null,
 op_return => v_return,
 op_returnMsg => v_message );

 end if;

*/

          -- CR39592 Start PMistry 03/07/2016 modify the code to update the status NEW for safe link and also update the part num for GSM safe link.

          Select count(*) into v_unlock_ready_count
          from unlock_esn_status
          where ESN=esn_info_rec.x_esn
          and upper(unlock_status)='UNLOCK-READY'
          and rownum=1;
       --Check for the PPE device.
        if (sa.GET_PARAM_BY_NAME_FUN(IP_PART_CLASS_NAME => esn_info_rec.name,IP_PARAMETER =>l_device_type)=l_feature)
          or v_unlock_ready_count = 1
           then

--CR39303 - Only Feature phone should be deactivited.
 		 if esn_info_rec.x_part_inst_status = '52' then
 sa.SERVICE_DEACTIVATION.DEACTSERVICE(
 ip_sourcesystem => p_sourcesystem,
 ip_userObjId => v_user_objid,
 ip_esn => esn_info_rec.x_esn,
 ip_min => esn_info_rec.x_min,
 ip_DeactReason => 'PASTDUE',
 intByPassOrderType => 0,
 ip_newESN => null,
 ip_samemin => null,
 op_return => v_return,
 op_returnMsg => v_message );
 end if;

    -- CR39303 - Update ESN's Part number to BYOP CDMA non LTE part mumber

              if (l_tech_cdma = sa.GET_PARAM_BY_NAME_FUN(IP_PART_CLASS_NAME => esn_info_rec.name,IP_PARAMETER =>l_technology))  then
                   v_change_model_err_code:=sa.ADFCRM_CARRIER.CHANGE_PHONE_MODEL(
                                            P_ESN             => esn_info_rec.x_esn,
                                            P_NEW_PART_NUMBER => l_part_class,
                                            P_USER            => p_login_name);
                   if v_unlock_ready_count =  1 then
                      part_unlock_status(p_esn,'50','NEW');
                   else
                      part_unlock_status(p_esn,'54','PASTDUE');
                   end if;

               else

                   if v_unlock_ready_count =  1 then

                      open class_exch_options_cur (esn_info_rec.x_esn,
                                                   esn_info_rec.part_number);
                      fetch class_exch_options_cur into class_exch_opetions_rec;
                      close class_exch_options_cur;
                      if class_exch_opetions_rec.x_upd_part_number is not null then
                        v_change_model_err_code:=sa.ADFCRM_CARRIER.CHANGE_PHONE_MODEL(P_ESN               => esn_info_rec.x_esn,
                                                                                      P_NEW_PART_NUMBER   => class_exch_opetions_rec.x_upd_part_number,
                                                                                      P_USER              => p_login_name);
                      end if;
                      part_unlock_status(p_esn,'50','NEW');
                   else
                      part_unlock_status(p_esn);
                   end if;
               end if;
               -- Expire Unlockable Phone Exchange alert for safe link if any open found.
               if v_unlock_ready_count = 1 then
                  update sa.table_alert
                  set    end_date = sysdate - 1,
                         modify_stmp = sysdate,
                         last_update2user = v_user_objid
                  where Title = 'SL Unlockable Phone Exchange'
                  and   alert2contract = esn_info_rec.pi_objid;

               end if;
              -- CR39592 End PMistry 03/07/2016.

 /*if (l_tech_gsm = sa.GET_PARAM_BY_NAME_FUN(IP_PART_CLASS_NAME => esn_info_rec.name,IP_PARAMETER =>l_technology))then
 --Unlock-Incactive status in the part_inst and the unlock spc encrypt to UNLOCKED.
 --part_unlock_status(p_esn);
 /* SA.SERVICE_DEACTIVATION.DEACTSERVICE(
 ip_sourcesystem => p_sourcesystem,
 ip_userObjId => v_user_objid,
 ip_esn => esn_info_rec.x_esn,
 ip_min => esn_info_rec.x_min,
 ip_DeactReason => 'Unlock_Inactive',
 intByPassOrderType => 0,
 ip_newESN => null,
 ip_samemin => null,
 op_return => v_return,
 op_returnMsg => v_message );


 elsif (l_tech_cdma = sa.GET_PARAM_BY_NAME_FUN(IP_PART_CLASS_NAME => esn_info_rec.name,IP_PARAMETER =>l_technology)) then
 --Update the mod level to BYOP CDMA non LTE and the unlock spc encrypt to UNLOCKED. .
 -- part_mod_level;
 null;
 end if; */
 end if;
--CR39303 unlock status is changed to unlocked except for Iphone
 IF UPPER(NVL(v_unlock_type,'X')) NOT IN ('IPHONE','TMO_WL') THEN --CR40342 added for TMO
 up_unlock_sp_encrypt(p_esn);
 END if;

 if p_err_code='0' then
 p_err_msg:='SUCCESS';
 end if;


 END UNLOCKING_CODE_REQUEST;

  -- CR39592 Start PMistry 03/16/2016 Added new procedure.
  procedure get_part_reqst_dtl ( i_esn               IN     varchar2,
                                 i_min               IN     varchar2,
                                 i_case_type         IN     varchar2,
                                 i_domain            IN     varchar2  DEFAULT 'PHONES',
                                 out_refcursor      OUT    SYS_REFCURSOR ,
                                 out_error_no       OUT    varchar2,
                                 out_error_str      OUT    varchar2) IS

  cursor get_esn_from_min_cur is
    select pi_ph.part_serial_no esn
    from sa.table_part_inst pi_ph, sa.table_part_inst pi_min
    where  pi_ph.x_domain = 'PHONES'
    and    pi_min.x_domain = 'LINES'
    and    pi_min.part_serial_no = i_min
    and    pi_min.part_to_esn2part_inst = pi_ph.objid;

  get_esn_from_min_rec    get_esn_from_min_cur%rowtype;

  cursor case_info_cur (c_esn     varchar2)is
    select c.objid, id_number, gb.title
    from sa.table_case c,
         sa.table_gbst_elm gb,
         (  select *
            from sa.table_x_case_conf_hdr
            where objid in (select x_param_value
                            from sa.table_x_parameters
                            where x_param_name = i_case_type )       ) param_type
    where c.x_esn = c_esn
    and c.x_case_type = param_type.x_case_type
    and c.title = param_type.X_Title
    and gb.objid = c.casests2gbst_elm;

    case_info_rec   case_info_cur%rowtype;

    l_esn     varchar2(60);
  begin
    out_error_no := '0';
    out_error_str := 'SUCCESS';

    if i_esn is null then
      open get_esn_from_min_cur;
      fetch get_esn_from_min_cur into get_esn_from_min_rec;
      close get_esn_from_min_cur;
      l_esn := get_esn_from_min_rec.esn;
    else
      l_esn := i_esn;
    end if;

    open case_info_cur(l_esn);
    fetch case_info_cur into case_info_rec;

    if case_info_cur%notfound then
      out_error_no := '-1';
      out_error_str := 'Case not found : ';
      return;
    end if;
    close case_info_cur;
    sa.clarify_case_pkg.get_part_reqst_dtl_by_caseid (  i_case_objid       => case_info_rec.objid,
                                                        i_domain           => i_domain,
                                                        out_refcursor      => out_refcursor ,
                                                        out_error_no       => out_error_no,
                                                        out_error_str      => out_error_str );
  exception
    when others then
      out_error_no := '-1';
      out_error_str := sqlerrm;

  end get_part_reqst_dtl;

  -- CR39592 End

END ADFCRM_UNLOCK_BUYBACK_PKG;
/