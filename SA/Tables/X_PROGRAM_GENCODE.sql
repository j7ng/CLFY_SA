CREATE TABLE sa.x_program_gencode (
  objid NUMBER NOT NULL,
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_insert_date DATE NOT NULL,
  x_post_date DATE,
  x_status VARCHAR2(15 BYTE) NOT NULL,
  x_error_num VARCHAR2(10 BYTE),
  x_error_string VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  gencode2prog_purch_hdr NUMBER,
  gencode2call_trans NUMBER,
  x_ota_trans_id NUMBER,
  x_sweep_and_add_flag NUMBER,
  x_priority NUMBER,
  sw_flag VARCHAR2(100 BYTE),
  x_smp VARCHAR2(50 BYTE)
);
ALTER TABLE sa.x_program_gencode ADD SUPPLEMENTAL LOG GROUP dmtsora624565253_0 (gencode2call_trans, gencode2prog_purch_hdr, objid, x_error_num, x_error_string, x_esn, x_insert_date, x_post_date, x_status, x_update_stamp) ALWAYS;
COMMENT ON TABLE sa.x_program_gencode IS 'Support table for the delivery of billing plan benefits.  It is use in conjuction with table_x_pending_redemption to trigger gencodes and the deliver ota messages with benefits.';
COMMENT ON COLUMN sa.x_program_gencode.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_program_gencode.x_esn IS 'Phone Serial Number, reference to part_serial_no in table_part_inst';
COMMENT ON COLUMN sa.x_program_gencode.x_insert_date IS 'Creation Date';
COMMENT ON COLUMN sa.x_program_gencode.x_post_date IS 'Not used';
COMMENT ON COLUMN sa.x_program_gencode.x_status IS 'Status of the transaction: FAILED INSERTED,NOPENDING,POSTED,PREPROCESSED,PROCESSED,STRPROCESSED,STRSCHEDULED';
COMMENT ON COLUMN sa.x_program_gencode.x_error_num IS 'Error Number for Failed transaction ';
COMMENT ON COLUMN sa.x_program_gencode.x_error_string IS 'Error Description for Failed transaction ';
COMMENT ON COLUMN sa.x_program_gencode.x_update_stamp IS 'Latest timestamp';
COMMENT ON COLUMN sa.x_program_gencode.gencode2prog_purch_hdr IS 'Reference to x_program_purch_hdr';
COMMENT ON COLUMN sa.x_program_gencode.gencode2call_trans IS 'Reference to table_x_call_trans';
COMMENT ON COLUMN sa.x_program_gencode.x_ota_trans_id IS 'OTA Transaction counter, same as x_counter in table_x_ota_transaction';
COMMENT ON COLUMN sa.x_program_gencode.x_sweep_and_add_flag IS 'Sweep and Add flag: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_gencode.x_priority IS 'Priority for batch process';
COMMENT ON COLUMN sa.x_program_gencode.sw_flag IS 'switch based flag Y/N';