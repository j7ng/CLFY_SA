CREATE OR REPLACE PACKAGE BODY sa."UTIL_PKG" AS
PROCEDURE insert_error_tab_proc (
      ip_action         IN   VARCHAR2,
      ip_key            IN   VARCHAR2,
      ip_program_name   IN   VARCHAR2,
      ip_error_text     IN   VARCHAR2 DEFAULT NULL
   )
   IS
   PRAGMA AUTONOMOUS_TRANSACTION; -- CR31683
   BEGIN

      IF ip_error_text IS NULL
      THEN
         return;
      END IF;

      INSERT INTO biz_error_table
                  (ERROR_TEXT, error_date, ERROR_NUM, error_key, program_name
                  )
           VALUES (ip_error_text, SYSDATE, ip_action, substr(ip_key,1,100), ip_program_name
                  );

   COMMIT;
   END insert_error_tab_proc;

PROCEDURE insert_error_tab ( i_action         IN   VARCHAR2,
                             i_key            IN   VARCHAR2,
                             i_program_name   IN   VARCHAR2,
                             i_error_text     IN   VARCHAR2 DEFAULT NULL ) IS

  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF i_error_text IS NULL THEN
    return;
  END IF;

  INSERT
  INTO   error_table
         ( error_text,
           error_date,
           action,
           key,
           program_name
         )
  VALUES
  ( i_error_text,
    SYSDATE,
    i_action,
    substr(i_key,1,100),
    i_program_name
  );

  COMMIT;

END insert_error_tab;

-- Get the rate plan of an ESN
FUNCTION get_esn_rate_plan ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS
  l_rate_plan   varchar2(50);
  l_sp_objid    number;
BEGIN
  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  l_rate_plan := service_plan.f_get_esn_rate_plan ( p_esn => i_esn);

  IF l_rate_plan IS NULL THEN
    --
    BEGIN
      select rate_plan
      into   l_rate_plan
      from   ( select *
              from   ( select rate_plan, rate_plan_date
                       from   gw1.ig_rate_plan_history
                       where  esn = i_esn
                       and    order_type not in  ('S','D')
                       union
                       select rate_plan, rate_plan_date
                       from   gw1.ig_rate_plan_history_archive where esn = i_esn
                       and    order_type not in  ('S','D')
                      )
              order by rate_plan_date desc
            )
      where rownum = 1;
    EXCEPTION
      WHEN others THEN
        NULL;
    END;

  END IF;
  --
  RETURN l_rate_plan;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_esn_rate_plan;


--
FUNCTION get_expire_dt ( i_esn IN VARCHAR2 ) RETURN DATE IS

  l_expire_dt DATE;

BEGIN
  BEGIN

    -- CR42459 Only use the service_exp_date when it's not a ppe
    --         and the cmmtmnt_end_dt is not null.
    --
    SELECT MAX(COALESCE(CASE WHEN GET_DATA_MTG_SOURCE (i_esn) <> 'PPE'
                             THEN sp.cmmtmnt_end_dt
                             ELSE NULL
                              END,sp.x_expire_dt))
    INTO   l_expire_dt
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = i_esn
    AND    ( ( sp.part_status = 'Active' AND
               sp.x_min IN ( SELECT pi_min.part_serial_no
                             FROM   table_part_inst pi_esn,
                                    table_part_inst pi_min
                             WHERE  1 = 1
                             AND    pi_esn.part_serial_no = sp.x_service_id
                             AND    pi_esn.x_domain = 'PHONES'
                             AND    pi_esn.objid = pi_min.part_to_esn2part_inst
                             AND    pi_min.x_domain = 'LINES'
                           )
             )
             OR
             ( sp.part_status <> 'Active')
           );
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- IF the BASE TTL is >= 20 years in future; we need to set the BASE TTL = sysdate + 20 Years
  IF l_expire_dt >= ADD_MONTHS ( SYSDATE, 240) THEN
    l_expire_dt := ADD_MONTHS ( SYSDATE, 240); -- 20 YEARS
  END IF;

  -- IF the BASE TTL is >= 20 years in future; we need to set the BASE TTL = sysdate + 20 Years
  IF TO_NUMBER(TO_CHAR(l_expire_dt,'YYYY')) <= 1753 THEN
    l_expire_dt := SYSDATE + 30;
  END IF;

  RETURN (TRUNC(l_expire_dt) + .99999);

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_expire_dt;

-- Get the service plan feature for an ESN's service plan and a feature value
FUNCTION get_sp_feature_value ( i_esn         IN VARCHAR2,
                                i_value_name  IN VARCHAR ) RETURN VARCHAR2 IS

  l_service_plan_id  x_service_plan.objid%TYPE;

BEGIN

  IF i_esn IS NULL OR i_value_name IS NULL THEN
    RETURN NULL;
  END IF;

  -- Get the esn service plan
  l_service_plan_id := get_service_plan_id ( i_esn => i_esn);

  -- Return the service plan feature value
  RETURN get_sp_feature_value ( i_service_plan_plan_objid => l_service_plan_id,
                                i_value_name              => i_value_name );

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_sp_feature_value;

--
FUNCTION get_sp_feature_value ( i_service_plan_plan_objid IN NUMBER,
                                i_value_name              IN VARCHAR ) RETURN VARCHAR2 IS

   -- Part number based click plan
   CURSOR c_get_value_name IS
    SELECT DISTINCT spfvdef2.value_name value_name
    FROM   x_serviceplanfeaturevalue_def spfvdef,
           x_serviceplanfeature_value spfv,
           x_service_plan_feature spf,
           x_serviceplanfeaturevalue_def spfvdef2,
           x_service_plan sp
    WHERE  sp.objid = i_service_plan_plan_objid
    AND    spf.sp_feature2service_plan = sp.objid
    AND    spf.sp_feature2rest_value_def = spfvdef.objid
    AND    spf.objid = spfv.spf_value2spf
    AND    spfvdef2.objid = spfv.value_ref
    AND    spfvdef.value_name = i_value_name;

  value_rec c_get_value_name%ROWTYPE;

BEGIN

  OPEN c_get_value_name;
  FETCH c_get_value_name INTO value_rec;
  IF c_get_value_name%FOUND THEN
    CLOSE c_get_value_name;
    --
    RETURN value_rec.value_name;
  ELSE
    CLOSE c_get_value_name;
    --
    RETURN NULL;
  END IF;
 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_sp_feature_value;

-- Added wrapper function to get the service plan id based on a provided ESN and PIN
FUNCTION get_service_plan_id ( i_esn  IN VARCHAR2,
                               i_pin  IN VARCHAR2 ) RETURN NUMBER IS

BEGIN
   RETURN ( sa.get_service_plan_id ( f_esn      => i_esn,
                                     f_red_code => i_pin) );
 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_service_plan_id;

