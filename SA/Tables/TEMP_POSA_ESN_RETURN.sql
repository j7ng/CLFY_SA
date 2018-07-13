CREATE TABLE sa.temp_posa_esn_return (
  ip_esn_num VARCHAR2(30 BYTE),
  ip_upc_code VARCHAR2(30 BYTE),
  ip_date DATE,
  ip_time DATE,
  ip_trans_id NUMBER,
  ip_trans_type CHAR(8 BYTE),
  ip_merchant_id NUMBER,
  ip_store_detail NUMBER,
  ip_sourcesystem CHAR(4 BYTE)
);