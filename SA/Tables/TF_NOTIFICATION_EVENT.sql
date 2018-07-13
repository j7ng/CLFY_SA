CREATE TABLE sa.tf_notification_event (
  objid NUMBER(22) NOT NULL,
  x_notification_template VARCHAR2(100 BYTE),
  x_esn VARCHAR2(20 BYTE),
  x_min VARCHAR2(20 BYTE),
  x_event_date DATE,
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_payment_status VARCHAR2(20 BYTE),
  x_status_desc VARCHAR2(1000 BYTE),
  x_payment_src_id NUMBER,
  x_payment_method VARCHAR2(30 BYTE),
  x_web_user_id NUMBER(22),
  x_merchant_ref_id VARCHAR2(50 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT tf_notification_event_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.tf_notification_event IS 'Stores the customer notification information';
COMMENT ON COLUMN sa.tf_notification_event.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.tf_notification_event.x_notification_template IS 'Notification template';
COMMENT ON COLUMN sa.tf_notification_event.x_esn IS 'Electronic Serial Number';
COMMENT ON COLUMN sa.tf_notification_event.x_min IS 'Mobile Identification Number';
COMMENT ON COLUMN sa.tf_notification_event.x_event_date IS 'Date of the Event';
COMMENT ON COLUMN sa.tf_notification_event.x_customer_firstname IS 'First name of the customer';
COMMENT ON COLUMN sa.tf_notification_event.x_customer_lastname IS 'Lastname of the customer';
COMMENT ON COLUMN sa.tf_notification_event.x_customer_email IS 'Email address of the customer';
COMMENT ON COLUMN sa.tf_notification_event.x_payment_status IS 'Status of the payment';
COMMENT ON COLUMN sa.tf_notification_event.x_status_desc IS 'Status Description';
COMMENT ON COLUMN sa.tf_notification_event.x_payment_src_id IS 'Source of Payment';
COMMENT ON COLUMN sa.tf_notification_event.x_payment_method IS 'Method of Payment';
COMMENT ON COLUMN sa.tf_notification_event.x_web_user_id IS 'Web User';
COMMENT ON COLUMN sa.tf_notification_event.x_merchant_ref_id IS 'Reference ID of Merchant';
COMMENT ON COLUMN sa.tf_notification_event.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.tf_notification_event.update_timestamp IS 'Last date when the record was last modified';