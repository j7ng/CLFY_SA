CREATE OR REPLACE PACKAGE BODY sa."APEX_LOAD_ICCID_BATCH" IS

  PROCEDURE LOAD_FILE  (P_USER IN VARCHAR2, P_SD IN VARCHAR2, P_MNC  IN VARCHAR2, P_PO IN VARCHAR2, P_PART IN VARCHAR2, P_LTE IN NUMBER) IS
    type split_tbl_ty is table of varchar2(500);
    st split_tbl_ty := split_tbl_ty();
    tblob blob;
    v_data_array      wwv_flow_global.vc_arr2;
    myrec varchar2(4000);
----------------------------------------------------------------------------
procedure split( p_list in out varchar2 , p_del varchar2,split_tbl in out split_tbl_ty) is
--------------------------------------------------------------------------------

    l_idx    pls_integer;
    l_list    varchar2(32767):= p_list;
    l_value    varchar2(32767);
begin
    loop
        l_idx :=instr(l_list,p_del);
        if l_idx > 0 then
            split_tbl.extend;
            --dbms_output.put_line(substr(l_list,1,l_idx-1));
            split_tbl(split_tbl.count) := substr(l_list,1,l_idx-1);
            l_list:= substr(l_list,l_idx+length(p_del));
        else
            if ( p_del = ',') then
              split_tbl.extend;
              split_tbl(split_tbl.count) := l_list;
            else
              p_list := l_list;
            end if;
            exit;
        end if;
    end loop;
end ;
----------------------------------------------------------------------------
-- SPLIT  BLOB
----------------------------------------------------------------------------
procedure split( p_blob blob , p_del varchar2,split_tbl in out split_tbl_ty) IS
--------------------------------------------------------------------------------
    v_start    pls_integer := 1;
    v_blob    blob := p_blob;
    v_varchar    varchar2(32767);
    n_buffer pls_integer := 32767;
    v_remaining varchar2(32767);
begin
     dbms_output.put_line('Length of blob '||dbms_lob.getlength(v_blob));
     for i in 1..ceil(dbms_lob.getlength(v_blob) / n_buffer)
     loop
        v_varchar := v_remaining||
                     utl_raw.cast_to_varchar2(
                             dbms_lob.substr(v_blob,
                                             n_buffer-nvl(length(v_remaining),0),
                                             v_start+nvl(length(v_remaining),0)));
        /*dbms_output.put('rem='||substr(v_varchar,1,30)||'<....>'
                 ||substr(v_varchar,length(v_varchar)-10 )||'|  L='
                 ||v_start||' L1='||length(v_varchar) ); */
        --dbms_output.put_line('TAB COUNT='||split_tbl.count);
        split(v_varchar,p_del,split_tbl);
        v_remaining := v_varchar;
        --dbms_output.put_line(' <'||v_remaining||'>');
        v_start  := v_start  + n_buffer-nvl(length(v_remaining),0);
     end loop;
end ;

begin
    begin
       select blob_content into TbloB
       from wwv_flow_files a
       where upper(updated_by) =upper(P_USER)
       and created_on =(select max(created_on)
                        from wwv_flow_files
                        where upper(updated_by)=upper(P_USER));
     exception
         when no_data_found then
         dbms_output.put_line(chr(10)||chr(10)||'	"'|| '" :File not found. Exiting ..'||chr(10));
         return;
     end;

 split(tblob,chr(10),st);
 for i in 1..st.count
   loop
         myrec := replace(st(i), chr(10) ,'');
--        myrec := REPLACE (st, ',', ':');
     myrec := replace(myrec, chr(13) ,'');
    v_data_array := wwv_flow_utilities.string_to_table(myrec||',',',');
    -- v_data_array := wwv_flow_utilities.string_to_table(myrec);
      BEGIN
        IF P_LTE = 1 THEN
           EXECUTE IMMEDIATE 'insert into X_LOAD_ICCID_STG(sim,qty,pin1,puk1,pin2,puk2,imsi, INSERTED_ON, INSERTED_BY,SD_TICKET,MNC, PURCHASE_ORDER,part_number) values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13)'
            USING   v_data_array(1),
                    v_data_array(2),
                    v_data_array(3),
                    v_data_array(4),
                    v_data_array(5),
                    v_data_array(6),
                    v_data_array(7),
                    SYSDATE,
                    P_USER,
                    P_SD,
                    P_MNC,
                    P_PO,
                    P_PART;

            COMMIT;
        ELSE
            EXECUTE IMMEDIATE 'insert into X_LOAD_ICCID_STG(sim,qty,pin1,puk1,pin2,puk2, INSERTED_ON, INSERTED_BY,SD_TICKET,MNC, PURCHASE_ORDER,part_number) values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'
            USING   v_data_array(1),
                    v_data_array(2),
                    v_data_array(3),
                    v_data_array(4),
                    v_data_array(5),
                    v_data_array(6),
                    SYSDATE,
                    P_USER,
                    P_SD,
                    P_MNC,
                    P_PO,
                    P_PART;

            COMMIT;
        END IF;

      EXCEPTION
      when no_data_found then
      null;
      WHEN OTHERS THEN
         NULL;
      END;

   --       commit;

 end loop;
 -- EXECUTE IMMEDIATE ' DELETE FROM WWV_FLOW_FILES WHERE UPPER(UPDATED_BY) = :1 AND UPDATED_ON >= TRUNC(SYSDATE) ' USING upper(P_USER);
  --COMMIT;
