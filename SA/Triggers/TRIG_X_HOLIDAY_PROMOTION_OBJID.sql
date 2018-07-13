CREATE OR REPLACE TRIGGER sa."TRIG_X_HOLIDAY_PROMOTION_OBJID"
before insert on sa.table_x_holiday_promotion FOR EACH ROW
DECLARE

begin



IF :new.OBJID IS NULL THEN
     SELECT sa.seq_table_x_holiday_promotion.NEXTVAL
       INTO :new.objid
       FROM dual;
END IF;



END;
/