CREATE OR REPLACE PACKAGE sa."SP_CHECK_EXCHANGES" AS
PROCEDURE deactivate_service  (ip_objid IN NUMBER,
                              ip_reason IN NUMBER,
                              ip_deactdate IN DATE,
                              ip_esn IN VARCHAR2,
                              ip_min IN VARCHAR2,
                              ip_result IN OUT BOOLEAN);
PROCEDURE create_call_trans  (ip_site_part IN NUMBER,
                              ip_action IN NUMBER,
                              ip_carrier IN NUMBER,
                              ip_dealer IN NUMBER,
                              ip_user  IN NUMBER,
                              ip_min  IN VARCHAR2,
                              ip_phone IN VARCHAR2,
                              ip_source IN VARCHAR2,
                              ip_transdate IN DATE,
                              ip_units IN NUMBER,
                              ip_action_text IN VARCHAR2,
                              ip_reason IN VARCHAR2,
                              ip_result IN VARCHAR2);
PROCEDURE deactivate_overdue_exchange;
END Sp_check_exchanges;
/