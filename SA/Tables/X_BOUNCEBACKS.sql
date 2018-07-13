CREATE TABLE sa.x_bouncebacks (
  address VARCHAR2(100 BYTE)
);
ALTER TABLE sa.x_bouncebacks ADD SUPPLEMENTAL LOG GROUP dmtsora904791407_0 (address) ALWAYS;