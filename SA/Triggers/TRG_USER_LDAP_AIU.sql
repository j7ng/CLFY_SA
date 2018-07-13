CREATE OR REPLACE TRIGGER sa."TRG_USER_LDAP_AIU"
AFTER INSERT OR UPDATE OR DELETE
OF OBJID,S_LOGIN_NAME,DEV,STATUS,web_password
ON sa.TABLE_USER FOR EACH row
DECLARE
--------------------------------------------------------------------------------------------
--$RCSfile: trg_user_ldap_aiu.sql,v $
--$Revision: 1.1 $
--$Author: akhan $
--$Date: 2016/06/23 16:44:50 $
--$ $Log: trg_user_ldap_aiu.sql,v $
--$ Revision 1.1  2016/06/23 16:44:50  akhan
--$ Modified to send both B2B and B2C flags to LDAP as necessary
--$
--------------------------------------------------------------------------------------------

web_user_objid NUMBER;
contact_objid NUMBER;
action        VARCHAR2(1);
device_list CLOB;
b2b_account NUMBER := 0;
b2c_account NUMBER := 0;
v_role varchar2(10);
BEGIN
  dbms_output.put_line('trigger fired TABLE_USER');
  IF inserting THEN
    action := 'I';
  elsif updating THEN
    action := 'U';
  elsif deleting or :new.dev + :new.status < 2  THEN
    action := 'D';
  END IF;

  SELECT sum(decode(upper(agent_role),'B2B',1,0)),
         sum(decode(upper(agent_role),'B2C',1,0))
  INTO b2b_account,
       b2c_account
  FROM sa.table_user_extn
  WHERE table_user_objid = NVL(:new.objid,:old.objid)
  AND upper(agent_role) in('B2C','B2B');

  dbms_output.put_line('Count = '||b2b_account||b2c_account );
  IF b2b_account > 0 or b2c_account > 0  THEN

  if b2b_account > 0 then
    v_role := 'B2B';
  end if;
  if b2c_account > 0 then
    select nvl2(v_role,v_role||'|B2C','B2C')
    into v_role
    from dual;
  end if;

    FOR i  IN
    (SELECT *
    FROM table_employee
    WHERE employee2user = NVL(:new.objid,:old.objid)
    )
    LOOP
      dbms_output.put_line('Merging into ccduser');
      merge INTO tdi.ccduser a USING
      (SELECT MAX(rowid) MRID
      FROM tdi.ccduser
      WHERE clfy_wu_objid = NVL(:new.objid,:old.objid)
      )
    ON (clfy_wu_objid = :new.objid AND  a.rowid = MRID)
    WHEN matched THEN
      UPDATE
      SET firstname    = i.first_name,
        lastname       = i.last_name,
        clfy_con_objid = NULL, --i.cont_objid,
        email          = :new.s_login_name,
        brand          = 'CSR', --i.brand,
        password       = '{SHA}' ||:new.web_password ,
        b2b_brand      = v_role
    WHEN NOT matched THEN
      INSERT
        (
          IBMSNAP_COMMITSEQ,
          IBMSNAP_INTENTSEQ,
          IBMSNAP_OPERATION,
          IBMSNAP_LOGMARKER,
          CLFY_WU_OBJID,
          CLFY_CON_OBJID,
          WHO,
          FIRSTNAME,
          LASTNAME,
          EMAIL,
          PASSWORD,
          BRAND,
          B2B_BRAND
          --,DEVICE_IDS
        )
        VALUES
        (
          LPAD(TO_CHAR(tdi.SGENERATOR001.NEXTVAL),20,'0'),
          LPAD(TO_CHAR(tdi.SGENERATOR002.NEXTVAL),20,'0'),
          action,
          SYSDATE,
          NVL(:new.objid, :old.objid),
          NULL, --i.cont_objid,
          'TU',
          i.first_name,
          i.last_name,
          :new.s_login_name,
          '{SHA}'
          ||:new.web_password,
          'CSR', --i.brand,
          v_role
          --,null
        );
      NULL;
    END LOOP;
    NULL;
  END IF;
EXCEPTION
  when others then
    dbms_output.put_line(sqlerrm);
END;
/