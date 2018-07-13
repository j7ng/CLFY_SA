CREATE OR REPLACE PROCEDURE sa.GEN_ECOMM_TST_INVENTORY( v_action OUT VARCHAR2, p_loop_max IN NUMBER, p_part_number IN VARCHAR2 ) AS

PRAGMA AUTONOMOUS_TRANSACTION;
--DECLARE
is_inbound CONSTANT VARCHAR2(1) := 'Y';-- 'Y' Will log into sa.ecomm_generated_inventory table, to create inventory for OFS.
                                      -- 'N' to just create some ESN's for testing.
v_loop_max NUMBER := p_loop_max;
v_esn VARCHAR2(20);
v_pin VARCHAR2(20);
v_sim VARCHAR2(25);
v_tech sa.table_part_num.x_technology%TYPE := NULL;
v_sim_tmp VARCHAR2(25);
v_is_lte NUMBER(1) := 0;

v_part_number_pin varchar2(30) := NULL; --Telcel'TCNS00040ILD' ;STRAIGHTTALK: 'NTPMP00045'; TRACFONE: -- NET10: --NTPS30900;  SIMPLE MOBILE: --'SMNS0050ILD'; TELCEL --'TCAPPUNLILD60' TSAPP40300
v_part_number_esn varchar2(30) := NULL; --'TCBYOPVZ'; --Telcel: 'TCBYOPVZ';--STRAIGHTTALK: --NTLG200CP ;TRACFONE --'TF1100P4' ; NET10: 'NT1100P4' --SIMPLE MOBILE: PHSM64PSIMT5B; TELCEL: 'TCHUH867G3P4'  TFBYOPC
v_part_number_sim varchar2(30) := NULL;--STRAGIHT TALK: '' ;SIMPLE MOBILE: --'SM64PSIMT5B' TRACFONE/NET: --'TF64SIMC4'; TC: 'TF64PSIMT5'
v_cnt NUMBER;
v_sim_lookup_pn table_part_num.part_number%TYPE;
too_much_to_log EXCEPTION;
unsupported_domain EXCEPTION;
--v_action varchar2(500);

v_pin_serial_num table_part_inst.part_serial_no%type;
v_domain table_part_inst.x_domain%type;

