CREATE OR REPLACE TRIGGER sa."SITE_PART_TRG_BIUR"
BEFORE INSERT OR UPDATE OF X_EXPIRE_DT
ON sa.TABLE_SITE_PART
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
  check_action INTEGER;
  BEGIN
    IF UPDATING THEN
      IF UPPER(:new.part_status) ='ACTIVE' THEN
        :new.x_actual_expire_dt :=:new.x_expire_dt;            -- updating the new value of x_expire_dt to the new date field
      ELSE
        IF UPPER(:new.part_status) ='INACTIVE' THEN
          IF UPPER(:new.x_deact_reason) ='PASTDUE' THEN        -- For PASTDUE x_expire_dt is not modified, the new date field and x_expire_dt should have same value
            :new.x_actual_expire_dt :=:old.x_expire_dt;
           -- ELSIF(:new.x_deact_reason ='NONUSAGE') THEN
           --  :new.x_actual_expire_dt :=:new.x_expire_dt;
           elsif :new.x_deact_reason = 'SENDCARRDEACT' then --CR12858
             if :old.x_actual_expire_dt > SYSDATE then
               :new.x_actual_expire_dt := sysdate;
             end if; --CR12858
          ELSE
           BEGIN
             SELECT 1
             INTO check_action
             FROM sa.table_x_code_table
             WHERE UPPER(x_code_name) = UPPER(:new.x_deact_reason)
             AND UPPER(Action)='EXPIRE';                         -- Checks for x_code_name and ACTION VALUE in table_x_code_table
               :new.x_actual_expire_dt :=SYSDATE;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
             IF :old.x_expire_dt > SYSDATE+2 THEN
              :new.x_actual_expire_dt :=SYSDATE+2;              -- Action is not EXPIRE, Reason Not PASTDUE, x_expire_dt > sysdate+2
             ELSE
                NULL;                                           -- Action is not EXPIRE, Reason Not PASTDUE, x_expire_dt <= sysdate+2
             END IF;
           END;
          END IF;
        END IF;
      END IF;
      -- CR15023 STARTS
      UPDATE sa.X_SERVICE_PLAN_SITE_PART
       SET X_LAST_MODIFIED_DATE = SYSDATE
      WHERE TABLE_SITE_PART_ID = :new.objid;
      -- CR15023 ENDS
    ELSIF INSERTING THEN
      IF UPPER(:new.part_status) ='ACTIVE' THEN
        :new.x_actual_expire_dt  :=:new.x_expire_dt;            -- Activating a NEW ESN, new date field will be updated by new value of x_expire_dt
      END IF;
      -- CR15023 STARTS
      UPDATE sa.X_SERVICE_PLAN_SITE_PART
       SET X_LAST_MODIFIED_DATE = SYSDATE
      WHERE TABLE_SITE_PART_ID = :new.objid;
      -- CR15023 ENDS
    END IF;
  END;
/