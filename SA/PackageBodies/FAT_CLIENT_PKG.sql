CREATE OR REPLACE PACKAGE BODY sa."FAT_CLIENT_PKG" as
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
--------------------------------------------------------------------
procedure get_state_list
                       (op_state_list out sys_refcursor ) is
--------------------------------------------------------------------
begin
   open op_state_list for select s_name,full_name from table_state_prov;
end;
--------------------------------------------------------------------
function ins_new_pi_rec(pi_rec in table_part_inst%ROWTYPE)
return number is
--------------------------------------------------------------------
  ret_objid number;
begin
      insert into table_part_inst (objid,
                             part_good_qty,
                             part_bad_qty,
                             part_serial_no,
                             part_mod,
                             part_bin,
                             last_pi_date,
                             pi_tag_no,
                             last_cycle_ct,
                             next_cycle_ct,
                             last_mod_time,
                             last_trans_time,
                             transaction_id,
                             date_in_serv,
                             warr_end_date,
                             repair_date,
                             part_status,
                             pick_request,
                             good_res_qty,
                             bad_res_qty,
                             hdr_ind,
                             x_insert_date,
                             x_sequence,
                             x_creation_date,
                             x_po_num,
                             x_red_code,
                             x_domain,
                             x_deactivation_flag,
                             x_reactivation_flag,
                             x_cool_end_date,
                             x_part_inst_status,
                             x_npa,
                             x_nxx,
                             x_ext,
                             x_order_number,
                             x_ld_processed,
                             x_msid,
                             x_iccid,
                             x_clear_tank,
                             x_port_in,
                             x_hex_serial_no,
                             created_by2user,
                             part_inst2carrier_mkt,
                             part_inst2x_pers,
                             status2x_code_table,
                             part_to_esn2part_inst)
                      values(seq('part_inst'),
                             pi_rec.part_good_qty,
                             pi_rec.part_bad_qty,
                             pi_rec.part_serial_no,
                             pi_rec.part_mod,
                             pi_rec.part_bin,
                             pi_rec.last_pi_date,
                             pi_rec.pi_tag_no,
                             pi_rec.last_cycle_ct,
                             pi_rec.next_cycle_ct,
                             pi_rec.last_mod_time,
                             pi_rec.last_trans_time,
                             pi_rec.transaction_id,
                             pi_rec.date_in_serv,
                             pi_rec.warr_end_date,
                             pi_rec.repair_date,
                             pi_rec.part_status,
                             pi_rec.pick_request,
                             pi_rec.good_res_qty,
                             pi_rec.bad_res_qty,
                             pi_rec.hdr_ind,
                             pi_rec.x_insert_date,
                             pi_rec.x_sequence,
                             pi_rec.x_creation_date,
                             pi_rec.x_po_num,
                             pi_rec.x_red_code,
                             pi_rec.x_domain,
                             pi_rec.x_deactivation_flag,
                             pi_rec.x_reactivation_flag,
                             pi_rec.x_cool_end_date,
                             pi_rec.x_part_inst_status,
                             pi_rec.x_npa,
                             pi_rec.x_nxx,
                             pi_rec.x_ext,
                             pi_rec.x_order_number,
                             pi_rec.x_ld_processed,
                             pi_rec.x_msid,
                             pi_rec.x_iccid,
                             pi_rec.x_clear_tank,
                             pi_rec.x_port_in,
                             pi_rec.x_hex_serial_no,
                             pi_rec.created_by2user,
                             pi_rec.part_inst2carrier_mkt,
                             pi_rec.part_inst2x_pers,
                             pi_rec.status2x_code_table,
                             pi_rec.part_to_esn2part_inst)
                      returning objid into ret_objid;

return ret_objid;
end;


--------------------------------------------------------------------
procedure lm_show_technology(p_in_min in varchar2,
                           p_out_ph_tech out varchar2,
                           p_out_carr_tech out varchar2,
                           p_out_msg out varchar2 )
--------------------------------------------------------------------
is
 l_pstatus table_site_part.part_status%TYPE;
 l_pi_status table_part_inst.x_part_inst_status%TYPE;
begin

  begin
    select x_part_inst_status
    into l_pi_status
    from table_part_inst
    where part_serial_no = p_in_min;
    if (l_pi_status not in ('15', -- Port in Min Reserved
                          '12', -- used
                          '13', --Active
                          '34', --Pending AC Change
                          '39', --Reserved used
                          '60', --NTN
                          '110', --Pending MSID Update
                          '73', --Portin min reserved
                          '79' )) --Port Cancelled
   then
      p_out_msg := 'Technology not available for this MIN';
      return;
   end if;
  exception
    when others then
      p_out_msg := 'Technology is not available for this MIN';
      return;
  end;



SELECT x_technology,
       part_status
INTO p_out_ph_tech,
     l_pstatus
FROM table_site_part sp,
     table_mod_level ml,
     table_part_num pn
WHERE sp.x_min = p_in_min
AND site_part2part_info = ml.objid
AND ml.part_info2part_num=pn.objid;

p_out_carr_tech := p_out_ph_tech;

if p_out_ph_tech is null then
   p_out_msg := 'Technology is not available for this MIN';
else
   p_out_msg := 'SUCCESS';
end if;

exception
  when others then
   p_out_msg := 'Technology is not available for this MIN';

end;
--------------------------------------------------------------------
procedure lm_get_status_list( p_in_codeType in varchar2,
                              status_list out sys_refcursor)
--------------------------------------------------------------------
is
begin
  open status_list for SELECT  x_code_name
                 FROM table_x_code_table
                 WHERE  x_code_type = p_in_codeType ;
end;
--------------------------------------------------------------------
procedure lm_get_carrier_name_list(carrier_name_list out sys_refcursor )
--------------------------------------------------------------------
is
begin
open carrier_name_list for
select distinct x_carrier_name
from   table_x_carrier_group
order by  x_carrier_name asc;
end;

--------------------------------------------------------------------
procedure lm_get_lines( ip_cool_edate in number,
                        ip_carr_id varchar2,
                        ip_carr_name varchar2,
                        ip_mkt_submkt_name varchar2,
                        ip_status varchar2,
                        ip_npa_start varchar2,
                        ip_npa_end varchar2,
                        ip_nxx_start varchar2,
                        ip_nxx_end varchar2,
                        ip_ext_start varchar2,
                        ip_ext_end varchar2,
                        line_list out sys_refcursor)
--------------------------------------------------------------------
is
  run_qry number := 0;
  expl_plan_stmt varchar2(4000);
  ep_time number; ep_cardinality number; ep_cost number; ep_cpu_cost number; ep_io_cost number;
  sqlstmt varchar2(4000);
  l_npa_end varchar2(5) := nvl(ip_npa_end,ip_npa_start);
  l_nxx_end varchar2(5) := nvl(ip_nxx_end,ip_nxx_start);
  l_ext_end varchar2(5) := nvl(ip_ext_end,ip_ext_start);

  npa_nxx_exists boolean := false;
  npa_nxx_empty boolean := false;
  ntn_usehold_newhold_exists boolean := false;

  v_carr_objid number;
  v_code_objid number;
  v_code_number varchar2(20);
  emptystmt varchar2(4000) := 'SELECT null line_objid, null x_carrier_id, null x_npa, null x_nxx, null x_ext, '||
                             'null x_msid, null x_min, null x_code_name, null x_carrier_name, '||
                             'null x_mkt_submkt_name, null warr_end_date, null pi_sts '||
                             'FROM dual where rownum <1';
begin

  -- VALIDATE NPA/NXX BOTH HAVE VALUES
  if ((ip_npa_start is not null or ip_npa_start != '') and
     (ip_nxx_start is not null or ip_nxx_start != ''))
  then
    npa_nxx_exists := true;
  end if;

  -- VALIDATE STATUS IS IN NTN,USEHOLD,NEWHOLD
  if ip_status in ('NTN','USEDHOLD','NEWHOLD') then
    ntn_usehold_newhold_exists := true;
  end if;

  if (ip_npa_start is not null or ip_npa_end is not null) and
     (ip_nxx_start is not null or ip_nxx_end is not null) and
	 ( (ip_carr_name is null and ip_mkt_submkt_name is null) or
	   ip_carr_id is not null
	  )
  then
     run_qry := 1;
  end if;
  if ntn_usehold_newhold_exists and
	 ( (ip_carr_name is null and ip_mkt_submkt_name is null) or
	   ip_carr_id is not null
	  )
  then
     run_qry := 1;
  end if;
  if run_qry = 0 and
    (ip_carr_id is not null or
     ip_carr_name is not null or
     ip_mkt_submkt_name is not null) and
     ip_npa_start is null and
     ip_npa_end is null and
     ip_nxx_start is null and
     ip_nxx_end is null and
     ip_ext_start is null and
     ip_ext_end is null
  then
     run_qry := 2;
  end if;

  if run_qry = 1 then
        sqlstmt :=
			'SELECT '||
			'    pi.LINE_OBJID, '||
			'    tc.x_carrier_id, '||
			'    pi.x_npa, '||
			'    pi.x_nxx, '||
			'    pi.x_ext, '||
			'    pi.x_msid, '||
			'    pi.X_MIN, '||
			'    (select tct.x_code_name  '||
			'    from sa.table_x_code_table tct  '||
			'    where tct.objid = pi.status2x_code_table) x_code_name, '||
			'    tcg.x_carrier_name, '||
			'    tc.x_mkt_submkt_name, '||
			'    pi.warr_end_date, '||
			'    pi.X_STATUS pi_sts '||
			'FROM ( '||
			'      SELECT /*+ FIRST_ROWS(105) */  '||
			'          pi.objid LINE_OBJID, '||
			'          pi.warr_end_date, '||
			'          pi.part_serial_no X_MIN, '||
			'          pi.x_part_inst_status  X_STATUS, '||
			'          pi.x_deactivation_flag, '||
			'          pi.x_domain, '||
			'          pi.x_npa, '||
			'          pi.x_nxx, '||
			'          pi.x_ext, '||
			'          pi.x_cool_end_date, '||
			'          pi.x_msid, '||
			'          pi.part_inst2carrier_mkt, '||
			'          pi.status2x_code_table '||
			'      FROM sa.table_part_inst pi '||
			'      WHERE pi.x_domain = ''LINES'' ';
  elsif run_qry = 2 then
        sqlstmt :=
			'SELECT '||
			'    pi.objid LINE_OBJID, '||
			'    tc.x_carrier_id, '||
			'    pi.x_npa, '||
			'    pi.x_nxx, '||
			'    pi.x_ext, '||
			'    pi.x_msid, '||
			'    pi.part_serial_no  X_MIN, '||
			'    (select tct.x_code_name  '||
			'    from sa.table_x_code_table tct  '||
			'    where tct.objid = pi.status2x_code_table) x_code_name, '||
			'    tc.x_carrier_name, '||
			'    tc.x_mkt_submkt_name, '||
			'    pi.warr_end_date, '||
			'    pi.x_part_inst_status pi_sts '||
			'FROM (SELECT tc.objid, '||
             			'tc.x_carrier_id, '||
			'             tc.x_mkt_submkt_name, '||
             			'tcg.x_carrier_name '||
			'      FROM  sa.table_x_carrier tc, '||
			'            sa.table_x_carrier_group tcg '||
			'      WHERE tcg.objid = tc.carrier2carrier_group ';
  else
  sqlstmt := 'SELECT line_objid,x_carrier_id, x_npa, x_nxx, x_ext, '||
             'x_msid, x_min,x_code_name, x_carrier_name, '||
             'x_mkt_submkt_name, warr_end_date, x_status pi_sts '||
             'FROM table_x_line_manage_view '||
             'WHERE x_domain = ''LINES'' ';
  end if;

  --filter for sa.table_part_inst
  if ip_npa_start is not null then
       sqlstmt := sqlstmt||' AND x_npa >= '''||ip_npa_start||'''' ;
  end if;
  --filter for sa.table_part_inst
  if l_npa_end is not null then
       sqlstmt := sqlstmt ||' AND x_npa <= '''||l_npa_end||'''' ;
  end if;
  --filter for sa.table_part_inst
  if ip_nxx_start is not null then
      sqlstmt := sqlstmt ||' AND x_nxx >= '''|| ip_nxx_start||'''' ;
  end if;
  --filter for sa.table_part_inst
  if l_nxx_end is not null then
      sqlstmt := sqlstmt ||' AND x_nxx <= '''|| l_nxx_end||'''';
  end if;
  --filter for sa.table_part_inst
  if ip_ext_start is not null then
      sqlstmt := sqlstmt ||' AND x_ext >= '''||ip_ext_start ||'''';
  end if;
  --filter for sa.table_part_inst
  if l_ext_end is not null then
      sqlstmt := sqlstmt ||' AND x_ext <= '''||l_ext_end||'''';
  end if;
  --filter for sa.table_part_inst
  if ip_cool_edate = 1 then
       sqlstmt:= sqlstmt ||' AND x_cool_end_date < SYSDATE ';
  end if;
  --filter for sa.table_part_inst
  if ip_carr_id is not null then
	if run_qry = 1 then
       --filter for sa.table_part_inst
	   begin
	      select objid
		  into   v_carr_objid
		  from   sa.table_x_carrier
		  where  x_carrier_id = ip_carr_id;
		  sqlstmt := sqlstmt ||' AND pi.part_inst2carrier_mkt = '||v_carr_objid ;
	   exception
	      when others then
		    null;
	   end;
	else
       sqlstmt := sqlstmt ||' AND x_carrier_id = '''||ip_carr_id||'''' ;
	end if;
  end if;

  if run_qry != 1 and ip_carr_name is not null then
       sqlstmt := sqlstmt ||' AND x_carrier_name = '''||ip_carr_name||'''' ;
  end if;

  if run_qry != 1 and ip_mkt_submkt_name is not null then
       sqlstmt := sqlstmt ||' AND x_mkt_submkt_name = '''||ip_mkt_submkt_name||'''' ;
  end if;

  if run_qry = 2 then
    sqlstmt := sqlstmt ||' ) tc,';
    sqlstmt := sqlstmt ||' sa.table_part_inst pi';
    sqlstmt := sqlstmt ||' where pi.part_inst2carrier_mkt = tc.objid';
  end if;

  if ip_status is not null then
	if run_qry in (1,2) then
       --filter for sa.table_part_inst
	   begin
		  select tct.x_code_number, tct.objid
		  into  v_code_number, v_code_objid
		  from sa.table_x_code_table tct
		  where x_code_type = 'LS'
		  and x_code_name = ip_status;

		  --if ntn_usehold_newhold_exists then
		     sqlstmt := sqlstmt ||' AND pi.status2x_code_table = '||v_code_objid;
		  --else
		  --   sqlstmt := sqlstmt ||' AND pi.x_part_inst_status = '''||v_code_number||'''' ;
		  --end if;
	   exception
	      when others then
		    null;
	   end;
    else
       sqlstmt := sqlstmt ||' AND x_code_name = '''||ip_status||'''' ;
	end if;
  end if;

  if run_qry = 1 then
        sqlstmt := sqlstmt ||
             '           and rownum < 106 '||
             '            ) pi, '||
             '            sa.table_x_carrier tc, '||
             '            sa.table_x_carrier_group tcg '||
             '      WHERE tc.objid  = pi.part_inst2carrier_mkt '||
             '      and   tcg.objid = tc.carrier2carrier_group '||
             '      ORDER BY pi.x_npa ASC , pi.x_nxx ASC , pi.x_ext ASC ';
  elsif run_qry = 2 then
        sqlstmt := sqlstmt ||' and rownum <= 106';
        sqlstmt := sqlstmt ||' ORDER BY x_npa ASC , x_nxx ASC , x_ext ASC';
  else
        sqlstmt := sqlstmt ||' and rownum <= 106';
        sqlstmt := sqlstmt ||' ORDER BY x_npa ASC , x_nxx ASC , x_ext ASC';
        sqlstmt := 'select * from ('||sqlstmt||') where rownum <106';
  end if;

  --dbms_output.put_line(sqlstmt);

  -- SEARCH RULES
  -- CANNOT DO OPEN SEARCH
  -- MUST HAVE AT LEASE NPA/NXX OR
  -- A STATUS OF NTN,USEHOLD, OR NEWHOLD
  -- IF CHECKING AGAINST THE SPECIFIED STATUS
  -- TO PREVENT RUNAWAY QUERIES, VALIDATION
  -- MODIFIED TO ENFORCE PARAMS NPA/NXX TO BE
  -- EITHER BOTH FILLED OR BOTH EMPTY

  if ip_carr_id is null and
     ip_carr_name is null and
     ip_mkt_submkt_name is null and
     ip_status is null and
     ip_npa_start is null and
     ip_npa_end is null and
     ip_nxx_start is null and
     ip_nxx_end is null and
     ip_ext_start is null and
     ip_ext_end is null
  then
    sqlstmt := emptystmt;
  end if;

  -- VALIDATE NPA/NXX BOTH ARE EMPTY
  if ((ip_npa_start is null or ip_npa_start = '') and
      (ip_nxx_start is null or ip_nxx_start = ''))
  then
    npa_nxx_empty := true;
  end if;

  if ntn_usehold_newhold_exists and
   (npa_nxx_exists or
    npa_nxx_empty) then
    null;
  elsif not ntn_usehold_newhold_exists and
   (npa_nxx_exists or
    npa_nxx_empty) then
    null;
  else
    sqlstmt := emptystmt;
  end if;

  -- Very Long Query Safety Check (Nitin Request)
  if (ip_carr_id is null and
      not(ip_npa_start is not null or ip_npa_end is not null) and
	  not ntn_usehold_newhold_exists) then
--      ip_status is not null ) then
	  dbms_output.put_line('***************  Very Long Query Safety Check  *********************');
      sqlstmt := emptystmt;
  elsif
    -- Very Long Query Safety Check CR40969 Email from Elliot Garcia 5/6/2016 4:23 PM
	-- (Carrier ID, Carrier Name, Carrier Market) and Status
	(ip_carr_id is not null or
     ip_carr_name is not null or
     ip_mkt_submkt_name is not null) and
	 (ip_status is not null and not ntn_usehold_newhold_exists) and
     ip_npa_start is null and
     ip_npa_end is null and
     ip_nxx_start is null and
     ip_nxx_end is null and
     ip_ext_start is null and
     ip_ext_end is null
  then
      sqlstmt := emptystmt;
  end if;

/*****************************************
--------checking explain plan begin
delete from plan_table where statement_id = 'lm_get_lines_stmt';
commit;
expl_plan_stmt := 'EXPLAIN PLAN SET STATEMENT_ID = ''lm_get_lines_stmt'' FOR '||sqlstmt;
execute immediate expl_plan_stmt;

 select time, --Elapsed time in seconds of the operation as estimated by query optimization
 cardinality, --Estimate by the query optimization approach of the number of rows accessed by the operation.
 cost, cpu_cost, io_cost
 into ep_time, ep_cardinality, ep_cost, ep_cpu_cost, ep_io_cost
 from plan_table
 where statement_id = 'lm_get_lines_stmt' and parent_id is null and id = 0;

 dbms_output.put_line(run_qry||'***************** QUERY Cost and time '||ep_cost||'  '||ep_time);

if (ep_time > 30)
then
    sqlstmt := emptystmt;
    dbms_output.put_line('***************  Very Long Query Safety Check  *********************');
end if;
--------checking explain plan end
*****************************************/

  print_line(sqlstmt);
  open line_list for  sqlstmt;

end lm_get_lines;
--------------------------------------------------------------------
function lm_get_lines(ip_cool_edate in number,
                        ip_carr_id varchar2,
                        ip_carr_name varchar2,
                        ip_mkt_submkt_name varchar2,
                        ip_status varchar2,
                        ip_npa_start varchar2,
                        ip_npa_end varchar2,
                        ip_nxx_start varchar2,
                        ip_nxx_end varchar2,
                        ip_ext_start varchar2,
                        ip_ext_end varchar2)
return lm_get_lines_tab_ty pipelined is
--------------------------------------------------------------------
 ref_cur sys_refcursor;
 lm_get_lines_lst  lm_get_lines_ty;
begin
  lm_get_lines(ip_cool_edate,
               ip_carr_id,
               ip_carr_name,
               ip_mkt_submkt_name,
               ip_status,
               ip_npa_start,
               ip_npa_end,
               ip_nxx_start,
               ip_nxx_end,
               ip_ext_start,
               ip_ext_end,
               ref_cur);
   loop
   fetch ref_cur into lm_get_lines_lst;
   exit when ref_cur%NOTFOUND;
   pipe row(lm_get_lines_lst);
   end loop;

end;
--------------------------------------------------------------------
procedure lm_get_carrier_detail_list(ip_carr_id varchar2,
                                     ip_carr_name varchar2,
                                     ip_carr_mkt varchar2,
                                     carrier_dtl_list out sys_refcursor )
--------------------------------------------------------------------
is
 sqlstmt varchar2(500);
begin
    sqlstmt:= 'select c.objid carrier_objid, x_carrier_id,';
    sqlstmt:= sqlstmt||'x_mkt_submkt_name, x_city, x_state,';
    sqlstmt:= sqlstmt||'x_carrier_name,';
    sqlstmt:= sqlstmt||'decode(x_line_expire_days,0,null,';
    sqlstmt:= sqlstmt||'to_char(sysdate+cr.x_line_expire_days,''MM/DD/YYYY'')) exp_date';
    sqlstmt:= sqlstmt||' FROM table_x_carrier c,';
    sqlstmt:= sqlstmt||'table_x_carrier_group cg,';
    sqlstmt:= sqlstmt||'table_x_parent p,';
    sqlstmt:= sqlstmt||'table_x_carrier_rules cr';
    sqlstmt:= sqlstmt||' WHERE p.objid (+)  = cg.x_carrier_group2x_parent';
    sqlstmt:= sqlstmt||' AND cg.objid = c.carrier2carrier_group';
    sqlstmt:= sqlstmt||' and c.carrier2rules = cr.objid';

    if ip_carr_id is not null then
       sqlstmt := sqlstmt ||' and x_carrier_id ='||ip_carr_id;
    end if;
    if ip_carr_name is not null then
       sqlstmt := sqlstmt ||' and x_carrier_name like ''%'||ip_carr_name||'%''';
    end if;
    if ip_carr_mkt is not null then
       sqlstmt := sqlstmt ||' and x_mkt_submkt_name like ''%'||ip_carr_mkt||'%''';
    end if;
    print_line(sqlstmt);
    open carrier_dtl_list for sqlstmt;

