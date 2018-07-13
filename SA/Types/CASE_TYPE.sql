CREATE OR REPLACE TYPE sa."CASE_TYPE" AS OBJECT (
  case_objid                      NUMBER(22)      ,
  esn                             VARCHAR2(30)    ,
  reference_esn                   VARCHAR2(30)    ,
  new_esn                         VARCHAR2(30)    ,
  title                           VARCHAR2(80)    ,
  s_title                         VARCHAR2(80)    ,
  id_number                       VARCHAR2(255)   ,
  creation_time                   DATE            ,
  internal_case                   NUMBER          ,
  hangup_time                     DATE            ,
  alt_phone_num                   VARCHAR2(20)    ,
  phone_num                       VARCHAR2(20)    ,
  pickup_ext                      VARCHAR2(8)     ,
  topics_title                    VARCHAR2(255)   ,
  yank_flag                       NUMBER          ,
  server_status                   VARCHAR2(2)     ,
  support_type                    VARCHAR2(2)     ,
  warranty_flag                   VARCHAR2(2)     ,
  support_msg                     VARCHAR2(80)    ,
  alt_first_name                  VARCHAR2(30)    ,
  alt_last_name                   VARCHAR2(30)    ,
  alt_fax_number                  VARCHAR2(20)    ,
  alt_e_mail                      VARCHAR2(80)    ,
  alt_site_name                   VARCHAR2(80)    ,
  alt_address                     VARCHAR2(200)   ,
  alt_city                        VARCHAR2(30)    ,
  alt_state                       VARCHAR2(30)    ,
  alt_zipcode                     VARCHAR2(20)    ,
  fcs_cc_notify                   NUMBER          ,
  symptom_code                    VARCHAR2(10)    ,
  cure_code                       VARCHAR2(10)    ,
  site_time                       DATE            ,
  alt_prod_serial                 VARCHAR2(30)    ,
  msg_wait_count                  NUMBER          ,
  reply_wait_count                NUMBER          ,
  reply_state                     NUMBER          ,
  oper_system                     VARCHAR2(20)    ,
  case_sup_type                   VARCHAR2(2)     ,
  payment_method                  VARCHAR2(30)    ,
  ref_number                      VARCHAR2(80)    ,
  doa_check_box                   NUMBER          ,
  customer_satis                  NUMBER          ,
  customer_code                   VARCHAR2(20)    ,
  service_id                      VARCHAR2(30)    ,
  alt_phone                       VARCHAR2(20)    ,
  forward_check                   NUMBER          ,
  cclist1                         VARCHAR2(255)   ,
  cclist2                         VARCHAR2(255)   ,
  keywords                        VARCHAR2(255)   ,
  ownership_stmp                  DATE            ,
  modify_stmp                     DATE            ,
  dist                            NUMBER          ,
  arch_ind                        NUMBER          ,
  is_supercase                    NUMBER          ,
  dev                             NUMBER          ,
  case_soln2workaround            NUMBER          ,
  case_prevq2queue                NUMBER          ,
  case_currq2queue                NUMBER          ,
  case_wip2wipbin                 NUMBER          ,
  case_logic2prog_logic           NUMBER          ,
  case_owner2user                 NUMBER          ,
  case_state2condition            NUMBER          ,
  case_originator2user            NUMBER          ,
  case_empl2employee              NUMBER          ,
  calltype2gbst_elm               NUMBER          ,
  respprty2gbst_elm               NUMBER          ,
  respsvrty2gbst_elm              NUMBER          ,
  case_prod2site_part             NUMBER          ,
  case_reporter2site              NUMBER          ,
  case_reporter2contact           NUMBER          ,
  entitlement2contract            NUMBER          ,
  casests2gbst_elm                NUMBER          ,
  case_rip2ripbin                 NUMBER          ,
  covrd_ppi2site_part             NUMBER          ,
  case_distr2site                 NUMBER          ,
  case2address                    NUMBER          ,
  case_node2site_part             NUMBER          ,
  de_product2site_part            NUMBER          ,
  case_prt2part_info              NUMBER          ,
  de_prt2part_info                NUMBER          ,
  alt_contact2contact             NUMBER          ,
  task2opportunity                NUMBER          ,
  case2life_cycle                 NUMBER          ,
  case_victim2case                NUMBER          ,
  entitle2contr_itm               NUMBER          ,
  x_case_type                     VARCHAR2(30)    ,
  x_carrier_id                    NUMBER          ,
  x_carrier_name                  VARCHAR2(30)    ,
  x_min                           VARCHAR2(30)    ,
  x_phone_model                   VARCHAR2(30)    ,
  x_retailer_name                 VARCHAR2(80)    ,
  x_text_car_id                   VARCHAR2(10)    ,
  x_activation_zip                VARCHAR2(20)    ,
  x_model                         VARCHAR2(20)    ,
  x_replacement_units             NUMBER          ,
  x_require_return                NUMBER          ,
  x_stock_type                    VARCHAR2(20)    ,
  x_case2task                     NUMBER          ,
  x_order_number                  VARCHAR2(7)     ,
  x_po_number                     VARCHAR2(30)    ,
  x_return_desc                   VARCHAR2(255)   ,
  x_waive_fee                     NUMBER          ,
  x_msid                          VARCHAR2(30)    ,
  case2blg_argmnt                 NUMBER          ,
  case2fin_accnt                  NUMBER          ,
  case2pay_channel                NUMBER          ,
  case_type_lvl1                  VARCHAR2(255)   ,
  case_type_lvl2                  VARCHAR2(30)    ,
  case_type_lvl3                  VARCHAR2(30)    ,
  x_iccid                         VARCHAR2(30)    ,
  x_repl_part_num                 VARCHAR2(30)    ,
  details                         case_detail_tab ,
  response                        VARCHAR2(1000)  ,
  numeric_value                   NUMBER          ,
  varchar2_value                  VARCHAR2(2000)  ,
  exist                           VARCHAR2(1)     ,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION case_type RETURN SELF AS RESULT,
  -- Constructor used to get the case attributes by objid
  CONSTRUCTOR FUNCTION case_type ( i_case_objid IN NUMBER ) RETURN SELF AS RESULT,
  -- Function used to close a case by objid
  MEMBER FUNCTION close ( i_case_objid IN NUMBER ) RETURN case_type,
  -- Function used to get the case attributes
  MEMBER FUNCTION get RETURN case_type,
  -- Function used to get the case attributes by objid
  MEMBER FUNCTION get ( i_case_objid IN NUMBER ) RETURN case_type,
  -- Function used to get the case attributes by objid
  MEMBER FUNCTION get ( i_esn        IN VARCHAR2 ,
                        i_case_title IN VARCHAR2 ) RETURN case_type,
  -- Function used to insert a case
  MEMBER FUNCTION ins RETURN case_type,
  -- Function used to save a case
  MEMBER FUNCTION save ( i_cs IN OUT case_type ) RETURN VARCHAR2,
  -- Function used to save a case
  MEMBER FUNCTION save RETURN case_type
);
/
CREATE OR REPLACE TYPE BODY sa.case_type IS

