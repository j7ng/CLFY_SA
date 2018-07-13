CREATE TABLE sa.b2b_inventory (
  item_code VARCHAR2(50 BYTE),
  material_type VARCHAR2(50 BYTE),
  description VARCHAR2(200 BYTE),
  warehouse VARCHAR2(50 BYTE),
  on_hand VARCHAR2(30 BYTE),
  "COMMITTED" VARCHAR2(30 BYTE),
  bko VARCHAR2(30 BYTE),
  available VARCHAR2(30 BYTE),
  open_pos VARCHAR2(30 BYTE),
  shipments_mtd VARCHAR2(30 BYTE),
  shipments_ytd VARCHAR2(30 BYTE)
);