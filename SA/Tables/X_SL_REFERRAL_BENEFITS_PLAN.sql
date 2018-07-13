CREATE TABLE sa.x_sl_referral_benefits_plan (
  objid NUMBER,
  enrolled_esn VARCHAR2(30 BYTE),
  safelink_esn VARCHAR2(30 BYTE),
  start_enrolled_date DATE DEFAULT SYSDATE,
  end_enrolled_date DATE DEFAULT TO_DATE('12/31/2055 11:59:59 PM','MM/DD/YYYY HH:MI:SS AM'),
  benefits_enrolled VARCHAR2(4000 BYTE)
);
COMMENT ON TABLE sa.x_sl_referral_benefits_plan IS 'TABLE TO STORE THE RATE PLAN HISTORY FOR ESNS';
COMMENT ON COLUMN sa.x_sl_referral_benefits_plan.objid IS 'THE OBJECT ID OF THE TABLE; PRIMARY KEY';
COMMENT ON COLUMN sa.x_sl_referral_benefits_plan.enrolled_esn IS 'THE NON-SAFELINK ESN BEING ENROLLED';
COMMENT ON COLUMN sa.x_sl_referral_benefits_plan.safelink_esn IS 'THE REFERENCE SAFELINK ESN';
COMMENT ON COLUMN sa.x_sl_referral_benefits_plan.start_enrolled_date IS 'THE START DATE OF ENROLLMENT';
COMMENT ON COLUMN sa.x_sl_referral_benefits_plan.end_enrolled_date IS 'THE END DATE OF ENROLLMENT';
COMMENT ON COLUMN sa.x_sl_referral_benefits_plan.benefits_enrolled IS 'BENEFITS THE ESN WAS ENROLLED INTO';