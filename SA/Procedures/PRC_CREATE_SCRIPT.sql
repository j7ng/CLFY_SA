CREATE OR REPLACE procedure sa.prc_create_script as

cursor cl is
select a.table_name
from   dba_tables a
where      a.owner='SA'
       ;

v_rec         cl%rowtype;
v_string1     varchar2(250);
v_string2     varchar2(250);
v_string3     varchar2(250);
v_string4     varchar2(250);
v_string5     varchar2(250);
v_string6     varchar2(250);
v_string7     varchar2(250);
v_string8     varchar2(250);
v_string9     varchar2(250);
v_string10    varchar2(250);
v_string11    varchar2(250);
v_file_out    utl_file.file_type;
v_file_path   constant varchar2(100):='/f01/invfile';
v_file_name   constant varchar2(100):='table_analyse.sql';

BEGIN

 v_file_out :=utl_file.fopen(v_file_path,v_file_name,'w');
 dbms_output.put_line('delete from TABLE_WITH_CHAINED_ROWS;');
 utl_file.put_line(v_file_out,'delete from TABLE_WITH_CHAINED_ROWS;');
 open cl;
   loop
      fetch cl into v_rec;
      exit when cl%notfound;

      v_string1  := RPAD('-',100,'-');
      v_string2  := '-- Analysing Table '||v_rec.table_name;
      v_string3  := RPAD('-',100,'-');
      v_string4  := '@H:\chained_Rows\CHAINED_ROWS.sql;';
      v_string5  := 'INSERT INTO TABLE_WITH_CHAINED_ROWS VALUES('||''''||v_rec.table_name||''''||',SYSDATE,NULL,NULL);';
      v_string6  := 'analyze table '||v_rec.table_name||' list chained rows into chained_rows;';
      v_string7  := 'UPDATE TABLE_WITH_CHAINED_ROWS';
      v_string8  := 'SET ANALYSIS_END = SYSDATE, NO_OF_CHAINED_ROWS = (SELECT COUNT(*) FROM CHAINED_ROWS)';
      v_string9  := 'WHERE TABLE_NAME = '||''''||v_rec.table_name||''''||';';
    --v_string7  := 'INSERT INTO TABLE_WITH_CHAINED_ROWS (SELECT '||''''||v_rec.table_name||''''||' ,COUNT(*) FROM CHAINED_ROWS);';
      v_string10 := 'commit;';
    --v_string8  := '@C:\CHAINED_ROWS.sql;';

      dbms_output.put_line(v_string1);
      dbms_output.put_line(v_string2);
      dbms_output.put_line(v_string3);
      dbms_output.put_line(v_string4);
      dbms_output.put_line(v_string5);
      dbms_output.put_line(v_string6);
      dbms_output.put_line(v_string7);
      dbms_output.put_line(v_string8);
      dbms_output.put_line(v_string9);
      dbms_output.put_line(v_string10);
/*
      utl_file.put_line(v_file_out,v_string1);
      utl_file.put_line(v_file_out,v_string2);
      utl_file.put_line(v_file_out,v_string3);
      utl_file.put_line(v_file_out,v_string4);
      utl_file.put_line(v_file_out,v_string5);
      utl_file.put_line(v_file_out,v_string6);
      utl_file.put_line(v_file_out,v_string7);
      utl_file.put_line(v_file_out,v_string8);
      utl_file.put_line(v_file_out,v_string9);
      utl_file.put_line(v_file_out,v_string10);
*/
   end loop;
 close cl;
 utl_file.fclose(v_file_out);

EXCEPTION
	when others then
        utl_file.fclose(v_file_out);
	dbms_output.put_line('PROCESS FAILED = '|| sqlerrm);
END;
/