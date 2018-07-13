CREATE OR REPLACE PACKAGE BODY sa."ECOMMERCE_SUPPLY_CHAIN"
IS
/*******************************************************************************************************
/*******************************************************************************************************
* --$RCSfile: ecommerce_supply_chain_pkb.sql,v $
 --$Revision: 1.25 $
  --$Author: tbaney $
  --$Date: 2017/11/13 19:56:58 $
  --$ $Log: ecommerce_supply_chain_pkb.sql,v $
  --$ Revision 1.25  2017/11/13 19:56:58  tbaney
  --$ Merged.
  --$
  --$ Revision 1.24  2017/11/10 17:09:23  smacha
  --$ Modified for SIM_TYPE1 logic.
  --$
  --$ Revision 1.20  2017/11/08 21:49:04  smacha
  --$  Modified code changes for tracfone brand and product key is SIM_TYPE1 in GET_BP_CODES procedure.
  --$
  --$ Revision 1.19  2017/11/06 23:07:51  skambhammettu
  --$ *** empty log message ***
  --$
  --$ Revision 1.17  2017/10/26 18:24:45  skambhammettu
  --$ *** empty log message ***
  --$
  --$ Revision 1.16  2017/10/26 16:11:37  skambhammettu
  --$ BP_CODE for WFM
  --$
  --$ Revision 1.13  2017/02/24 19:34:06  sgangineni
  --$ CR45644 - Total wireless changes for hotspot devices
  --$
  --$ Revision 1.12  2017/02/13 16:25:18  sgangineni
  --$ CR45644 - TF & TW Ecommerce changes merged with latest production version.
  --$
  --$ Revision 1.11  2016/12/16 18:16:30  vlaad
  --$ Updated for GO_SMART
  --$
  --$ Revision 1.8  2014/11/07 19:34:22  cpannala
  --$ CR31022 Simple mobile changes
  --$
  --$ Revision 1.6  2014/06/26 16:10:11  cpannala
  --$ Changes for get BP_codes CR29467
  --$
  --$ Revision 1.5  2014/06/06 13:32:35  cpannala
  --$ get_bp_codes has changed to trim the bp code values.
  --$
  --$ Revision 1.2  2013/12/27 17:20:38  cpannala
  --$ CR22623 Changes
  --$
  --$ Revision 1.2  2013/12/27 17:14:47  cpannala
  --$ CR22623 Changes
  --$
  --$ Revision 1.1  2013/12/05 16:22:36 cpannala
  --$ CR22623 - B2B Initiative
  --$
* Description:
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
-------------cr22623 ---supply chain contract service----
PROCEDURE list_of_carriers(
    P_ZIP         IN VARCHAR2,
    p_device_type IN VARCHAR2 ,
    p_att OUT VARCHAR2,
    p_verizon OUT VARCHAR2,
    p_sprint OUT VARCHAR2,
    p_tmobile OUT VARCHAR2)
IS
  CURSOR SIM_CURS
  IS
    SELECT DISTINCT TECH2 FROM sa.ZIP2TECH_SIMPROFILES WHERE ZIP = P_ZIP;
  CURSOR phone_curs
  IS
    SELECT techkey FROM MAPINFO.eg_zip2tech WHERE zip = p_zip;
BEGIN
  IF p_device_type = 'SIM' OR p_device_type IS NULL THEN
    FOR sim_rec IN sim_curs
    LOOP
      IF sim_rec.tech2    = 'SIMGSM41' THEN
        p_att            := '1';
      elsif sim_rec.tech2 = 'SIMGSM5' THEN
        p_tmobile        := '1';
      END IF;
    END LOOP;
  END IF;
  IF p_device_type = 'PHONE' OR p_device_type IS NULL THEN
    FOR phone_rec IN phone_curs
    LOOP
      IF phone_rec.techkey IN ('GSM4','AT') THEN
        p_att                := '1';
      elsif phone_rec.techkey = 'CO' THEN
        p_verizon            := '1';
      elsif phone_rec.techkey = 'SPR' THEN
        p_sprint             := '1';
      elsif phone_rec.techkey = 'GSM5' THEN
        p_tmobile            := '1';
      END IF;
    END LOOP;
  END IF;
  IF p_device_type = 'HOMEPHONE' OR p_device_type IS NULL THEN
    FOR phone_rec IN phone_curs
    LOOP
      IF phone_rec.techkey = 'HFCDMAV' THEN
        p_verizon         := '1';
      END IF;
    END LOOP;
  END IF;
END LIST_OF_CARRIERS;

--------
Procedure Phone_Cart_Prc(P_Phone_Cart In Out Phone_Cart_object)
Is
v_phone_cart_object phone_cart_object := phone_cart_object();
Begin
v_phone_cart_object := P_Phone_Cart;

  FOR i IN v_phone_cart_object.first..v_phone_cart_object.last
  LOOP
    nap_SERVICE_pkg.get_list(v_phone_cart_object(i).x_zip, NULL, v_phone_cart_object(i).x_part_number, NULL, NULL, NULL);
    IF nap_SERVICE_pkg.big_tab.count >0 THEN
      v_phone_cart_object(i).x_status      := 'COVERED';
    ELSE
      v_phone_cart_object(i).x_status := 'NOT COVERED';
    END IF;
  End Loop;
   /*IF nap_SERVICE_pkg.big_tab.count >0 THEN
    for j in nap_SERVICE_pkg.big_tab.first .. nap_SERVICE_pkg.big_tab.last loop
      dbms_output.put_line(nap_SERVICE_pkg.big_tab(j).carrier_info.x_parent_name);
      dbms_output.put_line(nap_SERVICE_pkg.big_tab(j).carrier_info.sim_profile);
      dbms_output.put_line(nap_SERVICE_pkg.big_tab(j).same_carrier);
      dbms_output.put_line(nap_SERVICE_pkg.big_tab(j).same_zone);
      dbms_output.put_line(nap_SERVICE_pkg.big_tab(j).same_parent);
    end loop;
  end if;  */
