CREATE OR REPLACE PROCEDURE sa."MAINQCONSUMER" IS
--------------------------------------------------------------------------------------------
--$RCSfile: mainQconsumer.sql,v $
--$Revision: 1.12 $
--$Author: oimana $
--$Date: 2017/12/13 15:47:08 $
--$ $Log: mainQconsumer.sql,v $
--$ Revision 1.12  2017/12/13 15:47:08  oimana
--$ CR52234 - Added insert to log table for CLFY_MAIN_Q activity
--$
--$ Revision 1.10  2016/08/22 15:27:59  pamistry
--$ CR41473 - LRP2 Modify the procedure to set the priority for Event Queue
--$
--$ Revision 1.9  2016/02/08 04:39:00  aganesan
--$ Removed the payload log table from this procedure
--$
--$ Revision 1.8  2016/02/05 00:14:03  aganesan
--$ Included payload logging table.
--$
--$ Revision 1.7  2016/02/04 16:32:22  aganesan
--$ CR33098
--$
--$ Revision 1.5  2016/02/02 20:39:23  nmuthukkaruppan
--$ Review comments incorporated
--$
--$ Revision 1.4  2015/12/18 20:02:46  nmuthukkaruppan
--$ Adding Grants
--$
--$ Revision 1.3  2015/12/08 19:05:06  akhan
--$ added cvs header
--$
--------------------------------------------------------------------------------------------

  op_msg                  VARCHAR2(4000);
  qmsg                    sa.q_payload_t;
  qname                   VARCHAR2(400);
  tq                      VARCHAR2(300);
  ctr                     NUMBER := 0;
  MAX_MSG_COUNT           CONSTANT NUMBER := 10000;
  l_priority              NUMBER := 1;
  v_enqueued              BOOLEAN;
  v_bool                  BOOLEAN;

--CR52234 - Added insert to log table to debug and validate all consumers//OImana
PROCEDURE insert_log (i_esn        IN VARCHAR2,
                      i_min        IN VARCHAR2,
                      i_brand      IN VARCHAR2,
                      i_event_name IN VARCHAR2,
                      i_created_by IN VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  INSERT INTO sa.q_payload_log (esn           ,
                                min           ,
                                brand         ,
                                event_name    ,
                                created_by)
                        VALUES (i_esn         ,
                                i_min         ,
                                i_brand       ,
                                i_event_name  ,
                                i_created_by);
  COMMIT;
EXCEPTION
  WHEN others THEN
    ROLLBACK;
END;

BEGIN

  LOOP

    BEGIN

      IF NOT sa.QUEUE_PKG.dq (i_q_name     => 'SA.CLFY_MAIN_Q',
                              o_q_payload  => qmsg,
                              o_op_msg     => op_msg) THEN

         RAISE_APPLICATION_ERROR (-20001,op_msg);

      END IF;

      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        UTIL_PKG.insert_error_tab ('Reading queue: CLFY_MAIN_Q',
                                   qmsg.esn,
                                   'mainQconsumer',
                                   sqlerrm );
        EXIT;
    END;

    -- Logging messages
    BEGIN
      insert_log (i_esn        => qmsg.esn       ,
                  i_min        => qmsg.min       ,
                  i_brand      => qmsg.brand     ,
                  i_event_name => qmsg.event_name,
                  i_created_by => 'MAIN');
    END;

    BEGIN
      SELECT '"'||REPLACE(target_queues, ',', '","')||'"'
        INTO tq
        FROM sa.queue_routing_tbl
       WHERE UPPER(source_type)   = UPPER(qmsg.source_type)
         AND UPPER(source_tbl)    = UPPER(qmsg.source_tbl)
         AND UPPER(source_status) = UPPER(qmsg.source_status)
         AND step_complete        = qmsg.step_complete;
    EXCEPTION
      WHEN OTHERS THEN
        tq := '""';
        UTIL_PKG.insert_error_tab ('Routing table config error '||chr(10)||
                                   'source_type='    ||qmsg.source_type  ||chr(10)||
                                   'source_tbl='     || qmsg.source_tbl  ||chr(10)||
                                   'source_status='  ||qmsg.source_status||chr(10)||
                                   'step_complete='  ||qmsg.step_complete, '',
                                   'mainQconsumer',
                                   sqlerrm);
    END;

    FOR i IN (SELECT TRIM(column_value) cv
                FROM xmltable(tq)) LOOP

      qname := 'SA.CLFY_'||i.cv||'_Q';

      -- CR41473 08/17/2016 Setting lower priority for the loyalty event where the request coming from third party.
      IF i.cv = 'EVENT' AND qmsg.source_tbl = 'X_REWARD_REQUEST' THEN
        l_priority := 2;
      END IF;

      BEGIN

        IF NOT sa.QUEUE_PKG.enq (i_q_name     => qname,
                                 io_q_payload => qmsg,
                                 o_op_msg     => op_msg,
                                 ip_priority  => l_priority) THEN

          RAISE_APPLICATION_ERROR (-20001,op_msg);

        END IF;

        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          UTIL_PKG.insert_error_tab ('Writing queue:'||qname,
                                     qmsg.esn,
                                     'mainQconsumer',
                                     sqlerrm );

      END;

    END LOOP;

    ctr := ctr +1;

    EXIT WHEN ctr >= MAX_MSG_COUNT;

  END LOOP;

END mainQconsumer;
/