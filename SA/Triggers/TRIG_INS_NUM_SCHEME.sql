CREATE OR REPLACE TRIGGER sa.trig_ins_num_scheme INSTEAD OF UPDATE ON
 sa.table_num_scheme
FOR EACH ROW
DECLARE
   num_inc NUMBER := :NEW.next_value - :old.next_value - 1;
   tmp_val NUMBER;
   i NUMBER;
BEGIN
   IF num_inc > 0
   THEN
      i := 1;
      WHILE i <= num_inc
      LOOP
         tmp_val := table_num_scheme_func (:old.name);
         i := i + 1;
      END LOOP;
   END IF;
END;
/