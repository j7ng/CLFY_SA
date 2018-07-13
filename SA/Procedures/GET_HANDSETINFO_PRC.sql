CREATE OR REPLACE PROCEDURE sa."GET_HANDSETINFO_PRC" (
    p_esn     IN VARCHAR2,
    p_balance IN NUMBER DEFAULT 0,
    p_billing_direction OUT VARCHAR2,
    p_resolution_url OUT VARCHAR2,
    p_min OUT VARCHAR2,
    p_delivery_method OUT VARCHAR2,
    p_MANUFACTURER OUT VARCHAR2,
    p_MODEL OUT VARCHAR2,
    p_part_class OUT VARCHAR2,
    p_ppe_enabled OUT VARCHAR2,
    p_toolkit_version OUT VARCHAR2,
    p_device_os OUT VARCHAR2,
    p_backbone_carrier OUT VARCHAR2,
    p_CONVERSION_FACTOR OUT VARCHAR2,
    p_account_id OUT VARCHAR2,
    p_DEALER_ID OUT VARCHAR2,
    P_due_date OUT VARCHAR2,
    p_BRAND OUT VARCHAR2,
    P_CHARGE_UNIT_TYPE OUT VARCHAR2,
    p_associated_account OUT VARCHAR2,
    op_err_num OUT NUMBER,
    OP_ERR_STRING OUT VARCHAR2)
