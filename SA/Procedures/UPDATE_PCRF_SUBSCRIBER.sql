CREATE OR REPLACE PROCEDURE sa."UPDATE_PCRF_SUBSCRIBER" (  i_esn                 IN  VARCHAR2              ,
                                                        i_action_type         IN  VARCHAR2              ,
                                                        i_reason              IN  VARCHAR2              ,
                                                        i_prgm_purc_hdr_objid IN  NUMBER   DEFAULT NULL ,
                                                        i_src_program_name    IN  VARCHAR2              ,
                                                        i_sourcesystem        IN  VARCHAR2 DEFAULT NULL ,
                                                        i_ig_order_type       IN  VARCHAR2 DEFAULT NULL ,
                                                        i_transaction_id      IN  NUMBER   DEFAULT NULL ,
                                                        o_error_code          OUT NUMBER                ,
                                                        o_error_msg           OUT VARCHAR2              ,
                                                        i_call_trans_objid    IN  NUMBER   DEFAULT NULL ) IS

  -- Declaration of type variables
  l_new_sid                 VARCHAR2(100);
  l_old_sid                 VARCHAR2(100);
  c_new_esn                 VARCHAR2(30);
  c_old_esn                 VARCHAR2(30) := i_esn;
  l_save_output             VARCHAR2(1000);
  l_return                  VARCHAR2(1000);
  l_ignore_tw_logic_flag    VARCHAR2(1);
  l_cos 					varchar2(30);
  --
  su_addons  sa.subscriber_type := sa.subscriber_type();
  -- sub types
  old_spr  subscriber_type;
  esn_spr  subscriber_type;
  new_spr  subscriber_type;
  sub      subscriber_type;
  s        subscriber_type;
  s1       subscriber_type := subscriber_type ( i_esn );
  su       subscriber_type := subscriber_type ( i_esn );
  sp       subscriber_type;
  detail   subscriber_detail_type := subscriber_detail_type();
  ref_sub  subscriber_type;
  old_sub  subscriber_type;
  new_sub  subscriber_type;
  rms      subscriber_type;
  rs       subscriber_type;
  cst      customer_type := customer_type();
  c        customer_type := customer_type();
  --
  gt       group_type := group_type();
  g        group_type := group_type();
  --
  mt       group_member_type := group_member_type();
  m        group_member_type := group_member_type();
  --
  ctp      case_type := case_type();
  ct       case_type := case_type();
  --
  pcrf     pcrf_transaction_type := pcrf_transaction_type();
  p        pcrf_transaction_type;
  --
  igt      ig_transaction_type;
  ig       ig_transaction_type;
  --
  ctt      call_trans_type;

  c_cross_company_case_title CONSTANT VARCHAR2(20) := '%CROSS%COMPANY%';
  c_current_esn_value_name   CONSTANT VARCHAR2(20) := 'CURRENT_ESN';

  c_new_esn_value_name       CONSTANT VARCHAR2(20) := 'NEW_ESN';
  c_upgrade_case_title       CONSTANT VARCHAR2(30) := '%PHONE%UPGRADE%';
  --
  c_old_esn_value_name       CONSTANT VARCHAR2(20) := 'REFERENCE_ESN';
  c_replacement_case_title   CONSTANT VARCHAR2(30) := '%REPLACEMENT%UNITS%';
  --
  c_ipi_old_esn_value_name   CONSTANT VARCHAR2(20) := 'CURRENT_ESN';
  c_ipi_case_title           CONSTANT VARCHAR2(30) := '%CROSS%COMPANY%';
  --
  c_pir_old_esn_value_name   CONSTANT VARCHAR2(20) := 'CURRENT_ESN';
  c_auto_internal_case_title CONSTANT VARCHAR2(30) := '%AUTO%INTERNAL%';

  c_epir_new_esn_value_name  CONSTANT VARCHAR2(20) := 'NEW_ESN';
  c_epir_case_title          CONSTANT VARCHAR2(30) := '%EXTERNAL%';
--CR57251 NT10 promo
	r_service_plan_rec sa.x_service_plan%rowtype;
--

  -- Cursor to retrieve pcrf order type information
  CURSOR c_get_ct_spr_config IS
    SELECT call_trans_reason,
           spr_applicable_flag,
           pcr_applicable_flag,
           upgrade_applicable_flag,
           replacement_applicable_flag,
           order_type_code,
           delete_spr_flag
    FROM   x_mtm_ct_spr_config
    WHERE  action_type = i_action_type
    AND    NVL(inactive_flag,'Y') = 'N' -- Only get active configuration
    ORDER BY ( CASE
                 WHEN call_trans_reason = UPPER(i_reason) THEN 1
                 WHEN call_trans_reason IS NULL THEN 2
                 ELSE 3
               END ),
             priority_order;

  -- Cursor to retrieve pcrf order type information for ig processing
  CURSOR c_get_ig_spr_config ( p_ig_order_type IN VARCHAR2 ) IS
    SELECT spr_applicable_flag,
           pcr_applicable_flag,
           ipi_flag,
           pir_flag,
           epir_flag,
           minc_flag,
           e_flag,
           order_type_code,
           delete_spr_flag,
           NVL(get_case_flag,'N') get_case_flag,
           NVL(create_new_sub_id_flag,'N') create_new_sub_id_flag
    FROM   x_mtm_ig_spr_config
    WHERE  ig_order_type = p_ig_order_type
    AND    NVL(inactive_flag,'Y') = 'N' -- Only get active configuration
    ORDER BY priority_order;

  -- Internal function to get the subscriber uid for a provided ESN
FUNCTION get_sid ( i_esn IN VARCHAR2) RETURN VARCHAR2 IS
    l_sid VARCHAR2(100);
  BEGIN
    SELECT DISTINCT subscriber_uid
    INTO   l_sid
    FROM   x_account_group_member
    WHERE  esn = i_esn
    AND    UPPER(status) <> 'EXPIRED'
    ORDER BY objid desc;
    RETURN l_sid;
   EXCEPTION
     WHEN others THEN
       RETURN NULL;
  END;

PROCEDURE insert_spr_log ( i_esn                       IN VARCHAR2  ,
                           i_min                       IN VARCHAR2  DEFAULT NULL,
                           i_call_trans_objid          IN NUMBER    DEFAULT NULL,
                           i_program_purch_hdr_objid   IN NUMBER    DEFAULT NULL,
                           i_ig_transaction_objid      IN NUMBER    DEFAULT NULL,
                           i_response                  IN VARCHAR2  DEFAULT NULL,
                           i_action_type               IN VARCHAR2  DEFAULT NULL,
                           i_reason                    IN VARCHAR2  DEFAULT NULL,
                           i_new_esn                   IN VARCHAR2  DEFAULT NULL,
                           i_old_esn                   IN VARCHAR2  DEFAULT NULL,
                           i_program_name              IN VARCHAR2  ,
                           i_action                    IN VARCHAR2  ) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  INSERT
  INTO   sa.x_spr_error_log
         ( objid                   ,
           esn                     ,
           min                     ,
           call_trans_objid        ,
           program_purch_hdr_objid ,
           ig_transaction_objid    ,
           response                ,
           program_name            ,
           action                  ,
           action_type             ,
           reason                  ,
           new_esn                 ,
           old_esn
         )
  VALUES
  ( spr_error_log_seq.NEXTVAL ,
    i_esn                     ,
    i_min                     ,
    i_call_trans_objid        ,
    i_program_purch_hdr_objid ,
    i_ig_transaction_objid    ,
    i_response                ,
    i_program_name            ,
    i_action                  ,
    i_action_type             ,
    i_reason                  ,
    i_new_esn                 ,
    i_old_esn
  );
  -- Save changes
  COMMIT;
 EXCEPTION
   WHEN others THEN
     ROLLBACK;
END;

-- CR39916 Start - 10/05/2016 PMistry added new cursor to get cos value for compensation flow if it exists.
PROCEDURE set_compensation_case ( i_esn              IN  VARCHAR2,
                                  i_transaction_id   IN  NUMBER   DEFAULT NULL,
                                  i_call_trans_objid IN  NUMBER   DEFAULT NULL,
                                  i_old_esn          IN  VARCHAR2 DEFAULT NULL) IS

  cursor cur_get_cos_from_case (c_esn IN VARCHAR2 )is
      select cd_pf.objid process_flag_objid, cd_pf.x_value process_flag_value,
             row_number () over (order by c.creation_time desc ) r_num
      from   table_case c, table_x_case_detail cd_cos, table_x_case_detail cd_pf
      where  1 = 1
      and    c.x_esn = c_esn
      and    c.title in ('Replacement Units', 'Replacement Service Plan', 'Compensation Units' )
      and    c.x_case_type = 'Units'
      and    cd_cos.detail2case = c.objid
      and    cd_pf.detail2case = c.objid
      and    cd_cos.x_name = 'COS'
      and    cd_pf.x_name = 'PROCESS_FLAG'
      and    cd_pf.x_value = 'N'
      order by creation_time desc;

  rec_get_cos_from_case  cur_get_cos_from_case%rowtype;

  s1  subscriber_type := subscriber_type (i_esn);

  awop_cnt NUMBER := 0;

BEGIN

  -- Validate the ESN is passed
  IF i_esn IS NULL THEN
    RETURN;
  END IF;

  -- close the open cases for old esn when the upgrade happened
  IF i_old_esn IS NOT NULL THEN
     FOR rec_get_cos_from_case_old in cur_get_cos_from_case (i_old_esn)
     LOOP
        -- close all open cases
        update sa.table_x_case_detail
        set    x_value = 'Y'
        where  objid = rec_get_cos_from_case_old.process_flag_objid;
     END LOOP;
  --
  ELSE
      -- Checking current transaction is AWOP/Replacement
      BEGIN
        SELECT count (1)
          INTO awop_cnt
          FROM sa.table_x_call_trans ct,
               sa.table_task tt,
               gw1.ig_transaction ig
        WHERE  ct.objid = tt.x_task2x_call_trans
          and  tt.task_id = ig.action_item_id
          and  (ct.objid = i_call_trans_objid OR ig.transaction_id = i_transaction_id)
          and  ct.x_reason in ('AWOP', 'REPLACEMENT');

      EXCEPTION
       WHEN OTHERS THEN
         NULL;
      END;

      FOR rec_get_cos_from_case  in cur_get_cos_from_case (i_esn)
      LOOP
        -- close all open cases
        IF rec_get_cos_from_case.r_num > 1 then
           update sa.table_x_case_detail
           set    x_value = 'Y'
           where  objid = rec_get_cos_from_case.process_flag_objid;
        END IF;

        -- Close the current case whenever new redemtion happend
        IF rec_get_cos_from_case.r_num = 1 AND awop_cnt = 0
           AND s1.pcrf_last_redemption_date <> sa.util_pkg.get_last_base_red_date ( i_esn => i_esn ) THEN
           --
           update sa.table_x_case_detail
           set    x_value = 'Y'
           where  objid = rec_get_cos_from_case.process_flag_objid;
        END IF;
      END LOOP;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
     NULL;
END set_compensation_case;
-- CR39916 End
PROCEDURE set_winback_promo (i_esn in VARCHAR2)
IS
BEGIN

  IF i_esn IS NULL THEN
    RETURN;
  END IF;

  --update reactivation promo
	UPDATE  sa.st_winback
	SET	    inactive_flag    = 'Y',
		      update_timestamp = SYSDATE
	WHERE  	esn = i_esn
	AND    	inactive_flag    = 'N';

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

-- Transfer add on benefits to upgade esn CR49890
PROCEDURE transfer_addon_beneifts (i_accnt_grp_uid in VARCHAR2,
                                   i_new_grp_id   in NUMBER )
