CREATE TABLE sa.x_resend_email_with_attachment (
  objid NUMBER NOT NULL,
  mail_host VARCHAR2(255 BYTE) DEFAULT 'MIACAS1',
  port NUMBER DEFAULT 25,
  subject_text VARCHAR2(255 BYTE),
  message_from VARCHAR2(255 BYTE) DEFAULT 'noreply@tracfone.com',
  send_to VARCHAR2(255 BYTE),
  message_text CLOB,
  attachment_name VARCHAR2(255 BYTE),
  attachment_text CLOB,
  attachment_context_type VARCHAR2(255 BYTE),
  original_failure_date DATE DEFAULT SYSDATE,
  retry_failure_date DATE,
  retry_count NUMBER
);
COMMENT ON TABLE sa.x_resend_email_with_attachment IS 'HOLDING TABLE TO STORE EMAILS WITH ATTACHMENT THAT FAILED TO BE SENT';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.objid IS 'PRIMARY KEY; INTERNAL RECORD NUMBER';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.mail_host IS 'SMTP HOST NAME TO CONNECT TO';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.port IS 'PORT NUMBER OF THE SMTP SERVER TO CONNECT TO';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.subject_text IS 'EMAIL SUBJECT';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.message_from IS 'EMAIL SENDER';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.send_to IS 'EMAIL RECIPIENT';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.message_text IS 'EMAIL BODY';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.attachment_name IS 'EMAIL ATTACHMENT NAME';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.attachment_text IS 'EMAIL ATTACHMENT';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.attachment_context_type IS 'EMAIL ATTACHMENT TYPE';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.original_failure_date IS 'ORIGINAL DATE THE EMAIL FAILED TO BE SENT';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.retry_failure_date IS 'LATEST DATE THE EMAIL RETRIED TO BE SENT';
COMMENT ON COLUMN sa.x_resend_email_with_attachment.retry_count IS 'NUMBER OF TIMES THE EMAIL RETRIED TO BE SENT';