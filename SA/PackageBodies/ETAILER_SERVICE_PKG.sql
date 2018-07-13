CREATE OR REPLACE PACKAGE BODY sa.etailer_service_pkg
AS
/*******************************************************************************************************
  * --$RCSfile: ETAILER_SERVICE_PKB.sql,v $
  --$Revision: 1.15 $
  --$Author: smeganathan $
  --$Date: 2016/07/01 17:29:08 $
  --$ $Log: ETAILER_SERVICE_PKB.sql,v $
  --$ Revision 1.15  2016/07/01 17:29:08  smeganathan
  --$ changes in void pin
  --$
  --$ Revision 1.14  2016/06/30 18:18:34  smeganathan
  --$ Changes in validate orderid
  --$
  --$ Revision 1.13  2016/06/28 15:58:08  smeganathan
  --$ changes for qpintoesn
  --$
  --$ Revision 1.12  2016/06/27 22:24:00  smeganathan
  --$ Added Brand validation for PIN and partnumber
  --$
  --$ Revision 1.11  2016/06/22 20:01:55  smeganathan
  --$ CR43162
  --$
  --$ Revision 1.9  2016/06/22 17:58:04  smeganathan
  --$ void pin changes
  --$
  --$ Revision 1.8  2016/06/22 17:38:05  smeganathan
  --$ changes in void pin
  --$
  --$ Revision 1.7  2016/06/22 15:24:26  smeganathan
  --$ fixed Able to void pin twice and commit in p_void_pin proc
  --$
  --$ Revision 1.6  2016/06/20 18:25:08  smeganathan
  --$ replaced customer type with red card type
  --$
  --$ Revision 1.5  2016/05/17 18:26:35  smeganathan
  --$ changes in get partner param
  --$
  --$ Revision 1.4  2016/05/13 21:11:43  smeganathan
  --$ CR42257 changes in void pin
  --$
  --$ Revision 1.3  2016/05/06 23:08:19  smeganathan
  --$ CR42257 changes for validate partner
  --$
  --$ Revision 1.2  2016/04/26 21:29:09  smeganathan
  --$ CR42257 code changes for etailer
  --$
  --$ Revision 1.11  2016/03/22 16:22:36 smeganathan
  --$ CR42257 - Code logic for Etailer project
  * Description: This package includes procedures
  * that are required for the Etailers to generate Pin / to get pin status
  *
  * -----------------------------------------------------------------------------------------------------
*********************************************************************************************************/
--
PROCEDURE p_validate_orderid (i_partner_id  IN  VARCHAR2,
                              i_brand       IN  VARCHAR2,
                              i_order_id    IN  VARCHAR2,
                              i_action      IN  VARCHAR2,
                              i_pin         IN  VARCHAR2,
                              i_smp         IN  VARCHAR2,
                              o_err_code    OUT VARCHAR2,
                              o_err_msg     OUT VARCHAR2)
