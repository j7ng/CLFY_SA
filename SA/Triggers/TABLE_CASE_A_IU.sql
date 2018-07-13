CREATE OR REPLACE TRIGGER sa."TABLE_CASE_A_IU"
   AFTER INSERT OR UPDATE OF x_case_type, title, casests2gbst_elm
   ON sa.TABLE_CASE    FOR EACH ROW
/************************************************************************************************
|    COPYRIGHT   TRACFONE  WIRELESS INC. ALL RIGHTS RESERVED
|
| PURPOSE  : CONTROL THE PART REQUEST STATUS BASED ON CASE STATUS
| FREQUENCY:
| PLATFORMS:
|
| REVISIONS:
| VERSION  DATE        WHO              PURPOSE
| -------  ---------- -----             ------------------------------------------------------
| 1.0      10/27/06   NATALIO GUADA    INITIAL REVISION
| 1.1      11/10/06   NATALIO GUADA     CR5569 INCOMPLETE STATUS ADDED
| 1.2      11/28/06   NATALIO GUADA     CR5569 DUPLICATES REMOVED (RELEASE VERSION)
| 1.4      01/05/06   NATALIO GUADA     CR5569 CHANGES REMOVED
| 1.5      06/08/07   Cosmin Ioan      CR6073 Accessories Automation
                                 Can't reprocess cases with multiple parts defect - Fixed
| 1.6      06/11/07   Cosmin Ioan      Fixed another defect for CR6073
                                 Get unique part numbers based on the insert date if attached to the same part class
/************************************************************************************************/
/*New Structure
/* 1.1      08/21/07   NATALIO GUADA    CR6241 Clean ESN data for refurb and undeliverables
/* 1.2      11/06/09   NATALIO GUADA    CR12155 ST_BUNDLE_III
/* 1.3-1.4  11/16/09   NATALIO GUADA    CR12155 ST_BUNDLE_III
/*
/* new structure cvs
/*  1.2      08/20/2010  NATALIO GUADA CR13581 B2B
/*  1.3      09/14/2010  NATALIO GUADA CR13581 B2B
/*  1.8      11/07/2013  YRIELIS MILLAN CR24827  MERGE production with 1.7
|************************************************************************************************/
BEGIN