FUNCTION get_ota_current_conv_rate ( i_part_inst_objid IN NUMBER ) RETURN VARCHAR2 IS
 ota_rec table_x_ota_features%ROWTYPE;
BEGIN
  --
  ota_rec := get_ota_features ( i_part_inst_objid => i_part_inst_objid );

  --
  RETURN ota_rec.x_current_conv_rate;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_ota_current_conv_rate;

FUNCTION get_ota_features ( i_part_inst_objid IN NUMBER ) RETURN table_x_ota_features%ROWTYPE IS
  CURSOR c_get_ota_features IS
    SELECT *
    FROM   table_x_ota_features
    WHERE  x_ota_features2part_inst = i_part_inst_objid;

  ota_rec  c_get_ota_features%ROWTYPE;
BEGIN
  --
  OPEN c_get_ota_features;
  FETCH c_get_ota_features INTO ota_rec;
  CLOSE c_get_ota_features;

  --
  RETURN ota_rec;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_ota_features;


-- Added wrapper function to get the service plan id based on a provided ESN
FUNCTION get_service_plan_id ( i_esn IN VARCHAR2) RETURN NUMBER IS

 spsp_rec x_service_plan_site_part%ROWTYPE;

BEGIN
  SELECT spsp.*
  INTO   spsp_rec
  FROM   table_part_inst pi_esn,
         table_site_part sp,
         x_service_plan_site_part spsp
  WHERE  pi_esn.part_serial_no = i_esn
  AND    pi_esn.x_domain = 'PHONES'
  AND    pi_esn.x_part_inst2site_part = sp.objid
  AND    sp.objid = spsp.table_site_part_id
  AND    sp.part_status = 'Active';

  RETURN spsp_rec.x_service_plan_id;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_service_plan_id;

FUNCTION get_esn_by_min ( i_min IN VARCHAR2 ) RETURN VARCHAR2 IS

  CURSOR c_get_esn IS
    SELECT pi_esn.part_serial_no
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.part_serial_no = i_min
    AND    pi_min.x_domain = 'LINES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst;

  esn_rec  c_get_esn%ROWTYPE;

BEGIN

  OPEN c_get_esn;
  FETCH c_get_esn INTO esn_rec;
  CLOSE c_get_esn;

  RETURN(esn_rec.part_serial_no);

 EXCEPTION
   WHEN others THEN
     RETURN(NULL);
END get_esn_by_min;

FUNCTION get_esn_by_msid ( i_msid IN VARCHAR2 ) RETURN VARCHAR2 IS

  CURSOR c_get_esn IS
    SELECT pi_esn.part_serial_no
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.x_msid = i_msid
    AND    pi_min.x_domain = 'LINES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst;

  esn_rec  c_get_esn%ROWTYPE;

BEGIN

  OPEN c_get_esn;
  FETCH c_get_esn INTO esn_rec;
  CLOSE c_get_esn;

  RETURN(esn_rec.part_serial_no);

 EXCEPTION
   WHEN others THEN
     RETURN(NULL);
END get_esn_by_msid;

-- Get the MIN (part_serial_no) based on the ESN
FUNCTION get_min_by_esn ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  l_min   table_part_inst.part_serial_no%TYPE;

BEGIN

  -- Get the MIN (part_serial_no) based on the ESN
  SELECT pi_min.part_serial_no min
  INTO   l_min
  FROM   table_part_inst pi_esn,
         table_part_inst pi_min
  WHERE  1 = 1
  AND    pi_esn.part_serial_no = i_esn
  AND    pi_esn.x_domain = 'PHONES'
  AND    pi_min.part_to_esn2part_inst = pi_esn.objid
  AND    pi_min.x_domain = 'LINES'
  AND    rownum = 1;

  RETURN l_min;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_min_by_esn;

-- Added function to get the brand objid based on a provided ESN
FUNCTION get_bus_org_id ( i_esn IN VARCHAR2) RETURN VARCHAR2 IS

  bus_org_rec   table_bus_org%ROWTYPE;

BEGIN

  bus_org_rec := get_bus_org_rec ( i_esn => i_esn);

  RETURN bus_org_rec.org_id;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_bus_org_id;

-- Added function to get the brand objid based on a provided ESN
FUNCTION get_min_bus_org_id ( i_min IN VARCHAR2) RETURN VARCHAR2 IS

  l_bus_org_id   VARCHAR2(100);

BEGIN
  --
  BEGIN
    SELECT bo.org_id
    INTO   l_bus_org_id
    FROM   table_part_num pn,
           table_mod_level ml,
           table_part_inst pi_esn,
           table_part_inst pi_min,
           table_bus_org bo
    WHERE  1 = 1
    AND    pi_min.part_serial_no = i_min
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst
    AND    ml.part_info2part_num = pn.objid
    AND    pi_esn.n_part_inst2part_mod = ml.objid
    AND    pn.part_num2bus_org = bo.objid;
   EXCEPTION
     WHEN others THEN
        RETURN NULL;
  END;

  RETURN l_bus_org_id;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_min_bus_org_id;

-- Added function to get the brand objid based on a provided ESN
FUNCTION get_bus_org_rec ( i_esn IN VARCHAR2) RETURN table_bus_org%ROWTYPE IS

   CURSOR c_esn  IS
      SELECT bo.*
      FROM   table_part_num pn,
             table_mod_level ml,
             table_part_inst pi,
             table_bus_org bo
      WHERE 1 = 1
      AND ml.part_info2part_num = pn.objid
      AND pi.n_part_inst2part_mod = ml.objid
      AND pi.part_serial_no = i_esn
      AND pn.part_num2bus_org = bo.objid;

  bus_org_rec   table_bus_org%ROWTYPE;

BEGIN

   OPEN c_esn;
   FETCH c_esn INTO bus_org_rec;
   IF c_esn%NOTFOUND
   THEN
      CLOSE c_esn;
      RETURN NULL;
   ELSE
      CLOSE c_esn;
      RETURN bus_org_rec;
   END IF;
 EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;

END get_bus_org_rec;

-- Added function to get the brand objid based on a provided ESN
FUNCTION get_bus_org_objid ( i_esn IN VARCHAR2) RETURN NUMBER IS
   CURSOR c_esn  IS
      SELECT bo.*
      FROM   table_part_num pn,
             table_mod_level ml,
             table_part_inst pi,
             table_bus_org bo
      WHERE 1 = 1
      AND ml.part_info2part_num = pn.objid
      AND pi.n_part_inst2part_mod = ml.objid
      AND pi.part_serial_no = i_esn
      AND pn.part_num2bus_org = bo.objid;

   l_part_num_rec    c_esn%ROWTYPE;

