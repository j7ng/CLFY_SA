CREATE OR REPLACE procedure sa.check_seq (tab_name in varchar2)
is
   v_table_name varchar2(30);
   v_maxobjid number :=0;
   v_lastnum number :=0;
   v_statement varchar2(100);
   v_type varchar2(20);
   cursor tab 
   is
     select distinct owner||'.'||table_name full_name, table_name from dba_tables where owner IN ('SA' ,'GW1')
   and table_name in (select table_name from dba_tab_columns where column_name ='OBJID')
 and table_name =UPPER(tab_name);
   cursor sequ (p_table_name in varchar2)
   is
    select sequence_name, last_number
    from dba_sequences
    where sequence_name ='SEQU'||substr(upper(p_table_name),6)
    or sequence_name ='SEQ'||substr(upper(p_table_name),6)
    or sequence_name ='SEQ_'||upper(p_table_name)
    or sequence_name ='SEQU_'||upper(p_table_name);
   r_tab tab%ROWTYPE;
   r_sequ sequ%ROWTYPE;
BEGIN
    open tab;
    fetch tab into r_tab;
    if tab%found then
      v_table_name:=r_tab.table_name;
       v_statement := 'select max(objid) from '|| r_tab.full_name ;
--DBMS_OUTPUT.put_line(v_statement);
          EXECUTE IMMEDIATE v_statement into v_maxobjid ;
        IF V_TABLE_NAME='TABLE_X_ORDER_TYPE_RIM' THEN V_TABLE_NAME:='TABLE_X_OT_RIM'; END IF;
	    IF V_TABLE_NAME='TABLE_X_RIM_TRANSACTION' THEN V_TABLE_NAME:='TABLE_X_RIM_TRAN'; END IF;
   if nvl(v_maxobjid,0) >0 then
      open sequ(v_table_name);
      fetch sequ into r_sequ;
      if sequ%FOUND then
        IF V_TABLE_NAME='TABLE_X_OT_RIM' THEN V_TABLE_NAME:='TABLE_X_ORDER_TYPE_RIM'; END IF;
	    IF V_TABLE_NAME='TABLE_X_RIM_TRAN' THEN V_TABLE_NAME:='TABLE_X_RIM_TRANSACTION'; END IF;
      DBMS_OUTPUT.put_line('******************************');
        DBMS_OUTPUT.put_line('--Max Objid for table '||v_table_name ||' is '||v_maxobjid);
        DBMS_OUTPUT.put_line('--CURRVAL for sequence '||r_sequ.sequence_name||': '||r_sequ.last_number);
        v_lastnum:=r_sequ.last_number+268435457;
        DBMS_OUTPUT.put_line('--ADP OBJ for sequence '||r_sequ.sequence_name||': '||v_lastnum);
        if r_sequ.last_number <  v_maxobjid
            and (r_sequ.sequence_name = 'SEQU_X_SIM_INV' OR
        r_sequ.sequence_name = 'SEQU_ACT_ENTRY' OR
        r_sequ.sequence_name = 'SEQU_PART_INST' OR
        r_sequ.sequence_name  ='SEQU_TASK' OR
        r_sequ.sequence_name  ='SEQU_TIME_BOMB' OR
        r_sequ.sequence_name  ='SEQU_X_CALL_TRANS' OR
        r_sequ.sequence_name  ='SEQU_X_CBO_ERROR' OR
        r_sequ.sequence_name  ='SEQU_X_CODE_HIST' OR
        r_sequ.sequence_name  ='SEQU_X_CODE_HIST_TEMP' OR
        r_sequ.sequence_name  ='SEQU_X_CONTACT_ADD_INFO' OR
        r_sequ.sequence_name  ='SEQU_X_GROUP2ESN' OR
        r_sequ.sequence_name  ='SEQU_X_PENDING_REDEMPTION' OR
        r_sequ.sequence_name  ='SEQU_X_PI_HIST' OR
        r_sequ.sequence_name  ='SEQU_X_POSA_CARD_INV' OR
        r_sequ.sequence_name  ='SEQU_X_PROMO_HIST' OR
        r_sequ.sequence_name  ='SEQU_X_RATE_MIN_HIST' OR
        r_sequ.sequence_name  ='SEQU_X_RED_CARD' OR
        r_sequ.sequence_name  ='SEQU_X_RED_CARD_TEMP' OR
        r_sequ.sequence_name  ='SEQU_X_OTA_TRANSACTION' OR
        r_sequ.sequence_name  ='SEQU_X_OTA_TRANS_DTL' OR
        r_sequ.sequence_name  ='SEQU_X_OTA_ACK' OR
        r_sequ.sequence_name  ='SEQU_X_OTA_FEATURES' OR
        r_sequ.sequence_name  ='SEQU_CONTACT_ROLE' OR
        r_sequ.sequence_name  ='SEQU_SITE' OR
        r_sequ.sequence_name  ='SEQU_SITE_PART' OR
        r_sequ.sequence_name  ='SEQU_ADDRESS' OR
        r_sequ.sequence_name  ='SEQU_X_GROUP2ESN' OR
        r_sequ.sequence_name  ='SEQU_X_CLICK_PLAN_HIST' OR
        r_sequ.sequence_name  ='SEQU_X_CODE_TEMP' OR
        r_sequ.sequence_name  ='SEQU_X_TRACKING_VISITOR' OR
        r_sequ.sequence_name  ='SEQU_X_TRACKING_SITE' OR
        r_sequ.sequence_name  ='SEQU_X_TRACKING_CAMPAIGN' OR
        r_sequ.sequence_name  ='SEQU_X_TRACKING_ELEMENT' OR
        r_sequ.sequence_name  ='SEQU_X_TRACKING_POSITION' OR
        r_sequ.sequence_name  ='SEQU_X_TRACKING_TARGET_URL' OR
        r_sequ.sequence_name  ='SEQU_X_TRACKING_ACCOUNT' OR
        r_sequ.sequence_name  ='SEQU_X_TRACKING_STATUS' OR
        r_sequ.sequence_name  ='SEQU_MOD_LEVEL' OR
        r_sequ.sequence_name  ='SEQU_PART_NUM' OR
        r_sequ.sequence_name  ='SEQU_X_PURCH_HDR' OR
        r_sequ.sequence_name  ='SEQU_X_PURCH_DTL' OR
        r_sequ.sequence_name  ='SEQU_X_CREDIT_CARD' OR
        r_sequ.sequence_name  ='SEQU_CONDITION' OR
        r_sequ.sequence_name  ='SEQU_CASE' OR
        r_sequ.sequence_name  ='SEQU_X_ALT_ESN' OR
        r_sequ.sequence_name  ='SEQU_X_CASE_EXTRA_INFO' OR
        r_sequ.sequence_name  ='SEQU_X_WEBCSR_LOG' OR
        r_sequ.sequence_name  ='SEQU_X_PROMOTION' OR
        r_sequ.sequence_name  ='SEQU_X_ZERO_OUT_MAX' or 
		r_sequ.sequence_name  ='SEQU_TABLE_X_RIM_TRAN' or 
		r_sequ.sequence_name  ='SEQU_TABLE_X_OT_RIM')
        then
            v_type:='ORACLE Sequence';
            DBMS_OUTPUT.put_line('******************************');
            DBMS_OUTPUT.put_line('--Using '||v_type||' '||r_sequ.sequence_name);
            DBMS_OUTPUT.put_line('--Need to Recreated As Below:');
            DBMS_OUTPUT.put_line('*********');
            DBMS_OUTPUT.put_line('drop sequence '||r_sequ.sequence_name||';');
            v_maxobjid := v_maxobjid + 1;
            DBMS_OUTPUT.put_line('create sequence  '||r_sequ.sequence_name||' START WITH '||v_maxobjid);
        DBMS_OUTPUT.put_line('MAXVALUE 999999999999999999999999999');
            DBMS_OUTPUT.put_line('MINVALUE 1 NOCYCLE CACHE 100 NOORDER;');
           DBMS_OUTPUT.put_line('create or replace public synonym '||r_sequ.sequence_name||' for '||r_sequ.sequence_name||';');
            DBMS_OUTPUT.put_line('grant all on '||r_sequ.sequence_name||' to public;');
    else if (r_sequ.last_number+ 1 + POWER (2, 28)) <  v_maxobjid
        then
            v_type:='ADP Sequence';
            DBMS_OUTPUT.put_line('******************************');
            DBMS_OUTPUT.put_line('--Using '||v_type||' '||r_sequ.sequence_name);
            DBMS_OUTPUT.put_line('--Need to Recreated As Below:');
            DBMS_OUTPUT.put_line('*********');
            DBMS_OUTPUT.put_line('drop sequence '||r_sequ.sequence_name||';');
            v_maxobjid := v_maxobjid- 268435456;
            DBMS_OUTPUT.put_line('create sequence  '||r_sequ.sequence_name||' START WITH '||v_maxobjid);
            DBMS_OUTPUT.put_line('MAXVALUE 999999999999999999999999999');
            DBMS_OUTPUT.put_line('MINVALUE 1 NOCYCLE CACHE 100 NOORDER;');
          DBMS_OUTPUT.put_line('create or replace public synonym '||r_sequ.sequence_name||' for '||r_sequ.sequence_name||';');
           DBMS_OUTPUT.put_line('grant all on '||r_sequ.sequence_name||' to public;');
        end if;     
        end if;
      end if;
      close sequ;
end if;
      end if;
close tab;
end;
/