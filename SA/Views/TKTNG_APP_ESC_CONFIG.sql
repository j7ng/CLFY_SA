CREATE OR REPLACE FORCE VIEW sa.tktng_app_esc_config (ec_objid,from_priority,to_priority,x_eval_escalation,x_hot_transfer,x_script_id_hot,x_script_id_cold,x_script_id_grace,h_objid) AS
select distinct ec_objid,
       from_priority,
       to_priority,
       x_eval_escalation,
       x_hot_transfer,
       x_script_id_hot,
       x_script_id_cold,
       x_script_id_grace,
       h_objid
from   sa.tktng_app_esc_triggers
where  p_objid != -1
order by substr(from_priority,1,1) ;