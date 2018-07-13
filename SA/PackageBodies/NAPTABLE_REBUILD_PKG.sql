CREATE OR REPLACE PACKAGE BODY sa.NapTable_Rebuild_pkg
/*****************************************************************************/
/* Name         :  NapTableRebuild_Pkg
/* Purpose      :  Rebuilds NapTables based on master tables and mapinfo_data
/* Author       :  Gerald Pintado
/* Date         :  09/27/2005
/* Revisions    :
/* Version Date        Who            Purpose
/* ------- ----------  -------------  --------------------------
/* 1.0     09/27/2005  Gerald Pintado Initial Release
/*****************************************************************************/
AS

/*********************************************************************/
/*
/* Renames the NapTable's backup back to their original name
/*
/*********************************************************************/
PROCEDURE REVERT_NAPTABLE
(ip_tablename IN VARCHAR2,
 op_result   OUT VARCHAR2)
is

val1 varchar2(200) :=
 'RENAME ' ||ip_tablename || ' to ' ||ip_tablename || '_bkup1';

 val2 varchar2(200) :=
 'RENAME ' ||ip_tablename || '_bkup to ' ||ip_tablename;

 val3 varchar2(200) :=
 'RENAME ' ||ip_tablename || '_bkup1 to ' ||ip_tablename || '_bkup';

 cid number;
 getrows number;
 v_errm varchar2(300);

BEGIN
  dbms_output.put_line('1');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val1,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('2');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val2,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('3');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  OP_RESULT := 'Revert Complete';

EXCEPTION
WHEN OTHERS THEN
 v_errm := substr(sqlerrm,1,300);
 OP_RESULT := v_errm;
END;


/*********************************************************************/
/*
/* Renames the MasterTable's backup back to their original name
/*
/*********************************************************************/
PROCEDURE REVERT_NAPTABLE_MASTER
(ip_tablename IN VARCHAR2,
 op_result   OUT VARCHAR2)
is

val1 varchar2(200) :=
 'RENAME ' ||ip_tablename || '_master to ' ||ip_tablename || '_mbkup1';

 val2 varchar2(200) :=
 'RENAME ' ||ip_tablename || '_mbkup to ' ||ip_tablename ||'_master';

 val3 varchar2(200) :=
 'RENAME ' ||ip_tablename || '_mbkup1 to ' ||ip_tablename || '_mbkup';

 cid number;
 getrows number;
 v_errm varchar2(300);

BEGIN
  dbms_output.put_line('1');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val1,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('2');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val2,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('3');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  OP_RESULT := 'Revert Complete';

EXCEPTION
WHEN OTHERS THEN
 v_errm := substr(sqlerrm,1,300);
 OP_RESULT := v_errm;
END;



/*********************************************************************/
/*
/* Procedure to rebuild carrierzones table with new data
/*
/*********************************************************************/
PROCEDURE REBUILD_CARRIERZONES
(
 ip_tablename  IN VARCHAR2,
 op_result     OUT VARCHAR2
 )
is

 val1 varchar2(200) :=
 'DROP table ' ||ip_tablename;

 val2 varchar2(200) :=
 'DROP table carrierzones_bkup';

 val3 varchar2(400) :=
 'CREATE table ' || ip_tablename || '
  tablespace clfy_data
  STORAGE(INITIAL 1M
  NEXT 10M)
  as
  Select * From carrierzones';

 val3a varchar2(800) :=
 'DELETE ' || ip_tablename || ' WHERE (carrier_name,zip) in (select distinct a.zipcode,a.carrier_name
  from toppapp.mapinfo_data a, carrierzones_master b
  Where b.zip = a.zipcode
  and a.carrier_name = b.carrier_name)';



 val3b varchar2(4000) :=
