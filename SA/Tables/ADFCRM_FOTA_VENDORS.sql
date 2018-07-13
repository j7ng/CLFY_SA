CREATE TABLE sa.adfcrm_fota_vendors (
  objid NUMBER NOT NULL,
  vendor VARCHAR2(30 BYTE),
  order_type VARCHAR2(30 BYTE),
  CONSTRAINT adfcrm_fota_vendors_pk PRIMARY KEY (objid) USING INDEX sa.adfcrm_fota_vendors_idx
);
COMMENT ON TABLE sa.adfcrm_fota_vendors IS 'This table is used to store FOTA VENDOR details.';
COMMENT ON COLUMN sa.adfcrm_fota_vendors.objid IS 'OBJID of FOTA VENDOR';
COMMENT ON COLUMN sa.adfcrm_fota_vendors.vendor IS 'VENDOR Name';
COMMENT ON COLUMN sa.adfcrm_fota_vendors.order_type IS 'Vendor Order Type';