IS
--
l_merchant_id           VARCHAR2(255);
l_charge_count          NUMBER :=  0;
l_refund_count          NUMBER :=  0;
l_pin                   table_part_inst.x_red_code%TYPE;
l_smp                   table_part_inst.part_serial_no%TYPE;
c                       sa.red_card_type := red_card_type();
--
BEGIN
--
  -- Input validation
  IF i_partner_id  IS NULL
  THEN
    o_err_code  :=  '800';
    o_err_msg   :=  'Partner ID cannot be null';
    RETURN;
  ELSIF i_brand IS NULL
  THEN
    o_err_code  :=  '810';
    o_err_msg   :=  'Brand cannot be null';
    RETURN;
  ELSIF i_order_id IS NULL
  THEN
    o_err_code  :=  '820';
    o_err_msg   :=  'Order ID cannot be null';
    RETURN;
  ELSIF i_action IS NULL
  THEN
    o_err_code  :=  '840';
    o_err_msg   :=  'Action cannot be null';
    RETURN;
  ELSIF i_action = 'VOID' AND i_pin IS NULL AND i_smp IS NULL
  THEN
    o_err_code  :=  '850';
    o_err_msg   :=  'PIN and SMP both cannot be null for VOID action';
    RETURN;
  END IF;
  --
  IF i_pin IS NULL AND i_smp IS NOT NULL
  THEN
    l_pin :=  c.convert_smp_to_pin ( i_smp => i_smp );
    l_smp :=  i_smp;
    --
    IF  l_pin IS NULL
    THEN
      o_err_code  :=  '825';
      o_err_msg   :=  'PIN Not Found';
      RETURN;
    END IF;
    --
  ELSIF i_smp IS NULL AND i_pin IS NOT NULL
  THEN
    l_smp :=  c.convert_pin_to_smp ( i_red_card_code =>  i_pin);
    l_pin :=  i_pin;
    --
    DBMS_OUTPUT.PUT_LINE('convert_pin_to_smp');
    IF  l_smp IS NULL
    THEN
      o_err_code  :=  '8226';
      o_err_msg   :=  'SMP Not found';
      RETURN;
    END IF;
    --
  END IF;
  -- Validate Partner ID and get Merchant ID
  etailer_service_pkg.get_partner_param (i_partner_id      =>   i_partner_id,
                                         i_param_name      =>   'MERCHANT_ID',
                                         o_param_value     =>   l_merchant_id,
                                         o_err_code        =>   o_err_code,
                                         o_err_msg         =>   o_err_msg);
  --
  IF i_action = 'CREATE'
  THEN
    -- check whether the same combination of merchant id, order id, action type exists
    BEGIN
      SELECT  count(1)
      INTO    l_charge_count
      FROM    x_biz_purch_hdr ph
      WHERE   ph.C_ORDERID        =   i_order_id
      AND     ph.X_MERCHANT_ID    =   l_merchant_id
      AND     ph.X_PAYMENT_TYPE   =   'CHARGE';
    EXCEPTION
      WHEN OTHERS THEN
        l_charge_count  :=  1;
    END;
    -- same order id, merchant id, action type exists throw error
    IF l_charge_count > 0
    THEN
      o_err_code  :=  '855';
      o_err_msg   :=  'Order ID is duplicate for the merchant id and action type';
      RETURN;
    END IF;
  ELSIF i_action = 'VOID'
  THEN
    -- check whether the same combination of merchant id, order id, action type exists
    BEGIN
      SELECT  count(1)
      INTO    l_charge_count
      FROM    x_biz_purch_hdr ph,
              x_biz_purch_dtl pd
      WHERE   ph.C_ORDERID        =   i_order_id
      AND     ph.X_MERCHANT_ID    =   l_merchant_id
      AND     ph.X_PAYMENT_TYPE   =   'CHARGE'
      AND     ph.objid            =   pd.BIZ_PURCH_DTL2BIZ_PURCH_HDR
      AND     pd.smp              =   l_smp;
    EXCEPTION
      WHEN OTHERS THEN
        l_charge_count  :=  0;
    END;
    -- same order id, merchant id, action type doesnt exists throw error for VOID
    IF l_charge_count = 0
    THEN
      o_err_code  :=  '856';
      o_err_msg   :=  'Charge transaction not processed for this Order ID';
      RETURN;
    END IF;
    -- Check whether PIN is already voided for this order ID
    BEGIN
      SELECT  count(1)
      INTO    l_refund_count
      FROM    x_biz_purch_hdr ph
      WHERE   ph.C_ORDERID        =   i_order_id
      AND     ph.X_MERCHANT_ID    =   l_merchant_id
      AND     ph.X_PAYMENT_TYPE   =   'REFUND';
    EXCEPTION
      WHEN OTHERS THEN
        l_refund_count  :=  1;
    END;
    --
    IF l_refund_count  > 0
    THEN
      o_err_code  :=  '857';
      o_err_msg   :=  'Refund is already processed for this Order ID';
      RETURN;
    END IF;
    --
  END IF;
  --
  o_err_code  :=  '0';
  o_err_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_code  :=  '700';
    o_err_msg   :=  'Inside when others while Queueing Pin to ESN';
