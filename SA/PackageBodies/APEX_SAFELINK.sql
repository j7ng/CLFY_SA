CREATE OR REPLACE PACKAGE BODY sa."APEX_SAFELINK" as
--------------------------------------------------------------------------------
g_col_count number;
g_err_msg varchar2(200);
escaped_comma constant varchar2(3) := '~C';
double_pipe constant varchar2(4) := '~P';
--------------------------------------------------------------------------------
-- INTERNAL TO PACKAGE - PROCEDURE TO INSERT SL HISTORY
--------------------------------------------------------------------------------
  procedure ins_sl_hist (ipv_job_data_id  x_sl_hist.x_event_value%type,
                         ipn_event_code   x_sl_hist.x_event_code%type,
                         ipv_event_data   x_sl_hist.x_event_data%type,
                         ipv_username     x_sl_hist.username%type,
                         ipv_sourcesystem x_sl_hist.x_sourcesystem%type,
                         ipv_code_number  x_sl_hist.x_code_number%type,
                         ipv_src_table    x_sl_hist.x_src_table%type,
                         ipn_src_objid    x_sl_hist.x_src_objid%type)
  as
  begin
    insert into x_sl_hist
      (objid,
       lid,
       x_event_dt,
       x_insert_dt,
       x_event_value,
       x_event_code,
       x_event_data,
       username,
       x_sourcesystem,
       x_code_number,
       x_src_table,
       x_src_objid)
    values
      (sa.seq_x_sl_hist.nextval,
       -1,
       sysdate,
       sysdate,
       ipv_job_data_id, -- x_event_value
       ipn_event_code, -- x_event_code NEW COOLING CODE
       ipv_event_data,
       ipv_username,
       ipv_sourcesystem,
       ipv_code_number,
       ipv_src_table,
       ipn_src_objid);

    -- dbms_output.put_line('SL Hist Logged: '||ipn_src_objid);
  end ins_sl_hist;
--------------------------------------------------------------------------------
-- INTERNAL TO PACKAGE - PROCEDURE TO INSERT JOB ERRORS
--------------------------------------------------------------------------------
  procedure ins_job_err (ipv_job_data_id varchar2,
                         ipv_req_type varchar2,
                         ipv_req varchar2,
                         pv_err_msg in out varchar2)
  as
    pragma autonomous_transaction;
  begin
    insert into x_job_errors
     (objid,
      x_source_job_id,
      x_request_type,
      x_request,
      ordinal,
      x_status_code,
      x_reject,
      x_insert_date,
      x_update_date,
      x_resent,
      x_error_msg)
    values
     (sa.seq_x_job_errors.nextval,
      ipv_job_data_id, --j.job_data_id,
      ipv_req_type, --i.req_type,
      ipv_req, --i.req,
      0,
      -100,
      0,
      sysdate,
      sysdate,
      0,
      pv_err_msg
      );
     pv_err_msg := null;
      commit;
end ins_job_err;

------------------------------------------------------------------------------
-- CREATE JOB RUN DETAILS PROC
------------------------------------------------------------------------------
procedure ins_job_run_details (ipv_job_data_id x_job_run_details.job_data_id%type,
                        ipv_priority           x_job_run_details.x_priority%type,
                        ipv_scheduled_run_date x_job_run_details.x_scheduled_run_date%type,
                        ipv_job_objid          x_job_run_details.run_details2job_master%type,
                        ipv_user_name          x_job_run_details.owner_name%type,
                        ipv_reason             x_job_run_details.x_reason%type,
                        ipv_sourcesystem       x_job_run_details.x_sub_sourcesystem%type,
                        ipv_msg                x_job_run_details.x_source_table%type,
                        ipv_file_name          varchar2, -- new
                        ipv_job_data_count     varchar2)

as
 tmp boolean;
begin
  insert into x_job_run_details
    (objid,
     job_data_id,
     x_priority,
     x_scheduled_run_date,
     x_actual_run_date,
     run_details2job_master,
     x_insert_date,
     x_status_code,
     owner_name,
     x_reason,
     x_sub_sourcesystem,
     x_source_table)
  values
    (seq_x_job_run_details.nextval,
     ipv_job_data_id,
     ipv_priority,
     ipv_scheduled_run_date,
     null,
     ipv_job_objid,
     sysdate,
     500,
     ipv_user_name,
     ipv_reason,
     ipv_sourcesystem,
     null);


  if ipv_sourcesystem = 'APEX_SAFELINK' then
       ins_sl_hist( ipv_job_data_id,
                    '606',
                    'Created job, rec cnt: '||ipv_job_data_count,
                    ipv_user_name,
                    'APEX',
                    0,
                    ipv_file_name,
                    null);
  end if;
exception
  when others then
  -- JOB DID NOT INSERT
 -- opv_job_data_id := null;

       ins_sl_hist(ipv_job_data_id,
                   '505',
                   'No job, rec cnt: '||ipv_job_data_count,
                   ipv_user_name,
                   'APEX',
                   0,
                   ipv_file_name,
                   null);
end ins_job_run_details;

------------------------------------------------------------------------------
-- INSERT JOB DATA PROC
------------------------------------------------------------------------------
function ins_job_data(ipv_job_data_id      x_job_data.job_data_id%type,
                      ipv_x_request_type   x_job_data.x_request_type%type, -- 50 byte
                      ipv_x_request        x_job_data.x_request%type,      -- 2000 byte
                      ipn_ordinal          x_job_data.ordinal%type)
return boolean is
begin
    insert into x_job_data
      (job_data_id,
       x_request_type,
       x_request,
       ordinal)
    values
      (ipv_job_data_id,
       ipv_x_request_type,
       ipv_x_request,
       ipn_ordinal);
  return true;
exception
  when others then
    return false;
end;

----------------------------------------------------------------------------
-- UPDATE X_SL_SUBS TABLE                                                 --
----------------------------------------------------------------------------
procedure upd_sl_subs(ipn_lid x_sl_subs.lid%type)
--------------------------------------------------------------------------------
as
begin
  update x_sl_subs
  set    sl_subs2table_contact = -1
  where  lid = ipn_lid
  and    sl_subs2table_contact is null;
end upd_sl_subs;
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
function get_cursor(ip_job_data_id varchar2,
                    op_job_class out varchar2,
                    op_job_rec_count out number,
                    op_curs out sys_refcursor ) return boolean is
