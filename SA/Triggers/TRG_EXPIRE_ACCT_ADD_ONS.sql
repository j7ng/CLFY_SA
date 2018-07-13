CREATE OR REPLACE TRIGGER sa."TRG_EXPIRE_ACCT_ADD_ONS"
BEFORE INSERT OR UPDATE  ON sa.x_expire_acct_add_on_benefit REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
   s  subscriber_type;
BEGIN
  -- Update only when the record is not processed
  IF NVL(UPPER(:NEW.processed_flag), UPPER(:OLD.processed_flag)) = 'N' THEN

    IF NVL(:NEW.min, :OLD.min) IS NOT NULL THEN

      -- get the subscriber data
      s := subscriber_type ( i_esn => NULL,
                             i_min => NVL(:NEW.min, :OLD.min) );

      -- exit when there are no addons
      IF NVL(s.addons.COUNT,0) = 0 THEN
        :NEW.processed_flag := 'Y';
        RETURN;
      END IF;

	  -- if there are addons
      IF s.addons.COUNT > 0 THEN

        -- Expire benefit table
        UPDATE x_subscriber_spr_detail
        SET    expired_usage_date = :NEW.expire_timestamp,
               update_timestamp = SYSDATE
        WHERE  subscriber_spr_objid = s.subscriber_spr_objid
        AND    add_on_offer_id = :NEW.offer_id
        AND    add_on_redemption_date = :NEW.add_on_redemption_date;

        -- When updated then set the processed flag
        IF SQL%ROWCOUNT > 0 THEN
          :NEW.processed_flag := 'Y';
        END IF;

      END IF;

    END IF;
  END IF;
END;
/