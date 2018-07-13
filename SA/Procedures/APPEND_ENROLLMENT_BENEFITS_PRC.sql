CREATE OR REPLACE PROCEDURE sa."APPEND_ENROLLMENT_BENEFITS_PRC"
  ---------------------------------------------------------------------------------------------
  --$RCSfile: APPEND_ENROLLMENT_BENEFITS_PRC.sql,v $
  --$Revision: 1.7 $
  --$Author: ddevaraj $
  --$Date: 2015/04/16 21:27:06 $
  --$ $Log: APPEND_ENROLLMENT_BENEFITS_PRC.sql,v $
  --$ Revision 1.7  2015/04/16 21:27:06  ddevaraj
  --$ FOR CR31908
  --$
  --$ Revision 1.5  2012/04/17 15:41:28  ymillan
  --$ CR19821
  --$
  --$ Revision 1.4  2011/11/23 19:13:07  pmistry
  --$ Added CarrierPending with reference to defect # 77
  --$
  ---------------------------------------------------------------------------------------------
  /******************************************************************************/
  /* Name      :   APPEND_ENROLLMENT_BENEFITS_PRC
  /* Type      :   Procedure
  /* Purpose   :   Append Enrollment Benefits
  /* Author    :   Natalio
  /* Date      :   07/01/2009
  /* Revisions :   Version  Date      Who         Purpose
  /*               -------  --------  -------     -----------------------
  /*               1.0       07/01/09  NGuada    Initial revision
  /*               1.1       07/29/09  CLindner  CR8470 work on IOs for 2 cursors
  /*               1.2/1.3   08/14/09  AKhan    CR11503
  /*               1.4       01/18/10  NGuada   CR11623 BRAND_SEP_IV
  /*
  /*               CVS Versions
  /*               1.1       03/12/10  NGuada     PVCS to CVS Migration
  /*               1.2       02/22/11  Kacosta    CR12843 Call Trans objid is NULL for Action type 8
  /*                                              Added code to set the CT_OBJID variable to set the
  /*                                              TABLE_X_CALL_TRANS.OBJID
  /*               1.3       03/03/11  Kacosta    CR12843 remove format comment
  /*               1.5       04/17/12  YMillan    CR19821 Net10 Activation engine
  /******************************************************************************/
  (
    ip_esn        IN VARCHAR2,
    ip_plan_objid IN NUMBER,
    ip_case_id    IN VARCHAR2,
    op_error_no OUT VARCHAR2,
    op_error_msg OUT VARCHAR2 )
IS
  -- CR11623 BRAND_SEP added table_bus_org to this cursor
  CURSOR part_inst_c
  IS
    SELECT sa.table_part_inst.*,
      org_id
    FROM sa.table_part_inst,
      sa.table_mod_level,
      sa.table_part_num,
      sa.table_bus_org
    WHERE part_serial_no     = ip_esn
    AND x_domain             = 'PHONES'
    AND n_part_inst2part_mod = table_mod_level.objid
    AND part_info2part_num   = table_part_num.objid
    AND part_num2bus_org     = table_bus_org.objid;
  rec_part_inst_c part_inst_c%ROWTYPE;
  CURSOR site_part_c
  IS
    SELECT objid,
      x_min,
      x_service_id
    FROM
      (SELECT objid,
        x_min,
        x_service_id,
        dense_rank() over (partition BY x_service_id order by DECODE(part_status,'Active',1,'CarrierPending',2,'Obsolete',3,4),install_date DESC,objid DESC)x_rank
      FROM sa.table_site_part
      WHERE x_service_id = ip_esn
      AND part_status   IN ('Active','CarrierPending','Obsolete')
      )
  WHERE x_rank=1; -- CR19821 YM   -- CR14033 PM 11/23/2011 with reference to defect # 77
  --------FOR CR31908
  rec_site_part_c site_part_c%ROWTYPE;
  -- CR8470 CWL
  CURSOR days_units_c (ip_plan_objid IN NUMBER)
  IS
    SELECT SUM (NVL (x_access_days, 0)) days,
      SUM (NVL (x_units, 0)) v_units
    FROM table_x_promotion p,
      x_program_parameters pp
    WHERE p.objid IN (pp.x_promo_incl_min_at, pp.x_incl_service_days)
    AND pp.objid   = ip_plan_objid;
  rec_days_units_c days_units_c%ROWTYPE;
  CURSOR promo_c
  IS
    SELECT p.objid
    FROM table_x_promotion p,
      x_program_parameters pp
    WHERE p.objid IN (pp.x_promo_incl_min_at, pp.x_incl_service_days)
    AND pp.objid   = ip_plan_objid;
  promo_r promo_c%ROWTYPE;
  sp_min VARCHAR2 (20);
  CURSOR case_c
  IS
    SELECT * FROM table_case WHERE id_number = ip_case_id;
  case_r case_c%ROWTYPE;
  CURSOR plan_c
  IS
    SELECT * FROM x_program_parameters WHERE objid = ip_plan_objid;
  plan_r plan_c%ROWTYPE;
  v_chgreason VARCHAR2 (100) := 'Plan Enrollment';
  sp_objid    NUMBER;
  pr_objid    NUMBER;
  v_units     NUMBER;
  ct_objid    NUMBER;
  n           NUMBER;
  days        NUMBER;
  new_date    DATE;
