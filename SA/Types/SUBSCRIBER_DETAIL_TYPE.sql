CREATE OR REPLACE TYPE sa.SUBSCRIBER_DETAIL_TYPE IS OBJECT
(
  subscriber_spr_objid    NUMBER(22)    ,
  add_on_offer_id         VARCHAR2(50)  ,
  add_on_ttl              DATE          ,
  add_on_redemption_date  DATE          ,
  expired_usage_date      DATE          ,
  status                  VARCHAR2(1000),
  acct_grp_benefit_objid  NUMBER        ,
  CONSTRUCTOR FUNCTION subscriber_detail_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION subscriber_detail_type ( i_subscriber_spr_objid   IN NUMBER,
                                                i_add_on_offer_id        IN VARCHAR2,
                                                i_add_on_redemption_date IN DATE) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION subscriber_detail_type ( i_subscriber_spr_objid   IN NUMBER,
                                                i_add_on_offer_id        IN VARCHAR2,
                                                i_add_on_ttl             IN DATE,
                                                i_add_on_redemption_date IN DATE,
                                                i_expired_usage_date     IN DATE) RETURN SELF AS RESULT,
  MEMBER FUNCTION ins RETURN subscriber_detail_type,
  MEMBER FUNCTION ins ( i_esn IN VARCHAR2, o_result OUT VARCHAR2 ) RETURN BOOLEAN,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION upd ( i_subscriber_spr_objid   IN NUMBER               ,
                        i_add_on_offer_id        IN VARCHAR2             ,
                        i_add_on_ttl             IN DATE   DEFAULT null ,
                        i_add_on_redemption_date IN DATE   DEFAULT null ,
                        i_expired_usage_date     IN DATE   DEFAULT null ) RETURN BOOLEAN ,
  MEMBER FUNCTION del return boolean,
  MEMBER FUNCTION getOfferID return number ,
  MEMBER FUNCTION getstatus return varchar2,
  MEMBER FUNCTION pp_ins ( i_mdn IN VARCHAR2, o_result OUT VARCHAR2 ) RETURN BOOLEAN
);
/
CREATE OR REPLACE TYPE BODY sa.SUBSCRIBER_DETAIL_TYPE AS
/***************************************************************************************************/
--$RCSfile: subscriber_detail_type.sql,v $
--$Revision: 1.34 $
--$Author: skota $
--$Date: 2018/05/21 19:26:46 $
--$ $Log: subscriber_detail_type.sql,v $
--$ Revision 1.34  2018/05/21 19:26:46  skota
--$ Modified to update the addon ttls for only active addonn
--$
--$ Revision 1.33  2018/04/16 13:59:06  skota
--$ Modified to update the addon ttls for only active addonn
--$
--$ Revision 1.32  2017/10/24 17:47:18  skota
--$ Modified
--$
--$ Revision 1.31  2017/10/24 15:47:20  skota
--$ Modified for the page plus addons
--$
--$ Revision 1.29  2017/10/10 15:56:40  skota
--$ Added changes for the pageplus addons
--$
--$ Revision 1.28  2017/07/31 16:27:35  skota
--$ Merged with Prod
--$
--$ Revision 1.27  2017/07/03 18:02:47  skota
--$ Added accnt grp benefit column in to the spr detail table
--$
--$ Revision 1.26  2017/05/03 21:52:52  jcheruvathoor
--$ Changes as prt of CR48780
--$
--$ Revision 1.25  2017/03/15 22:09:16  skota
--$ added logic to delete the records in spr detail if the addon ttl is null
--$
--$ Revision 1.24  2017/03/02 18:52:40  skota
--$ added awop compensation addon check before insert into spr detail table
--$
--$ Revision 1.23  2017/01/18 20:31:37  akhan
--$ removed ;
--$
--$ Revision 1.22  2017/01/18 20:19:11  akhan
--$ fixed a defect
--$
--$ Revision 1.21  2017/01/18 17:04:50  akhan
--$ fixed a defect
--$
--$ Revision 1.20  2017/01/16 22:23:23  akhan
--$ added an update to addon_ttl
--$
--$ Revision 1.19  2017/01/04 22:10:37  akhan
--$ only expire if they are active
--$
--$ Revision 1.18  2017/01/04 21:27:40  akhan
--$ fixed the insert not to delete and re insert
--$
--$ Revision 1.17  2017/01/04 16:12:07  akhan
--$ Added debug statement
--$
/***************************************************************************************************/

CONSTRUCTOR FUNCTION subscriber_detail_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END subscriber_detail_type;

