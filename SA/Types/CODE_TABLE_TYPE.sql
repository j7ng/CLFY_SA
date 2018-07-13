CREATE OR REPLACE TYPE sa.CODE_TABLE_TYPE AS OBJECT (
  code_table_objid                NUMBER,
  code_name                       VARCHAR2(20),
  code_number                     VARCHAR2(20),
  code_type                       VARCHAR2(20),
  value                           NUMBER,
  text                            VARCHAR2(4000),
  action                          VARCHAR2(50),
  remove_account_group_flag       NUMBER(1),
  expire_acct_group_member_flag   VARCHAR2(1),
  expire_subscriber_flag          VARCHAR2(1),
  block_apn_creation_flag         VARCHAR2(1),
  migration_flag                  VARCHAR2(1),
  response                        VARCHAR2(1000),
  numeric_value                   NUMBER,
  varchar2_value                  VARCHAR2(2000),
  exist                           VARCHAR2(1),
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION code_table_type RETURN SELF AS RESULT,
  -- Constructor used to initialize the
  CONSTRUCTOR FUNCTION code_table_type ( i_code_table_objid IN NUMBER ) RETURN SELF AS RESULT,
  -- Constructor used to return code_table base on code number
  CONSTRUCTOR FUNCTION code_table_type ( i_code_number IN VARCHAR2 ) RETURN SELF AS RESULT,
  -- Function used to get the code configuration for a sim
  MEMBER FUNCTION get_sim_code_table_config ( i_part_serial_no IN VARCHAR2 ,
                                              i_esn            IN VARCHAR2 ,
                                              i_technology     IN VARCHAR2 ,
                                              i_code_name      IN VARCHAR2 ,
                                              i_code_type      IN VARCHAR2 ,
                                              i_carrier_mkt    IN NUMBER DEFAULT NULL) RETURN code_table_type,
  -- Function used to get the code configuration for an esn
  MEMBER FUNCTION get_esn_code_table_config ( i_code_name IN VARCHAR2 ,
                                              i_code_type IN VARCHAR2 ) RETURN code_table_type,
  -- Function used to get the code configuration for an esn
  MEMBER FUNCTION get_min_code_table_config ( i_min        IN VARCHAR2 ,
                                              i_technology IN VARCHAR2 ,
                                              i_code_name  IN VARCHAR2 ,
                                              i_code_type  IN VARCHAR2 ) RETURN code_table_type,
  -- member function to determine when a deact reason is applicable to the status rule
  MEMBER FUNCTION esn_deact_reason_exists ( i_deact_reason    IN VARCHAR2 ,
                                            i_esn_status_code IN VARCHAR2 ) RETURN VARCHAR2,
  -- local function to get the migration flag
  MEMBER FUNCTION get_migration_flag ( i_code_number IN VARCHAR2 ) RETURN VARCHAR2,
  -- member function to determine when a deact reason is applicable to the status rule
  MEMBER FUNCTION min_deact_reason_exists ( i_deact_reason    IN VARCHAR2 ,
                                            i_min_status_code IN VARCHAR2 ) RETURN VARCHAR2,
  -- member function to determine when a deact reason is applicable to the status rule
  MEMBER FUNCTION sim_deact_reason_exists ( i_deact_reason    IN VARCHAR2 ,
                                            i_sim_status_code IN VARCHAR2 ) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY sa.CODE_TABLE_TYPE IS
CONSTRUCTOR FUNCTION code_table_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

CONSTRUCTOR FUNCTION code_table_type ( i_code_table_objid IN NUMBER ) RETURN SELF AS RESULT IS
BEGIN
  BEGIN
    SELECT code_table_type ( objid                         ,
                             x_code_name                   ,
                             x_code_number                 ,
                             x_code_type                   ,
                             x_value                       ,
                             NULL                          ,
                             action                        ,
                             remove_account_group_flag     ,
                             expire_acct_group_member_flag ,
                             expire_subscriber_flag        ,
                             block_apn_creation_flag       ,
                             migration_flag                ,
                             NULL                          ,
                             NULL                          ,
                             NULL                          ,
			     NULL
                           )
    INTO   SELF
    FROM   table_x_code_table
    WHERE  objid = i_code_table_objid;
   EXCEPTION
     WHEN OTHERS THEN
       SELF.response := 'CODE TABLE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'CODE TABLE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

CONSTRUCTOR FUNCTION code_table_type ( i_code_number IN VARCHAR2 ) RETURN SELF AS RESULT IS
BEGIN
  BEGIN
    SELECT code_table_type ( objid                         ,
                             x_code_name                   ,
                             x_code_number                 ,
                             x_code_type                   ,
                             x_value                       ,
                             NULL                          ,
                             action                        ,
                             remove_account_group_flag     ,
                             expire_acct_group_member_flag ,
                             expire_subscriber_flag        ,
                             block_apn_creation_flag       ,
                             migration_flag                ,
                             NULL                          ,
                             NULL                          ,
                             NULL                          ,
			     NULL
                           )
    INTO   SELF
    FROM   table_x_code_table
    WHERE  x_code_number = i_code_number;
   EXCEPTION
     WHEN OTHERS THEN
       SELF.response := 'CODE TABLE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
   WHEN OTHERS THEN
     SELF.response := 'CODE TABLE NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;


-- Function used to get the code configuration for a sim
MEMBER FUNCTION get_sim_code_table_config ( i_part_serial_no IN VARCHAR2 ,
                                            i_esn            IN VARCHAR2 ,
                                            i_technology     IN VARCHAR2 ,
                                            i_code_name      IN VARCHAR2 ,
                                            i_code_type      IN VARCHAR2 ,
                                            i_carrier_mkt    IN NUMBER DEFAULT NULL
                                           ) RETURN code_table_type IS

  tct           code_table_type := code_table_type ();
  c_code_name   table_x_code_table.x_code_name%TYPE;
  v_parent_name VARCHAR2(10);        --CR57185
  --v_default_flag VARCHAR2(2) := 'N'; --CR57185
BEGIN

--CR57185 - SIM Rule changes start --{
  --v_parent_name := sa.customer_info.get_short_parent_name(i_esn);

  BEGIN --{
      SELECT sa.util_pkg.get_short_parent_name(i_parent_name => p.x_parent_name)
      INTO   v_parent_name
      FROM   table_x_parent p,
             table_x_carrier_group cg,
             table_x_carrier c
      WHERE  c.objid = i_carrier_mkt
      AND    c.carrier2carrier_group = cg.objid
      AND    cg.x_carrier_group2x_parent = p.objid
      AND    ROWNUM  <=1;
  EXCEPTION
  WHEN OTHERS THEN
   v_parent_name := NULL;
  END; --}

  DBMS_OUTPUT.PUT_LINE('v_parent_name: '||v_parent_name);
  BEGIN --{
   SELECT  CASE
               WHEN v_parent_name = 'TMO'
               THEN sim_status_tmo
               WHEN v_parent_name = 'ATT'
               THEN sim_status_att
               WHEN v_parent_name = 'VZW'
               THEN sim_status_vrz
               ELSE NULL
           END
   INTO    c_code_name
   FROM    sa.x_deact_reason_config
   WHERE   deact_reason = i_code_name;
  EXCEPTION
  WHEN OTHERS THEN
   c_code_name := NULL;
  END; --}
  DBMS_OUTPUT.PUT_LINE('yahooo!!! c_code_name: '||c_code_name);
--CR57185 - SIM Rule changes end --}
IF c_code_name IS NULL --CR57185
THEN --{
--DBMS_OUTPUT.PUT_LINE('Oops!! Default logic');
  -- gsm or cdma
  IF ( i_technology = 'GSM' OR
       sa.lte_service_pkg.is_esn_lte_cdma ( p_esn => i_part_serial_no  ) = 1
     )
  THEN
    -- temporary
    --DBMS_OUTPUT.PUT_LINE('GSM or CDMA');
    --
    BEGIN
      c_code_name := CASE
                       WHEN ( tct.sim_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                            i_sim_status_code => 'SIM EXPIRED|SIM RESERVED' ) = 'Y' ) AND
                            sa.device_util_pkg.is_connect ( h_esn => i_esn ) = 1
                       THEN ( CASE WHEN i_technology = 'GSM' THEN 'SIM EXPIRED' ELSE 'SIM RESERVED' END)
                       WHEN ( tct.sim_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                            i_sim_status_code => 'SIM EXPIRED|SIM NEW' ) = 'Y' ) AND
                            sa.device_util_pkg.is_connect ( h_esn => i_esn ) = 1
                       THEN ( CASE WHEN i_technology = 'GSM' THEN 'SIM EXPIRED' ELSE 'SIM NEW' END)
                       WHEN ( tct.sim_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                            i_sim_status_code => 'SIM NEW' ) = 'Y' ) THEN 'SIM NEW'
                       WHEN ( tct.sim_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                            i_sim_status_code => 'SIM VOID' ) = 'Y' ) THEN 'SIM VOID'
                       WHEN ( tct.sim_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                            i_sim_status_code => 'SIM RESERVED' ) = 'Y' ) THEN 'SIM RESERVED'
                       ELSE 'SIM RESERVED'
                     END;
     EXCEPTION
       WHEN others THEN
         c_code_name := NULL;
    END;
  -- other technologies
  ELSE
    -- temporary
    --DBMS_OUTPUT.PUT_LINE('NON-GSM or CDMA');
    -- set a default value for exceptions
    c_code_name := 'SIM RESERVED';
  END IF;
