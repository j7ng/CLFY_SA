CREATE TABLE sa.x_rtr_trans_dtl_discount (
  objid NUMBER NOT NULL,
  rtr_trans_detail_objid NUMBER,
  discount_code VARCHAR2(100 BYTE),
  discount_amount NUMBER,
  insert_timestamp DATE,
  update_timestamp DATE,
  CONSTRAINT pk_rtr_trans_dtl_discount PRIMARY KEY (objid),
  CONSTRAINT fk1_rtr_trans_dtl_discount FOREIGN KEY (rtr_trans_detail_objid) REFERENCES sa.x_rtr_trans_detail (objid)
);