CONSTRUCTOR FUNCTION subscriber_detail_type ( i_subscriber_spr_objid   IN NUMBER   ,
                                              i_add_on_offer_id        IN VARCHAR2 ,
                                              i_add_on_redemption_date IN DATE     ) RETURN SELF AS RESULT AS
BEGIN
  IF i_subscriber_spr_objid IS NULL OR i_add_on_offer_id IS NULL OR i_add_on_redemption_date IS NULL THEN
    self.status := 'INPUT PARAMETERS MISSING';
    RETURN;
  END IF;

  SELECT subscriber_detail_type ( subscriber_spr_objid   ,
                                  add_on_offer_id        ,
                                  add_on_ttl             ,
                                  add_on_redemption_date ,
                                  expired_usage_date     ,
                                  NULL                   , -- status
                                  acct_grp_benefit_objid
                                )
  INTO   SELF
  FROM   x_subscriber_spr_detail
  WHERE  subscriber_spr_objid = i_subscriber_spr_objid
  AND    add_on_offer_id = i_add_on_offer_id
  AND    add_on_redemption_date = i_add_on_redemption_date;

  SELF.status := 'SUCCESS';

  RETURN;
EXCEPTION
   WHEN OTHERS THEN
    SELF.subscriber_spr_objid   := i_subscriber_spr_objid;
     SELF.add_on_offer_id := i_add_on_offer_id;
     SELF.status := ''''||i_subscriber_spr_objid ||''','''||i_add_on_offer_id||''' sqlerrm = '||substr(sqlerrm,1,100);
     RETURN;
END subscriber_detail_type;

CONSTRUCTOR FUNCTION subscriber_detail_type ( i_subscriber_spr_objid   IN NUMBER,
                                              i_add_on_offer_id        IN VARCHAR2,
                                              i_add_on_ttl             IN DATE,
                                              i_add_on_redemption_date IN DATE,
                                              i_expired_usage_date     IN DATE) RETURN SELF AS RESULT AS
BEGIN
  --
  SELF.subscriber_spr_objid   := i_subscriber_spr_objid       ;
  SELF.add_on_offer_id        := i_add_on_offer_id        ;
  SELF.add_on_ttl             := i_add_on_ttl             ;
  SELF.add_on_redemption_date := i_add_on_redemption_date ;
  SELF.expired_usage_date     := i_expired_usage_date     ;
  RETURN;

END subscriber_detail_type;

MEMBER FUNCTION ins RETURN subscriber_detail_type AS

  detail   subscriber_detail_type := SELF;
BEGIN
  detail.status := null;
  IF self.subscriber_spr_objid IS NULL THEN
    detail.status := 'SUBSCRIBER ID, ';
  END IF;
  IF self.add_on_offer_id IS NULL THEN
    detail.status := 'OFFER ID';
  END IF;
  if (detail.status is not null) then
     detail.status := detail.status ||' Missing';
     return detail;
  end if;

  IF detail.exist then
    detail.status := 'OFFER ID ALREADY EXISTS (' || detail.add_on_offer_id ||')';
            RETURN detail;
  END IF;

  INSERT
  INTO   x_subscriber_spr_detail
         ( objid                  ,
           subscriber_spr_objid      ,
           add_on_offer_id        ,
           add_on_ttl             ,
           add_on_redemption_date ,
           expired_usage_date
         )
  VALUES
  ( sequ_subscriber_spr_detail.NEXTVAL ,
    detail.subscriber_spr_objid               ,
    detail.add_on_offer_id                ,
    detail.add_on_ttl                     ,
    detail.add_on_redemption_date         ,
    detail.expired_usage_date
  );

  detail.status := 'SUCCESS';
  RETURN detail;

EXCEPTION
   WHEN OTHERS THEN
     detail.status := 'ERROR ADDING SUBSCRIBER DETAIL : ' || SQLERRM;
     RETURN detail;
END ins;

MEMBER FUNCTION ins ( i_esn IN VARCHAR2, o_result OUT VARCHAR2 ) RETURN BOOLEAN IS

  sd           subscriber_detail_type := SELF;
  l_future_ttl date;
  l_base_ttl   date;
  l_addon_ttl date;