--------------------------------------------------------------------------------
begin
  select x_request_type,count(*)
  into op_job_class,op_job_rec_count
  from x_job_data
  where job_data_id = ip_job_data_id
  group by x_request_type;

  if op_job_class = 'BDeacts' then
     open op_curs for  select extractvalue(xmltype(x_request),'request/esn') esn,
                              extractvalue(xmltype(x_request),'request/min') min,
                              extractvalue(xmltype(x_request),'request/reason') reason,
                              extractvalue(xmltype(x_request),'request/act_item') act_item,
                              extractvalue(xmltype(x_request),'request/new_esn') new_esn,
                              extractvalue(xmltype(x_request),'request/same_min') same_min,
                              x_request req
                       from   x_job_data
                       where  1=1
                       and    job_data_id = ip_job_data_id;
     return true;
  elsif op_job_class = 'BInteract' then
     open op_curs for select extractvalue(xmltype(x_request),'request/esn') esn,
                             extractvalue(xmltype(x_request),'request/reason') reason,
                             extractvalue(xmltype(x_request),'request/detail') detail,
                             extractvalue(xmltype(x_request),'request/notes') notes,
                             x_request req
                     from   x_job_data
                     where  job_data_id = ip_job_data_id;
     return true;
  elsif op_job_class = 'BCooling' then
      open op_curs for select extractvalue(xmltype(x_request),'request/objid') objid,
                              x_request req
                       from   x_job_data
                       where  job_data_id = ip_job_data_id;
     return true;
  elsif op_job_class = 'BCreateCase' then
     open op_curs for  select extractvalue(xmltype(x_request),'request/esn') esn,
                       extractvalue(xmltype(x_request),'request/case_title') case_title,
                       extractvalue(xmltype(x_request),'request/case_type') case_type,
                       extractvalue(xmltype(x_request),'request/status') status,
                       extractvalue(xmltype(x_request),'request/priority') priority,
                       extractvalue(xmltype(x_request),'request/issue') issue,
                       extractvalue(xmltype(x_request),'request/notes') notes,
                       extractvalue(xmltype(x_request),'request/c_objid') c_objid,
                       extractvalue(xmltype(x_request),'request/f_name') f_name,
                       extractvalue(xmltype(x_request),'request/l_name') l_name,
                       extractvalue(xmltype(x_request),'request/part_req') part_req,
                       x_request req
                from   x_job_data
                where  job_data_id = ip_job_data_id;
     return true;
  elsif op_job_class = 'BResPgmSrtDate' then
     open op_curs for select extractvalue(xmltype(x_request),'request/lid') lid,
                       extractvalue(xmltype(x_request),'request/esn') esn,
                       extractvalue(xmltype(x_request),'request/new_date') new_date,
                       x_request req
                from   x_job_data
                where  job_data_id = ip_job_data_id;
     return true;
  elsif op_job_class = 'BChargeBks' then
     open op_curs for select extractvalue(xmltype(x_request),'request/merch_no') merch_no,
                       extractvalue(xmltype(x_request),'request/reason') reason,
                       extractvalue(xmltype(x_request),'request/requestor') requestor,
                       x_request req
                from   x_job_data
                where  job_data_id = ip_job_data_id;
     return true;
  elsif op_job_class = 'ContactEdit' then
     open op_curs for select extractvalue(xmltype(x_request),'request/name') name,
                       extractvalue(xmltype(x_request),'request/address') address,
                       extractvalue(xmltype(x_request),'request/address2') address2,
                       extractvalue(xmltype(x_request),'request/city') city,
                       extractvalue(xmltype(x_request),'request/state') state,
                       extractvalue(xmltype(x_request),'request/zip') zip,
                       extractvalue(xmltype(x_request),'request/zip2') zip2,
                       extractvalue(xmltype(x_request),'request/country') country,
                       extractvalue(xmltype(x_request),'request/email') email,
                       extractvalue(xmltype(x_request),'request/homenumber') homenumber,
                       extractvalue(xmltype(x_request),'request/external_account') ext_acct,
                       extractvalue(xmltype(x_request),'request/lid') lid,
                       extractvalue(xmltype(x_request),'request/shippingAddress') shp_address,    -- CR22302 -- adding shipping address
                       extractvalue(xmltype(x_request),'request/shippingAddress2') shp_address2, -- CR22302 -- adding shipping address
                       extractvalue(xmltype(x_request),'request/shippingCity') shp_city,   -- CR22302 -- adding shipping address
                       extractvalue(xmltype(x_request),'request/shippingState') shp_state ,  -- CR22302 -- adding shipping address
                       extractvalue(xmltype(x_request),'request/shippingZip') shp_zip,  -- CR22302 -- adding shipping address
                       x_request req
                from   x_job_data
                where  job_data_id = ip_job_data_id;
     return true;

  end if;
return false;
end;
----------------------------------------------------------------------------
-- RET_XML_REC
----------------------------------------------------------------------------
procedure ret_xml_rec(p_job_class  varchar2,
                      p_data_array wwv_flow_global.vc_arr2,
                      p_user_name  varchar2,
                      op_st out    varchar2 ) is
--------------------------------------------------------------------------------
  v_data_1 varchar2(100);
  v_data_2 varchar2(100);
  v_data_3 varchar2(100);
  v_data_4 varchar2(100);
begin
 dbms_output.put_line('DA count='||p_data_array.count||' GCount='||g_col_count);
 op_st := '<request>'||chr(10)||'   ';
 if p_job_class = 'BCreateCase' then
   op_st := op_st||'<requestType>'|| p_job_class     ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(1) ||'</esn>'        ||chr(10)||'   ';
   op_st := op_st||'<case_title>' || p_data_array(2) ||'</case_title>' ||chr(10)||'   ';
   op_st := op_st||'<case_type>'  || p_data_array(3) ||'</case_type>'  ||chr(10)||'   ';
   op_st := op_st||'<status>'     || p_data_array(4) ||'</status>'     ||chr(10)||'   ';
   op_st := op_st||'<priority>'   || p_data_array(5) ||'</priority>'   ||chr(10)||'   ';
   op_st := op_st||'<issue>'      || p_data_array(6) ||'</issue>'      ||chr(10)||'   ';
