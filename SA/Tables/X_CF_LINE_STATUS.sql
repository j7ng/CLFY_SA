CREATE TABLE sa.x_cf_line_status (
  line_status_code VARCHAR2(2 BYTE) NOT NULL,
  description VARCHAR2(20 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_cf_line_status PRIMARY KEY (line_status_code)
);
COMMENT ON COLUMN sa.x_cf_line_status.line_status_code IS 'Description of line status';