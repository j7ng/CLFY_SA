CREATE OR REPLACE PACKAGE sa.etailer_service_pkg
AS
/*******************************************************************************************************
  * --$RCSfile: ETAILER_SERVICE_PKG.sql,v $
  --$Revision: 1.5 $
  --$Author: smeganathan $
  --$Date: 2016/06/30 18:17:25 $
  --$ $Log: ETAILER_SERVICE_PKG.sql,v $
  --$ Revision 1.5  2016/06/30 18:17:25  smeganathan
  --$ changes for validate order
  --$
  --$ Revision 1.4  2016/06/28 15:57:20  smeganathan
  --$ changes for qpintoesn
  --$
  --$ Revision 1.3  2016/06/27 22:21:40  smeganathan
  --$ Added Brand validation for PIN and partnumber
  --$
  --$ Revision 1.2  2016/05/06 23:09:53  smeganathan
  --$ CR42257 changes for validate partner
  --$
  --$ Revision 1.1  2016/04/26 21:25:21  smeganathan
  --$ CR42257 new package for etailer
  --$
  --$ Revision 1.11  2016/03/22 16:22:36 smeganathan
  --$ CR42257 - Code logic for Etailer project
  * Description: This package includes procedures
  * that are required for the Etailers to generate Pin / to get pin status
  *
  * -----------------------------------------------------------------------------------------------------
*********************************************************************************************************/
--
PROCEDURE get_partner_param (i_partner_id      IN     VARCHAR2,
                             i_param_name      IN     VARCHAR2,
                             o_param_value     OUT    VARCHAR2,
                             o_err_code        OUT    VARCHAR2,
                             o_err_msg         OUT    VARCHAR2);
--
PROCEDURE get_inv_objid (i_partner_id      IN     VARCHAR2,
                         o_inv_bin_objid   OUT    table_part_inst.PART_INST2INV_BIN%TYPE,
                         o_err_code        OUT    VARCHAR2,
                         o_err_msg         OUT    VARCHAR2);
--
PROCEDURE validate_partner (i_partner_id      IN    VARCHAR2,
                            i_brand           IN     VARCHAR2,
                            i_pin_part_num    IN    VARCHAR2,
                            i_smp             IN    VARCHAR2,
                            i_pin             IN    VARCHAR2,
                            o_inv_bin_objid   OUT   VARCHAR2,
                            o_status          OUT   VARCHAR2,
                            o_err_code        OUT   VARCHAR2,
                            o_err_msg         OUT   VARCHAR2);
--
PROCEDURE p_void_pin (  i_pin                 IN    VARCHAR2,
                        o_post_void_status    OUT   VARCHAR2,
                        o_err_code            OUT   VARCHAR2,
                        o_err_msg             OUT   VARCHAR2);

--
PROCEDURE p_soft_pin_actions (  i_partner_id     IN     VARCHAR2,
                                i_brand          IN     VARCHAR2,
                                i_pin_part_num   IN     table_part_inst.part_serial_no%TYPE,
                                i_pin            IN     table_part_inst.x_red_code%TYPE,
                                i_smp            IN     table_x_cc_red_inv.x_smp%TYPE,
                                i_action         IN     VARCHAR2,
                                o_refcursor      OUT    SYS_REFCURSOR,
                                o_err_code       OUT    VARCHAR2,
                                o_err_msg        OUT    VARCHAR2);
--
PROCEDURE p_qpintoesn_wrp ( i_partner_id  IN  VARCHAR2,
                            i_esn         IN  VARCHAR2,
                            i_pin         IN  VARCHAR2,
                            i_smp         IN  VARCHAR2,
                            i_brand       IN  VARCHAR2,
                            o_err_code    OUT VARCHAR2,
                            o_err_msg     OUT VARCHAR2);
--
PROCEDURE p_validate_orderid (i_partner_id  IN  VARCHAR2,
                              i_brand       IN  VARCHAR2,
                              i_order_id    IN  VARCHAR2,
                              i_action      IN  VARCHAR2,
                              i_pin         IN  VARCHAR2,
                              i_smp         IN  VARCHAR2,
                              o_err_code    OUT VARCHAR2,
                              o_err_msg     OUT VARCHAR2);
--
END etailer_service_pkg;
-- ANTHILL_TEST PLSQL/SA/Packages/ETAILER_SERVICE_PKG.sql 	CR43162: 1.5
/