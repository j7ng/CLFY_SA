CREATE OR REPLACE PACKAGE sa.rtr_multi_trans_pkg
AS
  /*******************************************************************************************************
  --$RCSfile: RTR_MULTI_TRANS_PKG.sql,v $
  --$ $Log: RTR_MULTI_TRANS_PKG.sql,v $
  --$ Revision 1.7  2018/04/23 16:11:19  sgangineni
  --$ CR49520 - New overloaded proc get_order_status
  --$
  --$ Revision 1.6  2018/02/09 21:52:30  sraman
  --$ added another input out paramter for rtr_trans_type
  --$
  --$ Revision 1.5  2018/02/09 16:42:30  sraman
  --$ added new procedure get_order_status
  --$
  --$ Revision 1.4  2017/10/04 18:15:56  nsurapaneni
  --$ Added Procedure cancel order
  --$
  --$ Revision 1.3  2017/09/25 18:33:36  sraman
  --$ Added new Procs
  --$
  --$ Revision 1.2  2017/09/20 14:52:59  vnainar
  --$ CR48260  removed  get_app_part_num and get_billing_part_num
  --$
  --$ Revision 1.1  2017/09/19 18:00:36  sgangineni
  --$ CR48260 (SM MLD) - RTR_MULTI_TRANS_PKG specification initial version
  --$
  --$
  * Description: This package includes the below procedures and functions
  *                 GET_BILLING_PART_NUM
  *                 VALIDATE_ORDER
  *                 SUBMIT_ORDER
  *                 UPDATE_ORDER
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/

  PROCEDURE  validate_order ( io_rtr_header_type    IN OUT  rtr_trans_header_type,
                              o_error_code          OUT     VARCHAR2,
                              o_error_message       OUT     VARCHAR2
                            );

  PROCEDURE  submit_order   ( io_rtr_header_type    IN OUT  rtr_trans_header_type,
                              o_error_code          OUT     VARCHAR2,
                              o_error_message       OUT     VARCHAR2
                            );

  PROCEDURE  update_order   ( io_rtr_header_type    IN OUT  rtr_trans_header_type,
                              o_error_code          OUT     VARCHAR2,
                              o_error_message       OUT     VARCHAR2
                            );

  PROCEDURE  process_rtr_outbound ( o_error_code          OUT     VARCHAR2,
                                    o_error_message       OUT     VARCHAR2
                                  );

  PROCEDURE  sync_rtr_outbound    ( o_error_code          OUT     VARCHAR2,
                                    o_error_message       OUT     VARCHAR2
                                  );

  PROCEDURE  cancel_order   ( io_rtr_header_type        IN OUT  rtr_trans_header_type,
                              i_rtr_transid_add_fund    IN      VARCHAR2,
                              o_error_code              OUT     VARCHAR2,
                              o_error_message           OUT     VARCHAR2
                             );

  PROCEDURE  get_order_status ( i_rtr_vendor_name        IN      VARCHAR2                  ,
                                io_esn                   IN OUT  VARCHAR2                  ,
                                io_min                   IN OUT  VARCHAR2                  ,
                                io_order_id              IN OUT  VARCHAR2                  ,
                                io_rtr_trans_type	     IN OUT  VARCHAR2                  ,
                                o_order_status           OUT     VARCHAR2                  ,
                                o_trans_date             OUT     DATE                      ,
                                o_error_code             OUT     VARCHAR2                  ,
                                o_error_message          OUT     VARCHAR2
                             );

  --CR49520 changes start
  PROCEDURE  get_order_status ( i_rtr_vendor_name        IN      VARCHAR2                  ,
                                io_esn                   IN OUT  VARCHAR2                  ,
                                io_min                   IN OUT  VARCHAR2                  ,
                                io_order_id              IN OUT  VARCHAR2                  ,
                                io_rtr_trans_type	       IN OUT  VARCHAR2                  ,
                                o_order_status           OUT     VARCHAR2                  ,
                                o_trans_date             OUT     DATE                      ,
                                o_error_code             OUT     VARCHAR2                  ,
                                o_error_message          OUT     VARCHAR2                  ,
                                o_ord_details            OUT     rtr_order_detail_tab
                             );
	--CR49520 changes end


END rtr_multi_trans_pkg;
/