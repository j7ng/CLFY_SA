CREATE TABLE sa.queue_routing_tbl (
  source_type VARCHAR2(80 BYTE),
  source_tbl VARCHAR2(80 BYTE),
  source_status VARCHAR2(80 BYTE),
  step_complete VARCHAR2(30 BYTE),
  target_queues VARCHAR2(180 BYTE)
);