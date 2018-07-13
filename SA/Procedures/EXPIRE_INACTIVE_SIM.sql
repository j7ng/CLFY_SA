CREATE OR REPLACE PROCEDURE sa.expire_inactive_sim(
                                                   i_days      NUMBER   DEFAULT 366,
												   i_truncate  VARCHAR2 DEFAULT 'Y',
                                                   i_rowlimit  NUMBER   DEFAULT 1000,
												   o_response OUT VARCHAR2
												  ) IS

   pcount                NUMBER := 0;
   row_count             NUMBER := 0;
   v_ins_cnt             NUMBER := 0;
-- Main Data Load cursor
CURSOR cur_main_load IS
   SELECT /*+ parallel(a, 6 ) */
          a.objid             sim_inv_objid,
          a.x_sim_serial_no,
          a.x_sim_inv_status sim_inv_status,
          a.x_sim_po_number,
          a.x_sim_imsi,
          e.objid            part_num_objid,
          e.part_number,
          e.domain,
          a.x_inv_insert_date,
          a.x_last_update_date x_inv_last_update_date,
		  NULL pi_serial_no,
		  'N' x_processed_flag,
		  NULL update_status,
		  NULL update_date
     FROM sa.table_x_sim_inv a,
	      sa.table_mod_level d,
		  sa.table_part_num  e
    WHERE 1 = 1
          --and a.x_sim_serial_no = '8901260710013867023'
		  AND a.x_sim_inv_status   = '251'
          AND a.x_last_update_date < TRUNC (SYSDATE - i_days)
          AND a.x_sim_inv2part_mod = d.objid
          AND d.part_info2part_num = e.objid
          AND e.part_number LIKE '%SIMV9%'
		  AND ROWNUM < i_rowlimit;
   TYPE ty_sim_load IS TABLE OF cur_main_load%ROWTYPE;
   tb_sim_load ty_sim_load;
/* Main Cursor */
CURSOR cur_main IS
   SELECT tp.ROWID, tp.*
    FROM sa.table_temp_sim_inv_reserved tp
   WHERE 1 = 1
	 AND tp.x_processed_flag = 'N' ;
/* Cursor to get Part inst details from the ESN */
CURSOR cur_pi_sim (p_sim_num IN VARCHAR) IS
   SELECT objid, part_serial_no, x_iccid
     FROM table_part_inst
    WHERE x_domain = 'PHONES'
	  AND x_iccid  = p_sim_num;
   cur_pi_sim_rec        cur_pi_sim%ROWTYPE;
/* Cursor to get Active Site Part details from the ESN */
CURSOR cur_inactive_sp (p_serial_num   IN VARCHAR) IS
   SELECT *
     FROM (SELECT x_service_id,
                  x_min,
                  objid sp_objid,
                  install_date,
                  part_status,
                  x_expire_dt,
                  service_end_dt,
                  x_deact_reason,
                  site_objid,
                  x_iccid,
                  RANK () OVER (PARTITION BY x_iccid ORDER BY install_date DESC) rk
            FROM table_site_part
           WHERE 1 = 1
		     AND x_service_id = p_serial_num
          )
    WHERE rk = 1;
   cur_inactive_sp_rec   cur_inactive_sp%ROWTYPE;
/* Cursor to get last call trans from site part esn  */
CURSOR cur_last_ct (sp_esn    VARCHAR2)IS
   SELECT *
     FROM (SELECT ct.objid    ct_objid,
                  ct.x_transact_date,
                  ct.x_service_id,
                  ct.x_action_type,
                  ct.x_result ct_result,
                  ct.x_total_units,
                  ct.x_sub_sourcesystem,
                  ct.x_sourcesystem,
                  RANK () OVER (PARTITION BY ct.x_service_id ORDER BY ct.x_transact_date DESC) rk
             FROM table_x_call_trans ct
            WHERE 1 = 1
			  AND ct.x_service_id = sp_esn
		  )
    WHERE rk = 1;
   cur_last_ct_rec       cur_last_ct%ROWTYPE;
BEGIN
  DBMS_OUTPUT.put_line ('PROCESS STARTED AT     : ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY hh:mi:ss AM'));
  --dbms_output.put_line(' Parameters :'||i_days||' '||i_truncate||' '||i_rowlimit);
  -- Truncate before Load
   IF i_truncate = 'Y' THEN
	  BEGIN
		EXECUTE IMMEDIATE 'TRUNCATE TABLE sa.table_temp_sim_inv_reserved';
	  EXCEPTION WHEN OTHERS THEN
		NULL;
	  END;
   END IF;
   DBMS_OUTPUT.put_line (
      'TRUNCATE COMPLETED AT  : ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY hh:mi:ss AM'));
