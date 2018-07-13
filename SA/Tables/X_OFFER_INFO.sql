CREATE TABLE sa.x_offer_info (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  promo_type VARCHAR2(30 BYTE),
  offer_type VARCHAR2(30 BYTE),
  offer_desc VARCHAR2(400 BYTE),
  cash_value NUMBER,
  unit_value NUMBER,
  part_number VARCHAR2(30 BYTE),
  technology VARCHAR2(80 BYTE),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  offerinfo2pnum NUMBER(22),
  sp_objid NUMBER(22),
  "COS" VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_offer_info ADD SUPPLEMENTAL LOG GROUP dmtsora150688211_0 (cash_value, end_date, "NAME", objid, offer_desc, offer_type, part_number, promo_type, start_date, technology, unit_value) ALWAYS;