P_Phone_Cart  := v_phone_cart_object;
End Phone_Cart_Prc;
----------

function carriers_by_part_num(p_part_number in varchar2) return varchar2 is
  l_comma_list varchar2(300) := null;
  cursor esn_part_num_info_curs is
    SELECT /*+ ORDERED */
           pn.part_number esn_part_number,
           pn.x_technology,
           nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'DATA_SPEED'
                   and rownum <2),NVL(pn.x_data_capable, 0)) data_speed,
           (select bo.org_id
              from table_bus_org bo
             where bo.objid =pn.PART_NUM2BUS_ORG) bus_org_id,
           pn.PART_NUM2BUS_ORG bus_org_objid
     FROM table_part_num pn
     WHERE 1=1
       and pn.part_number = p_part_number;
  esn_part_num_info_rec esn_part_num_info_curs%rowtype;
  cursor carr_feat_curs(c_technology in varchar2,
                        c_bus_org_objid in number,
                        c_data_speed in number,
                        c_esn_part_number in varchar2) is
    select distinct p.x_parent_name
      from table_x_carrier_features cf,
           sa.table_x_carrier ca,
           sa.table_x_carrier_group cg,
           sa.table_x_parent p
     where 1=1
       and cf.x_technology        = c_technology
       and cf.X_FEATURES2BUS_ORG  = c_bus_org_objid
       and cf.x_data              = c_data_speed
       AND ca.objid                = cf.X_FEATURE2X_CARRIER
       AND cg.objid               = ca.CARRIER2CARRIER_GROUP
       and p.objid                = cg.X_CARRIER_GROUP2X_PARENT
       and upper(p.x_status)      = 'ACTIVE'
       and not exists (SELECT 1
                         FROM table_x_not_certify_models cm,
                              table_part_num pn
                        WHERE 1 = 1
                          AND cm.X_PARENT_ID = p.x_parent_id
                          AND cm.X_PART_CLASS_OBJID = pn.PART_NUM2PART_CLASS
                          AND pn.PART_NUMBER = c_esn_part_number);
  cursor net10_carr_feat_curs(c_technology in varchar2,
                              c_bus_org_objid in number,
                              c_data_speed in number,
                              c_esn_part_number in varchar2) is
    select distinct p.x_parent_name
      from table_x_carrier_features cf,
           sa.table_x_carrier ca,
           sa.table_x_carrier_group cg,
           sa.table_x_parent p
     where cf.X_FEATURE2X_CARRIER in( SELECT c2.objid
                                        FROM table_x_carrier_group cg2,
                                             table_x_carrier c2
                                       WHERE cg2.x_carrier_group2x_parent = p.objid
                                         AND c2.carrier2carrier_group = cg2.objid)
       and cf.x_technology        = c_technology
       and cf.X_FEATURES2BUS_ORG  = (select bo.objid
                                       from table_bus_org bo
                                      where bo.org_id = 'NET10'
                                        and bo.objid  = c_bus_org_objid)
       and cf.x_data              = c_data_speed
       AND ca.objid               = cf.X_FEATURE2X_CARRIER
       AND cg.objid               = ca.CARRIER2CARRIER_GROUP
       and p.objid                = cg.X_CARRIER_GROUP2X_PARENT
       and upper(p.x_status)      = 'ACTIVE'
       and not exists (SELECT 1
                         FROM table_x_not_certify_models cm,
                              table_part_num pn
                        WHERE 1 = 1
                          AND cm.X_PARENT_ID = p.x_parent_id
                          AND cm.X_PART_CLASS_OBJID = pn.PART_NUM2PART_CLASS
                          AND pn.PART_NUMBER = c_esn_part_number);
