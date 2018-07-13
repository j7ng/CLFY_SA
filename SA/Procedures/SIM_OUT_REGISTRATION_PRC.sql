CREATE OR REPLACE PROCEDURE sa."SIM_OUT_REGISTRATION_PRC" (
    i_client_trans_id IN      VARCHAR2,
    i_client_id       IN      VARCHAR2,
    i_esn             IN      VARCHAR2,
    i_sim             IN      VARCHAR2,
    i_brand           IN      VARCHAR2,
    i_source_system   IN      VARCHAR2,
    i_store_id        IN      VARCHAR2,
    i_terminal_id     IN      VARCHAR2,
    i_phone_make      IN      VARCHAR2,
    i_phone_model     IN      VARCHAR2,
    i_retry_flag      IN      VARCHAR2,
    io_vd_trans_id    IN OUT  VARCHAR2,
    o_result_code     OUT     VARCHAR2,
    o_result_msg      OUT     VARCHAR2)
AS
--
/**********************************************************************************************/
/* */
/* Name : sim_out_registration_prc */
/* */
/* Purpose : Registers the ESN New Status for Retailer Phone */
/* Initiates VD as applicable and inserts call trans. */
--
/* VERSION DATE WHO PURPOSE */
/* ------- ---------- ----- -------------------------------------------- */
/* 1.0 Initial Revision */
/**********************************************************************************************/
--
  CURSOR sim_inv_cur
  IS
  SELECT pn.part_number
  FROM   sa.table_x_sim_inv si,
         sa.table_mod_level ml,
         sa.table_part_num pn
  WHERE  si.x_sim_serial_no     = i_sim
  AND    si.x_sim_inv_status    = '253'--SIM NEW
  AND    si.X_SIM_INV2PART_MOD  = ml.objid
  AND    ml.part_info2part_num  = pn.objid;
  --
  sim_inv_rec sim_inv_cur%rowtype;
  --
  CURSOR conf_cur (v_vendor_model VARCHAR2,v_sim_profile VARCHAR2)
  IS
  SELECT conf.sourcesystem,
         conf.org_id,
         conf.sim_profile,
         conf.vendor_model,
         conf.dealer_id,
         conf.phone_part_num,
         conf.esninputformat,
         conf.esnsize,
         conf.luhn_validation,
         conf.hexconversion,
         conf.vd_reqd,
         ml.objid mod_level_objid,
         pc.name  part_class_name
  FROM   sa.SIMOUTCONFRULES   conf,
         sa.table_mod_level   ml,
         sa.table_part_num    pn,
         sa.table_part_class  pc
  WHERE conf.SOURCESYSTEM         = i_source_system
  AND   conf.ORG_ID               = i_brand
  AND   conf.sim_profile          = v_sim_profile
  AND   conf.vendor_model         = v_vendor_model
  AND   conf.phone_part_num       = pn.part_number
  AND   ml.part_info2part_num     = pn.objid
  AND   pn.part_num2part_class    = pc.objid;
  --
  conf_rec conf_cur%rowtype;
  --
  CURSOR dealer_cur (v_dealer_id VARCHAR2)
  IS
  SELECT objid
  FROM sa.table_inv_bin
  WHERE location_name = v_dealer_id;
  --
  dealer_rec dealer_cur%rowtype;
  --
  CURSOR esn_cur(v_esn VARCHAR2)
  IS
  SELECT * --x_part_inst_status, x_iccid
  FROM   table_part_inst
  WHERE  part_serial_no   = v_esn
  AND    x_domain         = 'PHONES';
  --
  esn_rec         esn_cur%rowtype;
  --
  CURSOR c_sim_status
  IS
  SELECT /*+ USE_INVISIBLE_INDEXES */
         x_sim_serial_no,
         x_sim_inv_status
  FROM   table_x_sim_inv sim
  WHERE  sim.x_sim_serial_no   = i_sim;
  --
  sim_status_rec         c_sim_status%rowtype;
  --
  CURSOR c_brand_chk
  IS
  SELECT conf.org_id
  FROM   sa.SIMOUTCONFRULES conf
  WHERE conf.SOURCESYSTEM     = i_source_system
  AND   conf.ORG_ID           = i_brand;
  --
  brand_rec c_brand_chk%rowtype;
  --
  CURSOR c_model_chk
  IS
  SELECT conf.vendor_model
  FROM   sa.SIMOUTCONFRULES conf
  WHERE  conf.SOURCESYSTEM     = i_source_system
  AND    conf.vendor_model     = i_phone_model;
  --
  model_rec     c_model_chk%rowtype;
  --
  CURSOR c_pcpv  (v_part_class VARCHAR2)
  IS
  SELECT *
  FROM   sa.pcpv v
  WHERE  part_class     =  v_part_class;
  --
  pcpv_rec      c_pcpv%rowtype;
  --
  CURSOR c_last_ig(c_template IN VARCHAR2)
  IS
  SELECT
          /*+ USE_INVISIBLE_INDEXES */
          ig.status,
          ig.x_pool_name,
          ig.transaction_id
  FROM    gw1.ig_transaction ig
  WHERE   ig.esn              = i_esn
  AND     ig.order_type       = 'VD'
  AND     ig.TEMPLATE         = c_template
  AND     ig.transaction_id   = (CASE
                                 WHEN  io_vd_trans_id IS NULL OR io_vd_trans_id <= 0
                                 THEN ig.transaction_id
                                 ELSE TO_NUMBER(TRIM(io_vd_trans_id))
                                 END)
  ORDER BY ig.transaction_id DESC;
  --
  last_ig_rec   c_last_ig%rowtype;
  --
  CURSOR c_remove_esn_frm_acc (v_esn VARCHAR2)
  IS
  SELECT *
  FROM   sa.table_part_inst
  WHERE  part_serial_no     <> v_esn
  AND    x_iccid            = i_sim
  AND    x_part_inst_status = '50'
  AND    x_domain           = 'PHONES';
  --
  v_esn                   VARCHAR2(30);
  v_hex                   VARCHAR2(30);
  v_esn_loaded            NUMBER  :=  0;
  v_luhn                  VARCHAR2(10);
  v_pi_Return             BOOLEAN;
  l_ig_status             VARCHAR2(100);
  l_vd_reqd               VARCHAR2(1);
  l_insert_call_trans     NUMBER  :=  0;
  l_calltranobj           table_x_call_trans.objid%TYPE;
  l_trans_id              gw1.ig_transaction.transaction_id%TYPE;
  l_error_txt             error_table.error_text%TYPE;
  l_action                error_table.action%TYPE;
  l_web_user_objid        table_web_user.objid%TYPE;
  l_error_code            VARCHAR2(20);
  l_error_msg             VARCHAR2(1000);
  --
