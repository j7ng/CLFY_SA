CREATE OR REPLACE PROCEDURE sa."ARCHIVE_SPR_REPROCESS_LOG" ( i_archive_from_days     IN  NUMBER DEFAULT 7    ,
                                                              i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                                              i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                                              i_bulk_collection_limit IN  NUMBER DEFAULT 200  ,
                                                              o_response              OUT VARCHAR2            ) AS

  -- temporary record to hold required attributes
  TYPE spr_reprocess_record IS RECORD ( rowid   VARCHAR2(100) ,
                                        objid   NUMBER        );

  -- based on record above
  TYPE spr_reprocess_list IS TABLE OF spr_reprocess_record;

  -- table to hold array of data
  spr_rec spr_reprocess_list;

  -- get spr reprocess transactions (limit the rows to be retrieved)
  CURSOR c_reprocess_list IS
    SELECT *
    FROM   ( SELECT rowid, objid
             FROM   sa.x_spr_reprocess_log
             WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
           )
    WHERE  ROWNUM <= i_max_rows_limit;

  --
  n_count_rows  NUMBER := 0;
  --

-- used to determine if a transaction exists that needs to be delete
FUNCTION exists_archive_process RETURN BOOLEAN IS
  n_count NUMBER := 0;
BEGIN

  SELECT COUNT(1)
  INTO   n_count
  FROM   dual
  WHERE  EXISTS ( SELECT 1
                  FROM   sa.x_spr_reprocess_log
                  WHERE  insert_timestamp < TRUNC(SYSDATE - i_archive_from_days)
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
END exists_archive_process;


BEGIN
  -- perform a loop while applicable if record exists
  WHILE ( exists_archive_process )
  LOOP

    -- open cursor for spr_log transaction records
    OPEN c_reprocess_list;

    -- start loop
    LOOP

      -- fetch cursor data into  collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_reprocess_list BULK COLLECT INTO spr_rec LIMIT i_bulk_collection_limit;

      -- loop through collection
      FOR i IN 1 .. spr_rec.COUNT LOOP

       DELETE  sa.x_spr_reprocess_log
        WHERE  ROWID = spr_rec(i).rowid;


        -- increase row count
        n_count_rows := n_count_rows + 1;

        IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
          -- Save changes
          COMMIT;
        END IF;
        --
      END LOOP; --
      --
      EXIT WHEN c_reprocess_list%NOTFOUND;
      --
    END LOOP;

    CLOSE c_reprocess_list;

    -- exit when there are no more records to archive
    EXIT WHEN NOT ( exists_archive_process );

  END LOOP; -- WHILE (exists)

  -- Save changes
  COMMIT;

  n_count_rows := 0;


  COMMIT;

  -- Return successful execution
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN ARCHIVE_SPR_REPROCESS_LOG: ' || SQLERRM;
     RAISE;

END archive_spr_reprocess_log;
/