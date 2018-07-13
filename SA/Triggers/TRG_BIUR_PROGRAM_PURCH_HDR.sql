CREATE OR REPLACE TRIGGER sa."TRG_BIUR_PROGRAM_PURCH_HDR" BEFORE
  INSERT OR
  UPDATE OF x_status ON sa.x_program_purch_hdr REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
DECLARE
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
  -- get the esn and min of the enrolled purchase
  CURSOR get_esn_curs IS
    SELECT /*+ ORDERED */ DISTINCT ppd.x_esn esn, rownum row_num
    FROM   x_program_purch_dtl ppd
    WHERE  1 = 1
    AND    ppd.pgm_purch_dtl2prog_hdr = :NEW.objid;

  --
  CURSOR get_throttled_esns ( c_esn IN VARCHAR2, c_min IN VARCHAR2 ) IS
    SELECT tc.*,
           ( SELECT agm.account_group_id group_id
             FROM   x_account_group_member agm
             WHERE  agm.esn = c_esn
             AND    agm.status = 'ACTIVE'
             AND    agm.objid = ( SELECT MIN(objid)
                                  FROM   x_account_group_member
                                  WHERE  esn = agm.esn
                                  AND    status = agm.status
                                )
             AND    ROWNUM = 1 -- CR42: added to avoid duplicate active members issue
           ) group_id,
           NVL(sa.brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => sa.util_pkg.get_bus_org_id ( i_esn => c_esn ) ),'N') shared_group_flag
    FROM   w3ci.table_x_throttling_cache tc
    WHERE  1 = 1
    AND    (tc.x_esn = c_esn OR tc.x_min = c_min)
    AND    tc.x_status IN ('A','P'); -- CR42299: Added P for Pending Throttled Requests

  --Cursor to get the program parameter program class information
  CURSOR get_program_class_curs IS
    select pp.x_prog_class
      from x_program_purch_dtl dtl,
           x_program_enrolled pe,
           x_program_parameters pp
     where 1 = 1
       and dtl.pgm_purch_dtl2prog_hdr     = :NEW.objid
       and dtl.pgm_purch_dtl2pgm_enrolled = pe.objid
       and pe.PGM_ENROLL2PGM_PARAMETER    = pp.objid;
   get_program_class_rec  get_program_class_curs%rowtype;

  n_error_code        NUMBER         := 0;
  c_error_message     VARCHAR2(4000) := NULL;
  n_throttle_priority NUMBER         := 1;
  c_throttle_source   VARCHAR2(50)   := 'PURCH_HDR_TRIG';
  l_min               VARCHAR2(50)   := NULL;

  function is_unthrottle_pgm_class (i_program_class in varchar2,
                                    i_payment_type  in varchar2) return boolean
  is
   cnt number := 0;
  begin
    select count(1)
      into cnt
      from w3ci.x_unthrottle_program_class
     where nvl(program_class,'XYXY') = nvl(i_program_class, 'XYXY')
       and payment_type = i_payment_type;
    --
    if cnt >0 then
       return true;
    else
       return false;
    end if;
  end;

