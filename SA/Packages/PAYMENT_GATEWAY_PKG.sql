CREATE OR REPLACE PACKAGE sa.PAYMENT_GATEWAY_PKG
IS
  /*******************************************************************************************************
  * --$RCSfile: PAYMENT_GATEWAY_PKG.SQL,v $
  --$Revision: 1.4 $
  --$Author: nmuthukkaruppan $
  --$Date: 2016/04/21 18:08:09 $
  --$ $Log: PAYMENT_GATEWAY_PKG.SQL,v $
  --$ Revision 1.4  2016/04/21 18:08:09  nmuthukkaruppan
  --$ CR 38620 -  eBay Integration & Store Front - modifications
  --$
  --$ Revision 1.3  2016/04/21 18:04:27  nmuthukkaruppan
  --$ CR 38620: eBay Integration & Store Front
  --$
  --$ Revision 1.2  2016/01/19 16:22:36 smeganathan
  --$ CR33098 - LRP fixes
  * Description: This package includes procedures
  * that are required for the Payment Gateway Springform services
  *
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/

 PROCEDURE P_GET_PYMT_SOURCE_DETAILS(
    p_pymt_src_id IN NUMBER,
    out_rec OUT typ_pymt_src_dtls_rec,
    out_err_num out number,
    out_err_msg out VARCHAR2);

PROCEDURE P_WRITE_PYMT_AUTH_REQ_DATA(
      In_Org_Id    IN VARCHAR2,
      In_Brand     IN VARCHAR2,
      In_Language  IN VARCHAR2,
      In_Promocode IN VARCHAR2,
      in_purch_hdr IN purch_hdr_rec,
      In_ADDRESS   IN ADDRESS_REC,
      In_Purch_Dtl In Purch_Dtl_Tbl,
      IN_request_XML IN CLOB,
      Out_Purch_Hdr_Objid Out Number,
      Out_X_Payment_Objid Out Number,
      OUT_WEB_USER_ObjID OUT Number,
      Out_Error_Msg Out Varchar2,
      OUT_Error_num OUT NUMBER);

  PROCEDURE P_WRITE_PYMT_TRANS_REPLY_DATA(
      in_Purch_Hdr_Objid IN NUMBER,
      In_X_Payment_Objid In Number,
      in_Rqst_Type  IN VARCHAR2, -- AUTH, SETTLEMENT, CANCEL, REFUND
      In_X_Transaction_Id In Varchar2,
      In_Tf_Transaction_Id In Varchar2,
      IN_TRANS_STATUS IN NUMBER, --0 for success
      In_Trans_Msg In Varchar2,
      IN_response_XML IN CLOB,
      Out_Error_Msg Out Varchar2,
      OUT_Error_num OUT NUMBER);

 PROCEDURE P_WRITE_PYMT_TRANS_REQ_DATA(
      In_Tf_Rel_Trans_Id In Varchar2,
	    In_Rqst_Type  In Varchar2, -- SETTLEMENT, CANCEL, REFUND
      IN_request_XML IN CLOB,
      Out_Purch_Hdr_Objid Out Number,
      Out_X_Payment_Objid Out Number,
      OUT_WEB_USER_ObjID OUT Number,
      Out_Orderid Out Varchar2,
      Out_Trans_id Out Varchar2,
      OUT_pymt_src_id OUT number,
      Out_Error_Msg Out Varchar2,
      OUT_Error_num OUT NUMBER);
--
PROCEDURE p_getpaymentsource (
          In_Login_Name       IN  VARCHAR2,
          In_Bus_Org_Id       IN  VARCHAR2,
          In_Esn              IN  VARCHAR2,
          In_Min              IN  VARCHAR2,
          in_PYMT_SRC_TYPE    IN  VARCHAR2,
          OUT_tbl             OUT pymt_src_tbl,
          out_err_num         OUT NUMBER,
          out_err_msg         OUT VARCHAR2);
--
PROCEDURE P_FETCH_PYMT_DATA (
          In_Transaction_Id  IN  VARCHAR2,
          Out_X_Total_Amount  OUT NUMBER,
          Out_Error_Msg       OUT VARCHAR2,
          OUT_Error_num       OUT  NUMBER);
--
PROCEDURE P_WRITE_EBAY_PYMT_TRANS_REQ (
In_Transaction_Id    IN    VARCHAR2,
In_Rqst_Type          IN    VARCHAR2,
IN_request_XML        IN    CLOB,
Out_Purch_Hdr_Objid   OUT   NUMBER,
Out_X_Payment_Objid   OUT   NUMBER,
Out_Error_Msg         OUT   VARCHAR2,
OUT_Error_num         OUT   NUMBER
);

PROCEDURE P_WRITE_EBAY_PYMT_TRANS_REPLY
(
In_X_Payment_Objid    IN    NUMBER,
In_Rqst_Type          IN    VARCHAR2,
In_Tf_Transaction_Id  IN    VARCHAR2,
In_trans_status       IN    NUMBER,
In_Trans_Msg          IN    VARCHAR2,
In_response_XML       IN    CLOB,
Out_Error_Msg         OUT   VARCHAR2,
OUT_Error_num         OUT   NUMBER
);

END PAYMENT_GATEWAY_PKG;
/