'INSERT INTO ' || ip_tablename || '
 (
   ZIP,ST,COUNTY,ZONE,RATE_CENTE,MARKETID,
   MRKT_AREA,CITY,BTA_MKT_NUMBER,BTA_MKT_NAME,CARRIER_ID,
   CARRIER_NAME,ZIP_STATUS,SIM_PROFILE,SIM_PROFILE_2,PLANTYPE
  )
 Select DISTINCT
        a.ZIP,
        b.pulling_ratecenter_state ST,
        a.county,
        b.pulling_ratecenter ZONE,
        a.RATE_CENTE,
        a.MARKETID,
        a.MRKT_AREA,
        a.CITY,
        a.BTA_MKT_NUMBER,
        a.BTA_MKT_NAME,
        0 carrier_id,
        a.CARRIER_NAME,
        a.ZIP_STATUS,
        a.SIM_PROFILE,
        a.SIM_PROFILE_2,
        b.plantype
   From carrierzones_master a, toppapp.mapinfo_data b
  Where a.carrier_name = b.carrier_name
    And a.zip = b.ZIPCODE';

 val4 varchar2(200) :=
 'ALTER index idx_carrierzones_ratecenter RENAME to idx_carrierzones_rate_bkup';

 val5 varchar2(200) :=
 'ALTER index idx_carrierzones_zip RENAME to idx_carrierzones_zip_bkup';

 val6 varchar2(200) :=
 'CREATE INDEX idx_carrierzones_zip
  ON '|| ip_tablename ||' (ZIP) TABLESPACE CLFY_INDX
  STORAGE(INITIAL 1M
  NEXT 5M)';

 val7 varchar2(200) :=
 'CREATE INDEX idx_carrierzones_ratecenter
  ON '|| ip_tablename ||' (RATE_CENTE) TABLESPACE CLFY_INDX
  STORAGE(INITIAL 1M
  NEXT 5M)';

 val8 varchar2(100) :=
 'GRANT SELECT ON '|| ip_tablename ||' TO NAP_SELECT_ROLE';
 val9 varchar2(100) :=
 'GRANT ALTER ON '|| ip_tablename ||' TO "PUBLIC"';
 val10 varchar2(100) :=
 'GRANT DELETE ON '|| ip_tablename ||' TO "PUBLIC"';
 val11 varchar2(100) :=
 'GRANT INDEX ON '|| ip_tablename ||' TO "PUBLIC"';
 val12 varchar2(100) :=
 'GRANT INSERT ON '|| ip_tablename ||' TO "PUBLIC"';
 val13 varchar2(100) :=
 'GRANT REFERENCES ON '|| ip_tablename ||' TO "PUBLIC"';
 val14 varchar2(100) :=
 'GRANT SELECT ON '|| ip_tablename ||' TO "PUBLIC"';
 val15 varchar2(100) :=
 'GRANT UPDATE ON '|| ip_tablename ||' TO "PUBLIC"';

 val16 varchar2(200) :=
 'RENAME carrierzones to carrierzones_bkup';

 val17 varchar2(200) :=
 'RENAME ' || ip_tablename || ' to carrierzones';

  cid number;
  getrows number;
  v_errm varchar2(300);
Begin
 dbms_output.put_line('1');
  Begin
   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid,val1,dbms_sql.native);
   getrows := dbms_sql.execute(cid);
   dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('2');
  Begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val2,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('3');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('3a');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3a,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('3b');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3b,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);


  dbms_output.put_line('4');
  Begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val4,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('5');
  Begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val5,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('6');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val6,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('7');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val7,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('8');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val8,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('9');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val9,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('10');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val10,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('11');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val11,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('12');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val12,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('13');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val13,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('14');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val14,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('15');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val15,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);


  dbms_output.put_line('16');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val16,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('17');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val17,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  OP_RESULT := 'Rebuild Complete';

EXCEPTION
WHEN OTHERS THEN
 v_errm := substr(sqlerrm,1,300);
 OP_RESULT := v_errm;
end;



/*********************************************************************/
/*
/* Procedure to rebuild npanxx2carrierzones table with new data
/*
/*********************************************************************/
PROCEDURE REBUILD_NPANXX2CARRIERZONES
(
 ip_tablename  IN VARCHAR2,
 op_result     OUT VARCHAR2
 )
