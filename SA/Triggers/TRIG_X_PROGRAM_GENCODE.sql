CREATE OR REPLACE TRIGGER sa."TRIG_X_PROGRAM_GENCODE" AFTER
                INSERT OR UPDATE OF X_STATUS ON sa.X_PROGRAM_GENCODE REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_X_PROGRAM_GENCODE.sql,v $
--$Revision: 1.1 $
--$Author: mmunoz $
--$Date: 2012/02/20 20:30:45 $
--$ $Log: TRIG_X_PROGRAM_GENCODE.sql,v $
--$ Revision 1.1  2012/02/20 20:30:45  mmunoz
--$ Added logic to get x_min before inserting event codes 616 and 617
--$
--------------------------------------------------------------------------------------------
DECLARE
                v_lid NUMBER :=NULL;
                v_event_code number :=0;
      CURSOR get_x_min (ip_esn in varchar2)
      IS
          SELECT  tsp.x_min
          from    table_site_part tsp
          where   tsp.x_service_id = ip_esn
          and     tsp.part_status||''='Active'
          order by install_date desc;

     get_x_min_rec   get_x_min%rowtype;
     procedure close_cursor is
     begin
        IF get_x_min%ISOPEN THEN
	       CLOSE get_x_min;
	    END IF;
     end close_cursor;
BEGIN
 IF INSERTING OR UPDATING THEN
   BEGIN
     SELECT lid INTO v_lid FROM sa.x_sl_currentvals WHERE x_current_esn=:new.x_esn AND rownum < 2;
   EXCEPTION WHEN NO_DATA_FOUND THEN
     NULL;    /* to check if the ESN is Safe link , if not do nothing */
   END;
   BEGIN
                                IF v_lid IS NOT NULL THEN /* if this is a safelink ESN */

                                                IF INSERTING /* :new.x_status='INSERTED' AND :old.x_status<>'INSERTED' */ THEN
                                                                v_event_code := 616;
                                                ELSIF (:new.x_status='PROCESSED' AND :old.x_status<>'PROCESSED') OR (:new.x_status='NOPENDING' AND :old.x_status<>'NOPENDING') THEN
                                                                v_event_code := 617;
                                                END IF;

                                                IF v_event_code <> 0 THEN
                                                                OPEN get_x_min(:new.x_esn);  --CR17925
                                                                FETCH get_x_min INTO get_x_min_rec;	  --CR17925
                                                                /* old UPDATE sa.x_sl_currentvals SET x_minutes_sent_dt = SYSDATE WHERE x_current_esn = :new.x_esn; */
                                                                /* 'minutes sent' and 'minutes delivered' event */
                                                                INSERT INTO sa.X_SL_HIST (
                                                                                objid, lid, x_esn, x_min,
                                                                                x_event_dt, x_insert_dt,
                                                                                x_event_code,
                                                                                x_event_value, x_event_data, x_code_number,
                                                                                username, x_sourcesystem,
                                                                                x_src_table, x_src_objid
                                                                ) VALUES (
                                                                                sa.SEQ_X_SL_HIST.NEXTVAL, v_lid, :new.x_esn, get_x_min_rec.x_min,
                                                                                NVL(:new.x_update_stamp,:new.x_insert_date), SYSDATE,
                                                                                v_event_code,
                                                                                :new.gencode2prog_purch_hdr, :new.gencode2call_trans, :new.x_ota_trans_id,
                                                                                USER, 'WEB',
                                                                                'x_program_gencode', :new.objid
                                                                );
                                                                close_cursor;  --CR17925
                                                END IF;

                                END IF;
   EXCEPTION
    WHEN OTHERS THEN
	  close_cursor;  --CR17925
      NULL;
      /* let's not fail the insert/update, so minutes delivery is unaffected */
      /* raise_application_error (-20010,SUBSTR('Audit error in TRIG_PRG_GENCODE while updating X_SL_HIST -  '||SQLERRM,1,255) ); */
   END;
 END IF;
END;
/