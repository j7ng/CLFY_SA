CREATE OR REPLACE FUNCTION sa."F_PRODUCT_ALLOWED_SL_PPE" (
    in_esn IN VARCHAR2 )
  RETURN NUMBER
AS
--------------------------------------------------------------------------------------------
 --$RCSfile: f_product_allowed_sl_ppe.sql,v $
 --$Revision: 1.4 $
 --$Author: tbaney $
 --$Date: 2016/12/29 15:30:23 $
 --$ $Log: f_product_allowed_sl_ppe.sql,v $
 --$ Revision 1.4  2016/12/29 15:30:23  tbaney
 --$ Added comment.  CR47024
 --$
 --$ Revision 1.3  2016/12/12 18:29:47  nmuthukkaruppan
 --$ CR42459 - Added Modification History
 --$
 --$
 --$ Revision 1.1  2016/12/02 10:33:53  nmuthukkaruppan
 --$ CR42459  - Safelink Unlimited Plans -  Production selection logic
 --$  --------------------------------------------------------------------------------------------
  l_part_class table_part_class.name%type;
  is_allowed    NUMBER;
  op_err_num    NUMBER;
  op_err_string  VARCHAR2(500);
  /* This function returns 1 if ppe safelink record is found and 0 for others.  */
BEGIN

  SELECT pc.name
    INTO  l_part_class
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_part_class pc
  WHERE    pi.part_serial_no = in_esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num = pn.objid
    AND    pn.domain = 'PHONES'
    AND    pc.objid  = PART_NUM2PART_CLASS;

	dbms_output.put_line('l_part_class       = ' || l_part_class  );
  BEGIN
	SELECT 1
	INTO is_allowed
	FROM pc_params_view
	WHERE param_name = 'PRODUCT_SELECTION'
	  AND part_class  = l_part_class;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        is_allowed  := 0;
  END;

    dbms_output.put_line('  is_allowed     = ' || is_allowed  );

    RETURN is_allowed;

EXCEPTION
WHEN OTHERS THEN
     op_err_num := -1;
     op_err_string  := 'Exception in f_product_allowed_sl_ppe Proc'||SUBSTR (SQLERRM, 1, 300);
     UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Exception occured', IP_KEY => 'in_esn:'||in_esn , IP_PROGRAM_NAME => 'f_product_allowed_sl_ppe', ip_error_text => op_err_string);
     is_allowed  := 0;
     RETURN is_allowed;
END f_product_allowed_sl_ppe;
/