AS
l_old_grp_id NUMBER;
BEGIN

 IF i_accnt_grp_uid IS NULL OR i_new_grp_id IS NULL THEN
    RETURN;
 END IF;

 BEGIN
   select max(objid)
    into  l_old_grp_id
    from  sa.x_account_group
   where  STATUS = 'EXPIRED'
     and  ACCOUNT_GROUP_UID = i_accnt_grp_uid;
 EXCEPTION
   WHEN OTHERS THEN
    NULL;
 END;

 update sa.x_account_group_benefit
   set  account_group_id = i_new_grp_id
 where  account_group_id = l_old_grp_id
   and  status = 'ACTIVE';

EXCEPTION
 WHEN OTHERS THEN
  NULL;
END;

-- To expire the compensation addons based on redemption date
PROCEDURE expire_compensation_addon (i_esn in VARCHAR2)
AS

BEGIN
 IF i_esn IS NULL THEN
   RETURN;
 END IF;

 -- get the active compensation addons CR48780
 FOR i in ( SELECT agb.call_trans_id, rc.x_red_date , agb.status,agb.end_date,spp.rollover_flag,spp.ignore_ig_flag
            FROM   x_account_group_member agm,
                   x_account_group_benefit agb,
                   table_x_red_card rc,
                   sa.service_plan_feat_pivot_mv spp
            WHERE  agm.esn = i_esn
            AND    agm.account_group_id = agb.account_group_id
            AND    agb.call_trans_id   = rc.red_card2call_trans
            AND    agb.service_plan_id = spp.service_plan_objid
            AND    EXISTS ( SELECT 1
                            FROM   table_x_call_trans
                            WHERE  objid = agb.call_trans_id)
            --AND    nvl(spp.ignore_ig_flag,'N') = 'Y' --CR48780
			      AND    agb.end_date >= trunc(SYSDATE))
    LOOP
        -- comparing with last redemption date with addon redemption
        IF sa.util_pkg.get_last_base_red_date ( i_esn => i_esn ) > i.x_red_date and  nvl(i.ignore_ig_flag,'N') = 'Y' then --CR48780
           update x_account_group_benefit
             set  end_date = sysdate -1,
                  REASON   = 'EXPIRED FROM PCRF SUBSCIBER',
                  STATUS   = 'EXPIRED'
            where call_trans_id = i.call_trans_id;
            -- CR48780  update the end date for the roll over data addon's
        ELSIF nvl(i.rollover_flag, 'N') = 'Y' and i.status = 'ACTIVE' and i.end_date <> trunc(sa.util_pkg.get_expire_dt(i_esn => i_esn) )+ 30 THEN
			--
              update x_account_group_benefit
                set end_date = trunc(sa.util_pkg.get_expire_dt(i_esn => i_esn) + 30 )
              where call_trans_id = i.call_trans_id;
        END IF;
    END LOOP;

EXCEPTION
 WHEN OTHERS THEN
  NULL;
END;
--To capture spr failures in reprocess log table to reprocess
PROCEDURE insert_reprocess_log ( i_esn                       IN VARCHAR2  ,
                                 i_min                       IN VARCHAR2  DEFAULT NULL,
                                 i_call_trans_objid          IN NUMBER    DEFAULT NULL,
                                 i_ig_transaction_id         IN NUMBER    DEFAULT NULL,
                                 i_ig_order_type             IN VARCHAR2  DEFAULT NULL,
                                 i_ct_action_type            IN VARCHAR2  DEFAULT NULL,
                                 i_response                  IN VARCHAR2  DEFAULT NULL,
                                 i_reason                    IN VARCHAR2  DEFAULT NULL,
                                 i_program_name              IN VARCHAR2  DEFAULT NULL,
                                 i_action                    IN VARCHAR2  DEFAULT NULL
                                 ) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  --
  MERGE INTO sa.x_spr_reprocess_log rep1
  USING (select i_ig_transaction_id ig_transaction_id, i_esn esn from dual) rep2
     ON (rep1.ig_transaction_id = rep2.ig_transaction_id and rep1.esn = rep2.esn)
   WHEN MATCHED THEN
 UPDATE SET rep1.reason           = i_reason,
            rep1.response         = i_response,
            rep1.action           = i_action,
            rep1.reprocess_count  = rep1.reprocess_count + 1,
            rep1.update_timestamp = SYSDATE
   WHEN NOT MATCHED THEN
         INSERT ( objid                ,
                  esn                  ,
                  min                  ,
                  call_trans_objid     ,
                  ig_transaction_id    ,
                  ig_order_type        ,
                  ct_action_type       ,
                  reason               ,
                  response             ,
                  program_name         ,
                  action               ,
                  reprocess_flag
                )
          VALUES
          ( sa.spr_reprocess_log_seq.NEXTVAL ,
            i_esn                     ,
            i_min                     ,
            i_call_trans_objid        ,
            i_ig_transaction_id       ,
            i_ig_order_type           ,
            i_ct_action_type          ,
            i_reason                  ,
            i_response                ,
            i_program_name            ,
            i_action                  ,
            'N'                        --reprocess_flag
           );
    -- Save changes
  COMMIT;
 EXCEPTION
   WHEN others THEN
     ROLLBACK;
END;