CONSTRUCTOR FUNCTION case_type RETURN SELF AS RESULT IS
BEGIN
  SELF.details := case_detail_tab();
  RETURN;
END;

CONSTRUCTOR FUNCTION case_type ( i_case_objid IN NUMBER ) RETURN SELF AS RESULT IS
BEGIN
  BEGIN
    SELECT case_type ( case_objid               , -- case_objid                  NUMBER(22)
                       esn                      , -- esn                         VARCHAR2(30)
                       NULL                     , -- reference_esn               VARCHAR2(30)
                       NULL                     , -- new_esn                     VARCHAR2(30)
                       title                    , -- title                       VARCHAR2(80)
                       s_title                  , -- s_title                     VARCHAR2(80)
                       id_number                , -- id_number                   VARCHAR2(255)
                       creation_time            , -- creation_time               DATE
                       internal_case            , -- internal_case               NUMBER
                       hangup_time              , -- hangup_time                 DATE
                       alt_phone_num            , -- alt_phone_num               VARCHAR2(20)
                       phone_num                , -- phone_num                   VARCHAR2(20)
                       pickup_ext               , -- pickup_ext                  VARCHAR2(8)
                       topics_title             , -- topics_title                VARCHAR2(255)
                       yank_flag                , -- yank_flag                   NUMBER
                       server_status            , -- server_status               VARCHAR2(2)
                       support_type             , -- support_type                VARCHAR2(2)
                       warranty_flag            , -- warranty_flag               VARCHAR2(2)
                       support_msg              , -- support_msg                 VARCHAR2(80)
                       alt_first_name           , -- alt_first_name              VARCHAR2(30)
                       alt_last_name            , -- alt_last_name               VARCHAR2(30)
                       alt_fax_number           , -- alt_fax_number              VARCHAR2(20)
                       alt_e_mail               , -- alt_e_mail                  VARCHAR2(80)
                       alt_site_name            , -- alt_site_name               VARCHAR2(80)
                       alt_address              , -- alt_address                 VARCHAR2(200)
                       alt_city                 , -- alt_city                    VARCHAR2(30)
                       alt_state                , -- alt_state                   VARCHAR2(30)
                       alt_zipcode              , -- alt_zipcode                 VARCHAR2(20)
                       fcs_cc_notify            , -- fcs_cc_notify               NUMBER
                       symptom_code             , -- symptom_code                VARCHAR2(10)
                       cure_code                , -- cure_code                   VARCHAR2(10)
                       site_time                , -- site_time                   DATE
                       alt_prod_serial          , -- alt_prod_serial             VARCHAR2(30)
                       msg_wait_count           , -- msg_wait_count              NUMBER
                       reply_wait_count         , -- reply_wait_count            NUMBER
                       reply_state              , -- reply_state                 NUMBER
                       oper_system              , -- oper_system                 VARCHAR2(20)
                       case_sup_type            , -- case_sup_type               VARCHAR2(2)
                       payment_method           , -- payment_method              VARCHAR2(30)
                       ref_number               , -- ref_number                  VARCHAR2(80)
                       doa_check_box            , -- doa_check_box               NUMBER
                       customer_satis           , -- customer_satis              NUMBER
                       customer_code            , -- customer_code               VARCHAR2(20)
                       service_id               , -- service_id                  VARCHAR2(30)
                       alt_phone                , -- alt_phone                   VARCHAR2(20)
                       forward_check            , -- forward_check               NUMBER
                       cclist1                  , -- cclist1                     VARCHAR2(255)
                       cclist2                  , -- cclist2                     VARCHAR2(255)
                       keywords                 , -- keywords                    VARCHAR2(255)
                       ownership_stmp           , -- ownership_stmp              DATE
                       modify_stmp              , -- modify_stmp                 DATE
                       dist                     , -- dist                        NUMBER
                      arch_ind                 , -- arch_ind                    NUMBER
                       is_supercase             , -- is_supercase                NUMBER
                       dev                      , -- dev                         NUMBER
                       case_soln2workaround     , -- case_soln2workaround        NUMBER
                       case_prevq2queue         , -- case_prevq2queue            NUMBER
                       case_currq2queue         , -- case_currq2queue            NUMBER
                       case_wip2wipbin          , -- case_wip2wipbin             NUMBER
                       case_logic2prog_logic    , -- case_logic2prog_logic       NUMBER
                       case_owner2user          , -- case_owner2user             NUMBER
                       case_state2condition     , -- case_state2condition        NUMBER
                       case_originator2user     , -- case_originator2user        NUMBER
                       case_empl2employee       , -- case_empl2employee          NUMBER
                       calltype2gbst_elm        , -- calltype2gbst_elm           NUMBER
                       respprty2gbst_elm        , -- respprty2gbst_elm           NUMBER
                       respsvrty2gbst_elm       , -- respsvrty2gbst_elm          NUMBER
                       case_prod2site_part      , -- case_prod2site_part         NUMBER
                       case_reporter2site       , -- case_reporter2site          NUMBER
                       case_reporter2contact    , -- case_reporter2contact       NUMBER
                       entitlement2contract     , -- entitlement2contract        NUMBER
                       casests2gbst_elm         , -- casests2gbst_elm            NUMBER
                       case_rip2ripbin          , -- case_rip2ripbin             NUMBER
                       covrd_ppi2site_part      , -- covrd_ppi2site_part         NUMBER
                       case_distr2site          , -- case_distr2site             NUMBER
                       case2address             , -- case2address                NUMBER
                       case_node2site_part      , -- case_node2site_part         NUMBER
                       de_product2site_part     , -- de_product2site_part        NUMBER
                       case_prt2part_info       , -- case_prt2part_info          NUMBER
                       de_prt2part_info         , -- de_prt2part_info            NUMBER
                       alt_contact2contact      , -- alt_contact2contact         NUMBER
                       task2opportunity         , -- task2opportunity            NUMBER
                       case2life_cycle          , -- case2life_cycle             NUMBER
                       case_victim2case         , -- case_victim2case            NUMBER
                       entitle2contr_itm        , -- entitle2contr_itm           NUMBER
                       x_case_type              , -- x_case_type                 VARCHAR2(30)
                       x_carrier_id             , -- x_carrier_id                NUMBER
                       x_carrier_name           , -- x_carrier_name              VARCHAR2(30)
                       x_min                    , -- x_min                       VARCHAR2(30)
                       x_phone_model            , -- x_phone_model               VARCHAR2(30)
                       x_retailer_name          , -- x_retailer_name             VARCHAR2(80)
                       x_text_car_id            , -- x_text_car_id               VARCHAR2(10)
                       x_activation_zip         , -- x_activation_zip            VARCHAR2(20)
                       x_model                  , -- x_model                     VARCHAR2(20)
                       x_replacement_units      , -- x_replacement_units         NUMBER
                       x_require_return         , -- x_require_return            NUMBER
                       x_stock_type             , -- x_stock_type                VARCHAR2(20)
                       x_case2task              , -- x_case2task                 NUMBER
                       x_order_number           , -- x_order_number              VARCHAR2(7)
                       x_po_number              , -- x_po_number                 VARCHAR2(30)
                       x_return_desc            , -- x_return_desc               VARCHAR2(255)
                       x_waive_fee              , -- x_waive_fee                 NUMBER
                       x_msid                   , -- x_msid                      VARCHAR2(30)
                       case2blg_argmnt          , -- case2blg_argmnt             NUMBER
                       case2fin_accnt           , -- case2fin_accnt              NUMBER
                       case2pay_channel         , -- case2pay_channel            NUMBER
                       case_type_lvl1           , -- case_type_lvl1              VARCHAR2(255)
                       case_type_lvl2           , -- case_type_lvl2              VARCHAR2(30)
                       case_type_lvl3           , -- case_type_lvl3              VARCHAR2(30)
                       x_iccid                  , -- x_iccid                     VARCHAR2(30)
                       x_repl_part_num          , -- x_repl_part_num             VARCHAR2(30)
                       NULL                     , -- details                     case_detail_tab
                       NULL                     , -- response                    VARCHAR2(1000)
                       NULL                     , -- numeric_value               NUMBER
                       NULL                     , -- varchar2_value              VARCHAR2(2000)
                       NULL                       -- exist                       VARCHAR2(1)
                     )
    INTO   SELF
    FROM   table_case
    WHERE  objid = i_case_objid;
   EXCEPTION
     WHEN OTHERS THEN
       SELF.case_objid := i_case_objid;
       SELF.response := 'CASE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;

