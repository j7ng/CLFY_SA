CREATE OR REPLACE PACKAGE BODY sa."TFSOA_NTFY_CORE_LOGGING_PKG"
IS

PROCEDURE TF_UPDATELOGENTRY(
          p_NTFY_DB_INPUT_TYPE  IN  TF_NTFY_DB_INPUT_TYPE,
          p_NTFY_DB_OUTPUT_TYPE  OUT      TF_NTFY_DB_OUTPUT_TYPE)
IS

BEGIN

 UPDATE x_ntfy_trans_log
    SET x_update_stamp = SYSDATE,
        x_update_status = 'U',
        x_sent_date = SYSDATE,
        x_sent_status = p_NTFY_DB_INPUT_TYPE.p_status,
        x_fail_code = nvl(p_NTFY_DB_INPUT_TYPE.p_code,0)
WHERE  objid = p_NTFY_DB_INPUT_TYPE.p_objid;

p_NTFY_DB_OUTPUT_TYPE := TF_NTFY_DB_OUTPUT_TYPE(0,'Success');

EXCEPTION
WHEN OTHERS THEN
 p_NTFY_DB_OUTPUT_TYPE := TF_NTFY_DB_OUTPUT_TYPE(SQLCODE,'Update error: '||SQLCODE || SUBSTR (SQLERRM, 1, 100));

END TF_UPDATELOGENTRY;


PROCEDURE    TF_CREATEBILLINGLOGENTRY(
             p_NTFY_DB_INPUT_TYPE  IN        TF_NTFY_DB_INPUT_TYPE,
             p_NTFY_DB_OUTPUT_TYPE  OUT      TF_NTFY_DB_OUTPUT_TYPE)
IS
BEGIN


INSERT INTO x_billing_log (
	objid,
	x_log_category,
	x_log_title,
	x_log_date,
	x_details,
	x_additional_details,
	x_program_name,
	x_nickname,
	x_esn,
	x_originator,
	x_contact_first_name,
	x_contact_last_name,
	x_agent_name,
	x_sourcesystem,
	billing_log2web_user
) VALUES (
	BILLING_SEQ('X_BILLING_LOG'),
	'Notification',
	 p_NTFY_DB_INPUT_TYPE.p_log_title,
	SYSDATE,
	 p_NTFY_DB_INPUT_TYPE.p_details,
	'N/A',
	 p_NTFY_DB_INPUT_TYPE.p_program_name,
	 p_NTFY_DB_INPUT_TYPE.p_nickname,
	 p_NTFY_DB_INPUT_TYPE.p_esn,
	'System',
	'N/A',
	'N/A',
	 p_NTFY_DB_INPUT_TYPE.p_agent_name,
	 p_NTFY_DB_INPUT_TYPE.p_sourcesystem,
	 nvl(p_NTFY_DB_INPUT_TYPE.p_billing_log2web_user,0)
);

p_NTFY_DB_OUTPUT_TYPE := TF_NTFY_DB_OUTPUT_TYPE(0,'Success');
EXCEPTION
WHEN OTHERS THEN
  p_NTFY_DB_OUTPUT_TYPE := TF_NTFY_DB_OUTPUT_TYPE(SQLCODE,'INSERT error: '||SQLCODE || SUBSTR (SQLERRM, 1, 100));

END TF_CREATEBILLINGLOGENTRY;

PROCEDURE  TF_STOREFORDELIVERYSTATUS(
           p_NTFY_DB_INPUT_TYPE  IN  TF_NTFY_DB_INPUT_TYPE,
           p_NTFY_DB_OUTPUT_TYPE  OUT      TF_NTFY_DB_OUTPUT_TYPE)
IS

BEGIN


INSERT INTO x_ntfy_sent (
	objid,
	x_channel_name,
	x_channel_msgid,
	x_sent_date,
	x_update_stamp,
	x_update_status,
	ntfy_sent2trans_log,
	x_message
) VALUES (
	BILLING_SEQ('X_NTFY_SENT'),
	 p_NTFY_DB_INPUT_TYPE.p_channel_name,
	 p_NTFY_DB_INPUT_TYPE.p_channel_message_id,
	 p_NTFY_DB_INPUT_TYPE.p_sent_date,
	SYSDATE,
	 p_NTFY_DB_INPUT_TYPE.p_update_status,
	 nvl(p_NTFY_DB_INPUT_TYPE.p_ntfy_sent2trans_log,0),
	 p_NTFY_DB_INPUT_TYPE.p_message --(base64 encoded message)
);

p_NTFY_DB_OUTPUT_TYPE := TF_NTFY_DB_OUTPUT_TYPE(0,'Success');
EXCEPTION
WHEN OTHERS THEN
  p_NTFY_DB_OUTPUT_TYPE := TF_NTFY_DB_OUTPUT_TYPE(SQLCODE,'INSERT error: '||SQLCODE || SUBSTR (SQLERRM, 1, 100));

END TF_STOREFORDELIVERYSTATUS;

PROCEDURE TF_STOREFORBATCHPROCESSING (
           p_NTFY_DB_INPUT_TYPE  IN  TF_NTFY_DB_INPUT_TYPE,
           p_NTFY_DB_OUTPUT_TYPE  OUT TF_NTFY_DB_OUTPUT_TYPE)
IS

BEGIN

INSERT INTO x_ntfy_batch (
	objid,
	batch2trans_log,
	x_channel_name,
	x_update_stamp,
	x_update_status,
	x_message
) VALUES (
	BILLING_SEQ('X_NTFY_BATCH'),
	nvl(p_NTFY_DB_INPUT_TYPE.p_batch2trans_log,0),
	p_NTFY_DB_INPUT_TYPE.p_channel_name,
	SYSDATE,
	p_NTFY_DB_INPUT_TYPE.p_update_status,
	p_NTFY_DB_INPUT_TYPE.p_message
);

p_NTFY_DB_OUTPUT_TYPE := TF_NTFY_DB_OUTPUT_TYPE(0,'Success');
EXCEPTION
WHEN OTHERS THEN
  p_NTFY_DB_OUTPUT_TYPE := TF_NTFY_DB_OUTPUT_TYPE(SQLCODE,'INSERT error: '||SQLCODE || SUBSTR (SQLERRM, 1, 100));

END TF_STOREFORBATCHPROCESSING;
END TFSOA_NTFY_CORE_LOGGING_PKG ;
/