BEGIN

  -- Validate ESN input parameter
  IF i_esn IS NULL THEN
    o_result := 'ESN IS A REQUIRED INPUT PARAMETER';
    RETURN FALSE;
  END IF;

  -- Check if the subscriber exists
  BEGIN
    SELECT objid,
           future_ttl,
           pcrf_base_ttl,
           pcrf_cos
    INTO   sd.subscriber_spr_objid,
           l_future_ttl,
           l_base_ttl,
           sd.add_on_offer_id
    FROM   x_subscriber_spr
    WHERE  pcrf_esn = i_esn;
   EXCEPTION
     WHEN others THEN
       o_result := 'SUBSCRIBER NOT FOUND';
       RETURN FALSE;
  END;

  --
  IF sd.subscriber_spr_objid IS NOT NULL THEN
      SELECT  MAX(CASE WHEN nvl(spp.IGNORE_IG_FLAG,'N') = 'Y' THEN
                       CASE WHEN l_base_ttl IS NOT NULL THEN trunc(l_base_ttl)+.99999
                       ELSE NULL
                       END
                  ELSE
                      CASE WHEN l_future_ttl IS NOT NULL THEN trunc(l_future_ttl + 30) +.99999
                           WHEN rc.x_red_date IS NOT NULL THEN trunc(rc.x_red_date + 30) +.99999
                           WHEN l_base_ttl IS NOT NULL THEN trunc(l_base_ttl + 30)+.99999
                      ELSE NULL
                      END
                  END)
      INTO   l_addon_ttl
      FROM   x_account_group_member agm,
             x_account_group_benefit agb,
             table_x_red_card rc,
             sa.service_plan_feat_pivot_mv spp
      WHERE  agm.esn = i_esn
      AND    agm.account_group_id = agb.account_group_id
      AND    agb.call_trans_id = rc.red_card2call_trans
      AND    agb.service_plan_id = spp.service_plan_objid
      AND    EXISTS ( SELECT 1
                      FROM   table_x_call_trans
                      WHERE  objid = agb.call_trans_id )
      AND   (agb.end_date > SYSDATE OR (nvl(spp.IGNORE_IG_FLAG,'N') = 'Y' and agb.end_date >= trunc (l_base_ttl))); --CR48780

      -- if addon ttl is null delete
      IF l_addon_ttl IS NULL THEN
         DELETE FROM x_subscriber_spr_detail WHERE subscriber_spr_objid = sd.subscriber_spr_objid;
      ELSE
        --
        delete
        from  sa.x_subscriber_spr_detail sprd
        where sprd.subscriber_spr_objid = sd.subscriber_spr_objid
        and   exists (select 1
                      from   sa.x_account_group_benefit agb
                      where  sprd.acct_grp_benefit_objid = agb.objid
                      and    agb.status = 'EXPIRED'
                     );
        --
        UPDATE x_subscriber_spr_detail sprd
           SET sprd.add_on_ttl = l_addon_ttl
         WHERE sprd.subscriber_spr_objid  = sd.subscriber_spr_objid
           AND NOT EXISTS (SELECT 1 -- to ignore the expired add-ons and compensation add-ons
                           FROM   sa.x_account_group_benefit agb,
                                  sa.service_plan_feat_pivot_mv spp
                           WHERE  agb.objid = sprd.acct_grp_benefit_objid
                           AND    agb.service_plan_id = spp.service_plan_objid
                           AND    (agb.status = 'EXPIRED' OR nvl(spp.ignore_ig_flag,'N') = 'Y')
                          );
      END IF;
  END IF;

  BEGIN
    --
    INSERT
    INTO   x_subscriber_spr_detail
           ( objid                  ,
             subscriber_spr_objid   ,
             add_on_offer_id        ,
             add_on_ttl             ,
             add_on_redemption_date ,
             expired_usage_date     ,
             acct_grp_benefit_objid
           )
    SELECT sequ_subscriber_spr_detail.NEXTVAL,
           sd.subscriber_spr_objid,
           CASE WHEN EXISTS (	SELECT 1
                              FROM   sa.table_x_add_on_runtime_promo xrp
														  WHERE  1=1
														  AND    PROMO_GROUP = 'GROUP_1GB'
														  AND    SYSDATE <= xrp.END_DATE
														  AND    spp.service_plan_objid = xrp.sp_objid
														  AND    xrp.x_esn = i_esn
												    ) THEN 'NTPA1'
								WHEN EXISTS ( SELECT 1
                              FROM   sa.table_x_add_on_runtime_promo xrp
														  WHERE  1 = 1
														  AND    PROMO_GROUP = 'GROUP_2GB'
														  AND    SYSDATE <= xrp.END_DATE
														  AND    spp.service_plan_objid = xrp.sp_objid
														  AND    xrp.x_esn = i_esn
												    ) THEN 'NTPA2'
								ELSE spp.cos
			     END add_on_offer_id,
			 --END CR56698 -- NT $10 ADD on Promotion
		   -- CR39916 Modify the criteria to select the add on ttl based on IG_Ignore flag of service plan feature.
                CASE when nvl(spp.IGNORE_IG_FLAG,'N') = 'Y' then
                     CASE  WHEN l_base_ttl IS NOT NULL THEN trunc(l_base_ttl)+.99999 ELSE NULL END
                ELSE
                     CASE  WHEN l_future_ttl  IS NOT NULL THEN trunc(l_future_ttl + 30) +.99999
                           WHEN rc.x_red_date IS NOT NULL THEN trunc(rc.x_red_date + 30) +.99999
                           WHEN l_base_ttl    IS NOT NULL THEN trunc(l_base_ttl + 30)+.99999
                     ELSE  NULL
                     END
                END  add_on_ttl,
           rc.x_red_date add_on_redemption_date,
           NULL expired_usage_date,
           agb.objid
    FROM   x_account_group_member agm,
           x_account_group_benefit agb,
           table_x_red_card rc,
           sa.service_plan_feat_pivot_mv spp
    WHERE  agm.esn = i_esn
    AND    agm.account_group_id = agb.account_group_id
    AND    agb.call_trans_id = rc.red_card2call_trans
    AND    agb.service_plan_id = spp.service_plan_objid
    AND    EXISTS ( SELECT 1
                    FROM   table_x_call_trans
                    WHERE  objid = agb.call_trans_id
                   )
    AND    (agb.end_date > SYSDATE OR (nvl(spp.IGNORE_IG_FLAG,'N') = 'Y' and agb.end_date >= trunc (l_base_ttl))) --added for AWOP compensation  CR47042  , CR48780
       --CR43498 ADDED FOR DATA CLUB TO AVOID DUPLICATING COS VALUES
    AND    EXISTS ( SELECT 1
                    FROM   service_plan_feat_pivot_mv mv
                    WHERE  mv.service_plan_objid = sa.util_pkg.get_service_plan_id( i_esn => i_esn,
                                                                                    i_pin => rc.x_red_code)
                    AND    mv.service_plan_group = 'ADD_ON_DATA'
                  )
    AND NOT EXISTS( SELECT 1 from x_subscriber_spr_detail
                    WHERE 1 = 1
                    --and  add_on_offer_id = spp.cos
                    AND  subscriber_spr_objid = sd.subscriber_spr_objid
                    AND  add_on_redemption_date = rc.x_red_date);
  EXCEPTION
     WHEN OTHERS THEN
       o_result := 'ERROR ADDING SUBSCRIBER DETAIL : ' || SUBSTR(SQLERRM,1,100);
       RETURN FALSE;
  END;

  o_result := 'SUCCESS';

  RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
     o_result := 'ERROR ADDING SUBSCRIBER DETAIL : ' || SUBSTR(SQLERRM,1,100);
     RETURN FALSE;
