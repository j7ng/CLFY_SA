CREATE OR REPLACE PROCEDURE sa.Phone_Receive_Temp_file AS
    l_sa                table_user.objid%TYPE;
    r_table_case        table_case%ROWTYPE;
    l_v                 number(2);  --number of valid cases
    l_elm_objid         table_gbst_elm.objid%TYPE;
    l_error             varchar2(200);
    l_case_id           table_case.id_number%TYPE;
    l_case_history      varchar2(32700);
    my_code             NUMBER;
    my_errm             VARCHAR2(32000);
    
    CURSOR c_Receive IS
       SELECT case_number AS t_esn
         FROM x_migr_cases
        WHERE SUBSTR(case_number,1,1) <> 'P' and status is NULL;
                   
    CURSOR c_Case (pc_ESN IN VARCHAR2) IS
         SELECT id_number
         FROM (SELECT c.objid, c.title, c.x_case_type, s.title GBST_ELM_STATUS, c.id_number
                 FROM table_case c, table_gbst_elm s
                WHERE c.casests2gbst_elm = s.objid AND 
                      c.x_esn = pc_ESN AND
                      c.s_title NOT IN ('SIM CARD EXCHANGE','SIM EXCHANGE') AND
                      upper(c.x_case_type) IN ('TECHNOLOGY EXCHANGE','WAREHOUSE','WARRANTY') AND
                      c.casests2gbst_elm IN (SELECT objid
                                               FROM table_gbst_elm
                                              WHERE s_title = 'PENDING')
                ORDER BY c.objid DESC)
         WHERE ROWNUM = 1;
  BEGIN

    SELECT objid 
      INTO l_sa
      FROM table_user t 
     WHERE login_name = 'sa';

    FOR r_Receive IN c_Receive LOOP
      COMMIT;
      l_error := null;
      l_case_id := Null;

      IF r_Receive.t_esn IS NOT NULL THEN
         l_v := 0;
         FOR r_Case IN c_Case (r_Receive.t_esn) LOOP
             BEGIN
                l_case_id := r_Case.id_number;
                l_v := l_v + 1;
             END;
         END LOOP;
      END IF;
      IF l_case_id IS NOT NULL THEN 
         BEGIN
            BEGIN
               SELECT *
                 INTO r_table_case
                 FROM table_case c
                WHERE c.id_number = l_case_id;
            EXCEPTION
               WHEN OTHERS THEN
                   l_error := 'This should not happen. Case: ' || l_case_id;
            END; 
            IF l_error is NOT Null then
               Null; --The ESN will not be marked as Processed;
            ELSE
                BEGIN
                   SELECT objid
                     INTO l_elm_objid
                     FROM table_gbst_elm g 
                    WHERE g.gbst_elm2gbst_lst = (select objid from table_gbst_lst where title = 'Open')
                      AND g.title = 'Received';
                EXCEPTION WHEN OTHERS THEN
                   l_elm_objid := Null;
                END;   
                
                BEGIN
                SAVEPOINT My_Insert;
                INSERT INTO table_act_entry 
                      (objid, act_code, entry_time, addnl_info, act_entry2user, act_entry2case, entry_name2gbst_elm)
                   VALUES 
                      (sa.seq('act_entry') ,2000, sysdate, 'ESN Received', l_sa, r_table_case.objid, l_elm_objid);
                EXCEPTION WHEN OTHERS THEN
                   my_code := SQLCODE;
                   my_errm := SQLERRM;
                   l_error := 'The insertion in table_act_entry for case '|| r_table_case.id_number || ' had the following error: ' || my_code || ': ' || my_errm;
                END;
                IF l_error is null THEN
                   BEGIN
                      l_case_history := r_table_case.case_history;
                      UPDATE table_case c
                         SET case_history = TRIM(l_case_history) || CHR(10) || CHR(13) || ' *** Logged by Integration *** ' || CHR(10) || ' ESN Received on ' || sysdate,
                             site_time = sysdate,
                             casests2gbst_elm = DECODE(l_elm_objid, Null, casests2gbst_elm, l_elm_objid)  
                       WHERE objid = r_table_case.objid;
                   EXCEPTION WHEN OTHERS THEN
                      ROLLBACK TO SAVEPOINT My_Insert;
                      my_code := SQLCODE;
                      my_errm := SQLERRM;
                      l_error := 'The actualization of table_case for case '|| r_table_case.id_number || ' had the following error: ' || my_code || ': ' || my_errm;
                   END;
                END IF;
                IF l_error is null then                
                   Update x_migr_cases 
                      SET case_number = 'P ' || case_number
                   WHERE case_number = r_receive.t_esn;
                ELSE
                   Null; --The ESN will not be marked as Processed;
                END IF;
            END IF;  
         EXCEPTION WHEN OTHERS THEN
            Null; --The ESN will not be marked as Processed;
         END;
      END IF;
      COMMIT;
    END LOOP;
  END Phone_Receive_Temp_file;
/