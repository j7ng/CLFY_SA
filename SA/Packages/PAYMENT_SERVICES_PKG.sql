CREATE OR REPLACE PACKAGE sa.PAYMENT_SERVICES_PKG
IS
 /*******************************************************************************************************
 * --$RCSfile: PAYMENT_SERVICES_PKG.sql,v $
 --$Revision: 1.55 $
 --$Author: tbaney $
 --$Date: 2018/04/16 19:34:16 $
 --$ $Log: PAYMENT_SERVICES_PKG.sql,v $
 --$ Revision 1.55  2018/04/16 19:34:16  tbaney
 --$ CR57737_artSOA_Fetching_inactive_CC_at_the_time_of_Auto_Refill_payment_for_SM_WFM
 --$
 --$ Revision 1.54  2018/01/10 21:45:34  smacha
 --$ Merged to Prod version.
 --$
 --$ Revision 1.52  2018/01/04 22:55:59  mshah
 --$ CR53474 - Net10 Business ACH Data club real time processing.
 --$
 --$ Revision 1.49  2017/12/07 14:04:35  skambhammettu
 --$ cr53217--New procedures
 --$
 --$ Revision 1.48  2017/12/05 02:50:42  sgangineni
 --$ Merging code with production - Commiting on behelf Sagar Inturi
 --$
 --$ Revision 1.47  2017/10/11 18:10:56  sinturi
 --$ Added payment details proc
 --$
 --$ Revision 1.41  2017/10/03 21:42:53  sinturi
 --$ Adding related proc to fetch the payment details
 --$
 --$ Revision 1.39  2017/10/10 20:30:57  sinturi
 --$ CR49058 Adding related proc to fetch the payment details
 --$
 --$ Revision 1.39  2017/09/22 20:30:57  skambhammettu
 --$ CR53217
 --$
 --$ Revision 1.36  2017/07/31 19:17:04  sraman
 --$ CR52703 WFM TAS WEB a?? Credit Card cannot be deleted from Payment Purchase History after removed
 --$
 --$ Revision 1.34  2017/07/18 22:05:30  tpathare
 --$ 52164 - Fix for country column NULL in table_address
 --$
 --$ Revision 1.30  2017/02/04 22:18:47  aganesan
 --$ CR47564 New procedure added to add payment based on ESN
 --$
 --$ Revision 1.29  2017/01/20 03:33:39  aganesan
 --$ CR47564 WFM business validation changes
 --$
 --$ Revision 1.28  2017/01/18 20:20:00  aganesan
 --$ CR47564 - WFM changes merged with CR46581 Go Smart production release version
 --$
 --$ Revision 1.26  2016/10/28 20:44:51  smeganathan
 --$ CR43524 made sp_ivr_insert_order_info public
 --$
 --$ Revision 1.25  2016/08/03 17:28:57  smeganathan
 --$ CR43524 Changes for IVR Tracfone
 --$
 --$ Revision 1.24  2016/06/07 16:12:07  smeganathan
 --$ CR43162 changed p_update_smp added new parameter i_pin
 --$
 --$ Revision 1.23  2016/06/02 15:54:05  smeganathan
 --$ added new proc p_update_smp
 --$
 --$ Revision 1.21 2015/11/28 04:44:08 nmuthukkaruppan
 --$ CR36886 - Changes to incorporate ST B2C - SMART PAY requirements
 --$
 --$ Revision 1.13 2015/02/13 20:42:38 ahabeeb
 --$ CR28870
 --$
 --$ Revision 1.12 2014/07/24 13:31:45 cpannala
 --$ CR29771 paraeter type change for validate settle auth id
 --$
 --$ Revision 1.11 2014/06/17 21:54:32 ahabeeb
 --$ changes to billing hist signature
 --$ Revision 1.1 2013/12/05 16:22:36 cpannala
 --$ CR22623 - B2B Initiative
 * Description: This package includes the five procedures
 * getpaymentsource, getpaymentsourcedetails, addpaymentsource, updatepaymentsource, removepaymentsource and also the Enrollment Services.
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
PROCEDURE Getpaymentsource(
 In_Login_Name IN VARCHAR2,
 In_Bus_Org_Id IN VARCHAR2,
 In_Esn IN VARCHAR2,
 In_Min IN VARCHAR2,
 in_PYMT_SRC_TYPE IN VARCHAR2,
 OUT_tbl OUT pymt_src_tbl,
 Out_Err_Num Out Number,
 Out_Err_Msg OUT VARCHAR2);
 -----------------------------------------------------------------------------------------------------
PROCEDURE getpaymentsourcedetails(
 p_pymt_src_id IN NUMBER,
 out_rec OUT typ_pymt_src_dtls_rec,
 out_err_num out number,
 out_err_msg out VARCHAR2);
 ---------------------------------------------------------------------
 procedure addpaymentsource(
 p_login_name in varchar2,
 p_bus_org in varchar2,
 P_ESN IN VARCHAR2,
 P_REC IN TYP_PYMT_SRC_DTLS_REC,
 OP_PYMT_SRC_ID OUT VARCHAR2,
 OP_ERR_NUM OUT NUMBER,
 op_ERR_MSG OUT VARCHAR2);
 ---------------------------------------------------------------
 PROCEDURE updatepaymentsource(
 P_LOGIN_NAME IN VARCHAR2,
 P_bus_org_id IN VARCHAR2,
 P_ESN IN VARCHAR2,
 P_REC IN TYP_PYMT_SRC_DTLS_REC,
 OP_PYMT_SRC_ID OUT VARCHAR2,
 OP_ERR_NUM OUT NUMBER,
 op_ERR_MSG OUT VARCHAR2);
 ---------------------------------------------------------------
 PROCEDURE removePaymentSource(
 P_LOGIN_NAME IN VARCHAR2 DEFAULT NULL, --Added default value to NULL for CR47564-WFM
 P_bus_org_id IN VARCHAR2,
 P_ESN IN VARCHAR2 DEFAULT NULL,--Added default value to NULL for CR47564-WFM
 P_MIN IN VARCHAR2 DEFAULT NULL,--Added default value to NULL for CR47564-WFM
 P_PYMT_SRC_ID IN OUT NUMBER,
 OUT_ERR_NUM OUT NUMBER,
 OUT_ERR_MSG OUT VARCHAR2);
 ---------------------------------------------------------------

 PROCEDURE getbillinghistory(
 in_login_name IN Table_Web_User.Login_Name%type,
 in_bus_org IN VARCHAR2,
 in_esn IN table_part_inst.part_serial_no%TYPE,
 in_min IN table_site_part.x_min%TYPE,
 in_phone_nick_name IN table_x_contact_part_inst.x_esn_nick_name%TYPE DEFAULT NULL,
 in_org_name IN table_site.s_name%type DEFAULT NULL,
 in_org_id in Table_Site.X_Commerce_Id%type DEFAULT NULL,
 in_buyer_id in Table_Web_User.Login_Name%type DEFAULT NULL,
 in_start_date IN DATE DEFAULT NULL,
 in_end_date IN DATE DEFAULT NULL,
 in_low_amt IN x_program_purch_hdr.x_bill_amount%TYPE,
 in_high_amt IN x_program_purch_hdr.x_bill_amount%TYPE,
 in_start_idx IN BINARY_INTEGER DEFAULT 0,
 in_max_rec_number IN NUMBER DEFAULT 100,
 in_order_by_field IN VARCHAR2 DEFAULT NULL,
 in_order_direction IN VARCHAR2 DEFAULT 'ASC',
 out_bill_hist OUT typ_bill_hist_tbl,
 OUT_ERR_NUM OUT NUMBER,
 OUT_ERR_MSG OUT VARCHAR2);
 ---------------------------------------------------------------
 PROCEDURE SetRecurringPaymentsource(
 in_esn IN table_part_inst.part_serial_no%TYPE,
 IN_MIN IN TABLE_SITE_PART.X_MIN%TYPE,
 in_plan_id IN x_program_parameters.objid%TYPE,
 in_payment_source_id IN x_payment_source.objid%TYPE ,
 out_err_num OUT NUMBER,
 OUT_ERR_MSG OUT VARCHAR2);
 ---------------------------------------------------------------
 PROCEDURE Inserts_Purch(
 In_Org_Id IN VARCHAR2,
 In_Brand IN VARCHAR2,
 In_Language IN VARCHAR2,
 In_Promocode IN VARCHAR2,
 in_purch_hdr IN purch_hdr_rec,
 In_ADDRESS IN ADDRESS_REC,
 IN_PURCH_DTL IN BIZ_PURCH_DTL_TBL, --Table type changed to include new columns for SmartPay integration CR33430 on 08/01/2015
 Out_Purch_Hdr_Objid OUT NUMBER,
 OUT_MERCHANT_REF_NUMBER OUT VARCHAR2,
 OUT_MERCHANT_ID OUT VARCHAR2,
 OUT_ERROR_MSG OUT VARCHAR2,
 OUT_Error_num OUT NUMBER);
 --------------------

 PROCEDURE UPDATE_PURCH(
 in_hdr_objid in number,
 IN_C_ORDERID IN VARCHAR2,
 IN_MERCHANT_REF_NUMBER IN VARCHAR2,
 IN_AUTH_REQUEST_ID IN VARCHAR2,
 IN_AUTH_CODE IN VARCHAR2,
 IN_ICS_RCODE IN VARCHAR2,
 IN_ICS_RFLAG IN VARCHAR2,
 IN_ICS_RMSG IN VARCHAR2,
 IN_REQUEST_ID IN VARCHAR2,
 IN_AUTH_REQUEST_TOKEN IN VARCHAR2,
 IN_AUTH_AVS IN VARCHAR2,
 IN_AUTH_RESPONSE IN VARCHAR2,
 IN_AUTH_TIME IN VARCHAR2,
 IN_AUTH_RCODE IN VARCHAR2,
 IN_AUTH_RFLAG IN VARCHAR2,
 IN_AUTH_RMSG IN VARCHAR2,
 IN_BILL_REQUEST_TIME IN VARCHAR2,
 IN_BILL_RCODE IN VARCHAR2,
 IN_BILL_RFLAG IN VARCHAR2,
 IN_BILL_RMSG IN VARCHAR2,
 IN_BILL_TRANS_REF_NO IN VARCHAR2,
 IN_SCORE_RCODE IN VARCHAR2,
 IN_SCORE_RFLAG IN VARCHAR2,
 IN_SCORE_RMSG IN VARCHAR2,
 IN_STATUS IN VARCHAR2,
 in_bill_amount IN NUMBER,
 IN_PROCESS_DATE IN DATE,
 OUT_Error_Msg OUT VARCHAR2,
 out_error_num out number );

 PROCEDURE validate_settle_authid(
 in_authid IN x_biz_purch_hdr.x_auth_request_id%type,
 out_error_msg OUT varchar2,
 out_status OUT varchar2,
 out_code OUT number,
 out_objid OUT x_biz_purch_hdr.objid%type,
 out_orderid OUT x_biz_purch_hdr.c_orderid%type,
 out_merchant_id OUT x_biz_purch_hdr.x_merchant_id%type,
 out_merchant_ref_number OUT x_biz_purch_hdr.x_merchant_ref_number%type,
 out_customer_ipaddress OUT x_biz_purch_hdr.x_customer_ipaddress%type,
 out_amount OUT x_biz_purch_hdr.X_Auth_Amount%type,
 out_rqst_type OUT x_biz_purch_hdr.x_rqst_type%type,
 out_bill_trans_ref_no OUT x_biz_purch_hdr.x_bill_trans_ref_no%TYPE
 );

--Overloaded for Smartpay integration CR33430 on 08/01/2015
 PROCEDURE validate_settle_authid(
 in_authid IN x_biz_purch_hdr.x_auth_request_id%type,
 out_error_msg OUT varchar2,
 out_status OUT varchar2,
 out_code OUT number,
 out_purch_dtl OUT BIZ_PURCH_DTL_TBL,
 out_address_rec OUT ADDR_REC,
 out_application_key OUT table_x_altpymtsource.x_application_key%type,
 out_objid OUT x_biz_purch_hdr.objid%type,
 out_orderid OUT x_biz_purch_hdr.c_orderid%type,
 out_merchant_id OUT x_biz_purch_hdr.x_merchant_id%type,
 out_merchant_ref_number OUT x_biz_purch_hdr.x_merchant_ref_number%type,
 out_customer_ipaddress OUT x_biz_purch_hdr.x_customer_ipaddress%type,
 out_amount OUT x_biz_purch_hdr.x_amount%type,
 out_tax_amount OUT x_biz_purch_hdr.x_tax_amount%type,
 out_auth_amount OUT x_biz_purch_hdr.X_Auth_Amount%type,
 out_rqst_type OUT x_biz_purch_hdr.x_rqst_type%type,
 out_bill_trans_ref_no OUT x_biz_purch_hdr.x_bill_trans_ref_no%TYPE,
 out_freight_amount OUT X_BIZ_PURCH_HDR.FREIGHT_AMOUNT%TYPE
 );

 PROCEDURE update_settlmnt_rec(
 in_objid IN x_biz_purch_hdr.objid%type,
 in_authid IN x_biz_purch_hdr.x_auth_request_id%type,
 in_pymt_source_type IN x_biz_purch_hdr.x_rqst_type%type,
 in_ics_rcode IN x_biz_purch_hdr.x_ics_rcode%type,
 in_ics_rflag IN x_biz_purch_hdr.x_ics_rflag%type,
 in_ics_rmsg IN x_biz_purch_hdr.x_ics_rmsg%type,
 in_bill_request_time IN x_biz_purch_hdr.x_bill_request_time%type,
 in_bill_rcode IN x_biz_purch_hdr.x_bill_rcode%type,
 in_bill_rflag IN x_biz_purch_hdr.x_bill_rflag%type,
 in_bill_rmsg IN x_biz_purch_hdr.x_bill_rmsg%type,
 inout_bill_trans_ref_no IN OUT x_biz_purch_hdr.x_bill_trans_ref_no%type,
 in_bill_amount IN x_biz_purch_hdr.x_bill_amount%type,
 in_auth_rcode IN x_biz_purch_hdr.X_AUTH_RCODE%type,
 in_auth_rflag IN x_biz_purch_hdr.X_AUTH_RFLAG%type,
 in_auth_rmsg IN x_biz_purch_hdr.X_AUTH_RMSG%type,
 in_auth_avs IN x_biz_purch_hdr.X_AUTH_AVS%type,
 in_auth_response IN x_biz_purch_hdr.X_AUTH_RESPONSE%type,
 in_auth_time IN x_biz_purch_hdr.X_AUTH_TIME%type,
 in_auth_code IN x_biz_purch_hdr.X_AUTH_CODE%type,
 out_error_msg OUT varchar2,
 out_status OUT varchar2,
 out_code OUT number
 );
 PROCEDURE get_expired_auth_dtls(
 in_authid IN VARCHAR2,
 out_hdr_rec OUT purch_hdr_rec_full,
 out_dtls_result_set OUT purch_dtl_tbl
 );
  -- CR42257 changes new procedure to update smp value for etailer
  PROCEDURE p_update_smp( i_biz_hdr_objid       IN    VARCHAR2,
                          i_pin                 IN    VARCHAR2,
                          i_smp                 IN    VARCHAR2,
                          o_error_code          OUT   VARCHAR2,
                          o_error_msg           OUT   VARCHAR2);
  -- CR43524 New procedure to check whether scoring is required
  PROCEDURE p_check_score ( i_esn               IN    VARCHAR2,
                            i_payment_src_id    IN    VARCHAR2,
                            i_channel           IN    VARCHAR2,
                            i_brand             IN    VARCHAR2,
                            i_source            IN    VARCHAR2,
                            o_cc_scoring_reqd   OUT   VARCHAR2,
                            o_error_code        OUT   VARCHAR2,
                            o_error_msg         OUT   VARCHAR2);
  -- CR43524  made this procedure public
  PROCEDURE  sp_ivr_insert_order_info(i_auth_request_id  IN   VARCHAR2,
                                    o_err_msg          OUT  VARCHAR2,
                                    o_err_code         OUT  NUMBER
                                    );

  -- CR52164  made this procedure public
PROCEDURE update_customer_address(i_payment_source_rec IN  sa.typ_pymt_src_dtls_rec,
                                  o_response           OUT VARCHAR2);
--
--CR46902 WFM changes --Start
procedure addpaymentsource(p_esn               IN  VARCHAR2             ,
                           p_bus_org           IN  VARCHAR2             ,
                           p_esn_contact_objid IN NUMBER                ,
                           p_rec               IN  TYP_PYMT_SRC_DTLS_REC,
                           op_pymt_src_id      OUT VARCHAR2             ,
                           op_err_num          OUT NUMBER               ,
                           op_err_msg          OUT VARCHAR2
						   );
--
 PROCEDURE addpaymentsource(i_esn                        IN VARCHAR2 DEFAULT NULL      ,
                            i_min                        IN VARCHAR2 DEFAULT NULL      ,
							i_login_name                 IN VARCHAR2 DEFAULT NULL      ,
							i_bus_org                    IN VARCHAR2                   ,
							i_payment_source_detail_rec  IN payment_source_detail_type ,
							o_payment_source_id          OUT VARCHAR2                  ,
							o_err_num                    OUT NUMBER                    ,
							o_err_msg                    OUT VARCHAR2
							);
--
 PROCEDURE updatepaymentsource(i_login_name                IN VARCHAR2 DEFAULT NULL      ,
							   i_bus_org_id                IN VARCHAR2                   ,
							   i_esn                       IN VARCHAR2 DEFAULT NULL      ,
							   i_min                       IN VARCHAR2 DEFAULT NULL      ,
							   i_payment_source_detail_rec IN payment_source_detail_type ,
							   o_payment_source_id         OUT VARCHAR2                  ,
							   o_err_num                   OUT NUMBER                    ,
							   o_err_msg                   OUT VARCHAR2
							   );
--
PROCEDURE Getpaymentsource(i_login_name                 IN VARCHAR2 DEFAULT NULL     ,
						   i_bus_org_id                 IN VARCHAR2                  ,
						   i_esn                        IN VARCHAR2 DEFAULT NULL     ,
						   i_min                        IN VARCHAR2 DEFAULT NULL     ,
						   o_payment_source_detail_tbl  OUT payment_source_detail_tab,
						   o_err_num                    OUT NUMBER                   ,
						   o_err_msg                    OUT VARCHAR2
						   );
--
PROCEDURE getpaymentsourcehistory(io_payment_source_tbl  IN OUT  payment_source_detail_tab,
							      o_err_num              OUT NUMBER                       ,
							      o_err_msg              OUT VARCHAR2
							      );
--CR46902 WFM changes --End

--CR 52703 changes starts here
PROCEDURE getpaymentsourcedetails_hist ( p_pymt_src_id              IN  NUMBER                ,
                                         out_rec                    OUT typ_pymt_src_dtls_rec ,
                                         out_err_num                OUT NUMBER                ,
                                         out_err_msg                OUT VARCHAR2              ,
                                         i_payment_source_status    IN  VARCHAR2 DEFAULT NULL );  -- CR57737_artSOA_Fetching_inactive_CC_at_the_time_of_Auto_Refill_payment_for_SM_WFM

--CR 52703 changes ends here


--CR51907 WARP Auto pay --Start
PROCEDURE upsert_payment_details_staging(io_payment_detail_id IN OUT  VARCHAR2,
                                         i_payment_details   IN  XMLTYPE ,
                                         o_response          OUT VARCHAR2
					);
--
PROCEDURE delete_payment_details_staging(i_payment_detail_id IN  VARCHAR2,
                                         o_response          OUT VARCHAR2
                                         );
--
PROCEDURE get_payment_details_staging(i_payment_detail_id IN  VARCHAR2,
                                      o_payment_details   OUT  XMLTYPE,
                                      o_response          OUT VARCHAR2
                                     );
--CR51907 WARP Auto pay --End
--CR49058 Adding get_paymentsrc_by_vass_id proc to fetch the payment source details with Vas ID
PROCEDURE getpaymentsourcedetails_by_vas ( i_vas_subscription_id IN NUMBER,
                                           o_rec OUT typ_pymt_src_dtls_rec,
                                           o_err_num out number,
                                           o_err_msg out VARCHAR2 );
--CR49058 Adding get_payment_details proc to fetch the payment details
PROCEDURE get_payment_details ( i_esn					IN  VARCHAR2 ,
                                i_prog_purch_id         IN  NUMBER   ,
                                i_pymt_type             IN  VARCHAR2 ,
                                i_bus_org               IN  VARCHAR2 ,
                                o_merchant_ref_number   OUT VARCHAR2 ,
                                o_merchant_id           OUT VARCHAR2 ,
                                o_customer_hostname     OUT VARCHAR2 ,
                                o_customer_ipaddress    OUT VARCHAR2 ,
                                o_ignore_avs            OUT VARCHAR2 ,
                                o_disable_avs           OUT VARCHAR2 ,
                                o_ignore_bad_cv         OUT VARCHAR2 ,
                                o_offer_num             OUT VARCHAR2 ,
                                o_quantity              OUT NUMBER   ,
                                o_amount                OUT NUMBER   ,
                                o_tax_amount            OUT NUMBER   ,
                                o_e911_tax_amount       OUT NUMBER   ,
                                o_usf_taxamount         OUT NUMBER   ,
                                o_rcrf_tax_amount       OUT NUMBER   ,
                                o_discount_amount       OUT NUMBER   ,
                                o_capture_req_id        OUT VARCHAR2 ,
                                o_error_code            OUT NUMBER   ,
                                o_error_msg             OUT VARCHAR2 );
                                --CR53217 Net10 web common standards
PROCEDURE recurring_payment_fail_flag(
    i_esn IN VARCHAR2,
    o_recurring_payment_flag OUT VARCHAR2,
    o_err_num OUT NUMBER,
    o_err_string OUT VARCHAR2);

procedure get_enrolled_esns (
i_payment_source_id in varchar2,
o_esns_ref out sys_refcursor,
o_err_num  OUT VARCHAR2,
o_err_string  OUT VARCHAR2);
--CR53217 Net10 web common standards

--CR53474 Start
PROCEDURE insert_program_purch
(
 ip_x_rqst_source  				           IN VARCHAR2,
 ip_x_rqst_type  				             IN VARCHAR2,
 ip_x_ics_applications  			       IN VARCHAR2,
 ip_x_merchant_id  				           IN VARCHAR2,
 ip_x_merchant_ref_number  		     IN VARCHAR2,
 ip_x_offer_num   				            IN VARCHAR2,
 ip_x_quantity   				             IN NUMBER,
 ip_x_merchant_product_sku   	    IN VARCHAR2,
 ip_x_product_code    			         IN VARCHAR2,
 ip_x_ignore_avs    				          IN VARCHAR2,
 ip_x_customer_hostname 			       IN VARCHAR2,
 ip_x_customer_ipaddress 		       IN VARCHAR2,
 ip_x_customer_phone 			          IN VARCHAR2,
 ip_x_status 					                IN VARCHAR2,
 ip_x_esn 						                  IN VARCHAR2,
 ip_x_amount 					                IN NUMBER,
 ip_x_tax_amount 				             IN NUMBER,
 ip_prog_hdr2x_pymt_src 			       IN NUMBER,
 ip_prog_hdr2web_user 			         IN NUMBER,
 ip_x_payment_type 				           IN VARCHAR2,
 ip_x_e911_tax_amount 			         IN NUMBER,
 ip_x_usf_taxamount 				          IN NUMBER,
 ip_x_rcrf_tax_amount 			         IN NUMBER,
 ip_x_discount_amount 			         IN NUMBER,
 ip_x_charge_desc                 IN VARCHAR2,
 ip_is_dataclub                   IN VARCHAR2 DEFAULT 'N',
 op_program_purchhdr_objid		      OUT NUMBER,
 op_errornum						                OUT VARCHAR2,
 op_errormsg						                OUT VARCHAR2
);
--CR53474 End

-- CR53192 changes begin :Overloading Getpaymentsource, getpaymentsourcedetails for sending the Inactive Payment source info
PROCEDURE get_all_payment_sources ( i_login_name                    IN  VARCHAR2 DEFAULT NULL    ,
                                    i_bus_org_id                    IN  VARCHAR2                 ,
                                    i_esn                           IN  VARCHAR2 DEFAULT NULL    ,
                                    i_min                           IN  VARCHAR2 DEFAULT NULL    ,
                                    i_include_inactive              IN  VARCHAR2 DEFAULT 'Y'     ,
                                    o_payment_source_detail_tbl     OUT payment_source_detail_tab,
                                    o_err_num                       OUT NUMBER                   ,
                                    o_err_msg                       OUT VARCHAR2                 );

--CR53912
PROCEDURE get_all_payment_source_details ( i_pymt_src_id                IN  NUMBER               ,
                                           i_include_inactive           IN  VARCHAR2 DEFAULT 'Y' ,
                                           o_payment_source_detail_rec  OUT typ_pymt_src_dtls_rec,
                                           o_err_num                    OUT NUMBER               ,
                                           o_err_msg                    OUT VARCHAR2             );
-- CR53192 changes Ends here

END PAYMENT_SERVICES_PKG;
/