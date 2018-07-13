CREATE OR REPLACE PACKAGE BODY sa.safelink_validations_pkg AS
/****************************************************************************
 ****************************************************************************
 * $Revision: 1.160 $
 * $Author: oimana $
 * $Date: 2018/04/12 18:20:25 $
 * $Log: SAFELINK_VALIDATIONS_PKB.sql,v $
 * Revision 1.160  2018/04/12 18:20:25  oimana
 * CR56887 - Package Body
 *
 *
 *****************************************************************************
 *****************************************************************************/
--
--
 PROCEDURE job_log (ip_job_name          IN  x_job_master.x_job_name%TYPE,
                    ip_job_desc          IN  x_job_master.x_job_desc%TYPE,
                    ip_job_class         IN  x_job_master.x_job_class%TYPE,
                    ip_job_sourcesystem  IN  x_job_master.x_job_sourcesystem%TYPE,
                    ip_status            IN  x_job_run_details.x_status%TYPE,
                    ip_job_run_mode      IN  x_job_run_details.x_job_run_mode%TYPE,
                    ip_seq_name          IN  VARCHAR2,
                    op_job_run_objid     OUT x_job_run_details.objid%TYPE) IS

 v_job_run_objid    x_job_run_details.objid%TYPE;
 v_job_master_id    x_job_master.objid%TYPE;

 PRAGMA autonomous_transaction;

 BEGIN

   SELECT MAX (objid)
     INTO v_job_master_id
     FROM sa.x_job_master
    WHERE x_job_name = ip_job_name
      AND x_job_desc = ip_job_desc
      AND x_job_class = ip_job_class
      AND x_job_sourcesystem = ip_job_sourcesystem;

   v_job_run_objid  := billing_seq (ip_seq_name);
   op_job_run_objid := v_job_run_objid;

   -- Mark the job as started running.
   INSERT INTO sa.x_job_run_details (objid,
                                     x_scheduled_run_date,
                                     x_actual_run_date,
                                     x_status,
                                     x_job_run_mode,
                                     x_start_time,
                                     run_details2job_master)
                             VALUES (v_job_run_objid,
                                     sysdate,
                                     sysdate,
                                     ip_status,
                                     ip_job_run_mode,
                                     sysdate,
                                     v_job_master_id);

   COMMIT;

 EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     raise_application_error (-20001, 'Failed to insert record into x_job_run_details: '||SQLERRM);
 END job_log;
--
--
 PROCEDURE job_log (ip_status        IN x_job_run_details.x_status%TYPE,
                    ip_job_run_objid IN x_job_run_details.objid%TYPE) IS

 v_job_run_objid x_job_run_details.objid%TYPE;
 v_job_master_id x_job_master.objid%TYPE;

 PRAGMA autonomous_transaction;

 BEGIN

   UPDATE sa.x_job_run_details
      SET x_status = ip_status,
          x_end_time = sysdate
    WHERE objid = ip_job_run_objid;

   COMMIT;

 EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     raise_application_error (-20002, 'Failed to update record into x_job_run_details: '||SQLERRM);
 END job_log;
