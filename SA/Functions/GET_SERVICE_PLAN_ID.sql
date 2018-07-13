CREATE OR REPLACE FUNCTION sa."GET_SERVICE_PLAN_ID" (f_esn      IN VARCHAR2,
                                                   f_red_code IN VARCHAR2)
RETURN NUMBER IS

/****************************************************************************
 ****************************************************************************
 * $Revision: 1.11 $
 * $Author: oimana $
 * $Date: 2017/07/26 22:00:29 $
 * $Log: get_service_plan_id.sql,v $
 * Revision 1.40  2017/07/26 22:00:29  oimana
 * CR48916 - Function
 *
 *
 *****************************************************************************
 *****************************************************************************/

op_error_code     INTEGER;
op_error_message  VARCHAR2(200);
v_flag            VARCHAR2(25);
v_units           table_x_promotion.x_units%TYPE;
v_sp_objid        x_service_plan.objid%TYPE := NULL;

CURSOR red_code_curs IS
  SELECT pn.part_num2part_class pc_objid
    FROM table_part_inst pi,
         table_mod_level ml,
         table_part_num pn
   WHERE 1 = 1
     AND pi.x_red_code  = f_red_code
     AND pi.x_domain    = 'REDEMPTION CARDS'
     AND ml.objid       = pi.n_part_inst2part_mod
     AND pn.objid       = ml.part_info2part_num
     AND pn.domain      = 'REDEMPTION CARDS'
  UNION
  SELECT pn.part_num2part_class pc_objid
    FROM table_x_red_card pi,
         table_mod_level ml,
         table_part_num pn
   WHERE 1 = 1
     AND pi.x_red_code  = f_red_code
     AND ml.objid       = pi.x_red_card2part_mod
     AND pn.objid       = ml.part_info2part_num
     AND pn.domain      = 'REDEMPTION CARDS'
  UNION
  SELECT pn.part_num2part_class pc_objid
    FROM table_x_posa_card_inv pi,
         table_mod_level ml,
         table_part_num pn
   WHERE 1 = 1
     AND pi.x_red_code  = f_red_code
     AND ml.objid       = pi.x_posa_inv2part_mod
     AND pn.objid       = ml.part_info2part_num
     AND pn.domain      = 'REDEMPTION CARDS';

CURSOR plan_curs (c_card_pc_objid IN NUMBER) IS
  SELECT /*+ use_invisible_indexes */
         sp.objid,
         sp.customer_price,
         sp.mkt_name
    FROM sa.x_service_plan sp,
         sa.x_service_plan_feature spf,
         sa.x_serviceplanfeature_value spfv,
         sa.x_serviceplanfeaturevalue_def a,
         sa.mtm_partclass_x_spf_value_def b
   WHERE sp.objid = spf.sp_feature2service_plan
     AND spf.objid = spfv.spf_value2spf
     AND spfv.value_ref = a.objid
     AND b.spfeaturevalue_def_id = a.objid
     AND EXISTS (SELECT NULL
                   FROM sa.table_part_inst pi,
                        sa.table_mod_level ml,
                        sa.table_part_num e,
                        sa.mtm_partclass_x_spf_value_def d,
                        sa.x_serviceplanfeaturevalue_def c
                  WHERE pi.x_domain = e.domain
                    AND pi.n_part_inst2part_mod = ml.objid
                    AND ml.part_info2part_num = e.objid
                    AND e.domain = 'PHONES'
                    AND d.part_class_id = e.part_num2part_class
                    AND d.spfeaturevalue_def_id = c.objid
                    AND c.objid = b.spfeaturevalue_def_id
                    AND pi.part_serial_no = f_esn
                    AND ROWNUM = 1)
     AND b.part_class_id = c_card_pc_objid;

-- CR48916 - Improved performance in cursor plan_curs

plan_rec plan_curs%ROWTYPE;

BEGIN

  FOR red_code_rec IN  red_code_curs LOOP

    FOR plan_rec IN  plan_curs (red_code_rec.pc_objid) LOOP
      RETURN plan_rec.objid;
    END LOOP;

    -- CR42459 See if Saflelink customer
    -- Check if a Safelink customer.
    IF v_sp_objid IS NULL THEN

      v_flag := 'N';

      BEGIN
        SELECT DISTINCT flg
          INTO v_flag
          FROM (SELECT 'Y' flg
                  FROM x_program_enrolled pe,
                       x_program_parameters pgm,
                       x_sl_currentvals slcur,
                       table_bus_org borg,
                       table_x_promotion tp
                 WHERE 1                       = 1
                   AND pgm.objid               = pe.pgm_enroll2pgm_parameter
                   AND slcur.x_current_esn     = pe.x_esn
                   AND sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
                   AND pgm.x_prog_class        = 'LIFELINE'
                   AND pe.x_esn                = f_esn
                   AND borg.objid              = pgm.prog_param2bus_org
                   AND org_id                  = 'TRACFONE'
                   AND pgm.x_promo_incl_min_at = tp.objid);
        EXCEPTION WHEN OTHERS THEN
           v_flag := 'N';
        END;

        IF v_flag = 'Y' THEN

          BEGIN

            SELECT sp.objid
              INTO v_sp_objid
              FROM sa.x_serviceplanfeaturevalue_def a,
                   sa.mtm_partclass_x_spf_value_def b,
                   sa.x_serviceplanfeaturevalue_def c,
                   sa.mtm_partclass_x_spf_value_def d,
                   sa.x_serviceplanfeature_value spfv,
                   sa.x_service_plan_feature spf,
                   sa.x_service_plan sp
             WHERE spf.objid = spfv.spf_value2spf
               AND sp.objid = spf.sp_feature2service_plan
               AND spfv.value_ref = a.objid
               AND c.objid = d.spfeaturevalue_def_id
               AND a.value_name = c.value_name
               AND a.objid = b.spfeaturevalue_def_id
               AND b.part_class_id = red_code_rec.pc_objid
               AND ROWNUM = 1;

            RETURN v_sp_objid;

          EXCEPTION WHEN OTHERS THEN
            RETURN NULL;
          END;

        ELSE

          RETURN NULL;

        END IF;

    END IF;

  END LOOP;

  RETURN NULL;

END;
/