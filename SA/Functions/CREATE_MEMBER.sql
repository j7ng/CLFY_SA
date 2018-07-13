CREATE OR REPLACE FUNCTION sa."CREATE_MEMBER" ( i_esn                IN  VARCHAR2 ,
                                           i_web_user_objid     IN  NUMBER   ,
                                           i_service_plan_id    IN  NUMBER   ,
                                           i_bus_org_objid      IN  NUMBER   ,
                                           i_group_status       IN  VARCHAR2 ,
                                           i_member_status      IN  VARCHAR2 ,
                                           i_force_create_flag  IN  VARCHAR2 DEFAULT 'N',
                                           i_retrieve_only_flag IN  VARCHAR2 DEFAULT 'N',
                                           o_account_group_uid  OUT VARCHAR2 ,
                                           o_account_group_id   OUT NUMBER   ,
                                           o_subscriber_uid     OUT VARCHAR2 ,
                                           o_err_code           OUT NUMBER   ,
                                           o_err_msg            OUT VARCHAR2 ) RETURN NUMBER IS

  c  customer_type := customer_type ();

--
PROCEDURE local_create_group ( i_web_user_objid    IN     NUMBER    ,
                               i_service_plan_id   IN     NUMBER    ,
                               i_group_status      IN     VARCHAR2  ,
                               i_bus_org_objid     IN     NUMBER    ,
                               io_account_group_id IN OUT NUMBER    ,
                               o_account_group_uid OUT    VARCHAR2  ,
                               o_response          OUT    VARCHAR2  ) IS

  c  customer_type := customer_type ();

BEGIN

  -- get the brand
  c.bus_org_objid := NVL(i_bus_org_objid, c.get_bus_org_objid ( i_esn => i_esn ));

  -- validate brand
  IF c.bus_org_objid IS NULL THEN
    o_response := 'BRAND NOT FOUND';
  END IF;

  -- Get the group name (nickname)
  sa.brand_x_pkg.get_default_group_name ( ip_web_user_objid     => i_web_user_objid,
                                          op_account_group_name => c.account_group_name);

  IF io_account_group_id IS NULL THEN

    -- assign sequence next value
    io_account_group_id := sa.sequ_account_group.NEXTVAL;

    -- assign random group unique identifier
    o_account_group_uid := RandomUUID;

  END IF;

  BEGIN
    MERGE
    INTO  x_account_group d
    USING ( SELECT io_account_group_id objid,
                   NVL(c.account_group_name,'GROUP 1') account_group_name,
                   i_service_plan_id service_plan_id,
                   NULL service_plan_feature_date,
                   NULL program_enrolled_id,
                   i_group_status status,
                   SYSDATE insert_timestamp,
                   SYSDATE update_timestamp,
                   c.bus_org_objid bus_org_objid,
                   SYSDATE start_date,
                   NULL end_date,
                   o_account_group_uid account_group_uid
            FROM   DUAL
          ) s
   ON     ( d.objid = s.objid )
   WHEN MATCHED THEN
     UPDATE
     SET    d.bus_org_objid    = CASE
                                   WHEN (s.bus_org_objid = d.bus_org_objid) THEN d.bus_org_objid
                                   ELSE NVL(s.bus_org_objid,d.bus_org_objid)
                                 END,
            d.update_timestamp = s.update_timestamp
   WHEN NOT MATCHED THEN
     INSERT ( d.objid                     ,
              d.account_group_name        ,
              d.service_plan_id           ,
              d.service_plan_feature_date ,
              d.program_enrolled_id       ,
              d.status                    ,
              d.insert_timestamp          ,
              d.update_timestamp          ,
              d.bus_org_objid             ,
              d.start_date                ,
              d.end_date                  ,
              d.account_group_uid
            )
     VALUES ( s.objid                     ,
              s.account_group_name        ,
              s.service_plan_id           ,
              s.service_plan_feature_date ,
              s.program_enrolled_id       ,
              s.status                    ,
              s.insert_timestamp          ,
              s.update_timestamp          ,
              s.bus_org_objid             ,
              s.start_date                ,
              s.end_date                  ,
              s.account_group_uid
            );
   EXCEPTION
     WHEN others THEN
       -- return successful response
       o_response  := 'ERROR MERGING GROUP: ' || SQLERRM;
       RETURN;
  END;

  --
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN others THEN
     o_response := 'ERROR INSERTING GROUP => ' || SQLERRM;
END local_create_group;

PROCEDURE local_create_member ( i_esn              IN  VARCHAR2 ,
                                i_account_group_id IN  NUMBER   ,
                                i_member_status    IN  VARCHAR2 ,
                                o_member_objid     OUT NUMBER   ,
                                o_subscriber_uid   OUT VARCHAR2 ,
                                o_response         OUT VARCHAR2 ) IS

  c  customer_type := customer_type ();

