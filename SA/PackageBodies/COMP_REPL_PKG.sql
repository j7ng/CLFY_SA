CREATE OR REPLACE PACKAGE BODY sa."COMP_REPL_PKG" is
------------------------------------------------------------------------
--$RCSfile: comp_repl_pkb.sql,v $
--$Revision: 1.5 $
--$Author: akhan $
--$Date: 2013/08/15 16:14:47 $
--$Log: comp_repl_pkb.sql,v $
--Revision 1.5  2013/08/15 16:14:47  akhan
--fixed a bug relating to refurbished phones.
--
------------------------------------------------------------------------

type limits_ty is record (unit_type varchar2(20),esn_limit number,agent_limit number);

type limits_tab_ty is table of limits_ty
index by binary_integer;
--------------------------------------------------------------------
procedure print_line(msg in varchar2) is
--------------------------------------------------------------------
line varchar2(300);
totlen number := length(msg);
len number := 0;
last_space number;
begin
    if totlen < 250 then
          dbms_output.put_line(msg);
          return;
    end if;
 dbms_output.put_line(' '||chr(10));
    while ( len < totlen)
    loop
         select instr(reverse(substr(msg,len,80)),' ')
         into last_space
         from dual;
         if last_space = 0 then
             select instr(reverse(substr(msg,len,80)),',')
             into last_space
             from dual;
         end if;
         dbms_output.put_line(substr(msg, len,80-last_space+1));

         len := len + 80-last_space +1;

    end loop;
end;
-----------------------------------------------------------------------
procedure get_thresh_limits
  ( ip_thresh_unit_type  IN VARCHAR2, --VOICE|DATA|SMS|DAYS
    ip_type    IN VARCHAR2, -- REPL|COMP
    ip_agent IN VARCHAR2, -- signed in agent
    op_limits out limits_tab_ty) is
-----------------------------------------------------------------------
ctr number := 0;
begin

 for i in (select sct.thresh_unit_type,
                  nvl(sum(decode(thresh_level,'ESN',x_value,0)),0) esn_limit,
                  nvl(sum(decode(thresh_level,'AGENT',x_value,0)),0) agent_limit
           from   table_x_sec_grp c,
                  mtm_user125_x_sec_grp1 b,
                  table_user a,
                  mtm_thresh_threshtype mtm,
                  table_sec_threshold_types  sct,
                  table_x_sec_threshold xst
           where 1= 1
           and a.s_login_name = upper(ip_agent)
           and sct.thresh_unit_type = nvl(ip_thresh_unit_type,sct.thresh_unit_type)
           and sct.thresh_comp_type = ip_type
           and c.objid = b.X_SEC_GRP2USER
           and b.USER2X_SEC_GRP = a.objid
           and mtm.threshold_type2threshold = xst.objid
           and sct.objid = mtm.threshold2threshhold_type
           and c.x_sec_grp2x_threshold = xst.objid
           group by sct.thresh_unit_type)
loop
    ctr := ctr +1;
    op_limits(ctr).unit_type  := i.thresh_unit_type;
    op_limits(ctr).esn_limit  := i.esn_limit;
    op_limits(ctr).agent_limit:= i.agent_limit;
end loop;
if ctr = 0 and ip_thresh_unit_type is not null then
    ctr := ctr +1;
    op_limits(ctr).unit_type  :=  ip_thresh_unit_type ;
    op_limits(ctr).esn_limit  := 0;
    op_limits(ctr).agent_limit:= 0;
end if;
end;


-----------------------------------------------------------------------
procedure getCompHistory(ip_esn in varchar2,
                         ip_csr in varchar2,
                         ip_brand_name in varchar2,
                         op_unit_list out sys_refcursor) is
