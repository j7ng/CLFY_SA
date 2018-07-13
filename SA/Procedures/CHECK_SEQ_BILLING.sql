CREATE OR REPLACE procedure sa.check_seq_billing (p_table_name varchar2)
as

   v_maxobjid number :=0;
   v_lastnum number :=0;
   v_statement varchar2(100);
   v_seq varchar2(30);

   cursor tab
   is
   select table_name  from dba_tables L
    where L.table_name =upper(p_table_name);
   -- and EXISTS (select 1 from USER_indexes  S WHERE INDEX_NAME LIKE '%OBJINDEX%' AND S.TABLE_NAME = L.TABLE_NAME);

   r_tab tab%ROWTYPE;

BEGIN
      OPEN tab;
      FETCH tab INTO r_tab;

       if r_tab.table_name <>'X_NTFY_BOUNCE_EMAIL_TRANS'
        THEN
        	if r_tab.table_name = 'X_PAYMENT_REAL_TIME' then
        	v_statement := 'select max(seq_id) from '|| p_table_name ;
        	else
      		v_statement := 'select max(objid) from '|| p_table_name ;
      		end if;

        	EXECUTE IMMEDIATE v_statement into v_maxobjid ;

		sa.billing_seq_jing( p_table_name, v_seq, v_lastnum);

      		--DBMS_OUTPUT.put_line(v_seq||' '||v_lastnum);
        	if v_lastnum < v_maxobjid then
        		--DBMS_OUTPUT.put_line('******************************');
        	   --	DBMS_OUTPUT.put_line('Max Objid for table '||p_table_name ||': '||v_maxobjid);
        	 	--DBMS_OUTPUT.put_line('Next Val for sequence  '||v_seq||': '||v_lastnum);

        		--DBMS_OUTPUT.put_line('Need to recreate sequence for table '||v_seq||','||p_table_name);
        	--	DBMS_OUTPUT.put_line('******************************');
        		DBMS_OUTPUT.put_line('drop sequence '||v_seq||';');
			v_maxobjid := v_maxobjid + 1;
			DBMS_OUTPUT.put_line('create sequence  '||v_seq||' START WITH '||v_maxobjid);
			DBMS_OUTPUT.put_line('MAXVALUE 999999999999999999999999999');
			DBMS_OUTPUT.put_line('MINVALUE 1 NOCYCLE CACHE 100 NOORDER;');
			DBMS_OUTPUT.put_line('create or replace public synonym '||v_seq||' for '||v_seq||';');
			DBMS_OUTPUT.put_line('grant all on '||v_seq||' to public;');
     		--else
       		--	DBMS_OUTPUT.put_line('******************************');
       		--	DBMS_OUTPUT.put_line('Sequence '||v_seq||' for table '||p_table_name||' is OK');
        	end if;

       ELSE
       		DBMS_OUTPUT.put_line('******************************');
       		DBMS_OUTPUT.put_line('TABLE '||p_table_name||' NOT DATA');
       END IF;

      close tab;

end;
/