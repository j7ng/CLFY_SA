CREATE OR REPLACE TRIGGER sa."TRIGGER_SD_CASE_TABLE"
BEFORE  INSERT or UPDATE ON sa.TABLE_CASE
REFERENCING OLD AS old NEW AS new
FOR EACH ROW
 WHEN (
new.x_case_type in ('IT TOSS', 'Enrollment', 'Monthly service','Payment')
      ) DECLARE
    V_ERROR_CODE VARCHAR2(50);
    V_ERROR_DESC VARCHAR2(200);
    V_FLOW VARCHAR2(50);
    V_CASE_STATUS VARCHAR2(10);
    V_SD_ID NUMBER;
    GBST_ELM_POBJID NUMBER;
    GBST_ELM_EOBJID NUMBER;
    QUEUE_OBJID NUMBER;
    OUTBOUND_OBJID NUMBER;

    CLARIFY_USER TABLE_USER.LOGIN_NAME%TYPE;

   cursor table_case_cur(c_case_id in number) is
      SELECT cd1.x_value Error_Code,
             cd2.x_value Flow,
             cd3.x_value error_description
      FROM table_x_case_detail cd1,
           table_x_case_detail cd2,
           table_x_case_detail cd3,
           table_user u
      WHERE cd1.detail2case = c_case_id
      AND cd2.detail2case = c_case_id
      AND cd3.detail2case = c_case_id
      AND cd1.x_name||'' = 'ERROR_CODE'
      AND cd2.x_name||'' = 'FLOW'
      AND cd3.x_name||'' = 'COPY_PASTE_ERROR_FROM_WEBCSR';
BEGIN
select objid
into gbst_elm_pobjid
from table_gbst_elm where s_title = 'PENDING'
and rank = 0;

select objid
into gbst_elm_eobjid
from table_gbst_elm where s_title = 'EXCEPTION';

select objid into queue_objid
from table_queue where s_title = 'CRM APPS SUPPORT';

select objid into outbound_objid
from table_queue where s_title = 'OUTBOUND';

 if ((:new.casests2gbst_elm = GBST_ELM_POBJID or :new.casests2gbst_elm = GBST_ELM_EOBJID)
     and (:new.case_currq2queue = QUEUE_OBJID or :new.case_currq2queue = OUTBOUND_OBJID)) then

     select login_name
     into CLARIFY_USER
     from table_user
     where objid = :new.case_originator2user;

     open table_case_cur(:new.objid);
     begin
       fetch table_case_cur into V_ERROR_CODE,V_FLOW,V_ERROR_DESC;
     exception
       when others then
         V_ERROR_CODE := 'SHOULD NEVER BE THIS';
     end;
     close table_case_cur;



     if inserting then
           INSERT INTO X_SD_CASE_INTERFACE
                    (
                    SD_ID ,
                    ID_NUMBER ,
                    CASE_STATUS ,
                    PROCESS_STATUS ,
                    CREATION_DATE ,
                    LAST_UDPATE_DATE ,
                    LOGIN_NAME_CRM ,
                    X_CASE_TYPE ,
                    TITLE ,
                    X_ESN ,
                    X_MIN ,
                    X_ICCID,
                    X_MODEL ,
                    X_CARRIER_NAME ,
                    ERROR_CODE,
                    ERROR_DESC,
                    FLOW
                    )
       VALUES
                    (
                    sd_case_seq.nextval,
                    :new.id_number,
                    'O',
                    'O',
                    SYSDATE,
                    SYSDATE,
                    clarify_user,
                    :new.X_CASE_TYPE,
                    :new.TITLE,
                    :new.X_ESN ,
                    :new.X_MIN,
                    :new.X_ICCID,
                    :new.X_MODEL,
                    :new.X_CARRIER_NAME,
                    V_ERROR_CODE,
                    V_ERROR_DESC,
                    V_FLOW
                    );
    else
      begin
          select case_status ,sd_id
          into V_CASE_STATUS,V_SD_ID
          from x_sd_case_interface
          where id_number = :new.id_number;
      exception
          when no_data_found then
             v_case_status := 'C';
          when too_many_rows then
             select case_status,sd_id
             into V_CASE_STATUS,V_SD_ID
             from x_sd_case_interface
             where id_number = :new.id_number
             and sd_id in (select max(sd_id)
                           from x_sd_case_interface
                           where id_number = :new.id_number);
      end;

      if (v_case_status = 'C' ) then
              INSERT INTO X_SD_CASE_INTERFACE
                    (
                    SD_ID ,
                    ID_NUMBER ,
                    CASE_STATUS ,
                    PROCESS_STATUS ,
                    CREATION_DATE ,
                    LAST_UDPATE_DATE ,
                    LOGIN_NAME_CRM ,
                    X_CASE_TYPE ,
                    TITLE ,
                    X_ESN ,
                    X_MIN ,
                    X_ICCID,
                    X_MODEL ,
                    X_CARRIER_NAME ,
                    ERROR_CODE,
                    ERROR_DESC,
                    FLOW
                    )
               VALUES
                    (
                    sd_case_seq.nextval,
                    :new.id_number,
                    'O',
                    'O',
                    SYSDATE,
                    SYSDATE,
                    clarify_user,
                    :new.X_CASE_TYPE,
                    :new.TITLE,
                    :new.X_ESN ,
                    :new.X_MIN,
                    :new.X_ICCID,
                    :new.X_MODEL,
                    :new.X_CARRIER_NAME,
                    V_ERROR_CODE,
                    V_ERROR_DESC,
                    V_FLOW
                    );

           elsif (v_case_status = 'O' ) then

              update x_sd_case_interface
              set x_esn             = :new.x_esn,
                  x_min             = :new.x_min,
                  title             = :new.title,
                  x_iccid           = :new.x_iccid,
                  x_model           = :new.x_model,
                  X_CASE_TYPE       = :new.X_CASE_TYPE,
                  X_CARRIER_NAME    = :new.X_CARRIER_NAME,
                  LAST_UDPATE_DATE  = SYSDATE,
                  login_name_crm    =  clarify_user,
                  process_status    = 'O'
              where id_number = :old.id_number
              and sd_id = V_SD_ID;



           end if;
    end if;
  end if;

END;
/