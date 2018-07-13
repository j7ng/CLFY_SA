CREATE OR REPLACE PACKAGE BODY sa."SP_METADATA" IS
 --------------------------------------------------------------------------------------------
 --$RCSfile: SP_METADATA_PKB.sql,v $
 --$Revision: 1.121 $
 --$Author: skambhammettu $
 --$Date: 2017/12/18 19:59:14 $
 --$ $Log: SP_METADATA_PKB.sql,v $
 --$ Revision 1.121  2017/12/18 19:59:14  skambhammettu
 --$ Change in Retrieving promo objid and sript id  using PROMO CODE(input paramter)
 --$
 --$ Revision 1.120  2017/12/12 23:45:13  abustos
 --$ C91087 - Correct issue for TF promocodes
 --$
 --$ Revision 1.119  2017/12/07 14:18:36  skambhammettu
 --$ CR53217
 --$
 --$ Revision 1.118  2017/11/24 22:29:46  sinturi
 --$ Condition Added
 --$
 --$ Revision 1.117  2017/11/13 20:48:06  smeganathan
 --$ incorporated review comments
 --$
 --$ Revision 1.115  2017/11/13 19:35:12  sinturi
 --$ Added condition
 --$
 --$ Revision 1.114  2017/10/30 21:55:37  smeganathan
 --$ changes in vas added logic to retrieve part number based on billing program
 --$
 --$ Revision 1.113  2017/10/27 20:59:28  smeganathan
 --$ removed vas program tax check
 --$
 --$ Revision 1.112  2017/10/25 20:27:53  smeganathan
 --$ changes in vas proration service to get data based on billing program id
 --$
 --$ Revision 1.111  2017/10/24 20:55:57  smeganathan
 --$ changes in vas proration service
 --$
 --$ Revision 1.110  2017/10/24 20:51:37  smeganathan
 --$ changes in vas proration service
 --$
 --$ Revision 1.109  2017/10/23 18:59:17  smeganathan
 --$ new overloaded procedure vas proration service added
 --$
 --$ Revision 1.105  2017/10/09 17:53:56  smeganathan
 --$ added validations in vas proration services procedure
 --$
 --$ Revision 1.104  2017/10/06 18:51:22  smeganathan
 --$ added validations in vas proration services procedure
 --$
 --$ Revision 1.101  2017/09/28 21:47:52  smeganathan
 --$ new procedures for VAS proration
 --$
 --$ Revision 1.100  2017/09/20 22:09:12  smeganathan
 --$ New procedures for proration logic
 --$
 --$ Revision 1.99  2017/06/20 18:00:39  smeganathan
 --$ merged with 6/20 production release
 --$
 --$ Revision 1.98  2017/06/15 15:45:59  nkandagatla
 --$ Merged with 6/6 Production
 --$
 --$ Revision 1.97  2017/05/26 14:41:04  tbaney
 --$ Added logic for APP partnumbers.  CR48480
 --$
 --$ Revision 1.93  2017/04/19 18:59:26  tbaney
 --$ CR48480 Corrected default for parameter.
 --$
 --$ Revision 1.92  2017/04/19 17:26:37  tbaney
 --$ CR48480 Logic for Affiliated partners.
 --$
 --$ Revision 1.91  2016/12/06 15:08:57  rpednekar
 --$ CR44459- Changes to add multi plan purchase discount.
 --$
 --$ Revision 1.90  2016/12/05 17:52:10  rpednekar
 --$ CR44459- Changes to add multi plan purchase discount.
 --$
 --$ Revision 1.86  2016/09/29 23:07:51  mgovindarajan
 --$ CR45122:  Removed Brandname check when calling validate_promo_code_ext since the Front end is not passing Brand name.
 --$
 --$ Revision 1.85  2016/09/29 18:34:57  mgovindarajan
 --$ CR45122 : Use the correct price for TF Smartphone when calling validate_promo_code_ext
 --$
 --$ Revision 1.84  2016/08/26 18:06:31  mgovindarajan
 --$ CR42361 added new validate promo code procedure for smartphones, merged with production copy.
 --$
 --$ Revision 1.82  2016/08/12 21:09:13  rpednekar
 --$ CR41745 - Changed query to identify sales tax only part numbers.
 --$
 --$ Revision 1.81  2016/08/05 15:41:17  rpednekar
 --$ CR41745 - Changes done to identify sales tax only part numbers.
 --$
 --$ Revision 1.80  2016/08/03 21:55:20  rpednekar
 --$ CR41745 - Added wrapper procedure with original parameters to modified procedure getcartmetadata
 --$
 --$ Revision 1.79  2016/08/02 21:13:33  rpednekar
 --$ CR41745 - Added new function is_salestax_only and output parameters to procedure getcartmetadata
 --$
 --$ Revision 1.78  2015/11/25 16:19:24  rpednekar
 --$ CR39674 - Modified query that gets price for SL E911 part number.
 --$
 --$ Revision 1.77  2015/11/25 16:13:40  rpednekar
 --$ CR39674
 --$
 --$ Revision 1.76  2015/10/21 14:28:16  rpednekar
 --$ CR37485 - Price of safelink e911 is assigned as zero.
 --$
 --$ Revision 1.75  2015/10/19 19:04:31  rpednekar
 --$ CR37485
 --$
 --$ Revision 1.74  2015/10/19 17:11:44  rpednekar
 --$ CR34623
 --$
 --$ Revision 1.73  2015/07/08 22:02:56  rpednekar
 --$ Reverted to 1.70
 --$
 --$ Revision 1.70  2015/06/30 15:42:45  rpednekar
 --$ Changes done by Rahul for BRANCH.Branch_2015 - Defect # 3155 for CR 33056
 --$
 --$ Revision 1.69  2015/05/29 20:35:33  vyegnamurthy
 --$ CR35332
 --$
 --$ Revision 1.68  2015/05/14 14:27:31  vmadhawnadella
 --$ fixed tax for DATA and TEXT card.
 --$
 --$ Revision 1.66  2015/04/15 13:41:42  vmadhawnadella
 --$ ADD LOGIC  FOR $10.00 TEXT ONLY CARD.
 --$
 --$ Revision 1.65  2015/02/20 21:19:53  vkashmire
 --$ CR32086 sit1 defect fix#144
 --$
 --$ Revision 1.64  2015/02/16 20:22:19  vkashmire
 --$ CR30286 - code merged with prod
 --$
  --$ Revision 1.62  2015/01/30 14:56:17  vmadhawnadella
  --$ add logic for simple mobile for auto reup.
  --$
  --$ Revision 1.54  2014/09/26 15:07:50  jpena
  --$ Modify decode function to include new UDP source system entry in getprice_tot  Stored Procedure.
  --$
  --$ Revision 1.51  2014/08/18 17:41:30  rramachandran
  --$ CR25335 - ST, NT, TC,  SM Web - No tax when purchased "$10 Pay as you go plan
  --$
  --$ Revision 1.50  2014/08/15 21:00:53  rramachandran
  --$ CR25335 - ST, NT, TC,  SM Web - No tax when purchased "$10 Pay as you go plan"
  --$
  --$ Revision 1.49  2014/06/18 18:51:00  oarbab
  --$ CR22106 added one line 'WMKIOSK' , 'WEB' ,
  --$
  --$ Revision 1.48  2014/05/16 19:17:15  mvadlapally
  --$ CR27270 Audiovox Car Connection
  --$
  --$ Revision 1.47  2014/04/04 21:53:33  icanavan
  --$ fix logic for airtime
  --$
  --$ Revision 1.42  2013/11/15 16:11:27  icanavan
  --$ added missing brackets
  --$
  --$ Revision 1.38  2013/09/10 15:09:14  ymillan
  --$ CR23513
  --$
  --$ Revision 1.37  2013/08/14 19:05:50  ymillan
  --$ CR24397
  --$
  --$ Revision 1.35  2013/08/06 19:32:39  ymillan
  --$ CR24397
  --$
  --$ Revision 1.33  2013/01/08 20:52:27  icanavan
  --$ merge VAS with production rollout
  --$
  --$ Revision 1.32  2013/01/04 19:10:45  mmunoz
  --$ CR23042 : Updated query in cursor airtime_billing, merged with production version
  --$
  --$ Revision 1.30  2012/11/30 23:05:03  mmunoz
  --$ CR22380 : Handset Protection Program - Phase I (Changes merged with rev. 1.29 )
  --$
  --$ Revision 1.29  2012/11/23 21:35:53  ymillan
  --$ Cr21966
  --$
  --$ Revision 1.28  2012/11/23 21:19:07  ymillan
  --$ CR19041 CR21966
  --$
  --$ Revision 1.25  2012/11/01 16:00:21  kacosta
  --$ CR22460 NT Promo Logic - CSR issue with discounts
  --$
  --$ Revision 1.24  2012/11/01 15:11:18  kacosta
  --$ CR22460 NT Promo Logic - CSR issue with discounts
  --$
  --$ Revision 1.23  2012/10/31 21:55:00  kacosta
  --$ CR22460 NT Promo Logic - CSR issue with discounts
  --$
  --$ Revision 1.22  2012/10/31 18:15:41  kacosta
  --$ CR22460 NT Promo Logic - CSR issue with discounts
  --$
  --$ Revision 1.18  2012/10/04 13:01:39  ymillan
  --$ CR21192 CR21964
  --$
  --$ Revision 1.17  2012/07/31 15:13:02  kacosta
  --$ CR21610 Missing records in purchase tables for Safelink
  --$
  --$ Revision 1.16  2012/07/10 18:42:32  ymillan
  --$ CR19467
  --$
  --$ Revision 1.15  2012/06/19 20:43:52  ymillan
  --$ CR19467
  --$
  --$ Revision 1.14  2012/06/05 15:08:28  ymillan
  --$ CR19467
  --$
  --$ Revision 1.12  2012/03/01 22:18:43  mmunoz
  --$ Modified procedure getprice_tot to get pricing related with WEB when source system is WAP or BEAST
  --$
  --$ Revision 1.11  2012/03/01 21:25:33  mmunoz
  --$ Adding CVS header. This version is the same in production at 03/01/2011
  --$
  --------------------------------------------------------------------------------------------
  /***************************************************************************************************************
  * Package Name: sp_METADATA
  * Description: The package is called by  Clarify
  *              to get info about part number and promo for use in taxes calculation
  *
  * Created by: YM
  * Date:  10/07/2010
  *
  * History
  * -------------------------------------------------------------------------------------------------------------------------------------
  * 10/07/2010         YM                 Initial Version                               CR11553
  * 03/15/2011         YM                 add getcartmetadata_b2b                       CR11553
  * 04/18/2011         YM                 add logic for channel BUYNOW                  CR14282
  * 04/20/2011         YM                 add logic for handset use sp_purchase         CR14282
  * 05/31/2011         NG                 remove logic for part class buynow            CR15035
  * 06/15/2011         PM                  Walmart Money Card changes                    CR15373
  * 08/31/2100         YM                 StraightTalk Retention - APP Migration        CR17340, CR12838
  *                                        use new view  sa.Service_Plan_Flat_Summary
  * 06/05/2012         MM                  CR20557
  * 03/20/2012         YM/PM               ST and NET10 promo                           CR19467
  * 10/10/2012         CL                  Billing Mobile                               CR19041/CR21966
  * 01/08/2013         IC                  VAS - My Account Application                 CR21961/CR19080
  * 03/26/2014         IC/VT               CHANGE SIGNATURE FOR GETCARTMETADATA
  * 09/29/2016         MG/VM               Call the validate_promo_code_ext for tracfone  CR42361
  *                                         and smartphone and use the correct price for
  *                                         the transaction amount instead of redeem units
  *******************************************************************************************************************/
PROCEDURE getprice_tot
  (
    p_part_number  IN VARCHAR2
   ,p_source       IN VARCHAR2
   ,p_retail_price OUT NUMBER
   ,p_redeem_units OUT NUMBER
   ,p_redeem_days  OUT NUMBER
   ,p_result       OUT NUMBER
  ) IS
    CURSOR price_cur(v_source IN VARCHAR2) IS
      SELECT tp.x_retail_price
            ,pn.x_redeem_days
            ,pn.x_redeem_units
        FROM table_x_pricing tp
            ,table_part_num  pn
       WHERE 1 = 1
         AND tp.x_end_date + 0 > SYSDATE
         AND tp.x_channel || '' = DECODE(domain
                                        ,'BILLING PROGRAM'
                                        ,DECODE(tp.x_channel
                                               ,'LIFELINE'
                                               ,'LIFELINE'
                                               ,'BILLING'
                                               ,'BILLING')
                                         ,DECODE(V_SOURCE ,'HANDSET' , 'BUYNOW' ,
                                                            'WAP'   , 'WEB' ,
                                                            'BEAST' , 'WEB' ,
                                                            'APP'   , 'WEB' ,
                                                            'WMKIOSK','WEB' , -- CR22106
                                                            'UDP'    ,'WEB' , -- CR28456 Added by Jpena on 09/26/2014
                                                            'TAS'  , 'WEBCSR',   --CR23513 surepay CR24397
                                                            v_source)) --  CR15035 / CR19724 / CR21961
         AND tp.x_pricing2part_num = pn.objid + 0
         AND pn.part_number = p_part_number;
    price_rec price_cur%ROWTYPE;

    -- CR15035
    --cursor price_bn_cur   is
    --Select tp.x_retail_price, pn.x_redeem_days,pn.x_redeem_units
    --  from table_x_pricing TP,
    --       table_part_num pn
    --where 1=1
    --   and tp.x_end_date+0 > sysdate
    --   and tp.x_channel||'' = 'BUYNOW'
    --   and TP.X_PRICING2PART_NUM = pn.objid+0
    --   and pn.part_number =p_part_number;
    --price_bn_rec price_bn_cur%rowtype;
    --cursor class_buynow_cur  is
    --Select pc.objid
    --  from table_part_class pc,
    --table_part_num pn
    --where 1=1
    --and pc.x_model_number like '%BUYNOW%'
    --and pn.part_num2part_class = pc.objid
    --and pn.part_number =p_part_number;
    --class_buynow_rec class_buynow_cur%rowtype;
    CURSOR domain_cur IS
      SELECT domain
        FROM table_part_num
       WHERE part_number = p_part_number;
    domain_rec domain_cur%ROWTYPE;
  BEGIN
    /* -- CR15035
         open domain_cur;
         fetch domain_cur into domain_rec;
        If  domain_cur%found then
           open class_buynow_cur;
           fetch class_buynow_cur into class_buynow_rec;
         If class_buynow_cur%found then
            Open price_bn_Cur;
            Fetch price_bn_Cur Into price_bn_Rec;
           If price_bn_Cur%Found Then
                 close price_bn_Cur;
                 close domain_cur;
                 close class_buynow_cur;
                 p_retail_price:= price_bn_Rec.x_retail_price;
                 p_redeem_days:= price_bn_Rec.x_redeem_days;
                 p_redeem_units:= price_bn_Rec.x_redeem_units;
                 p_result :=0; --'succesful';
           Else
                 close class_buynow_cur;
                 close price_bn_Cur;
                 close domain_cur;
                 p_retail_price:= 0;
                 p_redeem_days:= 0;
                 p_redeem_units:= 0;
                  p_result :=-1; --'not found bn price';
           end if;
         else
    -- CR15035
    */
    --   Open price_Cur(domain_rec.domain);
    OPEN price_cur(p_source);
    FETCH price_cur
      INTO price_rec;
    IF price_cur%FOUND THEN
      CLOSE price_cur;
      --close domain_cur;
      -- close class_buynow_cur;
      p_retail_price := price_rec.x_retail_price;
      p_redeem_days  := price_rec.x_redeem_days;
      p_redeem_units := price_rec.x_redeem_units;
      p_result       := 0; --'succesful';
    ELSE
      CLOSE price_cur;
      --close domain_cur;
      -- close class_buynow_cur;
      p_retail_price := 0;
      p_redeem_days  := 0;
      p_redeem_units := 0;
      p_result       := -1; --'not foundprice';
    END IF;
    -- CR15035
    --    end if;
    --    else
    --       close domain_cur;
    --            p_retail_price:= 0;
    --            p_redeem_days:= 0;
    --            p_redeem_units:= 0;
    --             p_result :=-1; --'not domain';
    --     end if;
  EXCEPTION
    WHEN others THEN
      p_retail_price := 0;
      p_redeem_days  := 0;
      p_redeem_units := 0;
      p_result       := SQLCODE; --'fail exception';
  END;
  FUNCTION getprice
  (
    p_part_number IN VARCHAR2
   ,p_source      IN VARCHAR2
  ) RETURN NUMBER IS
    v_price  NUMBER;
    v_units  NUMBER;
    v_days   NUMBER;
    v_result NUMBER;
  BEGIN
    getprice_tot(p_part_number
                ,p_source
                ,v_price
                ,v_units
                ,v_days
                ,v_result);
    IF v_result = 0 THEN
      RETURN v_price;
    ELSE
      RETURN - 1;
    END IF;
  EXCEPTION
    WHEN others THEN
      RETURN - 1;
  END;
