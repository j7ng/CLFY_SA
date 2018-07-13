CREATE OR REPLACE TRIGGER sa."TRIG_X_SL_HIST"
AFTER INSERT OR UPDATE OR DELETE
ON sa.X_SL_HIST REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_X_SL_HIST.sql,v $
--$Revision: 1.14 $
--$Author: ddevaraj $
--$Date: 2015/07/20 16:06:16 $
--$ $Log: TRIG_X_SL_HIST.sql,v $
--$ Revision 1.14  2015/07/20 16:06:16  ddevaraj
--$ FOR CR34295
--$
--$ Revision 1.13  2012/05/04 20:44:38  mmunoz
--$ Adding slash at the end
--$
--$ Revision 1.12  2012/05/03 20:23:05  mmunoz
--$ CR20202 mHealth changes related x_sourcesystem = 'HMO'
--$
--$ Revision 1.11  2012/02/20 19:46:35  mmunoz
--$ Changes to keep updated new column x_sl_currentvals.x_current_min (event_codes 602, 700, 616, 617, 611, 613)
--$
--$ Revision 1.10  2012/01/31 21:25:57  mmunoz
--$ Changes to keep the new columns updated in x_sl_currentvals (event_codes 617, 607, 609)
--$
--------------------------------------------------------------------------------------------
DECLARE
      CURSOR get_x_min (ip_esn in varchar2)
      IS
          SELECT  tsp.x_min
          from    table_site_part tsp
          where   tsp.x_service_id = ip_esn
          and     tsp.part_status||''='Active'
          order by install_date desc;

     get_x_min_rec   get_x_min%rowtype;
     procedure close_cursor is
     begin
        IF get_x_min%ISOPEN THEN
	       CLOSE get_x_min;
	    END IF;
     end close_cursor;
