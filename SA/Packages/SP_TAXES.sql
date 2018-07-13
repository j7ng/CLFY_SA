CREATE OR REPLACE PACKAGE sa."SP_TAXES"
IS
  --------------------------------------------------------------------------------------------
  --$RCSfile: SP_TAXES_PKG.sql,v $
  --$Revision: 1.37 $
  --$Author: mshah $
  --$Date: 2018/02/21 15:25:26 $
  --$ $Log: SP_TAXES_PKG.sql,v $
  --$ Revision 1.37  2018/02/21 15:25:26  mshah
  --$ CR55657 - Plans in APP not taxed properly
  --$
  --$ Revision 1.36  2018/01/31 22:16:00  mshah
  --$ CR55657 - Plans in APP not taxed properly
  --$
  --$ Revision 1.34  2017/10/03 18:12:29  sgangineni
  --$ CR49915 - Merged with CR52959
  --$
  --$ Revision 1.33  2017/09/28 21:54:12  mtholkappian
  --$ changes over latest production version
  --$
  --$ Revision 1.25  2016/08/02 21:11:19  rpednekar
  --$ CR41745 - Added input parameters to procedure calctax.
  --$
  --$ Revision 1.24  2015/11/23 21:46:20  nmuthukkaruppan
  --$ ECR39519 -  Fix to pick the tangible comb rates from tpp_combstax column
  --$
  --$ Revision 1.22  2015/04/14 23:04:31  vmadhawnadella
  --$ ADD LOGIC  FOR $10.00 TEXT ONLY CARD.
  --$
  --$ Revision 1.20  2015/02/13 16:26:26  oarbab
  --$ CR31683 UPATED ip parameters and object type column names
  --$
  --$ Revision 1.19  2015/02/11 20:51:46  oarbab
  --$ CR31683 ADDED GET_TAX_SCRIPT_PRC to SP_TAXES and removed from SCRIPT_PKG
  --$
  --$ Revision 1.18  2015/01/19 21:55:30  vkashmire
  --$ CR29021 correct version
  --$
  --$ Revision 1.16  2014/12/15 16:21:22  icanavan
  --$ added new functions for BILLING RECURRING PAYMENTS
  --$
  --$ Revision 1.14  2014/04/24 22:35:30  cpannala
  --$ CR25490
  --$
  --$ Revision 1.5  2013/10/31 20:58:15  icanavan
  --$ ADDED DATA ONLY
  --$
  --$ Revision 1.4  2013/05/21 20:20:43  ymillan
  --$ CR22860
  --$
  --$ Revision 1.3  2012/10/31 19:15:29  mmunoz
  --$ CR22380: Commented the code that is not being used (regression testing considered)
  --$
  --$ Revision 1.2  2012/10/24 15:17:32  mmunoz
  --$ CR22380 : Updated Calctax to add input parameter : warranty amount
  --$
  --------------------------------------------------------------------------------------------
  --CR22380 removing ESN function is not used
  --FUNCTION TAX_SERVICE(p_esn IN VARCHAR2)
  --   RETURN NUMBER ;
  FUNCTION computetax(
      p_webuser_objid IN NUMBER,
      p_program_param IN NUMBER,
      p_esn           IN VARCHAR2 DEFAULT NULL )
    RETURN NUMBER;
  FUNCTION computetax2(
      p_zipcode IN VARCHAR2,
      p_esn     IN VARCHAR2 )
    RETURN NUMBER;
 -- START CR33047
 FUNCTION computetax3(
    p_zipcode IN VARCHAR2,
    p_esn     IN VARCHAR2 )
    RETURN NUMBER;
