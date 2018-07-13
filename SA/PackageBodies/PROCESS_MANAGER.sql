CREATE OR REPLACE PACKAGE BODY sa."PROCESS_MANAGER" AS
--
-- Get the next objid for inserts - this is a private routine
--
PROCEDURE getnextobjid
(
 antypeid  IN NUMBER,  -- Database type_id (eg time_bomb=77)
 ancachedobjid  IN NUMBER,  -- Cached objid (unused from last time)
 annewobjid  OUT NUMBER  -- Returned objid
) AS

noffset NUMBER;  -- 2^28 * site_id
nobjnum NUMBER;  -- Next sequence number from adp_tbl_oid

BEGIN
 IF ancachedobjid = 0 THEN
  -- Get next objid from adp_tbl_oid
  UPDATE adp_tbl_oid SET obj_num = obj_num + 1
  WHERE type_id = antypeid;

  SELECT obj_num INTO nobjnum
  FROM adp_tbl_oid
  WHERE type_id = antypeid;

  -- Close transaction as quikcly as possible
  COMMIT WORK;

  SELECT site_id * 268435456 INTO noffset
  FROM adp_db_header;

  annewobjid := noffset + MOD( nobjnum, 268435456 );
 ELSE
  annewobjid := ancachedobjid;
 END IF;
END;

--
-- Insert a request pending row to the database - this is also a private routine
--
PROCEDURE insertrqstpending
(
 anrqstpendingobjid IN OUT NUMBER,
 anrqstinstobjid  IN NUMBER,
 anattrvalobjid  IN NUMBER,
 anisactivation  IN NUMBER
) AS

nobjid NUMBER;

CURSOR c_rqst_pending( nrqstinstobjid NUMBER, nattrvalobjid NUMBER ) IS
 SELECT objid
 FROM table_rqst_pending
 WHERE pending2rqst_inst = nrqstinstobjid AND  pending2n_attributevalue = nattrvalobjid;

BEGIN

-- See if there is already a rqst pending row
 OPEN c_rqst_pending( anrqstinstobjid, anattrvalobjid );

 FETCH c_rqst_pending INTO nobjid;

 IF c_rqst_pending%notfound THEN
         INSERT INTO table_rqst_pending
         (
          objid,start_time,is_activation,pending2rqst_inst,pending2n_attributevalue
         )
         VALUES
         (
          anrqstpendingobjid,sysdate,anisactivation,anrqstinstobjid,anattrvalobjid
         );

         anrqstpendingobjid := 0; -- Need a new one next time
 END IF;
END;

--
-- Check to see if an Activation field (date/time) has lapsed
--
PROCEDURE checkactivationattrval
(
 focus_type  IN NUMBER,  -- Owning object db type
 focus_lowid    IN NUMBER,  -- Owning object objid
 attr_name     IN VARCHAR2, -- Attribute Name
     rqst_inst_objid   IN      NUMBER,      -- The request instance being processed
     empl_objid  IN NUMBER,  -- The employee objid
     com_tmplte_title IN VARCHAR2, -- Title of com_tmplte for time bomb
     ora_date_format  IN VARCHAR2, -- The Oracle date format to convert returned value to string
     cached_time_bomb_id IN NUMBER,  -- Cached time_bomb objid for reuse as needed
     cached_rqst_pending_id IN NUMBER,  -- Cached rqst_pending objid for possible reuse
     new_time_bomb_id OUT NUMBER,  -- New time_bomb objid for use next time
     new_rqst_pending_id OUT NUMBER,  -- New rqst_pending objid for use next time
 attr_value      OUT VARCHAR2, -- The attr value (if its there!)
 return_status   OUT NUMBER  -- 1=time elapsed, 2=time not elapsed, 0=error
) AS

attr_val_objid NUMBER;
attr_status NUMBER;
com_tmplte_objid NUMBER;
attr_val_date DATE;
attr_type NUMBER;