BEGIN
  IF INSERTING and :new.x_sourcesystem <> 'HMO' THEN  --CR20202 excluded HMO
   BEGIN
   /* if we have a LID and ESN, all the logic below happens to require both */
       IF :new.lid IS NOT NULL AND :new.x_esn IS NOT NULL THEN
              BEGIN
              /* event                    code has lid? has esn?     Is it already the ESN for this LID?      assign ESN/LID     set */

              /* brightpoint activation attempt */
              /* 602 BPoint Activation    0      Y      Y      THEN   no check      Y      active=Y */
              IF :new.x_event_code=602 AND :new.x_code_number=0 THEN
               /* new update CR13940 */
               UPDATE  sa.x_sl_currentvals
                                SET  x_current_esn = NULL,
                                                x_current_active = 'N',
                                                x_current_enrolled = 'N'
                                WHERE x_current_esn = :new.x_esn;

               UPDATE sa.X_SL_CURRENTVALS
                SET
                     x_current_esn = :new.x_esn,   /* x_current_active = 'Y',  */
                     x_current_active = NULL,      /*  CR13940  */
                     x_current_enrolled = NULL,    /*  CR13940  */
                     x_current_active_date = :new.x_event_dt
                     ,x_current_min = null  --CR17925
                WHERE lid= :new.lid;

              /* phone has shipped */
              /* 609 Shipped Confirm      any    Y      Y      ELSE   no check      Y      shipped-6/24, ticketid (keep) */
              ELSIF :NEW.X_EVENT_CODE=609 THEN
               UPDATE sa.X_SL_CURRENTVALS
                SET
                 x_current_esn = :new.x_esn,
                 x_current_shipped = 'Y',
                 --x_current_shipped_date =:new.x_event_dt - 6/24,--CR13649
                 --
                 -- Start CR14050 kacosta
                 --X_CURRENT_PGM_START_DATE =:new.x_event_dt - 6/24,
                 x_current_pgm_start_date = CASE
                                              WHEN ((:new.x_event_dt - 6/24) - NVL(x_original_ship_date,(:new.x_event_dt - 6/24)) <= 60) THEN
                                                :new.x_event_dt - 6/24
                                              ELSE
                                                x_current_pgm_start_date
                                            END,
                 x_original_ship_date = CASE
                                          WHEN x_original_ship_date IS NULL THEN
                                            :new.x_event_dt - 6/24
                                          ELSE
                                            x_original_ship_date
                                        END,
                 -- End CR14050 kacosta
                 --
                 x_current_ticket_id = :new.x_event_value,
				  /*CR17925-CR10032*/
				 (X_SHIP_ADDRESS_1,
                 X_SHIP_ADDRESS_2,
                 X_SHIP_CITY,
                 X_SHIP_STATE,
                 X_SHIP_ZIPCODE,
                 X_SHIP_DATE,
                 X_TRACKING_NO) = (SELECT /*+ ORDERED */
                                          ship_address.address,
                                          ship_address.address_2,
                                          ship_address.city,
                                          ship_address.state,
                                          ship_address.zipcode,
                                          pr.x_ship_date,
                                          pr.x_tracking_no
                                   FROM table_case           ship_case,
                                        table_address        ship_address,
                                        table_x_part_request pr
                                   WHERE 1 = 1
                                   AND SHIP_CASE.ID_NUMBER = :NEW.X_EVENT_VALUE
                                   AND ship_address.objid  = ship_case.CASE2ADDRESS
                                   AND PR.REQUEST2CASE     = SHIP_CASE.OBJID
                                   AND PR.X_PART_SERIAL_NO = :new.x_esn
                                   AND PR.X_ACTION = 'SHIP'
                                   AND PR.X_STATUS = 'SHIPPED'
                                   AND PR.X_PART_NUM_DOMAIN = 'PHONES'
                                   AND ROWNUM < 2
                                   )
              WHERE lid= :new.lid;

              /* assign a ticket to a LID (inbound) */
              /* 610 Ticket Assigned      0      Y      Y      ELSE   no check      Y      ticketid */
              ELSIF :new.x_event_code=610 AND :new.x_code_number=0 THEN
               UPDATE sa.X_SL_CURRENTVALS
                SET
                     x_current_esn = :new.x_esn,
                     x_deenroll_reason=:new.x_event_data,
                     x_current_ticket_id = :new.x_event_value
              WHERE lid= :new.lid;

              /* successful enroll */
              /* 607 Value Plan    0      Y      Y      ELSE   no check      Y      enrolled=Y */
              ELSIF :new.x_event_code=607 AND :new.x_code_number=0 THEN
               UPDATE sa.X_SL_CURRENTVALS
                SET
                     X_current_active = 'Y',           /* CR13940 */
                     x_current_enrolled = 'Y',
                     x_current_enrolled_date = :new.x_event_dt,
                     x_current_pe_id  = :new.x_src_objid
                WHERE lid= :new.lid;

              /* successful deenroll */
              /* 607 Value Plan    700    Y      Y      ELSE   Y      Y      enrolled=N */
              ELSIF :new.x_event_code=607 AND :new.x_code_number=700 THEN
                 UPDATE sa.X_SL_CURRENTVALS
                     SET
                           x_current_enrolled = 'N',
                           x_current_enrolled_date = sysdate,
                           x_current_pe_id  = :new.x_src_objid
                     WHERE lid= :new.lid AND x_current_esn = :new.x_esn; /* only if already my ESN in that LID */
              /* 700 INFO (deenroll reason)     any    Y      Y      ELSE   Y      ?????       enroll_reason=reason */
              ELSIF :new.x_event_code=700 /*AND :new.x_code_number=0*/ AND :new.x_event_value LIKE 'DeEnrollment%' /* AND :new.x_event_value LIKE '%Success%'*/ THEN
                 UPDATE sa.X_SL_CURRENTVALS
                     SET
                           x_deenroll_reason = :new.x_event_data /* the reason text */
                     WHERE lid= :new.lid AND x_current_esn = :new.x_esn; /* only if already my ESN in that LID */

              /* 700 INFO (enroll reason)     any    Y      Y      ELSE   Y      ?????       enroll_reason=reason */
              ELSIF :new.x_event_code=700 AND :new.x_event_value LIKE 'Enrollment%' THEN
                 UPDATE sa.X_SL_CURRENTVALS
                     SET
                           x_current_esn = :new.x_esn,
                           x_deenroll_reason = :new.x_event_data /* the reason text */
                     WHERE lid= :new.lid;

              ELSIF :new.x_event_code=700 AND :new.x_event_value LIKE 'Deactivation picked up%' THEN --CR17925
                 UPDATE sa.X_SL_CURRENTVALS
                     SET   x_current_min = NULL
                     WHERE lid= :new.lid;

              /* 615    Program start    any    Y    Y    ELSE    no check    Y    esn=new ESN where lid=lid, shipped=event date */
              ELSIF :new.x_event_code=615 THEN
                 UPDATE sa.X_SL_CURRENTVALS
                     SET
                     -- CR15625  SAFELINK PROCESS IMPROVEMENT
                     x_deenroll_reason = nvl(:new.x_event_data,x_deenroll_reason), /* the reason text */
                           --x_deenroll_reason = :new.x_event_data, /* the reason text */
                           x_current_esn = :new.x_esn,
                           x_current_shipped = 'Y',
                           --x_current_shipped_date =:new.x_event_dt - 0 /* no offset */ --CR13649
                           X_CURRENT_PGM_START_DATE =:new.x_event_dt - 0 /* no offset */
                     --WHERE lid= :new.lid;
                        WHERE lid= :new.lid and X_CURRENT_PGM_START_DATE IS NULL ;

              /* 616 Program start any    Y      Y      ELSE   no check      Y      x_minutes_sent_dt=event date */
              ELSIF :new.x_event_code=616 THEN
                 UPDATE sa.X_SL_CURRENTVALS
                     SET
                           x_minutes_sent_dt = :new.x_event_dt
                           ,x_current_min = :new.x_min  --CR17925
                     WHERE lid= :new.lid;

              /* 617 Program start any    Y      Y      ELSE   no check      Y       x_minutes_delivered_dt=event date */
              elsif :new.x_event_code=617 then
                  UPDATE sa.X_SL_CURRENTVALS cv
                     SET
                         X_BENEFIT_DELVD_ESN = :NEW.x_esn,    /*CR17925-CR10032*/
                         X_BENEFIT_DELVD_MIN = :NEW.x_min,    /*CR17925-CR10032*/
                         X_CURRENT_MIN = :NEW.x_min,    /*CR17925-CR10032*/
                         (X_BENEFIT_DELVD_PHONE_STATUS,
                          X_BENEFIT_DELVD_ACT_ZIPCODE,
                          X_BENEFIT_DELVD_PART_NUM   ) = (select x_part_inst_status,
                                                                 (SELECT sp.x_zipcode
                                                                    FROM TABLE_SITE_PART sp
                                                                   WHERE sp.objid = pi.x_part_inst2site_part) x_zipcode,
                                                                 part.part_number
                                                            from table_part_inst pi,
                                                                 table_mod_level ml,
                                                                 table_part_num part
                                                           where pi.part_serial_no = :new.x_esn
                                                             and pi.x_domain = 'PHONES'
                                                             AND ml.objid = pi.n_part_inst2part_mod
                                                             AND part.objid  = ml.part_info2part_num),
                         x_minutes_delivered_dt = :new.x_event_dt,
                         X_current_active = 'Y',                 /* CR13940  */
						 /*CR17925-CR10032*/
                         X_BENEFIT_DELVD_PE_ID = CV.X_CURRENT_PE_ID,
                         (X_SHIP_ADDRESS_1,
                          X_SHIP_ADDRESS_2,
                          X_SHIP_CITY,
                          X_SHIP_STATE,
                          X_SHIP_ZIPCODE,
                          X_SHIP_DATE,
                          X_TRACKING_NO) = (SELECT /*+ ORDERED */
                                                   ship_address.address,
                                                   ship_address.address_2,
                                                   ship_address.city,
                                                   ship_address.state,
                                                   ship_address.zipcode,
                                                   pr.x_ship_date,
                                                   pr.x_tracking_no
                                              FROM table_case           ship_case,
                                                   table_address        ship_address,
                                                   table_x_part_request pr
                                             WHERE 1 = 1
                                               AND ship_case.id_number = cv.x_current_ticket_id
                                               AND ship_address.objid  = ship_case.CASE2ADDRESS
                                               AND PR.REQUEST2CASE     = SHIP_CASE.OBJID
                                               AND PR.X_PART_SERIAL_NO = CV.X_CURRENT_ESN
                                               AND PR.X_ACTION = 'SHIP'
                                               AND PR.X_STATUS = 'SHIPPED'
                                               AND PR.X_PART_NUM_DOMAIN = 'PHONES'
                                               AND rownum < 2
                                               ),
                         (X_BENEFIT_DELVD_CARRIER_ID,
                          X_BENEFIT_DELVD_CARRIER_NAME) = (SELECT /*+ ORDERED */
                                                                  ca.x_carrier_id        CARRIER_ID,
                                                                  ca.X_MKT_SUBMKT_NAME   CARRIER_NAME
                                                             FROM table_part_inst PI,
                                                                  table_x_carrier ca
                                                            WHERE pi.part_serial_no = :new.x_min
                                                              and ca.objid = pi.part_inst2carrier_mkt),
                         (X_OTA_STATUS,
                          X_OTA_UNITS) = (SELECT /*+ ORDERED */
                                                 ota.X_STATUS,
                                                 ct.X_TOTAL_UNITS
                                            FROM
                                                 table_part_inst pi,
                                                 TABLE_X_CALL_TRANS ct,
                                                 TABLE_X_OTA_TRANSACTION ota
                                           where pi.part_serial_no = :new.x_esn
                                             and pi.x_domain = 'PHONES'
                                             and ct.call_trans2site_part            = pi.x_part_inst2site_part
                                             AND ct.x_action_type                   = '6' --REDEMPTION
                                             AND CT.X_RESULT                     LIKE 'Completed%'
                                             AND ct.x_transact_date                >=  :new.x_event_dt-5
                                             AND ct.x_transact_date                <=  :new.x_event_dt+5
                                             AND ota.x_ota_trans2x_call_trans(+)    = ct.objid
                                             AND rownum < 2)
                   WHERE lid= :new.lid;
                /* 611 Exchange      any    Y      Y      ELSE   N      Y      esn=new ESN where lid=lid */
                /* 613 Upgrade              any    Y      Y      ELSE   N      Y      esn=new ESN where lid=lid */
              ELSIF (:new.x_event_code=611 OR :new.x_event_code=613) THEN--- for CR34295
                 UPDATE sa.X_SL_CURRENTVALS
                     set  x_current_esn = :new.x_esn
                         ,x_current_min = case --CR17925
                                          when :new.x_event_code=611 then nvl(:new.x_min,x_current_min)
                                          else x_current_min
                                          end
                     WHERE lid= :new.lid;
