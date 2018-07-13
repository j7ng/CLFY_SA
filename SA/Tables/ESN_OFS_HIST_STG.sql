CREATE TABLE sa.esn_ofs_hist_stg (
  "PROCESS" VARCHAR2(4 BYTE),
  tp_location_code VARCHAR2(35 BYTE),
  shipment_num VARCHAR2(40 BYTE),
  creation_date DATE,
  shipped_date DATE,
  order_num VARCHAR2(100 BYTE),
  cust_po VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(150 BYTE),
  status VARCHAR2(1 BYTE),
  part_number VARCHAR2(100 BYTE),
  qty_shipped NUMBER,
  serial_number VARCHAR2(100 BYTE),
  qty NUMBER
);