-- Main Section of update_subscriber procedure
BEGIN

   port_out_pkg.set_portout_winback_promo(i_esn           => i_esn,
                                          i_ig_order_type => i_ig_order_type,
                                          o_errcode       => o_error_code,
                                          o_errmsg        => o_error_msg );

   o_error_code      := NULL;
   o_error_msg       := NULL;

  IF i_action_type IS NOT NULL THEN
   --

   c.brand_shared_group_flag := c.get_shared_group_flag ( i_esn => i_esn );

   --expiring the compensation add on
   expire_compensation_addon (i_esn => i_esn);

   -- Loop through the cursor c_get_action_type_config
   FOR i in c_get_ct_spr_config LOOP
      -- Initialize the type to use the attributes

        -- AWOP and Replacement case enhancement
      set_compensation_case ( i_esn               => i_esn,
                              i_transaction_id    => i_transaction_id,
                              i_call_trans_objid  => i_call_trans_objid);
      c_new_esn := i_esn;

      -- Sync ttl dates and expire a subscriber
      IF i.delete_spr_flag = 'Y' THEN

        s1 := subscriber_type (i_esn => i_esn);

        -- Call the delete member function
        IF NOT s1.del THEN
          -- Log error in SPR logging table
          insert_spr_log ( i_esn                     => i_esn                 ,
                           i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                           i_ig_transaction_objid    => i_transaction_id      ,
                           i_response                => s1.status             ,
                           i_action_type             => i_action_type         ,
                           i_reason                  => i_reason              ,
                           i_program_name            => i_src_program_name    ,
                           i_action                  => 'DELETING (EXPIRING) SUBSCRIBER');
          --
        END IF;
        --

      END IF; -- IF i.delete_spr_flag = 'Y'
      -- End Logic for Deactivations

      -- Logic for redemption replacements
      IF i.replacement_applicable_flag = 'Y' THEN
        IF i.call_trans_reason = UPPER(i_reason) THEN
          -- Get the old esn
          BEGIN
            SELECT DISTINCT cd.x_value old_esn
            INTO   c_old_esn
            FROM   table_case c,
                   table_x_case_detail cd
            WHERE  c.x_esn = c_new_esn
            AND    c.s_title LIKE c_replacement_case_title
            AND    c.objid = cd.detail2case
            AND    cd.x_name = c_old_esn_value_name;
           EXCEPTION
             WHEN OTHERS THEN
               c_old_esn := NULL;
               -- Log error in SPR logging table
               insert_spr_log ( i_esn                     => i_esn                 ,
                                i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                                i_ig_transaction_objid    => i_transaction_id      ,
                                i_response                => 'OLD ESN NOT FOUND IN TABLE_CASE: '|| '| ERROR: ' || SUBSTR(SQLERRM,1,100),
                                i_action_type             => i_action_type         ,
                                i_reason                  => i_reason              ,
                                i_program_name            => i_src_program_name    ,
                                i_action                  => 'GETTING OLD ESN IN CASE (TITLE=%REPLACEMENT%UNITS%) (VALUE=REFERENCE_ESN)');
               o_error_code := 130;
               o_error_msg := 'GETTING OLD ESN IN CASE (TITLE=%REPLACEMENT%UNITS%) (VALUE=REFERENCE_ESN)';
               -- Exit the routine
               RETURN;
          END;
          --
          IF c_old_esn IS NULL THEN
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => i_esn                 ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'REPLACING SUBSCRIBER IN SPR',
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'OLD ESN NOT FOUND');
            o_error_code := 130;
            o_error_msg := 'GETTING OLD ESN IN CASE (TITLE=%REPLACEMENT%UNITS%) (VALUE=REFERENCE_ESN)';
            -- Exit the routine
            RETURN;
          END IF;

          IF c.brand_shared_group_flag = 'N' THEN -- brand is not TOTAL_WIRELESS

            -- Expire the account group member row
            UPDATE x_account_group_member
            SET    status = 'EXPIRED'
            WHERE  esn = i_esn
            AND    status <> 'EXPIRED';

            l_new_sid := get_sid(c_new_esn);
            l_old_sid := get_sid(c_old_esn);

            -- Replace esn (member). For non-shared group subscribers there should only be one entry per ESN in the member table
            UPDATE x_account_group_member
            SET    esn = c_new_esn      -- new upgraded esn
            WHERE  esn = c_old_esn      -- old esn
            AND    UPPER(status) <> 'EXPIRED';

            -- When the new ESN already has a SID
            IF l_new_sid IS NOT NULL THEN
              -- Update the record with the new SID with the OLD ESN (to avoid dup data)
              UPDATE x_account_group_member
              SET    esn = c_old_esn
              WHERE  subscriber_uid = l_new_sid;
            END IF;

          END IF; -- if brand is NOT TOTAL_WIRELESS THEN

          -- Retrieve the data from the spr table for the old ESN
          old_spr := subscriber_type ( i_esn => c_old_esn );

          -- Retrieve all the data (from the Clarify tables) for the old ESN except for the group and member logic
          old_sub := old_spr.retrieve ( i_ignore_tw_logic_flag => 'Y' );

          -- Update values for the old ESN (ttl, future ttl and redemption date)
          ref_sub := old_sub.refresh_dates ( i_esn => old_sub.pcrf_esn );

          -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
          l_return := s1.process_upgrade( i_old_esn => c_old_esn,
                                          i_new_esn => c_new_esn);

          --
          IF l_return <> 'SUCCESS' THEN
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => NVL(c_old_esn,i_esn)  ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'REPLACING TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');
          ELSE
            -- Resend ttl dates for new esn
            pcrf := pcrf_transaction_type (i_esn              => c_new_esn,
                                           i_min              => NULL,
                                           i_order_type       => i.order_type_code,
                                           i_zipcode          => ref_sub.zipcode,
                                           i_sourcesystem     => i_sourcesystem,
                                           i_pcrf_status_code => 'Q');

            -- Call insert pcrf transaction member procedure
            p := pcrf.ins;

          END IF;
        END IF; -- IF UPPER(i.call_trans_reason) = i_reason

      END IF; --
      -- End logic for redemption replacements

      -- Logic for Upgrades
      IF i.upgrade_applicable_flag = 'Y' THEN
        IF UPPER(i_reason) <> i.call_trans_reason THEN
          IF c.brand_shared_group_flag = 'N' THEN -- brand is NOT TOTAL_WIRELESS
            -- Expire the account group member row
            UPDATE x_account_group_member
            SET    status = 'EXPIRED'
            WHERE  esn = i_esn
            AND    status <> 'EXPIRED';
          END IF;
        ELSE -- If the provided reason was for upgrades

          -- Get the new upgraded esn
          BEGIN
            SELECT DISTINCT cd.x_value new_esn
            INTO   c_new_esn
            FROM   table_case c,
                   table_x_case_detail cd
            WHERE  c.x_esn = i_esn
            AND    c.s_title LIKE c_upgrade_case_title
            AND    c.objid = cd.detail2case
            AND    cd.x_name = c_new_esn_value_name
            AND    c.objid = ( SELECT MAX(objid)
                               FROM   table_case
                               WHERE  x_esn = c.x_esn
                               AND    s_title LIKE c_upgrade_case_title
                             );
           EXCEPTION
             WHEN OTHERS THEN
               c_new_esn := NULL;
               -- Find the new upgraded esn from the case detail
               BEGIN
                 SELECT DISTINCT c.x_esn new_esn
                 INTO   c_new_esn
                 FROM   table_x_case_detail cd,
                        table_case c
                 WHERE  cd.x_name = c_pir_old_esn_value_name
                 AND    cd.x_value = i_esn
                 AND    cd.detail2case = c.objid
                 AND    c.s_title LIKE c_auto_internal_case_title
                 AND    c.objid = ( SELECT MAX(objid)
                                    FROM   table_case
                                    WHERE  x_esn = c.x_esn
                                    AND    s_title LIKE c_auto_internal_case_title
                                  );
                EXCEPTION
                  WHEN others THEN
                    c_new_esn := NULL;
                    -- Log error in SPR logging table
                    insert_spr_log ( i_esn                     => i_esn                 ,
                                     i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                                     i_ig_transaction_objid    => i_transaction_id      ,
                                     i_response                => 'NEW ESN NOT FOUND IN THESE CASE TITLES (%PHONE%UPGRADE%, %AUTO%INTERNAL%)',
                                     i_action_type             => i_action_type         ,
                                     i_reason                  => i_reason              ,
                                     i_program_name            => i_src_program_name    ,
                                     i_action                  => 'GETTING NEW ESN FROM CASE');
                    o_error_code := 100;
                    o_error_msg := 'NEW ESN NOT FOUND IN THESE CASE TITLES (%PHONE%UPGRADE%, %AUTO%INTERNAL%)';
                    -- Exit the routine
                    RETURN;
               END;
          END;
          --
          IF c_new_esn IS NULL THEN
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => i_esn                 ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'NEW ESN NOT FOUND IN THESE CASE TITLES (%PHONE%UPGRADE%, %AUTO%INTERNAL%)',
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'UPGRADING SUBSCRIBER IN SPR');
            o_error_code := 110;
            o_error_msg := 'NEW ESN NOT FOUND IN THESE CASE TITLES (%PHONE%UPGRADE%, %AUTO%INTERNAL%)';
            -- Exit the routine
            RETURN;
          END IF;

          -- brand is NOT TOTAL_WIRELESS
          IF c.brand_shared_group_flag = 'N' THEN
            -- Get the NEW and OLD subscriber uid (sid)

            l_new_sid := get_sid(c_new_esn);
            l_old_sid := get_sid(c_old_esn);

            -- Replace esn (member). For non-shared group subscribers there should only be one entry per ESN in the member table
            UPDATE x_account_group_member
            SET    esn = c_new_esn      -- new upgraded esn
            WHERE  esn = c_old_esn      -- old esn
            AND    UPPER(status) <> 'EXPIRED';

            -- When the new ESN already has a SID
            IF l_new_sid IS NOT NULL THEN
              -- Update the record with the new SID with the OLD ESN (to avoid dup data)
              UPDATE x_account_group_member
              SET    esn = c_old_esn
              WHERE  subscriber_uid = l_new_sid;
            END IF;
          END IF; -- not TOTAL_WIRELESS

          -- Retrieve the data from the spr table for the old ESN
          old_spr := subscriber_type ( i_esn => c_old_esn );

          -- Retrieve all the data (from the Clarify tables) for the old ESN except for the group and member logic
          old_sub := old_spr.retrieve ( i_ignore_tw_logic_flag => 'Y');

          -- Update values for the old ESN (ttl, future ttl and redemption date)
          ref_sub := old_sub.refresh_dates ( i_esn => old_sub.pcrf_esn);

          -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
          l_return := s1.process_upgrade( i_old_esn => c_old_esn,
                                          i_new_esn => c_new_esn);

          IF l_return <> 'SUCCESS' THEN
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => NVL(c_old_esn,i_esn)  ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');
          ELSE
            -- Resend ttl dates for new esn
            pcrf := pcrf_transaction_type (i_esn              => c_new_esn,
                                           i_min              => NULL,
                                           i_order_type       => i.order_type_code,
                                           i_zipcode          => ref_sub.zipcode,
                                           i_sourcesystem     => i_sourcesystem,
                                           i_pcrf_status_code => 'Q');

            -- Call insert pcrf transaction member procedure
            p := pcrf.ins;

          END IF;

        END IF; -- IF i_reason <> c_upgrade_reason
      END IF; -- IF i.upgrade_applicable_flag = 'Y'
      -- End logic for Upgrades

      -- Start logic of Syncing the subscriber table
      IF i.spr_applicable_flag = 'Y' THEN

        c := cst.retrieve ( i_esn => c_new_esn );

        sub := subscriber_type (i_esn => c_new_esn,
                                i_min => c.min);

        -- If process is getting called from program purch header trigger only call refresh dates method and get out
        IF i_prgm_purc_hdr_objid IS NOT NULL THEN
          -- Instantiate a blank subscriber type
          sub := subscriber_type ();
          -- Refresh the TTL dates
          s := sub.refresh_dates( i_esn => c_new_esn);
          --
          IF s.status NOT LIKE '%SUCCESS%' THEN
            o_error_code := 11;
            o_error_msg  := s.status;
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => NVL(c_new_esn, i_esn) ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'UPDATING DATES WITH NEW ESN = ' || c_new_esn || s.status,
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'REFRESHING DATES IN SPR (SUBSCRIBER_TYPE.REFRESH_DATES)');
            --
            RETURN;
          ELSE
            o_error_code := 0;
            o_error_msg := s.status;
          END IF;

        ELSE -- IF i_prgm_purc_hdr_objid IS NULL

          IF sub.status NOT LIKE '%SUCCESS%' THEN
             -- Delete SPR by ESN
             rms := subscriber_type ( i_esn => c_new_esn );
             rs  := rms.remove;

             -- Delete SPR by MIN
             rms := subscriber_type ( i_esn => NULL,
                                      i_min => c.min );
             rs  := rms.remove;
          END IF;

          -- Call add subscriber member procedure
		  IF i_action_type != '401' OR NOT sub.exist THEN -- Changes as part of CR50892

			-- net 10 data promo
          l_cos := sa.util_pkg.net10_data_promo (i_esn      => c.esn,
                                                           i_min      => c.min,
                                                           i_sp_objid => c.service_plan_objid,
														   i_ct_objid => i_call_trans_objid);
              s := sub.ins;
		  ELSE
               s := sub.upd;
          END IF;


          IF s.status NOT LIKE '%SUCCESS%' THEN
            o_error_code := 11;
            o_error_msg  := s.status;
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => i_esn                 ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'CREATING SPR WITH NEW ESN = (' || c_new_esn || ') | ' || s.status,
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'CREATING SUBSCRIBER (SUBSCRIBER_TYPE.INS)');
            --
            RETURN;
          ELSE
            o_error_code := 0;
            o_error_msg := s.status;
          END IF;
        END IF;
      END IF;

      IF i.pcr_applicable_flag = 'Y' THEN
        s1 := subscriber_type (i_esn => c_new_esn);
        s := subscriber_type();
        --
        IF NOT s1.exist then
          -- Call add subscriber member procedure
          s := s1.ins;

         IF s.status NOT LIKE '%SUCCESS' THEN
           o_error_code := 12;
           o_error_msg  := s.status;
           -- Log error in SPR logging table
           insert_spr_log ( i_esn                     => i_esn                 ,
                            i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                            i_ig_transaction_objid    => i_transaction_id      ,
                            i_response                => 'CREATING SPR WITH NEW ESN = ' || c_new_esn || s.status,
                            i_action_type             => i_action_type         ,
                            i_reason                  => i_reason              ,
                            i_program_name            => i_src_program_name    ,
                            i_action                  => 'CREATING SUBSCRIBER PRE-PCRF (SUBSCRIBER_TYPE.INS)');
           --
           RETURN;
          END IF;
        END IF;

        -- Instantiate pcrf transaction table in constructor
        pcrf := pcrf_transaction_type (i_esn              => s1.pcrf_esn,
                                       i_min              => NULL,
                                       i_order_type       => i.order_type_code,
                                       i_zipcode          => s.zipcode,
                                       i_sourcesystem     => i_sourcesystem,
                                       i_pcrf_status_code => 'Q');

        -- Call insert pcrf transaction member procedure
        p := pcrf.ins;

        IF p.status LIKE '%SUCCESS' THEN
          o_error_code := 0;
          o_error_msg  := p.status;
        END IF;

      END IF;
      --
      set_winback_promo (i_esn => s1.pcrf_esn);

      -- Only apply one rule
      EXIT;

    END LOOP; --cursor loop ending.
  END IF;


  -- START LOGIC FOR IG TRANSACTIONS

  IF i_transaction_id IS NOT NULL THEN

    -- call ig transaction type constructor to get the true order type from IG
    igt := ig_transaction_type ( i_transaction_id => i_transaction_id );

    -- call call_trans_type constructor to get the all attributes from the call trans
    ctt := call_trans_type ( i_call_trans_objid => igt.call_trans_objid );

    -- Initialize the type to use the attributes
    c_new_esn := i_esn;

    --expiring the compensation add on
    expire_compensation_addon (i_esn => i_esn);

    -- Loop through the cursor pcrf_ord_typ_curs
    FOR i in c_get_ig_spr_config ( igt.order_type ) LOOP
      --
      set_compensation_case ( i_esn               => i_esn,
                              i_transaction_id    => i_transaction_id,
                              i_call_trans_objid  => i_call_trans_objid);

      IF igt.order_type IN ('A','E') AND i_transaction_id IS NOT NULL THEN
        --
        IF ctt.action_type = '3' THEN
          i.order_type_code := 'UP';
        END IF;
        --
      END IF;

      IF i.delete_spr_flag = 'Y' THEN
        s1 := subscriber_type (i_esn => i_esn);
        -- Call the delete member function
        IF NOT s1.del THEN
          -- Log error in SPR logging table
          insert_spr_log ( i_esn                     => i_esn                 ,
                           i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                           i_ig_transaction_objid    => i_transaction_id      ,
                           i_response                => s1.status             ,
                           i_action_type             => i_action_type         ,
                           i_reason                  => i_reason              ,
                           i_program_name            => i_src_program_name    ,
                           i_action                  => 'DELETING (EXPIRING) SUBSCRIBER CALLING SUBSCRIBER_TYPE.DEL');

          o_error_code := 1;
          o_error_msg  := 'ERROR EXPIRING THE SUBSCRIBER';
          --
          RETURN;
          --
        END IF;
        --
        -- Generate a UP for new ESN
        pcrf := pcrf_transaction_type ( i_esn              => i_esn,
                                        i_min              => NULL,
                                        i_order_type       => i.order_type_code,
                                        i_zipcode          => s1.zipcode,
                                        i_sourcesystem     => i_sourcesystem,
                                        i_pcrf_status_code => 'Q' );

        -- Call insert pcrf transaction member procedure
        p := pcrf.ins;

      END IF; -- IF i.delete_spr_flag = 'Y'

      -- Logic for min changes
      IF i.minc_flag = 'Y' THEN

          c := customer_type ();

          -- get the shared group flag for an esn
          c.brand_shared_group_flag := c.get_shared_group_flag ( i_esn => i_esn );

          -- Instantiate the sub and assign the esn to => SELF.pcrf_esn
          new_sub  := subscriber_type ( i_esn => i_esn );

          l_ignore_tw_logic_flag := CASE WHEN (c.brand_shared_group_flag = 'N' AND i.create_new_sub_id_flag = 'Y') THEN 'N' ELSE 'Y' END;

          -- Retrieve all the new ESN information to new_sub
          new_spr := new_sub.retrieve ( i_ignore_tw_logic_flag => l_ignore_tw_logic_flag );

          IF new_spr.status NOT LIKE '%SUCCESS%' THEN
             --instert failures in spr_reprocess table
             insert_reprocess_log ( i_esn                     => i_esn                 ,
                                    i_min                     => new_spr.pcrf_min      ,
                                    i_ig_transaction_id       => i_transaction_id      ,
                                    i_ig_order_type           => igt.order_type        ,
                                    i_response                => 'SUBSCRIBER_TYPE.STATUS = ' || s.status,
                                    i_program_name            => i_src_program_name    ,
                                    i_action                  => 'CHECKING SUBSCRIBER MINC SUBSCRIBER_TYPE.RETRIEVE');
            RETURN;
          END IF;

          -- Delete SPR by ESN
          rms := subscriber_type ( i_esn => new_spr.pcrf_esn );
          rs  := rms.remove;

          -- Delete SPR by MIN
          rms := subscriber_type ( i_esn => NULL,
                                   i_min => new_spr.pcrf_min );
          rs  := rms.remove;

          -- Save the new SPR row
          s := subscriber_type ();
          s := new_spr.ins;

          -- If the new ESN was not saved properly exit the iteration
          IF s.status NOT LIKE  '%SUCCESS%' THEN
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => i_esn                 ,
                             i_min                     => new_spr.pcrf_min      ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => s.status              ,
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'SAVING SUBSCRIBER SUBSCRIBER_TYPE.SAVE');

            --instert failures in spr_reprocess table
            insert_reprocess_log ( i_esn                     => i_esn                 ,
                                   i_min                     => new_spr.pcrf_min      ,
                                   i_ig_transaction_id       => i_transaction_id      ,
                                   i_ig_order_type           => igt.order_type        ,
                                   i_response                => 'SUBSCRIBER_TYPE.STATUS = ' || s.status,
                                   i_program_name            => i_src_program_name    ,
                                   i_action                  => 'SAVING SUBSCRIBER MINC SUBSCRIBER_TYPE.SAVE');
            --
            RETURN;
          END IF;

          -- Generate a UP for new ESN
          pcrf := pcrf_transaction_type ( i_esn              => i_esn,
                                          i_min              => NULL,
                                          i_order_type       => i.order_type_code,
                                          i_zipcode          => new_spr.zipcode,
                                          i_sourcesystem     => i_sourcesystem,
                                          i_pcrf_status_code => 'Q' );

          -- Call insert pcrf transaction member procedure
          p := pcrf.ins;

      END IF;
      -- End logic for min changes

      -- Logic for scenarios where we need to get the case information
      IF i.get_case_flag = 'Y' THEN

        -- start logic of "E" IG order types
        IF i.e_flag = 'Y' THEN

          --
          c_new_esn := i_esn;

          -- reset case type
          ctp := case_type ();
          ct  := case_type ();

          -- call case type member function to get the latest case data
          ct := ctp.get ( i_esn        => c_new_esn ,
                          i_case_title => '%PHONE%UPGRADE%' );

          -- if the esn does not have an UPGRADE case then look for the AUTO INTERNAL
          IF ct.reference_esn IS NULL THEN
            ctp := case_type ();
            ct  := case_type ();

            -- call case type member function to get the latest case data
            ct := ctp.get ( i_esn        => c_new_esn ,
                            i_case_title => '%AUTO%INTERNAL%' );
          END IF;

          -- if the esn does not have an UPGRADE/AUTO INTERNAL case then look for the CROSS COMPANY
          IF ct.reference_esn IS NULL THEN
            ctp := case_type ();
            ct  := case_type ();

            -- call case type function to get the latest case data
            ct := ctp.get ( i_esn        => c_new_esn ,
                            i_case_title => '%CROSS%COMPANY%' );
            --
            c_old_esn := ct.reference_esn;
            -- If the upgrade is CROSS COMPANY
            IF c_old_esn IS NOT NULL THEN

              -- get the reference esn from the member table
              mt := group_member_type ( i_esn => c_old_esn );

              -- only perform the following actions for non shared group brands
              IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR  -- non shared group brands
               mt.member_objid IS NOT NULL                          -- members that have not been upgraded to new esn
              THEN

              -- call retrieve member function to get all the attributes related to an esn
               c := cst.retrieve ( i_esn => c_new_esn );

               IF c.site_part_status <> 'Active' then
                   --instert failures in spr_reprocess table
                insert_reprocess_log ( i_esn                     => c_new_esn             ,
                                       i_min                     => NULL                  ,
                                       i_ig_transaction_id       => i_transaction_id      ,
                                       i_ig_order_type           => igt.order_type        ,
                                       i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn,
                                       i_program_name            => i_src_program_name    ,
                                       i_action                  => 'CHECKING SITE PART STATUS TO PROCESS ORDER TYPE E');
                 --
                o_error_code := 1;
                o_error_msg  := 'SITE PART IS NOT ACTIVE TO PROCESS ORDER TYPE E';
                --
                RETURN;
               END IF;

               -- reset group member type
               mt := group_member_type ();
               m  := group_member_type ();

               -- expire the old account group member by esn
               m := mt.expire ( i_esn => c_old_esn );

               -- expire the old account group by group objid (based on the old esn)
               g := gt.expire ( i_group_objid => m.group_objid );

               -- reset group member type
               m := group_member_type();

               -- reset group type
               g := group_type();

               -- expire the new account group member by esn
               m := mt.expire ( i_esn => c_new_esn );

               -- expire the new account group by group objid (based on the new esn)
               g := gt.expire ( i_group_objid => m.group_objid  );

               -- CREATE NEW MEMBER AND GROUP

               -- reset group type
               gt := group_type ();

               -- instantiate initial values for insertion
               gt := group_type ( i_web_user_objid    => c.web_user_objid     ,
                                  i_service_plan_id   => c.service_plan_objid ,  -- carry over the service_plan_id
                                  i_status            => 'ACTIVE'             ,
                                  i_bus_org_objid     => c.bus_org_objid      ,
                                  i_account_group_uid => NULL                 ); -- leave blank to assign a new group UID

               -- call insert group type member function
               g := gt.ins;

               -- reset group member type
               mt := group_member_type ();

               -- instantiate initial values for insertion
               mt := group_member_type ( i_esn            => c_new_esn     ,
                                         i_group_objid    => g.group_objid ,
                                         i_status         => 'ACTIVE'      ,
                                         i_subscriber_uid => NULL          ); -- leave blank to assign a new subscriber UID

               -- call insert member type function
               m := mt.ins;

               -- END CREATE NEW MEMBER AND GROUP
               -- close open replacement/awop cases for old esn
               set_compensation_case ( i_esn               => c_new_esn,
                                       i_transaction_id    => NULL,
                                       i_call_trans_objid  => NULL,
                                       i_old_esn           => c_old_esn );

               -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
               l_return := su.process_upgrade ( i_old_esn              => c_old_esn              ,
                                                i_new_esn              => c_new_esn              ,
                                                i_last_redemption_date => c.last_redemption_date ,
                                                i_pcrf_subscriber_id   => m.subscriber_uid       ,
                                                i_pcrf_group_id        => g.account_group_uid    );

               IF l_return <> 'SUCCESS' THEN
                 -- Log error in SPR logging table
                 insert_spr_log ( i_esn                     => i_esn                 ,
                                  i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                                  i_ig_transaction_objid    => i_transaction_id      ,
                                  i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                  i_action_type             => i_action_type         ,
                                  i_reason                  => i_reason              ,
                                  i_old_esn                 => c_old_esn             ,
                                  i_new_esn                 => c_new_esn             ,
                                  i_program_name            => i_src_program_name    ,
                                  i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');

                 --instert failures in spr_reprocess table
                 insert_reprocess_log ( i_esn                     => i_esn                 ,
                                        i_min                     => NULL                  ,
                                        i_ig_transaction_id       => i_transaction_id      ,
                                        i_ig_order_type           => igt.order_type        ,
                                        i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                        i_program_name            => i_src_program_name    ,
                                        i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE FOR ORDER TYPE E');

                 o_error_code := 1;
                 o_error_msg  := 'ERROR PROCESSING UPGRADE: ' || l_return;
                 --
                 RETURN;

               END IF;

              -- instantiate pcrf values
              pcrf := pcrf_transaction_type ( i_esn              => c_new_esn,
                                              i_min              => NULL,
                                              i_order_type       => i.order_type_code,
                                              i_zipcode          => c.zipcode,
                                              i_sourcesystem     => i_sourcesystem,
                                              i_pcrf_status_code => 'Q' );

              -- insert a UP pcrf transaction
              p := pcrf.ins;

              su_addons := sa.subscriber_type (i_esn => c_new_esn);
              --
              IF su_addons.addons.COUNT > 0 and c.get_shared_group_flag ( i_esn => i_esn ) = 'N' then
                 transfer_addon_beneifts (i_accnt_grp_uid =>  g.account_group_uid,
                                          i_new_grp_id    =>  g.group_objid);
              END IF;
              -- exit loop
              EXIT;

              --
            END IF; -- IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR

            END IF;  --if old is not null
          END IF;   -- If it's a cross company (port)

          -- set the reference esn (old esn)
          c_old_esn := ct.reference_esn;

          -- if the case is not there consider the transaction as a reactivation
          IF ct.reference_esn IS NULL OR                                  -- if the case was not found
             ct.creation_time < ( igt.creation_date - INTERVAL '2' HOUR ) -- look for cases created today so that we don't get an old case.
          THEN

            -- get min info
            c := cst.retrieve ( i_esn => c_new_esn );

            -- get the data from the subscriber spr
            sub := subscriber_type ( i_esn => i_esn ,
                                     i_min => c.min);

            IF sub.status NOT LIKE '%SUCCESS%' THEN
                -- Delete SPR by ESN
                rms := subscriber_type ( i_esn => i_esn );
                rs  := rms.remove;

                -- Delete SPR by MIN
                rms := subscriber_type ( i_esn => NULL,
                                         i_min => c.min );
                rs  := rms.remove;
            END IF;

            -- call add subscriber member procedure
            s := sub.ins;

            IF s.status NOT LIKE '%SUCCESS%' THEN

                --instert failures in spr_reprocess table
                insert_reprocess_log ( i_esn                     => i_esn                 ,
                                       i_min                     => NULL                  ,
                                       i_ig_transaction_id       => i_transaction_id      ,
                                       i_ig_order_type           => igt.order_type        ,
                                       i_response                => 'SUBSCRIBER_TYPE.STATUS = ' || s.status,
                                       i_program_name            => i_src_program_name    ,
                                       i_action                  => 'CREATING SUBSCRIBER FOR E WHILE EXECUTING SUBSCRIBER_TYPE.INS');


                o_error_code := 1;
                o_error_msg  := 'ERROR SAVING SUBSCRIBER ROW: ' || s.status;
                --
                RETURN;
            END IF;

            -- Generate a UP for new ESN
            pcrf := pcrf_transaction_type ( i_esn              => i_esn,
                                            i_min              => s.pcrf_min,
                                            i_order_type       => i.order_type_code,
                                            i_zipcode          => s.zipcode,
                                            i_sourcesystem     => ctt.sourcesystem,
                                            i_pcrf_status_code => 'Q' );

            -- Call insert pcrf transaction member procedure
            p := pcrf.ins;

            --
            o_error_code := 0;
            o_error_msg  := 'SUCCESS';
            -- Exit the current iteration (should exit the loop)
            RETURN;

          END IF; -- IF ct.reference_esn IS NULL THEN

          -- get the reference esn from the member table
          mt := group_member_type ( i_esn => c_old_esn );

          -- only perform the following actions for non shared group brands
          IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR  -- non shared group brands
             mt.member_objid IS NOT NULL                          -- members that have not been upgraded to new esn
          THEN

            -- reset customer type
            c := customer_type ();

            -- call customer type to retrieve all attributes related to an esn
            c := cst.retrieve ( i_esn => c_new_esn );

            IF c.site_part_status <> 'Active' then
                --instert failures in spr_reprocess table
              insert_reprocess_log ( i_esn                     => c_new_esn             ,
                                     i_min                     => NULL                  ,
                                     i_ig_transaction_id       => i_transaction_id      ,
                                     i_ig_order_type           => igt.order_type        ,
                                     i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn,
                                     i_program_name            => i_src_program_name    ,
                                     i_action                  => 'CHECKING SITE PART STATUS TO PROCESS E');
               --
              o_error_code := 1;
              o_error_msg  := 'SITE PART IS NOT ACTIVE TO PROCESS E';
              --
              RETURN;
            END IF;

            -- reset group member type
            mt := group_member_type ();
            m  := group_member_type ();

            -- reset group type
            g := group_type ();

            -- expire the new account group member by esn
            m := mt.expire ( i_esn => c_new_esn );

            -- expire the new account group by group objid (based on the old esn)
            g := gt.expire ( i_group_objid => m.group_objid );

            -- reset group member type
            m := group_member_type ();

            -- reset group type
            g := group_type ();

            -- expire the new account group member by esn
            m := mt.expire ( i_esn => c_old_esn );

            -- expire the new account group by group objid (based on the new esn)
            g := gt.expire ( i_group_objid => m.group_objid  );

            -- reset group type
            gt := group_type();

            -- instantiate initial values for insertion
            gt := group_type ( i_web_user_objid    => c.web_user_objid    ,
                               i_service_plan_id   => g.service_plan_id   ,  -- carry over the service_plan_id
                               i_status            => 'ACTIVE'            ,
                               i_bus_org_objid     => c.bus_org_objid     ,
                               i_account_group_uid => g.account_group_uid ); -- carry over the group UID

            -- call insert group type member function
            g := gt.ins;

            -- reset group member type
            mt := group_member_type ();

            -- instantiate initial values for insertion
            mt := group_member_type ( i_esn            => c_new_esn        ,
                                      i_group_objid    => g.group_objid    ,
                                      i_status         => 'ACTIVE'         ,
                                      i_subscriber_uid => m.subscriber_uid ); -- carry over the subscriber UID

            -- call insert member type function
            m := mt.ins;

            -- get the last redemption date from customer type
            c.last_redemption_date := cst.get_last_redemption_date ( i_esn => c_new_esn );

            -- if the redemption date of the new esn is greater than the case creation date (minus 5 minutes)
            IF c.last_redemption_date >= ( ct.creation_time - INTERVAL '5' MINUTE ) THEN
              -- use last redemption from new esn
              c.last_redemption_date := cst.get_last_redemption_date ( i_esn => c_new_esn );
            ELSE
              -- carry over last redemption date from reference esn (skip new esn from site part)
              c.last_redemption_date := cst.get_last_redemption_date ( i_esn         => c_old_esn ,
                                                                       i_exclude_esn => c_new_esn );
            END IF;

            -- close open replacement/awop cases for old esn
            set_compensation_case ( i_esn               => c_new_esn  ,
                                    i_transaction_id    => NULL       ,
                                    i_call_trans_objid  => NULL       ,
                                    i_old_esn           => c_old_esn );

            -- Transfer addons
            su_addons := sa.subscriber_type (i_esn => c_old_esn);

            -- to transfer the addons for the internal port in for non shared group plans from old ens to new esn
            IF su_addons.addons.COUNT > 0 and c.get_shared_group_flag ( i_esn => i_esn ) = 'N' then
               --
               transfer_addon_beneifts (i_accnt_grp_uid =>  g.account_group_uid,
                                        i_new_grp_id    =>  g.group_objid);
            END IF;

            -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
            l_return := su.process_upgrade ( i_old_esn              => c_old_esn              ,
                                             i_new_esn              => c_new_esn              ,
                                             i_last_redemption_date => c.last_redemption_date );

            IF l_return <> 'SUCCESS' THEN
              -- Log error in SPR logging table
              insert_spr_log ( i_esn                     => i_esn                 ,
                               i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                               i_ig_transaction_objid    => i_transaction_id      ,
                               i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                               i_action_type             => i_action_type         ,
                               i_reason                  => i_reason              ,
                               i_old_esn                 => c_old_esn             ,
                               i_new_esn                 => c_new_esn             ,
                               i_program_name            => i_src_program_name    ,
                               i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');

              --instert failures in spr_reprocess table
              insert_reprocess_log ( i_esn                     => i_esn                 ,
                                     i_min                     => NULL                  ,
                                     i_ig_transaction_id       => i_transaction_id      ,
                                     i_ig_order_type           => igt.order_type        ,
                                     i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                     i_program_name            => i_src_program_name    ,
                                     i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE FOR EXCAHNGE');
              --
              o_error_code := 1;
              o_error_msg  := 'ERROR PROCESSING UPGRADE: ' || l_return;
              --
              RETURN;

            END IF;

            -- instantiate pcrf values
            pcrf := pcrf_transaction_type ( i_esn              => c_new_esn,
                                            i_min              => c.min,
                                            i_order_type       => i.order_type_code,
                                            i_zipcode          => c.zipcode,
                                            i_sourcesystem     => i_sourcesystem,
                                            i_pcrf_status_code => 'Q' );

            -- insert a UP pcrf transaction
            p := pcrf.ins;

            su_addons := sa.subscriber_type (i_esn => c_new_esn);
            --
            IF su_addons.addons.COUNT > 0 and c.get_shared_group_flag ( i_esn => i_esn ) = 'N' then
               transfer_addon_beneifts (i_accnt_grp_uid =>  g.account_group_uid,
                                        i_new_grp_id    =>  g.group_objid);
            END IF;
            -- exit loop
            EXIT;

          --CR 47282:PCRF Upgrade Logic for shared plans(TW and SM).
          ELSIF c.get_shared_group_flag ( i_esn => i_esn ) = 'Y' and  -- shared group brands
                mt.member_objid IS NULL                               -- members that have been upgraded to new esn from old esn
          THEN

              mt := group_member_type ();
              mt := group_member_type ( i_esn => c_new_esn );         -- members that have been upgraded to new esn
              --
              IF  mt.member_objid IS NOT NULL THEN
                  -- reset customer type
                  c := customer_type ();

                  -- call customer type to retrieve all attributes related to an esn
                  c := cst.retrieve ( i_esn => c_new_esn );

                  -- get the last redemption date from customer type
                  c.last_redemption_date := cst.get_last_redemption_date ( i_esn => c_new_esn );

                  -- if the redemption date of the new esn is greater than the case creation date (minus 5 minutes)
                  IF c.last_redemption_date >= ( ct.creation_time - INTERVAL '5' MINUTE ) THEN
                     -- use last redemption from new esn
                     c.last_redemption_date := cst.get_last_redemption_date ( i_esn => c_new_esn );
                  ELSE
                     -- carry over last redemption date from reference esn (skip new esn from site part)
                     c.last_redemption_date := cst.get_last_redemption_date ( i_esn         => c_old_esn ,
                                                                              i_exclude_esn => c_new_esn );
                  END IF;

                  -- close open replacement/awop cases for old esn
                  set_compensation_case ( i_esn               => c_new_esn  ,
                                          i_transaction_id    => NULL       ,
                                          i_call_trans_objid  => NULL       ,
                                          i_old_esn           => c_old_esn );

                  -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
                  l_return := su.process_upgrade ( i_old_esn              => c_old_esn              ,
                                                   i_new_esn              => c_new_esn              ,
                                                   i_last_redemption_date => c.last_redemption_date );
                  -- instantiate pcrf values
                  pcrf := pcrf_transaction_type ( i_esn              => c_new_esn,
                                                  i_min              => c.min,
                                                  i_order_type       => i.order_type_code,
                                                  i_zipcode          => c.zipcode,
                                                  i_sourcesystem     => i_sourcesystem,
                                                  i_pcrf_status_code => 'Q' );

                  -- insert a UP pcrf transaction
                  p := pcrf.ins;

                  -- exit loop
                  EXIT;

              END IF;

          END IF; -- IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' ....

        END IF;
        -- end logic for "E" IG order types

        --
        IF i.ipi_flag = 'Y' THEN

          -- set the new esn from IG
          c_new_esn := i_esn;

          -- get the old esn if cross company

          ctp := case_type ();
          ct  := case_type ();

          -- call case type function to get the latest case data
          ct := ctp.get ( i_esn        => c_new_esn ,
                          i_case_title => '%CROSS%COMPANY%' );

          --
          c_old_esn := ct.reference_esn;

          -- If the upgrade is CROSS COMPANY
          IF c_old_esn IS NOT NULL THEN

            -- get the reference esn from the member table
            mt := group_member_type ( i_esn => c_old_esn );

            -- only perform the following actions for non shared group brands
            IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR  -- non shared group brands
               mt.member_objid IS NOT NULL                          -- members that have not been upgraded to new esn
            THEN

              -- call retrieve member function to get all the attributes related to an esn
              c := cst.retrieve ( i_esn => c_new_esn );

              IF c.site_part_status <> 'Active' then
                --instert failures in spr_reprocess table
                insert_reprocess_log ( i_esn                     => c_new_esn             ,
                                       i_min                     => NULL                  ,
                                       i_ig_transaction_id       => i_transaction_id      ,
                                       i_ig_order_type           => igt.order_type        ,
                                       i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn,
                                       i_program_name            => i_src_program_name    ,
                                       i_action                  => 'CHECKING SITE PART STATUS TO PROCESS IPI');
                 --
                o_error_code := 1;
                o_error_msg  := 'SITE PART IS NOT ACTIVE TO PROCESS IPI';
                --
               RETURN;
              END IF;

              -- reset group member type
              mt := group_member_type ();
              m  := group_member_type ();

              -- expire the old account group member by esn
              m := mt.expire ( i_esn => c_old_esn );

              -- expire the old account group by group objid (based on the old esn)
              g := gt.expire ( i_group_objid => m.group_objid );

              -- reset group member type
              m := group_member_type();

              -- reset group type
              g := group_type();

              -- expire the new account group member by esn
              m := mt.expire ( i_esn => c_new_esn );

              -- expire the new account group by group objid (based on the new esn)
              g := gt.expire ( i_group_objid => m.group_objid  );

              -- CREATE NEW MEMBER AND GROUP

              -- reset group type
              gt := group_type ();

              -- instantiate initial values for insertion
              gt := group_type ( i_web_user_objid    => c.web_user_objid     ,
                                 i_service_plan_id   => c.service_plan_objid ,  -- carry over the service_plan_id
                                 i_status            => 'ACTIVE'             ,
                                 i_bus_org_objid     => c.bus_org_objid      ,
                                 i_account_group_uid => NULL                 ); -- leave blank to assign a new group UID

              -- call insert group type member function
              g := gt.ins;

              -- reset group member type
              mt := group_member_type ();

              -- instantiate initial values for insertion
              mt := group_member_type ( i_esn            => c_new_esn     ,
                                        i_group_objid    => g.group_objid ,
                                        i_status         => 'ACTIVE'      ,
                                        i_subscriber_uid => NULL          ); -- leave blank to assign a new subscriber UID

              -- call insert member type function
              m := mt.ins;

              -- END CREATE NEW MEMBER AND GROUP

              -- close open replacement/awop cases for old esn
              set_compensation_case ( i_esn               => c_new_esn  ,
                                      i_transaction_id    => NULL       ,
                                      i_call_trans_objid  => NULL       ,
                                      i_old_esn           => c_old_esn );

              -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
              l_return := su.process_upgrade ( i_old_esn              => c_old_esn              ,
                                               i_new_esn              => c_new_esn              ,
                                               i_last_redemption_date => c.last_redemption_date ,
                                               i_pcrf_subscriber_id   => m.subscriber_uid       ,
                                               i_pcrf_group_id        => g.account_group_uid    );

              IF l_return <> 'SUCCESS' THEN
                -- Log error in SPR logging table
                insert_spr_log ( i_esn                     => i_esn                 ,
                                 i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                                 i_ig_transaction_objid    => i_transaction_id      ,
                                 i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                 i_action_type             => i_action_type         ,
                                 i_reason                  => i_reason              ,
                                 i_old_esn                 => c_old_esn             ,
                                 i_new_esn                 => c_new_esn             ,
                                 i_program_name            => i_src_program_name    ,
                                 i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');

                --instert failures in spr_reprocess table
                insert_reprocess_log ( i_esn                     => i_esn                 ,
                                       i_min                     => NULL                  ,
                                       i_ig_transaction_id       => i_transaction_id      ,
                                       i_ig_order_type           => igt.order_type        ,
                                       i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                       i_program_name            => i_src_program_name    ,
                                       i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE FOR IPI');

                o_error_code := 1;
                o_error_msg  := 'ERROR PROCESSING UPGRADE: ' || l_return;
                --
                RETURN;

              END IF;

              -- instantiate pcrf values
              pcrf := pcrf_transaction_type ( i_esn              => c_new_esn,
                                              i_min              => NULL,
                                              i_order_type       => i.order_type_code,
                                              i_zipcode          => c.zipcode,
                                              i_sourcesystem     => i_sourcesystem,
                                              i_pcrf_status_code => 'Q' );

              -- insert a UP pcrf transaction
              p := pcrf.ins;

              su_addons := sa.subscriber_type (i_esn => c_new_esn);
              --
              IF su_addons.addons.COUNT > 0 and c.get_shared_group_flag ( i_esn => i_esn ) = 'N' then
                 transfer_addon_beneifts (i_accnt_grp_uid =>  g.account_group_uid,
                                          i_new_grp_id    =>  g.group_objid);
              END IF;
              -- exit loop
              EXIT;

              --
            END IF; -- IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR

          END IF; -- If it's a cross company (port)

          -- continue logic for non-cross company (ports)

          -- reset case type
          ctp := case_type ();
          ct  := case_type ();

          -- call case type member function to get the latest case data
          ct := ctp.get ( i_esn        => c_new_esn ,
                          i_case_title => '%AUTO%INTERNAL%' );

          -- set the reference esn (old esn)
          c_old_esn := ct.reference_esn;

          -- Get the old esn from the case
          IF c_old_esn IS NULL THEN
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => i_esn                 ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'OLD ESN NOT FOUND IN TABLE_CASE TITLES (%AUTO%INTERNAL%): '|| '| ERROR: ' || SUBSTR(SQLERRM,1,100) ,
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_new_esn                 => c_new_esn             ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'FINDING OLD ESN IN PIR CASE WITH NEW ESN = ' || c_new_esn );

            --
            o_error_code := 1;
            o_error_msg  := 'ERROR SEARCHING FOR THE CASE FOR PIR: ' || SQLERRM;
            -- Exit the current iteration (should exit the loop)
            RETURN;
          END IF;


          -- get the reference esn from the member table
          mt := group_member_type ( i_esn => c_old_esn );

          -- only perform the following actions for non shared group brands
          IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR  -- non shared group brands
             mt.member_objid IS NOT NULL                          -- members that have not been upgraded to new esn
          THEN
            -- reset customer type
            c := customer_type ();

            -- call customer type to retrieve all attributes related to an esn
            c := cst.retrieve ( i_esn => c_new_esn );

            --
            IF c.site_part_status <> 'Active' then
                --instert failures in spr_reprocess table
                insert_reprocess_log ( i_esn                     => c_new_esn             ,
                                       i_min                     => NULL                  ,
                                       i_ig_transaction_id       => i_transaction_id      ,
                                       i_ig_order_type           => igt.order_type        ,
                                       i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn,
                                       i_program_name            => i_src_program_name    ,
                                       i_action                  => 'CHECKING SITE PART STATUS TO PROCESS IPI');
                 --
                o_error_code := 1;
                o_error_msg  := 'SITE PART IS NOT ACTIVE TO PROCESS IPI';
                --
                RETURN;
            END IF;

            -- reset group member type
            mt := group_member_type ();
            m := group_member_type ();

            -- reset group type
            g := group_type ();

            -- expire the new account group member by esn
            m := mt.expire ( i_esn => c_new_esn );

            -- expire the new account group by group objid (based on the old esn)
            g := gt.expire ( i_group_objid => m.group_objid );

            -- reset group member type
            m := group_member_type ();

            -- reset group type
            g := group_type ();

            -- expire the new account group member by esn
            m := mt.expire ( i_esn => c_old_esn );

            -- expire the new account group by group objid (based on the new esn)
            g := gt.expire ( i_group_objid => m.group_objid  );

            -- reset group type
            gt := group_type();

            -- instantiate initial values for insertion
            gt := group_type ( i_web_user_objid    => c.web_user_objid    ,
                               i_service_plan_id   => g.service_plan_id   ,  -- carry over the service_plan_id
                               i_status            => 'ACTIVE'            ,
                               i_bus_org_objid     => c.bus_org_objid     ,
                               i_account_group_uid => g.account_group_uid ); -- carry over the group UID

            -- call insert group type member function
            g := gt.ins;

            -- reset group member type
            mt := group_member_type ();

            -- instantiate initial values for insertion
            mt := group_member_type ( i_esn            => c_new_esn        ,
                                      i_group_objid    => g.group_objid    ,
                                      i_status         => 'ACTIVE'         ,
                                      i_subscriber_uid => m.subscriber_uid ); -- carry over the subscriber UID

            -- call insert member type function
            m := mt.ins;

            -- get the last redemption date from customer type
            c.last_redemption_date := cst.get_last_redemption_date ( i_esn => c_new_esn );

            -- if the redemption date of the new esn is greater than the case creation date (minus 5 minutes)
            IF c.last_redemption_date >= ( ct.creation_time - INTERVAL '5' MINUTE ) THEN
              -- use last redemption from new esn
              c.last_redemption_date := cst.get_last_redemption_date ( i_esn => c_new_esn );
            ELSE
              -- carry over last redemption date from reference esn (skip new esn from site part)
              c.last_redemption_date := cst.get_last_redemption_date ( i_esn         => c_old_esn ,
                                                                       i_exclude_esn => c_new_esn );
            END IF;

            -- close open replacement/awop cases for old esn
            set_compensation_case ( i_esn               => c_new_esn  ,
                                    i_transaction_id    => NULL       ,
                                    i_call_trans_objid  => NULL       ,
                                    i_old_esn           => c_old_esn );

            su_addons := sa.subscriber_type (i_esn => c_old_esn);
            --
            IF su_addons.addons.COUNT > 0 and c.get_shared_group_flag ( i_esn => i_esn ) = 'N' then
               transfer_addon_beneifts (i_accnt_grp_uid =>  g.account_group_uid,
                                        i_new_grp_id    =>  g.group_objid);
            END IF;

            -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
            l_return := su.process_upgrade ( i_old_esn              => c_old_esn              ,
                                             i_new_esn              => c_new_esn              ,
                                             i_last_redemption_date => c.last_redemption_date );

            IF l_return <> 'SUCCESS' THEN
              -- Log error in SPR logging table
              insert_spr_log ( i_esn                     => i_esn                 ,
                               i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                               i_ig_transaction_objid    => i_transaction_id      ,
                               i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                               i_action_type             => i_action_type         ,
                               i_reason                  => i_reason              ,
                               i_old_esn                 => c_old_esn             ,
                               i_new_esn                 => c_new_esn             ,
                               i_program_name            => i_src_program_name    ,
                               i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');

              --instert failures in spr_reprocess table
              insert_reprocess_log ( i_esn                     => i_esn                 ,
                                     i_min                     => NULL                  ,
                                     i_ig_transaction_id       => i_transaction_id      ,
                                     i_ig_order_type           => igt.order_type        ,
                                     i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                     i_program_name            => i_src_program_name    ,
                                     i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');
              --
              o_error_code := 1;
              o_error_msg  := 'ERROR PROCESSING UPGRADE: ' || l_return;
              --
              RETURN;

            END IF;

            -- instantiate pcrf values
            pcrf := pcrf_transaction_type ( i_esn              => c_new_esn,
                                            i_min              => c.min,
                                            i_order_type       => i.order_type_code,
                                            i_zipcode          => c.zipcode,
                                            i_sourcesystem     => i_sourcesystem,
                                            i_pcrf_status_code => 'Q' );

            -- insert a UP pcrf transaction
            p := pcrf.ins;

            -- exit loop
            EXIT;

            --
          END IF; -- IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR ....


        END IF; -- i.ipi_flag = 'Y'

        -- Manage PIRs from IGATE_IN3
        IF i.pir_flag = 'Y' THEN

          -- set the new esn from IG
          c_new_esn := i_esn;

          -- get the old esn if cross company

          ctp := case_type ();
          ct  := case_type ();

          -- call case type function to get the latest case data
          ct := ctp.get ( i_esn        => c_new_esn ,
                          i_case_title => '%CROSS%COMPANY%' );

          --
          c_old_esn := ct.reference_esn;

          -- If the upgrade is CROSS COMPANY
          IF c_old_esn IS NOT NULL THEN

            -- get the reference esn from the member table
            mt := group_member_type ( i_esn => c_old_esn );

            -- only perform the following actions for non shared group brands
            IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR  -- non shared group brands
               mt.member_objid IS NOT NULL                          -- members that have not been upgraded to new esn
            THEN

              -- call retrieve member function to get all the attributes related to an esn
              c := cst.retrieve ( i_esn => c_new_esn );

              IF c.site_part_status <> 'Active' then
                 --instert failures in spr_reprocess table
                 insert_reprocess_log ( i_esn                     => c_new_esn             ,
                                        i_min                     => NULL                  ,
                                        i_ig_transaction_id       => i_transaction_id      ,
                                        i_ig_order_type           => igt.order_type        ,
                                        i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn,
                                        i_program_name            => i_src_program_name    ,
                                        i_action                  => 'CHECKING SITE PART STATUS TO PROCESS PIR');
                --
                o_error_code := 1;
                o_error_msg  := 'SITE PART IS NOT ACTIVE TO PROCESS PIR';
                --
                RETURN;
              END IF;
              -- reset group member type
              mt := group_member_type ();
              m  := group_member_type ();

              -- expire the old account group member by esn
              m := mt.expire ( i_esn => c_old_esn );

              -- expire the old account group by group objid (based on the old esn)
              g := gt.expire ( i_group_objid => m.group_objid );

              -- reset group member type
              m := group_member_type();

              -- reset group type
              g := group_type();

              -- expire the new account group member by esn
              m := mt.expire ( i_esn => c_new_esn );

              -- expire the new account group by group objid (based on the new esn)
              g := gt.expire ( i_group_objid => m.group_objid  );

              -- CREATE NEW MEMBER AND GROUP

              -- reset group type
              gt := group_type ();

              -- instantiate initial values for insertion
              gt := group_type ( i_web_user_objid    => c.web_user_objid     ,
                                 i_service_plan_id   => c.service_plan_objid ,  -- carry over the service_plan_id
                                 i_status            => 'ACTIVE'             ,
                                 i_bus_org_objid     => c.bus_org_objid      ,
                                 i_account_group_uid => NULL                 ); -- leave blank to assign a new group UID

              -- call insert group type member function
              g := gt.ins;

              -- reset group member type
              mt := group_member_type ();

              -- instantiate initial values for insertion
              mt := group_member_type ( i_esn            => c_new_esn     ,
                                        i_group_objid    => g.group_objid ,
                                        i_status         => 'ACTIVE'      ,
                                        i_subscriber_uid => NULL          ); -- leave blank to assign a new subscriber UID

              -- call insert member type function
              m := mt.ins;

              -- END CREATE NEW MEMBER AND GROUP

              -- close open replacement/awop cases for old esn
              set_compensation_case ( i_esn               => c_new_esn  ,
                                      i_transaction_id    => NULL       ,
                                      i_call_trans_objid  => NULL       ,
                                      i_old_esn           => c_old_esn );

              -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
              l_return := su.process_upgrade ( i_old_esn              => c_old_esn              ,
                                               i_new_esn              => c_new_esn              ,
                                               i_last_redemption_date => c.last_redemption_date ,
                                               i_pcrf_subscriber_id   => m.subscriber_uid       ,
                                               i_pcrf_group_id        => g.account_group_uid    );

              IF l_return <> 'SUCCESS' THEN
                -- Log error in SPR logging table
                insert_spr_log ( i_esn                     => i_esn                 ,
                                 i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                                 i_ig_transaction_objid    => i_transaction_id      ,
                                 i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                 i_action_type             => i_action_type         ,
                                 i_reason                  => i_reason              ,
                                 i_old_esn                 => c_old_esn             ,
                                 i_new_esn                 => c_new_esn             ,
                                 i_program_name            => i_src_program_name    ,
                                 i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');

                --instert failures in spr_reprocess table
                insert_reprocess_log ( i_esn                     => i_esn                 ,
                                       i_min                     => NULL                  ,
                                       i_ig_transaction_id       => i_transaction_id      ,
                                       i_ig_order_type           => igt.order_type        ,
                                       i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                       i_program_name            => i_src_program_name    ,
                                       i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');
                o_error_code := 1;
                o_error_msg  := 'ERROR PROCESSING UPGRADE: ' || l_return;
                --
                RETURN;

              END IF;

              -- instantiate pcrf values
              pcrf := pcrf_transaction_type ( i_esn              => c_new_esn,
                                              i_min              => NULL,
                                              i_order_type       => i.order_type_code,
                                              i_zipcode          => c.zipcode,
                                              i_sourcesystem     => i_sourcesystem,
                                              i_pcrf_status_code => 'Q' );

              -- insert a UP pcrf transaction
              p := pcrf.ins;

              su_addons := sa.subscriber_type (i_esn => c_new_esn);
              --
              IF su_addons.addons.COUNT > 0 and c.get_shared_group_flag ( i_esn => i_esn ) = 'N' then
                 transfer_addon_beneifts (i_accnt_grp_uid =>  g.account_group_uid,
                                          i_new_grp_id    =>  g.group_objid);
              END IF;

              -- exit loop
              EXIT;

              --
            END IF; --

          END IF; -- If it's a cross company (port)

          -- continue logic for non-cross company (ports)

          -- reset case type
          ctp := case_type ();
          ct  := case_type ();

          -- call case type member function to get the latest case data
          ct := ctp.get ( i_esn        => c_new_esn ,
                          i_case_title => '%AUTO%INTERNAL%' );

          -- set the reference esn (old esn)
          c_old_esn := ct.reference_esn;

          -- Get the old esn from the case
          IF c_old_esn IS NULL THEN
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => i_esn                 ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'OLD ESN NOT FOUND IN TABLE_CASE TITLES (%AUTO%INTERNAL%): '|| '| ERROR: ' || SUBSTR(SQLERRM,1,100) ,
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_new_esn                 => c_new_esn             ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'FINDING OLD ESN IN PIR CASE WITH NEW ESN = ' || c_new_esn );
            --
            o_error_code := 1;
            o_error_msg  := 'ERROR SEARCHING FOR THE CASE FOR PIR: ' || SQLERRM;
            -- Exit the current iteration (should exit the loop)
            RETURN;
          END IF;

          -- get the reference esn from the member table
          mt := group_member_type ( i_esn => c_old_esn );

          -- only perform the following actions for non shared group brands
          IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' OR  -- non shared group brands
             mt.member_objid IS NOT NULL                          -- members that have not been upgraded to new esn
          THEN

            -- reset customer type
            c := customer_type ();

            -- call retrieve member function to get all the attributes related to an esn
            c := cst.retrieve ( i_esn => c_new_esn );

            IF c.site_part_status <> 'Active' then
                --instert failures in spr_reprocess table
                insert_reprocess_log ( i_esn                     => c_new_esn             ,
                                       i_min                     => NULL                  ,
                                       i_ig_transaction_id       => i_transaction_id      ,
                                       i_ig_order_type           => igt.order_type        ,
                                       i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn,
                                       i_program_name            => i_src_program_name    ,
                                       i_action                  => 'CHECKING SITE PART STATUS TO PROCESS PIR');
                --
                o_error_code := 1;
                o_error_msg  := 'SITE PART IS NOT ACTIVE TO PROCESS PIR';
                --
                RETURN;
            END IF;

            -- reset group member type
            mt := group_member_type ();
            m  := group_member_type ();

            -- reset group type
            g := group_type ();

            -- expire the new account group member by esn
            m := mt.expire ( i_esn => c_new_esn );

            -- expire the new account group by group objid (based on the old esn)
            g := gt.expire ( i_group_objid => m.group_objid );

            -- reset group member type
            m := group_member_type ();

            -- reset group type
            g := group_type ();

            -- expire the new account group member by esn
            m := mt.expire ( i_esn => c_old_esn );

            -- expire the new account group by group objid (based on the new esn)
            g := gt.expire ( i_group_objid => m.group_objid  );

            -- call customer type to retrieve all attributes related to an esn
            c := cst.retrieve ( i_esn => c_new_esn );

            -- reset group type
            gt := group_type();

            -- instantiate initial values for insertion
            gt := group_type ( i_web_user_objid    => c.web_user_objid    ,
                               i_service_plan_id   => g.service_plan_id   ,  -- carry over the service_plan_id
                               i_status            => 'ACTIVE'            ,
                               i_bus_org_objid     => c.bus_org_objid     ,
                               i_account_group_uid => g.account_group_uid ); -- carry over the group UID

            -- call insert group type member function
            g := gt.ins;

            -- reset group member type
            mt := group_member_type ();

            -- instantiate initial values for insertion
            mt := group_member_type ( i_esn            => c_new_esn        ,
                                      i_group_objid    => g.group_objid    ,
                                      i_status         => 'ACTIVE'         ,
                                      i_subscriber_uid => m.subscriber_uid ); -- carry over the subscriber UID

            -- call insert member type function
            m := mt.ins;

            -- get the last redemption date from customer type
            c.last_redemption_date := cst.get_last_redemption_date ( i_esn => c_new_esn );

            -- if the redemption date of the new esn is greater than the case creation date (minus 5 minutes)
            IF c.last_redemption_date >= ( ct.creation_time - INTERVAL '5' MINUTE ) THEN
              -- use last redemption from new esn
              c.last_redemption_date := cst.get_last_redemption_date ( i_esn => c_new_esn );
            ELSE
              -- carry over last redemption date from reference esn (skip new esn from site part)
              c.last_redemption_date := cst.get_last_redemption_date ( i_esn         => c_old_esn ,
                                                                       i_exclude_esn => c_new_esn );
            END IF;

            -- close open replacement/awop cases for old esn
            set_compensation_case ( i_esn               => c_new_esn  ,
                                    i_transaction_id    => NULL       ,
                                    i_call_trans_objid  => NULL       ,
                                    i_old_esn           => c_old_esn );

            su_addons := sa.subscriber_type (i_esn => c_old_esn);

            -- to transfer the addons for the internal port in for non shared group plans from old ens to new esn
            IF su_addons.addons.COUNT > 0 and c.get_shared_group_flag ( i_esn => i_esn ) = 'N' then
               --
               transfer_addon_beneifts (i_accnt_grp_uid =>  g.account_group_uid,
                                        i_new_grp_id    =>  g.group_objid);
            END IF;

            -- Perform update to replace ESN by objid and capture output in s1 (subscriber_type)
            l_return := su.process_upgrade ( i_old_esn              => c_old_esn              ,
                                             i_new_esn              => c_new_esn              ,
                                             i_last_redemption_date => c.last_redemption_date );

            IF l_return <> 'SUCCESS' THEN
              -- Log error in SPR logging table
              insert_spr_log ( i_esn                     => i_esn                 ,
                               i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                               i_ig_transaction_objid    => i_transaction_id      ,
                               i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                               i_action_type             => i_action_type         ,
                               i_reason                  => i_reason              ,
                               i_old_esn                 => c_old_esn             ,
                               i_new_esn                 => c_new_esn             ,
                               i_program_name            => i_src_program_name    ,
                               i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE');

              --instert failures in spr_reprocess table
              insert_reprocess_log ( i_esn                     => i_esn                 ,
                                     i_min                     => NULL                  ,
                                     i_ig_transaction_id       => i_transaction_id      ,
                                     i_ig_order_type           => igt.order_type        ,
                                     i_response                => 'UPGRADING FROM OLD ESN = ' || c_old_esn || ' TO NEW ESN = '|| c_new_esn ||'| ERROR: ' || l_return,
                                     i_program_name            => i_src_program_name    ,
                                     i_action                  => 'CALLING SUBSCRIBER_TYPE.PROCESS_UPGRADE FOR PIR');

              --
              o_error_code := 1;
              o_error_msg  := 'ERROR PROCESSING UPGRADE: ' || l_return;
              --
              RETURN;

            END IF;

            -- instantiate pcrf values
            pcrf := pcrf_transaction_type ( i_esn              => c_new_esn,
                                            i_min              => c.min,
                                            i_order_type       => i.order_type_code,
                                            i_zipcode          => c.zipcode,
                                            i_sourcesystem     => i_sourcesystem,
                                            i_pcrf_status_code => 'Q' );

            -- insert a UP pcrf transaction
            p := pcrf.ins;

            su_addons := sa.subscriber_type (i_esn => c_new_esn);
            --
            IF su_addons.addons.COUNT > 0 and c.get_shared_group_flag ( i_esn => i_esn ) = 'N' then
               transfer_addon_beneifts (i_accnt_grp_uid =>  g.account_group_uid,
                                        i_new_grp_id    =>  g.group_objid);
            END IF;

            -- exit loop
            EXIT;

            --
          END IF; -- IF c.get_shared_group_flag ( i_esn => i_esn ) = 'N' ....

        END IF; -- IF i.pir_flag = 'Y' THEN

        -- manage EPIR from igate_in3
        IF i.epir_flag = 'Y' THEN

          -- reset customer type variables
          c   := customer_type();
          cst := customer_type();

          -- get the customer data
          c := cst.retrieve ( i_esn => i_esn );

          --
          sub := subscriber_type ( i_esn => c.esn );
          -- remove existing entries from the spr for esn and min
          s := sub.remove;

          sub := subscriber_type ( i_esn => NULL ,
                                   i_min => c.min );
          -- remove existing entries from the spr for esn and min
          s := sub.remove;

          -- reset group member type
          m := group_member_type ();

          -- reset group type
          g := group_type ();

          -- reset customer type
          c := customer_type ();

          -- expire the account group member by esn
          m := mt.expire ( i_esn => c.esn );

          -- expire the account group by group objid (based on the esn)
          g := gt.expire ( i_group_objid => m.group_objid );

          -- reset group member type
          m := group_member_type ();

          -- reset group type
          g := group_type ();

          -- instantiate initial values for insertion
          gt := group_type ( i_web_user_objid    => c.web_user_objid     ,
                             i_service_plan_id   => c.service_plan_objid ,  -- use service_plan_id from esn
                             i_status            => 'ACTIVE'             ,
                             i_bus_org_objid     => c.bus_org_objid      ,
                             i_account_group_uid => NULL                 ); -- generate a new group UID

          -- call insert group type member function
          g := gt.ins;

          -- reset group member type
          mt := group_member_type ();

          -- instantiate initial values for insertion
          mt := group_member_type ( i_esn            => c.esn         ,
                                    i_group_objid    => g.group_objid ,
                                    i_status         => 'ACTIVE'      ,
                                    i_subscriber_uid => NULL          ); -- generate a new subscriber UID

          -- call insert member type function
          m := mt.ins;

          -- reset type
          sub := subscriber_type();

          -- instantiate esn
          sub := subscriber_type ( i_esn => c.esn );

          -- get subscriber data (ignore group and member creation when shared group flag is turned on)
          s := sub.retrieve ( i_ignore_tw_logic_flag => 'Y' );

          -- raw insert into subscriber table
          s.status := s.save(s);

          -- insert addons (offers)
          IF NOT detail.ins ( i_esn    => sub.pcrf_esn,
                              o_result => detail.status ) THEN
            NULL;
          END IF;

          IF s.status NOT LIKE '%SUCCESS%' THEN
            o_error_code := 11;
            o_error_msg  := s.status;
            -- Log error in SPR logging table
            insert_spr_log ( i_esn                     => i_esn ,
                             i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                             i_ig_transaction_objid    => i_transaction_id      ,
                             i_response                => 'INSERT INTO SPR FOR EPIR = ' || i_esn || s.status,
                             i_action_type             => i_action_type         ,
                             i_reason                  => i_reason              ,
                             i_program_name            => i_src_program_name    ,
                             i_action                  => 'INSERT INTO SPR FOR EPIR');
            --
            RETURN;
          ELSE
            o_error_code := 0;
            o_error_msg  := s.status;
          END IF;

          -- generate a "UP" pcrf
          pcrf := pcrf_transaction_type ( i_esn              => c.esn,
                                          i_min              => c.min,
                                          i_order_type       => i.order_type_code,
                                          i_zipcode          => c.zipcode,
                                          i_sourcesystem     => i_sourcesystem,
                                          i_pcrf_status_code => 'Q' );

          -- Call insert pcrf transaction member procedure
          p := pcrf.ins;

          -- exit loop
          EXIT;

        END IF;

      END IF; -- i.get_case_flag = 'Y'

      -- reset customer type variables
      c   := customer_type();
      cst := customer_type();

      -- get min info
      c := cst.retrieve ( i_esn => c_new_esn );

      -- Start logic of Syncing the subscriber table
      IF i.spr_applicable_flag = 'Y' THEN

        sub := subscriber_type (i_esn => c_new_esn,
                                i_min => c.min);

         -- check if spr exists already with esn and min combination, if not remove
        IF sub.status NOT LIKE '%SUCCESS%' THEN
          -- Delete SPR by ESN
          rms := subscriber_type ( i_esn => c_new_esn );
          rs  := rms.remove;

          -- Delete SPR by MIN
          rms := subscriber_type ( i_esn => NULL,
                                   i_min => c.min );
          rs  := rms.remove;
        END IF;

        sub := subscriber_type ( i_esn => i_esn);

		  s := subscriber_type();
        --
	 -- CR57251, NT10 50 percent more data on $35/$40 plan + ILD

		IF i.epir_flag = 'N' THEN
				IF 	c.service_plan_objid IS NULL THEN
					r_service_plan_rec := sa.service_plan.get_service_plan_by_esn(c.esn);

				-- get the service plan from part_inst
					IF r_service_plan_rec.objid IS NULL THEN
						BEGIN
								SELECT  MV.SP_OBJID INTO r_service_plan_rec.objid
								FROM sa.TABLE_PART_INST PI, sa.TABLE_MOD_LEVEL ML, sa.TABLE_PART_NUM PN, sa.TABLE_BUS_ORG BO,sa.TABLE_PART_INST RED,sa.TABLE_PART_CLASS PC,sa.ADFCRM_SERV_PLAN_CLASS_MATVIEW MV
								WHERE RED.X_DOMAIN = 'REDEMPTION CARDS'
								AND RED.N_PART_INST2PART_MOD = ML.OBJID
								AND ML.PART_INFO2PART_NUM = PN.OBJID
								AND PN.PART_NUM2BUS_ORG=BO.OBJID
								AND PN.PART_NUM2PART_CLASS = PC.OBJID
								AND MV.PART_CLASS_NAME = PC.NAME
								AND RED.PART_TO_ESN2PART_INST = PI.OBJID
								AND PI.PART_SERIAL_NO = c.esn
								AND ROWNUM = 1;
						EXCEPTION
							WHEN OTHERS THEN
								NULL;
						END;
					END IF;
				-- get the service plan from table_X_red_card
					IF r_service_plan_rec.objid IS NULL THEN
						BEGIN
							SELECT MV.SP_OBJID INTO r_service_plan_rec.objid
							FROM   sa.TABLE_X_RED_CARD RC ,
							sa.TABLE_X_CALL_TRANS CT,
								sa.TABLE_MOD_LEVEL ML ,
								sa.TABLE_PART_NUM PN,
								sa.ADFCRM_SERV_PLAN_CLASS_MATVIEW MV
								WHERE CT.OBJID               =  RC.RED_CARD2CALL_TRANS
								AND    PN.DOMAIN             = 'REDEMPTION CARDS'
								AND    ML.OBJID              = RC.X_RED_CARD2PART_MOD
								AND    ML.PART_INFO2PART_NUM = PN.OBJID
								AND   PN.PART_NUM2PART_CLASS = MV.PART_CLASS_OBJID
							  AND   CT.X_SERVICE_ID        = c.esn
							  AND ROWNUM = 1;
						EXCEPTION
							WHEN OTHERS THEN
								NULL;
						END;
					END IF;

			END IF;

           s.pcrf_cos := sa.util_pkg.net10_data_promo (i_esn      => c.esn,
                                                       i_min      => c.min,
                                                       i_sp_objid => NVL(c.service_plan_objid,r_service_plan_rec.objid));

           sub.pcrf_cos := nvl (s.pcrf_cos, sub.pcrf_cos);

        END IF;
		-- End CR57251
	--
	-- Call add subscriber member procedure
        s := sub.ins;
        --
        IF s.status NOT LIKE '%SUCCESS%' THEN
          -- Log error in SPR logging table
          insert_spr_log ( i_esn                     => i_esn                 ,
                           i_program_purch_hdr_objid => i_prgm_purc_hdr_objid ,
                           i_ig_transaction_objid    => i_transaction_id      ,
                           i_response                => 'SUBSCRIBER_TYPE.STATUS = ' || s.status,
                           i_action_type             => i_action_type         ,
                           i_reason                  => i_reason              ,
                           i_program_name            => i_src_program_name    ,
                           i_action                  => 'CREATING SUBSCRIBER EXECUTING SUBSCRIBER_TYPE.INS');

          --instert failures in spr_reprocess table
          insert_reprocess_log ( i_esn                     => i_esn                 ,
                                 i_min                     => s.pcrf_min            ,
                                 i_ig_transaction_id       => i_transaction_id      ,
                                 i_ig_order_type           => igt.order_type        ,
                                 i_response                => 'SUBSCRIBER_TYPE.STATUS = ' || s.status,
                                 i_program_name            => i_src_program_name    ,
                                 i_action                  => 'CREATING SUBSCRIBER EXECUTING SUBSCRIBER_TYPE.INS');


          o_error_code := 1;
          o_error_msg  := 'ERROR SAVING SUBSCRIBER ROW: ' || s.status;
          --
          RETURN;
        ELSE
          o_error_code := 0;
          o_error_msg := s.status;
        END IF;
      END IF;

      IF i.pcr_applicable_flag = 'Y' THEN
        --
        s1 := subscriber_type ( i_esn => i_esn,
                                i_min => c.min);
        s := subscriber_type();
        --
        IF NOT s1.exist then
          -- Call add subscriber member procedure
          -- Delete SPR by ESN
          rms := subscriber_type ( i_esn => c_new_esn );
          rs  := rms.remove;

          -- Delete SPR by MIN
          rms := subscriber_type ( i_esn => NULL,
                                   i_min => c.min );
          rs  := rms.remove;

          --
          s := s1.ins;

          IF s.status NOT LIKE '%SUCCESS%' THEN
            --
            --instert failures in spr_reprocess table
            insert_reprocess_log ( i_esn                     => i_esn                 ,
                                   i_min                     => s.pcrf_min            ,
                                   i_ig_transaction_id       => i_transaction_id      ,
                                   i_ig_order_type           => igt.order_type        ,
                                   i_response                => 'SUBSCRIBER_TYPE.STATUS = ' || s.status,
                                   i_program_name            => i_src_program_name    ,
                                   i_action                  => 'CREATING SUBSCRIBER FOR PCRF SUBSCRIBER_TYPE.INS');
            RETURN;
          END IF;
        END IF;

        -- Instantiate pcrf transaction table in constructor
        pcrf := pcrf_transaction_type ( i_esn              => s1.pcrf_esn,
                                        i_min              => NULL,
                                        i_order_type       => i.order_type_code,
                                        i_zipcode          => s.zipcode,
                                        i_sourcesystem     => NVL(i_sourcesystem,ctt.sourcesystem),
                                        i_pcrf_status_code => 'Q');

        -- Call insert pcrf transaction member procedure
        p := pcrf.ins;

        IF p.status LIKE '%SUCCESS' THEN
          o_error_code := 0;
          o_error_msg  := p.status;
        END IF;
      END IF;
      --
      set_winback_promo     (i_esn  => i_esn)  ;
      -- Just process one configuration row per transaction
      EXIT;

    END LOOP; -- End Loop through the cursor c_get_ig_config

  END IF;


EXCEPTION
   WHEN OTHERS THEN
    o_error_code := 99;
    o_error_msg := 'Updating PCRF Subscriber:  '||substr(sqlerrm,1,500);
    util_pkg.insert_error_tab ( i_action       => 'exception block',
                                i_key          => NVL(i_prgm_purc_hdr_objid,i_esn),
                                i_program_name => i_src_program_name,
                                i_error_text   => 'sqlerrm : '|| substr(sqlerrm,1,500) );

END update_pcrf_subscriber; -- End update_subscriber
/