--CR18994 - CR22380 New function
  FUNCTION is_warranty (
    p_part_number  IN sa.table_part_num.part_number%type
  ) RETURN NUMBER IS
    CURSOR warranty_cur(l1_var1 IN VARCHAR2) IS
      SELECT COUNT(*) n_amount
        FROM table_part_num   pn
            ,table_part_class pc
            ,pc_params_view   pcv
       WHERE 1 = 1
         AND pn.part_number = l1_var1
         AND pn.part_num2part_class = pc.objid
         AND pcv.part_class = pc.name
         AND pcv.param_name = 'TAX_CALCULATION'
         AND pcv.param_value = 'HS_WARRANTY';
    warranty_cur_rec  warranty_cur%ROWTYPE;
    f_warranty  NUMBER;
  BEGIN
        --CR18994 - CR22380  check if part number is associated to warranty plan begin
        OPEN warranty_cur(p_part_number);
        FETCH warranty_cur
          INTO WARRANTY_CUR_REC;
        f_warranty := warranty_cur_rec.n_amount;
        CLOSE warranty_cur;
        --CR18994 - CR22380  check if part number is associated to warranty plan end;
    RETURN f_warranty;
  END is_warranty;
--CR18994 - CR22380 New function

--CR26033 / CR26274
  FUNCTION is_dataonly (
    p_part_number  IN sa.table_part_num.part_number%type
  ) RETURN NUMBER IS
    CURSOR dataonly_cur(l1_var1 IN VARCHAR2) IS

    --  SELECT COUNT(*) n_amount
    --    FROM table_part_num   pn
    --   WHERE 1 = 1
    --     AND pn.part_number = l1_var1
    --         AND ( pn.x_card_type = 'DATA CARD'
    --     OR pn.s_description like '%BROAD%' ) ;  -- CR26033 / CR26274 needed a way to include BILLING PROGRAMS for SM

    -- CR26033 Removed LIKE reference.  Created SM DATA CARD to find these part numbers
    SELECT COUNT(*) n_amount
      FROM table_part_num   pn
     WHERE 1 = 1
       AND pn.part_number = l1_var1
             AND ( pn.x_card_type = 'DATA CARD'
         OR pn.x_sourcesystem = 'DATA CARD'
         OR pn.x_card_type = 'SM DATA CARD' )
         --OR pn.s_description like '%BROAD%' )
         AND pn.x_card_type not in ('BUNDLE CARDS')
         AND pn.x_sourcesystem not in ('SIM CARD BUNDLE') ;  -- CR26033 / CR26274 needed a way to include BILLING PROGRAMS for SM

    dataonly_cur_rec  dataonly_cur%ROWTYPE;
    f_dataonly  NUMBER;

  BEGIN
       OPEN dataonly_cur(p_part_number);
       FETCH dataonly_cur
         INTO dataonly_CUR_REC;
         f_dataonly := dataonly_cur_rec.n_amount;
       CLOSE dataonly_cur;
      RETURN f_dataonly;
  END is_dataonly;
--CR26033 / CR26274



---------CR32572 TEXT TAX

  FUNCTION is_TXTonly (
    p_part_number  IN sa.table_part_num.part_number%type
  ) RETURN NUMBER IS
    CURSOR TXTonly_cur(l1_var1 IN VARCHAR2) IS


    SELECT COUNT(*) n_amount
      FROM table_part_num   pn
     WHERE 1 = 1
       AND pn.part_number = l1_var1
             AND  pn.x_card_type = 'TEXT ONLY'
          ;

    TXTonly_cur_rec  TXTonly_cur%ROWTYPE;
    f_TXTonly  NUMBER;

  BEGIN
       OPEN TXTonly_cur(p_part_number);
       FETCH TXTonly_cur
         INTO TXTonly_CUR_REC;
         f_TXTonly := TXTonly_cur_rec.n_amount;
       CLOSE TXTonly_cur;
      RETURN f_TXTonly;
  END is_TXTonly;
-- CR32572 END TEXT TAX


  --CR27269 -- CR27270 -- ***
  Function MODEL_TAXES
  (p_esn  IN sa.table_part_inst.part_serial_no%type)
      return varchar2
is
    f_model_type varchar2(30)  ;
  cursor GET_PART_CLASS_CUR(x_esn in varchar2 )
  is
     SELECT PC.NAME
      FROM TABLE_PART_INST PI, TABLE_MOD_LEVEL ML,
           TABLE_PART_NUM PN,TABLE_PART_CLASS PC
     WHERE PI.part_serial_no= X_ESN  -- '100000000013255982' HOME ALERT --100000000013255942' HOME PHONE
       AND pi.n_part_inst2part_mod=ML.OBJID
       AND ml.part_info2part_num=PN.OBJID
       AND PN.PART_NUM2PART_CLASS=pc.objid ;

      get_Part_class_rec get_part_class_cur%rowtype ;
     BEGIN
      OPEN get_part_class_cur(p_esn) ;
      fetch get_part_class_cur into get_part_class_rec ;

      f_model_type := '1' ;
      if get_part_class_cur%found
      then
      close get_part_class_cur ;
      f_model_type :=sa.get_param_by_name_fun(get_part_class_rec.name,'MODEL_TYPE') ;
      return f_model_type ;
      else
        close get_part_class_cur ;
        return '0' ;
      end if ;

    END ;


  FUNCTION is_airtime (
    p_part_number  IN sa.table_part_num.part_number%type,
    p_redeem_units IN sa.table_part_num.x_redeem_units%type
  ) RETURN NUMBER IS
    CURSOR airtime_cur(l1_var1 IN VARCHAR2) IS
      SELECT COUNT(*) n_amount
        FROM table_part_num   pn
            ,table_part_class pc
       WHERE 1 = 1
         AND pn.part_number = l1_var1
         AND pn.domain = 'REDEMPTION CARDS'
         AND pn.part_num2part_class = pc.objid
         AND pn.x_redeem_units > 0; -- CR17340 or (pn.x_redeem_units = 0 and  pc.name = 'NTULCARD'));-- included net10 unlimited 0 units
    --    where part_number = L1_VAR1 and domain ='REDEMPTION CARDS'  and x_redeem_units > 0 ;
    airtime_rec airtime_cur%ROWTYPE;
    --CR17340
    CURSOR airtime_unl_cur(l1_var1 IN VARCHAR2) IS
      SELECT COUNT(*) n_amount
        FROM table_part_num               pn
            ,table_part_class             pc
            ,sa.service_plan_flat_summary sf
       WHERE 1 = 1
         AND pn.part_number = l1_var1
         AND pn.domain = 'REDEMPTION CARDS'
         AND pn.part_num2part_class = pc.objid
         AND pn.x_redeem_units = 0
         AND sf.part_class_objid = pc.objid
         AND sf.fea_name = 'VOICE';
    --     and sf.Fea_Display='Unlimited'; --CR12838
    airtime_unl_rec airtime_unl_cur%ROWTYPE;
    --CR17340
    CURSOR airtime_BILLING(l1_var1 IN VARCHAR2) IS      --CR23042 Updated query to look for any part_number in the program.
        SELECT COUNT(*) N_AMOUNT
        from  X_PROGRAM_PARAMETERS PP,
              TABLE_PART_NUM PN
        where PN.OBJID in  (PP.PROG_PARAM2PRTNUM_MONFEE
                           ,PP.PROG_PARAM2PRTNUM_ENRLFEE
                           ,PP.PROG_PARAM2PRTNUM_GRPMONFEE
                           ,PP.PROG_PARAM2PRTNUM_GRPENRLFEE)
        AND   PN.PART_NUMBER = l1_var1;
    airtime_BILLING_REC airtime_BILLING%ROWTYPE;
    f_airtime  number;
  BEGIN
      f_airtime := 0;
      --CR17340
      IF p_redeem_units > 0 THEN
        dbms_output.put_line('Get part number airtime count');
        OPEN airtime_cur(p_part_number);
        FETCH airtime_cur
          INTO airtime_rec;
        f_airtime := airtime_rec.n_amount;
        CLOSE airtime_cur;
        dbms_output.put_line('Part number airtime count: ' || TO_CHAR(f_airtime));
      ELSE
        --check if part number is associated to unlimited plan (included net10 unlimited 0 unit)
        dbms_output.put_line('Get part number unlimited airtime count');
        OPEN airtime_unl_cur(p_part_number);
        FETCH airtime_unl_cur
          INTO airtime_unl_rec;
        f_airtime := airtime_unl_rec.n_amount;
        CLOSE airtime_unl_cur;
        dbms_output.put_line('Part number unlimited airtime count: ' || TO_CHAR(f_airtime));
      END IF;
     --CR17340
      IF f_airtime = 0
      THEN
        OPEN airtime_BILLING(p_part_number);
        FETCH Airtime_BILLING
          INTO airtime_BILLING_rec;
        f_airtime := airtime_BILLING_rec.n_amount;
        CLOSE airtime_BILLING;
      END IF;
      return f_airtime;
  END is_airtime;
  /* CR15373 WMMC pm Start new input parameter for CC id and Brand Name */

---  CR41745
FUNCTION is_salestax_only (p_part_number  IN sa.table_part_num.part_number%type)
RETURN NUMBER
IS
    CURSOR salestax_only_cur(l1_var1 IN VARCHAR2) IS
    SELECT COUNT(*) n_amount
    FROM table_part_num   pn
    WHERE 1 = 1
    AND pn.part_number = l1_var1
    --AND pn.x_card_type     = 'SERVICE_DAYS_ONLY'
    AND pn.part_number       = 'TFAPP40365'
    ;


    salestax_only_cur_rec  salestax_only_cur%ROWTYPE;
    f_salestaxsonly  NUMBER;

BEGIN
    OPEN salestax_only_cur(p_part_number);

    FETCH salestax_only_cur
    INTO salestax_only_cur_rec;

    f_salestaxsonly := salestax_only_cur_rec.n_amount;

    CLOSE salestax_only_cur;

    RETURN f_salestaxsonly;

END is_salestax_only;