END IF; --}
  -- temporary
  --DBMS_OUTPUT.PUT_LINE('c_code_name : ' || c_code_name);
  --DBMS_OUTPUT.PUT_LINE('i_code_type : ' || i_code_type);

  -- get the code table configuration
  BEGIN
    SELECT objid                         ,
           x_code_name                   ,
           x_code_number                 ,
           x_code_type                   ,
           x_value                       ,
           x_text                        ,
           action                        ,
           remove_account_group_flag     ,
           expire_acct_group_member_flag ,
           expire_subscriber_flag        ,
           block_apn_creation_flag
    INTO   tct.code_table_objid              ,
           tct.code_name                     ,
           tct.code_number                   ,
           tct.code_type                     ,
           tct.value                         ,
           tct.text                          ,
           tct.action                        ,
           tct.remove_account_group_flag     ,
           tct.expire_acct_group_member_flag ,
           tct.expire_subscriber_flag        ,
           tct.block_apn_creation_flag
    FROM   table_x_code_table
    WHERE  x_code_name = c_code_name
    AND    x_code_type = i_code_type;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- override the expire_acct_group_member_flag and expire_subscriber_flag attributes
  BEGIN
    SELECT expire_member_flag,
           expire_subscriber_flag
    INTO   tct.expire_acct_group_member_flag,
           tct.expire_subscriber_flag
    FROM   x_deact_reason_config
    WHERE  deact_reason = i_code_name;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- set a default value
  tct.expire_acct_group_member_flag := NVL(tct.expire_acct_group_member_flag,'N');
  tct.expire_subscriber_flag := NVL(tct.expire_subscriber_flag,'N');

  tct.response := 'SUCCESS';

  -- return the row type
  RETURN tct;

 EXCEPTION
   WHEN others THEN
     tct.response := 'ERROR FINDING SIM CODE TABLE CONFIG: ' || SQLERRM;
     RETURN tct;
