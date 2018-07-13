CREATE OR REPLACE TYPE sa.pcrf_transaction_detail_type IS OBJECT
(
  pcrf_transaction_detail_id   NUMBER(22)     ,
  pcrf_transaction_id          NUMBER(22)     ,
  offer_id                     VARCHAR2(50)   ,
  ttl                          DATE           ,
  future_ttl                   DATE           ,
  redemption_date              DATE           ,
  offer_name                   VARCHAR2(50)   ,
  data_usage                   NUMBER(20,2)   ,
  status                       VARCHAR2(1000) ,
  CONSTRUCTOR FUNCTION pcrf_transaction_detail_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_transaction_detail_type ( i_pcrf_transaction_id IN  NUMBER,
                                                      i_offer_id            IN  VARCHAR2,
                                                      i_redemption_date     IN  DATE) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pcrf_transaction_detail_type ( i_pcrf_transaction_id IN  NUMBER,
                                                      i_offer_id            IN  VARCHAR2,
                                                      i_ttl                 IN  DATE,
                                                      i_future_ttl          IN  DATE,
                                                      i_redemption_date     IN  DATE,
                                                      i_offer_name          IN  VARCHAR2,
                                                      i_data_usage          IN  NUMBER) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_pcrf_transaction_id IN  NUMBER,
                        i_offer_id            IN  VARCHAR2,
                        i_ttl                 IN  DATE,
                        i_future_ttl          IN  DATE,
                        i_redemption_date     IN  DATE,
                        i_offer_name          IN  VARCHAR2) RETURN pcrf_transaction_detail_type,
  MEMBER FUNCTION upd RETURN pcrf_transaction_detail_type,
  MEMBER FUNCTION del ( i_pcrf_transaction_id IN  NUMBER,
                        i_offer_id            IN  VARCHAR2,
                        i_redemption_date     IN  DATE) RETURN BOOLEAN,
  -- get the low priority flag from x_cos (table)
  MEMBER FUNCTION get_low_priority_flag ( i_pcrf_transaction_id IN NUMBER ) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY sa."PCRF_TRANSACTION_DETAIL_TYPE" AS

CONSTRUCTOR FUNCTION pcrf_transaction_detail_type RETURN SELF AS RESULT AS
BEGIN
  -- TODO: Implementation required for FUNCTION PCRF_TRANSACTION_DETAIL_TYPE.pcrf_transaction_detail_type
  RETURN;
END pcrf_transaction_detail_type;

CONSTRUCTOR FUNCTION pcrf_transaction_detail_type ( i_pcrf_transaction_id IN  NUMBER,
                                                    i_offer_id            IN  VARCHAR2,
                                                    i_redemption_date     IN  DATE) RETURN SELF AS RESULT AS

BEGIN
  -- Validate input parameters
  IF i_pcrf_transaction_id IS NULL OR i_offer_id IS NULL OR i_redemption_date IS NULL THEN
    SELF.status := 'MISSING REQUIRED INPUT PARAMETERS';
    RETURN;
  END IF;

  --
  SELECT pcrf_transaction_detail_type ( objid               ,
                                        pcrf_transaction_id ,
                                        offer_id            ,
                                        ttl                 ,
                                        future_ttl          ,
                                        redemption_date     ,
                                        offer_name          ,
                                        data_usage          ,
                                        NULL                  -- status
                                      )
  INTO   SELF
  FROM   x_pcrf_transaction_detail
  WHERE  pcrf_transaction_id = i_pcrf_transaction_id
  AND    offer_id = i_offer_id
  AND    redemption_date = i_redemption_date;

  SELF.status := 'SUCCESS';
  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.pcrf_transaction_id := i_pcrf_transaction_id;
     SELF.offer_id            := i_offer_id;
     SELF.redemption_date     := i_redemption_date;
     SELF.status := 'PCRF TRANSACTION DETAIL NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END pcrf_transaction_detail_type;

CONSTRUCTOR FUNCTION pcrf_transaction_detail_type ( i_pcrf_transaction_id IN  NUMBER,
                                                    i_offer_id            IN  VARCHAR2,
                                                    i_ttl                 IN  DATE,
                                                    i_future_ttl          IN  DATE,
                                                    i_redemption_date     IN  DATE,
                                                    i_offer_name          IN  VARCHAR2,
                                                    i_data_usage          IN  NUMBER) RETURN SELF AS RESULT AS

