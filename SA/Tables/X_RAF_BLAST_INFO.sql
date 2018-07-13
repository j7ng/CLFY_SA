CREATE TABLE sa.x_raf_blast_info (
  blast_id NUMBER,
  blast_date DATE NOT NULL,
  blast_expire_date DATE NOT NULL,
  registration_days NUMBER NOT NULL,
  blast_count NUMBER NOT NULL,
  customer_part_num VARCHAR2(30 BYTE),
  friend_part_num VARCHAR2(30 BYTE),
  blast_desc VARCHAR2(80 BYTE) NOT NULL,
  refer_message VARCHAR2(255 BYTE) NOT NULL,
  customer_message VARCHAR2(4000 BYTE),
  friend_message VARCHAR2(4000 BYTE),
  customer_message_subject VARCHAR2(200 BYTE),
  friend_message_subject VARCHAR2(200 BYTE)
);
ALTER TABLE sa.x_raf_blast_info ADD SUPPLEMENTAL LOG GROUP dmtsora860184432_0 (blast_count, blast_date, blast_desc, blast_expire_date, blast_id, customer_message, customer_message_subject, customer_part_num, friend_message, friend_message_subject, friend_part_num, refer_message, registration_days) ALWAYS;