END p_validate_orderid;
--
PROCEDURE p_qpintoesn_wrp ( i_partner_id  IN  VARCHAR2,
                            i_esn         IN  VARCHAR2,
                            i_pin         IN  VARCHAR2,
                            i_smp         IN  VARCHAR2,
                            i_brand       IN  VARCHAR2,
                            o_err_code    OUT VARCHAR2,
                            o_err_msg     OUT VARCHAR2)
IS
--
  l_status            VARCHAR2(200);
  l_inv_bin_objid     table_part_inst.PART_INST2INV_BIN%TYPE;
  l_pintoesn          NUMBER;
  c                   sa.red_card_type := red_card_type();
  l_dummy             varchar2(100);
--
BEGIN
--
  -- Input validation
  IF i_partner_id  IS NULL
  THEN
    o_err_code  :=  '700';
    o_err_msg   :=  'Partner ID cannot be null';
    RETURN;
  ELSIF i_brand IS NULL
  THEN
    o_err_code  :=  '710';
    o_err_msg   :=  'Brand cannot be null';
    RETURN;
  ELSIF i_esn IS NULL
  THEN
    o_err_code  :=  '720';
    o_err_msg   :=  'ESN cannot be null';
    RETURN;
  ELSIF i_pin IS NULL
  THEN
    o_err_code  :=  '730';
    o_err_msg   :=  'PIN cannot be null';
    RETURN;
  END IF;
  --
  -- ESN and brand validation
  IF i_brand  <> NVL(c.get_bus_org_id ( i_esn =>  i_esn),'X')
  THEN
    o_err_code    :=  '740';
    o_err_msg     :=  'Invalid ESN for the Brand';
    RETURN;
  END IF;
  -- Validate partner id
  etailer_service_pkg.validate_partner (i_partner_id      =>    i_partner_id,
                                        i_brand           =>    i_brand,
                                        i_pin_part_num    =>    NULL,
                                        i_smp             =>    i_smp,
                                        i_pin             =>    i_pin,
                                        o_inv_bin_objid   =>    l_inv_bin_objid,
                                        o_status          =>    l_status,
                                        o_err_code        =>    o_err_code,
                                        o_err_msg         =>    o_err_msg);
  --
  IF o_err_code <> '0'
  THEN
    RETURN;
  END IF;
  --
  l_pintoesn  :=  c.qPinToEsn ( i_esn      => i_esn,
                                i_pin      => i_pin,
                                o_err_code => o_err_code,
                                o_err_msg  => o_err_msg);
--
EXCEPTION
  WHEN OTHERS THEN
    o_err_code  :=  '700';
    o_err_msg   :=  'Inside when others while Queueing Pin to ESN';
END p_qpintoesn_wrp;
--
PROCEDURE get_partner_param (i_partner_id      IN     VARCHAR2,
                             i_param_name      IN     VARCHAR2,
                             o_param_value     OUT    VARCHAR2,
                             o_err_code        OUT    VARCHAR2,
                             o_err_msg         OUT    VARCHAR2)
IS
--
BEGIN
  --
  SELECT  pp.PARAM_VALUE
  INTO    o_param_value
  FROM    table_partner_params  pid,
          table_partner_params  ps,
          table_partner_params  pp
  WHERE   UPPER(pid.PARAM_NAME)       =  'PARTNER_ID'
  AND     UPPER(pid.PARAM_VALUE)      =  UPPER(i_partner_id)
  AND     pid.objid                   =  ps.link_objid
  AND     ps.PARAM_NAME               =  'STATUS'
  AND     ps.PARAM_VALUE              =  'ACTIVE'
  AND     pid.objid                   =  pp.link_objid
  AND     UPPER(pp.PARAM_NAME)        =  UPPER(i_param_name);
  --
  o_err_code    :=  '0';
  o_err_msg     :=  'SUCCESS';
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    o_err_code  :=  '510';
    o_err_msg   :=  'Either Partner ID could be InActive / Not a valid Partner Param name';
  WHEN OTHERS THEN
    o_err_code  :=  '550';
    o_err_msg   :=  'Inside when others while fetching partner params';
END get_partner_param;
--
PROCEDURE get_inv_objid (i_partner_id      IN     VARCHAR2,
                         o_inv_bin_objid   OUT    table_part_inst.PART_INST2INV_BIN%TYPE,
                         o_err_code        OUT    VARCHAR2,
                         o_err_msg         OUT    VARCHAR2)