BEGIN
-- Reserver resource
 getnextobjid( 77, cached_time_bomb_id, new_time_bomb_id );
 getnextobjid( 9760, cached_rqst_pending_id, new_rqst_pending_id );

-- Lock the N_AttributeValue row, reading its pending flag, and value
 SELECT objid, n_status, n_datevalue, n_type
    INTO attr_val_objid, attr_status, attr_val_date, attr_type
 FROM table_n_attributevalue
 WHERE n_focustype = focus_type
   AND n_focuslowid = focus_lowid
   AND n_name = attr_name
 FOR UPDATE;

 IF attr_status != 1 AND sysdate > attr_val_date THEN
 -- Time has elapsed
 -- Delete the request pending entry in case it was restarted by time_bomb
 -- If it was restarted by NotifyDependents, then this will delete no rows!
  DELETE FROM table_rqst_pending
  WHERE pending2rqst_inst = rqst_inst_objid
    AND pending2n_attributevalue = attr_val_objid;

  -- We can set the pending to flag to zero - all requests should be being restarted
  IF attr_status = 2 THEN
   UPDATE table_n_attributevalue
   SET n_status = 0
          WHERE n_focustype = focus_type
     AND n_focuslowid = focus_lowid
     AND n_name = attr_name;
  END IF;

  return_status := 1;
 ELSE
 -- Time has not lapsed - write request pending, time_bomb if needed
  insertrqstpending( new_rqst_pending_id, rqst_inst_objid, attr_val_objid, 1 );

  IF attr_status != 1 THEN
  -- Need to insert IS_REG_TB time bomb,relate to the com_tmplte
   SELECT objid INTO com_tmplte_objid
   FROM   table_com_tmplte
   WHERE  title = com_tmplte_title;

/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
   INSERT INTO table_time_bomb
   (objid,title,escalate_time,focus_lowid,focus_type,flags,cmit_creator2employee, trckr_info2com_tmplte)
   VALUES
   (new_time_bomb_id,'ReActivate',attr_val_date,rqst_inst_objid,9758,0, empl_objid,com_tmplte_objid);
*/

   new_time_bomb_id := 0;

  -- If the attr_status was 0, set to 2 so that future update will notify dependents
   IF attr_status = 0 THEN
    UPDATE table_n_attributevalue
    SET n_status = 2
           WHERE n_focustype = focus_type
        AND n_focuslowid = focus_lowid
      AND n_name = attr_name;
   END IF;

  END IF;

  return_status := 2;
 END IF;

 IF attr_type = 17 THEN  -- Date only
  attr_value := to_char( attr_val_date, ora_date_format );
 ELSE
  attr_value := to_char( attr_val_date, ora_date_format || ' HH24:MI:SS' );
 END IF;
 COMMIT WORK;

EXCEPTION
WHEN OTHERS THEN
 return_status := 0;
 attr_value := '';
 ROLLBACK;

END;

--
-- Check to ee if a dependent field has been set yet
--
PROCEDURE checkdependentattrval
(
 focus_type  IN NUMBER,  -- Owning object db type
 focus_lowid    IN NUMBER,
 attr_name       IN VARCHAR2,
    rqst_inst_objid   IN      NUMBER,      -- The request instance being processed
    dependency_value IN VARCHAR2, -- Dependency on a particular value
     ora_date_format  IN VARCHAR2, -- The Oracle date format to convert returned value to string
     cached_rqst_pending_id IN NUMBER,  -- Cached rqst_pending objid for possible reuse
     new_rqst_pending_id OUT NUMBER,  -- New rqst_pending objid for use next time
 attr_value  OUT VARCHAR2, -- The attr value (if its there!)
 attr_status   OUT NUMBER  -- 0 = OK, 1 = Request(s) pending for dependent field, 2 = Requests pending for activation
) AS

attr_val_objid NUMBER;
attr_type NUMBER;

BEGIN
-- Reserver resource
 getnextobjid( 9760, cached_rqst_pending_id, new_rqst_pending_id );

