CREATE TABLE sa.table_x_campaign_lists (
  objid NUMBER,
  x_serial_number VARCHAR2(30 BYTE),
  x_email VARCHAR2(50 BYTE),
  x_response_dt DATE,
  x_html_ok NUMBER,
  x_disposition_code NUMBER,
  x_camp_lists2x_camp_codes NUMBER
);
ALTER TABLE sa.table_x_campaign_lists ADD SUPPLEMENTAL LOG GROUP dmtsora1978287394_0 (objid, x_camp_lists2x_camp_codes, x_disposition_code, x_email, x_html_ok, x_response_dt, x_serial_number) ALWAYS;