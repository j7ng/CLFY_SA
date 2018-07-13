CREATE OR REPLACE PACKAGE sa.SMARTPAY_ORDER_LOG_PKG
AS
--Procedure to log SmartPay Order
PROCEDURE INSERT_ORDER_LOG ( i_sp_ord_log_hdr   IN smartpay_ord_log_hdr_rec_type,
                             i_sp_ord_log_dtl   IN smartpay_ord_log_dtl_rec_tab,
                             o_objid           OUT VARCHAR2,
                             o_error_num       OUT VARCHAR2,
                             o_error_msg       OUT VARCHAR2
                           );

--Procedure to update SmartPay Order response
PROCEDURE UPDATE_ORDER_LOG ( i_order_id         IN VARCHAR2,
                             i_fin_order_id     IN VARCHAR2,
                             i_order_type       IN VARCHAR2,
                             i_decision         IN VARCHAR2,
                             i_response_code    IN VARCHAR2,
                             i_response_msg     IN VARCHAR2,
                             o_error_num       OUT VARCHAR2,
                             o_error_msg       OUT VARCHAR2
                           );
END SMARTPAY_ORDER_LOG_PKG;
/