BEGIN

   OPEN c_esn;
   FETCH c_esn INTO l_part_num_rec;
   IF c_esn%NOTFOUND
   THEN
      CLOSE c_esn;
      RETURN 0;
   ELSE
      CLOSE c_esn;
      RETURN l_part_num_rec.objid;
   END IF;
 EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;
END get_bus_org_objid;

-- Added function to get the web user objid based on a provided ESN
FUNCTION get_web_user_objid ( i_esn IN VARCHAR2) RETURN NUMBER IS

   CURSOR c_get_web_user  IS
    SELECT wu.objid web_user_objid
    FROM   table_part_inst pi,
           table_x_ota_features ota,
           table_web_user wu,
           table_site_part sp,
           table_x_contact_part_inst cpi
    WHERE  1 = 1
    AND    pi.part_serial_no = i_esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.objid = x_ota_features2part_inst
    AND    pi.part_serial_no = sp.x_service_id
    AND    sp.part_status = 'Active'
    AND    cpi.x_contact_part_inst2part_inst = pi.objid
    AND    wu.web_user2contact = cpi.x_contact_part_inst2contact;

   l_web_user_rec    c_get_web_user%ROWTYPE;

BEGIN
   -- Get the web user objid based on an esn
   OPEN c_get_web_user;
   FETCH c_get_web_user INTO l_web_user_rec;
   CLOSE c_get_web_user;

   -- Return the objid
   RETURN NVL(l_web_user_rec.web_user_objid,0);

 EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;
END get_web_user_objid;


FUNCTION determine_usage_host_id ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  CURSOR c_is_tw IS
    SELECT 1
    FROM   x_account_group_member
    WHERE  esn = i_esn
    AND    UPPER(status) <> 'EXPIRED';
  is_tw_rec  c_is_tw%ROWTYPE;
BEGIN
  OPEN c_is_tw;
  FETCH c_is_tw INTO is_tw_rec;
  IF c_is_tw%FOUND THEN
    RETURN 'PCR';
    CLOSE c_is_tw;

  ELSE
    CLOSE c_is_tw;
    RETURN 'MAX';
  END IF;

 EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;
END determine_usage_host_id;

FUNCTION get_short_parent_name ( i_line_part_inst_objid IN NUMBER ) RETURN VARCHAR2 IS

  l_parent_name VARCHAR2(40);

BEGIN
  -- Get the parent name function from the part inst objid
  l_parent_name := get_parent_name ( i_line_part_inst_objid => i_line_part_inst_objid );

  -- convert the parent name and return the short description
  RETURN get_short_parent_name ( i_parent_name => l_parent_name );

 EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;
END get_short_parent_name;

-- Get the short description of the parent name based on the logic from the previous get inquiry process
FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2 IS

  l_short_parent_name VARCHAR2(40);
 cust sa.customer_type ; --CR46073

BEGIN
  --
/* CR46073 commented below case and added below two lines of code
 l_short_parent_name := CASE i_parent_name
 WHEN 'T-MOBILE' THEN 'TMO'
 WHEN 'T-MOBILE SAFELINK' THEN 'TMO'
 WHEN 'T-MOBILE PREPAY PLATFORM' THEN 'TMO'
 WHEN 'T-MOBILE SIMPLE' THEN 'TMO'
 WHEN 'CINGULAR' THEN 'ATT'
 WHEN 'CLARO' THEN 'CLR'
 WHEN 'CLARO SAFELINK' THEN 'CLR'
 WHEN 'VERIZON PREPAY PLATFORM' THEN 'VZW'
 WHEN 'VERIZON' THEN 'VZW'
 WHEN 'VERIZON SAFELINK' THEN 'VZW'
 WHEN 'VERIZON WIRELESS' THEN 'VZW'
 WHEN 'AT&T SAFELINK' THEN 'ATT'
 WHEN 'AT&T WIRELESS' THEN 'ATT'
 WHEN 'ATT WIRELESS' THEN 'ATT'
 WHEN 'AT&T PREPAY PLATFORM' THEN 'ATT'
 WHEN 'AT&T_NET10' THEN 'ATT'
 WHEN 'DOBSON CELLULAR' 	 THEN 'ATT'
 WHEN 'DOBSON GSM' THEN 'ATT'
 WHEN 'SPRINT' THEN 'SPRINT'
 WHEN 'SPRINT_NET10' THEN 'SPRINT'
 WHEN 'WIRELESS_NET10' 	 THEN 'VZW'
 WHEN 'VERIZON_PPP_SAFELINK' THEN 'VZW'
 ELSE i_parent_name
 END;
*/
 cust := sa.customer_type ();
 l_short_parent_name := cust.get_short_parent_name ( i_parent_name => i_parent_name);
  --
  RETURN l_short_parent_name;

 EXCEPTION
   WHEN OTHERS  THEN
     RETURN NULL;
END get_short_parent_name;

FUNCTION get_parent_name ( i_line_part_inst_objid IN NUMBER ) RETURN VARCHAR2 IS

  CURSOR c_get_parent_name IS
    SELECT p.x_parent_name parent_name
    FROM   table_part_inst pi_min,
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c
    WHERE  1 = 1
    AND    pi_min.part_to_esn2part_inst = i_line_part_inst_objid
    AND    c.objid                      = pi_min.part_inst2carrier_mkt
    AND    cg.objid                     = c.carrier2carrier_group
    AND    p.objid                      = cg.x_carrier_group2x_parent;

  parent_rec  c_get_parent_name%ROWTYPE;

BEGIN
  OPEN c_get_parent_name;
  FETCH c_get_parent_name INTO parent_rec;
  CLOSE c_get_parent_name;

  RETURN parent_rec.parent_name;

END get_parent_name;

FUNCTION get_parent_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  CURSOR c_get_parent_name IS
    SELECT p.x_parent_name parent_name
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min,
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c
    WHERE  1 = 1
    AND    pi_esn.part_serial_no = i_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst
    AND    pi_min.part_inst2carrier_mkt = c.objid
    AND    c.carrier2carrier_group = cg.objid
    AND    cg.x_carrier_group2x_parent = p.objid;

  parent_rec  c_get_parent_name%ROWTYPE;

BEGIN
  OPEN c_get_parent_name;
  FETCH c_get_parent_name INTO parent_rec;
  CLOSE c_get_parent_name;

  RETURN parent_rec.parent_name;

END get_parent_name;

