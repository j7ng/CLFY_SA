CREATE OR REPLACE PACKAGE BODY sa.REWARD_POINTS_PKG
AS
  /*
  12-NOV-2014
  CR31431 - NET10 / SIMPLE MOBILE UPGRADE PLANS PROJECT
  Vkashmire
  X_POINTS_ACTION
  ADD = added in effect of Activation / ReActivation / Redemption
  DEDUCT = subtracted by TAS agent
  CONSUMED = subtracted in effect of getting money for points
  REFUND = points subtracted in case customer does the refund or return the CONSUMED points
  ESNUPGRADE = just indicates when the ESN was upgraded. this will have 0 points
  */
  lc_point_category_reward CONSTANT VARCHAR2(50) := 'REWARD_POINTS';
  lv_job_insert_rec_counter pls_integer;
  lv_job_update_rec_counter pls_integer;
  --cursor cur_call_trans: fetches data from specific date till today for specific MIN or all MIN's
  --fetch un-processed records with action type 1 / 3 / 6
  --@TW 5/3 added 401 for queued cards, 2 for DEACTIVATIONS, 20 for PORT OUTS?
  --unprocessed means record not present in table_x_point_trans
  CURSOR cur_call_trans ( in_min IN VARCHAR2 DEFAULT NULL, in_trans_date IN DATE)
  IS
    SELECT
      /*+ ORDERED */
      ct.objid,
      ct.call_trans2site_part,
      ct.x_min,
      ct.x_service_id AS x_esn,
      ct.x_action_type,
      ct.x_transact_date,
      ct.x_result,
      ct.x_reason
    FROM table_site_part sp,
      table_x_call_trans ct
    WHERE 1                     = 1
    AND sp.x_min                = in_min
    AND ct.call_trans2site_part = sp.objid
      --and ( ct.x_min = in_min or in_min is null )
    AND ( ct.x_transact_date   >= in_trans_date-5)                                  --- check for last 5 days. @TW some procs also subtract 5 days before calling using this cursor; need to remove those
    AND ( ct.x_action_type                    IN ('1', '3', '6', '401', '2', '20') ) --@TW added 401 for queued cards, 2 for DEACTIVATIONS, 20 for PORT OUTS?
    AND ( ct.x_result           = 'Completed' )
    AND ( NVL(ct.x_reason,'~') <> 'Queue_Card_Delivery' ) --cr32367 - ignore queue card delivery redemptions
    AND ( ct.x_min NOT LIKE 'T%')                         --do not consider temporary MINs
    AND NOT EXISTS
      (
      --check points are not already generated in table_x_point_trans
      SELECT 1
      FROM table_x_point_trans PT
      WHERE pt.point_trans2ref_table_objid = ct.objid
      AND pt.ref_table_name                = 'TABLE_X_CALL_TRANS'
      )
  AND NOT EXISTS
    (SELECT 1
    FROM table_x_call_trans ct2,
      table_x_red_card rc
    WHERE ct.objid        = rc.RED_CARD2CALL_TRANS
    AND ct.x_action_type  = '6'
    AND ct.X_SERVICE_ID   = ct2.X_SERVICE_ID
    AND ct2.x_action_type = '401'
    AND ct2.x_reason      = rc.x_red_code
    )
  ORDER BY ct.x_transact_date,
    ct.objid ;
  --cursor fetches specific min/esn details by checking if its active or not
  CURSOR cur_esn_min_dtl(in_key IN VARCHAR2, in_value IN VARCHAR2)
  IS
    SELECT pn.part_num2bus_org AS bus_org_objid,
      tsp.objid                AS site_part_objid,
      tsp.x_service_id         AS x_esn,
      tsp.x_min                AS x_min,
      spsp.x_service_plan_id   AS service_plan_objid
    FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn,
      table_site_part tsp,
      x_service_plan_site_part spsp
    WHERE 1                     =1
    AND pi.part_serial_no       = tsp.x_service_id
    AND pi.x_domain             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND tsp.part_status
      || '' = 'Active'
    AND tsp.x_min NOT LIKE 'T%'
    AND tsp.objid        = spsp.TABLE_SITE_PART_ID
    AND ( (in_key        = 'ESN'
    AND tsp.x_service_id = in_value )
    OR (in_key           = 'MIN'
    AND tsp.x_min        = in_value ) ) ;
  /*vs:05/13/2015: commenting this out to use the old cursor
  cursor cur_esn_min_dtl(in_key in varchar2, in_value in varchar2)
  is
  select bus_org_objid, site_part_objid, x_esn, x_min, service_plan_objid
  from (
  select
  pn.part_num2bus_org as bus_org_objid,
  tsp.objid as site_part_objid,
  tsp.x_service_id as x_esn,
  tsp.x_min as x_min,
  spsp.x_service_plan_id as service_plan_objid,
  row_number() over (partition by tsp.x_service_id order by tsp.update_stamp desc) esn_order,
  row_number() over (partition by tsp.x_min order by tsp.update_stamp desc) min_order
  from
  table_part_inst pi,
  table_mod_level ml,
  table_part_num pn,
  table_site_part tsp,
  x_service_plan_site_part spsp
  where 1=1
  and pi.part_serial_no = tsp.x_service_id
  and pi.x_domain = 'PHONES'
  and pi.n_part_inst2part_mod = ml.objid
  and ml.part_info2part_num = pn.objid
  and tsp.x_min not like 'T%'
  and tsp.objid = spsp.table_site_part_id
  and (
  (in_key = 'ESN' and tsp.x_service_id = in_value )
  or (in_key = 'MIN' and tsp.x_min = in_value )
  )
  )
  where ((in_key = 'ESN' and esn_order = 1)or (in_key = 'MIN' and min_order = 1))
  ; */
  CURSOR cur_point_account (in_key IN VARCHAR2, in_value IN VARCHAR2, in_brand IN NUMBER)
  IS
    SELECT objid,
      x_min,
      x_esn,
      total_points,
      x_points_category,
      x_last_calc_date,
      account_status,
      account_status_reason,
      bus_org_objid,
      subscriber_uid --CR32367:VS:05/07/15
    FROM table_x_point_account
    WHERE 1               = 1
    AND ( in_key          = 'MIN'
    AND x_min             = in_value
    OR in_key             ='ESN'
    AND x_esn             = in_value )
    AND account_status    = 'ACTIVE'
    AND x_points_category = lc_point_category_reward
    AND bus_org_objid     = in_brand ;
  --retrieve the current brand of input esn
  CURSOR cur_esn_brand (in_esn IN VARCHAR2)
  IS
    SELECT pn.part_num2bus_org AS bus_org_objid
    FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn
    WHERE 1                     =1
    AND pi.part_serial_no       = in_esn
    AND pi.x_domain             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid;
  /* procedure not required any more ... 3/20/2015
  procedure p_get_money_for_points (
  in_points in number ,
  in_points_category in varchar2,
  --in_service_plan_objid in number,
  in_brand_objid in number,
  out_amount out number,
  out_err_code out integer,
  out_err_msg out varchar2
  )
  is
  begin
  select max(x_amount)
  into out_amount
  from table_x_tiers tt, mtm_tier_x_connections txc
  where ( tt.tier_type = in_points_category )
  and ( in_points between tt.tier_min_value and tt.tier_max_value )
  and ( sysdate between tt.start_date and tt.end_date )
  and tt.objid = txc.tier_id
  and txc.connected_table = 'TABLE_BUS_ORG'
  and txc.connected_table_objid = in_brand_objid
  ;
  out_err_code := 0;
  out_err_msg := 'SUCCESS';
  exception
  when others then
  out_err_code := -99;
  out_err_msg := 'p_get_money_for_points FAILURE..ERR=' || substr(sqlerrm,1,100);
  sa.ota_util_pkg.err_log (
  p_action => 'p_get_money_for_points',
  p_error_date => sysdate,
  p_key => null,
  p_program_name => 'p_get_money_for_points',
  p_error_text => 'in_brand_objid='||in_brand_objid
  ||', in_points_category='|| in_points_category
  ||', in_points='||in_points
  ||', ERR='|| substr(sqlerrm, 1, 4000));
  end p_get_money_for_points;
  */
  PROCEDURE p_point_benefit_exp_check(
      in_acct_objid      IN NUMBER ,
      in_recalculate_flg IN VARCHAR2,
      out_err_code OUT INTEGER,
      out_err_msg OUT VARCHAR2)
  AS
    lv_expiry_date    DATE ;
    lv_total_pts      NUMBER;
    lv_sub_id         VARCHAR2(40);
    lv_esn            VARCHAR2(30);
    lv_min            VARCHAR2(30);
    e_invalid_input   EXCEPTION;
    e_calculte_failed EXCEPTION;
    /**********************************************************************
    VS:051515:CR32367
    This Procedure is used to remove expiry date set on point account on
    reactivation event. It should remove any points that have expired as
    well. If an account is reactivated before its actual expiry the points
    shouldnt be removed and teh benefit expiry date should be removed
    ***********************************************************************/
  BEGIN
    IF in_acct_objid IS NOT NULL THEN
      SELECT pa.x_expiry_date ,
        pa.total_points,
        pa.subscriber_uid,
        pa.x_esn,
        pa.x_min
      INTO lv_expiry_date,
        lv_total_pts,
        lv_sub_id,
        lv_esn,
        lv_min
      FROM table_x_point_account pa
      WHERE pa.objid =in_acct_objid ;
      -- A reactivation attempt has called this proc
      -- check to see if expiry date is set if so nullify the expiry date
      IF lv_expiry_date IS NOT NULL THEN
        -- Expiry date needs to be removed if a customer returns
        UPDATE table_x_point_account tpa
        SET tpa.x_expiry_date  = NULL
        WHERE tpa.objid        =in_acct_objid
        AND tpa.x_expiry_date IS NOT NULL;
        /*if account has expired and then reactivation is tried then make sure to
        remove the points that are attached to the account and not associated to a benefit yet
        */
        IF lv_expiry_date < sysdate AND lv_total_pts > 0 THEN
          INSERT
          INTO table_x_point_trans
            (
              objid,
              x_trans_date,
              x_min,
              x_esn,
              x_points,
              x_points_category,
              x_points_action,
              points_action_reason,
              point_trans2ref_table_objid,
              ref_table_name,
              point_trans2service_plan,
              point_trans2point_account,
              point_trans2purchase_objid,
              purchase_table_name,
              point_trans2site_part,
              point_display_reason
            )
            VALUES
            (
              sa.seq_x_point_trans.nextval,
              sysdate,
              lv_min,
              lv_esn,
              -1*lv_total_pts,
              'REWARD_POINTS',
              'DEDUCT',
              'Expired Points removed on reactivation ACT_EXPDT:'
              ||lv_expiry_date,
              NULL,
              NULL,
              NULL,
              in_acct_objid,
              NULL,
              NULL,
              NULL,
              'Expired'
            );
          IF in_recalculate_flg = 'Y' THEN
            p_calculate_points (lv_min, out_err_code, out_err_msg);
          END IF;
          /*if account has not expired and reactivation is attempted then remove
          expiry date set on benefit*/
        ELSIF lv_expiry_date > sysdate THEN
          UPDATE table_x_benefits txb
          SET txb.X_EXPIRY_DATE           = NULL
          WHERE txb.X_BENEFIT_OWNER_VALUE = lv_sub_id
          AND TRUNC(txb.X_EXPIRY_DATE)    =TRUNC(lv_expiry_date) ;
        END IF; -- expired points check end if
      END IF;   --expiry check end if
      out_err_code:= 0;
      out_err_msg := 'SUCCESS';
    ELSE
      raise e_invalid_input;
    END IF;
  EXCEPTION
  WHEN e_invalid_input THEN
    out_err_code:= -10;
    out_err_msg := 'Account objid is null-Expiry check failed';
    sa.ota_util_pkg.err_log ( p_action => 'p_point_benefit_exp_check', p_error_date => sysdate, p_key => NULL, p_program_name => 'p_point_benefit_exp_check', p_error_text => 'in_acct_objid='||in_acct_objid ||'Proc failed: Account Object id was not supplied' ||', ERR='|| SUBSTR(sqlerrm, 1, 4000));
  WHEN OTHERS THEN
    out_err_code:= -10;
    out_err_msg := 'Process error - Expiry check failed';
    sa.ota_util_pkg.err_log ( p_action => 'p_point_benefit_exp_check', p_error_date => sysdate, p_key => NULL, p_program_name => 'p_point_benefit_exp_check', p_error_text => 'in_acct_objid='||in_acct_objid ||'Proc failed look for expiry related issues on account' ||', ERR='|| SUBSTR(sqlerrm, 1, 4000));
  END p_point_benefit_exp_check;
  PROCEDURE P_generate_reward_point_trans(
      in_rundate IN DATE,
      in_min     IN VARCHAR2 DEFAULT NULL,
      in_esn     IN VARCHAR2 DEFAULT NULL,
      out_err_code OUT INTEGER,
      out_err_msg OUT VARCHAR2)
  IS
    /*
    This procedure will read the table_x_call_trans and
    for each ACTIVATION / REACTIVATION / REDEMPTION, it inserts the reward points
    */
    rec_call_trans cur_call_trans%ROWTYPE;
    --lv_limit_clause pls_integer;
    lv_loop_counter PLS_INTEGER;
    lv_last_scan_date        DATE;
    lv_current_point_account NUMBER;
    lv_current_point_brand   NUMBER;
    lv_purch_ref_objid       NUMBER;
    lv_purch_ref_table_name  VARCHAR2(30);
    lv_points                NUMBER;
    lv_service_plan          NUMBER;
    lv_rec_updated PLS_INTEGER := 0;
    lv_old_points             NUMBER;
    lv_old_points_objid       NUMBER;
    lv_expiry_date            DATE; --@TW added for pt expiration logic
    lv_expiry_upg_date        DATE;
    lv_pa_objid               NUMBER;
    lv_upg_acc_id             NUMBER;
    lv_new_esn_already_objid  NUMBER;
    lv_new_esn_already_points NUMBER;
    lv_old_txn_repl           NUMBER;
    lv_exp_set_subid table_x_point_account.subscriber_uid%TYPE;
    rec_point_account cur_point_account%ROWTYPE;
    rec_esn_brand cur_esn_brand%ROWTYPE;
    lv_my_brand cur_esn_brand%ROWTYPE;
    lv_subscriber_id VARCHAR2(40);
    lv_pta_objid     NUMBER;
    lv_rf_total      NUMBER;
    lv_rf_subid      VARCHAR2(40);
    lv_rf_objid      NUMBER;
    lv_refurb_flg    NUMBER;
    lv_rf_min        VARCHAR2(40);
  BEGIN
    ---dbms_output.put_line('**** START OF PROCEDURE p_generate_reward_point_trans ****');
    IF in_min IS NOT NULL THEN
      OPEN cur_esn_brand(in_esn);
      FETCH cur_esn_brand INTO rec_esn_brand;
      ----this block retrieves the bus objid of ESN
      CLOSE cur_esn_brand;
      BEGIN
        ----this block gets the last pt acct update date for MIN, BUS OBJID (of ESN) combo
        SELECT x_last_calc_date
        INTO lv_last_scan_date
        FROM table_x_point_account
        WHERE 1               = 1
        AND x_min             = in_min
        AND x_points_category = lc_point_category_reward
        AND bus_org_objid     = rec_esn_brand.bus_org_objid
        AND account_status    = 'ACTIVE';
      EXCEPTION
      WHEN no_data_found THEN
        lv_last_scan_date := in_rundate;
      END;
    ELSE ----if no record found, last update date is date passed in to SP
      lv_last_scan_date := in_rundate;
    END IF;
    lv_loop_counter          := 0;
    lv_current_point_account := NULL;
    rec_esn_brand            := NULL;
    --dbms_output.put_line('in_min passed to calltran:'||in_min);
    SELECT COUNT(*)
    INTO lv_refurb_flg
    FROM table_x_point_trans tpt
    WHERE tpt.x_esn         = in_esn
    AND tpt.x_points_action = 'REFURB'
    AND tpt.ref_table_name IS NULL;
    --dbms_output.put_line('lv_refurb_flg:'||lv_refurb_flg);
    /*CR32367:VS:05222015 following block is added to handle teh refurbished ESN cases.
    Points and benefits need to be removed from account that has been using the ESN*/
    IF ( lv_refurb_flg > 0 ) THEN
      BEGIN
        SELECT total_points,
          subscriber_uid,
          objid,
          x_min
        INTO lv_rf_total,
          lv_rf_subid,
          lv_rf_objid,
          lv_rf_min
        FROM table_x_point_account pa
        WHERE pa.x_esn        = in_esn
        AND pa.account_status = 'ACTIVE';
      EXCEPTION
      WHEN OTHERS THEN
        lv_rf_total := NULL;
        lv_rf_subid := NULL;
        lv_rf_objid := NULL;
      END;
      IF lv_rf_objid IS NOT NULL AND lv_rf_total > 0 THEN
        -- dbms_output.put_line('Negating '||lv_rf_total||' points for act: '||lv_rf_objid);
        INSERT
        INTO table_x_point_trans
          (
            objid,
            x_trans_date,
            x_min,
            x_esn,
            x_points,
            x_points_category,
            x_points_action,
            points_action_reason,
            point_trans2ref_table_objid,
            ref_table_name,
            point_trans2service_plan,
            point_trans2point_account,
            point_trans2purchase_objid,
            purchase_table_name,
            point_trans2site_part
          )
          VALUES
          (
            sa.seq_x_point_trans.NEXTVAL,
            SYSDATE,
            lv_rf_min,
            in_esn,
            -1*lv_rf_total,
            'REWARD_POINTS',
            'DEDUCT',
            'ESN on which Points were accrued got refurbished',
            NULL,
            NULL,
            NULL,
            lv_rf_objid,
            NULL,
            NULL,
            NULL
          );
        IF lv_rf_subid IS NOT NULL THEN
          UPDATE table_x_benefits txb
          SET txb.x_status           = 967,
            txb.x_notes              = 'ESN on which Benefit was accrued got refurbished'
          WHERE x_benefit_owner_type = 'SID'
          AND x_benefit_owner_value  = lv_rf_subid;
          -- dbms_output.put_line('refurb benefits :'||SQL%rowcount);
        END IF;
      END IF;
      UPDATE table_x_point_trans tpt
      SET tpt.ref_table_name  = 'REFURB_PT_BFT_REMOVED'
      WHERE tpt.x_esn         = in_esn
      AND tpt.x_points_action = 'REFURB'
      AND tpt.ref_table_name IS NULL;
    END IF;
    /*CR32367:VS: End of refurbished ESN cases.*/
    FOR rec_call_trans IN cur_call_trans (in_min, lv_last_scan_date)
    ----retrieves call trans records for this MIN since last scan date (cursor code subtracts 5 days)
    LOOP
      --dbms_output.put_line('call tran cur count:'||rec_call_trans.count); --remove before prod
      lv_points               := NULL;
      lv_service_plan         := NULL;
      lv_purch_ref_objid      := NULL;
      lv_purch_ref_table_name := NULL;
      --for current call_trans record
      --find the corresponding purchase record objid, purchase table name
      --and service plan objid, and the points and
      P_get_points_n_plan (in_esn => rec_call_trans.x_esn, in_call_trans_objid => rec_call_trans.objid, in_call_trans_actiontype => rec_call_trans.x_action_type, in_call_trans_reason => rec_call_trans.x_reason, out_points_earned => lv_points, out_points_plan => lv_service_plan, out_purch_objid => lv_purch_ref_objid, out_purch_table_name => lv_purch_ref_table_name);
      --@TW added this entire if block to take care of DEACTIVATION and PORT OUT ???
      --if one of these transactions is detected, then create a trans log record and set the account expiration date appropriately
      --this SHOULD BE MOVED above the above call to p_get_points_n_plan (and skip that call)
      IF ( rec_call_trans.x_action_type IN ( '2', '20' ) ) THEN
        BEGIN
          --dbms_output.put_line('inside acition 2/20 block'); --remove before prod
          --check whether point_account exists and if not then create point_account
          --(this code copied from other sections below)
          P_check_point_account (in_min => rec_call_trans.x_min, in_esn => rec_call_trans.x_esn, out_account_objid => lv_current_point_account, out_account_bus_org => lv_current_point_brand);
          --dbms_output.put_line('after check point account'); --remove before prod
          --insert a record in the transaction table (just a note marking the event but no point changes)
          INSERT
          INTO table_x_point_trans
            (
              objid,
              x_trans_date,
              x_min,
              x_esn,
              x_points,
              x_points_category,
              x_points_action,
              points_action_reason,
              point_trans2ref_table_objid,
              ref_table_name,
              point_trans2service_plan,
              point_trans2point_account,
              point_trans2purchase_objid,
              purchase_table_name,
              point_trans2site_part,
              point_display_reason
            )
            VALUES
            (
              sa.seq_x_point_trans.NEXTVAL,
              SYSDATE,
              rec_call_trans.x_min,
              rec_call_trans.x_esn,
            -- 0,--no points for this trans (note)
              NULL, -- Modified from ZERO TO NULL value for the 'CR52398'
              lc_point_category_reward,
              'NOTE',
              --@TW placeholder for now; check for appropriate type
              'ACTION_TYPE='
              ||rec_call_trans.x_action_type
              || ', REASON='
              ||rec_call_trans.x_reason,
              rec_call_trans.objid,
              'TABLE_X_CALL_TRANS',
              NULL,--lv_service_plan,
              lv_current_point_account,
              NULL,--lv_purch_ref_objid,
              NULL,--lv_purch_ref_table_name,
              NULL,--rec_call_trans.call_trans2site_part
              rec_call_trans.x_reason
            );
          --dbms_output.put_line('after inserting the deactivation trans'); --remove before prod
          --determine expiration date based on action type
          IF rec_call_trans.x_action_type = '2' THEN
            IF rec_call_trans.x_reason    = 'PORT OUT'
              -- ITQ#46 vs:05/11/15
              THEN
              lv_expiry_date := SYSDATE + ( 30 );
            ELSE
              lv_expiry_date := SYSDATE + ( 365 * 2 );
              --2 years for DEACTIVATIONS
            END IF;
          ELSE -- ct.x_action_type ='20'
            lv_expiry_date := SYSDATE + ( 30 );
            -- SQA2327 1 month for PORT OUTS --05/27/15 VS: setting port out expiration to 1 month
          END IF;
          --dbms_output.put_line('Expiration determined'); --remove before prod
          -- update the point account entry
          UPDATE table_x_point_account tpa
          SET tpa.x_expiry_date = lv_expiry_date
          WHERE tpa.objid       = lv_current_point_account returning tpa.subscriber_uid
          INTO lv_subscriber_id;
          --dbms_output.put_line('PA expiry date updated:'||SQL%ROWCOUNT); --remove before prod
          -- update the benefit records with exact same expiry date as its account
          UPDATE table_x_benefits txb
          SET txb.x_expiry_date          = lv_expiry_date
          WHERE txb.x_benefit_owner_type = 'SID'
          AND txb.x_benefit_owner_value  = lv_subscriber_id
          AND txb.x_expiry_date         IS NULL; --VS:051515:CR32367
          --dbms_output.put_line('TXB expiry date updated:'||SQL%ROWCOUNT); --remove before prod
          lv_job_insert_rec_counter := lv_job_insert_rec_counter + 1;
        END;
      ELSIF NVL(lv_points, 0) != 0 THEN
        --@TW I assume this one covers ACTIVATION, REACTIVATION, REDEMPTION
        BEGIN
          lv_loop_counter := lv_loop_counter + 1;
          --check whether point_account exists or no
          --if not then create point_account
          --@TW ideally, this should be called once only - is there a scenario where we might have to create more than one acct rec ???
          P_check_point_account (in_min => rec_call_trans.x_min, in_esn => rec_call_trans.x_esn, out_account_objid => lv_current_point_account, out_account_bus_org => lv_current_point_brand);
          --inserts the points that are earned through this call_trans transaction
          IF lv_current_point_account IS NOT NULL THEN
            -- Expiry date needs to be removed if a customer returns
            -- CR32367:VS:051515 -- Points benefit expiry updates
            P_point_benefit_exp_check(lv_current_point_account, 'N', out_err_code, out_err_msg);
            INSERT
            INTO table_x_point_trans
              (
                objid,
                x_trans_date,
                x_min,
                x_esn,
                x_points,
                x_points_category,
                x_points_action,
                points_action_reason,
                point_trans2ref_table_objid,
                ref_table_name,
                point_trans2service_plan,
                point_trans2point_account,
                point_trans2purchase_objid,
                purchase_table_name,
                point_trans2site_part,
                point_display_reason
              )
              VALUES
              (
                sa.seq_x_point_trans.NEXTVAL,
                SYSDATE,
                rec_call_trans.x_min,
                rec_call_trans.x_esn,
                lv_points,
                lc_point_category_reward,
                'ADD',
                'ACTION_TYPE='
                ||rec_call_trans.x_action_type
                || ', REASON='
                ||rec_call_trans.x_reason,
                rec_call_trans.objid,
                'TABLE_X_CALL_TRANS',
                lv_service_plan,
                lv_current_point_account,
                lv_purch_ref_objid,
                lv_purch_ref_table_name,
                rec_call_trans.call_trans2site_part,
                (
                CASE
                  WHEN rec_call_trans.x_reason     IS NOT NULL
                  AND rec_call_trans.x_action_type <> '401'
                  THEN rec_call_trans.x_reason
                  WHEN rec_call_trans.x_action_type = '401'
                  THEN 'Queued Card'
                  WHEN rec_call_trans.x_action_type = '1'
                  THEN 'Activation'
                  WHEN rec_call_trans.x_action_type = '3'
                  THEN 'Reactivation'
                  WHEN rec_call_trans.x_action_type = '6'
                  THEN 'Redemption'
                  ELSE 'Reason undocumented'
                END )
              );
            lv_job_insert_rec_counter := lv_job_insert_rec_counter + 1;
            ----for replacement plans, also tries to find pt trans record for original entry then creates duplicate with neg points to undo it
            IF Upper(rec_call_trans.x_reason) IN ( 'REPLACEMENT' ) THEN
              BEGIN
                --find the old plan which is being replaced
                SELECT plan_hist2service_plan
                INTO lv_old_points_objid
                FROM x_service_plan_hist
                WHERE plan_hist2site_part = rec_call_trans.call_trans2site_part
                  --1630705336
                AND x_start_date =
                  (SELECT MAX(x_start_date)
                    --- to_char(x_start_date, 'dd-mon-rrrr hh24:mi:sssss'), xh.*
                  FROM x_service_plan_hist xh
                  WHERE plan_hist2site_part = rec_call_trans.call_trans2site_part
                    ---1630705336
                  AND plan_hist2service_plan <> lv_service_plan
                    ---358
                  );
                --find the last txn record for the service plan
                lv_old_txn_repl := NULL;
                SELECT MAX(objid)
                INTO lv_old_txn_repl
                FROM table_x_point_trans
                WHERE point_trans2point_account = lv_current_point_account
                AND point_trans2service_plan    = lv_old_points_objid;
                IF lv_old_txn_repl             IS NOT NULL THEN
                  INSERT
                  INTO table_x_point_trans
                    (
                      objid,
                      x_trans_date,
                      x_min,
                      x_esn,
                      x_points,
                      x_points_category,
                      x_points_action,
                      points_action_reason,
                      point_trans2ref_table_objid,
                      ref_table_name,
                      point_trans2service_plan,
                      point_trans2point_account,
                      point_trans2purchase_objid,
                      purchase_table_name,
                      point_trans2site_part,
                      point_display_reason
                    )
                  SELECT sa.seq_x_point_trans.NEXTVAL,
                    SYSDATE,
                    x_min,
                    x_esn,
                    -1 * x_points,
                    x_points_category,
                    'DEDUCT',
                    'Points subtracted due to service plan Replacement',
                    lv_old_txn_repl,
                    'TABLE_X_POINT_TRANS',
                    point_trans2service_plan,
                    point_trans2point_account,
                    point_trans2purchase_objid,
                    purchase_table_name,
                    point_trans2site_part,
                    'Svc plan replacement'
                  FROM table_x_point_trans
                  WHERE objid = lv_old_txn_repl;
                END IF;
              EXCEPTION
              WHEN OTHERS THEN
                sa.ota_util_pkg.Err_log (p_action => 'replacement of points' , p_error_date => SYSDATE, p_key => 'MIN=' ||in_min || '.', p_program_name => 'p_generate_reward_point_trans', p_error_text => 'ERR in replacement of points' ||', lv_current_point_account=' ||lv_current_point_account ||', lv_old_points_objid=' ||lv_old_points_objid ||', Err=' ||SUBSTR(SQLERRM, 1, 2000));
              END;
            END IF;
          END IF;
        END;
      ELSIF ( Upper(rec_call_trans.x_reason) IN ( 'UPGRADE', 'REACTIVATION' ) OR
        /*CR32367:VS:052115:ITQ111:ITQ128:TAS reactivations carry x_reason as null
        TAS couldnt find fix for the issue in time so we are handing reactivation
        with NULL reason the same way a REACTIVATION reason will be handled*/
        rec_call_trans.x_action_type = '3' AND rec_call_trans.x_reason IS NULL ) THEN
        BEGIN
          --during esn upgrade, change the esn
          --FROM_ESN = rec_call_trans.x_esn ==> @TWfor upgrade, wheres the to ESN stored ?
          --TO_ESN = present in table_x_point_account with same brand as that of from_esn
          --UPGRADE = active to pastdue or active to brand new
          --REACTIVATION = active to active
          --get the brand of FROM_ESN
          OPEN cur_esn_brand (rec_call_trans.x_esn);
          FETCH cur_esn_brand INTO lv_my_brand;
          CLOSE cur_esn_brand;
          --check the FROM_ESN already have any points within the same brand;
          lv_new_esn_already_objid  := NULL;
          lv_new_esn_already_points := NULL;
          SELECT MAX(objid),
            NVL(MAX(total_points), 0),
            MAX(x_expiry_date)
            --@TW this looks strange, can it get objid and points from different records ??? if so not good !!!
          INTO lv_new_esn_already_objid,
            lv_new_esn_already_points,
            lv_expiry_upg_date
          FROM table_x_point_account
          WHERE 1            = 1
          AND x_esn          = rec_call_trans.x_esn
          AND x_min         <> rec_call_trans.x_min
          AND account_status = 'ACTIVE'
          AND bus_org_objid  = lv_my_brand.bus_org_objid;
          --update the esn
          --@TW this also looks strange, not sure what's happening; appears to be adding pts from different accounts (that are still active)
          IF lv_new_esn_already_objid IS NOT NULL THEN
            /*Cr32367:VS:051715 block added to do expiry check on target account*/
            BEGIN
              SELECT objid
              INTO lv_upg_acc_id
              FROM table_x_point_account
              WHERE x_min        = rec_call_trans.x_min
              AND bus_org_objid  = lv_my_brand.bus_org_objid
              AND account_status = 'ACTIVE';
              IF lv_upg_acc_id  IS NOT NULL THEN
                -- CR32367:VS:051715 -- Points benefit expiry updates
                P_point_benefit_exp_check(lv_upg_acc_id, 'Y', out_err_code , out_err_msg) ;
                --recalculate flag set to 'Y'
              END IF;
            EXCEPTION
            WHEN OTHERS THEN
              sa.ota_util_pkg.Err_log ( p_action => 'upgrade esn check-GenPTrans' , p_error_date => SYSDATE, p_key => NULL, p_program_name => 'p_generate_point_trans', p_error_text => 'lv_upg_acc_id=' ||lv_upg_acc_id ||'Failure on account lookup' ||', ERR=' || SUBSTR(SQLERRM, 1, 4000));
            END;
            /*Cr32367:VS:051715 block ends on doing expiry check on target account*/
            UPDATE table_x_point_account
            SET x_esn               = rec_call_trans.x_esn,
              account_status_reason = 'ESN Upgrade on='
              || TO_CHAR(SYSDATE, 'dd-mon-rrrr hh24:mi:sssss')
              ||'; old esn='
              ||x_esn,
              total_points = total_points + (
              CASE
                WHEN (lv_expiry_upg_date IS NULL
                OR lv_expiry_upg_date     > SYSDATE )
                THEN NVL (lv_new_esn_already_points, 0)
                ELSE 0
              END ),
              x_last_calc_date = SYSDATE
            WHERE 1            = 1
            AND x_min          = rec_call_trans.x_min
            AND bus_org_objid  = lv_my_brand.bus_org_objid
            AND account_status = 'ACTIVE' returning objid
            INTO lv_pa_objid;
          END IF;
          lv_job_update_rec_counter := lv_job_update_rec_counter + SQL% rowcount;
          --if points are present in FROM_ESN then transfer those points to TO_ESN
          --and mark the FROM_ESN record as inactive
          --@TW why is new record being made INACTIVE? or is it just bad variable name
          IF lv_new_esn_already_objid IS NOT NULL AND lv_pa_objid IS NOT NULL THEN
            UPDATE table_x_point_account
            SET account_status      = 'INACTIVE',
              account_status_reason = 'Account inactivated since ESN Upgraded and Points transferred to Account-Objid='
              ||lv_pa_objid,
              x_last_calc_date         = SYSDATE
            WHERE objid                = lv_new_esn_already_objid;
            lv_rec_updated            := SQL%rowcount;
            lv_job_update_rec_counter := lv_job_update_rec_counter + SQL%rowcount;
          END IF;
          --inserts a record in point_trans just to note when ESN got upgraded
          IF NVL(lv_rec_updated, 0) > 0 THEN
            lv_loop_counter        := lv_loop_counter + 1;
            INSERT
            INTO table_x_point_trans
              (
                objid,
                x_trans_date,
                x_min,
                x_esn,
                x_points,
                x_points_category,
                x_points_action,
                points_action_reason,
                point_trans2ref_table_objid,
                ref_table_name,
                point_trans2service_plan,
                point_trans2point_account,
                point_trans2purchase_objid,
                purchase_table_name,
                point_trans2site_part,
                point_display_reason
              )
              VALUES
              (
                sa.seq_x_point_trans.NEXTVAL,
                SYSDATE,
                rec_call_trans.x_min,
                rec_call_trans.x_esn,
                NVL(lv_new_esn_already_points, NULL),--total_points  Included  NULL value for the 'CR52398'
                lc_point_category_reward,
                'ESNUPGRADE',
                'ESN Upgraded on : '
                || TO_CHAR(SYSDATE, 'dd-mon-rrrr hh24:mi:sssss'),
                rec_call_trans.objid,
                'TABLE_X_CALL_TRANS',
                NULL,
                lv_pa_objid,
                NULL,
                NULL,
                rec_call_trans.call_trans2site_part,
                'Upgrade'
              );
            lv_job_insert_rec_counter := lv_job_insert_rec_counter + 1;
          END IF;
        END;
      ELSIF Upper(rec_call_trans.x_reason) IN ( 'MINCHANGE' ) THEN
        --check whether point_account exists or no
        --if not then create point_account
        /*VS:051715:Note-Expiry check on minchange is to make sure we
        dont transfer points to new MIN account if its using a ESN
        that is active on upgrade plan account. This check will be
        done inside check point account*/
        P_check_point_account (in_min => rec_call_trans.x_min, in_esn => rec_call_trans.x_esn, out_account_objid => lv_current_point_account, out_account_bus_org => lv_current_point_brand);
        /*CR32367:ITQ111:VS:051815:Else block to handle any non-deactivation
        scenario that is not earning points. Specifically to unset expiry
        date when a point account is reactivated with a non point earning
        transaction. In this block Expiration date if available on point
        account will be made null, if expired points are available they
        will be taken away. If live benfits with future expiry date is
        available then the expiry date will be nullified*/
      ELSE
        BEGIN
          SELECT pa.objid
          INTO lv_pta_objid
          FROM table_x_point_account pa
          WHERE pa.x_min        = rec_call_trans.x_min
          AND pa.x_esn          = rec_call_trans.x_esn
          AND pa.account_status = 'ACTIVE'
          AND pa.x_expiry_date IS NOT NULL;
        EXCEPTION
        WHEN OTHERS THEN
          lv_pta_objid := NULL;
        END;
        IF lv_pta_objid IS NOT NULL THEN
          P_point_benefit_exp_check(lv_pta_objid, 'N', out_err_code, out_err_msg);
        END IF;
      END IF;
      IF Upper(rec_call_trans.x_reason) IN ( 'AWOP' ) THEN
        /*VS:051715:NEED MORE ANALYSIS ON AWOP BEFORE TAKING ACTION ON EXPIRY
        CHECK ON CONFIRMATION POINT_BENEFIT_EXPIRY_CHECK CAN BE ADDED*/
        --check how many points the old esn has
        --and if it has any then subtract the newly added points
        OPEN cur_esn_brand(rec_call_trans.x_esn);
        FETCH cur_esn_brand INTO rec_esn_brand;
        CLOSE cur_esn_brand;
        SELECT NVL(MAX(pa.total_points), 0),
          MAX(pa.objid)
        INTO lv_old_points,
          lv_old_points_objid
        FROM table_x_point_account pa,
          (SELECT tc.x_esn  AS new_esn,
            tcd_esn.x_value AS old_esn
          FROM table_case tc,
            table_x_case_detail tcd_esn
          WHERE 1                 = 1
          AND tc.x_esn            = rec_call_trans.x_esn
          AND tcd_esn.detail2case = tc.objid
          AND tc.s_title
            ||'' = 'REPLACEMENT UNITS'
          AND tcd_esn.x_name
            ||'' = 'REFERENCE_ESN'
          UNION
          SELECT tc.x_esn   AS new_esn,
            ct.x_service_id AS old_esn
          FROM table_case tc,
            table_x_case_detail tcd,
            table_x_red_card rc,
            table_x_call_trans ct
          WHERE 1             = 1
          AND tc.x_esn        = rec_call_trans.x_esn
          AND ct.x_service_id = tc.x_esn
          AND tc.objid        = tcd.detail2case
          AND tc.s_title
            ||'' = 'REPLACEMENT UNITS'
          AND tcd.x_name
            ||''                = 'REFERENCE_PIN'
          AND tcd.x_value       = rc.x_red_code
          AND rc.x_result       = 'Completed'
          AND ct.objid          = rc.red_card2call_trans
          AND ct.x_action_type IN ( '1', '3', '6', '401' )
            --@TW added 401 for queued cards (I dont think '2' and '20' needed here ?)
          AND ct.x_result
            ||'' = 'Completed'
          ) tt
        WHERE 1                  = 1
        AND tt.old_esn           = pa.x_esn
        AND pa.account_status    = 'ACTIVE'
        AND pa.bus_org_objid     = rec_esn_brand.bus_org_objid;
        IF NVL(lv_old_points, 0) > 0 THEN
          --that means points were added for old transaction
          --and so, subtract new_esn points from old_esn points
          UPDATE table_x_point_account
          SET total_points        = Greatest (0, total_points - NVL(lv_points, 0)),
            account_status_reason = NVL(lv_points, 0)
            ||' Points subtracted because of AWOP txn.'
            ||' call_trans objid= '
            ||rec_call_trans.objid,
            x_last_calc_date         = SYSDATE
          WHERE objid                = lv_old_points_objid;
          lv_job_update_rec_counter := lv_job_update_rec_counter + SQL%rowcount;
        END IF;
      END IF;
    END LOOP;
    out_err_code := 0;
    out_err_msg  := 'SUCCESS';
    --dbms_output.put_line('**** END OF PROCEDURE p_generate_reward_point_trans ****');
    --DBMS_OUTPUT.PUT_LINE('TOTAL INSERTED RECORDS INTO table_x_point_trans: '||lv_loop_counter);
    --CLOSE cur_call_trans;
  EXCEPTION
  WHEN OTHERS THEN
    out_err_code := -99;
    out_err_msg  := 'FAILED';
    /*
    IF cur_call_trans%isopen THEN
    CLOSE cur_call_trans;
    END IF;
    */
    sa.ota_util_pkg.Err_log ( p_action => 'reward_points_pkg.p_generate_reward_point_trans', p_error_date => SYSDATE, p_key => 'MIN=' ||in_min || '.', p_program_name => 'reward_points_pkg.p_generate_reward_point_trans', p_error_text => 'Unknown error..' ||', lv_current_point_account=' ||lv_current_point_account ||', lv_loop_counter=' ||lv_loop_counter ||', Err=' ||SUBSTR(SQLERRM, 1, 2000));
    --DBMS_OUTPUT.PUT_LINE('**** EXCEPTION WHILE RUNNING PROCEDURE p_generate_reward_point_trans **** MIN = '||in_min);
  END p_generate_reward_point_trans;
  PROCEDURE p_calculate_points(
      in_min IN VARCHAR2 DEFAULT NULL,
      out_err_code OUT INTEGER,
      out_err_msg OUT VARCHAR2 )
    /*
    14-nov-2014
    --calculate how many total points this min has earned till date
    Vkashmire
    This procedure will read table_x_point_trans
    and update total_points in table_x_point_account
    This process can be performed for specific min or
    for all MINs for which total_points are not yet calculated
    */
  IS
    CURSOR cur_point_summary
    IS
      SELECT acc.x_min,
        acc.x_esn,
        acc.x_points_category,
        acc.objid AS acc_objid,
        acc.bus_org_objid,
        SUM(trans.x_points) AS calc_points
        --max(trans.x_trans_date) as new_last_calc_date
      FROM table_x_point_trans trans,
        table_x_point_account acc
      WHERE 1 = 1
        --and ( trans.x_min = in_min or in_min is null )-- 060215 commenting this as only null mins will use this cursor
      AND ( trans.x_trans_date       > NVL(acc.x_last_calc_date, sysdate-5) )
      AND ( acc.objid                = trans.point_trans2point_account)
      AND ( acc.account_status       = 'ACTIVE' )
      AND trans.x_points_action     IN ('ADD', 'DEDUCT', 'REFUND', 'CONSUMED')
      AND trans.point_trans2benefit IS NULL
      GROUP BY acc.bus_org_objid,
        acc.x_min,
        acc.x_esn,
        acc.x_points_category,
        acc.objid;
    /*VS:060215 adding cursor to handle performance issue*/
    CURSOR cur_point_summary_min
    IS
      SELECT acc.x_min,
        acc.x_esn,
        acc.x_points_category,
        acc.objid AS acc_objid,
        acc.bus_org_objid,
        SUM(trans.x_points) AS calc_points
        --max(trans.x_trans_date) as new_last_calc_date
      FROM table_x_point_trans trans,
        table_x_point_account acc
      WHERE 1                        = 1
      AND trans.x_min                = in_min -- min null check removed to help performance 060215
      AND ( trans.x_trans_date       > NVL(acc.x_last_calc_date, sysdate-5) )
      AND ( acc.objid                = trans.point_trans2point_account)
      AND ( acc.account_status       = 'ACTIVE' )
      AND trans.x_points_action     IN ('ADD', 'DEDUCT', 'REFUND', 'CONSUMED')
      AND trans.point_trans2benefit IS NULL
      GROUP BY acc.bus_org_objid,
        acc.x_min,
        acc.x_esn,
        acc.x_points_category,
        acc.objid;
    rec_esn_min cur_esn_min_dtl%rowtype;
  type tab_cur_points_summary
