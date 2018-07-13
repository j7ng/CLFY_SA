CREATE OR REPLACE PROCEDURE sa."GET_SERVICE_FORECAST_DET" (
    ip_esn                        IN      VARCHAR2,
    op_part_num_det               IN OUT  part_num_det_tab,
    op_forecast_action            OUT     VARCHAR2,
    op_forecast_ttl               OUT     DATE,        -- ServiceEndDueDate
    op_forecast_future_ttl        OUT     DATE, -- ServiceEndForecastedDate
    op_forecast_enroll_status     OUT     VARCHAR2,
    op_forecast_next_charge_date  OUT     DATE,
    op_forecast_code              OUT     NUMBER,
    op_forecast_msg               OUT     VARCHAR2)
  /*******************************************************************************************************
  --$RCSfile: get_service_forecast_det.sql,v $
  --$Revision: 1.18 $
  --$Author: mdave $
  --$Date: 2018/02/26 23:24:26 $
  --$ $Log: get_service_forecast_det.sql,v $
  --$ Revision 1.18  2018/02/26 23:24:26  mdave
  --$ CR55545 changes
  --$
  --$ Revision 1.15  2016/11/08 21:01:34  smeganathan
  --$ CR46373 existing AR should be deenrolled for paygo to unl for NOW
  --$
  --$ Revision 1.14  2016/11/07 16:23:33  smeganathan
  --$ CR46373 existing AR should be deenrolled for unl to paygo for NOW
  --$
  --$ Revision 1.13  2016/10/31 15:45:35  smeganathan
  --$ ILD fix
  --$
  --$ Revision 1.12  2016/10/24 19:13:30  smeganathan
  --$ CR43524 code fix for paygo- paygo
  --$
  --$ Revision 1.11  2016/10/21 18:26:36  smeganathan
  --$ CR43524 Defect fixes for next charge date
  --$
  --$ Revision 1.10  2016/10/11 20:04:08  sraman
  --$ CR43524 -Bug Fix for TF brand Airtime part numbers
  --$
  --$ Revision 1.9  2016/10/07 18:33:01  sraman
  --$ CR43524 -Bug Fix for past due ESNs with future servie end date but Inactive
  --$
  --$ Revision 1.8  2016/10/05 17:40:40  sraman
  --$ CR43524 -Bug Fix for past due ESNs
  --$
  --$ Revision 1.7  2016/10/05 16:55:45  sraman
  --$ CR43524 -Bug Fix for past due ESNs
  --$
  --$ Revision 1.6  2016/09/27 17:00:44  sraman
  --$ CR43524 -Bug Fix
  --$
  --$ Revision 1.5  2016/09/13 13:31:55  sraman
  --$ CR43524 - Unit testing error fix
  --$
  --$ Revision 1.4  2016/09/12 21:11:18  sraman
  --$ CR43524 - Unit testing error fix
  --$
  --$ Revision 1.2  2016/08/23 16:19:15  smeganathan
  --$ Code fixes for ttl days
  --$
  --$ Revision 1.1  2016/08/02 20:54:04  smeganathan
  --$ New proc to get service forecast details for IVR
  --$
  --$ Revision 1.1 2016/07/26 18:42:58  SMEGANATHAN
  --$ New procedure created for IVR Tracfone - CR43524
  --$
  * Description: This procedure get the forecast details of service
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
IS
  --
  CURSOR c_part_num_det (c_part_num VARCHAR2)
  IS
    SELECT sp_id,
      sp_name,
      (
      CASE
        WHEN a.sp_type = 'MONTHLY PLANS'
        THEN 'MONTHLY'
        WHEN a.sp_type = 'PAYGO'
        THEN 'PAYGO'
        WHEN a.ivr_plan_id = 999
        THEN 'PAYGO'
        ELSE a.sp_type
      END ) sp_type,
      service_days
    FROM
      (SELECT spf.splan_objid sp_id,
        spf.sp_mkt_name sp_name,
        spf.plan_type sp_type,
        sp.ivr_plan_id ivr_plan_id,
        spf.plan_purchase_part_number,
        TRIM(REPLACE(NVL(UPPER(spf.service_days),0),'DAYS') ) service_days,
        ROW_NUMBER() OVER(PARTITION BY spf.plan_purchase_part_number ORDER BY sp.objid) AS rn
      FROM splan_feat_pivot spf,
        x_service_plan sp
      WHERE spf.plan_purchase_part_number = c_part_num
      AND spf.splan_objid                 = sp.objid
    UNION
    SELECT sp.objid sp_id,
      sp.mkt_name sp_name,
      spf.plan_type sp_type,
      sp.ivr_plan_id ivr_plan_id,
      tpn.part_number,
      TRIM(REPLACE(NVL(UPPER(spf.service_days),0),'DAYS') ) service_days,
      ROW_NUMBER() OVER(PARTITION BY tpn.part_number ORDER BY sp.objid) AS rn
    FROM table_part_num tpn,
      adfcrm_serv_plan_class_matview spc,
      x_service_plan sp,
      splan_feat_pivot spf
    WHERE 1                     = 1
    AND spc.SP_OBJID            = spf.splan_objid
    AND sp.OBJID                = spc.SP_OBJID
    AND tpn.part_num2part_class = spc.PART_CLASS_OBJID
    AND tpn.part_number         = c_part_num
      ) a
    WHERE a.rn =1;
    c_part_num_det_rec c_part_num_det%ROWTYPE;

 CURSOR c_part_num_det_TF (c_part_num VARCHAR2)
  IS
   SELECT 252 AS sp_id,
      'TracFone Paygo for Android' sp_name,
      'PAYGO' AS sp_type,
      X_REDEEM_DAYS service_days,
      CASE
        WHEN b.VAS_SERVICE_ID IS NOT NULL
        THEN 'Y'
        ELSE 'N'
      END AS VAS_flag
    FROM table_part_num a
    LEFT OUTER JOIN VAS_PROGRAMS_VIEW b
    ON (a.part_number  =b.VAS_APP_CARD)
    WHERE part_number IN (c_part_num)
    AND domain         = 'REDEMPTION CARDS';

c_part_num_det_rec_tf c_part_num_det_tf%ROWTYPE;

    CURSOR c_vas_ild (c_part_num VARCHAR2)
    IS
      SELECT VAS_APP_CARD FROM VAS_PROGRAMS_VIEW WHERE VAS_APP_CARD=c_part_num;
    c_vas_ild_rec c_vas_ild%ROWTYPE;
    --
    CURSOR c_prog_enrl_det
    IS
      SELECT ee.pgm_enroll2web_user,
        x_program_name,
        pp.x_prog_class,
        ee.x_esn,
        ee.x_enrollment_status,
        ee.x_next_charge_date
      FROM x_program_parameters pp,
        x_program_enrolled ee
      WHERE ee.pgm_enroll2pgm_parameter = pp.objid
      AND ee.x_enrollment_status        = 'ENROLLED'
      AND (pp.x_prog_class IS NULL OR pp.x_prog_class = 'SWITCHBASE')
      AND ee.x_next_charge_date        IS NOT NULL
      AND ee.x_esn                      = ip_esn ;
    c_prog_enrl_det_rec c_prog_enrl_det%ROWTYPE;
    --
    CURSOR c_site_part
    IS
    SELECT tsp.*
    FROM table_site_part tsp
    WHERE x_service_id = ip_esn
    AND tsp.objid      = DECODE( (SELECT COUNT(1) FROM table_site_part sp_cnt WHERE sp_cnt.x_service_id = ip_esn AND sp_cnt.part_status= 'Active'),
                                 1,
                                 (SELECT sp1.objid
                                  FROM table_site_part sp1
                                  WHERE sp1.x_service_id = ip_esn
                                  AND sp1.part_status    = 'Active'
                                 ),
                                 (SELECT MAX(sp_max.objid)
                                 FROM table_site_part sp_max
                                 WHERE sp_max.x_service_id = ip_esn
                                 AND sp_max.part_status   <> 'Obsolete'
                                 )
                              );

    c_site_part_rec c_site_part%ROWTYPE;
    --
    CURSOR c_q_service_days (i_esn_objid table_part_inst.objid%TYPE)
    IS
      SELECT *
      FROM
        (SELECT pi.x_red_code,
          pn.part_number,
          TRIM(regexp_replace(NVL(spf.service_days,0),'[[:alpha:]]','') ) service_day,
          ROW_NUMBER() OVER(PARTITION BY pi.x_red_code ORDER BY spf.SPLAN_OBJID) AS rn
        FROM table_part_inst pi,
          table_mod_level ml,
          table_part_num pn,
          splan_feat_pivot spf
        WHERE spf.plan_purchase_part_number = pn.part_number
        AND ml.PART_INFO2PART_NUM           = pn.objid
        AND pi.n_part_inst2part_mod         = ml.objid
        AND pi.X_PART_INST_STATUS           = '400'
        AND pi.x_domain                     = 'REDEMPTION CARDS'
        AND pi.PART_TO_ESN2PART_INST        = i_esn_objid
      UNION
      SELECT pi.x_red_code,
        pn.part_number,
        TRIM(regexp_replace(NVL(spf.service_days,0),'[[:alpha:]]','') ) service_day,
        ROW_NUMBER() OVER(PARTITION BY pi.x_red_code ORDER BY spf.SPLAN_OBJID) AS rn
      FROM adfcrm_serv_plan_class_matview spc,
        splan_feat_pivot spf,
        table_part_inst pi,
        table_mod_level ml,
        table_part_num pn
      WHERE spc.SP_OBJID           = spf.splan_objid
      AND pn.part_num2part_class   = spc.PART_CLASS_OBJID
      AND ml.PART_INFO2PART_NUM    = pn.objid
      AND pi.n_part_inst2part_mod  = ml.objid
      AND pi.X_PART_INST_STATUS    = '400'
      AND pi.x_domain              = 'REDEMPTION CARDS'
      AND pi.PART_TO_ESN2PART_INST = i_esn_objid
        ) a
      WHERE a.rn = 1;
      --
      l_service_days        NUMBER;
      l_queued_service_days NUMBER := 0;
      l_part_inst_rec table_part_inst%ROWTYPE;
      l_apply_now        VARCHAR2(1) := 'N';
      l_apply_later      VARCHAR2(1) := 'N';
      l_autorefill       VARCHAR2(1) := 'N';
      l_now_autorefill   VARCHAR2(1) := 'N';
      l_later_autorefill VARCHAR2(1) := 'N';
      l_curr_sp_id x_service_plan.objid%TYPE;
      l_curr_sp_type      VARCHAR2(50);
      l_forecast_sp_type  VARCHAR2(50);
      l_dest_sp_type      VARCHAR2(50);
      l_x_expire_dt       DATE;
      l_enrollment_status VARCHAR2(50);
      l_next_charge_date  DATE;
      l_fulfillment_type  VARCHAR2(50);
      --
      FUNCTION get_service_plan_type(
          in_sp_id IN VARCHAR2)
        RETURN VARCHAR2
      AS
        --
        l_sp_type VARCHAR2(50);
        --
      BEGIN
        SELECT (
          CASE
            WHEN spf.plan_type = 'MONTHLY PLANS'
            THEN 'MONTHLY'
            WHEN sp.ivr_plan_id = 999
            THEN 'PAYGO'
            ELSE spf.plan_type
          END )
        INTO l_sp_type
        FROM splan_feat_pivot spf,
          x_service_plan sp
        WHERE sp.OBJID      = spf.splan_objid
        AND spf.splan_objid = in_sp_id;
        --
        RETURN l_sp_type;
      EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
      END;
    --
    BEGIN
      --
      -- Input Validation
      BEGIN
        SELECT pi.*
        INTO l_part_inst_rec
        FROM table_part_inst pi
        WHERE pi.part_serial_no = ip_esn
        AND pi.x_domain         = 'PHONES';
      EXCEPTION
      WHEN OTHERS THEN
        op_forecast_code := 100;
        op_forecast_msg  := 'ESN does not exists';
        RETURN;
      END;
      --
      IF op_part_num_det.Count = 0 OR op_part_num_det IS NULL THEN
        op_forecast_code      := 101;
        op_forecast_msg       := 'Part num details list has no input value';
        RETURN;
      END IF;
      -- Get current service plan id details
      l_curr_sp_id := util_pkg.get_service_plan_id ( i_esn => ip_esn);
      --
      IF l_curr_sp_id IS NULL AND
         sa.bau_util_pkg.get_esn_brand(ip_esn) = 'TRACFONE'
      THEN
        l_curr_sp_id  :=  252;
      END IF;
      -- Get current service plan type
      l_curr_sp_type := NVL(get_service_plan_type(in_sp_id => l_curr_sp_id), 'PAYGO');
      --
      dbms_output.put_line('l_curr_sp_id : '||l_curr_sp_id);

      -- Update op_part_num_det variables
      FOR i IN op_part_num_det.FIRST .. op_part_num_det.LAST
      LOOP
        dbms_output.put_line('ip_airtime_partnum : '||op_part_num_det(i).ip_airtime_partnum);
        dbms_output.put_line('ip_fulfillment_type : '||op_part_num_det(i).ip_fulfillment_type);

        IF sa.bau_util_pkg.get_esn_brand(ip_esn) = 'TRACFONE' THEN
              dbms_output.put_line('Brand: Tracfone');
              OPEN c_part_num_det_tf (op_part_num_det(i).ip_airtime_partnum);
              FETCH c_part_num_det_tf INTO c_part_num_det_rec_tf;
              IF c_part_num_det_tf%FOUND THEN
                op_part_num_det(i).op_partnum_service_days := c_part_num_det_rec_tf.service_days;
                op_part_num_det(i).op_service_plan_id      := c_part_num_det_rec_tf.sp_id;
                op_part_num_det(i).op_plan_name            := c_part_num_det_rec_tf.sp_name;
                dbms_output.put_line('service_days : '||c_part_num_det_rec_tf.service_days);
                dbms_output.put_line('sp_id        : '||c_part_num_det_rec_tf.sp_id);
                dbms_output.put_line('sp_name      : '||c_part_num_det_rec_tf.sp_name);
                l_dest_sp_type           := c_part_num_det_rec_tf.sp_type;
                l_fulfillment_type       := op_part_num_det(i).ip_fulfillment_type;
                IF c_part_num_det_rec_tf.VAS_flag='Y' THEN
                   l_dest_sp_type     := 'ILD';
                   l_fulfillment_type := 'ILD';
                END IF;
              END IF;

              CLOSE c_part_num_det_tf;

        ELSE --Other than Tracfone
              dbms_output.put_line('Brand: Otherthan Tracfone');
              OPEN c_part_num_det (op_part_num_det(i).ip_airtime_partnum);
              FETCH c_part_num_det INTO c_part_num_det_rec;
              IF c_part_num_det%FOUND THEN
                op_part_num_det(i).op_partnum_service_days := c_part_num_det_rec.service_days;
                op_part_num_det(i).op_service_plan_id      := c_part_num_det_rec.sp_id;
                op_part_num_det(i).op_plan_name            := c_part_num_det_rec.sp_name;
                dbms_output.put_line('service_days : '||c_part_num_det_rec.service_days);
                dbms_output.put_line('sp_id        : '||c_part_num_det_rec.sp_id);
                dbms_output.put_line('sp_name      : '||c_part_num_det_rec.sp_name);
                IF NVL(l_dest_sp_type,'X') <> 'MONTHLY' THEN
                  l_dest_sp_type           := c_part_num_det_rec.sp_type;
                END IF;
                IF l_fulfillment_type IS NULL THEN
                  l_fulfillment_type  := op_part_num_det(i).ip_fulfillment_type;
                END IF;
              ELSE
                OPEN c_vas_ild (op_part_num_det(i).ip_airtime_partnum);
                FETCH c_vas_ild INTO c_vas_ild_rec;
                IF c_vas_ild%FOUND THEN
                  l_dest_sp_type     := 'ILD';
                  l_fulfillment_type := NVL(l_fulfillment_type,'ILD');
                END IF;
                CLOSE c_vas_ild;
              END IF;
              CLOSE c_part_num_det;
        END IF;
      END LOOP;
      --

      IF l_part_inst_rec.X_PART_INST_STATUS = '52' THEN
        op_forecast_action                 := '1';
      ELSE
        op_forecast_action := '2';
      END IF;
      --
      OPEN c_site_part;
      FETCH c_site_part INTO c_site_part_rec;
      IF c_site_part%FOUND THEN
        --  This is service end date
        l_x_expire_dt := c_site_part_rec.x_expire_dt;
      END IF;
      CLOSE c_site_part;

      IF l_x_expire_dt < TRUNC(SYSDATE) OR l_x_expire_dt IS NULL THEN
         l_x_expire_dt := TRUNC(SYSDATE);
      END IF;
      dbms_output.put_line('l_x_expire_dt : '||l_x_expire_dt);

      -- Get the no of service days from queued cards
      l_queued_service_days := NVL(sa.util_pkg.get_queued_days (ip_esn),0);
      dbms_output.put_line('l_queued_service_days : '||l_queued_service_days);
      -- Get program enrollment details
      OPEN c_prog_enrl_det;
      FETCH c_prog_enrl_det INTO c_prog_enrl_det_rec;
      IF c_prog_enrl_det%FOUND THEN
        l_enrollment_status := c_prog_enrl_det_rec.x_enrollment_status;
        l_next_charge_date  := c_prog_enrl_det_rec.x_next_charge_date;
        dbms_output.put_line('l_enrollment_status : '||l_enrollment_status);
        dbms_output.put_line('l_next_charge_date : '||l_next_charge_date);
      END IF;
      CLOSE c_prog_enrl_det;

      FOR i IN op_part_num_det.FIRST .. op_part_num_det.LAST
      LOOP
        dbms_output.put_line('l_dest_sp_type : '||l_dest_sp_type);
        dbms_output.put_line('l_curr_sp_type : '||l_curr_sp_type);

        IF l_fulfillment_type IN ('LATER','LATER_AUTOREFILL' ) THEN

          --Paygo to UNL begin
          IF l_curr_sp_type                 ='PAYGO' AND l_dest_sp_type='MONTHLY' THEN
            op_forecast_ttl                := l_x_expire_dt;
            op_forecast_future_ttl         := NVL(op_forecast_future_ttl,(l_x_expire_dt + l_queued_service_days) ) + op_part_num_det(i).op_partnum_service_days;
            IF NVL(l_enrollment_status,'X') = 'ENROLLED' OR l_fulfillment_type = 'LATER_AUTOREFILL' THEN
              op_forecast_enroll_status    := 'ENROLLED';
              op_forecast_next_charge_date :=
              CASE
              WHEN l_fulfillment_type ='LATER_AUTOREFILL' THEN
                l_x_expire_dt
              WHEN l_fulfillment_type ='LATER' THEN
                l_next_charge_date
              END ;
            ELSE
              op_forecast_enroll_status    := 'NOT_ENROLLED';
              op_forecast_next_charge_date := NULL;
            END IF;
          END IF; --Paygo to UNL ends

          --UNL to UNL begin
          IF l_curr_sp_type='MONTHLY' AND l_dest_sp_type='MONTHLY' THEN

            op_forecast_ttl                := l_x_expire_dt;
            op_forecast_future_ttl         := NVL(op_forecast_future_ttl,(l_x_expire_dt + l_queued_service_days) ) + op_part_num_det(i).op_partnum_service_days;
            IF NVL(l_enrollment_status,'X') = 'ENROLLED' OR l_fulfillment_type = 'LATER_AUTOREFILL'
              --and  l_curr_sp_id = op_part_num_det(i).op_service_plan_id
              THEN
              op_forecast_enroll_status    := 'ENROLLED';
              op_forecast_next_charge_date :=
              CASE
              WHEN l_fulfillment_type ='LATER_AUTOREFILL' THEN
                l_x_expire_dt
              WHEN l_fulfillment_type ='LATER' THEN
                l_next_charge_date
              END ;
            ELSE
              op_forecast_enroll_status    := 'NOT_ENROLLED';
              op_forecast_next_charge_date := NULL;
            END IF;
          END IF; --UNL to UNL ends

        ELSIF l_fulfillment_type IN ('NOW','NOW_AUTOREFILL' ) THEN

          --Paygo to UNL begin
          IF l_curr_sp_type                 = 'PAYGO' AND l_dest_sp_type = 'MONTHLY' THEN
            op_forecast_ttl                := NVL (op_forecast_ttl,TRUNC(SYSDATE) )      + op_part_num_det(i).op_partnum_service_days;
            op_forecast_future_ttl         := NVL(op_forecast_future_ttl,(TRUNC(sysdate) + l_queued_service_days) ) + op_part_num_det(i).op_partnum_service_days ;
             -- CR46373 Paygo to Unlimited, existing Paygo Autorefil should be deenrolled as per business
            IF l_fulfillment_type = 'NOW_AUTOREFILL' THEN
              op_forecast_enroll_status    := 'ENROLLED';
              op_forecast_next_charge_date := TRUNC(SYSDATE) + op_part_num_det(i).op_partnum_service_days;
            ELSE
              op_forecast_enroll_status    := 'NOT_ENROLLED';
              op_forecast_next_charge_date := NULL;
            END IF;
          END IF; -- --Paygo to UNL end

          --UNL to UNL begin
          IF l_curr_sp_type = 'MONTHLY' AND l_dest_sp_type = 'MONTHLY' THEN

            op_forecast_ttl                  := NVL (op_forecast_ttl,TRUNC(SYSDATE) )      + op_part_num_det(i).op_partnum_service_days;
            op_forecast_future_ttl           := NVL(op_forecast_future_ttl,(TRUNC(sysdate) + l_queued_service_days) ) + op_part_num_det(i).op_partnum_service_days ;
            IF  l_fulfillment_type='NOW' AND  NVL(l_enrollment_status,'X') = 'ENROLLED'  AND l_curr_sp_id = op_part_num_det(i).op_service_plan_id THEN
              op_forecast_enroll_status      := 'ENROLLED';
              op_forecast_next_charge_date   := TRUNC(SYSDATE) + op_part_num_det(i).op_partnum_service_days;
            ELSE
              op_forecast_enroll_status    := 'NOT_ENROLLED';
              op_forecast_next_charge_date := NULL;
            END IF;

            IF ( l_fulfillment_type='NOW_AUTOREFILL') THEN
              op_forecast_enroll_status      := 'ENROLLED';
              op_forecast_next_charge_date   := TRUNC(SYSDATE) + op_part_num_det(i).op_partnum_service_days;
            END IF;

          END IF; --UNL to UNL end

          --UNL to Paygo begin
          IF l_curr_sp_type = 'MONTHLY' AND l_dest_sp_type = 'PAYGO' THEN

            op_forecast_ttl                  := NVL (op_forecast_ttl,TRUNC(SYSDATE) )      + op_part_num_det(i).op_partnum_service_days;
            op_forecast_future_ttl           := NVL(op_forecast_future_ttl,(TRUNC(sysdate) + l_queued_service_days) ) + op_part_num_det(i).op_partnum_service_days ;
            --
            -- CR46373 Unlimited to Paygo, existing UNL Autorefil should be deenrolled as per business
            IF  l_fulfillment_type  = 'NOW'
            THEN
              op_forecast_enroll_status    := 'NOT_ENROLLED';
              op_forecast_next_charge_date := NULL;
            END IF;
            --
            IF ( l_fulfillment_type='NOW_AUTOREFILL') THEN
              op_forecast_enroll_status      := 'ENROLLED';
              op_forecast_next_charge_date   := TRUNC(SYSDATE) + op_part_num_det(i).op_partnum_service_days;
            END IF;

          END IF; --UNL to Paygo end

          --Paygo to Paygo begin
          IF l_curr_sp_type = 'PAYGO' AND l_dest_sp_type = 'PAYGO' THEN

            dbms_output.put_line('op_forecast_ttl         : '||op_forecast_ttl);
            dbms_output.put_line('op_forecast_future_ttl  : '||op_forecast_future_ttl);
            dbms_output.put_line('l_x_expire_dt           : '||l_x_expire_dt);
            dbms_output.put_line('op_part_num_det(i).op_partnum_service_days           : '||op_part_num_det(i).op_partnum_service_days);

            op_forecast_ttl                  := NVL (op_forecast_ttl, l_x_expire_dt)      + op_part_num_det(i).op_partnum_service_days;
            op_forecast_future_ttl           := NVL(op_forecast_future_ttl,l_x_expire_dt) + op_part_num_det(i).op_partnum_service_days;

            IF  l_fulfillment_type='NOW'                   AND
                NVL(l_enrollment_status,'X') = 'ENROLLED'  AND
                l_curr_sp_id = op_part_num_det(i).op_service_plan_id
            THEN
              --
              op_forecast_enroll_status      := 'ENROLLED';
              --
              IF sa.bau_util_pkg.get_esn_brand(ip_esn) = 'TRACFONE'
              THEN
                op_forecast_next_charge_date   := l_next_charge_date;
              ELSE
                op_forecast_next_charge_date   := l_x_expire_dt + op_part_num_det(i).op_partnum_service_days;
              END IF;
              --
            ELSE
              op_forecast_enroll_status    := 'NOT_ENROLLED';
              op_forecast_next_charge_date := NULL;
            END IF;
            --
            IF ( l_fulfillment_type='NOW_AUTOREFILL')
            THEN
              op_forecast_enroll_status      := 'ENROLLED';
              IF sa.bau_util_pkg.get_esn_brand(ip_esn) IN ('TRACFONE', 'NET10')
              THEN
                op_forecast_next_charge_date   := TRUNC(SYSDATE) + op_part_num_det(i).op_partnum_service_days;
              ELSE
                op_forecast_next_charge_date   := l_x_expire_dt + op_part_num_det(i).op_partnum_service_days;
              END IF;
            END IF;

          END IF; --Paygo to Paygo end

		  -- CR55545 IVR NET10 $10 Data add on. Added condition to handle destination plan as DATA PLANS, mdave, 02/26/2018
		IF  l_dest_sp_type   = 'DATA PLANS' AND sa.bau_util_pkg.get_esn_brand(ip_esn) IN ('NET10') THEN
          op_forecast_ttl                := l_x_expire_dt;
          op_forecast_future_ttl         := NVL(op_forecast_future_ttl,(l_x_expire_dt + l_queued_service_days) );
          IF NVL(l_enrollment_status,'X') = 'ENROLLED' THEN
            op_forecast_enroll_status    := 'ENROLLED';
            op_forecast_next_charge_date := l_next_charge_date;
          ELSE
            op_forecast_enroll_status    := 'NOT_ENROLLED';
            op_forecast_next_charge_date := NULL;
          END IF;
        END IF;

	ELSIF  l_dest_sp_type                 = 'ILD' THEN
	  op_forecast_ttl                := l_x_expire_dt;
	  op_forecast_future_ttl         := NVL(op_forecast_future_ttl,(l_x_expire_dt + l_queued_service_days) );
	  IF NVL(l_enrollment_status,'X') = 'ENROLLED' THEN
		op_forecast_enroll_status    := 'ENROLLED';
		op_forecast_next_charge_date := l_next_charge_date;
	  ELSE
		op_forecast_enroll_status    := 'NOT_ENROLLED';
		op_forecast_next_charge_date := NULL;
	  END IF;
	END IF;
   END LOOP;
      --
      op_forecast_code := 0;
      op_forecast_msg  := 'SUCCESS';
      --
    EXCEPTION
    WHEN OTHERS THEN
      op_forecast_code := 99;
      op_forecast_msg  := 'Failed in when others' || SUBSTR(SQLERRM, 1,200);
    END get_service_forecast_det;
/