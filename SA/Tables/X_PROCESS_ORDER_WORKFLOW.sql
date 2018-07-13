CREATE TABLE sa.x_process_order_workflow (
  process_order_objid NUMBER NOT NULL,
  process_order_detail_objid NUMBER NOT NULL,
  updated_by VARCHAR2(30 BYTE) NOT NULL,
  updated_order_status VARCHAR2(50 BYTE) NOT NULL,
  comments VARCHAR2(1000 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE
);