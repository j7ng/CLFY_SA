CREATE OR REPLACE package body sa.apex_zip_to_tech
as
--------------------------------------------------------------------------------
  function ret_dblinks
  return varchar2
  as
    stmt varchar2(300);
  begin
    stmt := ' select ''CLFYSIT1'' d, ''CLFYSIT1'' r from dual union '|| -- DO NOT CHECK THIS IN
            ' select ''CLFYTOPP'' d, ''CLFYTOPP'' r from dual union '||
            ' select ''MAPSPRD'' d, ''MAPSPRD'' r from dual ';
    return stmt;
  end ret_dblinks;
--------------------------------------------------------------------------------
  function ret_log (ipv_db varchar2,
                    ipv_rev number default null,
                    ipv_type varchar2 default null)
  return varchar2
  as
    stmt varchar2(4000);
  begin
    if ipv_type = 'DETAIL' then
      stmt := ' select * '||
              ' from   sa.apex_zip2tech_error_log '||
              ' where  1=1 '||
              ' and    assoc_bkp = '''||ipv_rev||''''||
              ' and    db = '''||ipv_db||'''';
    else
      stmt := ' select decode(a.assoc_bkp,c.bkp,decode(b.name,null,null,''roll back''),null) roll_back, '||
              '        a.file_name, '||
              '        a.assoc_bkp rel_no, '||
              '        a.db, '||
              '        a.log_date, '||
              '        a.created_by, '||
              '        a.log_summary, '||
              '        decode(d.e_cnt,null,null,''view errors'') view_errors '||
              ' from   sa.apex_zip2tech_log a, '||
              '        wwv_flow_files b, '||
              '        (select max(assoc_bkp) bkp '||
              '         from   sa.apex_zip2tech_log '||
              '         where  1=1 '||
              '         and    db = '''||ipv_db||''') c, '||
              '        (select count(*) e_cnt, assoc_bkp d_assoc_bkp, trim(db) d_db '||
              '         from   apex_zip2tech_error_log '||
              '         where  1=1 '||
              '         and    db = '''||ipv_db||''''||
              '         group by assoc_bkp,db) d '||
              ' where  1=1 '||
              ' and    b.name(+) = a.file_name '||
              ' and    d.d_assoc_bkp(+) = a.assoc_bkp '||
              ' and    a.db = '''||ipv_db||''''||
              ' order by assoc_bkp desc,log_date desc ';
    end if;
    return stmt;
  end ret_log;
--------------------------------------------------------------------------------
  function ret_bptech (ipv_db varchar2,
                       ipv_techkey varchar2,
                       ipv_service varchar2)
  return varchar2
  as
    stmt varchar2(4000);
    v_db varchar2(30);
  begin
    if ipv_db != 'CLFYTOPP' then
      v_db := v_db||'@'||ipv_db;
    end if;

    stmt := ' select * '||
            ' from   mapinfo.eg_bptech'||v_db||
            ' where  1=1 ';

    if ipv_techkey is not null then
    stmt := stmt||' and    techkey = '''||ipv_techkey||'''';
    end if;

    if ipv_service is not null then
    stmt := stmt||' and    service = '''||ipv_service||'''';
    end if;

    return stmt;
  end ret_bptech;
--------------------------------------------------------------------------------
  procedure edit_bptech(ipv_db varchar2,
                        ipv_action varchar2,
                        ipv_techkey varchar2,
                        ipv_service varchar2,
                        ipv_bp_code varchar2)
  as
    stmt varchar2(300);
    v_db varchar2(30);
  begin
    if ipv_db != 'CLFYTOPP' then
      v_db := '@'||ipv_db;
    end if;

    if ipv_action = 'DEL' then
      stmt := ' delete mapinfo.eg_bptech'||v_db||
              ' where 1=1 '||
              ' and   techkey = :1'||
              ' and   service = :2';

    execute immediate stmt using ipv_techkey, ipv_service;

    else
      stmt := ' merge into mapinfo.eg_bptech'||v_db||' a '||
              ' using (select 1 from dual) '||
              '   on  (a.techkey = :1 '||
              '   and  a.service = :2'||
              '   ) '||
              ' when matched then '||
              '   update set a.bp_code = :3 '||
              ' when not matched then '||
              '   insert (techkey,service,bp_code) '||
              '   values (:4,:5,:6) ';

    execute immediate stmt using ipv_techkey, ipv_service,ipv_bp_code,ipv_techkey,ipv_service,ipv_bp_code;

    end if;
  end edit_bptech;
--------------------------------------------------------------------------------
  procedure z2t_bp_tech_view (v_db varchar2,
                              v_zip varchar2,
                              v_service varchar2,
                              v_lang varchar2,
                              p_recordset out sys_refcursor)
  as
    stmt clob;
    zip clob;
    v_link varchar2(30);
  begin

  if v_db != 'CLFYTOPP' then
    v_link := '@'||v_db;
  end if;

  zip := ''''||replace(v_zip,',',''',''')||'''';

  stmt := '       select   '||
          '                a.zip, '||
          '                a.state, '||
          '                a.county, '||
          '                a.pref1, '||
          '                a.pref2, '||
          '                a.service, '||
          '                a.language, '||
          '                a.action, '||
          '                a.market, '||
          '                a.zip2, '||
          '                a.aid, '||
          '                a.vid, '||
          '                a.vc, '||
          '                a.sahcid, '||
          '                a.com, '||
          '                a.locale, '||
          '                a.sitetype, '||
          '                a.gotophonelist, '||
          '                a.tech, '||
          '                a.techzip, '||
          '                a.techkey, '||
          '                b.bp_code  '||
          '         from   mapinfo.eg_zip2tech'||v_link||' a, '||
          '                mapinfo.eg_bptech'||v_link||' b '||
          '         where  1=1 '||
          '         and    a.techkey = b.techkey '||
          '         and    a.service = b.service '||
          '         and    a.zip in ('||zip||') '||
          '         and    a.service = nvl('''||v_service||''',a.service) '||
          '         and    a.language = nvl('''||v_lang||''',a.language)';

    open p_recordset for stmt;

   dbms_output.put_line(stmt);

  end z2t_bp_tech_view;
--------------------------------------------------------------------------------
  function z2t_bp_tech_view (v_db varchar2,
                             v_zip varchar2,
                             v_service varchar2,
                             v_lang varchar2)
  return z2t_tab_ty
  pipelined
  as
    rc sys_refcursor;
  begin
    z2t_bp_tech_view(v_db,
                     v_zip,
                     v_service,
                     v_lang,
                     rc);
    loop
      fetch rc into z2t_rslt;
      exit when rc%notfound;
      pipe row(z2t_rslt);
    end loop;

  end z2t_bp_tech_view;
--------------------------------------------------------------------------------
  procedure rslt_log(ip_rtype varchar2,
                     ipv_user varchar2,
                     ipv_rev_no number,
                     ipv_db varchar2,
                     ipv_summary varchar2,
                     ipv_file varchar2)
  as
  begin
    if ip_rtype = 'ROLLBACK' then
      delete wwv_flow_files
      where  name = ipv_file;
    end if;

    insert into sa.apex_zip2tech_log
     (assoc_bkp,created_by,db,log_date,log_summary,file_name)
    values
     (ipv_rev_no,ipv_user,ipv_db,sysdate,ipv_summary,ipv_file);

  end rslt_log;
--------------------------------------------------------------------------------
  procedure file_uploader (ip_file_name varchar2,
                           ip_user_name varchar2,
                           ip_rtype varchar2, -- DEPLOY OR ROLLBACK
                           ip_source varchar2,
                           op_result out varchar2)
  is
    --------------------------------------------------------------------------------
    -- GLOBAL VARIABLES
    --------------------------------------------------------------------------------
      gn_records_processed number;
      gb_tblob blob;
      gn_suc_cnt number := 0;
      gn_err_cnt number := 0;
      gn_start_proc number;
      gn_end_proc number;
      gn_elapsed_time number;
      gn_new_rev_no number := 0;

      type split_tbl_ty is table of varchar2(500);
      st split_tbl_ty := split_tbl_ty();
    --------------------------------------------------------------------------------
        procedure ins_err_log(ipv_user varchar2,
                              ipv_rev_no number,
                              ipv_db varchar2,
                              ipv_zip varchar2,
                              ipv_state varchar2,
                              ipv_county varchar2,
                              ipv_pref1 varchar2,
                              ipv_pref2 varchar2,
                              ipv_service varchar2,
                              ipv_language varchar2,
                              ipv_sitetype varchar2,
                              ipv_techkey varchar2,
                              ipv_summary varchar2)
        as
        begin

          insert into apex_zip2tech_error_log
            (assoc_bkp,db,user_name,log_date,zip,state,county,pref1,pref2,service,language,sitetype,techkey,err_summary)
          values
            (ipv_rev_no,ipv_db,ipv_user,sysdate,ipv_zip,ipv_state,ipv_county,ipv_pref1,ipv_pref2,ipv_service,ipv_language,ipv_sitetype,ipv_techkey,ipv_summary);

        end ins_err_log;
      --------------------------------------------------------------------------------
        procedure exe_del (pv_action varchar2,
                           pv_db varchar2,
                           pv_zip varchar2,
                           pv_service varchar2,
                           pv_techkey varchar2,
                           pv_language varchar2,
                           pv_state varchar2,
                           pv_county varchar2,
                           pv_pref_parent varchar2,
                           op_rslt out boolean)
        is
          v_stmt varchar2(4000) := '';
          cnt number;
          st_len number := nvl(length(pv_state),0);
          cty_len number := nvl(length(pv_county),0);
        begin
          if st_len>0 and cty_len>0 then
            --dbms_output.put_line('STATE AND COUNTY ARE NOT NULL - zip '||pv_zip||' - service '||pv_service);
            v_stmt := ' declare '||
                      ' a number; '||
                      ' begin '||
                      ' delete mapinfo.eg_zip2tech'||pv_db||
                      ' where zip = :1 '|| -- ipv_zip
                      ' and  service = :2 '|| -- ipv_service
                      ' and  techkey = :3 '|| -- ipv_techkey
                      ' and  language = :4 '|| -- ipv_language
                      ' and  state = :5 '|| --ipv_state
                      ' and  county = :6; '|| -- ipv_county
                      ' a := sql%rowcount; '||
                      ' :7 := a; '||
                      ' end ;';
            execute immediate v_stmt using in pv_zip,in pv_service,in pv_techkey,in pv_language,in pv_state,in pv_county, out cnt;
          elsif st_len>0 and cty_len=0 then
            dbms_output.put_line('STATE IS NOT NULL AND COUNTY IS NULL - zip '||pv_zip||' - service '||pv_service);
            v_stmt := ' declare '||
                      ' a number; '||
                      ' begin '||
                      ' delete mapinfo.eg_zip2tech'||pv_db||
                      ' where zip = :1 '|| -- ipv_zip
                      ' and  service = :2 '|| -- ipv_service
                      ' and  techkey = :3 '|| -- ipv_techkey
                      ' and  language = :4 '|| -- ipv_language
                      ' and  state = :5 '|| --ipv_state
                      ' and  county is null; '|| -- ipv_county
                      ' a := sql%rowcount; '||
                      ' :6 := a; '||
                      ' end ;';
            execute immediate v_stmt using in pv_zip,in pv_service,in pv_techkey,in pv_language,in pv_state, out cnt;
          elsif st_len=0 and cty_len=0 then
            dbms_output.put_line('STATE AND COUNTY ARE NULL - zip '||pv_zip||' - service '||pv_service);
            v_stmt := ' declare '||
                      ' a number; '||
                      ' begin '||
                      ' delete mapinfo.eg_zip2tech'||pv_db||
                      ' where zip = :1 '|| -- ipv_zip
                      ' and  service = :2 '|| -- ipv_service
                      ' and  techkey = :3 '|| -- ipv_techkey
                      ' and  language = :4 '|| -- ipv_language
                      ' and  state is null '|| --ipv_state
                      ' and  county is null; '|| -- ipv_county
                      ' a := sql%rowcount; '||
                      ' :5 := a; '||
                      ' end ;';
            execute immediate v_stmt using in pv_zip,in pv_service,in pv_techkey,in pv_language, out cnt;
          else
            dbms_output.put_line('ELSE CLAUSE - STATE IS NULL AND COUNTY IS NOT - zip '||pv_zip||' - service '||pv_service|| ' ST LEN('||st_len||') COUNTY LEN ('||cty_len||')');
            v_stmt := ' declare '||
                      ' a number; '||
                      ' begin '||
                      ' delete mapinfo.eg_zip2tech'||pv_db||
                      ' where zip = :1 '|| -- ipv_zip
                      ' and  service = :2 '|| -- ipv_service
                      ' and  techkey = :3 '|| -- ipv_techkey
                      ' and  language = :4 '|| -- ipv_language
                      ' and  state is null '|| --ipv_state
                      ' and  county = :5; '||
                      ' a := sql%rowcount; '||
                      ' :6 := a; '||
                      ' end ;';
            execute immediate v_stmt using pv_zip,pv_service,pv_techkey,pv_language,pv_county, out cnt;
          end if;

          --dbms_output.put_line('exe_del =>'||cnt);
          if pv_action = 'DEL' and cnt = 0 then
            op_rslt := false;
          else
            op_rslt := true;
          end if;
        end exe_del;
      --------------------------------------------------------------------------------
        procedure exe_ins(pv_db varchar2,
                          pv_zip varchar2,
                          pv_state varchar2,
                          pv_county varchar2,
                          pv_pref1 varchar2,
                          pv_pref2 varchar2,
                          pv_service varchar2,
                          pv_language varchar2,
                          pv_zip2 varchar2,
                          pv_locale varchar2,
                          pv_site_type varchar2,
                          pv_techzip varchar2,
                          pv_techkey varchar2,
                          pv_pref_parent varchar2,
                          op_rslt out boolean)
        is
            v varchar2(10):= chr(10);
            v_stmt varchar2(4000) := '';
            cnt number;
            v_action varchar2(50) :='action=';
            v_market varchar2(50) :='&market=';
            v_aid varchar2(20) :='&aid=';
            v_vid varchar2(20) :='&vid=';
            v_vc varchar2(20) :='&vc=';
            v_sahcid varchar2(20) :='&sahcid=';
            v_com varchar2(20) :='&com=';
            v_gotophonelist varchar2(50) := '&gotoPhonelist=';
            v_tech varchar2(20) := 'tech=';
        begin

          v_stmt := ' merge into mapinfo.eg_zip2tech'||pv_db||v||
                    ' using (select 1 from dual)'||v||
                    '   on (zip = :1 '||v|| -- ipv_zip
                    '   and state = :2 '||v|| -- ipv_state
                    '   and county = :3 '||v|| -- ipv_county
                    '   and service = :4 '||v|| -- ipv_service
                    '   and language = :5 '||v|| -- ipv_language
                    '   and techkey = :6 '||v|| -- ipv_techkey
                    ' ) '||v||
                    ' when not matched then '||v||
                    ' insert '||
                    ' (zip,state,county,service,language,techkey,pref1,pref2,action,market,zip2,aid,vid,vc,sahcid,com,locale,sitetype,gotophonelist,tech,techzip,x_pref_parent) '||v||
                    ' values '||v||
                    ' (:7,'||v|| -- ipv_zip
                    '  :8,'||v|| -- ipv_state
                    '  :9,'||v|| -- ipv_county
                    '  :10,'||v|| -- ipv_service
                    '  :11,'||v|| --ipv_language
                    '  :12,'||v|| -- ipv_techkey
                    '  :13,'||v|| -- ipv_pref1
                    '  :14,'||v|| --ipv_pref2
                    '  :15,'||v|| -- v_action
                    '  :16,'||v|| -- v_market
                    '  :17,'||v|| -- v_zip2
                    '  :18,'||v|| -- v_aid
                    '  :19,'||v|| --v_vid
                    '  :20,'||v|| --v_vc
                    '  :21,'||v|| --v_sahcid
                    '  :22,'||v|| --v_com
                    '  :23,'||v|| -- v_locale
                    '  :24,'||v||--v_site_type||''','||
                    '  :25,'||v|| --v_gotophonelist
                    '  :26,'||v||  -- v_tech
                    '  :27,'||v|| -- v_techzip
                    '  :28'||v|| -- pv_pref_parent
                    '  )'||v||
                    ' when matched then '||v||
                    ' update set '||v||
                    ' pref1 = :29, '||v|| -- ipv_pref1
                    ' pref2 = :30, '||v|| --ipv_pref2
                    ' sitetype = :31, '||v|| -- v_site_type
                    ' x_pref_parent = :32 '; -- pv_pref_parent

            --dbms_output.put_line(v_stmt);
            execute immediate v_stmt using pv_zip,pv_state,pv_county,pv_service,pv_language,pv_techkey,pv_zip,pv_state,pv_county,pv_service,pv_language,
                                           pv_techkey,pv_pref1,pv_pref2,v_action,v_market,pv_zip2,v_aid,v_vid,v_vc,v_sahcid,v_com,pv_locale,pv_site_type,
                                           v_gotophonelist,v_tech,pv_techzip,pv_pref_parent
                                           ,
                                           pv_pref1,pv_pref2,pv_site_type,pv_pref_parent
                                           ;
            op_rslt := true;
        exception
          when others then
            op_rslt := false;
        end exe_ins;
      --------------------------------------------------------------------------------
        function run_batch(ip_src            varchar2,  -- DBLINK
                           ipv_action        varchar2,  -- INS or DEL
                           ipv_user          varchar2,
                           ipv_rev_no        number,
                           ipv_zip           varchar2,
                           ipv_state         varchar2,
                           ipv_county        varchar2,
                           ipv_pref1         varchar2,
                           ipv_pref2         varchar2,
                           ipv_service       varchar2,
                           ipv_language      varchar2,
                           ipv_sitetype      varchar2,
                           ipv_techkey       varchar2,
                           ipv_pref_parent   varchar2)
                           return boolean
        as
          v_zip2    varchar2(20) := '&zip='||ipv_zip;
          v_techzip varchar2(30) :='&techzip='||ipv_zip;
          v_locale  varchar2(30) := '&locale=en';
          v_site_type varchar2(30) := '&siteType='||ipv_sitetype;
          v_rb_action varchar2(3);
          v_exists  number := 0;
          v_bptech_exists number := 0;
          v_stmt    varchar2(4000);
          v_cnty_test varchar2(90);
          err_str varchar2(1000);
          del_rslt boolean;
          ins_rslt boolean;
        begin
          if ip_src != 'CLFYTOPP' then
            v_stmt := '@'||ip_src;
          end if;

          if ipv_language = 'SP' then
            v_locale := '&locale=es_US';
          end if;

          -- DEFINE THE BKP/RB ACTION
          if ipv_action = 'INS' then
            v_rb_action := 'DEL';
          elsif ipv_action = 'DEL' then
            v_rb_action := 'INS';
          end if;

          -- PROCESS INTO TARGET TABLE
          if ipv_action = 'INS' then
            exe_ins(pv_db => v_stmt,
                    pv_zip => ipv_zip,
                    pv_state => ipv_state,
                    pv_county => ipv_county,
                    pv_pref1 => ipv_pref1,
                    pv_pref2 => ipv_pref2,
                    pv_service => ipv_service,
                    pv_language => ipv_language,
                    pv_zip2 => v_zip2,
                    pv_locale => v_locale,
                    pv_site_type => v_site_type,
                    pv_techzip => v_techzip,
                    pv_techkey => ipv_techkey,
                    pv_pref_parent => ipv_pref_parent,
                    op_rslt => ins_rslt);

            if not ins_rslt then
              return false;
            else
              return true;
            end if;

          elsif ipv_action = 'DEL' then
            exe_del (pv_action => ipv_action,
                     pv_db => v_stmt,
                     pv_zip => ipv_zip,
                     pv_service => ipv_service,
                     pv_techkey => ipv_techkey,
                     pv_language => ipv_language,
                     pv_state => ipv_state,
                     pv_county => ipv_county,
                     pv_pref_parent => ipv_pref_parent,
                     op_rslt => del_rslt);

            if not del_rslt then
              return false;
            else
              return true;
            end if;

          else
            null;
          end if;

        exception
          when others then
            err_str := substr(sqlerrm,1,1000);
            -- ERROR 2 - IS REAL ERROR
            ins_err_log(ipv_user,
                        ipv_rev_no,
                        ip_src,
                        ipv_zip,
                        ipv_state,
                        ipv_county,
                        ipv_pref1,
                        ipv_pref2,
                        ipv_service,
                        ipv_language,
                        ipv_sitetype,
                        ipv_techkey,
                        'ACTION: '||ipv_action||' - '||err_str);
            return false;
        end run_batch;
      --------------------------------------------------------------------------------
        procedure process_split(split_tbl in split_tbl_ty)
        is
          myrec varchar2(4000);
          v_data_array wwv_flow_global.vc_arr2;
          v_pref1 varchar2(20);
          v_pref2 varchar2(20);
          v_err varchar2(3000);
          job_data_rec_not_inserted exception;
          action_no_good exception;
          v_x_pref_parent varchar2(30);
        begin
          for i in 1..split_tbl.count
          loop
            myrec := split_tbl(i);
            myrec := replace(replace(myrec,chr(10),''),chr(13),'');
            if length(myrec) >0 then
              begin
                v_data_array := wwv_flow_utilities.string_to_table(myrec,',');
                if ip_rtype = 'ROLLBACK' then
                  if v_data_array(1) = 'INS' then
                    v_data_array(1) := 'DEL';
                  elsif v_data_array(1) = 'DEL' then
                    v_data_array(1) := 'INS';
                  end if;
                end if;
                --dbms_output.put_line(v_data_array(1));
                if v_data_array(1) not in('INS','DEL') then
                  v_err := 'Action Requested is no good ('||v_data_array(1)||') ';
                  dbms_output.put_line('action_no_good');
                  raise action_no_good;
                end if;

                if v_data_array.count >8 then
                  v_pref1 := v_data_array(9);
                end if;

                if v_data_array.count >9 then
                  v_pref2 := v_data_array(10);
                end if;

                if v_data_array.count >10 then
                  v_x_pref_parent := v_data_array(11);
                end if;

