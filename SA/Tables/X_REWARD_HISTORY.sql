CREATE TABLE sa.x_reward_history (
  objid NUMBER,
  table_name VARCHAR2(50 BYTE),
  column_name VARCHAR2(50 BYTE),
  user_name VARCHAR2(50 BYTE),
  "ACTION" VARCHAR2(20 BYTE),
  insert_date DATE,
  current_value VARCHAR2(100 BYTE),
  new_value VARCHAR2(100 BYTE),
  objid_to_action NUMBER
);
COMMENT ON TABLE sa.x_reward_history IS 'History table for the LRP configuration tables';
COMMENT ON COLUMN sa.x_reward_history.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_reward_history.table_name IS 'Name of the table that was modified ';
COMMENT ON COLUMN sa.x_reward_history.column_name IS 'Column that was changed';
COMMENT ON COLUMN sa.x_reward_history.user_name IS 'Modified user';
COMMENT ON COLUMN sa.x_reward_history."ACTION" IS 'INSERT/UPDATE/DELETE';
COMMENT ON COLUMN sa.x_reward_history.insert_date IS 'Date when the column is changed effective ';
COMMENT ON COLUMN sa.x_reward_history.current_value IS 'Current value of the column changed';
COMMENT ON COLUMN sa.x_reward_history.new_value IS 'New value of the column changed';