--
--
 PROCEDURE p_validate_min (ip_key            IN  VARCHAR2,
                           ip_value          IN  VARCHAR2,
                           ip_source_system  IN  VARCHAR2,
                           op_actiontype     OUT VARCHAR2,
                           op_enroll_zip     OUT VARCHAR2,
                           op_web_user_id    OUT NUMBER,
                           op_lid            OUT NUMBER,
                           op_esn            OUT VARCHAR2,
                           op_contact_objid  OUT NUMBER,
                           op_refcursor      OUT SYS_REFCURSOR,
                           op_err_num        OUT NUMBER,
                           op_err_string     OUT VARCHAR2) IS

 -- CR54705 - Put back the UNION query due to :B1,:B2 issue from DBA but made it UNION ALL//OImana
 CURSOR cu_vald_min (c_ip_key   IN VARCHAR2,
                     c_ip_value IN VARCHAR2)
 IS
 SELECT tsu.x_min,
        tsu.x_service_id,
        tsu.objid sp_objid,
        tsu.x_expire_dt cycle_start_date,
        tsu.install_date,
        tsu.part_status
   FROM (SELECT tsp.x_min,
                tsp.x_service_id,
                tsp.objid,
                tsp.x_expire_dt,
                tsp.install_date,
                tsp.part_status
           FROM sa.table_site_part tsp
          WHERE 'ESN'            = c_ip_key
            AND tsp.x_service_id = c_ip_value
            AND tsp.part_status||'' IN('Active','Inactive')
          UNION ALL
         SELECT tsp.x_min,
                tsp.x_service_id,
                tsp.objid,
                tsp.x_expire_dt,
                tsp.install_date,
                tsp.part_status
           FROM sa.table_site_part tsp
          WHERE 'MIN'     = c_ip_key
            AND tsp.x_min = c_ip_value
            AND tsp.part_status||'' IN('Active','Inactive')) tsu
 ORDER BY tsu.install_date DESC;

 rec_vald_min cu_vald_min%ROWTYPE;

 CURSOR cu_esn_dtl (in_esn IN VARCHAR2)
 IS
 SELECT pc.objid pc_objid,
        pi.part_serial_no,
        pi.x_part_inst2contact
   FROM sa.table_part_inst pi,
        sa.table_mod_level ml,
        sa.table_part_num pn,
        sa.table_part_class pc
  WHERE pc.objid = pn.part_num2part_class
    AND pn.objid = ml.part_info2part_num
    AND ml.objid = pi.n_part_inst2part_mod
    AND pi.x_part_inst_status IN('52','51','54') --CR47024
    AND pi.x_domain = 'PHONES'
    AND pi.part_serial_no = in_esn;

 rec_esn_dtl cu_esn_dtl%ROWTYPE;

 CURSOR cu_data_pln (in_esn IN VARCHAR2)
 IS
 SELECT sp.service_plan_objid objid,
        sp.mkt_name,
        sp.description,
        'DATA' value_name,
        sp.data property_value,
        sp.data property_display
   FROM sa.table_site_part tsp,
        sa.x_service_plan_site_part ssp,
        sa.service_plan_feat_pivot_mv sp
  WHERE 1 = 1
    AND ((sp.data = '512')
     OR  (sp.data = '500')
     OR  (sp.data = 'NA')
     OR  (sp.data = '0')
     OR  (sp.data = 'Dynamic'))
    AND sp.service_plan_objid = ssp.x_service_plan_id
    AND ssp.table_site_part_id = tsp.objid
    AND tsp.part_status = 'Active'
    AND tsp.x_service_id = in_esn;

 rec_data_pln cu_data_pln%ROWTYPE;

 CURSOR cu_red_code (in_esn IN VARCHAR2)
 IS
 SELECT COUNT(1) cnt_red_code
   FROM sa.table_part_inst esn,
        sa.table_part_inst lin
  WHERE lin.part_to_esn2part_inst = esn.objid
    AND lin.x_part_inst_status = '400'     --RESERVED QUEUED
    AND lin.x_domain = 'REDEMPTION CARDS'
    AND esn.x_domain = 'PHONES'
    AND esn.part_serial_no = in_esn;

 rec_red_code cu_red_code%ROWTYPE;

 -- CR54705 - Tuned query in cursor//OImana.
 CURSOR cu_prgnrl_sl (in_esn IN x_program_enrolled.x_esn%TYPE)
 IS
 SELECT i_pe.pgm_enroll2web_user web_user_id,
        i_pgm.objid              prog_param_objid,
        i_pgm.x_program_name     prog_param_prog_name,
        i_pe.x_enrollment_status prog_enroll_status
   FROM sa.x_program_enrolled i_pe,
        sa.x_program_parameters i_pgm
  WHERE sysdate BETWEEN i_pgm.x_start_date AND i_pgm.x_end_date
    AND i_pgm.x_prog_class = 'LIFELINE'
    AND i_pgm.x_is_recurring = 1
    AND i_pgm.objid = i_pe.pgm_enroll2pgm_parameter
    AND i_pe.x_sourcesystem IN('VMBC', 'WEB')
    AND i_pe.x_enrollment_status = 'ENROLLED'
    AND i_pe.x_esn = in_esn
 UNION ALL
 SELECT i_pe.pgm_enroll2web_user web_user_id,
        i_pgm.objid              prog_param_objid,
        i_pgm.x_program_name     prog_param_prog_name,
        i_pe.x_enrollment_status prog_enroll_status
   FROM sa.x_program_enrolled i_pe,
        sa.x_program_parameters i_pgm
  WHERE sysdate BETWEEN i_pgm.x_start_date AND i_pgm.x_end_date
    AND i_pgm.x_prog_class = 'LIFELINE'
    AND i_pgm.x_is_recurring = 1
    AND i_pgm.objid = i_pe.pgm_enroll2pgm_parameter
    AND i_pe.x_enrolled_date = (SELECT MAX(i_pex.x_enrolled_date)
                                 FROM sa.x_program_enrolled i_pex
                                WHERE i_pex.pgm_enroll2pgm_parameter = i_pe.pgm_enroll2pgm_parameter
                                  AND i_pex.x_sourcesystem = i_pe.x_sourcesystem
                                  AND i_pex.x_esn = i_pe.x_esn)
    AND i_pe.x_sourcesystem IN('VMBC', 'WEB')
    AND i_pe.x_enrollment_status <> 'ENROLLED'
    AND i_pe.x_esn = in_esn;

 rec_prgnrl_sl cu_prgnrl_sl%ROWTYPE;

 -- CR54705 - Tuned query in cursor
 CURSOR cu_enroll_sl (in_esn                IN x_program_enrolled.x_esn%TYPE,
                      in_prog_param_objid   IN x_program_parameters.objid%TYPE,
                      in_prog_enroll_status IN x_program_enrolled.x_enrollment_status%TYPE,
                      in_lid                IN x_sl_hist.lid%TYPE)
 IS
 SELECT * FROM (SELECT DISTINCT
                       ps.program_param_objid prog_param_objid,
                       ps.reserve_card_limit,
                       ps.web_display,
                       ps.csr_display,
                       ps.ivr_display,
                       ps.program_provision_flag,    -- CR31545 SAFELINK CA HOME PHONE AR
                       ps.priority priority,
                       ps.app_display,               -- CR48643 added for mobile
                       ps.coverage_script,           -- CR54705
                       ps.script_type,               -- CR54705
                       ps.is_default_part_num,       -- CR54705
                       pn.part_number mtm_part_num,  -- CR35974 e911 Indiana
                       ROW_NUMBER() OVER (PARTITION BY pn.part_number
                                              ORDER BY slcur.objid DESC)
                                      AS latest_rec, -- CR39674 to get single record for part number when there are multiple records in X_SL_CURRENTVALS per ESN
                       slsub.zip enroll_zip,
                       slsub.lid lid,
                       slsub.state enroll_state      -- CR35974 e911 Indiana
                  FROM sa.mtm_program_safelink ps,
                       sa.table_part_num pn,
                       sa.x_sl_currentvals slcur,
                       sa.x_sl_subs slsub
                 WHERE slsub.lid = in_lid
                   AND slsub.lid = slcur.lid
                   AND slcur.x_current_esn = in_esn
                   AND pn.objid = ps.part_num_objid
                   AND DECODE(in_prog_enroll_status, 'ENROLLED', 'Y', ps.allow_non_sl_customer) = 'Y'
                   AND sysdate BETWEEN ps.start_date AND ps.end_date
                   AND ps.program_param_objid = in_prog_param_objid)
  WHERE latest_rec = 1
 ORDER BY priority;

 rec_enroll_sl cu_enroll_sl%ROWTYPE;

 lv_refcur_rec sl_refcur_rec;

 lv_refcur_tab sl_refcur_tab := sl_refcur_tab();

 cur                  SYS_REFCURSOR;
 v_boolean            BOOLEAN := FALSE;
 v_boolean_dummy_val  BOOLEAN := FALSE;
 lv_quantity          NUMBER := 0;                     --CR30286//CR29021
 lv_enroll_state_full table_state_prov.full_name%TYPE; --CR35974
 v_splan_group_esn    x_serviceplanfeaturevalue_def.value_name%TYPE;  -- CR51180
 l_device_type        VARCHAR2(30);
 l_enrl_count         NUMBER := 0;                     --CR54705
 l_xsha_esn           x_sl_hist.x_esn%TYPE;            --CR54705
 l_xsha_lid           x_sl_hist.lid%TYPE;              --CR54705

 BEGIN

  op_actiontype := NULL;
  op_err_num := 0;
  op_err_string := 'SUCCESS.';

  lv_refcur_tab := sl_refcur_tab();

  OPEN op_refcursor FOR
  SELECT NULL part_number,
         NULL pn_desc,
         NULL x_retail_price,
         NULL sp_objid,
         NULL plan_type,
         NULL service_plan_group,
         NULL mkt_name,
         NULL sp_desc,
         NULL customer_price,
         NULL ivr_plan_id,
         NULL webcsr_display_name,
         NULL x_sp2program_param,
         NULL x_program_name,
         NULL cycle_start_date,
         NULL cycle_end_date,
         NULL quantity,
         NULL coverage_script,
         NULL short_script,
         NULL trans_script,
         NULL script_type,
         NULL AS sl_program_flag,
         NULL AS enroll_state_full_name -- CR35974
    FROM dual;

  OPEN cur FOR
  SELECT NULL part_number,
         NULL pn_desc,
         NULL x_retail_price,
         NULL sp_objid,
         NULL plan_type,
         NULL service_plan_group,
         NULL mkt_name,
         NULL sp_desc,
         NULL customer_price,
         NULL ivr_plan_id,
         NULL webcsr_display_name,
         NULL x_sp2program_param,
         NULL x_program_name,
         NULL cycle_start_date,
         NULL cycle_end_date,
         NULL quantity,
         NULL coverage_script,
         NULL short_script,
         NULL trans_script,
         NULL script_type,
         NULL AS sl_program_flag,
         NULL AS enroll_state_full_name -- CR35974
    FROM dual;

  IF NVL(ip_key,'~') NOT IN('MIN','ESN') THEN
    op_err_num    := 910;   --NEW CODE "Enter valid Key Name"
    op_err_string := sa.get_code_fun('SA.SAFELINK_VALIDATIONS_PKG', op_err_num, 'ENGLISH');
    RETURN;
  ELSIF ip_value IS NULL THEN
    op_err_num    := 911;   --NEW CODE "Provide MIN or ESN"
    op_err_string := sa.get_code_fun('SA.SAFELINK_VALIDATIONS_PKG', op_err_num, 'ENGLISH');
    RETURN;
  END IF;

  OPEN cu_vald_min (ip_key, ip_value);
  FETCH cu_vald_min INTO rec_vald_min;

    IF cu_vald_min%ROWCOUNT = 0 THEN
      CLOSE cu_vald_min;
      op_err_num    := 912;   --NEW CODE "MIN is Not Active or Not Valid"
      op_err_string := sa.get_code_fun('SA.SAFELINK_VALIDATIONS_PKG', op_err_num, 'ENGLISH');
      RETURN;
    END IF;

  CLOSE cu_vald_min;

  OPEN cu_esn_dtl (rec_vald_min.x_service_id);
  FETCH cu_esn_dtl INTO rec_esn_dtl;

    IF cu_esn_dtl%ROWCOUNT = 0 THEN
      CLOSE cu_esn_dtl;
      op_err_num    := 913;   --NEW CODE "ESN is not Active or Not Valid or Invalid part number"
      op_err_string := sa.get_code_fun('SA.SAFELINK_VALIDATIONS_PKG', op_err_num, 'ENGLISH');
      RETURN;
    END IF;

  CLOSE cu_esn_dtl;

  -- CR54705 - Tuned query in cursor//OImana.
  BEGIN
    SELECT xsha.x_esn,
           xsha.lid
      INTO l_xsha_esn,
           l_xsha_lid
      FROM sa.x_sl_hist xsha
     WHERE xsha.objid = (SELECT MAX(objid)
                           FROM sa.x_sl_hist xshb
                          WHERE xshb.x_esn = rec_esn_dtl.part_serial_no)
       AND xsha.x_esn = rec_esn_dtl.part_serial_no;
  EXCEPTION
    WHEN OTHERS THEN
      op_err_num    := 914;   --NEW CODE "ESN is not Enrolled in any safelink program"
      op_err_string := sa.get_code_fun('SAFELINK_VALIDATIONS_PKG', op_err_num, 'ENGLISH');
      RETURN;
  END;

  OPEN cu_prgnrl_sl (rec_esn_dtl.part_serial_no);
  FETCH cu_prgnrl_sl INTO rec_prgnrl_sl;

    IF cu_prgnrl_sl%ROWCOUNT = 0 THEN
      CLOSE cu_esn_dtl;
      op_err_num    := 914;   --NEW CODE "ESN is not Enrolled in any safelink program"
      op_err_string := sa.get_code_fun('SAFELINK_VALIDATIONS_PKG', op_err_num, 'ENGLISH');
      RETURN;
    END IF;

  CLOSE cu_prgnrl_sl;

  op_esn           := rec_esn_dtl.part_serial_no;
  op_contact_objid := rec_esn_dtl.x_part_inst2contact;

  dbms_output.put_line('Calling(0) cu_enroll_sl for ESN: '||rec_esn_dtl.part_serial_no||
                       ' - prog_param_objid: '||rec_prgnrl_sl.prog_param_objid||
                       ' - l_xsha_lid: '||l_xsha_lid);

  FOR rec_enroll_sl IN cu_enroll_sl (rec_esn_dtl.part_serial_no,
                                     rec_prgnrl_sl.prog_param_objid,
                                     rec_prgnrl_sl.prog_enroll_status,
                                     l_xsha_lid) LOOP

    l_enrl_count := l_enrl_count + 1;

    dbms_output.put_line('rec_enroll_sl loop part num '||rec_enroll_sl.mtm_part_num||
                         ' Prov flag '||rec_enroll_sl.program_provision_flag||
                         ' Prog param objid '||rec_enroll_sl.prog_param_objid);

    v_boolean_dummy_val := FALSE;
    v_boolean           := FALSE;
    lv_quantity         := NULL;
    op_enroll_zip       := rec_enroll_sl.enroll_zip;
    op_web_user_id      := rec_prgnrl_sl.web_user_id;
    op_lid              := rec_enroll_sl.lid;

    BEGIN
      SELECT full_name
        INTO lv_enroll_state_full
        FROM sa.table_state_prov
       WHERE name = rec_enroll_sl.enroll_state;
    EXCEPTION
      WHEN OTHERS THEN
        op_err_num    := 955;   --NEW CODE "need to update error codes in clarity code table  " ---pending ar
        op_err_string := sa.get_code_fun('SA.SAFELINK_VALIDATIONS_PKG', op_err_num, 'ENGLISH');
        GOTO procedure_end;
    END;

    IF rec_enroll_sl.program_provision_flag = 2 THEN

      v_boolean_dummy_val := TRUE;
      v_boolean           := TRUE;
      op_actiontype       := 'HOMEPHONE';

      dbms_output.put_line('in prov flag 2 after cur');

    ELSIF rec_enroll_sl.program_provision_flag = 3 THEN

      v_boolean := TRUE;

      dbms_output.put_line('prov flag 3 part num '||rec_enroll_sl.mtm_part_num||
                           ' Prov flag '||rec_enroll_sl.program_provision_flag||
                           ' Prog param objid '||rec_enroll_sl.prog_param_objid);

      lv_quantity := NULL;

      p_get_valid_e911_txn_allowed (rec_enroll_sl.lid,
                                    rec_enroll_sl.prog_param_objid,
                                    rec_enroll_sl.mtm_part_num,
                                    lv_quantity,
                                    op_err_num,
                                    op_err_string);

      IF ((ip_source_system = 'WEB' AND rec_enroll_sl.web_display = 'Y') OR
          (ip_source_system = 'TAS' AND rec_enroll_sl.csr_display = 'Y')) THEN

        dbms_output.put_line('prov flag 3 before cur part num '||rec_enroll_sl.mtm_part_num||
                             ' Prov flag '||rec_enroll_sl.program_provision_flag||
                             ' Prog param objid '||rec_enroll_sl.prog_param_objid);

        OPEN cur FOR
        SELECT DISTINCT *
          FROM (SELECT pn.part_number                       AS part_number,
                       pn.description                       AS pn_desc,
                       (tpc.x_retail_price + sa.sp_taxes.computee911surcharge2(rec_enroll_sl.enroll_zip)) AS x_retail_price,
                       NULL                                 AS sp_objid,
                       NULL                                 AS plan_type,
                       NULL                                 AS service_plan_group,
                       NULL                                 AS mkt_name,
                       NULL                                 AS sp_desc,
                       NULL                                 AS customer_price,
                       NULL                                 AS ivr_plan_id,
                       NULL                                 AS webcsr_display_name,
                       rec_enroll_sl.prog_param_objid       AS x_sp2program_param,
                       rec_prgnrl_sl.prog_param_prog_name   AS x_program_name,
                       NULL                                 AS cycle_start_date,
                       NULL                                 AS cycle_end_date,
                       lv_quantity                          AS quantity,
                       NULL                                 AS coverage_script,
                       NULL                                 AS short_script,
                       NULL                                 AS trans_script,
                       NULL                                 AS script_type,
                       rec_enroll_sl.program_provision_flag AS sl_program_flag,
                       lv_enroll_state_full                 AS enroll_state_full_name  --CR35974 e911 Indiana
                  FROM sa.table_part_num pn,
                       sa.table_x_pricing tpc
                 WHERE sysdate BETWEEN tpc.x_start_date AND tpc.x_end_date
                   AND tpc.x_pricing2part_num = pn.objid
                   AND pn.part_number  = rec_enroll_sl.mtm_part_num);

      END IF;

      op_err_num        := 0;
      op_err_string     := 'SUCCESS';

      dbms_output.put_line('in prov flag 3 after cur');

    ELSIF rec_enroll_sl.program_provision_flag IN(1, 4) THEN

      -- CR31545 Safelink CA home phone AR = 1
      -- CR33124 SL BYOP - Added program_provision_flag = 4
      -- check for data plan

      OPEN cu_data_pln (rec_esn_dtl.part_serial_no);
      FETCH cu_data_pln INTO rec_data_pln;

      -- that means Current data plan exists - now check for reserve card >> start
      IF cu_data_pln%ROWCOUNT = 0 THEN
        CLOSE cu_data_pln;

        OPEN cu_red_code (rec_esn_dtl.part_serial_no);
        FETCH cu_red_code INTO rec_red_code;

        -- CHECK FOR RESERVED QUEUE
        -- IF CURRENT DATA PLAN EXISTS AND NO CARD IN RESERVE  >> start
        -- New addition to handle "Reserve card not allowed" scenario

        IF rec_enroll_sl.reserve_card_limit = 0 THEN
          v_boolean     := FALSE;
          op_actiontype := NULL;
          op_err_num    := 916; --NEW CODE "Currently ESN has a data plan and RESERVE is not allowed for this ESN"
          op_err_string := sa.get_code_fun('SAFELINK_VALIDATIONS_PKG' ,op_err_num ,'ENGLISH');
          CLOSE cu_red_code;
          GOTO procedure_end;
        END IF;

        IF (rec_red_code.cnt_red_code > 0) AND (rec_red_code.cnt_red_code >= rec_enroll_sl.reserve_card_limit) THEN
          v_boolean_dummy_val := TRUE;
          v_boolean     := TRUE;
          op_actiontype := 'ILDONLY';
          CLOSE cu_red_code;
          GOTO procedure_end;
        ELSE
          op_actiontype := 'RESERVE';
          v_boolean     := TRUE;
        END IF;

        CLOSE cu_red_code;
        -- IF CURRENT DATA PLAN EXISTS AND NO CARD IN RESERVE  >> end

      ELSE  -- No data plan exists

        op_actiontype := 'ADDNOW';
        v_boolean     := TRUE;
        rec_vald_min.cycle_start_date := sysdate;

      END IF;
      -- that means Current data plan exists - now check for reserve card >> end

      IF cu_data_pln%ISOPEN THEN
        CLOSE cu_data_pln;
      END IF;

      -- CR48643 - if condition and query criteria
      -- CR35974 - added lv_enroll_state_full to query for e911 Indiana
      -- CR54705 - query performance improvement

      IF v_boolean AND ((ip_source_system = 'WEB'     AND rec_enroll_sl.web_display = 'Y')
                    OR  (ip_source_system = 'TAS'     AND rec_enroll_sl.csr_display = 'Y')
                    OR  (ip_source_system = 'APP'     AND rec_enroll_sl.app_display = 'Y')
                    OR  (ip_source_system = 'HANDSET' AND rec_enroll_sl.app_display = 'Y')) THEN

        OPEN cur FOR
        SELECT DISTINCT
               pn.part_number                                   AS part_number,
               pn.description                                   AS pn_desc,
               tpc.x_retail_price                               AS x_retail_price,
               sp.objid                                         AS sp_objid,
               NULL                                             AS plan_type,
               NULL                                             AS service_plan_group,
               sp.mkt_name                                      AS mkt_name,
               sp.description                                   AS sp_desc,
               sp.customer_price                                AS customer_price,
               sp.ivr_plan_id                                   AS ivr_plan_id,
               sp.webcsr_display_name                           AS webcsr_display_name,
               sppp.x_sp2program_param                          AS x_sp2program_param,
               rec_prgnrl_sl.prog_param_prog_name               AS x_program_name,
               rec_vald_min.cycle_start_date                    AS cycle_start_date,
               rec_vald_min.cycle_start_date + pn.x_redeem_days AS cycle_end_date,
               0                                                AS quantity,
               spfp.coverage_script                             AS coverage_script,
               spfp.short_script                                AS short_script,
               spfp.trans_summ_script                           AS trans_script,
               spfp.script_type                                 AS script_type,
               rec_enroll_sl.program_provision_flag             AS sl_program_flag,
               lv_enroll_state_full                             AS enroll_state_full_name
          FROM sa.table_part_num                 pn,
               sa.table_x_pricing                tpc,
               sa.adfcrm_serv_plan_class_matview spcv,
               sa.x_service_plan                 sp,
               sa.mtm_sp_x_program_param         sppp,
               sa.service_plan_feat_pivot_mv     spfp
         WHERE spfp.service_plan_objid  = sp.objid
           AND sppp.x_sp2program_param  = rec_enroll_sl.prog_param_objid
           AND 'N'                      = rec_enroll_sl.is_default_part_num
           AND sp.objid                 = spcv.sp_objid
           AND spcv.part_class_objid    = pn.part_num2part_class
           AND sysdate BETWEEN tpc.x_start_date AND tpc.x_end_date
           AND tpc.x_channel            = DECODE(ip_source_system, 'WEB', 'WEB', 'TAS', 'WEBCSR', 'APP', 'APP', 'HANDSET', 'APP', 'LIFELINE')
           AND tpc.x_pricing2part_num   = pn.objid
           AND pn.domain                = 'REDEMPTION CARDS'
           AND pn.part_number           = rec_enroll_sl.mtm_part_num
        ORDER BY sp.objid, pn.part_number;

      ELSE

        v_boolean := FALSE;

      END IF;

      dbms_output.put_line('in prov flag 1 or 4 after cur');

    ELSIF rec_enroll_sl.program_provision_flag = 5 THEN

      -- CR51180 Block the Paygo for TFSL_UNLIMITED customers.
      v_splan_group_esn := NULL;

      BEGIN
        SELECT sa.get_serv_plan_value (sa.util_pkg.get_service_plan_id (rec_esn_dtl.part_serial_no), 'SERVICE_PLAN_GROUP') service_plan_group
          INTO v_splan_group_esn
          FROM dual;
      EXCEPTION
        WHEN OTHERS THEN
          v_splan_group_esn := NULL;
      END;

      v_boolean     := TRUE;
      lv_quantity   := NULL;
      l_device_type := sa.get_device_type (rec_esn_dtl.part_serial_no);

      dbms_output.put_line ('prov flag 5 part num '||rec_enroll_sl.mtm_part_num||
                            ' Prov flag '||rec_enroll_sl.program_provision_flag||
                            ' Prog param objid '||rec_enroll_sl.prog_param_objid);

      -- CR51180 Block the PAYGO for TFSL_UNLIMITED customers will return null and service plan group is not TFSL_UNLIMITED for the esn
      -- CR47024 Adding to query MV sa.adfcrm_serv_plan_class_matview to check availability of service plan with MIN device
      -- CR54705 reviewed query to improve performance and removed call to tables already in loop cursor
      OPEN cur FOR
      SELECT DISTINCT *
        FROM (SELECT pn.part_number                       AS part_number,
                     pn.description                       AS pn_desc,
                     tpc.x_retail_price                   AS x_retail_price,
                     NVL(adf.sp_objid,pn.objid)           AS sp_objid,
                     DECODE(adf.sp_objid, NULL, 'PAY_GO', sa.get_serv_plan_value(adf.sp_objid, 'PLAN TYPE')) AS plan_type,
                     DECODE(adf.sp_objid, NULL, 'PAY_GO', sa.get_serv_plan_value(adf.sp_objid, 'SERVICE_PLAN_GROUP')) AS service_plan_group,
                     NULL                                 AS mkt_name,
                     NULL                                 AS sp_desc,
                     tpc.x_retail_price                   AS customer_price,
                     NULL                                 AS ivr_plan_id,
                     NULL                                 AS webcsr_display_name,
                     NULL                                 AS x_sp2program_param,
                     NULL                                 AS x_program_name,
                     NULL                                 AS cycle_start_date,
                     NULL                                 AS cycle_end_date,
                     lv_quantity                          AS quantity,
                     rec_enroll_sl.coverage_script        AS coverage_script,
                     NULL                                 AS short_script,
                     NULL                                 AS trans_script,
                     rec_enroll_sl.script_type            AS script_type,
                     rec_enroll_sl.program_provision_flag AS sl_program_flag,
                     lv_enroll_state_full                 AS enroll_state_full_name  --CR35974 e911 Indiana
                FROM sa.table_part_num pn,
                     sa.table_x_pricing tpc,
                     sa.adfcrm_serv_plan_class_matview adf
               WHERE sysdate BETWEEN tpc.x_start_date AND tpc.x_end_date
                 AND tpc.x_pricing2part_num = pn.objid
                 AND 1 =  DECODE(l_device_type,'FEATURE_PHONE', is_srvc_plan_allowed (pn.objid, rec_esn_dtl.part_serial_no),1)          -- CR47024
                 AND NOT (sa.get_serv_plan_value(adf.sp_objid, 'PLAN TYPE') IS NULL AND NVL(v_splan_group_esn,'X') = 'TFSL_UNLIMITED')  -- CR51180
                 AND adf.part_class_objid(+) = pn.part_num2part_class
                 AND pn.part_number = rec_enroll_sl.mtm_part_num);

      dbms_output.put_line('in prov flag 5 after cur');

    END IF;

    <<procedure_end>>

    NULL;

    IF NOT v_boolean THEN

      dbms_output.put_line('inside not v_boolean');

      OPEN cur FOR
      SELECT NULL part_number,
             NULL pn_desc,
             NULL x_retail_price,
             NULL sp_objid,
             NULL plan_type,
             NULL service_plan_group,
             NULL mkt_name,
             NULL sp_desc,
             NULL customer_price,
             NULL ivr_plan_id,
             NULL webcsr_display_name,
             NULL x_sp2program_param,
             NULL x_program_name,
             NULL cycle_start_date,
             NULL cycle_end_date,
             NULL quantity,
             NULL coverage_script,
             NULL short_script,
             NULL trans_script,
             NULL script_type,
             NULL sl_program_flag,
             NULL enroll_state_full_name
        FROM dual;

    END IF;

    IF v_boolean_dummy_val THEN

      dbms_output.put_line('inside v_boolean_dummy_val');

      OPEN cur FOR
      SELECT '0'    part_number,
             '0'    pn_desc,
             0      x_retail_price,
             0      sp_objid,
             NULL   plan_type,
             NULL   service_plan_group,
             '0'    mkt_name,
             '0'    sp_desc,
             0      customer_price,
             0      ivr_plan_id,
             '0'    webcsr_display_name,
             0      x_sp2program_param,
             '0'    x_program_name,
             TO_DATE('01/01/0001', 'MM/DD/YYYY') cycle_start_date,
             TO_DATE('01/01/0001', 'MM/DD/YYYY') cycle_end_date,
             0      quantity,
             '0'    coverage_script,
             '0'    short_script,
             '0'    trans_script,
             '0'    script_type,
             0      sl_program_flag,
             '0'    enroll_state_full_name
        FROM dual;

    END IF;

    dbms_output.put_line('before loop');

    LOOP

      dbms_output.put_line('inside loop 1 '||lv_refcur_tab.COUNT);

      lv_refcur_tab.extend();

      dbms_output.put_line('inside loop 2 '||lv_refcur_tab.COUNT);

      lv_refcur_tab (lv_refcur_tab.LAST) := sl_refcur_rec (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

      dbms_output.put_line('inside loop 3 '||lv_refcur_tab.COUNT);

      -- CR44611
      IF cur%ISOPEN THEN

        FETCH cur INTO lv_refcur_tab(lv_refcur_tab.LAST).part_number,
                       lv_refcur_tab(lv_refcur_tab.LAST).pn_desc,
                       lv_refcur_tab(lv_refcur_tab.LAST).x_retail_price,
                       lv_refcur_tab(lv_refcur_tab.LAST).sp_objid,
                       lv_refcur_tab(lv_refcur_tab.LAST).plan_type,
                       lv_refcur_tab(lv_refcur_tab.LAST).service_plan_group,
                       lv_refcur_tab(lv_refcur_tab.LAST).mkt_name,
                       lv_refcur_tab(lv_refcur_tab.LAST).sp_desc,
                       lv_refcur_tab(lv_refcur_tab.LAST).customer_price,
                       lv_refcur_tab(lv_refcur_tab.LAST).ivr_plan_id,
                       lv_refcur_tab(lv_refcur_tab.LAST).webcsr_display_name,
                       lv_refcur_tab(lv_refcur_tab.LAST).x_sp2program_param,
                       lv_refcur_tab(lv_refcur_tab.LAST).x_program_name,
                       lv_refcur_tab(lv_refcur_tab.LAST).cycle_start_date,
                       lv_refcur_tab(lv_refcur_tab.LAST).cycle_end_date,
                       lv_refcur_tab(lv_refcur_tab.LAST).quantity,
                       lv_refcur_tab(lv_refcur_tab.LAST).coverage_script,
                       lv_refcur_tab(lv_refcur_tab.LAST).short_script,
                       lv_refcur_tab(lv_refcur_tab.LAST).trans_script,
                       lv_refcur_tab(lv_refcur_tab.LAST).script_type,
                       lv_refcur_tab(lv_refcur_tab.LAST).sl_program_flag,
                       lv_refcur_tab(lv_refcur_tab.LAST).enroll_state_full_name;

        dbms_output.put_line('inside loop after fetch '||cur%ROWCOUNT);

        EXIT WHEN cur%NOTFOUND;

      ELSE

        EXIT;

      END IF;  -- CR44611

    END LOOP;

    lv_refcur_tab.DELETE(lv_refcur_tab.LAST);

    -- CR44611
    IF cur%ISOPEN THEN
      CLOSE cur;
    END IF;

  END LOOP;   --close cu_enroll_sl cursor;

  dbms_output.put_line('End Loop(0) cu_enroll_sl for ESN - Count: '||l_enrl_count);

  -- CR54705 - send error if ESN is not enrolled in Safelink program - cu_enroll_sl cursor is null
  IF l_enrl_count = 0 THEN
    op_err_num    := 914;   --NEW CODE "ESN is not Enrolled in any safelink program"
    op_err_string := sa.get_code_fun('SAFELINK_VALIDATIONS_PKG', op_err_num, 'ENGLISH');
    RETURN;
  END IF;

  OPEN op_refcursor FOR
  SELECT DISTINCT *
    FROM TABLE (CAST (lv_refcur_tab AS sl_refcur_tab));

  dbms_output.put_line('End of process - return to calling program');

 EXCEPTION
   WHEN OTHERS THEN
     op_err_num    := SQLCODE;
     op_err_string := SQLERRM;

     ota_util_pkg.err_log (p_action       => 'VALIDATEMIN',
                           p_error_date   => sysdate,
                           p_key          => ('MIN_ESN_LID'),
                           p_program_name => 'SAFELINK_VALIDATIONS_PKG.SP_VALIDATE_MIN',
                           p_error_text   => op_err_string);

     OPEN cur FOR
     SELECT NULL part_number,
            NULL pn_desc,
            NULL x_retail_price,
            NULL sp_objid,
            NULL plan_type,
            NULL service_plan_group,
            NULL mkt_name,
            NULL sp_desc,
            NULL customer_price,
            NULL ivr_plan_id,
            NULL webcsr_display_name,
            NULL x_sp2program_param,
            NULL x_program_name,
            NULL cycle_start_date,
            NULL cycle_end_date,
            NULL quantity,
            NULL coverage_script,
            NULL short_script,
            NULL trans_script,
            NULL script_type,
            NULL AS sl_program_flag,
            NULL AS enroll_state_full_name
       FROM dual;

     IF cur%ISOPEN THEN
      CLOSE cur;
     END IF;

 END p_validate_min;
--
--
 PROCEDURE p_redemption_card_actions (ip_esn               IN  table_part_inst.part_serial_no%TYPE,
                                      ip_action_type       IN  VARCHAR2,
                                      ip_source_system     IN  x_program_purch_hdr.x_rqst_source%TYPE,
                                      ip_create_call_trans IN  VARCHAR2,
                                      ip_call_trans_objid  IN  table_x_call_trans.objid%TYPE,
                                      ip_merchant_ref_no   IN  x_program_purch_hdr.x_merchant_ref_number%TYPE,
                                      op_soft_pin          OUT table_x_cc_red_inv.x_red_card_number%TYPE,
                                      op_smp               OUT table_x_cc_red_inv.x_smp%TYPE,
                                      op_err_num           OUT NUMBER,
                                      op_err_string        OUT VARCHAR2) IS

    v_status           VARCHAR2(1);
    v_msg              VARCHAR2(100);
    v_call_trans_objid table_x_call_trans.objid%TYPE;

 BEGIN

    op_err_num    := 0;
    op_err_string := 'SUCCESS.';
    v_call_trans_objid := ip_call_trans_objid;

    --Calling sp_reserve_app_card to generate Soft Pin
    --sa.sp_reserve_app_card(ip_merchant_ref_no, 1, 'REDEMPTION CARDS', v_status, v_msg );

    sa.sp_reserve_app_card(p_reserve_id => ip_merchant_ref_no,
                           p_total      => 1,
                           p_domain     => 'REDEMPTION CARDS',
                           p_status     => v_status,
                           p_msg        => v_msg );  --CR42260

      IF v_msg <> 'Completed' THEN
       op_err_num    := 920; --new code "SOFT PIN Generation Failed"
       op_err_string := 'SP_RESERVE_APP_CARD v_status: '||v_status||' v_msg: '||v_msg;
       ota_util_pkg.err_log(p_action => 'SAFELINKVALIDATE', p_error_date => sysdate, p_key => 'OP_SOFT_PIN', p_program_name =>
        'SAFELINK_VALIDATIONS_PKG.P_REDEMPTION_CARD_ACTIONS', p_error_text => op_err_string);

       RETURN;
       END IF;

      --pull the soft pin generated from above procedure  sp_reserve_app_card
      BEGIN
          SELECT x_red_card_number,x_smp
          INTO  op_soft_pin, op_smp
          FROM table_x_cc_red_inv
          WHERE x_reserved_id = ip_merchant_ref_no
          AND x_reserved_flag = 1;
          op_err_num := 0;
          op_err_string  := 'Success';
      EXCEPTION
        WHEN OTHERS THEN
        op_soft_pin := -1;
        op_smp := -1;
        op_err_num := SQLCODE;
        op_err_string := SQLERRM;
        ota_util_pkg.err_log(p_action => 'SAFELINKVALIDATE', p_error_date => sysdate, p_key => 'OP_SOFT_PIN', p_program_name =>
        'SAFELINK_VALIDATIONS_PKG.P_REDEMPTION_CARD_ACTIONS', p_error_text => op_err_string);
        RETURN;
      END;

    --Start > checking action type and calling procedures accordingly
 --   IF ip_action_type = 'ADDNOW' THEN

    IF ip_action_type = 'RESERVE' THEN

      --Call procedure to reserve
      sa.queue_card_pkg.sp_add_queue( ip_esn,
                                      op_soft_pin,
                                      ip_source_system,
                                      ip_create_call_trans,
                                      v_call_trans_objid,
                                      op_err_num,
                                      op_err_string);
      IF op_err_num <> 0 THEN
        op_err_string := 'SAFELINK_VALIDATIONS_PKG.P_REDEMPTION_CARD_ACTIONS calling sp_add_queue.. '||op_err_num||' '||op_err_string;
        op_err_num := 921;  --new code "QUEUE PIN Failed"

      END IF;
    END IF;
    --End > checking action type and calling procedures accordingly

        <<procedure_end>>
    NULL;

 EXCEPTION
   WHEN OTHERS THEN
     op_err_num    := SQLCODE;
     op_err_string := SQLERRM;
     ota_util_pkg.err_log(p_action => 'SAFELINKVALIDATE', p_error_date => sysdate, p_key => ('ADD_RESERVE'), p_program_name =>
     'SAFELINK_VALIDATIONS_PKG.P_REDEMPTION_CARD_ACTIONS', p_error_text => op_err_string);
 END p_redemption_card_actions;
--
--
 PROCEDURE p_update_purchase_details (ip_merch_ref_number  IN  table_x_purch_hdr.x_merchant_ref_number%TYPE,
                                      ip_lid               IN  x_sl_subs.lid%TYPE,
                                      ip_partnum           IN  VARCHAR2 DEFAULT NULL,
                                      op_err_num           OUT NUMBER,
                                      op_err_string        OUT VARCHAR2) IS

  lv_e911_count   NUMBER := 0;    --CR30286
  lv_part_num     VARCHAR2(200);  --CR30286

 BEGIN

    op_err_num    := 0;
    op_err_string := 'SUCCESS';

    IF ip_merch_ref_number IS NOT NULL THEN

      UPDATE table_x_purch_hdr
      SET x_user_po = ip_lid
      WHERE x_merchant_ref_number = ip_merch_ref_number;

    END IF;

    /* CR30286 change starts */
    /* Defect # 3155 raised for CR 33056
    if ip_partnum is null then
      select max(pn.part_number)
      into lv_part_num
      from table_x_purch_hdr ph
        ,table_x_purch_dtl pd
        ,table_mod_level ml
        ,table_part_num pn
      where 1=1
      and ph.x_merchant_ref_number = ip_merch_ref_number
      and pd.x_purch_dtl2x_purch_hdr = ph.objid
      and pd.x_purch_dtl2mod_level = ml.objid
      and ml.part_info2part_num = pn.objid ;

    else
      lv_part_num := ip_partnum;
    end if;

    lv_e911_count := 0;

    select count(1)
    into lv_e911_count
    from mtm_program_safelink mtm
    where 1=1
    --and mtm.program_param_objid = rec_enrollment.prog_objid
    and mtm.part_num_objid = (select objid
                    from table_part_num
                    where part_number = lv_part_num
                    and domain = 'REDEMPTION CARDS'
                    )
    and sysdate between mtm.start_date  and mtm.end_date
    and mtm.program_provision_flag = '3' ;

    if NVL(lv_e911_count,0) > 0 then
      update table_x_purch_hdr
      set x_e911_amount = x_amount
        ,x_amount = x_e911_amount
      where x_merchant_ref_number = ip_merch_ref_number;
    end if;
    */
    /* CR30286 change ends */

 EXCEPTION
   WHEN OTHERS THEN
      op_err_num    := SQLCODE;
      op_err_string := 'FAILURE..ERR=' || substr(SQLERRM,1,100);

      sa.ota_util_pkg.err_log (
        p_action => 'update purchase with LID',
        p_error_date => sysdate,
        p_key => 'UPDATE',
        p_program_name => 'p_update_purchase_details',
        p_error_text => substr('ip_merch_ref_number='||ip_merch_ref_number
            ||', ip_lid='||ip_lid
            ||', ip_partnum='||ip_partnum --CR30286
            ||', SQLERRM='||  SQLERRM, 1, 4000));
 END p_update_purchase_details;
--
--
 PROCEDURE p_move_sl_cycle_date (ip_enrolled_objid  IN  x_program_enrolled.objid%TYPE,
                                 ip_esn             IN  x_program_enrolled.x_esn%TYPE,
                                 ip_cycle_days      IN  NUMBER,
                                 op_err_num         OUT NUMBER,
                                 op_err_string      OUT VARCHAR2) IS

      retval NUMBER;
      ld_next_delivery_date DATE;

      CURSOR cu_get_prog_enrol_dtl (in_enrolled_objid x_program_enrolled.objid%TYPE)
      IS
        SELECT
          pe.pgm_enroll2web_user,
          pe.pgm_enroll2site_part,
          pp.x_program_name,
          pe.x_next_delivery_date
        FROM
          x_program_parameters pp,
          x_program_enrolled pe
        WHERE
          pe.objid                      = in_enrolled_objid
        AND pe.pgm_enroll2pgm_parameter = pp.objid
        AND sysdate BETWEEN pp.x_start_date AND pp.x_end_date;
      rec_get_prog_enrol_dtl cu_get_prog_enrol_dtl%ROWTYPE;

 BEGIN

      op_err_num    := 0;
      op_err_string := 'SUCCESS';

      OPEN cu_get_prog_enrol_dtl (ip_enrolled_objid);
      FETCH cu_get_prog_enrol_dtl
      INTO rec_get_prog_enrol_dtl;

      ld_next_delivery_date := TRUNC(sysdate) + ip_cycle_days;

      UPDATE sa.x_program_enrolled
         SET x_next_delivery_date = ld_next_delivery_date, --TRUNC(SYSDATE)+ ip_cycle_days,
             x_next_charge_date   = NULL
       WHERE objid = ip_enrolled_objid
         AND x_esn = ip_esn;

        retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
        ,'ENROLLED'
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,sysdate
        ,'Change Delivery Date'
        ,'CHANGE_DELIVERY_DATE'
        ,rec_get_prog_enrol_dtl.x_program_name || ' From ' || rec_get_prog_enrol_dtl.x_next_delivery_date || ' to ' || ld_next_delivery_date
        ,'VMBC'
        ,ip_esn
        ,sysdate
        ,sysdate
        ,'I'
        ,'System'
        ,ip_enrolled_objid
        ,rec_get_prog_enrol_dtl.pgm_enroll2web_user,
        rec_get_prog_enrol_dtl.pgm_enroll2site_part);

        op_err_num := retval;

      CLOSE cu_get_prog_enrol_dtl;

 EXCEPTION
    WHEN OTHERS THEN
      op_err_num    := SQLCODE;
      op_err_string := 'FAILURE..ERR=' || substr(SQLERRM,1,100);
      sa.ota_util_pkg.err_log ( p_action => 'move sl cycle date', p_error_date =>
      sysdate, p_key => 'UPDATE', p_program_name => 'p_move_sl_cycle_date',
      p_error_text => substr('ip_enrolled_objid='||ip_enrolled_objid ||', ip_esn='
      ||ip_esn ||', SQLERRM='|| SQLERRM, 1, 4000) );
 END p_move_sl_cycle_date;
