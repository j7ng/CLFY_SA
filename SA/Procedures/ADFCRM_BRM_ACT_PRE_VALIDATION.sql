CREATE OR REPLACE PROCEDURE sa."ADFCRM_BRM_ACT_PRE_VALIDATION"
(
  IP_WEB_USER_OBJID IN VARCHAR2
, IP_ESN IN VARCHAR2
, IP_SIM IN VARCHAR2
, IP_SEC_PIN IN VARCHAR2
, OP_ESN OUT VARCHAR2
, OP_SIM OUT VARCHAR2
, OP_SEC_PIN OUT VARCHAR2
, OP_MEMBER_COUNT OUT VARCHAR2
, OP_ERR_NO OUT VARCHAR2
, OP_ERR_MSG OUT VARCHAR2
) AS

v_esn varchar2(30);
v_esn_status varchar2(30);
v_sim varchar2(30);
v_sim_status varchar2(30);
v_esn_bus_objid varchar2(30);
v_max_account_members number:=5;
v_already_in_account number:=0;
v_sec_pin_number number;
v_emaildummy number:=0;
v_email_name varchar2(50);
v_email_domain varchar2(50);
v_rec_count number;

cursor part_inst_esn_cur is
select part_serial_no,x_iccid,x_part_inst_status,table_part_num.part_num2bus_org,table_bus_org.org_id
from sa.table_part_inst,sa.table_mod_level,sa.table_part_num,sa.table_bus_org
where part_serial_no = ip_esn
and x_domain = 'PHONES'
and N_PART_INST2PART_MOD=table_mod_level.objid
and table_part_num.objid = table_mod_level.part_info2part_num
and table_part_num.part_num2bus_org = table_bus_org.objid;

part_inst_esn_rec part_inst_esn_cur%rowtype;

cursor part_inst_sim_cur is
select part_serial_no,x_part_inst_status,x_iccid,x_sim_inv_status,x_sim_serial_no,part_num2bus_org
from sa.table_part_inst,sa.table_x_sim_inv,sa.table_mod_level,sa.table_part_num
where x_iccid = ip_sim
and x_domain = 'PHONES'
and x_sim_serial_no = ip_sim
and N_PART_INST2PART_MOD=table_mod_level.objid
and table_part_num.objid = table_mod_level.part_info2part_num;

part_inst_sim_rec part_inst_sim_cur%rowtype;

cursor sim_inv_cur (cv_sim varchar2) is
select x_sim_serial_no,x_sim_inv_status
from sa.table_x_sim_inv
where x_sim_serial_no = cv_sim;

sim_inv_rec sim_inv_cur%rowtype;


cursor account_cur (cv_web_user_objid varchar2,cv_bus_objid varchar2,cv_esn varchar2) is
select objid,web_user2bus_org,web_user2contact, (select count(*) from  sa.table_x_contact_part_inst,sa.table_part_inst
                                                 where x_contact_part_inst2contact=web_user2contact
                                                 and table_part_inst.objid = x_contact_part_inst2part_inst
                                                 and table_part_inst.part_serial_no = cv_esn
                                                 and table_part_inst.x_domain = 'PHONES') already_in_account,
                                             (select count(*) from sa.table_x_contact_part_inst cpi2,sa.table_part_inst pi2
                                              where cpi2.X_CONTACT_PART_INST2CONTACT=web_user2contact
                                              and pi2.objid = cpi2.X_CONTACT_PART_INST2PART_INST
                                              and (pi2.x_part_inst_status = '52'
											        or exists (select '1' from table_case c, table_condition co
											        where c.x_esn = pi2.part_serial_no
													and c.x_case_type = 'Port In'
													and c.case_state2condition = co.objid
													and co.title <> 'Closed'))) member_count
from sa.table_web_user
where objid = cv_web_user_objid
and web_user2bus_org = cv_bus_objid;

account_rec account_cur%rowtype;

cursor esn_account_cur(cv_esn varchar2) is
select wu.objid web_user_objid,wu.login_name,(select count(*) from sa.table_x_contact_part_inst cpi2,sa.table_part_inst pi2
                                              where cpi2.X_CONTACT_PART_INST2CONTACT=cpi.X_CONTACT_PART_INST2CONTACT
                                              and pi2.objid = cpi2.X_CONTACT_PART_INST2PART_INST
                                              and (pi2.x_part_inst_status = '52'
											        or exists (select '1' from table_case c, table_condition co
											        where c.x_esn = pi2.part_serial_no
													and c.x_case_type = 'Port In'
													and c.case_state2condition = co.objid
													and co.title <> 'Closed'))) member_count_esn
from sa.table_web_user wu,sa.table_x_contact_part_inst cpi,sa.table_part_inst pi
where cpi.X_CONTACT_PART_INST2PART_INST = pi.objid
and pi.part_serial_no = cv_esn
and pi.x_domain = 'PHONES'
and wu.web_user2contact = cpi.x_contact_part_inst2contact;

esn_account_rec esn_account_cur%rowtype;


