CREATE OR REPLACE PACKAGE BODY sa."TFSOA_GET_SERVICES_PKG" AS

  procedure GET_SMS_DETAILS  (
                      p_esn                         IN       VARCHAR2,
                      p_mode                        IN       VARCHAR2,
                      p_text                        IN       VARCHAR2,
                      p_ota_trans2x_ota_mrkt_info   IN       VARCHAR2 DEFAULT NULL,
                      p_ota_trans_reason            IN       VARCHAR2 DEFAULT NULL,
                      p_x_ota_trans2x_call_trans    IN       NUMBER DEFAULT NULL,
                      p_cbo_error_message           IN       VARCHAR2  DEFAULT NULL,      -- error message passed from CBO
                      p_mobile365_id                IN       VARCHAR2 DEFAULT NULL,      --OTA Enhancements
                      p_dynamic_params              IN       TF_DYNAMICPARAM_DATATAB,
                      p_min                         out      varchar2,
                      p_dll                         out      varchar2,
                      p_psms_message                OUT      VARCHAR2,
                      p_technology                  OUT      varchar2,
                      p_sequence                    out      NUMBER,
                      p_ota_trans_objid             OUT      NUMBER,
                      p_out_text                        OUT     varchar2,
                      p_error                       out      varchar2)  AS

 l_text             varchar2(4000)        := p_text;
 l_start_of         number                := instr(p_text,'%',1,1);
 l_end_of           number                := instr(p_text,'%',1,2);
 l_sub_value        varchar2(4000);
 v_ota_trans_objid  NUMBER;
 v_technology       varchar2(255);

-- added to support pre-dll call
 v_P_Transid_In Number;
 v_P_Int_Dll_To_Use_In Number;
 v_p_x_carrier_id_in Number;


      cursor min_curs is
    SELECT x_min
      FROM table_site_part
     WHERE part_status = 'Active'
       AND x_service_id = p_esn;
  min_rec min_curs%rowtype;
  cursor dll_curs is
    SELECT pn.x_dll,
           pn.x_ota_allowed
      FROM table_part_num pn,
           table_mod_level ml,
           table_part_inst pi,
           table_x_code_table ct
      WHERE pi.part_serial_no = p_esn
        AND pi.x_domain = 'PHONES'
        AND pi.x_part_inst_status = ct.x_code_number
        AND ct.x_code_name = 'ACTIVE'
        AND pi.n_part_inst2part_mod = ml.objid
        AND pn.objid = ml.part_info2part_num;
  dll_rec dll_curs%rowtype;


  TYPE ref_cur_type IS REF CURSOR;
  l_sub_rc  ref_cur_type;
  type l_sub_type is record( PARAMNAME                    VARCHAR2 (2000),
                             PARAMVALUE                   VARCHAR2 (2000));
  l_sub_rec l_sub_type;

begin


  --insert into tf_soa_debug (name, value) values('begin','step1');


  l_sub_value := substr(p_text,l_start_of+1,(l_end_of-l_start_of)-1);

  open l_sub_rc for
    select *
      from table (cast(p_dynamic_params as  TF_DYNAMICPARAM_DATATAB));
    loop
      fetch l_sub_rc into l_sub_rec;
      exit when l_sub_rc%notfound;
      if l_sub_rec.paramname = l_sub_value then
	l_text := replace(p_text,'%'||l_sub_value||'%',l_sub_rec.paramvalue);
      end if;
    end loop;
    if instr(l_text,'%',1,1) != 0 then
      l_text := replace(p_text,'%'||l_sub_value||'%','');
      p_error := 'Sub value not found';
    end if;

    -- assigning l_text as out via p_text (RM: 2011.02.21)
    p_out_text := l_text;


  open min_curs;
    fetch min_curs into min_rec;
    p_min := min_rec.x_min;
  close min_curs;
  open dll_curs;
    fetch dll_curs into dll_rec;
    p_dll := dll_rec.x_dll;
  close dll_curs;
-- P_psms_message retrive 11/1/2010

BEGIN
  SELECT pi.X_SEQUENCE,
                DECODE (pn.x_technology,
                        'ANALOG', '0',
                        'CDMA', '2',
                        'TDMA', '1',
                        'GSM', '3'
                       ) technology,
  pn.x_technology
   INTO p_sequence, p_technology, v_technology
  FROM table_part_inst pi, table_mod_level ml, table_part_num pn
  WHERE pi.x_domain = 'PHONES'
  --AND pi.x_part_inst_status ||'' = '52'
  AND pi.n_part_inst2part_mod = ml.objid
  AND ml.part_info2part_num = pn.objid
  AND pi.part_serial_no = p_esn;


EXCEPTION
  WHEN others then
       p_psms_message := null;
END;

