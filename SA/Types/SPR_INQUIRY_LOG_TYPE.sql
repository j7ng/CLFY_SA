CREATE OR REPLACE TYPE sa.spr_inquiry_log_type IS OBJECT
(
  spr_inquiry_log_objid        NUMBER(22)             ,
  esn                          VARCHAR2(30)           ,
  min                          VARCHAR2(30)           ,
  msid                         VARCHAR2(30)           ,
  subscriber_id                VARCHAR2(50)           ,
  group_id                     VARCHAR2(50)           ,
  wf_mac_id                    VARCHAR2(50)           ,
  response_code                NUMBER(3)              ,
  response_message             VARCHAR2(1000)         ,
  sourcesystem                 VARCHAR2(30)           ,
  status                       VARCHAR2(1000)         ,
  CONSTRUCTOR FUNCTION spr_inquiry_log_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION spr_inquiry_log_type (i_esn              IN  VARCHAR2 DEFAULT NULL ,
                                             i_min              IN  VARCHAR2 DEFAULT NULL ,
                                             i_msid             IN  VARCHAR2 DEFAULT NULL ,
                                             i_subscriber_id    IN  VARCHAR2 DEFAULT NULL ,
                                             i_group_id         IN  VARCHAR2 DEFAULT NULL ,
                                             i_wf_mac_id        IN  VARCHAR2 DEFAULT NULL ,
                                             i_response_code    IN  NUMBER   DEFAULT NULL ,
                                             i_response_message IN  VARCHAR2 DEFAULT NULL ,
                                             i_sourcesystem     IN  VARCHAR2 DEFAULT NULL) RETURN SELF AS RESULT,
  MEMBER FUNCTION ins ( o_result OUT VARCHAR2 ) RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY sa.spr_inquiry_log_type AS

CONSTRUCTOR FUNCTION spr_inquiry_log_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END spr_inquiry_log_type;

CONSTRUCTOR FUNCTION spr_inquiry_log_type (i_esn              IN  VARCHAR2 DEFAULT NULL ,
                                           i_min              IN  VARCHAR2 DEFAULT NULL ,
                                           i_msid             IN  VARCHAR2 DEFAULT NULL ,
                                           i_subscriber_id    IN  VARCHAR2 DEFAULT NULL ,
                                           i_group_id         IN  VARCHAR2 DEFAULT NULL ,
                                           i_wf_mac_id        IN  VARCHAR2 DEFAULT NULL ,
                                           i_response_code    IN  NUMBER   DEFAULT NULL ,
                                           i_response_message IN  VARCHAR2 DEFAULT NULL ,
                                           i_sourcesystem     IN  VARCHAR2 DEFAULT NULL) RETURN SELF AS RESULT AS
BEGIN
  SELF.esn              := i_esn               ;
  SELF.min              := i_min               ;
  SELF.msid             := i_msid              ;
  SELF.subscriber_id    := i_subscriber_id     ;
  SELF.group_id         := i_group_id          ;
  SELF.wf_mac_id        := i_wf_mac_id         ;
  SELF.response_code    := i_response_code     ;
  SELF.response_message := i_response_message  ;
  SELF.sourcesystem     := i_sourcesystem      ;
  RETURN;
END;

MEMBER FUNCTION ins ( o_result OUT VARCHAR2) RETURN NUMBER AS

  inq spr_inquiry_log_type := SELF;
  PRAGMA autonomous_transaction;
  l_spr_inquiry_log_objid NUMBER;
BEGIN
  IF SELF.esn              IS NULL AND
     SELF.min              IS NULL AND
     SELF.msid             IS NULL AND
	 SELF.subscriber_id    IS NULL AND
     SELF.response_code    IS NULL AND
     SELF.response_message IS NULL AND
     SELF.sourcesystem     IS NULL
  THEN
    inq.status := 'NO INPUT VALUES PASSED';
	o_result := 'NO INPUT VALUES PASSED';
	RETURN(0);
  END IF;

  --
  INSERT
  INTO   sa.x_spr_inquiry_log
         ( objid              ,
           esn                ,
           min                ,
           msid               ,
           response_code      ,
           response_message   ,
           sourcesystem       ,
		   subscriber_id
         )
  VALUES
  ( sequ_spr_inquiry_log.NEXTVAL ,
    SELF.esn                ,
    SELF.min                ,
    SELF.msid               ,
    SELF.response_code      ,
    SELF.response_message   ,
    SELF.sourcesystem       ,
	SELF.subscriber_id
  )
  RETURNING objid INTO l_spr_inquiry_log_objid;
  inq.status := 'SUCCESS';
  o_result := 'SUCCESS';

  -- Must commit or rollback using pragma autonomous_transaction
  COMMIT;
  RETURN l_spr_inquiry_log_objid;
  --
 EXCEPTION
  WHEN OTHERS THEN
    o_result := 'ERROR INSERTING INQUIRY LOG ' || SUBSTR(sqlerrm,1,100);
    RETURN(0);
    ROLLBACK;
END ins;
END;
/