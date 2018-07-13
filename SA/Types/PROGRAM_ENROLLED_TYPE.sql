CREATE OR REPLACE TYPE sa.program_enrolled_type AS OBJECT
------------------------------------------------------------------------
--$RCSfile: program_enrolled_type_spec.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/29 20:42:36 $
--$ $Log: program_enrolled_type_spec.sql,v $
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
(
  program_enrolled_objid         NUMBER        ,
  esn                            VARCHAR2(30)  ,
  amount                         NUMBER        ,
  TYPE                           VARCHAR2(30)  ,
  zipcode                        NUMBER        ,
  sourcesystem                   VARCHAR2(30)  ,
  insert_date                    DATE          ,
  charge_date                    DATE          ,
  pec_customer                   NUMBER        ,
  charge_type                    VARCHAR2(30)  ,
  enrolled_date                  DATE          ,
  start_date                     DATE          ,
  reason                         VARCHAR2(255) ,
  exp_date                       DATE          ,
  delivery_cycle_number          NUMBER        ,
  enroll_amount                  NUMBER        ,
  LANGUAGE                       VARCHAR2(7)   ,
  payment_type                   VARCHAR2(20)  ,
  grace_period                   NUMBER(30)    ,
  cooling_period                 NUMBER(30)    ,
  service_days                   NUMBER(30)    ,
  cooling_exp_date               DATE          ,
  enrollment_status              VARCHAR2(30)  ,
  is_grp_primary                 NUMBER(10)    ,
  tot_grace_period_given         NUMBER        ,
  next_charge_date               DATE          ,
  next_delivery_date             DATE          ,
  update_stamp                   DATE          ,
  update_user                    VARCHAR2(40)  ,
  pgm_enroll2pgm_parameter       NUMBER        ,
  pgm_enroll2pgm_group           NUMBER        ,
  pgm_enroll2site_part           NUMBER        ,
  pgm_enroll2part_inst           NUMBER        ,
  pgm_enroll2contact             NUMBER        ,
  pgm_enroll2web_user            NUMBER        ,
  pgm_enroll2x_pymt_src          NUMBER        ,
  wait_exp_date                  DATE          ,
  pgm_enroll2x_promotion         NUMBER        ,
  pgm_enroll2prog_hdr            NUMBER        ,
  termscond_accepted             NUMBER        ,
  service_delivery_date          DATE          ,
  default_denomination           NUMBER        ,
  auto_refill_max_limit          NUMBER        ,
  auto_refill_counter            NUMBER        ,
  response                       VARCHAR2(1000),
  numeric_value                  NUMBER        ,
  varchar2_value                 VARCHAR2(2000),
  CONSTRUCTOR FUNCTION program_enrolled_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION program_enrolled_type ( i_program_enrolled_objid IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION program_enrolled_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_program_enrolled_type IN OUT program_enrolled_type )  RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_program_enrolled_type IN program_enrolled_type ) RETURN program_enrolled_type,
  MEMBER FUNCTION ins RETURN program_enrolled_type,
  MEMBER FUNCTION upd ( i_program_enrolled_type IN program_enrolled_type ) RETURN program_enrolled_type,
  MEMBER FUNCTION del ( i_program_enrolled_objid IN  NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN
);

/
CREATE OR REPLACE TYPE BODY sa.PROGRAM_ENROLLED_TYPE AS
------------------------------------------------------------------------
--$RCSfile: program_enrolled_type.sql,v $
--$Revision: 1.6 $
--$Author: sinturi $
--$Date: 2018/01/30 17:44:29 $
--$ $Log: program_enrolled_type.sql,v $
--$ Revision 1.6  2018/01/30 17:44:29  sinturi
--$ updated
--$
--$ Revision 1.5  2017/12/12 22:53:11  rmorthala
--$ *** empty log message ***
--$
--$ Revision 1.2  2016/12/09 15:28:34  sraman
--$ CR44729 - removed exists error in response
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------

CONSTRUCTOR FUNCTION program_enrolled_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END program_enrolled_type;

