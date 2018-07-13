CREATE OR REPLACE PROCEDURE sa."SP_SETSOFTPIN_WRAPPER" (i_esn             IN  VARCHAR2,
                                                  i_purch_hdr_objid IN  NUMBER  ,
                                                  i_pin_part_num    IN  VARCHAR2,
                                                  i_inv_bin_objid   IN  NUMBER  ,
                                                  o_soft_pin        OUT VARCHAR2,
                                                  o_smp_number      OUT VARCHAR2,
                                                  o_pin_sp_name     OUT VARCHAR2, -- CR43524 added
                                                  o_pin_sp_id       OUT VARCHAR2, -- CR43524 added
                                                  o_pin_sp_type     OUT VARCHAR2, -- CR43524 added
                                                  o_err_str         OUT VARCHAR2,
                                                  o_err_num         OUT NUMBER
                                                  )
IS
--Local variables declaration
l_return_val           NUMBER;
l_esn_count            NUMBER;
l_ph_objid_cnt         NUMBER;
l_part_num_cnt         NUMBER;
l_sett_purch_hdr_objid NUMBER;
l_inv_bin_objid        NUMBER;
l_merchant_id          VARCHAR2(30);
l_lrp                  VARCHAR2(1)  := 'N';  -- CR41786
l_site_id              VARCHAR2(200);
-- CR43524 changes starts..
l_chg_purch_hdr_objid  NUMBER;
l_ivr_merch_id         VARCHAR2(100);
l_bus_org              table_bus_org.org_id%TYPE;
-- CR43524 changes ends
--
BEGIN --Main Section
--
  --To validate ESN OR Purchase Header OBJID Cannot be NULL.
  IF (i_esn IS NULL OR i_purch_hdr_objid IS NULL) THEN
    o_err_num := -1;
    o_err_str := ('ESN OR Purchase Header OBJID Cannot be NULL');
    RETURN;
  END IF;
  --
  --To check ESN and Purchase Header OBJID exists.
  BEGIN
     SELECT COUNT(*)
     INTO  l_esn_count
     FROM  table_part_inst pi_esn
     WHERE pi_esn.part_serial_no =  i_esn
     AND   pi_esn.x_domain       = 'PHONES';
     --
     SELECT COUNT(*)
     INTO  l_ph_objid_cnt
     FROM  x_biz_purch_hdr ph,
           x_biz_purch_dtl pd
     WHERE ph.x_esn          = i_esn
     AND   ph.objid          = i_purch_hdr_objid
     AND   ph.x_esn          = pd.x_esn
     AND   ph.objid          = pd.biz_purch_dtl2biz_purch_hdr;
  EXCEPTION
     WHEN OTHERS THEN
     o_err_num := -1;
     o_err_str := 'SP_SETSOFTPIN_WRAPPER - ESN and Purchase Header OBJID Validation: '||substr(sqlerrm,1,100);
  END;
  --
  --To validate ESN is valid
  IF l_esn_count = 0 THEN
      o_err_num := '922'                ;
      o_err_str := 'ESN cannot be found';
      RETURN;
  END IF;
  --
  --Purchase Header OBJID Validation
  IF l_ph_objid_cnt = 0 THEN
      o_err_num := '925'                                ;
      o_err_str := 'Purchase Header OBJID doesnt exists';
      RETURN;
  END IF;
  --
    --To retrieve the exists coun for the given input pin part number.
  BEGIN
     SELECT COUNT(*)
     INTO   l_part_num_cnt
     FROM   table_part_num  pn,
            table_mod_level ml
     WHERE  1 = 1
     AND    pn.part_number             = i_pin_part_num
     AND    pn.domain                  = 'REDEMPTION CARDS'
     AND    ml.part_info2part_num      = pn.objid;
  EXCEPTION
       WHEN OTHERS THEN
       o_err_num := -1;
       o_err_str := 'sp_setsoftpin_wrapper : Invalid Pin Part Number'||substr(sqlerrm,1,100);
       Return;
  END;
  --
  --To check whether the input pin part number exists.
  IF l_part_num_cnt = 0 THEN
     o_err_num := '-1'                     ;
     o_err_str := 'Invalid Pin Part Number';
     RETURN;
  END IF;
  --
  IF NVL(i_inv_bin_objid,0) = 0 THEN
    --Retrieve merchant ID for the given x_biz_purch_hdr_objid
    BEGIN
      SELECT x_merchant_id
      INTO   l_merchant_id
      FROM   x_biz_purch_hdr bph
      WHERE  bph.objid = i_purch_hdr_objid;
    EXCEPTION
      WHEN OTHERS THEN
        o_err_num := -1;
        o_err_str := 'sp_setsoftpin_wrapper : Invalid Purch Header OBJID'||substr(sqlerrm,1,100);
        Return;
    END;
    -- Check for LRP
    BEGIN
      SELECT  'Y'
      INTO    l_lrp
      FROM    x_biz_purch_hdr
      WHERE   PURCH_HDR2ALTPYMTSOURCE IN  (SELECT aps.objid
                                           FROM   Table_X_Altpymtsource aps
                                           WHERE  aps.X_Alt_Pymt_Source = 'LOYALTY_PTS')
      AND     objid                   = i_purch_hdr_objid;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        o_err_num := -1;
        o_err_str := 'sp_setsoftpin_wrapper : Invalid Purch Header OBJID'||substr(sqlerrm,1,100);
    END;
    -- CR43524 changes starts..
    -- removed hard coding on merchant id and make it configuratble
    -- Get the Brand
    SELECT  bo.org_id
    INTO    l_bus_org
    FROM    table_part_num  pn,
            table_part_class  pc,
            table_bus_org   bo
    WHERE   pn.part_number          = i_pin_part_num
    AND     pn.PART_NUM2PART_CLASS  = pc.objid
    AND     pn.PART_NUM2BUS_ORG     = bo.objid;
    --
    -- Get merchant ID for IVR based on brand
    BEGIN
      SELECT tp.X_PARAM_VALUE
      INTO   l_ivr_merch_id
      FROM   table_x_parameters tp
      WHERE  tp.X_PARAM_NAME      =   l_bus_org||'IVR_MERCH_ID'
      AND    tp.objid             =  (SELECT MAX(tp1.objid)
                                      FROM  table_x_parameters tp1
                                      WHERE tp1.X_PARAM_NAME =  tp.X_PARAM_NAME);
    EXCEPTION
      WHEN OTHERS THEN
        l_ivr_merch_id  :=  null;
    END;
    --
    IF UPPER(l_merchant_id) = NVL(l_ivr_merch_id,'X') OR l_lrp   = 'Y'
    -- CR43524 changes ends
    --Validation to check only for IVR
    -- CR41786 added condition for LRP
  --  IF UPPER(l_merchant_id) = 'TFNET10B2C' OR l_lrp   = 'Y'
    THEN
    -- CR41786 changes to remove the hard code and make it configurable
      -- Get site id
      BEGIN
        SELECT tp.X_PARAM_VALUE
        INTO   l_site_id
        FROM   table_x_parameters tp
        WHERE  tp.X_PARAM_NAME      = 'TF_INB_CC_SALES'
        AND    tp.objid             =  (SELECT MAX(tp1.objid)
                                        FROM  table_x_parameters tp1
                                        WHERE tp1.X_PARAM_NAME =  tp.X_PARAM_NAME);
      EXCEPTION
          WHEN OTHERS THEN
          o_err_num := -1;
          o_err_str := 'sp_setsoftpin_wrapper : No record exists in Inventory BIN'||substr(sqlerrm,1,100);
          Return;
      END;
      --
      BEGIN
        SELECT inv.objid
        INTO   l_inv_bin_objid
        FROM   table_inv_bin inv
        WHERE  inv.location_name = l_site_id ;
      EXCEPTION
          WHEN OTHERS THEN
          o_err_num := -1;
          o_err_str := 'sp_setsoftpin_wrapper : No record exists in Inventory BIN'||substr(sqlerrm,1,100);
          Return;
      END;
    --
    END IF;
    --
  ELSE
    l_inv_bin_objid := i_inv_bin_objid;

  END IF;
  --
  --getsoftpin procedure call to retrieve the soft pin and SMP.
  l_return_val:= sa.getSoftPin(ip_pin_part_num  => i_pin_part_num  ,
                               ip_inv_bin_objid => l_inv_bin_objid ,
                               op_soft_pin      => o_soft_pin      ,
                               op_smp_number    => o_smp_number    ,
                               op_err_msg       => o_err_str
                               );
  --
  -- CR43524 changes Starts..
  -- Update the PIN status to RESERVED
  UPDATE  table_part_inst
  SET     x_part_inst_status    = '40',  -- RESERVED
          status2x_code_table   = ( SELECT  objid
                                    FROM    table_x_code_table
                                    WHERE   x_code_number = '40'),
          part_to_esn2part_inst = ( SELECT  objid
                                    FROM    table_part_inst
                                    WHERE   part_serial_no  = i_esn
                                    AND     x_domain        = 'PHONES')
  WHERE   x_red_code  =   o_soft_pin
  AND     x_domain    =   'REDEMPTION CARDS';
  -- CR43524 changes ends.
  --To retrieve the settlement purch header objid
  -- CR43524 added IF condition to restrict this only for LRP
  -- added else condition for IVR to get CHARGE transaction
  IF l_lrp  IN( 'Y')
  THEN
    BEGIN
      SELECT ph2.objid
      INTO   l_sett_purch_hdr_objid
      FROM   x_biz_purch_hdr ph1,
            x_biz_purch_hdr ph2
      WHERE  ph1.objid              = i_purch_hdr_objid
      AND    ph1.c_orderid          = ph2.c_orderid
      AND    ph2.x_payment_type     in ('CHARGE', 'SETTLEMENT');       -- CR41473 PMistry 09/13/2016 Added Charge as with LRP2 the settlement is changed to Charge.
    EXCEPTION
      WHEN OTHERS THEN
        o_soft_pin    :=  NULL;
        o_smp_number  :=  NULL;
        o_err_num     := -1;
        o_err_str     := 'Failed while fetching settlement transaction '||substr(sqlerrm,1,100);
        RETURN;
    END;
    --
    --Updating SMP column value in x_biz_purch_dtl table for Settlement.
    UPDATE x_biz_purch_dtl bpd
    SET    bpd.smp                         = o_smp_number
    WHERE  bpd.x_esn                       = i_esn
    AND    bpd.biz_purch_dtl2biz_purch_hdr = l_sett_purch_hdr_objid;
  ELSE
    --
    BEGIN
      SELECT ph1.objid
      INTO   l_chg_purch_hdr_objid
      FROM   x_biz_purch_hdr ph1
      WHERE  ph1.objid              = i_purch_hdr_objid
      AND    ph1.x_payment_type     = 'CHARGE';
    EXCEPTION
      WHEN OTHERS THEN
        o_soft_pin    :=  NULL;
        o_smp_number  :=  NULL;
        o_err_num     := -1;
        o_err_str     := 'Failed while fetching Charge transaction '||substr(sqlerrm,1,100);
        RETURN;
    END;
    --
    --Updating SMP column value in x_biz_purch_dtl table for Settlement.
    UPDATE x_biz_purch_dtl bpd
    SET    bpd.smp                         = o_smp_number
    WHERE  bpd.x_esn                       = i_esn
    AND    bpd.biz_purch_dtl2biz_purch_hdr = l_chg_purch_hdr_objid;
  END IF;
  --
  --Updating SMP column value in x_biz_purch_dtl table for Auth.
  UPDATE x_biz_purch_dtl bpd
  SET    bpd.smp                         = o_smp_number
  WHERE  bpd.x_esn                       = i_esn
  AND    bpd.biz_purch_dtl2biz_purch_hdr = i_purch_hdr_objid;
  --
  -- CR43524 changes starts..
  BEGIN
    SELECT  sp_id,
            sp_name,
            (CASE
              WHEN  a.sp_type = 'MONTHLY PLANS'
              THEN  'MONTHLY'
              WHEN  a.ivr_plan_id  = 999
              THEN  'PAYGO'
              ELSE
                    a.sp_type
              END )           sp_type
    INTO    o_pin_sp_id,
            o_pin_sp_name,
            o_pin_sp_type
    FROM    (
            SELECT  spf.splan_objid   sp_id,
                    spf.sp_mkt_name   sp_name,
                    spf.plan_type     sp_type,
                    sp.ivr_plan_id    ivr_plan_id,
                    spf.plan_purchase_part_number,
                    ROW_NUMBER() OVER(PARTITION BY spf.plan_purchase_part_number ORDER BY sp.objid) AS rn
            FROM    splan_feat_pivot  spf,
                    x_service_plan    sp
            WHERE   spf.plan_purchase_part_number = i_pin_part_num
            AND     spf.splan_objid               = sp.objid
            UNION
            SELECT  sp.objid          sp_id,
                    sp.mkt_name       sp_name,
                    spf.plan_type     sp_type,
                    sp.ivr_plan_id    ivr_plan_id,
                    tpn.part_number,
                    ROW_NUMBER() OVER(PARTITION BY tpn.part_number ORDER BY sp.objid) AS rn
            FROM    table_part_num tpn,
                    adfcrm_serv_plan_class_matview spc,
                    x_service_plan    sp,
                    splan_feat_pivot  spf
            WHERE 1                        =  1
            AND   spc.SP_OBJID             =  spf.splan_objid
            AND   sp.OBJID                 =  spc.SP_OBJID
            AND   tpn.part_num2part_class  =  spc.PART_CLASS_OBJID
            AND   tpn.part_number          =  i_pin_part_num
            UNION
            SELECT VAS_SERVICE_ID   sp_id,
                   'VAS 10$ILD'     sp_name,
                   'VAS 10$ILD'     sp_type,
                   0                ivr_plan_id,
                   VAS_APP_CARD,
                   ROW_NUMBER() OVER(PARTITION BY VAS_APP_CARD ORDER BY VAS_SERVICE_ID) AS rn
            FROM  vas_programs_view,
                  table_part_num    pn,
                  table_part_class  pc
            WHERE pn.PART_NUM2PART_CLASS  = pc.objid
            AND   pn.part_number          = i_pin_part_num
            AND   vas_type                = 'STANDALONE'
            AND   VAS_CARD_CLASS          =  pc.name
            AND   ROWNUM < 2
            ) a
    WHERE   a.rn =1;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  -- CR43524 changes ends
  o_err_num       :=  0        ;
  o_err_str       :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
  o_err_num := -1;
  o_err_str := 'sp_setsoftpin_wrapper:  '||substr(sqlerrm,1,100);
  util_pkg.insert_error_tab (i_action       => 'sp_setsoftpin_wrapper',
                            i_key          => i_esn                  ,
                            i_program_name => 'sp_setsoftpin_wrapper',
                            i_error_text   => o_err_str
                            );
END sp_setsoftpin_wrapper;
/