--   op_st := op_st||'<notes>'      || p_data_array(7) ||'</notes>'      ||chr(10)||'   ';
   op_st := op_st||'<c_objid>'    || p_data_array(7) ||'</c_objid>'    ||chr(10)||'   ';
   op_st := op_st||'<f_name>'     || p_data_array(8) ||'</f_name>'     ||chr(10)||'   ';
   op_st := op_st||'<l_name>'     || p_data_array(9)||'</l_name>'     ||chr(10)||'   ';
   if g_col_count > 9 then
      op_st := op_st||'<part_req>'   || p_data_array(10)||'</part_req>'||chr(10)||'    ';
   end if;
   op_st := op_st||'<requestor>'   || p_user_name     ||'</requestor>'||chr(10);

 elsif p_job_class in ('BAttachEsn','BDetachEsn','BDeliverBenefits') then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(2)||'</esn>'        ||chr(10)||'   ';
   op_st := op_st||'<lid>'        || p_data_array(1)||'</lid>' ||chr(10);

 elsif p_job_class = 'BDeEnroll' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(2)||'</esn>'        ||chr(10)||'   ';
   op_st := op_st||'<lid>'        || p_data_array(1)||'</lid>'        ||chr(10)||'   ';
   op_st := op_st||'<reason>'     || p_data_array(3)||'</reason>'||chr(10);
   upd_sl_subs(p_data_array(1));
 elsif p_job_class = 'BUpdateZipParts' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<zipcode>'    || p_data_array(1)||'</zipcode>'    ||chr(10)||'   ';
   op_st := op_st||'<partnum>'    || p_data_array(2)||'</partnum>'||chr(10);
 elsif p_job_class = 'BArSend' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(1)||'</esn>'        ||chr(10)||'   ';
   op_st := op_st||'<onoff>'      || p_data_array(2)||'</onoff>'      ||chr(10)||'   ';
   op_st := op_st||'<aramount>'   || p_data_array(3)||'</aramount>'   ||chr(10)||'   ';
   op_st := op_st||'<arstartdate>'|| p_data_array(4)||'</arstartdate>'||chr(10)||'   ';
   op_st := op_st||'<arenddate>'  || p_data_array(5)||'</arenddate>'  ||chr(10)||'   ';
   op_st := op_st||'<artimer>'    || p_data_array(6)||'</artimer>'    ||chr(10)||'   ';
   op_st := op_st||'<arday>'      || p_data_array(7)||'</arday>'      ||chr(10)||'   ';
   op_st := op_st||'<arshortcode>32275</arshortcode>'          ||chr(10);
  --Asim Look orig code "esn in (2)"??
 elsif p_job_class = 'BInvoiceReason' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<lid>'        || p_data_array(1)||'</lid>'        ||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(2)||'</esn>'        ||chr(10)||'   ';
   op_st := op_st||'<reason>'     || p_data_array(3)||'</reason>'||chr(10);
 elsif p_job_class = 'BUpdateInvoice' then
   op_st := op_st||'<requestType>'  || p_job_class     ||'</requestType>'  ||chr(10)||'   ';
   op_st := op_st||'<lid>'          || p_data_array(1) ||'</lid>'          ||chr(10)||'   ';
   op_st := op_st||'<esn>'          || p_data_array(2) ||'</esn>'          ||chr(10)||'   ';
   op_st := op_st||'<invoicereason>'|| p_data_array(3) ||'</invoicereason>'||chr(10)||'   ';
   op_st := op_st||'<batchdate>'    || p_data_array(4) ||'</batchdate>'    ||chr(10)||'   ';
   op_st := op_st||'<address1>'     || p_data_array(5) ||'</address1>'     ||chr(10)||'   ';
   op_st := op_st||'<address2>'     || p_data_array(6) ||'</address2>'     ||chr(10)||'   ';
   op_st := op_st||'<city>'         || p_data_array(7) ||'</city>'         ||chr(10)||'   ';
   op_st := op_st||'<state>'        || p_data_array(8) ||'</state>'        ||chr(10)||'   ';
   op_st := op_st||'<zip5>'         || p_data_array(9) ||'</zip5>'         ||chr(10)||'   ';
   op_st := op_st||'<texasflag>'    || p_data_array(10)||'</texasflag>'    ||chr(10)||'   ';
   op_st := op_st||'<exclusion>'    || p_data_array(11)||'</exclusion>'||chr(10);
 elsif p_job_class = 'BInteract' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(1)||'</esn>'        ||chr(10)||'   ';
   op_st := op_st||'<reason>'     || p_data_array(2)||'</reason>'     ||chr(10)||'   ';
   op_st := op_st||'<detail>'     || p_data_array(3)||'</detail>'     ||chr(10)||'   ';
   op_st := op_st||'<notes>'      || p_data_array(4)||'</notes>'||chr(10);
 elsif p_job_class = 'BCooling' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<objid>'      || p_data_array(1)||'</objid>'||chr(10);
 elsif p_job_class = 'BResPgmSrtDate' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<lid>'        || p_data_array(1)||'</lid>'        ||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(2)||'</esn>'        ||chr(10)||'   ';
   op_st := op_st||'<new_date>'   || p_data_array(3)||'</new_date>'   ||chr(10);
--   op_st := op_st||'<reason>'     || p_data_array(4)||'</reason>'||chr(10);
 elsif p_job_class = 'BChargeBks' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<merch_no>'   || p_data_array(1)||'</merch_no>'   ||chr(10)||'   ';
   op_st := op_st||'<reason>'     || p_data_array(2)||'</reason>'     ||chr(10)||'   ';
   op_st := op_st||'<requestor>'  || p_user_name    ||'</requestor>'  ||chr(10);
 elsif p_job_class = 'BDeacts' then
   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(1)||'</esn>'||chr(10)||'   ';
   op_st := op_st||'<min>'        || p_data_array(2)||'</min>'||chr(10)||'   ';
   op_st := op_st||'<reason>'     || p_data_array(3)||'</reason>'||chr(10)||'   ';
   op_st := op_st||'<act_item>'   || p_data_array(4)||'</act_item>'||chr(10)||'   ';
   if g_col_count >4 then
      op_st := op_st||'<new_esn>'    || p_data_array(5)||'</new_esn>'||chr(10)||'   ';
   end if;
   if g_col_count >5 then
      op_st := op_st||'<same_min>'   || p_data_array(6)||'</same_min>'||chr(10);
   end if;
 elsif p_job_class = 'Invoicefeed' then
    null;
 else
   if g_col_count > 2 then
    v_data_1 := p_data_array(3);
   end if;
   if g_col_count > 3 then
    v_data_2 := p_data_array(4);
   end if;
   if g_col_count > 4 then
    v_data_3 := p_data_array(5);
   end if;
   if g_col_count > 5 then
       v_data_4 := p_data_array(6);
   end if;

   op_st := op_st||'<requestType>'|| p_job_class    ||'</requestType>'||chr(10)||'   ';
   op_st := op_st||'<lid>'        || p_data_array(1)||'</lid>'||chr(10)||'   ';
   op_st := op_st||'<esn>'        || p_data_array(2)||'</esn>'||chr(10)||'   ';

   op_st := op_st||'<reason>'     || v_data_1 ||'</reason>'||chr(10)||'   ';
   op_st := op_st||'<data1>'      || v_data_2 ||'</data1>'||chr(10)||'   ';
   op_st := op_st||'<data2>'      || v_data_3 ||'</data2>'||chr(10)||'   ';
   op_st := op_st||'<data3>'      || v_data_4 ||'</data3>'||chr(10)||'   ';

   op_st := op_st||'<apexuser>'   || p_user_name ||'</apexuser>'||chr(10);
 end if;
 op_st := op_st||'</request>';
end;
----------------------------------------------------------------------------
-- IS_HEADER
----------------------------------------------------------------------------
function is_header(rec in varchar2) return boolean
----------------------------------------------------------------------------
is
tmp varchar2(1000);
begin
 g_col_count := 1;

 tmp := rec;
 while (instr(tmp,',',1,g_col_count) <> 0)
 loop
  g_col_count := g_col_count + 1;
 end loop;
 tmp := replace(tmp,',','');

 if instr(tmp,'LID')+instr(tmp,'ESN')+instr(tmp,'HEADER')+instr(tmp,'MERCHANT_REF_NUMBER')+instr(tmp,'PGM_ENROLLED_OBJID') > 0 then
  return true;
 else
  return false;
 end if;
end;

----------------------------------------------------------------------------
-- FILE UPLOADER
----------------------------------------------------------------------------
procedure file_uploader(ip_job_name varchar2,
                        ip_file_name varchar2,
                        ip_priority number,
                        ip_sch_rundate date,
                        ip_user_reason varchar2,
                        ip_user_name varchar2,
                        ip_bus_reason  varchar2 default null,
                        op_result out varchar2) is
----------------------------------------------------------------------------
 st split_tbl_ty := split_tbl_ty();
 myrec varchar2(4000);
 v_data_array wwv_flow_global.vc_arr2;
 tblob blob;
 start_data number;
 xml_str varchar2(1000);
 v_job_data_id varchar2(20);
 v_job_class   x_job_master.x_job_class%type;
 v_job_objid   x_job_master.objid%type;
 v_sourcesystem x_job_master.x_job_sourcesystem%type;
 job_data_rec_not_inserted exception;
 start_proc number;
 end_proc number;
 elapsed_time number;
 suc_cnt number := 0;
 err_cnt number := 0;
 v_row_limit number := 50000;
