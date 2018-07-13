CREATE OR REPLACE TYPE sa.rtr_trans_header_type AS OBJECT
  /*************************************************************************************************************************************
  --$RCSfile: RTR_TRANS_HEADER_TYPE_SPEC.sql,v $
  --$ $Log: RTR_TRANS_HEADER_TYPE_SPEC.sql,v $
  --$ Revision 1.9  2017/12/29 23:08:29  sgangineni
  --$ CR48260 - Fixed issues with data comparision
  --$
  --$ Revision 1.8  2017/12/23 01:27:30  akhan
  --$ synced
  --$
  --$ Revision 1.7  2017/12/23 01:03:01  akhan
  --$ fixed code
  --$
  --$ Revision 1.6  2017/12/22 22:50:37  sgangineni
  --$ CR48260 - Increased rtr_remote_trans_id length from 20 to 100
  --$
  --$ Revision 1.2  2017/12/05 17:27:52  sgangineni
  --$ CR48260 - Added BRAND attribute
  --$
  --$ Revision 1.1  2017/09/19 17:55:40  sgangineni
  --$ CR48260 (SM MLD) - Types initial version
  --$
  --$
  *
  * CR48260 - RTR Transaction Header Type Spec.
  *
  *************************************************************************************************************************************/

( OBJID	                  NUMBER,
  ORDER_ID	              VARCHAR2(100),
  RTR_VENDOR_NAME	        VARCHAR2(100),
  RTR_MERCH_STORE_NUM	    VARCHAR2(100),
  TRANS_DATE	            DATE,
  RTR_REMOTE_TRANS_ID	    VARCHAR2(100),
  SOURCESYSTEM	          VARCHAR2(50),
  RTR_MERCH_REG_NUM	      VARCHAR2(30),
  RESPONSE_CODE	          VARCHAR2(100),
  RTR_MERCH_STORE_NAME	  VARCHAR2(100),
  STATUS	                VARCHAR2(500),
  ACTION                  VARCHAR2(40),
  TENDER_AMOUNT	          NUMBER,
  ESTIMATED_AMOUNT	      NUMBER,
  TOTAL_DISCOUNT	        NUMBER,
  INSERT_TIMESTAMP	      DATE,
  UPDATE_TIMESTAMP	      DATE,
  RESPONSE                VARCHAR2(300),
  TRANS_DETAIL            rtr_trans_detail_tab,
  BRAND                   VARCHAR2(40),
  CONSTRUCTOR FUNCTION rtr_trans_header_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION rtr_trans_header_type (i_rtr_remote_trans_id IN VARCHAR2,
                                              i_rtr_vendor_name     IN VARCHAR2  ) RETURN SELF AS RESULT,
  MEMBER FUNCTION ins ( i_rtr_trans_header_type IN rtr_trans_header_type ) RETURN rtr_trans_header_type,
  MEMBER FUNCTION ins RETURN rtr_trans_header_type,
  MEMBER FUNCTION upd ( i_rtr_trans_header_type IN rtr_trans_header_type ) RETURN rtr_trans_header_type,
  MEMBER FUNCTION compare( i_rtr_trans_header_type IN rtr_trans_header_type) RETURN VARCHAR2,
  map member function equals return raw
);
/
CREATE OR REPLACE TYPE BODY sa.rtr_trans_header_type AS
  /*************************************************************************************************************************************
  --$RCSfile: RTR_TRANS_HEADER_TYPE_BODY.sql,v $
  --$ $Log: RTR_TRANS_HEADER_TYPE_BODY.sql,v $
  --$ Revision 1.14  2018/01/11 20:12:23  sraman
  --$ CR52120 - Modified to have trans date always inserted with sysdate and donot modify that column
  --$
  --$ Revision 1.13  2017/12/29 23:08:29  sgangineni
  --$ CR48260 - Fixed issues with data comparision
  --$
  --$ Revision 1.12  2017/12/28 15:51:06  akhan
  --$ modified ins fuction to merge instead of insert
  --$
  --$ Revision 1.11  2017/12/23 00:57:09  akhan
  --$ fixed bug
  --$
  --$ Revision 1.10  2017/12/20 20:58:50  akhan
  --$ modified compare function
  --$
  --$ Revision 1.9  2017/12/18 20:08:52  sgangineni
  --$ CR48260 - New changes to compare the attributes
  --$
  --$ Revision 1.8  2017/12/14 22:40:45  sraman
  --$ ADDED COMPARE FUNCTION
  --$
  --$ Revision 1.7  2017/12/12 23:05:05  akhan
  --$ added compare function
  --$
  --$ Revision 1.6  2017/11/06 19:20:09  sgangineni
  --$ CR48260 - added header objid to be etched from sequence
  --$
  --$ Revision 1.5  2017/11/01 20:23:36  sgangineni
  --$ CR48260 - Modified as per code review comments
  --$
  --$ Revision 1.4  2017/10/09 21:59:54  sgangineni
  --$ CR48260 - Removed debug messages
  --$
  --$ Revision 1.3  2017/10/09 21:47:59  sgangineni
  --$ CR48260 - Added new attributes in detail type
  --$
  --$ Revision 1.2  2017/09/26 21:29:55  sgangineni
  --$ CR48260 - modified the draft versions
  --$
  --$ Revision 1.1  2017/09/19 17:55:40  sgangineni
  --$ CR48260 (SM MLD) - Types initial version
  --$
  --$
  *
  * CR48260 - RTR Transaction Header Type body.
  *
  *************************************************************************************************************************************/
  CONSTRUCTOR FUNCTION rtr_trans_header_type RETURN SELF AS RESULT AS
  BEGIN
    RETURN;
  END rtr_trans_header_type;

  CONSTRUCTOR FUNCTION rtr_trans_header_type (i_rtr_remote_trans_id IN VARCHAR2,
                                              i_rtr_vendor_name     IN VARCHAR2  ) RETURN SELF AS RESULT AS
  BEGIN
    IF i_rtr_remote_trans_id IS NULL THEN
      SELF.response := 'RTR_REMOTE_TRANS_ID NOT PASSED';
      RETURN;
    END IF;

    --fetching header
    SELECT rtr_trans_header_type(OBJID	                  ,
                                 ORDER_ID	              ,
                                 RTR_VENDOR_NAME	      ,
                                 RTR_MERCH_STORE_NUM	  ,
                                 TRANS_DATE	              ,
                                 RTR_REMOTE_TRANS_ID	  ,
                                 SOURCESYSTEM	          ,
                                 RTR_MERCH_REG_NUM	      ,
                                 RESPONSE_CODE	          ,
                                 RTR_MERCH_STORE_NAME	  ,
                                 STATUS	                  ,
                                 ACTION          ,
                                 TENDER_AMOUNT	          ,
                                 ESTIMATED_AMOUNT	      ,
                                 TOTAL_DISCOUNT	          ,
                                 INSERT_TIMESTAMP	      ,
                                 UPDATE_TIMESTAMP	      ,
                                 NULL                     ,   --RESPONSE
                                 NULL                     ,   --TRANS_DETAIL
                                 NULL                         --BRAND
                                )
    INTO SELF
    FROM  x_rtr_trans_header
    WHERE rtr_vendor_name     = i_rtr_vendor_name
     AND  rtr_remote_trans_id = i_rtr_remote_trans_id;

    -- Fetching the details
    SELECT rtr_trans_detail_type(  OBJID	                        ,
                                   ORDER_DETAIL_ID	                ,
                                   RTR_TRANS_HEADER_OBJID	        ,
                                   PART_NUM_PARENT	                ,
                                   SERIAL_NUM	                    ,
                                   RED_CODE	                        ,
                                   PIN_STATUS_CODE	                ,
                                   NULL                             ,   --PIN_SERVICE_DAYS
                                   EXTRACT_FLAG	                    ,
                                   EXTRACT_DATE	                    ,
                                   SITE_ID	                        ,
                                   RTR_TRANS_TYPE	                ,
                                   UPC	                            ,
                                   MIN	                            ,
                                   ESN	                            ,
                                   AMOUNT	                        ,
                                   STATUS	                        ,
                                   NULL                             ,  --ORDER_LINE_ACTION_TYPE
                                   NULL                             ,  --ZIPCODE
                                   NULL                             ,  --CARD_ACTION
                                   SIM                              ,
                                   NULL                             ,  --ERROR_CODE
                                   NULL                             ,  --ERROR_MESSAGE
                                   INSERT_TIMESTAMP	                ,
                                   UPDATE_TIMESTAMP	                ,
                                   NULL                             ,  -- TRANS_DTL_DISCOUNTS
                                   NULL                             ,  -- ESN_STATUS
                                   NULL                             ,  -- WEB_USER_OBJID
                                   NULL                             ,  -- ACCOUNT_TYPE
                                   NULL                             ,  -- PIN_PART_CLASS
                                   NULL                             ,  -- RESERVED_CARDS
                                   NULL                                -- call_trans_objid
                                )
    BULK COLLECT
    INTO  SELF.TRANS_DETAIL
    FROM  X_RTR_TRANS_DETAIL
    WHERE RTR_TRANS_HEADER_OBJID = SELF.OBJID
	ORDER BY OBJID;

    --Fetching discount
    IF self.trans_detail IS NOT NULL THEN
      FOR i IN 1..self.trans_detail.COUNT
      LOOP
           SELECT rtr_trans_dtl_discount_type( OBJID	                     ,
                                               RTR_TRANS_DETAIL_OBJID        ,
                                               DISCOUNT_CODE	             ,
                                               DISCOUNT_AMOUNT	             ,
                                               INSERT_TIMESTAMP	             ,
                                               UPDATE_TIMESTAMP	             ,
                                               NULL                            --RESPONSE
                                             )
            BULK COLLECT
           INTO  SELF.TRANS_DETAIL(i).TRANS_DTL_DISCOUNTS
           FROM  sa.X_RTR_TRANS_DTL_DISCOUNT
           WHERE RTR_TRANS_DETAIL_OBJID = SELF.TRANS_DETAIL(i).OBJID;
      END LOOP;
    END IF;

    SELF.response := 'SUCCESS';
  	RETURN;
   EXCEPTION
      WHEN OTHERS THEN
        SELF.response   := 'RTR TRANS NOT FOUND' || SUBSTR(SQLERRM,1,100);
        SELF.RTR_REMOTE_TRANS_ID := i_rtr_remote_trans_id;
        RETURN;
  END rtr_trans_header_type;

  MEMBER FUNCTION ins ( i_rtr_trans_header_type IN rtr_trans_header_type ) RETURN rtr_trans_header_type
  AS
    rth    rtr_trans_header_type        := i_rtr_trans_header_type;
  BEGIN
    -- IF rth.trans_date IS NULL THEN
      rth.trans_date  := SYSDATE;
    -- END IF;

    IF rth.insert_timestamp IS NULL THEN
      rth.insert_timestamp  := SYSDATE;
    END IF;

    IF rth.update_timestamp IS NULL THEN
      rth.update_timestamp  := SYSDATE;
    END IF;

    IF rth.objid IS NULL THEN
      rth.objid  := sa.seq_rtr_trans_header.nextval;
    END IF;

    IF rth.action IS NULL THEN
      rth.action := 'ADD';
    END IF;

    BEGIN
      -- Insert RTR Trans Header
      MERGE INTO x_rtr_trans_header  rh
      using ( select 1 from dual)
      on ( rh.rtr_vendor_name = rth.rtr_vendor_name
           and rh.rtr_remote_trans_id = rth.rtr_remote_trans_id)
      WHEN MATCHED THEN
       update set
           rh.order_id               = NVL(rth.order_id, rh.order_id),
           rh.rtr_merch_store_num    = NVL(rth.rtr_merch_store_num, rh.rtr_merch_store_num),
           rh.trans_date             = NVL(rth.trans_date, rh.trans_date),
           rh.action                 = NVL(rth.action, rh.action),
           rh.sourcesystem           = NVL(rth.sourcesystem, rh.sourcesystem),
           rh.rtr_merch_reg_num      = NVL(rth.rtr_merch_reg_num, rh.rtr_merch_reg_num),
           rh.response_code          = NVL(rth.response_code, rh.response_code),
           rh.rtr_merch_store_name   = NVL(rth.rtr_merch_store_name, rh.rtr_merch_store_name),
           rh.status                 = NVL(rth.status, rh.status),
           rh.tender_amount          = NVL(rth.tender_amount, rh.tender_amount),
           rh.estimated_amount       = NVL(rth.estimated_amount, rh.estimated_amount),
           rh.total_discount         = NVL(rth.total_discount, rh.total_discount),
           rh.UPDATE_TIMESTAMP       = SYSDATE
      WHEN NOT MATCHED THEN
      INSERT ( rh.OBJID,
               rh.ORDER_ID,
               rh.RTR_VENDOR_NAME,
               rh.RTR_MERCH_STORE_NUM,
               rh.TRANS_DATE,
               rh.RTR_REMOTE_TRANS_ID,
               rh.action,
               rh.SOURCESYSTEM,
               rh.RTR_MERCH_REG_NUM,
               rh.RESPONSE_CODE,
               rh.RTR_MERCH_STORE_NAME,
               rh.STATUS,
               rh.TENDER_AMOUNT,
               rh.ESTIMATED_AMOUNT,
               rh.TOTAL_DISCOUNT,
               rh.INSERT_TIMESTAMP,
               rh.UPDATE_TIMESTAMP
             )
      VALUES ( rth.objid,
               rth.order_id,
               rth.rtr_vendor_name,
               rth.rtr_merch_store_num,
               rth.trans_date,
               rth.rtr_remote_trans_id,
               rth.action,
               rth.sourcesystem,
               rth.rtr_merch_reg_num,
               rth.response_code,
               rth.rtr_merch_store_name,
               rth.status,
               rth.tender_amount,
               rth.estimated_amount,
               rth.total_discount,
               rth.insert_timestamp,
               rth.update_timestamp
             );
    EXCEPTION
      WHEN OTHERS THEN
        rth.response  := 'FAILED WHILE INSERTING INTO X_RTR_TRANS_HEADER. '||SQLERRM;
        RETURN rth;
    END;

    delete x_rtr_trans_dtl_discount
    where rtr_trans_detail_objid IN (select objid from x_rtr_trans_detail where rtr_trans_header_objid= rth.objid);

    delete x_rtr_trans_detail
    where rtr_trans_header_objid = rth.objid;

    --Execute the detail insert function
    IF rth.trans_detail IS NOT NULL THEN
      FOR i IN 1..rth.trans_detail.COUNT
      LOOP
        --Map the header objid to the detial records
        rth.trans_detail(i).rtr_trans_header_objid := rth.objid;
        rth.trans_detail(i) :=  rth.trans_detail(i).ins;
        IF rth.trans_detail(i).error_code <> '0'
        THEN
          rth.response  := 'FAILED WHILE INSERTING TRANSACTION DETAILS. Err-'||rth.trans_detail(i).error_message;
          RETURN rth;
        END IF;
      END LOOP;
    END IF;

    -- set Success Response
    rth.response  := 'SUCCESS';
    RETURN rth;
  EXCEPTION
  WHEN OTHERS THEN
    rth.response := rth.response || '|ERROR INSERTING X_RTR_TRANS_HEADER RECORD: ' || SUBSTR(SQLERRM,1,100);
    ROLLBACK;
    RETURN rth;
  END ins;

  MEMBER FUNCTION ins RETURN rtr_trans_header_type AS
    rth   rtr_trans_header_type := SELF;
    i    rtr_trans_header_type;
  BEGIN
    i := rth.ins ( i_rtr_trans_header_type => rth );
    RETURN i;
  END ins;

  MEMBER FUNCTION upd ( i_rtr_trans_header_type IN rtr_trans_header_type ) RETURN rtr_trans_header_type AS
    rth    rtr_trans_header_type        := rtr_trans_header_type();
    rtd   rtr_trans_detail_type := rtr_trans_detail_type();
  BEGIN

    rth := i_rtr_trans_header_type;

    -- update header
    UPDATE x_rtr_trans_header
    SET    order_id               = NVL(rth.order_id, order_id),
           rtr_vendor_name        = NVL(rth.rtr_vendor_name, rtr_vendor_name),
           rtr_merch_store_num    = NVL(rth.rtr_merch_store_num, rtr_merch_store_num),
           --trans_date             = NVL(rth.trans_date, trans_date),
           rtr_remote_trans_id    = NVL(rth.rtr_remote_trans_id, rtr_remote_trans_id),
           sourcesystem           = NVL(rth.sourcesystem, sourcesystem),
           rtr_merch_reg_num      = NVL(rth.rtr_merch_reg_num, rtr_merch_reg_num),
           response_code          = NVL(rth.response_code, response_code),
           rtr_merch_store_name   = NVL(rth.rtr_merch_store_name, rtr_merch_store_name),
           status                 = NVL(rth.status, status),
           tender_amount          = NVL(rth.tender_amount, tender_amount),
           estimated_amount       = NVL(rth.estimated_amount, estimated_amount),
           total_discount         = NVL(rth.total_discount, total_discount),
           UPDATE_TIMESTAMP       = SYSDATE
    WHERE  objid =  rth.objid
    RETURNING objid,
              order_id,
              rtr_vendor_name,
              rtr_merch_store_num,
              trans_date,
              rtr_remote_trans_id,
              sourcesystem,
              rtr_merch_reg_num,
              response_code,
              rtr_merch_store_name,
              status,
              tender_amount,
              estimated_amount,
              total_discount,
              insert_timestamp,
              update_timestamp
         INTO rth.objid,
              rth.order_id,
              rth.rtr_vendor_name,
              rth.rtr_merch_store_num,
              rth.trans_date,
              rth.rtr_remote_trans_id,
              rth.sourcesystem,
              rth.rtr_merch_reg_num,
              rth.response_code,
              rth.rtr_merch_store_name,
              rth.status,
              rth.tender_amount,
              rth.estimated_amount,
              rth.total_discount,
              rth.insert_timestamp,
              rth.update_timestamp;

    -- only update when detail is not empty
    IF rth.trans_detail IS NOT NULL THEN
      -- update order details
      FOR i IN 1..rth.trans_detail.COUNT
      LOOP
        rth.trans_detail(i) :=  rtd.upd ( i_rtr_trans_detail_type => rth.trans_detail (i) ) ;
     END LOOP;

    END IF;

    -- set Success Response
    rth.response  := 'SUCCESS';

    RETURN rth;

  EXCEPTION
  WHEN OTHERS THEN
    rth.response := rth.response || '|ERROR UPDATING X_RTR_TRANS_HEADER RECORD: ' || SUBSTR(SQLERRM,1,100);
    RETURN rth;

  END upd;

