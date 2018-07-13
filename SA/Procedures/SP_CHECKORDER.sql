CREATE OR REPLACE PROCEDURE sa."SP_CHECKORDER"
(In_OrderId         IN VARCHAR2,
 In_Rqst_type       IN VARCHAR2,
 In_alt_pymt_source IN VARCHAR2 ,
 Out_IsOrderExist   OUT VARCHAR2,
 Out_Err_Num        OUT NUMBER,
 Out_Err_Msg        OUT VARCHAR2
 )
 IS
  /*******************************************************************************************************
 --$RCSfile: SP_CHECKORDER.sql,v $
 --$Revision: 1.4 $
 --$Author: nmuthukkaruppan $
 --$Date: 2016/06/27 15:26:28 $
 --$ $Log: SP_CHECKORDER.sql,v $
 --$ Revision 1.4  2016/06/27 15:26:28  nmuthukkaruppan
 --$ CR39912 - Changes
 --$
 --$ Revision 1.3  2016/06/24 19:37:06  nmuthukkaruppan
 --$ CR39912 - ST Commerce -  Check Order for SmartPay service
 --$
 --$ Revision 1.2  2016/06/24 19:29:45  nmuthukkaruppan
 --$ CR39912 - ST Commerce -  Check Order for SmartPay service
 --$
 --$ Revision 1.1 2016/06/18 15:13:12 nmuthukkaruppan
 --$ CR39912 - ST Commerce - Go Live changes
 --$
 * Description: This proc is to check if the order exists
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
    Input_validation_Failed EXCEPTION;
  BEGIN
   IF In_OrderId IS NULL OR In_Rqst_type IS NULL OR In_alt_pymt_source IS NULL THEN
      Out_Err_Num := 1;
      Out_Err_Msg  := 'Invalid Inputs';
      raise Input_validation_Failed ;
   END IF;

   BEGIN
      SELECT distinct 'Y'
        INTO  Out_IsOrderExist
        FROM X_BIZ_PURCH_HDR HDR, table_x_altpymtsource alt
       WHERE hdr.C_ORDERID = In_OrderId
         AND hdr.X_RQST_TYPE = In_Rqst_type
         AND hdr.PURCH_HDR2ALTPYMTSOURCE = alt.objid
         AND alt.X_ALT_PYMT_SOURCE  = In_alt_pymt_source
         AND hdr.X_PAYMENT_TYPE = 'SETTLEMENT';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Out_IsOrderExist := 'N';
     WHEN OTHERS THEN
      Out_Err_Num := 1;
      Out_Err_Msg  := 'Exception - '||SUBSTR (SQLERRM, 1, 300);
      UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Exception Occured', IP_KEY => 'OrderId:'||In_Orderid || ',Rqst_type:'||In_Rqst_type || ',Alt_PymtSource '|| In_alt_pymt_source, IP_PROGRAM_NAME => 'sp_checkorder', ip_error_text => OUT_Err_MSg);
      RETURN;
   END;

  Out_Err_Num := 0;
  Out_Err_Msg  := 'SUCCESS';
EXCEPTION
 WHEN Input_validation_Failed THEN
    	UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input_validation_Failed', IP_KEY => 'OrderId:'||In_Orderid || ',Rqst_type:'||In_Rqst_type || ',Alt_PymtSource '|| In_alt_pymt_source, IP_PROGRAM_NAME => 'sp_checkorder', ip_error_text => OUT_Err_MSg);
 WHEN OTHERS THEN
    Out_Err_Num  := 1  ;
    Out_Err_Msg  :=  'Exception in sp_checkorder '||SUBSTR (SQLERRM, 1, 300);
    UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY =>'OrderId:'||In_Orderid || ',Rqst_type:'||In_Rqst_type || ',Alt_PymtSource '|| In_alt_pymt_source, IP_PROGRAM_NAME => 'sp_checkorder', ip_error_text => OUT_Err_MSg);
END;
/