-- Function used to get the last redemption date
-- CR53137 Modified get_last_base_red_date function for increasing the performance.
FUNCTION get_last_base_red_date ( ip_esn        IN  VARCHAR2 ,
                                  op_msg        OUT VARCHAR2 ,
                                  i_exclude_esn IN  VARCHAR2 DEFAULT NULL) RETURN DATE IS
  d_last_redemption_date DATE;
  c_device_type          VARCHAR2(30);
  c_min                  VARCHAR2(30);
  n_days                 NUMBER;
  n_transaction_days     NUMBER;
 FUNCTION f_get_red_date ( i_esn              IN VARCHAR2,
						               i_transaction_days IN NUMBER ) RETURN DATE IS
   l_red_date DATE;
  BEGIN
   SELECT MAX(x_transact_date)
   INTO   l_red_date
   FROM   ( SELECT x_transact_date  -- purch hdr
            FROM   table_x_call_trans ct
            WHERE  ct.x_service_id = i_esn
			      AND    ct.x_transact_date >= TRUNC(SYSDATE) - i_transaction_days
			      AND    ct.x_action_type+0 IN ( 1, 3, 6)
			      AND    x_result = 'Completed'
			      AND    NVL(x_reason,'X') NOT IN ('ADD_ON','COMPENSATION') --
            AND    EXISTS (SELECT  1
                            FROM   sa.x_program_purch_hdr hdr,
                                   sa.x_program_gencode pg
                            WHERE  1 = 1
                            AND    pg.gencode2call_trans     = ct.objid
                            AND    pg.gencode2prog_purch_hdr = hdr.objid
                            AND    hdr.x_ics_rflag IN ('ACCEPT', 'SOK')
                            AND    NVL(hdr.x_ics_rcode,'0') IN ('1','100')
                            AND    ( hdr.x_merchant_id IS NOT NULL OR hdr.x_payment_type = 'LL_RECURRING' )
                            AND    hdr.x_payment_type NOT IN ('REFUND', 'OTAPURCH')
                            )
            UNION
            SELECT  ct.x_transact_date  -- red card
            FROM    table_x_call_trans ct,
                    table_x_red_card rc
            WHERE   ct.x_service_id = i_esn
	          AND     ct.x_transact_date >= TRUNC(SYSDATE) - i_transaction_days
	          AND     ct.x_action_type+0 IN ( 1, 3, 6)
	          AND     ct.x_result = 'Completed'
	          AND     rc.red_card2call_trans = ct.objid
	          AND     NVL(x_reason,'X') NOT IN ('ADD_ON','COMPENSATION') -- it will avoid the data addons and ild addons
            UNION
            SELECT  ct.x_transact_date  -- awop/replacement
            FROM    table_x_call_trans ct
            WHERE   ct.x_service_id = i_esn
	          AND     ct.x_transact_date >= TRUNC(SYSDATE) - i_transaction_days
	          AND     ct.x_action_type+0 IN ( 1, 3, 6)
	          AND     ct.x_result = 'Completed'
	          AND     NVL(x_reason,'X') IN ('AWOP', 'REPLACEMENT')
          );

        RETURN l_red_date;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END f_get_red_date;
BEGIN
   -- Get the device type of the part class of the phone
   BEGIN
      SELECT NVL(vw.device_type,'FEATURE_PHONE')
      INTO   c_device_type
      FROM   table_part_inst pi,
             table_mod_level ml,
             table_part_num pn,
             table_part_class pc,
             sa.pcpv_mv vw
      WHERE  pi.part_serial_no = ip_esn
      AND    pi.n_part_inst2part_mod= ml.objid
      AND    ml.part_info2part_num = pn.objid
      AND    pn.part_num2part_class = pc.objid
      AND    pc.name = vw.part_class;
   EXCEPTION
     WHEN OTHERS THEN
       c_device_type := 'FEATURE_PHONE';
  END;

  --
  IF c_device_type IN ('WIRELESS_HOME_PHONE', 'FEATURE_PHONE') THEN
    BEGIN
       SELECT MAX(ct.x_transact_date)
       INTO   d_last_redemption_date
       FROM   table_x_call_trans ct
       WHERE  x_service_id = ip_esn
       AND    x_action_type+0 IN ( 1, 3, 6 )
       AND    x_result = 'Completed';
       --
       RETURN d_last_redemption_date;
     EXCEPTION
      WHEN OTHERS THEN
       op_msg := 'Error in feature_phone '||SQLERRM;
       RETURN NULL;
    END;
  END IF;

  --
  BEGIN
    SELECT x_min
    INTO   c_min
    FROM   ( SELECT x_min
             FROM   table_site_part
             WHERE  x_service_id = ip_esn
             ORDER BY (CASE
                        WHEN part_status = 'Active' THEN 1
                        ELSE 2
                       END
                      ),
                      install_date DESC
           )
    WHERE  ROWNUM < 2;
   EXCEPTION
     WHEN OTHERS THEN
       op_msg := 'Error finding min '||SQLERRM;
       RETURN NULL;
  END;

  --
  FOR all_esns IN ( SELECT objid,
                           x_service_id,
                           install_date,
                           part_status
                    FROM   table_site_part tsp
                    WHERE  x_min = c_min
                    AND NOT EXISTS ( SELECT 1
                                     FROM   table_site_part
                                     WHERE  x_min = tsp.x_min
                                     AND    x_service_id = tsp.x_service_id
                                     AND    x_service_id = i_exclude_esn
                                   )
                    ORDER BY (CASE
                                WHEN tsp.part_status = 'Active' THEN 1
                                ELSE 2
                              END
                             ),
                             install_date DESC
                  )
  LOOP
    -- -- Fteching plan sevice days
	 BEGIN
	  SELECT mv.days
	  INTO   n_days
	  FROM   x_service_plan_site_part xspsp
	  INNER  JOIN service_plan_feat_pivot_mv mv ON mv.service_plan_objid = x_service_plan_id
	  AND    xspsp.table_site_part_id = all_esns.objid;
	 EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		 n_days := 0;
	 END;
   --
   IF n_days <= 30 THEN
	   SELECT TO_NUMBER(x_param_value)
	   INTO   n_transaction_days
	   FROM   table_x_parameters
	   WHERE  x_param_name = 'CALL_TRANS_LIMIT4NON_MULTI_MNTH'
	   AND    ROWNUM = 1; -- Defining days limit for Non-Multi month plans
   ELSE
	   SELECT TO_NUMBER(x_param_value)
	   INTO   n_transaction_days
	   FROM   table_x_parameters
	   WHERE  x_param_name = 'CALL_TRANS_LIMIT4MULTI_MNTH'
	   AND    ROWNUM = 1;
   END IF;
   --
   IF sa.customer_info.get_shared_group_flag (i_esn => all_esns.x_service_id ) = 'N' THEN
      --
      d_last_redemption_date := f_get_red_date ( i_esn 				=> all_esns.x_service_id,
                                                 i_transaction_days	=> n_transaction_days );

      EXIT WHEN d_last_redemption_date IS NOT NULL;

   ELSE   -- shared plans

     FOR grp_esn in ( SELECT esn, master_flag
                      FROM   x_account_group_member
                      WHERE  account_group_id IN ( SELECT account_group_id
                                                   FROM   x_account_group_member
                                                   WHERE  UPPER(status) <> 'EXPIRED'
                                                   AND    esn = all_esns.x_service_id)
					            UNION
					            SELECT part_serial_no, 'N' master_flag
					            FROM   table_part_inst
					            WHERE  part_serial_no = all_esns.x_service_id
                      order by master_flag desc
					)
     LOOP
       -- Shared plans doesn't have the multi-month subscribers, so transaction days are fixed to parameter.
       SELECT TO_NUMBER(x_param_value)
	     INTO   n_transaction_days
	     FROM   table_x_parameters
	     WHERE  x_param_name = 'CALL_TRANS_LIMIT4NON_MULTI_MNTH'
		   AND    ROWNUM = 1; -- Defining days limit for Non-Multi month plans
       d_last_redemption_date := f_get_red_date ( i_esn 				      => grp_esn.esn,
                                                  i_transaction_days	=> n_transaction_days);

       EXIT WHEN d_last_redemption_date IS NOT NULL;

     END LOOP;

	 EXIT WHEN d_last_redemption_date IS NOT NULL;

   END IF;  -- shared flag
  --
  END LOOP; --all_esns

  -- If the above logic does not return a valid redemption date, then pick max tran date from call trans
  IF d_last_redemption_date IS NULL THEN
    SELECT MAX(x_transact_date)
    INTO   d_last_redemption_date
    FROM   table_x_call_trans ct
    WHERE  x_action_type IN ( 1, 3, 6)
    AND    x_service_id = ip_esn
	AND    NVL(x_reason,'X') NOT IN ('ADD_ON', 'MINCHANGE','COMPENSATION');
  END IF;

  -- If the above logic does not return a valid redemption date from call trans, then use site part (install date)
  IF d_last_redemption_date IS NULL THEN
    SELECT MAX(install_date)
    INTO   d_last_redemption_date
    FROM   table_site_part sp
    WHERE  x_service_id = ip_esn;
  END IF;

  RETURN (d_last_redemption_date);

