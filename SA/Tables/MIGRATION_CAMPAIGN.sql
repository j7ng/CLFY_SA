CREATE TABLE sa.migration_campaign (
  campaign_name VARCHAR2(200 BYTE) NOT NULL,
  is_campaign_active VARCHAR2(1 BYTE) NOT NULL,
  offer_title VARCHAR2(200 BYTE),
  script_id VARCHAR2(2000 BYTE),
  phone_status VARCHAR2(100 BYTE),
  display_alert VARCHAR2(1000 BYTE) NOT NULL,
  block_functionality VARCHAR2(2000 BYTE),
  alert_severity VARCHAR2(4 BYTE) NOT NULL,
  case_type VARCHAR2(30 BYTE),
  case_title VARCHAR2(80 BYTE),
  default_repl_pn VARCHAR2(30 BYTE),
  bright_point_inserts VARCHAR2(200 BYTE),
  description VARCHAR2(1000 BYTE) NOT NULL,
  approved_cr_or_ticket VARCHAR2(100 BYTE) NOT NULL,
  requested_by VARCHAR2(100 BYTE) NOT NULL,
  creation_date DATE,
  updated_by VARCHAR2(100 BYTE) NOT NULL,
  update_date DATE,
  expiration_date DATE
);
COMMENT ON COLUMN sa.migration_campaign.campaign_name IS 'Name of the Offer - Pref all caps  with underscores - REQUIRED FIELD';
COMMENT ON COLUMN sa.migration_campaign.is_campaign_active IS 'Y or N - Either an offer is active or not - REQUIRED FIELD';
COMMENT ON COLUMN sa.migration_campaign.offer_title IS 'This is the alert title. That will display on the front ends.';
COMMENT ON COLUMN sa.migration_campaign.script_id IS 'This alert is script id driven - See Scripting team when making a new offer';
COMMENT ON COLUMN sa.migration_campaign.phone_status IS 'Status of the ESN being evaluated - Add as a comma separated string - see example ''50,51,52,54'' ';
COMMENT ON COLUMN sa.migration_campaign.display_alert IS 'Where should this alert be displayed - see example ''TAS,IVR,WEB,SMS'' One must be specified - REQUIRED FIELD';
COMMENT ON COLUMN sa.migration_campaign.block_functionality IS 'Fucntional or Areas that are to be blocked until a case is created. If blank no areas are blocked. Will only work if the front end teams develop for it. ACTIVATION,REDEMPTION,ENROLLMENTS,UPGRADE. However, if you use HOT, it will keep the alert hot regardless of case status ';
COMMENT ON COLUMN sa.migration_campaign.alert_severity IS 'This value should only be HOT or COLD - REQUIRED FIELD';
COMMENT ON COLUMN sa.migration_campaign.case_type IS 'This should be entered exactly as column (x_case_type) in table_x_case_conf_hdr ';
COMMENT ON COLUMN sa.migration_campaign.case_title IS 'This should be entered exactly as column (x_title) in table_x_case_conf_hdr ';
COMMENT ON COLUMN sa.migration_campaign.default_repl_pn IS 'The default replacement part number';
COMMENT ON COLUMN sa.migration_campaign.bright_point_inserts IS 'Advise BP what insert needs to be used for this type of migration - current defined at the campaign level';
COMMENT ON COLUMN sa.migration_campaign.description IS 'A brief description of what this offer is about. This is NOT the actual text that will show in the popup. - REQUIRED FIELD';
COMMENT ON COLUMN sa.migration_campaign.approved_cr_or_ticket IS 'Requested by Teebu. This is to tie all migration offers to a CR or Ticket.';
COMMENT ON COLUMN sa.migration_campaign.requested_by IS 'Requested by Teebu. This is to tie all migration offers to a user.';
COMMENT ON COLUMN sa.migration_campaign.creation_date IS 'Used by the case ship confirm validation query. To check When this alert was requested.';
COMMENT ON COLUMN sa.migration_campaign.expiration_date IS 'Date the alert is supposed to expire';