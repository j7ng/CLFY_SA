CREATE OR REPLACE FORCE VIEW sa.action_item_view (s_status,t_objid,status,"OWNER",s_queue,"QUEUE",x_order_type,current_method,t_id,start_date,f_name,l_name,"CONDITION",s_condition,carr_name,carr_mkt,x_esn,x_min) AS
SELECT st.s_title s_status,
    t.objid t_objid,
    st.title status,
    u.login_name owner,
    q.s_title s_queue ,
    q.title queue,
    ot.x_order_type,
    tp.x_transmit_method current_method,
    t.task_id "T_ID",
    t."START_DATE",
    c.First_NAME f_name,
    c.Last_name L_NAME,
    con.title "CONDITION",
    con.s_title "S_CONDITION",
    cg.x_carrier_name carr_name,
    carr.x_mkt_submkt_name carr_mkt,
    ct.x_service_id "X_ESN",
    ct."X_MIN"
  FROM sa.table_task t,
    sa.table_condition con,
    sa.table_x_call_trans ct,
    sa.table_x_carrier carr,
    sa.table_x_carrier_group cg,
    sa.table_queue q,
    sa.table_contact c,
    sa.table_x_order_type ot,
    sa.table_x_trans_profile tp,
    sa.table_gbst_elm st,
    sa.table_user u
  WHERE task_currq2queue              = q.objid(+)
  AND con.objid                       = t.task_state2condition
  AND ct.objid                        = t.x_task2x_call_trans
  AND c.objid                         = t.task2contact
  AND carr.objid                      = ct.x_call_trans2carrier
  AND cg.objid                        = carr.CARRIER2CARRIER_GROUP
  AND t.x_task2x_order_type           = ot.objid(+)
  AND task_owner2user                 = u.objid
  AND st.objid                        = t.task_sts2gbst_elm
  AND ot.x_order_type2x_trans_profile = tp.objid;