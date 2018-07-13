CREATE OR REPLACE FORCE VIEW sa.ota_ackn_trans_hist_view (x_esn,x_min,x_counter,ota_trans_objid,call_trans_objid,code_hist_objid,x_sequence,x_code_accepted,x_code_type,x_seq_update,x_result) AS
SELECT   ot.x_esn
 ,ot.x_min
 ,ot.x_counter
 ,ot.objid  ota_trans_objid
 ,h.CODE_HIST2CALL_TRANS call_trans_objid
 ,h.OBJID   code_hist_objid
 ,h.X_SEQUENCE
 ,h.X_CODE_ACCEPTED
 ,h.X_CODE_TYPE
 ,h.X_SEQ_UPDATE
 ,ct.X_RESULT
FROM
  table_x_ota_transaction ot
 ,table_x_call_trans  ct
 ,table_x_code_hist  h
WHERE ot.X_OTA_TRANS2X_CALL_TRANS = ct.OBJID
AND h.CODE_HIST2CALL_TRANS  = ct.OBJID
AND ot.X_STATUS = 'OTA PENDING'
ORDER BY h.OBJID;