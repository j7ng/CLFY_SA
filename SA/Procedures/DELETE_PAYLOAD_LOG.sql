CREATE OR REPLACE PROCEDURE sa."DELETE_PAYLOAD_LOG" ( i_archive_from_days     IN  NUMBER DEFAULT 30    ,
                                                          i_max_rows_limit        IN  NUMBER DEFAULT 1000 ,
                                                          i_commit_every_rows     IN  NUMBER DEFAULT 5000 ,
                                                          i_bulk_collection_limit IN  NUMBER DEFAULT 200  ,
														  o_response              OUT VARCHAR2            ) AS
  -- temporary record to hold required attributes
  TYPE payload_record IS RECORD ( rowid   VARCHAR2(100) );

  -- based on record above
  TYPE payloadList IS TABLE OF payload_record;

  -- table to hold array of data
  payload payloadList;

  -- get payload transactions (limit the rows to be retrieved)
  CURSOR c_payload IS
    SELECT *
    FROM   ( SELECT rowid
             FROM   q_payload_log
             WHERE  1=1
             AND    creation_date < TRUNC(SYSDATE - i_archive_from_days)
           )
    WHERE  ROWNUM <= i_max_rows_limit;

  --
  n_count_rows  NUMBER := 0;
  --

-- used to determine if a payload transaction exists that needs to be archived
FUNCTION exists_payload RETURN BOOLEAN IS
  n_count NUMBER := 0;
BEGIN

  SELECT COUNT(1)
  INTO   n_count
  FROM   dual
  WHERE  EXISTS ( SELECT 1
                  FROM   q_payload_log
                  WHERE  1=1
                  AND    creation_date < TRUNC(SYSDATE - i_archive_from_days)
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
END exists_payload;

BEGIN
  -- perform a loop while applicable payload record exists
  WHILE ( exists_payload )
  LOOP

    -- open cursor for payload transaction records
    OPEN c_payload;

    -- start loop
    LOOP

      -- fetch cursor data into payload collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_payload BULK COLLECT INTO payload LIMIT i_bulk_collection_limit;

      -- loop through payload collection
      FOR i IN 1 .. payload.COUNT LOOP



        DELETE sa.q_payload_log
        WHERE  ROWID = payload(i).rowid;


        -- increase row count
        n_count_rows := n_count_rows + 1;

        IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
          -- Save changes
          COMMIT;
        END IF;
        --
      END LOOP; -- c_payload
      --
      EXIT WHEN c_payload%NOTFOUND;
      --
    END LOOP;

    CLOSE c_payload;

    -- exit when there are no more records to archive
    EXIT WHEN NOT ( exists_payload );

  END LOOP; -- WHILE (exists_payload)

  -- Save changes
  COMMIT;

  n_count_rows := 0;




  -- Return successful execution
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     --
     o_response := 'ERROR IN delete_payload_log: ' || SQLERRM;
     RAISE;

END delete_payload_log;
/