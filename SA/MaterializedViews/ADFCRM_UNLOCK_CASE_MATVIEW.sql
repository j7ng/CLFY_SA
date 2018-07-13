CREATE MATERIALIZED VIEW sa.adfcrm_unlock_case_matview (objid,x_esn,id_number,title,x_case_type,creation_time,alt_first_name,alt_last_name,alt_address,alt_zipcode)
ORGANIZATION HEAP 
REFRESH START WITH TO_DATE('2018-7-14 0:0:0', 'yyyy-mm-dd hh24:mi:ss') NEXT trunc(SYSDATE) + 1 
AS SELECT c.objid,
        c.x_esn,
      c.id_number,
      c.title,
      c.x_case_type,
      c.creation_time ,
      upper(trim(alt_first_name)) alt_first_name ,
      upper(trim(alt_last_name)) alt_last_name ,
      upper(trim(alt_address)) alt_address ,
      upper(trim(alt_zipcode)) alt_zipcode
FROM sa.table_case c
WHERE ( ( x_case_type  = 'Warehouse' and title = 'Unlock Exchange') or
        ( x_case_type  = 'Unlock Policy' and title = 'Locked Handset Buy Back')
      )
AND creation_time >= trunc(sysdate) - 365;
COMMENT ON MATERIALIZED VIEW sa.adfcrm_unlock_case_matview IS 'snapshot table for Unlock cases for last 365 days.';