begin
 start_proc := DBMS_UTILITY.get_time;
 begin
   select blob_content,
          to_char(systimestamp,'yyyymmddhh24missff4')
       into tblob,
            v_job_data_id
   from   wwv_flow_files a
   where  a.name = ip_file_name;

 exception
     when no_data_found then
     dbms_output.put_line(chr(10)||chr(10)||'    "'||ip_file_name
                    || '" :File not found. Exiting ..'||chr(10));
     return;
 end;
 begin
    select x_job_class,
           objid,
           x_job_sourcesystem
    into   v_job_class,
           v_job_objid,
           v_sourcesystem
    from   x_job_master
    where  x_job_name = ip_job_name;
 exception
    when others then
      raise_application_error(-20107, 'NEED A JOB NAME TO CONTINUE ');
 end;

   split(tblob,chr(10),st);
   dbms_output.put_line('TOTAL RECS-'||st.count);
   if not is_header(st(1)) then
      start_data := 1;
   else
      start_data := 2;
   end if;
   for i in start_data..st.count
   loop
      if i >= v_row_limit then
        exit;
      end if;

      myrec := replace(st(i), '\,', escaped_comma);
      myrec := replace(myrec, '||', double_pipe);
      myrec := replace(myrec, chr(10) ,'');
      myrec := replace(myrec, chr(13) ,'');
--      dbms_output.put_line(myrec);
      v_data_array := wwv_flow_utilities.string_to_table(myrec||',',',');
      begin
          ret_xml_rec(v_job_class, v_data_array, ip_user_name, xml_str );
          if (ins_job_data(v_job_data_id,
                           v_job_class,
                           replace(replace(xml_str,escaped_comma,','),double_pipe,'||'),
                           0)) then
                suc_cnt := suc_cnt +1;
          else
               raise job_data_rec_not_inserted;
          end if;

      exception
      when others then
        dbms_output.put_line(i||'-'||myrec||'('||sqlerrm||')');
           err_cnt := err_cnt + 1;
      end;
-- dbms_output.put_line('====='||i||'===='||chr(10)||xml_str||chr(10)||'===============');
   end loop;

   if suc_cnt > 0 then
       ins_job_run_details(v_job_data_id,
                           ip_priority,
                           ip_sch_rundate,
                           v_job_objid,
                           ip_user_name,
                           ip_user_reason,
                           v_sourcesystem,
                           null,
                           ip_file_name,
                           st.count);
      op_result := 'Job Data ID:'||v_job_data_id||' Name:'||ip_job_name||chr(10)||'<br />';
      op_result := op_result||'Sch Run Date:'||to_char(ip_sch_rundate,'mm/dd/yyyy hh24:mi:ss');
      op_result := op_result||' File:'||ip_file_name ||'<br />';
   else
      op_result := 'No RECORDS Loaded. Check the FILE and try it again '||chr(10)||'<br />';
   end if;
   end_proc := DBMS_UTILITY.get_time;
   elapsed_time := (end_proc-start_proc)/100;
   op_result := op_result||'Totals: ('||suc_cnt||') Loaded.('||err_cnt||') Errors.';
   op_result := op_result||' / Elapsed: '||floor(elapsed_time/60)||'m:';
   op_result := op_result||to_char(mod(elapsed_time,60),'9990.09')||'s';

   commit;
end file_uploader;
--------------------------------------------------------------------------------
-- INTERNAL TO PACKAGE - PROCEDURE TO INSERT SL HISTORY
--------------------------------------------------------------------------------
procedure upd_jrd (ipn_objid number,
                              ip_start_date date,
                              ipn_code number)
as
begin

  update x_job_run_details
  set    x_actual_run_date = sysdate,
         x_status = decode(ipn_code,0,'SUCCESS',503,'SUCCESS','FAILED'),
         x_start_time = ip_start_date,
         x_end_time = sysdate,
         -- x_job_run_mode = -- what is the diff between 0 and 1
         x_status_code = ipn_code -- from 501 to 0 i assume 0 = success
  where  objid = ipn_objid;
  -- dbms_output.put_line('Job Run Details Updated: '||ipn_objid);

end upd_jrd;

--------------------------------------------------------------------------
function ins_chargeback(ip_merch_no in varchar2,
                        ip_reason in varchar2,
                        ip_requestor in varchar2  ) return boolean is
begin
insert into table_x_purch_hdr(
             OBJID,
             X_RQST_SOURCE,
             X_RQST_TYPE,
             X_RQST_DATE,
             X_ICS_APPLICATIONS,
             X_MERCHANT_ID,
             X_MERCHANT_REF_NUMBER,
             X_OFFER_NUM,
             X_QUANTITY,
             X_MERCHANT_PRODUCT_SKU,
             X_PRODUCT_NAME,
             X_PRODUCT_CODE,
             X_IGNORE_BAD_CV,
             X_IGNORE_AVS,
             X_USER_PO,
             X_AVS,
             X_DISABLE_AVS,
             X_CUSTOMER_HOSTNAME,
             X_CUSTOMER_IPADDRESS,
             X_AUTH_REQUEST_ID,
             X_AUTH_CODE,
             X_AUTH_TYPE,
             X_ICS_RCODE,
             X_ICS_RFLAG,
             X_ICS_RMSG,
             X_REQUEST_ID,
             X_AUTH_AVS,
             X_AUTH_RESPONSE,
             X_AUTH_TIME,
             X_AUTH_RCODE,
             X_AUTH_RFLAG,
             X_AUTH_RMSG,
             X_AUTH_CV_RESULT,
             X_SCORE_FACTORS,
             X_SCORE_HOST_SEVERITY,
             X_SCORE_RCODE,
             X_SCORE_RFLAG,
             X_SCORE_RMSG,
             X_SCORE_RESULT,
             X_SCORE_TIME_LOCAL,
             X_BILL_REQUEST_TIME,
             X_BILL_RCODE,
             X_BILL_RFLAG,
             X_BILL_RMSG,
             X_BILL_TRANS_REF_NO,
             X_CUSTOMER_CC_NUMBER,
             X_CUSTOMER_CC_EXPMO,
             X_CUSTOMER_CC_EXPYR,
             X_CUSTOMER_CC_CV_NUMBER,
             X_CUSTOMER_FIRSTNAME,
             X_CUSTOMER_LASTNAME,
             X_CUSTOMER_PHONE,
             X_CUSTOMER_EMAIL,
             X_BANK_NUM,
             X_CUSTOMER_ACCT,
             X_ROUTING,
             X_ABA_TRANSIT,
             X_BANK_NAME,
             X_STATUS,
             X_BILL_ADDRESS1,
             X_BILL_ADDRESS2,
             X_BILL_CITY,
             X_BILL_STATE,
             X_BILL_ZIP,
             X_BILL_COUNTRY,
             X_ESN,
             X_CC_LASTFOUR,
             X_AMOUNT,
             X_TAX_AMOUNT,
             X_AUTH_AMOUNT,
             X_BILL_AMOUNT,
             X_USER,
             X_PURCH_HDR2CREDITCARD,
             X_PURCH_HDR2BANK_ACCT,
             X_PURCH_HDR2CONTACT,
             X_PURCH_HDR2USER,
             X_PURCH_HDR2ESN,
             X_PURCH_HDR2X_RMSG_CODES,
             X_PURCH_HDR2CR_PURCH,
             X_CREDIT_CODE,
             X_CREDIT_REASON,
             X_E911_AMOUNT,
             X_SHIPPING_COST,
             X_USF_TAXAMOUNT,
             X_RCRF_TAX_AMOUNT,
             X_DISCOUNT_AMOUNT,
             X_TOTAL_TAX)
            select sa.seq ('x_purch_hdr') objid,
                   'WEBCSR' x_rqst_source,
                   'cc_chgbk' x_rqst_type,
                   SYSDATE x_rqst_date,
                   'Toss_Chargeback' x_ics_applications,
                   x_merchant_id,
                   x_merchant_ref_number || '-CR' x_merchant_ref_number,
                   x_offer_num,
                   x_quantity,
                   x_merchant_product_sku,
                   x_product_name,
                   x_product_code,
                   x_ignore_bad_cv,
                   x_ignore_avs,
                   x_user_po,
                   x_avs,
                   x_disable_avs,
                   x_customer_hostname,
                   x_customer_ipaddress,
                   x_auth_request_id,
                   x_auth_code,
                   x_auth_type,
                   x_ics_rcode,
                   x_ics_rflag,
                   x_ics_rmsg,
                   x_request_id,
                   x_auth_avs,
                   x_auth_response,
                   x_auth_time,
                   x_auth_rcode,
                   x_auth_rflag,
                   x_auth_rmsg,
                   x_auth_cv_result,
                   x_score_factors,
                   x_score_host_severity,
                   x_score_rcode,
                   x_score_rflag,
                   x_score_rmsg,
                   x_score_result,
                   x_score_time_local,
                   x_bill_request_time,
                   x_bill_rcode,
                   x_bill_rflag,
                   x_bill_rmsg,
                   x_bill_trans_ref_no,
                   x_customer_cc_number,
                   x_customer_cc_expmo,
                   x_customer_cc_expyr,
                   x_customer_cc_cv_number,
                   x_customer_firstname,
                   x_customer_lastname,
                   x_customer_phone,
                   x_customer_email,
                   x_bank_num,
                   x_customer_acct,
                   x_routing,
                   x_aba_transit,
                   x_bank_name,
                   x_status,
                   x_bill_address1,
                   x_bill_address2,
                   x_bill_city,
                   x_bill_state,
                   x_bill_zip,
                   x_bill_country,
                   x_esn,
                   x_cc_lastfour,
                   x_amount*-1 x_amount,
                   x_tax_amount*-1 x_tax_amount,
                   x_auth_amount*-1 x_auth_amount,
                   x_bill_amount*-1 x_bill_amount,
                   ip_requestor,
                   x_purch_hdr2creditcard,
                   x_purch_hdr2bank_acct,
                   x_purch_hdr2contact,
                   x_purch_hdr2user,
                   x_purch_hdr2esn,
                   x_purch_hdr2x_rmsg_codes,
                   objid,
                   x_credit_code,
                   ip_reason x_credit_reason,
                   NVL(x_e911_amount,0)*-1,
                   NVL(X_SHIPPING_COST,0)*-1,
                   NVL(X_USF_TAXAMOUNT,0)*-1,
                   NVL(X_RCRF_TAX_AMOUNT,0)*-1,
                   NVL(X_DISCOUNT_AMOUNT,0)*-1,
                   NVL(X_TOTAL_TAX,0)*-1
            from   table_x_purch_hdr
            where  1=1
            and    x_merchant_ref_number = ip_merch_no;
   return true;
