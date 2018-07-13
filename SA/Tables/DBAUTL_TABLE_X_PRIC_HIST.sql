CREATE TABLE sa.dbautl_table_x_pric_hist (
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
  x_card_type NUMBER,
  x_special_type VARCHAR2(20 BYTE),
  x_brand_name VARCHAR2(30 BYTE),
  x_channel VARCHAR2(30 BYTE),
  delete_dt TIMESTAMP,
  delete_by VARCHAR2(50 BYTE)
);