CREATE OR REPLACE PACKAGE sa."ALERT_PKG"
AS
/*****************************************************************
  * Package Name: convert_bo_to_sql_pkg
  * Purpose     : To convert CBO methods to PLSQL procedures - Memory Leak Project
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Natalio Guada
  * Date        : 06/12/2005
  *
  * Frequency   : All weekdays
  * History
  * REVISIONS    VERSION  DATE          WHO            PURPOSE
  * -------------------------------------------------------------
  *              1.0      06/12/2006    Nguada     Initial Revision (CR4640)
  *              1.1      06/16/2010    NGuada     Step
  ************************************************************************/

PROCEDURE GET_ALERT ( ESN         VARCHAR2,
                      STEP        NUMBER,
                      channel     VARCHAR2 DEFAULT 'IVR',     -- Channel to display flash   --CR37075
                      TITLE       OUT VARCHAR2, -- Alert Title
                      CSR_TEXT    OUT VARCHAR2, -- Text to be used in WEBCSR
                      ENG_TEXT    OUT VARCHAR2, -- Web Text English
                      SPA_TEXT    OUT VARCHAR2, -- Web Text Spanish
                      ivr_scr_id  OUT varchar2, -- IVR script ID
                      tts_english OUT varchar2, -- Text to Speech English
                      TTS_SPANISH OUT VARCHAR2, -- Text to Speech Spanish
                      HOT         OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                      ERR         OUT VARCHAR2, -- Error Number
                      msg         OUT varchar2);-- Additional Messages
-- OVERLOADED
procedure get_alert ( esn            varchar2,
                      step           number,
                      channel        varchar2 default 'IVR',     -- Channel to display flash   --CR37075
                      title          out varchar2, -- Alert Title
                      CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                      eng_text       out varchar2, -- Web Text English
                      SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                      ivr_scr_id     out varchar2, -- IVR script ID
                      tts_english    OUT varchar2, -- Text to Speech English
                      tts_spanish    out varchar2, -- Text to Speech Spanish
                      HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                      err            out varchar2, -- Error Number
                      msg            out varchar2,-- Additional Messages
                      OP_URL         OUT VARCHAR2,
                      OP_URL_TEXT_EN OUT VARCHAR2,
                      op_url_text_es out varchar2,
                      OP_SMS_TEXT    OUT VARCHAR2);
-- OVERLOADED
procedure get_alert ( esn            varchar2,
                      step           number,
                      channel        varchar2 default 'IVR',     -- Channel to display flash   --CR37075
                      title          out varchar2, -- Alert Title
                      CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                      eng_text       out varchar2, -- Web Text English
                      SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                      ivr_scr_id     out varchar2, -- IVR script ID
                      tts_english    OUT varchar2, -- Text to Speech English
                      tts_spanish    out varchar2, -- Text to Speech Spanish
                      HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                      err            out varchar2, -- Error Number
                      msg            out varchar2,-- Additional Messages
                      OP_URL         OUT VARCHAR2,
                      OP_URL_TEXT_EN OUT VARCHAR2,
                      op_url_text_es out varchar2,
                      OP_SMS_TEXT    OUT VARCHAR2,
                      alert_objid    out varchar2,
                      is_alert_suppressible out VARCHAR2);

-- WRAPPER TO GET_ALERT OVERLOADED
procedure get_alert_2pos (esn            varchar2,
                          step           number,
                          channel        varchar2,     -- Channel to display flash
                          title          out varchar2, -- Alert Title
                          CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                          eng_text       out varchar2, -- Web Text English
                          SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                          ivr_scr_id     out varchar2, -- IVR script ID
                          tts_english    OUT varchar2, -- Text to Speech English
                          tts_spanish    out varchar2, -- Text to Speech Spanish
                          HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                          err            out varchar2, -- Error Number
                          msg            out varchar2,-- Additional Messages
                          OP_URL         OUT VARCHAR2,
                          op_url_text_en out varchar2,
                          op_url_text_es out varchar2,
                          op_sms_text    out varchar2);
