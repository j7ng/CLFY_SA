CREATE OR REPLACE package body sa.adfcrm_cust_pymt_info is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_CUST_PYMT_INFO_PKB.sql,v $
--$Revision: 1.13 $
--$Author: mmunoz $
--$Date: 2017/03/16 20:57:12 $
--$ $Log: ADFCRM_CUST_PYMT_INFO_PKB.sql,v $
--$ Revision 1.13  2017/03/16 20:57:12  mmunoz
--$ CR4682 : function insert_cc_no_consent and delete_cc_no_consent are not longer needed
--$
--$ Revision 1.12  2017/02/13 22:22:02  mmunoz
--$ CR47567 ACH payments data fixes, uppercase for ip_aba_transit
--$
--$ Revision 1.11  2016/11/15 16:25:44  mmunoz
--$ CR45711  : Updated INSERT_ACH to check if the data already exists for that brand
--$
--$ Revision 1.10  2015/06/05 18:57:38  mmunoz
--$ CR34207 : Only break link between credit card and contact when the record was deleted from ADFCRM_CC_NO_CONSENT
--$
--$ Revision 1.9  2015/06/02 16:40:35  mmunoz
--$ CR34207 : Do not change the X_card_status to have it available when is added for second time.
--$
--$ Revision 1.8  2015/06/01 20:05:05  mmunoz
--$ CR34207	: fix for merge
--$
--$ Revision 1.7  2015/05/29 21:52:12  mmunoz
--$ CR34207	: Added contact_objid in new functions
--$
--$ Revision 1.6  2015/05/29 16:33:04  mmunoz
--$ CR34207 : remove association between credit card and contact. Fix in line 209
--$
--$ Revision 1.5  2015/05/29 16:22:24  mmunoz
--$ CR34207 : remove association between credit card and contact.
--$
--$ Revision 1.4  2015/05/28 21:56:01  mmunoz
--$ CR34207	TAS Consent to Save CC Info
--$
--$ Revision 1.3  2014/10/28 21:31:31  mmunoz
--$ CR31050	Migration of existing ACH accounts to DataPower Tokenization
--$
--$ Revision 1.2  2014/07/16 13:59:48  mmunoz
--$ Added commit and rollback
--$
--$ Revision 1.1  2014/07/11 18:31:35  mmunoz
--$ new functions insert_ach and update_ach
--$
--------------------------------------------------------------------------------------------

  function insert_ach (
		ip_bank_num varchar2,
		ip_customer_acct varchar2,
		ip_routing varchar2,
		ip_bank_name varchar2,
		ip_status varchar2,
		ip_customer_firstname varchar2,
		ip_customer_lastname varchar2,
		ip_customer_phone varchar2,
		ip_customer_email varchar2,
		ip_max_purch_amt varchar2,
		ip_changedby varchar2,
		ip_cc_comments varchar2,
		ip_bank_acct2contact varchar2,
		ip_bank_acct2address varchar2,
		ip_org_id varchar2,
		ip_aba_transit varchar2,
		ip_bank2cert varchar2,
		ip_customer_acct_key varchar2,
		ip_customer_acct_enc varchar2,
		ip_key_transport_algo varchar2,
		ip_algo varchar2
  ) return varchar2 is
	cursor check_acct_org(ip_customer_acct varchar2, ip_org_id varchar2) is
		select b.objid bank_objid
		from table_x_bank_account b,
			table_bus_org bo
		where b.x_customer_acct = ip_customer_acct
		and bo.org_id = ip_org_id
		and b.x_bank_account2bus_org = bo.objid;
	check_acct_org_rec check_acct_org%rowtype;

	l_bank_acnt_objid NUMBER := 0;
	v_cert number;
  begin
	--CR45711 check if the data already exists ans return the objid
	  open check_acct_org(ip_customer_acct, ip_org_id);
	  fetch check_acct_org into check_acct_org_rec;
	  if check_acct_org%found then
		close check_acct_org;
		return check_acct_org_rec.bank_objid;
	  end if;
	  close check_acct_org;

      -- PCI compliance begin
	  if ip_bank2cert is not null
	  then
	     begin
	        select objid
	        into v_cert
	        from x_cert
	        where x_cc_algo = ip_algo
	        and x_key_algo = ip_key_transport_algo
	        and x_cert = ip_bank2cert
	        and rownum < 2;
	     exception
	        when no_data_found then
	            v_cert := sa.seq_x_cert.nextval;
	            insert into x_cert(
	            objid,
	            x_cert,
	            x_key_algo,
	            x_cc_algo,
	            create_date
	            ) values(
	            v_cert,
	            ip_bank2cert,
	            ip_key_transport_algo,
	            ip_algo,
	            systimestamp
	            );
	     end;
	  end if;
	  -- PCI compliance end;

	  l_bank_acnt_objid := sa.sequ_x_bank_account.NEXTVAL;
	  INSERT
	  INTO table_x_bank_account
		(
		objid,
		x_bank_num,
		x_customer_acct,
		x_routing,
		x_bank_name,
		x_status,
		x_customer_firstname,
		x_customer_lastname,
		x_customer_phone,
		x_customer_email,
		x_max_purch_amt,
		x_original_insert_date,
		x_changedby,
		x_cc_comments,
		x_bank_acct2contact,
		x_bank_acct2address,
		x_bank_account2bus_org,
		x_aba_transit,
		bank2cert,
		x_customer_acct_key,
		x_customer_acct_enc
		)
		VALUES
		(
		l_bank_acnt_objid,
		ip_bank_num,
		ip_customer_acct,
		ip_routing,
		ip_bank_name,
		ip_status,
		ip_customer_firstname,
		ip_customer_lastname,
		ip_customer_phone,
		ip_customer_email,
		ip_max_purch_amt,
		sysdate,
		ip_changedby,
		ip_cc_comments,
		ip_bank_acct2contact,
		ip_bank_acct2address,
		(select objid from table_bus_org where s_org_id = ip_org_id),
		upper(ip_aba_transit),
		v_cert,
		ip_customer_acct_key,
		ip_customer_acct_enc
		);
	  commit;
	  return l_bank_acnt_objid;
	EXCEPTION
	WHEN OTHERS THEN
	  rollback;
	  RETURN SQLCODE;
  end insert_ach;