BEGIN
  op_error_no  := '0';
  op_error_msg := 'Benefits Appended';
  DELETE sa.table_x_pending_redemption
  WHERE x_case_id          = ip_case_id
  AND pend_redemption2esn IN
    (SELECT objid
    FROM table_part_inst
    WHERE part_serial_no = ip_esn
    AND x_domain         = 'PHONES'
    );
  OPEN part_inst_c;
  FETCH part_inst_c INTO rec_part_inst_c;
  IF part_inst_c%NOTFOUND THEN
    CLOSE part_inst_c;
    op_error_no  := '100';
    op_error_msg := 'Serial Number not found';
    RETURN;
  END IF;
  OPEN case_c;
  FETCH case_c INTO case_r;
  IF case_c%FOUND THEN
    CLOSE case_c;
  ELSE
    CLOSE case_c;
    op_error_no  := '110';
    op_error_msg := 'Case not found';
    RETURN;
  END IF;
  OPEN plan_c;
  FETCH plan_c INTO plan_r;
  IF plan_c%FOUND THEN
    CLOSE plan_c;
  ELSE
    CLOSE plan_c;
    op_error_no  := '120';
    op_error_msg := 'Plan not found';
    RETURN;
  END IF;
  CLOSE part_inst_c;
  OPEN site_part_c;
  FETCH site_part_c INTO rec_site_part_c;
  IF site_part_c%NOTFOUND THEN
    SELECT sa.sequ_site_part.NEXTVAL INTO sp_objid FROM DUAL;
    sp_min := NULL;
    INSERT
    INTO sa.table_site_part
      (
        objid,
        instance_name,
        serial_no,
        s_serial_no,
        install_date,
        part_status,
        service_end_dt,
        x_service_id,
        site_part2part_info
      )
      VALUES
      (
        sp_objid,
        'Wireless',
        rec_part_inst_c.part_serial_no,
        rec_part_inst_c.part_serial_no,
        SYSDATE,
        'Obsolete',
        TO_DATE ('01/01/1753', 'mm/dd/yyyy'),
        rec_part_inst_c.part_serial_no,
        rec_part_inst_c.n_part_inst2part_mod
      );
  ELSE
    sp_objid := rec_site_part_c.objid;
    sp_min   := rec_site_part_c.x_min;
  END IF;
  -- CR8470 CWL
  OPEN days_units_c (ip_plan_objid);
  FETCH days_units_c INTO rec_days_units_c;
  --CLOSE days_units_c ; --CR11503
  IF days_units_c%NOTFOUND THEN
    rec_days_units_c.days    := 0;
    rec_days_units_c.v_units := 0;
  END IF;
  CLOSE days_units_c; --CR11503
  IF rec_part_inst_c.warr_end_date > SYSDATE THEN
    new_date                      := rec_part_inst_c.warr_end_date + rec_days_units_c.days;
  ELSE
    new_date := SYSDATE + rec_days_units_c.days;
  END IF;
  UPDATE sa.table_part_inst
  SET x_part_inst2site_part = sp_objid,
    warr_end_date           = new_date
  WHERE part_serial_no      = ip_esn
  AND x_domain              = 'PHONES';
  -- Start CR12843 kacosta
  SELECT sa.seq('x_call_trans')
  INTO ct_objid
  FROM dual;
  -- End CR12843 kacosta
  -- insert into call Trans
  INSERT
  INTO sa.table_x_call_trans
    (
      objid,
      call_trans2site_part,
      x_action_type,
      x_call_trans2carrier,
      x_call_trans2dealer,
      x_call_trans2user,
      x_min,
      x_service_id,
      x_sourcesystem,
      x_transact_date,
      x_total_units,
      x_action_text,
      x_reason,
      x_result,
      x_sub_sourcesystem
    )
    VALUES
    (
      ct_objid,
      sp_objid,
      '8',
      NULL,
      NULL,
      '268435556',
      sp_min,
      ip_esn,
      'WEBCSR',
      SYSDATE,
      rec_days_units_c.v_units,
      'BPDelivery',
      v_chgreason,
      'Completed',
      rec_part_inst_c.org_id
    );
  -- CR11623 BRAND_SEP populate x_sub_sourcesystem with the brand
  n := 0;
  --SELECT SA.SEQU_X_PENDING_REDEMPTION.NEXTVAL INTO PR_OBJID FROM DUAL ; --CR11503
  FOR promo_r IN promo_c
  LOOP
    SELECT sa.sequ_x_pending_redemption.NEXTVAL INTO pr_objid FROM DUAL; --CR11503
    n := n + 1;
    INSERT
    INTO sa.table_x_pending_redemption
      (
        objid,
        pend_red2x_promotion,
        pend_redemption2esn,
        x_pend_type,
        x_case_id,
        x_granted_from2x_call_trans
      )
      VALUES
      (
        pr_objid,
        promo_r.objid,
        rec_part_inst_c.objid,
        'REPL',
        ip_case_id,
        ct_objid
      );
  END LOOP;
  IF n > 0 THEN -- Promos added
    COMMIT;
  ELSE
    ROLLBACK;
    op_error_no  := '200';
    op_error_msg := 'No Promos added, transaction rolled back';
    RETURN;
  END IF;
END;
/