IS
  /******************************************************************************************/
  /*    Copyright   2012 Tracfone  Wireless Inc. All rights reserved                  */
  /*                                                                                  */
  /* NAME:         get_handsetinfo_prc                                                */
  /* PURPOSE:      To retrieve the handset info                                       */
  /*
  /* FREQUENCY:                                                                       */
  /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                   */
  /*                                                                                        */
  /* REVISIONS:                                                                       */
  /* VERSION  DATE        WHO              PURPOSE                                          */
  /* -------  ---------- -----     ---------------------------------------------    */
  /*  1.0                           initial
  /*  1.8     12/18/12  CLindner    add distinct to query
  /*  1.9     02/15/2013 CLindner   CR21967                                                   */
  /******************************************************************************************/
  CURSOR c1
  IS
    SELECT NULL delivery_method,
      (SELECT v.x_param_value
      FROM table_x_part_class_params n,
        table_x_part_class_values v
      WHERE 1                =1
      AND n.x_param_name     = 'MANUFACTURER'
      AND n.objid            = v.value2class_param
      AND v.value2part_class = pn.part_num2part_class
      ) MANUFACTURER,
    (SELECT X_MODEL_NUMBER
    FROM table_part_class pc
    WHERE 1      =1
    AND pc.objid = pn.part_num2part_class
    ) MODEL,
    (SELECT name
    FROM table_part_class pc
    WHERE 1      =1
    AND pc.objid = pn.part_num2part_class
    ) part_class,
    (
    CASE
      WHEN EXISTS
        (SELECT 1
        FROM table_x_part_class_values v,
          table_x_part_class_params n
        WHERE 1                 = 1
        AND v.value2part_class  = pn.part_num2part_class
        AND v.value2class_param = n.objid
        AND n.x_param_name      = 'NON_PPE'
        AND v.x_param_value    IN ( '1')  --CR46039  Removed '0'
        AND ROWNUM              < 2
        )
      THEN 0
      ELSE 1
    END) ppe_enabled,
    (SELECT x_param_value
      FROM table_x_part_class_values v,
        table_x_part_class_params n
      WHERE 1                 = 1
      AND v.value2part_class  = pn.part_num2part_class
      AND v.value2class_param = n.objid
      AND n.x_param_name      = 'NON_PPE'
      AND ROWNUM              < 2
    )non_ppe,    --CR46039 New field in c1 cur
    NULL toolkit_version,
    (SELECT v.x_param_value
    FROM table_x_part_class_params n,
      table_x_part_class_values v
    WHERE 1                =1
    AND n.x_param_name     = 'DLL'
    AND n.objid            = v.value2class_param
    AND v.value2part_class = pn.part_num2part_class
    ) dll,
    (SELECT v.x_param_value
    FROM table_x_part_class_params n,
      table_x_part_class_values v
    WHERE 1                =1
    AND n.x_param_name     = 'OPERATING_SYSTEM'
    AND n.objid            = v.value2class_param
    AND v.value2part_class = pn.part_num2part_class
    ) device_os,
    (SELECT v.x_param_value
    FROM table_x_part_class_params n,
      table_x_part_class_values v
    WHERE 1                =1
    AND n.x_param_name     = 'DEVICE_TYPE'
    AND n.objid            = v.value2class_param
    AND v.value2part_class = pn.part_num2part_class
    ) device_type,
    (SELECT p.x_parent_name
    FROM table_site_part sp,
      table_part_inst pi2,
      table_x_carrier ca,
      table_x_carrier_group cg,
      table_x_parent p
    WHERE 1             =1
    AND sp.x_service_id = p_esn
    AND sp.part_status
      ||''                 = 'Active'
    AND pi2.part_serial_no = sp.x_min
    AND ca.objid           = pi2.part_inst2carrier_mkt
    AND cg.objid           = ca.CARRIER2CARRIER_GROUP
    AND p.objid            = cg.X_CARRIER_GROUP2X_PARENT
    ) backbone_carrier,
    NVL(
    (SELECT otaf.X_CURRENT_CONV_RATE
    FROM table_x_ota_features otaf
    WHERE otaf.X_OTA_FEATURES2PART_INST = pi.objid
    ),0) CONVERSION_FACTOR,
    NVL(
    (SELECT x_conv_rate
    FROM table_site_part sp,
      table_x_ild_transaction it
    WHERE 1             =1
    AND sp.x_service_id = p_esn
    AND sp.part_status
      ||''                     = 'Active'
    AND it.x_esn               = sp.x_service_id
    AND it.ild_trans2site_part = sp.objid
    AND rownum                 <2
    ),0) CONVERSION_FACTOR2,
    NULL account_id,
    (SELECT bin_name FROM table_inv_bin ib WHERE ib.objid = pi.PART_INST2INV_BIN
    ) dealer_id,
    (SELECT x_min
    FROM table_site_part sp
    WHERE 1             =1
    AND sp.x_service_id = p_esn
    AND sp.part_status
      ||'' = 'Active'
    ) x_min,
    (SELECT x_expire_dt
    FROM table_site_part sp
    WHERE 1             =1
    AND sp.x_service_id = p_esn
    AND sp.part_status
      ||'' = 'Active'
    ) due_date,
    (SELECT v.x_param_value
    FROM table_x_part_class_params n,
      table_x_part_class_values v
    WHERE 1                =1
    AND n.x_param_name     = 'BUS_ORG'
    AND n.objid            = v.value2class_param
    AND v.value2part_class = pn.part_num2part_class
    ) brand,
    (SELECT DISTINCT wu.objid
    FROM table_web_user wu,
      table_x_contact_part_inst conpi
    WHERE wu.WEB_USER2CONTACT               = conpi.x_contact_part_inst2contact
    and wu.web_user2bus_org = pn.part_num2bus_org --cr25420
    AND conpi.x_contact_part_inst2part_inst = pi.objid
    ) web_user_objid,
    (SELECT NVL(spfvdef2.value_name,'NULL PLAN') plan_type
    FROM table_site_part sp,
      X_SERVICE_PLAN_SITE_PART spsp,
      X_SERVICE_PLAN_FEATURE spf,
      X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
      X_SERVICEPLANFEATURE_VALUE spfv,
      X_SERVICEPLANFEATUREVALUE_DEF spfvdef2
   WHERE 1             =1
    AND sp.x_service_id = pi.part_serial_no
    AND sp.part_status
      ||''                          = 'Active'
    AND spsp.TABLE_SITE_PART_ID     = sp.objid
    AND spf.sp_feature2service_plan =spsp.X_SERVICE_PLAN_ID
    AND spfvdef.objid               =spf.sp_feature2rest_value_def
    AND spfvdef.value_name          = 'PLAN TYPE'
    AND spfv.spf_value2spf          = spf.objid
    AND spfvdef2.objid              = spfv.value_ref
    ) plan_type,
    (SELECT COUNT(*)
    FROM x_sl_currentvals
    WHERE x_current_esn= pi.part_serial_no
    AND rownum         < 2
    ) safelink,
    (SELECT COUNT(*) cnt
    FROM table_site_part sp,
      table_x_call_trans ct,
      table_x_red_card rc
    WHERE 1             =1
    AND sp.x_service_id = pi.part_serial_no
    AND sp.part_status
      ||''                     = 'Active'
    AND ct.CALL_TRANS2SITE_PART= sp.objid
    AND ct.x_transact_date+0   > sysdate -90
    AND rc.RED_CARD2CALL_TRANS = ct.objid
    AND upper(rc.X_RESULT)     = 'COMPLETED'
    AND rownum                 <2
    ) cardpurchlast90days,
    (SELECT COUNT(*)
    FROM X_PROGRAM_ENROLLED ENROLL,
      X_PROGRAM_PARAMETERS PARAM
    WHERE 1                        = 1
    AND ENROLL.X_ESN               = pi.part_serial_no
    AND ENROLL.X_ENROLLMENT_STATUS = 'ENROLLED'
    AND PARAM.OBJID                = ENROLL.PGM_ENROLL2PGM_PARAMETER
    AND x_is_recurring             = 1
    AND rownum                     < 2
    ) autorefill,
    (SELECT COUNT(*)
    FROM table_x_group2esn ge,
      table_x_promotion_group pg
    WHERE 1                   =1
    AND ge.groupesn2part_inst = pi.objid
    AND sysdate BETWEEN ge.X_START_DATE AND ge.X_END_DATE
    AND pg.objid      = ge.groupesn2x_promo_group+0
    AND pg.group_name = 'X3XMN_GRP'
    AND rownum        <2
    ) triple_minutes,
    NULL charge_unit_type
  FROM table_part_inst pi,
    table_mod_level ml,
    table_part_num pn
  WHERE 1               =1
  AND pi.part_serial_no = p_esn
  AND pi.x_domain       = 'PHONES'
  AND ml.objid          = pi.n_part_inst2part_mod
  AND pn.objid          = ml.part_info2part_num;
  c1_rec c1%rowtype;
  cursor branch_curs(c_plan_type in varchar2,
                    c_due_date in date,
                    c_triple_minutes in number,
                    c_safelink in number,
                    c_brand in varchar2,
                    c_web_user_objid in number,
                    c_CARDPURCHLAST90DAYS in number,
                    c_auto_refill in number,     --CR23816
                    c_ppe_enabled in varchar2,
                    c_device_type in varchar2,
                    c_device_os in varchar2,
                    c_branch_type in varchar2
                    ) is      --CR23816
    select x_billing_direction,x_resolution_url,objid
      from x_gethandsetinfo
     where x_plan_type = case when c_plan_type in ('MONTHLY PLANS') then
                                'MONTHLY PLANS'
                              when c_plan_type IN ('EASY MINUTES','WEB EXCLUSIVE','DEFAULT', 'PAYGO') then
                                'NOT MONTHLY'
                              when c_plan_type is null then
                                'NOT MONTHLY'
                              when c_brand in ('STRAIGHT_TALK','SIMPLE_MOBILE','TELCEL') and c_plan_type = 'SPECIAL PLANS' then
                                'MONTHLY PLANS'
                              when c_brand in ('NET10') and c_plan_type = 'SPECIAL PLANS' then
                                'NOT NONTHLY'
                              else
                                'PLAN NOT FOUND'
                              end
       and 1 = case when x_ppe_enabled = 'NO' then
                      1
                    when x_ppe_enabled = c_ppe_enabled then   --CR23816, CR24606: Added by Akuthadi per CLindner
                      1
                    else
                      0
               end
       and 1 = case when x_device_type = 'NO' then
                      1
                    when x_device_type = c_device_type then   --CR23816
                      1
                    else
                      0
               end
       and 1 = case when x_device_os = 'NO' then
                      1
                    when x_device_os = c_device_os then   --CR23816
                      1
                    else
                      0
               end
       and 1 = case when x_due_date = 'NO' then
                      1
                    when x_due_date = 'YES' and trunc(sysdate) = trunc(c_due_date) then   --CR23816
                      1
                    else
                      0
               end
       and 1 = case when x_triple_minutes = 'NO' then       --CR23816
                      1
                    when x_triple_minutes = 'YES' and C_TRIPLE_MINUTES = 1  then        --CR23816
                      1
                    else
                      0
                    end
       and 1 = case when x_safelink = 'NO' then       --CR23816
                      1
                    when x_safelink = 'YES' and C_SAFELINK = 1  then        --CR23816
                      1
                    else
                      0
                    end
       and 1 = case when x_brand = 'NONE' then       --CR23816
                      1
                    when x_brand = c_brand then        --CR23816
                      1
                    else
                      0
                    end
       and 1 = case when x_account_id = 'NO' then
                      1
                    when c_web_user_objid is not null and x_account_id = 'YES' then
                      1
                    when c_web_user_objid is null and x_account_id = 'NOTYES' then
                      1
                    else
                      0
                    end
       and 1= case when x_redeem_in_last_90_days = 'NO' then
                     1
                  when C_CARDPURCHLAST90DAYS = 1 and x_redeem_in_last_90_days = 'YES' then
                     1
                  when C_CARDPURCHLAST90DAYS = 0 and  x_redeem_in_last_90_days = 'NOTYES' then
                     1
                  else
                     0
                  end
       and 1= case when x_auto_refill = 'NO' then
                     1
                  when C_auto_refill = 1 and x_auto_refill = 'YES' then
                     1
                  when C_auto_refill = 0 and  x_auto_refill = 'NOTYES' then
                     1
                  else
                     0
                  end
       and 1 = case when x_balance_type = 'NONE' then
                      1
                    when x_balance_type = '<' and P_BALANCE < x_balance then
                      1
                    when x_balance_type = '>' and P_BALANCE > x_balance then
                      1
                    when x_balance_type = '=' and P_BALANCE = x_balance then
                      1
                    else
                      0
                    end
       and 1= case when c_branch_type =  'x_resolution_url'       --CR23816
                    and x_resolution_url is not null then
                     1
                   when c_branch_type =  'x_billing_direction'
                    and x_billing_direction is not null then
                     1
                   else
                     0
                   end
   order by x_order;                                             --CR23816
  branch_rec branch_curs%rowtype;