END get_last_base_red_date;

FUNCTION get_last_base_red_date ( i_esn         IN VARCHAR2,
                                  i_exclude_esn IN  VARCHAR2 DEFAULT NULL ) RETURN DATE IS
  d_redemption_date  DATE;
  msg                VARCHAR2(300);
BEGIN
  --
  d_redemption_date := get_last_base_red_date ( ip_esn        => i_esn         ,
                                                op_msg        => msg           ,
						                        i_exclude_esn => i_exclude_esn );
  --
  RETURN d_redemption_date;
  --
END get_last_base_red_date;

FUNCTION get_propagate_flag ( ip_esn       IN VARCHAR2 ,
                              ip_rate_plan IN VARCHAR2 ) RETURN NUMBER IS
  ret_prop_flag number;
  err_loc       varchar2(100);
begin
  --
  begin
    select nvl(propagate_flag_value,2)
    into   ret_prop_flag
    from   x_rate_plan
    where  x_rate_plan = ip_rate_plan;
   exception
     when others then
       ret_prop_flag := 2;
  end;

  --
  return ret_prop_flag;

 exception
  when others then
    err_loc := nvl(err_loc, substr('Selecting prop flag '||sqlerrm,1,100));
    ret_prop_flag := null;
    return ret_prop_flag;
end get_propagate_flag;

function get_queued_days ( i_esn in varchar2 ) return number is
  l_queued_days number := 0;
  BEGIN

  IF i_esn IS NULL THEN
    RETURN NULL;
  END IF;

  SELECT SUM(QUEUED_DAYS)  -- [ CR47564 WFM change ] For WFM  brand the  brm_service_days is fetched from x_part_inst_ext and for
    INTO l_queued_days     --  other brands x_redeem_days are fetched from table_part_num.
  FROM TABLE (sa.customer_info.get_esn_queued_cards (i_esn => i_esn));

  RETURN l_queued_days;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 0;
END get_queued_days;

-- Function to determine the ESN based on the MIN or MSID or SUBSCRIBER_ID
FUNCTION get_esn ( i_min           IN VARCHAR2 ,
                   i_msid          IN VARCHAR2 ,
                   i_subscriber_id IN VARCHAR2 ,
                   i_wf_mac_id     IN VARCHAR2 ) RETURN VARCHAR2 IS

  l_esn VARCHAR2(30);

BEGIN

  -- Get the ESN by min
  IF i_min IS NOT NULL THEN
    l_esn := get_esn_by_min ( i_min => i_min );
    --
	IF l_esn IS NOT NULL THEN
	  RETURN l_esn;
	END IF;
  END IF;

  -- Get the ESN by msid
  IF i_msid IS NOT NULL THEN
    l_esn := NVL( get_esn_by_msid ( i_msid => i_msid ), get_esn_by_min ( i_min => i_msid) );
    --
	IF l_esn IS NOT NULL THEN
	  RETURN l_esn;
	END IF;
  END IF;

  --  Get the ESN by subscriber_id
  IF i_subscriber_id IS NOT NULL THEN
    BEGIN
	  SELECT esn
	  INTO   l_esn
      FROM   ( SELECT esn
               FROM   x_account_group_member
               WHERE  subscriber_uid = i_subscriber_id
               ORDER BY (CASE UPPER(status) WHEN 'ACTIVE'          THEN 1
                                            WHEN 'PAYMENT_PENDING' THEN 2
                                            WHEN 'INACTIVE'        THEN 3
                                            WHEN 'EXPIRED'         THEN 4
                         END),
                         ( CASE WHEN (end_date IS NULL) THEN 1
                                ELSE 2
                           END
                         ),
                         insert_timestamp
             )
      WHERE ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;

    --
	IF l_esn IS NOT NULL THEN
	  RETURN l_esn;
	END IF;

  END IF; -- IF i_subscriber_id IS NOT NULL ...

  -- Commented out since there is no index on TABLE_PART_INST on (x_wf_mac_id, x_domain)
  --IF i_wf_mac_id IS NOT NULL THEN
  --  BEGIN
  --    SELECT part_serial_no
  --    INTO   l_esn
  --    FROM   table_part_inst
  --    WHERE  x_wf_mac_id = i_wf_mac_id
  --    AND    x_domain = 'PHONES';
  --   EXCEPTION
  --     WHEN others THEN
  --       NULL;
  --  END;
  --END IF;

  RETURN l_esn;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_esn;

-- CR31456
FUNCTION fn_get_prev_carrier (i_serial_no         IN    VARCHAR2)
RETURN VARCHAR2
IS
--
CURSOR  c_prev_carrier
IS
SELECT parent.x_parent_id
FROM   table_x_carrier       carrier,
       table_x_parent        parent,
       table_x_carrier_group carrgrp
