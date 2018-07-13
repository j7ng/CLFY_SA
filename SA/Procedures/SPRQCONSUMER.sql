CREATE OR REPLACE PROCEDURE sa."SPRQCONSUMER" is
--------------------------------------------------------------------------------------------
--$RCSfile: sprQconsumer.sql,v $
--$Revision: 1.19 $
--$Author: skota $
--$Date: 2017/03/22 15:12:55 $
--$ $Log: sprQconsumer.sql,v $
--$ Revision 1.19  2017/03/22 15:12:55  skota
--$ Increased the error message size, which is causing failure in update pcrf subscriber
--$
--$ Revision 1.18  2017/02/21 17:32:31  skota
--$ Modified UPDATE PCRF LOGIC
--$
--$ Revision 1.17  2016/08/16 20:17:23  jpena
--$ Handle error logging for invalidate nameval attributes in consumer.
--$
--$ Revision 1.15  2016/06/09 21:27:15  jpena
--$ Changes to use new prcr log tables to control duplicate processing.
--$
--$ Revision 1.12  2016/05/09 14:45:34  jpena
--$ Add rollback on failures.
--$
--$ Revision 1.11  2016/03/14 15:29:27  skota
--$ Modified the CT Reason
--$
--$ Revision 1.10  2016/02/08 20:44:34  jpena
--$ Modify logging on q_payload
--$
--$ Revision 1.9  2016/02/08 04:39:42  aganesan
--$ Removed the payload log table from this procedure
--$
--$ Revision 1.8  2016/02/05 00:14:03  aganesan
--$ Included payload logging table.
--$
--$ Revision 1.7  2016/02/04 16:37:06  aganesan
--$ CR33098
--$
--$ Revision 1.5  2016/02/02 20:37:38  nmuthukkaruppan
--$ Review comments incorporated
--$
--$ Revision 1.4  2015/12/18 20:06:11  nmuthukkaruppan
--$ Adding Grants
--$
--$ Revision 1.3  2015/12/08 19:05:23  akhan
--$ added cvs header
--$
--------------------------------------------------------------------------------------------

  queue_msg           sa.q_payload_t;
  n_err_code          NUMBER;
  c_err_msg           VARCHAR2(2000);
  n_ctr               NUMBER := 0;
  n_max_to_process    CONSTANT NUMBER := 10000;
  c_action_type       table_x_call_trans.x_action_type%type;
  c_reason            table_x_call_trans.x_reason%type;
  c_sourcesystem      table_x_call_trans.x_sourcesystem%type;
  n_call_trans_objid  NUMBER;
  c_event             VARCHAR2(50);
  c_event_addl_info   VARCHAR2(50);
  c_msg               VARCHAR2(300);
  --
  cpl ct_pcrf_log_type := ct_pcrf_log_type();
  cp  ct_pcrf_log_type := ct_pcrf_log_type();

PROCEDURE insert_log ( i_esn        IN VARCHAR2 ,
                       i_min        IN VARCHAR2 ,
                       i_brand      IN VARCHAR2 ,
                       i_event_name IN VARCHAR2 ,
                       i_created_by IN VARCHAR2 ) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  INSERT
  INTO   sa.q_payload_log
         ( esn           ,
           min           ,
           brand         ,
           event_name    ,
           created_by
         )
  VALUES
  ( i_esn                           ,
    i_min                           ,
    i_brand                         ,
    i_event_name                    ,
    i_created_by
  );
  COMMIT;
EXCEPTION
   WHEN others THEN
     ROLLBACK;
END;

PROCEDURE insert_error_log ( i_esn           IN VARCHAR2    ,
                             i_min           IN VARCHAR2    ,
                             i_event_name    IN VARCHAR2    ,
                             i_error_text    IN VARCHAR2    ,
                             i_queue_message IN q_payload_t ) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  INSERT
  INTO   sa.x_payload_error_log
         ( esn           ,
           min           ,
           event_name    ,
           error_text    ,
           queue_message
         )
  VALUES
  ( i_esn                           ,
    i_min                           ,
    i_event_name                    ,
    i_error_text                    ,
    i_queue_message
  );
  COMMIT;
 EXCEPTION
   WHEN others THEN
     ROLLBACK;
END;

