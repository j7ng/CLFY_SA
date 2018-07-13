CREATE OR REPLACE PACKAGE BODY sa."APEX_CREATE_FLASH_BATCH" IS

  PROCEDURE LOAD_FILE (P_USER VARCHAR2) IS
    type split_tbl_ty is table of varchar2(500);
    st split_tbl_ty := split_tbl_ty();
    tblob blob;
    v_data_array      wwv_flow_global.vc_arr2;
    myrec varchar2(4000);
----------------------------------------------------------------------------
procedure split( p_list in out varchar2 , p_del varchar2,split_tbl in out split_tbl_ty)
--------------------------------------------------------------------------------
is
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
procedure split( p_blob blob , p_del varchar2,split_tbl in out split_tbl_ty)
--------------------------------------------------------------------------------
is
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
                  EXECUTE IMMEDIATE ' insert into x_create_flash_throttle(mdn,esn, INSERT_DATE, INSERTED_BY,CREATE_FLASH ) values (:1,:2,:3,:4,:5) '
                  USING   v_data_array(1),
                          v_data_array(2),
                          SYSDATE,
                        P_USER,
                          'N';
       commit;

      EXCEPTION
      when no_data_found then
      null;
      WHEN OTHERS THEN
         NULL;
      END;

   --       commit;

 end loop;
--EXECUTE IMMEDIATE ' DELETE FROM WWV_FLOW_FILES WHERE UPPER(UPDATED_BY) = :1 AND UPDATED_ON >= TRUNC(SYSDATE) ' USING upper(P_USER);
--COMMIT;
end;

 PROCEDURE LOAD_FILE_EXPIRE (P_USER VARCHAR2) IS
    type split_tbl_ty is table of varchar2(500);
    st split_tbl_ty := split_tbl_ty();
    tblob blob;
    v_data_array      wwv_flow_global.vc_arr2;
    myrec varchar2(4000);
----------------------------------------------------------------------------
procedure split( p_list in out varchar2 , p_del varchar2,split_tbl in out split_tbl_ty)
--------------------------------------------------------------------------------
is
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
procedure split( p_blob blob , p_del varchar2,split_tbl in out split_tbl_ty)
--------------------------------------------------------------------------------
is
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
                  EXECUTE IMMEDIATE ' insert into x_create_flash_throttle(mdn,esn, INSERT_DATE, INSERTED_BY,EXPIRE_FLASH ) values (:1,:2,:3,:4,:5) '
                  USING   v_data_array(1),
                          v_data_array(2),
                          SYSDATE,
                        P_USER,
                          'N';
       commit;

      EXCEPTION
      when no_data_found then
      null;
      WHEN OTHERS THEN
         NULL;
      END;

   --       commit;

 end loop;