MEMBER FUNCTION compare( i_rtr_trans_header_type IN rtr_trans_header_type) RETURN VARCHAR2 AS
  l_response    VARCHAR(500)          := NULL;
  rtd sa.rtr_trans_detail_type := sa.rtr_trans_detail_type();
BEGIN
   IF    nvl(self.rtr_vendor_name,'X')      <> nvl(i_rtr_trans_header_type.rtr_vendor_name,'X')       THEN
            l_response := 'RTR_VENDOR_NAME MISMATCH :'||i_rtr_trans_header_type.rtr_vendor_name ;
   ELSIF nvl(self.rtr_merch_store_num,'X')  <> nvl(i_rtr_trans_header_type.rtr_merch_store_num,'X')   THEN
            l_response := 'RTR_MERCH_STORE_NUM MISMATCH :'||i_rtr_trans_header_type.rtr_merch_store_num;
   ELSIF nvl(self.rtr_remote_trans_id,'X')  <> nvl(i_rtr_trans_header_type.rtr_remote_trans_id,'X')   THEN
            l_response := 'RTR_REMOTE_TRANS_ID MISMATCH :'|| i_rtr_trans_header_type.rtr_remote_trans_id;
   ELSIF nvl(self.rtr_merch_reg_num,'X')    <> nvl(i_rtr_trans_header_type.rtr_merch_reg_num,'X')     THEN
            l_response := 'RTR_MERCH_REG_NUM MISMATCH : '|| i_rtr_trans_header_type.rtr_merch_reg_num;
   ELSIF nvl(self.rtr_merch_store_name,'X')  <> nvl(i_rtr_trans_header_type.rtr_merch_store_name,'X') THEN
            l_response := 'RTR_MERCH_STORE_NAME MISMATCH :'||i_rtr_trans_header_type.rtr_merch_store_name;
   -- ELSIF nvl(self.tender_amount,0)           <> nvl(i_rtr_trans_header_type.tender_amount,0)          THEN
            -- l_response := 'TENDER_AMOUNT MISMATCH :'||i_rtr_trans_header_type.tender_amount;
   -- ELSIF nvl(self.estimated_amount,0)        <> nvl(i_rtr_trans_header_type.estimated_amount,0)       THEN
            -- l_response := 'ESTIMATED_AMOUNT MISMATCH :'||i_rtr_trans_header_type.estimated_amount;
   -- ELSIF nvl(self.total_discount,0)          <> nvl(i_rtr_trans_header_type.total_discount,0)         THEN
            -- l_response := 'TOTAL_DISCOUNT MISMATCH :'|| i_rtr_trans_header_type.total_discount ;
   ELSIF nvl(self.trans_detail.count,0)      <> nvl(i_rtr_trans_header_type.trans_detail.count,0)     THEN
            l_response := 'TRANS_DETAIL COUNT MISMATCH :' || i_rtr_trans_header_type.trans_detail.count;
   END IF;

   IF  l_response IS NOT NULL THEN
      RETURN   'HEADER: '|| l_response;
   END IF;

   IF self.trans_detail IS NOT NULL THEN
      FOR i IN 1..self.trans_detail.COUNT
      LOOP
          rtd:= sa.rtr_trans_detail_type (self.trans_detail(i).OBJID
                                          ,self.trans_detail(i).ORDER_DETAIL_ID
                                          ,self.trans_detail(i).RTR_TRANS_HEADER_OBJID
                                          ,self.trans_detail(i).PART_NUM_PARENT
                                          ,self.trans_detail(i).SERIAL_NUM
                                          ,self.trans_detail(i).RED_CODE
                                          ,self.trans_detail(i).PIN_STATUS_CODE
                                          ,self.trans_detail(i).PIN_SERVICE_DAYS
                                          ,self.trans_detail(i).EXTRACT_FLAG
                                          ,self.trans_detail(i).EXTRACT_DATE
                                          ,self.trans_detail(i).SITE_ID
                                          ,self.trans_detail(i).RTR_TRANS_TYPE
                                          ,self.trans_detail(i).UPC
                                          ,self.trans_detail(i).MIN
                                          ,self.trans_detail(i).ESN
                                          ,self.trans_detail(i).AMOUNT
                                          ,self.trans_detail(i).STATUS
                                          ,self.trans_detail(i).ORDER_LINE_ACTION_TYPE
                                          ,self.trans_detail(i).ZIPCODE
                                          ,self.trans_detail(i).CARD_ACTION
                                          ,self.trans_detail(i).SIM
                                          ,self.trans_detail(i).ERROR_CODE
                                          ,self.trans_detail(i).ERROR_MESSAGE
                                          ,self.trans_detail(i).INSERT_TIMESTAMP
                                          ,self.trans_detail(i).UPDATE_TIMESTAMP
                                          ,self.trans_detail(i).TRANS_DTL_DISCOUNTS
                                          ,self.trans_detail(i).ESN_STATUS
                                          ,self.trans_detail(i).WEB_USER_OBJID
                                          ,self.trans_detail(i).ACCOUNT_TYPE
                                          ,self.trans_detail(i).PIN_PART_CLASS
                                          ,self.trans_detail(i).RESERVED_CARDS
                                          ,self.trans_detail(i).call_trans_objid
                                               );

        l_response := rtd.found (self.RTR_VENDOR_NAME, self.RTR_REMOTE_TRANS_ID);

        if l_response <> 'SUCCESS' THEN
          RETURN   'DETAIL: '|| l_response;
        END IF;
      END LOOP;
   END IF;

   l_response := 'SUCCESS';

   RETURN l_response;

   EXCEPTION
     WHEN OTHERS THEN
       l_response := 'ERROR WHILE COMPARISON: ' || SUBSTR(SQLERRM,1,250);
       RETURN l_response;
