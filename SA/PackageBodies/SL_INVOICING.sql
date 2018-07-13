CREATE OR REPLACE PACKAGE BODY sa."SL_INVOICING" AS
--------------------------------------------------------------------------------------------
--$RCSfile: SL_INVOICING_PKB.sql,v $
--$Revision: 1.7 $
--$Author: mmunoz $
--$Date: 2012/03/27 14:49:14 $
--$ $Log: SL_INVOICING_PKB.sql,v $
--$ Revision 1.7  2012/03/27 14:49:14  mmunoz
--$ Excluded deenroll reason 'D00' with an x_current_Enrolled = 'N' from the billl
--$ Changes in cursors to populate the bill flag (x_sl_invoice.x_bill)
--$
--$ Revision 1.6  2012/03/13 20:39:55  mmunoz
--$ removed x_full_name colum from x_sl_invoice
--$
--$ Revision 1.5  2012/02/22 16:33:39  mmunoz
--$ Allow timestamp in x_sl_invoice.x_batch_date (removed trunc(sysdate))
--$
--$ Revision 1.4  2012/02/21 19:02:43  mmunoz
--$ More changes for improving performance
--$
--$ Revision 1.3  2012/02/21 16:52:37  mmunoz
--$ Changes to get a better performance.
--$
--$ Revision 1.2  2012/02/03 19:10:34  mmunoz
--$ Removing code related with columns xcv.x_enrollment_status, xcv.x_latest_promo_code, promo.x_units
--$
--$ Revision 1.1  2012/01/31 20:06:16  mmunoz
--$ Safelink Invoicing
--$
--------------------------------------------------------------------------------------------
PROCEDURE get_first_last_name (
    ip_lid        in  number,
    ip_Full_Name  in  varchar2,
	op_first_name out varchar2,
	op_last_name  out varchar2
) IS
v_spaces      number;
v_Full_Name   sa.x_sl_subs.full_name%type;
BEGIN
	/*Get First and Last Names*/
	v_Full_Name := ip_Full_Name;
	IF nvl(trim(v_Full_Name),' ') != ' ' and instr(v_Full_Name,' ',1,1) > 0 THEN
         while instr(v_Full_Name,'  ',1,1) > 0 loop
	           v_Full_Name := REPLACE(v_Full_Name,'  ',' ');  -- set only 1 space between words
	     end loop;
	     v_spaces    := 0;
	     while instr(v_Full_Name,' ',1,v_spaces+1) > 0 loop
	         v_spaces := v_spaces + 1;  -- count how many spaces
	     end loop;
	     op_first_name := SUBSTR( v_Full_Name, 1, instr(v_Full_Name,' ',1,round(v_spaces/2))-1);
	     op_last_name  := SUBSTR( v_Full_Name, instr(v_Full_Name,' ',1,round(v_spaces/2))+1, (length(v_Full_Name)-instr(v_Full_Name,' ',1,round(v_spaces/2))));
      /*End First and Last Names*/
	ELSE
	     op_first_name := v_Full_Name;
		 op_last_name  := '';
    END IF;
EXCEPTION
	WHEN OTHERS THEN
	    raise_application_error(-20101, 'ERROR: get_first_last_name'||chr(10)||
	    'Lifeline => '||to_char(ip_lid)||'  Full_Name => '||ip_Full_Name||chr(10)
	    ||SQLERRM);
END get_first_last_name;

PROCEDURE get_duplicate_esn (
	IP_BATCH_DATE		IN DATE,
	IP_BILL_START_DATE	IN DATE,
    IP_BILL_END_DATE	IN DATE
) IS
CURSOR exc_duplicate_esn (
		ip_bill_start_date in date,
		ip_bill_end_date   in date
) IS
      SELECT	X_CURRENT_PART_SERIAL_NO X_CURRENT_ESN
	  FROM		X_SL_INVOICE
	  WHERE		X_BATCH_DATE = IP_BATCH_DATE
      GROUP BY X_CURRENT_PART_SERIAL_NO
      HAVING COUNT(DISTINCT X_LIFELINE_ID) > 1;

CURSOR exc_dup_esn_lid(
	ip_X_CURRENT_ESN  in varchar2,
	ip_bill_start_date in date,
	ip_bill_end_date   in date
) IS
	SELECT		X.X_LIFELINE_ID LID, X.X_EXCLUSION
	FROM		X_SL_INVOICE X,
				X_SL_INVOICE Y
	WHERE		1 = 1
	AND			X.X_BATCH_DATE = IP_BATCH_DATE
	AND			X.X_CURRENT_PART_SERIAL_NO = ip_X_CURRENT_ESN
	AND			Y.X_BATCH_DATE = IP_BATCH_DATE
	AND			Y.X_CURRENT_PART_SERIAL_NO = ip_X_CURRENT_ESN
	AND			X.X_LIFELINE_ID <> Y.X_LIFELINE_ID
    AND    (	(Y.X_BILL = 'Y' AND X.X_BILL  <> 'Y') -- EXCLUDE NON-Y WHERE OTHER IS Y
            OR	(Y.X_BILL<> 'Y' AND X.X_BILL <> 'Y' AND X.X_DEENROLL_DATE < Y.X_DEENROLL_DATE) -- KEEP LATEST DEENROLLED
            OR	(NVL(X.X_ACT_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_ACT_DATE,TO_DATE('01011900','DDMMYYYY'))) -- KEEP ONE WITH LATEST ACT DATE
            OR	(Y.X_BILL<> 'Y' AND X.X_BILL <> 'Y' AND
            	NVL(X.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) AND
                NVL(NVL(X.X_DEENROLL_DATE,Y.X_DEENROLL_DATE),SYSDATE) = NVL(NVL(Y.X_DEENROLL_DATE,X.X_DEENROLL_DATE),SYSDATE)
            	 ) -- 2 NON-Ys WITH SAME OR NO DEENROLL DATE, KEEP LATEST PROGRAM START
            OR (Y.X_BILL= 'Y' AND X.X_BILL  = 'Y' AND
            	NVL(X.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY'))
			    )-- 2 Ys KEEP LATEST PROGRAM START
            )
	;

/****                    Variables                            ****/
exc_duplicate_esn_rec      exc_duplicate_esn%rowtype;
exc_dup_esn_lid_rec        exc_dup_esn_lid%rowtype;
v_rowsupdated  number := 0;
v_bdate date;

BEGIN
	v_bdate := sysdate;
	v_rowsupdated := 0;
    OPEN exc_duplicate_esn(ip_bill_start_date,ip_bill_end_date);
    LOOP
    FETCH exc_duplicate_esn INTO exc_duplicate_esn_rec;
    EXIT WHEN exc_duplicate_esn%NOTFOUND;

		 OPEN exc_dup_esn_lid(exc_duplicate_esn_rec.X_CURRENT_ESN,ip_bill_start_date,ip_bill_end_date);
		 LOOP
		 FETCH exc_dup_esn_lid INTO exc_dup_esn_lid_rec;
		 EXIT WHEN exc_dup_esn_lid%NOTFOUND;
			IF exc_dup_esn_lid_rec.X_EXCLUSION is NULL
			THEN
				BEGIN
				UPDATE /*+ INDEX (INV,X_SL_INVOICE_IDX_BDATE_LID) */ X_SL_INVOICE INV
				SET    X_EXCLUSION = '2'
				WHERE	X_LIFELINE_ID	= exc_dup_esn_lid_rec.LID
				AND		X_BATCH_DATE	= ip_batch_date
				AND		X_EXCLUSION IS NULL;
				EXCEPTION
				WHEN OTHERS THEN
				    raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 2'||chr(10)||
				    'Lifeline => '||exc_dup_esn_lid_rec.LID||chr(10)
				    ||SQLERRM);
				END;

				COMMIT;
			    v_rowsupdated := v_rowsupdated + 1;
			END IF;
	     END LOOP;
		 CLOSE exc_dup_esn_lid;
    END LOOP;
    CLOSE exc_duplicate_esn;
DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  get_duplicate_esn  '||v_rowsupdated);v_bdate:=sysdate;
END get_duplicate_esn;

PROCEDURE get_duplicate_min (
	IP_BATCH_DATE		IN DATE,
	IP_BILL_START_DATE	IN DATE,
    IP_BILL_END_DATE	IN DATE
) IS
CURSOR exc_duplicate_min (
		ip_bill_start_date in date,
		ip_bill_end_date   in date
) IS
      SELECT	X_CURRENT_X_MIN X_CURRENT_MIN
	  FROM		X_SL_INVOICE
	  WHERE		X_BATCH_DATE = IP_BATCH_DATE
	  AND		X_CURRENT_X_MIN IS NOT NULL
      GROUP BY X_CURRENT_X_MIN
      HAVING COUNT(DISTINCT X_LIFELINE_ID) > 1;

CURSOR exc_dup_min_lid(
	ip_X_CURRENT_MIN  in varchar2,
	ip_bill_start_date in date,
	ip_bill_end_date   in date
) IS
	SELECT		X.X_LIFELINE_ID LID, X.X_EXCLUSION
	FROM		X_SL_INVOICE X,
				X_SL_INVOICE Y
	WHERE		1 = 1
	AND			X.X_BATCH_DATE = IP_BATCH_DATE
	AND			X.X_CURRENT_X_MIN = ip_X_CURRENT_MIN
	AND			Y.X_BATCH_DATE = IP_BATCH_DATE
	AND			Y.X_CURRENT_X_MIN = ip_X_CURRENT_MIN
	AND			X.X_LIFELINE_ID <> Y.X_LIFELINE_ID
    AND    (	(Y.X_BILL = 'Y' AND X.X_BILL  <> 'Y') -- EXCLUDE NON-Y WHERE OTHER IS Y
            OR	(Y.X_BILL<> 'Y' AND X.X_BILL <> 'Y' AND X.X_DEENROLL_DATE < Y.X_DEENROLL_DATE) -- KEEP LATEST DEENROLLED
            OR	(NVL(X.X_ACT_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_ACT_DATE,TO_DATE('01011900','DDMMYYYY'))) -- KEEP ONE WITH LATEST ACT DATE
            OR	(Y.X_BILL<> 'Y' AND X.X_BILL <> 'Y' AND
            	NVL(X.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) AND
                NVL(NVL(X.X_DEENROLL_DATE,Y.X_DEENROLL_DATE),SYSDATE) = NVL(NVL(Y.X_DEENROLL_DATE,X.X_DEENROLL_DATE),SYSDATE)
            	 ) -- 2 NON-Ys WITH SAME OR NO DEENROLL DATE, KEEP LATEST PROGRAM START
            OR (Y.X_BILL= 'Y' AND X.X_BILL  = 'Y' AND
            	NVL(X.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY'))
			    )-- 2 Ys KEEP LATEST PROGRAM START
            )
	;

/****                    Variables                            ****/
exc_duplicate_min_rec      exc_duplicate_min%rowtype;
exc_dup_min_lid_rec        exc_dup_min_lid%rowtype;
v_rowsupdated  number := 0;
v_bdate date;
BEGIN
	v_bdate := sysdate;
	v_rowsupdated := 0;
    OPEN exc_duplicate_min(ip_bill_start_date,ip_bill_end_date);
    LOOP
    FETCH exc_duplicate_min INTO exc_duplicate_min_rec;
    EXIT WHEN exc_duplicate_min%NOTFOUND;

		 OPEN exc_dup_min_lid(exc_duplicate_min_rec.X_CURRENT_MIN,ip_bill_start_date,ip_bill_end_date);
		 LOOP
		 FETCH exc_dup_min_lid INTO exc_dup_min_lid_rec;
		 EXIT WHEN exc_dup_min_lid%NOTFOUND;
			IF exc_dup_min_lid_rec.X_EXCLUSION IS NULL
			THEN
				BEGIN
				UPDATE /*+ INDEX (INV,X_SL_INVOICE_IDX_BDATE_LID) */ X_SL_INVOICE INV
				SET    X_EXCLUSION = '3'
				WHERE	X_LIFELINE_ID	= exc_dup_min_lid_rec.LID
				AND		X_BATCH_DATE	= ip_batch_date
				AND		X_EXCLUSION IS NULL;
				EXCEPTION
				WHEN OTHERS THEN
				    raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 3'||chr(10)||
				    'Lifeline => '||exc_dup_min_lid_rec.LID||chr(10)
				    ||SQLERRM);
				END;

				COMMIT;
			    v_rowsupdated := v_rowsupdated + 1;
			END IF;
	     END LOOP;
		 CLOSE exc_dup_min_lid;
    END LOOP;
    CLOSE exc_duplicate_min;
 DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  get_duplicate_min  '||v_rowsupdated);v_bdate:=sysdate;
END get_duplicate_min;

PROCEDURE get_duplicate_address (
	IP_BATCH_DATE		IN DATE,
	IP_BILL_START_DATE	IN DATE,
    IP_BILL_END_DATE	IN DATE
) IS


CURSOR exc_duplicate_address(
		IP_BATCH_DATE in date
) IS
		select
			x_bill_address1 address_1, x_bill_address2 address_2
			,x_bill_zip5 zip
			,x_bill_city city
			,x_bill_state state, count(x_lifeline_id) dup_addr
		from x_sl_invoice
		where x_batch_date = IP_BATCH_DATE
		group by x_bill_address1, x_bill_address2,x_bill_zip5,x_bill_city,x_bill_state
		having count(x_lifeline_id) > 1;

