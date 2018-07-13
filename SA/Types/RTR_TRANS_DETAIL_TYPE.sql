CREATE OR REPLACE TYPE sa.rtr_trans_detail_type AS OBJECT
  /*************************************************************************************************************************************
  --$RCSfile: RTR_TRANS_DETAIL_TYPE_SPEC.sql,v $
  --$ $Log: RTR_TRANS_DETAIL_TYPE_SPEC.sql,v $
  --$ Revision 1.9  2017/12/29 23:08:29  sgangineni
  --$ CR48260 - Fixed issues with data comparision
  --$
  --$ Revision 1.8  2017/12/23 00:52:11  akhan
  --$ fixing code as per reqmnt
  --$
  --$ Revision 1.7  2017/12/20 20:58:50  akhan
  --$ modified compare function
  --$
  --$ Revision 1.6  2017/12/14 22:47:10  sraman
  --$ added compare function
  --$
  --$ Revision 1.5  2017/11/28 22:34:15  sgangineni
  --$ CR48260 - Modified as per code review comments
  --$
  --$ Revision 1.4  2017/10/09 21:47:59  sgangineni
  --$ CR48260 - Added new attributes in detail type
  --$
  --$ Revision 1.3  2017/10/04 17:24:25  nsurapaneni
  --$ Added attriute SIM to the Type spec
  --$
  --$ Revision 1.2  2017/09/26 21:06:29  sraman
  --$ added CARD_ACTION column
  --$
  --$ Revision 1.1  2017/09/19 17:55:40  sgangineni
  --$ CR48260 (SM MLD) - Types initial version
  --$
  --$
  *
  * CR48260 - RTR Transaction Detail Type Spec.
  *
  *************************************************************************************************************************************/

( OBJID	                  NUMBER,
  ORDER_DETAIL_ID	        NUMBER,
  RTR_TRANS_HEADER_OBJID	NUMBER,
  PART_NUM_PARENT	        VARCHAR2(100),
  SERIAL_NUM	            VARCHAR2(100),
  RED_CODE	              VARCHAR2(100),
  PIN_STATUS_CODE	        VARCHAR2(100),
  PIN_SERVICE_DAYS        NUMBER,
  EXTRACT_FLAG	          VARCHAR2(1),
  EXTRACT_DATE	          DATE,
  SITE_ID	                VARCHAR2(40),
  RTR_TRANS_TYPE	        VARCHAR2(40),
  UPC	                    VARCHAR2(30),
  MIN	                    VARCHAR2(30),
  ESN	                    VARCHAR2(100),
  AMOUNT	                NUMBER,
  STATUS	                VARCHAR2(500),
  ORDER_LINE_ACTION_TYPE  VARCHAR2(200),
  ZIPCODE                 VARCHAR2(30),
  CARD_ACTION             VARCHAR2(50), --ADD_NOW/ADD_RESERVE/BLOCK
  SIM                     VARCHAR2(30),
  ERROR_CODE              VARCHAR2(10),
  ERROR_MESSAGE           VARCHAR2(2000),
  INSERT_TIMESTAMP	      DATE,
  UPDATE_TIMESTAMP	      DATE,
  TRANS_DTL_DISCOUNTS     rtr_trans_dtl_discount_tab,
  ESN_STATUS              VARCHAR2 (20),
  WEB_USER_OBJID          NUMBER,
  ACCOUNT_TYPE            VARCHAR2(50),
  PIN_PART_CLASS          VARCHAR2(40),
  RESERVED_CARDS          NUMBER,
  call_trans_objid        NUMBER,
  CONSTRUCTOR FUNCTION rtr_trans_detail_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION rtr_trans_detail_type(i_rtr_vendor_name in varchar2, i_rtr_remote_trans_id in varchar2, i_line_id in varchar2 ) RETURN SELF AS RESULT,
  MEMBER FUNCTION ins ( i_rtr_trans_detail_type IN rtr_trans_detail_type ) RETURN rtr_trans_detail_type,
  MEMBER FUNCTION ins RETURN rtr_trans_detail_type,
  MEMBER FUNCTION upd ( i_rtr_trans_detail_type IN rtr_trans_detail_type ) RETURN rtr_trans_detail_type,
  MEMBER FUNCTION found (i_RTR_VENDOR_NAME IN VARCHAR2, i_RTR_REMOTE_TRANS_ID IN VARCHAR2) RETURN VARCHAR2 ,
  map member function equals return raw
);
/
CREATE OR REPLACE TYPE BODY sa.rtr_trans_detail_type AS
/*************************************************************************************************************************************
--$RCSfile: RTR_TRANS_DETAIL_TYPE_BODY.sql,v $
--$ $Log: RTR_TRANS_DETAIL_TYPE_BODY.sql,v $
--$ Revision 1.13  2017/12/29 23:08:29  sgangineni
--$ CR48260 - Fixed issues with data comparision
--$
--$ Revision 1.12  2017/12/28 15:51:06  akhan
--$ modified ins fuction to merge instead of insert
--$
--$ Revision 1.11  2017/12/23 01:03:35  akhan
--$ fixed code
--$
--$ Revision 1.10  2017/12/20 20:58:50  akhan
--$ modified compare function
--$
--$ Revision 1.9  2017/12/18 20:08:52  sgangineni
--$ CR48260 - New changes to compare the attributes
--$
--$ Revision 1.8  2017/12/14 22:45:24  sraman
--$ bug fix
--$
--$ Revision 1.7  2017/12/14 22:17:42  sraman
--$ added compare function
--$
--$ Revision 1.6  2017/11/28 22:34:15  sgangineni
--$ CR48260 - Modified as per code review comments
--$
--$ Revision 1.5  2017/11/01 20:19:41  sgangineni
--$ CR48260 - Modified as per code review comments
--$
--$ Revision 1.3  2017/10/05 14:04:03  nsurapaneni
--$ Added field SIM in  insert and update member function
--$
--$ Revision 1.2  2017/09/26 21:29:55  sgangineni
--$ CR48260 - modified the draft versions
--$
--$ Revision 1.1  2017/09/19 17:55:40  sgangineni
--$ CR48260 (SM MLD) - Types initial version
--$
--$
*
* CR48260 - RTR Transaction Detail Type body.
*
*************************************************************************************************************************************/

