CREATE OR REPLACE trigger sa.TRIG_RATE_PLAN_FEAT_TYPE_OBJID
before insert on sa.CARRIER_RATE_PLAN_FEATURE_TYPE FOR EACH ROW
DECLARE

begin



IF :new.OBJID IS NULL THEN
     SELECT sa.SEQU_CARR_RATE_PLAN_FEAT_TYPE.NEXTVAL
       INTO :new.objid
       FROM dual;
END IF;



END;
/