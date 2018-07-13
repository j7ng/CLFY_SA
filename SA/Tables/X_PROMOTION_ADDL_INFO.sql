CREATE TABLE sa.x_promotion_addl_info (
  x_active VARCHAR2(20 BYTE),
  x_dll_allow VARCHAR2(20 BYTE),
  x_site_objid NUMBER,
  x_promo_addl2x_promo NUMBER,
  x_delivery_method VARCHAR2(200 BYTE),
  x_cost_center_no NUMBER
);
ALTER TABLE sa.x_promotion_addl_info ADD SUPPLEMENTAL LOG GROUP dmtsora1921120261_0 (x_active, x_cost_center_no, x_delivery_method, x_dll_allow, x_promo_addl2x_promo, x_site_objid) ALWAYS;
COMMENT ON COLUMN sa.x_promotion_addl_info.x_active IS 'Extra Info Record is Active: Y,N';
COMMENT ON COLUMN sa.x_promotion_addl_info.x_dll_allow IS 'Promotion Filter by DLL: Comma delimited dll numbers list or ALL when valid for all DLLs';
COMMENT ON COLUMN sa.x_promotion_addl_info.x_site_objid IS 'Reference to table_site (Dealer)';
COMMENT ON COLUMN sa.x_promotion_addl_info.x_promo_addl2x_promo IS 'Reference to table_x_promotion';
COMMENT ON COLUMN sa.x_promotion_addl_info.x_delivery_method IS 'not used';
COMMENT ON COLUMN sa.x_promotion_addl_info.x_cost_center_no IS 'not used';