EXCEPTION
   WHEN OTHERS THEN
     SELF.case_objid := i_case_objid;
     SELF.response := 'CASE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION close ( i_case_objid IN NUMBER ) RETURN case_type IS
  c  case_type := case_type ();
BEGIN

  IF i_case_objid IS NULL THEN
    c.response := 'CASE NOT PASSED';
    RETURN c;
  END IF;

  --
  c := case_type ( i_case_objid => i_case_objid );

  --
  IF c.response NOT LIKE '%SUCCESS%' THEN
    RETURN c;
  END IF;

  -- perform call to close ticket (case)
  NULL;

  --
  c.response := 'SUCCESS';

  --
  RETURN c;

EXCEPTION
   WHEN OTHERS THEN
     c.response := 'CASE NOT CLOSED: ' || SUBSTR(SQLERRM,1,100);
     RETURN c;
END close;

-- Function used to expire a case with the case objid
MEMBER FUNCTION get RETURN case_type IS

  c  case_type := SELF;

BEGIN

  --
  IF c.case_objid IS NULL THEN
    c.response := 'CASE OBJID NOT PASSED';
    RETURN c;
  END IF;

  --
  c := case_type ( i_case_objid => c.case_objid );

  --
  c.response := 'SUCCESS';

  --
  RETURN c;

EXCEPTION
   WHEN OTHERS THEN
     c.response := 'case NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN c;
END get;

-- Function used to expire a case with the case objid
MEMBER FUNCTION get ( i_case_objid IN NUMBER ) RETURN case_type IS

  c  case_type := case_type ();

BEGIN
  --
  c.case_objid := i_case_objid;

  --
  IF i_case_objid IS NULL THEN
    c.response := 'case OBJID NOT PASSED';
    RETURN c;
  END IF;

  --
  c.response := 'SUCCESS';

  RETURN c;

EXCEPTION
   WHEN OTHERS THEN
     c.response := 'CASE NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN c;