--
--
 PROCEDURE p_safelink_data_feed (op_err_num    OUT NUMBER,
                                 op_err_string OUT VARCHAR2) IS
      /**************************************************************************
      CR30295
      DATE: 11/24/2014
      This procedure is used to insert the records for SL data feed
      **************************************************************************/

      v_next_value NUMBER;
      v_job_run_objid x_job_run_details.objid%TYPE;
      v_count NUMBER := 0;
      v_lid xsu_vmbc_request.lid%TYPE;

      CURSOR cur_get_data_feed
      IS
        SELECT
          --SEQ_SAFELINK_DATA_FEED.nextval,
          xsu.lid lid,
          NVL(TO_DATE(xsu.qualifydate, 'YYYY-MM-DD'), xsu.batchdate) qualify_date ,
          to_char(nvl(TO_DATE(xsu.qualifydate, 'YYYY-MM-DD'), xsu.batchdate), 'YYYY-MON') data_feed_month,
          xsu.NAME,
          xsu.address,
          xsu.address2,
          xsu.city,
          xsu.STATE,
          xsu.zip,
          cv.x_current_esn x_esn,
          cv.x_current_min x_min,
          xsl.x_requested_plan x_plan,
          cv.x_current_ticket_id x_case_id,
          cv.x_tracking_no x_tracking_number,
          cv.x_current_enrolled x_enrolled,
          cv.x_current_active x_active,
          sf.connection_fee connection_fee,
          sf.usac_amount usac_amount,
          sf.state_support state_support,
          sf.other_fee_1 other_fee_1,
          sf.other_fee_2 other_fee_2,
          (SELECT MIN(ph.objid) FROM x_program_purch_hdr ph, x_program_purch_dtl pd
                        WHERE ph.objid=pd.pgm_purch_dtl2prog_hdr
                        AND pd.pgm_purch_dtl2pgm_enrolled = cv.x_current_pe_id
                        AND ph.x_payment_type IN ('LL_ENROLL', 'LL_ENROLLMENT')) prog_purch_hdr_objid,
          cv.x_current_active_date x_current_active_date,
          sysdate run_date,
          DECODE(sf.connection_fee, 39.00, 'SLACTIVATIONFEE', NULL) part_number
        FROM
          xsu_vmbc_request xsu,
          x_sl_subs xsl,
          x_sl_currentvals cv,
          safelink_fee sf
        WHERE
          xsu.STATE              = 'CA'
        AND xsu.requesttype      ='Enroll'
        AND xsu.lid              =xsl.lid
        AND xsl.x_requested_plan = sf.program_name
        AND sysdate BETWEEN sf.start_date AND sf.end_date
        AND xsu.lid NOT LIKE '-%'
        AND NVL(TO_DATE(xsu.qualifydate, 'YYYY-MM-DD'), xsu.batchdate) >= TRUNC(
          sysdate)-60
        AND xsl.lid=cv.lid
        AND cv.x_current_esn IS NOT NULL
        AND cv.x_current_esn NOT LIKE '-%'
        AND NOT EXISTS
          (
            SELECT
              1
            FROM
              sa.safelink_data_feed x
            WHERE
              x.lid = xsu.lid
          );

 BEGIN

      dbms_output.put_line('********** START OF PROCEDURE p_safelink_data_feed **********');

      op_err_num    := 0;
      op_err_string := 'SUCCESS';

      job_log('SL_DATA_FEED', 'SafeLink - Data Feed', 'BSafelinkFeed', 'SAFELINK', 'RUNNING', '0', 'X_JOB_RUN_DETAILS', v_job_run_objid);

      dbms_output.put_line ('Inserting record into JOB RUN ');

      FOR rec IN cur_get_data_feed
      LOOP
        v_lid := rec.lid;
        v_next_value := sa.sequ_safelink_data_feed.NEXTVAL;
        v_count := v_count + 1;
        INSERT
        INTO
          sa.safelink_data_feed
          (
            objid,
            lid,
            qualify_date,
            data_feed_month,
            NAME,
            address,
            address2,
            city,
            STATE,
            zip,
            x_esn,
            x_min,
            x_plan,
            x_case_id,
            x_tracking_number,
            x_enrolled,
            x_active,
            connection_fee,
            usac_amount,
            state_support,
            other_fee_1,
            other_fee_2,
            prog_purch_hdr_objid,
            x_current_active_date,
            run_date,
            part_number
          )
          VALUES
          (
            v_next_value,
            rec.lid,
            rec.qualify_date,
            rec.data_feed_month,
            rec.NAME,
            rec.address,
            rec.address2,
            rec.city,
            rec.STATE,
            rec.zip,
            rec.x_esn,
            rec.x_min,
            rec.x_plan,
            rec.x_case_id,
            rec.x_tracking_number,
            rec.x_enrolled,
            rec.x_active,
            rec.connection_fee,
            rec.usac_amount,
            rec.state_support,
            rec.other_fee_1,
            rec.other_fee_2,
            rec.prog_purch_hdr_objid,
            rec.x_current_active_date,
            rec.run_date,
            rec.part_number
          ) ;
      END LOOP;

      dbms_output.put_line('TOTAL INSERTED RECORD INTO safelink_data_feed: '||v_count);

      job_log('SUCCESS', v_job_run_objid);

      dbms_output.put_line('********** END OF PROCEDURE p_safelink_data_feed **********');

 EXCEPTION
   WHEN OTHERS THEN
      op_err_num    := SQLCODE;
      op_err_string := 'FAILURE..ERR=' || substr(SQLERRM,1,100)||' LID: '||v_lid;
      sa.ota_util_pkg.err_log ( p_action => 'p_safelink_data_feed', p_error_date =>
      sysdate, p_key => 'data feed', p_program_name => 'p_safelink_data_feed',
      p_error_text => substr(SQLERRM, 1, 4000) );

      job_log('FAILED', v_job_run_objid);

      ROLLBACK;

      dbms_output.put_line('********** EXCEPTION WHILE RUNNING PROCEDURE p_safelink_data_feed ********** op_err_num'||op_err_num||' op_err_string: '||op_err_string );

 END p_safelink_data_feed;
