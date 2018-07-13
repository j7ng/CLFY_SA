CREATE OR REPLACE PACKAGE sa."TFSOA_GET_SERVICES_PKG" AS
  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure GET_SMS_DETAILS  (
                      p_esn                         IN       VARCHAR2,
                      p_mode                        IN       VARCHAR2,
                      p_text                        IN       VARCHAR2,
                      p_ota_trans2x_ota_mrkt_info   IN       VARCHAR2 DEFAULT NULL,
                      p_ota_trans_reason            IN       VARCHAR2 DEFAULT NULL,
                      p_x_ota_trans2x_call_trans    IN       NUMBER DEFAULT NULL,
                      p_cbo_error_message           IN       VARCHAR2  DEFAULT NULL,      -- error message passed from CBO
                      p_mobile365_id                IN       VARCHAR2 DEFAULT NULL,      --OTA Enhancements
                      p_dynamic_params              IN       TF_DYNAMICPARAM_DATATAB,
                      p_min                         out      varchar2,
                      p_dll                         out      varchar2,
                      p_psms_message                OUT      VARCHAR2,
                      p_technology                  OUT      varchar2,
                      p_sequence                    out      NUMBER,
                      p_ota_trans_objid             OUT      NUMBER,
                      p_out_text                        OUT     varchar2,
                      p_error                       out      varchar2);

procedure GET_CUST_DETAILS(p_webuserID    in number,
                                             p_paymentsrc   in number,
                                             p_type         in varchar2,
                                             p_cust_detail out CUSTOMER_DETAILS );

END TFSOA_GET_SERVICES_PKG;
/