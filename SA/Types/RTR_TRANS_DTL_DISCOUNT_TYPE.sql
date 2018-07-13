CREATE OR REPLACE TYPE sa.rtr_trans_dtl_discount_type AS OBJECT
  /*************************************************************************************************************************************
  --$RCSfile: RTR_TRANS_DTL_DISCOUNT_TYPE_SPEC.sql,v $
  --$ $Log: RTR_TRANS_DTL_DISCOUNT_TYPE_SPEC.sql,v $
  --$ Revision 1.1  2017/09/19 17:55:40  sgangineni
  --$ CR48260 (SM MLD) - Types initial version
  --$
  --$
  *
  * CR48260 - RTR Transaction Detail Discount Type spec.
  *
  *************************************************************************************************************************************/

( OBJID	                  NUMBER,
  RTR_TRANS_DETAIL_OBJID	NUMBER,
  DISCOUNT_CODE	          VARCHAR2(100),
  DISCOUNT_AMOUNT	        NUMBER,
  INSERT_TIMESTAMP	      DATE,
  UPDATE_TIMESTAMP	      DATE,
  RESPONSE                VARCHAR2(300),
  CONSTRUCTOR FUNCTION rtr_trans_dtl_discount_type RETURN SELF AS RESULT,
  MEMBER FUNCTION ins ( i_rtr_trans_dtl_discount_type IN rtr_trans_dtl_discount_type ) RETURN rtr_trans_dtl_discount_type,
  MEMBER FUNCTION ins RETURN rtr_trans_dtl_discount_type,
  MEMBER FUNCTION upd ( i_rtr_trans_dtl_discount_type IN rtr_trans_dtl_discount_type ) RETURN rtr_trans_dtl_discount_type
);
/
CREATE OR REPLACE TYPE BODY sa.rtr_trans_dtl_discount_type AS
  /*************************************************************************************************************************************
  --$RCSfile: RTR_TRANS_DTL_DISCOUNT_TYPE_BODY.sql,v $
  --$ $Log: RTR_TRANS_DTL_DISCOUNT_TYPE_BODY.sql,v $
  --$ Revision 1.3  2017/11/01 20:21:03  sgangineni
  --$ CR48260 - Modified as per code review comments
  --$
  --$ Revision 1.2  2017/09/26 21:29:55  sgangineni
  --$ CR48260 - modified the draft versions
  --$
  --$
  *
  * CR48260 - RTR Transaction Detail Discount Type body.
  *
  *************************************************************************************************************************************/
CONSTRUCTOR FUNCTION rtr_trans_dtl_discount_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END rtr_trans_dtl_discount_type;

MEMBER FUNCTION ins ( i_rtr_trans_dtl_discount_type IN rtr_trans_dtl_discount_type ) RETURN rtr_trans_dtl_discount_type AS
  rtdd  rtr_trans_dtl_discount_type := i_rtr_trans_dtl_discount_type;
BEGIN
  IF rtdd.objid IS NULL THEN
     rtdd.objid  := sa.seq_rtr_trans_dtl_discount.nextval;
  END IF;

  --Assign Time stamp attributes
  IF rtdd.update_timestamp IS NULL THEN
    rtdd.update_timestamp  := SYSDATE;
  END IF;

  IF rtdd.insert_timestamp IS NULL THEN
    rtdd.insert_timestamp  := SYSDATE;
  END IF;


  INSERT INTO X_RTR_TRANS_DTL_DISCOUNT ( OBJID,
                                         RTR_TRANS_DETAIL_OBJID,
                                         DISCOUNT_CODE,
                                         DISCOUNT_AMOUNT,
                                         INSERT_TIMESTAMP,
                                         UPDATE_TIMESTAMP
                                       )
                                VALUES ( rtdd.objid,
                                         rtdd.rtr_trans_detail_objid,
                                         rtdd.discount_code,
                                         rtdd.discount_amount,
                                         rtdd.insert_timestamp,
                                         rtdd.update_timestamp
                                       );

  -- set Success Response
  rtdd.response  := 'SUCCESS';
  RETURN rtdd;
EXCEPTION
WHEN OTHERS THEN
  rtdd.response := rtdd.response || '|ERROR INSERTING X_RTR_TRANS_DTL_DISCOUNT RECORD: ' || SUBSTR(SQLERRM,1,100);
  RETURN rtdd;
END ins;

MEMBER FUNCTION ins RETURN rtr_trans_dtl_discount_type AS
  rtdd   rtr_trans_dtl_discount_type := SELF;
  i     rtr_trans_dtl_discount_type;
BEGIN
  i := rtdd.ins ( i_rtr_trans_dtl_discount_type => rtdd );
  RETURN i;
END ins;

MEMBER FUNCTION upd ( i_rtr_trans_dtl_discount_type IN rtr_trans_dtl_discount_type ) RETURN rtr_trans_dtl_discount_type AS
  rtdd  rtr_trans_dtl_discount_type := rtr_trans_dtl_discount_type();
BEGIN
  rtdd := i_rtr_trans_dtl_discount_type;

  BEGIN
    UPDATE x_rtr_trans_dtl_discount
    SET   rtr_trans_detail_objid = NVL(rtdd.rtr_trans_detail_objid, rtr_trans_detail_objid),
          discount_code          = NVL(rtdd.discount_code, discount_code),
          discount_amount        = NVL(rtdd.discount_amount, discount_amount),
          update_timestamp       = SYSDATE
    WHERE objid =  rtdd.objid
    RETURNING rtr_trans_detail_objid,
              discount_code,
              discount_amount,
              update_timestamp
    INTO rtdd.rtr_trans_detail_objid,
         rtdd.discount_code,
         rtdd.discount_amount,
         rtdd.update_timestamp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      rtdd.response := 'COULD NOT FIND DETAIL DISCOUNT OBJID:'||rtdd.objid;
      RETURN rtdd;
  END;

  -- set Success Response
  rtdd.response  := 'SUCCESS';
  RETURN rtdd;
EXCEPTION
WHEN OTHERS THEN
  rtdd.response := rtdd.response || '|ERROR UPDATING X_RTR_TRANS_DTL_DISCOUNT RECORD: ' || SUBSTR(SQLERRM,1,100);
  RETURN rtdd;
END upd;

END;
/