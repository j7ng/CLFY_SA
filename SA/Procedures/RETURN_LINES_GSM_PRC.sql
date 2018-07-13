CREATE OR REPLACE PROCEDURE sa."RETURN_LINES_GSM_PRC"
IS

CURSOR get_lines_cur
IS
SELECT pi.part_serial_no, ct.x_iccid
FROM
table_x_carrier_rules car,
table_x_carrier ca,
table_x_call_trans ct,
table_part_inst pi,
table_site_part sp
WHERE
    sp.part_status = 'Inactive'
AND state_value = 'GSM'
AND sp.x_min = pi.part_serial_no -- lines
AND pi.x_part_inst_status = '37' -- reserved
AND sp.objid = ct.call_trans2site_Part
AND x_call_trans2carrier = ca.objid
AND ca.carrier2rules_gsm = car.objid
AND (trunc(sysdate) - trunc(sp.x_expire_dt)) > car.x_line_expire_days ;




BEGIN


FOR  get_lines_rec IN  get_lines_cur LOOP

      UPDATE table_part_inst
        SET x_part_inst_status = '17',
            status2x_code_table = (SELECT objid FROM table_x_code_table WHERE x_code_number = '17')
      WHERE part_serial_no = get_lines_rec.part_serial_no;

      COMMIT;

      UPDATE table_x_sim_inv
        SET x_sim_inv_status = '250',
            x_sim_status2x_code_table = (SELECT objid FROM table_x_code_table WHERE x_code_number = '250')
      WHERE
           x_sim_serial_no = get_lines_rec.x_iccid
           and x_sim_inv_status = '251';


      COMMIT;

END LOOP;

END;
/