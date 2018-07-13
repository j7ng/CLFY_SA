CREATE OR REPLACE PROCEDURE sa."LOYALTYQCONSUMER" IS
/*******************************************************************************************************
  * --$RCSfile: loyaltyQconsumer.sql,v $
  --$Revision: 1.18 $
  --$Author: pamistry $
  --$Date: 2016/08/26 19:17:17 $
  --$ $Log: loyaltyQconsumer.sql,v $
  --$ Revision 1.18  2016/08/26 19:17:17  pamistry
  --$ CR41473 Production merge with 08 25 release CR41232
  --$
  --$ Revision 1.17  2016/08/22 15:42:45  pamistry
  --$ CR41473 - LRP Modify the procedure to call different procedure to reward points from Phase2
  --$
  --$ Revision 1.14  2016/06/09 21:58:20  smeganathan
  --$ CR42428 changed for QUEUED transaction, moved the statment
  --$
  --$ Revision 1.13  2016/02/09 18:26:35  smeganathan
  --$ CR33098 LRP new object
  --$
  * Description: This Procedure dequeues events queue, does validation and calls
  * event processing procedure in rewards_mgt_util package
  * -----------------------------------------------------------------------------------------------------
*********************************************************************************************************/
  --Local variables
  ln_error_code      NUMBER                       ;
  ln_action_type     VARCHAR2(20)                 ;
  lv_err_msg         VARCHAR2(1000)               ;
  lv_error_message   VARCHAR2 (2000)              ;
  lv_x_reason        VARCHAR2 (500)               ;
  dequeue_options    dbms_aq.dequeue_options_t    ;
  message_properties dbms_aq.message_properties_t ;
  payload_rec        q_payload_t                  ;
  q_name             queue_type_tbl.Q_NAME%TYPE   ;
  message_handle     RAW(16)                      ;
  op_msg             VARCHAR2(400)                ;
  ctr                NUMBER := 0;
  max_to_process     CONSTANT NUMBER := 10000;
  c_action_type      VARCHAR2(100);

PROCEDURE insert_lrp_log ( i_esn             IN VARCHAR2      ,
                              i_min             IN VARCHAR2      ,
                              i_brand           IN VARCHAR2      ,
                              i_event_name      IN VARCHAR2      ,
                              i_created_by      IN VARCHAR2      ) IS
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

  --
