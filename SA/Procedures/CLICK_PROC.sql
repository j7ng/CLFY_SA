CREATE OR REPLACE procedure sa.click_proc(p_date in date default sysdate-1) as
  sql1 varchar2(2000) := 'drop   table click_proc_temp1';
  sql2 varchar2(2000) := 'create table click_proc_temp1
                          pctfree 0
                          storage(initial 50M next 5M)
                          tablespace clfy_data as
                          (select sp.x_service_id esn,
                                  sp.install_date,
                                  sp.objid,
                                  sp.x_min min
                             from table_site_part sp
                            where part_status   <> ''Obsolete''
                              and install_date  < trunc(to_date('''||to_char(p_date)||'''))+1
                              and X_EXPIRE_DT  >= trunc(to_date('''||to_char(p_date)||''')))';
  sql3 varchar2(2000):= 'create index click_proc_temp1_ndx on
                          click_proc_temp1(esn,install_date)
                          storage(initial 60m next 5M)
                          tablespace clfy_indx';
  sql4 varchar2(2000):= 'delete from click_proc_temp1 b
                         where (b.esn,b.install_date) != (select a.esn,max(a.install_date)
                                                            from click_proc_temp1 a
                                                           where a.esn= b.esn
                                                           group by a.esn)';

  sql5 varchar2(2000) := 'drop   table click_proc_temp2';
  sql6 varchar2(5000) := 'create table click_proc_temp2
                          pctfree 0
                          storage(initial 50M next 5M)
                          tablespace clfy_data as
                          select
                                 trunc(to_date('''||to_char(p_date)||''')) active_on,
                                 cg.x_carrier_name                  carrier_name,
                                 sum(decode(cp.x_click_rl,2,1,0))   click_plan2,
                                 sum(decode(cp.x_click_rl,3,1,0))   click_plan3,
                                 sum(decode(cp.x_click_rl,4,1,0))   click_plan4,
                                 sum(decode(cp.x_click_rl,9.9,1,0)) click_plan9_9,
                                 sum(decode(cp.x_click_ld,1,1,0))   click_plan1,
                                 sum(decode(cp.x_click_ld,1.5,1,0)) click_plan1_5,
                                 count(*)                           cnt
                            from
                                 table_x_click_plan      cp,
                                 table_x_click_plan_hist cph,
                                 table_x_carrier_group   cg,
                                 table_x_carrier         c,
                                 x_score_card_mkt        pi,
                                 click_proc_temp1        sp
                           where (  (    cp.objid                 = cph.plan_hist2click_plan
                                     and cph.x_start_date        <= trunc(to_date('''||to_char(p_date)||'''))
                                     and cph.curr_hist2site_part  = sp.objid
                                    )
                                 or (    cp.objid                      = cph.plan_hist2click_plan
                                      and trunc(to_date('''||to_char(p_date)||''')) between
                                          cph.x_start_date and cph.x_end_date
                                      and cph.plan_hist2site_part      = sp.objid
                                    )
                                 )
                             and cg.objid                      = c.carrier2carrier_group
                             and c.objid                       = pi.part_inst2carrier_mkt
                             and pi.part_serial_no             = sp.min
                           group by cg.x_carrier_name';
  sql9 varchar2(5000) := 'insert into x_act_esn_carrier
                          select ACTIVE_ON,
                                 CARRIER_NAME,
                                 CLICK_PLAN2,
                                 CLICK_PLAN3,
                                 CLICK_PLAN4,
                                 CLICK_PLAN9_9,
                                 CNT
                            from click_proc_temp2';
  sql10 varchar2(5000) := 'insert into x_click_ld
                           select ACTIVE_ON,
                                  CARRIER_NAME,
                                  CLICK_PLAN1,
                                  CLICK_PLAN1_5,
                                  CNT
                             from click_proc_temp2';
  cid     number;
  getrows number;
begin
-----------------------------------------------
--cwl2.put_line('cwl','1');
  begin
    cid := dbms_sql.open_cursor;
    dbms_sql.parse(cid,sql1,dbms_sql.v7);
    getrows := dbms_sql.execute(cid);
    dbms_sql.close_cursor(cid);
  exception when others then null;
  end;
-----------------------------------------------
--cwl2.put_line('cwl','2');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,sql2,dbms_sql.v7);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
-----------------------------------------------
--cwl2.put_line('cwl','3');
  begin
    cid := dbms_sql.open_cursor;
    dbms_sql.parse(cid,sql3,dbms_sql.v7);
    getrows := dbms_sql.execute(cid);
    dbms_sql.close_cursor(cid);
  exception when others then null;
  end;
-----------------------------------------------
--cwl2.put_line('cwl','4');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,sql4,dbms_sql.v7);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
-----------------------------------------------
--cwl2.put_line('cwl','5');
  begin
    cid := dbms_sql.open_cursor;
    dbms_sql.parse(cid,sql5,dbms_sql.v7);
    getrows := dbms_sql.execute(cid);
    dbms_sql.close_cursor(cid);
  exception when others then null;
  end;
-----------------------------------------------
--cwl2.put_line('cwl','6');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,sql6,dbms_sql.v7);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
-----------------------------------------------
--cwl2.put_line('cwl','7');
  delete from x_act_esn_carrier
   where trunc(active_on) = trunc(p_date);
-----------------------------------------------
--cwl2.put_line('cwl','8');
  delete from x_click_ld
   where trunc(active_on) = trunc(p_date);
-----------------------------------------------
--cwl2.put_line('cwl','9');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,sql9,dbms_sql.v7);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
-----------------------------------------------
--cwl2.put_line('cwl','10');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,sql10,dbms_sql.v7);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
-----------------------------------------------
commit;
-----------------------------------------------
end;
/