END get_sim_code_table_config;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION get_esn_code_table_config ( i_code_name IN VARCHAR2 ,
                                            i_code_type IN VARCHAR2 ) RETURN code_table_type IS
  tct           code_table_type := code_table_type ();
  c_code_number table_x_code_table.x_code_number%TYPE;

BEGIN
  --
  BEGIN
    c_code_number := CASE
                     WHEN ( tct.esn_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                          i_esn_status_code => '53' ) = 'Y' )
                     THEN '53'
                     WHEN ( tct.esn_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                          i_esn_status_code => '54' ) = 'Y' )
                     THEN '54'
                     WHEN ( tct.esn_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                          i_esn_status_code => '55' ) = 'Y' )
                     THEN '55'
                     WHEN ( tct.esn_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                          i_esn_status_code => '56' ) = 'Y' )
                     THEN '56'
                     WHEN ( tct.esn_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                          i_esn_status_code => '58' ) = 'Y' )
                     THEN '58'
                     WHEN ( tct.esn_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                          i_esn_status_code => '51' ) = 'Y' )
                     THEN '51'
                     WHEN ( tct.esn_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                          i_esn_status_code => '65' ) = 'Y' )
                     THEN '65'
                     ELSE '51'
                   END;
   EXCEPTION
     WHEN others THEN
       c_code_number := NULL;
  END;

  -- temporary
  --DBMS_OUTPUT.PUT_LINE('c_code_number : ' || c_code_number);
  --DBMS_OUTPUT.PUT_LINE('i_code_type : ' || i_code_type);

  -- get the code table configuration
  BEGIN
    SELECT objid                         ,
           x_code_name                   ,
           x_code_number                 ,
           x_code_type                   ,
           x_value                       ,
           x_text                        ,
           action                        ,
           remove_account_group_flag     ,
           expire_acct_group_member_flag ,
           expire_subscriber_flag        ,
           block_apn_creation_flag
    INTO   tct.code_table_objid              ,
           tct.code_name                     ,
           tct.code_number                   ,
           tct.code_type                     ,
           tct.value                         ,
           tct.text                          ,
           tct.action                        ,
           tct.remove_account_group_flag     ,
           tct.expire_acct_group_member_flag ,
           tct.expire_subscriber_flag        ,
           tct.block_apn_creation_flag
    FROM   table_x_code_table
    WHERE  x_code_number = c_code_number
    AND    x_code_type = i_code_type;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- override the expire_acct_group_member_flag and expire_subscriber_flag attributes
  BEGIN
    SELECT expire_member_flag,
           expire_subscriber_flag
    INTO   tct.expire_acct_group_member_flag,
           tct.expire_subscriber_flag
    FROM   x_deact_reason_config
    WHERE  deact_reason = i_code_name;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- set a default value
  tct.expire_acct_group_member_flag := NVL(tct.expire_acct_group_member_flag,'N');
  tct.expire_subscriber_flag := NVL(tct.expire_subscriber_flag,'N');

  -- return the row type
  RETURN tct;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_esn_code_table_config;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION get_min_code_table_config ( i_min        IN VARCHAR2 ,
                                            i_technology IN VARCHAR2 ,
                                            i_code_name  IN VARCHAR2 ,
                                            i_code_type  IN VARCHAR2 ) RETURN code_table_type IS

  tct          code_table_type := code_table_type ();
  c_code_name  table_x_code_table.x_code_name%TYPE;

  CURSOR cur_min IS
    SELECT pi.part_serial_no,
           NVL(pi.x_port_in,0) x_port_in,
           pi.x_part_inst_status,
           cr.x_line_return_days
    FROM   table_x_parent        p,
           table_x_carrier_group cg,
           table_x_carrier_rules cr,
           table_x_carrier       c,
           table_part_inst       pi
    WHERE  1 = 1
    AND    pi.part_serial_no = i_min
    AND    pi.x_domain = 'LINES'
    AND    c.objid = pi.part_inst2carrier_mkt
    AND    cg.objid = c.carrier2carrier_group
    AND    p.objid = cg.x_carrier_group2x_parent
    AND    cr.objid = DECODE(i_technology,'GSM',c.carrier2rules_gsm,'CDMA',c.carrier2rules_cdma,c.carrier2rules);

  rec_min    cur_min%ROWTYPE;

