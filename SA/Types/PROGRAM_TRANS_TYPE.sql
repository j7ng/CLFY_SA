CREATE OR REPLACE TYPE sa."PROGRAM_TRANS_TYPE" AS OBJECT
------------------------------------------------------------------------
--$RCSfile: program_trans_type_spec.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/29 20:42:36 $
--$ $Log: program_trans_type_spec.sql,v $
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
(
  program_trans_objid    NUMBER,
  enrollment_status      VARCHAR2(30),
  enroll_status_reason   VARCHAR2(255),
  float_given            NUMBER,
  cooling_given          NUMBER,
  grace_period_given     NUMBER,
  trans_DATE             DATE,
  action_text            VARCHAR2(30),
  action_type            VARCHAR2(30),
  reason                 VARCHAR2(255),
  sourcesystem           VARCHAR2(20),
  esn                    VARCHAR2(30),
  exp_DATE               DATE,
  cooling_exp_DATE       DATE,
  upDATE_status          VARCHAR2(1),
  upDATE_user            VARCHAR2(255),
  pgm_tran2pgm_entrolled NUMBER,
  pgm_trans2web_user     NUMBER,
  pgm_trans2site_part    NUMBER,
  response               VARCHAR2(1000),
  numeric_value          NUMBER ,
  varchar2_value         VARCHAR2(1000),
  CONSTRUCTOR FUNCTION program_trans_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION program_trans_type ( i_program_trans_objid IN NUMBER) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist ( i_program_trans_type IN OUT program_trans_type)  RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_program_trans_type IN program_trans_type) RETURN program_trans_type,
  MEMBER FUNCTION ins RETURN program_trans_type,
  MEMBER FUNCTION upd ( i_program_trans_objid IN NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN program_trans_type
);
/
CREATE OR REPLACE TYPE BODY sa."PROGRAM_TRANS_TYPE" AS
------------------------------------------------------------------------
--$RCSfile: program_trans_type.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/29 20:42:36 $
--$ $Log: program_trans_type.sql,v $
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------


CONSTRUCTOR FUNCTION program_trans_type RETURN SELF AS RESULT AS
BEGIN
  -- TODO: Implementation required for FUNCTION program_trans_type.program_trans_type
  RETURN ;
END program_trans_type;

CONSTRUCTOR FUNCTION program_trans_type ( i_program_trans_objid IN NUMBER) RETURN SELF AS RESULT AS
BEGIN

  IF i_program_trans_objid is NOT NULL THEN
   SELF.response := 'PROGRAM TRANS ID NOT PASSED';
  END IF;

    --Query the table
    SELECT program_trans_type ( objid                   ,
                                x_enrollment_status     ,
                                x_enroll_status_reason  ,
                                x_float_given           ,
                                x_cooling_given         ,
                                x_grace_period_given    ,
                                x_trans_date            ,
                                x_action_text           ,
                                x_action_type           ,
                                x_reason                ,
                                x_sourcesystem          ,
                                x_esn                   ,
                                x_exp_date              ,
                                x_cooling_exp_date      ,
                                x_update_status         ,
                                x_update_user           ,
                                pgm_tran2pgm_entrolled  ,
                                pgm_trans2web_user      ,
                                pgm_trans2site_part     ,
                                NULL                    ,
                                NULL                    ,
                                NULL
                               )
    INTO SELF
    FROM x_program_trans
    WHERE objid= i_program_trans_objid;
    --G5

    SELF.response := 'SUCCESS';

    RETURN;

EXCEPTION
WHEN OTHERS THEN
 SELF.response := 'PROGRAM TRANS ID NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
 SELF.program_trans_objid := i_program_trans_objid;
 RETURN ;
END program_trans_type;

