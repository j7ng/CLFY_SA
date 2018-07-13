CREATE OR REPLACE PROCEDURE sa."EXP_CARRPEND_STATUS"
AS

-- declare
  --lag_days number := 10;
  lag_days number := 3;

  cursor cur_user is
  select objid from table_user where s_login_name = 'SA' ;

  rec_user cur_user%rowtype ;

  cursor c1 is
    select * from (
select tab1.*,
           (case when tab1.x_action_type not in ('1','3') then
                   null
                 when tab1.transaction_id2 is not null then
                   tab1.transaction_id2
                 else
                   (select igh.transaction_id
                      from gw1.ig_transaction_history igh
                     where 1=1
                       and igh.order_type in ('A','E')
                       and igh.status = 'S'
                       and igh.action_item_id = tab1.task_id
                       and rownum <2)
            end) transaction_id
      from (select sp.install_date,
                   sp.x_service_id,
                   sp.x_min,
                   sp.objid,
                   t.task_id,
                   ct.x_action_type,
                   ct.objid call_trans_objid,
                   (select ig.transaction_id
                      from gw1.ig_transaction ig
                     where 1=1
                       and ig.order_type in ('A','E')
                       and ig.status = 'S'
                       and ig.action_item_id = t.task_id
                       and rownum <2) transaction_id2
              from table_task t,
                   table_x_call_trans ct,
                   table_site_part sp
             where 1=1
               and t.X_TASK2X_CALL_TRANS(+) = ct.objid
               and ct.call_trans2site_part(+) = sp.objid
               and sp.install_date+0 < trunc(sysdate) -3
               and sp.part_status = 'CarrierPending'
               and rownum <1001) tab1)
where transaction_id is not null;
  cnt1 number := 0;
  cnt2 number := 0;
  cnt3 number := 0;
  cnt4 number := 0;
  cnt5 number := 0;
  cnt6 number := 0;
  cnt7 number := 0;
  v_return varchar2(300) default null ;
  v_returnmsg varchar2(300) default null;
begin

  open cur_user ;
  fetch cur_user into rec_user ;
  close cur_user ;

  for c1_rec in c1 loop
    cnt4 := cnt4 + 1;
    if c1_rec.x_min not like 'T%' and (c1_rec.transaction_id is not null or c1_rec.install_date < sysdate -lag_days) then
      cnt1 := cnt1 + 1;
    elsif c1_rec.x_min like 'T%' and (c1_rec.transaction_id is not null or c1_rec.install_date < sysdate -lag_days) then
      cnt2 := cnt2 + 1;
    else
      cnt3 := cnt3 + 1;
    end if;
    dbms_output.put_line(c1_rec.x_min||':'||c1_rec.transaction_id||':'||c1_rec.install_date);
    if     c1_rec.x_min not like 'T%'
       and (c1_rec.transaction_id is not null or c1_rec.install_date < sysdate -lag_days) then
      cnt5 := cnt5 + 1;
      sa.service_deactivation.deactservice
         ('PAST_DUE_BATCH',rec_user.objid,c1_rec.x_service_id,c1_rec.x_min,'SENDCARRDEACT',
           0,NULL,'RETURNMIN',v_return,v_returnmsg);

    elsif     c1_rec.x_min like 'T%'
          and (c1_rec.transaction_id is not null or c1_rec.install_date < sysdate -lag_days) then
      cnt6 := cnt6 + 1;
         --update table_part_inst
          --  set x_part_inst_status = '51'
          --where part_serial_no = c1_rec.x_service_id
          --  and x_domain = 'PHONES';
         delete from table_part_inst
          where part_serial_no = c1_rec.x_min
            and x_domain = 'LINES';
    end if;
    if (c1_rec.transaction_id is not null or c1_rec.install_date < sysdate -lag_days) then
      cnt7 := cnt7 + 1;
      update table_x_red_card
         set x_status = '42'
       where RED_CARD2CALL_TRANS = c1_rec.call_trans_objid;
      update table_site_part
         set part_status = 'Obsolete'
       where objid = c1_rec.objid;
    end if;
    commit;
  end loop;
  dbms_output.put_line('cnt1:'||cnt1);
  dbms_output.put_line('cnt2:'||cnt2);
  dbms_output.put_line('cnt3:'||cnt3);
  dbms_output.put_line('cnt4:'||cnt4);
  dbms_output.put_line('cnt5:'||cnt5);
  dbms_output.put_line('cnt6:'||cnt6);
  dbms_output.put_line('cnt7:'||cnt7);
  commit;
end;
/