CONSTRUCTOR FUNCTION program_enrolled_type ( i_program_enrolled_objid IN NUMBER) RETURN SELF AS RESULT AS
BEGIN
    --
  IF i_program_enrolled_objid IS  NULL THEN
    SELF.response                   := 'PROGRAM ENROLLED ID NOT PASSED';
    RETURN;
  END IF;

  --Query the table
  SELECT program_enrolled_type( objid                     ,
                                x_esn                     ,
                                x_amount                  ,
                                x_type                    ,
                                x_zipcode                 ,
                                x_sourcesystem            ,
                                x_insert_date             ,
                                x_charge_date             ,
                                x_pec_customer            ,
                                x_charge_type             ,
                                x_enrolled_date           ,
                                x_start_date              ,
                                x_reason                  ,
                                x_exp_date                ,
                                x_delivery_cycle_number   ,
                                x_enroll_amount           ,
                                x_language                ,
                                x_payment_type            ,
                                x_grace_period            ,
                                x_cooling_period          ,
                                x_service_days            ,
                                x_cooling_exp_date        ,
                                x_enrollment_status       ,
                                x_is_grp_primary          ,
                                x_tot_grace_period_given  ,
                                x_next_charge_date        ,
                                x_next_delivery_date      ,
                                x_update_stamp            ,
                                x_update_user             ,
                                pgm_enroll2pgm_parameter  ,
                                pgm_enroll2pgm_group      ,
                                pgm_enroll2site_part      ,
                                pgm_enroll2part_inst      ,
                                pgm_enroll2contact        ,
                                pgm_enroll2web_user       ,
                                pgm_enroll2x_pymt_src     ,
                                x_wait_exp_date           ,
                                pgm_enroll2x_promotion    ,
                                pgm_enroll2prog_hdr       ,
                                x_termscond_accepted      ,
                                x_service_delivery_date   ,
                                default_denomination      ,
                                auto_refill_max_limit     ,
                                auto_refill_counter       ,
                                NULL                      ,
                                NULL                      ,
                                NULL
                                )
  INTO SELF
  FROM x_program_enrolled
  WHERE objid = i_program_enrolled_objid;
  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response := 'PROGRAM ENROLLED NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.program_enrolled_objid := NULL;

      --
      RETURN;
END program_enrolled_type;

CONSTRUCTOR FUNCTION program_enrolled_type ( i_esn IN VARCHAR2) RETURN SELF AS RESULT AS
BEGIN
   --
  IF i_esn IS  NULL THEN
    SELF.response                   := 'ESN IS NOT PASSED';
    RETURN;
  END IF;

  --Query the table
  BEGIN
  SELECT program_enrolled_type( objid                     ,
                                x_esn                     ,
                                x_amount                  ,
                                x_type                    ,
                                x_zipcode                 ,
                                x_sourcesystem            ,
                                x_insert_date             ,
                                x_charge_date             ,
                                x_pec_customer            ,
                                x_charge_type             ,
                                x_enrolled_date           ,
                                x_start_date              ,
                                x_reason                  ,
                                x_exp_date                ,
                                x_delivery_cycle_number   ,
                                x_enroll_amount           ,
                                x_language                ,
                                x_payment_type            ,
                                x_grace_period            ,
                                x_cooling_period          ,
                                x_service_days            ,
                                x_cooling_exp_date        ,
                                x_enrollment_status       ,
                                x_is_grp_primary          ,
                                x_tot_grace_period_given  ,
                                x_next_charge_date        ,
                                x_next_delivery_date      ,
                                x_update_stamp            ,
                                x_update_user             ,
                                pgm_enroll2pgm_parameter  ,
                                pgm_enroll2pgm_group      ,
                                pgm_enroll2site_part      ,
                                pgm_enroll2part_inst      ,
                                pgm_enroll2contact        ,
                                pgm_enroll2web_user       ,
                                pgm_enroll2x_pymt_src     ,
                                x_wait_exp_date           ,
                                pgm_enroll2x_promotion    ,
                                pgm_enroll2prog_hdr       ,
                                x_termscond_accepted      ,
                                x_service_delivery_date   ,
                                default_denomination      ,
                                auto_refill_max_limit     ,
                                auto_refill_counter       ,
                                NULL                      ,
                                NULL                      ,
                                NULL
                                )
  INTO SELF
  FROM x_program_enrolled
  WHERE x_esn = i_esn;
  EXCEPTION
  WHEN TOO_MANY_ROWS
  THEN
    SELECT program_enrolled_type ( objid                     ,
                                   x_esn                     ,
                                   x_amount                  ,
                                   x_type                    ,
                                   x_zipcode                 ,
                                   x_sourcesystem            ,
                                   x_insert_date             ,
                                   x_charge_date             ,
                                   x_pec_customer            ,
                                   x_charge_type             ,
                                   x_enrolled_date           ,
                                   x_start_date              ,
                                   x_reason                  ,
                                   x_exp_date                ,
                                   x_delivery_cycle_number   ,
                                   x_enroll_amount           ,
                                   x_language                ,
                                   x_payment_type            ,
                                   x_grace_period            ,
                                   x_cooling_period          ,
                                   x_service_days            ,
                                   x_cooling_exp_date        ,
                                   x_enrollment_status       ,
                                   x_is_grp_primary          ,
                                   x_tot_grace_period_given  ,
                                   x_next_charge_date        ,
                                   x_next_delivery_date      ,
                                   x_update_stamp            ,
                                   x_update_user             ,
                                   pgm_enroll2pgm_parameter  ,
                                   pgm_enroll2pgm_group      ,
                                   pgm_enroll2site_part      ,
                                   pgm_enroll2part_inst      ,
                                   pgm_enroll2contact        ,
                                   pgm_enroll2web_user       ,
                                   pgm_enroll2x_pymt_src     ,
                                   x_wait_exp_date           ,
                                   pgm_enroll2x_promotion    ,
                                   pgm_enroll2prog_hdr       ,
                                   x_termscond_accepted      ,
                                   x_service_delivery_date   ,
                                   default_denomination      ,
                                   auto_refill_max_limit     ,
                                   auto_refill_counter       ,
                                   NULL                      ,
                                   NULL                      ,
                                   NULL
                                 )
    INTO  SELF
	FROM  ( SELECT *
            FROM   x_program_enrolled
            WHERE  x_esn = i_esn
            AND    x_enrollment_status IN ('ENROLLED','ENROLLMENTSCHEDULED')
            ORDER BY NVL(x_next_charge_date,ADD_MONTHS(SYSDATE,-36)) DESC, objid ASC
	      )
	WHERE ROWNUM = 1;
  END;
  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response := 'PROGRAM ENROLLED NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.program_enrolled_objid := NULL;

      --
      RETURN;
