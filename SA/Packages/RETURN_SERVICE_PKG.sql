CREATE OR REPLACE PACKAGE sa.RETURN_SERVICE_PKG
IS
/*******************************************************************************************************
  * --$RCSfile: RETURN_SERVICE_PKG.sql,v $
  --$Revision: 1.17 $
  --$Author: sinturi $
  --$Date: 2017/11/24 18:03:47 $
  --$ $Log: RETURN_SERVICE_PKG.sql,v $
  --$ Revision 1.17  2017/11/24 18:03:47  sinturi
  --$ Added accessory validation proc
  --$
  --$ Revision 1.16  2017/11/22 03:00:02  sinturi
  --$ Added get_sim_status proc
  --$
  --$ Revision 1.13  2017/07/17 14:55:35  smeganathan
  --$ Code changes for Automated return of SIM and SOFTPINs
  --$
  --$ Revision 1.12  2016/06/27 15:04:58  nmuthukkaruppan
  --$ CR39912 - Changes merged with Ebay Production changes.
  --$
  --$ Revision 1.11  2016/04/29 19:21:22  nmuthukkaruppan
  --$ CR39912 - Straight Talk Commerce Soft Launch - Open Items
  --$
  --$ Revision 1.3  2015/12/11   nmuthukkaruppan
  --$ CR39912 - Populating bill_trans_ref_no in db during process_refund settlement call.
  --$
  --$ Revision 1.2  2015/10/20   nmuthukkaruppan
  --$ CR36886 - ST B2C Return Automation - Changes
  --$
  --$ Revision 1.1  2015/10/20  nmuthukkaruppan
  --$ CR33430 - ST B2C Return Automation -  Initial Version
  * Description: This package is mainly for automating the Return process for B2C orders for Straight Talk, Ebay Integration
  * This package has five procedures is_tracfone, log_returntransaction, get_pin_status, process_refund, Void_PIN
  *
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
-- Check if ESN/SMP belongs to Tracfone
PROCEDURE is_tracfone(
    In_Item             IN  RETURN_ITEM_TBL ,
    In_Order_id         IN  VARCHAR2,
    In_Order_Type       IN  VARCHAR2,
    In_RMA_Id           IN  VARCHAR2,
    In_Stage            IN  VARCHAR2,
    Out_Item            OUT RETURN_ITEM_TBL,
    Out_Err_Num         OUT NUMBER,
    Out_Err_Msg         OUT VARCHAR2,
    Out_Warn_Msg        OUT VARCHAR2);

-- To Log the ST B2C Return transactions
PROCEDURE log_returntransaction(
    In_Order_id                 IN  VARCHAR2,
    In_RMA_Id                   IN  VARCHAR2,
    In_Request_Payload          IN  CLOB  ,
    In_Return_Stage_code        IN  VARCHAR2,
    In_Return_Status_code       IN  VARCHAR2,
    In_Response_Payload         IN  VARCHAR2,
    In_Retrigger_stage          IN  VARCHAR2,
    In_Comments                 IN  VARCHAR2,
    In_Refund_Payload           IN  CLOB,
    In_Refund_Stage_code        IN  VARCHAR2,
    In_Refund_Status_code       IN  VARCHAR2,
    In_Refund_Resp_Payload      IN  CLOB,
    In_Returns_Dtl              IN  RETURN_ITEM_TBL,
    Out_Err_Num                 OUT NUMBER,
    Out_Err_Msg                 OUT VARCHAR2);

-- To Get the status of the PIN
PROCEDURE get_pin_status(
    In_Order_id         IN  VARCHAR2,
    In_RMA_Id           IN  VARCHAR2,
    In_Order_Type       IN  VARCHAR2,
    In_PIN_Status       IN  REFUND_TBL,
    Out_PIN_Status      OUT REFUND_TBL,
    Out_Err_Num         OUT NUMBER,
    Out_Err_Msg         OUT VARCHAR2,
    Out_Warn_Msg        OUT VARCHAR2);

-- To Calculate and Process the refund for ST B2C
PROCEDURE process_refund(
    In_Order_id              IN  VARCHAR2,
    In_RMA_Id                IN  VARCHAR2,
    In_RefundItem            IN  REFUND_TBL,
    IN_ICS_RCODE             IN  x_biz_purch_hdr.X_ICS_RCODE%TYPE,
    IN_ICS_RFLAG             IN  x_biz_purch_hdr.X_ICS_RFLAG%TYPE,
    IN_ICS_RMSG              IN  x_biz_purch_hdr.X_ICS_RMSG%TYPE,
    IN_BILL_RCODE            IN  x_biz_purch_hdr.X_BILL_RCODE%TYPE,
    IN_BILL_RFLAG            IN  x_biz_purch_hdr.X_BILL_RFLAG%TYPE,
    IN_BILL_RMSG             IN  x_biz_purch_hdr.X_BILL_RMSG%TYPE,
    IN_AUTH_REQUEST_ID       IN  x_biz_purch_hdr.X_AUTH_REQUEST_ID %TYPE,
    In_bill_trans_ref_no     IN  x_biz_purch_hdr.x_bill_trans_ref_no%TYPE,
    In_refundsettlement_flag IN  VARCHAR2,
    Out_Objid                OUT NUMBER,
    Out_ICSApplication       OUT VARCHAR2,
    Out_FirstName            OUT VARCHAR2,
    Out_LastName             OUT VARCHAR2,
    Out_Ship_Address1        OUT VARCHAR2,
    Out_Ship_Address2        OUT VARCHAR2,
    Out_Ship_Zip             OUT VARCHAR2,
    Out_Ship_city            OUT VARCHAR2,
    Out_Ship_Country         OUT VARCHAR2,
    Out_Ship_State           OUT VARCHAR2,
    Out_AuthRequestId        OUT VARCHAR2,
    Out_MerchantId           OUT VARCHAR2,
    Out_MerchantRefNumber    OUT  VARCHAR2,
    Out_refundItem           OUT REFUND_TBL,
    Out_Stax_Tot             OUT NUMBER,
    Out_E911_Tot             OUT NUMBER,
    Out_RCRF_Tot             OUT NUMBER,
    Out_USF_Tot              OUT NUMBER,
    Out_Tax_Tot              OUT NUMBER,
    Out_Total_Refund         OUT NUMBER,
    Out_Err_Num              OUT NUMBER,
    Out_Err_Msg              OUT VARCHAR2,
    Out_Warn_Msg             OUT VARCHAR2);

--Overloaded for Ebay Integration
PROCEDURE process_refund(
    In_Order_id              IN  VARCHAR2,
    In_RMA_Id                IN  VARCHAR2,
    In_Rqst_Source           IN  VARCHAR2,   --TAS/OFS
    In_Partner_id            IN  VARCHAR2,   --EBAY
    In_RefundItem            IN  REFUND_TBL,
    IN_ICS_RCODE             IN  x_biz_purch_hdr.X_ICS_RCODE%TYPE,
    IN_ICS_RFLAG             IN  x_biz_purch_hdr.X_ICS_RFLAG%TYPE,
    IN_ICS_RMSG              IN  x_biz_purch_hdr.X_ICS_RMSG%TYPE,
    IN_BILL_RCODE            IN  x_biz_purch_hdr.X_BILL_RCODE%TYPE,
    IN_BILL_RFLAG            IN  x_biz_purch_hdr.X_BILL_RFLAG%TYPE,
    IN_BILL_RMSG             IN  x_biz_purch_hdr.X_BILL_RMSG%TYPE,
    In_Request_id            IN  x_biz_purch_hdr.X_REQUEST_ID%TYPE, --Ebay Return id will be passed here.
    IN_AUTH_REQUEST_ID       IN  x_biz_purch_hdr.X_AUTH_REQUEST_ID%TYPE,
    In_refundsettlement_flag IN  VARCHAR2,
    Out_Objid                OUT NUMBER,
    Out_ICSApplication       OUT VARCHAR2,
    Out_FirstName            OUT VARCHAR2,
    Out_LastName             OUT VARCHAR2,
    Out_Ship_Address1        OUT VARCHAR2,
    Out_Ship_Address2        OUT VARCHAR2,
    Out_Ship_Zip             OUT VARCHAR2,
    Out_Ship_city            OUT VARCHAR2,
    Out_Ship_Country         OUT VARCHAR2,
    Out_Ship_State           OUT VARCHAR2,
    Out_AuthRequestId        OUT VARCHAR2,
    Out_MerchantId           OUT VARCHAR2,
    Out_MerchantRefNumber    OUT  VARCHAR2,
    Out_refundItem           OUT REFUND_TBL,
    Out_Stax_Tot             OUT NUMBER,
    Out_E911_Tot             OUT NUMBER,
    Out_RCRF_Tot             OUT NUMBER,
    Out_USF_Tot              OUT NUMBER,
    Out_Tax_Tot              OUT NUMBER,
    Out_Total_Refund         OUT NUMBER,
    Out_Err_Num              OUT NUMBER,
    Out_Err_Msg              OUT VARCHAR2,
    Out_Warn_Msg             OUT VARCHAR2);

  --To Void the PIN
PROCEDURE Void_PIN(
    In_Order_id          IN  VARCHAR2,
    In_RMA_id            IN  VARCHAR2,
    In_Order_Type        IN  VARCHAR2,
    In_VoidItem          IN  REFUND_TBL,
    In_VoidStatus_code   IN  VARCHAR2  default '44',
    Out_VoidItem         OUT REFUND_TBL,
    Out_Err_Num          OUT NUMBER,
    Out_Err_Msg          OUT VARCHAR2,
    Out_Warn_Msg         OUT VARCHAR2);

-- CR51737 Changes new procedure to get smp, part num and esn based on OrderID and SIM
PROCEDURE get_smp_details ( i_order_id        IN      VARCHAR2,
                            io_sim            IN OUT  VARCHAR2,
                            io_esn            IN OUT  VARCHAR2,
                            o_smp             OUT     VARCHAR2,
                            o_smp_partnum     OUT     VARCHAR2,
                            o_smp_unitprice   OUT     NUMBER,
                            o_err_code        OUT     VARCHAR2,
                            o_err_msg         OUT     VARCHAR2);
-- CR54805 Get sim status
-- To Get the status of the SIM
PROCEDURE get_sim_status( in_order_id         IN  VARCHAR2,
                          in_rma_id           IN  VARCHAR2,
                          in_order_type       IN  VARCHAR2,
                          in_sim_status       IN  REFUND_TBL,
                          out_sim_status      OUT REFUND_TBL,
                          out_err_num         OUT NUMBER,
                          out_err_msg         OUT VARCHAR2,
                          out_warn_msg        OUT VARCHAR2 );
-- CR54805 This procedure will check the accessory validation .
PROCEDURE  accessory_validation_check (in_order_id         IN  VARCHAR2,
                                       in_part_number      IN  VARCHAR2,
                                       in_quantity         IN  NUMBER,
                                       out_err_num         OUT NUMBER,
                                       out_err_msg         OUT VARCHAR2);
END RETURN_SERVICE_PKG;
/