CREATE OR REPLACE PACKAGE sa.account_services_pkg IS
  /*******************************************************************************************************
  *  --$RCSfile: account_services_pkg.sql,v $
    --$Revision: 1.8 $
    --$Author: ddevaraj $
    --$Date: 2016/01/12 21:15:44 $
    --$ $Log: account_services_pkg.sql,v $
    --$ Revision 1.8  2016/01/12 21:15:44  ddevaraj
    --$ FOR CR39698
    --$
    --$ Revision 1.7  2015/02/04 19:31:31  oarbab
    --$ switched getaccountsummary parameter io_account_summary IN OUT typ_account_summary_tbl to out only. new name out_account_summary
    --$
    --$ Revision 1.6  2015/01/28 22:20:12  gsaragadam
    --$ CR31683 Added i/p parameter to getaccountsummary Procedure
    --$
    --$ Revision 1.5  2015/01/23 18:48:44  gsaragadam
    --$ CR31683 Updated Package Spec
    --$
    --$ Revision 1.4  2014/05/23 19:13:02  adasgupta
    --$ procedure validate_plan added for CR28212
    --$
    --$ Revision 1.3  2014/02/07 15:44:15  cpannala
    --$ CR25490 ADDESNTOACCOUNT procedure added
    --$
    --$ Revision 1.1  2013/12/03 cpannala
    --$ CR22623 - B2B Initiative
    --$ CR28212 -- Adasgupta
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
  PROCEDURE getesnlistbycriterias
  (
    in_login_name      IN table_web_user.login_name%TYPE
   ,in_bus_org         IN VARCHAR2
   ,in_esn             IN table_part_inst.part_serial_no%TYPE DEFAULT NULL
   ,in_min             IN table_site_part.x_min%TYPE DEFAULT NULL
   ,io_esn_info        IN OUT typ_esn_info_tbl
   ,in_order_by_field  IN VARCHAR2
   ,in_order_direction IN VARCHAR2 DEFAULT 'ASC'
   ,in_start_idx       IN BINARY_INTEGER DEFAULT 0
   ,in_max_rec_number  IN NUMBER DEFAULT 25
   ,out_err_num        OUT NUMBER
   ,out_err_msg        OUT VARCHAR2
  );

  PROCEDURE addesntoaccount
  (
    in_esn          IN table_part_inst.part_serial_no%TYPE
   ,in_login_name   IN table_web_user.login_name%TYPE
   ,in_org_id       IN VARCHAR2
   , --brand
    in_sourcesystem IN VARCHAR2
   ,out_err_num     OUT VARCHAR2
   ,out_err_msg     OUT VARCHAR2
  );

  PROCEDURE validate_plan
  (
    p_service_plan_id  IN x_service_plan.objid%TYPE
   ,p_org_id           IN table_bus_org.org_id%TYPE
   ,op_billing_plan_id OUT NUMBER
   ,op_is_unlimited    OUT NUMBER
   , --- 1 or 0
    op_er_cd           OUT NUMBER
   ,op_msg             OUT VARCHAR2
  );
  --CR31683 Start Kacosta 01/22/2015

  --added FOR CR39698
   PROCEDURE b2b_validate_plan
 (
 p_b2b_part_num in varchar2
 ,p_org_id IN table_bus_org.org_id%TYPE
 ,op_billing_plan_id OUT NUMBER
 ,op_is_unlimited OUT NUMBER
 , --- 1 or 0
 op_er_cd OUT NUMBER
 ,op_msg OUT VARCHAR2
 );
  --end addition FOR CR39698

  PROCEDURE getaccountsummary
  (
    organizationid     IN VARCHAR2
   ,in_login_name      IN table_web_user.login_name%TYPE
   ,in_bus_org         IN table_bus_org.org_id%TYPE
   ,out_account_summary OUT typ_account_summary_tbl
   ,out_err_num        OUT NUMBER
   ,out_err_msg        OUT VARCHAR2
  );
  --CR31683 End Kacosta 01/22/2015
--
END account_services_pkg;
/