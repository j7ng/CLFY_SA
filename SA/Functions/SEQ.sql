CREATE OR REPLACE FUNCTION sa."SEQ" (p_seq_name VARCHAR2)
   RETURN NUMBER
AS
/******************************************************************************/
/*    Copyright ) 2003 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         seq.sql                                                      */
/* PURPOSE:                                                                   */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/* REVISIONS:    VERSION  DATE        WHO               PURPOSE               */
/*               -------  ----------  ---------------   -------------------   */
/*               1.0      04/10/03    SL                Initial Revision      */
/*                                                      Clarify Upgrade       */
/*               1.1      12/16/03    SL                Performance Enhance-  */
/*                                                      ment                  */
/*           05/06/04    MH        change from dbms_lock.sleep(1)*/
/*                      to dbms_lock.sleep(0.20)          */
/*                     01/10/05    SL                insert error directly */
/*                     03/21/06    cwl               Use Ora SEQ for ota   */
/*                                                                            */
/*              1.2  06/23/06   NG/CL           CR5391 - Added More sequences*
/*				1.3   08/01/06   CL				CR4902-1 - Added more sequences
/******************************************************************************/
   PRAGMA AUTONOMOUS_TRANSACTION;

   CURSOR get_current (c_sequence_name VARCHAR2)
   IS
      SELECT     OID.*, OID.ROWID
            FROM adp_tbl_oid OID, adp_tbl_name_map MAP
           WHERE OID.type_id = MAP.type_id
             --and upper(map.type_name)= upper(c_sequence_name) --12/16/03
             AND MAP.type_name = LOWER (c_sequence_name)           -- 12/16/03
      /* FOR UPDATE NOWAIT */ ;

   v_seq_name          VARCHAR2 (100)        := LTRIM (RTRIM (p_seq_name));
   v_get_current_rec   get_current%ROWTYPE;
   v_next_value        NUMBER;
   v_dummy             NUMBER;
   v_max_attempts      NUMBER                := 10;                -- 01/10/05
   v_program_name      VARCHAR2 (50)         := 'seq';              --01/10/05
   v_error             VARCHAR2 (1000);                             --01/10/05
BEGIN
-------------------------------------------------------------------------------------------------------
-- NEW CODE TO USE ORACLE SEQUENCES ON SOME HIGH USED TABLES
-------------------------------------------------------------------------------------------------------
   IF LOWER (p_seq_name) = 'x_sim_inv'
   THEN
      SELECT sa.sequ_x_sim_inv.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'act_entry'
   THEN
      SELECT sa.sequ_act_entry.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'part_inst'
   THEN
      SELECT sa.sequ_part_inst.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'task'
   THEN
      SELECT sa.sequ_task.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'time_bomb'
   THEN
      SELECT sa.sequ_time_bomb.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_call_trans'
   THEN
      SELECT sa.sequ_x_call_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_cbo_error'
   THEN
      SELECT sa.sequ_x_cbo_error.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_code_hist'
   THEN
      SELECT sa.sequ_x_code_hist.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_code_hist_temp'
   THEN
      SELECT sa.sequ_x_code_hist_temp.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_contact_add_info'
   THEN
      SELECT sa.sequ_x_contact_add_info.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_group2esn'
   THEN
      SELECT sa.sequ_x_group2esn.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_pending_redemption'
   THEN
      SELECT sa.sequ_x_pending_redemption.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_pi_hist'
   THEN
      SELECT sa.sequ_x_pi_hist.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_posa_card_inv'
   THEN
      SELECT sa.sequ_x_posa_card_inv.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_promo_hist'
   THEN
      SELECT sa.sequ_x_promo_hist.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_rate_min_hist'
   THEN
      SELECT sa.sequ_x_rate_min_hist.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_red_card'
   THEN
      SELECT sa.sequ_x_red_card.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_red_card_temp'
   THEN
      SELECT sa.sequ_x_red_card_temp.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
---------------------------------------------------------------------------
-- new code for ota tables
---------------------------------------------------------------------------
   ELSIF LOWER (p_seq_name) = 'x_ota_transaction'
   THEN
      SELECT sa.sequ_x_ota_transaction.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_ota_trans_dtl'
   THEN
      SELECT sa.sequ_x_ota_trans_dtl.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_ota_ack'
   THEN
      SELECT sa.sequ_x_ota_ack.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_ota_features'
   THEN
      SELECT sa.sequ_x_ota_features.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
---------------------------------------------------------------------------
-- new code for ota tables
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- new code 4/24/06
---------------------------------------------------------------------------
   ELSIF LOWER (p_seq_name) = 'contact_role'
   THEN
      SELECT sa.sequ_contact_role.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'site'
   THEN
      SELECT sa.sequ_site.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'site_part'
   THEN
      SELECT sa.sequ_site_part.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'address'
   THEN
      SELECT sa.sequ_address.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_group2esn'
   THEN
      SELECT sa.sequ_x_group2esn.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_click_plan_hist'
   THEN
      SELECT sa.sequ_x_click_plan_hist.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_code_temp'
   THEN
      SELECT sa.sequ_x_code_temp.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_tracking_visitor'
   THEN
      SELECT sa.sequ_x_tracking_visitor.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_tracking_site'
   THEN
      SELECT sa.sequ_x_tracking_site.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_tracking_campaign'
   THEN
      SELECT sa.sequ_x_tracking_campaign.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_tracking_element'
   THEN
      SELECT sa.sequ_x_tracking_element.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_tracking_position'
   THEN
      SELECT sa.sequ_x_tracking_position.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_tracking_target_url'
   THEN
      SELECT sa.sequ_x_tracking_target_url.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_tracking_account'
   THEN
      SELECT sa.sequ_x_tracking_account.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_tracking_status'
   THEN
      SELECT sa.sequ_x_tracking_status.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'mod_level'
   THEN
      SELECT sa.sequ_mod_level.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'part_num'
   THEN
      SELECT sa.sequ_part_num.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_purch_hdr'
   THEN
      SELECT sa.sequ_x_purch_hdr.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_purch_dtl'
   THEN
      SELECT sa.sequ_x_purch_dtl.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_credit_card'
   THEN
      SELECT sa.sequ_x_credit_card.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'condition'
   THEN
      SELECT sa.sequ_condition.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'case'
   THEN
      SELECT sa.sequ_case.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_alt_esn'
   THEN
      SELECT sa.sequ_x_alt_esn.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_case_extra_info'
   THEN
      SELECT sa.sequ_x_case_extra_info.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
