CREATE OR REPLACE FUNCTION sa."GETSOFTPIN" (ip_pin_part_num  IN table_part_inst.part_serial_no%TYPE,
                                       ip_inv_bin_objid IN table_inv_bin.objid%TYPE DEFAULT 0,
                                       p_consumer       IN table_x_cc_red_inv.x_consumer%TYPE DEFAULT NULL,--CR42260
                                       op_soft_pin      OUT table_x_cc_red_inv.x_red_card_number%TYPE,
                                       op_smp_number    OUT table_x_cc_red_inv.x_smp%TYPE,
                                       op_err_msg       OUT VARCHAR2)
RETURN NUMBER
IS --return 0 if successful,else return 1;
  v_ml_objid   table_mod_level.objid%TYPE;
  o_next_value NUMBER;
  o_format     VARCHAR2 (200);
  p_status     VARCHAR2 (200);
  p_msg        VARCHAR2 (200);
  v_proc_name  VARCHAR2 (80) := 'getSoftPin';
  v_action     biz_error_table.error_num%TYPE;
  v_error_msg  biz_error_table.error_text%TYPE;
  card_status CONSTANT VARCHAR2(2) := '42';
  uerror EXCEPTION;
BEGIN
    BEGIN
        SELECT ml.objid mod_level_objid
        INTO   v_ml_objid
        FROM   table_part_num pn,
               table_mod_level ml
        WHERE  1 = 1
               AND pn.part_number = ip_pin_part_num
               AND pn.domain = 'REDEMPTION CARDS'
               AND To_char(pn.x_redeem_units) = ml.s_mod_level
               AND ml.part_info2part_num = pn.objid;
    EXCEPTION
        WHEN OTHERS THEN
          op_err_msg := 'Unable to retrieve PIN part_number'
                        ||ip_pin_part_num;

          RETURN 1;
    END;

    Next_id ('X_MERCH_REF_ID', o_next_value, o_format);

    Sp_reserve_app_card (o_next_value, 1, 'REDEMPTION CARDS', p_consumer,
    p_status,
    p_msg);

    IF p_msg != 'Completed' THEN
      v_action := 'sp_reserve_app_card failed';

      v_error_msg := Substr(p_msg, 1, 300);

      RAISE uerror;
    ELSE
      BEGIN
          SELECT x_red_card_number,
                 x_smp
          INTO   op_soft_pin, op_smp_number
          FROM   table_x_cc_red_inv
          WHERE  x_reserved_id = o_next_value;
      EXCEPTION
          WHEN OTHERS THEN
            v_action := 'Unable to retrrieve pin from cc_red_inv';

            v_error_msg := Substr(SQLERRM, 1, 300);

            RAISE uerror;
      END;
    END IF;

    dbms_output.Put_line('Inserting PI rec');

    INSERT INTO table_part_inst
                (objid,
                 last_pi_date,
                 last_cycle_ct,
                 next_cycle_ct,
                 last_mod_time,
                 last_trans_time,
                 date_in_serv,
                 repair_date,
                 warr_end_date,
                 x_cool_end_date,
                 part_status,
                 hdr_ind,
                 x_sequence,
                 x_insert_date,
                 x_creation_date,
                 x_domain,
                 x_deactivation_flag,
                 x_reactivation_flag,
                 x_red_code,
                 part_serial_no,
                 x_part_inst_status,
                 part_inst2inv_bin,
                 created_by2user,
                 status2x_code_table,
                 n_part_inst2part_mod,
                 part_to_esn2part_inst)
    VALUES      ( Seq ('part_inst'),--objid
                 To_date ('01/01/1753', 'mm/dd/yyyy'),--last_pi_date
                 To_date ('01/01/1753', 'mm/dd/yyyy'),--last_cycle_ct
                 To_date ('01/01/1753', 'mm/dd/yyyy'),--next_cycle_ct
                 To_date ('01/01/1753', 'mm/dd/yyyy'),--last_mod_time
                 SYSDATE,--last_trans_time
                 To_date ('01/01/1753', 'mm/dd/yyyy'),--date_in_serv
                 To_date ('01/01/1753', 'mm/dd/yyyy'),--repair_date
                 To_date ('01/01/1753', 'mm/dd/yyyy'),--warr_end_date
                 To_date ('01/01/1753', 'mm/dd/yyyy'),--x_cool_end_date
                 'Active',--part_status
                 0,--hdr_ind
                 0,--x_sequence
                 SYSDATE,--x_insert_date
                 SYSDATE,--x_creation_date
                 'REDEMPTION CARDS',--x_domain
                 0,--x_deactivation_flag
                 0,--x_reactivation_flag
                 op_soft_pin,--x_red_code
                 op_smp_number,--part_serial_no
                 card_status,--x_part_inst_status
                 ip_inv_bin_objid,--part_inst2inv_bin
                 '',--created_by2user
                 (SELECT objid
                  FROM   table_x_code_table
                  WHERE  x_code_number = To_char(card_status)),
                 --status2x_code_table
                 v_ml_objid,--n_part_inst2part_mod,
                 NULL); --part_to_esn2part_inst)

    RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
             IF v_error_msg IS NULL THEN
               v_error_msg := Substr (SQLERRM, 1, 200);
             END IF;

             util_pkg.Insert_error_tab_proc(ip_action => v_action,
             ip_key => 'PIN_PART_NUM: '
                       ||ip_pin_part_num, ip_program_name => v_proc_name,
             ip_error_text => v_error_msg);

             RETURN 1;
END;
/