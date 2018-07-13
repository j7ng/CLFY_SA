CREATE OR REPLACE TYPE sa."GROUP_TYPE" AS OBJECT (
  group_objid                     NUMBER(22)     ,
  account_group_name              VARCHAR2(50)   ,
  service_plan_id                 NUMBER(22)     ,
  service_plan_feature_date       DATE           ,
  program_enrolled_id             NUMBER(22)     ,
  status                          VARCHAR2(30)   ,
  start_date                      DATE           ,
  end_date                        DATE           ,
  bus_org_objid                   NUMBER(22)     ,
  account_group_uid               VARCHAR2(50)   ,
  insert_timestamp                DATE           ,
  update_timestamp                DATE           ,
  web_user_objid                  NUMBER(22)     ,
  response                        VARCHAR2(1000) ,
  numeric_value                   NUMBER         ,
  varchar2_value                  VARCHAR2(2000) ,
  exist                           VARCHAR2(1)    ,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION group_type RETURN SELF AS RESULT,
  -- Constructor used to initialize the
  CONSTRUCTOR FUNCTION group_type ( i_group_objid IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION group_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION group_type ( i_group_objid     IN NUMBER   ,
                                    i_service_plan_id IN NUMBER   ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION group_type ( i_web_user_objid    IN  NUMBER    ,
                                    i_service_plan_id   IN  NUMBER    ,
                                    i_status            IN  VARCHAR2  ,
                                    i_bus_org_objid     IN  NUMBER    ,
                                    i_account_group_uid IN  VARCHAR2  ) RETURN SELF AS RESULT,
  -- Function used to get the code configuration for an esn
  MEMBER FUNCTION expire ( i_esn IN VARCHAR2 ) RETURN group_type,
  -- Function used to expire a group with the group objid
  MEMBER FUNCTION expire ( i_group_objid IN NUMBER ) RETURN group_type,
  -- Function used to get the code configuration for an esn
  MEMBER FUNCTION expire RETURN group_type,
  MEMBER FUNCTION expire_add_ons ( i_esn             IN VARCHAR2              ,
                                   i_minute_interval IN VARCHAR2 DEFAULT '5'  ) RETURN VARCHAR2,
  MEMBER FUNCTION get_default_group_name ( i_web_user_objid IN NUMBER )  RETURN VARCHAR2,
  -- get the service plan of the esn
  MEMBER FUNCTION get_service_plan_objid ( i_esn IN VARCHAR2 ) RETURN VARCHAR2,
  -- Function used to get the code configuration for a sim
  MEMBER FUNCTION ins RETURN group_type,
  MEMBER FUNCTION save ( i_grp IN OUT group_type ) RETURN VARCHAR2,
  MEMBER FUNCTION save RETURN group_type,
  MEMBER FUNCTION upd RETURN group_type
);
/
CREATE OR REPLACE TYPE BODY sa."GROUP_TYPE" IS
CONSTRUCTOR FUNCTION group_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

CONSTRUCTOR FUNCTION group_type ( i_group_objid IN NUMBER ) RETURN SELF AS RESULT IS
  c_esn  VARCHAR2(30);
  gt  group_type := group_type();
  g   group_type := group_type();
BEGIN
  BEGIN
    SELECT group_type ( objid                      , -- objid                        NUMBER(22)
                        account_group_name         , -- account_group_name           VARCHAR2(50)
                        service_plan_id            , -- service_plan_id              NUMBER(22)
                        service_plan_feature_date  , -- service_plan_feature_date    DATE
                        program_enrolled_id        , -- program_enrolled_id          NUMBER(22)
                        status                     , -- status                       VARCHAR2(30)
                        start_date                 , -- start_date                   DATE
                        end_date                   , -- end_date                     DATE
                        bus_org_objid              , -- bus_org_objid                NUMBER(22)
                        account_group_uid          , -- account_group_uid            VARCHAR2(50)
                        insert_timestamp           , -- insert_timestamp             DATE
                        update_timestamp           , -- update_timestamp             DATE
                        NULL                       , -- web_user_objid
                        NULL                       , -- response                     VARCHAR2(1000),
                        NULL                       , -- numeric_value                NUMBER,
                        NULL                       , -- varchar2_value               VARCHAR2(2000),
                        NULL                         -- exist                        VARCHAR2(1),
                      )
    INTO   SELF
    FROM   x_account_group
    WHERE  objid = i_group_objid;
   EXCEPTION
     WHEN OTHERS THEN
       SELF.group_objid := i_group_objid;
       SELF.response := 'GROUP NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  IF SELF.service_plan_id IS NULL AND
     SELF.group_objid IS NOT NULL
  THEN
    --
    BEGIN
      SELECT esn
      INTO   c_esn
      FROM   x_account_group_member
      WHERE  account_group_id = SELF.group_objid
      AND    status = 'ACTIVE'
      AND    ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
    --
    IF c_esn IS NOT NULL THEN
      -- get the service plan
      SELF.service_plan_id := SELF.get_service_plan_objid ( i_esn => c_esn );
      -- if the service plan was found
      IF SELF.service_plan_id IS NOT NULL THEN
        -- instantiate values
        gt := group_type ( i_group_objid     => SELF.group_objid,
                           i_service_plan_id => SELF.service_plan_id);
        -- call method to update the missing service plan
        g := gt.upd;
      END IF;
    END IF; -- IF c_esn IS NOT NULL
  END IF; -- IF SELF.service_plan_id IS NULL AND SELF.group_objid IS NOT NULL

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.group_objid := i_group_objid;
     SELF.response := 'GROUP NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

CONSTRUCTOR FUNCTION group_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT IS
  gt  group_type := group_type();
  g   group_type := group_type();
BEGIN
  BEGIN
    SELECT group_type ( objid                      , -- objid                        NUMBER(22)
                        account_group_name         , -- account_group_name           VARCHAR2(50)
                        service_plan_id            , -- service_plan_id              NUMBER(22)
                        service_plan_feature_date  , -- service_plan_feature_date    DATE
                        program_enrolled_id        , -- program_enrolled_id          NUMBER(22)
                        status                     , -- status                       VARCHAR2(30)
                        start_date                 , -- start_date                   DATE
                        end_date                   , -- end_date                     DATE
                        bus_org_objid              , -- bus_org_objid                NUMBER(22)
                        account_group_uid          , -- account_group_uid            VARCHAR2(50)
                        insert_timestamp           , -- insert_timestamp             DATE
                        update_timestamp           , -- update_timestamp             DATE
                        NULL                       , -- web_user_objid
                        NULL                       , -- response                     VARCHAR2(1000),
                        NULL                       , -- numeric_value                NUMBER,
                        NULL                       , -- varchar2_value               VARCHAR2(2000),
                        NULL                         -- exist                        VARCHAR2(1),
                      )
    INTO   SELF
    FROM   x_account_group
    WHERE  objid IN ( SELECT account_group_id
                      FROM   x_account_group_member agm
                      WHERE  esn = i_esn
                      AND    status != 'EXPIRED'
                      AND    objid = ( SELECT MIN(objid)
                                       FROM   x_account_group_member
                                       WHERE  esn = agm.esn
                                       AND    status = agm.status
                                     )
                    );
   EXCEPTION
     WHEN OTHERS THEN
       SELF.response := 'GROUP NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  IF SELF.service_plan_id IS NULL AND
     SELF.group_objid IS NOT NULL
  THEN
    --
    IF i_esn IS NOT NULL THEN
      -- get the service plan
      SELF.service_plan_id := SELF.get_service_plan_objid ( i_esn => i_esn );
      -- if the service plan was found
      IF SELF.service_plan_id IS NOT NULL THEN
        -- instantiate values
        gt := group_type ( i_group_objid     => SELF.group_objid,
                           i_service_plan_id => SELF.service_plan_id);
        -- call method to update the missing service plan
        g := gt.upd;
      END IF;
      --
    END IF; -- IF i_esn IS NOT NULL
  END IF; -- IF SELF.service_plan_id IS NULL AND SELF.group_objid IS NOT NULL

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'GROUP NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

CONSTRUCTOR FUNCTION group_type ( i_group_objid       IN  NUMBER ,
                                  i_service_plan_id   IN  NUMBER ) RETURN SELF AS RESULT IS
BEGIN

  SELF.group_objid     := i_group_objid;
  SELF.service_plan_id := i_service_plan_id;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'ERROR INSTANTIATING GROUP: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

CONSTRUCTOR FUNCTION group_type ( i_web_user_objid    IN  NUMBER    ,
                                  i_service_plan_id   IN  NUMBER    ,
                                  i_status            IN  VARCHAR2  ,
                                  i_bus_org_objid     IN  NUMBER    ,
                                  i_account_group_uid IN  VARCHAR2  ) RETURN SELF AS RESULT IS
BEGIN

  SELF.web_user_objid    := i_web_user_objid;
  SELF.service_plan_id   := i_service_plan_id;
  SELF.status            := i_status;
  SELF.bus_org_objid     := i_bus_org_objid;
  SELF.account_group_uid := i_account_group_uid;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'ERROR INSTANTIATING GROUP: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION expire ( i_esn IN VARCHAR2 ) RETURN group_type IS
  g  group_type := group_type ();
BEGIN

  IF i_esn IS NULL THEN
    g.response := 'ESN NOT PASSED';
    RETURN g;
  END IF;

  --
  g := group_type ( i_esn => i_esn );

  --
  IF g.response NOT LIKE '%SUCCESS%' THEN
    RETURN g;
  END IF;

  --
  UPDATE x_account_group
  SET    status = 'EXPIRED',
         end_date = SYSDATE,
         update_timestamp = SYSDATE
  WHERE  objid = g.group_objid
  RETURNING objid                     ,
            account_group_name        ,
            service_plan_id           ,
            service_plan_feature_date ,
            program_enrolled_id       ,
            status                    ,
            start_date                ,
            end_date                  ,
            bus_org_objid             ,
            account_group_uid         ,
            insert_timestamp          ,
            update_timestamp
  INTO g.group_objid               ,
       g.account_group_name        ,
       g.service_plan_id           ,
       g.service_plan_feature_date ,
       g.program_enrolled_id       ,
       g.status                    ,
       g.start_date                ,
       g.end_date                  ,
       g.bus_org_objid             ,
       g.account_group_uid         ,
       g.insert_timestamp          ,
       g.update_timestamp          ;

  --
  g.response := 'SUCCESS';

  RETURN g;

 EXCEPTION
   WHEN OTHERS THEN
     g.response := 'GROUP NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN g;
END expire;

-- Function used to expire a group with the group objid
MEMBER FUNCTION expire ( i_group_objid IN NUMBER ) RETURN group_type IS

  g  group_type := group_type ();

BEGIN

  --
  g.group_objid := i_group_objid;

  --
  IF i_group_objid IS NULL THEN
    g.response := 'GROUP OBJID NOT PASSED';
    RETURN g;
  END IF;

  --
  UPDATE x_account_group
  SET    status = 'EXPIRED',
         end_date = SYSDATE,
         update_timestamp = SYSDATE
  WHERE  objid = g.group_objid
  RETURNING objid                     ,
            account_group_name        ,
            service_plan_id           ,
            service_plan_feature_date ,
            program_enrolled_id       ,
            status                    ,
            start_date                ,
            end_date                  ,
            bus_org_objid             ,
            account_group_uid         ,
            insert_timestamp          ,
            update_timestamp
  INTO g.group_objid               ,
       g.account_group_name        ,
       g.service_plan_id           ,
       g.service_plan_feature_date ,
       g.program_enrolled_id       ,
       g.status                    ,
       g.start_date                ,
       g.end_date                  ,
       g.bus_org_objid             ,
       g.account_group_uid         ,
       g.insert_timestamp          ,
       g.update_timestamp          ;

  --
  g.response := 'SUCCESS';

  RETURN g;

 EXCEPTION
   WHEN OTHERS THEN
     g.response := 'GROUP NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN g;

END expire;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION expire RETURN group_type IS

  g  group_type := SELF;

BEGIN

  --
  IF g.group_objid IS NULL THEN
    g.response := 'GROUP OBJID NOT PASSED';
    RETURN g;
  END IF;

  --
  g := g.expire ( i_group_objid => g.group_objid );

  --
  RETURN g;

 EXCEPTION
   WHEN OTHERS THEN
     g.response := 'GROUP NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN g;
END expire;

-- logic to expire all the active add ons made before 5 minutes ago
MEMBER FUNCTION expire_add_ons ( i_esn             IN VARCHAR2,
                                 i_minute_interval IN VARCHAR2  DEFAULT '5') RETURN VARCHAR2 IS

  g sa.group_type := sa.group_type ();

BEGIN

  --
  g := sa.group_type ( i_esn => i_esn );

  IF g.group_objid IS NULL THEN
    RETURN('GROUP NOT FOUND');
  END IF;

  --
  UPDATE sa.x_account_group_benefit agb
  SET    status = 'EXPIRED',
         end_date = SYSDATE,
         reason = 'EXPIRED FROM THROTTLE VALVE',
         update_timestamp = SYSDATE
  WHERE  account_group_id = g.group_objid
  AND    status = 'ACTIVE'
  AND    NOT EXISTS ( SELECT 1
                      FROM   table_x_call_trans
                      WHERE  objid = agb.call_trans_id
                      AND    x_transact_date >=  SYSDATE - NUMTODSINTERVAL ( i_minute_interval, 'MINUTE' )
                      AND    x_result = 'Completed'
                    );

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'GROUP ADDONS NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
END expire_add_ons;

MEMBER FUNCTION get_default_group_name ( i_web_user_objid IN NUMBER ) RETURN VARCHAR2 IS

  g group_type := group_type ();

BEGIN
  BEGIN
    -- Get the distinct groups that belong to the web user objid
    SELECT 'GROUP ' || TO_CHAR(NVL((NVL(COUNT(DISTINCT account_group_id),0) + 1),1))
    INTO   g.account_group_name
    FROM   x_account_group_member agm
    WHERE  esn IN ( SELECT pi.part_serial_no esn
                    FROM   table_x_contact_part_inst cpi,
                           table_contact c,
                           table_part_inst pi,
                           table_web_user wu
                    WHERE  wu.objid = i_web_user_objid
                    AND    wu.web_user2contact = c.objid
                    AND    c.objid = cpi.x_contact_part_inst2contact
                    AND    pi.objid = cpi.x_contact_part_inst2part_inst
                  );
   EXCEPTION
     WHEN others THEN
       RETURN('GROUP 1');
  END;

  -- return group name
  RETURN(g.account_group_name);

 EXCEPTION
   WHEN OTHERS THEN
     RETURN('GROUP 1');
END get_default_group_name;

MEMBER FUNCTION get_service_plan_objid ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 IS

  g group_type := group_type ();
  n_site_part_objid NUMBER;
BEGIN

  -- Get the active site part status
  BEGIN
    SELECT sp.objid site_part_objid
    INTO   n_site_part_objid
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = i_esn
    AND    sp.part_status = 'Active';
   EXCEPTION
     WHEN no_data_found THEN
       -- get the site part for the last installed row in site part
       BEGIN
         SELECT sp.objid site_part_objid
         INTO   n_site_part_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = i_esn
         AND    sp.install_date = ( SELECT MAX(install_date)
                                    FROM   table_site_part
                                    WHERE  x_service_id = sp.x_service_id
                                  );
        EXCEPTION
          WHEN others THEN
            NULL;
       END;
     WHEN too_many_rows THEN
       -- Get the max objid when there is more than one active site part
       BEGIN
         SELECT sp.objid site_part_objid
         INTO   n_site_part_objid
         FROM   table_site_part sp
         WHERE  1 = 1
         AND    sp.x_service_id = i_esn
         AND    sp.part_status = 'Active'
         AND    sp.objid = ( SELECT MAX(objid)
                             FROM   table_site_part
                             WHERE  x_service_id = sp.x_service_id
                             AND    part_status = 'Active'
                           );
        EXCEPTION
          WHEN others THEN
            NULL;
       END;
     WHEN others THEN
       NULL;
  END;

  --
  IF n_site_part_objid IS NOT NULL THEN
    -- Get the service plan and cos
    BEGIN
      SELECT fea.service_plan_objid
      INTO   g.service_plan_id
      FROM   x_service_plan_site_part spsp,
             sa.service_plan_feat_pivot_mv fea
      WHERE  spsp.table_site_part_id = n_site_part_objid
      AND    spsp.x_service_plan_id = fea.service_plan_objid;
     EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  END IF;

  -- return group name
  RETURN(g.service_plan_id);

 EXCEPTION
   WHEN OTHERS THEN
     RETURN(NULL);
END get_service_plan_objid;

-- Function used to get the code configuration for a sim
MEMBER FUNCTION ins RETURN group_type IS

  g  group_type := SELF;

BEGIN

  --
  -- validate brand
  IF g.bus_org_objid IS NULL THEN
    g.response := 'BRAND NOT PASSED';
    RETURN g;
  END IF;

  -- validate brand
  IF g.service_plan_id IS NULL THEN
    g.response := 'SERVICE PLAN NOT PASSED';
    RETURN g;
  END IF;

  --
  g.account_group_name := g.get_default_group_name ( i_web_user_objid => g.web_user_objid );

  --
  g.status := NVL(g.status,'ACTIVE');

  --
  g.account_group_uid := NVL(g.account_group_uid,RandomUUID);

  g.start_date := SYSDATE;
  g.end_date := NULL;
  g.service_plan_feature_date := NULL;
  g.program_enrolled_id := NULL;

  --
  g.response := g.save ( i_grp => g );


  -- return the row type
  RETURN g;

 EXCEPTION
   WHEN others THEN
     g.response := 'ERROR INSERTING GROUP: ' || SQLERRM;
     RETURN g;
END ins;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save ( i_grp IN OUT group_type ) RETURN VARCHAR2 IS

  g  group_type := group_type ();

BEGIN

  -- Assign timestamp attributes
  i_grp.insert_timestamp := SYSDATE;
  i_grp.update_timestamp := SYSDATE;

  -- set unique identifier when not passed
  IF i_grp.account_group_uid IS NULL THEN
    i_grp.account_group_uid := RandomUUID;
  END IF;

  --
  BEGIN
    INSERT
    INTO   x_account_group
           ( objid                     ,
             account_group_name        ,
             service_plan_id           ,
             service_plan_feature_date ,
             program_enrolled_id       ,
             status                    ,
             start_date                ,
             end_date                  ,
             bus_org_objid             ,
             account_group_uid         ,
             insert_timestamp          ,
             update_timestamp
           )
    VALUES
    ( sa.sequ_account_group.NEXTVAL   ,
      i_grp.account_group_name        ,
      i_grp.service_plan_id           ,
      i_grp.service_plan_feature_date ,
      i_grp.program_enrolled_id       ,
      i_grp.status                    ,
      i_grp.start_date                ,
      i_grp.end_date                  ,
      i_grp.bus_org_objid             ,
      i_grp.account_group_uid         ,
      i_grp.insert_timestamp          ,
      i_grp.update_timestamp
    )
    RETURNING objid,
              account_group_uid
    INTO      i_grp.group_objid,
              i_grp.account_group_uid;

   EXCEPTION
    WHEN dup_val_on_index then
      RETURN('DUPLICATE VALUE INSERTING INTO GROUP');
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in GRP (' || i_grp.group_objid || ')');

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING GROUP RECORD: ' || SQLERRM;
     --
END save;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save RETURN group_type IS

  g  group_type := SELF;

BEGIN

  -- Assign timestamp attributes
  g.insert_timestamp := SYSDATE;
  g.update_timestamp := SYSDATE;

  -- set unique identifier when not passed
  IF g.account_group_uid IS NULL THEN
    g.account_group_uid := RandomUUID;
  END IF;

  --
  BEGIN
    INSERT
    INTO   x_account_group
           ( objid                     ,
             account_group_name        ,
             service_plan_id           ,
             service_plan_feature_date ,
             program_enrolled_id       ,
             status                    ,
             start_date                ,
             end_date                  ,
             bus_org_objid             ,
             account_group_uid         ,
             insert_timestamp          ,
             update_timestamp
           )
    VALUES
    ( sa.sequ_account_group.NEXTVAL   ,
      g.account_group_name        ,
      g.service_plan_id           ,
      g.service_plan_feature_date ,
      g.program_enrolled_id       ,
      g.status                    ,
      g.start_date                ,
      g.end_date                  ,
      g.bus_org_objid             ,
      g.account_group_uid         ,
      g.insert_timestamp          ,
      g.update_timestamp
    )
    RETURNING objid
    INTO      g.group_objid;

   EXCEPTION
    WHEN dup_val_on_index then
      g.response := 'DUPLICATE VALUE INSERTING INTO GROUP';
      RETURN g;
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in GRP (' || g.group_objid || ')');

  --
  g.response := 'SUCCESS';

  RETURN g;

 EXCEPTION
   WHEN OTHERS THEN
     g.response := 'ERROR SAVING GROUP RECORD: ' || SQLERRM;
     RETURN g;
     --
END save;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION upd RETURN group_type IS

  g  group_type := SELF;

BEGIN

  -- validate group objid when not passed
  IF g.group_objid IS NULL THEN
    g.response := 'GROUP OBJID NOT PASSED';
    RETURN g;
  END IF;

  -- validate service plan when not passed
  IF g.service_plan_id IS NULL THEN
    g.response := 'SERVICE PLAN NOT PASSED';
    RETURN g;
  END IF;

  BEGIN
    -- update service plan
    UPDATE x_account_group
    SET    service_plan_id = g.service_plan_id,
           update_timestamp = SYSDATE
    WHERE  objid           = g.group_objid
    RETURNING account_group_name        ,
              service_plan_id           ,
              service_plan_feature_date ,
              program_enrolled_id       ,
              status                    ,
              start_date                ,
              end_date                  ,
              bus_org_objid             ,
              account_group_uid         ,
              insert_timestamp          ,
              update_timestamp
    INTO      g.account_group_name        ,
              g.service_plan_id           ,
              g.service_plan_feature_date ,
              g.program_enrolled_id       ,
              g.status                    ,
              g.start_date                ,
              g.end_date                  ,
              g.bus_org_objid             ,
              g.account_group_uid         ,
              g.insert_timestamp          ,
              g.update_timestamp          ;
   EXCEPTION
    WHEN others THEN
      g.response := 'ERROR UPDATING GROUP: ' || SQLERRM;
      RETURN g;
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row udpated in GRP (' || g.group_objid || ')');

  --
  g.response := 'SUCCESS';

  RETURN g;

 EXCEPTION
   WHEN OTHERS THEN
     g.response := 'ERROR SAVING GROUP RECORD: ' || SQLERRM;
     RETURN g;
     --
END upd;

--
END;
/