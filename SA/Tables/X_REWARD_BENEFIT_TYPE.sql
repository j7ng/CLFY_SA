CREATE TABLE sa.x_reward_benefit_type (
  benefit_type_code VARCHAR2(100 BYTE),
  description VARCHAR2(255 BYTE)
);
COMMENT ON TABLE sa.x_reward_benefit_type IS 'STORES INFORMATION ABOUT BENEFIT TYPES';
COMMENT ON COLUMN sa.x_reward_benefit_type.benefit_type_code IS 'BENEFIT_TYPE_CODE is one of LOYALTY_POINTS/UPGRADAE_POINTS/UPGRADE_BENEFITS';
COMMENT ON COLUMN sa.x_reward_benefit_type.description IS 'DESCRIPTION';