CREATE OR REPLACE TRIGGER sa."TRIG_PAY_SERVICE_PARAMS_OBJID"
before insert on sa.x_payment_service_parameters FOR EACH ROW
DECLARE

begin



IF :new.OBJID IS NULL THEN
     SELECT sa.sequ_x_payment_service_params.NEXTVAL
       INTO :new.objid
       FROM dual;
END IF;



END;
/