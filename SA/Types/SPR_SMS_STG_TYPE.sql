CREATE OR REPLACE TYPE sa.spr_sms_stg_type IS OBJECT
(
  spr_sms_stg_id              NUMBER(22)    ,
  esn                         VARCHAR2(30)  ,
  usage_percent               NUMBER(3)     ,
  script_id                   VARCHAR2(30)  ,
  insert_timestamp            DATE          ,
  sent_date                   DATE          ,
  status                      VARCHAR2(1000),
  CONSTRUCTOR FUNCTION spr_sms_stg_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION spr_sms_stg_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION spr_sms_stg_type ( i_esn              IN  VARCHAR2              ,
                                          i_usage_percent    IN  NUMBER                ,
                                          i_script_id        IN  VARCHAR2 DEFAULT NULL ,
                                          i_insert_timestamp IN  DATE DEFAULT SYSDATE  ,
                                          i_sent_date        IN  DATE DEFAULT NULL     ) RETURN SELF AS RESULT,
  MEMBER FUNCTION ins RETURN spr_sms_stg_type,
  MEMBER FUNCTION ins ( i_esn              IN  VARCHAR2 ,
                        i_usage_percent    IN  NUMBER   ,
                        i_script_id        IN  VARCHAR2 ,
                        i_insert_timestamp IN  DATE     ,
                        i_sent_date        IN  DATE     ) RETURN spr_sms_stg_type,
  MEMBER FUNCTION exist ( i_esn   IN VARCHAR2 ) RETURN BOOLEAN,
  MEMBER FUNCTION upd ( i_esn              IN VARCHAR2 ,
                        i_usage_percent    IN NUMBER   ,
                        i_script_id        IN VARCHAR2 ,
                        i_insert_timestamp IN DATE     ,
                        i_sent_date        IN DATE     ) RETURN BOOLEAN,
  MEMBER FUNCTION del ( i_esn IN VARCHAR2 ) RETURN BOOLEAN
);
/
CREATE OR REPLACE TYPE BODY sa.spr_sms_stg_type AS

CONSTRUCTOR FUNCTION spr_sms_stg_type RETURN SELF AS RESULT AS
BEGIN
  -- TODO: Implementation required for FUNCTION SPR_SMS_STG_TYPE.spr_sms_stg_type
  RETURN;
END spr_sms_stg_type;

CONSTRUCTOR FUNCTION spr_sms_stg_type ( i_esn IN VARCHAR2 ) RETURN SELF AS RESULT AS
BEGIN
  --
  IF i_esn IS NULL THEN
    RETURN;
  END IF;

  -- Search an unsent sms row for a given ESN
  SELECT spr_sms_stg_type ( objid            ,
                            esn              ,
                            usage_percent    ,
                            script_id        ,
                            insert_timestamp ,
                            sent_date        ,
                            NULL               -- Set status as empty
                          )
  INTO   SELF
  FROM   x_spr_sms_stg
  WHERE  esn = i_esn
  AND    sent_date IS NULL -- search for unsent messages only
  AND    ROWNUM = 1; -- only return one row

  --
  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     self.esn := i_esn;
     RETURN;
END spr_sms_stg_type;

CONSTRUCTOR FUNCTION spr_sms_stg_type ( i_esn              IN  VARCHAR2              ,
                                        i_usage_percent    IN  NUMBER                ,
                                        i_script_id        IN  VARCHAR2 DEFAULT NULL ,
                                        i_insert_timestamp IN  DATE DEFAULT SYSDATE  ,
                                        i_sent_date        IN  DATE DEFAULT NULL     ) RETURN SELF AS RESULT AS
BEGIN

  SELF.esn              := i_esn              ;
  SELF.usage_percent    := i_usage_percent    ;
  SELF.script_id        := i_script_id        ;
  SELF.insert_timestamp := i_insert_timestamp ;
  SELF.sent_date        := i_sent_date        ;
  --
  RETURN;
END spr_sms_stg_type;

MEMBER FUNCTION ins RETURN spr_sms_stg_type IS
  sms   spr_sms_stg_type := SELF;