BEGIN
  -- get the required data related to the min
  OPEN cur_min;
  FETCH cur_min INTO rec_min;
  IF cur_min%NOTFOUND THEN
    CLOSE cur_min;
    RETURN NULL;
  END IF;
  CLOSE cur_min;

  -- gsm or cdma
  IF (SUBSTR(rec_min.part_serial_no ,1 ,1) = 'T') THEN
    --DBMS_OUTPUT.PUT_LINE('TMIN');
    c_code_name  := 'DELETED';
  ELSIF (rec_min.x_part_inst_status = '34') THEN
    --DBMS_OUTPUT.PUT_LINE('PART_INST_STATUS=34');
    c_code_name := 'AC VOIDED';
  ELSE
    -- temporary
    --DBMS_OUTPUT.PUT_LINE('ELSE');
    --
    BEGIN
      c_code_name := CASE
                       WHEN ( min_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                        i_min_status_code => 'RESERVED USED' ) = 'Y' )
                       THEN 'RESERVED USED'
                       WHEN ( min_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                        i_min_status_code => 'USED|RETURNED' ) = 'Y' )
                       THEN ( CASE WHEN rec_min.x_line_return_days = 0 THEN 'USED' ELSE 'RETURNED' END)
                       WHEN ( min_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                        i_min_status_code => 'RETURNED' ) = 'Y' )
                       THEN 'RETURNED'
                       WHEN ( min_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                        i_min_status_code => 'NTN' ) = 'Y' )
                       THEN 'NTN'
                       WHEN ( min_deact_reason_exists ( i_deact_reason    => i_code_name,
                                                        i_min_status_code => 'RESERVED USED|USED|RETURNED' ) = 'Y' )
                       THEN ( CASE
                                WHEN rec_min.x_port_in IN (1 ,2 ,3)
                                THEN 'RESERVED USED'
                                ELSE CASE
                                       WHEN rec_min.x_line_return_days = 0
                                       THEN 'USED'
                                       ELSE 'RETURNED'
                                     END
                                END )
                       ELSE 'RETURNED'
                     END;
     EXCEPTION
       WHEN others THEN
         c_code_name := NULL;
    END;
  END IF;

  -- temporary
  --DBMS_OUTPUT.PUT_LINE('c_code_name : ' || c_code_name);
  --DBMS_OUTPUT.PUT_LINE('i_code_type : ' || i_code_type);

  -- get the code table configuration
  BEGIN
    SELECT objid                         ,
           x_code_name                   ,
           x_code_number                 ,
           x_code_type                   ,
           x_value                       ,
           x_text                        ,
           action                        ,
           remove_account_group_flag     ,
           expire_acct_group_member_flag ,
           expire_subscriber_flag        ,
           block_apn_creation_flag
    INTO   tct.code_table_objid              ,
           tct.code_name                     ,
           tct.code_number                   ,
           tct.code_type                     ,
           tct.value                         ,
           tct.text                          ,
           tct.action                        ,
           tct.remove_account_group_flag     ,
           tct.expire_acct_group_member_flag ,
           tct.expire_subscriber_flag        ,
           tct.block_apn_creation_flag
    FROM   table_x_code_table
    WHERE  x_code_name = c_code_name
    AND    x_code_type = i_code_type;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- temporary
  --DBMS_OUTPUT.PUT_LINE('tct.expire_acct_group_member_flag : ' || tct.expire_acct_group_member_flag);
  --DBMS_OUTPUT.PUT_LINE('tct.expire_subscriber_flag        : ' || tct.expire_subscriber_flag);

  -- override the expire_acct_group_member_flag and expire_subscriber_flag attributes
  BEGIN
    SELECT expire_member_flag,
           expire_subscriber_flag
    INTO   tct.expire_acct_group_member_flag,
           tct.expire_subscriber_flag
    FROM   x_deact_reason_config
    WHERE  deact_reason = i_code_name;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- override the flag with YES if the line will be returned
  tct.expire_acct_group_member_flag := CASE tct.code_name
                                         WHEN 'RETURNED'
                                         THEN 'Y'
					 ELSE tct.expire_acct_group_member_flag
                                       END;

  -- set default value
  tct.expire_acct_group_member_flag := NVL(tct.expire_acct_group_member_flag,'N');

  -- set default value
  tct.expire_subscriber_flag := NVL(tct.expire_subscriber_flag,'N');

  -- return the row type
  RETURN tct;

 EXCEPTION
   WHEN others THEN
     RETURN NULL;
