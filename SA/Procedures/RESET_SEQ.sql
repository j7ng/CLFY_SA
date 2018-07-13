CREATE OR REPLACE procedure sa.reset_seq( p_seq_name in varchar2, new_start_no in number )
is
    l_val number;
    l_diff number;
begin

    execute immediate
    'select ' || p_seq_name || '.nextval from dual' INTO l_val;

    l_diff := new_start_no-l_val;
    execute immediate
    'alter sequence ' || p_seq_name || ' increment by ' ||l_diff;

    execute immediate
    'select ' || p_seq_name || '.nextval from dual' INTO l_val;

    execute immediate
    'alter sequence ' || p_seq_name || ' increment by 1';

    dbms_output.put_line('Nextval - max(objid) is '||l_diff);
        dbms_output.put_line('Nextval  is '||l_val);
end;
/