--
--
 PROCEDURE p_benefit_receipt_rec_insert (ip_process_date IN  VARCHAR2,
                                         op_err_num      OUT NUMBER,
                                         op_err_string   OUT VARCHAR2) IS

   /*
    Created Date: 10/20/2014
    CR# 29866
    This procedure inserts records into
    x_program_purch_hdr
    x_program_purch_dtl
    x_program_trans

    input
    ip_process_date = VARCHAR2 WITH FORMAT (MM-DD-YYYY)

    Output
    if no error occured
    op_err_num = 0
    op_err_string = 'SUCCESS.'
    if any error occured
    op_err_num = error number
    op_err_string = error message
    */

     v_job_run_objid x_job_run_details.objid%TYPE;
     ld_process_date DATE;
     ln_count NUMBER := 0;
     l_purch_hdr_seq x_program_purch_hdr.objid%TYPE ;
     v_job_master_id x_job_master.objid%TYPE;


     CURSOR cu_sl_data_feed (ip_process_date DATE)
        IS SELECT * FROM safelink_data_feed x
    WHERE 1=1
    AND EXISTS (SELECT 1 FROM x_program_enrolled pe, x_sl_currentvals cv
                    WHERE pe.x_esn = cv.x_current_esn
                    AND cv.lid=x.lid
                    AND pe.x_enrollment_status = 'ENROLLED' AND pe.x_sourcesystem = 'VMBC') -- To make sure LID/ ESN still Enrolled
    AND EXISTS (SELECT 1 FROM x_program_enrolled pe, x_sl_currentvals cv, table_site_part sp
                    WHERE pe.x_esn = cv.x_current_esn
                    AND cv.lid=x.lid
                    AND sp.x_service_id = pe.x_esn
                    AND sp.part_status = 'Active'
                    AND sp.x_expire_dt >= last_day (add_months (TRUNC (ip_process_date), 0)) + 1
                    AND pe.x_enrollment_status = 'ENROLLED' AND pe.x_sourcesystem = 'VMBC')   -- To make sure ESN Service end date is not in this month.
    AND NOT EXISTS (SELECT 1 FROM x_program_purch_hdr ph, x_program_purch_dtl pd, x_program_enrolled pe, x_sl_currentvals cv
                        WHERE 1=1
                        AND pe.x_esn = cv.x_current_esn
                        AND cv.lid=x.lid
                        AND pe.objid=pd.pgm_purch_dtl2pgm_enrolled
                        AND pd.pgm_purch_dtl2prog_hdr=ph.objid
                        AND ph.x_rqst_date >= last_day (add_months (TRUNC (ip_process_date), -1)) + 1
                        AND ph.x_payment_type IN ('LL_ENROLL', 'LL_ENROLLMENT', 'LL_RECURRING', 'LL_RECUR')
                        ); -- To make sure No Purch hdr record in this month.

    rec_sl_data_feed     cu_sl_data_feed%ROWTYPE;

    CURSOR cu_prog_enrolled (in_lid IN NUMBER)
    IS
    SELECT pe.x_esn sl_esn,
            pe.objid enroll_objid,
            pe.pgm_enroll2web_user wu_objid,
            pe.pgm_enroll2site_part sp_objid,
            cv.lid lid,
            pe.x_sourcesystem x_sourcesystem,
            pe.x_amount x_amount,
            pp.x_program_name program_name
       FROM x_program_enrolled pe, x_sl_currentvals cv, x_program_parameters pp
                WHERE pe.x_esn = cv.x_current_esn
                AND cv.lid= in_lid
                AND pe.pgm_enroll2pgm_parameter = pp.objid
                AND pe.x_enrollment_status = 'ENROLLED' AND pe.x_sourcesystem = 'VMBC';

    rec_prog_enrolled cu_prog_enrolled%ROWTYPE;

 BEGIN

     dbms_output.put_line('********** START OF PROCEDURE p_benefit_receipt_rec_insert **********');

    op_err_num      := 0;
    op_err_string   := 'SUCCESS';

    job_log('SL_BENEFIT_RECEIPT', 'SafeLink - Benefit Receipt', 'BSafelinkBenefit', 'SAFELINK', 'RUNNING', '0', 'X_JOB_RUN_DETAILS', v_job_run_objid);

    dbms_output.put_line ('Inserting record into JOB RUN ');

    IF ip_process_date IS NOT NULL THEN
    ld_process_date := TO_DATE(ip_process_date, 'MM-DD-YYYY');
    ELSE
    ld_process_date := sysdate;
    END IF;


    FOR rec_sl_data_feed IN cu_sl_data_feed (ld_process_date)
    LOOP

      OPEN cu_prog_enrolled(rec_sl_data_feed.lid);
      FETCH
        cu_prog_enrolled
      INTO
        rec_prog_enrolled;

       IF cu_prog_enrolled%found THEN
         ln_count := ln_count + 1;
         l_purch_hdr_seq := billing_seq ('X_PROGRAM_PURCH_HDR');

          --insert purchase header record
          INSERT
          INTO
            x_program_purch_hdr
            (
              objid,
              x_rqst_source,
              x_rqst_type,
              x_rqst_date,
              x_ignore_avs,
              x_ics_rcode,
              x_ics_rflag,
              x_ics_rmsg,
              x_auth_rcode,
              x_auth_rflag,
              x_auth_rmsg,
              x_bill_rcode,
              x_bill_rflag,
              x_bill_rmsg,
              x_customer_email,
              x_status,
              x_bill_country,
              x_amount,
              x_tax_amount,
              x_auth_amount,
              x_user,
              prog_hdr2web_user,
              x_payment_type,
              x_e911_tax_amount,
              x_usf_taxamount,
              x_rcrf_tax_amount,
              x_process_date
            )
            VALUES
            (
             l_purch_hdr_seq,
              rec_prog_enrolled.x_sourcesystem, ---ip_source_system,
              'LIFELINE_PURCH',
              ld_process_date,
              'Yes',
              '100',
              'ACCEPT',
              'ACCEPT',
              100,
              'ACCEPT',
              'ACCEPT',
              100,
              'ACCEPT',
              'ACCEPT',
              'null@cybersource.com',
              'LIFELINEPROCESSED',
              'USA',
              rec_prog_enrolled.x_amount,
              0,
              0,
              'System',
              rec_prog_enrolled.wu_objid,
              'LL_RECURRING',
              0,
              0,
              0,
              ip_process_date
            );



          --insert purchase detail
          INSERT
          INTO
            x_program_purch_dtl
            (
              objid,
              x_esn,
              x_amount,
              x_charge_desc,
              x_cycle_start_date,
              x_cycle_end_date,
              pgm_purch_dtl2pgm_enrolled,
              pgm_purch_dtl2prog_hdr,
              pgm_purch_dtl2penal_pend,
              x_tax_amount,
              x_e911_tax_amount,
              x_usf_taxamount,
              x_rcrf_tax_amount,
              x_priority
            )
            VALUES
            (
              billing_seq ('X_PROGRAM_PURCH_DTL'),
              rec_prog_enrolled.sl_esn,
              rec_prog_enrolled.x_amount,
              'Charges for Lifelink Wireless Customers',
              TRUNC (ld_process_date),
              TRUNC (ld_process_date) + 30,
              rec_prog_enrolled.enroll_objid, ----   PGM_PURCH_DTL2PGM_ENROLLED
              l_purch_hdr_seq,
              NULL,
              0,
              0,
              0,
              0,
              NULL
            );

          --insert x_program_trans

          INSERT
          INTO
            x_program_trans
            (
              objid,
              x_enrollment_status,
              x_enroll_status_reason,
              x_trans_date,
              x_action_text,
              x_action_type,
              x_reason,
              x_sourcesystem,
              x_esn,
              x_update_user,
              pgm_tran2pgm_entrolled,
              pgm_trans2web_user,
              pgm_trans2site_part
            )
            VALUES
            (
              billing_seq ('X_PROGRAM_TRANS'),
              'ENROLLED',
              'Monthly Benefits Receipt record',
              ld_process_date,
              'Benefits Receipt',
              'BENEFITS',
              rec_prog_enrolled.program_name,
              'System',
              rec_prog_enrolled.sl_esn,
              'operations',
              rec_prog_enrolled.enroll_objid,
              rec_prog_enrolled.wu_objid,
              rec_prog_enrolled.sp_objid
            );

      END IF;

      CLOSE cu_prog_enrolled;

    END LOOP;

   dbms_output.put_line('Total inserted into x_program_purch_hdr: '||ln_count);
   dbms_output.put_line('Total inserted into x_program_purch_dtl: '||ln_count);
   dbms_output.put_line('Total inserted into x_program_trans: '||ln_count);

    job_log('SUCCESS', v_job_run_objid);

    dbms_output.put_line('********** END OF PROCEDURE p_benefit_receipt_rec_insert **********');

 EXCEPTION
   WHEN OTHERS THEN
     op_err_num    := SQLCODE;
     op_err_string := 'P_DUMMY_PURCH_IN_SL_REDEEM Failed..ERR='|| SQLERRM;
     sa.ota_util_pkg.err_log(p_action => 'P_DUMMY_PURCH_IN_SL_REDEEM',
     p_error_date => sysdate, p_key => ('INSERT_DUMMY'), p_program_name =>
     'SAFELINK_VALIDATIONS_PKG.P_DUMMY_PURCH_IN_SL_REDEEM', p_error_text =>
     op_err_string);

     job_log('FAILED', v_job_run_objid);

     ROLLBACK;

     dbms_output.put_line('********** EXCEPTION WHILE RUNNING PROCEDURE p_benefit_receipt_rec_insert ********** op_err_num'||op_err_num||' op_err_string: '||op_err_string );

 END p_benefit_receipt_rec_insert;
