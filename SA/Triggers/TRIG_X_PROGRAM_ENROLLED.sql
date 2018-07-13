CREATE OR REPLACE TRIGGER sa."TRIG_X_PROGRAM_ENROLLED" AFTER
INSERT OR UPDATE OF X_ESN,X_ENROLLMENT_STATUS ON sa.X_PROGRAM_ENROLLED
REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_X_PROGRAM_ENROLLED.sql,v $
--$Revision: 1.6 $
--$Author: mmunoz $
--$Date: 2012/05/04 20:51:07 $
--$ $Log: TRIG_X_PROGRAM_ENROLLED.sql,v $
--$ Revision 1.6  2012/05/04 20:51:07  mmunoz
--$ Adding slash
--$
--$ Revision 1.5  2012/05/03 20:20:14  mmunoz
--$ CR20202 mHealth changes related x_sourcesystem = 'HMO'
--$
--$ Revision 1.4  2012/02/20 21:14:09  mmunoz
--$ Added changes to have VMBC origin in the x_sourcesystem when insert event code=607.
--$
--$ Revision 1.3  2012/01/31 20:25:26  mmunoz
--$ Just adding CVS header
--$
--------------------------------------------------------------------------------------------
DECLARE
 v_lid      NUMBER :=NULL;
 v_err_num  NUMBER :=0;
 v_x_current_pgm_start_date DATE;
 v_update_user	sa.X_PROGRAM_ENROLLED.x_update_user%type;
 v_sourcesystem sa.x_program_enrolled.x_sourcesystem%type;
  cursor get_vmbc_request (my_lid in varchar2) is
		selecT 'VMBC' origin
		from xsu_vmbc_request x
		where batchdate >= (select nvl(max(x_insert_dt) , TRUNC(sysdate) )
                        from x_sl_hist h
                        where h.lid = x.lid
                        and h.x_event_code='607'
                        and h.x_event_value in ('DEENROLLED','READYTOREENROLL')
                        and h.x_insert_dt >= trunc(sysdate)
                        and h.x_sourcesystem= 'VMBC')
		and upper(X.REQUESTTYPE) = 'DEENROLL'
		and x.lid = my_lid;

 get_vmbc_request_rec  get_vmbc_request%rowtype;
 procedure close_cursor is
 begin
    IF get_vmbc_request%ISOPEN THEN
	   CLOSE get_vmbc_request;
	END IF;
 end close_cursor;
BEGIN
IF INSERTING OR UPDATING THEN
 BEGIN
  BEGIN
	-- SELECT lid INTO v_lid FROM sa.x_sl_currentvals WHERE x_current_esn=:new.x_esn
   SELECT lid, x_current_pgm_start_date INTO v_lid,v_x_current_pgm_start_date
   FROM sa.x_sl_currentvals WHERE x_current_esn=:new.x_esn
    AND rownum < 2;
  EXCEPTION WHEN NO_DATA_FOUND THEN
   NULL;
  END;

	v_sourcesystem := :new.x_sourcesystem;

    IF(:new.x_enrollment_status !='ENROLLED') THEN v_err_num:=700; END IF;

	IF((:new.x_enrollment_status='SAFELINK') OR (v_lid IS NOT NULL)) THEN

	IF :new.x_sourcesystem <> 'HMO'                --CR20202
	THEN                                           --CR20202
	  --CR17925 begin
	  IF :new.x_enrollment_status = 'ENROLLED'
	  THEN
			IF :new.x_update_user like 'APX_%'
			THEN
				v_update_user := ltrim(:new.x_update_user,'APX_');
				v_sourcesystem := 'SAFELINK';  --tracfone side
			ELSE
				v_update_user := :new.x_update_user;
				v_sourcesystem :=  'VMBC';
			END IF;
	  ELSIF  :new.x_enrollment_status IN ('DEENROLLED','READYTOREENROLL')
	     THEN
      OPEN get_vmbc_request(v_lid);
			FETCH get_vmbc_request INTO get_vmbc_request_rec;
			IF get_vmbc_request%FOUND THEN
			   v_sourcesystem :=  'VMBC';
			ELSE
			   v_sourcesystem := 'SAFELINK';
			END IF;
			close_cursor;
	  END IF;
	  --CR17925 end
	END IF;                                       --CR20202

	  INSERT
	  INTO sa.X_SL_HIST
		(
		  objid,
		  lid,
		  x_esn,
		  x_event_dt,
		  x_insert_dt,
		  x_event_value,
		  x_event_code,
		  x_event_data,
		  x_min,
		  username,
		  x_sourcesystem,
		  x_code_number,
		  x_SRC_table,
		  x_SRC_objid
		)
		VALUES
		(
		  sa.SEQ_X_SL_HIST.nextval,
		  v_lid,
		  :new.x_esn,
		  nvl(:new.x_update_stamp,:new.x_insert_date),
		  SYSDATE,
		  :new.x_enrollment_status,
		  607,
		  :new.x_esn
			||','
			||:new.x_enrollment_status
			||','
			||:new.x_reason,
		  NULL, -- no min
		  NVL(v_update_user,'SYSTEM'),  --CR17925
		  v_sourcesystem,  --CR17925
		  v_err_num,
		  'x_program_enrolled',
		  :new.objid
		);

    -- CR15625 SAFELINK PROCESS IMPROVEMENT

  IF( v_x_current_pgm_start_date) is null THEN
	  INSERT
	  INTO sa.X_SL_HIST
		(
		  objid,
		  lid,
		  x_esn,
		  x_event_dt,
		  x_insert_dt,
		  x_event_value,
		  x_event_code,
		  x_event_data,
		  x_min,
		  username,
		  x_sourcesystem,
		  x_code_number,
		  x_SRC_table,
		  x_SRC_objid
		)
		VALUES
		(
		  sa.SEQ_X_SL_HIST.nextval,
		  v_lid,
		  :new.x_esn,
		  SYSDATE, --CR15625
		  SYSDATE,
		  NULL, -- CR15625
		  615,
		  NULL,  -- CR15625
		  NULL,  -- no min
		  NVL(:new.x_update_user,'SYSTEM'),
		  :new.x_sourcesystem,
		  0,  -- CR15625
		  'x_program_enrolled',
		  NULL  --CR15625
		);
  -- CR15625 SAFELINK PROCESS IMPROVEMENT
  END IF ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  close_cursor;
  dbms_output.put_line ('Error in TRIG_X_PROGRAM_ENROLLED While inserting into X_SL_HIST TABLE');
  END;
END IF;
END;
/