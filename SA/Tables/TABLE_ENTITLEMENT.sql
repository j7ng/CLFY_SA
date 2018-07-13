CREATE TABLE sa.table_entitlement (
  objid NUMBER,
  entitle_id VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  "TYPE" VARCHAR2(40 BYTE),
  "ACTIVE" NUMBER,
  "COST" NUMBER(19,4),
  unit_measure VARCHAR2(20 BYTE),
  incl_parts NUMBER,
  incl_labor NUMBER,
  taxable NUMBER,
  delivery_type NUMBER,
  "CATEGORY" NUMBER,
  response_time NUMBER,
  ctgry_name VARCHAR2(20 BYTE),
  dev NUMBER,
  cover_hrs2biz_cal_hdr NUMBER(*,0),
  curr_type2currency NUMBER(*,0),
  entitlement2wk_work_hr NUMBER(*,0),
  service2mod_level NUMBER(*,0)
);
ALTER TABLE sa.table_entitlement ADD SUPPLEMENTAL LOG GROUP dmtsora875556778_0 ("ACTIVE", "CATEGORY", "COST", cover_hrs2biz_cal_hdr, ctgry_name, curr_type2currency, delivery_type, description, dev, entitlement2wk_work_hr, entitle_id, incl_labor, incl_parts, "NAME", objid, response_time, service2mod_level, taxable, "TYPE", unit_measure) ALWAYS;