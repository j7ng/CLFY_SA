CREATE OR REPLACE procedure sa.sp_error_code2script(error_code varchar2,
                                      func varchar2,
                                      flow varchar2,
                                      script_name in out varchar2,
                                      script_text in varchar2 ) is
   print_debug boolean := true;
   save_ec varchar2(30);
   save_func varchar2(100);
   save_flow varchar2(100);
   v_ec varchar2(30):= nvl(upper(error_code),'ALL');
   v_func varchar2(100):= nvl(upper(func),'ALL');
   v_flow varchar2(100):= nvl(upper(flow),'ALL');
   v_script_name varchar2(30) := nvl(upper(script_name),'ALL');
   v_ret varchar2(40);
   v_ins boolean := false;
--   upd_stmt varchar2(300);
   iter number := 0;
   ins_stmt varchar2(400):= 'insert into sa.x_rqst_mapping( objid';
   ins_val varchar2(400) := 'values ( sa.rqst_mapping_seq.nextval';
function scriptExists(p_script in varchar2) return boolean is
  var  varchar2(100):= '-1';
begin
   select p_script
   into var
   from sa.table_x_scripts
   where x_script_type  = substr(p_script,1,instr(p_script,'_')-1)
   and   x_script_id = substr(p_script,instr(p_script,'_')+1)
   and rownum <2;

   return true;
exception
   when others then
     return false;
end;
begin
<<repeat>>
  begin
     if print_debug then
        dbms_output.put_line ( '============================');
        if v_ins then
          dbms_output.put_line ( iter||' Iteration'||' Ins=true ');
        else
          dbms_output.put_line ( iter||' Iteration'||' Ins=FALSE ');
        end if;
        dbms_output.put_line ( 'v_func='||v_func);
        dbms_output.put_line ( 'v_flow='||v_flow);
        dbms_output.put_line ( 'v_ec='||v_ec);
        dbms_output.put_line ( 'v_script_name='||v_script_name);
        --dbms_output.put_line ( 'v_script_name='||v_script_name||chr(10));
     end if;


   select b.x_script_name
   into v_ret
   from sa.x_mapping_tbl b,
        sa.x_flows c,
        sa.x_error_codes d,
        sa.x_functions e
   where b.x_script_name = decode(v_script_name,'ALL',b.x_script_name,v_script_name)
   and   b.x_flow_objid  = c.x_flow_objid(+)
   and   b.x_error_objid = d.x_error_objid(+)
   and   b.x_func_objid  = e.x_func_objid(+)
   and   d.x_error_code in (v_ec,upper(error_code))
   and   e.x_func_name in ( v_func,upper(func))
   and   c.x_flow_name in (v_flow,upper(flow))
   and rownum < 2;
   dbms_output.put_line ( 'Iter '||iter||' ret='||v_ret);

   if (iter <> 0 and iter < 4 ) and v_ins = true then
        raise no_data_found;
   end if;

  exception
     when no_data_found then
      v_ins := true;
      if iter = 0 then
          ins_stmt := ins_stmt||',x_func_name';
          ins_val := ins_val||','''||v_func||'''';
          v_func := 'ALL';
          iter := iter +1;
          goto repeat;
      elsif iter = 1 then
          ins_stmt := ins_stmt||',x_flow_name';
          ins_val := ins_val||','''||v_flow||'''';
          iter := iter +1;
          v_flow := 'ALL';
          goto repeat;
      elsif iter = 2 then
          ins_stmt := ins_stmt||',x_error_code';
          ins_val := ins_val||','''||v_ec||'''';
          iter := iter +1;
          v_ec := 'ALL';
          goto repeat;
      elsif iter = 3 then
          if (v_script_name <> 'ALL') then
               ins_stmt := ins_stmt||',x_script_name';
               ins_val := ins_val||','''||script_name||'''';
               iter := iter +1;
               goto repeat;
          end if;
      end if;
  end;
  if v_ins then
       begin
         if print_debug = true then
            dbms_output.put_line(ins_stmt||',x_script_text)'||
                             ins_val||','''||script_text||''')');
         end if;
         execute immediate ins_stmt||',x_script_text)'||ins_val||','''||script_text||''')';
       exception
         when dup_val_on_index then
            null;
         when others then
            if (print_debug) then
                dbms_output.put_line('Inserting - '||sqlerrm);
            end if;
       end;
  end if;
        dbms_output.put_line ( 'v_ret='||v_ret);
  if ( v_ret is not null ) then
      script_name := v_ret;
  elsif (not scriptExists(v_script_name)) then
      script_name := null;
  end if;
end;
/