CREATE OR REPLACE TYPE sa.part_num_mapping_type AS OBJECT
/*************************************************************************************************************************************
--$RCSfile: part_num_mapping_type.sql,v $
--$ $Log: part_num_mapping_type.sql,v $
--$ Revision 1.3  2017/09/20 20:12:02  vnainar
--$ CR48260 type modified
--$
--$
--$
*
* CR48260 - part_num_mapping_type.
*
*************************************************************************************************************************************/
(
app_part_number                               VARCHAR2(50) ,
app_ar_part_number                            VARCHAR2(50) ,
part_class_name                               VARCHAR2(40) ,
service_plan_objid                            NUMBER       ,
service_plan_name                             VARCHAR2(50) ,
service_plan_group                            VARCHAR2(50) ,
service_plan_type                             VARCHAR2(30)
);
/