CONSTRUCTOR FUNCTION rtr_trans_detail_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END rtr_trans_detail_type;
CONSTRUCTOR FUNCTION rtr_trans_detail_type(i_rtr_vendor_name in varchar2, i_rtr_remote_trans_id in varchar2, i_line_id in varchar2 ) RETURN SELF AS RESULT as
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
    INTO  SELF
    FROM  X_RTR_TRANS_DETAIL dtl, X_RTR_TRANS_HEADER hdr
    WHERE ( dtl.MIN= i_line_id or dtl.ESN= i_line_id)
    AND   dtl.RTR_TRANS_HEADER_OBJID = hdr.OBJID
    AND   hdr.rtr_remote_trans_id = i_rtr_remote_trans_id
    AND   hdr.rtr_vendor_name = i_rtr_vendor_name;

    self.error_code := 0;
    self.error_message := 'SUCCESS';
    RETURN;
exception
  when no_data_found then
    self.error_code := 100;
    self.error_message := 'UNABLE TO RETRIEVE THE ESN/MIN';
    return;
end rtr_trans_detail_type;

MEMBER FUNCTION ins ( i_rtr_trans_detail_type IN rtr_trans_detail_type ) RETURN rtr_trans_detail_type AS
  rtd  rtr_trans_detail_type := i_rtr_trans_detail_type;
