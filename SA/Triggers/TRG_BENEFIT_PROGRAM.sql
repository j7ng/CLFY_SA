CREATE OR REPLACE TRIGGER sa.TRG_BENEFIT_PROGRAM AFTER
  INSERT OR
  UPDATE ON sa.x_reward_benefit_program REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_column_name VARCHAR2(100);
  l_column_value                                                                                          VARCHAR2(100);
  l_curr_value                                                                                            VARCHAR2(100);
  v_osuser                                                                                                VARCHAR2(50);
  v_userid                                                                                                VARCHAR2(30);
  ln_objid_to_action NUMBER := 1;
  ln_objid 			NUMBER;
  BEGIN
    SELECT username,
      osuser
    INTO v_userid,
      v_osuser
    FROM v$session s
    WHERE s.audsid = userenv('sessionid');
    IF INSERTING THEN
      FOR REC IN
      (SELECT COLUMN_NAME
      FROM ALL_TAB_COLUMNS
      WHERE TABLE_NAME= 'X_REWARD_BENEFIT_PROGRAM'
      AND OWNER       ='SA'
      )
      LOOP
        l_column_name      :=rec.COLUMN_NAME;
        ln_objid := sa.seq_x_reward_history.nextval;
        IF l_column_name ='OBJID' THEN
          l_column_value   := :new.OBJID;
          ln_objid_to_action := ln_objid;
        ELSIF l_column_name    ='START_DATE' THEN
          l_column_value   := :new.START_DATE;
        ELSIF l_column_name ='END_DATE' THEN
          l_column_value   := :new.END_DATE;
        ELSIF l_column_name ='PROGRAM_NAME' THEN
          l_column_value   := :new.PROGRAM_NAME;
        ELSIF l_column_name ='PROGRAM_DESC' THEN
          l_column_value   := :new.PROGRAM_DESC;
        ELSIF l_column_name ='BENEFIT_TYPE_CODE' THEN
          l_column_value   := :new.BENEFIT_TYPE_CODE;
        ELSIF l_column_name ='BENEFIT_UNIT' THEN
          l_column_value   := :new.BENEFIT_UNIT;
        ELSIF l_column_name ='BRAND' THEN
          l_column_value   := :new.BRAND;
        ELSIF l_column_name ='MIN_THRESHOLD_VALUE' THEN
          l_column_value   := :new.MIN_THRESHOLD_VALUE;
        ELSIF l_column_name ='MAX_THRESHOLD_VALUE' THEN
          l_column_value   := :new.MAX_THRESHOLD_VALUE;
        ELSIF l_column_name ='BENEFIT_VALUE' THEN
          l_column_value   := :new.BENEFIT_VALUE;
        ELSIF l_column_name ='BENEFIT_PRIORITY' THEN
          l_column_value   := :new.BENEFIT_PRIORITY;
        ELSIF l_column_name ='PARTIAL_USAGE_ALLOWED' THEN
          l_column_value   := :new.PARTIAL_USAGE_ALLOWED;
        ELSIF l_column_name ='MIN_THRESHOLD_VALUE' THEN
          l_column_value   := :new.MIN_THRESHOLD_VALUE;
        END IF;
        INSERT
        INTO X_REWARD_HISTORY
          (
            OBJID ,
            TABLE_NAME ,
            COLUMN_NAME ,
            USER_NAME ,
            ACTION ,
            INSERT_DATE ,
            CURRENT_VALUE ,
            NEW_VALUE ,
            OBJID_TO_ACTION
          )
          VALUES
          (
            SEQ_X_REWARD_HISTORY.nextval,
            'X_REWARD_BENEFIT_PROGRAM',
            l_column_name,
            v_userid,
            'INSERT',
            SYSDATE,
            NULL,
            l_column_value,
            :new.OBJID
          );
      END LOOP;
    ELSIF UPDATING THEN
          FOR REC IN
      (SELECT COLUMN_NAME
      FROM ALL_TAB_COLUMNS
      WHERE TABLE_NAME= 'X_REWARD_BENEFIT_PROGRAM'
      AND OWNER       ='SA'
      order by COLUMN_ID
      )
      LOOP
      l_column_name      :=rec.COLUMN_NAME;

      IF  l_column_name IN ('OBJID', 'START_DATE', 'END_DATE', 'BENEFIT_VALUE', 'PARTIAL_USAGE_ALLOWED', 'MIN_THRESHOLD_VALUE') THEN

      ln_objid := seq_x_reward_history.nextval;

       IF l_column_name = 'OBJID' THEN
          l_curr_value   := :old.OBJID;
          ln_objid_to_action := ln_objid;
      ELSIF (:OLD.START_DATE               <> :NEW.START_DATE) THEN
        l_column_name                   :='START_DATE';
        l_column_value                  := :new.START_DATE;
      ELSIF (:OLD.END_DATE              <> :NEW.END_DATE) THEN
        l_column_name                   :='END_DATE';
        l_column_value                  := :new.END_DATE;
      ELSIF (:OLD.BENEFIT_VALUE         <> :NEW.BENEFIT_VALUE) THEN
        l_column_name                   :='BENEFIT_VALUE';
        l_column_value                  := :new.BENEFIT_VALUE;
      ELSIF (:OLD.BENEFIT_PRIORITY      <> :NEW.BENEFIT_PRIORITY) THEN
        l_column_name                   :='BENEFIT_PRIORITY';
        l_column_value                  := :new.BENEFIT_PRIORITY;
      ELSIF (:OLD.PARTIAL_USAGE_ALLOWED <> :NEW.PARTIAL_USAGE_ALLOWED) THEN
        l_column_name                   :='PARTIAL_USAGE_ALLOWED';
        l_column_value                  := :new.PARTIAL_USAGE_ALLOWED;
      ELSIF (:OLD.MIN_THRESHOLD_VALUE   <> :NEW.MIN_THRESHOLD_VALUE) THEN
        l_column_name                   :='MIN_THRESHOLD_VALUE';
        l_column_value                  := :new.MIN_THRESHOLD_VALUE;
      END IF;
      INSERT
      INTO X_REWARD_HISTORY
        (
          OBJID ,
          TABLE_NAME ,
          COLUMN_NAME ,
          USER_NAME ,
          ACTION ,
          INSERT_DATE ,
          CURRENT_VALUE ,
          NEW_VALUE ,
          OBJID_TO_ACTION
        )
        VALUES
        (
          SEQ_X_REWARD_HISTORY.nextval,
          'X_REWARD_BENEFIT_PROGRAM',
          l_column_name,
          v_userid,
          'UPDATE',
          SYSDATE,
          NULL,
          l_column_value,
          :old.OBJID
        );
     END IF;

    END LOOP;

    ElSIF DELETING THEN
     raise_application_error (-20002,SUBSTR('DELETE FROM X_REWARD_BENEFIT_PROGRAM TABLE IS NOT ALLOWED '||SQLERRM,1,255));

    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001,'Error occured - '||sqlerrm||' - '||dbms_utility.format_error_backtrace);
  END;
/