CREATE TABLE sa.x_pricing_hist (
  objid NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_web_link VARCHAR2(100 BYTE),
  x_web_description VARCHAR2(100 BYTE),
  x_retail_price NUMBER(8,2),
  x_type VARCHAR2(10 BYTE),
  x_pricing2part_num NUMBER,
  x_fin_priceline_id NUMBER,
  x_sp_web_description VARCHAR2(100 BYTE),
  pricing_hist2pricing NUMBER,
  x_pricing_hist2user NUMBER,
  x_change_date DATE,
  osuser VARCHAR2(30 BYTE),
  triggering_record_type VARCHAR2(6 BYTE)
);
ALTER TABLE sa.x_pricing_hist ADD SUPPLEMENTAL LOG GROUP dmtsora519256189_0 (objid, osuser, pricing_hist2pricing, triggering_record_type, x_change_date, x_end_date, x_fin_priceline_id, x_pricing2part_num, x_pricing_hist2user, x_retail_price, x_sp_web_description, x_start_date, x_type, x_web_description, x_web_link) ALWAYS;