end;
--------------------------------------------------------------------
function lm_get_carrier_detail_list(ip_carr_id varchar2,
                        ip_carr_name varchar2,
                        ip_carr_mkt varchar2)
return carr_dtl_list_tab_ty pipelined is
--------------------------------------------------------------------
 ref_cur sys_refcursor;
 carr_dtl_list  carr_dtl_list_ty;
begin
    lm_get_carrier_detail_list(ip_carr_id ,
                        ip_carr_name,
                        ip_carr_mkt,
                        ref_cur);
   loop
   fetch ref_cur into carr_dtl_list;
   exit when ref_cur%NOTFOUND;
   pipe row(carr_dtl_list);
   end loop;

end;
--------------------------------------------------------------------
procedure lm_get_deact_reason(ip_privclass_objid in number,
                              ip_codeType in varchar2,
                              deact_reason_list out sys_refcursor)
--------------------------------------------------------------------
is
 sqlstmt varchar2(1000);
begin
   --come back here asim
  sqlstmt := 'SELECT T2.x_code_number, T2.x_code_name ';
  sqlstmt := sqlstmt ||' FROM table_x_code_table T2, table_privclass T1, ';
  sqlstmt := sqlstmt ||' mtm_privclass9_x_code_table2 MTM ';
  sqlstmt := sqlstmt ||' WHERE T1.objid = MTM.x_privclass2x_code_table ';
  sqlstmt := sqlstmt ||' AND T2.objid = MTM.x_code_table2privclass ';

  if ip_privclass_objid is not null then
       sqlstmt := sqlstmt ||' and T1.objid = '||ip_privclass_objid;
  end if;
  if ip_codeType is not null then
       sqlstmt := sqlstmt ||' and T2.x_code_type = '''||ip_codeType||'''';
  end if;
  open deact_reason_list for sqlstmt;

end;
--------------------------------------------------------------------
-- OVERLOAD
--------------------------------------------------------------------
procedure lm_get_deact_reason(ip_privclass_name in varchar2,
                              ip_codeType in varchar2,
                              deact_reason_list out sys_refcursor)
--------------------------------------------------------------------
is
 sqlstmt varchar2(1000);
begin
   --come back here asim
  sqlstmt := 'SELECT T2.x_code_number, T2.x_code_name ';
  sqlstmt := sqlstmt ||' FROM table_x_code_table T2, table_privclass T1, ';
  sqlstmt := sqlstmt ||' mtm_privclass9_x_code_table2 MTM ';
  sqlstmt := sqlstmt ||' WHERE T1.objid = MTM.x_privclass2x_code_table ';
  sqlstmt := sqlstmt ||' AND T2.objid = MTM.x_code_table2privclass ';

  if ip_privclass_name is not null then
       sqlstmt := sqlstmt ||' and T1.class_name = '''||ip_privclass_name||'''';
  end if;
  if ip_codeType is not null then
       sqlstmt := sqlstmt ||' and T2.x_code_type = '''||ip_codeType||'''';
  end if;
  open deact_reason_list for sqlstmt;

end;
--------------------------------------------------------------------
function lm_get_deact_reason(ip_privclass_objid in number,
                             ip_codeType in varchar2)
return lm_get_deact_reason_tab_ty pipelined is
--------------------------------------------------------------------
 ref_cur sys_refcursor;
 lm_get_deact_reason_lst  lm_get_deact_reason_ty;
begin
    lm_get_deact_reason(ip_privclass_objid,
                        ip_codeType,
                        ref_cur);
   loop
   fetch ref_cur into lm_get_deact_reason_lst;
   exit when ref_cur%NOTFOUND;
   pipe row(lm_get_deact_reason_lst);
   end loop;

end;
--------------------------------------------------------------------
-- OVERLOAD
--------------------------------------------------------------------
function lm_get_deact_reason(ip_privclass_name in varchar2,
                             ip_codeType in varchar2)
return lm_get_deact_reason_tab_ty pipelined is
--------------------------------------------------------------------
 ref_cur sys_refcursor;
 lm_get_deact_reason_lst  lm_get_deact_reason_ty;
begin
    lm_get_deact_reason(ip_privclass_name,
                        ip_codeType,
                        ref_cur);
   loop
   fetch ref_cur into lm_get_deact_reason_lst;
   exit when ref_cur%NOTFOUND;
   pipe row(lm_get_deact_reason_lst);
   end loop;

end;
--------------------------------------------------------------------
function lm_get_accounts (ip_carr_id in number)
return lm_get_accounts_tab_ty pipelined is
--------------------------------------------------------------------
 ref_cur sys_refcursor;
 lm_get_accounts_list  lm_get_accounts_ty;
begin
  lm_get_accounts(ip_carr_id,ref_cur);
  loop
    fetch ref_cur into lm_get_accounts_list;
    exit when ref_cur%NOTFOUND;
    pipe row(lm_get_accounts_list);
  end loop;
end;
---------------------------------------------------------------
procedure lm_get_accounts(ip_carr_id in number,
                          account_list out sys_refcursor)
---------------------------------------------------------------
is
begin
 open account_list for
  select  objid, x_acct_num
 from table_x_account
 where (  (  x_status = 'Active') )
     AND account2x_carrier IN (select objid from table_x_carrier where x_carrier_id =ip_carr_id);
end;
---------------------------------------------------------------
procedure lm_change_carrier_id (ip_pi_objid_list in varchar2,
                                ip_new_carr_id in number,
                                ip_user_objid in number,
                                op_msg out varchar2)
---------------------------------------------------------------
is
l_user_objid number;
l_part_serial_no varchar2(40);
l_pi_line_objid number;
l_esn table_part_inst.part_serial_no%TYPE;
l_pi_esn_objid number;
l_status table_part_inst.x_part_inst_status%TYPE;
l_esn_status table_part_inst.x_part_inst_status%TYPE;
pi_cur sys_refcursor;
sqlstmt varchar2(3000);

l_personality_objid number;
l_carr_objid number;
l_min varchar2(15);
l_line_carr_objid number;
l_old_carr_id number;
l_line_carr_objid_saved number;
pi_hist_res number;

area_code_valid_for_carr number:= 0;
carr_chng_ok_for_status number := 0;
l_lines_updated number := 0;
begin
   sqlstmt := 'select objid,part_to_esn2part_inst,part_serial_no,x_part_inst_status ';
   sqlstmt:= sqlstmt||',part_inst2carrier_mkt,x_npa||x_nxx||x_ext';
   sqlstmt:= sqlstmt||' from table_part_inst ';
   sqlstmt:= sqlstmt||' WHERE  x_domain = ''LINES''';
   sqlstmt:= sqlstmt||' AND  objid in ('||ip_pi_objid_list  ||')';

select objid,
       carrier2personality
into l_carr_objid,
     l_personality_objid
from table_x_carrier xc
where x_carrier_id = ip_new_carr_id;
  open pi_cur for sqlstmt;
  loop
     fetch pi_cur into l_pi_line_objid, l_pi_esn_objid,
                       l_part_serial_no,l_status,l_line_carr_objid,l_min;
     exit when pi_cur%NOTFOUND;

     select x_carrier_id
     into l_old_carr_id
     from table_x_carrier
     where objid = l_line_carr_objid;

     if l_old_carr_id = ip_new_carr_id then
         op_msg := 'The NEW Carrier must be different from OLD Carrier';
         return;
     end if;
     if nvl(l_line_carr_objid_saved,l_line_carr_objid) <> l_line_carr_objid  then
         op_msg := 'The selected line(s) could not be updated because the MIN = '||
                   l_min||' does not have the same Carrier as the first MIN selected.'||
                   ' All the selected lines must have the same Carrier.';
         rollback;
         return;
     else
          l_line_carr_objid_saved := l_line_carr_objid;
     end if;

     select count(*)
     into carr_chng_ok_for_status
     from table_x_code_table
     where x_code_type = 'LS'
     and x_code_name in ('NEW','NEWHOLD','USED','USEDHOLD','ACTIVE')
     and x_code_number = l_status;
     if carr_chng_ok_for_status = 0 then
         op_msg := 'The selected line(s) could not be updated because the MIN = '||
                   l_min||' does not have a status of NEW,USED,HOLD,or ACTIVE.'||
                   ' Please Deselect this line.';
         rollback;
         return;
     end if;

     select  count(*)
     into area_code_valid_for_carr
     from table_x_lac
     where lac2personality = l_personality_objid
     and x_local_area_code = substr(l_min,1,3);
     if area_code_valid_for_carr = 0 then
         op_msg := 'The selected line(s) could not be updated because the Area Code = '||
                   substr(l_min,1,3)||' is not defined as a local carea code for '||
                   'the new Carrier. Add the area code to the Carrier and then try again.';
         rollback;
         return;
     end if;

     update table_part_inst
        set part_inst2x_pers = l_personality_objid ,
            part_inst2carrier_mkt = l_carr_objid
     where objid = l_pi_line_objid;

     l_lines_updated := l_lines_updated + 1 ;

     sa.insert_pi_hist_prc( ip_user_objid,
                            l_part_serial_no,
                            '',
                            '',
                            '',
                            'CARRIER CHANGE',
                            pi_hist_res);

  end loop;
  close pi_cur;
  op_msg := l_lines_updated ||' line(s) have been Updated.';
end;

---------------------------------------------------------------
procedure lm_deactivate_lines(ip_pi_objid_list in varchar2,
                           ip_user_objid in number,
                           ip_deact_reason in varchar2,
                           ip_create_action_item in varchar2,
                           op_ret out varchar2,
                           op_retmsg out varchar2) is
---------------------------------------------------------------
  l_user_objid number;
  l_msid varchar2(40);
  l_pi_line_objid number;
  l_esn table_part_inst.part_serial_no%TYPE;
  l_pi_esn_objid number;
  l_status table_part_inst.x_part_inst_status%TYPE;
  l_esn_status table_part_inst.x_part_inst_status%TYPE;
  l_bypass_ordertype number;
  l_lines_deactivated number := 0;

  pi_cur sys_refcursor;
  sqlstmt varchar2(4000);
  err_msg varchar2(4000);
  ttl_cnt number := 0;
begin
  sqlstmt := 'select objid,part_to_esn2part_inst,part_serial_no,x_part_inst_status ';
  sqlstmt:= sqlstmt||' from table_part_inst ';
  sqlstmt:= sqlstmt||' WHERE  x_domain = ''LINES''';
  sqlstmt:= sqlstmt||' AND  objid in ('||ip_pi_objid_list  ||')';

  if ip_create_action_item = '1' then
     l_bypass_ordertype := 0;
  else
     l_bypass_ordertype := 2;
  end if;

  open pi_cur for sqlstmt;
  loop
       fetch pi_cur into l_pi_line_objid, l_pi_esn_objid,l_msid,l_status;
       exit when pi_cur%notfound;
       ttl_cnt := ttl_cnt+1;

       begin
          select part_serial_no,x_part_inst_status
          into l_esn,l_esn_status
          from table_part_inst
          where objid = l_pi_esn_objid;
       exception
           when others then
           l_esn_status := -1;
       end;

       if ((l_esn_status = '52' and l_status = '13') or ip_deact_reason ='SENDCARDDEACT') then

            sa.service_deactivation.deactservice('TAS',
                                       ip_user_objid,
                                       l_esn,
                                       l_msid,
                                       ip_deact_reason,
                                       l_bypass_ordertype,
                                       '',
                                       'false',
                                       op_ret,
                                       op_retmsg);

      else
         op_ret := 'false';
      end if;

      if op_ret = 'false' then
        err_msg := err_msg||','||l_pi_line_objid;
      else
        l_lines_deactivated := l_lines_deactivated +1;
      end if;

  end loop;
  close pi_cur;

  op_retmsg := ' Total lines to process ('||ttl_cnt||') - Total lines deactivated ('||l_lines_deactivated||')'||chr(10)||
               ' problem objids '||substr(err_msg,2);

end;
---------------------------------------------------------------
procedure lm_extend_exp_date(ip_pi_objid_list in varchar2,
                          ip_user_objid in number,
                          ip_exp_date in date,
                          result out varchar2) is
---------------------------------------------------------------
  sqlstmt varchar2(500);
  pi_cur sys_refcursor;
  pi_rec table_part_inst%ROWTYPE;
  pi_hist_res number;
  ctr number := 0;
begin

 sqlstmt :=' select * from table_part_inst ';
 sqlstmt := sqlstmt|| ' where objid in ('||ip_pi_objid_list||')';

  open pi_cur for sqlstmt;
  loop
   fetch pi_cur into pi_rec;
   exit when pi_cur%NOTFOUND;

   if ( pi_rec.x_part_inst_status = '11') then --ONLY FOR NEW LINES

       update table_part_inst
       set warr_end_date= ip_exp_date
       where objid = pi_rec.objid;
       ctr := ctr + sql%ROWCOUNT;

       sa.insert_pi_hist_prc(ip_user_objid,
                         pi_rec.part_serial_no,
                         '',
                         '',
                         '',
                         'EXPIRED LINE',
                         pi_hist_res);
   end if;

  end loop;
  close pi_cur;
  result := ctr||' Line(s) updated';

end;
---------------------------------------------------------------
-- The following function is not called currently
procedure lm_return_to_carrier(ip_user_objid in number,
                            ip_pi_objid_list in varchar2,
                            op_result out varchar2) is
---------------------------------------------------------------
sqlstmt varchar2(500);
pi_cur sys_refcursor;
pi_rec table_part_inst%ROWTYPE;
l_status_objid number;
l_sp_objid number;
l_carr_rules_objid number;
l_acct_hist_objid number;