--
-- Lock the N_AttributeValue row, reading its pending flag, and value
--
 SELECT objid, n_status, n_type,
        decode( n_type,
    3, to_char( n_longvalue ),                       -- Long
    4, to_char( n_decimalvalue ),                   -- Float
    6, to_char( n_decimalvalue ),     -- Decimal
    7, to_char( n_datevalue, ora_date_format || ' HH24:MI:SS' ), -- DateTime
    8, n_stringvalue,                   -- String
   11, to_char( n_longvalue ),                 -- Boolean
   17, to_char( n_datevalue, ora_date_format ),   -- Date only
    n_stringvalue )
     INTO attr_val_objid, attr_status, attr_type, attr_value
 FROM table_n_attributevalue
 WHERE n_focustype = focus_type
   AND n_focuslowid = focus_lowid
   AND n_name = attr_name
 FOR UPDATE;

-- Check for specific value of dependent field
 IF LENGTH(LTRIM(dependency_value)) > 0 AND dependency_value != attr_value THEN
 -- For all intents and purposes the dependent field isn't set for this request
  attr_status := 1;
 END IF;

-- If its pending, it means that the field is unavailable,Insert new request pending entry
 IF attr_status = 1 THEN
  insertrqstpending( new_rqst_pending_id, rqst_inst_objid, attr_val_objid, 0 );
 END IF;

 COMMIT WORK;

EXCEPTION
WHEN OTHERS THEN
 attr_status := 0;
 attr_value := '';
 ROLLBACK;
END;

--
-- Lock a rqst_inst for processing
--
PROCEDURE lockrqstinst
(
 rqst_inst_objid     IN      NUMBER,  -- Objid of the x_rqst_inst
 call_string         IN      VARCHAR2,  -- Call string from execute_return only
 queue_objid        IN NUMBER,  -- Optional Parameter for queued rqst
 cached_rqst_queue_id IN NUMBER,  -- Cached rqst_queue objid for possible reuse
 new_rqst_queue_id OUT NUMBER,  -- New rqst_queue objid for use next time
 busy_flag      OUT NUMBER,  -- The busy flag: 0=free, 1=busy
 used_rqst_queue_id OUT NUMBER
) AS

BEGIN
-- Reserver resource
 getnextobjid( 9761, cached_rqst_queue_id, new_rqst_queue_id );

-- Read and lock the rqst inst and check if it is busy
 SELECT busy INTO busy_flag
 FROM table_rqst_inst
 WHERE objid = rqst_inst_objid
 FOR UPDATE;

-- If it was busy, then all we can do is queue the request if we haven't already !
 IF busy_flag = 1 THEN
     -- If we have a Queued Request already dont need to create it again
  -- and continue

     IF  queue_objid = 0 THEN

   INSERT INTO table_rqst_queue ( objid, FIELDS, queue2rqst_inst )
   VALUES ( new_rqst_queue_id, call_string, rqst_inst_objid );

   used_rqst_queue_id := new_rqst_queue_id;
   new_rqst_queue_id := 0;
  ELSE
   used_rqst_queue_id := queue_objid;
  END IF;

 ELSE
  IF  queue_objid > 0 THEN
   DELETE FROM table_rqst_queue
     WHERE objid = queue_objid;
  END IF;

         UPDATE table_rqst_inst SET busy = 1
  WHERE objid = rqst_inst_objid;

 END IF;

 COMMIT WORK;

EXCEPTION
WHEN OTHERS THEN
 busy_flag := 0;
 ROLLBACK;
END;

--
-- Unlock a requets instance after processing
--
PROCEDURE unlockrqstinst
(
 rqst_inst_objid     IN  NUMBER,   -- Objid of the x_rqst_inst
 rqst_queue_objid    OUT   NUMBER,   -- Optional queue objid
 call_string         OUT   VARCHAR2    -- Call string if return request
) AS

