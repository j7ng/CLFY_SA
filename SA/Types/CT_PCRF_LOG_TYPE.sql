CREATE OR REPLACE TYPE sa.ct_pcrf_log_type AS OBJECT (
  call_trans_objid                NUMBER          ,
  processed_timestamp             DATE            ,
  response                        VARCHAR2(1000)  ,
  exist_flag                      VARCHAR2(1)     ,
  numeric_value                   NUMBER          ,
  varchar2_value                  VARCHAR2(2000)  ,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION ct_pcrf_log_type RETURN SELF AS RESULT,
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION ct_pcrf_log_type ( i_call_trans_objid IN NUMBER ) RETURN SELF AS RESULT,
  -- Function used to delete a row with the transaction_id
  MEMBER FUNCTION del ( i_call_trans_objid IN NUMBER ) RETURN ct_pcrf_log_type,
  -- Function used to get the case attributes
  MEMBER FUNCTION del ( i_rowid IN VARCHAR2 ) RETURN ct_pcrf_log_type,
  -- validate if a record exists in the event gateway table
  MEMBER FUNCTION exist RETURN BOOLEAN,
  -- validate if a record exists in the event gateway table
  MEMBER FUNCTION exist ( i_call_trans_objid IN NUMBER ) RETURN BOOLEAN,
  -- Function used to get the case attributes
  MEMBER FUNCTION get RETURN ct_pcrf_log_type,
  -- Function used to get the case attributes by objid
  MEMBER FUNCTION get ( i_call_trans_objid IN NUMBER ) RETURN ct_pcrf_log_type,
  -- Function used to insert a case
  MEMBER FUNCTION ins RETURN ct_pcrf_log_type,
  -- Function used to insert a case
  MEMBER FUNCTION ins ( i_call_trans_objid IN NUMBER ) RETURN ct_pcrf_log_type,
  -- Function used to save a case
  MEMBER FUNCTION merge ( i_ctpl IN OUT ct_pcrf_log_type ) RETURN VARCHAR2,
  -- Function used to save a case
  MEMBER FUNCTION save ( i_ctpl IN OUT ct_pcrf_log_type ) RETURN VARCHAR2,
  -- Function used to save a case
  MEMBER FUNCTION save RETURN ct_pcrf_log_type,
  -- Function used to save a case
  MEMBER FUNCTION upd RETURN ct_pcrf_log_type
);
/
CREATE OR REPLACE TYPE BODY sa.ct_pcrf_log_type IS
-- constructor used to initialize the entire type
CONSTRUCTOR FUNCTION ct_pcrf_log_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END;

--
CONSTRUCTOR FUNCTION ct_pcrf_log_type ( i_call_trans_objid IN NUMBER ) RETURN SELF AS RESULT AS
BEGIN

  BEGIN
    SELECT ct_pcrf_log_type ( call_trans_objid    ,
                              processed_timestamp ,
                              NULL                ,
                              NULL                ,
                              NULL                ,
                              NULL
                            )
    INTO   SELF
    FROM   sa.x_ct_pcrf_log
    WHERE  call_trans_objid = i_call_trans_objid;
   EXCEPTION
     WHEN OTHERS THEN
       SELF.call_trans_objid := i_call_trans_objid;
       SELF.response := 'CT PCRF LOG NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
       RETURN;
  END;

  --
  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.call_trans_objid := i_call_trans_objid;
     SELF.response := 'CT PCRF LOG NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END;

-- Function used to delete a EVENT GATEWAY with the EVENT GATEWAY objid
MEMBER FUNCTION del ( i_call_trans_objid IN NUMBER ) RETURN ct_pcrf_log_type AS

  e  ct_pcrf_log_type := ct_pcrf_log_type();

BEGIN

  e.call_trans_objid := i_call_trans_objid;

  --
  IF e.call_trans_objid IS NULL THEN
    e.response := 'CALL TRANS ID NOT PASSED';
    RETURN e;
  END IF;

  --
  DELETE sa.x_ct_pcrf_log
  WHERE  call_trans_objid = e.call_trans_objid
  RETURNING processed_timestamp
  INTO e.processed_timestamp;

  --
  e.response := 'SUCCESS';

  --
  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'CT PCRF LOG NOT DELETED: ' || SUBSTR(SQLERRM,1,100);
     RETURN e;
END del;

-- Function used to expire a EVENT GATEWAY with the EVENT GATEWAY objid
MEMBER FUNCTION del ( i_rowid IN VARCHAR2 ) RETURN ct_pcrf_log_type AS

  e  ct_pcrf_log_type := ct_pcrf_log_type();

