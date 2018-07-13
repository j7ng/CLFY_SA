CREATE OR REPLACE PACKAGE sa.udp_tx_logging_pkg
AS
    PROCEDURE udp_log_tx_process (p_dealer_username    IN     VARCHAR2,
                                  p_functionname       IN     VARCHAR2,
                                  p_transaction_date          DATE,
                                  p_app_uri            IN     VARCHAR2,
                                  p_app_name           IN     VARCHAR2,
                                  p_remote_ip          IN     VARCHAR2,
                                  p_sim                IN     VARCHAR2,
                                  p_min                IN     VARCHAR2,
                                  p_esn                IN     VARCHAR2,
                                  p_sequence           IN     VARCHAR2,
                                  p_employee_id                IN VARCHAR2 default null,
                                  p_rental_agreement_no   IN VARCHAR2 default null,
                                  p_call_trans_objid      IN NUMBER,
                                  o_txid                  OUT NUMBER,
                                  o_err_code              OUT VARCHAR2,
                                  o_err_msg               OUT VARCHAR2);

    PROCEDURE udp_update_tx_process (p_txid       IN     NUMBER,
                                     p_status     IN     VARCHAR2,
                                     p_dealer_objid IN NUMBER,
                                     p_call_trans_objid      IN NUMBER,
                                     o_err_code      OUT VARCHAR2,
                                     o_err_msg       OUT VARCHAR2);

    -- CR37756 Added new procedure for Simple Mobile.
    PROCEDURE update_udp_tx_process_dealer (i_esn       IN     VARCHAR2,
                                            i_sim       IN     VARCHAR2,
                                            --i_min       IN     VARCHAR2,
                                            i_call_trans_objid      IN NUMBER,
                                            o_err_code      OUT VARCHAR2,
                                            o_err_msg       OUT VARCHAR2);

END udp_tx_logging_pkg;
/