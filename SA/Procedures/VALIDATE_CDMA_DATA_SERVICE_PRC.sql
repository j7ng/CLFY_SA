CREATE OR REPLACE PROCEDURE sa."VALIDATE_CDMA_DATA_SERVICE_PRC"
( IP_ZIPCODE IN VARCHAR2
, OP_RESULT OUT NUMBER
) AS

cursor cdma_cur is
SELECT  b.carrier_id
   FROM npanxx2carrierzones b, (
      SELECT DISTINCT a.ZONE,
         a.st,
         a.sim_profile,
         a.sim_profile_2,
         a.CARRIER_NAME,
         a.county
      FROM carrierzones a
      WHERE a.zip = ip_zipcode) tab1, table_x_carrier ca, table_x_carrier_group grp
      , table_x_parent pa, carrierpref pref
   WHERE b.ZONE = tab1.ZONE
   AND b.state = tab1.st
   AND ca.X_CARRIER_ID = b.carrier_id
   AND grp.OBJID = ca.CARRIER2CARRIER_GROUP
   AND pa.OBJID = grp.X_CARRIER_GROUP2X_PARENT
   AND pref.carrier_id = ca.x_carrier_id
   AND pref.st = b.state
   and ca.x_status = 'ACTIVE'
   AND ca.X_DATA_SERVICE = 1
   AND pref.county = tab1.county
   AND CDMA_TECH = 'CDMA';

cdma_rec cdma_cur%rowtype;

BEGIN

  OP_RESULT := 0;

  open cdma_cur;
  fetch cdma_cur into cdma_rec;
  if cdma_cur%found then
     OP_RESULT := 1;
  end if;
  close cdma_cur;


END VALIDATE_CDMA_DATA_SERVICE_PRC;
/