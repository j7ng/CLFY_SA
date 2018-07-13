CREATE TABLE sa.x_promotion_prefer_site (
  site_objid NUMBER,
  promo_code VARCHAR2(30 BYTE),
  "ACTIVE" VARCHAR2(10 BYTE),
  dll_allow VARCHAR2(2000 BYTE)
);
ALTER TABLE sa.x_promotion_prefer_site ADD SUPPLEMENTAL LOG GROUP dmtsora583305314_0 ("ACTIVE", dll_allow, promo_code, site_objid) ALWAYS;