begin
  open esn_part_num_info_curs;
    fetch esn_part_num_info_curs into esn_part_num_info_rec;
    dbms_output.put_line('esn part num info-------------------------------------------------------------------');
    dbms_output.put_line('esn part num info-------------------------------------------------------------------');
    dbms_output.put_line('esn_part_num_info_rec.x_technology:'||esn_part_num_info_rec.x_technology);
    dbms_output.put_line('esn_part_num_info_rec.data_speed:'||esn_part_num_info_rec.data_speed);
    dbms_output.put_line('esn_part_num_info_rec.bus_org_objid:'||esn_part_num_info_rec.bus_org_objid);
    dbms_output.put_line('esn_part_num_info_rec.bus_org_id:'||esn_part_num_info_rec.bus_org_id);
    if esn_part_num_info_rec.bus_org_id = 'NET10' then
      for  carr_feat_rec in net10_carr_feat_curs(esn_part_num_info_rec.x_technology,
                                                 esn_part_num_info_rec.bus_org_objid,
                                                 esn_part_num_info_rec.data_speed,
                                                 esn_part_num_info_rec.esn_part_number) loop
        if l_comma_list is null then
          l_comma_list := carr_feat_rec.x_parent_name;
        else
          l_comma_list := l_comma_list||','||carr_feat_rec.x_parent_name;
        end if;
      end loop;
    else
      for  carr_feat_rec in carr_feat_curs(esn_part_num_info_rec.x_technology,
                                           esn_part_num_info_rec.bus_org_objid,
                                                 esn_part_num_info_rec.data_speed,
                                                 esn_part_num_info_rec.esn_part_number) loop
        if l_comma_list is null then
          l_comma_list := carr_feat_rec.x_parent_name;
        else
          l_comma_list := l_comma_list||','||carr_feat_rec.x_parent_name;
        end if;
      end loop;
    end if;
  close esn_part_num_info_curs;
  dbms_output.put_line(l_comma_list);
  RETURN L_COMMA_LIST;
END CARRIERS_BY_PART_NUM;
---
PROCEDURE GET_BP_CODES(
    IN_ZIPCODE     IN VARCHAR2 ,
    IN_BRAND       IN VARCHAR2 ,
    IN_PRODUCT_KEY IN VARCHAR2 ,
    IN_LANGUAGE    IN VARCHAR2 DEFAULT 'EN' ,
    in_carrier     IN VARCHAR2 ,
    OUT_BP_CODE OUT SYS_REFCURSOR,
    OUT_ERR_NUM OUT NUMBER ,
    out_err_msg OUT VARCHAR2 )
