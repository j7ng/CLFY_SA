CREATE TABLE sa.x_republik_order_status_hist (
  toss_order_id NUMBER NOT NULL,
  cancel_request_id NUMBER,
  status VARCHAR2(20 BYTE) NOT NULL,
  created_date DATE NOT NULL
);
ALTER TABLE sa.x_republik_order_status_hist ADD SUPPLEMENTAL LOG GROUP dmtsora755360350_0 (cancel_request_id, created_date, status, toss_order_id) ALWAYS;