END get_min_code_table_config;

-- local function to determine when a deact reason is applicable to the status rule
MEMBER FUNCTION esn_deact_reason_exists ( i_deact_reason    IN VARCHAR2 ,
                                          i_esn_status_code IN VARCHAR2 ) RETURN VARCHAR2 IS

  tct code_table_type := code_table_type ();

BEGIN
  --
  BEGIN
    SELECT 'Y'
    INTO   tct.exist
    FROM   x_deact_reason_config
    WHERE  deact_reason = i_deact_reason
    AND    esn_status_code = i_esn_status_code;
   EXCEPTION
     WHEN too_many_rows THEN
       tct.exist := 'Y';
     WHEN others THEN
       tct.exist := 'N';
  END;

  --
  RETURN ( NVL(tct.exist,'N') );

 EXCEPTION
   WHEN OTHERS THEN
     RETURN ('N');
END esn_deact_reason_exists;

-- local function to get the migration flag
MEMBER FUNCTION get_migration_flag ( i_code_number IN VARCHAR2 ) RETURN VARCHAR2 IS
  tct code_table_type := code_table_type ();
BEGIN
  --
  BEGIN
    SELECT migration_flag
    INTO   tct.migration_flag
    FROM   table_x_code_table
    WHERE  x_code_number = i_code_number;
   EXCEPTION
     WHEN too_many_rows THEN
       tct.migration_flag := 'Y';
     WHEN others THEN
       tct.migration_flag := 'N';
  END;

  --
  RETURN ( NVL(tct.migration_flag,'N') );

 EXCEPTION
   WHEN OTHERS THEN
     RETURN ('N');
