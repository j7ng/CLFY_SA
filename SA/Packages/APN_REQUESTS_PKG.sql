CREATE OR REPLACE PACKAGE sa.apn_requests_pkg AS

PROCEDURE create_ig_apn_requests ( i_transaction_id IN  NUMBER   ,
                                   o_response       OUT VARCHAR2 );

PROCEDURE create_ig_min ( i_min             IN  VARCHAR2 ,
                          i_apn_source_type IN  VARCHAR2,
						  o_response_code   OUT NUMBER,
                          o_response        OUT VARCHAR2 ) ;

PROCEDURE create_w3ci_apn ( i_min           IN  VARCHAR2 ,
							i_rate_plan     IN  VARCHAR2 DEFAULT NULL,
                            o_response_code OUT NUMBER,
                            o_response      OUT VARCHAR2 );

END apn_requests_pkg;
/