exception
   when others then
     return false;
end;
--------------------------------------------------------------------------
function create_case(ipv_case_title varchar2,
                     ipv_case_type  table_case.x_case_type%type,
                     ipv_status  varchar2,
                     ipv_priority varchar2,
                     ipv_issue  varchar2,
                     ipv_c_objid varchar2,
                     ipv_esn varchar2,
                     ipv_f_name varchar2,
                     ipv_l_name varchar2,
                     ipv_part_req varchar2)
return boolean is
--------------------------------------------------------------------------
 v_id_number   varchar2(40);
 n_case_objid  number;
 n_user_objid  number;
 v_err_no      varchar2(30);
 v_err_str     varchar2(300);
begin

    clarify_case_pkg.create_case(ipv_case_title,    -- P_TITLE
                                 ipv_case_type,     -- P_CASE_TYPE
                                 ipv_status,        -- P_STATUS
                                 ipv_priority,      -- P_PRIORITY
                                 ipv_issue,         -- P_ISSUE
                                 'APEX_CRM',        -- P_SOURCE (HIDDEN FIELD)
                                 null,              -- P_POINT_CONTACT
                                 sysdate,           -- P_CREATION_TIME
                                 null,              -- P_TASK_OBJID
                                 ipv_c_objid,       -- P_CONTACT_OBJID
                                 n_user_objid,      -- P_USER_OBJID
                                 ipv_esn,           -- P_ESN
                                 null,              -- P_PHONE_NUM     -- FOR SHIPPING
                                 ipv_f_name,        -- P_FIRST_NAME    -- FOR SHIPPING
                                 ipv_l_name,        -- P_LAST_NAME     -- FOR SHIPPING
                                 null,              -- P_E_MAIL        -- FOR SHIPPING
                                 null,              -- P_DELIVERY_TYPE -- FOR SHIPPING
                                 null,              -- P_ADDRESS       -- FOR SHIPPING
                                 null,              -- P_CITY          -- FOR SHIPPING
                                 null,              -- P_STATE         -- FOR SHIPPING
                                 null,              -- P_ZIPCODE       -- FOR SHIPPING
                                 null,              -- P_REPL_UNITS
                                 null,              -- P_FRAUD_OBJID
                                 null,              -- P_CASE_DETAIL
                                 ipv_part_req,      -- P_PART_REQUEST
                                 v_id_number,       -- P_ID_NUMBER
                                 n_case_objid,      -- P_CASE_OBJID
                                 v_err_no,          -- P_ERROR_NO
                                 v_err_str          -- P_ERROR_STR
                                 );
    if instr(upper(ipv_case_title),'CHARGEBACK')+instr(upper(ipv_case_type),'CHARGEBACK')>0 then
      return true;
    elsif v_err_no = 0 then
       ----Notes ???? Asim
      clarify_case_pkg.dispatch_case(n_case_objid,
                                     n_user_objid,
                                     null,
                                     v_err_no,
                                     v_err_str);
      if v_err_no = 0 then
         return true;
      else
         g_err_msg := 'case created '||n_case_objid||',but not dispatched';
         return false;
      end if;
    else
       g_err_msg := ipv_esn||'- case not processed';
       return false;
    end if;
end;
--------------------------------------------------------------------------
function reset_pgm_stdate(ipv_esn varchar2,
                          ipv_lid varchar2,
                          ipv_new_date varchar2)
--------------------------------------------------------------------------
return boolean is
begin
     update x_sl_currentvals
     set x_current_pgm_start_date = to_date(ipv_new_date,'MM/DD/YYYY')
     where  lid = ipv_lid
     and    x_current_esn = ipv_esn;
  if sql%rowcount > 0  then
     return true;
  else
     g_err_msg := ipv_lid||'/'||ipv_esn|| ' - Error Unable to Update';
     return false;
  end if;
exception
  when others then
     return false;
end;
--------------------------------------------------------------------------
function update_contact(ipv_name varchar2,
                        ipv_address varchar2,
                        ipv_address2 varchar2,
                        ipv_city  varchar2,
                        ipv_state  varchar2,
                        ipv_zip varchar2,
                        ipv_zip2 varchar2,
                        ipv_country varchar2,
                        ipv_email varchar2,
                        ipv_homenumber varchar2,
                        ipv_ext_acct varchar2,
                        ipv_lid VARCHAR,
                        ipv_shpaddress varchar2,     -- CR22302 -- adding shipping address
                        ipv_shpaddress2 varchar2,    -- CR22302 -- adding shipping address
                        ipv_shpcity  varchar2,       -- CR22302 -- adding shipping address
                        ipv_shpstate  varchar2,      -- CR22302 -- adding shipping address
                        ipv_shpzip varchar2          -- CR22302 -- adding shipping address
                        )