BEGIN

  --
  IF i_rowid IS NULL THEN
    e.response := 'ROWID NOT PASSED';
    RETURN e;
  END IF;

  --
  DELETE sa.x_ct_pcrf_log
  WHERE  ROWID = i_rowid
  RETURNING processed_timestamp
  INTO e.processed_timestamp;

  --
  e.response := 'SUCCESS';

  --
  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'CT PCRF LOG NOT DELETED: ' || SUBSTR(SQLERRM,1,100);
     RETURN e;
END del;

MEMBER FUNCTION exist RETURN BOOLEAN AS

  e  ct_pcrf_log_type;


BEGIN

  -- return false when the required parameters are not passed to the constructor
  IF SELF.call_trans_objid IS NULL THEN
    RETURN FALSE;
  END IF;

  -- call constructor to find the data by call_trans_objid
  e  := ct_pcrf_log_type ( i_call_trans_objid => SELF.call_trans_objid );

  -- if the objid is available then the record exists
  IF e.processed_timestamp IS NOT NULL THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

END exist;

-- Validate if a subscriber exists in the subscriber table
MEMBER FUNCTION exist ( i_call_trans_objid IN NUMBER ) RETURN BOOLEAN AS

  e  ct_pcrf_log_type;

  ig  sa.ig_transaction_type := sa.ig_transaction_type ();

  igp sa.ig_pcrf_log_type;

BEGIN

  -- return false when the required parameters are not passed
  IF i_call_trans_objid IS NULL THEN
    RETURN FALSE;
  END IF;

  -- call constructor to find the data by esn and action
  e := ct_pcrf_log_type ( i_call_trans_objid => i_call_trans_objid );

  -- call to ig_transaction type to get ig trnasaction id
  ig.transaction_id := ig.get_ig_transaction_id ( i_call_trans_ojid => i_call_trans_objid );

  -- call ig_pcrf_log_type to check the transaction already processed or not
  igp := sa.ig_pcrf_log_type (i_transaction_id => ig.transaction_id );

  -- if the objid is available then the record exists
  IF e.processed_timestamp IS NOT NULL OR igp.processed_timestamp IS NOT NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END exist;

-- Function used to expire a EVENT GATEWAY with the EVENT GATEWAY objid
MEMBER FUNCTION get RETURN ct_pcrf_log_type AS

  e  ct_pcrf_log_type := SELF;

BEGIN

  --
  IF e.call_trans_objid IS NULL THEN
    e.response := 'CALL TRANS ID NOT PASSED';
    RETURN e;
  END IF;

  --
  e := ct_pcrf_log_type ( i_call_trans_objid => e.call_trans_objid );

  --
  e.response := 'SUCCESS';

  --
  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'CT PCRF LOG NOT EXPIRED: ' || SUBSTR(SQLERRM,1,100);
     RETURN e;
END get;

-- Function used to expire a EVENT GATEWAY
MEMBER FUNCTION get ( i_call_trans_objid IN NUMBER ) RETURN ct_pcrf_log_type AS

  e  ct_pcrf_log_type := ct_pcrf_log_type ();

BEGIN
  --
  e.call_trans_objid := i_call_trans_objid;

  --
  IF call_trans_objid IS NULL THEN
    e.response := 'CALL TRANS ID NOT PASSED';
    RETURN e;
  END IF;

  --
  e.response := 'SUCCESS';

  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'CALL TRANS ID NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN e;
END get;

-- Function used to get the code configuration for a sim
MEMBER FUNCTION ins RETURN ct_pcrf_log_type AS

  eg  ct_pcrf_log_type := SELF;

BEGIN

  -- validate call_trans_objid
  IF eg.call_trans_objid IS NULL THEN
    eg.response := 'CALL TRANS ID NOT PASSED';
    RETURN eg;
  END IF;

  --
  eg.response := eg.save ( i_ctpl => eg );

  -- return the row type
  RETURN eg;


 EXCEPTION
   WHEN others THEN
     eg.response := 'ERROR INSERTING CT PCRF LOG: ' || SQLERRM;
     RETURN eg;
END ins;

-- Function used to get the code configuration for a sim
MEMBER FUNCTION ins ( i_call_trans_objid IN NUMBER ) RETURN ct_pcrf_log_type AS

  cpl ct_pcrf_log_type := ct_pcrf_log_type ();
  cp  ct_pcrf_log_type := ct_pcrf_log_type ();