AS
V_BP_CODE VARCHAR2(20) ;
  ---
  BEGIN
 -- DBMS_OUTPUT.PUT_LINE('Start');
  IF (IN_ZIPCODE IS NULL) OR (IN_BRAND IS NULL) OR (IN_PRODUCT_KEY IS NULL) THEN
    OUT_ERR_NUM  := -1;
    OUT_ERR_MSG  := 'Valid Inputs Required'||SUBSTR(sqlerrm, 1, 300);
    return;
  END IF;
  ---CR54324
  OPEN out_bp_code FOR
  SELECT DISTINCT bp.bp_code bp_code
  FROM   mapinfo.eg_zip2tech zip,
         mapinfo.eg_bptech bp
  WHERE  1 = 1
  AND    zip.zip = in_zipcode
  AND    bp.service IN ( -- brand
                         SELECT map_service
                         FROM   sa.x_bus_org_map_service
                         WHERE  bus_org_id = in_brand
                       )
  AND    zip.language = 'EN'
  AND    bp.product_key = in_product_key
  AND    zip.techkey = bp.techkey
  AND    zip.service = bp.service;

  --CR53681
  IF(IN_PRODUCT_KEY LIKE 'SIM%') and (IN_BRAND in ('TRACFONE','TOTAL_WIRELESS'))THEN
    OPEN OUT_BP_CODE FOR
	SELECT rtrim(ltrim( TECH2,'SIM'), '12') sim_tech
    FROM sa.ZIP2TECH_SIMPROFILES
    WHERE  ZIP = IN_ZIPCODE
    AND SIM_TYPE = (CASE WHEN UPPER(IN_PRODUCT_KEY) = 'SIM_TYPE1' THEN 1 WHEN UPPER(IN_PRODUCT_KEY) = 'SIM_TYPE2' THEN 2 ELSE SIM_TYPE END)
    and carrier = (CASE    WHEN UPPER(in_carrier) = 'VZW' THEN 'SIMCDMA'   ELSE CARRIER  END);
  END IF;

--CR54324

  IF(IN_PRODUCT_KEY LIKE 'SIM%') and (IN_BRAND in ('STRAIGHT_TALK', 'NET10'))THEN
    OPEN OUT_BP_CODE FOR
    SELECT rtrim(ltrim( TECH2,'SIM'), '12') sim_tech
    FROM sa.ZIP2TECH_SIMPROFILES
    WHERE  ZIP = IN_ZIPCODE
    AND SIM_TYPE = (CASE WHEN UPPER(IN_PRODUCT_KEY) = 'SIM_TYPE1' THEN 1 WHEN UPPER(IN_PRODUCT_KEY) = 'SIM_TYPE2' THEN 2 ELSE SIM_TYPE END)
    and carrier =  (CASE WHEN UPPER(in_carrier) = 'ATT' THEN 'SIMGSM4'
	                 WHEN UPPER(in_carrier) = 'TMO' THEN 'SIMGSM5'
			 WHEN UPPER(in_carrier) = 'VZW' THEN 'SIMCDMA'
                  	 ELSE CARRIER   END);
    --ORDER BY NVL(PREF,0) DESC ;
  END IF;

  IF(IN_PRODUCT_KEY LIKE 'SIM%') and (IN_BRAND in ('SIMPLE_MOBILE'))THEN
    OPEN OUT_BP_CODE FOR
    SELECT rtrim(ltrim( TECH2,'SIM'), '12') sim_tech
    FROM sa.ZIP2TECH_SIMPROFILES
    WHERE  ZIP = IN_ZIPCODE
    AND SIM_TYPE = (CASE WHEN UPPER(IN_PRODUCT_KEY) = 'SIM_TYPE1' THEN 1 WHEN UPPER(IN_PRODUCT_KEY) = 'SIM_TYPE2' THEN 2 ELSE SIM_TYPE END)
    and carrier = 'SIMGSM5';
  END IF;

  -- CR 44729
  -- ADDING CONDITION FOR GO SMART

  IF(IN_PRODUCT_KEY LIKE 'SIM%') and (IN_BRAND in ('GO_SMART'))THEN
    OPEN OUT_BP_CODE FOR
    SELECT rtrim(ltrim( TECH2,'SIM'), '12') sim_tech
    FROM sa.ZIP2TECH_SIMPROFILES
    WHERE  ZIP = IN_ZIPCODE
    AND SIM_TYPE = (CASE WHEN UPPER(IN_PRODUCT_KEY) = 'SIM_TYPE1' THEN 1 WHEN UPPER(IN_PRODUCT_KEY) = 'SIM_TYPE2' THEN 2 ELSE SIM_TYPE END)
    and carrier = 'SIMGSM5';
    DBMS_OUTPUT.PUT_LINE('INSIDE SECOND CONDITION');
  END IF;

 if OUT_ERR_NUM is null then
    OUT_ERR_NUM := 0 ;
    OUT_ERR_MSG := 'SUCCESS';
  else
    OUT_ERR_NUM := 0 ;
    OUT_ERR_MSG := 'BP Code not Avialble';
 end if;
  ---
