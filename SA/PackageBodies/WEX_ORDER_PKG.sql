CREATE OR REPLACE PACKAGE BODY sa.WEX_ORDER_PKG
IS

/*************************************************************************************************************************************
  * $Revision: 1.8 $
  * $Author: abustos $
  * $Date: 2017/09/20 19:35:49 $
  * $Log: WEX_ORDER_PKG.sql,v $
  * Revision 1.8  2017/09/20 19:35:49  abustos
  * Update db link from ofstst -> ofsprd
  *
  * Revision 1.7  2017/09/18 21:18:58  abustos
  * Add item information when retrieving from open_orders
  *
  * Revision 1.6  2017/09/12 19:50:03  abustos
  * Removed p_min logic in get_order_info
  *
  * Revision 1.5  2017/08/31 15:25:59  abustos
  * Added Union to open_orders when passing order_num
  *
  * Revision 1.4  2017/08/30 16:02:14  abustos
  * New function get_wex_inventory to retrieve inv details on item_code
  *
  * Revision 1.3  2017/08/30 14:01:59  abustos
  * Extra check added to avoid duplicate records
  *
  * Revision 1.2  2017/08/25 14:10:59  abustos
  * Added show errors
  *
  * Revision 1.1  2017/08/17 23:33:27  abustos
  * WEX order pkg. Will be used to inbound tables from OFS as well as function to return information on WEX orders called by TAS
  *
  *************************************************************************************************************************************/

-- Table wex_order_shipping_details  -  TF.XXTF_BP_EX_DAILY_SHIPMENTS
PROCEDURE INBOUND_WEX_ORDER_SHIP_DTL ( op_result OUT NUMBER,
                                       op_msg    OUT VARCHAR2)
IS
  TYPE wex_ship_dtl_tab IS TABLE OF wex_order_shipping_details%ROWTYPE;
  wex_shipping_dtl_tab wex_ship_dtl_tab := wex_ship_dtl_tab();
BEGIN

  SELECT * BULK COLLECT INTO wex_shipping_dtl_tab FROM TF.XXTF_BP_EX_DAILY_SHIPMENTS@ofsprd;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE sa.wex_order_shipping_details';

  FORALL i IN wex_shipping_dtl_tab.first .. wex_shipping_dtl_tab.last
    INSERT INTO wex_order_shipping_details VALUES wex_shipping_dtl_tab(i);

  op_result := 0;
  op_msg    := 'Success';

EXCEPTION WHEN OTHERS
THEN
  op_result := - 999;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  DBMS_OUTPUT.PUT_LINE('FAILURE loading table wex_order_shipping_details');
END INBOUND_WEX_ORDER_SHIP_DTL;

-- Table wex_bp_inv_receipts  -  TF.XXTF_BP_INV_RECEIPTS
PROCEDURE INBOUND_WEX_INV_RECEIPTS ( op_result OUT NUMBER,
                                     op_msg    OUT VARCHAR2)
IS
  TYPE wex_inv_tab IS TABLE OF wex_bp_inv_receipts%ROWTYPE;
  wex_inventory_tab wex_inv_tab := wex_inv_tab();
BEGIN

  SELECT * BULK COLLECT INTO wex_inventory_tab FROM TF.XXTF_BP_INV_RECEIPTS@ofsprd;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE sa.wex_bp_inv_receipts';

  FORALL i IN wex_inventory_tab.first .. wex_inventory_tab.last
    INSERT INTO wex_bp_inv_receipts VALUES wex_inventory_tab(i);

  op_result := 0;
  op_msg    := 'Success';

EXCEPTION WHEN OTHERS
THEN
  op_result := - 999;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  DBMS_OUTPUT.PUT_LINE('FAILURE loading table wex_bp_inv_receipts');
END INBOUND_WEX_INV_RECEIPTS;

-- Table wex_bp_open_orders  -  TF.XXTF_BP_EX_OPEN_ORDERS
PROCEDURE INBOUND_WEX_OPEN_ORDERS ( op_result OUT NUMBER,
                                    op_msg    OUT VARCHAR2)
