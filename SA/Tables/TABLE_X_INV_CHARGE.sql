CREATE TABLE sa.table_x_inv_charge (
  objid NUMBER,
  inv_charge2carrier NUMBER,
  x_activation_charge NUMBER(6,2),
  x_chargeinv_flag NUMBER,
  x_esn_change NUMBER(6,2),
  x_from NUMBER,
  x_inventory_charge NUMBER(6,2),
  x_max_lines_inv NUMBER,
  x_min_lines_inv NUMBER,
  x_order_charge NUMBER(6,2),
  x_reactivate_charge NUMBER(6,2),
  x_suspend_charge NUMBER(6,2),
  x_tier_type VARCHAR2(10 BYTE),
  x_to NUMBER,
  x_susp_access_charge NUMBER(6,2)
);
ALTER TABLE sa.table_x_inv_charge ADD SUPPLEMENTAL LOG GROUP dmtsora226262074_0 (inv_charge2carrier, objid, x_activation_charge, x_chargeinv_flag, x_esn_change, x_from, x_inventory_charge, x_max_lines_inv, x_min_lines_inv, x_order_charge, x_reactivate_charge, x_suspend_charge, x_susp_access_charge, x_tier_type, x_to) ALWAYS;
COMMENT ON TABLE sa.table_x_inv_charge IS 'Contains charges for keeping lines inventory from a carrier market';
COMMENT ON COLUMN sa.table_x_inv_charge.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_inv_charge.inv_charge2carrier IS 'Carrier Relation to Inventory Charge';
COMMENT ON COLUMN sa.table_x_inv_charge.x_activation_charge IS 'Charge for Activations';
COMMENT ON COLUMN sa.table_x_inv_charge.x_chargeinv_flag IS 'Charge Inventory Flag: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_inv_charge.x_esn_change IS 'Charges for ESN Changes';
COMMENT ON COLUMN sa.table_x_inv_charge.x_from IS 'From Range';
COMMENT ON COLUMN sa.table_x_inv_charge.x_inventory_charge IS 'Inventory Charge';
COMMENT ON COLUMN sa.table_x_inv_charge.x_max_lines_inv IS 'Maximum Lines in Inventory';
COMMENT ON COLUMN sa.table_x_inv_charge.x_min_lines_inv IS 'Minimum Lines in inventory';
COMMENT ON COLUMN sa.table_x_inv_charge.x_order_charge IS 'Charges for Ordering Lines';
COMMENT ON COLUMN sa.table_x_inv_charge.x_reactivate_charge IS 'Charges for Reactivating Lines';
COMMENT ON COLUMN sa.table_x_inv_charge.x_suspend_charge IS 'Charge for Suspending a Line';
COMMENT ON COLUMN sa.table_x_inv_charge.x_tier_type IS 'Tier Type';
COMMENT ON COLUMN sa.table_x_inv_charge.x_to IS 'To Range';
COMMENT ON COLUMN sa.table_x_inv_charge.x_susp_access_charge IS 'Charge for accessing a suspended line';