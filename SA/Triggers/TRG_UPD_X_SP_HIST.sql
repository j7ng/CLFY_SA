CREATE OR REPLACE TRIGGER sa."TRG_UPD_X_SP_HIST"
    BEFORE UPDATE ON sa.x_service_plan_hist
    FOR EACH ROW
DECLARE

BEGIN

    --Update the date field to last time it was updated
    :new.x_last_modified_date := sysdate;
    --DBMS_OUTPUT.PUT_LINE('X_LAST_MODIFIED_DATE successfully updated');

    EXCEPTION WHEN OTHERS
    THEN
        NULL;

END;
/