--------------------------------------------------------------------------
return boolean is
begin
     update x_sl_subs
     set FULL_NAME=ipv_name,
         ADDRESS_1=ipv_address,
         ADDRESS_2=ipv_address2,
         CITY=ipv_city,
         STATE=ipv_state,
         ZIP=ipv_zip,
         ZIP2=ipv_zip2,
         COUNTRY=ipv_country,
         E_MAIL=ipv_email,
         X_HOMENUMBER=ipv_homenumber,
         X_EXTERNAL_ACCOUNT= ipv_ext_acct,
         X_SHP_ADDRESS  = ipv_shpaddress,        -- CR 22302 -- adding shipping address
         X_SHP_ADDRESS2 = ipv_shpaddress2,       -- CR22302 -- adding shipping address
         X_SHP_CITY     = ipv_shpcity,           -- CR22302 -- adding shipping address
         X_SHP_STATE    = ipv_shpstate,          -- CR22302 -- adding shipping address
         X_SHP_ZIP      = ipv_shpzip             -- CR22302 -- adding shipping address
     where  lid = ipv_lid;
  if sql%rowcount > 0  then
     return true;
  else
     g_err_msg := ipv_lid||' - Error Unable to Update';
     return false;
  end if;
exception
  when others then
     return false;
end;

--------------------------------------------------------------------------
function  reset_cooling(ipv_objid in varchar2) return boolean
--------------------------------------------------------------------------
is
 found_correct_status number;
 v_status x_program_enrolled.x_enrollment_status%type;
 found_incorrect_status number;
begin
   select e.x_enrollment_status
   into   v_status
   from   x_program_enrolled e,
          x_program_parameters p
   where  1=1
   and    e.pgm_enroll2pgm_parameter = p.objid
   and    p.x_prog_class = 'LIFELINE'
   and    e.objid = ipv_objid;
   if v_status in ('DEENROLLED','ENROLLMENTPENDING') then
      update x_program_enrolled
      set    x_enrollment_status      = 'READYTOREENROLL',
             x_update_stamp           = sysdate,
             x_cooling_exp_date       = null,
             x_delivery_cycle_number  = null,
             x_next_delivery_date     = null,
             x_charge_date            = null,
             x_next_charge_date       = null,
             x_grace_period           = null,
             x_cooling_period         = null,
             x_service_days           = null,
             x_wait_exp_date          = null,
             x_tot_grace_period_given = null
      where objid = ipv_objid;
      if sql%rowcount >0 then
          return true;
       else
          g_err_msg := 'Objid -'||ipv_objid||' Unable to update';
          return false;
       end if;
   else
      g_err_msg := 'Objid -'||ipv_objid||' Incorrect status('||v_status||') to update';
      return false;
   end if;
exception
  when others then
      g_err_msg := 'Objid -'||ipv_objid||' not found';
      return false;
end;
--------------------------------------------------------------------------
function  deact_service( ipv_esn varchar2,
                         ipv_min varchar2,
                         ipv_reason varchar2,
                         ipv_create_ai varchar2,
                         ipv_new_esn varchar2,
                         ipv_same_min varchar2)
return boolean is
--------------------------------------------------------------------------
v_err_no varchar2(30);
v_same_min varchar(30);
v_action_item varchar2(2);
opv_out_msg varchar2(300);
n_user_objid number;
begin
     service_deactivation_code.deactService
                     ('APEX_BATCH_PROCESSOR', -- CURRENT VALS
                      n_user_objid,           -- SA OBJID -- ip_userObjId,
                      ipv_esn,
                      ipv_min,      -- ip_min
                      ipv_reason,   -- ip_DeactReason
                      nvl(v_action_item,1),  -- intByPassOrderType
                      ipv_new_esn,  -- ip_newESN only if adding a new esn
                      v_same_min, -- ip_samemin only if keeping the same min
                      v_err_no,
                      opv_out_msg);
    if instr(v_err_no,'false') = 0 then
       return true;
    else
       g_err_msg := 'ESN:'||ipv_esn ||' MIN:'||ipv_min||' - '||opv_out_msg;
       return false;
    end if;
end;
--------------------------------------------------------------------------
function  insert_interaction   (ipv_esn    table_part_inst.part_serial_no%type,
                                ipv_reason varchar2,
                                ipv_detail varchar2,
                                ipv_notes  varchar2,
                                ipv_call_rslt varchar2,
                                ipv_user_name varchar2)
 return boolean is
--------------------------------------------------------------------------
    v_objid number;
    v_interact_id number;
    v_con_first_name  varchar2(30);
    v_con_last_name   varchar2(30);
    v_con_phone       varchar2(20);
    v_con_e_mail      varchar2(80);
    v_con_zip         varchar2(20);
    n_con_objid       number;
    n_agent_objid     number;
begin
      begin
        select objid
        into   n_agent_objid
        from   table_user
        where  s_login_name = upper(ipv_user_name);
      exception
        when others then
          -- INSERT JUST THE AGENTS NAME AND CONTINUE
          null;
      end;

      select c.objid,
             c.first_name,
             c.last_name,
             c.phone,
             c.e_mail,
             c.zipcode
      into   n_con_objid,
             v_con_first_name,
             v_con_last_name,
             v_con_phone,
             v_con_e_mail,
             v_con_zip
      from   table_part_inst p,
             table_contact c
      where  p.x_part_inst2contact = c.objid
      and    p.part_serial_no = ipv_esn;

      v_objid := sa.Seq ('interact');
      select sa.sequ_interaction_id.NEXTVAL
      into v_interact_id
      from dual;

      insert into table_interact
        (objid,
         interact_id,
         create_date,
         inserted_by,
         external_id,
         direction,
         type,
         s_type,
         origin,
         product,
         s_product,
         reason_1,
         s_reason_1,
         reason_2,
         s_reason_2,
         reason_3,
         s_reason_3,
         result,
         done_in_one,
         fee_based,
         wait_time,
         system_time,
         entered_time,
         pay_option,
         title,
         s_title,
         start_date,
         end_date,
         last_name,
         s_last_name,
         first_name,
         s_first_name,
         phone,
         fax_number,
         email,
         s_email,
         zipcode,
         arch_ind,
         agent,
         s_agent,
         serial_no,
         mobile_phone,
         x_service_type,
         interact2contact,
         interact2user)
      values
        (v_objid,
         v_interact_id,
         sysdate, --to_date(d_end_time, 'DD-MON-YYYY HH24:MI:SS'),
         ipv_user_name,
         '',
         'BatchProc',
         'BatchProc',
         upper('BatchProc'),
         'BatchProc',
         'None',
         upper('None'),
         ipv_reason,
         upper(ipv_reason),
         ipv_detail,
         upper(ipv_detail),
         '',
         '',
         nvl(ipv_call_rslt,'Successful'),
         0,
         0,
         0,
         0,
         0,
         ipv_reason,
         '',
         '',
         sysdate, --d_start_time,
         sysdate, --d_end_time,
         v_con_last_name,
         upper(v_con_last_name),
         v_con_first_name,
         upper(v_con_first_name),
         v_con_phone,
         '',
         v_con_e_mail,
         upper(v_con_e_mail),
         v_con_zip,
         0,
         ipv_user_name,
         upper(ipv_user_name),
         ipv_esn,
         '',
         'Wireless',
         n_con_objid,
         n_agent_objid);
    ------------------------------------------------------------------------------
    -- CREATE INTERACTION TEXT
    ------------------------------------------------------------------------------
      insert into table_interact_txt
        (objid,
         notes,
         interact_txt2interact)
      values
        (sa.Seq('interact_txt'),
         replace(ipv_notes,'\nl',chr(10)),
         v_objid);
  return true;
