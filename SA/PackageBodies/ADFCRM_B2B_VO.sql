CREATE OR REPLACE package body sa.adfcrm_b2b_vo
as
  ------------------------------------------------------------------------------
  function b2b_orders (ip_email varchar2,ip_order_id varchar2)
  return b2b_orders_tab pipelined
  is
    b2b_orders_rslt b2b_orders_rec;
    v_action varchar2(100) := 'ACTION IS EMPTY';
  begin
    b2b_orders_rslt.biz_objid                := null;
    b2b_orders_rslt.c_objid                  := null;
    b2b_orders_rslt.c_x_cust_id              := null;
    b2b_orders_rslt.b_c_orderid              := null;
    b2b_orders_rslt.b_x_customer_firstname   := null;
    b2b_orders_rslt.b_x_customer_lastname    := null;
    b2b_orders_rslt.b_x_rqst_date            := null;
    b2b_orders_rslt.b_x_customer_phone       := null;
    b2b_orders_rslt.b_x_bill_address1        := null;
    b2b_orders_rslt.b_x_bill_city            := null;
    b2b_orders_rslt.b_x_bill_state           := null;
    b2b_orders_rslt.b_x_bill_zip             := null;
    b2b_orders_rslt.b_x_customer_email       := null;
	b2b_orders_rslt.b_x_esn                  := null;
    b2b_orders_rslt.b_x_merchant_ref_number  := null;

    -- orderId or email
    if ip_order_id is not null then
      v_action := 'CHECK BASED ON ORDER ID ('||ip_order_id||')';
      for i in (select  biz.objid bizobjid,
                        c.objid,
                        c.x_cust_id,
                        biz.c_orderid,
                        biz.x_customer_firstname,
                        biz.x_customer_lastname,
                        biz.x_rqst_date,
                        biz.x_customer_phone,
                        biz.x_bill_address1,
                        biz.x_bill_city,
                        biz.x_bill_state,
                        biz.x_bill_zip,
                        biz.x_customer_email,
						biz.x_esn,
                        biz.x_merchant_ref_number
                from    x_biz_purch_hdr biz LEFT JOIN
                        table_web_user w ON biz.prog_hdr2web_user = w.objid LEFT JOIN
                        table_contact c ON w.web_user2contact = c.objid
                where   biz.x_rqst_type like '%PURCH%'
                and    (biz.x_payment_type = 'SETTLEMENT' or
                        biz.x_payment_type = 'CHARGE')
                and    (biz.c_orderid = ip_order_id)
        )
      loop
        b2b_orders_rslt.biz_objid                := i.bizobjid;
        b2b_orders_rslt.c_objid                  := i.objid;
        b2b_orders_rslt.c_x_cust_id              := i.x_cust_id;
        b2b_orders_rslt.b_c_orderid              := i.c_orderid;
        b2b_orders_rslt.b_x_customer_firstname   := i.x_customer_firstname;
        b2b_orders_rslt.b_x_customer_lastname    := i.x_customer_lastname;
        b2b_orders_rslt.b_x_rqst_date            := i.x_rqst_date;
        b2b_orders_rslt.b_x_customer_phone       := i.x_customer_phone;
        b2b_orders_rslt.b_x_bill_address1        := i.x_bill_address1;
        b2b_orders_rslt.b_x_bill_city            := i.x_bill_city;
        b2b_orders_rslt.b_x_bill_state           := i.x_bill_state;
        b2b_orders_rslt.b_x_bill_zip             := i.x_bill_zip;
        b2b_orders_rslt.b_x_customer_email       := i.x_customer_email;
		b2b_orders_rslt.b_x_esn                  := i.x_esn;
        b2b_orders_rslt.b_x_merchant_ref_number  := i.x_merchant_ref_number;
        pipe row (b2b_orders_rslt);
      end loop;
    end if;

    if ip_email is not null then
      v_action := 'CHECK BASED ON EMAIL ('||ip_email||')';
      for i in (select  biz.objid bizobjid,
                        c.objid,
                        c.x_cust_id,
                        biz.c_orderid,
                        biz.x_customer_firstname,
                        biz.x_customer_lastname,
                        biz.x_rqst_date,
                        biz.x_customer_phone,
                        biz.x_bill_address1,
                        biz.x_bill_city,
                        biz.x_bill_state,
                        biz.x_bill_zip,
                        biz.x_customer_email,
						biz.x_esn,
                        biz.x_merchant_ref_number
                from    x_biz_purch_hdr biz LEFT JOIN
                        table_web_user w ON biz.prog_hdr2web_user = w.objid LEFT JOIN
                        table_contact c ON w.web_user2contact = c.objid
                where   biz.x_rqst_type like '%PURCH%'
                and    (biz.x_payment_type = 'SETTLEMENT' or
                        biz.x_payment_type = 'CHARGE')
                and     (biz.x_customer_email in (upper(ip_email), lower(ip_email),ip_email))
        )
      loop
        b2b_orders_rslt.biz_objid                := i.bizobjid;
        b2b_orders_rslt.c_objid                  := i.objid;
        b2b_orders_rslt.c_x_cust_id              := i.x_cust_id;
        b2b_orders_rslt.b_c_orderid              := i.c_orderid;
        b2b_orders_rslt.b_x_customer_firstname   := i.x_customer_firstname;
        b2b_orders_rslt.b_x_customer_lastname    := i.x_customer_lastname;
        b2b_orders_rslt.b_x_rqst_date            := i.x_rqst_date;
        b2b_orders_rslt.b_x_customer_phone       := i.x_customer_phone;
        b2b_orders_rslt.b_x_bill_address1        := i.x_bill_address1;
        b2b_orders_rslt.b_x_bill_city            := i.x_bill_city;
        b2b_orders_rslt.b_x_bill_state           := i.x_bill_state;
        b2b_orders_rslt.b_x_bill_zip             := i.x_bill_zip;
        b2b_orders_rslt.b_x_customer_email       := i.x_customer_email;
		b2b_orders_rslt.b_x_esn                  := i.x_esn;
        b2b_orders_rslt.b_x_merchant_ref_number  := i.x_merchant_ref_number;
        pipe row (b2b_orders_rslt);
      end loop;
    end if;

    dbms_output.put_line(v_action);

  end b2b_orders;

  procedure link_b2bcontact_to_order (
    ip_orderid        in varchar2,
    ip_cust_id        in varchar2,
    op_err_code        out varchar2,
    op_err_msg         out varchar2) is
    web_user_objid table_web_user.objid%type;
    table_cntid table_contact.objid%type;
  begin
    if ip_orderid is null or ip_cust_id is null then
        op_err_code := -700;
        op_err_msg := 'ERROR-00700 ADFCRM_R2B_VO.link_b2bcontact_to_order cust_id or orderid is missing';
        return;  --Procedure stops here
    end if;
   /*---------------------------------------------------------------------*/
   /*  Get objid of table_web_user from table_contact customer id                                     */
   /*---------------------------------------------------------------------*/
    select objid   --Get OBJID from table_contact ofrom customerId.
    into   table_cntid
    from   table_contact
    where  x_cust_id = ip_cust_id;

    select objid   --Get Objid from table_web_user from objid of table_contact.
    into   web_user_objid
    from   table_web_user
    where  web_user2contact = table_cntid;

    begin
        /*---------------------------------------------------------------------*/
        /*   Link contact to Order                                             */
        /*---------------------------------------------------------------------*/
        UPDATE x_biz_purch_hdr set PROG_HDR2WEB_USER = web_user_objid where objid=ip_orderid;

        op_err_code := 0;
        op_err_msg := 'Contact linked to order, Successfully';
    exception
    when others then
        op_err_code := -710;
        op_err_msg := 'ERROR-00710 ADFCRM_B2B_VO.link_b2bcontact_to_order '||sqlcode;
    end;
  end link_b2bcontact_to_order;
  ------------------------------------------------------------------------------
end adfcrm_b2b_vo;
/