IS
  TYPE wex_open_tab IS TABLE OF wex_bp_open_orders%ROWTYPE;
  wex_bp_open_tab wex_open_tab := wex_open_tab();
BEGIN

  SELECT * BULK COLLECT INTO wex_bp_open_tab FROM TF.XXTF_BP_EX_OPEN_ORDERS@ofsprd;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE sa.wex_bp_open_orders';

  FORALL i IN wex_bp_open_tab.first .. wex_bp_open_tab.last
    INSERT INTO wex_bp_open_orders VALUES wex_bp_open_tab(i);

  op_result := 0;
  op_msg    := 'Success';

EXCEPTION WHEN OTHERS
THEN
  op_result := - 999;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  DBMS_OUTPUT.PUT_LINE('FAILURE loading table wex_bp_open_orders');
END INBOUND_WEX_OPEN_ORDERS;

-- Table wex_return_dispos_daily  -  TF.XXTF_RETRUNS_DISPOS_DAILY
PROCEDURE INBOUND_WEX_RETURN_ORDERS ( op_result OUT NUMBER,
                                      op_msg    OUT VARCHAR2)
IS
  TYPE wex_returns_tab IS TABLE OF wex_return_dispos_daily%ROWTYPE;
  wex_returns_daily_tab wex_returns_tab := wex_returns_tab();
BEGIN

  SELECT * BULK COLLECT INTO wex_returns_daily_tab FROM TF.XXTF_RETRUNS_DISPOS_DAILY@ofsprd;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE sa.wex_return_dispos_daily';

  FORALL i IN wex_returns_daily_tab.first .. wex_returns_daily_tab.last
    INSERT INTO wex_return_dispos_daily VALUES wex_returns_daily_tab(i);

  op_result := 0;
  op_msg    := 'Success';

EXCEPTION WHEN OTHERS
THEN
  op_result := - 999;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  DBMS_OUTPUT.PUT_LINE('FAILURE loading table wex_return_dispos_daily');
END INBOUND_WEX_RETURN_ORDERS;

-- Table wex_shipping_mtd  -  TF.XXTF_SHIP_TFX8_MTD
PROCEDURE INBOUND_WEX_SHIPPING_MTD ( op_result OUT NUMBER,
                                     op_msg    OUT VARCHAR2)
IS
  TYPE wex_ship_tab IS TABLE OF wex_shipping_mtd%ROWTYPE;
  wex_shipping_tab wex_ship_tab := wex_ship_tab();
BEGIN

  SELECT * BULK COLLECT INTO wex_shipping_tab FROM TF.XXTF_SHIP_TFX8_MTD@ofsprd;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE sa.wex_shipping_mtd';

  FORALL i IN wex_shipping_tab.first .. wex_shipping_tab.last
    INSERT INTO wex_shipping_mtd VALUES wex_shipping_tab(i);

  op_result := 0;
  op_msg    := 'Success';

EXCEPTION WHEN OTHERS
THEN
  op_result := - 999;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  DBMS_OUTPUT.PUT_LINE('FAILURE loading table wex_shipping_mtd');
END INBOUND_WEX_SHIPPING_MTD;

--
--Main Procedure: Used to process Inbound
--
PROCEDURE WEX_INBOUND_JOB ( op_result OUT NUMBER,
                            op_msg    OUT VARCHAR2)
IS
  l_result NUMBER;
  l_msg    VARCHAR2 (255) := 0;
