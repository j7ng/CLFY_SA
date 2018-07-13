CREATE OR REPLACE TYPE sa.ig_transaction_features_type AS OBJECT
(
  transaction_features_objid     NUMBER         ,
  transaction_id                 NUMBER         ,
  feature_name                   VARCHAR2(1000) ,
  feature_value                  VARCHAR2(1000) ,
  feature_requirement            VARCHAR2(3)    ,
  throttle_status_code           VARCHAR2(20)   ,
  toggle_flag                    VARCHAR2(1)    ,
  response                       VARCHAR2(1000) ,
  display_sui_flag               VARCHAR2(1)    ,
  restrict_sui_flag              VARCHAR2(1)    ,
  cf_profile_id                  NUMBER         ,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION ig_transaction_features_type RETURN SELF AS RESULT,
  -- Constructor used to initialize
  CONSTRUCTOR FUNCTION ig_transaction_features_type ( i_transaction_features_objid IN NUMBER ) RETURN SELF AS RESULT,
  -- Constructor used to initialize
  CONSTRUCTOR FUNCTION ig_transaction_features_type ( i_transaction_features_objid IN NUMBER   ,
                                                      i_transaction_id             IN NUMBER   ,
                                                      i_feature_name               IN VARCHAR2 ,
                                                      i_feature_value              IN VARCHAR2 ,
                                                      i_feature_requirement        IN VARCHAR2 ,
                                                      i_throttle_status_code       IN VARCHAR2 ,
                                                      i_toggle_flag                IN VARCHAR2 ,
                                                      i_display_sui_flag           IN VARCHAR2 ,
                                                      i_restrict_sui_flag          IN VARCHAR2 ,
                                                      i_cf_profile_id              IN NUMBER
                                                      ) RETURN SELF AS RESULT,
  --
  MEMBER FUNCTION ins ( i_igf IN ig_transaction_features_type ) RETURN ig_transaction_features_type
);
/
CREATE OR REPLACE TYPE BODY sa.ig_transaction_features_type IS
--
CONSTRUCTOR FUNCTION ig_transaction_features_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

--
CONSTRUCTOR FUNCTION ig_transaction_features_type ( i_transaction_features_objid IN NUMBER ) RETURN SELF AS RESULT IS
BEGIN
  --
  IF i_transaction_features_objid IS NULL THEN
    SELF.response := 'TRANSACTION FEATURE ID NOT PASSED';
    RETURN;
  END IF;

  --
  SELECT ig_transaction_features_type ( objid                ,
                                        transaction_id       ,
                                        feature_name         ,
                                        feature_value        ,
                                        feature_requirement  ,
                                        throttle_status_code ,
                                        toggle_flag          ,
                                        NULL                 , -- response
                                        display_sui_flag     ,
                                        restrict_sui_flag    ,
                                        cf_profile_id
                                      )
  INTO   SELF
  FROM   gw1.ig_transaction_features
  WHERE  objid = i_transaction_features_objid;

  SELF.response := 'SUCCESS';
  --
  RETURN;

 EXCEPTION
   WHEN others THEN
     SELF.response := 'TRANSACTION FEATURE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     SELF.transaction_features_objid := i_transaction_features_objid;
     RETURN;
END;

CONSTRUCTOR FUNCTION ig_transaction_features_type ( i_transaction_features_objid IN NUMBER   ,
                                                    i_transaction_id             IN NUMBER   ,
                                                    i_feature_name               IN VARCHAR2 ,
                                                    i_feature_value              IN VARCHAR2 ,
                                                    i_feature_requirement        IN VARCHAR2 ,
                                                    i_throttle_status_code       IN VARCHAR2 ,
                                                    i_toggle_flag                IN VARCHAR2 ,
                                                    i_display_sui_flag           IN VARCHAR2 ,
                                                    i_restrict_sui_flag          IN VARCHAR2 ,
                                                    i_cf_profile_id              IN NUMBER
                                                   ) RETURN SELF AS RESULT IS

BEGIN

  SELF.transaction_features_objid := i_transaction_features_objid;
  SELF.transaction_id             := i_transaction_id            ;
  SELF.feature_name               := i_feature_name              ;
  SELF.feature_value              := i_feature_value             ;
  SELF.feature_requirement        := i_feature_requirement       ;
  SELF.throttle_status_code       := i_throttle_status_code      ;
  SELF.toggle_flag                := i_toggle_flag               ;
  SELF.display_sui_flag           := i_display_sui_flag          ;
  SELF.restrict_sui_flag          := i_restrict_sui_flag         ;
  SELF.cf_profile_id              := i_cf_profile_id             ;

  SELF.response := 'SUCCESS';
  --
  RETURN;

 EXCEPTION
   WHEN others THEN
     SELF.response := 'ERROR INSTANTIATING TRANSACTION FEATURE: ' || SUBSTR(SQLERRM,1,100);
     SELF.transaction_features_objid := i_transaction_features_objid;
     SELF.transaction_id             := i_transaction_id            ;
     SELF.feature_name               := i_feature_name              ;
     SELF.feature_value              := i_feature_value             ;
     SELF.feature_requirement        := i_feature_requirement       ;
     SELF.throttle_status_code       := i_throttle_status_code      ;
     SELF.toggle_flag                := i_toggle_flag               ;
     SELF.display_sui_flag           := i_display_sui_flag          ;
     SELF.restrict_sui_flag          := i_restrict_sui_flag         ;
     SELF.cf_profile_id              := i_cf_profile_id             ;
     RETURN;
END;

-- Procedure to add the row based on ESN or MIN with all the proper validations.
MEMBER FUNCTION ins ( i_igf IN ig_transaction_features_type ) RETURN ig_transaction_features_type IS

  igf  ig_transaction_features_type := i_igf;

BEGIN

  --
  IF igf.transaction_features_objid IS NULL THEN
    igf.transaction_features_objid := gw1.trans_id_seq.NEXTVAL;
  END IF;

  --
  INSERT
  INTO   gw1.ig_transaction_features
         ( objid                ,
           transaction_id       ,
           feature_name         ,
           feature_value        ,
           feature_requirement  ,
           throttle_status_code ,
           toggle_flag          ,
           display_sui_flag     ,
           restrict_sui_flag    ,
           cf_profile_id
         )
  VALUES
  ( igf.transaction_features_objid ,
    igf.transaction_id             ,
    igf.feature_name               ,
    igf.feature_value              ,
    igf.feature_requirement        ,
    igf.throttle_status_code       ,
    igf.toggle_flag                ,
    igf.display_sui_flag           ,
    igf.restrict_sui_flag          ,
    igf.cf_profile_id
  );

   --
  RETURN igf;

 EXCEPTION WHEN OTHERS THEN
   igf.response := igf.response || '|ERROR INSERTING IG TRANSACTION FEATURES RECORD: ' || SUBSTR(SQLERRM,1,100);
   --
   RETURN igf;
END ins;

END;
/