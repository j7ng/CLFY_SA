CREATE OR REPLACE FUNCTION sa."GET_CC_FLAG" (in_esn IN VARCHAR2)
RETURN NUMBER
AS
  cc_flag NUMBER;
  x_val   NUMBER := 0;
  rec_val NUMBER := 0;
  v_objid NUMBER;
BEGIN
    --Making sure ESN is not new
	BEGIN
	SELECT objid INTO v_objid
      FROM table_x_call_trans
     WHERE x_service_id = in_esn
       AND ROWNUM < 2;
	EXCEPTION
    WHEN NO_DATA_FOUND THEN
             cc_flag := 2;
			 rec_val:=1;
    RETURN cc_flag;
             dbms_output.Put_line ('exception ccflag'||cc_flag);
    END;

	FOR rec IN (SELECT objid,
                       x_action_type,
                       x_reason,
					   X_TRANSACT_DATE,
					   x_service_id,
                       Count(*)
                         over ( ) cnt
                -- Specify only the columns you need, exclude the table_x_call_trans
                FROM   (SELECT *
                        FROM   table_x_call_trans
                        WHERE  x_service_id = in_esn
                               AND x_action_type + 0 IN ( 1, 3, 6, 401 )
                               AND x_sourcesystem NOT IN ( 'BATCH', 'SLBATCH' )
                        ORDER  BY objid DESC) tt
                WHERE  ROWNUM <= 2) LOOP
        IF rec.cnt = 2 THEN
          DBMS_OUTPUT.PUT_LINE ('cursor row count'||rec.cnt);


          IF rec.x_action_type IN ( 1, 3, 6 ) THEN
            --Validiating transactions other than queued
           SELECT COUNT(1) INTO  x_val
		   FROM
		   (SELECT 1
            FROM   table_x_red_card rc,
                   table_x_purch_dtl PDTL,
                   sa.table_x_purch_hdr phdr
            WHERE  1 = 1
                   AND rc.red_card2call_trans = rec.objid
                   AND PDTL.x_red_card_number = RC.x_red_code
                   AND PDTL.x_smp = RC.x_smp
				   AND PHDR.OBJID = PDTL.X_PURCH_DTL2X_PURCH_HDR
				   and   phdr.x_ics_rcode in ('1','100')
                   and   phdr.x_ics_rflag in ('SOK', 'ACCEPT')
		   UNION
		   SELECT 1
			FROM   x_program_purch_hdr bhdr,
				   x_program_purch_dtl bdtl
			WHERE  1=1
			AND    bdtl.pgm_purch_dtl2prog_hdr= bhdr.objid
			AND    bdtl.x_esn = rec.x_service_id
			AND    bhdr.x_process_date BETWEEN rec.x_transact_date-(2/(24*60)) AND    rec.x_transact_date + (2/(24*60)));

            DBMS_OUTPUT.PUT_LINE ('redemption x_val' ||x_val);

          ELSIF rec.x_action_type IN ( 401 ) THEN
            SELECT COUNT(1)
            INTO   x_val
            FROM   sa.table_x_red_card rc,
                   sa.table_x_purch_dtl pdtl,
                   sa.table_x_purch_hdr phdr
            WHERE  1 = 1
            --  AND rc.red_card2call_trans = rec.objid
              AND rc.x_red_code = rec.x_reason
              AND pdtl.x_red_card_number = rc.x_red_code
              AND pdtl.x_smp = rc.x_smp
              AND phdr.objid = pdtl.x_purch_dtl2x_purch_hdr
              --AND    phdr.x_esn = '100000000013559261'----
              AND phdr.x_ics_rcode IN ( '1', '100' )
              AND phdr.x_ics_rflag IN ( 'SOK', 'ACCEPT' );
              DBMS_OUTPUT.PUT_LINE ('queed x_val' ||x_val);
          END IF;
        ELSE
          DBMS_OUTPUT.PUT_LINE ('else row count'||REC.CNT);

          cc_flag := 2;
		  RETURN cc_flag;
        END IF;

          IF x_val > 0 THEN
            rec_val := x_val + rec_val;
            DBMS_OUTPUT.PUT_LINE ('outer x_val1'||x_val);

          END IF;
   END LOOP;

    IF rec_val = 2 THEN
      cc_flag := 0; --credit card purchase true for last two transaction
    ELSIF rec_val = 1 THEN
      cc_flag := 2; --unknow transaction (either of one will be cc/pin)
    ELSIF rec_val = 0 THEN
      cc_flag := 1; --no cc transaction found means its a pin transaction
    END IF;
RETURN cc_flag;
    dbms_output.Put_line ('after execution ccflag'||cc_flag);
EXCEPTION
  WHEN OTHERS THEN
             cc_flag := 2;
RETURN cc_flag;
             dbms_output.Put_line ('exception ccflag'||cc_flag);
END;
/