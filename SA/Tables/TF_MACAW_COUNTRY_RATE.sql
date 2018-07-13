CREATE TABLE sa.tf_macaw_country_rate (
  objid NUMBER,
  country_id VARCHAR2(18 BYTE),
  m_country_name VARCHAR2(100 BYTE),
  m_country_rate NUMBER(6,2),
  m_start_date DATE,
  m_end_date DATE
);
ALTER TABLE sa.tf_macaw_country_rate ADD SUPPLEMENTAL LOG GROUP dmtsora1416294983_0 (country_id, m_country_name, m_country_rate, m_end_date, m_start_date, objid) ALWAYS;