IS
--
l_site_id       table_site.SITE_ID%TYPE;
--
BEGIN
  -- Validate input parameter
  IF i_partner_id IS NULL
  THEN
    o_err_code  :=  '600';
    o_err_msg   :=  'Partner ID cannot be null';
    RETURN;
  END IF;
  -- Get partner param value for SITE ID
  etailer_service_pkg.get_partner_param (i_partner_id      =>   i_partner_id,
                                         i_param_name      =>   'SITE_ID',
                                         o_param_value     =>   l_site_id,
                                         o_err_code        =>   o_err_code,
                                         o_err_msg         =>   o_err_msg);
  --
  IF o_err_code <> '0'
  THEN
    RETURN;
  END IF;
  -- Get  Inv_bin_objid
  BEGIN
    SELECT inv.objid
    INTO   o_inv_bin_objid
    FROM   table_inv_bin inv
    WHERE  inv.location_name = l_site_id ;
  EXCEPTION
    WHEN OTHERS THEN
      o_err_code  := '610';
      o_err_msg   := 'Could not obtain inv_bin_objid for site id - '||l_site_id ;
      RETURN;
  END;
  --
  o_err_code    :=  '0';
  o_err_msg     :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
  o_err_code  := '630';
  o_err_msg   := 'Inside when others of get_inv_objid for partner id ' || i_partner_id ;
  RETURN;
END get_inv_objid;
--
PROCEDURE validate_partner (i_partner_id      IN    VARCHAR2,
                            i_brand           IN    VARCHAR2,
                            i_pin_part_num    IN    VARCHAR2,
                            i_smp             IN    VARCHAR2,
                            i_pin             IN    VARCHAR2,
                            o_inv_bin_objid   OUT   VARCHAR2,
                            o_status          OUT   VARCHAR2,
                            o_err_code        OUT   VARCHAR2,
                            o_err_msg         OUT   VARCHAR2)
IS
--
  l_pin                   table_part_inst.x_red_code%TYPE;
  l_smp                   table_part_inst.part_serial_no%TYPE;
  l_ofs_cust_account_id   VARCHAR2(200);
  c    sa.red_card_type := red_card_type();
