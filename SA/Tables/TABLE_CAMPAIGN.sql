CREATE TABLE sa.table_campaign (
  objid NUMBER,
  cam_type VARCHAR2(20 BYTE),
  cam_code VARCHAR2(20 BYTE),
  start_date DATE,
  end_date DATE,
  objective VARCHAR2(255 BYTE),
  audience VARCHAR2(80 BYTE),
  int_rsrc VARCHAR2(50 BYTE),
  ext_rsrc VARCHAR2(50 BYTE),
  "COST" NUMBER(19,4),
  description VARCHAR2(255 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  budget_amt NUMBER(19,4),
  opps_goal NUMBER,
  won_goal NUMBER,
  revenue_goal NUMBER(19,4),
  status VARCHAR2(30 BYTE),
  products VARCHAR2(80 BYTE),
  arch_ind NUMBER,
  dev NUMBER,
  campaign2currency NUMBER(*,0),
  campaign2price_prog NUMBER(*,0),
  cam_owner2user NUMBER(*,0)
);
ALTER TABLE sa.table_campaign ADD SUPPLEMENTAL LOG GROUP dmtsora633255779_0 (arch_ind, audience, budget_amt, campaign2currency, campaign2price_prog, cam_code, cam_owner2user, cam_type, "COST", description, dev, end_date, ext_rsrc, int_rsrc, "NAME", objective, objid, opps_goal, products, revenue_goal, start_date, status, s_name, won_goal) ALWAYS;
COMMENT ON TABLE sa.table_campaign IS 'A set of information about a marketing program that potentially results in downstream sales activity. Examples include advertising campaigns, trade shows, seminars, etc';
COMMENT ON COLUMN sa.table_campaign.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_campaign.cam_type IS 'Type of marketing campaign:  This is a user-defined pop up with default name Campaign Type';
COMMENT ON COLUMN sa.table_campaign.cam_code IS 'Campaign code; from a user-defined pop up list';
COMMENT ON COLUMN sa.table_campaign.start_date IS 'The starting date for the campaign';
COMMENT ON COLUMN sa.table_campaign.end_date IS 'The ending date for the campaign';
COMMENT ON COLUMN sa.table_campaign.objective IS 'What the campaign is intended to achieve';
COMMENT ON COLUMN sa.table_campaign.audience IS 'Target audience for the campaign';
COMMENT ON COLUMN sa.table_campaign.int_rsrc IS 'Description of internal resources working on the campaign';
COMMENT ON COLUMN sa.table_campaign.ext_rsrc IS 'Description of external resources working on the campaign';
COMMENT ON COLUMN sa.table_campaign."COST" IS 'Amount spent on campaign';
COMMENT ON COLUMN sa.table_campaign.description IS 'Description of the campaign';
COMMENT ON COLUMN sa.table_campaign."NAME" IS 'Name of the campaign';
COMMENT ON COLUMN sa.table_campaign.budget_amt IS 'Goal in currency for the cost of the campaign';
COMMENT ON COLUMN sa.table_campaign.opps_goal IS 'Goal in number of opportunities generated from the campaign';
COMMENT ON COLUMN sa.table_campaign.won_goal IS 'Goal in number of deals won from the campaign';
COMMENT ON COLUMN sa.table_campaign.revenue_goal IS 'Goal in currency of revenue generated from the campaign';
COMMENT ON COLUMN sa.table_campaign.status IS 'Status of the campaign. This is a user-defined popup with default name Campaign Status';
COMMENT ON COLUMN sa.table_campaign.products IS 'Product families addressed by the campaign';
COMMENT ON COLUMN sa.table_campaign.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_campaign.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_campaign.campaign2currency IS 'Currency in which campaign is denominated';
COMMENT ON COLUMN sa.table_campaign.campaign2price_prog IS 'Price program used for the campaign';
COMMENT ON COLUMN sa.table_campaign.cam_owner2user IS 'User responsible for the campaign';