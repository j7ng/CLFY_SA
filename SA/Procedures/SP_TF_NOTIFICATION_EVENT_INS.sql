CREATE OR REPLACE PROCEDURE sa."SP_TF_NOTIFICATION_EVENT_INS" (i_notification_template   IN VARCHAR2,
                                                             i_esn                     IN VARCHAR2,
                                                             i_min                     IN VARCHAR2,
                                                             i_event_date              IN DATE    ,
                                                             i_customer_firstname      IN VARCHAR2,
                                                             i_customer_lastname       IN VARCHAR2,
                                                             i_customer_email          IN VARCHAR2,
                                                             i_payment_status          IN VARCHAR2,
                                                             i_status_desc             IN VARCHAR2,
                                                             i_payment_src_id          IN NUMBER  ,
                                                             i_payment_method          IN VARCHAR2,
                                                             i_web_user_id             IN NUMBER  ,
                                                             i_merchant_ref_id         IN VARCHAR2,
                                                             o_error_code              OUT NUMBER ,
                                                             o_error_msg               OUT VARCHAR2)
IS
-- Main Section of sp_tf_notification_event_ins procedure
BEGIN

   INSERT INTO TF_NOTIFICATION_EVENT
   (objid                  ,
    x_notification_template,
    x_esn                  ,
    x_min                  ,
    x_event_date           ,
    x_customer_firstname   ,
    x_customer_lastname    ,
    x_customer_email       ,
    x_payment_status       ,
    x_status_desc          ,
    x_payment_src_id       ,
    x_payment_method       ,
    x_web_user_id          ,
    x_merchant_ref_id      ,
    insert_timestamp       ,
    update_timestamp
    )
    VALUES
    (sequ_tf_notification_evnt.NEXTVAL,
     i_notification_template,
     i_esn                  ,
     i_min                  ,
     i_event_date           ,
     i_customer_firstname   ,
     i_customer_lastname    ,
     i_customer_email       ,
     i_payment_status       ,
     i_status_desc          ,
     i_payment_src_id       ,
     i_payment_method       ,
     i_web_user_id          ,
     i_merchant_ref_id      ,
     SYSDATE                ,
     SYSDATE
     );
    COMMIT;
    o_error_code := 0;
    o_error_msg  := 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
    o_error_code := 99;
    o_error_msg := 'Error Inserting tf_notification_event table:  '||substr(sqlerrm,1,100);

	--Inserting the failed records into error logging table.
	INSERT INTO x_program_error_log
	 (x_source,
	  x_error_code,
	  x_error_msg,
	  x_date,
	  x_description,
	  x_severity
	 )
	 VALUES
	 ('SA.SP_TF_NOTIFICATION_EVENT_INS',
	  o_error_code,
	  o_error_msg,
	  SYSDATE,
	  'ESN '||i_esn,
	  1 -- HIGH
	 );

END sp_tf_notification_event_ins; --Ending the update_subscriber procedure definition.
/