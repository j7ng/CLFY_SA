CREATE OR REPLACE PACKAGE sa.TMO_WIFI_PKG  IS

PROCEDURE Update_Insert_E911address  (
                                      ip_action       in varchar2,
                                      ip_esn          in varchar2,
                                      ip_Address      in Varchar2,
                                      ip_Address2     in varchar2,
                                      ip_city         in varchar2,
                                      ip_state        in varchar2,
                                      ip_country      in varchar2,
                                      ip_zip          in  varchar2,
                                      op_errorcode    out number,
                                      op_errormessage out varchar2
                                      );

PROCEDURE GetWifi_Eligibility(
                              ip_min               IN   VARCHAR2,
                              op_min               OUT  VARCHAR2,
                              op_esn               OUT  VARCHAR2,
                              op_addressln1        OUT  VARCHAR2,
                              op_addressln2        OUT  VARCHAR2,
                              op_city              OUT  VARCHAR2,
                              op_state             OUT  VARCHAR2,
                              op_zipcode           OUT  VARCHAR2,
                              op_esn_elg           OUT  VARCHAR2 ,
                              op_sim_elg           OUT  VARCHAR2 ,
                              op_errorcode         OUT   NUMBER ,
                              op_errormessage      OUT  VARCHAR2
                             );


PROCEDURE create_wifi_trans(
                             ip_transaction_id IN  NUMBER  ,
                             o_err_msg        OUT VARCHAR2
                            );

PROCEDURE create_wifi_trans_wrap(
                                 ip_transaction_id IN  NUMBER
                                 );

 END TMO_WIFI_PKG;
/