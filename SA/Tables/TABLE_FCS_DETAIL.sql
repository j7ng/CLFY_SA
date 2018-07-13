CREATE TABLE sa.table_fcs_detail (
  objid NUMBER,
  line_number NUMBER,
  trans_type NUMBER,
  trans_status NUMBER,
  req_originator VARCHAR2(20 BYTE),
  log_date DATE,
  confirm_date DATE,
  request_number VARCHAR2(10 BYTE),
  req_status VARCHAR2(23 BYTE),
  install_part VARCHAR2(20 BYTE),
  install_serial VARCHAR2(22 BYTE),
  remove_part VARCHAR2(20 BYTE),
  remove_serial VARCHAR2(22 BYTE),
  quantity VARCHAR2(2 BYTE),
  inv_location VARCHAR2(10 BYTE),
  price VARCHAR2(8 BYTE),
  exchange_code VARCHAR2(2 BYTE),
  exch_done_flag VARCHAR2(2 BYTE),
  fail_code VARCHAR2(4 BYTE),
  use_code VARCHAR2(2 BYTE),
  request_note VARCHAR2(255 BYTE),
  line_closed VARCHAR2(2 BYTE),
  error_message VARCHAR2(255 BYTE),
  dev NUMBER,
  curr_owner2owner NUMBER(*,0),
  fcs_detail2fcs_header NUMBER(*,0),
  used_by2case NUMBER(*,0),
  used_by2subcase NUMBER(*,0),
  install2part_mod NUMBER(*,0),
  remove2part_mod NUMBER(*,0)
);
ALTER TABLE sa.table_fcs_detail ADD SUPPLEMENTAL LOG GROUP dmtsora674167648_0 (confirm_date, curr_owner2owner, dev, error_message, exchange_code, exch_done_flag, fail_code, fcs_detail2fcs_header, install2part_mod, install_part, install_serial, inv_location, line_closed, line_number, log_date, objid, price, quantity, remove2part_mod, remove_part, remove_serial, request_note, request_number, req_originator, req_status, trans_status, trans_type, used_by2case, used_by2subcase, use_code) ALWAYS;
COMMENT ON TABLE sa.table_fcs_detail IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.objid IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.line_number IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.trans_type IS 'Transaction type; i.e., 0=request; 1=consume; 2=exchange; 3=close. Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.trans_status IS 'Transaction status; i.e., -1=failed, 0=new, 1=done. Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.req_originator IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.log_date IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.confirm_date IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.request_number IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.req_status IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.install_part IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.install_serial IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.remove_part IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.remove_serial IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.quantity IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.inv_location IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.price IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.exchange_code IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.exch_done_flag IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.fail_code IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.use_code IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.request_note IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.line_closed IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.error_message IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_fcs_detail.curr_owner2owner IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.fcs_detail2fcs_header IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.used_by2case IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.used_by2subcase IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.install2part_mod IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_detail.remove2part_mod IS 'Reserved; custom';