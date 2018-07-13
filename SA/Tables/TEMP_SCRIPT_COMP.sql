CREATE TABLE sa.temp_script_comp (
  total_rtrp NUMBER,
  x_script_id VARCHAR2(20 BYTE),
  x_script_type VARCHAR2(20 BYTE),
  x_technology VARCHAR2(20 BYTE),
  script2bus_org NUMBER,
  x_language VARCHAR2(20 BYTE),
  max_pub_date DATE,
  checked_by VARCHAR2(50 BYTE),
  time_ckd DATE DEFAULT sysdate
);