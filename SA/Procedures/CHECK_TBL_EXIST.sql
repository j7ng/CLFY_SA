CREATE OR REPLACE PROCEDURE sa.Check_tbl_exist(p_tab IN VARCHAR2)
IS
cursor C is
select script_name,refresh_tab_nmae from refresh_table_Names where refresh_tab_nmae=upper(p_tab);
p_rec C%rowtype;
  lCount number;
BEGIN
   --  for p_rec in C
   open C;
   fetch C into p_rec;
 -- LOOP
  if C%found then
    DBMS_OUTPUT.PUT_LINE('Table match : ' ||'SCRIPT NAME :'|| p_rec.script_name|| ' ' ||'TABLE NAME :' || p_rec.refresh_tab_nmae);
      -- fetch C into p_rec;
   -- elsif C%NOTfound then
  -- exit;
 --execute immediate 'select count(*) refresh_table_Names where refresh_tab_nmae=upper(p_tab);'  into lCount;
  -- if lCount =0  then
  else
    DBMS_OUTPUT.PUT_LINE('Table not match'|| p_rec.refresh_tab_nmae );
   -- else
   -- exit;
  end if;
 -- end if;

--end loop;
if C%ISOPEN then
         close C;
       end if;
END;
/