BEGIN

    SELECT s_domain
    INTO v_domain
    FROM sa.table_part_num
    WHERE s_part_number = p_part_number;

  v_action := 'IF v_domain: ' || v_domain;
  IF v_domain = 'REDEMPTION CARDS' THEN
    v_part_number_pin := p_part_number;
  ELSIF v_domain = 'PHONES' THEN
    v_part_number_esn := p_part_number;


    v_action := 'Get v_is_lte value';
    SELECT COUNT(1)
    INTO v_is_lte
    FROM table_part_num pn, table_x_part_class_params pcp,table_x_part_class_values pcv
    WHERE pn.part_num2part_class = pcv.value2part_class
    AND pcv.value2class_param = pcp.objid
    AND pcp.x_param_name = 'PHONE_GEN'
    AND pcv.x_param_value = '4G_LTE'
    AND  pn.part_number = p_part_number;

  ELSIF v_domain = 'SIM CARDS' THEN
    v_part_number_sim := p_part_number;
  ELSE
    RAISE unsupported_domain;
  END IF;

  v_action := 'IF v_esn IS NOT NULL OR v_pin IS NOT NULL OR v_sim IS NOT NULL THEN';
  IF v_esn IS NOT NULL OR v_pin IS NOT NULL OR v_sim IS NOT NULL THEN
    v_loop_max := 1; --ONLY INSERT AN EXACT VALUE ONCE INTO THE DB.
  END IF;

  IF ( (is_inbound='Y') AND (v_part_number_pin IS NOT NULL) AND (v_part_number_esn IS NOT NULL) ) THEN
    DBMS_OUTPUT.PUT_LINE('You cannot log a PIN and an ESN in the same row in the sa.ecomm_generated_inventory table for inbounding.
      Please either change the flag is_inbound flag to N or only generate an ESN or PIN');
    RAISE too_much_to_log;
  END IF;

  v_action := 'SELECT x_technology FROM table_part_num';
  IF v_part_number_esn IS NOT NULL THEN
    SELECT x_technology
    INTO v_tech
    FROM sa.table_part_num
    WHERE s_part_number = v_part_number_esn;
  ELSE
    v_tech := NULL;
  END IF;

  v_action :='IF v_part_number_pin IS NOT NULL  THEN';
  IF v_part_number_pin IS NOT NULL  THEN
    dbms_output.put_line('PIN Part Number: '|| v_part_number_pin);
  END IF;

  IF v_part_number_esn IS NOT NULL THEN
    dbms_output.put_line('ESN Part Number: '|| v_part_number_esn);
  END IF;

  IF v_part_number_sim IS NOT NULL AND v_tech = 'GSM' THEN
    dbms_output.put_line('SIM Part Number: '|| v_part_number_sim);
  END IF;

v_action := 'FOR I IN 1..v_loop_max';
FOR I IN 1..v_loop_max
LOOP

  IF v_part_number_esn IS NOT NULL AND v_esn IS NULL THEN
    V_ESN := sa.get_test_esn(v_part_number_esn);
  END IF;

  v_action := 'Check if it should CREATE A SIM';
  IF v_part_number_sim IS NOT NULL OR v_tech = 'GSM' OR v_is_lte > 0 THEN

    IF v_part_number_sim IS NULL AND v_part_number_esn IS NOT NULL THEN

      v_action := 'SELECT count(*) FROM phone_sim_mapping';
      SELECT count(*)
      INTO v_cnt
      FROM sa.phone_sim_mapping
      WHERE PHONE_PART_NUMBER = v_part_number_esn;

      IF v_cnt = 0 THEN

      BEGIN
          v_action := 'Looking for compatible sim for: ' || v_part_number_esn || ' from CARRIERSIMPREF';
          SELECT sim_profile
          INTO v_sim_lookup_pn
          FROM (
          SELECT DISTINCT s.sim_profile,
                                   s.rank
                   FROM sa.CARRIERSIMPREF s,
                        sa.TABLE_PART_NUM pn,
                        sa.table_part_num sim_pn
                   LEFT OUTER JOIN sa.MTM_PART_NUM22_X_FF_CENTER2 xfc
                       ON sim_pn.objid = xfc.part_num2ff_center
                   WHERE pn.x_dll BETWEEN s.min_dll_exch AND s.max_dll_exch
                           AND pn.part_number = v_part_number_esn
                           AND sim_pn.part_number = s.sim_profile
                           AND RANK!= 0
                           ANd xfc.part_num2ff_center IS NOT NULL
                           ORDER BY RANK
                ) where rownum < 2;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
        v_action := 'Looking for compatible sim for: ' || v_part_number_esn || ' from part_inst';
        SELECT pns.s_part_number sim_pn
        INTO v_sim_lookup_pn
        FROM table_part_inst phone, table_mod_level ml, table_part_num pn,table_x_sim_inv sinv,table_mod_level mls, table_part_num pns
        WHERE phone.n_part_inst2part_mod = ml.objid
            AND ml.part_info2part_num = pn.objid
            AND sinv.x_sim_serial_no = phone.x_iccid
            AND x_sim_inv2part_mod = mls.objid
            AND mls.part_info2part_num = pns.objid
            AND PN.S_DOMAIN = 'PHONES'
            and x_part_inst_status = '52'
            AND pn.s_part_number = v_part_number_esn
            AND ROWNUM < 2;
          END;

            IF SQL%ROWCOUNT = 1 THEN
                v_action := 'Inserting ' || v_part_number_esn || ', ' || v_sim_lookup_pn ||' into phone_sim_mapping';
                INSERT INTO sa.phone_sim_mapping VALUES (v_part_number_esn,v_sim_lookup_pn );
                COMMIT;
            END IF;
      END IF;

      v_action := 'SELECT FROM phone_sim_mapping';
      SELECT SIM_PART_NUMBER
      INTO v_part_number_sim
      FROM sa.phone_sim_mapping
      WHERE PHONE_PART_NUMBER = v_part_number_esn;

      v_action := 'after SIM_PART_NUMBER';
    END IF;

      v_action := 'SA.get_test_SIM(v_part_number_sim)';
      v_sim_tmp := sa.get_test_SIM(v_part_number_sim);

    IF v_sim IS NOT NULL THEN--Manual PHYSICAL SIM load
      v_action := 'UPDATE OLD SIM WITH NEW PHYSICAL SIM';
      UPDATE table_x_sim_inv
      SET x_sim_serial_no = v_sim
      WHERE x_sim_serial_no = v_sim_tmp;
      COMMIT;
    END IF;

      v_sim := v_sim_tmp;

    --IF BYOP/SM
    if v_part_number_sim like 'PH%' OR v_part_number_esn like 'PH%' then
--      v_action := 'update table_x_sim_inv';
       v_action := 'CHANGE SIM serial number for BYOP';

      update table_x_sim_inv
      set x_sim_serial_no = '8901' || V_ESN
      where x_sim_serial_no = v_sim;

      v_sim := '8901' || V_ESN;
      COMMIT;
    end if;

    v_action := 'ADD SIM TO ESN IN TABLE_PART_INST';
    UPDATE TABLE_PART_INST
    SET X_ICCID = V_SIM
    WHERE PART_SERIAL_NO = V_ESN;

    COMMIT;
    dbms_output.put_line ('SIM (' || I || '): ' || V_SIM); -- PUT PART NUMBER HERE
  END IF;


  v_action := 'Create a NEW ESN';
  dbms_output.put_line ( 'ESN (' || I || '): ' || V_ESN );

  IF v_part_number_pin IS NOT NULL THEN
    v_action := 'Create a Valid PIN';
    V_PIN := sa.get_test_pin(v_part_number_pin);
    dbms_output.put_line ('PIN (' || I || '): ' || V_PIN); -- PUT PART NUMBER HERE

    IF v_esn IS NOT NULL THEN

      v_action := 'QUEING PIN';
      -- Add Pin to Queue
      Update Table_Part_Inst
      SET x_part_inst_status = '400',
      Last_Trans_Time = Sysdate,
      Status2x_Code_Table = ( Select Objid From sa.Table_X_Code_Table Where X_Code_Number = '400'),
      Part_To_Esn2part_Inst = (Select Objid From Table_Part_Inst Where Part_Serial_No = V_ESN)
      WHERE X_Red_Code = V_PIN;
      COMMIT;
    END IF;
  END IF;


  IF  is_inbound = 'Y' THEN

    IF v_pin IS NOT NULL THEN
      v_action := 'select red_code';
      SELECT part_serial_no
      INTO v_pin_serial_num
      FROM table_part_inst
      WHERE x_red_code = v_pin;

      v_domain := 'REDEMPTION CARDS';
    ELSIF v_esn IS NOT NULL THEN
      v_domain := 'PHONES';
    END IF;

    v_action := 'insert into sa.ecomm_generated_inventory';
    INSERT INTO sa.ecomm_generated_inventory (serial_num,part_num,insert_date,iccid,x_red_code,domain)
    --VALUES(COALESCE(v_esn,v_pin_serial_num),COALESCE(v_part_number_esn,v_part_number_pin),SYSDATE,v_sim,v_pin,v_domain);
    VALUES(COALESCE(v_esn,v_pin_serial_num,v_sim),COALESCE(v_part_number_esn,v_part_number_pin,v_part_number_sim),SYSDATE,v_sim,v_pin,v_domain);
/*
    --No Delete priv in SIT1 or TST
    v_action := 'delete from table_part_inst';
    DELETE table_part_inst
    WHERE part_serial_no=COALESCE(v_esn,v_pin_serial_num);
*/

    COMMIT;
  END IF;

  v_esn := NULL;
  v_pin := NULL;
  v_sim := NULL;
  v_tech := NULL;
END LOOP;

v_action := 'success';

EXCEPTION
  WHEN too_much_to_log THEN
    ROLLBACK;
    dbms_output.put_line('too_much_to_log');
    dbms_output.put_line('v_action: ' || v_action || ' ' || sqlcode || ': ' || sqlerrm);
    v_action := v_action || ' too_much_to_log ' || sqlcode || ': ' || sqlerrm;
  WHEN unsupported_domain THEN
    ROLLBACK;
    dbms_output.put_line('unsupported_domain');
    dbms_output.put_line('v_action: ' || v_action || ' ' || sqlcode || ': ' || sqlerrm);
    v_action := v_action || ' unsupported_domain ' || sqlcode || ': ' || sqlerrm;
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('v_action: ' || v_action || ' ' || sqlcode || ': ' || sqlerrm);
   v_action := v_action || ' ' || sqlcode || ': ' || sqlerrm;

END;
/