begin
 sqlstmt := 'select * from table_part_inst WHERE objid IN ( '||ip_pi_objid_list||')';

  select  objid
  into l_status_objid
  from table_x_code_table
  WHERE   x_code_name = 'RETURNED'
  AND X_CODE_TYPE = 'LS';


  open pi_cur for sqlstmt;
  loop
     fetch pi_cur into pi_rec;
     exit when pi_cur%NOTFOUND;

     begin
        select  objid
        into l_acct_hist_objid
        from table_x_account_hist
        where account_hist2part_inst IN ( pi_rec.objid );

        select  objid
        into l_sp_objid
        from table_site_part
        WHERE     x_min = pi_rec.part_serial_no ;

        select  carrier2rules
        into l_carr_rules_objid
        from table_x_carrier
        where objid = pi_rec.PART_INST2CARRIER_MKT;

        ----- Take out the required fields from the below table
        select objid
        into  l_carr_rules_objid
        from table_x_carrier_rules
        where objid = l_carr_rules_objid;

     exception
       when others then null;
     end;
  end loop;
  close pi_cur;
end;
---------------------------------------------------------------
procedure lm_hold_lines(ip_user_objid in number,
                        ip_pi_objid_list in varchar2,
                        op_result out varchar2) is
---------------------------------------------------------------
  pi_cur sys_refcursor;
  pi_rec table_part_inst%ROWTYPE;
  sqlstmt varchar2(4000);
  l_usedhold_objid number;
  l_usedhold_num  varchar2(5);
  l_newhold_objid number;
  l_newhold_num  varchar2(5);
  ctr number := 0;
  errctr number := 0;
begin
  sqlstmt := 'select * from table_part_inst ';
  sqlstmt := sqlstmt||' WHERE objid IN ( '||ip_pi_objid_list||')';

  select objid,x_code_number
  into l_usedhold_objid,
       l_usedhold_num
  from table_x_code_table
  where x_code_name = 'USEDHOLD'
  and x_code_type = 'LS';

  select objid,x_code_number
  into l_newhold_objid,
       l_newhold_num
  from table_x_code_table
  where x_code_name = 'NEWHOLD'
  and x_code_type = 'LS';

  open pi_cur for sqlstmt;
  loop
     fetch pi_cur into pi_rec;
     exit when pi_cur%NOTFOUND;

     if ( pi_rec.x_part_inst_status = '11') then
         update table_part_inst
         set x_part_inst_status= l_newhold_num,
             status2x_code_table=l_newhold_objid
         where objid = pi_rec.objid;
        ctr := ctr +1;
     elsif ( pi_rec.x_part_inst_status = '12' ) then
         update table_part_inst
         set x_part_inst_status= l_usedhold_num,
             status2x_code_table=l_usedhold_objid
         where objid = pi_rec.objid;
        ctr := ctr +1;
     else
        errctr := errctr+1;
     end if;

  end loop;
  close pi_cur;

  op_result := 'Requested ('||to_char(ctr+errctr)||') lines. Total lines held ('||ctr||') ';

end;
---------------------------------------------------------------
procedure lm_delete_lines( ip_user_objid in number,
                        ip_pi_objid_list in varchar2,
                        op_result out varchar2 ) is
---------------------------------------------------------------
  pi_cur sys_refcursor;
  Pi_Rec Table_Part_Inst%Rowtype;
  sqlstmt varchar2(4000);
  l_code_num varchar2(5);
  l_code_objid number;
  ctr number := 0;
  errctr number := 0;
  ret number;
begin
  sqlstmt := 'select * from table_part_inst WHERE objid IN ( '||ip_pi_objid_list||')';

  select objid,
         x_code_number
    into l_code_objid,
         l_code_num
  from table_x_code_table
  where x_code_name = 'DELETED'
  and x_code_type = 'LS';

  open pi_cur for sqlstmt;
  loop
     fetch pi_cur into pi_rec;
     exit when pi_cur%NOTFOUND;
     if ( pi_rec.x_part_inst_status  in ('11', --NEW
                                         '12', --USED
                                         '15', --NEWHOLD
                                         '16', --USEDHOLD
                                         '60'  --NTN
                                        )) then
           update table_part_inst
           set x_part_inst_status=l_code_num,
               status2x_code_table=l_code_objid
           where objid = pi_rec.objid;

           update table_x_account_hist
           set x_end_date= sysdate
           where account_hist2part_inst = pi_rec.objid;

           sa.insert_pi_hist_prc(ip_user_objid,
                                 pi_rec.part_serial_no,
                                 '',
                                 '',
                                 '',
                                 'DELETED',
                                 ret);
          ctr := ctr + 1;

    else
          errctr := errctr+1;
    end if;

  end loop;
  close pi_cur;

  op_result := 'Requested ('||to_char(ctr+errctr)||') lines. Total deleted ('||ctr||') ';

end;
---------------------------------------------------------------
procedure lm_set_lines_ntn(ip_user_objid in number,
                           ip_pi_objid_list in varchar2,
                           op_result out varchar2 ) is
---------------------------------------------------------------
  pi_cur sys_refcursor;
  pi_rec table_part_inst%rowtype;
  sqlstmt varchar2(4000);
  l_code_num varchar2(5);
  l_code_objid number;
  ctr number := 0;
  errctr number := 0;
  ret number;

begin

  sqlstmt := 'select * from table_part_inst WHERE objid IN ( '||ip_pi_objid_list||')';

  select objid,
         x_code_number
    into l_code_objid,
         l_code_num
  from table_x_code_table
  where x_code_name = 'NTN'
  and x_code_type = 'LS';

  open pi_cur for sqlstmt;
  loop
     fetch pi_cur into pi_rec;
     exit when pi_cur%NOTFOUND;
     if ( pi_rec.x_part_inst_status  in ('11', --NEW
                                         '12' --USED
                                        )) then
           update table_part_inst
           set x_part_inst_status=l_code_num,
               status2x_code_table=l_code_objid
           where objid = pi_rec.objid;

           update table_x_account_hist
           set x_end_date= sysdate
           where account_hist2part_inst = pi_rec.objid;

           sa.insert_pi_hist_prc(ip_user_objid,
                                 pi_rec.part_serial_no,
                                 '',
                                 '',
                                 '',
                                 'NTN',
                                 ret);
          ctr := ctr + 1;

    else
          errctr := errctr+1;
    end if;

  end loop;
  close pi_cur;

  op_result := 'Requested ('||to_char(ctr+errctr)||') lines. Total set to NTN ('||ctr||') ';

end;

---------------------------------------------------------------
procedure lm_change_msid( ip_user_objid in number,
                       ip_pi_objid in varchar2,
                       ip_new_msid in varchar2,
                       ip_second_call in varchar2,
                       op_result out varchar2 ) is
---------------------------------------------------------------
msid_exists number := 0;
l_esn_objid number;
l_active_rec_exists number := 0;
l_code_num varchar2(5);
l_code_objid number;
l_sp_objid number;
l_old_msid varchar2(12);
ret number;
begin
  if nvl(ip_second_call,'N') = 'N' then
      select  count(*)
      into msid_exists
      from table_part_inst
      WHERE  x_msid = ip_new_msid
       AND  x_part_inst_status IN ( '11',
                                    '12',
                                    '13',
                                    '15',
                                    '16',
                                    '34',
                                    '37',
                                    '38',
                                    '39',
                                    '60',
                                    '110',
                                    '73',
                                    '79' ) ;

      if (msid_exists <> 0 ) then
           op_result := 'Warning!'||chr(10)||'New MSID value is already in use by another line!'
                   ||chr(10)||'Press OK to continue or Cancel to stop.';
           return;

      end if;
  end if;
  select x_msid,
         part_to_esn2part_inst
  into l_old_msid,
       l_esn_objid
  from table_part_inst
  where objid = ip_pi_objid
  and x_domain = 'LINES';

  begin
     select x_part_inst2site_part
     into l_sp_objid
  from table_part_inst
     where objid = l_esn_objid;
  exception
     when others then
       l_sp_objid := -1;
  end;

  select count(*)
  into l_active_rec_exists
  from table_site_part
  where  objid = l_sp_objid
    AND  part_status = 'Active';

  if l_active_rec_exists = 0 then
       update table_part_inst
       set x_msid  = ip_new_msid
       where objid = ip_pi_objid;
  else
      select objid,
             x_code_number
      into   l_code_objid,
             l_code_num
      from table_x_code_table
      where x_code_name = 'PENDING MSID UPDATE'
      and x_code_type = 'LS';

       update table_part_inst
       set x_msid              = ip_new_msid,
           x_part_inst_status  = l_code_num,
           status2x_code_table = l_code_objid
       where objid = ip_pi_objid;
  end if;

  sa.insert_pi_hist_prc(ip_user_objid,
                        l_old_msid,
                        '',
                        '',
                        '',
                       'MSID CHANGE',
                        ret);
  op_result := 'MSID Updated';
end;

---------------------------------------------------------------
procedure lm_release_lines(ip_user_objid in number,
                           ip_pi_objid_list varchar2,
                           op_result out varchar2)
---------------------------------------------------------------
is
  pi_cur sys_refcursor;
  l table_part_inst%ROWTYPE;
  sqlstmt varchar2(4000);
  l_new_objid number;
  l_new_num  varchar2(20);
  l_out_val number;
  ctr number := 0;
  errctr number := 0;
begin

  sqlstmt := 'select * from table_part_inst WHERE objid  IN ( '||ip_pi_objid_list||')';

  select objid,x_code_number
  into l_new_objid,l_new_num
  from table_x_code_table
  where x_code_name = 'NEW'
  and x_code_type = 'LS';

  open pi_cur for sqlstmt;
  loop
    fetch pi_cur into l;
    exit when pi_cur%NOTFOUND;

    if l.x_part_inst_status in( '15','16') then
      update table_part_inst
      set x_part_inst_status= l_new_num,
      status2x_code_table=l_new_objid
      where objid = l.objid;
      commit;
      sa.insert_pi_hist_prc(ip_user_objid,l.part_serial_no,'','','','RELEASED LINE',l_out_val);
      ctr := ctr +1;
    else
      errctr := errctr+1;
    end if;

  end loop;
  close pi_cur;

  op_result := 'Requested ('||to_char(ctr+errctr)||') lines. Total lines released ('||ctr||') ';

end;

---------------------------------------------------------------
procedure lm_add_lines(ip_user_objid number,
                      ip_carr_id varchar2,
                      ip_account_num varchar2,
                      ip_npa varchar2,
                      ip_nxx varchar2,
                      ip_from_ext varchar2,
                      ip_to_ext varchar2,
                      ip_exp_date varchar2,
                      ip_msid varchar2,
                      op_msg out varchar2)
is
---------------------------------------------------------------
 l_luts number ;
 l_msid varchar2(30);
 l_carr number;
 l_user number;
 l_pers number;
 l_warr_end_date number;
 l_status_code varchar2(5) ;
 l_status_objid number ;
 l_part_mod number;
 l_account number;
 l_part_serial_no varchar2(30);
 l_pi_obj number;
 l_quantity number;
 l_ext varchar2(10);
 l_exp_date date;
 l_mdn_count number := 0;
 l_msid_exists number := 0;
 l_updtble_line_sts varchar2(20);
 l_lines_added number := 0;
 pi_hist_res number;

 cursor carrier_info is
  select tc.objid car_obj, tr.X_LINE_EXPIRE_DAYS, tp.objid per_obj
  from table_x_carrier tc, table_x_carr_personality tp, table_x_carrier_rules tr
  where tp.objid=carrier2personality
  and carrier2rules=tr.objid
  and X_CARRIER_ID=ip_carr_id;

 l_carrier_info carrier_info%rowtype;
begin

    SP_CHECK_LUTS(ip_npa, ip_nxx, l_luts);
    if l_luts <1 then
        op_msg := 'NPA and NXX do not exist in LUTS constraint table.'
               ||chr(10)||'Lines not added.';
        return;
    end if;

    select count(*)
    into l_mdn_count
    from table_part_inst
    where  x_part_inst_status in ( '11','12','13','15' ,'16','34','37' ,'38','39','110' )
    and   x_domain = 'LINES'
    and  x_npa = ip_npa
    and  x_nxx = ip_nxx
    and x_ext>=ip_from_ext
    and x_ext<=ip_to_ext;

    if l_mdn_count > 0 then
            op_msg := 'MDN '||ip_npa||' '||ip_nxx||' '||l_ext||
                      ' was specified to be added, but it already exists and '||
                      'has a status code that does not allow it to be added. '||
                      'Either the range must be changed or the MDN must be updated. ';
            return;
    end if;

    open carrier_info;
    fetch carrier_info into l_carrier_info;
    if  carrier_info%notfound then
         op_msg := 'Carrier does not exist';
         return;
    else
         l_carr:=l_carrier_info.car_obj;
         l_pers:=l_carrier_info.per_obj;
         l_warr_end_date:=l_carrier_info.X_LINE_EXPIRE_DAYS;
    end if;
    close carrier_info;


    if ip_msid is null then
      l_quantity:=to_number(nvl(ip_to_ext,ip_from_ext))-to_number(ip_from_ext)+1;
    else
       l_quantity:=1;
    end if;

    for i in 1..l_quantity
    loop
       l_ext:=trim(to_char(to_number(ip_from_ext)+i-1,'0000'));
       l_part_serial_no:=ip_npa||ip_nxx||l_ext;

       if ip_msid is null then
          l_msid:=l_part_serial_no;
       else
          l_msid:=ip_msid;
       end if;

       select count(*)
       into   l_msid_exists
       from   table_part_inst
       where  x_part_inst_status in ('11','12','13','15' ,'16','34','37' ,'38','39','110')
       and    x_domain = 'LINES'
       and    x_msid = l_msid;

       if l_msid_exists  <> 0 then
               op_msg := op_msg||'|NEW MSID value '||l_msid||' is used by another line.' ;
                        --||chr(10)||'Press OK to continue or Cancel to stop.';
                goto try_next_line;
       end if;

       begin
         -- ESN EXISTS BUT, WASN'T CAUGHT ABOVE STATUS >> ('17','18','33','35','36','60','73','79')
         select objid,
                x_part_inst_status
         into   l_pi_obj,
                l_updtble_line_sts
         from   table_part_inst
         where  1=1
         and    x_domain = 'LINES'
         and    x_msid = l_msid;
       exception
         when others then
           l_pi_obj := seq('part_inst');
       end;

       if l_updtble_line_sts in ('11','12','13','15' ,'16','34','37' ,'38','39','110') then
         op_msg := op_msg||'|NEW MSID value '||l_msid||' is used by another line.' ;
         goto try_next_line;
       end if;

       select objid,
              x_code_number
       into l_status_objid,
            l_status_code
       from table_x_code_table
       where x_code_name ='NEW'
       and x_code_type = 'LS';

       select ml.objid
       into l_part_mod
       from table_part_num pn, table_mod_level ml
       WHERE S_part_number =  'LINES'
       and pn.objid=part_info2part_num
       and rownum<2;

       select objid
       into l_account
       from table_x_account
       where x_acct_num = ip_account_num
       AND account2x_carrier =l_carr;

       if ip_exp_date is not null
       then
          l_exp_date := to_date(ip_exp_date,'MM/DD/YYYY') ;
       end if;

       if l_updtble_line_sts in ('17','18','33','35','36','60','73','79') then
         update table_part_inst
         set    part_good_qty         = 1,
                part_bad_qty          = 0,
                part_serial_no        = l_part_serial_no,
                part_mod              = null,
                part_bin              = null,
                last_pi_date          = TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                pi_tag_no             = null,
                last_cycle_ct         = TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                next_cycle_ct         = TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                last_mod_time         = TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                last_trans_time       = TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                transaction_id        = null,
                date_in_serv          = TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                warr_end_date         = l_exp_date,
                repair_date           = TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                part_status           = 'Active',
                pick_request          = null,
                good_res_qty          = 0,
                bad_res_qty           = 0,
                hdr_ind               = 0,
                x_insert_date         = sysdate,
                x_sequence            = 0,
                x_creation_date       = sysdate,
                x_po_num              = null,
                x_red_code            = null,
                x_domain              = 'LINES',
                x_deactivation_flag   = 0,
                x_reactivation_flag   = 0,
                x_cool_end_date       = TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                x_part_inst_status    = l_status_code,
                x_npa                 = ip_npa,
                x_nxx                 = ip_nxx,
                x_ext                 = l_ext,
                x_order_number        = null,
                x_ld_processed        = null,
                x_msid                = l_msid,
                x_iccid               = null,
                x_clear_tank          = 0,
                x_port_in             = 0,
                x_hex_serial_no       = null,
                created_by2user       = ip_user_objid,
                part_inst2carrier_mkt = l_carr,
                status2x_code_table   = l_status_objid,
                n_part_inst2part_mod  = l_part_mod,
                part_inst2x_pers      = l_pers
         where  objid = l_pi_obj;

       else
         insert into table_part_inst
                              (objid,
                              part_good_qty,
                              part_bad_qty,
                              part_serial_no,
                              part_mod,
                              part_bin,
                              last_pi_date,
                              pi_tag_no,
                              last_cycle_ct,
                              next_cycle_ct,
                              last_mod_time,
                              last_trans_time,
                              transaction_id,
                              date_in_serv,
                              warr_end_date,
                              repair_date,
                              part_status,
                              pick_request,
                              good_res_qty,
                              bad_res_qty,
                              hdr_ind,
                              x_insert_date,
                              x_sequence,
                              x_creation_date,
                              x_po_num,
                              x_red_code,
                              x_domain,
                              x_deactivation_flag,
                              x_reactivation_flag,
                              x_cool_end_date,
                              x_part_inst_status,
                              x_npa,x_nxx,x_ext,
                              x_order_number,
                              x_ld_processed,
                              x_msid,
                              x_iccid,
                              x_clear_tank,
                              x_port_in,
                              x_hex_serial_no,
                              created_by2user,
                              part_inst2carrier_mkt,
                              status2x_code_table,
                              n_part_inst2part_mod,
                              part_inst2x_pers)
                      values( l_pi_obj,
                              1,
                              0,
                              l_part_serial_no,
                              '',
                              '',
                              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                              '',
                              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                              '',
                              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                              l_exp_date,
                              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                              'Active',
                              '',
                              0,
                              0,
                              0,
                              sysdate,
                              0,
                              sysdate,
                              '',
                              '',
                              'LINES',
                              0,
                              0,
                              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                              l_status_code,
                              ip_npa,
                              ip_nxx,
                              l_ext,
                              '',
                              '',
                              l_msid,
                              '',
                              0,
                              0,
                              '',
                              ip_user_objid,
                              l_carr,
                              l_status_objid,
                              l_part_mod,
                              l_pers);
       end if;
           insert into table_x_account_hist (objid,
                                     x_start_date,
                                     x_end_date,
                                     account_hist2part_inst,
                                     account_hist2x_account)
                               values(seq('x_account_hist'),
                                      sysdate,
                                      TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                                      l_pi_obj,
                                      l_account);
       sa.insert_pi_hist_prc(ip_user_objid,
                         l_part_serial_no,
                         '',
                         '',
                         '',
                         'ADD LINE',
                         pi_hist_res);

      l_lines_added := l_lines_added + 1;