WHERE parent.objid                = carrgrp.x_carrier_group2x_parent
AND   carrgrp.objid               = carrier.carrier2carrier_group
AND   carrier.carrier2personality IN
                           (SELECT part_inst2x_pers
                            FROM
                                 (SELECT  x_min,
                                          service_end_dt,
                                          RANK() OVER (ORDER BY service_end_dt DESC) new_rank
                                  FROM  table_site_part
                                  WHERE part_status  = 'Inactive'
                                  AND   x_service_id = i_serial_no ) a,
                                  table_part_inst                     pi
                            WHERE new_rank    = 1
                            AND   pi.x_domain = 'LINES'
                            AND   a.x_min     = pi.part_serial_no) ;
--
prev_carrier_rec  c_prev_carrier%ROWTYPE;
--
BEGIN
--
  OPEN c_prev_carrier;
  FETCH c_prev_carrier INTO prev_carrier_rec;
  CLOSE c_prev_carrier;
  --
  RETURN prev_carrier_rec.x_parent_id;
--
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END fn_get_prev_carrier;
--
-- CR31456
PROCEDURE p_get_carrier_frm_nap_digital(i_zip             IN    VARCHAR2,
                                        i_esn             IN    VARCHAR2,
                                        i_sim             IN    VARCHAR2,
                                        i_source          IN    VARCHAR2,
                                        o_carr_mkt_objid  OUT   VARCHAR2,   --Added for CR42933 - ST Refresh
                                        o_carr_parent_id  OUT   VARCHAR2,    --Added for CR42933 - ST Refresh
                                        i_carrier         OUT   VARCHAR2,
                                        i_error_no        OUT   NUMBER,
                                        i_error_str       OUT   VARCHAR2)
IS
--
l_repl_part               VARCHAR2(100);
l_repl_tech               VARCHAR2(100);
l_sim_profile             VARCHAR2(100);
l_part_serial_no          VARCHAR2(100);
l_msg                     VARCHAR2(400);
l_pref_parent             VARCHAR2(100);
l_pref_carrier_objid      VARCHAR2(100);
l_dbg_msg                 VARCHAR2(2000);
--
CURSOR c_get_carrier_name
IS
SELECT cg.x_carrier_name
FROM   table_x_carrier c,
       table_x_carrier_group  cg
WHERE  c.carrier2carrier_group  = cg.objid
AND    c.x_status               = 'ACTIVE'
AND    cg.x_status              = 'ACTIVE'
AND    c.objid                  = l_pref_carrier_objid;
--
c_get_carrier_name_rec  c_get_carrier_name%ROWTYPE;
--
CURSOR c_get_disp_msg
IS
SELECT npm.error_no, npm.display_msg
FROM   table_nap_msg_mapping npm
WHERE  UPPER(npm.nap_msg)                  =  UPPER(l_msg)   -- Added UPPER for ST refresh Defect#13702 to avoid CASE issues.
   OR  Instr(UPPER(l_msg),UPPER(npm.nap_msg))  >  0;
--
c_get_disp_msg_rec  c_get_disp_msg%rowtype;
--
BEGIN
--
  BEGIN
  --
  NAP_DIGITAL(p_zip                 =>  i_zip,
              p_esn                 =>  i_esn,
              p_commit              =>  'NO',
              p_sim                 =>  i_sim,
              p_source              =>  i_source,
              p_repl_part           =>  l_repl_part,
              p_repl_tech           =>  l_repl_tech,
              p_sim_profile         =>  l_sim_profile,
              p_part_serial_no      =>  l_part_serial_no,
              p_msg                 =>  l_msg,
              p_pref_parent         =>  l_pref_parent,
              p_pref_carrier_objid  =>  l_pref_carrier_objid);
  --
  o_carr_mkt_objid  :=  l_pref_carrier_objid;
  o_carr_parent_id  :=  l_pref_parent;
  dbms_output.put_line ('l_pref_parent'       ||l_pref_parent);
  dbms_output.put_line ('l_pref_carrier_objid'||l_pref_carrier_objid);
  --
  EXCEPTION
  WHEN OTHERS THEN
    l_dbg_msg :=  SQLERRM;
    l_dbg_msg :=  SQLCODE;
  END;
  --
  OPEN c_get_carrier_name;
  FETCH c_get_carrier_name INTO c_get_carrier_name_rec;
  CLOSE c_get_carrier_name;
  --
  i_carrier := c_get_carrier_name_rec.x_carrier_name;
  --
  OPEN c_get_disp_msg;
  FETCH c_get_disp_msg INTO c_get_disp_msg_rec;
  IF c_get_disp_msg%NOTFOUND
  THEN
     i_error_no  :=  1;
     i_error_str :=  l_msg;
  ELSE
     i_error_no  :=  c_get_disp_msg_rec.error_no;
     i_error_str :=  NVL(c_get_disp_msg_rec.display_msg,l_msg);
  END IF;
  CLOSE c_get_disp_msg;
  --
EXCEPTION
WHEN OTHERS THEN
  i_error_no  :=  1;
  i_error_str :=  'Failed in when others of get_carrier_frm_nap_digital';
END p_get_carrier_frm_nap_digital;
--
-- CR31456
FUNCTION fn_is_number (i_string IN VARCHAR2)
RETURN NUMBER
IS
  v_new_num NUMBER;
BEGIN
  v_new_num := TO_NUMBER(i_string);
  RETURN 0;
EXCEPTION
WHEN VALUE_ERROR THEN
  RETURN 1;
END fn_is_number;
--
PROCEDURE p_convert_esn(i_serial_no     IN    VARCHAR2, -- ESN
                        i_carrier       IN    VARCHAR2,
                        i_err_no        OUT   NUMBER,
                        i_err_str       OUT   VARCHAR2,
                        i_esn           OUT   VARCHAR2,
                        i_esn_hex       OUT   VARCHAR2
                       )