END get_migration_flag;

-- member function to determine when a deact reason is applicable to the status rule
MEMBER FUNCTION min_deact_reason_exists ( i_deact_reason    IN VARCHAR2 ,
                                          i_min_status_code IN VARCHAR2 ) RETURN VARCHAR2 IS
  tct code_table_type := code_table_type ();
BEGIN

  --
  BEGIN
    SELECT 'Y'
    INTO   tct.exist
    FROM   x_deact_reason_config
    WHERE  deact_reason = i_deact_reason
    AND    min_status_code = i_min_status_code;
   EXCEPTION
     WHEN too_many_rows THEN
       tct.exist := 'Y';
     WHEN others THEN
       tct.exist := 'N';
  END;

  --
  RETURN ( NVL(tct.exist,'N') );

 EXCEPTION
   WHEN OTHERS THEN
     RETURN ('N');
END min_deact_reason_exists;

-- local function to determine when a deact reason is applicable to the status rule
MEMBER FUNCTION sim_deact_reason_exists ( i_deact_reason    IN VARCHAR2 ,
                                          i_sim_status_code IN VARCHAR2 ) RETURN VARCHAR2 IS
  tct code_table_type := code_table_type ();
BEGIN
  --
  BEGIN
    SELECT 'Y'
    INTO   tct.exist
    FROM   x_deact_reason_config
    WHERE  deact_reason = i_deact_reason
    AND    sim_status_code = i_sim_status_code;
   EXCEPTION
     WHEN too_many_rows THEN
       tct.exist := 'Y';
     WHEN others THEN
       tct.exist := 'N';
  END;

  --
  RETURN ( NVL(tct.exist,'N') );
 EXCEPTION
   WHEN OTHERS THEN
     RETURN ('N');
END sim_deact_reason_exists;

--
END;
/