-----------------------------------------------------------------------
  sqlstmt varchar2(300);
  refurb_line varchar2(600):= null;
  l_install_date date;
   -- esn --
  ev_units number := 0;
  ed_units number := 0;
  es_units number := 0;
  e_days number := 0;
  e_trans number := 0;
   -- agent --
  av_units number := 0;
  ad_units number := 0;
  as_units number := 0;
  a_days number := 0;
  a_trans number := 0;
   -- greater limit --
  voice_limit number := 0;
  data_limit number := 0;
  sms_limit number := 0;
  days_limit number := 0;
  trans_limit number := 0;

  l_limits_tab limits_tab_ty;
begin
  select to_char(max(x_change_date),'MM/DD/YYYY HH24:MI:SS')
  into refurb_line
  from sa.table_x_pi_hist
  where x_part_serial_no = ip_esn
  and x_change_reason = 'REFURBISHED';

  if refurb_line is not null then
     refurb_line := ' and install_date >= to_date('''||refurb_line||''',''MM/DD/YYYY HH24:MI:SS'')';
  end if;
  sqlstmt := 'select min(install_date) ';
  sqlstmt := sqlstmt||' from sa.table_site_part ';
  sqlstmt := sqlstmt||' where x_service_id = '''||ip_esn||'''';
  sqlstmt := sqlstmt||' and part_status <>''Obsolete''';
  sqlstmt := sqlstmt|| refurb_line;

  execute immediate sqlstmt into l_install_date;

  select SUM(decode(cd.x_name,'VOICE_UNITS',NVL(cd.x_value,'0'))) ,
         SUM(decode(cd.x_name,'DATA_UNITS',NVL(cd.x_value,'0'))) ,
         SUM(decode(cd.x_name,'SMS_UNITS',NVL(cd.x_value,'0'))) ,
         SUM(decode(cd.x_name,'SERVICE_DAYS',NVL(cd.x_value,'0'))) ,
         count(distinct c.objid)
  into   ev_units,ed_units,es_units,e_days,e_trans
  from table_case c, table_x_case_detail cd
  where c.objid = cd.detail2case
  and c.x_esn = ip_esn
  and c.title ||'' = 'Compensation Service Plan'
  and c.creation_time + 0 >= l_install_date;

  select SUM(decode(cd.x_name,'VOICE_UNITS',NVL(cd.x_value,'0'))) ,
         SUM(decode(cd.x_name,'DATA_UNITS',NVL(cd.x_value,'0'))) ,
         SUM(decode(cd.x_name,'SMS_UNITS',NVL(cd.x_value,'0'))) ,
         SUM(decode(cd.x_name,'SERVICE_DAYS',NVL(cd.x_value,'0'))) ,
         count(distinct c.objid)
  into   av_units,ad_units,as_units,a_days,a_trans
  from table_case c,
  table_x_case_detail cd,
  table_part_inst pi,
  table_mod_level ml,
  table_part_num pn,
  table_bus_org bo
  where c.objid   = cd.detail2case
  and c.title||'' ='Compensation Service Plan'
  and c.case_originator2user+0 = (select objid
                                  from table_user
                                  where s_login_name = upper(ip_csr))
  and c.creation_time >= trunc(sysdate)
  and c.x_esn = pi.part_serial_no
  and pi.n_part_inst2part_mod = ml.objid
  and ml.part_info2part_num = pn.objid
  and pn.part_num2bus_org = bo.objid
  and bo.s_org_id = ip_brand_name;

  get_thresh_limits(null,'COMP',ip_csr,l_limits_tab);

  for i in 1..l_limits_tab.count
  loop
       if l_limits_tab(i).unit_type = 'DAYS' then
           days_limit := greatest(least( l_limits_tab(i).esn_limit - nvl(e_days,0) ,
                                l_limits_tab(i).agent_limit - nvl(a_days,0)),0);
       elsif l_limits_tab(i).unit_type = 'VOICE' then
           voice_limit := greatest(least( l_limits_tab(i).esn_limit - nvl(ev_units,0),
                                 l_limits_tab(i).agent_limit -nvl(av_units,0)),0);
       elsif l_limits_tab(i).unit_type = 'DATA' then
           data_limit := greatest(least( l_limits_tab(i).esn_limit - nvl(ed_units,0) ,
                                l_limits_tab(i).agent_limit - nvl(ad_units,0) ),0);
       elsif l_limits_tab(i).unit_type = 'SMS' then
           sms_limit := greatest(least( l_limits_tab(i).esn_limit - nvl(es_units,0),
                               l_limits_tab(i).agent_limit - nvl(as_units,0)),0);
       elsif l_limits_tab(i).unit_type = 'TRANS' then
           trans_limit := greatest(least( l_limits_tab(i).esn_limit - nvl(e_trans,0),
                                 l_limits_tab(i).agent_limit - nvl(a_trans,0)),0);
       end if;
  end loop;

  sqlstmt := 'select ''DAYS'' unit_type ,' ||nvl(e_days,0) ||' esn_units  ,';
  sqlstmt := sqlstmt||nvl(a_days,0)  ||' agent_units, '||nvl(days_limit,0);
  sqlstmt := sqlstmt||' remain  from dual ';
  sqlstmt := sqlstmt||' union select ''VOICE'','||nvl(ev_units,0)||',';
  sqlstmt := sqlstmt||nvl(av_units,0)||','||nvl(voice_limit,0)||' from dual';
  sqlstmt := sqlstmt||' union select ''DATA'', '||nvl(ed_units,0)||',';
  sqlstmt := sqlstmt||nvl(ad_units,0)||','||nvl(data_limit,0)||' from dual';
  sqlstmt := sqlstmt||' union select ''TEXT'', '||nvl(es_units,0)||',';
  sqlstmt := sqlstmt||nvl(as_units,0)||','||nvl(sms_limit,0)||' from dual';
  sqlstmt := sqlstmt||' union select ''TRANS'','||nvl(e_trans,0)||',';
  sqlstmt := sqlstmt||nvl(a_trans,0) ||','||nvl(trans_limit,0)||' from dual';

  print_line(sqlstmt);
  open op_unit_list for sqlstmt;
