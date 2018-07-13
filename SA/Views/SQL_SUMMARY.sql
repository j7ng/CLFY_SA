CREATE OR REPLACE FORCE VIEW sa.sql_summary (username,sharable_mem,persistent_mem,runtime_mem) AS
select username, sharable_mem, persistent_mem, runtime_mem
from   sys.v_$sqlarea a, dba_users b
where  a.parsing_user_id = b.user_id;