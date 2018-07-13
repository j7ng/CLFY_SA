CREATE TABLE sa.x_raf_friends (
  blast_id NUMBER,
  customer_esn VARCHAR2(30 BYTE),
  friend_email VARCHAR2(80 BYTE),
  submission_date DATE,
  viral_flag VARCHAR2(1 BYTE)
);
ALTER TABLE sa.x_raf_friends ADD SUPPLEMENTAL LOG GROUP dmtsora127723023_0 (blast_id, customer_esn, friend_email, submission_date, viral_flag) ALWAYS;