BEGIN
  sms.status := NULL;

  IF SELF.esn IS NULL THEN
    sms.status := 'ESN NOT FOUND';
    RETURN sms;
  END IF;

  IF SELF.usage_percent IS NULL THEN
    sms.status := 'USAGE NOT FOUND';
    RETURN sms;
  END IF;

  --IF SELF.script_id IS NULL THEN
  --  sms.status := 'SCRIPT NOT FOUND';
  --  RETURN sms;
  --END IF;

  -- TODO: Implementation for FUNCTION SPR_SMS_STG_TYPE.ins
  INSERT
  INTO   x_spr_sms_stg
         ( objid            ,
           esn              ,
           usage_percent    ,
           script_id        ,
           insert_timestamp ,
           sent_date
         )
  VALUES
  ( sequ_spr_sms_stg.NEXTVAL          ,
    sms.esn                           ,
    sms.usage_percent                 ,
    sms.script_id                     ,
    sms.insert_timestamp ,
    sms.sent_date
  );
  --
  sms.status := 'SUCCESS';
  --
  RETURN sms;
 EXCEPTION
   WHEN others THEN
    sms.status := 'ERROR INSERTING SMS: ' || SUBSTR(SQLERRM,1,100);
    RETURN sms;

END ins;

MEMBER FUNCTION ins ( i_esn              IN  VARCHAR2 ,
                      i_usage_percent    IN  NUMBER   ,
                      i_script_id        IN  VARCHAR2 ,
                      i_insert_timestamp IN  DATE     ,
                      i_sent_date        IN  DATE     ) RETURN spr_sms_stg_type IS

  sms   spr_sms_stg_type := SELF;
BEGIN
  IF i_esn IS NULL THEN
    sms.status := 'ESN NOT FOUND';
    RETURN sms;
  END IF;

  IF i_usage_percent IS NULL THEN
    sms.status := 'USAGE NOT FOUND';
    RETURN sms;
  END IF;

  IF i_script_id IS NULL THEN
    sms.status := 'SCRIPT NOT FOUND';
    RETURN sms;
  END IF;

  sms.esn              := i_esn;
  sms.usage_percent    := i_usage_percent;
  sms.script_id        := i_script_id;
  sms.insert_timestamp := NVL(i_insert_timestamp, SYSDATE);
  sms.sent_date        := i_sent_date;

  -- TODO: Implementation for FUNCTION SPR_SMS_STG_TYPE.ins
  INSERT
  INTO   x_spr_sms_stg
         ( objid            ,
           esn              ,
           usage_percent    ,
           script_id        ,
           insert_timestamp ,
           sent_date
         )
  VALUES
  ( sequ_spr_sms_stg.NEXTVAL          ,
    sms.esn                           ,
    sms.usage_percent                 ,
    sms.script_id                     ,
    sms.insert_timestamp ,
    sms.sent_date
  );
  --
  sms.status := 'SUCCESS';
  --
  RETURN sms;
 EXCEPTION
   WHEN others THEN
    sms.status := 'UNHANDLED ERROR: ' || SQLERRM;
    RETURN sms;
END ins;

MEMBER FUNCTION exist ( i_esn  IN VARCHAR2 ) RETURN BOOLEAN AS

  sms spr_sms_stg_type := spr_sms_stg_type ( i_esn => i_esn );

BEGIN
  IF sms.spr_sms_stg_id IS NOT NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END exist;

MEMBER FUNCTION upd ( i_esn              IN VARCHAR2 ,
                      i_usage_percent    IN NUMBER   ,
                      i_script_id        IN VARCHAR2 ,
                      i_insert_timestamp IN DATE     ,
                      i_sent_date        IN DATE     ) RETURN BOOLEAN AS

  sms spr_sms_stg_type := spr_sms_stg_type ( i_esn => i_esn );

BEGIN
  IF i_esn IS NULL THEN
    sms.status := 'ESN NOT FOUND';
    RETURN FALSE;
  END IF;

  IF sms.spr_sms_stg_id IS NULL THEN
    sms.status := 'RECORD NOT FOUND';
    RETURN FALSE;
  END IF;

  UPDATE x_spr_sms_stg
  SET    usage_percent    = i_usage_percent,
         script_id        = i_script_id,
         insert_timestamp = i_insert_timestamp,
         sent_date        = i_sent_date
  WHERE  objid = sms.spr_sms_stg_id;

  -- TODO: Implementation for FUNCTION SPR_SMS_STG_TYPE.upd
  RETURN TRUE;
END upd;

MEMBER FUNCTION del ( i_esn IN VARCHAR2 ) RETURN BOOLEAN AS

  sms spr_sms_stg_type := spr_sms_stg_type ( i_esn => i_esn );

BEGIN
  IF sms.spr_sms_stg_id IS NOT NULL THEN
    --
    DELETE x_spr_sms_stg
    WHERE  objid = sms.spr_sms_stg_id;
    --
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END del;

END;
/