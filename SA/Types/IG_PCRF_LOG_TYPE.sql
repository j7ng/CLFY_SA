CREATE OR REPLACE TYPE sa.ig_pcrf_log_type AS OBJECT (
  transaction_id                  NUMBER          ,
  processed_timestamp             DATE            ,
  response                        VARCHAR2(1000)  ,
  exist_flag                      VARCHAR2(1)     ,
  numeric_value                   NUMBER          ,
  varchar2_value                  VARCHAR2(2000)  ,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION ig_pcrf_log_type RETURN SELF AS RESULT,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION ig_pcrf_log_type ( i_transaction_id IN NUMBER ) RETURN SELF AS RESULT,
  -- Function used to delete a row with the transaction_id
  MEMBER FUNCTION del ( i_transaction_id IN NUMBER ) RETURN ig_pcrf_log_type,
  -- Function used to get the case attributes
  MEMBER FUNCTION del ( i_rowid IN VARCHAR2 ) RETURN ig_pcrf_log_type,
  -- validate if a record exists in the event gateway table
  MEMBER FUNCTION exist RETURN BOOLEAN,
  -- validate if a record exists in the event gateway table
  MEMBER FUNCTION exist ( i_transaction_id IN NUMBER ) RETURN BOOLEAN,
  -- Function used to get the case attributes
  MEMBER FUNCTION get RETURN ig_pcrf_log_type,
  -- Function used to get the case attributes by objid
  MEMBER FUNCTION get ( i_transaction_id IN NUMBER ) RETURN ig_pcrf_log_type,
  -- Function used to insert a case
  MEMBER FUNCTION ins RETURN ig_pcrf_log_type,
  -- Function used to insert a case
  MEMBER FUNCTION ins ( i_transaction_id IN NUMBER ) RETURN ig_pcrf_log_type,
  -- Function used to save a case
  MEMBER FUNCTION merge ( i_igpl IN OUT ig_pcrf_log_type ) RETURN VARCHAR2,
  -- Function used to save a case
  MEMBER FUNCTION save ( i_igpl IN OUT ig_pcrf_log_type ) RETURN VARCHAR2,
  -- Function used to save a case
  MEMBER FUNCTION save RETURN ig_pcrf_log_type,
  -- Function used to save a case
  MEMBER FUNCTION upd RETURN ig_pcrf_log_type
);
/
CREATE OR REPLACE TYPE BODY sa.ig_pcrf_log_type IS
-- constructor used to initialize the entire type
CONSTRUCTOR FUNCTION ig_pcrf_log_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END;

--
CONSTRUCTOR FUNCTION ig_pcrf_log_type ( i_transaction_id IN NUMBER ) RETURN SELF AS RESULT AS
BEGIN

  BEGIN
    SELECT ig_pcrf_log_type ( transaction_id      ,
                              processed_timestamp ,
                              NULL                ,
                              NULL                ,
                              NULL                ,
                              NULL
                            )
    INTO   SELF
    FROM   sa.x_ig_pcrf_log
    WHERE  transaction_id = i_transaction_id;
   EXCEPTION
     WHEN OTHERS THEN
       SELF.transaction_id := i_transaction_id;
       SELF.response := 'IG PCRF LOG NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.transaction_id := i_transaction_id;
     SELF.response := 'IG PCRF LOG NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

-- Function used to delete a EVENT GATEWAY with the EVENT GATEWAY objid
MEMBER FUNCTION del ( i_transaction_id IN NUMBER ) RETURN ig_pcrf_log_type AS

  e  ig_pcrf_log_type := ig_pcrf_log_type();

BEGIN

  e.transaction_id := i_transaction_id;

  --
  IF e.transaction_id IS NULL THEN
    e.response := 'TRANSACTION ID NOT PASSED';
    RETURN e;
  END IF;

  --
  DELETE sa.x_ig_pcrf_log
  WHERE  transaction_id = e.transaction_id
  RETURNING processed_timestamp
  INTO e.processed_timestamp;

  --
  e.response := 'SUCCESS';

  --
  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'IG PCRF LOG NOT DELETED: ' || SUBSTR(SQLERRM,1,100);
     RETURN e;
END del;

