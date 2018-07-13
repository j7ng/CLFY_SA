CREATE OR REPLACE PROCEDURE sa.utilization1
IS
/********************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved              */
/*                                                                              */
/* NAME     :       UTILIZATION1                                                */
/* PURPOSE  :       Creates line utilization tables                             */
/*                  of TFPhonePart Java. CBO logic rewritten in PL/SQL for      */
/*                  Stabilization project                                       */
/* FREQUENCY:                                                                   */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                               */
/*                                                                              */
/* REVISIONS:                                                                   */
/* VERSION  DATE            WHO         PURPOSE                                 */
/* -------  ----------     -----       ------------------------------------     */
/*  1.0     05/02/2000      ????        Initial  Revision                       */
/*  1.1     07/08/04       VAdapa       CR2912 - Check SID_TYPE based on the    */
/*                                      technologies instead of MASTER value    */
/*                                      SQL tuned by Hanif Mohammad             */
/********************************************************************************/
   CURSOR c1 (tablename CHAR)
   IS
      SELECT 'x'
        FROM user_tables
       WHERE table_name = '' || tablename || '';


   c1_rec c1%ROWTYPE;

   sql1 VARCHAR2 (2000) := 'DROP TABLE LINE_UTILIZATION';
   sql1a VARCHAR2 (2000) := 'DROP TABLE UT_TEMP1';
   sql1b VARCHAR2 (2000) := 'DROP TABLE UT_TEMP2';
   sql1c VARCHAR2 (2000) := 'DROP TABLE UT_TEMP3';
   sql1d VARCHAR2 (2000) := 'DROP TABLE UT_TEMP4';
   sql_indx VARCHAR2 (2000)
         := 'create index Utilization1 on LINE_UTILIZATION(STATE,ZONE,MARKETID,CARRIER_ID,SID)
                    tablespace clfy_indx';
   v_week CHAR (2);
   v_year CHAR (4);
   cid NUMBER;
   getrows NUMBER;
   sql2a VARCHAR (3000);
   sql2b VARCHAR (3000);
   sql2c VARCHAR (3000);
   sql2d VARCHAR (3000);
   sql3 VARCHAR (3000);
   v_cnt INTEGER;
BEGIN

   OPEN c1 ('LINE_UTILIZATION');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;
--CR2912 Changes
--    sql2a := 'CREATE TABLE UT_TEMP1 AS
-- select SUBSTR(A.X_MIN,1,3) AS NPA,SUBSTR(A.X_MIN,4,3) AS NXX ,
-- trunc(A.X_TRANSACT_DATE) as Day , D.X_SID AS SID,COUNT(*) as Activations from
-- SA.TABLE_X_CALL_TRANS A,
-- SA.TABLE_X_CARRIER B,
-- SA.TABLE_X_CARR_PERSONALITY C,
-- SA.TABLE_X_SIDS D
-- where A.x_result = ''Completed''
--    and ((A.x_action_type = ''1'') OR (A.x_action_type = ''3'')) and
--    trunc(A.X_TRANSACT_DATE) between  trunc(sysdate - 7) and trunc(sysdate -1 )
--    and A.X_CALL_TRANS2CARRIER = B.OBJID
--    AND B.CARRIER2PERSONALITY = C.OBJID
--    AND D.X_SID_TYPE = ''MASTER''
--    AND C.OBJID = D.SIDS2PERSONALITY
--  group by  SUBSTR(A.X_MIN,1,3),SUBSTR(A.X_MIN,4,3), trunc(A.X_TRANSACT_DATE), D.X_SID';
   sql2a := 'CREATE TABLE UT_TEMP1 AS
select  /*+ NO_MERGE */  NPA,NXX,
Day , D.X_SID AS SID,COUNT(*) as Activations from
SA.TABLE_X_CARRIER B,
SA.TABLE_X_CARR_PERSONALITY C,
SA.TABLE_X_SIDS D,        (SELECT /*+ NO_MERGE */ SUBSTR(A.X_MIN,1,3) AS NPA,SUBSTR(A.X_MIN,4,3) AS NXX ,
          trunc(A.X_TRANSACT_DATE) as Day, X_CALL_TRANS2CARRIER
         FROM SA.TABLE_X_CALL_TRANS A
         where A.x_result = ''Completed''
         and ((A.x_action_type = ''1'') OR (A.x_action_type = ''3'')) and
               A.X_TRANSACT_DATE   between  trunc(sysdate - 7) and trunc(sysdate-1) + 0.99999  ) Qry1
