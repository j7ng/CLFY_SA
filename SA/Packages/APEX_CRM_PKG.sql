CREATE OR REPLACE PACKAGE sa."APEX_CRM_PKG" AS
--------------------------------------------------------------------------------------------
--$RCSfile: APEX_CRM_PKG.sql,v $
--$Revision: 1.32 $
--$Author: nguada $
--$Date: 2017/11/03 18:05:24 $
--$ $Log: APEX_CRM_PKG.sql,v $
--$ Revision 1.32  2017/11/03 18:05:24  nguada
--$ CR54247
--$
--$ Revision 1.31  2017/08/14 14:31:24  oimana
--$ CR51768 - Remove call to TABLE_TIME_BOMB from entire process.
--$
--$ Revision 1.30  2017/01/18 18:34:56  nguada
--$ WFM_TAS_01
--$
--$ Revision 1.28  2016/01/14 17:36:24  mmunoz
--$ CR39389: Updated type recent_interactions_rec and rirec, Change merged with prod. version (1.25)
--$
--$ Revision 1.27  2016/01/12 21:18:37  mmunoz
--$ CR39389: Updated type recent_interactions_rec and rirec
--$
--$ Revision 1.26  2015/09/23 19:58:24  mmunoz
--$ Apollo: Added org_id in type cntct_reslt_ty
--$
--$ Revision 1.25  2015/01/06 15:21:09  mmunoz
--$ get_cntct_rslt_tas overloaded to add Lifeline ID and do not break other branches
--$
--$ Revision 1.24  2014/10/16 13:05:17  hcampano
--$ TAS_2014_10A, TAS_2014_10B
--$
--$ Revision 1.23  2014/01/03 16:12:38  hcampano
--$ Added New Auth_user func returning varchar2
--$
--$ Revision 1.22  2013/12/30 16:01:45  hcampano
--$ Added site_type column to get_cntct_rslt_tas function
--$
--$ Revision 1.21  2013/11/18 19:42:22  nguada
--$ CR26679 New Parameter for Conact Search
--$
--$ Revision 1.20  2013/09/24 16:02:47  hcampano
--$ Commiting Natalio changes.
--$
--$ Revision 1.19  2013/01/28 22:50:10  mmunoz
--$ CR23043 checking in for Natalio. - Added New Function  get_cntct_rslt_tas.
--$
--------------------------------------------------------------------------------------------
  FUNCTION bo_cal( ip_inp IN VARCHAR2)
  RETURN VARCHAR2;

 FUNCTION apex_esn_min_hist (
  ip_request IN VARCHAR2,
  ip_esn IN VARCHAR2,
  ip_min IN VARCHAR2,
  ip_trans_type IN VARCHAR2,
  ip_days IN VARCHAR2,
  ip_msid IN VARCHAR2,
  ip_red_card IN VARCHAR2,
  ip_line_trans_type IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION ret_var(var_name IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION auth_user(ipv_user_name VARCHAR2,
                     ipv_perm_name VARCHAR2)
  RETURN BOOLEAN;

  FUNCTION auth_user(ipv_user_name VARCHAR2,
                     ipv_perm VARCHAR2,
                     ipv_perm_str CLOB) RETURN BOOLEAN;

  FUNCTION auth_user_v(ipv_user_name VARCHAR2,
                       ipv_perm_name VARCHAR2) RETURN VARCHAR;

  FUNCTION ret_menu (p_app_id NUMBER,
                      p_app_page_id NUMBER,
                      p_menu_grp_name VARCHAR2 DEFAULT NULL,
                      p_app_user VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

  FUNCTION has_tick(ipv_text VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE get_cntct_rslt (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            p_recordset OUT SYS_REFCURSOR);

  PROCEDURE get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2,
                            p_recordset OUT SYS_REFCURSOR);

--------------Overloaded to add Lifeline ID and do not break other branches-----------------------
  PROCEDURE get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2,
                            ipv_lid VARCHAR2,
                            p_recordset OUT SYS_REFCURSOR);

  PROCEDURE get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2,
                            ipv_lid VARCHAR2,
                            ipv_web_user_objid VARCHAR2,
                            p_recordset OUT SYS_REFCURSOR);

  PROCEDURE clr_parent_flag(ipv_parent VARCHAR2);

  PROCEDURE clr_parent_case_from_child(ipv_child   VARCHAR2,
                                       ipv_parent  VARCHAR2 DEFAULT NULL,
                                       opv_out_msg OUT VARCHAR2);

  PROCEDURE set_parent_case(ipv_parent  VARCHAR2,
                            ipv_child   VARCHAR2,
                            opv_out_msg OUT VARCHAR2);

FUNCTION apex_case_query
(
  ip_query_objid IN NUMBER
) RETURN VARCHAR2;

FUNCTION apex_console_queue_query (ip_queue_objid IN NUMBER,
                                   ip_queue_type IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION  apex_validate_user
          (p_username IN VARCHAR2,
           p_password IN VARCHAR2)
RETURN BOOLEAN;

PROCEDURE accept_case_to_wipbin(
     p_case_objid IN NUMBER,
     p_user_objid IN NUMBER,
     p_wipbin_objid IN NUMBER,
     p_error_no OUT VARCHAR2,
     p_error_str OUT VARCHAR2);

--------------------------------------------------------------------
     PROCEDURE sp_apex_close_action_item (
      p_task_objid   IN       NUMBER,
      p_status       IN       NUMBER,
      p_user         IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   );

--------------------------------------------------------------------
    TYPE cntct_reslt_ty IS RECORD
    ( con_objid NUMBER,
      cust_id  table_contact.x_cust_id%TYPE,
      f_name table_contact.first_name%TYPE,
      l_name table_contact.last_name%TYPE,
      phone table_contact.phone%TYPE,
      address table_address.address%TYPE,
      city table_address.city%TYPE,
      STATE table_address.STATE%TYPE,
      zip table_address.zipcode%TYPE,
      fax table_contact.fax_number%TYPE,
      email table_contact.e_mail%TYPE,
      site_type table_site.site_type%TYPE,
   lid sa.x_sl_subs.lid%TYPE);
   TYPE tab_cntct_rslt_ty IS TABLE OF cntct_reslt_ty;
 --  tab_cntct_rslt tab_cntct_rslt_ty := tab_cntct_rslt_ty();
   cntct_reslt cntct_reslt_ty;

--------------------------------------------------------------------

  FUNCTION get_cntct_rslt (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2)
  RETURN tab_cntct_rslt_ty PIPELINED;

  FUNCTION get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2)
  RETURN tab_cntct_rslt_ty PIPELINED;

--------------Overloaded to add Lifeline ID and do not break other branches-----------------------
  FUNCTION get_cntct_rslt_tas (ipv_f_name VARCHAR2,
                            ipv_l_name VARCHAR2,
                            ipn_phone VARCHAR2,
                            ipv_esn   VARCHAR2,
                            ipn_cust_id VARCHAR2,
                            ipv_email VARCHAR2,
                            ipv_interact_id VARCHAR2,
                            ipv_min VARCHAR2,
                            ipv_sim VARCHAR2,
                            ipv_address VARCHAR2,
                            ipv_zipcode VARCHAR2,
       ipv_lid VARCHAR2)
  RETURN tab_cntct_rslt_ty PIPELINED;

--------------------------------------------------------------------
PROCEDURE PASSWORD_VERIFY_FUNCTION(
      username  IN   VARCHAR2,
      PASSWORD  IN   VARCHAR2,
      op_result OUT BOOLEAN,
      op_message OUT VARCHAR2);

--------------------------------------------------------------------
  TYPE rcn_arr IS TABLE OF CLOB;

  FUNCTION refresh_case_notes (c_objid NUMBER)
  RETURN rcn_arr
  PIPELINED;
  FUNCTION refresh_case_notes_2 (case_id VARCHAR2)
  RETURN rcn_arr
  PIPELINED;
--------------------------------------------------------------------
  PROCEDURE case_maintenance(ip_carrier_name VARCHAR2,
                             ip_condition VARCHAR2,
                             ip_case_id VARCHAR2,
                             ip_case_type VARCHAR2,
                             ip_title VARCHAR2,
                             ip_queue VARCHAR2,
                             ip_esn VARCHAR2,
                             ip_min VARCHAR2,
                             ip_iccid VARCHAR2,
                             ip_date_from VARCHAR2,
                             ip_date_to VARCHAR2,
                             ip_check_results NUMBER,
                             ip_app_id NUMBER,
                             ip_pg_id NUMBER,
                             ip_app_session NUMBER,
                             ip_recordset OUT SYS_REFCURSOR);

  TYPE case_maintenance_rec IS RECORD
  (select_link      VARCHAR2(355),
   case_link        VARCHAR2(355),
   id_number        VARCHAR2(255),
   case_type        VARCHAR2(30),
   title            VARCHAR2(80),
   carrier_mkt_name VARCHAR2(30),
   esn              VARCHAR2(30),
   phone_model      VARCHAR2(30),
   MIN              VARCHAR2(30),
   condition        VARCHAR2(80),
   status           VARCHAR2(80),
   case_objid       NUMBER
  );
  TYPE case_maintenance_tab IS TABLE OF case_maintenance_rec;
  case_maintenance_rslt case_maintenance_rec;

  FUNCTION case_maintenance(ip_carrier_name VARCHAR2,
                            ip_condition VARCHAR2,
                            ip_case_id VARCHAR2,
                            ip_case_type VARCHAR2,
                            ip_title VARCHAR2,
                            ip_queue VARCHAR2,
                            ip_esn VARCHAR2,
                            ip_min VARCHAR2,
                            ip_iccid VARCHAR2,
                            ip_date_from VARCHAR2,
                            ip_date_to VARCHAR2,
                            ip_check_results NUMBER,
                            ip_app_id NUMBER,
                            ip_pg_id NUMBER,
                            ip_app_session NUMBER)
  RETURN case_maintenance_tab PIPELINED;
--------------------------------------------------------------------
  PROCEDURE close_bulk_cases (ip_carrier_name VARCHAR2,
                              ip_condition VARCHAR2,
                              ip_case_id VARCHAR2,
                              ip_case_type VARCHAR2,
                              ip_title VARCHAR2,
                              ip_queue VARCHAR2,
                              ip_esn VARCHAR2,
                              ip_min VARCHAR2,
                              ip_iccid VARCHAR2,
                              ip_date_from VARCHAR2,
                              ip_date_to VARCHAR2,
                              ip_reason VARCHAR2,
                              ip_user VARCHAR2,
                              ip_user_objid NUMBER,
                              op_msg OUT VARCHAR2);
--------------------------------------------------------------------
  PROCEDURE action_item_maintenance(ip_carrier_name VARCHAR2,
                                    ip_carrier_mkt VARCHAR2,
                                    ip_order_type VARCHAR2,
                                    ip_trans_method VARCHAR2,
                                    ip_status VARCHAR2,
                                    ip_condition VARCHAR2,
                                    ip_esn VARCHAR2,
                                    ip_queue VARCHAR2,
                                    ip_task_id VARCHAR2,
                                    ip_date_from NUMBER,
                                    ip_check_results NUMBER,
                                    ip_app_id NUMBER,
                                    ip_pg_id NUMBER,
                                    ip_app_session NUMBER,
                                    ip_calling_from_apex NUMBER,
                                    ip_recordset OUT SYS_REFCURSOR);

  TYPE action_item_maintenance_rec IS RECORD
  (select_link      VARCHAR2(355),
   task_link        VARCHAR2(355),
   task_id          VARCHAR2(25),
   start_date       DATE,
   f_name           VARCHAR2(30),
   l_name           VARCHAR2(30),
   condition        VARCHAR2(80),
   QUEUE            VARCHAR2(24),
   OWNER            VARCHAR2(30),
   status           VARCHAR2(80),
   order_type       VARCHAR2(30),
   carrier_name     VARCHAR2(30),
   carrier_mkt      VARCHAR2(30),
   esn              VARCHAR2(30),
   current_method   VARCHAR2(30),
   MIN              VARCHAR2(30)
  );

  TYPE action_item_maintenance_tab IS TABLE OF action_item_maintenance_rec;
  action_item_maintenance_rslt action_item_maintenance_rec;

  FUNCTION action_item_maintenance(ip_carrier_name VARCHAR2,
                                   ip_carrier_mkt VARCHAR2,
                                   ip_order_type VARCHAR2,
                                   ip_trans_method VARCHAR2,
                                   ip_status VARCHAR2,
                                   ip_condition VARCHAR2,
                                   ip_esn VARCHAR2,
                                   ip_queue VARCHAR2,
                                   ip_task_id VARCHAR2,
                                   ip_date_from NUMBER,
                                   ip_check_results NUMBER,
                                   ip_app_id NUMBER,
                                   ip_pg_id NUMBER,
                                   ip_app_session NUMBER,
                                   ip_calling_from_apex NUMBER)
  RETURN action_item_maintenance_tab PIPELINED;
--------------------------------------------------------------------
  PROCEDURE close_bulk_action_items (ip_carrier_name VARCHAR2,
                                     ip_carrier_mkt VARCHAR2,
                                     ip_order_type VARCHAR2,
                                     ip_trans_method VARCHAR2,
                                     ip_status VARCHAR2,
                                     ip_condition VARCHAR2,
                                     ip_esn VARCHAR2,
                                     ip_queue VARCHAR2,
                                     ip_task_id VARCHAR2,
                                     ip_date_from NUMBER,
                                     ip_user VARCHAR2,
                                     op_msg OUT VARCHAR2);
--------------------------------------------------------------------
  TYPE recent_interactions_rec IS RECORD
  (i_objid          NUMBER,
   create_date       DATE,
   x_service_type   VARCHAR2(50),--varchar2(20),
   inserted_by      VARCHAR2(40),
   reason           VARCHAR2(200), --varchar2(20),
   detail           VARCHAR2(200),
   channel          VARCHAR2(200),
   interact_result  VARCHAR2(200), --varchar2(20),
   interact_id      VARCHAR2(40),
   notes            CLOB,
   esn              VARCHAR2(30)
  );

  TYPE rirec IS RECORD
  (i_objid          NUMBER,
   create_date       DATE,
   x_service_type   VARCHAR2(50),
   inserted_by      VARCHAR2(40),
   reason           VARCHAR2(200),
   detail           VARCHAR2(200),
   channel          VARCHAR2(200),
   interact_result  VARCHAR2(200),
   interact_id      VARCHAR2(40),
   notes            LONG,
   esn              VARCHAR2(30)
  );

  TYPE recent_interactions_tab IS TABLE OF recent_interactions_rec;
  recent_interactions_rslt recent_interactions_rec;

  FUNCTION recent_interactions(ip_c_objid NUMBER,
                               ip_serial_no VARCHAR2)
  RETURN recent_interactions_tab PIPELINED;
--------------------------------------------------------------------------------
END apex_crm_pkg;
/