--
BEGIN
--
  IF i_partner_id IS NULL
  THEN
    o_err_code  :=  '410';
    o_err_msg   :=  'Partner ID cannot be null';
    RETURN;
  END IF;
  --
  IF  i_pin_part_num  IS NULL AND  i_smp IS NULL AND i_pin  IS NULL
  THEN
    o_err_code  :=  '420';
    o_err_msg   :=  'Either Part num / PIN / SMP should have value';
    RETURN;
  END IF;
  --
  -- Get inv objid
  etailer_service_pkg.get_inv_objid (i_partner_id      => i_partner_id,
                                     o_inv_bin_objid   => o_inv_bin_objid,
                                     o_err_code        => o_err_code,
                                     o_err_msg         => o_err_msg);
  --
  IF NVL(o_inv_bin_objid,0) = 0
  THEN
    RETURN;
  END IF;
  --
  IF i_pin_part_num IS NULL
  THEN
    -- Retrieve PIN / SMP if any of the value is not passed
    IF i_pin IS NULL AND i_smp IS NOT NULL
    THEN
      DBMS_OUTPUT.PUT_LINE('convert_smp_to_pin');
      l_pin :=  c.convert_smp_to_pin ( i_smp => i_smp );
      l_smp :=  i_smp;
      --
      IF  l_pin IS NULL
      THEN
        o_err_code  :=  '430';
        o_err_msg   :=  'PIN Not Found';
        RETURN;
      END IF;
      --
    ELSIF i_smp IS NULL AND i_pin IS NOT NULL
    THEN
      l_smp :=  c.convert_pin_to_smp ( i_red_card_code =>  i_pin);
      l_pin :=  i_pin;
      --
      DBMS_OUTPUT.PUT_LINE('convert_pin_to_smp');
      IF  l_smp IS NULL
      THEN
        o_err_code  :=  '440';
        o_err_msg   :=  'SMP Not found';
        RETURN;
      END IF;
      --
    ELSE
      l_pin :=  i_pin;
      l_smp :=  i_smp;
    END IF;
    --
    -- PIN and Brand validation
    IF i_brand  <>  NVL(c.get_brand_pin (i_pin => l_pin),'X')--NVL(get_brand_pin (i_pin => l_pin),'X')
    THEN
      o_status      :=  'INVALID';
      o_err_code    :=  '475';
      o_err_msg     :=  'Invalid PIN number for the Brand';
      RETURN;
    END IF;
    -- PIN and Partner ID validation
    BEGIN
      SELECT 'VALID'
      INTO    o_status
      FROM
          (SELECT  'Y'
          FROM    table_part_inst
          WHERE   x_red_code            = l_pin
          AND     PART_INST2INV_BIN     = o_inv_bin_objid
          UNION
          SELECT  'Y'
          FROM    table_x_red_card
          WHERE   x_red_code            = l_pin
          AND     X_RED_CARD2INV_BIN    = o_inv_bin_objid);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_status      :=  'INVALID';
      o_err_code    :=  '450';
      o_err_msg     :=  'Invalid Partner ID for the PIN / SMP';
      RETURN;
    WHEN OTHERS THEN
      o_err_code    :=  '460';
      o_err_msg     :=  'Failed while fetching from part inst / red card';
      RETURN;
    END;
  ELSE  -- Else of i_pin_part_num IS NULL
    --Logic to check whether the part num is mapped to brand
    IF i_brand  <>  NVL(c.get_brand_partnum (i_partnumber => i_pin_part_num),'X') --NVL(get_brand_partnum (i_partnumber => i_pin_part_num),'X')
    THEN
      o_status      :=  'INVALID';
      o_err_code    :=  '470';
      o_err_msg     :=  'Invalid Part number for the Brand';
      RETURN;
    END IF;
    -- Logic to check whether the Part num is mapped to the dealer
    -- Get partner param value for OFS CUST ACCOUNT ID
    etailer_service_pkg.get_partner_param (i_partner_id      =>   i_partner_id,
                                           i_param_name      =>   'OFS_CUST_ACCOUNT_ID',
                                           o_param_value     =>   l_ofs_cust_account_id,
                                           o_err_code        =>   o_err_code,
                                           o_err_msg         =>   o_err_msg);
    IF l_ofs_cust_account_id IS NOT NULL
    THEN
      BEGIN
        SELECT 'VALID'
        INTO   o_status
        FROM   PARTNUM_DEALER_MATVIEW
        WHERE  PART_NUMBER      =   i_pin_part_num
        AND    CUST_ACCOUNT_ID  =   l_ofs_cust_account_id
        AND    ROWNUM           =   1;
      EXCEPTION
        WHEN OTHERS
        THEN
          o_status      :=  'INVALID';
          o_err_code    :=  '480';
          o_err_msg     :=  'Invalid Part number for the Brand';
          RETURN;
      END;
    ELSE
      o_status      :=  'INVALID';
      o_err_code    :=  '490';
      o_err_msg     :=  'Partner validation failed';
      RETURN;
    END IF;
  END IF;
  --
  o_err_code := '0';
  o_err_msg  := 'SUCCESS';
--
EXCEPTION
WHEN OTHERS THEN
  o_err_code    :=  '400';
  o_err_msg     :=  'Failed in when others of validate_partner';
END validate_partner;
--
PROCEDURE p_void_pin (  i_pin               IN    VARCHAR2,
                        o_post_void_status  OUT   VARCHAR2,
                        o_err_code          OUT   VARCHAR2,
                        o_err_msg           OUT   VARCHAR2)
IS
--
  l_pin               table_part_inst.x_red_code%TYPE;
  l_pin_status        table_x_code_table.X_CODE_NAME%TYPE;
  l_units             VARCHAR2(200);
  l_days              VARCHAR2(200);
  l_brand             VARCHAR2(200);
  l_part_type         VARCHAR2(200);
  l_card_type         VARCHAR2(200);
  l_status            VARCHAR2(200);