PROCEDURE getcartmetadata
  (
    p_partnumbers     IN VARCHAR2
   ,p_promos          IN VARCHAR2
   ,v_esn             IN VARCHAR2
   ,p_cc_id           IN NUMBER
   ,p_source          IN VARCHAR2
   ,p_type            IN VARCHAR2
   ,p_brand_name      IN VARCHAR2
   ,p_itemprice       in varchar2  --cwl 10/9/12 CR19041
   ,p_totb_pn         OUT NUMBER
   ,p_tota_pn         OUT NUMBER
   ,p_totb_air        OUT NUMBER
   ,p_tota_air        OUT NUMBER
   ,p_totb_wty        OUT NUMBER   --CR18994 -- CR22380
   ,p_totb_dta        OUT NUMBER   --CR26033 -- CR26274
   ,p_totb_txt        OUT NUMBER   --CR32572
   ,p_tot_MODEL_TYPE  OUT NUMBER   -- CR27269 -- CR27270 (alert car)
   ,p_model_type      OUT VARCHAR2 -- CR27269 -- CR27270 (alert car)
   ,p_tot_disc        OUT NUMBER
   ,op_count          OUT NUMBER
   ,op_result         OUT NUMBER
   ,op_msg            OUT VARCHAR2
  ) IS

    OP_SALESTAXONLY_B_AMT         NUMBER;
    OP_SALESTAXONLY_A_AMT         NUMBER;
    OP_ACTIVATION_CHRG_B_AMT     NUMBER;
    OP_ACTIVATION_CHRG_A_AMT     NUMBER;
    op_err_string VARCHAR2(1000);
        p_ar_promo_flag              VARCHAR2(20) := 'N';
        p_partner_name               table_affiliated_partners.partner_name%TYPE := NULL;

  BEGIN

    sa.SP_METADATA.GETCARTMETADATA(
    P_PARTNUMBERS => P_PARTNUMBERS,
    P_PROMOS => P_PROMOS,
    V_ESN => V_ESN,
    P_CC_ID => P_CC_ID,
    P_SOURCE => P_SOURCE,
    P_TYPE => P_TYPE,
    P_BRAND_NAME => P_BRAND_NAME,
    P_ITEMPRICE => P_ITEMPRICE,
    P_TOTB_PN => P_TOTB_PN,
    P_TOTA_PN => P_TOTA_PN,
    P_TOTB_AIR => P_TOTB_AIR,
    P_TOTA_AIR => P_TOTA_AIR,
    P_TOTB_WTY => P_TOTB_WTY,
    P_TOTB_DTA => P_TOTB_DTA,
    P_TOTB_TXT => P_TOTB_TXT,
    P_TOT_MODEL_TYPE => P_TOT_MODEL_TYPE,
    P_MODEL_TYPE => P_MODEL_TYPE,
    P_TOT_DISC => P_TOT_DISC,
    OP_COUNT => OP_COUNT,
    OP_RESULT => OP_RESULT,
    OP_MSG => OP_MSG,
    OP_SALESTAXONLY_B_AMT => OP_SALESTAXONLY_B_AMT,
    OP_SALESTAXONLY_A_AMT => OP_SALESTAXONLY_A_AMT,
    OP_ACTIVATION_CHRG_B_AMT => OP_ACTIVATION_CHRG_B_AMT,
    OP_ACTIVATION_CHRG_A_AMT => OP_ACTIVATION_CHRG_A_AMT,
        P_AR_PROMO_FLAG => P_AR_PROMO_FLAG,
        P_PARTNER_NAME => P_PARTNER_NAME
    );



    op_err_string := 'Using old signature of SA.SP_METADATA.GETCARTMETADATA ESN '||V_ESN ||' SOURCE '||p_source||' partnumbers '||TRIM(SUBSTR(p_partnumbers,1,100));

    ota_util_pkg.err_log(p_action => 'SP_METADATA.getcardmetadata_wrapper', p_error_date => SYSDATE, p_key => V_ESN, p_program_name =>
    'SP_METADATA.getcardmetadata_wrapper', p_error_text => op_err_string);

  EXCEPTION WHEN OTHERS
  THEN
      dbms_output.put_line('Executing sp_metadata.getcartmetadata old completed with others exception');
      op_result := SQLCODE;
      op_msg    := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK
                ,1
                ,100)||' '||SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ,1
                ,40)||' '||SUBSTR(p_partnumbers,1,40)||' '||' esn '||v_esn||' '||p_source;

      dbms_output.put_line('op_result: ' || TO_CHAR(SQLCODE));
      dbms_output.put_line('op_msg: ' || op_msg);
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata_wrapper'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata_wrapper'
        ,2 -- MEDIUM
         );
  END getcartmetadata;



---  CR41745


  PROCEDURE getcartmetadata
  (
    p_partnumbers     IN VARCHAR2
   ,p_promos          IN VARCHAR2
   ,v_esn             IN VARCHAR2
   ,p_cc_id           IN NUMBER
   ,p_source          IN VARCHAR2
   ,p_type            IN VARCHAR2
   ,p_brand_name      IN VARCHAR2
   ,p_itemprice       in varchar2  --cwl 10/9/12 CR19041
   ,p_totb_pn         OUT NUMBER
   ,p_tota_pn         OUT NUMBER
   ,p_totb_air        OUT NUMBER
   ,p_tota_air        OUT NUMBER
   ,p_totb_wty        OUT NUMBER   --CR18994 -- CR22380
   ,p_totb_dta        OUT NUMBER   --CR26033 -- CR26274
   ,p_totb_txt        OUT NUMBER   --CR32572
   ,p_tot_MODEL_TYPE  OUT NUMBER   -- CR27269 -- CR27270 (alert car)
   ,p_model_type      OUT VARCHAR2 -- CR27269 -- CR27270 (alert car)
   ,p_tot_disc        OUT NUMBER
   ,op_count          OUT NUMBER
   ,op_result         OUT NUMBER
   ,op_msg            OUT VARCHAR2
   ,op_salestaxonly_b_amt        OUT NUMBER        --- CR41745
   ,op_salestaxonly_a_amt        OUT NUMBER        --- CR41745
   ,op_activation_chrg_b_amt        OUT NUMBER        --- CR41745
   ,op_activation_chrg_a_amt        OUT NUMBER        --- CR41745
   ,p_ar_promo_flag         IN VARCHAR2   DEFAULT 'N'           --- CR48480 'Y' 'N'
   ,p_partner_name          IN VARCHAR2   DEFAULT NULL          --- CR48480 Partner name ex: AMAZON WEB ORDERS, Best Buy, Ebay
  ) IS
    /* CR15373 WMMC pm End */
    /* Assumptions: P_partnumbers are a group of part number valid or pin number cards valid. all input parameters are valid.
    */
    l_bus_org           VARCHAR2(40);
    validate_promo_exc EXCEPTION;
    part_number_exc    EXCEPTION;
    cc2zip2tax_exc     EXCEPTION;
    i                    NUMBER;
    k                    NUMBER;
    p_count              NUMBER;
    l_var1               table_part_num.part_number%TYPE;
    l_string             VARCHAR2(1000);
    p_esn                VARCHAR2(200);
    p_red_code02         VARCHAR2(200);
    p_red_code03         VARCHAR2(200);
    p_red_code04         VARCHAR2(200);
    p_red_code05         VARCHAR2(200);
    p_red_code06         VARCHAR2(200);
    p_red_code07         VARCHAR2(200);
    p_red_code08         VARCHAR2(200);
    p_red_code09         VARCHAR2(200);
    p_red_code10         VARCHAR2(200);
    p_technology         VARCHAR2(200);
    p_transaction_amount NUMBER;
    p_source_system      VARCHAR2(200);
    p_promo_code         VARCHAR2(200);
    p_transaction_type   VARCHAR2(200);
    p_zipcode            VARCHAR2(200);
    p_language           VARCHAR2(200);
    p_fail_flag          NUMBER;
    p_discount_amount    VARCHAR2(200);
    p_promo_units        NUMBER;
    p_access_days        NUMBER;
    p_status             VARCHAR2(200);
    p_msg                 VARCHAR2(200);
    p_dont_tax_first_25   NUMBER ; -- CR26033

    --CR42361: MGovindarajan: 8/24/2016 - start
    p_sms                         NUMBER;
    p_data_mb                     NUMBER;
    p_applicable_device_type    VARCHAR2(60);
    --CR42361: MGovindarajan : 8/24/2016 - end

    p_dont_tax_MODEL_TYPE NUMBER;  -- CR27269 -- CR27270 (alert car)
    p_sales_tax_only      NUMBER;
    lv_e911_count            NUMBER := 0; --CR37485

    TYPE name_record IS RECORD(
       pn        table_part_num.part_number%TYPE
      ,price     table_x_pricing.x_retail_price%TYPE
      ,disc      table_x_pricing.x_retail_price%TYPE
      ,promo     table_x_promotion.x_promo_code%TYPE
      ,f_airtime    NUMBER
      ,f_warranty   NUMBER   --CR18994 - CR22380
      ,f_dataonly   NUMBER   --CR26033 / CR26274
      ,f_txtonly   NUMBER   --CR32572
      ,f_model_type varchar2(30)  --NUMBER    -- CR27269 -- CR27270 (alert car)
      ,f_tot_model_type Number
      ,f_salestaxonly    NUMBER        --- CR41745
      ,f_nac_activation_charge    NUMBER        --- CR41745
        );
    TYPE dim1 IS TABLE OF name_record INDEX BY BINARY_INTEGER;
    t_dim1 dim1;



    CURSOR amount_cur(l1_var1 IN VARCHAR2) IS
      SELECT x_redeem_units
        FROM table_part_num
       WHERE part_number = l1_var1;
    amount_rec amount_cur%ROWTYPE;


--BEGIN code was moved to function is_airtime   CR18994 CR22340 BEGIN
--    CURSOR airtime_cur(l1_var1 IN VARCHAR2) IS
--      SELECT COUNT(*) n_amount
--        FROM table_part_num   pn
--            ,table_part_class pc
--       WHERE 1 = 1
--         AND pn.part_number = l1_var1
--         AND pn.domain = 'REDEMPTION CARDS'
--         AND pn.part_num2part_class = pc.objid
--         AND pn.x_redeem_units > 0; -- CR17340 or (pn.x_redeem_units = 0 and  pc.name = 'NTULCARD'));-- included net10 unlimited 0 units
--    --    where part_number = L1_VAR1 and domain ='REDEMPTION CARDS'  and x_redeem_units > 0 ;
--
--    airtime_rec airtime_cur%ROWTYPE;
--
--    --CR17340
--    CURSOR airtime_unl_cur(l1_var1 IN VARCHAR2) IS
--      SELECT COUNT(*) n_amount
--        FROM table_part_num               pn
--            ,table_part_class             pc
--            ,sa.service_plan_flat_summary sf
--       WHERE 1 = 1
--         AND pn.part_number = l1_var1
--         AND pn.domain = 'REDEMPTION CARDS'
--         AND pn.part_num2part_class = pc.objid
--         AND pn.x_redeem_units = 0
--         AND sf.part_class_objid = pc.objid
--         AND sf.fea_name = 'VOICE';
--    --     and sf.Fea_Display='Unlimited'; --CR12838
--
--    airtime_unl_rec airtime_unl_cur%ROWTYPE;
--    --CR17340
--END code was moved to function is_airtime   CR18994 CR22340 END

    CURSOR tech_cur(l1_var1 IN VARCHAR2) IS
      SELECT pn.x_technology tech
        FROM table_part_num pn
       WHERE pn.part_number = l1_var1;
    tech_rec tech_cur%ROWTYPE;
    -- CR15373 WMMC pm Start.
    -- CR19467 ST Promo pm Start.
    CURSOR cur_promo_dtl
    (
      c_promo_code VARCHAR2
     ,c_promo_type VARCHAR2
    ) IS
      SELECT *
        FROM table_x_promotion
       WHERE x_promo_code = c_promo_code
         AND x_promo_type = c_promo_type;
    rec_promo_dtl cur_promo_dtl%ROWTYPE;

    l_promo_objid   table_x_promotion.objid%TYPE;
    l_promo_code    table_x_promotion.x_promo_code%TYPE;
    l_enroll_type   table_x_promotion.x_transaction_type%TYPE;
    l_enroll_amount table_x_promotion.x_discount_amount%TYPE;
    l_enroll_units  table_x_promotion.x_units%TYPE;
    l_enroll_days   table_x_promotion.x_access_days%TYPE;
    l_error_code    NUMBER;
    l_error_message VARCHAR2(400);
    -- CR19467 ST Promo pm Start.
    -- CR15373 WMMC pm End.
    l_itemprice_count binary_integer :=0;
  --CR22460 Start kacosta 10/31/2012
    l_n_program_parameters_objid x_program_parameters.objid%TYPE;
    l_v_script_id                x_enroll_promo_rule.x_script_id%TYPE;
    --CR22460 End kacosta 10/31/2012
    l_itemprice_array dbms_utility.lname_array;

    l_ild_exists NUMBER;


    --CR44459
    lv_purch_promo_code        TABLE_X_PROMOTION.X_PROMO_CODE%TYPE;
    lv_purch_promo_objid        TABLE_X_PROMOTION.X_PROMO_CODE%TYPE;
    lv_purch_discount_amt        NUMBER;
    lv_purch_promo_err_code        VARCHAR2(5);
    lv_purch_promo_err_msg        VARCHAR2(500);
    --CR44459
    l_result    number;  --CR49229
  BEGIN
    dbms_output.put_line('Executing sp_metadata.getcartmetadata');
    dbms_output.put_line('p_partnumbers: ' || p_partnumbers);
    dbms_output.put_line('p_promos     : ' || p_promos);
    dbms_output.put_line('v_esn        : ' || v_esn);
    dbms_output.put_line('p_cc_id      : ' || TO_CHAR(p_cc_id));
    dbms_output.put_line('p_source     : ' || p_source);
    dbms_output.put_line('p_type       : ' || p_type);
    dbms_output.put_line('p_brand_name : ' || p_brand_name);
    dbms_output.put_line('p_itemprice  : ' || to_char(p_itemprice));  -- cr26033 see more parameters

--cwl 10/9/12   CR19041
    if p_itemprice is not null then
      dbms_utility.comma_to_table
        ( list   => regexp_replace(replace(p_itemprice,'.','y'),'(^|,)','\1x')
        , tablen => l_itemprice_count
        , tab    => l_itemprice_array);
    end if;