is

 val1 varchar2(200) :=
 'DROP table ' ||ip_tablename;

 val2 varchar2(200) :=
 'DROP table npanxx2carrierzones_bkup';

 val3 varchar2(400) :=
 'CREATE table ' || ip_tablename || '
  tablespace clfy_data
  STORAGE(INITIAL 1M
  NEXT 10M)
  as
  Select * From npanxx2carrierzones';

 val3a varchar2(800) :=
 'DELETE ' || ip_tablename || ' WHERE (carrier_name,npa,nxx) in (select distinct a.carrier_name,a.npa,a.nxx
  from toppapp.mapinfo_data a, npanxx2carrierzones_master b
  Where a.npa = b.npa
  And a.nxx = b.nxx
  And a.carrier_name = b.carrier_name)';
 val3b varchar2(4000) :=
'INSERT INTO ' || ip_tablename || '
(
 NPA,NXX,CARRIER_ID,CARRIER_NAME,LEAD_TIME,TARGET_LEVEL,
 RATECENTER,STATE,CARRIER_ID_DESCRIPTION,ZONE,COUNTY,MARKETID,
 MRKT_AREA,SID,TECHNOLOGY,FREQUENCY1,FREQUENCY2,BTA_MKT_NUMBER,
 BTA_MKT_NAME,GSM_TECH,CDMA_TECH,TDMA_TECH,MNC
 )
 select DISTINCT
    a.NPA,
    a.NXX,
    a.CARRIER_ID,
    a.CARRIER_NAME,
    a.LEAD_TIME,
    a.TARGET_LEVEL,
    a.RATECENTER,
    b.pulling_ratecenter_state state,
    a.CARRIER_ID_DESCRIPTION,
    b.pulling_ratecenter zone,
    a.COUNTY,
    a.MARKETID,
    a.MRKT_AREA,
    a.SID,
    a.TECHNOLOGY,
    a.FREQUENCY1,
    a.FREQUENCY2,
    a.BTA_MKT_NUMBER,
    a.BTA_MKT_NAME,
    a.GSM_TECH,
    a.CDMA_TECH,
    a.TDMA_TECH,
    a.MNC
  from sa.npanxx2carrierzones_master a, toppapp.mapinfo_data b
 where a.carrier_name = b.carrier_name
   and a.npa = b.npa
   and a.nxx = b.nxx';

 val4 varchar2(200) :=
 'ALTER index idx_NPANXX1_ZONE RENAME to idx_NPANXX1_ZONE_bkup';

 val5 varchar2(200) :=
 'ALTER index idx_NPANXX2CARRIERZONES RENAME to idx_NPANXX2CARRIERZONES_bkup';

 val6 varchar2(200) :=
 'ALTER index idx_NPANXX1_NAP RENAME to idx_NPANXX1_NAP_bkup';

 val7 varchar2(200) :=
 'ALTER index idx_NPANXX1_RATECENTER RENAME to idx_NPANXX1_RATECENTER_bkup';

 val8 varchar2(200) :=
 'ALTER index idx_NPANXX_STATE RENAME to idx_NPANXX_STATE_bkup';

 val9 varchar2(200) :=
 'ALTER index idx_NPANXX1_STATE RENAME to idx_NPANXX1_STATE_bkup';

 val10 varchar2(200) :=
 'CREATE INDEX idx_NPANXX1_ZONE
  ON '|| ip_tablename ||' (ZONE) TABLESPACE CLFY_INDX
  STORAGE(INITIAL 1M
  NEXT 5M)';

 val11 varchar2(200) :=
 'CREATE INDEX idx_NPANXX2CARRIERZONES
  ON '|| ip_tablename ||' (CARRIER_ID) TABLESPACE CLFY_INDX
  STORAGE(INITIAL 5M
  NEXT 5M)';


  val12 varchar2(200) :=
 'CREATE INDEX idx_NPANXX1_NAP
  ON '|| ip_tablename ||' (NPA,NXX,STATE,ZONE,SID,MARKETID,CARRIER_ID) TABLESPACE CLFY_INDX
  STORAGE(INITIAL 1M
  NEXT 5M)';


   val13 varchar2(200) :=
 'CREATE INDEX idx_NPANXX1_RATECENTER
  ON '|| ip_tablename ||' (RATECENTER,NPA,NXX) TABLESPACE CLFY_INDX
  STORAGE(INITIAL 1M
  NEXT 5M)';

   val14 varchar2(200) :=
 'CREATE INDEX idx_NPANXX_STATE
  ON '|| ip_tablename ||' (STATE,MRKT_AREA,MARKETID,ZONE,CARRIER_ID,CARRIER_NAME,SID) TABLESPACE CLFY_INDX
  STORAGE(INITIAL 1M
  NEXT 5M)';

   val15 varchar2(200) :=
 'CREATE INDEX idx_NPANXX1_STATE
  ON '|| ip_tablename ||' (STATE,ZONE,SID,MARKETID,CARRIER_ID) TABLESPACE CLFY_INDX
  STORAGE(INITIAL 1M
  NEXT 5M)';

 val16 varchar2(100) :=
 'GRANT SELECT ON '|| ip_tablename ||' TO NAP_SELECT_ROLE';
 val17 varchar2(100) :=
 'GRANT ALTER ON '|| ip_tablename ||' TO "PUBLIC"';
 val18 varchar2(100) :=
 'GRANT DELETE ON '|| ip_tablename ||' TO "PUBLIC"';
 val19 varchar2(100) :=
 'GRANT INDEX ON '|| ip_tablename ||' TO "PUBLIC"';
 val20 varchar2(100) :=
 'GRANT INSERT ON '|| ip_tablename ||' TO "PUBLIC"';
 val21 varchar2(100) :=
 'GRANT REFERENCES ON '|| ip_tablename ||' TO "PUBLIC"';
 val22 varchar2(100) :=
 'GRANT SELECT ON '|| ip_tablename ||' TO "PUBLIC"';
 val23 varchar2(100) :=
 'GRANT UPDATE ON '|| ip_tablename ||' TO "PUBLIC"';

 val24 varchar2(200) :=
 'RENAME npanxx2carrierzones to npanxx2carrierzones_bkup';

 val25 varchar2(200) :=
 'RENAME ' || ip_tablename || ' to npanxx2carrierzones';

  cid number;
  getrows number;
  v_errm varchar2(300);
