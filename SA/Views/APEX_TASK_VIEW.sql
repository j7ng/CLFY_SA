CREATE OR REPLACE FORCE VIEW sa.apex_task_view (q_objid,id_number,title,age,carrier_id,carrier_name,esn,"CONDITION",status,"PRIORITY",severity,creation_time) AS
select /*+ FIRST_ROWS(250) */
         t.task_currq2queue q_objid,
         t.task_id id_number,
         t.title,
         con.queue_time age,
         'n/a' Carrier_ID,
         'n/a' Carrier_Name,
         'n/a' esn,
         con.title condition,
         decode(t.task_sts2gbst_elm,
                '268435580','In Progress',
                '268435581','Wait On Others',
                '268435582','Deferred',
                '268436604','In Blackout',
                '268436605','Sent AOL',
                '268436606','NTN',
                '268436607','Re-Work',
                '268436608','Expedite',
                '268436609','Failed - Open',
                '268436610','Sent ICI',
                '268436611','Sent Manual',
                '268436612','Queued',
                '268436613','Created',
                t.task_sts2gbst_elm) status,
         'n/a' priority,
         'n/a' severity,
         to_char(start_date, 'MM/DD/YYYY HH:MI:SS PM') creation_time
  from   table_task t,
         table_condition con
  where  con.objid = t.task_state2condition
  and    t.task_currq2queue is not null
  and    con.title != 'CLOSED';