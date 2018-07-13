CREATE OR REPLACE PACKAGE sa."TEMP_MIGRA_INTELLITRACK" IS

/*****************************************************************
  * Package Name: migra_intellitrack (HEADER)
  * Purpose     : To manage the interface between Clarify and Intellitrack
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Fernando Lasa, DRITON
  * Date        : 09/02/2005
  *
  * Frequency   : All weekdays
  * History
  * REVISIONS    VERSION  DATE        WHO            PURPOSE
  * --------------------------------------------------------------
  *              1.0               Fernando Lasa   Initial Revision
  *              1.2   09/02/05    Fernando Lasa   CR 4260 - To include the procedure
  *                                                  getReplacementPartNum in the header
  *                                                  to allow calls to it in a direct way.
  *              1.3   09/09/05    Fernando Lasa   CR 4187 - To include this header
  *              1.4   09/28/05    Fernando Lasa   CR 4513 - To include procedure TransferPromotions
  *              1.5   12/29/05    Fernando Lasa   CR 4878 - To include procedure RemovePromotions
  *              1.10  10/11/06    Gerald Pintado  PJ244 - Added params to BAD_ADDRESS proc
  *                                                and TransferPromotions proc
  ************************************************************************/

   Procedure Send_Cases;
   --Procedure Bad_Address;
   Procedure Bad_Address(ip_case_number in varchar2,
                         ip_order_number in number
                         );
   Procedure Phone_Shipping;
   Procedure Phone_Receive;
   Procedure getReplacementPartNum(strESN     IN Varchar2,
                                strZipCode IN Varchar2,
                                strType    IN Varchar2,
                                strNewESN      OUT Varchar2,
                                strReplPartNum OUT Varchar2,
                                strError       OUT Varchar2);
   Procedure TransferPromotions(p_objid        IN  NUMBER,
                                --p_OldEsn       IN Varchar2, --Modified by Jasmine on 09/08/2006
                                p_NewEsn       IN Varchar2,
                                p_error_number  OUT Number,
                                p_error_message OUT Varchar2);
   Procedure RemovePromotions(p_ESN           IN VARCHAR2,
                              p_error_number  OUT NUMBER,
                              p_error_message OUT VARCHAR2);

END temp_migra_intellitrack;
/