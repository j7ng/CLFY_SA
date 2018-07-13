CREATE OR REPLACE TYPE sa.task_type AS OBJECT (
  task_objid                   NUMBER         ,
  call_trans_objid             NUMBER         ,
  contact_objid                NUMBER         ,
  min                          VARCHAR2(30)   ,
  esn                          VARCHAR2(30)   ,
  bypass_order_type            VARCHAR2(30)   ,
  case_code                    VARCHAR2(50)   ,
  action_text                  VARCHAR2(20)   ,
  task_id                      VARCHAR2(25)   ,
  s_task_id                    VARCHAR2(25)   ,
  title                        VARCHAR2(80)   ,
  s_title                      VARCHAR2(80)   ,
  notes                        VARCHAR2(4000) ,
  start_date                   DATE           ,
  due_date                     DATE           ,
  comp_date                    DATE           ,
  active                       NUMBER         ,
  arch_ind                     NUMBER         ,
  dev                          NUMBER         ,
  task_sts2gbst_elm            NUMBER         ,
  task_priority2gbst_elm       NUMBER         ,
  type_task2gbst_elm           NUMBER         ,
  sm_task2opportunity          NUMBER         ,
  task_originator2user         NUMBER         ,
  task_owner2user              NUMBER         ,
  task_gen2cls_factory         NUMBER         ,
  task_for2bus_org             NUMBER         ,
  task_state2condition         NUMBER         ,
  task_wip2wipbin              NUMBER         ,
  task_currq2queue             NUMBER         ,
  task_prevq2queue             NUMBER         ,
  sm_task2contract             NUMBER         ,
  task2lead                    NUMBER         ,
  task2lit_req                 NUMBER         ,
  task2task_desc               NUMBER         ,
  update_stamp                 DATE           ,
  account_num                  VARCHAR2(40)   ,
  activation_timeframe         VARCHAR2(40)   ,
  current_method               VARCHAR2(30)   ,
  expedite                     NUMBER         ,
  fax_file                     VARCHAR2(80)   ,
  original_method              VARCHAR2(30)   ,
  queued_flag                  VARCHAR2(10)   ,
  task2site_part               NUMBER         ,
  order_type_objid             NUMBER         ,
  task2x_topp_err_codes        NUMBER         ,
  trans_login                  VARCHAR2(30)   ,
  rate_plan                    VARCHAR2(60)   ,
  ota_type                     VARCHAR2(10)   ,
  mod_level_objid              NUMBER         ,
  site_objid                   NUMBER         ,
  act_name_gbst_objid          NUMBER         ,
  open_actn_itm_gbst_objid     NUMBER         ,
  cr8_actn_itm_gbst_objid      NUMBER         ,
  cr8d_gbst_objid              NUMBER         ,
  task_type_gbst_objid         NUMBER         ,
  task_type_ot_gbst_objid      NUMBER         ,
  task_priority_gbst_objid     NUMBER         ,
  high_gbst_objid              NUMBER         ,
  order_type                   VARCHAR2(50)   ,
  task_type_ot                 VARCHAR2(50)   ,
  db_user                      VARCHAR2(30)   ,
  user_objid                   NUMBER         ,
  wipbin_objid                 NUMBER         ,
  new_esn                      VARCHAR2(20)   ,
  mdbk                         VARCHAR2(80)   ,
  carrier_group_objid          NUMBER         ,
  carrier_mkt_submkt_name      VARCHAR2(30)   ,
  ota_carrier                  VARCHAR2(30)   ,
  technology                   VARCHAR2(20)   ,
  data_speed                   VARCHAR2(50)   ,
  bus_org_id                   VARCHAR2(40)   ,
  bus_org_flow                 VARCHAR2(1)    ,
  trans_profile_objid          NUMBER         ,
  gsm_transmit_method          VARCHAR2(20)   ,
  d_transmit_method            VARCHAR2(20)   ,
  transmit_method              VARCHAR2(20)   ,
  transact_date                DATE           ,
  response                     VARCHAR2(1000) ,
  numeric_value                NUMBER         ,
  varchar2_value               VARCHAR2(2000) ,
  CONSTRUCTOR FUNCTION task_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION task_type ( i_task_objid IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION task_type ( i_call_trans_objid   IN NUMBER  ,
                                   i_contact_objid      IN NUMBER  ,
                                   i_order_type         IN VARCHAR2,
                                   i_bypass_order_type  IN VARCHAR2,
                                   i_case_code          IN VARCHAR2) RETURN SELF AS RESULT,

  MEMBER FUNCTION get_order_type_objid ( i_min              IN VARCHAR2 ,
                                         i_order_type       IN VARCHAR2 ,
                                         i_carrier_objid    IN NUMBER   ,
                                         i_technology       IN VARCHAR2 ) RETURN NUMBER,
 -- CR47564 overloaded constructor function initialize
  CONSTRUCTOR FUNCTION task_type (  i_title                   IN  VARCHAR2,
                                    i_case_code               IN  VARCHAR2,
                                    i_notes                   IN  VARCHAR2,
                                    i_update_stamp            IN  DATE,
                                    i_original_method         IN  VARCHAR2,
                                    i_current_method          IN  VARCHAR2,
                                    i_task_priority2gbst_elm  IN  NUMBER,
                                    i_task_sts2gbst_elm       IN  NUMBER,
                                    i_type_task2gbst_elm      IN  NUMBER,
                                    i_contact_objid           IN  NUMBER,
                                    i_task_wip2wipbin         IN  NUMBER,
                                    i_call_trans_objid        IN  NUMBER,
                                    i_task_originator2user    IN  NUMBER,
                                    i_order_type_objid        IN  NUMBER,
                                    i_ota_type                IN  VARCHAR2) RETURN SELF AS RESULT,

  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_task_objid IN NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION ins RETURN task_type,
  MEMBER FUNCTION upd ( i_task_objid IN NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN task_type,
  MEMBER FUNCTION del ( i_task_objid IN  NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN,
  MEMBER FUNCTION get RETURN task_type,
  MEMBER FUNCTION get ( i_task_objid IN NUMBER ) RETURN task_type,
  MEMBER FUNCTION retrieve RETURN task_type,
  MEMBER FUNCTION save ( i_tt IN OUT task_type ) RETURN VARCHAR2,
  MEMBER FUNCTION dispatch ( i_task_objid IN NUMBER ) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY sa."TASK_TYPE" IS
CONSTRUCTOR FUNCTION task_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

CONSTRUCTOR FUNCTION task_type ( i_task_objid IN NUMBER ) RETURN SELF AS RESULT IS

BEGIN
  --
  IF i_task_objid IS NULL THEN
    SELF.response := 'TASK ID NOT PASSED';
    RETURN;
  END IF;

  -- Query the table
  SELECT task_type (  tt.objid                  , -- task_objid
                      ct.objid                  , -- call_trans_objid
                      tt.task2contact           , -- contact_objid
                      ct.x_min                  , -- MIN
                      ct.x_service_id           , -- ESN
                      NULL                      , -- bypass_order_type
                      NULL                      , -- case_code
                      NULL                      , -- action_text
                      task_id                   ,
                      s_task_id                 ,
                      title                     ,
                      s_title                   ,
                      NULL                      ,
                      start_date                ,
                      due_date                  ,
                      comp_date                 ,
                      active                    ,
                      arch_ind                  ,
                      dev                       ,
                      task_sts2gbst_elm         ,
                      task_priority2gbst_elm    ,
                      type_task2gbst_elm        ,
                      sm_task2opportunity       ,
                      task_originator2user      ,
                      task_owner2user           ,
                      task_gen2cls_factory      ,
                      task_for2bus_org          ,
                      task_state2condition      ,
                      task_wip2wipbin           ,
                      task_currq2queue          ,
                      task_prevq2queue          ,
                      sm_task2contract          ,
                      task2lead                 ,
                      task2lit_req              ,
                      task2task_desc            ,
                      tt.update_stamp           ,
                      x_account_num             ,
                      x_activation_timeframe    ,
                      x_current_method          ,
                      x_expedite                ,
                      x_fax_file                ,
                      x_original_method         ,
                      x_queued_flag             ,
                      x_task2site_part          ,
                      x_task2x_order_type       ,
                      x_task2x_topp_err_codes   ,
                      x_trans_login             ,
                      x_rate_plan               ,
                      tt.x_ota_type             ,
                      NULL                      , -- mod_level_objid
                      NULL                      , -- site_objid
                      NULL                      , -- act_name_gbst_objid
                      NULL                      , -- open_actn_itm_gbst_objid
                      NULL                      , -- cr8_actn_itm_gbst_objid
                      NULL                      , -- cr8d_gbst_objid
                      NULL                      , -- task_type_gbst_objid
                      NULL                      , -- task_type_ot_gbst_objid
                      NULL                      , -- task_priority_gbst_objid
                      NULL                      , -- high_gbst_objid
                      NULL                      , -- order_type
                      NULL                      , -- task_type_ot
                      NULL                      , -- db_user
                      NULL                      , -- user_objid
                      NULL                      , -- wipbin_objid
                      NULL                      , -- new_esn
                      NULL                      , -- mdbk
                      NULL                      , -- carrier_group_objid
                      NULL                      , -- carrier_mkt_submkt_name
                      NULL                      , -- ota_carrier
                      NULL                      , -- technology
                      NULL                      , -- data_speed
                      NULL                      , -- bus_org_id
                      NULL                      , -- bus_org_flow
                      NULL                      , -- trans_profile_objid
                      NULL                      , -- gsm_transmit_method
                      NULL                      , -- d_transmit_method
                      NULL                      , -- transmit_method
                      NULL                      , -- transact_date
                      NULL                      , -- RESPONSE
                      NULL                      , -- NUMERIC_VALUE
                      NULL                        -- VARCHAR2_VALUE
                    )
  INTO   SELF
  FROM   sa.table_task tt,
         sa.table_x_call_trans ct
  WHERE  tt.objid = i_task_objid
  AND    tt.x_task2x_call_trans = ct.objid(+);

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'TASK NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     SELF.task_objid := i_task_objid;
	 --
     RETURN;
END;

CONSTRUCTOR FUNCTION task_type ( i_call_trans_objid   IN NUMBER  ,
                                 i_contact_objid      IN NUMBER  ,
                                 i_order_type         IN VARCHAR2,
                                 i_bypass_order_type  IN VARCHAR2,
                                 i_case_code          IN VARCHAR2 ) RETURN SELF AS RESULT IS

BEGIN

  --
  SELF.call_trans_objid  := i_call_trans_objid;
  SELF.contact_objid     := i_contact_objid;
  SELF.order_type        := i_order_type;
  SELF.bypass_order_type := i_bypass_order_type;
  SELF.case_code         := i_case_code;
  --

  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.response     := 'ERROR INITIALIZING TASK: ' || SUBSTR(SQLERRM,1,100);
     SELF.call_trans_objid  := i_call_trans_objid;
     SELF.contact_objid     := i_contact_objid;
     SELF.order_type        := i_order_type;
     SELF.bypass_order_type := i_bypass_order_type;
     SELF.case_code         := i_case_code;
	 --
     RETURN;
END;

-- CR47564 overloaded constructor function initialize
CONSTRUCTOR FUNCTION task_type (  i_title                   IN  VARCHAR2,
                                  i_case_code               IN  VARCHAR2,
                                  i_notes                   IN  VARCHAR2,
                                  i_update_stamp            IN  DATE,
                                  i_original_method         IN  VARCHAR2,
                                  i_current_method          IN  VARCHAR2,
                                  i_task_priority2gbst_elm  IN  NUMBER,
                                  i_task_sts2gbst_elm       IN  NUMBER,
                                  i_type_task2gbst_elm      IN  NUMBER,
                                  i_contact_objid           IN  NUMBER,
                                  i_task_wip2wipbin         IN  NUMBER,
                                  i_call_trans_objid        IN  NUMBER,
                                  i_task_originator2user    IN  NUMBER,
                                  i_order_type_objid        IN  NUMBER,
                                  i_ota_type                IN  VARCHAR2) RETURN SELF AS RESULT IS
--
BEGIN
  --
  SELF.title                      :=	  i_title                  ;
  SELF.case_code                  :=    i_case_code              ;
  SELF.notes                      :=    i_notes                  ;
  SELF.update_stamp               :=    i_update_stamp           ;
  SELF.original_method            :=    i_original_method        ;
  SELF.current_method             :=    i_current_method         ;
  SELF.task_priority2gbst_elm     :=    i_task_priority2gbst_elm ;
  SELF.task_sts2gbst_elm          :=    i_task_sts2gbst_elm      ;
  SELF.type_task2gbst_elm         :=    i_type_task2gbst_elm     ;
  SELF.contact_objid              :=    i_contact_objid          ;
  SELF.task_wip2wipbin            :=    i_task_wip2wipbin        ;
  SELF.call_trans_objid           :=    i_call_trans_objid       ;
  SELF.task_originator2user       :=    i_task_originator2user   ;
  SELF.order_type_objid           :=    i_order_type_objid       ;
  SELF.ota_type                   :=    i_ota_type               ;
  --
  SELF.response := 'SUCCESS';
  --
  RETURN;
  --
 EXCEPTION
   WHEN OTHERS THEN
      SELF.response     := 'ERROR INITIALIZING TASK: ' || SUBSTR(SQLERRM,1,100);
      SELF.title                      :=	  i_title                  ;
      SELF.case_code                  :=    i_case_code              ;
      SELF.notes                      :=    i_notes                  ;
      SELF.update_stamp               :=    i_update_stamp           ;
      SELF.original_method            :=    i_original_method        ;
      SELF.current_method             :=    i_current_method         ;
      SELF.task_priority2gbst_elm     :=    i_task_priority2gbst_elm ;
      SELF.task_sts2gbst_elm          :=    i_task_sts2gbst_elm      ;
      SELF.type_task2gbst_elm         :=    i_type_task2gbst_elm     ;
      SELF.contact_objid              :=    i_contact_objid          ;
      SELF.task_wip2wipbin            :=    i_task_wip2wipbin        ;
      SELF.call_trans_objid           :=    i_call_trans_objid       ;
      SELF.task_originator2user       :=    i_task_originator2user   ;
      SELF.order_type_objid           :=    i_order_type_objid       ;
      SELF.ota_type                   :=    i_ota_type               ;
    --
     RETURN;
END;
--

MEMBER FUNCTION get_order_type_objid ( i_min              IN VARCHAR2 ,
                                       i_order_type       IN VARCHAR2 ,
                                       i_carrier_objid    IN NUMBER   ,
                                       i_technology       IN VARCHAR2 ) RETURN NUMBER IS

  tt task_type := task_type();
  l_order_type    VARCHAR2(30);

  CURSOR o_type_curs ( c_npa           IN VARCHAR2 ,
                       c_nxx           IN VARCHAR2 ,
                       c_order_type    IN VARCHAR2 ,
                       c_carrier_objid IN NUMBER ) IS
    SELECT /*+ index ( ot IND_ORDER_TYPE3 ) */
           ot.*
    FROM   table_x_order_type ot ,
           table_x_carrier c
    WHERE  ot.x_order_type2x_carrier = c.objid
    AND    NVL(ot.x_npa ,'-1') = c_npa
    AND    NVL(ot.x_nxx ,'-1') = c_nxx
    AND    ot.x_order_type = c_order_type
    AND    c.objid = c_carrier_objid;

  o_type_rec o_type_curs%ROWTYPE;

  CURSOR rules_curs ( c_carrier_objid IN NUMBER ,c_tech IN VARCHAR2 ) IS
    SELECT cr.*
    FROM   table_x_carrier_rules cr ,
           table_x_carrier c
    WHERE  cr.objid = DECODE(c_tech ,'GSM' ,c.carrier2rules_gsm ,'TDMA' ,c.carrier2rules_tdma ,'CDMA' ,c.carrier2rules_cdma ,c.carrier2rules)
    AND    c.objid    = c_carrier_objid;
  rules_rec rules_curs%ROWTYPE;
  cnt NUMBER := 0;
BEGIN
  --
  IF i_order_type = 'Return' THEN
    l_order_type := 'Deactivation';
  ELSE
    l_order_type := i_order_type;
  END IF;

  --
  OPEN o_type_curs ( SUBSTR(i_min ,1 ,3) ,SUBSTR(i_min ,4 ,3) , l_order_type ,i_carrier_objid);
  FETCH o_type_curs INTO o_type_rec;
  IF o_type_curs%FOUND THEN
    CLOSE o_type_curs;
	-- Return the order type objid
    RETURN o_type_rec.objid;
  END IF;
  CLOSE o_type_curs;

  --
  OPEN o_type_curs ('-1', '-1', l_order_type, i_carrier_objid);
  FETCH o_type_curs INTO o_type_rec;
  IF o_type_curs%NOTFOUND THEN
    o_type_rec.objid := 0;
    --
  ELSE
    OPEN rules_curs (i_carrier_objid, i_technology);
    FETCH rules_curs INTO rules_rec;
    IF rules_curs%FOUND THEN
      --
      IF rules_rec.x_npa_nxx_flag > 0 THEN
        --p_order_type_objid := o_type_rec.objid;
		NULL;
      ELSE
        o_type_rec.objid := 0;
      END IF;
    ELSE
      --
      o_type_rec.objid := 0;
    END IF;
    CLOSE rules_curs;
    --
  END IF;
  CLOSE o_type_curs;

  -- Return order type objid
  RETURN o_type_rec.objid;

END get_order_type_objid;

MEMBER FUNCTION exist RETURN BOOLEAN IS

 tt  task_type := task_type ( i_task_objid => SELF.task_objid );

BEGIN
 IF tt.esn IS NOT NULL THEN
    RETURN TRUE;
 ELSE
    RETURN FALSE;
 END IF;
END exist;

MEMBER FUNCTION exist ( i_task_objid IN NUMBER) RETURN BOOLEAN IS

 tt  task_type := task_type ( i_task_objid => i_task_objid );

BEGIN
 IF tt.task_objid IS NOT NULL THEN
    RETURN TRUE;
 ELSE
    RETURN FALSE;
 END IF;
END exist;

-- Procedure to add the
MEMBER FUNCTION ins RETURN task_type IS

  tt  task_type := SELF;
  t   task_type := SELF;

BEGIN
  --
  IF tt.call_trans_objid IS NULL THEN
    tt.response := 'NO CALL TRANS OBJID ATTRIBUTE PASSED';
    RETURN tt;
  END IF;

  -- Retrieve the call trans data
  t := tt.retrieve;

  -- Save transaction only when retrieve came back successful
  IF t.response LIKE '%SUCCESS%' THEN
    -- Raw insert into table
    t.response := t.response || '|' || save(t) ;
	--
	t.response := CASE t.response WHEN 'SUCCESS|SUCCESS' THEN 'SUCCESS' ELSE t.response END;

  ELSE
    -- Return the error message in the c.response column
    t.response := t.response || '|TASK ROW WAS NOT CREATED';
  END IF;

  RETURN t;

 EXCEPTION
   WHEN others THEN
     tt.response  := 'ERROR INSERTING TASK RECORD: ' || SUBSTR(SQLERRM,1,100);
     --
     RETURN tt;
END ins;

-- Function to expire a subscriber
MEMBER FUNCTION upd ( i_task_objid IN NUMBER) RETURN BOOLEAN IS
BEGIN
  RETURN TRUE;
END upd;

-- Function to update a subscriber
MEMBER FUNCTION upd RETURN task_type IS

  tt  task_type := SELF;
  t   task_type := task_type ();
BEGIN
  --
  IF tt.task_objid IS NULL THEN
    tt.response := 'TASK OBJID CANNOT BE EMPTY';
    RETURN tt;
  END IF;

  IF ( 1 = 1 --tt.total_units IS NOT NULL
	 )
  THEN
    --
    UPDATE table_task
    SET    update_stamp   = SYSDATE
    WHERE  objid = tt.task_objid;
  END IF;

  t := task_type ( tt.task_objid );

  tt.response := 'SUCCESS';
  RETURN t;

 EXCEPTION
   WHEN others THEN
    tt.response := 'ERROR UPDATING TASK: ' || SUBSTR(SQLERRM,1,100);
    t.response := 'ERROR UPDATING TASK: ' || SUBSTR(SQLERRM,1,100);
    RETURN t;
END upd;

MEMBER FUNCTION del RETURN BOOLEAN IS

  tt task_type := task_type ( SELF.task_objid );

begin
   RETURN tt.del ( SELF.task_objid);
end;

MEMBER FUNCTION del ( i_task_objid IN NUMBER) RETURN BOOLEAN IS

  -- Find the task row
  tt task_type := task_type ( i_task_objid => i_task_objid);

BEGIN
  --DBMS_OUTPUT.PUT_LINE('START DELETING');

  -- If the TASK row was not found successfully
  IF tt.response != 'SUCCESS' THEN
    --DBMS_OUTPUT.PUT_LINE('tt.response => ' || tt.response);
    tt.response := 'UNABLE TO FIND TASK: ' || tt.response;
    RETURN FALSE;
  END IF;

  -- Delete task
  DELETE table_task
  WHERE  objid = i_task_objid;

  tt.response := 'SUCCESS';

  --DBMS_OUTPUT.PUT_LINE('END DELETING');

  RETURN TRUE;
 EXCEPTION
   WHEN others THEN
     tt.response := 'ERROR DELETING TASK: ' || SUBSTR(SQLERRM,1,100);
     RETURN FALSE;
END del;

MEMBER FUNCTION get RETURN task_type is

  tt task_type := task_type ( SELF.task_objid );

BEGIN
  RETURN tt;
END;

MEMBER FUNCTION get ( i_task_objid IN NUMBER ) RETURN task_type IS

  tt  task_type := SELF;
  t   task_type;

BEGIN
  RETURN tt;
END get;

-- Procedure to get all the values in order to create the task
MEMBER FUNCTION retrieve RETURN task_type IS

  tt  task_type := SELF;
  ct  call_trans_type := call_trans_type ( i_call_trans_objid => tt.call_trans_objid );

BEGIN

  -- Reset response column to blank
  tt.response := NULL;

  --
  IF tt.call_trans_objid IS NULL THEN
    tt.response := 'NO CALL TRANS PASSED';
    RETURN tt;
  END IF;

  -- Verify call trans
  IF ct.response NOT LIKE '%SUCCESS%' THEN
    tt.response := ct.response;
    RETURN tt;
  END IF;

  --
  BEGIN
    SELECT sp.site_part2site,
           sp.x_service_id,
		   sp.x_min,
           ( SELECT pi.n_part_inst2part_mod
             FROM   table_part_inst pi
             WHERE  pi.part_serial_no = sp.x_service_id
           ) n_part_inst2part_mod
    INTO   tt.site_objid,
           tt.esn,
           tt.min,
           tt.mod_level_objid
    FROM   table_site_part sp
    WHERE  objid = ct.call_trans2site_part;
   EXCEPTION
     WHEN others THEN
       tt.response := 'SITE PART NOT FOUND IN SITE PART TABLE';
       RETURN tt;
  END;
  --OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  --FETCH site_part_curs INTO site_part_rec;
  --IF site_part_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE site_part_curs;
  --  RETURN;
  --END IF;
  --CLOSE site_part_curs;

  BEGIN
    SELECT 1
    INTO   tt.numeric_value
    FROM   table_site
    WHERE  objid = tt.site_objid;
   EXCEPTION
     WHEN others THEN
       tt.response := 'SITE NOT FOUND IN SITE TABLE';
       RETURN tt;
  END;
  --OPEN site_curs(site_part_rec.site_part2site);
  --FETCH site_curs INTO site_rec;
  --IF site_curs%NOTFOUND THEN
  --END IF;
  --CLOSE site_curs;

  -- Verify ESN in part inst
  BEGIN
    SELECT n_part_inst2part_mod
    INTO   tt.mod_level_objid
    FROM   table_part_inst
    WHERE  part_serial_no = tt.esn;
   EXCEPTION
     WHEN others THEN
       tt.response := 'ESN NOT FOUND IN PART INST TABLE';
       RETURN tt;
  END;
  --OPEN c_get_part_inst(site_part_rec.x_service_id);
  --FETCH c_get_part_inst INTO r_get_part_inst;
  --IF c_get_part_inst%notfound THEN
  --    p_status_code := 3;
  --    CLOSE c_get_part_inst;
  --    RETURN;
  --END IF;
  --CLOSE c_get_part_inst;


  BEGIN
    SELECT pn.x_technology,
           NVL( ( SELECT TO_NUMBER(data_speed)
                  FROM   sa.pcpv_mv pcpv --CR47564 WFM changed to use pcpv_mv from pcpv view to improve performance
                  WHERE  1 = 1
                  AND    pc_objid = pn.part_num2part_class
                ), NVL(pn.x_data_capable, 0)
              ) data_speed,
           bo.org_id ,
           bo.org_flow
    INTO   tt.technology,
	       tt.data_speed,
		   tt.bus_org_id,
		   tt.bus_org_flow
    FROM   table_part_num pn,
           table_mod_level ml,
           table_bus_org bo
    WHERE  1 = 1
    AND    ml.objid = tt.mod_level_objid
    AND    pn.objid = ml.part_info2part_num
    AND    pn.part_num2bus_org = bo.objid;
   EXCEPTION
     WHEN others THEN
       tt.response := 'MOD LEVEL NOT FOUND IN MOD LEVEL TABLE (' || tt.mod_level_objid || '): ERROR: ' || SQLERRM;
       RETURN tt;
  END;
  --
  --OPEN part_num_curs(r_get_part_inst.n_part_inst2part_mod);
  --FETCH part_num_curs INTO part_num_rec;
  --IF part_num_curs%NOTFOUND THEN
  --    p_status_code := 3;
  --    CLOSE part_num_curs;
  --    RETURN;
  --END IF;
  --CLOSE part_num_curs;

  BEGIN
    SELECT 1
    INTO   tt.numeric_value
	FROM   table_user
    WHERE  objid = ct.call_trans2user;
   EXCEPTION
     WHEN others THEN
       tt.response := 'USER NOT FOUND IN USER TABLE';
       RETURN tt;
  END;
  --
  --OPEN user_curs(call_trans_rec.x_call_trans2user);
  --FETCH user_curs INTO user_rec;
  --IF user_curs%NOTFOUND THEN
  --    p_status_code := 3;
  --    CLOSE user_curs;
  --    RETURN;
  --END IF;
  --CLOSE user_curs;

  --
  BEGIN
    SELECT objid
	INTO   tt.act_name_gbst_objid
    FROM   table_gbst_lst
    WHERE  title LIKE 'Activity Name';
   EXCEPTION
     WHEN others THEN
       tt.response := 'GBST LIST (ACTIVITY NAME) NOT FOUND IN GBST_LST TABLE';
       RETURN tt;
  END;
  --
  --OPEN gbst_lst_curs();
  --FETCH gbst_lst_curs INTO gbst_lst4_rec;
  --IF gbst_lst_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE gbst_lst_curs;
  --  RETURN;
  --END IF;
  --CLOSE gbst_lst_curs;
  --

  --
  BEGIN
    SELECT objid
	INTO   tt.cr8_actn_itm_gbst_objid
    FROM   table_gbst_elm
    WHERE  gbst_elm2gbst_lst = tt.act_name_gbst_objid
    AND    title LIKE 'Create Action Item';
   EXCEPTION
     WHEN others THEN
       tt.response := 'GBST ELM (CREATE ACTION ITEM) NOT FOUND IN GBST_ELM TABLE';
       RETURN tt;
  END;
  --OPEN gbst_elm_curs(gbst_lst4_rec.objid ,'Create Action Item');
  --FETCH gbst_elm_curs INTO gbst_elm4_rec;
  --IF gbst_elm_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE gbst_elm_curs;
  --  RETURN;
  --END IF;
  --CLOSE gbst_elm_curs;
  --

  --
  BEGIN
    SELECT objid
	INTO   tt.open_actn_itm_gbst_objid
    FROM   table_gbst_lst
    WHERE  title LIKE 'Open Action Item';
   EXCEPTION
     WHEN others THEN
       tt.response := 'GBST LIST (OPEN ACTION ITEM) NOT FOUND IN GBST_LST TABLE';
       RETURN tt;
  END;
  --OPEN gbst_lst_curs('Open Action Item');
  --FETCH gbst_lst_curs INTO gbst_lst3_rec;
  --IF gbst_lst_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE gbst_lst_curs;
  --  RETURN;
  --END IF;
  --CLOSE gbst_lst_curs;
  --

  --
  BEGIN
    SELECT objid
	INTO   tt.cr8d_gbst_objid
    FROM   table_gbst_elm
    WHERE  gbst_elm2gbst_lst = tt.open_actn_itm_gbst_objid
    AND    title LIKE 'Created';
   EXCEPTION
     WHEN others THEN
       tt.response := 'GBST ELM (CREATED) NOT FOUND IN GBST_ELM TABLE';
       RETURN tt;
  END;
  --OPEN gbst_elm_curs(gbst_lst3_rec.objid ,'Created');
  --FETCH gbst_elm_curs INTO gbst_elm3_rec;
  --IF gbst_elm_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE gbst_elm_curs;
  --  RETURN;
  --END IF;
  --CLOSE gbst_elm_curs;
  --

  --
  BEGIN
    SELECT objid
	INTO   tt.task_type_gbst_objid
    FROM   table_gbst_lst
    WHERE  title LIKE 'Task Type';
   EXCEPTION
     WHEN too_many_rows THEN
       tt.response := 'MULTIPLE GBST LIST (TASK TYPE) FOUND IN GBST_LST TABLE';
       RETURN tt;
     WHEN others THEN
       tt.response := 'GBST LIST (TASK TYPE) NOT FOUND IN GBST_LST TABLE';
       RETURN tt;
  END;
  --OPEN gbst_lst_curs('Task Type');
  --FETCH gbst_lst_curs INTO gbst_lst2_rec;
  --IF gbst_lst_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE gbst_lst_curs;
  --  RETURN;
  --END IF;
  --CLOSE gbst_lst_curs;
  --

  -- Assign task type order type (task_type_ot)
  tt.task_type_ot := CASE
                       WHEN tt.order_type = 'Return'                      THEN 'Deactivation'
                       WHEN tt.order_type IN ('SIMC' ,'EC' ,'SI')         THEN 'SIM Change'
                       WHEN tt.order_type = 'Act Payment Partial Buckets' THEN 'Activation Payment'
                       WHEN tt.order_type = 'Partial Buckets'             THEN 'Credit'
                       ELSE tt.order_type
					 END;

  dbms_output.put_line('tt.task_type_gbst_objid => ' || tt.task_type_gbst_objid);
  dbms_output.put_line('tt.task_type_ot         => ' || tt.task_type_ot);

  --
  BEGIN
    SELECT objid
    INTO   tt.task_type_ot_gbst_objid
    FROM   table_gbst_elm
    WHERE  gbst_elm2gbst_lst = tt.task_type_gbst_objid
    AND    title LIKE tt.task_type_ot;
   EXCEPTION
     WHEN too_many_rows THEN
       tt.response := 'MULTIPLE GBST ELM (TASK TYPE ORDER TYPE) FOUND IN GBST_ELM TABLE ( '|| tt.task_type_gbst_objid || ')';
       RETURN tt;
     WHEN others THEN
       tt.response := 'GBST ELM (TASK TYPE ORDER TYPE) NOT FOUND IN GBST_ELM TABLE ( '|| tt.task_type_gbst_objid || ')';
       RETURN tt;
  END;
  --OPEN gbst_elm_curs(gbst_lst2_rec.objid ,l_tasktype_ot);
  --FETCH gbst_elm_curs INTO gbst_elm2_rec;
  --IF gbst_elm_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE gbst_elm_curs;
  --  RETURN;
  --END IF;
  --CLOSE gbst_elm_curs;

  --
  BEGIN
    SELECT objid
	INTO   tt.task_priority_gbst_objid
    FROM   table_gbst_lst
    WHERE  title LIKE 'Task Priority';
   EXCEPTION
     WHEN others THEN
       tt.response := 'GBST LIST (TASK PRIORITY) NOT FOUND IN GBST_LST TABLE';
       RETURN tt;
  END;
  --OPEN gbst_lst_curs('Task Priority');
  --FETCH gbst_lst_curs INTO gbst_lst1_rec;
  --IF gbst_lst_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE gbst_lst_curs;
  --  RETURN;
  --END IF;
  --CLOSE gbst_lst_curs;

  --
  BEGIN
    SELECT objid
	INTO   tt.high_gbst_objid
    FROM   table_gbst_elm
    WHERE  gbst_elm2gbst_lst = tt.task_priority_gbst_objid
    AND    title LIKE 'High';
   EXCEPTION
     WHEN others THEN
       tt.response := 'GBST ELM (HIGH) NOT FOUND IN GBST_ELM TABLE';
       RETURN tt;
  END;
  --OPEN gbst_elm_curs(gbst_lst1_rec.objid ,'High');
  --FETCH gbst_elm_curs INTO gbst_elm1_rec;
  --IF gbst_elm_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE gbst_elm_curs;
  --  RETURN;
  --END IF;
  --CLOSE gbst_elm_curs;

  -- Set db user
  BEGIN
    SELECT USER
    INTO   tt.db_user
    FROM   dual;
   EXCEPTION
     WHEN others THEN
       tt.db_user := 'appsrv';
  END;
  --OPEN current_user_curs;
  --FETCH current_user_curs INTO current_user_rec;
  --IF current_user_curs%NOTFOUND THEN
  --  current_user_rec.user := 'appsrv';
  --END IF;
  --CLOSE current_user_curs;

  -- Set db user
  BEGIN
    SELECT objid,
           objid,
           objid
	  INTO   tt.user_objid,
           tt.task_originator2user,
           tt.task_owner2user
    FROM   table_user
    WHERE  s_login_name = UPPER(tt.db_user);
   EXCEPTION
     WHEN others THEN
        BEGIN
          SELECT objid,
                 objid,
                 objid
	          INTO tt.user_objid,
                 tt.task_originator2user,
                 tt.task_owner2user
            FROM table_user
           WHERE UPPER(s_login_name) = 'APPSRV';
        EXCEPTION
          WHEN others THEN
            tt.response := 'USER LOGIN NOT FOUND IN USER TABLE';
            RETURN tt;
        END;
  END;
  --OPEN user2_curs(current_user_rec.user);
  --FETCH user2_curs INTO user2_rec;
  --IF user2_curs%NOTFOUND THEN
  --  CLOSE user2_curs;
  --  OPEN user2_curs('appsrv');
  --  FETCH user2_curs INTO user2_rec;
  --  IF user2_curs%NOTFOUND THEN
  --    p_status_code := 3;
  --    CLOSE user2_curs;
  --    RETURN;
  --  END IF;
  --  CLOSE user2_curs;
  --ELSE
  --  CLOSE user2_curs;
  --END IF;

  BEGIN
    SELECT 1
    INTO   tt.numeric_value
    FROM   table_wipbin
    WHERE  wipbin_owner2user = tt.user_objid;
   EXCEPTION
     WHEN too_many_rows THEN
       NULL;
     WHEN others THEN
       tt.response := 'USER NOT FOUND IN WIPBIN TABLE ('|| tt.user_objid || ')';
       RETURN tt;
  END;
  --OPEN wipbin_curs(user2_rec.objid);
  --FETCH wipbin_curs INTO wipbin_rec;
  --IF wipbin_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE wipbin_curs;
  --  RETURN;
  --END IF;
  --CLOSE wipbin_curs;

  BEGIN
    SELECT 1
    INTO   tt.numeric_value
    FROM   table_employee
    WHERE  employee2user = tt.user_objid;
   EXCEPTION
     WHEN others THEN
       tt.response := 'USER NOT FOUND IN EMPLOYEE TABLE';
       RETURN tt;
  END;
  --OPEN employee_curs(user2_rec.objid);
  --FETCH employee_curs INTO employee_rec;
  --IF employee_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE employee_curs;
  --  RETURN;
  --END IF;
  --CLOSE employee_curs;


  BEGIN
    SELECT x_new_esn,
           mdbk
	INTO   tt.new_esn,
	       tt.mdbk
    FROM   table_contact
    WHERE  objid = tt.contact_objid;
   EXCEPTION
     WHEN others THEN
       tt.response := 'CONTACT NOT FOUND IN CONTACT TABLE';
       RETURN tt;
  END;
  --OPEN contact_curs(p_contact_objid);
  --FETCH contact_curs INTO contact_rec;
  --IF contact_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE contact_curs;
  --  RETURN;
  --END IF;
  --CLOSE contact_curs;

  BEGIN
    SELECT carrier2carrier_group, x_mkt_submkt_name
	INTO   tt.carrier_group_objid, tt.carrier_mkt_submkt_name
    FROM   table_x_carrier
    WHERE  objid = ct.call_trans2carrier;
   EXCEPTION
     WHEN others THEN
       tt.response := 'CARRIER NOT FOUND IN CARRIER TABLE';
       RETURN tt;
  END;
  --OPEN carrier_curs(ct.x_call_trans2carrier);
  --FETCH carrier_curs INTO carrier_rec;
  --IF carrier_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE carrier_curs;
  --  RETURN;
  --END IF;
  --CLOSE carrier_curs;

  BEGIN
    SELECT 1
	INTO   tt.numeric_value
    FROM   table_x_carrier_group
    WHERE  objid = tt.carrier_group_objid;
   EXCEPTION
     WHEN others THEN
       tt.response := 'CARRIER GROUP NOT FOUND IN CARRIER GROUP TABLE';
       RETURN tt;
  END;
  --OPEN carrier_group_curs(carrier_rec.carrier2carrier_group);
  --FETCH carrier_group_curs INTO carrier_group_rec;
  --IF carrier_group_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE carrier_group_curs;
  --  RETURN;
  --END IF;
  --CLOSE carrier_group_curs;

  --
  IF tt.new_esn = ct.esn OR tt.order_type = 'Suspend' THEN
  --
    IF tt.mdbk = 'UPGRADE' THEN
      --
      BEGIN
        SELECT objid
        INTO   tt.high_gbst_objid
        FROM   table_gbst_elm
        WHERE  gbst_elm2gbst_lst = tt.task_priority_gbst_objid
        AND    title LIKE 'High - Upgrade';
       EXCEPTION
         WHEN others THEN
           tt.response := 'GBST ELM (HIGH - UPGRADE) NOT FOUND IN GBST_ELM TABLE';
           RETURN tt;
      END;
      --OPEN gbst_elm_curs(gbst_lst1_rec.objid ,'High - Upgrade');
      --FETCH gbst_elm_curs INTO gbst_elm1_rec;
      --IF gbst_elm_curs%NOTFOUND THEN
      --  p_status_code := 3;
      --  CLOSE gbst_elm_curs;
      --  RETURN;
      --END IF;
      --CLOSE gbst_elm_curs;
    END IF;
    --
    IF tt.order_type IN ( 'Activation', 'ESN Change' ) THEN
      -- This should be moved to a contact type in the future
      UPDATE table_contact
      SET    x_new_esn = NULL,
             mdbk      = NULL
      WHERE  objid = tt.contact_objid;
      --
    END IF;
  END IF;
  --
  tt.ota_type := NULL;
  --
  IF ct.ota_type = ota_util_pkg.ota_activation THEN
    --
    BEGIN
      SELECT p.x_ota_carrier
      INTO   tt.ota_carrier
      FROM   table_x_parent p ,
             table_x_carrier_group g ,
             table_x_carrier c
      WHERE  1 = 1
      AND    c.objid = ct.call_trans2carrier
      AND    g.objid = c.carrier2carrier_group
      AND    p.objid = g.x_carrier_group2x_parent;
     EXCEPTION
       WHEN others THEN
         tt.response := 'CARRIER PARENT NOT FOUND';
         RETURN tt;
    END;
    IF UPPER(tt.ota_carrier) = 'Y' THEN
      tt.ota_type := ota_util_pkg.ota_queued;
    ELSE
      tt.ota_type := SUBSTR('1NL' || ct.call_trans2carrier ,1 ,10);
    END IF;
    --
    --OPEN parent_curs_local(carrier_rec.objid);
    --FETCH parent_curs_local INTO parent_rec;
    --IF parent_curs_local%notfound THEN
    --  p_status_code := 3;
    --  CLOSE parent_curs_local;
    --  RETURN;
    --ELSE
    --  IF UPPER(parent_rec.x_ota_carrier) = 'Y' THEN
    --    c_ota_type                      := ota_util_pkg.ota_queued;
    --  ELSE
    --    c_ota_type := SUBSTR('1NL' || carrier_rec.objid ,1 ,10);
    --  END IF;
    --END IF;
    --CLOSE parent_curs_local;
  END IF;
  --
  --igate.sp_get_ordertype(site_part_rec.x_min , tt.order_type ,carrier_rec.objid ,part_num_rec.x_technology , l_order_type_objid);

  dbms_output.put_line(' tt.min                  => ' || tt.min );
  dbms_output.put_line(' tt.order_type           => ' || tt.order_type );
  dbms_output.put_line(' ct.call_trans2carrier   => ' || ct.call_trans2carrier );
  dbms_output.put_line(' tt.technology           => ' || tt.technology );

  tt.order_type_objid := get_order_type_objid ( i_min           => tt.min ,
                                                i_order_type    => tt.order_type ,
                                                i_carrier_objid => ct.call_trans2carrier ,
                                                i_technology    => tt.technology );

  dbms_output.put_line(' tt.order_type_objid     => ' || tt.order_type_objid);

  --
  IF tt.order_type_objid IS NULL AND NVL(tt.bypass_order_type,0) = 1 THEN
    tt.title := ' FAILED ' || UPPER(tt.order_type) || ' FOR ' || UPPER(tt.carrier_mkt_submkt_name);
  ELSIF tt.order_type_objid IS NULL THEN
    --
    tt.response := 'ORDER TYPE OBJID IS NULL'; -- p_status_code := 3;
    RETURN tt;
  END IF;
  --
  BEGIN
	SELECT x_order_type2x_trans_profile
    INTO   tt.trans_profile_objid
    FROM   table_x_order_type
    WHERE  objid = tt.order_type_objid;
   EXCEPTION
     WHEN others THEN
       tt.response := 'ORDER TYPE OBJID NOT FOUND ('|| tt.order_type_objid ||')'; -- p_status_code := 3;
	   RETURN tt;
  END;
  --
  IF NVL(tt.bypass_order_type,0) = 1 THEN
    tt.title := ' FAILED ' || UPPER(tt.order_type) || ' FOR ' || UPPER(tt.carrier_mkt_submkt_name);
  END IF;

  --OPEN order_type_curs(tt.order_type_objid);
  --FETCH order_type_curs INTO order_type_rec;
  --IF order_type_curs%NOTFOUND AND NVL(p_bypass_order_type,0) = 1 THEN
  --  titlestr := ' FAILED ' || UPPER(p_order_type) || ' FOR ' || UPPER(carrier_rec.x_mkt_submkt_name);
  --ELSIF order_type_curs%NOTFOUND THEN
  --  p_status_code := 3;
  --  CLOSE order_type_curs;
  --  RETURN;
  --END IF;
  --CLOSE order_type_curs;
  --

  BEGIN
	SELECT x_gsm_transmit_method, x_d_transmit_method, x_transmit_method
    INTO   tt.gsm_transmit_method, tt.d_transmit_method, tt.transmit_method
    FROM   table_x_trans_profile
    WHERE  objid = tt.trans_profile_objid;
   EXCEPTION
     WHEN others THEN
	   IF NVL(tt.bypass_order_type,0) = 1 THEN
         tt.title := ' FAILED ' || UPPER(tt.order_type) || ' FOR ' || UPPER(tt.carrier_mkt_submkt_name);
         IF tt.order_type IN ('Return', 'Deactivation' ,'Suspend') AND NVL(tt.bypass_order_type, 0 ) = 0
		 THEN
           tt.response := 'TRANS PROFILE NOT FOUND FOR ORDER_TYPE IN (Return, Deactivation ,Suspend)'; -- p_status_code := 2;
   	       RETURN tt;
         ELSE
           tt.response := 'TRANS PROFILE NOT FOUND FOR OTHER ORDER TYPES'; -- p_status_code := 1;
   	       RETURN tt;
         END IF;
         --
	   END IF;
       tt.response := 'TRANS PROFILE NOT FOUND'; -- p_status_code := 2;
	   RETURN tt;
  END;

  --OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
  --FETCH trans_profile_curs INTO trans_profile_rec;
  --CLOSE trans_profile_curs;

  IF tt.gsm_transmit_method IS NOT NULL THEN
    tt.original_method := tt.gsm_transmit_method;
    tt.current_method := tt.gsm_transmit_method;
  ELSIF tt.d_transmit_method IS NOT NULL THEN
    tt.original_method := tt.d_transmit_method;
    tt.current_method := tt.d_transmit_method;
  ELSIF tt.transmit_method   IS NOT NULL THEN
    tt.original_method := tt.transmit_method;
    tt.current_method := tt.transmit_method;
  ELSIF NVL(tt.bypass_order_type,0) = 1 THEN
    tt.original_method := NULL;
    tt.current_method := NULL;
  ELSE
    tt.response := 'INVALID METHODS'; -- p_status_code := 1;
    RETURN tt;
  END IF;

  --
  IF tt.title IS NULL THEN
    tt.title := UPPER(tt.carrier_mkt_submkt_name) || ' ' || UPPER(tt.order_type);
  END IF;

  tt.notes := ':  ********** New Action Item *********** :' || CHR(10) || CHR(13) || ' ActionTitle:  ' || tt.title || CHR(10) || CHR(13) || 'Originator: ' || USER || CHR(10) || CHR(13) || ' Create Time: ' || SYSDATE;

  -- Set transaction date
  tt.transact_date := SYSDATE;

  -- Set successful response
  tt.response  := CASE WHEN tt.response IS NULL THEN 'SUCCESS' ELSE tt.response || '|SUCCESS' END;

  RETURN tt;

 EXCEPTION
    WHEN others THEN
      tt.response  := tt.response || '|ERROR RETRIEVING TASK RECORD: ' || SUBSTR(SQLERRM,1,100);
      --
      RETURN tt;
END retrieve;

MEMBER FUNCTION save ( i_tt IN OUT task_type ) RETURN VARCHAR2 IS


BEGIN
  -- Validate empty attribute
  IF i_tt.call_trans_objid IS NULL THEN
    RETURN 'CALL TRANS OBJID ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Assign timestamp attributes
  i_tt.update_stamp := SYSDATE;

  --
  BEGIN
    INSERT
    INTO   sa.table_condition
           (
             objid ,
             condition ,
             wipbin_time ,
             title ,
             s_title ,
             sequence_num
           )
    VALUES
    ( sa.sequ_condition.NEXTVAL ,
      268435456 ,
      SYSDATE ,
      'Not Started' ,
      'NOT STARTED' ,
      0
    )
    RETURNING objid
	INTO      i_tt.task_state2condition;
  END;
  --

  BEGIN
    SELECT sa.sequ_action_item_id.NEXTVAL
    INTO   i_tt.task_id
	FROM   dual;
  END;

  --
  INSERT
  INTO   table_task
         ( objid ,
           task_id ,
           s_task_id ,
           title ,
           s_title ,
           notes ,
           start_date ,
           update_stamp,
           x_original_method ,
           x_current_method ,
           x_queued_flag ,
           task_priority2gbst_elm ,
           task_sts2gbst_elm ,
           type_task2gbst_elm ,
           task2contact ,
           task_wip2wipbin ,
           x_task2x_call_trans ,
           task_state2condition ,
           task_originator2user ,
           task_owner2user ,
           x_task2x_order_type ,
           active ,
           x_ota_type
         )
  VALUES
  ( sequ_task.NEXTVAL ,
    i_tt.task_id ,
    i_tt.task_id ,
    i_tt.title || DECODE(i_tt.case_code ,100 ,':CASE' ,NULL) ,
    UPPER(i_tt.title || DECODE(i_tt.case_code ,100 ,':CASE' ,NULL)) ,
    i_tt.notes ,
    SYSDATE ,
    i_tt.update_stamp,
    i_tt.original_method ,
    i_tt.current_method ,
    '1' ,
    i_tt.task_priority2gbst_elm ,
    i_tt.task_sts2gbst_elm ,
    i_tt.type_task2gbst_elm ,
    i_tt.contact_objid ,
    i_tt.task_wip2wipbin ,
    i_tt.call_trans_objid ,
    i_tt.task_state2condition ,
    i_tt.task_originator2user ,
    i_tt.task_originator2user ,
    i_tt.order_type_objid ,
    1 , -- always 1
    i_tt.ota_type
  )
  RETURNING objid
  INTO      i_tt.task_objid;
  --

  IF i_tt.title LIKE 'FAILED%' THEN
    i_tt.response := dispatch ( i_task_objid =>  i_tt.task_objid); --,'Line Management Re-work' );
    IF i_tt.response <> 'SUCCESS' THEN
	  RETURN i_tt.response;
    END IF;
  END IF;

  dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row(s) created in TT (' || i_tt.task_objid || ')');

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING TASK RECORD: ' || SQLERRM;
     --
END save;

MEMBER FUNCTION dispatch ( i_task_objid IN NUMBER ) RETURN VARCHAR2 IS

BEGIN
  RETURN 'SUCCESS';
END dispatch;
END;
/