<<try_next_line>>
null;
    end loop;
  if op_msg is not null then
     op_msg := substr(op_msg,2)||'|'||l_lines_added||' Line(s) were added.';
  else
     op_msg := l_lines_added||' Line(s) were added.';
  end if;
exception
  when others then
    if instr(sqlerrm,'IND_PART_INST_PSERIAL_U11')>0 then
      op_msg := 'ERROR - Line already exists.';
    else
      op_msg := 'ERROR - '||sqlerrm;
    end if;
end;
---------------------------------------------------------------
procedure lm_area_code_change(ip_grid_lines_cbox  number,
                              ip_change_ac_cbox number,
                              ip_serial_no_list in varchar2,
                              ip_user_objid in number,
                              ip_old_area_code in varchar2,
                              ip_old_nxx in varchar2,
                              ip_new_area_code in varchar2,
                              op_result out varchar2) is
---------------------------------------------------------------
  sqlstmt varchar2(4000);
  l_reserved_ac_objid number;
  l_reserved_ac_number varchar2(5);
  l_ac_returned_objid number;
  l_ac_returned_number varchar2(5);
  l_ac_voided_objid number;
  l_ac_voided_number varchar2(5);
  l_pending_ac_objid number;
  l_pending_ac_number varchar2(5);
  l_carrier_personality_objid number;
  l_carrier_name table_x_carrier.x_mkt_submkt_name%TYPE;
  l_carr_valid_change number;
  l_achist_rec table_x_account_hist%ROWTYPE;
  l_acct_rec table_x_account%ROWTYPE;
  new_part_serial_no table_part_inst.part_serial_no%TYPE;
  new_pi_objid table_part_inst.objid%TYPE;
  date1753 date := to_date('01-01-1753','MM-DD-YYYY');
  pi_cur sys_refcursor;
  active_sp_record_exists number;
  psno_exists number := 0;
  l_old_psno  table_part_inst.part_serial_no%TYPE;
  pi_rec  table_part_inst%ROWTYPE;
  pi_hist_res number;
  sp_acc_status varchar2(300);
begin

 if ip_grid_lines_cbox = 0  then
       SP_AREA_CODE_CHANGE(ip_old_area_code,
                           ip_old_nxx ,
                           ip_new_area_code,
                           sp_acc_status,
                           op_result);
       return;
 end if;

 sqlstmt := ' select  * from table_part_inst where x_domain = ''LINES''';
 sqlstmt := sqlstmt ||' and  part_serial_no IN ('||ip_serial_no_list||')  ';

 select  objid, x_code_number
 into l_reserved_ac_objid,
      l_reserved_ac_number
 from table_x_code_table
 WHERE   x_code_name =  'RESERVED AC' ;

 select  objid, x_code_number
 into l_ac_voided_objid,
      l_ac_voided_number
 from table_x_code_table
 WHERE   x_code_name =  'AC VOIDED' ;

 select  objid, x_code_number
 into l_ac_returned_objid,
      l_ac_returned_number
 from table_x_code_table
 WHERE   x_code_name =  'AC RETURNED' ;

 select  objid, x_code_number
 into l_pending_ac_objid,
      l_pending_ac_number
 from table_x_code_table
 WHERE   x_code_name =  'PENDING AC CHANGE'  ;

  open pi_cur for sqlstmt;
  loop
      fetch pi_cur into pi_rec;
      exit when pi_cur%NOTFOUND;

      l_old_psno:= pi_rec.part_serial_no;

      select cp.objid,x_mkt_submkt_name
      into l_carrier_personality_objid,
           l_carrier_name
      from table_x_carrier xc,
           table_x_carr_personality cp
      WHERE  xc.carrier2personality=cp.objid
      and   xc.objid  = pi_rec.part_inst2carrier_mkt;

     select  count(*)
     into l_carr_valid_change
     from table_x_lac
     where lac2personality = l_carrier_personality_objid
     and x_local_area_code = ip_new_area_code;

     if (l_carr_valid_change <> 1 ) then
         op_result := 'Local Area Code '||ip_new_area_code||
                      ' not defined for carrier '||l_carrier_name;
         return;
     end if;

     new_part_serial_no := ip_new_area_code||substr(pi_rec.part_serial_no,4);
     select count(*)
     into psno_exists
     from table_part_inst
     where part_serial_no = new_part_serial_no;
     if psno_exists > 0 then
         op_result := 'Area Code change could not be processed because '||
                  'the line '||new_part_serial_no||' already exists in '||
                  'the new Area Code';
         return;
     end if;

     begin
         select  * --objid, x_start_date,x_end_date,account_hist2x_account
         into l_achist_rec
         from table_x_account_hist
         where account_hist2part_inst = pi_rec.objid;
     exception
         when no_data_found then
            op_result := 'MIN '||pi_rec.part_serial_no||' has no account '||
                      'history. Please note this MIN and notify IT so it '||
                      ' can be fixed';
     end;

     select count(*)
     into active_sp_record_exists
     from table_site_part
     where x_service_id = pi_rec.part_serial_no
     and part_status = 'Active';

     begin
        select  * -- objid, x_acct_num, x_status
        into l_acct_rec
        from table_x_account
        where objid =  ( select account_hist2x_account
                    from table_x_account_hist
                    where account_hist2part_inst = pi_rec.objid);
     exception
         when others then null;
     end;

     if active_sp_record_exists > 0 then
         update table_part_inst
           set x_part_inst_status=l_pending_ac_number,
           status2x_code_table=l_pending_ac_objid
         where objid = pi_rec.objid;
         op_result := op_result||'|'||'Area Code Change Completed';
     end if;

     pi_rec.part_serial_no := new_part_serial_no;
     pi_rec.warr_end_date  := sysdate;
     pi_rec.part_status := 'Active';
     pi_rec.x_insert_date := sysdate;
     pi_rec.x_creation_date := sysdate+1;
     pi_rec.x_npa           := ip_new_area_code;
     pi_rec.created_by2user := ip_user_objid;

     if ( pi_rec.x_part_inst_status in ('11','12')) then  --NEW

          new_pi_objid := ins_new_pi_rec(pi_rec);

          update table_part_inst
              set x_part_inst_status=l_ac_returned_number,
                  status2x_code_table=l_ac_returned_objid
          where objid = pi_rec.objid;
         op_result := op_result||'|'||'Area Code Change Completed';

    elsif ( pi_rec.x_part_inst_status in ('13')) then --ACTIVE

          pi_rec.x_part_inst_status  := l_reserved_ac_number;
          pi_rec.status2x_code_table := l_reserved_ac_objid;
          new_pi_objid := ins_new_pi_rec(pi_rec);

          update table_part_inst
              set x_part_inst_status=l_pending_ac_number,
                  status2x_code_table=l_pending_ac_objid
          where objid = pi_rec.objid;
         op_result := op_result||'|'||'Area Code Change Completed';

    end if;

    insert into table_x_account_hist (objid,
                                  x_start_date,
                                  x_end_date,
                                  account_hist2part_inst,
                                  account_hist2x_account)
                           values(seq('x_account_hist'),
                                  date1753,
                                  date1753,
                                  new_pi_objid,
                                  l_acct_rec.objid);
    update table_x_account_hist
      set x_end_date= sysdate
    where objid = l_achist_rec.objid;

    sa.insert_pi_hist_prc(ip_user_objid,
                          new_part_serial_no,
                          '',
                          '',
                          pi_rec.x_ext,
                          'AC CHANGE',
                          pi_hist_res);
    sa.insert_pi_hist_prc(ip_user_objid,
                          l_old_psno,
                          '',
                          '',
                          pi_rec.x_ext,
                          'AC CHANGE',
                          pi_hist_res);

  end loop;
  close pi_cur;

exception
  when others then
    op_result := 'AREA CODE CHANGE - '||sqlstmt;
end;
---------------------------------------------------------------
procedure cops_search(ip_carr_name in varchar2,
                      ip_carr_group_id in varchar2,
                      ip_mkt_submkt_name in varchar2,
                      ip_carr_id in varchar2,
                      ip_state in varchar2,
                      ip_city in varchar2,
                      ip_parent_x_parent_name in varchar2,
                      ip_parent_x_parent_id in varchar2,
                      ip_include_inactive  in number,
                      op_carr_list out sys_refcursor) is
---------------------------------------------------------------
sqlstmt varchar2(3000);
begin
    sqlstmt := ' select  distinct x_carrier_name,';
    sqlstmt := sqlstmt||' x_carrier_group_id, ';
    sqlstmt := sqlstmt||' x_group_status, ';
    sqlstmt := sqlstmt||' x_parent_x_parent_name, ';
    sqlstmt := sqlstmt||' x_parent_x_parent_id, ';
    sqlstmt := sqlstmt||' x_parent_x_status ';
    sqlstmt := sqlstmt||' from table_x_carr_srch_view ';
    sqlstmt := sqlstmt||' where  1=1 ';
    if ip_carr_name is not null then
       sqlstmt:= sqlstmt||' and x_carrier_name LIKE '''||upper(ip_carr_name)||'%''';
    end if;
    if ip_carr_group_id is not null then
       sqlstmt:= sqlstmt||' and x_carrier_group_id = '||ip_carr_group_id;
    end if;
    if ip_mkt_submkt_name is not null then
       sqlstmt:= sqlstmt||' and x_mkt_submkt_name like '''||
                 upper(ip_mkt_submkt_name)||'%''';
    end if;
    if ip_carr_id is not null then
       sqlstmt:= sqlstmt||' and x_carrier_id = '||ip_carr_id;
    end if;
    if ip_state is not null then
       sqlstmt:= sqlstmt||' and x_state like '''||upper(ip_state)||'%''';
    end if;
    if ip_city is not null then
       sqlstmt:= sqlstmt||' and x_city like '''||upper(ip_city)||'%''';
    end if;
    if ip_parent_x_parent_name is not null then
       sqlstmt:= sqlstmt||' and x_parent_x_parent_name like '''||
                 upper(ip_parent_x_parent_name)||'%''';
    end if;
    if ip_parent_x_parent_id is not null then
       sqlstmt:= sqlstmt||' and x_parent_x_parent_id = '||ip_parent_x_parent_id;
    end if;
    if ip_include_inactive = 0 then
       sqlstmt:= sqlstmt||' and x_group_status = ''ACTIVE''';
    end if;
    sqlstmt := sqlstmt||' order by x_carrier_name desc';
    open op_carr_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_search_detail (ip_carr_name in varchar2,
                              ip_carr_group_id in varchar2,
                              ip_mkt_submkt_name in varchar2,
                              ip_carr_id in varchar2,
                              ip_state in varchar2,
                              ip_city in varchar2,
                              ip_parent_x_parent_name in varchar2,
                              ip_parent_x_parent_id in varchar2,
                              ip_include_inactive  in number,
                              op_carr_list out sys_refcursor) is
---------------------------------------------------------------
sqlstmt varchar2(3000);
begin

    sqlstmt := ' select  carrier_objid,';
    sqlstmt := sqlstmt||' x_mkt_submkt_name,';
    sqlstmt := sqlstmt||' x_carrier_id, ';
    sqlstmt := sqlstmt||' x_state, ';
    sqlstmt := sqlstmt||' x_city, ';
    sqlstmt := sqlstmt||' x_carrier_status ';
    sqlstmt := sqlstmt||' from table_x_carr_srch_view ';
    sqlstmt := sqlstmt||' where  1=1 ';
    if ip_carr_name is not null then
       sqlstmt:= sqlstmt||' and x_carrier_name LIKE '''||upper(ip_carr_name)||'%''';
    end if;
    if ip_carr_group_id is not null then
       sqlstmt:= sqlstmt||' and x_carrier_group_id = '||ip_carr_group_id;
    end if;
    if ip_mkt_submkt_name is not null then
       sqlstmt:= sqlstmt||' and x_mkt_submkt_name like '''||
                 upper(ip_mkt_submkt_name)||'%''';
    end if;
    if ip_carr_id is not null then
       sqlstmt:= sqlstmt||' and x_carrier_id = '||ip_carr_id;
    end if;
    if ip_state is not null then
       sqlstmt:= sqlstmt||' and x_state like '''||upper(ip_state)||'%''';
    end if;
    if ip_city is not null then
       sqlstmt:= sqlstmt||' and x_city like '''||upper(ip_city)||'%''';
    end if;
    if ip_parent_x_parent_name is not null then
       sqlstmt:= sqlstmt||' and x_parent_x_parent_name like '''||
                 upper(ip_parent_x_parent_name)||'%''';
    end if;
    if ip_parent_x_parent_id is not null then
       sqlstmt:= sqlstmt||' and x_parent_x_parent_id = '||ip_parent_x_parent_id;
    end if;
    if ip_include_inactive = 0 then
       sqlstmt:= sqlstmt||' and x_carrier_status = ''ACTIVE''';
    end if;
    sqlstmt := sqlstmt||' order by x_carrier_name desc';
    open op_carr_list for sqlstmt;
end;
---------------------------------------------------------------
procedure create_new_parent(ip_parent_name in varchar2,
                            ip_psms_address in varchar2,
                            op_parent_id out varchar2)
is
---------------------------------------------------------------
begin
insert into table_x_parent (objid,
                            x_parent_name,
                            x_parent_id,
                            x_status,
                            x_hold_analog_deac,
                            x_hold_digital_deac,
                            x_no_inventory,
                            x_vm_access_num,
                            x_no_msid,
                            x_auto_port_in,
                            x_auto_port_out,
                            x_ota_carrier,
                            x_ota_psms_address,
                            x_ota_start_date,
                            x_ota_end_date,
                            x_next_available,
                            x_queue_name,
                            x_block_port_in,
                            x_meid_carrier,
                            x_ota_react)
                     values(seq('X_PARENT'),
                            ip_parent_name,
                            SEQU_X_PARENT_ID.nextval,
                            'INACTIVE',
                            0,
                            0,
                            0,
                            '',
                            0,
                            0,
                            0,
                            'N',
                            ip_psms_address,
                            TO_DATE( '01/01/1753', 'MM/DD/YYYY'),
                            TO_DATE( '01/01/1753', 'MM/DD/YYYY'),
                            0,
                            '',
                            0,
                            0,
                            0) returning x_parent_id into op_parent_id;
end;
---------------------------------------------------------------
procedure cops_edit_parent(ip_parent_id in number,
                             ip_parent_name in varchar2,
                             ip_vm_access_num in varchar2,
                             ip_ota_psms_address in varchar2,
                             ip_status in number,
                             ip_no_msid in number,
                             ip_auto_port_in in number,
                             ip_ota_active in number,
                             ip_no_inventory in number,
                             ip_auto_port_out in number)
                              is
---------------------------------------------------------------
begin
   update table_x_parent
   set x_parent_name=ip_parent_name,
       x_status=decode(ip_status,1,'ACTIVE','INACTIVE'),
       x_no_inventory= ip_no_inventory,
       x_vm_access_num=ip_vm_access_num,
       x_no_msid=ip_no_msid,
       x_auto_port_in=ip_auto_port_in,
       x_auto_port_out=ip_auto_port_out,
       x_ota_carrier=decode(ip_ota_active,1,'Y','N'),
       x_ota_psms_address=ip_ota_psms_address
   where x_parent_id = ip_parent_id;
end;
---------------------------------------------------------------
procedure cops_display_ai_list(ip_parent_id in number,
                               op_ai_list out sys_refcursor,
                               op_blocked_ai_list out sys_refcursor) is
