CREATE OR REPLACE TYPE sa.byop_sms_send_record AS OBJECT
(        p_rowid                    VARCHAR2(500)
        ,p_esn                      VARCHAR2(30)
        ,p_min                      VARCHAR2(30)
        ,p_ota_psms_address         VARCHAR2(30)
        ,p_agg_carr_code            NUMBER
        ,p_transaction_type         VARCHAR2(50)
        ,p_brand                    VARCHAR2(40)
        ,p_error_code               NUMBER
        ,p_error_message            VARCHAR2(500)
        ,p_expire_dt                DATE
        ,p_x_msg_script_id          VARCHAR2(30)
        ,p_forecast_date            DATE
        ,p_x_msg_script_variables   VARCHAR2(1000)
        ,p_sms_flag                 VARCHAR2(1)
);
/