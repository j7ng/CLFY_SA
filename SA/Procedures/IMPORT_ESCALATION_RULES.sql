CREATE OR REPLACE PROCEDURE sa.import_escalation_rules (
   p_error_no    OUT   VARCHAR2,
   p_error_str   OUT   VARCHAR2
)
AS
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
   | 1.0      10/27/05   Natalio Guada    Initial revision
   |************************************************************************************************/
--Priority and Status
   CURSOR c1
   IS
      SELECT x_case_type, x_title, st.title status, pr.title priority,
             qu.title queue
        FROM table_x_case_dispatch_conf dis,
             table_x_case_conf_hdr hdr,
             table_gbst_elm st,
             table_gbst_elm pr,
             table_queue qu
       WHERE dis.dispatch2conf_hdr = hdr.objid
         AND dis.dispatch2conf_hdr = hdr.objid
         AND dis.status2gbst_elm <> -1
         AND dis.priority2gbst_elm <> -1
         AND st.objid = dis.status2gbst_elm
         AND pr.objid = dis.priority2gbst_elm
         AND qu.objid = dis.dispatch2queue
         AND x_case_type IS NOT NULL
         AND x_title IS NOT NULL;

--Priority Only
   CURSOR c2
   IS
      SELECT x_case_type, x_title, pr.title priority, qu.title queue
        FROM table_x_case_dispatch_conf dis,
             table_x_case_conf_hdr hdr,
             table_gbst_elm pr,
             table_queue qu
       WHERE dis.dispatch2conf_hdr = hdr.objid
         AND dis.dispatch2conf_hdr = hdr.objid
         AND dis.status2gbst_elm = -1
         AND dis.priority2gbst_elm <> -1
         AND pr.objid = dis.priority2gbst_elm
         AND qu.objid = dis.dispatch2queue
         AND x_case_type IS NOT NULL
         AND x_title IS NOT NULL;

--Status Only
   CURSOR c3
   IS
      SELECT x_case_type, x_title, st.title status, qu.title queue
        FROM table_x_case_dispatch_conf dis,
             table_x_case_conf_hdr hdr,
             table_gbst_elm st,
             table_queue qu
       WHERE dis.dispatch2conf_hdr = hdr.objid
         AND dis.dispatch2conf_hdr = hdr.objid
         AND dis.status2gbst_elm <> -1
         AND dis.priority2gbst_elm = -1
         AND st.objid = dis.status2gbst_elm
         AND qu.objid = dis.dispatch2queue
         AND x_case_type IS NOT NULL
         AND x_title IS NOT NULL;

--No Status, No Priority
   CURSOR c4
   IS
      SELECT x_case_type, x_title, qu.title queue
        FROM table_x_case_dispatch_conf dis,
             table_x_case_conf_hdr hdr,
             table_queue qu
       WHERE dis.dispatch2conf_hdr = hdr.objid
         AND dis.dispatch2conf_hdr = hdr.objid
         AND dis.status2gbst_elm = -1
         AND dis.priority2gbst_elm = -1
         AND qu.objid = dis.dispatch2queue
         AND x_case_type IS NOT NULL
         AND x_title IS NOT NULL;

   rule1       VARCHAR2 (1000);
   rule2       VARCHAR2 (1000);
   rule3       VARCHAR2 (1000);
   rule4       VARCHAR2 (1000);
   full_rule   LONG;
BEGIN
   p_error_no := '0';
   p_error_str := 'SUCCESS';

   FOR r1 IN c1
   LOOP                                                 --Priority and Status
      rule1 :=
            'AUTO_DISPATCH ((x_case_type starts with "'
         || TRIM (r1.x_case_type)
         || '")';
      rule2 := ' AND (title starts with "' || TRIM (r1.x_title) || '")';
      rule3 :=
            ' AND (casests2gbst_elm:title starts with "'
         || TRIM (r1.status)
         || '")';
      rule4 :=
            ' AND (respprty2gbst_elm:title starts with "'
         || TRIM (r1.priority)
         || '"))->"'
         || r1.queue
         || '";';
      full_rule := full_rule || rule1 || rule2 || rule3 || rule4 || CHR (10);
   END LOOP;

   FOR r1 IN c2
   LOOP                                                        --Priority Only
      rule1 :=
         'AUTO_DISPATCH ((x_case_type starts with "' || r1.x_case_type
         || '")';
      rule2 := ' AND (title starts with "' || r1.x_title || '")';
      rule3 :=
            ' AND (respprty2gbst_elm:title starts with "'
         || r1.priority
         || '"))->"'
         || r1.queue
         || '";';
      full_rule := full_rule || rule1 || rule2 || rule3 || CHR (10);
   END LOOP;

   FOR r1 IN c3
   LOOP                                                         -- Status Only
      rule1 :=
         'AUTO_DISPATCH ((x_case_type starts with "' || r1.x_case_type
         || '")';
      rule2 := ' AND (title starts with "' || r1.x_title || '")';
      rule3 :=
            ' AND (casests2gbst_elm:title starts with "'
         || r1.status
         || '"))->"'
         || r1.queue
         || '";';
      full_rule := full_rule || rule1 || rule2 || rule3 || CHR (10);
   END LOOP;

   FOR r1 IN c4
   LOOP                                               --No Status, No Priority
      rule1 :=
         'AUTO_DISPATCH ((x_case_type starts with "' || r1.x_case_type
         || '")';
      rule2 :=
            ' AND (title starts with "'
         || r1.x_title
         || '"))->"'
         || r1.queue
         || '";';
      full_rule := full_rule || rule1 || rule2 || CHR (10);
   END LOOP;

   UPDATE table_rule
      SET rule_text = full_rule
    WHERE operation = 'DISPATCH';

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      p_error_no := SQLCODE;
      p_error_str := SQLERRM;
END;
/