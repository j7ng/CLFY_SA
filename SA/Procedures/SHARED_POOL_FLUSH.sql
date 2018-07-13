CREATE OR REPLACE PROCEDURE sa.shared_pool_flush AS
fp number;
BEGIN

  SELECT ROUND(f.bytes/s.sgasize*100, 2) into fp
FROM    (SELECT 'shared pool' pool,SUM(bytes) sgasize FROM v$sgastat where  pool='shared pool') s, v$sgastat f
WHERE  f.name = 'free memory'  AND f.pool = s.pool;

if fp<20 then
    DBMS_OUTPUT.PUT_LINE ('Flushing Shared Pool ...');
    execute immediate 'ALTER SYSTEM FLUSH SHARED_POOL';
END IF;
END;
/