BEGIN

  SELF.pcrf_transaction_id := i_pcrf_transaction_id;
  SELF.offer_id            := i_offer_id;
  SELF.ttl                 := i_ttl;
  SELF.future_ttl          := i_future_ttl;
  SELF.redemption_date     := i_redemption_date;
  SELF.offer_name          := i_offer_id;
  SELF.data_usage          := i_data_usage;

  SELF.status := 'SUCCESS';
  RETURN;

 EXCEPTION
   WHEN OTHERS THEN
     SELF.pcrf_transaction_id := i_pcrf_transaction_id;
     SELF.offer_id            := i_offer_id;
     SELF.ttl                 := i_ttl;
     SELF.future_ttl          := i_future_ttl;
     SELF.redemption_date     := i_redemption_date;
     SELF.offer_name          := i_offer_id;
     SELF.data_usage          := i_data_usage;
     SELF.status := 'PCRF TRANSACTION DETAIL NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
     RETURN;
END pcrf_transaction_detail_type;

MEMBER FUNCTION exist RETURN BOOLEAN IS

  pcrf  pcrf_transaction_detail_type := pcrf_transaction_detail_type ( i_pcrf_transaction_id => SELF.pcrf_transaction_id,
                                                                       i_offer_id            => SELF.offer_id           ,
                                                                       i_redemption_date     => SELF.redemption_date    );

BEGIN
 IF pcrf.pcrf_transaction_detail_id IS NOT NULL THEN
    RETURN TRUE;
 ELSE
    RETURN FALSE;
 END IF;
END exist;

MEMBER FUNCTION ins ( i_pcrf_transaction_id IN  NUMBER,
                      i_offer_id            IN  VARCHAR2,
                      i_ttl                 IN  DATE,
                      i_future_ttl          IN  DATE,
                      i_redemption_date     IN  DATE,
                      i_offer_name          IN  VARCHAR2) RETURN pcrf_transaction_detail_type AS

  pcrf      pcrf_transaction_type := pcrf_transaction_type ( i_pcrf_transaction_id => i_pcrf_transaction_id);
  detail    pcrf_transaction_detail_type := SELF;

BEGIN
  IF pcrf.pcrf_transaction_id IS NULL THEN
    detail.status := 'PCRF TRANSACTION NOT FOUND';
	RETURN detail;
  END IF;

  -- IF pcrf.addons.COUNT > 0 THEN
  --   IF pcrf.addons.EXIST(offer_id) THEN
  --
  --   END IF;
  -- END IF;

  INSERT
  INTO   x_pcrf_transaction_detail
         ( objid               ,
           pcrf_transaction_id ,
           offer_id            ,
           ttl                 ,
           future_ttl          ,
           redemption_date     ,
           offer_name
		 )
  VALUES
  ( sequ_pcrf_transaction_detail.NEXTVAL ,
    i_pcrf_transaction_id                ,
    i_offer_id                           ,
    i_ttl                                ,
    i_future_ttl                         ,
    i_redemption_date                    ,
    i_offer_name
  );

  detail.status := 'SUCCESS';
  --
  RETURN detail;

 EXCEPTION
   WHEN OTHERS THEN
     --
     detail.status  := 'ERROR ADDING PCRF DETAIL : ' || SQLERRM;
     --
     RETURN detail;
END ins;

MEMBER FUNCTION upd RETURN pcrf_transaction_detail_type AS

  detail pcrf_transaction_detail_type := SELF;
  dt     pcrf_transaction_detail_type := pcrf_transaction_detail_type ( i_pcrf_transaction_id => SELF.pcrf_transaction_id,
                                                                        i_offer_id            => SELF.offer_id,
                                                                        i_redemption_date     => SELF.redemption_date);

  ldt    pcrf_transaction_detail_type := pcrf_transaction_detail_type ( i_pcrf_transaction_id => SELF.pcrf_transaction_id,
                                                                        i_offer_id            => SELF.offer_id,
                                                                        i_redemption_date     => SELF.redemption_date);
