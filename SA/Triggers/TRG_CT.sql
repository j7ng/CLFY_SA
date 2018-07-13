CREATE OR REPLACE TRIGGER sa."TRG_CT" AFTER
INSERT OR UPDATE
ON sa.TABLE_X_CALL_TRANS REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
--------------------------------------------------------------------------------------------
   --$RCSfile: trg_ct.sql,v $
   --$Revision: 1.9 $
   --$Author: oimana $
   --$Date: 2017/12/13 15:43:56 $
   --$ $Log: trg_ct.sql,v $
   --$ Revision 1.9  2017/12/13 15:43:56  oimana
   --$ CR52234 - Trigger for CT
   --$
   --$ Revision 1.7  2017/11/30 23:50:50  skota
   --$ Modified for CR53511
   --$
   --$ Revision 1.6  2017/11/20 20:40:38  oimana
   --$ CR52234 - Correct a detail from previous versions
   --$
   --$ Revision 1.4  2016/10/14 14:02:45  vlaad
   --$ Added condition for not firing triggers for Go Smart Migration
   --$
   --$ Revision 1.3  2016/07/05 19:25:24  jpena
   --$ Use new priority function
   --$
   --$ Revision 1.11  2016/03/29 13:55:13  akhan
   --$ Added code to by pass safelink load
   --$
   --------------------------------------------------------------------------------------------
DECLARE

  c_msg                VARCHAR2(4000);
  pl                   q_payload_t;
  ctr                  NUMBER := 0;
  c_event              VARCHAR2(20);
  nv                   q_nameval_tab := q_nameval_tab();
  n_seconds_delay      NUMBER;
  c_bypass_brand_flag  VARCHAR2(1) := 'N';
  n_priority           NUMBER(2) := 1;
  n_upd_delay          NUMBER(2) := 0;

BEGIN

  -- Go Smart changes
  -- Do not fire trigger if global variable is turned off
  IF NOT sa.GLOBALS_PKG.g_run_my_trigger THEN
    RETURN;
  END IF;
  -- End Go Smart changes

  -- filter out conditions
  IF UPPER(:NEW.x_result) = 'COMPLETED'  -- only completed call transactions
       AND :NEW.x_min NOT LIKE 'T%'      -- exclude temporary mins
       AND :NEW.x_min IS NOT NULL        -- exclude when min is not present
       AND :NEW.x_service_id IS NOT NULL -- exclude when esn is not present
  THEN

    -- START BYPASS BRAND for running safelink load
    BEGIN
      SELECT 'Y'
        INTO c_bypass_brand_flag
        FROM sa.table_x_parameters
       WHERE x_param_name = 'BRAND_INCLUDED_FROM_SPR:FALSE'
         AND INSTR(x_param_value,:NEW.x_sub_sourcesystem) > 0;
    EXCEPTION
      WHEN others THEN
        c_bypass_brand_flag := 'N';
    END;

    -- return when safelink job is running
    IF NVL(c_bypass_brand_flag,'N') = 'Y' THEN
      RETURN;
    END IF;

    -- set the event name based on action type
    SELECT DECODE(:NEW.x_action_type,
                  '1', 'ACTIVATION',
                  '2', 'DEACTIVATION',
                  '3', 'REACTIVATION',
                  '6', 'REDEMPTION',
                  :NEW.x_action_text)
      INTO c_event
      FROM dual;

    -- set the named attribute values:
    -- CR52234 - corrected value for x_sourcesystem name value to SOURCESYSTEM
    sa.queue_pkg.add_nameval_elmt ('ACTION_TYPE',    :new.x_action_type,  nv);
    sa.queue_pkg.add_nameval_elmt ('REASON_CODE',    :new.x_reason,       nv);
    sa.queue_pkg.add_nameval_elmt ('SOURCESYSTEM',   :new.x_sourcesystem, nv);
    sa.queue_pkg.add_nameval_elmt ('CT_OBJID',       :new.objid,          nv);
    sa.queue_pkg.add_nameval_elmt ('X_ACTION_TEXT',  :new.x_action_text,  nv);
    sa.queue_pkg.add_nameval_elmt ('X_REASON',       :new.x_reason,       nv);

    -- form the payload type values
    pl := q_payload_t ('CT',                     -- source_type
                       'CT',                     -- source_tbl
                       'COMPLETE',               -- source_status
                       :new.x_service_id,        -- esn
                       :new.x_min,               -- min
                       :new.x_sub_sourcesystem,  -- brand
                       c_event,                  -- event_name
                       nv,                       -- varray
                       'INIT' );                 -- step_complete

    n_seconds_delay := 0;

    -- CR39782 set the seconds delay for DEACTIVATION, REACTIVATION and QUEUED transactions
    IF (:NEW.x_action_type IN('2','3','401')) THEN

      BEGIN
        SELECT TO_NUMBER(x_param_value) * 60
          INTO n_seconds_delay
          FROM sa.table_x_parameters
         WHERE x_param_name = 'PREACTIVATION_SPR_DELAY';
      EXCEPTION
        WHEN OTHERS THEN
          n_seconds_delay := 600;
      END;

    -- CR53511 set the seconds delay for REDEMPTION transactions
    ELSIF (:NEW.x_action_type = '6') THEN

      -- CR52234 - delay updates 5 seconds to indentify records between insert and update for RTC queueing.
      IF UPDATING THEN
        n_upd_delay := 5;
      END IF;

      BEGIN
        SELECT (TO_NUMBER(x_param_value) * 60) + n_upd_delay
          INTO n_seconds_delay
          FROM sa.table_x_parameters
         WHERE x_param_name = 'REDEMPTION_SPR_DELAY';
       EXCEPTION
         WHEN OTHERS THEN
           n_seconds_delay := 0;
       END;

    END IF;

    -- get the priority based on the cos value
    n_priority := get_queue_priority (i_esn => :NEW.x_service_id);

    -- enqueue the transaction into the main queue
    BEGIN
      --
      IF NOT (sa.QUEUE_PKG.enq (i_q_name     => 'SA.CLFY_MAIN_Q',
                                io_q_payload => pl,
                                o_op_msg     => c_msg,
                                ip_delay     => n_seconds_delay,
                                ip_priority  => n_priority)) THEN
        -- log an error
        UTIL_PKG.insert_error_tab (i_action       => 'Writing queue: CLFY_MAIN_Q',
                                   i_key          => pl.esn,
                                   i_program_name => 'tr_ct',
                                   i_error_text   => c_msg);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- log an error
        UTIL_PKG.insert_error_tab (i_action       => 'Writing queue: CLFY_MAIN_Q',
                                   i_key          => pl.esn  ,
                                   i_program_name => 'tr_ct' ,
                                   i_error_text   => sqlerrm );
    END;

  END IF;

END;
/