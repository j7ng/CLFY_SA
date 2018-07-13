CREATE OR REPLACE package body sa.apex_case_create_batch as
----------------------------------------------------------------------------
-- SPLIT VARCHAR
----------------------------------------------------------------------------
procedure split( p_list in out varchar2 , p_del varchar2,split_tbl in out split_tbl_ty)
--------------------------------------------------------------------------------
is
    l_idx    pls_integer;
    l_list    varchar2(32767):= p_list;
    l_value    varchar2(32767);
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
            exit;
        end if;
    end loop;
end split;
----------------------------------------------------------------------------
-- SPLIT  BLOB
----------------------------------------------------------------------------
procedure split( p_blob blob , p_del varchar2,split_tbl in out split_tbl_ty)
--------------------------------------------------------------------------------
is
    v_start    pls_integer := 1;
    v_blob    blob := p_blob;
    v_varchar    varchar2(32767);
    n_buffer pls_integer := 32767;
    v_remaining varchar2(32767);
begin
     dbms_output.put_line('Length of blob '||dbms_lob.getlength(v_blob));
     for i in 1..ceil(dbms_lob.getlength(v_blob) / n_buffer)
     loop
        v_varchar := v_remaining||
                     utl_raw.cast_to_varchar2(
                             dbms_lob.substr(v_blob,
                                             n_buffer-nvl(length(v_remaining),0),
                                             v_start+nvl(length(v_remaining),0)));
        /*dbms_output.put('rem='||substr(v_varchar,1,30)||'<....>'
                 ||substr(v_varchar,length(v_varchar)-10 )||'|  L='
                 ||v_start||' L1='||length(v_varchar) ); */
        --dbms_output.put_line('TAB COUNT='||split_tbl.count);
        split(v_varchar,p_del,split_tbl);
        v_remaining := v_varchar;
        --dbms_output.put_line(' <'||v_remaining||'>');
        v_start  := v_start  + n_buffer-nvl(length(v_remaining),0);
     end loop;
end split;
----------------------------------------------------------------------------
-- FILE UPLOADER
----------------------------------------------------------------------------
  procedure file_uploader(ip_file_name varchar2,
                          ip_user_name varchar2,
                          op_result out varchar2) is
  ----------------------------------------------------------------------------
    st split_tbl_ty := split_tbl_ty();
    myrec varchar2(4000);
    v_case_array wwv_flow_global.vc_arr2;
    v_case_dtl_array wwv_flow_global.vc_arr2;
    tblob blob;
    start_data number;
    job_data_rec_not_inserted exception;
    start_proc number;
    end_proc number;
    elapsed_time number;
    suc_cnt number := 0;
    err_cnt number := 0;
    -- NEW VALS
    v_esn                  varchar2(30);
    v_source               varchar2(30);
    v_issue                varchar2(255);
    v_notes                varchar2(255);
    v_case_type            varchar2(30); --  := upper('WAREHOUSE');
    v_title                varchar2(100); -- := upper('2G Migration');
    v_status               varchar2(30); -- := 'Pending';
    v_priority             varchar2(30); -- := 'High'; --Options are Low,Medium,High, or Urgent
    v_point_contact        varchar2(20); -- :=  'TAS';
    v_x_part_inst2contact  sa.table_part_inst.x_part_inst2contact%type;
    v_u_objid              sa.table_user.objid%type;
    v_ticket_id            sa.table_case.id_number%type;
    v_case_objid           sa.table_case.objid%type;
    v_part_number          varchar2(30);
    v_err_code             varchar2(30);
    v_err_msg              varchar2(2000);
    v_case_detail          varchar2(5000);
    v_new_line             varchar2(30);
    v_part_req             varchar2(30);
    v_id_number            sa.table_case.id_number%type;

    v_phone                sa.table_case.alt_phone%type;
    v_fname                sa.table_case.alt_first_name%type;
    v_lname                sa.table_case.alt_last_name%type;
    v_email                sa.table_case.alt_e_mail%type;
    v_address              sa.table_case.alt_address%type;
    v_address2             sa.table_case.alt_city%type;
    v_city                 sa.table_case.alt_city%type;
    v_state                sa.table_case.alt_state%type;
    v_zipcode              sa.table_case.alt_zipcode%type;
    v_case_cnt             number;
  begin
    start_proc := DBMS_UTILITY.get_time;
    begin
      select blob_content
      into   tblob
      from   wwv_flow_files a
      where  a.name = ip_file_name;
    exception
        when no_data_found then
        dbms_output.put_line(chr(10)||chr(10)||'    "'||ip_file_name
                       || '" :File not found. Exiting ..'||chr(10));
        return;
    end;

    split(tblob,chr(10),st);
    dbms_output.put_line('TOTAL RECS-'||st.count);
    start_data := 1;

    for i in start_data..st.count
    loop
      myrec := st(i);
