CREATE OR REPLACE TYPE sa."SERVICE_PLAN_HIST_TYPE" AS OBJECT
------------------------------------------------------------------------
--$RCSfile: service_plan_hist_type_spec.sql,v $
--$Revision: 1.2 $
--$Author: vnainar $
--$Date: 2017/03/03 00:07:32 $
--$ $Log: service_plan_hist_type_spec.sql,v $
--$ Revision 1.2  2017/03/03 00:07:32  vnainar
--$ CR47564 enhancements added for WFM
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
(
  plan_hist2site_part_objid   NUMBER        ,
  start_date     	      DATE          ,
  plan_hist2service_plan      NUMBER        ,
  insert_date 		      DATE          ,
  last_modified_date 	      DATE          ,
  response                    VARCHAR2(1000),
  numeric_value               NUMBER        ,
  varchar2_value              VARCHAR2(2000),
  CONSTRUCTOR FUNCTION service_plan_hist_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION service_plan_hist_type ( i_plan_hist2site_part_objid IN NUMBER ) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist  ( i_service_plan_hist_type IN OUT service_plan_hist_type ) RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_service_plan_hist_type IN service_plan_hist_type ) RETURN service_plan_hist_type,
  MEMBER FUNCTION ins RETURN service_plan_hist_type,
  --MEMBER FUNCTION upd ( i_plan_hist2site_part_objid IN NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION upd  ( i_service_plan_hist_type IN service_plan_hist_type )  RETURN service_plan_hist_type
);
/
CREATE OR REPLACE TYPE BODY sa."SERVICE_PLAN_HIST_TYPE" AS
------------------------------------------------------------------------
--$RCSfile: service_plan_hist_type.sql,v $
--$Revision: 1.3 $
--$Author: vnainar $
--$Date: 2017/03/03 00:13:17 $
--$ $Log: service_plan_hist_type.sql,v $
--$ Revision 1.3  2017/03/03 00:13:17  vnainar
--$ CR47564 WFM enhancements added
--$
--$ Revision 1.2  2017/03/03 00:09:34  vnainar
--$ CR47564 WFM enhancements added
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------

CONSTRUCTOR FUNCTION service_plan_hist_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END service_plan_hist_type;

CONSTRUCTOR FUNCTION service_plan_hist_type ( i_plan_hist2site_part_objid IN NUMBER ) RETURN SELF AS RESULT AS

BEGIN
  --
  IF i_plan_hist2site_part_objid IS NOT NULL THEN
    SELF.response                   := 'SERVICE PLAN ID NOT PASSED';
  END IF;

  --Query the table
  SELECT service_plan_hist_type( plan_hist2site_part             ,
                                 x_start_date                    ,
                                 plan_hist2service_plan          ,
                                 x_insert_date                   ,
                                 x_last_modified_date            ,
                                 NULL                            ,
                                 NULL                            ,
                                 NULL
                             )
  INTO SELF
  FROM x_service_plan_hist
  WHERE plan_hist2site_part = i_plan_hist2site_part_objid;
  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response := 'SERVICE PLAN NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.plan_hist2site_part_objid := i_plan_hist2site_part_objid;

      --
      RETURN;
END service_plan_hist_type;

MEMBER FUNCTION exist ( i_service_plan_hist_type IN OUT service_plan_hist_type ) RETURN BOOLEAN AS
BEGIN

  IF i_service_plan_hist_type.plan_hist2site_part_objid is  NULL THEN
    i_service_plan_hist_type.response := 'ID NOT PASSED';
  RETURN FALSE;
  END IF;

  --Query the table
  SELECT plan_hist2site_part INTO i_service_plan_hist_type.plan_hist2site_part_objid
  FROM x_service_plan_hist
  WHERE plan_hist2site_part= i_service_plan_hist_type.plan_hist2site_part_objid;

  i_service_plan_hist_type.response := 'SUCCESS';

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN FALSE;

END exist;

MEMBER FUNCTION ins ( i_service_plan_hist_type IN service_plan_hist_type ) RETURN service_plan_hist_type AS
i_sph service_plan_hist_type := i_service_plan_hist_type;
BEGIN

  IF i_sph.plan_hist2site_part_objid IS NULL THEN
    i_sph.plan_hist2site_part_objid  := sa.SEQU_SERVICE_PLAN.nextval;
  END IF;

  --Assign Time stamp attributes
  IF i_sph.last_modified_date IS NULL THEN
    i_sph.last_modified_date  := SYSDATE;
  END IF;

  INSERT
  INTO x_service_plan_hist
    (
      plan_hist2site_part             ,
      x_start_date                    ,
      plan_hist2service_plan          ,
      x_insert_date                   ,
      x_last_modified_date
    )
    VALUES
    (
      i_sph.plan_hist2site_part_objid ,
      i_sph.start_date                ,
      i_sph.plan_hist2service_plan    ,
      i_sph.insert_date               ,
      i_sph.last_modified_date
    );

  -- set Success Response
  i_sph.response := CASE WHEN i_sph.response IS NULL THEN 'SUCCESS' ELSE i_sph.response || '|SUCCESS' END;
  RETURN i_sph;

EXCEPTION
WHEN OTHERS THEN
  i_sph.response := i_sph.response || '|ERROR INSERTING SERVICE PLAN HIST RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN i_sph;
END ins;

MEMBER FUNCTION ins RETURN service_plan_hist_type AS
  i_sph     service_plan_hist_type := SELF;
  i         service_plan_hist_type;
BEGIN
  i := i_sph.ins ( i_service_plan_hist_type => i_sph );
  RETURN i;
END ins;

MEMBER FUNCTION upd ( i_service_plan_hist_type IN service_plan_hist_type )  RETURN service_plan_hist_type AS
    isph service_plan_hist_type     := i_service_plan_hist_type;
    sph_ret service_plan_hist_type  := service_plan_hist_type(i_plan_hist2site_part_objid => i_service_plan_hist_type.plan_hist2site_part_objid);
BEGIN
    --sph_ret := service_plan_hist_type();


   IF NVL(sph_ret.plan_hist2service_plan,1) <> NVL(isph.plan_hist2service_plan,1)   THEN

       UPDATE sa.x_service_plan_hist
       SET
            x_start_date              = NVL(isph.start_date             , x_start_date     ),
            plan_hist2service_plan    = NVL(isph.plan_hist2service_plan , plan_hist2service_plan    ),
            x_insert_date             = NVL(isph.insert_date            , x_insert_date  ),
	    x_last_modified_date      = NVL(isph.last_modified_date  , last_modified_date)
       WHERE  plan_hist2site_part     =  isph.plan_hist2site_part_objid;
       -- set Success Response
      -- isph := service_plan_site_part_type ( i_service_plan_site_part_objid => ispspt.service_plan_site_part_objid);

       isph.response  := 'SUCCESS';
   ELSE
     -- set Success Response
     --isph := service_plan_hist_type ( i_plan_hist2site_part_objid => i_service_plan_hist_type.plan_hist2site_part_objid);
     isph.response  := 'SUCCESS';
   END IF;


RETURN  isph;
EXCEPTION
WHEN OTHERS THEN

  isph.response := 'ERROR UPDATING SERVICE PLAN HIST RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN isph;

END upd;


END;
/