BEGIN
  OP_ERR_NUM    := 0;
  OP_ERR_STRING := 'Success';
  BEGIN
    OPEN c1;
    FETCH c1 INTO c1_rec;
    IF c1%notfound THEN
      p_resolution_url := 'E6_resolution_url';
      CLOSE c1;
      RETURN;
    END IF;
    CLOSE c1;
    DBMS_OUTPUT.PUT_LINE('c1_rec.plan_type:'||c1_rec.plan_type);
    p_min                      := c1_rec.x_min;
    p_delivery_method          := c1_rec.delivery_method;
    p_MANUFACTURER             := c1_rec.MANUFACTURER;
    p_MODEL                    := c1_rec.MODEL;
    p_part_class               := c1_rec.part_class;
    p_ppe_enabled              := c1_rec.ppe_enabled;
    p_toolkit_version          := c1_rec.toolkit_version;
    p_device_os                := c1_rec.device_os;
    p_backbone_carrier         := c1_rec.backbone_carrier;
    IF c1_rec.CONVERSION_FACTOR =0 AND c1_rec.CONVERSION_FACTOR2!=0 THEN
      p_CONVERSION_FACTOR      := c1_rec.CONVERSION_FACTOR2;
    ELSE
      p_CONVERSION_FACTOR := c1_rec.CONVERSION_FACTOR;
    END IF;
    p_account_id       := c1_rec.web_user_objid;

    -- CR#24606 - Mobile Billing Guest Checkout
    IF c1_rec.web_user_objid IS NULL THEN
       p_associated_account := 'NONE';
    ELSE
       p_associated_account := sa.bau_util_pkg.get_account_association(c1_rec.web_user_objid);
    END IF;

    p_DEALER_ID        := c1_rec.DEALER_ID;
    P_due_date         := c1_rec.due_date;
    p_BRAND            := c1_rec.BRAND;
    P_CHARGE_UNIT_TYPE := C1_REC.CHARGE_UNIT_TYPE;
    dbms_output.put_line('c1_rec.plan_type '||c1_rec.plan_type);
    IF c1_rec.due_date IS NULL OR TRUNC(c1_rec.due_date) < TRUNC(sysdate) THEN
      p_resolution_url := 'E2_resolution_url';
      RETURN;
    END IF;
    IF C1_REC.PLAN_TYPE = 'NULL PLAN' THEN
      DBMS_OUTPUT.PUT_LINE('C1_REC.PLAN_TYPE  '||C1_REC.PLAN_TYPE );
      P_RESOLUTION_URL         := 'E1_resolution_url';
      return;
    end if;
     DBMS_OUTPUT.PUT_LINE('c1_rec.plan_type:'||c1_rec.plan_type);
     DBMS_OUTPUT.PUT_LINE('c1_rec.due_date:'||c1_rec.due_date);
     DBMS_OUTPUT.PUT_LINE('c1_rec.TRIPLE_MINUTES:'||c1_rec.TRIPLE_MINUTES);
     DBMS_OUTPUT.PUT_LINE('c1_rec.SAFELINK:'||c1_rec.SAFELINK);
     DBMS_OUTPUT.PUT_LINE('c1_rec.brand:'||c1_rec.brand);
     DBMS_OUTPUT.PUT_LINE('c1_rec.web_user_objid:'||c1_rec.web_user_objid);
     DBMS_OUTPUT.PUT_LINE('c1_rec.CARDPURCHLAST90DAYS:'||c1_rec.CARDPURCHLAST90DAYS);
     DBMS_OUTPUT.PUT_LINE('c1_rec.AUTOREFILL:'||c1_rec.AUTOREFILL);
   open branch_curs(c1_rec.plan_type,
                   c1_rec.due_date,
                   C1_REC.TRIPLE_MINUTES,
                   C1_REC.SAFELINK,
                   c1_rec.brand,
                   c1_rec.web_user_objid,
                   C1_REC.CARDPURCHLAST90DAYS,
                   C1_REC.AUTOREFILL,
                   c1_rec.ppe_enabled,
                   c1_rec.device_type,
                   c1_rec.device_os,
                   'x_resolution_url');             --CR23816
     fetch branch_curs into branch_rec;
     DBMS_OUTPUT.PUT_LINE('x_resolution_url' );
     DBMS_OUTPUT.PUT_LINE('c1_rec.NON_PPE:'||c1_rec.NON_PPE);
     if branch_curs%found and nvl(c1_rec.non_ppe,'99') not in ('1','0')then          --CR23816  --CR46039 Added check to bypass x_resolution
       DBMS_OUTPUT.PUT_LINE('error x_resolution_url found:'||branch_rec.objid  );
       P_RESOLUTION_URL         := branch_rec.x_resolution_url;
       close branch_curs;
       return;
     end if;
   close branch_curs;
   open branch_curs(c1_rec.plan_type,
                    c1_rec.due_date,
                    C1_REC.TRIPLE_MINUTES,
                    C1_REC.SAFELINK,
                    c1_rec.brand,
                    c1_rec.web_user_objid,
                    C1_REC.CARDPURCHLAST90DAYS,
                    C1_REC.AUTOREFILL,
                   c1_rec.ppe_enabled,
                   c1_rec.device_type,
                   c1_rec.device_os,
                    'x_billing_direction');
     fetch branch_curs into branch_rec;               --CR23816
     if branch_curs%notfound then
       DBMS_OUTPUT.PUT_LINE('x_billing_direction not found' );
       P_RESOLUTION_URL         := 'E1_resolution_url';
       close branch_curs;                                        --CR23816
       return;
     else
       DBMS_OUTPUT.PUT_LINE('branch_rec.x_billing_direction:'||branch_rec.x_billing_direction||':'||branch_rec.objid );
       p_billing_direction := branch_rec.x_billing_direction;          --CR23816
     end if;
    close branch_curs;

     p_delivery_method := case when p_device_os in ( 'ANDROID','BBOS','BYOP','IOS') then
                              'HTTP_RAW_DOWNLOAD'
                            else
                              'DD_FILE'
                            END;
    P_CHARGE_UNIT_TYPE :=
    CASE
    WHEN instr(p_billing_direction ,'AIRTIME')>0 THEN
      'Minutes'
    ELSE
      'Dollars'
    END;
    p_toolkit_version :=
    CASE
    WHEN c1_rec.dll <=0 THEN
      NULL
    WHEN c1_rec.dll BETWEEN 1 AND 13 THEN
      '1.0'
    WHEN c1_rec.dll BETWEEN 14 AND 21 THEN
      '2.0'
    WHEN c1_rec.dll BETWEEN 22 AND 29 THEN
      '2.x'
    WHEN c1_rec.dll BETWEEN 30 AND 36 THEN
      '3.0'
    WHEN c1_rec.dll BETWEEN 37 AND 48 THEN
      '3.x'
    WHEN c1_rec.dll BETWEEN 49 AND 49 THEN
      '4.0'
    WHEN c1_rec.dll BETWEEN 50 AND 62 THEN
      '4.x'
    ELSE
      '5.x'
    END;
  EXCEPTION
  WHEN OTHERS THEN
    OP_ERR_NUM    := SQLCODE;
    OP_ERR_STRING := sqlerrm;
  END;
END;
/