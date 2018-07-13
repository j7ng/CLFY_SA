CREATE OR REPLACE PROCEDURE sa.get_wfm_migrated_ban(i_ban               IN VARCHAR2 ,
                                                    i_min               IN VARCHAR2 ,
                                                    i_amount_paid       IN NUMBER   ,
						    i_quote_amount      IN NUMBER   ,
                                                    i_external_order_id IN VARCHAR2 ,
                                                    o_migrated_status   OUT VARCHAR2,
                                                    o_errnum            OUT NUMBER  ,
                                                    o_errstr            OUT VARCHAR2)
AS
  l_ban VARCHAR2(50);
  CURSOR c_ban (p_ban VARCHAR2)
  IS
    SELECT ban,
      COUNT(*) AS total_line_count,
      SUM(
      CASE
        WHEN MIGRATION_STATUS='FINAL_MIGRATION_COMPLETED'
        THEN 1
        ELSE 0
      END ) migration_completed_count
    FROM WFMMIG.X_WFM_ACCT_MIGRATION_BILL_STG
    WHERE ban=p_ban
    GROUP BY ban;
  c_ban_rec c_ban%ROWTYPE;
  n_account_stg_cnt NUMBER :=0;
BEGIN
  --validate input
  IF i_ban   IS NULL AND i_min IS NULL THEN
    o_errnum := 101;
    o_errstr := 'ERROR - BAN and MIN NOT PASSED';
    RETURN;
  END IF;

  --Get BAN from MIN
  l_ban    := i_ban;
  IF i_ban IS NULL AND i_min IS NOT NULL THEN
    BEGIN
      SELECT ban
      INTO l_ban
      FROM
        (SELECT ban,MIN FROM wfmmig.x_wfm_acct_migration_bill_stg WHERE MIN=i_min
        UNION
        SELECT ban,MIN FROM wfmmig.x_wfm_acct_migration_stg WHERE MIN=i_min
        )
      WHERE MIN =i_min
      AND rownum=1;
    EXCEPTION
    WHEN OTHERS THEN
      l_ban:=NULL;
    END;
    IF l_ban   IS NULL THEN

      --Insert record into x_wfm_payment_not_migrated
       INSERT INTO x_wfm_payment_not_migrated
       (objid            ,
        ban              ,
        min              ,
        external_order_id,
        amount_paid      ,
        migration_status ,
        transact_date    ,
        insert_timestamp ,
        update_timestamp ,
	quote_amount
        )
        VALUES
        (seq_x_wfm_payment_not_migrated.nextval,
	 i_ban                              ,
	 i_min                              ,
	 i_external_order_id                ,
	 i_amount_paid                      ,
	 'MGR'                              ,
         SYSDATE                            ,
	 SYSDATE                            ,
	 SYSDATE                            ,
 	 i_quote_amount
	 );
      o_migrated_status := 'MGR'; --MIGRATED New customers SOA require MIGRATED
      o_errnum          := 0;
      o_errstr          := 'SUCCESS' ;
      RETURN;
    END IF;
  END IF;

  --Get Total Line count and Migrated line count
  OPEN c_ban (l_ban);
  FETCH c_ban INTO c_ban_rec;
  IF c_ban%notfound THEN
    CLOSE c_ban;
    BEGIN
      SELECT COUNT(*)
      INTO n_account_stg_cnt
      FROM wfmmig.x_wfm_acct_migration_stg
      WHERE ban=l_ban;
    EXCEPTION
    WHEN OTHERS THEN
      n_account_stg_cnt := 0;
    END;
    IF n_account_stg_cnt =0 THEN

      --Insert record into x_wfm_payment_not_migrated
       INSERT INTO x_wfm_payment_not_migrated
       (objid            ,
        ban              ,
        min              ,
        external_order_id,
        amount_paid      ,
        migration_status ,
        transact_date    ,
        insert_timestamp ,
        update_timestamp ,
	quote_amount
        )
        VALUES
        (seq_x_wfm_payment_not_migrated.nextval,
	 i_ban                              ,
	 i_min                              ,
	 i_external_order_id                ,
	 i_amount_paid                      ,
	 'MGR'                              ,
         SYSDATE                            ,
	 SYSDATE                            ,
	 SYSDATE                            ,
 	 i_quote_amount
	 );

      o_migrated_status := 'MGR'; --MIGRATED New customers SOA require MIGRATED
      o_errnum          := 0;
      o_errstr          := 'SUCCESS' ;
      RETURN;
    ELSE
       --Insert record into x_wfm_payment_not_migrated
       INSERT INTO x_wfm_payment_not_migrated
       (objid            ,
        ban              ,
        min              ,
        external_order_id,
        amount_paid      ,
        migration_status ,
        transact_date    ,
        insert_timestamp ,
        update_timestamp ,
	quote_amount
        )
        VALUES
        (seq_x_wfm_payment_not_migrated.nextval,
	 i_ban                              ,
	 i_min                              ,
	 i_external_order_id                ,
	 i_amount_paid                      ,
	 'NMG'                              ,
         SYSDATE                            ,
	 SYSDATE                            ,
	 SYSDATE                            ,
 	 i_quote_amount
	 );
      o_migrated_status := 'NMG'; --NOT MIGRATED
      o_errnum          := 0;
      o_errstr          := 'SUCCESS' ;
      RETURN;
    END IF;
  END IF;
  CLOSE c_ban;
  IF c_ban_rec.total_line_count             = c_ban_rec.migration_completed_count THEN

     --Insert record into x_wfm_payment_not_migrated
       INSERT INTO x_wfm_payment_not_migrated
       (objid            ,
        ban              ,
        min              ,
        external_order_id,
        amount_paid      ,
        migration_status ,
        transact_date    ,
        insert_timestamp ,
        update_timestamp ,
	quote_amount
        )
        VALUES
        (seq_x_wfm_payment_not_migrated.nextval,
	 i_ban                              ,
	 i_min                              ,
	 i_external_order_id                ,
	 i_amount_paid                      ,
	 'MGR'                              ,
         SYSDATE                            ,
	 SYSDATE                            ,
	 SYSDATE                            ,
 	 i_quote_amount
	 );
    o_migrated_status                      := 'MGR'; --MIGRATED

  elsif c_ban_rec.migration_completed_count = 0 THEN

    --Insert record into x_wfm_payment_not_migrated
       INSERT INTO x_wfm_payment_not_migrated
       (objid            ,
        ban              ,
        min              ,
        external_order_id,
        amount_paid      ,
        migration_status ,
        transact_date    ,
        insert_timestamp ,
        update_timestamp ,
	quote_amount
        )
        VALUES
        (seq_x_wfm_payment_not_migrated.nextval,
	 i_ban                              ,
	 i_min                              ,
	 i_external_order_id                ,
	 i_amount_paid                      ,
	 'NMG'                              ,
         SYSDATE                            ,
	 SYSDATE                            ,
	 SYSDATE                            ,
 	 i_quote_amount
	 );

    o_migrated_status                      := 'NMG'; --NOT MIGRATED
  ELSE
    --Insert record into x_wfm_payment_not_migrated
       INSERT INTO x_wfm_payment_not_migrated
       (objid            ,
        ban              ,
        min              ,
        external_order_id,
        amount_paid      ,
        migration_status ,
        transact_date    ,
        insert_timestamp ,
        update_timestamp ,
	quote_amount
        )
        VALUES
        (seq_x_wfm_payment_not_migrated.nextval,
	 i_ban                              ,
	 i_min                              ,
	 i_external_order_id                ,
	 i_amount_paid                      ,
	 'INP'                              ,
         SYSDATE                            ,
	 SYSDATE                            ,
	 SYSDATE                            ,
 	 i_quote_amount
	 );
    o_migrated_status := 'INP'; --MIGRATION IN PROGRESS
  END IF;
  o_errnum := 0;
  o_errstr := 'SUCCESS' ;
EXCEPTION
WHEN OTHERS THEN
  o_errnum := 104;
  o_errstr := 'ERROR - '|| SUBSTR(sqlerrm,1,200) ;
END;
/