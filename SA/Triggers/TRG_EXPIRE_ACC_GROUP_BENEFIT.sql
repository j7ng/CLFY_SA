CREATE OR REPLACE TRIGGER sa."TRG_EXPIRE_ACC_GROUP_BENEFIT"
BEFORE INSERT OR UPDATE  ON sa.x_expire_account_group_benefit REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DISABLE DECLARE
  sd       subscriber_detail_type := subscriber_detail_type();
  l_result VARCHAR2(1000);
BEGIN

  -- Update only when the record is not processed
  IF NVL(UPPER(:NEW.processed_flag), UPPER(:OLD.processed_flag)) = 'N' THEN
    -- Expire benefit table
    UPDATE x_account_group_benefit
    SET    status = 'EXPIRED',
           update_timestamp = SYSDATE,
           end_date = :NEW.expire_timestamp,
           reason = 'EXPIRED FROM MaxFeedbackJob'
    WHERE  account_group_id = NVL(:NEW.account_group_id,:OLD.account_group_id)
    AND    insert_timestamp < :NEW.expire_timestamp;
    -- When updated then set the processed flag
    IF SQL%ROWCOUNT > 0 THEN
      :NEW.processed_flag := 'Y';
    END IF;

    -- Synchronize all members in the subscriber detail (add-ons) table
    FOR i IN ( SELECT esn
               FROM   x_account_group_member
               WHERE  account_group_id = NVL(:NEW.account_group_id,:OLD.account_group_id)
               AND    UPPER(status) = 'ACTIVE'
             )
    LOOP
      -- reinsert the detail (add-ons)
      IF NOT sd.ins ( i_esn => i.esn, o_result => l_result ) THEN
        NULL;
      END IF;
    END LOOP;

  END IF;
END;
/