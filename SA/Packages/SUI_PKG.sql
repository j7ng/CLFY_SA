CREATE OR REPLACE PACKAGE sa.sui_pkg
AS
PROCEDURE create_sui_order ( i_esn                        IN VARCHAR2,
                             i_min                        IN VARCHAR2,
                             i_case_id                    IN NUMBER,
                             i_order_type                 IN VARCHAR2,
                             i_source_system              IN VARCHAR2,
                             o_call_trans_objid           OUT NUMBER,
                             o_task_objid                 OUT NUMBER,
                             o_transaction_id             OUT NUMBER,
                             o_errorcode                  OUT NUMBER,
                             o_errormsg                   OUT VARCHAR2,
                             o_transaction_found_flag     OUT VARCHAR2,
                             i_discount_code_list         IN sa.discount_code_tab DEFAULT NULL --for WFM transaction
                          );

FUNCTION fetch_sui_order ( i_transaction_id  IN NUMBER )
  RETURN sui_result_rec_tab;

PROCEDURE update_sui ( i_esn          IN  VARCHAR2 ,
                       i_min          IN  VARCHAR2 ,
                       i_msid         IN  VARCHAR2 ,
                       i_sourcesystem IN  VARCHAR2 ,
                       o_response     OUT VARCHAR2 );

--CR48570 - Verizon MIN Mismatch on SUI transactions
PROCEDURE update_sui_transaction ( i_transaction_id   IN  NUMBER ,
                                   i_sourcesystem     IN  VARCHAR2 ,
                                   o_response         OUT VARCHAR2 );

FUNCTION fetch_sui_buckets ( i_transaction_id   IN   NUMBER,
                             i_direction        IN   VARCHAR2 DEFAULT 'OUTBOUND' )
   RETURN sui_result_rec_tab;

-- CR55008 - SUI Result Monitoring
PROCEDURE insert_sui_inquiry_mismatches ( i_transaction_id   IN  NUMBER ,
                                          i_min              IN  VARCHAR2,
                                          i_esn              IN  VARCHAR2,
                                          i_inquiry_result   IN  sa.SUI_INQUIRY_RESULT_REC_TAB,
                                          o_response         OUT VARCHAR2);

END sui_pkg;
/