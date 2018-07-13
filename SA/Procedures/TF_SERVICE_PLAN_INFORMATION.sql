CREATE OR REPLACE PROCEDURE sa."TF_SERVICE_PLAN_INFORMATION" ( i_min           IN  sa.table_site_part.x_min%TYPE         ,
                                                             i_language      IN  VARCHAR2 DEFAULT 'EN'                 ,
                                                             i_brand         IN  sa.table_bus_org.org_id%TYPE          ,
                                                             o_plan_id       OUT sa.x_service_plan.objid%TYPE          ,
                                                             o_plan_name     OUT sa.x_service_plan.mkt_name%TYPE       ,
                                                             o_plan_desc     OUT VARCHAR2                              ,
                                                             o_cust_price    OUT sa.x_service_plan.customer_price%TYPE ,
                                                             o_error_number  OUT NUMBER                                ,
                                                             o_response      OUT VARCHAR2                              )
IS

  -- CR51319 - Create a SOA service to allow Service Plan information through source system "SMS" to be process on 611611//OImana//08212017
  -- CR51319 - New procedure to retrieve service plan details and SMS text in English and Spanish//OImana//08212017
  -- CR51319 - Error out parameter returns 1 when issues are found and 0 when process is successful//response is out message//OImana//08212017
  -- CR51319 - Based in change requested on 09/29/2017 (YCruz), the O_PLAN_NAME returning parameter should be the service plan description.

  c_language  VARCHAR2(30);
  cst         customer_type := customer_type();
  c           customer_type := customer_type();

BEGIN

  o_plan_id      := NULL;
  o_error_number := 1;     -- initial value set to error
  o_response     := 'ERROR - Invalid action';
  c_language     := NULL;

  IF (i_min IS NULL)
  THEN
    o_response := 'ERROR - MIN input value is missing: <'||i_min||'><'||i_brand||'>';
    DBMS_OUTPUT.PUT_LINE(o_response);
    RETURN;
  END IF;

  IF NVL(i_language,'XX') IN ('ES','EN','SPA','ENG')
  THEN
    IF (i_language = 'SPA')
    THEN
      c_language := 'ES';  --Spanish
    ELSIF (i_language = 'ENG')
    THEN
      c_language := 'EN';  --English
    END IF;
  ELSE
    o_response := 'ERROR - Invalid or missing input language: <'||i_language||'>';
    DBMS_OUTPUT.PUT_LINE(o_response);
    RETURN;
  END IF;

  --
  cst.min := i_min;

  -- get the service plan attributes
  c := cst.get_service_plan_attributes;

  -- validate that the plan was retrieved successfully
  IF c.service_plan_objid IS NULL THEN
    o_response:= 'WARNING - No service plan data found for <'||i_min||'><'||i_brand||'><'||c_language||'>';
    RETURN;
  END IF;

  -- set output parameters
  o_plan_id    := c.service_plan_objid;
  o_plan_name  := c.service_plan_name;
  o_cust_price := c.service_plan_price;
  o_plan_desc  := sa.adfcrm_scripts.get_plan_description (c.service_plan_objid, c_language, 'ALL');

  IF (o_plan_id IS NOT NULL)
  THEN
    o_error_number := 0;
    o_response     := 'SUCCESS';
  END IF;

EXCEPTION
WHEN OTHERS
THEN
  o_error_number := 1;
  o_response := NVL(o_response,'ERROR - MAIN tf_service_plan_information PROCESS FAILED: '||SQLCODE||' - '||SUBSTR(SQLERRM, 1, 200));
  DBMS_OUTPUT.PUT_LINE(o_response);
END tf_service_plan_information;
/