CREATE OR REPLACE PROCEDURE sa."VALIDATE_PROMO_CODE_IVR" ( ip_esn                 IN  VARCHAR2,
                                                     ip_airtime_part_number IN  VARCHAR2,
                                                     ip_promo_code          IN  VARCHAR2,
                                                     ip_channel             IN  VARCHAR2 DEFAULT 'IVR',
                                                     op_is_eligibile        OUT VARCHAR2,  --yes/no
                                                     op_promo_type          OUT VARCHAR2,  --standard/special
                                                     op_promo_discount      OUT VARCHAR2,
                                                     op_promo_addl_mins     OUT NUMBER,
                                                     op_promo_addl_days     OUT NUMBER,
                                                     op_promo_script        OUT VARCHAR2,
                                                     op_status_code         OUT VARCHAR2,
                                                     op_status_msg          OUT VARCHAR2 )
/*******************************************************************************************************
  --$RCSfile: validate_promo_code_ivr.sql,v $
  --$Revision: 1.4 $
  --$Author: smeganathan $
  --$Date: 2016/12/19 19:44:27 $
  --$ $Log: validate_promo_code_ivr.sql,v $
  --$ Revision 1.4  2016/12/19 19:44:27  smeganathan
  --$ CR47127 changed Promo type value
  --$
  --$ Revision 1.3  2016/10/21 16:44:13  smeganathan
  --$ CR43524  code changes to call validate proc from promotion package
  --$
  --$ Revision 1.0  2016/10/11 20:04:08  sraman
  --$ CR43524 -New wrapper procedure for IVR
  --$
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
IS
--
  l_technology              VARCHAR2(10);
  l_transaction_amount      NUMBER        :=  1;
  l_transaction_type        VARCHAR2(30)  :=  'PURCHASE';
  l_zipcode                 VARCHAR2(10);
  l_fail_flag               NUMBER;
  l_sms                     table_x_promotion.X_SMS%TYPE;
  l_data_mb                 table_x_promotion.X_DATA_MB%TYPE;
  l_applicable_device_type  table_x_promotion.X_DEVICE_TYPE%TYPE;
  l_brand                   table_bus_org.org_id%TYPE;
  l_device_type             VARCHAR2(200);
  --
BEGIN
  --
  BEGIN
     SELECT x_technology
     INTO   l_technology
     FROM   table_part_num pn,
            table_mod_level ml,
            table_part_inst pi
     WHERE  pi.n_part_inst2part_mod = ml.objid
     AND    ml.part_info2part_num   = pn.objid
     AND    pi.part_serial_no       = ip_esn;
  EXCEPTION
    WHEN OTHERS THEN
      op_status_code :=   sqlcode;
      op_status_msg  :=   'Error selecting esn '||ip_esn;
      RETURN;
  END;
  --
  BEGIN
    SELECT x_retail_price
    INTO l_transaction_amount
    FROM table_part_num pn,
         table_x_pricing xp
    WHERE 1            =1
    AND pn.part_number =ip_airtime_part_number
    AND pn.objid       = xp.x_pricing2part_num
    AND sysdate BETWEEN xp.x_start_date AND NVL(xp.x_end_date,sysdate)
    AND xp.X_CHANNEL = UPPER(ip_channel);
  EXCEPTION
    WHEN OTHERS THEN
      op_status_code :=   sqlcode;
      op_status_msg  :=   'Error Fetching Price of Part number:'||ip_airtime_part_number;
      RETURN;
  END;
  --
  -- Get brand and device type
  BEGIN
    SELECT  bo.org_id, pcpv.DEVICE_TYPE
    INTO    l_brand,  l_device_type
    FROM    table_part_inst   pi,
            table_mod_level   ml,
            table_part_num    pn,
            table_part_class  pc,
            table_bus_org     bo,
            pcpv              pcpv
    WHERE   pi.part_serial_no       = ip_esn
    AND     pi.x_domain             = 'PHONES'
    AND     pi.n_part_inst2part_mod = ml.objid
    AND     ml.PART_INFO2PART_NUM   = pn.objid
    AND     pn.PART_NUM2PART_CLASS  = pc.objid
    AND     pn.PART_NUM2BUS_ORG     = bo.objid
    AND     pc.name                 = pcpv.PART_CLASS;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;
  --
  IF  l_brand  = 'TRACFONE'
  AND (device_util_pkg.get_smartphone_fun(in_esn => ip_esn) = 0 OR l_device_type  IN ('BYOP'))
  THEN
    PROMOTION_PKG.validate_promo_code_ext
                            ( p_esn                 => ip_esn,
                              p_red_code01          => ip_airtime_part_number,
                              p_technology          => l_technology,                 --varchar2
                              p_transaction_amount  => l_transaction_amount,         --number
                              p_source_system       => ip_channel,                   --p_source_system VARCHAR2,
                              p_promo_code          => ip_promo_code,                --VARCHAR2,
                              p_transaction_type    => l_transaction_type,           --VARCHAR2,
                              p_zipcode             => l_zipcode,                    --VARCHAR2,
                              p_language            => 'ENGLISH',                    --p_language VARCHAR2,
                              p_fail_flag           => l_fail_flag,                  --NUMBER, --CR2739
                              p_discount_amount     => op_promo_discount,            --OUT VARCHAR2,
                              p_promo_units         => op_promo_addl_mins,           --p_promo_units OUT NUMBER,
                              p_sms                 => l_sms,
                              p_data_mb             => l_data_mb,
                              p_applicable_device_type  =>  l_applicable_device_type,
                              p_access_days         => op_promo_addl_days,           --p_access_days OUT NUMBER,
                              p_status              => op_status_code,               --OUT VARCHAR2,
                              p_msg                 => op_status_msg );              --OUT VARCHAR2)
  ELSE
    VALIDATE_PROMO_CODE ( p_esn                 => ip_esn,
                          p_red_code01          => ip_airtime_part_number,
                          p_technology          => l_technology,                 --varchar2
                          p_transaction_amount  => l_transaction_amount,         --number
                          p_source_system       => ip_channel,                   --p_source_system VARCHAR2,
                          p_promo_code          => ip_promo_code,                --VARCHAR2,
                          p_transaction_type    => l_transaction_type,           --VARCHAR2,
                          p_zipcode             => l_zipcode,                    --VARCHAR2,
                          p_language            => 'ENGLISH',                    --p_language VARCHAR2,
                          p_fail_flag           => l_fail_flag,                  --NUMBER, --CR2739
                          p_discount_amount     => op_promo_discount,            --OUT VARCHAR2,
                          p_promo_units         => op_promo_addl_mins,           --p_promo_units OUT NUMBER,
                          p_access_days         => op_promo_addl_days,           --p_access_days OUT NUMBER,
                          p_status              => op_status_code,               --OUT VARCHAR2,
                          p_msg                 => op_status_msg );              --OUT VARCHAR2)
  END IF;
  --
  ROLLBACK; --because it is already enrolling esn, not just validating promo
  --
  -- CR47127 Changes starts..
  -- promo type should be changed to "ELSE" as generic message message
  -- needs to be played in IVR, as per Gina
  op_promo_type := 'ELSE';
  /*
  IF op_promo_discount  + op_promo_addl_mins  + op_promo_addl_days > 0
  THEN
     op_promo_type := 'standard';
  ELSE
     op_promo_type := 'special';
  END IF;
  */
  -- CR47127 Changes ends
  --
  IF op_status_code <> 0
  THEN
    op_is_eligibile := 'NO';
  ELSE
    op_is_eligibile :=  'YES';
    op_promo_script :=  op_status_msg;
    op_status_msg   :=  'Success';
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    op_status_code   :=  sqlcode;
    op_status_msg    :=  'Failed in when others validate_promo_code_ivr '|| SUBSTR(SQLERRM, 1,100);
    --
END validate_promo_code_ivr;
/