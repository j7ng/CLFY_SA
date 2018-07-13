CREATE OR REPLACE PROCEDURE sa.sp_purge2dayold_event_stats
IS
BEGIN
  delete from table_x_event_stats
    where time_stamp < sysdate - 2;
  commit;
END sp_purge2dayold_event_stats;



/