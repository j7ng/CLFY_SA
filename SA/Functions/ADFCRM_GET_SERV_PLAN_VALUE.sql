CREATE OR REPLACE FUNCTION sa.ADFCRM_GET_SERV_PLAN_VALUE(
   ip_plan_objid IN NUMBER,
   ip_property_name IN VARCHAR
)
   RETURN VARCHAR
IS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_GET_SERV_PLAN_VALUE.sql,v $
--$Revision: 1.1 $
--$Author: mmunoz $
--$Date: 2014/08/26 18:50:45 $
--$ $Log: ADFCRM_GET_SERV_PLAN_VALUE.sql,v $
--$ Revision 1.1  2014/08/26 18:50:45  mmunoz
--$ TAS_2014_07
--$
--------------------------------------------------------------------------------------------

  CURSOR c1
   IS
    SELECT
       matview.Fea_value  PROPERTY_VALUE
    FROM
      sa.ADFCRM_SERV_PLAN_FEAT_MATVIEW matview
    WHERE matview.Sp_Objid = ip_plan_objid
      AND matview.Fea_Name = ip_property_name
      AND ROWNUM < 2;

   r1 c1%ROWTYPE;

BEGIN
   OPEN c1;
   FETCH c1
   INTO r1;
   IF c1%found THEN
     CLOSE c1;
     RETURN r1.PROPERTY_VALUE;
   ELSE
     CLOSE c1;
     RETURN NULL;
   END IF;
END;
/