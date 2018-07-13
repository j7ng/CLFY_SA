CREATE OR REPLACE function sa.ADFCRM_GET_CASE_DTL_DDL (ip_ddl_title in varchar2,ip_case_objid in varchar2) return sa.ADFCRM_DDL_NESTED_TABLE as
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_GET_CASE_DTL_DDL.sql,v $
--$Revision: 1.3 $
--$Author: mmunoz $
--$Date: 2013/01/28 19:06:35 $
--$ $Log: ADFCRM_GET_CASE_DTL_DDL.sql,v $
--$ Revision 1.3  2013/01/28 19:06:35  mmunoz
--$ CR23043 ADF Oracle Application - Third Release
--$
--$
--------------------------------------------------------------------------------------------

  v_ret   sa.ADFCRM_DDL_NESTED_TABLE;

  cursor c1 (dll_title varchar2) is select * from sa.Table_gbst_Lst
  where title = dll_title;

  cursor c2 (lst_objid number) is select * from sa.Table_gbst_Elm
  where gbst_elm2gbst_lst = lst_objid
  and state in (0,2) --0=Active,1=Inactive,2=Default
  order by rank asc;

  TYPE cur_typ IS REF CURSOR;
  c3 cur_typ;

  row_counter number:=0;
  dynamic_title varchar2(200);

begin
  v_ret  := sa.ADFCRM_DDL_NESTED_TABLE();

  for r1 in c1(ip_ddl_title) loop
     if r1.sql_text is null then
         for r2 in c2(r1.objid) loop
            row_counter:=row_counter+1;
              v_ret.extend;
              v_ret(v_ret.count) := sa.ADFCRM_DDL_COL(row_counter,r2.title);
         end loop;
     else
        OPEN c3 FOR r1.sql_text USING ip_case_objid;
        LOOP
            FETCH c3 INTO dynamic_title;
            EXIT WHEN c3%NOTFOUND;
                row_counter:=row_counter+1;
                  v_ret.extend;
                  v_ret(v_ret.count) := sa.ADFCRM_DDL_COL(row_counter,dynamic_title);
        END LOOP;
     end if;
  end loop;
  return v_ret;
end adfcrm_get_case_dtl_ddl;
/