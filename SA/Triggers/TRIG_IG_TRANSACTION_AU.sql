CREATE OR REPLACE trigger sa.TRIG_IG_TRANSACTION_AU
after UPDATE on gw1.IG_TRANSACTION
FOR EACH ROW
when (
        new.STATUS = 'S'
        and new.MSID not like 'T%'
        and length(new.MSID) = 10
        AND NEW.CREATION_DATE >= SYSDATE-12/24
        and new.ORDER_TYPE IN ('A','E','AP','R')
      )

------------------------------------------------------------------------
--$RCSfile: TRIG_IG_TRANSACTION_AU.sql,v $
--$Revision: 1.5 $
--$Author: dbecerril $
--$Date: 2013/03/19 18:46:52 $
--$Log: TRIG_IG_TRANSACTION_AU.sql,v $
--Revision 1.5  2013/03/19 18:46:52  dbecerril
--Added new rate plans TFCSS1, TFCCS1 and TFCCS2.
--Trigger also checks order type in when statement for performance.
--
------------------------------------------------------------------------

declare
  V_CNT_EXISTS NUMBER;
  V_CNT_ISNULL NUMBER;
  v_debug boolean := FALSE;

begin

  SELECT COUNT(*)
  into V_CNT_ISNULL
  from sa.X_DEVICE_MGMT
  where X_TRANSACTION_ID = :new.TRANSACTION_ID
  and X_APN_UPDATE_FLAG is null
  and X_LAST_UPDATE_DATE >= sysdate-12/24;

  SELECT COUNT(*)
  into V_CNT_EXISTS
  from sa.X_DEVICE_MGMT
  where X_TRANSACTION_ID = :new.TRANSACTION_ID;

if  V_CNT_ISNULL > 0 then
    update sa.X_DEVICE_MGMT
    set X_NEW_RATE_PLAN = :new.RATE_PLAN,
    X_APN_UPDATE_FLAG = 'N',--X_APN_UPDATE_FLAG: NULL - WAITING TO BE INSERTED INTO IG_TRANSACTION;'N' - EXISTS IN IG_TRANSACTION, WAITING TO BE THROTTLED; 'Y' - HAS BEEN ADDED TO THROTTLED LIST, DO NOT PROCESS AGAIN.
    X_LAST_UPDATE_DATE = sysdate,
    X_CARRIER_ID =  :new.CARRIER_ID
    where X_TRANSACTION_ID = :new.TRANSACTION_ID;

    IF V_DEBUG THEN
      dbms_output.put_line('Update sql%rowcount: ' || sql%rowcount);
    end if;
  ELSIF V_CNT_EXISTS=0 AND :NEW.ORDER_TYPE IN ('A','E','AP') AND :NEW.RATE_PLAN IN ('TFCSS1','TFCCS1','TFCCS2') THEN --'A': Activations, 'E' Reactivations
     INSERT INTO sa.X_DEVICE_MGMT (objid,X_MIN,X_ESN,X_CURRENT_RATE_PLAN,X_NEW_RATE_PLAN,X_APN_UPDATE_FLAG,X_CREATE_DATE,X_LAST_UPDATE_DATE,X_CARRIER_ID,X_TRANSACTION_ID)
    VALUES(
          DEVICE_MGMT_SEQ.NEXTVAL,      --objid
          :NEW.MSID,                    --X_MIN
          :NEW.ESN,                      --X_ESN
          :NEW.RATE_PLAN,      --X_CURRENT_RATE_PLAN
          :NEW.RATE_PLAN, --X_NEW_RATE_PLAN
          'N',                 --X_APN_UPDATE_FLAG: NULL - WAITING TO BE INSERTED INTO IG_TRANSACTION;'N' - EXISTS IN IG_TRANSACTION, WAITING TO BE THROTTLED; 'Y' - HAS BEEN ADDED TO THROTTLED LIST, DO NOT PROCESS AGAIN.
          SYSDATE,             --X_CREATE_DATE
          SYSDATE,             --X_LAST_UPDATE_DATE
          :NEW.CARRIER_ID,     --X_CARRIER_CODE
          :NEW.TRANSACTION_ID  --X_TRANSACTION_ID
        );

    IF V_DEBUG THEN
      DBMS_OUTPUT.PUT_LINE('Insert sql%rowcount: ' || SQL%ROWCOUNT);
    END IF;
end if;

END;
/