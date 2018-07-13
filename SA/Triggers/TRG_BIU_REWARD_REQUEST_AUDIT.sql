CREATE OR REPLACE TRIGGER sa."TRG_BIU_REWARD_REQUEST_AUDIT"
  --
  -- CR41473 - LRP2 - Triigger for populating the audit columns of a new table
  BEFORE INSERT OR UPDATE ON sa.x_reward_request
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
  --
BEGIN
  -- Populates the update_timestamp columns with sysdate
    :NEW.update_timestamp := SYSDATE;
  --
END;
/