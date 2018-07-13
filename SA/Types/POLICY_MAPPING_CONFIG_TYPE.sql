CREATE OR REPLACE TYPE sa."POLICY_MAPPING_CONFIG_TYPE" AS OBJECT
( objid                     NUMBER(22),
  parent_name               VARCHAR2(30),
  cos                       VARCHAR2(30),
  threshold                 NUMBER(12,2),
  syniverse_policy          VARCHAR2(1),
  usage_tier_id             NUMBER(2,0),
  usage_percentage          NUMBER(5,2),
  entitlement               VARCHAR2(30),
  policy_objid              NUMBER(22),
  policy_name               VARCHAR2(30),
  inactive_flag             VARCHAR2(1) ,
  throttle_transact_type    VARCHAR2(30),
  throttle_transact_status  VARCHAR2(20),
  varchar2_value            VARCHAR2(1000),
  numeric_value             NUMBER,
  status                    VARCHAR2(1000),
CONSTRUCTOR FUNCTION policy_mapping_config_type RETURN SELF AS RESULT,
CONSTRUCTOR FUNCTION policy_mapping_config_type ( i_cos           IN  VARCHAR2 ,
                                                  i_parent_name   IN  VARCHAR2 ,
                                                  i_usage_tier_id IN  NUMBER   ,
                                                  i_entitlement   IN  VARCHAR2 DEFAULT 'DEFAULT'
                                                 ) RETURN SELF AS RESULT,
MEMBER FUNCTION get_policy_id ( i_policy_name IN VARCHAR2 ) RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY sa."POLICY_MAPPING_CONFIG_TYPE" AS

CONSTRUCTOR FUNCTION policy_mapping_config_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END policy_mapping_config_type;

CONSTRUCTOR FUNCTION policy_mapping_config_type ( i_cos           IN  VARCHAR2 ,
                                                  i_parent_name   IN  VARCHAR2 ,
                                                  i_usage_tier_id IN  NUMBER   ,
                                                  i_entitlement   IN  VARCHAR2 DEFAULT 'DEFAULT' ) RETURN SELF AS RESULT AS

  pm policy_mapping_config_type := policy_mapping_config_type ();

BEGIN
  -- set entitlement from parameter
  pm.entitlement := i_entitlement;

  --
  IF i_cos IS NULL THEN
    SELF.status:= 'COS INPUT PARAMETER NOT FOUND';
    RETURN ;
  END IF;
  --
  IF i_parent_name IS NULL THEN
    SELF.status:= 'PARENT NAME INPUT PARAMETER NOT FOUND';
    RETURN ;
  END IF;
  --
  IF i_usage_tier_id IS NULL THEN
    SELF.status:= 'USAGE TIER ID INPUT PARAMETER NOT FOUND';
    RETURN ;
  END IF;

  -- set the short parent name to get the correct policy configuration (in case they pass the complete parent name)
  SELF.parent_name := util_pkg.get_short_parent_name ( i_parent_name => i_parent_name );

  --
  IF pm.entitlement IS NULL OR pm.entitlement = 'DEFAULT' THEN
    BEGIN
      SELECT entitlement
      INTO   pm.entitlement
      FROM   x_policy_mapping_config pmc
      WHERE  parent_name = SELF.parent_name --i_parent_name --CR44107 changed to SELF.parent_name
      AND    cos = i_cos
      AND    usage_tier_id = i_usage_tier_id
      AND    inactive_flag = 'N'
      AND    objid IN ( SELECT MAX(objid)
                        FROM   x_policy_mapping_config
                        WHERE  parent_name = pmc.parent_name
                        AND    cos = pmc.cos
                        AND    usage_tier_id = pmc.usage_tier_id
                        AND    inactive_flag = 'N'
                      );
     EXCEPTION
       WHEN others THEN
         NULL;
    END;
    --
  END IF;
  -- set the short parent name to get the correct policy configuration (in case they pass the complete parent name)
  --SELF.parent_name := util_pkg.get_short_parent_name ( i_parent_name => i_parent_name ); --CR44107 Moved up above If statement

  --
  BEGIN
    SELECT policy_mapping_config_type ( objid                    ,
                                        parent_name              ,
                                        cos                      ,
                                        threshold                ,
                                        syniverse_policy         ,
                                        usage_tier_id            ,
                                        NULL                     , -- usage_percentage
                                        entitlement              ,
                                        policy_objid             ,
                                        NULL                     , -- policy_name
                                        inactive_flag            ,
                                        throttle_transact_type   ,
                                        throttle_transact_status ,
                                        NULL                     , -- varchar2
                                        NULL                     , -- setting temporary numeric variable as null here
                                        NULL                       -- setting status as null here
                                      )
    INTO   SELF
    FROM   x_policy_mapping_config
    WHERE  cos = i_cos
    AND    parent_name = SELF.parent_name
    AND    usage_tier_id = i_usage_tier_id
    AND    entitlement = pm.entitlement
    AND    inactive_flag = 'N'; -- Only return active mapping row
   EXCEPTION
     WHEN no_data_found THEN
       -- Discard the entitlement parameters and just search by parent and cos
            -- Return input variables to the type
            SELF.cos           := i_cos           ;
            SELF.parent_name   := SELF.parent_name   ;
            SELF.usage_tier_id := i_usage_tier_id ;
            SELF.entitlement   := i_entitlement   ;
            SELF.status:= 'POLICY NOT FOUND FOR THE PROVIDED INPUT PARAMETERS';
            RETURN;
     WHEN too_many_rows THEN
       -- Return input variables to the type
       SELF.cos           := i_cos           ;
       SELF.parent_name   := SELF.parent_name   ;
       SELF.usage_tier_id := i_usage_tier_id ;
       SELF.entitlement   := pm.entitlement   ;
       SELF.status:= 'DUPLICATE POLICIES FOUND';
       RETURN;
     WHEN others THEN
       -- Return input variables to the type
       SELF.cos           := i_cos           ;
       SELF.parent_name   := SELF.parent_name   ;
       SELF.usage_tier_id := i_usage_tier_id ;
       SELF.entitlement   := i_entitlement   ;
       SELF.status:= 'POLICIES NOT FOUND: '|| SQLERRM;
       RETURN;
  END;

  BEGIN
    SELECT usage_percentage
    INTO   self.usage_percentage
    FROM   x_usage_tier
    WHERE  usage_tier_id = i_usage_tier_id;
   EXCEPTION
    WHEN OTHERS THEN
      -- Do nothing; Continue when the usage tier was not found
      NULL;
  END;

  --
  IF SELF.policy_objid IS NOT NULL THEN
    BEGIN
      SELECT x_policy_name
      INTO   SELF.policy_name
      FROM   w3ci.table_x_throttling_policy
      WHERE  objid = SELF.policy_objid;
     EXCEPTION
      WHEN OTHERS THEN
        -- Do nothing; Continue when the policy name was not found
        NULL;
    END;
  END IF;

  self.status := 'SUCCESS';
  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
	  -- Return input variables to the type
      SELF.cos           := i_cos           ;
      SELF.parent_name   := SELF.parent_name   ;
      SELF.usage_tier_id := i_usage_tier_id ;
      SELF.entitlement   := pm.entitlement  ;
      SELF.status := 'POLICY MAPPING NOT FOUND' || SUBSTR(SQLERRM,1,100);
      RETURN;
END policy_mapping_config_type;

MEMBER FUNCTION get_policy_id ( i_policy_name IN VARCHAR2 ) RETURN NUMBER AS
  pd  policy_mapping_config_type := SELF;
BEGIN
  BEGIN
    SELECT objid
    INTO   pd.policy_objid
    FROM   w3ci.table_x_throttling_policy
    WHERE  x_policy_name = i_policy_name;
   EXCEPTION
     WHEN no_data_found THEN
       RETURN 0;
     WHEN others THEN
       RETURN -1;
  END;
  RETURN pd.policy_objid;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN -1;
END get_policy_id;

END;
/