CREATE OR REPLACE procedure sa.reset_seq_up( p_seq_name in varchar2, up_num in number )
is
    l_val number;
    l_diff number;
begin

    execute immediate
    'select ' || p_seq_name || '.nextval from dual' INTO l_val;

    l_diff := up_num-l_val;
    execute immediate
    'alter sequence ' || p_seq_name || ' increment by ' ||l_diff;

    execute immediate
    'select ' || p_seq_name || '.nextval from dual' INTO l_val;

    execute immediate
    'alter sequence ' || p_seq_name || ' increment by 1';
     l_diff := l_val -up_num;
    dbms_output.put_line('Nextval - max(objid) is '||l_diff);
end;
/