WHERE  Qry1.X_CALL_TRANS2CARRIER = B.OBJID
   AND B.CARRIER2PERSONALITY = C.OBJID
   AND D.X_SID_TYPE IN (''ANALOG'',''TDMA'',''CDMA'',''GSM'')
   AND C.OBJID = D.SIDS2PERSONALITY
group by  NPA,NXX, Day, D.X_SID';
--End CR2912 Changes


   OPEN c1 ('UT_TEMP1');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1a, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;

   cid := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (cid, sql2a, DBMS_SQL.v7);
   DBMS_SQL.close_cursor (cid);
   --COMMIT;
   sql2b := 'CREATE TABLE UT_TEMP2 AS SELECT DISTINCT A.NPA,A.NXX,A.CARRIER_ID,
        A.CARRIER_NAME,A.MARKETID,A.MRKT_AREA,A.ZONE,A.STATE FROM SA.NPANXX2CARRIERZONES A,
        UT_TEMP1 B WHERE A.NPA=B.NPA AND A.NXX=B.NXX';

   OPEN c1 ('UT_TEMP2');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1b, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;
   cid := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (cid, sql2b, DBMS_SQL.v7);
   DBMS_SQL.close_cursor (cid);
   --COMMIT;
   sql2c := 'CREATE TABLE UT_TEMP3 AS
        SELECT  A.NPA,A.NXX,A.SID,a.Activations,a.day,B.CARRIER_ID,B.CARRIER_NAME,B.MARKETID,
        B.MRKT_AREA,B.ZONE,B.STATE FROM UT_TEMP1 a,
        UT_TEMP2 B WHERE A.NPA=B.NPA AND A.NXX=B.NXX';

   OPEN c1 ('UT_TEMP3');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1c, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;
   cid := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (cid, sql2c, DBMS_SQL.v7);
   DBMS_SQL.close_cursor (cid);
   --COMMIT;
   sql2d := 'CREATE TABLE UT_TEMP4 AS
       SELECT STATE ,ZONE, MARKETID, MRKT_AREA, CARRIER_ID,CARRIER_NAME,SID, SUM(ACTIVATIONS) MAXI_ACTIVATIONS
              FROM UT_TEMP3
              GROUP BY STATE ,ZONE,MARKETID, MRKT_AREA, CARRIER_ID,CARRIER_NAME,SID,DAY';

   OPEN c1 ('UT_TEMP4');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1d, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;
   cid := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (cid, sql2d, DBMS_SQL.v7);
   DBMS_SQL.close_cursor (cid);
   --COMMIT;
   sql3 := 'CREATE TABLE LINE_UTILIZATION AS
              SELECT STATE ,ZONE, MARKETID, MRKT_AREA, CARRIER_ID,CARRIER_NAME,SID,AVG(MAXI_ACTIVATIONS) AV_ACTIVATIONS, MAX(MAXI_ACTIVATIONS) MAX_ACTIVATIONS
              FROM UT_TEMP4
              GROUP BY STATE ,ZONE,MARKETID, MRKT_AREA, CARRIER_ID,CARRIER_NAME,SID';

   cid := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (cid, sql3, DBMS_SQL.v7);
   getrows := DBMS_SQL.execute (cid);
   DBMS_SQL.close_cursor (cid);
   COMMIT;

   cid := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (cid, sql_indx, DBMS_SQL.v7);
   getrows := DBMS_SQL.execute (cid);
   DBMS_SQL.close_cursor (cid);

   OPEN c1 ('UT_TEMP1');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1a, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;

   OPEN c1 ('UT_TEMP2');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1b, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;

   OPEN c1 ('UT_TEMP3');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1c, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;

   OPEN c1 ('UT_TEMP4');
   FETCH c1 INTO c1_rec;


   IF c1%FOUND
   THEN
      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (cid, sql1d, DBMS_SQL.v7);
      DBMS_SQL.close_cursor (cid);
   END IF;

   CLOSE c1;
END;
/