BEGIN
  IF rtd.objid IS NULL THEN
     rtd.objid  := sa.seq_rtr_trans_detail.nextval;
  END IF;

  --Assign Time stamp attributes
  IF rtd.update_timestamp IS NULL THEN
    rtd.update_timestamp  := SYSDATE;
  END IF;

  IF rtd.insert_timestamp IS NULL THEN
    rtd.insert_timestamp  := SYSDATE;
  END IF;
  BEGIN
    INSERT INTO X_RTR_TRANS_DETAIL ( OBJID,
                                     ORDER_DETAIL_ID,
                                     RTR_TRANS_HEADER_OBJID,
                                     PART_NUM_PARENT,
                                     SERIAL_NUM,
                                     RED_CODE,
                                     PIN_STATUS_CODE,
                                     EXTRACT_FLAG,
                                     EXTRACT_DATE,
                                     SITE_ID,
                                     RTR_TRANS_TYPE,
                                     UPC,
                                     MIN,
                                     ESN,
                                     AMOUNT,
                                     STATUS,
                                     SIM,
                                     INSERT_TIMESTAMP,
                                     UPDATE_TIMESTAMP
                                   )
                            VALUES ( rtd.objid,
                                     rtd.order_detail_id,
                                     rtd.rtr_trans_header_objid,
                                     rtd.part_num_parent,
                                     rtd.serial_num,
                                     rtd.red_code,
                                     rtd.pin_status_code,
                                     rtd.extract_flag,
                                     rtd.extract_date,
                                     rtd.site_id,
                                     rtd.rtr_trans_type,
                                     rtd.upc,
                                     rtd.min,
                                     rtd.esn,
                                     rtd.amount,
                                     rtd.status,
                                     rtd.sim,
                                     rtd.insert_timestamp,
                                     rtd.update_timestamp
                                   );
    EXCEPTION
      WHEN OTHERS THEN
        rtd.error_code  := '102';
        rtd.error_message  := 'ERROR WHILE INSERTING X_RTR_TRANS_DETAIL RECORD: ' || SUBSTR(SQLERRM,1,100);
        RETURN rtd;
    END;

    IF rtd.trans_dtl_discounts IS NOT NULL THEN
      FOR i IN 1..rtd.trans_dtl_discounts.COUNT
      LOOP
        rtd.trans_dtl_discounts(i).rtr_trans_detail_objid := rtd.objid;
        rtd.trans_dtl_discounts(i) :=  rtd.trans_dtl_discounts(i).ins;

        IF rtd.trans_dtl_discounts(i).response <> 'SUCCESS'
        THEN
          rtd.error_code  := '100';
          rtd.error_message  := 'FAILED WHILE INSERTING DISCOUNT DETAILS. '||rtd.trans_dtl_discounts(i).response;
          RETURN rtd;
        END IF;
      END LOOP;
    END IF;

    -- set Success Response
    rtd.error_code  := '0';
    rtd.error_message  := 'SUCCESS';
  RETURN rtd;
EXCEPTION
WHEN OTHERS THEN
    rtd.error_code  := '101';
    rtd.error_message  := 'UNEXPECTED ERROR IN rtr_trans_detail_type. ' || SUBSTR(SQLERRM,1,100);
    RETURN rtd;
END ins;


MEMBER FUNCTION ins RETURN rtr_trans_detail_type AS
  rtd   rtr_trans_detail_type := SELF;
  i     rtr_trans_detail_type;
BEGIN
  i := rtd.ins ( i_rtr_trans_detail_type => rtd );
  RETURN i;
END ins;

MEMBER FUNCTION upd ( i_rtr_trans_detail_type IN rtr_trans_detail_type ) RETURN rtr_trans_detail_type AS
  rtd   rtr_trans_detail_type := rtr_trans_detail_type();
  rtdd  rtr_trans_dtl_discount_type := rtr_trans_dtl_discount_type();
BEGIN
  rtd := i_rtr_trans_detail_type;

  BEGIN
    UPDATE x_rtr_trans_detail
    SET    order_detail_id           = NVL(rtd.order_detail_id, order_detail_id),
           rtr_trans_header_objid    = NVL(rtd.rtr_trans_header_objid, rtr_trans_header_objid),
           part_num_parent           = NVL(rtd.part_num_parent, part_num_parent),
           serial_num                = NVL(rtd.serial_num, serial_num),
           red_code                  = NVL(rtd.red_code, red_code),
           pin_status_code           = NVL(rtd.pin_status_code, pin_status_code),
           extract_flag              = NVL(rtd.extract_flag, extract_flag),
           extract_date              = NVL(rtd.extract_date, extract_date),
           site_id                   = NVL(rtd.site_id, site_id),
           rtr_trans_type            = NVL(rtd.rtr_trans_type, rtr_trans_type),
           upc                       = NVL(rtd.upc, upc),
           min                       = NVL(rtd.min, min),
           esn                       = NVL(rtd.esn, esn),
           amount                    = NVL(rtd.amount, amount),
           status                    = NVL(rtd.status, status),
           sim                       = NVL(rtd.sim, sim),
           update_timestamp          = SYSDATE
    WHERE  objid =  rtd.objid
    RETURNING order_detail_id,
              rtr_trans_header_objid,
              part_num_parent,
              serial_num,
              red_code,
              pin_status_code,
              extract_flag,
              extract_date,
              site_id,
              rtr_trans_type,
              upc,
              min,
              esn,
              amount,
              status,
              sim,
              update_timestamp
         INTO rtd.order_detail_id,
              rtd.rtr_trans_header_objid,
              rtd.part_num_parent,
              rtd.serial_num,
              rtd.red_code,
              rtd.pin_status_code,
              rtd.extract_flag,
              rtd.extract_date,
              rtd.site_id,
              rtd.rtr_trans_type,
              rtd.upc,
              rtd.min,
              rtd.esn,
              rtd.amount,
              rtd.status,
              rtd.sim,
              rtd.update_timestamp;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      rtd.error_code := '200';
      rtd.error_message := 'COULD NOT FIND DETAIL OBJID:'||rtd.objid;
      RETURN rtd;
  END;

  -- only update when detail is not empty
  IF rtd.trans_dtl_discounts IS NOT NULL THEN
    -- update transaction detail discounts
    FOR i IN 1..rtd.trans_dtl_discounts.COUNT
    LOOP
      rtd.trans_dtl_discounts(i) :=  rtdd.upd ( i_rtr_trans_dtl_discount_type => rtd.trans_dtl_discounts (i) );

      IF rtd.trans_dtl_discounts(i).response <> 'SUCCESS'
      THEN
        rtd.error_code  := '201';
        rtd.error_message  := 'FAILED WHILE UPDATING DISCOUNT DETAILS. '||rtd.trans_dtl_discounts(i).response;
        RETURN rtd;
      END IF;
    END LOOP;
  END IF;

  rtd.error_code := '0';
  rtd.error_message := 'SUCCESS';
  RETURN rtd;
