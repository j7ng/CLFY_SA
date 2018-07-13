CREATE OR REPLACE PROCEDURE sa."P_GET_CARRIER_ELIG" (
    I_ESN             IN VARCHAR2,
    I_ZIPCODE         IN VARCHAR2,
    I_SOURCE        IN VARCHAR2,
    I_SIMNUMBER     IN VARCHAR2 ,  --esn or sim either one is mandatory
    O_ELIGIBILITY     OUT VARCHAR2,
    O_CARRIER_ID     OUT VARCHAR2,
    O_CARRIER_NAME     OUT VARCHAR2,
    O_PARENT_CARRIER OUT VARCHAR2,
    O_FAILED_REASON  OUT VARCHAR2,
    O_ERR_CODE          OUT number,
    O_ERR_MSG         OUT VARCHAR2
)
IS
  /*******************************************************************************************************
 --$RCSfile: P_GET_CARRIER_ELIG.sql,v $
 --$Revision: 1.5 $
 --$Author: nmuthukkaruppan $
 --$Date: 2016/07/12 21:50:48 $
 --$ $Log: P_GET_CARRIER_ELIG.sql,v $
 --$ Revision 1.5  2016/07/12 21:50:48  nmuthukkaruppan
 --$ CR42933 - ST refresh - Changes made to have either Esn or Sim is mandatory
 --$
 --$ Revision 1.1 2016/06/24 15:13:12 nmuthukkaruppan
 --$ CR42933 - To check the carrier eligiblity for Port Coverage.
 --$
 * Description: This proc is to check the carrier eligiblity for Port Coverage
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
l_carried_id  VARCHAR2(30);

l_nap_error_no   NUMBER;
l_nap_error_str  VARCHAR2(1000);

l_repl_part               VARCHAR2(100);
l_repl_tech               VARCHAR2(100);
l_sim_profile             VARCHAR2(100);
l_part_serial_no          VARCHAR2(100);
l_msg                     VARCHAR2(400);
l_pref_parent             VARCHAR2(100);
l_pref_carrier_objid      VARCHAR2(100);
l_simnumber               VARCHAR2(100);
l_esn                     VARCHAR2(100);
l_parent_name             VARCHAR2(100);

CURSOR c_get_disp_msg
IS
SELECT npm.error_no, npm.display_msg
FROM   table_nap_msg_mapping npm
WHERE  npm.nap_msg                  =  l_msg
       OR Instr(l_msg,npm.nap_msg)  >  0;
c_get_disp_msg_rec   c_get_disp_msg%ROWTYPE;

  rc customer_type;
  c  customer_type;

BEGIN
o_eligibility:='N';
o_failed_reason:= NULL;

 DBMS_OUTPUT.PUT_LINE('Start i_simnumber' || i_simnumber);

l_esn := i_esn;
l_simnumber := i_simnumber;

IF l_simnumber IS NULL AND l_esn IS NULL THEN
    o_err_code := -1;
    o_err_msg  := 'Either ESN/SIM is mandatory';
    RETURN;
END IF;

IF l_simnumber is NULL AND l_esn IS NOT NULL THEN
  BEGIN
   SELECT x_iccid
     INTO l_simnumber
     FROM table_part_inst
    WHERE x_domain = 'PHONES'
      AND part_serial_no = l_esn;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        o_err_code := -1;
        o_err_msg  := 'ESN does not exist';
        RETURN;
    WHEN OTHERS THEN
      o_err_code := -99;
      o_err_msg  := 'Exception Occured when fetching SIM serial no';
      RETURN;
    END;
ELSIF l_simnumber is NOT NULL AND l_esn IS NULL THEN
  BEGIN
   SELECT part_serial_no
     INTO l_esn
     FROM table_part_inst
    WHERE x_domain = 'PHONES'
      AND x_iccid = l_simnumber;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_err_code := -1;
      o_err_msg  := 'SIM serial number is Invalid';
      RETURN;
    WHEN OTHERS THEN
      o_err_code := -99;
      o_err_msg  := 'Exception Occured when fetching SIM serial no';
      RETURN;
    END;
END IF;

   rc := customer_type ( l_esn );
   c  := rc.retrieve;

DBMS_OUTPUT.PUT_LINE('c.technology: ' || c.technology);

IF (l_simnumber IS NULL  AND (c.technology='GSM' OR lte_service_pkg.is_esn_lte_cdma (l_esn) =1 /*this indicates 4G CDMA*/ )) THEN
    o_err_code := -1;
    o_err_msg  := 'Not able to retrieve SIM for this ESN';
    RETURN;
END IF;

DBMS_OUTPUT.PUT_LINE('l_simnumber: ' || l_simnumber);
DBMS_OUTPUT.PUT_LINE('l_esn: ' || l_esn);

  NAP_DIGITAL(p_zip                 =>  i_zipcode,
              p_esn                 =>  l_esn,
              p_commit              =>  'NO',
              p_sim                 =>  l_simnumber,
              p_source              =>  i_source,
              p_repl_part           =>  l_repl_part,
              p_repl_tech           =>  l_repl_tech,
              p_sim_profile         =>  l_sim_profile,
              p_part_serial_no      =>  l_part_serial_no,
              p_msg                 =>  l_msg,
              p_pref_parent         =>  l_pref_parent,
              p_pref_carrier_objid  =>  l_pref_carrier_objid);

