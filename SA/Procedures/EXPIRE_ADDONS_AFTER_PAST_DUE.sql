CREATE OR REPLACE PROCEDURE sa."EXPIRE_ADDONS_AFTER_PAST_DUE" ( i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                                                i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                                                i_bulk_collection_limit IN  NUMBER DEFAULT 200  ,
                                                                o_response              OUT VARCHAR2            ) AS

/*=========================================================================================================
  -- Expire the active addons in grp benefit table after past due + 30 days  (service_end_dt + 30 days)
  =========================================================================================================*/

  -- temporary record to hold required attributes
  TYPE acct_grp_benefit_record IS RECORD ( pp_benefit VARCHAR(1)  ,
                                           rowid   VARCHAR2(100)  ,
                                           objid   NUMBER         ,
                                           esn     VARCHAR2(100)  ,
                                           insert_timestamp DATE) ;

  -- based on record above
  TYPE acct_grp_process_list IS TABLE OF acct_grp_benefit_record;

  -- table to hold array of data
  grp_benefit_rec acct_grp_process_list;

  -- get active addons
  CURSOR c_get_active_addons IS
    SELECT   'N' pp_benefit, agb.rowid, agb.objid, ct.x_service_id esn, agb.insert_timestamp
      FROM   sa.x_account_group_benefit agb,
             sa.table_x_call_trans ct
     WHERE   1 =1
       AND   agb.call_trans_id = ct.objid
       AND   agb.end_date < trunc(SYSDATE) + 0.99999
       AND   agb.status = 'ACTIVE'
       AND   ROWNUM <= i_max_rows_limit
    UNION
    SELECT   'Y' pp_benefit, agb.rowid, agb.objid, agb.pcrf_esn esn, agb.insert_timestamp
      FROM   sa.x_pageplus_addon_benefit agb
     WHERE   1 =1
       AND   agb.end_date < trunc(SYSDATE) + 0.99999
       AND   agb.status = 'ACTIVE'
       AND   ROWNUM <= i_max_rows_limit
    ;

  --
  n_count_rows  NUMBER := 0;
  v_upd_cnt     NUMBER := 0;
  v_del_cnt     NUMBER := 0;
  --
  s sa.subscriber_type := sa.subscriber_type();

-- used to determine if a transaction exists that needs to be update
FUNCTION exists_active_addons RETURN BOOLEAN IS
  n_count NUMBER := 0;
BEGIN

  SELECT COUNT(1)
  INTO   n_count
  FROM   dual
  WHERE  EXISTS ( SELECT 1
                  FROM   sa.x_account_group_benefit agb,
                         sa.table_x_call_trans ct
                  WHERE  1 =1
                  AND    agb.call_trans_id = ct.objid
                  AND    agb.end_date < trunc(SYSDATE) + 0.99999
                  AND    agb.status = 'ACTIVE'
                  AND    ROWNUM <= i_max_rows_limit
                  UNION
                  SELECT 1
                  FROM   sa.x_pageplus_addon_benefit agb
                  WHERE  1 =1
                  AND    agb.end_date < trunc(SYSDATE) + 0.99999
                  AND    agb.status = 'ACTIVE'
                  AND    ROWNUM <= i_max_rows_limit
                );
  --
  RETURN ( CASE
             WHEN n_count > 0 THEN TRUE
             ELSE FALSE
           END );
  --
 EXCEPTION
   WHEN others THEN
     RETURN FALSE;
END exists_active_addons;

BEGIN
  -- perform a loop while applicable if record exists
  WHILE ( exists_active_addons )
  LOOP

    -- open cursor to get active adds transaction records
    OPEN c_get_active_addons;

    -- start loop
    LOOP

      -- fetch cursor data into  collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_get_active_addons BULK COLLECT INTO grp_benefit_rec LIMIT i_bulk_collection_limit;

      -- loop through collection
      FOR i IN 1 .. grp_benefit_rec.COUNT LOOP

       IF grp_benefit_rec(i).pp_benefit = 'N' THEN
          --
          UPDATE sa.x_account_group_benefit
            SET  STATUS = 'EXPIRED',
                 REASON = 'EXPIRED FROM EXPIRE ADDON JOB',
                 END_DATE = SYSDATE
          WHERE  ROWID = grp_benefit_rec(i).rowid;
       ELSE
          -- page plus benefit
          UPDATE sa.x_pageplus_addon_benefit
            SET  STATUS = 'EXPIRED',
                 REASON = 'EXPIRED FROM EXPIRE ADDON JOB',
                 END_DATE = SYSDATE
          WHERE  ROWID = grp_benefit_rec(i).rowid;
       END IF;

       v_upd_cnt := v_upd_cnt+ SQL%ROWCOUNT;

       -- clean up in SPR detail
       DELETE
       FROM   sa.x_subscriber_spr_detail
       WHERE  acct_grp_benefit_objid = grp_benefit_rec(i).objid;
       --AND    subscriber_spr_objid IN (SELECT objid
       --                                FROM   sa.x_subscriber_spr
       --                                WHERE  pcrf_esn =  grp_benefit_rec(i).esn);
       -- increase row count
       n_count_rows := n_count_rows + 1;

       IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
         -- Save changes
         COMMIT;
       END IF;
       --
      END LOOP; --
      --
      EXIT WHEN c_get_active_addons%NOTFOUND;
      --
    END LOOP;

    CLOSE c_get_active_addons;

    -- exit when there are no more records to expire
    EXIT WHEN NOT ( exists_active_addons );

  END LOOP; -- WHILE (exists)

  -- Save changes
  COMMIT;

  n_count_rows := 0;

  -- Return successful execution
  DBMS_OUTPUT.PUT_LINE('No of Records updated : '||v_upd_cnt);
  o_response := 'SUCCESS';

  --
  -- Expire the spr detail expired add ons / bad data
  delete
  from  sa.x_subscriber_spr_detail sprd
  where sprd.add_on_ttl < trunc(sysdate) + 0.99999
  and   exists (select 1
                from   sa.x_account_group_benefit agb
                where  sprd.acct_grp_benefit_objid = agb.objid
                and    agb.status = 'EXPIRED'
                );

  COMMIT;
  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN EXPIRE_ACTIVE_ADDONS: ' || SQLERRM;
     RAISE;

END expire_addons_after_past_due;
/