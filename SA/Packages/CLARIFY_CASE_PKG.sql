CREATE OR REPLACE PACKAGE sa."CLARIFY_CASE_PKG" AS
  ---------------------------------------------------------------------------------------------
  --$RCSfile: CLARIFY_CASE_PKG.sql,v $
  --$Revision: 1.35 $
  --$Author: mshah $
  --$Date: 2018/05/01 16:27:21 $
  --$ $Log: CLARIFY_CASE_PKG.sql,v $
  --$ Revision 1.35  2018/05/01 16:27:21  mshah
  --$ CR56717 - Overnight ship exchange option
  --$
  --$ Revision 1.34  2018/04/19 14:46:17  mshah
  --$ CR57185 TMO AND VERIZON SIM EXPIRATION RULE
  --$
  --$ Revision 1.33  2018/04/11 21:02:57  mshah
  --$ CR56717 - Overnight ship exchange option
  --$
  --$ Revision 1.32  2018/04/09 22:10:40  mshah
  --$ CR56717 - Overnight ship exchange option
  --$
  --$ Revision 1.31  2018/04/06 21:49:21  mshah
  --$ CR56717 - Overnight ship exchange option
  --$
  --$ Revision 1.30  2018/04/05 19:11:06  mshah
  --$ CR56717 - Overnight ship exchange option
  --$
  --$ Revision 1.29  2018/02/02 23:22:53  tpathare
  --$ New procedure to retrieve case id based on detail
  --$
  --$ Revision 1.27  2017/10/30 22:21:55  sinturi
  --$ Added check_date variable
  --$
  --$ Revision 1.26  2017/10/24 20:12:58  sinturi
  --$ Adding update refund process proc
  --$
  --$ Revision 1.23  2017/02/08 15:13:48  mmunoz
  --$ CR46924 : Added function get_warranty_days_left
  --$
  --$ Revision 1.22  2016/10/18 15:07:44  rpednekar
  --$ CR42899 - New procedure CREATE_PORT_CASE_DETAIL_HIST
  --$
  --$ Revision 1.21  2016/08/11 13:59:59  rpednekar
  --$ CR42968 - New procedure get_repl_part_number
  --$
  --$ Revision 1.20  2016/05/02 16:30:21  hcampano
  --$ CR42374 - 2G Migration PPE:123
  --$
  --$ Revision 1.19  2016/04/14 16:41:37  hcampano
  --$ CR40993 - 2G Migration Project - Simplified Activation
  --$
  --$ Revision 1.18  2016/04/07 22:22:52  pamistry
  --$ CR39592 - FCC Production merge before TST deployment
  --$
  --$ Revision 1.17  2016/04/04 14:38:47  hcampano
  --$ CR42159 - Fix express activation case look up
  --$
  --$ Revision 1.16  2016/03/28 19:25:41  hcampano
  --$ CR41687 - PHASE 2 OF 2GMIGRATION
  --$
  --$ Revision 1.14  2016/03/24 18:40:27  hcampano
  --$ CR41687 - PHASE 2 OF 2GMIGRATION
  --$
  --$ Revision 1.13  2015/02/25 19:45:39  ddevaraj
  --$ modified for CR31107
  --$
  --$ Revision 1.9  2014/08/22 21:08:01  vkashmire
  --$ CR29489_CR22313
  --$
  --$ Revision 1.8  2012/09/18 19:53:17  kacosta
  --$ CR21208 Modify Ship Confirm Closed Cases
  --$ This revision does include the CR20854 Telcel changes incorporated previous revision
  --$
  --$ Revision 1.6  2012/07/02 17:16:03  kacosta
  --$ CR21208 Modify Ship Confirm Closed Cases
  --$
  --$ Revision 1.5  2011/12/02 20:38:36  nguada
  --$ Comments updated
  --$
  --$ 1.5      11/04/11   Natalio Guada     CR15757 ST Warranty Exch Activations
  --$ 1.4      10/04/10   Natalio Guada     Cr13085 Universal Branding
  --$ 1.3      12/01/09   Natalio Guada     B2b Changes
  --$ 1.2      11/06/09   Natalio Guada     Cr12155 St_Bundle_Iii
  --$ 1.1      02/25/08   Natalio Guada     Cr8264 Tmo Data Phase 6
  --$ 1.0      02/25/08   Natalio Guada     Cr8264 Tmo Data Phase 6
  --$ Move to CVS
  --$ 1.2      11/28/06   Natalio Guada     Cr5569 New Parameters (Release Version)
  --$ 1.1      11/13/06   Natalio Guada     Cr5569 New Requirements
  --$ 1.0      10/27/06   Natalio Guada    Initial revision
  ---------------------------------------------------------------------------------------------
  --
  --CR21208 Start Kacosta 06/28/2012
  l_b_debug BOOLEAN := TRUE;
  --CR21208 End Kacosta 06/28/2012