BEGIN
  --Begin calling individual inbound procedures for Tables
  --
  BEGIN
    inbound_wex_order_ship_dtl ( l_result,
                                 l_msg);
    IF l_msg <> 'Success' THEN
      DBMS_OUTPUT.PUT_LINE('Error Inbounding WEX_ORDER_SHIPPING_DETAILS :' || l_msg);
    END IF;
  EXCEPTION WHEN OTHERS
  THEN
    op_result := - 999;
    op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
    DBMS_OUTPUT.PUT_LINE('Error calling inbound_wex_order_ship_dtl');
  END;
  --

  BEGIN
    inbound_wex_inv_receipts ( l_result,
                               l_msg);
    IF l_msg <> 'Success' THEN
      DBMS_OUTPUT.PUT_LINE('Error Inbounding wex_bp_inv_receipts :' || l_msg);
    END IF;
  EXCEPTION WHEN OTHERS
  THEN
    op_result := - 999;
    op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
    DBMS_OUTPUT.PUT_LINE('Error calling inbound_wex_inv_receipts');
  END;
  --

  BEGIN
    inbound_wex_open_orders ( l_result,
                              l_msg);
    IF l_msg <> 'Success' THEN
      DBMS_OUTPUT.PUT_LINE('Error Inbounding inbound_wex_open_orders :' || l_msg);
    END IF;
  EXCEPTION WHEN OTHERS
  THEN
    op_result := - 999;
    op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
    DBMS_OUTPUT.PUT_LINE('Error calling inbound_wex_open_orders');
  END;
  --

  BEGIN
    inbound_wex_return_orders ( l_result,
                                l_msg);
    IF l_msg <> 'Success' THEN
      DBMS_OUTPUT.PUT_LINE('Error Inbounding inbound_wex_return_orders :' || l_msg);
    END IF;
  EXCEPTION WHEN OTHERS
  THEN
    op_result := - 999;
    op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
    DBMS_OUTPUT.PUT_LINE('Error calling inbound_wex_return_orders');
  END;
  --

  BEGIN
    inbound_wex_shipping_mtd ( l_result,
                                l_msg);
    IF l_msg <> 'Success' THEN
      DBMS_OUTPUT.PUT_LINE('Error Inbounding inbound_wex_shipping_mtd :' || l_msg);
    END IF;
  EXCEPTION WHEN OTHERS
  THEN
    op_result := - 999;
    op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
    DBMS_OUTPUT.PUT_LINE('Error calling inbound_wex_shipping_mtd');
  END;
  --
  op_result := 0;
  op_msg    := 'Success';
EXCEPTION WHEN OTHERS
THEN
  op_result := - 999;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT INTO x_program_error_log
    ( x_source     ,
      x_error_code ,
      x_error_msg  ,
      x_date       ,
      x_description,
      x_severity
    )
  VALUES
    ( 'WEX_ORDER_INBOUND_PKG.wex_inbound_job' ,
      op_result                               ,
      op_msg                                  ,
      SYSDATE                                 ,
      'WEX Inbound Job could not be processed',
      NULL
    );
END WEX_INBOUND_JOB;


FUNCTION GET_WEX_ORDER_INFO ( p_esn        IN  VARCHAR2,
                              p_case_id    IN  VARCHAR2,
                              p_min        IN  VARCHAR2,
                              p_order_num  IN  VARCHAR2)
  RETURN get_wex_info_tab PIPELINED
IS
  get_wex_info_rslt get_wex_info_rec;
  l_esn VARCHAR2(30) := p_esn;

