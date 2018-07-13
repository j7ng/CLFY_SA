CREATE OR REPLACE PROCEDURE sa."NEXT_ID" (
   p_seq_name     IN       VARCHAR2,
   o_next_value   OUT      NUMBER,
   o_format       OUT      VARCHAR2
)
IS
   /************************************************************************************************
   |    Copyright   Tracfone  Wireless Inc. All rights reserved
   |
   | PURPOSE  :
   | FREQUENCY:
   | PLATFORMS:
   |
   | REVISIONS:
   | VERSION  DATE        WHO              PURPOSE
   | -------  ---------- -----             ------------------------------------------------------
   | 1.0      10/27/05   Curt Lindner   Initial revision
   |************************************************************************************************/
   CURSOR get_current (c_sequence_name VARCHAR2)
   IS
      SELECT     sch.ROWID, next_value, format
            FROM table_num_scheme sch
           WHERE NAME = p_seq_name
      FOR UPDATE NOWAIT;

   v_seq_name          VARCHAR2 (100)        := LTRIM (RTRIM (p_seq_name));
   v_get_current_rec   get_current%ROWTYPE;
   v_next_value        NUMBER;
   v_dummy             NUMBER;
   v_max_attempts      NUMBER                := 10;               -- 01/10/05
   v_program_name      VARCHAR2 (50)         := 'seq';             --01/10/05
   v_error             VARCHAR2 (1000);                            --01/10/05
BEGIN
---------------------------------------------------------------------------
-- NEW CODE TO USE ORACLE SEQUENCES ON SOME HIGH USED TABLES
---------------------------------------------------------------------------
   IF LOWER (p_seq_name) = LOWER ('Action Item ID')
   THEN
      SELECT sa.sequ_action_item_id.NEXTVAL
        INTO o_next_value
        FROM DUAL;

      o_format := '%i';
      RETURN;
   ELSIF LOWER (p_seq_name) = LOWER ('Case ID')
   THEN
      SELECT sa.sequ_case_id.NEXTVAL
        INTO o_next_value
        FROM DUAL;

      o_format := '%i';
      RETURN;
   ELSIF LOWER (p_seq_name) = LOWER ('Individual ID')
   THEN
      SELECT sa.sequ_individual_id.NEXTVAL
        INTO o_next_value
        FROM DUAL;

      o_format := 'IND%i';
      RETURN;
   ELSIF LOWER (p_seq_name) = LOWER ('Interaction ID')
   THEN
      SELECT sa.sequ_interaction_id.NEXTVAL
        INTO o_next_value
        FROM DUAL;

      o_format := '%i';
      RETURN;
   ELSIF LOWER (p_seq_name) = LOWER ('Site ID')
   THEN
      SELECT sa.sequ_site_id.NEXTVAL
        INTO o_next_value
        FROM DUAL;

      o_format := '%i';
      RETURN;
   ELSIF LOWER (p_seq_name) = LOWER ('Temp Cust')
   THEN
      SELECT sa.sequ_temp_cust.NEXTVAL
        INTO o_next_value
        FROM DUAL;

      o_format := '%i';
      RETURN;
   ELSIF LOWER (p_seq_name) = LOWER ('onlineTracking')
   THEN
      SELECT sa.sequ_onlinetracking.NEXTVAL
        INTO o_next_value
        FROM DUAL;

      o_format := '%i';
      RETURN;
   ELSIF LOWER (p_seq_name) = LOWER ('x_merch_ref_id')
   THEN
      SELECT sa.sequ_x_merch_ref_id.NEXTVAL
        INTO o_next_value
        FROM DUAL;

      o_format := '%i';
      RETURN;
   END IF;

---------------------------------------------------------------------------
-- END NEW CODE TO USE ORACLE SEQUENCES ON SOME HIGH USED TABLES
---------------------------------------------------------------------------
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
         UPDATE sa.table_num_scheme
            SET next_value = next_value + 1
          WHERE ROWID = v_get_current_rec.ROWID;

         COMMIT;
      END;
   END IF;

   o_next_value := v_get_current_rec.next_value;
   o_format := v_get_current_rec.format;
END;
/