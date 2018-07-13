CREATE OR REPLACE TYPE sa.process_order_detail_type AS OBJECT
/*************************************************************************************************************************************
  * $Revision: 1.8 $
  * $Author: sinturi $
  * $Date: 2018/04/03 15:11:25 $
  * $Log: process_order_detail_type_spec.SQL,v $
  * Revision 1.8  2018/04/03 15:11:25  sinturi
  * updated after review
  *
  * Revision 1.6  2017/06/12 19:10:19  sraman
  * ESN added
  *
  * Revision 1.5  2017/06/06 18:47:21  sraman
  * Added additional columns
  *
  * Revision 1.4  2017/02/23 23:15:41  sraman
  * CR47564- Added new column CaseStatus,CallTransSatus,Action
  *
  * Revision 1.3  2017/02/20 21:52:12  sraman
  * CR47564- Added new column min, pin and pin_status
  *
  * Revision 1.2  2017/02/14 22:28:09  sgangineni
  * Removed the grants to the below roles ROLE_SA_UPDATE, ROLE_REPORT_UPDATE, ROLE_SA_SELECT
  *
  * Revision 1.1  2017/02/01 16:50:19  sraman
  * CR47564 - new type
  *
  *************************************************************************************************************************************/

(
  process_order_detail_objid               NUMBER,
  process_order_objid                      NUMBER,
  case_objid                               NUMBER,
  call_trans_objid                         NUMBER,
  Order_Status                             VARCHAR2(50),
  min                                      VARCHAR2(30),
  pin                                      VARCHAR2(30),
  pin_status                               VARCHAR2(20),
  Case_Status                              VARCHAR2(80),
  Action_Text                              VARCHAR2(20),
  CallTrans_Status                         VARCHAR2(20),
  Order_Type                               VARCHAR2(50), --CR50433
  BAN                                      VARCHAR2(20), --CR50433
  ESN                                      VARCHAR2(30), --CR50433
  SMP                                      VARCHAR2(30), --CR55836
  insert_timestamp                         DATE,
  update_timestamp                         DATE,
  response                                 VARCHAR2(1000),
  CONSTRUCTOR FUNCTION process_order_detail_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION process_order_detail_type ( i_process_order_detail_objid IN NUMBER ) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_process_order_detail_type IN process_order_detail_type ) RETURN process_order_detail_type,
  MEMBER FUNCTION ins RETURN process_order_detail_type,
  MEMBER FUNCTION upd ( i_process_order_detail_type IN process_order_detail_type ) RETURN process_order_detail_type,
  MEMBER FUNCTION del ( i_process_order_detail_objid IN  NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN
);
/
CREATE OR REPLACE TYPE BODY sa.process_order_detail_type AS
/*************************************************************************************************************************************
  * $Revision: 1.11 $
  * $Author: sinturi $
  * $Date: 2018/04/03 15:11:25 $
  * $Log: process_order_detail_type.SQL,v $
  * Revision 1.11  2018/04/03 15:11:25  sinturi
  * updated after review
  *
  * Revision 1.8  2017/06/12 19:14:34  sraman
  * ESN column is added
  *
  * Revision 1.7  2017/06/06 18:47:34  sraman
  * Added additional columns
  *
  * Revision 1.6  2017/04/07 15:34:19  sgangineni
  * CR48944 - added / at the end of file
  *
  * Revision 1.5  2017/03/08 18:42:03  nsurapaneni
  * Process order details Update  Code changes
  *
  * Revision 1.3  2017/02/20 21:51:32  sraman
  * CR47564- Added new column min, pin and pin_status
  *
  * Revision 1.2  2017/02/14 22:28:09  sgangineni
  * Removed the grants to the below roles ROLE_SA_UPDATE, ROLE_REPORT_UPDATE, ROLE_SA_SELECT
  *
  * Revision 1.1  2017/02/01 16:58:41  sraman
  * CR47564 - New Package Body for process_order_detail
  *
  *************************************************************************************************************************************/

CONSTRUCTOR FUNCTION process_order_detail_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END process_order_detail_type;

CONSTRUCTOR FUNCTION process_order_detail_type ( i_process_order_detail_objid IN NUMBER ) RETURN SELF AS RESULT AS
BEGIN
  IF i_process_order_detail_objid IS NULL THEN
    SELF.response                   := 'PROCESS ORDER DETAIL OBJID NOT PASSED';
    RETURN;
  END IF;

  --Query the table
  SELECT process_order_detail_type ( objid                ,
                                     process_order_objid  ,
                                     case_objid           ,
                                     call_trans_objid     ,
                                     order_Status         ,
                                     min                  ,
                                     null                 , --pin
                                     null                 , --pin_status
                                     null                 , --case_status
                                     null                 , --action_text
                                     null                 , --CallTrans_Status
                                     Order_Type           ,
                                     BAN                  ,
                                     ESN                  ,
				                     SMP                  ,
                                     insert_timestamp     ,
                                     update_timestamp     ,
                                     null                   --response
                                   )
  INTO SELF
  FROM x_process_order_detail
  WHERE objid = i_process_order_detail_objid;

  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response   := 'PROCESS ORDER DETAIL NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.process_order_detail_objid := i_process_order_detail_objid;
      RETURN;
