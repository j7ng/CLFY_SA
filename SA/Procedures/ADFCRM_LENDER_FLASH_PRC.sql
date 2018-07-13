CREATE OR REPLACE PROCEDURE sa."ADFCRM_LENDER_FLASH_PRC" (ip_min varchar2,
                                  ip_status varchar2, -- ACTIVE, DEFAULTED (THIS MEANS THEY ARE IN DEFAULT), INACTIVE (WILL NOT RECEIVE A FLASH)
                                  ip_lender varchar2 default 'PAYJOY',
                                  op_result out varchar2)
is
  v_esn varchar2(30);
  n_esn_objid number;
  n_alert_objid number;
  v_alert_title varchar2(100) := upper(ip_lender||'_'||ip_status);
  v_exist_alert_title varchar2(100);
  act_text varchar2(4000) := '<p>This is a PayJoy customer, continue to servicing account.</p>';
  def_text varchar2(4000) := '<p>Please contact PayJoy customer service: at (240) 428-4174, or <u>support@payjoy.com</u>  in order to make your monthly payment, unlock your device, or receive additional support.</p>';
begin

  op_result:='FAIL';

  if ip_status not in ('ACTIVE','DEFAULTED','INACTIVE') then
    return;
  end if;

  begin
    select p.part_serial_no,p.objid
    into   v_esn,n_esn_objid
    from   table_part_inst p,
          (select part_to_esn2part_inst
           from table_part_inst
           where part_serial_no = ip_min) m
    where  p.objid = m.part_to_esn2part_inst;
  exception
    when others then
      dbms_output.put_line('NO RECORD FOUND');
      return;
  end;
  for i in (select objid,title
            from table_alert
            where alert2contract = n_esn_objid)
  loop
    if i.title like ip_lender||'%' then
      n_alert_objid := i.objid;
      v_exist_alert_title := i.title;
      exit;
    end if;
  end loop;

  dbms_output.put_line('n_alert_objid ==> '||n_alert_objid);
  dbms_output.put_line('v_exist_alert_title ==> '||v_exist_alert_title);
  dbms_output.put_line('v_alert_title ==> '||v_alert_title);
  dbms_output.put_line('v_esn         ==> '||v_esn);
  dbms_output.put_line('n_esn_objid   ==> '||n_esn_objid);
  dbms_output.put_line('ip_min        ==> '||ip_min);
  dbms_output.put_line('ip_status     ==> '||ip_status);
  dbms_output.put_line('ip_lender     ==> '||ip_lender);

  if n_alert_objid is null then

    insert into sa.table_alert (objid,
                                type,
                                alert_text,
                                start_date,
                                end_date,
                                active,
                                title,
                                hot,
                                last_update2user,
                                alert2contract,
                                modify_stmp,
                                x_step)
    values (sa.seq('alert'),
            'GENERIC',
            decode(ip_status,'DEFAULTED',def_text,act_text), -- TAS text
            sysdate, -- Start Date
            sysdate + 730, -- End Date 2yrs
            1, -- Active
            v_alert_title, -- Title
            0, -- HOt
            268435556, -- last_update2user 268435556 -- sa user
            n_esn_objid, -- alert2contract is the esn_objid
            sysdate, -- modify_stmp
            '0'
            );

  else
    if v_alert_title like '%INACTIVE' then
      dbms_output.put_line('ALERT EXISTS - DELETE');
      delete table_alert where objid = n_alert_objid;
    elsif v_alert_title != v_exist_alert_title then
      dbms_output.put_line('UPDATE ALERT TO - '||v_alert_title);
      update table_alert
      set title = v_alert_title,
          alert_text = decode(ip_status,'DEFAULTED',def_text,act_text)
      where objid = n_alert_objid;
    else
      dbms_output.put_line('ALERT EXISTS - DO NOTHING');
    end if;
  end if;
  op_result:='SUCCESS';
exception
   when others then
    op_result:='FAIL';
end adfcrm_lender_flash_prc;
/