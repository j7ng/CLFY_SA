CREATE OR REPLACE TYPE sa."GROUP_MEMBER_TYPE" AS OBJECT (
  member_objid                    NUMBER(22)     ,
  group_objid                     NUMBER(22)     ,
  esn                             VARCHAR2(30)   ,
  member_order                    NUMBER(2)      ,
  site_part_id                    NUMBER(22)     ,
  promotion_id                    NUMBER(22)     ,
  status                          VARCHAR2(30)   ,
  master_flag                     VARCHAR2(1)    ,
  program_param_id                NUMBER(22)     ,
  start_date                      DATE           ,
  end_date                        DATE           ,
  insert_timestamp                DATE           ,
  update_timestamp                DATE           ,
  receive_text_alerts_flag        VARCHAR2(1)    ,
  subscriber_uid                  VARCHAR2(50)   ,
  response                        VARCHAR2(1000) ,
  numeric_value                   NUMBER         ,
  varchar2_value                  VARCHAR2(2000) ,
  exist                           VARCHAR2(1)    ,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION group_member_type RETURN SELF AS RESULT,
  -- Constructor used to initialize the
  CONSTRUCTOR FUNCTION group_member_type ( i_member_objid IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION group_member_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION group_member_type ( i_esn            IN VARCHAR2 ,
                                           i_group_objid    IN NUMBER   ,
                                           i_status         IN VARCHAR2 ,
                                           i_subscriber_uid IN VARCHAR2 ) RETURN SELF AS RESULT,
  -- Function used to delete an esn from the member table
  MEMBER FUNCTION change_master ( i_group_objid      IN NUMBER   ,
                                  i_esn              IN VARCHAR2 ,
                                  i_switch_pin_flag  IN VARCHAR2 DEFAULT 'Y') RETURN group_member_type,
  -- Function used to delete an esn from the member table
  MEMBER FUNCTION del ( i_esn IN VARCHAR2 ) RETURN group_member_type,
  -- Function used to get the code configuration for an esn
  MEMBER FUNCTION expire ( i_esn IN VARCHAR2 ) RETURN group_member_type,
  -- Function used to expire a group with the group objid
  MEMBER FUNCTION expire ( i_member_objid IN NUMBER ) RETURN group_member_type,
  -- Function used to get the code configuration for an esn
  MEMBER FUNCTION expire RETURN group_member_type,
  -- Function used to get the code configuration for an esn
  MEMBER FUNCTION get_master ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the code configuration for a sim
  MEMBER FUNCTION ins RETURN group_member_type,
  MEMBER FUNCTION save ( i_mbr IN OUT group_member_type ) RETURN VARCHAR2,
  MEMBER FUNCTION save RETURN group_member_type
);
/
CREATE OR REPLACE TYPE BODY sa."GROUP_MEMBER_TYPE" IS
CONSTRUCTOR FUNCTION group_member_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

CONSTRUCTOR FUNCTION group_member_type ( i_member_objid IN NUMBER ) RETURN SELF AS RESULT IS
BEGIN
  BEGIN
    SELECT group_member_type ( objid                      , -- member_objid                 NUMBER(22)     ,
                               account_group_id           , -- group_objid                  NUMBER(22)     ,
                               esn                        , -- esn                          VARCHAR2(30)   ,
                               member_order               , -- member_order                 NUMBER(2)      ,
                               site_part_id               , -- site_part_id                 NUMBER(22)     ,
                               promotion_id               , -- promotion_id                 NUMBER(22)     ,
                               status                     , -- status                       VARCHAR2(30)   ,
                               master_flag                , -- master_flag                  VARCHAR2(1)    ,
                               program_param_id           , -- program_param_id             NUMBER(22)     ,
                               start_date                 , -- start_date                   DATE           ,
                               end_date                   , -- end_date                     DATE           ,
                               insert_timestamp           , -- insert_timestamp             DATE           ,
                               update_timestamp           , -- update_timestamp             DATE           ,
                               receive_text_alerts_flag   , -- receive_text_alerts_flag     VARCHAR2(1)    ,
                               subscriber_uid             , -- subscriber_uid               VARCHAR2(50)   ,
                               NULL                       , -- response                     VARCHAR2(1000),
                               NULL                       , -- numeric_value                NUMBER,
                               NULL                       , -- varchar2_value               VARCHAR2(2000),
                               NULL                         -- exist                        VARCHAR2(1),
                             )
    INTO   SELF
    FROM   x_account_group_member
    WHERE  objid = i_member_objid;
   EXCEPTION
     WHEN OTHERS THEN
       SELF.member_objid := i_member_objid;
       SELF.response := 'MEMBER NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.member_objid := i_member_objid;
     SELF.response := 'MEMBER NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

CONSTRUCTOR FUNCTION group_member_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT IS
BEGIN
  BEGIN
    SELECT group_member_type ( objid                      , -- member_objid                 NUMBER(22)     ,
                               account_group_id           , -- group_objid                  NUMBER(22)     ,
                               esn                        , -- esn                          VARCHAR2(30)   ,
                               member_order               , -- member_order                 NUMBER(2)      ,
                               site_part_id               , -- site_part_id                 NUMBER(22)     ,
                               promotion_id               , -- promotion_id                 NUMBER(22)     ,
                               status                     , -- status                       VARCHAR2(30)   ,
                               master_flag                , -- master_flag                  VARCHAR2(1)    ,
                               program_param_id           , -- program_param_id             NUMBER(22)     ,
                               start_date                 , -- start_date                   DATE           ,
                               end_date                   , -- end_date                     DATE           ,
                               insert_timestamp           , -- insert_timestamp             DATE           ,
                               update_timestamp           , -- update_timestamp             DATE           ,
                               receive_text_alerts_flag   , -- receive_text_alerts_flag     VARCHAR2(1)    ,
                               subscriber_uid             , -- subscriber_uid               VARCHAR2(50)   ,
                               NULL                       , -- response                     VARCHAR2(1000),
                               NULL                       , -- numeric_value                NUMBER,
                               NULL                       , -- varchar2_value               VARCHAR2(2000),
                               NULL                         -- exist                        VARCHAR2(1),
                             )
    INTO   SELF
    FROM   x_account_group_member agm
    WHERE  esn = i_esn
    AND    status != 'EXPIRED'
    AND    objid = ( SELECT MIN(objid)
                     FROM   x_account_group_member
                     WHERE  esn = agm.esn
                     AND    status = agm.status
                   );
   EXCEPTION
     WHEN OTHERS THEN
       SELF.response := 'GROUP NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'GROUP NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

--
CONSTRUCTOR FUNCTION group_member_type ( i_esn              IN VARCHAR2 ,
                                         i_group_objid      IN NUMBER   ,
                                         i_status           IN VARCHAR2 ,
                                         i_subscriber_uid   IN VARCHAR2 ) RETURN SELF AS RESULT IS
BEGIN

  SELF.esn            := i_esn           ;
  SELF.group_objid    := i_group_objid   ;
  SELF.status         := i_status        ;
  SELF.subscriber_uid := i_subscriber_uid;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'ERROR INSTANTIATING GROUP: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

--
MEMBER FUNCTION change_master ( i_group_objid     IN NUMBER   ,   --
                                i_esn             IN VARCHAR2 ,   -- new master esn
                                i_switch_pin_flag IN VARCHAR2 DEFAULT 'Y') RETURN group_member_type AS

  --
  gm group_member_type := group_member_type();
  om group_member_type := group_member_type();
  g  group_type := group_type();
  n_program_enrolled_id NUMBER;
  --
BEGIN
  --
  gm.esn := i_esn;

  -- validate if esn is blank
  IF gm.esn IS NULL THEN
    -- set error code
    gm.response := 'ESN cannot be blank';
    -- exit the program whenever an error occurred
    RETURN gm;
  END IF;

  --
  gm := group_member_type ( i_esn => gm.esn );

  --
  IF gm.group_objid != i_group_objid THEN
    gm.response := 'ESN DOES NOT BELONG TO THE ACCOUNT GROUP';
  END IF;

  -- get the current master of the group that esn belongs to
  om.esn := om.get_master ( i_esn => gm.esn );

  --
  IF NVL(i_switch_pin_flag,'Y') = 'Y' THEN
    -- Flip flop the pin, service plan when a master of the account is changed
    MERGE
    INTO x_service_order_stage NEW
    USING ( SELECT sos.objid,
                   sos.account_group_member_id,
                   sos.esn,
                   sos.service_plan_id,
                   child_data.child_type,
                   child_data.child_service_plan_id,
                   sos.smp,
                   sos.case_id,
                   sos.type,
                   master_data.master_smp,
                   master_data.master_program_param_id,
                   master_data.master_pmt_source_id,
                   master_data.master_case_id,
                   master_data.master_type,
                   NVL( ( SELECT 'Y'
                          FROM   x_account_group_member agm
                          WHERE  agm.account_group_id = i_group_objid
                          AND    agm.esn = sos.esn
                          AND    esn = gm.esn
                          AND    ROWNUM = 1
                   ), 'N') new_master_flag -- new master esn
            FROM   x_service_order_stage sos,
                   ( SELECT objid,
                            case_id master_case_id,
                            type master_type,
                            program_param_id master_program_param_id,
                            pmt_source_id master_pmt_source_id,
                            smp master_smp
                     FROM   x_service_order_stage
                     WHERE  account_group_member_id IN ( SELECT objid
                                                         FROM   x_account_group_member
                                                         WHERE  account_group_id = i_group_objid
                                                         AND    master_flag = 'Y'
                                                       )
                     AND    esn IN ( SELECT esn -- previous master ESN
                                     FROM x_account_group_member
                                     WHERE account_group_id = i_group_objid
                                     AND master_flag        = 'Y'
                                   )
                   ) master_data,
                   ( SELECT type child_type,
                            service_plan_id child_service_plan_id
                     FROM   x_service_order_stage
                     WHERE  account_group_member_id IN ( SELECT objid
                                                         FROM   x_account_group_member
                                                         WHERE  account_group_id = i_group_objid
                                                         AND    master_flag = 'N'
                                                       )
                     AND    esn <> ( SELECT esn -- Previous master esn
                                     FROM   x_account_group_member
                                     WHERE  account_group_id = i_group_objid
                                     AND    master_flag = 'Y'
                                     AND    ROWNUM = 1
                                   )
                     AND ROWNUM = 1
                   ) child_data
            WHERE sos.account_group_member_id IN ( SELECT objid
                                                   FROM   x_account_group_member
                                                   WHERE  account_group_id = i_group_objid
                                                 )
            -- CR39391 - Added SIM_PENDING and CASE_PENDING to below IN clause and also added below OR condition
            AND   ( UPPER(sos.status) IN ('PAYMENT_PENDING','SIM_PENDING','CASE_PENDING') )
          ) data
    ON ( data.objid = new.objid )
    WHEN MATCHED THEN
      UPDATE
      SET    new.smp = ( CASE
                           WHEN data.new_master_flag = 'Y' THEN data.master_smp
                           ELSE NULL
                         END ),
             new.program_param_id = ( CASE
                                        WHEN data.new_master_flag = 'Y'
                                        THEN data.master_program_param_id
                                        ELSE NULL
                                      END),
             new.pmt_source_id = ( CASE
                                     WHEN data.new_master_flag = 'Y'
                                     THEN data.master_pmt_source_id
                                     ELSE NULL
                                   END),
             new.service_plan_id = ( CASE
                                       WHEN data.new_master_flag = 'N'
                                       THEN data.child_service_plan_id
                                       ELSE NULL
                                     END);

  END IF; -- IF NVL(i_switch_pin_flag,'Y') = 'Y' THEN

  -- set the previous master esn as a child
  UPDATE x_account_group_member
  SET    master_flag      = 'N',
         update_timestamp = SYSDATE
  WHERE  account_group_id = i_group_objid
  AND    master_flag      = 'Y';

  -- set the new master esn
  UPDATE x_account_group_member
  SET    master_flag      = 'Y',
         update_timestamp = SYSDATE
  WHERE  account_group_id = i_group_objid
  AND    esn              = gm.esn
  AND    status <> 'EXPIRED';

  -- validate if master esn was set correctly
  IF SQL%ROWCOUNT = 0 THEN
    -- Set error code
    gm.response := 'ACTIVE ESN NOT FOUND';
    -- exit the program whenever an error occurs
    RETURN gm;
  ELSIF SQL%ROWCOUNT > 1 THEN
    -- Set error code
    gm.response := 'DUPLICATE ACTIVE ESN FOUND';
    -- exit the program whenever an error occurs
    RETURN gm;
  END IF;

  -- get the account group (header) data
  g := group_type ( i_esn => gm.esn );

  BEGIN
    SELECT program_enrolled_id
    INTO   n_program_enrolled_id
    FROM   x_account_group
    WHERE  objid IN ( SELECT account_group_id
                      FROM   x_account_group_member
                      WHERE  esn = gm.esn
                      AND    status <> 'EXPIRED'
                    )
    AND    UPPER(status) <> 'EXPIRED';
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- if the group is enrolled in auto refill
  IF n_program_enrolled_id IS NOT NULL THEN

    -- creating x_program_trans history for enrollment
    BEGIN
      INSERT
      INTO x_program_trans
           ( objid,
             x_enrollment_status,
             x_enroll_status_reason,
             x_trans_date,
             x_action_text,
             x_action_type,
             x_esn,
             x_update_user,
             pgm_tran2pgm_entrolled,
             pgm_trans2web_user
           )
      SELECT seq_x_program_trans.NEXTVAL,
             'ENROLLED' ,
             'Change Account Group Enrollment to ESN => ' || gm.esn ,
             SYSDATE ,
             'Enrollment Attempt'  ,
             'ENROLLMENT' ,
             gm.esn ,
             'web2' ,
             n_program_enrolled_id , -- pgm_tran2pgm_enrolled  ,
             pgm_enroll2web_user     -- pgm_trans2web_user
      FROM   x_program_enrolled
      WHERE  objid = n_program_enrolled_id;
     EXCEPTION
       WHEN others THEN
         gm.response := 'ERROR INSERTING PROGRAM TRANS: ' || SQLERRM;
         RETURN gm;
    END;

    -- Updating the new master esn program_enrolled_id
    UPDATE x_program_enrolled
    SET    x_esn = gm.esn,
           ( pgm_enroll2part_inst, pgm_enroll2site_part) = ( SELECT objid,
                                                                    x_part_inst2site_part
                                                             FROM   table_part_inst
                                                             WHERE  part_serial_no = gm.esn
                                                             AND    x_domain = 'PHONES'
                                                             AND    ROWNUM = 1
                                                           ),
           pgm_enroll2contact = ( SELECT pi.x_part_inst2contact
                                  FROM   table_x_contact_part_inst conpi,
                                         table_part_inst pi
                                  WHERE  1 = 1
                                  AND    pi.part_serial_no = gm.esn
                                  AND    pi.x_domain = 'PHONES'
                                  AND    pi.objid = conpi.x_contact_part_inst2part_inst
                                  AND    ROWNUM = 1
                                )
    WHERE  objid = n_program_enrolled_id;

  END IF; -- IF n_program_enrolled_id IS NOT NULL THEN

  -- update new esn part inst objids for the queued redemption cards
  UPDATE table_part_inst pi_pin
  SET    pi_pin.part_to_esn2part_inst = ( SELECT objid
                                          FROM   table_part_inst
                                          WHERE  part_serial_no = gm.esn -- new master esn
                                          AND    x_domain = 'PHONES'
                                          AND    ROWNUM = 1
                                        )
  WHERE  pi_pin.part_to_esn2part_inst IN ( SELECT objid
                                           FROM   table_part_inst
                                           WHERE  part_serial_no IN ( SELECT esn -- all active children of the account group
                                                                      FROM   x_account_group_member
                                                                      WHERE  account_group_id = i_group_objid
                                                                      AND    esn = om.esn -- old master esn
                                                                    )
                                         )
  AND    x_domain = 'REDEMPTION CARDS'
  AND    pi_pin.x_part_inst_status||'' IN ( '400'); -- queued redemption cards

  --
  FOR rec_esn_promo IN ( SELECT DISTINCT
                                promo_objid,
                                program_enrolled_objid
                         FROM   x_enroll_promo_grp2esn
                         WHERE  x_esn = om.esn -- old master esn
                         AND    ( ( x_end_date > SYSDATE)
                                  OR (x_end_date  IS NULL)
                                )
                       )
  LOOP
    IF rec_esn_promo.promo_objid IS NOT NULL THEN
      UPDATE x_enroll_promo_grp2esn
      SET x_end_date             = SYSDATE
      WHERE x_esn                = om.esn -- old master esn
      AND ((x_end_date           > SYSDATE)
      OR (x_end_date            IS NULL))
      AND promo_objid            = rec_esn_promo.promo_objid
      AND program_enrolled_objid = rec_esn_promo.program_enrolled_objid ;
      IF gm.esn                 IS NOT NULL THEN
        --
        sa.enroll_promo_pkg.sp_register_esn_promo ( p_esn         => gm.esn                               ,
                                                    p_promo_objid => rec_esn_promo.promo_objid            ,
                                                    p_program_enrolled_objid=> rec_esn_promo.program_enrolled_objid ,
                                                    p_error_code=> gm.numeric_value                     ,
                                                    p_error_msg=> gm.varchar2_value                    );
      END IF;
    END IF;
  END LOOP;

  --
  gm.response := 'SUCCESS';

 EXCEPTION
   WHEN OTHERS THEN
     -- log error message
     gm.response  := 'UNKNOWN ERROR CHANGING MASTER: ' || SQLERRM;
     RETURN gm;
END change_master;

-- Function used to delete an esn from the member table
MEMBER FUNCTION del ( i_esn IN VARCHAR2 ) RETURN group_member_type IS

  c_block_group_transfer_flag   VARCHAR2(1);
  c_new_master_esn              VARCHAR2(30);
  n_payment_pending_stage_count NUMBER;
  --
  gm  group_member_type := group_member_type ();
  gmt group_member_type := group_member_type ();
  --
  cst customer_type := customer_type();
BEGIN

  --
  gm.esn := i_esn;

  --
  IF gm.esn IS NULL THEN
    gm.response := 'ESN NOT PASSED';
    RETURN gm;
  END IF;

  -- call the retrieve method
  cst := cst.retrieve ( i_esn => gm.esn );

  -- enter logic for shared groups
  IF cst.get_shared_group_flag ( i_esn => gm.esn ) = 'Y' THEN

    -- count the number of records with payment pending
    SELECT COUNT(1)
    INTO   n_payment_pending_stage_count
    FROM   sa.x_service_order_stage so
    WHERE  esn = gm.esn
    AND    UPPER(status) = 'PAYMENT_PENDING';

    -- when there is only one esn remaining in the group
    IF cst.group_total_lines = 1 THEN
      -- Set the group to EXPIRED
      UPDATE x_account_group
      SET    status = 'EXPIRED'
      WHERE  objid = cst.account_group_objid;
    END IF;

    --
    IF cst.member_status NOT IN ('ACTIVE','PENDING_ENROLLMENT') OR cst.member_status IS NULL THEN
      gm.response := 'CANNOT DELETE A MEMBER WHEN IT IS NOT ACTIVE OR PENDING ENROLLMENT';
      --
      RETURN gm;
    END IF;

    -- get the lease status flags
    IF cst.lease_status IS NOT NULL THEN
      BEGIN
        SELECT block_group_transfer_flag
        INTO   c_block_group_transfer_flag
        FROM   sa.x_lease_status
        WHERE  lease_status = cst.lease_status;
       EXCEPTION
         WHEN others THEN
           NULL;
      END;
    END IF;

    -- do not allow leased devices to be removed from an account group
    IF c_block_group_transfer_flag = 'Y' THEN
      gm.response := 'LEASED DEVICE IS NOT ALLOWED TO BE REMOVED FROM THE GROUP';
      -- return
      RETURN gm;
    END IF;

    -- Updating the account group member details.
    UPDATE x_account_group_member
    SET    status           = 'EXPIRED',
           end_date         = SYSDATE,
           update_timestamp = SYSDATE
    WHERE  esn = gm.esn;

    -- If the member to be deleted is the current master of the group
    IF cst.member_master_flag = 'Y' AND cst.group_allowed_lines = 1
    THEN
      -- change the master only when there is more than 1 active member
      IF cst.group_total_lines > 1 THEN
        -- get a new master esn (using the member order)
        BEGIN
          SELECT esn
          INTO   c_new_master_esn
          FROM   ( SELECT esn
                   FROM   x_account_group_member
                   WHERE  account_group_id = cst.account_group_objid
                   AND    status <> 'EXPIRED'
                   AND    ( esn <> gm.esn or gm.esn IS NULL)
                   AND    master_flag = 'N'
                   ORDER BY member_order,
                            objid
                 )
          WHERE  ROWNUM = 1;
        END;

        -- when a new master was not found
        IF c_new_master_esn IS NULL THEN
          --
          gm.response := 'NEW MASTER ESN NOT FOUND';
          --
          RETURN gm;
        END IF;
        -- set the next esn as the master of the group
        gmt := gmt.change_master ( i_group_objid     => cst.account_group_objid,
                                   i_esn             => c_new_master_esn,
                                   i_switch_pin_flag => 'Y');

        -- When an error occurs
        IF gmt.response NOT LIKE '%SUCCESS%' THEN
          --
          RETURN gmt;
        END IF;
      END IF; -- IF cst.group_total_lines > 1 THEN
    END IF; -- IF cst.member_master_flag = 'Y' AND cst.group_allowed_lines = 1

    -- update any pending stage records as deleted
    UPDATE x_service_order_stage so
    SET    status         = 'DELETED',
           update_timestamp = SYSDATE
    WHERE  1 = 1
    AND    esn = gm.esn
    AND    status IN ('PAYMENT_PENDING','PROCESSING','QUEUED','TO_QUEUE');

    -- close all opened staged cases

  ELSE -- IF cst.get_shared_group_flag ( i_esn => gm.esn ) = 'N' THEN
    gm := gm.expire ( i_esn => gm.esn );
    --
    IF gm.response NOT LIKE '%SUCCESS%' THEN
      RETURN gm;
    END IF;
  END IF; -- IF cst.get_shared_group_flag ( i_esn => gm.esn ) = 'Y' THEN

  --
  gm.response := 'SUCCESS';

  RETURN gm;

 EXCEPTION
   WHEN OTHERS THEN
     gm.response := 'MEMBER NOT DELETED: ' || SUBSTR(SQLERRM,1,100);
     RETURN gm;
END del;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION expire ( i_esn IN VARCHAR2 ) RETURN group_member_type IS
  gm  group_member_type := group_member_type ();
  n_act_count 			NUMBER := 0;
  c_new_master_esn 		VARCHAR2(30);
  gmt group_member_type := group_member_type ();
BEGIN

  --
  gm.esn := i_esn;

  --
  IF i_esn IS NULL THEN
    gm.response := 'ESN NOT PASSED';
    RETURN gm;
  END IF;

  --
  UPDATE x_account_group_member agm
  SET    status = 'EXPIRED',
         end_date = SYSDATE,
         update_timestamp = SYSDATE
  WHERE  esn = gm.esn
  AND    status != 'EXPIRED'
  AND    objid = ( SELECT MIN(objid)
                   FROM   x_account_group_member
                   WHERE  esn = agm.esn
                   AND    status = agm.status
                 )
  RETURNING objid                    ,
            account_group_id         ,
            esn                      ,
            member_order             ,
            site_part_id             ,
            promotion_id             ,
            status                   ,
            master_flag              ,
            program_param_id         ,
            start_date               ,
            end_date                 ,
            insert_timestamp         ,
            update_timestamp         ,
            receive_text_alerts_flag ,
            subscriber_uid
  INTO gm.member_objid             ,
       gm.group_objid              ,
       gm.esn                      ,
       gm.member_order             ,
       gm.site_part_id             ,
       gm.promotion_id             ,
       gm.status                   ,
       gm.master_flag              ,
       gm.program_param_id         ,
       gm.start_date               ,
       gm.end_date                 ,
       gm.insert_timestamp         ,
       gm.update_timestamp         ,
       gm.receive_text_alerts_flag ,
       gm.subscriber_uid           ;

  IF SQL%ROWCOUNT = 0 THEN
    IF gm.group_objid IS NULL THEN
      BEGIN
        SELECT account_group_id
        INTO   gm.group_objid
        FROM   ( SELECT account_group_id
   	             FROM   x_account_group_member agm
   	             WHERE  esn = i_esn
                 AND    EXISTS ( SELECT 1
                                 FROM   x_account_group
                                 WHERE  objid = agm.account_group_id
                                 AND    status != 'EXPIRED'
                               )
   	             ORDER BY objid
               )
        WHERE  ROWNUM = 1;
       EXCEPTION
         WHEN others THEN
           NULL;
      END;
    END IF;
  END IF;

   BEGIN
    SELECT COUNT(1)
    INTO   n_act_count
    FROM   x_account_group_member
    WHERE  account_group_id = gm.group_objid
    AND    STATUS = 'ACTIVE';
   EXCEPTION
     WHEN OTHERS THEN
       n_act_count := 0;
  END;

  IF n_act_count > 0  AND  -- if there are other active members within the group
     gm.master_flag = 'Y' -- if the expired member was the master
  THEN
    BEGIN
      SELECT esn
      INTO   c_new_master_esn
      FROM   (
              SELECT esn
              FROM   x_account_group_member
              WHERE  account_group_id = gm.group_objid
              AND    UPPER(status) <> 'EXPIRED'
              AND    master_flag = 'N'
              ORDER BY member_order,
                       objid
             )
      WHERE  ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
         c_new_master_esn := NULL;
    END;

    --
    IF c_new_master_esn IS NOT NULL THEN
              -- set the next esn as the master of the group
        gmt := gmt.change_master ( i_group_objid     => gm.group_objid,
                                   i_esn             => c_new_master_esn,
                                   i_switch_pin_flag => 'Y');
    END IF;
  END IF;
  --
  gm.response := 'SUCCESS';

  RETURN gm;

 EXCEPTION
   WHEN OTHERS THEN
     gm.response := 'MEMBER NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN gm;
END expire;

-- Function used to expire a group with the group objid
MEMBER FUNCTION expire ( i_member_objid IN NUMBER ) RETURN group_member_type IS

  gm  group_member_type := group_member_type ();

BEGIN

  -- set the member objid
  gm.member_objid := i_member_objid;

  --
  IF i_member_objid IS NULL THEN
    gm.response := 'MEMBER OBJID NOT PASSED';
    RETURN gm;
  END IF;

  -- get the esn and other attributes
  gm := group_member_type ( i_member_objid => i_member_objid );

  -- if esn was not found
  IF gm.response NOT LIKE '%SUCCESS%' THEN
    RETURN gm;
  END IF;

  -- call the expire member function by esn
  gm := gm.expire ( i_esn => gm.esn );

  -- return output
  RETURN gm;

 EXCEPTION
   WHEN OTHERS THEN
     gm.response := 'MEMBER NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN gm;
END expire;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION expire RETURN group_member_type IS

  gm  group_member_type := SELF;

BEGIN

  --
  IF gm.member_objid IS NULL THEN
    gm.response := 'MEMBER OBJID NOT PASSED';
    RETURN gm;
  END IF;

  gm := gm.expire ( i_member_objid => gm.member_objid );

  --
  RETURN gm;

 EXCEPTION
   WHEN OTHERS THEN
     gm.response := 'MEMBER NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN gm;
END expire;

--
MEMBER FUNCTION get_master ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  gm group_member_type := group_member_type();

BEGIN
  -- get the master esn of the group
  BEGIN
    SELECT esn
    INTO   gm.esn
    FROM   x_account_group_member ag
    WHERE  account_group_id = ( SELECT account_group_id
                                FROM   x_account_group_member agm
                                WHERE  esn = i_esn
                                AND    objid = ( SELECT MIN(objid)
                                                 FROM   x_account_group_member
                                                 WHERE  esn = agm.esn
                                                 AND    status = agm.status
                                               )
                              )
    AND    master_flag = 'Y'
    AND    objid = ( SELECT MIN(objid)
                     FROM   x_account_group_member
                     WHERE  account_group_id = ag.account_group_id
                     AND    master_flag = 'Y'
                   );
   EXCEPTION
     WHEN others THEN
       RETURN NULL;
  END;
  --
  RETURN gm.esn;
  --
 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_master;

-- Function used to get the code configuration for a sim
MEMBER FUNCTION ins RETURN group_member_type IS

  gm  group_member_type := SELF;
  n_group_total_lines  NUMBER;
BEGIN
  --

  -- validate group id
  IF gm.group_objid IS NULL THEN
    gm.response := 'GROUP ID NOT PASSED';
    RETURN gm;
  END IF;

  -- validate esn
  IF gm.esn IS NULL THEN
    gm.response := 'ESN NOT PASSED';
    RETURN gm;
  END IF;

  -- validate status
  IF gm.status IS NULL THEN
    gm.response := 'STATUS NOT PASSED';
    RETURN gm;
  END IF;

  -- count active members in the group
  BEGIN
    SELECT COUNT(1)
    INTO   n_group_total_lines
    FROM   x_account_group_member
    WHERE  account_group_id = gm.group_objid;
   EXCEPTION
     WHEN others THEN
       n_group_total_lines := 0;
  END;

  -- set the master flag
  gm.master_flag := CASE WHEN n_group_total_lines = 0 THEN 'Y' ELSE 'N' END;

  -- set text alerts flag to the same value as master flag
  gm.receive_text_alerts_flag := gm.master_flag;

  -- set the member order
  BEGIN
    SELECT MAX(member_order) + 1
    INTO   gm.member_order
    FROM   x_account_group_member
    WHERE  account_group_id = gm.group_objid;
   EXCEPTION
     WHEN others THEN
       gm.member_order := 1;
  END;

  -- set default value when not calculated
  gm.member_order := NVL(gm.member_order,1);

  -- set subscriber unique identified
  gm.subscriber_uid := NVL( gm.subscriber_uid, RandomUUID );

  -- set dates
  gm.start_date := SYSDATE;
  gm.end_date := NULL;

  --
  gm.response := gm.save ( i_mbr => gm );

  -- return the row type
  RETURN gm;

 EXCEPTION
   WHEN others THEN
     gm.response := 'ERROR INSERTING MEMBER: ' || SQLERRM;
     RETURN gm;
END ins;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save ( i_mbr IN OUT group_member_type ) RETURN VARCHAR2 IS

  gm  group_member_type := group_member_type ();

BEGIN

  -- Assign timestamp attributes
  i_mbr.insert_timestamp := SYSDATE;
  i_mbr.update_timestamp := SYSDATE;

  -- set unique identifier when not passed
  IF i_mbr.subscriber_uid IS NULL THEN
    i_mbr.subscriber_uid := RandomUUID;
  END IF;

  IF i_mbr.esn IS NULL THEN
    RETURN('ESN NOT PASSED');
  END IF;

  --
  BEGIN
    INSERT
    INTO   x_account_group_member
           ( objid                    ,
             account_group_id         ,
             esn                      ,
             member_order             ,
             site_part_id             ,
             promotion_id             ,
             status                   ,
             master_flag              ,
             program_param_id         ,
             start_date               ,
             end_date                 ,
             insert_timestamp         ,
             update_timestamp         ,
             receive_text_alerts_flag ,
             subscriber_uid
           )
    VALUES
    ( sa.sequ_account_group_member.NEXTVAL ,
      i_mbr.group_objid                    ,
      i_mbr.esn                            ,
      i_mbr.member_order                   ,
      i_mbr.site_part_id                   ,
      i_mbr.promotion_id                   ,
      i_mbr.status                         ,
      i_mbr.master_flag                    ,
      i_mbr.program_param_id               ,
      i_mbr.start_date                     ,
      i_mbr.end_date                       ,
      i_mbr.insert_timestamp               ,
      i_mbr.update_timestamp               ,
      i_mbr.receive_text_alerts_flag       ,
      i_mbr.subscriber_uid
    )
    RETURNING objid,
              subscriber_uid
    INTO      i_mbr.member_objid,
              i_mbr.subscriber_uid;

   EXCEPTION
    WHEN dup_val_on_index then
      RETURN('DUPLICATE VALUE INSERTING INTO MEMBER');
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in MBR (' || i_mbr.member_objid || ')');

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING MEMBER RECORD: ' || SQLERRM;
     --
END save;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save RETURN group_member_type IS

  gm  group_member_type := SELF;

BEGIN

  -- set unique identifier when not passed
  IF gm.subscriber_uid IS NULL THEN
    gm.subscriber_uid := RandomUUID;
  END IF;

  -- call the save method to insert row
  gm.response := gm.save ( i_mbr => gm );

  -- return the entire type
  RETURN gm;

 EXCEPTION
   WHEN OTHERS THEN
     gm.response := 'ERROR SAVING MEMBER RECORD: ' || SQLERRM;
     RETURN gm;
     --
END save;

--
END;
/