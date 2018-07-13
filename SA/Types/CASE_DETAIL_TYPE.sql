CREATE OR REPLACE TYPE sa.case_detail_type AS OBJECT (
  case_detail_objid               NUMBER(38)      ,
  dev                             NUMBER          ,
  name                            VARCHAR2(30)    ,
  value                           VARCHAR2(500)   ,
  detail2case                     NUMBER          ,
  response                        VARCHAR2(1000)  ,
  numeric_value                   NUMBER          ,
  varchar2_value                  VARCHAR2(2000)  ,
  exist                           VARCHAR2(1)     ,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION case_detail_type RETURN SELF AS RESULT,
  -- Constructor used to get the case attributes by objid
  CONSTRUCTOR FUNCTION case_detail_type ( i_case_detail_objid IN NUMBER ) RETURN SELF AS RESULT,
  -- Function used to get the case attributes
  MEMBER FUNCTION get RETURN case_detail_type,
  -- Function used to insert a case detail
  MEMBER FUNCTION ins RETURN case_detail_type,
  -- Function used to save a case
  MEMBER FUNCTION save ( i_cd IN OUT case_detail_type ) RETURN VARCHAR2,
  -- Function used to save a case
  MEMBER FUNCTION save RETURN case_detail_type
);
/
CREATE OR REPLACE TYPE BODY sa.case_detail_type IS

-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION case_detail_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

-- Constructor used to get the case attributes by objid
CONSTRUCTOR FUNCTION case_detail_type ( i_case_detail_objid IN NUMBER ) RETURN SELF AS RESULT IS
BEGIN
  BEGIN
    SELECT case_detail_type ( objid                    ,
                              dev                      ,
                              x_name                   ,
                              x_value                  ,
                              detail2case              ,
                              NULL                     , -- response                    VARCHAR2(1000)
                              NULL                     , -- numeric_value               NUMBER
                              NULL                     , -- varchar2_value              VARCHAR2(2000)
                              NULL                       -- exist                       VARCHAR2(1)
                            )
    INTO   SELF
    FROM   table_x_case_detail
    WHERE  objid = i_case_detail_objid;
   EXCEPTION
     WHEN OTHERS THEN
       SELF.case_detail_objid := i_case_detail_objid;
       SELF.response := 'CASE DETAIL NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.case_detail_objid := i_case_detail_objid;
     SELF.response := 'CASE DETAIL NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

-- Function used to get the case attributes
MEMBER FUNCTION get RETURN case_detail_type IS
  cd case_detail_type := case_detail_type ();
BEGIN
  RETURN cd;
END get;

-- Function used to insert a case detail
MEMBER FUNCTION ins RETURN case_detail_type IS

  cd case_detail_type := case_detail_type ();

BEGIN
  RETURN cd;
END ins;

-- Function used to save a case
MEMBER FUNCTION save ( i_cd IN OUT case_detail_type ) RETURN VARCHAR2 IS

BEGIN
  RETURN('SUCCESS');
END save;

-- Function used to save a case
MEMBER FUNCTION save RETURN case_detail_type IS

  cd case_detail_type := case_detail_type ();

BEGIN

  RETURN cd;

END save;

--
END;
/