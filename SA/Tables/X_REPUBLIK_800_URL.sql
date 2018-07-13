CREATE TABLE sa.x_republik_800_url (
  product_code VARCHAR2(10 BYTE),
  phone_number VARCHAR2(20 BYTE),
  promo_code VARCHAR2(10 BYTE),
  promotion_desc VARCHAR2(80 BYTE),
  language VARCHAR2(20 BYTE),
  media_outlet VARCHAR2(100 BYTE),
  media VARCHAR2(20 BYTE),
  time_start DATE,
  time_end DATE,
  url VARCHAR2(200 BYTE)
);
ALTER TABLE sa.x_republik_800_url ADD SUPPLEMENTAL LOG GROUP dmtsora24637807_0 (language, media, media_outlet, phone_number, product_code, promotion_desc, promo_code, time_end, time_start, url) ALWAYS;