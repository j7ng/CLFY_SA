CREATE OR REPLACE package body sa.apex_hotline_request_pkg
as
--------------------------------------------------------------------------------
  procedure split( p_list in out varchar2 , p_del varchar2,split_tbl in out split_tbl_ty)
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
--------------------------------------------------------------------------------
  procedure split( p_blob blob , p_del varchar2,split_tbl in out split_tbl_ty)
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
          split(v_varchar,p_del,split_tbl);
          v_remaining := v_varchar;
          v_start  := v_start  + n_buffer-nvl(length(v_remaining),0);
       end loop;
  end split;
--------------------------------------------------------------------------------
  procedure file_uploader(ip_file_name varchar2,
                          ip_order_type varchar2,
                          ip_short_code varchar2,
                          ip_sms_msg varchar2,
                          ip_user_name varchar2,
                          op_result out varchar2) is
    st split_tbl_ty := split_tbl_ty();
    myrec varchar2(4000);
    v_data_array wwv_flow_global.vc_arr2;
    tblob blob;
    start_data number;
    rec_not_inserted exception;
    hot_line_cap_maxed exception;
    start_proc number;
    end_proc number;
    elapsed_time number;
    suc_cnt number := 0;
    err_cnt number := 0;
    v_err varchar2(3000);
    v_out_err_num number;
    v_out_err_msg varchar2(3000);
    v_esn_rqst_cnt number := 0;
    v_sms_rqst_cnt number := 0;
    v_esn_rqst_fail_cnt number := 0;
    v_sms_rqst_fail_cnt number := 0;
    v_sms_msg varchar2(200);
    v_upload_cap number := 0;
  begin
    start_proc := DBMS_UTILITY.get_time;
    begin
      select blob_content
      into   tblob
      from   wwv_flow_files a
      where  a.name = ip_file_name;
    exception
        when no_data_found then
        dbms_output.put_line(chr(10)||chr(10)||'	"'||ip_file_name
                       || '" :File not found. Exiting ..'||chr(10));
        return;
    end;
    split(tblob,chr(10),st);
    dbms_output.put_line('TOTAL RECS-'||st.count);

    begin
      select to_number(x_param_value)
      into v_upload_cap
      from table_x_parameters
      where x_param_name = 'APEX_HOTLINE_UPLOAD_CAP';
    exception
      when others then
        dbms_output.put_line('MISSING CAP FROM DB');
        v_upload_cap := 5000;
    end;

    if st.count > v_upload_cap then
      raise hot_line_cap_maxed;
    end if;


    start_data := 1;

    -- INSERT BATCH
    for i in start_data..st.count
    loop
      myrec := st(i);
      myrec := replace(replace(myrec,chr(10),''),chr(13),'');

      if length(myrec) >0 then
        v_data_array := wwv_flow_utilities.string_to_table(myrec,',');
        begin

          if ip_order_type in ('SAFELINK_REDIRECT','MARKETTD_REDIRECT','FRAUD_REDIRECT','REMOVE_FRAUD') then
            sa.hotline_request_pkg.create_hotline_esn_request (in_esn      => v_data_array(1),
                                                               in_rqsttype => ip_order_type, --v_data_array(2),
                                                               in_user     => ip_user_name,
                                                               out_err_num => v_out_err_num,
                                                               out_err_msg => v_out_err_msg);
          end if;

          if ip_order_type in ('SEND_MESSAGE') then
            if ip_sms_msg is not null then
              v_sms_msg := ip_sms_msg;
            elsif v_data_array.count = 2 then
              v_sms_msg := v_data_array(2);
            end if;

            sa.hotline_request_pkg.create_hotline_sms (in_min        => v_data_array(1),
                                                       in_rqsttype   => ip_order_type,
                                                       in_short_code => ip_short_code,
                                                       in_sms_msg    => v_sms_msg,
                                                       in_user       => ip_user_name,
                                                       out_err_num   => v_out_err_num,
                                                       out_err_msg   => v_out_err_msg);

          end if;

          if v_out_err_num != 0 then
            raise rec_not_inserted;
          end if;

          suc_cnt := suc_cnt+1;

          if ip_order_type in ('SAFELINK_REDIRECT','MARKETTD_REDIRECT','FRAUD_REDIRECT','REMOVE_FRAUD') then
            v_esn_rqst_cnt := v_esn_rqst_cnt+1;
          end if;

          if ip_order_type in ('SEND_MESSAGE') then
            v_sms_rqst_cnt := v_sms_rqst_cnt +1;
          end if;

        exception
          when others then
            err_cnt := err_cnt + 1;
            v_err := v_err || sqlerrm;
            v_err := null;

            if ip_order_type in ('SAFELINK_REDIRECT','MARKETTD_REDIRECT','FRAUD_REDIRECT', 'REMOVE_FRAUD') then
              v_esn_rqst_fail_cnt := v_esn_rqst_fail_cnt+1;
            end if;

            if ip_order_type in ('SEND_MESSAGE') then
              v_sms_rqst_fail_cnt := v_sms_rqst_fail_cnt+1;
            end if;

        end;
      end if;
     end loop;

     end_proc := DBMS_UTILITY.get_time;
     elapsed_time := (end_proc-start_proc)/100;

     op_result := op_result||' File:'||ip_file_name ||'<br />'||
                             'Totals: ('||suc_cnt||') Success / ('||err_cnt||') Failed'||'<br />';
     if ip_order_type in ('SAFELINK_REDIRECT','MARKETTD_REDIRECT','FRAUD_REDIRECT', 'REMOVE_FRAUD') then
       op_result := op_result||' Total Requested ('||v_esn_rqst_cnt||')'||'<br />'||
                               ' Total Failed ('||v_esn_rqst_fail_cnt||')'||'<br />';
     end if;
     if ip_order_type in ('SEND_MESSAGE') then
       op_result := op_result||' Total Requested ('||v_sms_rqst_cnt||')'||'<br />'||
                               ' Total Failed ('||v_sms_rqst_fail_cnt||')'||'<br />';
     end if;
     op_result := op_result||'Total Time: '||floor(elapsed_time/60)||'m:'||to_char(mod(elapsed_time,60),'9990.09')||'s'||'<br />';

  exception
    when hot_line_cap_maxed then
      op_result := 'You have exceeded the allowed records to process ('||v_upload_cap||'). Please reduce the size of your file and try again.';
    when others then
      op_result := sqlerrm;
  end file_uploader;
