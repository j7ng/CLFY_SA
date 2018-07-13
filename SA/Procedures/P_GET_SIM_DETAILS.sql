CREATE OR REPLACE PROCEDURE sa."P_GET_SIM_DETAILS" (
    i_sim IN VARCHAR2,
    o_sim_status_code OUT VARCHAR2,
    o_sim_status_msg OUT VARCHAR2,
    o_sim_dealer_code OUT VARCHAR2,
    o_sim_dealer_name OUT VARCHAR2,
    o_sim_brand OUT VARCHAR2,
    o_sim_comp OUT VARCHAR2,
    o_sim_manufacturer OUT VARCHAR2,--46378
    o_err_num OUT NUMBER,
    o_err_msg OUT VARCHAR2)


IS
  --- ----------------------------------------------------------------------------------------------
  -- Author: sethiraj
  -- Date: 2016/01/29
  -- <CR# 39511>
  -- This procedure will get the SIM details for the given SIM number
  -- -----------------------------------------------------------------------------------------------
  -- VERSION  DATE       WHO           PURPOSE
  -- -------  ---------- ----------     ------------------------------------------------------------
  --  1.0     01/29/2016 sethiraj       CR35511 To get the SIM details for the given SIM number
  -- -------  ---------- ----------     ------------------------------------------------------------
  -- Cursor to get the SIM details
  CURSOR cur_sim_details
  IS
	SELECT  si.x_sim_serial_no,
            si.x_sim_inv_status  AS sim_status_code,
            ct.x_code_name       AS sim_status_msg,
            ts.site_id           AS sim_dealer_code,
            ts.NAME              AS sim_dealer_name,
            bo.org_id            AS sim_brand,
            nvl(pcv.x_param_value,'2G')    AS sim_comp,
            pn.X_MANUFACTURER    AS sim_manufacturer --46378
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
  rec_sim_details cur_sim_details%ROWTYPE;
  sim_details_validation_failed EXCEPTION;
  --
BEGIN
  -- Validate SIM
  IF i_sim    IS NULL THEN
    o_err_num := -99;
    o_err_num := 'Error. Unsupported or Null values received for I_SIM';
    RAISE sim_details_validation_failed;
  END IF;
  --
  OPEN cur_sim_details;
  --
  FETCH cur_sim_details INTO rec_sim_details;
  IF cur_sim_details%FOUND THEN
    o_sim_status_code := rec_sim_details.sim_status_code;
    o_sim_status_msg  := rec_sim_details.sim_status_msg;
    o_sim_dealer_code := rec_sim_details.sim_dealer_code;
    o_sim_dealer_name := rec_sim_details.sim_dealer_name;
    o_sim_brand       := rec_sim_details.sim_brand;
    o_sim_comp        := rec_sim_details.sim_comp;
    o_sim_manufacturer:= rec_sim_details.sim_manufacturer; --46378
    o_err_num         := 0;
    o_err_msg         := 'Success';
  ELSE
    o_sim_status_code := '0';
    o_sim_status_msg  := NULL;
    o_sim_dealer_code := NULL;
    o_sim_dealer_name := NULL;
    o_sim_brand       := NULL;
    o_sim_comp        := NULL;
    o_sim_manufacturer:= NULL;--46378
    o_err_num         := -99;
    o_err_msg         := 'No Details found for the given SIM';
  END IF;
  CLOSE cur_sim_details;
EXCEPTION
WHEN sim_details_validation_failed THEN
  o_err_msg:='Error_code: '||o_err_num||' Error_msg: '||o_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
  sa.ota_util_pkg.err_log ( p_action => 'Error', p_error_date => SYSDATE, p_key => 'SIM', p_program_name => 'p_get_sim_details', p_error_text => 'input params: ' || 'i_sim ='||i_sim || ', o_sim_status_code='|| o_sim_status_code || ', o_sim_status_msg=' || o_sim_status_msg || ', o_sim_dealer_code=' || o_sim_dealer_code || ', o_sim_dealer_name=' || o_sim_dealer_name || ', o_sim_brand= ' || o_sim_brand || ', o_sim_comp= ' || o_sim_comp || ', o_err_num='||o_err_num || ', o_err_msg='|| o_err_msg );
WHEN OTHERS THEN
  o_err_num := -99;
  o_err_msg := sqlerrm;
  sa.ota_util_pkg.err_log ( p_action => 'Error', p_error_date => SYSDATE, p_key => 'SIM', p_program_name => 'p_get_sim_details', p_error_text => 'input params: ' || 'i_sim ='||i_sim || ', o_sim_status_code='|| o_sim_status_code || ', o_sim_status_msg=' || o_sim_status_msg || ', o_sim_dealer_code=' || o_sim_dealer_code || ', o_sim_dealer_name=' || o_sim_dealer_name || ', o_sim_brand= ' || o_sim_brand || ', o_sim_comp= ' || o_sim_comp || ', o_err_num='||o_err_num || ', o_err_msg='|| o_err_msg );
END p_get_sim_details;
/