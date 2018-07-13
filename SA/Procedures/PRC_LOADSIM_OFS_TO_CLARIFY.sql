CREATE OR REPLACE PROCEDURE sa."PRC_LOADSIM_OFS_TO_CLARIFY"
AS

  CURSOR c_sim IS
      SELECT stg.rowid, stg.*
        FROM x_load_iccid_tmp stg
       WHERE 1 = 1
         AND stg.sim_processed = 'N';
    c_rec c_sim%ROWTYPE;

    lv_mod_level NUMBER;
    lv_sim_exist PLS_INTEGER;

    lv_count     PLS_INTEGER :=0;
    lv_message   VARCHAR2(100);

    lv_procedure_name VARCHAR2(80) := 'loadsim_ofs_to_clarify';

    exp_no_mod_level EXCEPTION;
    exp_sim_exist    EXCEPTION;

    err_msg  VARCHAR2(200);

    time_before BINARY_INTEGER;
    time_after BINARY_INTEGER;
    v_po_num sa.table_x_sim_inv.x_sim_po_number%TYPE; --CR42273

BEGIN

  time_before := DBMS_UTILITY.GET_TIME;

  FOR c_rec IN c_sim
  LOOP

  BEGIN

    BEGIN
      SELECT /*+RESULT_CACHE */
             MAX(ml.objid)
        INTO lv_mod_level
        FROM table_mod_level ml,
             table_part_num pn
       WHERE 1 = 1
         AND ml.part_info2part_num = pn.objid
         AND pn.part_number = c_rec.tf_num
         AND ml.active = 'Active'
         AND pn.domain = 'SIM CARDS';
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE exp_no_mod_level;
     END;

     ---------------------Check If card exists in Clarify-----------------------
      SELECT COUNT(1)
        INTO lv_sim_exist
        FROM dual
       WHERE 1 = 1
         AND EXISTS ( SELECT 1
                        FROM table_x_sim_inv
                       WHERE x_sim_serial_no = c_rec.iccid);

      IF lv_sim_exist <> 0 THEN
        RAISE exp_sim_exist;
      END IF;
      --------------------------------------------------------------------------

      --CR42273 begin
      IF c_rec.tf_num LIKE '%V9%' AND instr(c_rec.po_num,'_')>0 THEN
        v_po_num := substr(c_rec.po_num,1,instr(c_rec.po_num,'_')-1);
      ELSE
        v_po_num := c_rec.po_num;
      END IF;
      --CR42273 end

      INSERT INTO table_x_sim_inv
                 (objid,
                  x_sim_serial_no,
                  x_sim_inv_status,
                  x_sim_po_number,
                  x_created_by2user,
                  x_sim_inv2part_mod,
                  x_sim_inv2inv_bin,
                  x_inv_insert_date,
                  x_sim_status2x_code_table,
                  x_sim_imsi,
                  x_pin1,
                  x_pin2,
                  x_puk1,
                  x_puk2,
                  x_qty,
                  Expiration_Date --CR42894 added this column
                  )
           VALUES(sa.seq('X_SIM_INV'),
                  c_rec.iccid,
                  '253',
                  v_po_num, --CR42273 use v_po_num instead of c_rec.po_num,
                  268435556,
                  lv_mod_level,
                  268495405,
                  SYSDATE,
                  268438606,
                  c_rec.imsi,
                  c_rec.pin1,
                  c_rec.pin2,
                  c_rec.puk1,
                  c_rec.puk2,
                  c_rec.quantity,
                  c_rec.Expiration_Date --CR42894 added this column
                  );

      UPDATE x_load_iccid_tmp
         SET sim_processed = 'Y',
             last_update_date = SYSDATE,
             last_updated_by = lv_procedure_name
       WHERE rowid = c_rec.rowid;

      COMMIT;

    EXCEPTION
      WHEN exp_no_mod_level THEN
        lv_message := 'Mod Level Not Found';
        TOSS_UTIL_PKG.insert_error_tab_proc (
             c_rec.tf_num,
             SUBSTR(c_rec.iccid, 1, 50),
             lv_procedure_name,
             'Mod Level Not Found'
         );
		 UPDATE x_load_iccid_tmp
         SET sim_processed = 'E', error_details = lv_message,
             last_update_date = SYSDATE,
             last_updated_by = lv_procedure_name
		 WHERE rowid = c_rec.rowid;
		 COMMIT;

      WHEN exp_sim_exist THEN
        lv_message := 'SIM exist in Clarify';
        TOSS_UTIL_PKG.insert_error_tab_proc (
             'Sim Load Procedure tf_864_sim_data',
             SUBSTR(c_rec.iccid, 1, 50),
             lv_procedure_name,
             'SIM exist in Clarify'
         );
		 UPDATE x_load_iccid_tmp
         SET sim_processed = 'E', error_details = lv_message,
             last_update_date = SYSDATE,
             last_updated_by = lv_procedure_name
		 WHERE rowid = c_rec.rowid;
		 COMMIT;

      WHEN OTHERS THEN
        lv_message := 'An error occurred';
        err_msg    := SUBSTR(SQLERRM, 1, 200);
        TOSS_UTIL_PKG.insert_error_tab_proc (
               'Sim Load Procedure tf_864_sim_data',
               SUBSTR(c_rec.iccid, 1, 50),
               lv_procedure_name,
               err_msg
           );
        ROLLBACK;
		UPDATE x_load_iccid_tmp
        SET sim_processed = 'E', error_details = err_msg,
             last_update_date = SYSDATE,
             last_updated_by = lv_procedure_name
		WHERE rowid = c_rec.rowid;
		COMMIT;
      END;

  END LOOP;

  time_after := DBMS_UTILITY.GET_TIME;
  DBMS_OUTPUT.PUT_LINE(ROUND((time_after - time_before)/100, 2) );

END prc_loadsim_ofs_to_clarify;
/