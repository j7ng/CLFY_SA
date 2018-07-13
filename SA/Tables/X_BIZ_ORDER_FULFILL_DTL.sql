CREATE TABLE sa.x_biz_order_fulfill_dtl (
  order_id VARCHAR2(50 BYTE),
  esn VARCHAR2(50 BYTE),
  sim VARCHAR2(50 BYTE),
  smp VARCHAR2(20 BYTE),
  accessory_serial VARCHAR2(50 BYTE),
  app_part_number VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  modified_timestamp DATE DEFAULT SYSDATE
);
COMMENT ON TABLE sa.x_biz_order_fulfill_dtl IS 'Table to connect Order ESN and generated SMP';
COMMENT ON COLUMN sa.x_biz_order_fulfill_dtl.order_id IS 'Ecommerce Order ID';
COMMENT ON COLUMN sa.x_biz_order_fulfill_dtl.esn IS 'ESN';
COMMENT ON COLUMN sa.x_biz_order_fulfill_dtl.sim IS 'SIM';
COMMENT ON COLUMN sa.x_biz_order_fulfill_dtl.smp IS 'Generated SOFT PIN for the ORDER';
COMMENT ON COLUMN sa.x_biz_order_fulfill_dtl.accessory_serial IS 'Accessory serial number';
COMMENT ON COLUMN sa.x_biz_order_fulfill_dtl.app_part_number IS 'APP Part number used to generate SOFTPIN';