END ins;

MEMBER FUNCTION exist RETURN BOOLEAN IS

detail subscriber_detail_type := subscriber_detail_type ( i_subscriber_spr_objid => SELF.subscriber_spr_objid,
                                                           i_add_on_offer_id      => SELF.add_on_offer_id,
                                                                                                                                                                           i_add_on_redemption_date => SELF.add_on_redemption_date);

BEGIN
IF detail.add_on_ttl IS NOT NULL THEN
    RETURN TRUE;
ELSE
    RETURN FALSE;
END IF;
END;

MEMBER FUNCTION upd ( i_subscriber_spr_objid   IN NUMBER               ,
                      i_add_on_offer_id        IN VARCHAR2             ,
                      i_add_on_ttl             IN DATE   DEFAULT  null ,
                      i_add_on_redemption_date IN DATE   DEFAULT  null ,
                      i_expired_usage_date     IN DATE   DEFAULT  null ) RETURN BOOLEAN AS

rows_updated number := 0;
BEGIN

  UPDATE x_subscriber_spr_detail
  SET    add_on_ttl             = DECODE(i_add_on_ttl,null, add_on_ttl, i_add_on_ttl),
         add_on_redemption_date = DECODE(i_add_on_redemption_date,null,add_on_redemption_date,i_add_on_redemption_date),
         expired_usage_date     = DECODE(i_expired_usage_date,null, expired_usage_date,i_expired_usage_date)
  WHERE  subscriber_spr_objid = i_subscriber_spr_objid
   and   add_on_offer_id = i_add_on_offer_id
   and expired_usage_date is null;

   rows_updated := sql%rowcount;
  --
  if rows_updated > 0 then
    RETURN TRUE;
  else
    RETURN FALSE;
  end if;
EXCEPTION
   WHEN OTHERS THEN
     RETURN FALSE;
END upd;