--
BEGIN
--
  -- Get status of the pin before Voiding
  byop_service_pkg.card_status( p_red_code    =>  i_pin,
                                p_status      =>  l_pin_status,
                                p_units       =>  l_units,
                                p_days        =>  l_days,
                                p_brand       =>  l_brand,
                                p_part_type   =>  l_part_type,
                                p_card_type   =>  l_card_type,
                                p_out_code    =>  o_err_code,
                                p_out_desc    =>  o_err_msg );
  --
  IF l_pin_status = 'INVALID'
  THEN
    o_post_void_status  :=  'INVALID';
    o_err_code          :=  '310';
    o_err_msg           :=  'PIN is already in VOID Status';
    RETURN;
    --
  ELSIF l_pin_status NOT IN ('REDEEMED')
  THEN
    --
    UPDATE  table_part_inst
    SET     part_to_esn2part_inst = NULL,   --  Detach the ESN linked to PIN
            x_part_inst_status    = '44',   --  Make the PIN Invalid
            STATUS2X_CODE_TABLE   = '1144'
    WHERE   x_red_code          = i_pin
    AND     x_domain            = 'REDEMPTION CARDS';
    --
    o_post_void_status  :=  'INVALID';
    --
  ELSE
    --
    o_post_void_status  :=  l_pin_status;
    o_err_code          :=  '330';
    o_err_msg           :=  'PIN cannot be Voided';
    RETURN;
    --
  END IF;
  --
  o_err_code := '0';
  o_err_msg  := 'SUCCESS';
--
EXCEPTION
WHEN OTHERS THEN
  o_err_code  :=  '320';
  o_err_msg   :=  'Inside when others p_void_pin';
END p_void_pin;
--
PROCEDURE p_soft_pin_actions (  i_partner_id     IN     VARCHAR2,
                                i_brand          IN     VARCHAR2,
                                i_pin_part_num   IN     table_part_inst.part_serial_no%TYPE,
                                i_pin            IN     table_part_inst.x_red_code%TYPE,
                                i_smp            IN     table_x_cc_red_inv.x_smp%TYPE,
                                i_action         IN     VARCHAR2,
                                o_refcursor      OUT    SYS_REFCURSOR,
                                o_err_code       OUT    VARCHAR2,
                                o_err_msg        OUT    VARCHAR2)
IS
--
  l_pin               table_part_inst.x_red_code%TYPE;
  l_soft_pin          table_part_inst.x_red_code%TYPE;
  l_smp               table_part_inst.part_serial_no%TYPE;
  l_return            NUMBER;
  l_pin_status        table_x_code_table.X_CODE_NAME%TYPE;
  l_units             VARCHAR2(200);
  l_days              VARCHAR2(200);
  l_brand             VARCHAR2(200);
  l_part_type         VARCHAR2(200);
  l_card_type         VARCHAR2(200);
  l_status            VARCHAR2(200);
  l_inv_bin_objid     table_part_inst.PART_INST2INV_BIN%TYPE;
  c                   sa.red_card_type := red_card_type();
