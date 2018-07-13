CREATE TABLE sa.x_special_promotion (
  objid NUMBER NOT NULL,
  spl_promo_type VARCHAR2(30 BYTE) NOT NULL,
  spl_promo_desc VARCHAR2(500 BYTE) NOT NULL,
  promo_objid NUMBER,
  start_date DATE,
  end_date DATE,
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  old_pe_objid NUMBER,
  spl_promo2busorg NUMBER NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE
);