--      myrec := replace(st(i), '\,', escaped_comma);
--      myrec := replace(myrec, '||', double_pipe);

      myrec := replace(replace(myrec,chr(10),''),chr(13),'');

      if length(myrec) >0 then
        v_case_array := wwv_flow_utilities.string_to_table(myrec,',');
        if v_case_array(1) != 'ESN' then
          if v_case_array.count>20 then
            v_case_dtl_array :=  wwv_flow_utilities.string_to_table(v_case_array(21),':');
          end if;

          begin
            -- PRCESS HERE
            if sa.apex_case_create_batch.case_type_and_title_allowed(ip_case_type => v_case_array(2), ip_case_title => v_case_array(3)) > 0 then
              v_esn           := v_case_array(1);
              v_case_type     := upper(v_case_array(2));
              v_title         := upper(v_case_array(3));
              v_priority      := v_case_array(4);
              v_status        := v_case_array(5);
              v_point_contact := SUBSTR(v_case_array(6) ,1 ,20);
              v_source        := substr(v_case_array(7) ,1 ,30);
              v_issue         := substr(v_case_array(8) ,1 ,255);
              v_notes         := substr(v_case_array(9) ,1 ,255);
              v_new_line      := v_case_array(10);
              v_part_req      := v_case_array(11);
              v_fname         := v_case_array(12);
              v_lname         := v_case_array(13);
              v_address       := v_case_array(14);
              v_address2      := v_case_array(15);
              v_city          := v_case_array(16);
              v_state         := v_case_array(17);
              v_zipcode       := v_case_array(18);
              v_phone         := v_case_array(19);
              v_email         := v_case_array(20);

              v_case_detail := null;
              if v_case_array.count>20 and v_case_dtl_array.count>0 then
                for i in 1..v_case_dtl_array.count
                loop
                  v_case_detail := v_case_detail||v_case_dtl_array(i)||'||';
                end loop;
              end if;
              v_case_detail := substr(v_case_detail,1,length(v_case_detail)-2);

              -- Get the User Info
              begin
                select objid
                into  v_u_objid
                from table_user
                where s_login_name = upper(ip_user_name);
              exception
                when others then
                  null;
              end;

              -- Get the Contact Info
              begin
                select x_part_inst2contact
                into v_x_part_inst2contact
                from table_part_inst
                where part_serial_no = v_esn;
              exception
                when others then
                  null;
              end;

              begin
                select x_case_type,x_title
                into   v_case_type,v_title
                from   table_x_case_conf_hdr
                where  s_x_case_type = upper(v_case_type)
                AND    s_x_title = upper(v_title);
              exception
                when others then
                  null;
              end;

              dbms_output.put_line('v_esn           ============>('||v_esn||')');
              dbms_output.put_line('v_case_type     ============>('||v_case_type||')');
              dbms_output.put_line('v_title         ============>('||v_title||')');
              dbms_output.put_line('v_priority      ============>('||v_priority||')');
              dbms_output.put_line('v_status        ============>('||v_status||')');
              dbms_output.put_line('v_point_contact ============>('||v_point_contact||')');
              dbms_output.put_line('v_source        ============>('||v_source||')');
              dbms_output.put_line('v_issue         ============>('||v_issue||')');
              dbms_output.put_line('v_notes         ============>('||v_notes||')');
              dbms_output.put_line('v_new_line      ============>('||v_new_line||')');
              dbms_output.put_line('v_part_req      ============>('||v_part_req||')');
              dbms_output.put_line('v_fname         ============>('||v_fname||')');
              dbms_output.put_line('v_lname         ============>('||v_lname||')');
              dbms_output.put_line('v_address       ============>('||v_address||')');
              dbms_output.put_line('v_address2      ============>('||v_address2||')');
              dbms_output.put_line('v_city          ============>('||v_city||')');
              dbms_output.put_line('v_state         ============>('||v_state||')');
              dbms_output.put_line('v_zipcode       ============>('||v_zipcode||')');
              dbms_output.put_line('v_phone         ============>('||v_phone||')');
              dbms_output.put_line('v_email         ============>('||v_email||')');
              dbms_output.put_line('v_case_detail   ============>('||v_case_detail||')');
              dbms_output.put_line('v_u_objid       ============>('||v_u_objid||')');
              dbms_output.put_line('v_x_part_inst2contact ======>('||v_x_part_inst2contact||')');
              dbms_output.put_line(chr(10));

               v_id_number := adfcrm_case.create_case(p_case_type => v_case_type,
                                                      p_case_title => v_title,
                                                      p_case_status => v_status,
                                                      p_case_priority => v_priority,
                                                      p_case_source => v_source,
                                                      p_case_poc => v_point_contact,
                                                      p_case_issue => v_issue,
                                                      p_contact_objid => v_x_part_inst2contact,
                                                      p_first_name => v_fname,
                                                      p_last_name => v_lname,
                                                      p_user_objid => v_u_objid,
                                                      p_esn => v_esn,
                                                      p_case_part_req => v_part_req,
                                                      p_case_notes => v_notes,
                                                      p_case_details => v_case_detail);

                select count(*)
                into v_case_cnt
                from table_case
                where id_number = v_id_number;

                if v_case_cnt >0 then
                  suc_cnt := suc_cnt +1;
                else
                  raise job_data_rec_not_inserted;
                end if;

              end if;
            exception
              when others then
                dbms_output.put_line(i||'-'||myrec||'('||sqlerrm||')');
                err_cnt := err_cnt + 1;
            end;

        end if;
      end if;
     end loop;

     end_proc := DBMS_UTILITY.get_time;
     elapsed_time := (end_proc-start_proc)/100;
     op_result := op_result||' File:'||ip_file_name ||'<br />';
     op_result := op_result||'Totals: ('||suc_cnt||') Loaded ('||err_cnt||') Errors';
     op_result := op_result||' / Elapsed: '||floor(elapsed_time/60)||'m:';
     op_result := op_result||to_char(mod(elapsed_time,60),'9990.09')||'s';

  end file_uploader;

  function case_type_and_title_allowed(ip_case_type varchar2, ip_case_title varchar2)
  return number
  is
    num number := 0;
  begin
    select count(*)
    into num
    from (
          select * from table_x_case_conf_hdr where s_x_case_type = 'DIRECT SALES' and s_x_title = 'WEB ORDER PACKAGE SLIP' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'DIRECT SALES' and s_x_title = 'BRIGHT POINT ORDER INQUIRY' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'DIRECT SALES' and s_x_title = 'WEB AIRTIME PURCHASE' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'REFUNDS' and s_x_title = 'REFUND REQUEST' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'REFUNDS' and s_x_title = 'TAX EXEMPT REFUND' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'REFUNDS' and s_x_title = 'RINGTONE REFUND' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'REFUNDS' and s_x_title = 'LOYALTY PROGRAM REFUND' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'VAS' and s_x_title = 'LOYALTY PROGRAM' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'VAS' and s_x_title = 'HANDSET PROTECTION' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'VAS' and s_x_title = 'BYOP HANDSET PROTECTION PROGRAM' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'VAS' and s_x_title = 'UNABLE TO ROAM IN MEXICO' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'REFUNDS' and s_x_title = 'EBAY REFUNDS' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'REFUNDS' and s_x_title = 'MANUAL REFUND REQUEST' union
          select * from table_x_case_conf_hdr where s_x_case_type = 'REFUNDS' and s_x_title = 'RELEASE OF FUNDS'
        )
    where s_x_case_type = upper(ip_case_type)
    and s_x_title = upper(ip_case_title);

    return num;
  exception
    when others then
      return num;
  end;
end apex_case_create_batch;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/apex_case_create_batch_pkb.sql 	CR40646: 1.1
/