END process_order_detail_type;

--
MEMBER FUNCTION exist RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END exist;

MEMBER FUNCTION ins ( i_process_order_detail_type IN process_order_detail_type ) RETURN process_order_detail_type AS
pod  process_order_detail_type := i_process_order_detail_type;
cst  sa.customer_type := sa.customer_type();
BEGIN
  IF pod.process_order_detail_objid IS NULL THEN
     pod.process_order_detail_objid  := sa.seq_process_order_detail.nextval;
  END IF;

    IF pod.Order_Status IS NULL THEN
     pod.Order_Status  := 'INITIATED';
  END IF;

  --Assign Time stamp attributes
  IF pod.update_timestamp IS NULL THEN
    pod.update_timestamp  := SYSDATE;
  END IF;

  IF pod.insert_timestamp IS NULL THEN
    pod.insert_timestamp  := SYSDATE;
  END IF;

  IF pod.SMP IS NULL
  THEN
    IF pod.pin IS NOT NULL
    THEN
      pod.SMP := cst.convert_pin_to_smp(pod.pin);
    END IF;
  END IF;

  INSERT
  INTO x_process_order_detail
  (
    objid                     ,
    process_order_objid       ,
    case_objid                ,
    call_trans_objid          ,
    Order_Status              ,
    min                       ,
    Order_Type                ,
    BAN                       ,
    ESN                       ,
    SMP                       ,
    insert_timestamp          ,
    update_timestamp
   )
  VALUES
  (
   pod.process_order_detail_objid    ,
   pod.process_order_objid       ,
   pod.case_objid                ,
   pod.call_trans_objid          ,
   pod.Order_Status              ,
   pod.min                       ,
   pod.Order_Type                ,
   pod.BAN                       ,
   pod.ESN                       ,
   pod.SMP                       ,
   pod.insert_timestamp          ,
   pod.update_timestamp
   );

  -- set Success Response
  pod.response  := 'SUCCESS';
  RETURN pod;
EXCEPTION
WHEN OTHERS THEN
  pod.response := pod.response || '|ERROR INSERTING X_PROCESS_ORDER_DETAIL RECORD: ' || SUBSTR(SQLERRM,1,100);
  RETURN pod;

END ins;

MEMBER FUNCTION ins RETURN process_order_detail_type AS
  pod   process_order_detail_type := SELF;
  i     process_order_detail_type;
BEGIN
  i := pod.ins ( i_process_order_detail_type => pod );
  RETURN i;

END ins;

MEMBER FUNCTION upd ( i_process_order_detail_type IN process_order_detail_type ) RETURN process_order_detail_type AS
  pod  process_order_detail_type := process_order_detail_type();
BEGIN
  pod := i_process_order_detail_type;

  UPDATE x_process_order_detail
  SET    objid                           = NVL(pod.process_order_detail_objid      , objid               ),
         process_order_objid             = NVL(pod.process_order_objid             , process_order_objid ),
         case_objid                      = NVL(pod.case_objid                      , case_objid          ),
         call_trans_objid                = NVL(pod.call_trans_objid                , call_trans_objid    ),
         order_Status                    = NVL(pod.Order_Status                    , Order_Status        ),
         min                             = NVL(pod.min                             , min                 ),
         order_type                      = NVL(pod.order_type                      , order_type          ),
         ban                             = NVL(pod.ban                             , ban                 ),
         ESN                             = NVL(pod.ESN                             , ESN                 ),
		 SMP                             = NVL(pod.SMP                             , SMP                 ),
         update_timestamp                = SYSDATE
  WHERE  objid =  pod.process_order_detail_objid
  RETURNING process_order_objid,
            case_objid,
            call_trans_objid,
            order_status,
            min,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            Order_Type,
            ban,
            ESN,
            SMP,
            insert_timestamp,
            update_timestamp
  INTO pod.process_order_objid,
       pod.case_objid,
       pod.call_trans_objid,
       pod.order_status,
       pod.min,
       pod.pin,
       pod.pin_status,
       pod.case_status,
       pod.action_text,
       pod.calltrans_status,
       pod.Order_Type,
       pod.ban,
       pod.ESN,
       pod.SMP,
       pod.insert_timestamp,
       pod.update_timestamp;

  -- set Success Response
  --pod := process_order_detail_type ( i_process_order_detail_objid  => pod.process_order_detail_objid);

  pod.response  := 'SUCCESS';

  RETURN pod;
EXCEPTION
WHEN OTHERS THEN
  pod.response := pod.response || '|ERROR UPDATING X_PROCESS_ORDER_DETAIL RECORD: ' || SUBSTR(SQLERRM,1,100);
  RETURN pod;

END upd;

MEMBER FUNCTION del ( i_process_order_detail_objid IN  NUMBER ) RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END del;

MEMBER FUNCTION del RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END del;

END;
/