CREATE OR REPLACE TYPE sa."SERVICE_PLAN_SITE_PART_TYPE" AS OBJECT
------------------------------------------------------------------------
--$RCSfile: service_plan_site_part_type_spec.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/29 20:42:37 $
--$ $Log: service_plan_site_part_type_spec.sql,v $
--$ Revision 1.1  2016/11/29 20:42:37  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
(
  service_plan_site_part_objid   NUMBER,
  service_plan_id                NUMBER,
  switch_base_rate               VARCHAR2(10),
  new_service_plan_id            NUMBER,
  last_modified_date             DATE,
  response                       VARCHAR2(1000),
  numeric_value                  NUMBER ,
  varchar2_value                 VARCHAR2(1000),
  CONSTRUCTOR FUNCTION service_plan_site_part_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION service_plan_site_part_type ( i_service_plan_site_part_objid IN NUMBER) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_service_plan_site_part_type IN OUT service_plan_site_part_type ) RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_service_plan_site_part_type IN service_plan_site_part_type ) RETURN service_plan_site_part_type,
  MEMBER FUNCTION ins RETURN service_plan_site_part_type,
  MEMBER FUNCTION upd ( i_service_plan_site_part_type IN service_plan_site_part_type ) RETURN service_plan_site_part_type
);
/
CREATE OR REPLACE TYPE BODY sa."SERVICE_PLAN_SITE_PART_TYPE" AS
------------------------------------------------------------------------
--$RCSfile: service_plan_site_part_type.sql,v $
--$Revision: 1.3 $
--$Author: sraman $
--$Date: 2016/12/09 15:38:47 $
--$ $Log: service_plan_site_part_type.sql,v $
--$ Revision 1.3  2016/12/09 15:38:47  sraman
--$ CR44729 exists error response commented
--$
--$ Revision 1.2  2016/11/30 16:35:44  vnainar
--$ CR44729 dbms_output removed
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------

  CONSTRUCTOR FUNCTION service_plan_site_part_type RETURN SELF AS RESULT AS
  BEGIN
    -- TODO: Implementation required for FUNCTION service_plan_site_part_type.service_plan_site_part_type
    RETURN;
  END service_plan_site_part_type;

  CONSTRUCTOR FUNCTION service_plan_site_part_type ( i_service_plan_site_part_objid IN NUMBER) RETURN SELF AS RESULT AS
  BEGIN

		IF i_service_plan_site_part_objid is  NULL THEN
		  SELF.response := 'ID NOT PASSED';
      RETURN;
		END IF;

		--Query the table
		select service_plan_site_part_type (  table_site_part_id		,
                                                      x_service_plan_id		        ,
                                                      x_switch_base_rate	        ,
                                                      x_new_service_plan_id	        ,
                                                      x_last_modified_date	        ,
                                                      null   			        ,
                                                      null   			        ,
                                                      null
                                        )
		INTO SELF
		FROM X_SERVICE_PLAN_SITE_PART
		WHERE table_site_part_id= i_service_plan_site_part_objid;
		--G5

		SELF.response := 'SUCCESS';

		RETURN;

	EXCEPTION
	WHEN OTHERS THEN
	SELF.response := 'NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
	SELF.service_plan_site_part_objid := NULL;
  RETURN;
  END service_plan_site_part_type;

  MEMBER FUNCTION exist RETURN BOOLEAN AS
  BEGIN
    -- TODO: Implementation required for FUNCTION service_plan_site_part_type.exist
    RETURN NULL;
  END exist;

  MEMBER FUNCTION exist ( i_service_plan_site_part_type IN OUT service_plan_site_part_type ) RETURN BOOLEAN AS
  BEGIN

		IF i_service_plan_site_part_type.service_plan_site_part_objid is  NULL THEN
		  i_service_plan_site_part_type.response := 'ID NOT PASSED';
      RETURN FALSE;
		END IF;

		--Query the table
		SELECT table_site_part_id INTO i_service_plan_site_part_type.service_plan_site_part_objid
		FROM X_SERVICE_PLAN_SITE_PART
		WHERE table_site_part_id= i_service_plan_site_part_type.service_plan_site_part_objid;

		i_service_plan_site_part_type.response := 'SUCCESS';

		RETURN TRUE;

	EXCEPTION
	WHEN OTHERS THEN
	--i_service_plan_site_part_type.response := 'NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
	--i_service_plan_site_part_type.service_plan_site_part_objid := NULL;
  RETURN FALSE;
  END;

  MEMBER FUNCTION ins
  RETURN service_plan_site_part_type