EXCEPTION
WHEN OTHERS THEN
  --
  OUT_ERR_NUM := SQLCODE;
  OUT_ERR_MSG := SUBSTR(SQLERRM, 1, 300);
   TOSS_UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => 'B2B Carriers',
                                        IP_KEY => TO_CHAR(IN_ZIPCODE),
                                        IP_PROGRAM_NAME => 'GET_BP_CODES',
                                        iP_ERROR_TEXT => OUT_ERR_MSG);
END GET_BP_CODES;


--  EME Tim 10/21/2017 CR54238_Resolve_Issue_with_Orders_Not_Found_in_Commerce

PROCEDURE get_ecomm_biz_purch_hdr_dtl(
                                     i_c_orderid      IN      VARCHAR2,
                                     i_x_ics_rflag    IN      VARCHAR2,
                                     i_x_payment_type IN      VARCHAR2,
                                     po_refcursor         OUT SYS_REFCURSOR)

IS

  op_err_num      NUMBER;
  op_err_string   VARCHAR2(200);
  op_result       VARCHAR2(200);
  out_err_num     NUMBER;
  out_err_message VARCHAR2(200);


BEGIN




     OPEN po_refcursor FOR
   SELECT hdr.c_orderid           orderid
         ,hdr.x_auth_request_id     requestid
         ,hdr.groupidentifier       groupidentifier
         ,hdr.x_customer_firstname  c_firstname
         ,hdr.x_customer_lastname   c_lastname
         ,hdr.x_customer_phone      c_phone
         ,hdr.x_customer_email      c_email
         ,hdr.x_ship_address1       ship_address1
         ,hdr.x_ship_address2       ship_address2
         ,hdr.x_ship_city           ship_city
         ,hdr.x_ship_state          ship_state
         ,hdr.x_ship_zip            ship_zip
         ,hdr.x_amount              amount
         ,hdr.x_tax_amount          tax_amount
         ,hdr.x_sales_tax_amount    sales_tax_amount
         ,hdr.x_e911_tax_amount     e911_tax_amount
         ,hdr.x_usf_taxamount       usf_taxamount
         ,hdr.x_rcrf_tax_amount     rcrf_tax_amount
         ,hdr.discount_amount       discount_amount
         ,hdr.x_auth_amount         auth_amount
         ,hdr.prog_hdr2x_pymt_src   prog_hdr2x_pymt_src
         ,hdr.x_merchant_id         merchantid
         ,dtl.x_amount              amount_dtl
         ,dtl.line_number           line_number
         ,dtl.part_number           part_number
         ,dtl.sales_rate            sales_rate
         ,dtl.salestax_amount       salestax_amount
         ,dtl.e911_rate             e911_rate
         ,dtl.x_e911_tax_amount     e911_tax_amount_dtl
         ,dtl.usf_rate              usf_rate
         ,dtl.x_usf_taxamount       usf_taxamount_dtl
         ,dtl.rcrf_rate             rcrf_rate
         ,dtl.x_rcrf_tax_amount     rcrf_tax_amount_dtl
         ,dtl.total_tax_amount      total_tax_amount
         ,dtl.total_amount          total_amount
         ,dtl.freight_amount        freight_amount_dtl
         ,dtl.freight_method        freight_method
         ,dtl.discount_amount       discount_amount_dtl
         ,dtl.groupidentifier       groupidentifier_dtl
         ,dtl.x_quantity            quantity
     FROM sa.x_biz_purch_hdr hdr,
          sa.x_biz_purch_dtl dtl
    WHERE 1                                   = 1
      AND hdr.c_orderid                       = i_c_orderid
      AND hdr.x_ics_rflag                     = i_x_ics_rflag
      AND hdr.x_payment_type                  = i_x_payment_type
      AND hdr.objid                           = dtl.biz_purch_dtl2biz_purch_hdr
    ORDER BY dtl.groupidentifier ;

	  op_err_num   	:= 0;
	  op_err_string := 'SUCCESS';
	  op_result 	:= 'SUCCESS';

EXCEPTION WHEN OTHERS THEN


	  op_result     := 'ERROR';
	  op_err_num    := SQLCODE;
	  op_err_string := SQLCODE || SUBSTR (SQLERRM, 1, 100);

      dbms_output.put_line('op_result '||op_result);
      dbms_output.put_line('op_err_num '||op_err_num);
      dbms_output.put_line('op_err_string '||op_err_string);

END;
END ecommerce_supply_chain;
/