--for CR34295
                     IF :new.x_event_code=613 then  --CR17925
                      OPEN get_x_min(:new.x_esn);
                      FETCH get_x_min INTO get_x_min_rec;
                      IF get_x_min%FOUND THEN
                            UPDATE sa.X_SL_CURRENTVALS
                            SET     x_current_min = get_x_min_rec.x_min
                            WHERE lid= :new.lid;
                      END IF;
                      close_cursor;
                      END IF;



        /* 618 Invoice Reasons     any    Y      Y      ELSE   N      Y       invoice_reason=reason */
              ELSIF :new.x_event_code=618 THEN
                 UPDATE sa.X_SL_CURRENTVALS
                     SET
                           x_invoice_reason  = :new.x_event_data /* the reason text */
                     WHERE lid= :new.lid;
              /* ELSE do nothing */
              END IF;
              END;

       END IF;
   EXCEPTION
    when others then
	  close_cursor;
    raise_application_error (-20100,SUBSTR('Audit error in TRIG_X_SL_HIST while updating SL_SUBS -  '||SQLERRM,1,255) ) ;
   END;
  ELSIF UPDATING THEN
    raise_application_error (-20130,SUBSTR('UPDATE OF X_SL_HIST TABLE IS NOT ALLOWED '||SQLERRM,1,255));
  ElSIF DELETING THEN
    raise_application_error (-20140,SUBSTR('DELETE FROM X_SL_HIST TABLE IS NOT ALLOWED '||SQLERRM,1,255));
  END IF;
END;
/