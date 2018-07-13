CREATE OR REPLACE PACKAGE sa."IPOLL" as
  procedure sp_poll_intergate;
  procedure sp_poll_monitor;
  procedure sp_poll_blackout(p_cnt in number);
  procedure sp_poll_action_items;
end ipoll;
/