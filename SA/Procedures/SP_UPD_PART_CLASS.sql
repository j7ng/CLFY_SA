CREATE OR REPLACE PROCEDURE sa.SP_UPD_PART_CLASS AS
  CURSOR tf_pc
  IS
    SELECT DISTINCT PART_CLASS
    FROM PC_PARAMS_VIEW
    WHERE 1        =1
    AND param_name ='BUS_ORG'
    AND PARAM_VALUE='TRACFONE';
  CURSOR device_group (pc_name VARCHAR2)
  IS
    SELECT *
    FROM PC_PARAMS_VIEW
    WHERE part_class =pc_name
    AND param_name   ='NON_PPE' ;
  v_device_gp VARCHAR2 (100);
  v_objid table_x_part_class_values.objid%type;
  v_param_id table_x_part_class_params.objid%type;
  v_count NUMBER :=0;
BEGIN
  select objid into v_param_id from table_x_part_class_params where x_param_name ='DEVICE_GROUP';
  FOR v_tf_pc IN tf_pc
  LOOP
    FOR v_device_group IN device_group(v_tf_pc.part_class)
    LOOP
      IF v_device_group.PARAM_VALUE    =1 THEN
        v_device_gp                   :='SMARTPHONE';
      ELSIF v_device_group.PARAM_VALUE =0 THEN
        v_device_gp                   :='FEATURE_PHONE';
      END IF ;
      SELECT MAX(objid+1) INTO v_objid FROM table_x_part_class_values;
      INSERT
      INTO table_x_part_class_values VALUES
        (
          v_objid,
          0,
          v_device_gp,
          v_param_id,
          v_device_group.PC_OBJID
        );
        v_count:=v_count+1;
    END LOOP;
	    --NULL;
  END LOOP;
  dbms_output.put_line('# of rows inserted: '|| v_count);
  COMMIT;
END SP_UPD_PART_CLASS;
/