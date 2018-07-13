CREATE OR REPLACE PACKAGE BODY sa."SWITCH_BASED" IS
  /********************************************************************************/
  /*    Copyright ) 2009 Tracfone  Wireless Inc. All rights reserved              */
  /*                                                                              */
  /* NAME:         SWITCH_BASED(PACKAGE SPECIFICATION)                            */
  /* PURPOSE:      switch based functionality                                     */
  /* FREQUENCY:                                                                   */
  /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                               */
  /* REVISIONS:                                                                   */
  /* VERSION  DATE     WHO        PURPOSE                                         */
  /* ------  ----     ------      --------------------------------------------    */
  /* 1.0    04/07/09  jvalencia    Initial  Revision                              */
  /* 1.1/1.2/1.3    05/08/09 CLindner      Optimized
  /*1.4/1.5     05/20/09   jvalencia    Added changes for PORT                             */
  /*1.6            05/26/09   VAdapa      Added changes for PORT                             */
  /*1.7            06/24/09   VAdapa      STUL                             */
  /*1.8/1.9             06/10/09  VAdapa     STUL_taxes (CR11061)
  /*1.10         09/24/09    VAdapa     CR11526 - Straight talk Automation Bundle 1
  /*1.11-14      10/13/09    VAdapa     CR11975 - ST_BUNDLE_II_A change parameter
  /*                                    in passive_ activation p_msid
  /*1.15         05/10/10    Skuthadi   CR11971 To avoid x_switchbase_transaction logic if its ST GSM ESN  */
  /********************************************************************************/
  --
  --********************************************************************************
  --$RCSfile: SWITCH_BASED.sql,v $
  --$Revision: 1.4 $
  --$Author: kacosta $
  --$Date: 2012/06/08 14:09:09 $
  --$ $Log: SWITCH_BASED.sql,v $
  --$ Revision 1.4  2012/06/08 14:09:09  kacosta
  --$ CR21060 Update SIM status to Active.
  --$
  --$
  --********************************************************************************
  --
  /*****************************************************************************/
  /*                                                                            */
  /* Name:passive_activation                                                    */
  /* Description : activate phone-line in 'TRACFONE' database.                  */
  /*               Used when doing PORT-INS and after closing the               */
  /*               the ticket and activation on the RSS and Switch.             */
  /*****************************************************************************/
  PROCEDURE passive_activation
  (
    p_min        IN VARCHAR2
   ,p_esn        IN VARCHAR2
   ,p_msid       IN VARCHAR2
   ,p_err_num    OUT NUMBER
   ,p_err_string OUT VARCHAR2
   ,p_due_date   OUT DATE
  ) IS
    CURSOR c_call_tx IS
      SELECT ctx.objid
            ,ctx.call_trans2site_part
        FROM table_x_call_trans ctx
       WHERE x_service_id = p_esn
            --AND X_action_type in = '1'
         AND x_action_type IN ('1'
                              ,'3') --CR11526
         AND x_result = 'Completed'
       ORDER BY ctx.x_transact_date DESC;

    r_call_tx c_call_tx%ROWTYPE;

    --CR11061
    --       CURSOR c_part_inst
    --       IS
    --       SELECT pi.objid,
    --          (
    --          SELECT COUNT(*) cnt
    --       FROM table_part_inst pi_phone
    --             WHERE pi_phone.part_to_esn2part_inst = pi.objid
    --             AND x_domain = 'LINES') numOfLines
    --       FROM table_part_inst pi
    --       WHERE pi.part_serial_no = p_esn
    --       AND pi.x_domain = 'PHONES';
    CURSOR c_part_inst IS
      SELECT pi.objid
            ,(SELECT COUNT(*) cnt
                FROM table_part_inst pi_phone
               WHERE pi_phone.part_to_esn2part_inst = pi.objid
                 AND x_domain = 'LINES') numoflines
            ,(SELECT pi_msid.x_msid
                FROM table_part_inst pi_msid
               WHERE pi_msid.part_to_esn2part_inst = pi.objid
                 AND x_domain = 'LINES'
                 AND pi_msid.part_serial_no NOT LIKE 'T%') msid
        FROM table_part_inst pi
       WHERE pi.part_serial_no = p_esn
         AND pi.x_domain = 'PHONES';

    --CR11061
    r_part_inst c_part_inst%ROWTYPE;

    CURSOR value_def_curs(c_site_part_objid IN NUMBER) IS
      SELECT spfvd2.value_name servicenumber
        FROM x_serviceplanfeaturevalue_def spfvd2
            ,x_serviceplanfeature_value    spfv
            ,x_service_plan_feature        spf
            ,x_serviceplanfeaturevalue_def spfvd
            ,x_service_plan_site_part      spsp
       WHERE 1 = 1
         AND spfvd2.objid = spfv.value_ref
         AND spfv.spf_value2spf = spf.objid
         AND spf.sp_feature2rest_value_def = spfvd.objid
         AND spf.sp_feature2service_plan = spsp.x_service_plan_id
         AND spfvd.value_name = 'SERVICE DAYS'
         AND spsp.table_site_part_id = c_site_part_objid;

    CURSOR chk_st_gsm_cur -- CR11971 ST_GSM
    IS
      SELECT pcv.x_param_value
        FROM table_x_part_class_params pcp
            ,table_x_part_class_values pcv
            ,table_part_num            pn
            ,table_part_inst           pi
            ,table_mod_level           ml
            ,table_bus_org             bo
       WHERE 1 = 1
         AND pcp.x_param_name = 'NON_PPE'
         AND pi.part_serial_no = p_esn
         AND pn.part_num2bus_org = bo.objid
         AND bo.org_id = 'STRAIGHT_TALK'
         AND pcv.value2class_param = pcp.objid
         AND pcv.value2part_class = pn.part_num2part_class
         AND ml.part_info2part_num = pn.objid
         AND pi.n_part_inst2part_mod = ml.objid;

    rec_chk_st_gsm chk_st_gsm_cur%ROWTYPE;

    value_def_rec value_def_curs%ROWTYPE;
    stmt          VARCHAR2(1000); -- Statement been executed
    too_many_lines      EXCEPTION;
    value_def_not_found EXCEPTION;
  BEGIN
    OPEN c_call_tx;

    FETCH c_call_tx
      INTO r_call_tx;

    IF c_call_tx%FOUND THEN
      stmt := 'select a.VALUE_NAME INTO servicenumber';

      OPEN value_def_curs(r_call_tx.call_trans2site_part);

      FETCH value_def_curs
        INTO value_def_rec;

      IF value_def_curs%NOTFOUND THEN
        CLOSE c_call_tx;

        CLOSE value_def_curs;

        RAISE value_def_not_found;
      END IF;

      CLOSE value_def_curs;

      -- Complete the TX
      stmt := 'update table_x_call_trans';

      UPDATE table_x_call_trans
         SET x_result       = 'Completed'
            ,x_min          = p_min
            ,x_new_due_date =
             (SYSDATE + value_def_rec.servicenumber)
       WHERE objid = r_call_tx.objid;

      -- ST_GSM CR11971 Starts
      OPEN chk_st_gsm_cur;

      FETCH chk_st_gsm_cur
        INTO rec_chk_st_gsm;

      IF chk_st_gsm_cur%FOUND THEN

        IF rec_chk_st_gsm.x_param_value != 0 THEN
          -- ST_GSM CR11971 Skip Update x_switchbased_transaction
          -- if ESN is ST GSM
          -- Complete SwB Tx
          stmt := 'x_switchbased_transaction';

          UPDATE x_switchbased_transaction
             SET status   = 'Completed'
                ,exp_date =
                 (SYSDATE + value_def_rec.servicenumber)
           WHERE x_sb_trans2x_call_trans = r_call_tx.objid;

        END IF;
      END IF;

      CLOSE chk_st_gsm_cur; -- ST_GSM CR11971 ENDS

      --          -- SITE PART
      --          stmt := 'update table_site_part';
      --          UPDATE table_site_part SET PART_STATUS = 'Active', x_min = p_min,
      --          x_msid = p_min, --todo:keep it for now. It may be changed.
      --          --service_end_dt = (SYSDATE + value_def_rec.servicenumber),
      --          x_expire_dt = (SYSDATE + value_def_rec.servicenumber)
      --          WHERE objid = r_call_tx.call_trans2site_part;
      -- Section to UPDATE PART INST
      OPEN c_part_inst;

      FETCH c_part_inst
        INTO r_part_inst;

      IF c_part_inst%FOUND THEN
        IF r_part_inst.numoflines > 2 THEN
          CLOSE c_part_inst;

          CLOSE c_call_tx;

          RAISE too_many_lines;
        ELSIF r_part_inst.numoflines = 2 THEN
          stmt := 'delete from  table_part_inst';

          DELETE FROM table_part_inst
           WHERE part_serial_no LIKE 'T%'
             AND part_to_esn2part_inst = r_part_inst.objid
             AND x_domain = 'LINES';
        END IF;

        stmt := 'update table_part_inst';

        -- UPDATE LINE in PART INST
        IF p_msid IS NULL THEN
          UPDATE table_part_inst
             SET x_part_inst_status  = '13'
                ,status2x_code_table = 960
                ,warr_end_date      =
                 (SYSDATE + value_def_rec.servicenumber)
                ,part_serial_no      = p_min
                , --x_msid = p_min, --CR11061
                 x_port_in           = 0 --2 STUL
           WHERE part_to_esn2part_inst = r_part_inst.objid
             AND x_domain = 'LINES';
        ELSE
          UPDATE table_part_inst
             SET x_part_inst_status  = '13'
                ,status2x_code_table = 960
                ,warr_end_date      =
                 (SYSDATE + value_def_rec.servicenumber)
                ,part_serial_no      = p_min
                ,x_msid              = p_msid
                ,
                 --ST_BUNDLE_II--x_msid = p_min, --CR11061
                 x_port_in = 0 --2 STUL
           WHERE part_to_esn2part_inst = r_part_inst.objid
             AND x_domain = 'LINES';
        END IF;

        UPDATE table_part_inst
           SET warr_end_date      =
               (SYSDATE + value_def_rec.servicenumber)
              ,x_part_inst_status  = '52'
              ,last_trans_time    =
               (SYSDATE + value_def_rec.servicenumber)
              ,status2x_code_table = 988
              ,x_port_in           = 0 --2 STUL
         WHERE part_serial_no = p_esn
           AND x_domain = 'PHONES';

        --CR11061
        -- SITE PART
        stmt := 'update table_site_part';

        --ST_BUNDLE_II
        IF p_msid IS NULL THEN
          UPDATE table_site_part
             SET part_status = 'Active'
                ,x_min       = p_min
                ,x_msid      = r_part_inst.msid
                ,x_expire_dt =
                 (SYSDATE + value_def_rec.servicenumber)
           WHERE objid = r_call_tx.call_trans2site_part;
        ELSE
          UPDATE table_site_part
             SET part_status = 'Active'
                ,x_min       = p_min
                ,x_msid      = p_msid
                ,x_expire_dt =
                 (SYSDATE + value_def_rec.servicenumber)
           WHERE objid = r_call_tx.call_trans2site_part;
        END IF;
        --ST_BUNDLE_II
        --CR11061
        --
        --CR21060 Start kacosta 06/05/2012
        UPDATE table_x_sim_inv xsi
           SET xsi.x_last_update_date        = SYSDATE
              ,xsi.x_sim_inv_status          = '254'
              ,xsi.x_sim_status2x_code_table = 268438607
         WHERE EXISTS (SELECT 1
                  FROM table_part_inst tpi
                  JOIN table_site_part tsp
                    ON tpi.part_serial_no = tsp.x_service_id
                 WHERE tpi.part_serial_no = p_esn
                   AND tpi.x_iccid = xsi.x_sim_serial_no
                   AND tpi.x_part_inst_status = '52'
                   AND tsp.objid = r_call_tx.call_trans2site_part
                   AND tsp.x_iccid = xsi.x_sim_serial_no
                   AND tsp.part_status = 'Active')
           AND xsi.x_sim_inv_status IN ('251'
                                       ,'253');
        --CR21060 End kacosta 06/05/2012
        --
      END IF;

      CLOSE c_part_inst;
    END IF;

    CLOSE c_call_tx;

    COMMIT;
    p_due_date   := (SYSDATE + value_def_rec.servicenumber);
    p_err_num    := 0;
    p_err_string := 'Success';
  EXCEPTION
    WHEN too_many_lines THEN
      p_err_num    := -111;
      p_err_string := 'More than two lines found.';
      ROLLBACK;
    WHEN value_def_not_found THEN
      p_err_num    := -111;
      p_err_string := 'No value def found.';
      ROLLBACK;
    WHEN others THEN
      ROLLBACK;
      p_due_date   := NULL;
      p_err_num    := SQLCODE;
      p_err_string := SQLERRM || ':::Location:' || stmt;
  END passive_activation;
END switch_based;
/