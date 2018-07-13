CREATE OR REPLACE TRIGGER sa."TRG_AUD_EXP_GROUP_MEMBER_HIST"
--
  ---------------------------------------------------------------------------------------------
  --$RCSfile: trg_aud_exp_group_member_hist.sql,v $
  --$Revision: 1.1 $
  --$Author: vlaad $
  --$Date: 2016/10/14 14:02:45 $
  --$ $Log: trg_aud_exp_group_member_hist.sql,v $
  --$ Revision 1.1  2016/10/14 14:02:45  vlaad
  --$ Added condition for not firing triggers for Go Smart Migration
  --$
  --$
  --$ Revision 1.1  2016/03/10 18:04:00  sethiraj
  --$ CR37756  - Added by sethiraj to move the deleted and expired member to history table
  --$
  ---------------------------------------------------------------------------------------------
  --
  --
  AFTER UPDATE OR DELETE ON sa.x_account_group_member
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
DECLARE
  --
  v_osuser VARCHAR2(50);
  --v_userid VARCHAR2(30);
  v_objid VARCHAR2(30);

  --
  BEGIN
  -- Go Smart changes
  -- Do not fire trigger if global variable is turned off
   if not sa.globals_pkg.g_run_my_trigger then
     return;
   end if;
  -- End Go Smart changes
    --
    -- Get the user details	-- Commented for CR43837
    /*SELECT objid,
            sys_context('USERENV','OS_USER')
    INTO v_userid,
          v_osuser
    FROM table_user
    WHERE upper(login_name) = upper(USER);*/

	BEGIN
		SELECT  sys_context('USERENV','OS_USER')
		INTO  v_osuser
		FROM DUAL;
	 EXCEPTION
	   WHEN OTHERS THEN
		 NULL;
	END;
	--
	v_objid := :OLD.OBJID;
	--
    -- If the status is updated to EXPIRED move it to history table
    IF UPDATING THEN
      IF :NEW.status = 'EXPIRED' THEN
        INSERT
        INTO gtt_account_group_member
          (
            agm_objid,
            agm_esn
          )
          VALUES
          (
            :OLD.objid,
            :OLD.esn
          );
        --
        -- Insert the expired member record in to the history table.
        INSERT
        INTO X_ACCOUNT_GROUP_MEMBER_HIST
          (
            OBJID,
            MEMBER_OBJID,
            ACCOUNT_GROUP_ID,
            ESN,
            MEMBER_ORDER,
            SITE_PART_ID,
            PROMOTION_ID,
            STATUS,
            MASTER_FLAG,
            PROGRAM_PARAM_ID,
            START_DATE,
            END_DATE,
            INSERT_TIMESTAMP,
            UPDATE_TIMESTAMP,
            RECEIVE_TEXT_ALERTS_FLAG,
            SUBSCRIBER_UID,
            OSUSER,
            CHANGE_DATE
          )
          VALUES
          (
            seq_account_group_member_hist.NEXTVAL,
            :OLD.OBJID,
            :OLD.ACCOUNT_GROUP_ID,
            :OLD.ESN,
            :OLD.MEMBER_ORDER,
            :OLD.SITE_PART_ID,
            :OLD.PROMOTION_ID,
            :NEW.STATUS,
            :OLD.MASTER_FLAG,
            :OLD.PROGRAM_PARAM_ID,
            :OLD.START_DATE,
            :NEW.END_DATE,
            :OLD.INSERT_TIMESTAMP,
            :NEW.UPDATE_TIMESTAMP,
            :OLD.RECEIVE_TEXT_ALERTS_FLAG,
            :OLD.SUBSCRIBER_UID,
            v_osuser,
            SYSDATE
          );
      END IF;
    ELSIF DELETING THEN
      --
      -- Insert the deleted member record in to the history table.
      IF :OLD.status <> 'EXPIRED' THEN
        BEGIN
          INSERT
          INTO X_ACCOUNT_GROUP_MEMBER_HIST
            (
              OBJID,
              MEMBER_OBJID,
              ACCOUNT_GROUP_ID,
              ESN,
              MEMBER_ORDER,
              SITE_PART_ID,
              PROMOTION_ID,
              STATUS,
              MASTER_FLAG,
              PROGRAM_PARAM_ID,
              START_DATE,
              END_DATE,
              INSERT_TIMESTAMP,
              UPDATE_TIMESTAMP,
              RECEIVE_TEXT_ALERTS_FLAG,
              SUBSCRIBER_UID,
              OSUSER,
              CHANGE_DATE
            )
            VALUES
            (
              seq_account_group_member_hist.NEXTVAL,
              :OLD.OBJID,
              :OLD.ACCOUNT_GROUP_ID,
              :OLD.ESN,
              :OLD.MEMBER_ORDER,
              :OLD.SITE_PART_ID,
              :OLD.PROMOTION_ID,
              :OLD.STATUS,
              :OLD.MASTER_FLAG,
              :OLD.PROGRAM_PARAM_ID,
              :OLD.START_DATE,
              :NEW.END_DATE,
              :OLD.INSERT_TIMESTAMP,
              :OLD.UPDATE_TIMESTAMP,
              :OLD.RECEIVE_TEXT_ALERTS_FLAG,
              :OLD.SUBSCRIBER_UID,
              v_osuser,
              SYSDATE
            );
         EXCEPTION
           WHEN OTHERS THEN
             NULL;
        END;
      END IF;
    END IF;
    --
  EXCEPTION
	WHEN OTHERS THEN
	  --
	  DBMS_OUTPUT.PUT_LINE('error while historizing the expired member => ' ||
	  SQLERRM);
	  -- Do not fail if there are exceptions
	  NULL;
	  -- Enter data in error table
	  sa.util_pkg.insert_error_tab(
      'error while historizing the expired member',
      v_objid,
      'TRG_AUD_EXP_GROUP_MEMBER_HIST',
      NVL(SQLERRM,SUBSTR(sqlerrm,1,198)));
	END;
/