---------------------------------------------------------------------------
-- new code 4/24/06
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- new code 8/01/06
---------------------------------------------------------------------------
-- new code 01/29/07 Fix wrong seq being used, was broken by 8/01/06 change
---------------------------------------------------------------------------
   ELSIF LOWER (p_seq_name) = 'x_webcsr_log'
   THEN
      SELECT sa.sequ_x_webcsr_log.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
   ELSIF LOWER (p_seq_name) = 'x_zero_out_max'
   THEN
      SELECT sa.sequ_x_zero_out_max.NEXTVAL
        INTO v_next_value
        FROM DUAL;

      RETURN v_next_value;
---------------------------------------------------------------------------
-- new code 01/29/07 end change
---------------------------------------------------------------------------
    ELSIF LOWER (p_seq_name) = 'table_x_cc_parms_mapping'
       THEN
          SELECT sa.sequ_cc_parms_mapping.NEXTVAL
            INTO v_next_value
            FROM DUAL;

          RETURN v_next_value;
   --CR49087 use contact sequence
   ELSIF  LOWER (p_seq_name) = 'contact'
      THEN

         SELECT sa.sequ_contact.NEXTVAL
         INTO v_next_value
         FROM DUAL;

         RETURN v_next_value;

   END IF;

-------------------------------------------------------------------------------------------------------
-- END NEW CODE TO USE ORACLE SEQUENCES ON SOME HIGH USED TABLES
-------------------------------------------------------------------------------------------------------
   IF v_seq_name IS NULL
   THEN
      --01/10/05
      INSERT INTO error_table
                  (ERROR_TEXT, error_date, action,
                   KEY, program_name
                  )
           VALUES ('Sequence Name Required.', SYSDATE, 'Verifying seq name',
                   NULL, v_program_name
                  );

      COMMIT;
      raise_application_error (-20001, 'Sequence Name Required.');
   END IF;

   FOR i IN 1 .. v_max_attempts
   LOOP
      BEGIN
         OPEN get_current (v_seq_name);

         EXIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF i = v_max_attempts
            THEN
               --01/10/05
               INSERT INTO error_table
                           (ERROR_TEXT,
                            error_date,
                            action,
                            KEY, program_name
                           )
                    VALUES (   'Error in trying to get a lock on a table name'
                            || p_seq_name,
                            SYSDATE,
                            'Times Tried so far' || TO_CHAR (v_max_attempts),
                            v_seq_name, v_program_name
                           );

               COMMIT;
               raise_application_error
                                      (-20003,
                                          'Resource Busy. Maxium '
                                       || v_max_attempts
                                       || ' attempts rearched. Please try again.'
                                      );
/* this is added on 04/01/2004 by MHanif */
/* 01/10/05 use insert instead
   toss_util_pkg.insert_error_tab_proc ('Error in trying to get a lock on a table name:'||p_seq_name,
                                               'Times Tried so far'||to_char(v_max_attempts),
                                               'seq',
                                                'NONE');
*/
            ELSE
               DBMS_LOCK.sleep (0.20);
            END IF;
      END;
   END LOOP;

   FETCH get_current
    INTO v_get_current_rec;

   IF get_current%NOTFOUND
   THEN
      CLOSE get_current;

      --01/10/05
      INSERT INTO error_table
                  (ERROR_TEXT,
                   error_date, action,
                   KEY, program_name
                  )
           VALUES ('Sequence ' || UPPER (v_seq_name) || ' not found',
                   SYSDATE, 'Retrieving sequence name ' || v_seq_name,
                   v_seq_name, v_program_name
                  );

      COMMIT;
      raise_application_error (-20002,
                               'Sequence ' || UPPER (v_seq_name)
                               || ' not found'
                              );
   ELSE
      CLOSE get_current;

      BEGIN
	 /*
         UPDATE adp_tbl_oid
            SET obj_num = obj_num + 1
          WHERE ROWID = v_get_current_rec.ROWID;
	  */

         v_next_value := v_get_current_rec.obj_num + 1 + POWER (2, 28);
      EXCEPTION
         WHEN OTHERS
         THEN
            --rollback;
            --01/10/05
            INSERT INTO error_table
                        (ERROR_TEXT,
                         error_date, action,
                         KEY, program_name
                        )
                 VALUES (   'Error occured when updating sequence '
                         || v_seq_name
                         || ' - '
                         || v_error,
                         SYSDATE, 'Updating sequence ' || v_seq_name,
                         v_seq_name, v_program_name
                        );

            COMMIT;
            raise_application_error
                                   (-20004,
                                       'Error occured when updating sequence '
                                    || v_seq_name
                                    || v_error
                                   );
      END;

      COMMIT;
      RETURN v_next_value;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;

      IF get_current%ISOPEN
      THEN
         CLOSE get_current;
      END IF;
END;
/