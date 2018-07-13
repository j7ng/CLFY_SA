CREATE TABLE sa.table_price_factor (
  objid NUMBER,
  factor_id VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  "TYPE" VARCHAR2(40 BYTE),
  start_date DATE,
  end_date DATE,
  precedence NUMBER,
  "ACTIVE" NUMBER,
  fxd_amt NUMBER(19,4),
  pct NUMBER(19,4),
  factor_base NUMBER,
  eligible_hdr NUMBER,
  eligible_dtl NUMBER,
  dev NUMBER,
  factor2currency NUMBER(*,0)
);
ALTER TABLE sa.table_price_factor ADD SUPPLEMENTAL LOG GROUP dmtsora1493829034_0 ("ACTIVE", description, dev, eligible_dtl, eligible_hdr, end_date, factor2currency, factor_base, factor_id, fxd_amt, "NAME", objid, pct, precedence, start_date, "TYPE") ALWAYS;