END program_enrolled_type;

MEMBER FUNCTION exist RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END exist;

MEMBER FUNCTION exist ( i_program_enrolled_type IN OUT program_enrolled_type )  RETURN BOOLEAN AS
BEGIN
   --
  IF i_program_enrolled_type.esn IS  NULL THEN
    i_program_enrolled_type.response                   := 'ESN IS NOT PASSED';
    RETURN FALSE;
  END IF;

  --Query the table
  SELECT  objid INTO i_program_enrolled_type.program_enrolled_objid
  FROM x_program_enrolled
  WHERE x_esn = i_program_enrolled_type.esn;
  --
  i_program_enrolled_type.response := 'SUCCESS';

  RETURN TRUE;

 EXCEPTION
    WHEN OTHERS THEN
      --i_program_enrolled_type.response := 'PROGRAM ENROLLED NOT FOUND' || SUBSTR(SQLERRM,1,100);
      i_program_enrolled_type.program_enrolled_objid := NULL;
      RETURN FALSE;
END;

MEMBER FUNCTION ins ( i_program_enrolled_type IN program_enrolled_type ) RETURN program_enrolled_type AS
i_pet program_enrolled_type := i_program_enrolled_type;
BEGIN
  IF i_pet.program_enrolled_objid IS NULL THEN
    i_pet.program_enrolled_objid  := sa.SEQ_X_PROGRAM_ENROLLED.nextval;
  END IF;

  --Assign Time stamp attributes
  IF i_pet.update_stamp IS NULL THEN
    i_pet.update_stamp  := SYSDATE;
  END IF;

  INSERT
    INTO X_PROGRAM_ENROLLED
    (
      objid                             ,
      x_esn                             ,
      x_amount                          ,
      x_type                            ,
      x_zipcode                         ,
      x_sourcesystem                    ,
      x_insert_date                     ,
      x_charge_date                     ,
      x_pec_customer                    ,
      x_charge_type                     ,
      x_enrolled_date                   ,
      x_start_date                      ,
      x_reason                          ,
      x_exp_date                        ,
      x_delivery_cycle_number           ,
      x_enroll_amount                   ,
      x_language                        ,
      x_payment_type                    ,
      x_grace_period                    ,
      x_cooling_period                  ,
      x_service_days                    ,
      x_cooling_exp_date                ,
      x_enrollment_status               ,
      x_is_grp_primary                  ,
      x_tot_grace_period_given          ,
      x_next_charge_date                ,
      x_next_delivery_date              ,
      x_update_stamp                    ,
      x_update_user                     ,
      pgm_enroll2pgm_parameter          ,
      pgm_enroll2pgm_group              ,
      pgm_enroll2site_part              ,
      pgm_enroll2part_inst              ,
      pgm_enroll2contact                ,
      pgm_enroll2web_user               ,
      pgm_enroll2x_pymt_src             ,
      x_wait_exp_date                   ,
      pgm_enroll2x_promotion            ,
      pgm_enroll2prog_hdr               ,
      x_termscond_accepted              ,
      x_service_delivery_date           ,
      default_denomination              ,
      auto_refill_max_limit             ,
      auto_refill_counter
    )
    VALUES
    (
      i_pet.program_enrolled_objid         ,
      i_pet.esn                            ,
      i_pet.amount                         ,
      i_pet.TYPE                           ,
      i_pet.zipcode                        ,
      i_pet.sourcesystem                   ,
      i_pet.insert_date                    ,
      i_pet.charge_date                    ,
      i_pet.pec_customer                   ,
      i_pet.charge_type                    ,
      i_pet.enrolled_date                  ,
      i_pet.start_date                     ,
      i_pet.reason                         ,
      i_pet.exp_date                       ,
      i_pet.delivery_cycle_number          ,
      i_pet.enroll_amount                  ,
      i_pet.LANGUAGE                       ,
      i_pet.payment_type                   ,
      i_pet.grace_period                   ,
      i_pet.cooling_period                 ,
      i_pet.service_days                   ,
      i_pet.cooling_exp_date               ,
      i_pet.enrollment_status              ,
      i_pet.is_grp_primary                 ,
      i_pet.tot_grace_period_given         ,
      i_pet.next_charge_date               ,
      i_pet.next_delivery_date             ,
      i_pet.update_stamp                   ,
      i_pet.update_user                    ,
      i_pet.pgm_enroll2pgm_parameter       ,
      i_pet.pgm_enroll2pgm_group           ,
      i_pet.pgm_enroll2site_part           ,
      i_pet.pgm_enroll2part_inst           ,
      i_pet.pgm_enroll2contact             ,
      i_pet.pgm_enroll2web_user            ,
      i_pet.pgm_enroll2x_pymt_src          ,
      i_pet.wait_exp_date                  ,
      i_pet.pgm_enroll2x_promotion         ,
      i_pet.pgm_enroll2prog_hdr            ,
      i_pet.termscond_accepted             ,
      i_pet.service_delivery_date          ,
      i_pet.default_denomination           ,
      i_pet.auto_refill_max_limit          ,
      i_pet.auto_refill_counter
    );

  -- set Success Response
  i_pet.response := CASE WHEN i_pet.response IS NULL THEN 'SUCCESS' ELSE i_pet.response || '|SUCCESS' END;
  RETURN i_pet;