CURSOR exc_dup_addr_lid (
	ip_BILL_STATE          in varchar2,
	ip_BILL_CITY           in varchar2,
	ip_BILL_ZIP5           in varchar2,
	ip_BILL_ADDRESS1       in varchar2,
	ip_BILL_ADDRESS2       in varchar2,
	ip_bill_start_date		in date,
	ip_bill_end_date		in date
) IS
	SELECT		X.X_LIFELINE_ID LID, X.X_EXCLUSION
	FROM		X_SL_INVOICE X,
				X_SL_INVOICE Y
	WHERE		1 = 1
	AND			X.X_BATCH_DATE = IP_BATCH_DATE
	AND     	NVL(X.X_BILL_ADDRESS2,' ') = NVL(ip_BILL_ADDRESS2,' ')
	AND     	X.X_BILL_ADDRESS1 = ip_BILL_ADDRESS1
	AND     	X.X_BILL_ZIP5     = ip_BILL_ZIP5
	AND     	X.X_BILL_CITY     = ip_BILL_CITY
	AND     	X.X_BILL_STATE    = IP_BILL_STATE
	AND			Y.X_BATCH_DATE = IP_BATCH_DATE
	AND     	NVL(Y.X_BILL_ADDRESS2,' ') = NVL(ip_BILL_ADDRESS2,' ')
	AND     	Y.X_BILL_ADDRESS1 = ip_BILL_ADDRESS1
	AND     	Y.X_BILL_ZIP5     = ip_BILL_ZIP5
	AND     	Y.X_BILL_CITY     = ip_BILL_CITY
	AND     	Y.X_BILL_STATE    = IP_BILL_STATE
	AND			X.X_LIFELINE_ID <> Y.X_LIFELINE_ID
    AND    (	(Y.X_BILL = 'Y' AND X.X_BILL  <> 'Y') -- EXCLUDE NON-Y WHERE OTHER IS Y
            OR	(Y.X_BILL<> 'Y' AND X.X_BILL <> 'Y' AND X.X_DEENROLL_DATE < Y.X_DEENROLL_DATE) -- KEEP LATEST DEENROLLED
            OR	(NVL(X.X_ACT_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_ACT_DATE,TO_DATE('01011900','DDMMYYYY'))) -- KEEP ONE WITH LATEST ACT DATE
            OR	(Y.X_BILL<> 'Y' AND X.X_BILL <> 'Y' AND
            	NVL(X.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) AND
                NVL(NVL(X.X_DEENROLL_DATE,Y.X_DEENROLL_DATE),SYSDATE) = NVL(NVL(Y.X_DEENROLL_DATE,X.X_DEENROLL_DATE),SYSDATE)
            	 ) -- 2 NON-Ys WITH SAME OR NO DEENROLL DATE, KEEP LATEST PROGRAM START
            OR (Y.X_BILL= 'Y' AND X.X_BILL  = 'Y' AND
            	NVL(X.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY')) < NVL(Y.X_PROGRAM_START_DATE,TO_DATE('01011900','DDMMYYYY'))
			    )-- 2 Ys KEEP LATEST PROGRAM START
            )
	;

/****                    Variables                            ****/
exc_duplicate_addr_rec     exc_duplicate_address%rowtype;
exc_dup_addr_lid_rec       exc_dup_addr_lid%rowtype;
v_rowsupdated  number := 0;
v_bdate date;
BEGIN
	v_bdate := sysdate;
	OPEN exc_duplicate_address(ip_batch_date);
    LOOP
    FETCH exc_duplicate_address INTO exc_duplicate_addr_rec;
    EXIT WHEN exc_duplicate_address%NOTFOUND;

		 OPEN exc_dup_addr_lid(exc_duplicate_addr_rec.STATE,
		                       exc_duplicate_addr_rec.CITY,
							   exc_duplicate_addr_rec.ZIP,
							   exc_duplicate_addr_rec.ADDRESS_1,
							   exc_duplicate_addr_rec.ADDRESS_2,
							   ip_bill_start_date,ip_bill_end_date);
		 LOOP
		 FETCH exc_dup_addr_lid INTO exc_dup_addr_lid_rec;
		 EXIT WHEN exc_dup_addr_lid%NOTFOUND;
			IF exc_dup_addr_lid_rec.X_EXCLUSION IS NULL
			THEN
				BEGIN
				UPDATE /*+ INDEX (INV,X_SL_INVOICE_IDX_BDATE_LID) */ X_SL_INVOICE INV
				SET    X_EXCLUSION = '4'
				WHERE	X_LIFELINE_ID	= exc_dup_addr_lid_rec.LID
				AND		X_BATCH_DATE	= ip_batch_date
				AND		X_EXCLUSION IS NULL;
				EXCEPTION
				WHEN OTHERS THEN
				    raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 4'||chr(10)||
				    'Lifeline => '||exc_dup_addr_lid_rec.LID||chr(10)
				    ||SQLERRM);
				END;

				COMMIT;
			    v_rowsupdated := v_rowsupdated + 1;
			END IF;
	     END LOOP;
		 CLOSE exc_dup_addr_lid;
    END LOOP;
    CLOSE exc_duplicate_address;
DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  get_duplicate_address  '||v_rowsupdated);v_bdate:=sysdate;
END get_duplicate_address;

PROCEDURE get_texas_inbound (
	IP_BATCH_DATE		IN DATE,
	IP_BILL_START_DATE	IN DATE,
    IP_BILL_END_DATE	IN DATE
) IS
CURSOR get_texas_esn (
	IP_BATCH_DATE		IN DATE
) IS
	SELECT	INV.X_CURRENT_PART_SERIAL_NO
	FROM	X_SL_INVOICE INV
	WHERE	INV.X_BATCH_DATE	= ip_batch_date
	AND		INV.X_EXCLUSION IS NULL
	AND		INV.X_BILL_STATE = 'TX';

CURSOR get_texas_inbound (
	ip_X_CURRENT_ESN  	in varchar2,
	IP_BILL_START_DATE	IN DATE
) IS
                SELECT /*+ INDEX (C,XSU_SOLIX_REQUEST_IDX_ACC) */
			c.account
                FROM	sa.xsu_solix_request C
                WHERE	c.batchdate >= ip_bill_start_date
                AND	c.account like ip_X_CURRENT_ESN ||'|%';

get_texas_esn_rec			get_texas_esn%rowtype;
get_texas_inbound_rec		get_texas_inbound%rowtype;
v_rowsupdated				number := 0;
v_bdate date;
BEGIN
v_bdate := SYSDATE;
	OPEN get_texas_esn(IP_BATCH_DATE);
	LOOP
	FETCH get_texas_esn INTO get_texas_esn_rec;
	EXIT WHEN get_texas_esn%NOTFOUND;
			OPEN get_texas_inbound(get_texas_esn_rec.X_CURRENT_PART_SERIAL_NO,IP_BILL_START_DATE);
			FETCH get_texas_inbound INTO get_texas_inbound_rec ;
			IF get_texas_inbound%NOTFOUND THEN
			    BEGIN
				UPDATE	X_SL_INVOICE
				SET		X_EXCLUSION = '20'
				WHERE	X_BATCH_DATE	= ip_batch_date
				AND		X_EXCLUSION IS NULL
				AND		X_BILL_STATE = 'TX'
				AND		X_CURRENT_PART_SERIAL_NO = get_texas_esn_rec.X_CURRENT_PART_SERIAL_NO;
				EXCEPTION
				WHEN OTHERS THEN
				    raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 20'||chr(10)||
				    'CURRENT_PART_SERIAL_NO => '||get_texas_esn_rec.X_CURRENT_PART_SERIAL_NO||chr(10)
				    ||SQLERRM);
				END;

				COMMIT;
			    v_rowsupdated := v_rowsupdated + 1;
			END IF;
			CLOSE get_texas_inbound;
	END LOOP;
	CLOSE get_texas_esn;
DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  get_texas_inbound '||v_rowsupdated);
END get_texas_inbound;

PROCEDURE get_invalid_fields (
	IP_BATCH_DATE		IN DATE,
	IP_BILL_START_DATE	IN DATE,
    IP_BILL_END_DATE	IN DATE
) IS
	v_bdate date;
BEGIN
	v_bdate:=sysdate;
BEGIN
	UPDATE X_SL_INVOICE INV
	SET    X_EXCLUSION = '9'   --T-xmin Number
	WHERE  INV.X_BATCH_DATE	= ip_batch_date
	AND    INV.X_EXCLUSION IS NULL
	AND    INV.X_CURRENT_X_MIN LIKE 'T%';
EXCEPTION
	WHEN OTHERS THEN
	    raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 9'||chr(10)
		    ||SQLERRM);
END;
DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  get_invalid_fields T-xmin '||SQL%ROWCOUNT);v_bdate:=sysdate;
	COMMIT;
BEGIN
	UPDATE X_SL_INVOICE INV
	SET    X_EXCLUSION = '5'
	WHERE  INV.X_BATCH_DATE	= ip_batch_date
	AND    INV.X_EXCLUSION IS NULL
	AND    INV.X_CURRENT_X_MIN IS NULL;
EXCEPTION
	WHEN OTHERS THEN
	    raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 5'||chr(10)
		    ||SQLERRM);
END;
DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  get_invalid_fields MIN NULL '||SQL%ROWCOUNT);v_bdate:=sysdate;
	COMMIT;
BEGIN
	UPDATE X_SL_INVOICE INV
	SET    X_EXCLUSION = '6'
	WHERE  INV.X_BATCH_DATE	= ip_batch_date
	AND    INV.X_EXCLUSION IS NULL
	AND    INV.X_PROGRAM_START_DATE IS NULL;
EXCEPTION
	WHEN OTHERS THEN
	    raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 6'||chr(10)
		    ||SQLERRM);
END;
DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  get_invalid_fields PGM_START_DATE NULL '||SQL%ROWCOUNT);v_bdate:=sysdate;
	COMMIT;
BEGIN
	UPDATE X_SL_INVOICE INV
	SET    X_EXCLUSION = '8'    --Test Lifeline Id
	WHERE  INV.X_BATCH_DATE	= ip_batch_date
	AND    INV.X_EXCLUSION IS NULL
	AND    INV.X_LIFELINE_ID  <= 0;
EXCEPTION
	WHEN OTHERS THEN
	    raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 8'||chr(10)
		    ||SQLERRM);
END;
DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  get_invalid_fields TEST LID '||SQL%ROWCOUNT);v_bdate:=sysdate;
	COMMIT;
END get_invalid_fields;

PROCEDURE drop_temp_tables
IS
	sql_stmt	varchar2(100);
BEGIN
	-- Dropping tables created
	sql_stmt := ' drop table sl_inv_temp1';
	execute immediate sql_stmt;
	sql_stmt := ' drop table sl_inv_temp2';
	execute immediate sql_stmt;
	sql_stmt := ' drop table sl_inv_temp3';
	execute immediate sql_stmt;
	sql_stmt := ' drop table sl_inv_temp4';
	execute immediate sql_stmt;
EXCEPTION
    WHEN others THEN
      dbms_output.put_line(SQLERRM);
      dbms_output.put_line('drop_temp_tables: '||SUBSTR(sql_stmt,1,254) );
	    raise_application_error(-20101, 'ERROR: drop_temp_tables'||chr(10)
		    ||SQLERRM);
END drop_temp_tables;

PROCEDURE get_rates (
	IP_BATCH_DATE		IN DATE,
	IP_BILL_START_DATE	IN DATE	,
	IP_BILL_END_DATE	IN DATE
) IS
  TYPE rate_cursor IS REF CURSOR;
  ratec rate_cursor;
  TYPE rate_record IS RECORD
  (state          x_sl_invoice.X_BILL_STATE%type,
  zip             x_sl_invoice.X_BILL_ZIP5%type,
  ratecenter_st   x_sl_invoice.X_RATECENTER_ST%type,
  eucl_rate       x_sl_invoice.X_EUCL_RATE%type
  );
  ratec_rec         rate_record;

  ex_table_already_exists    EXCEPTION;

  PRAGMA EXCEPTION_INIT(ex_table_already_exists,-955);

  sql_stmt	varchar2(1000);
BEGIN
dbms_output.put_line('Creating tables  '||to_char(sysdate,'mm/dd hh24:mi:ss'));

