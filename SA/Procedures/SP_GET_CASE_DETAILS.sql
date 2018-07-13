CREATE OR REPLACE PROCEDURE sa."SP_GET_CASE_DETAILS" (
    IP_ESN IN VARCHAR2,
    IP_MIN IN VARCHAR2,
    err_code OUT NUMBER,
    err_msg OUT VARCHAR2,
    p_recordset OUT SYS_REFCURSOR)
AS
  l_case_type  CONSTANT VARCHAR2(30) :='Unlock Policy';
  l_case_title CONSTANT VARCHAR2(30) :='Unlock Phone Request';
  v_case_id    NUMBER;
BEGIN
  IF ip_esn IS NULL AND ip_min IS NULL THEN
    err_code:=-1;
    err_msg :='Both ESN and MIN can not be null';
  ELSE
    --Looking for the Unlock case.
    /*SELECT objid
    INTO v_case_id
    FROM sa.table_case
    WHERE (x_esn    = ip_esn
    OR x_min        = ip_min)
    AND x_case_type = l_case_type
    AND title       = l_case_title;*/
    OPEN p_recordset
     FOR SELECT x_esn,
                x_min,
                alt_e_mail,
                alt_first_name,
                id_number,
                cd.*
           FROM table_x_case_detail cd,
                table_case tc
          WHERE tc.objid=DETAIL2CASE
            AND (x_esn = ip_esn OR x_min = ip_min)
            AND x_case_type = l_case_type
            AND title = l_case_title;
    /*SELECT 'GENCODE'
    AS
    X_NAME,
    RTRIM ( XMLAGG (XMLELEMENT (e, X_VALUE || ',')).EXTRACT ('//text()'), ',') X_VALUE FROM TABLE_X_CASE_DETAIL WHERE (X_NAME LIKE('UNLOCK_GENCODE%')) AND DETAIL2CASE IN
    ( SELECT OBJID FROM TABLE_CASE WHERE objid  = v_case_id
    )
    UNION
    SELECT X_NAME ,
    X_VALUE
    FROM TABLE_X_CASE_DETAIL
    WHERE (X_NAME   IN ('SPC CODE','UNLOCK_CODE1','UNLOCK_CODE2','UNLOCK_CODE3'))
    AND DETAIL2CASE IN
    ( SELECT OBJID FROM TABLE_CASE WHERE objid  = v_case_id
    ) ;*/
    err_code :=0;
    err_msg  :='Success';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  err_code := SQLCODE;
  err_msg  := SUBSTR(SQLERRM, 1, 200);
END;
/