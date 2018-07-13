CREATE OR REPLACE PACKAGE sa."ADFCRM_SAFELINK" as

  function get_lid(ip_esn varchar2) return number;
---------------------------------------------------------------------------
  function get_lid(ip_table varchar2, ip_esn varchar2) return number;
---------------------------------------------------------------------------
  function get_lid(ip_contact_objid varchar2, ip_wu_objid varchar2, ip_cust_id varchar2) return number;
---------------------------..------------------------------------------------

  type service_history_rec is record
  (x_event_dt            date,
   x_esn                 varchar2(300),
   lid 		               number,
   event_desc            varchar2(20),
   prog_name             varchar2(50),
   prog_minutes          varchar2(50),
   x_sourcesystem        varchar2(30),
   status_desc           varchar2(20),
   x_event_data          varchar2(300)
  );

  --------------------------------------------------------------------------------
  type service_history_tab is table of service_history_rec;
  service_history_rslt service_history_rec;
  --------------------------------------------------------------------------------
  procedure service_history(ip_search_field varchar2,
                            ip_search_value varchar2,
                            ip_recordset out sys_refcursor);
  --------------------------------------------------------------------------------
  function service_history(ip_search_field varchar2,
                           ip_search_value varchar2)
  return service_history_tab pipelined;
  --------------------------------------------------------------------------------
  function ret_info(ip_esn varchar2)
  return adfcrm_esn_structure;
  --------------------------------------------------------------------------------
  function get_slEsn_Enrolled(ip_lid varchar2) return adfcrm_esn_structure;
  --------------------------------------------------------------------------------
  function get_Enroll_record(ip_esn varchar2) return adfcrm_esn_structure;
  --------------------------------------------------------------------------------
  procedure validateSlEsn(
     ip_esn in varchar2,
     ip_min in varchar2,
     ip_lid in varchar2,
     ip_web_user_id varchar2,
     ip_action varchar2,
     ip_org_id varchar2,
     op_error_no out varchar2,
     op_error_msg out varchar2);

procedure enrollment (
   ip_esn in varchar2,
   ip_lid in varchar2,
   ip_user_name in varchar2,
   ip_reason in varchar2,
   op_err_code out varchar2,
   op_err_msg  out varchar2
);

procedure de_enrollment (
   ip_esn in varchar2,
   ip_lid in varchar2,
   ip_enroll_id in varchar2,
   ip_user_name in varchar2,
   ip_reason in varchar2,
   op_err_code out varchar2,
   op_err_msg  out varchar2
);

/***************************************************************/
--CR35135	Attach ESN to Safelink ID in TAS
procedure assign_esn_to_lid (
   ip_esn in varchar2,
   ip_lid in number,
   ip_userName in varchar2, -- CR 36487 Add hist record for Attach ESN to LID
   op_err_code out varchar2,
   op_err_msg  out varchar2
);
/***************************************************************/
  function is_phone_safelink (ip_esn varchar2) return varchar2;
/***************************************************************/
  function is_past_safelink_enrolled (ip_esn VARCHAR2)
  return varchar2;
/***************************************************************/
  function is_still_safelink (ip_esn varchar2, ip_org_id varchar2) return varchar2;
/***************************************************************/



type safe_link_lid_rec
IS
  record
  (
    LID                     NUMBER,
    FULL_NAME               VARCHAR2(200),
    ADDRESS_1               VARCHAR2(200),
    CITY                    VARCHAR2(30),
    STATE                   VARCHAR2(40),
    ZIP                     VARCHAR2(20),
    COUNTRY                 VARCHAR2(40),
    E_MAIL                  VARCHAR2(80),
    X_HOMENUMBER            VARCHAR2(20),
    X_CURRENT_ESN           VARCHAR2(30),
    X_CURRENT_ENROLLED      VARCHAR2(1),
    X_CURRENT_ENROLLED_DATE DATE,
    X_SL_HIST_DATE          DATE,
    X_RANK                  NUMBER );

type safe_link_lid_tab
IS
  TABLE OF safe_link_lid_rec;

FUNCTION fetch_safelink_id_info(
    ip_zipcode   VARCHAR2,
    ip_address   VARCHAR2,
    ip_full_name VARCHAR2,
    ip_org_id VARCHAR2)
  RETURN safe_link_lid_tab pipelined;

end adfcrm_safelink;
/