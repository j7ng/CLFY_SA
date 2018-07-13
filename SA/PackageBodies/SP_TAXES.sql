CREATE OR REPLACE PACKAGE BODY sa."SP_TAXES"
IS
 --------------------------------------------------------------------------------------------
 --$RCSfile: SP_TAXES_PKB.sql,v $

   --$Revision: 1.119 $
  --$Author: mshah $
  --$Date: 2018/02/28 16:15:35 $
  --$ $Log: SP_TAXES_PKB.sql,v $
  --$ Revision 1.119  2018/02/28 16:15:35  mshah
  --$ CR55657 - Plans in APP not taxed properly
  --$
  --$ Revision 1.118  2018/02/21 15:26:20  mshah
  --$ CR55657 - Plans in APP not taxed properly
  --$
  --$ Revision 1.114  2018/02/01 22:36:16  abustos
  --$ CR55657 - applied function is_country_taxable
  --$
  --$ Revision 1.113  2018/01/31 22:17:33  mshah
  --$ CR55657 - Plans in APP not taxed properly
  --$
  --$ Revision 1.109  2017/10/04 15:09:07  sgangineni
  --$ CR49915 - handled null value for e911 amount
  --$
  --$ Revision 1.108  2017/10/03 23:26:12  sgangineni
  --$ CR49915 - Fix for defect#31371
  --$
  --$ Revision 1.107  2017/10/03 23:12:40  sgangineni
  --$ CR49915 - Fix for defect#31371
  --$
  --$ Revision 1.106  2017/10/03 21:02:28  sgangineni
  --$ CR49915 - Fix for defect#31368
  --$
  --$ Revision 1.105  2017/10/03 16:25:47  sgangineni
  --$ CR49915 - Merged with CR52959 changes
  --$
  --$ Revision 1.104  2017/10/03 16:10:06  sgangineni
  --$ CR49915 - Fix for defect#31330. Flipped the tax rules like 0 means skip and 1 means
  --$  apply tax on the discount amount
  --$
  --$ Revision 1.100  2017/08/22 16:33:05  sgangineni
  --$ Merged with CR52959 changes
  --$
  --$ Revision 1.99  2017/08/21 21:06:40  mtholkappian
  --$  CR52959 END USF and RCR Taxes Exception HANDLED NVL
  --$
  --$ Revision 1.91  2016/09/16 16:26:39  vnainar
  --$ CR43498 mapped tax rate columns for data plans
  --$
  --$ Revision 1.90  2016/09/15 22:37:31  vnainar
  --$ CR43498 updated for dataonly amount
  --$
  --$ Revision 1.88  2016/08/03 21:56:28  rpednekar
  --$ CR41745 - Modified error message in calctax procedures.
  --$
  --$ Revision 1.87  2016/08/02 21:17:11  rpednekar
  --$ CR41745 - Added input parameters to procedure calctax and used inside procedure.
  --$
  --$ Revision 1.86  2015/11/23 21:35:46  nmuthukkaruppan
  --$ ECR39519 -  Prod fix to pick the tangible comb rates from tpp_combstax column
  --$
  --$ Revision 1.85  2015/10/14 14:03:45  rpednekar
  --$ CR34623 - Changes done in calctax procedure
  --$
  --$ Revision 1.84  2015/10/12 18:25:11  rpednekar
  --$ CR37485
  --$
  --$ Revision 1.82  2015/07/21 17:26:29  arijal
  --$ CR33124 SL BYOP
  --$
  --$ Revision 1.81  2015/07/08 21:59:30  rpednekar
  --$ Reverted to rev 1.78
  --$
  --$ Revision 1.78  2015/06/30 20:40:52  rpednekar
  --$ Changes done for BRANCH.Branch_2015 - Defect # 3155 raised for CR 33056
  --$
  --$ Revision 1.77  2015/06/30 20:14:16  rpednekar
  --$ Changes done for BRANCH.Branch_2015 - Defect # 3155 raised for CR 33056
  --$
  --$ Revision 1.76  2015/06/22 15:42:50  rpednekar
  --$ Changes done by Rahul for CR33056.  Removed query and variables to get states.
  --$
  --$ Revision 1.75  2015/06/22 14:15:37  rpednekar
  --$ Changes done Rahul P for CR33056
  --$
  --$ Revision 1.74  2015/05/28 00:31:22  vsugavanam
  --$ CR34807
  --$
  --$ Revision 1.71  2015/05/22 13:53:36  pvenkata
  --$ CR
  --$
  --$ Revision 1.68  2015/05/19 18:50:01  pvenkata
  --$ Changes for the State Tax
  --$
  --$ Revision 1.66  2015/05/16 17:37:45  vyegnamurthy
  --$ Made changes to text card block
  --$
  --$ Revision 1.65  2015/05/15 16:23:00  vyegnamurthy
  --$ Added the logic not to charge USF and RCR for txt only card
  --$
  --$ Revision 1.64  2015/05/14 14:32:48  vmadhawnadella
  --$ fixed tax for DATA and TEXT card.
  --$
  --$ Revision 1.60  2015/05/07 01:57:16  vmadhawnadella
  --$ CR-TAXES
  --$
  --$ Revision 1.59  2015/04/17 22:03:24  vmadhawnadella
  --$ ADD LOGIC  FOR $10.00 TEXT ONLY CARD.
  --$
  --$ Revision 1.57  2015/04/15 14:35:04  vmadhawnadella
  --$ ADD LOGIC  FOR $10.00 TEXT ONLY CARD.
  --$
  --$ Revision 1.56  2015/04/14 23:01:33  vmadhawnadella
  --$ ADD LOGIC  FOR $10.00 TEXT ONLY CARD.
  --$
  --$ Revision 1.55  2015/04/06 20:29:04  oarbab
  --$ CR33407_B2B_Tax_Calculation Added New function Computetax3(v_zip, NULL)
  --$
  --$ Revision 1.54  2015/02/24 15:34:15  oarbab
  --$ CR32306 added replace function per Rosseta and SOA request.
  --$
  --$ Revision 1.53  2015/02/18 20:04:30  oarbab
  --$ CR31683 removed CDATA tags.
  --$
  --$ Revision 1.52  2015/02/17 20:35:33  oarbab
  --$ CR31683 handle no zipcode but count is more than zero.
  --$
  --$ Revision 1.51  2015/02/17 17:59:37  oarbab
  --$ CR31683 added more decode options for language
  --$
  --$ Revision 1.50  2015/02/13 19:29:17  oarbab
  --$ cr31683 updated the error message in get_tax_script procedure
  --$
  --$ Revision 1.49  2015/02/13 16:26:26  oarbab
  --$ CR31683 UPATED ip parameters and object type column names
  --$
  --$ Revision 1.47  2015/02/11 22:54:26  oarbab
  --$ cr31683 updated def table in in get_tax_script
  --$
  --$ Revision 1.45  2015/01/20 19:10:34  vkashmire
  --$ CR29021 - safelink e911
  --$
  --$ Revision 1.44  2015/01/19 22:06:37  vkashmire
  --$ CR29021 safelink e911 tax calculation
  --$
  --$ Revision 1.43  2014/12/15 16:14:46  icanavan
  --$ added a second cursor for tax calculations and put 2 functions in that are used for recuring plans
  --$
  --$ Revision 1.41  2014/08/28 21:45:38  dtunk
  --$ Added logic to handle DIGITAL SALES , ANCILLARY SALES
  --$
  --$ Revision 1.40  2014/08/18 20:32:19  cpannala
  --$ CR30255 Defect 179 fixes
  --$
  --$ Revision 1.39  2014/08/04 15:58:17  cpannala
  --$ CR30096 Amount can be Zero for the line items in b2c.
  --$
  --$ Revision 1.38  2014/07/07 14:46:01  cpannala
  --$ CR29468 Claculate Taxes has modified for device tax rates
  --$
  --$ Revision 1.37  2014/06/27 17:54:19  cpannala
  --$ CR29467 Changes made for B2B devcie taxes
  --$
  --$ Revision 1.36  2014/06/04 20:54:49  icanavan
  --$ FIX CALC TAX IN TX
  --$
  --$ Revision 1.35  2014/04/24 22:28:38  cpannala
  --$ CR25490
  --$
  --$ Revision 1.34  2014/04/16 21:29:27  icanavan
  --$ FIX CALULATION OF MODEL TAX
  --$
  --$ Revision 1.33  2014/04/12 20:16:38  icanavan
  --$ added logic for new sales columns
  --$
  --$ Revision 1.32  2014/04/02 00:03:55  icanavan
  --$ ADDED RULES FOR MODELS
  --$
  --$ Revision 1.25  2013/11/20 20:38:40  mvadlapally
  --$ CR26274
  --$
  --$ Revision 1.24  2013/11/20 14:29:00  mvadlapally
  --$ CR26274
  --$
  --$ Revision 1.23  2013/11/20 00:00:33  mvadlapally
  --$ CR26274
  --$
  --$ Revision 1.22  2013/10/31 21:25:47  icanavan
  --$ ADDED DATA ONLY RATE
  --$
  --$ Revision 1.21  2013/05/23 15:27:40  ymillan
  --$ CR22860 add nvl check input parameters
  --$
  --$ Revision 1.20  2013/05/22 21:03:07  ymillan
  --$ CR22860
  --$
  --$ Revision 1.19  2013/05/21 20:21:27  ymillan
  --$ CR22860
  --$
  --$ Revision 1.18  2012/12/11 17:31:27  mmunoz
  --$ CR22380 Handset Protection (Master CR18994)
  --$
  --$ Revision 1.17  2012/11/29 17:03:44  mmunoz
  --$ CR22380 : Added function get_combstax and updated Calctax. Not apply the X_NON_SALES logic for Handsets
  --$
  --$ Revision 1.16  2012/11/08 22:15:26  mmunoz
  --$ CR22380 : Modified CalcTax
  --$
  --$ Revision 1.15  2012/10/31 21:48:26  mmunoz
  --$ CR22380: Commented the code that is not being used (regression testing considered)
  --$
  --$ Revision 1.14  2012/10/29 14:56:37  mmunoz
  --$ CR22380 : Added semicolon
  --$
  --$ Revision 1.13  2012/10/24 15:25:24  mmunoz
  --$ CR22380 : Changes merged with rv1.12. Added logic to calculate warranty taxes
  --$
  --------------------------------------------------------------------------------------------
  /**********************************************************************************************************************************
  * Package Name: sp_taxes
  * Description: The package is called by  Clarify
  *              to get taxes calculation for Part number
  *
  * Created by: YM
  * Date:  10/07/2010
  *
  * History
  * ------------------------------------------------------------------------------------------------------------------------------------------------------------
  * 10/07/2010          YM                 Initial Version                 CR11553
  * 03/11/2011          YM                 added b2b                      CR11553
  * 04/26/2011          YM                change prc get_script     CR14282
  * 06/08/2011          YM                add round(x,2) subtotal amount in calctax and calctax_b2b CR16392
  * 07/20/2011          Skuthadi          CR17182 update c_tax_service in TAX_SERVICE to handle PARENT_OBJID NULL
  * 07/20/2012          ICanavan          CR20451 | CR20854: Add TELCEL Brand
  *********************************************************************************************************************************/

  --CR18994 CR22380 Handset Protection Program - Phase I  New Function get_combstax added
  CURSOR CUR_ZIP_PYMT_SRC(p_pe_payment_source IN NUMBER )
  IS
    SELECT ADR.ZIPCODE
    FROM TABLE_ADDRESS ADR,
      TABLE_COUNTRY CNTR,
      TABLE_X_BANK_ACCOUNT BANK,
      X_PAYMENT_SOURCE PYMTSRC
    WHERE ADR.OBJID      = BANK.X_BANK_ACCT2ADDRESS
    AND CNTR.OBJID(+)    = ADR.ADDRESS2COUNTRY
    AND BANK.OBJID       = PYMTSRC.PYMT_SRC2X_BANK_ACCOUNT
    AND BANK.X_STATUS    = 'ACTIVE'
    AND PYMTSRC.X_STATUS = 'ACTIVE'
    AND PYMTSRC.OBJID    = p_pe_payment_source
  UNION
  SELECT ADR.ZIPCODE
  FROM TABLE_ADDRESS ADR,
    TABLE_COUNTRY CNTR,
    TABLE_X_CREDIT_CARD CC,
    X_PAYMENT_SOURCE PYMTSRC
  WHERE ADR.OBJID      = CC.X_CREDIT_CARD2ADDRESS
  AND CNTR.OBJID(+)    = ADR.ADDRESS2COUNTRY
  AND CC.OBJID         = PYMTSRC.PYMT_SRC2X_CREDIT_CARD
  AND CC.X_CARD_STATUS = 'ACTIVE'
  AND PYMTSRC.X_STATUS = 'ACTIVE'
  AND PYMTSRC.OBJID    = p_pe_payment_source ;
  CURSOR CUR_ZIP_WEB_USER (WEB_USER_OBJID IN NUMBER)
  IS
    SELECT ADDRESS.ZIPCODE
    FROM TABLE_ADDRESS ADDRESS,
      TABLE_COUNTRY CNTR,
      TABLE_X_CREDIT_CARD CREDIT,
      MTM_CONTACT46_X_CREDIT_CARD3 MTMCC,
      X_PAYMENT_SOURCE pymt,
      TABLE_WEB_USER WEB
    WHERE CREDIT.X_CREDIT_CARD2ADDRESS  = ADDRESS.OBJID
    AND CNTR.OBJID(+)                   = ADDRESS.ADDRESS2COUNTRY
    AND CREDIT.X_CARD_STATUS            = 'ACTIVE'
    AND CREDIT.OBJID                    = MTMCC.MTM_CREDIT_CARD2CONTACT
    AND mtm_credit_card2contact         = pymt.PYMT_SRC2X_CREDIT_CARD
    AND MTMCC.MTM_CONTACT2X_CREDIT_CARD = WEB.WEB_USER2CONTACT
    AND PYMT.X_STATUS                   = 'ACTIVE'
    AND PYMT_SRC2WEB_USER               = WEB.OBJID
    AND WEB.OBJID                       = WEB_USER_OBJID
  UNION
  SELECT ADDRESS.ZIPCODE
  FROM TABLE_ADDRESS ADDRESS,
    TABLE_COUNTRY CNTR,
    TABLE_X_BANK_ACCOUNT BANK,
    X_PAYMENT_SOURCE pymt,
    TABLE_WEB_USER WEB
  WHERE BANK.X_BANK_ACCT2ADDRESS = ADDRESS.OBJID
  AND CNTR.OBJID(+)              = ADDRESS.ADDRESS2COUNTRY
  AND BANK.X_STATUS              = 'ACTIVE'
  AND BANK.OBJID                 = PYMT.PYMT_SRC2X_BANK_ACCOUNT
  AND PYMT.X_STATUS              = 'ACTIVE'
  AND PYMT_SRC2WEB_USER          = WEB.OBJID
  AND WEB.OBJID                  = WEB_USER_OBJID;
  L_ZIP TABLE_ADDRESS.ZIPCODE%TYPE ;
FUNCTION get_combstax(
    p_zipcode IN VARCHAR2 )
  RETURN NUMBER
IS
  l_sales_tax NUMBER;
