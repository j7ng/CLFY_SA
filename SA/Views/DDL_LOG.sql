CREATE OR REPLACE FORCE VIEW sa.ddl_log (osuser,oracleuser,ddl_date,ddl_type,object_type,"OBJECT","PROGRAM",machine) AS
SELECT osuser,
            oracleuser,
     --       TO_DATE (ddl_date, 'dd-Mon-yy hh:mi:ss pm')
            ddl_date,
            ddl_type,
            object_type,
            object_owner || '.' || object_name object,
            program,
            machine
       FROM sys."AUDIT$DDL_LOG"
      WHERE object_owner IN ('SA', 'GW1', 'W3CI') AND oracleuser NOT IN ('SYS')
   ORDER BY 1, 3 DESC;