IS
--
l_digits_len      NUMBER;
--
BEGIN
--
  l_digits_len  :=  LENGTH(i_serial_no);
  --
  IF i_carrier  IN ('VERIZON','SPRINT') AND l_digits_len IN (18,14)
  THEN
    IF l_digits_len = 18
    THEN
      i_esn     :=  i_serial_no;
      i_esn_hex :=  sa.meiddectohex(i_serial_no);
    ELSIF l_digits_len = 14
    THEN
      i_esn     :=  byop_service_pkg.hex2dec18(i_serial_no) ;
      i_esn_hex :=  i_serial_no;
    END IF;
 ELSIF i_carrier = 'VERIZON' AND l_digits_len = 15 AND sa.util_pkg.fn_is_number(i_serial_no) =0
  THEN
    IF luhn (i_serial_no) = 0
    THEN
      i_esn     :=  i_serial_no;
      i_esn_hex :=  i_serial_no;
    ELSE
      i_err_str :=  'ESN is not in valid format';
      i_err_no  :=  1;
      RETURN;
    END IF;
  ELSIF i_carrier = 'SPRINT'   AND l_digits_len  = 15
  THEN
    IF luhn (i_serial_no) = 0
    THEN
      i_esn     :=  byop_service_pkg.hex2dec18(SUBSTR(i_serial_no, 1,  14) );
      i_esn_hex :=  substr(i_serial_no, 1,  14);
    ELSE
      i_err_str :=  'ESN is not in valid format';
      i_err_no  :=  1;
      RETURN;
    END IF;
  ELSIF i_carrier = 'VERIZON'  AND l_digits_len  = 15 AND util_pkg.fn_is_number(i_serial_no) <> 0
  THEN
    i_esn     :=  byop_service_pkg.hex2dec18(SUBSTR(i_serial_no, 1,  14) );
    i_esn_hex :=  SUBSTR(i_serial_no, 1,  14);
  END IF;
  --
  i_err_str :=  'SUCCESS';
  i_err_no  :=  0;
  --
EXCEPTION
WHEN OTHERS THEN
  i_err_no  :=  1;
  i_err_str :=  'Failed in when others of p_convert_esn';
END p_convert_esn;
--
--CR43088 WARP 2.0
PROCEDURE p_insert_queued_cbo_service
                             (ip_cbo_task_name       IN  VARCHAR2,
                              ip_status              IN  VARCHAR2,
                              ip_creation_date       IN  DATE,
                              ip_delay_in_seconds    IN  NUMBER,
                              ip_request             IN  CLOB,
                              ip_soa_service_url     IN  VARCHAR2,
                              ip_esn                 IN  VARCHAR2  DEFAULT NULL,
                              ip_upgrade_to_esn      IN  VARCHAR2  DEFAULT NULL,
                              ip_source_system       IN  VARCHAR2  DEFAULT NULL,
                              op_error_code          OUT VARCHAR2,
                              op_error_msg           OUT VARCHAR2)
AS
BEGIN

INSERT INTO table_queued_cbo_service
(
objid              ,
cbo_task_name      ,
status             ,
creation_date      ,
delay_in_seconds   ,
request            ,
soa_service_uri    ,
esn                ,
upgrade_to_esn     ,
source_system
)
VALUES
(
sa.seq_queued_cbo_service.nextval  ,
ip_cbo_task_name                   ,
ip_status                          ,
ip_creation_date                   ,
ip_delay_in_seconds                ,
xmltype(ip_request)                ,
ip_soa_service_url                 ,
ip_esn                             ,
ip_upgrade_to_esn                  ,
ip_source_system
);

EXCEPTION
WHEN OTHERS THEN
    op_error_code := sqlcode;
    op_error_msg  := sqlerrm;
END p_insert_queued_cbo_service;
-- CR43088 WARP 2.0

--CR42674
PROCEDURE insert_rtc_log (
      ip_action         IN   VARCHAR2,
      ip_key            IN   VARCHAR2,
      ip_program_name   IN   VARCHAR2,
      ip_process_text   IN   VARCHAR2 DEFAULT NULL
   )
   IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN

      IF ip_process_text IS NULL
      THEN
         return;
      END IF;

/*	  DELETE rtc_process_log
	  WHERE process_date < sysdate - 30;*/ -- CR46502 Removed and added to archive_pkg under archive_rtc_process_log

      INSERT INTO rtc_process_log
                  (process_text, process_date, action, process_key, program_name
                  )
           VALUES (ip_process_text, SYSDATE, ip_action, substr(ip_key,1,100), ip_program_name
                  );

COMMIT;
END insert_rtc_log;

-- CR52737_Track_Name_and_Address_History_Part_2  Tim  10/2/2017
PROCEDURE write_log(ip_call_id          sa.adfcrm_activity_log.call_id%type,
                    ip_esn              sa.adfcrm_activity_log.esn%type,
                    ip_cust_id          sa.adfcrm_activity_log.cust_id%type,
                    ip_smp              sa.adfcrm_activity_log.smp%type,
                    ip_agent            sa.adfcrm_activity_log.agent%type,
                    ip_flow_name        sa.adfcrm_activity_log.flow_name%type,
                    ip_flow_description sa.adfcrm_activity_log.flow_description%type,
                    ip_status           sa.adfcrm_activity_log.status%type,
                    ip_permission_name  sa.adfcrm_activity_log.permission_name%type,
                    ip_reason           sa.adfcrm_activity_log.reason%type,
                    ip_ani              VARCHAR2,
                    ip_source_system    VARCHAR2)
  AS
  BEGIN

   MERGE INTO sa.adfcrm_activity_log
     USING (SELECT 1 FROM dual)
     ON   (AGENT = ip_agent
     AND   flow_name = ip_flow_name
     AND   nvl(flow_description,'default') = nvl(ip_flow_description,'default')
     AND   status = ip_status
     AND   decode(ip_esn,NULL,'NA',esn) = nvl(ip_esn,'NA')
     AND   decode(ip_call_id,NULL,'NA',call_id) = nvl(ip_call_id,'NA')
     AND   decode(ip_cust_id,NULL,'NA',cust_id) = nvl(ip_cust_id,'NA')
     AND   decode(ip_reason,NULL,'NA',reason) = nvl(ip_reason,'NA')
     AND   decode(ip_ani,NULL,'NA',ani) = nvl(ip_ani,'NA')
     AND   log_date BETWEEN SYSDATE-5/(24*60) AND SYSDATE
     AND   source_system = ip_source_system
     )
     WHEN NOT MATCHED THEN
     INSERT (objid,esn,smp,agent,log_date,flow_name,flow_description,status,permission_name,call_id,reason, cust_id,ani,source_system)
     VALUES (sa.seq_adfcrm_activity_log.nextval,ip_esn,ip_smp,ip_agent,SYSDATE,ip_flow_name,ip_flow_description,ip_status,ip_permission_name,ip_call_id,ip_reason,ip_cust_id,ip_ani,ip_source_system);


END write_log;

FUNCTION get_cos_by_red_date (i_cos      IN VARCHAR2,
                              i_red_date IN DATE ) RETURN VARCHAR2
AS
 l_cos  sa.x_policy_rule_config.cos%TYPE;

BEGIN
 SELECT cos
 INTO   l_cos
 FROM   x_policy_mapping_config
 WHERE  update_cos = i_cos
 AND    usage_tier_id = 2
 AND    i_red_date between start_date and end_date
 AND    rownum < 2;

 RETURN l_cos;