exception
      when others then
     g_err_msg := ipv_esn||' - Interaction not processed';
     return false;
end;
------------------------

procedure runbatch(ip_jid varchar2 default null,
                   ip_srce_table varchar2 default null) is
  cursor job_curs(jid_in varchar2) is
              select d.job_data_id,
                     d.objid,
                     d.owner_name
              from   x_job_run_details d,
                     x_job_master m
              where  run_details2job_master = m.objid
              and    x_status_code = '501'
              and    x_scheduled_run_date < decode(jid_in,null,sysdate,x_scheduled_run_date+1)
              and    job_data_id = nvl(jid_in,job_data_id);
              --and    x_actual_run_date is null;
  v_job_data_id varchar2(30);
  v_job_objid number;
  v_event_code x_sl_hist.x_event_code%type;
  v_event_data x_sl_hist.x_event_data%type;
  v_job_class varchar2(30);
  v_job_rec_count number;
  v_cur sys_refcursor;
  v_suc_cnt number;
  v_err_cnt number;
  v_ret_code number;
  v_start_date date;
  v_rec_inserted  boolean;
  v_req x_job_data.x_request%type;
  v_requestor x_job_run_details.owner_name%type;
  opv_out_msg varchar2(300);
  job_processed boolean;
  type rt_t is table of varchar2(1000) index by binary_integer;
  rt rt_t;