EXCEPTION
WHEN OTHERS THEN
  rtd.error_code := '202';
  rtd.error_message := 'UNEXPECTED ERROR IN rtr_trans_detail_type.upd. '||SQLERRM;
  RETURN rtd;
END upd;


MEMBER FUNCTION found (i_RTR_VENDOR_NAME IN VARCHAR2, i_RTR_REMOTE_TRANS_ID IN VARCHAR2) RETURN VARCHAR2 AS
  l_rtr_dt  rtr_trans_detail_type;-- := rtr_trans_detail_type(i_RTR_VENDOR_NAME, i_RTR_REMOTE_TRANS_ID, nvl(self.min,self.esn));
  l_response    VARCHAR2(2000);
BEGIN
  l_rtr_dt := rtr_trans_detail_type(i_RTR_VENDOR_NAME, i_RTR_REMOTE_TRANS_ID, nvl(self.min,self.esn));

if l_rtr_dt.error_code <> 0 then
    return l_rtr_dt.error_message;
end if;

IF NVL(self.PART_NUM_PARENT,'X')  <> NVL(l_rtr_dt.PART_NUM_PARENT,'X')
THEN
  l_response := 'PART_NUM_PARENT NOT MATCHING';
ELSIF NVL(self.RTR_TRANS_TYPE,'X')   <> NVL(l_rtr_dt.RTR_TRANS_TYPE,'X')
THEN
  l_response := 'RTR_TRANS_TYPE NOT MATCHING';
ELSIF NVL(self.UPC,'X')              <> NVL(l_rtr_dt.UPC,'X')
THEN
  l_response := 'UPC NOT MATCHING';
ELSIF NVL(self.MIN,'X')              <> NVL(l_rtr_dt.MIN,'X')
THEN
  l_response := 'MIN NOT MATCHING';
ELSIF NVL(self.ESN,'X')              <> NVL(l_rtr_dt.ESN,'X')
THEN
  l_response := 'ESN NOT MATCHING';
ELSIF NVL(self.SIM,'X')              <> NVL(l_rtr_dt.SIM,'X')
THEN
  l_response := 'SIM NOT MATCHING';
END IF;

IF l_response IS NULL
THEN
  RETURN ('SUCCESS');
ELSE
  RETURN l_response;
END IF;

EXCEPTION
     WHEN OTHERS THEN
       RETURN 'ERROR WHILE MATCHING ORDER DETAILS';
END found;

map member function equals return raw as
begin
 return
    -- NVL() to avoid NULLS being treated
    -- as equal. NVL default values: choose
    -- carefully!
    utl_raw.cast_to_raw(
    nvl(self.RTR_TRANS_HEADER_OBJID, -1)||
    nvl(self.PART_NUM_PARENT,'PNP')||
    nvl(self.RTR_TRANS_TYPE,'RTT')||
    nvl(self.UPC,'UPC')||
    nvl(self.MIN,'1111111111')||
    rpad(nvl(self.ESN,0),30,'0')||
    rpad(nvl(self.AMOUNT,0),10,'0')||
    rpad(nvl(self.SIM,0),30,'0')||
    rpad(nvl(self.ESN_STATUS,0),3,'0')||
    nvl(self.ACCOUNT_TYPE,'AT')||
    nvl(self.PIN_PART_CLASS,'PPC')
      );

end;
END;
/