END get;

-- Function used to expire a case with the case objid
-- Function used to expire a case with the case objid
MEMBER FUNCTION get ( i_esn        IN VARCHAR2 ,
                      i_case_title IN VARCHAR2 ) RETURN case_type IS

  c  case_type := case_type ();
  case_count 	NUMBER(5) := 0; -- CR44687
BEGIN
  --
  c.esn := i_esn;
  c.title := i_case_title;

  --
  IF c.title IS NULL THEN
    c.response := 'CASE TITLE NOT PASSED';
    RETURN c;
  END IF;

  --
  IF c.esn IS NULL THEN
    c.response := 'ESN NOT PASSED';
    RETURN c;
  END IF;

  IF i_case_title LIKE '%PHONE%UPGRADE%' THEN
    BEGIN
	 SELECT  COUNT(1)
	 INTO    case_count
	 FROM    table_case  cs 			--	for upgrade table_case has old esn
	 WHERE   cs.x_esn    = i_esn		--	Check if new esn record is already present in table_case
	 AND     cs.s_title  LIKE i_case_title
	 AND     cs.objid    = ( SELECT  MAX(inn.objid)
                             FROM    table_case inn
                             WHERE   x_esn = cs.x_esn
                             AND     s_title LIKE i_case_title
                           )
	 AND     EXISTS (
					 SELECT   1
					 FROM     table_x_case_detail cd
					 WHERE    cs.objid = detail2case
					 AND      X_NAME   = 'NEW_ESN'
					 AND      X_VALUE  != x_esn
					);
     EXCEPTION
       WHEN others THEN
	     case_count := 0;
	END;

    IF case_count > 0 THEN
	  BEGIN
			 SELECT cs.objid                  ,
					cs.x_esn                  ,
					cs.x_esn                  , -- REFERENCE_ESN
					cs.title                  ,
					cs.s_title                ,
					cs.id_number              ,
					cs.creation_time          ,
					cs.internal_case          ,
					cs.hangup_time            ,
					cs.alt_phone_num          ,
					cs.phone_num              ,
					cs.pickup_ext             ,
					cs.topics_title           ,
					cs.yank_flag              ,
					cs.server_status          ,
					cs.support_type           ,
					cs.warranty_flag          ,
					cs.support_msg            ,
					cs.alt_first_name         ,
					cs.alt_last_name          ,
					cs.alt_fax_number         ,
					cs.alt_e_mail             ,
					cs.alt_site_name          ,
					cs.alt_address            ,
					cs.alt_city               ,
					cs.alt_state              ,
					cs.alt_zipcode            ,
					cs.fcs_cc_notify          ,
					cs.symptom_code           ,
					cs.cure_code              ,
					cs.site_time              ,
					cs.alt_prod_serial        ,
					cs.msg_wait_count         ,
					cs.reply_wait_count       ,
					cs.reply_state            ,
					cs.oper_system            ,
					cs.case_sup_type          ,
					cs.payment_method         ,
					cs.ref_number             ,
					cs.doa_check_box          ,
					cs.customer_satis         ,
					cs.customer_code          ,
					cs.service_id             ,
					cs.alt_phone              ,
					cs.forward_check          ,
					cs.cclist1                ,
					cs.cclist2                ,
					cs.keywords               ,
					cs.ownership_stmp         ,
					cs.modify_stmp            ,
					cs.dist                   ,
					cs.arch_ind               ,
					cs.is_supercase           ,
					cs.dev                    ,
					cs.case_soln2workaround   ,
					cs.case_prevq2queue       ,
					cs.case_currq2queue       ,
					cs.case_wip2wipbin        ,
					cs.case_logic2prog_logic  ,
					cs.case_owner2user        ,
					cs.case_state2condition   ,
					cs.case_originator2user   ,
					cs.case_empl2employee     ,
					cs.calltype2gbst_elm      ,
					cs.respprty2gbst_elm      ,
					cs.respsvrty2gbst_elm     ,
					cs.case_prod2site_part    ,
					cs.case_reporter2site     ,
					cs.case_reporter2contact  ,
					cs.entitlement2contract   ,
					cs.casests2gbst_elm       ,
					cs.case_rip2ripbin        ,
					cs.covrd_ppi2site_part    ,
					cs.case_distr2site        ,
					cs.case2address           ,
					cs.case_node2site_part    ,
					cs.de_product2site_part   ,
					cs.case_prt2part_info     ,
					cs.de_prt2part_info       ,
					cs.alt_contact2contact    ,
					cs.task2opportunity       ,
					cs.case2life_cycle        ,
					cs.case_victim2case       ,
					cs.entitle2contr_itm      ,
					cs.x_case_type            ,
					cs.x_carrier_id           ,
					cs.x_carrier_name         ,
					cs.x_min                  ,
					cs.x_phone_model          ,
					cs.x_retailer_name        ,
					cs.x_text_car_id          ,
					cs.x_activation_zip       ,
					cs.x_model                ,
					cs.x_replacement_units    ,
					cs.x_require_return       ,
					cs.x_stock_type           ,
					cs.x_case2task            ,
					cs.x_order_number         ,
					cs.x_po_number            ,
					cs.x_return_desc          ,
					cs.x_waive_fee            ,
					cs.x_msid                 ,
					cs.case2blg_argmnt        ,
					cs.case2fin_accnt         ,
					cs.case2pay_channel       ,
					cs.case_type_lvl1         ,
					cs.case_type_lvl2         ,
					cs.case_type_lvl3         ,
					cs.x_iccid                ,
					cs.x_repl_part_num
			 INTO   c.case_objid              ,
					c.esn                     ,
					c.reference_esn           ,
					c.title                   ,
					c.s_title                 ,
					c.id_number               ,
					c.creation_time           ,
					c.internal_case           ,
					c.hangup_time             ,
					c.alt_phone_num           ,
					c.phone_num               ,
					c.pickup_ext              ,
					c.topics_title            ,
					c.yank_flag               ,
					c.server_status           ,
					c.support_type            ,
					c.warranty_flag           ,
					c.support_msg             ,
					c.alt_first_name          ,
					c.alt_last_name           ,
					c.alt_fax_number          ,
					c.alt_e_mail              ,
					c.alt_site_name           ,
					c.alt_address             ,
					c.alt_city                ,
					c.alt_state               ,
					c.alt_zipcode             ,
					c.fcs_cc_notify           ,
					c.symptom_code            ,
					c.cure_code               ,
					c.site_time               ,
					c.alt_prod_serial         ,
					c.msg_wait_count          ,
					c.reply_wait_count        ,
					c.reply_state             ,
					c.oper_system             ,
					c.case_sup_type           ,
					c.payment_method          ,
					c.ref_number              ,
					c.doa_check_box           ,
					c.customer_satis          ,
					c.customer_code           ,
					c.service_id              ,
					c.alt_phone               ,
					c.forward_check           ,
					c.cclist1                 ,
					c.cclist2                 ,
					c.keywords                ,
					c.ownership_stmp          ,
					c.modify_stmp             ,
					c.dist                    ,
					c.arch_ind                ,
					c.is_supercase            ,
					c.dev                     ,
					c.case_soln2workaround    ,
					c.case_prevq2queue        ,
					c.case_currq2queue        ,
					c.case_wip2wipbin         ,
					c.case_logic2prog_logic   ,
					c.case_owner2user         ,
					c.case_state2condition    ,
					c.case_originator2user    ,
					c.case_empl2employee      ,
					c.calltype2gbst_elm       ,
					c.respprty2gbst_elm       ,
					c.respsvrty2gbst_elm      ,
					c.case_prod2site_part     ,
					c.case_reporter2site      ,
					c.case_reporter2contact   ,
					c.entitlement2contract    ,
					c.casests2gbst_elm        ,
					c.case_rip2ripbin         ,
					c.covrd_ppi2site_part     ,
					c.case_distr2site         ,
					c.case2address            ,
					c.case_node2site_part     ,
					c.de_product2site_part    ,
					c.case_prt2part_info      ,
					c.de_prt2part_info        ,
					c.alt_contact2contact     ,
					c.task2opportunity        ,
					c.case2life_cycle         ,
					c.case_victim2case        ,
					c.entitle2contr_itm       ,
					c.x_case_type             ,
					c.x_carrier_id            ,
					c.x_carrier_name          ,
					c.x_min                   ,
					c.x_phone_model           ,
					c.x_retailer_name         ,
					c.x_text_car_id           ,
					c.x_activation_zip        ,
					c.x_model                 ,
					c.x_replacement_units     ,
					c.x_require_return        ,
					c.x_stock_type            ,
					c.x_case2task             ,
					c.x_order_number          ,
					c.x_po_number             ,
					c.x_return_desc           ,
					c.x_waive_fee             ,
					c.x_msid                  ,
					c.case2blg_argmnt         ,
					c.case2fin_accnt          ,
					c.case2pay_channel        ,
					c.case_type_lvl1          ,
					c.case_type_lvl2          ,
					c.case_type_lvl3          ,
					c.x_iccid                 ,
					c.x_repl_part_num
       FROM  TABLE_CASE cs
       WHERE OBJID = (SELECT OBJID
                      FROM  (SELECT row_number () over (order by  tc.creation_time desc) rn, tc.objid
                             FROM   table_x_case_detail cd,
                                    table_case tc
                             WHERE  cd.x_name = 'NEW_ESN'
                             AND    cd.x_value = i_esn
                             AND    cd.detail2case = tc.objid
                             AND    tc.s_title LIKE i_case_title
                             AND    tc.objid = ( SELECT MAX(objid)
                                                 FROM   table_case
                                                 WHERE  x_esn = tc.x_esn
                                                 AND    s_title LIKE i_case_title))
                      WHERE RN = 1
							   );
    EXCEPTION
      WHEN others THEN
      NULL;
          --
    END;
    END IF; -- case_count > 0
  END IF; -- PHONE UPGRADE

  IF c.case_objid IS NULL THEN
    BEGIN
      SELECT cs.objid                  ,
             cs.x_esn                  ,
             cs.title                  ,
             cs.s_title                ,
             cs.id_number              ,
             cs.creation_time          ,
             cs.internal_case          ,
             cs.hangup_time            ,
             cs.alt_phone_num          ,
             cs.phone_num              ,
             cs.pickup_ext             ,
             cs.topics_title           ,
             cs.yank_flag              ,
             cs.server_status          ,
             cs.support_type           ,
             cs.warranty_flag          ,
             cs.support_msg            ,
             cs.alt_first_name         ,
             cs.alt_last_name          ,
             cs.alt_fax_number         ,
             cs.alt_e_mail             ,
             cs.alt_site_name          ,
             cs.alt_address            ,
             cs.alt_city               ,
             cs.alt_state              ,
             cs.alt_zipcode            ,
             cs.fcs_cc_notify          ,
             cs.symptom_code           ,
             cs.cure_code              ,
             cs.site_time              ,
             cs.alt_prod_serial        ,
             cs.msg_wait_count         ,
             cs.reply_wait_count       ,
             cs.reply_state            ,
             cs.oper_system            ,
             cs.case_sup_type          ,
             cs.payment_method         ,
             cs.ref_number             ,
             cs.doa_check_box          ,
             cs.customer_satis         ,
             cs.customer_code          ,
             cs.service_id             ,
             cs.alt_phone              ,
             cs.forward_check          ,
             cs.cclist1                ,
             cs.cclist2                ,
             cs.keywords               ,
             cs.ownership_stmp         ,
             cs.modify_stmp            ,
             cs.dist                   ,
             cs.arch_ind               ,
             cs.is_supercase           ,
             cs.dev                    ,
             cs.case_soln2workaround   ,
             cs.case_prevq2queue       ,
             cs.case_currq2queue       ,
             cs.case_wip2wipbin        ,
             cs.case_logic2prog_logic  ,
             cs.case_owner2user        ,
             cs.case_state2condition   ,
             cs.case_originator2user   ,
             cs.case_empl2employee     ,
             cs.calltype2gbst_elm      ,
             cs.respprty2gbst_elm      ,
             cs.respsvrty2gbst_elm     ,
             cs.case_prod2site_part    ,
             cs.case_reporter2site     ,
             cs.case_reporter2contact  ,
             cs.entitlement2contract   ,
             cs.casests2gbst_elm       ,
             cs.case_rip2ripbin        ,
             cs.covrd_ppi2site_part    ,
             cs.case_distr2site        ,
             cs.case2address           ,
             cs.case_node2site_part    ,
             cs.de_product2site_part   ,
             cs.case_prt2part_info     ,
             cs.de_prt2part_info       ,
             cs.alt_contact2contact    ,
             cs.task2opportunity       ,
             cs.case2life_cycle        ,
             cs.case_victim2case       ,
             cs.entitle2contr_itm      ,
             cs.x_case_type            ,
             cs.x_carrier_id           ,
             cs.x_carrier_name         ,
             cs.x_min                  ,
             cs.x_phone_model          ,
             cs.x_retailer_name        ,
             cs.x_text_car_id          ,
             cs.x_activation_zip       ,
             cs.x_model                ,
             cs.x_replacement_units    ,
             cs.x_require_return       ,
             cs.x_stock_type           ,
             cs.x_case2task            ,
             cs.x_order_number         ,
             cs.x_po_number            ,
             cs.x_return_desc          ,
             cs.x_waive_fee            ,
             cs.x_msid                 ,
             cs.case2blg_argmnt        ,
             cs.case2fin_accnt         ,
             cs.case2pay_channel       ,
             cs.case_type_lvl1         ,
             cs.case_type_lvl2         ,
             cs.case_type_lvl3         ,
             cs.x_iccid                ,
             cs.x_repl_part_num
      INTO   c.case_objid              ,
             c.esn                     ,
             c.title                   ,
             c.s_title                 ,
             c.id_number               ,
             c.creation_time           ,
             c.internal_case           ,
             c.hangup_time             ,
             c.alt_phone_num           ,
             c.phone_num               ,
             c.pickup_ext              ,
             c.topics_title            ,
             c.yank_flag               ,
             c.server_status           ,
             c.support_type            ,
             c.warranty_flag           ,
             c.support_msg             ,
             c.alt_first_name          ,
             c.alt_last_name           ,
             c.alt_fax_number          ,
             c.alt_e_mail              ,
             c.alt_site_name           ,
             c.alt_address             ,
             c.alt_city                ,
             c.alt_state               ,
             c.alt_zipcode             ,
             c.fcs_cc_notify           ,
             c.symptom_code            ,
             c.cure_code               ,
             c.site_time               ,
             c.alt_prod_serial         ,
             c.msg_wait_count          ,
             c.reply_wait_count        ,
             c.reply_state             ,
             c.oper_system             ,
             c.case_sup_type           ,
             c.payment_method          ,
             c.ref_number              ,
             c.doa_check_box           ,
             c.customer_satis          ,
             c.customer_code           ,
             c.service_id              ,
             c.alt_phone               ,
             c.forward_check           ,
             c.cclist1                 ,
             c.cclist2                 ,
             c.keywords                ,
             c.ownership_stmp          ,
             c.modify_stmp             ,
             c.dist                    ,
             c.arch_ind                ,
             c.is_supercase            ,
             c.dev                     ,
             c.case_soln2workaround    ,
             c.case_prevq2queue        ,
             c.case_currq2queue        ,
             c.case_wip2wipbin         ,
             c.case_logic2prog_logic   ,
             c.case_owner2user         ,
             c.case_state2condition    ,
             c.case_originator2user    ,
             c.case_empl2employee      ,
             c.calltype2gbst_elm       ,
             c.respprty2gbst_elm       ,
             c.respsvrty2gbst_elm      ,
             c.case_prod2site_part     ,
             c.case_reporter2site      ,
             c.case_reporter2contact   ,
             c.entitlement2contract    ,
             c.casests2gbst_elm        ,
             c.case_rip2ripbin         ,
             c.covrd_ppi2site_part     ,
             c.case_distr2site         ,
             c.case2address            ,
             c.case_node2site_part     ,
             c.de_product2site_part    ,
             c.case_prt2part_info      ,
             c.de_prt2part_info        ,
             c.alt_contact2contact     ,
             c.task2opportunity        ,
             c.case2life_cycle         ,
             c.case_victim2case        ,
             c.entitle2contr_itm       ,
             c.x_case_type             ,
             c.x_carrier_id            ,
             c.x_carrier_name          ,
             c.x_min                   ,
             c.x_phone_model           ,
             c.x_retailer_name         ,
             c.x_text_car_id           ,
             c.x_activation_zip        ,
             c.x_model                 ,
             c.x_replacement_units     ,
             c.x_require_return        ,
             c.x_stock_type            ,
             c.x_case2task             ,
             c.x_order_number          ,
             c.x_po_number             ,
             c.x_return_desc           ,
             c.x_waive_fee             ,
             c.x_msid                  ,
             c.case2blg_argmnt         ,
             c.case2fin_accnt          ,
             c.case2pay_channel        ,
             c.case_type_lvl1          ,
             c.case_type_lvl2          ,
             c.case_type_lvl3          ,
             c.x_iccid                 ,
             c.x_repl_part_num
      FROM   table_case cs
      WHERE  cs.x_esn = i_esn
      AND    cs.s_title LIKE i_case_title
      AND    cs.objid = ( SELECT MAX(objid)
                          FROM   table_case
                          WHERE  x_esn = cs.x_esn
                          AND    s_title LIKE i_case_title
                        );
     EXCEPTION
       WHEN no_data_found THEN
         BEGIN
           SELECT cs.objid                  ,
                  cs.x_esn                  ,
                  cs.x_esn                  , -- REFERENCE_ESN
                  cs.title                  ,
                  cs.s_title                ,
                  cs.id_number              ,
                  cs.creation_time          ,
                  cs.internal_case          ,
                  cs.hangup_time            ,
                  cs.alt_phone_num          ,
                  cs.phone_num              ,
                  cs.pickup_ext             ,
                  cs.topics_title           ,
                  cs.yank_flag              ,
                  cs.server_status          ,
                  cs.support_type           ,
                  cs.warranty_flag          ,
                  cs.support_msg            ,
                  cs.alt_first_name         ,
                  cs.alt_last_name          ,
                  cs.alt_fax_number         ,
                  cs.alt_e_mail             ,
                  cs.alt_site_name          ,
                  cs.alt_address            ,
                  cs.alt_city               ,
                  cs.alt_state              ,
                  cs.alt_zipcode            ,
                  cs.fcs_cc_notify          ,
                  cs.symptom_code           ,
                  cs.cure_code              ,
                  cs.site_time              ,
                  cs.alt_prod_serial        ,
                  cs.msg_wait_count         ,
                  cs.reply_wait_count       ,
                  cs.reply_state            ,
                  cs.oper_system            ,
                  cs.case_sup_type          ,
                  cs.payment_method         ,
                  cs.ref_number             ,
                  cs.doa_check_box          ,
                  cs.customer_satis         ,
                  cs.customer_code          ,
                  cs.service_id             ,
                  cs.alt_phone              ,
                  cs.forward_check          ,
                  cs.cclist1                ,
                  cs.cclist2                ,
                  cs.keywords               ,
                  cs.ownership_stmp         ,
                  cs.modify_stmp            ,
                  cs.dist                   ,
                  cs.arch_ind               ,
                  cs.is_supercase           ,
                  cs.dev                    ,
                  cs.case_soln2workaround   ,
                  cs.case_prevq2queue       ,
                  cs.case_currq2queue       ,
                  cs.case_wip2wipbin        ,
                  cs.case_logic2prog_logic  ,
                  cs.case_owner2user        ,
                  cs.case_state2condition   ,
                  cs.case_originator2user   ,
                  cs.case_empl2employee     ,
                  cs.calltype2gbst_elm      ,
                  cs.respprty2gbst_elm      ,
                  cs.respsvrty2gbst_elm     ,
                  cs.case_prod2site_part    ,
                  cs.case_reporter2site     ,
                  cs.case_reporter2contact  ,
                  cs.entitlement2contract   ,
                  cs.casests2gbst_elm       ,
                  cs.case_rip2ripbin        ,
                  cs.covrd_ppi2site_part    ,
                  cs.case_distr2site        ,
                  cs.case2address           ,
                  cs.case_node2site_part    ,
                  cs.de_product2site_part   ,
                  cs.case_prt2part_info     ,
                  cs.de_prt2part_info       ,
                  cs.alt_contact2contact    ,
                  cs.task2opportunity       ,
                  cs.case2life_cycle        ,
                  cs.case_victim2case       ,
                  cs.entitle2contr_itm      ,
                  cs.x_case_type            ,
                  cs.x_carrier_id           ,
                  cs.x_carrier_name         ,
                  cs.x_min                  ,
                  cs.x_phone_model          ,
                  cs.x_retailer_name        ,
                  cs.x_text_car_id          ,
                  cs.x_activation_zip       ,
                  cs.x_model                ,
                  cs.x_replacement_units    ,
                  cs.x_require_return       ,
                  cs.x_stock_type           ,
                  cs.x_case2task            ,
                  cs.x_order_number         ,
                  cs.x_po_number            ,
                  cs.x_return_desc          ,
                  cs.x_waive_fee            ,
                  cs.x_msid                 ,
                  cs.case2blg_argmnt        ,
                  cs.case2fin_accnt         ,
                  cs.case2pay_channel       ,
                  cs.case_type_lvl1         ,
                  cs.case_type_lvl2         ,
                  cs.case_type_lvl3         ,
                  cs.x_iccid                ,
                  cs.x_repl_part_num
           INTO   c.case_objid              ,
                  c.esn                     ,
                  c.reference_esn           ,
                  c.title                   ,
                  c.s_title                 ,
                  c.id_number               ,
                  c.creation_time           ,
                  c.internal_case           ,
                  c.hangup_time             ,
                  c.alt_phone_num           ,
                  c.phone_num               ,
                  c.pickup_ext              ,
                  c.topics_title            ,
                  c.yank_flag               ,
                  c.server_status           ,
                  c.support_type            ,
                  c.warranty_flag           ,
                  c.support_msg             ,
                  c.alt_first_name          ,
                  c.alt_last_name           ,
                  c.alt_fax_number          ,
                  c.alt_e_mail              ,
                  c.alt_site_name           ,
                  c.alt_address             ,
                  c.alt_city                ,
                  c.alt_state               ,
                  c.alt_zipcode             ,
                  c.fcs_cc_notify           ,
                  c.symptom_code            ,
                  c.cure_code               ,
                  c.site_time               ,
                  c.alt_prod_serial         ,
                  c.msg_wait_count          ,
                  c.reply_wait_count        ,
                  c.reply_state             ,
                  c.oper_system             ,
                  c.case_sup_type           ,
                  c.payment_method          ,
                  c.ref_number              ,
                  c.doa_check_box           ,
                  c.customer_satis          ,
                  c.customer_code           ,
                  c.service_id              ,
                  c.alt_phone               ,
                  c.forward_check           ,
                  c.cclist1                 ,
                  c.cclist2                 ,
                  c.keywords                ,
                  c.ownership_stmp          ,
                  c.modify_stmp             ,
                  c.dist                    ,
                  c.arch_ind                ,
                  c.is_supercase            ,
                  c.dev                     ,
                  c.case_soln2workaround    ,
                  c.case_prevq2queue        ,
                  c.case_currq2queue        ,
                  c.case_wip2wipbin         ,
                  c.case_logic2prog_logic   ,
                  c.case_owner2user         ,
                  c.case_state2condition    ,
                  c.case_originator2user    ,
                  c.case_empl2employee      ,
                  c.calltype2gbst_elm       ,
                  c.respprty2gbst_elm       ,
                  c.respsvrty2gbst_elm      ,
                  c.case_prod2site_part     ,
                  c.case_reporter2site      ,
                  c.case_reporter2contact   ,
                  c.entitlement2contract    ,
                  c.casests2gbst_elm        ,
                  c.case_rip2ripbin         ,
                  c.covrd_ppi2site_part     ,
                  c.case_distr2site         ,
                  c.case2address            ,
                  c.case_node2site_part     ,
                  c.de_product2site_part    ,
                  c.case_prt2part_info      ,
                  c.de_prt2part_info        ,
                  c.alt_contact2contact     ,
                  c.task2opportunity        ,
                  c.case2life_cycle         ,
                  c.case_victim2case        ,
                  c.entitle2contr_itm       ,
                  c.x_case_type             ,
                  c.x_carrier_id            ,
                  c.x_carrier_name          ,
                  c.x_min                   ,
                  c.x_phone_model           ,
                  c.x_retailer_name         ,
                  c.x_text_car_id           ,
                  c.x_activation_zip        ,
                  c.x_model                 ,
                  c.x_replacement_units     ,
                  c.x_require_return        ,
                  c.x_stock_type            ,
                  c.x_case2task             ,
                  c.x_order_number          ,
                  c.x_po_number             ,
                  c.x_return_desc           ,
                  c.x_waive_fee             ,
                  c.x_msid                  ,
                  c.case2blg_argmnt         ,
                  c.case2fin_accnt          ,
                  c.case2pay_channel        ,
                  c.case_type_lvl1          ,
                  c.case_type_lvl2          ,
                  c.case_type_lvl3          ,
                  c.x_iccid                 ,
                  c.x_repl_part_num
           FROM   table_x_case_detail cd,
                  table_case cs
           WHERE  cd.x_name = 'NEW_ESN'
                          AND    cd.x_value = i_esn
           AND    cd.detail2case = cs.objid
           AND    cs.s_title LIKE i_case_title
           AND    cs.objid = ( SELECT MAX(objid)
                               FROM   table_case
                               WHERE  x_esn = cs.x_esn
                               AND    s_title LIKE i_case_title
                             );
          EXCEPTION
            WHEN others THEN
              c.response := 'CASE NOT FOUND';
              --
              RETURN c;
              --
         END;

       WHEN others THEN
         c.response := 'CASE NOT FOUND';
         --
         RETURN c;
         --
    END;

  END IF;

  BEGIN
    SELECT case_detail_type ( objid           , --    NUMBER(38)
                              dev             , --    NUMBER
                              x_name          , --    VARCHAR2(30)
                              x_value         , --    VARCHAR2(500)
                              detail2case     , --    NUMBER
                              response        , --    VARCHAR2(1000)
                              numeric_value   , --    NUMBER
                              varchar2_value  , --    VARCHAR2(2000)
                              exist             --    VARCHAR2(1)
                            )
    BULK COLLECT
    INTO   c.details
    FROM   table_x_case_detail
    WHERE  detail2case = c.case_objid;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- get the reference esn
  IF c.reference_esn IS NULL THEN
    BEGIN
      SELECT value
      INTO   c.reference_esn
      FROM   TABLE(CAST(c.details AS case_detail_tab))
      WHERE  name IN ('CURRENT_ESN','REFERENCE_ESN');
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- get the new esn
  BEGIN
    SELECT value
    INTO   c.new_esn
    FROM   TABLE(CAST(c.details AS case_detail_tab))
    WHERE  name IN ('NEW_ESN');
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  --
  c.response := 'SUCCESS';

  RETURN c;