---------------------------------------------------------------
begin
  open op_ai_list for 'select x_code_name,x_code_number,x_value
  from table_x_code_table where x_code_type = ''DA''';

  open op_blocked_ai_list for 'select  x_code_number, x_code_name from table_x_block_deact
  where x_parent_id = '||ip_parent_id||'  AND  x_block_active = 1';
end;
---------------------------------------------------------------
procedure cops_handle_ai(ip_action in varchar2,
                        ip_parent_id in number,
                        ip_user_id in number,
                        ip_code_number in number,
                        ip_code_name in varchar2,
                        op_out_msg out varchar2 )
is
---------------------------------------------------------------
entry_exists number;
begin
if(upper(ip_action) = 'BLOCK') then
    select count(*)
    into entry_exists
    from table_x_block_deact
    where x_parent_id = ip_parent_id
    and x_code_name = ip_code_name
    and x_block_active =1;

    if entry_exists  = 0 then
        insert into table_x_block_deact (objid,
                                 x_parent_id,
                                 x_code_number,
                                 x_code_name,
                                 x_block_active,
                                 x_created_by,
                                 x_created_date,
                                 x_removed_by,
                                 x_removed_date)
                          values(seq('x_block_deact'),
                                 ip_parent_id,
                                 ip_code_number,
                                 ip_code_name,
                                 1,
                                 ip_user_id,
                                 sysdate,
                                 '',
                                 TO_DATE( '01/01/1753', 'MM/DD/YYYY'));
    else
        op_out_msg := 'Block is already active for this reason';
    end if;
elsif (upper(ip_action) = 'UNBLOCK' ) then
   update table_x_block_deact
   set x_block_active=0,
       x_removed_by=ip_user_id,
       x_removed_date= sysdate
   where x_parent_id = ip_parent_id
   and x_code_name = ip_code_name;

else
  null;
end if;
end;

---------------------------------------------------------------
procedure cops_search_parent(ip_parent_id in varchar2,
                             ip_parent_name in varchar2,
                             op_parent_list out sys_refcursor) is
---------------------------------------------------------------
sqlstmt varchar2(300);
begin
  sqlstmt := 'select  objid, x_parent_name, x_parent_id, x_status,';
  sqlstmt := sqlstmt||'x_vm_access_num,x_auto_port_in,x_auto_port_out,';
  sqlstmt := sqlstmt||'x_ota_psms_address,x_no_msid,x_no_inventory,';
  sqlstmt := sqlstmt||'x_ota_carrier';
  sqlstmt := sqlstmt||' from table_x_parent ';
  sqlstmt := sqlstmt||' WHERE 1=1 ';
  if ip_parent_name is not null then
       sqlstmt := sqlstmt||' and x_parent_name LIKE '''||ip_parent_name||'%''';
  end if;
  if ip_parent_id is not null then
      sqlstmt := sqlstmt||' and x_parent_id = '||ip_parent_id;
  end if;

  print_line(sqlstmt);
  open op_parent_list for sqlstmt;

end;
---------------------------------------------------------------
procedure cops_get_hq_address(ip_carr_group_id varchar2,
                              op_carr_hq_address out sys_refcursor) is
---------------------------------------------------------------
 sqlstmt varchar2(300);
begin
  sqlstmt := ' select address,address_2,city,state,zipcode ';
  sqlstmt :=sqlstmt||' from table_address a, table_x_carrier_group cg ';
  sqlstmt :=sqlstmt||' where a.objid = cg.x_group2address ';
  sqlstmt :=sqlstmt||' and x_carrier_group_id =  '||ip_carr_group_id;
  open op_carr_hq_address for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_add_carrier_group(ip_address in out varchar2,
                           ip_address2 in out varchar2,
                           ip_city in out varchar2,
                           ip_state in out varchar2,
                           ip_zip   in out varchar2,
                           ip_hq_address in varchar2,
                           ip_hq_address2 in varchar2,
                           ip_hq_city in varchar2,
                           ip_hq_state in varchar2,
                           ip_hq_zip in varchar2,
                           ip_parent_id in varchar2,
                           ip_carr_group_objid in varchar2,
                           ip_mkt_submkt_name in varchar2, -- carr desc name
                           ip_carr_id in varchar2,
                           ip_carr_city in varchar2,
                           ip_carr_state in varchar2,
                           ip_mkt_type in varchar2,
                           ip_submkt_of in varchar2,
                           op_msg  out varchar2) is
---------------------------------------------------------------
l_address_seq number;
l_carr_objid number;
l_parent_objid number;
l_stateprov_objid number;
l_country_objid number;
l_hq_stateprov_objid number;
l_hq_country_objid number;
cid_exists number := 0;
begin

   select objid,state_prov2country
   into l_hq_stateprov_objid,l_hq_country_objid
   from table_state_prov
   where s_name = ip_hq_state;

   if ( ip_address is null ) then
       ip_address := ip_hq_address;
   end if;
   if ( ip_address2 is null) then
       ip_address2 := ip_hq_address2;
   end if;
   if ( ip_city is null) then
       ip_city := ip_hq_city;
   end if;
   if ( ip_state is null) then
       ip_state := ip_hq_state;
   end if;
   if ( ip_zip is null ) then
         ip_zip := ip_hq_zip;
   end if;

   select objid,state_prov2country
   into l_stateprov_objid,l_country_objid
   from table_state_prov
   where s_name = upper(ip_state);

   select count(*)
   into cid_exists
   from table_x_carrier
   where x_carrier_id = ip_carr_id;
   if cid_exists > 0 then
        op_msg := 'A carrier with the same carrier ID already exists.'||
                  'No save was performed. Please change the carrier ID and resave ';
         return;
   end if;

   select objid
   into l_parent_objid
   from table_x_parent
   where x_parent_id = ip_parent_id;

   insert into table_address (objid,
                           address,
                           s_address,
                           city,
                           s_city,
                           state,
                           s_state,
                           zipcode,
                           address_2,
                           update_stamp,
                           address2time_zone,
                           address2state_prov,
                           address2country)
                    values(seq('address'),
                           ip_address,
                           upper(ip_address),
                           ip_city,
                           upper(ip_city),
                           ip_state,
                           upper(ip_state),
                           ip_zip,
                           ip_address2,
                           sysdate,
                           268435561, --time_zone
                           l_stateprov_objid,
                           l_country_objid) returning objid into l_address_seq;


   update table_address
   set address=ip_hq_address,
       s_address=upper(ip_hq_address2),
       city = ip_hq_city,
       s_city=upper(ip_hq_city),
       state=ip_hq_state,
       s_state = upper(ip_hq_state),
       update_stamp= sysdate,
       address2time_zone=268435561,
       address2state_prov=l_hq_stateprov_objid,
       address2country=l_hq_country_objid
   where objid = (select x_group2address
                  from table_x_carrier_group
                  where objid = ip_carr_group_objid);

   insert into table_x_carrier (objid, x_carrier_id, x_mkt_submkt_name,
                           x_submkt_of, x_city, x_state,
                           x_tapereturn_charge, x_country_code, x_activeline_percent,
                           x_status, x_ld_provider, x_ld_account,
                           x_ld_pic_code, x_rate_plan, x_dummy_esn,
                           x_bill_date, x_voicemail, x_vm_code,
                           x_vm_package, x_caller_id, x_id_code,
                           x_id_package, x_call_waiting, x_cw_code,
                           x_cw_package, x_react_technology, x_react_analog,
                           x_act_technology, x_act_analog, x_digital_rate_plan,
                           x_digital_feature, x_prl_preloaded, x_special_mkt,
                           x_new_analog_plan, x_new_digital_plan, x_sms,
                           x_sms_code, x_sms_package, x_vm_setup_land_line,
                           x_data_service, x_automated, carrier2carrier_group,
                           x_carrier2address)
                    values( seq('x_carrier'), ip_carr_id, ip_mkt_submkt_name,
                           ip_submkt_of,ip_carr_city, ip_carr_state,
                            0.0,0, 0.000000,
                            'INACTIVE', '', '',
                            '', '', '',
                            TO_DATE( '1/1/1753', 'MM/DD/YYYY'), 0, '',
                            0, 0, '',
                            0, 0, '',
                            0, '', 0,
                            '', 0, '',
                            '', 0, ip_mkt_type,
                            '', '', 0,
                            '', 0, 0,
                            0, 0,  ip_carr_group_objid,
                           l_address_seq) returning objid into l_carr_objid;

   update table_x_carrier_group
    set x_carrier_group2x_parent = l_parent_objid
   where objid = ip_carr_group_objid;

   insert into table_x_carriergroup_hist (objid,
                           x_start_date,
                           x_end_date,
                           x_cargrp_hist2x_car,
                           x_cargrp_hist2x_cargrp)
                    values(seq('x_carriergroup_hist'),
                           sysdate,
                           TO_DATE('1/1/1753','MM/DD/YYYY'),
                           ip_carr_group_objid,
                           l_carr_objid);
   insert into table_x_parent_hist (objid,
                           x_begin_date,
                           x_end_date,
                           x_parent_hist2x_carrier_group,
                           x_parent_hist2x_parent)
                   values(seq('x_parent_hist'),
                           sysdate,
                           TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
                           ip_carr_group_objid,
                           l_parent_objid);
  op_msg := 'Carrier market has been added.';
  op_msg := op_msg ||' Carrier rules and a personality need to be added ';
  op_msg := op_msg ||'for the new carrier market';

end;
---------------------------------------------------------------
procedure cops_get_carrier_group (ip_carr_group_id in varchar2,
                                  ip_carr_id in varchar2,
                                  op_carr_group_rec out sys_refcursor)
---------------------------------------------------------------
is
sqlstmt varchar2(3000);
begin
   sqlstmt :=          ' select x_parent_id ,x_parent_name ,p.x_status parent_status,';
   sqlstmt := sqlstmt||      ' x_carrier_group_id ,x_carrier_name,cg.x_status ';
   sqlstmt := sqlstmt||      ' carr_group_status, a1.objid hq_add_objid,';
   sqlstmt := sqlstmt||      ' a1.address hq_add1,a1.address_2 hq_add2,a1.city hq_city,';
   sqlstmt := sqlstmt||      ' a1.state hq_state,a1.zipcode hq_zip,a2.objid add_objid,';
   sqlstmt := sqlstmt||      ' a2.address add1,';
   sqlstmt := sqlstmt||      ' a2.address_2 add2,a2.city city,a2.state state,a2.zipcode zip,';
   sqlstmt := sqlstmt||      ' c.objid carr_objid, x_mkt_submkt_name,x_carrier_id,';
   sqlstmt := sqlstmt||      ' c.x_status carr_status,x_city,x_state,x_special_mkt';
   sqlstmt := sqlstmt||' from table_x_carrier_group cg,';
   sqlstmt := sqlstmt||     ' table_x_carrier c,';
   sqlstmt := sqlstmt||     ' table_x_parent p,';
   sqlstmt := sqlstmt||     ' table_address a1,';
   sqlstmt := sqlstmt||     ' table_address a2';
   sqlstmt := sqlstmt||' where c.carrier2carrier_group = cg.objid';
   sqlstmt := sqlstmt||' and cg.x_carrier_group2x_parent = p.objid';
   sqlstmt := sqlstmt||' and cg.x_group2address = a1.objid';
   sqlstmt := sqlstmt||' and c.x_carrier2address = a2.objid';
   sqlstmt := sqlstmt||' and cg.x_carrier_group_id = '||ip_carr_group_id;
   if ip_carr_id is not null then
       sqlstmt := sqlstmt||' and c.x_carrier_id = '||ip_carr_id;
   end if;

   print_line(sqlstmt);

open op_carr_group_rec for sqlstmt;
end;


---------------------------------------------------------------
procedure cops_upd_carrier_group (ip_parent_id in varchar2 default null,
                            ip_carr_group_id in varchar2 default null,
                            ip_group_status in number default null,
                            ip_hq_add_objid in varchar2 default null,
                            ip_hq_add1 in varchar2 default null,
                            ip_hq_add2 in varchar2 default null,
                            ip_hq_city in varchar2 default null,
                            ip_hq_state in varchar2 default null,
                            ip_hq_zip in varchar2 default null,
                            ip_carr_objid in varchar2 default null,
                            ip_mkt_submkt_name in varchar2 default null,
                            ip_carr_id in varchar2 default null,
                            ip_carr_city in varchar2 default null,
                            ip_carr_state in varchar2 default null,
                            ip_carr_status in varchar2 default null,--0 or 1
                            ip_special_mkt in varchar2 default null,
                            ip_add_objid in varchar2 default null,
                            ip_add1 in varchar2 default null,
                            ip_add2 in varchar2 default null,
                            ip_city in varchar2 default null,
                            ip_state in varchar2 default null,
                            ip_zipcode in varchar2 default null) is
---------------------------------------------------------------
begin
  if ip_hq_add_objid is not null then
     update table_address
      set address= ip_hq_add1,
          s_address = upper(ip_hq_add1),
          address_2=ip_hq_add2,
          city=ip_hq_city,
          s_city = upper(ip_hq_city),
          state=ip_hq_state,
          s_state = upper(ip_hq_state),
          zipcode=ip_hq_zip,
          update_stamp=sysdate,
          address2state_prov=(select objid from table_state_prov
                              where s_name = upper(ip_hq_state)),
          address2country=(select state_prov2country
                           from table_state_prov where s_name = upper(ip_hq_state))
      where objid = ip_hq_add_objid;
  end if;
  if ( ip_carr_group_id is not null ) then
       update table_x_carrier_group
       set x_status = decode(ip_group_status,1,'ACTIVE',0,'INACTIVE'),
           x_carrier_group2x_parent = decode(ip_parent_id,null,x_carrier_group2x_parent,
                                (select objid from table_x_parent
                                 where x_parent_id = ip_parent_id))
       where x_carrier_group_id = ip_carr_group_id;
  end if;
  if ( ip_carr_objid is not null) then
     update table_x_carrier
       set x_carrier_id = ip_carr_id,
           x_status = decode(ip_carr_status,0,'INACTIVE',1,'ACTIVE'),
           x_city   = ip_carr_city,
           x_state  = ip_carr_state,
           x_special_mkt = ip_special_mkt
     where objid = ip_carr_objid;
  end if;
  if ( ip_add_objid is not null ) then
    update table_address
    set address = ip_add1,
        s_address = upper(ip_add1),
        address_2 = ip_add2,
        city     = ip_city,
        s_city   = upper(ip_city),
        state    = ip_state,
        s_state  = upper(ip_state),
        zipcode  = ip_zipcode,
        update_stamp=sysdate,
        address2state_prov=(select objid from table_state_prov
                              where s_name = upper(ip_state)),
        address2country=(select state_prov2country
                           from table_state_prov where s_name = upper(ip_state))
    where objid = ip_add_objid;
  end if;

end;
---------------------------------------------------------------
procedure cops_get_order_types(ip_carr_objid in number,
                          ip_order_type in varchar2,
                          ip_npa in varchar2,
                          ip_nxx in varchar2,
                          ip_bill_cycle in varchar2,
                          ip_dealer_code in varchar2,
                          ip_account_num in varchar2,
                          op_order_type_list out sys_refcursor )
---------------------------------------------------------------
is
sqlstmt varchar2(800);
begin
    sqlstmt := 'select x_order_type_objid, ';
    sqlstmt := sqlstmt||'x_transmit_method,';
    sqlstmt := sqlstmt||'x_fax_number,';
    sqlstmt := sqlstmt||'x_online_number,';
    sqlstmt := sqlstmt||'x_network_login,';
    sqlstmt := sqlstmt||'x_network_password,';
    sqlstmt := sqlstmt||'x_system_login,';
    sqlstmt := sqlstmt||'x_system_password,';
    sqlstmt := sqlstmt||'x_template,';
    sqlstmt := sqlstmt||'x_email,';
    sqlstmt := sqlstmt||'x_order_type,';
    sqlstmt := sqlstmt||'x_profile_name,';
    sqlstmt := sqlstmt||'x_NPA,';
    sqlstmt := sqlstmt||'x_NXX,';
    sqlstmt := sqlstmt||'x_bill_cycle,';
    sqlstmt := sqlstmt||'x_carrier_objid,';
    sqlstmt := sqlstmt||'x_account_num,';
    sqlstmt := sqlstmt||'x_dealer_code,';
    sqlstmt := sqlstmt||'x_market_code,';
    sqlstmt := sqlstmt||'x_mkt_submkt_name,';
    sqlstmt := sqlstmt||'x_trans_objid,';
    sqlstmt := sqlstmt||'x_carrier_id,';
    sqlstmt := sqlstmt||'x_description,';
    sqlstmt := sqlstmt||'x_transmit_template';
    sqlstmt := sqlstmt||' from table_x_order_type_view ';
    sqlstmt := sqlstmt||' where x_carrier_objid = '||ip_carr_objid ;

    if nvl(upper(ip_order_type),'ALL') != 'ALL'  then
         sqlstmt := sqlstmt ||' and x_order_type like '''||ip_order_type||'%''';
    end if;
    if ip_npa is not null then
         sqlstmt := sqlstmt ||' and x_npa like '''||ip_npa||'%''';
    end if;
    if ip_nxx is not null then
         sqlstmt := sqlstmt ||' and x_nxx like '''||ip_nxx||'%''';
    end if;
    if ip_bill_cycle is not null then
         sqlstmt := sqlstmt ||' and x_bill_cycle like '''||ip_bill_cycle||'%''';
    end if;
    if ip_dealer_code is not null then
         sqlstmt := sqlstmt ||' and x_dealer_code like '''||ip_dealer_code||'%''';
    end if;
    if ip_account_num is not null then
         sqlstmt := sqlstmt ||' and x_account_num like '''||ip_account_num||'%''';
    end if;

    print_line(sqlstmt);
    open op_order_type_list for sqlstmt;

end;
---------------------------------------------------------------
procedure cops_carr_group_search(ip_carr_name in varchar2,
                                 ip_carr_group_id in varchar2,
                                 op_carr_group_list out sys_refcursor) is
--------------------------------------------------------------
 sqlstmt varchar2(300);
begin
   sqlstmt := ' SELECT  objid, x_carrier_group_id, x_carrier_name, x_status, x_no_auto_port ';
   sqlstmt := sqlstmt||' FROM table_x_carrier_group ';
   sqlstmt := sqlstmt||' where 1=1 ';
   if ip_carr_name is not null then
       sqlstmt:= sqlstmt|| ' and x_carrier_name LIKE '''||ip_carr_name||'%''';
   end if;
   if ip_carr_group_id is not null then
      sqlstmt:= sqlstmt||' AND  x_carrier_group_id = '||ip_carr_group_id;
   end if;
   open op_carr_group_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_add_lines_useDOTM(ip_carr_objid in number,
                                 ip_npa in varchar2,
                                 ip_nxx in varchar2,
                                 ip_action in varchar2 default 'QUERY',
                                 op_npa_nxx_list out sys_refcursor) is
---------------------------------------------------------------
sqlstmt varchar2(300);
begin
  if ( ip_action = 'ADD' ) then
        insert into table_x_add_lines(objid,
                                      x_npa,
                                      x_nxx,
                                      x_add_lines2x_carrier)
                             values  (seq('X_ADD_LINES'),
                                      ip_npa,
                                      ip_nxx,
                                      ip_carr_objid);
  elsif ( ip_action = 'REMOVE') then
        delete table_x_add_lines
        where x_npa = ip_npa
        and   x_nxx = ip_nxx
        and   x_add_lines2x_carrier = ip_carr_objid;
  end if;
  sqlstmt := 'select  objid, x_npa, x_nxx ';
  sqlstmt := sqlstmt||' from table_x_add_lines ';
  sqlstmt := sqlstmt||' where x_npa = '||ip_npa ;
  sqlstmt := sqlstmt||' and x_nxx = '||ip_nxx;
  sqlstmt := sqlstmt||' and x_add_lines2x_carrier IN ('||ip_carr_objid||')';
  open op_npa_nxx_list for sqlstmt ;