--UTIL_PKG.p_get_carrier_frm_nap_digital(i_zip ,i_esn,i_sim,i_source,o_carrier,o_error_no,o_error_str); -- returns carrier id

DBMS_OUTPUT.PUT_LINE('l_pref_carrier_objid: ' || l_pref_carrier_objid);

  OPEN c_get_disp_msg;
  FETCH c_get_disp_msg INTO c_get_disp_msg_rec;
  IF c_get_disp_msg%NOTFOUND
  THEN
     l_nap_error_no  :=  -1;
     l_nap_error_str :=  l_msg;
  ELSE
     l_nap_error_no  :=  c_get_disp_msg_rec.error_no;
     l_nap_error_str :=  NVL(c_get_disp_msg_rec.display_msg,l_msg);
  END IF;
  CLOSE c_get_disp_msg;

DBMS_OUTPUT.PUT_LINE('l_nap_error_no: ' || l_nap_error_no);
DBMS_OUTPUT.PUT_LINE('l_nap_error_str: ' || l_nap_error_str);

--condition 1
IF l_pref_carrier_objid is not null THEN
     BEGIN
       SELECT X_CARRIER_ID, X_MKT_SUBMKT_NAME,X_PARENT_NAME
         INTO o_carrier_id,o_carrier_name,l_parent_name
         FROM table_x_parent p,
              table_x_carrier_group cg,
              table_x_carrier c
        WHERE 1 = 1
         AND p.objid = cg.X_CARRIER_GROUP2X_PARENT
         AND cg.objid = c.CARRIER2CARRIER_GROUP
         AND c.objid   = l_pref_carrier_objid;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          o_err_code := -1;
          o_err_msg  := 'Carrier Id not found';
          RETURN;
        WHEN OTHERS THEN
          o_err_code := -99;
          o_err_msg  := 'Exception Occured when fetching Carrier Id';
          RETURN;
     END;
ELSE
    o_err_code := -1;
    o_err_msg  := 'Preferred Carrier not found - NAP_DIGITAL';
    RETURN;
END IF;

DBMS_OUTPUT.PUT_LINE('o_carrier_id,o_carrier_name,l_parent_name: ' || o_carrier_id|| '  '||o_carrier_name || '   '||l_parent_name);

 o_carrier_name := util_pkg.get_short_parent_name(l_parent_name);

DBMS_OUTPUT.PUT_LINE('o_parent_carrier: ' || o_parent_carrier);

--condition 2
BEGIN
       SELECT 'Y'
         INTO o_eligibility
         FROM table_x_parent p,
              table_x_carrier_group cg,
              table_x_carrier c
        WHERE 1 = 1
         AND p.objid = cg.X_CARRIER_GROUP2X_PARENT  --
         AND cg.objid = c.CARRIER2CARRIER_GROUP
         AND c.objid  = l_pref_carrier_objid -- <nap_digital preferred carrier>     -- <-- here i will pass the nap_digital preferred carrier
         and p.x_auto_port_in = 1;
    EXCEPTION
    WHEN no_data_found THEN
      o_eligibility:='N';
      o_failed_reason:='No Autoport carrier';

      o_err_code := -1;
      o_err_msg  := o_failed_reason;
      return;
    WHEN OTHERS THEN
      o_err_code := -99;
      o_err_msg  :='Exception Occured checking AutoPort Carrier';
      return;
END;

DBMS_OUTPUT.PUT_LINE('auto port_eligibility: ' || o_eligibility);

--condition 3
IF l_simnumber is NOT NULL THEN
BEGIN
      SELECT 'Y'
      INTO o_eligibility
      FROM TABLE_X_CODE_TABLE
      WHERE X_CODE_TYPE='SIM'
      AND X_CODE_NUMBER IN
              (SELECT X_SIM_INV_STATUS
                FROM TABLE_X_SIM_INV WHERE 1=1
                AND X_SIM_SERIAL_NO =i_simnumber
                )
      AND X_CODE_NUMBER ='253';
EXCEPTION
  WHEN no_data_found THEN
      o_eligibility:='N';
      o_failed_reason:='SIM not NEW';

      o_err_code := -1;
      o_err_msg  := o_failed_reason;
      RETURN;
  WHEN OTHERS THEN
      o_err_code := -99;
      o_err_msg  :='Exception Occured checking SIM status';
      RETURN;
END;
END IF;
DBMS_OUTPUT.PUT_LINE('SIM status NEW: ' || o_eligibility);

--condition 4
o_eligibility:='Y';

o_err_code :=0;
o_err_msg := 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
  o_err_code :=-99;
  o_err_msg := 'Exception in p_get_carrier_elig' ||sqlerrm||':'||dbms_utility.format_error_backtrace;
END p_get_carrier_elig;
/