CREATE TABLE sa.mtm_tier_x_connections (
  tier_id NUMBER,
  connected_table VARCHAR2(30 BYTE),
  connected_table_objid NUMBER
);
COMMENT ON COLUMN sa.mtm_tier_x_connections.tier_id IS 'REFERS TABLE_X_TIERS.OBJID';
COMMENT ON COLUMN sa.mtm_tier_x_connections.connected_table IS 'THE TABLE NAME TO WHICH TIER IS CONNECTED FOR EXAMPLE: X_SERVICE_PLAN';
COMMENT ON COLUMN sa.mtm_tier_x_connections.connected_table_objid IS 'THE OBJID OF THE TABLE TO WHICH THE TIER IS CONNECTED';