--
--
 PROCEDURE p_get_part_num_by_zip_sl (ip_zip             IN table_x_zip_code.x_zip%TYPE,
                                     ip_program_name    IN x_program_parameters.x_program_name%TYPE,
                                     ip_device_type     IN x_sl_subs.x_device_type%TYPE,
                                     ip_simtype_carrier IN VARCHAR2,
                                     ip_sim_size        IN VARCHAR2,
                                     op_part_number     OUT table_part_num.part_number%TYPE,
                                     op_err_num         OUT NUMBER,
                                     op_err_string      OUT VARCHAR2) IS

 BEGIN

    op_err_num    := 0;
    op_err_string := 'Success.';

    BEGIN
       -- CR49050 Tribal
       -- Look only for the T1..TN plan types.
       --
       IF regexp_instr(UPPER(ip_program_name),'\s[T][0-9]') > 0   THEN
          --
          -- Expected like Lifeline - CA - T3' where the plan is TN.
          -- T for Tribal.
          --

          BEGIN

              SELECT part_number
                INTO op_part_number
                FROM table_part_num tpn
               WHERE tpn.objid = (SELECT CASE WHEN UPPER(ip_simtype_carrier) = 'ATT'
                                                   AND
                                                   UPPER(ip_sim_size)         = 'NANO'
                                              THEN zip.tribal_att_nano
                                              WHEN UPPER(ip_simtype_carrier) = 'ATT'
                                                   AND
                                                   UPPER(ip_sim_size)         = 'DUAL'
                                              THEN zip.tribal_att_dual
                                              WHEN UPPER(ip_simtype_carrier) = 'TMO'
                                                   AND
                                                   UPPER(ip_sim_size)         = 'NANO'
                                              THEN zip.tribal_tmo_nano
                                              WHEN UPPER(ip_simtype_carrier) = 'TMO'
                                                   AND
                                                   UPPER(ip_sim_size)         = 'DUAL'
                                              THEN zip.tribal_tmo_dual
                                              ELSE tribal_part_number
                                               END pn_objid
                                              FROM table_x_zip_code zip
                                             WHERE 1       = 1
                                               AND zip.x_zip = ip_zip);

          EXCEPTION WHEN no_data_found THEN
                    op_err_num    := -6;
                    op_err_string := 'Failed. No part number found for zip: '||ip_zip||'. '||ip_program_name;

                    WHEN OTHERS THEN
                    op_err_num    := -7;
                    op_err_string := 'p_get_part_num_by_zip_sl Failed..ERR='|| SQLERRM||' ZIP'||ip_zip||' ip_program_name '||ip_program_name;
          END;

          RETURN;

       END IF;

       IF (nvl(UPPER(ip_device_type), 'CELL') = 'CELL' OR UPPER(ip_device_type) = 'NULL') THEN
       SELECT pn.part_number
         INTO op_part_number
         FROM table_x_zip_code tzc,
              table_part_num pn
        WHERE tzc.x_zip = ip_zip
          AND pn.objid  = tzc.safelink_zip2part_num;

       RETURN;

        ELSIF UPPER(ip_device_type) = 'HOME_PHONE'  THEN

        SELECT pn.part_number
        INTO op_part_number
        FROM table_x_zip_code zip,
             table_part_num pn
        WHERE 1 = 1
        AND pn.objid = zip.safelink_zip2part_num_hp
        AND zip.x_zip = ip_zip;

      RETURN;

      /*vs: 062515 changed to display part_number from table_part_num*/
   ELSIF UPPER(ip_device_type) = 'BYOP' THEN
           WITH byop_part AS
              (SELECT
                CASE
                  WHEN UPPER(ip_simtype_carrier) = 'ATT'
                  AND UPPER(ip_sim_size)         = 'NANO'
                  THEN zip.x_att_nano
                  WHEN UPPER(ip_simtype_carrier) = 'ATT'
                  AND UPPER(ip_sim_size)         = 'DUAL'
                  THEN zip.x_att_dual
                  WHEN UPPER(ip_simtype_carrier) = 'TMO'
                  AND UPPER(ip_sim_size)         = 'NANO'
                  THEN zip.x_tmo_nano
                  WHEN UPPER(ip_simtype_carrier) = 'TMO'
                  AND UPPER(ip_sim_size)         = 'DUAL'
                  THEN zip.x_tmo_dual
                  WHEN UPPER(ip_simtype_carrier) = 'CLARO'  --CR49230 - Safelink BYOP support for Claro
                  AND UPPER(ip_sim_size)         = 'NANO'
                  THEN zip.x_claro_nano
                  WHEN UPPER(ip_simtype_carrier) = 'CLARO'  --CR49230 - Safelink BYOP support for Claro
                  AND UPPER(ip_sim_size)         = 'DUAL'
                  THEN zip.x_claro_dual
                  ELSE NULL
                END part_num
              FROM table_x_zip_code zip
              WHERE 1       = 1
              AND zip.x_zip = ip_zip
              )
            SELECT pn.part_number
              INTO op_part_number
              FROM table_part_num pn ,
                   byop_part
             WHERE pn.objid = byop_part.part_num;

         RETURN;

      ELSE

         op_part_number := NULL;

         RETURN;

     END IF;

     EXCEPTION
      WHEN too_many_rows THEN
        op_err_num    := -3;
        op_err_string := 'Failed. Too many records found for zip: '||ip_zip||'.';
      WHEN no_data_found THEN
        op_err_num    := -4;
        op_err_string := 'Failed. No part number found for zip: '||ip_zip||'.';
        WHEN OTHERS THEN
        op_err_num    := -5;
        op_err_string := 'Failed.';
       END;

 EXCEPTION
   WHEN OTHERS THEN
          op_err_num    := SQLCODE;
          op_err_string := 'p_get_part_num_by_zip_sl Failed..ERR='|| SQLERRM;
          sa.ota_util_pkg.err_log(p_action => 'p_get_part_num_by_zip_sl',
          p_error_date => sysdate, p_key => 'ip_zip: '||ip_zip, p_program_name =>
          'SAFELINK_VALIDATIONS_PKG.P_GET_PART_NUM_BY_ZIP_SL', p_error_text =>
          op_err_string);
      op_part_number := NULL;
 END p_get_part_num_by_zip_sl;
--
--
 PROCEDURE p_get_valid_e911_txn_allowed (ip_lid           IN  x_sl_subs.lid%TYPE,
                                         ip_program_objid IN  x_program_parameters.objid%TYPE,
                                         ip_part_number   IN  table_part_num.part_number%TYPE,
                                         op_txns_allowed  OUT PLS_INTEGER,
                                         op_err_num       OUT NUMBER,
                                         op_err_string    OUT VARCHAR2) IS

 CURSOR cur_sl_subs (c_in_lid IN x_sl_subs.lid%TYPE)
 IS
 SELECT objid,
        state,
        zip
   FROM sa.x_sl_subs
  WHERE lid = c_in_lid;

 rec_sl_subs cur_sl_subs%ROWTYPE;

 -- CR35974 e911 Indiana where x_provision_flag is 1.
 CURSOR cur_moneygram_lookup (c_in_state       IN x_sl_subs.state%TYPE,
                              c_ip_part_number IN table_part_num.part_number%TYPE)
 IS
 SELECT x_paycode
   FROM sa.x_moneygram_lookup
  WHERE x_provision_flag = 1
    AND x_state          = c_in_state
    AND x_part_number    = c_ip_part_number;

 rec_moneygram_lookup cur_moneygram_lookup%ROWTYPE;

 -- CR56887 - Changes for January payment count and code format improvements//OImana
 CURSOR cur_payments_made (c_moneygram_paycode IN x_mg_transactions.x_paycode%TYPE,
                           c_ip_program_objid  IN x_program_parameters.objid%TYPE,
                           c_ip_lid            IN x_sl_subs.lid%TYPE,
                           c_run_date          IN DATE,
                           c_e911_amount       IN NUMBER)
 IS
 SELECT pay_month             AS payment_month,
        SUM(NVL(pay_count,0)) AS payment_count,
        pay_channel           AS payment_channel
   FROM (SELECT TRUNC(hdr.x_rqst_date,'MM') pay_month,
                COUNT(dtl.objid)            pay_count,
                'WEB'                       pay_channel
           FROM sa.x_sl_currentvals cv,
                sa.table_x_purch_hdr hdr,
                sa.table_x_purch_dtl dtl,
                sa.table_mod_level ml,
                sa.mtm_program_safelink mtm
          WHERE mtm.program_provision_flag = 3
            AND mtm.program_param_objid = c_ip_program_objid
            AND c_run_date BETWEEN mtm.start_date AND mtm.end_date
            AND mtm.part_num_objid = ml.part_info2part_num
            AND ml.objid = dtl.x_purch_dtl2mod_level
            AND dtl.x_purch_dtl2x_purch_hdr = hdr.objid
            AND hdr.x_rqst_date BETWEEN TRUNC(c_run_date, 'YYYY') AND (LAST_DAY(ADD_MONTHS(TRUNC(c_run_date, 'YYYY'),11)) + 0.99999)
            AND hdr.x_esn = cv.x_current_esn
            AND cv.lid = c_ip_lid
         GROUP BY TRUNC(hdr.x_rqst_date,'MM')
         UNION
         SELECT TRUNC(MAX(mg.x_date_trans),'MM')            pay_month,
                TRUNC(SUM(mg.x_denomination)/c_e911_amount) pay_count,
                'MGT'                                       pay_channel
           FROM sa.x_mg_transactions mg
          WHERE mg.x_paycode = c_moneygram_paycode   --CR35974 e911 Indiana
            AND mg.x_date_trans BETWEEN TRUNC(c_run_date, 'YYYY') AND (LAST_DAY(ADD_MONTHS(TRUNC(c_run_date, 'YYYY'),11)) + 0.99999)
            AND mg.x_payment_type = 'SAFELINK E911'
            AND mg.x_lid = c_ip_lid
         UNION
         SELECT TRUNC(chk.receipt_date,'MM')                  pay_month,
                TRUNC(NVL(SUM(check_amount),0)/c_e911_amount) pay_count,
                'CHECK'                                       pay_channel
           FROM sa.xxtf_e911_tax_recon_tbl chk
          WHERE chk.llid = TO_CHAR(c_ip_lid)
            AND chk.receipt_date BETWEEN TRUNC(c_run_date, 'YYYY') AND (LAST_DAY(ADD_MONTHS(TRUNC(c_run_date, 'YYYY'),11)) + 0.99999)
         GROUP BY TRUNC(chk.receipt_date,'MM')) pay
  WHERE pay_month IS NOT NULL
 GROUP BY pay_month,
          pay_channel
 ORDER BY pay_month;

 lv_e911_txns_remaining  PLS_INTEGER := 0;
 lv_e911_amount          NUMBER;
 lv_run_date             DATE := sysdate;
 lv_pay_valid_date       DATE;

 BEGIN

   dbms_output.put_line('lv_run_date = ' || lv_run_date);

   -- CR30286 (CR29021) - 5-Nov-2014 - validate the no. of e911 payments remaining for input LID
   -- find the enrolled zip and then find the e911 fee for that zipcode
   OPEN cur_sl_subs (ip_lid);
     FETCH cur_sl_subs INTO rec_sl_subs;
   CLOSE cur_sl_subs;

   dbms_output.put_line('ip_lid='||ip_lid||', sl_subs.zip='||rec_sl_subs.zip);

   lv_e911_amount := sa.SP_TAXES.computee911surcharge2 (rec_sl_subs.zip);

   -- CR35974 e911 Indiana start
   IF NVL(lv_e911_amount, 0) = 0 THEN
     -- To avoid any runtime errors, this message is populated. This will not come on ideal case. This is database configuration error code
     op_err_num    := -88;
     op_err_string := 'E911 fee is zero or Null. Check the value set up in TABLE_X_SALES_TAX.X_E911SURCHARGE for state: '||rec_sl_subs.state;
     RETURN;
   END IF;

   OPEN cur_moneygram_lookup (rec_sl_subs.state, ip_part_number);
     FETCH cur_moneygram_lookup INTO rec_moneygram_lookup;
   CLOSE cur_moneygram_lookup;
   -- CR35974 e911 Indiana end

   lv_pay_valid_date := NULL;

   FOR icur IN cur_payments_made (rec_moneygram_lookup.x_paycode,
                                  ip_program_objid,
                                  ip_lid,
                                  lv_run_date,
                                  lv_e911_amount) LOOP

     IF lv_pay_valid_date IS NULL THEN

       lv_pay_valid_date := ADD_MONTHS(icur.payment_month, TO_NUMBER(icur.payment_count));

     ELSIF lv_pay_valid_date < TRUNC(lv_run_date,'MM') THEN

       lv_pay_valid_date := ADD_MONTHS(TRUNC(lv_run_date,'MM'), TO_NUMBER(icur.payment_count));

     ELSE

       lv_pay_valid_date := ADD_MONTHS(lv_pay_valid_date, TO_NUMBER(icur.payment_count));

     END IF;

     dbms_output.put_line('payment_month = '||icur.payment_month||' - pay count = '||icur.payment_count||' - lv_pay_valid_date = '||(lv_pay_valid_date-1));

   END LOOP;

   IF (lv_pay_valid_date IS NULL) OR (lv_pay_valid_date < TRUNC(lv_run_date,'MM')) THEN
     lv_pay_valid_date := TRUNC(lv_run_date,'MM');
   END IF;

   dbms_output.put_line('*** lv_pay_valid_date = '||(lv_pay_valid_date-1));

   -- decide how many e911 payments are allowed for remaining calendar year.

   IF lv_pay_valid_date > LAST_DAY(ADD_MONTHS(TRUNC(lv_run_date,'YYYY'),11)) THEN

     lv_e911_txns_remaining := 0;

   ELSE

     -- CR56887 - Code is not working for the first month of every calendar year and returns 0 for no. of payments allowed.
     -- CR56887 - If the value in lv_pay_valid_date falls in January then we need to default the number of remaining to 12.
     IF (TO_NUMBER(TO_CHAR(lv_pay_valid_date-1,'MM')) = 12) AND (TO_NUMBER(TO_CHAR(lv_pay_valid_date,'MM')) = 1) THEN
       lv_e911_txns_remaining := 12;  -- CR56887
     ELSE
       lv_e911_txns_remaining := 12 - TO_NUMBER(TO_CHAR(lv_pay_valid_date-1,'MM'));
     END IF;

   END IF;

   IF lv_e911_txns_remaining BETWEEN 1 AND 12 THEN
     op_txns_allowed := lv_e911_txns_remaining;
     op_err_num      := 0;
     op_err_string   := 'SUCCESS';
   ELSE
     op_txns_allowed := 0;
     op_err_num      := -1;
     op_err_string   := 'NO PAYMENT IS DUE AT THIS TIME.';
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     op_err_num    := SQLCODE;
     op_err_string := 'FAILURE..ERR=' || SUBSTR(dbms_utility.format_error_backtrace,1,200);

     sa.OTA_UTIL_PKG.err_log (p_action       => 'validate no. of pending e911 payments',
                              p_error_date   => sysdate,
                              p_key          => 'p_get_valid_e911_txn_allowed',
                              p_program_name => 'p_get_valid_e911_txn_allowed',
                              p_error_text   => SUBSTR('ip_lid='||ip_lid||', SQLERRM='||SQLERRM, 1, 1000));
 END p_get_valid_e911_txn_allowed;