CURSOR c_execute_rqst_queue( rqst_inst_objid NUMBER ) IS
 SELECT objid, FIELDS
 FROM table_rqst_queue
 WHERE queue2rqst_inst = rqst_inst_objid;

BEGIN


-- Unlock the request
 UPDATE table_rqst_inst SET busy = 0
 WHERE objid = rqst_inst_objid;

-- Now, see if any actions have been queued
 OPEN c_execute_rqst_queue( rqst_inst_objid );

 FETCH c_execute_rqst_queue INTO rqst_queue_objid, call_string;
 IF c_execute_rqst_queue%notfound THEN
     rqst_queue_objid := 0;
 END IF;

 CLOSE c_execute_rqst_queue;


 COMMIT WORK;

EXCEPTION
WHEN OTHERS THEN
 call_string := '';
 ROLLBACK;

END;

--
-- Update parent group inst when child completes
PROCEDURE updateparentgroupinst
(
 parent_objid    IN  NUMBER,   -- parent group insance
 delta_change    IN  NUMBER,   -- change in count
 new_count       OUT  NUMBER   -- new value returned
) AS

BEGIN
 UPDATE table_group_inst SET no_functions = no_functions + delta_change
 WHERE objid = parent_objid;

 SELECT no_functions INTO new_count FROM table_group_inst
 WHERE objid = parent_objid;

 COMMIT WORK;

EXCEPTION
WHEN OTHERS THEN
 new_count := 0;
 ROLLBACK;

END;

--
-- Set an attribute value, return if it was not yeet set!
--
PROCEDURE setattrval
(
 focus_type  IN NUMBER,  -- Owning object db type
 focus_lowid    IN NUMBER,  -- Focus objid of owning object instance
 attr_name  IN VARCHAR2,
 attr_value  IN      VARCHAR2, -- The value to set
     ora_date_format  IN VARCHAR2, -- The Oracle date format to convert values to dates
 attr_status   OUT     NUMBER  -- 0 = OK, 1 = Request(s) pending for dependent field, 2 = Requests pending for activation
) AS

attr_type NUMBER;
attr_val_objid NUMBER;

BEGIN
--
-- Lock the N_AttributeValue row, reading its status and type
--
 SELECT objid, n_status, n_type INTO attr_val_objid, attr_status, attr_type
 FROM table_n_attributevalue
 WHERE n_focustype = focus_type
   AND n_focuslowid = focus_lowid
   AND n_name = attr_name
 FOR UPDATE;

--
-- Now set the value - last one in gets it!
-- SET status to 0 here as well
--
 IF attr_type = 3 OR attr_type = 11 THEN
  UPDATE table_n_attributevalue
     SET n_longvalue = to_number( attr_value ), n_status = 0, n_modificationdate = sysdate
  WHERE objid = attr_val_objid;
 ELSIF attr_type = 4 OR attr_type = 6 THEN
  UPDATE table_n_attributevalue
     SET n_decimalvalue = to_number( attr_value ), n_status = 0, n_modificationdate = sysdate
  WHERE objid = attr_val_objid;
 ELSIF attr_type = 7 THEN
  UPDATE table_n_attributevalue
     SET n_datevalue = TO_DATE( attr_value, ora_date_format || ' HH24:MI:SS' ), n_status = 0, n_modificationdate = sysdate
  WHERE objid = attr_val_objid;
 ELSIF attr_type = 17 THEN
  UPDATE table_n_attributevalue
     SET n_datevalue = TO_DATE( attr_value, ora_date_format ), n_status = 0, n_modificationdate = sysdate
  WHERE objid = attr_val_objid;
 ELSE
  UPDATE table_n_attributevalue
     SET n_stringvalue = attr_value, n_status = 0, n_modificationdate = sysdate
  WHERE objid = attr_val_objid;
 END IF;

 COMMIT WORK;

EXCEPTION
WHEN OTHERS THEN
 attr_status := -1;
 ROLLBACK;
END;

END process_manager;
/