-- WRAPPER TO GET_ALERT OVERLOADED
  procedure migration_alert(esn            varchar2,
                            step           number,
                            channel        varchar2,     -- Channel to display flash
                            title          out varchar2, -- Alert Title
                            CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                            eng_text       out varchar2, -- Web Text English
                            SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                            ivr_scr_id     out varchar2, -- IVR script ID
                            tts_english    OUT varchar2, -- Text to Speech English
                            tts_spanish    out varchar2, -- Text to Speech Spanish
                            HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                            err            out varchar2, -- Error Number
                            op_msg         out varchar2, -- Additional Messages
                            OP_URL         OUT VARCHAR2,
                            op_url_text_en out varchar2,
                            op_url_text_es out varchar2,
                            op_sms_text    out varchar2,
                            op_bus_org     out varchar2 -- NEW OP INTRODUCED
                            );

PROCEDURE CANCEL_ALERT (TYPE          VARCHAR2,
                        SQLSTR        VARCHAR2,
                        ESN           VARCHAR2,
                        start_date    date,
                        END_DATE      DATE,
                        ERR       OUT VARCHAR2,
                        cancel    OUT boolean);

  function r_migration_alert_obj (ip_brand varchar2, ip_type varchar2, ip_hot varchar2, ip_position varchar2, ip_url varchar2, ip_status varchar2)
  return varchar2;

  procedure winback_alert(esn            varchar2,
                          step           number,
                          channel        varchar2,     -- Channel to display flash
                          title          out varchar2, -- Alert Title
                          CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                          eng_text       out varchar2, -- Web Text English
                          SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                          ivr_scr_id     out varchar2, -- IVR script ID
                          tts_english    OUT varchar2, -- Text to Speech English
                          tts_spanish    out varchar2, -- Text to Speech Spanish
                          HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                          err            out varchar2, -- Error Number
                          op_msg         out varchar2, -- Additional Messages
                          OP_URL         OUT VARCHAR2,
                          op_url_text_en out varchar2,
                          op_url_text_es out varchar2,
                          op_sms_text    out varchar2,
                          op_bus_org     out varchar2 -- NEW OP INTRODUCED
                            );

-- CR52609 START All BRANDS - ALL - Send a message to customers during maintenance outages periods

   PROCEDURE outage_alerts(ip_esn VARCHAR2,
                          ip_channel VARCHAR2,
                          ip_display_point VARCHAR2,
                          ip_flow VARCHAR2,
                          ip_language VARCHAR2,
                          op_outage_title out VARCHAR2,
                          op_outage_alert out VARCHAR2,
                          ip_multi_line IN VARCHAR2 default 'N',  -- As part of CR we added a flag to identify single line or multiline. If 'Y' means mutiline.
                          ip_zip_code IN VARCHAR2 default NULL);  -- As part of CR55585 to capture zip code while activation flow.

  FUNCTION outage_restriction(ip_brand VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE set_carrier_outage_switch (
                                       ip_affected_carrier VARCHAR2,
                                       ip_affected_zipcodes VARCHAR2,
                                       ip_user_decision NUMBER -- 1=ON, 0=OFF
                                      );

  -- CR52609  END All BRANDS - ALL - Send a message to customers during maintenance outages periods


  FUNCTION get_alert_suppression(i_esn         IN    VARCHAR2,
                                 i_alert_objid IN    NUMBER,
                                 i_channel     IN    VARCHAR2
                                )
  RETURN VARCHAR2;
  PROCEDURE set_alert_suppression(i_esn           IN      VARCHAR2,
                                  i_alert_objid   IN      NUMBER,
                                  i_agent_id      IN      VARCHAR2,
                                  o_err_code         OUT  VARCHAR2,
                                  o_err_msg          OUT  VARCHAR2
                                 );
END ALERT_PKG;
/