end;
---------------------------------------------------------------
procedure cops_add_upd_trans_profile
    (ip_objid number,ip_transmit_method varchar2,ip_exception varchar2,
    ip_fax_number varchar2,ip_online_number varchar2,ip_network_login varchar2,
    ip_network_password varchar2,ip_system_login varchar2,ip_system_password varchar2,
    ip_template varchar2,ip_email varchar2,ip_profile_name varchar2,
    ip_default_queue varchar2,ip_carrier_phone varchar2,ip_exception_queue varchar2,
    ip_batch_quantity varchar2,ip_batch_delay_max varchar2,ip_transmit_template varchar2,
    ip_online_num2 varchar2,ip_fax_num2 varchar2,ip_description varchar2,
    ip_ici_system varchar2,ip_analog_deact varchar2,ip_analog_rework varchar2,
    ip_digital_act varchar2,ip_digital_deact varchar2,ip_digital_rework varchar2,
    ip_upgrade varchar2,ip_d_transmit_method varchar2,ip_d_fax_number varchar2,
    ip_d_online_number varchar2,ip_d_network_login varchar2,ip_d_network_password varchar2,
    ip_d_system_login varchar2,ip_d_system_password varchar2,ip_d_template varchar2,
    ip_d_email varchar2,ip_d_carrier_phone varchar2,ip_d_batch_quantity varchar2,
    ip_d_batch_delay_max varchar2,ip_d_trans_template varchar2,ip_d_online_num2 varchar2,
    ip_d_fax_num2 varchar2,ip_d_ici_system varchar2,ip_gsm_act varchar2,
    ip_gsm_deact varchar2,ip_gsm_rework varchar2,ip_gsm_ici_system varchar2,
    ip_gsm_transmit_method varchar2,ip_gsm_trans_template varchar2,ip_gsm_carrier_phone varchar2,
    ip_gsm_fax_number varchar2,ip_gsm_online_number varchar2,ip_gsm_fax_num2 varchar2,
    ip_gsm_online_num2 varchar2,ip_gsm_network_password varchar2,ip_gsm_batch_quantity varchar2,
    ip_gsm_network_login varchar2,ip_gsm_batch_delay_max varchar2,ip_gsm_email varchar2,
    ip_sui_analog varchar2,ip_sui_digital varchar2,ip_sui_gsm varchar2,
    ip_timeout_analog varchar2,ip_timeout_digital varchar2,ip_timeout_gsm varchar2,
    ip_debug_analog varchar2,ip_debug_digital varchar2,ip_debug_gsm varchar2,
    ip_int_port_in_rework varchar2,ip_trans_profile2wk_work_hr varchar2,
    ip_d_trans_profile2wk_work_hr varchar2)
is
---------------------------------------------------------------
begin
  if ( ip_objid is null ) then
      insert into table_x_trans_profile (
                objid,x_transmit_method,x_exception,
                x_fax_number,x_online_number,x_network_login,
                x_network_password,x_system_login,x_system_password,
                x_template,x_email,x_profile_name,
                x_default_queue,x_carrier_phone,x_exception_queue,
                x_batch_quantity,x_batch_delay_max,x_transmit_template,
                x_online_num2,x_fax_num2,x_description,
                x_ici_system,x_analog_deact,x_analog_rework,
                x_digital_act,x_digital_deact,x_digital_rework,
                x_upgrade,x_d_transmit_method,x_d_fax_number,
                x_d_online_number,x_d_network_login,x_d_network_password,
                x_d_system_login,x_d_system_password,x_d_template,
                x_d_email,x_d_carrier_phone,x_d_batch_quantity,
                x_d_batch_delay_max,x_d_trans_template,x_d_online_num2,
                x_d_fax_num2,x_d_ici_system,x_gsm_act,
                x_gsm_deact,x_gsm_rework,x_gsm_ici_system,
                x_gsm_transmit_method,x_gsm_trans_template,x_gsm_carrier_phone,
                x_gsm_fax_number,x_gsm_online_number,x_gsm_fax_num2,
                x_gsm_online_num2,x_gsm_network_password,x_gsm_batch_quantity,
                x_gsm_network_login,x_gsm_batch_delay_max,x_gsm_email,
                x_sui_analog,x_sui_digital,x_sui_gsm,
                x_timeout_analog,x_timeout_digital,x_timeout_gsm,
                x_debug_analog,x_debug_digital,x_debug_gsm,
                x_int_port_in_rework,x_trans_profile2wk_work_hr,d_trans_profile2wk_work_hr)
         values(seq('x_trans_profile'),ip_transmit_method ,ip_exception ,
                ip_fax_number ,ip_online_number ,ip_network_login ,
                ip_network_password ,ip_system_login ,ip_system_password ,
                ip_template ,ip_email ,ip_profile_name ,
                ip_default_queue ,ip_carrier_phone ,ip_exception_queue ,
                ip_batch_quantity ,ip_batch_delay_max ,ip_transmit_template ,
                ip_online_num2 ,ip_fax_num2 ,ip_description ,
                ip_ici_system ,ip_analog_deact ,ip_analog_rework ,
                ip_digital_act ,ip_digital_deact ,ip_digital_rework ,
                ip_upgrade ,ip_d_transmit_method ,ip_d_fax_number ,
                ip_d_online_number ,ip_d_network_login ,ip_d_network_password ,
                ip_d_system_login ,ip_d_system_password ,ip_d_template ,
                ip_d_email ,ip_d_carrier_phone ,ip_d_batch_quantity ,
                ip_d_batch_delay_max ,ip_d_trans_template ,ip_d_online_num2 ,
                ip_d_fax_num2 ,ip_d_ici_system ,ip_gsm_act ,
                ip_gsm_deact ,ip_gsm_rework ,ip_gsm_ici_system ,
                ip_gsm_transmit_method ,ip_gsm_trans_template ,ip_gsm_carrier_phone ,
                ip_gsm_fax_number ,ip_gsm_online_number ,ip_gsm_fax_num2 ,
                ip_gsm_online_num2 ,ip_gsm_network_password ,ip_gsm_batch_quantity ,
                ip_gsm_network_login ,ip_gsm_batch_delay_max ,ip_gsm_email ,
                ip_sui_analog ,ip_sui_digital ,ip_sui_gsm ,
                ip_timeout_analog ,ip_timeout_digital ,ip_timeout_gsm ,
                ip_debug_analog ,ip_debug_digital ,ip_debug_gsm ,
                ip_int_port_in_rework ,ip_trans_profile2wk_work_hr ,
                ip_d_trans_profile2wk_work_hr);
   else
      update table_x_trans_profile
          set x_transmit_method=ip_transmit_method,
              x_exception=ip_exception,
              x_fax_number=ip_fax_number,
              x_online_number=ip_online_number,
              x_network_login=ip_network_login,
              x_network_password=ip_network_password,
              x_system_login=ip_system_login,
              x_system_password=ip_system_password,
              x_template=ip_template,
              x_email=ip_email,
              x_profile_name=ip_profile_name,
              x_default_queue=ip_default_queue,
              x_carrier_phone=ip_carrier_phone,
              x_exception_queue=ip_exception_queue,
              x_batch_quantity=ip_batch_quantity,
              x_batch_delay_max=ip_batch_delay_max,
              x_transmit_template=ip_transmit_template,
              x_online_num2=ip_online_num2,
              x_fax_num2=ip_fax_num2,
              x_description=ip_description,
              x_ici_system=ip_ici_system,
              x_analog_deact=ip_analog_deact,
              x_analog_rework=ip_analog_rework,
              x_digital_act=ip_digital_act,
              x_digital_deact=ip_digital_deact,
              x_digital_rework=ip_digital_rework,
              x_upgrade=ip_upgrade,
              x_d_transmit_method=ip_d_transmit_method,
              x_d_fax_number=ip_d_fax_number,
              x_d_online_number=ip_d_online_number,
              x_d_network_login=ip_d_network_login,
              x_d_network_password=ip_d_network_password,
              x_d_system_login=ip_d_system_login,
              x_d_system_password=ip_d_system_password,
              x_d_template=ip_d_template,
              x_d_email=ip_d_email,
              x_d_carrier_phone=ip_d_carrier_phone,
              x_d_batch_quantity=ip_d_batch_quantity,
              x_d_batch_delay_max=ip_d_batch_delay_max,
              x_d_trans_template=ip_d_trans_template,
              x_d_online_num2=ip_d_online_num2,
              x_d_fax_num2=ip_d_fax_num2,
              x_d_ici_system=ip_d_ici_system,
              x_gsm_act=ip_gsm_act,
              x_gsm_deact=ip_gsm_deact,
              x_gsm_rework=ip_gsm_rework,
              x_gsm_ici_system=ip_gsm_ici_system,
              x_gsm_transmit_method=ip_gsm_transmit_method,
              x_gsm_trans_template=ip_gsm_trans_template,
              x_gsm_carrier_phone=ip_gsm_carrier_phone,
              x_gsm_fax_number=ip_gsm_fax_number,
              x_gsm_online_number=ip_gsm_online_number,
              x_gsm_fax_num2=ip_gsm_fax_num2,
              x_gsm_online_num2=ip_gsm_online_num2,
              x_gsm_network_password=ip_gsm_network_password,
              x_gsm_batch_quantity=ip_gsm_batch_quantity,
              x_gsm_network_login=ip_gsm_network_login,
              x_gsm_batch_delay_max=ip_gsm_batch_delay_max,
              x_gsm_email=ip_gsm_email,
              x_sui_analog=ip_sui_analog,
              x_sui_digital=ip_sui_digital,
              x_sui_gsm=ip_sui_gsm,
              x_timeout_analog=ip_timeout_analog,
              x_timeout_digital=ip_timeout_digital,
              x_timeout_gsm=ip_timeout_gsm,
              x_debug_analog=ip_debug_analog,
              x_debug_digital=ip_debug_digital,
              x_debug_gsm=ip_debug_gsm,
              x_int_port_in_rework=ip_int_port_in_rework,
              x_trans_profile2wk_work_hr=ip_trans_profile2wk_work_hr,
              d_trans_profile2wk_work_hr=ip_d_trans_profile2wk_work_hr
          where objid = ip_objid;
   end if;
end;
---------------------------------------------------------------
procedure cops_get_trans_profile(ip_profile_name in varchar2,
                                 ip_trans_method in varchar2,
                                 ip_trans_desc in varchar2,
                                 ip_prof_objid in varchar2 default null,
                                 ip_del_flag in varchar2 default 'A',
                                 op_profile_list out sys_refcursor) is
---------------------------------------------------------------
sqlstmt varchar2(2000);
begin

  sqlstmt := 'select  objid,x_transmit_method,x_exception,';
  sqlstmt := sqlstmt||' x_fax_number,x_online_number,x_network_login,';
  sqlstmt := sqlstmt||' x_network_password,x_system_login,x_system_password,';
  sqlstmt := sqlstmt||' x_template,x_email,x_profile_name,x_default_queue,';
  sqlstmt := sqlstmt||' x_carrier_phone,x_exception_queue,x_batch_quantity,';
  sqlstmt := sqlstmt||' x_batch_delay_max,x_transmit_template,x_online_num2,';
  sqlstmt := sqlstmt||' x_fax_num2,x_description,x_ici_system,';
  sqlstmt := sqlstmt||' x_analog_deact,x_analog_rework,x_digital_act,';
  sqlstmt := sqlstmt||' x_digital_deact,x_digital_rework,x_upgrade,';
  sqlstmt := sqlstmt||' x_d_transmit_method,x_d_fax_number,x_d_online_number,';
  sqlstmt := sqlstmt||' x_d_network_login,x_d_network_password,x_d_system_login,';
  sqlstmt := sqlstmt||' x_d_system_password,x_d_template,x_d_email,x_d_carrier_phone,';
  sqlstmt := sqlstmt||' x_d_batch_quantity,x_d_batch_delay_max,x_d_trans_template,';
  sqlstmt := sqlstmt||' x_d_online_num2,x_d_fax_num2,x_d_ici_system,';
  sqlstmt := sqlstmt||' x_gsm_act,x_gsm_deact,x_gsm_rework,x_gsm_ici_system,';
  sqlstmt := sqlstmt||' x_gsm_transmit_method,x_gsm_trans_template,x_gsm_carrier_phone,';
  sqlstmt := sqlstmt||' x_gsm_fax_number,x_gsm_online_number,x_gsm_fax_num2,';
  sqlstmt := sqlstmt||' x_gsm_online_num2,x_gsm_network_password,x_gsm_batch_quantity,';
  sqlstmt := sqlstmt||' x_gsm_network_login,x_gsm_batch_delay_max,x_gsm_email,';
  sqlstmt := sqlstmt||' x_sui_analog,x_sui_digital,x_sui_gsm,x_timeout_analog,';
  sqlstmt := sqlstmt||' x_timeout_digital,x_timeout_gsm,x_debug_analog,';
  sqlstmt := sqlstmt||' x_debug_digital,x_debug_gsm,x_int_port_in_rework';
  sqlstmt := sqlstmt||' from table_x_trans_profile ';
  sqlstmt := sqlstmt||' where x_profile_name LIKE '''||ip_profile_name||'%''';
  if upper(ip_trans_method) != 'ALL' then
     sqlstmt := sqlstmt||' and x_transmit_method LIKE '''||ip_trans_method||'%''';
  end if;
  if ip_trans_desc is not null then
     sqlstmt := sqlstmt||' and x_description LIKE '''||ip_trans_desc||'%''';
  end if;
  if  ip_del_flag = 'D' then
      delete table_x_trans_profile
      where objid = ip_prof_objid;

      update table_x_order_type
        set x_order_type2x_trans_profile = NULL
        where x_order_type2x_trans_profile = ip_prof_objid;

      update table_x_carrier_logins
        set x_login2trans_profile = NULL
        where x_login2trans_profile = ip_prof_objid;
  elsif ip_del_flag != 'D' and ip_prof_objid is not null then
      sqlstmt := sqlstmt||' and objid = '||ip_prof_objid;
  end if;

  sqlstmt := sqlstmt||' order by x_profile_name asc ';
 print_line(sqlstmt);
 open op_profile_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_get_tp_markets(ip_prof_objid in number,
                              ip_mkt_list out sys_refcursor) is
---------------------------------------------------------------
sqlstmt varchar2(300);
begin
   sqlstmt := 'select  carrier_objid, profile_objid, ';
   sqlstmt := sqlstmt||' profile_name, market_name, order_type';
   sqlstmt := sqlstmt||' from table_x_profile_view ';
   sqlstmt := sqlstmt||' where  profile_objid =  '||ip_prof_objid;

   open ip_mkt_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_get_default_messages(default_msg_list out sys_refcursor)
---------------------------------------------------------------
is
sqlstmt varchar2(300);
begin

  sqlstmt := 'select  objid, x_type, x_message, x_is_default, ';
  sqlstmt := sqlstmt||' x_ivr_script from table_x_act_message ';
  sqlstmt := sqlstmt||' WHERE   x_is_default = 1 ';
  open default_msg_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_add_act_msg(ip_carr_id in varchar2,
                           ip_method in varchar2,
                           ip_msg_text in varchar2 ) is
---------------------------------------------------------------
begin
   insert into table_x_act_message(objid,
                                   x_type,
                                   x_message,
                                   x_act_message2x_carrier)
                            values(seq('x_act_message'),
                                   ip_method,
                                   ip_msg_text,
                                   ip_carr_id);
end;
---------------------------------------------------------------
procedure cops_get_act_msg(ip_carr_id in varchar2,
                           op_msg_list out sys_refcursor,
                           ip_action in varchar2 default 'QRY',
                           ip_msg_objid in number default null,
                           ip_msg_text in varchar2 default null) is
---------------------------------------------------------------
sqlstmt varchar2(300);
begin
  if ( upper(ip_action) = 'DEL') then
     if ip_msg_objid is not null then
        delete table_x_act_message where objid = ip_msg_objid;
     end if;
  elsif ( upper(ip_action) = 'UPD') then
     if ip_msg_objid is not null then
        update table_x_act_message
        set x_message = ip_msg_text
        where objid = ip_msg_objid;
     end if;
  end if;

  sqlstmt := 'select  objid, x_type, x_message, x_is_default, ';
  sqlstmt := sqlstmt||' x_ivr_script from table_x_act_message ';
  sqlstmt := sqlstmt||' WHERE   x_act_message2x_carrier  = '||ip_carr_id;

  open op_msg_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_fcc_markets(ip_carr_id in varchar2,
                           op_fcc_mkt_list out sys_refcursor) is