-----------------------------------------------------------------------------------------------
function get_warranty_days_left(p_esn in varchar2)
 --CR46924 March-2017
return number;
-----------------------------------------------------------------------------------------------
  PROCEDURE create_case
  (
    p_title         IN VARCHAR2
   ,p_case_type     IN VARCHAR2
   ,p_status        IN VARCHAR2
   ,p_priority      IN VARCHAR2
   ,p_issue         IN VARCHAR2
   ,p_source        IN VARCHAR2
   ,p_point_contact IN VARCHAR2
   ,p_creation_time IN DATE
   ,p_task_objid    IN NUMBER
   ,p_contact_objid IN NUMBER
   ,p_user_objid    IN NUMBER
   ,p_esn           IN VARCHAR2
   ,p_phone_num     IN VARCHAR2
   ,p_first_name    IN VARCHAR2
   ,p_last_name     IN VARCHAR2
   ,p_e_mail        IN VARCHAR2
   ,p_delivery_type IN VARCHAR2
   ,p_address       IN VARCHAR2
   ,p_city          IN VARCHAR2
   ,p_state         IN VARCHAR2
   ,p_zipcode       IN VARCHAR2
   ,p_repl_units    IN NUMBER
   ,p_fraud_objid   IN NUMBER
   ,p_case_detail   IN VARCHAR2
   ,p_part_request  IN VARCHAR2
   ,p_id_number     OUT VARCHAR2
   ,p_case_objid    OUT NUMBER
   ,p_error_no      OUT VARCHAR2
   ,p_error_str     OUT VARCHAR2
  );

  PROCEDURE dispatch_case
  (
    p_case_objid IN NUMBER
   ,p_user_objid IN NUMBER
   ,p_queue_name IN VARCHAR2
   ,p_error_no   OUT VARCHAR2
   ,p_error_str  OUT VARCHAR2
  );
  PROCEDURE log_notes
  (
    p_case_objid  IN NUMBER
   ,p_user_objid  IN NUMBER
   ,p_notes       IN VARCHAR2
   ,p_action_type IN VARCHAR2
   ,p_error_no    OUT VARCHAR2
   ,p_error_str   OUT VARCHAR2
  );
  PROCEDURE update_status
  (
    p_case_objid   IN NUMBER
   ,p_user_objid   IN NUMBER
   ,p_new_status   IN VARCHAR2
   ,p_status_notes IN VARCHAR2
   ,p_error_no     OUT VARCHAR2
   ,p_error_str    OUT VARCHAR2
  );
  PROCEDURE update_case_hdr
  (
    p_case_objid    IN NUMBER
   ,p_user_objid    IN NUMBER
   ,p_title         IN VARCHAR2
   ,p_case_type     IN VARCHAR2
   ,p_issue         IN VARCHAR2
   ,p_source        IN VARCHAR2
   ,p_point_contact IN VARCHAR2
   ,p_task_objid    IN NUMBER
   ,p_contact_objid IN NUMBER
   ,p_phone_num     IN VARCHAR2
   ,p_first_name    IN VARCHAR2
   ,p_last_name     IN VARCHAR2
   ,p_e_mail        IN VARCHAR2
   ,p_delivery_type IN VARCHAR2
   ,p_address       IN VARCHAR2
   ,p_city          IN VARCHAR2
   ,p_state         IN VARCHAR2
   ,p_zipcode       IN VARCHAR2
   ,p_repl_units    IN NUMBER
   ,p_fraud_objid   IN NUMBER
   ,p_esn           IN VARCHAR2
   ,p_priority      IN VARCHAR2
   ,p_error_no      OUT VARCHAR2
   ,p_error_str     OUT VARCHAR2
  );
  PROCEDURE accept_case
  (
    p_case_objid IN NUMBER
   ,p_user_objid IN NUMBER
   ,p_error_no   OUT VARCHAR2
   ,p_error_str  OUT VARCHAR2
  );
  PROCEDURE update_case_dtl
  (
    p_case_objid  IN NUMBER
   ,p_user_objid  IN NUMBER
   ,p_case_detail IN VARCHAR2
   ,p_error_no    OUT VARCHAR2
   ,p_error_str   OUT VARCHAR2
  );
  --   procedure UPDATE_PART_REQUEST (P_CASE_OBJID     in  number,
  --                                  P_USER_OBJID     in  number,
  --                                  P_ACTION         in  varchar2, --SHIP,UNDELIVERED,CANCEL
  --                                  P_PART_SERIAL_NO in  VARCHAR2, --Only for SHIP
  --                                  P_SHIP_DATE      in  DATE,     --Only for SHIP
  --                                  P_TRACKING_NO    in  VARCHAR2, --Only for SHIP
  --                                  P_ERROR_NO       OUT VARCHAR2,
  --                                  P_ERROR_STR      OUT VARCHAR2);
  PROCEDURE reopen_case
  (
    p_case_objid IN NUMBER
   ,p_user_objid IN NUMBER
   ,p_error_no   OUT VARCHAR2
   ,p_error_str  OUT VARCHAR2
  );

  PROCEDURE close_case
  (
    p_case_objid NUMBER
   ,p_user_objid NUMBER
   ,p_source     VARCHAR2
   ,p_resolution VARCHAR2
   ,p_status     VARCHAR2
   ,p_error_no   OUT VARCHAR2
   ,p_error_str  OUT VARCHAR2
  );

  PROCEDURE escalate
  (
    p_case_objid IN NUMBER
   ,p_user_objid IN NUMBER
   ,p_priority   IN VARCHAR2
   ,p_error_no   OUT VARCHAR2
   ,p_error_str  OUT VARCHAR2
  );

  PROCEDURE b2b_part_request_ship
  (
    ip_case_objid IN NUMBER
   ,ip_req_objid  IN NUMBER
   ,ip_new_esn    IN VARCHAR2
   ,ip_tracking   IN VARCHAR2
   ,ip_user_objid IN NUMBER
   ,p_error_no    OUT VARCHAR2
   ,p_error_str   OUT VARCHAR2
  );
  PROCEDURE part_request_ship
  (
    strcaseobjid IN VARCHAR2
   ,strnewesn    IN VARCHAR2
   ,strtracking  IN VARCHAR2
   ,struserobjid IN VARCHAR2
   ,p_error_no   OUT VARCHAR2
   ,p_error_str  OUT VARCHAR2
  );

  PROCEDURE part_request_add
  (
    strcaseobjid  IN VARCHAR2
   ,strpartnumber IN VARCHAR2
   ,p_quantity    IN NUMBER
   ,p_user_objid  IN VARCHAR2
   ,p_shipping    IN VARCHAR2
   , ----CR13085
    p_error_no    OUT VARCHAR2
   ,p_error_str   OUT VARCHAR2
  );

  FUNCTION arrival_date(service_level IN NUMBER) RETURN DATE;

  PROCEDURE revalidate_shipping
  (
    requestobjid IN VARCHAR2
   ,p_error_no   OUT VARCHAR2
   ,p_error_str  OUT VARCHAR2
  );

  FUNCTION status_part_inst
  (
    ip_serial_no IN VARCHAR2
   ,ip_domain    IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION status_desc_func(ip_status_code IN VARCHAR2) RETURN VARCHAR2;

  -- CR12155 ST_BUNDLE_III

  PROCEDURE advance_exchange
  (
    strcaseobjid IN VARCHAR2
   ,stroldesn    IN VARCHAR2
   ,struserobjid IN VARCHAR2
   ,p_error_no   OUT VARCHAR2
   ,p_error_str  OUT VARCHAR2
  );

  -- CR12155 ST_BUNDLE_III
  FUNCTION get_case_detail
  (
    strcaseobjid IN VARCHAR2
   ,strparameter IN VARCHAR2
  ) RETURN VARCHAR2;

  PROCEDURE st_exchange
  (
    caseobjid      IN NUMBER
   ,current_esn    IN VARCHAR2
   ,new_esn        IN VARCHAR2
   ,new_technology IN VARCHAR2
   ,new_iccid      IN VARCHAR2
   ,new_zipcode    IN VARCHAR2
   ,user_objid     IN NUMBER
   ,p_error_no     OUT VARCHAR2
   ,p_error_str    OUT VARCHAR2
  );

    PROCEDURE P_CREATE_CASE_BYOP (
                in_title           in     varchar2,
                in_case_type       in     varchar2,
                in_status          in     varchar2,
                in_priority        in     varchar2,
                in_issue           in     varchar2,
                in_source          in     varchar2,
                in_point_contact   in     varchar2,
                in_creation_time   in     date,
                in_task_objid      in     number,
                in_contact_objid   in     number,
                in_user_objid      in     number,
                in_esn             in     varchar2,
                in_phone_num       in     varchar2,
                in_first_name      in     varchar2,
                in_last_name       in     varchar2,
                in_e_mail          in     varchar2,
                in_delivery_type   in     varchar2,
                in_address         in     varchar2,
                in_city            in     varchar2,
                in_state           in     varchar2,
                in_zipcode         in     varchar2,
                in_repl_units      in     number,
                in_fraud_objid     in     number,
                in_case_detail     in     varchar2,
                in_part_request    in     varchar2,
                out_id_number      out    varchar2,
                out_case_objid     out    number,
                out_error_no       out    varchar2,
                out_error_str      out    varchar2
    ) ;
    /*
    CR29489   HPP BYOP    22-Aug-2014   vkashmire
    New procedure: P_CREATE_CASE_BYOP   manages HPP BYOP case creation
    */

  procedure express_activation (ip_debugger_switch varchar2,
                                ip_short_esn varchar2, -- last 4 digit esn
                                ip_min varchar2,
                                ip_client_id varchar2,
                                ip_transaction_id varchar2,
                                ip_org_id varchar2,
                                ip_source_system varchar2,
                                ip_language varchar2,
                                ip_login varchar2,
                                ip_case_id varchar2,
                                ip_units varchar2,
                                op_code out varchar2,
                                op_message out varchar2,
                                op_action out varchar2,
                                op_service_plan out varchar2,
                                op_service_plan_desc out varchar2,
                                op_units out varchar2,
                                op_sms out varchar2,
                                op_data out varchar2,
                                op_esn out varchar2,
                                op_min out varchar2,
                                op_zip out varchar2,
                                op_new_esn out varchar2,
                                op_new_sim out varchar2,
                                op_new_esn_pc out varchar2,
                                op_new_esn_pn out varchar2,
                                op_service_end_date out varchar2,
                                op_ticket_number out varchar2,
                                op_contact_objid out varchar2);

  procedure express_activation (ip_short_esn varchar2, -- last 4 digit esn
                                ip_min varchar2,
                                ip_client_id varchar2,
                                ip_transaction_id varchar2,
                                ip_org_id varchar2,
                                ip_source_system varchar2,
                                ip_language varchar2,
                                ip_login varchar2,
                                ip_case_id varchar2,
                                ip_units varchar2,
                                op_code out varchar2,
                                op_message out varchar2,
                                op_action out varchar2,
                                op_service_plan out varchar2,
                                op_service_plan_desc out varchar2,
                                op_units out varchar2,
                                op_sms out varchar2,
                                op_data out varchar2,
                                op_esn out varchar2,
                                op_min out varchar2,
                                op_zip out varchar2,
                                op_new_esn out varchar2,
                                op_new_sim out varchar2,
                                op_new_esn_pc out varchar2,
                                op_new_esn_pn out varchar2,
                                op_service_end_date out varchar2,
                                op_ticket_number out varchar2,
                                op_contact_objid out varchar2);

  function nap_check_passed (ip_zip varchar2, ip_esn varchar2, ip_min varchar2)
  return boolean;

  -- CR39592 Start PMistry 03/16/2016 Added new procedure.
  procedure get_part_reqst_dtl_by_caseid ( i_case_objid       IN     number,
                                            i_domain          IN     varchar2 DEFAULT 'PHONES',
                                            out_refcursor      OUT    SYS_REFCURSOR ,
                                            out_error_no       OUT    varchar2,
                                            out_error_str      OUT    varchar2);

  -- CR39592 End

  --CR42968 Start
  procedure get_repl_part_number
  (ip_esn			VARCHAR2
  ,ip_zipcode			VARCHAR2
  ,ip_case_type			VARCHAR2
  ,ip_case_title		VARCHAR2
  ,op_repl_part_number  OUT	VARCHAR2
  ,op_error_code	OUT	VARCHAR2
  ,op_error_msg		OUT	VARCHAR2
  );
  --CR42968 End


--CR42899

PROCEDURE CREATE_PORT_CASE_DETAIL_HIST
				( IP_TICKET_ID  		    VARCHAR2
				, OP_ERROR_CODE		OUT	 VARCHAR2
				, OP_ERROR_MSG		 OUT	 VARCHAR2
				);
--CR42899
-- Added this proc to update case status in batch process
PROCEDURE upd_refund_status ( i_check_date IN  DATE,
                              o_response   OUT VARCHAR2 );

--CR55956 Procedure added to retrieve case id based on detail
PROCEDURE get_case_id_by_detail ( in_detail_name  IN  VARCHAR2,
                                  in_detail_value IN  VARCHAR2,
                                  in_case_type    IN  VARCHAR2,
                                  in_case_title   IN  VARCHAR2,
                                  out_id_number   OUT VARCHAR2,
                                  out_error_code  OUT VARCHAR2,
                                  out_error_msg   OUT VARCHAR2 );

PROCEDURE update_expedite_shipping
                                   (
                                    i_case_id_number      IN  VARCHAR2,
                                    i_biz_hdr_objid       IN  NUMBER,
                                    i_shipping_method     IN  VARCHAR2,
                                    i_courier_id          IN  VARCHAR2,
                                    o_error_code          OUT NUMBER,
                                    o_error_msg           OUT VARCHAR2
                                   );

FUNCTION ship_refund_eligible
                           (
                             i_case_objid      IN  NUMBER,
                             o_error_code      OUT NUMBER,
                             o_error_msg       OUT VARCHAR2
                           )
RETURN VARCHAR2;

FUNCTION get_shipping_method
                           (
                             i_case_objid      IN  NUMBER,
                             part_request_id   IN  NUMBER
                           )
RETURN VARCHAR2;

END clarify_case_pkg;
/