BEGIN
  --
  -- Logging the params received
  l_action      :=  'SIM OUT LOGGING the PARAMS -- ESN: '|| i_esn||' SIM: ' || i_sim  || ' BRAND: '|| i_brand || ' SOURCE: '|| i_source_system;
  l_action      :=  l_action ||' MAKE: '|| i_phone_make || ' MODEL: '|| i_phone_model || ' VD Trans ID IN PARAM: '|| io_vd_trans_id;
  util_pkg.insert_error_tab (l_action, i_esn, 'sim_out_registration_prc','Info' );
  --
  OPEN esn_cur(i_esn);
  FETCH esn_cur INTO esn_rec;
  IF esn_cur%found AND esn_rec.x_part_inst_status = '52' THEN
    CLOSE esn_cur;
    o_result_code:= '140';
    o_result_msg :='ERROR: Phone Already Active';
    RETURN;
  ELSIF esn_cur%found AND esn_rec.x_part_inst_status NOT IN ('52','50') THEN
    CLOSE esn_cur;
    o_result_code:= '150';
    o_result_msg :='ERROR: Phone Invalid Status';
    RETURN;
  ELSE
    CLOSE esn_cur;
  END IF;
  --
  OPEN c_sim_status;
  FETCH c_sim_status INTO sim_status_rec;
  IF c_sim_status%found AND sim_status_rec.x_sim_inv_status <> '253' THEN
    CLOSE c_sim_status;
    o_result_code:= '100';
    o_result_msg :='ERROR: SIM already in use';
    RETURN;
  ELSE
    CLOSE c_sim_status;
  END IF;
  --
  OPEN sim_inv_cur;
  FETCH sim_inv_cur INTO sim_inv_rec;
  IF sim_inv_cur%notfound THEN
    CLOSE sim_inv_cur;
    o_result_code:= '105';
    o_result_msg :='ERROR: SIM Not Found or Invalid Status';
    RETURN;
  ELSE
    CLOSE sim_inv_cur;
  END IF;
  --
  OPEN conf_cur(i_phone_model,sim_inv_rec.part_number);
  FETCH conf_cur INTO conf_rec;
  IF conf_cur%notfound THEN
    CLOSE conf_cur;
    o_result_code:= '110';
    o_result_msg :='ERROR: SIM not compatible';
    RETURN;
  ELSE
    CLOSE conf_cur;
  END IF;
  --
  IF esn_rec.x_iccid IS NOT NULL        AND esn_rec.x_iccid  = i_sim AND
     esn_rec.x_part_inst_status = '50'  AND esn_rec.n_part_inst2part_mod = conf_rec.mod_level_objid
  THEN
    --CR40609 added below if condition to fix an invalid cursor exception issue
    IF esn_cur%ISOPEN THEN
      CLOSE esn_cur;
    END IF;
    o_result_code:= '145';
    o_result_msg := 'SUCCESS'; -- Business and PSI agreed to have SUCCESS here.
    --o_result_msg :='ERROR: SIM was already married to phone, no need to re-marry';
    RETURN;
  END IF;
  --
  OPEN c_brand_chk;
  FETCH c_brand_chk INTO brand_rec;
  IF c_brand_chk%notfound THEN
    CLOSE c_brand_chk;
    o_result_code:= '135';
    o_result_msg :='ERROR: Brand not available';
    RETURN;
  ELSE
    CLOSE c_brand_chk;
  END IF;
  --
  OPEN c_model_chk;
  FETCH c_model_chk INTO model_rec;
  IF c_model_chk%notfound THEN
    CLOSE c_model_chk;
    o_result_code   :=  '200';
    o_result_msg    :=  'ERROR:  Model passed is not supported';
    RETURN;
  ELSE
    CLOSE c_model_chk;
  END IF;
  --
  OPEN c_pcpv (conf_rec.part_class_name);
  FETCH c_pcpv INTO pcpv_rec;
  IF c_pcpv%notfound THEN
    CLOSE c_pcpv;
    o_result_code:= '155';
    o_result_msg :='ERROR: Part class configuration missing';
    RETURN;
  ELSE
    CLOSE c_pcpv;
  END IF;
  --
  IF conf_rec.ESNSIZE <> LENGTH(trim(i_esn)) THEN
    o_result_code     := '120';
    o_result_msg      :='ERROR: ESN should be '||conf_rec.ESNSIZE||' characters long';
    RETURN;
  END IF;
  --
  IF conf_rec.ESNINPUTFORMAT = 'HEXADECIMAL' THEN
    BEGIN
      v_esn := sa.HEX2DEC(HEXVAL => trim(i_esn));
      v_hex := trim(i_esn);
    EXCEPTION
    WHEN OTHERS THEN
      o_result_code:= '125';
      o_result_msg :='ERROR: Invalid hexadecimal entry';
      RETURN;
    END;
  ELSE -- DECIMAL
    v_esn := trim(i_esn);
  END IF;
  --
  OPEN dealer_cur(conf_rec.dealer_id);
  FETCH dealer_cur INTO dealer_rec; -- If not found storing null
  CLOSE dealer_cur;
  IF conf_rec.LUHN_VALIDATION='YES' THEN
    --------------------------------
    -- LUHN Validation
    --------------------------------
    v_luhn:= sa.luhn(substr(v_esn,1,conf_rec.ESNSIZE));
    IF v_luhn <> 0 THEN
      o_result_code:= '130';
      o_result_msg :='ERROR: Luhn Validation Failed';
      RETURN;
    END IF;
  END IF;
  --
  IF conf_rec.HEXCONVERSION = 'HEXADECIMAL' THEN
    BEGIN
      --IMEI does not convert to HEX,  function bellow does not work
      --v_hex := sa.MEIDDECTOHEX(P_DECNUM => v_esn);
      v_hex := trim(v_esn);
    EXCEPTION
    WHEN OTHERS THEN
      v_hex := v_esn;
    END;
  ELSE
    IF conf_rec.HEXCONVERSION = 'NOT_NEEDED' THEN
      v_hex   := NULL;
    ELSE
      IF conf_rec.HEXCONVERSION = 'DECIMAL' THEN
        v_hex := v_esn;
      END IF;
    END IF;
  END IF;
  --
  -- This below validations are repeated with the converted (if applicable) ESN
  --
  OPEN esn_cur(v_esn);
  FETCH esn_cur INTO esn_rec;
  IF esn_cur%found AND esn_rec.x_part_inst_status = '52' THEN
    CLOSE esn_cur;
    o_result_code:= '140';
    o_result_msg :='ERROR: Phone Already Active';
    RETURN;
  ELSIF esn_cur%found AND esn_rec.x_part_inst_status = '50' THEN
    IF esn_rec.x_iccid IS NOT NULL AND esn_rec.x_iccid  = i_sim AND esn_rec.n_part_inst2part_mod = conf_rec.mod_level_objid
    THEN
      CLOSE esn_cur;
      o_result_code:= '145';
      o_result_msg := 'SUCCESS'; -- Business and PSI agreed to have SUCCESS here.
      --o_result_msg :='ERROR: SIM was already married to phone, no need to re-marry';
      RETURN;
    ELSE
      v_esn_loaded      := 1;
      CLOSE esn_cur;
    END IF;
  ELSIF esn_cur%found THEN
    CLOSE esn_cur;
    o_result_code:= '150';
    o_result_msg :='ERROR: Phone Invalid Status';
    RETURN;
  ELSE
    CLOSE esn_cur;
  END IF;
  --
  IF pcpv_rec.technology = 'CDMA' AND conf_rec.VD_REQD = 'YES'
  THEN
    l_vd_reqd   :=  'Y';
  ELSE
    l_vd_reqd   :=  'N';
  END IF;
  --
  IF l_vd_reqd  = 'Y'
  THEN
    OPEN c_last_ig('RSS');
    FETCH c_last_ig INTO last_ig_rec;
    IF c_last_ig%notfound THEN
      CLOSE c_last_ig;
      -- Create VD logic
      -- Insert into ig_transaction
      l_trans_id  :=  (gw1.trans_id_seq.nextval + (POWER(2 ,28)));
      --
      INSERT
      INTO gw1.ig_transaction
      (
       action_item_id,
       esn,
       esn_hex,
       order_type,
       template,
       account_num,
       status,
       TRANSACTION_ID
      )
      VALUES
      (
       sa.sequ_action_item_id.NEXTVAL,
       i_esn,
       v_hex,
       'VD',
       'RSS',
       '1161',
       'Q',
       l_trans_id
      );
      --
      COMMIT;
      --
      io_vd_trans_id      :=    l_trans_id;
      o_result_code       :=    '160';
      o_result_msg        :=    'VD Initiated';
      RETURN;
    END IF;
    CLOSE c_last_ig;
    io_vd_trans_id      :=  last_ig_rec.transaction_id;
    IF last_ig_rec.status IN ('SS','S','W')
    THEN
      l_ig_status         :=  'ELIGIBLE';
    ELSIF last_ig_rec.status IN ('FF','F','E')
    THEN
      o_result_code       :=  '170';
      o_result_msg        :=  'VD Returned NOT ELIGIBLE';
      RETURN;
    ELSIF last_ig_rec.status IN ('CP','L', 'Q')
    THEN
      IF NVL(i_retry_flag, 'X') = 'Y'
      THEN
        o_result_code       :=  '180';
        o_result_msg        :=  'VD Pending';
        RETURN;
      ELSIF NVL(i_retry_flag, 'X') = 'N'
      THEN
        o_result_code       :=  '210';
      END IF;
    ELSE
      o_result_code       :=  '190';
      o_result_msg        :=  'INVALID Status from VD';
      RETURN;
    END IF;
  END IF;
  --
  IF v_esn_loaded = 0 THEN
    INSERT
    INTO sa.table_part_inst
      (
        objid,
        part_serial_no,
        x_hex_serial_no,
        x_part_inst_status,
        x_sequence,
        x_po_num,
        x_red_code,
        x_order_number,
        x_creation_date,
        x_domain,
        n_part_inst2part_mod,
        part_inst2inv_bin,
        part_status,
        x_insert_date,
        status2x_code_table,
        last_pi_date,
        last_cycle_ct,
        next_cycle_ct,
        last_mod_time,
        last_trans_time,
        date_in_serv,
        repair_date,
        created_by2user,
        x_iccid
      )
      VALUES
      (
        sa.seq('part_inst'),
        upper(v_esn),
        upper(v_hex),
        '50',
        0,
        'REGISTER RETAILER PHONE',
        NULL,
        NULL,
        SYSDATE,
        'PHONES',
        conf_rec.mod_level_objid,
        dealer_rec.objid,
        'Active',
        SYSDATE,
        986,
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
        (SELECT objid FROM sa.table_user WHERE s_login_name = upper('SA')
        ),
        i_sim
      );
    --
    v_pi_Return := sa.TOSS_UTIL_PKG.INSERT_PI_HIST_FUN( IP_PART_SERIAL_NO  => v_esn,
                                                       IP_DOMAIN          => 'PHONES',
                                                       IP_ACTION          => 'REGISTER RETAILER PHONE' ,
                                                       IP_PROG_CALLER     => i_source_system);
    --  remove other ESNs which are married to this SIM from Account
    FOR  each_rec  IN c_remove_esn_frm_acc(v_esn)
    LOOP
      --
      UPDATE Table_Part_Inst
      SET    x_part_inst2contact = NULL
      WHERE  objid               = each_rec.objid;
      --
      DELETE table_x_contact_part_inst
      WHERE  x_contact_part_inst2part_inst = each_rec.objid;
      --
    END LOOP;
    --  unmarry the sim associated with other phones which are in NEW Status
    UPDATE sa.table_part_inst
    SET    x_iccid                = NULL
    WHERE  part_serial_no     <> v_esn
    AND    x_iccid            = i_sim
    AND    x_part_inst_status = '50'
    AND    x_domain           = 'PHONES';
    --
    -- Insert into log table for SIMOUT registration
    INSERT INTO sa.simout_log
    (
      CLIENT_TRANS_ID,
      CLIENT_ID      ,
      ESN            ,
      SIM            ,
      BRAND          ,
      SOURCE_SYSTEM  ,
      DEALER_ID      ,
      STORE_ID       ,
      TERMINAL_ID    ,
      PHONE_MAKE     ,
      PHONE_MODEL    ,
      RETRY_FLAG     ,
      VD_TRANS_ID    ,
      INSERT_DATE    ,
      REGISTER_STATUS
    )
    VALUES
    (
      i_client_trans_id,
      i_client_id      ,
      i_esn            ,
      i_sim            ,
      i_brand          ,
      i_source_system  ,
      dealer_rec.objid ,
      i_store_id       ,
      i_terminal_id    ,
      i_phone_make     ,
      i_phone_model    ,
      i_retry_flag     ,
      io_vd_trans_id   ,
      SYSDATE          ,
      'S'
    );
    --
  ELSE
    UPDATE sa.table_part_inst
    SET    n_part_inst2part_mod   = conf_rec.mod_level_objid,
           part_inst2inv_bin      = dealer_rec.objid,
           x_iccid                = i_sim
    WHERE  part_serial_no     = v_esn
    AND    x_domain           = 'PHONES';
    --
    v_pi_Return := sa.TOSS_UTIL_PKG.INSERT_PI_HIST_FUN( IP_PART_SERIAL_NO => v_esn,
                                                        IP_DOMAIN         => 'PHONES',
                                                        IP_ACTION         => 'REGISTER RETAILER PHONE' ,
                                                        IP_PROG_CALLER    => i_source_system);
    --
    --  remove other ESNs which are married to the SIM from Account
    FOR  each_rec  IN c_remove_esn_frm_acc (v_esn)
    LOOP
      --
      UPDATE Table_Part_Inst
      SET    x_part_inst2contact = NULL
      WHERE  objid               = each_rec.objid;
      --
      DELETE table_x_contact_part_inst
      WHERE  x_contact_part_inst2part_inst = each_rec.objid;
      --
    END LOOP;
    --  unmarry the sim associated with other phones which are in NEW Status
    UPDATE sa.table_part_inst
    SET    x_iccid                = NULL
    WHERE  part_serial_no     <> v_esn
    AND    x_iccid            = i_sim
    AND    x_part_inst_status = '50'
    AND    x_domain           = 'PHONES';
    --
    UPDATE table_x_call_trans
    SET    x_result         = 'Failed',
           update_stamp     = SYSDATE
    WHERE  x_service_id     = v_esn
    AND    x_sourcesystem   = i_source_system ;
    --
    -- Insert into log table for SIMOUT registration
    INSERT INTO sa.simout_log
    (
      CLIENT_TRANS_ID,
      CLIENT_ID      ,
      ESN            ,
      SIM            ,
      BRAND          ,
      SOURCE_SYSTEM  ,
      DEALER_ID      ,
      STORE_ID       ,
      TERMINAL_ID    ,
      PHONE_MAKE     ,
      PHONE_MODEL    ,
      RETRY_FLAG     ,
      VD_TRANS_ID    ,
      INSERT_DATE    ,
      REGISTER_STATUS
    )
    VALUES
    (
      i_client_trans_id,
      i_client_id      ,
      i_esn            ,
      i_sim            ,
      i_brand          ,
      i_source_system  ,
      dealer_rec.objid ,
      i_store_id       ,
      i_terminal_id    ,
      i_phone_make     ,
      i_phone_model    ,
      i_retry_flag     ,
      io_vd_trans_id   ,
      SYSDATE          ,
      'S'
    );
    --
  END IF;
  --
  IF l_insert_call_trans  = 0
  THEN
    sp_seq('x_call_trans'
          ,l_calltranobj);
    INSERT INTO table_x_call_trans
          (objid
          ,call_trans2site_part
          ,x_action_type
          ,x_call_trans2carrier
          ,x_call_trans2dealer
          ,x_call_trans2user
          ,x_line_status
          ,x_min
          ,x_service_id
          ,x_sourcesystem
          ,x_transact_date
          ,x_total_units
          ,x_action_text
          ,x_reason
          ,x_result
          ,x_sub_sourcesystem
          ,x_iccid
          ,x_ota_req_type
          ,x_ota_type
          ,update_stamp)
          VALUES
          (l_calltranobj
          ,NULL
          ,8
          ,NULL
          ,dealer_rec.objid
          ,(SELECT objid FROM sa.table_user WHERE s_login_name = upper('SA'))
          ,NULL
          ,v_esn
          ,v_esn
          ,i_source_system
          ,SYSDATE
          ,0
          ,i_source_system
          ,i_source_system || '_REGISTER'
          , 'Completed'
          ,i_brand
          ,i_sim
          ,NULL -- ip_ota_req_type
          ,NULL -- ip_ota_type
          ,SYSDATE
          );
  END IF;
  --
  COMMIT;
  --
  IF o_result_code  = '210'
  THEN
    o_result_msg :='VD Pending but ESN is Registered';
  ELSE
    o_result_code:= '0';
    o_result_msg :='SUCCESS';
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
  --
  l_action      :=  'WHEN OTHERS ESN: '|| i_esn||' SIM: ' || i_sim  || ' BRAND: '|| i_brand || ' SOURCE: '|| i_source_system;
  l_action      :=  l_action ||' MAKE: '|| i_phone_make || ' MODEL: '|| i_phone_model || ' VD Trans ID IN PARAM: '|| io_vd_trans_id;
  l_error_txt   :=  'ERROR : ' || SUBSTR(SQLERRM,1,3800);
  util_pkg.insert_error_tab (l_action, i_esn, 'sim_out_registration_prc',l_error_txt );
  --
END sim_out_registration_prc;
-- ANTHILL_TEST PLSQL/SA/Procedures/sim_out_registration_prc.sql 	CR39389: 1.1
/