BEGIN

  -- count active members in the group
  BEGIN
    SELECT COUNT(1)
    INTO   c.group_total_lines
    FROM   x_account_group_member
    WHERE  account_group_id = i_account_group_id;
   EXCEPTION
     WHEN others THEN
       c.group_total_lines := 0;
  END;

  -- set the master flag
  c.member_master_flag := CASE WHEN c.group_total_lines = 0 THEN 'Y' ELSE 'N' END;

  -- set the member order
  BEGIN
    SELECT MAX(member_order) + 1
    INTO   c.numeric_value
    FROM   x_account_group_member
    WHERE  account_group_id = i_account_group_id;
   EXCEPTION
     WHEN others THEN
       c.numeric_value := 1;
  END;

  -- Insert account group member
  BEGIN
    --
    INSERT
    INTO   x_account_group_member
           ( objid,
             account_group_id,
             esn,
             member_order,
             site_part_id,
             promotion_id,
             status,
             subscriber_uid,
             master_flag,
             start_date,
             end_date,
             receive_text_alerts_flag,
             insert_timestamp,
             update_timestamp
           )
    VALUES
    ( sa.sequ_account_group_member.NEXTVAL, -- objid
      i_account_group_id,                   -- account_group_id
      i_esn,                                -- esn
      (NVL(c.numeric_value,1)),             -- member_order
      NULL,                                 -- site_part_id
      NULL,                                 -- promotion_id
      i_member_status,                      -- status
      RandomUUID,                           -- subscriber_uid
      c.member_master_flag,                 -- master_flag
      SYSDATE,                              -- start_date
      NULL,                                 -- end_date
      'Y',                                  -- receive_text_alerts_flag
      SYSDATE,                              -- insert_timestamp
      SYSDATE                               -- update_timestamp
    )
    RETURNING objid,
              subscriber_uid
    INTO      o_member_objid,
              o_subscriber_uid;
   EXCEPTION
     WHEN others THEN
       -- return error
       o_response := 'ERROR INSERTING MEMBER: ' || SQLERRM;
       RETURN;
  END;

  --
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN others THEN
     o_response := 'ERROR INSERTING MEMBER => ' || SQLERRM;
END local_create_member;

