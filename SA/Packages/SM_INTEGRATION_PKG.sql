CREATE OR REPLACE PACKAGE sa.SM_Integration_PKG AS

/*******************************************************************************************************
  * --$RCSfile: FB_INTEGRATION_INFO_PKG.sql,v $
  --$Revision: 1.8 $
  --$Author: bkayal $
  --$Date: 2014/12/16 16:50:52 $
  --$ $Log: FB_INTEGRATION_INFO_PKG.sql,v $
  --$ Revision 1.8  2014/12/16 16:50:52  bkayal
  --$ Modified for CR32075(Business manager API implementation for facebook)
  --$
  --$ Revision 1.7  2014/11/10 14:17:52  bkayal
  --$ Removed AddSocialMetricLogs procedure
  --$
  --$ Revision 1.6  2014/11/04 16:42:45  bkayal
  --$ Add Social media Table
  --$
  --$ Revision 1.5  2014/11/04 14:19:06  bkayal
  --$ Removed AddSocialMetricLogs
  --$
  --$ Revision 1.4  2014/09/22 12:51:56  bkayal
  --$ Comments Added as per DB instrucitions
  --$
  * Description: This package includes the five procedures
  * getMyAccountBySM, updateSMAccount, createAndLinkSMAccount, updatePreferredEmail,unlinkSMAccount,fetchLinkageAndInterestStatus,addSocialMediaMetricLogs Services.
  * -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/

  procedure getMyAccountBySM (
        in_SMUIDList in varchar2 --(Facebook user id) - INTEGER
      , in_SMEID in NUMBER       --(Social Entity Type ID) - INTEGER
	  , in_Token_For_Business varchar2
      , out_webUser out sys_refcursor
  ) ;


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
  );

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
      , out_result out NUMBER
  );

  procedure updatePreferredEmail (
      in_preferedEmail in varchar2
      , in_OBJID in NUMBER
      , out_result out NUMBER
  );

  procedure updateShareInterestSM (
        in_SMUID in varchar2
	  , in_SMEID in NUMBER
      , in_nonPublicAttribute in varchar2
      , out_result out NUMBER
  );

  procedure unlinkSMAccount (
      in_SMUID in varchar2
    , in_SMEID in NUMBER
    , in_OBJID in NUMBER
    , out_result out NUMBER
  ) ;

  procedure fetchLinkageAndIntStatus (
     in_OBJID in NUMBER
	,in_SMEId in number
	,link_status out varchar2
	,interest_share_status out varchar2
    ,out_result out NUMBER
  ) ;


 END SM_Integration_PKG;
/