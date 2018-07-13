CREATE TABLE sa.tf_macaw_inv_interface (
  objid NUMBER,
  m_part_number VARCHAR2(100 BYTE),
  m_part_serial_no VARCHAR2(20 BYTE),
  m_pin_code VARCHAR2(30 BYTE),
  tf_po_num VARCHAR2(30 BYTE),
  m_creation_date DATE,
  tf_extract_flag VARCHAR2(20 BYTE),
  m_invoice_id NUMBER,
  m_invoice_date DATE,
  macaw_id VARCHAR2(20 BYTE)
);
ALTER TABLE sa.tf_macaw_inv_interface ADD SUPPLEMENTAL LOG GROUP dmtsora955188089_0 (macaw_id, m_creation_date, m_invoice_date, m_invoice_id, m_part_number, m_part_serial_no, m_pin_code, objid, tf_extract_flag, tf_po_num) ALWAYS;