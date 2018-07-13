CREATE OR REPLACE trigger sa.TRIG_X_JOB_RUN_DETAILS after
insert or update on sa.x_job_run_details referencing old as old new as new
for each row
declare
  ------------------------------------------------------------------------------
  -- VARIABLES -----------------------------------------------------------------
  ------------------------------------------------------------------------------
  v_log_msg   x_sl_hist.x_event_data%type := null; -- (300 char max)
  ------------------------------------------------------------------------------
  -- INSERT SL HISTORY PROC ----------------------------------------------------
  ------------------------------------------------------------------------------
  procedure ins_sl_hist(n_lid           x_sl_hist.lid%type,
                        v_esn           x_sl_hist.x_esn%type,
                        d_event_dt      x_sl_hist.x_event_dt%type,
                        d_insert_dt     x_sl_hist.x_insert_dt%type,
                        v_event_value   x_sl_hist.x_event_value%type,
                        n_event_code    x_sl_hist.x_event_code%type,
                        v_event_data    x_sl_hist.x_event_data%type,
                        v_min           x_sl_hist.x_min%type,
                        v_username      x_sl_hist.username%type,
                        v_sourcesystem  x_sl_hist.x_sourcesystem%type,
                        v_code_number   x_sl_hist.x_code_number%type,
                        v_src_table     x_sl_hist.x_src_table%type,
                        n_src_objid     x_sl_hist.x_src_objid%type)
  as
  begin
    insert into sa.x_sl_hist
      (objid,
       lid,
       x_esn,
       x_event_dt,
       x_insert_dt,
       x_event_value,
       x_event_code,
       x_event_data,
       x_min,
       username,
       x_sourcesystem,
       x_code_number,
       x_SRC_table,
       x_SRC_objid)
    values
      (sa.SEQ_X_SL_HIST.nextval,
       n_lid,
       v_esn,
       d_event_dt,
       d_insert_dt,
       v_event_value,
       n_event_code,
       v_event_data,
       v_min,
       v_username,
       v_sourcesystem,
       v_code_number,
       v_src_table,
       n_src_objid);

  end ins_sl_hist;
  ------------------------------------------------------------------------------
  -- CHECK USER FUNC -----------------------------------------------------------
  ------------------------------------------------------------------------------
  function approved(ipv_approver_name varchar2, ipv_owner_name varchar2, ipn_objid varchar2 default null)
  return boolean
  as
  v_db_user varchar2(30);
  begin
    if ipv_approver_name is not null then

      select user
      into   v_db_user
      from   dual;

      if (v_db_user = ipv_approver_name) or (ipv_owner_name = ipv_approver_name) then
        return false;
      else
        return true;
      end if;

    else
      return true;
    end if;


  end approved;
  ------------------------------------------------------------------------------
  -- GET JOB CLASS FUNC --------------------------------------------------------
  ------------------------------------------------------------------------------
  function get_job_class(n_objid x_job_master.objid%type)
  return varchar2
  as
    v_jc x_job_master.x_job_class%type := null;
  begin
    select x_job_class
    into   v_jc
    from   sa.x_job_master
    where (x_job_sourcesystem = 'SAFELINK' or objid=1100020)
    and    objid = n_objid;
    return v_jc;
  exception
    when others then
      return v_jc;
  end get_job_class;
--------------------------------------------------------------------------------
-- MAIN BODY -------------------------------------------------------------------
--------------------------------------------------------------------------------
begin
  if inserting or updating then
      -- IF IT'S A SAFELINK JOB, LOG THE HIST INFORMATION
      v_log_msg := get_job_class(:new.run_details2job_master);
    if v_log_msg is not null then
      -- IF INSERT IS TO CHANGE STATUS TO APPROVAL
      if :new.x_status_code = 501 then
        -- IF THE USER IS ATTEMPTING TO APPROVE THEIR OWN TRANSACTION
        if not approved(:new.approved_by,:new.owner_name,:new.objid) then
          raise_application_error (-20111,'USER NOT AUTHORIZED TO APPROVE THIS JOB');
        else
          -- IF APPROVED BY PASSES
          v_log_msg := v_log_msg||' - APPROVED BY:'||nvl(:new.approved_by,'SYSTEM')||' - APPROVED DATE: '||sysdate;
        end if;
      end if;
      -- NOTE: NEED TO FIND OUT SPECIFICALLY THE COLUMN ENTRIES BELOW TO COMPLETE
      ins_sl_hist(-1, -- system
                  null, -- NO LID
                  sysdate,
                  sysdate,
                  :new.job_data_id,
                  601, -- BPr job
                  v_log_msg,
                  null, -- NO MIN
                  :new.owner_name,
                  'WEB',
                  :new.x_status_code,
                  'x_job_run_details',
                  :new.objid);
    end if;
  end if;
exception
  when others then
    if sqlcode = -20111 then
      raise;
    else
      raise_application_error (-20100,SUBSTR('Audit Error in TRIG_X_JOB_RUN_DETAILS when inserting into SL_HIST -  '||SQLERRM,1,255));
    end if;
end;
/