--------------------------------------------------------------------------------
-- CR46165 -- Apex Tool Hotline Removal Functionality
-- THE CHANGES BELOW ARE AN EFFORT TO FIX AN ISSUE THAT HAPPENS WITH FILE_UPLOADER (PROCEDURE ABOVE)
-- ISSUE IS THAT THE PAGE WOULD TAKE TO LONG TO PROCESS THE HOTLINE WHILE PROCESSING THE .CSV
-- AND THE PAGE WOULD TIME OUT. THE IDEA BEHIND THIS IS TO LOAD THE DATA INTO A JOB TABLE
-- USING NEW PROCS (CREATE_REQ) + (CREATE_REQ_DATA) AND THAT A JOB THAT PROD DBA WOULD CREATE
-- WILL RUN NEW PROCS (PROCESS_HOTLINE_REQ) + (PROCESS_SMS_REQ) IN ORDER TO CREATE THE ACTION ITEMS
-- THE APEX PORTION OF THE UPLOADER HAS NOT BEEN DEVELOPED AS OF 11.1.2016
--------------------------------------------------------------------------------
  procedure pt_time(st number, et number)
  is
    elapsed_time number;
  begin
    elapsed_time := (et-st)/100;
    dbms_output.put_line('Total Time: '||floor(elapsed_time/60)||'m:'||to_char(mod(elapsed_time,60),'9990.09')||'s');
    null;
  end pt_time;
--------------------------------------------------------------------------------
  procedure create_req (ip_file_name varchar2,
                        ip_order_type varchar2,
                        ip_short_code varchar2,
                        ip_sms_msg varchar2,
                        ip_user_name varchar2,
                        op_result out varchar2)
  is
    bc blob;
    v_short_code sa.apex_hotline_req.short_code%type;
    v_sms_msg sa.apex_hotline_req.sms_msg%type;
  begin
    if ip_order_type = 'SEND_MESSAGE' then
      v_short_code := ip_short_code;
      v_sms_msg := ip_sms_msg;
    end if;

    select blob_content into bc from wwv_flow_files where name = ip_file_name;
    insert into apex_hotline_req
    (source_file,blob_content,order_type,short_code,sms_msg,requestor,load_date,req_processed)
    values
    (ip_file_name,bc,ip_order_type,v_short_code,v_sms_msg,ip_user_name,sysdate,'N');
  end create_req;
