CREATE OR REPLACE PROCEDURE sa."GEN_FN_ADP_TBL_OID" as
  sql_text DBMS_SQL.varchar2a;
  tbl_idx  integer := 1;
  tmpVal   number;
  cursor_name INTEGER;
begin
  sql_text(tbl_idx) := 'create or replace function sa.fn_adp_tbl_oid (p_type_id in number) return number as' || chr(10);
  tbl_idx := tbl_idx + 1;
  sql_text(tbl_idx) := 'r number;' || chr(10);
  tbl_idx := tbl_idx + 1;
  sql_text(tbl_idx) := 'begin' || chr(10);
  tbl_idx := tbl_idx + 1;
  sql_text(tbl_idx) := '  case p_type_id' || chr(10);
  tbl_idx := tbl_idx + 1;
  for c1 in (
    select a.type_name, a.type_id,
    '  when ' ||  a.type_id || ' then' || chr(10) ||
    '    select sa.sequ_' || a.type_name || '.nextval into r from dual;' || chr(10) a
    from  sa.adp_tbl_name_map a, sa.adp_tbl_oid b
    where a.type_id = b.type_id
    order by a.type_id) loop
    sql_text(tbl_idx) := c1.a;
    tbl_idx := tbl_idx + 1;
    begin
    select 1 into tmpVal
    from   dba_sequences
    where  sequence_owner = 'SA'
    and    sequence_name = upper('sequ_' ||  c1.type_name);
    exception when no_data_found then
      begin
      select obj_num_start into tmpVal
      from   sa.adp_tbl_oid_base
      where  type_id = c1.type_id;
      exception when others then tmpVal := 0;
      end;
      execute immediate 'create sequence sa.sequ_' || c1.type_name || ' start with '
                        || to_char(tmpVal+1);
      sys.dbms_shared_pool.keep('sa.sequ_' || c1.type_name, 'Q');
    end;
  end loop;
  sql_text(tbl_idx) := '  end case;' || chr(10);
  tbl_idx := tbl_idx + 1;
  sql_text(tbl_idx) := '  return r;' || chr(10);
  tbl_idx := tbl_idx + 1;
  sql_text(tbl_idx) := 'end;';
  cursor_name := dbms_sql.open_cursor;
  dbms_sql.parse(cursor_name, sql_text, 1, tbl_idx, false, dbms_sql.native);
  dbms_sql.close_cursor(cursor_name);
end;
/