CREATE OR REPLACE TRIGGER sa."TRIG_CHECK_CASE_DETAIL"
BEFORE UPDATE ON sa.TABLE_X_CASE_DETAIL
REFERENCING OLD AS old NEW AS new
FOR EACH ROW
 WHEN (new.X_NAME = 'TT_UNITS') DECLARE
  v_value number;
BEGIN
   begin
      v_value := to_number(:new.x_value);
      if v_value > 50000 then
         :new.x_value := :old.x_value;
      end if;
   exception
   when others then
        --if the value is not numeric set to null
        :new.x_value := null;
   end;
END;
/