BEGIN
  SELECT NVL(MAX (x_combstax), 0)
  INTO l_sales_tax
  FROM table_x_sales_tax
  WHERE 1       = 1
  AND x_zipcode = p_zipcode
  AND x_eff_dt  < SYSDATE ;
  RETURN NVL (ROUND(l_sales_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END GET_COMBSTAX;
--CR22860 HPP Invoice New Function
FUNCTION computeCWGtax(
    p_zipcode IN VARCHAR2 )
  RETURN NUMBER
IS
  l_cwg_tax table_x_sales_tax.X_CWG_TAX%type; --cambiar column name
BEGIN
  SELECT *
  INTO l_cwg_tax
  FROM
    (SELECT NVL (MAX (X_CWG_TAX), 0) --cambiar column name
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  -- pick up the first record only
  RETURN NVL (ROUND (l_cwg_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END COMPUTECWGTAX;
--CR18994 CR22380 Handset Protection Program - Phase I  New Function computeWTYtax added Begin
FUNCTION computeWTYtax(
    p_zipcode IN VARCHAR2 )
  RETURN NUMBER
IS
  l_wty_tax table_x_sales_tax.x_wty_tax%type;
BEGIN
  SELECT *
  INTO l_wty_tax
  FROM
    (SELECT NVL (MAX (X_WTY_TAX), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  -- pick up the first record only
  RETURN NVL (ROUND (l_wty_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END computeWTYtax;
--CR22380 Handset Protection New function is_pgmMONFEE_EXCLUDED_tax_calc added
FUNCTION is_pgmMONFEE_EXCLUDED_tax_calc(
    ip_pp_objid    IN X_PROGRAM_PARAMETERS.objid%type,
    ip_param_name  IN table_x_part_class_params.x_param_name%type,
    ip_param_value IN table_x_part_class_values.X_PARAM_VALUE%type )
  RETURN BOOLEAN
IS
  v_flag   BOOLEAN := FALSE;
  v_cnt    NUMBER  := 0;
  v_pn_cnt NUMBER  := 0 ; -- CR26274
BEGIN
  SELECT COUNT(*) n_amount
  INTO v_cnt
  FROM x_program_parameters pp ,
    table_part_num pn ,
    table_part_class pc ,
    pc_params_view pcv
  WHERE pp.objid             = NVL(ip_pp_objid,-1)
  AND pn.objid               = PP.PROG_PARAM2PRTNUM_MONFEE
  AND pn.part_num2part_class = pc.objid
  AND pcv.part_class         = pc.name
  AND pcv.param_name         = ip_param_name
  AND pcv.param_value        = ip_param_value ;
  IF v_cnt                   > 0 THEN
    DBMS_OUTPUT.put_line('EXCLUDE TAX CALCULATION');
    v_flag := TRUE;
  ELSE
    -- CR26274
    SELECT COUNT (pn.objid)
    INTO v_pn_cnt
    FROM table_part_num pn,
      x_program_parameters pp
    WHERE pn.objid      = pp.prog_param2prtnum_monfee
    and pn.x_card_type in ('DATA CARD','TEXT ONLY') -- CR32572
   -- AND (pn.x_card_type = 'DATA CARD'
      -- OR pn.s_description LIKE '%BROAD%' CR27269 REMOVE THIS DONT PUT BACK
   --   )
    AND pp.objid = NVL(ip_pp_objid,-1); --5801544
    IF v_pn_cnt  > 0 THEN
      DBMS_OUTPUT.put_line('EXCLUDE TAX CALCULATION');
      v_flag := TRUE;
    END IF;
  END IF;
  RETURN v_flag;
END;
--CR26033 / CR26274
FUNCTION computeDTAtax(
    p_zipcode IN VARCHAR2 )
  RETURN VARCHAR2
IS
  l_DATA_NON_SALES NUMBER ;
  l_X_STATE        VARCHAR2(2) ;
BEGIN
  SELECT x_data_non_sales,
    x_state
  INTO l_DATA_NON_SALES,
    l_X_STATE
  FROM table_x_sales_tax
  WHERE x_zipcode      = p_zipcode
  AND x_eff_dt         < SYSDATE
  AND x_data_non_sales = 0 -- CR26033 ADDED THIS changed name fro x_dataonly_tax
  AND ROWNUM           < 2;
  IF l_DATA_NON_SALES  = 1 THEN
    RETURN 'NO DATA TAX' ;
  ELSE
    IF l_X_STATE = 'TX' THEN
      RETURN 'SALES TAX TEXAS' ;
    ELSE
      RETURN 'SALES TAX ONLY' ;
    END IF ;
  END IF ;
EXCEPTION
WHEN OTHERS THEN
  RETURN '0';
END computeDTAtax;
--CR26033 / CR26274


--CR27857
FUNCTION computeNONSHIPtax(
    p_zipcode IN VARCHAR2 )
  RETURN NUMBER
IS
  l_nonship_tax table_x_sales_tax.x_non_shipping%type;
BEGIN
  SELECT *
  INTO l_nonship_tax
  FROM
    (SELECT NVL (MAX (X_COMBSTAX), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode    = p_zipcode
    AND x_eff_dt       < SYSDATE
    AND x_non_shipping = 0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL (ROUND (l_nonship_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END computeNONSHIPtax;
--CR27857 end

--CR53102 New function to get the tax_rate for shipping
FUNCTION computeSHIPPINGtax (p_zipcode IN VARCHAR2)
  RETURN NUMBER
IS
  l_shipping_tax table_x_sales_tax.tpp_combtax%type;
BEGIN

  SELECT *
    INTO l_shipping_tax
  FROM  (SELECT NVL(MAX(tpp_combtax), 0)
         FROM   table_x_sales_tax
         WHERE  x_zipcode      = p_zipcode
           AND  x_eff_dt       < SYSDATE
           AND  x_non_shipping = 0
         ORDER BY x_eff_dt DESC)
  WHERE ROWNUM < 2;

  RETURN NVL(ROUND(l_shipping_tax, 4), 0);

EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END computeSHIPPINGtax;
--CR53102 End

--CR27269
FUNCTION computeMODELtax(
    p_zipcode    IN VARCHAR2,
    P_MODEL_TYPE IN VARCHAR2 )
  RETURN NUMBER
IS
  l_MODEL_tax table_x_sales_tax.x_home_alert_non_sales%type;
BEGIN
  IF P_MODEL_TYPE='HOME ALERT' THEN
    SELECT *
    INTO l_model_tax
    FROM
      (SELECT NVL (MAX (X_COMBSTAX), 0) -- CR26033 CHANGED THIS WAS USING X_DATA_ONLY FIELD BEFORE
      FROM table_x_sales_tax
      WHERE x_zipcode            = p_zipcode
      AND x_eff_dt               < SYSDATE
      AND x_home_alert_non_sales = 0 -- CR26033 ADDED THIS changed name fro x_dataonly_tax
      ORDER BY x_eff_dt DESC
      )
    WHERE ROWNUM < 2;
  END IF ;
  IF P_MODEL_TYPE='CAR CONNECT' THEN
    SELECT *
    INTO l_model_tax
    FROM
      (SELECT NVL (MAX (X_COMBSTAX), 0) -- CR26033 CHANGED THIS WAS USING X_DATA_ONLY FIELD BEFORE
      FROM table_x_sales_tax
      WHERE x_zipcode             = p_zipcode
      AND x_eff_dt                < SYSDATE
      AND X_CAR_CONNECT_NON_SALES = 0 -- CR26033 ADDED THIS changed name fro x_dataonly_tax
      ORDER BY x_eff_dt DESC
      )
    WHERE ROWNUM < 2;
  END IF ;
  -- Added for Mobile billing CR24413 - DIGITAL GOODS
  IF P_MODEL_TYPE='DIGITAL GOODS' THEN
    SELECT *
    INTO l_model_tax
    FROM
      (SELECT NVL (MAX (X_COMBSTAX), 0)
      FROM table_x_sales_tax
      WHERE x_zipcode         = p_zipcode
      AND x_eff_dt            < SYSDATE
      AND x_digital_non_sales = 0
      ORDER BY x_eff_dt DESC
      )
    WHERE ROWNUM < 2;
  END IF ;
  -- Added for Mobile billing CR24413 - ANCILLARY TELECOM SERVICE
  IF P_MODEL_TYPE='ANCILLARY TELECOM SERVICE' THEN
    SELECT *
    INTO l_model_tax
    FROM
      (SELECT NVL (MAX (X_COMBSTAX), 0)
      FROM table_x_sales_tax
      WHERE x_zipcode           = p_zipcode
      AND x_eff_dt              < SYSDATE
      AND X_ANCILLARY_NON_SALES = 0
      ORDER BY x_eff_dt DESC
      )
    WHERE ROWNUM < 2;
  END IF ;
  RETURN NVL (ROUND (l_MODEL_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END computeMODELtax ;
--CR27269 end
FUNCTION Computetax(
    p_webuser_objid IN NUMBER,
    p_program_param IN NUMBER,
    p_esn           IN VARCHAR2 )
  RETURN NUMBER
IS
  l_sales_tax NUMBER;
  l_zip_code table_contact.zipcode%TYPE;
  l_count NUMBER;
  l_prog_sales_tax_flag x_program_parameters.x_sales_tax_flag%TYPE;
  l_prog_sales_tax_cust x_program_parameters.x_sales_tax_charge_cust%TYPE;
  l_prog_add_tax1 x_program_parameters.x_additional_tax1%TYPE := 0;
  l_prog_add_tax2 x_program_parameters.x_additional_tax2%TYPE := 0;
  bcomputesalestaxflag BOOLEAN;
  V_TAX_SERVICE        NUMBER;
  ----CR13581
  CURSOR Tax_Exempt_Cur
  IS
    SELECT '1'
    FROM X_PROGRAM_ENROLLED,
      X_BUSINESS_ACCOUNTS,
      TABLE_WEB_USER
    WHERE PGM_ENROLL2WEB_USER   = TABLE_WEB_USER.OBJID
    AND BUS_PRIMARY2CONTACT     = WEB_USER2CONTACT
    AND NVL(TAX_EXEMPT,'false') = 'true'
    AND X_Esn                   = P_Esn;
  tax_exempt_rec tax_exempt_cur%rowtype; ----CR13581
  v_WtyTax NUMBER;                         --CR18994 CR22380 Calculate Warranty Taxes
  v_DtaTax NUMBER;                         --CR26033 / CR26274

BEGIN
  -- B2B Tax Exempt ----CR13581
  OPEN Tax_Exempt_Cur;
  FETCH Tax_Exempt_Cur INTO Tax_Exempt_Rec;
  IF Tax_Exempt_Cur%Found THEN
    CLOSE Tax_Exempt_Cur;
    RETURN 0;
  ELSE
    CLOSE Tax_Exempt_Cur;
  END IF; ----CR13581
  -- Check if the program permits taxation.
  IF (p_program_param IS NOT NULL) THEN
    SELECT x_sales_tax_flag,
      x_sales_tax_charge_cust,
      x_additional_tax1,
      x_additional_tax2
    INTO l_prog_sales_tax_flag,
      l_prog_sales_tax_cust,
      l_prog_add_tax1,
      l_prog_add_tax2
    FROM x_program_parameters
    WHERE objid               = p_program_param;
    IF (l_prog_sales_tax_flag = 1) AND (l_prog_sales_tax_cust = 1) THEN
      NULL;
      -- We need to compute sales tax for this scenario.
    ELSE
      RETURN 0;
      -- No tax needs to be computed.
    END IF;
  END IF;
  SELECT zipcode
  INTO l_zip_code
  FROM table_contact con,
    table_web_user web
  WHERE web.web_user2contact = con.objid
  AND web.objid              = p_webuser_objid;
  -----
  -- V_TAX_SERVICE := TAX_SERVICE(p_esn); CR11553
  SELECT NVL (MAX (x_combstax), 0)
  INTO l_sales_tax
  FROM table_x_sales_tax
  WHERE 1         = 1
  AND x_zipcode   = l_zip_code
  AND x_eff_dt    < SYSDATE
  AND x_non_sales =0;
  --CR18994 CR22380 Calculate Warranty Taxes and added if /Else begin
  IF is_pgmMONFEE_EXCLUDED_tax_calc(p_program_param,'TAX_CALCULATION','HS_WARRANTY') THEN
    v_WtyTax := ComputeWTYtax(l_zip_code)*get_combstax(l_zip_code);
    RETURN NVL (ROUND(v_WtyTax, 4), 0);
  ELSE
    RETURN NVL (ROUND(l_sales_tax, 4), 0);
  END IF;
  --CR18994 CR22380 Calculate Warranty Taxes end
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;
FUNCTION computetax2(
    p_zipcode IN VARCHAR2,
    p_esn     IN VARCHAR2 )
  RETURN NUMBER
IS
  l_sales_tax NUMBER;
  CURSOR Tax_Exempt_Cur
  IS
    SELECT '1'
    FROM X_PROGRAM_ENROLLED,
      X_BUSINESS_ACCOUNTS,
      TABLE_WEB_USER
    WHERE PGM_ENROLL2WEB_USER   = TABLE_WEB_USER.OBJID
    AND BUS_PRIMARY2CONTACT     = WEB_USER2CONTACT
    AND NVL(TAX_EXEMPT,'false') = 'true'
    AND X_Esn                   = P_Esn;
  tax_exempt_rec tax_exempt_cur%rowtype; ----CR13581
BEGIN
  -- B2B Tax Exempt   ----CR13581
  OPEN Tax_Exempt_Cur;
  FETCH Tax_Exempt_Cur INTO Tax_Exempt_Rec;
  IF Tax_Exempt_Cur%Found THEN
    CLOSE Tax_Exempt_Cur;
    RETURN 0;
  ELSE
    CLOSE Tax_Exempt_Cur;
  END IF;
  SELECT NVL(MAX (x_combstax), 0)
  INTO l_sales_tax
  FROM table_x_sales_tax
  WHERE 1         = 1
  AND x_zipcode   = p_zipcode
  AND x_eff_dt    < SYSDATE
  AND x_non_sales =0;
  RETURN NVL (ROUND(l_sales_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;
----------------- START OF CR33047 ---------------
FUNCTION computetax3(
    p_zipcode IN VARCHAR2,
    p_esn     IN VARCHAR2 )
  RETURN NUMBER
IS
  l_sales_tax NUMBER;
  CURSOR Tax_Exempt_Cur
  IS
    SELECT '1'
    FROM X_PROGRAM_ENROLLED,
      X_BUSINESS_ACCOUNTS,
      TABLE_WEB_USER
    WHERE PGM_ENROLL2WEB_USER   = TABLE_WEB_USER.OBJID
    AND BUS_PRIMARY2CONTACT     = WEB_USER2CONTACT
    AND NVL(TAX_EXEMPT,'false') = 'true'
    AND X_Esn                   = P_Esn;
  tax_exempt_rec tax_exempt_cur%rowtype; ----CR13581
BEGIN
  -- B2B Tax Exempt   ----CR13581
  OPEN Tax_Exempt_Cur;
  FETCH Tax_Exempt_Cur INTO Tax_Exempt_Rec;
  IF Tax_Exempt_Cur%Found THEN
    CLOSE Tax_Exempt_Cur;
    RETURN 0;
  ELSE
    CLOSE Tax_Exempt_Cur;
  END IF;

  SELECT NVL(MAX (tpp_combtax), 0)  -- EME CR39519 to pick tangible comb rates from tpp_combstax - new column--
  INTO l_sales_tax
  FROM table_x_sales_tax
  WHERE 1         = 1
  AND x_zipcode   = p_zipcode
  AND x_eff_dt    < SYSDATE;
--AND x_non_sales =0;CR33047 Removed flag realted
                     --to aritime for phones tax

  RETURN NVL (ROUND(l_sales_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;
------------------- END OF CR33047 ---------------
-- New Function Added for CR6283 .. Ramu
FUNCTION computee911tax(
    p_webuser_objid IN NUMBER,
    p_program_param IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_e911_tax NUMBER;
  l_zip_code table_contact.zipcode%TYPE;
  l_count NUMBER;
  l_prog_e911_tax_flag x_program_parameters.x_e911_tax_flag%TYPE;
  l_prog_e911_tax_cust x_program_parameters.x_e911_tax_charge_cust%TYPE;
  bcomputee911taxflag BOOLEAN;
  V_TAX_SERVICE       NUMBER;
BEGIN
  -- Check if the program permits taxation.
  IF (p_program_param IS NOT NULL) THEN
    SELECT x_e911_tax_flag,
      x_e911_tax_charge_cust
    INTO l_prog_e911_tax_flag,
      l_prog_e911_tax_cust
    FROM x_program_parameters
    WHERE objid              = p_program_param;
    IF (l_prog_e911_tax_flag = 1) AND (l_prog_e911_tax_cust = 1) THEN
      NULL;
      -- We need to compute sales tax for this scenario.
    ELSE
      RETURN 0;
      -- No tax needs to be computed.
    END IF;
  END IF;
  SELECT zipcode
  INTO l_zip_code
  FROM table_contact con,
    table_web_user web
  WHERE web.web_user2contact = con.objid
  AND web.objid              = p_webuser_objid;
  -- V_TAX_SERVICE := TAX_SERVICE(p_esn); CR11553
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911rate), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = l_zip_code
    AND x_eff_dt    < SYSDATE
      -- AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  -- Not required to Add AdditionalTax1 and AdditionalTax2 fields
  RETURN NVL (ROUND (l_e911_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeE911tax
-- New Function Added for STUL
FUNCTION computee911tax2(
    p_zipcode IN VARCHAR2
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_e911_tax NUMBER;
BEGIN
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911rate), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
      --  AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL (ROUND (l_e911_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeE911tax2
FUNCTION computee911surcharge(
    p_webuser_objid IN NUMBER,
    p_program_param IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_e911_tax NUMBER;
  l_zip_code table_contact.zipcode%TYPE;
  l_count NUMBER;
  l_prog_e911_tax_flag x_program_parameters.x_e911_tax_flag%TYPE;
  l_prog_e911_tax_cust x_program_parameters.x_e911_tax_charge_cust%TYPE;
  bcomputee911taxflag BOOLEAN;
  V_TAX_SERVICE       NUMBER;
BEGIN
  -- Check if the program permits taxation.
  IF (p_program_param IS NOT NULL) THEN
    SELECT x_e911_tax_flag,
      X_E911_TAX_CHARGE_CUST
    INTO l_prog_e911_tax_flag,
      l_prog_e911_tax_cust
    FROM x_program_parameters
    WHERE objid              = p_program_param;
    IF (l_prog_e911_tax_flag = 1) AND (l_prog_e911_tax_cust = 1) THEN
      NULL;
      -- We need to compute sales tax for this scenario.
    ELSE
      RETURN 0;
      -- No tax needs to be computed.
    END IF;
  END IF;
  SELECT zipcode
  INTO l_zip_code
  FROM table_contact con,
    table_web_user web
  WHERE web.web_user2contact = con.objid
  AND web.objid              = p_webuser_objid;
  --V_TAX_SERVICE := TAX_SERVICE(p_esn); CR22380 removing ESN
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911surcharge), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = l_zip_code
    AND x_eff_dt    < SYSDATE
      -- AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  -- Not required to Add AdditionalTax1 and AdditionalTax2 fields
  RETURN NVL (ROUND (l_e911_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeE911taxsurcharge
-- New Function Added for STUL
FUNCTION computee911surcharge2(
    p_zipcode IN VARCHAR2
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_e911_tax NUMBER;
BEGIN
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911surcharge), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
      --  AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL (ROUND(l_e911_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeE911taxsurcharge2
--New function Added for e911 fee for each state
FUNCTION computee911surcharge3(
    p_state IN VARCHAR2
  )
  RETURN NUMBER
IS
  l_e911_tax NUMBER;
BEGIN
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911surcharge), 0)
    FROM table_x_sales_tax
    WHERE x_state = p_state
    AND x_eff_dt    < SYSDATE
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL (ROUND(l_e911_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of --New function Added for e911 fee for each state
FUNCTION computee911note(
    p_webuser_objid IN NUMBER,
    p_program_param IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN VARCHAR2
IS
  l_e911_tax VARCHAR2(255);
  l_zip_code table_contact.zipcode%TYPE;
  l_count NUMBER;
  l_prog_e911_tax_flag x_program_parameters.x_e911_tax_flag%TYPE;
  l_prog_e911_tax_cust x_program_parameters.x_e911_tax_charge_cust%TYPE;
  bcomputee911taxflag BOOLEAN;
  V_TAX_SERVICE       NUMBER;
BEGIN
  -- Check if the program permits taxation.
  IF (p_program_param IS NOT NULL) THEN
    SELECT x_e911_tax_flag,
      X_E911_TAX_CHARGE_CUST
    INTO l_prog_e911_tax_flag,
      l_prog_e911_tax_cust
    FROM x_program_parameters
    WHERE objid              = p_program_param;
    IF (l_prog_e911_tax_flag = 1) AND (l_prog_e911_tax_cust = 1) THEN
      NULL;
      -- We need to compute sales tax for this scenario.
    ELSE
      RETURN 0;
      -- No tax needs to be computed.
    END IF;
  END IF;
  SELECT zipcode
  INTO l_zip_code
  FROM table_contact con,
    table_web_user web
  WHERE web.web_user2contact = con.objid
  AND web.objid              = p_webuser_objid;
  --    V_TAX_SERVICE := TAX_SERVICE(p_esn); cr11553
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911NOTE), ' ')
    FROM table_x_sales_tax
    WHERE x_zipcode = l_zip_code
    AND x_eff_dt    < SYSDATE
      -- and x_non_sales = 0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  -- Not required to Add AdditionalTax1 and AdditionalTax2 fields
  RETURN NVL(l_e911_tax, ' ');
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeE911taxsurcharge
FUNCTION computee911note2(
    p_zipcode IN VARCHAR2
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN VARCHAR2
IS
  l_e911_tax VARCHAR2(255);
BEGIN
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911NOTE), ' ')
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
      --   and x_non_sales = 0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL(l_e911_tax, ' ');
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeE911taxsurcharge2
FUNCTION computeUSFtax(
    p_webuser_objid IN NUMBER,
    p_program_param IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_usf_tax NUMBER;
  l_zip_code table_contact.zipcode%TYPE;
  l_count NUMBER;
  --l_prog_e911_tax_flag x_program_parameters.x_e911_tax_flag%TYPE;
  --l_prog_e911_tax_cust x_program_parameters.x_e911_tax_charge_cust%TYPE;
  bcomputee911taxflag BOOLEAN;
  -- V_TAX_SERVICE NUMBER; CR11553
BEGIN
  /*-- Check if the program permits taxation.
  IF (p_program_param
  IS
  NOT NULL)
  THEN
  SELECT x_e911_tax_flag,
  x_e911_tax_charge_cust
  INTO l_prog_e911_tax_flag, l_prog_e911_tax_cust
  FROM x_program_parameters
  WHERE objid = p_program_param;
  IF (l_prog_e911_tax_flag = 1)
  AND (l_prog_e911_tax_cust = 1)
  THEN
  NULL;
  -- We need to compute sales tax for this scenario.
  ELSE
  RETURN 0;
  -- No tax needs to be computed.
  END IF;
  END IF;*/
  --CR22380 Handset Protection if / else added
  IF is_pgmMONFEE_EXCLUDED_tax_calc(p_program_param,'TAX_CALCULATION','HS_WARRANTY') THEN
    l_usf_tax := 0;
  ELSE
    SELECT zipcode
    INTO l_zip_code
    FROM table_contact con,
      table_web_user web
    WHERE web.web_user2contact = con.objid
    AND web.objid              = p_webuser_objid;
    /* V_TAX_SERVICE := TAX_SERVICE(p_esn);
    IF V_TAX_SERVICE = 1
    THEN
    SELECT *
    INTO l_usf_tax
    FROM (
    SELECT NVL (MAX (X_ALT_usf_taxRATE), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = l_zip_code
    AND x_eff_dt < SYSDATE
    ORDER BY x_eff_dt DESC)
    WHERE ROWNUM < 2;
    -- pick up the first record only
    ELSE CR11553 */
    SELECT *
    INTO l_usf_tax
    FROM
      (SELECT NVL (MAX (x_usf_taxrate), 0)
      FROM table_x_sales_tax
      WHERE x_zipcode = l_zip_code
      AND x_eff_dt    < SYSDATE
      ORDER BY x_eff_dt DESC
      )
    WHERE ROWNUM < 2;
    -- pick up the first record only
    -- END IF; cr11553
  END IF; --CR22380 Handset Protection if / else added
  RETURN NVL (ROUND (l_usf_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeUSFtax
FUNCTION computeUSFtax2(
    p_zipcode IN VARCHAR2
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_usf_tax NUMBER;
BEGIN
  SELECT *
  INTO l_usf_tax
  FROM
    (SELECT NVL (MAX (x_usf_taxrate), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
      --    and x_non_sales = 0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL (ROUND (l_usf_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeUSFtax2
FUNCTION computeMISCtax(
    p_webuser_objid IN NUMBER,
    p_program_param IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_misc_tax NUMBER;
  l_zip_code table_contact.zipcode%TYPE;
  l_count             NUMBER;
  bcomputee911taxflag BOOLEAN;
  -- V_TAX_SERVICE NUMBER; CR11553
BEGIN
  --CR22380 Handset Protection if / else added
  IF is_pgmMONFEE_EXCLUDED_tax_calc(p_program_param,'TAX_CALCULATION','HS_WARRANTY') THEN
    l_misc_tax := 0;
  ELSE
    SELECT zipcode
    INTO l_zip_code
    FROM table_contact con,
      table_web_user web
    WHERE web.web_user2contact = con.objid
    AND web.objid              = p_webuser_objid;
    --  V_TAX_SERVICE := TAX_SERVICE(p_esn); CR11553
    SELECT *
    INTO l_misc_tax
    FROM
      (SELECT NVL (MAX (X_RCRFRATE), 0) --change name for cr11553
      FROM table_x_sales_tax
      WHERE x_zipcode = l_zip_code
      AND x_eff_dt    < SYSDATE
        --and x_non_sales = 0
      ORDER BY x_eff_dt DESC
      )
    WHERE ROWNUM < 2;
    -- pick up the first record only
  END IF; --CR22380 Handset Protection if / else added
  RETURN NVL (ROUND (l_misc_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeMISCtax
FUNCTION computeMISCtax2(
    p_zipcode IN VARCHAR2
    --p_esn IN VARCHAR2
  )
  RETURN NUMBER
IS
  l_misc_tax NUMBER;
BEGIN
  SELECT *
  INTO l_misc_tax
  FROM
    (SELECT NVL (MAX (X_RCRFRATE), 0) --change name for cr11553
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
      -- and x_non_sales = 0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  -- pick up the first record only
  RETURN NVL (ROUND (l_misc_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeMISCtax2
PROCEDURE INSERT_TAXES(
    IP_X_ZIPCODE       IN VARCHAR2,
    IP_X_CITY          IN VARCHAR2,
    IP_X_COUNTY        IN VARCHAR2,
    IP_X_STATE         IN VARCHAR2,
    IP_X_CNTYDEF       IN VARCHAR2,
    IP_X_DEFAULT       IN VARCHAR2,
    IP_X_CNTYFIPS      IN VARCHAR2,
    IP_X_STATESTAX     IN NUMBER,
    IP_X_CNTSTAX       IN NUMBER,
    IP_X_CNTLCLSTAX    IN NUMBER,
    IP_X_CTYSTAX       IN NUMBER,
    IP_X_CTYLCLSTAX    IN NUMBER,
    IP_X_COMBSTAX      IN NUMBER,
    IP_X_EFF_DT        IN DATE,
    IP_X_GEOCODE       IN VARCHAR2,
    IP_X_INOUT         IN VARCHAR2,
    IP_X_E911FOOT      IN VARCHAR2,
    IP_X_E911NOTE      IN VARCHAR2,
    IP_X_E911RATE      IN NUMBER,
    IP_X_E911SURCHARGE IN NUMBER,
    IP_X_USF_TAXRATE   IN NUMBER,
    IP_X_NON_SALES     IN NUMBER,
    Op_result OUT NUMBER,
    Op_Msg OUT VARCHAR2)
IS
  ID_NUMBER NUMBER;
BEGIN
  op_result:= 0;
  op_Msg   := '';
  SELECT sa.SEQU_X_SALES_TAX.NEXTVAL INTO ID_NUMBER FROM DUAL;
  INSERT
  INTO sa.TABLE_X_SALES_TAX
    (
      OBJID,
      X_ZIPCODE,
      X_CITY,
      X_COUNTY,
      X_STATE,
      X_CNTYDEF,
      X_DEFAULT,
      X_CNTYFIPS,
      X_STATESTAX,
      X_CNTSTAX,
      X_CNTLCLSTAX,
      X_CTYSTAX,
      X_CTYLCLSTAX,
      X_COMBSTAX ,
      X_EFF_DT,
      X_GEOCODE,
      X_INOUT ,
      X_E911FOOT,
      X_E911NOTE,
      X_E911RATE,
      X_E911SURCHARGE,
      X_USF_TAXRATE,
      X_NON_SALES
    )
    VALUES
    (
      ID_NUMBER,
      IP_X_ZIPCODE,
      IP_X_CITY,
      IP_X_COUNTY,
      IP_X_STATE,
      IP_X_CNTYDEF,
      IP_X_DEFAULT,
      IP_X_CNTYFIPS,
      IP_X_STATESTAX,
      IP_X_CNTSTAX,
      IP_X_CNTLCLSTAX,
      IP_X_CTYSTAX,
      IP_X_CTYLCLSTAX,
      IP_X_COMBSTAX,
      IP_X_EFF_DT,
      IP_X_GEOCODE,
      IP_X_INOUT,
      IP_X_E911FOOT,
      IP_X_E911NOTE,
      IP_X_E911RATE,
      IP_X_E911SURCHARGE,
      IP_X_USF_TAXRATE,
      IP_X_NON_SALES
    );
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  op_result := SQLCODE;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.insert_taxes',
      op_result,
      op_Msg,
      SYSDATE,
      'SP_TAXES.insert_taxes',
      2 -- MEDIUM
    );
END; -- end insert_taxes;





 FUNCTION compute911TXTtax( p_zipcode IN VARCHAR2 )
  RETURN number
IS
  l_e911_tax NUMBER ;
BEGIN
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911surcharge), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = nvl(p_zipcode, 'x')
    AND x_eff_dt    < SYSDATE
    AND X_2WAYTEXT_911  = 0
      --  AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL (ROUND(l_e911_tax, 4), 0);
EXCEPTION

WHEN OTHERS THEN
  RETURN  0;
END compute911TXTtax;


--x_e911rate--Rate
--x_e911surcharge--Surchage (Surchage+ Rate*Amt);

-- START NEW TXT TAX CR32572
FUNCTION computeTXTtax(
    p_zipcode IN VARCHAR2 )
  RETURN VARCHAR2
IS
  l_TXT_NON_SALES NUMBER ;
  l_X_STATE        VARCHAR2(2) ;
BEGIN
  SELECT X_2WAYTEXT_SALES ,
    x_state
  INTO l_TXT_NON_SALES,
    l_X_STATE
  FROM table_x_sales_tax
  WHERE x_zipcode      = p_zipcode
  AND x_eff_dt         < SYSDATE
  AND X_2WAYTEXT_SALES  = 0 -- CR32572 TXT TAX
  AND ROWNUM           < 2;
  IF l_TXT_NON_SALES  = 1 THEN
    RETURN 'NO TXT TAX' ;
 ELSIF  l_TXT_NON_SALES=0 THEN
         RETURN  'TXT TAX';
  END IF ;
EXCEPTION
WHEN OTHERS THEN
  RETURN '0';
END computeTXTtax;


FUNCTION computee911txtrate(
    p_zipcode IN VARCHAR2
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_e911_tax NUMBER;
BEGIN
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911rate), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
    AND X_2WAYTEXT_911  = 0
      --  AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL (ROUND (l_e911_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computee911txtrate

FUNCTION txtstatetax(
    p_zipcode IN VARCHAR2
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_txtstatetax NUMBER;
BEGIN
  SELECT *
  INTO l_txtstatetax
  FROM
    (SELECT NVL (MAX (x_combstax), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = p_zipcode
    AND x_eff_dt    < SYSDATE
    AND X_2WAYTEXT_SALES  = 0
      --  AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  RETURN NVL (ROUND (l_txtstatetax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;
--------END OF TXT TAX-CR32572-----

 PROCEDURE CalcTax
  (
    IP_ZIPCODE IN VARCHAR2,
    --IP_ESN                         IN     VARCHAR2, CR22380 removing ESN
    IP_purchaseamt      IN NUMBER,
    IP_airtimeamt       IN NUMBER,
    IP_warrantyamt      IN NUMBER,  --CR18994 CR22380
    IP_dataonlyamt      IN NUMBER,  --CR26033 / CR26274
    IP_txtonlyamt      IN NUMBER,  --CR32572
    IP_shipamt          IN NUMBER,  -- CR27857
    IP_MODEL_TYPE       IN VARCHAR2,--IP_homealertamt IN     number, -- CR27269
    IP_tot_model_type   IN NUMBER,  --IP_carconnectamt  IN     number, -- CR27270
    IP_totaldiscountamt IN NUMBER,
    IP_language         IN VARCHAR2,
    IP_source           IN VARCHAR2,
    IP_country          IN VARCHAR2,
    Op_CombStaxAmt OUT NUMBER,
    Op_E911Amt OUT NUMBER,
    Op_UsfAmt OUT NUMBER,
    Op_RcrfAmt OUT NUMBER,
    Op_SubTotalAmount OUT NUMBER,
    Op_TotalTaxAmount OUT NUMBER,
    Op_TotalCharges OUT NUMBER,
    Op_result OUT NUMBER,
    Op_CombStaxRate OUT NUMBER,
    Op_E911Rate OUT NUMBER,
    Op_UsfRate OUT NUMBER,
    Op_RcrfRate OUT NUMBER,
    Op_Msg OUT VARCHAR2,
    ip_partnumbers      in varchar2 default null  --CR29021
    ,ip_salestaxonly_amt               IN NUMBER    DEFAULT 0    --- CR41745
    ,ip_nac_activation_chrg        IN NUMBER    DEFAULT 0    --- CR41745
  )
IS
  v_tec_note            VARCHAR2(255);
  v_op_objid            VARCHAR2(20);
  v_op_description      VARCHAR2(255);
  v_op_script_text      VARCHAR2(4000);
  v_op_publish_by       VARCHAR2(30);
  v_op_publish_date     DATE;
  v_tec_type            VARCHAR2(20);
  v_tec_id              VARCHAR2(20);
  v_pos                 NUMBER;
  v_res                 NUMBER;
  v_country             VARCHAR2(50);
  op_sm_link            VARCHAR2(255);
  SubtotalAirtimeAmount NUMBER;
  v_OtherAmount         NUMBER;
  v_WtyTax              NUMBER;        --CR18994 CR22380
  v_DtaTax              NUMBER;        --CR26033 / CR26274
  v_DtaTax_prescreen    VARCHAR2(20) ; --CR26033 / CR26274
  v_modelTax            NUMBER;        --CR27269
  ONLY_SALES_TAX        NUMBER DEFAULT 1 ;
  v_dataonlyamt_a       NUMBER DEFAULT 0 ;
  v_dataonlyamt_b       NUMBER DEFAULT 0 ;
  vcompute911TXTtax    NUMBER DEFAULT 0;  -- CR32572
 x_data_sales          table_x_sales_tax.X_DATA_NON_SALES%TYPE;
 v_salestaxonly        NUMBER    :=     0;        ---CR41745
 v_nac_activation_chrg    NUMBER    :=     0;        ---CR41745

 vcomputeTXTtax      varchar2(30);
 v_TxtTax            number;

    sl_E911Amt            NUMBER    := 0;    --CR37485
    lv_activation_charge_flag        sa.table_x_sales_tax.x_non_activation_charge_flag%type    :=    1;    --34623
    apply_activation_charge_cnt        NUMBER := 0;    --34623

  -- AR CHANGE
  CURSOR cur_is_e911 (c_part_number VARCHAR2) IS
        select decode(pn.part_number, 'TFAPPE911FEESL', 'AL',SUBSTR(pn.part_number, -2, 2 )) e911_state
        from mtm_program_safelink mtm, table_part_num pn, x_program_parameters p
        where 1=1
        and mtm.program_param_objid = p.objid
        and p.x_prog_class = 'LIFELINE'
        and sysdate BETWEEN p.x_start_date AND p.x_end_date
        and sysdate between mtm.start_date  and mtm.end_date
        and mtm.program_provision_flag = '3'
        and mtm.part_num_objid = pn.objid
        and pn.part_number = c_part_number
        and pn.domain = 'REDEMPTION CARDS';

    rec_is_e911        cur_is_e911%ROWTYPE;

 ---BEGIN CR52959 EGIN  USF and RCR Taxes Exception
  l_tax_usf_flag    VARCHAR2(1);
  l_tax_rcrf_flag   VARCHAR2(1);
  ---END  CR52959 EGIN  USF and RCR Taxes Exception

BEGIN
  Op_result           := 0;
  op_Msg              := '';
  v_country           := ltrim(rtrim(ip_country));

  --Converting the NULL value in Country to USA.


  IF upper(v_Country) IS NULL OR v_Country = ' ' THEN
    v_country         := 'USA';
  END IF;

  Op_SubTotalAmount := NVL(IP_purchaseamt,0) - NVL(IP_totaldiscountamt,0); --CR22860 add nvl

  --Discount amount only applies to the airtime amount

  SubtotalAirtimeAmount := NVL(IP_airtimeamt,0) - NVL(IP_totaldiscountamt,0);
  -- IP_purchaseamt is Airtime + Warranty + Other
  --v_OtherAmount := NVL(IP_purchaseamt,0) - NVL(IP_airtimeamt,0) - NVL(IP_warrantyamt,0) --CR22380 CR22860 add nvl
    --                                     - NVL (IP_dataonlyamt, 0)                      --CR26033 / CR26274
      --                                   -NVL(IP_tot_model_type,0);                   --CR27269
-- Total Amount - all values of cards prices

v_OtherAmount := NVL(IP_purchaseamt,0) - NVL(IP_airtimeamt,0) - NVL(IP_warrantyamt,0) --CR22380 CR22860 add nvl
                                         - NVL (IP_dataonlyamt, 0)                      --CR26033 / CR26274
                                         -NVL(IP_tot_model_type,0)                     --CR27269
                                         - NVL (IP_TXTonlyamt, 0)                      --CR32572
                     - NVL(ip_salestaxonly_amt,0)            ---CR41745
                     - NVL(ip_nac_activation_chrg,0)        ---CR41745
                    ;

                    --  -ve scenario
  IF(SubtotalAirtimeAmount < 0) THEN
    SubtotalAirtimeAmount :=0;
  END IF;

  DBMS_OUTPUT.PUT_LINE('X1 : '||ONLY_SALES_TAX);

IF  IS_COUNTRY_TAXABLE(v_Country) = 'Y' THEN
  --  E911 AMT ,RATE
/* CR34807 Changes by vyegnamurthy Start*/

    IF NVL(IP_dataonlyamt,0)>0 AND NVL(IP_TXTonlyamt,0)<=0 AND NVL(IP_airtimeamt,0)<=0
        THEN
         NULL;
    ELSIF (NVL(IP_dataonlyamt,0)>0) AND NVL(IP_TXTonlyamt,0)>0 AND NVL(IP_airtimeamt,0)>0 THEN
--- AIR TEXT DATA Bundle START
    --AIR TIME logic START

    Op_UsfRate := computeUSFtax2(ip_zipcode);
    Op_UsfAmt  := ROUND(SubtotalAirtimeAmount * Op_UsfRate,2);
    Op_RcrfRate := computeMISCtax2(ip_zipcode);
    Op_RcrfAmt  := ROUND(SubtotalAirtimeAmount * Op_RcrfRate,2);
    Op_E911Amt  := computee911surcharge2(ip_zipcode);                         --CR22380 removing ESN
    Op_E911Rate := computee911tax2(ip_zipcode);                               --CR22380 removing ESN
    Op_E911Amt  := ROUND(Op_E911Amt + SubtotalAirtimeAmount * op_E911Rate,2);
    --AIR TIME logic END
    --TXT Logic START
    vcomputeTXTtax := computeTXTtax(ip_zipcode);
    Op_E911Rate:=computee911txtrate(ip_zipcode);
    IF         vcomputeTXTtax='TXT TAX'
    THEN    v_TxtTax := txtstatetax(ip_zipcode);
            DBMS_OUTPUT.PUT_LINE('Text State Tax : '||v_TxtTax);
    ELSIF     vcomputeTXTtax='NO TXT TAX' THEN v_TxtTax := 0;
    END IF;
    Op_E911Amt  :=  NVL(Op_E911Amt,0) + compute911TXTtax( ip_zipcode)+ (NVL(IP_TXTonlyamt,0)*Op_E911Rate);
        --TXT Logic END
    --DATA CARD logic START
    BEGIN
    select X_DATA_NON_SALES into x_data_sales
     from table_x_sales_tax
     WHERE X_ZIPCODE= NVL(IP_ZIPCODE,'X');
    EXCEPTION
    WHEN others
    THEN
    x_data_sales:= 1;
    DBMS_OUTPUT.PUT_LINE('No sales tax for data');
    END;

            IF x_data_sales= 1 THEN
               NULL;
              DBMS_OUTPUT.PUT_LINE('NO COMB TAX FOR DATA CARD');
              Op_CombStaxRate :=0;
             ELSE
               Op_CombStaxRate := sa.SP_TAXES.Computetax2(ip_zipcode, NULL);
               DBMS_OUTPUT.PUT_LINE('ESLE DATA CARD: ' || Op_CombStaxRate);
            END IF;

    v_WtyTax                := ComputeWTYtax(ip_zipcode) *get_combstax(ip_zipcode);
    v_modelTax              := ComputeMODELtax(ip_zipcode,ip_model_type ) ; -- CR27269 * get_comBstax(ip_zipcode);  --CR27269
    v_Dtatax_prescreen      := ComputeDTAtax(ip_zipcode) ;
    --vcompute911TXTtax := compute911TXTtax(ip_zipcode,ip_partnumbers); --32572

    --vcomputeTXTtax           := computeTXTtax(ip_zipcode);moved to 1356 line as part of CR34807

    IF v_Dtatax_prescreen    = 'NO DATA TAX' THEN
      v_DtaTax              := 0 ;
      v_dataonlyamt_a       := 0 ;
      v_dataonlyamt_b       := 0 ;
    elsif v_Dtatax_prescreen = 'SALES TAX TEXAS' THEN
      IF ip_dataonlyamt      > 25 THEN
        v_dataonlyamt_a     := 25 ;
        v_dataonlyamt_b     := ip_dataonlyamt - 25 ;
      ELSE
        --CR26033
        v_dataonlyamt_a := ip_dataonlyamt ;
     END IF ;
      v_DtaTax              := get_combstax(ip_zipcode); -- CR26033 / CR26274
    elsif v_Dtatax_prescreen = 'SALES TAX ONLY' THEN
      v_DtaTax              := get_combstax(ip_zipcode); -- CR26033 / CR26274
      v_dataonlyamt_a       := 0 ;
      v_dataonlyamt_b       := ip_dataonlyamt ;
    ELSE
      V_Dtatax := 0 ;
    END IF ;
        --DATA CARD logic END
--- AIR TEXT DATA Bundle END
--AIR and TEXT Bundle START
ELSIF (NVL(IP_dataonlyamt,0)<=0) AND NVL(IP_TXTonlyamt,0)>0 AND NVL(IP_airtimeamt,0)>0 THEN
--AIR TIME logic START
    Op_UsfRate := computeUSFtax2(ip_zipcode);
    Op_UsfAmt  := ROUND(SubtotalAirtimeAmount * Op_UsfRate,2);
    Op_RcrfRate := computeMISCtax2(ip_zipcode);
    Op_RcrfAmt  := ROUND(SubtotalAirtimeAmount * Op_RcrfRate,2);
    Op_E911Amt  := computee911surcharge2(ip_zipcode);                         --CR22380 removing ESN
    Op_E911Rate := computee911tax2(ip_zipcode);                               --CR22380 removing ESN
    Op_E911Amt  := ROUND(Op_E911Amt + SubtotalAirtimeAmount * op_E911Rate,2);
    --AIR TIME logic END
    --TXT Logic START
    vcomputeTXTtax := computeTXTtax(ip_zipcode);
    Op_E911Rate:=computee911txtrate(ip_zipcode);
    IF         vcomputeTXTtax='TXT TAX'
    THEN    v_TxtTax := txtstatetax(ip_zipcode);
            DBMS_OUTPUT.PUT_LINE('Text State Tax : '||v_TxtTax);
    ELSIF     vcomputeTXTtax='NO TXT TAX' THEN v_TxtTax := 0;
    END IF;
    Op_E911Amt  :=  NVL(Op_E911Amt,0) + compute911TXTtax( ip_zipcode)+ (NVL(IP_TXTonlyamt,0)*Op_E911Rate);
    --TXT Logic END
--AIR and TEXT Bundle END

--AIR and DATA Bundle START
                ELSIF (NVL(IP_dataonlyamt,0)>0) AND NVL(IP_TXTonlyamt,0)<=0 AND NVL(IP_airtimeamt,0)>0 THEN

    Op_UsfRate := computeUSFtax2(ip_zipcode);
    Op_UsfAmt  := ROUND(SubtotalAirtimeAmount * Op_UsfRate,2);
    Op_RcrfRate := computeMISCtax2(ip_zipcode);
    Op_RcrfAmt  := ROUND(SubtotalAirtimeAmount * Op_RcrfRate,2);
    Op_E911Amt  := computee911surcharge2(ip_zipcode);                         --CR22380 removing ESN
    Op_E911Rate := computee911tax2(ip_zipcode);                               --CR22380 removing ESN
    Op_E911Amt  := ROUND(Op_E911Amt + SubtotalAirtimeAmount * op_E911Rate,2);
        --AIR TIME logic END
    --DATA CARD logic START
    BEGIN
    select X_DATA_NON_SALES into x_data_sales
     from table_x_sales_tax
     WHERE X_ZIPCODE= NVL(IP_ZIPCODE,'X');
    EXCEPTION
    WHEN others
    THEN
    x_data_sales:= 1;
    DBMS_OUTPUT.PUT_LINE('No sales tax for data');
    END;

            IF x_data_sales= 1 THEN
               NULL;
              DBMS_OUTPUT.PUT_LINE('NO COMB TAX FOR DATA CARD');
              Op_CombStaxRate :=0;
             ELSE
               Op_CombStaxRate := sa.SP_TAXES.Computetax2(ip_zipcode, NULL);
               DBMS_OUTPUT.PUT_LINE('ESLE DATA CARD: ' || Op_CombStaxRate);
            END IF;

    v_WtyTax                := ComputeWTYtax(ip_zipcode) *get_combstax(ip_zipcode);
    v_modelTax              := ComputeMODELtax(ip_zipcode,ip_model_type ) ; -- CR27269 * get_comBstax(ip_zipcode);  --CR27269
    v_Dtatax_prescreen      := ComputeDTAtax(ip_zipcode) ;
    --vcompute911TXTtax := compute911TXTtax(ip_zipcode,ip_partnumbers); --32572

    --vcomputeTXTtax           := computeTXTtax(ip_zipcode);moved to 1356 line as part of CR34807

    IF v_Dtatax_prescreen    = 'NO DATA TAX' THEN
      v_DtaTax              := 0 ;
      v_dataonlyamt_a       := 0 ;
      v_dataonlyamt_b       := 0 ;
    elsif v_Dtatax_prescreen = 'SALES TAX TEXAS' THEN
      IF ip_dataonlyamt      > 25 THEN
        v_dataonlyamt_a     := 25 ;
        v_dataonlyamt_b     := ip_dataonlyamt - 25 ;
      ELSE
        --CR26033
        v_dataonlyamt_a := ip_dataonlyamt ;
     END IF ;
      v_DtaTax              := get_combstax(ip_zipcode); -- CR26033 / CR26274
    elsif v_Dtatax_prescreen = 'SALES TAX ONLY' THEN
      v_DtaTax              := get_combstax(ip_zipcode); -- CR26033 / CR26274
      v_dataonlyamt_a       := 0 ;
      v_dataonlyamt_b       := ip_dataonlyamt ;
    ELSE
      V_Dtatax := 0 ;
    END IF ;
--DATA CARD logic END

--AIR and DATA Bundle end

--**********Only TEXT
    ELSIF (NVL(IP_dataonlyamt,0)<=0) AND NVL(IP_TXTonlyamt,0)>0 AND NVL(IP_airtimeamt,0)<=0 THEN

                 vcomputeTXTtax           := computeTXTtax(ip_zipcode);
                    Op_E911Rate:=computee911txtrate(ip_zipcode);
                    --Surcharge + Text Amount*Rate;
            IF         vcomputeTXTtax='TXT TAX'
            THEN    v_TxtTax := txtstatetax(ip_zipcode);
                    DBMS_OUTPUT.PUT_LINE('Text State Tax : '||v_TxtTax);
            ELSIF     vcomputeTXTtax='NO TXT TAX' THEN v_TxtTax := 0;
            END IF;
                    Op_E911Amt  :=  NVL(Op_E911Amt,0) + compute911TXTtax( ip_zipcode)+ (NVL(IP_TXTonlyamt,0)*Op_E911Rate);
                    DBMS_OUTPUT.PUT_LINE('LAK : '||Op_E911Amt ||','||IP_TXTonlyamt||','||Op_E911Rate);
                    Op_RcrfAmt:=0;
                    Op_UsfRate:=0;
                    Op_RcrfRate:=0;
                    Op_RcrfAmt:=0;

--**********Only Air time
     ELSIF (NVL(IP_dataonlyamt,0)<=0) AND NVL(IP_TXTonlyamt,0)<=0 AND NVL(IP_airtimeamt,0)>0 THEN

            -- calculate USF TAX
            Op_UsfRate := computeUSFtax2(ip_zipcode);                  --CR22380 removing ESN
            DBMS_OUTPUT.PUT_LINE('usf1: '||Op_UsfRate);
            Op_UsfAmt  := ROUND(SubtotalAirtimeAmount * Op_UsfRate,2); --CR16392
            DBMS_OUTPUT.PUT_LINE('usf2 before txt:'||Op_UsfAmt);

            DBMS_OUTPUT.PUT_LINE('usf2:'||Op_UsfAmt);
            -- calculate RCRF TAX
            Op_RcrfRate := computeMISCtax2(ip_zipcode);                  --CR22380 removing ESN
            Op_RcrfAmt  := ROUND(SubtotalAirtimeAmount * Op_RcrfRate,2); --CR16392

            -- calculate E911 TAX
            Op_E911Amt  := computee911surcharge2(ip_zipcode);                         --CR22380 removing ESN
            Op_E911Rate := computee911tax2(ip_zipcode);                               --CR22380 removing ESN
            Op_E911Amt  := ROUND(Op_E911Amt + SubtotalAirtimeAmount * op_E911Rate,2); --CR16392
            DBMS_OUTPUT.PUT_LINE('X3 : '||Op_E911Amt);
            DBMS_OUTPUT.PUT_LINE('X2 : '||Op_E911Rate);


    END IF ;

/* CR34807 Changes by vyegnamurthy END*/
    -- Calculate sales taxes

        BEGIN

            select X_DATA_NON_SALES
            ,X_NON_ACTIVATION_CHARGE_FLAG    --CR34623
            into x_data_sales
            ,lv_activation_charge_flag
            from table_x_sales_tax
            WHERE X_ZIPCODE= NVL(IP_ZIPCODE,'X')
            AND ROWNUM = 1        --CR34623
            ;

        EXCEPTION
        WHEN others
        THEN
        lv_activation_charge_flag    := 1;    --CR34623
        x_data_sales:= 1;
        DBMS_OUTPUT.PUT_LINE('No sales tax for data');
        END;

    --CR34623
    /*
    BEGIN


        SELECT COUNT(pn.objid)
        INTO apply_activation_charge_cnt
        FROM table_part_num pn,table_x_parameters pm
        WHERE pn.domain = 'REDEMPTION CARDS'
        AND pn.part_number = trim(trim(BOTH ',' FROM trim(ip_partnumbers)))
        AND pm.X_PARAM_NAME = 'ACTIVATION_CHARGE_SOURCESYSTEMS'
        AND INSTR(X_PARAM_VALUE,pn.X_SOURCESYSTEM) > 0
        ;

    EXCEPTION WHEN OTHERS
    THEN

        apply_activation_charge_cnt    := 0;

    END;

    DBMS_OUTPUT.PUT_LINE('Calctax apply_activation_charge_cnt '||apply_activation_charge_cnt||' lv_activation_charge_flag '||lv_activation_charge_flag);
    */
    --CR34623

    IF ( NVL(IP_airtimeamt,0) >0 OR NVL(IP_txtonlyamt,0)>0 ) THEN

      Op_CombStaxRate := sa.SP_TAXES.Computetax2(ip_zipcode, NULL);

    ELSIF ( NVL(IP_dataonlyamt,0)>0 ) THEN

           IF x_data_sales= 1 THEN
               NULL;
              DBMS_OUTPUT.PUT_LINE('NO COMB TAX FOR DATA CARD');
              Op_CombStaxRate :=0;
             ELSE
               Op_CombStaxRate := sa.SP_TAXES.Computetax2(ip_zipcode, NULL);
               DBMS_OUTPUT.PUT_LINE('ESLE DATA CARD: ' || Op_CombStaxRate);
           END IF;
    /*
    ELSIF    apply_activation_charge_cnt <> 0 AND lv_activation_charge_flag = 0 -- BYOP NAC CDMA
    THEN
            DBMS_OUTPUT.PUT_LINE('Inside Activation charge condition');

            Op_CombStaxRate := SA.SP_TAXES.Computetax2(ip_zipcode, NULL);
    */
    ELSE
            Op_CombStaxRate :=0;

    END IF;






    DBMS_OUTPUT.PUT_LINE('test1: '||Op_CombStaxRate);

    --Op_CombStaxAmt    :=  round(Op_SubTotalAmount   * Op_CombStaxRate,2);  --CR16392  commented out by CR22380
    --CR18994 CR22380 Calculate Warranty Taxes begin
    v_WtyTax                := ComputeWTYtax(ip_zipcode) *get_combstax(ip_zipcode);
    v_modelTax              := ComputeMODELtax(ip_zipcode,ip_model_type ) ; -- CR27269 * get_comBstax(ip_zipcode);  --CR27269
    v_Dtatax_prescreen      := ComputeDTAtax(ip_zipcode) ;
    --vcompute911TXTtax := compute911TXTtax(ip_zipcode,ip_partnumbers); --32572

    --vcomputeTXTtax           := computeTXTtax(ip_zipcode);moved to 1356 line as part of CR34807

    --CR41745 Start
    DBMS_OUTPUT.PUT_LINE('Calctax salestaxonly amt '||NVL(ip_salestaxonly_amt,0)||' ip_nac_activation_chrg '||NVL(ip_nac_activation_chrg,0)||' lv_activation_charge_flag '||lv_activation_charge_flag);

    IF NVL(ip_salestaxonly_amt,0) > 0 THEN

        v_salestaxonly    :=    Computetax3(ip_zipcode, NULL);

    END IF;

    IF NVL(ip_nac_activation_chrg,0) > 0 AND lv_activation_charge_flag = 0
    THEN

        v_nac_activation_chrg    :=    sa.SP_TAXES.Computetax2(ip_zipcode, NULL);

    END IF;
    --CR41745 END

    IF v_Dtatax_prescreen    = 'NO DATA TAX' THEN
      v_DtaTax              := 0 ;
      v_dataonlyamt_a       := 0 ;
      v_dataonlyamt_b       := 0 ;
    elsif v_Dtatax_prescreen = 'SALES TAX TEXAS' THEN
      IF ip_dataonlyamt      > 25 THEN
        v_dataonlyamt_a     := 25 ;
        v_dataonlyamt_b     := ip_dataonlyamt - 25 ;
      ELSE
        --CR26033
        v_dataonlyamt_a := ip_dataonlyamt ;
     END IF ;
      v_DtaTax              := get_combstax(ip_zipcode); -- CR26033 / CR26274
    elsif v_Dtatax_prescreen = 'SALES TAX ONLY' THEN
      v_DtaTax              := get_combstax(ip_zipcode); -- CR26033 / CR26274
      v_dataonlyamt_a       := 0 ;
      v_dataonlyamt_b       := ip_dataonlyamt ;
    ELSE
      V_Dtatax := 0 ;
    END IF ;
/*moved to 1356 line as part of CR34807
   IF vcomputeTXTtax='TXT TAX' THEN
      IF (   ( NVL(IP_txtonlyamt,0)>0 ) AND( NVL(IP_airtimeamt,0)<=0 )  AND(NVL(IP_dataonlyamt,0) <= 0) )
        THEN
     v_TxtTax := txtstatetax(ip_zipcode);
       DBMS_OUTPUT.PUT_LINE('Text State Tax : '||v_TxtTax);
     ELSE
      DBMS_OUTPUT.PUT_LINE('NO Text ONLY INPUT : ' );
     END IF;
     ELSIF vcomputeTXTtax='NO TXT TAX' THEN

       v_TxtTax := 0;

   END IF;
  CR34807 end */

    OP_COMBSTAXAMT := ROUND(SUBTOTALAIRTIMEAMOUNT * OP_COMBSTAXRATE,2)
    + ROUND(NVL(ip_warrantyamt,0) * v_wtytax,2) +
    ROUND(v_OtherAmount * Op_CombStaxRate,2)
    --           + ROUND(NVL(ip_dataonlyamt,0) * v_dtatax,2)  -- CR26033 / CR26274
    + ROUND(NVL(v_dataonlyamt_B,0) * v_dtatax,2)      -- CR26033 / CR26274
    + ROUND(NVL(ip_TOT_model_type,0) * v_MODELtax,2) + ROUND(NVL(IP_TXTonlyamt,0)*NVL(v_TxtTax ,0),2) --CR27269/--CR32572
    + ROUND(NVL(ip_salestaxonly_amt,0)    *    NVL(v_salestaxonly ,0),2)    --CR41745
    + ROUND(NVL(ip_nac_activation_chrg,0)    *    NVL(v_nac_activation_chrg ,0),2)    --CR41745
    ;

     DBMS_OUTPUT.PUT_LINE('combination tax');
     DBMS_OUTPUT.PUT_LINE('V1: '||SUBTOTALAIRTIMEAMOUNT);
     DBMS_OUTPUT.PUT_LINE('V1: '||OP_COMBSTAXRATE);
     DBMS_OUTPUT.PUT_LINE('V1: '||ip_warrantyamt);
     DBMS_OUTPUT.PUT_LINE('V1: '||v_wtytax);
     DBMS_OUTPUT.PUT_LINE('V1: '||v_OtherAmount);
     DBMS_OUTPUT.PUT_LINE('V1: '||Op_CombStaxRate);
     DBMS_OUTPUT.PUT_LINE('V1: '||v_dataonlyamt_B);
     DBMS_OUTPUT.PUT_LINE('V1: '||v_dtatax);
     DBMS_OUTPUT.PUT_LINE('V1: '||ip_TOT_model_type);
     DBMS_OUTPUT.PUT_LINE('V1: '||v_MODELtax);
     DBMS_OUTPUT.PUT_LINE('V1: '||IP_TXTonlyamt);
       DBMS_OUTPUT.PUT_LINE('V1: '||v_TxtTax);
        DBMS_OUTPUT.PUT_LINE('V1: '||OP_COMBSTAXAMT);
   --CR18994 CR22380 Calculate Warranty Taxes end

    DBMS_OUTPUT.PUT_LINE('test2:'||OP_COMBSTAXRATE);
    ELSE
    -- taxes for others conuntry diferent USA
    Op_UsfRate      := 0;
    Op_UsfAmt       := 0;
    Op_RcrfRate     := 0;
    Op_RcrfAmt      := 0;
    Op_E911Amt      := 0;
    Op_E911Rate     := 0;
    Op_CombStaxRate := 0;
    Op_CombStaxAmt  := 0;

  END IF;

  -- Calculate E911 note --
  /*   V_TEC_NOTE := computee911note2(ip_zipcode, ip_esn);
  IF   V_TEC_NOTE = 'NULL' THEN
  v_op_script_text:='N/A';
  ELSE
  v_pos:= INSTR( V_TEC_NOTE,'_');
  v_tec_type:= SUBSTR(V_TEC_NOTE, 1, V_pos-1);
  v_tec_id:= SUBSTR(V_TEC_NOTE, V_pos+1, 100);
  SA.SCRIPTS_PKG.GET_SCRIPT_PRC(IP_Source, V_tec_type, V_tec_id, IP_language,NULL,NULL, V_op_objid ,
  v_op_description,v_op_script_text,v_op_publish_by ,v_op_publish_date,v_op_sm_link);
  END IF;
  Op_E911Note       :=  v_op_script_text; */
  IF( NVL(IP_airtimeamt,0) = 0) and  (NVL(IP_txtonlyamt,0)< 0 ) THEN --CR22860 add nvl
  DBMS_OUTPUT.PUT_LINE('test4');
    Op_UsfAmt             := 0;
    Op_E911Amt            := 0;
    Op_RcrfAmt            := 0;
  END IF;
  --   Calculate total output result
  OP_E911RATE         := NVL(OP_E911RATE,0) ;
  OP_USFRATE          := NVL(OP_USFRATE,0);
  OP_RCRFRATE         := NVL(OP_RCRFRATE,0) ;
  OP_COMBSTAXAMT      := NVL(OP_COMBSTAXAMT,0) ;
  DBMS_OUTPUT.PUT_LINE('test3 CMB'||OP_COMBSTAXAMT);
  OP_E911AMT          := NVL(OP_E911AMT,0) ;
  DBMS_OUTPUT.PUT_LINE('test3'||OP_E911AMT);
  OP_USFAMT           := NVL(OP_USFAMT,0) ;
  OP_RCRFAMT          := NVL(OP_RCRFAMT,0) ;
  OP_SUBTOTALAMOUNT   := NVL(OP_SUBTOTALAMOUNT,0) ;
  OP_TOTALTAXAMOUNT   := NVL(OP_TOTALTAXAMOUNT,0) ;
  DBMS_OUTPUT.PUT_LINE( 'T1 : '||OP_TOTALTAXAMOUNT);
  OP_TOTALCHARGES     := NVL(OP_TOTALCHARGES,0) ;
  IF IS_COUNTRY_TAXABLE(v_country) = 'Y' THEN   --CR55657
    Op_TotalTaxAmount := Op_UsfAmt + Op_E911Amt + Op_RcrfAmt + Op_CombStaxAmt;
    DBMS_OUTPUT.PUT_LINE( 'T2: '||Op_UsfAmt||','||Op_E911Amt ||',' ||Op_RcrfAmt||','|| Op_CombStaxAmt||','||Op_TotalTaxAmount );

  ELSE
    Op_TotalTaxAmount := 0;
  END IF;
  --Op_TotalCharges   :=  Op_SubTotalAmount  + Op_TotalTaxAmount;    commented out by CR22380
  --Op_TotalCharges   :=      nvl(SubtotalAirtimeAmount,0) + nvl(ip_warrantyamt,0) + nvl(v_OtherAmount,0) + nvl(Op_TotalTaxAmount,0); --CR22860 add nvl
  -- CR26033 / CR26274 add data only
  Op_TotalCharges := NVL(SubtotalAirtimeAmount,0) + NVL(ip_warrantyamt,0) + NVL(ip_dataonlyamt,0)    -- CR26033 / CR26274
                                                  + NVL(ip_TXTonlyamt,0)                         -- CR32572
                                                  + NVL(ip_TOT_MODEL_TYPE,0)                         -- CR27269
                                                  + NVL(v_OtherAmount,0) + NVL(Op_TotalTaxAmount,0) --CR22860 add nvl
                          + NVL(ip_salestaxonly_amt,0)        --CR41745
                          + NVL(ip_nac_activation_chrg,0)    --CR41745
                          ;
  Op_Msg:= 'Successful';

  /* CR29021 changes starts  */
  /*
  if input part-number is safelink e911 then
  DO not calculate any other taxes.. all other taxes will be 0
  return the totalCharges and subtotal_amount same as of input purchase amount
  if input part number is not safelink e911 then
  process as existing flow
  */
  declare
    lv_part_number  varchar2(1000);
    lv_subtext      varchar2(1000);
    i               pls_integer := 0;
    lv_count        integer := 0;
    --CR37485
    lv_found  varchar2(2);
    TYPE REC_PART_NUM_COUNT IS RECORD
    (
    PART_NUMBER                VARCHAR2(30),
    PART_NUM_COUNT    NUMBER
    );
    TYPE PART_NUM_COUNT_TAB IS TABLE OF REC_PART_NUM_COUNT;

    LV_PART_NUM_TAB PART_NUM_COUNT_TAB;
    LV_REC  REC_PART_NUM_COUNT;
    lv_E911Amt    NUMBER := 0;
    --CR37485

  begin
        LV_PART_NUM_TAB := PART_NUM_COUNT_TAB();    --CR37485
      lv_part_number := trim(trim(BOTH ',' FROM trim(ip_partnumbers))) ||',';
      lv_part_number :=  replace(lv_part_number, ' ', '');

      dbms_output.put_line(' start....lv_part_number='||lv_part_number);
      i := instr(lv_part_number, ',');

      while i > 0 loop
        i := instr(lv_part_number, ',');

        --if lv_subtext  is null then -- Commented for CR37485
          lv_subtext  := substr(lv_part_number, 1, i-1);
        --end if;

        --CR37485
            lv_found := 'N';
            dbms_output.put_line(' Rahul 0.1');
            FOR j IN nvl(LV_PART_NUM_TAB.FIRST,0) .. nvl(LV_PART_NUM_TAB.LAST,-1)
            LOOP


                IF LV_PART_NUM_TAB(j).PART_NUMBER = lv_subtext
                THEN



                    LV_PART_NUM_TAB(j).PART_NUM_COUNT := LV_PART_NUM_TAB(j).PART_NUM_COUNT + 1;

                    lv_found := 'Y';

                END IF;


            END LOOP;

            If lv_found = 'N' AND lv_subtext IS NOT NULL
            Then

                        LV_PART_NUM_TAB.EXTEND;
                        LV_REC.PART_NUMBER  := lv_subtext;
                        LV_REC.PART_NUM_COUNT := 1;
                        LV_PART_NUM_TAB(LV_PART_NUM_TAB.LAST) := LV_REC;

           End if;
        --CR37485
        /* --  Commented for CR37485
        if substr(lv_part_number, 1, i-1) = lv_subtext then
          lv_count := lv_count + 1;
        else
          lv_count := -1;
          --that means different part_numbers received;
          exit;
        end if;
        */

        lv_part_number := trim(substr(trim(lv_part_number), i+1));
        i := instr(lv_part_number, ',');
      end loop;


      FOR j in NVL(LV_PART_NUM_TAB.FIRST,0) .. NVL(LV_PART_NUM_TAB.LAST,-1)
      LOOP

      dbms_output.put_line('Part num from collection '||LV_PART_NUM_TAB(j).PART_NUMBER||' Count '||NVL(LV_PART_NUM_TAB(j).PART_NUM_COUNT,0));

        OPEN cur_is_e911 (LV_PART_NUM_TAB(j).PART_NUMBER);
        FETCH cur_is_e911 into rec_is_e911;

        IF cur_is_e911%FOUND
        THEN


            lv_E911Amt          :=   LV_PART_NUM_TAB(j).PART_NUM_COUNT * computee911surcharge3(rec_is_e911.e911_state);

            sl_E911Amt    := NVL(sl_E911Amt,0) + NVL(lv_E911Amt,0);

        END IF;
        CLOSE cur_is_e911;


      END LOOP;


      Op_E911Amt            := NVL(Op_E911Amt,0) + NVL(sl_E911Amt,0);
      Op_TotalTaxAmount        := NVL(Op_TotalTaxAmount,0) + NVL(sl_E911Amt,0);
      Op_TotalCharges        := NVL(Op_TotalCharges,0)    + NVL(sl_E911Amt,0);









    /*
      dbms_output.put_line('lv_count='||lv_count);

      if lv_count > 0 then
        lv_part_number := lv_subtext;

        dbms_output.put_line('********** ip_partnumbers='||ip_partnumbers);

        FOR rec IN cur_is_e911 (lv_part_number)  -- AR CHANGE
        loop
--        if nvl(lv_e911_count,0) > 0 then
          Op_CombStaxAmt      :=   0;
          --Op_E911Amt          :=   0;    Commented and modified by Rahul for CR33056 on Jun182015
            Op_E911Amt          :=   lv_count * computee911surcharge3(rec.e911_state);    -- Modified by Rahul for CR33056 on Jun182015
                                                             -- AR CHANGE
          Op_UsfAmt           :=   0;
          Op_RcrfAmt          :=   0;
          Op_SubTotalAmount   :=   IP_purchaseamt; --lv_count * sa.sp_taxes.computee911surcharge2(ip_zipcode);
          --Op_TotalTaxAmount   :=   0;              Commented by Rahul for BRANCH.Branch_2015 - Defect # 3155 for CR 33056
          Op_TotalTaxAmount := Op_UsfAmt + Op_E911Amt + Op_RcrfAmt + Op_CombStaxAmt;    -- Modified by Rahul for BRANCH.Branch_2015 - Defect # 3155 raised for CR 33056

          --Op_TotalCharges     :=   Op_SubTotalAmount;    Commented by Rahul for BRANCH.Branch_2015 - Defect # 3155 for CR 33056
          Op_TotalCharges     :=   Op_SubTotalAmount + Op_TotalTaxAmount;    -- Modified by Rahul for BRANCH.Branch_2015 - Defect # 3155 raised for CR 33056
          Op_CombStaxRate     :=   0;
          Op_E911Rate         :=   0;
          Op_UsfRate          :=   0;
          Op_RcrfRate         :=   0;
          Op_result           :=   0;
          Op_Msg              :=   'Successful';
--        end if;
        end loop;
      end if;
    */
  exception
    when others then
      Op_result := SQLCODE;
      Op_msg    := SQLCODE || ' CR29021 err='|| SUBSTR (SQLERRM, 1, 1000);

      INSERT INTO x_program_error_log
        (
          x_source,
          x_error_code,
          x_error_msg,
          x_date,
          x_description,
          x_severity
        )
        VALUES
        (
          'SP_TAXES.CalcTax',
          op_result,
          op_Msg,
          SYSDATE,
          'SP_TAXES.CalcTax',
          2 -- MEDIUM
        );
  end;
  /* CR29021 changes ends  */

  ----- BEGIN - CR52959  - USF and RCR Taxes Exception

  -- Calling the following procedure to get the tax flags to apply the tax or not
  get_tax_flag ( i_source        => IP_source        ,
                 o_tax_usf_flag  => l_tax_usf_flag   ,
                 o_tax_rcrf_flag => l_tax_rcrf_flag );

  --DBMS_OUTPUT.PUT_LINE('IP_source         : ' || IP_source);
  --DBMS_OUTPUT.PUT_LINE('l_tax_usf_flag    : ' || l_tax_usf_flag);
  --DBMS_OUTPUT.PUT_LINE('l_tax_rcrf_flag   : ' || l_tax_rcrf_flag);

  -- If tax_usf is set to N then don't apply USF Tax
  IF NVL(l_tax_usf_flag,'Y') = 'N'
  THEN
    --- Deducting the USF Amt from TotalTaxAmount , TotalCharges
    Op_TotalTaxAmount := NVL(Op_TotalTaxAmount,0) - NVL(Op_UsfAmt,0);
    Op_TotalCharges   := NVL(Op_TotalCharges,0)   - NVL(Op_UsfAmt,0);

    IF SIGN(Op_TotalTaxAmount) = -1
    THEN
      Op_TotalTaxAmount := 0 ;
    END IF;

    IF SIGN(Op_TotalCharges) = -1
    THEN
      Op_TotalCharges  := 0;
    END IF;

    Op_UsfAmt  := 0;
    Op_UsfRate := 0;

  END IF ;

  -- If l_tax_rcrf is set to N then don't apply RCRF Tax
  IF l_tax_rcrf_flag = 'N'
  THEN
    -- Deducting the RCF Amount from TotalTaxAmount,TotalCharges
    Op_TotalTaxAmount := NVL(Op_TotalTaxAmount,0) - NVL(Op_RcrfAmt,0);
    Op_TotalCharges   := NVL(Op_TotalCharges,0)   - NVL(Op_RcrfAmt,0);

    IF SIGN(Op_TotalTaxAmount) = -1
    THEN
      Op_TotalTaxAmount := 0 ;
    END IF;

    IF SIGN(Op_TotalCharges) = -1
    THEN
      Op_TotalCharges  := 0;
    END IF;


    Op_RcrfAmt   := 0 ;
    Op_RcrfRate  := 0 ;
  END IF ;
  ----- END - CR52959  - USF and RCR Taxes Exception


EXCEPTION
WHEN OTHERS THEN
  Op_result := SQLCODE;
  Op_msg    := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK
                ,1
                ,60)||' '||SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ,1
                ,40)||' '||SUBSTR(ip_partnumbers,1,40)||' Purchase Amt '||to_char(IP_purchaseamt)||' zipcode '||IP_ZIPCODE||' '||IP_source;

  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.CalcTax',
      op_result,
      op_Msg,
      SYSDATE,
      'SP_TAXES.CalcTax',
      2 -- MEDIUM
    );
END; -- END CalcTax;

 PROCEDURE TaxRATE_B2B_ZIPCODE
  (
    IP_ZIPCODE IN VARCHAR2,
    Op_B2bCombStaxRate OUT NUMBER,
    Op_B2bE911Rate OUT NUMBER,
    Op_B2bUsfRate OUT NUMBER,
    Op_B2brcrfRate OUT NUMBER,
    Op_B2bE911Surcharge OUT NUMBER
  )
IS
  CURSOR Sales_Tax_Cur
  IS
    SELECT NVL(MAX (st.x_combstax), 0) x_combstax
    FROM Table_X_Sales_Tax St
    WHERE IP_ZIPCODE   = St.X_Zipcode
    AND st.x_non_sales = 0;
  Sales_Tax_Rec Sales_Tax_Cur%Rowtype;
  CURSOR Tax_Cur
  IS
    SELECT NVL (MAX (x_e911rate), 0) x_e911rate,
      NVL (MAX (x_usf_taxrate), 0) x_usf_taxrate,
      NVL (MAX (X_RCRFRATE), 0) X_RCRFRATE,
      NVL (MAX (x_e911surcharge), 0) x_e911surcharge,
      NVL (MAX (x_e911NOTE), ' ') x_e911note
    FROM Table_X_Sales_Tax St
    WHERE IP_ZIPCODE = St.X_Zipcode;
  Tax_Rec Tax_Cur%Rowtype;
  op_result NUMBER;
  op_Msg    VARCHAR2(255);
BEGIN
  op_result:= 0;
  op_Msg   := '';
  OPEN Sales_Tax_Cur;
  FETCH Sales_Tax_Cur INTO Sales_Tax_Rec;
  IF Sales_Tax_Cur%Found THEN
    Op_B2bCombStaxRate := Sales_Tax_Rec.X_COMBSTAX;
  ELSE
    Op_B2bCombStaxRate := 0;
  END IF;
  CLOSE Sales_Tax_Cur;
  OPEN Tax_Cur;
  FETCH Tax_Cur INTO Tax_Rec;
  IF Tax_Cur%Found THEN
    Op_B2bE911Rate      := Tax_Rec.x_e911rate;
    Op_B2bUsfRate       := Tax_Rec.x_usf_taxrate;
    Op_B2brcrfRate      := Tax_Rec.X_RCRFRATE;
    Op_B2bE911Surcharge := Tax_Rec.X_e911surcharge;
  ELSE
    Op_B2bE911Rate      := 0;
    Op_B2bUsfRate       := 0;
    Op_B2brcrfRate      := 0;
    Op_B2bE911Surcharge := 0;
  END IF;
  CLOSE Tax_Cur;
  op_Msg:= 'Successful';
EXCEPTION
WHEN OTHERS THEN
  op_result := SQLCODE;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.Taxrate_B2B_zipcode',
      op_result,
      op_Msg,
      SYSDATE,
      'SP_TAXES.Taxrate_B2B_zipcode',
      2 -- MEDIUM
    );
END; -- END Taxrate_B2B_zipcode;
PROCEDURE TaxRATE_B2B
  (
    IP_ORDER_ID IN VARCHAR2,
    Op_B2bCombStaxRate OUT NUMBER,
    Op_B2bE911Rate OUT NUMBER,
    Op_B2bUsfRate OUT NUMBER,
    Op_B2brcrfRate OUT NUMBER,
    Op_B2bE911Surcharge OUT NUMBER
  )
IS
  CURSOR Sales_Tax_Cur (v_ip_order_Id VARCHAR2)
  IS
    SELECT NVL(MAX (st.x_combstax), 0) x_combstax
    FROM X_Sales_Orders So,
      X_Business_Accounts Ba,
      Table_X_Sales_Tax St
    WHERE So.Bill_Zipcode = St.X_Zipcode
    AND So.Order_Id       = V_Ip_Order_Id
    AND So.Account_Id     = Ba.Account_Id
    AND st.x_non_sales    = 0
    AND Ba.Tax_Exempt     = 'false';
  Sales_Tax_Rec Sales_Tax_Cur%Rowtype;
  CURSOR Tax_Cur (v_ip_order_Id VARCHAR2)
  IS
    SELECT NVL (MAX (x_e911rate), 0) x_e911rate,
      NVL (MAX (x_usf_taxrate), 0) x_usf_taxrate,
      NVL (MAX (X_RCRFRATE), 0) X_RCRFRATE,
      NVL (MAX (x_e911surcharge), 0) x_e911surcharge
    FROM X_Sales_Orders So,
      X_Business_Accounts Ba,
      Table_X_Sales_Tax St
    WHERE So.Bill_Zipcode = St.X_Zipcode
    AND So.Order_Id       = V_Ip_Order_Id
    AND So.Account_Id     = Ba.Account_Id
    AND Ba.Tax_Exempt     = 'false';
  Tax_Rec Tax_Cur%Rowtype;
  op_result NUMBER;
  op_Msg    VARCHAR2(255);
BEGIN
  op_result:= 0;
  op_Msg   := '';
  OPEN Sales_Tax_Cur (IP_order_Id );
  FETCH Sales_Tax_Cur INTO Sales_Tax_Rec;
  IF Sales_Tax_Cur%Found THEN
    Op_B2bCombStaxRate := Sales_Tax_Rec.X_COMBSTAX;
  ELSE
    Op_B2bCombStaxRate := 0;
  END IF;
  CLOSE Sales_Tax_Cur;
  OPEN Tax_Cur (IP_order_Id );
  FETCH Tax_Cur INTO Tax_Rec;
  IF Tax_Cur%Found THEN
    Op_B2bE911Rate      := Tax_Rec.x_e911rate;
    Op_B2bUsfRate       := Tax_Rec.x_usf_taxrate;
    Op_B2brcrfRate      := Tax_Rec.X_RCRFRATE;
    Op_B2bE911Surcharge := Tax_Rec.X_e911surcharge;
  ELSE
    Op_B2bE911Rate      := 0;
    Op_B2bUsfRate       := 0;
    Op_B2brcrfRate      := 0;
    Op_B2bE911Surcharge := 0;
  END IF;
  CLOSE Tax_Cur;
  op_Msg:= 'Successful';
EXCEPTION
WHEN OTHERS THEN
  op_result := SQLCODE;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.Taxrate_B2B',
      op_result,
      op_Msg,
      SYSDATE,
      'SP_TAXES.Taxrate_B2B',
      2 -- MEDIUM
    );
END; -- END Taxrate_B2B;
PROCEDURE GET_E911_Script
  (
    IP_language IN VARCHAR2,
    IP_source   IN VARCHAR2,
    IP_zipcode  IN VARCHAR2,
    IP_brand    IN VARCHAR2,
    Op_E911Label OUT VARCHAR2,
    Op_result OUT NUMBER,
    Op_Msg OUT VARCHAR2
  )
IS
  CURSOR Zipcode_Cur
  IS
    SELECT MAX(x_state) x_state
    FROM Table_x_sales_tax
    WHERE x_zipcode = IP_zipcode;
  Zipcode_Rec Zipcode_Cur%Rowtype;
  CURSOR Script_note_Cur(V_state VARCHAR2)
  IS
    SELECT x_script_id FROM X_E911_state_label WHERE x_state = v_state;
  Script_note_Rec Script_note_Cur%Rowtype;
  Script_note_Rec2 Script_note_Cur%Rowtype;
  v_TEC_NOTE        VARCHAR2(255);
  v_op_objid        VARCHAR2(20);
  V_op_description  VARCHAR2(255);
  V_op_script_text  VARCHAR2(4000);
  V_op_publish_by   VARCHAR2(30);
  V_op_publish_date DATE;
  v_tec_type        VARCHAR2(20);
  v_tec_id          VARCHAR2(20);
  v_pos             NUMBER;
  v_res             NUMBER;
  v_op_sm_link      VARCHAR2(255);
  l_org_flow table_bus_org.org_flow%TYPE ; --CR20451 | CR20854: Add TELCEL Brand
BEGIN
  op_result:= 0;
  op_Msg   := '';
  SELECT org_flow INTO l_org_flow FROM table_bus_org WHERE org_id = ip_brand ;
  OPEN Zipcode_Cur;
  FETCH zipcode_Cur INTO Zipcode_Rec;
  IF zipcode_Cur%Found THEN
    OPEN Script_note_cur(Zipcode_Rec.x_state);
    FETCH Script_note_cur INTO Script_note_Rec;
    IF Script_note_cur%Found THEN
      V_TEC_NOTE := Script_note_Rec.x_script_id;
      CLOSE Script_note_Cur;
    ELSE
      CLOSE Script_note_Cur;
      -- CR20451 | CR20854: Add TELCEL Brand
      -- if UPPER(IP_brand) = 'STRAIGHT_TALK' then
      IF l_org_flow = '3' THEN
        OPEN Script_note_cur('DEF_STR');
        FETCH Script_note_cur INTO Script_note_Rec2;
        V_TEC_NOTE := Script_note_Rec2.x_script_id;
        CLOSE Script_note_Cur;
      ELSE
        OPEN Script_note_cur('DEF_NONSTR');
        FETCH Script_note_cur INTO Script_note_Rec2;
        V_TEC_NOTE := Script_note_Rec2.x_script_id;
        CLOSE Script_note_Cur;
      END IF;
    END IF;
    CLOSE zipcode_Cur;
  ELSE
    Op_Msg     := 'Zipcode not found into table_x_sales_tax';
    V_TEC_NOTE := 'NULL';
  END IF;
  IF V_TEC_NOTE      = 'NULL' THEN
    v_op_script_text:='N/A';
  ELSE
    v_pos     := INSTR( V_TEC_NOTE,'_');
    v_tec_type:= SUBSTR(V_TEC_NOTE, 1, V_pos-1);
    v_tec_id  := SUBSTR(V_TEC_NOTE, V_pos   +1, 100);
    dbms_output.put_line ('v_pos:'||TO_CHAR(v_pos));
    dbms_output.put_line ('v_type:'|| v_tec_type);
    dbms_output.put_line ('v_tec_id:'||TO_CHAR(v_tec_id));
    /* GET_SCRIPT_PRC(IP_Source, V_tec_type, V_tec_id, IP_language,NULL,NULL, V_op_objid ,
    v_op_description,v_op_script_text,v_op_publish_by ,v_op_publish_date);  */
    sa.SCRIPTS_PKG.GET_SCRIPT_PRC(UPPER(IP_Source), Upper(NVL(Ip_Brand,'TRACFONE')), V_tec_type, V_tec_id, UPPER(IP_language), NULL, NULL, V_op_objid , v_op_description, v_op_script_text, v_op_publish_by , v_op_publish_date, v_op_sm_link);
    Op_Msg:= 'Successful';
  END IF;
  -- Return E911 Label description
  Op_E911label := v_op_script_text;
EXCEPTION
WHEN OTHERS THEN
  Op_result := SQLCODE;
  Op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.Calcnote_B2b',
      op_result,
      op_Msg,
      SYSDATE,
      'SP_TAXES.Calcnote_B2b',
      2 -- MEDIUM
    );
END; -- END CalcNote_B2b;
PROCEDURE CalcTax_B2b
  (
    IP_purchaseamt      IN NUMBER,
    IP_order_id         IN VARCHAR2,
    IP_airtimeamt       IN NUMBER,
    IP_totaldiscountamt IN NUMBER,
    IP_language         IN VARCHAR2,
    IP_source           IN VARCHAR2,
    IP_country          IN VARCHAR2,
    IP_zipcode          IN VARCHAR2,
    Op_CombStaxAmt OUT NUMBER,
    Op_E911Amt OUT NUMBER,
    Op_UsfAmt OUT NUMBER,
    Op_RcrfAmt OUT NUMBER,
    Op_SubTotalAmount OUT NUMBER,
    Op_TotalTaxAmount OUT NUMBER,
    Op_TotalCharges OUT NUMBER,
    Op_result OUT NUMBER,
    Op_CombStaxRate OUT NUMBER,
    Op_E911Rate OUT NUMBER,
    Op_UsfRate OUT NUMBER,
    Op_RcrfRate OUT NUMBER,
    Op_Msg OUT VARCHAR2
  )
IS
  v_op_objid            VARCHAR2(20);
  V_op_description      VARCHAR2(255);
  V_op_script_text      VARCHAR2(4000);
  V_op_publish_by       VARCHAR2(30);
  V_op_publish_date     DATE;
  v_tec_type            VARCHAR2(20);
  v_tec_id              VARCHAR2(20);
  v_pos                 NUMBER;
 v_res                 NUMBER;
  v_country             VARCHAR2(50);
  SubtotalAirtimeAmount NUMBER;
  V_MODEL_TYPE          NUMBER;
BEGIN
  op_result           := 0;
  op_Msg              := '';
  v_country           := ltrim(rtrim(ip_country));
  IF upper(v_Country) IS NULL OR v_Country = ' ' THEN
    v_country         := 'USA';
  END IF;
  Op_SubTotalAmount       := IP_purchaseamt - IP_totaldiscountamt ;
  SubtotalAirtimeAmount   := IP_airtimeamt  - IP_totaldiscountamt;
  IF(SubtotalAirtimeAmount < 0) THEN
    SubtotalAirtimeAmount :=0;
  END IF;
  IF UPPER(v_Country) = 'USA' THEN
    TaxRATE_B2B_ZIPCODE(IP_zipcode ,Op_CombStaxRate,Op_E911Rate,Op_UsfRate,Op_RcrfRate, Op_E911Amt);
    Op_UsfAmt      := ROUND(SubtotalAirtimeAmount * Op_UsfRate,2);      --CR16392
    Op_RcrfAmt     := ROUND(SubtotalAirtimeAmount * Op_RcrfRate,2);     --CR16392
    Op_CombStaxAmt := ROUND(Op_SubTotalAmount     * Op_CombStaxRate,2); --CR16392
    -- Calculate 911 amount -
    Op_E911Amt := ROUND(Op_E911Amt + SubtotalAirtimeAmount * op_E911Rate,2); --CR16392
  ELSE
    -- taxes for others conuntry diferent USA
    Op_UsfRate      := 0;
    Op_UsfAmt       := 0;
    Op_RcrfRate     := 0;
    Op_RcrfAmt      := 0;
    Op_E911Amt      := 0;
    Op_E911Rate     := 0;
    Op_CombStaxRate := 0;
    Op_CombStaxAmt  := 0;
  END IF;
  IF( IP_airtimeamt = 0 ) THEN
    Op_UsfAmt      := 0;
    Op_E911Amt     := 0;
    Op_RcrfAmt     := 0;
  END IF;
  -- Calculate total output result
  IF UPPER(v_Country)  = 'USA' THEN
    Op_TotalTaxAmount := Op_UsfAmt + Op_E911Amt + Op_RcrfAmt + Op_CombStaxAmt;
  ELSE
    Op_TotalTaxAmount := 0;
  END IF;
  Op_TotalCharges := Op_SubTotalAmount + Op_TotalTaxAmount;
  Op_Msg          := 'Successful';
  --end if;
EXCEPTION
WHEN OTHERS THEN
  Op_result := SQLCODE;
  Op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.CalcTax_B2b',
      op_result,
      op_Msg,
      SYSDATE,
      'SP_TAXES.CalcTax_B2b',
      2 -- MEDIUM
    );
END; -- END CalcTax_B2b;
PROCEDURE GETTax2_BILL
  (
    IP_price    IN NUMBER,
    IP_usf_tax  IN NUMBER,
    IP_rcrf_tax IN NUMBER,
    Op_usf_tax OUT NUMBER,
    Op_rcrf_tax OUT NUMBER
  )
IS
  op_Msg    VARCHAR2(20);
  Op_result NUMBER;
BEGIN
  Op_result   := 0;
  op_Msg      := '';
  Op_Usf_tax  := ip_price * IP_usf_tax;
  Op_Rcrf_tax := ip_price * IP_rcrf_tax;
  Op_Msg      := 'Successful';
EXCEPTION
WHEN OTHERS THEN
  Op_result := SQLCODE;
  Op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.GETTax2_BILL',
      op_result,
      op_Msg,
      SYSDATE,
      'SP_TAXES.GETTax2_BILL',
      2 -- MEDIUM
    );
END; -- END GETTax2_BILL;
PROCEDURE GETTax_BILL
  (
    IP_price     IN NUMBER,
    IP_sales_tax IN NUMBER,
    IP_e911_tax  IN NUMBER,
    Op_sales_tax OUT NUMBER,
    Op_e911_tax OUT NUMBER
  )
IS
  Op_Msg    VARCHAR2(20);
  Op_result NUMBER;
BEGIN
  Op_result    := 0;
  op_Msg       := '';
  Op_Sales_tax := ip_price * IP_sales_tax;
  Op_e911_tax  := ip_price * IP_e911_tax;
  Op_Msg       := 'Successful';
EXCEPTION
WHEN OTHERS THEN
  Op_result := SQLCODE;
  Op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.GETTax2_BILL',
      op_result,
      op_Msg,
      SYSDATE,
      'SP_TAXES.GETTax2_BILL',
      2 -- MEDIUM
    );
END; -- END GETTax2_BILL;
--New procedure added for B2B CR25490 by CPannala
PROCEDURE calculate_taxes
  (
    in_bill_zip IN VARCHAR2,
    in_ship_zip IN VARCHAR2,
    in_calc_tax IN OUT typ_calc_tax_tbl,
    in_total_discount_amt NUMBER,
    in_language        IN VARCHAR2,
    in_source          IN VARCHAR2,
    in_country         IN VARCHAR2,
    IN_TAX_EXEMPT_TYPE IN VARCHAR2,
    OUT_USF_TOT        OUT NUMBER,
    OUT_RCRF_TOT      OUT NUMBER,
    OUT_E911_TOT OUT NUMBER,
    OUT_STAX_TOT OUT NUMBER,
    OUT_tax_TOT OUT NUMBER,
    OUT_hdr_TOT OUT NUMBER,
    out_err_num OUT NUMBER,
    out_err_Message OUT VARCHAR2
  )
IS
  I PLS_INTEGER;
  v_zip      VARCHAR2(50);
  v_res      NUMBER;
  v_country  VARCHAR2(50);
  V_WTYTAX   NUMBER;
  l_RCRF_TOT NUMBER;
  l_E911_TOT NUMBER;
  l_USF_TOT  NUMBER;
  v_calc_tax_tbl typ_calc_tax_tbl := typ_calc_tax_tbl();
  v_combstaxrate NUMBER;
  v_e911rate NUMBER;
  v_usfrate NUMBER;
  v_rcrfrate NUMBER;
  v_err_message VARCHAR2(300);
  v_result  NUMBER;




BEGIN
  V_CALC_TAX_TBL := IN_CALC_TAX;
  OUT_HDR_TOT    :=0;
  OUT_USF_TOT    := 0;
  OUT_RCRF_TOT   := 0;
  OUT_E911_TOT   := 0;
  OUT_STAX_TOT   := 0;
  OUT_tax_TOT    := 0;



  ---
  IF (in_bill_zip   IS NULL ) THEN
    out_err_num     := 711; -- 'Zipcode required.'
    out_err_message := sa.get_code_fun('SP_TAXES', out_err_num, 'ENGLISH');
    RETURN;
  END IF;
  -----
  IF (v_calc_tax_tbl.Count = 0) THEN
    --dbms_output.put_line('v_err_num10');
    out_err_num     := 712; ---Input amounts List Required.
    out_err_message := sa.get_code_fun('PHONE_PKG', out_err_num, 'ENGLISH');
    RETURN;
  END IF;
  ----
  v_country           := ltrim(rtrim(in_country));
  IF upper(v_Country) IS NULL OR v_Country = ' ' THEN
    v_country         := 'USA';
  END IF;
  FOR i IN v_calc_tax_tbl.first .. v_calc_tax_tbl.last
  LOOP
      IF IS_COUNTRY_TAXABLE(v_country) = 'Y'
      THEN   --CR55657
      V_CALC_TAX_TBL
      (
        I
      )
      .RESULT := 0;
      --V_CALC_TAX_TBL(I).QUANTITY    := 1;
      IF V_CALC_TAX_TBL(I).QUANTITY = 0 THEN
        OUT_ERR_NUM                := -1;
        OUT_ERR_MESSAGE            := 'Need Quantity For Each Line And It Can Not Be Zero';
        RETURN;
      END IF;
      IF v_calc_tax_tbl(i).other_amt > 0 THEN --CR30096 amount can be 0 for B2C
        IF in_ship_zip              IS NULL THEN
          v_zip                     := in_bill_zip;
        ELSE
          v_zip := in_ship_zip;
        END IF;
        v_calc_tax_tbl(i).sub_total_amt   := (v_calc_tax_tbl(i).quantity * NVL(v_calc_tax_tbl(i).other_amt,0))- NVL(v_calc_tax_tbl(i).discount_amt,0);
        IF(v_calc_tax_tbl(i).sub_total_amt < 0) THEN
          v_calc_tax_tbl(i).sub_total_amt :=0;
        END IF;
        v_calc_tax_tbl(i).usf_rate       := '0';--computeUSFtax2(v_zip);
        v_calc_tax_tbl(i).usf_amt        := '0';--ROUND(v_calc_tax_tbl(i).sub_total_amt* v_calc_tax_tbl(i).usf_rate,2);
        v_calc_tax_tbl(i).rcrf_rate      := '0';--computeMISCtax2(v_zip);
        v_calc_tax_tbl(i).rcrf_amt       := '0';--ROUND(v_calc_tax_tbl(i).sub_total_amt* v_calc_tax_tbl(i).rcrf_rate,2);
        v_calc_tax_tbl(i).e911_amt       := '0';--computee911surcharge2(v_zip);
        v_calc_tax_tbl(i).e911_rate      := '0';--computee911tax2(v_zip);
        v_calc_tax_tbl(i).e911_amt       := ROUND(v_calc_tax_tbl(i).e911_amt + v_calc_tax_tbl(i).sub_total_amt * v_calc_tax_tbl(i).e911_rate,2);
        v_calc_tax_tbl(i).stax_rate      := Computetax3(v_zip, NULL); --CR33047
        v_WtyTax                         := ComputeWTYtax(v_zip)                   *get_tppcombstax(v_zip);   -- EME CR39519 - modified to get the tppcombstax--
        v_calc_tax_tbl(i).stax_amt       := ROUND(v_calc_tax_tbl(i).sub_total_amt  * v_calc_tax_tbl(i).stax_rate,2) + ROUND(NVL(v_calc_tax_tbl(i).warranty_amt,0) * v_wtytax,2);
         v_calc_tax_tbl(i).total_tax_amt  :=NVL( (v_calc_tax_tbl(i).usf_amt         + v_calc_tax_tbl(i).e911_amt + v_calc_tax_tbl(i).rcrf_amt + v_calc_tax_tbl(i).stax_amt),0);
        v_calc_tax_tbl(i).total_charges  := NVL(v_calc_tax_tbl(i).sub_total_amt,0) + NVL(v_calc_tax_tbl(i).warranty_amt,0)+ NVL(v_calc_tax_tbl(i).total_tax_amt,0);
        v_calc_tax_tbl(i).message        := 'Success';
      ELSIF V_CALC_TAX_TBL(I).AIRTIME_AMT > 0 THEN--CR30096 amount can be 0 for B2C

        --  dbms_output.put_line('v_calc_tax_tbl(i).quantity  :' || v_calc_tax_tbl(i).quantity );
        v_calc_tax_tbl(i).sub_total_amt := (v_calc_tax_tbl(i).quantity * NVL(v_calc_tax_tbl(i).airtime_amt,0)) - NVL(v_calc_tax_tbl(i).discount_amt,0);
        -- dbms_output.put_line(' v_calc_tax_tbl(i).sub_total_amt :' || v_calc_tax_tbl(i).sub_total_amt);
        IF(v_calc_tax_tbl(i).sub_total_amt < 0) THEN
          v_calc_tax_tbl(i).sub_total_amt :=0;
        END IF;
        v_calc_tax_tbl(i).usf_rate             := computeUSFtax2(in_bill_zip);
        v_calc_tax_tbl(i).usf_amt              := ROUND(v_calc_tax_tbl(i).sub_total_amt * v_calc_tax_tbl(i).usf_rate,2);
        v_calc_tax_tbl(i).rcrf_rate            := computeMISCtax2(in_bill_zip);
        v_calc_tax_tbl(i).rcrf_amt             := ROUND(v_calc_tax_tbl(i).sub_total_amt * v_calc_tax_tbl(i).rcrf_rate,2);
        v_calc_tax_tbl(i).e911_amt             := computee911surcharge2(in_bill_zip);
        v_calc_tax_tbl(i).e911_rate            := computee911tax2(in_bill_zip);
        v_calc_tax_tbl(i).e911_amt             := ROUND(v_calc_tax_tbl(i).e911_amt + v_calc_tax_tbl(i).sub_total_amt * v_calc_tax_tbl(i).e911_rate,2);
        v_calc_tax_tbl(i).stax_rate            := Computetax2(in_bill_zip, NULL);
        v_WtyTax                               := ComputeWTYtax(in_bill_zip)             *get_combstax(in_bill_zip);
        v_calc_tax_tbl(i).stax_amt             := ROUND(v_calc_tax_tbl(i).sub_total_amt  * v_calc_tax_tbl(i).stax_rate,2) + ROUND(NVL(v_calc_tax_tbl(i).warranty_amt,0) * v_wtytax,2);
        v_calc_tax_tbl(i).total_tax_amt        := v_calc_tax_tbl(i).usf_amt              + v_calc_tax_tbl(i).e911_amt + v_calc_tax_tbl(i).rcrf_amt + v_calc_tax_tbl(i).stax_amt;
        v_calc_tax_tbl(i).total_charges        := NVL(v_calc_tax_tbl(i).sub_total_amt,0) + NVL(v_calc_tax_tbl(i).warranty_amt,0)+ NVL(v_calc_tax_tbl(i).total_tax_amt,0);
        v_calc_tax_tbl(i).message              := 'Success';
      ELSIF V_CALC_TAX_TBL(I).WARRANTY_AMT      > 0 THEN--CR30096 amount can be 0 for B2C
        v_calc_tax_tbl(i).sub_total_amt        := 0;
        v_calc_tax_tbl(i).usf_rate             := 0;
        v_calc_tax_tbl(i).usf_amt              := 0;
        v_calc_tax_tbl(i).rcrf_rate            := 0;
        v_calc_tax_tbl(i).rcrf_amt             := 0;
        v_calc_tax_tbl(i).e911_amt             := 0;
        V_CALC_TAX_TBL(I).E911_RATE            := 0;
        v_calc_tax_tbl(i).e911_amt             := 0;
        V_CALC_TAX_TBL(I).STAX_RATE            := 0;
        v_WtyTax                               := (v_calc_tax_tbl(i).quantity * ComputeWTYtax(in_bill_zip)*get_combstax(in_bill_zip));
        V_CALC_TAX_TBL(I).STAX_AMT             := 0;
        V_CALC_TAX_TBL(I).TOTAL_TAX_AMT        := V_WTYTAX ;
        v_calc_tax_tbl(i).total_charges        := (v_calc_tax_tbl(i).quantity * NVL(v_calc_tax_tbl(i).warranty_amt,0)) + v_WtyTax ;
        v_calc_tax_tbl(i).message              := 'Success';
      Elsif v_calc_tax_tbl(i).digital_goods_amt > 0 THEN--CR30096 amount can be 0 for B2C
        v_calc_tax_tbl(i).sub_total_amt        := 0;
        v_calc_tax_tbl(i).usf_rate             := 0;
        v_calc_tax_tbl(i).usf_amt              := 0;
        v_calc_tax_tbl(i).rcrf_rate            := 0;
        v_calc_tax_tbl(i).rcrf_amt             := 0;
        v_calc_tax_tbl(i).e911_amt             := 0;
        v_calc_tax_tbl(i).e911_rate            := 0;
        v_calc_tax_tbl(i).e911_amt             :=0;
        v_calc_tax_tbl(i).stax_rate            := Computetax2(in_bill_zip, NULL);
        v_WtyTax                               := 0;
        v_calc_tax_tbl(i).stax_amt             := ROUND(in_calc_tax(i).sub_total_amt  * in_calc_tax(i).stax_rate,2) + ROUND(NVL(in_calc_tax(i).warranty_amt,0) * v_wtytax,2);
        v_calc_tax_tbl(i).total_tax_amt        := in_calc_tax(i).usf_amt              + in_calc_tax(i).e911_amt + in_calc_tax(i).rcrf_amt + in_calc_tax(i).stax_amt;
        v_calc_tax_tbl(i).total_charges        := NVL(in_calc_tax(i).sub_total_amt,0) + NVL(in_calc_tax(i).warranty_amt,0)+ NVL(in_calc_tax(i).total_tax_amt,0);
        V_CALC_TAX_TBL(I).MESSAGE              := 'Success';
      ELsif  v_calc_tax_tbl(i).dataonly_amt > 0 THEN  -- CR43498 calculate tax for data only cards

        sa.sp_taxes.calctax( ip_zipcode              => in_bill_zip,
                             ip_purchaseamt          => v_calc_tax_tbl(i).quantity*v_calc_tax_tbl(i).dataonly_amt,
                             ip_airtimeamt           => 0,
                             ip_warrantyamt          => 0,
                             ip_dataonlyamt          => v_calc_tax_tbl(i).quantity*v_calc_tax_tbl(i).dataonly_amt,
                             ip_txtonlyamt           => 0,
                             ip_shipamt              => 0,
                             ip_model_type           => NULL,
                             ip_tot_model_type       => NULL,
                             ip_totaldiscountamt     => NVL(v_calc_tax_tbl(i).discount_amt,0),
                             ip_language             => in_language,
                             ip_source               => in_source,
                             ip_country              => in_country,
                             op_combstaxamt          => v_calc_tax_tbl(i).stax_amt,
                             op_e911amt              => v_calc_tax_tbl(i).e911_amt,
                             op_usfamt               => v_calc_tax_tbl(i).usf_amt ,
                             op_rcrfamt              => v_calc_tax_tbl(i).rcrf_amt,
                             op_subtotalamount       => v_calc_tax_tbl(i).sub_total_amt,
                             op_totaltaxamount       => v_calc_tax_tbl(i).total_tax_amt,
                             op_totalcharges         => v_calc_tax_tbl(i).total_charges,
                             op_result               => v_result,
                             op_combstaxrate         => v_calc_tax_tbl(i).stax_rate,
                             op_e911rate             => v_calc_tax_tbl(i).e911_rate,
                             op_usfrate              => v_calc_tax_tbl(i).usf_rate,
                             op_rcrfrate             => v_calc_tax_tbl(i).rcrf_rate ,
                             op_msg                  => v_err_message,
                             ip_partnumbers          => NULL,
                             ip_salestaxonly_amt     => NULL,
                             ip_nac_activation_chrg  => NULL
                           );


    v_calc_tax_tbl(i).message              := 'Success';
        -- CR43498 calculate tax for data only cards
      ELSE
        v_calc_tax_tbl(i).usf_rate      := 0;
        v_calc_tax_tbl(i).usf_amt       := 0;
        v_calc_tax_tbl(i).rcrf_rate     := 0;
        v_calc_tax_tbl(i).rcrf_amt      := 0;
        v_calc_tax_tbl(i).e911_amt      := 0;
        v_calc_tax_tbl(i).e911_rate     := 0;
        v_calc_tax_tbl(i).stax_rate     := 0;
        v_calc_tax_tbl(i).stax_amt      := 0;
        v_calc_tax_tbl(I).TOTAL_TAX_AMT := 0;
        v_calc_tax_tbl(i).total_charges := 0;
        V_CALC_TAX_TBL(I).MESSAGE       := 'Success';
      END IF;
      OUT_STAX_TOT := OUT_STAX_TOT + v_calc_tax_tbl(i).stax_amt ;
      OUT_E911_TOT := OUT_E911_TOT + V_CALC_TAX_TBL(i).E911_AMT ;
      OUT_RCRF_TOT := OUT_RCRF_TOT + v_calc_tax_tbl(i).rcrf_amt ;
      OUT_USF_TOT  := OUT_USF_TOT  + V_CALC_TAX_TBL(I).USF_AMT ;


      OUT_tax_TOT  := OUT_tax_TOT  + v_calc_tax_tbl(i).total_tax_amt;
      OUT_hdr_TOT  := OUT_hdr_TOT  + v_calc_tax_tbl(i).total_charges;

    ELSE
      v_calc_tax_tbl(i).usf_rate      := 0;
      v_calc_tax_tbl(i).usf_amt       := 0;
      v_calc_tax_tbl(i).rcrf_rate     := 0;
      v_calc_tax_tbl(i).rcrf_amt      := 0;
      v_calc_tax_tbl(i).e911_amt      := 0;
      v_calc_tax_tbl(i).e911_rate     := 0;
      v_calc_tax_tbl(i).stax_rate     := 0;
      v_calc_tax_tbl(i).stax_amt      := 0;
      v_calc_tax_tbl(I).TOTAL_TAX_AMT := 0;
      v_calc_tax_tbl(i).total_charges := 0;
      V_CALC_TAX_TBL(I).MESSAGE       := 'Success';
    END IF;
  END LOOP;





  In_Calc_Tax     := V_Calc_Tax_Tbl ;


  ---------------------------------------
   Out_Err_Num     := 0;
   OUT_ERR_MESSAGE := 'Success.';







EXCEPTION
WHEN OTHERS THEN
  Out_Err_Num     := SQLCODE;
  OUT_ERR_MESSAGE := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'SP_TAXES.CALCULATE_TAXES',
      Out_Err_Num,
      OUT_ERR_MESSAGE,
      SYSDATE,
      'SP_TAXES.CALCULATE_TAXES',
      2 -- MEDIUM
    );
END CALCULATE_TAXES;
-------------- Tax calculations for recurring_payments (CR30259) ---------------
FUNCTION Computetax_billing
  (
    p_webuser_objid     IN NUMBER,
    p_program_param     IN NUMBER,
    p_esn               IN VARCHAR2,
    p_pe_payment_source IN NUMBER
  )
  RETURN NUMBER
IS
  l_sales_tax NUMBER;
  --l_zip_code table_contact.zipcode%TYPE;
  l_count NUMBER;
  l_prog_sales_tax_flag x_program_parameters.x_sales_tax_flag%TYPE;
  l_prog_sales_tax_cust x_program_parameters.x_sales_tax_charge_cust%TYPE;
  l_prog_add_tax1 x_program_parameters.x_additional_tax1%TYPE := 0;
  l_prog_add_tax2 x_program_parameters.x_additional_tax2%TYPE := 0;
  bcomputesalestaxflag BOOLEAN;
  V_TAX_SERVICE        NUMBER;
  ----CR13581
  CURSOR Tax_Exempt_Cur
  IS
    SELECT '1'
    FROM X_PROGRAM_ENROLLED,
      X_BUSINESS_ACCOUNTS,
      TABLE_WEB_USER
    WHERE PGM_ENROLL2WEB_USER   = TABLE_WEB_USER.OBJID
    AND BUS_PRIMARY2CONTACT     = WEB_USER2CONTACT
    AND NVL(TAX_EXEMPT,'false') = 'true'
    AND X_Esn                   = P_Esn;
  tax_exempt_rec tax_exempt_cur%rowtype; ----CR13581
  v_WtyTax NUMBER;                         --CR18994 CR22380 Calculate Warranty Taxes
  v_DtaTax NUMBER;                         --CR26033 / CR26274
BEGIN
  -- B2B Tax Exempt ----CR13581
  OPEN Tax_Exempt_Cur;
  FETCH Tax_Exempt_Cur INTO Tax_Exempt_Rec;
  IF Tax_Exempt_Cur%Found THEN
    CLOSE Tax_Exempt_Cur;
    RETURN 0;
  ELSE
    CLOSE Tax_Exempt_Cur;
  END IF; ----CR13581
  -- Check if the program permits taxation.
  IF (p_program_param IS NOT NULL) THEN
    SELECT x_sales_tax_flag,
      x_sales_tax_charge_cust,
      x_additional_tax1,
      x_additional_tax2
    INTO l_prog_sales_tax_flag,
      l_prog_sales_tax_cust,
      l_prog_add_tax1,
      l_prog_add_tax2
    FROM x_program_parameters
    WHERE objid               = p_program_param;
    IF (l_prog_sales_tax_flag = 1) AND (l_prog_sales_tax_cust = 1) THEN
      NULL;
      -- We need to compute sales tax for this scenario.
    ELSE
      RETURN 0;
      -- No tax needs to be computed.
    END IF;
  END IF;
  --  SELECT zipcode
  --  INTO l_zip_code
  --  FROM table_contact con,
  --    table_web_user web
  --  WHERE web.web_user2contact = con.objid
  --  AND web.objid              = p_webuser_objid;
  OPEN CUR_ZIP_PYMT_SRC(p_pe_payment_source);
  FETCH CUR_ZIP_PYMT_SRC INTO L_ZIP;
  IF CUR_ZIP_PYMT_SRC%NOTFOUND THEN
    OPEN CUR_ZIP_WEB_USER(p_webuser_objid);
    FETCH CUR_ZIP_WEB_USER INTO L_ZIP;
    CLOSE CUR_ZIP_WEB_USER;
  END IF;
  CLOSE CUR_ZIP_PYMT_SRC;
  -----
  -- V_TAX_SERVICE := TAX_SERVICE(p_esn); CR11553
  SELECT NVL (MAX (x_combstax), 0)
  INTO l_sales_tax
  FROM table_x_sales_tax
  WHERE 1         = 1
  AND x_zipcode   = L_ZIP -- l_zip_code
  AND x_eff_dt    < SYSDATE
  AND x_non_sales =0;
  --CR18994 CR22380 Calculate Warranty Taxes and added if /Else begin
  IF sa.sp_taxes.is_pgmMONFEE_EXCLUDED_tax_calc(p_program_param,'TAX_CALCULATION','HS_WARRANTY') THEN
    v_WtyTax := sa.sp_taxes.ComputeWTYtax(L_ZIP)*sa.sp_taxes.get_combstax(L_ZIP);
    RETURN NVL (ROUND(v_WtyTax, 4), 0);
  ELSE
    RETURN NVL (ROUND(l_sales_tax, 4), 0);
  END IF;
  --CR18994 CR22380 Calculate Warranty Taxes end
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;

-------------- Tax calculations for recurring_payments (CR30259) ---------------
FUNCTION computee911tax_billing(
    p_webuser_objid     IN NUMBER,
    p_program_param     IN NUMBER,
    p_pe_payment_source IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_e911_tax NUMBER;
  --l_zip_code table_contact.zipcode%TYPE;
  l_count NUMBER;
  l_prog_e911_tax_flag x_program_parameters.x_e911_tax_flag%TYPE;
  l_prog_e911_tax_cust x_program_parameters.x_e911_tax_charge_cust%TYPE;
  bcomputee911taxflag BOOLEAN;
  V_TAX_SERVICE       NUMBER;
BEGIN
  -- Check if the program permits taxation.
  IF (p_program_param IS NOT NULL) THEN
    SELECT x_e911_tax_flag,
      x_e911_tax_charge_cust
    INTO l_prog_e911_tax_flag,
      l_prog_e911_tax_cust
    FROM x_program_parameters
    WHERE objid              = p_program_param;
    IF (l_prog_e911_tax_flag = 1) AND (l_prog_e911_tax_cust = 1) THEN
      NULL;
      -- We need to compute sales tax for this scenario.
    ELSE
      RETURN 0;
      -- No tax needs to be computed.
    END IF;
  END IF;
  --  SELECT zipcode
  --  INTO l_zip_code
  --  FROM table_contact con,
  --    table_web_user web
  --  WHERE web.web_user2contact = con.objid
  --  AND web.objid              = p_webuser_objid;
  -- V_TAX_SERVICE := TAX_SERVICE(p_esn); CR11553
  OPEN CUR_ZIP_PYMT_SRC(p_pe_payment_source);
  FETCH CUR_ZIP_PYMT_SRC INTO L_ZIP;
  IF CUR_ZIP_PYMT_SRC%NOTFOUND THEN
    OPEN CUR_ZIP_WEB_USER(p_webuser_objid);
    FETCH CUR_ZIP_WEB_USER INTO L_ZIP;
    CLOSE CUR_ZIP_WEB_USER;
  END IF;
  CLOSE CUR_ZIP_PYMT_SRC;
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911rate), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = L_ZIP -- l_zip_code
    AND x_eff_dt    < SYSDATE
      -- AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  -- Not required to Add AdditionalTax1 and AdditionalTax2 fields
  RETURN NVL (ROUND (l_e911_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeE911tax

-------------- Tax calculations for recurring_payments (CR30259) ---------------
FUNCTION computee911surcharge_billing(
    p_webuser_objid     IN NUMBER,
    p_program_param     IN NUMBER,
    p_pe_payment_source IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_e911_tax NUMBER;
  --l_zip_code table_contact.zipcode%TYPE;
  l_count NUMBER;
  l_prog_e911_tax_flag x_program_parameters.x_e911_tax_flag%TYPE;
  l_prog_e911_tax_cust x_program_parameters.x_e911_tax_charge_cust%TYPE;
  bcomputee911taxflag BOOLEAN;
  V_TAX_SERVICE       NUMBER;
BEGIN
  -- Check if the program permits taxation.
  IF (p_program_param IS NOT NULL) THEN
    SELECT x_e911_tax_flag,
      X_E911_TAX_CHARGE_CUST
    INTO l_prog_e911_tax_flag,
      l_prog_e911_tax_cust
    FROM x_program_parameters
    WHERE objid              = p_program_param;
    IF (l_prog_e911_tax_flag = 1) AND (l_prog_e911_tax_cust = 1) THEN
      NULL;
      -- We need to compute sales tax for this scenario.
    ELSE
      RETURN 0;
      -- No tax needs to be computed.
    END IF;
  END IF;
  OPEN CUR_ZIP_PYMT_SRC(p_pe_payment_source);
  FETCH CUR_ZIP_PYMT_SRC INTO L_ZIP;
  IF CUR_ZIP_PYMT_SRC%NOTFOUND THEN
    OPEN CUR_ZIP_WEB_USER(p_webuser_objid);
    FETCH CUR_ZIP_WEB_USER INTO L_ZIP;
    CLOSE CUR_ZIP_WEB_USER;
  END IF;
  CLOSE CUR_ZIP_PYMT_SRC;
  --V_TAX_SERVICE := TAX_SERVICE(p_esn); CR22380 removing ESN
  SELECT *
  INTO l_e911_tax
  FROM
    (SELECT NVL (MAX (x_e911surcharge), 0)
    FROM table_x_sales_tax
    WHERE x_zipcode = L_ZIP --l_zip_code
    AND x_eff_dt    < SYSDATE
      -- AND x_non_sales =0
    ORDER BY x_eff_dt DESC
    )
  WHERE ROWNUM < 2;
  -- Not required to Add AdditionalTax1 and AdditionalTax2 fields
  RETURN NVL (ROUND (l_e911_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeE911taxsurcharge

-------------- Tax calculations for recurring_payments (CR30259) ---------------
FUNCTION computeUSFtax_billing(
    p_webuser_objid     IN NUMBER,
    p_program_param     IN NUMBER,
    p_pe_payment_source IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_usf_tax NUMBER;
  --l_zip_code table_contact.zipcode%TYPE;
  l_count             NUMBER;
  bcomputee911taxflag BOOLEAN;
  -- V_TAX_SERVICE NUMBER; CR11553
BEGIN
  IF sa.sp_taxes.is_pgmMONFEE_EXCLUDED_tax_calc(p_program_param,'TAX_CALCULATION','HS_WARRANTY') THEN
    l_usf_tax := 0;
  ELSE
    OPEN CUR_ZIP_PYMT_SRC(p_pe_payment_source);
    FETCH CUR_ZIP_PYMT_SRC INTO L_ZIP;
    IF CUR_ZIP_PYMT_SRC%NOTFOUND THEN
      OPEN CUR_ZIP_WEB_USER(p_webuser_objid);
      FETCH CUR_ZIP_WEB_USER INTO L_ZIP;
      CLOSE CUR_ZIP_WEB_USER;
    END IF;
    CLOSE CUR_ZIP_PYMT_SRC;
    SELECT *
    INTO l_usf_tax
    FROM
      (SELECT NVL (MAX (x_usf_taxrate), 0)
      FROM table_x_sales_tax
      WHERE x_zipcode = L_ZIP --l_zip_code
      AND x_eff_dt    < SYSDATE
      ORDER BY x_eff_dt DESC
      )
    WHERE ROWNUM < 2;
    -- pick up the first record only
    -- END IF; cr11553
  END IF; --CR22380 Handset Protection if / else added
  RETURN NVL (ROUND (l_usf_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- End of computeUSFtax

-------------- Tax calculations for recurring_payments (CR30259) ---------------
FUNCTION computeMISCtax_billing(
    p_webuser_objid     IN NUMBER,
    p_program_param     IN NUMBER,
    p_pe_payment_source IN NUMBER
    --p_esn IN VARCHAR2 CR22380 removing ESN
  )
  RETURN NUMBER
IS
  l_misc_tax NUMBER;
  --l_zip_code table_contact.zipcode%TYPE;
  l_count             NUMBER;
  bcomputee911taxflag BOOLEAN;
  -- V_TAX_SERVICE NUMBER; CR11553
BEGIN
  --CR22380 Handset Protection if / else added
  IF sa.sp_taxes.is_pgmMONFEE_EXCLUDED_tax_calc(p_program_param,'TAX_CALCULATION','HS_WARRANTY') THEN
    l_misc_tax := 0;
  ELSE
    --    SELECT zipcode
    --    INTO l_zip_code
    --    FROM table_contact con,
    --      table_web_user web
    --    WHERE web.web_user2contact = con.objid
    --    AND web.objid              = p_webuser_objid;
    OPEN CUR_ZIP_PYMT_SRC(p_pe_payment_source);
    FETCH CUR_ZIP_PYMT_SRC INTO L_ZIP;
    IF CUR_ZIP_PYMT_SRC%NOTFOUND THEN
      OPEN CUR_ZIP_WEB_USER(p_webuser_objid);
      FETCH CUR_ZIP_WEB_USER INTO L_ZIP;
      CLOSE CUR_ZIP_WEB_USER;
    END IF;
    CLOSE CUR_ZIP_PYMT_SRC;
    --  V_TAX_SERVICE := TAX_SERVICE(p_esn); CR11553
    SELECT *
    INTO l_misc_tax
    FROM
      (SELECT NVL (MAX (X_RCRFRATE), 0) --change name for cr11553
      FROM table_x_sales_tax
      WHERE x_zipcode = L_ZIP --l_zip_code
      AND x_eff_dt    < SYSDATE
        --and x_non_sales = 0
      ORDER BY x_eff_dt DESC
      )
    WHERE ROWNUM < 2;
    -- pick up the first record only
  END IF; --CR22380 Handset Protection if / else added
  RETURN NVL (ROUND (l_misc_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;

-------------- Tax calculations for recurring_payments (CR30259) ---------------
FUNCTION TAX_RULES_PROGS_DATA_BILLING(
    P_PE_OBJID IN VARCHAR2)
  RETURN VARCHAR2
IS
  --------------------------------------------------------------------------------------------

  --similar to TAX_RULES_PROGRAMS_DATA_FUN
  --but needed to make large changes for recurring programs, better to put this in sp_taxes
  --to calculate taxes different than airtime
  --------------------------------------------------------------------------------------------
  --X_HOME_ALERT_NON_SALES  NOT NULL NUMBER
  --X_DATA_NON_SALES        NOT NULL NUMBER
  --X_NON_SHIPPING          NOT NULL NUMBER
  --X_CAR_CONNECT_NON_SALES NOT NULL NUMBER
  CURSOR data_tax_cur (P_PE_objid NUMBER )
  IS
    SELECT pn.part_number --, pp.*, e.*
    FROM table_part_num pn,
      x_program_parameters pp,
      x_program_enrolled e
    WHERE 1                        =1
    AND (pn.objid                  = pp.prog_param2prtnum_monfee
    OR pn.objid                    = pp.prog_param2prtnum_enrlfee
    OR pn.objid                    = pp.prog_param2prtnum_grpmonfee
    OR pn.objid                    = pp.prog_param2prtnum_grpenrlfee)
    AND e.pgm_enroll2pgm_parameter = pp.objid
    AND (pn.x_card_type            ='DATA CARD')
    AND rownum                     < 2
    AND e.objid                    = P_PE_OBJID ; --41256291;  --1340665945 --
  data_TAX_REC data_TAX_CUR%ROWTYPE ;
  CURSOR find_data_flag_cur1 (P_PE_OBJID VARCHAR2)
  IS
    SELECT tax.x_zipcode,
      x_data_non_sales
    FROM TABLE_ADDRESS ADR,
      TABLE_COUNTRY CNTR,
      TABLE_X_BANK_ACCOUNT BANK,
      X_PAYMENT_SOURCE PYMTSRC,
      table_x_sales_tax tax,
      X_PROGRAM_ENROLLED PE
    WHERE ADR.OBJID              = BANK.X_BANK_ACCT2ADDRESS
    AND CNTR.OBJID(+)            = ADR.ADDRESS2COUNTRY
    AND BANK.OBJID               = PYMTSRC.PYMT_SRC2X_BANK_ACCOUNT
    AND BANK.X_STATUS            = 'ACTIVE'
    AND PYMTSRC.X_STATUS         = 'ACTIVE'
    AND ADR.ZIPCODE              = TAX.X_ZIPCODE
    AND PE.OBJID                 = P_PE_OBJID -- 40122198 --
    AND PE.PGM_ENROLL2X_PYMT_SRC = PYMTSRC.OBJID
  UNION
  SELECT tax.x_zipcode,
    x_data_non_sales
  FROM TABLE_ADDRESS ADR,
    TABLE_COUNTRY CNTR,
    TABLE_X_CREDIT_CARD CC,
    X_PAYMENT_SOURCE PYMTSRC,
    table_x_sales_tax tax,
    X_PROGRAM_ENROLLED PE
  WHERE ADR.OBJID              = CC.X_CREDIT_CARD2ADDRESS
  AND CNTR.OBJID(+)            = ADR.ADDRESS2COUNTRY
  AND CC.OBJID                 = PYMTSRC.PYMT_SRC2X_CREDIT_CARD
  AND CC.X_CARD_STATUS         = 'ACTIVE'
  AND PYMTSRC.X_STATUS         = 'ACTIVE'
  AND ADR.ZIPCODE              = TAX.X_ZIPCODE
  AND PE.OBJID                 = P_PE_OBJID -- 40122198 --
  AND PE.PGM_ENROLL2X_PYMT_SRC = PYMTSRC.OBJID ;
  find_data_flag_rec1 find_data_flag_cur1%rowtype ;

  CURSOR find_data_flag_cur2 (P_PE_OBJID VARCHAR2)
  IS
    SELECT tax.x_zipcode,
      x_data_non_sales
    FROM x_program_enrolled pe,
      table_web_user wu,
      table_contact c,
      table_x_sales_tax tax
    WHERE pe.pgm_enroll2web_user=wu.objid
    AND wu.web_user2contact     = c.objid
    AND c.zipcode               = tax.x_zipcode
    AND x_eff_dt                < sysdate
    AND rownum                  < 2
    AND pe.objid                = P_PE_OBJID ;
  find_data_flag_rec2 find_data_flag_cur2%rowtype ;
  v_data_tax_rule      VARCHAR2 (30) DEFAULT 'NORMAL TAX';
  v_tax_specifications NUMBER DEFAULT 3 ;
BEGIN
  OPEN data_tax_cur (P_PE_OBJID) ;
  FETCH data_tax_cur INTO data_tax_rec ;
  IF data_tax_cur%FOUND THEN
    CLOSE data_tax_cur;
  ELSE
    CLOSE data_tax_cur ;
    RETURN 'FULL TAX' ;
  END IF;
  OPEN find_data_flag_cur1 (P_PE_OBJID) ;
  FETCH find_data_flag_cur1 INTO find_data_flag_rec1;
  IF find_data_flag_cur1%FOUND THEN
    CLOSE find_data_flag_cur1;
    v_tax_specifications := find_data_flag_rec1.x_data_non_sales ;
  ELSE
    CLOSE find_data_flag_cur1 ;
    OPEN find_data_flag_cur2 (P_PE_OBJID) ;
    FETCH find_data_flag_cur2 INTO find_data_flag_rec2;
    IF find_data_flag_cur2%FOUND THEN
      CLOSE find_data_flag_cur2;
      v_tax_specifications := find_data_flag_rec2.x_data_non_sales ;
    ELSE
      CLOSE find_data_flag_cur2;
      RETURN 'FULL TAX' ;
    END IF;
  END IF;
  IF v_tax_specifications    = 1 THEN
    v_data_tax_rule         := 'NO TAX' ;
  elsif v_tax_specifications = 0 THEN
    v_data_tax_rule         := 'SALES TAX ONLY' ;
  ELSE
    v_data_tax_rule := 'FULL TAX' ;
  END IF ;
  RETURN v_data_tax_rule;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END TAX_RULES_PROGS_DATA_BILLING;

-------------- Tax calculations for recurring_payments (CR30259) ---------------

--------------------CR32572 BEGIN TXT TAX
FUNCTION TAX_RULES_PROGS_TXT_BILLING(
    P_PE_OBJID IN VARCHAR2)
  RETURN VARCHAR2
IS
  --------------------------------------------------------------------------------------------

  --similar to TAX_RULES_PROGRAMS_DATA_FUN
  --but needed to make large changes for recurring programs, better to put this in sp_taxes
  --to calculate taxes different than airtime
  --------------------------------------------------------------------------------------------
  --X_HOME_ALERT_NON_SALES  NOT NULL NUMBER
  --X_DATA_NON_SALES        NOT NULL NUMBER
  --X_NON_SHIPPING          NOT NULL NUMBER
  --X_CAR_CONNECT_NON_SALES NOT NULL NUMBER


  ----CR32572 TEXT ONLY
  CURSOR TXT_tax_cur (P_PE_objid NUMBER )
  IS
    SELECT pn.part_number --, pp.*, e.*
    FROM table_part_num pn,
      x_program_parameters pp,
      x_program_enrolled e
    WHERE 1                        =1
    AND (pn.objid                  = pp.prog_param2prtnum_monfee
    OR pn.objid                    = pp.prog_param2prtnum_enrlfee
    OR pn.objid                    = pp.prog_param2prtnum_grpmonfee
    OR pn.objid                    = pp.prog_param2prtnum_grpenrlfee)
    AND e.pgm_enroll2pgm_parameter = pp.objid
    AND (pn.x_card_type            ='TEXT ONLY')
    AND rownum                     < 2
    AND e.objid                    = P_PE_OBJID ; --41256291;  --1340665945 --
  TXT_TAX_REC txt_TAX_CUR%ROWTYPE ;

  CURSOR find_TXT_flag_cur1 (P_PE_OBJID VARCHAR2)
  IS
    SELECT tax.x_zipcode,
      X_2WAYTEXT_SALES
    FROM TABLE_ADDRESS ADR,
      TABLE_COUNTRY CNTR,
      TABLE_X_BANK_ACCOUNT BANK,
      X_PAYMENT_SOURCE PYMTSRC,
      table_x_sales_tax tax,
      X_PROGRAM_ENROLLED PE
    WHERE ADR.OBJID              = BANK.X_BANK_ACCT2ADDRESS
    AND CNTR.OBJID(+)            = ADR.ADDRESS2COUNTRY
    AND BANK.OBJID               = PYMTSRC.PYMT_SRC2X_BANK_ACCOUNT
    AND BANK.X_STATUS            = 'ACTIVE'
    AND PYMTSRC.X_STATUS         = 'ACTIVE'
    AND ADR.ZIPCODE              = TAX.X_ZIPCODE
    AND PE.OBJID                 = P_PE_OBJID -- 40122198 --
    AND PE.PGM_ENROLL2X_PYMT_SRC = PYMTSRC.OBJID
  UNION
  SELECT tax.x_zipcode,
    X_2WAYTEXT_SALES
  FROM TABLE_ADDRESS ADR,
    TABLE_COUNTRY CNTR,
    TABLE_X_CREDIT_CARD CC,
    X_PAYMENT_SOURCE PYMTSRC,
    table_x_sales_tax tax,
    X_PROGRAM_ENROLLED PE
  WHERE ADR.OBJID              = CC.X_CREDIT_CARD2ADDRESS
  AND CNTR.OBJID(+)            = ADR.ADDRESS2COUNTRY
  AND CC.OBJID                 = PYMTSRC.PYMT_SRC2X_CREDIT_CARD
  AND CC.X_CARD_STATUS         = 'ACTIVE'
  AND PYMTSRC.X_STATUS         = 'ACTIVE'
  AND ADR.ZIPCODE              = TAX.X_ZIPCODE
  AND PE.OBJID                 = P_PE_OBJID -- 40122198 --
  AND PE.PGM_ENROLL2X_PYMT_SRC = PYMTSRC.OBJID ;
  find_txt_flag_rec1 find_txt_flag_cur1%rowtype ;

  CURSOR find_txt_flag_cur2 (P_PE_OBJID VARCHAR2)
  IS
    SELECT tax.x_zipcode,
      X_2WAYTEXT_SALES
    FROM x_program_enrolled pe,
      table_web_user wu,
      table_contact c,
      table_x_sales_tax tax
    WHERE pe.pgm_enroll2web_user=wu.objid
    AND wu.web_user2contact     = c.objid
    AND c.zipcode               = tax.x_zipcode
    AND x_eff_dt                < sysdate
    AND rownum                  < 2
    AND pe.objid                = P_PE_OBJID ;
  find_txt_flag_rec2 find_txt_flag_cur2%rowtype ;
  v_txt_tax_rule      VARCHAR2 (30) DEFAULT 'NORMAL TAX';
  v_tax_specifications NUMBER DEFAULT 3 ;
BEGIN
  OPEN txt_tax_cur (P_PE_OBJID) ;
  FETCH txt_tax_cur INTO txt_tax_rec ;
  IF txt_tax_cur%FOUND THEN
    CLOSE txt_tax_cur;
  ELSE
    CLOSE txt_tax_cur ;
    RETURN 'FULL TAX' ;
  END IF;
  OPEN find_txt_flag_cur1 (P_PE_OBJID) ;
  FETCH find_txt_flag_cur1 INTO find_txt_flag_rec1;
  IF find_txt_flag_cur1%FOUND THEN
    CLOSE find_txt_flag_cur1;
    v_tax_specifications := find_txt_flag_rec1.X_2WAYTEXT_SALES  ;
  ELSE
    CLOSE find_txt_flag_cur1 ;
    OPEN find_txt_flag_cur2 (P_PE_OBJID) ;
    FETCH find_txt_flag_cur2 INTO find_txt_flag_rec2;
    IF find_txt_flag_cur2%FOUND THEN
      CLOSE find_txt_flag_cur2;
      v_tax_specifications := find_txt_flag_rec2.X_2WAYTEXT_SALES ;
    ELSE
      CLOSE find_txt_flag_cur2;
      RETURN 'FULL TAX' ;
    END IF;
  END IF;
  IF v_tax_specifications    = 1 THEN
    v_txt_tax_rule         := 'NO TAX' ;
  elsif v_tax_specifications = 0 THEN
    v_txt_tax_rule         := 'SALES TAX ONLY' ;
  ELSE
    v_txt_tax_rule := 'FULL TAX' ;
  END IF ;
  RETURN v_txt_tax_rule;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END TAX_RULES_PROGS_txt_BILLING;

-------------- CR32572 END TXT TAX



FUNCTION TAX_RULES_BILLING(
    P_esn IN VARCHAR2)
  RETURN VARCHAR2
IS
  --X_HOME_ALERT_NON_SALES  NOT NULL NUMBER
  --X_DATA_NON_SALES        NOT NULL NUMBER
  --X_NON_SHIPPING          NOT NULL NUMBER
  --X_CAR_CONNECT_NON_SALES NOT NULL NUMBER
  CURSOR c1
  IS
    SELECT pc.name
    FROM table_part_class pc,
      table_part_num pn,
      table_mod_level ml,
      table_part_inst pi
    WHERE pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num     = pn.objid
    AND pn.part_num2part_class    = pc.objid
    AND pi.part_serial_no         = P_esn; --'100000000013246789' ;
  r1 c1%ROWTYPE;
  -----------------------------------------------
  CURSOR c2
  IS
    SELECT tax.x_zipcode,
      x_home_alert_non_sales,
      x_car_connect_non_sales
      --SELECT ADR.ZIPCODE
    FROM TABLE_ADDRESS ADR,
      TABLE_COUNTRY CNTR,
      TABLE_X_BANK_ACCOUNT BANK,
      X_PAYMENT_SOURCE PYMTSRC,
      x_program_enrolled pe,
      table_x_sales_tax tax
    WHERE ADR.OBJID              = BANK.X_BANK_ACCT2ADDRESS
    AND CNTR.OBJID(+)            = ADR.ADDRESS2COUNTRY
    AND BANK.OBJID               = PYMTSRC.PYMT_SRC2X_BANK_ACCOUNT
    AND BANK.X_STATUS            = 'ACTIVE'
    AND PYMTSRC.X_STATUS         = 'ACTIVE'
    AND PE.PGM_ENROLL2X_PYMT_SRC = PYMTSRC.OBJID
    AND pe.x_esn                 = P_esn -- '100000000013246789'
    AND tax.x_zipcode            = ADR.ZIPCODE
  UNION
  SELECT tax.x_zipcode,
    x_home_alert_non_sales,
    x_car_connect_non_sales
    --SELECT ADR.ZIPCODE
  FROM TABLE_ADDRESS ADR,
    TABLE_COUNTRY CNTR,
    TABLE_X_CREDIT_CARD CC,
    X_PAYMENT_SOURCE PYMTSRC,
    x_program_enrolled pe,
    table_x_sales_tax tax
  WHERE ADR.OBJID              = CC.X_CREDIT_CARD2ADDRESS
  AND CNTR.OBJID(+)            = ADR.ADDRESS2COUNTRY
  AND CC.OBJID                 = PYMTSRC.PYMT_SRC2X_CREDIT_CARD
  AND CC.X_CARD_STATUS         = 'ACTIVE'
  AND PYMTSRC.X_STATUS         = 'ACTIVE'
  AND PE.PGM_ENROLL2X_PYMT_SRC = PYMTSRC.OBJID
  AND PE.PGM_ENROLL2X_PYMT_SRC = PYMTSRC.OBJID
  AND pe.x_esn                 = P_esn -- '100000000013246789'
  AND tax.x_zipcode            = ADR.ZIPCODE;
  r2 c2%ROWTYPE;
  -----------------------------------------------
  CURSOR c3
  IS
    SELECT tax.x_zipcode,
      x_home_alert_non_sales,
      x_car_connect_non_sales
    FROM x_program_enrolled pe,
      table_web_user wu,
      table_contact c,
      table_x_sales_tax tax
    WHERE pe.pgm_enroll2web_user = wu.objid
    AND wu.web_user2contact      = c.objid
    AND c.zipcode                = tax.x_zipcode
    AND x_eff_dt                 < SYSDATE
    AND pe.x_esn                 = P_esn -- '100000000013246789'
    AND ROWNUM                   < 2;
  r3 c3%ROWTYPE;
  -----------------------------------------------
  v_tax_rule           VARCHAR2 (30) DEFAULT 'NORMAL TAX';
  v_tax_specifications NUMBER DEFAULT 3;
  v_model_type         VARCHAR2 (30);
BEGIN
  OPEN c1;
  FETCH c1 INTO r1;
  IF c1%FOUND THEN
    CLOSE c1;
    v_model_type := get_param_by_name_fun (r1.name, 'MODEL_TYPE');
  ELSE
    CLOSE c1;
    RETURN 'FULL TAX' ;
  END IF;
  OPEN c2;
  FETCH c2 INTO r2;
  IF c2%FOUND THEN
    CLOSE c2;
    IF v_model_type         = 'HOME ALERT' THEN
      v_tax_specifications := r2.x_home_alert_non_sales;
    END IF;
    IF v_model_type         = 'CAR CONNECT' THEN
      v_tax_specifications := r2.x_car_connect_non_sales;
    END IF;
  ELSE
    CLOSE c2 ;
    OPEN c3;
    FETCH c3 INTO r3;
    IF C3%FOUND THEN
      CLOSE c3;
      IF v_model_type         = 'HOME ALERT' THEN
        v_tax_specifications := r3.x_home_alert_non_sales;
      END IF;
      IF v_model_type         = 'CAR CONNECT' THEN
        v_tax_specifications := r3.x_car_connect_non_sales;
      END IF;
    ELSE
      CLOSE c3;
      RETURN 'FULL TAX' ;
    END IF;
  END IF;
  IF v_tax_specifications    = 1 THEN
    v_tax_rule              := 'NO TAX' ;
  elsif v_tax_specifications = 0 THEN
    v_tax_rule              := 'SALES TAX ONLY' ;
  ELSE
    v_tax_rule := 'FULL TAX' ;
  END IF ;
  RETURN v_tax_rule;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END TAX_RULES_BILLING;
---------------- BEGINNING OF CR31683 -------------------------------------------------------------------------------------------------
PROCEDURE GET_TAX_SCRIPT_PRC
  (
    p_zip_tbl        IN OUT zip_script_rec_tbl
   ,ip_language      IN VARCHAR2 DEFAULT 'ENGLISH' -- required
   ,ip_source_system IN VARCHAR2 DEFAULT 'WEB' --WEB,WEBCSR,ALL
   ,IP_BRAND_NAME    IN VARCHAR2 DEFAULT 'NET10' -- required
  ) IS
    ------------------- VARIABLE DECLARATIONS
    v_language VARCHAR2 (10);
    v_script_text         VARCHAR2(4000); -- CAPTURE DEFAULT SCRIPT PRC OP
    v_label          VARCHAR2(4000); -- CAPTURE DEFAULT SCRIPT PRC OP
    v_description  VARCHAR2(400); -- CAPTURE DEFAULT SCRIPT PRC OP
    v_publish_by   VARCHAR2(400); -- CAPTURE DEFAULT SCRIPT PRC OP
    v_publish_date DATE; -- CAPTURE DEFAULT SCRIPT PRC OP
    v_sm_link      VARCHAR2(1000); -- CAPTURE DEFAULT SCRIPT PRC OP
    v_objid        VARCHAR2(100); -- CAPTURE DEFAULT SCRIPT PRC OP
    v_err_msg      VARCHAR2(400);
    l_tax_footer     sa.STATE_TAX_SCRIPT.TAX_FOOTER_ID%TYPE; -- LOCAL VAR 2 HOLD THE NOTE
    l_script_id      sa.table_x_scripts.x_script_id%TYPE; -- LOCAL VAR TO HOLD THE SCRIPT ID PORTION OF NOTE
    l_script_type    sa.table_x_scripts.x_script_type%TYPE; -- LOCAL VAR TO HOLD THE SCRIPT TYPE PORTION OF NOTE
    v_state sa.STATE_TAX_SCRIPT.X_STATE%TYPE; -- LOCAL VAR 2 HOLD THE CORESPONDING TO THE ZIPCODE
------------------- BEGIN MAIN -------------------
  BEGIN
    IF p_zip_tbl.count = 0 -- IF 1
     THEN
      v_err_msg := 'Error in input parameters. Zip code required';
      util_pkg.insert_error_tab_proc
                     ( ip_action  => 'MISSING ZIP CODE'
                       ,ip_key     => 'INPUT ZIPCODE MISSING'
                       ,ip_program_name => 'SA.SP_TAXES.GET_TAX_SCRIPT_PRC'
                       ,ip_error_text         => v_err_msg
                      );
      RETURN;
    END IF; -- END OF IF 1
    --  dbms_output.put_line('count = '||p_zip_tbl.count);
    FOR i IN 1 .. p_zip_tbl.count LOOP
      BEGIN
        begin
          SELECT x_state
           INTO v_state
           FROM Table_x_sales_tax
           WHERE x_zipcode = p_zip_tbl(i).zip_code
          and rownum < 2;
         exception
            when others then
            v_state := 'DEF_NONSTR';
        end;

        begin
           SELECT TAX_FOOTER_ID
            INTO l_tax_footer
            FROM STATE_TAX_SCRIPT
            WHERE x_state = v_state;
        exception
          when others then
            l_tax_footer := null;
        end;

       if l_tax_footer is null then
           v_state := 'DEF_NONSTR';-- get default script
           SELECT TAX_FOOTER_ID
               INTO l_tax_footer
               FROM STATE_TAX_SCRIPT
               WHERE x_state = v_state;
       end if;
       l_script_type :=
          UPPER(SUBSTR(l_tax_footer,1,INSTR(l_tax_footer,'_')- 1));
       l_script_id :=
         (SUBSTR(l_tax_footer,INSTR(l_tax_footer,'_') + 1));
    ------------- CALLS TO GET_SCRIPT PROCEDURE ----
      IF (l_script_type IS NOT NULL AND l_script_id IS NOT NULL) THEN
          -------- GET SCRIPT LANGUAGE ----------------------
          --     dbms_output.put_line('Calling ' );
         BEGIN
          SELECT DECODE(ip_language,
                            'ENG','ENGLISH',
                            'EN','ENGLISH',
                            'SPA','SPANISH',
                            'SP','SPANISH',
                            'ES','SPANISH',
                            ip_language)
          INTO v_language
          FROM DUAL;

          sp_taxes.get_e911_script
                (  v_language
                  ,ip_source_system
                  ,p_zip_tbl(i).zip_code
                  ,IP_BRAND_NAME
                  ,v_label
                  ,p_zip_tbl(i).result
                  ,v_description );

         sa.scripts_pkg.get_script_prc
                                ( ip_source_system --WEB,WEBCSR,ALL
                                   ,IP_BRAND_NAME --TRACFONE,NET10,STRAIGHT_TALK
                                   ,l_script_type -- IN script type
                                   ,l_script_id -- IN script ID
                                   ,v_language -- IN default 'ENGLISH' required
                                   ,NULL --IP_CARRIER_ID
                                   ,NULL --IP_PART_CLASS
                                   ,v_objid --OUT
                                   ,v_description -- OUT
                                   ,v_script_text -- OUT
                                   ,v_publish_by -- OUT
                                   ,v_publish_date -- OUT
                                   ,v_sm_link -- OUT
                                 );
         EXCEPTION
           WHEN others THEN dbms_output.put_line(SQLERRM);
         END;
          --    dbms_output.put_line('Back -'||v_script_text );
      ELSE
          sp_taxes.get_e911_script
                              (  ip_language
                                ,ip_source_system
                                ,p_zip_tbl(i).zip_code
                                ,IP_BRAND_NAME
                                ,v_script_text
                                ,p_zip_tbl(i).result
                                ,v_description
                              );
      END IF;

       p_zip_tbl(i).footer_text := replace ( v_script_text,'<sup>2</sup> ','<sup>2</sup> '||replace(v_label,'<sup>2</sup>',' ')||'. ');
       p_zip_tbl(i).result := '0';
      ---- loop exception
      EXCEPTION
        WHEN others THEN
          p_zip_tbl(i).result := '1';
          v_err_msg := SUBSTR(SQLERRM,1,300);
          util_pkg.insert_error_tab_proc
                      ( ip_action=> 'FAILED GETTING TAX SCRIPT BY ZIP CODE'
                        ,ip_key  => p_zip_tbl(i).zip_code
                        ,ip_program_name => 'SA.SP_TAXES.GET_TAX_SCRIPT_PRC'
                        ,ip_error_text   => v_err_msg
                      );
      END; -- loop exception
    END LOOP;
    ------------------ PRPC EXCEPTIONS  ------------------
  EXCEPTION
    WHEN others THEN
      v_err_msg := SUBSTR(SQLERRM,1,300);
      util_pkg.insert_error_tab_proc
                  ( ip_action => 'Failed GET_TAX_SCRIPT'
                    ,ip_key   => 'TAX_SCRIPT SQL ERROR'
                    ,ip_program_name => 'SA.SP_TAXES.GET_TAX_SCRIPT_PRC'
                    ,ip_error_text   => v_err_msg
                  );
      ------------------- END OF MAIN ------------------
  END GET_TAX_SCRIPT_PRC;
---------------- END OF CR31683 -------------------------------------------------------------------------------------------------
---------------------------------------------------------
-- EME CR39519--
FUNCTION get_tppcombstax(
    p_zipcode IN VARCHAR2 )
  RETURN NUMBER
IS
  l_sales_tax NUMBER;
BEGIN
  SELECT NVL(MAX (tpp_combtax), 0)
  INTO l_sales_tax
  FROM table_x_sales_tax
  WHERE 1       = 1
  AND x_zipcode = p_zipcode
  AND x_eff_dt  < SYSDATE ;
  RETURN NVL (ROUND(l_sales_tax, 4), 0);
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END get_tppcombstax;
-- EME CR39519--


 -----CR52959 BEGIN  USF and RCR Taxes Exception
PROCEDURE get_tax_flag ( i_source         IN  VARCHAR2 ,
                         o_tax_usf_flag   OUT VARCHAR2 ,
                         o_tax_rcrf_flag  OUT VARCHAR2 ) IS

BEGIN



  -- Fetching the Tax Flags values for the the coming SourceChannel
  SELECT NVL(UPPER(suppress_tax_usf_flag),'Y'),
         NVL(UPPER(suppress_tax_rcrf_flag),'Y')
  INTO   o_tax_usf_flag,
         o_tax_rcrf_flag
  FROM   table_channel
  WHERE  title = i_source;


 EXCEPTION
  WHEN OTHERS THEN
    o_tax_usf_flag   := 'Y';
    o_tax_rcrf_flag  := 'Y';
END get_tax_flag;
----- CR52959 END USF and RCR Taxes Exception

---BEGIN CR52959 EGIN  USF and RCR Taxes Exception
PROCEDURE GET_TAX_AMT(i_source_system IN  VARCHAR2,
                      o_usf_tax_amt   IN  OUT NUMBER,
                      o_rcrf_tax_amt  IN  OUT NUMBER,
                      o_usf_percent   IN  OUT NUMBER,
                      o_rcrf_percent  IN  OUT NUMBER
                     )
IS
l_tax_usf_flag   VARCHAR2(1);
l_tax_rcrf_flag  VARCHAR2(1);
BEGIN

-- Calling the get_tax_flag to get the flags set for the source system
 sp_taxes.get_tax_flag (i_source        => i_source_system  ,
                        o_tax_usf_flag  => l_tax_usf_flag   ,
                        o_tax_rcrf_flag => l_tax_rcrf_flag
                       );

-- if the USF flag is N then don't calculate the USF Tax Amt
IF l_tax_usf_flag = 'N'
THEN
o_usf_tax_amt := 0;
o_usf_percent := 0;
END IF;

IF l_tax_rcrf_flag = 'N'
THEN
o_rcrf_tax_amt  := 0;
o_rcrf_percent  := 0;
END IF;


END GET_TAX_AMT;
---END CR52959 EGIN  USF and RCR Taxes Exception

--CR49915 WFM LIFELINE changes start
--New overloaded procedure calculate_taxes
/****************************************************************************************************
* Procedure Name: calculate_taxes                                                                   *
* Purpose       : This is a new oveloaded procedure created for LIFELINE and below is the logic     *
*                                                                                                   *
*  1. This procedure will accept a new additional parameter taxable_discount_amt in the input table *
*  2. If the taxable discount amout is NULL or 0, then it will calculate the taxes using existing   *
*     calculate_taxes procedure.                                                                    *
*  3. If the taxable discount amount is > 0, then it will first calculate the tax using existing    *
*     procedure.                                                                                    *
*  4. After calculating the above tax, it will calculate the tax on the taxable_discount_amt based  *
*     on the tax rules defined in LL_TAX_RULES table for state of given zipcode.                    *
*  5. If tax rules were not defined for the state of given zipcode, then no tax will be calculated  *
*     on the taxable_discount_amt                                                                   *
****************************************************************************************************/
PROCEDURE calculate_taxes
  (
    in_bill_zip IN VARCHAR2,
    in_ship_zip IN VARCHAR2,
    in_calc_tax IN OUT calc_tax_tbl,
    in_total_discount_amt NUMBER,
    in_language        IN VARCHAR2,
    in_source          IN VARCHAR2,
    in_country         IN VARCHAR2,
    IN_TAX_EXEMPT_TYPE IN VARCHAR2,
    OUT_USF_TOT OUT NUMBER,
    OUT_RCRF_TOT OUT NUMBER,
    OUT_E911_TOT OUT NUMBER,
    OUT_STAX_TOT OUT NUMBER,
    OUT_tax_TOT OUT NUMBER,
    OUT_hdr_TOT OUT NUMBER,
    out_err_num OUT NUMBER,
    out_err_Message OUT VARCHAR2
  )
IS
  --Local variables
  v_country  VARCHAR2(50);
  V_WTYTAX   NUMBER;
  v_calc_base_tax_tbl typ_calc_tax_tbl := typ_calc_tax_tbl();
  v_err_message VARCHAR2(300);
  v_result  NUMBER;

  N_DISC_USF_TOT      NUMBER;
  N_DISC_RCRF_TOT     NUMBER;
  N_DISC_E911_TOT     NUMBER;
  N_DISC_STAX_TOT     NUMBER;
  N_DISC_TAX_TOT      NUMBER;
  N_DISC_HDR_TOT      NUMBER;

  n_apply_usf         NUMBER;
  n_apply_rcr         NUMBER;
  n_apply_e911        NUMBER;
  n_apply_combstax    NUMBER;
BEGIN
  IF IN_CALC_TAX IS NULL
  THEN
    out_err_num := '9001';
    out_err_Message  := 'NO RECORDS FOUND IN THE INPUT TO CALCULATE TAX.';
    RETURN;
  ELSIF IN_CALC_TAX.count = 0
  THEN
    out_err_num := '9002';
    out_err_Message  := 'NO RECORDS FOUND IN THE INPUT TO CALCULATE TAX.';
    RETURN;
  END IF;

  v_calc_base_tax_tbl.extend(IN_CALC_TAX.count);

  OUT_HDR_TOT    := 0;
  OUT_USF_TOT    := 0;
  OUT_RCRF_TOT   := 0;
  OUT_E911_TOT   := 0;
  OUT_STAX_TOT   := 0;
  OUT_tax_TOT    := 0;

  SELECT typ_calc_tax_rec ( quantity,
                            other_amt,
                            airtime_amt,
                            warranty_amt,
                            digital_goods_amt,
                            NVL(discount_amt, 0),-- + NVL(taxable_discount_amt, 0),
                            stax_amt,
                            e911_amt,
                            usf_amt,
                            rcrf_amt,
                            sub_total_amt,
                            total_tax_amt,
                            total_charges,
                            stax_rate,
                            e911_rate,
                            usf_rate,
                            rcrf_rate,
                            result,
                            message,
                            dataonly_amt)
  BULK COLLECT INTO v_calc_base_tax_tbl
  FROM table(IN_CALC_TAX);

  --Execute the original tax calculation procedure
  calculate_taxes ( in_bill_zip             => in_bill_zip,
                    in_ship_zip             => in_ship_zip,
                    in_calc_tax             => v_calc_base_tax_tbl,
                    in_total_discount_amt   => in_total_discount_amt,
                    in_language             => in_language,
                    in_source               => in_source,
                    in_country              => in_country,
                    IN_TAX_EXEMPT_TYPE      => IN_TAX_EXEMPT_TYPE,
                    OUT_USF_TOT             => OUT_USF_TOT,
                    OUT_RCRF_TOT            => OUT_RCRF_TOT,
                    OUT_E911_TOT            => OUT_E911_TOT,
                    OUT_STAX_TOT            => OUT_STAX_TOT,
                    OUT_tax_TOT             => OUT_tax_TOT,
                    OUT_hdr_TOT             => OUT_hdr_TOT,
                    out_err_num             => out_err_num,
                    out_err_Message         => out_err_Message
                  );

  IF out_err_num <> 0
  THEN
    RETURN;
  END IF;

  v_country           := ltrim(rtrim(in_country));
  IF upper(v_Country) IS NULL OR v_Country = ' ' THEN
    v_country         := 'USA';
  END IF;

  --Calculate the tax on taxable discount amount
  N_DISC_USF_TOT   := 0;
  N_DISC_RCRF_TOT  := 0;
  N_DISC_E911_TOT  := 0;
  N_DISC_STAX_TOT  := 0;
  N_DISC_TAX_TOT   := 0;
  N_DISC_HDR_TOT   := 0;

  BEGIN
    SELECT ltr.apply_usf,
           ltr.apply_rcr,
           ltr.apply_e911,
           ltr.apply_combstax
    INTO   n_apply_usf,
           n_apply_rcr,
           n_apply_e911,
           n_apply_combstax
    FROM   sa.table_x_zip_code tzc,
           sa.ll_tax_rules ltr
    WHERE tzc.x_zip = in_bill_zip
    AND tzc.x_state = ltr.state_code;
  EXCEPTION
    WHEN OTHERS THEN
      n_apply_usf       := 0;
      n_apply_rcr       := 0;
      n_apply_e911      := 0;
      n_apply_combstax  := 0;
  END;

  FOR i IN IN_CALC_TAX.first .. IN_CALC_TAX.last
  LOOP
    IF  upper (v_country) NOT IN ('USA','US')
    THEN
      IN_CALC_TAX(i).usf_rate      := 0;
      IN_CALC_TAX(i).usf_amt       := 0;
      IN_CALC_TAX(i).rcrf_rate     := 0;
      IN_CALC_TAX(i).rcrf_amt      := 0;
      IN_CALC_TAX(i).e911_amt      := 0;
      IN_CALC_TAX(i).e911_rate     := 0;
      IN_CALC_TAX(i).stax_rate     := 0;
      IN_CALC_TAX(i).stax_amt      := 0;
      IN_CALC_TAX(I).TOTAL_TAX_AMT := 0;
      IN_CALC_TAX(i).total_charges := 0;
      IN_CALC_TAX(I).MESSAGE       := 'Success';
    ELSE --upper (v_country) NOT IN ('USA','US')
      IN_CALC_TAX (i).RESULT := 0;

      IF NVL(IN_CALC_TAX(i).taxable_discount_amt, 0) > 0
      THEN
        IF n_apply_usf = 0
        THEN
          IN_CALC_TAX(i).usf_rate             := '0';
          IN_CALC_TAX(i).usf_amt              := '0';
        ELSIF n_apply_usf = 1
        THEN
          IN_CALC_TAX(i).usf_rate             := computeUSFtax2(in_bill_zip);
          IN_CALC_TAX(i).usf_amt              := ROUND(IN_CALC_TAX(i).taxable_discount_amt * IN_CALC_TAX(i).usf_rate,2);
        END IF;

        IF n_apply_rcr = 0
        THEN
          IN_CALC_TAX(i).rcrf_rate            := '0';
          IN_CALC_TAX(i).rcrf_amt             := '0';
        ELSIF n_apply_rcr = 1
        THEN
          IN_CALC_TAX(i).rcrf_rate            := computeMISCtax2(in_bill_zip);
          IN_CALC_TAX(i).rcrf_amt             := ROUND(IN_CALC_TAX(i).taxable_discount_amt * IN_CALC_TAX(i).rcrf_rate,2);
        END IF;

        IF n_apply_e911 = 0
        THEN
          IN_CALC_TAX(i).e911_rate            := '0';
          IN_CALC_TAX(i).e911_amt             := '0';
        ELSIF n_apply_e911 = 1
        THEN
          --Calculate E911 surcharge only if the airtime is 0 i.e. full discount
          IF TRIM(IN_CALC_TAX(i).airtime_amt) = 0
          THEN
            IN_CALC_TAX(i).e911_amt             := computee911surcharge2(in_bill_zip);
          ELSE
            IN_CALC_TAX(i).e911_amt             := 0;
          END IF;

          IN_CALC_TAX(i).e911_rate            := computee911tax2(in_bill_zip);
          IN_CALC_TAX(i).e911_amt             := ROUND(IN_CALC_TAX(i).e911_amt + IN_CALC_TAX(i).taxable_discount_amt * IN_CALC_TAX(i).e911_rate,2);
        END IF;

        IF n_apply_combstax = 0
        THEN
          IN_CALC_TAX(i).stax_rate            := '0';
          IN_CALC_TAX(i).stax_amt             := '0';
        ELSIF n_apply_combstax = 1
        THEN
          IN_CALC_TAX(i).stax_rate            := Computetax2(in_bill_zip, NULL);
          v_WtyTax                                    := ComputeWTYtax(in_bill_zip)             *get_combstax(in_bill_zip);
          IN_CALC_TAX(i).stax_amt             := ROUND(IN_CALC_TAX(i).taxable_discount_amt  * IN_CALC_TAX(i).stax_rate,2) + ROUND(NVL(IN_CALC_TAX(i).warranty_amt,0) * v_wtytax,2);
        END IF;

        IN_CALC_TAX(i).total_tax_amt          := IN_CALC_TAX(i).usf_amt + IN_CALC_TAX(i).e911_amt + IN_CALC_TAX(i).rcrf_amt + IN_CALC_TAX(i).stax_amt;
        IN_CALC_TAX(i).message                := 'Success';
      ELSE --NVL(IN_CALC_TAX(i).taxable_discount_amt, 0) > 0
        IN_CALC_TAX(i).usf_rate      := 0;
        IN_CALC_TAX(i).usf_amt       := 0;
        IN_CALC_TAX(i).rcrf_rate     := 0;
        IN_CALC_TAX(i).rcrf_amt      := 0;
        IN_CALC_TAX(i).e911_amt      := 0;
        IN_CALC_TAX(i).e911_rate     := 0;
        IN_CALC_TAX(i).stax_rate     := 0;
        IN_CALC_TAX(i).stax_amt      := 0;
        IN_CALC_TAX(I).TOTAL_TAX_AMT := 0;
        IN_CALC_TAX(i).total_charges := 0;
        IN_CALC_TAX(I).MESSAGE       := 'Success';
      END IF; --NVL(IN_CALC_TAX(i).taxable_discount_amt, 0) > 0
    END IF; --upper (v_country) NOT IN ('USA','US')

    N_DISC_USF_TOT  := N_DISC_USF_TOT  + IN_CALC_TAX(i).usf_amt;
    N_DISC_RCRF_TOT := N_DISC_RCRF_TOT + IN_CALC_TAX(i).rcrf_amt;
    N_DISC_E911_TOT := N_DISC_E911_TOT + IN_CALC_TAX(i).e911_amt;
    N_DISC_STAX_TOT := N_DISC_STAX_TOT + IN_CALC_TAX(I).stax_amt ;
    N_DISC_TAX_TOT  := N_DISC_TAX_TOT  + IN_CALC_TAX(i).total_tax_amt;

  END LOOP;

  FOR i IN v_calc_base_tax_tbl.first..v_calc_base_tax_tbl.last
  LOOP
    IN_CALC_TAX(i).stax_rate       := v_calc_base_tax_tbl(i).stax_rate;
    IN_CALC_TAX(i).e911_rate       := v_calc_base_tax_tbl(i).e911_rate;
    IN_CALC_TAX(i).usf_rate        := v_calc_base_tax_tbl(i).usf_rate;
    IN_CALC_TAX(i).rcrf_rate       := v_calc_base_tax_tbl(i).rcrf_rate;

    IN_CALC_TAX(i).sub_total_amt   := v_calc_base_tax_tbl(i).sub_total_amt;

    --Calculate total charges
    -- Base total charges + Tax on the taxable discount amount - taxable discount amount
    IN_CALC_TAX(i).total_charges   := NVL(v_calc_base_tax_tbl(i).total_charges, 0) + NVL(IN_CALC_TAX(i).total_tax_amt,0);

    --Calculate total tax
    -- Tax on the taxable discount + base total tax
    IN_CALC_TAX(i).total_tax_amt   := NVL(IN_CALC_TAX(i).total_tax_amt, 0) + NVL(v_calc_base_tax_tbl(i).total_tax_amt,0);

    IN_CALC_TAX(i).stax_amt        := NVL(IN_CALC_TAX(i).stax_amt, 0)  + NVL(v_calc_base_tax_tbl(i).stax_amt, 0);
    IN_CALC_TAX(i).e911_amt        := NVL(IN_CALC_TAX(i).e911_amt, 0)  + NVL(v_calc_base_tax_tbl(i).e911_amt, 0);
    IN_CALC_TAX(i).usf_amt         := NVL(IN_CALC_TAX(i).usf_amt , 0)  + NVL(v_calc_base_tax_tbl(i).usf_amt , 0);
    IN_CALC_TAX(i).rcrf_amt        := NVL(IN_CALC_TAX(i).rcrf_amt, 0)  + NVL(v_calc_base_tax_tbl(i).rcrf_amt, 0);
  END LOOP;

  --Add base total taxes and discount total taxes
  OUT_HDR_TOT    := NVL(OUT_HDR_TOT  , 0) + NVL(N_DISC_TAX_TOT , 0);
  OUT_USF_TOT    := NVL(OUT_USF_TOT  , 0) + NVL(N_DISC_USF_TOT , 0);
  OUT_RCRF_TOT   := NVL(OUT_RCRF_TOT , 0) + NVL(N_DISC_RCRF_TOT, 0);
  OUT_E911_TOT   := NVL(OUT_E911_TOT , 0) + NVL(N_DISC_E911_TOT, 0);
  OUT_STAX_TOT   := NVL(OUT_STAX_TOT , 0) + NVL(N_DISC_STAX_TOT, 0);
  OUT_tax_TOT    := NVL(OUT_tax_TOT  , 0) + NVL(N_DISC_tax_TOT , 0);

END calculate_taxes;
--CR49915 WFM LIFELINE changes end

--CR53102 Shipping charge taxation in B2B and B2C
--New overloaded procedure calculate_taxes
/****************************************************************************************************
* Procedure Name: calculate_taxes                                                                   *
* Purpose       : New overloaded procedure to calculate shipping taxes for B2B and B2C channels     *
*                                                                                                   *
*  1. New key_table which will have new attributes for shipping charges and tax calculation         *
*  2. We will call the original tax procedure in order to calculate existing amts (E911, RCF, etc..)*
*  3. Then if the shipping amt is > 0 we will calculate the shipping taxes for that record          *
*  4. Once the calculation completes we will converge the two amts to return the correct total_taxes*
*     and total purchase amt                                                                        *
*  5. New function computeShippingtax created to get the shipping rate based on information provided*
*     by the tax team.                                                                              *
****************************************************************************************************/
PROCEDURE calculate_taxes(
    in_bill_zip            IN VARCHAR2,
    in_ship_zip            IN VARCHAR2,
    in_calc_tax            IN OUT calc_taxb2b_tbl,
    in_total_discount_amt  IN NUMBER,
    in_language            IN VARCHAR2,
    in_source              IN VARCHAR2,
    in_country             IN VARCHAR2,
    in_tax_exempt_type     IN VARCHAR2,
    out_usf_tot           OUT NUMBER,
    out_rcrf_tot          OUT NUMBER,
    out_e911_tot          OUT NUMBER,
    out_stax_tot          OUT NUMBER,
    out_shiptax_tot       OUT NUMBER,
    out_ship_tot          OUT NUMBER,
    out_tax_tot           OUT NUMBER,
    out_hdr_tot           OUT NUMBER,
    out_err_num           OUT NUMBER,
    out_err_message       OUT VARCHAR2
  )
IS
  --Local variables
  v_country           VARCHAR2(50);
  v_wtytax            NUMBER;
  v_calc_base_tax_tbl typ_calc_tax_tbl := typ_calc_tax_tbl();
  v_err_message       VARCHAR2(300);
  v_result            NUMBER;
  v_b2b_tax_tot       NUMBER;
  v_b2b_hdr_tot       NUMBER;

BEGIN
  --
  IF in_calc_tax IS NULL
  THEN
    out_err_num      := '9001';
    out_err_Message  := 'NO RECORDS FOUND IN THE INPUT TO CALCULATE TAX.';
    RETURN;
  ELSIF in_calc_tax.count = 0
  THEN
    out_err_num      := '9002';
    out_err_Message  := 'NO RECORDS FOUND IN THE INPUT TO CALCULATE TAX.';
    RETURN;
  END IF;

  v_calc_base_tax_tbl.extend(IN_CALC_TAX.count);

  out_hdr_tot     := 0;
  out_usf_tot     := 0;
  out_rcrf_tot    := 0;
  out_e911_tot    := 0;
  out_stax_tot    := 0;
  -- Commerce wants values to be NULL if passing 0
  -- out_shiptax_tot := 0;
  -- out_ship_tot    := 0;
  out_tax_tot     := 0;

  SELECT typ_calc_tax_rec ( quantity,
                            other_amt,
                            airtime_amt,
                            warranty_amt,
                            digital_goods_amt,
                            NVL(discount_amt, 0),
                            stax_amt,
                            e911_amt,
                            usf_amt,
                            rcrf_amt,
                            sub_total_amt,
                            total_tax_amt,
                            total_charges,
                            stax_rate,
                            e911_rate,
                            usf_rate,
                            rcrf_rate,
                            result,
                            message,
                            dataonly_amt)
  BULK COLLECT INTO v_calc_base_tax_tbl
  FROM table(IN_CALC_TAX);

  --Execute the original tax calculation procedure
  calculate_taxes ( in_bill_zip             => in_bill_zip,
                    in_ship_zip             => in_ship_zip,
                    in_calc_tax             => v_calc_base_tax_tbl,
                    in_total_discount_amt   => in_total_discount_amt,
                    in_language             => in_language,
                    in_source               => in_source,
                    in_country              => in_country,
                    in_tax_exempt_type      => in_tax_exempt_type,
                    out_usf_tot             => OUT_USF_TOT,
                    out_rcrf_tot            => OUT_RCRF_TOT,
                    out_e911_tot            => OUT_E911_TOT,
                    out_stax_tot            => OUT_STAX_TOT,
                    out_tax_tot             => OUT_tax_TOT,
                    out_hdr_tot             => OUT_hdr_TOT,
                    out_err_num             => out_err_num,
                    out_err_message         => out_err_Message
                  );

  IF out_err_num <> 0
  THEN
    RETURN;
  END IF;
  --
  v_b2b_tax_tot := 0;
  v_b2b_hdr_tot := 0;

  FOR i IN IN_CALC_TAX.first .. IN_CALC_TAX.last
  LOOP
    IF NVL(in_calc_tax(i).shipping_amt, 0) > 0
    THEN
      --Call new function to calculate the shippping rate based on the ship_zip
      in_calc_tax(i).shiptax_rate  := computeshippingtax(in_ship_zip);
      in_calc_tax(i).shiptax_amt   := ROUND(in_calc_tax(i).shipping_amt * in_calc_tax(i).shiptax_rate,2);
      --Calculate totals
      in_calc_tax(i).total_tax_amt := in_calc_tax(i).shiptax_amt;
      out_shiptax_tot              := NVL(out_shiptax_tot,0) + NVL(in_calc_tax(i).shiptax_amt,0);
      out_ship_tot                 := NVL(out_ship_tot,0)    + NVL(in_calc_tax(i).shipping_amt,0);

      in_calc_tax(i).message       := 'Success';
    ELSE
      in_calc_tax(i).total_tax_amt := 0;
      in_calc_tax(i).message       := 'Success';
    END IF;
    --Local variables to capture the tax and hdr totals which will be added at the end
    v_b2b_tax_tot := v_b2b_tax_tot + NVL(IN_CALC_TAX(i).total_tax_amt,0);
    v_b2b_hdr_tot := v_b2b_hdr_tot + NVL(IN_CALC_TAX(i).total_tax_amt,0) + NVL(in_calc_tax(i).shipping_amt,0);

  END LOOP;

  FOR i IN v_calc_base_tax_tbl.first..v_calc_base_tax_tbl.last
  LOOP
    --Set values that were not manipulated to the original values returned from proc
    in_calc_tax(i).stax_rate       := v_calc_base_tax_tbl(i).stax_rate;
    in_calc_tax(i).e911_rate       := v_calc_base_tax_tbl(i).e911_rate;
    in_calc_tax(i).usf_rate        := v_calc_base_tax_tbl(i).usf_rate;
    in_calc_tax(i).rcrf_rate       := v_calc_base_tax_tbl(i).rcrf_rate;
    in_calc_tax(i).stax_amt        := NVL(v_calc_base_tax_tbl(i).stax_amt, 0);
    in_calc_tax(i).e911_amt        := NVL(v_calc_base_tax_tbl(i).e911_amt, 0);
    in_calc_tax(i).usf_amt         := NVL(v_calc_base_tax_tbl(i).usf_amt , 0);
    in_calc_tax(i).rcrf_amt        := NVL(v_calc_base_tax_tbl(i).rcrf_amt, 0);
    --Leave sub_total as is, was already calculated in proc call
    in_calc_tax(i).sub_total_amt   := v_calc_base_tax_tbl(i).sub_total_amt;

    --Calculate total charges
    in_calc_tax(i).total_charges   := NVL(v_calc_base_tax_tbl(i).total_charges, 0) + NVL(IN_CALC_TAX(i).total_tax_amt,0) + NVL(in_calc_tax(i).shipping_amt,0);

    --Calculate total tax
    --Agreggate the shipping tax to the taxes returned from original proc
    in_calc_tax(i).total_tax_amt   := NVL(in_calc_tax(i).total_tax_amt, 0) + NVL(v_calc_base_tax_tbl(i).total_tax_amt,0);

  END LOOP;

  --Add base total taxes and discount total taxes
  out_tax_tot := NVL(out_tax_tot,0) + NVL(v_b2b_tax_tot,0);

  --Add base hdr total and the shipping total gathered
  out_hdr_tot     := NVL(out_hdr_tot, 0) + NVL(v_b2b_hdr_tot, 0);

END calculate_taxes;
--CR53102 Calculate Shipping Tax for B2B and B2C channels END

FUNCTION IS_COUNTRY_TAXABLE(i_country VARCHAR2)
RETURN VARCHAR2 IS
 v_taxable VARCHAR2(5):= 'N';
BEGIN

 SELECT 'Y'
 INTO   v_taxable
 FROM   table_country
 WHERE  (
        REPLACE(S_NAME, chr(32), '') = UPPER(REPLACE(i_country, chr(32), ''))
        OR
        X_POSTAL_CODE = UPPER(i_country)
        )
 AND    country =  'USA'
 AND    ROWNUM  <= 1;

 RETURN v_taxable;

EXCEPTION
WHEN OTHERS THEN
 IF UPPER(i_country) = 'USA' OR UPPER(i_country) = 'US'
 THEN --{
  RETURN 'Y';
 END IF; --}
 RETURN v_taxable;
END IS_COUNTRY_TAXABLE;

END SP_TAXES;
/