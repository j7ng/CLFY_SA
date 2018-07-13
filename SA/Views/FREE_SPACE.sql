CREATE OR REPLACE FORCE VIEW sa.free_space ("TABLESPACE",file_id,pieces,free_bytes,free_blocks,largest_bytes,largest_blks) AS
SELECT tablespace_name, file_id, COUNT(*),
    SUM(bytes), SUM(blocks),
    MAX(bytes), MAX(blocks) FROM sys.dba_free_space
GROUP BY tablespace_name, file_id ;