-- Uncomment for populate  p_psms_message variable
/*
 BEGIN
  sa.OTA_MRKT_INFO_PKG.send_psms (
                p_esn,
                p_min,
                p_mode,
                l_text,
                p_dll,
                p_psms_message,
                p_ota_trans2x_ota_mrkt_info,
                p_ota_trans_reason,
                p_x_ota_trans2x_call_trans   ,
                p_cbo_error_message,
                p_mobile365_id,
                p_ota_trans_objid);

 exception when others then
     p_error := sqlerrm;
  END;
*/
-- added to coreect errors due to split of DLL functions
 BEGIN
      sa.OTA_MRKT_INFO_PKG.send_psms_pre_dll (
      p_esn => p_esn, --                        IN       VARCHAR2,
      p_min => p_min, --                         IN       VARCHAR2,
      p_mode => p_mode, --                        IN       VARCHAR2,
      p_text => l_text, --                       IN       VARCHAR2,
      p_int_dll_to_use => p_dll, --             IN       NUMBER,
      p_psms_message => p_psms_message, --                OUT      VARCHAR2,
      p_ota_trans2x_ota_mrkt_info => p_ota_trans2x_ota_mrkt_info, --  IN       VARCHAR2 DEFAULT NULL,
      p_ota_trans_reason => p_ota_trans_reason, --           IN       VARCHAR2 DEFAULT NULL,
      P_X_Ota_Trans2x_Call_Trans => P_X_Ota_Trans2x_Call_Trans, --   In       Number Default Null,
      P_Cbo_Error_Message => P_Cbo_Error_Message, --          In       Varchar2   Default Null,  -- error message passed from CBO
      P_Mobile365_Id => P_Mobile365_Id, --               In       Varchar2 Default Null,
      P_Ota_Trans_Objid => v_ota_trans_objid, --            Out      Number,        -- 06/27/05 CR4169
      --OUT
      P_Sequence_In => p_sequence, --                Out     Number,
      P_Technology_In => p_technology, --              Out     Number,
      P_Transid_In => v_P_Transid_In, --                 Out     Number,
      P_Int_Dll_To_Use_In => v_P_Int_Dll_To_Use_In, --          Out     Number,
      p_x_carrier_id_in => v_p_x_carrier_id_in      --        OUT     Number
  );
 exception when others then
     p_error := sqlerrm;
  END;

  p_ota_trans_objid := v_P_Transid_In;


  END GET_SMS_DETAILS;

  procedure GET_CUST_DETAILS(p_webuserID    in number,
                                             p_paymentsrc   in number,
                                             p_type         in varchar2,
                                             p_cust_detail out CUSTOMER_DETAILS ) AS

l_email        CUSTOMER_EMAILTYPE;
  l_addrtype      CUSTOMER_ADDRESSTYPE;
  l_addr          CUSTOMER_ADDRESSTYPE;
  l_addr_all      CUSTOMER_ADDRESSTAB;
  l_sms      CUSTOMER_SMSTYPE;
  l_cc       CUSTOMER_CCTYPE;
  cursor web_curs is
    select web.web_user2contact contact_objid,
           web.login_name,
           ps.PYMT_SRC2X_CREDIT_CARD,
           ps.X_BILLING_EMAIL
      from
           x_payment_source ps,
           table_web_user web
    where ps.PYMT_SRC2WEB_USER(+) = web.objid
      and web.objid = p_webuserid;
  cursor web2_curs is
    select web.web_user2contact contact_objid,
           web.login_name,
           ps.PYMT_SRC2X_CREDIT_CARD,
           ps.X_BILLING_EMAIL
      from
           table_web_user web,
           x_payment_source ps
    where web.objid = ps.PYMT_SRC2WEB_USER
      and ps.objid = p_paymentsrc;
  web_rec web_curs%rowtype;
  cursor customer_curs(c_contact_objid in number) is
    select c.last_name,
           c.first_name,
           pi.part_serial_no esn,
           pi.n_part_inst2part_mod,
           s.CUST_PRIMADDR2ADDRESS,
           s.CUST_BILLADDR2ADDRESS,
           s.CUST_SHIPADDR2ADDRESS,
           sp.x_min min
     from
          table_contact c,
          table_contact_role cr,
          table_site s,
          table_site_part sp,
          table_part_inst pi,
          table_x_contact_part_inst conpi
    where 1=1
      and c.objid = cr.contact_role2contact
      and cr.contact_role2site = s.objid
      and s.objid = sp.site_part2site
      and sp.part_status||'' = 'Active'
      and sp.x_service_id = pi.part_serial_no
      AND pi.x_part_inst_status||'' = '52'
      and pi.objid = conpi.x_contact_part_inst2part_inst
      AND conpi.x_is_default = 1
      AND conpi.x_contact_part_inst2contact = c_contact_objid;
  customer_rec customer_curs%rowtype;
  cursor address_curs(c_addr_objid in number,
                      c_addr_type in varchar2) is
    select customer_addresstype(c_addr_type,
                                addr.ADDRESS,
                                addr.ADDRESS_2,
                                null,
                                addr.CITY,
                                addr.STATE,
                                addr.ZIPCODE,
                                (select cnt.name
                                   from table_country cnt
                                  where cnt.objid = addr.ADDRESS2COUNTRY)
                                )
                          from table_address addr
                         where addr.objid = c_addr_objid;
  cursor cc_curs(c_cc_objid in number) is
    select CUSTOMER_CCTYPE(X_CUSTOMER_CC_NUMBER,
                           null,
                           X_CUSTOMER_CC_EXPMO||'/'||X_CUSTOMER_CC_EXPYR,
                           null)
      from table_x_credit_card cc
     where cc.X_CREDIT_CARD2CONTACT = c_cc_objid;
  cursor sms_curs(c_min in varchar2,
                  c_mod_level_objid number) is
    select CUSTOMER_SMSTYPE(pn.x_dll,
                            c_min,
                            null)
      from
           table_part_num pn,
           table_mod_level ml
     where pn.objid = ml.part_info2part_num
       AND ml.objid = c_mod_level_objid;