BEGIN

  --
  cpl := ct_pcrf_log_type ( i_call_trans_objid => i_call_trans_objid );

  cp := cpl.ins;

  -- return the row type
  RETURN cp;

 EXCEPTION
   WHEN others THEN
     cp.response := 'ERROR INSERTING CT PCRF LOG: ' || SQLERRM;
     RETURN cp;
END ins;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION merge ( i_ctpl IN OUT ct_pcrf_log_type ) RETURN VARCHAR2 AS

  e  ct_pcrf_log_type := ct_pcrf_log_type ();

BEGIN

  -- insert statement goes here
  BEGIN
    MERGE
    INTO   sa.x_ct_pcrf_log s
    USING  dual
    ON     ( s.call_trans_objid = i_ctpl.call_trans_objid )
    WHEN MATCHED THEN
      UPDATE
      SET    s.call_trans_objid = i_ctpl.call_trans_objid
    WHEN NOT MATCHED THEN
      INSERT ( s.call_trans_objid )
        VALUES
        ( i_ctpl.call_trans_objid );
   EXCEPTION
    WHEN others then
      RETURN('ERROR MERGING CT PCRF LOG DATA: ' || SQLERRM);
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row merged in CT PCRF LOG for CALL TRANS ID (' || i_ctpl.call_trans_objid || ')');

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING CT PCRF LOG RECORD: ' || SQLERRM;
     --
END merge;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save ( i_ctpl IN OUT ct_pcrf_log_type ) RETURN VARCHAR2 AS

  e  ct_pcrf_log_type := ct_pcrf_log_type ( i_call_trans_objid => i_ctpl.call_trans_objid );

BEGIN

  -- validate if an event gateway already exists for the esn and action combination
  IF e.exist THEN
    RETURN('CT PCRF LOG DUPLICATE ROW');
  END IF;

  -- insert statement
  BEGIN
      INSERT
      INTO   sa.x_ct_pcrf_log
             ( call_trans_objid )
      VALUES
      ( i_ctpl.call_trans_objid );
   EXCEPTION
    WHEN dup_val_on_index then
      RETURN('DUPLICATE ROWS IN ct PCRF LOG DATA');
    WHEN others then
      RETURN('ERROR INSERTING ct PCRF LOG DATA: ' || SQLERRM);
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in ct PCRF LOG for CALL TRANS ID (' || i_ctpl.call_trans_objid || ')');

  RETURN('SUCCESS');

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'ERROR SAVING ct PCRF LOG RECORD: ' || SQLERRM;
     --
END save;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION save RETURN ct_pcrf_log_type AS

  c  ct_pcrf_log_type := SELF;

BEGIN


  -- insert goes here
  BEGIN
    NULL;
   EXCEPTION
    WHEN dup_val_on_index then
      c.response := 'DUPLICATE VALUE INSERTING INTO ct PCRF LOG';
      RETURN c;
  END;

  DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in ct PCRF LOG (' || c.call_trans_objid || ')');

  --
  c.response := 'SUCCESS';

  RETURN c;

 EXCEPTION
   WHEN OTHERS THEN
     c.response := 'ERROR SAVING ct PCRF LOG RECORD: ' || SQLERRM;
     RETURN c;
     --
END save;

-- Function used to get the code configuration for an esn
MEMBER FUNCTION upd RETURN ct_pcrf_log_type AS

  e  ct_pcrf_log_type := SELF;

BEGIN

  IF e.call_trans_objid IS NULL THEN
    e.response := 'CALL TRANS ID NOT PASSED';
    RETURN e;
  END IF;

  -- insert goes here
  BEGIN
    UPDATE sa.x_ct_pcrf_log
    SET    call_trans_objid = e.call_trans_objid
    WHERE  call_trans_objid = e.call_trans_objid
    RETURNING call_trans_objid,
              processed_timestamp
    INTO      e.call_trans_objid,
              e.processed_timestamp;
   EXCEPTION
    WHEN others then
      e.response := 'ERROR UPDATING ct PCRF LOG: ' || SQLERRM;
      RETURN e;
  END;

  --DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row updated in CALL TRANS PCRF LOG (' || e.call_trans_objid || ')');

  --
  e.response := 'SUCCESS';

  RETURN e;

 EXCEPTION
   WHEN OTHERS THEN
     e.response := 'ERROR SAVING ct PCRF LOG RECORD: ' || SQLERRM;
     RETURN e;
     --
END upd;

--
END;
/