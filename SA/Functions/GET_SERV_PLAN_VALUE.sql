CREATE OR REPLACE FUNCTION sa."GET_SERV_PLAN_VALUE" (
    ip_plan_objid    IN NUMBER,
    ip_property_name IN VARCHAR )
  RETURN VARCHAR DETERMINISTIC
IS
  -- Part number based click plan
  CURSOR c1
  IS
    SELECT fea_value property_value
    FROM ADFCRM_SERV_PLAN_FEAT_MATVIEW
    WHERE FEA_NAME = ip_property_name
    AND sp_objid   = ip_plan_objid;
  r1 c1%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO r1;
  IF c1%found THEN
    CLOSE c1;
    RETURN r1.PROPERTY_VALUE;
  ELSE
    CLOSE c1;
    RETURN NULL;
  END IF;
END;
/