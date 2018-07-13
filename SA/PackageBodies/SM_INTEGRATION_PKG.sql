CREATE OR REPLACE PACKAGE BODY sa.SM_Integration_PKG AS
/*******************************************************************************************************
  * --$RCSfile: FB_INTEGRATION_INFO_PKG_BODY.sql,v $
  --$Revision: 1.17 $
  --$Author: bkayal $
  --$Date: 2015/01/16 13:38:54 $
  --$ $Log: FB_INTEGRATION_INFO_PKG_BODY.sql,v $
  --$ Revision 1.17  2015/01/16 13:38:54  bkayal
  --$ CR32075 : Change SMUID length value from 50 to 100
  --$
  --$ Revision 1.16  2015/01/15 16:35:20  bkayal
  --$ CR32075:  Updated for Few link/unlink scenarios of facebook.
  --$
  --$ Revision 1.15  2015/01/13 14:23:42  bkayal
  --$ Update for Businness manager implementation (each business manager per brand)
  --$
  --$ Revision 1.14  2014/12/22 13:21:53  bkayal
  --$ CR32075 Changed logic for One Usecase
  --$
  --$ Revision 1.13  2014/12/16 16:51:56  bkayal
  --$ Modified for CR32075(Business manager API implementation for facebook)
  --$
  --$ Revision 1.12  2014/11/26 20:48:10  bkayal
  --$ Changes in CreateAndLink Procedure  for TAS/Portal  changes
  --$
  --$ Revision 1.11  2014/11/20 18:43:16  bkayal
  --$ Update UnlinkSMaccount proc for Portal/TAS Requierment
  --$
  --$ Revision 1.10  2014/11/10 14:17:10  bkayal
  --$ Removed AddSocialMetricLogs procedure
  --$
  --$ Revision 1.9  2014/11/04 16:42:02  bkayal
  --$ Add social mediaTable
  --$
  --$ Revision 1.8  2014/11/04 14:20:02  bkayal
  --$ Removed AddSocialMetricLogs
  --$
  --$ Revision 1.7  2014/11/03 13:47:48  bkayal
  --$ Update createAndLinkSMAccount procedure
  --$
  --$ Revision 1.6  2014/10/21 15:07:28  bkayal
  --$ removed one clause form createAndLinkSMAccount () operation
  --$
  --$ Revision 1.5  2014/09/22 12:50:39  bkayal
  --$ Comments Added as per Db instructions
  --$
  * Description: This package includes the five procedures
  * getMyAccountBySM, updateSMAccount, createAndLinkSMAccount, updatePreferredEmail,unlinkSMAccount,fetchLinkageAndInterestStatus,addSocialMediaMetricLogs Services.
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
procedure getMyAccountBySM (
        in_SMUIDList in varchar2
	  , in_SMEID in NUMBER
	  , in_Token_For_Business varchar2
	  , out_webUser out sys_refcursor

  )is
    lv_objid    sa.X_SME_2MOBILEUSER.X_SME_MOBILEUSER2WEBUSER%type;
	lv_web_user2contact sa.table_web_user.web_user2contact%type;
	lv_web_user_login_name sa.table_web_user.login_name%type;
    lv_web_bus_ac_id sa.X_BUSINESS_ACCOUNTS.ACCOUNT_ID%type;
	lv_web__bus_ac_name sa.X_BUSINESS_ACCOUNTS.NAME%type;
	interest_share_status sa.X_SOCIAL_MEDIA_PROFILE.X_Interest_Share%type;
	lv_SMUID sa.X_SME_2MOBILEUSER.X_SOCIAL_MEDIA_UID%type;
	lv_link_cnt NUMBER;
	LV_TEST_CUR SYS_REFCURSOR;
  begin

    DBMS_OUTPUT.PUT_LINE('in_Token_For_Business = '||in_Token_For_Business);
	DBMS_OUTPUT.PUT_LINE('in_SMUIDList = '||in_SMUIDList);
	--Check if the linkage exists for Token_for_business

	select count(1) into lv_link_cnt
	from sa.X_SME_2MOBILEUSER
	where X_Token_For_Business = in_Token_For_Business
	and X_status_desc = 'Linked'
	and X_status = 1;

	DBMS_OUTPUT.PUT_LINE('1st --lv_link_cnt = '||lv_link_cnt);

	-- If there is not linkage against the Token_for_business
	-- Check if there is linkage against the SMUIDList associated with the Token_for_business
	IF lv_link_cnt = 0 THEN

		select count(1) into lv_link_cnt
		from sa.X_SME_2MOBILEUSER
		where X_SOCIAL_MEDIA_UID in (
										select regexp_substr(in_SMUIDList,'[^,]+', 1, level) from dual
										 connect by regexp_substr(in_SMUIDList, '[^,]+', 1, level) is not null
									 )
		and X_status_desc = 'Linked'
		and X_status = 1;

		DBMS_OUTPUT.PUT_LINE('2nd --lv_link_cnt = '||lv_link_cnt);

	END IF;

	IF lv_link_cnt = 0 THEN

		-- Returning a NULL cursor for no linkage
		open out_webuser   for
		select null web_user_objid
			   ,null contact_objid
			   ,null FIRST_NAME
			   ,null LAST_NAME
			   ,null E_MAIL
			   ,null IS_BUS_AC
			   ,null BUS_AC_ID
			   ,null BUS_AC_NM
			   ,null interest_share_status
		from dual;

	ELSE

		select distinct X_SME_MOBILEUSER2WEBUSER into lv_objid
		from sa.X_SME_2MOBILEUSER
		where X_SOCIAL_MEDIA_UID in (
										select regexp_substr(in_SMUIDList,'[^,]+', 1, level) from dual
										 connect by regexp_substr(in_SMUIDList, '[^,]+', 1, level) is not null
									 )
		and X_status_desc = 'Linked'
		and X_status = 1;

		FOR LV_TEST_CUR IN (select regexp_substr(in_SMUIDList,'[^,]+', 1, level) smuId from dual
	                       connect by regexp_substr(in_SMUIDList, '[^,]+', 1, level) is not null)
		LOOP
			MERGE INTO sa.X_SME_2MOBILEUSER b
			USING (
					SELECT LV_TEST_CUR.smuId smuId FROM dual
				  ) a
			ON (b.X_SOCIAL_MEDIA_UID = a.smuId)
			WHEN MATCHED THEN
			  UPDATE SET b.X_Token_For_Business = in_Token_For_Business
			            ,b.X_LastUpdate = sysdate
			WHEN NOT MATCHED THEN
			  Insert (X_CREATEDATE
						,X_LASTUPDATE
						,X_SME_MOBILEUSER2WEBUSER
						,X_SME_ID
						,X_SOCIAL_MEDIA_UID
						,X_STATUS
						,X_STATUS_DESC
						,X_Token_For_Business)
			  values (sysdate, null, lv_objid, in_SMEID, smuId, 1, 'Linked',in_Token_For_Business);


			MERGE INTO sa.X_SOCIAL_MEDIA_PROFILE b
			USING (
					SELECT LV_TEST_CUR.smuId smuId FROM dual
				  ) a
			ON (b.X_SOCIAL_MEDIA_UID = a.smuId)
			WHEN MATCHED THEN
			  UPDATE SET b.X_LASTUPDATEDATE = sysdate
			WHEN NOT MATCHED THEN
			  Insert (   X_SME_ID
						,X_SOCIAL_MEDIA_UID
						,X_SME_MOBILEUSER2WEBUSER
						,X_CREATEDATE)
			  values (in_SMEID, smuId, lv_objid, sysdate);

		END LOOP;
		commit;

		select web_user2contact
               ,login_name
		 into lv_web_user2contact
               ,lv_web_user_login_name
		from sa.table_web_user
		where objid = lv_objid;


		select nvl(X_Interest_Share , 'Disabled') into interest_share_status
			from sa.X_SOCIAL_MEDIA_PROFILE
		where X_SOCIAL_MEDIA_UID in (select X_SOCIAL_MEDIA_uid
										from  sa.X_SME_2MOBILEUSER
									 where X_SME_MOBILEUSER2WEBUSER= lv_objid
									 and X_status_desc = 'Linked'
									 and X_status = 1
									 and X_SME_ID = in_SMEID
									 and rownum=1);


		/*
		SELECT X_BUSINESS_ACCOUNTS.ACCOUNT_ID
			  ,X_BUSINESS_ACCOUNTS.NAME
		into  lv_web_bus_ac_id
			 ,lv_web__bus_ac_name
		FROM  SA.TABLE_CONTACT  , SA.X_BUSINESS_ACCOUNTS
		WHERE TABLE_CONTACT.objid =  X_BUSINESS_ACCOUNTS.BUS_PRIMARY2CONTACT
		AND  TABLE_CONTACT.objid = lv_web_user2contact;
		*/
		open out_webuser   for
		select lv_objid web_user_objid
			   ,lv_web_user2contact contact_objid
			   ,FIRST_NAME
			   ,LAST_NAME
			   ,lv_web_user_login_name E_MAIL
			   ,null IS_BUS_AC
			   ,123 BUS_AC_ID
			   ,'Bus A/C Name' BUS_AC_NM
			   ,interest_share_status interest_share_status
		from sa.TABLE_CONTACT
		 where objid = lv_web_user2contact;
	END IF;


  exception
        when others then
          DBMS_OUTPUT.PUT_LINE('error in getMyAccountBySM..ERR= '||sqlerrm);
  end getMyAccountBySM ;

  procedure updateSMAccount (
        in_SMUIDList in varchar2
	  , in_Token_For_Business varchar2
      , in_loginName in varchar2
      , in_firstName in varchar2
      , in_lastName in varchar2
      , in_link  in varchar2
      , in_userName in varchar2
      , in_gender in varchar2
      , in_locale in varchar2
      , in_ageRange in varchar2
      , in_email in varchar2
      , in_friendList in varchar2
	  , in_nonPublicList in varchar2
      , out_result out NUMBER
  ) is

  begin
      begin
        update sa.X_SOCIAL_MEDIA_PROFILE
        set
          X_UNAME              = in_loginName
        , X_FIRST_NAME         = in_firstName
        , X_LAST_NAME          = in_lastName
        , X_ULINK              = in_link
        , X_USERNAME           = in_loginName
        , X_GENDER             = in_gender
        , X_LOCALE             = in_locale
        , X_AGE_RANGE          = in_ageRange
        , X_EMAIL              = in_email
        , X_FRIEND_LIST_NODE   = in_friendList
        , X_LASTUPDATEDATE     = sysdate
		, X_NONPUBLICATTRIBUTE = in_nonPublicList

        WHERE X_SOCIAL_MEDIA_UID in (
										select regexp_substr(in_SMUIDList,'[^,]+', 1, level) from dual
										connect by regexp_substr(in_SMUIDList, '[^,]+', 1, level) is not null
									);

		out_result := sql%rowcount;

		commit;

		exception
        when others then
          DBMS_OUTPUT.PUT_LINE('error in  updateSMAccount..ERR= '||sqlerrm);
          out_result := -1;
      end;
  end updateSMAccount;

  procedure createAndLinkSMAccount (
        in_SMUIDList in varchar2
	  , in_Token_For_Business varchar2
	  , in_SMEId in number
      , in_loginName in varchar2
      , in_firstName in varchar2
      , in_lastName in varchar2
      , in_link  in varchar2
      , in_userName in varchar2
      , in_gender in varchar2
      , in_locale in varchar2
      , in_ageRange in varchar2
      , in_email in varchar2
      , in_friendList in varchar2
      , in_objid in NUMBER
      , out_result out NUMBER)
  is
	LV_TEST_CUR SYS_REFCURSOR;
  begin
	DECLARE
		int_cnt INTEGER := -1;
		link_status VARCHAR2(50);
		int_comma_pos INTEGER := -1;
		smuID VARCHAR2(100);
      begin

	  select count(1) into int_cnt
	    from sa.X_SME_2MOBILEUSER
	  where X_SOCIAL_MEDIA_UID in (
									select regexp_substr(in_SMUIDList,'[^,]+', 1, level) from dual
									 connect by regexp_substr(in_SMUIDList, '[^,]+', 1, level) is not null
								 )
	  and X_status_desc = 'UnLinked'
	  and X_status = 0;

	  IF int_cnt = 0 THEN
		link_status:='No-Record';
	  ELSE
		link_status:='UnLinked';
	  END IF;

	  DBMS_OUTPUT.PUT_LINE('link_status against SMUId List = '||link_status);

	   IF link_status = 'No-Record' THEN

			    -- For insert making sure that only single SMUID is fetched from the comma separated list
				-- This is defensive code written for input like '123,'  and '123,456'

				select in_str into smuID from
				(
				select regexp_substr(in_SMUIDList,'[^,]+', 1, level) in_str from dual
				   connect by regexp_substr(in_SMUIDList, '[^,]+', 1, level) is not null
				)
				where rownum=1;

				DBMS_OUTPUT.PUT_LINE('No pre existing record found .. inserting into linkage and profile for SMUID:' ||smuID);

				Insert into sa.X_SME_2MOBILEUSER  (X_CREATEDATE
												  ,X_LASTUPDATE
												  ,X_SME_MOBILEUSER2WEBUSER
												  ,X_SME_ID
												  ,X_SOCIAL_MEDIA_UID
												  ,X_STATUS
												  ,X_STATUS_DESC
												  ,X_Token_For_Business)
				values (sysdate, null, in_objid, in_SMEId, smuID, 1, 'Linked', in_Token_For_Business);

				Insert into sa.X_SOCIAL_MEDIA_PROFILE (X_SOCIAL_MEDIA_UID
												  ,X_UNAME
												  ,X_FIRST_NAME
												  ,X_LAST_NAME
												  ,X_ULINK
												  ,X_USERNAME
												  ,X_GENDER
												  ,X_LOCALE
												  ,X_AGE_RANGE
												  ,X_EMAIL
												  ,X_FRIEND_LIST_NODE
												  ,X_NONPUBLICATTRIBUTE
												  ,X_CREATEDATE
												  ,X_LASTUPDATEDATE
												  ,X_SME_MOBILEUSER2WEBUSER
												  ,X_SME_ID)
				values (smuID
						, in_loginName
						, in_firstName
						, in_lastName
						, in_link
						, in_userName
						, in_gender
						, in_locale
						, in_ageRange
						, in_email
						, in_friendList
						, null
						, sysdate
						, null
						, in_objid
						, in_SMEId);
				commit;
		ELSE
				DBMS_OUTPUT.PUT_LINE('Pre existing record found .. interating over the list of in_SMUIDList:' ||in_SMUIDList);

				FOR LV_TEST_CUR IN (select regexp_substr(in_SMUIDList,'[^,]+', 1, level) smuId from dual
	                       connect by regexp_substr(in_SMUIDList, '[^,]+', 1, level) is not null)
				LOOP
					DBMS_OUTPUT.PUT_LINE('Checking data for SMU ID:' ||LV_TEST_CUR.smuId);

					MERGE INTO sa.X_SME_2MOBILEUSER b
					USING (
							SELECT LV_TEST_CUR.smuId smuId FROM dual
						  ) a
					ON (b.X_SOCIAL_MEDIA_UID = a.smuId
					     and X_SME_MOBILEUSER2WEBUSER=in_objid
						)
					WHEN MATCHED THEN
					  UPDATE SET b.X_Token_For_Business = in_Token_For_Business
								,b.X_STATUS = 1
								,b.X_STATUS_DESC='Linked'
								,b.X_LastUpdate=sysdate
					WHEN NOT MATCHED THEN
					  Insert (X_CREATEDATE
								,X_LASTUPDATE
								,X_SME_MOBILEUSER2WEBUSER
								,X_SME_ID
								,X_SOCIAL_MEDIA_UID
								,X_STATUS
								,X_STATUS_DESC
								,X_Token_For_Business)
					  values (sysdate, null, in_objid, in_SMEID, smuId, 1, 'Linked',in_Token_For_Business);


					MERGE INTO sa.X_SOCIAL_MEDIA_PROFILE b
					USING (
							SELECT LV_TEST_CUR.smuId smuId FROM dual
						  ) a
					ON (b.X_SOCIAL_MEDIA_UID = a.smuId)
					WHEN MATCHED THEN
					  UPDATE SET b.X_SME_MOBILEUSER2WEBUSER = in_objid
								,b.X_UNAME              = in_loginName
								,b.X_FIRST_NAME         = in_firstName
								,b.X_LAST_NAME          = in_lastName
								,b.X_ULINK              = in_link
								,b.X_USERNAME           = in_userName
								,b.X_GENDER             = in_gender
								,b.X_LOCALE             = in_locale
								,b.X_AGE_RANGE          = in_ageRange
								,b.X_EMAIL              = in_email
								,b.X_FRIEND_LIST_NODE   = in_friendList
								,b.X_LASTUPDATEDATE     = sysdate
					WHEN NOT MATCHED THEN
					  Insert ( X_SOCIAL_MEDIA_UID
							  ,X_UNAME
							  ,X_FIRST_NAME
							  ,X_LAST_NAME
							  ,X_ULINK
							  ,X_USERNAME
							  ,X_GENDER
							  ,X_LOCALE
							  ,X_AGE_RANGE
							  ,X_EMAIL
							  ,X_FRIEND_LIST_NODE
							  ,X_NONPUBLICATTRIBUTE
							  ,X_CREATEDATE
							  ,X_LASTUPDATEDATE
							  ,X_SME_MOBILEUSER2WEBUSER
							  ,X_SME_ID)
					  values (smuID
							, in_loginName
							, in_firstName
							, in_lastName
							, in_link
							, in_userName
							, in_gender
							, in_locale
							, in_ageRange
							, in_email
							, in_friendList
							, null
							, sysdate
							, null
							, in_objid
							, in_SMEId);

				END LOOP;
				commit;
        END IF;
		out_result := 1;
      exception
        when others then
          DBMS_OUTPUT.PUT_LINE('error in  createAndLinkSMAccount..ERR= '||sqlerrm);
          out_result := -1;
      end;
  end createAndLinkSMAccount;

  procedure updatePreferredEmail ( in_preferedEmail in varchar2
                                  , in_OBJID in NUMBER
                                  , out_result out NUMBER)
  is
  begin
      begin
        Update sa.TABLE_CONTACT
        set E_MAIL = in_preferedEmail
        where objid = in_objid;

		out_result := sql%rowcount;

		commit;

      exception
        when others then
          DBMS_OUTPUT.PUT_LINE('error in  updatePreferredEmail..ERR= '||sqlerrm);
          out_result := -1;
      end;

  end updatePreferredEmail ;


  procedure updateShareInterestSM ( in_SMUID in varchar2
                                      , in_SMEID in NUMBER
									  , in_nonPublicAttribute in varchar2
									  , out_result out NUMBER)

  is
  begin
      begin
        update sa.X_SOCIAL_MEDIA_PROFILE
        set X_NonPublicAttribute = in_nonPublicAttribute
		   ,X_Interest_Share = 'Enabled'
        where X_SOCIAL_MEDIA_uid = in_SMUID
		and X_SME_ID=in_SMEId;

		out_result := sql%rowcount;

		commit;

      exception
        when others then
          DBMS_OUTPUT.PUT_LINE('error in  updateShareInterestSM..ERR= '||sqlerrm);
          out_result := -1;
      end;

  end updateShareInterestSM;

  procedure unlinkSMAccount (
      in_SMUID in varchar2
    , in_SMEID in NUMBER
    , in_OBJID in NUMBER
    , out_result out NUMBER
  ) is
  begin
      begin
        update sa.X_SME_2MOBILEUSER
        set  X_STATUS = 0
		    ,X_STATUS_DESC = 'UnLinked'
			,X_LastUpdate = sysdate
        where X_SME_MOBILEUSER2WEBUSER = in_OBJID;

		update sa.TABLE_WEB_USER
        set  X_LAST_UPDATE_DATE = sysdate
        where OBJID = in_OBJID;
		/*
		and sm_uid = in_SMUID
		and sme_id = in_SMEID;
		*/
		out_result := sql%rowcount;

		commit;
      exception
        when others then
          DBMS_OUTPUT.PUT_LINE('error in  unlinkSMAccount..ERR= '||sqlerrm);
          out_result := -1;
      end;
  end unlinkSMAccount;


  procedure fetchLinkageAndIntStatus (
     in_OBJID in NUMBER
	,in_SMEId in number
	,link_status out varchar2
	,interest_share_status out varchar2
    ,out_result out NUMBER
  ) is
  begin
      begin

       select decode (count(*), 0, 'Unlinked','linked')  into link_status
         from sa.X_SME_2MOBILEUSER
       where X_SME_MOBILEUSER2WEBUSER= in_OBJID
          and X_status_desc = 'Linked'
		  and X_STATUS=1
		  and X_SME_ID=in_SMEId;

	   interest_share_status := 'Disabled';

	   IF link_status = 'linked' THEN

		select nvl(X_Interest_Share , 'Disabled') into interest_share_status
          from sa.X_SOCIAL_MEDIA_PROFILE
        where X_SOCIAL_MEDIA_UID in (select X_SOCIAL_MEDIA_uid
		                                 from  sa.X_SME_2MOBILEUSER where X_SME_MOBILEUSER2WEBUSER= in_OBJID
		                             and X_SME_ID=in_SMEId)
		and X_SME_ID=in_SMEId;

	   END IF;
	   out_result := 0;

       exception
        when others then
          DBMS_OUTPUT.PUT_LINE('error in  fetchLinkageAndIntStatus..ERR= '||sqlerrm);
          out_result := -1;
      end;
  end fetchLinkageAndIntStatus;

END SM_Integration_PKG;
/