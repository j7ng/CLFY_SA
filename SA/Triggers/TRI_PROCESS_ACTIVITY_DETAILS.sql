CREATE OR REPLACE TRIGGER sa.TRI_PROCESS_ACTIVITY_DETAILS
BEFORE INSERT OR UPDATE
ON sa.TF_SOAPROCESS_ACTIVITY_DETAILS
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
TMPVAR NUMBER;
/******************************************************************************
   NAME:       TRI_PROCESS_ACTIVITY_INFO
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        4/28/2010             1. CREATED THIS TRIGGER.


******************************************************************************/
BEGIN


   IF INSERTING THEN
      SELECT TF_SOAPROCESS_ACTY_DETAILS_SEQ.NEXTVAL INTO TMPVAR FROM DUAL;
      :NEW.ACTIVITY_DETAILS_ID := TMPVAR;
   END IF;
   :NEW.ROW_UPD_DATE := SYSDATE;

   EXCEPTION
     WHEN OTHERS THEN
       -- CONSIDER LOGGING THE ERROR AND THEN RE-RAISE
       RAISE;
END TRI_PROCESS_ACTIVITY_DETAILS;
/