--
--
 PROCEDURE calculate_taxes_prc (ip_zipcode          IN  VARCHAR2,
                                ip_partnumbers      IN  VARCHAR2,
                                ip_esn              IN  VARCHAR2,
                                ip_cc_id            IN  NUMBER,
                                ip_promo            IN  VARCHAR2,
                                ip_brand_name       IN  VARCHAR2,
                                ip_transaction_type IN  VARCHAR2, --'ACTIVATION', 'REACTIVATION','REDEMPTION','PURCHASE', 'PROMOENROLLMENT'
                                ip_sourcesystem     IN  VARCHAR2,
                                op_combstaxamt      OUT NUMBER,
                                op_e911amt          OUT NUMBER,
                                op_usfamt           OUT NUMBER,
                                op_rcrfamt          OUT NUMBER,
                                op_subtotalamount   OUT NUMBER,
                                op_totaltaxamount   OUT NUMBER,
                                op_totalcharges     OUT NUMBER,
                                op_combstaxrate     OUT NUMBER,
                                op_e911rate         OUT NUMBER,
                                op_usfrate          OUT NUMBER,
                                op_rcrfrate         OUT NUMBER,
                                op_result           OUT NUMBER,
                                op_msg              OUT VARCHAR2) IS

    ip_purchaseamt NUMBER;
    ip_airtimeamt NUMBER;
    ip_warrantyamt NUMBER;
    ip_dataonly NUMBER; --CR26033/ CR26274
    ip_totaldiscountamt NUMBER;
    ip_txtonlyamt NUMBER;
    p_tota_pn NUMBER;
    p_tota_air NUMBER;
    op_count NUMBER;
    v_promo VARCHAR2(40);
    v_fp_discount NUMBER:=0;  --Monetary Discount
    v_fp_count NUMBER:=0;  --Previously Enrolled ESNs in Family Plan
    v_fp_flag BOOLEAN:=FALSE;
    v_total_discount NUMBER:=0;
    v_sourcesystem VARCHAR2(10);
    p_model_type VARCHAR2(4000);
    p_tot_model_type NUMBER;
    v_salestaxonly_b_amt NUMBER;  --- CR41745
    v_nac_activation_b_amt NUMBER;  --- CR41745
    v_salestaxonly_a_amt NUMBER;  --- CR41745
    v_nac_activation_a_amt NUMBER;  --- CR41745

 BEGIN

      sa.sp_metadata.getcartmetadata(
      p_partnumbers => ip_partnumbers,
      p_promos => v_promo,
      v_esn => ip_esn,
      p_cc_id => ip_cc_id,
      p_source => v_sourcesystem,
      p_type => ip_transaction_type,
      p_brand_name => ip_brand_name,
      p_itemprice => NULL,
      p_totb_pn => ip_purchaseamt,
      p_tota_pn => p_tota_pn,
      p_totb_air => ip_airtimeamt,
      p_tota_air => p_tota_air,
      p_totb_wty => ip_warrantyamt,
      p_totb_dta => ip_dataonly,
      p_totb_txt => ip_txtonlyamt,
      p_tot_model_type => p_tot_model_type,
      p_model_type => p_model_type,
      p_tot_disc => ip_totaldiscountamt,
      op_count => op_count,
      op_result => op_result,
      op_msg => op_msg,
      op_salestaxonly_b_amt  =>  v_salestaxonly_b_amt,  --- CR41745
      op_salestaxonly_a_amt  => v_salestaxonly_a_amt,  --- CR41745
      op_activation_chrg_b_amt => v_nac_activation_b_amt,  --- CR41745
      op_activation_chrg_a_amt => v_nac_activation_a_amt  --- CR41745
      );

    IF op_result = 0 THEN

      sa.sp_taxes.calctax(
      ip_zipcode => ip_zipcode,
      ip_purchaseamt => ip_purchaseamt,
      ip_airtimeamt => ip_airtimeamt,
      ip_warrantyamt => ip_warrantyamt,
      ip_dataonlyamt => ip_dataonly,
      ip_txtonlyamt => ip_txtonlyamt,
      ip_shipamt =>  0,
      ip_model_type => p_model_type,
      ip_tot_model_type => p_tot_model_type,
      ip_totaldiscountamt => v_total_discount,
      ip_language => NULL,
      ip_source => v_sourcesystem,
      ip_country => NULL,
      op_combstaxamt => op_combstaxamt,
      op_e911amt => op_e911amt,
      op_usfamt => op_usfamt,
      op_rcrfamt => op_rcrfamt,
      op_subtotalamount => op_subtotalamount,
      op_totaltaxamount => op_totaltaxamount,
      op_totalcharges => op_totalcharges,
      op_result => op_result,
      op_combstaxrate => op_combstaxrate,
      op_e911rate => op_e911rate,
      op_usfrate => op_usfrate,
      op_rcrfrate => op_rcrfrate,
      op_msg => op_msg,
      ip_partnumbers => ip_partnumbers,
      ip_salestaxonly_amt  => v_salestaxonly_b_amt,   --- CR41745
      ip_nac_activation_chrg  => v_nac_activation_b_amt  --- CR41745
      );

   END IF;

 END calculate_taxes_prc;
--
--
 PROCEDURE p_get_certif_model_details (ip_zip_cde          IN  table_x_zip_code.x_zip%TYPE,
                                       ip_device_type      IN  x_sl_subs.x_device_type%TYPE,
                                       ip_carrier          IN  x_sl_subs_dtl.x_byop_carrier%TYPE,
                                       ip_sim_type         IN  x_sl_subs_dtl.x_byop_sim%TYPE,
                                       op_is_certified     OUT VARCHAR2,
                                       op_model_number     OUT table_part_class.x_model_number%TYPE,
                                       op_err_num          OUT NUMBER,
                                       op_err_string       OUT VARCHAR2) IS

      lb_record_exist BOOLEAN := FALSE;

          CURSOR cur_device_dtl
       IS
         SELECT 'Y' x_is_certified, pc.x_model_number
            FROM
            (
            SELECT
            CASE WHEN UPPER(ip_device_type) = 'HOME_PHONE'
                            THEN tzip.safelink_zip2part_num_hp
                           WHEN UPPER(ip_device_type) = 'BYOP'
                           THEN
                           (SELECT to_number( CASE WHEN UPPER(ip_carrier) = 'ATT'
                               THEN
                               CASE WHEN UPPER(ip_sim_type) = 'NANO'
                                    THEN szip.x_att_nano
                                    WHEN UPPER(ip_sim_type) = 'DUAL'
                                    THEN szip.x_att_dual
                               END
                               WHEN UPPER(ip_carrier) = 'TMO'
                               THEN
                               CASE WHEN UPPER(ip_sim_type) = 'NANO'
                                    THEN szip.x_tmo_nano
                                    WHEN UPPER(ip_sim_type) = 'DUAL'
                                    THEN szip.x_tmo_dual
                               END
                               WHEN UPPER(ip_carrier) = 'CLARO'      --CR49230 - Safelink BYOP support for Claro
                               THEN
                               CASE WHEN UPPER(ip_sim_type) = 'NANO'
                                    THEN szip.x_claro_nano
                                    WHEN UPPER(ip_sim_type) = 'DUAL'
                                    THEN szip.x_claro_dual
                               END
                           END)  sim_part_num
                           FROM table_x_zip_code szip
                           WHERE x_zip = ip_zip_cde
                            )
                           ELSE tzip.safelink_zip2part_num
                           END part_num_objid
            FROM table_x_zip_code tzip
            WHERE x_zip = ip_zip_cde
            ),
            table_part_num pn,
            table_part_class pc
            WHERE part_num_objid = pn.objid
            AND pn.part_num2part_class = pc.objid;

 BEGIN

    op_err_num := 0;
    op_err_string := 'Success';

    FOR rec IN cur_device_dtl LOOP
         op_is_certified := rec.x_is_certified;
         op_model_number := rec.x_model_number;
         lb_record_exist := TRUE;
    END LOOP;

    IF NOT lb_record_exist THEN
      op_err_num := -1;
      op_err_string := 'X_IS_CERTIFIED AND X_MODEL_NUMBER do not exist';
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
          op_err_num    := SQLCODE;
          op_err_string := 'FAILURE..ERR=' ||
          substr(dbms_utility.format_error_backtrace,1,200);

          sa.ota_util_pkg.err_log (
            p_action => 'p_get_certif_model_details',
            p_error_date => sysdate,
            p_key => 'p_get_certif_model_details',
            p_program_name => 'p_get_certif_model_details',
            p_error_text => substr(
                ' ip_zip_cde='||ip_zip_cde
          ||'ip_device_type='||ip_device_type
          ||' ip_carrier='||ip_carrier
          ||' ip_sim_type='||ip_sim_type
                ||' , SQLERRM='||  SQLERRM, 1, 1000));
 END p_get_certif_model_details;
--
--
--CR47024 Changes Starts
 FUNCTION is_srvc_plan_allowed (in_plan_partnum_objid  IN table_part_num.objid%TYPE,
                                in_esn                 IN table_part_inst.part_serial_no%TYPE)
 RETURN NUMBER IS

 is_allowed  NUMBER;
 l_sp_objid  NUMBER;
 l_plan_type  x_serviceplanfeaturevalue_def.value_name%TYPE;
 op_err_num   NUMBER;
 op_err_string   VARCHAR2(500);

 BEGIN

  BEGIN
   SELECT sp_objid
     INTO l_sp_objid
     FROM adfcrm_serv_plan_class_matview mv ,
          table_part_num pn
    WHERE part_num2part_class = part_class_objid
      AND pn.objid = in_plan_partnum_objid;
  EXCEPTION
     WHEN no_data_found THEN
        is_allowed  := 1;
        RETURN is_allowed;
  END;

  l_plan_type := get_serv_plan_value (l_sp_objid, 'PLAN TYPE');

  IF l_plan_type <> 'SL_UNL_PLANS' THEN

    is_allowed  := 1;
    RETURN is_allowed;

  ELSE

    BEGIN
      SELECT 1
      INTO is_allowed
      FROM sa.table_x_parameters
      WHERE x_param_name = 'SL_UNL_ALLOWED_PLANS_PPE'
      AND  x_param_value  = TRIM(to_char(l_sp_objid));
    EXCEPTION
      WHEN no_data_found THEN
         is_allowed  := 0;
    END;

    IF f_product_allowed_sl_ppe(in_esn) = 0 THEN
      is_allowed  := 0;
    END IF;

    dbms_output.put_line('is_allowed_for_PPE                  = ' || is_allowed  );

   RETURN is_allowed;

  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     op_err_num := -1;
     op_err_string  := substr (SQLERRM, 1, 300);
     util_pkg.insert_error_tab_proc (ip_action => 'Exception others ',
                                     ip_key => 'in_plan_partnum_objid: '||in_plan_partnum_objid,
                                     ip_program_name => 'SAFELINK_VALIDATIONS_PKG.is_srvc_plan_allowed ',
                                     ip_error_text => op_err_string);
 END is_srvc_plan_allowed;
--
--
 FUNCTION is_balance_case_created (in_esn IN VARCHAR2)
 RETURN VARCHAR2 IS

 op_err_num      NUMBER;
 op_err_string   VARCHAR2(500);

 CURSOR balance_case_cur (p_esn IN VARCHAR2)
 IS
 SELECT C.objid
 FROM table_case C,
      table_x_case_detail dtl
 WHERE dtl.detail2case = C.objid
   AND x_esn       = p_esn
   AND x_case_type = 'BALANCE'
   AND s_title       = 'BALANCE_CAPTURE'
   AND x_name  = 'PAID_BALANCE_STATUS'
   AND x_value = 'CREATED';

 balance_case_rec   balance_case_cur%ROWTYPE;

 BEGIN

  OPEN balance_case_cur (in_esn);
  FETCH balance_case_cur INTO balance_case_rec;

  IF balance_case_cur%found THEN
     CLOSE balance_case_cur;
     RETURN 'Y';
  ELSE
    CLOSE balance_case_cur;
    RETURN 'N';
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     op_err_num := -1;
     op_err_string  := substr (SQLERRM, 1, 300);
     util_pkg.insert_error_tab_proc (ip_action => 'Exception others', ip_key => 'in_esn: '||in_esn ,
                                     ip_program_name => 'SAFELINK_VALIDATIONS_PKG.is_balance_case_created ',
                                     ip_error_text => op_err_string);
 END is_balance_case_created;
