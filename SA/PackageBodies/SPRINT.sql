CREATE OR REPLACE PACKAGE BODY sa."SPRINT"
AS
    Procedure get_new_lines is
    v_data     varchar2(200);
    v_cnt      number :=1;
    cursor c_lines is
     select pi.part_serial_no,
	       ca.x_ld_account
	  from table_part_inst        pi,
	       table_x_carrier        ca
	 where (pi.x_ld_processed is null OR pi.x_ld_processed = 'DELETED')
       and pi.x_part_inst_status||'' in  ('11','12','13','15','16','37','38','39')
	   and ca.objid          = pi.part_inst2carrier_mkt
	   and ca.x_ld_provider  = 'Sprint'
       and rownum < 15000;
    begin
     for r_lines in c_lines loop
      if mod(v_cnt,1000) = 0 then
       commit;
      end if;
      v_data := r_lines.x_ld_account || r_lines.part_Serial_no || r_lines.part_Serial_no || 'SS NONEE';
      dbms_output.put_line(v_data);
      update table_part_inst
         set x_ld_processed = 'INSERTED'
       where x_domain = 'LINES'
        and part_serial_no = r_lines.part_serial_no;
      v_cnt := v_cnt +1;
     end loop;
     commit;
    end get_new_lines;
-----------------------------------------------------------------------
    Procedure get_deleted_lines is
    v_data     varchar2(200);
    v_cnt      number :=1;
    cursor c_lines is
     select pi.part_serial_no,
	       ca.x_ld_account
	  from table_part_inst        pi,
	       table_x_carrier        ca
	 where pi.x_ld_processed = 'INSERTED'
       and pi.x_part_inst_status||'' in ('17','18','33','35','36')
	   and ca.objid          = pi.part_inst2carrier_mkt
	   and ca.x_ld_provider  = 'Sprint'
        and rownum < 15000;
    begin
     for r_lines in c_lines loop
      if mod(v_cnt,1000) = 0 then
       commit;
      end if;
      v_data := r_lines.part_Serial_no || r_lines.x_ld_account || '861641010' ;
      dbms_output.put_line(v_data);
      update table_part_inst
         set x_ld_processed = 'DELETED'
       where x_domain = 'LINES'
        and part_serial_no = r_lines.part_serial_no;
      v_cnt := v_cnt +1;
     end loop;
     commit;
    end get_deleted_lines;
    END SPRINT;
/