-- END CR33047
 FUNCTION computeE911tax(
      p_webuser_objid IN NUMBER,
      p_program_param IN NUMBER
      --p_esn           IN VARCHAR2 DEFAULT NULL --CR22380 removing ESN
    )
    RETURN NUMBER;
  FUNCTION computee911tax2(
      p_zipcode IN VARCHAR2
      --p_esn IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN NUMBER;
  FUNCTION computeUSFtax(
      p_webuser_objid IN NUMBER,
      p_program_param IN NUMBER
      --p_esn           IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN NUMBER;
  FUNCTION computeUSFtax2(
      p_zipcode IN VARCHAR2
      --p_esn IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN NUMBER;
  FUNCTION computee911surcharge(
      p_webuser_objid IN NUMBER,
      p_program_param IN NUMBER
      --p_esn IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN NUMBER;
  FUNCTION computee911surcharge2(
      p_zipcode IN VARCHAR2
      --p_esn IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN NUMBER;
  FUNCTION computee911note(
      p_webuser_objid IN NUMBER,
      p_program_param IN NUMBER
      --p_esn IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN VARCHAR2;
  FUNCTION computee911note2(
      p_zipcode IN VARCHAR2
      --p_esn IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN VARCHAR2;
  FUNCTION computeMISCtax(
      p_webuser_objid IN NUMBER,
      p_program_param IN NUMBER
      --p_esn           IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN NUMBER;
  FUNCTION computeMISCtax2(
      p_zipcode IN VARCHAR2
      --p_esn IN VARCHAR2 --CR22380 removing ESN
    )
    RETURN NUMBER;
  FUNCTION is_pgmMONFEE_EXCLUDED_tax_calc(
      ip_pp_objid    IN X_PROGRAM_PARAMETERS.objid%type,
      ip_param_name  IN table_x_part_class_params.x_param_name%type,
      ip_param_value IN table_x_part_class_values.X_PARAM_VALUE%type )
    RETURN BOOLEAN ;
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
      IP_X_CTYLCLSTAX    IN NUMBER ,
      IP_X_COMBSTAX      IN NUMBER ,
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
      Op_Msg OUT VARCHAR2) ;
  PROCEDURE CalcTax(
      IP_ZIPCODE IN VARCHAR2,
      --IP_ESN                         IN     VARCHAR2, CR22380 removing ESN
      IP_purchaseamt      IN NUMBER,
      IP_airtimeamt       IN NUMBER,
      IP_warrantyamt      IN NUMBER,  --CR18994 CR22380
      IP_dataonlyamt      IN NUMBER,  --CR26033 / CR26274
      IP_txtonlyamt      IN NUMBER,  --CR32572
      IP_shipamt          IN NUMBER,  -- CR27857
      IP_MODEL_TYPE       IN VARCHAR2,--IP_homealertamt              IN     number, -- CR27269
      IP_tot_model_type   IN NUMBER,  --IP_carconnectamt             IN     number, -- CR27270
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
    ,ip_salestaxonly_amt           IN NUMBER    DEFAULT 0    --- CR41745
    ,ip_nac_activation_chrg        IN NUMBER    DEFAULT 0    --- CR41745
      );
  PROCEDURE TaxRATE_B2B(
      IP_ORDER_ID IN VARCHAR2,
      Op_B2bCombStaxRate OUT NUMBER,
      Op_B2bE911Rate OUT NUMBER,
      Op_B2bUsfRate OUT NUMBER,
      Op_B2brcrfRate OUT NUMBER,
      Op_B2bE911Surcharge OUT NUMBER);
  PROCEDURE TaxRATE_B2B_ZIPCODE(
      IP_ZIPCODE IN VARCHAR2,
      Op_B2bCombStaxRate OUT NUMBER,
      Op_B2bE911Rate OUT NUMBER,
      Op_B2bUsfRate OUT NUMBER,
      Op_B2brcrfRate OUT NUMBER,
      Op_B2bE911Surcharge OUT NUMBER);
  PROCEDURE GET_E911_Script(
      IP_language IN VARCHAR2,
      IP_source   IN VARCHAR2,
      IP_zipcode  IN VARCHAR2,
      IP_brand    IN VARCHAR2,
      Op_E911Label OUT VARCHAR2,
      Op_result OUT NUMBER,
      Op_Msg OUT VARCHAR2);
  PROCEDURE CalcTax_B2b(
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
      Op_Msg OUT VARCHAR2);
  PROCEDURE GetTax2_BILL(
      IP_price    IN NUMBER,
      IP_usf_tax  IN NUMBER,
      IP_rcrf_tax IN NUMBER,
      Op_usf_tax OUT NUMBER,
      Op_rcrf_tax OUT NUMBER);
  PROCEDURE GetTax_BILL(
      IP_price     IN NUMBER,
      IP_sales_tax IN NUMBER,
      IP_e911_tax  IN NUMBER,
      Op_sales_tax OUT NUMBER,
      Op_e911_tax OUT NUMBER);
  -- CR22860 public hpp function
  FUNCTION get_combstax(
      p_zipcode IN VARCHAR2 )
    RETURN NUMBER;
  -- CR22860 public hpp function
  FUNCTION computeWTYtax(
      p_zipcode IN VARCHAR2 )
    RETURN NUMBER;
  --CR22860 new funtion HPP for CWG
  FUNCTION computeCWGtax(
      p_zipcode IN VARCHAR2 )
    RETURN NUMBER;
  --CR26033 / CR26274
  FUNCTION computeDTAtax(
      p_zipcode IN VARCHAR2 )
    RETURN VARCHAR2 ;
    --CR32572
    FUNCTION computeTXTtax(
      p_zipcode IN VARCHAR2 )
    RETURN VARCHAR2 ;
  --CR27269
  FUNCTION computeMODELtax(
      p_zipcode    IN VARCHAR2,
      P_MODEL_TYPE IN VARCHAR2 )
    RETURN NUMBER;
  --CR25490
  PROCEDURE calculate_taxes(
      in_bill_zip IN VARCHAR2,
      in_ship_zip IN VARCHAR2,
      in_calc_tax IN OUT typ_calc_tax_tbl,
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
      OUT_ERR_NUM OUT NUMBER,
      out_err_Message OUT VARCHAR2 );
  -------------- Tax calculations for recurring_payments (CR30259) ---------------
  FUNCTION computetax_billing(
      p_webuser_objid     IN NUMBER,
      p_program_param     IN NUMBER,
      p_esn               IN VARCHAR2 DEFAULT NULL,
      p_pe_payment_source IN NUMBER )
    RETURN NUMBER;
  FUNCTION computeE911tax_billing(
      p_webuser_objid     IN NUMBER,
      p_program_param     IN NUMBER,
      p_pe_payment_source IN NUMBER )
    RETURN NUMBER;
  FUNCTION computeUSFtax_billing(
      p_webuser_objid     IN NUMBER,
      p_program_param     IN NUMBER,
      p_pe_payment_source IN NUMBER )
    RETURN NUMBER;
  FUNCTION computee911surcharge_billing(
      p_webuser_objid     IN NUMBER,
      p_program_param     IN NUMBER,
      p_pe_payment_source IN NUMBER )
    RETURN NUMBER;
  FUNCTION computeMISCtax_billing(
      p_webuser_objid     IN NUMBER,
      p_program_param     IN NUMBER,
      p_pe_payment_source IN NUMBER )
    RETURN NUMBER;
  FUNCTION TAX_RULES_PROGS_DATA_BILLING(
      P_PE_OBJID IN VARCHAR2)
    RETURN VARCHAR2 ;
  FUNCTION TAX_RULES_BILLING(
      P_esn IN VARCHAR2)
    RETURN VARCHAR2 ;
  --------------------------------------------------------------------------------
  --------------------- BEGIN CR31683 -------------------------------------
  PROCEDURE GET_TAX_SCRIPT_PRC
   ( P_ZIP_TBL          IN OUT zip_script_rec_tbl
     ,IP_LANGUAGE        IN     VARCHAR2 DEFAULT 'ENGLISH' -- required
     ,IP_SOURCE_SYSTEM   IN     VARCHAR2 DEFAULT 'WEB'    --WEB,WEBCSR,ALL
     ,IP_BRAND_NAME    IN VARCHAR2 DEFAULT 'NET10' -- required
    );
--------------------- END CR31683 -------------------------------------
-- EME CR39519--
 FUNCTION get_tppcombstax(
      p_zipcode IN VARCHAR2 )
    RETURN NUMBER;
-- EME CR39519--


 ----- BEGIN - CR52959  - USF and RCR Taxes Exception
 PROCEDURE get_tax_flag
   (
    I_Source         IN  VARCHAR2,
    O_tax_USF_flag   OUT VARCHAR2,
    O_tax_RCRF_flag  OUT VARCHAR2
   );
  ----- END - CR52959  - USF and RCR Taxes Exception

  ---BEGIN CR52959 EGIN  USF and RCR Taxes Exception
 PROCEDURE GET_TAX_AMT
   (
     i_source_system IN  VARCHAR2,
     o_usf_tax_amt   IN  OUT NUMBER,
     o_rcrf_tax_amt  IN  OUT NUMBER,
     o_usf_percent   IN  OUT NUMBER,
     o_rcrf_percent  IN  OUT NUMBER

   ) ;
---END CR52959 EGIN  USF and RCR Taxes Exception

  --CR49915 WFM-LIFELINE changes start
  --New overloaded procedure
  PROCEDURE calculate_taxes(
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
      OUT_ERR_NUM OUT NUMBER,
      out_err_Message OUT VARCHAR2
      );
  ----CR49915 WFM-LIFELINE changes end

  --CR53102 B2B and B2C Shipping Tax Calculation
  --New overloaded procedure
  PROCEDURE calculate_taxes(
      in_bill_zip           IN VARCHAR2,
      in_ship_zip           IN VARCHAR2,
      in_calc_tax       IN OUT calc_taxb2b_tbl,
      in_total_discount_amt IN NUMBER,
      in_language           IN VARCHAR2,
      in_source             IN VARCHAR2,
      in_country            IN VARCHAR2,
      in_tax_exempt_type    IN VARCHAR2,
      out_usf_tot          OUT NUMBER,
      out_rcrf_tot         OUT NUMBER,
      out_e911_tot         OUT NUMBER,
      out_stax_tot         OUT NUMBER,
      out_shiptax_tot      OUT NUMBER, --total shipping taxes
      out_ship_tot         OUT NUMBER, --total shipping amt (without tax)
      out_tax_tot          OUT NUMBER,
      out_hdr_tot          OUT NUMBER,
      out_err_num          OUT NUMBER,
      out_err_message      OUT VARCHAR2
      );
  --CR53102 end

  FUNCTION IS_COUNTRY_TAXABLE (i_country VARCHAR2) RETURN VARCHAR2; --55657

END SP_TAXES;
/