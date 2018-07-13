CREATE TABLE sa.queue_type_tbl (
  q_name VARCHAR2(30 BYTE) NOT NULL,
  q_type VARCHAR2(30 BYTE),
  enq_transformation VARCHAR2(100 BYTE),
  deq_transformation VARCHAR2(100 BYTE),
  allowed_brands VARCHAR2(200 BYTE) DEFAULT 'ALL' NOT NULL,
  allowed_source_types VARCHAR2(200 BYTE) DEFAULT 'ALL' NOT NULL,
  allowed_events VARCHAR2(400 BYTE) DEFAULT 'ALL' NOT NULL,
  PRIMARY KEY (q_name)
);