-- start of main logic
BEGIN

  -- just for debugging
  --DBMS_OUTPUT.PUT_LINE('i_force_create_flag   => ' || i_force_create_flag);

  -- if we want to force a new member creation
  IF i_force_create_flag = 'Y'
  THEN

    -- get all the esn related information
    c := c.retrieve ( i_esn => i_esn );

    -- if there is already a group and a member created
    IF c.account_group_objid IS NOT NULL AND
       c.member_objid IS NOT NULL
    THEN

      -- expire all previous member record
      UPDATE x_account_group_member
      SET    status             = 'EXPIRED',
             end_date           = SYSDATE,
             update_timestamp   = SYSDATE
      WHERE  esn = c.esn;

      --
      IF c.group_total_lines = 1 THEN
        -- expire previous group
        UPDATE x_account_group
        SET    status = 'EXPIRED'
        WHERE  objid = c.account_group_objid;
	--
      END IF;

    END IF; -- IF c.account_group_objid IS NOT NULL AND

    --
    -- insert new group
    local_create_group ( i_web_user_objid    => i_web_user_objid      ,
                         i_service_plan_id   => i_service_plan_id     ,
                         i_group_status      => i_group_status        ,
                         i_bus_org_objid     => i_bus_org_objid       ,
                         io_account_group_id => c.account_group_objid ,
                         o_account_group_uid => o_account_group_uid   ,
                         o_response          => c.response            );

    o_account_group_id := c.account_group_objid;

    --
    IF c.response NOT LIKE '%SUCCESS%' THEN
      -- return successful response
      o_err_code := 10;
      o_err_msg  := c.response;
      RETURN c.member_objid;
    END IF;

    -- if the member was created, then return the new values and exit
    IF c.member_objid IS NOT NULL THEN
      -- return successful response
      o_err_code := 0;
      o_err_msg  := 'SUCCESS';
      --
      -- just for debugging
      --DBMS_OUTPUT.PUT_LINE('new group id          => ' || o_account_group_id);
      --DBMS_OUTPUT.PUT_LINE('new group uid         => ' || o_account_group_uid);
      --DBMS_OUTPUT.PUT_LINE('new member id         => ' || c.member_objid);
      --DBMS_OUTPUT.PUT_LINE('new member uid        => ' || o_subscriber_uid);
      -- return the existing member objid and exit
      RETURN c.member_objid;
    END IF;

  END IF; -- IF i_force_create_flag = 'Y'

  -- Get the UID, GROUP ID and MEMBER ID when an active ESN exists in the member table
  BEGIN
    SELECT subscriber_uid,
           objid,
           account_group_id
    INTO   o_subscriber_uid,
           c.member_objid,
           c.account_group_objid
    FROM   ( SELECT subscriber_uid,
                    objid,
                    account_group_id
             FROM   sa.x_account_group_member
             WHERE  esn = i_esn
             AND    UPPER(status) != 'EXPIRED'
             ORDER BY ( CASE UPPER(status)
                          WHEN 'ACTIVE'             THEN 1
                          WHEN 'PENDING_ENROLLMENT' THEN 2
                          ELSE 3
                        END),
                      ( CASE
                          WHEN (end_date IS NULL) THEN 1
                          ELSE 2
                        END ),
                      insert_timestamp
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  --
  IF c.account_group_objid IS NOT NULL THEN
    BEGIN
      SELECT account_group_uid,
             objid
      INTO   o_account_group_uid,
             o_account_group_id
      FROM   x_account_group
      WHERE  objid = c.account_group_objid;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
  END IF;

  -- if a member already exists, then return the retrieved values and exit
  IF c.member_objid IS NOT NULL THEN
    -- return successful response
    o_err_code := 0;
    o_err_msg  := 'SUCCESS';
    --
    -- just for debugging
    --DBMS_OUTPUT.PUT_LINE('group id              => ' || o_account_group_id);
    --DBMS_OUTPUT.PUT_LINE('group uid             => ' || o_account_group_uid);
    --DBMS_OUTPUT.PUT_LINE('member id             => ' || c.member_objid);
    --DBMS_OUTPUT.PUT_LINE('member uid            => ' || o_subscriber_uid);
    -- return the existing member objid and exit
    RETURN c.member_objid;
  END IF;

  -- ENTER THE GROUP CREATION LOGIC
  --IF c.account_group_objid IS NULL THEN

  -- ONLY retrieve the member info
  IF i_retrieve_only_flag = 'N' THEN

    --DBMS_OUTPUT.PUT_LINE('c.account_group_objid => ' || c.account_group_objid);

    -- insert new group
    local_create_group ( i_web_user_objid    => i_web_user_objid      ,
                         i_service_plan_id   => i_service_plan_id     ,
                         i_group_status      => i_group_status        ,
                         i_bus_org_objid     => i_bus_org_objid       ,
                         io_account_group_id => c.account_group_objid ,
                         o_account_group_uid => o_account_group_uid   ,
                         o_response          => c.response            );

    o_account_group_id := c.account_group_objid;

    --DBMS_OUTPUT.PUT_LINE('local_create_group    => ' || c.response);
    --DBMS_OUTPUT.PUT_LINE('o_account_group_id    => ' || o_account_group_id);

    --
    IF c.response NOT LIKE '%SUCCESS%' THEN
      -- return successful response
      o_err_code := 30;
      o_err_msg  := c.response;
      RETURN c.member_objid;
    END IF;
    --
  END IF;

  -- END IF;  -- IF c.account_group_objid IS NULL

  -- COMPLETED GROUP CREATION LOGIC
  --
  -- just for debugging
  --DBMS_OUTPUT.PUT_LINE('new group_objid       => ' || o_account_group_id);
  --DBMS_OUTPUT.PUT_LINE('new group uid         => ' || o_account_group_uid);

  -- Check if the ESN is in the member table (once again)
  BEGIN
    SELECT member_objid,
           subscriber_uid
    INTO   c.member_objid,
           o_subscriber_uid
    FROM   ( SELECT objid member_objid,
                    subscriber_uid
             FROM   sa.x_account_group_member
             WHERE  esn = i_esn
             AND    UPPER(status) != 'EXPIRED'
             ORDER BY status,
                      ( CASE
                          WHEN (end_date IS NULL) THEN 1
                          ELSE 2
                        END ),
                      insert_timestamp
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  --
  IF c.member_objid IS NOT NULL THEN
    --
    o_err_code := 0;
    o_err_msg  := 'SUCCESS';
    --
    --DBMS_OUTPUT.PUT_LINE('mbr is already there   => ' || c.member_objid);
    --
    RETURN c.member_objid;
    --
  END IF;

  -- ONLY retrieve the member info
  IF i_retrieve_only_flag = 'N' THEN

    -- insert new member
    local_create_member ( i_esn              => i_esn              ,
                          i_account_group_id => o_account_group_id ,
                          i_member_status    => i_member_status    ,
                          o_member_objid     => c.member_objid     ,
                          o_subscriber_uid   => o_subscriber_uid   ,
                          o_response         => c.response         );

    -- exit the program when the member insert failed
    IF c.response NOT LIKE '%SUCCESS%' THEN
      -- return successful response
      o_err_code := 40;
      o_err_msg  := c.response;
      RETURN c.member_objid;
    END IF;
    --

  END IF; -- IF i_retrieve_only_flag = 'N' ....

  -- return successful response
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';

  --
  -- just for debugging
  --DBMS_OUTPUT.PUT_LINE('new member objid      => ' || c.member_objid);
  --DBMS_OUTPUT.PUT_LINE('new member uid        => ' || o_subscriber_uid);

  RETURN c.member_objid;

 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := SQLCODE;
     o_err_msg  := SUBSTR(SQLERRM,1,100);
     RETURN NULL;
END;
/