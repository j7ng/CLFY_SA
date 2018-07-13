CREATE OR REPLACE PROCEDURE sa."SP_ILD_MOTRICITY_TEMP"
IS
   CURSOR c1
   IS
      SELECT it.objid ild_objid, sp.x_min sp_min, it.x_min ild_min
        FROM table_x_ild_transaction it, table_site_part sp
       WHERE x_ild_status = 'Hold' -- CR11767
         AND x_ild_trans_type = 'Activation'
         AND x_target_system = 'motricity'
         AND sp.x_service_id = it.x_esn
         AND sp.part_status || '' = 'Active'
         AND sp.x_min NOT LIKE 'T%'
         AND it.X_TRANSACT_DATE >= trunc(sysdate)-2;

     	l_procedure_name CONSTANT VARCHAR2(100) := 'sp_ild_motricity_temp';
	l_start_date                 DATE                               := SYSDATE;
	l_recs_processed             NUMBER                             := 0;

BEGIN
   FOR r1 IN c1
   LOOP
      UPDATE table_x_ild_transaction
         SET x_min = r1.sp_min,
             x_ild_status = 'Pending'
       WHERE x_ild_trans_type = 'Activation'
         AND x_target_system = 'motricity'
         AND objid = r1.ild_objid;

      COMMIT;
      l_recs_processed := l_recs_processed + 1;

   END LOOP;

   COMMIT;

   IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                               l_start_date,
                                               SYSDATE,
                                               l_recs_processed,
                                               'SUCCESS',
                                               l_procedure_name
                                              )
   THEN
      COMMIT;
   END IF;

END;
/