BEGIN


  OP_ERR_NO := '0';
  OP_ERR_MSG := 'SUCCESS';
  OP_SEC_PIN := IP_SEC_PIN;
  OP_MEMBER_COUNT := 0;

  if ip_web_user_objid is null then
    OP_ERR_NO := '200';
    OP_ERR_MSG := 'Input parameters missing (web_user_objid)';
    RETURN;
  end if;

  if ip_esn is null and ip_sim is null then
    OP_ERR_NO := '205';
    OP_ERR_MSG := 'Input parameters missing (ESN,SIM)';
    RETURN;
  end if;

  if ip_esn is not null then

     open part_inst_esn_cur;
     fetch part_inst_esn_cur into part_inst_esn_rec;

     if part_inst_esn_cur%found then
        v_esn:=part_inst_esn_rec.part_serial_no;
        v_esn_status:=part_inst_esn_rec.x_part_inst_status;
        v_esn_bus_objid:=part_inst_esn_rec.part_num2bus_org;
        v_sim := part_inst_esn_rec.x_iccid;
        if v_sim is not null then
          open sim_inv_cur(v_sim);
          fetch sim_inv_cur into sim_inv_rec;
          if sim_inv_cur%found then
            v_sim_status := sim_inv_rec.x_sim_inv_status;
          end if;
		  close sim_inv_cur;
        end if;
     end if;
     close part_inst_esn_cur;

     if ip_sim is not null then
        open sim_inv_cur(ip_sim);
        fetch sim_inv_cur into sim_inv_rec;
        if sim_inv_cur%found then
            v_sim := sim_inv_rec.x_sim_serial_no;
            v_sim_status := sim_inv_rec.x_sim_inv_status;
        end if;
        close sim_inv_cur;
     end if;
  elsif ip_sim is not null then

    open part_inst_sim_cur;
    fetch part_inst_sim_cur into part_inst_sim_rec;

    if part_inst_sim_cur%found then
        v_sim := part_inst_sim_rec.x_sim_serial_no;
        v_sim_status := part_inst_sim_rec.x_sim_inv_status;
        v_esn:=part_inst_sim_rec.part_serial_no;
        v_esn_status:=part_inst_sim_rec.x_part_inst_status;
        v_esn_bus_objid:=part_inst_sim_rec.part_num2bus_org;
    end if;
    close part_inst_sim_cur;

  end if;

  OP_ESN := v_esn;
  OP_SIM := v_sim;

  if v_esn is null or v_esn_status is null then
      OP_ERR_NO := '210';
      OP_ERR_MSG := 'Invalid parameters (ESN)';
      RETURN;
  end if;

  if v_esn_status not in ('50','150','51','54') then
      OP_ERR_NO := '215';
      OP_ERR_MSG := 'Invalid ESN Status';
      RETURN;
  end if;

  if v_sim is null or v_esn_status is null then
      OP_ERR_NO := '220';
      OP_ERR_MSG := 'Invalid parameters (SIM)';
      RETURN;
  end if;

  --if  v_sim_status not in ('251','253') then
  --    OP_ERR_NO := '225';
  --    OP_ERR_MSG := 'Invalid SIM Status';
  --    RETURN;
  --end if;

  --Invalid Account or Bus Org Missmatch
  open account_cur(ip_web_user_objid,v_esn_bus_objid,v_esn);
  fetch account_cur into account_rec;
  if account_cur%notfound then
     close account_cur;
     OP_ERR_NO := '230';
     OP_ERR_MSG := 'Invalid parameters (Account/web_user_objid)';
     RETURN;
  else
     close account_cur;
     OP_MEMBER_COUNT:=account_rec.member_count;
     v_already_in_account:=account_rec.already_in_account;
	 if account_rec.member_count + 1 > v_max_account_members then
      OP_ERR_NO := '231';
      OP_ERR_MSG := 'Max number of member reached';
      RETURN;
     end if;
  end if;

  if part_inst_esn_rec.org_id= 'WFM' and v_already_in_account = 0 and (ADFCRM_IS_NUMERIC(ip_sec_pin) = 0 or length (ip_sec_pin)<>4) then
      OP_ERR_NO := '235';
      OP_ERR_MSG := 'Security Pin Required (4 digit number)';
      RETURN;
  end if;
  OP_SEC_PIN:=ip_sec_pin;

  if v_already_in_account=0 then
      open esn_account_cur(v_esn);
      fetch esn_account_cur into esn_account_rec;
      if esn_account_cur%found then
         close esn_account_cur;

         if esn_account_rec.member_count_esn > 1 then
           OP_ERR_NO := '240';
           OP_ERR_MSG := 'ESN belongs to an active account';
           RETURN;
         end if;

         v_email_name:= substr(esn_account_rec.login_name,1,instr(esn_account_rec.login_name,'@')-1);
         v_email_domain:=substr(esn_account_rec.login_name,instr(esn_account_rec.login_name,'@')+1);

         select count(*)
         into v_rec_count
         from sa.table_bus_org
         where upper(web_site) = upper('www.'||v_email_domain)
         and type='IT';

         if ADFCRM_IS_NUMERIC(v_email_name) = 1 and (v_rec_count > 0 or v_email_domain='tfWFM.com') then
            if esn_account_rec.web_user_objid <> ip_web_user_objid then
			   OP_ERR_NO := '250';
			   OP_ERR_MSG := 'ESN belongs to dummy account and can be moved';
			   RETURN;
			end if;
         else
           OP_ERR_NO := '240';
           OP_ERR_MSG := 'ESN belongs to an active account';
           RETURN;
         end if;


      else
         --esn not in an account
         close esn_account_cur;
      end if;
  end if;

  --Temp update since SOA service cannot process mix of New and Used.
  --update sa.table_part_inst
  --set x_part_inst_status = '50',status2x_code_table = 986
  --where part_serial_no = IP_ESN
  --and x_domain = 'PHONES'
  --and x_part_inst_status in ('51','54');
  --commit;

END ADFCRM_BRM_ACT_PRE_VALIDATION;
/