-- Load the data to temp table_temp_sim_inv_reserved
   OPEN cur_main_load;
   LOOP
    FETCH cur_main_load BULK COLLECT
      INTO tb_sim_load LIMIT 100;
    EXIT WHEN tb_sim_load.COUNT = 0;
    --
    FOR j IN tb_sim_load.FIRST .. tb_sim_load.COUNT LOOP
      INSERT INTO sa.table_temp_sim_inv_reserved
	       VALUES (tb_sim_load(j).x_sim_serial_no,
			       tb_sim_load(j).pi_serial_no,
                   tb_sim_load(j).sim_inv_objid,
				   tb_sim_load(j).sim_inv_status,
				   tb_sim_load(j).x_sim_po_number,
				   tb_sim_load(j).x_sim_imsi,
				   tb_sim_load(j).part_num_objid,
				   tb_sim_load(j).part_number,
				   tb_sim_load(j).domain,
				   tb_sim_load(j).x_inv_insert_date,
				   tb_sim_load(j).x_inv_last_update_date,
				   tb_sim_load(j).x_processed_flag,
				   tb_sim_load(j).update_status,
				   tb_sim_load(j).update_date
				  );
    v_ins_cnt := v_ins_cnt + 1;
	END LOOP;
	--
    COMMIT;
   END LOOP;
  --
  CLOSE cur_main_load;
  DBMS_OUTPUT.put_line ('RECORDS INSERTED       : '||v_ins_cnt);
  DBMS_OUTPUT.put_line ('DATA LOAD COMPLETED    : ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY hh:mi:ss AM'));
  --
   FOR cur_main_rec IN cur_main
   LOOP
      IF cur_inactive_sp%ISOPEN
      THEN
         CLOSE cur_inactive_sp;
      END IF;
      IF cur_last_ct%ISOPEN
      THEN
         CLOSE cur_last_ct;
      END IF;
      OPEN cur_pi_sim (cur_main_rec.x_sim_serial_no);
		FETCH cur_pi_sim INTO cur_pi_sim_rec;
		row_count := cur_pi_sim%rowcount;
        IF row_count = 1 THEN--{
			IF cur_pi_sim%FOUND THEN--{
				OPEN cur_inactive_sp (cur_pi_sim_rec.part_serial_no);
				FETCH cur_inactive_sp INTO cur_inactive_sp_rec;
				IF cur_inactive_sp%FOUND THEN --{
					IF cur_inactive_sp_rec.part_status <> 'Active' THEN--{
						OPEN cur_last_ct (cur_inactive_sp_rec.x_service_id);
						FETCH cur_last_ct INTO cur_last_ct_rec;
						IF cur_last_ct%FOUND THEN --{
							IF cur_last_ct_rec.x_transact_date < TRUNC (SYSDATE - i_days) and cur_last_ct_rec.x_action_type = '2' THEN --{
								UPDATE table_x_sim_inv
								   SET x_sim_Inv_status          = '250',
									   x_sim_status2x_code_table = 268438609,
									   x_last_update_date        = SYSDATE
								 WHERE x_sim_serial_no           = cur_main_rec.x_sim_serial_no;
								pcount := pcount + 1;
								UPDATE sa.table_temp_sim_inv_reserved
								   SET pi_serial_no     = cur_inactive_sp_rec.x_service_id,
									   update_status    = 'Completed - Deact found',
									   x_processed_flag = 'Y',
									   update_date      = SYSDATE
								 WHERE x_sim_serial_no  = cur_main_rec.x_sim_serial_no;
							ELSE
								UPDATE sa.table_temp_sim_inv_reserved
								   SET pi_serial_no    =  cur_inactive_sp_rec.x_service_id,
									   update_status   = 'Call Trans found within 365 Days : '||cur_last_ct_rec.x_transact_date,
									   update_date     = SYSDATE
								 WHERE x_sim_serial_no = cur_main_rec.x_sim_serial_no;
							END IF; --}
                        ELSE
							UPDATE table_x_sim_inv
							   SET x_sim_Inv_status = '250',
								   x_sim_status2x_code_table = 268438609,
								   x_last_update_date = SYSDATE
							 WHERE x_sim_serial_no = cur_main_rec.x_sim_serial_no;
							pcount := pcount + 1;
							UPDATE sa.table_temp_sim_inv_reserved
							   SET pi_serial_no =
									  cur_inactive_sp_rec.x_service_id,
								   update_status = 'Completed - CT Not found',
								   x_processed_flag = 'Y',
								   update_date = SYSDATE
							 WHERE x_sim_serial_no = cur_main_rec.x_sim_serial_no;
                        END IF;--}
						CLOSE cur_last_ct;
                    END IF;--}
                END IF;--}
            END IF;--}
			--CLOSE cur_pi_sim;
        ELSIF row_count = 0 THEN
			UPDATE table_x_sim_inv
			   SET x_sim_Inv_status          = '250',
				   x_sim_status2x_code_table = 268438609,
				   x_last_update_date        = SYSDATE
			 WHERE x_sim_serial_no           = cur_main_rec.x_sim_serial_no;
			pcount := pcount + 1;
			UPDATE sa.table_temp_sim_inv_reserved
			   SET update_status    = 'Completed - ESN not Found',
				   x_processed_flag = 'Y',
				   update_date      = SYSDATE
			 WHERE x_sim_serial_no  = cur_main_rec.x_sim_serial_no;
        ELSIF row_count > 1  THEN
			UPDATE sa.table_temp_sim_inv_reserved
			   SET update_status   = 'Found Duplicate ESNs',
				   update_date     = SYSDATE
			 WHERE x_sim_serial_no = cur_main_rec.x_sim_serial_no;
        END IF;--}
	  CLOSE cur_pi_sim;
   END LOOP;
   DBMS_OUTPUT.put_line ('RECORDS PROCESSED      : ' || pcount );
   DBMS_OUTPUT.put_line ('PROCESS COMPLETED AT   : ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY hh:mi:ss AM'));
   o_response := 'No of Records Processed : '||pcount;
   COMMIT;
EXCEPTION WHEN OTHERS THEN
o_response := 'Excption Occured : '||SQLERRM;
END;
-- ANTHILL_TEST PLSQL/SA/Procedures/EXPIRE_INACTIVE_SIM.sql 	CR54302: 1.5
/