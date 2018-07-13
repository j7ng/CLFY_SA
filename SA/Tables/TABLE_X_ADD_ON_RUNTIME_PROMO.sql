CREATE TABLE sa.table_x_add_on_runtime_promo (
  objid NUMBER NOT NULL,
  promo_group VARCHAR2(30 BYTE) NOT NULL,
  promo_group_desc VARCHAR2(500 BYTE),
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_min VARCHAR2(30 BYTE),
  sp_objid NUMBER,
  start_date DATE,
  end_date DATE,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE
);