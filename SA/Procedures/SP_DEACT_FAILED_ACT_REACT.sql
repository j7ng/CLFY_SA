CREATE OR REPLACE PROCEDURE sa."SP_DEACT_FAILED_ACT_REACT"
AS
/********************************************************************************/
   /* Copyright ) 2001 Tracfone Wireless Inc. All rights reserved                  */
   /*                                                                              */
   /* Name         :   sp_deact_failed_act_react.sql                               */
   /* Purpose      :   Picks up all failed activations/reactivations for Carriers  */
   /*                  with x_no_msid = 1 and send a deactivation/suspend request  */
   /*                  to the carrier                                              */
   /* Parameters   :   None                                                        */
   /* Platforms    :   Oracle 8.0.6 AND newer versions                             */
   /* Author	    :     Ritu Gandhi                                         				*/
   /*                  Tracfone			                                            	*/
   /* Date         :   October 13,2004                                             */
   /* Revisions	:   Version  Date      Who       Purpose                          */
   /*                  -------  --------  -------   ------------------------------ */
   /*                  1.0                          Initial Version for CR2620     */
   /********************************************************************************/
   CURSOR csrFailedTrans
   IS
   SELECT CT.Objid call_trans_obj,
      CT.x_Service_Id,
      CT.CALL_TRANS2SITE_PART,
      CT.X_CALL_TRANS2CARRIER
   FROM Table_x_Call_Trans CT
   WHERE CT.X_ACTION_TYPE IN (1, 3)
   AND CT.X_TRANSACT_DATE >= TRUNC(SYSDATE - 1)
   AND CT.X_TRANSACT_DATE < TRUNC(SYSDATE)
   AND CT.x_Result = 'Failed';
   recFailedTrans csrFailedTrans%ROWTYPE;
   CURSOR noMsidCarrier(
      carr_objid NUMBER
   )
   IS
   SELECT C.*
   FROM table_x_carrier C, table_x_carrier_group CG, table_x_parent P
   WHERE C.Objid = carr_objid
   AND C.CARRIER2CARRIER_GROUP = CG.OBJID
   AND CG.X_CARRIER_GROUP2X_PARENT = P.Objid
   AND P.X_NO_MSID = 1;
   recNoMsidCarrier noMsidCarrier%ROWTYPE;
   CURSOR closedTask(
      call_trans_obj NUMBER
   )
   IS
   SELECT T.*
   FROM table_task T, table_condition CO
   WHERE T.X_TASK2X_CALL_TRANS = call_trans_obj
   AND T.TASK_STATE2CONDITION ||'' = CO.Objid
   AND CO.s_Title || '' = 'CLOSED ACTION ITEM';
   recTask closedTask%ROWTYPE;
   x_min table_site_part.x_min%TYPE;
   iActiveCnt int := 0;
   iClosedTask int := 0;
   user_obj NUMBER;
   op_return VARCHAR2(10);
   op_returnMsg VARCHAR2(200);
BEGIN
   SELECT objid
   INTO user_obj
   FROM table_user
   WHERE login_name = 'sa';
   --Loop through all failed activations and reactivations for the previous day
   FOR recFailedTrans IN csrFailedTrans
   LOOP

      --Check if the carrier is flagged for No Msid
      OPEN noMsidCarrier(recFailedTrans.X_CALL_TRANS2CARRIER);
      FETCH noMsidCarrier
      INTO recNoMsidCarrier;
      IF noMsidCarrier%FOUND
      THEN
         SELECT COUNT(*)
         INTO iActiveCnt
         FROM table_site_part
         WHERE x_service_id = recFailedTrans.x_service_id
         AND part_status = 'Active';
         IF iActiveCnt = 0
         THEN

            --Get the MIN for the failed transaction
            BEGIN
               SELECT x_min
               INTO x_min
               FROM table_site_part
               WHERE objid = recFailedTrans.CALL_TRANS2SITE_PART;
               EXCEPTION
               WHEN OTHERS
               THEN
                  iClosedTask := 0;
            END;
            --Check if the task associated is complete
            OPEN closedTask(recFailedTrans.call_trans_obj);
            FETCH closedTask
            INTO recTask;
            IF closedTask%NOTFOUND
            THEN
               iClosedTask := 0;
            ELSE
               iClosedTask := 1;
            END IF;
            CLOSE closedTask;
            IF iClosedTask > 0
            THEN
               DBMS_OUTPUT.put_line('Call service deact for ' || recFailedTrans.x_service_id
               || ', ' || x_min);
               --Call service_deactivation to send a deactivation/suspend order type to the carrier/Intergate
               service_deactivation.deactService ( 'CLARIFY', user_obj,
               recFailedTrans.x_service_id, x_min, 'SENDCARRDEACT', 0, NULL,
               'true', op_return, op_returnMsg);
            END IF;
--End if for iClosedTask>0
         END IF;
-- End If for iActiveCnt = 0
      END IF; --end of check for No Msid carrier
      CLOSE noMsidCarrier;
   END LOOP;
END;
/