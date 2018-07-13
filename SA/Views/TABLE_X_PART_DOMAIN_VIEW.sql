CREATE OR REPLACE FORCE VIEW sa.table_x_part_domain_view (x_name,x_model_number,x_objid,x_description,s_x_description,x_domain,s_x_domain,x_part_number,s_x_part_number) AS
select table_part_class.name, table_part_class.x_model_number,
 table_part_num.objid, table_part_num.description, table_part_num.S_description,
 table_part_num.domain, table_part_num.S_domain, table_part_num.part_number, table_part_num.S_part_number
 from table_part_class, table_part_num
 where table_part_class.objid = table_part_num.part_num2part_class
 ;