CREATE OR REPLACE PROCEDURE sa."SP_CENTURY_AC_CHANGE"
(IP_EMAIL_ID in  NUMBER)  -- Passed in by Unix Cron job

/******************************************************************************************
/* Author : Gerald Pintado
/* Date	  : 02/20/2003
/* Purpose: Finds MINs associated to Century carrier that were under status 38(RESERVED AC)
/*          and are now under status 13(ACTIVE). Then populates table(CENTURY_AC_CHANGED)
/*          with the above MINs as well as ESN and Intergate Info. Cron job will then query
/*          this table by the IP_EMAIL_ID and save the results to
/*          a text file that will be emailed to Line Management.
/******************************************************************************************/
IS
CURSOR C1
IS
SELECT A.ROWID,
       A.*,
       B.X_PART_INST_STATUS NEW_STATUS,
       B.X_NPA,
       B.X_NXX,
       C.OBJID CARRIER_OBJID,
       C.X_CARRIER_ID,
       C.X_RATE_PLAN,
       DECODE(C.X_VOICEMAIL,1,'YES','NO') VOICEMAIL,
       C.X_VM_CODE,
       DECODE(C.X_CALL_WAITING,1,'YES','NO') CALL_WAITING,
       C.X_CW_CODE
FROM sa.CENTURY_RESERVED_AC A,
     TABLE_PART_INST B,
     TABLE_X_CARRIER C
WHERE A.PART_SERIAL_NO = B.PART_SERIAL_NO
AND B.PART_INST2CARRIER_MKT = C.OBJID
AND A.TIMESTAMP IS NULL;



CURSOR C2 (C_CARRIEROBJID IN NUMBER,C_NPA IN VARCHAR2,C_NXX IN VARCHAR2)
IS
SELECT * FROM TABLE_X_ORDER_TYPE
WHERE X_ORDER_TYPE2X_CARRIER = C_CARRIEROBJID
AND x_ORDER_TYPE = 'Activation'
AND X_NPA = C_NPA
AND X_NXX = C_NXX;

c2_rec c2%rowtype;

CURSOR C3 (C_CARRIEROBJID IN NUMBER)
IS
SELECT * FROM TABLE_X_ORDER_TYPE
WHERE X_ORDER_TYPE2X_CARRIER = C_CARRIEROBJID
AND x_ORDER_TYPE = 'Activation'
AND X_NPA IS NULL
AND X_NXX IS NULL;

c3_rec c3%rowtype;


CURSOR C4 (C_ESNOBJID IN NUMBER)
IS
SELECT PART_SERIAL_NO FROM TABLE_PART_INST
WHERE OBJID = C_ESNOBJID;


v_dealer_code VARCHAR2(30);
v_ld_acct_num VARCHAR2(30);
v_market_code VARCHAR2(30);


BEGIN
 FOR C1_REC IN C1 LOOP
  IF C1_REC.X_PART_INST_STATUS <> C1_REC.NEW_STATUS THEN
   IF C1_REC.NEW_STATUS = '13' THEN

     OPEN c2(C1_REC.CARRIER_OBJID,'616',C1_REC.X_NPA);
     FETCH c2 INTO c2_rec;

     IF C2%NOTFOUND THEN
        CLOSE c2;
        OPEN c3(C1_REC.CARRIER_OBJID);
        FETCH c3 INTO c3_rec;
        CLOSE c3;
        v_dealer_code := c3_rec.x_dealer_code;
        v_ld_acct_num := c3_rec.x_ld_account_num;
        v_market_code := c3_rec.x_market_code;
     ELSE
        CLOSE c2;
        v_dealer_code := c2_rec.x_dealer_code;
        v_ld_acct_num := c2_rec.x_ld_account_num;
        v_market_code := c2_rec.x_market_code;
     END IF;

     FOR C4_REC IN C4(C1_REC.PART_TO_ESN2PART_INST) LOOP
         INSERT INTO CENTURY_AC_CHANGED
         (ESN,
          LINE,
          DEALER_CODE,
          VOICEMAIL,
          VM_CODE,
          CALL_WAITING,
          CW_CODE,
          RATE_PLAN,
          ACCT_NO,
          MARKET_CODE,
          INSERT_DATE,
          MODIFY_DATE,
          EMAIL_REQUEST_ID)
         VALUES
          (C4_REC.PART_SERIAL_NO,
           C1_REC.PART_SERIAL_NO,
           v_dealer_code,
           C1_REC.VOICEMAIL,
           C1_REC.X_VM_CODE,
           C1_REC.CALL_WAITING,
           C1_REC.X_CW_CODE,
           C1_REC.X_RATE_PLAN,
           v_ld_acct_num,
           v_market_code,
           SYSDATE,
           SYSDATE,
           IP_EMAIL_ID);

          UPDATE sa.CENTURY_RESERVED_AC
          SET TIMESTAMP = SYSDATE
          WHERE ROWID = C1_REC.ROWID;

       END LOOP;
   END IF;
  END IF;
 END LOOP;
END SP_CENTURY_AC_CHANGE;
/