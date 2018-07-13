CREATE TABLE sa.x_service_provider_config (
  objid NUMBER(*,0),
  service_provider VARCHAR2(10 BYTE),
  service_provider_desc VARCHAR2(100 BYTE),
  brand_name VARCHAR2(30 BYTE),
  backbone_provider VARCHAR2(10 BYTE),
  backbone_provider_desc VARCHAR2(100 BYTE)
);
COMMENT ON COLUMN sa.x_service_provider_config.objid IS 'Uniquely Identifies the record';
COMMENT ON COLUMN sa.x_service_provider_config.service_provider IS 'Name of the Service Provider';
COMMENT ON COLUMN sa.x_service_provider_config.service_provider_desc IS 'Description of the Service Provider';
COMMENT ON COLUMN sa.x_service_provider_config.brand_name IS 'Brand Name';
COMMENT ON COLUMN sa.x_service_provider_config.backbone_provider IS 'Backbone Service Provider';
COMMENT ON COLUMN sa.x_service_provider_config.backbone_provider_desc IS 'Backbone Service Provider Desc';