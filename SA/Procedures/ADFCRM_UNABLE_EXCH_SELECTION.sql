CREATE OR REPLACE PROCEDURE sa."ADFCRM_UNABLE_EXCH_SELECTION" (
    ip_esn IN VARCHAR2,
    ip_zipcode IN varchar2,
    ip_pref_parent IN varchar2,
    op_repl_part out varchar2,
    op_repl_sim_prof out varchar2,
    op_repl_sim_suffix out varchar2)
IS

   cursor cur_esn (c_esn varchar2) is
   select table_part_num.part_num2part_class part_class_objid, table_part_num.part_number
   from  table_part_num, table_mod_level, table_part_inst
   where table_part_num.objid = table_mod_level.part_info2part_num
   and table_part_inst.part_serial_no = c_esn
   and table_part_inst.x_domain = 'PHONES'
   and table_part_inst.n_part_inst2part_mod = table_mod_level.objid;

   rec_esn cur_esn%rowtype;

   CURSOR get_refurb_cnt(c_esn varchar2)
   IS
   SELECT x_refurb_flag
   FROM table_site_part sp_a
   WHERE sp_a.x_service_id = c_esn
   AND sp_a.x_refurb_flag = 1;

   get_refurb_cnt_rec get_refurb_cnt%ROWTYPE;

   CURSOR cur_plus_45_days(c_esn varchar2,c_part_class_objid varchar2)
   IS
   select nvl(trunc(sysdate)-install_date,0) days_in_use
   from table_site_part
   where x_service_id = c_esn
   and part_status in ('Active','Inactive','CarrierPending')
   and nvl(x_refurb_flag,0) = 0
   and nvl(trunc(sysdate)-install_date,0) >= (select nvl(min(x_days_for_used_part),0)
                                               from table_x_class_exch_options
                                               where SOURCE2PART_CLASS =c_part_class_objid
                                               and x_exch_type = 'TECHNOLOGY'
                                               and nvl(x_days_for_used_part,0) >0);

   rec_plus_45_days cur_plus_45_days%ROWTYPE;


    cursor cur_exchanges (c_esn varchar2, c_refurb_flag number) is
    select DECODE(c_refurb_flag, 1, x.x_used_part_num, x.x_new_part_num) pref_phone_part_num
    from table_x_class_exch_options x,table_part_num pn, table_mod_level ml, table_part_inst pi
    where pn.part_num2part_class = x.source2part_class
    and x.x_exch_type = 'TECHNOLOGY'
    and pn.objid = ml.part_info2part_num
    and pi.n_part_inst2part_mod = ml.objid
    and pi.part_serial_no = c_esn
    and pi.x_domain = 'PHONES'
    order by x.X_PRIORITY asc;

    rec_exchanges cur_exchanges%rowtype;


    cursor cur_parent (c_parent_id varchar2, c_pref_parent varchar2) is
    select '1' from table_x_parent
    where X_PARENT_ID = c_parent_id
    and nvl(x_queue_name,x_parent_name) = c_pref_parent;

    rec_parent cur_parent%rowtype;

    v_refurb_flag number:=0;
    n number:=0;

begin

    op_repl_part:='';
    op_repl_sim_prof:='';

    -- find part_class
    open cur_esn(ip_esn);
    fetch cur_esn into rec_esn;
    if cur_esn%notfound then
       close cur_esn;
       return;
    else
       close cur_esn;
    end if;

    -- check current part_number
    nap_SERVICE_pkg.get_list(
        ip_zipcode,
        null,
        rec_esn.part_number,
        null,
        null,
        null);

    n:=1;
    if nap_SERVICE_pkg.big_tab.count>0 then
      while n <= nap_SERVICE_pkg.big_tab.count loop
          open cur_parent (nap_SERVICE_pkg.big_tab(n).carrier_info.x_parent_id,ip_pref_parent);
          fetch cur_parent into rec_parent;
          if cur_parent%found then
             close cur_parent;
             op_repl_part:=nap_SERVICE_pkg.big_tab(n).carrier_info.sim_profile;
             op_repl_sim_prof:=null;
             op_repl_sim_suffix:=null;
          else
             close cur_parent;
          end if;
          n:= n+1;
      end loop;
    end if;

    -- find refub
    open get_refurb_cnt(ip_esn);
    fetch get_refurb_cnt into get_refurb_cnt_rec;
    if get_refurb_cnt%found then
       close get_refurb_cnt;
       v_refurb_flag:=1;
    else
       v_refurb_flag:=0;
       close get_refurb_cnt;
    end if;

    open cur_plus_45_days(ip_esn,rec_esn.part_class_objid);
    fetch cur_plus_45_days into rec_plus_45_days;
    if cur_plus_45_days%found then
       close cur_plus_45_days;
       v_refurb_flag:=1;
    else
       v_refurb_flag:=0;
       close cur_plus_45_days;
    end if;

     -- check exchanges part number
     for rec_exchanges in cur_exchanges(ip_esn,v_refurb_flag) loop

          nap_SERVICE_pkg.get_list(
              ip_zipcode,
              null,
              rec_exchanges.pref_phone_part_num,
              null,
              null,
              null);
        n:=1;
        if nap_SERVICE_pkg.big_tab.count>0 then
          while n <= nap_SERVICE_pkg.big_tab.count loop
              open cur_parent (nap_SERVICE_pkg.big_tab(n).carrier_info.x_parent_id,ip_pref_parent);
              fetch cur_parent into rec_parent;
              if cur_parent%found then
                 close cur_parent;
                 op_repl_part:=rec_exchanges.pref_phone_part_num;
                 op_repl_sim_prof:=nap_SERVICE_pkg.big_tab(n).carrier_info.sim_profile;
                 begin
                   select prog_type
                   into op_repl_sim_suffix
                   from table_part_num
                   where part_number = nap_SERVICE_pkg.big_tab(n).carrier_info.sim_profile;
                 exception when others then null;
                 end;
                 return;
              else
                 close cur_parent;
              end if;
              n:= n+1;
          end loop;
        end if;
    end loop;

end adfcrm_unable_exch_selection;
/