MEMBER FUNCTION del  RETURN BOOLEAN AS

  detail subscriber_detail_type := subscriber_detail_type ( i_subscriber_spr_objid   => self.subscriber_spr_objid   ,
                                                            i_add_on_offer_id        => self.add_on_offer_id        ,
                                                            i_add_on_redemption_date => self.add_on_redemption_date );

BEGIN

  IF detail.status <> 'SUCCESS' then
    RETURN FALSE;
  END IF;

  DELETE x_subscriber_spr_detail
  WHERE  subscriber_spr_objid = detail.subscriber_spr_objid
  AND    add_on_offer_id = detail.add_on_offer_id
  AND    add_on_redemption_date = detail.add_on_redemption_date;

  detail.status := 'SUCCESS';
  --
  RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
     detail.status := 'ERROR DELETING SUBSCRIBER DETAIL: ' || SQLERRM;
     RETURN FALSE;
END del;
MEMBER FUNCTION getOfferID RETURN NUMBER IS
BEGIN
RETURN self.add_on_offer_id;
END;
MEMBER FUNCTION getstatus RETURN VARCHAR2 IS
begin
  return self.status;
end;

MEMBER FUNCTION pp_ins ( i_mdn IN VARCHAR2,  o_result OUT VARCHAR2 ) RETURN BOOLEAN IS

  sd           subscriber_detail_type := SELF;
  l_future_ttl date;
  l_base_ttl   date;
  l_addon_ttl  date;

BEGIN

  -- Validate ESN input parameter
  IF i_mdn IS NULL THEN
    o_result := 'MDN IS A REQUIRED INPUT PARAMETER';
    RETURN FALSE;
  END IF;

  -- Check if the subscriber exists
  BEGIN
    SELECT objid,
           future_ttl,
           pcrf_base_ttl
    INTO   sd.subscriber_spr_objid,
           l_future_ttl,
           l_base_ttl
    FROM   x_subscriber_spr
    WHERE  pcrf_mdn = i_mdn;
   EXCEPTION
     WHEN others THEN
       o_result := 'SUBSCRIBER NOT FOUND';
       RETURN FALSE;
  END;

  --
  IF sd.subscriber_spr_objid IS NOT NULL THEN
    SELECT  trunc(l_base_ttl + 30) +.99999
    INTO    l_addon_ttl
    FROM    dual
    WHERE   EXISTS (SELECT 1
                    FROM   sa.x_pageplus_addon_benefit pab
                    WHERE  pab.pcrf_min = i_mdn
                    AND    pab.end_date >= SYSDATE);


    -- if addon ttl is null delet
    IF l_addon_ttl is null then
       DELETE FROM x_subscriber_spr_detail WHERE subscriber_spr_objid = sd.subscriber_spr_objid;
    ELSE
      UPDATE x_subscriber_spr_detail
      SET    add_on_ttl = l_addon_ttl
      WHERE  subscriber_spr_objid = sd.subscriber_spr_objid;
    END IF;
  END IF;


  BEGIN
    --
    INSERT
    INTO   x_subscriber_spr_detail
           ( objid                  ,
             subscriber_spr_objid   ,
             add_on_offer_id        ,
             add_on_ttl             ,
             add_on_redemption_date ,
             expired_usage_date     ,
             acct_grp_benefit_objid
           )
    SELECT sequ_subscriber_spr_detail.NEXTVAL,
           sd.subscriber_spr_objid,
           (select cos_value from sa.x_pageplus_cos where plan_value = pab.plan_value and rownum < 2)  ,
           trunc(l_base_ttl + 30) +.99999 ,
           pab.start_date,
           NULL expired_usage_date,
           pab.objid
    FROM   sa.x_pageplus_addon_benefit pab
    WHERE  pab.pcrf_min = i_mdn
    AND    pab.end_date >= SYSDATE
    AND    NOT EXISTS (SELECT 1
                       FROM   X_SUBSCRIBER_SPR_DETAIL
                       WHERE  subscriber_spr_objid = sd.subscriber_spr_objid
                       AND    add_on_redemption_date = pab.start_date);
   EXCEPTION
     WHEN OTHERS THEN
       o_result := 'ERROR ADDING SUBSCRIBER DETAIL : ' || SUBSTR(SQLERRM,1,100);
       RETURN FALSE;
  END;

  o_result := 'SUCCESS';

  RETURN TRUE;

 EXCEPTION
   WHEN OTHERS THEN
     o_result := 'ERROR ADDING SUBSCRIBER DETAIL : ' || SUBSTR(SQLERRM,1,100);
     RETURN FALSE;
END pp_ins;


END;
/