IS
  ispspt service_plan_site_part_type := SELF;
  i service_plan_site_part_type;
BEGIN
  i := ispspt.ins ( i_service_plan_site_part_type => ispspt );
  RETURN i;
END ins;

 MEMBER FUNCTION ins(i_service_plan_site_part_type IN service_plan_site_part_type )
  RETURN service_plan_site_part_type
AS
  ispspt service_plan_site_part_type := i_service_plan_site_part_type;
BEGIN
  IF ispspt.service_plan_site_part_objid IS NULL THEN
    ispspt.service_plan_site_part_objid  := sa.sequ_service_plan.NEXTVAL;
  END IF;
  -- Inserting into X_SERVICE_PLAN_SITE_PART
  INSERT
  INTO sa.x_service_plan_site_part
    (
      table_site_part_id        ,
      x_service_plan_id         ,
      x_switch_base_rate        ,
      x_new_service_plan_id     ,
      x_last_modified_date
    )
    VALUES
    (
      ispspt.service_plan_site_part_objid ,
      ispspt.service_plan_id                ,
      ispspt.switch_base_rate               ,
      ispspt.new_service_plan_id            ,
      ispspt.last_modified_date
    );
 -- dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row(s) created in ispspt (' || ispspt.service_plan_site_part_objid || ')');
    -- set Success Response
   ispspt.response  := 'SUCCESS' ;--CASE WHEN ispspt.response IS NULL THEN 'SUCCESS' ELSE ispspt.response || '|SUCCESS' END;
  RETURN ispspt;
EXCEPTION
WHEN OTHERS THEN
  ispspt.response := ispspt.response || '|ERROR INSERTING ispspt RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN ispspt;
END ins;



MEMBER FUNCTION  upd ( i_service_plan_site_part_type IN service_plan_site_part_type ) RETURN service_plan_site_part_type AS
    ispspt service_plan_site_part_type := i_service_plan_site_part_type;
    l_spspt service_plan_site_part_type := service_plan_site_part_type();
BEGIN
  l_spspt := service_plan_site_part_type ( i_service_plan_site_part_objid => ispspt.service_plan_site_part_objid);
  -- Updating  X_SERVICE_PLAN_SITE_PART
  IF NOT (NVL(l_spspt.service_plan_id,1)     = NVL(ispspt.service_plan_id,1)       AND
          NVL(l_spspt.switch_base_rate,'X')  = NVL(ispspt.switch_base_rate,'X')    AND
          NVL(l_spspt.new_service_plan_id,1) = NVL(ispspt.new_service_plan_id,1)  )THEN

    UPDATE sa.x_service_plan_site_part
    SET
         x_service_plan_id         = NVL(ispspt.service_plan_id                ,x_service_plan_id     ),
         x_switch_base_rate        = NVL(ispspt.switch_base_rate               ,x_switch_base_rate    ),
         x_new_service_plan_id     = NVL(ispspt.new_service_plan_id            ,x_new_service_plan_id ),
         x_last_modified_date      = NVL(ispspt.last_modified_date             ,x_last_modified_date  )
    WHERE  table_site_part_id =  ispspt.service_plan_site_part_objid;
    -- set Success Response
    ispspt := service_plan_site_part_type ( i_service_plan_site_part_objid => ispspt.service_plan_site_part_objid);

    ispspt.response  := 'SUCCESS-UPDATED';
  else
    -- set Success Response
    ispspt := service_plan_site_part_type ( i_service_plan_site_part_objid => ispspt.service_plan_site_part_objid);
    ispspt.response  := 'SUCCESS';
  END IF;

  RETURN ispspt;
EXCEPTION
WHEN OTHERS THEN
  ispspt.response := ispspt.response || '|ERROR UPDATING ispspt RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN ispspt;
  END upd;

END;
/