end;
-----------------------------------------------------------------------
procedure is_thresh_limit_voilated
  ( ip_thresh_unit_type  IN VARCHAR2, --VOICE|DATA|SMS|DAYS
    ip_type    IN VARCHAR2, -- REPL|COMP
    ip_agent IN VARCHAR2, -- signed in agent
    ip_esn_units in number,
    ip_agent_units in number,
    op_voil in out number,
    op_err out number ) is
-----------------------------------------------------------------------
l_esn_limit number:= 0;
l_agent_limit number := 0;
l_limits_tab limits_tab_ty;
begin
  get_thresh_limits(ip_thresh_unit_type,
                    ip_type,
                    ip_agent,
                    l_limits_tab);

  if (ip_esn_units > l_limits_tab(1).esn_limit ) then
     op_voil := 1;
  end if;
  if ( ip_agent_units > l_limits_tab(1).agent_limit ) then
     op_voil := op_voil+2;
  end if;
   op_err := 0;
exception
  when others then
   op_err := sqlcode;
end;
-----------------------------------------------------------------------
PROCEDURE validate_comp_repl_limits
  ( ip_esn         IN VARCHAR2, --ESN in flow
    ip_agent       IN VARCHAR2, --signed in agent
    ip_type        IN VARCHAR2, -- REPL|COMP
    ip_voice_units IN NUMBER, -- selected from flow
    ip_data_units  IN NUMBER, -- selected from flow
    ip_sms_units   IN NUMBER, -- selected from flow
    ip_days        IN NUMBER, -- selected from flow
    ip_sup_login   IN VARCHAR2, --signed supervisor override
    op_error_num   OUT NUMBER) is
