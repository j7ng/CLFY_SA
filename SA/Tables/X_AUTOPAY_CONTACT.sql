CREATE TABLE sa.x_autopay_contact (
  objid NUMBER,
  esn VARCHAR2(30 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  address VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(40 BYTE),
  zip VARCHAR2(20 BYTE),
  phone VARCHAR2(20 BYTE),
  contact2autopay_details NUMBER
);
ALTER TABLE sa.x_autopay_contact ADD SUPPLEMENTAL LOG GROUP dmtsora206208947_0 (address, city, contact2autopay_details, esn, first_name, last_name, objid, phone, "STATE", zip) ALWAYS;