CREATE OR REPLACE FUNCTION sa."GET_SAFELINKASSIST_FLAG" (
    in_esn IN VARCHAR2 )
  RETURN VARCHAR2
AS
--------------------------------------------------------------------------------------------
 --$RCSfile: get_safelinkassist_flag.sql,v $
 --$Revision: 1.2 $
 --$Author: nmuthukkaruppan $
 --$Date: 2017/06/26 15:52:28 $
 --$ $Log: get_safelinkassist_flag.sql,v $
 --$ Revision 1.2  2017/06/26 15:52:28  nmuthukkaruppan
 --$ CR51656  -  Comment the logging into BIZ_ERROR_TABLE
 --$
 --$ Revision 1.1  2017/05/08 19:24:11  nmuthukkaruppan
 --$ CR49808 - To identify if the ESN is assocaited for the SafeLink Assist Program.
 --$
 --$ Revision 1.1  2017/05/09 10:33:53  nmuthukkaruppan
 --$ CR49808  - Safelink Assist Program
 --$  --------------------------------------------------------------------------------------------
  l_safelinkassist_flag    VARCHAR2(1);
  op_err_num    NUMBER;
  op_err_string  VARCHAR2(500);
  /* This function returns 1 if esn is associated with safelink assist program */
BEGIN

     SELECT 'Y'
	    INTO l_safelinkassist_flag
        FROM table_part_inst tpi_esn
        JOIN table_x_group2esn xge
          ON tpi_esn.objid = xge.groupesn2part_inst
        JOIN table_x_promotion_group xpg
          ON xge.groupesn2x_promo_group = xpg.objid
       WHERE  tpi_esn.part_serial_no =  in_esn
           AND  SYSDATE BETWEEN NVL(xge.x_start_date
                                ,SYSDATE) AND NVL(xge.x_end_date
                                                 ,SYSDATE)
         AND xpg.group_name LIKE 'SLA_GRP'
       ORDER BY xge.x_end_date   DESC
               ,xge.x_start_date DESC
               ,xge.objid        DESC;


    dbms_output.put_line('  l_safelinkassist_flag     = ' || l_safelinkassist_flag  );

    RETURN l_safelinkassist_flag;

EXCEPTION
WHEN OTHERS THEN
     op_err_num := -1;
     op_err_string  := 'Exception in get_safelinkassist_flag '||SUBSTR (SQLERRM, 1, 300);
    --CR51656  - remove logging as it create more rows in biz_error_table and impacting production.
	-- UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Exception occured', IP_KEY => 'in_esn:'||in_esn , IP_PROGRAM_NAME => 'get_safelinkassist_flag', ip_error_text => op_err_string);
     l_safelinkassist_flag  := 'N';
     RETURN l_safelinkassist_flag;
END get_safelinkassist_flag;
/