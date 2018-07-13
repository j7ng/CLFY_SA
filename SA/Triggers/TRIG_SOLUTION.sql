CREATE OR REPLACE TRIGGER sa."TRIG_SOLUTION"
BEFORE INSERT OR UPDATE OR DELETE
ON sa.ADFCRM_SOLUTION REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
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

if deleting or updating
then
      --Save the old record in the history table
      insert into sa.adfcrm_solution_hist
      (solution_id
      ,solution_name
      ,solution_description
      ,keywords
      ,access_type
      ,phone_status
      ,script_type
      ,script_id
      ,parent_id
      ,case_conf_hdr_id
      ,carrrier_parents
      ,send_by_email
      ,file_id
      ,show_in_popup_window
      ,file_id_2
      ,file_id_3
      ,file_id_4
      ,file_id_5
      ,changed_date
      ,changed_by
      ,change_type)
      values
      (:old.solution_id
      ,:old.solution_name
      ,:old.solution_description
      ,:old.keywords
      ,:old.access_type
      ,:old.phone_status
      ,:old.script_type
      ,:old.script_id
      ,:old.parent_id
      ,:old.case_conf_hdr_id
      ,:old.carrrier_parents
      ,:old.send_by_email
      ,:old.file_id
      ,:old.show_in_popup_window
      ,:old.file_id_2
      ,:old.file_id_3
      ,:old.file_id_4
      ,:old.file_id_5
      ,:old.changed_date
      ,:old.changed_by
      ,:old.change_type);

      --Save the record in the history table to track delete
      if deleting then
        insert into sa.adfcrm_solution_hist
        (solution_id
        ,solution_name
        ,solution_description
        ,keywords
        ,access_type
        ,phone_status
        ,script_type
        ,script_id
        ,parent_id
        ,case_conf_hdr_id
        ,carrrier_parents
        ,send_by_email
        ,file_id
        ,show_in_popup_window
        ,file_id_2
        ,file_id_3
        ,file_id_4
        ,file_id_5
        ,changed_date
        ,changed_by
        ,change_type)
        values
        (:old.solution_id
        ,:old.solution_name
        ,:old.solution_description
        ,:old.keywords
        ,:old.access_type
        ,:old.phone_status
        ,:old.script_type
        ,:old.script_id
        ,:old.parent_id
        ,:old.case_conf_hdr_id
        ,:old.carrrier_parents
        ,:old.send_by_email
        ,:old.file_id
        ,:old.show_in_popup_window
        ,:old.file_id_2
        ,:old.file_id_3
        ,:old.file_id_4
        ,:old.file_id_5
        ,v_changed_date
        ,v_changed_by
        ,v_change_type);
      end if;
end if;
END;
/