begin
  job_processed := false;
  dbms_output.put_line('exec apex_safelink.runbatch('''||ip_jid||''','''||ip_srce_table||''')');


  for i in  job_curs(ip_jid)
  loop
     -- fetch job_curs into v_job_data_id,v_job_objid,v_requestor;
      v_job_data_id := i.job_data_id;
      v_job_objid :=  i.objid;
      v_requestor :=  i.owner_name;


        dbms_output.put_line('getting in');
     --exit when job_curs%notfound;
     begin
       v_start_date := sysdate;
       job_processed := true;
       v_event_code := null;
       v_event_data := null;
       dbms_output.put_line('Inside');

       if (not get_cursor(v_job_data_id,v_job_class,v_job_rec_count,v_cur)) then
           dbms_output.put_line('get_cursor returned false');
       else
          v_suc_cnt := 0;
          v_err_cnt := 0;
        --  dbms_output.disable;
          --dbms_output.put_line('v_job_data_id: '||v_job_data_id);
          --dbms_output.put_line('v_job_class: '||v_job_class);
          --dbms_output.put_line('v_job_rec_count: '||v_job_rec_count);
          loop
              if v_job_class = 'BCreateCase' then
                 fetch v_cur into rt(1),rt(2),rt(3),rt(4),rt(5),rt(6),
--                                  rt(7),rt(8),rt(9),rt(10),v_req;
                                  rt(7),rt(8),rt(9),rt(10),rt(11),v_req;
                 exit when v_cur%notfound;
                 v_rec_inserted := create_case(rt(2),  --case_title
                                               rt(3),  --case_type
                                               rt(4),  --status
                                               rt(5),  --priority
                                               rt(6),  --issue
                                               rt(7),  --c_objid
                                               rt(1),  --esn
                                               rt(8),  --fname
                                               rt(9), --lname
                                               rt(10));--part_req
              elsif v_job_class = 'BInteract' then
                 fetch v_cur into rt(1),rt(2),rt(3),rt(4),v_req;
                 exit when v_cur%notfound;
                 v_rec_inserted := insert_interaction(rt(1),
                                                      rt(2),
                                                      rt(3),
                                                      rt(4),
                                                      null,
                                                      v_requestor);
              elsif v_job_class = 'BCooling' then
                 fetch v_cur into rt(1),v_req;
                 exit when v_cur%notfound;
                 v_event_code := '624';
                 v_rec_inserted :=  reset_cooling(rt(1)); --objid

              elsif v_job_class = 'BResPgmSrtDate' then
                 fetch v_cur into rt(1),rt(2),rt(3),v_req;
                 exit when v_cur%notfound;
                 v_event_code := '625';
                 v_rec_inserted :=  reset_pgm_stdate(rt(2), --esn
                                                     rt(1), --lid
                                                     rt(3));-- new_date
              elsif v_job_class = 'BDeacts' then
                 fetch v_cur into rt(1),rt(2),rt(3),rt(4),rt(5),rt(6),v_req;
                 exit when v_cur%notfound;
                 v_rec_inserted :=  deact_service(rt(1),--esn
                                                  rt(2),--min
                                                  rt(3),--reason
                                                  rt(4),--create ai
                                                  rt(5),--new_esn
                                                  rt(6));--same_min
              elsif v_job_class = 'BChargeBks' then
                 fetch v_cur into rt(1),rt(2),rt(3),v_req;
                 exit when v_cur%notfound;
                 v_rec_inserted :=  ins_chargeback(rt(1), --merch_no
                                                   rt(2), --reason
                                                   rt(3));--requestor
              elsif v_job_class = 'ContactEdit' then
                 fetch v_cur into rt(1),
                                  rt(2),
                                  rt(3),
                                  rt(4),
                                  rt(5),
                                  rt(6),
                                  rt(7),
                                  rt(8),
                                  rt(9),
                                  rt(10),
                                  rt(11),
                                  rt(12),
                                  rt(13),
                                  rt(14),
                                  rt(15),
                                  rt(16),
                                  rt(17),
                                  v_req;
                 exit when v_cur%notfound;
                 v_event_code := '605';
                 v_rec_inserted := update_contact(rt(1), --ipv_name varchar2,
                                                  rt(2), --ipv_address varchar2,
                                                  rt(3), --ipv_address2 varchar2,
                                                  rt(4), --ipv_city  varchar2,
                                                  rt(5), --ipv_state  varchar2,
                                                  rt(6), --ipv_zip varchar2,
                                                  rt(7), --ipv_zip2 varchar2,
                                                  rt(8), --ipv_country varchar2,
                                                  rt(9), --ipv_email varchar2,
                                                  rt(10), --ipv_homenumber varchar2,
                                                  rt(11), --ipv_ext_acct varchar2,
                                                  rt(12), --ipv_lid varchar)
                                                  rt(13), --ipv_shpaddress     -- CR22302 -- adding shipping address
                                                  rt(14), --ipv_shpaddress2    -- CR22302 -- adding shipping address
                                                  rt(15), --ipv_shpcity        -- CR22302 -- adding shipping address
                                                  rt(16), --ipv_shpstate       -- CR22302 -- adding shipping address
                                                  rt(17));--ipv_shpzip         -- CR22302 -- adding shipping address

              end if;
              if v_rec_inserted
              then
                  v_suc_cnt := v_suc_cnt+1;
              else
                  v_err_cnt := v_err_cnt+1;
                  ins_job_err(v_job_data_id,
                              v_job_class,
                              v_req,
                              g_err_msg);

              end if;
              if mod(v_suc_cnt,100) = 0 then
                 commit;
              end if;
          end loop; --RECS
          --dbms_output.enable;
          dbms_output.put_line('Total recs for job = '||v_job_rec_count);
          ---------------
          --Summarize
          ---------------
          if v_suc_cnt = v_job_rec_count then
             v_ret_code := 0;
          elsif v_err_cnt = v_job_rec_count then
             v_ret_code := 506;
          else
             v_ret_code := 503;
          end if;
          upd_jrd(v_job_objid,v_start_date,v_ret_code);
          if ( v_event_code is not null ) then
             if v_event_code = '624' then
               v_event_data:= 'Safelink Cooling Reset - TTl Processed: '||
                              v_job_rec_count||' Ttl Updated: '||v_suc_cnt;
             elsif v_event_code = '625' then
               v_event_data:= 'Safelink Reset PGM Start Date - TTl Processed: '||
                              v_job_rec_count||' Ttl Updated: '||v_suc_cnt;
             elsif v_event_code = '605' then
               v_event_data:= 'record count = '||
                              v_job_rec_count;

             end if;
             dbms_output.put_line('SRCE='||nvl(ip_srce_table,'x_job_run_details'));
             ins_sl_hist (v_job_data_id,
                          v_event_code,
                          v_event_data,
                          'BATCH_PROC',
                          'WEB',
                          v_ret_code,
                          nvl(ip_srce_table,'x_job_run_details'),
                          v_job_objid);

          end if;
          commit;
       end if; -- get_cursor
     exception
         when others then
          upd_jrd(v_job_objid,v_start_date,506);
         null;
     end;
  end loop;
  commit;
  dbms_output.put_line('Job complete');
end;
--------------------------------------------------------------------------
procedure vmbc_to_job_data(ip_requesttype in varchar2,
                           op_job_data_id out varchar2,
                           recs_processed out number ) is
--------------------------------------------------------------------------
begin
  --dbms_output.put_line('Entering into vmbc_to_job_data');
  if ip_requesttype not in ('vmbc-edit-contact','vmbc-request-to-job-data') then
    raise_application_error(-20001,'requesttype '||ip_requesttype||' not supported by apex_safelink package');
  end if;

  SELECT to_char(systimestamp,'yyyymmddhh24missff4')
  INTO op_job_data_id
  FROM DUAL;

  -- CR22302 Select Statement changed to insert Shipping address
  -- CR28715 Changed the way we generate XML.
  insert into x_job_data(JOB_DATA_ID,X_REQUEST_TYPE,X_REQUEST,ORDINAL)
  select op_job_data_id ,
         requesttype ,
        XMLELEMENT("request",
          XMLELEMENT("requestType", requesttype),
          XMLELEMENT("enrollRequest", enrollrequest),
          XMLELEMENT("state", state),
          XMLELEMENT("name", replace(name,'''','')),
          XMLELEMENT("dob", '1970-01-01'),
          XMLELEMENT("lid", lid),
          XMLELEMENT("zip", zip),
          XMLELEMENT("zip2", zip),
          XMLELEMENT("city", city),
          XMLELEMENT("address", regexp_replace(address,'box','B0X',1,0,'i')),
          XMLELEMENT("address2", nvl(address2,'')),
          XMLELEMENT("country", country),
          XMLELEMENT("shippingAddress", regexp_replace(x_shp_address,'box','B0X',1,0,'i')),
          XMLELEMENT("shippingAddress2", nvl(x_shp_address2,' ')),
          XMLELEMENT("shippingCity", x_shp_city),
          XMLELEMENT("shippingState", x_shp_state),
          XMLELEMENT("shippingZip", x_shp_zip),
          XMLELEMENT("homeNumber", nvl(homenumber,'')),
          XMLELEMENT("channelType", channeltype),
          XMLELEMENT("deenrollReason", decode(qualifyStatus,'L','D20','D00')),
          XMLELEMENT("ssn", '00000000'),
          XMLELEMENT("email", nvl(email,'')),
          XMLELEMENT("allowPrerecorded", allowprerecorded),
          XMLELEMENT("emailPref", nvl(emailpref,'')),
          XMLELEMENT("plan", 'Lifeline - '||state||' - '|| plan),
          XMLELEMENT("src_origin", 'VMBC'),
          XMLELEMENT("external_account", external_Account),
          XMLELEMENT("ref_fname", nvl(ref_fname,'')),
          XMLELEMENT("ref_lname", nvl(ref_lname,'')),
          XMLELEMENT("ref_lid", nvl(ref_lid,'')),
          XMLELEMENT("ref_min", nvl(ref_min,'')),
          XMLELEMENT("ref_status", nvl(ref_status,''))
        ) xml,0
  from  xsu_vmbc_request b
  where (requesttype = decode(ip_requesttype,'vmbc-edit-contact','ContactEdit','enroll')
       or requesttype = decode(ip_requesttype,'vmbc-edit-contact','ContactEdit','ProgramChange'))
  AND batchdate >(SELECT NVL(MAX(X_EVENT_DT),TRUNC(SYSDATE))
                 FROM x_sl_hist
                 WHERE lid=-1
                 AND x_esn IS NULL
                 AND x_event_code='605'
                 AND x_code_number=0
                 AND X_SRC_TABLE=ip_requesttype);
    --dbms_output.put_line('Entered vmbc_to_job_data Inserted rows:'||sql%rowcount);
 IF sql%rowcount > 0  THEN
     recs_processed := sql%rowcount;
    dbms_output.put_line ('Number of job queue rows inserted: ' ||sql%rowcount||' JOB_ID='||op_job_data_id);
             INSERT INTO sa.x_job_run_details(objid,
                                              job_data_id,
                                              x_priority,
                                              x_scheduled_run_date,
                                              x_actual_run_date,
                                              run_details2job_master,
                                              x_insert_date,
                                              x_status_code,
                                              owner_name,
                                              x_reason)
             SELECT sa.SEQ_X_job_run_details.nextval,
                    op_job_data_id,
                    10,
                    SYSDATE+1,
                    SYSDATE+1,
                    objid,
                    SYSDATE,
                    '501',
                    'BATCH_PROC',
                    'Autosys'
             FROM sa.x_job_master
             where x_job_name=decode(ip_requesttype,'vmbc-edit-contact',
                           'SL_CONTACT_EDIT','SL_ENROLL');

       --dbms_output.put_line ('Number of job_run_details inserted: ' ||sql%rowcount);
       commit;
       END IF;

  --dbms_output.put_line('End of vmbc_to_job_data');
exception
  when others then
   raise;
end;
--------------------------------------------------------------------------
procedure process_contact_edit is
--------------------------------------------------------------------------
v_job_data_id varchar2(50);
v_recs  number;
begin
  null;
      sa.ota_util_pkg.err_log (
        p_action => 'process_contact_edit',
			  p_error_date => sysdate,
			  p_key => null,
			  p_program_name => 'sa.apex_safelink.process_contact_edit',
        p_error_text => 'This record indicates this procedure have not done anything'
        );
  /*
  This Code has been commented and written with new logic in
  safelink_services_pkg.p_process_contactedit_job
  CR31300
  16-jan-2015
  */

  /*
  --dbms_output.put_line('Entered into process_contact_edit');
  vmbc_to_job_data('vmbc-edit-contact', v_job_data_id,v_recs);
  dbms_output.put_line('Recs processed = '||v_recs||' JID=>'||v_job_data_id||'<');
   if v_recs > 0 then
      runbatch(v_job_data_id,'vmbc-edit-contact');
   end if;
   --dbms_output.put_line('End of process_contact_edit');
   */
end;
end apex_safelink;
/