--cwl 10/9/12   CR19041
    i         := 1;
    k         := 1;
    op_result := 0;
    op_msg    := '';
    l_string  := p_partnumbers;
    p_count   := 0;
    LOOP
      --
      --CR22460 Start kacosta 10/31/2012
      l_n_program_parameters_objid := NULL;
      l_promo_objid                := NULL;
      l_promo_code                 := NULL;
      --CR22460 End kacosta 10/31/2012
      --
      l_string    := trim(trim (BOTH ',' from l_string));    -- added during CR41745 to fix one of possibility of numeric or value error.

       EXIT WHEN l_string IS NULL;            -- added during CR41745 to fix one of possibility of numeric or value error.

      dbms_output.put_line('Determine part number to process ');
      l_var1   := NVL(SUBSTR(l_string
                            ,1
                            ,INSTR(l_string
                                  ,','
                                  ,1) - 1)
                     ,l_string);
      l_string := TRIM(SUBSTR(l_string
                             ,LENGTH(l_var1) + 2
                             ,LENGTH(l_string)));
      dbms_output.put_line('Processing part number: ' || l_var1);
      dbms_output.put_line('Get part number price');
      t_dim1(i).pn := l_var1;

      ---CR37485 SET PRICE TO ZERO IF IT IS SAFELINK E911

      select count(1)
      into lv_e911_count
      from mtm_program_safelink mtm
      where 1=1
      --and mtm.program_param_objid = (select x.pgm_enroll2pgm_parameter
      and mtm.program_param_objid IN (select DISTINCT x.pgm_enroll2pgm_parameter    -- Modified for CR39674
                                    from x_program_enrolled x,
                                    x_sl_currentvals val,
                                    x_sl_subs sub,
                                    x_program_parameters p
                                    where 1=1
                                    and x.x_esn = v_esn
                                    and val.x_current_esn = x.x_esn
                                    and sub.lid = val.lid
                                    and p.objid = x.pgm_enroll2pgm_parameter
                                    and p.x_prog_class = 'LIFELINE'
                                    and x.x_enrollment_status = 'ENROLLED'
                                    )
      and mtm.part_num_objid = (select objid
                      from table_part_num
                      where part_number = l_var1
                      and domain = 'REDEMPTION CARDS'
                      )
      and sysdate between mtm.start_date  and mtm.end_date
      and mtm.program_provision_flag = '3' ;

      IF lv_e911_count <> 0
      THEN
            t_dim1(i).price := '0';
      ELSE

            t_dim1(i).price := getprice(l_var1,p_source);

      END IF;

      --CR37485

--cwl 10/9/12 CR19041
    if p_itemprice is not null and i <=l_itemprice_count  then
      if substr(l_itemprice_array(i),2) is not null then
        dbms_output.put_line('overwrite with itemprice array:'||to_number(substr(replace(l_itemprice_array(i),'y','.'),2)));
        t_dim1(i).price := to_number(substr(replace(l_itemprice_array(i),'y','.'),2));
      end if;
    end if;
--cwl 10/9/12 CR19041
      dbms_output.put_line('Part number price: ' || TO_CHAR(t_dim1(i).price));
      p_count              := p_count + 1;
      p_esn                := v_esn;
      p_red_code02         := NULL;
      p_red_code03         := NULL;
      p_red_code04         := NULL;
      p_red_code05         := NULL;
      p_red_code06         := NULL;
      p_red_code07         := NULL;
      p_red_code08         := NULL;
      p_red_code09         := NULL;
      p_red_code10         := NULL;
      p_zipcode            := NULL;
      p_technology         := NULL;
      p_transaction_amount := NULL;
      p_source_system      := p_source;
      dbms_output.put_line('Get part number redeem units');
      OPEN amount_cur(l_var1);
      FETCH amount_cur
        INTO amount_rec;
      IF amount_cur%NOTFOUND THEN
        CLOSE amount_cur;
        op_msg := 'part_number not found: ' || l_var1;
        RAISE part_number_exc;
      END IF;
      dbms_output.put_line('Part number redeem units : ' || TO_CHAR(amount_rec.x_redeem_units));
      p_transaction_amount := amount_rec.x_redeem_units;
      CLOSE amount_cur;

--BEGIN code was moved to function is_airtime   CR18994 CR22340 BEGIN
--      --CR17340
--      IF p_transaction_amount > 0 THEN
--
--        dbms_output.put_line('Get part number airtime count');
--
--        OPEN airtime_cur(l_var1);
--        FETCH airtime_cur
--          INTO airtime_rec;
--        t_dim1(i).f_airtime := airtime_rec.n_amount;
--        CLOSE airtime_cur;
--
--        dbms_output.put_line('Part number airtime count: ' || TO_CHAR(t_dim1(i).f_airtime));
--
--      ELSE
--        --check if part number is associated to unlimited plan (included net10 unlimited 0 unit)
--
--        dbms_output.put_line('Get part number unlimited airtime count');
--
--        OPEN airtime_unl_cur(l_var1);
--        FETCH airtime_unl_cur
--          INTO airtime_unl_rec;
--        t_dim1(i).f_airtime := airtime_unl_rec.n_amount;
--        CLOSE airtime_unl_cur;
--
--        dbms_output.put_line('Part number unlimited airtime count: ' || TO_CHAR(t_dim1(i).f_airtime));
--
--      END IF;
--      --CR17340
--END code was moved to function is_airtime   CR18994 CR22340 END
--CR18994 - CR22380  check if part number is associated to warranty plan    begin

    t_dim1(i).f_warranty   := is_warranty(l_var1);
    t_dim1(i).f_dataonly   := is_dataonly(l_var1);       --CR26033 / CR26274
    t_dim1(i).f_txtonly   := is_txtonly(l_var1);
    t_dim1(i).f_model_type := model_taxes(p_esn);     -- CR27269 -- CR27270 (alert car)
     -- CR26033 GET THE FLAG FROM THE TAX TABLE BASED ON THE APP ZIP SPECIFIC TO X_DATAONLY_TAX

--X_HOME_ALERT_NON_SALES  NOT NULL NUMBER
--X_DATA_NON_SALES        NOT NULL NUMBER
--X_NON_SHIPPING          NOT NULL NUMBER
--X_CAR_CONNECT_NON_SALES NOT NULL NUMBER

    P_DONT_TAX_MODEL_TYPE:=0;
    p_sales_tax_only := 0 ;


    if t_dim1(i).f_warranty = 0 -- not a warranty, regular taxes
    then
       t_dim1(i).f_airtime := is_airtime(l_var1,p_transaction_amount);
    else
         t_dim1(i).f_airtime := 0;  -- this is warranty
    end if;

    if t_dim1(i).f_model_type IN ('HOME ALERT', 'CAR CONNECT')
    then
        t_dim1(i).f_airtime := is_airtime(l_var1,p_transaction_amount);
    else
          t_dim1(i).f_airtime := 0;  -- this is warranty
    end if;
    if t_dim1(i).f_dataonly > 0 -- yes it is a data only card lets see the zip
    then
        t_dim1(i).f_airtime := is_airtime(l_var1,p_transaction_amount);
    else
          t_dim1(i).f_airtime := 0;  -- this is warranty
    end if ;
    IF t_dim1 (i).f_warranty = 0 AND t_dim1 (i).f_dataonly = 0  AND t_dim1 (i).f_txtonly = 0  --CR32572
    --IF t_dim1 (i).f_warranty = 0 AND t_dim1 (i).f_dataonly = 0 --CR26033 / CR26274

    -- if t_dim1(i).f_model_type = 'HOME ALERT'   -- Ingrid
    then
           t_dim1(i).f_airtime := is_airtime(l_var1,p_transaction_amount);
    else
             t_dim1(i).f_airtime := 0;  -- this is warranty
    end if;

     -- CR41745
    IF t_dim1 (i).f_warranty = 0 AND t_dim1(i).f_airtime = 0 AND t_dim1 (i).f_dataonly = 0  AND t_dim1 (i).f_txtonly = 0
    then
           --t_dim1(i).f_salestaxonly := is_salestax_only(l_var1);

    BEGIN


        SELECT COUNT(pn.objid)
        INTO t_dim1(i).f_salestaxonly
        FROM table_part_num pn,table_x_parameters pm
        WHERE pn.domain = 'REDEMPTION CARDS'
        AND pn.part_number = trim(l_var1)
        AND pm.X_PARAM_NAME LIKE 'SALESTAX_ONLY_PART_NUMBERS%'
        AND INSTR(X_PARAM_VALUE,pn.part_number) > 0
        ;

    EXCEPTION WHEN OTHERS
    THEN

        t_dim1(i).f_salestaxonly    := 0;

    END;


    else
           t_dim1(i).f_salestaxonly := 0;
    end if;

    IF t_dim1 (i).f_warranty = 0 AND t_dim1(i).f_airtime = 0 AND t_dim1 (i).f_dataonly = 0  AND t_dim1 (i).f_txtonly = 0
    AND t_dim1(i).f_salestaxonly = 0
    THEN

        BEGIN


        SELECT COUNT(pn.objid)
        INTO t_dim1(i).f_nac_activation_charge
        FROM table_part_num pn,table_x_parameters pm
        WHERE pn.domain = 'REDEMPTION CARDS'
        AND pn.part_number = trim(l_var1)
        AND pm.X_PARAM_NAME = 'ACTIVATION_CHARGE_SOURCESYSTEMS'
        AND INSTR(X_PARAM_VALUE,pn.X_SOURCESYSTEM) > 0
        ;

    EXCEPTION WHEN OTHERS
    THEN

        t_dim1(i).f_nac_activation_charge    := 0;

    END;

    ELSE

           t_dim1(i).f_nac_activation_charge    := 0;

    END IF;

     -- CR41745

      --CR18994 - CR22380  end
      dbms_output.put_line('Get part number technology');
      OPEN tech_cur(l_var1);
      FETCH tech_cur
        INTO tech_rec;
      dbms_output.put_line('Part number technology: ' || tech_rec.tech);
      p_technology := tech_rec.tech;
      CLOSE tech_cur;
      p_transaction_type := p_type;
      p_language         := 'ENGLISH';
      p_fail_flag        := NULL;
      p_promo_code       := p_promos;
      --
      --CR22460 Start kacosta 10/31/2012
      dbms_output.put_line('Check if the price is greater than zero to check for promotions');
      --
      -- Only retreive promo if the price is more than zero
      --
      IF (NVL(t_dim1(k).price
             ,0) > 0) THEN
        --
        dbms_output.put_line('Get part number billing program related promotion');
        --
        -- Assuming billing program related promotion takes precedence over all other promotions
        BEGIN
          --
          BEGIN
            --
            dbms_output.put_line('Get part number billing program based on enrollment part number');
            --
            SELECT xpp.objid
              INTO l_n_program_parameters_objid
              FROM table_part_num tpn
              JOIN x_program_parameters xpp
                ON tpn.objid = xpp.prog_param2prtnum_enrlfee
             WHERE tpn.part_number = l_var1;
            --
          EXCEPTION
            WHEN no_data_found THEN
              --
              dbms_output.put_line('Part number billing program based on enrollment part number not found');
              --
              l_n_program_parameters_objid := NULL;
              --
            WHEN others THEN
              --
              op_result := SQLCODE;
              op_msg    := SQLCODE || SUBSTR(SQLERRM
                                            ,1
                                            ,100);
              --
              INSERT INTO x_program_error_log
                (x_source
                ,x_error_code
                ,x_error_msg
                ,x_date
                ,x_description
                ,x_severity)
              VALUES
                ('SP_METADATA.getcardmetadata'
                ,op_result
                ,op_msg
                ,SYSDATE
                ,'Retreiving program for billing program enrollment part number: ' || l_var1
                ,2);
              --
              RAISE;
              --
          END;
          --
          IF (l_n_program_parameters_objid IS NULL) THEN
            --
            dbms_output.put_line('Get part number billing program based on recurring part number');
            --
            SELECT xpp.objid
              INTO l_n_program_parameters_objid
              FROM table_part_num tpn
              JOIN x_program_parameters xpp
                ON tpn.objid = xpp.prog_param2prtnum_monfee
             WHERE tpn.part_number = l_var1;
            --
          END IF;
          --
          dbms_output.put_line('Part number billing program: ' || TO_CHAR(l_n_program_parameters_objid));
          --
        EXCEPTION
          WHEN no_data_found THEN
            --
            dbms_output.put_line('Part number billing program based on recurring part number not found');
            --
            l_n_program_parameters_objid := NULL;
            --
          WHEN others THEN
            --
            op_result := SQLCODE;
            op_msg    := SQLCODE || SUBSTR(SQLERRM
                                          ,1
                                          ,100);
            --
            INSERT INTO x_program_error_log
              (x_source
              ,x_error_code
              ,x_error_msg
              ,x_date
              ,x_description
              ,x_severity)
            VALUES
              ('SP_METADATA.getcardmetadata'
              ,op_result
              ,op_msg
              ,SYSDATE
              ,'Retreiving program for billing program recurring part number: ' || l_var1
              ,2);
            --
            RAISE;
            --
        END;
        --
        dbms_output.put_line('Check if part number billing program was found');

        -- CR48480_Amazon_SM_Discounted_Plans
        -- Check to see if this is a 1 time promo.  APP partumber.
        --
        IF (l_n_program_parameters_objid IS NULL
           AND
           p_partner_name IS NOT NULL) THEN

           BEGIN
            --
            dbms_output.put_line('Get part number billing program based on APP part number');
            --

               SELECT mtm.x_sp2program_param
                 INTO l_n_program_parameters_objid
                 FROM x_serviceplanfeaturevalue_def spfvdef,
                      x_serviceplanfeature_value spfv,
                      x_service_plan_feature spf,
                      x_serviceplanfeaturevalue_def spfvdef2,
                      x_service_plan sp,
                      mtm_sp_x_program_param mtm
                WHERE spf.sp_feature2service_plan = sp.objid
                  AND spf.sp_feature2rest_value_def = spfvdef.objid
                  AND spf.objid = spfv.spf_value2spf
                  AND spfvdef2.objid = spfv.value_ref
                  AND mtm.program_para2x_sp = sp.objid
                  AND spfvdef.value_name  = 'PLAN_PURCHASE_PART_NUMBER'
                  AND spfvdef2.value_name = l_var1
                  AND mtm.x_recurring = (CASE WHEN p_ar_promo_flag = 'Y'
                                              THEN 1
                                              WHEN p_ar_promo_flag = 'N'
                                              THEN 0
                                              ELSE NULL
                                               END)
                  AND ROWNUM < 2;


            EXCEPTION WHEN OTHERS THEN

               --
               l_n_program_parameters_objid := NULL;
               --

            END;

        END IF;

      -- get brand
      l_bus_org := sa.customer_info.get_bus_org_id ( i_esn => v_esn );

      IF l_bus_org IS NULL
      THEN
        BEGIN
          SELECT s_org_id
            INTO l_bus_org
          FROM table_part_num pn,
               table_bus_org bo
          WHERE bo.objid = part_num2bus_org
            AND pn.part_number = l_var1;
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
      END IF;

        ------  CR53217 Retrieving promo objid and sript id  when PROMO CODE is not passed.
      IF(p_promo_code IS NULL OR l_bus_org <> 'NET10') THEN

        IF (l_n_program_parameters_objid IS NOT NULL) THEN

           IF p_partner_name IS NULL THEN
              --
              dbms_output.put_line('Yes, part number billing program was found; call enroll_promo_pkg.sp_get_eligible_promo_esn3');
              --
              sa.enroll_promo_pkg.sp_get_eligible_promo_esn3(p_esn           => p_esn
                                                            ,p_program_objid => l_n_program_parameters_objid
                                                            ,p_promo_objid   => l_promo_objid
                                                            ,p_promo_code    => l_promo_code
                                                            ,p_script_id     => l_v_script_id
                                                            ,p_error_code    => l_error_code
                                                            ,p_error_msg     => l_error_message);
              --
              dbms_output.put_line('Check if ESN is eligible for program promotion');

           ELSE

             -- p_partner_name is populated.
             dbms_output.put_line('Check if authenticated ESN is eligible for program promotion');

                promotion_pkg.get_authenticated_promos (
                                                         i_esn           => p_esn,
                                                         i_program_objid => l_n_program_parameters_objid,
                                                         i_partner_name  => p_partner_name,
                                                         i_ar_promo_flag => p_ar_promo_flag,
                                                         o_promo_objid   => l_promo_objid,
                                                         o_promo_code    => l_promo_code,
                                                         o_script_id     => l_v_script_id,
                                                         o_error_code    => l_error_code,
                                                         o_error_msg     => l_error_message,
                                                         i_ignore_attached_promo => 'N'
                                                        );

          END IF;
          END IF;

      END IF;

     ---  CR53217 Retrieving promo objid and sript id  using PROMO CODE(input paramter).

      IF (p_promo_code IS  NOT NULL AND (l_bus_org = 'NET10' )) THEN
        BEGIN
          SELECT pr.promo_objid,
                 p.x_promo_code ,
                 pr.x_script_id
            INTO l_promo_objid,
                 l_promo_code,
                 l_v_script_id
          FROM table_x_promotion p,
               x_enroll_promo_rule pr
          WHERE 1           = 1
          AND p.objid       = pr.promo_objid
          AND p.x_promo_code= p_promo_code;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          -- Handle Exception for Non-Recurring Promo
          BEGIN
            SELECT pr.promo_objid,
                  p.x_promo_code ,
                  pr.x_script_id
              INTO l_promo_objid,
                  l_promo_code,
                  l_v_script_id
            FROM table_x_promotion p ,
                x_enroll_promo_rule pr
            WHERE 1             = 1
            AND p.objid         = pr.promo_objid
            AND pr.promo_objid =
            (SELECT promo_objid
             FROM x_enroll_promo_extra ext,
                  table_x_promotion tp
             WHERE ext.extra_promo_objid = tp.objid
             AND tp.x_promo_code         = p_promo_code
             and   ext.program_objid     = l_n_program_parameters_objid
            );
          EXCEPTION
          WHEN OTHERS THEN
            NULL;
          END;

          WHEN OTHERS THEN
            op_result := SQLCODE;
            op_msg    := SQLCODE|| ' '||'Error Retrieving promo objid and sript id  using promo code';

            INSERT INTO x_program_error_log
              (x_source
              ,x_error_code
              ,x_error_msg
              ,x_date
              ,x_description
              ,x_severity)
            VALUES
              ('SP_METADATA.getcardmetadata'
              ,op_result
              ,op_msg
              ,SYSDATE
              ,'Error Retrieving promo objid and sript id  using promo code'
              ,2);
            RETURN;
        END ;

      END IF;
          --
          IF (l_promo_objid IS NOT NULL) THEN
            --
            dbms_output.put_line('Yes, ESN is eligible for program promotion');
            dbms_output.put_line('Eligible promo objid: ' || TO_CHAR(l_promo_objid));
            --
            BEGIN
              --
              dbms_output.put_line('Get eligible promotion discount amount and promo code');
              --
              SELECT discount_amount
                    ,promo_code
                INTO l_enroll_amount
                    ,l_promo_code
                FROM (SELECT txp.x_discount_amount discount_amount
                            ,txp.x_promo_code      promo_code
                        FROM x_enroll_promo_extra epe
                        JOIN table_x_promotion txp
                          ON epe.extra_promo_objid = txp.objid
                       WHERE epe.program_objid = l_n_program_parameters_objid
                         AND epe.promo_objid = l_promo_objid
                         AND SYSDATE BETWEEN txp.x_start_date AND txp.x_end_date
                       ORDER BY txp.x_start_date)
               WHERE ROWNUM <= 1;

 -- START CR49229

        sa.enroll_promo_pkg.get_discount_amount(v_esn,
                                             l_promo_objid,
                                             t_dim1(k).price,
                                             l_enroll_amount,
                                             l_result);

-- END CR49229

              --
              dbms_output.put_line('Eligible promo discount amount: ' || TO_CHAR(l_enroll_amount));
              dbms_output.put_line('Eligible promo code: ' || l_promo_code);
              --
              t_dim1(i).disc := l_enroll_amount;
              t_dim1(i).promo := l_promo_code;
              --
            EXCEPTION
              WHEN no_data_found THEN
                --
                dbms_output.put_line('Eligible promotion discount amount and promo code not found');
                --
                l_promo_code := NULL;
                --
              WHEN others THEN
                --
                op_result := SQLCODE;
                op_msg    := SQLCODE || SUBSTR(SQLERRM
                                              ,1
                                              ,100);
                --
                INSERT INTO x_program_error_log
                  (x_source
                  ,x_error_code
                  ,x_error_msg
                  ,x_date
                  ,x_description
                  ,x_severity)
                VALUES
                  ('SP_METADATA.getcardmetadata'
                  ,op_result
                  ,op_msg
                  ,SYSDATE
                  ,'Retreiving program for promo discount for: ' || l_promo_code
                  ,2);
                --
                RAISE;
                --
            END;
            --
          END IF;
          --
         --
        IF (l_promo_code IS NULL) THEN
          --
          dbms_output.put_line('Checking for Money Card promotion');
          --CR22460 End kacosta 10/31/2012
          --
          -- CR15373 WMMC pm Start.
          OPEN cur_promo_dtl(p_promo_code
                            ,'Moneycard'); --CR19467
          FETCH cur_promo_dtl
            INTO rec_promo_dtl;
          CLOSE cur_promo_dtl;
          l_promo_objid := NULL;
          l_error_code  := NULL;
          IF p_cc_id IS NOT NULL
             AND p_brand_name in ('STRAIGHT_TALK','SIMPLE_MOBILE') --CR31853
             AND rec_promo_dtl.x_promo_code IS NOT NULL THEN
            money_card_pkg.validate_money_card_promo(p_esn
                                                    ,p_cc_id
                                                    ,'Enrollment'
                                                    ,p_promo_code
                                                    ,l_promo_objid
                                                    ,l_enroll_type
                                                    ,l_enroll_amount
                                                    ,l_enroll_units
                                                    ,l_enroll_days
                                                    ,l_error_code
                                                    ,l_error_message);
            IF l_promo_objid IS NOT NULL THEN
              BEGIN
                SELECT x_promo_code
                  INTO l_promo_code
                  FROM table_x_promotion
                 WHERE objid = l_promo_objid;
              EXCEPTION
                WHEN no_data_found THEN
                  l_promo_code := NULL;
              END;

-- START CR49229

        sa.enroll_promo_pkg.get_discount_amount(v_esn,
                                             l_promo_objid,
                                             t_dim1(k).price,
                                             l_enroll_amount,
                                             l_result);

-- END CR49229

              t_dim1(i).disc := l_enroll_amount;
              t_dim1(i).promo := l_promo_code;
            ELSE
              t_dim1(i).disc := 0;
              t_dim1(i).promo := 'N/A';
            END IF;
          END IF;
          -- CR15373 WMMC pm End.
          --
          --CR22460 Start kacosta 10/31/2012
        END IF;
        --CR22460 End kacosta 10/31/2012
        --
        -- CR19467 ST Promo Start.
        OPEN cur_promo_dtl(p_promo_code
                          ,'BPEnrollment'); --07/09/2012
        FETCH cur_promo_dtl
          INTO rec_promo_dtl;
        --CR20399
        --if cur_promo_dtl%found then
        --     l_promo_objid := rec_promo_dtl.objid;
        --   end if;
        CLOSE cur_promo_dtl;
        -- CR20399
        dbms_output.put_line('l_promo_objid a ' || l_promo_objid);
        dbms_output.put_line('l_promo_objid b ' || l_promo_code);
        dbms_output.put_line('l_promo_objid c ' || l_enroll_type);
        dbms_output.put_line('l_promo_objid d ' || l_enroll_amount);
        dbms_output.put_line('l_promo_code: ' || l_promo_code);
        dbms_output.put_line('l_promo_objid: ' || l_promo_objid);
        dbms_output.put_line('rec_promo_dtl.x_promo_code: ' || rec_promo_dtl.x_promo_code);
        --CR20399
        IF rec_promo_dtl.x_promo_code IS NOT NULL
           AND l_promo_code IS NULL THEN
          --
          --CR22460 Start kacosta 10/31/2012
          dbms_output.put_line('Checking for enrolled program promotion');
          --
          -- Correct a flaw in passing l_promo_objid as NULL
          l_promo_objid := rec_promo_dtl.objid;
          --CR22460 End kacosta 10/31/2012
          --
          sa.enroll_promo_pkg.sp_validate_promo(p_esn
                                               ,NULL
                                               , -- p_program_objid
                                                'RECURRING'
                                               , -- p_process
                                                l_promo_objid
                                               , -- p_promo_objid
                                                l_promo_code
                                               ,l_enroll_type
                                               ,l_enroll_amount
                                               ,l_enroll_units
                                               ,l_enroll_days
                                               ,l_error_code
                                               ,l_error_message);
          dbms_output.put_line('l_promo_objid ' || l_promo_objid);
          dbms_output.put_line('l_enroll_amount: ' || l_enroll_amount);
          --
          --CR22460 Start kacosta 10/31/2012
          -- Change to check to promo code
          --IF l_promo_objid IS NOT NULL THEN
          IF l_promo_objid IS NOT NULL
             AND l_promo_code IS NOT NULL THEN
            --CR22460 End kacosta 10/31/2012
            --
            BEGIN
              SELECT x_promo_code
                INTO l_promo_code
                FROM table_x_promotion
               WHERE objid = l_promo_objid;
            EXCEPTION
              WHEN no_data_found THEN
                l_promo_code := NULL;
            END;
            dbms_output.put_line('l_promo_code ' || l_promo_code);

-- START CR49229

        sa.enroll_promo_pkg.get_discount_amount(v_esn,
                                             l_promo_objid,
                                             t_dim1(k).price,
                                             l_enroll_amount,
                                             l_result);

-- END CR49229

            t_dim1(i).disc := l_enroll_amount;
            t_dim1(i).promo := l_promo_code;
          ELSE
            t_dim1(i).disc := 0;
            t_dim1(i).promo := 'N/A';
          END IF;
        END IF;
        -- CR19467 ST Promo Start.
        --
        --CR22460 Start kacosta 10/31/2012
        -- Change to check to promo code
        --IF l_error_code IS NULL THEN
        IF l_promo_code IS NULL THEN
          --CR22460 Start kacosta 10/31/2012
          dbms_output.put_line('Checking for promo code promotion');
          --
          --
          -- CR15373 WMMC pm condition added to skip if money card promo exists.
          dbms_output.put_line('before promo_code: ');
          --CR20399
          IF p_brand_name = 'NET10' THEN
            p_transaction_amount := t_dim1(i).price;
          END IF;

           /*
          Change: CR42361
          Name: VNainar / MGovindarajan
          Date: 8/24/2016
          Comments: added new procedure promotion_pkg.validate_promo_code_ext for TF smartphones.
                Use the Correct Price as transaction amt for TF Smartphone only  instead of Part_num's x_redeem-units */

          IF sa.device_util_pkg.get_smartphone_fun(p_esn) = 0 THEN

            sa.promotion_pkg.validate_promo_code_ext(p_esn    => p_esn
                            ,p_red_code01                => l_var1
                            ,p_red_code02              => p_red_code02
                            ,p_red_code03              => p_red_code03
                            ,p_red_code04              => p_red_code04
                            ,p_red_code05              => p_red_code05
                            ,p_red_code06              => p_red_code06
                            ,p_red_code07              => p_red_code07
                            ,p_red_code08              => p_red_code08
                            ,p_red_code09              => p_red_code09
                            ,p_red_code10              => p_red_code10
                            ,p_technology              => p_technology
                            ,p_transaction_amount      => t_dim1(i).price
                            ,p_source_system           => p_source_system
                            ,p_promo_code              => p_promo_code
                            ,p_transaction_type        => p_transaction_type
                            ,p_zipcode                 => p_zipcode
                            ,p_language                => p_language
                            ,p_fail_flag               => p_fail_flag
                            ,p_discount_amount         => p_discount_amount
                            ,p_promo_units             => p_promo_units
                            ,p_sms                                => p_sms
                            ,p_data_mb                           => p_data_mb
                            ,p_applicable_device_type     => p_applicable_device_type
                            ,p_access_days             => p_access_days
                            ,p_status                  => p_status
                            ,p_msg                     => p_msg);

          ELSE

              validate_promo_code(p_esn                => p_esn
                           ,p_red_code01         => l_var1
                           ,p_red_code02         => p_red_code02
                           ,p_red_code03         => p_red_code03
                           ,p_red_code04         => p_red_code04
                           ,p_red_code05         => p_red_code05
                           ,p_red_code06         => p_red_code06
                           ,p_red_code07         => p_red_code07
                           ,p_red_code08         => p_red_code08
                           ,p_red_code09         => p_red_code09
                           ,p_red_code10         => p_red_code10
                           ,p_technology         => p_technology
                           ,p_transaction_amount => p_transaction_amount
                           ,p_source_system      => p_source_system
                           ,p_promo_code         => p_promo_code
                           ,p_transaction_type   => p_transaction_type
                           ,p_zipcode            => p_zipcode
                           ,p_language           => p_language
                           ,p_fail_flag          => p_fail_flag
                           ,p_discount_amount    => p_discount_amount
                           ,p_promo_units        => p_promo_units
                           ,p_access_days        => p_access_days
                           ,p_status             => p_status
                           ,p_msg                => p_msg);
          END IF;

         dbms_output.put_line('after promo_code: ');
         dbms_output.put_line('P_UNITS_OUT = ' || p_promo_units);
         dbms_output.put_line('P_ACCESS_DAYS_OUT = ' || p_access_days);
         dbms_output.put_line('P_STATUS = ' || p_status);
         dbms_output.put_line('P_MSG = ' || p_msg);
         dbms_output.put_line('P_PROMO_OUT_CODE = ' || p_promo_code);

         --Mgovindarajan : 8/24/2016 : Start
         dbms_output.put_line('P_SMS = ' || p_sms);
         dbms_output.put_line('P_DATA_MB = ' || p_data_mb);
         dbms_output.put_line('P_APPLICABLE_DEVICE_TYPE = ' || p_applicable_device_type);
         --MGovindarajan : 8/24/2016 : End

          IF p_status <> '0' THEN
            -- op_msg:=L_VAR1||P_MSG;
            -- op_result :=   P_STATUS;
            -- RAISE Validate_promo_exc;
            t_dim1(i).disc := 0;
            t_dim1(i).promo := 'N/A';
          ELSE
            t_dim1(i).disc := TO_NUMBER(p_discount_amount);
            t_dim1(i).promo := p_promos;
          END IF;
        END IF;
        --
        --CR22460 Start kacosta 10/31/2012
        dbms_output.put_line('Checking for promotions completed');
        dbms_output.put_line('Discount amount: ' || TO_CHAR(t_dim1(i).disc));
        dbms_output.put_line('Promotion Code: ' || t_dim1(i).promo);
        --
      END IF;
      --CR22460 End kacosta 10/31/2012
      --
      i := i + 1;
      EXIT WHEN l_string IS NULL;
    END loop;

    p_totb_pn    := 0;
    p_tota_pn    := 0;
    p_totb_air   := 0;
    p_tota_air   := 0;
    p_totb_wty   := 0;  --CR18994 - CR22380
    p_totb_dta   := 0;  --CR26033 / CR26274
    p_totb_txt   := 0;  --CR325752

    p_tot_MODEL_TYPE  := 0;   -- CR27269 -- CR27270 (alert car)
    p_model_type      := 'N/A';  -- CR27269 -- CR27270 (alert car)

    p_tot_disc := 0;

    --    CR41745
    op_salestaxonly_b_amt        :=    0;
    op_salestaxonly_a_amt        :=    0;
    op_activation_chrg_b_amt    :=    0;
    op_activation_chrg_a_amt    :=    0;
    --    CR41745


    dbms_output.put_line('Setting out parameters');
    FOR k IN 1 .. p_count LOOP
      p_totb_pn := NVL(p_totb_pn
                      ,0) + NVL(t_dim1(k).price
                               ,0);
      p_tota_pn := NVL(p_tota_pn
                      ,0) + (NVL(t_dim1(k).price
                                ,0) - NVL(t_dim1(k).disc
                                         ,0));

      SELECT COUNT(*) INTO L_ILD_EXISTS FROM VAS_PROGRAMS_VIEW WHERE VAS_APP_CARD = t_dim1(k).pn;

      IF NVL(t_dim1(k).f_airtime
            ,0) > 0 OR L_ILD_EXISTS <> 0 THEN
        p_totb_air := NVL(p_totb_air
                         ,0) + NVL(t_dim1(k).price
                                  ,0);
        p_tota_air := NVL(p_tota_air
                         ,0) + (NVL(t_dim1(k).price
                                   ,0) - NVL(t_dim1(k).disc
                                            ,0));
      END IF;
      p_tot_disc := NVL(p_tot_disc
                       ,0) + NVL(t_dim1(k).disc
                                ,0);
      dbms_output.put_line('t_dim1(k).pn: ' || t_dim1(k).pn);
      dbms_output.put_line('t_dim1(k).price: ' || TO_CHAR(NVL(t_dim1(k).price
                                                             ,0)));
      dbms_output.put_line('t_dim1(k).disc: ' || TO_CHAR(NVL(t_dim1(k).disc
                                                            ,0)));
      dbms_output.put_line('t_dim1(k).promo: ' || t_dim1(k).promo);
      dbms_output.put_line('t_dim1(k).f_airtime: ' || TO_CHAR(NVL(t_dim1(k).f_airtime
                                                                 ,0)));
--CR18994 - CR22380 begin
      IF t_dim1(k).f_warranty > 0 THEN
        p_totb_wty := nvl(p_totb_wty,0) + nvl(t_dim1(k).price,0);
      END IF;
--CR18994 - CR22380 end
     IF t_dim1(k).f_MODEL_TYPE IN ('HOME ALERT', 'CAR CONNECT') THEN
        p_TOT_MODEL_TYPE := nvl(p_tot_MODEL_TYPE,0) + nvl(t_dim1(k).price,0);
        p_MODEL_TYPE := nvl(t_dim1(k).F_MODEL_TYPE,'0');
      END IF;
      --CR26033 / CR26274
      IF t_dim1(k).f_dataonly > 0 THEN
        p_totb_dta := nvl(p_totb_dta,0) + nvl(t_dim1(k).price,0);
      END IF;
      --CR26033 / CR26274

      --CR32572 BEGIN
       IF t_dim1(k).f_txtonly > 0 THEN
        p_totb_txt := nvl(p_totb_txt,0) + nvl(t_dim1(k).price,0);
      END IF;
       --CR32572 end

       ---CR41745


    IF NVL(t_dim1(k).f_salestaxonly    ,0) > 0
    THEN

        op_salestaxonly_b_amt    :=    NVL(op_salestaxonly_b_amt,0) + NVL(t_dim1(k).price,0);
        op_salestaxonly_a_amt    :=    NVL(op_salestaxonly_a_amt,0) + (NVL(t_dim1(k).price,0) - NVL(t_dim1(k).disc,0));


    ELSIF     NVL(t_dim1(k).f_nac_activation_charge    ,0) > 0
    THEN

        op_activation_chrg_b_amt    :=    NVL(op_activation_chrg_b_amt,0) + NVL(t_dim1(k).price,0);
        op_activation_chrg_a_amt    :=    NVL(op_activation_chrg_a_amt,0) + (NVL(t_dim1(k).price,0) - NVL(t_dim1(k).disc,0));



    END IF;
    ---CR41745
    END LOOP;

    --CR44459
    BEGIN

        FOR REC_PURCHASE_PROMO IN
        (SELECT PART_NUMBERS ,
          COUNT(1) QUANTITIES
        FROM
          (WITH DATA1 AS
          ( SELECT p_partnumbers PART_NUMBERS FROM dual
          )
        SELECT trim(regexp_substr(PART_NUMBERS, '[^,]+', 1, LEVEL)) PART_NUMBERS
        FROM DATA1
          CONNECT BY instr(PART_NUMBERS, ',', 1, LEVEL - 1) > 0
          )
        WHERE 1           = 1
        AND PART_NUMBERS IS NOT NULL
        GROUP BY PART_NUMBERS
        )
        LOOP

          sa.promotion_pkg.get_eligible_promo ( 'Purchase' ---i_promo_type  IN  VARCHAR2,
          ,rec_purchase_promo.part_numbers                 ---i_part_number IN  VARCHAR2,
          ,rec_purchase_promo.quantities                   ---i_quantity    IN  VARCHAR2,
          ,lv_purch_promo_code                             ---o_promo_code  OUT VARCHAR2,
          ,lv_purch_promo_objid                            ---o_promo_objid OUT VARCHAR2,
          ,lv_purch_discount_amt                           ---o_discount    OUT VARCHAR2,
          ,lv_purch_promo_err_code                         ---o_error_code  OUT VARCHAR2,
          ,lv_purch_promo_err_msg                          ---o_error_msg   OUT VARCHAR2
          );


          IF lv_purch_promo_code IS NOT NULL AND NVL(lv_purch_discount_amt,0) > 0
          THEN

            p_tot_disc           := NVL(p_tot_disc,0)     + NVL(lv_purch_discount_amt,0);
            p_tota_pn         :=    NVL(p_tota_pn,0)    - NVL(lv_purch_discount_amt,0);

            FOR j IN 1 .. p_count
            LOOP

                IF t_dim1(j).pn = rec_purchase_promo.part_numbers
                THEN

                    SELECT COUNT(*) INTO L_ILD_EXISTS FROM VAS_PROGRAMS_VIEW WHERE VAS_APP_CARD = t_dim1(j).pn;

                    IF NVL(t_dim1(j).f_airtime,0) > 0 OR L_ILD_EXISTS <> 0
                    THEN

                        p_tota_air := NVL(p_tota_air,0) - NVL(lv_purch_discount_amt,0);



                    ELSIF NVL(t_dim1(j).f_salestaxonly    ,0) > 0
                    THEN


                        op_salestaxonly_a_amt    :=    NVL(op_salestaxonly_a_amt,0) - NVL(lv_purch_discount_amt,0);


                    ELSIF     NVL(t_dim1(j).f_nac_activation_charge    ,0) > 0
                    THEN


                        op_activation_chrg_a_amt    :=    NVL(op_activation_chrg_a_amt,0) - NVL(lv_purch_discount_amt,0);



                    END IF;


                    EXIT;

                END IF;


            END LOOP;
          END IF;



        END LOOP;

    EXCEPTION WHEN OTHERS
    THEN

        dbms_output.put_line('Purchase promo exception '||sqlerrm);

    END;

    --CR44459


    p_totb_pn  := NVL(p_totb_pn
                     ,0);
    p_tota_pn  := NVL(p_tota_pn
                     ,0);
    p_totb_air := NVL(p_totb_air
                     ,0);
    p_tota_air := NVL(p_tota_air
                     ,0);
    p_tot_disc := NVL(p_tot_disc
                     ,0);
--CR18994 - CR22380 begin
    p_totb_wty := NVL(p_totb_wty
                     ,0);
--CR18994 - CR22380 end

    p_totb_dta := NVL(p_totb_dta,0);   --CR26033 / CR26274
    p_totb_dta := NVL(p_totb_dta,0) ;   --CR26033 / CR26274
    p_totb_txt := NVL(p_totb_txt,0) ;   --CR32572

    p_tot_model_type := NVL(p_tot_model_type,0);   --CR27269

    p_model_type := NVL(P_model_type,'0');   -- CR27269--vineeth

    op_msg   := 'successful';
    op_count := p_count;
    COMMIT;

    --CR29021 changes start  9-jan-2015  --CR30286
        /* return the 4 parameters as 0 for safelink e911 project since the part number has price= $0 */
        /* Below code has not been used since CR33056.  However it is impacting CR37485. Hence commenting.
    declare
      lv_e911_count         pls_integer := 0;
      lv_part_number        varchar2(2000);
      lv_subtext            varchar2(2000);
      i                     pls_integer := 0;
      lv_part_number_count  integer := 0;

      cursor cur_enrollment is
        select
          sub.lid as lid,
          sub.zip as prog_zipcode,
          x.pgm_enroll2pgm_parameter as prog_objid
        from x_program_enrolled x,
            x_sl_currentvals val,
            x_sl_subs sub,
          x_program_parameters p
        where 1=1
        and x.x_esn = v_esn
        and val.x_current_esn = x.x_esn
        and sub.lid = val.lid
        and p.objid = x.pgm_enroll2pgm_parameter
        and p.x_prog_class = 'LIFELINE'
        and x.x_enrollment_status = 'ENROLLED';

      rec_enrollment    cur_enrollment%rowtype;

    begin

      lv_part_number := trim(trim(BOTH ',' FROM trim(p_partnumbers))) ||',';
      lv_part_number :=  replace(lv_part_number, ' ', '');

      ---dbms_output.put_line(' start....lv_part_number='||lv_part_number);
      i := instr(lv_part_number, ',');

      while i > 0 loop
        i := instr(lv_part_number, ',');

        if lv_subtext  is null then
          lv_subtext  := substr(lv_part_number, 1, i-1);
        end if;

        if substr(lv_part_number, 1, i-1) = lv_subtext then
          lv_part_number_count := lv_part_number_count + 1;
        else
          lv_part_number_count := -1;
          exit;
        end if;
        lv_part_number := trim(substr(trim(lv_part_number), i+1));
        i := instr(lv_part_number, ',');
      end loop;

      ---dbms_output.put_line('*************** lv_count='||lv_count ||', lv_subtext='||lv_subtext);
      open cur_enrollment ;
      fetch cur_enrollment into rec_enrollment ;
      close cur_enrollment;

            select count(1)
      into lv_e911_count
      from mtm_program_safelink mtm
      where 1=1
      and mtm.program_param_objid = rec_enrollment.prog_objid
      and mtm.part_num_objid = (select objid
                      from table_part_num
                      where part_number = lv_subtext
                      and domain = 'REDEMPTION CARDS'
                      )
      and sysdate between mtm.start_date  and mtm.end_date
      and mtm.program_provision_flag = '3' ;
      ---dbms_output.put_line('**********lv_e911_count='||lv_e911_count);
      if nvl(lv_e911_count,0) > 0 then
        --p_totb_pn := lv_part_number_count * sa.sp_taxes.computee911surcharge2(rec_enrollment.prog_zipcode); Commented by Rahul for BRANCH.Branch_2015 - Defect # 3155 for CR 33056
        p_totb_pn := 0;    -- Modified by Rahul for BRANCH.Branch_2015 - Defect # 3155 raised for CR 33056
        p_tota_pn := p_totb_pn;
        p_totb_air := 0;
        p_tota_air := 0;
      end if;
    end;
    --CR29021 changes end
    Above code has not been used since CR33056.  However it is impacting CR37485. Hence commenting.
    */

    dbms_output.put_line('p_totb_pn: ' || TO_CHAR(p_totb_pn));
    dbms_output.put_line('p_tota_pn: ' || TO_CHAR(p_tota_pn));
    dbms_output.put_line('p_totb_air: ' || TO_CHAR(p_totb_air));
    dbms_output.put_line('p_tota_air: ' || TO_CHAR(p_tota_air));
    dbms_output.put_line('p_tot_disc: ' || TO_CHAR(p_tot_disc));
    dbms_output.put_line('p_totb_wty: ' || TO_CHAR(p_totb_wty));      --CR18994 - CR22380
    dbms_output.put_line('p_totb_dta: ' || TO_CHAR(p_totb_dta));      --CR26033 / CR26274
    dbms_output.put_line('p_totb_TXT: ' || TO_CHAR(p_totb_TXT));      --CR32572
    dbms_output.put_line('p_tot_model_type: ' || TO_CHAR(p_tot_model_type));  --CR27269
    dbms_output.put_line('p_model_type: ' || p_model_type);      --CR27270

    dbms_output.put_line('op_count: ' || TO_CHAR(op_count));
    dbms_output.put_line('op_result: ' || TO_CHAR(op_result));
    dbms_output.put_line('op_msg: ' || op_msg);
    dbms_output.put_line('Executing sp_metadata.getcartmetadata completed');
  EXCEPTION
    WHEN part_number_exc THEN
      dbms_output.put_line('Executing sp_metadata.getcartmetadata completed with part_number_exc exception');
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata'
        ,2 -- MEDIUM
         );
      COMMIT;
    WHEN validate_promo_exc THEN
      dbms_output.put_line('Executing sp_metadata.getcartmetadata completed with validate_promo_exc exception');
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata'
        ,2 -- MEDIUM
         );
      COMMIT;
      WHEN cc2zip2tax_exc THEN
      dbms_output.put_line('Executing sp_metadata.getcartmetadata completed with validate_cc2zip2tax_exc exception');
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata'
        ,2 -- MEDIUM
         );
      COMMIT;
    WHEN others THEN
      dbms_output.put_line('Executing sp_metadata.getcartmetadata completed with others exception');
      op_result := SQLCODE;
      op_msg    := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK
                ,1
                ,100)||' '||SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ,1
                ,40)||' '||SUBSTR(p_partnumbers,1,40)||' '||' esn '||v_esn||' '||p_source;

      dbms_output.put_line('op_result: ' || TO_CHAR(SQLCODE));
      dbms_output.put_line('op_msg: ' || op_msg);
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata'
        ,2 -- MEDIUM
         );
  END getcartmetadata;

  PROCEDURE getcartmetadata_b2b
  (
    p_partnumbers IN VARCHAR2
   ,p_promos      IN VARCHAR2
   ,v_esn         IN VARCHAR2
   ,p_source      IN VARCHAR2
   ,p_type        IN VARCHAR2
   ,p_totb_pn     OUT NUMBER
   ,p_tota_pn     OUT NUMBER
   ,p_totb_air    OUT NUMBER
   ,p_tota_air    OUT NUMBER
   ,p_tot_disc    OUT NUMBER
   ,op_count      OUT NUMBER
   ,op_result     OUT NUMBER
   ,op_msg        OUT VARCHAR2
  ) IS
    /* Assumptions: P_partnumbers are a group of part number valid or pin number cards valid. all input parameters are valid.
    */
    validate_promo_exc EXCEPTION;
    part_number_exc    EXCEPTION;
    pricing_exc        EXCEPTION;
    i                    NUMBER;
    k                    NUMBER;
    p_count              NUMBER;
    l_var1               table_part_num.part_number%TYPE;
    l_string             VARCHAR2(1000);
    p_esn                VARCHAR2(200);
    p_red_code02         VARCHAR2(200);
    p_red_code03         VARCHAR2(200);
    p_red_code04         VARCHAR2(200);
    p_red_code05         VARCHAR2(200);
    p_red_code06         VARCHAR2(200);
    p_red_code07         VARCHAR2(200);
    p_red_code08         VARCHAR2(200);
    p_red_code09         VARCHAR2(200);
    p_red_code10         VARCHAR2(200);
    p_technology         VARCHAR2(200);
    p_transaction_amount NUMBER;
    p_source_system      VARCHAR2(200);
    p_promo_code         VARCHAR2(200);
    p_transaction_type   VARCHAR2(200);
    p_zipcode            VARCHAR2(200);
    p_language           VARCHAR2(200);
    p_fail_flag          NUMBER;
    p_discount_amount    VARCHAR2(200);
    p_promo_units        NUMBER;
    p_access_days        NUMBER;
    p_status             VARCHAR2(200);
    p_msg                VARCHAR2(200);
    TYPE name_record IS RECORD(
       pn        table_part_num.part_number%TYPE
      ,price     table_x_pricing.x_retail_price%TYPE
      ,disc      table_x_pricing.x_retail_price%TYPE
      ,promo     table_x_promotion.x_promo_code%TYPE
      ,f_airtime NUMBER);
    TYPE dim1 IS TABLE OF name_record INDEX BY BINARY_INTEGER;
    t_dim1 dim1;
    CURSOR amount_cur(l1_var1 IN VARCHAR2) IS
      SELECT x_redeem_units
        FROM table_part_num
       WHERE part_number = l1_var1;
    amount_rec amount_cur%ROWTYPE;
    CURSOR airtime_cur(l1_var1 IN VARCHAR2) IS
      SELECT COUNT(*) n_amount
        FROM table_part_num   pn
            ,table_part_class pc
       WHERE 1 = 1
         AND pn.part_number = l1_var1
         AND pn.domain = 'REDEMPTION CARDS'
         AND pn.part_num2part_class = pc.objid
         AND pn.x_redeem_units > 0; -- CR17340 or (pn.x_redeem_units = 0 and  pc.name = 'NTULCARD'));-- included net10 unlimited 0 units
    --    where part_number = L1_VAR1 and domain ='REDEMPTION CARDS'  and x_redeem_units > 0 ;
    airtime_rec airtime_cur%ROWTYPE;
    --CR17340
    CURSOR airtime_unl_cur(l1_var1 IN VARCHAR2) IS
      SELECT COUNT(*) n_amount
        FROM table_part_num               pn
            ,table_part_class             pc
            ,sa.service_plan_flat_summary sf
       WHERE 1 = 1
         AND pn.part_number = l1_var1
         AND pn.domain = 'REDEMPTION CARDS'
         AND pn.part_num2part_class = pc.objid
         AND pn.x_redeem_units = 0
         AND sf.part_class_objid = pc.objid
         AND sf.fea_name = 'VOICE';
    --    and sf.Fea_Display='Unlimited'; -- CR12838
    airtime_unl_rec airtime_unl_cur%ROWTYPE;
    --CR17340
    CURSOR tech_cur(l1_var1 IN VARCHAR2) IS
      SELECT pn.x_technology tech
        FROM table_part_num pn
       WHERE pn.part_number = l1_var1;
    tech_rec tech_cur%ROWTYPE;
    CURSOR price_b2b_cur(l1_var1 IN VARCHAR2) IS
      SELECT x_retail_price
        FROM sa.x_b2b_phone_view
       WHERE part_number = l1_var1;
    price_b2b_rec price_b2b_cur%ROWTYPE;
  BEGIN
    i         := 1;
    k         := 1;
    op_result := 0;
    op_msg    := '';
    l_string  := p_partnumbers;
    p_count   := 0;
    LOOP
      l_var1   := NVL(SUBSTR(l_string
                            ,1
                            ,INSTR(l_string
                                  ,','
                                  ,1) - 1)
                     ,l_string);
      l_string := TRIM(SUBSTR(l_string
                             ,LENGTH(l_var1) + 2
                             ,LENGTH(l_string)));
      dbms_output.put_line('Part Number: ' || l_var1);
      t_dim1(i).pn := l_var1;
      dbms_output.put_line('before get price ');
      OPEN price_b2b_cur(l_var1);
      FETCH price_b2b_cur
        INTO price_b2b_rec;
      IF price_b2b_cur%NOTFOUND THEN
        CLOSE price_b2b_cur;
        op_msg := 'price not found: ' || l_var1;
        RAISE pricing_exc;
      END IF;
      t_dim1(i).price := price_b2b_rec.x_retail_price;
      CLOSE price_b2b_cur;
      dbms_output.put_line('after price: ' || t_dim1(i).price);
      p_count         := p_count + 1;
      p_esn           := v_esn;
      p_red_code02    := NULL;
      p_red_code03    := NULL;
      p_red_code04    := NULL;
      p_red_code05    := NULL;
      p_red_code06    := NULL;
      p_red_code07    := NULL;
      p_red_code08    := NULL;
      p_red_code09    := NULL;
      p_red_code10    := NULL;
      p_zipcode       := NULL;
      p_technology    := NULL;
      p_source_system := p_source;
      OPEN amount_cur(l_var1);
      FETCH amount_cur
        INTO amount_rec;
      IF amount_cur%NOTFOUND THEN
        CLOSE amount_cur;
        op_msg := 'part_number not found: ' || l_var1;
        RAISE part_number_exc;
      END IF;
      dbms_output.put_line('amount found: ' || TO_CHAR(amount_rec.x_redeem_units));
      p_transaction_amount := amount_rec.x_redeem_units;
      CLOSE amount_cur;
      /*
      open airtime_cur(L_VAR1);
      fetch airtime_cur into airtime_rec;
      t_dim1(i).f_airtime := airtime_rec.n_amount;
      close airtime_cur; */
      --CR17340
      IF p_transaction_amount > 0 THEN
        OPEN airtime_cur(l_var1);
        FETCH airtime_cur
          INTO airtime_rec;
        t_dim1(i).f_airtime := airtime_rec.n_amount;
        CLOSE airtime_cur;
      ELSE
        --check if part number is associated to unlimited plan (included net10 unlimited 0 unit)
        OPEN airtime_unl_cur(l_var1);
        FETCH airtime_unl_cur
          INTO airtime_unl_rec;
        t_dim1(i).f_airtime := airtime_unl_rec.n_amount;
        CLOSE airtime_unl_cur;
      END IF;
      --CR17340
      OPEN tech_cur(l_var1);
      FETCH tech_cur
        INTO tech_rec;
      p_technology := tech_rec.tech;
      CLOSE tech_cur;
      p_transaction_type := p_type;
      p_language         := 'ENGLISH';
      p_fail_flag        := NULL;
      p_promo_code       := p_promos;
      dbms_output.put_line('before promo_code: ');
      validate_promo_code(p_esn                => p_esn
                         ,p_red_code01         => l_var1
                         ,p_red_code02         => p_red_code02
                         ,p_red_code03         => p_red_code03
                         ,p_red_code04         => p_red_code04
                         ,p_red_code05         => p_red_code05
                         ,p_red_code06         => p_red_code06
                         ,p_red_code07         => p_red_code07
                         ,p_red_code08         => p_red_code08
                         ,p_red_code09         => p_red_code09
                         ,p_red_code10         => p_red_code10
                         ,p_technology         => p_technology
                         ,p_transaction_amount => p_transaction_amount
                         ,p_source_system      => p_source_system
                         ,p_promo_code         => p_promo_code
                         ,p_transaction_type   => p_transaction_type
                         ,p_zipcode            => p_zipcode
                         ,p_language           => p_language
                         ,p_fail_flag          => p_fail_flag
                         ,p_discount_amount    => p_discount_amount
                         ,p_promo_units        => p_promo_units
                         ,p_access_days        => p_access_days
                         ,p_status             => p_status
                         ,p_msg                => p_msg);
      dbms_output.put_line('after promo_code: ');
      dbms_output.put_line('P_UNITS_OUT = ' || p_promo_units);
      dbms_output.put_line('P_ACCESS_DAYS_OUT = ' || p_access_days);
      dbms_output.put_line('P_STATUS = ' || p_status);
      dbms_output.put_line('P_MSG = ' || p_msg);
      dbms_output.put_line('P_PROMO_OUT_CODE = ' || p_promo_code);
      IF p_status <> '0' THEN
        -- op_msg:=L_VAR1||P_MSG;
        -- op_result :=   P_STATUS;
        -- RAISE Validate_promo_exc;
        t_dim1(i).disc := 0;
        t_dim1(i).promo := 'N/A';
      ELSE
        t_dim1(i).disc := TO_NUMBER(p_discount_amount);
        t_dim1(i).promo := p_promos;
      END IF;
      i := i + 1;
      EXIT WHEN l_string IS NULL;
    END LOOP;
    p_totb_pn  := 0;
    p_tota_pn  := 0;
    p_totb_air := 0;
    p_tota_air := 0;
    p_tot_disc := 0;
    FOR k IN 1 .. p_count LOOP
      p_totb_pn := p_totb_pn + t_dim1(k).price;
      p_tota_pn := p_tota_pn + (t_dim1(k).price - t_dim1(k).disc);
      IF t_dim1(k).f_airtime > 0 THEN
        p_totb_air := p_totb_air + t_dim1(k).price;
        p_tota_air := p_tota_air + (t_dim1(k).price - t_dim1(k).disc);
      END IF;
      p_tot_disc := p_tot_disc + t_dim1(k).disc;
      dbms_output.put_line(t_dim1(k).pn);
      dbms_output.put_line(t_dim1(k).price);
      dbms_output.put_line(t_dim1(k).disc);
      dbms_output.put_line(t_dim1(k).promo);
      dbms_output.put_line(t_dim1(k).f_airtime);
      COMMIT;
    END LOOP;
    -- dbms_output.put_line(to_char(P_TOTB_PN));
    -- dbms_output.put_line(to_char(P_TOTA_PN));
    -- dbms_output.put_line(to_char(P_TOTB_Air));
    -- dbms_output.put_line(to_char(P_TOTA_Air));
    -- dbms_output.put_line(to_char(P_TOT_disc));
    op_msg   := 'successful';
    op_count := p_count;
    COMMIT;
  EXCEPTION
    WHEN part_number_exc THEN
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata_b2b'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata_b2b'
        ,2 -- MEDIUM
         );
      COMMIT;
    WHEN pricing_exc THEN
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata_b2b'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata_b2b'
        ,2 -- MEDIUM
         );
      COMMIT;
    WHEN validate_promo_exc THEN
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata_b2b'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata_b2b'
        ,2 -- MEDIUM
         );
      COMMIT;
    WHEN others THEN
      op_result := SQLCODE;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('SP_METADATA.getcardmetadata'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'SP_METADATA.getcardmetadata'
        ,2 -- MEDIUM
         );
  END GETCARTMETADATA_B2B;
