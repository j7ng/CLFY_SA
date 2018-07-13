CREATE OR REPLACE FORCE VIEW sa.adfcrm_case_history_v (id_number,status,x_esn,creation_time,x_case_type,title,contact_objid,issue) AS
SELECT ecase.id_number,
    ecase.status ,
    ecase.x_esn,
    ecase.creation_time,
    ecase.x_case_type ,
    ecase.title,
    c.OBJID AS contact_objid,
    ecase.issue
  FROM table_extactcase ecase,
    table_contact c
  WHERE 1                 =1
  AND ecase.contact_objid = c.objid
    -- and    c.objid = 294579057
    -- and    c.x_cust_id = '30498514' --'1019553976'
  ORDER BY creation_time,
    x_esn;