--
BEGIN
--
  o_err_code := '0';
  o_err_msg  := 'SUCCESS';
  OPEN o_refcursor
  FOR  SELECT   NULL
  FROM DUAL;
  --
  -- Input validation
  IF i_action  IS NULL  OR i_action NOT IN ('CREATE','GET','VOID')
  THEN
    o_err_code  :=  '100';
    o_err_msg   :=  'INVALID Action';
    RETURN;
  ELSIF i_action = 'CREATE' AND i_pin_part_num  IS NULL
  THEN
    o_err_code  :=  '110';
    o_err_msg   :=  'Pin part number cannot be null for Action CREATE';
    RETURN;
  ELSIF i_action IN ('GET','VOID') AND (i_pin  IS NULL AND i_smp IS NULL)
  THEN
    o_err_code  :=  '120';
    o_err_msg   :=  'Either PIN or SMP should have value for Action GET or VOID';
    RETURN;
  ELSIF i_partner_id  IS NULL
  THEN
    o_err_code  :=  '130';
    o_err_msg   :=  'Partner ID cannot be null';
    RETURN;
  ELSIF i_brand IS NULL
  THEN
    o_err_code  :=  '190';
    o_err_msg   :=  'Brand cannot be null';
    RETURN;
  END IF;
  -- Validate the partner ID and get Inv bin objid
  etailer_service_pkg.validate_partner (i_partner_id      =>    i_partner_id,
                                        i_brand           =>    i_brand,
                                        i_pin_part_num    =>    i_pin_part_num,
                                        i_smp             =>    i_smp,
                                        i_pin             =>    i_pin,
                                        o_inv_bin_objid   =>    l_inv_bin_objid,
                                        o_status          =>    l_status,
                                        o_err_code        =>    o_err_code,
                                        o_err_msg         =>    o_err_msg);
  --
  IF o_err_code <> '0'
  THEN
    RETURN;
  END IF;
  --
  -- Retrieve PIN / SMP if any of the value is not passed
  IF i_pin IS NULL AND i_smp IS NOT NULL
  THEN
    l_pin :=  c.convert_smp_to_pin ( i_smp => i_smp );
    l_smp :=  i_smp;
    --
    IF  l_pin IS NULL
    THEN
      o_err_code  :=  '140';
      o_err_msg   :=  'Product serial number not found';
    END IF;
    --
  ELSIF i_smp IS NULL AND i_pin IS NOT NULL
  THEN
    l_smp :=  c.convert_pin_to_smp ( i_red_card_code =>  i_pin);
    l_pin :=  i_pin;
    --
    IF  l_smp IS NULL
    THEN
      o_err_code  :=  '150';
      o_err_msg   :=  'SMP Not found';
    END IF;
    --
  ELSE
    l_pin :=  i_pin;
    l_smp :=  i_smp;
  END IF;
  --
  IF i_action =  'CREATE'
  THEN
    --
    l_return    :=  getSoftPin (  ip_pin_part_num   =>  i_pin_part_num,
                                  ip_inv_bin_objid  =>  l_inv_bin_objid,
                                  op_soft_pin       =>  l_pin,
                                  op_smp_number     =>  l_smp,
                                  op_err_msg        =>  o_err_msg);
    --
    IF NVL(l_pin,0) = 0
    THEN
      o_err_code  :=  '180';
      RETURN;
    ELSE
      l_pin_status    :=  'NOT REDEEMED';
      o_err_msg       :=  'SUCCESS';
    END IF;
  ELSIF i_action = 'GET'
  THEN
    --
    byop_service_pkg.card_status( p_red_code    =>  l_pin,
                                  p_status      =>  l_pin_status,
                                  p_units       =>  l_units,
                                  p_days        =>  l_days,
                                  p_brand       =>  l_brand,
                                  p_part_type   =>  l_part_type,
                                  p_card_type   =>  l_card_type,
                                  p_out_code    =>  o_err_code,
                                  p_out_desc    =>  o_err_msg );
  ELSIF i_action  = 'VOID'
  THEN
    --
    etailer_service_pkg.p_void_pin (  i_pin                 =>  l_pin,
                                      o_post_void_status    =>  l_pin_status,
                                      o_err_code            =>  o_err_code,
                                      o_err_msg             =>  o_err_msg);
  END IF;
  --
  IF l_pin_status IS NULL
  THEN
    --
    byop_service_pkg.card_status( p_red_code    =>  l_pin,
                                  p_status      =>  l_pin_status,
                                  p_units       =>  l_units,
                                  p_days        =>  l_days,
                                  p_brand       =>  l_brand,
                                  p_part_type   =>  l_part_type,
                                  p_card_type   =>  l_card_type,
                                  p_out_code    =>  o_err_code,
                                  p_out_desc    =>  o_err_msg );

  END IF;
  --
  OPEN o_refcursor
  FOR  SELECT   l_pin                 AS  PIN,
                l_smp                 AS  SMP,
                l_pin_status          AS  PIN_STATUS
  FROM DUAL;
  --
EXCEPTION
WHEN OTHERS THEN
  o_err_code := '160';
  o_err_msg  := 'Failed in when others of soft pin actions ';
END p_soft_pin_actions;
--
END etailer_service_pkg;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/ETAILER_SERVICE_PKB.sql 	CR43162: 1.15
/