CREATE OR REPLACE TRIGGER sa.PROG_MEMBERSHIP_TRIG
   BEFORE INSERT
    ON sa.X_PROGRAM_MEMBERSHIP      REFERENCING OLD AS OLD NEW AS NEW
      FOR EACH ROW
DECLARE
    i        number;
BEGIN

     SELECT sa.SEQ_PROGRAM_MEMBERSHIP.Nextval INTO i
   FROM Dual;
    :New.X_MEMBERSHIP_ID := i;
END;
/