CREATE OR REPLACE PACKAGE sa.Full_fillment_Services_pkg
IS
 /*******************************************************************************************************
 *--$RCSfile: FULL_FILLMENT_SERVICES_pkg.sql,v $
 --$Revision: 1.16 $
  --$Author: smeganathan $
  --$Date: 2017/07/17 14:53:29 $
  --$ $Log: FULL_FILLMENT_SERVICES_pkg.sql,v $
  --$ Revision 1.16  2017/07/17 14:53:29  smeganathan
  --$ Code changes for Automated return of SIM and SOFTPINs
  --$
  --$ Revision 1.15  2017/05/24 15:44:25  smeganathan
  --$ Merged Amazon Discounted plans code with 5/23 prod release
  --$
  --$ Revision 1.13  2017/05/03 18:16:49  vlaad
  --$ Added validate inputs
  --$
  --$ Revision 1.12  2017/04/24 18:37:48  smeganathan
  --$ added parameter i_consumer to b2c procedure
  --$
  --$ Revision 1.11  2017/04/12 18:15:16  smeganathan
  --$ Added provision_service_plan_b2c
  --$
  --$ Revision 1.10  2017/04/07 20:09:01  smeganathan
  --$ Added provision_service_plan_b2c
  --$
  --$ Revision 1.7  2016/07/27 19:40:29  vyegnamurthy
  --$ CR42260 Added new parameter to accept the channel
  --$
  --$ Revision 1.4  2014/04/02 15:10:50  cpannala
  --$ CR25490
  --$
  --$ Revision 1.1  2013/12/11 cpannala
  --$ CR22623 - B2B Initiative
  --$Description:New package forB2B CR22623: To provision the benifits to the coustmer
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
PROCEDURE PROVISION_SERVICE_PLAN(
    in_order_id         IN  x_biz_purch_hdr.c_orderid%TYPE,
    in_account_id       IN  table_web_user.login_name%TYPE,
    in_bus_org_id       IN  table_bus_org.org_id%TYPE,
    in_organization_id  IN  table_site.x_commerce_id%TYPE, -- Organization ID as passed commerce --CR47608
    in_paymentsourceid  IN  x_payment_source.objid%Type,
    io_esn_part_num     IN  OUT esn_part_num_tbl,
    out_err_num         OUT NUMBER,
    out_err_message     OUT VARCHAR2,
    p_consumer          IN  VARCHAR2 DEFAULT NULL,--CR42260
    i_ship_loc_id       IN  table_site.x_ship_loc_id%TYPE -- Organization ID as passed by OFS   --CR47608
    );
--
--CR47608 made procedure signature public
PROCEDURE validate_inputs( in_order_id           IN  x_biz_purch_hdr.c_orderid%TYPE,
                           In_Paymentsourceid    IN  NUMBER,
                           in_account_id         IN  VARCHAR2,
                           in_bus_org_id         IN  VARCHAR2,
                           in_organization_id    IN  table_site.x_commerce_id%TYPE, --CR47608
                           in_esn_tbl_count      IN  NUMBER,
                           op_org_objid          OUT NUMBER,
                           op_wu_objid           OUT NUMBER,
                           op_dealer_invbinobjid OUT NUMBER,
                           site_objid            OUT NUMBER,
                           out_err_num           OUT NUMBER,
                           out_err_msg           OUT VARCHAR2,
                           i_ship_loc_id         IN  table_site.x_ship_loc_id%TYPE  --CR47608
                          );
--
--  CR48480 changes starts...
--  Procedure to generate soft pin and queue it to ESN
--  this procedure is called for B2C mixed (tangible and intangible) orders
--
PROCEDURE provision_service_plan_b2c( i_bus_org_id          IN  VARCHAR2,
                                      i_consumer            IN VARCHAR2 DEFAULT NULL,
                                      i_order_id            IN  VARCHAR2,   -- CR51737
                                      io_esn_part_num       IN OUT Esn_Part_Num_Tbl,
                                      o_err_msg             OUT VARCHAR2,
                                      o_err_code            OUT VARCHAR2);
--  CR48480 changes ends.
END FULL_FILLMENT_SERVICES_pkg;
/