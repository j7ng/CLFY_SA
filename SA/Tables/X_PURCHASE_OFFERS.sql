CREATE TABLE sa.x_purchase_offers (
  objid NUMBER NOT NULL,
  part_number VARCHAR2(30 BYTE),
  quantity NUMBER,
  purch2promo NUMBER,
  promo_code VARCHAR2(30 BYTE),
  created_on DATE,
  CONSTRAINT purchoff_pk PRIMARY KEY (objid)
);