CREATE OR REPLACE TYPE sa.call_trans_ext_type AS OBJECT (
  call_trans_ext_objid       NUMBER(38)     ,
  call_trans_objid           NUMBER(38)     ,
  total_days                 NUMBER         ,
  total_sms_units            NUMBER         ,
  total_data_units           NUMBER         ,
  insert_date                DATE           ,
  update_date                DATE           ,
  account_group_id           NUMBER(22)     ,
  master_flag                VARCHAR2(1)    ,
  service_plan_id            NUMBER(38)     ,
  response                   VARCHAR2(1000) ,
  numeric_value              NUMBER         ,
  varchar2_value             VARCHAR2(2000) ,
  CONSTRUCTOR FUNCTION call_trans_ext_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION call_trans_ext_type ( i_call_trans_ext_objid IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION call_trans_ext_type ( i_call_trans_objid IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION call_trans_ext_type ( i_call_trans_ext_objid IN NUMBER DEFAULT NULL,
                                             i_call_trans_objid     IN NUMBER   ,
                                             i_total_days           IN NUMBER   DEFAULT NULL,
                                             i_total_sms_units      IN NUMBER   DEFAULT NULL,
                                             i_total_data_units     IN NUMBER   DEFAULT NULL,
                                             i_insert_date          IN DATE     DEFAULT NULL,
                                             i_update_date          IN DATE     DEFAULT NULL,
                                             i_account_group_id     IN NUMBER   DEFAULT NULL,
                                             i_master_flag          IN VARCHAR2 DEFAULT NULL,
                                             i_service_plan_id      IN NUMBER   DEFAULT NULL) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_call_trans_ext_objid IN NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION ins RETURN call_trans_ext_type,
  MEMBER FUNCTION upd ( i_call_trans_ext_objid IN NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN call_trans_ext_type,
  MEMBER FUNCTION del ( i_call_trans_ext_objid IN  NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION del ( i_call_trans_objid IN  NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN,
  MEMBER FUNCTION get RETURN call_trans_ext_type,
  MEMBER FUNCTION get ( i_call_trans_ext_objid IN NUMBER ) RETURN call_trans_ext_type,
  MEMBER FUNCTION retrieve RETURN call_trans_ext_type,
  MEMBER FUNCTION save ( i_ce IN OUT call_trans_ext_type ) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY sa."CALL_TRANS_EXT_TYPE" IS
CONSTRUCTOR FUNCTION call_trans_ext_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

CONSTRUCTOR FUNCTION call_trans_ext_type ( i_call_trans_ext_objid IN NUMBER ) RETURN SELF AS RESULT IS

BEGIN
  --
  IF i_call_trans_ext_objid IS NULL THEN
    SELF.response := 'CALL TRANS EXT ID NOT PASSED';
    RETURN;
  END IF;

  -- Query the table
  SELECT call_trans_ext_type ( ext.objid                 , -- call_trans_ext_objid
                               call_trans_ext2call_trans , -- call_trans_objid
                               x_total_days              , -- total_days
                               x_total_sms_units         , -- total_sms_units
                               x_total_data_units        , -- total_data_units
                               insert_date               , -- insert_date
                               update_date               , -- update_date
                               account_group_id          , -- account_group_id
                               master_flag               , -- master_flag
                               service_plan_id           , -- service_plan_id
                               NULL                      , -- response
                               NULL                      , -- numeric_value
                               NULL                        -- varchar2_value
                             )
  INTO   SELF
  FROM   table_x_call_trans_ext ext,
         table_x_call_trans ct
  WHERE  ext.objid = i_call_trans_ext_objid
  AND    ext.call_trans_ext2call_trans = ct.objid;

  --
  SELF.response := 'SUCCESS';

  RETURN;

EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'CALL TRANS NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     SELF.call_trans_ext_objid := i_call_trans_ext_objid;
     --
     RETURN;
END;

CONSTRUCTOR FUNCTION call_trans_ext_type ( i_call_trans_objid IN NUMBER ) RETURN SELF AS RESULT IS

BEGIN
  --
  IF i_call_trans_objid IS NULL THEN
    SELF.response := 'CALL TRANS ID NOT PASSED';
    RETURN;
  END IF;

  -- Query the table
  SELECT call_trans_ext_type ( ext.objid                     , -- call_trans_ext_objid
                               ext.call_trans_ext2call_trans , -- call_trans_objid
                               ext.x_total_days              , -- total_days
                               ext.x_total_sms_units         , -- total_sms_units
                               ext.x_total_data_units        , -- total_data_units
                               ext.insert_date               , -- insert_date
                               ext.update_date               , -- update_date
                               ext.account_group_id          , -- account_group_id
                               ext.master_flag               , -- master_flag
                               ext.service_plan_id           , -- service_plan_id
                               NULL                          , -- response
                               NULL                          , -- numeric_value
                               NULL                            -- varchar2_value
                             )
  INTO   SELF
  FROM   table_x_call_trans ct,
         table_x_call_trans_ext ext
  WHERE  ct.objid = i_call_trans_objid
  AND    ct.objid = ext.call_trans_ext2call_trans;

  --
  SELF.response := 'SUCCESS';

  RETURN;
EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'CALL TRANS NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     SELF.call_trans_objid := i_call_trans_objid;
     --
     RETURN;
END;

CONSTRUCTOR FUNCTION call_trans_ext_type ( i_call_trans_ext_objid IN NUMBER DEFAULT NULL,
                                           i_call_trans_objid     IN NUMBER   ,
                                           i_total_days           IN NUMBER   DEFAULT NULL,
                                           i_total_sms_units      IN NUMBER   DEFAULT NULL,
                                           i_total_data_units     IN NUMBER   DEFAULT NULL,
                                           i_insert_date          IN DATE     DEFAULT NULL,
                                           i_update_date          IN DATE     DEFAULT NULL,
                                           i_account_group_id     IN NUMBER   DEFAULT NULL,
                                           i_master_flag          IN VARCHAR2 DEFAULT NULL,
                                           i_service_plan_id      IN NUMBER   DEFAULT NULL) RETURN SELF AS RESULT IS

BEGIN

  --
  SELF.call_trans_ext_objid := i_call_trans_ext_objid ;
  SELF.call_trans_objid     := i_call_trans_objid     ;
  SELF.total_days           := i_total_days           ;
  SELF.total_sms_units      := i_total_sms_units      ;
  SELF.total_data_units     := i_total_data_units     ;
  SELF.insert_date          := i_insert_date          ;
  SELF.update_date          := i_update_date          ;
  SELF.account_group_id     := i_account_group_id     ;
  SELF.master_flag          := i_master_flag          ;
  SELF.service_plan_id      := i_service_plan_id      ;
  --

  SELF.response := 'SUCCESS';

  RETURN;

EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'ERROR INITIALIZING CALL TRANS EXT: ' || SUBSTR(SQLERRM,1,100);
     SELF.call_trans_ext_objid := i_call_trans_ext_objid ;
     SELF.call_trans_objid     := i_call_trans_objid     ;
     SELF.total_days           := i_total_days           ;
     SELF.total_sms_units      := i_total_sms_units      ;
     SELF.total_data_units     := i_total_data_units     ;
     SELF.insert_date          := i_insert_date          ;
     SELF.update_date          := i_update_date          ;
     SELF.account_group_id     := i_account_group_id     ;
     SELF.master_flag          := i_master_flag          ;
     SELF.service_plan_id      := i_service_plan_id      ;
     --
     RETURN;
END;

MEMBER FUNCTION exist RETURN BOOLEAN IS

ce  call_trans_ext_type := call_trans_ext_type ( i_call_trans_ext_objid => SELF.call_trans_ext_objid );

BEGIN
IF ce.call_trans_objid IS NOT NULL THEN
    RETURN TRUE;
ELSE
    RETURN FALSE;
END IF;
END exist;

MEMBER FUNCTION exist ( i_call_trans_ext_objid IN NUMBER) RETURN BOOLEAN IS

ce  call_trans_ext_type := call_trans_ext_type ( i_call_trans_ext_objid => i_call_trans_ext_objid );

BEGIN
IF ce.call_trans_objid IS NOT NULL THEN
    RETURN TRUE;
ELSE
    RETURN FALSE;
END IF;
END exist;

-- Procedure to add the
MEMBER FUNCTION ins RETURN call_trans_ext_type IS

  ce  call_trans_ext_type := SELF;
  c   call_trans_ext_type := SELF;

BEGIN

  -- Verify inputs
  IF ce.total_days       IS NULL AND
     ce.total_sms_units  IS NULL AND
     ce.total_data_units IS NULL AND
     ce.insert_date      IS NULL AND
     ce.update_date      IS NULL AND
     ce.account_group_id IS NULL AND
     ce.master_flag      IS NULL AND
     ce.service_plan_id  IS NULL
  THEN
    -- At least one attribute should have been passed
    ce.response := 'NO ATTRIBUTE PASSED';
    RETURN ce;
  END IF;

  -- Retrieve the call trans data
  c := ce.retrieve;

  -- Save transaction only when retrieve came back successful
  IF c.response LIKE '%SUCCESS%' THEN
    -- Raw insert into TABLE_X_CALL_TRANS_EXT table
    c.response := c.response || '|' || save(c) ;
    --
    c.response := CASE c.response WHEN 'SUCCESS|SUCCESS' THEN 'SUCCESS' ELSE c.response END;

  ELSE
    -- Return the error message in the c.response column
    c.response := c.response || '|ROW WAS NOT CREATED';
  END IF;

  RETURN c;

EXCEPTION
   WHEN others THEN
     ce.response  := 'ERROR INSERTING CALL TRANS EXT RECORD: ' || SUBSTR(SQLERRM,1,100);
     --
     RETURN ce;
END ins;

-- Function to expire a subscriber
MEMBER FUNCTION upd ( i_call_trans_ext_objid IN NUMBER) RETURN BOOLEAN IS
BEGIN
  RETURN TRUE;
END upd;

-- Function to update a subscriber
MEMBER FUNCTION upd RETURN call_trans_ext_type IS

  ce  call_trans_ext_type := SELF;

BEGIN
  IF ce.call_trans_ext_objid IS NOT NULL THEN
    UPDATE table_x_call_trans_ext
    SET    update_date = SYSDATE
    WHERE  objid = ce.call_trans_ext_objid;
  END IF;

  ce.response := 'SUCCESS';
  RETURN ce;

END upd;

MEMBER FUNCTION del ( i_call_trans_ext_objid  IN NUMBER) RETURN BOOLEAN IS

  ce call_trans_ext_type := call_trans_ext_type ( i_call_trans_ext_objid => i_call_trans_ext_objid);

  -- ce call_trans_ext_type := call_trans_ext_type ( i_call_trans_objid => i_call_trans_objid);

BEGIN
  --
  IF ce.response != 'SUCCESS' THEN
    ce.response := 'UNABLE TO DELETE CALL TRANS EXT: ' || ce.response;
    RETURN FALSE;
  END IF;

  --
  DELETE table_x_call_trans_ext
  WHERE  objid = i_call_trans_ext_objid;

  ce.response := 'SUCCESS';

  RETURN TRUE;

EXCEPTION
   WHEN others THEN
     ce.response := 'ERROR DELETING CALL TRANS EXT: ' || SUBSTR(SQLERRM,1,100);
     RETURN FALSE;
END del;

MEMBER FUNCTION del ( i_call_trans_objid IN NUMBER ) RETURN BOOLEAN IS

  -- ce call_trans_ext_type := call_trans_ext_type ( i_call_trans_objid => i_call_trans_objid);

BEGIN
  --
  DELETE table_x_call_trans_ext
  WHERE  call_trans_ext2call_trans = i_call_trans_objid;


  RETURN TRUE;
EXCEPTION
   WHEN others THEN
     RETURN FALSE;
END del;

MEMBER FUNCTION del RETURN BOOLEAN IS

  ce call_trans_ext_type := call_trans_ext_type ( i_call_trans_ext_objid => SELF.call_trans_ext_objid );

BEGIN
   RETURN ce.del ( i_call_trans_ext_objid => SELF.call_trans_ext_objid);
END;

--
MEMBER FUNCTION get RETURN call_trans_ext_type IS

  ce call_trans_ext_type := call_trans_ext_type( i_call_trans_ext_objid => SELF.call_trans_ext_objid );

BEGIN
  RETURN ce;
END;

MEMBER FUNCTION get ( i_call_trans_ext_objid IN NUMBER ) RETURN call_trans_ext_type IS

  ce  call_trans_ext_type := SELF;
  c   call_trans_ext_type;

BEGIN
  RETURN ce;
END get;

-- Procedure to add the
MEMBER FUNCTION retrieve RETURN call_trans_ext_type IS

  ce  call_trans_ext_type := SELF;
  l_esn  VARCHAR2(30);

BEGIN
  -- Reset response column to blank
  ce.response := NULL;

  -- call_trans_objid
  IF ce.call_trans_objid IS NULL THEN
    ce.response := 'NO CALL TRANS ID PASSED';
    RETURN ce;
  END IF;

  --
  BEGIN
    SELECT x_service_id
     INTO   l_esn
     FROM   table_x_call_trans
     WHERE  objid = ce.call_trans_objid;
   EXCEPTION
     WHEN others THEN
      ce.response := 'CALL TRANS NOT FOUND';
      RETURN ce;
  END;

  --
  IF l_esn IS NULL THEN
    ce.response := 'ESN NOT FOUND IN CALL TRANS';
    RETURN ce;
  END IF;

  -- Get the account group attributes
  BEGIN
    SELECT agm.account_group_id group_id,
           agm.master_flag,
           ( SELECT service_plan_id
             FROM   ( SELECT spsp.x_service_plan_id service_plan_id
                      FROM   table_site_part sp,
                             x_service_plan_site_part spsp
                      WHERE  sp.x_service_id = l_esn
                      AND    sp.objid = spsp.table_site_part_id
                      ORDER BY sp.update_stamp DESC
                    )
             WHERE  ROWNUM = 1 -- Return the latest modified row
           ) service_plan_id
    INTO   ce.account_group_id,
            ce.master_flag,
              ce.service_plan_id
    FROM   x_account_group_member agm
    WHERE  1 = 1
    AND    agm.esn = l_esn
    AND    UPPER(agm.status) <> 'EXPIRED';
   EXCEPTION
     WHEN no_data_found THEN
       ce.response  := 'ESN NOT FOUND IN ACCOUNT GROUP MEMBER';
     WHEN too_many_rows THEN
       ce.response  := 'DUPLICATE ESN FOUND IN ACCOUNT GROUP MEMBER';
       RETURN ce;
     WHEN others THEN
       ce.response  := 'ERROR SEARCHING FOR ESN IN ACCOUNT GROUP MEMBER: ' || SUBSTR(SQLERRM,1,100);
       RETURN ce;
  END;


  -- Set dates
  ce.insert_date := SYSDATE;
  ce.update_date := SYSDATE;

  -- total_days
  -- total_sms_units
  -- total_data_units

  -- Set successful response
  ce.response := CASE WHEN ce.response IS NULL THEN 'SUCCESS' ELSE ce.response || '|SUCCESS' END;

  RETURN ce;

EXCEPTION
    WHEN others THEN
      ce.response  := ce.response || '|ERROR RETRIEVING CALL TRANS EXT RECORD: ' || SUBSTR(SQLERRM,1,100);
      --
      RETURN ce;
END retrieve;

MEMBER FUNCTION save ( i_ce IN OUT call_trans_ext_type ) RETURN VARCHAR2 IS

  --c call_trans_ext_type := call_trans_ext_type();

BEGIN
  -- Validate empty attribute
  IF i_ce.call_trans_objid IS NULL THEN
    RETURN 'CALL TRANS OBJID ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Validate empty attribute
  IF i_ce.insert_date IS NULL THEN
    RETURN 'INSERT DATE ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  -- Validate empty attribute
  IF i_ce.update_date IS NULL THEN
    RETURN 'INSERT DATE ATTRIBUTE CANNOT BE EMPTY';
  END IF;

  --
  BEGIN
    MERGE
    INTO  table_x_call_trans_ext ce
    USING dual
    ON    ( ce.call_trans_ext2call_trans = i_ce.call_trans_objid )
    WHEN MATCHED THEN
      UPDATE
      SET    ce.x_total_days       = NVL(ce.x_total_days, i_ce.total_days), -- CR47564 added NVL to retain not null existing value
             ce.x_total_sms_units  = i_ce.total_sms_units ,
             ce.x_total_data_units = i_ce.total_data_units,
             ce.update_date        = i_ce.update_date     ,
             ce.account_group_id   = i_ce.account_group_id,
             ce.master_flag        = i_ce.master_flag     ,
             ce.service_plan_id    = i_ce.service_plan_id
    WHEN NOT MATCHED THEN
      INSERT ( objid                     ,
               call_trans_ext2call_trans ,
               x_total_days              ,
               x_total_sms_units         ,
               x_total_data_units        ,
               insert_date               ,
               update_date               ,
               account_group_id          ,
               master_flag               ,
               service_plan_id
             )
      VALUES
      ( sa.sequ_table_x_call_trans_ext.NEXTVAL ,
        i_ce.call_trans_objid                  ,
        i_ce.total_days                        ,
        i_ce.total_sms_units                   ,
        i_ce.total_data_units                  ,
        i_ce.insert_date                       ,
        i_ce.update_date                       ,
        i_ce.account_group_id                  ,
        i_ce.master_flag                       ,
        i_ce.service_plan_id
      );

   EXCEPTION
    WHEN OTHERS then
      RETURN('ERROR MERGING CALL TRANS EXT ROW: ' || SUBSTR(SQLERRM,1,100));

  END;

  dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row(s) merged in CE');

  -- Call the CALL TRANS constructor to find out the objid created/updated
  --c := call_trans_ext_type ( i_call_trans_objid => i_ce.call_trans_objid );

  -- Set the objid created/updated
  --i_ce.call_trans_ext_objid := c.call_trans_ext_objid;


  RETURN('SUCCESS');

EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING CALL TRANS EXT RECORD: ' || SQLERRM;
     --
END save;

END;
/