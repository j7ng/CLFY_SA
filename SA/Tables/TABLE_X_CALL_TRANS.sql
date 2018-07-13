CREATE TABLE sa.table_x_call_trans (
  objid NUMBER,
  call_trans2site_part NUMBER,
  x_action_type VARCHAR2(20 BYTE),
  x_call_trans2carrier NUMBER,
  x_call_trans2dealer NUMBER,
  x_call_trans2user NUMBER,
  x_line_status VARCHAR2(20 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_service_id VARCHAR2(30 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_transact_date DATE,
  x_total_units NUMBER,
  x_action_text VARCHAR2(20 BYTE),
  x_reason VARCHAR2(500 BYTE),
  x_result VARCHAR2(20 BYTE),
  x_sub_sourcesystem VARCHAR2(30 BYTE),
  x_iccid VARCHAR2(30 BYTE),
  x_ota_req_type VARCHAR2(30 BYTE),
  x_ota_type VARCHAR2(30 BYTE),
  x_call_trans2x_ota_code_hist NUMBER,
  x_new_due_date DATE,
  update_stamp DATE
);
ALTER TABLE sa.table_x_call_trans ADD SUPPLEMENTAL LOG GROUP dmtsora1180931000_0 (call_trans2site_part, objid, x_action_text, x_action_type, x_call_trans2carrier, x_call_trans2dealer, x_call_trans2user, x_call_trans2x_ota_code_hist, x_iccid, x_line_status, x_min, x_new_due_date, x_ota_req_type, x_ota_type, x_reason, x_result, x_service_id, x_sourcesystem, x_sub_sourcesystem, x_total_units, x_transact_date) ALWAYS;
COMMENT ON TABLE sa.table_x_call_trans IS 'Stores all the transactions that happen for a particular service';
COMMENT ON COLUMN sa.table_x_call_trans.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_call_trans.call_trans2site_part IS 'Call transaction relation for site_part';
COMMENT ON COLUMN sa.table_x_call_trans.x_action_type IS 'Type of action taken during the Transaction -- Activation/Deactivation';
COMMENT ON COLUMN sa.table_x_call_trans.x_call_trans2carrier IS 'Call Transaction Relation to Carrier';
COMMENT ON COLUMN sa.table_x_call_trans.x_call_trans2dealer IS 'Dealer  who sold the Phone';
COMMENT ON COLUMN sa.table_x_call_trans.x_call_trans2user IS 'User who attended to the transaction';
COMMENT ON COLUMN sa.table_x_call_trans.x_line_status IS 'Status of the Line (Active/Inactive)';
COMMENT ON COLUMN sa.table_x_call_trans.x_min IS 'Line Number/Phone Number';
COMMENT ON COLUMN sa.table_x_call_trans.x_service_id IS 'Phone Serial Number for Wireless and Service Id for Wireline';
COMMENT ON COLUMN sa.table_x_call_trans.x_sourcesystem IS 'Source System of the Transaction (CSR/IVR)';
COMMENT ON COLUMN sa.table_x_call_trans.x_transact_date IS 'Date/Time on which Transaction occurred';
COMMENT ON COLUMN sa.table_x_call_trans.x_total_units IS 'Total units redeemed during a call transaction';
COMMENT ON COLUMN sa.table_x_call_trans.x_action_text IS 'Code Name';
COMMENT ON COLUMN sa.table_x_call_trans.x_reason IS 'Reason for the Call Action - used in addition to x_action_type';
COMMENT ON COLUMN sa.table_x_call_trans.x_result IS 'Result of the call transaction, i.e. Completed or Failed';
COMMENT ON COLUMN sa.table_x_call_trans.x_sub_sourcesystem IS 'TBD';
COMMENT ON COLUMN sa.table_x_call_trans.x_iccid IS 'SIM Serial Number';
COMMENT ON COLUMN sa.table_x_call_trans.x_ota_req_type IS 'OTA Req type';
COMMENT ON COLUMN sa.table_x_call_trans.x_ota_type IS 'OTA transaction type';
COMMENT ON COLUMN sa.table_x_call_trans.x_call_trans2x_ota_code_hist IS 'Transaction record for OTA relation';
COMMENT ON COLUMN sa.table_x_call_trans.x_new_due_date IS 'New due date for the transaction';
COMMENT ON COLUMN sa.table_x_call_trans.update_stamp IS 'LAST DATE THE RECORD WAS UPDATED';