BEGIN

   -- Go Smart changes
   -- Do not fire trigger if global variable is turned off
   if not sa.globals_pkg.g_run_my_trigger then
      return;
   end if;
   -- End Go Smart changes

  c_error_message := 'step1';
  -- CR21966
  IF ( INSERTING AND :NEW.x_payment_type = 'REFUND') OR
     ( UPDATING AND
       :NEW.x_payment_type = 'REFUND' AND
       NVL(:NEW.x_payment_type,'XYXY') != :OLD.x_payment_type
     )
  THEN
    UPDATE x_content_purch_dtl
    SET    x_delivery_status = 'REFUND ' || :NEW.x_status
    WHERE  x_content2pgm_purch_hdr IN ( SELECT h2.objid
                                        FROM   x_program_purch_hdr h2
                                        WHERE  h2.objid = :NEW.purch_hdr2cr_purch
                                      );
    COMMIT;
  END IF;

  c_error_message := 'step2';
  -- CR21966
  IF INSERTING OR UPDATING THEN
    --
    BEGIN
      IF (:OLD.x_status <> :NEW.x_status) OR (:OLD.x_status IS NOT NULL AND :NEW.x_status IS NULL)
      THEN
        :NEW.x_process_date := SYSDATE;
      ELSIF (:OLD.x_status  IS NULL AND :NEW.x_status IS NOT NULL) THEN -- CR12382
        :NEW.x_process_date := :NEW.x_rqst_date;
      END IF;
     EXCEPTION
       WHEN OTHERS THEN
         -- construct debug message
         NULL;
    END;
    -- Save changes
    COMMIT;
  END IF;

  -- CR29939
  -- Changed IF condition for CR33629
  --
  c_error_message := 'step3';
  open  get_program_class_curs;
    fetch get_program_class_curs into get_program_class_rec;
  close get_program_class_curs;

  c_error_message := 'step4';
  IF ( INSERTING AND NVL(:NEW.X_ICS_RCODE,'0') IN ('1', '100')                                                                  -- Successful payments
       AND ((:NEW.x_merchant_id IS NOT NULL AND :NEW.x_merchant_id NOT LIKE '%wusa%') OR :NEW.x_payment_type = 'LL_RECURRING' ) -- Exclude BML / Include SAFELINK
       AND :NEW.x_payment_type NOT IN ('REFUND', 'OTAPURCH')                                                                    -- Exclude Refunds and mobile billing
       AND is_unthrottle_pgm_class (i_program_class => get_program_class_rec.x_prog_class,
                                    i_payment_type  => :NEW.x_payment_type )
			-- unthrottle by program paramter program classes/purch hdr payment type
     ) OR
     ( UPDATING AND NVL(:NEW.x_ics_rcode,'0') IN ('1','100')                                                                    -- Exclude BML
       AND NVL(:OLD.x_ics_rcode,'0') NOT IN ('1','100')                                                                         -- Exclude BML
       AND ((:NEW.x_merchant_id IS NOT NULL AND :NEW.x_merchant_id NOT LIKE '%wusa%') OR :NEW.x_payment_type = 'LL_RECURRING' ) -- Exclude BML / Include SAFELINK
       AND  :NEW.x_payment_type NOT IN ('REFUND', 'OTAPURCH')                                                                   -- Exclude Refunds and mobile billing
       AND  is_unthrottle_pgm_class (i_program_class => get_program_class_rec.x_prog_class,
                                     i_payment_type  => :NEW.x_payment_type )
			-- unthrottle by program paramter program classes/purch hdr payment type
     )
  THEN
    c_error_message := 'step5';
    FOR i IN get_esn_curs LOOP
      c_error_message := 'step6:'||i.esn;

      BEGIN
        SELECT pi_min.part_serial_no
        INTO   l_min
        FROM   table_part_inst pi_esn,
               table_part_inst pi_min
        WHERE  pi_esn.part_serial_no = i.esn
        AND    pi_esn.x_domain = 'PHONES'
        AND    pi_min.part_to_esn2part_inst = pi_esn.objid
        AND    pi_min.x_domain = 'LINES'
        AND    ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      -- Search for throttled subscribers
      FOR throttled_esns IN get_throttled_esns ( i.esn, l_min ) LOOP
        BEGIN
          INSERT INTO w3ci.x_stg_ttoff_transactions
                    (objid                   ,
                     esn                     ,
                     MIN                     ,
                     throttle_source_system  ,
                     insert_timestamp        ,
                     shared_group_flag       ,
                     account_group_id  )
            VALUES  (w3ci.seq_x_stg_ttoff_transactions.nextval,
                     throttled_esns.x_esn ,
                     throttled_esns.x_min ,
                     c_throttle_source,
                     SYSDATE,
                     NVL(throttled_esns.shared_group_flag,'N'),
                     throttled_esns.group_id
                     );


        EXCEPTION
          WHEN OTHERS THEN
          c_error_message := SQLERRM;
          sa.ota_util_pkg.err_log ( p_action       => 'EXCEPTION WHILE INSEERT INTO TTOFF STG' ,
                                    p_error_date   => SYSDATE ,
                                    p_key          => i.esn ,
                                    p_program_name => 'TRG_BIUR_PROGRAM_PURCH_HDR' ,
                                    p_error_text   => c_error_message);
        END;

      END LOOP; -- FOR throttled_esns IN get_throttled_esns
    END LOOP; -- FOR i IN get_esn_curs
    --
  END IF;
  -- Save changes
  COMMIT;
  --

 EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     -- construct error message
     c_error_message := SQLERRM;
     -- debug message
     sa.ota_util_pkg.err_log ( p_action       => 'EXCEPTION BLOCK' ,
                               p_error_date   => SYSDATE ,
                               p_key          => :NEW.objid ,
                               p_program_name => 'TRG_BIUR_PROGRAM_PURCH_HDR' ,
                               p_error_text   => c_error_message);

END;
/