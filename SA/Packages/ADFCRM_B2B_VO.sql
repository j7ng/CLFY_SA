CREATE OR REPLACE package sa.adfcrm_b2b_vo
as
    type b2b_orders_rec is record
    (   biz_objid               sa.x_biz_purch_hdr.objid%type,
        c_objid                 sa.table_contact.objid%type,
        c_x_cust_id             sa.table_contact.x_cust_id%type,
        b_c_orderid             sa.x_biz_purch_hdr.c_orderid%type,
        b_x_customer_firstname  sa.x_biz_purch_hdr.x_customer_firstname%type,
        b_x_customer_lastname   sa.x_biz_purch_hdr.x_customer_lastname%type,
        b_x_rqst_date           sa.x_biz_purch_hdr.x_rqst_date%type,
        b_x_customer_phone      sa.x_biz_purch_hdr.x_customer_phone%type,
        b_x_bill_address1       sa.x_biz_purch_hdr.x_bill_address1%type,
        b_x_bill_city           sa.x_biz_purch_hdr.x_bill_city%type,
        b_x_bill_state          sa.x_biz_purch_hdr.x_bill_state%type,
        b_x_bill_zip            sa.x_biz_purch_hdr.x_bill_zip%type,
        b_x_customer_email      sa.x_biz_purch_hdr.x_customer_email%type,
		b_x_esn                 sa.x_biz_purch_hdr.x_esn%type,
        b_x_merchant_ref_number sa.x_biz_purch_hdr.x_merchant_ref_number%type
    );

    type b2b_orders_tab is table of b2b_orders_rec;

  function b2b_orders (ip_email varchar2,ip_order_id varchar2)
  return b2b_orders_tab pipelined;

  procedure link_b2bcontact_to_order (
    ip_orderid        in varchar2,
    ip_cust_id        in varchar2,
    op_err_code        out varchar2,
    op_err_msg         out varchar2);

end adfcrm_b2b_vo;
/