--
-- CR49058 changes starts..
-- new procedure to get billing program based on the partnumber
--
PROCEDURE  p_get_billing_program  ( i_part_number     IN    VARCHAR2,
                                    o_program_id      OUT   VARCHAR2,
                                    o_error_code      OUT   VARCHAR2,
                                    o_error_msg       OUT   VARCHAR2)
IS
BEGIN
--
  SELECT pp.objid
  INTO   o_program_id
  FROM   x_program_parameters pp,
         table_part_num   pn
  WHERE  pn.part_number   = i_part_number
  AND   (pp.prog_param2prtnum_enrlfee = pn.objid OR
         pp.prog_param2prtnum_monfee  = pn.objid);
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_program_id  :=  NULL;
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of p_get_billing_program ' || SQLERRM;
END p_get_billing_program;
--
--new procedure to get part number based on billing program
--
PROCEDURE  p_get_part_number    ( i_program_parameter_id      IN    VARCHAR2,
                                  o_part_number               OUT   VARCHAR2,
                                  o_error_code                OUT   VARCHAR2,
                                  o_error_msg                 OUT   VARCHAR2)
IS
BEGIN
--
  SELECT  pn.part_number
  INTO    o_part_number
  FROM    x_program_parameters pp,
          table_part_num  pn
  WHERE   pp.objid    = i_program_parameter_id
  AND     pn.objid    = (CASE WHEN pp.x_is_recurring = 0
                              THEN pp.prog_param2prtnum_enrlfee
                              ELSE pp.prog_param2prtnum_monfee
                         END);
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_part_number   :=  NULL;
    o_error_code    :=  '99';
    o_error_msg     :=  'Failed in when others of p_get_part_number ' || SQLERRM;