dbms_output.put_line('Rahul in Trig');

   IF :NEW.title = 'Business Sales Direct Shipment' OR
      :NEW.title =  'Business Sales Service Shipment' THEN

      DECLARE
         l_action                     VARCHAR2 (80);
         l_req_status                 VARCHAR2 (80);
         l_req_objid                  NUMBER;
         l_part_number                VARCHAR2 (80);
         ship_overwrite               NUMBER                           := 0;
         ff_code                      VARCHAR2 (80);
         esn_received                 number:=0;

         CURSOR action_cur
         IS
            SELECT ELM.S_TITLE new_case_status,  INT.x_action
              FROM table_x_case_conf_hdr hdr,
                   table_x_case_conf_int INT,
                   table_gbst_elm elm
             WHERE hdr.x_case_type = :NEW.x_case_type
               AND hdr.x_title = :NEW.title
               AND hdr.x_warehouse = 1
               AND INT.conf_int2conf_hdr = hdr.objid
               AND INT.x_status = elm.title
               AND elm.objid = :NEW.casests2gbst_elm
               AND INT.x_active = 1;

         --CR6241 START - nguada 08/21/2007
         --CR31107 added x_part_inst_status to cursor 2/25/2015
         CURSOR cur_returned_esns is
          select objid, x_part_inst_status from table_part_inst where part_serial_no in
          (select x_part_serial_no from table_x_part_request
           where request2case = :NEW.objid
           and x_status IN ('SHIPPED', 'PROCESSED')
           and x_part_num_domain = 'PHONES'
           and x_part_serial_no is not null)
           and x_domain = 'PHONES';

           --CR31107 added phone part inst to add its x_part_inst_status to cursor 2/25/2015
          CURSOR cur_reserved_line is
          select line.objid, line.x_part_inst_status,line.part_to_esn2part_inst, phone.x_part_inst_status phone_status
          from table_part_inst line,
            table_part_inst phone
          where line.part_serial_no = nvl(:NEW.x_min,0)
          and line.x_domain = 'LINES'
          and phone.objid = line.part_to_esn2part_inst;

         --CR6241 END

         CURSOR part_request_cur
         IS
            SELECT *
              FROM table_x_part_request
             WHERE request2case = :NEW.objid
               AND x_status NOT IN ('CANCEL_REQUEST'); -- Active Records


      --CR6073
         CURSOR ff_center_curs (status_objid NUMBER, ff_code VARCHAR2)
         IS
            SELECT   x_ff_code
                FROM table_x_ff_center, table_gbst_elm
               WHERE x_status_exception = table_gbst_elm.title
                 AND x_ff_code <> ff_code
                 AND table_gbst_elm.objid = status_objid
            ORDER BY x_ranking ASC;

         ff_center_rec                ff_center_curs%ROWTYPE;
      BEGIN
      dbms_output.put_line('Rahul after begin before if ');
         IF        (:NEW.objid IS NOT NULL)
               AND (NVL (:OLD.casests2gbst_elm, 0) <> :NEW.casests2gbst_elm)
            OR (NVL (:OLD.x_case_type, 'x') <> :NEW.x_case_type)
            OR (NVL (:OLD.title, 'x') <> :NEW.title)
         THEN
     dbms_output.put_line('Rahul before action rec '||:NEW.casests2gbst_elm);
            FOR action_rec IN action_cur
            LOOP
               l_action := action_rec.x_action;
        dbms_output.put_line('Rahul 2 in if l_action '||l_action );
               FOR part_request_rec IN part_request_cur
               LOOP

                  OPEN ff_center_curs (:NEW.casests2gbst_elm,
                                       part_request_rec.x_ff_center
                                      );

                  FETCH ff_center_curs
                   INTO ff_center_rec;

                  IF ff_center_curs%FOUND
                  THEN
                     ship_overwrite := 1;
                     ff_code := ff_center_rec.x_ff_code;
                  END IF;

                  CLOSE ff_center_curs;

                  l_req_status := part_request_rec.x_status;
                  l_req_objid := part_request_rec.objid;
        dbms_output.put_line('Rahul 2 in Trig l_req_status '||l_req_status||' l_req_objid '||l_req_objid );
                  IF l_action = 'PROCESS'
                  THEN
                     IF l_req_status IN ('ONHOLD', 'INCOMPLETE')
                     THEN
                        --Move to Pending
                        UPDATE table_x_part_request
                           SET x_status = 'PENDING',
                               x_ff_center =
                                    DECODE (ship_overwrite,
                                            0, x_ff_center,
                                            ff_code
                                           ),
                               x_last_update_stamp = SYSDATE
                         WHERE objid = l_req_objid;
                     END IF;
                  END IF;

                  IF l_action = 'RELEASE ST'
                  THEN
                     IF l_req_status IN ('ONHOLDST')
                     THEN
                        --Move to Pending
                        UPDATE table_x_part_request
                           SET x_status = 'PENDING',
                               x_ff_center =
                                    DECODE (ship_overwrite,
                                            0, x_ff_center,
                                            ff_code
                                           ),
                               x_last_update_stamp = SYSDATE
                         WHERE objid = l_req_objid;
                     END IF;
                  END IF;


                  IF l_action = 'CANCEL'
                  THEN
                     IF l_req_status IN ('ONHOLDST','PENDING', 'ONHOLD', 'INCOMPLETE')
                     THEN
                        --Move to Cancel Request
                        UPDATE table_x_part_request
                           SET x_status = 'CANCEL_REQUEST',
                               x_last_update_stamp = SYSDATE
                         WHERE objid = l_req_objid;
                     END IF;
                  END IF;

                  IF l_action = 'HOLD'
                  THEN
                     IF l_req_status = 'PENDING'  or part_request_rec.x_status = 'INCOMPLETE' then
                        --Move to ONHOLD
                        --CR56660 The Air Bill ( accessory ) line should be updated to CANCELLED.
                        --CR56660 When a case status is updated to Back Order
                        if action_rec.new_case_status = 'BACK ORDER' and
                           part_request_rec.x_part_num_domain = 'ACC'
                        then
                            UPDATE table_x_part_request
                            SET x_status = 'CANCELLED',
                               x_last_update_stamp = SYSDATE
                            WHERE objid = l_req_objid;
                        else
                            UPDATE table_x_part_request
                               SET x_status = 'ONHOLD',
                                   x_ff_center =
                                        DECODE (ship_overwrite,
                                                0, x_ff_center,
                                                ff_code
                                               ),
                                   x_last_update_stamp = SYSDATE
                             WHERE objid = l_req_objid;
                        end if;
                     END IF;
                     IF part_request_rec.x_status = 'SHIPPED'
                        or part_request_rec.x_status = 'PROCESSED' then

                           UPDATE table_x_part_request
                           SET x_status = 'CANCEL_REQUEST',
                               x_last_update_stamp = SYSDATE
                           WHERE objid  = part_request_rec.objid;

                           INSERT INTO table_x_part_request
                                  (objid, x_action,
                                   x_repl_part_num,
                                   x_part_serial_no,
                                   x_ff_center,
                                   x_ship_date, x_est_arrival_date,
                                   x_received_date, x_courier,
                                   x_shipping_method,
                                   x_tracking_no, x_status,
                                   request2case,
                                   x_insert_date,
                                   x_part_num_domain,
                                   x_service_level,
                                   x_quantity
                                  )
                           VALUES (seq ('x_part_request'), 'SHIP',
                                   part_request_rec.x_repl_part_num,
                                   NULL,
                                   DECODE (ship_overwrite,
                                           0, part_request_rec.x_ff_center,
                                           ff_code
                                          ),
                                   NULL, NULL,
                                   NULL,
                                   DECODE(part_request_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL,part_request_rec.x_courier),
                                   DECODE(part_request_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL, part_request_rec.x_shipping_method), --56717
                                   NULL, 'ONHOLD',
                                   part_request_rec.request2case,
                                   SYSDATE,
                                   part_request_rec.x_part_num_domain,
                                   DECODE(part_request_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL,part_request_rec.x_service_level),
                                   part_request_rec.x_quantity
                                  );
                    end if;  -- end 'SHIPED','PROCESSED'

                  END IF;
               END LOOP;
            END LOOP;                                               -- Action Cursor
         END IF;
      END;
   ELSE
    dbms_output.put_line('Rahul after begin in else ');
        DECLARE
           l_action                     VARCHAR2 (80);
           l_req_status                 VARCHAR2 (80);
           l_req_objid                  NUMBER;
           l_part_number                VARCHAR2 (80);
           ship_overwrite               NUMBER                           := 0;
           ff_code                      VARCHAR2 (80);
           active_count                 NUMBER                           := 0;
           esn_received                 number:=0;

           CURSOR action_cur
           IS
              SELECT X_ACTION,
                      elm.title, --CR24827
                      ELM.S_TITLE new_case_status
                FROM table_x_case_conf_hdr hdr,
                     table_x_case_conf_int INT,
                     table_gbst_elm elm
               WHERE hdr.x_case_type = :NEW.x_case_type
                 AND hdr.x_title = :NEW.title
                 AND hdr.x_warehouse = 1
                 AND INT.conf_int2conf_hdr = hdr.objid
                 AND INT.x_status = elm.title
                 AND elm.objid = :NEW.casests2gbst_elm
                 AND INT.x_active = 1;

           --CR6241 START - nguada 08/21/2007
           --CR31107 added x_part_inst_status to cursor 2/25/2015
           CURSOR cur_returned_esns is
            select objid, x_part_inst_status from table_part_inst where part_serial_no in
            (select x_part_serial_no from table_x_part_request
             where request2case = :NEW.objid
             and x_status IN ('SHIPPED', 'PROCESSED')
             and x_part_num_domain = 'PHONES'
             and x_part_serial_no is not null)
             and x_domain = 'PHONES';

           --CR31107 added phone part inst to add its x_part_inst_status to cursor 2/25/2015
            CURSOR cur_reserved_line is
              select line.objid, line.x_part_inst_status,line.part_to_esn2part_inst, phone.x_part_inst_status phone_status
              from table_part_inst line,
                table_part_inst phone
              where line.part_serial_no = nvl(:NEW.x_min,0)
              and line.x_domain = 'LINES'
              and phone.objid = line.part_to_esn2part_inst;

           --CR6241 END

           CURSOR part_request_cur(v_title varchar2) --   CR24827
           IS
              SELECT *
                FROM TABLE_X_PART_REQUEST R
               WHERE R.REQUEST2CASE = :NEW.OBJID
                 AND r.X_STATUS IN ('ONHOLD','ONHOLDST', 'PENDING', 'INCOMPLETE')
                 AND 0 = NVL((SELECT CASE
                   WHEN  R.X_REPL_PART_NUM LIKE '%-AIRBILL%' AND R.X_PART_SERIAL_NO IS NOT NULL and v_title in ('Exception')
                   THEN  1
                   ELSE 0
                   END
                   from dual ),0);

           CURSOR part_request_domain(v_title varchar2)
           IS
              SELECT DISTINCT r.X_PART_NUM_DOMAIN
                         FROM TABLE_X_PART_REQUEST R
                        WHERE R.REQUEST2CASE = :NEW.OBJID
                          AND r.x_status IN
                                 ('SHIPPED',
                                  'PROCESSED',
                                  'CANCELLED',
                                  'CANCEL_REQUEST'
                                 )
                          AND 0 = NVL((SELECT CASE
                          WHEN  R.X_REPL_PART_NUM LIKE '%-AIRBILL%' AND R.X_PART_SERIAL_NO IS NOT NULL and v_title in ('Exception')
                          THEN  1
                          ELSE 0
                          END
                          from dual ),0);

           CURSOR part_request_by_domain(domain VARCHAR2)
           IS
              SELECT *
                FROM table_x_part_request
               WHERE request2case = :NEW.objid
                 AND x_part_num_domain = domain
                 AND domain <> 'ACC'                                          --CR6073
                 AND x_status IN
                              ('SHIPPED', 'PROCESSED', 'CANCELLED', 'CANCEL_REQUEST')
                 AND ROWNUM < 2;

           part_request_by_domain_rec   part_request_by_domain%ROWTYPE;

        --CR6073
           CURSOR part_request_by_acc(v_title varchar2)
           IS
              SELECT pq.*
                FROM table_x_part_request pq, table_part_num pn1,
                     table_part_class pc1
               WHERE pq.request2case = :NEW.objid
                 AND pq.x_part_num_domain = 'ACC'
                 AND pq.x_status IN
                              ('SHIPPED', 'PROCESSED', 'CANCELLED', 'CANCEL_REQUEST')
                 AND (pq.x_insert_date, pc1.NAME) IN (
                        SELECT   MAX (pr.x_insert_date) AS max_x_insert_date, pc.NAME
                            FROM table_x_part_request pr,
                                 table_part_class pc,
                                 table_part_num pn
                           WHERE pr.request2case = :NEW.objid
                             AND pr.x_part_num_domain = 'ACC'
                             AND pr.x_status IN
                                    ('SHIPPED',
                                     'PROCESSED',
                                     'CANCELLED',
                                     'CANCEL_REQUEST'
                                    )
                             AND pr.x_repl_part_num = pn.part_number
                             AND pn.part_num2part_class = pc.objid
                        GROUP BY pc.NAME)
                 AND pq.x_repl_part_num = pn1.part_number
                 AND PN1.PART_NUM2PART_CLASS = PC1.OBJID
                 AND 0 = NVL((SELECT CASE
                      WHEN  PQ.X_REPL_PART_NUM LIKE '%-AIRBILL%' AND PQ.X_PART_SERIAL_NO IS NOT NULL AND V_TITLE IN ('Exception')  --CR24827
                       THEN  1
                       ELSE 0
                        END
                        from dual ),0);


        --Revision 1.6
           part_request_by_acc_rec      part_request_by_acc%ROWTYPE;

        --CR6073
           CURSOR ff_center_curs (status_objid NUMBER, ff_code VARCHAR2)
           IS
              SELECT   x_ff_code
                  FROM table_x_ff_center, table_gbst_elm
                 WHERE x_status_exception = table_gbst_elm.title
                   AND x_ff_code <> ff_code
                   AND table_gbst_elm.objid = status_objid
              ORDER BY x_ranking ASC;

           ff_center_rec                ff_center_curs%ROWTYPE;
        BEGIN
    dbms_output.put_line('Rahul after begin 2');
           IF        (:NEW.objid IS NOT NULL)
                 AND (NVL (:OLD.casests2gbst_elm, 0) <> :NEW.casests2gbst_elm)
              OR (NVL (:OLD.x_case_type, 'x') <> :NEW.x_case_type)
              OR (NVL (:OLD.title, 'x') <> :NEW.title)
           THEN
       dbms_output.put_line('Rahul 2 before action rec '||:NEW.casests2gbst_elm||' :NEW.x_case_type '||:NEW.x_case_type||' :NEW.title '||:NEW.title);
              FOR action_rec IN action_cur
              LOOP
                 l_action := action_rec.x_action;

         dbms_output.put_line('Rahul in Trig 2 l_action'||l_action);

                 IF l_action = 'HOLD'
                 THEN
                       if CLARIFY_CASE_PKG.GET_CASE_DETAIL(:NEW.objid,'ACTIVE_SITE_PART') is null then

                     --CR6241 START  - nguada 08/21/2007
                       For rec_esns in cur_returned_esns loop

                    -- CR31107 Add status check to ensure we only remove reserved line and other updates for active ESNs 2/25/2015
                        if rec_esns.x_part_inst_status != '52' then
                          --Remove reserved line
                          UPDATE table_part_inst
                          SET part_to_esn2part_inst = NULL
                          WHERE part_to_esn2part_inst = rec_esns.objid;

                          -- remove pending units
                          DELETE FROM table_x_pending_redemption
                          WHERE pend_redemption2esn  = rec_esns.objid;

                          -- remove service days
                          UPDATE table_part_inst
                          set warr_end_date = '1-jan-1753',
                              x_part_inst2contact = null
                          where objid = rec_esns.objid;
                        end if;
                       end loop;

                         for cur_line in cur_reserved_line loop

                            -- CR31107 Add phone status check to ensure we only remove reserved line and other updates for active ESNs 2/25/2015
                            if cur_line.x_part_inst_status in ('37','39') and cur_line.phone_status != '52' then
                               update table_part_inst
                               set part_to_esn2part_inst = (select objid from table_part_inst where part_serial_no = nvl(:NEW.x_esn,'0') and x_domain = 'PHONES')
                               where part_serial_no = nvl(:NEW.x_min,'0')
                               and x_domain = 'LINES';

                            end if;
                         end loop;
                       end if;

                     --CR6241 END

                    --Move to Cancel Request
                    UPDATE table_x_part_request
                       SET x_status = 'CANCEL_REQUEST',
                           x_last_update_stamp = SYSDATE
                     WHERE request2case = :NEW.objid
                       AND x_status IN ('SHIPPED', 'PROCESSED');

                 END IF;

                 FOR part_request_rec IN part_request_cur(action_rec.title) --CR24827
                 LOOP

                    if part_request_rec.x_status <> 'ONHOLDST' then  -- Don't count ONHOLDST as Active records
                       active_count := active_count + 1;
                    end if;

                    OPEN ff_center_curs (:NEW.casests2gbst_elm,
                                         part_request_rec.x_ff_center
                                        );

                    FETCH ff_center_curs
                     INTO ff_center_rec;

                    IF ff_center_curs%FOUND
                    THEN
                       ship_overwrite := 1;
                       ff_code := ff_center_rec.x_ff_code;
                    END IF;

                    CLOSE ff_center_curs;

                    l_req_status := part_request_rec.x_status;
                    l_req_objid := part_request_rec.objid;

        dbms_output.put_line('Rahul in Trig 2 l_req_status'||l_req_status||' l_req_objid '||l_req_objid);

                    IF l_action = 'PROCESS'
                    THEN
                       IF l_req_status IN ('ONHOLD', 'INCOMPLETE')
                       THEN
                          --Move to Pending
                          UPDATE table_x_part_request
                             SET x_status = 'PENDING',
                                 x_ff_center =
                                      DECODE (ship_overwrite,
                                              0, x_ff_center,
                                              ff_code
                                             ),
                                 x_last_update_stamp = SYSDATE
                           WHERE objid = l_req_objid;
                       END IF;
                    END IF;

                    IF l_action = 'RELEASE ST'
                    THEN
                       IF l_req_status IN ('ONHOLDST')
                       THEN
                          --Move to Pending
                          UPDATE table_x_part_request
                             SET x_status = 'PENDING',
                                 x_ff_center =
                                      DECODE (ship_overwrite,
                                              0, x_ff_center,
                                              ff_code
                                             ),
                                 x_last_update_stamp = SYSDATE
                           WHERE objid = l_req_objid;
                       END IF;
                    END IF;


                    IF l_action = 'CANCEL'
                    THEN
                       IF l_req_status IN ('ONHOLDST','PENDING', 'ONHOLD', 'INCOMPLETE')
                       THEN
                          --Move to Cancel Request
                          UPDATE table_x_part_request
                             SET x_status = 'CANCEL_REQUEST',
                                 x_last_update_stamp = SYSDATE
                           WHERE objid = l_req_objid;
                       END IF;
                    END IF;

                    IF l_action = 'HOLD'
                    THEN
                       IF l_req_status = 'PENDING'
                       THEN
                        --Move to ONHOLD
                        --CR56660 The Air Bill ( accessory ) line should be updated to CANCELLED.
                        --CR56660 When a case status is updated to Back Order
                        if action_rec.new_case_status = 'BACK ORDER' and
                           part_request_rec.x_part_num_domain = 'ACC'
                        then
                           UPDATE table_x_part_request
                           SET x_status = 'CANCELLED',
                               x_last_update_stamp = SYSDATE
                           WHERE objid = l_req_objid;
                        else
                          --Move to ONHOLD
                          UPDATE table_x_part_request
                             SET x_status = 'ONHOLD',
                                 x_ff_center =
                                      DECODE (ship_overwrite,
                                              0, x_ff_center,
                                              ff_code
                                             ),
                                 x_last_update_stamp = SYSDATE
                           WHERE objid = l_req_objid;
                        end if;
                       END IF;

                    END IF;
                 END LOOP;

                 -- No Active Records Found
                 IF active_count = 0 AND l_action = 'HOLD'
                 THEN
                    FOR part_request_domain_rec IN part_request_domain(action_rec.title)  --CR24827
                    LOOP
                       OPEN part_request_by_domain
                                           (part_request_domain_rec.x_part_num_domain);

                       FETCH part_request_by_domain
                        INTO part_request_by_domain_rec;

                       IF part_request_by_domain%FOUND
                       THEN
                          CLOSE part_request_by_domain;

                          INSERT INTO table_x_part_request
                                      (objid, x_action,
                                       x_repl_part_num,
                                       x_part_serial_no,
                                       x_ff_center,
                                       x_ship_date, x_est_arrival_date,
                                       x_received_date, x_courier,
                                       x_shipping_method,
                                       x_tracking_no, x_status,
                                       request2case,
                                       x_insert_date,
                                       x_part_num_domain,
                                       x_service_level
                                      )
                               VALUES (seq ('x_part_request'), 'SHIP',
                                       part_request_by_domain_rec.x_repl_part_num,
                                       NULL,
                                       DECODE (ship_overwrite,
                                               0, part_request_by_domain_rec.x_ff_center,
                                               ff_code
                                              ),
                                       NULL, NULL,
                                       NULL,
                                       DECODE(part_request_by_domain_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL,part_request_by_domain_rec.x_courier),
                                       DECODE(part_request_by_domain_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL, part_request_by_domain_rec.x_shipping_method), --56717
                                       NULL, 'ONHOLD',
                                       part_request_by_domain_rec.request2case,
                                       SYSDATE,
                                       part_request_by_domain_rec.x_part_num_domain,
                                       DECODE(part_request_by_domain_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL,part_request_by_domain_rec.x_service_level)
                                      );
                       ELSE
                          CLOSE part_request_by_domain;
                       END IF;
                    END LOOP;

                    --CR6073
                    FOR part_request_by_acc_rec IN part_request_by_acc(action_rec.title) --CR24827
                    LOOP


                      select count(*)
                      into esn_received
                      from table_status_chg,table_gbst_elm
                      where table_status_chg.c_status_chg2gbst_elm= table_gbst_elm.objid
                      and table_gbst_elm.title = 'ESN Received'
                      and table_status_chg.case_status_chg2case= :NEW.objid;

                       if (esn_received = 0 and part_request_by_acc_rec.x_repl_part_num = 'AIRBILL')
                          or part_request_by_acc_rec.x_repl_part_num <> 'AIRBILL' then

                           INSERT INTO table_x_part_request
                                   (objid, x_action,
                                    x_repl_part_num, x_part_serial_no,
                                    x_ff_center,
                                    x_ship_date, x_est_arrival_date,
                                    x_received_date, x_courier,
                                    x_shipping_method, x_tracking_no,
                                    x_status, request2case,
                                    x_insert_date,
                                    x_part_num_domain,
                                    x_service_level
                                   )
                            VALUES (seq ('x_part_request'), 'SHIP',
                                    part_request_by_acc_rec.x_repl_part_num, NULL,
                                    DECODE (ship_overwrite,
                                            0, part_request_by_acc_rec.x_ff_center,
                                            ff_code
                                           ),
                                    NULL, NULL,
                                    NULL,
                                    DECODE(part_request_by_acc_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL, part_request_by_acc_rec.x_courier),
                                    DECODE(part_request_by_acc_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL, part_request_by_acc_rec.x_shipping_method), --56717
                                    NULL,
                                    'ONHOLD', part_request_by_acc_rec.request2case,
                                    SYSDATE,
                                    part_request_by_acc_rec.x_part_num_domain,
                                    DECODE(part_request_by_acc_rec.x_shipping_method, 'FX01', NULL, 'USPP', NULL, part_request_by_acc_rec.x_service_level)
                                   );
                       end if;

                    END LOOP;
                 --CR6073
                 END IF;
              END LOOP;                                               -- Action Cursor
           END IF;
        END;

   END IF;

Exception when others
then

dbms_output.put_line('Rahul in main exception '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

END TABLE_CASE_A_IU;
/