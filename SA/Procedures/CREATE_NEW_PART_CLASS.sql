CREATE OR REPLACE procedure sa.create_new_part_class (p_class_name varchar2,
                                                   out_objid out number)
 as
  -------------------------------------------------------------------
  -- WORKS ALONG SIDE W/THE APEX PART CLASS PARAMS APPLICATION.
  -- CHECKS FOR PART CLASS EXISTANCE IN PROD. IF IT'S NOT FOUND,
  -- ADD THE PART CLASS TO PROD
  -------------------------------------------------------------------
  -- NOTE: THIS PROCEDURE SHOULD ONLY EXIST AND BE CALLED IN
  -- PRODUCTION BECAUSE THE SEQUENCE FUNCTION IT CALLS
  -------------------------------------------------------------------
  check_exists number;
begin
  select count(*)
  into   check_exists
  from   table_part_class
  where  name = p_class_name;

  if check_exists = 1 then
    select objid
    into   out_objid
    from   table_part_class
    where  name = p_class_name;
  else
    begin
      insert into table_part_class
        (objid, name, description, dev, x_model_number, x_psms_inquiry)
      values
        (seq('PART_CLASS'), p_class_name, p_class_name, '', p_class_name, '') returning objid into out_objid;
    exception when others then
      out_objid := -1;
    end;
  end if;

end;
/