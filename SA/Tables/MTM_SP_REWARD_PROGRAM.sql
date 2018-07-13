CREATE TABLE sa.mtm_sp_reward_program (
  objid NUMBER NOT NULL,
  service_plan_objid NUMBER,
  reward_program_objid NUMBER,
  reward_point NUMBER,
  start_date DATE,
  end_date DATE,
  brand VARCHAR2(100 BYTE),
  source_system VARCHAR2(100 BYTE),
  last_updated_date DATE,
  reward_point_auto_refill NUMBER(22),
  points_required_to_redeem NUMBER(22),
  CONSTRAINT mtm_rwd_objid_pk PRIMARY KEY (objid),
  CONSTRAINT sp_reward_unique UNIQUE (service_plan_objid,reward_program_objid,brand,start_date,end_date)
);
COMMENT ON TABLE sa.mtm_sp_reward_program IS 'Table contains the points associated with service plan feature';
COMMENT ON COLUMN sa.mtm_sp_reward_program.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.mtm_sp_reward_program.service_plan_objid IS 'link to service plan objid ';
COMMENT ON COLUMN sa.mtm_sp_reward_program.reward_program_objid IS 'link to reward program objid';
COMMENT ON COLUMN sa.mtm_sp_reward_program.reward_point IS 'No. of points';
COMMENT ON COLUMN sa.mtm_sp_reward_program.start_date IS 'Date when the points are effective';
COMMENT ON COLUMN sa.mtm_sp_reward_program.end_date IS 'Date until which the points are effective';
COMMENT ON COLUMN sa.mtm_sp_reward_program.reward_point_auto_refill IS 'No. of points for Auto Refill';
COMMENT ON COLUMN sa.mtm_sp_reward_program.points_required_to_redeem IS 'NEW COLUMN TO HOLD POINTS, REQUIRED TO REDEEM THE SERVICE PLAN';