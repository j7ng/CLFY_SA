CREATE OR REPLACE TRIGGER sa."TRIG_SOLUTION_SCRIPTS"
BEFORE INSERT OR UPDATE OR DELETE
ON sa.ADFCRM_SOLUTION_SCRIPTS REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
DECLARE
    v_changed_date date;
    v_changed_by varchar2(50);
    v_change_type varchar2(100);
    v_username varchar2(50);
    v_sqlerrm varchar2(4000);
BEGIN

SELECT substr(user,1,50) INTO v_username
FROM dual;
if (inserting or updating) and nvl(:new.changed_by,'empty') = 'empty' then
   :new.changed_by := v_username;
end if;

if inserting then
    --This will not create a record in history table
    :new.changed_date := sysdate;
    :new.change_type  := 'INSERT';
elsif updating then
    :new.changed_date := sysdate;
    :new.change_type  := 'UPDATE';
elsif deleting then
    v_changed_by := v_username; --This need to be verified.
    v_changed_date := sysdate;
    v_change_type := 'DELETE';
end if;

if deleting or (updating and (:old.solution_id != :new.solution_id or
                              :old.ss_id != :new.ss_id or
                              :old.step != :new.step or
                              :old.script_type != :new.script_type or
                              :old.script_id != :new.script_id
                              )
               )
then
      --Save the old record in the history table
      insert into sa.adfcrm_solution_scripts_hist
      (solution_id
      ,ss_id
      ,step
      ,script_type
      ,script_id
      ,changed_date
      ,changed_by
      ,change_type)
      values
      (:old.solution_id
      ,:old.ss_id
      ,:old.step
      ,:old.script_type
      ,:old.script_id
      ,:old.changed_date
      ,:old.changed_by
      ,:old.change_type);
end if;
--Save the record in the history table to track delete
if deleting then
        insert into sa.adfcrm_solution_scripts_hist
        (solution_id
        ,ss_id
        ,step
        ,script_type
        ,script_id
        ,changed_date
        ,changed_by
        ,change_type)
        values
        (:old.solution_id
        ,:old.ss_id
        ,:old.step
        ,:old.script_type
        ,:old.script_id
        ,v_changed_date
        ,v_changed_by
        ,v_change_type);
end if;

END;
/