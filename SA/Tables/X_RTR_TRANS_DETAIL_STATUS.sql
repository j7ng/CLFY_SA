CREATE TABLE sa.x_rtr_trans_detail_status (
  rtr_trans_detail_status VARCHAR2(100 BYTE) NOT NULL,
  description VARCHAR2(200 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_rtr_trans_detail_status PRIMARY KEY (rtr_trans_detail_status)
);