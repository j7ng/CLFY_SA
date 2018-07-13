CREATE OR REPLACE TYPE sa.program_purch_dtl_type AS OBJECT
-----------------------------------------------------------------------
--$RCSfile: program_purch_dtl_spec.sql,v $
--$Revision: 1.2 $
--$Author: sinturi $
--$Date: 2017/11/20 23:52:48 $
--$ $Log: program_purch_dtl_spec.sql,v $
--$ Revision 1.2  2017/11/20 23:52:48  sinturi
--$ Modified amount size
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
--$
-------------------------------------------------------------------------
(
  program_purch_dtl_objid         NUMBER          ,
  esn                             VARCHAR2(30)    ,
  amount                          NUMBER          ,
  charge_desc                     VARCHAR2(255)   ,
  cycle_start_date                DATE            ,
  cycle_end_date                  DATE            ,
  pgm_purch_dtl2pgm_enrolled      NUMBER          ,
  pgm_purch_dtl2prog_hdr          NUMBER          ,
  pgm_purch_dtl2penal_pend        NUMBER          ,
  tax_amount                      NUMBER          ,
  e911_tax_amount                 NUMBER          ,
  usf_taxamount                   NUMBER          ,
  rcrf_tax_amount                 NUMBER          ,
  priority                        NUMBER          ,
  response                        VARCHAR2(1000)  ,
  numeric_value                   NUMBER          ,
  varchar2_value                  VARCHAR2(2000)  ,
  CONSTRUCTOR FUNCTION program_purch_dtl_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION program_purch_dtl_type ( i_program_purch_dtl_objid IN NUMBER) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION program_purch_dtl_type ( i_esn IN VARCHAR2) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_program_purch_dtl_type IN OUT program_purch_dtl_type ) RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_program_purch_dtl_type IN program_purch_dtl_type ) RETURN program_purch_dtl_type,
  MEMBER FUNCTION ins RETURN program_purch_dtl_type,
  MEMBER FUNCTION upd ( i_program_purch_dtl_type IN program_purch_dtl_type ) RETURN program_purch_dtl_type
);
/
CREATE OR REPLACE TYPE BODY sa.PROGRAM_PURCH_DTL_TYPE AS
-----------------------------------------------------------------------
--$RCSfile: program_purch_dtl.sql,v $
--$Revision: 1.2 $
--$Author: sraman $
--$Date: 2016/12/09 15:35:03 $
--$ $Log: program_purch_dtl.sql,v $
--$ Revision 1.2  2016/12/09 15:35:03  sraman
--$ CR44729 - removed exists error in response
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
--$
-------------------------------------------------------------------------

CONSTRUCTOR FUNCTION program_purch_dtl_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END program_purch_dtl_type;

CONSTRUCTOR FUNCTION program_purch_dtl_type ( i_program_purch_dtl_objid IN NUMBER) RETURN SELF AS RESULT AS
BEGIN
  --
  IF i_program_purch_dtl_objid IS NOT NULL THEN
    SELF.response                   := 'PROGRAM PURCH DTL ID NOT PASSED';
  END IF;

  --Query the table
  SELECT program_purch_dtl_type(  objid                       ,
                                  x_esn                       ,
                                  x_amount                    ,
                                  x_charge_desc               ,
                                  x_cycle_start_date          ,
                                  x_cycle_end_date            ,
                                  pgm_purch_dtl2pgm_enrolled  ,
                                  pgm_purch_dtl2prog_hdr      ,
                                  pgm_purch_dtl2penal_pend    ,
                                  x_usf_taxamount             ,
                                  x_rcrf_tax_amount           ,
                                  x_priority                  ,
                                  x_tax_amount                ,
                                  x_e911_tax_amount           ,
                                  NULL                        ,
                                  NULL                        ,
                                  NULL
                                )
  INTO SELF
  FROM X_PROGRAM_PURCH_DTL
  WHERE OBJID = i_program_purch_dtl_objid;
  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response                       := 'PROGRAM PURCH DTL NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.program_purch_dtl_objid := i_program_purch_dtl_objid;

      --
      RETURN;
END program_purch_dtl_type;

CONSTRUCTOR FUNCTION program_purch_dtl_type ( i_esn IN VARCHAR2) RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END program_purch_dtl_type;

MEMBER FUNCTION exist RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END exist;

MEMBER FUNCTION exist ( i_program_purch_dtl_type IN OUT program_purch_dtl_type ) RETURN BOOLEAN AS
BEGIN
  --
  IF i_program_purch_dtl_type.ESN IS  NULL THEN
    i_program_purch_dtl_type.response                   := 'PROGRAM PURCH DTL ESN NOT PASSED';
    RETURN FALSE;
  END IF;

  --Query the table
  SELECT OBJID INTO i_program_purch_dtl_type.program_purch_dtl_objid
  FROM X_PROGRAM_PURCH_DTL
  WHERE x_esn = i_program_purch_dtl_type.ESN;
  --
  i_program_purch_dtl_type.response := 'SUCCESS';

  RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
      --i_program_purch_dtl_type.response                       := 'PROGRAM PURCH DTL NOT FOUND' || SUBSTR(SQLERRM,1,100);
      i_program_purch_dtl_type.program_purch_dtl_objid := NULL;
      RETURN FALSE;
