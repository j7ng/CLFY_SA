CREATE TABLE sa.tf_macaw_country_rate_hist (
  objid NUMBER,
  country_id VARCHAR2(18 BYTE),
  m_country_name VARCHAR2(100 BYTE),
  m_country_rate NUMBER(6,2),
  m_start_date DATE,
  m_end_date DATE,
  update_stamp DATE
);
ALTER TABLE sa.tf_macaw_country_rate_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1699717110_0 (country_id, m_country_name, m_country_rate, m_end_date, m_start_date, objid, update_stamp) ALWAYS;