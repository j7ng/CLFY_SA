CREATE OR REPLACE PROCEDURE sa.CLOSE_OTA_TRANS_PRC(
   p_call_trans_list IN VARCHAR2,
   p_error_num OUT NUMBER,
   p_error_string OUT VARCHAR2
)
IS
   error_string VARCHAR2(200) := NULL;
   error_num VARCHAR2(200) := 0;
   hold1 VARCHAR2(200) := NULL;
   hold2 VARCHAR2(200) := NULL;
   total_codes NUMBER := 0;
   l_max_days NUMBER := 15;
   l_upd_count NUMBER := 0;
   TYPE call_trans_list_type
   IS
   TABLE OF VARCHAR2 (30) INDEX BY BINARY_INTEGER;
   call_trans_list_tab call_trans_list_type;
   clear_call_trans_list_tab call_trans_list_type;
   -------------------------------------------------------------------------------------
   CURSOR OverduePendingTrans(
      c_call_trans_objid IN NUMBER
   )
   IS
   SELECT ota.x_action_type,
      ota.X_TRANSACTION_DATE,
      ota.x_status,
      ota.x_mode,
      ota.X_OTA_TRANS2X_CALL_TRANS,
      ota.X_ESN,
      ota.X_MIN,
      ota.objid
   FROM table_x_ota_transaction ota
   WHERE 1 = 1
   AND ota.objid = c_call_trans_objid;
   -------------------------------------------------------------------------------------
   CURSOR c2(
      c_OTA_TRANS2X_CALL_TRANS IN NUMBER
   )
   IS
   SELECT COUNT(objid) code_count
   FROM sa.table_x_code_hist
   WHERE CODE_HIST2CALL_TRANS = c_OTA_TRANS2X_CALL_TRANS
   AND X_CODE_ACCEPTED||'' = 'OTAPENDING';
   -------------------------------------------------------------------------------------
   PROCEDURE get_indv_ct_sub
   IS
      l_call_trans_list VARCHAR2 (1000) := p_call_trans_list;
      i PLS_INTEGER := 1;
   BEGIN
      call_trans_list_tab := clear_call_trans_list_tab;
      WHILE LENGTH (l_call_trans_list) > 0
      LOOP
         IF INSTR (l_call_trans_list, ',') = 0
         THEN
            call_trans_list_tab(i) := LTRIM (RTRIM (l_call_trans_list));
            EXIT;
         ELSE
            call_trans_list_tab(i) := LTRIM (RTRIM (SUBSTR (l_call_trans_list,
            1, INSTR (l_call_trans_list, ',') - 1)));
            l_call_trans_list := LTRIM (RTRIM (SUBSTR (l_call_trans_list, INSTR
            (l_call_trans_list, ',') + 1)));
            i := i + 1;
         END IF;
      END LOOP;
      FOR i IN 1 .. call_trans_list_tab.LAST
      LOOP
         DBMS_OUTPUT.put_line(i);
         DBMS_OUTPUT.put_line('call_trans_list:'||call_trans_list_tab(i));
      END LOOP;
   END;
-------------------------------------------------------------------------------------
BEGIN
   IF LTRIM(RTRIM(p_call_trans_list))
   IS
   NULL
   THEN
      p_error_num := 1;
      p_error_string := 'No Call Trans List';
      RETURN;
   END IF;
   get_indv_ct_sub;
   IF call_trans_list_tab.count = 0
   THEN
      p_error_num := 1;
      p_error_string := 'No Call Trans List';
      RETURN;
   END IF;
   FOR i IN 1 .. call_trans_list_tab.LAST
   LOOP
      FOR c1_rec IN OverduePendingTrans(call_trans_list_tab(i))
      LOOP
         FOR c2_rec IN c2(c1_rec.X_OTA_TRANS2X_CALL_TRANS)
         LOOP
            sa.convert_bo_to_sql_pkg.otacodeacceptedupdate(c1_rec.X_OTA_TRANS2X_CALL_TRANS
            , hold1, hold2, error_num, error_string);
         END LOOP;
         UPDATE table_x_ota_transaction SET x_status = 'Completed'
         WHERE x_ota_trans2x_call_trans = c1_rec.X_OTA_TRANS2X_CALL_TRANS;
         sa.convert_bo_to_sql_pkg.OTAcompleteTransaction(c1_rec.X_ESN, c1_rec.X_OTA_TRANS2X_CALL_TRANS
         , c1_rec.X_MIN, total_codes, 'English', error_num, error_string);
         IF SQL%rowcount > 0
         THEN
            l_upd_count := l_upd_count + 1;
         END IF;
         COMMIT;
      END LOOP;
   END LOOP;
   IF call_trans_list_tab.count <> l_upd_count
   THEN
      p_error_num := 1;
      p_error_string := 'Count Mismatch';
      RETURN;
   ELSE
      p_error_num := 0;
      p_error_string := 'Success';
      RETURN;
   END IF;
END close_ota_trans_prc;
/