END;

MEMBER FUNCTION ins ( i_program_purch_dtl_type IN program_purch_dtl_type ) RETURN program_purch_dtl_type AS
ippd  program_purch_dtl_type := i_program_purch_dtl_type;
BEGIN
  IF ippd.program_purch_dtl_objid IS NULL THEN
    ippd.program_purch_dtl_objid  := sa.seq_x_program_purch_dtl.nextval;
  END IF;

  INSERT
  INTO X_PROGRAM_PURCH_DTL
    (
      objid                       ,
      x_esn                       ,
      x_amount                    ,
      x_charge_desc               ,
      x_cycle_start_date          ,
      x_cycle_end_date            ,
      pgm_purch_dtl2pgm_enrolled  ,
      pgm_purch_dtl2prog_hdr      ,
      pgm_purch_dtl2penal_pend    ,
      x_tax_amount                ,
      x_e911_tax_amount           ,
      x_usf_taxamount             ,
      x_rcrf_tax_amount           ,
      x_priority
    )
    VALUES
    (
      ippd.program_purch_dtl_objid     ,
      ippd.esn                         ,
      ippd.amount                      ,
      ippd.charge_desc                 ,
      ippd.cycle_start_date            ,
      ippd.cycle_end_date              ,
      ippd.pgm_purch_dtl2pgm_enrolled  ,
      ippd.pgm_purch_dtl2prog_hdr      ,
      ippd.pgm_purch_dtl2penal_pend    ,
      ippd.tax_amount                  ,
      ippd.e911_tax_amount             ,
      ippd.usf_taxamount               ,
      ippd.rcrf_tax_amount             ,
      ippd.priority
    );

  -- set Success Response
  ippd.response  := CASE WHEN ippd.response IS NULL THEN 'SUCCESS' ELSE ippd.response || '|SUCCESS' END;
   RETURN ippd;
EXCEPTION
WHEN OTHERS THEN
  ippd.response := ippd.response || '|ERROR INSERTING PROGRAM PURCH DTL RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN ippd;
END ins;

MEMBER FUNCTION ins RETURN program_purch_dtl_type AS
  ippd   program_purch_dtl_type := SELF;
  i      program_purch_dtl_type;
begin
  i := ippd.ins ( i_program_purch_dtl_type => ippd );
  RETURN i;
END ins;

MEMBER FUNCTION upd ( i_program_purch_dtl_type IN program_purch_dtl_type ) RETURN program_purch_dtl_type AS
ippd  program_purch_dtl_type := i_program_purch_dtl_type;
BEGIN

  UPDATE
     x_program_purch_dtl
	 SET
      x_esn                       = NVL(ippd.esn                         ,x_esn                      ),
      x_amount                    = NVL(ippd.amount                      ,x_amount                   ),
      x_charge_desc               = NVL(ippd.charge_desc                 ,x_charge_desc              ),
      x_cycle_start_date          = NVL(ippd.cycle_start_date            ,x_cycle_start_date         ),
      x_cycle_end_date            = NVL(ippd.cycle_end_date              ,x_cycle_end_date           ),
      pgm_purch_dtl2pgm_enrolled  = NVL(ippd.pgm_purch_dtl2pgm_enrolled  ,pgm_purch_dtl2pgm_enrolled ),
      pgm_purch_dtl2prog_hdr      = NVL(ippd.pgm_purch_dtl2prog_hdr      ,pgm_purch_dtl2prog_hdr     ),
      pgm_purch_dtl2penal_pend    = NVL(ippd.pgm_purch_dtl2penal_pend    ,pgm_purch_dtl2penal_pend   ),
      x_tax_amount                = NVL(ippd.tax_amount                  ,x_tax_amount               ),
      x_e911_tax_amount           = NVL(ippd.e911_tax_amount             ,x_e911_tax_amount          ),
      x_usf_taxamount             = NVL(ippd.usf_taxamount               ,x_usf_taxamount            ),
      x_rcrf_tax_amount           = NVL(ippd.rcrf_tax_amount             ,x_rcrf_tax_amount          ),
      x_priority                  = NVL(ippd.priority                    ,x_priority                 )
   WHERE objid = ippd.program_purch_dtl_objid ;

  -- set Success Response
  ippd := program_purch_dtl_type ( i_program_purch_dtl_objid => ippd.program_purch_dtl_objid);
  ippd.response  := 'SUCCESS';

   RETURN ippd;
EXCEPTION
WHEN OTHERS THEN
  ippd.response := ippd.response || '|ERROR UPDATING PROGRAM PURCH DTL RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN ippd;
END upd;

END;
/