--                dbms_output.put_line(v_data_array(1)||', '||
--                                     v_data_array(2)||', '||
--                                     v_data_array(3)||', '||
--                                     v_data_array(4)||', '||
--                                     v_data_array(5)||', '||
--                                     v_data_array(6)||', '||
--                                     v_data_array(7)||', '||
--                                     v_data_array(8)||
--                                     ', '
--                                     );
            if (run_batch(ip_source,
                              v_data_array(1),  -- action
                              ip_user_name,
                              gn_new_rev_no,
                              v_data_array(2),  -- ipv_zip,
                              v_data_array(6),  -- ipv_state
                              v_data_array(7),  -- ipv_county
                              v_pref1, --v_data_array(9),  -- ipv_pref1
                              v_pref2, --v_data_array(10), -- ipv_pref2
                              v_data_array(3),  -- ipv_service
                              v_data_array(5),  -- ipv_language
                              v_data_array(8),  -- ipv_sitetype
                              v_data_array(4),  -- ipv_techkey
                              v_x_pref_parent-- v_x_pref_parent
                              )
                   ) then
                  gn_suc_cnt := gn_suc_cnt +1;
                else
                  raise job_data_rec_not_inserted;
                end if;
              exception
                when others then
                  gn_err_cnt := gn_err_cnt + 1;
                  v_err := v_err || sqlerrm;
                  v_err := 'NO ACTION COMPLETED - '||
                           v_err ||' - '||
                           ip_source||' - '||
                           v_data_array(1)||' - '||
                           v_data_array(2)||' - '||
                           v_data_array(6)||' - '||
                           v_data_array(7)||' - '||
                           v_pref1||' - '||
                           v_pref2||' - '||
                           v_data_array(3)||' - '||
                           v_data_array(5)||' - '||
                           v_data_array(8)||' - '||
                           v_data_array(4);

                  ins_err_log(ip_user_name,
                              gn_new_rev_no,
                              ip_source,
                              v_data_array(2),
                              v_data_array(6),
                              v_data_array(7),
                              v_pref1,
                              v_pref2,
                              v_data_array(3),
                              v_data_array(5),
                              v_data_array(8),
                              v_data_array(4),
                              v_err);
                v_err := null;

              end;
            end if;
          end loop;
        end process_split;
      --------------------------------------------------------------------------------
        procedure split( p_list in out varchar2 , p_del varchar2,split_tbl in out split_tbl_ty,p_it number,p_curr_it number, recs_processed in out number)
        is
            l_idx    pls_integer;
            l_list   varchar2(32767):= p_list;
            l_value  varchar2(32767);
            l_thresh number := 1000;

        begin
            loop
                l_idx :=instr(l_list,p_del);
                if l_idx > 0 then
                    split_tbl.extend;
                    --dbms_output.put_line(substr(l_list,1,l_idx-1));
                    split_tbl(split_tbl.count) := substr(l_list,1,l_idx-1);
                    l_list:= substr(l_list,l_idx+length(p_del));
                else
                    if ( p_del = ',') then
                      split_tbl.extend;
                      split_tbl(split_tbl.count) := l_list;
                    else
                      p_list := l_list;
                    end if;
                    goto goto_process_split; /* exit; */
                end if;
            end loop;
            <<goto_process_split>>
            -- PROCESS THE SPLIT TABLE AND EMPTY IT.
            if split_tbl.count > l_thresh or p_it = p_curr_it then
              process_split(split_tbl);
              recs_processed := nvl(recs_processed,0)+split_tbl.count;
              split_tbl.delete();
              commit;
            end if;
        end split;
      --------------------------------------------------------------------------------
        procedure split( p_blob blob , p_del varchar2,split_tbl in out split_tbl_ty, recs_processed in out number)
        is
            v_start    pls_integer := 1;
            v_blob    blob := p_blob;
            v_varchar    varchar2(32767);
            n_buffer pls_integer := 32767;
            v_remaining varchar2(32767);
            n_it number;
        begin
             dbms_output.put_line('Length of blob '||dbms_lob.getlength(v_blob));
             n_it := ceil(dbms_lob.getlength(v_blob) / n_buffer);
             for i in 1..n_it
             loop
                v_varchar := v_remaining||
                             utl_raw.cast_to_varchar2(
                                     dbms_lob.substr(v_blob,
                                                     n_buffer-nvl(length(v_remaining),0),
                                                     v_start+nvl(length(v_remaining),0)));
                split(v_varchar,p_del,split_tbl,n_it,i,recs_processed);
                v_remaining := v_varchar;
                v_start  := v_start  + n_buffer-nvl(length(v_remaining),0);
             end loop;
        end split;
      --------------------------------------------------------------------------------
  begin
    gn_start_proc := dbms_utility.get_time;

    select blob_content
    into  gb_tblob
    from   wwv_flow_files a
    where  a.name = ip_file_name;

    -- NEW REVISION NO.
    execute immediate ' select nvl(max(assoc_bkp),0)+1 from apex_zip2tech_log where db = :1' into gn_new_rev_no using ip_source;

    split(gb_tblob,chr(10),st,gn_records_processed);
    dbms_output.put_line('TOTAL RECS-'||gn_records_processed);

    gn_end_proc := DBMS_UTILITY.get_time;
    gn_elapsed_time := (gn_end_proc-gn_start_proc)/100;

    op_result := op_result||' Action:'||ip_rtype||'<br />'||
                            ' File:'||ip_file_name ||'<br />'||
                            'Totals: ('||gn_suc_cnt||') Loaded ('||gn_err_cnt||') Errors'||
                            ' / Elapsed: '||floor(gn_elapsed_time/60)||'m:'||
                            to_char(mod(gn_elapsed_time,60),'9990.09')||'s';

  end file_uploader;
--------------------------------------------------------------------------------
end apex_zip_to_tech;
/