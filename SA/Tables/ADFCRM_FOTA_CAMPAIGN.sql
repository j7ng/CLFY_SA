CREATE TABLE sa.adfcrm_fota_campaign (
  objid NUMBER NOT NULL,
  campaign_name VARCHAR2(50 BYTE) NOT NULL,
  vendor VARCHAR2(30 BYTE) NOT NULL,
  activation NUMBER,
  reactivation NUMBER,
  redemption NUMBER,
  created_by VARCHAR2(30 BYTE) NOT NULL,
  creation_time DATE NOT NULL,
  CONSTRAINT adfcrm_fota_campaign_pk PRIMARY KEY (objid) USING INDEX sa.adfcrm_fota_campaign_idx1
);
COMMENT ON TABLE sa.adfcrm_fota_campaign IS 'This table is used to store FOTA CAMPAIGN details.';
COMMENT ON COLUMN sa.adfcrm_fota_campaign.objid IS 'OBJID of CAMPAIGN';
COMMENT ON COLUMN sa.adfcrm_fota_campaign.campaign_name IS 'CAMPAIGN Name';
COMMENT ON COLUMN sa.adfcrm_fota_campaign.vendor IS 'Vendor of CAMPAIGN';
COMMENT ON COLUMN sa.adfcrm_fota_campaign.activation IS 'ACTIVATION Operation of CAMPAIGN Value 0 or 1';
COMMENT ON COLUMN sa.adfcrm_fota_campaign.reactivation IS 'REACTIVATION Operation of CAMPAIGN Value 0 or 1';
COMMENT ON COLUMN sa.adfcrm_fota_campaign.redemption IS 'REDEMPTION Operation of CAMPAIGN Value 0 or 1';
COMMENT ON COLUMN sa.adfcrm_fota_campaign.created_by IS 'Created By';
COMMENT ON COLUMN sa.adfcrm_fota_campaign.creation_time IS 'Creation Time';