CREATE OR REPLACE TRIGGER sa."TRIG_SOLUTION_QUALIFICATION"
BEFORE INSERT OR UPDATE OR DELETE
ON sa.ADFCRM_SOLUTION_QUALIFICATION REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
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
                              :old.class_param_name != :new.class_param_name or
                              :old.class_param_value != :new.class_param_value)
               )
then
      --Save the old record in the history table
      insert into sa.adfcrm_sol_qualification_hist
      (solution_id
      ,class_param_name
      ,class_param_value
      ,changed_date
      ,changed_by
      ,change_type)
      values
      (:old.solution_id
      ,:old.class_param_name
      ,:old.class_param_value
      ,:old.changed_date
      ,:old.changed_by
      ,:old.change_type);
end if;

--Save the record in the history table to track delete
if deleting then
        insert into sa.adfcrm_sol_qualification_hist
        (solution_id
        ,class_param_name
        ,class_param_value
        ,changed_date
        ,changed_by
        ,change_type)
        values
        (:old.solution_id
        ,:old.class_param_name
        ,:old.class_param_value
        ,v_changed_date
        ,v_changed_by
        ,v_change_type);
end if;

END;
/