MEMBER FUNCTION exist ( i_program_trans_type IN OUT program_trans_type) RETURN BOOLEAN AS
  BEGIN
    IF  ( i_program_trans_type.pgm_trans2site_part is NULL OR i_program_trans_type.pgm_trans2web_user IS NULL
        OR i_program_trans_type.pgm_tran2pgm_entrolled IS NULL OR i_program_trans_type.enrollment_status IS NULL ) THEN
        i_program_trans_type.response := 'Input parameter missing';
        RETURN FALSE;
    END IF;


       SELECT objid INTO i_program_trans_type.program_trans_objid
       FROM x_program_trans
       WHERE  pgm_trans2site_part    = i_program_trans_type.pgm_trans2site_part
       AND    pgm_trans2web_user     = i_program_trans_type.pgm_trans2web_user
       AND    pgm_tran2pgm_entrolled = i_program_trans_type.pgm_tran2pgm_entrolled
       AND    x_enrollment_status    = i_program_trans_type.enrollment_status
       AND ROWNUM=1;

       i_program_trans_type.response := 'SUCCESS';

       RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
   --i_program_trans_type.response := 'PROGRAM TRANS  NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
   i_program_trans_type.response := 'SUCCESS';
   i_program_trans_type.program_trans_objid := NULL;
   RETURN FALSE;
END exist;

MEMBER FUNCTION ins ( i_program_trans_type IN program_trans_type ) RETURN program_trans_type AS
  i_pt program_trans_type := i_program_trans_type;
BEGIN

  IF i_pt.program_trans_objid IS NULL THEN
    i_pt.program_trans_objid  := sa.SEQ_X_PROGRAM_TRANS.nextval;
  END IF;

  INSERT  INTO x_program_trans
    (   objid                  ,
        x_enrollment_status    ,
        x_enroll_status_reason ,
        x_float_given          ,
        x_cooling_given        ,
        x_grace_period_given   ,
        x_trans_date           ,
        x_action_text          ,
        x_action_type          ,
        x_reason               ,
        x_sourcesystem         ,
        x_esn                  ,
        x_exp_date             ,
        x_cooling_exp_date     ,
        x_update_status        ,
        x_update_user          ,
        pgm_tran2pgm_entrolled ,
        pgm_trans2web_user     ,
        pgm_trans2site_part   )
    VALUES
    (
      i_pt.program_trans_objid    ,
      i_pt.enrollment_status      ,
      i_pt.enroll_status_reason   ,
      i_pt.float_given            ,
      i_pt.cooling_given          ,
      i_pt.grace_period_given     ,
      i_pt.trans_date             ,
      i_pt.action_text            ,
      i_pt.action_type            ,
      i_pt.reason                 ,
      i_pt.sourcesystem           ,
      i_pt.esn                    ,
      i_pt.exp_date               ,
      i_pt.cooling_exp_date       ,
      i_pt.update_status          ,
      i_pt.update_user            ,
      i_pt.pgm_tran2pgm_entrolled ,
      i_pt.pgm_trans2web_user     ,
      i_pt.pgm_trans2site_part
    );

  -- set Success Response
  i_pt.response :=  'SUCCESS';
  RETURN i_pt;

EXCEPTION
  WHEN OTHERS THEN
  i_pt.response := i_pt.response || '|ERROR INSERTING PROGRAM TRANS RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN i_pt;
END ins;

MEMBER FUNCTION ins RETURN program_trans_type AS
i_pt     program_trans_type := SELF;
i         program_trans_type;
BEGIN
 i := i_pt.ins ( i_program_trans_type => i_pt );
 RETURN i;
END ins;

MEMBER FUNCTION upd ( i_program_trans_objid IN NUMBER) RETURN BOOLEAN AS
BEGIN
  -- TODO: Implementation required for FUNCTION program_trans_type.upd
  RETURN NULL;
END upd;

MEMBER FUNCTION upd RETURN program_trans_type AS
BEGIN
  -- TODO: Implementation required for FUNCTION program_trans_type.upd
  RETURN NULL;
END upd;

END;
/