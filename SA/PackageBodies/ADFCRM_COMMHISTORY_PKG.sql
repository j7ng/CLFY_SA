CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_COMMHISTORY_PKG"
IS
  /*******************************************************************************************************
  --$RCSfile: ADFCRM_COMMHISTORY_PKB.sql,v $
  --$ $Log: ADFCRM_COMMHISTORY_PKB.sql,v $
  --$ Revision 1.7  2017/10/19 23:45:02  epaiva
  --$ CR51354 - dates for sms history
  --$
  --$ Revision 1.6  2017/10/19 20:42:17  epaiva
  --$ CR51354 - To handle null value cases for different brands and to manage old and new behavior of inserting records in table_x_cai_log table
  --$
  --$ Revision 1.5  2017/10/19 17:45:26  epaiva
  --$ CR51354 - To address initial records of communication
  --$
  --$ Revision 1.4  2017/10/17 15:46:52  epaiva
  --$ CR51354 - defect fix
  --$
  --$ Revision 1.2  2017/09/28 21:04:57  epaiva
  --$ CR51354 - To filter history with Date used by ADFCRM40
  --$
  --$ Revision 1.1  2017/09/26 15:54:47  epaiva
  --$ CR51354 -  opt in/out Communication history used by ADFCRMUC40
  --$
  --$
  --$
  *******************************************************************************************************/
    function get_smshistory_func(
 ip_contact_objid in number,
 ip_date in varchar2)
  return get_commhist_rec_tab pipelined
    is


   get_commhist_rslt get_commhist_rec;

    cursor c_smshist_info (p_contact_obj_id number,p_date varchar2) is
    select change_date, add_info2contact,new_sms_Val,u.login_name ,wu.login_name as web_login_name,x_min,SOURCE_SYSTEM
    from sa.table_x_cai_log ,  sa.table_user u, sa.table_web_user wu
    where add_info2contact= p_contact_obj_id
    and u.objid (+)  = add_info2user
    and wu.objid(+) = add_info2web_user
    and to_date(change_date,'dd-MON-yy') between to_date(p_date,'dd-MON-yy') and to_date(sysdate,'dd-MON-yy')
     and ((action = 'UPDATING' and nvl(old_sms_val,2) <> nvl(new_sms_val,2))
     or action = 'INSERTING')
   order by change_date desc;

    r_smshist_info c_smshist_info%ROWTYPE ;

   v_date varchar2(100);
    begin


     dbms_output.put_line(' SMS Input Values===================='||ip_contact_objid||'-'||ip_date);
  if ip_date is null then
  v_date:=to_date(sysdate - 30,'dd-MON-yy');
  else
  v_date:=ip_date;
  end if;

    dbms_output.put_line(' SMS Input Values===================='||ip_contact_objid||'-'||v_date);

    for sms_rec in c_smshist_info(ip_contact_objid,v_date)
        loop
           dbms_output.put_line('SMS Change date===================='||sms_rec.change_date||'- loginname - '||sms_rec.login_name);
            get_commhist_rslt.change_date         := sms_rec.change_date;
           get_commhist_rslt.add_info2contact             := sms_rec.add_info2contact;
            get_commhist_rslt.new_sms_Val     := nvl(sms_rec.new_sms_Val,1);
            if sms_rec.login_name is not null then
            get_commhist_rslt.login_name       := sms_rec.login_name;
            end if;
            if sms_rec.web_login_name is not null and sms_rec.SOURCE_SYSTEM <> 'TAS' then
           get_commhist_rslt.login_name          := sms_rec.web_login_name;
           end if;
            get_commhist_rslt.x_min       := sms_rec.x_min;
            get_commhist_rslt.SOURCE_SYSTEM          := sms_rec.SOURCE_SYSTEM;


            pipe row (get_commhist_rslt);
        end loop;

end;

  function get_mailhistory_func(
 ip_contact_objid in number,
  ip_date in varchar2)
  return get_commhist_rec_tab pipelined
    is


   get_commhist_rslt get_commhist_rec;

    cursor c_mailhist_info (p_contact_obj_id number, p_date varchar2) is
    select change_date, add_info2contact,new_mail_Val,u.login_name ,wu.login_name as web_login_name,x_min,SOURCE_SYSTEM
    from sa.table_x_cai_log ,  sa.table_user u, sa.table_web_user wu
    where add_info2contact= p_contact_obj_id
    and u.objid (+)  = add_info2user
    and wu.objid(+) = add_info2web_user
    and to_date(change_date,'dd-MON-yy') between to_date(p_date,'dd-MON-yy') and to_date(sysdate,'dd-MON-yy')
    and ((action = 'UPDATING' and nvl(old_mail_val,2) <> nvl(new_mail_val,2))
    or action = 'INSERTING')
    order by change_date desc;

    r_mailhist_info c_mailhist_info%ROWTYPE ;

     v_date varchar2(100);
    begin

     dbms_output.put_line(' Mail Input Values===================='||ip_contact_objid);

         if ip_date is null then
        v_date:=to_date(sysdate - 30,'dd-MON-yy');
        else
        v_date:=ip_date;
        end if;

    for mail_rec in c_mailhist_info(ip_contact_objid, v_date)
        loop
           dbms_output.put_line('Mail Change date===================='||mail_rec.change_date||'- loginname - '||mail_rec.login_name);
            get_commhist_rslt.change_date         := mail_rec.change_date;
           get_commhist_rslt.add_info2contact             := mail_rec.add_info2contact;
            get_commhist_rslt.new_mail_Val     := nvl(mail_rec.new_mail_Val,1);
            if mail_rec.login_name is not null then
            get_commhist_rslt.login_name       := mail_rec.login_name;
            end if;
            if mail_rec.web_login_name is not null and mail_rec.SOURCE_SYSTEM <> 'TAS' then
           get_commhist_rslt.login_name          := mail_rec.web_login_name;
           end if;
            get_commhist_rslt.x_min       := mail_rec.x_min;
            get_commhist_rslt.SOURCE_SYSTEM          := mail_rec.SOURCE_SYSTEM;


            pipe row (get_commhist_rslt);
        end loop;

