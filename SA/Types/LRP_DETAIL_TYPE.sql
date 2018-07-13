CREATE OR REPLACE TYPE sa.lrp_detail_type AS OBJECT
(
service_plan_objid           NUMBER,
available_for_lrp_flag       VARCHAR2(1),
points_required_to_redeem    NUMBER,
points_accrued_by_purchase   NUMBER,
points_accrued_by_autorefill NUMBER,
status                       VARCHAR2(4000),
CONSTRUCTOR FUNCTION lrp_detail_type RETURN SELF AS RESULT,
CONSTRUCTOR FUNCTION lrp_detail_type ( i_service_plan_objid  IN NUMBER ) RETURN SELF AS RESULT,
MEMBER FUNCTION retrieve ( i_service_plan_objid  IN NUMBER,
                           i_vas_program_flag    IN VARCHAR2,
                           i_channel             IN VARCHAR2 DEFAULT 'WEB')  RETURN lrp_detail_type
);
/
CREATE OR REPLACE TYPE BODY sa.lrp_detail_type IS
  CONSTRUCTOR FUNCTION lrp_detail_type RETURN SELF AS RESULT
  IS
  BEGIN
    RETURN;
  END lrp_detail_type;

  CONSTRUCTOR FUNCTION lrp_detail_type ( i_service_plan_objid  IN NUMBER ) RETURN SELF AS RESULT
  IS
  BEGIN
    IF i_service_plan_objid IS NOT NULL
    THEN
      SELF.service_plan_objid := i_service_plan_objid;
      self := self.retrieve (i_service_plan_objid => i_service_plan_objid, i_vas_program_flag => 'Y');
      SELF.STATUS := 'SUCCESS';
    END IF;
    RETURN;
  END lrp_detail_type;

--CR55804 start
--removed, points getting based on the calculation logic, which required to buy a service plan.
--fetching the points, required to redeem the service plan from sa.mtm_sp_reward_program.points_required_to_redeem table

  MEMBER FUNCTION retrieve ( i_service_plan_objid  IN NUMBER,
                             i_vas_program_flag    IN VARCHAR2,
                             i_channel             IN VARCHAR2 DEFAULT 'WEB')  RETURN lrp_detail_type
  IS

    lrp_type            lrp_detail_type;

  BEGIN

  lrp_type := lrp_detail_type();
  lrp_type.service_plan_objid := i_service_plan_objid;



       SELECT NVL2(points_required_to_redeem, 'Y', 'N') available_for_lrp_flag,
              points_required_to_redeem points_required_to_redeem,
              reward_point points_accrued_by_purchase,
              reward_point_auto_refill points_accrued_by_autorefill
       INTO   lrp_type.available_for_lrp_flag,
              lrp_type.points_required_to_redeem,
              lrp_type.points_accrued_by_purchase,
              lrp_type.points_accrued_by_autorefill
       FROM   sa.mtm_sp_reward_program
       WHERE  service_plan_objid = i_service_plan_objid
       AND    SYSDATE BETWEEN start_date AND end_date;

	   lrp_type.status := 'SUCCESS '||lrp_type.status;

      RETURN lrp_type;
    EXCEPTION
      WHEN OTHERS
      THEN
        lrp_type.status                       := lrp_type.status ||' ERROR IN GETTING REWARD POINTS -'||SQLERRM;
        lrp_type.available_for_lrp_flag       := 'N';
        lrp_type.points_required_to_redeem    := NULL;
        lrp_type.points_accrued_by_purchase   := NULL;
        lrp_type.points_accrued_by_autorefill := NULL;
      RETURN lrp_type;

  END retrieve;

  --CR55804 end

END;
-- ANTHILL_TEST PLSQL/SA/Types/lrp_detail_type_body.sql 	CR55804: 1.7
/