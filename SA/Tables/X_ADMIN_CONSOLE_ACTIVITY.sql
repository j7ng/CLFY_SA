CREATE TABLE sa.x_admin_console_activity (
  objid NUMBER,
  x_act_performed VARCHAR2(1000 BYTE),
  x_act_date DATE,
  admin_con2table_user NUMBER
);
ALTER TABLE sa.x_admin_console_activity ADD SUPPLEMENTAL LOG GROUP dmtsora2013249334_0 (admin_con2table_user, objid, x_act_date, x_act_performed) ALWAYS;
COMMENT ON TABLE sa.x_admin_console_activity IS 'Activity log for the Billing Platform Admin Console';
COMMENT ON COLUMN sa.x_admin_console_activity.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_admin_console_activity.x_act_performed IS 'Activity Performed';
COMMENT ON COLUMN sa.x_admin_console_activity.x_act_date IS 'Activity Date';
COMMENT ON COLUMN sa.x_admin_console_activity.admin_con2table_user IS 'Reference to objid in table_user
';