Begin
 dbms_output.put_line('1');
  Begin
   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid,val1,dbms_sql.native);
   getrows := dbms_sql.execute(cid);
   dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('2');
  Begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val2,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('3');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('3a');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3a,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('3b');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3b,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('4');
  Begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val4,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('5');
  Begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val5,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('6');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val6,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('7');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val7,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('8');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val8,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('9');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val9,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

    dbms_output.put_line('10');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val10,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('11');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val11,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('12');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val12,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('13');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val13,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;


  dbms_output.put_line('14');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val14,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('15');
  begin
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val15,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('16');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val16,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('17');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val17,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('18');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val18,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('19');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val19,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('20');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val20,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('21');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val21,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('22');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val22,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('23');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val23,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);


  dbms_output.put_line('24');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val24,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('25');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val25,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  OP_RESULT := 'Rebuild Complete';

EXCEPTION
WHEN OTHERS THEN
 v_errm := substr(sqlerrm,1,300);
 OP_RESULT := v_errm;
end;



/*********************************************************************/
/*
/* Procedure to rebuild carrierzones Master table with new data
/*
/*********************************************************************/
PROCEDURE REBUILD_CARRIERZONES_M
(
 op_result     OUT VARCHAR2
 )
is

val1 varchar2(200) :=
 'DROP table carrierzones_mbkup';

val2 varchar2(200) :=
 'RENAME carrierzones_master to carrierzones_mbkup';

val3 varchar2(200) :=
 'ALTER index carrier_master_zip RENAME to carrier_master_zipbkup';

val4 varchar2(200) :=
 'ALTER index carrier_master_carrier RENAME to carrier_master_carrierbkup';


