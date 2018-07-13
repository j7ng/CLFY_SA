CREATE OR REPLACE PACKAGE sa.rtc_pkg AS
--------------------------------------------------------------------------------
PROCEDURE is_rtc_enabled_for_esn (in_esn       IN   VARCHAR2,
                                  in_event     IN   VARCHAR2,
                                  in_bus_org   IN   VARCHAR2,
                                  in_language  IN   VARCHAR2,
                                  in_case_id   IN   NUMBER DEFAULT NULL,
                                  io_key_tbl   IN   OUT keys_tbl,
                                  out_err_num  OUT  NUMBER,
                                  out_err_msg  OUT  VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE set_rtc_event (in_event    IN   VARCHAR2,
                         in_comm_on  IN   VARCHAR2,
                         in_desc     IN   VARCHAR2,
                         out_msg     OUT  VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE set_rtc_criteria (in_criteria  IN   VARCHAR2,
                            in_desc      IN   VARCHAR2,
                            out_msg      OUT  VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE set_rtc_criteria_values (in_sp_objid    IN    NUMBER,
                                   in_event       IN    VARCHAR2,
                                   in_bus_org     IN    VARCHAR2,
                                   io_key_tbl     IN    sa.keys_tbl,
                                   out_err_num    OUT   VARCHAR2,
                                   out_err_msg    OUT   VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE enqueue (in_msg_string        IN    VARCHAR2,
                   in_priority          IN    NUMBER    DEFAULT 1,
                   in_expiration        IN    NUMBER    DEFAULT 86400,
                   in_queue             IN    VARCHAR2  DEFAULT 'SA.RTC_queue',
                   in_exception_queue   IN    VARCHAR2  DEFAULT 'SA.RTC_Exception_Queue',
                   in_correlation       IN    VARCHAR2  DEFAULT 'RTC_Queue',
                   out_err_num          OUT   NUMBER,
                   out_err_msg          OUT   VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE dequeue (in_queue       IN   VARCHAR2  DEFAULT 'SA.RTC_EXCEPTION_QUEUE',
                   in_consumer    IN   VARCHAR2  DEFAULT  NULL,
                   in_msg_state   IN   VARCHAR2  DEFAULT 'EXPIRED');
--------------------------------------------------------------------------------
FUNCTION get_rtc_event_data (i_event             IN   VARCHAR2,
                             i_esn               IN   VARCHAR2,
                             i_min               IN   VARCHAR2,
                             i_bus_org_id        IN   VARCHAR2,
                             i_contact_email     IN   VARCHAR2,
                             i_language          IN   VARCHAR2,
                             i_web_user_key      IN   VARCHAR2,
                             i_non_ppe_flag      IN   VARCHAR2,
                             i_case_id           IN   VARCHAR2,
                             i_sourcesystem      IN   VARCHAR2,
                             i_bus_org_objid     IN   VARCHAR2,
                             i_carrier_id        IN   VARCHAR2,
                             i_service_plan      IN   VARCHAR2,
                             i_udf1              IN   VARCHAR2,
                             i_udf2              IN   VARCHAR2,
                             i_udf3              IN   VARCHAR2,
                             i_udf4              IN   VARCHAR2,
                             i_udf5              IN   VARCHAR2,
                             i_udf6              IN   VARCHAR2,
                             i_udf7              IN   VARCHAR2,
                             i_udf8              IN   VARCHAR2,
                             i_udf9              IN   VARCHAR2,
                             i_err_num           IN   VARCHAR2,
                             i_err_msg           IN   VARCHAR2)
RETURN sys_refcursor;
--------------------------------------------------------------------------------
FUNCTION is_cust_not_lrp_enrolled (i_payload_msg   IN   q_payload_t,
                                   i_number_days   IN   NUMBER DEFAULT 30)
RETURN BOOLEAN;
--------------------------------------------------------------------------------
END rtc_pkg;
/