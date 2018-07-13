CREATE OR REPLACE TYPE sa.process_order_type AS OBJECT
/*************************************************************************************************************************************
  * $Revision: 1.8 $
  * $Author: sinturi $
  * $Date: 2018/04/03 15:11:25 $
  * $Log: process_order_type_spec.SQL,v $
  * Revision 1.8  2018/04/03 15:11:25  sinturi
  * updated after review
  *
  * Revision 1.4  2017/06/12 19:18:06  sraman
  * CR50433 - Added Channel Column
  *
  * Revision 1.3  2017/02/28 22:22:06  sraman
  * CR47564 -  modified  retrieve method to use external order id column
  *
  * Revision 1.2  2017/02/14 22:28:09  sgangineni
  * Removed the grants to the below roles ROLE_SA_UPDATE, ROLE_REPORT_UPDATE, ROLE_SA_SELECT
  *
  * Revision 1.1  2017/02/01 17:07:01  sraman
  * CR47564 - Process order Type Spec. This is the header.
  *
  *************************************************************************************************************************************/

(
  process_order_objid              NUMBER,
  transaction_date                 DATE,
  External_Order_ID                VARCHAR2(100),
  Order_Id                         VARCHAR2(100),
  BRM_Trans_ID                     VARCHAR2(100),
  insert_timestamp                 DATE ,
  update_timestamp                 DATE ,
  order_detail                     process_order_detail_tab,
  Channel                          VARCHAR2(30)  , --CR50433
  -- CR55836 Begin
  store_id                         VARCHAR2(30), -- adjust the names
  register_id                      VARCHAR2(30),
  user_id                          VARCHAR2(30),
  party_id                         VARCHAR2(30),
  request_payload                  XMLTYPE,
  response_payload                 XMLTYPE,
  -- End
  response                         VARCHAR2(1000),
  CONSTRUCTOR FUNCTION process_order_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION process_order_type ( i_process_order_objid IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION process_order_type ( i_Order_Id IN VARCHAR2 ,
                                            i_BRM_Trans_ID IN VARCHAR2 ,
											i_external_order_id IN VARCHAR2 ,
											i_detail_flag IN VARCHAR2 DEFAULT 'N'
										  ) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_process_order_type IN process_order_type ) RETURN process_order_type,
  MEMBER FUNCTION ins RETURN process_order_type,
  MEMBER FUNCTION upd ( i_process_order_type IN process_order_type ) RETURN process_order_type,
  MEMBER FUNCTION del ( i_process_order_objid IN  NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN
);
/
CREATE OR REPLACE TYPE BODY sa.process_order_type AS
/*************************************************************************************************************************************
  * $Revision: 1.13 $
  * $Author: sinturi $
  * $Date: 2018/04/03 15:11:25 $
  * $Log: process_order_type.SQL,v $
  * Revision 1.13  2018/04/03 15:11:25  sinturi
  * updated after review
  *
  * Revision 1.9  2017/06/12 19:28:17  sraman
  * Added Channel column to the header
  *
  * Revision 1.8  2017/06/06 19:04:41  sraman
  * Added new columns
  *
  * Revision 1.7  2017/06/06 18:47:13  sraman
  * Added additional columns
  *
  * Revision 1.6  2017/03/08 18:44:13  nsurapaneni
  * Process order Type insert and update changes
  *
  * Revision 1.4  2017/02/23 23:13:16  sraman
  * CR47564- Added new column CaseStatus,CallTransSatus,Action
  *
  * Revision 1.3  2017/02/20 21:50:47  sraman
  * CR47564- Added new column min, pin and pin_status
  *
  * Revision 1.2  2017/02/14 22:28:09  sgangineni
  * Removed the grants to the below roles ROLE_SA_UPDATE, ROLE_REPORT_UPDATE , ROLE_SA_SELECT
  *
  * Revision 1.1  2017/02/01 17:12:25  sraman
  * CR47564 - Process order header type body initial version
  *
  *************************************************************************************************************************************/

CONSTRUCTOR FUNCTION process_order_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END process_order_type;

CONSTRUCTOR FUNCTION process_order_type ( i_process_order_objid IN NUMBER ) RETURN SELF AS RESULT AS
  cst sa.customer_type := sa.customer_type();
BEGIN
  IF i_process_order_objid IS NULL THEN
    SELF.response := 'PROCESS ORDER OBJID NOT PASSED';
    RETURN;
  END IF;

  --fetching header
  SELECT process_order_type(  xpo.objid              ,
                              xpo.transaction_date   ,
                              xpo.External_Order_ID  ,
                              xpo.Order_Id           ,
                              xpo.BRM_Trans_ID       ,
                              xpo.insert_timestamp   ,
                              xpo.update_timestamp   ,
                              null                   , --order_detail
                              xpo.Channel            ,
                              xpo.store_id           ,
                              xpo.register_id        ,
                              xpo.user_id            ,
                              xpo.party_id           ,
                              xpe.request_payload    ,
                              xpe.response_payload   ,
                              null                     --Response
                            )
  INTO SELF
  FROM  x_process_order xpo
  LEFT OUTER JOIN x_process_order_extension xpe ON xpo.objid = xpe.process_order_objid
  WHERE xpo.objid = i_process_order_objid;

  -- Fecthing the details
  SELECT process_order_detail_type(  pd.objid                ,
                                     pd.process_order_objid  ,
                                     pd.case_objid           ,
                                     pd.call_trans_objid     ,
                                     pd.order_status         ,
                                     min                     , -- MIN
                                     NULL                    , -- PIN
                                     NULL                    , -- PIN STATUS
                                     NULL                    , -- CASE_STATUS
                                     NULL                    , -- ACTION_TEXT
                                     NULL                    , -- CALLTRANS_STATUS
                                     Order_Type              ,
                                     BAN                     ,
                                     ESN                     ,
                                     SMP                     ,
                                     pd.insert_timestamp     ,
                                     pd.update_timestamp     ,
                                     NULL                      -- Response
                                   )
  BULK COLLECT
  INTO  SELF.order_detail
  FROM  x_process_order_detail pd
  WHERE process_order_objid = SELF.process_order_objid;

  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
    WHEN OTHERS THEN
      SELF.response   := 'PROCESS ORDER NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.process_order_objid := i_process_order_objid;
      RETURN;
END process_order_type;

CONSTRUCTOR FUNCTION process_order_type ( i_order_id          IN VARCHAR2 ,
                                          i_brm_trans_id      IN VARCHAR2,
                                          i_external_order_id IN VARCHAR2,
                                          i_detail_flag       IN VARCHAR2 DEFAULT 'N' ) RETURN SELF AS RESULT AS

BEGIN

  IF i_order_id IS NULL AND i_brm_trans_id IS NULL AND i_external_order_id IS NULL THEN
    SELF.response := 'ORDER ID / BRM Trans ID	/ EXTERNAL ORDER ID NOT PASSED';
    RETURN;
  END IF;

  -- fetching header
  SELECT process_order_type ( xpo.objid              ,
                              xpo.transaction_date   ,
                              xpo.External_Order_ID  ,
                              xpo.Order_Id           ,
                              xpo.BRM_Trans_ID       ,
                              xpo.insert_timestamp   ,
                              xpo.update_timestamp   ,
                              null                   , --order_detail
                              xpo.Channel            ,
                              xpo.store_id           ,
                              xpo.register_id        ,
                              xpo.user_id            ,
                              xpo.party_id           ,
                              xpe.request_payload    ,
                              xpe.response_payload   ,
                              NULL                    -- response
                           )
  INTO   SELF
  FROM   x_process_order xpo
  LEFT OUTER JOIN x_process_order_extension xpe ON xpo.objid = xpe.process_order_objid
  WHERE  ( xpo.order_id = i_order_id OR xpo.brm_trans_id = i_brm_trans_id OR xpo.external_order_id = i_external_order_id );

  SELF.response := 'SUCCESS';

  RETURN;

 EXCEPTION
    WHEN OTHERS THEN
      SELF.response       := 'ORDER ID / BRM Trans ID /EXTERNAL ORDER ID NOT FOUND' || SUBSTR(SQLERRM,1,100);
	  SELF.Order_Id       := i_Order_Id;
	  SELF.BRM_Trans_ID   := i_BRM_Trans_ID;
	  SELF.External_Order_ID := i_External_Order_ID;
      RETURN;
END process_order_type;

MEMBER FUNCTION exist RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END exist;

MEMBER FUNCTION ins ( i_process_order_type IN process_order_type ) RETURN process_order_type AS
  po    process_order_type        := i_process_order_type;
  --pod   process_order_detail_type := process_order_detail_type();
BEGIN

  -- assign values to attributes
  IF po.process_order_objid IS NULL THEN
    po.process_order_objid  := sa.seq_process_order.nextval;
  END IF;

  IF po.transaction_date IS NULL THEN
    po.transaction_date  := SYSDATE;
  END IF;

  IF po.Order_Id IS NULL THEN
    po.Order_Id  := po.process_order_objid ||'-' ||TO_CHAR( sysdate, 'DDDSSSSS' )  ||'-' ||TRUNC(dbms_random.value(100000,999999));
  END IF;

  IF po.insert_timestamp IS NULL THEN
    po.insert_timestamp  := SYSDATE;
  END IF;

  IF po.update_timestamp IS NULL THEN
    po.update_timestamp  := SYSDATE;
  END IF;

  -- Insert Header
  BEGIN
    INSERT
    INTO x_process_order
    (
       objid                   ,
       transaction_date        ,
       external_order_id       ,
       order_id                ,
       brm_trans_id            ,
       Channel                 ,
       insert_timestamp        ,
       update_timestamp        ,
       store_id                ,
       register_id             ,
       user_id                 ,
       party_id
     )
    VALUES
    (
       po.process_order_objid    ,
       po.transaction_date       ,
       po.External_Order_ID      ,
       po.Order_Id               ,
       po.BRM_Trans_ID           ,
       po.Channel                ,
       po.insert_timestamp       ,
       po.update_timestamp       ,
       po.store_id               ,
       po.register_id            ,
       po.user_id                ,
       po.party_id
     );
  EXCEPTION
  WHEN OTHERS THEN
    po.response := po.response || '|ERROR INSERTING X_PROCESS_ORDER RECORD: ' || SUBSTR(SQLERRM,1,100);
    RETURN po;
  END;


  BEGIN
    INSERT
    INTO x_process_order_extension
    (
      process_order_objid  ,
      request_payload      ,
      response_payload     ,
      insert_timestamp
    )
    VALUES
    (
      po.process_order_objid ,
      po.request_payload     ,
      po.response_payload    ,
      po.insert_timestamp
    );
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;

   IF po.order_detail IS NOT NULL THEN
     FOR i IN 1..po.order_detail.COUNT
     LOOP
       --pod                     :=  po.order_detail(i);
       --pod.process_order_objid :=  po.process_order_objid;
       --po.order_detail(i)      :=  pod.ins;
       --
       po.order_detail(i).process_order_objid := po.process_order_objid;
       po.order_detail(i) :=  po.order_detail(i).ins;

	   IF po.response <> 'SUCCESS'
	   THEN
	     po.response := po.response || '|ERROR INSERTING X_PROCESS_ORDER_DETAIL RECORD: ' || SUBSTR(SQLERRM,1,100);
	     RETURN po;
	   END IF;

     END LOOP;
  END IF;

  -- set Success Response
  po.response  := 'SUCCESS';

  RETURN po;

EXCEPTION
WHEN OTHERS THEN
  po.response := po.response || '|ERROR INSERTING X_PROCESS_ORDER RECORD: ' || SUBSTR(SQLERRM,1,100);
  RETURN po;
END ins;

MEMBER FUNCTION ins RETURN process_order_type AS
  po   process_order_type := SELF;
  i    process_order_type;
BEGIN
  i := po.ins ( i_process_order_type => po );
  RETURN i;

END ins;

MEMBER FUNCTION upd ( i_process_order_type IN process_order_type ) RETURN process_order_type AS
  po    process_order_type        := process_order_type();
  pod   process_order_detail_type := process_order_detail_type();
BEGIN

  po := i_process_order_type;

  -- update header
  UPDATE x_process_order
  SET    objid                   = NVL(po.process_order_objid          , objid                      ),
         transaction_date        = NVL(po.transaction_date             , transaction_date           ),
         External_Order_ID       = NVL(po.External_Order_ID            , External_Order_ID          ),
         Order_Id                = NVL(po.Order_Id                     , Order_Id                   ),
         BRM_Trans_ID            = NVL(po.BRM_Trans_ID                 , BRM_Trans_ID               ),
         Channel                 = NVL(po.Channel                      , Channel                    ),
         store_id                = NVL(po.store_id                     , store_id                   ),
         register_id             = NVL(po.register_id                  , register_id                ),
         user_id                 = NVL(po.user_id                      , user_id                    ),
         party_id                = NVL(po.party_id                     , party_id                   ),
         update_timestamp        = SYSDATE
  WHERE  Order_Id =  po.Order_Id
  RETURNING objid
  INTO      po.process_order_objid;

  UPDATE x_process_order_extension
  SET    process_order_objid  = NVL(po.process_order_objid   , process_order_objid ),
         request_payload      = NVL(po.request_payload       , request_payload     ),
         response_payload     = NVL(po.response_payload      , response_payload    ),
         updated_timestamp    = SYSDATE
  WHERE  process_order_objid  = po.process_order_objid;

  -- only update when detail is not empty
  IF po.order_detail IS NOT NULL THEN
    -- update order details
    FOR i IN 1..po.order_detail.COUNT
    LOOP
      --l_pod                     :=  process_order_detail_type();
      --l_pod                     :=  po.order_detail (i);
      po.order_detail(i).process_order_objid :=  po.process_order_objid;
      po.order_detail(i) :=  pod.upd ( i_process_order_detail_type => po.order_detail (i) ) ;
   END LOOP;

  END IF;

  -- set Success Response
  po := process_order_type ( i_process_order_objid  => po.process_order_objid );

  po.response  := 'SUCCESS';

  RETURN po;

EXCEPTION
WHEN OTHERS THEN
  po.response := po.response || '|ERROR UPDATING X_PROCESS_ORDER RECORD: ' || SUBSTR(SQLERRM,1,100);
  RETURN po;

END upd;

MEMBER FUNCTION del ( i_process_order_objid IN  NUMBER ) RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END del;

MEMBER FUNCTION del RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END del;

END;
/