val5 varchar2(1000) :=
'create table carrierzones_master TABLESPACE CLFY_DATA
as
SELECT DISTINCT A.ZIP,
                B.CARRIER_NAME,
                A.COUNTY,
                A.RATE_CENTE,
                A.CITY,
                A.ZIP_STATUS,
                A.MRKT_AREA,
                A.MARKETID,
                A.BTA_MKT_NAME,
                A.BTA_MKT_NUMBER,
                A.SIM_PROFILE,
                A.SIM_PROFILE_2
FROM CARRIERZONES A,
     NPANXX2CARRIERZONES B
WHERE A.ST = B.STATE
AND A.ZONE = B.ZONE';


val6 varchar2(200) :=
'CREATE INDEX carrier_master_zip
    ON carrierzones_master(zip,carrier_name)
 TABLESPACE CLFY_INDX';

val7 varchar2(200) :=
'CREATE INDEX carrier_master_carrier
    ON carrierzones_master(carrier_name,zip)
TABLESPACE CLFY_INDX';

  cid number;
  getrows number;
  v_errm varchar2(300);

Begin

  dbms_output.put_line('1');
  Begin
   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid,val1,dbms_sql.native);
   getrows := dbms_sql.execute(cid);
   dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('2');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val2,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('3');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

	dbms_output.put_line('4');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val4,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('5');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val5,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('6');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val6,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('7');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val7,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  OP_RESULT := 'Rebuild Complete';

EXCEPTION
WHEN OTHERS THEN
 v_errm := substr(sqlerrm,1,300);
 OP_RESULT := v_errm;
end;


/************************************************************************/
/*
/* Procedure to rebuild NPANXX2carrierzones Master table with new data
/*
/************************************************************************/
PROCEDURE REBUILD_NPANXX2CARRIERZONES_M
(
 op_result     OUT VARCHAR2
 )
is

val1 varchar2(200) :=
 'DROP table npanxx2carrierzones_mbkup';

val2 varchar2(200) :=
 'RENAME npanxx2carrierzones_master to npanxx2carrierzones_mbkup';

val3 varchar2(200) :=
 'ALTER index npanxx_master_carrier RENAME to npanxx_master_carrier_bkup';

val4 varchar2(1000) :=
'Create table npanxx2carrierzones_master TABLESPACE CLFY_DATA
 as
   SELECT DISTINCT NPA,
                   NXX,
                   CARRIER_ID,
                   CARRIER_NAME,
                   LEAD_TIME,
                   TARGET_LEVEL,
                   RATECENTER,
                   CARRIER_ID_DESCRIPTION,
                   COUNTY,
                   SID,
                   ''NA'' TECHNOLOGY,
                   MARKETID,
                   MRKT_AREA,
                   BTA_MKT_NUMBER,
                   BTA_MKT_NAME,
                   FREQUENCY1,
                   FREQUENCY2,
                   GSM_TECH,
                   CDMA_TECH,
                   TDMA_TECH,
                   MNC
   FROM NPANXX2CARRIERZONES';


val5 varchar2(200) :=
'CREATE INDEX npanxx_master_carrier
    ON SA.npanxx2carrierzones_master(npa,nxx,carrier_name)
TABLESPACE CLFY_INDX';

  cid number;
  getrows number;
  v_errm varchar2(300);

Begin

  dbms_output.put_line('1');
  Begin
   cid := dbms_sql.open_cursor;
   dbms_sql.parse(cid,val1,dbms_sql.native);
   getrows := dbms_sql.execute(cid);
   dbms_sql.close_cursor(cid);
  exception when others then null;
  end;

  dbms_output.put_line('2');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val2,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('3');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val3,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

	dbms_output.put_line('4');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val4,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

  dbms_output.put_line('5');
  cid := dbms_sql.open_cursor;
  dbms_sql.parse(cid,val5,dbms_sql.native);
  getrows := dbms_sql.execute(cid);
  dbms_sql.close_cursor(cid);

	OP_RESULT := 'Rebuild Complete';

EXCEPTION
WHEN OTHERS THEN
 v_errm := substr(sqlerrm,1,300);
 OP_RESULT := v_errm;
end;



END NapTable_Rebuild_pkg;
/