CREATE OR REPLACE package body sa.apex_crm_batch as
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
--------------------------------------------------------------------------------
-- INSERT BATCH FUNC
--------------------------------------------------------------------------------
  function ins_batch(ip_rtype varchar2,
                     ip_user_name varchar2,
                     ip_case_id varchar2,
                     ip_esn varchar2,
                     ip_tracking_no varchar2,
                     ip_status varchar2,
                     ip_new_model varchar2,
                     ip_ff_center varchar2,
                     ip_courier varchar2,
                     ip_shipping_method varchar2,
                     ip_entry_date varchar2,  -- NEW
                     ip_msid varchar2,        -- NEW
                     ip_min varchar2,         -- NEW
                     ip_carrier_id varchar2,  -- NEW
                     ip_src varchar2)         -- NEW
                     return boolean as
  begin
    if ip_src = 'CRM' then
      -- CRM TAB
      insert into sa.x_crm_batch_file_temp
        (rec_type,
         app_user,
         case_id,
         esn,
         tracking_no,
         status,
         new_model,
         ff_center,
         courier,
         shipping_method)
      values
        (ip_rtype,
         ip_user_name,
         ip_case_id,
         ip_esn,
         ip_tracking_no,
         ip_status,
         ip_new_model,
         ip_ff_center,
         ip_courier,
         ip_shipping_method);
    else
      -- LUTS TAB
      -- select * from x_luts_batch_file_temp;
      insert into sa.x_luts_batch_file_temp
        (rec_type,
         app_user,
         entry_date,
         msid,
         min,
         esn,
         carrier_id,
         status)
      values
        (ip_rtype,
         ip_user_name,
         ip_entry_date, -- NEW
         ip_msid, -- NEW
         ip_min, -- NEW
         ip_esn,
         ip_carrier_id, -- NEW
         ip_status);
    end if;
    return true;
  exception
    when others then
      return false;
  end ins_batch;
----------------------------------------------------------------------------
-- FILE UPLOADER
----------------------------------------------------------------------------
  procedure file_uploader(ip_file_name varchar2,
                          ip_user_name varchar2,
                          ip_rtype varchar2,
                          ip_source varchar2,
                          op_result out varchar2) is
  ----------------------------------------------------------------------------
    st split_tbl_ty := split_tbl_ty();
    myrec varchar2(4000);
    v_data_array wwv_flow_global.vc_arr2;
    tblob blob;
    start_data number;
    job_data_rec_not_inserted exception;
    start_proc number;
    end_proc number;
    elapsed_time number;
    suc_cnt number := 0;
    err_cnt number := 0;
    -- NEW VALS
    v_case_id     sa.x_crm_batch_file_temp.case_id%type;
    v_esn         sa.x_crm_batch_file_temp.esn%type;
    v_tracking_no sa.x_crm_batch_file_temp.tracking_no%type;
    v_new_model   sa.x_crm_batch_file_temp.new_model%type;
    v_ff_center   sa.x_crm_batch_file_temp.ff_center%type;
    v_courier     sa.x_crm_batch_file_temp.courier%type;
    v_ship_meth   sa.x_crm_batch_file_temp.shipping_method%type;
    -- v_src         varchar2(10) := 'CRM';
    v_entry_date  sa.x_luts_batch_file_temp.entry_date%type;
    v_msid        sa.x_luts_batch_file_temp.msid%type;
    v_min         sa.x_luts_batch_file_temp.min%type;
    v_carrier_id  sa.x_luts_batch_file_temp.carrier_id%type;

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
        v_data_array := wwv_flow_utilities.string_to_table(myrec,',');

        if ip_rtype = 'PART_REQUEST_UPDATE' then
          v_case_id     := v_data_array(1);
          v_new_model   := v_data_array(2);
          v_ff_center   := v_data_array(3);
          v_courier     := v_data_array(4);
          v_ship_meth   := v_data_array(5);
        elsif ip_rtype = 'REFURBISH' then
          v_esn         := v_data_array(1);
        elsif ip_rtype = 'REOPEN' then
          v_case_id     := v_data_array(1);
        elsif ip_rtype = 'RECEIVED' then
          v_case_id     := v_data_array(1);
          v_esn         := v_data_array(2);
        elsif ip_rtype = 'SHIP' then
          v_case_id     := v_data_array(1);
          v_esn         := v_data_array(2);
          v_tracking_no := v_data_array(3);
        elsif ip_rtype = 'ESN_STATUS_UPDATE' then
          v_esn         := v_data_array(1);
        elsif ip_source = 'LUTS' and ip_rtype = 'INSERT' then
          v_min         := v_data_array(1);
          v_carrier_id  := v_data_array(2);
          v_msid        := v_data_array(3);
        elsif ip_source = 'LUTS' and ip_rtype = 'DELETE' then
          v_min         := v_data_array(1);
        elsif ip_source = 'LUTS' and ip_rtype = 'TNUMBER' then
          null;
        end if;

        begin
          if (ins_batch(ip_rtype,
                        ip_user_name,
                        v_case_id,
                        v_esn,
                        v_tracking_no,
                        'PENDING', --ip_status,
                        v_new_model,
                        v_ff_center,
                        v_courier,
                        v_ship_meth,
                        v_entry_date,   --ip_entry_date varchar2,  -- NEW
                        v_msid,         --ip_msid varchar2,        -- NEW
                        v_min,          --ip_min varchar2,         -- NEW
                        v_carrier_id,   --ip_carrier_id varchar2,  -- NEW
                        ip_source       --ip_src default 'CRM')    -- NEW
                        )) then
            suc_cnt := suc_cnt +1;
          else
            raise job_data_rec_not_inserted;
          end if;
        exception
          when others then
            dbms_output.put_line(i||'-'||myrec||'('||sqlerrm||')');
            err_cnt := err_cnt + 1;
        end;
      end if;
     end loop;

     end_proc := DBMS_UTILITY.get_time;
     elapsed_time := (end_proc-start_proc)/100;
     op_result := op_result||' File:'||ip_file_name ||'<br />';
     op_result := op_result||'Totals: ('||suc_cnt||') Loaded ('||err_cnt||') Errors';
     op_result := op_result||' / Elapsed: '||floor(elapsed_time/60)||'m:';
     op_result := op_result||to_char(mod(elapsed_time,60),'9990.09')||'s';

  end file_uploader;
end apex_crm_batch;
/