--------------------------------------------------------------------------------
  procedure create_req_data(ip_file_name varchar2,
                            op_result out varchar2)
  is
    st split_tbl_ty := split_tbl_ty();
    myrec varchar2(4000);
    v_data_array wwv_flow_global.vc_arr2;
    tblob blob;
    start_data number;
    rec_not_inserted exception;
    hot_line_cap_maxed exception;
    start_proc number;
    end_proc number;
    suc_cnt number := 0;
    err_cnt number := 0;
    v_upload_cap number := 0;
    v_order_type varchar2(200);
    v_sms_msg varchar2(200);
  begin
    start_proc := DBMS_UTILITY.get_time;
    begin
      select blob_content,order_type
      into   tblob,v_order_type
      from   apex_hotline_req
      where  source_file = ip_file_name;
    exception
        when no_data_found then
        dbms_output.put_line(chr(10)||chr(10)||'	"'||ip_file_name
                       || '" :File not found. Exiting ..'||chr(10));
        return;
    end;
    split(tblob,chr(10),st);
    dbms_output.put_line('TOTAL RECS-'||st.count);

    begin
      select to_number(x_param_value) into v_upload_cap
      from table_x_parameters where x_param_name = 'APEX_HOTLINE_UPLOAD_CAP';
    exception
      when others then
        v_upload_cap := 5000;
    end;

    if st.count > v_upload_cap then
      raise hot_line_cap_maxed;
    end if;

    start_data := 1;

    -- INSERT BATCH
    for i in start_data..st.count
    loop
      myrec := st(i);
      myrec := replace(replace(myrec,chr(10),''),chr(13),'');
      v_sms_msg := null;
      if length(myrec) >0 then
        v_data_array := wwv_flow_utilities.string_to_table(myrec,',');
        begin
          if v_data_array.count > 1 then
            v_sms_msg := substr(v_data_array(2),0,200);
          end if;
          insert into apex_hotline_req_data (source_file,esn_or_min,sms_msg,process_status) values (ip_file_name,v_data_array(1),v_sms_msg,'N');
          suc_cnt := suc_cnt+1;
        exception
          when others then
            err_cnt := err_cnt + 1;
        end;
      end if;
     end loop;

     end_proc := DBMS_UTILITY.get_time;
     pt_time(st =>start_proc, et =>end_proc);
     op_result := op_result||' File:'||ip_file_name ||'<br />'|| 'Totals: ('||suc_cnt||') Success / ('||err_cnt||') Failed'||'<br />';

  exception
    when hot_line_cap_maxed then
      op_result := 'You have exceeded the allowed records to process ('||v_upload_cap||'). Please reduce the size of your file and try again.';
    when others then
      op_result := sqlerrm;
  end create_req_data;
--------------------------------------------------------------------------------
  procedure process_req(ip_order_type varchar2, ip_request_type varchar2,ip_commit_every number)
  is
    v_out_err_num number;
    v_out_err_msg varchar2(4000);
    cnt number := 1;
    err_cnt number := 0;
    start_proc number;
    end_proc number;
    data_cnt number := 0;
  begin
    if ip_commit_every is null then
      return;
    end if;

    start_proc := DBMS_UTILITY.get_time;
    for j in (
              -- PROCESS ALL REDIRECTS AND SMS SEPERATELY WITHIN THE NEXT
              select *
              from apex_hotline_req r
              where r.load_date between trunc(sysdate) and trunc(sysdate)+1
              and r.req_processed != 'S'
              and r.req_processed = ip_request_type
              and r.order_type = decode(ip_order_type,'',r.order_type,ip_order_type)
              and r.order_type != decode(ip_order_type,'','SEND_MESSAGE','DISPLAY_ALL')
              )
    loop
        for i in (
                  select *
                  from  apex_hotline_req_data
                  where process_status != 'S'
                  and  source_file = j.source_file -- PROCESS ONLY NEW AND FAILED JOBS
                  )
        loop

          if j.order_type in ('SEND_MESSAGE') then
            sa.hotline_request_pkg.create_hotline_sms (in_min => i.esn_or_min, in_rqsttype => j.order_type, in_short_code => j.short_code,
                                                       in_sms_msg => j.sms_msg, in_user => j.requestor, out_err_num => v_out_err_num,
                                                       out_err_msg => v_out_err_msg);
          else
            sa.hotline_request_pkg.create_hotline_esn_request (in_esn      => i.esn_or_min,
                                                               in_rqsttype => j.order_type,
                                                               in_user     => j.requestor,
                                                               out_err_num => v_out_err_num,
                                                               out_err_msg => v_out_err_msg);
          end if;

          update apex_hotline_req_data
          set process_status = decode(v_out_err_num,'0','S','F')
          where esn_or_min = i.esn_or_min
          and source_file = j.source_file;

          if v_out_err_num > 0 then
            err_cnt := err_cnt+1;
          end if;

          cnt := cnt+1;
          if cnt = 1000 then
            commit;
            cnt := 1;
          end if;
          data_cnt := data_cnt+1;
        end loop;

        if data_cnt > 0 then
          update apex_hotline_req
          set req_processed = decode(err_cnt,'0','S','P')
          where source_file = j.source_file;
          data_cnt := 0;
        end if;
        commit;
        cnt := 1;
        err_cnt := 0;
    end loop;
    end_proc := dbms_utility.get_time;
    pt_time(st =>start_proc, et =>end_proc);
  end process_req;
--------------------------------------------------------------------------------
  procedure process_hotline_req(ip_commit_every number default 500)
  is
  begin
    process_req(ip_order_type =>null, ip_request_type =>'N', ip_commit_every =>ip_commit_every);
  end process_hotline_req;
--------------------------------------------------------------------------------
  procedure process_sms_req(ip_commit_every number default 500)
  is
  begin
    process_req(ip_order_type =>'SEND_MESSAGE', ip_request_type =>'N', ip_commit_every =>ip_commit_every);
  end process_sms_req;
--------------------------------------------------------------------------------
end apex_hotline_request_pkg;
/