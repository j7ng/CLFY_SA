CREATE OR REPLACE PACKAGE BODY sa.SMARTPAY_ORDER_LOG_PKG
AS
PROCEDURE INSERT_ORDER_LOG ( i_sp_ord_log_hdr   IN smartpay_ord_log_hdr_rec_type,
                             i_sp_ord_log_dtl   IN smartpay_ord_log_dtl_rec_tab,
                             o_objid           OUT VARCHAR2,
                             o_error_num       OUT VARCHAR2,
                             o_error_msg       OUT VARCHAR2
                           )
IS
BEGIN

   o_objid := sa.sequ_smartpay_order_log_hdr.NEXTVAL;

   BEGIN
      INSERT
      INTO smartpay_order_log_hdr
        (
          objid              ,
          commerce_order_id  ,
          commerce_order_type,
          bus_org_id         ,
          request_source     ,
          client_id          ,
          amount             ,
          total_amount       ,
          decision           ,
          auth_request_id    ,
          merchant_ref_number,
          customer_firstname ,
          customer_lastname  ,
          customer_phone     ,
          customer_email     ,
          ship_address1      ,
          ship_address2      ,
          ship_city          ,
          ship_state         ,
          ship_zip           ,
          ship_country       ,
          response_code      ,
          response_message   ,
          insert_timestamp   ,
          update_timestamp
        )
      VALUES
        (
          o_objid                               ,
          i_sp_ord_log_hdr.commerce_order_id    ,
          i_sp_ord_log_hdr.commerce_order_type  ,
          i_sp_ord_log_hdr.bus_org_id           ,
          i_sp_ord_log_hdr.request_source       ,
          i_sp_ord_log_hdr.client_id            ,
          i_sp_ord_log_hdr.amount               ,
          i_sp_ord_log_hdr.total_amount         ,
          i_sp_ord_log_hdr.decision             ,
          i_sp_ord_log_hdr.auth_request_id      ,
          i_sp_ord_log_hdr.merchant_ref_number  ,
          i_sp_ord_log_hdr.customer_firstname   ,
          i_sp_ord_log_hdr.customer_lastname    ,
          i_sp_ord_log_hdr.customer_phone       ,
          i_sp_ord_log_hdr.customer_email       ,
          i_sp_ord_log_hdr.ship_address1        ,
          i_sp_ord_log_hdr.ship_address2        ,
          i_sp_ord_log_hdr.ship_city            ,
          i_sp_ord_log_hdr.ship_state           ,
          i_sp_ord_log_hdr.ship_zip             ,
          i_sp_ord_log_hdr.ship_country         ,
          i_sp_ord_log_hdr.response_code        ,
          i_sp_ord_log_hdr.response_message     ,
          SYSDATE                               ,
          SYSDATE
        );
   EXCEPTION
   WHEN OTHERS THEN
      o_error_num := '-1';
      o_error_msg := 'Error inserting into SMARTPAY_ORDER_LOG_HDR - ' || SQLERRM;
      RETURN;
   END;

   IF i_sp_ord_log_dtl IS NOT NULL
   THEN
      IF i_sp_ord_log_dtl.COUNT > 0
      THEN
        FOR i_count IN i_sp_ord_log_dtl.FIRST..i_sp_ord_log_dtl.LAST
        LOOP
          BEGIN
             INSERT
             INTO smartpay_order_log_dtl
               (
                 objid                        ,
                 group_id                     ,
                 esn                          ,
                 smp                          ,
                 sp_ord_log_dtl2sp_ord_log_hdr,
                 quantity                     ,
                 product_amount               ,
                 product_type                 ,
                 product_description          ,
                 merchant_product_sku
               )
             VALUES
               (
                 sa.sequ_smartpay_order_log_dtl.nextval        ,
                 i_sp_ord_log_dtl(i_count).group_id            ,
                 i_sp_ord_log_dtl(i_count).esn                 ,
                 i_sp_ord_log_dtl(i_count).smp                 ,
                 o_objid                                       , -- Header objid
                 i_sp_ord_log_dtl(i_count).quantity            ,
                 i_sp_ord_log_dtl(i_count).product_amount      ,
                 i_sp_ord_log_dtl(i_count).product_type        ,
                 i_sp_ord_log_dtl(i_count).product_description ,
                 i_sp_ord_log_dtl(i_count).merchant_product_sku
               );
          EXCEPTION
          WHEN OTHERS THEN
             o_error_num := '-2';
             o_error_msg := 'Error inserting into SMARTPAY_ORDER_LOG_DTL - ' || SQLERRM;
             RETURN;
          END;
        END LOOP;
      END IF; -- IF i_sp_ord_log_dtl.COUNT > 0
   END IF; -- IF i_sp_ord_log_dtl IS NOT NULL

   o_error_num := '0';
   o_error_msg := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  o_error_num := SQLCODE;
  o_error_msg := SQLERRM;
  RETURN;
END INSERT_ORDER_LOG;

PROCEDURE UPDATE_ORDER_LOG ( i_order_id         IN VARCHAR2,
                             i_fin_order_id     IN VARCHAR2,
                             i_order_type       IN VARCHAR2,
                             i_decision         IN VARCHAR2,
                             i_response_code    IN VARCHAR2,
                             i_response_msg     IN VARCHAR2,
                             o_error_num       OUT VARCHAR2,
                             o_error_msg       OUT VARCHAR2
                           )
IS
BEGIN

   --Update order id with actual order id when finance order id is used during insert
   IF i_fin_order_id IS NULL
   THEN
      UPDATE smartpay_order_log_hdr
        SET response_code    = i_response_code,
            response_message = i_response_msg,
            decision = i_decision,
            update_timestamp = SYSDATE
      WHERE commerce_order_id      = i_order_id
      AND   commerce_order_type    = i_order_type;
   ELSE
      UPDATE smartpay_order_log_hdr
        SET response_code    = i_response_code,
            response_message = i_response_msg,
            commerce_order_id = i_order_id,
            decision = i_decision,
            update_timestamp = SYSDATE
      WHERE commerce_order_id      = i_fin_order_id
      AND   commerce_order_type    = i_order_type;
   END iF;

   o_error_num := '0';
   o_error_msg := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  o_error_num := SQLCODE;
  o_error_msg := SQLERRM;
  RETURN;
END UPDATE_ORDER_LOG;

END SMARTPAY_ORDER_LOG_PKG;
/