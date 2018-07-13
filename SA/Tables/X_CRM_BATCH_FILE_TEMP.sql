CREATE TABLE sa.x_crm_batch_file_temp (
  rec_type VARCHAR2(30 BYTE),
  app_user VARCHAR2(30 BYTE),
  case_id VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  tracking_no VARCHAR2(30 BYTE),
  status VARCHAR2(200 BYTE),
  new_model VARCHAR2(30 BYTE),
  ff_center VARCHAR2(30 BYTE),
  courier VARCHAR2(30 BYTE),
  shipping_method VARCHAR2(30 BYTE),
  note VARCHAR2(4000 BYTE),
  case_status VARCHAR2(30 BYTE),
  action_item_id VARCHAR2(30 BYTE),
  part_request_objid NUMBER(22),
  case_type VARCHAR2(30 BYTE),
  case_title VARCHAR2(80 BYTE)
);
COMMENT ON COLUMN sa.x_crm_batch_file_temp.note IS 'THIS IS THE NOTE TO BE ADDED. IT WILL STORE IN TABLE_NOTES_LOG';
COMMENT ON COLUMN sa.x_crm_batch_file_temp.case_status IS 'NEW STATUS IN WHICH THE CASE WILL BE UPDATED.';