EXCEPTION
WHEN OTHERS THEN
  i_pet.response := i_pet.response || '|ERROR INSERTING PROGRAM ENROLLED RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN i_pet;
END ins;

MEMBER FUNCTION ins RETURN program_enrolled_type AS
  i_pet     program_enrolled_type := SELF;
  i         program_enrolled_type;
BEGIN
  i := i_pet.ins ( i_program_enrolled_type => i_pet );
  RETURN i;
END ins;

MEMBER FUNCTION upd ( i_program_enrolled_type IN program_enrolled_type ) RETURN program_enrolled_type AS
i_pet program_enrolled_type := i_program_enrolled_type;
BEGIN

  --Assign Time stamp attributes
  IF i_pet.update_stamp IS NULL THEN
    i_pet.update_stamp  := SYSDATE;
  END IF;

  UPDATE
        x_program_enrolled
		SET
			x_esn                             = NVL(i_pet.esn                           , x_esn                           ),
			x_amount                          = NVL(i_pet.amount                        , x_amount                        ),
			x_type                            = NVL(i_pet.TYPE                          , x_type                          ),
			x_zipcode                         = NVL(i_pet.zipcode                       , x_zipcode                       ),
			x_sourcesystem                    = NVL(i_pet.sourcesystem                  , x_sourcesystem                  ),
			x_insert_date                     = NVL(i_pet.insert_date                   , x_insert_date                   ),
			x_charge_date                     = NVL(i_pet.charge_date                   , x_charge_date                   ),
                        x_pec_customer                    = NVL(i_pet.pec_customer                  , x_pec_customer                  ),
			x_charge_type                     = NVL(i_pet.charge_type                   , x_charge_type                   ),
			x_enrolled_date                   = NVL(i_pet.enrolled_date                 , x_enrolled_date                 ),
			x_start_date                      = NVL(i_pet.start_date                    , x_start_date                    ),
			x_reason                          = NVL(i_pet.reason                        , x_reason                        ),
			x_exp_date                        = NVL(i_pet.exp_date                      , x_exp_date                      ),
			x_delivery_cycle_number           = NVL(i_pet.delivery_cycle_number         , x_delivery_cycle_number         ),
			x_enroll_amount                   = NVL(i_pet.enroll_amount                 , x_enroll_amount                 ),
			x_language                        = NVL(i_pet.LANGUAGE                      , x_language                      ),
			x_payment_type                    = NVL(i_pet.payment_type                  , x_payment_type                  ),
			x_grace_period                    = NVL(i_pet.grace_period                  , x_grace_period                  ),
			x_cooling_period                  = NVL(i_pet.cooling_period                , x_cooling_period                ),
			x_service_days                    = NVL(i_pet.service_days                  , x_service_days                  ),
			x_cooling_exp_date                = NVL(i_pet.cooling_exp_date              , x_cooling_exp_date              ),
			x_enrollment_status               = NVL(i_pet.enrollment_status             , x_enrollment_status             ),
			x_is_grp_primary                  = NVL(i_pet.is_grp_primary                , x_is_grp_primary                ),
			x_tot_grace_period_given          = NVL(i_pet.tot_grace_period_given        , x_tot_grace_period_given        ),
			x_next_charge_date                = NVL(i_pet.next_charge_date              , x_next_charge_date              ),
			x_next_delivery_date              = NVL(i_pet.next_delivery_date            , x_next_delivery_date            ),
			x_update_stamp                    = NVL(i_pet.update_stamp                  , x_update_stamp                  ),
			x_update_user                     = NVL(i_pet.update_user                   , x_update_user                   ),
			pgm_enroll2pgm_parameter          = NVL(i_pet.pgm_enroll2pgm_parameter      , pgm_enroll2pgm_parameter        ),
			pgm_enroll2pgm_group              = NVL(i_pet.pgm_enroll2pgm_group          , pgm_enroll2pgm_group            ),
			pgm_enroll2site_part              = NVL(i_pet.pgm_enroll2site_part          , pgm_enroll2site_part            ),
			pgm_enroll2part_inst              = NVL(i_pet.pgm_enroll2part_inst          , pgm_enroll2part_inst            ),
			pgm_enroll2contact                = NVL(i_pet.pgm_enroll2contact            , pgm_enroll2contact              ),
			pgm_enroll2web_user               = NVL(i_pet.pgm_enroll2web_user           , pgm_enroll2web_user             ),
			pgm_enroll2x_pymt_src             = NVL(i_pet.pgm_enroll2x_pymt_src         , pgm_enroll2x_pymt_src           ),
			x_wait_exp_date                   = NVL(i_pet.wait_exp_date                 , x_wait_exp_date                 ),
			pgm_enroll2x_promotion            = NVL(i_pet.pgm_enroll2x_promotion        , pgm_enroll2x_promotion          ),
			pgm_enroll2prog_hdr               = NVL(i_pet.pgm_enroll2prog_hdr           , pgm_enroll2prog_hdr             ),
			x_termscond_accepted              = NVL(i_pet.termscond_accepted            , x_termscond_accepted            ),
			x_service_delivery_date           = NVL(i_pet.service_delivery_date         , x_service_delivery_date         ),
			default_denomination              = NVL(i_pet.default_denomination          , default_denomination            ),
			auto_refill_max_limit             = NVL(i_pet.auto_refill_max_limit         , auto_refill_max_limit           ),
			auto_refill_counter               = NVL(i_pet.auto_refill_counter           ,  auto_refill_counter            )
  WHERE  objid  = i_pet.program_enrolled_objid  ;

  -- set Success Response
  i_pet := program_enrolled_type ( i_program_enrolled_objid => i_pet.program_enrolled_objid );
  i_pet.response := 'SUCCESS';
  RETURN i_pet;

EXCEPTION
WHEN OTHERS THEN
  i_pet.response := i_pet.response || '|ERROR UPDATING PROGRAM ENROLLED RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN i_pet;
END upd;

MEMBER FUNCTION del ( i_program_enrolled_objid IN  NUMBER) RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END del;

MEMBER FUNCTION del RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END del;

END;
/