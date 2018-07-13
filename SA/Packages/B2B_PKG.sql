CREATE OR REPLACE PACKAGE sa."B2B_PKG"
 /*******************************************************************************************************
  --$RCSfile: B2B_PKG.sql,v $
  --$Revision: 1.4 $
  --$Author: cpannala $
  --$Date: 2014/04/29 14:12:46 $
  --$ $Log: B2B_PKG.sql,v $
  --$ Revision 1.4  2014/04/29 14:12:46  cpannala
  --$ CR25490
  --$
  --$ Revision 1.1  2014/02/20 19:22:36  cpannala
  --$ CR22623 - B2B Initiative
  --$ Description: This procedure generates B2B esn for given part number.
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
AS
  -----
  PROCEDURE is_b2b_prc(
      ip_type  VARCHAR2,
      ip_value VARCHAR2,
      IP_BRAND VARCHAR2,--Only needed if ip_type = email
      OP_RESULT OUT NUMBER,
      OP_ERR_NUM OUT NUMBER,
      OP_ERR_MSG OUT VARCHAR2);
  ------
  PROCEDURE set_address(
      in_address IN address_type_rec,
      out_addr_objid OUT table_address.objid%TYPE);
  ----
 FUNCTION  B2B_MERCHANT_REF_NUMBER(in_channel varchar2)
    RETURN VARCHAR2;
  ----
  FUNCTION is_b2b(
      ip_type  VARCHAR2,
      ip_value VARCHAR2,
      IP_BRAND VARCHAR2,--Only needed if ip_type = email
      OP_ERR_NUM OUT NUMBER,
      OP_ERR_MSG OUT VARCHAR2 )
    RETURN NUMBER;
  ----
 PROCEDURE          get_esn_web_user(
    in_login_name IN table_web_user.login_name%TYPE ,
    IN_BUS_ORG    IN VARCHAR2,
    in_esn        IN table_part_inst.part_serial_no%type DEFAULT NULL,
    in_min        in table_site_part.x_min%type default null,
    out_wu_objid OUT NUMBER,
    out_esn_wuobjid out number,
    out_bo_objid out number,
    out_err_num OUT NUMBER,
    out_Err_msg OUT VARCHAR2);

  PROCEDURE b2b_err_log_proc(in_rec err_rec,
                          out_code  out number,
                          out_msg   out varchar2);
END B2B_PKG;
/