BEGIN
  -- TODO: Implementation for FUNCTION PCRF_TRANSACTION_DETAIL_TYPE.update_pcrf_detail
  IF SELF.pcrf_transaction_id IS NULL THEN
    detail.status := 'PCRF TRANSACTION ID IS A REQUIRED PARAMETER';
    RETURN detail;
  END IF;

  IF SELF.offer_id IS NULL THEN
    detail.status := 'OFFER ID IS A REQUIRED PARAMETER';
    RETURN detail;
  END IF;

  IF SELF.redemption_date IS NULL THEN
    detail.status := 'REDEMPTION DATE IS A REQUIRED PARAMETER';
    RETURN detail;
  END IF;

  IF SELF.ttl IS NULL AND SELF.future_ttl IS NULL AND SELF.offer_name IS NULL AND SELF.data_usage IS NULL THEN
    detail.status := 'NO VALUES PASSED TO BE UPDATED';
    RETURN detail;
  END IF;

  IF dt.pcrf_transaction_detail_id IS NULL THEN
    detail.status := 'PCRF TRANSACTION DETAIL NOT FOUND';
    RETURN detail;
  END IF;

  detail.pcrf_transaction_id := SELF.pcrf_transaction_id;
  detail.offer_id            := SELF.offer_id;
  detail.redemption_date     := SELF.redemption_date;

  DBMS_OUTPUT.PUT_LINE(detail.pcrf_transaction_detail_id);

  --
  IF detail.get_low_priority_flag ( i_pcrf_transaction_id => SELF.pcrf_transaction_id) = 'Y' THEN

    UPDATE x_pcrf_trans_detail_low_prty
    SET    ttl             = NVL(SELF.ttl, ttl),
           future_ttl      = NVL(SELF.future_ttl, future_ttl),
           offer_name      = NVL(SELF.offer_name, offer_name),
           data_usage      = NVL(SELF.data_usage, data_usage)
    WHERE  objid = ldt.pcrf_transaction_detail_id
    RETURNING ttl, future_ttl, offer_name, data_usage
    INTO      detail.ttl,
              detail.future_ttl,
              detail.offer_name,
              detail.data_usage;
  ELSE
    --
    UPDATE x_pcrf_transaction_detail
    SET    ttl             = NVL(SELF.ttl, ttl),
           future_ttl      = NVL(SELF.future_ttl, future_ttl),
           offer_name      = NVL(SELF.offer_name, offer_name),
           data_usage      = NVL(SELF.data_usage, data_usage)
    WHERE  objid = dt.pcrf_transaction_detail_id
    RETURNING ttl, future_ttl, offer_name, data_usage
    INTO      detail.ttl,
              detail.future_ttl,
              detail.offer_name,
              detail.data_usage;

  END IF;
  --
  detail.status := 'SUCCESS';
  --
  RETURN detail;

 EXCEPTION
   WHEN OTHERS THEN
     --
     detail.status := 'ERROR UPDATING PCRF TRANSACTION DETAIL : ' || SUBSTR(SQLERRM,1,100);
     --
     RETURN detail;
END upd;

MEMBER FUNCTION del ( i_pcrf_transaction_id IN  NUMBER,
                      i_offer_id            IN  VARCHAR2,
                      i_redemption_date     IN  DATE) RETURN BOOLEAN AS

  detail pcrf_transaction_detail_type := pcrf_transaction_detail_type ( i_pcrf_transaction_id => i_pcrf_transaction_id,
                                                                        i_offer_id            => i_offer_id,
                                                                        i_redemption_date     => i_redemption_date);
BEGIN
  IF detail.pcrf_transaction_detail_id IS NULL THEN
    detail.status := 'PCRF DETAIL NOT FOUND';
    RETURN FALSE;
  END IF;

  DELETE x_pcrf_transaction_detail
  WHERE  objid = detail.pcrf_transaction_detail_id;

  --
  detail.status := 'SUCCESS';

  RETURN TRUE;

 EXCEPTION
   WHEN OTHERS THEN
     --
     detail.status := 'ERROR DELETING PCRF DETAIL : ' || SQLERRM;
     --
     RETURN FALSE;
END del;

-- get the low priority flag from x_cos (table)
MEMBER FUNCTION get_low_priority_flag ( i_pcrf_transaction_id IN NUMBER ) RETURN VARCHAR2 IS

  c_low_priority_flag  VARCHAR2(1) := 'N';

BEGIN
  -- exit when the cos is not passed
  IF i_pcrf_transaction_id IS NULL THEN
    RETURN('N');
  END IF;

  -- get the low priority flag from the X_COS table
  BEGIN
    SELECT NVL(pcrf_low_priority_flag,'N')
    INTO   c_low_priority_flag
    FROM   x_cos
    WHERE  cos = ( SELECT pcrf_cos
                   FROM   x_pcrf_transaction
                   WHERE  objid = i_pcrf_transaction_id
                 );
   EXCEPTION
     WHEN others THEN
       c_low_priority_flag := 'N';
  END;

  -- return value
  RETURN (NVL(c_low_priority_flag,'N'));

 EXCEPTION
   WHEN OTHERS THEN
     RETURN('N');
END get_low_priority_flag;

END;
/