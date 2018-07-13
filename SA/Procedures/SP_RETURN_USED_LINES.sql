CREATE OR REPLACE PROCEDURE sa."SP_RETURN_USED_LINES"
Is
CURSOR c1
IS
/* Get all MINs with status of 12 and associated to Verizon*/
SELECT a.part_serial_no,
       a.x_domain,
       c.x_line_return_days
  FROM table_part_inst a,
       table_x_carrier b,
       table_x_carrier_group d,
       table_x_carrier_rules c,
       table_x_parent e
 WHERE b.carrier2rules = c.objid
   AND e.x_parent_id ||''= '5'
   AND d.x_carrier_group2x_parent = e.objid
   AND b.carrier2carrier_group = d.objid
   AND b.x_status = 'ACTIVE'
   AND a.part_inst2carrier_mkt = b.objid
   AND a.x_domain = 'LINES'
   AND a.x_part_inst_status = '12';

counter       NUMBER := 0;
StartDate     VARCHAR2(35);
EndDate       VARCHAR2(35);
v_program     VARCHAR2(25);
v_action      VARCHAR2(25);
v_status      VARCHAR2(2);
v_step        VARCHAR2(100);
e_exceptions  EXCEPTION;
     	l_procedure_name CONSTANT VARCHAR2(100) := 'SP_RETURN_USED_LINES';
	l_start_date                 DATE                               := SYSDATE;
	l_recs_processed             NUMBER                             := 0;


BEGIN
 v_action  := 'RETURN USED LINE';
 v_program := 'SP_RETURN_USED_LINES';
 v_status  := '17';
 StartDate := TO_CHAR(SYSDATE,'mm/dd/yyyy hh:mi:ss pm');

 FOR c1_rec IN c1 LOOP
       /* If MIN's line_return_days=1 update status=17 and write to pi_hist, else do nothing */
       IF c1_rec.x_line_return_days = 1 THEN
        counter := counter+ 1;
        v_step := 'Updating part_inst record';
        /* If returns TRUE call SA.TOSS_UTIL_PKG.insert_pi_hist_fun */
        If sa.TOSS_UTIL_PKG.set_pi_status_fun(c1_rec.part_serial_no,
                                              c1_rec.x_domain,v_status,v_program) THEN
           v_step := 'Insert pi_hist record';
           l_recs_processed := l_recs_processed  + 1;
           /* If returns FALSE RAISE e_exceptions */
           IF NOT sa.TOSS_UTIL_PKG.insert_pi_hist_fun(c1_rec.part_serial_no,c1_rec.x_domain,v_action,v_program) Then
            RAISE e_exceptions;
           END IF;
        ELSE
         RAISE e_exceptions;
        END IF;
       END IF;
 END LOOP;
  EndDate := TO_CHAR(SYSDATE,'mm/dd/yyyy hh:mi:ss pm');
  Dbms_output.put_line('Rows Affected: ' || counter || '  StartDate:'||StartDate || '  EndDate:'|| EndDate);

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

EXCEPTION
 WHEN e_exceptions THEN
  dbms_output.put_line('Exception: ' || v_step || ', ' || SUBSTR(SQLERRM,1,100));
 WHEN OTHERS THEN
  dbms_output.put_line(SUBSTR(SQLERRM,1,100));
END SP_RETURN_USED_LINES;
/