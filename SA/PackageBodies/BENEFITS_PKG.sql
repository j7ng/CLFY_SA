CREATE OR REPLACE PACKAGE BODY sa.benefits_pkg
IS
    /*===============================================================================================*/
    /*                                                                                               */
    /* Purpose: BENIFITS_PKG handles objects which give benifits for an ESN                          */
    /* REVISIONS  DATE          WHO            PURPOSE                                               */
    /* --------------------------------------------------------------------------------------------- */
    /*            05/10/2014    MVadlapally     Initial                                              */
    /*===============================================================================================*/

    /* To reserve a pin for an esn before activation  */
    PROCEDURE sp_preactive_reserve_pin (
        in_esn            IN     table_part_inst.part_serial_no%TYPE,
        in_pin_part_num   IN     table_part_inst.part_serial_no%TYPE,
        in_inv_bin_objid  IN     table_inv_bin.objid%TYPE,
        out_soft_pin      OUT    table_x_cc_red_inv.x_red_card_number%TYPE,
        out_smp_number    OUT    table_x_cc_red_inv.x_smp%TYPE,
        out_err_num       OUT    NUMBER,
        out_err_msg       OUT    VARCHAR2,
        in_consumer       IN     table_x_cc_red_inv.x_consumer%TYPE DEFAULT NULL) --CR54533
    IS
        o_next_value       NUMBER;
        o_format           VARCHAR2 (200);
        p_status           VARCHAR2 (200);
        p_msg              VARCHAR2 (200);
        v_proc_name        VARCHAR2 (80) := 'BENEFITS_PKG.SP_PREACTIVE_RESERVE_PIN';


        CURSOR c_pin_part_num (p_pin_part_num   IN VARCHAR2)
        IS
            SELECT m.objid mod_level_objid,
                   bo.org_id,
                   pn.x_upc,
                   pn.part_number
              FROM table_part_num pn, table_mod_level m, table_bus_org bo
             WHERE 1 = 1
               AND pn.part_number = p_pin_part_num
               AND m.part_info2part_num = pn.objid
               AND bo.objid = pn.part_num2bus_org;

        pin_part_num_rec   c_pin_part_num%ROWTYPE;

        CURSOR c_get_esn
        IS
            SELECT pi_esn.part_serial_no esn,
                   pi_esn.objid pi_esn_objid,
                   pi_esn.part_inst2inv_bin,
                   ib.bin_name site_id
              FROM table_part_inst pi_esn, table_inv_bin ib
             WHERE 1 = 1 AND pi_esn.part_serial_no = in_esn AND ib.objid = pi_esn.part_inst2inv_bin;

        get_esn_rec        c_get_esn%ROWTYPE;

        CURSOR c_get_pin (p_next_value IN NUMBER)
        IS
            SELECT x_red_card_number, x_smp
              FROM table_x_cc_red_inv
             WHERE x_reserved_id = p_next_value;

        get_pin_rec        c_get_pin%ROWTYPE;

        CURSOR c_get_user
        IS
            SELECT objid
              FROM table_user
             WHERE s_login_name = USER;

        get_user_rec       c_get_user%ROWTYPE;


    BEGIN

            OPEN c_get_user;
            FETCH c_get_user INTO get_user_rec;
            CLOSE c_get_user;

            OPEN c_get_esn;
            FETCH c_get_esn INTO get_esn_rec;

            IF c_get_esn%FOUND
            THEN
                OPEN c_pin_part_num (in_pin_part_num);
                FETCH c_pin_part_num INTO pin_part_num_rec;

                IF c_pin_part_num%FOUND
                THEN
                    next_id ('X_MERCH_REF_ID', o_next_value, o_format);
                    sp_reserve_app_card (p_reserve_id => o_next_value,
                      p_total      => 1,
                      p_domain     => 'REDEMPTION CARDS',
                      p_consumer   => in_consumer, --CR54533
                      p_status     => p_status,
                      p_msg        => p_msg);		--CR42260
                    IF p_msg = 'Completed'
                    THEN
                        OPEN c_get_pin (o_next_value);
                        FETCH c_get_pin INTO get_pin_rec;

                        IF c_get_pin%FOUND
                        THEN
                            INSERT INTO table_part_inst (objid,
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
                                                         part_to_esn2part_inst,
                                                         x_ext)
                                     VALUES (
                                                (seq ('part_inst')),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                SYSDATE,
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                'Active',
                                                0,
                                                0,
                                                SYSDATE,
                                                SYSDATE,
                                                'REDEMPTION CARDS',
                                                0,
                                                0,
                                                get_pin_rec.x_red_card_number,
                                                get_pin_rec.x_smp,
                                                400,
                                                in_inv_bin_objid,
                                                get_user_rec.objid,
                                                (SELECT objid
                                                   FROM table_x_code_table
                                                  WHERE x_code_number = 400),
                                                pin_part_num_rec.mod_level_objid,
                                                get_esn_rec.pi_esn_objid,
                                                NVL (
                                                    (SELECT MAX (TO_NUMBER (x_ext) + 1)
                                                       FROM table_part_inst
                                                      WHERE part_to_esn2part_inst =
                                                                get_esn_rec.pi_esn_objid
                                                        AND x_domain = 'REDEMPTION CARDS'),
                                                    1));

                            out_soft_pin     := get_pin_rec.x_red_card_number;
                            out_smp_number   := get_pin_rec.x_smp;

                            COMMIT;
                        ELSE
                            CLOSE c_get_pin;

                            out_err_num      := 800;
                            out_err_msg      :='C_GET_PIN '||sa.get_code_fun ('WALMART_MONTHLY_PLANS_PKG',out_err_num,'ENGLISH');
                        END IF;

                        CLOSE c_get_pin;
                    ELSE
                        out_err_num      := 4;
                        out_err_msg      := v_proc_name||':'||p_status||':'||p_msg;
                    END IF;
                ELSE
                    out_err_num      := 800;
                    out_err_msg      :='C_PIN_PART_NUM '||sa.get_code_fun ('WALMART_MONTHLY_PLANS_PKG',out_err_num,'ENGLISH');

                    CLOSE c_pin_part_num;
                END IF;

                CLOSE c_pin_part_num;
            ELSE
                out_err_num      := 800;
                out_err_msg      :='C_GET_ESN '||sa.get_code_fun ('WALMART_MONTHLY_PLANS_PKG',out_err_num,'ENGLISH');

                CLOSE c_get_esn;
            END IF;

            CLOSE c_get_esn;
    EXCEPTION
        WHEN OTHERS
        THEN
            out_err_num      := SQLCODE;
            out_err_msg      := SUBSTR (SQLERRM, 1, 200);
            ota_util_pkg.err_log(p_action=> 'Main Excep: '||v_proc_name,
                                 p_error_date=> SYSDATE,
                                 p_key=> 'ESN: '||in_esn||' PIN_PART_NUM: '||in_pin_part_num,
                                 p_program_name=> v_proc_name,
                                 p_error_text=> SQLCODE||': '||SUBSTR (SQLERRM, 1, 200));
    END;
END;
/