-----------------------------------------------------------------------
is_sup number:= 0;
l_brand_name table_bus_org.s_org_id%TYPE;
type out_rec_ty is record ( unit_type varchar2(30), esn_units number,agent_units number,remain number);
out_hist_rec  out_rec_ty;
out_hist_curs sys_refcursor;
v_overall number := 0;
v_msg number:= 0;
l_esn_limit number;
l_agent_limit number;
l_agent varchar2(50);

TYPE varr_ty IS VARRAY(4) OF integer;
 v_arr varr_ty := varr_ty(0,0,0,0);

begin

   select s_org_id
   into l_brand_name
   from table_bus_org bo,
        table_part_inst pi,
        table_part_num pn,
        table_mod_level ml
   where  pi.n_part_inst2part_mod = ml.objid
   and ml.part_info2part_num = pn.objid
   and pi.x_domain = 'PHONES'
   and pn.part_num2bus_org = bo.objid
   and pi.part_serial_no = ip_esn;

   if (ip_sup_login is not null) then
          l_agent := ip_sup_login;
   else
          l_agent := ip_agent;
   end if;

   getCompHistory(ip_esn,l_agent,l_brand_name,out_hist_curs);
   loop
     fetch out_hist_curs into out_hist_rec;
     exit when out_hist_curs%NOTFOUND;
     if ( out_hist_rec.unit_type = 'VOICE' and nvl(ip_voice_units,0) > 0 ) then
        is_thresh_limit_voilated (out_hist_rec.unit_type,
                               ip_type  ,
                               l_agent ,
                               out_hist_rec.esn_units + nvl(ip_voice_units,0),
                               out_hist_rec.agent_units + nvl(ip_voice_units,0),
                               v_arr(1),
                               v_msg );


     elsif ( out_hist_rec.unit_type = 'DATA'  and nvl(ip_data_units,0) > 0 ) then
        is_thresh_limit_voilated (out_hist_rec.unit_type,
                               ip_type  ,
                               l_agent ,
                               out_hist_rec.esn_units + nvl(ip_data_units,0),
                               out_hist_rec.agent_units + nvl(ip_data_units,0),
                               v_arr(2),
                               v_msg );
     elsif ( out_hist_rec.unit_type = 'TEXT'  and nvl(ip_sms_units,0) > 0 ) then
        is_thresh_limit_voilated ('SMS',
                               ip_type  ,
                               l_agent ,
                               out_hist_rec.esn_units + nvl(ip_sms_units,0),
                               out_hist_rec.agent_units + nvl(ip_sms_units,0),
                               v_arr(3),
                               v_msg );
     elsif ( out_hist_rec.unit_type = 'DAYS' and nvl(ip_days,0) > 0 ) then
        is_thresh_limit_voilated (out_hist_rec.unit_type,
                               ip_type  ,
                               l_agent ,
                               out_hist_rec.esn_units + nvl(ip_days,0),
                               out_hist_rec.agent_units + nvl(ip_days,0),
                               v_arr(4),
                               v_msg );
     end if;
     if v_msg <> 0 then
          exit;
     end if;
   end loop;

   if (v_arr(1)<>0 or v_arr(2)<>0 or v_arr(3)<>0 or v_arr(4)<>0 ) then
        v_overall := 1;
   end if;

   if v_msg = -1403 then
        v_overall:= 2;
   end if;

   op_error_num := to_number(to_char(v_overall||v_arr(1)||v_arr(2)||v_arr(3)||v_arr(4)));

/*
0 . Success
1 . Esn Limit Exceeded
2 . Agent Limit Exceeded
3 . Transaction limit Exceeded
Non 0 in each position represents a limit violation

Overall Voice Data SMS Days
0       0     0    0   0     . Success
1       1     0    0   0     . Voice Esn Limit Exceeded
1       2     0    0   0     . Voice Agent Limit Exceeded
1       4     0    0   0     . Voice Transactional Limit Exceeded
*/
end;
end;
/