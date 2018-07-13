CREATE OR REPLACE FORCE VIEW sa.table_x_safe_link_view (x_part_number,s_x_part_number,x_objid,x_zip,x_city,x_state) AS
select table_part_num.part_number, table_part_num.S_part_number, table_x_zip_code.objid,
 table_x_zip_code.x_zip, table_x_zip_code.x_city,
 table_x_zip_code.x_state
 from table_part_num, table_x_zip_code
 where table_part_num.objid = table_x_zip_code.safelink_zip2part_num;