-- Function used to expire a EVENT GATEWAY with the EVENT GATEWAY objid
MEMBER FUNCTION del ( i_rowid IN VARCHAR2 ) RETURN ig_pcrf_log_type AS

  e  ig_pcrf_log_type := ig_pcrf_log_type();

BEGIN

  --
  IF i_rowid IS NULL THEN
    e.response := 'ROWID NOT PASSED';
    RETURN e;
  END IF;

  --
  DELETE sa.x_ig_pcrf_log
  WHERE  ROWID = i_rowid
  RETURNING processed_timestamp
  INTO e.processed_timestamp;

  --
  e.response := 'SUCCESS';

  --
  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'IG PCRF LOG NOT DELETED: ' || SUBSTR(SQLERRM,1,100);
     RETURN e;
END del;

MEMBER FUNCTION exist RETURN BOOLEAN AS

  e  ig_pcrf_log_type;

BEGIN

  -- return false when the required parameters are not passed to the constructor
  IF SELF.transaction_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- call constructor to find the data by transaction_id
  e  := ig_pcrf_log_type ( i_transaction_id => SELF.transaction_id );

  -- if the objid is available then the record exists
  IF e.processed_timestamp IS NOT NULL THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

END exist;

-- Validate if a subscriber exists in the subscriber table
MEMBER FUNCTION exist ( i_transaction_id IN NUMBER ) RETURN BOOLEAN AS

  e   ig_pcrf_log_type;

  ctp ct_pcrf_log_type;

  ig  ig_transaction_type;

BEGIN

  -- return false when the required parameters are not passed
  IF i_transaction_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- call constructor to find the data by esn and action
  e   := ig_pcrf_log_type     (i_transaction_id => i_transaction_id );

  -- call ig_transaction_type to get the call trans objid
  ig  := ig_transaction_type (i_transaction_id => i_transaction_id );

  -- call ct_pcrf_log_type to check the transaction already processed or not
  ctp := ct_pcrf_log_type    (i_call_trans_objid => ig.call_trans_objid);

  -- if the objid is available then the record exists
  IF e.processed_timestamp IS NOT NULL OR ctp.processed_timestamp IS NOT NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END exist;

-- Function used to expire a EVENT GATEWAY with the EVENT GATEWAY objid
MEMBER FUNCTION get RETURN ig_pcrf_log_type AS

  e  ig_pcrf_log_type := SELF;

BEGIN

  --
  IF e.transaction_id IS NULL THEN
    e.response := 'TRANSACTION ID NOT PASSED';
    RETURN e;
  END IF;

  --
  e := ig_pcrf_log_type ( i_transaction_id => e.transaction_id );

  --
  e.response := 'SUCCESS';

  --
  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'IG PCRF LOG NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN e;
END get;

-- Function used to expire a EVENT GATEWAY
MEMBER FUNCTION get ( i_transaction_id IN NUMBER ) RETURN ig_pcrf_log_type AS

  e  ig_pcrf_log_type := ig_pcrf_log_type ();

BEGIN
  --
  e.transaction_id := i_transaction_id;

  --
  IF i_transaction_id IS NULL THEN
    e.response := 'TRANSACTION ID NOT PASSED';
    RETURN e;
  END IF;

  --
  e.response := 'SUCCESS';

  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'TRANSACTION ID NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN e;
END get;

-- Function used to get the code configuration for a sim
MEMBER FUNCTION ins RETURN ig_pcrf_log_type AS

  eg  ig_pcrf_log_type := SELF;

BEGIN

  -- validate transaction_id
  IF eg.transaction_id IS NULL THEN
    eg.response := 'TRANSACTION ID NOT PASSED';
    RETURN eg;
  END IF;

  --
  eg.response := eg.save ( i_igpl => eg );

  -- return the row type
  RETURN eg;


 EXCEPTION
   WHEN others THEN
     eg.response := 'ERROR INSERTING IG PCRF LOG: ' || SQLERRM;
     RETURN eg;
END ins;

-- Function used to get the code configuration for a sim
MEMBER FUNCTION ins ( i_transaction_id IN NUMBER ) RETURN ig_pcrf_log_type AS

  ipl ig_pcrf_log_type := ig_pcrf_log_type ();
  ip  ig_pcrf_log_type := ig_pcrf_log_type ();