---------------------------------------------------------------
sqlstmt varchar2(300);
begin
sqlstmt := 'select distinct marketid, mrkt_area  ';
sqlstmt := sqlstmt||' from sa.npanxx2carrierzones ';
sqlstmt := sqlstmt||' where carrier_id = '''||ip_carr_id||'''';
open op_fcc_mkt_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_bta_markets(ip_carr_id in varchar2,
                           op_bta_mkt_list out sys_refcursor) is
---------------------------------------------------------------
sqlstmt varchar2(300);
begin
sqlstmt := 'select distinct bta_mkt_number, bta_mkt_name ';
sqlstmt := sqlstmt||' from sa.npanxx2carrierzones ';
sqlstmt := sqlstmt||' where carrier_id = '''||ip_carr_id||'''';
open op_bta_mkt_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_carrier_accts( ip_carr_id in varchar2,
                              op_acct_list out sys_refcursor,
                              op_msg_out out varchar2,
                              ip_action in varchar2 default 'QUERY',
                              ip_acct_num in varchar2 default null,
                              ip_new_acct_num in varchar2 default null,
                              ip_active in varchar2 default null)
---------------------------------------------------------------
is
 sqlstmt varchar2(300);
begin
 if upper(ip_action) = 'ADD' then
   begin
      insert into table_x_account
           (objid,x_acct_num,
            x_status,account2x_carrier)
      values(seq('x_account'),ip_acct_num,
            decode(ip_active,0,'Inactive',1,'Active'), ip_carr_id);
   exception
       when dup_val_on_index then
       op_msg_out := 'The account number already exists for this carrier.';
       op_msg_out := op_msg_out||' The account was not added';
   end;
 elsif upper(ip_action) = 'REPLACE' then
   if ip_new_acct_num <> ip_acct_num then
      update table_x_account
      set x_status = 'Inactive'
      where x_acct_num = ip_acct_num;
      insert into table_x_account
              (objid,x_acct_num,
               x_status,account2x_carrier)
        values(seq('x_account'),ip_new_acct_num,
               decode(ip_active,0,'Inactive',1,'Active'), ip_carr_id);
   else
     op_msg_out := 'Can not replace the existing acct with the same account number.';
   end if;
 elsif upper(ip_action) = 'SAVE' then
   update table_x_account
   set x_status = decode(ip_active,0,'Inactive',1,'Active')
   where x_acct_num = ip_acct_num
   and x_status !=decode(ip_active,0,'Inactive',1,'Active');
   if sql%rowcount = 0 then
      op_msg_out := 'New status is the same as old status';
   end if;
 end if;
 sqlstmt := 'select  objid, x_acct_num, x_status';
 sqlstmt := sqlstmt||' from table_x_account ';
 sqlstmt := sqlstmt||' where account2x_carrier ='''||ip_carr_id||'''';
 open op_acct_list for sqlstmt;
end;
---------------------------------------------------------------
procedure cops_get_carrier_profile( ip_carr_id in varchar2,
                              ip_technology in varchar2 ,
                              op_rules out sys_refcursor,
                              op_msg_out out varchar2) is
---------------------------------------------------------------
sqlstmt varchar2(3000);
begin
  sqlstmt :=          'select x_carrier_name,x_carrier_id,x_mkt_submkt_name,';
  sqlstmt := sqlstmt||      ' x_act_technology,x_act_analog,x_react_technology,';
  sqlstmt := sqlstmt||      ' x_react_analog,x_ld_provider,x_ld_account,';
  sqlstmt := sqlstmt||      ' x_ld_pic_code,x_activeline_percent,x_automated,';
  sqlstmt := sqlstmt||      ' x_technology,x_cooling_period,x_used_line_expire_days,';
  sqlstmt := sqlstmt||      ' x_line_expire_days,x_gsm_grace_period,x_cancel_suspend_days,';
  sqlstmt := sqlstmt||      ' x_cancel_suspend,x_esn_change_flag,x_line_return_days,';
  sqlstmt := sqlstmt||      ' x_npa_nxx_flag,x_cooling_after_insert,x_reserve_on_suspend,';
  sqlstmt := sqlstmt||      ' x_reserve_period,x_deac_after_grace,x_prl_preloaded';
  sqlstmt := sqlstmt||' from table_x_carrier c,';
  sqlstmt := sqlstmt||     ' table_x_carrier_group cg';
  sqlstmt := sqlstmt||' full outer join table_x_carrier_rules cr ';
  sqlstmt := sqlstmt||' on (c.carrier2rules = cr.objid';
  sqlstmt := sqlstmt||   ' or c.carrier2rules_cdma = cr.objid';
  sqlstmt := sqlstmt||   ' or c.carrier2rules_tdma = cr.objid';
  sqlstmt := sqlstmt||   ' or c.carrier2rules_gsm = cr.objid)';
  sqlstmt := sqlstmt||' where 1=1 ';
  sqlstmt := sqlstmt||' and c.carrier2carrier_group = cg.objid';
  sqlstmt := sqlstmt||' and x_carrier_id = '||ip_carr_id;

  if ip_technology is not null then
     if ip_technology = 'ANALOG' then
         sqlstmt := sqlstmt||' and c.carrier2rules = cr.objid';
     else
         sqlstmt := sqlstmt||' and c.carrier2rules_'||ip_technology||' = cr.objid';
     end if;
  end if;
  open op_rules for sqlstmt;

end;
---------------------------------------------------------------
procedure cops_save_carrier_profile( ip_carr_id in varchar2,
                              ip_act_technology in varchar2,
                              ip_act_analog in number,
                              ip_react_technology in varchar2,
                              ip_react_analog in number,
                              ip_automated in number,
                              ip_ld_provider in varchar2 ,
                              ip_ld_account in varchar2 ,
                              ip_ld_pic_code in varchar2 ,
                              ip_activeline_percent in varchar2 ,
                              ip_technology in varchar2 ,
                              ip_cooling_period in varchar2 ,
                              ip_cooling_after_insert in varchar2,
                              ip_used_line_expire_days in number,
                              ip_line_expire_days in number,
                              ip_gsm_grace_period in number,
                              ip_npa_nxx_flag in number,
                              ip_reserve_on_suspend in number,
                              ip_reserve_period in number,
                              ip_deac_after_grace in number,
                              ip_prl_preload in number,
                              ip_esn_change_flag in number,
                              ip_line_return_days in number,
                              ip_cancel_suspend in number,
                              ip_cancel_suspend_days in number,
                              op_msg out varchar2
                              ) is
---------------------------------------------------------------
l_carr_rules_objid number;
l_upd_line varchar2(100);
l_upd_stmt varchar2(1000);
begin

   if (ip_ld_provider is null) then
         op_msg := 'Please select LD Provider(on Rates tab). This field ';
         op_msg := op_msg||'is mandatory. Save was not performed.';
         return;
   end if;
   begin
      select cr.objid
      into l_carr_rules_objid
      from table_x_carrier c,
           table_x_carrier_rules cr
      where c.x_carrier_id = ip_carr_id
      and cr.x_technology = ip_technology
      and (c.carrier2rules = cr.objid
      or c.carrier2rules_cdma = cr.objid
      or c.carrier2rules_tdma = cr.objid
      or c.carrier2rules_gsm = cr.objid);
   exception
      when others then
         l_carr_rules_objid := -1;
   end;
   if ( l_carr_rules_objid <> -1 ) then
     update table_x_carrier_rules
     set x_cooling_period = ip_cooling_period,
         x_esn_change_flag = ip_esn_change_flag,
         x_line_expire_days = ip_line_expire_days,
         x_line_return_days = ip_line_return_days,
         x_cooling_after_insert = ip_cooling_after_insert,
         x_npa_nxx_flag = ip_npa_nxx_flag,
         x_used_line_expire_days = ip_used_line_expire_days,
         x_gsm_grace_period = ip_gsm_grace_period,
         x_reserve_on_suspend = ip_reserve_on_suspend,
         x_reserve_period = ip_reserve_period,
         x_deac_after_grace = ip_deac_after_grace,
         x_cancel_suspend_days = ip_cancel_suspend_days,
         x_cancel_suspend = ip_cancel_suspend
     where objid = l_carr_rules_objid;
     l_upd_line := '';
   else
     insert into table_x_carrier_rules
                          (objid,
                           x_cooling_period ,
                           x_esn_change_flag ,
                           x_line_expire_days ,
                           x_line_return_days ,
                           x_cooling_after_insert ,
                           x_npa_nxx_flag ,
                           x_used_line_expire_days ,
                           x_gsm_grace_period ,
                           x_reserve_on_suspend ,
                           x_reserve_period ,
                           x_deac_after_grace ,
                           x_cancel_suspend_days ,
                           x_cancel_suspend )
                    values(seq('x_carrier_rules'),
                           ip_cooling_period ,
                           ip_esn_change_flag ,
                           ip_line_expire_days ,
                           ip_line_return_days ,
                           ip_cooling_after_insert ,
                           ip_npa_nxx_flag ,
                           ip_used_line_expire_days ,
                           ip_gsm_grace_period ,
                           ip_reserve_on_suspend ,
                           ip_reserve_period ,
                           ip_deac_after_grace ,
                           ip_cancel_suspend_days ,
                           ip_cancel_suspend)
     returning objid into l_carr_rules_objid;

     if ( ip_act_technology = 'ANALOG' ) then
         l_upd_line := ',carrier2rules = '||l_carr_rules_objid;
     else
         l_upd_line := ',carrier2rules_'||ip_act_technology ||' = '||l_carr_rules_objid;
     end if;
   end if;
 l_upd_stmt :=              'update table_x_carrier ';
 l_upd_stmt := l_upd_stmt ||' set x_automated = '||ip_automated;
 l_upd_stmt := l_upd_stmt ||' ,x_act_analog = '||ip_act_analog;
 l_upd_stmt := l_upd_stmt ||' ,x_act_technology = '''||ip_act_technology||'''';
 l_upd_stmt := l_upd_stmt ||' ,x_react_analog = '||ip_react_analog;
 l_upd_stmt := l_upd_stmt ||' ,x_react_technology = '''||ip_react_technology||'''';
 l_upd_stmt := l_upd_stmt ||' ,x_ld_provider = '''||ip_ld_provider||'''';
 l_upd_stmt := l_upd_stmt ||' ,x_ld_account = '''||ip_ld_account||'''';
 l_upd_stmt := l_upd_stmt ||' ,x_ld_pic_code = '''||ip_ld_pic_code||'''';
 l_upd_stmt := l_upd_stmt ||' ,x_activeline_percent = '''||ip_activeline_percent||'''';
 l_upd_stmt := l_upd_stmt ||' ,x_prl_preload = '''||ip_prl_preload||'''';
 l_upd_stmt := l_upd_stmt || l_upd_line;
 l_upd_stmt := l_upd_stmt ||' where x_carrier_id = '||ip_carr_id;

 execute immediate l_upd_stmt;
  op_msg := 'SUCCESS';
 print_line(l_upd_stmt);
end;
procedure cops_add_pref_tech(ip_technology in varchar2,
                             ip_frequency in varchar2,
                             ip_carr_id in varchar2,
                             ip_action in varchar2,
                             op_msg out varchar2 ) is
  pref_exists number;
  l_pref_tech_objid number;
  l_c_objid number;
  l_f_objid number;
begin
  -- GET CARR OBJID
  select objid
  into   l_c_objid
  from   table_x_carrier
  where  x_carrier_id = ip_carr_id;

  if ( ip_action = 'ADD') then

    -- CHECK EXISTS
    select count(*)
    into   pref_exists
    from   table_x_pref_tech
    where  x_technology = ip_technology
    and    x_frequency  = ip_frequency
    and    x_pref_tech2x_carrier = l_c_objid;

    if pref_exists = 0 then
      -- GET THE FREQ OBJID
      select objid
      into   l_f_objid
      from   table_x_frequency
      where  x_frequency = ip_frequency;

      l_pref_tech_objid := seq('x_pref_tech');

      -- CREATE THE PREF FOR THIS CARRIER
      insert into table_x_pref_tech
        (objid,
         x_technology,
         x_frequency,
         x_activation,
         x_reactivation,
         x_reac_exception_code,
         x_pref_tech2x_carrier)
      values
        (l_pref_tech_objid,
         ip_technology,
         ip_frequency,
         '1',
         '1',
         '',
         l_c_objid);

      -- MARRY THE CARRIER PREF TECH TO FREQ
      insert into mtm_x_frequency2_x_pref_tech1
        (x_frequency2x_pref_tech,
         x_pref_tech2x_frequency)
      values
        (l_f_objid,
         l_pref_tech_objid);

      op_msg := 'Remember to add the Master SID,Rate and Features corresponding to this new Technology';
    else
      op_msg := 'Carrier ID/Tech/Freq: '||ip_carr_id||'/'||ip_technology||'/'||ip_frequency||' already exists.';
    end if;

   elsif ( ip_action = 'DELETE') then

    delete from table_x_pref_tech
    where objid = (select objid from table_x_pref_tech
                   where x_technology = ip_technology
                   and x_frequency    = ip_frequency
                   and  x_pref_tech2x_carrier = l_c_objid)
    returning objid into l_pref_tech_objid;

    delete from mtm_x_frequency2_x_pref_tech1
    where x_pref_tech2x_frequency = l_pref_tech_objid;

    op_msg := 'Removed Carrier ID/Tech/Freq: '||ip_carr_id||'/'||ip_technology||'/'||ip_frequency||'.';

   else
      null;
   end if;
end cops_add_pref_tech;
procedure carr_personality_get(ip_carr_id in varchar2,
                               op_pers_cur out sys_refcursor,
                               op_local_sids out sys_refcursor,
                               op_master_sids out sys_refcursor,
                               op_lac_list out sys_refcursor,
                               op_soc_list out sys_refcursor) is
  sqlstmt varchar2(3000);
begin
  sqlstmt := 'select g.x_carrier_group_id,';
  sqlstmt := sqlstmt||' g.x_carrier_name,';
  sqlstmt := sqlstmt||' x_carrier_id,';
  sqlstmt := sqlstmt||' x_mkt_submkt_name, ';
  sqlstmt := sqlstmt||' a.address2country, -- come back ';
  sqlstmt := sqlstmt||' cp.x_restrict_callop,';
  sqlstmt := sqlstmt||' cp.x_restrict_ld,';
  sqlstmt := sqlstmt||' cp.x_restrict_intl,';
  sqlstmt := sqlstmt||' cp.x_restrict_roam,';
  sqlstmt := sqlstmt||' cp.x_restrict_inbound,';
  sqlstmt := sqlstmt||' cp.x_restrict_outbound,';
  sqlstmt := sqlstmt||' cp.x_freenum1,cp.x_freenum2,cp.x_freenum3,';
  sqlstmt := sqlstmt||' cp.x_partner,cp.x_favored,cp.x_neutral,';
  sqlstmt := sqlstmt||' cp.x_soc_id,cp.x_carr_personality2x_soc ';
  sqlstmt := sqlstmt||' from table_x_carr_personality cp, table_x_carrier c,';
  sqlstmt := sqlstmt||' table_x_carrier_group g, table_address a';
  sqlstmt := sqlstmt||' where c.carrier2personality=cp.objid ';
  sqlstmt := sqlstmt||' and c.carrier2carrier_group = g.objid';
  sqlstmt := sqlstmt||' and g.x_group2address = a.objid';
  sqlstmt := sqlstmt||' and x_carrier_id = '''||ip_carr_id||'''';
  open op_pers_cur for sqlstmt;

  sqlstmt := 'select x_local_area_code from table_x_lac l,table_x_carrier c ';
  sqlstmt := sqlstmt||' where l.lac2personality = c.carrier2personality ';
  sqlstmt := sqlstmt||' and x_carrier_id = '''||ip_carr_id||'''';

  sqlstmt :=          ' select x_sid,x_band,x_sid_type ';
  sqlstmt := sqlstmt||' from table_x_sids s,table_x_carrier c ';
  sqlstmt := sqlstmt||' where sids2personality = c.carrier2personality';
  sqlstmt := sqlstmt||' and x_sid_type <> ''LOCAL''';
  sqlstmt := sqlstmt||' and x_carrier_id = '''||ip_carr_id||'''';
  open op_master_sids for sqlstmt;

  sqlstmt :=          ' select x_sid ';
  sqlstmt := sqlstmt||' from table_x_sids s,table_x_carrier c ';
  sqlstmt := sqlstmt||' where sids2personality = c.carrier2personality';
  sqlstmt := sqlstmt||' and x_sid_type = ''LOCAL''';
  sqlstmt := sqlstmt||' and x_carrier_id = '''||ip_carr_id||'''';
  sqlstmt := sqlstmt||' order by x_index';
  open op_local_sids for sqlstmt;

  open op_soc_list for 'select x_sid from table_x_sids';

end;
procedure get_soc_sid_list(ip_soc_sid in varchar2,
                           op_soc_sid_list out sys_refcursor) is
  sqlstmt varchar2(200);
begin
  sqlstmt := 'select x_sid from table_x_soc s, table_x_soc_sid ss';
  sqlstmt := sqlstmt||' where s.x_sid  = '''||ip_soc_sid||'''';
  sqlstmt := sqlstmt||' and ss.x_soc_sid2x_soc = s.objid';
  open op_soc_sid_list for sqlstmt ;
end;
procedure carr_personality_save is
begin
/*
Call SP_CARRIER_PERSONALITY.SAVE(:A1,
               :A2,
               :A3,
               :A4,
               :A5,
               :A6,
               :A7,
               :A8,
               :A9,
               :A10,
               :A11,
               :A12,
               :A13,
               :A14,
               :A15,
               :A16,
               :A17,
               :A18,
               :A19,
               :A20,
               :A21,
               :A22,
               :A23,
               :A24,
               :A25);
--:A1 = 805868415
--:A2 = 1234567
--:A3 = 0
--:A4 = ' 00021 '   ... binding placeholder
--:A5 = ' 1 '   ... binding placeholder
--:A6 = ' 1 '   ... binding placeholder
--:A7 = -1
--:A8 = -1
--:A9 = -1
--:A10 = -1
--:A11 = -1
--:A12 = -1
--:A13 = ' FALSE '   ... binding placeholder
--:A14 = ' 12345~ '   ... binding placeholder
--:A15 = ' GSM~ '   ... binding placeholder
--:A16 = ' 98989~99898~89899~~~~ '   ... binding placeholder
--:A17 = ' 305~ '   ... binding placeholder
--:A18 = ' 22 '   ... binding placeholder
--:A19 = ' 33 '   ... binding placeholder
--:A20 = ' 44 '   ... binding placeholder
--:A21 = ' Roam '   ... binding placeholder
--:A22 = ' Roam '   ... binding placeholder
--:A23 = ' Roam '   ... binding placeholder
--:A24 = ' '   ... binding placeholder
--:A25 = ' '   ... binding placeholder
*/
null;
end;
procedure cops_get_carrier(ip_carr_identifier in varchar2,
                           op_carr_list out sys_refcursor) is
  sqlstmt varchar2(500);
begin
  sqlstmt := 'select objid,x_carrier_id,x_mkt_submkt_name';
  sqlstmt := sqlstmt||' from table_x_carrier';

  begin
         sqlstmt := sqlstmt||' where x_carrier_id = '||to_number(ip_carr_identifier);
  exception
     when others then
         sqlstmt := sqlstmt||' where x_mkt_submkt_name like '''||ip_carr_identifier||'%''';
  end;
  open op_carr_list for sqlstmt;
