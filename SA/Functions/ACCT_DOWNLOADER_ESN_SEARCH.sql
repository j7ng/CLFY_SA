CREATE OR REPLACE FUNCTION sa."ACCT_DOWNLOADER_ESN_SEARCH"
(ip_decnum VARCHAR2)
RETURN VARCHAR2 AS
  CURSOR cur_part_inst (p_esn IN VARCHAR2) IS
    SELECT part_serial_no
    FROM table_part_inst where
    part_serial_no = p_esn;
  rec_part_inst  cur_part_inst%ROWTYPE;
  hex_meid   VARCHAR2(30);
  hex_imei   VARCHAR2(50);
  l_err_text  VARCHAR2(4000);
  v_ip_decnum VARCHAR2(30); --CR42268_My Account_Downloader_Conversion_Fix
BEGIN
  IF ip_decnum IS NULL THEN
    RETURN 'INVALID ESN PASSED';
  END IF;
  OPEN cur_part_inst(ip_decnum);
  FETCH cur_part_inst INTO rec_part_inst;
  IF cur_part_inst%FOUND THEN
    CLOSE cur_part_inst;
    RETURN rec_part_inst.part_serial_no;
  ELSE
    CLOSE cur_part_inst;

    --CR42268_My Account_Downloader_Conversion_Fix (Begin)
    IF LENGTH(ip_decnum) < 18 THEN
       v_ip_decnum := LPAD(ip_decnum, 18, '0');
    ELSE
       v_ip_decnum := ip_decnum;
    END IF;

    --hex_meid := sa.meiddectohex(ip_decnum);
    hex_meid := sa.meiddectohex(v_ip_decnum);
    --CR42268_My Account_Downloader_Conversion_Fix (ends)

    FOR i IN 0..9 LOOP
      hex_imei := hex_meid || i || '';
      OPEN cur_part_inst(TRIM(hex_imei));
      FETCH cur_part_inst INTO rec_part_inst;
      IF cur_part_inst%FOUND THEN
        CLOSE cur_part_inst;
        EXIT;
      END IF;
      CLOSE cur_part_inst;
      hex_imei := NULL;
    END LOOP;
  END IF;
  IF hex_imei IS NOT NULL THEN
    RETURN TRIM(hex_imei);
  ELSE
    RETURN 'ESN NOT FOUND';
    NULL;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err_text := sqlcode || '  ' || sqlerrm;
    INSERT INTO error_table (ERROR_TEXT,ERROR_DATE,ACTION                           ,KEY       ,PROGRAM_NAME)
                      VALUES(l_err_text,sysdate   ,'ESN retrieval of app downloader',ip_decnum ,'SA.APP_DOWNLOADER_ESN_SEARCH');
  RETURN 'ESN NOT FOUND';
END;
/
