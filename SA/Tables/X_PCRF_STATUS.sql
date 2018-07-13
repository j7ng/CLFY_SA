CREATE TABLE sa.x_pcrf_status (
  pcrf_status_code VARCHAR2(2 BYTE) NOT NULL,
  description VARCHAR2(50 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_pcrf_status_pk PRIMARY KEY (pcrf_status_code)
);
COMMENT ON TABLE sa.x_pcrf_status IS 'Stores the PCRF status code and description';
COMMENT ON COLUMN sa.x_pcrf_status.pcrf_status_code IS 'Stores the different PCRF transaction status codes';
COMMENT ON COLUMN sa.x_pcrf_status.description IS 'Description of pcrf status code';
COMMENT ON COLUMN sa.x_pcrf_status.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_pcrf_status.update_timestamp IS 'Last date when the record was last modified';