end;

procedure cops_get_carrier_scripts( ip_carr_objid in varchar2,
                                ip_sourcesystem in varchar2,
                                ip_script_type in varchar2,
                                ip_script_id in varchar2,
                                ip_script_description in varchar2,
                                ip_language in varchar2,
                                ip_get_what in varchar2,
                                op_carr_scr_list out sys_refcursor) is
   sqlstmt varchar2(1000);
begin

  if ip_carr_objid is not null or ip_get_what = 'CARRIERS' then
       if ( ip_get_what = 'CARRIERS' ) then
            sqlstmt := 'select x_carrier_id,x_mkt_submkt_name';
       else
            sqlstmt := 'select  T2.objid, T2.x_script_id, T2.x_script_text,';
            sqlstmt := sqlstmt||' T2.x_script_type, T2.x_sourcesystem, T2.x_ivr_id,';
            sqlstmt := sqlstmt||' T2.x_description, T2.x_language, T2.x_technology ';
       end if;
       sqlstmt := sqlstmt||' from table_x_scr T2, ';
       sqlstmt := sqlstmt||      'table_x_carrier T1, ';
       sqlstmt := sqlstmt||      'mtm_x_carrier27_x_scr0 ';
       sqlstmt := sqlstmt|| 'where T1.objid = mtm_x_carrier27_x_scr0.carrier2x_scr ';
       sqlstmt := sqlstmt|| ' AND T2.objid = mtm_x_carrier27_x_scr0.x_scr2x_carrier  ';

       if ( ip_get_what = 'CARRIERS' ) then
           sqlstmt := sqlstmt|| ' AND  T2.x_script_id = '||ip_script_id ;
       else
           sqlstmt := sqlstmt|| ' AND  T1.objid = '||ip_carr_objid ;
           sqlstmt := sqlstmt|| ' order by T2.x_language asc ';
       end if;
  else
       sqlstmt := 'select  T2.objid, T2.x_script_id, T2.x_script_text,';
       sqlstmt := sqlstmt||' T2.x_script_type, T2.x_sourcesystem, T2.x_ivr_id,';
       sqlstmt := sqlstmt||' T2.x_description, T2.x_language, T2.x_technology ';
       sqlstmt := sqlstmt||' from table_x_scr T2 ';
       sqlstmt := sqlstmt||' where 1 = 1 ';
       if ip_sourcesystem is not null then
          sqlstmt := sqlstmt||' and x_sourcesystem = '''||ip_sourcesystem||'''';
       end if;
       if ip_script_type is not null then
          sqlstmt := sqlstmt||' and x_script_type = '''||ip_script_type||'''';
       end if;
       if ip_script_description is not null then
          sqlstmt := sqlstmt||' and x_description = '''||ip_script_description||'''';
       end if;
       if ip_script_id is not null then
          sqlstmt := sqlstmt||' and x_script_type = '''||ip_script_id||'''';
       end if;
       if ip_language is not null then
          sqlstmt := sqlstmt||' and x_language = '''||ip_language||'''';
       end if;
       sqlstmt := sqlstmt||' order by x_script_id asc ';
   end if;
   print_line(sqlstmt);
   open op_carr_scr_list for sqlstmt;

end;
procedure cops_process_carr_scr(ip_carr_objid in varchar2,
                                ip_scr_objid in varchar2,
                                ip_script_text in varchar2,
                                ip_action in varchar2,
                                op_msg out varchar2)
is
 exist_obj  number;
begin
    if ( upper(ip_action) = 'ADD') then
       BEGIN
          SELECT carrier2x_scr
          INTO exist_obj
          FROM mtm_x_carrier27_x_scr0
          WHERE carrier2x_scr =  ip_scr_objid
          AND x_scr2x_carrier =  ip_carr_objid;
          op_msg := 'A script already exists for this carrier with this type';
          op_msg := op_msg||' and system. Please remove it before adding another.';
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               insert into mtm_x_carrier27_x_scr0
                       (carrier2x_scr, x_scr2x_carrier)
                 values(ip_scr_objid,ip_carr_objid);
           op_msg := 'SUCCESS';
       END;
    elsif(upper(ip_action) = 'REMOVE') then
       DELETE mtm_x_carrier27_x_scr0
       WHERE carrier2x_scr = ip_scr_objid
       AND x_scr2x_carrier = ip_carr_objid ;
       op_msg := 'SUCCESS';
    elsif(upper(ip_action) = 'MODIFY') then
       update table_x_scr
       set x_script_text = ip_script_text
       where objid = ip_scr_objid;
    end if;
end;
procedure cops_action_item_maintenace(ip_carr_name in varchar2,
                            ip_carr_mkt in varchar2,
                            ip_esn in varchar2,
                            ip_task_id in varchar2,
                            ip_trans_method in varchar2,
                            ip_status in varchar2,
                            ip_queue_name in varchar2,
                            ip_condition in varchar2,
                            ip_order_type in varchar2,
                            ip_task_cdate in varchar2,
                            ip_task_cd_operator in varchar2 default '>',
                            ip_sort_by  varchar2,
                            op_ai_list out sys_refcursor ) is
sqlstmt varchar2(3000);
begin

   sqlstmt := sqlstmt||' select  task_objid, task_id,';
   sqlstmt := sqlstmt||' TO_CHAR(task_create_date,';
   sqlstmt := sqlstmt||' ''MM/DD/YYYY HH24:MI:SS'') task_create_date,';
   sqlstmt := sqlstmt||' TO_CHAR(task_close_date,';
   sqlstmt := sqlstmt||' ''MM/DD/YYYY HH24:MI:SS'') task_close_date,';
   sqlstmt := sqlstmt||' contact_first, contact_last,';
   sqlstmt := sqlstmt||' priority, condition, curr_queue,';
   sqlstmt := sqlstmt||' owner, status, order_type,';
   sqlstmt := sqlstmt||' carrier_name, carrier_mkt, esn, topp_error_code,';
   sqlstmt := sqlstmt||' current_method, x_min, x_iccid,';
   sqlstmt := sqlstmt||' transmission_method, fax_path';
   sqlstmt := sqlstmt||' from table_x_monitor_view';
   sqlstmt := sqlstmt||' WHERE carrier_name LIKE '''||ip_carr_name||'%''';
   sqlstmt := sqlstmt||' AND  carrier_mkt LIKE   '''||ip_carr_mkt||'%''';
   sqlstmt := sqlstmt||' AND  esn LIKE  '''||ip_esn||'%''';
   sqlstmt := sqlstmt||' AND  S_task_id LIKE upper('''||ip_task_id||'%'')';
   if ip_trans_method is not null then
     sqlstmt := sqlstmt||' AND  transmission_method ='''||
                        ip_trans_method||'''';
   end if;
   sqlstmt := sqlstmt||' AND  S_status LIKE upper('''||ip_status||'%'')';
   sqlstmt := sqlstmt||' AND  S_curr_queue LIKE upper('''||ip_queue_name||'%'')';
   sqlstmt := sqlstmt||' AND  S_condition LIKE upper('''||ip_condition||'%'')';
   sqlstmt := sqlstmt||' AND  S_order_type LIKE upper('''||ip_order_type||'%'')';
   sqlstmt := sqlstmt||' AND  task_create_date '||nvl(ip_task_cd_operator,'>');
   sqlstmt := sqlstmt||'  TO_DATE( '''||ip_task_cdate||'''';
   sqlstmt := sqlstmt||', ''MM/DD/YYYY HH24:MI:SS'')';
   sqlstmt := sqlstmt||' order by '||ip_sort_by||' asc ';

  print_line(sqlstmt);
  open  op_ai_list for sqlstmt;

end ;

--------------------------------------------------------------------
procedure cops_get_queue_list
                       (op_queue_list out sys_refcursor ) is
--------------------------------------------------------------------
begin
 open op_queue_list for
 select  objid, title
 from table_queue
 order by S_title asc ;
end;

--------------------------------------------------------------------
procedure cops_get_soc_id_list
                       (op_soc_id_list out sys_refcursor ) is
--------------------------------------------------------------------
begin
  open op_soc_id_list for
   select  objid, x_soc_id
   from table_x_soc;
end;
--------------------------------------------------------------------
procedure cops_action_item_status_list
                       (op_ai_status_list out sys_refcursor ) is
--------------------------------------------------------------------
begin
   open op_ai_status_list for
    select  objid, title, rank, state, description, dev, addnl_info
    from table_gbst_elm
    where gbst_elm2gbst_lst IN (select  objid
    from table_gbst_lst
    WHERE title in('Open Action Item', 'Closed Action Item'));
end;
--------------------------------------------------------------------
procedure cops_get_list(which_list in varchar2,
                        op_list out sys_refcursor ) is
--------------------------------------------------------------------
 list_identifier varchar2(50);
begin
 if which_list = 'LD_PROVIDER' then
   list_identifier := 'x_ddl_LD_Provider';
 elsif which_list = 'TECHNOLOGY' then
   list_identifier := 'x_ddl_LD_Provider';
 elsif which_list = 'UNUSED_LINE_EXPIRATION' then
   list_identifier := 'x_ddl_Line_Expiration';
 elsif which_list = 'USED_LINE_EXPIRATION' then
   list_identifier := 'x_ddl_UsedLine_Expiration';
 elsif which_list = 'COOLING_PERIOD' then
   list_identifier := 'x_ddl_Cooling_Period';
 elsif which_list = 'TRANSMIT_METHOD' then
   list_identifier := 'x_ddlTransmitmethod';
 elsif which_list = 'ORDER_TYPE' then
   list_identifier := 'x_ddl_order_type';
 end if;
 open op_list for
 select  T2.objid, T2.title
 from table_hgbst_elm T2, table_hgbst_show T1, mtm_hgbst_elm0_hgbst_show1
 where T2.objid = mtm_hgbst_elm0_hgbst_show1.hgbst_elm2hgbst_show
 AND T1.objid = mtm_hgbst_elm0_hgbst_show1.hgbst_show2hgbst_elm
 AND  T1.objid = ( select hgbst_lst2hgbst_show
                    from table_hgbst_lst
                    where objid =(select  objid
                                  from table_hgbst_lst
                                  WHERE title =  list_identifier))
 order by rank;
end;
--------------------------------------------------------------------
procedure cops_process_action_item(aii_list in varchar2,
                                   ip_action in varchar2,
                                   ip_new_trans_method in varchar2,
                                   out_msg out varchar2 ) is
--------------------------------------------------------------------
sqlstmt varchar2(500);
sr sys_refcursor;
type rec_ty is record
   (task_create_date table_x_monitor_view.task_create_date%TYPE,
    task_id table_x_monitor_view.task_id%TYPE,
    task_objid table_x_monitor_view.task_objid%TYPE,
    fax_path table_x_monitor_view.fax_path%TYPE,
    order_type table_x_monitor_view.order_type%TYPE,
    transmission_method table_x_monitor_view.transmission_method%TYPE,
    out_queue   number);
rec rec_ty;
begin

  sqlstmt := 'select task_create_date,task_id,task_objid,';
  sqlstmt := sqlstmt ||' fax_path,order_type,transmission_method ';
  sqlstmt := sqlstmt ||' from table_x_monitor_view ';
  sqlstmt := sqlstmt ||' where task_id in ('||aii_list||')';

  open sr for sqlstmt;
  loop
     fetch sr into rec;
     exit when sr%notfound;
     if ip_action = 'RESEND' then
          update table_task
           set start_date= TO_DATE( rec.task_create_date, 'MM/DD/YYYY HH24:MI:SS'),
               comp_date= TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
               task_id=rec.task_id,
               s_task_id = rec.task_id,
               update_stamp= sysdate,
               x_original_method=rec.transmission_method,
               x_current_method =nvl(ip_new_trans_method,x_current_method),
               x_fax_file=rec.fax_path,
               x_queued_flag='1'
           where objid = rec.task_objid;
           IGATE.CALL_SP_DETERMINE_TRANS_METHOD(rec.task_objid,
                                                rec.order_type,
                                                nvl(ip_new_trans_method,rec.transmission_method),
                                                'CMT',
                                                 rec.out_queue);
      elsif ip_action = 'CLOSE' then
          IGATE.SP_CLOSE_ACTION_ITEM(rec.task_objid, '0', rec.out_queue);
      else
          out_msg := 'Unsupported action '||ip_action;
      end if;
  end loop;
  close sr;
end;
--------------------------------------------------------------------
procedure cops_dealer_search(ip_dealer_name in varchar2,
                             ip_dealer_id in varchar2,
                             op_dealer_list out sys_refcursor) is
--------------------------------------------------------------------
 sqlstmt varchar2(500);
begin
   sqlstmt := 'select objid,site_id dealer_id ,s_name dealer_name ';
   sqlstmt := sqlstmt||' from table_site ';
   sqlstmt := sqlstmt||' where type = ''3''';
   sqlstmt := sqlstmt||' and  site_type =  ''RSEL''';
   if ip_dealer_name is not null then
       sqlstmt := sqlstmt ||' and s_name like '||upper(ip_dealer_name)||'%';
   end if;
   if ip_dealer_id is not null then
       sqlstmt := sqlstmt ||' and site_id = '||ip_dealer_id;
   end if;
   open op_dealer_list for sqlstmt;
end;
--------------------------------------------------------------------
procedure cops_process_carrierdealer(ip_action in varchar2,
                                     ip_carr_id in varchar2,
                                     ip_dealer_id in varchar2,
                                     op_message out varchar2,
                                     op_dealer_list out sys_refcursor) is
--------------------------------------------------------------------
 sqlstmt varchar2(1000);
begin
   if (ip_action = 'ADD') then
     if ( ip_carr_id is null ) then
          op_message := 'You have to Select a Carrier before adding a Carrier/Dealer preference';
          return;
     elsif ( ip_dealer_id is null ) then
          op_message := 'You have to Select a Dealer before adding a Carrier/Dealer preference';
          return;
     end if;

     insert into table_x_carrierdealer (objid,x_carrier_id,x_dealer_id,x_cd2x_carrier,x_cd2site)
        values(seq('X_CARRIERDEALER'),ip_carr_id,ip_dealer_id,
            (select objid from table_x_carrier where x_carrier_id = ip_carr_id) ,
            (select objid from table_site where site_id = ip_dealer_id));

   elsif(ip_action = 'DELETE') then
     delete table_x_carrierdealer
        where x_carrier_id = ip_carr_id
        and x_dealer_id = ip_dealer_id;
   end if;

   sqlstmt := 'select objid,x_carrier_id,';
   sqlstmt := sqlstmt||' (select c.x_mkt_submkt_name from table_x_carrier c ';
   sqlstmt := sqlstmt||'  where x_carrier_id = a.x_carrier_id) carrier_name,';
   sqlstmt := sqlstmt||' x_dealer_id, (select s_name from table_site ';
   sqlstmt := sqlstmt||' where site_id = x_dealer_id) dealer_name ';
   sqlstmt := sqlstmt||' from table_x_carrierdealer a where 1=1';
   if ( ip_carr_id is not null ) then
        sqlstmt := sqlstmt||' and x_carrier_id = '||ip_carr_id;
   end if;
   if (ip_dealer_id is not null ) then
        sqlstmt := sqlstmt||' and x_dealer_id = '''||ip_dealer_id||'''';
   end if;
   print_line(sqlstmt);

end;

--------------------------------------------------------------------
procedure cops_process_carrierpref(ip_action in varchar2,
                                   ip_pref_carr_id in varchar2,
                                   ip_sec_carr_id in varchar2,
                                   op_message out varchar2,
                                   op_pref_carr_list out sys_refcursor) is
--------------------------------------------------------------------
 sqlstmt varchar2(1000);
begin
   if (ip_action = 'ADD') then
     if ( ip_pref_carr_id is null ) then
          op_message := 'You have to Select a Preferred Carrier before adding a carrier preference';
          return;
     elsif ( ip_sec_carr_id is null ) then
          op_message := 'You have to Select a Secondary Carrier before adding a carrier preference';
          return;
     end if;

     insert into table_x_carrierpreference (objid,x_ca_id_pref,x_ca_id_2,
                               x_preferred2x_carrier,x_secondary2x_carrier)
        values(seq('X_CARRIERPREFERENCE'),ip_pref_carr_id,ip_sec_carr_id,
            (select objid from table_x_carrier where x_carrier_id = ip_pref_carr_id) ,
            (select objid from table_x_carrier where x_carrier_id = ip_sec_carr_id));


   elsif(ip_action = 'DELETE') then
     delete table_x_carrierpreference
        where x_ca_id_pref = ip_pref_carr_id
        and x_ca_id_2 = ip_sec_carr_id;
   end if;

   sqlstmt := 'select objid,x_ca_id_pref,';
   sqlstmt := sqlstmt||' (select c.x_mkt_submkt_name from table_x_carrier c ';
   sqlstmt := sqlstmt||'  where x_carrier_id = a.x_ca_id_pref) pref_carrier_name,';
   sqlstmt := sqlstmt||' x_ca_id_2, (select c.x_mkt_submkt_name from table_x_carrier c  ';
   sqlstmt := sqlstmt||' where x_carrier_id = a.x_ca_id_2 ) sec_carrier_name ';
   sqlstmt := sqlstmt||' from table_x_carrierpreference a where 1=1';
   if ( ip_pref_carr_id is not null ) then
        sqlstmt := sqlstmt||' and x_ca_id_pref = '||ip_pref_carr_id;
   end if;
   if (ip_sec_carr_id is not null ) then
        sqlstmt := sqlstmt||' and x_ca_id_2 = '||ip_sec_carr_id;
   end if;
   print_line(sqlstmt);

end;
end fat_client_pkg;
/