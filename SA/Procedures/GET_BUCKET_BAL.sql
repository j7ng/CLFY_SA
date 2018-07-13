CREATE OR REPLACE PROCEDURE sa."GET_BUCKET_BAL" (
    P_TRANS_ID IN NUMBER,
    P_BUCKET_INFO OUT sa.BI_type_tab,
    P_ERROR_NUM OUT NUMBER,
    P_ERROR_MSG OUT VARCHAR2 )
IS
  I_type_tab BI_type_tab := BI_type_tab();
BEGIN
  SELECT BI_type( igb.MEASURE_UNIT, igtb.TRANSACTION_ID, igtb.BUCKET_ID, igtb.BUCKET_BALANCE, igtb.BUCKET_VALUE, igtb.EXPIRATION_DATE,igb.BUCKET_TYPE) BULK COLLECT
  INTO P_BUCKET_INFO
  FROM gw1.ig_buckets igb,
    gw1.ig_transaction_buckets igtb,
    IG_TRANSACTION ig
  WHERE 1                 = 1
  AND igb.bucket_id       = igtb.bucket_id
  AND igtb.direction     = 'INBOUND'
  AND Igtb.Transaction_Id = P_TRANS_ID
  AND ig.Transaction_Id   =igtb.Transaction_Id
  AND IGB.RATE_PLAN       = ig.RATE_PLAN;
  --P_BUCKET_INFO          := I_type_tab;

  P_ERROR_NUM := 0;
  P_ERROR_MSG :='Success';

    IF (P_BUCKET_INFO.COUNT  =0) THEN
    P_ERROR_NUM                    :=-1;
    P_ERROR_MSG                     :='No data found';
	  RETURN;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  P_ERROR_NUM := -1;
  P_ERROR_MSG := 'NO_DATA_FOUND';
WHEN OTHERS THEN
  P_ERROR_NUM := -1;
  P_ERROR_MSG := SQLERRM;
END get_Bucket_Bal;
/