IS
  TABLE OF cur_point_summary%rowtype INDEX BY pls_integer;
  rec_cur_points_summary tab_cur_points_summary;
  --060215 perf_fix
type tab_cur_points_summary_min
IS
  TABLE OF cur_point_summary_min%rowtype INDEX BY pls_integer;
  rec_cur_points_summary_min tab_cur_points_summary_min;
  lv_update_counter pls_integer := 0;
BEGIN
  --dbms_output.put_line('**** START OF PROCEDURE p_calculate_points ****');
  IF in_min IS NOT NULL THEN
    OPEN cur_esn_min_dtl ('MIN', in_min);
    FETCH cur_esn_min_dtl INTO rec_esn_min ;
    CLOSE cur_esn_min_dtl;
    IF rec_esn_min.x_min IS NULL THEN
      raise no_data_found;
    END IF;
  END IF;
--adding if block to check the min and choose the curoe to be opened 060215
IF in_min IS NULL THEN --060215 perf fix
  OPEN cur_point_summary;
  LOOP
    FETCH cur_point_summary bulk collect INTO rec_cur_points_summary;
    EXIT
  WHEN rec_cur_points_summary.count = 0;
    forall ic IN 1..rec_cur_points_summary.count
    UPDATE table_x_point_account t1
    SET t1.x_esn          = rec_cur_points_summary(ic).x_esn,
      t1.total_points     = t1.total_points + rec_cur_points_summary(ic).calc_points,
      t1.x_last_calc_date = sysdate ----rec_cur_points_summary(ic).new_last_calc_date
    WHERE objid           = rec_cur_points_summary(ic).acc_objid ;
    lv_update_counter    := lv_update_counter + sql%rowcount;
  END LOOP;
  CLOSE cur_point_summary;
ELSE -- 060215 perf fix
  OPEN cur_point_summary_min;
  LOOP
    FETCH cur_point_summary_min bulk collect INTO rec_cur_points_summary_min;
    EXIT
  WHEN rec_cur_points_summary_min.count = 0;
    forall ic IN 1..rec_cur_points_summary_min.count
    UPDATE table_x_point_account t1
    SET t1.x_esn          = rec_cur_points_summary_min(ic).x_esn,
      t1.total_points     = t1.total_points + rec_cur_points_summary_min(ic).calc_points,
      t1.x_last_calc_date = sysdate ----rec_cur_points_summary(ic).new_last_calc_date
    WHERE objid           = rec_cur_points_summary_min(ic).acc_objid ;
    lv_update_counter    := lv_update_counter + sql%rowcount;
  END LOOP;
  CLOSE cur_point_summary_min; -- 060215 perf fix end
END IF ;                       -- 060215 perf fix end
out_err_code := 0;
out_err_msg  := 'SUCCESS';
---DBMS_OUTPUT.PUT_LINE('TOTAL RECORDS UPDATED IN TABLE_x_POINT_ACCOUNT : '||lv_update_counter);
--dbms_output.put_line('**** END OF PROCEDURE p_calculate_points ****');
EXCEPTION
WHEN OTHERS THEN
  IF cur_point_summary%isopen THEN
    CLOSE cur_point_summary;
  END IF;
  out_err_code := -99;
  out_err_msg  := 'p_calculate_points FAILURE...' ||'ERR=' || SUBSTR(sqlerrm,1,100);
  sa.ota_util_pkg.err_log ( p_action => 'p_calculate_points', p_error_date => sysdate, p_key => 'p_calculate_points', p_program_name => 'p_calculate_points', p_error_text => SUBSTR(sqlerrm, 1, 4000));
  --DBMS_OUTPUT.PUT_LINE('**** EXCEPTION WHILE RUNNING PROCEDURE p_calculate_points **** out_err_code: '||out_err_code||' out_err_msg: '||out_err_msg );
