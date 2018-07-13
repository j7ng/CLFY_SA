CREATE OR REPLACE TRIGGER sa."TRG_IG_TRANSACTION_BUCKETS"
BEFORE UPDATE ON gw1.IG_TRANSACTION_BUCKETS REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
--
DISABLE DECLARE
--
  l_esn               VARCHAR2(30);
  c                   sa.customer_type  := customer_type ();
  l_service_plan_id   x_service_plan.objid%TYPE;
--
BEGIN
  --
  IF :new.direction     = 'OUTBOUND' AND
     :new.bucket_id     = 'WALLET'   AND
     :new.benefit_type  = 'SWEEP_ADD'
  THEN
    BEGIN
      SELECT ig.esn
      INTO   l_esn
      FROM   gw1.ig_transaction ig
      WHERE  transaction_id = :new.transaction_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    --
    SELECT sa.customer_info.get_service_plan_objid ( i_esn => l_esn)
    INTO   l_service_plan_id
    FROM DUAL;
    --
    IF l_service_plan_id IN (481,482,483,484)
    THEN
      :new.benefit_type  := 'TRANSFER';
    END IF;
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/