BEGIN

  LOOP

    -- wrapping entire loop section to trap errors and allow other messages to get dequeued
    BEGIN

      BEGIN
        IF NOT queue_pkg.dq ( i_q_name     => 'SA.CLFY_SPR_Q',
                              o_q_payload  => queue_msg           ,
                              o_op_msg     => c_msg          )
        THEN
          -- rollback changes whenever an error occurred
          ROLLBACK;
          --
          RAISE_APPLICATION_ERROR ( -20001, c_msg );
        END IF;
        --
        COMMIT;
        --
       EXCEPTION
         WHEN OTHERS THEN
           util_pkg.insert_error_tab ( i_action       => 'READING QUEUE: CLFY_SPR_Q',
                                       i_key          => queue_msg.esn,
                                       i_program_name => 'sprQconsumer',
                                       i_error_text   => SQLERRM );

      END;

      -- only enter logic when the nameval attributes are populated correctly
      IF queue_msg.nameval IS NULL THEN
        -- insert error and queue message in sa.x_payload_error_log
        insert_error_log ( i_esn           => queue_msg.esn        ,
                           i_min           => queue_msg.min        ,
                           i_event_name    => queue_msg.event_name ,
                           i_error_text    => 'NAMEVAL ATTRIBUTES NOT FOUND' ,
                           i_queue_message => queue_msg            );

        -- skip current row and do not enqueue incorrect message in CLFY_MAIN_Q once again
        CONTINUE;
        --
      END IF;

      -- set variables coming from queue message
      FOR i IN 1..queue_msg.nameval.COUNT
      LOOP
        IF queue_msg.nameval(i).fld = 'ACTION_TYPE' THEN
          c_action_type := queue_msg.nameval(i).val;
        ELSIF queue_msg.nameval(i).fld = 'X_REASON' THEN
          c_reason :=  queue_msg.nameval(i).val;
        ELSIF queue_msg.nameval(i).fld = 'SOURCESYSTEM' THEN
          c_sourcesystem :=  queue_msg.nameval(i).val;
        ELSIF queue_msg.nameval(i).fld = 'CT_OBJID' THEN
          n_call_trans_objid :=  queue_msg.nameval(i).val;
        END IF;
      END LOOP;

      -- Logging messages
      BEGIN
        insert_log ( i_esn        => queue_msg.esn        ,
                     i_min        => queue_msg.min        ,
                     i_brand      => queue_msg.brand      ,
                     i_event_name => queue_msg.event_name ,
                     i_created_by => 'SPR'           );
      END;

      -- reset types
      cpl  := ct_pcrf_log_type ();
      cp   := ct_pcrf_log_type ();

      IF NOT cpl.exist ( i_call_trans_objid => n_call_trans_objid )  -- avoid duplicate execution of the update_pcrf_subscriber
      THEN

        -- call update pcrf to take actions on spr and pcrf
        BEGIN
          --
          update_pcrf_subscriber ( i_esn                 => queue_msg.esn,
                                   i_action_type         => c_action_type,
                                   i_reason              => c_reason,
                                   i_prgm_purc_hdr_objid => NULL,
                                   i_src_program_name    => 'TRG_CT',
                                   i_sourcesystem        => c_sourcesystem,
                                   o_error_code          => n_err_code,
                                   o_error_msg           => c_err_msg ,
                                   i_call_trans_objid    => n_call_trans_objid );

		  IF n_err_code = 0 then
		     -- log the pcrf call trans log
             cp := cpl.ins ( i_call_trans_objid => n_call_trans_objid );
		  END IF;

        EXCEPTION
           WHEN others THEN
             NULL;
        END;

      END IF; -- IF NOT cpl.exist ( i_call_trans_objid => n_call_trans_objid ) ....

      --
      queue_msg.step_complete  := 'SPR';

      -- put it back in the queue
      BEGIN
        IF NOT queue_pkg.enq ( i_q_name     => 'SA.CLFY_MAIN_Q',
                               io_q_payload => queue_msg,
                               o_op_msg     => c_msg)
        THEN
          -- rollback changes whenever an error occurred
          ROLLBACK;
          RAISE_APPLICATION_ERROR ( -20001, c_msg );
        END IF;
        -- save changes
        COMMIT;
       EXCEPTION
         WHEN OTHERS THEN
           util_pkg.insert_error_tab ( i_action       => 'ERROR WRITING: CLFY_MAIN_Q',
                                       i_key          => queue_msg.esn,
                                       i_program_name => 'sprQconsumer',
                                       i_error_text   => SQLERRM );
      END;

     EXCEPTION
       WHEN others THEN
         -- insert unhandled errors and queue message in sa.x_payload_error_log
         insert_error_log ( i_esn           => queue_msg.esn        ,
                            i_min           => queue_msg.min        ,
                            i_event_name    => queue_msg.event_name ,
                            i_error_text    => 'UNHANDLED EXCEPTION READING SA.CLFY_SPR_Q: ' || SQLERRM ,
                            i_queue_message => queue_msg            );

    END;

    n_ctr := n_ctr + 1;

    EXIT WHEN n_ctr >= n_max_to_process;

  END LOOP;
END;
/