BEGIN --Main Section
	--
    ln_error_code                 := 0                  ;
    lv_error_message              := 'Success'          ;
    --dequeue_options.msgid         := descr.msg_id       ;
    dequeue_options.dequeue_mode  := DBMS_AQ.REMOVE     ;
    --dequeue_options.consumer_name := descr.consumer_name;
    LOOP
      BEGIN
        IF NOT queue_pkg.dq( i_q_name         => 'SA.CLFY_EVENT_Q' ,
                              o_q_payload      => payload_rec       ,
                              o_op_msg         => lv_error_message  ,
                              i_consumer_name  => 'LOYALTY'         ,
                              i_dq_mode        => 'REMOVE' )
        THEN
          util_pkg.insert_error_tab('Not reading queue: CLFY_EVENT_Q',
                                    payload_rec.esn,
                                    'loyaltyQconsumer',
                                    lv_error_message );
          raise_application_error(-20001,op_msg);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          util_pkg.insert_error_tab('Reading queue: CLFY_EVENT_Q',
                                    payload_rec.esn,
                                    'loyaltyQconsumer',
                                    sqlerrm );
          EXIT;
      END;

      -- Logging messages
      BEGIN
       insert_lrp_log ( i_esn            => payload_rec.esn           ,
                        i_min            => payload_rec.min           ,
                        i_brand          => payload_rec.brand         ,
                        i_event_name     => payload_rec.event_name    ,
                        i_created_by     => 'LOYALTYQCONSUMER-DQ'     );
      END;

      c_action_type := NULL;

      --
      FOR i IN payload_rec.nameval.FIRST..payload_rec.nameval.LAST
      LOOP
        IF payload_rec.nameval(i).fld = 'ACTION_TYPE'  AND
           payload_rec.nameval(i).val = '401'
        THEN
          -- Added logic for CR41232 to ignore queued cards
          c_action_type := payload_rec.nameval(i).val; -- '401'
          --payload_rec.nameval(i).val  :=  '6' ;
          --payload_rec.event_name      :=  'REDEMPTION';
        END IF;
        --
      END LOOP;

	  -- Added logic for 41232 to ignore queued cards
      IF c_action_type = '401' THEN
        -- skip current iteration
        CONTINUE;
      END IF;

      -- Test ending
      IF payload_rec.brand = 'STRAIGHT_TALK'
      THEN --Condition to check whether brand is 'STRAIGHT_TALK'
        FOR i IN payload_rec.nameval.FIRST..payload_rec.nameval.LAST
        LOOP
          IF payload_rec.nameval(i).fld    = 'ACTION_TYPE' THEN
             ln_action_type               := payload_rec.nameval(i).val;
          ELSIF payload_rec.nameval(i).fld = 'X_REASON' THEN
             lv_x_reason                  := payload_rec.nameval(i).val;
          END IF;
        --
        END LOOP;
        --

        -- Logging messages
        BEGIN
         insert_lrp_log ( i_esn            => payload_rec.esn           ,
                          i_min            => payload_rec.min           ,
                          i_brand          => payload_rec.brand         ,
                          i_event_name     => payload_rec.event_name    ,
                          i_created_by     => 'LOYALTYQCONSUMER-BEFOREVPROC' );
        END;

        IF payload_rec.source_tbl = 'X_REWARD_REQUEST' then
            -- Calling the process reward request procedure.   -- CR41473 LRP2 call different procedure for rewarding points.
            sa.rewards_mgt_util_pkg.p_process_reward_request(in_event     => payload_rec     ,
                                                             out_err_code => ln_error_code   ,
                                                             out_err_msg  => lv_error_message
                                                             );
        else
          IF ((ln_action_type   = 1 ) OR
             -- (ln_action_type = 6  AND upper(lv_x_reason) IN ('REDEMPTION', 'BYOP REGISTER')) OR
              (ln_action_type = 6  AND payload_rec.event_name IN ('REDEMPTION', 'BYOP REGISTER')AND
              (NVL(UPPER(lv_x_reason),'XX') NOT IN ('COMPENSATION')) ) OR
              (ln_action_type IN (2,3)))
          THEN

            -- Calling the event processing procedure.
            sa.rewards_mgt_util_pkg.p_event_processing(in_event     => payload_rec     ,
                                                       out_err_code => ln_error_code   ,
                                                       out_err_msg  => lv_error_message
                                                       );

          ELSIF  (ln_action_type   = 'ENROLLED' AND lv_x_reason <> 'AWOP') THEN -- Activation (with PIN)

            -- Calling the event processing procedure.
            sa.rewards_mgt_util_pkg.p_event_processing( in_event     => payload_rec     ,
                                                        out_err_code => ln_error_code   ,
                                                        out_err_msg  => lv_error_message
                                                       );
          --
          END IF;
        END IF;
        -- Logging messages
        BEGIN
         insert_lrp_log ( i_esn            => payload_rec.esn           ,
                          i_min            => payload_rec.min           ,
                          i_brand          => payload_rec.brand         ,
                          i_event_name     => payload_rec.event_name    ,
                          i_created_by     => 'LOYALTYQCONSUMER-AFTEREVPROC' );
        END;

         --
      END IF;
      --
	  ctr := ctr + 1;
	  --
	  EXIT WHEN ctr >= max_to_process;
    END LOOP;
    --
EXCEPTION
  --
  WHEN OTHERS THEN
    lv_err_msg := SQLCODE;
    lv_err_msg := SQLERRM;
    DBMS_OUTPUT.PUT_LINE('SQLCODE: '||lv_err_msg||'SQLERRM: '||lv_err_msg);
    util_pkg.insert_error_tab( i_action       => 'MAIN EXCEPTION: loyaltyQconsumer',
                               i_key          =>  payload_rec.esn,
                               i_program_name => 'loyaltyQconsumer',
                               i_error_text   => SUBSTR(SQLERRM,1,200));
    --
END loyaltyQconsumer;
/