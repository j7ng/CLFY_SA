CREATE OR REPLACE FORCE VIEW sa.part_class_params_rtrp (objid,dev,x_param_name,x_param_info) AS
select "OBJID","DEV","X_PARAM_NAME","X_PARAM_INFO" from table_x_part_class_params@read_rtrp;