end;


  function get_phonehistory_func(
 ip_contact_objid in number,
 ip_date varchar2)
  return get_commhist_rec_tab pipelined
    is


   get_commhist_rslt get_commhist_rec;

    cursor c_phonehist_info (p_contact_obj_id number, p_date varchar2) is
    select change_date, add_info2contact,new_ph_Val,u.login_name ,wu.login_name as web_login_name,x_min,SOURCE_SYSTEM
    from sa.table_x_cai_log ,  sa.table_user u, sa.table_web_user wu
    where add_info2contact= p_contact_obj_id
    and u.objid (+)  = add_info2user
    and wu.objid(+) = add_info2web_user
    and to_date(change_date,'dd-MON-yy') between to_date(p_date,'dd-MON-yy') and to_date(sysdate,'dd-MON-yy')
    and ((action = 'UPDATING' and nvl(old_ph_val,2) <> nvl(new_ph_val,2))
    or action = 'INSERTING')
    order by change_date desc;

    r_phonehist_info c_phonehist_info%ROWTYPE ;

     v_date varchar2(100);
    begin

     dbms_output.put_line(' Phone Input Values===================='||ip_contact_objid);

      if ip_date is null then
      v_date:=to_date(sysdate - 30,'dd-MON-yy');
      else
      v_date:=ip_date;
      end if;

    for phone_rec in c_phonehist_info(ip_contact_objid,v_date)
        loop
           dbms_output.put_line('Phone Change date===================='||phone_rec.change_date||'- loginname - '||phone_rec.login_name);
            get_commhist_rslt.change_date         := phone_rec.change_date;
           get_commhist_rslt.add_info2contact             := phone_rec.add_info2contact;
            get_commhist_rslt.new_ph_Val     := nvl(phone_rec.new_ph_Val,1);
            if phone_rec.login_name is not null then
            get_commhist_rslt.login_name       := phone_rec.login_name;
            end if;
            if phone_rec.web_login_name is not null and phone_rec.SOURCE_SYSTEM <> 'TAS' then
           get_commhist_rslt.login_name          := phone_rec.web_login_name;
           end if;
            get_commhist_rslt.x_min       := phone_rec.x_min;
            get_commhist_rslt.SOURCE_SYSTEM          := phone_rec.SOURCE_SYSTEM;


            pipe row (get_commhist_rslt);
        end loop;

end;

  function get_emailhistory_func(
 ip_contact_objid in number,
 ip_date varchar2)
  return get_commhist_rec_tab pipelined
    is


   get_commhist_rslt get_commhist_rec;

    cursor c_emailhist_info (p_contact_obj_id number,p_date varchar2) is
    select change_date, add_info2contact,new_em_Val,u.login_name ,wu.login_name as web_login_name,x_min,SOURCE_SYSTEM
    from sa.table_x_cai_log ,  sa.table_user u, sa.table_web_user wu
    where add_info2contact= p_contact_obj_id
    and u.objid (+)  = add_info2user
    and wu.objid(+) = add_info2web_user
    and to_date(change_date,'dd-MON-yy') between to_date(p_date,'dd-MON-yy') and to_date(sysdate,'dd-MON-yy')
    and ((action = 'UPDATING' and nvl(old_em_val,2) <> nvl(new_em_val,2))
    or action = 'INSERTING')
    order by change_date desc;

    r_emailhist_info c_emailhist_info%ROWTYPE ;

     v_date varchar2(100);
    begin

     dbms_output.put_line(' Email Input Values===================='||ip_contact_objid);

      if ip_date is null then
      v_date:=to_date(sysdate - 30,'dd-MON-yy');
      else
      v_date:=ip_date;
      end if;

    for email_rec in c_emailhist_info(ip_contact_objid,v_date)
        loop
           dbms_output.put_line('Email Change date===================='||email_rec.change_date||'- loginname - '||email_rec.login_name);
            get_commhist_rslt.change_date         := email_rec.change_date;
           get_commhist_rslt.add_info2contact             := email_rec.add_info2contact;
            get_commhist_rslt.new_em_Val     := nvl(email_rec.new_em_Val,1);
            if email_rec.login_name is not null then
            get_commhist_rslt.login_name       := email_rec.login_name;
            end if;
            if email_rec.web_login_name is not null and email_rec.SOURCE_SYSTEM <> 'TAS' then
           get_commhist_rslt.login_name          := email_rec.web_login_name;
           end if;
            get_commhist_rslt.x_min       := email_rec.x_min;
            get_commhist_rslt.SOURCE_SYSTEM          := email_rec.SOURCE_SYSTEM;


            pipe row (get_commhist_rslt);
        end loop;

end;

end ADFCRM_COMMHISTORY_PKG;
/