BEGIN

  --
  ipl := ig_pcrf_log_type ( i_transaction_id => i_transaction_id );

  ip := ipl.ins;

  -- return the row type
  RETURN ip;

 EXCEPTION
   WHEN others THEN
     ip.response := 'ERROR INSERTING IG PCRF LOG: ' || SQLERRM;
     RETURN ip;
END ins;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION merge ( i_igpl IN OUT ig_pcrf_log_type ) RETURN VARCHAR2 AS

  e  ig_pcrf_log_type := ig_pcrf_log_type ();

BEGIN

  -- insert statement goes here
  BEGIN
    MERGE
    INTO   sa.x_ig_pcrf_log s
    USING  dual
    ON     ( s.transaction_id = i_igpl.transaction_id )
    WHEN MATCHED THEN
      UPDATE
      SET    s.transaction_id = i_igpl.transaction_id
    WHEN NOT MATCHED THEN
      INSERT ( s.transaction_id )
        VALUES
        ( i_igpl.transaction_id );
   EXCEPTION
    WHEN others then
      RETURN('ERROR MERGING IG PCRF LOG DATA: ' || SQLERRM);
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row merged in IG PCRF LOG for transaction_id (' || i_igpl.transaction_id || ')');

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING IG PCRF LOG RECORD: ' || SQLERRM;
     --
END merge;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save ( i_igpl IN OUT ig_pcrf_log_type ) RETURN VARCHAR2 AS

  e  ig_pcrf_log_type := ig_pcrf_log_type ( i_transaction_id => i_igpl.transaction_id );

BEGIN

  -- validate if an event gateway already exists for the esn and action combination
  IF e.exist THEN
    RETURN('IG PCRF LOG DUPLICATE ROW');
  END IF;

  -- insert statement
  BEGIN
      INSERT
      INTO   sa.x_ig_pcrf_log
             ( transaction_id )
      VALUES
      ( i_igpl.transaction_id );
   EXCEPTION
    WHEN dup_val_on_index then
      RETURN('DUPLICATE ROWS IN IG PCRF LOG DATA');
    WHEN others then
      RETURN('ERROR INSERTING IG PCRF LOG DATA: ' || SQLERRM);
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in IG PCRF LOG for TRANSACTION ID (' || i_igpl.transaction_id || ')');

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING IG PCRF LOG RECORD: ' || SQLERRM;
     --
END save;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save RETURN ig_pcrf_log_type AS

  c  ig_pcrf_log_type := SELF;

BEGIN


  -- insert goes here
  BEGIN
    NULL;
   EXCEPTION
    WHEN dup_val_on_index then
      c.response := 'DUPLICATE VALUE INSERTING INTO IG PCRF LOG';
      RETURN c;
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in IG PCRF LOG (' || c.transaction_id || ')');

  --
  c.response := 'SUCCESS';

  RETURN c;

 EXCEPTION
   WHEN OTHERS THEN
     c.response := 'ERROR SAVING IG PCRF LOG RECORD: ' || SQLERRM;
     RETURN c;
     --
END save;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION upd RETURN ig_pcrf_log_type AS

  e  ig_pcrf_log_type := SELF;

BEGIN

  IF e.transaction_id IS NULL THEN
    e.response := 'TRANSACTION ID NOT PASSED';
    RETURN e;
  END IF;

  -- insert goes here
  BEGIN
    UPDATE sa.x_ig_pcrf_log
    SET    transaction_id = e.transaction_id
    WHERE  transaction_id = e.transaction_id
    RETURNING transaction_id,
              processed_timestamp
    INTO      e.transaction_id,
              e.processed_timestamp;
   EXCEPTION
    WHEN others then
      e.response := 'ERROR UPDATING IG PCRF LOG: ' || SQLERRM;
      RETURN e;
  END;

  --DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row updated in EVENT GATEWAY (' || e.transaction_id || ')');

  --
  e.response := 'SUCCESS';

  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'ERROR SAVING IG PCRF LOG RECORD: ' || SQLERRM;
     RETURN e;
     --
END upd;

--
END;
/