EXCEPTION
   WHEN OTHERS THEN
     c.response := 'CASE NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN c;
END get;


-- Function used to get the code configuration for a sim
MEMBER FUNCTION ins RETURN case_type IS

  c  case_type := SELF;

BEGIN

  --
  c.response := 'SUCCESS';

  -- return the row type
  RETURN c;

EXCEPTION
   WHEN others THEN
     c.response := 'ERROR INSERTING CASE: ' || SQLERRM;
     RETURN c;
END ins;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save ( i_cs IN OUT case_type ) RETURN VARCHAR2 IS

  c  case_type := case_type ();

BEGIN

  -- insert statement goes here
  BEGIN
    NULL;
   EXCEPTION
    WHEN dup_val_on_index then
      RETURN('DUPLICATE VALUE INSERTING INTO CASE');
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in CASE (' || i_cs.case_objid || ')');

  RETURN('SUCCESS');

EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING CASE RECORD: ' || SQLERRM;
     --
END save;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save RETURN case_type IS

  c  case_type := SELF;

BEGIN


  -- insert goes here
  BEGIN
    NULL;
   EXCEPTION
    WHEN dup_val_on_index then
      c.response := 'DUPLICATE VALUE INSERTING INTO CASE';
      RETURN c;
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in CASE (' || c.case_objid || ')');

  --
  c.response := 'SUCCESS';

  RETURN c;

EXCEPTION
   WHEN OTHERS THEN
     c.response := 'ERROR SAVING CASE RECORD: ' || SQLERRM;
     RETURN c;
     --
END save;

--
END;
/