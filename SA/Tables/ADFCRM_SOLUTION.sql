CREATE TABLE sa.adfcrm_solution (
  solution_id NUMBER NOT NULL,
  solution_name VARCHAR2(100 BYTE) NOT NULL,
  solution_description VARCHAR2(400 BYTE) NOT NULL,
  keywords VARCHAR2(100 BYTE) NOT NULL,
  access_type NUMBER NOT NULL,
  phone_status VARCHAR2(100 BYTE) NOT NULL,
  script_type VARCHAR2(20 BYTE),
  script_id VARCHAR2(20 BYTE),
  parent_id NUMBER,
  case_conf_hdr_id NUMBER,
  carrrier_parents VARCHAR2(30 BYTE),
  send_by_email VARCHAR2(10 BYTE),
  file_id NUMBER,
  show_in_popup_window VARCHAR2(20 BYTE),
  file_id_2 NUMBER(22),
  file_id_3 NUMBER(22),
  file_id_4 NUMBER(22),
  file_id_5 NUMBER(22),
  warranty_flag VARCHAR2(10 BYTE),
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_solution_pk PRIMARY KEY (solution_id),
  CONSTRAINT adfcrm_solution_uk UNIQUE (solution_name),
  CONSTRAINT adfcrm_solution_fk2 FOREIGN KEY (case_conf_hdr_id) REFERENCES sa.table_x_case_conf_hdr (objid)
);
COMMENT ON TABLE sa.adfcrm_solution IS 'All solutions currently underway.';
COMMENT ON COLUMN sa.adfcrm_solution.solution_id IS 'Internal unique identifier for the solution.';
COMMENT ON COLUMN sa.adfcrm_solution.solution_name IS 'The unique name of the solution.';
COMMENT ON COLUMN sa.adfcrm_solution.solution_description IS 'The description of the solution.';
COMMENT ON COLUMN sa.adfcrm_solution.keywords IS 'Key words';
COMMENT ON COLUMN sa.adfcrm_solution.access_type IS 'Support Tier: 0=all tiers, 1=1st tier,2=2nd tier';
COMMENT ON COLUMN sa.adfcrm_solution.phone_status IS 'Comma separated phone status ';
COMMENT ON COLUMN sa.adfcrm_solution.script_type IS 'References to table_x_scripts.x_script_type';
COMMENT ON COLUMN sa.adfcrm_solution.script_id IS 'References to table_x_scripts.x_script_id';
COMMENT ON COLUMN sa.adfcrm_solution.parent_id IS 'Reference to adfcrm_solution.solution_id (self-reference), allowing to create a tree structure for solution navigation';
COMMENT ON COLUMN sa.adfcrm_solution.case_conf_hdr_id IS 'Reference to sa.table_x_case_conf_hdr.objid';
COMMENT ON COLUMN sa.adfcrm_solution.send_by_email IS 'Indicate if the solution can be send by email to the customer (YES/NO)';
COMMENT ON COLUMN sa.adfcrm_solution.file_id IS 'Reference to SA.ADFCRM_SOLUTION_FILES.FILE_ID';
COMMENT ON COLUMN sa.adfcrm_solution.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_solution.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_solution.change_type IS 'Type of change INSERT/DELETE/UPDATE';