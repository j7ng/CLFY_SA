CREATE TABLE sa.x_reset_sim_inv (
  objid NUMBER NOT NULL,
  x_sim_serial_no VARCHAR2(30 BYTE),
  x_sim_status VARCHAR2(30 BYTE),
  calltrans_objid NUMBER,
  carrier_objid NUMBER,
  insert_timestamp DATE,
  expire_date DATE,
  CONSTRAINT reset_sim_inv_pk PRIMARY KEY (objid)
);