END p_calculate_points;
PROCEDURE p_get_reward_points(
    in_key            IN VARCHAR2,
    in_value          IN VARCHAR2,
    in_point_category IN VARCHAR2 DEFAULT 'REWARD_POINTS',
    out_total_points OUT NUMBER,
    out_subscriber_id OUT VARCHAR2,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
  validation_failed EXCEPTION;
  lv_acc_objid      NUMBER;
  lv_esn table_site_part.x_service_id%type;
  rec_esn_min cur_esn_min_dtl%rowtype;
  lv_steps_completed INTEGER ;
  lv_points_brand    NUMBER;
  lv_bus_org         NUMBER;
  lv_subid           VARCHAR2(50);
  lv_err_code        NUMBER;
  lv_err_msg         VARCHAR2(2000);
  lv_expiry_date     DATE;
  lv_deact_ct_id     NUMBER;
  lv_deact_min       VARCHAR2(30);
  lv_deact_esn       VARCHAR2(30);
  lv_deact_trans_flg VARCHAR2(30) := 'N';
BEGIN
  out_total_points   := 0;
  lv_steps_completed := 0;
  IF NVL(in_key,'~') NOT IN ('MIN', 'ESN') THEN
    out_err_code :=       -311;
    out_err_msg  := 'Error. Unsupported values received for IN_KEY and IN_VALUE' ;
    raise validation_failed;
  elsif in_value IS NULL THEN
    out_err_code := -311;
    out_err_msg  := 'Error. IN_KEY and IN_VALUE should not be null' ;
    raise validation_failed;
  elsif NVL(in_point_category,lc_point_category_reward) != lc_point_category_reward THEN
    out_err_code                                        := -311;
    out_err_msg                                         := 'Input point category is invalid' ;
    raise validation_failed;
  END IF;
  OPEN cur_esn_min_dtl (in_key, in_value);
  FETCH cur_esn_min_dtl INTO rec_esn_min ;
  CLOSE cur_esn_min_dtl;
  IF rec_esn_min.x_esn IS NULL OR rec_esn_min.x_min IS NULL THEN
    /*CR32367:VS:051615
    following select and check is in place to allow for deactivation transaction
    to get into the system. this will allow to set the expiration date
    on point account and benefits*/
    SELECT MAX(ct.objid),
      MAX(ct.x_min),
      MAX(ct.x_service_id)
    INTO lv_deact_ct_id,
      lv_deact_min,
      lv_deact_esn
    FROM table_x_call_trans ct
    WHERE ct.x_action_type IN ('2','20')
    AND ( (in_key           = 'ESN'
    AND ct.x_service_id     = in_value )
    OR (in_key              = 'MIN'
    AND ct.x_min            = in_value ) )
    AND NOT EXISTS
      (SELECT 1
      FROM table_x_point_trans pt
      WHERE pt.point_trans2ref_table_objid = ct.objid
      AND pt.REF_TABLE_NAME                = 'TABLE_X_CALL_TRANS'
      AND ( (in_key                        = 'ESN'
      AND pt.x_esn                         = in_value )
      OR (in_key                           = 'MIN'
      AND pt.x_min                         = in_value ) )
      );
    IF lv_deact_ct_id    IS NOT NULL THEN
      lv_deact_trans_flg := 'Y';
      -- not an exception needs to be processed for deactivation:CR32367:VS:051615
    ELSE
      out_err_code := -325;
      out_err_msg  := 'Input '|| in_key || '['|| in_value || '] not found in database OR its NOT ACTIVE' ;
      raise validation_failed;
    END IF;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  -----------------
  /* CR32367:ITQ51:VS:051815:
  moving reward_benefits_n_vouchers_pkg.p_get_subscriber_id to a later stage
  in the process*/
  -----------------
  --generate point trans records for input min
  --@TW removed the -5 from the below call, its already done in call chain as part of p_generate_reward_point_trans
  --@TW p_generate_reward_point_trans(sysdate-5, rec_esn_min.x_min, rec_esn_min.x_esn, out_err_code, out_err_msg);
  IF lv_deact_trans_flg ='Y' THEN
    p_generate_reward_point_trans(sysdate,lv_deact_min ,lv_deact_esn , out_err_code, out_err_msg);
    IF out_err_code != 0 THEN
      raise validation_failed;
    END IF;
  ELSE
    p_generate_reward_point_trans(sysdate, rec_esn_min.x_min, rec_esn_min.x_esn, out_err_code, out_err_msg);
    IF out_err_code != 0 THEN
      raise validation_failed;
    END IF;
  END IF;
  --CR32367:ITQ51:VS:051815:Repositioning the following call from where it was before.
  reward_benefits_n_vouchers_pkg.p_get_subscriber_id ( in_key => in_key ,in_value => in_value ,out_subscriber_id => lv_subid ,out_err_code => lv_err_code ,out_err_msg => lv_err_msg ) ;
  --CR52398 - START
  out_subscriber_id := lv_subid;
  --CR52398 - END
  lv_steps_completed    := lv_steps_completed + 1;
  IF (rec_esn_min.x_min IS NOT NULL AND lv_deact_trans_flg <> 'Y' ) --06042015 deact perf fix
    THEN
    p_calculate_points (rec_esn_min.x_min, out_err_code, out_err_msg);
    IF out_err_code != 0 THEN
      raise validation_failed;
    END IF;
  END IF; --06042015 deact perf fix
  lv_steps_completed := lv_steps_completed + 1;
  --check if total points have reached the maximum value
  --and may be eligible to create a reward benefit
  --03/24/2015 CR32367
  IF (rec_esn_min.x_min IS NOT NULL AND lv_deact_trans_flg <> 'Y' ) --06042015 deact perf fix
    THEN
    sa.reward_benefits_n_vouchers_pkg.p_create_reward_benefits ( in_min => rec_esn_min.x_min ,out_err_code => out_err_code ,out_err_msg => out_err_msg );
    --dbms_output.put_line('p_create_reward_benefits response CODE ='||out_err_code);
  END IF; --06042015 deact perf fix
  lv_steps_completed := lv_steps_completed + 1;
  --dbms_output.put_line(' min brand ='|| rec_esn_min.bus_org_objid
  --|| ', min='||rec_esn_min.x_min );
  --during upgrade, esn gets changed; so need to update min with new esn
  IF lv_deact_trans_flg <> 'Y' THEN
    BEGIN
      SELECT NVL(acc.total_points,0),
        acc.x_esn,
        acc.objid,
        acc.bus_org_objid,
        acc.subscriber_uid
      INTO out_total_points,
        lv_esn,
        lv_acc_objid,
        lv_points_brand,
        out_subscriber_id
      FROM table_x_point_account acc
      WHERE 1                   =1
      AND acc.x_min             = rec_esn_min.x_min
      AND acc.x_points_category = in_point_category
      AND acc.bus_org_objid     = rec_esn_min.bus_org_objid
      AND acc.account_status    = 'ACTIVE';
      IF (lv_esn                = rec_esn_min.x_esn ) AND (lv_acc_objid IS NOT NULL) THEN
        NULL;
      ELSE
        --esn might have got changed because of any reason - upgrade/warranty exchange etc
        --if points-job is not yet run then esn will not be updated..so update it here
        UPDATE table_x_point_account
        SET x_esn               = rec_esn_min.x_esn ,
          account_status_reason = 'ESN changed on='
          || TO_CHAR(sysdate, 'dd-Mon-yyyy hh24:mi')
          ||'; old esn='
          ||x_esn ,
          x_last_calc_date = sysdate ,
          x_expiry_date    = NULL --VS:052815: srenevasquez,gtorraco upgrade testcase
        WHERE objid        = lv_acc_objid;
        IF sql%rowcount    > 0 THEN
          INSERT
          INTO table_x_point_trans
            (
              objid,
              x_trans_date,
              x_min,
              x_esn,
              x_points,
              x_points_category,
              x_points_action,
              points_action_reason,
              point_trans2ref_table_objid,
              ref_table_name,
              point_trans2service_plan,
              point_trans2point_account,
              point_trans2purchase_objid,
              purchase_table_name,
              point_trans2site_part,
              point_display_reason
            )
            VALUES
            (
              sa.seq_x_point_trans.nextval,
              sysdate,
              rec_esn_min.x_min,
              rec_esn_min.x_esn,
             -- 0,
              NULL, -- Modified from ZERO TO NULL value for the Modified from ZERO TO NULL value for the 'CR52398'
              lc_point_category_reward,
              'ESNUPGRADE',
              'ESN Upgraded On: '
              || TO_CHAR(sysdate, 'dd-mon-rrrr hh24:mi:sssss'),
              NULL,
              NULL,
              NULL,
              lv_acc_objid,
              NULL,
              NULL,
              rec_esn_min.site_part_objid,
              'Upgrade'
            );
        END IF;
      END IF;
      lv_steps_completed := lv_steps_completed + 1;
    EXCEPTION
    WHEN no_data_found THEN
      out_err_code := -5;
      out_err_msg  := 'No Points for ' || in_key || ' = ' || in_value ;
      raise validation_failed;
    END;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  /*
  p_get_money_for_points (
  out_total_points,
  in_point_category,
  lv_points_brand, ---null, ---rec_esn_min.service_plan_objid,
  out_amount,
  out_err_code,
  out_err_msg);
  lv_steps_completed := lv_steps_completed + 1;
  if out_err_code <> 0 then
  out_amount := 0;
  out_err_msg := 'Amount tier not found for points='||out_total_points
  || ', lc_point_category_reward=' || lc_point_category_reward
  || ', lv_points_brand='||lv_points_brand
  ;
  raise validation_failed;
  end if;
  */
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';

  --CR47722 - Start
  BEGIN --{
   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Commit Successful');
  --do commit since this procedure directly gets called from TAS without commit
  EXCEPTION
  WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE('In commit exception ~ '||sqlerrm);
   ROLLBACK;
   out_err_code      := 0;
   DBMS_OUTPUT.PUT_LINE('After Rollback');
  END; --}
  --CR47722 - End
  lv_steps_completed := lv_steps_completed + 1;
EXCEPTION
WHEN validation_failed THEN
  --dbms_output.put_line('Going to rollback --validation_failed GRP');
  ROLLBACK;
  IF out_err_code = -325 THEN
    -- "-4" means input min/esn not active
    --so return points for inactive min/esn
    --find the brand for inactive min/esn
    SELECT MAX(pn.part_num2bus_org)
    INTO lv_bus_org
    FROM table_site_part tsp,
      table_part_inst pi,
      table_mod_level ml,
      table_part_num pn
    WHERE 1                     =1
    AND ( (in_key               = 'ESN'
    AND tsp.x_service_id        = in_value )
    OR (in_key                  = 'MIN'
    AND tsp.x_min               = in_value ) )
    AND pi.part_serial_no       = tsp.x_service_id
    AND pi.x_domain             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND tsp.part_status
      || '' != 'Active'
    AND tsp.x_min NOT LIKE 'T%' ;
    BEGIN
      SELECT NVL(acc.total_points,0),
        acc.subscriber_uid,
        acc.x_expiry_date
      INTO out_total_points,
        out_subscriber_id,
        lv_expiry_date
      FROM table_x_point_account acc
      WHERE 1                   = 1
      AND ( (in_key             = 'MIN'
      AND acc.x_min             = in_value)
      OR (in_key                = 'ESN'
      AND acc.x_esn             = in_value) )
      AND acc.x_points_category = in_point_category
      AND acc.account_status    = 'ACTIVE'
      AND acc.bus_org_objid     = lv_bus_org;
      IF (lv_expiry_date       IS NOT NULL AND lv_expiry_date < sysdate) THEN
        out_total_points       := 0;
        out_subscriber_id      := NULL;
      END IF;
      --out_amount := 0;
      out_err_code := 0;
      out_err_msg  := 'SUCCESS';
    EXCEPTION
    WHEN OTHERS THEN
      out_total_points := 0;
      --out_amount := 0;
      out_subscriber_id := NULL;
      out_err_code      := -11;
      out_err_msg       := 'No Points for '||in_key || '='|| in_value ;
      /*
      out_err_msg := 'Points not found for '||in_key
      || '='|| in_value
      || ' having Brand='||lv_bus_org
      || '. Steps Completed='|| lv_steps_completed;
      */
      /*
      sa.ota_util_pkg.err_log (
      p_action => 'validation_failed',
      p_error_date => sysdate,
      p_key => null,
      p_program_name => 'P_GET_REWARD_POINTS',
      p_error_text => 'out_err_code='||out_err_code
      ||', out_err_msg='|| out_err_msg);
      */
    END;
  ELSE
    out_total_points := 0;
    --out_amount := 0;
  END IF;
WHEN OTHERS THEN
  --dbms_output.put_line('Going to rollback --catch all GRP');
  ROLLBACK;
  out_total_points := 0;
  --out_amount := 0;
  out_subscriber_id := NULL;
  out_err_code      := -99;
  out_err_msg       := 'p_get_reward_points FAILURE...lv_steps_completed='||lv_steps_completed ||' ERR=' || SUBSTR(sqlerrm,1,500);
  sa.ota_util_pkg.err_log ( p_action => 'Got OTHERS exception ..', p_error_date => sysdate, p_key => 'P_GET_REWARD_POINTS', p_program_name => 'P_GET_REWARD_POINTS', p_error_text => in_key || '='|| in_value || '. Out_err_code='||out_err_code || ', Out_err_msg='|| out_err_msg );
END p_get_reward_points ;
PROCEDURE p_compensate_reward_points(
    in_key               IN VARCHAR2,
    in_value             IN VARCHAR2,
    in_points            IN NUMBER,
    in_points_category   IN VARCHAR2 DEFAULT 'REWARD_POINTS',
    in_points_action     IN VARCHAR2,
    in_user_objid        IN NUMBER,
    in_compensate_reason IN VARCHAR2,
    out_total_points OUT NUMBER,
    inout_transaction_id IN OUT NUMBER,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
  /*
  P_COMPENSATE_REWARD_POINTS
  This procedure will update the reward points for input MIN
  and provides output as total points available
  Input
  IN_KEY = can be ESN or MIN
  IN_VALUE = value of esn or min
  IN_POINTS = points to compensate
  IN_POINT_CATEGORY = REWARD / LOYALTY / BONUS
  IN_POINTS_ACTION = how to compensate the points - it can be "ADD" / "DEDUCT"
  IN_USER_OBJID = the TAS user which calls this procedure to compensate the points for customer
  IN_COMPENSATE_REASON = description explaining why the points are compensated
  Output
  out_total_points = total points available
  OUT_AMOUNT = money equal to the total points
  OUT_TRANSACTION_ID = transaction id generated for this points compensation transaction
  OUT_ERR_CODE = 0 if success ; else error code
  OUT_ERR_MSG = SUCCESS or error message
  */
  lv_sign           INTEGER := 1;
  validation_failed EXCEPTION;
  rec_esn_min cur_esn_min_dtl%rowtype;
  lv_points            NUMBER;
  lv_point_trans_objid NUMBER;
  lv_points_brand      NUMBER;
  lv_count             INTEGER;
  lv_steps_completed   INTEGER := 0;
type typ_tab_valid_points
IS
  TABLE OF NUMBER;
  tab_valid_points typ_tab_valid_points;
  lv_invalid_points_error  VARCHAR2(1000);
  lv_current_point_account NUMBER;
  lv_current_point_brand   NUMBER;
  CURSOR cur_point_trans (in_objid IN NUMBER)
  IS
    SELECT pt.* ,
      tb.x_status AS benefit_status ,
      tb.objid    AS benefit_objid
    FROM table_x_point_trans pt ,
      table_x_benefits tb
    WHERE 1                    =1
    AND pt.objid               = in_objid
    AND pt.point_trans2benefit = tb.objid ;
  rec_point_trans cur_point_trans%rowtype;
BEGIN
  ---dbms_output.put_line ('*** lv_steps_completed=' || lv_steps_completed);
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  IF NVL(in_key,'~') NOT IN ('MIN', 'ESN') THEN
    out_err_code :=       -311;
    out_err_msg  := 'Input Key should be MIN or ESN' ;
    raise validation_failed;
  END IF;
  IF NVL(in_points_action,'~') NOT IN ('ADD', 'DEDUCT', 'CONSUMED') THEN
    out_err_code :=                 -311;
    out_err_msg  := 'Input action type should be "ADD" / "DEDUCT" ';
    raise validation_failed;
  END IF;
  IF NVL(in_points_category,'~') NOT IN (lc_point_category_reward) THEN
    out_err_code :=                   -311;
    out_err_msg  := 'Input point category should be "'|| lc_point_category_reward || '" ';
    raise validation_failed;
  END IF;
  IF in_value    IS NULL THEN
    out_err_code := -311;
    out_err_msg  := 'Input key is ' || in_key || ' ; it should not have NULL value' ;
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  OPEN cur_esn_min_dtl (in_key, in_value);
  FETCH cur_esn_min_dtl INTO rec_esn_min ;
  CLOSE cur_esn_min_dtl;
  IF rec_esn_min.x_min IS NULL THEN
    out_err_code       := -332;
    out_err_msg        := 'Input ' || in_key || ' not found or is not active' ;
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  SELECT COUNT(1)
  INTO lv_count
  FROM x_reward_point_values rpv
  WHERE 1                  =1
  AND rpv.bus_org_objid    = rec_esn_min.bus_org_objid
  AND rpv.x_point_category = lc_point_category_reward ;
  IF NVL(lv_count,0)       = 0 THEN
    out_err_code          := -333;
    out_err_msg           := 'Input ' || in_key || '=' || in_value || ' is from ' || rec_esn_min.bus_org_objid || ' and it Does not have eligible reward points at this time';
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  --verify points that can be earned by input min/esn
  BEGIN
    tab_valid_points := NULL;
    SELECT DISTINCT NVL(mv.fea_value ,0) bulk collect
    INTO tab_valid_points
    FROM adfcrm_serv_plan_feat_matview mv
    WHERE mv.fea_name        = lc_point_category_reward
    AND NVL(mv.fea_value,0) <> 0;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END ;
  lv_steps_completed              := lv_steps_completed + 1;
  lv_points                       := 0;
  IF NVL(tab_valid_points.count,0) = 0 THEN
    out_err_code                  := -9;
    out_err_msg                   := 'No Points available at this time.';
    raise validation_failed;
  ELSE
    lv_invalid_points_error := NULL;
    FOR i IN 1..tab_valid_points.count
    LOOP
      IF in_points               = tab_valid_points(i) THEN
        lv_points               := tab_valid_points(i);
        lv_invalid_points_error := NULL;
        EXIT;
      ELSE
        lv_invalid_points_error := lv_invalid_points_error || ', '|| tab_valid_points(i);
      END IF;
    END LOOP;
  END IF;
  ---dbms_output.put_line ('### lv_invalid_points_error=' || lv_invalid_points_error);
  --check input points are equal to points offered by service plan
  IF (lv_points         = in_points ) AND NVL(lv_points,0) > 0 THEN
    IF in_points_action = 'ADD' THEN
      lv_sign          := 1;
    elsif in_points_action IN ('DEDUCT', 'CONSUMED') THEN
      lv_sign :=            -1;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    lv_points          := lv_points          * lv_sign ;
  ELSE
    out_err_code := -334;
    out_err_msg  := 'Points allowed to compensate are ' || SUBSTR(lv_invalid_points_error,2);
    raise validation_failed;
  END IF;
  lv_steps_completed   := lv_steps_completed + 1;
  IF NVL(lv_points, 0) <> 0 THEN ---and inout_transaction_id is not null then
    --dbms_output.put_line ('Invoking p_check_point_account ....................');
    --check whether point_account exists or no
    --if not then create point_account
    p_check_point_account ( in_min => rec_esn_min.x_min, in_esn => rec_esn_min.x_esn, out_account_objid => lv_current_point_account, out_account_bus_org => lv_current_point_brand );
    lv_steps_completed          := lv_steps_completed + 1;
    IF lv_current_point_account IS NULL THEN
      ---dbms_output.put_line (' heheheheh ');
      raise validation_failed;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    /* cr32367 changes starts 4/14/2015 */
    IF inout_transaction_id IS NOT NULL AND in_points_action IN ('DEDUCT', 'CONSUMED') THEN
      OPEN cur_point_trans (inout_transaction_id);
      FETCH cur_point_trans INTO rec_point_trans;
      CLOSE cur_point_trans;
      IF rec_point_trans.benefit_objid IS NOT NULL THEN
        ---and rec_point_trans.benefit_status = '961' then
        --check here the benefit points are already added back.
        --if points are already added then dont add them again
        BEGIN
          UPDATE table_x_benefits
          SET x_status = '967' --967=benefit removed
            ,
            x_update_date = sysdate ,
            x_notes       = 'benefits have been removed since Transaction [ TABLE_X_POINT_TRANS.OBJID ='
            || inout_transaction_id
            || '] is refunded'
          WHERE objid   = rec_point_trans.benefit_objid
          AND x_status <> '967' --check benefit is NOT already removed
            ;
          --dbms_output.put_line ('benefit remove update rwocount=' || sql%rowcount);
          --if sql%rowcount = 0 that means no record updated means benefits are already removed
          --and in that case do not insert the points again
          --if benefit is removed successfully by above update sql then only add the points back
          IF sql%rowcount > 0 THEN
            --revert the points back (those points which were converted to benefit)
            INSERT
            INTO table_X_point_trans
            SELECT seq_x_point_trans.nextval --objid
              ,
              sysdate --X_TRANS_DATE
              ,
              x_min ,
              x_esn ,
              -1 * (x_points) --X_POINTS
              ,
              x_points_category ,
              'ADD' --X_POINTS_ACTION
              ,
              'Points added back because of the benefits associated are removed [TABLE_X_BENEFITS.OBJID='
              ||rec_point_trans.benefit_objid
              || ']' ---POINTS_ACTION_REASON
              ,
              point_trans2ref_table_objid ,
              ref_table_name ,
              point_trans2service_plan ,
              point_trans2point_account ,
              NULL ---point_trans2purchase_objid
              ,
              'COMPENSATE' ---purchase_table_name
              ,
              point_trans2site_part ,
              NULL ----dont set any benefit-id here; this refund can be used to get new benefit
              ,
              'Restored from Benefit'
            FROM table_x_point_trans
            WHERE 1                         =1
            AND point_trans2point_account   = rec_point_trans.POINT_TRANS2POINT_ACCOUNT
            AND ref_table_name              = 'TABLE_X_BENEFITS'
            AND point_trans2ref_table_objid = rec_point_trans.benefit_objid
            AND x_points_action             = 'CONVERT' ;
            --dbms_output.put_line ('beenfits removed');
          END IF;
        END;
      END IF;
    END IF;
    /* cr32367 changes ends */
    lv_point_trans_objid := sa.seq_x_point_trans.nextval ;
    INSERT
    INTO table_x_point_trans
      (
        objid,
        x_trans_date,
        x_min,
        x_esn,
        x_points,
        x_points_category,
        x_points_action,
        points_action_reason,
        point_trans2ref_table_objid,
        ref_table_name,
        point_trans2service_plan,
        point_trans2point_account,
        point_trans2purchase_objid,
        purchase_table_name,
        point_trans2site_part,
        point_trans2benefit,
        point_display_reason
      )
      VALUES
      (
        lv_point_trans_objid,
        sysdate,
        rec_esn_min.x_min,
        rec_esn_min.x_esn,
        lv_points,
        in_points_category,
        in_points_action,
        SUBSTR(in_compensate_reason,1,2000),
        in_user_objid,
        'TABLE_USER',
        (SELECT MIN(service_plan_objid)
        FROM x_reward_point_values rpv
        WHERE 1                  =1
        AND rpv.X_POINT_CATEGORY = lc_point_category_reward
        AND rpv.BUS_ORG_OBJID    = lv_current_point_brand
        AND rpv.X_UNIT_POINTS    = ABS(lv_points)
        ),
        lv_current_point_account,
        NULL,
        'COMPENSATE',
        rec_esn_min.site_part_objid,
        NULL, --initialize benefit as null
        'Agent provided: '
        || SUBSTR(in_compensate_reason,1,1980)
      );
    lv_steps_completed := lv_steps_completed + 1;
    --calculate the total points that this min has earned till date
    p_calculate_points (rec_esn_min.x_min, out_err_code, out_err_msg);
    IF out_err_code != 0 THEN
      raise validation_failed;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    COMMIT;
    --check if total points have reached the maximum value
    --and may be eligible to create a reward benefit
    --03/24/2015 CR32367
    ----dbms_output.put_line ('CWC in min=' || rec_esn_min.x_min) ;
    ----raise validation_failed;
    --dbms_output.put_line ('commit done...checking to create benefits');
    sa.reward_benefits_n_vouchers_pkg.p_create_reward_benefits ( in_min => rec_esn_min.x_min ,out_err_code => out_err_code ,out_err_msg => out_err_msg );
    IF out_err_code = 0 THEN
      COMMIT;
    ELSE
      --DBMS_OUTPUT.PUT_LINE('ERROR...Could not refresh benefits ='
      --|| out_err_code || ' ' || out_err_msg);
      raise no_data_found;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    BEGIN
      SELECT acc.total_points,
        acc.bus_org_objid
      INTO out_total_points,
        lv_points_brand
      FROM table_x_point_account acc
      WHERE objid = lv_current_point_account;
    EXCEPTION
    WHEN no_data_found THEN
      out_total_points := 0;
    END;
    lv_steps_completed := lv_steps_completed + 1;
    --if all goes well, then return the transaction objid which generated the points
    inout_transaction_id := lv_point_trans_objid;
    lv_steps_completed   := lv_steps_completed + 1;
    -- dbms_output.put_line ('*** lv_steps_completed=' || lv_steps_completed);
  END IF;
EXCEPTION
WHEN validation_failed THEN
  ROLLBACK;
  out_total_points := 0;
WHEN OTHERS THEN
  ROLLBACK;
  out_err_code := -99;
  out_err_msg  := 'FAILURE..steps='|| lv_steps_completed ||', ERR=' || SUBSTR(sqlerrm,1,100);
  sa.ota_util_pkg.err_log ( p_action => 'P_COMPENSATE_REWARD_POINTS', p_error_date => sysdate, p_key => NULL, p_program_name => 'P_COMPENSATE_REWARD_POINTS', p_error_text => 'out_err_code = '||out_err_code || ', out_err_msg='||out_err_msg);
END p_compensate_reward_points ;
/*27-APR-2015 CR32367
Vedanarayanan S
Overloading the compensate reward points procedure to add additional input
parameter "service plan objid"
*/
PROCEDURE p_compensate_reward_points(
    in_key                IN VARCHAR2,
    in_value              IN VARCHAR2,
    in_points             IN NUMBER,
    in_points_category    IN VARCHAR2 DEFAULT 'REWARD_POINTS',
    in_points_action      IN VARCHAR2,
    in_user_objid         IN NUMBER,
    in_compensate_reason  IN VARCHAR2,
    in_service_plan_objid IN NUMBER,
    out_total_points OUT NUMBER,
    inout_transaction_id IN OUT NUMBER,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
  /*
  P_COMPENSATE_REWARD_POINTS
  This procedure will update the reward points for input MIN
  and provides output as total points available
  Input
  IN_KEY = can be ESN or MIN
  IN_VALUE = value of esn or min
  IN_POINTS = points to compensate
  IN_POINT_CATEGORY = REWARD / LOYALTY / BONUS
  IN_POINTS_ACTION = how to compensate the points - it can be "ADD" / "DEDUCT"
  IN_USER_OBJID = the TAS user which calls this procedure to compensate the points for customer
  IN_COMPENSATE_REASON = description explaining why the points are compensated
  Output
  out_total_points = total points available
  OUT_AMOUNT = money equal to the total points
  OUT_TRANSACTION_ID = transaction id generated for this points compensation transaction
  OUT_ERR_CODE = 0 if success ; else error code
  OUT_ERR_MSG = SUCCESS or error message
  */
  lv_sign           INTEGER := 1;
  validation_failed EXCEPTION;
  rec_esn_min cur_esn_min_dtl%rowtype;
  lv_points               NUMBER;
  lv_point_trans_objid    NUMBER;
  lv_points_brand         NUMBER;
  lv_count                INTEGER;
  lv_steps_completed      INTEGER     := 0;
  lv_point_category_bonus VARCHAR2(40):= 'BONUS_POINTS'; --CR35343
type typ_tab_valid_points
IS
  TABLE OF NUMBER;
  tab_valid_points typ_tab_valid_points;
  lv_invalid_points_error  VARCHAR2(1000);
  lv_current_point_account NUMBER;
  lv_current_point_brand   NUMBER;
  lv_splan_points          NUMBER;    -- CR32367 4/30/15 VS
  lv_sp_in_points          NUMBER;    -- CR32367 4/30/15 VS
  lv_benefit_cnt           NUMBER;    -- CR32367 5/21/15 VS
  lv_benefit_id            NUMBER;    -- CR32367 5/21/15 VS
  e_multi_benefit          EXCEPTION; -- CR32367 5/21/15 VS
  lv_subid                 VARCHAR2(40);
  lv_err_code              NUMBER;
  lv_pa_objid              NUMBER;
  lv_err_msg               VARCHAR2(2000);
  lv_tot_pnts              NUMBER;
  lv_recalc_total          NUMBER;
  lv_pts_objid             NUMBER;
  CURSOR cur_point_trans (in_objid IN NUMBER)
  IS
    SELECT pt.* ,
      tb.x_status AS benefit_status ,
      tb.objid    AS benefit_objid
    FROM table_x_point_trans pt ,
      table_x_benefits tb
    WHERE 1                    =1
    AND pt.objid               = in_objid
    AND pt.point_trans2benefit = tb.objid ;
  rec_point_trans cur_point_trans%rowtype;
BEGIN
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  IF NVL(in_key,'~') NOT IN ('MIN', 'ESN') THEN
    out_err_code :=       -311;
    out_err_msg  := 'Input Key should be MIN or ESN' ;
    raise validation_failed;
  END IF;
  IF NVL(in_points_action,'~') NOT IN ('ADD', 'DEDUCT', 'CONSUMED') THEN
    out_err_code :=                 -311;
    out_err_msg  := 'Input action type should be "ADD" / "DEDUCT" ';
    raise validation_failed;
  END IF;
  --CR35343 adding the lv_point_category_bonus check
  IF NVL(in_points_category,'~') NOT IN (lc_point_category_reward, lv_point_category_bonus) THEN
    out_err_code :=                   -311;
    out_err_msg  := 'Input point category should be "'|| lc_point_category_reward || '" ';
    raise validation_failed;
  END IF;
  IF in_value    IS NULL THEN
    out_err_code := -311;
    out_err_msg  := 'Input key is ' || in_key || ' ; it should not have NULL value' ;
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  OPEN cur_esn_min_dtl (in_key, in_value);
  FETCH cur_esn_min_dtl INTO rec_esn_min ;
  CLOSE cur_esn_min_dtl;
  IF rec_esn_min.x_min IS NULL THEN
    out_err_code       := -332;
    out_err_msg        := 'Input ' || in_key || ' not found or is not active' ;
    raise validation_failed;
  END IF;
  IF (in_service_plan_objid IS NULL AND in_points IS NULL) THEN
    out_err_code            := -332;
    out_err_msg             := 'Both service_plan_objid and points cannot be null' ;
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  SELECT COUNT(1)
  INTO lv_count
  FROM x_reward_point_values rpv
  WHERE 1                  =1
  AND rpv.bus_org_objid    = rec_esn_min.bus_org_objid
  AND rpv.x_point_category = lc_point_category_reward ;
  IF NVL(lv_count,0)       = 0 THEN
    out_err_code          := -333;
    out_err_msg           := 'Input ' || in_key || '=' || in_value || ' is from ' || rec_esn_min.bus_org_objid || ' and it Does not have eligible reward points at this time';
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  /***************************************************************
  CR32367 4/30/15 VS
  Fetching the reward points based on the service plan objid if
  its passed in the input. if in_points value is passed that will
  be used, if not service plan based points will be used.
  ****************************************************************/
  IF (in_service_plan_objid IS NOT NULL) THEN
    BEGIN
      SELECT x_unit_points
      INTO lv_splan_points
      FROM x_reward_point_values
      WHERE service_plan_objid = in_service_plan_objid
      AND x_point_category     = lc_point_category_reward;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_code := -332;
      out_err_msg  := 'Service plan is not eligible for rewards' ;
      raise validation_failed;
    END;
  END IF ;
  IF lv_splan_points IS NOT NULL THEN
    lv_sp_in_points  := lv_splan_points;
  elsif in_points    IS NOT NULL THEN
    lv_sp_in_points  := in_points;
  ELSE
    lv_sp_in_points := lv_splan_points;
  END IF ;
  /*********************************************************************/
  --verify points that can be earned by input min/esn
  BEGIN
    SELECT DISTINCT NVL(mv.fea_value ,0) bulk collect
    INTO tab_valid_points
    FROM adfcrm_serv_plan_feat_matview mv
    WHERE mv.fea_name        = lc_point_category_reward
    AND NVL(mv.fea_value,0) <> 0;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END ;
  lv_steps_completed              := lv_steps_completed + 1;
  lv_points                       := 0;
  IF NVL(tab_valid_points.count,0) = 0 THEN
    out_err_code                  := -9;
    out_err_msg                   := 'No Points available at this time.';
    raise validation_failed;
  ELSE
    lv_invalid_points_error := NULL;
    FOR i IN 1..tab_valid_points.count
    LOOP
      IF lv_sp_in_points         = tab_valid_points(i) THEN
        lv_points               := tab_valid_points(i);
        lv_invalid_points_error := NULL;
        EXIT;
      ELSE
        lv_invalid_points_error := lv_invalid_points_error || ', '|| tab_valid_points(i);
      END IF;
    END LOOP;
  END IF;
  --check input points are equal to points offered by service plan
  IF (in_points_category = lc_point_category_reward) --CR35343
    THEN
    IF (lv_points         = lv_sp_in_points ) AND NVL(lv_points,0) > 0 THEN
      IF in_points_action = 'ADD' THEN
        lv_sign          := 1;
      elsif in_points_action IN ('DEDUCT', 'CONSUMED') THEN
        lv_sign :=            -1;
      END IF;
      lv_steps_completed := lv_steps_completed + 1;
      lv_points          := lv_points          * lv_sign ;
    ELSE
      out_err_code := -334;
      out_err_msg  := 'Points allowed to compensate are ' || SUBSTR(lv_invalid_points_error,2);
      raise validation_failed;
    END IF;
    /*CR35343: 070815: adding the following to handle bonus_points */
  elsif (in_points_category = 'BONUS_POINTS') THEN
    IF in_points_action     = 'ADD' THEN
      lv_sign              := 1;
    elsif in_points_action IN ('DEDUCT', 'CONSUMED') THEN
      lv_sign :=            -1;
    END IF;
    lv_points := lv_sign * lv_sp_in_points;
  END IF; --CR35343
  lv_steps_completed   := lv_steps_completed + 1;
  IF NVL(lv_points, 0) <> 0 THEN ---and inout_transaction_id is not null then
    --check whether point_account exists or no
    --if not then create point_account
    p_check_point_account ( in_min => rec_esn_min.x_min, in_esn => rec_esn_min.x_esn, out_account_objid => lv_current_point_account, out_account_bus_org => lv_current_point_brand );
    lv_steps_completed          := lv_steps_completed + 1;
    IF lv_current_point_account IS NULL THEN
      raise validation_failed;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    /* cr32367 changes starts 4/14/2015 */
    IF inout_transaction_id IS NOT NULL AND in_points_action IN ('DEDUCT', 'CONSUMED') THEN
      OPEN cur_point_trans (inout_transaction_id);
      FETCH cur_point_trans INTO rec_point_trans;
      CLOSE cur_point_trans;
      IF rec_point_trans.benefit_objid IS NOT NULL THEN
        ---and rec_point_trans.benefit_status = '961' then
        --check here the benefit points are already added back.
        --if points are already added then dont add them again
        BEGIN
          UPDATE table_x_benefits
          SET x_status = '967' --967=benefit removed
            ,
            x_update_date = sysdate ,
            x_notes       = 'benefits have been removed since Transaction [ TABLE_X_POINT_TRANS.OBJID ='
            || inout_transaction_id
            || '] is refunded'
          WHERE objid   = rec_point_trans.benefit_objid
          AND x_status <> '967' --check benefit is NOT already removed
            ;
          --if sql%rowcount = 0 that means no record updated means benefits are already removed
          --and in that case do not insert the points again
          --if benefit is removed successfully by above update sql then only add the points back
          IF sql%rowcount > 0 THEN
            --revert the points back (those points which were converted to benefit)
            INSERT
            INTO table_X_point_trans
            SELECT seq_x_point_trans.nextval --objid
              ,
              sysdate --X_TRANS_DATE
              ,
              x_min ,
              x_esn ,
              -1 * (x_points) --X_POINTS
              ,
              x_points_category ,
              'ADD' --X_POINTS_ACTION
              ,
              'Points added back because of the benefits associated are removed [TABLE_X_BENEFITS.OBJID='
              ||rec_point_trans.benefit_objid
              || ']' ---POINTS_ACTION_REASON
              ,
              point_trans2ref_table_objid ,
              ref_table_name ,
              point_trans2service_plan ,
              point_trans2point_account ,
              NULL ---point_trans2purchase_objid
              ,
              'COMPENSATE' ---purchase_table_name
              ,
              point_trans2site_part ,
              NULL ----dont set any benefit-id here; this refund can be used to get new benefit
              ,
              'Restored from Benefit'
            FROM table_x_point_trans
            WHERE 1                         =1
            AND point_trans2point_account   = rec_point_trans.POINT_TRANS2POINT_ACCOUNT
            AND ref_table_name              = 'TABLE_X_BENEFITS'
            AND point_trans2ref_table_objid = rec_point_trans.benefit_objid
            AND x_points_action             = 'CONVERT' ;
          END IF;
        END;
      END IF;
    END IF;
    /*VS:05212015:CR32367:SQA1917: TAS is not yet equipped to pass the point
    transaction id for which the deduct/consumed transaction takes place.
    So when deduct/consumed transaction is made and there is just one benefit
    associated with the user at the point time that benefit will be removed
    If more than one benefit is available then there is no way to tell which
    one gets removed so procedure will return an exception and not process
    the point removal. When TAS passes the point transaction ID stored proc
    will be able to decide teh rigt benefit to remove in all case and should
    work as expected*/
    IF (inout_transaction_id IS NULL AND in_points_action IN ('DEDUCT', 'CONSUMED') ) THEN
      BEGIN
        SELECT total_cnt,
          benefit_objid,
          pa_objid
        INTO lv_benefit_cnt,
          lv_benefit_id,
          lv_pa_objid
        FROM
          (SELECT COUNT(*) over (partition BY xb.x_benefit_owner_value ) total_cnt,
            xb.objid benefit_objid ,
            pa.objid pa_objid
          FROM table_x_benefits xb ,
            table_x_point_account pa
          WHERE pa.x_min              = rec_esn_min.x_min
          AND pa.x_esn                = rec_esn_min.x_esn
          AND pa.account_status       = 'ACTIVE'
          AND pa.subscriber_uid       = xb.x_benefit_owner_value
          AND xb.x_benefit_owner_type = 'SID'
          AND xb.x_status             = '961'
          AND (xb.x_expiry_date      IS NULL
          OR xb.x_expiry_date         > sysdate )
          )
        WHERE rownum < 2 ;
        SELECT pa.total_points
        INTO lv_tot_pnts
        FROM table_x_point_account pa
        WHERE pa.x_min       = rec_esn_min.x_min
        AND pa.x_esn         = rec_esn_min.x_esn
        AND pa.account_status= 'ACTIVE' ;
      EXCEPTION
      WHEN OTHERS THEN
        -- when any exception in above select set the the count to 0.
        lv_benefit_cnt := 0;
        lv_tot_pnts    := 0;
        lv_benefit_id  := NULL;
      END ;
      IF (lv_benefit_cnt = 1 AND lv_tot_pnts < ABS(lv_points))--SQA#1917 052715
        THEN
        /*remove the benefit only if its just teh one benefit
        associated to account at this point.*/
        UPDATE table_x_benefits
        SET x_status = '967' --967=benefit removed
          ,
          x_update_date = sysdate ,
          x_notes       = 'Benefit has been removed since point transaction was refunded'
        WHERE objid     = lv_benefit_id
        AND x_status   <> '967' ;
        /*Add the reward points back to the account that were
        converted to benefit that got removed. The deduction of points will be done in the next block*/
        IF sql%rowcount > 0 THEN
          lv_pts_objid :=seq_x_point_trans.nextval;
          --revert the points back (those points which were converted to benefit)
          /* CR35343: changed the X_POINTS_ACTION to CONVERT from ADD */
          INSERT
          INTO table_x_point_trans
          SELECT lv_pts_objid --objid
            ,
            sysdate --X_TRANS_DATE
            ,
            x_min ,
            x_esn ,
            -1 * (x_points) --X_POINTS
            ,
            x_points_category ,
            'CONVERT' --X_POINTS_ACTION -- CR35343:070215 changing to CONVERT from ADD
            ,
            'Points added back because of the benefits associated are removed [TABLE_X_BENEFITS.OBJID='
            ||lv_benefit_id
            ||']' ---POINTS_ACTION_REASON
            ,
            point_trans2ref_table_objid ,
            ref_table_name ,
            point_trans2service_plan ,
            point_trans2point_account ,
            NULL ---point_trans2purchase_objid
            ,
            'COMPENSATE' ---purchase_table_name
            ,
            point_trans2site_part ,
            NULL ----dont set any benefit-id here; this refund can be used to get new benefit
            ,
            'Restored from Benefit'
          FROM table_x_point_trans
          WHERE 1                         =1
          AND point_trans2point_account   = lv_pa_objid
          AND ref_table_name              = 'TABLE_X_BENEFITS'
          AND point_trans2ref_table_objid = lv_benefit_id
          AND x_points_action             = 'CONVERT' ;
          /*CR35343 change to address QC2358. Get the conversion point added to point
          trans table using teh point trans objid inserted in teh above step.
          */
          SELECT (x_points)
          INTO lv_recalc_total
          FROM table_x_point_trans
          WHERE 1                       =1
          AND point_trans2point_account = lv_pa_objid
          AND objid                     = lv_pts_objid;
          /* select
          sum(trans.x_points) as calc_points
          into lv_recalc_total
          from table_x_point_trans trans,
          table_x_point_account acc
          where 1 = 1
          --and trans.x_min = in_min -- min null check removed to help performance 060215
          and ( acc.objid = trans.point_trans2point_account)
          and ( acc.account_status = 'ACTIVE' )
          and trans.x_points_action in ('ADD', 'DEDUCT', 'REFUND', 'CONSUMED')
          and trans.point_trans2benefit = lv_benefit_id
          and acc.objid = lv_pa_objid;
          */
          /*CR35343 change to address QC2358*/
          UPDATE table_x_point_trans xpt
          SET xpt.POINT_TRANS2BENEFIT       = NULL
          WHERE xpt.POINT_TRANS2BENEFIT     = lv_benefit_id
          AND xpt.POINT_TRANS2POINT_ACCOUNT = lv_pa_objid
            --QC4142 08/13/2015
          AND xpt.x_points        <> -18
          AND xpt.x_points_action <> 'CONVERT';
          /*CR35343 change to address QC2358*/
          UPDATE table_x_point_account acc
          SET total_points = NVL(total_points,0) + NVL(lv_recalc_total, 0)
            --,x_last_calc_date = sysdate
          WHERE acc.objid    = lv_pa_objid
          AND account_status = 'ACTIVE';
        END IF;
      elsif lv_benefit_cnt > 1 THEN
        -- raise an exception to the application if there are more than one benefit and transaction id is not passed by the application
        out_err_code := -332;
        out_err_msg  := 'More than 1 benefit associated to user.Pass point id to deduct points' ;
        raise e_multi_benefit;
      END IF;
    END IF;
    /* cr32367 changes ends */
    lv_point_trans_objid := sa.seq_x_point_trans.nextval ;
    INSERT
    INTO table_x_point_trans
      (
        objid,
        x_trans_date,
        x_min,
        x_esn,
        x_points,
        x_points_category,
        x_points_action,
        points_action_reason,
        point_trans2ref_table_objid,
        ref_table_name,
        point_trans2service_plan,
        point_trans2point_account,
        point_trans2purchase_objid,
        purchase_table_name,
        point_trans2site_part,
        point_trans2benefit,
        point_display_reason
      )
      VALUES
      (
        lv_point_trans_objid,
        sysdate,
        rec_esn_min.x_min,
        rec_esn_min.x_esn,
        lv_points,
        in_points_category,
        in_points_action,
        SUBSTR(in_compensate_reason,1,2000),
        in_user_objid,
        'TABLE_USER',
        in_service_plan_objid,
        lv_current_point_account,
        NULL,
        DECODE (in_points_category ,'BONUS_POINTS','BONUS' ,'COMPENSATE') ,
        rec_esn_min.site_part_objid,
        NULL , --initialize benefit as null
        DECODE (in_points_category ,'BONUS_POINTS', SUBSTR(in_compensate_reason,1,1980) ,'Agent provided: '
        || SUBSTR(in_compensate_reason,1,1980) )
      );
    lv_steps_completed := lv_steps_completed + 1;
    --calculate the total points that this min has earned till date
    dbms_output.put_line ('calling p_calculate_points');
    p_calculate_points (rec_esn_min.x_min, out_err_code, out_err_msg);
    IF out_err_code != 0 THEN
      raise validation_failed;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    COMMIT;
    reward_benefits_n_vouchers_pkg.p_get_subscriber_id ( in_key => in_key ,in_value => in_value ,out_subscriber_id => lv_subid ,out_err_code => lv_err_code ,out_err_msg => lv_err_msg ) ;
    --check if total points have reached the maximum value
    --and may be eligible to create a reward benefit
    --03/24/2015 CR32367
    sa.reward_benefits_n_vouchers_pkg.p_create_reward_benefits ( in_min => rec_esn_min.x_min ,out_err_code => out_err_code ,out_err_msg => out_err_msg );
    IF out_err_code = 0 THEN
      COMMIT;
    ELSE
      raise no_data_found;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    /*CR32367:050915:SQA2010: TAS needs transaction points not total points
    so commenting the total point from below select and assigning the
    transaction point value to the output*/
    out_total_points := ABS(lv_points);
    BEGIN
      SELECT --acc.total_points,
        acc.bus_org_objid
      INTO --out_total_points,
        lv_points_brand
      FROM table_x_point_account acc
      WHERE objid = lv_current_point_account;
    EXCEPTION
    WHEN no_data_found THEN
      out_total_points := 0;
    END;
    lv_steps_completed := lv_steps_completed + 1;
    --if all goes well, then return the transaction objid which generated the points
    inout_transaction_id := lv_point_trans_objid;
    lv_steps_completed   := lv_steps_completed + 1;
  END IF;
EXCEPTION
WHEN validation_failed THEN
  ROLLBACK;
  out_total_points := 0;
WHEN e_multi_benefit THEN
  ROLLBACK;
  out_total_points := 0;
WHEN OTHERS THEN
  ROLLBACK;
  out_err_code := -99;
  out_err_msg  := 'FAILURE..steps='|| lv_steps_completed ||', ERR=' || SUBSTR(sqlerrm,1,100);
  sa.ota_util_pkg.err_log ( p_action => 'P_COMPENSATE_REWARD_POINTS', p_error_date => sysdate, p_key => NULL, p_program_name => 'P_COMPENSATE_REWARD_POINTS', p_error_text => 'out_err_code = '||out_err_code || ', out_err_msg='||out_err_msg);
END p_compensate_reward_points ;
PROCEDURE p_compensate_bonus_points_ia(
    in_key                IN VARCHAR2,
    in_value              IN VARCHAR2,
    in_points             IN NUMBER,
    in_points_category    IN VARCHAR2 DEFAULT 'BONUS_POINTS',
    in_points_action      IN VARCHAR2,
    in_user_objid         IN NUMBER,
    in_compensate_reason  IN VARCHAR2,
    in_service_plan_objid IN NUMBER,
    in_bonus_objid        IN NUMBER,
    out_x_min OUT VARCHAR2,
    out_total_points OUT NUMBER,
    inout_transaction_id IN OUT NUMBER,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
  /*
  P_COMPENSATE_REWARD_POINTS
  This procedure will update the reward points for input MIN
  and provides output as total points available
  Input
  IN_KEY = can be ESN or MIN
  IN_VALUE = value of esn or min
  IN_POINTS = points to compensate
  IN_POINT_CATEGORY = REWARD / LOYALTY / BONUS
  IN_POINTS_ACTION = how to compensate the points - it can be "ADD" / "DEDUCT"
  IN_USER_OBJID = the TAS user which calls this procedure to compensate the points for customer
  IN_COMPENSATE_REASON = description explaining why the points are compensated
  Output
  out_total_points = total points available
  OUT_AMOUNT = money equal to the total points
  OUT_TRANSACTION_ID = transaction id generated for this points compensation transaction
  OUT_ERR_CODE = 0 if success ; else error code
  OUT_ERR_MSG = SUCCESS or error message
  */
  lv_sign           INTEGER := 1;
  validation_failed EXCEPTION;
  rec_esn_min cur_esn_min_dtl%rowtype;
  lv_points               NUMBER;
  lv_point_trans_objid    NUMBER;
  lv_points_brand         NUMBER;
  lv_count                INTEGER;
  lv_steps_completed      INTEGER     := 0;
  lv_point_category_bonus VARCHAR2(40):= 'BONUS_POINTS'; --CR35343
type typ_tab_valid_points
IS
  TABLE OF NUMBER;
  tab_valid_points typ_tab_valid_points;
  lv_invalid_points_error  VARCHAR2(1000);
  lv_current_point_account NUMBER;
  lv_current_point_brand   NUMBER;
  lv_splan_points          NUMBER;    -- CR32367 4/30/15 VS
  lv_sp_in_points          NUMBER;    -- CR32367 4/30/15 VS
  lv_benefit_cnt           NUMBER;    -- CR32367 5/21/15 VS
  lv_benefit_id            NUMBER;    -- CR32367 5/21/15 VS
  e_multi_benefit          EXCEPTION; -- CR32367 5/21/15 VS
  lv_subid                 VARCHAR2(40);
  lv_err_code              NUMBER;
  lv_pa_objid              NUMBER;
  lv_err_msg               VARCHAR2(2000);
  lv_tot_pnts              NUMBER;
  lv_recalc_total          NUMBER;
  lv_pts_objid             NUMBER;
  CURSOR cur_point_trans (in_objid IN NUMBER)
  IS
    SELECT pt.* ,
      tb.x_status AS benefit_status ,
      tb.objid    AS benefit_objid
    FROM table_x_point_trans pt ,
      table_x_benefits tb
    WHERE 1                    =1
    AND pt.objid               = in_objid
    AND pt.point_trans2benefit = tb.objid ;
  rec_point_trans cur_point_trans%rowtype;
BEGIN
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  IF NVL(in_key,'~') NOT IN ('MIN', 'ESN') THEN
    out_err_code :=       -311;
    out_err_msg  := 'Input Key should be MIN or ESN' ;
    raise validation_failed;
  END IF;
  IF NVL(in_points_action,'~') NOT IN ('ADD', 'DEDUCT', 'CONSUMED') THEN
    out_err_code :=                 -311;
    out_err_msg  := 'Input action type should be "ADD" / "DEDUCT" ';
    raise validation_failed;
  END IF;
  --CR35343 adding the lv_point_category_bonus check
  IF NVL(in_points_category,'~') NOT IN (lc_point_category_reward, lv_point_category_bonus) THEN
    out_err_code :=                   -311;
    out_err_msg  := 'Input point category should be "'|| lc_point_category_reward || '" ';
    raise validation_failed;
  END IF;
  IF in_value    IS NULL THEN
    out_err_code := -311;
    out_err_msg  := 'Input key is ' || in_key || ' ; it should not have NULL value' ;
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  OPEN cur_esn_min_dtl (in_key, in_value);
  FETCH cur_esn_min_dtl INTO rec_esn_min ;
  CLOSE cur_esn_min_dtl;
  IF rec_esn_min.x_min IS NULL THEN
    out_err_code       := -332;
    out_err_msg        := 'Input ' || in_key || ' not found or is not active' ;
    raise validation_failed;
  END IF;
  IF (in_service_plan_objid IS NULL AND in_points IS NULL) THEN
    out_err_code            := -332;
    out_err_msg             := 'Both service_plan_objid and points cannot be null' ;
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  SELECT COUNT(1)
  INTO lv_count
  FROM x_reward_point_values rpv
  WHERE 1                  =1
  AND rpv.bus_org_objid    = rec_esn_min.bus_org_objid
  AND rpv.x_point_category = lc_point_category_reward ;
  IF NVL(lv_count,0)       = 0 THEN
    out_err_code          := -333;
    out_err_msg           := 'Input ' || in_key || '=' || in_value || ' is from ' || rec_esn_min.bus_org_objid || ' and it Does not have eligible reward points at this time';
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  /***************************************************************
  CR32367 4/30/15 VS
  Fetching the reward points based on the service plan objid if
  its passed in the input. if in_points value is passed that will
  be used, if not service plan based points will be used.
  ****************************************************************/
  IF (in_service_plan_objid IS NOT NULL) THEN
    BEGIN
      SELECT x_unit_points
      INTO lv_splan_points
      FROM x_reward_point_values
      WHERE service_plan_objid = in_service_plan_objid
      AND x_point_category     = lc_point_category_reward;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_code := -332;
      out_err_msg  := 'Service plan is not eligible for rewards' ;
      raise validation_failed;
    END;
  END IF ;
  IF lv_splan_points IS NOT NULL THEN
    lv_sp_in_points  := lv_splan_points;
  elsif in_points    IS NOT NULL THEN
    lv_sp_in_points  := in_points;
  ELSE
    lv_sp_in_points := lv_splan_points;
  END IF ;
  /*********************************************************************/
  --verify points that can be earned by input min/esn
  BEGIN
    SELECT DISTINCT NVL(mv.fea_value ,0) bulk collect
    INTO tab_valid_points
    FROM adfcrm_serv_plan_feat_matview mv
    WHERE mv.fea_name        = lc_point_category_reward
    AND NVL(mv.fea_value,0) <> 0;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END ;
  lv_steps_completed              := lv_steps_completed + 1;
  lv_points                       := 0;
  IF NVL(tab_valid_points.count,0) = 0 THEN
    out_err_code                  := -9;
    out_err_msg                   := 'No Points available at this time.';
    raise validation_failed;
  ELSE
    lv_invalid_points_error := NULL;
    FOR i IN 1..tab_valid_points.count
    LOOP
      IF lv_sp_in_points         = tab_valid_points(i) THEN
        lv_points               := tab_valid_points(i);
        lv_invalid_points_error := NULL;
        EXIT;
      ELSE
        lv_invalid_points_error := lv_invalid_points_error || ', '|| tab_valid_points(i);
      END IF;
    END LOOP;
  END IF;
  --check input points are equal to points offered by service plan
  IF (in_points_category = lc_point_category_reward) --CR35343
    THEN
    IF (lv_points         = lv_sp_in_points ) AND NVL(lv_points,0) > 0 THEN
      IF in_points_action = 'ADD' THEN
        lv_sign          := 1;
      elsif in_points_action IN ('DEDUCT', 'CONSUMED') THEN
        lv_sign :=            -1;
      END IF;
      lv_steps_completed := lv_steps_completed + 1;
      lv_points          := lv_points          * lv_sign ;
    ELSE
      out_err_code := -334;
      out_err_msg  := 'Points allowed to compensate are ' || SUBSTR(lv_invalid_points_error,2);
      raise validation_failed;
    END IF;
    /*CR35343: 070815: adding the following to handle bonus_points */
  elsif (in_points_category = 'BONUS_POINTS') THEN
    IF in_points_action     = 'ADD' THEN
      lv_sign              := 1;
    elsif in_points_action IN ('DEDUCT', 'CONSUMED') THEN
      lv_sign :=            -1;
    END IF;
    lv_points := lv_sign * lv_sp_in_points;
  END IF; --CR35343
  lv_steps_completed   := lv_steps_completed + 1;
  IF NVL(lv_points, 0) <> 0 THEN ---and inout_transaction_id is not null then
    --check whether point_account exists or no
    --if not then create point_account
    p_check_point_account ( in_min => rec_esn_min.x_min, in_esn => rec_esn_min.x_esn, out_account_objid => lv_current_point_account, out_account_bus_org => lv_current_point_brand );
    lv_steps_completed          := lv_steps_completed + 1;
    IF lv_current_point_account IS NULL THEN
      raise validation_failed;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    /* cr32367 changes starts 4/14/2015 */
    IF inout_transaction_id IS NOT NULL AND in_points_action IN ('DEDUCT', 'CONSUMED') THEN
      OPEN cur_point_trans (inout_transaction_id);
      FETCH cur_point_trans INTO rec_point_trans;
      CLOSE cur_point_trans;
      IF rec_point_trans.benefit_objid IS NOT NULL THEN
        ---and rec_point_trans.benefit_status = '961' then
        --check here the benefit points are already added back.
        --if points are already added then dont add them again
        BEGIN
          UPDATE table_x_benefits
          SET x_status = '967' --967=benefit removed
            ,
            x_update_date = sysdate ,
            x_notes       = 'benefits have been removed since Transaction [ TABLE_X_POINT_TRANS.OBJID ='
            || inout_transaction_id
            || '] is refunded'
          WHERE objid   = rec_point_trans.benefit_objid
          AND x_status <> '967' --check benefit is NOT already removed
            ;
          --if sql%rowcount = 0 that means no record updated means benefits are already removed
          --and in that case do not insert the points again
          --if benefit is removed successfully by above update sql then only add the points back
          IF sql%rowcount > 0 THEN
            --revert the points back (those points which were converted to benefit)
            INSERT
            INTO table_X_point_trans
            SELECT seq_x_point_trans.nextval --objid
              ,
              sysdate --X_TRANS_DATE
              ,
              x_min ,
              x_esn ,
              -1 * (x_points) --X_POINTS
              ,
              x_points_category ,
              'ADD' --X_POINTS_ACTION
              ,
              'Points added back because of the benefits associated are removed [TABLE_X_BENEFITS.OBJID='
              ||rec_point_trans.benefit_objid
              || ']' ---POINTS_ACTION_REASON
              ,
              point_trans2ref_table_objid ,
              ref_table_name ,
              point_trans2service_plan ,
              point_trans2point_account ,
              NULL ---point_trans2purchase_objid
              ,
              'COMPENSATE' ---purchase_table_name
              ,
              point_trans2site_part ,
              NULL ----dont set any benefit-id here; this refund can be used to get new benefit
              ,
              'Restored from Benefit'
            FROM table_x_point_trans
            WHERE 1                         =1
            AND point_trans2point_account   = rec_point_trans.POINT_TRANS2POINT_ACCOUNT
            AND ref_table_name              = 'TABLE_X_BENEFITS'
            AND point_trans2ref_table_objid = rec_point_trans.benefit_objid
            AND x_points_action             = 'CONVERT' ;
          END IF;
        END;
      END IF;
    END IF;
    /*VS:05212015:CR32367:SQA1917: TAS is not yet equipped to pass the point
    transaction id for which the deduct/consumed transaction takes place.
    So when deduct/consumed transaction is made and there is just one benefit
    associated with the user at the point time that benefit will be removed
    If more than one benefit is available then there is no way to tell which
    one gets removed so procedure will return an exception and not process
    the point removal. When TAS passes the point transaction ID stored proc
    will be able to decide teh rigt benefit to remove in all case and should
    work as expected*/
    IF (inout_transaction_id IS NULL AND in_points_action IN ('DEDUCT', 'CONSUMED') ) THEN
      BEGIN
        SELECT total_cnt,
          benefit_objid,
          pa_objid
        INTO lv_benefit_cnt,
          lv_benefit_id,
          lv_pa_objid
        FROM
          (SELECT COUNT(*) over (partition BY xb.x_benefit_owner_value ) total_cnt,
            xb.objid benefit_objid ,
            pa.objid pa_objid
          FROM table_x_benefits xb ,
            table_x_point_account pa
          WHERE pa.x_min              = rec_esn_min.x_min
          AND pa.x_esn                = rec_esn_min.x_esn
          AND pa.account_status       = 'ACTIVE'
          AND pa.subscriber_uid       = xb.x_benefit_owner_value
          AND xb.x_benefit_owner_type = 'SID'
          AND xb.x_status             = '961'
          AND (xb.x_expiry_date      IS NULL
          OR xb.x_expiry_date         > sysdate )
          )
        WHERE rownum < 2 ;
        SELECT pa.total_points
        INTO lv_tot_pnts
        FROM table_x_point_account pa
        WHERE pa.x_min       = rec_esn_min.x_min
        AND pa.x_esn         = rec_esn_min.x_esn
        AND pa.account_status= 'ACTIVE' ;
      EXCEPTION
      WHEN OTHERS THEN
        -- when any exception in above select set the the count to 0.
        lv_benefit_cnt := 0;
        lv_tot_pnts    := 0;
        lv_benefit_id  := NULL;
      END ;
      IF (lv_benefit_cnt = 1 AND lv_tot_pnts < ABS(lv_points))--SQA#1917 052715
        THEN
        /*remove the benefit only if its just teh one benefit
        associated to account at this point.*/
        UPDATE table_x_benefits
        SET x_status = '967' --967=benefit removed
          ,
          x_update_date = sysdate ,
          x_notes       = 'Benefit has been removed since point transaction was refunded'
        WHERE objid     = lv_benefit_id
        AND x_status   <> '967' ;
        /*Add the reward points back to the account that were
        converted to benefit that got removed. The deduction of points will be done in the next block*/
        IF sql%rowcount > 0 THEN
          lv_pts_objid :=seq_x_point_trans.nextval;
          --revert the points back (those points which were converted to benefit)
          /* CR35343: changed the X_POINTS_ACTION to CONVERT from ADD */
          INSERT
          INTO table_x_point_trans
          SELECT lv_pts_objid --objid
            ,
            sysdate --X_TRANS_DATE
            ,
            x_min ,
            x_esn ,
            -1 * (x_points) --X_POINTS
            ,
            x_points_category ,
            'CONVERT' --X_POINTS_ACTION -- CR35343:070215 changing to CONVERT from ADD
            ,
            'Points added back because of the benefits associated are removed [TABLE_X_BENEFITS.OBJID='
            ||lv_benefit_id
            ||']' ---POINTS_ACTION_REASON
            ,
            point_trans2ref_table_objid ,
            ref_table_name ,
            point_trans2service_plan ,
            point_trans2point_account ,
            NULL ---point_trans2purchase_objid
            ,
            'COMPENSATE' ---purchase_table_name
            ,
            point_trans2site_part ,
            NULL ----dont set any benefit-id here; this refund can be used to get new benefit
            ,
            'Restored from Benefit'
          FROM table_x_point_trans
          WHERE 1                         =1
          AND point_trans2point_account   = lv_pa_objid
          AND ref_table_name              = 'TABLE_X_BENEFITS'
          AND point_trans2ref_table_objid = lv_benefit_id
          AND x_points_action             = 'CONVERT' ;
          /*CR35343 change to address QC2358. Get the conversion point added to point
          trans table using teh point trans objid inserted in teh above step.
          */
          SELECT (x_points)
          INTO lv_recalc_total
          FROM table_x_point_trans
          WHERE 1                       =1
          AND point_trans2point_account = lv_pa_objid
          AND objid                     = lv_pts_objid;
          /* select
          sum(trans.x_points) as calc_points
          into lv_recalc_total
          from table_x_point_trans trans,
          table_x_point_account acc
          where 1 = 1
          --and trans.x_min = in_min -- min null check removed to help performance 060215
          and ( acc.objid = trans.point_trans2point_account)
          and ( acc.account_status = 'ACTIVE' )
          and trans.x_points_action in ('ADD', 'DEDUCT', 'REFUND', 'CONSUMED')
          and trans.point_trans2benefit = lv_benefit_id
          and acc.objid = lv_pa_objid;
          */
          /*CR35343 change to address QC2358*/
          UPDATE table_x_point_trans xpt
          SET xpt.POINT_TRANS2BENEFIT       = NULL
          WHERE xpt.POINT_TRANS2BENEFIT     = lv_benefit_id
          AND xpt.POINT_TRANS2POINT_ACCOUNT = lv_pa_objid;
          /*CR35343 change to address QC2358*/
          UPDATE table_x_point_account acc
          SET total_points = NVL(total_points,0) + NVL(lv_recalc_total, 0)
            --,x_last_calc_date = sysdate
          WHERE acc.objid    = lv_pa_objid
          AND account_status = 'ACTIVE';
        END IF;
      elsif lv_benefit_cnt > 1 THEN
        -- raise an exception to the application if there are more than one benefit and transaction id is not passed by the application
        out_err_code := -332;
        out_err_msg  := 'More than 1 benefit associated to user.Pass point id to deduct points' ;
        raise e_multi_benefit;
      END IF;
    END IF;
    /* cr32367 changes ends */
    lv_point_trans_objid := sa.seq_x_point_trans.nextval ;
    INSERT
    INTO table_x_point_trans
      (
        objid,
        x_trans_date,
        x_min,
        x_esn,
        x_points,
        x_points_category,
        x_points_action,
        points_action_reason,
        point_trans2ref_table_objid,
        ref_table_name,
        point_trans2service_plan,
        point_trans2point_account,
        point_trans2purchase_objid,
        purchase_table_name,
        point_trans2site_part,
        point_trans2benefit,
        point_display_reason
      )
      VALUES
      (
        lv_point_trans_objid,
        sysdate,
        rec_esn_min.x_min,
        rec_esn_min.x_esn,
        lv_points,
        in_points_category,
        in_points_action,
        SUBSTR(in_compensate_reason,1,2000),
        in_bonus_objid,
        'TABLE_X_BONUS_POINTS_LOAD',
        in_service_plan_objid,
        lv_current_point_account,
        NULL,
        DECODE (in_points_category ,'BONUS_POINTS','BONUS' ,'COMPENSATE') ,
        rec_esn_min.site_part_objid,
        NULL , --initialize benefit as null
        DECODE (in_points_category ,'BONUS_POINTS', SUBSTR(in_compensate_reason,1,1980) ,'Agent provided: '
        || SUBSTR(in_compensate_reason,1,1980) )
      );
    lv_steps_completed := lv_steps_completed + 1;
    out_x_min          := rec_esn_min.x_min;
    dbms_output.put_line('COMP:insert count:'||SQL%rowcount);
    dbms_output.put_line('COMP:lv_points: '||lv_points);
    lv_steps_completed := lv_steps_completed + 1;
    /*CR32367:050915:SQA2010: TAS needs transaction points not total points
    so commenting the total point from below select and assigning the
    transaction point value to the output*/
    out_total_points := ABS(lv_points);
    BEGIN
      SELECT --acc.total_points,
        acc.bus_org_objid
      INTO --out_total_points,
        lv_points_brand
      FROM table_x_point_account acc
      WHERE objid = lv_current_point_account;
    EXCEPTION
    WHEN no_data_found THEN
      out_total_points := 0;
    END;
    lv_steps_completed := lv_steps_completed + 1;
    --if all goes well, then return the transaction objid which generated the points
    inout_transaction_id := lv_point_trans_objid;
    lv_steps_completed   := lv_steps_completed + 1;
  END IF;
EXCEPTION
WHEN validation_failed THEN
  ROLLBACK;
  out_total_points := 0;
WHEN e_multi_benefit THEN
  ROLLBACK;
  out_total_points := 0;
WHEN OTHERS THEN
  ROLLBACK;
  out_err_code := -99;
  out_err_msg  := 'FAILURE..steps='|| lv_steps_completed ||', ERR=' || SUBSTR(sqlerrm,1,100);
  sa.ota_util_pkg.err_log ( p_action => 'P_COMPENSATE_BONUS_POINTS', p_error_date => sysdate, p_key => NULL, p_program_name => 'P_COMPENSATE_BONUS_POINTS', p_error_text => 'out_err_code = '||out_err_code || ', out_err_msg='||out_err_msg);
END p_compensate_bonus_points_ia ;
/*used in bonus_points load*/
PROCEDURE p_compensate_bonus_points(
    in_key                IN VARCHAR2,
    in_value              IN VARCHAR2,
    in_points             IN NUMBER,
    in_points_category    IN VARCHAR2 DEFAULT 'BONUS_POINTS',
    in_points_action      IN VARCHAR2,
    in_user_objid         IN NUMBER,
    in_compensate_reason  IN VARCHAR2,
    in_service_plan_objid IN NUMBER,
    in_bonus_objid        IN NUMBER,
    out_total_points OUT NUMBER,
    inout_transaction_id IN OUT NUMBER,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
  /*
  P_COMPENSATE_REWARD_POINTS
  This procedure will update the reward points for input MIN
  and provides output as total points available
  Input
  IN_KEY = can be ESN or MIN
  IN_VALUE = value of esn or min
  IN_POINTS = points to compensate
  IN_POINT_CATEGORY = REWARD / LOYALTY / BONUS
  IN_POINTS_ACTION = how to compensate the points - it can be "ADD" / "DEDUCT"
  IN_USER_OBJID = the TAS user which calls this procedure to compensate the points for customer
  IN_COMPENSATE_REASON = description explaining why the points are compensated
  Output
  out_total_points = total points available
  OUT_AMOUNT = money equal to the total points
  OUT_TRANSACTION_ID = transaction id generated for this points compensation transaction
  OUT_ERR_CODE = 0 if success ; else error code
  OUT_ERR_MSG = SUCCESS or error message
  */
  lv_sign           INTEGER := 1;
  validation_failed EXCEPTION;
  rec_esn_min cur_esn_min_dtl%rowtype;
  lv_points               NUMBER;
  lv_point_trans_objid    NUMBER;
  lv_points_brand         NUMBER;
  lv_count                INTEGER;
  lv_steps_completed      INTEGER     := 0;
  lv_point_category_bonus VARCHAR2(40):= 'BONUS_POINTS'; --CR35343
type typ_tab_valid_points
IS
  TABLE OF NUMBER;
  tab_valid_points typ_tab_valid_points;
  lv_invalid_points_error  VARCHAR2(1000);
  lv_current_point_account NUMBER;
  lv_current_point_brand   NUMBER;
  lv_splan_points          NUMBER;    -- CR32367 4/30/15 VS
  lv_sp_in_points          NUMBER;    -- CR32367 4/30/15 VS
  lv_benefit_cnt           NUMBER;    -- CR32367 5/21/15 VS
  lv_benefit_id            NUMBER;    -- CR32367 5/21/15 VS
  e_multi_benefit          EXCEPTION; -- CR32367 5/21/15 VS
  lv_subid                 VARCHAR2(40);
  lv_err_code              NUMBER;
  lv_pa_objid              NUMBER;
  lv_err_msg               VARCHAR2(2000);
  lv_tot_pnts              NUMBER;
  lv_recalc_total          NUMBER;
  lv_pts_objid             NUMBER;
  CURSOR cur_point_trans (in_objid IN NUMBER)
  IS
    SELECT pt.* ,
      tb.x_status AS benefit_status ,
      tb.objid    AS benefit_objid
    FROM table_x_point_trans pt ,
      table_x_benefits tb
    WHERE 1                    =1
    AND pt.objid               = in_objid
    AND pt.point_trans2benefit = tb.objid ;
  rec_point_trans cur_point_trans%rowtype;
BEGIN
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  IF NVL(in_key,'~') NOT IN ('MIN', 'ESN') THEN
    out_err_code :=       -311;
    out_err_msg  := 'Input Key should be MIN or ESN' ;
    raise validation_failed;
  END IF;
  IF NVL(in_points_action,'~') NOT IN ('ADD', 'DEDUCT', 'CONSUMED') THEN
    out_err_code :=                 -311;
    out_err_msg  := 'Input action type should be "ADD" / "DEDUCT" ';
    raise validation_failed;
  END IF;
  --CR35343 adding the lv_point_category_bonus check
  IF NVL(in_points_category,'~') NOT IN (lc_point_category_reward, lv_point_category_bonus) THEN
    out_err_code :=                   -311;
    out_err_msg  := 'Input point category should be "'|| lc_point_category_reward || '" ';
    raise validation_failed;
  END IF;
  IF in_value    IS NULL THEN
    out_err_code := -311;
    out_err_msg  := 'Input key is ' || in_key || ' ; it should not have NULL value' ;
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  OPEN cur_esn_min_dtl (in_key, in_value);
  FETCH cur_esn_min_dtl INTO rec_esn_min ;
  CLOSE cur_esn_min_dtl;
  IF rec_esn_min.x_min IS NULL THEN
    out_err_code       := -332;
    out_err_msg        := 'Input ' || in_key || ' not found or is not active' ;
    raise validation_failed;
  END IF;
  IF (in_service_plan_objid IS NULL AND in_points IS NULL) THEN
    out_err_code            := -332;
    out_err_msg             := 'Both service_plan_objid and points cannot be null' ;
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  SELECT COUNT(1)
  INTO lv_count
  FROM x_reward_point_values rpv
  WHERE 1                  =1
  AND rpv.bus_org_objid    = rec_esn_min.bus_org_objid
  AND rpv.x_point_category = lc_point_category_reward ;
  IF NVL(lv_count,0)       = 0 THEN
    out_err_code          := -333;
    out_err_msg           := 'Input ' || in_key || '=' || in_value || ' is from ' || rec_esn_min.bus_org_objid || ' and it Does not have eligible reward points at this time';
    raise validation_failed;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  /***************************************************************
  CR32367 4/30/15 VS
  Fetching the reward points based on the service plan objid if
  its passed in the input. if in_points value is passed that will
  be used, if not service plan based points will be used.
  ****************************************************************/
  IF (in_service_plan_objid IS NOT NULL) THEN
    BEGIN
      SELECT x_unit_points
      INTO lv_splan_points
      FROM x_reward_point_values
      WHERE service_plan_objid = in_service_plan_objid
      AND x_point_category     = lc_point_category_reward;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_code := -332;
      out_err_msg  := 'Service plan is not eligible for rewards' ;
      raise validation_failed;
    END;
  END IF ;
  IF lv_splan_points IS NOT NULL THEN
    lv_sp_in_points  := lv_splan_points;
  elsif in_points    IS NOT NULL THEN
    lv_sp_in_points  := in_points;
  ELSE
    lv_sp_in_points := lv_splan_points;
  END IF ;
  /*********************************************************************/
  --verify points that can be earned by input min/esn
  BEGIN
    SELECT DISTINCT NVL(mv.fea_value ,0) bulk collect
    INTO tab_valid_points
    FROM adfcrm_serv_plan_feat_matview mv
    WHERE mv.fea_name        = lc_point_category_reward
    AND NVL(mv.fea_value,0) <> 0;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END ;
  lv_steps_completed              := lv_steps_completed + 1;
  lv_points                       := 0;
  IF NVL(tab_valid_points.count,0) = 0 THEN
    out_err_code                  := -9;
    out_err_msg                   := 'No Points available at this time.';
    raise validation_failed;
  ELSE
    lv_invalid_points_error := NULL;
    FOR i IN 1..tab_valid_points.count
    LOOP
      IF lv_sp_in_points         = tab_valid_points(i) THEN
        lv_points               := tab_valid_points(i);
        lv_invalid_points_error := NULL;
        EXIT;
      ELSE
        lv_invalid_points_error := lv_invalid_points_error || ', '|| tab_valid_points(i);
      END IF;
    END LOOP;
  END IF;
  --check input points are equal to points offered by service plan
  IF (in_points_category = lc_point_category_reward) --CR35343
    THEN
    IF (lv_points         = lv_sp_in_points ) AND NVL(lv_points,0) > 0 THEN
      IF in_points_action = 'ADD' THEN
        lv_sign          := 1;
      elsif in_points_action IN ('DEDUCT', 'CONSUMED') THEN
        lv_sign :=            -1;
      END IF;
      lv_steps_completed := lv_steps_completed + 1;
      lv_points          := lv_points          * lv_sign ;
    ELSE
      out_err_code := -334;
      out_err_msg  := 'Points allowed to compensate are ' || SUBSTR(lv_invalid_points_error,2);
      raise validation_failed;
    END IF;
    /*CR35343: 070815: adding the following to handle bonus_points */
  elsif (in_points_category = 'BONUS_POINTS') THEN
    IF in_points_action     = 'ADD' THEN
      lv_sign              := 1;
    elsif in_points_action IN ('DEDUCT', 'CONSUMED') THEN
      lv_sign :=            -1;
    END IF;
    lv_points := lv_sign * lv_sp_in_points;
  END IF; --CR35343
  lv_steps_completed   := lv_steps_completed + 1;
  IF NVL(lv_points, 0) <> 0 THEN ---and inout_transaction_id is not null then
    --check whether point_account exists or no
    --if not then create point_account
    p_check_point_account ( in_min => rec_esn_min.x_min, in_esn => rec_esn_min.x_esn, out_account_objid => lv_current_point_account, out_account_bus_org => lv_current_point_brand );
    lv_steps_completed          := lv_steps_completed + 1;
    IF lv_current_point_account IS NULL THEN
      raise validation_failed;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    /* cr32367 changes starts 4/14/2015 */
    IF inout_transaction_id IS NOT NULL AND in_points_action IN ('DEDUCT', 'CONSUMED') THEN
      OPEN cur_point_trans (inout_transaction_id);
      FETCH cur_point_trans INTO rec_point_trans;
      CLOSE cur_point_trans;
      IF rec_point_trans.benefit_objid IS NOT NULL THEN
        ---and rec_point_trans.benefit_status = '961' then
        --check here the benefit points are already added back.
        --if points are already added then dont add them again
        BEGIN
          UPDATE table_x_benefits
          SET x_status = '967' --967=benefit removed
            ,
            x_update_date = sysdate ,
            x_notes       = 'benefits have been removed since Transaction [ TABLE_X_POINT_TRANS.OBJID ='
            || inout_transaction_id
            || '] is refunded'
          WHERE objid   = rec_point_trans.benefit_objid
          AND x_status <> '967' --check benefit is NOT already removed
            ;
          --if sql%rowcount = 0 that means no record updated means benefits are already removed
          --and in that case do not insert the points again
          --if benefit is removed successfully by above update sql then only add the points back
          IF sql%rowcount > 0 THEN
            --revert the points back (those points which were converted to benefit)
            INSERT
            INTO table_X_point_trans
            SELECT seq_x_point_trans.nextval --objid
              ,
              sysdate --X_TRANS_DATE
              ,
              x_min ,
              x_esn ,
              -1 * (x_points) --X_POINTS
              ,
              x_points_category ,
              'ADD' --X_POINTS_ACTION
              ,
              'Points added back because of the benefits associated are removed [TABLE_X_BENEFITS.OBJID='
              ||rec_point_trans.benefit_objid
              || ']' ---POINTS_ACTION_REASON
              ,
              point_trans2ref_table_objid ,
              ref_table_name ,
              point_trans2service_plan ,
              point_trans2point_account ,
              NULL ---point_trans2purchase_objid
              ,
              'COMPENSATE' ---purchase_table_name
              ,
              point_trans2site_part ,
              NULL ----dont set any benefit-id here; this refund can be used to get new benefit
              ,
              'Restored from Benefit'
            FROM table_x_point_trans
            WHERE 1                         =1
            AND point_trans2point_account   = rec_point_trans.POINT_TRANS2POINT_ACCOUNT
            AND ref_table_name              = 'TABLE_X_BENEFITS'
            AND point_trans2ref_table_objid = rec_point_trans.benefit_objid
            AND x_points_action             = 'CONVERT' ;
          END IF;
        END;
      END IF;
    END IF;
    /*VS:05212015:CR32367:SQA1917: TAS is not yet equipped to pass the point
    transaction id for which the deduct/consumed transaction takes place.
    So when deduct/consumed transaction is made and there is just one benefit
    associated with the user at the point time that benefit will be removed
    If more than one benefit is available then there is no way to tell which
    one gets removed so procedure will return an exception and not process
    the point removal. When TAS passes the point transaction ID stored proc
    will be able to decide teh rigt benefit to remove in all case and should
    work as expected*/
    IF (inout_transaction_id IS NULL AND in_points_action IN ('DEDUCT', 'CONSUMED') ) THEN
      BEGIN
        SELECT total_cnt,
          benefit_objid,
          pa_objid
        INTO lv_benefit_cnt,
          lv_benefit_id,
          lv_pa_objid
        FROM
          (SELECT COUNT(*) over (partition BY xb.x_benefit_owner_value ) total_cnt,
            xb.objid benefit_objid ,
            pa.objid pa_objid
          FROM table_x_benefits xb ,
            table_x_point_account pa
          WHERE pa.x_min              = rec_esn_min.x_min
          AND pa.x_esn                = rec_esn_min.x_esn
          AND pa.account_status       = 'ACTIVE'
          AND pa.subscriber_uid       = xb.x_benefit_owner_value
          AND xb.x_benefit_owner_type = 'SID'
          AND xb.x_status             = '961'
          AND (xb.x_expiry_date      IS NULL
          OR xb.x_expiry_date         > sysdate )
          )
        WHERE rownum < 2 ;
        SELECT pa.total_points
        INTO lv_tot_pnts
        FROM table_x_point_account pa
        WHERE pa.x_min       = rec_esn_min.x_min
        AND pa.x_esn         = rec_esn_min.x_esn
        AND pa.account_status= 'ACTIVE' ;
      EXCEPTION
      WHEN OTHERS THEN
        -- when any exception in above select set the the count to 0.
        lv_benefit_cnt := 0;
        lv_tot_pnts    := 0;
        lv_benefit_id  := NULL;
      END ;
      IF (lv_benefit_cnt = 1 AND lv_tot_pnts < ABS(lv_points))--SQA#1917 052715
        THEN
        /*remove the benefit only if its just teh one benefit
        associated to account at this point.*/
        UPDATE table_x_benefits
        SET x_status = '967' --967=benefit removed
          ,
          x_update_date = sysdate ,
          x_notes       = 'Benefit has been removed since point transaction was refunded'
        WHERE objid     = lv_benefit_id
        AND x_status   <> '967' ;
        /*Add the reward points back to the account that were
        converted to benefit that got removed. The deduction of points will be done in the next block*/
        IF sql%rowcount > 0 THEN
          lv_pts_objid :=seq_x_point_trans.nextval;
          --revert the points back (those points which were converted to benefit)
          /* CR35343: changed the X_POINTS_ACTION to CONVERT from ADD */
          INSERT
          INTO table_x_point_trans
          SELECT lv_pts_objid --objid
            ,
            sysdate --X_TRANS_DATE
            ,
            x_min ,
            x_esn ,
            -1 * (x_points) --X_POINTS
            ,
            x_points_category ,
            'CONVERT' --X_POINTS_ACTION -- CR35343:070215 changing to CONVERT from ADD
            ,
            'Points added back because of the benefits associated are removed [TABLE_X_BENEFITS.OBJID='
            ||lv_benefit_id
            ||']' ---POINTS_ACTION_REASON
            ,
            point_trans2ref_table_objid ,
            ref_table_name ,
            point_trans2service_plan ,
            point_trans2point_account ,
            NULL ---point_trans2purchase_objid
            ,
            'COMPENSATE' ---purchase_table_name
            ,
            point_trans2site_part ,
            NULL ----dont set any benefit-id here; this refund can be used to get new benefit
            ,
            'Restored from Benefit'
          FROM table_x_point_trans
          WHERE 1                         =1
          AND point_trans2point_account   = lv_pa_objid
          AND ref_table_name              = 'TABLE_X_BENEFITS'
          AND point_trans2ref_table_objid = lv_benefit_id
          AND x_points_action             = 'CONVERT' ;
          /*CR35343 change to address QC2358. Get the conversion point added to point
          trans table using teh point trans objid inserted in teh above step.
          */
          SELECT (x_points)
          INTO lv_recalc_total
          FROM table_x_point_trans
          WHERE 1                       =1
          AND point_trans2point_account = lv_pa_objid
          AND objid                     = lv_pts_objid;
          /* select
          sum(trans.x_points) as calc_points
          into lv_recalc_total
          from table_x_point_trans trans,
          table_x_point_account acc
          where 1 = 1
          --and trans.x_min = in_min -- min null check removed to help performance 060215
          and ( acc.objid = trans.point_trans2point_account)
          and ( acc.account_status = 'ACTIVE' )
          and trans.x_points_action in ('ADD', 'DEDUCT', 'REFUND', 'CONSUMED')
          and trans.point_trans2benefit = lv_benefit_id
          and acc.objid = lv_pa_objid;
          */
          /*CR35343 change to address QC2358*/
          UPDATE table_x_point_trans xpt
          SET xpt.POINT_TRANS2BENEFIT       = NULL
          WHERE xpt.POINT_TRANS2BENEFIT     = lv_benefit_id
          AND xpt.POINT_TRANS2POINT_ACCOUNT = lv_pa_objid;
          /*CR35343 change to address QC2358*/
          UPDATE table_x_point_account acc
          SET total_points = NVL(total_points,0) + NVL(lv_recalc_total, 0)
            --,x_last_calc_date = sysdate
          WHERE acc.objid    = lv_pa_objid
          AND account_status = 'ACTIVE';
        END IF;
      elsif lv_benefit_cnt > 1 THEN
        -- raise an exception to the application if there are more than one benefit and transaction id is not passed by the application
        out_err_code := -332;
        out_err_msg  := 'More than 1 benefit associated to user.Pass point id to deduct points' ;
        raise e_multi_benefit;
      END IF;
    END IF;
    /* cr32367 changes ends */
    lv_point_trans_objid := sa.seq_x_point_trans.nextval ;
    INSERT
    INTO table_x_point_trans
      (
        objid,
        x_trans_date,
        x_min,
        x_esn,
        x_points,
        x_points_category,
        x_points_action,
        points_action_reason,
        point_trans2ref_table_objid,
        ref_table_name,
        point_trans2service_plan,
        point_trans2point_account,
        point_trans2purchase_objid,
        purchase_table_name,
        point_trans2site_part,
        point_trans2benefit,
        point_display_reason
      )
      VALUES
      (
        lv_point_trans_objid,
        sysdate,
        rec_esn_min.x_min,
        rec_esn_min.x_esn,
        lv_points,
        in_points_category,
        in_points_action,
        SUBSTR(in_compensate_reason,1,2000),
        in_bonus_objid,
        'TABLE_X_BONUS_POINTS_LOAD',
        in_service_plan_objid,
        lv_current_point_account,
        NULL,
        DECODE (in_points_category ,'BONUS_POINTS','BONUS' ,'COMPENSATE') ,
        rec_esn_min.site_part_objid,
        NULL , --initialize benefit as null
        DECODE (in_points_category ,'BONUS_POINTS', SUBSTR(in_compensate_reason,1,1980) ,'Agent provided: '
        || SUBSTR(in_compensate_reason,1,1980) )
      );
    lv_steps_completed := lv_steps_completed + 1;
    --calculate the total points that this min has earned till date
    dbms_output.put_line ('calling p_calculate_points');
    p_calculate_points (rec_esn_min.x_min, out_err_code, out_err_msg);
    IF out_err_code != 0 THEN
      raise validation_failed;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    COMMIT;
    reward_benefits_n_vouchers_pkg.p_get_subscriber_id ( in_key => in_key ,in_value => in_value ,out_subscriber_id => lv_subid ,out_err_code => lv_err_code ,out_err_msg => lv_err_msg ) ;
    --check if total points have reached the maximum value
    --and may be eligible to create a reward benefit
    --03/24/2015 CR32367
    sa.reward_benefits_n_vouchers_pkg.p_create_reward_benefits ( in_min => rec_esn_min.x_min ,out_err_code => out_err_code ,out_err_msg => out_err_msg );
    IF out_err_code = 0 THEN
      COMMIT;
    ELSE
      raise no_data_found;
    END IF;
    lv_steps_completed := lv_steps_completed + 1;
    /*CR32367:050915:SQA2010: TAS needs transaction points not total points
    so commenting the total point from below select and assigning the
    transaction point value to the output*/
    out_total_points := ABS(lv_points);
    BEGIN
      SELECT --acc.total_points,
        acc.bus_org_objid
      INTO --out_total_points,
        lv_points_brand
      FROM table_x_point_account acc
      WHERE objid = lv_current_point_account;
    EXCEPTION
    WHEN no_data_found THEN
      out_total_points := 0;
    END;
    lv_steps_completed := lv_steps_completed + 1;
    --if all goes well, then return the transaction objid which generated the points
    inout_transaction_id := lv_point_trans_objid;
    lv_steps_completed   := lv_steps_completed + 1;
  END IF;
EXCEPTION
WHEN validation_failed THEN
  ROLLBACK;
  out_total_points := 0;
WHEN e_multi_benefit THEN
  ROLLBACK;
  out_total_points := 0;
WHEN OTHERS THEN
  ROLLBACK;
  out_err_code := -99;
  out_err_msg  := 'FAILURE..steps='|| lv_steps_completed ||', ERR=' || SUBSTR(sqlerrm,1,100);
  sa.ota_util_pkg.err_log ( p_action => 'P_COMPENSATE_BONUS_POINTS', p_error_date => sysdate, p_key => NULL, p_program_name => 'P_COMPENSATE_BONUS_POINTS', p_error_text => 'out_err_code = '||out_err_code || ', out_err_msg='||out_err_msg);
END p_compensate_bonus_points ;
PROCEDURE P_update_reward_points_job(
    in_rundate IN DATE,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2)
IS
  /*
  p_update_reward_points_job
  This procedure will calculate reward points for each esn and update the total reward points
  This will also check for inactive min / esn for X days and wipes out the reward points as applicable
  */
  lv_steps_completed INTEGER;
  lv_call_trans_read NUMBER := 0;
  lv_brands          VARCHAR2(2000);
  lv_hours           NUMBER := 6;
  CURSOR cur_call_trans_records
  IS
    --@TW why is separate cursor used than the one for P_GENERATE_REWARD_POINT_BENEFITS ???
    SELECT
      --CR43497
      DISTINCT ct.x_min,
      ct.x_service_id AS x_esn
      --CR43497
    FROM table_x_call_trans ct
    WHERE 1                 = 1
    AND ct.x_transact_date >= in_rundate - lv_hours / 24
      --@TW hard coded value; ALSO why is this not -5 days as the other cases ???
    AND ct.x_result = 'Completed'
    AND ct.x_action_type
      ||'' IN ( '1', '3', '6', '401', '2', '20' )
      --@TW added 401 for queued cards, 2 for DEACTIVATIONS, 20 for PORT OUTS?
    AND ct.x_min NOT LIKE 'T%'
      ----and lv_brands like '%'||ct.x_sub_sourcesystem||'%'
    AND ct.x_sub_sourcesystem IN
      (SELECT Regexp_substr(lv_brands, '[^,]+', 1, LEVEL) AS data_1
      FROM dual
        CONNECT BY LEVEL <= Regexp_count(lv_brands, '[^,]+')
      )
    --ignore records which are already processed and inserted in point_trans
  AND NOT EXISTS
    (SELECT 1
    FROM table_x_point_trans pt
    WHERE 1                            = 1
    AND pt.point_trans2ref_table_objid = ct.objid
    );
TYPE typ_cur_call_trans_records
IS
  TABLE OF cur_call_trans_records%ROWTYPE INDEX BY PLS_INTEGER;
  tab_call_trans TYP_CUR_CALL_TRANS_RECORDS;
BEGIN
  lv_steps_completed        := 0;
  lv_job_insert_rec_counter := 0; --count how many inserts run in this job
  lv_job_update_rec_counter := 0; --count how many updates run in this job
  ----collect all the brands which are applicable for reward points
  BEGIN
    SELECT Listagg (brandname, ',') within GROUP (
    ORDER BY 1) AS brands
    INTO lv_brands
    FROM
      (SELECT DISTINCT org_id AS brandname
      FROM table_bus_org bo,
        x_reward_point_values rb
      WHERE 1                 = 1
      AND bo.objid            = rb.bus_org_objid
      AND rb.x_point_category = lc_point_category_reward
      AND SYSDATE BETWEEN rb.x_start_date AND rb.x_end_date
      );
  EXCEPTION
  WHEN OTHERS THEN
    lv_brands := NULL;
  END;
  BEGIN
    SELECT x_param_value
    INTO lv_hours
    FROM table_x_parameters
    WHERE x_param_name = 'REWARD_POINTS_CHECK_HOURS_BACK';
  EXCEPTION
  WHEN OTHERS THEN
    lv_hours := 6;
  END;
  --generate table_x_point_trans records
  lv_call_trans_read := 0;
  OPEN cur_call_trans_records;
  LOOP
    FETCH cur_call_trans_records bulk collect INTO tab_call_trans limit 200;
    EXIT
  WHEN tab_call_trans.count = 0;
    FOR ir IN 1..tab_call_trans.count
    LOOP
      sa.reward_points_pkg.P_generate_reward_point_trans( in_rundate => in_rundate, in_min => Tab_call_trans(ir).x_min, in_esn => Tab_call_trans(ir).x_esn, out_err_code => out_err_code, out_err_msg => out_err_msg);
    END LOOP;
    lv_call_trans_read := lv_call_trans_read + tab_call_trans.count;
    COMMIT; --cr32367
  END LOOP;
  CLOSE cur_call_trans_records;
  lv_steps_completed := lv_steps_completed + 1;
  --calculate and update the total points for each MIN in table_x_point_account
  --NULL is mentioned as input parameter instead of MIN; which means all MIN will be processed from the date
  P_calculate_points (NULL, out_err_code, out_err_msg);
  lv_steps_completed := lv_steps_completed + 1;
  --check if total points have reached the maximum value
  --and may be eligible to create a reward benefit
  --03/24/2015 CR32367
  sa.reward_benefits_n_vouchers_pkg.P_create_reward_benefits (in_min => NULL, out_err_code => out_err_code, out_err_msg => out_err_msg);
  lv_steps_completed := lv_steps_completed + 1;
  COMMIT;
  --process refund transactions
  P_refund_points (
  --@TW should this proc also be called for p_get_reward_points ???
  in_rundate => in_rundate, out_err_code => out_err_code, out_err_msg => out_err_msg);
  lv_steps_completed := lv_steps_completed + 1;
  IF out_err_code     = 0 THEN
    COMMIT;
    out_err_msg := 'SUCCESS';
  ELSE
    ROLLBACK;
    sa.ota_util_pkg.Err_log (p_action => 'reward_points_pkg.p_update_reward_points_job', p_error_date => SYSDATE, p_key => NULL, p_program_name => 'reward_points_pkg.p_update_reward_points_job', p_error_text => SUBSTR('ROLLBACK DONE.' || ', lv_call_trans_read=' ||lv_call_trans_read || ', lv_steps_completed=' ||lv_steps_completed || ', out_err_code=' || out_err_code || ', out_err_msg=' || out_err_msg, 1, 3999));
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  out_err_code := -99;
  out_err_msg  := 'p_update_reward_points_job FAILURE..' ||', lv_steps_completed=' || lv_steps_completed ||', ERR=' || SUBSTR(SQLERRM, 1, 500);
  sa.ota_util_pkg.Err_log (p_action => 'p_update_reward_points_job', p_error_date => SYSDATE, p_key => NULL, p_program_name => 'p_update_reward_points_job', p_error_text => out_err_msg);
  --DBMS_OUTPUT.PUT_LINE('**** EXCEPTION WHILE RUNNING PROCEDURE p_update_reward_points_job **** out_err_code: '||out_err_code||' out_err_msg: '||out_err_msg );
END p_update_reward_points_job;
FUNCTION f_get_purch_objid(
    in_red_card_objid IN NUMBER)
  RETURN NUMBER
IS
  /*
  function: f_get_purch_objid
  input
  table_x_red_card.objid
  output
  returns the corresponding table_x_purch_hdr.objid
  */
  lv_return NUMBER;
BEGIN
  SELECT MAX(ph.objid)
  INTO lv_return
  FROM table_x_red_card rc,
    table_x_purch_dtl pd,
    table_x_purch_hdr ph
  WHERE 1       =1
  AND rc.objid  = in_red_card_objid
  AND rc.x_smp  = pd.x_smp
  AND ph.objid  = pd.x_purch_dtl2x_purch_hdr;
  IF lv_return IS NULL THEN
    lv_return  := in_red_card_objid;
  END IF;
  RETURN lv_return ;
END f_get_purch_objid;
PROCEDURE p_refund_points(
    in_rundate IN DATE,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
  /*
  procedure: p_refund_points = returns the points that MIN has accrued
  for example: cust paid $70 for SM upgrade plan and got 3 points
  after 4 days, customer asking for refund of $70
  in this case, subtract 3 points when refund is completed
  */
  CURSOR cur_point_trans (in_date IN DATE)
  IS
    SELECT pt.objid ,
      pt.x_trans_date ,
      pt.x_min ,
      pt.x_esn ,
      pt.x_points ,
      pt.x_points_category ,
      pt.x_points_action ,
      pt.point_trans2ref_table_objid ,
      pt.point_trans2service_plan ,
      pt.point_trans2point_account ,
      pt.points_action_reason ,
      pt.point_trans2purchase_objid,
      pt.purchase_table_name,
      pt.point_trans2site_part,
      ph_refund.refund_objid,
      ph_refund.refund_txn_date,
      ph_refund.purchase_type
    FROM table_x_point_trans pt ,
      ( --app purchase refund
      SELECT 'TABLE_X_PURCH_HDR' AS purchase_type,
        objid                    AS refund_objid,
        x_rqst_date              AS refund_txn_date,
        x_purch_hdr2cr_purch     AS sale_objid
      FROM table_x_purch_hdr
      WHERE 1          =1
      AND x_rqst_date >= in_date
      AND x_rqst_type  ='cc_refund'
      AND x_ics_rcode IN ('1','100')
    UNION ALL
    -- program purch Refunds
    SELECT 'X_PROGRAM_PURCH_HDR' AS purchase_type,
      objid                      AS refund_objid,
      x_rqst_date                AS refund_txn_date,
      purch_hdr2cr_purch         AS sale_objid
    FROM x_program_purch_hdr
    WHERE 1          =1
    AND x_rqst_date >= in_date
    AND x_rqst_type  ='CREDITCARD_REFUND'
    AND x_ics_rcode IN ('1','100')
      ) ph_refund
    WHERE ( pt.x_trans_date        >= in_date )
    AND ( ph_refund.refund_txn_date > pt.x_trans_date ) -- refund will happen after purchase only
    AND ( pt.x_points_category      = lc_point_category_reward )
      --and ( ph_refund.sale_objid = pt.point_trans2purchase_objid
    AND ( ph_refund.sale_objid = f_get_purch_objid(pt.point_trans2purchase_objid) )
      --Ensure refund has not already been processed
    AND NVL(pt.x_points_action,'~') != 'REFUND'
    AND NOT EXISTS
      (SELECT 1
      FROM table_x_point_trans tt
      WHERE tt.point_trans2purchase_objid = pt.point_trans2purchase_objid
      AND tt.point_trans2ref_table_objid  = ph_refund.refund_objid
      AND tt.x_points_action              = 'REFUND'
      AND tt.x_points_category            = pt.x_points_category
      ) ;
  type tab_cur_point_trans
IS
  TABLE OF cur_point_trans%rowtype INDEX BY pls_integer;
  tab_point_trans tab_cur_point_trans;
  lv_refund_days INTEGER;
  lv_loop_counter pls_integer := 0;
BEGIN
  ---dbms_output.put_line('**** START OF PROCEDURE p_refund_points ****');
  --check for how many days we should look back to see any refund transaction has happened
  BEGIN
    SELECT x_param_value
    INTO lv_refund_days
    FROM table_x_parameters
    WHERE x_param_name = 'REFUND_REWARD_POINTS_THRESHOLD_DAYS';
  EXCEPTION
  WHEN OTHERS THEN
    lv_refund_days := 0;
  END;
  OPEN cur_point_trans(in_rundate - NVL(lv_refund_days,0) );
  -- select refund transactions which happened in last X days
  LOOP
    FETCH cur_point_trans bulk collect INTO tab_point_trans limit 500 ;
    EXIT
  WHEN tab_point_trans.count = 0;
    forall ir IN 1..tab_point_trans.count
    INSERT
    INTO table_x_point_trans
      (
        objid,
        x_trans_date,
        x_min,
        x_esn,
        x_points,
        x_points_category,
        x_points_action,
        points_action_reason,
        point_trans2ref_table_objid,
        ref_table_name,
        point_trans2service_plan,
        point_trans2point_account,
        point_trans2purchase_objid,
        purchase_table_name,
        point_trans2site_part,
        point_display_reason
      )
      VALUES
      (
        sa.seq_x_point_trans.nextval,
        sysdate,
        tab_point_trans(ir).x_min,
        tab_point_trans(ir).x_esn,
        -1 * tab_point_trans(ir).x_points,
        tab_point_trans(ir).x_points_category,
        'REFUND',
        'Points returned because Refund transaction processed on '
        || TO_CHAR(tab_point_trans(ir).refund_txn_date,'dd-mon-rrrr hh24:mi:sssss'),
        tab_point_trans(ir).refund_objid,
        tab_point_trans(ir).purchase_type,
        tab_point_trans(ir).point_trans2service_plan,
        tab_point_trans(ir).point_trans2point_account,
        tab_point_trans(ir).point_trans2purchase_objid,
        tab_point_trans(ir).purchase_table_name,
        tab_point_trans(ir).point_trans2site_part,
        'Refund'
      );
    --lv_loop_counter := lv_loop_counter + sql%rowcount; ---tab_point_trans.count;
    lv_job_insert_rec_counter := lv_job_insert_rec_counter + sql%rowcount ;
  END LOOP;
  ---DBMS_OUTPUT.PUT_LINE('TOTAL INSERTED RECORDS(REFUND) INTO table_x_point_trans: '||lv_loop_counter);
  --calculate total points for those MINs which undergo refund transactions
  p_calculate_points (NULL, out_err_code, out_err_msg);
  ---dbms_output.put_line('**** END OF PROCEDURE p_refund_points ****');
EXCEPTION
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'p_refund_points FAILURE..ERR=' || SUBSTR(sqlerrm,1,500);
  sa.ota_util_pkg.err_log ( p_action => 'p_refund_points', p_error_date => sysdate, p_key => NULL, p_program_name => 'p_refund_points', p_error_text => 'out_err_code='||out_err_code ||', out_err_msg='||out_err_msg );
  --DBMS_OUTPUT.PUT_LINE('**** EXCEPTION WHILE RUNNING PROCEDURE p_refund_points **** out_err_code: '||out_err_code||' out_err_msg: '||out_err_msg );
END p_refund_points;
PROCEDURE p_get_points_for_purch_trans
  (
    in_purch_objid IN NUMBER,
    out_purch_type OUT VARCHAR2,
    out_points OUT NUMBER,
    out_points_category OUT VARCHAR2,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2
  )
IS
  /*
  procedure: p_get_points_for_purch_trans
  This procedure accepts transaction objid
  and returns how many points were earned during that transaction
  Input:
  in_purch_objid = objid of either TABLE_X_PURCH_HDR or X_PROGRAM_PURCH_HDR
  Output:
  out_purch_type = values either APP or BILLING
  out_points = points associated with the transaction
  out_points_category = category of points (for now its fixed - REWARD_POINTS )
  out_err_code = 0 if successfull ; otherwise corresponding error number
  out_err_msg = SUCCESS otherwise corresponding error message
  */
BEGIN
  SELECT ph.purch_type,
     NVL(pt.x_points,NULL),  -- Modified  TO NULL value for the CR52398
    NVL(pt.x_points_category, lc_point_category_reward)
  INTO out_purch_type,
    out_points,
    out_points_category
  FROM table_x_point_trans pt,
    (
    -- APP Purchase to call trans
    SELECT
      /*+ ORDERED */
      DISTINCT ph.objid   AS purch_objid,
      'APP'               AS purch_type,
      red_card2call_trans AS call_trans_objid
    FROM table_x_purch_hdr ph,
      table_x_point_trans pt,
      table_x_purch_dtl pd,
      table_x_red_card rc
    WHERE 1                           =1
    AND ph.objid                      = in_purch_objid
    AND pt.point_trans2purchase_objid = ph.objid
    AND pt.x_points_category          = 'REWARD_POINTS'
    AND pd.x_purch_dtl2x_purch_hdr    = ph.objid
    AND rc.objid                      = pd.x_purch_dtl2redcard
    UNION
    SELECT
      /*+ ORDERED */
      DISTINCT xph.objid,
      'BILLING',
      xpg.gencode2call_trans AS call_trans_objid
    FROM x_program_purch_hdr xph,
      table_x_point_trans xpt ,
      x_program_purch_dtl xpd ,
      x_program_gencode xpg
    WHERE 1                            =1
    AND xph.objid                      = in_purch_objid
    AND xpt.point_trans2purchase_objid = xph.objid
    AND xpt.x_points_category          = 'REWARD_POINTS' --lc_point_category_reward
    AND xph.objid                      = xpd.pgm_purch_dtl2prog_hdr
    AND xpg.gencode2prog_purch_hdr     = xph.objid
    ) ph ;
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
EXCEPTION
WHEN no_data_found THEN
  out_err_code := -1;
  out_err_msg  := 'No Purchase transaction found for transaction id: '|| in_purch_objid;
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'p_get_points_for_purch_trans FAILURE..ERR=' || SUBSTR(sqlerrm,1,500);
  sa.ota_util_pkg.err_log ( p_action => 'p_get_points_for_purch_trans', p_error_date => sysdate, p_key => NULL, p_program_name => 'p_get_points_for_purch_trans', p_error_text => 'out_err_code='||out_err_code ||', out_err_msg='||out_err_msg );
END p_get_points_for_purch_trans ;
/*VS:062915:CR35343:Adding in_esn as input to get the correct plan information*/
PROCEDURE p_get_points_n_plan( in_esn                   IN VARCHAR2,
                               in_call_trans_objid      IN NUMBER,
                               in_call_trans_actiontype IN VARCHAR2,
                               in_call_trans_reason     IN VARCHAR2,
                               out_points_earned        OUT NUMBER,
                               out_points_plan          OUT NUMBER,
                               out_purch_objid          OUT NUMBER,
                               out_purch_table_name     OUT VARCHAR2 )
  /*
  procedure: p_get_points_n_plan
  this procedure accepts the call_trans.objid and finds out the corresponding
  purchase transaction record and service plan
  and outputs the purch-txn objid with any reward points that it can earn
  */
IS
  lv_points             NUMBER       := 0;
  lv_service_plan       NUMBER       := NULL;
  lv_purch_txn          NUMBER       := NULL;
  lv_xph_objid          NUMBER       := NULL;
  lv_trc_objid          NUMBER       := NULL;
  lv_ct_obj_id          NUMBER       := NULL;
  lv_enr_obj_id         NUMBER       := NULL;
  lv_table_name         VARCHAR2(30) := NULL;
  lv_upgrade_case_count INTEGER;
  lv_case_objid         NUMBER;
  lv_site_part_id       NUMBER;
BEGIN
  --
  BEGIN
    --
    BEGIN
      SELECT MAX(points) , --@TW are all these MAXes are problem ??? will they return data from separate rows ?
             MAX(sp_objid),
             MAX(xph_objid),
             MAX(trc_objid),
             MAX(ct_obj_id),
             MAX(enrlmnt_obj_id),
             MAX(site_part_id)
      INTO   lv_points ,
             lv_service_plan,
             lv_xph_objid,
             lv_trc_objid,
             lv_ct_obj_id,
             lv_enr_obj_id,
             lv_site_part_id
     FROM
      (
            /*VS:062915:CR35343: Service plans available for the ESN are looked up
            and used to filter the service plan applied in the current transaction
            */
            WITH esn_serv_plan AS
              (SELECT x2.sp_objid
              FROM table_part_inst pi,
                sa.TABLE_MOD_LEVEL ML2,
                sa.TABLE_PART_NUM PN2 ,
                adfcrm_serv_plan_CLASS_matview x2
              WHERE pi.PART_SERIAL_NO = in_esn
              AND ML2.OBJID           = PI.N_PART_INST2PART_MOD
              AND pn2.objid           = ml2.part_info2part_num
              AND x2.part_class_objid = PN2.PART_NUM2PART_CLASS
              )
              --check program purchase
              SELECT NVL(mv.fea_value,0) AS points,
                mv.sp_objid              AS sp_objid,
                hdr.objid                AS xph_objid,
                NULL                     AS trc_objid,
                NULL                     AS ct_obj_id,
                NULL                     AS enrlmnt_obj_id,
                NULL                     AS site_part_id
              FROM x_program_purch_hdr hdr ,
                x_program_purch_dtl dtl ,
                x_program_enrolled pe ,
                x_program_gencode pg ,
                mtm_sp_x_program_param mtm ,
                adfcrm_serv_plan_feat_matview mv,
                esn_serv_plan esp
              WHERE 1                         = 1
              AND pg.gencode2call_trans       = in_call_trans_objid
              AND pg.gencode2prog_purch_hdr   = hdr.objid
              AND dtl.pgm_purch_dtl2prog_hdr  = hdr.objid
              AND pe.objid                    = dtl.pgm_purch_dtl2pgm_enrolled
              AND pe.pgm_enroll2pgm_parameter = mtm.x_sp2program_param
              AND mv.sp_objid                 = mtm.program_para2x_sp
              AND mv.sp_objid                 = esp.sp_objid --CR35343
              AND mv.fea_name                 = lc_point_category_reward
              AND NVL(mv.fea_value , 0)       > 0
              UNION
              --check activation with pin or store purchase
              --check what plan is used and decide the points
              SELECT NVL(y.fea_value,0) AS points,
                x.sp_objid              AS sp_objid,
                NULL                    AS xph_objid,
                rc.objid                AS trc_objid,
                NULL                    AS ct_obj_id,
                NULL,
                NULL
              FROM table_mod_level ml,
                table_part_num pn,
                adfcrm_serv_plan_CLASS_matview x,
                adfcrm_serv_plan_feat_matview y,
                table_x_red_card rc,
                esn_serv_plan esp
              WHERE 1                    =1
              AND rc.red_card2call_trans = in_call_trans_objid
              AND rc.x_red_card2part_mod = ml.objid
              AND ml.part_info2part_num  = pn.objid
              AND pn.part_num2part_class = x.part_class_objid
              AND esp.sp_objid           = x.sp_objid --CR35343
              AND y.fea_name (+)         = lc_point_category_reward
              AND y.sp_objid (+)         = x.sp_objid
              ----and nvl(y.fea_value , 0) > 0
              UNION -- CR32367:VS:following query is added to capture plan-point of a queued card
              SELECT TO_CHAR(rpv.x_unit_points) AS points,
                rpv.service_plan_objid          AS sp_objid,
                NULL,
                NULL,
                ct.objid ct_obj_id,
                NULL,
                NULL
              FROM table_part_inst pi,
                table_part_num pn,
                table_mod_level ml,
                table_part_class pc,
                (SELECT sp.objid serv_objid,
                  pc.objid part_class_objid,
                  pc.name part_class_name,
                  sp.objid service_plan_objid,
                  sp.mkt_name
                FROM X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
                  X_SERVICEPLANFEATURE_VALUE spfv,
                  X_SERVICE_PLAN_FEATURE spf,
                  X_Serviceplanfeaturevalue_Def Spfvdef2,
                  X_Serviceplanfeaturevalue_Def Spfvdef3,
                  X_Service_Plan Sp,
                  Mtm_Partclass_X_Spf_Value_Def Mtm,
                  table_part_class pc,
                  esn_serv_plan esp
                WHERE spf.sp_feature2rest_value_def = spfvdef.objid
                AND spf.objid                       = spfv.spf_value2spf
                AND Spfvdef2.Objid                  = Spfv.Value_Ref
                AND Spfvdef3.Objid (+)              = Spfv.Child_Value_Ref
                AND Spfvdef.Value_Name              = 'SUPPORTED PART CLASS'
                AND Sp.Objid                        = Spf.Sp_Feature2service_Plan
                AND Spfvdef2.Objid                  = Mtm.Spfeaturevalue_Def_Id
                AND Pc.Objid                        = Mtm.Part_Class_Id
                AND esp.sp_Objid                    = Sp.Objid --CR35343
                ) sp_pc_table ,
                x_reward_point_values rpv ,
                table_x_call_trans ct
              WHERE pi.n_part_inst2part_mod      =ml.objid
              AND ct.objid                       = in_call_trans_objid
              AND ct.x_action_type               = 401
              AND ml.part_info2part_num          =pn.objid
              AND pn.domain                      ='REDEMPTION CARDS'
              AND pn.part_num2part_class         =pc.objid
              AND pi.x_red_code                  = ct.x_reason
              AND sp_pc_table.part_class_objid   = pc.OBJID
              AND sp_pc_table.service_plan_objid = rpv.service_plan_objid(+)
              AND rpv.X_POINT_CATEGORY(+)        = lc_point_category_reward
              UNION -- CR32367:VS: following union is to get the point plan for auto enrollment candidates
              SELECT TO_CHAR(rpv.X_UNIT_POINTS) ,
                psp.X_SERVICE_PLAN_ID ,
                NULL ,
                NULL ,
                NULL ,
                pe.OBJID AS enrlmnt_obj_id ,
                NULL
              FROM x_program_enrolled pe,
                table_x_call_trans ct,
                x_service_plan_site_part psp,
                x_reward_point_values rpv
              WHERE ct.x_service_id       = pe.x_esn
              AND ct.objid                = in_call_trans_objid
              AND ct.x_reason             = 'Redemption' --CR32367:Bug 49 fix:5/12/15:VS
              AND pe.PGM_ENROLL2SITE_PART = psp.TABLE_SITE_PART_ID
              AND psp.X_SERVICE_PLAN_ID   = rpv.SERVICE_PLAN_OBJID(+)
              AND rpv.X_POINT_CATEGORY(+) = lc_point_category_reward
              AND pe.X_ENROLLMENT_STATUS  ='ENROLLED'
              UNION --CR32367:ITQ49:VS:051415
              SELECT TO_CHAR(rpv.X_UNIT_POINTS) ,
                psp.X_SERVICE_PLAN_ID ,
                NULL ,
                NULL ,
                NULL ,
                NULL ,
                psp.table_site_part_id
              FROM table_x_call_trans ct,
                x_service_plan_site_part psp,
                x_reward_point_values rpv
              WHERE ct.objid              = in_call_trans_objid
              AND ct.call_trans2site_part = psp.table_site_part_id
              AND ct.x_reason             = 'ReActivation'
              AND psp.X_SERVICE_PLAN_ID   = rpv.SERVICE_PLAN_OBJID(+)
              AND rpv.X_POINT_CATEGORY(+) = lc_point_category_reward
                );
    EXCEPTION  -- Added for CR47171 to filter No data found
      WHEN OTHERS THEN
       lv_points       := 0;
       lv_service_plan := NULL;
    END;
    --
    IF (NVL(lv_points,0) = 0 AND NVL(lv_service_plan,0) = 0) AND ( in_call_trans_actiontype = '1' OR (NVL(upper(in_call_trans_reason),'~') = 'AWOP' AND in_call_trans_actiontype IN ('1', '3', '6', '401') --@TW added 401 for queued cards (I dont think '2' and '20' apply here)
        ) ) AND (NVL(upper(in_call_trans_reason),'~') NOT                                                                                                                        IN ('UPGRADE')) THEN
        lv_upgrade_case_count := 0;

        SELECT COUNT(1)
        INTO lv_upgrade_case_count
        FROM table_x_case_detail tcd,
             table_case tc,
             table_x_call_trans ct
        WHERE 1             =1
        AND ct.objid        = in_call_trans_objid ---799531087
        AND tc.objid        = tcd.detail2case
        AND ct.x_service_id = tcd.x_value
        AND tcd.x_name      = 'NEW_ESN'
        AND tc.s_title LIKE '%UPGRADE%' ;

        IF NVL(lv_upgrade_case_count,0) > 0 THEN
          --this activation was done because of upgrade
          --so do not add reward points in this scenario
          lv_points       := 0;
          lv_service_plan := 0;
          lv_purch_txn    := 0;
          lv_table_name   := NULL;
        ELSE
          --could be any other type of activation ..
          --like activation with program
          /*VS:062915:CR35343: Service plans available for the ESN are looked up
          and used to filter the service plan applied in the current transaction
          */
          BEGIN
              WITH esn_serv_plan AS
                (SELECT x2.sp_objid
                FROM table_part_inst pi,
                  sa.TABLE_MOD_LEVEL ML2,
                  sa.TABLE_PART_NUM PN2 ,
                  adfcrm_serv_plan_CLASS_matview x2
                WHERE pi.PART_SERIAL_NO = in_esn
                AND ML2.OBJID           = PI.N_PART_INST2PART_MOD
                AND pn2.objid           = ml2.part_info2part_num
                AND x2.part_class_objid = PN2.PART_NUM2PART_CLASS
                )
              SELECT NVL(mv.fea_value,0),
                mv.sp_objid,
                tsp.OBJID
              INTO lv_points,
                lv_service_plan,
                lv_purch_txn
              FROM table_x_call_trans ct,
                table_site_part tsp,
                x_service_plan_site_part spsp,
                adfcrm_serv_plan_feat_matview mv,
                esn_serv_plan esp
              WHERE 1                     = 1
              AND ct.objid                = in_call_trans_objid
              AND ct.call_trans2site_part = tsp.objid
              AND tsp.objid               = spsp.table_site_part_id
              AND spsp.x_service_plan_id  = mv.sp_objid
              AND mv.sp_objid             = esp.sp_Objid
              AND mv.fea_name             = lc_point_category_reward
              AND NVL(mv.fea_value , 0)   > 0
              AND NOT(NVL(ct.x_reason,'~')='Ship Confirm'
              AND ct.x_sourcesystem       = 'BATCH' ); --CR32367:ITQ19:VS:added filter
        EXCEPTION  -- Added for CR47171 to filter No data found
          WHEN OTHERS THEN
            lv_points       := 0;
            lv_service_plan := NULL;
        END;
      END IF;
    ELSIF (NVL(lv_points,0) = 0 AND NVL(lv_service_plan,0) = 0) AND in_call_trans_actiontype = '6' AND (NVL(upper(in_call_trans_reason),'~') IN ('REPLACEMENT')) THEN
        --
        BEGIN
            /*VS:062915:CR35343: Service plans available for the ESN are looked up
            and used to filter the service plan applied in the current transaction
            */
          WITH esn_serv_plan AS
            (SELECT x2.sp_objid
            FROM table_part_inst pi,
              sa.TABLE_MOD_LEVEL ML2,
              sa.TABLE_PART_NUM PN2 ,
              adfcrm_serv_plan_CLASS_matview x2
            WHERE pi.PART_SERIAL_NO = in_esn
            AND ML2.OBJID           = PI.N_PART_INST2PART_MOD
            AND pn2.objid           = ml2.part_info2part_num
            AND x2.part_class_objid = PN2.PART_NUM2PART_CLASS
            )
          SELECT NVL(mv.fea_value,0),
            mv.sp_objid,
            tc.objid
          INTO lv_points,
            lv_service_plan,
            lv_case_objid
          FROM table_x_call_trans ct,
            table_case tc,
            table_x_case_detail tcd,
            adfcrm_serv_plan_feat_matview mv,
            esn_serv_plan esp
          WHERE 1                 =1
          AND ct.objid            = in_call_trans_objid
          AND ct.x_service_id     = tc.x_esn
          AND tc.s_title          = 'REPLACEMENT UNITS'
          AND tc.objid            = tcd.detail2case
          AND tcd.x_name          = 'SERVICE_PLAN'
          AND mv.fea_name         = lc_point_category_reward
          AND mv.sp_mkt_name      = tcd.x_value
          AND mv.sp_objid         = esp.sp_Objid
          AND NVL(mv.fea_value,0) > 0 ;
        EXCEPTION
        WHEN OTHERS THEN
          lv_points       := 0;
          lv_service_plan := NULL;
        END;
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        sa.ota_util_pkg.err_log ( p_action => 'Get points and plan', p_error_date => sysdate, p_key => 'in_call_trans_objid='||in_call_trans_objid || '.', p_program_name => 'p_get_points_n_plan', p_error_text => 'Err while selecting plan points' ||', in_call_trans_objid='||in_call_trans_objid ||', in_call_trans_actiontype='||in_call_trans_actiontype ||', in_call_trans_reason='||in_call_trans_reason ||', Err='||SUBSTR(sqlerrm, 1, 2000));
        lv_points       := 0;
        lv_service_plan := 0;
        lv_purch_txn    := 0;
        lv_table_name   := NULL;
  END ;

  IF NVL(lv_points, 0)   > 0 THEN
    IF lv_xph_objid     IS NOT NULL THEN
      lv_table_name     := 'X_PROGRAM_PURCH_HDR';
      lv_purch_txn      := lv_xph_objid;
    elsif lv_trc_objid  IS NOT NULL THEN
      lv_table_name     := 'TABLE_X_RED_CARD';
      lv_purch_txn      := lv_trc_objid;
    elsif lv_case_objid IS NOT NULL THEN
      lv_table_name     := 'TABLE_CASE';
      lv_purch_txn      := lv_case_objid;
      /*CR32367 changes: vs*/
    elsif lv_ct_obj_id    IS NOT NULL THEN
      lv_table_name       := 'TABLE_X_CALL_TRANS';
      lv_purch_txn        := lv_ct_obj_id;
    elsif lv_enr_obj_id   IS NOT NULL THEN
      lv_table_name       := 'X_PROGRAM_ENROLLED';
      lv_purch_txn        :=lv_enr_obj_id;
    elsif lv_site_part_id IS NOT NULL THEN
      lv_table_name       := 'TABLE_SITE_PART';
      lv_purch_txn        :=lv_site_part_id;
      /*end CR32367 changes: vs*/
    elsif lv_purch_txn IS NOT NULL THEN
      lv_table_name    := 'TABLE_SITE_PART';
    END IF;
  ELSE
    lv_table_name := NULL;
  END IF;
      /*dbms_output.put_line(' CT.Objid='||in_call_trans_objid
      ||', lv_table_name='||lv_table_name
      ||', lv_service_plan='||lv_service_plan
      || ' ******* lv_points='||lv_points);
      */
  out_points_earned    := lv_points;
  out_points_plan      := lv_service_plan;
  out_purch_objid      := lv_purch_txn;
  out_purch_table_name := lv_table_name;
END p_get_points_n_plan;

PROCEDURE p_check_point_account(
    in_min IN VARCHAR2,
    in_esn IN VARCHAR2,
    out_account_objid OUT NUMBER,
    out_account_bus_org OUT NUMBER )
IS
  rec_point_account cur_point_account%rowtype;
  lv_steps_completed INTEGER;
  lv_count           INTEGER;
  lv_expiry_date     DATE;
  rec_esn_brand cur_esn_brand%rowtype;
BEGIN
  ---dbms_output.put_line('**** START OF PROCEDURE p_check_point_account ****');
  lv_steps_completed := 0;
  --retrieve the current brand of min and esn
  OPEN cur_esn_brand(in_esn);
  FETCH cur_esn_brand INTO rec_esn_brand;
  CLOSE cur_esn_brand;
  SELECT COUNT(1)
  INTO lv_count
  FROM x_rewarD_point_values rpv
  WHERE 1=1
  AND sysdate BETWEEN rpv.x_start_date AND rpv.x_end_date
  AND rpv.x_point_category = lc_point_category_reward
  AND rpv.bus_org_objid    = rec_esn_brand.bus_org_objid;
  IF NVL(lv_count,0)       = 0 THEN
    out_account_objid     := NULL;
    out_account_bus_org   := rec_esn_brand.bus_org_objid;
    /*dbms_output.put_line('*** esn='||in_esn
    || ' having brand='||rec_esn_brand.bus_org_objid
    || ' not eligible for reward_points account'
    );*/
    RETURN;
  END IF;
  --check if point account exists for input MIN
  OPEN cur_point_account('MIN',in_min, rec_esn_brand.bus_org_objid); --always use MIN
  FETCH cur_point_account INTO rec_point_account;
  CLOSE cur_point_account;
  out_account_bus_org        := rec_esn_brand.bus_org_objid;
  IF rec_point_account.x_min IS NOT NULL THEN
    --account exist for min and brand
    --; so nothing to do anymore; simply return account objid
    NULL;
    out_account_objid  := rec_point_account.objid;
    lv_steps_completed := lv_steps_completed + 1;
  ELSE
    --account not exists for MIN so create a new account
    out_account_objid := sa.seq_x_point_account.nextval;
    --check if ESN is exists in point_account
    rec_point_account := NULL;
    OPEN cur_point_account('ESN',in_esn, rec_esn_brand.bus_org_objid);
    FETCH cur_point_account INTO rec_point_account;
    CLOSE cur_point_account;
    INSERT
    INTO table_x_point_account
      (
        objid,
        x_min,
        x_esn,
        total_points,
        x_points_category,
        x_last_calc_date,
        account_status,
        account_status_reason,
        bus_org_objid
      )
      VALUES
      (
        out_account_objid,
        in_min,
        in_esn,
        0,
        lc_point_category_reward,
        sysdate-5, --just created the account so should be able to read point-trans for last 5 days
        'ACTIVE',
        'Activated on '
        || TO_CHAR(sysdate, 'dd-mon-yyyy hh24:mi'),
        rec_esn_brand.bus_org_objid
      );
    lv_job_insert_rec_counter := lv_job_insert_rec_counter + 1;
    ---DBMS_OUTPUT.PUT_LINE('1 RECORD INSERTED INTO table_x_point_account');
    lv_steps_completed         := lv_steps_completed + 1;
    IF rec_point_account.objid IS NULL THEN
      --this means MIN has changed brand
      --do not transfer points from old brand to new brand
      --till here we have setup the account for new min and brand
      --nothing to do any more.
      NULL;
    ELSE
      --that means ESN exists with another MIN
      --this is MIN change scenario within same brand
      --for example Min Changed from Esn1 to Esn2
      --update old account as inactive
      UPDATE table_x_point_account
      SET account_status      = 'INACTIVE',
        account_status_reason = 'MIN Change on'
        || TO_CHAR(sysdate, 'dd-mon-yyyy hh24:mi')
        || ', Points transferred to new MIN='
        || in_min,
        x_last_calc_date = sysdate
      WHERE objid        = rec_point_account.objid returning x_expiry_date
      INTO lv_expiry_date; -- VS:051715 expiry date return
      --DBMS_OUTPUT.PUT_LINE('1 RECORD UPDATED INTO table_x_point_account TO UPDATE OLD ACCOUNT AS INACTIVE');
      lv_steps_completed := lv_steps_completed + 1;
      /*CR32367:VS:051715: Expiry check on source account for MINCHANGE point transfer*/
      IF lv_expiry_date IS NULL OR lv_expiry_date > sysdate THEN
        /*CR32367:VS:05/07/2015 Adding this update to get the old MIN's benefits
        associated to the new MIN's point account record*/
        UPDATE table_x_point_account xpa
        SET subscriber_uid = rec_point_account.subscriber_uid
        WHERE xpa.objid    = out_account_objid
        AND x_min          = in_min
        AND x_esn          = in_esn;
        --insert record for total number of points transferred from Min1 to Min2
        INSERT
        INTO table_x_point_trans
          (
            objid,
            x_trans_date,
            x_min,
            x_esn,
            x_points,
            x_points_category,
            x_points_action,
            points_action_reason,
            point_trans2ref_table_objid,
            ref_table_name,
            point_trans2service_plan,
            point_trans2point_account,
            point_trans2purchase_objid,
            purchase_table_name,
            point_trans2site_part,
            point_display_reason
          )
          VALUES
          (
            sa.seq_x_point_trans.nextval,
            sysdate,
            in_min,
            in_esn,
            rec_point_account.total_points,
            lc_point_category_reward,
            'ADD',
            'Points earned through MINCHANGE from Old MIN='
            || rec_point_account.x_min ,
            rec_point_account.objid,
            'TABLE_X_POINT_ACCOUNT',
            NULL,
            out_account_objid,
            NULL,
            NULL,
            NULL,
            'Points transfered from other MIN'
          );
        lv_steps_completed        := lv_steps_completed        + 1;
        lv_job_insert_rec_counter := lv_job_insert_rec_counter + 1;
      END IF ; -- VS:05/17/15 ending expiry check on source account
      ---DBMS_OUTPUT.PUT_LINE('1 RECORD INSERTED INTO table_x_point_trans for total number of points transferred from Min1 to Min2');
    END IF;
  END IF;
  lv_steps_completed := lv_steps_completed + 1;
  ---dbms_output.put_line('**** END OF PROCEDURE p_check_point_account ****');
EXCEPTION
WHEN OTHERS THEN
  out_account_objid   := NULL;
  out_account_bus_org := NULL;
  sa.ota_util_pkg.err_log ( p_action => 'p_check_point_account', p_error_date => sysdate, p_key => NULL, p_program_name => 'p_check_point_account', p_error_text => 'steps_completed='|| lv_steps_completed ||', err='|| SUBSTR(sqlerrm,1,500) );
  --DBMS_OUTPUT.PUT_LINE(' OTHERS Exc=' || dbms_utility.format_error_backtrace );
  --DBMS_OUTPUT.PUT_LINE('**** EXCEPTION WHILE RUNNING PROCEDURE p_check_point_account ****' );
END p_check_point_account;
FUNCTION f_get_points_history
  (
    in_key   IN VARCHAR2,
    in_value IN VARCHAR2
  )
  RETURN tab_points_hist pipelined
IS
  /*
  function: f_get_points_history - can be used to fetch point transactions
  */
  rec_esn cur_esn_min_dtl%rowtype;
  rec_points_hist typ_rec_points_hist;
  lv_my_esn VARCHAR2(30);
  lv_my_min VARCHAR2(30);
  /* cursor cur_points_hist (in_esn in varchar2, in_min in varchar2) is
  select pt.objid,
  pt.x_trans_date,
  pt.x_points,
  pt.x_points_action,
  pt.x_points_category,
  pa.x_min,
  pa.x_esn,
  pt.points_action_reason, --CR32367 vs:0512/2015
  pt.point_display_reason
  from table_x_point_trans pt, table_x_point_account pa
  where 1=1
  and pa.objid = pt.point_trans2point_account
  and pt.x_points_action in ('ADD', 'DEDUCT', 'REFUND', 'CONSUMED', 'ESNUPGRADE', 'CONVERT') --SQA1891:VS:051415:adding CONVERT
  and pa.account_status = 'ACTIVE'
  and pa.x_esn = in_esn
  and pa.x_min = in_min
  order by pt.objid;*/
  /*VS:052915 changing the cursor to accomodate TAS reasons CR32367 */
  CURSOR cur_points_hist (in_esn IN VARCHAR2, in_min IN VARCHAR2)
  IS
    SELECT pt.objid,
      pt.x_trans_date,
      pt.x_points,
      pt.x_points_action,
      pt.x_points_category,
      pa.x_min,
      pa.x_esn,
      pt.points_action_reason, --CR32367 vs:0512/2015
      pt.point_display_reason
    FROM table_x_point_trans pt,
      table_x_point_account pa
    WHERE 1                 =1
    AND pa.objid            = pt.point_trans2point_account
    AND pt.x_points_action IN ('ADD', 'DEDUCT', 'REFUND', 'CONSUMED', 'ESNUPGRADE', 'CONVERT') --SQA1891:VS:051415:adding CONVERT
    AND pa.account_status   = 'ACTIVE'
    AND pa.x_esn            = in_esn
    AND pa.x_min            = in_min
    AND NOT ( upper(pt.points_action_reason) LIKE '%EXPIRED POINTS REMOVED ON REACTIVATION ACT_EXPDT%'
    AND pt.x_points_action   = 'DEDUCT'
    AND point_display_reason = 'Expired')
  UNION
  SELECT pt.objid,
    pa.x_expiry_date,
    -1*(pa.total_points) x_points,
    'DEDUCT' x_points_action,
    pt.x_points_category,
    pa.x_min,
    pa.x_esn,
    pt.points_action_reason, --CR32367 vs:0512/2015
    CASE
      WHEN (upper(pt.POINTS_ACTION_REASON) LIKE '%REASON=PORT%')
      THEN 'Ported Out'
      ELSE 'Expired'
    END point_display_reason
  FROM table_x_point_trans pt,
    table_x_point_account pa
  WHERE 1                =1
  AND pa.objid           = pt.point_trans2point_account
  AND(pt.x_points_action = 'NOTE'
  AND (upper(pt.POINTS_ACTION_REASON) LIKE 'ACTION_TYPE=2%'
  OR upper(pt.POINTS_ACTION_REASON) LIKE 'ACTION_TYPE=20%' ) )
  AND pa.account_status = 'ACTIVE'
  AND pa.x_esn          = in_esn
  AND pa.x_min          = in_min
  AND pa.x_expiry_date  < sysdate
  AND NOT ( upper(pt.points_action_reason) LIKE '%EXPIRED POINTS REMOVED ON REACTIVATION ACT_EXPDT%'
  AND pt.x_points_action   = 'DEDUCT'
  AND point_display_reason = 'Expired' )
  ORDER BY objid;
BEGIN
  OPEN cur_esn_min_dtl(in_key, in_value);
  FETCH cur_esn_min_dtl INTO rec_esn;
  CLOSE cur_esn_min_dtl;
  IF rec_esn.x_esn IS NOT NULL AND rec_esn.x_min IS NOT NULL THEN
    lv_my_esn      := rec_esn.x_esn;
    lv_my_min      := rec_esn.x_min;
  ELSE
    SELECT x_min,
      x_service_id
    INTO lv_my_min,
      lv_my_esn
    FROM table_site_part tsp
    WHERE tsp.objid =
      (SELECT MAX(objid)
      FROM table_site_part tsp_inactive
      WHERE 1                        =1
      AND ( tsp_inactive.part_status = 'Inactive')
      AND ( ( in_key                 = 'ESN'
      AND tsp_inactive.x_service_id  = in_value )
      OR ( in_key                    = 'MIN'
      AND tsp_inactive.x_min         = in_value ) )
      ) ;
  END IF;
  FOR irec IN cur_points_hist (lv_my_esn, lv_my_min)
  LOOP
    rec_points_hist.objid                 := irec.objid ;
    rec_points_hist.x_min                 := irec.x_min ;
    rec_points_hist.x_esn                 := irec.x_esn ;
    rec_points_hist.x_points              := irec.x_points ;
    rec_points_hist.x_trans_date          := irec.x_trans_date ;
    rec_points_hist.x_points_action       := irec.x_points_action ;
    rec_points_hist.x_points_category     := irec.x_points_category ;
    rec_points_hist.points_action_reason  := irec.point_display_reason; --CR32367 vs:0512/2015
    rec_points_hist.display_action_reason := irec.point_display_reason; --CR32367 vs:0512/2015
    pipe row (rec_points_hist);
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  NULL;
  RETURN;
END f_get_points_history;
PROCEDURE p_get_reward_summary(
    in_key            IN VARCHAR2,
    in_value          IN VARCHAR2,
    in_point_category IN VARCHAR2 DEFAULT 'REWARD_POINTS',
    out_total_points OUT NUMBER,
    out_subscriber_id OUT VARCHAR2,
    out_reward_total OUT NUMBER,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
  lv_total_points  NUMBER;
  lv_subscriber_id VARCHAR2(40);
  lv_err_code      INTEGER;
  lv_err_msg       VARCHAR2(2000);
BEGIN
  p_get_reward_points( in_key => in_key , in_value => in_value, in_point_category => in_point_category , out_total_points => lv_total_points , out_subscriber_id => lv_subscriber_id , out_err_code => lv_err_code , out_err_msg => lv_err_msg );
  IF lv_err_code      <> 0 THEN
    out_total_points  := 0;
    out_reward_total  := 0;
    out_subscriber_id := lv_subscriber_id;
    out_err_code      :=lv_err_code;
    out_err_msg       := lv_err_msg;
    RETURN ;
  ELSE
    IF lv_subscriber_id IS NOT NULL AND lv_subscriber_id <> '0' THEN
      SELECT NVL(SUM(to_number(xbp.x_benefit_value)), 0)
      INTO out_reward_total
      FROM table_x_benefits xb,
        table_x_benefit_programs xbp
      WHERE xb.benefits2benefit_program = xbp.objid
      AND XB.X_BENEFIT_OWNER_VALUE      = lv_subscriber_id
      AND XB.X_BENEFIT_OWNER_TYPE       = 'SID'
      AND XB.X_STATUS                   = '961'
      AND(XB.X_EXPIRY_DATE             IS NULL
      OR XB.X_EXPIRY_DATE               > sysdate) ;
    END IF;
    out_reward_total  := NVL(out_reward_total,0); --CR52398 Added this change to handle NULL pointer exception.
    out_total_points  := lv_total_points;
    out_subscriber_id := lv_subscriber_id;
    out_err_code      :=lv_err_code;
    out_err_msg       := lv_err_msg;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  out_total_points := 0;
  out_reward_total := 0;
  --out_amount := 0;
  out_subscriber_id := NULL;
  out_err_code      := -99;
  out_err_msg       := 'p_get_reward_summary FAILURE...'||' ERR=' || SUBSTR(sqlerrm,1,500);
  sa.ota_util_pkg.err_log ( p_action => 'Got OTHERS exception ..', p_error_date => sysdate, p_key => 'P_GET_REWARD_SUMMARY', p_program_name => 'P_GET_REWARD_SUMMARY', p_error_text => in_key || '='|| in_value || '. Out_err_code='||out_err_code || ', Out_err_msg='|| out_err_msg );
END p_get_reward_summary;
PROCEDURE p_get_reward_points(
    in_key            IN VARCHAR2,
    in_value          IN VARCHAR2,
    in_point_category IN VARCHAR2 DEFAULT 'REWARD_POINTS',
    out_total_points OUT NUMBER,
    out_amount OUT NUMBER,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
BEGIN
  out_total_points := 0;
  out_amount       := 0;
  out_err_code     := -1;
  out_err_msg      := 'DO NOT USE THIS PROCEDURE ANYMORE. USE SAME PROCEDURE WITH DIFFERENT SIGNATURE';
END;
PROCEDURE p_compensate_reward_points(
    in_key               IN VARCHAR2,
    in_value             IN VARCHAR2,
    in_points            IN NUMBER,
    in_points_category   IN VARCHAR2 DEFAULT 'REWARD_POINTS',
    in_points_action     IN VARCHAR2,
    in_user_objid        IN NUMBER,
    in_compensate_reason IN VARCHAR2,
    out_total_points OUT NUMBER,
    out_amount OUT NUMBER,
    inout_transaction_id IN OUT NUMBER,
    out_err_code OUT INTEGER,
    out_err_msg OUT VARCHAR2 )
IS
BEGIN
  out_total_points     := 0;
  out_amount           := 0;
  inout_transaction_id := 0;
  out_err_code         := -1;
  out_err_msg          := 'DO NOT USE THIS PROCEDURE ANYMORE. USE SAME PROCEDURE WITH DIFFERENT SIGNATURE';
END;
PROCEDURE p_insert_bonus_points
AS
  CURSOR c1
  IS
    SELECT objid,
      x_min,
      x_esn ,
      x_points,
      x_reason,
      x_benefit_type
    FROM sa.table_x_bonus_points_load bpl
    WHERE status IS NULL
    AND NOT EXISTS
      (SELECT 1
      FROM sa.table_x_point_trans pt
      WHERE pt.POINT_TRANS2REF_TABLE_OBJID = bpl.objid
      AND pt.REF_TABLE_NAME                = 'TABLE_X_BONUS_POINTS_LOAD'
      ) ;
type rec_bonus_pts
IS
  TABLE OF c1%rowtype;
  tab_bonus_pts rec_bonus_pts;
  v_min                  VARCHAR2(30);
  v_esn                  VARCHAR2(30);
  v_points               NUMBER;
  c_bonus_pts            CONSTANT VARCHAR2(40) := 'BONUS_POINTS';
  c_add_action           CONSTANT VARCHAR2(40) := 'ADD';
  c_user_objid           CONSTANT NUMBER       := 0;
  v_compensate_reason    VARCHAR2(200);
  v_service_plan_objid   NUMBER := NULL;
  v_out_total_points     NUMBER;
  v_inout_transaction_id NUMBER;
  v_out_err_code         NUMBER;
  v_out_err_msg          VARCHAR2(200);
  v_pts_catgry           VARCHAR2(40);
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 bulk collect INTO tab_bonus_pts limit 1000;
    EXIT
  WHEN tab_bonus_pts.count = 0;
    FOR i IN 1 .. tab_bonus_pts.count
    LOOP
      v_min               := trim(regexp_replace(tab_bonus_pts(i).x_min,'[[:punct:]]', ''));
      v_esn               := trim(regexp_replace(tab_bonus_pts(i).x_esn,'[[:punct:]]', ''));
      v_points            := trim(tab_bonus_pts(i).x_points);
      v_compensate_reason := NVL(trim(SUBSTR(tab_bonus_pts(i).x_reason, 1, 2000)), 'BONUS_POINTS');
      v_pts_catgry        := REPLACE(tab_bonus_pts(i).x_benefit_type, chr(13), '');
      sa.REWARD_POINTS_PKG.P_COMPENSATE_BONUS_POINTS( IN_KEY => 'ESN', IN_VALUE => v_esn, IN_POINTS => v_points, IN_POINTS_CATEGORY => v_pts_catgry, IN_POINTS_ACTION => c_add_action, IN_USER_OBJID => c_user_objid, IN_COMPENSATE_REASON => v_compensate_reason, IN_SERVICE_PLAN_OBJID => v_service_plan_objid, IN_BONUS_OBJID => tab_bonus_pts(i).objid, OUT_TOTAL_POINTS => v_out_total_points, INOUT_TRANSACTION_ID => v_inout_transaction_id, OUT_ERR_CODE => v_out_err_code, OUT_ERR_MSG => v_out_err_msg );
      IF v_out_err_code = 0 THEN
        dbms_output.put_line('ESN: '||tab_bonus_pts(i).x_esn||' MIN: '||tab_bonus_pts(i).x_esn||' processed successfully');
        UPDATE table_x_bonus_points_load
        SET status  = 'SUCCESS'
        WHERE x_esn = tab_bonus_pts(i).x_esn
        AND x_min   = tab_bonus_pts(i).x_min;
      ELSE
        dbms_output.put_line('ESN: '||tab_bonus_pts(i).x_esn||' MIN: '||tab_bonus_pts(i).x_min||' process failed');
        UPDATE table_x_bonus_points_load
        SET status  = 'FAIL',
          error_msg = v_out_err_msg
        WHERE x_esn = tab_bonus_pts(i).x_esn
        AND x_min   = tab_bonus_pts(i).x_min;
      END IF;
      COMMIT;
    END LOOP;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line('ERROR_MSG:'||SQLERRM);
  raise;
END p_insert_bonus_points;
/*this procedure is built as a back up if required to overcome timestamp issue
this is not in use now*/
PROCEDURE p_insert_bonus_points_ia
AS
  CURSOR c1
  IS
    SELECT objid,
      x_min,
      x_esn ,
      x_points,
      x_reason,
      x_benefit_type
    FROM sa.table_x_bonus_points_load bpl
    WHERE status IS NULL
    AND NOT EXISTS
      (SELECT 1
      FROM sa.table_x_point_trans pt
      WHERE pt.POINT_TRANS2REF_TABLE_OBJID = bpl.objid
      AND pt.REF_TABLE_NAME                = 'TABLE_X_BONUS_POINTS_LOAD'
      ) ;
type rec_bonus_pts
IS
  TABLE OF c1%rowtype;
  tab_bonus_pts rec_bonus_pts;
  v_status               VARCHAR2(30);
  v_min                  VARCHAR2(30);
  v_esn                  VARCHAR2(30);
  v_points               NUMBER;
  c_bonus_pts            CONSTANT VARCHAR2(40) := 'BONUS_POINTS';
  c_add_action           CONSTANT VARCHAR2(40) := 'ADD';
  c_user_objid           CONSTANT NUMBER       := 0;
  v_compensate_reason    VARCHAR2(200);
  v_service_plan_objid   NUMBER := NULL;
  v_out_total_points     NUMBER;
  v_inout_transaction_id NUMBER;
  v_out_err_code         NUMBER;
  v_out_err_msg          VARCHAR2(200);
  v_pts_catgry           VARCHAR2(40);
  v_x_min                VARCHAR2(40);
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 bulk collect INTO tab_bonus_pts limit 1000;
    EXIT
  WHEN tab_bonus_pts.count = 0;
    dbms_output.put_line('loopin P_COMPENSATE_bonus_POINTS ');
    FOR i IN 1 .. tab_bonus_pts.count
    LOOP
      v_min               := trim(regexp_replace(tab_bonus_pts(i).x_min,'[[:punct:]]', ''));
      v_esn               := trim(regexp_replace(tab_bonus_pts(i).x_esn,'[[:punct:]]', ''));
      v_points            := trim(tab_bonus_pts(i).x_points);
      v_compensate_reason := NVL(trim(SUBSTR(tab_bonus_pts(i).x_reason, 1, 2000)), 'BONUS_POINTS');
      v_pts_catgry        := REPLACE(tab_bonus_pts(i).x_benefit_type, chr(13), '');
      -- SA.REWARD_POINTS_PKG.P_COMPENSATE_BONUS_POINTS_IA(  --CR43497
      P_COMPENSATE_BONUS_POINTS_IA( IN_KEY => 'ESN', IN_VALUE => v_esn, IN_POINTS => v_points, IN_POINTS_CATEGORY => v_pts_catgry, IN_POINTS_ACTION => c_add_action, IN_USER_OBJID => c_user_objid, IN_COMPENSATE_REASON => v_compensate_reason, IN_SERVICE_PLAN_OBJID => v_service_plan_objid, IN_BONUS_OBJID => tab_bonus_pts(i).objid, OUT_X_MIN => v_x_min, OUT_TOTAL_POINTS => v_out_total_points, INOUT_TRANSACTION_ID => v_inout_transaction_id, OUT_ERR_CODE => v_out_err_code, OUT_ERR_MSG => v_out_err_msg );
      dbms_output.put_line('v_out_total_points:'||v_out_total_points);
      dbms_output.put_line('v_points:'||v_out_total_points);
      dbms_output.put_line('v_out_err_code:'||v_out_err_code);
      dbms_output.put_line('v_out_err_msg:'||v_out_err_msg);
      IF v_out_err_code <> 0 THEN
        --dbms_output.put_line('ESN: '||tab_bonus_pts(i).x_esn||' MIN: '||tab_bonus_pts(i).x_min||' process failed');
        UPDATE table_x_bonus_points_load
        SET status     = 'FAIL',
          error_msg    = v_out_err_msg
        WHERE x_esn    = tab_bonus_pts(i).x_esn
        AND x_min      = tab_bonus_pts(i).x_min
        AND objid      = tab_bonus_pts(i).objid;
        v_out_err_msg := NULL;
      END IF;
    END LOOP ;
    dbms_output.put_line('looping calculate points benfits' );
    FOR i IN 1 .. tab_bonus_pts.count
    LOOP
      SELECT status
      INTO v_status
      FROM table_x_bonus_points_load
      WHERE objid  = tab_bonus_pts(i).objid;
      IF v_status IS NULL THEN
        p_calculate_points (v_x_min, v_out_err_code, v_out_err_msg);
        IF v_out_err_code <> 0 THEN
          UPDATE table_x_bonus_points_load
          SET status  = 'FAIL',
            error_msg = 'On Calc_points:'
            ||v_out_err_msg
          WHERE x_esn     = tab_bonus_pts(i).x_esn
          AND x_min       = tab_bonus_pts(i).x_min
          AND objid       = tab_bonus_pts(i).objid;
          v_out_err_code :=0;
          v_out_err_msg  := NULL;
          CONTINUE;
        END IF;
        --check if total points have reached the maximum value
        --and may be eligible to create a reward benefit
        --03/24/2015 CR32367
        sa.reward_benefits_n_vouchers_pkg.p_create_reward_benefits ( in_min => v_x_min ,out_err_code => v_out_err_code ,out_err_msg => v_out_err_msg );
        IF v_out_err_code <> 0 THEN
          UPDATE table_x_bonus_points_load
          SET status  = 'FAIL',
            error_msg = 'On benefits:'
            ||v_out_err_msg
          WHERE x_esn = tab_bonus_pts(i).x_esn
          AND x_min   = tab_bonus_pts(i).x_min
          AND objid   = tab_bonus_pts(i).objid;
          CONTINUE;
        END IF ;
        UPDATE table_x_bonus_points_load
        SET status  = 'SUCCESS'
        WHERE x_esn = tab_bonus_pts(i).x_esn
        AND x_min   = tab_bonus_pts(i).x_min
        AND objid   = tab_bonus_pts(i).objid;
      END IF;
    END LOOP;
    COMMIT;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line('ERROR_MSG:'||SQLERRM);
  raise;
END p_insert_bonus_points_ia;
END reward_points_pkg;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/REWARD_POINTS_PKB.sql 	CR52398: 1.115
/