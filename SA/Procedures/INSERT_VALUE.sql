CREATE OR REPLACE procedure sa.insert_value(p_para_name in varchar2, p_objid in number) is

    exec_stmt varchar2(2000):= null;
   begin
      exec_stmt := null;
    --  dbms_output.put_line(p_para_name||','|| p_objid);
      exec_stmt := exec_stmt ||'declare
                                  cursor c1 is
                                    select distinct objid,'||p_para_name||' para_value from SA.TMP_VALUES;
                                  begin
                                     for c1_rec in c1 loop
                                        insert into SA.TABLE_X_PART_CLASS_VALUES values (
                                         SA.SEQU_X_PART_CLASS_VALUES.nextval, null, c1_rec.para_value'||','||p_objid||',c1_rec.objid);
                                           end loop;
                                    end;';
       begin
         EXECUTE IMMEDIATE exec_stmt;
         exception when others then
         dbms_output.put_line('ERROR');
         dbms_output.put_line(substr(exec_stmt,1,80));
        dbms_output.put_line(substr(exec_stmt,81,80));
        dbms_output.put_line(substr(exec_stmt,161,80));
        dbms_output.put_line(substr(exec_stmt,241,80));
        dbms_output.put_line(substr(exec_stmt,321,80));
        dbms_output.put_line(substr(exec_stmt,401,80));
        dbms_output.put_line(substr(exec_stmt,481,80));
        dbms_output.put_line(substr(exec_stmt,561,80));
        dbms_output.put_line(substr(exec_stmt,641,80));
        dbms_output.put_line(substr(exec_stmt,721,80));
        dbms_output.put_line(substr(exec_stmt,801,80));
        dbms_output.put_line(substr(exec_stmt,881,80));
        dbms_output.put_line(substr(exec_stmt,961,80));
        dbms_output.put_line(substr(exec_stmt,1041,80));
        dbms_output.put_line(substr(exec_stmt,1121,80));
        dbms_output.put_line(substr(exec_stmt,1201,80));
        dbms_output.put_line(substr(exec_stmt,1281,80));
        dbms_output.put_line(substr(exec_stmt,1361,80));
        dbms_output.put_line(substr(exec_stmt,1441,80));
      end;
  end;
/