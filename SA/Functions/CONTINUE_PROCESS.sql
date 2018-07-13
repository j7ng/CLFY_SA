CREATE OR REPLACE FUNCTION sa."CONTINUE_PROCESS" (p_test_esn varchar2)
return varchar2
as
--To make sure the testing process does not affect real customers.
  db_name varchar2(100);
  sqlstmt varchar2(100) := 'select count(*) from sa.test_igate_esn where esn = :p_esn and esn_type = ''H''';
  cnt number := 0;
  result varchar2(20) := 'false';
begin
   select name into db_name from v$database;
   if db_name = 'CLFYTOPP' then
      result := 'true';
   else
      --Check if esn exists in sa.test_igate_esn
      begin
        execute immediate sqlstmt into cnt using p_test_esn;
      exception
        when others then result := 'false';
      end;
      if cnt > 0 then
         result := 'true';
      end if;
   end if;
   return result;
end continue_process;
/