END  p_get_part_number;
--
-- procedure to calculate prorated amount based on the part number and prorated days
--
PROCEDURE  p_get_prorated_amount  ( i_esn               IN    VARCHAR2,
                                    i_part_number       IN    VARCHAR2,
                                    i_price_channel     IN    VARCHAR2,
                                    i_prorated_days     IN    NUMBER,
                                    i_service_days      IN    NUMBER,
                                    o_prorated_amount   OUT   NUMBER,
                                    o_error_code        OUT   VARCHAR2,
                                    o_error_msg         OUT   VARCHAR2
                                  )
IS
--
  l_partnum_price       NUMBER;
  l_cost_per_day        NUMBER;
--
BEGIN
  --  Input Validation
  IF i_esn  IS NULL OR i_part_number IS NULL OR i_price_channel IS NULL OR i_prorated_days  IS NULL OR i_service_days IS NULL
  THEN
    o_error_code  :=  '100';
    o_error_msg   :=  'Invalid Input Parameters';
    RETURN;
  END IF;
  -- get partnumber
  l_partnum_price   :=  sp_metadata.getprice(i_part_number,i_price_channel);
  --
  IF NVL(l_partnum_price, 0 ) = 0
  THEN
    o_error_code  :=  '101';
    o_error_msg   :=  'Invalid Part Number Pricing';
    RETURN;
  END IF;
  -- Calculate cost per day
  l_cost_per_day    :=  l_partnum_price / NVL(i_service_days,1);
  --
  -- Calculate prorated cost
  o_prorated_amount :=  i_prorated_days * l_cost_per_day;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of p_get_prorated_amount ' || SQLERRM;
