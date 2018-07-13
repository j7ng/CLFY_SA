CREATE OR REPLACE TRIGGER sa."TRIG_RQST_MAPPING"
before insert or update on sa.x_rqst_mapping
for each row
declare
  v_error_objid number;
  v_func_objid number;
  v_flow_objid number;
  v_script_objid number;
  function getObjid(v_str in varchar2,tbl in varchar2 )
  return number is
     v_start number;
     v_end number;
     v_len number;
     v_objid number;
  begin
      v_start := instr(v_str,'(');
      if v_start > 0 then
            v_start:=v_start+1;
            v_end := instr(v_str,')');
            v_len := v_end - v_start ;
            return to_number(substr(v_str,v_start,v_len));
      end if;
      if ( tbl = 'x_flows') then
          begin
               select x_flow_objid
               into v_objid
               from sa.x_flows
               where x_flow_name=v_str;
          exception
            when no_data_found then
               insert into sa.x_flows(x_flow_objid,x_flow_name,create_date)
                        values (x_flow_seq.nextval,v_str,sysdate)
                        returning x_flow_objid into v_objid;
          end;
      end if;
      if ( tbl = 'x_error_codes') then
          begin
               select x_error_objid
               into v_objid
               from sa.x_error_codes
               where x_error_code=v_str;
          exception
            when no_data_found then
                insert into sa.x_error_codes(x_error_objid,x_error_code,create_date)
                        values (x_error_code_seq.nextval,v_str,sysdate)
                        returning x_error_objid into v_objid;
          end;
      end if;
      if ( tbl = 'x_functions') then
          begin
               select x_func_objid
               into v_objid
               from sa.x_functions
               where x_func_name=v_str;
          exception
            when no_data_found then
               insert into sa.x_functions(x_func_objid,x_func_name,create_date)
                        values (x_func_seq.nextval,v_str,sysdate)
                        returning x_func_objid into v_objid;
         end;
      end if;
      if ( tbl = 'table_x_scripts') then
          begin
             select objid
             into v_objid
             from sa.table_x_scripts
             where x_script_type = substr(v_str,1,instr(v_str,'_')-1)
             and x_script_id = substr(v_str,instr(v_str,'_')+1)
             and rownum < 2;
          exception
             when others then
              v_objid := -1;
          end;
      end if;
      return v_objid;
  end;
begin
    dbms_output.put_line('Trigger FIRED');
    if updating then
      if (:new.x_func_name <> :old.x_func_name) then
           dbms_output.put_line('Updating x_func_name is not allowed');
           :new.x_func_name := :old.x_func_name;
      end if;
      if (:new.x_error_code <> :old.x_error_code) then
           dbms_output.put_line('Updating x_error_code is not allowed');
           :new.x_error_code := :old.x_error_code;
      end if;
      if (:new.x_flow_name <> :old.x_flow_name) then
           dbms_output.put_line('Updating x_flow_name is not allowed');
           :new.x_flow_name := :old.x_flow_name;
      end if;

    end if;
    v_error_objid := getObjid(:new.x_error_code,'x_error_codes');
    v_func_objid := getObjid(:new.x_func_name,'x_functions');
    v_flow_objid := getObjid(:new.x_flow_name,'x_flows');
    v_script_objid := getObjid(:new.x_script_name,'table_x_scripts');


/*
    if :new.x_func_name not like '%(%)' then
        :new.x_func_name := :new.x_func_name||'('||v_func_objid||')';
    end if;
    if :new.x_flow_name not like '%(%)' then
        :new.x_flow_name := :new.x_flow_name||'('||v_flow_objid||')';
    end if;
    if :new.x_error_code not like '%(%)' then
        :new.x_error_code := :new.x_error_code||'('||v_error_objid||')';
    end if;
*/

    if v_script_objid = -1 then
        :new.deploy_flag :='N';
        :new.x_script_name := '';
    else
       if (:new.x_script_name <> nvl(:old.x_script_name,' ')) then
        :new.deploy_flag := 'Y';
       end if;
    end if;


    if ( :new.deploy_flag = 'Y' ) then
          begin
              insert into x_rqst_sync   ( x_func_name,
                                      x_flow_name,
                                      x_error_code,
                                      x_script_name
                                     )
                               values(:new.x_func_name,
                                      :new.x_flow_name,
                                      :new.x_error_code,
                                      :new.x_script_name
                                     );
              dbms_output.put_line( 'inserted '||sql%ROWCOUNT||' rows');
              dbms_output.put_line('Merging('||:new.x_script_name||','
                              ||v_error_objid||','
                              ||v_flow_objid||','
                              ||v_func_objid||')');

              merge into sa.x_mapping_tbl a
              using ( select 1 from dual )
              on (a.x_func_objid = v_func_objid
                  and a.x_flow_objid = v_flow_objid
                  and a.x_error_objid = v_error_objid )
              when matched then
                   update set a.x_script_name = :new.x_script_name
              when not matched then
                   insert (x_script_name,
                           x_func_objid,
                           x_flow_objid,
                           x_error_objid)
                   values (:new.x_script_name,
                           v_func_objid,
                           v_flow_objid,
                           v_error_objid);
          exception
             when others then
                dbms_output.put_line(sqlerrm);
          end;


   elsif (:new.deploy_flag = 'N' ) then
        dbms_output.put_line('DELETING ('||:new.x_script_name||','
                              ||v_error_objid||','
                              ||v_flow_objid||','
                              ||v_func_objid||')');
        delete sa.x_mapping_tbl
        where 1=1
        and x_func_objid = v_func_objid
        and x_flow_objid = v_flow_objid
        and x_error_objid = v_error_objid
        and x_script_name = :old.x_script_name;
   end if;
end;
/