end;


  PROCEDURE INSERT_ICCID (P_USER IN VARCHAR2,  P_SD IN VARCHAR2, P_MNC IN VARCHAR2, P_PO IN VARCHAR2, P_PART IN VARCHAR2, P_LTE IN NUMBER, P_MESSAGE OUT VARCHAR2,  P_COUNT OUT NUMBER) IS
    CURSOR C_SIM IS
      SELECT  *
      FROM    X_LOAD_ICCID_STG A
      WHERE   A.INSERTED_ON >=TRUNC(SYSDATE)
      AND     A.INSERT_FLAG='N'
      AND NOT EXISTS (SELECT 1 FROM TABLE_X_SIM_INV WHERE 1=1 AND X_SIM_SERIAL_NO= A.SIM);

    V_MOD_LEVEL   NUMBER;
    V_COUNT       NUMBER:=0;
    V_EXIST       NUMBER;
    V_TOTAL       NUMBER;

  BEGIN
    V_COUNT:=0;
    SELECT COUNT(*) INTO V_TOTAL
    FROM  sa.X_LOAD_ICCID_STG A
    WHERE  A.INSERTED_ON >=TRUNC(SYSDATE)
      AND     A.INSERT_FLAG='N';
    BEGIN
      SELECT MAX(OBJID) INTO V_MOD_LEVEL
      FROM table_mod_level
      where  part_info2part_num = ( select objid from table_part_num where part_number = P_PART);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_MESSAGE:='NO MOD LEVEL RECORD FOUND FOR THE GIVER PART ';
        RETURN;
    END;

    FOR C1_REC IN C_SIM
    LOOP

    IF P_LTE = 1 THEN
        INSERT INTO TABLE_X_SIM_INV ( OBJID, X_SIM_SERIAL_NO, X_SIM_INV_STATUS, X_SIM_PO_NUMBER, X_CREATED_BY2USER,
                                    X_SIM_INV2PART_MOD, X_SIM_INV2INV_BIN, X_INV_INSERT_DATE, X_SIM_STATUS2X_CODE_TABLE,
                                    X_SIM_MNC, X_PIN1, X_PIN2, X_PUK1, X_PUK2, X_QTY, X_SIM_IMSI )
        VALUES ( sa.SEQ ( 'X_SIM_INV'), C1_REC.SIM, '253', C1_REC.PURCHASE_ORDER, 268435556, V_MOD_LEVEL,
                 268495405, SYSDATE, 268438606, C1_REC.MNC,  C1_REC.PIN1, C1_REC.PIN2, C1_REC.PUK1, C1_REC.PUK2, C1_REC.QTY, C1_REC.IMSI );
    ELSE
        INSERT INTO TABLE_X_SIM_INV ( OBJID, X_SIM_SERIAL_NO, X_SIM_INV_STATUS, X_SIM_PO_NUMBER, X_CREATED_BY2USER,
                                    X_SIM_INV2PART_MOD, X_SIM_INV2INV_BIN, X_INV_INSERT_DATE, X_SIM_STATUS2X_CODE_TABLE,
                                    X_SIM_MNC, X_PIN1, X_PIN2, X_PUK1, X_PUK2, X_QTY )
        VALUES ( sa.SEQ ( 'X_SIM_INV'), C1_REC.SIM, '253', C1_REC.PURCHASE_ORDER, 268435556, V_MOD_LEVEL,
                 268495405, SYSDATE, 268438606, C1_REC.MNC,  C1_REC.PIN1, C1_REC.PIN2, C1_REC.PUK1, C1_REC.PUK2, C1_REC.QTY );
     END IF;
        IF SQL%ROWCOUNT=1 THEN
          COMMIT;
          V_COUNT:=V_COUNT+1;
          UPDATE X_LOAD_ICCID_STG
          SET    INSERT_FLAG='Y'
          WHERE  SIM=C1_REC.SIM;
          COMMIT;
        END IF;

    END LOOP;

      P_COUNT:=V_COUNT;


END;

  PROCEDURE VALIDATE_USER (P_USER IN VARCHAR2, P_PWD IN VARCHAR2, P_PRIV OUT VARCHAR2, P_MSG OUT VARCHAR2, P_SUCCESS OUT NUMBER) IS
    PEN1 VARCHAR2(100);
    V_CNT NUMBER;

    BEGIN
      PEN1:=PENCRYPT(P_PWD);
      SELECT COUNT(*)INTO V_CNT FROM TABLE_USER
      WHERE S_LOGIN_NAME=UPPER(P_USER)
      AND WEB_PASSWORD=PEN1
      AND STATUS=1;
      IF V_CNT>0 THEN
        SELECT USER_ACCESS2PRIVCLASS INTO P_PRIV FROM TABLE_USER WHERE S_LOGIN_NAME=UPPER(P_USER);
        CASE P_PRIV
          WHEN 268435768 THEN P_PRIV := 'Y'; P_SUCCESS:=1;
        ELSE
          P_SUCCESS:=0;
          P_PRIV:=NULL;
          P_MSG:='Not Authorized to use this Application. ';
        END CASE;
      ELSE
        P_SUCCESS:=0;
        P_MSG:='Incorrect Username/Password. Please try again';
        P_PRIV:=NULL;
      END IF;
    END;

  END; -- PACKAGE BODY
/