sql_stmt := ' Create table sl_inv_temp1'
          ||' as'
          ||' select distinct x_bill_state state, X_BILL_ZIP5 zip'
          ||' from x_sl_invoice'
          ||' where x_batch_date = to_date('''||to_char(IP_BATCH_DATE,'mm/dd/yyyy hh24:mi:ss')||''',''mm/dd/yyyy hh24:mi:ss'')';
execute immediate sql_stmt;
dbms_output.put_line('table temp1 created  '||to_char(sysdate,'mm/dd hh24:mi:ss'));

sql_stmt := ' Create table sl_inv_temp2'
          ||' As'
          ||' select distinct lur.state, lur.eucl_rate, lur.ratecenter'
          ||' from ll_eucl_rates lur'
          ||' where batchdate >= to_date('''||to_char(IP_BILL_START_DATE,'mm/dd/yyyy hh24:mi:ss')||''',''mm/dd/yyyy hh24:mi:ss'')'
          ||'   and batchdate <  to_date('''||to_char(IP_BILL_END_DATE,'mm/dd/yyyy hh24:mi:ss')||''',''mm/dd/yyyy hh24:mi:ss'')'
          ||' group by lur.state, lur.eucl_rate, lur.ratecenter';
execute immediate sql_stmt;
dbms_output.put_line('table temp2 created  '||to_char(sysdate,'mm/dd hh24:mi:ss'));

sql_stmt := ' Create table sl_inv_temp3'
          ||' As'
          ||' Select distinct cz.rate_cente, cz.st, cz.zip'
          ||' from carrierzones cz'
          ||' where 1=1'
          ||' and (   cz.carrier_name like ''CINGULAR%'' '
          ||'      or cz.carrier_name like ''AT''||chr(38)||''T%'' '
          ||'      or cz.carrier_name like ''VERI'')';
execute immediate sql_stmt;
dbms_output.put_line('table temp3 created  '||to_char(sysdate,'mm/dd hh24:mi:ss'));

sql_stmt := ' Create table sl_inv_temp4'
          ||' As'
          ||' select t1.STATE, t1.ZIP,'
          ||'        lur.ratecenter||cz.st ratecenter_st,'
          ||'        LUR.EUCL_RATE EUCL_RATE'
          ||' From sl_inv_temp1 t1,'
          ||'      sl_inv_Temp2 lur,'
          ||'      sl_inv_Temp3 cz'
          ||' Where lur.state = t1.STATE'
          ||' And cz.rate_cente = lur.ratecenter'
          ||' and cz.st = lur.state'
          ||' and cz.zip = t1.ZIP';
execute immediate sql_stmt;
dbms_output.put_line('table temp4 created  '||to_char(sysdate,'mm/dd hh24:mi:ss'));

sql_stmt := ' select state, zip, ratecenter_st, eucl_rate'
          ||' from sl_inv_temp4';

OPEN ratec FOR sql_stmt;
LOOP
FETCH ratec INTO ratec_rec;
EXIT WHEN ratec%NOTFOUND;
        update  x_sl_invoice
        set     x_eucl_rate = ratec_rec.eucl_rate
               ,x_ratecenter_st = ratec_rec.ratecenter_st
        where   x_batch_date = IP_BATCH_DATE
        and     x_bill_state = ratec_rec.state
        and     x_bill_zip5  =  ratec_rec.zip
        ;
        COMMIT;
END LOOP;
CLOSE ratec;

drop_temp_tables;
EXCEPTION
    WHEN ex_table_already_exists THEN
      dbms_output.put_line('table_already_exists: '||SUBSTR(sql_stmt,1,254) ||SQLERRM );
    WHEN others THEN
      dbms_output.put_line(SQLERRM);
      dbms_output.put_line(SUBSTR(sql_stmt,1,254));
	    raise_application_error(-20101, 'ERROR: get_rates '||chr(10)
		    ||SQLERRM);
END get_rates;

PROCEDURE POPULATE_X_SL_INVOICE (
     p_rowsinserted out number,
     p_batchdate out date
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
  /*************************************************************************************/
  /*                                                                                   */
  /* NAME     : POPULATE_X_SL_INVOICE                                                  */
  /* PURPOSE  : Procedure has been developed to populate the table x_sl_invoice        */
  /*            with the billable lifelines found x_sl_currentvals                     */
  /*			call GET_EXCLUSION to update the exclusion field in the x_sl_invoice  */
  /* Input parameter:                                                                  */
  /* Output parameters:                                                                */
  /*            	Rows Inserted                                                      */
  /*            	Batch Date                                                         */
  /*                                                                                   */
  /* VERSION DATE     WHO        COMMENTS                                              */
  /* ------- -------- ---------- ------------------------------------------------------*/
  /* 1.0     Sept/11  mmunoz     CR 17925 SafeLink II (Invoicing and Synch)            */
  /*************************************************************************************/
CURSOR SL_INVOICE_cursor1 (
		ip_bill_start_date in date,
		ip_bill_end_date   in date
) IS
			SELECT
			  xcv.lid, xcv.X_CURRENT_MIN, xcv.X_CURRENT_ESN, xcv.x_minutes_delivered_dt,
			  xcv.X_CURRENT_PGM_START_DATE, xcv.x_invoice_reason, xcv.x_current_active_date,
			  xcv.X_BENEFIT_DELVD_CARRIER_ID, xcv.X_BENEFIT_DELVD_CARRIER_NAME, xcv.X_BENEFIT_DELVD_ESN, xcv.X_BENEFIT_DELVD_MIN,
			  xcv.X_BENEFIT_DELVD_PHONE_STATUS, xcv.X_BENEFIT_DELVD_ACT_ZIPCODE, xcv.X_BENEFIT_DELVD_PART_NUM,
			  xcv.X_SHIP_ADDRESS_1, xcv.X_SHIP_ADDRESS_2, xcv.X_SHIP_CITY, xcv.X_SHIP_STATE, xcv.X_SHIP_ZIPCODE,
			  xcv.X_SHIP_DATE, xcv.X_TRACKING_NO, xcv.X_OTA_STATUS, xcv.X_OTA_UNITS,
			  xcv.X_CURRENT_PE_ID, xcv.X_BENEFIT_DELVD_PE_ID,
			  CASE WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'AT'||CHR(38)||'T%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'T-MOBILE%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'VERIZON%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'CLARO%' AND subs.STATE = 'PR' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'CINGULAR%' THEN 'Y'
   			       ELSE 'N'
			  END                       APPROVED_CARRIER,
              DECODE(xcv.X_CURRENT_ENROLLED,'N','Y','N')    as DEENROLL,
              xcv.X_CURRENT_ENROLLED_DATE                   as ENROLLDATE,
              DECODE(xcv.X_CURRENT_ENROLLED,'Y',NULL,
                     xcv.X_CURRENT_ENROLLED_DATE)           as DEENROLL_DATE,
              'Y'                                           as BILL,
			  CASE WHEN xcv.lid BETWEEN 80000000 AND 89999999
			       THEN 'Y'
				   ELSE 'N'
                   END                     				   as TEXAS,
 			  subs.full_name                               as FULL_NAME,
              subs.X_HOMENUMBER                            as HOME_PHONE,
              subs.ADDRESS_1                               as BILL_ADDRESS1,
              subs.ADDRESS_2                               as BILL_ADDRESS2,
              subs.CITY                                    as BILL_CITY,
              subs.STATE                                   as BILL_STATE,
              subs.ZIP                                     as BILL_ZIP5,
			  pe.X_ENROLLMENT_STATUS		               as LL_STATUS,
			  pe.x_program_name							   as X_CURRENT_PROG_NAME
			FROM	(select *
					from x_sl_currentvals xcv
					where 1 = 1
					AND xcv.X_CURRENT_ENROLLED = 'Y'
					AND xcv.X_BENEFIT_DELVD_PHONE_STATUS = '52'
					)  XCV,
					X_SL_SUBS            SUBS,
					(
					SELECT
					      pe.objid, pe.X_ENROLLMENT_STATUS, pp.x_program_name
					from   x_program_parameters pp,
					       x_program_enrolled pe
					where pp.x_prog_class = 'LIFELINE'
					and  pe.pgm_enroll2pgm_parameter = pp.objid
					AND  PE.X_SOURCESYSTEM = 'VMBC'
					AND  PE.X_ENROLLMENT_STATUS IN ('ENROLLED','ENROLLMENTBLOCKED','ENROLLMENTPENDING','ENROLLMENTSCHEDULED')
					) PE
			WHERE	1 = 1
			AND		subs.lid = xcv.lid
			AND		PE.OBJID = XCV.X_CURRENT_PE_ID;

CURSOR SL_INVOICE_cursor2 (
		ip_bill_start_date in date,
		ip_bill_end_date   in date
) IS
			SELECT  /*+ PUSH_SUBQ ORDERED */
			  xcv.lid, xcv.X_CURRENT_MIN, xcv.X_CURRENT_ESN, xcv.x_minutes_delivered_dt,
			  xcv.X_CURRENT_PGM_START_DATE, xcv.x_invoice_reason, xcv.x_current_active_date,
			  xcv.X_BENEFIT_DELVD_CARRIER_ID, xcv.X_BENEFIT_DELVD_CARRIER_NAME, xcv.X_BENEFIT_DELVD_ESN, xcv.X_BENEFIT_DELVD_MIN,
			  xcv.X_BENEFIT_DELVD_PHONE_STATUS, xcv.X_BENEFIT_DELVD_ACT_ZIPCODE, xcv.X_BENEFIT_DELVD_PART_NUM,
			  xcv.X_SHIP_ADDRESS_1, xcv.X_SHIP_ADDRESS_2, xcv.X_SHIP_CITY, xcv.X_SHIP_STATE, xcv.X_SHIP_ZIPCODE,
			  xcv.X_SHIP_DATE, xcv.X_TRACKING_NO, xcv.X_OTA_STATUS, xcv.X_OTA_UNITS,
			  xcv.X_CURRENT_PE_ID, xcv.X_BENEFIT_DELVD_PE_ID,
			  CASE WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'AT'||CHR(38)||'T%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'T-MOBILE%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'VERIZON%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'CLARO%' AND subs.STATE = 'PR' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'CINGULAR%' THEN 'Y'
   			       ELSE 'N'
			  END                       APPROVED_CARRIER,
              DECODE(xcv.X_CURRENT_ENROLLED,'N','Y','N')    as DEENROLL,
              xcv.X_CURRENT_ENROLLED_DATE                   as ENROLLDATE,
              DECODE(xcv.X_CURRENT_ENROLLED,'Y',NULL,
                     xcv.X_CURRENT_ENROLLED_DATE)           as DEENROLL_DATE,
              DECODE(xcv.X_DEENROLL_REASON,NULL,'Y',
                     SUBSTR(X_DEENROLL_REASON,1,3))    	    as BILL,
			  CASE WHEN xcv.lid BETWEEN 80000000 AND 89999999
			       THEN 'Y'
				   ELSE 'N'
                   END                     				   as TEXAS,
 			  subs.full_name                               as FULL_NAME,
              subs.X_HOMENUMBER                            as HOME_PHONE,
              subs.ADDRESS_1                               as BILL_ADDRESS1,
              subs.ADDRESS_2                               as BILL_ADDRESS2,
              subs.CITY                                    as BILL_CITY,
              subs.STATE                                   as BILL_STATE,
              subs.ZIP                                     as BILL_ZIP5,
			  pe.X_ENROLLMENT_STATUS		               as LL_STATUS,
			  pe.x_program_name							   as X_CURRENT_PROG_NAME
			FROM	(select *
					from x_sl_currentvals xcv
					where 1 = 1
					AND	xcv.X_CURRENT_ENROLLED = 'N'
					AND NVL(SUBSTR(xcv.X_DEENROLL_REASON,1,3),'')  IN ('D03','D04','U00','U03','U04')
					AND NVL(xcv.X_CURRENT_ENROLLED_DATE,(ip_bill_start_date-1)) >= ip_bill_start_date
					AND xcv.x_minutes_delivered_dt >= ip_bill_start_date
					AND xcv.x_minutes_delivered_dt <  ip_bill_end_date
					)  xcv,
					x_sl_subs            subs,
					(
					SELECT
					      pe.objid, pe.X_ENROLLMENT_STATUS, pp.x_program_name
					from   x_program_parameters pp,
					       x_program_enrolled pe
					where pp.x_prog_class = 'LIFELINE'
					and  pe.pgm_enroll2pgm_parameter = pp.objid
					AND  PE.X_SOURCESYSTEM = 'VMBC'
					) PE
			WHERE	1 = 1
			AND		subs.lid = xcv.lid
			AND		PE.OBJID = XCV.X_CURRENT_PE_ID;

CURSOR SL_INVOICE_cursor3 (
		ip_bill_start_date in date,
		ip_bill_end_date   in date
) IS
			SELECT
			  xcv.lid, xcv.X_CURRENT_MIN, xcv.X_CURRENT_ESN, xcv.x_minutes_delivered_dt,
			  xcv.X_CURRENT_PGM_START_DATE, xcv.x_invoice_reason, xcv.x_current_active_date,
			  xcv.X_BENEFIT_DELVD_CARRIER_ID, xcv.X_BENEFIT_DELVD_CARRIER_NAME, xcv.X_BENEFIT_DELVD_ESN, xcv.X_BENEFIT_DELVD_MIN,
			  xcv.X_BENEFIT_DELVD_PHONE_STATUS, xcv.X_BENEFIT_DELVD_ACT_ZIPCODE, xcv.X_BENEFIT_DELVD_PART_NUM,
			  xcv.X_SHIP_ADDRESS_1, xcv.X_SHIP_ADDRESS_2, xcv.X_SHIP_CITY, xcv.X_SHIP_STATE, xcv.X_SHIP_ZIPCODE,
			  xcv.X_SHIP_DATE, xcv.X_TRACKING_NO, xcv.X_OTA_STATUS, xcv.X_OTA_UNITS,
			  xcv.X_CURRENT_PE_ID, xcv.X_BENEFIT_DELVD_PE_ID,
			  CASE WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'AT'||CHR(38)||'T%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'T-MOBILE%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'VERIZON%' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'CLARO%' AND subs.STATE = 'PR' THEN 'Y'
				   WHEN xcv.X_BENEFIT_DELVD_CARRIER_NAME LIKE 'CINGULAR%' THEN 'Y'
   			       ELSE 'N'
			  END                       APPROVED_CARRIER,
              DECODE(xcv.X_CURRENT_ENROLLED,'N','Y','N')    as DEENROLL,
              xcv.X_CURRENT_ENROLLED_DATE                   as ENROLLDATE,
              DECODE(xcv.X_CURRENT_ENROLLED,'Y',NULL,
                     xcv.X_CURRENT_ENROLLED_DATE)           as DEENROLL_DATE,
              DECODE(xcv.X_DEENROLL_REASON,NULL,'Y',
                     SUBSTR(X_DEENROLL_REASON,1,1))    	    as BILL,
			  CASE WHEN xcv.lid BETWEEN 80000000 AND 89999999
			       THEN 'Y'
				   ELSE 'N'
                   END                     				   as TEXAS,
 			  subs.full_name                               as FULL_NAME,
              subs.X_HOMENUMBER                            as HOME_PHONE,
              subs.ADDRESS_1                               as BILL_ADDRESS1,
              subs.ADDRESS_2                               as BILL_ADDRESS2,
              subs.CITY                                    as BILL_CITY,
              subs.STATE                                   as BILL_STATE,
              subs.ZIP                                     as BILL_ZIP5,
			  pe.X_ENROLLMENT_STATUS		               as LL_STATUS,
			  pe.x_program_name							   as X_CURRENT_PROG_NAME
			FROM	(select *
					from x_sl_currentvals xcv
					where 1 = 1
					AND   xcv.X_CURRENT_ENROLLED = 'N'
					AND xcv.X_DEENROLL_REASON like 'H%'
					AND NVL(xcv.X_CURRENT_ENROLLED_DATE,ip_bill_start_date) >= ip_bill_start_date
					AND xcv.x_minutes_delivered_dt >= ip_bill_start_date
					AND xcv.x_minutes_delivered_dt <  ip_bill_end_date
					)  xcv,
					x_sl_subs            subs,
					(
					SELECT
					      pe.objid, pe.X_ENROLLMENT_STATUS, pp.x_program_name
					from   x_program_parameters pp,
					       x_program_enrolled pe
					where pp.x_prog_class = 'LIFELINE'
					and  pe.pgm_enroll2pgm_parameter = pp.objid
					AND  PE.X_SOURCESYSTEM = 'VMBC'
					) PE
			WHERE	1 = 1
			AND		subs.lid = xcv.lid
			AND		PE.OBJID = XCV.X_CURRENT_PE_ID;

/****                    Variables                            ****/
sl_invoice_rec			SL_INVOICE_cursor2%rowtype;

v_bdate					date;
v_bill_start_date		date;
v_bill_end_date			date;
v_batchdate			sa.x_sl_invoice.X_BATCH_DATE%type;
v_rowsinserted			number := 0;
v_totalinserted			number := 0;
v_FIRST_NAME			sa.x_sl_invoice.X_FIRST_NAME%type;
v_LAST_NAME 			sa.x_sl_invoice.X_LAST_NAME%type;

procedure insert_row IS
BEGIN
    get_first_last_name(sl_invoice_rec.LID,sl_invoice_rec.Full_Name,v_first_name, v_last_name);

    BEGIN
	INSERT INTO X_SL_INVOICE
     (OBJID,
	  X_BATCH_DATE, X_LIFELINE_ID, X_BILL_PART_SERIAL_NO, X_CURRENT_PART_SERIAL_NO, X_BILL_X_MIN,  X_CURRENT_X_MIN,
	  X_PHONE_STATUS,      X_ACTIVATION_ZIPCODE,     X_LL_STATUS,   X_ACT_DATE,   X_PART_NUMBER, X_FIRST_NAME,   X_LAST_NAME, X_HOME_PHONE,
      X_SHIP_ADDRESS_1,   X_SHIP_ADDRESS_2,   X_SHIP_CITY,   X_SHIP_STATE,   X_SHIP_ZIPCODE,   X_SHIP_DATE,   X_TRACKING_NO,
      X_ENROLLDATE,      X_DEENROLL,   X_DEENROLL_DATE,   X_BILL,    X_PROGRAM_START_DATE,  X_CARRIER_ID,   X_CARRIER_NAME, X_TEXAS,
      X_BILL_ADDRESS1,    X_BILL_ADDRESS2,      X_BILL_CITY,   X_BILL_STATE,   X_BILL_ZIP5,
      X_APPROVED_CARRIER, X_EXCLUSION, X_BILL_STATUS, X_INVOICE_REASON,
      X_BILL_PROGRAM_NAME,     X_CURRENT_PROGRAM_NAME,    X_BENEFIT_DELIV_DATE, X_OTA_STATUS, X_OTA_UNITS,
	  X_EUCL_RATE, X_RATECENTER_ST)
	SELECT
	  sa.SEQU_X_SL_INVOICE.nextval, v_batchdate,  sl_invoice_rec.LID,  sl_invoice_rec.X_BENEFIT_DELVD_ESN, sl_invoice_rec.X_CURRENT_ESN, sl_invoice_rec.X_BENEFIT_DELVD_MIN, sl_invoice_rec.X_CURRENT_MIN,
	  sl_invoice_rec.X_BENEFIT_DELVD_PHONE_STATUS, sl_invoice_rec.X_BENEFIT_DELVD_ACT_ZIPCODE, sl_invoice_rec.LL_STATUS, sl_invoice_rec.x_current_active_date,
	  sl_invoice_rec.X_BENEFIT_DELVD_PART_NUM, v_FIRST_NAME, v_LAST_NAME,  SL_INVOICE_REC.HOME_PHONE,
	  SL_INVOICE_REC.X_SHIP_ADDRESS_1, SL_INVOICE_REC.X_SHIP_ADDRESS_2, SL_INVOICE_REC.X_SHIP_CITY, SL_INVOICE_REC.X_SHIP_STATE,
	  sl_invoice_rec.X_SHIP_ZIPCODE, sl_invoice_rec.X_SHIP_DATE, sl_invoice_rec.X_TRACKING_NO,
	  SL_INVOICE_REC.ENROLLDATE, SL_INVOICE_REC.DEENROLL, SL_INVOICE_REC.DEENROLL_DATE, SL_INVOICE_REC.BILL, sl_invoice_rec.X_CURRENT_PGM_START_DATE,
	  sl_invoice_rec.X_BENEFIT_DELVD_CARRIER_ID, sl_invoice_rec.X_BENEFIT_DELVD_CARRIER_NAME,
	  sl_invoice_rec.TEXAS, sl_invoice_rec.BILL_ADDRESS1, sl_invoice_rec.BILL_ADDRESS2, sl_invoice_rec.BILL_CITY, sl_invoice_rec.BILL_STATE,
	  sl_invoice_rec.BILL_ZIP5, sl_invoice_rec.APPROVED_CARRIER, NULL /*exclusion*/, 'Y' /*bill_STATUS*/,
	  sl_invoice_rec.x_invoice_reason,
      case 	   --X_BILL_PROGRAM_NAME
	  when SL_INVOICE_REC.X_CURRENT_PE_ID <> SL_INVOICE_REC.X_BENEFIT_DELVD_PE_ID
	  then (SELECT pp.x_program_name
			FROM  X_PROGRAM_ENROLLED PE,
				X_PROGRAM_PARAMETERS PP
			WHERE PE.OBJID = SL_INVOICE_REC.X_BENEFIT_DELVD_PE_ID
			AND   pp.objid = pe.pgm_enroll2pgm_parameter)
	  else SL_INVOICE_REC.X_CURRENT_PROG_NAME
	  end,
	  SL_INVOICE_REC.X_CURRENT_PROG_NAME, sl_invoice_rec.x_minutes_delivered_dt,
	  sl_invoice_rec.X_OTA_STATUS, sl_invoice_rec.X_OTA_UNITS,
	  null EUCL_RATE,  null ratecenter_st
	FROM DUAL;
	EXCEPTION
	WHEN OTHERS THEN
         raise_application_error(-20101, 'ERROR: Inserting into X_SL_INVOICE '||chr(10)||
		 'Lifeline => '||sl_invoice_rec.LID
		 ||SQLERRM
		 );
	END;

	v_rowsinserted := v_rowsinserted + 1;
    v_totalinserted := v_totalinserted + 1;

	IF (v_rowsinserted = 5000)
    THEN
	     COMMIT;
		 v_rowsinserted := 0;
    END IF;
END insert_row;

BEGIN
dbms_output.put_line('BEGIN POPULATE_X_SL_INVOICE  : '||( to_char(sysdate, 'mm/dd/yyyy HH24:MI:SS')  ) );

v_batchdate := sysdate;
--OPEN check_invoice(v_batchdate);
--FETCH check_invoice INTO check_invoice_rec;
--IF check_invoice%FOUND
--THEN
--	raise_application_error (-20099,'Existing invoicing, NOT more than one invoicing permitted during the day' ) ;
--ELSE
/****                    Compute bill_start_date and bill_end_date                           *****/

IF TRUNC(SYSDATE) BETWEEN TRUNC(SYSDATE,'MONTH')     --DAY 01 OF CURRENT MONTH
                  AND     TRUNC(SYSDATE,'MONTH')+4   --DAY 05 OF CURRENT MONTH
THEN
    v_bill_start_date := TRUNC(ADD_MONTHS(SYSDATE,-1),'MONTH');  --FIRST DAY OF THE PREVIOUS MONTH
ELSE
    v_bill_start_date := TRUNC(SYSDATE,'MONTH');  --FIRST DAY OF THE CURRENT MONTH
END IF;

v_bill_end_date := ADD_MONTHS(v_bill_start_date,1);

dbms_output.put_line('Bill_start '||to_char(v_bill_start_date,'mm/dd/yy')||'   Bill_End '||to_char(v_bill_end_date,'mm/dd/yy'));

-- main cursor to retrieve billable lifelines between bill_start_date and bill_end_date
BEGIN
OPEN SL_INVOICE_cursor1(v_bill_start_date,v_bill_end_date);
IF SL_INVOICE_cursor1%ISOPEN THEN
	LOOP
	FETCH SL_INVOICE_cursor1 INTO sl_invoice_rec;
	EXIT WHEN SL_INVOICE_cursor1%NOTFOUND;
		insert_row;
	END LOOP;
	COMMIT;
	CLOSE SL_INVOICE_cursor1;
END IF;
EXCEPTION
	WHEN OTHERS THEN
	    raise_application_error(-20101, 'ERROR: SL_INVOICE_cursor1 '||chr(10)
		    ||SQLERRM);
END;
dbms_output.put_line('ROWS INSERTED: '||v_totalinserted||'  bATCH DATE: '||v_batchdate||'      end loop:'||( to_char(sysdate, 'mm/dd/yyyy HH24:MI:SS')  ) );
BEGIN
OPEN SL_INVOICE_cursor2(v_bill_start_date,v_bill_end_date);
IF SL_INVOICE_cursor2%ISOPEN THEN
	LOOP
	FETCH SL_INVOICE_cursor2 INTO sl_invoice_rec;
	EXIT WHEN SL_INVOICE_cursor2%NOTFOUND;
		insert_row;
	END LOOP;
	COMMIT;
	CLOSE SL_INVOICE_cursor2;
END IF;
EXCEPTION
	WHEN OTHERS THEN
	    raise_application_error(-20101, 'ERROR: SL_INVOICE_cursor2 '||chr(10)
		    ||SQLERRM);
END;
dbms_output.put_line('ROWS INSERTED: '||v_totalinserted||'  bATCH DATE: '||v_batchdate||'      end loop:'||( to_char(sysdate, 'mm/dd/yyyy HH24:MI:SS')  ) );
BEGIN
OPEN SL_INVOICE_cursor3(v_bill_start_date,v_bill_end_date);
IF SL_INVOICE_cursor3%ISOPEN THEN
	LOOP
	FETCH SL_INVOICE_cursor3 INTO sl_invoice_rec;
	EXIT WHEN SL_INVOICE_cursor3%NOTFOUND;
		insert_row;
	END LOOP;
	COMMIT;
	CLOSE SL_INVOICE_cursor3;
END IF;
EXCEPTION
	WHEN OTHERS THEN
	    raise_application_error(-20101, 'ERROR: SL_INVOICE_cursor3 '||chr(10)
		    ||SQLERRM);
END;
dbms_output.put_line('ROWS INSERTED: '||v_totalinserted||'  bATCH DATE: '||v_batchdate||'      end loop:'||( to_char(sysdate, 'mm/dd/yyyy HH24:MI:SS')  ) );

IF v_totalinserted > 0 THEN
	-- Determine if lifeline is excluded. NOT change the logical order for finding X_EXCLUSION (business requirement)
	get_duplicate_esn(v_batchdate,v_bill_start_date,v_bill_end_date);
	get_duplicate_min(v_batchdate,v_bill_start_date,v_bill_end_date);
	get_invalid_fields(v_batchdate,v_bill_start_date,v_bill_end_date);
	get_texas_inbound(v_batchdate,v_bill_start_date,v_bill_end_date);
	v_bdate:=sysdate;
	--Exclusion No approved Carrier
	BEGIN
	UPDATE	X_SL_INVOICE INV
	SET		X_EXCLUSION = '22'
	WHERE	X_BATCH_DATE	= v_batchdate
	AND		X_EXCLUSION IS NULL
	AND		X_APPROVED_CARRIER = 'N';
	EXCEPTION
		WHEN OTHERS THEN
	   		 raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_EXCLUSION = 22 '||chr(10)
		  	  ||SQLERRM);
	END;
	DBMS_OUTPUT.PUT_LINE(to_char(v_bdate,'hh24:mi:ss')||' to '||to_char(sysdate,'hh24:mi:ss')||'  update not approved carrier '||sql%rowcount);v_bdate:=sysdate;
	COMMIT;

	get_duplicate_address(v_batchdate,v_bill_start_date,v_bill_end_date);

	BEGIN
	UPDATE  X_SL_INVOICE
	SET		X_BILL_STATUS = 'N'
	WHERE	X_BATCH_DATE	= v_batchdate
	AND		X_EXCLUSION IS NOT NULL;
	EXCEPTION
		WHEN OTHERS THEN
	   		 raise_application_error(-20101, 'ERROR: Updating X_SL_INVOICE X_BILL_STATUS = N '||chr(10)
		  	  ||SQLERRM);
	END;
	COMMIT;
	dbms_output.put_line('BILL_STATUS UPDATED: '||( to_char(sysdate, 'mm/dd/yyyy HH24:MI:SS')  ) );

	get_rates(v_batchdate,v_bill_start_date,v_bill_end_date);
	dbms_output.put_line('GET_RATES: '||( to_char(sysdate, 'mm/dd/yyyy HH24:MI:SS')  ) );

	p_rowsinserted := v_totalinserted;
ELSE
	p_rowsinserted := 0;
END IF;
    p_batchdate    := v_batchdate;

END POPULATE_X_SL_INVOICE;
BEGIN
NULL;
END SL_INVOICING;
/