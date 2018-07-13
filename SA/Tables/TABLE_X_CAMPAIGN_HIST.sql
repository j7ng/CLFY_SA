CREATE TABLE sa.table_x_campaign_hist (
  objid NUMBER,
  x_sent_dt DATE,
  x_response_dt DATE,
  x_campaign_hist2contact NUMBER,
  x_campaign_hist2site_part NUMBER,
  x_campaign_hist2x_campaign NUMBER
);
ALTER TABLE sa.table_x_campaign_hist ADD SUPPLEMENTAL LOG GROUP dmtsora105144953_0 (objid, x_campaign_hist2contact, x_campaign_hist2site_part, x_campaign_hist2x_campaign, x_response_dt, x_sent_dt) ALWAYS;