END p_get_prorated_amount;
--
-- actual proration logic is in this overloaded procedure
--
PROCEDURE p_vas_proration_service ( i_esn                   IN    VARCHAR2,
                                    i_vas_service_id        IN    VARCHAR2,
                                    i_current_expiry_date   IN    DATE,
                                    i_current_status        IN    VARCHAR2,
                                    i_part_number           IN    VARCHAR2,
                                    i_source                IN    VARCHAR2,
                                    o_prorated_service_days OUT   NUMBER,
                                    o_prorated_amount       OUT   NUMBER,
                                    o_error_code            OUT   VARCHAR2,
                                    o_error_msg             OUT   VARCHAR2
                                  )
IS
--
  l_prorated_days           NUMBER;
  l_prorated_amount         NUMBER;
  c                         customer_type     :=  customer_type();
  cst                       customer_type     :=  customer_type();
  vpt                       vas_programs_type;
--
BEGIN
--
  -- Initialize Output variables
  o_prorated_service_days     :=  0;
  o_prorated_amount           := 0;
  --
  -- Input validation
  IF i_esn IS NULL OR i_part_number IS NULL OR i_vas_service_id IS NULL OR i_current_status IS NULL
  THEN
    o_error_code      :=  '200';
    o_error_msg       :=  'INPUT PARAMETERS CANNOT BE NULL';
    RETURN;
  END IF;
  --
  IF i_current_expiry_date IS NULL AND i_current_status <> 'NOT_ENROLLED'
  THEN
    o_error_code      :=  '201';
    o_error_msg       :=  'INPUT PARAMETER CURRENT EXPIRY DATE CANNOT BE NULL';
    RETURN;
  END IF;
  -- get VAS program attributes
  vpt                   :=  vas_programs_type (i_vas_service_id => i_vas_service_id );
  --
  IF vpt.response NOT LIKE '%SUCCESS%'
  THEN
    o_error_code      :=  '202';
    o_error_msg       :=  'INVALID VAS SERVICE ID';
    RETURN;
  END IF;
  --
  -- get the base_service plan end date
  c.expiration_date     :=  cst.get_expiration_date ( i_esn => i_esn);
  --
  IF  c.expiration_date IS NULL
  THEN
    o_error_code      :=  '203';
    o_error_msg       :=  'INVALID ESN';
    RETURN;
  END IF;
  --
  c.esn                 :=  i_esn;
  cst                   :=  c.get_service_plan_attributes;
  --
  ----------  PRORATION LOGIC TO ALIGN DATES IN DIFFERENT SCENARIOS  -----------
  --
  --  base plan was reactivated and  VAS is in suspend status with expiry date in the past
  IF  i_current_status              = 'SUSPENDED'
  AND TRUNC(i_current_expiry_date)  < TRUNC(SYSDATE)
  AND TRUNC(c.expiration_date)      > TRUNC(SYSDATE)
  THEN
    --
    l_prorated_days :=  TRUNC(c.expiration_date) - TRUNC(i_current_expiry_date);
    --
  --  base plan is going to be reactivated and  VAS is in suspend status with expiry date in the future
  ELSIF i_current_status            = 'SUSPENDED'
  AND TRUNC(i_current_expiry_date)  > TRUNC(SYSDATE)
  AND TRUNC(c.expiration_date)      < TRUNC(SYSDATE)
  THEN
    --
    -- new forecasted service end date minus vas expiry date
    l_prorated_days :=  (TRUNC(SYSDATE)  + cst.service_plan_days) - TRUNC(i_current_expiry_date);
    --
  --  base plan is going to be reactivated and  VAS is in suspend status with expiry date in the past
  --  to cover the scenario where the customer is trying to pay on the due date, less than equal to added
  ELSIF i_current_status            = 'SUSPENDED'
  AND TRUNC(i_current_expiry_date)  <= TRUNC(SYSDATE)
  AND TRUNC(c.expiration_date)      <= TRUNC(SYSDATE)
  THEN
    --
    -- new forecasted service end date minus vas expiry date
    l_prorated_days :=  (TRUNC(SYSDATE)  + cst.service_plan_days) - TRUNC(i_current_expiry_date);
    --
  -- apply proration at the time of offering / new enrollment
  ELSIF i_current_status            = 'NOT_ENROLLED'
  AND TRUNC(c.expiration_date)      > TRUNC(SYSDATE)
  THEN
    --
    l_prorated_days :=  TRUNC(c.expiration_date) - TRUNC(SYSDATE);
    --
    -- During new enrollment, Prorated days should always be less than the actual service days of the program
    IF l_prorated_days > vpt.service_days
    THEN
      l_prorated_days :=  0;
      --
    END IF;
    --
  ELSE
    l_prorated_days :=  0;
    --
  END IF;
  --
  IF cst.service_plan_benefit_type <> 'STACK'  AND
     l_prorated_days  > 0
  THEN
    -- GET PRORATED AMOUNT
    sp_metadata.p_get_prorated_amount  (  i_esn               =>  i_esn,
                                          i_part_number       =>  i_part_number,
                                          i_price_channel     =>  i_source, --'BILLING',
                                          i_prorated_days     =>  l_prorated_days,
                                          i_service_days      =>  vpt.service_days,
                                          o_prorated_amount   =>  l_prorated_amount,
                                          o_error_code        =>  o_error_code,
                                          o_error_msg         =>  o_error_msg
                                        );
    --
    IF NVL(l_prorated_amount,0)  > 0
    THEN
      o_prorated_service_days     :=  l_prorated_days;
      o_prorated_amount           :=  l_prorated_amount;
    END IF;
  END IF;
  --
  o_error_code      :=  '0';
  o_error_msg       :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of p_vas_proration_service ' || SQLERRM;
