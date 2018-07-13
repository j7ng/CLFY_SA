CREATE TABLE sa.x_raf_replies (
  blast_id NUMBER,
  friend_esn VARCHAR2(30 BYTE),
  customer_esn VARCHAR2(30 BYTE),
  register_date DATE,
  reply_date DATE,
  friend_min VARCHAR2(30 BYTE),
  friend_email VARCHAR2(80 BYTE),
  units_sent VARCHAR2(1 BYTE),
  card_objid_customer NUMBER,
  card_objid_friend NUMBER,
  card_smp_customer VARCHAR2(30 BYTE),
  card_smp_friend VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_raf_replies ADD SUPPLEMENTAL LOG GROUP dmtsora1200627693_0 (blast_id, card_objid_customer, card_objid_friend, card_smp_customer, card_smp_friend, customer_esn, friend_email, friend_esn, friend_min, register_date, reply_date, units_sent) ALWAYS;