--
--
 FUNCTION is_balance_storage_eligible (in_esn IN VARCHAR2)
 RETURN VARCHAR2 IS

 l_red_date  DATE;
 l_bal_capture_elig_days NUMBER;
 op_err_num      NUMBER;
 op_err_string   VARCHAR2(500);

 BEGIN

  IF  get_device_type (in_esn) = 'FEATURE_PHONE'  THEN

    BEGIN
    SELECT MAX(A.red_date)
    INTO l_red_date
    FROM (
    SELECT MAX(rc.x_red_date) AS red_date
    FROM sa.table_site_part tsp
    ,sa.table_x_call_trans ct
    ,sa.table_x_red_card rc,
     table_mod_level ml,
     table_part_num pn
    WHERE 1 = 1
    AND tsp.part_status  = 'Active'
    AND tsp.x_service_id  = in_esn
    AND tsp.objid = ct.call_trans2site_part
    AND ct.x_action_type  = '6'
    AND ct.objid = rc.red_card2call_trans
    AND ml.objid = rc.x_red_card2part_mod
    AND pn.objid = ml.part_info2part_num
    AND pn.part_type = 'PAID'
    UNION
    SELECT MAX(ct.x_transact_date)  AS red_date
    FROM x_program_gencode pg,
         table_x_call_trans ct,
         sa.table_site_part tsp
    WHERE 1 = 1
    AND pg.x_esn = ct.x_service_id
    AND pg.gencode2call_trans = ct.objid
    AND tsp.objid = ct.call_trans2site_part
    AND tsp.part_status  = 'Active'
    AND ct.x_action_type ='6'
    AND ct.x_result = 'Completed'
    AND pg.x_status = 'PROCESSED'
    AND ct.x_service_id = in_esn
    ) A
    WHERE A.red_date IS NOT NULL;
   EXCEPTION
        WHEN no_data_found THEN
          RETURN 'N';
   END;

   dbms_output.put_line('l_red_date     = ' || l_red_date  );

   BEGIN
      SELECT x_param_value
      INTO l_bal_capture_elig_days
      FROM sa.table_x_parameters
      WHERE x_param_name = 'REDEMPTION_BALANCE_CRITERIA_DAYS';
   EXCEPTION
      WHEN no_data_found THEN
         l_bal_capture_elig_days  := 0;
   END;

   dbms_output.put_line('l_bal_capture_elig_days     = ' || l_bal_capture_elig_days  );
   dbms_output.put_line('sysdate     = ' || sysdate  );

   IF l_red_date >= sysdate - l_bal_capture_elig_days THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

  ELSE

     RETURN 'Y';

  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     op_err_num := -1;
     op_err_string  := substr (SQLERRM, 1, 300);
     util_pkg.insert_error_tab_proc (ip_action => 'Exception others',
                                     ip_key => 'in_esn: '||in_esn ,
                                     ip_program_name => 'SAFELINK_VALIDATIONS_PKG.is_balance_storage_eligible ',
                                     ip_error_text => op_err_string);
 END is_balance_storage_eligible;
--
--
 FUNCTION f_get_paidunits_ppe (in_esn IN VARCHAR2)
 RETURN NUMBER IS

 l_bal_capture_elig_days  NUMBER;
 l_total_units  NUMBER;
 op_err_num      NUMBER;
 op_err_string   VARCHAR2(500);

 BEGIN

  BEGIN
  SELECT x_param_value
  INTO l_bal_capture_elig_days
  FROM sa.table_x_parameters
  WHERE x_param_name = 'REDEMPTION_BALANCE_CRITERIA_DAYS';
  EXCEPTION
  WHEN no_data_found THEN
     l_bal_capture_elig_days  := 0;
  END;

  dbms_output.put_line('l_bal_capture_elig_days     = ' || l_bal_capture_elig_days  );
  dbms_output.put_line('sysdate     = ' || sysdate  );

  IF get_device_type (in_esn) = 'FEATURE_PHONE'  THEN

     BEGIN
       SELECT NVL(SUM(total_units),0)
         INTO l_total_units
         FROM (
            SELECT SUM(ct.x_total_units) AS total_units
             FROM sa.table_site_part tsp
             ,sa.table_x_call_trans ct
             ,sa.table_x_red_card rc,
              table_mod_level ml,
              table_part_num pn
             WHERE 1 = 1
             AND tsp.part_status  = 'Active'
             AND tsp.x_service_id  = in_esn
             AND tsp.objid = ct.call_trans2site_part
             AND ct.x_action_type  = '6'
             AND ct.objid = rc.red_card2call_trans
             AND ml.objid = rc.x_red_card2part_mod
             AND pn.objid = ml.part_info2part_num
             AND pn.part_type = 'PAID'
                   AND rc.x_red_date >= sysdate - l_bal_capture_elig_days
           UNION
             SELECT SUM(ct.x_total_units)  AS total_units
             FROM x_program_gencode pg,
                table_x_call_trans ct,
              sa.table_site_part tsp
            WHERE 1 = 1
              AND pg.x_esn = ct.x_service_id
            AND pg.gencode2call_trans = ct.objid
            AND tsp.objid = ct.call_trans2site_part
            AND tsp.part_status  = 'Active'
            AND ct.x_action_type ='6'
            AND ct.x_result = 'Completed'
            AND pg.x_status = 'PROCESSED'
            AND ct.x_service_id = in_esn
            AND ct.x_transact_date >= sysdate - l_bal_capture_elig_days
            )  ;
     EXCEPTION
        WHEN OTHERS THEN
          l_total_units := 0;
     END;
    END IF;
      dbms_output.put_line('l_total_units     = ' || l_total_units  );

   RETURN l_total_units;

 EXCEPTION
   WHEN OTHERS THEN
     op_err_num := -1;
     op_err_string  := substr (SQLERRM, 1, 300);
     util_pkg.insert_error_tab_proc (ip_action => 'Exception others',
                                     ip_key => 'in_esn: '||in_esn ,
                                     ip_program_name => 'SAFELINK_VALIDATIONS_PKG.f_get_paidunits_ppe ',
                                     ip_error_text => op_err_string);
 END f_get_paidunits_ppe;
--
--
 PROCEDURE p_insert_paid_balance (in_caseid         IN  VARCHAR2,
                                  in_voice_units    IN  VARCHAR2,
                                  in_sms_units      IN  VARCHAR2,
                                  in_data_units     IN  VARCHAR2,
                                  in_balance_source IN  VARCHAR2,
                                  op_err_num        OUT NUMBER,
                                  op_err_string     OUT VARCHAR2) IS

 CURSOR balance_case_cur (p_caseid IN VARCHAR2)
 IS
 SELECT C.objid
 FROM table_case C,
     table_x_case_detail dtl
 WHERE dtl.detail2case = C.objid
  AND id_number       = p_caseid
  AND x_case_type = 'BALANCE'
  AND s_title       = 'BALANCE_CAPTURE'
  AND x_name  = 'PAID_BALANCE_STATUS'
  AND x_value = 'CREATED';

 balance_case_rec balance_case_cur%ROWTYPE;

 CURSOR case_status_cur (p_caseid IN VARCHAR2)
 IS
 SELECT C.objid,C.id_number,C.title,C.x_case_type,C.x_esn,tc.s_title AS case_status
 FROM table_case C, table_condition tc
 WHERE C.case_state2condition = tc.objid
  AND id_number = in_caseid
  AND C.x_case_type = 'BALANCE'
  AND C.s_title       = 'BALANCE_CAPTURE';

 case_status_rec  case_status_cur%ROWTYPE;

 l_user_objid    table_user.objid%TYPE;
 input_validation_failed  EXCEPTION;

 BEGIN

  IF in_caseid IS NULL THEN
     op_err_num :=  -1;
     op_err_string  := 'Case id cannot be NULL';
     RAISE input_validation_failed;
  END IF;

  OPEN balance_case_cur (in_caseid);
  FETCH balance_case_cur INTO balance_case_rec;
  IF balance_case_cur%notfound THEN
      op_err_num := -1;
      op_err_string  := 'Balance Case Not Found';
    CLOSE balance_case_cur;
      RAISE input_validation_failed;
  END IF;

  OPEN case_status_cur (in_caseid);
  FETCH case_status_cur INTO case_status_rec;
  IF case_status_rec.case_status = 'CLOSED' THEN
      op_err_num := -1;
      op_err_string  := 'Case is already closed';
      CLOSE case_status_cur;
      RAISE input_validation_failed;
  END IF;

  IF (in_voice_units IS NULL AND in_sms_units IS NULL AND in_data_units IS NULL) AND in_balance_source IS NOT NULL THEN

    UPDATE table_x_case_detail
    SET x_value =  x_value || DECODE(x_value,NULL,'','  ,  ') || 'No balance found from '||in_balance_source
    WHERE detail2case = case_status_rec.objid
    AND x_name = 'REMARKS';

  ELSE

    UPDATE table_x_case_detail
    SET x_value = in_voice_units
    WHERE detail2case = case_status_rec.objid
    AND x_name = 'VOICE_UNITS';

    UPDATE table_x_case_detail
    SET x_value = in_data_units
    WHERE detail2case = case_status_rec.objid
    AND x_name = 'DATA_UNITS';

    UPDATE table_x_case_detail
    SET x_value = in_sms_units
    WHERE detail2case = case_status_rec.objid
    AND x_name = 'SMS_UNITS';

  END IF ;

    UPDATE table_x_case_detail
    SET x_value = in_balance_source
    WHERE detail2case = case_status_rec.objid
    AND x_name = 'BALANCE_SOURCE';

    UPDATE table_x_case_detail
    SET x_value = 'PENDING'
    WHERE detail2case = case_status_rec.objid
    AND x_name = 'PAID_BALANCE_STATUS';

    UPDATE table_x_case_detail
    SET x_value = sysdate
    WHERE detail2case = case_status_rec.objid
    AND x_name = 'BALANCE_UPDATE_DATE';

    SELECT objid
     INTO l_user_objid
    FROM table_user
    WHERE s_login_name LIKE 'SA';

   sa.clarify_case_pkg.close_case (p_case_objid => case_status_rec.objid,
                    p_user_objid => l_user_objid,
                    p_source => NULL,
                    p_resolution => 'Balance Captured and Case Closed ', --Optional
                    p_status => 'Closed', --Optional
                    p_error_no => op_err_num,
                    p_error_str => op_err_string);

  CLOSE balance_case_cur;
  CLOSE case_status_cur;

  op_err_num := 0;
  op_err_string  := 'SUCCESS';

 EXCEPTION
   WHEN input_validation_failed THEN
    util_pkg.insert_error_tab_proc (ip_action => 'Input validation Failed',
                                    ip_key => 'p_caseid: '||in_caseid ,
                                    ip_program_name => 'SAFELINK_VALIDATIONS_PKG.p_insert_paid_balance',
                                    ip_error_text => op_err_string);
    ROLLBACK;
   WHEN OTHERS THEN
     op_err_num := -1;
     op_err_string  := substr (SQLERRM, 1, 300);
     util_pkg.insert_error_tab_proc (ip_action => 'Exception Others',
                                     ip_key => 'p_caseid: '||in_caseid ,
                                     ip_program_name => 'SAFELINK_VALIDATIONS_PKG.p_insert_paid_balance',
                                     ip_error_text => op_err_string);
     RETURN;
 END p_insert_paid_balance;
--
--
 PROCEDURE p_retrieve_paid_balance (in_esn                 IN  VARCHAR2,
                                    in_balance_replay_date IN  DATE,
                                    io_caseid              IN  OUT VARCHAR2,
                                    o_voice_units          OUT VARCHAR2,
                                    o_sms_units            OUT VARCHAR2,
                                    o_data_units           OUT VARCHAR2,
                                    o_balance_trans_id     OUT VARCHAR2,
                                    o_replacement_case     OUT VARCHAR2,
                                    o_replace_days         OUT NUMBER,
                                    op_err_num             OUT NUMBER,
                                    op_err_string          OUT VARCHAR2) IS

CURSOR balance_case_cur (p_caseid IN VARCHAR2)
IS
SELECT C.objid,dtl.x_value AS status
FROM table_case C,
     table_x_case_detail dtl
WHERE dtl.detail2case = C.objid
  AND id_number       = p_caseid
  AND x_case_type = 'BALANCE'
  AND s_title       = 'BALANCE_CAPTURE'
  AND x_name  = 'PAID_BALANCE_STATUS';

balance_case_rec balance_case_cur%ROWTYPE;

CURSOR case_status_cur (p_caseid IN VARCHAR2)
IS
SELECT C.objid,C.id_number,C.title,C.x_case_type,C.x_esn,tc.s_title AS case_status
 FROM table_case C, table_condition tc
WHERE C.case_state2condition = tc.objid
  AND id_number = p_caseid
  AND C.x_case_type = 'BALANCE'
  AND C.s_title       = 'BALANCE_CAPTURE';

