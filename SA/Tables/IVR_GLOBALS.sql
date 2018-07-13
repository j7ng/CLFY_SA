CREATE TABLE sa.ivr_globals (
  channel VARCHAR2(30 BYTE),
  public_x_expire_dt DATE,
  public_redeem_days VARCHAR2(30 BYTE),
  public_redeem_units NUMBER,
  public_warr_end_date DATE,
  public_site_part_objid NUMBER,
  public_red_code VARCHAR2(100 BYTE)
);
ALTER TABLE sa.ivr_globals ADD SUPPLEMENTAL LOG GROUP dmtsora370731501_0 (channel, public_redeem_days, public_redeem_units, public_red_code, public_site_part_objid, public_warr_end_date, public_x_expire_dt) ALWAYS;