--
END p_vas_proration_service;
--
-- below procedure is a wrapper which can be called directly from the getcartmetadata in future
--
PROCEDURE  p_vas_proration_service( i_esn               IN    VARCHAR2,
                                    i_part_number       IN    VARCHAR2,
                                    i_source            IN    VARCHAR2,
                                    o_prorated_amount   OUT   NUMBER,
                                    o_error_code        OUT   VARCHAR2,
                                    o_error_msg         OUT   VARCHAR2
                                  )
IS
--
l_program_param_id            VARCHAR2(50);
l_proration_applicable_flag   VARCHAR2(1) :=  'N';
l_prorated_days               NUMBER      :=  0;
l_prorated_amount             NUMBER      :=  0;
l_esn_part_inst_status        table_part_inst.x_part_inst_status%TYPE;
vpt                           vas_programs_type       :=  vas_programs_type();
vs                            vas_subscriptions_type  :=  vas_subscriptions_type();
cst                           customer_type           :=  customer_type();
--
BEGIN
--
  -- Initialize out variables
  o_prorated_amount   :=  0;
  --
  -- Input validation
  IF i_esn IS NULL OR i_part_number IS NULL
  THEN
    o_error_code      :=  '300';
    o_error_msg       :=  'INPUT PARAMETERS CANNOT BE NULL';
    RETURN;
  END IF;
  --
  l_esn_part_inst_status    :=  cst.get_esn_part_inst_status (i_esn =>  i_esn);
  --
  -- NO PRORATION FOR NEW PHONE
  IF l_esn_part_inst_status   = '50'
  THEN
    o_prorated_amount   :=  0;
    o_error_code        :=  '0';
    o_error_msg         :=  'SUCCESS';
    RETURN;
  END IF;
  --
  -- get billing program with part number
  sp_metadata.p_get_billing_program ( i_part_number    => i_part_number,
                                      o_program_id     => l_program_param_id,
                                      o_error_code     => o_error_code,
                                      o_error_msg      => o_error_msg);
  IF l_program_param_id IS NOT NULL
  THEN
    -- get VAS program attributes
    vpt                   :=  vas_programs_type (i_program_param_id => l_program_param_id );
    --
    IF vpt.response NOT LIKE '%SUCCESS%'
    THEN
      o_error_code      :=  '301';
      o_error_msg       :=  'INVALID VAS SERVICE ID';
      RETURN;
    END IF;
    --
  END IF;
  -- get vas_susbscription details
  vs                   :=  vas_subscriptions_type ( i_esn             => i_esn,
                                                    i_vas_service_id  => vpt.vas_service_id );
  --
  -- Apply proration logic
  IF vpt.proration_flag =  'Y'
  THEN
    --
    -- For new vas subscriptions expiry date is passed as null and status as not enrolled
    --
    sp_metadata.p_vas_proration_service ( i_esn                   =>  i_esn,
                                          i_vas_service_id        =>  vpt.vas_service_id,
                                          i_current_expiry_date   =>  vs.vas_expiry_date,
                                          i_current_status        =>  NVL(vs.status,'NOT_ENROLLED'),
                                          i_part_number           =>  i_part_number,
                                          i_source                =>  i_source,
                                          o_prorated_service_days =>  l_prorated_days,
                                          o_prorated_amount       =>  l_prorated_amount,
                                          o_error_code            =>  o_error_code,
                                          o_error_msg             =>  o_error_msg
                                        );
    --
    IF  NVL(l_prorated_amount,0)  > 0  AND
        NVL(l_prorated_days,0)    > 0
    THEN
      o_prorated_amount           :=  l_prorated_amount;
    END IF;
  END IF;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of p_vas_proration_service 1 ' || SQLERRM;
END p_vas_proration_service;
--
-- This procedure will be called to get the proration and tax applicable details
-- if the tax is applicable, CBO calls sp_metada.getcartmetadata , sp_taxes.calculate_taxes ( BAU flow )
--
PROCEDURE  p_vas_proration_service  ( i_esn                       IN      VARCHAR2,
                                      i_source                    IN      VARCHAR2, -- price channel
                                      io_part_number_details_tab  IN OUT  part_number_details_tab,
                                      o_error_code                OUT     VARCHAR2,
                                      o_error_msg                 OUT     VARCHAR2 )
IS
--
  l_program_id                NUMBER;
  l_program_parameters_rec    x_program_parameters%ROWTYPE;
  vpt                         vas_programs_type       :=  vas_programs_type();
  l_prorated_amount           NUMBER:=  0;
  l_part_number               VARCHAR2(50);
--
BEGIN
--
  IF i_esn IS NULL OR io_part_number_details_tab IS NULL
  THEN
    o_error_code  :=  '400';
    o_error_msg   :=  'INPUT PARAMETERS CANNOT BE NULL';
    RETURN;
  END IF;
  --
  FOR each_pn IN 1 .. io_part_number_details_tab.COUNT
  LOOP
    --
    IF io_part_number_details_tab(each_pn).part_number IS NULL  AND
       io_part_number_details_tab(each_pn).billing_program_id IS NULL
    THEN
       o_error_code  :=  '401';
      o_error_msg   :=  'PARTNUMBER AND BILLING PROGRAM CANNOT BE NULL';
      RETURN;
    END IF;
    --
    l_program_id      :=  0;
    l_prorated_amount :=  0;
    l_part_number     :=  NULL;
    -- Initializing the out attributes with default values
    io_part_number_details_tab(each_pn).tax_applicable_flag :=  'Y';
    io_part_number_details_tab(each_pn).proration_applied   :=  'N';
    io_part_number_details_tab(each_pn).amount              :=  0;
    --
    l_program_id  :=  io_part_number_details_tab(each_pn).billing_program_id;
    l_part_number :=  io_part_number_details_tab(each_pn).part_number;
    --
    -- Get Billing Program using part number
    IF l_part_number IS NOT NULL
    THEN
      sp_metadata.p_get_billing_program  (  i_part_number    =>  l_part_number,
                                            o_program_id     =>  l_program_id,
                                            o_error_code     =>  o_error_code,
                                            o_error_msg      =>  o_error_msg);
    ELSIF l_part_number IS NULL AND
          l_program_id  IS NOT NULL
    THEN
      sp_metadata.p_get_part_number ( i_program_parameter_id      =>  l_program_id,
                                      o_part_number               =>  l_part_number,
                                      o_error_code                =>  o_error_code,
                                      o_error_msg                 =>  o_error_msg);
    END IF;
    --
    IF NVL(l_program_id,0) <> 0
    THEN
      -- get VAS program attributes
      vpt                   :=  vas_programs_type (i_program_param_id => l_program_id );
      --
      IF vpt.response NOT LIKE '%SUCCESS%'
      THEN
        --
        CONTINUE;
      END IF;
      --
      BEGIN
        SELECT  *
        INTO    l_program_parameters_rec
        FROM    x_program_parameters
        WHERE   objid           =   l_program_id
        AND     x_prog_class    IN  ( SELECT x_param_value
                                      FROM sa.table_x_parameters
                                      WHERE x_param_name = 'NON_BASE_PROGRAM_CLASS'
                                    );
      EXCEPTION
        WHEN OTHERS THEN
          CONTINUE;
      END;
      --
    ELSE
      --
      CONTINUE;
    END IF;
    --
    IF  l_program_parameters_rec.x_sales_tax_flag         = 0    AND
        l_program_parameters_rec.x_sales_tax_charge_cust  = 0
    THEN
      io_part_number_details_tab(each_pn).tax_applicable_flag :=  'N';
      --
      IF vpt.proration_flag =  'Y'
      THEN
        sp_metadata. p_vas_proration_service( i_esn               =>  i_esn,
                                              i_part_number       =>  l_part_number,
                                              i_source            =>  i_source,
                                              o_prorated_amount   =>  l_prorated_amount,
                                              o_error_code        =>  o_error_code,
                                              o_error_msg         =>  o_error_msg
                                            );
        --
        IF  l_prorated_amount > 0
        THEN
          io_part_number_details_tab(each_pn).proration_applied   :=  'Y';
          io_part_number_details_tab(each_pn).amount              :=  l_prorated_amount;
        END IF;
      ELSE
        io_part_number_details_tab(each_pn).amount     :=  sp_metadata.getprice(l_part_number,  i_source);
      END IF;
   ELSE -- Added for if sales flag is not equal to zero
     io_part_number_details_tab(each_pn).amount     :=  sp_metadata.getprice(l_part_number,  i_source);
    END IF;
    --
  END LOOP;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of p_vas_proration_service 2 ' || SQLERRM;
END p_vas_proration_service;
--
-- CR49058 changes ends.
--
END sp_metadata;
/