--EXECUTE IMMEDIATE ' DELETE FROM WWV_FLOW_FILES WHERE UPPER(UPDATED_BY) = :1 AND UPDATED_ON >= TRUNC(SYSDATE) ' USING upper(P_USER);
--COMMIT;
end;
PROCEDURE CREATE_FLASH (P_USER IN VARCHAR2, P_EXP_DT IN NUMBER, P_FLASH_TEXT IN VARCHAR2, P_START_DATE IN VARCHAR2, P_END_DATE IN VARCHAR2, P_TITLE IN VARCHAR2, msg out varchar2) IS
    CURSOR C_ESN IS
        SELECT  A.*
        FROM    TABLE_PART_INST A, x_create_flash_throttle B
        WHERE   1=1
        AND     A.PART_SERIAL_NO = B.ESN
        AND     A.X_DOMAIN||''='PHONES'
        AND     B.INSERT_DATE>=TRUNC(SYSDATE)
        AND     B.INSERTED_BY = P_USER
        AND     B.CREATE_FLASH='N';

    CURSOR  C_SITE_PART (ESN IN VARCHAR2) IS
        SELECT  *
        FROM    TABLE_SITE_PART A
        WHERE   1=1
        AND     A.X_SERVICE_ID = ESN
        AND     A.PART_STATUS = 'Active'
        AND     A.INSTALL_DATE = (  SELECT  MAX(INSTALL_DATE)
                                  FROM    TABLE_SITE_PART
                                  WHERE   X_SERVICE_ID=A.X_SERVICE_ID
                                  AND     PART_STATUS='Active');
    C_SP  C_SITE_PART%ROWTYPE;

    V_EXIST       NUMBER;
    V_FLASH_TEXT  VARCHAR2(5000);
    V_END_DATE    DATE;

 BEGIN
    V_FLASH_TEXT:=REPLACE(P_FLASH_TEXT,CHR(39),CHR(39)||CHR(39));
    FOR C_FLASH IN C_ESN
    LOOP
      BEGIN
        IF P_EXP_DT = 1 THEN
          IF C_SITE_PART%ISOPEN THEN
            CLOSE C_SITE_PART;
          END IF;
          OPEN C_SITE_PART(C_FLASH.PART_SERIAL_NO);
          FETCH C_SITE_PART INTO C_SP;
          IF C_SITE_PART%FOUND THEN
            V_END_DATE := NVL(C_SP.X_EXPIRE_DT,'01-JAN-1753');
          END IF;
          CLOSE C_SITE_PART;
        ELSE
          V_END_DATE:=P_END_DATE;
        END IF;

        SELECT  COUNT(*) INTO V_EXIST
        FROM    TABLE_ALERT
        WHERE   1=1
        AND     ALERT2CONTRACT = C_FLASH.OBJID
        AND     TITLE=P_TITLE
        AND     END_DATE>=TRUNC(SYSDATE);

        IF V_EXIST >0 THEN
            UPDATE  TABLE_ALERT
            SET     END_DATE=TRUNC(SYSDATE-1),
                    TITLE=DECODE (TITLE, P_TITLE, SUBSTR(TITLE,1,5)||SYSDATE, TITLE)
            WHERE   ALERT2CONTRACT = C_FLASH.OBJID;
            COMMIT;
        END IF;

            INSERT INTO TABLE_ALERT
                (   OBJID, START_DATE, END_DATE, ACTIVE, ALERT2CONTRACT, TITLE, ALERT_TEXT)
            VALUES
                (   sa.SEQ('ALERT'), P_START_DATE,V_END_DATE,1,
                C_FLASH.OBJID, P_TITLE, '<font color="brown"><p>'||V_FLASH_TEXT||'</p></font>');
            COMMIT ;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            msg:='error : '||SQLERRM||P_TITLE;
          WHEN OTHERS THEN
          msg:='error : '||SQLERRM||P_TITLE;

        END;
    END LOOP;
    V_FLASH_TEXT:=NULL;
    V_END_DATE:=NULL;

  END;

  PROCEDURE EXPIRE_FLASH (P_USER IN VARCHAR2) IS
    CURSOR C_FLASH IS
      SELECT  A.OBJID, C.ESN, a.end_date
      FROM TABLE_ALERT A, TABLE_PART_INST B, X_CREATE_FLASH_THROTTLE C
      WHERE 1=1
      AND B.PART_SERIAL_NO = C.ESN
      AND C.EXPIRE_FLASH='N'
      AND C.INSERTED_BY = P_USER
      AND B.X_DOMAIN='PHONES'
      AND A.ALERT2CONTRACT = B.OBJID
      AND A.TITLE IN ('High Data Deactivations','High Data Suspension','High Data Throttled','Credit Card Discrepancy','Loss Prevention Abuse','Loss Prevention Other')
      AND TO_CHAR(A.END_DATE,'DD-MON-YYYY')>=TO_CHAR(SYSDATE,'DD-MON-YYYY');
  BEGIN
    FOR I IN C_FLASH
    LOOP
      UPDATE  TABLE_ALERT
      SET     END_DATE =  TRUNC(SYSDATE-1)
      WHERE   OBJID = I.OBJID;
      IF SQL%ROWCOUNT = 1 THEN
        COMMIT;
        UPDATE  X_CREATE_FLASH_THROTTLE
        SET     EXPIRE_FLASH='Y'
        WHERE   ESN= I.ESN
        AND     EXPIRE_FLASH='N';
        COMMIT;
      END IF;
    END LOOP;
  END;

  PROCEDURE VALIDATE_USER (P_USER IN VARCHAR2, P_PWD IN VARCHAR2, P_PRIV OUT VARCHAR2, P_MSG OUT VARCHAR2, P_SUCCESS OUT NUMBER) IS
    PEN1 VARCHAR2(100);
    V_CNT NUMBER;

    BEGIN
      PEN1:=PENCRYPT(P_PWD);
      SELECT COUNT(*)INTO V_CNT FROM TABLE_USER
      WHERE S_LOGIN_NAME=UPPER(P_USER)
      AND WEB_PASSWORD=PEN1;
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

  END;

/