case_status_rec  case_status_cur%ROWTYPE;
l_case_objid  table_case.objid%TYPE;
l_case_idnumber  table_case.id_number%TYPE;
update_balance  BOOLEAN;
retrive_balance BOOLEAN;
input_validation_failed  EXCEPTION;

 BEGIN

  IF in_esn IS NULL AND io_caseid IS NULL THEN
     op_err_num :=  -1;
     op_err_string  := 'ESN and CASE ID both cannot be NULL';
     RAISE input_validation_failed;
  ELSIF in_esn IS NOT NULL AND io_caseid IS NOT NULL THEN
     op_err_num :=  -1;
     op_err_string  := 'Please input either ESN or Caseid - not Both';
     RAISE input_validation_failed;
  END IF;

    dbms_output.put_line('in_esn ' ||in_esn);
    dbms_output.put_line('io_caseid ' ||io_caseid);

  IF io_caseid IS NOT NULL THEN
     l_case_idnumber  := io_caseid;
     update_balance := TRUE;
  ELSE
     BEGIN
  SELECT MAX(objid)
       INTO l_case_objid
      FROM table_case
     WHERE x_esn      = in_esn
      AND x_case_type = 'BALANCE'
      AND s_title       = 'BALANCE_CAPTURE';
    EXCEPTION
   WHEN no_data_found THEN
   op_err_num := -1;
   op_err_string  := 'Balance Case not Found for this ESN';
   RAISE input_validation_failed;
  END;

     SELECT id_number
       INTO l_case_idnumber
      FROM table_case
     WHERE objid = l_case_objid;

     retrive_balance := TRUE;
      dbms_output.put_line('l_case_objid ' ||l_case_objid);
      dbms_output.put_line('l_case_idnumber - derived from esn' ||l_case_idnumber);
  END IF;
    dbms_output.put_line('l_case_idnumber  ' ||l_case_idnumber);

    OPEN case_status_cur (l_case_idnumber);
    FETCH case_status_cur INTO case_status_rec;

      dbms_output.put_line('case_status_rec.case_status ' ||case_status_rec.case_status);
      dbms_output.put_line('case_status_rec.objid ' ||case_status_rec.objid);

      dbms_output.put_line('before balance cur l_case_idnumber ' ||l_case_idnumber);

 OPEN balance_case_cur (l_case_idnumber);
 FETCH balance_case_cur INTO balance_case_rec;
 IF balance_case_cur%notfound THEN
      op_err_num := -1;
      op_err_string  := 'Balance Case Not Found';
      CLOSE balance_case_cur;
      RAISE input_validation_failed;
 ELSE
    IF update_balance THEN
        IF balance_case_rec.status = 'CREATED' THEN
          op_err_num := -1;
          op_err_string  := 'Balance is not captured Yet';
          CLOSE balance_case_cur;
          RAISE input_validation_failed;
        ELSIF balance_case_rec.status = 'RETRIVED' THEN
          op_err_num := -1;
          op_err_string  := 'Balance is already retrieved';
          CLOSE balance_case_cur;
          RAISE input_validation_failed;
        ELSIF balance_case_rec.status = 'PENDING' THEN
            dbms_output.put_line('inside update_balance, case objid is ' ||case_status_rec.objid);
            UPDATE table_x_case_detail
            SET x_value = sysdate
            WHERE detail2case = case_status_rec.objid
            AND x_name = 'BALANCE_REPLAY_DATE';

            UPDATE table_x_case_detail
            SET x_value = 'RETRIVED'
            WHERE detail2case = case_status_rec.objid
            AND x_name = 'PAID_BALANCE_STATUS';
        END IF;
     ELSIF  retrive_balance THEN
        dbms_output.put_line('inside retrieve_balance, case objid is ' ||case_status_rec.objid);
        SELECT *
        INTO o_voice_units,o_sms_units,o_data_units,o_balance_trans_id,o_replacement_case,o_replace_days
        FROM (SELECT x_name,x_value FROM table_x_case_detail
                 WHERE  detail2case = case_status_rec.objid)
        PIVOT
        (
        MAX(x_value) FOR x_name IN
        ('VOICE_UNITS','SMS_UNITS','DATA_UNITS','BALANCE_TRANS_ID','REPLACEMENT_CASE','REPLACE_DAYS')
        );

        io_caseid := l_case_idnumber;
     END IF;
  END IF;

  CLOSE balance_case_cur;
  CLOSE case_status_cur;
  op_err_num := 0;
  op_err_string  := 'SUCCESS';

 EXCEPTION
   WHEN input_validation_failed THEN
    util_pkg.insert_error_tab_proc (ip_action => 'Input validation Failed ',
                                    ip_key => 'caseid: '||io_caseid ||'in_esn '|| in_esn,
                                    ip_program_name => 'SAFELINK_VALIDATIONS_PKG.p_retrieve_paid_balance',
                                    ip_error_text => op_err_string);
     ROLLBACK;
   WHEN OTHERS THEN
   op_err_num := -1;
   op_err_string  := substr (SQLERRM, 1, 300);
   util_pkg.insert_error_tab_proc (ip_action => 'Exception Others',
                                   ip_key => 'caseid: '||io_caseid ||'in_esn '|| in_esn,
                                   ip_program_name => 'SAFELINK_VALIDATIONS_PKG.p_retrieve_paid_balance',
                                   ip_error_text => op_err_string);
 END p_retrieve_paid_balance;
--
--
 PROCEDURE p_transfer_paid_balance_case (in_fromesn     IN  VARCHAR2,
                                         in_toesn       IN  VARCHAR2,
                                         op_err_num     OUT NUMBER,
                                         op_err_string  OUT VARCHAR2) IS

   l_case_objid  table_case.objid%TYPE;

 BEGIN

  SELECT MAX(C.objid)
   INTO l_case_objid
  FROM table_case C,
      table_x_case_detail dtl
  WHERE dtl.detail2case = C.objid
    AND x_esn       = in_fromesn
    AND x_case_type = 'BALANCE'
    AND title       = 'BALANCE_CAPTURE'
    AND x_name  = 'PAID_BALANCE_STATUS'
    AND x_value IN ('CREATED','PENDING');


   IF l_case_objid IS NULL THEN
  op_err_num := -1;
  op_err_string  := 'No Balance case found for the fromesn : ' || in_fromesn;
  util_pkg.insert_error_tab_proc ( ip_action => 'Balance case not found',
                                   ip_key => 'in_fromesn '|| in_fromesn,
                                   ip_program_name => 'SAFELINK_VALIDATIONS_PKG.p_transfer_paid_balance_case', ip_error_text => op_err_string);
  RETURN;
 END IF;

  dbms_output.put_line(' l_case_objid ' ||l_case_objid);

  UPDATE table_case
   SET x_esn = in_toesn
  WHERE objid = l_case_objid;

  IF SQL%ROWCOUNT = 0 THEN
    op_err_num := -1;
    op_err_string  := 'Update failed, in_toesn: ' ||in_toesn ;
    util_pkg.insert_error_tab_proc ( ip_action => NULL , ip_key => 'in_fromesn '||in_fromesn ||'l_case_objid : '||l_case_objid, ip_program_name => 'SAFELINK_VALIDATIONS_PKG.p_transfer_paid_balance_case', ip_error_text => op_err_string);
    RETURN;
  ELSE
     dbms_output.put_line(' Updating REMARKS');

      UPDATE table_x_case_detail
        SET x_value =  x_value || DECODE(x_value,NULL,'','  ,  ') ||'Due to Phone Upgrade - Balance ticket updated with new esn '|| in_toesn
      WHERE detail2case = l_case_objid
        AND x_name = 'REMARKS';

      op_err_num    := 0;
      op_err_string :=  'SUCCESS';
  END IF;
 EXCEPTION
   WHEN OTHERS THEN
    op_err_num := -1;
    op_err_string  := substr (SQLERRM, 1, 300);
    util_pkg.insert_error_tab_proc ( ip_action => 'Exception Others', ip_key => 'in_fromesn '|| in_fromesn,
                                     ip_program_name => 'SAFELINK_VALIDATIONS_PKG.p_transfer_paid_balance_case',
                                     ip_error_text => op_err_string);
 END p_transfer_paid_balance_case;
--
--
--CR47024 Changes Ends
--CR48643 adding overloaded p_validate_min
 PROCEDURE p_validate_min_sp (ip_key                 IN  VARCHAR2,
                              ip_value               IN  VARCHAR2,
                              ip_source_system       IN  VARCHAR2,
                              op_actiontype          OUT VARCHAR2,
                              op_enroll_zip          OUT VARCHAR2,
                              op_web_user_id         OUT NUMBER,
                              op_lid                 OUT NUMBER,
                              op_esn                 OUT VARCHAR2,
                              op_contact_objid       OUT NUMBER,
                              op_err_num             OUT NUMBER,
                              op_err_string          OUT VARCHAR2,
                              o_sp_detail_refcursor  OUT SYS_REFCURSOR) IS

  lv_refcur_rec          sl_refcur_rec;
  lv_refcur_tab          sl_refcur_tab := sl_refcur_tab();
  op_refcursor           SYS_REFCURSOR;

 BEGIN
  --OPEN REFCURSOR SO THAT IT IS NOT EMPTY_BLOB
  OPEN o_sp_detail_refcursor FOR
    SELECT  NULL  part_number,
            NULL  pn_desc,
            NULL  x_retail_price,
            NULL  sp_objid,
            NULL  plan_type,
            NULL  service_plan_group,
            NULL  mkt_name,
            NULL  sp_desc,
            NULL  customer_price,
            NULL  ivr_plan_id,
            NULL  webcsr_display_name,
            NULL  x_sp2program_param,
            NULL  x_program_name,
            NULL  cycle_start_date,
            NULL  cycle_end_date,
            NULL  quantity,
            NULL  coverage_script,
            NULL  short_script,
            NULL  trans_script,
            NULL  script_type,
            NULL  sl_program_flag,
            NULL  enroll_state_full_name,
            NULL  service_plan_objid,
            NULL  mobile_description1,
            NULL  mobile_description2,
            NULL  mobile_description3,
            NULL  mobile_description4,
            NULL  voice_units,
            NULL  sms_units,
            NULL  data_units,
            NULL  service_days,
            NULL  ild_supported,
            NULL  service_plan_purchase,
            NULL  reward_points,
            NULL  ild_product,
            NULL  recurring_service_plan,
            NULL  price_mon,
            NULL  enrl_price_mon,
            NULL  x_recurring,
            NULL  number_of_lines,
            NULL  mobile_plan_category
    FROM dual;
  -- CALL ORIGINAL PROCEDURE
  p_validate_min (ip_key             => ip_key,
                  ip_value           => ip_value,
                  ip_source_system   => ip_source_system,
                  op_actiontype      => op_actiontype,
                  op_enroll_zip      => op_enroll_zip,
                  op_web_user_id     => op_web_user_id,
                  op_lid             => op_lid,
                  op_esn             => op_esn,
                  op_contact_objid   => op_contact_objid,
                  op_refcursor       => op_refcursor,
                  op_err_num         => op_err_num,
                  op_err_string      => op_err_string );
  IF  op_err_num = 0 AND  op_esn IS NOT NULL THEN
    LOOP
      lv_refcur_tab.extend();
      lv_refcur_tab(lv_refcur_tab.LAST) := sl_refcur_rec(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      IF op_refcursor%ISOPEN
      THEN
        FETCH op_refcursor
        INTO lv_refcur_tab(lv_refcur_tab.LAST).part_number,
             lv_refcur_tab(lv_refcur_tab.LAST).pn_desc,
             lv_refcur_tab(lv_refcur_tab.LAST).x_retail_price,
             lv_refcur_tab(lv_refcur_tab.LAST).sp_objid,
             lv_refcur_tab(lv_refcur_tab.LAST).plan_type,
             lv_refcur_tab(lv_refcur_tab.LAST).service_plan_group,
             lv_refcur_tab(lv_refcur_tab.LAST).mkt_name,
             lv_refcur_tab(lv_refcur_tab.LAST).sp_desc,
             lv_refcur_tab(lv_refcur_tab.LAST).customer_price,
             lv_refcur_tab(lv_refcur_tab.LAST).ivr_plan_id,
             lv_refcur_tab(lv_refcur_tab.LAST).webcsr_display_name,
             lv_refcur_tab(lv_refcur_tab.LAST).x_sp2program_param,
             lv_refcur_tab(lv_refcur_tab.LAST).x_program_name,
             lv_refcur_tab(lv_refcur_tab.LAST).cycle_start_date,
             lv_refcur_tab(lv_refcur_tab.LAST).cycle_end_date,
             lv_refcur_tab(lv_refcur_tab.LAST).quantity,
             lv_refcur_tab(lv_refcur_tab.LAST).coverage_script,
             lv_refcur_tab(lv_refcur_tab.LAST).short_script,
             lv_refcur_tab(lv_refcur_tab.LAST).trans_script,
             lv_refcur_tab(lv_refcur_tab.LAST).script_type,
             lv_refcur_tab(lv_refcur_tab.LAST).sl_program_flag,
             lv_refcur_tab(lv_refcur_tab.LAST).enroll_state_full_name      ;
        EXIT WHEN op_refcursor%NOTFOUND;
      ELSE
         EXIT;
      END IF;
    END LOOP;

    lv_refcur_tab.DELETE(lv_refcur_tab.LAST);

    IF op_refcursor%ISOPEN --{ added for CR44611
    THEN
     CLOSE op_refcursor;
    END IF; --} added for CR44611

    OPEN o_sp_detail_refcursor FOR
      SELECT DISTINCT t_cur.part_number,
                      t_cur.pn_desc,
                      t_cur.x_retail_price,
                      t_cur.sp_objid,
                      t_cur.plan_type,
                      t_cur.service_plan_group,
                      NVL(t_cur.mkt_name,mv.mkt_name) mkt_name,
                      t_cur.sp_desc,
                      t_cur.customer_price,
                      t_cur.ivr_plan_id,
                      t_cur.webcsr_display_name,
                      t_cur.x_sp2program_param,
                      t_cur.x_program_name,
                      t_cur.cycle_start_date,
                      t_cur.cycle_end_date,
                      t_cur.quantity,
                      t_cur.coverage_script,
                      t_cur.short_script,
                      t_cur.trans_script,
                      t_cur.script_type,
                      t_cur.sl_program_flag,
                      t_cur.enroll_state_full_name,
                      mv.service_plan_objid,
                      mv.mobile_description1,
                      mv.mobile_description2,
                      mv.mobile_description3,
                      mv.mobile_description4,
                      mv.voice voice_units,
                      mv.sms   sms_units,
                      mv.DATA  data_units,
                      mv.service_days,
                      mv.ild ild_supported,
                      mv.service_plan_purchase,
                      mv.rewards_points reward_points,
                      mv.ild_product,
                      mv.recurring_service_plan,
                      p1.x_retail_price price_mon,
                      p2.x_retail_price enrl_price_mon,
                      spxpp.x_recurring x_recurring,
                      mv.number_of_lines,
                      mv.mobile_plan_category
      FROM   TABLE(CAST (lv_refcur_tab AS sl_refcur_tab)) t_cur
      LEFT OUTER JOIN
             service_plan_feat_pivot_mv mv
      ON     t_cur.sp_objid= mv.service_plan_objid
      LEFT OUTER JOIN
             mtm_sp_x_program_param spxpp
      ON     spxpp.program_para2x_sp= mv.service_plan_objid
      LEFT OUTER JOIN x_program_parameters  xpp
      ON     xpp.objid = spxpp.x_sp2program_param
      LEFT OUTER JOIN table_part_num pn2
      ON     pn2.objid = xpp.prog_param2prtnum_enrlfee
      LEFT OUTER JOIN table_x_pricing p1
      ON     p1.x_pricing2part_num = xpp.prog_param2prtnum_monfee
      LEFT OUTER JOIN table_x_pricing p2
      ON     p2.x_pricing2part_num = xpp.prog_param2prtnum_enrlfee
      AND    p1.x_end_date > sysdate
      AND    p2.x_end_date > sysdate;

  END IF;--IF  op_err_num = 0 and  op_esn IS NOT NULL

 EXCEPTION
   WHEN OTHERS THEN
    OPEN o_sp_detail_refcursor FOR
    SELECT  NULL  part_number,
            NULL  pn_desc,
            NULL  x_retail_price,
            NULL  sp_objid,
            NULL  plan_type,
            NULL  service_plan_group,
            NULL  mkt_name,
            NULL  sp_desc,
            NULL  customer_price,
            NULL  ivr_plan_id,
            NULL  webcsr_display_name,
            NULL  x_sp2program_param,
            NULL  x_program_name,
            NULL  cycle_start_date,
            NULL  cycle_end_date,
            NULL  quantity,
            NULL  coverage_script,
            NULL  short_script,
            NULL  trans_script,
            NULL  script_type,
            NULL  sl_program_flag,
            NULL  enroll_state_full_name,
            NULL  service_plan_objid,
            NULL  mobile_description1,
            NULL  mobile_description2,
            NULL  mobile_description3,
            NULL  mobile_description4,
            NULL  voice_units,
            NULL  sms_units,
            NULL  data_units,
            NULL  service_days,
            NULL  ild_supported,
            NULL  service_plan_purchase,
            NULL  reward_points,
            NULL  ild_product,
            NULL  recurring_service_plan,
            NULL  price_mon,
            NULL  enrl_price_mon,
            NULL  x_recurring,
            NULL  number_of_lines,
            NULL  mobile_plan_category
    FROM dual;
 END p_validate_min_sp;
--
--
END safelink_validations_pkg;
/