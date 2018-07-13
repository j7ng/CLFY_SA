CREATE OR REPLACE PACKAGE sa."ORGANIZATION_SERVICES_PKG"
AS
  ---------------------------------------------------------------------------------------------
  --$RCSfile: ORGANIZATION_SERVICES_PKG.sql,v $
  --$Revision: 1.7 $
  --$Author: cpannala $
  --$Date: 2014/04/02 14:03:14 $
  --$ $Log: ORGANIZATION_SERVICES_PKG.sql,v $
  --$ Revision 1.7  2014/04/02 14:03:14  cpannala
  --$ CR25490 Impemataion change
  --$
  ---------------------------------------------------------------------------------------------
  -- global variable - for debugging purposes
  g_v_debug BOOLEAN := FALSE;
  --
  PROCEDURE createOrganization(
      in_org_dtls IN org_type_rec,
      out_org_objid OUT table_site.objid%TYPE,
      out_err_num OUT NUMBER,
      out_err_msg OUT VARCHAR2);
  ----
  PROCEDURE deleteOrganization(
      In_Commerce_Id IN Table_Site.X_Commerce_Id%Type,
      out_err_num OUT NUMBER,
      Out_Err_Msg OUT VARCHAR2);
  ----------
  PROCEDURE updateOrganization(
      In_Org_Dtls IN  org_type_rec,
      out_err_num OUT NUMBER,
      Out_Err_Msg OUT VARCHAR2);
  --------------------
  PROCEDURE getOrganization(
      in_Commerce_Id IN table_site.x_commerce_id%TYPE,
      Out_Org_Structure_Dtls OUT Sys_Refcursor,
      out_err_num OUT NUMBER,
      Out_Err_Msg OUT VARCHAR2);
  --------------
  PROCEDURE assignBuyer(
      in_Commerce_Id IN table_site.x_commerce_id%TYPE,
      in_web_accnt   IN Table_Web_User.Login_Name%TYPE,
      in_brand       IN table_bus_org.org_id%TYPE,
      In_Buyer_Type  IN X_Site_Web_Accounts.X_Account_Type%Type,
      out_err_num OUT NUMBER,
      Out_Err_Msg OUT VARCHAR2);
  ----------
END organization_services_pkg;
/