------------------------------------------------------------------------------------
  function update_ach (
		ip_bank_acnt_objid varchar2,
		ip_bank_num varchar2,
		ip_customer_firstname varchar2,
		ip_customer_lastname varchar2,
		ip_customer_phone varchar2,
		ip_customer_email varchar2,
		ip_changedby varchar2,
		ip_cc_comments varchar2,
		ip_aba_transit varchar2
  ) return varchar2 is
  begin
        UPDATE table_x_bank_account
        SET
			x_bank_num = ip_bank_num,
			x_customer_firstname = ip_customer_firstname,
			x_customer_lastname    = ip_customer_lastname,
			x_customer_phone = ip_customer_phone,
			x_customer_email       = x_customer_email,
			x_changedby = ip_changedby,
			x_cc_comments = ip_cc_comments|| ' ' ||to_char(sysdate,'yyyy/mm/dd hh24:mi:ss'),
			x_aba_transit = upper(ip_aba_transit)
        WHERE objid      = ip_bank_acnt_objid;
		commit;
		return '0';
      EXCEPTION
      WHEN OTHERS THEN
	    rollback;
        RETURN sqlcode;
  end update_ach;

------------------------------------------------------------------------------------
--CR34207 new function insert_cc_no_consent
  function insert_cc_no_consent (
    ip_cc_objid number,
    ip_web_user_objid number,
    ip_contact_objid number
  )
  return varchar2 is
  begin
     null; --CR4682 TAS Credit Card Modifications  Commented this code
     /**
     merge into SA.ADFCRM_CC_NO_CONSENT cc
     using (select ip_cc_objid ip_cc_objid,
                   ip_web_user_objid ip_web_user_objid,
                   ip_contact_objid ip_contact_objid
            from dual) a
     on (cc.cc_objid = a.ip_cc_objid and cc.web_user_objid = a.ip_web_user_objid and cc.contact_objid = a.ip_contact_objid)
     when not matched then
         insert (cc_objid,web_user_objid,contact_objid)
         values (a.ip_cc_objid,a.ip_web_user_objid,a.ip_contact_objid);
     commit;
     ***/
     return '0';
  EXCEPTION
      WHEN OTHERS THEN
        rollback;
        RETURN sqlcode||' '||sqlerrm;
  end insert_cc_no_consent;
------------------------------------------------------------------------------------
--CR34207 new function delete_cc_no_consent
  function delete_cc_no_consent (
    ip_cc_objid number,
    ip_web_user_objid number,
    ip_contact_objid number
  )
  return varchar2 is
    v_delete_no_consent number;
  begin
     null; --CR4682 TAS Credit Card Modifications  Comment this code
     /***
     v_delete_no_consent := 0;
     if ip_web_user_objid is not null
     then
         delete from SA.ADFCRM_CC_NO_CONSENT
         where web_user_objid = ip_web_user_objid
         and cc_objid = ip_cc_objid;

         v_delete_no_consent := v_delete_no_consent + sql%rowcount;

         --Only delete from Mtm_Contact46_X_Credit_Card3 when the record was deleted from ADFCRM_CC_NO_CONSENT
         if (v_delete_no_consent > 0) then
             delete from Mtm_Contact46_X_Credit_Card3 mtm
             where Mtm.Mtm_Credit_Card2contact    = ip_cc_objid
             and mtm.Mtm_Contact2x_Credit_Card =
                 (select web_user2contact
                 from table_web_user
                 where objid = ip_web_user_objid);
        end if;
     end if;
     if ip_contact_objid is not null
     then
         delete from SA.ADFCRM_CC_NO_CONSENT
         where contact_objid = ip_contact_objid
         and cc_objid = ip_cc_objid;

         v_delete_no_consent := v_delete_no_consent + sql%rowcount;
         --Only delete from Mtm_Contact46_X_Credit_Card3 when the record was deleted from ADFCRM_CC_NO_CONSENT
         if (v_delete_no_consent> 0) then
             delete from Mtm_Contact46_X_Credit_Card3 mtm
             where Mtm.Mtm_Credit_Card2contact    = ip_cc_objid
             and mtm.Mtm_Contact2x_Credit_Card = ip_contact_objid;
         end if;
     end if;

     --Only update when the record was deleted from ADFCRM_CC_NO_CONSENT
     --and it is the same contact objid
     if (v_delete_no_consent > 0) then
        update Table_X_Credit_Card Cc
        set cc.x_credit_card2contact = null
             --Cc.X_card_status = 'INACTIVE' --****Do not change the X_card_status to have it available when is added for second time.
        where cc.objid = ip_cc_objid
        and cc.x_credit_card2contact = ip_contact_objid;
     end if;

     commit;
     ***/
     return '0';
  EXCEPTION
      WHEN OTHERS THEN
        rollback;
        RETURN sqlcode||' '||sqlerrm;
  end delete_cc_no_consent;

end adfcrm_cust_pymt_info;
/