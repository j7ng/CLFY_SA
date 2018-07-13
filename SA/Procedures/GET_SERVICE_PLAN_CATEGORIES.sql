CREATE OR REPLACE PROCEDURE sa."GET_SERVICE_PLAN_CATEGORIES" (I_SOURCE_SYSTEM IN VARCHAR2 default 'APP',
                                                  I_LANGUAGE IN VARCHAR2 default 'ENGLISH',
                                                  I_ORG_ID  IN sa.TABLE_BUS_ORG.ORG_ID%TYPE,
                                                  O_SERVICE_PLAN_DESCRIPTION OUT SYS_REFCURSOR,
                                                  O_ERR_NUM OUT VARCHAR2,
                                                  O_ERR_MSG OUT VARCHAR2
                                                  )
IS

BEGIN

OPEN O_SERVICE_PLAN_DESCRIPTION FOR

SELECT  adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SERVICE_PLAN_CATEGORY, 1, instr( SERVICE_PLAN_CATEGORY,'_')-1),
                                ip_script_id => substr(SERVICE_PLAN_CATEGORY, instr( SERVICE_PLAN_CATEGORY,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) SERVICE_PLAN_CATEGORY,
         adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT1, 1, instr( SCRIPT1,'_')-1),
                                ip_script_id => substr(SCRIPT1, instr( SCRIPT1,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION1,
        adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT2, 1, instr( SCRIPT2,'_')-1),
                                ip_script_id => substr(SCRIPT2, instr( SCRIPT2,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION2,
         adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT3, 1, instr( SCRIPT3,'_')-1),
                                ip_script_id => substr(SCRIPT3, instr( SCRIPT3,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION3,
          adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT4, 1, instr( SCRIPT4,'_')-1),
                                ip_script_id => substr(SCRIPT4, instr( SCRIPT4,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION4,
         adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT5, 1, instr( SCRIPT5,'_')-1),
                                ip_script_id => substr(SCRIPT5, instr( SCRIPT5,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION5,
        adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT6, 1, instr( SCRIPT6,'_')-1),
                                ip_script_id => substr(SCRIPT6, instr( SCRIPT6,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION6,
         adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT7, 1, instr( SCRIPT7,'_')-1),
                                ip_script_id => substr(SCRIPT7, instr( SCRIPT7,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION7,
        adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT8, 1, instr( SCRIPT8,'_')-1),
                                ip_script_id => substr(SCRIPT8, instr( SCRIPT8,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION8,
         adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT9, 1, instr( SCRIPT9,'_')-1),
                                ip_script_id => substr(SCRIPT8, instr( SCRIPT9,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION9,
       adfcrm_scripts.get_generic_brand_script  (ip_script_type=>substr(SCRIPT10, 1, instr( SCRIPT10,'_')-1),
                                ip_script_id => substr(SCRIPT8, instr( SCRIPT10,'_') +1, 100),
                                ip_language =>I_LANGUAGE,
                                ip_sourcesystem  =>I_SOURCE_SYSTEM,
                                ip_brand_name =>I_ORG_ID) DESCRIPTION10
FROM SERVICE_PLAN_CATEGORY
WHERE BUS_ORG_ID=I_ORG_ID;

O_ERR_NUM:=0;
O_ERR_MSG:='Success';
EXCEPTION WHEN OTHERS THEN
O_ERR_NUM:=-1;
O_ERR_MSG:='Error while retrieving service plan categories: ' || SQLERRM;
END GET_SERVICE_PLAN_CATEGORIES;
/