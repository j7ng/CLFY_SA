CREATE OR REPLACE TRIGGER sa.trig_rqst_mapping_stmt
after insert or update of x_script_name ON sa.X_RQST_MAPPING
begin
  dbms_output.put_line('STMT TRIGGER');
  update x_rqst_mapping a set deploy_flag = 'N'
  where exists(select 1 from x_rqst_sync b
   where a.x_func_name = b.x_func_name
   and   a.x_error_code = b.x_error_code
   and   a.x_flow_name = b.x_flow_name
   and   a.x_script_name <> b.x_script_name);

   delete x_rqst_sync;
end;
/