begin
  if NVL(p_WebUserID,0) > 0 then
    open web_curs;
      fetch web_curs into web_rec;
      if web_curs%found then
	if p_type in ('ALL', 'EMAIL', 'email') then
          l_email := customer_emailtype(web_rec.login_name,web_rec.x_billing_email);
        end if;
        dbms_output.put_line('web_rec.contact_objid:'||web_rec.contact_objid);
      end if;
    close web_curs;
  elsif nvl(p_paymentsrc,0) > 0  then
    open web2_curs;
      fetch web2_curs into web_rec;
      if web2_curs%found then
	if p_type in ('ALL', 'EMAIL', 'email') then
          l_email := customer_emailtype(web_rec.login_name,web_rec.x_billing_email);
        end if;
        dbms_output.put_line('web_rec.contact_objid:'||web_rec.contact_objid);
      end if;
    close web2_curs;
  else return;
  end if;
  open customer_curs(web_rec.contact_objid);
    fetch customer_curs into customer_rec;
    if customer_curs%found then
      dbms_output.put_line('customer_rec.last_name:'||customer_rec.last_name);
      dbms_output.put_line('customer_rec.first_name:'||customer_rec.first_name);
    end if;
  close customer_curs;
  dbms_output.put_line('p:'||customer_rec.CUST_PRIMADDR2ADDRESS);
   Dbms_Output.Put_Line('b:'||Customer_Rec.Cust_Billaddr2address);
   Dbms_Output.Put_Line('s:'|| Customer_Rec.Cust_Shipaddr2address);
  l_addr_all := customer_addresstab(l_addrtype);
  if customer_rec.cust_primaddr2address is not null then
    open address_curs(customer_rec.CUST_PRIMADDR2ADDRESS,
                     'PRIMARY');
      fetch address_curs into l_addr;
      If Address_Curs%Found Then
	l_addr_all(l_addr_all.last) := l_addr;
	l_addr_all.extend;
      end if;
    close address_curs;
  end if;
  if customer_rec.CUST_BILLADDR2ADDRESS is not null then
    open address_curs(customer_rec.CUST_BILLADDR2ADDRESS,
                     'BILLING');
      fetch address_curs into l_addr;
      if address_curs%found then
	l_addr_all(l_addr_all.last) := l_addr;
	l_addr_all.extend;
      end if;
    close address_curs;
  end if;
  if customer_rec.CUST_SHIPADDR2ADDRESS is not null then
    open address_curs(customer_rec.CUST_SHIPADDR2ADDRESS,
                     'SHIPPING');
      fetch address_curs into l_addr;
      if address_curs%found then
	l_addr_all(l_addr_all.last) := l_addr;
      end if;
    close address_curs;
  end if;
  if p_type in('ALL', 'CC') then
    open cc_curs(web_rec.PYMT_SRC2X_CREDIT_CARD);
      fetch cc_curs into l_cc;
    close cc_curs;
  end if;
  if p_type in ('ALL', 'SMS','sms') then
    open sms_curs(customer_rec.min,
                  customer_rec.n_part_inst2part_mod);
      fetch sms_curs into l_sms;
    close sms_curs;
  end if;
  p_cust_detail := customer_details(customer_rec.last_name,
	                            customer_rec.first_name,
				    customer_rec.esn,
				    l_addr_all,
                                    l_email,
                                    l_sms,
                                    l_cc);
  END GET_CUST_DETAILS;

END TFSOA_GET_SERVICES_PKG;
/