EXCEPTION
 WHEN OTHERS THEN
   RETURN i_cos;
END get_cos_by_red_date;

--Get Volte Flag.
FUNCTION get_volte_flag (i_part_num      IN table_part_num.part_number%TYPE )
RETURN VARCHAR2
AS
 l_volte_flag  VARCHAR2(1) := 'N';

BEGIN
    SELECT param_value
      INTO l_volte_flag
      FROM pc_params_view vw,
           table_part_num tpn
     WHERE 1=1
       AND tpn.part_num2part_class = vw.pc_objid
       AND part_number = i_part_num
       AND vw.param_name = 'VOLTE'
       AND vw.param_value = 'Y';
	dbms_output.put_line ('l_volte_flag  :'||l_volte_flag);
    RETURN l_volte_flag;
EXCEPTION
	WHEN OTHERS THEN
		l_volte_flag := 'N'; --Considered as non-HD.
        RETURN l_volte_flag;
END get_volte_flag;


FUNCTION net10_data_promo ( i_esn      IN VARCHAR2,
                            i_min      IN VARCHAR2,
                            i_sp_objid IN NUMBER  ,
                            i_ct_objid IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
 l_cos VARCHAR2(10);
 v_min VARCHAR2(20);
PROCEDURE ct_red_promo (i_ct_objid in NUMBER DEFAULT NULL)
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 igt  ig_transaction_type := ig_transaction_type();
 ig   ig_transaction_type := ig_transaction_type();
 --
 is_promo_min VARCHAR2(40);
 l_old_cos    VARCHAR2(10);
 l_sp_objid   NUMBER;
 l_new_cos    VARCHAR2(10);
BEGIN

  IF i_ct_objid IS NULL THEN
    RETURN;
  END IF;

  ig.transaction_id := ig.get_ig_transaction_id (i_call_trans_ojid => i_ct_objid);

  igt := ig_transaction_type ( i_transaction_id => ig.transaction_id  );

  -- exiting promo for min
  BEGIN
	SELECT 'Y' , cos
    INTO   is_promo_min, l_old_cos
    FROM   sa.x_policy_rule_subscriber prs
	WHERE  MIN = igt.MIN
	AND    nvl(inactive_flag,'N') = 'N'
	AND    EXISTS ( SELECT 1
			        FROM   sa.x_policy_rule_service_plan psp,
				           sa.x_policy_rule_config prc
			        WHERE  psp.policy_rule_config_objid = prc.objid
                    AND    prs.cos = prc.cos
			        AND    (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
  EXCEPTION
	WHEN OTHERS THEN
	  RETURN;
  END;

  -- eligible promo for min
  IF is_promo_min = 'Y' and igt.order_type = 'R' THEN
 	 -- cuurent sp
     l_sp_objid := sa.customer_info.get_service_plan_objid (i_esn => igt.esn);

     BEGIN
	  SELECT prc.cos
      INTO   l_new_cos
	  FROM   sa.x_policy_rule_service_plan psp,
	         sa.x_policy_rule_config prc
	  WHERE  psp.policy_rule_config_objid = prc.objid
	  AND    psp.service_plan_objid = l_sp_objid
	  AND    psp.inactive_flag = 'N'
	  AND   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y');
	EXCEPTION
	  WHEN OTHERS THEN
		l_new_cos := NULL;
	END;

    IF l_new_cos IS NOT NULL THEN
       -- for switching the plan from $35 to $40 vice versa
       IF l_new_cos != l_old_cos THEN
        -- update the cos
			BEGIN
				update sa.x_policy_rule_subscriber prs
				set    cos = l_new_cos,
					   update_timestamp = sysdate
				where  min = igt.min
				and    exists ( select 1
								from   sa.x_policy_rule_service_plan psp,
									   sa.x_policy_rule_config prc
								where  psp.policy_rule_config_objid = prc.objid
								and    prc.cos = prs.cos
								and   (nt_35_promo_flag = 'Y' or nt_40_promo_flag = 'Y'));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;

	   END IF;

    ELSE
      -- disable the promo
			BEGIN
			  update sa.x_policy_rule_subscriber prs
			  set    inactive_flag = 'Y',
					 update_timestamp = sysdate
			  where  min = igt.min
			  and    exists ( select 1
							  from   sa.x_policy_rule_service_plan psp,
									 sa.x_policy_rule_config prc
							  where  psp.policy_rule_config_objid = prc.objid
							  and    prc.cos = prs.cos
							  and   (nt_35_promo_flag = 'Y' or nt_40_promo_flag = 'Y'));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
	END IF;
  END IF;
  --
  COMMIT;
EXCEPTION
 WHEN OTHERS THEN
    NULL;
END;

BEGIN

 IF i_ct_objid IS NOT NULL THEN
     ct_red_promo (i_ct_objid => i_ct_objid);
     RETURN NULL;

 ELSE

  BEGIN
	  SELECT prc.cos
	  INTO   l_cos
	  FROM   sa.x_policy_rule_service_plan psp,
			     sa.x_policy_rule_config prc
	  WHERE  psp.policy_rule_config_objid = prc.objid
	  and    psp.service_plan_objid = i_sp_objid
	  and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y')
	  and   SYSDATE BETWEEN prc.start_date and prc.end_date;
  EXCEPTION
    WHEN OTHERS THEN
    l_cos := null;
  END;

    BEGIN
			SELECT CASE WHEN i_min LIKE 'T%' THEN CD.X_VALUE ELSE i_min END
			INTO v_min
			FROM sa.TABLE_CASE C,sa.TABLE_X_CASE_DETAIL CD
			WHERE 1=1
			AND C.OBJID = CD.DETAIL2CASE
			AND X_ESN = i_esn
			AND CD.X_NAME = 'CURRENT_MIN'
			AND C.CREATION_TIME > SYSDATE-2
			AND ROWNUM = 1;

  EXCEPTION
    WHEN OTHERS THEN
    v_min := i_min;
  END;


  if l_cos is not null then
		BEGIN
		 INSERT INTO sa.x_policy_rule_subscriber
					 ( OBJID,
					   MIN,
					   ESN,
					   COS,
					   START_DATE,
					   END_DATE,
					   INSERT_TIMESTAMP,
					   UPDATE_TIMESTAMP,
					   INACTIVE_FLAG
					  )
					 VALUES
					 (
					 sa.sequ_policy_rule_subscriber.NEXTVAL,
					 v_min,
					 i_esn,
					 l_cos,
					 TRUNC(SYSDATE),
					 '31-DEC-2055',
					 SYSDATE,
					 SYSDATE,
					 'N'
					 );
			--COMMIT;
		EXCEPTION
		WHEN OTHERS THEN
			null;
		END;
  end if;

  RETURN l_cos;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END;

END;
/