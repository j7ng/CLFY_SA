CREATE OR REPLACE PROCEDURE sa."ARCHIVE_TTOFF_TRANSACTION_LOG" ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                                                  i_max_rows_limit        IN  NUMBER DEFAULT 5000 ,
                                                                  o_response              OUT VARCHAR2            ) AS

 BEGIN
  LOOP
    delete
    from   w3ci.x_ttoff_transactions_hist
    where  update_timestamp < trunc(sysdate - i_archive_from_days)
    and    rownum <= i_max_rows_limit;

    commit;

    exit when sql%rowcount = 0;

  END LOOP;

  COMMIT;

  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN ARCHIVE_TTOFF_TRANSACTION_LOG: ' || SQLERRM;
     RAISE;

END archive_ttoff_transaction_log;
/