BEGIN

  IF (p_esn IS NULL AND p_case_id IS NULL AND p_min IS NULL AND p_order_num IS NULL)
  THEN
    DBMS_OUTPUT.PUT_LINE('At least one input parameter must be passed');
    RETURN;
  END IF;

  --Get ESN of MIN
  IF (p_min IS NOT NULL AND l_esn IS NULL)
  THEN
    SELECT pi_esn.part_serial_no
      INTO l_esn
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_min.part_serial_no = p_min
      AND  pi_min.x_domain       = 'LINES'
      AND  pi_esn.objid          = pi_min.part_to_esn2part_inst;
  END IF;

  -- Function will return based upon the first value passed and not process the rest.
  --
  IF l_esn IS NOT NULL
  THEN
    FOR wex_esn_rec IN
     (SELECT sd.creation_date                 received_date,
             tc.creation_time                 case_creation,
             elm.title                        case_status,
             NULL                             product_status,--Come from Open_orders
             NULL                             wh_queue_case, --Awaiting more information
             tc.modify_stmp                   aging_date,
             NULL                             airbill,
             sd.item_code                     item_code,
             mtd.class_to                     item_class,
             mtd.description                  item_description,
             NULL                             ship_status,   --Only necessary for Returns/Open Orders
             mtd.tracking_inf                 tracking_num,
             mtd.sales                        sale_price,
             lower(mtd.email_address)         ship_email,
             sd.order_date                    order_date,
             upper(mtd.ship_to)               ship_name,
             mtd.ship_city                    city,
             mtd.ship_st                      state,
             mtd.bp_order                     order_num
      FROM sa.table_case tc,
           sa.table_gbst_elm elm,
           wex_order_shipping_details sd,
           wex_shipping_mtd  mtd
      WHERE tc.casests2gbst_elm = elm.objid
        AND tc.id_number        = sd.ship_to_po
        AND mtd.bp_order        = sd.bp_order
        AND mtd.item_code       = sd.item_code
        AND tc.x_esn            = l_esn)
    LOOP
      get_wex_info_rslt.RECEIVED_DATE    := wex_esn_rec.RECEIVED_DATE;
      get_wex_info_rslt.CASE_CREATION    := wex_esn_rec.CASE_CREATION;
      get_wex_info_rslt.CASE_STATUS      := wex_esn_rec.CASE_STATUS;
      get_wex_info_rslt.PRODUCT_STATUS   := wex_esn_rec.PRODUCT_STATUS;
      get_wex_info_rslt.WH_QUEUE_CASE    := wex_esn_rec.WH_QUEUE_CASE;
      get_wex_info_rslt.AGING_DATE       := wex_esn_rec.AGING_DATE;
      get_wex_info_rslt.AIRBILL          := wex_esn_rec.AIRBILL;
      get_wex_info_rslt.ITEM_CODE        := wex_esn_rec.ITEM_CODE;
      get_wex_info_rslt.ITEM_CLASS       := wex_esn_rec.ITEM_CLASS;
      get_wex_info_rslt.ITEM_DESCRIPTION := wex_esn_rec.ITEM_DESCRIPTION;
      get_wex_info_rslt.SHIP_STATUS      := wex_esn_rec.SHIP_STATUS;
      get_wex_info_rslt.TRACKING_NUM     := wex_esn_rec.TRACKING_NUM;
      get_wex_info_rslt.SALE_PRICE       := wex_esn_rec.SALE_PRICE;
      get_wex_info_rslt.SHIP_EMAIL       := wex_esn_rec.SHIP_EMAIL;
      get_wex_info_rslt.ORDER_DATE       := wex_esn_rec.ORDER_DATE;
      get_wex_info_rslt.SHIP_NAME        := wex_esn_rec.SHIP_NAME;
      get_wex_info_rslt.CITY             := wex_esn_rec.CITY;
      get_wex_info_rslt.STATE            := wex_esn_rec.STATE;
      get_wex_info_rslt.ORDER_NUM        := wex_esn_rec.ORDER_NUM;

      pipe row (get_wex_info_rslt);
    END LOOP;
    RETURN; -- Exit once processed
  END IF;

  IF p_case_id IS NOT NULL
  THEN
    FOR wex_case_rec IN
      (SELECT mtd.creation_date                received_date,
              tc.creation_time                 case_creation,
              elm.title                        case_status,
              NULL                             product_status,
              NULL                             wh_queue_case, --NEED MORE INFO FROM Eli
              tc.modify_stmp                   aging_date,
              NULL                             airbill,
              mtd.item_code                    item_code,
              mtd.class_to                     item_class,
              mtd.description                  item_description,
              NULL                             ship_status,
              mtd.tracking_inf                 tracking_num,
              mtd.sales                        sale_price,
              lower(mtd.email_address)         ship_email,
              mtd.order_date                   order_date,
              upper(mtd.ship_to)               ship_name,
              mtd.ship_city                    city,
              mtd.ship_st                      state,
              mtd.bp_order                     order_num
      FROM sa.table_case tc,
           sa.table_gbst_elm elm,
           wex_order_shipping_details sd,
           wex_shipping_mtd  mtd
      WHERE tc.casests2gbst_elm = elm.objid
        AND tc.id_number        = sd.ship_to_po
        AND mtd.bp_order        = sd.bp_order
        AND mtd.item_code       = sd.item_code
        AND tc.id_number        = p_case_id)
    LOOP
      get_wex_info_rslt.RECEIVED_DATE    := wex_case_rec.RECEIVED_DATE;
      get_wex_info_rslt.CASE_CREATION    := wex_case_rec.CASE_CREATION;
      get_wex_info_rslt.CASE_STATUS      := wex_case_rec.CASE_STATUS;
      get_wex_info_rslt.PRODUCT_STATUS   := wex_case_rec.PRODUCT_STATUS;
      get_wex_info_rslt.WH_QUEUE_CASE    := wex_case_rec.WH_QUEUE_CASE;
      get_wex_info_rslt.AGING_DATE       := wex_case_rec.AGING_DATE;
      get_wex_info_rslt.AIRBILL          := wex_case_rec.AIRBILL;
      get_wex_info_rslt.ITEM_CODE        := wex_case_rec.ITEM_CODE;
      get_wex_info_rslt.ITEM_CLASS       := wex_case_rec.ITEM_CLASS;
      get_wex_info_rslt.ITEM_DESCRIPTION := wex_case_rec.ITEM_DESCRIPTION;
      get_wex_info_rslt.SHIP_STATUS      := wex_case_rec.SHIP_STATUS;
      get_wex_info_rslt.TRACKING_NUM     := wex_case_rec.TRACKING_NUM;
      get_wex_info_rslt.SALE_PRICE       := wex_case_rec.SALE_PRICE;
      get_wex_info_rslt.SHIP_EMAIL       := wex_case_rec.SHIP_EMAIL;
      get_wex_info_rslt.ORDER_DATE       := wex_case_rec.ORDER_DATE;
      get_wex_info_rslt.SHIP_NAME        := wex_case_rec.SHIP_NAME;
      get_wex_info_rslt.CITY             := wex_case_rec.CITY;
      get_wex_info_rslt.STATE            := wex_case_rec.STATE;
      get_wex_info_rslt.ORDER_NUM        := wex_case_rec.ORDER_NUM;

      pipe row (get_wex_info_rslt);
    END LOOP;
    RETURN;
  END IF;

  IF p_order_num IS NOT NULL
  THEN
    FOR wex_order_rec IN
      (SELECT   mtd.creation_date             received_date,    --wex_shipping_mtd
                NULL                          case_creation,    --no table_case
                NULL                          case_status,      --no table_case
                NULL                          product_status,   --Only for Open_orders
                NULL                          wh_queue_case,    --no table_case
                NULL                          aging_date,       --no table_case
                NULL                          airbill,          --per Business, NULL
                mtd.item_code                 item_code,
                mtd.class_to                  item_class,
                mtd.description               item_description,
                NULL                          ship_status,      --Only necessary for Returns/Open Orders
                mtd.tracking_inf              tracking_num,
                mtd.sales                     sale_price,
                lower(mtd.email_address)      ship_email,
                mtd.order_date                order_date,
                upper(mtd.ship_to)            ship_name,
                mtd.ship_city                 city,
                mtd.ship_st                   state,
                mtd.bp_order                  order_num
       FROM wex_shipping_mtd mtd
       WHERE mtd.bp_order   = p_order_num
    UNION
       SELECT   NULL                          received_date,    --wex_order_shipping_details
                NULL                          case_creation,    --no table_case
                NULL                          case_status,      --no table_case
                DECODE(SIGN(bko_qty),
                       1,'BACKORDER',NULL)    product_status,   --if col > 1 return BACKORDER
                NULL                          wh_queue_case,    --no table_case
                NULL                          aging_date,       --no table_case
                NULL                          airbill,
                oo.items                      item_code,
                inv.item_sub_class            item_class,
                inv.short_des                 item_description,
                DECODE(hold,'Y','HOLD',NULL)  ship_status,      --return HOLD based on flag
                NULL                          tracking_num,     --no tracking for open_orders
                NULL                          sale_price,       --no price for open_orders
                NULL                          ship_email,       --no email for open_orders
                oo.creation_date              order_date,
                upper(oo.ship_to_name)        ship_name,
                oo.city                       city,
                oo.state                      state,
                oo.bp_order                   order_num
       FROM wex_bp_open_orders oo,
           (SELECT DISTINCT item_code,short_des,item_sub_class
            FROM wex_bp_inv_receipts inv) inv
       WHERE oo.items    = inv.item_code(+)
         AND oo.bp_order = p_order_num)
    LOOP
      get_wex_info_rslt.RECEIVED_DATE    := wex_order_rec.RECEIVED_DATE;
      get_wex_info_rslt.CASE_CREATION    := wex_order_rec.CASE_CREATION;
      get_wex_info_rslt.CASE_STATUS      := wex_order_rec.CASE_STATUS;
      get_wex_info_rslt.PRODUCT_STATUS   := wex_order_rec.PRODUCT_STATUS;
      get_wex_info_rslt.WH_QUEUE_CASE    := wex_order_rec.WH_QUEUE_CASE;
      get_wex_info_rslt.AGING_DATE       := wex_order_rec.AGING_DATE;
      get_wex_info_rslt.AIRBILL          := wex_order_rec.AIRBILL;
      get_wex_info_rslt.ITEM_CODE        := wex_order_rec.ITEM_CODE;
      get_wex_info_rslt.ITEM_CLASS       := wex_order_rec.ITEM_CLASS;
      get_wex_info_rslt.ITEM_DESCRIPTION := wex_order_rec.ITEM_DESCRIPTION;
      get_wex_info_rslt.SHIP_STATUS      := wex_order_rec.SHIP_STATUS;
      get_wex_info_rslt.TRACKING_NUM     := wex_order_rec.TRACKING_NUM;
      get_wex_info_rslt.SALE_PRICE       := wex_order_rec.SALE_PRICE;
      get_wex_info_rslt.SHIP_EMAIL       := wex_order_rec.SHIP_EMAIL;
      get_wex_info_rslt.ORDER_DATE       := wex_order_rec.ORDER_DATE;
      get_wex_info_rslt.SHIP_NAME        := wex_order_rec.SHIP_NAME;
      get_wex_info_rslt.CITY             := wex_order_rec.CITY;
      get_wex_info_rslt.STATE            := wex_order_rec.STATE;
      get_wex_info_rslt.ORDER_NUM        := wex_order_rec.ORDER_NUM;

      pipe row (get_wex_info_rslt);
    END LOOP;
    RETURN;
  END IF;

EXCEPTION WHEN OTHERS
THEN
  DBMS_OUTPUT.PUT_LINE('ERROR retrieving information from the tables');
END GET_WEX_ORDER_INFO;


--
--New funtion to retrieve inventory details based on item_code from sa.wex_bp_inv_receipts
FUNCTION get_wex_inventory ( p_item_code  IN  VARCHAR2)
  RETURN get_wex_inventory_tab PIPELINED
IS
  get_wex_inv_rslt wex_bp_inv_receipts%ROWTYPE;
BEGIN

  IF p_item_code IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('Input Parameter not Passed');
    RETURN;
  END IF;

  BEGIN
    FOR wex_inventory_rec IN (SELECT *  FROM wex_bp_inv_receipts WHERE item_code = p_item_code)
    LOOP
      get_wex_inv_rslt := wex_inventory_rec;
      pipe row(get_wex_inv_rslt);
    END LOOP;
    RETURN;
  END;

EXCEPTION WHEN OTHERS
THEN
  DBMS_OUTPUT.PUT_LINE('ERROR retrieving information:' || SUBSTR (SQLERRM, 1, 100));
END get_wex_inventory;

END WEX_ORDER_PKG;
/