END compare;

map member function equals return raw is
rdtab  rtr_trans_detail_tab;
begin
    SELECT rtr_trans_detail_type(  dtl.OBJID	                        ,
                                   dtl.ORDER_DETAIL_ID	                ,
                                   dtl.RTR_TRANS_HEADER_OBJID	        ,
                                   dtl.PART_NUM_PARENT	                ,
                                   dtl.SERIAL_NUM	                    ,
                                   dtl.RED_CODE	                        ,
                                   dtl.PIN_STATUS_CODE	                ,
                                   NULL                             ,   --PIN_SERVICE_DAYS
                                   dtl.EXTRACT_FLAG	                    ,
                                   dtl.EXTRACT_DATE	                    ,
                                   dtl.SITE_ID	                        ,
                                   dtl.RTR_TRANS_TYPE	                ,
                                   dtl.UPC	                            ,
                                   dtl.MIN	                            ,
                                   dtl.ESN	                            ,
                                   dtl.AMOUNT	                        ,
                                   dtl.STATUS	                        ,
                                   NULL                             ,  --ORDER_LINE_ACTION_TYPE
                                   NULL                             ,  --ZIPCODE
                                   NULL                             ,  --CARD_ACTION
                                   dtl.SIM                              ,
                                   NULL                             ,  --ERROR_CODE
                                   NULL                             ,  --ERROR_MESSAGE
                                   dtl.INSERT_TIMESTAMP	                ,
                                   dtl.UPDATE_TIMESTAMP	                ,
                                   NULL                             ,  -- TRANS_DTL_DISCOUNTS
                                   NULL                             ,  -- ESN_STATUS
                                   NULL                             ,  -- WEB_USER_OBJID
                                   NULL                             ,  -- ACCOUNT_TYPE
                                   NULL                             ,  -- PIN_PART_CLASS
                                   NULL                             ,  -- RESERVED_CARDS
                                   NULL                                -- call_trans_objid
                                )
    BULK COLLECT
    INTO  rdtab
    FROM  X_RTR_TRANS_DETAIL dtl, X_RTR_TRANS_HEADER hdr
    WHERE dtl.RTR_TRANS_HEADER_OBJID = hdr.OBJID
    AND   hdr.rtr_remote_trans_id = SELF.rtr_remote_trans_id
    AND   hdr.rtr_vendor_name = SELF.rtr_vendor_name;

 if rdtab <> self.trans_detail then
    return null;
 else

 return
    utl_raw.cast_to_raw(
       nvl(self.rtr_vendor_name,'X') ||
       nvl(self.rtr_merch_store_num,'X') ||
       nvl(self.rtr_remote_trans_id,'X') ||
       nvl(self.rtr_merch_reg_num,'X')   ||
       nvl(self.rtr_merch_store_name,'X')
      );
end if;
end;
END;
/