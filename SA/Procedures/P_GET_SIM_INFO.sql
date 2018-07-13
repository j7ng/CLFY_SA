CREATE OR REPLACE PROCEDURE sa."P_GET_SIM_INFO" (
    i_sim IN VARCHAR2,
    i_zip IN VARCHAR2,
    o_sim_status_code OUT VARCHAR2,
    o_sim_status_msg OUT VARCHAR2,
    o_sim_dealer_code OUT VARCHAR2,
    o_sim_dealer_name OUT VARCHAR2,
    o_sim_brand OUT VARCHAR2,
    o_sim_comp OUT VARCHAR2,
    o_esn    OUT VARCHAR2,
    o_phone_carrier OUT VARCHAR2,
    o_technology OUT VARCHAR2,
    o_sim_type   OUT VARCHAR2,
    o_err_num OUT NUMBER,
    o_err_msg OUT VARCHAR2
     )
IS
  /*******************************************************************************************************
 --$RCSfile: P_GET_SIM_INFO.sql,v $
 --$Revision: 1.4 $
 --$Author: nmuthukkaruppan $
 --$Date: 2016/07/12 21:39:37 $
 --$ $Log: P_GET_SIM_INFO.sql,v $
 --$ Revision 1.4  2016/07/12 21:39:37  nmuthukkaruppan
 --$  CR42933  - ST refresh changes
 --$
 --$ Revision 1.1 2016/06/24 15:13:12 nmuthukkaruppan
 --$ CR42933 - To get all the required info for the given SIM.
 --$
 * Description: This proc is to get the SIM details
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/

  CURSOR cur_married_sim_details
  IS
	SELECT  si.x_sim_serial_no,
            Pi.Part_Serial_No    AS ESN,   --CR42933
            si.x_sim_inv_status  AS sim_status_code,
            ct.x_code_name       AS sim_status_msg,
            ts.site_id           AS sim_dealer_code,
            ts.NAME              AS sim_dealer_name,
            bo.org_id            AS sim_brand,
            nvl(pcv.x_param_value,'2G')    AS sim_comp,
            pn.part_number      AS sim_part_number
    FROM  table_part_inst pi,
          table_x_sim_inv si,
          table_inv_bin ib,
          table_inv_locatn il,
          table_site ts,
          table_x_code_table ct,
          table_part_mod_v pm,
          table_part_num pn,
          table_bus_org bo,
          table_part_class pc,
          table_x_part_class_values pcv,
          table_x_part_class_params pcp
    WHERE pi.x_iccid             = si.x_sim_serial_no
    AND   pi.PART_INST2INV_BIN   = ib.objid
    AND   ib.inv_bin2inv_locatn  = il.objid
    AND   il.inv_locatn2site     = ts.objid
    AND   si.x_sim_inv_status    = ct.x_code_number
    AND   ct.x_code_type         = 'SIM'
    AND   si.x_sim_inv2part_mod  = pm.objid
    AND   pm.part_num_objid      = pn.objid
    AND   pn.part_num2part_class = pc.objid
    AND   pc.objid               = pcv.value2part_class (+)
    AND   pcv.value2class_param  = pcp.objid (+)
    AND   pcp.x_param_name (+)   = 'PHONE_GEN'
    AND   pn.part_num2bus_org    = bo.objid (+)
    AND   pi.x_iccid             = i_sim ;
	--

  CURSOR cur_sim_details
  IS
  SELECT  si.x_sim_serial_no,
            si.x_sim_inv_status  AS sim_status_code,
            ct.x_code_name       AS sim_status_msg,
            bo.org_id            AS sim_brand,
            nvl(pcv.x_param_value,'2G')    AS sim_comp,
            pn.part_number      AS sim_part_number
    FROM   table_x_sim_inv si,
          table_x_code_table ct,
          table_part_mod_v pm,
          table_part_num pn,
          table_bus_org bo,
          table_part_class pc,
          table_x_part_class_values pcv,
          table_x_part_class_params pcp
    WHERE   si.x_sim_inv_status    = ct.x_code_number
    AND   ct.x_code_type         = 'SIM'
    AND   si.x_sim_inv2part_mod  = pm.objid
    AND   pm.part_num_objid      = pn.objid
    AND   pn.part_num2part_class = pc.objid
    AND   pc.objid               = pcv.value2part_class (+)
    AND   pcv.value2class_param  = pcp.objid (+)
    AND   pcp.x_param_name (+)   = 'PHONE_GEN'
    AND   pn.part_num2bus_org    = bo.objid (+)
    AND  si.x_sim_serial_no      = i_sim ;

  rec_sim_details cur_sim_details%ROWTYPE;
  rec_married_sim_details cur_married_sim_details%ROWTYPE;
  sim_details_validation_failed EXCEPTION;

  --Variables for CR42933
  rc customer_type;
  c  customer_type;

  c_sim_profile  table_part_num.s_part_number%type;
  l_carrier_id   table_x_carrier.x_carrier_id%type;
  l_parent_name  table_x_parent.x_parent_name%type;


BEGIN
  -- Validate SIM
  IF i_sim  IS NULL THEN
    o_err_num := -99;
    o_err_msg := 'Error. Unsupported or Null values received for I_SIM';
    RAISE sim_details_validation_failed;
  END IF;
  --
  OPEN cur_sim_details;
  OPEN cur_married_sim_details;
  --
  FETCH cur_married_sim_details INTO rec_married_sim_details;
  FETCH cur_sim_details INTO rec_sim_details;

  IF cur_married_sim_details%FOUND THEN
    o_sim_status_code := rec_married_sim_details.sim_status_code;
    o_sim_status_msg  := rec_married_sim_details.sim_status_msg;
    o_sim_dealer_code := rec_married_sim_details.sim_dealer_code;
    o_sim_dealer_name := rec_married_sim_details.sim_dealer_name;
    o_sim_brand       := rec_married_sim_details.sim_brand;
    o_sim_comp        := rec_married_sim_details.sim_comp;
    o_esn             := rec_married_sim_details.esn;
    c_sim_profile     := rec_married_sim_details.sim_part_number;
    o_err_num         := 0;
    o_err_msg         := 'Success';
  ELSIF cur_sim_details%FOUND THEN
    o_sim_status_code := rec_sim_details.sim_status_code;
    o_sim_status_msg  := rec_sim_details.sim_status_msg;
    o_sim_dealer_code := NULL;
    o_sim_dealer_name := NULL;
    o_sim_brand       := rec_sim_details.sim_brand;
    o_sim_comp        := rec_sim_details.sim_comp;
    o_esn             := NULL;
    c_sim_profile     := rec_sim_details.sim_part_number;
    o_err_num         := 0;
    o_err_msg         := 'Success';
  ELSE
    o_sim_status_code := '0';
    o_sim_status_msg  := NULL;
    o_sim_dealer_code := NULL;
    o_sim_dealer_name := NULL;
    o_sim_brand       := NULL;
    o_sim_comp        := NULL;
    o_esn             := NULL;
    c_sim_profile     := NULL;
    o_err_num         := -99;
    o_err_msg         := 'No Details found for the given SIM';
  END IF;
  CLOSE cur_married_sim_details;
  CLOSE cur_sim_details;

   DBMS_OUTPUT.PUT_LINE('c_sim_profile ' || c_sim_profile);

  BEGIN
   SELECT CARRIER_ID
     INTO l_carrier_id
     FROM (
           SELECT MIN(to_number(cp.new_rank)) new_rank,
                b.carrier_id,
                a.sim_profile,
                a.min_dll_exch,
                a.max_dll_exch
           FROM carrierpref cp,
                npanxx2carrierzones b,
                (SELECT DISTINCT a.ZONE,
                        a.st,
                        s.sim_profile,
                        a.county,
                        s.min_dll_exch,
                        s.max_dll_exch,
                        s.rank
                   FROM carrierzones a,
                        carriersimpref s
                  WHERE a.zip       = i_zip
                    AND a.CARRIER_NAME=s.CARRIER_NAME
                  ORDER BY s.rank ASC ) a
          WHERE 1           =1
            AND cp.st         = b.state
            AND cp.carrier_id = b.carrier_ID
            AND cp.county     = a.county
            AND a.sim_profile = DECODE(c_sim_profile,NULL,a.sim_profile,c_sim_profile)
            AND b.ZONE        = a.ZONE
            AND b.state       = a.st
          group by  a.sim_profile, b.carrier_id, a.min_dll_exch, a.max_dll_exch
          )
      WHERE rownum = 1;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        sa.ota_util_pkg.err_log ( p_action => 'Error', p_error_date => SYSDATE, p_key => 'SIM', p_program_name => 'p_get_sim_info', p_error_text => 'Carrier Not Found');
   END;
   DBMS_OUTPUT.PUT_LINE('l_carrier_id ' || l_carrier_id);

  BEGIN
     SELECT X_PARENT_NAME
       INTO l_parent_name
       FROM table_x_parent p,
            table_x_carrier_group cg,
            table_x_carrier c
      WHERE 1 = 1
       AND p.objid = cg.X_CARRIER_GROUP2X_PARENT
       AND cg.objid = c.CARRIER2CARRIER_GROUP
       AND c.x_carrier_id   = l_carrier_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      sa.ota_util_pkg.err_log ( p_action => 'Error', p_error_date => SYSDATE, p_key => 'SIM', p_program_name => 'p_get_sim_info', p_error_text => 'Parent Carrier Not Found');
   END;

--CR42933 - To get Carrier, and Technology
   rc := customer_type ( i_esn => o_esn );
   c  := rc.retrieve;

   o_technology    := c.technology;
   o_sim_type      := sa.BYOP_SERVICE_PKG.get_byop_sim_type(rec_sim_details.sim_part_number);

   o_phone_carrier := util_pkg.get_short_parent_name(l_parent_name);

   DBMS_OUTPUT.PUT_LINE('l_parent_name ' || l_parent_name);
   DBMS_OUTPUT.PUT_LINE('phone_carrier: ' || o_phone_carrier);
   DBMS_OUTPUT.PUT_LINE('technology: ' || o_technology);

EXCEPTION
WHEN sim_details_validation_failed THEN
  sa.ota_util_pkg.err_log ( p_action => 'Error', p_error_date => SYSDATE, p_key => 'SIM', p_program_name => 'p_get_sim_details', p_error_text => 'input params: ' || 'i_sim ='||i_sim || ', o_sim_status_code='|| o_sim_status_code || ', o_sim_status_msg=' || o_sim_status_msg || ', o_sim_dealer_code=' || o_sim_dealer_code || ', o_sim_dealer_name=' || o_sim_dealer_name || ', o_sim_brand= ' || o_sim_brand || ', o_sim_comp= ' || o_sim_comp || ', o_err_num='||o_err_num || ', o_err_msg='|| o_err_msg );
WHEN OTHERS THEN
  o_err_num := -99;
  o_err_msg := sqlerrm;
  sa.ota_util_pkg.err_log ( p_action => 'Error', p_error_date => SYSDATE, p_key => 'SIM', p_program_name => 'p_get_sim_details', p_error_text => 'input params: ' || 'i_sim ='||i_sim || ', o_sim_status_code='|| o_sim_status_code || ', o_sim_status_msg=' || o_sim_status_msg || ', o_sim_dealer_code=' || o_sim_dealer_code || ', o_sim_dealer_name=' || o_sim_dealer_name || ', o_sim_brand= ' || o_sim_brand || ', o_sim_comp= ' || o_sim_comp || ', o_err_num='||o_err_num || ', o_err_msg='|| o_err_msg );
END p_get_sim_info;
/