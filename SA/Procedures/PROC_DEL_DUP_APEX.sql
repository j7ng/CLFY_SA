CREATE OR REPLACE procedure sa.proc_del_dup_apex  is
--declare
cursor dup_param is
select x_param_name,count(x_param_name)
from table_x_part_class_params
group by x_param_name
having count(x_param_name) >1;

v_obj number;
Param_nm  varchar2(300);

cursor del_param is
  select pcdev.objid
  from table_x_part_class_params pcdev,
  part_class_params_RTRP@jt_samp pcprd
  where pcprd.x_param_name=pcdev.x_param_name
  and pcdev.x_param_name =Param_nm
  and pcprd.objid <> pcdev.objid;


begin
  for dup_rec in dup_param   loop
     Param_nm     :=dup_rec.x_param_name;
      for  del_rec in del_param loop
         v_obj := del_rec.objid;


       dbms_output.put_line( 'The objid  for the param '|| Param_nm|| '   to delete is '||v_obj);

---delete the record in dev whose objid does not match RTRP objid

    delete from table_x_part_class_params
       where objid =v_obj
        and  X_PARAM_NAME=Param_nm ;
        commit;

     dbms_output.put_line('Deleted the record for '|| Param_nm||' with this objid in DEV '||v_obj);
     end loop;
  end loop;

end;
/