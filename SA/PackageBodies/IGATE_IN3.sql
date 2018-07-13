CREATE OR REPLACE PACKAGE BODY sa."IGATE_IN3"
 ---------------------------------------------------------------------------------------------
 --$RCSfile: IGATE_IN3.sql,v $
 --$Revision: 1.354 $
 --$Author: mdave $
 --$Date: 2018/05/23 13:39:40 $
 --$ $Log: IGATE_IN3.sql,v $
 --$ Revision 1.354  2018/05/23 13:39:40  mdave
 --$ CR58576
 --$
 --$ Revision 1.341  2018/03/26 19:54:33  jcheruvathoor
 --$ CR56462	TMobile Update Port In Case with OSP
 --$
 --$ Revision 1.332  2018/02/15 16:48:16  skota
 --$ Modified for PFR order type
 --$
 --$ Revision 1.331  2018/02/12 19:42:41  jcheruvathoor
 --$ CR54900
 --$
 --$ Revision 1.330  2018/01/31 15:22:52  skota
 --$ Merged the code
 --$
 --$ Revision 1.329  2018/01/19 15:05:18  skota
 --$ Modified for sending buctes to TMO
 --$
 --$ Revision 1.327  2017/12/12 15:11:09  tpathare
 --$ New procedure rta_lite added for minimal processing of specific order types.
 --$
 --$ Revision 1.319  2017/09/15 16:12:54  mdave
 --$ CR49915 - lifeline wfm changes for min change with sim change
 --$
 --$ Revision 1.316  2017/08/17 17:38:51  vnainar
 --$ CR52803 merged with CR51539
 --$
 --$ Revision 1.314  2017/08/09 17:35:35  vnainar
 --$ CR52803 Safelink benefit order type exclusion
 --$
 --$ Revision 1.313  2017/08/03 14:44:37  nsurapaneni
 --$ Merged with CR51036
 --$
 --$ Revision 1.310  2017/07/14 21:42:28  smeganathan
 --$ skip min update check is added while updating MIN status
 --$
 --$ Revision 1.305  2017/07/07 16:53:26  smeganathan
 --$ skip min update check is added while updating MIN status
 --$
 --$ Revision 1.299  2017/06/26 17:32:51  skota
 --$ Make changes for newer transaction found
 --$
 --$ Revision 1.298  2017/06/26 14:42:11  skota
 --$ make changes to close the old transactions which are in non provision order type
 --$
 --$ Revision 1.297  2017/06/22 19:27:16  smeganathan
 --$ CR51685 Excluding APN UI and PFR while checking for newer transactions
 --$
 --$ Revision 1.296  2017/06/22 15:48:47  smeganathan
 --$ CR51685 Excluding UI and PFR while checking for newer transactions
 --$
 --$ Revision 1.294  2017/04/06 19:48:41  sgangineni
 --$ CR47564 - WFM code merge with Rel_854 SUI changes
 --$
 --$ Revision 1.293  2017/04/05 18:19:06  sgangineni
 --$ CR47564 - WFM code merge with Rel_854 changes
 --$
 --$ Revision 1.288  2017/03/21 21:27:36  sraman
 --$ CR47564-Update x_account_group service_plan_id with the ESN service plan objid for Non-Shared Group Plan
 --$
 --$ Revision 1.283  2017/02/21 22:36:12  aganesan
 --$ CR47564 enqueue transaction package signature call modified.
 --$
 --$ Revision 1.281  2017/02/01 23:02:24  smeganathan
 --$ CR47564  incorporated review comments
 --$
 --$ Revision 1.280  2017/01/30 22:57:00  smeganathan
 --$ CR47564 changes for update ldap
 --$
 --$ Revision 1.279  2017/01/24 22:35:11  smeganathan
 --$ CR47564 calling p_update_ldap_security_pin
 --$
 --$ Revision 1.278  2016/12/13 16:26:35  tbaney
 --$ Changed logic to use Plan Type SL_UNL_PLANS CR42459
 --$
 --$ Revision 1.277  2016/12/09 21:26:33  tbaney
 --$ Changes for CR42459.
 --$
 --$ Revision 1.276  2016/12/02 15:58:36  rpednekar
 --$ CR39916 - Merged 1.274 and 1.275.
 --$
 --$ Revision 1.274  2016/10/25 18:10:29  ddudhankar
 --$ CR44787 - BOGO call from iGate_IN3 commented
 --$
 --$ Revision 1.273  2016/10/20 22:17:51  rpednekar
 --$ 43254
 --$
 --$ Revision 1.271  2016/09/29 21:57:04  rpednekar
 --$ CR43254
 --$
 --$ Revision 1.270  2016/09/26 19:48:38  rpednekar
 --$ CR43254 - IGATE.PROCESS_FOTA_CAMP_TRANS called on ig sucess on top of bogo copy.
 --$
 --$ Revision 1.269  2016/09/21 17:41:54  ddudhankar
 --$ CR44652 - logging removed
 --$
 --$ Revision 1.268  2016/09/16 21:21:01  ddudhankar
 --$ CR44652 - Error logging introduced
 --$
 --$ Revision 1.267  2016/09/13 15:12:10  ddudhankar
 --$ CR44652 - BOGO pakage call changes after Juda's review comments
 --$
 --$ Revision 1.266  2016/09/09 20:55:30  ddudhankar
 --$ CR44652 - BOGO NT changes
 --$
 --$ Revision 1.265  2016/09/09 20:53:17  ddudhankar
 --$ CR44652 - BOGO NT Changes
 --$
 --$ Revision 1.264  2016/06/14 15:01:09  pamistry
 --$ CR37756 - Production merge for jun 14 release
 --$
 --$ Revision 1.263  2016/06/09 21:28:07  jpena
 --$ Restrict duplicate processing for PCRF
 --$
 --$ Revision 1.259  2016/04/22 20:38:35  jpena
 --$ Add skip pcrf subscriber flag to monthly plans call.
 --$
 --$ Revision 1.258 2016/01/20 17:38:39 jarza
 --$ CR40388
 --$
 --$ Revision 1.257 2016/01/04 15:39:44 vnainar
 --$ CR38927 unmerge CR38280
 --$
 --$ Revision 1.256 2015/12/19 15:29:21 vnainar
 --$ CR38927 merged 1.249 and CR38280 changes
 --$
 --$ Revision 1.252 2015/11/17 21:30:05 vnainar
 --$ CR38927 merged on top of 1.249 version
 --$
 --$ Revision 1.251 2015/11/13 17:08:39 vnainar
 --$ CR38927 latest changes commented to compile in SITCI
 --$
 --$ Revision 1.250 2015/11/13 16:21:41 vnainar
 --$ CR38927 safelink upgrades If block added for safelink disenrollment rate plan change
 --$
 --$ Revision 1.249 2015/11/10 18:56:20 skota
 --$ merge the code
 --$
 --$ Revision 1.246 2015/11/06 22:26:43 skota
 --$ merged the code
 --$
 --$ Revision 1.244 2015/10/14 19:59:11 jpena
 --$ Adding changes for TFDM + E911 Changes
 --$
 --$ Revision 1.243 2015/10/14 19:49:51 pvenkata
 --$ E911
 --$
 --$ Revision 1.242 2015/10/12 19:34:56 pvenkata
 --$ *** empty log message ***
 --$
 --$ Revision 1.241 2015/10/12 16:32:43 pvenkata
 --$ *** empty log message ***
 --$
 --$ Revision 1.239 2015/10/01 16:09:57 pvenkata
 --$ 35097
 --$
 --$ Revision 1.238 2015/09/17 14:48:03 skota
 --$ merge the code
 --$
 --$ Revision 1.237 2015/09/15 16:03:45 skota
 --$ modified
 --$
 --$ Revision 1.232 2015/08/31 21:19:11 aganesan
 --$ CR37016 changes.
 --$
 --$ Revision 1.225 2015/07/06 02:17:46 jpena
 --$ Changes for Super Carrier to remove a temp log message
 --$
 --$ Revision 1.224 2015/06/30 23:30:20 aganesan
 --$ CR36122 - Super Carrier Release5 changes.
 --$
 --$ Revision 1.221 2015/06/10 15:33:57 aganesan
 --$ CR35396 Changes.
 --$
 --$ Revision 1.220 2015/06/10 06:47:11 aganesan
 --$ CR35396 Changes
 --$
 --$ Revision 1.216 2015/06/02 15:51:47 arijal
 --$ CR35007 MOM Action Item fix
 --$
 --$ Revision 1.213 2015/05/26 20:50:35 jarza
 --$ merging CR34475 code to CR34909
 --$
 --$ Revision 1.212 2015/05/19 00:18:12 aganesan
 --$ CR34909 - Super Carrier Changes
 --$
 --$ Revision 1.209 2015/05/01 21:41:20 arijal
 --$ CR33548 MOM ACTION ITEM
 --$
 --$ Revision 1.203 2015/04/14 16:18:17 jarza
 --$ Commenting D and S from not inserting into ILD table. We will open this with intergate team changes.
 --$
 --$ Revision 1.202 2015/04/13 17:27:22 jarza
 --$ CR32641 - sending x_ild_account as 0 during deactivations
 --$
 --$ Revision 1.201 2015/04/07 17:01:40 jarza
 --$ CR32641 changes
 --$
 --$ Revision 1.200 2015/03/31 13:50:14 jarza
 --$ CR32641 changes
 --$
 --$ Revision 1.199 2015/03/30 15:20:45 jarza
 --$ CR32641 - ILD logic re-write
 --$
 --$ Revision 1.198 2015/03/25 18:00:54 ddevaraj
 --$ For CR32258
 --$
 --$ Revision 1.197 2015/03/25 17:42:06 ddevaraj
 --$ For CR32258
 --$
 --$ Revision 1.187 2015/03/10 15:45:11 gsaragadam
 --$ CR31618 - Exclude Order Type 'MINC'
 --$
 --$ Revision 1.186 2015/03/04 22:09:59 jpena
 --$ BRAND X CHANGES
 --$
 --$ Revision 1.181 2015/02/26 22:25:30 arijal
 --$ CR33057_pkg_PRODUCT_ID__p
 --$
 --$ Revision 1.180 2015/02/26 21:21:31 arijal
 --$ CR33057_pkg_PRODUCT_ID__p
 --$
 --$ Revision 1.179 2015/02/26 19:02:15 arijal
 --$ CR33057_pkg_PRODUCT_ID__p
 --$
 --$ Revision 1.173 2015/01/23 15:29:42 clinder
 --$ CR31242
 --$
 --$ Revision 1.172 2015/01/21 16:09:24 clinder
 --$ CR31242
 --$
 --$ Revision 1.171 2015/01/13 16:07:46 clinder
 --$ CR31242
 --$
 --$ Revision 1.170 2014/10/21 16:04:07 cpannala
 --$ CR30127 SM_ILD_U changes
 --$
 --$ Revision 1.169 2014/10/14 14:56:57 rramachandran
 --$ CR29840 - TracFone ILD 'TF_PILD_P' update
 --$
 --$ Revision 1.168 2014/10/09 19:58:33 clinder
 --$ CR27279
 --$
 --$ Revision 1.167 2014/10/09 16:26:04 rramachandran
 --$ CR30127 - SM_ILD_U
 --$
 --$ Revision 1.166 2014/10/09 16:03:07 clinder
 --$ CR27279
 --$
 --$ Revision 1.165 2014/10/08 20:20:51 rramachandran
 --$ CR27279 - Enhance SA.IGATE_IN3 to look for newer transactions on failed action items
 --$
 --$ Revision 1.164 2014/10/08 20:17:54 rramachandran
 --$ CR27279 - Enhance SA.IGATE_IN3 to look for newer transactions on failed action items
  --$
  --$ Revision 1.163  2014/10/07 22:09:54  rramachandran
  --$ CR29840 - TracFone ILD 'TF_PILD_P' update
  --$
  --$ Revision 1.162  2014/10/07 20:51:57  rramachandran
  --$ CR27279 - Enhance IGATE_IN3 to look for newer transactions on failed action items
  --$
  --$ Revision 1.161  2014/10/06 18:34:53  rramachandran
  --$ CR27279 - Enhance IGATE_IN3 to look for newer transactions on failed action items
  --$
  --$ Revision 1.160  2014/10/03 19:04:23  rramachandran
  --$ CR29840 - TracFone ILD 'TF_PILD_P' update
  --$
  --$ Revision 1.159  2014/10/02 19:56:08  rramachandran
  --$ CR27279 - Enhance IGATE_IN3 to look for newer transactions on failed action items
  --$
  --$ Revision 1.158  2014/10/02 13:38:04  rramachandran
  --$ CR27279 - Enhance IGATE_IN3 to look for newer transactions on failed action items
  --$
  --$ Revision 1.157  2014/09/30 21:38:37  rramachandran
  --$ CR27279 - Enhance IGATE_IN3 to look for newer transactions on failed action items
  --$
  --$ Revision 1.156  2014/09/30 20:09:24  rramachandran
  --$ CR29840 - TracFone ILD 'TF_PILD_P' update
  --$
  --$ Revision 1.155  2014/09/30 19:07:50  rramachandran
  --$ CR28160 - ET10 cross carrier upgrade and internal ports
  --$
  --$ Revision 1.154  2014/09/30 19:02:26  rramachandran
  --$ CR28160 - ET10 cross carrier upgrade and internal ports
  --$
  --$ Revision 1.152  2014/09/30 15:21:40  mvadlapally
  --$ CR28625 - Curt change at merge statement for table_x_ild_transaction- Merged with Prod
  --$
  --$ Revision 1.144  2014/09/22 16:36:54  mvadlapally
  --$ CR28625 - adding V_ACCOUNT type 2 for 'TF_ILD_10 - Code merged with Prod
  --$
  --$ Revision 1.133  2014/07/25 18:05:45  rramachandran
  --$ CR29971 - TracFone and Net10 provisioning
  --$
  --$ Revision 1.132  2014/07/17 17:34:26  rramachandran
  --$ CR29001 - Fix for CR29008
  --$
  --$ Revision 1.131  2014/07/15 18:46:46  rramachandran
  --$ CR29001 - ST_ILD_U
  --$
  --$ Revision 1.130  2014/06/20 21:44:46  rramachandran
  --$ CR29008 - Prevent SIMC transactions from being logged into table_x_ild_transaction
  --$
  --$ Revision 1.129  2014/04/18 16:11:36  ymillan
  --$ CR27015 + CR28317
  --$
  --$ Revision 1.127  2014/03/26 14:09:02  ymillan
  --$ CR27015 merge with CR26586
  --$
  --$ Revision 1.125  2014/01/29 14:53:17  clinder
  --$ CR26586
  --$
  --$ Revision 1.124  2013/11/08 21:13:59  icanavan
  --$ change the insert into table_x_ild_transaction
  --$
  --$ Revision 1.123  2013/11/04 19:58:18  ymillan
  --$ CR25632
  --$
  --$ Revision 1.122  2013/10/02 22:05:05  icanavan
  --$ SUSPEND2CANCEL AND 10 ILD DUPLICATE BENEFITS ISSUE
  --$
  --$ Revision 1.120  2013/09/26 16:23:40  icanavan
  --$ add TMOSM template to fix problem with mins being set to RETURNED
  --$
  --$ Revision 1.118  2013/09/10 02:46:02  mvadlapally
  --$ CR23513 TF Surepay
  --$
  --$ Revision 1.117  2013/09/07 00:20:36  mvadlapally
  --$ CR23513 TF Surepay
  --$
  --$ Revision 1.115  2013/08/22 23:41:09  mvadlapally
  --$ CR23513 TF Surepay
  --$
  --$ Revision 1.110  2013/07/29 22:39:29  akhan
  --$ Block inserts to ild_trnsaction table for Mega CArd
  --$
  --$ Revision 1.108  2013/07/17 17:10:45  icanavan
  --$ CR24196
  --$
  --$ Revision 1.107  2013/07/16 21:49:53  icanavan
  --$ new cursor for CR24196
  --$
  --$ Revision 1.106  2013/06/18 21:26:32  icanavan
  --$ merge with production CR24247
  --$
  --$ Revision 1.104  2013/06/05 18:18:33  icanavan
  --$ ADDED CHANGES FOR ILD
  --$
  --$ Revision 1.103  2013/06/04 23:35:44  icanavan
  --$ HOLD THIS FOR ANOTHER DAY
  --$
  --$ Revision 1.101  2013/06/03 20:12:30  ymillan
  --$ production 6/3/2013 + merge CR24082
  --$
  --$ Revision 1.97  2013/04/16 15:51:40  icanavan
  --$ VAS_MANAGEMENT AND SM
  --$
  --$ Revision 1.96  2013/04/12 13:06:36  ymillan
  --$ CR22452
  --$
  --$ Revision 1.92  2013/03/22 22:02:01  ymillan
  --$ CR23775
  --$
  --$ Revision 1.91  2013/03/22 16:37:48  ymillan
  --$ CR22213
  --$
  --$ Revision 1.90  2013/03/19 15:51:30  icanavan
  --$ For release 3/26 exclude CR21443
  --$
  --$ Revision 1.89  2013/03/19 15:42:29  ymillan
  --$ CR22213
  --$
  --$ Revision 1.88  2013/03/13 21:35:51  icanavan
  --$ CR21443 merged with CR22487 and CR22213
  --$
  --$ Revision 1.87  2013/03/08 20:59:49  ymillan
  --$ CR22487 CR22213
  --$
  --$ Revision 1.83  2013/02/26 19:37:10  ymillan
  --$ CR22487 NET10 HOMEPHONE
  --$
  --$ Revision 1.81  2013/01/07 20:04:00  ymillan
  --$ CR20403 merge with CO #: C28023
  --$
  --$ Revision 1.80  2012/12/24 18:10:28  ymillan
  --$ CR20403
  --$
  --$ Revision 1.79  2012/10/03 18:21:59  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.78  2012/09/26 13:10:16  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.77  2012/09/25 21:34:23  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.76  2012/09/25 21:29:08  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.75  2012/09/24 17:29:34  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.74  2012/09/19 17:11:46  kacosta
  --$ CR21157 TF Pay As You Go ILD
  --$
  --$ Revision 1.73  2012/09/18 19:34:41  ymillan
  --$ CR21934
  --$
  --$ Revision 1.72  2012/09/18 19:31:44  ymillan
  --$ CR21934
  --$
  --$ Revision 1.71  2012/09/12 17:52:11  icanavan
  --$ TELCEL added /
  --$
  --$ Revision 1.70  2012/09/12 17:35:36  icanavan
  --$ TELCEL for ILD
  --$
  --$ Revision 1.69  2012/09/06 21:12:53  icanavan
  --$ TELCEL merged with prod rollout 9/6/12
  --$
  --$ Revision 1.65  2012/08/31 19:22:03  icanavan
  --$ HOMEPHONE merge with PRODUCTION
  --$
  --$ Revision 1.54  2012/06/04 21:34:42  kacosta
  --$ CR21051 Missing Part Number for LINES
  --$
  --$ Revision 1.53  2012/05/09 15:25:21  ymillan
  --$ CR20546 merge with production version
  --$
  --$ Revision 1.52  2012/04/16 20:12:54  ymillan
  --$ CR19595
  --$
  --$ Revision 1.51  2012/04/16 20:10:20  ymillan
  --$ CR20546
  --$
  --$ Revision 1.50  2012/04/11 19:10:55  ymillan
  --$ CR19595
  --$
  --$ Revision 1.49  2012/04/11 16:02:36  ymillan
  --$ CR19595
  --$
  --$ Revision 1.48  2012/03/16 13:32:23  lsatuluri
  --$ CR19595
  --$
  --$ Revision 1.47  2012/03/01 21:22:01  ymillan
  --$  CR15690
  --$
  --$ Revision 1.46  2012/02/27 20:23:57  ymillan
  --$ CR15690 ILD project
  --$
  --$ Revision 1.45  2012/02/06 23:16:54  pmistry
  --$ CR18776  Sprint - NT CDMA Postpaid -Upgrade (To handle ESN Change order type).
  --$
  --$ Revision 1.44  2012/01/18 19:23:27  kacosta
  --$ CR18553 igate_in3 Create Sim Exchange
  --$ CR19321 IG Failed Log Update
  --$
  --$ Revision 1.43  2012/01/18 19:16:45  kacosta
  --$ CR18553 igate_in3 Create Sim Exchange
  --$ CR19321 IG Failed Log Update
  --$
  --$ Revision 1.42  2012/01/18 14:16:37  kacosta
  --$ CR18553 igate_in3 Create Sim Exchange
  --$ CR19321 IG Failed Log Update
  --$
  --$ Revision 1.30  2011/11/17 15:45:09  pmistry
  --$ CR18895 Added parameter to run igate_in3 in parallel.
  --$
  ---------------------------------------------------------------------------------------------
  /*===============================================================================================================x
  | -----------------  ----------  --------  ----------------------------------------------------------------------
  | REVISIONS VERSION  DATE        WHO       PURPOSE
  | -----------------  ----------  --------  ----------------------------------------------------------------------
  |         1.0                              Initial Revision
  |         1.1        08/17/04    GP        CR3154 Added new Naming Convention
  |                                          to auto close IGATE cases under new CM
  |         1.2        09/17/04    TCS       CR3153. TMOBILE changes
  |         1.3        10/27/04    TCS       CR3327 - Internal Port In changes
  |         1.4        11/10/04    GP        CR3327 - added decode for GSM phones and
  |                                                   added parent cursor
  |         1.5        12/02/04    Ritu      CR3440 - Remove code related to blnUpdated flag.
  |         1.6        01/04/05    NLalovic  OTA Project changes:
  |                                          Procedure rta_in was modified:
  |                                          Update table TABLE_X_OTA_TRANSACTION with new MIN
  |                                          if call_trans_rec.X_OTA_TYPE is OTA Activation
  |                                          and carrier is TMOBILE
  |         1.7        01/15/04    NLalovic  OTA project changes:
  |                                          Procedure rta_in was modified:
  |                                          IF ig_trans_rec.TEMPLATE != 'TMOBILE'
  |                                          OR ( ig_trans_rec.TEMPLATE = 'TMOBILE'
  |                                          AND
  |                                          (part_inst_rec.esn_status = '52'
  |                                          OR
  |                                          f_ota_activation_is_pending(ig_trans_rec.ESN)) )
  |                                          NOTE:
  |                                          For OTA Activation the ESN status will be 50
  |                                          since the code accepted logic will not be executed
  |                                          until the codes are sent through the OTA and
  |                                          MO acknowledgment is received.
  |                                          Created: cursor ota_call_trans_curs,
  |                                                   function f_ota_activation_is_pending
  !        1.8         03/01/05      Ritu    CR3647 - MIN Change for TMOBILE
  |        .......     ...........
  |        1.13        05/04/05      VAdapa  CR3918 - MSISDN Change for Cingular
  |        1.14        05/07/05      VAdapa  Fix for CR3918 for Cingular's new error code
  |                                          W000017 - There are no lines available for the given zip
  |        1.15        05/20/05      Mchinta Fix for CR3918 for Cingular's new error code for Cares
  |                                          and Telegence
  |                                          Fix to update the carrier from Call trans record.
  |        1.16        05/22/05      VAdapa  Check for MINC and TMOBILE in PART_INST rec cursor
  |        1.17        05/24/05      MChinta Make a call to sp_Dispatch_Task instead to sp_Close_Action_Item
  |                                          when no lines available.Dispatch Action item to GSM Rework Queue
  |        1.18
  |         .19        05/27/05      MChinta Sinking the version label with PVCS revision
  |        1.20        06/15/05      MChinta Create Sim Exchange case for CR3918 wher error is
  |                                          'Operation MINC failed'
  |        1.21
  |         .22
  |         .23
  |         .24        06/15/05      MChinta  Update x-replacement_units to 0 for CR3918 where error is
  |                                           'Operation MINC failed'
  |        1.26        07/11/05      Gpintado CR4264 - Line Status change
  |        1.27        10/12/05      Gpintado CR4579 - Added Technology param to sp_get_orderType
  |        1.28        10/16/05      NLalovic Changes for Cingular Next available project.
  |        1.29        12/30/05      NLalovic Changes for Cingular Next Available project:
  |                                           Added call to packaged procedure IGATE.reopen_case_proc.
  |                                           Procedure is called from igate_in3.RTA_IN to re    open case
  |                                           when carrier with no Tracfone inventory returns message
  |                                           "No Line Available"
  |        1.30        01/05/06      NLalovic Changes for Cingular Next Available project:
  |                                           Added input parameter p_notes to IGATE.reopen_case_proc
  |                                           procedure to make it more generic. The value will be passed in
  |                                           from the calling program (igate_in3.RTA_IN) instead of
  |                                           to be hardcoded in the reopen_case_proc procedure.
  |        1.8.1.9     02/21/06      VAdapa   Merged the Next Available (CR4588) changes with
  |                                           CR5008 (Curt's recommendations)
  |                                           Case can be closed if the value of ig_transaction.subscriber_update
  |                                           column is set to NOT NULL.
  |         1.31       05/22/06      NLalovic CR4960
  |                                           Added UPDATE TABLE_X_ILD_TRANSACTION statement to handle duplicate
  |                                           records in TABLE_X_CALL_TRANS, TABLE_SITE_PART and TABLE_PART_INST
  |                                           that we started having after Next Avaibale project was pushed into
  |                                           production. The change in code is marked with CR4960 comment.
  |                    05/22/06      NLalovic GSM Enhancement project:
  |                                           Added an additional condition to "close the case ?" logic
  |                                           in 4 places in the program. Changes in the code are marked with
  |                                           "-- GSM Enhancement" comment.
  |                                           Case can be closed if the value of ig_transaction.subscriber_update
  |                                           column is set to NOT NULL.
  |       1.8.1.15     06/08/06        VAdapa CR5349 - Fix for OPEN_CURSORS
  |       1.8.1.16     06/13/06        VAdapa CR4960 - 1 changes
  |       1.8.1.17     06/15/06        VAdapa CR4947 - Merged CR4947 changes with the latest production copy
  |                                           made by Novak on 05/22/06
  |                                           Adjusted revision number here and in PVCS to be the same.
  |                                           Handle status messages coming from TMOBILE carrier:
  |                                           The following private procedures (inner modules of RTA_IN procedure)
  |                                           were created to implement this change:
  |                                           sp_close_task
  |                                           sp_create_sim_exchange_case
  |                                           sp_remove_mdn_from_imei
  |                                           sp_process_esn_change
  |                                           f_tmobile_activation_msg
  |                                           f_tmobile_esn_chng_msg
  |                                           f_tmobile_minc_msg
  |                                           f_tmobile_deact_msg
  |                                           f_tmobile_suspend_msg
  |                                           Commented out UPDATE TABLE_X_ILD_TRANSACTION
  |                                           statement that was made for CR4960.
  |                                           Modified procedure call to CREATE_CASE_CLARIFY_PKG.SP_CREATE_CASE
  |                                           by adding two new parameters.
  |     1.8.1.16.1.1   07/05/06      NLalovic Merged latest code from production into GSM Enhancement project.
  |     1.8.1.16.1.2   07/26/06               Added meaningful notes to CASE_HISTORY if the case is sucessfully closed.
  |     1.8.1.16.1.3   07/31/06      NLalovic Merged CR4902 code (GSM Enhancement) into CR4947 code (T-Mobile status messages)
  |     1.8.1.16.1.4   08/03/06      NLalovic Fixed a bug in sp_remove_mdn_from_imei procedure.
  |                                           Changed AND x_domain = 'PHONES'
  |                                           into:   AND x_domain = 'LINES'
  |                                           Changed WHERE part_serial_no = p_ig_trans_rec.esn
  |                                           into:   WHERE part_serial_no = p_ig_trans_rec.min
  |                                           Modified  f_tmobile_minc_msg:
  |                                           added call to sp_remove_mdn_from_imei procedure
  |                                           when status message is Invalid Subscriber.
  |     1.8.1.16.1.5   08/03/06      NLalovic sp_remove_mdn_from_imei doesn;t deactivate the phone
  |                                           we will call SERVICE_DEACTIVATION.DEACTIVATE_ANY procedure instead.
  |     1.8.1.16.1.6   08/10/06      NLalovic Converted private stored procedures  into private stored functions:
  |                                           sp_tmobile_activation_msg     -->    f_tmobile_activation_msg
  |                                           sp_tmobile_esn_chng_msg       -->    f_tmobile_esn_chng_msg
  |                                           sp_tmobile_minc_msg           -->    f_tmobile_minc_msg
  |                                           sp_tmobile_deact_msg          -->    f_tmobile_deact_msg
  |                                           sp_tmobile_suspend_msg        -->    f_tmobile_suspend_msg
  |                                           The RTA_IN procedure needs to continue to process current ig_transaction
  |                                           record if the above functions didn't process it.
  |                                           Each function returns true or false.
  |      1.8.1.16.1.7/8/9  08/10/06      VAdapa  Added call to interface_jobs procedure to log the number os records processed
  |                                 Based on Jing T (DBA) recommendation)
  |      1.8.1.16.1.10   09/27/06      VAdapa  CR5600 changes -- Move the update of MSID  to the beginning of the program
  |      1.8.1.16.1.11  10/05/06      VAdapa   Fix the defect occurred during testing of CR5586
  |                                        Pass MSID to part_inst_curs insteadt of MIN if it is a T number
  |      1.8.1.16.1.12  10/20/06      VAdapa   Revert revision   1.8.1.16.1.11
  |      1.8.1.16.1.13  11/1/06       NLalovic CR5780 if part_inst_curs doesn't return any rows with min try to open it with msid
  |                                            if that doesn't return row then try to open site_part_x_min_curs with ESN
  /    1.8.1.16.1.14  12/06/06      VAdapa   CR5687-1 Update Phone pers to MDN personality - Wrong Carrier Personality Code
  x================================================================================================================*/
  ----------------------------------------------------------------------------------
  /* NEW PVCS STRUCTURE /NEW_PLSQL?CODE                                                              */
  /*1.0       04/08/08  VAdapa      Initial Version (Production copy as of 04/08/08)
  /*1.1       04/08/08  VAdapa      Changes are made as per Nitin(Oracle DBA) for CR7159
  /*1.1.1.1   11/6/08   NGuada      CR8013 Chnages for TMO Portability 'PIR' order type              */
  /*1.1.1.2   11/11/08  NGuada      CR8246 Dispatch Port In Cases to Internal Port Approval queue    */
  /*1.2/1.3   10/02/08  CLinder     CDMA NEXT AVAIL PROJECT
  /*1.4/1.5/1.6       11/20/08  ICanavan    Merge CR7814_CDMA NEXT AVAIL PROJECT CR8013 CR8246
  /* 1.7         01/27/09       CLindner     CR8427
  CDMA Next Available = No MSID update needed
  CDMA NON Next Available = MSID Update needed
  /* 1.13         03/25/09       CLindner     CR8465 MIN change
  /* 1.14         04/03/09       VAdapa    CR8465 MIN change
  /* 1.15         04/08/09       VAdapa    CR7579 - Claro
  /* 1.16-17      04/24/09       CLindner  CR8663 - Walmart Straight Talk and merge with CR8465,CR7579
  /* 1.18-1.22    11/02/09       SKuthadi  ST_BUNDLE_II , ST_BUNDLE_II_A
  /* 1.23-24      11/11/09       SKuthadi  CR12155 ST_BUNDLE_III
  /* 1.25         11/16/09       Skuthadi  CR12155 ST_BUNDLE_III -- status = W, (PIR), do not update table case
  /* 1.27         02/05/2010     CLindner  CR13035 CR12825 -- NTUL Fix for ST reserved lines
  /* 1.28         03/11/2010     Skuthadi  CR12218 new template TMOUN
  /* NEW CVS STRUCTURE                  */
  /* 1.2          05/03/2010     Vadapa   CR13463 ST Reacts Not Getting Reserved Min
  /* 1.3          06/22/2010     Skuthadi CR12852 (WSRD)Website Redesign new queues and case titles */
  /* 1.6          08/16/2010     PM       CR13531 STCC as we are changing Order Type in IGATE from AP to PAP in case of VERIZON_PP */
  /* 1.7          09/15/2010     Skuthadi CR13531 STCC add check for closed cases */
  /* 1.8          09/28/2010     PMistry  CR13980 Need to handle CRU as CR */
  /* 1.9          10/08/2010     NGuada  CR13085                    */
  /* 1.10          10/08/2010     NGuada  CR13085                    */
  /* 1.11         12/13/2010     kacosta   CR14927 NET10 CDMA Act_React Rate Plan Check - Added code to generate a rate plan change action item if the the rate plan has changed */
  /*                                               1. In the ig_trans_curs cursor added 2 retreive values used to determined if a rate plan change action item needs to be created */
  /*                                               2. In procedure RTA_IN added 3 new variables to support the fix /*
  /*                                               3. In procedure RTA_IN developed a new local function to created a rate plan change task if necessary */
  /*                                               4. Moved the record processed counter and encapsulating of the primary RTA_IN code to the beginning of the transactions loop */
  /*                                               5. Added code to check if the rate plan check needs to be created if the order type is A or E and the transactions was successfully returned from the c
  arrier */
  /*                                                  Code will call the new local function */
  /* 1.13         01/26/2011     YMillan  CR15365  Intergate Log File                   */
  /* 1.15         03/08/2011     CLindner CR15578 PBX Enhancement for Portability and Phone Upgrade Options  */
  /* 1.16         03/08/2011     Kacosta  CR12399  Straight Talk Carrier Problem after Port-In */
  /*                                               Modified igate_in3.RTA_IN procedure to update the carrier on the TABLE_PART_INST record for the MIN only if there is no "Active" */
  /*                                               or "CarrierPending" TABLE_SITE_PART record for the MIN */
  /*  1.17               04/07/2011     CLindner CR15983 Enhance igate_in3 to Properly Update MIN/MSID for Alltel and USC  */
  /*  1.18               04/14/2011     CLindner CR15983 Enhance igate_in3 to Properly Update MIN/MSID for Alltel and USC  */
  /*  1.20               04/25/2011     CLindner  CR16262   Missing T Number from Part Inst (Activation Failures)   */
  /*  1.21/1.22/1.24     05/10/2011     CLindner  CR16262   Missing T Number from Part Inst (Activation Failures)   */
  /*  1.25               05/13/2011     Skuthadi  CR15035   NET10 Activation Engine                                 */
  /*  1.27               08/05/2011     Pmistry   CR17415   PPIR - Partial Beenfits for PIR                                 */
  /*  1.28               08/16/2011     Skuthadi  CR16308   SPRINT                                                  */
  /*  1.29               10/24/2011     PMistry   CR17793   Remove PPIR - ST GSM Upgrades Fixes                     */
  /*  1.45               12/02/2011     PMistry   CR18776   Sprint NT10 - UPGRADES.
  /*  1.46/ 1.47       2/3/2012       Clindner  CR15690   ILD Phase II - New Unlimited ILD Monthly Plan            */
  /*  1.49 / 1.52        3/16/2012      Clindner  CR19595   Handset full release    */
  /*  1.51 /1.53         3/19/2012      Clindner  CR20546   multiple row errors    */
  /*  1.81               12/07/2012     YMillan   CR20403  RIM Intregation CDMA  mrege with CO #: C28023 */
  /*  1.82               02/07/2013     YMillan   CR22487  NET10 homephone
  /*  1.92               03/20/2013     Ymillna   CR23775 + NET10 Homephone + CR22213
  /*  1.96               04/12/2013     Ymillna   CR22452  simple mobile included for ILD transaction feature ild cursor    */
  /*  1.120              09/26/2013     ICanavan  CR25987 SIMPLE MOBILE SUSPEND2CANCEL */
  /*-------------------------------------------------------------------------------------------------- | |
  |   x *** CODING STANDARDS *** -----------------------------------------------------------------------------x   |
  |   |                                                                                                       |   |
  |   |  CURSORS:          All cursor names must end with suffix "_curs"                                      |   |
  |   |  CURSOR RECORDS:   All cursor record variable names must end with suffix "_rec".                      |   |
  |   |  VARIABLES:        All other variable names must start with prefix "l_[datatype abbriviation]_"       |   |
  |   |                    i.e. "l_n_" for number variables, "l_c_" for char and varchar,                     |   |
  |   |                    "l_b_" for boolean etc                                                             |   |
  |   |  PACKAGE LEVEL VARIABLES: Use prefix  "g_" in front of the name of each package level variable,       |   |
  |   |                    including cursors. "g" stands for GLOBAL.                                          |   |
  |   |  PROCEDURES:       All stored procedure names must start with prefix "sp_". RTA_IN is just an         |   |
  |   |                    exception from the rule because it was created long before the coding standards.   |   |
  |   |  FUNCTIONS:        All stored function names must start with prefix "f_"                              |   |
  |   |  INPUT PARAMETERS: All input parameters to procs and funcs must start with prefix "p_"                |   |
  |   |                    All input parameters to cursors must start with prefix "c_"                        |   |
  |   |  PROCEDURE STARTS: The following comment lines are used to separate start of each procedure from      |   |
  |   |                    the rest of the code to enhance code readability and maintenance:                  |   |
  |   |                    ----------------------------------------                                           |   |
  |   |                    -- ********************************** --                                           |   |
  |   |                    ----------------------------------------                                           |   |
  |   |  PROCEDURE CALLS:  The following comment lines are used to separate procedure calls from              |   |
  |   |                    the rest of the code to enhance code readability and maintenance:                  |   |
  |   |                    ---------------------------                                                        |   |
  |   |                    -- *** [procedure_name]                                                            |   |
  |   |                    ---------------------------                                                        |   |
  |   |  CURSOR DECLARATION: The following comment lines are used to separate declaration of each cursor      |   |
  |   |                   from the rest of the code to enhance code readability and maintenance:              |   |
  |   |                   -------                                                                             |   |
  |   |                   -- * --                                                                             |   |
  |   |                   -------                                                                             |   |
  |   |  RETURN STATEMENTS: The following comment lines are used to separate "RETURN;" statements inside      |   |
  |   |                   the stored procedures from the rest of the code to enhance code readability         |   |
  |   |                   and maintenance:                                                                    |   |
  |   |                   ------------------------                                                            |   |
  |   |                   -- * EXIT PROCEDURE * --                                                            |   |
  |   |                   ------------------------                                                            |   |
  |   |  KEY WORDS:       All SQL and PL/SQL key words must be in UPPER case                                  |   |
  |   |  DATA ELEMENTS:   The names of all data elements must be in LOWER case                                |   |
  |   |                   Use underscore "_" between the words in the names for all data elements:            |   |
  |   |                   cursors, records, variables, procedure names... everything.                         |   |
  |   |  NOTE:                                                                                                |   |
  |   |  Please use every chance you get to standardize the code in this package using the above standards.   |   |
  |   |  If you are working an a specific procedure, take an extra time and standardize it.                   |   |
  |   x-------------------------------------------------------------------------------------------------------x   |
  |                                                                                                               |
  x---------------------------------------------------------------------------------------------------------------*/
  /*.....................................x
  . ORDER TYPES in IG_TRANSACTION table .
  . ----------------------------------- .
  . A     =   Activation                .
  . D     =   Deactivation              .
  . E     =   ESN Change                .
  . EPIR  =   External Port In Request  .
  . IPA   =   Int Port Approval         .
  . IPI   =   Internal Port In          .
  . IPS   =   Internal Port Status      .
  . MINC  =   MIN Change                .
  . R     =   Return                    .
  . S     =   Suspend                   .
  x.....................................*/
AS

--********************************************************************************
-- Procedure TO UPDATE TABLE_QUEUED_CBO_SERVICE
-- Procedure was created for CR33548
--********************************************************************************

-- CR33548 MOM Action Item  start
PROCEDURE SP_QUEUED_CBO_SERVICE
  (
    PI_ACTION_ITEM_ID IN TABLE_QUEUED_CBO_SERVICE.ACTION_ITEM_ID%TYPE,
    PI_STATUS IN TABLE_QUEUED_CBO_SERVICE.STATUS%TYPE,
    PO_COMMIT OUT BOOLEAN)  --CR35007 FIX
IS
  CURSOR CUR_QUEUED_CBO_SERVICE
  IS
    SELECT *
    FROM TABLE_QUEUED_CBO_SERVICE
    WHERE ACTION_ITEM_ID = PI_ACTION_ITEM_ID;

BEGIN
  PO_COMMIT := FALSE;
  FOR REC IN CUR_QUEUED_CBO_SERVICE

  LOOP
    UPDATE sa.TABLE_QUEUED_CBO_SERVICE
    SET STATUS  = PI_STATUS,
        PROCESSED_DATE = SYSDATE
    WHERE OBJID = REC.OBJID;

  PO_COMMIT := TRUE;

  END LOOP;

END SP_QUEUED_CBO_SERVICE;
-- CR33548 MOM Action Item  end


--********************************************************************************
-- Function to if ESN enrolled in a program and the program is ILD
-- Procedure was created for CR21157
--********************************************************************************
--
FUNCTION is_enrolled_esn_program_ild(
    p_esn table_part_inst.part_serial_no%TYPE)
  RETURN BOOLEAN
AS
  --
  l_b_enrolled_esn_program_ild BOOLEAN               := TRUE;
  l_cv_subprogram_name         CONSTANT VARCHAR2(61) := 'igate_in3.is_enrolled_esn_program_ild';
  l_i_error_code PLS_INTEGER                         := 0;
  l_v_error_message VARCHAR2(32767)                  := 'SUCCESS';
  l_v_position      VARCHAR2(32767)                  := l_cv_subprogram_name || '.1';
  l_v_note          VARCHAR2(32767)                  := 'Start executing ' || l_cv_subprogram_name;
  --
BEGIN
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_esn: ' || NVL(p_esn ,'Value is null'));
    --
  END IF;
  --
  l_v_position := l_cv_subprogram_name || '.2';
  l_v_note     := 'Retrieve is enrolled ESN program ILD';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  FOR rec_program_parameters IN
  (SELECT xpp.x_ild
  FROM x_program_enrolled xpe
  JOIN x_program_parameters xpp
  ON xpe.pgm_enroll2pgm_parameter = xpp.objid
  WHERE xpe.x_esn                 = p_esn
  AND xpe.x_enrollment_status     = 'ENROLLED'
  )
  LOOP
    --
    IF (rec_program_parameters.x_ild = 0) THEN
      --
      l_b_enrolled_esn_program_ild := FALSE;
      --
    ELSE
      --
      l_b_enrolled_esn_program_ild := TRUE;
      --
      EXIT;
      --
    END IF;
    --
  END LOOP;
  --
  l_v_position := l_cv_subprogram_name || '.3';
  l_v_note     := 'Returning is enrolled ESN program ILD';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  RETURN l_b_enrolled_esn_program_ild;
  --
EXCEPTION
WHEN OTHERS THEN
  --
  l_i_error_code    := SQLCODE;
  l_v_error_message := SQLERRM;
  --
  l_v_position := l_cv_subprogram_name || '.5';
  l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
    dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message ,'Value is null'));
    --
  END IF;
  --
  ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => p_esn ,p_program_name => l_v_position ,p_error_text => l_v_error_message);
  --
  RAISE;
  --
END is_enrolled_esn_program_ild;
--CR21157 End Kacosta 08/28/2012
--
--
--CR18553 Start KACOSTA 1/17/2011
--*******************************************************************************
-- Procedure to create SIM exchange cases for IG_TRANSACTIONS
--*******************************************************************************
--
PROCEDURE sp_ig_create_sim_exchange_case(
    p_error_code OUT INTEGER ,
    p_error_message OUT VARCHAR2 )
IS
  --
  CURSOR get_sim_exchange_trans_curs
  IS
    SELECT *
    FROM
      (SELECT
        /*+ USE_NL(igt tbt) */
        igt.* ,
        igt.rowid ,
        (SELECT NVL(txp.x_next_available ,0) x_next_available
        FROM table_x_carrier txc
        JOIN table_x_carrier_group xcg
        ON txc.carrier2carrier_group = xcg.objid
        JOIN table_x_parent txp
        ON xcg.x_carrier_group2x_parent = txp.objid
        WHERE txc.x_carrier_id          = igt.carrier_id
        AND UPPER(xcg.x_status)         = 'ACTIVE'
        AND UPPER(txp.x_status)         = 'ACTIVE'
        ) x_next_available ,
      (SELECT NVL(txp.x_no_inventory ,0) x_no_inventory
      FROM table_x_carrier txc
      JOIN table_x_carrier_group xcg
      ON txc.carrier2carrier_group = xcg.objid
      JOIN table_x_parent txp
      ON xcg.x_carrier_group2x_parent = txp.objid
      WHERE txc.x_carrier_id          = igt.carrier_id
      AND UPPER(xcg.x_status)         = 'ACTIVE'
      AND UPPER(txp.x_status)         = 'ACTIVE'
      ) x_no_inventory ,
      (SELECT tpn.x_technology
      FROM table_part_inst tpi
      JOIN table_mod_level tml
      ON tpi.n_part_inst2part_mod = tml.objid
      JOIN table_part_num tpn
      ON tml.part_info2part_num = tpn.objid
      WHERE tpi.part_serial_no  = igt.esn
      AND tpi.x_domain          = 'PHONES'
      ) x_technology
    FROM gw1.ig_transaction igt
    JOIN table_task tbt
    ON igt.action_item_id  = tbt.task_id
    WHERE igt.status       = 'E'
    AND igt.status_message = 'CREATE SIM EXCHANGE CASE'
      );
    --
    get_sim_exchange_trans_rec get_sim_exchange_trans_curs%ROWTYPE;
    --
    CURSOR get_task_objid_curs(c_v_action_item_id gw1.ig_transaction.action_item_id%TYPE)
    IS
      SELECT tbt.objid FROM table_task tbt WHERE tbt.task_id = c_v_action_item_id;
    --
    get_task_objid_rec get_task_objid_curs%ROWTYPE;
    --
    CURSOR check_sim_exchange_case_curs(c_v_esn table_case.x_esn%TYPE)
    IS
      SELECT tbc.objid case_objid ,
        tbc.id_number case_id_number
      FROM table_case tbc
      JOIN table_condition tcd
      ON tbc.case_state2condition = tcd.objid
      WHERE tbc.x_esn             = c_v_esn
      AND tbc.creation_time      >= TRUNC(SYSDATE) - 7
      AND tbc.x_case_type         = 'Technology Exchange'
      AND tbc.title               = 'SIM Card Exchange'
      AND tcd.s_title LIKE '%OPEN%';
    --
    check_sim_exchange_case_rec check_sim_exchange_case_curs%ROWTYPE;
    --
   /*  CURSOR get_repl_part_iccid_curs(c_v_iccid gw1.ig_transaction.iccid%TYPE)
    IS
      SELECT tpn_sim.part_number repl_part_sim
      FROM table_x_sim_inv xsi
      JOIN table_mod_level tml_sim
      ON xsi.x_sim_inv2part_mod = tml_sim.objid
      JOIN table_part_num tpn_sim
      ON tml_sim.part_info2part_num = tpn_sim.objid
      WHERE xsi.x_sim_serial_no     = c_v_iccid;
    --
    get_repl_part_iccid_rec get_repl_part_iccid_curs%ROWTYPE; */  --CR46319
    --
    CURSOR get_esn_contact_objid_curs(c_v_esn table_part_inst.part_serial_no%TYPE)
    IS
      SELECT x_part_inst2contact esn_contact_objid
      FROM table_part_inst tpi_esn
      WHERE tpi_esn.part_serial_no = c_v_esn
      AND tpi_esn.x_domain         = 'PHONES';
    --
    get_esn_contact_objid_rec get_esn_contact_objid_curs%ROWTYPE;
    --
    l_cn_user_objid      CONSTANT table_user.objid%TYPE := 268435556;
    l_cv_subprogram_name CONSTANT VARCHAR2(61)          := 'igate_in3.sp_ig_create_sim_exchange_case';
    l_i_error_code       INTEGER                        := 0;
    l_n_dummy_out        NUMBER;
    l_v_error_message    VARCHAR2(32767) := 'SUCCESS';
    l_v_position         VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note             VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_v_case_error_no    VARCHAR2(6);
    l_v_case_error_str   VARCHAR2(2000);
	repl_part_sim 				  VARCHAR2(100);--CR46319
    --CR20403 --comment 22798
    --   CURSOR ESN_BB_curs  (p_esn IN VARCHAR2) IS
    --   select bo.org_id, pc.name, pn.*
    --      from table_part_class pc, table_part_num pn , table_bus_org bo,  pc_params_view pv
    --           ,table_part_inst pi, table_mod_level ml
    --     where pn.part_num2part_class = pc.objid
    --       and pv.part_class = pc.name
    --      and  pi.part_serial_no = p_esn
    --      and pi.n_part_inst2part_mod = ml.objid
    --      AND   ml.part_info2part_num = pn.objid
    --      and pc.objid = pn.part_num2part_class
    --      and pn.part_num2bus_org = bo.objid
    --      and  pv.param_name = 'OPERATING_SYSTEM'
    --      and pv.param_value = 'BBOS';
    --   ESN_BB_rec ESN_BB_curs%ROWTYPE;
    op_msg    VARCHAR2(300):=' ';
    op_status VARCHAR2(30) := ' ';
    --CR20403
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Open get_sim_exchange_trans_curs to retrieve SIM exchange IG_TRANSACTION records';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF get_sim_exchange_trans_curs%ISOPEN THEN
      --
      CLOSE get_sim_exchange_trans_curs;
      --
    END IF;
    --
    OPEN get_sim_exchange_trans_curs;
    --
    LOOP
      --
      FETCH get_sim_exchange_trans_curs INTO get_sim_exchange_trans_rec;
      --
      EXIT
    WHEN get_sim_exchange_trans_curs%NOTFOUND;
      --
      BEGIN
        --
        get_task_objid_rec          := NULL;
        check_sim_exchange_case_rec := NULL;
       -- get_repl_part_iccid_rec     := NULL;
        get_esn_contact_objid_rec   := NULL;
        l_v_case_error_no           := '0';
        l_v_case_error_str          := NULL;
        --
        l_v_position := l_cv_subprogram_name || '.3';
        l_v_note     := 'Open get_task_objid_curs to retrieve task objid';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF get_task_objid_curs%ISOPEN THEN
          --
          CLOSE get_task_objid_curs;
          --
        END IF;
        --
        OPEN get_task_objid_curs(c_v_action_item_id => get_sim_exchange_trans_rec.action_item_id);
        FETCH get_task_objid_curs INTO get_task_objid_rec;
        CLOSE get_task_objid_curs;
        --
        l_v_position := l_cv_subprogram_name || '.4';
        l_v_note     := 'Check if the ICCID is not null and the technology is GSM';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF (get_sim_exchange_trans_rec.iccid IS NOT NULL AND get_sim_exchange_trans_rec.x_technology = 'GSM') THEN
          --
          l_v_position := l_cv_subprogram_name || '.5';
          l_v_note     := 'The ICCID is not null and the technology is GSM; call check_sim_exchange_case_curs to see if there is an open case';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF check_sim_exchange_case_curs%ISOPEN THEN
            --
            CLOSE check_sim_exchange_case_curs;
            --
          END IF;
          --
          OPEN check_sim_exchange_case_curs(c_v_esn => get_sim_exchange_trans_rec.esn);
          FETCH check_sim_exchange_case_curs INTO check_sim_exchange_case_rec;
          CLOSE check_sim_exchange_case_curs;
          --
          l_v_position := l_cv_subprogram_name || '.6';
          l_v_note     := 'Check to see if there is an open case';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF (check_sim_exchange_case_rec.case_id_number IS NULL) THEN
            --
            l_v_position := l_cv_subprogram_name || '.7';
            l_v_note     := 'There is no open case; check if the SIM part number is provided';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF (get_sim_exchange_trans_rec.expidite IS NOT NULL) THEN
              --
              l_v_position := l_cv_subprogram_name || '.8';
              l_v_note     := 'The SIM part number is provided';
              --
              IF l_b_debug THEN
                --
                dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
                --
              END IF;
              --
              --get_repl_part_iccid_rec.repl_part_sim := get_sim_exchange_trans_rec.expidite; CR46319
			  repl_part_sim:= get_sim_exchange_trans_rec.expidite;
              --
            ELSE
              --
              l_v_position := l_cv_subprogram_name || '.9';
              l_v_note     := 'No, SIM part number is not provided; determined SIM part number based on the ICCID value';
              --
              IF l_b_debug THEN
                --
                dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
                --
              END IF;
              --
              /* IF get_repl_part_iccid_curs%ISOPEN THEN
                --
                CLOSE get_repl_part_iccid_curs;
                --
              END IF;
              --
              OPEN get_repl_part_iccid_curs(c_v_iccid => get_sim_exchange_trans_rec.iccid);
              FETCH get_repl_part_iccid_curs INTO get_repl_part_iccid_rec;
              CLOSE get_repl_part_iccid_curs; */
			  sa.nap_SERVICE_pkg.get_list(get_sim_exchange_trans_rec.ZIP_CODE,
                              get_sim_exchange_trans_rec.ESN,
                              NULL,
                              NULL,
                              NULL,
                              NULL);
					  IF nap_SERVICE_pkg.big_tab.COUNT >0 then

						  DBMS_OUTPUT.put_line('get_sim_exchange_trans_rec.CARRIER_ID:'||get_sim_exchange_trans_rec.CARRIER_ID);
						  FOR i in nap_SERVICE_pkg.big_tab.FIRST..nap_SERVICE_pkg.big_tab.LAST loop
							IF    get_sim_exchange_trans_rec.CARRIER_ID = nap_SERVICE_pkg.big_tab(i).carrier_info.x_carrier_id
							   AND NVL(nap_SERVICE_pkg.big_tab(i).carrier_info.sim_profile,'NA') != 'NA'
							   AND nap_SERVICE_pkg.big_tab(i).carrier_info.shippable = 'Y'
							   THEN
							 -- p_out_msg := 'SIM Exchange';
							 -- p_repl_part := NULL;
							 -- p_repl_tech := c_old_esn_info_rec.x_technology;
							  repl_part_sim := nap_SERVICE_pkg.big_tab(i).carrier_info.sim_profile;
							 -- p_pref_carrier := nap_SERVICE_pkg.big_tab(i).carrier_info.x_carrier_id;
							  --p_pref_parent := nap_SERVICE_pkg.big_tab(i).carrier_info.x_parent_id;
							  --RETURN;
							END if;
							END LOOP;
					  END IF;
              --
            END IF;
            --
            l_v_position := l_cv_subprogram_name || '.10';
            l_v_note     := 'Was the SIM part number provided or determined';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            --IF (get_repl_part_iccid_rec.repl_part_sim IS NOT NULL) THEN
            IF repl_part_sim IS NOT NULL THEN --CR46319
              --
              l_v_position := l_cv_subprogram_name || '.11';
              l_v_note     := 'Yes, the SIM part number was provided or determined; retrieve ESN contact information';
              --
              IF l_b_debug THEN
                --
                dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
                --
              END IF;
              --
              IF get_esn_contact_objid_curs%ISOPEN THEN
                --
                CLOSE get_esn_contact_objid_curs;
                --
              END IF;
              --
              OPEN get_esn_contact_objid_curs(c_v_esn => get_sim_exchange_trans_rec.esn);
              FETCH get_esn_contact_objid_curs INTO get_esn_contact_objid_rec;
              CLOSE get_esn_contact_objid_curs;
              --
              l_v_position := l_cv_subprogram_name || '.12';
              l_v_note     := 'Create case';
              --
              IF l_b_debug THEN
                --
                dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
                --
              END IF;
              --
              clarify_case_pkg.create_case(p_title => 'SIM Card Exchange' ,p_case_type => 'Technology Exchange' ,p_status => 'Pending' ,
	      p_priority => 'Low' ,p_issue => 'Expired SIM' ,p_source => 'SP_IG_CREATE_SIM_EXCHANGE_CASE' ,
	      p_point_contact => 'IGATE_IN3' ,p_creation_time => SYSDATE ,p_task_objid => 0 ,p_contact_objid => get_esn_contact_objid_rec.esn_contact_objid ,
	      p_user_objid => l_cn_user_objid ,p_esn => get_sim_exchange_trans_rec.esn ,p_phone_num => NULL ,
	      p_first_name => NULL ,p_last_name => NULL ,p_e_mail => NULL ,p_delivery_type => NULL ,
	      p_address => NULL ,p_city => NULL ,p_state => NULL ,p_zipcode => NULL ,p_repl_units => 0 ,
                                           p_fraud_objid => 0 ,p_case_detail => NULL ,p_part_request => repl_part_sim , --get_repl_part_iccid_rec.repl_part_sim ,--CR46319
	      p_id_number => check_sim_exchange_case_rec.case_id_number ,p_case_objid => check_sim_exchange_case_rec.case_objid ,
	      p_error_no => l_v_case_error_no ,p_error_str => l_v_case_error_str);
              --
              IF (l_v_case_error_no = '0') THEN
                --
                l_v_position := l_cv_subprogram_name || '.13';
                l_v_note     := 'Update the case status';
                --
                IF l_b_debug THEN
                  --
                  dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
                  --
                END IF;
                --
                sa.clarify_case_pkg.update_status(p_case_objid => check_sim_exchange_case_rec.case_objid ,p_user_objid => l_cn_user_objid ,p_new_status => 'BadAddress' ,p_status_notes => 'Need address update' ,p_error_no => l_v_case_error_no ,p_error_str => l_v_case_error_str);
                --
                IF (l_v_case_error_no = '0') THEN
                  --
                  l_v_position := l_cv_subprogram_name || '.14';
                  l_v_note     := 'Displatch case';
                  --
                  IF l_b_debug THEN
                    --
                    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
                    --
                  END IF;
                  --
                  sa.clarify_case_pkg.dispatch_case(p_case_objid => check_sim_exchange_case_rec.case_objid ,p_user_objid => l_cn_user_objid ,p_queue_name => 'Warehouse Exception' ,p_error_no => l_v_case_error_no ,p_error_str => l_v_case_error_str);
                  --
                  IF (l_v_case_error_no = '0') THEN
                    --
                    l_v_case_error_str := l_v_note || ': ' || l_v_case_error_str;
                    --
                  END IF;
                  --
                ELSE
                  --
                  l_v_case_error_str := l_v_note || ': ' || l_v_case_error_str;
                  --
                END IF;
                --
              ELSE
                --
                l_v_case_error_str := l_v_note || ': ' || l_v_case_error_str;
                --
              END IF;
              --
            END IF;
            --
          END IF;
          --
        ELSE
          --
          l_v_position := l_cv_subprogram_name || '.15';
          l_v_note     := 'Either the ICCID is null or the technology is not GSM';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          l_v_case_error_no := '1';
          --
          IF (get_sim_exchange_trans_rec.x_technology = 'GSM') THEN
            --
            l_v_case_error_str := 'GSM ESN IG_TRANSACTION record is missing ICCID/SIM value';
            --
          ELSE
            --
            l_v_case_error_str := 'Cannot create SIM EXCHANGE case for non-GSM ESN';
            --
          END IF;
          --
        END IF;
        --
        IF (check_sim_exchange_case_rec.case_id_number IS NOT NULL) THEN
          --
          l_v_position := l_cv_subprogram_name || '.16';
          l_v_note     := 'A case was opened or an open case found; close the task and update the status of the IG_TRANSACTION record to success';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          igate.sp_close_action_item(p_task_objid => get_task_objid_rec.objid ,p_status => 0 ,p_dummy_out => l_n_dummy_out);
          --
          UPDATE gw1.ig_transaction
          SET status       = 'S' ,
            status_message = 'SIM exchange case created; case ID: '
            || check_sim_exchange_case_rec.case_id_number ,
            new_msid_flag      = 'PROCESSED' ,
            application_system = 'IG_RWK'
          WHERE ROWID          = get_sim_exchange_trans_rec.rowid;
          --CR48373
          DELETE FROM gw1.ig_transaction_features
          WHERE  transaction_id = get_sim_exchange_trans_rec.transaction_id;
          -- CR20403 RIM Integration CDMA
          -- ST CR20403
          --   OPEN ESN_BB_curs(get_sim_exchange_trans_rec.esn);
          --   FETCH ESN_BB_curs
          --   INTO ESN_BB_rec;
          -- IF ESN_BB_curs%FOUND THEN
          IF sa.RIM_SERVICE_PKG.IF_BB_ESN(GET_SIM_EXCHANGE_TRANS_REC.ESN) = 'TRUE' THEN
            dbms_output.put_line('Insert ig_transaction_RIM for SIM excahnge case created ');
            sa.Rim_service_pkg.sp_create_rim_action_item(get_sim_exchange_trans_rec.action_item_id, op_msg, op_status); --action_item_id (gw1.ig_transaction)
            IF op_status = 'S' THEN
              dbms_output.put_line('Inserted ig_transaction_RIM succesful');
            ELSE
              dbms_output.put_line('fail process sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM');
            END IF;
          END IF;
          --    close ESN_BB_curs;
          COMMIT;
          -- CR20403 RIM Integration CDMA
          --
        ELSE
          --
          l_v_position := l_cv_subprogram_name || '.17';
          l_v_note     := 'A case was not opened and an open case was not found; log an error to IG_FAILED_LOG table, log an erro to error table and update the status of the IG_TRANSACTION record to failed';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF (l_v_case_error_no = '0') THEN
            --
            l_v_case_error_str := 'Failed to create SIM exchange case for ESN ' || get_sim_exchange_trans_rec.esn;
            --
          END IF;
          --
          toss_util_pkg.insert_error_tab_proc(ip_action => 'Create SIM exchange case' ,ip_key => get_sim_exchange_trans_rec.action_item_id ,ip_program_name => l_cv_subprogram_name ,ip_error_text => l_v_case_error_str);
          --
          INSERT
          INTO gw1.ig_failed_log
            (
              action_item_id ,
              carrier_id ,
              order_type ,
              MIN ,
              esn ,
              esn_hex ,
              old_esn ,
              old_esn_hex ,
              pin ,
              phone_manf ,
              end_user ,
              account_num ,
              market_code ,
              rate_plan ,
              ld_provider ,
              sequence_num ,
              dealer_code ,
              transmission_method ,
              fax_num ,
              online_num ,
              email ,
              network_login ,
              network_password ,
              system_login ,
              system_password ,
              template ,
              com_port ,
              status ,
              status_message ,
              trans_prof_key ,
              q_transaction ,
              fax_num2 ,
              creation_date ,
              update_date ,
              blackout_wait ,
              transaction_id ,
              technology_flag ,
              voice_mail ,
              voice_mail_package ,
              caller_id ,
              caller_id_package ,
              call_waiting ,
              call_waiting_package ,
              digital_feature_code ,
              state_field ,
              zip_code ,
              msid ,
              new_msid_flag ,
              sms ,
              sms_package ,
              iccid ,
              old_min ,
              digital_feature ,
              ota_type ,
              rate_center_no ,
              application_system ,
              subscriber_update ,
              download_date ,
              prl_number ,
              amount ,
              balance ,
              LANGUAGE ,
              exp_date ,
              logged_date ,
              logged_by
              --cr 22467
              ,
              x_mpn ,
              x_mpn_code ,
              x_pool_name,
              X_MAKE,--CR37839
              X_MODE,--CR37839
              X_MODEL,--CR37839
              CARRIER_INITIAL_TRANS_TIME,
              CARRIER_END_TRANS_TIME
              --cr 22467
            )
            VALUES
            (
              get_sim_exchange_trans_rec.action_item_id ,
              get_sim_exchange_trans_rec.carrier_id ,
              get_sim_exchange_trans_rec.order_type ,
              get_sim_exchange_trans_rec.min ,
              get_sim_exchange_trans_rec.esn ,
              get_sim_exchange_trans_rec.esn_hex ,
              get_sim_exchange_trans_rec.old_esn ,
              get_sim_exchange_trans_rec.old_esn_hex ,
              get_sim_exchange_trans_rec.pin ,
              get_sim_exchange_trans_rec.phone_manf ,
              get_sim_exchange_trans_rec.end_user ,
              get_sim_exchange_trans_rec.account_num ,
              get_sim_exchange_trans_rec.market_code ,
              get_sim_exchange_trans_rec.rate_plan ,
              get_sim_exchange_trans_rec.ld_provider ,
              get_sim_exchange_trans_rec.sequence_num ,
              get_sim_exchange_trans_rec.dealer_code ,
              get_sim_exchange_trans_rec.transmission_method ,
              get_sim_exchange_trans_rec.fax_num ,
              get_sim_exchange_trans_rec.online_num ,
              get_sim_exchange_trans_rec.email ,
              get_sim_exchange_trans_rec.network_login ,
              get_sim_exchange_trans_rec.network_password ,
              get_sim_exchange_trans_rec.system_login ,
              get_sim_exchange_trans_rec.system_password ,
              get_sim_exchange_trans_rec.template ,
              get_sim_exchange_trans_rec.com_port ,
              get_sim_exchange_trans_rec.status ,
              get_sim_exchange_trans_rec.status_message ,
              get_sim_exchange_trans_rec.trans_prof_key ,
              get_sim_exchange_trans_rec.q_transaction ,
              get_sim_exchange_trans_rec.fax_num2 ,
              get_sim_exchange_trans_rec.creation_date ,
              get_sim_exchange_trans_rec.update_date ,
              get_sim_exchange_trans_rec.blackout_wait ,
              get_sim_exchange_trans_rec.transaction_id ,
              get_sim_exchange_trans_rec.technology_flag ,
              get_sim_exchange_trans_rec.voice_mail ,
              get_sim_exchange_trans_rec.voice_mail_package ,
              get_sim_exchange_trans_rec.caller_id ,
              get_sim_exchange_trans_rec.caller_id_package ,
              get_sim_exchange_trans_rec.call_waiting ,
              get_sim_exchange_trans_rec.call_waiting_package ,
              get_sim_exchange_trans_rec.digital_feature_code ,
              get_sim_exchange_trans_rec.state_field ,
              get_sim_exchange_trans_rec.zip_code ,
              get_sim_exchange_trans_rec.msid ,
              get_sim_exchange_trans_rec.new_msid_flag ,
              get_sim_exchange_trans_rec.sms ,
              get_sim_exchange_trans_rec.sms_package ,
              get_sim_exchange_trans_rec.iccid ,
              get_sim_exchange_trans_rec.old_min ,
              get_sim_exchange_trans_rec.digital_feature ,
              get_sim_exchange_trans_rec.ota_type ,
              get_sim_exchange_trans_rec.rate_center_no ,
              get_sim_exchange_trans_rec.application_system ,
              get_sim_exchange_trans_rec.subscriber_update ,
              get_sim_exchange_trans_rec.download_date ,
              get_sim_exchange_trans_rec.prl_number ,
              get_sim_exchange_trans_rec.amount ,
              get_sim_exchange_trans_rec.balance ,
              get_sim_exchange_trans_rec.language ,
              get_sim_exchange_trans_rec.exp_date ,
              SYSDATE ,
              l_cv_subprogram_name
              --cr 22467
              ,
              get_sim_exchange_trans_rec.x_mpn ,
              get_sim_exchange_trans_rec.x_mpn_code ,
              get_sim_exchange_trans_rec.x_pool_name,
              --cr 22467
               get_sim_exchange_trans_rec.X_MAKE,--CR37839
              get_sim_exchange_trans_rec.X_MODE,--CR37839
              get_sim_exchange_trans_rec.X_MODEL,
              get_sim_exchange_trans_rec.CARRIER_INITIAL_TRANS_TIME,--CR37839
              get_sim_exchange_trans_rec.CARRIER_END_TRANS_TIME
            );
          --
          UPDATE gw1.ig_transaction
          SET status  = 'F'
          WHERE ROWID = get_sim_exchange_trans_rec.rowid;
          --
        END IF;
        --
      EXCEPTION
      WHEN OTHERS THEN
        --
        ROLLBACK;
        --
        ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => get_sim_exchange_trans_rec.action_item_id ,p_program_name => l_v_position ,p_error_text => SQLERRM);
        --
        IF get_sim_exchange_trans_curs%ISOPEN THEN
          --
          CLOSE get_sim_exchange_trans_curs;
          --
        END IF;
        --
        IF get_task_objid_curs%ISOPEN THEN
          --
          CLOSE get_task_objid_curs;
          --
        END IF;
        --
        IF check_sim_exchange_case_curs%ISOPEN THEN
          --
          CLOSE check_sim_exchange_case_curs;
          --
        END IF;
        --
      --  IF get_repl_part_iccid_curs%ISOPEN THEN
          --
      --    CLOSE get_repl_part_iccid_curs;
          --
     --   END IF; --CR46319
        --
        IF get_esn_contact_objid_curs%ISOPEN THEN
          --
          CLOSE get_esn_contact_objid_curs;
          --
        END IF;
        --
      END;
      --
      COMMIT;
      --
    END LOOP;
    --
    CLOSE get_sim_exchange_trans_curs;
    --
    l_v_position := l_cv_subprogram_name || '.18';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message ,'Value is null'));
      --
    END IF;
    --
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
  WHEN OTHERS THEN
    --
    p_error_code    := SQLCODE;
    p_error_message := SQLERRM;
    --
    ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => get_sim_exchange_trans_rec.action_item_id ,p_program_name => l_v_position ,p_error_text => p_error_message);
    --
    l_v_position := l_cv_subprogram_name || '.19';
    l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code) ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(p_error_message ,'Value is null'));
      --
    END IF;
    --
    IF get_sim_exchange_trans_curs%ISOPEN THEN
      --
      CLOSE get_sim_exchange_trans_curs;
      --
    END IF;
    --
    IF get_task_objid_curs%ISOPEN THEN
      --
      CLOSE get_task_objid_curs;
      --
    END IF;
    --
    IF check_sim_exchange_case_curs%ISOPEN THEN
      --
      CLOSE check_sim_exchange_case_curs;
      --
    END IF;
--    --CR46319
--    IF get_repl_part_iccid_curs%ISOPEN THEN
--      --
--      CLOSE get_repl_part_iccid_curs;
--      --
--    END IF;
    --
    IF get_esn_contact_objid_curs%ISOPEN THEN
      --
      CLOSE get_esn_contact_objid_curs;
      --
    END IF;
    --
  END sp_ig_create_sim_exchange_case;
  --CR18553 End KACOSTA 1/16/2011

PROCEDURE rta_in(
    p_div IN NUMBER DEFAULT 1 ,
    p_rem IN NUMBER DEFAULT 0 )
IS
  --
  lv_ild VARCHAR2(30) := NULL;
  LV_ERR_NUM                 NUMBER(10);
  LV_ERR_STRING              VARCHAR2(2000);
  LV_X_ILD_OBJID         sa.TABLE_X_ILD_TRANSACTION.OBJID%TYPE;
  lb_commit BOOLEAN;     --CR35007 FIX

  -- Super Carrier Changes (CR35396, CR29586)
  l_error_code    NUMBER;
  l_error_msg     VARCHAR2(1000);


  --  CR43254
  fota_error_code    NUMBER;
  fota_error_msg     VARCHAR2(1000);
  --  CR43254

  --CR 47564 WFM
  gt sa.group_type := sa.group_type();
  g sa.group_type  := sa.group_type();
  --CR 47564 WF

  -- CR49915 Lifeline for other Brands - WFM
  o_ll_minc_err 	VARCHAR2(1000);
  o_ll_minc_err_msg VARCHAR2(1000);
  o_ll_red_err 		VARCHAR2(1000);
  o_ll_red_err_msg  VARCHAR2(1000);
  o_ll_esnc_err 	VARCHAR2(1000);
  o_ll_esnc_err_msg VARCHAR2(1000);
   -- CR49915 Lifeline for other Brands - WFM

	-- CR57251
	r_service_plan_rec sa.x_service_plan%rowtype;
	NT_35_40_PROMO_ILD_FLAG VARCHAR2(2);
	IS_PROMO_MIN	VARCHAR2(2);
	PROMO_SPOBJID varchar2(20);
	l_PROMO_COS	varchar2(20);
	IS_AR_ENROLLED varchar2(2);
	IS_PROMO_ESN VARCHAR2(2);
	NT_35_40_PROMO_REACT VARCHAR2(2);
	IS_PROMO_REACT_MIN VARCHAR2(2);
	LV_ILD_PRFX VARCHAR2(2);
	-- END CR57251

  -- TFDM CR35211 changes
  o_response      VARCHAR2(1000);
  ipl ig_pcrf_log_type := ig_pcrf_log_type();
  ip  ig_pcrf_log_type := ig_pcrf_log_type();
  -----------------------
  ------- 20402 Huawei H226C - HomeFone (Master)END 1
  -----------------------
  CURSOR ig_trans_curs
  IS
    SELECT *
    FROM
      (SELECT
        /*+ USE_NL(a t) */
        a.* ,
        a.rowid ,
        (SELECT NVL(p.x_next_available ,0) x_next_available
        FROM table_x_parent p ,
          table_x_carrier_group cg ,
          table_x_carrier c
        WHERE p.objid          = cg.x_carrier_group2x_parent
        AND UPPER(p.x_status)  = 'ACTIVE'
        AND cg.objid           = c.carrier2carrier_group
        AND UPPER(cg.x_status) = 'ACTIVE'
        AND c.x_carrier_id     = a.carrier_id
        ) x_next_available ,
      (SELECT NVL(p.x_no_inventory ,0) x_no_inventory ----CR7579 (Claro Begin)
      FROM table_x_parent p ,
        table_x_carrier_group cg ,
        table_x_carrier c
      WHERE p.objid          = cg.x_carrier_group2x_parent
      AND UPPER(p.x_status)  = 'ACTIVE'
      AND cg.objid           = c.carrier2carrier_group
      AND UPPER(cg.x_status) = 'ACTIVE'
      AND c.x_carrier_id     = a.carrier_id
      ) x_no_inventory , --CR7579 (Claro End)
      --cwl 2/3/2012 --CR15690
      t.x_task2x_call_trans ,
      (SELECT bo.s_org_id
      FROM table_bus_org bo ,
        table_part_num pn ,
        table_mod_level ml ,
        table_part_inst pi
      WHERE bo.objid        = part_num2bus_org
      AND pn.objid          = ml.part_info2part_num
      AND ml.objid          = pi.n_part_inst2part_mod
      AND pi.part_serial_no = a.esn
      AND pi.x_domain       = 'PHONES'
      ) bus_org ,
      --cwl 2/3/2012 --CR15690
      (
      SELECT pn.x_technology
      FROM table_part_num pn ,
        table_mod_level ml ,
        table_part_inst pi
      WHERE pn.objid        = ml.part_info2part_num
      AND ml.objid          = pi.n_part_inst2part_mod
      AND pi.part_serial_no = a.esn
      AND pi.x_domain       = 'PHONES'
      ) x_technology
    FROM table_task t ,
      gw1.ig_transaction a
    WHERE t.task_id                  = a.action_item_id
    AND status                      IN ('E' ,'W')
    AND MOD(a.transaction_id ,p_div) = p_rem
    --AND order_type NOT              IN ('BI' ,'CR' ,'CRU' ,'EU' ,'DB' ,'PCR') -- CR13980 PM 09/28/2010
    AND order_type NOT              IN (SELECT x_ig_order_type FROM x_ig_order_type WHERE process_igate_in3_flag = 'N') --CR54061
    --CR52803 exclude new order type safelink benefit similar to CR-Credit
    AND NOT EXISTS (SELECT 1 FROM sa.x_ig_order_type iot WHERE a.order_type = iot.x_ig_order_type AND iot.safelink_batch_flag='Y')
    AND NOT (a.status                = 'E'
    AND a.status_message             = 'CREATE SIM EXCHANGE CASE')
      --CR18553 End KACOSTA 1/17/2011
      );
    hold_msid_for_cdma_next_avail VARCHAR2(30) := NULL;
    CURSOR ig_wi_detail_curs(c_transaction_id IN NUMBER)
    IS
      SELECT * FROM gw1.ig_wi_detail WHERE wi_id = c_transaction_id;
    ig_wi_detail_rec ig_wi_detail_curs%ROWTYPE;
    --
    CURSOR task_curs(c_task_id IN VARCHAR2)
    IS
      SELECT * FROM table_task WHERE task_id = c_task_id;
    task_rec task_curs%ROWTYPE;
    --
    CURSOR user_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_user WHERE objid = c_objid;
    user_rec user_curs%ROWTYPE;
    --
    CURSOR call_trans_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_x_call_trans WHERE objid = c_objid;
    call_trans_rec call_trans_curs%ROWTYPE;
    --
    -- OTA
    --
    CURSOR ota_call_trans_curs(c_part_serial_no IN VARCHAR2)
    IS
      SELECT *
      FROM table_x_call_trans
      WHERE x_service_id = c_part_serial_no
      ORDER BY x_transact_date DESC;
    ota_call_trans_rec ota_call_trans_curs%ROWTYPE;
    --
    CURSOR condition_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_condition WHERE objid = c_objid AND title LIKE 'Closed%';
    condition_rec condition_curs%ROWTYPE;
    --
    CURSOR queue_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_queue WHERE objid = c_objid AND title LIKE 'Intergate%';
    queue_rec queue_curs%ROWTYPE;
    --
    CURSOR order_type_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_x_order_type WHERE objid = c_objid;
    order_type_rec order_type_curs%ROWTYPE;
    --
    CURSOR trans_profile_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_x_trans_profile WHERE objid = c_objid;
    trans_profile_rec trans_profile_curs%ROWTYPE;
    --
    CURSOR site_part_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_site_part WHERE objid = c_objid;
    site_part_rec site_part_curs%ROWTYPE;
    -- CR5780
    CURSOR site_part_x_min_curs(c_esn IN VARCHAR2)
    IS
      SELECT *
      FROM table_site_part
      WHERE x_service_id = c_esn
      AND part_status
        || '' = 'Active';
    site_part_x_min_rec site_part_x_min_curs%ROWTYPE;
    --
    CURSOR part_num_curs(c_objid IN NUMBER)
    IS
      SELECT pn.*
      FROM table_part_num pn ,
        table_mod_level ml
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid   = c_objid;
    part_num_rec part_num_curs%ROWTYPE;
    --
    CURSOR carrier_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_x_carrier WHERE objid = c_objid;
    carrier_rec carrier_curs%ROWTYPE;
    --
    CURSOR retail_esn_curs
    IS
      SELECT ge.objid
      FROM table_gbst_elm ge ,
        table_gbst_lst gl
      WHERE ge.gbst_elm2gbst_lst = gl.objid
      AND ge.title               = 'Failed - Retail ESN'
      AND gl.title               = 'Closed Action Item';
    retail_esn_rec retail_esn_curs%ROWTYPE;
    --
    CURSOR failed_open_curs
    IS
      SELECT ge.objid
      FROM table_gbst_elm ge ,
        table_gbst_lst gl
      WHERE ge.gbst_elm2gbst_lst = gl.objid
      AND ge.title               = 'Failed - Open'
      AND gl.title               = 'Open Action Item';
    failed_open_rec failed_open_curs%ROWTYPE;
    --
    CURSOR queued_curs
    IS
      SELECT ge.objid
      FROM table_gbst_elm ge ,
        table_gbst_lst gl
      WHERE ge.gbst_elm2gbst_lst = gl.objid
      AND ge.title               = 'Queued'
      AND gl.title               = 'Open Action Item';
    queued_rec queued_curs%ROWTYPE;
    --
    CURSOR failed_ntn_curs
    IS
      SELECT * FROM table_x_code_table WHERE x_code_name = 'FAILED NTN';
    failed_ntn_rec failed_ntn_curs%ROWTYPE;
    --
    CURSOR topp_err_curs ( c_carrier_objid IN NUMBER ,c_message IN VARCHAR2 )
    IS
      SELECT tec.*
      FROM table_x_topp_err_codes tec ,
        table_x_carrier_err_codes cec
      WHERE tec.objid = cec.ccodes2x_topp_err_codes
      AND cec.x_code_name LIKE '%'
        || c_message
        || '%'
      AND cec.x_car_er2x_carrier = c_carrier_objid;
    topp_err_rec topp_err_curs%ROWTYPE;
    --
    CURSOR gen_err_curs
    IS
      SELECT tec.*
      FROM table_x_topp_err_codes tec
      WHERE tec.x_code_name = 'System Malfunction';
    gen_err_rec gen_err_curs%ROWTYPE;
    --
    CURSOR min_curs(c_min IN VARCHAR2)
    IS
      SELECT a.* ,
        a.rowid
      FROM table_part_inst a
      WHERE part_serial_no = c_min
      AND x_domain         = 'LINES'; --CR15983
    min_rec min_curs%ROWTYPE;
    --CR3153 - T-Mobile begin
    CURSOR part_inst_curs ( c_min VARCHAR2 ,c_min2 VARCHAR2 )
    IS
      SELECT line.* ,
        1 col1
      FROM table_part_inst line
      WHERE 1                 = 1
      AND line.x_domain       = 'LINES' --CR15983
      AND line.part_serial_no = c_min
    UNION
    SELECT line.* ,
      2 col1
    FROM table_part_inst line
    WHERE 1                 = 1
    AND line.x_domain       = 'LINES' --CR15983
    AND line.part_serial_no = c_min2
    ORDER BY col1 ASC;
    part_inst_rec part_inst_curs%ROWTYPE;
    --CR3440 End
    CURSOR code_curs(c_code_number VARCHAR)
    IS
      SELECT * FROM table_x_code_table WHERE x_code_number = c_code_number;
    code_rec code_curs%ROWTYPE;
    --CR 3153 - T-Mobile end
    --
    -- 01/17/03
    --
    -- Start CR3918 Mchinta ver1.20 06/15/2005
    CURSOR case_curs(case_objid IN NUMBER)
    IS
      SELECT * FROM table_case WHERE objid = case_objid;
    case_rec case_curs%ROWTYPE;
    -- End CR3918 Mchinta ver1.20 06/15/2005
    CURSOR opened_case_curs ( c_esn VARCHAR2 ,c_min VARCHAR2 )
    IS
      SELECT c.rowid ,
        c.id_number ,
        c.title ,
        c.x_case_type ,
        c.case_history,
        c.case_originator2user,
        c.OBJID
      FROM table_condition cd ,
        table_case c
      WHERE cd.title LIKE 'Open%'
      AND c.case_state2condition = cd.objid
      AND c.x_esn                = c_esn
      AND c.x_min                = c_min;
    opened_case_rec opened_case_curs%ROWTYPE;
    CURSOR port_in_case_curs ( c_esn VARCHAR2 ,c_min VARCHAR2 )
    IS
      SELECT c.rowid ,
        c.objid ,
        c.case_originator2user ,
        c.id_number ,
        c.title ,
        c.x_case_type ,
        c.case_history
      FROM table_case c ,
        table_x_case_detail cd
      WHERE c.x_esn      = c_esn
      AND c.x_case_type  = 'Port In'
      AND c.title       IN ('Internal' ,'Internal Cross Company')
      AND cd.detail2case = c.objid
      AND cd.x_name      = 'CURRENT_MIN'
      AND cd.x_value     = c_min;
    port_in_case_rec port_in_case_curs%ROWTYPE;
    l_status VARCHAR2(10);
    l_msg    VARCHAR2(200);
    --end 01/17/03
    --CR3327 GP
    CURSOR parent_curs(c_objid NUMBER)
    IS
      SELECT a.*
      FROM table_x_parent a ,
        table_x_carrier_group b ,
        table_x_carrier c
      WHERE a.objid = b.x_carrier_group2x_parent
      AND b.objid   = c.carrier2carrier_group
      AND c.objid   = c_objid;
    parent_rec parent_curs%ROWTYPE;
    -- CR 5008
    CURSOR min_still_exists_curs(c_min_objid IN NUMBER)
    IS
      SELECT 1 hold FROM table_part_inst WHERE objid = c_min_objid;
    min_still_exists_rec min_still_exists_curs%ROWTYPE;
    -- End CR 5008
    -- Cingular Next Available Project:
    -- Get Closed case to reopen it
    CURSOR closed_case_cur(c_esn VARCHAR2)
    IS
      SELECT table_case.objid case_objid
      FROM table_case ,
        table_condition
      WHERE table_condition.objid = table_case.case_state2condition
      AND table_condition.s_title LIKE 'CLOSE%'
      AND table_case.title       = 'No Line Available'
      AND table_case.x_case_type = 'Line Management'
      AND table_case.x_esn       = c_esn;
    closed_case_rec closed_case_cur%ROWTYPE;
    -- Cingular Next Available Project:
    -- This error message will eventually be populated by igate.reopen_case_proc
    c_reopen_case_err_msg VARCHAR2(250);
    -----------------------------------------------------------
    -- Process status messages received from TMOBILE carrier --
    -- CR4947 START                                          --
    -----------------------------------------------------------
    l_b_tmobile_msg_processed BOOLEAN := FALSE;
    -----------------------------------------------------------
    -- CR4947 END                                            --
    -----------------------------------------------------------
    --Next Available
    CURSOR c_is_npanxx_exist ( ip_msid IN VARCHAR2 ,ip_zip IN VARCHAR2 )
    IS
      SELECT 'X'
      FROM carrierzones a ,
        npanxx2carrierzones b
      WHERE b.nxx = SUBSTR(ip_msid ,4 ,3)
        -- This is from ig_transaction.msid
      AND b.npa = SUBSTR(ip_msid ,1 ,3)
        -- This is from ig_transaction.msid
      AND a.st   = b.state
      AND a.zone = b.zone
      AND a.zip  = ip_zip;
    -- This is from ig_transaction.zip_code
    c_is_npanxx_exist_rec c_is_npanxx_exist%ROWTYPE;
    CURSOR c_get_npa_nxx(ip_zip IN VARCHAR2)
    IS
      SELECT DISTINCT b.*
      FROM carrierzones a ,
        npanxx2carrierzones b
      WHERE a.st = b.state
      AND a.zone = b.zone
      AND a.zip  = ip_zip
        -- This is from ig_transaction.zip_code
      AND b.carrier_name = 'CINGULAR WIRELESS'
      AND ROWNUM         < 2;
    c_get_npa_nxx_rec c_get_npa_nxx%ROWTYPE;
    --Next Available
    --CR4902
    CURSOR get_param_curs
    IS
      SELECT x_param_value
      FROM table_x_parameters
      WHERE x_param_name = 'CLOSE_CASE_FAILURE';
    ---------------
    -- ST_BUNDLE_II -- to check if the esn is ST for EPIR, IPI
    ---------------
    CURSOR check_st_esn_curs ( c_esn IN VARCHAR2 ,c_param_name IN VARCHAR2 , ---CR13085
      c_param_value                  IN VARCHAR2 )
    IS
      SELECT pc.name ,
        pcv.x_param_value ,
        pn.x_technology ,
        pi.*
      FROM table_part_num pn ,
        table_part_class pc ,
        table_x_part_class_params pcp ,
        table_x_part_class_values pcv ,
        table_part_inst pi ,
        table_mod_level ml
      WHERE 1                     = 1
      AND pcp.x_param_name        = c_param_name
      AND pc.objid                = pcv.value2part_class
      AND pcp.objid               = pcv.value2class_param
      AND pc.objid                = pn.part_num2part_class
      AND pn.domain               = 'PHONES'
      AND pn.part_num2part_class  = pc.objid
      AND ml.part_info2part_num   = pn.objid
      AND pi.n_part_inst2part_mod = ml.objid
      AND pcv.x_param_value       = c_param_value
      AND pi.part_serial_no       = c_esn;
    check_st_esn_rec check_st_esn_curs%ROWTYPE;
    --------------------------------------------------------------------------------
    --ST_BUNDLE_II_A
    --ST_BUNDLE_III
    -- **********************************************************************
    -- CR20451 | CR20854: Add TELCEL Brand   mod 1 BEGIN
    -- **********************************************************************
    CURSOR org_flow_curs ( c_esn IN VARCHAR2 ,c_param_value IN VARCHAR2 )
    IS
      SELECT pn.x_technology ,
        pi.* ,
        bo.org_flow
      FROM table_part_num pn ,
        table_bus_org bo ,
        table_part_inst pi ,
        table_mod_level ml
      WHERE 1                     = 1
      AND pn.domain               = 'PHONES'
      AND pn.part_num2bus_org     = bo.objid
      AND ml.part_info2part_num   = pn.objid
      AND pi.n_part_inst2part_mod = ml.objid
      AND bo.org_flow             = c_param_value
      AND pi.part_serial_no       = c_esn;
    org_flow_rec org_flow_curs%ROWTYPE;
    -- **********************************************************************
    -- CR20451 | CR20854: Add TELCEL Brand   mod 1 END
    -- **********************************************************************
    CURSOR st_portin_case_curs(c_esn VARCHAR2)
    IS
      SELECT c.rowid ,
        c.objid ,
        c.case_originator2user ,
        c.id_number ,
        c.title ,
        c.x_case_type ,
        c.case_history
      FROM table_case c ,
        table_x_case_detail cd ,
        table_condition tc
      WHERE c.x_esn      = c_esn
      AND c.x_case_type  = 'Port In'
      AND c.title       IN ('ST External' ,'ST Cross Company' ,'ST Auto Internal')
      AND cd.x_name      = 'CURRENT_MIN'
      AND cd.detail2case = c.objid
      AND tc.objid       = c.case_state2condition
      AND tc.s_title NOT LIKE 'CLOSE%'; -- STCC Skuthadi
    --AND cd.x_value = c_min;
    st_portin_case_rec st_portin_case_curs%ROWTYPE;
    --ST_BUNDLE_III
    /* CURSOR st_epir_case_curs ( c_esn   VARCHAR2 )
    IS
    SELECT c.objid, c.id_number, c.title, c.x_case_type, c.case_originator2user
    FROM table_case c,table_condition tc
    WHERE tc.objid =CASE_STATE2CONDITION
    AND c.x_esn = c_esn
    AND c.x_case_type = 'Port In'
    AND c.s_title = 'ST EXTERNAL'
    AND tc.s_title like 'OPEN%';
    st_epir_case_rec               st_epir_case_curs%ROWTYPE;
    */
    --ST_BUNDLE_II_A
    ----------------
    -- ST_BUNDLE_II
    ----------------
    --------------------------------------------------------------------------------
    -- WSRD TF/NT Port Flow Starts
    CURSOR port_flow_curs ( c_esn VARCHAR2 ,c_min VARCHAR2 )
    IS
      SELECT c.rowid ,
        c.objid ,
        c.case_originator2user ,
        c.id_number ,
        c.title ,
        c.x_case_type ,
        c.case_history
      FROM table_case c ,
        table_x_case_detail cd ,
        table_condition tc
      WHERE c.x_esn      = c_esn
      AND c.x_case_type  = 'Port In'
      AND c.title       IN ('Auto External' ,'Auto Internal Cross Company')
      AND cd.x_name      = 'CURRENT_MIN'
      AND cd.x_value     = c_min
      AND cd.detail2case = c.objid
      AND tc.objid       = c.case_state2condition
      AND tc.s_title NOT LIKE 'CLOSE%'; -- STCC Skuthadi
    port_flow_rec port_flow_curs%ROWTYPE;
    --CR15983
    -- YM PM Start CR19595
    -- *****************************************************************************
    -- CR20451 | CR20854: Add TELCEL Brand  and param_name = 'ORG_FLOW')   org_flow  AREA2
    -- *****************************************************************************
    CURSOR esn_curs(c_esn IN VARCHAR2)
    IS
      SELECT pi.* ,
        bo.org_flow ,
        (SELECT param_value
        FROM pc_params_view ppv
        WHERE ppv.part_class = pc.name
        AND param_name       = 'TECHNOLOGY'
        ) tech ,
      (SELECT param_value
      FROM pc_params_view ppv
      WHERE ppv.part_class = pc.name
      AND param_name       = 'BUS_ORG'
      ) bus ,
      (SELECT param_value
      FROM pc_params_view ppv
      WHERE ppv.part_class = pc.name
      AND param_name       = 'DLL'
      ) dll ,
      (SELECT param_value
      FROM pc_params_view ppv
      WHERE ppv.part_class = pc.name
      AND param_name       = 'NON_PPE'
      ) non_ppe
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_part_class pc ,
      table_bus_org bo
    WHERE 1                     = 1
    AND pi.part_serial_no       = c_esn
    AND pi.x_domain             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.part_num2part_class  = pc.objid
    AND pn.part_num2bus_org     = bo.objid;
    -- YM PM End CR19595
    esn_rec esn_curs%ROWTYPE;

    --cwl 2/3/2012 --CR15690
    -- NET10_PAYGO STARTS
    CURSOR mov_ig_dep_tx_curs ( c_action_item_id IN VARCHAR2 ,c_status IN VARCHAR2 )
    IS
      SELECT *
      FROM gw1.ig_dependent_transaction
      WHERE parent_action_item_id = c_action_item_id
      AND dep_status              = c_status;
    mov_ig_dep_tx_rec mov_ig_dep_tx_curs%ROWTYPE;
    --CR27279
    CURSOR newer_ig_curs(c_action_item_id IN VARCHAR2)
    IS
      SELECT b.objid newer_task_objid
      FROM GW1.IG_TRANSACTION A,
        TABLE_TASK B,
        table_x_call_trans ct1
      WHERE 1               =1
      AND A.action_item_id  = c_action_item_id
      AND A.STATUS         IN ('E','EE','F','FF','HW','C')
      --AND A.ORDER_TYPE NOT IN ('IPRL','BI','PIS','V','VP','AS','DS','F','COHL','ROTA','ROTAF','DI', 'I','WP','DAB','DBK','PIE','CNHL','IDD','IDS','SPC','VD','MINC') -- Exclude Order Type 'MINC' CR31618 Gsaragadam
      AND A.ORDER_TYPE IN (SELECT X_IG_ORDER_TYPE FROM X_IG_ORDER_TYPE WHERE NEWER_TRANS_FLAG   ='Y') --CR48086
      AND B.TASK_ID         = A.ACTION_ITEM_ID
      AND NOT EXISTS
        (SELECT 1
        FROM TABLE_GBST_ELM eg
        WHERE eg.objid    = B.TYPE_TASK2GBST_ELM
        AND UPPER(TITLE) IN ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS')
        )
    AND ct1.objid = b.x_task2x_call_trans
    AND EXISTS
      (SELECT
        /*+ USE_INVISIBLE_INDEXES */
        1
      FROM GW1.IG_TRANSACTION C,
        TABLE_TASK D ,
        table_x_call_trans ct2
      WHERE 1               =1
      AND c.esn             = a.esn
      --AND C.ORDER_TYPE NOT IN ('IPRL','BI','PIS','V','VP','AS','DS','F','COHL','ROTA','ROTAF','DI', 'I','WP','DAB','DBK','PIE','CNHL','IDD','IDS','SPC','VD','MINC') -- Exclude Order Type 'MINC' CR31618 Gsaragadam
      AND C.ORDER_TYPE IN (SELECT X_IG_ORDER_TYPE FROM X_IG_ORDER_TYPE WHERE NEWER_TRANS_FLAG   ='Y')--CR48086
      AND D.TASK_ID         = C.ACTION_ITEM_ID
      AND NOT EXISTS
        (SELECT 1
        FROM TABLE_GBST_ELM eg
        WHERE eg.objid    = D.TYPE_TASK2GBST_ELM
        AND UPPER(TITLE) IN ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS')
        )
      AND ct2.objid           = d.x_task2x_call_trans
      AND ct2.x_transact_date > ct1.x_transact_date
      );
    newer_ig_rec newer_ig_curs%rowtype;
    CURSOR older_ig_curs(c_action_item_id IN VARCHAR2)
    IS
      SELECT
        /*+ USE_INVISIBLE_INDEXES ORDERED */
        d.objid older_task_objid,
        c.transaction_id
      FROM GW1.IG_TRANSACTION A,
        TABLE_TASK B,
        table_x_call_trans ct1,
        GW1.IG_TRANSACTION C,
        TABLE_TASK D ,
        table_x_call_trans ct2
      WHERE 1               =1
      AND A.action_item_id  = c_action_item_id
      --AND A.ORDER_TYPE NOT IN ('IPRL','BI','PIS','V','VP','AS','DS','F','COHL','ROTA','ROTAF','DI', 'I','WP','DAB','DBK','PIE','CNHL','IDD','IDS','SPC','VD','MINC') -- Exclude Order Type 'MINC' CR31618 Gsaragadam
      AND A.ORDER_TYPE IN (SELECT X_IG_ORDER_TYPE FROM X_IG_ORDER_TYPE WHERE NEWER_TRANS_FLAG   ='Y') --CR48086
      AND B.TASK_ID         = A.ACTION_ITEM_ID
      AND NOT EXISTS
        (SELECT 1
        FROM TABLE_GBST_ELM eg
        WHERE eg.objid    = B.TYPE_TASK2GBST_ELM
        AND UPPER(TITLE) IN ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS')
        )
    AND ct1.objid         = b.x_task2x_call_trans
    AND c.esn             = a.esn
    AND c.STATUS         IN ('E','EE','F','FF','HW','C')
    AND C.ORDER_TYPE IN (SELECT X_IG_ORDER_TYPE FROM X_IG_ORDER_TYPE WHERE NEWER_TRANS_FLAG   ='Y')--CR48086
    --AND C.ORDER_TYPE NOT IN ('IPRL','BI','PIS','V','VP','AS','DS','F','COHL','ROTA','ROTAF','DI', 'I','WP','DAB','DBK','PIE','CNHL','IDD','IDS','SPC','VD','MINC') -- Exclude Order Type 'MINC' CR31618 Gsaragadam
    AND D.TASK_ID         = C.ACTION_ITEM_ID
    AND NOT EXISTS
      (SELECT 1
      FROM TABLE_GBST_ELM eg
      WHERE eg.objid    = D.TYPE_TASK2GBST_ELM
      AND UPPER(TITLE) IN ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS')
      )
    AND ct2.objid           = d.x_task2x_call_trans
    AND ct2.x_transact_date < ct1.x_transact_date;

    CURSOR non_prov_old_ig_curs(c_action_item_id IN VARCHAR2)
    IS
     select /*+ USE_INVISIBLE_INDEXES ORDERED */
            d.objid older_task_objid,
            c.transaction_id
       from gw1.ig_transaction a,
            table_task b,
            table_x_call_trans ct1,
            gw1.ig_transaction c,
            table_task d ,
            table_x_call_trans ct2
      where 1               =1
        and a.action_item_id  = c_action_item_id
        and a.order_type      = c.order_type
        and a.order_type in  (select x_ig_order_type from sa.x_ig_order_type where newer_trans_flag = 'N') -- Exclude Order Type 'MINC' CR31618 Gsaragadam, CR51685 added UI and PFR
        and b.task_id         = a.action_item_id
        and not exists (select  1
                        from    table_gbst_elm eg
                        where   eg.objid    = b.type_task2gbst_elm
                        and     upper(title) in ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS'))
        and ct1.objid         = b.x_task2x_call_trans
        and c.esn             = a.esn
        and c.status         in ('E','EE','F','FF','HW','C')
        and a.order_type      = c.order_type
        and c.order_type in  (select x_ig_order_type from sa.x_ig_order_type where newer_trans_flag = 'N') -- Exclude Order Type 'MINC' CR31618 Gsaragadam, CR51685 added UI and PFR
        and d.task_id         = c.action_item_id
        and not exists  (select 1
                         from   table_gbst_elm eg
                         where  eg.objid    = d.type_task2gbst_elm
                         and    upper(title) in ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS') )
        and ct2.objid           = d.x_task2x_call_trans
        and ct2.x_transact_date < ct1.x_transact_date;

    CURSOR current_ig_status_curs(c_transaction_id IN NUMBER)
    IS
      SELECT status
      FROM gw1.ig_transaction ig
      WHERE ig.transaction_id = c_transaction_id;
    current_ig_status_rec current_ig_status_curs%rowtype;
    --cwl 1/2/2015
    CURSOR test_family_plan_curs(c_esn IN VARCHAR2, c_ig_order_type IN VARCHAR2) IS
      SELECT a.*
      FROM   ( SELECT agm.account_group_id,
                      agm.objid,
                      ( SELECT bo.org_id bus_org_id
                        FROM   table_part_inst pi,
                               table_mod_level ml,
                               table_part_num pn,
                               table_bus_org bo
                        WHERE  1 = 1
                        AND pi.part_serial_no       = c_esn
                        AND pi.x_domain             = 'PHONES'
                        AND pi.n_part_inst2part_mod = ml.objid
                        AND ml.part_info2part_num   = pn.objid
                        AND pn.domain               = 'PHONES'
                        AND pn.part_num2bus_org     = bo.objid
                        AND ROWNUM                  = 1
                      ) bus_org_id,
                      ( SELECT NVL(create_so_gencode_flag,'N')
                        FROM   x_ig_order_type
                        WHERE  x_ig_order_type = c_ig_order_type
                        AND    ROWNUM = 1
                      ) create_so_gencode_flag
               FROM   sa.x_account_group_member agm
               WHERE  agm.esn = c_esn
               AND NOT EXISTS ( SELECT 1
                                FROM   table_part_inst pi,
                                       table_mod_level ml,
                                       table_part_num pn,
                                       table_x_part_class_values v,
                                       table_x_part_class_params n
                                WHERE  1 = 1
                                AND    pi.part_serial_no   = c_esn
                                AND    pi.x_domain = 'PHONES'
                                AND    ml.objid = pi.n_part_inst2part_mod
                                AND    pn.objid = ml.part_info2part_num
                                AND    v.value2part_class = pn.part_num2part_class
                                AND    v.value2class_param = n.objid
                                AND n.x_param_name      = 'NON_PPE'
                                AND v.x_param_value    IN ('1')
                              )
             ) a
      WHERE  brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => a.bus_org_id ) = 'Y';


    test_family_plan_rec test_family_plan_curs%rowtype;
    fp_service_order_stage_id NUMBER;
    fp_err_code               NUMBER;
    fp_err_msg                VARCHAR2(300);

    -- CR42459
    x_service_plan_rec sa.x_service_plan%rowtype;
    v_service_plan_group   VARCHAR2(200) := NULL;


        CURSOR test_ppe_switch_curs(c_esn IN VARCHAR2, c_ig_order_type IN VARCHAR2) IS
      SELECT a.*
      FROM   ( SELECT agm.account_group_id,
                      agm.objid,
                      ( SELECT bo.org_id bus_org_id
                        FROM   table_part_inst pi,
                               table_mod_level ml,
                               table_part_num pn,
                               table_bus_org bo
                        WHERE  1 = 1
                        AND pi.part_serial_no       = c_esn
                        AND pi.x_domain             = 'PHONES'
                        AND pi.n_part_inst2part_mod = ml.objid
                        AND ml.part_info2part_num   = pn.objid
                        AND pn.domain               = 'PHONES'
                        AND pn.part_num2bus_org     = bo.objid
                        AND ROWNUM                  = 1
                      ) bus_org_id,
                      ( SELECT NVL(create_so_gencode_flag,'N')
                        FROM   x_ig_order_type
                        WHERE  x_ig_order_type = c_ig_order_type
                        AND    ROWNUM = 1
                      ) create_so_gencode_flag
               FROM   sa.x_account_group_member agm
               WHERE  agm.esn = c_esn
               AND NOT EXISTS ( SELECT 1
                                FROM   table_part_inst pi,
                                       table_mod_level ml,
                                       table_part_num pn,
                                       table_x_part_class_values v,
                                       table_x_part_class_params n
                                WHERE  1 = 1
                                AND    pi.part_serial_no   = c_esn
                                AND    pi.x_domain = 'PHONES'
                                AND    ml.objid = pi.n_part_inst2part_mod
                                AND    pn.objid = ml.part_info2part_num
                                AND    v.value2part_class = pn.part_num2part_class
                                AND    v.value2class_param = n.objid
                                AND n.x_param_name      = 'NON_PPE'
                                AND v.x_param_value    IN ('1')
                              )
             ) a
      WHERE get_device_type (c_esn) = 'FEATURE_PHONE'
        AND v_service_plan_group  = 'SL_UNL_PLANS';
      test_ppe_switch_rec test_ppe_switch_curs%rowtype;


    --cwl 1/2/2015
    --CR27279
    -- CR23513 TF Surepay by Mvadlapally
    /*    CURSOR ig_trans_bkt_curs
    (
    c_transaction_id IN VARCHAR2
    ,c_rate_plan      IN VARCHAR2
    ) IS
    SELECT igtb.transaction_id,
    MAX (DECODE (igb.bucket_type, 'VOICE_UNITS', igtb.bucket_balance, NULL)) voice_units,
    MAX (DECODE (igb.bucket_type, 'SMS_UNITS', igtb.bucket_balance, NULL)) sms_units,
    MAX (DECODE (igb.bucket_type, 'DATA_UNITS', igtb.bucket_balance, NULL)) data_units,
    igtb.recharge_date,
    igtb.expiration_date
    FROM gw1.ig_buckets igb, gw1.ig_transaction_buckets igtb
    WHERE     1 = 1
    AND igb.bucket_id = igtb.bucket_id
    AND igtb.direction = 'INBOUND'
    AND igtb.transaction_id = c_transaction_id ---  399226575
    AND igb.rate_plan = c_rate_plan           --'TFREVBULKTIER_D'
    group by igtb.transaction_id, igtb.recharge_date, igtb.expiration_date;
    ig_trans_bkt_rec   ig_trans_bkt_curs%rowtype;*/
    --CR20403 RIM
    --  CURSOR ESN_BB_curs  (p_esn IN VARCHAR2) IS
    -- select bo.org_id, pc.name, pn.*
    --  from table_part_class pc, table_part_num pn , table_bus_org bo,  pc_params_view pv
    --     ,table_part_inst pi, table_mod_level ml
    --  where pn.part_num2part_class = pc.objid
    ---   and pv.part_class = pc.name
    --   AND  PI.PART_SERIAL_NO = P_ESN
    --    and pi.n_part_inst2part_mod = ml.objid
    --    AND   ml.part_info2part_num = pn.objid
    --    and pc.objid = pn.part_num2part_class
    --    and pn.part_num2bus_org = bo.objid
    --    and  pv.param_name = 'OPERATING_SYSTEM'
    --    and pv.param_value = 'BBOS';
    --  ESN_BB_rec ESN_BB_curs%ROWTYPE;
    op_msg    VARCHAR2(300):=' ';
    op_status VARCHAR2(30) :=' ';
    --CR20403 RIM
    -- NET10_PAYGO ENDS
    get_param_rec get_param_curs%ROWTYPE;
    v_fail_notes VARCHAR2(2000);
    --CR4902
    str_reworkq VARCHAR2(100);
    --      rtain_notesstr          VARCHAR2 (23768); --CR5008
    rtain_notesstr LONG; --CR5008, CR4947
    fax_filename    VARCHAR2(100);
    l_notes_log_seq NUMBER;
    hold            NUMBER;
    hold2           VARCHAR2(100);
    lcaseobjid      NUMBER;
    rtain_strqueue  VARCHAR2(100);
    cnt             NUMBER        := 0;
    l_program_name  VARCHAR2(100) := 'IGATE_IN.RTA_IN';
    l_start_date    DATE          := SYSDATE;
    --CR4947
    l_recs_processed NUMBER := 0;
    --CR4947
    blnresult BOOLEAN;
    --blnUpdated BOOLEAN := false; --Commented for CR3440
    intportinq        NUMBER;
    itobeauth         NUMBER;
    l_ins_pihist_flag BOOLEAN;
    --CR3327-1 Variable declarations starts
    v_order_type         VARCHAR2(30);
    v_ordertype_objid    NUMBER;
    v_action_item_id_ipa NUMBER;
    v_black_out_code     NUMBER;
    v_dest_queue         NUMBER;
    v_dummy              NUMBER;
    v_contact_objid      NUMBER;
    v_status_out         NUMBER;
    v_case_id table_case.id_number%TYPE;
    v_case_history table_case.case_history%TYPE;
    v_task_id table_task.task_id%TYPE;
    v_task_objid table_task.objid%TYPE;
    --CR3327-1 Variable declarations ends
    v_case_error_no  VARCHAR2(100);
    v_case_error_str VARCHAR2(100);
    --
    -- OTA
    --
    cntcase       NUMBER; --CR3918 ver1.20  Mchinta 06/15/2005
    cntclosedcase NUMBER;
    piobjid       NUMBER;                 --CR3918 ver1.20  Mchinta 06/15/2005
    out_errorcode NUMBER        := 0;     -- CR23513
    out_errormsg  VARCHAR2(300) := NULL ; -- CR23513
    v_objid X_SERVICE_PLAN.OBJID%TYPE;    --CR29001 RRS
    LV_ACCOUNT           VARCHAR2(10);              --CR29001 RRS
    LV_CODE              NUMBER(10);
    LV_MESSAGE           VARCHAR2(1000);
    LV_DEFAULT_VALUE_SET VARCHAR2(10);
    v_insert             BOOLEAN; --CR29001 RRS
   ig_order_type_rec sa.X_IG_ORDER_TYPE%ROWTYPE; --CR36850
    -- NET10_PAYGO STARTS
    l_final_ig_status gw1.ig_transaction.status%TYPE := '';
    -- NET10_PAYGO ENDS
    --*****************************************************************************************************
    l_have_service_plans sa.table_x_parameters.x_param_value%TYPE; -- CR20451 | CR20854: Add TELCEL Brand AREA3
    -- ***************************************************************************************************
    l_ani_already_exists BOOLEAN;
    TF_PILD_P_count      INTEGER;
    TF_PILD_P_MIN_count  INTEGER;
    c_error_code          VARCHAR2(100);    -- CR49058
    c_error_msg           VARCHAR2(1000);   -- CR49058
	--CR54900 Starts
    lv_ild_flag          VARCHAR2(100) := 'Y';
	op_last_rate_plan_sent table_x_carrier_features.x_rate_plan%TYPE;
    op_is_swb_carr         VARCHAR2(100);
    op_error_code          INTEGER;
    op_error_message       VARCHAR2(1000);
    --CR54900 Ends
	-- CR56462 Starts
	cst           sa.customer_type := customer_type();
	l_error_no    VARCHAR2(10);
	l_error_str   VARCHAR2(1000);
	-- CR56462 Ends
  --
  FUNCTION ota_activation_pending(
      p_part_serial_no IN VARCHAR2)
    RETURN BOOLEAN
  IS
    b_return_value BOOLEAN := FALSE;
  BEGIN
    OPEN ota_call_trans_curs(p_part_serial_no);
    FETCH ota_call_trans_curs INTO ota_call_trans_rec;
    IF ota_call_trans_rec.x_action_type = '1' AND ota_call_trans_rec.x_result = 'OTA PENDING' THEN
      b_return_value                   := TRUE;
    END IF;
    CLOSE ota_call_trans_curs;
    RETURN b_return_value;
  END ota_activation_pending;
  --cwl 4/22/2011
FUNCTION recreate_tmin(
    p_action_item_id IN VARCHAR2)
  RETURN BOOLEAN
IS
  CURSOR c1
  IS
    SELECT g.min ,
      g.msid ,
      g.esn ,
      g.technology_flag ,
      g.template ,
      '39' line_status ,
      (SELECT objid FROM table_x_code_table WHERE x_code_number = '39'
      ) line_status_objid
    --CR21051 Start Kacosta 05/31/2012
    --,pi_esn.n_part_inst2part_mod
    ,
    23070541 n_part_inst2part_mod
    --CR21051 End Kacosta 05/31/2012
    ,
    pi_esn.warr_end_date ,
    pi_esn.x_cool_end_date ,
    pi_esn.part_inst2x_pers ,
    (SELECT ct.x_call_trans2carrier
    FROM table_task t ,
      table_x_call_trans ct
    WHERE t.task_id = g.action_item_id
    AND ct.objid    = t.x_task2x_call_trans
    ) x_call_trans2carrier ,
    (SELECT ct.x_call_trans2user
    FROM table_task t ,
      table_x_call_trans ct
    WHERE t.task_id = g.action_item_id
    AND ct.objid    = t.x_task2x_call_trans
    ) x_call_trans2user ,
    (SELECT sp.x_min
    FROM table_task t ,
      table_x_call_trans ct ,
      table_site_part sp
    WHERE t.task_id = g.action_item_id
    AND ct.objid    = t.x_task2x_call_trans
    AND sp.objid    = ct.call_trans2site_part
    ) sp_x_min
  FROM
    (SELECT g.min ,
      g.msid ,
      g.esn ,
      g.action_item_id ,
      g.technology_flag ,
      g.template
    FROM gw1.ig_transaction g
    WHERE 1                 = 1
    AND g.action_item_id    = p_action_item_id
    AND ((g.technology_flag = 'C'
    AND (g.min NOT LIKE 'T%'
    OR g.msid NOT LIKE 'T%'))
    OR (g.technology_flag = 'G'
    AND g.msid NOT LIKE 'T%'))
    AND EXISTS
      (SELECT sp.x_min
      FROM table_task t ,
        table_x_call_trans ct ,
        table_site_part sp
      WHERE t.task_id = g.action_item_id
      AND ct.objid    = t.x_task2x_call_trans
      AND sp.objid    = ct.call_trans2site_part
      AND NOT EXISTS
        (SELECT 1 FROM table_part_inst pi WHERE part_serial_no = sp.x_min
        )
      )
    ) g ,
    table_part_inst pi_esn
  WHERE pi_esn.part_serial_no = g.esn
  AND x_domain                = 'PHONES';
  c1_rec c1%ROWTYPE;
  blnresult BOOLEAN := FALSE;
BEGIN
  OPEN c1;
  FETCH c1 INTO c1_rec;
  IF c1%NOTFOUND THEN
    CLOSE c1;
    dbms_output.put_line('recreate Tmin cursor returned null');
    RETURN FALSE;
  END IF;
  CLOSE c1;
  dbms_output.put_line('c1_rec.sp_x_min:' || c1_rec.sp_x_min);
  blnresult   := toppapp.line_insert_pkg.insert_line_rec(c1_rec.sp_x_min ,c1_rec.sp_x_min ,SUBSTR(c1_rec.sp_x_min ,1 ,3) ,SUBSTR(c1_rec.sp_x_min ,4 ,3) ,SUBSTR(c1_rec.sp_x_min ,7 ,10) ,c1_rec.template || '_' || SYSDATE ,c1_rec.warr_end_date ,c1_rec.x_cool_end_date ,c1_rec.line_status ,c1_rec.n_part_inst2part_mod ,c1_rec.part_inst2x_pers ,c1_rec.x_call_trans2carrier ,c1_rec.line_status_objid ,c1_rec.x_call_trans2user);
  IF blnresult = FALSE THEN
    dbms_output.put_line('recreate Tmin insert failure');
    RETURN FALSE;
  END IF;
  COMMIT;
  RETURN TRUE;
END;
--cwl 4/22/2011
-----------------------------------------------------------
-- Process status messages received from TMOBILE carrier --
-- CR4947 START                                            --
-----------------------------------------------------------
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
PROCEDURE failed_log(
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
IS
BEGIN
  INSERT
  INTO gw1.ig_failed_log
    (
      action_item_id ,
      carrier_id ,
      order_type ,
      MIN ,
      esn ,
      esn_hex ,
      old_esn ,
      old_esn_hex ,
      pin ,
      phone_manf ,
      end_user ,
      account_num ,
      market_code ,
      rate_plan ,
      ld_provider ,
      sequence_num ,
      dealer_code ,
      transmission_method ,
      fax_num ,
      online_num ,
      email ,
      network_login ,
      network_password ,
      system_login ,
      system_password ,
      template ,
      com_port ,
      status ,
      status_message ,
      trans_prof_key ,
      q_transaction ,
      fax_num2 ,
      creation_date ,
      update_date ,
      blackout_wait ,
      transaction_id ,
      technology_flag ,
      voice_mail ,
      voice_mail_package ,
      caller_id ,
      caller_id_package ,
      call_waiting ,
      call_waiting_package ,
      digital_feature_code ,
      state_field ,
      zip_code ,
      msid ,
      new_msid_flag ,
      sms ,
      sms_package ,
      iccid ,
      old_min ,
      digital_feature ,
      ota_type ,
      rate_center_no ,
      application_system ,
      subscriber_update ,
      download_date ,
      prl_number ,
      amount ,
      balance ,
      LANGUAGE ,
      exp_date ,
      logged_date ,
      logged_by
    )
    VALUES
    (
      p_ig_trans_rec.action_item_id ,
      p_ig_trans_rec.carrier_id ,
      p_ig_trans_rec.order_type ,
      p_ig_trans_rec.min ,
      p_ig_trans_rec.esn ,
      p_ig_trans_rec.esn_hex ,
      p_ig_trans_rec.old_esn ,
      p_ig_trans_rec.old_esn_hex ,
      p_ig_trans_rec.pin ,
      p_ig_trans_rec.phone_manf ,
      p_ig_trans_rec.end_user ,
      p_ig_trans_rec.account_num ,
      p_ig_trans_rec.market_code ,
      p_ig_trans_rec.rate_plan ,
      p_ig_trans_rec.ld_provider ,
      p_ig_trans_rec.sequence_num ,
      p_ig_trans_rec.dealer_code ,
      p_ig_trans_rec.transmission_method ,
      p_ig_trans_rec.fax_num ,
      p_ig_trans_rec.online_num ,
      p_ig_trans_rec.email ,
      p_ig_trans_rec.network_login ,
      p_ig_trans_rec.network_password ,
      p_ig_trans_rec.system_login ,
      p_ig_trans_rec.system_password ,
      p_ig_trans_rec.template ,
      p_ig_trans_rec.com_port ,
      p_ig_trans_rec.status ,
      p_ig_trans_rec.status_message ,
      p_ig_trans_rec.trans_prof_key ,
      p_ig_trans_rec.q_transaction ,
      p_ig_trans_rec.fax_num2 ,
      p_ig_trans_rec.creation_date ,
      p_ig_trans_rec.update_date ,
      p_ig_trans_rec.blackout_wait ,
      p_ig_trans_rec.transaction_id ,
      p_ig_trans_rec.technology_flag ,
      p_ig_trans_rec.voice_mail ,
      p_ig_trans_rec.voice_mail_package ,
      p_ig_trans_rec.caller_id ,
      p_ig_trans_rec.caller_id_package ,
      p_ig_trans_rec.call_waiting ,
      p_ig_trans_rec.call_waiting_package ,
      p_ig_trans_rec.digital_feature_code ,
      p_ig_trans_rec.state_field ,
      p_ig_trans_rec.zip_code ,
      p_ig_trans_rec.msid ,
      p_ig_trans_rec.new_msid_flag ,
      p_ig_trans_rec.sms ,
      p_ig_trans_rec.sms_package ,
      p_ig_trans_rec.iccid ,
      p_ig_trans_rec.old_min ,
      p_ig_trans_rec.digital_feature ,
      p_ig_trans_rec.ota_type ,
      p_ig_trans_rec.rate_center_no ,
      p_ig_trans_rec.application_system ,
      p_ig_trans_rec.subscriber_update ,
      p_ig_trans_rec.download_date ,
      p_ig_trans_rec.prl_number ,
      p_ig_trans_rec.amount ,
      p_ig_trans_rec.balance ,
      p_ig_trans_rec.language ,
      p_ig_trans_rec.exp_date ,
      SYSDATE ,
      'igate_in3'
    );
  COMMIT;
  dbms_output.put_line('insert into table gw1.IG_FAILED_LOG ');
END;
PROCEDURE sp_close_task
  (
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE ,
    p_task_rec     IN task_curs%ROWTYPE ,
    p_task_status  IN NUMBER ,
    p_trans_status IN gw1.ig_transaction.status%TYPE
  )
IS
BEGIN
  -----------------------------------------------
  -- Closes the task which is associated       --
  -- with the current IGATE transaction record --
  -----------------------------------------------
  ----------------------------
  -- *** Close the task *** --
  ----------------------------
  igate.sp_close_action_item(p_task_objid => p_task_rec.objid ,p_status => p_task_status
  -- 0, 2, 3
  ,p_dummy_out => hold);
  -- CR15365
  IF p_trans_status <> 'S' THEN
    failed_log(p_ig_trans_rec);
  END IF;
  --CR15365
  UPDATE gw1.ig_transaction
  SET status  = p_trans_status -- 'S' = Success 'F' = Failure
  WHERE ROWID = p_ig_trans_rec.rowid;
  COMMIT;
  -- CR20403 RIM Integration CDMA
  -- ST CR20403
  IF p_trans_status = 'S' THEN
    --  OPEN ESN_BB_curs(p_ig_trans_rec.esn);
    --  FETCH ESN_BB_curs
    --  INTO ESN_BB_rec;
    -- IF ESN_BB_curs%FOUND THEN
    IF sa.RIM_SERVICE_PKG.IF_BB_ESN(P_IG_TRANS_REC.ESN) = 'TRUE' THEN --CR22487
      dbms_output.put_line('Insert ig_transaction_RIM after close action item');
      sa.Rim_service_pkg.sp_create_rim_action_item(p_ig_trans_rec.action_item_id, op_msg, op_status); --action_item_id (gw1.ig_transaction)
      IF op_status = 'S' THEN
        dbms_output.put_line('Inserted ig_transaction_RIM after close action item');
      ELSE
        dbms_output.put_line('Fail process sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM');
      END IF;
    END IF;
    --  close ESN_BB_curs;
    --CR48373
    DELETE FROM gw1.ig_transaction_features
    WHERE  transaction_id = p_ig_trans_rec.transaction_id;
  END IF;
  -- CR20403 RIM Integration CDMA
  COMMIT;
END sp_close_task;
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
PROCEDURE sp_create_sim_exchange_case(
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
IS
  -------
  -- * --
  -------
  l_c_case_id_out VARCHAR2(255);
BEGIN
  create_case_clarify_pkg.sp_create_case(p_esn => p_ig_trans_rec.esn ,p_contact_objid => esn_rec.x_part_inst2contact ,p_queue_name => 'Warehouse' ,p_type => 'Technology Exchange' ,p_title => 'SIM Card Exchange' ,p_history => 'Technology Exchange Case: SIM Card Exchange ' || 'Originated from IGATE ESN: ' || p_ig_trans_rec.esn ,p_status => 'BadAddress' ,p_repl_part => 'TFSIMT5' ,p_replacement_units => 0 ,p_case2task => 0 ,p_case_type_lvl2 => 'Tracfone' ,p_issue => 'Carrier Requested' ,p_inbound => NULL ,p_outbound => NULL ,p_signal => NULL ,p_scan => NULL ,p_promo_code => NULL ,p_master_sid => NULL ,p_prl_soc => NULL ,p_time_tank => NULL ,p_tt_units => 0 ,p_fraud_id => NULL ,p_wrong_esn => NULL ,p_ttest_seq => 0 ,p_sys_seq => 0 ,p_channel => NULL ,p_phone_due_date => '1-jan-1753' ,p_sys_phone_date => '1-jan-1753' ,p_super_login => NULL ,p_cust_units_claim => 0 ,p_fraud_units => 0 ,p_vm_password => NULL ,p_courier => NULL ,p_stock_type => NULL ,p_reason => NULL ,p_problem_source => NULL
  ,p_case_id => l_c_case_id_out);
END sp_create_sim_exchange_case;
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
PROCEDURE sp_process_esn_change(
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
IS
BEGIN
  UPDATE gw1.ig_transaction
  SET order_type = 'E'
  WHERE ROWID    = p_ig_trans_rec.rowid;
  COMMIT;
END sp_process_esn_change;
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
FUNCTION f_tmobile_activation_msg(
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
  RETURN BOOLEAN
IS
  b_deact_success BOOLEAN := FALSE;
  b_return_value  BOOLEAN := FALSE;
BEGIN
  ---------------------------------
  -- Order type 'A' = Activation --
  ---------------------------------
  dbms_output.put_line('RUNNING:  f_tmobile_activation_msg');
  IF RTRIM(p_ig_trans_rec.status_message) IN ('MSISDN Not Found' ,'SIM is not valid') THEN
    --------------------------------------------
    -- *** Close action item with success *** --
    --------------------------------------------
    sp_close_task(p_ig_trans_rec => p_ig_trans_rec ,p_task_rec => task_rec ,p_task_status => 0 ,p_trans_status => 'S');
    --------------------------------------
    -- *** Create SIM Exchange case *** --
    --------------------------------------
    sp_create_sim_exchange_case(p_ig_trans_rec => p_ig_trans_rec);
    -----------------------------------------------------------
    -- *** Disassociate the MDN (min)from the IMEI (esn) *** --
    -----------------------------------------------------------
    service_deactivation.deactivate_any(ip_esn => p_ig_trans_rec.esn ,ip_reason => 'WN-SYSTEM ISSUED' ,ip_caller_program => 'igate_in3.RTA_IN' ,ip_result => b_deact_success);
    IF b_deact_success THEN
      dbms_output.put_line('service_deactivation.deactivate_any prodecure returned TRUE');
    ELSE
      dbms_output.put_line('service_deactivation.deactivate_any prodecure returned FALSE');
      toss_util_pkg.insert_error_tab_proc('Deactivating the phone' ,p_ig_trans_rec.action_item_id ,l_program_name ,'service_deactivation.deactivate_any prodecure returned FALSE ' || p_ig_trans_rec.action_item_id);
    END IF;
    b_return_value                          := TRUE;
  ELSIF RTRIM(p_ig_trans_rec.status_message) = 'TracFone: SIM active with different IMEI' THEN
    --------------------------------
    -- *** Process ESN change *** --
    --------------------------------
    sp_process_esn_change(p_ig_trans_rec => p_ig_trans_rec);
    b_return_value                          := TRUE;
  ELSIF RTRIM(p_ig_trans_rec.status_message) = 'TracFone: Unable to process Reactivation' THEN
    -- further investigation required with Tracfone
    NULL;
  END IF;
  RETURN b_return_value;
END f_tmobile_activation_msg;
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
FUNCTION f_tmobile_esn_chng_msg(
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
  RETURN BOOLEAN
IS
  b_deact_success BOOLEAN := FALSE;
  b_return_value  BOOLEAN := FALSE;
BEGIN
  -----------------------------------
  -- Order type 'E' = ESN Change   --
  -----------------------------------
  dbms_output.put_line('RUNNING:  f_tmobile_esn_chng_msg');
  IF RTRIM(p_ig_trans_rec.status_message) IN ('SIM is already active' ,'SIM is not valid') THEN
    --------------------------------------------
    -- *** Close action item with success *** --
    --------------------------------------------
    sp_close_task(p_ig_trans_rec => p_ig_trans_rec ,p_task_rec => task_rec ,p_task_status => 0 ,p_trans_status => 'S');
    --------------------------------------
    -- *** Create SIM Exchange case *** --
    --------------------------------------
    sp_create_sim_exchange_case(p_ig_trans_rec => p_ig_trans_rec);
    ------------------------------------------------------------
    -- *** Disassociate the MDN (min) from the IMEI (esn) *** --
    ------------------------------------------------------------
    service_deactivation.deactivate_any(ip_esn => p_ig_trans_rec.esn ,ip_reason => 'WN-SYSTEM ISSUED' ,ip_caller_program => 'igate_in3.RTA_IN' ,ip_result => b_deact_success);
    IF b_deact_success THEN
      dbms_output.put_line('service_deactivation.deactivate_any prodecure returned TRUE');
    ELSE
      dbms_output.put_line('service_deactivation.deactivate_any prodecure returned FALSE');
      toss_util_pkg.insert_error_tab_proc('Deactivating the phone' ,p_ig_trans_rec.action_item_id ,l_program_name ,'service_deactivation.deactivate_any prodecure returned FALSE ' || p_ig_trans_rec.action_item_id);
    END IF;
    b_return_value                          := TRUE;
  ELSIF RTRIM(p_ig_trans_rec.status_message) = 'ReActivating Active Subscriber' THEN
    -- further investigation required with Tracfone
    NULL;
  END IF;
  RETURN b_return_value;
END f_tmobile_esn_chng_msg;
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
FUNCTION f_tmobile_minc_msg(
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
  RETURN BOOLEAN
IS
  b_deact_success BOOLEAN := FALSE;
  b_return_value  BOOLEAN := FALSE;
BEGIN
  ------------------------------------
  -- Order type 'MINC' = MIN Change --
  ------------------------------------
  dbms_output.put_line('RUNNING:  f_tmobile_minc_msg');
  IF RTRIM(p_ig_trans_rec.status_message) = 'Invalid Subscriber' THEN
    --------------------------------------------
    -- *** Close action item with success *** --
    --------------------------------------------
    sp_close_task(p_ig_trans_rec => p_ig_trans_rec ,p_task_rec => task_rec ,p_task_status => 0 ,p_trans_status => 'S');
    --------------------------------------
    -- *** Create SIM Exchange case *** --
    --------------------------------------
    sp_create_sim_exchange_case(p_ig_trans_rec => p_ig_trans_rec);
    ------------------------------------------------------------
    -- *** Disassociate the MDN (min) from the IMEI (esn) *** --
    ------------------------------------------------------------
    service_deactivation.deactivate_any(ip_esn => p_ig_trans_rec.esn ,ip_reason => 'WN-SYSTEM ISSUED' ,ip_caller_program => 'igate_in3.RTA_IN' ,ip_result => b_deact_success);
    IF b_deact_success THEN
      dbms_output.put_line('service_deactivation.deactivate_any prodecure returned TRUE');
    ELSE
      dbms_output.put_line('service_deactivation.deactivate_any prodecure returned FALSE');
      toss_util_pkg.insert_error_tab_proc('Deactivating the phone' ,p_ig_trans_rec.action_item_id ,l_program_name ,'service_deactivation.deactivate_any prodecure returned FALSE ' || p_ig_trans_rec.action_item_id);
    END IF;
    b_return_value                          := TRUE;
  ELSIF RTRIM(p_ig_trans_rec.status_message) = 'MSISDN is not associated with SIM and/or IMEI' THEN
    --------------------------------------------
    -- *** Close action item with success *** --
    --------------------------------------------
    sp_close_task(p_ig_trans_rec => p_ig_trans_rec ,p_task_rec => task_rec ,p_task_status => 0 ,p_trans_status => 'S');
    --------------------------------------
    -- *** Create SIM Exchange case *** --
    --------------------------------------
    sp_create_sim_exchange_case(p_ig_trans_rec => p_ig_trans_rec);
    ------------------------------------------------------------
    -- *** Disassociate the MDN (min) from the IMEI (esn) *** --
    ------------------------------------------------------------
    service_deactivation.deactivate_any(ip_esn => p_ig_trans_rec.esn ,ip_reason => 'WN-SYSTEM ISSUED' ,ip_caller_program => 'igate_in3.RTA_IN' ,ip_result => b_deact_success);
    IF b_deact_success THEN
      dbms_output.put_line('service_deactivation.deactivate_any prodecure returned TRUE');
    ELSE
      dbms_output.put_line('service_deactivation.deactivate_any prodecure returned FALSE');
      toss_util_pkg.insert_error_tab_proc('Deactivating the phone' ,p_ig_trans_rec.action_item_id ,l_program_name ,'service_deactivation.deactivate_any prodecure returned FALSE ' || p_ig_trans_rec.action_item_id);
    END IF;
    b_return_value                          := TRUE;
  ELSIF RTRIM(p_ig_trans_rec.status_message) = 'SIM is already active' THEN
    --------------------------------------------
    -- *** Close action item with success *** --
    --------------------------------------------
    sp_close_task(p_ig_trans_rec => p_ig_trans_rec ,p_task_rec => task_rec ,p_task_status => 0 ,p_trans_status => 'S');
    --------------------------------------
    -- *** Create SIM Exchange case *** --
    --------------------------------------
    sp_create_sim_exchange_case(p_ig_trans_rec => p_ig_trans_rec);
    ------------------------------------------------
    -- *** Assign customer old number back ***    --
    ------------------------------------------------
    -- It's not neccesary...
    b_return_value                          := TRUE;
  ELSIF RTRIM(p_ig_trans_rec.status_message) = 'MSISDN Not Found' THEN
    -- further investigation required with Tracfone
    NULL;
  ELSIF RTRIM(p_ig_trans_rec.status_message) = 'ReActivating active subscriber' THEN
    -- further investigation required with TMOBILE
    NULL;
  END IF;
  RETURN b_return_value;
END f_tmobile_minc_msg;
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
FUNCTION f_tmobile_deact_msg(
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
  RETURN BOOLEAN
IS
  b_return_value BOOLEAN := FALSE;
BEGIN
  -----------------------------------
  -- Order type 'D' = Deactivation --
  -----------------------------------
  dbms_output.put_line('RUNNING:  f_tmobile_deact_msg');
  IF RTRIM(p_ig_trans_rec.status_message) = 'MSISDN is not associated with SIM and/or IMEI' THEN
    --------------------------------------------
    -- *** Close action item with success *** --
    --------------------------------------------
    sp_close_task(p_ig_trans_rec => p_ig_trans_rec ,p_task_rec => task_rec ,p_task_status => 0 ,p_trans_status => 'S');
    b_return_value := TRUE;
  END IF;
  RETURN b_return_value;
END f_tmobile_deact_msg;
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
FUNCTION f_tmobile_suspend_msg(
    p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
  RETURN BOOLEAN
IS
  b_return_value BOOLEAN := FALSE;
BEGIN
  ------------------------------
  -- Order type 'S' = Suspend --
  ------------------------------
  dbms_output.put_line('RUNNING:  f_tmobile_suspend_msg');
  IF RTRIM(p_ig_trans_rec.status_message) = 'MSISDN is not associated with SIM and/or IMEI' THEN
    --------------------------------------------
    -- *** Close action item with success *** --
    --------------------------------------------
    sp_close_task(p_ig_trans_rec => p_ig_trans_rec ,p_task_rec => task_rec ,p_task_status => 0 ,p_trans_status => 'S');
    b_return_value := TRUE;
  END IF;
  RETURN b_return_value;
END f_tmobile_suspend_msg;

-- New Procedure Starts CR56462
PROCEDURE SP_UPDATE_CASE_OSP(
                             p_esn        IN  VARCHAR2,
                             p_order_type IN  VARCHAR2,
                             p_error_no   OUT VARCHAR2,
                             p_error_str  OUT VARCHAR2
							)
IS
CURSOR tmo_portin_case_curs
IS
	SELECT c.*
      FROM table_case c
     WHERE c.x_esn      = p_esn
       AND c.x_case_type  = 'Port In'
	   AND EXISTS (
	               SELECT /*+ use_invisible_indexes */ 1
	                 FROM gw1.ig_transaction ig
				    WHERE ig.esn = p_esn
					  AND ig.order_type = p_order_type
					  AND ig.transaction_id = (SELECT /*+ use_invisible_indexes */ MAX(ig1.transaction_id)
		                                         FROM gw1.ig_transaction ig1
								                WHERE ig1.esn        = ig.esn
									              AND ig1.order_type = ig.order_type
								               )
				  );
   v_osp          VARCHAR2(30);
   v_case_details VARCHAR2(1000);
   v_error_no     VARCHAR2(100);
   v_error_str    VARCHAR2(100);
BEGIN
  p_error_no := '0';
  p_error_str := 'SUCCESS';
  FOR tmo_portin_case_rec IN tmo_portin_case_curs LOOP
	  BEGIN
		  SELECT /*+ use_invisible_indexes */
				 extractvalue(igr.xml_response, '//oldServiceProvider')
			INTO v_osp
			FROM gw1.ig_transaction ig ,
				 gw1.ig_trans_carrier_response igr
		   WHERE ig.esn            = p_esn
			 AND ig.order_type     = p_order_type
			 AND ig.transaction_id = igr.transaction_id
			 AND ig.transaction_id = (
									  SELECT MAX(ig1.transaction_id)
										FROM gw1.ig_transaction ig1
									   WHERE ig1.ESN        = ig.esn
										 AND ig1.order_type = ig.order_type
									 );
	  EXCEPTION WHEN OTHERS THEN
	   v_osp := NULL;
	  END;
	  IF v_osp IS NOT NULL THEN
		 v_case_details :=  'OLD_SERVICE_PROVIDER||'||v_osp;
         sa.clarify_case_pkg.update_case_dtl(tmo_portin_case_rec.objid ,tmo_portin_case_rec.case_owner2user ,v_case_details ,v_error_no ,v_error_str);
	  END IF;
  END LOOP;
EXCEPTION WHEN OTHERS THEN
  p_error_no := '-1';
  p_error_str := 'FAILED';
END SP_UPDATE_CASE_OSP;
-- Ends CR56462
-----------------------------------------------------------
-- Process status messages received from TMOBILE carrier --
-- CR4947 END                                            --
-----------------------------------------------------------
--Local procedure to process when new_msid_flag is set to 'Y'
--Input Parameters : MIN, ORDER_TYPE
--START OF MAIN
BEGIN
  OPEN get_param_curs;
  FETCH get_param_curs INTO get_param_rec;
  IF get_param_curs%FOUND THEN
    v_fail_notes := get_param_rec.x_param_value;
  ELSE
    v_fail_notes := NULL;
  END IF;
  CLOSE get_param_curs;
  FOR ig_trans_rec IN ig_trans_curs
  LOOP

   --CR35154 to update IMSI value in TABLE_X_SIM_INV  Added by Srini Kota
    sa.load_sim_inv_pkg.sp_upd_imsi_sim_inv (ip_transaction_id => ig_trans_rec.transaction_id ); -- CR35154
    --Added by phaneendra for the CR33090 TMO wifi.
   sa.tmo_wifi_pkg.create_wifi_trans_wrap ( ip_transaction_id => ig_trans_rec.transaction_id );
   --CR56462
		IF ig_trans_rec.order_type IN ('PIR','EPIR') THEN
			cst := customer_type ( i_esn => ig_trans_rec.ESN);
			cst.short_parent_name := cst.get_short_parent_name (i_esn => ig_trans_rec.ESN);
			--dbms_output.put_line('MIN Carrier :'||NVL(cst.parent_name,'Not Found'));
			IF NVL(cst.short_parent_name,'XXXX') LIKE 'TMO' THEN
				SP_UPDATE_CASE_OSP(ig_trans_rec.esn ,ig_trans_rec.order_type ,l_error_no ,l_error_str );
			END IF;
		END IF;
		--CR56462
   --Added by Srini for CR36850 - transaction struck in HW for EPIR, PIR and APN
      BEGIN
        SELECT p.* into ig_order_type_rec
         FROM sa.X_IG_ORDER_TYPE P
         WHERE X_IG_ORDER_TYPE = ig_trans_rec.order_type;
      EXCEPTION
        WHEN OTHERS THEN
         NULL;
      END;   --END CR36850
    OPEN current_ig_status_curs(ig_trans_rec.transaction_id);
    FETCH current_ig_status_curs INTO current_ig_status_rec;
    IF NVL(current_ig_status_rec.status,'XXXXXX') = 'S' THEN
      CLOSE current_ig_status_curs;
      GOTO next_action_item;
    END IF;
    CLOSE current_ig_status_curs;
    OPEN newer_ig_curs(ig_trans_rec.action_item_id);
    FETCH newer_ig_curs INTO newer_ig_rec;
    IF newer_ig_curs%found THEN
      igate.sp_close_action_item(newer_ig_rec.newer_task_objid ,0 ,hold);
      UPDATE gw1.ig_transaction
      SET status       = 'TF',
        status_message = 'NEWER TRANSACTION FOUND'
      WHERE ROWID      = ig_trans_rec.rowid;
      --CR48373
      DELETE FROM gw1.ig_transaction_features
      WHERE  transaction_id = ig_trans_rec.transaction_id;
      COMMIT;
      CLOSE newer_ig_curs;
      GOTO next_action_item;
      NULL;
    END IF;
    CLOSE newer_ig_curs;
    FOR older_ig_rec IN older_ig_curs(ig_trans_rec.action_item_id)
    LOOP
      igate.sp_close_action_item(older_ig_rec.older_task_objid ,0 ,hold);
      UPDATE gw1.ig_transaction
      SET status           = 'TF',--'S', --CR48086
        status_message     = 'NEWER TRANSACTION FOUND'
      WHERE transaction_id = older_ig_rec.transaction_id;
      --CR48373
      DELETE FROM gw1.ig_transaction_features
      WHERE transaction_id = older_ig_rec.transaction_id;
      COMMIT;
    END LOOP;

    -- close old non proviosion order type
    FOR non_prov_old_ig_rec IN non_prov_old_ig_curs(ig_trans_rec.action_item_id)
    LOOP
      --
      igate.sp_close_action_item(non_prov_old_ig_rec.older_task_objid ,0 ,hold);
      --
      update gw1.ig_transaction
         set status           = 'TF',
             status_message   = 'NEWER TRANSACTION FOUND'
       where transaction_id   = non_prov_old_ig_rec.transaction_id;

       delete from gw1.ig_transaction_features
        where transaction_id = non_prov_old_ig_rec.transaction_id;

      commit;
      --
    END LOOP;



    OPEN esn_curs(ig_trans_rec.esn);
    FETCH esn_curs INTO esn_rec;
    IF esn_curs%NOTFOUND AND NVL(ig_order_type_rec.skip_esn_validation_flag,'N') = 'N'  THEN  --FOR CR36850 changes
      toss_util_pkg.insert_error_tab_proc('Retrieve esn record from part inst' ,ig_trans_rec.action_item_id ,l_program_name ,'No esn record found' || NVL(LTRIM(ig_trans_rec.esn) ,'N/A'));
      dbms_output.put_line('exit esn_curs not found log error  ');
      failed_log(ig_trans_rec);
      UPDATE gw1.ig_transaction
      SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW' ,'CP' ,'HCP' ,'HH') --CR16262 05/10/2011
      WHERE transaction_id = ig_trans_rec.transaction_id;
      COMMIT;
      CLOSE esn_curs;
      GOTO next_action_item;
    END IF;
    CLOSE esn_curs;
    --CR15983
    -- CR20451 | CR20854: Add TELCEL Brand   mod 2
    -- FOR check_st_esn_rec IN check_st_esn_curs (ig_trans_rec.esn,'BUS_ORG','STRAIGHT_TALK') LOOP
    FOR org_flow_rec IN org_flow_curs(ig_trans_rec.esn ,'3')
    LOOP
      IF ig_trans_rec.order_type = 'E' THEN
        sa.walmart_monthly_plans_pkg.run_single( p_transaction_id        => ig_trans_rec.transaction_id,
                                                 i_skip_pcrf_update_flag => 'Y' );
        ig_trans_rec.order_type := 'E';
      END IF;
    END LOOP;
    -- YM PM Start CR19595
    IF ig_trans_rec.order_type    IN ('AP' ,'PAP') OR                                                                                                                                                                                                     -- CR13531 STCC PM Included PAP.
      (ig_trans_rec.order_type    IN ('A','MINC') AND ig_trans_rec.template IN ('SUREPAY','SPRINT')) OR (ig_trans_rec.order_type IN ('A','MINC') AND ig_trans_rec.template IN ('RSS')AND sa.device_util_pkg.get_smartphone_fun(ig_trans_rec.esn) = 0 ) ----- TF Surepay CR23513 MVadlapally
      OR (ig_trans_rec.order_type IN ('E') AND ig_trans_rec.template IN ('SPRINT')) OR                                                                                                                                                                    -- PMistry 02/12/2011 CR18776 Sprint NT10 - UPGRADES.
      (ig_trans_rec.order_type    IN ('A' ,'E') AND esn_rec.non_ppe = '1' AND esn_rec.bus IN('NET10' ,'TRACFONE') AND esn_rec.dll <= 0)                                                                                                                   -- All Net 10 Non PPE with non OTA Transaction. -- CR31783
      THEN
      -- CR13980 PM 09/15/2010 -- SPRINT and MINC (for Verizon too) SKuthadi
      sa.walmart_monthly_plans_pkg.run_single ( p_transaction_id        => ig_trans_rec.transaction_id,
                                                i_skip_pcrf_update_flag => 'Y' );
      ig_trans_rec.order_type := 'A';
      -- YM PM END CR19595
    ELSE
      -- CR20451 | CR20854: Add TELCEL Brand   mod 3 GONNA LEAVE THIS ONE ALONE
      FOR check_st_esn_rec IN check_st_esn_curs(ig_trans_rec.esn ,'NON_PPE' ,'1')
      LOOP
        IF check_st_esn_rec.x_technology = 'GSM' THEN
          sa.walmart_monthly_plans_pkg.run_single ( p_transaction_id        => ig_trans_rec.transaction_id,
                                                    i_skip_pcrf_update_flag => 'Y' );
        END IF;
      END LOOP;
    END IF;
    l_recs_processed := l_recs_processed + 1;                                     --CR4947
    dbms_output.put_line('--start new trans_id:' || ig_trans_rec.transaction_id); -- CR 5008
    /* Start of CR4264: Line Status change for old MIN */
    BEGIN
      IF (ig_trans_rec.template NOT IN ('TMOBILE' ,'TMOUN' ,'TMOSM' )) -- CR25987 SIMPLE MOBILE SUSPEND2CANCEL
        AND ig_trans_rec.order_type IN ('D' ,'MINC') AND (ig_trans_rec.old_min IS NOT NULL) THEN
        -- CR13035 -- NTUL new template TMOUN
        UPDATE table_part_inst
        SET x_part_inst_status = DECODE(x_part_inst_status ,'13' ,x_part_inst_status ,'33' ,x_part_inst_status ,'17') ,
          status2x_code_table  = DECODE(status2x_code_table ,960 ,status2x_code_table ,965 ,status2x_code_table ,963)
          --CR21051 Start Kacosta 05/31/2012
          ,
          n_part_inst2part_mod =
          CASE
            WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
            THEN 23070541
            ELSE n_part_inst2part_mod
          END
          --CR21051 End Kacosta 05/31/2012
        WHERE part_serial_no = ig_trans_rec.old_min
		AND   x_domain       = 'LINES'; --EME 56766
        COMMIT;
        IF sa.toss_util_pkg.insert_pi_hist_fun(ig_trans_rec.old_min ,'LINES' ,'RETURNED MINC' ,'igate_in3') THEN
          NULL;
        END IF;
      END IF;
      OPEN ig_wi_detail_curs(ig_trans_rec.transaction_id);
      FETCH ig_wi_detail_curs INTO ig_wi_detail_rec;
      CLOSE ig_wi_detail_curs;
      OPEN task_curs(ig_trans_rec.action_item_id);
      FETCH task_curs INTO task_rec;
      IF task_curs%NOTFOUND THEN
        CLOSE task_curs;
        toss_util_pkg.insert_error_tab_proc('Retrieve task record' ,ig_trans_rec.action_item_id ,l_program_name ,'Task record for task id ' || ig_trans_rec.action_item_id || ' not found.');
        GOTO next_action_item;
      END IF;
      CLOSE task_curs;
      dbms_output.put_line('--task record:');
      OPEN user_curs(task_rec.task_originator2user);
      FETCH user_curs INTO user_rec;
      IF user_curs%NOTFOUND THEN
        CLOSE user_curs;
        toss_util_pkg.insert_error_tab_proc('Retrieve originator info of an action item' ,ig_trans_rec.action_item_id ,l_program_name ,'No user record found for user objid ' || NVL(TO_CHAR(task_rec.task_originator2user) ,'N/A'));
        GOTO next_action_item;
      END IF;
      CLOSE user_curs;
      dbms_output.put_line('--user  record:');
      OPEN call_trans_curs(task_rec.x_task2x_call_trans);
      FETCH call_trans_curs INTO call_trans_rec;
      IF call_trans_curs%NOTFOUND THEN
        CLOSE call_trans_curs;
        dbms_output.put_line('--ct no record:');
        toss_util_pkg.insert_error_tab_proc('Retrieve call trans record' ,ig_trans_rec.action_item_id ,l_program_name ,'No calltran record found for this calltran objid ' || NVL(TO_CHAR(task_rec.x_task2x_call_trans) ,'N/A'));
        --cwl 4/4/2011
        --calltrans doesn't exist --CR15983
        --CR19321 Start kacosta 12/23/2011
        failed_log(p_ig_trans_rec => ig_trans_rec);
        --CR19321 End kacosta 12/23/2011
        UPDATE gw1.ig_transaction
        SET status           = DECODE(status ,'E' ,'FF' ,'W' ,'SS' ,'EE')
        WHERE transaction_id = ig_trans_rec.transaction_id;
        COMMIT;
        --cwl 4/4/2011
        GOTO next_action_item;
      END IF;
      CLOSE call_trans_curs;
      OPEN site_part_curs(call_trans_rec.call_trans2site_part);
      FETCH site_part_curs INTO site_part_rec;
      IF site_part_curs%NOTFOUND THEN
        CLOSE site_part_curs;
        toss_util_pkg.insert_error_tab_proc('Retrieve site part record' ,ig_trans_rec.action_item_id ,l_program_name ,'No site part record found for this site part objid ' || NVL(TO_CHAR(call_trans_rec.call_trans2site_part) ,'N/A'));
        --cwl 4/4/2011  --CR15983
        --sitepart doesn't exist
        --CR19321 Start kacosta 12/23/2011
        failed_log(p_ig_trans_rec => ig_trans_rec);
        --CR19321 End kacosta 12/23/2011
        UPDATE gw1.ig_transaction
        SET status           = DECODE(status ,'E' ,'FF' ,'W' ,'SS' ,'EE')
        WHERE transaction_id = ig_trans_rec.transaction_id;
        COMMIT;
        --cwl 4/4/2011  --CR15983
        GOTO next_action_item;
      END IF;
      CLOSE site_part_curs;
      dbms_output.put_line('--sp record:');
      --cwl 4/4/2011  --CR15983
      --      IF         ig_trans_rec.x_next_available = 1 AND ig_trans_rec.x_technology = 'CDMA'
      --         OR (    ig_trans_rec.order_type = 'MINC' and ig_trans_rec.x_next_available = 0
      --             and ig_trans_rec.x_technology = 'CDMA') THEN
      --cwl 4/4/2011  --CR15983
      dbms_output.put_line('ig_trans_rec.x_technology:' || ig_trans_rec.x_technology);
      IF ig_trans_rec.x_technology = 'CDMA' THEN
        dbms_output.put_line('change for cdma next available');
        hold_msid_for_cdma_next_avail := ig_trans_rec.msid;
        ig_trans_rec.msid             := ig_trans_rec.min;
        ig_trans_rec.min              := site_part_rec.x_min;
        dbms_output.put_line('store min for cdma next available');
      ELSE
        hold_msid_for_cdma_next_avail := ig_trans_rec.msid;
      END IF;
      dbms_output.put_line('ig_trans_rec.msid:' || ig_trans_rec.msid);
      dbms_output.put_line('ig_trans_rec.min:' || ig_trans_rec.min);
      dbms_output.put_line('openning  order_type_curs cur');
      dbms_output.put_line('openning  order_type_curs cur');
      OPEN order_type_curs(task_rec.x_task2x_order_type);
      FETCH order_type_curs INTO order_type_rec;
      IF order_type_curs%NOTFOUND THEN
        dbms_output.put_line('updating ig_transaction inside  order_type_curs cur');
        failed_log(ig_trans_rec);
        UPDATE gw1.ig_transaction
        SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW') --CR16262 05/10/2011
        WHERE transaction_id = ig_trans_rec.transaction_id;
        COMMIT;
        dbms_output.put_line('updating ig_transaction inside  order_type_curs cur');
        CLOSE order_type_curs;
        GOTO next_action_item;
      END IF;
      CLOSE order_type_curs;
      dbms_output.put_line('opening  carrier_curs cur');
      OPEN carrier_curs(order_type_rec.x_order_type2x_carrier);
      FETCH carrier_curs INTO carrier_rec;
      IF carrier_curs%NOTFOUND THEN
        CLOSE carrier_curs;
        dbms_output.put_line('inserting error retrieve carrier rec');
        dbms_output.put_line('order type to carrier: ' || TO_CHAR(NVL(order_type_rec.x_order_type2x_carrier ,0)));
        toss_util_pkg.insert_error_tab_proc('Retrieve carrier record' ,ig_trans_rec.action_item_id ,l_program_name ,'No carrier record found for this carrier objid ' || TO_CHAR(NVL(order_type_rec.x_order_type2x_carrier ,0)));
        failed_log(ig_trans_rec); --CR15983
        UPDATE gw1.ig_transaction
        SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW') --CR16262 05/10/2011
        WHERE transaction_id = ig_trans_rec.transaction_id;
        COMMIT;
        GOTO next_action_item;
      END IF;
      CLOSE carrier_curs;
      /*** Getting Parent for carrier_id ***/
      OPEN parent_curs(carrier_rec.objid);
      FETCH parent_curs INTO parent_rec;
      CLOSE parent_curs;
      dbms_output.put_line('closing  carrier_curs cur');
      dbms_output.put_line('ig_trans_rec.new_msid_flag :' || ig_trans_rec.new_msid_flag);
      dbms_output.put_line('ig_trans_rec.status:' || ig_trans_rec.status);
      dbms_output.put_line('ig_trans_rec.order_type:' || ig_trans_rec.order_type);
      --cwl 2/3/2012 --CR15690
      -- *********************************************************************
      -- -- CR20451 | CR20854: Add TELCEL Brand AREA3
      -- ********************************************************************
      SELECT x_param_value
      INTO l_have_service_plans
      FROM table_x_parameters
      WHERE x_param_name = 'HAVE_SERVICE_PLANS';
      -- *********************************************************************
      -- -- CR20451 | CR20854: Add TELCEL Brand AREA3x
      -- ********************************************************************
      -----------****************************-----------
      -----------CR32641 - Start of ILD logic-----------
      -----------****************************-----------
   IF UPPER(ig_trans_rec.msid) NOT LIKE 'T%' THEN --CR34475
     LV_ILD               := NULL;
      LV_ACCOUNT           := NULL;
      LV_CODE              := NULL;
      LV_MESSAGE           := NULL;

     sa.ILD_TRANSACTION_PKG.GET_ILD_PARAMS_BY_SITEPART(
         IP_SITE_PART_OBJID => SITE_PART_REC.OBJID,
         IP_ESN => IG_TRANS_REC.ESN,
         IP_BUS_ORG => IG_TRANS_REC.BUS_ORG,
         OP_ILD_PRODUCT_ID => LV_ILD,
         OP_ILD_IG_ACCOUNT => LV_ACCOUNT,
         OP_ERR_NUM => LV_ERR_NUM,
         OP_ERR_STRING => LV_ERR_STRING
        );

	-- CR57251 NT 35 40 PROMO + ILD benefits for EPIR
	IF ig_trans_rec.order_type in ('EPIR') THEN
		BEGIN

			r_service_plan_rec := sa.service_plan.get_service_plan_by_esn(ig_trans_rec.esn);

			-- get the service plan from part_inst
			IF r_service_plan_rec.objid IS NULL THEN
				BEGIN
						SELECT  MV.SP_OBJID INTO r_service_plan_rec.objid
						FROM sa.TABLE_PART_INST PI, sa.TABLE_MOD_LEVEL ML, sa.TABLE_PART_NUM PN, sa.TABLE_BUS_ORG BO,sa.TABLE_PART_INST RED,sa.TABLE_PART_CLASS PC,sa.ADFCRM_SERV_PLAN_CLASS_MATVIEW MV
						WHERE RED.X_DOMAIN = 'REDEMPTION CARDS'
						AND RED.N_PART_INST2PART_MOD = ML.OBJID
						AND ML.PART_INFO2PART_NUM = PN.OBJID
						AND PN.PART_NUM2BUS_ORG=BO.OBJID
						AND PN.PART_NUM2PART_CLASS = PC.OBJID
						AND MV.PART_CLASS_NAME = PC.NAME
						AND RED.PART_TO_ESN2PART_INST = PI.OBJID
						AND PI.PART_SERIAL_NO = IG_TRANS_REC.ESN
						AND ROWNUM = 1;
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
			END IF;
			-- get the service plan from table_X_red_card
			IF r_service_plan_rec.objid IS NULL THEN
				BEGIN
					SELECT MV.SP_OBJID INTO r_service_plan_rec.objid
					FROM   sa.TABLE_X_RED_CARD RC ,
					sa.TABLE_X_CALL_TRANS CT,
						sa.TABLE_MOD_LEVEL ML ,
						sa.TABLE_PART_NUM PN,
						sa.ADFCRM_SERV_PLAN_CLASS_MATVIEW MV
						WHERE CT.OBJID               =  RC.RED_CARD2CALL_TRANS
						AND    PN.DOMAIN             = 'REDEMPTION CARDS'
						AND    ML.OBJID              = RC.X_RED_CARD2PART_MOD
						AND    ML.PART_INFO2PART_NUM = PN.OBJID
						AND   PN.PART_NUM2PART_CLASS = MV.PART_CLASS_OBJID
					  AND   CT.X_SERVICE_ID        = IG_TRANS_REC.ESN
					  AND ROWNUM = 1;
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
			END IF;
			-- check if promo is applicable
			SELECT 'Y' INTO NT_35_40_PROMO_ILD_FLAG
			FROM   sa.x_policy_rule_service_plan psp,
					 sa.x_policy_rule_config prc
			WHERE  psp.policy_rule_config_objid = prc.objid
			and    psp.service_plan_objid = r_service_plan_rec.objid
			and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y')
			and   SYSDATE BETWEEN prc.start_date and prc.end_date
			and ROWNUM = 1;

			IF NT_35_40_PROMO_ILD_FLAG = 'Y' THEN
				 BEGIN
				  SELECT PROMO_ILD_PRODUCT_ID, '1',substr(PROMO_ILD_PRODUCT_ID,1,2) INTO LV_ILD ,LV_ACCOUNT, LV_ILD_PRFX
				  FROM sa.SERVICE_PLAN_FEAT_PIVOT_MV WHERE SERVICE_PLAN_OBJID = r_service_plan_rec.objid;
				 EXCEPTION
				  WHEN OTHERS THEN
					  NULL;
				 END;

					BEGIN
						SELECT 'Y' INTO IS_AR_ENROLLED
						FROM sa.X_PROGRAM_ENROLLED
						WHERE 1=1
						AND X_ENROLLMENT_STATUS = 'ENROLLED'
						AND X_ESN = IG_TRANS_REC.ESN
						AND ROWNUM = 1;
					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;

					IF IS_AR_ENROLLED = 'Y' AND (LV_ILD_PRFX <> 'BP') THEN
						LV_ILD := 'BP'||LV_ILD;
					ENd IF;
			END IF;

		EXCEPTION
		  WHEN OTHERS THEN
		  NULL;
		END;
	END IF;
-- CR57251 for Reactivation within promo period scenario
	IF ( call_trans_rec.x_action_type in ('3') AND UPPER(call_trans_rec.X_REASON) = 'REACTIVATION') OR (ig_trans_rec.order_type in ('R')) THEN
		BEGIN
			r_service_plan_rec := sa.service_plan.get_service_plan_by_esn(ig_trans_rec.esn);

			SELECT 'Y' INTO NT_35_40_PROMO_REACT
			FROM   sa.x_policy_rule_service_plan psp,
					 sa.x_policy_rule_config prc
			WHERE  psp.policy_rule_config_objid = prc.objid
			and    psp.service_plan_objid = r_service_plan_rec.objid
			and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y')
			and   SYSDATE BETWEEN prc.start_date and prc.end_date
			and ROWNUM = 1;

			  BEGIN
				  SELECT 'Y' INTO IS_PROMO_REACT_MIN FROM sa.X_POLICY_RULE_SUBSCRIBER PRS
				  WHERE MIN = ig_trans_rec.min
				  AND NVL(INACTIVE_FLAG,'N') = 'Y'
				  AND EXISTS ( SELECT 1
								  FROM   sa.x_policy_rule_service_plan psp,
										 sa.x_policy_rule_config prc
								  WHERE  psp.policy_rule_config_objid = prc.objid
								  and PRS.COS = prc.cos
								  and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
			  EXCEPTION
				WHEN OTHERS THEN
				  NULL;
				END;

			IF NT_35_40_PROMO_REACT = 'Y' AND IS_PROMO_REACT_MIN = 'Y' THEN
				BEGIN
					  UPDATE sa.X_POLICY_RULE_SUBSCRIBER
					  SET INACTIVE_FLAG = 'N',
					  UPDATE_TIMESTAMP = SYSDATE,
					  esn = ig_trans_rec.esn
					  WHERE MIN = ig_trans_rec.min
					  AND COS IN ( SELECT DISTINCT  prc.cos
									  FROM   sa.x_policy_rule_service_plan psp,
											 sa.x_policy_rule_config prc
									  WHERE  psp.policy_rule_config_objid = prc.objid
									  and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
				EXCEPTION
				  WHEN OTHERS THEN
				  NULL;
				END;

				 BEGIN
				  SELECT PROMO_ILD_PRODUCT_ID,'1' INTO LV_ILD,LV_ACCOUNT
				  FROM sa.SERVICE_PLAN_FEAT_PIVOT_MV WHERE SERVICE_PLAN_OBJID = r_service_plan_rec.objid;
				 EXCEPTION
				  WHEN OTHERS THEN
					  NULL;
				 END;

				 IF r_service_plan_rec.objid in (265,273,266) THEN
					BEGIN
						SELECT 'Y' INTO IS_AR_ENROLLED
						FROM sa.X_PROGRAM_ENROLLED
						WHERE PGM_ENROLL2PGM_PARAMETER IN ( SELECT X_SP2PROGRAM_PARAM FROM sa.MTM_SP_X_PROGRAM_PARAM WHERE PROGRAM_PARA2X_SP = r_service_plan_rec.objid)
						AND X_ENROLLMENT_STATUS = 'ENROLLED'
						AND X_ESN = IG_TRANS_REC.ESN;

					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;

					IF IS_AR_ENROLLED = 'Y' THEN
						LV_ILD := 'BP'||LV_ILD;
					ENd IF;

				END IF;

			END IF;

		EXCEPTION
		  WHEN OTHERS THEN
		  NULL;
		END;
	END IF;

	-- CR57251	NT 35 40 PROMO + ILD benefits for EPIR
		-- to continue providing ILD benefits for the customers in promo ( NT 35/40 plan)
		  BEGIN
			  SELECT 'Y' INTO IS_PROMO_MIN FROM sa.X_POLICY_RULE_SUBSCRIBER PRS
			  WHERE MIN = ig_trans_rec.min
			  AND NVL(INACTIVE_FLAG,'N') = 'N'
			  AND EXISTS ( SELECT 1
							  FROM   sa.x_policy_rule_service_plan psp,
									 sa.x_policy_rule_config prc
							  WHERE  psp.policy_rule_config_objid = prc.objid
							  and PRS.COS = prc.cos
							  and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
		  EXCEPTION
			WHEN OTHERS THEN
			  NULL;
		  END;
		 --

	IF IS_PROMO_MIN = 'Y' AND (ig_trans_rec.order_type in ('R') OR (call_trans_rec.x_action_type = '1' and upper(call_trans_rec.X_REASON) = 'UPGRADE' ))  THEN

		BEGIN
			r_service_plan_rec := sa.service_plan.get_service_plan_by_esn(ig_trans_rec.esn);

			BEGIN
			   SELECT 1, PRC.COS INTO PROMO_SPOBJID , l_PROMO_COS
			FROM  sa.X_POLICY_RULE_SERVICE_PLAN PSP,
				 sa.X_POLICY_RULE_CONFIG PRC
			WHERE PSP.POLICY_RULE_CONFIG_OBJID = PRC.OBJID
			AND  PSP.SERVICE_PLAN_OBJID = r_service_plan_rec.objid
			AND  PSP.INACTIVE_FLAG = 'N'
			AND  (NT_35_PROMO_FLAG = 'Y' OR NT_40_PROMO_FLAG = 'Y');

			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;

			IF PROMO_SPOBJID = 1 THEN
			  SELECT PROMO_ILD_PRODUCT_ID,'1' INTO LV_ILD,LV_ACCOUNT
			  FROM sa.SERVICE_PLAN_FEAT_PIVOT_MV WHERE SERVICE_PLAN_OBJID = r_service_plan_rec.objid;


				IF r_service_plan_rec.objid in (265,273,266) THEN
					BEGIN
						SELECT 'Y' INTO IS_AR_ENROLLED
						FROM sa.X_PROGRAM_ENROLLED
						WHERE PGM_ENROLL2PGM_PARAMETER IN ( SELECT X_SP2PROGRAM_PARAM FROM sa.MTM_SP_X_PROGRAM_PARAM WHERE PROGRAM_PARA2X_SP = r_service_plan_rec.objid)
						AND X_ENROLLMENT_STATUS = 'ENROLLED'
						AND X_ESN = IG_TRANS_REC.ESN;

					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;

					IF IS_AR_ENROLLED = 'Y' THEN
						LV_ILD := 'BP'||LV_ILD;
					ENd IF;

				END IF;

				BEGIN
					  UPDATE sa.X_POLICY_RULE_SUBSCRIBER PRS
					  SET COS = l_PROMO_COS,
					  UPDATE_TIMESTAMP = SYSDATE,
					  esn = ig_trans_rec.esn
					  WHERE MIN = ig_trans_rec.min
					  AND EXISTS ( SELECT 1
									  FROM   sa.x_policy_rule_service_plan psp,
											 sa.x_policy_rule_config prc
									  WHERE  psp.policy_rule_config_objid = prc.objid
									  and PRS.COS = prc.cos
									  and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
				EXCEPTION
				  WHEN OTHERS THEN
				  NULL;
				END;
			ELSE
				BEGIN
					  UPDATE sa.X_POLICY_RULE_SUBSCRIBER PRS
					  SET INACTIVE_FLAG = 'Y',
					  UPDATE_TIMESTAMP = SYSDATE
					  WHERE MIN = ig_trans_rec.min
					  AND EXISTS ( SELECT 1
									  FROM   sa.x_policy_rule_service_plan psp,
											 sa.x_policy_rule_config prc
									  WHERE  psp.policy_rule_config_objid = prc.objid
									  and PRS.COS = prc.cos
									  and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
				EXCEPTION
				  WHEN OTHERS THEN
				  NULL;
				END;
			END IF;
		EXCEPTION
		  WHEN OTHERS THEN
		  NULL;
		END;

	ENd IF;

	 BEGIN
			  SELECT 'Y' INTO IS_PROMO_ESN FROM sa.X_POLICY_RULE_SUBSCRIBER PRS
			  WHERE ESN = ig_trans_rec.esn
			  AND NVL(INACTIVE_FLAG,'N') = 'N'
			  AND EXISTS ( SELECT 1
							  FROM   sa.x_policy_rule_service_plan psp,
									 sa.x_policy_rule_config prc
							  WHERE  psp.policy_rule_config_objid = prc.objid
							  and PRS.COS = prc.cos
							  and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
		  EXCEPTION
			WHEN OTHERS THEN
			  NULL;
		  END;

	IF IS_PROMO_ESN = 'Y' AND ig_trans_rec.order_type in ('MINC') THEN
			BEGIN
					  UPDATE sa.X_POLICY_RULE_SUBSCRIBER PRS
					  SET INACTIVE_FLAG = 'Y',
					  UPDATE_TIMESTAMP = SYSDATE
					  WHERE esn = ig_trans_rec.min
					  AND EXISTS ( SELECT 1
									  FROM   sa.x_policy_rule_service_plan psp,
											 sa.x_policy_rule_config prc
									  WHERE  psp.policy_rule_config_objid = prc.objid
									  and PRS.COS = prc.cos
									  and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
				EXCEPTION
				  WHEN OTHERS THEN
				  NULL;
				END;
	END IF;

	-- END CR57251
    IF IG_TRANS_REC.ORDER_TYPE IN ('D','S') THEN
      LV_ACCOUNT := 0;
    END IF;
    -- CR54900 Starts
	lv_ild_flag := 'Y';
	IF ig_trans_rec.bus_org        = 'TRACFONE'
	   AND ig_trans_rec.order_type = 'R'
	   AND NVL(sa.get_device_type(ig_trans_rec.esn),'X') = 'FEATURE_PHONE' THEN
	   sa.carrier_is_swb_rate_plan.sp_swb_carr_rate_plan(ig_trans_rec.esn,
														 op_last_rate_plan_sent,
														 op_is_swb_carr,
														 op_error_code,
														 op_error_message );
		IF  op_is_swb_carr = 'Non-Switch Base' THEN
			lv_ild_flag := 'N';
		END IF;
	END IF;
	-- CR54900 Ends
      IF LV_ILD IS NOT NULL
        AND LV_ILD != 'ERR_BRAND'
        AND IG_TRANS_REC.ORDER_TYPE NOT IN ('D','S')
		AND lv_ild_flag = 'Y' -- Added as part of CR54900
		THEN

      sa.ILD_TRANSACTION_PKG.INSERT_TABLE_X_ILD_TRANS(
            NULL --DEV
            ,
            ig_trans_rec.msid --X_MIN
            ,
            ig_trans_rec.esn --X_ESN
            ,
            SYSDATE --X_TRANSACT_DATE
            ,
            ig_trans_rec.order_type --X_ILD_TRANS_TYPE
            ,
            'PENDING' --X_ILD_STATUS
            ,
            SYSDATE --X_LAST_UPDATE
            ,
            LV_ACCOUNT --X_ILD_ACCOUNT
            ,
            NULL --ILD_TRANS2SITE_PART
            ,
            NULL --ILD_TRANS2USER
            ,
            1 --X_CONV_RATE
            ,
            NULL --X_TARGET_SYSTEM
            ,
            LV_ILD --X_PRODUCT_ID
            ,
            NULL --X_API_STATUS
            ,
            NULL --X_API_MESSAGE
            ,
            ig_trans_rec.transaction_id --X_ILD_TRANS2IG_TRANS_ID
            ,
            ig_trans_rec.x_task2x_call_trans --X_ILD_TRANS2CALL_TRANS
            ,LV_X_ILD_OBJID
         ,LV_ERR_NUM
         ,LV_ERR_STRING
          );
        DBMS_OUTPUT.PUT_LINE('LV_X_ILD_OBJID: '||LV_X_ILD_OBJID);
      END IF;
   END IF; --CR34475
      -----------****************************-----------
      -----------CR32641 - End of ILD logic  -----------
      -----------****************************-----------
      --cwl 2/3/2012 --CR15690
      --cwl 1/2/2015
      OPEN test_family_plan_curs(ig_trans_rec.esn, ig_trans_rec.order_type);
      FETCH test_family_plan_curs INTO test_family_plan_rec;
      IF test_family_plan_curs%found AND test_family_plan_rec.create_so_gencode_flag = 'Y' -- Order types = A, E, EPIR, IPI, PIR
        THEN
        INSERT
        INTO x_service_order_stage
          (
            objid ,
            account_group_member_id ,
            esn ,
            sim ,
            zipcode ,
            smp ,
            service_plan_id ,
            case_id ,
            status ,
            type ,
            program_param_id ,
            pmt_source_id ,
            web_objid ,
            bus_org_id ,
            insert_timestamp ,
            update_timestamp
          )
          VALUES
          (
            sa.sequ_service_order_stage.nextval ,
            test_family_plan_rec.objid ,
            ig_trans_rec.esn ,
            NULL ,
            NULL ,
            NULL ,
            NULL ,
            NULL ,
            'QUEUED' ,
            'GENCODE' ,
            NULL ,
            'IGATE_IN3' ,
            NULL ,
            test_family_plan_rec.bus_org_id ,
            SYSDATE ,
            SYSDATE
          );
      END IF;
      CLOSE test_family_plan_curs;

      -- CR42459
                  -- Now check the service plan.
            x_service_plan_rec := sa.service_plan.get_service_plan_by_esn(ig_trans_rec.esn);
            BEGIN
               SELECT sa.get_serv_plan_value(x_service_plan_rec.objid, 'PLAN TYPE')
                 INTO v_service_plan_group
                 FROM DUAL;

            EXCEPTION WHEN OTHERS THEN
               v_service_plan_group := NULL;

            END;


      IF ig_trans_rec.order_type IN ('E', 'EPIR', 'IPI', 'PIR') THEN
         OPEN test_ppe_switch_curs(ig_trans_rec.esn, ig_trans_rec.order_type);
         FETCH test_ppe_switch_curs INTO test_ppe_switch_rec;
         IF test_ppe_switch_curs%found THEN
            IF test_family_plan_rec.create_so_gencode_flag = 'Y' -- Order types = A, E, EPIR, IPI, PIR
               THEN
                  INSERT INTO x_service_order_stage
                              (
                               objid ,
                               account_group_member_id ,
                               esn ,
                               sim ,
                               zipcode ,
                               smp ,
                               service_plan_id ,
                               case_id ,
                               status ,
                               type ,
                               program_param_id ,
                               pmt_source_id ,
                               web_objid ,
                               bus_org_id ,
                               insert_timestamp ,
                               update_timestamp
                             )
                             VALUES
                             (
                               sa.sequ_service_order_stage.nextval ,
                               test_ppe_switch_rec.objid ,
                               ig_trans_rec.esn ,
                               NULL ,
                               NULL ,
                               NULL ,
                               NULL ,
                               NULL ,
                               'QUEUED' ,
                               'GENCODE' ,
                               NULL ,
                               'IGATE_IN3' ,
                               NULL ,
                               test_ppe_switch_rec.bus_org_id ,
                               SYSDATE ,
                               SYSDATE
                             );
            END IF;  -- test_family_plan_rec.create_so_gencode_flag
            CLOSE test_ppe_switch_curs;
         ELSE
            CLOSE test_ppe_switch_curs;
         END IF;  -- test_ppe_switch_curs%found
      END IF;  -- ig_trans_rec.order_type



      --cwl 1/2/2015
      IF ig_trans_rec.new_msid_flag IS NULL AND ig_trans_rec.status = 'W' AND NVL(ig_order_type_rec.skip_min_update_flag,'N') = 'N'-- CR51036
      --AND ig_trans_rec.order_type NOT IN ('D' ,'S')
      THEN
        UPDATE table_part_inst
        SET x_part_inst_status =
          CASE
            WHEN ig_trans_rec.x_technology    = 'GSM'
            OR (ig_trans_rec.x_next_available = 1
            AND ig_trans_rec.x_technology     = 'CDMA')
            THEN '13'
            WHEN (ig_trans_rec.x_next_available != 1
            AND ig_trans_rec.x_technology        = 'CDMA')
            THEN '110'
            ELSE x_part_inst_status
          END ,
          status2x_code_table =
          CASE
            WHEN ig_trans_rec.x_technology    = 'GSM'
            OR (ig_trans_rec.x_next_available = 1
            AND ig_trans_rec.x_technology     = 'CDMA')
            THEN 960
            WHEN (ig_trans_rec.x_next_available != 1
            AND ig_trans_rec.x_technology        = 'CDMA')
            THEN 268438300
            ELSE status2x_code_table
          END
          --CR21051 Start Kacosta 05/31/2012
          ,
          n_part_inst2part_mod =
          CASE
            WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
            THEN 23070541
            ELSE n_part_inst2part_mod
          END
          --CR21051 End Kacosta 05/31/2012
        WHERE part_serial_no = ig_trans_rec.min
		AND   x_domain       = 'LINES'; --EME 56766;
        /** CR12825 **/
      ELSIF (ig_trans_rec.new_msid_flag = 'Y') THEN
        --cwl 4/22/2011 --CR16262
        IF ((ig_trans_rec.technology_flag = 'G' AND ig_trans_rec.msid LIKE 'T%') OR (ig_trans_rec.technology_flag = 'C' AND (ig_trans_rec.msid LIKE 'T%' OR hold_msid_for_cdma_next_avail LIKE 'T%'))) THEN
          toss_util_pkg.insert_error_tab_proc('ig not updating T-numbers ' ,ig_trans_rec.action_item_id ,l_program_name ,'ig min or msid data not correct ' || NVL(LTRIM(ig_trans_rec.msid) ,'N/A'));
          dbms_output.put_line('ig not updating T-numbers');
          failed_log(ig_trans_rec);
          UPDATE gw1.ig_transaction
          SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW' ,'CP' ,'HCP' ,'HH') --CR16262 05/10/2011
          WHERE transaction_id = ig_trans_rec.transaction_id;
          COMMIT;
          GOTO next_action_item;
        END IF;
        --cwl 4/22/2011
        dbms_output.put_line('opening min_curs  ');
        IF ig_trans_rec.order_type IN ('MINC' ,'E' ,'A') THEN
          dbms_output.put_line('opening min_curs ig_trans_rec.order_type:' || ig_trans_rec.order_type);
          OPEN min_curs(ig_trans_rec.msid); --CR15983
          FETCH min_curs INTO min_rec;
          IF min_curs%NOTFOUND THEN
            IF (ig_trans_rec.x_next_available = 0 AND ig_trans_rec.x_no_inventory = 0) THEN
              toss_util_pkg.insert_error_tab_proc('Retrieve min_curs record from part inst' ,ig_trans_rec.action_item_id ,l_program_name ,'No min record found for inventory carrier ' || NVL(LTRIM(ig_trans_rec.msid) ,'N/A'));
              dbms_output.put_line('No min record found for inventory carrier ');
              failed_log(ig_trans_rec);
              UPDATE gw1.ig_transaction
              SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW' ,'CP' ,'HCP' ,'HH') --CR16262 05/10/2011
              WHERE transaction_id = ig_trans_rec.transaction_id;
              COMMIT;
              CLOSE min_curs;
              GOTO next_action_item;
            END IF;
            dbms_output.put_line('min:oldmin in site_part::' || ig_trans_rec.min || ':' || site_part_rec.x_min);
            OPEN part_inst_curs(ig_trans_rec.min ,site_part_rec.x_min);
            FETCH part_inst_curs INTO part_inst_rec;
            --cwl 4/22/2011 CR16262
            IF part_inst_curs%NOTFOUND THEN
              IF recreate_tmin(ig_trans_rec.action_item_id) THEN
                CLOSE part_inst_curs;
                OPEN part_inst_curs(ig_trans_rec.min ,site_part_rec.x_min);
                FETCH part_inst_curs INTO part_inst_rec;
                IF part_inst_curs%NOTFOUND THEN
                  toss_util_pkg.insert_error_tab_proc('Retrieve esn_min record from part inst' ,ig_trans_rec.action_item_id ,l_program_name ,'No esn_min record found ' || NVL(LTRIM(ig_trans_rec.min) ,'N/A'));
                  dbms_output.put_line('exit part_inst_curs not found log error  ');
                  failed_log(ig_trans_rec);
                  UPDATE gw1.ig_transaction
                  SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW' ,'CP' ,'HCP' ,'HH') --CR16262 05/10/2011
                  WHERE transaction_id = ig_trans_rec.transaction_id;
                  COMMIT;
                  CLOSE min_curs;
                  CLOSE part_inst_curs;
                  GOTO next_action_item;
                ELSE
                  blnresult := toppapp.line_insert_pkg.insert_line_rec(hold_msid_for_cdma_next_avail , --CR15983
                  ig_trans_rec.msid ,SUBSTR(ig_trans_rec.msid ,1 ,3) ,SUBSTR(ig_trans_rec.msid ,4 ,3) ,SUBSTR(ig_trans_rec.msid ,7) ,ig_trans_rec.template || '_' || SYSDATE ,part_inst_rec.warr_end_date ,part_inst_rec.x_cool_end_date ,part_inst_rec.x_part_inst_status ,part_inst_rec.n_part_inst2part_mod ,part_inst_rec.part_inst2x_pers ,part_inst_rec.part_inst2carrier_mkt ,part_inst_rec.status2x_code_table ,part_inst_rec.created_by2user);
                  IF blnresult = FALSE THEN
                    toss_util_pkg.insert_error_tab_proc('unable to insert new number into part inst' ,ig_trans_rec.action_item_id ,l_program_name ,'can not create part_inst for ' || NVL(LTRIM(ig_trans_rec.msid) ,'N/A'));
                    dbms_output.put_line('unable to insert new number into part inst');
                    failed_log(ig_trans_rec);
                    UPDATE gw1.ig_transaction
                    SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW' ,'CP' ,'HCP' ,'HH') --CR16262 05/10/2011
                    WHERE transaction_id = ig_trans_rec.transaction_id;
                    COMMIT;
                    CLOSE min_curs;
                    CLOSE part_inst_curs;
                    GOTO next_action_item;
                  END IF;
                  l_ins_pihist_flag := toss_util_pkg.insert_pi_hist_fun(ig_trans_rec.msid ,'LINES' ,'LINE_BATCH' ,l_program_name);
                END IF;
                l_ins_pihist_flag := toss_util_pkg.insert_pi_hist_fun(ig_trans_rec.msid ,'LINES' ,'ACTIVATE' ,l_program_name);
              ELSE
                toss_util_pkg.insert_error_tab_proc('Recreate tmin failed' ,ig_trans_rec.action_item_id ,l_program_name ,'No esn_min record found ' || NVL(LTRIM(ig_trans_rec.min) ,'N/A'));
                dbms_output.put_line('recreate tmin failed');
                failed_log(ig_trans_rec);
                UPDATE gw1.ig_transaction
                SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW' ,'CP' ,'HCP' ,'HH') --CR16262 05/10/2011
                WHERE transaction_id = ig_trans_rec.transaction_id;
                COMMIT;
                CLOSE min_curs;
                CLOSE part_inst_curs;
                GOTO next_action_item;
              END IF;
            ELSE
              blnresult := toppapp.line_insert_pkg.insert_line_rec(hold_msid_for_cdma_next_avail , --CR15983
              ig_trans_rec.msid ,SUBSTR(ig_trans_rec.msid ,1 ,3) ,SUBSTR(ig_trans_rec.msid ,4 ,3) ,SUBSTR(ig_trans_rec.msid ,7) ,ig_trans_rec.template || '_' || SYSDATE ,part_inst_rec.warr_end_date ,part_inst_rec.x_cool_end_date ,part_inst_rec.x_part_inst_status ,part_inst_rec.n_part_inst2part_mod ,part_inst_rec.part_inst2x_pers ,part_inst_rec.part_inst2carrier_mkt ,part_inst_rec.status2x_code_table ,part_inst_rec.created_by2user);
              IF blnresult = FALSE THEN
                toss_util_pkg.insert_error_tab_proc('unable to insert new number into part inst' ,ig_trans_rec.action_item_id ,l_program_name ,'can not create part_inst for ' || NVL(LTRIM(ig_trans_rec.msid) ,'N/A'));
                dbms_output.put_line('unable to insert new number into part inst');
                failed_log(ig_trans_rec);
                UPDATE gw1.ig_transaction
                SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW' ,'CP' ,'HCP' ,'HH') --CR16262 05/10/2011
                WHERE transaction_id = ig_trans_rec.transaction_id;
                COMMIT;
                CLOSE min_curs;
                CLOSE part_inst_curs;
                GOTO next_action_item;
              END IF;
              l_ins_pihist_flag := toss_util_pkg.insert_pi_hist_fun(ig_trans_rec.msid ,'LINES' ,'LINE_BATCH' ,l_program_name);
              l_ins_pihist_flag := toss_util_pkg.insert_pi_hist_fun(ig_trans_rec.msid ,'LINES' ,'ACTIVATE' ,l_program_name);
            END IF;
            --cwl 4/22/2011
            CLOSE part_inst_curs;
          END IF;
          CLOSE min_curs;
        END IF;
        dbms_output.put_line('opening min_curs  ');
        --CR15983
        OPEN min_curs(ig_trans_rec.msid);
        FETCH min_curs INTO min_rec;
        --cwl 4/22/2011 CR16262
        IF min_curs%NOTFOUND AND  NVL(ig_order_type_rec.SKIP_MIN_VALIDATION_FLAG,'N') = 'N'  --FOR CR36850 changes
        THEN
          -- CR55771 : Commented error log table insert : spagidala  01/8/2009
		  --toss_util_pkg.insert_error_tab_proc('new msid not found in part inst' ,ig_trans_rec.action_item_id ,l_program_name ,'can not find new msid ' || NVL(LTRIM(ig_trans_rec.msid) ,'N/A'));
          dbms_output.put_line('new msid not found in part inst');
          failed_log(ig_trans_rec);
          UPDATE gw1.ig_transaction
          SET status           = DECODE(status ,'E' ,'F' ,'W' ,'HW' ,'CP' ,'HCP' ,'HH') --CR16262 05/10/2011
          WHERE transaction_id = ig_trans_rec.transaction_id;
          COMMIT;
          CLOSE min_curs;
          GOTO next_action_item;
        END IF;
        --cwl 4/22/2011
        CLOSE min_curs;
        IF ig_trans_rec.order_type IN ('MINC' ,'E' ,'A') THEN
          UPDATE table_x_ild_transaction
          SET x_ild_status = 'Pending' ,
            x_min          = ig_trans_rec.msid ,
            x_last_update  = SYSDATE
          WHERE x_esn      = ig_trans_rec.esn
          AND x_ild_status = 'Hold'
          AND x_min        = ig_trans_rec.min;
          -- CR21443 CR22413 VAS IC BEGIN
          IF ig_trans_rec.order_type ='MINC' THEN
            sa.vas_management_pkg.UpdateSubscriptionforMINC (ig_trans_rec.old_min,ig_trans_rec.min,op_msg,op_status) ;
          END IF ;
          -- CR21443 CR22413 VAS IC END
          ----------------------------
          --  Delete the dummy line --
          ----------------------------
          dbms_output.put_line('opening min_curs 2:5 '); -- CR 5008 --CR15983
          IF ig_trans_rec.min LIKE 'T%' THEN
            dbms_output.put_line('opening min_curs 2:6 ');
            DELETE
            FROM table_part_inst
            WHERE part_serial_no = ig_trans_rec.min
            AND x_domain         = 'LINES';
            DELETE FROM table_x_pi_hist WHERE x_part_serial_no = ig_trans_rec.min;
          END IF;
          ----------------------------------------------------------------------
          -- If the ESN is not active, set the status of the line to Reserved --
          -- so that we give this line to the customer when he reactivates.   --
          ----------------------------------------------------------------------
          dbms_output.put_line('opening min_curs 2:3 '); -- CR 5008
          IF esn_rec.x_part_inst_status != '52' THEN
            dbms_output.put_line('opening min_curs 2:4 ');
            OPEN code_curs('37');
            FETCH code_curs INTO code_rec;
            CLOSE code_curs;
            UPDATE table_part_inst
            SET x_part_inst_status = '37' ,
              status2x_code_table  = code_rec.objid
              --CR21051 Start Kacosta 05/31/2012
              ,
              n_part_inst2part_mod =
              CASE
                WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
                THEN 23070541
                ELSE n_part_inst2part_mod
              END
              --CR21051 End Kacosta 05/31/2012
            WHERE objid = min_rec.objid;
          END IF;
          ----------------------------------------------
          --  Set the relation between line and phone --
          ----------------------------------------------
          dbms_output.put_line('opening min_curs 2:2 '); -- CR 5008 --CR15983
          UPDATE table_part_inst tpi
          SET tpi.part_to_esn2part_inst = esn_rec.objid ,
            tpi.part_inst2carrier_mkt   = call_trans_rec.x_call_trans2carrier ,
            tpi.part_inst2x_pers        = carrier_rec.carrier2personality
            --CR21051 Start Kacosta 05/31/2012
            ,
            n_part_inst2part_mod =
            CASE
              WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
              THEN 23070541
              ELSE n_part_inst2part_mod
            END
            --CR21051 End Kacosta 05/31/2012
          WHERE tpi.objid = min_rec.objid
            -- Start CR12399 kacosta
          AND NOT EXISTS
            (SELECT 1
            FROM table_site_part tsp
            WHERE tsp.x_min      = tpi.part_serial_no
            AND tsp.part_status IN ('CarrierPending' ,'Active')
            );
          -- End CR12399 kacosta
          ---------------------------------------------------
          -- Set the part_inst2x_pers relation for the ESN --
          ---------------------------------------------------
          UPDATE table_part_inst
          SET part_inst2x_pers = min_rec.part_inst2x_pers
          WHERE objid          = esn_rec.objid;
          -----------------------------------------------
          -- Update Site_part and Call Trans with Line --
          -----------------------------------------------
          dbms_output.put_line('opening min_curs 2:6:1: site_part_objid ' || call_trans_rec.call_trans2site_part);
          --cwl 4/22/2011 --CR16262
          DECLARE
            CURSOR c1
            IS
              SELECT sp2.objid ,
                sp2.x_service_id ,
                sp2.install_date
              FROM table_site_part sp2 ,
                table_site_part sp1
              WHERE 1              = 1
              AND sp2.x_service_id = sp1.x_service_id
              AND sp2.install_date = sp1.install_date
              AND sp2.objid       != call_trans_rec.objid
              AND sp1.objid        = call_trans_rec.objid;
            CURSOR c2 ( c_objid IN NUMBER ,c_service_id IN VARCHAR2 ,c_install_date IN DATE )
            IS
              SELECT 1 col1
              FROM table_site_part sp
              WHERE sp.x_service_id = c_service_id
              AND sp.install_date   = c_install_date
              AND sp.objid         != c_objid;
            c2_rec c2%ROWTYPE;
          BEGIN
            FOR c1_rec IN c1
            LOOP
              FOR i IN 0 .. 100
              LOOP
                OPEN c2(c1_rec.objid ,c1_rec.x_service_id ,c1_rec.install_date + (i / (60 * 60 * 24)));
                FETCH c2 INTO c2_rec;
                IF c2%NOTFOUND THEN
                  UPDATE table_site_part
                  SET part_status = 'Obsolete' ,
                    install_date  = install_date + (i / (60 * 60 * 24))
                  WHERE objid     = c1_rec.objid;
                  CLOSE c2;
                  EXIT;
                END IF;
                CLOSE c2;
              END LOOP;
            END LOOP;
          END;
          DECLARE
            CURSOR c1
            IS
              SELECT sp.objid ,
                sp.x_service_id ,
                sp.install_date
              FROM table_site_part sp
              WHERE sp.x_min != ig_trans_rec.msid
              AND sp.objid    = call_trans_rec.call_trans2site_part;
            CURSOR c2 ( c_objid IN NUMBER ,c_service_id IN VARCHAR2 ,c_install_date IN DATE )
            IS
              SELECT 1 col1
              FROM table_site_part sp
              WHERE sp.x_service_id = c_service_id
              AND sp.install_date   = c_install_date
              AND sp.objid         != c_objid;
            c2_rec c2%ROWTYPE;
          BEGIN
            FOR c1_rec IN c1
            LOOP
              FOR i IN 0 .. 100
              LOOP
                OPEN c2(c1_rec.objid ,c1_rec.x_service_id ,c1_rec.install_date + (i / (60 * 60 * 24)));
                FETCH c2 INTO c2_rec;
                IF c2%NOTFOUND THEN
                  UPDATE table_site_part
                  SET x_min      = ig_trans_rec.msid ,
                    install_date = install_date + (i / (60 * 60 * 24))
                  WHERE objid    = c1_rec.objid;
                  CLOSE c2;
                  EXIT;
                END IF;
                CLOSE c2;
              END LOOP;
            END LOOP;
          END;
          --cwl 4/22/2011 --CR162
          dbms_output.put_line('opening min_curs msid 2:6:1: ' || ig_trans_rec.msid); -- CR 5008
          dbms_output.put_line('opening min_curs min  2:6:1: ' || ig_trans_rec.min);  -- CR 5008
          dbms_output.put_line('opening min_curs 2:6:2 ' || call_trans_rec.objid);    -- CR 5008
          DECLARE
            CURSOR c1
            IS
              SELECT ct2.objid ,
                ct2.x_service_id ,
                ct2.x_transact_date
              FROM table_x_call_trans ct2 ,
                table_x_call_trans ct1
              WHERE 1                 = 1
              AND ct2.x_service_id    = ct1.x_service_id
              AND ct2.x_transact_date = ct1.x_transact_date
              AND ct2.x_action_type   = ct1.x_action_type
              AND ct2.objid          != call_trans_rec.objid
              AND ct1.objid           = call_trans_rec.objid;
            CURSOR c2 ( c_objid IN NUMBER ,c_service_id IN VARCHAR2 ,c_transact_date IN DATE )
            IS
              SELECT 1 col1
              FROM table_x_call_trans ct
              WHERE ct.x_service_id  = c_service_id
              AND ct.x_transact_date = c_transact_date
              AND ct.objid          != c_objid;
            c2_rec c2%ROWTYPE;
          BEGIN
            FOR c1_rec IN c1
            LOOP
              FOR i IN 0 .. 100
              LOOP
                OPEN c2(c1_rec.objid ,c1_rec.x_service_id ,c1_rec.x_transact_date + (i / (60 * 60 * 24)));
                FETCH c2 INTO c2_rec;
                IF c2%NOTFOUND THEN
                  UPDATE table_x_call_trans
                  SET x_result      = 'Failed' ,
                    x_transact_date = x_transact_date + (i / (60 * 60 * 24))
                  WHERE objid       = c1_rec.objid;
                  CLOSE c2;
                  EXIT;
                END IF;
                CLOSE c2;
              END LOOP;
            END LOOP;
          END;
          DECLARE
            CURSOR c1
            IS
              SELECT ct.objid ,
                x_service_id ,
                x_transact_date
              FROM table_x_call_trans ct
              WHERE ct.x_min          != ig_trans_rec.msid
              AND call_trans2site_part = call_trans_rec.call_trans2site_part;
            CURSOR c2 ( c_objid IN NUMBER ,c_service_id IN VARCHAR2 ,c_transact_date IN DATE )
            IS
              SELECT 1 col1
              FROM table_x_call_trans ct
              WHERE ct.x_service_id  = c_service_id
              AND ct.x_transact_date = c_transact_date
              AND ct.objid          != c_objid;
            c2_rec c2%ROWTYPE;
          BEGIN
            FOR c1_rec IN c1
            LOOP
              FOR i IN 0 .. 100
              LOOP
                OPEN c2(c1_rec.objid ,c1_rec.x_service_id ,c1_rec.x_transact_date + (i / (60 * 60 * 24)));
                FETCH c2 INTO c2_rec;
                IF c2%NOTFOUND THEN
                  UPDATE table_x_call_trans
                  SET x_min         = ig_trans_rec.msid ,
                    x_transact_date = x_transact_date + (i / (60 * 60 * 24))
                  WHERE objid       = c1_rec.objid;
                  CLOSE c2;
                  EXIT;
                END IF;
                CLOSE c2;
              END LOOP;
            END LOOP;
          END;
          --4/4/2011 cwl  --CR15983
        END IF;
        dbms_output.put_line('opening min_curs 2:6:4 '); -- CR 5008
        dbms_output.put_line('opening min_curs 2:7 ');   -- CR 5008
        --cwl 1/2/2015
        OPEN test_family_plan_curs(ig_trans_rec.esn, ig_trans_rec.order_type);
        FETCH test_family_plan_curs INTO test_family_plan_rec;
        IF test_family_plan_curs%notfound AND call_trans_rec.x_ota_type = ota_util_pkg.ota_activation THEN
          dbms_output.put_line('opening min_curs 2:8 '); -- CR 5008
          UPDATE table_x_ota_transaction
          SET x_min                      = ig_trans_rec.msid
          WHERE x_ota_trans2x_call_trans = call_trans_rec.objid;
        END IF;
        CLOSE test_family_plan_curs;
        --cwl 1/2/2015
        UPDATE gw1.ig_transaction
        SET new_msid_flag = 'PROCESSED'
        WHERE ROWID       = ig_trans_rec.rowid;
        dbms_output.put_line('opening min_curs 2:9 ');                     -- CR 5008
        IF (ig_trans_rec.template NOT IN ('TMOBILE' ,'TMOUN'               -- CR13035 -- NTUL new TMOUN template
          ,'TMOSM')                                                        -- CR25987 SIMPLE MOBILE SUSPEND2CANCEL
          AND ig_trans_rec.order_type NOT IN ('D' ,'S'))                   -- CR13463
          OR ((ig_trans_rec.template      IN ('TMOBILE' ,'TMOUN' ,'TMOSM') -- CR25987 SIMPLE MOBILE SUSPEND2CANCEL
              AND NVL(esn_rec.x_part_inst_status ,'0') = '52') OR ota_activation_pending(ig_trans_rec.esn)) THEN
          dbms_output.put_line('opening min_curs 2:10 '); -- CR 5008
          OPEN min_still_exists_curs(min_rec.objid);
          FETCH min_still_exists_curs INTO min_still_exists_rec;
          IF min_still_exists_curs%FOUND THEN
            dbms_output.put_line('opening min_curs 2:10 :' || ig_trans_rec.msid);           -- CR 5008
            dbms_output.put_line('opening min_curs 2:10:min_rec.rowid: ' || min_rec.rowid); -- CR 5008
            dbms_output.put_line('opening min_curs 2:10 ');
            dbms_output.put_line('opening min_curs 2:10: ' || ig_trans_rec.x_technology);
            dbms_output.put_line('opening min_curs 2:10: ' || ig_trans_rec.x_next_available);
            IF NVL(ig_order_type_rec.skip_min_update_flag,'N') = 'N'-- CR51036
            THEN
            UPDATE table_part_inst
            SET x_part_inst_status =
              CASE
                WHEN ig_trans_rec.x_technology    = 'GSM'
                OR (ig_trans_rec.x_next_available = 1
                AND ig_trans_rec.x_technology     = 'CDMA')
                THEN '13'
                WHEN (ig_trans_rec.x_next_available != 1
                AND ig_trans_rec.x_technology        = 'CDMA')
                THEN '110'
                ELSE x_part_inst_status
              END ,
              status2x_code_table =
              CASE
                WHEN ig_trans_rec.x_technology    = 'GSM'
                OR (ig_trans_rec.x_next_available = 1
                AND ig_trans_rec.x_technology     = 'CDMA')
                THEN 960
                WHEN (ig_trans_rec.x_next_available != 1
                AND ig_trans_rec.x_technology        = 'CDMA')
                THEN 268438300
                ELSE status2x_code_table
              END ,
              --CR8427  --CR15983
              x_msid = hold_msid_for_cdma_next_avail
              --CR21051 Start Kacosta 05/31/2012
              ,
              n_part_inst2part_mod =
              CASE
                WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
                THEN 23070541
                ELSE n_part_inst2part_mod
              END
              --CR21051 End Kacosta 05/31/2012
            WHERE ROWID = min_rec.rowid;
            END IF;
          END IF;
          CLOSE min_still_exists_curs;                  --CR5008
        END IF;                                         --CR5008
        dbms_output.put_line('opening min_curs 2:11 '); -- CR 5008
        IF ig_trans_rec.order_type NOT IN ('D' ,'S') THEN
          --CR13463  --CR15983
          UPDATE table_site_part
          SET x_msid  = hold_msid_for_cdma_next_avail
          WHERE objid = call_trans_rec.call_trans2site_part;
          INSERT
          INTO table_x_pi_hist
            (
              objid ,
              status_hist2x_code_table ,
              x_change_date ,
              x_change_reason ,
              x_cool_end_date ,
              x_creation_date ,
              x_deactivation_flag ,
              x_domain ,
              x_ext ,
              x_insert_date ,
              x_npa ,
              x_nxx ,
              x_old_ext ,
              x_old_npa ,
              x_old_nxx ,
              x_part_bin ,
              x_part_inst_status ,
              x_part_mod ,
              x_part_serial_no ,
              x_part_status ,
              x_pi_hist2carrier_mkt ,
              x_pi_hist2inv_bin ,
              x_pi_hist2part_inst ,
              x_pi_hist2part_mod ,
              x_pi_hist2user ,
              x_pi_hist2x_new_pers ,
              x_pi_hist2x_pers ,
              x_po_num ,
              x_reactivation_flag ,
              x_red_code ,
              x_sequence ,
              x_warr_end_date ,
              dev ,
              fulfill_hist2demand_dtl ,
              part_to_esn_hist2part_inst ,
              x_bad_res_qty ,
              x_date_in_serv ,
              x_good_res_qty ,
              x_last_cycle_ct ,
              x_last_mod_time ,
              x_last_pi_date ,
              x_last_trans_time ,
              x_next_cycle_ct ,
              x_order_number ,
              x_part_bad_qty ,
              x_part_good_qty ,
              x_pi_tag_no ,
              x_pick_request ,
              x_repair_date ,
              x_transaction_id ,
              x_msid -- Nitin: Added for Number Pooling.
            )
            VALUES
            (
              -- 04/10/03 seq_x_pi_hist.NEXTVAL + POWER (2, 28),
              seq('x_pi_hist') ,
              (SELECT status2x_code_table FROM table_part_inst WHERE ROWID = min_rec.rowid
              ) ,
              SYSDATE ,
              'MSID UPDATE' ,
              min_rec.x_cool_end_date ,
              min_rec.x_creation_date ,
              min_rec.x_deactivation_flag ,
              min_rec.x_domain ,
              min_rec.x_ext ,
              min_rec.x_insert_date ,
              min_rec.x_npa ,
              min_rec.x_nxx ,
              SUBSTR(min_rec.part_serial_no ,7 ,4) ,
              SUBSTR(min_rec.part_serial_no ,1 ,3) ,
              SUBSTR(min_rec.part_serial_no ,4 ,3) ,
              min_rec.part_bin ,
              (SELECT x_part_inst_status FROM table_part_inst WHERE ROWID = min_rec.rowid
              ) ,
              min_rec.part_mod ,
              min_rec.part_serial_no ,
              min_rec.part_status ,
              min_rec.part_inst2carrier_mkt ,
              min_rec.part_inst2inv_bin ,
              min_rec.objid ,
              min_rec.n_part_inst2part_mod ,
              min_rec.created_by2user ,
              min_rec.part_inst2x_new_pers ,
              min_rec.part_inst2x_pers ,
              min_rec.x_po_num ,
              min_rec.x_reactivation_flag ,
              min_rec.x_red_code ,
              min_rec.x_sequence ,
              min_rec.warr_end_date ,
              min_rec.dev ,
              min_rec.fulfill2demand_dtl ,
              min_rec.part_to_esn2part_inst ,
              min_rec.bad_res_qty ,
              min_rec.date_in_serv ,
              min_rec.good_res_qty ,
              min_rec.last_cycle_ct ,
              min_rec.last_mod_time ,
              min_rec.last_pi_date ,
              min_rec.last_trans_time ,
              min_rec.next_cycle_ct ,
              min_rec.x_order_number ,
              min_rec.part_bad_qty ,
              min_rec.part_good_qty ,
              min_rec.pi_tag_no ,
              min_rec.pick_request ,
              min_rec.repair_date ,
              min_rec.transaction_id ,
              min_rec.x_msid
            );
        END IF;
      END IF;
      dbms_output.put_line('opening min_curs 2:12 ');
      dbms_output.put_line('task_rec.task_currq2queue:' || task_rec.task_currq2queue);
      OPEN queue_curs(task_rec.task_currq2queue);
      FETCH queue_curs INTO queue_rec;
      dbms_output.put_line('task_rec.task_state2condition:' || task_rec.task_state2condition);
      OPEN condition_curs(task_rec.task_state2condition);
      FETCH condition_curs INTO condition_rec;
      IF queue_curs%NOTFOUND AND condition_curs%FOUND THEN
        dbms_output.put_line('ig_trans_rec.status' || ig_trans_rec.status);
        IF ig_trans_rec.status <> 'W' THEN
          dbms_output.put_line(' if ig_trans_rec.status <>W then');
          failed_log(ig_trans_rec);
        END IF;
        UPDATE gw1.ig_transaction
        SET status  = DECODE(ig_trans_rec.status ,'E' ,'F' ,'W' ,'S')
        WHERE ROWID = ig_trans_rec.rowid;

        COMMIT;
        -- CR20403 RIM Integration CDMA
        -- ST CR20403
        IF ig_trans_rec.status IN ('S','W') THEN
          --    OPEN ESN_BB_curs(ig_trans_rec.esn);
          --   FETCH ESN_BB_curs
          --   INTO ESN_BB_rec;
          --  IF ESN_BB_curs%FOUND THEN
          IF sa.RIM_SERVICE_PKG.IF_BB_ESN(ig_trans_rec.esn)= 'TRUE' THEN --CR22487
            dbms_output.put_line('Insert ig_transaction_RIM for opening min_curs 2:12 ');
            sa.Rim_service_pkg.sp_create_rim_action_item(ig_trans_rec.action_item_id, op_msg, op_status); --action_item_id (gw1.ig_transaction)
            IF OP_STATUS = 'S' THEN
              dbms_output.put_line('Insert ig_transaction_RIM and status is S from sa.Rim_service_pkg.sp_create_rim_action_item');
            ELSE
              dbms_output.put_line('Fail process sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM');
            END IF;
          END IF;
          --  close ESN_BB_curs;
          --CR48373
          DELETE FROM gw1.ig_transaction_features
          WHERE  transaction_id = ig_trans_rec.transaction_id;
          COMMIT;
        END IF;
        -- CR20403 RIM Integration CDMA
        CLOSE queue_curs;
        CLOSE condition_curs;
        GOTO next_action_item;
      END IF;
      CLOSE queue_curs;
      CLOSE condition_curs;
      OPEN queue_curs(task_rec.task_currq2queue);
      FETCH queue_curs INTO queue_rec;
      IF queue_curs%NOTFOUND THEN
        IF ig_trans_rec.status IN ('W') THEN
          IF task_rec.x_queued_flag <> ' ' THEN
            UPDATE table_task SET x_queued_flag = '0' WHERE objid = task_rec.objid;
          END IF;
          igate.sp_close_action_item(task_rec.objid ,0 ,hold);
          UPDATE gw1.ig_transaction SET status = 'S' WHERE ROWID = ig_trans_rec.rowid;
          --CR48373
          DELETE FROM gw1.ig_transaction_features
          WHERE  transaction_id = ig_trans_rec.transaction_id;
          COMMIT;
          -- CR20403 RIM Integration CDMA
          -- ST CR20403
          --   OPEN ESN_BB_curs(ig_trans_rec.esn);
          --  FETCH ESN_BB_curs
          --  INTO ESN_BB_rec;
          --  IF ESN_BB_curs%FOUND THEN
          IF sa.RIM_SERVICE_PKG.IF_BB_ESN(ig_trans_rec.esn) = 'TRUE' THEN --CR22487
            dbms_output.put_line('insert ig_transaction_RIM after update status S in ig_transaction');
            sa.Rim_service_pkg.sp_create_rim_action_item(ig_trans_rec.action_item_id, op_msg, op_status); --action_item_id (gw1.ig_transaction)
            IF op_status = 'S' THEN
              dbms_output.put_line('Inserted ig_transaction_RIM');
            ELSE
              dbms_output.put_line('Fail process sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM');
            END IF;
          END IF;
          --  close ESN_BB_curs;
          -- CR20403 RIM Integration CDMA
          COMMIT;
          IF task_rec.x_current_method IN ('ICI' ,'AOL') AND RTRIM(call_trans_rec.x_service_id) IS NOT NULL AND ig_trans_rec.subscriber_update IS NOT NULL THEN
            FOR opened_case_rec        IN opened_case_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
            LOOP
              IF (opened_case_rec.title IN ('Line Inactive' ,'Line Inactive WEB' ,'Line Inactive IVR' ,'Inactive Features' ,'Voicemail not active' ,'Unable to Make / Unable to Receive Calls' ,'Caller ID not active' ,'Callwait not active' ,'Voicemail' ,'Caller ID' ,'Call Waiting' ,'SMS') AND opened_case_rec.x_case_type IN ('Carrier LA' ,'Carrier LA Features' ,'Features' ,'Line Activation')) THEN
                igate.sp_close_case(opened_case_rec.id_number ,USER ,'IGATE_IN' ,'Resolution Given' ,l_status ,l_msg);
              ELSE
                v_case_history := opened_case_rec.case_history;
                v_case_history := v_case_history || CHR(10) || '*** CASE STILL OPEN ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS AM ') || USER || ' FROM source "' || 'IGATE_IN' || '"' || v_fail_notes;
                UPDATE table_case
                SET case_history = v_case_history
                WHERE id_number  = opened_case_rec.id_number;
              END IF;
            END LOOP;
          END IF;
        ELSIF ig_trans_rec.status IN ('E') THEN
          OPEN part_num_curs(site_part_rec.site_part2part_info);
          FETCH part_num_curs INTO part_num_rec;
          IF part_num_curs%NOTFOUND THEN
            str_reworkq := 'Action Re-Work';
          ELSE
            IF ig_trans_rec.order_type = 'IPA' OR ig_trans_rec.order_type = 'IPS' OR ig_trans_rec.order_type = 'IPI' OR ig_trans_rec.order_type = 'PIR' THEN
              -- CR17415   PPIR - Partial Beenfits for PIR  -- CR17793 to remove PPIR
              str_reworkq := trans_profile_rec.x_int_port_in_rework;
              -- *********************************************************************
              -- -- CR20451 | CR20854: Add TELCEL Brand AREA5 START
              -- ********************************************************************
              -- CR20451 | CR20854: Add TELCEL Brand   mod 4
              -- FOR CHECK_ST_ESN_REC IN CHECK_ST_ESN_CURS (IG_TRANS_REC.ESN,'BUS_ORG','STRAIGHT_TALK') LOOP
              FOR org_flow_rec IN org_flow_curs(ig_trans_rec.esn ,'3')
              LOOP
                IF ig_trans_rec.order_type IN ('PIR') THEN
                  -- CR17415   PPIR - Partial Beenfits for PIR -- CR17793 to remove PPIR
                  str_reworkq := 'ST Internal Port Reworks';
                END IF;
              END LOOP;
              -- *********************************************************************
              -- -- CR20451 | CR20854: Add TELCEL Brand AREA5 END
              -- ********************************************************************
            ELSE
              OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
              FETCH trans_profile_curs INTO trans_profile_rec;
              IF trans_profile_curs%NOTFOUND THEN
                str_reworkq := 'Action Re-Work';
              ELSE
                IF part_num_rec.x_technology = 'ANALOG' THEN
                  str_reworkq               := trans_profile_rec.x_analog_rework;
                ELSIF part_num_rec.x_technology IN ('CDMA' ,'TDMA') THEN
                  str_reworkq := trans_profile_rec.x_digital_rework;
                ELSIF part_num_rec.x_technology IN ('GSM') THEN
                  str_reworkq := trans_profile_rec.x_gsm_rework;
                ELSE
                  str_reworkq := 'Action Re-Work';
                END IF;
              END IF;
              CLOSE trans_profile_curs; -- CR 5008
            END IF;
          END IF;
          CLOSE part_num_curs;
          IF ig_trans_rec.order_type IN ('A' ,'E') THEN
            rtain_strqueue := str_reworkq;
          ELSIF ig_trans_rec.order_type IN ('D' ,'S') THEN
            rtain_strqueue := 'Line Management Re-work';
          ELSE
            rtain_strqueue := str_reworkq;
          END IF;
          dbms_output.put_line('start upd transaction pre');
          igate.sp_dispatch_task(task_rec.objid ,rtain_strqueue ,hold);
          dbms_output.put_line('start upd transaction');
          failed_log(ig_trans_rec);
          UPDATE gw1.ig_transaction SET status = 'F' WHERE ROWID = ig_trans_rec.rowid;
          COMMIT;
          dbms_output.put_line('end upd transaction');
        END IF;
        CLOSE queue_curs;
        GOTO next_action_item;
      END IF;
      CLOSE queue_curs;
      --
      dbms_output.put_line('Taks Id...' || task_rec.task_id);
      dbms_output.put_line('opening condition cur');
      OPEN condition_curs(task_rec.task_state2condition);
      FETCH condition_curs INTO condition_rec;
      IF condition_curs%FOUND THEN
        CLOSE condition_curs;
        dbms_output.put_line('before inserting error --cond');
        BEGIN
          dbms_output.put_line('Before Updating...');
          IF (ig_trans_rec.status != 'CP') THEN
            UPDATE table_task
            SET task_currq2queue       = NULL
            WHERE task_state2condition = condition_rec.objid;
          END IF;
          dbms_output.put_line('After Updating...');
          COMMIT;
        EXCEPTION
        WHEN no_data_found THEN
          NULL;
        WHEN OTHERS THEN
          toss_util_pkg.insert_error_tab_proc('Error in Updating Table_Task Table' ,ig_trans_rec.action_item_id ,l_program_name ,'For Object Id  ' || NVL(TO_CHAR(task_rec.task_state2condition) ,'N/A'));
        END;
        GOTO next_action_item;
      END IF;
      CLOSE condition_curs;
      dbms_output.put_line('closing condition cur');
      dbms_output.put_line('opening part_num_curs cur');
      OPEN part_num_curs(site_part_rec.site_part2part_info);
      FETCH part_num_curs INTO part_num_rec;
      IF part_num_curs%NOTFOUND THEN
        str_reworkq := 'Action Re-Work';
      ELSE
        dbms_output.put_line('opening trans_profile_curs cur');
        OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
        FETCH trans_profile_curs INTO trans_profile_rec;
        IF trans_profile_curs%NOTFOUND THEN
          str_reworkq := 'Action Re-Work';
        ELSE
          IF ig_trans_rec.order_type   = 'IPI' OR ig_trans_rec.order_type = 'PIR' -- CR17415   PPIR - Partial Beenfits for PIR  --CR17793 to remove PPIR
            OR ig_trans_rec.order_type = 'IPA' OR ig_trans_rec.order_type = 'IPS' THEN
            str_reworkq               := trans_profile_rec.x_int_port_in_rework;
            -- *********************************************************************
            -- -- CR20451 | CR20854: Add TELCEL Brand AREA6 START
            -- ********************************************************************
            -- CR20451 | CR20854: Add TELCEL Brand   mod 5
            -- FOR CHECK_ST_ESN_REC IN CHECK_ST_ESN_CURS (IG_TRANS_REC.ESN,'BUS_ORG','STRAIGHT_TALK') LOOP
            FOR org_flow_rec IN org_flow_curs(ig_trans_rec.esn ,'3')
            LOOP
              IF ig_trans_rec.order_type IN ('PIR') THEN
                -- CR17415   PPIR - Partial Beenfits for PIR -- CR17793 to remove PPIR
                str_reworkq := 'ST Internal Port Reworks';
              END IF;
            END LOOP;
            -- *********************************************************************
            -- -- CR20451 | CR20854: Add TELCEL Brand AREA6 END
            -- ********************************************************************
          ELSE
            IF part_num_rec.x_technology = 'ANALOG' THEN
              str_reworkq               := trans_profile_rec.x_analog_rework;
            ELSIF part_num_rec.x_technology IN ('CDMA' ,'TDMA') THEN
              str_reworkq := trans_profile_rec.x_digital_rework;
            ELSIF part_num_rec.x_technology IN ('GSM') THEN
              str_reworkq := trans_profile_rec.x_gsm_rework;
            ELSE
              str_reworkq := 'Action Re-Work';
            END IF;
          END IF;
        END IF;
        CLOSE trans_profile_curs;
        dbms_output.put_line('closing trans_profile_curs cur');
      END IF;
      CLOSE part_num_curs;
      dbms_output.put_line('closing part_num_curs cur');
      -----------------------------------------------------------
      dbms_output.put_line('entering rtain_NotesStr,  TRANSMISSION_METHOD ');
      dbms_output.put_line('Length of Notes: ' || TO_CHAR(LENGTH(task_rec.notes)));
      dbms_output.put_line('Length of status_message: ' || TO_CHAR(LENGTH(ig_trans_rec.status_message)));
      rtain_notesstr := task_rec.notes || CHR(10) || CHR(13) || ' ' || TO_CHAR(SYSDATE ,'DD-MON-YYYY') || '  ---  ' || ig_trans_rec.status_message;
      dbms_output.put_line('exiting rtain_NotesStr,  TRANSMISSION_METHOD ');
      --
      IF (ig_trans_rec.transmission_method = 'AOL') THEN
        fax_filename                      := 'not found';
      ELSIF ig_wi_detail_rec.batch_id     IS NOT NULL THEN
        fax_filename                      := 'f' || ig_wi_detail_rec.batch_id || '.fmf';
      ELSE
        fax_filename := 'not found';
      END IF;
      dbms_output.put_line('exit rtain_NotesStr,  TRANSMISSION_METHOD ');
      dbms_output.put_line('entering update table task ');
      UPDATE table_task
      SET notes     = rtain_notesstr ,
        x_fax_file  = fax_filename
      WHERE task_id = ig_trans_rec.action_item_id;
      dbms_output.put_line('exiting update table task ');
      SELECT seq('notes_log') INTO l_notes_log_seq FROM dual;
      dbms_output.put_line('enter - insert table notes log  ');
      INSERT
      INTO table_notes_log
        (
          objid ,
          creation_time ,
          description ,
          action_type ,
          task_notes2task
        )
        VALUES
        (
          l_notes_log_seq ,
          SYSDATE ,
          ' AOL Retur n Message: '
          || ig_trans_rec.status_message ,
          'AOL' ,
          task_rec.objid
        );
      dbms_output.put_line('exit - insert table notes log  ');
      -- --************************************************************************/
      -- --*** If successful then:
      -- --***   Close the item
      -- --***      Update the condition to closed
      -- --***      Update the status to "succeeded".
      -- --***   Append the f200message to the action item notes
      -- --***   If this is an automated online request (AOL) Then
      -- --***      If the task wasn't previously queued then
      -- --***         check to see if the user is logged on
      --***         if so then add an act_entry to perform a screen pop.
      --***      If the item was previously queued, reset queue flag
      --************************************************************************/
      dbms_output.put_line('ig_trans_rec.status:' || ig_trans_rec.status);
      IF ig_trans_rec.status IN ('W') THEN
        --*** If this is an online request, then notify user if logged into Clarify
        --    reset the queue flag for the task if needed
        IF task_rec.x_queued_flag <> ' ' THEN
          dbms_output.put_line('task_rec.x_queued_flag 1:' || task_rec.x_queued_flag);
          UPDATE table_task SET x_queued_flag = '0' WHERE objid = task_rec.objid;
        END IF;
        dbms_output.put_line('task_rec.x_queued_flag 2:' || task_rec.x_queued_flag);
        -- Start Changes for CR3918 by Mchinta on 06/15/2005 Ver 1.20
        IF (ig_trans_rec.status_message = 'Operation MINC failed' AND ig_trans_rec.order_type = 'MINC') THEN
          dbms_output.put_line('ig_trans_rec.status_message:' || ig_trans_rec.status_message);
          lcaseobjid := igate.f_create_case(call_trans_rec.objid ,task_rec.objid ,'Bad Address' ,'Technology Exchange' ,'SIM Card Exchange');
          --to remove the shipping address and set the status to bad address
          dbms_output.put_line('update bad address');
          UPDATE table_case
          SET alt_first_name    = '' ,
            alt_last_name       = '' ,
            alt_address         = '' ,
            alt_city            = '' ,
            alt_state           = '' ,
            alt_zipcode         = '' ,
            x_replacement_units = 0 ,
            casests2gbst_elm    =
            (SELECT MAX(objid) FROM table_gbst_elm WHERE s_title = 'BADADDRESS'
            )
          WHERE objid = lcaseobjid;
          dbms_output.put_line('open case');
          OPEN case_curs(lcaseobjid);
          FETCH case_curs INTO case_rec;
          CLOSE case_curs;
          v_case_history := case_rec.case_history;
          v_case_history := v_case_history || CHR(10) || CHR(13) || '*** Notes ' || SYSDATE || ' ' || 'IMPORTANT:  In order to process the customer''s phone number change request, we will have to send the customer a new SIM card.  Document the customer''s shipping information, then change the case
status to Address Up dated.';
          --'
          dbms_output.put_line('update case');
          UPDATE table_case SET case_history = v_case_history WHERE objid = lcaseobjid;
          COMMIT;
        END IF;
        -- End Changes for CR3918 by Mchinta on 06/15/2005 Ver1.20
        dbms_output.put_line('close action item1');
        igate.sp_close_action_item(task_rec.objid ,0 ,hold);
        -- start CR23513 TracFone SurePay for Android by Mvadlapally on 09/04/2013
        IF sa.device_util_pkg.get_smartphone_fun(ig_trans_rec.esn) = 0 THEN
          sa.walmart_monthly_plans_pkg.sp_set_zero_out_max(task_rec.x_task2x_call_trans, ig_trans_rec.esn ,ig_trans_rec.order_type, ig_trans_rec.transaction_id, ig_trans_rec.rate_plan, out_errorcode, out_errormsg);
        END IF;
        UPDATE gw1.ig_transaction SET status = 'S' WHERE ROWID = ig_trans_rec.rowid;
        --CR48373
        DELETE FROM gw1.ig_transaction_features
        WHERE  transaction_id = ig_trans_rec.transaction_id;
        COMMIT;
        -- CR20403 RIM Integration CDMA
        -- ST CR20403
        -- OPEN ESN_BB_curs(ig_trans_rec.esn);
        -- FETCH ESN_BB_curs
        -- INTO ESN_BB_rec;
        -- IF ESN_BB_curs%FOUND THEN
        IF sa.RIM_SERVICE_PKG.IF_BB_ESN(ig_trans_rec.esn) = 'TRUE' THEN --CR22487
          dbms_output.put_line('Insert ig_transaction_RIM after update case');
          sa.Rim_service_pkg.sp_create_rim_action_item(ig_trans_rec.action_item_id, op_msg, op_status); --action_item_id (gw1.ig_transaction)
          IF op_status = 'S' THEN
            dbms_output.put_line('Inserted ig_transaction_RIM');
          ELSE
            dbms_output.put_line('Fail process sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM');
          END IF;
        END IF;
        --  close ESN_BB_curs;
        -- CR20403 RIM Integration CDMA
        dbms_output.put_line('close action item1');
        IF ig_trans_rec.order_type IN ('IPI' ,'PIR') THEN
          -- ST_BUNDLE_III Starts  -- CR17415   PPIR - Partial Beenfits for PIR     -- CR17793 to remove PPIR
          IF ig_trans_rec.order_type IN ('PIR') THEN
            -- CR17793 to remove PPIR
            -- *********************************************************************
            -- -- CR20451 | CR20854: Add TELCEL Brand AREA7 START
            -- ********************************************************************
            -- CR20451 | CR20854: Add TELCEL Brand   mod 6
            -- FOR check_st_esn_rec IN check_st_esn_curs (ig_trans_rec.esn,'BUS_ORG','STRAIGHT_TALK') LOOP
            FOR org_flow_rec IN org_flow_curs(ig_trans_rec.esn ,'3')
            LOOP
              FOR st_portin_case_rec IN st_portin_case_curs(call_trans_rec.x_service_id)
              LOOP
                sa.clarify_case_pkg.dispatch_case(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_queue_name => 'ST Int Port Approval' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
                sa.clarify_case_pkg.update_status(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_new_status => 'Pending Approval' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
                v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> Port Request Accepted' || CHR(10) || CHR(13) || 'Internal Port Approval Required  ';
                clarify_case_pkg.log_notes(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              END LOOP;
            END LOOP; -- ST_BUNDLE_III Ends
            -- *********************************************************************
            -- -- CR20451 | CR20854: Add TELCEL Brand AREA7 END
            -- ********************************************************************
            FOR port_flow_rec IN port_flow_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
            LOOP
              sa.clarify_case_pkg.dispatch_case(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_queue_name => 'TF/NT Auto Port Pending' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              sa.clarify_case_pkg.update_status(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_new_status => 'Pending Approval' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> Auto Port Pending Accepted' || CHR(10) || CHR(13) || 'Auto Port Pending Approval ';
              clarify_case_pkg.log_notes(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            END LOOP;
          END IF;
          FOR port_in_case_rec IN port_in_case_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
          LOOP
            sa.clarify_case_pkg.reopen_case(p_case_objid => port_in_case_rec.objid ,p_user_objid => port_in_case_rec.case_originator2user ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            sa.clarify_case_pkg.dispatch_case(p_case_objid => port_in_case_rec.objid ,p_user_objid => port_in_case_rec.case_originator2user ,p_queue_name => 'Internal Port Approval' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            UPDATE table_case
            SET case_type_lvl3 = 'To Be Authorized' ,
              x_case2task      =
              (SELECT objid FROM table_task WHERE task_id = ig_trans_rec.action_item_id
              )
            WHERE objid = port_in_case_rec.objid;
            COMMIT;
            v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> Port Request Accepted' || CHR(10) || CHR(13) || 'Internal Port Approval Required  ';
            clarify_case_pkg.log_notes(p_case_objid => port_in_case_rec.objid ,p_user_objid => port_in_case_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
          END LOOP;
        ELSIF ig_trans_rec.order_type = 'IPA' THEN
          FOR opened_case_rec IN opened_case_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
          LOOP
            IF (opened_case_rec.title = 'Internal' AND opened_case_rec.x_case_type = 'Port In') THEN
              SELECT objid
              INTO intportinq
              FROM table_queue
              WHERE title = 'Internal Port Status';
              UPDATE table_case
              SET case_currq2queue = intportinq ,
                case_type_lvl3     = 'Approved OSP'
              WHERE id_number      = opened_case_rec.id_number;
              COMMIT;
              v_case_history := opened_case_rec.case_history;
              v_case_id      := opened_case_rec.id_number;
            END IF;
          END LOOP;
          v_order_type := 'Internal Port Status';
          SELECT x_part_inst2contact
          INTO v_contact_objid
          FROM table_part_inst
          WHERE part_serial_no = call_trans_rec.x_service_id;
          igate.sp_create_action_item(v_contact_objid ,call_trans_rec.objid ,v_order_type ,1 ,0 ,v_status_out ,v_action_item_id_ipa);
          --Get order type objid
          igate.sp_get_ordertype(call_trans_rec.x_min ,v_order_type ,call_trans_rec.x_call_trans2carrier ,ig_trans_rec.x_technology ,v_ordertype_objid); -- CR4579: Added Technology
          igate.sp_check_blackout(v_action_item_id_ipa ,v_ordertype_objid ,v_black_out_code);
          IF (v_black_out_code = 0) THEN
            igate.sp_determine_trans_method(v_action_item_id_ipa ,v_order_type ,NULL ,v_dest_queue);
          ELSIF (v_black_out_code = 1) THEN
            igate.sp_dispatch_task(v_action_item_id_ipa ,'BlackOut' ,v_dummy);
          ELSE
            igate.sp_dispatch_task(v_action_item_id_ipa ,'Line Management Re-work' ,v_dummy);
          END IF;
          SELECT objid ,
            task_id
          INTO v_task_objid ,
            v_task_id
          FROM table_task
          WHERE objid     = v_action_item_id_ipa;
          v_case_history := v_case_history || CHR(10) || CHR(13) || '*** Notes ' || SYSDATE || ' ' || 'igate_in3';
          v_case_history := v_case_history || CHR(10) || CHR(13) || 'Internal Port Approval Action item ' || task_rec.task_id || ' closed successfully.';
          v_case_history := v_case_history || CHR(10) || CHR(13) || ' Sent for Port Status Action item ' || v_task_id;
          UPDATE table_case
          SET case_history = v_case_history ,
            x_case2task    = v_task_objid
          WHERE id_number  = v_case_id;
          COMMIT;
        ELSIF ig_trans_rec.order_type = 'IPS' AND ig_trans_rec.subscriber_update IS NOT NULL THEN
          FOR opened_case_rec IN opened_case_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
          LOOP
            IF (opened_case_rec.title = 'Internal' AND opened_case_rec.x_case_type = 'Port In') THEN
              v_case_history         := opened_case_rec.case_history;
              v_case_history         := v_case_history || CHR(10) || CHR(13) || '*** Notes ' || SYSDATE || ' ' || 'igate_in3';
              v_case_history         := v_case_history || CHR(10) || CHR(13) || 'Internal Port Status Action item ' || task_rec.task_id || ' closed successfully.';
              UPDATE table_case
              SET case_currq2queue = intportinq ,
                case_type_lvl3     = 'Port Successful' ,
                case_history       = v_case_history
              WHERE id_number      = opened_case_rec.id_number;
              COMMIT;
              v_case_history := opened_case_rec.case_history;
              v_case_id      := opened_case_rec.id_number;
              igate.sp_close_case(opened_case_rec.id_number ,USER ,'IGATE_IN' ,'Resolution Given' ,l_status ,l_msg);
            ELSE
              v_case_history := opened_case_rec.case_history;
              v_case_history := v_case_history || CHR(10) || '*** CASE STILL OPEN ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS AM ') || USER || ' FROM source "' || 'IGATE_IN' || '"' || v_fail_notes;
              UPDATE table_case
              SET case_history = v_case_history
              WHERE id_number  = opened_case_rec.id_number;
            END IF;
          END LOOP;
        END IF;
        COMMIT;
        IF task_rec.x_current_method IN ('ICI' ,'AOL') AND RTRIM(call_trans_rec.x_service_id) IS NOT NULL AND ig_trans_rec.subscriber_update IS NOT NULL THEN
          FOR opened_case_rec        IN opened_case_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
          LOOP
            IF (opened_case_rec.title IN ('Line Inactive' ,'Line Inactive WEB' ,'Line Inactive IVR' ,'Inactive Features' ,'Voicemail not active' ,'Unable to Make / Unable to Receive Calls' ,'Caller ID not active' ,'Callwait not active' ,'Voicemail' ,'Caller ID' ,'Call Waiting' ,'SMS') AND opened_case_rec.x_case_type IN ('Carrier LA' ,'Carrier LA Features' ,'Features' ,'Line Activation')) THEN
              igate.sp_close_case(opened_case_rec.id_number ,USER ,'IGATE_IN' ,'Resolution Given' ,l_status ,l_msg);
            ELSE
              v_case_history := opened_case_rec.case_history;
              v_case_history := v_case_history || CHR(10) || '*** CASE STILL OPEN ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS AM ') || USER || ' FROM source "' || 'IGATE_IN' || '"' || v_fail_notes;
              UPDATE table_case
              SET case_history = v_case_history
              WHERE id_number  = opened_case_rec.id_number;
            END IF;
          END LOOP;
        END IF;

       FOR opened_case_rec IN opened_case_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
          LOOP
        --Closing the E911 opened case if any.
        IF ig_trans_rec.order_type ='E911'
             THEN
              IF ig_trans_rec.status ='E' THEN
                      sa.clarify_case_pkg.update_status(p_case_objid => opened_case_rec.objid ,p_user_objid => opened_case_rec.case_originator2user,p_new_status => 'Rework' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              ELSE
           null;
           END IF;
        END IF;
    END LOOP;

        IF ig_trans_rec.order_type = 'EPIR' THEN
          -- *********************************************************************
          -- -- CR20451 | CR20854: Add TELCEL Brand AREA8 START
          -- ********************************************************************
          -- CR20451 | CR20854: Add TELCEL Brand   mod 7
          -- FOR check_st_esn_rec IN check_st_esn_curs (ig_trans_rec.esn,'BUS_ORG','STRAIGHT_TALK') LOOP
          FOR org_flow_rec IN org_flow_curs(ig_trans_rec.esn ,'3')
          LOOP
            FOR st_portin_case_rec IN st_portin_case_curs(call_trans_rec.x_service_id)
            LOOP
              sa.clarify_case_pkg.dispatch_case(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_queue_name => 'ST Ext Pending Approval' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              sa.clarify_case_pkg.update_status(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_new_status => 'Pending Approval' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> ' || CHR(10) || CHR(13) || 'ST Ext Pending Approval';
              sa.clarify_case_pkg.log_notes(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            END LOOP;
          END LOOP;
          -- *********************************************************************
          -- -- CR20451 | CR20854: Add TELCEL Brand AREA8 END
          -- ********************************************************************
          FOR port_flow_rec IN port_flow_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
          LOOP
            sa.clarify_case_pkg.dispatch_case(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_queue_name => 'TF/NT Auto Port Pending' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            sa.clarify_case_pkg.update_status(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_new_status => 'Pending Approval' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> Auto Port Pending Accepted' || CHR(10) || CHR(13) || 'Auto Port Pending Approval ';
            clarify_case_pkg.log_notes(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
          END LOOP;
        END IF;
        --************************************************************************/
        --*** If failure then:
        --***
        --***   Look for one of four types of error:
        --***      1.  RETAIL ESN error
        --***      2.  Failure to contact Intergate
        --***      3.  Non-Topp Number (NTN) error
        --***      4.  Non NTN error
        --***   Map the Intergate error code to a Topp error code.
        --***   If it is an NTN error:
        --***      close the task
        --***      Set the status to failed
        --***      Create a new case
        --***      dispatch new case to the re-work queue.
        --***   Otherwise
        --***      leave current task open
        --***      change the status to failed
        --***      dispatch to the Action Re-Work queue
        --***      if the user is logged in then do a screen pop.
        --************************************************************************/
      ELSIF ig_trans_rec.status = 'E' THEN
        --//***********************************************************************
        --// if action item is created by case and action item is failed,
        --//   close action item
        --//***********************************************************************
        IF SUBSTR(task_rec.s_title ,LENGTH(task_rec.s_title) - 4) = ':CASE' THEN
          igate.sp_close_action_item(task_rec.objid ,0 ,hold);
          failed_log(ig_trans_rec);
          UPDATE gw1.ig_transaction SET status = 'F' WHERE ROWID = ig_trans_rec.rowid;
          COMMIT;
          GOTO next_action_item;
        END IF;
        -----------------------------------------------------------
        -- Process status messages received from TMOBILE carrier --
        -- CR4947 START                                          --
        -----------------------------------------------------------
        l_b_tmobile_msg_processed := FALSE;
        IF ig_trans_rec.template IN ('TMOBILE' ,'TMOUN' ,'TMOSM' ) -- CR25987 SIMPLE MOBILE SUSPEND2CANCEL
          THEN
          IF ig_trans_rec.order_type    = 'A' THEN
            l_b_tmobile_msg_processed  := f_tmobile_activation_msg(p_ig_trans_rec => ig_trans_rec);
          ELSIF ig_trans_rec.order_type = 'E' THEN
            l_b_tmobile_msg_processed  := f_tmobile_esn_chng_msg(p_ig_trans_rec => ig_trans_rec);
          ELSIF ig_trans_rec.order_type = 'MINC' THEN
            l_b_tmobile_msg_processed  := f_tmobile_minc_msg(p_ig_trans_rec => ig_trans_rec);
          ELSIF ig_trans_rec.order_type = 'D' THEN
            l_b_tmobile_msg_processed  := f_tmobile_deact_msg(p_ig_trans_rec => ig_trans_rec);
          ELSIF ig_trans_rec.order_type = 'S' THEN
            l_b_tmobile_msg_processed  := f_tmobile_suspend_msg(p_ig_trans_rec => ig_trans_rec);
          END IF;
        END IF;
        IF l_b_tmobile_msg_processed THEN
          GOTO next_action_item;
        END IF;
        IF RTRIM(ig_trans_rec.status_message) = 'Failure to contact Intergate' THEN
          igate.sp_dispatch_task(task_rec.objid ,'Intergate' ,hold);
          --//************************************************************************/
          --//*** Look for a Retail ESN failure, if found:
          --//*** 1.  close the task
          --//*** 2.  set the status to failed esn failure
          --//*** 3.  perform a createactionstatus
          --//************************************************************************/
        ELSIF ig_trans_rec.status_message = 'RETAIL ESN' THEN
          OPEN retail_esn_curs;
          FETCH retail_esn_curs INTO retail_esn_rec;
          CLOSE retail_esn_curs;
          UPDATE table_task
          SET task_sts2gbst_elm = retail_esn_rec.objid
          WHERE objid           = task_rec.objid;
          igate.sp_close_action_item(task_rec.objid ,2 ,hold);
        ELSIF (ig_trans_rec.status_message = 'There are no MSISDNs available for zip' OR ig_trans_rec.status_message = 'W000017' OR ig_trans_rec.status_message = 'No Subscribers are available') THEN
          SELECT COUNT(*)
          INTO cntcase
          FROM table_case ,
            table_condition
          WHERE table_condition.objid = table_case.case_state2condition
          AND table_condition.s_title LIKE 'OPEN%'
          AND table_case.title       = 'No Line Available'
          AND table_case.x_case_type = 'Line Management'
          AND table_case.x_esn       = call_trans_rec.x_service_id;
          IF (cntcase                = 0) THEN
            OPEN closed_case_cur(call_trans_rec.x_service_id);
            FETCH closed_case_cur INTO closed_case_rec;
            IF closed_case_cur%NOTFOUND THEN
              lcaseobjid := igate.f_create_case(call_trans_rec.objid ,task_rec.objid ,'Line Management' ,'Line Management' ,'No Line Available');
            ELSE
              lcaseobjid            := closed_case_rec.case_objid;
              c_reopen_case_err_msg := NULL;
              igate.reopen_case_proc(p_case_objid => lcaseobjid ,p_queue_name => 'LINE MANAGEMENT' ,p_notes => 'AGENT:  This case has been re-opened and sent to the appropriate department.  Please advise the customer that lines should be available in 24 - 48 hours.' ,
              --'
              p_user_login_name => USER ,p_error_message => c_reopen_case_err_msg);
              IF c_reopen_case_err_msg IS NOT NULL THEN
                toss_util_pkg.insert_error_tab_proc('Reopen case: calling stored proc igate.reopen_case_proc' ,lcaseobjid ,l_program_name ,'ESN = ' || call_trans_rec.x_service_id || ' ' || c_reopen_case_err_msg);
                CLOSE closed_case_cur;
                GOTO next_action_item;
              END IF;
            END IF;
            CLOSE closed_case_cur;
          END IF;
          igate.sp_dispatch_task(task_rec.objid ,'GSM Action Re-Work' ,hold); --CR3918 mchinta on 05/27/2005
          --//***********************************************************************
          --//*** Check for an NTN or NON-NTN error
          --//***********************************************************************
        ELSE
          OPEN topp_err_curs(carrier_rec.objid ,ig_trans_rec.status_message);
          FETCH topp_err_curs INTO topp_err_rec;
          IF topp_err_curs%NOTFOUND THEN
            OPEN gen_err_curs;
            FETCH gen_err_curs INTO topp_err_rec;
            IF gen_err_curs%NOTFOUND THEN
              ROLLBACK;
              CLOSE topp_err_curs; --Fix OPEN_CURSORS
              CLOSE gen_err_curs;
              toss_util_pkg.insert_error_tab_proc('Retrieve "System Malfunction"
error record
from table_x_topp_err_codes' ,ig_trans_rec.action_item_id ,l_program_name , 'No "System Malfunction"
record found.');
              --'
              GOTO next_action_item;
            END IF;
            CLOSE gen_err_curs;
          END IF;
          CLOSE topp_err_curs;
          --we have found either the default or a specific error
          --//*** Is it a NTN (non Topp Number) error? If so then close the task,
          --//*** set the status to 'failed', create a new case, and dispatch to*/
          --//*** the re-work queue*/
          --If InStr (ErrorRec.GetField("x_code_name"), "NON-TOPP MIN", 1) <> 0 Then
          IF topp_err_rec.x_code_name = 'Non Tracfone #' THEN
            OPEN failed_ntn_curs;
            FETCH failed_ntn_curs INTO failed_ntn_rec;
            IF failed_ntn_curs%NOTFOUND THEN
              failed_ntn_rec.x_text := 'Line Activation';
            END IF;
            CLOSE failed_ntn_curs;
            dbms_output.put_line('current method: ' || task_rec.x_current_method);
            IF task_rec.x_current_method IN ('ICI' ,'AOL') AND RTRIM(call_trans_rec.x_service_id) IS NOT NULL AND ig_trans_rec.subscriber_update IS NOT NULL THEN
              FOR opened_case_rec        IN opened_case_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
              LOOP
                igate.sp_close_case(opened_case_rec.id_number ,USER ,'IGATE_IN' ,'Resolution Given' ,l_status ,l_msg);
              END LOOP;
            END IF;
            lcaseobjid := igate.f_create_case(call_trans_rec.objid ,task_rec.objid ,failed_ntn_rec.x_text ,'Line Activation' ,'Non Tracfone #');
            igate.sp_close_action_item(task_rec.objid ,3 ,hold);
            IF (ig_trans_rec.min = site_part_rec.x_min AND site_part_rec.part_status = 'Active') THEN
              sp_deactivate_ntn.deactivate_ntn(call_trans_rec.x_service_id ,hold2);
            END IF;
          ELSE
            OPEN failed_open_curs;
            FETCH failed_open_curs INTO failed_open_rec;
            IF failed_open_curs%NOTFOUND THEN
              ROLLBACK;
              CLOSE failed_open_curs;
              toss_util_pkg.insert_error_tab_proc('Retrieve "Failed - Open"
record
from
table gbst_elm
and gbst_lst' ,ig_trans_rec.action_item_id ,l_program_name , 'No "Failed - Open"
record found.');
              GOTO next_action_item;
            END IF;
            CLOSE failed_open_curs;
            UPDATE table_task
            SET task_sts2gbst_elm = failed_open_rec.objid
            WHERE objid           = task_rec.objid;
            IF ig_trans_rec.order_type IN ('A' ,'E') THEN
              rtain_strqueue := str_reworkq;
            ELSIF ig_trans_rec.order_type IN ('D' ,'S') THEN
              rtain_strqueue := 'Line Management Re-work';
            ELSE
              rtain_strqueue := str_reworkq;
            END IF;
            igate.sp_dispatch_task(task_rec.objid ,rtain_strqueue ,hold);
          END IF;
          --Now, relate the Topp error to the task
          UPDATE table_task
          SET x_task2x_topp_err_codes = topp_err_rec.objid
          WHERE objid                 = task_rec.objid;
          COMMIT;
          failed_log(ig_trans_rec);
          UPDATE gw1.ig_transaction SET status = 'F' WHERE ROWID = ig_trans_rec.rowid;
          COMMIT;
        END IF;

        IF ig_trans_rec.order_type IN ('PIR') THEN
          -- ST_BUNDLE_III  -- CR17415   PPIR - Partial Beenfits for PIR  -- CR17793 to remove PPIR
          -- -- CR20451 | CR20854: Add TELCEL Brand AREA9 START
          -- ********************************************************************
          -- CR20451 | CR20854: Add TELCEL Brand   mod 8
          -- FOR check_st_esn_rec IN check_st_esn_curs (ig_trans_rec.esn,'BUS_ORG','STRAIGHT_TALK') LOOP
          FOR org_flow_rec IN org_flow_curs(ig_trans_rec.esn ,'3')
          LOOP
            FOR st_portin_case_rec IN st_portin_case_curs(call_trans_rec.x_service_id)
            LOOP
              sa.clarify_case_pkg.dispatch_case(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_queue_name => 'ST Internal Port Reworks' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              sa.clarify_case_pkg.update_status(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_new_status => 'Rework' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> ' || CHR(10) || CHR(13) || 'ST Internal Port Reworks  ';
              clarify_case_pkg.log_notes(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            END LOOP;
          END LOOP;
          -- *********************************************************************
          -- -- CR20451 | CR20854: Add TELCEL Brand AREA9 END
          -- ********************************************************************
          FOR port_flow_rec IN port_flow_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
          LOOP
            sa.clarify_case_pkg.dispatch_case(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_queue_name => 'TF/NT Auto Port Rework' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            sa.clarify_case_pkg.update_status(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_new_status => 'Port Auto Failed' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> ' || CHR(10) || CHR(13) || ' PIR did not return successful. Port Auto Failed ';
            sa.clarify_case_pkg.log_notes(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
          END LOOP;
		ELSIF ig_trans_rec.order_type = 'EPIR' THEN
          -- ST_BUNDLE_II
          -- -- CR20451 | CR20854: Add TELCEL Brand AREA10 START
          -- ********************************************************************
          -- CR20451 | CR20854: Add TELCEL Brand   mod 9
          -- FOR check_st_esn_rec IN check_st_esn_curs (ig_trans_rec.esn,'BUS_ORG','STRAIGHT_TALK') LOOP  ---CR13085
          FOR org_flow_rec IN org_flow_curs(ig_trans_rec.esn ,'3')
          LOOP
            ---CR13085
            FOR st_portin_case_rec IN st_portin_case_curs(call_trans_rec.x_service_id)
            LOOP
              sa.clarify_case_pkg.dispatch_case(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_queue_name => 'ST External Port Reworks' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              sa.clarify_case_pkg.update_status(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_new_status => 'Rework' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
              v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> ' || CHR(10) || CHR(13) || 'ST External Port Reworks';
              sa.clarify_case_pkg.log_notes(p_case_objid => st_portin_case_rec.objid ,p_user_objid => st_portin_case_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            END LOOP;
          END LOOP;
          -- *********************************************************************
          -- -- CR20451 | CR20854: Add TELCEL Brand AREA10 END
          -- ********************************************************************
          FOR port_flow_rec IN port_flow_curs(call_trans_rec.x_service_id ,call_trans_rec.x_min)
          LOOP
            sa.clarify_case_pkg.dispatch_case(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_queue_name => 'TF/NT Auto Port Rework' ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            sa.clarify_case_pkg.update_status(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_new_status => 'Port Auto Failed' ,p_status_notes => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
            v_case_history := '*** Notes ' || SYSDATE || ' ' || 'igate_in3 --> ' || CHR(10) || CHR(13) || ' EPIR did not return successful. Port Auto Failed ';
            sa.clarify_case_pkg.log_notes(p_case_objid => port_flow_rec.objid ,p_user_objid => port_flow_rec.case_originator2user ,p_notes => v_case_history ,p_action_type => NULL ,p_error_no => v_case_error_no ,p_error_str => v_case_error_str);
          END LOOP;
        END IF;
      ELSIF ig_trans_rec.status = 'CP' AND (ig_trans_rec.order_type IN ('MINC' ,'E' ,'A')) THEN
        failed_log(ig_trans_rec);
        UPDATE gw1.ig_transaction SET status = 'CPU' WHERE ROWID = ig_trans_rec.rowid;
        COMMIT;
      END IF;
      --------------------------------------------------------------------------------------
    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      toss_util_pkg.insert_error_tab_proc('Process ig transaction id:  ' || ig_trans_rec.action_item_id ,ig_trans_rec.action_item_id ,l_program_name ,SUBSTR(SQLERRM ,1 ,255));
    END;
    <<next_action_item>>
    NULL;
    -- NET10_PAYGO STARTS
    BEGIN
      SELECT status
      INTO l_final_ig_status
      FROM gw1.ig_transaction
      WHERE ROWID = ig_trans_rec.rowid;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;

    IF l_final_ig_status = 'S' THEN
     --
      IF ig_trans_rec.order_type = 'E911' THEN
        FOR opened_case_rec IN opened_case_curs( ig_trans_rec.esn, ig_trans_rec.msid)
        LOOP
          igate.sp_close_case(opened_case_rec.id_number, USER , 'IGATE_IN' , 'Resolution Given', l_status, l_msg);
        END LOOP;
      END IF;

       --CR38927 Safelink upgrades Rate plan changes for safelink Disenrollment start
      FOR xrec IN (SELECT x_param_value from table_x_parameters where x_param_name ='SL SWITCH RATE PLAN CHANGE')
      LOOP
        IF (ig_trans_rec.order_type ='R' AND ig_trans_rec.language='TRANSFER' AND ig_trans_rec.template = xrec.x_param_value)
        THEN
          UPDATE table_part_inst tpi
          SET tpi.part_inst2carrier_mkt = CASE WHEN tpi.part_inst2carrier_mkt <> call_trans_rec.x_call_trans2carrier THEN call_trans_rec.x_call_trans2carrier
                                          ELSE tpi.part_inst2carrier_mkt
                                          END,
            tpi.part_inst2x_pers        = CASE WHEN tpi.part_inst2x_pers <> carrier_rec.carrier2personality THEN carrier_rec.carrier2personality
                                          ELSE  tpi.part_inst2x_pers
                                          END
          WHERE   part_serial_no        = ig_trans_rec.min
                  AND tpi.x_domain ='LINES';

        END IF;
      END LOOP;
      --CR38927 Safelink upgrades Rate plan changes for safelink Disenrollment end


      -- Change made by Kedar Parkhi on 8/28/2015 for CR35211
      apn_requests_pkg.create_ig_apn_requests ( i_transaction_id => ig_trans_rec.transaction_id ,
                                                o_response       => o_response ) ;

      -- reset types
      ipl := ig_pcrf_log_type ();
      ip  := ig_pcrf_log_type ();

      -- logic to avoid duplicate execution of the update_pcrf_subscriber
      IF NOT ipl.exist ( i_transaction_id => ig_trans_rec.transaction_id )
      THEN

        -- End of Super Carrier Changes to create the subscriber and pcrf record (CR35396, CR29586)
        sa.update_pcrf_subscriber ( i_esn                 => ig_trans_rec.esn        ,
                                    i_action_type         => NULL                    ,
                                    i_reason              => NULL                    ,
                                    i_src_program_name    => 'IGATE_IN3'             ,
                                    i_sourcesystem        => NULL                    ,
                                    i_ig_order_type       => ig_trans_rec.order_type ,
                                    i_transaction_id      => ig_trans_rec.transaction_id ,
                                    o_error_code          => l_error_code            ,
                                    o_error_msg           => l_error_msg             );
        -- End of Super Carrier Changes to create the subscriber and pcrf record (CR35396, CR29586)
        if l_error_code = 0  then
            -- log the pcrf ig log to avoid duplicate processing
            ip := ipl.ins ( i_transaction_id => ig_trans_rec.transaction_id );

            -- Save changes to avoid locks
            COMMIT;
        end if;
      END IF;
      --
      -- Send thresholsd to TMO
      BEGIN
       sa.send_thresholds_to_tmo ( i_transaction_id    =>  ig_trans_rec.transaction_id ,
                                i_call_trans_objid  =>  NULL                   ,
                                o_errorcode         =>  l_error_code  ,
                                o_errormsg          =>  l_error_msg );
      EXCEPTION
       WHEN OTHERS THEN
        NULL;
      END;

      sa.CONVERT_BO_TO_SQL_PKG.update_call_trans_extension(  in_call_trans_id    => call_trans_rec.objid ,
                                                              o_response         => o_response );     -- CR37756 PMistry 05/05/2016 Added new procedure call to update group member information in call trans.
      -- Added logic by Juda Pena to validate when to throttle a TW member (if the master is throttled) (CR36819)
      sa.validate_tw_throttling ( i_esn      => ig_trans_rec.esn,
                                  o_response => l_error_msg );

      --added for CR32258
      sa.T_MOBILE_RED_LOGS(ig_trans_rec.transaction_id);
      ---------addition end for CR32258
      OPEN mov_ig_dep_tx_curs(ig_trans_rec.action_item_id ,l_final_ig_status);
      FETCH mov_ig_dep_tx_curs INTO mov_ig_dep_tx_rec;
      IF mov_ig_dep_tx_curs%FOUND THEN
        INSERT
        INTO gw1.ig_transaction
          (
            action_item_id ,
            trans_prof_key ,
            carrier_id ,
            order_type ,
            MIN ,
            esn ,
            esn_hex ,
            old_esn ,
            old_esn_hex ,
            pin ,
            phone_manf ,
            end_user ,
            account_num ,
            market_code ,
            rate_plan ,
            ld_provider ,
            dealer_code ,
            transmission_method ,
            fax_num ,
            fax_num2 ,
            online_num ,
            online_num2 ,
            email ,
            network_login ,
            network_password ,
            system_login ,
            system_password ,
            template ,
            fax_batch_size ,
            fax_batch_q_time ,
            expidite ,
            technology_flag ,
            voice_mail ,
            voice_mail_package ,
            caller_id ,
            caller_id_package ,
            call_waiting ,
            call_waiting_package ,
            sms ,
            sms_package ,
            tux_iti_server ,
            q_transaction ,
            com_port ,
            transaction_id ,
            status ,
            status_message ,
            digital_feature ,
            digital_feature_code ,
            state_field ,
            zip_code ,
            msid ,
            iccid ,
            old_min ,
            ota_type ,
            rate_center_no ,
            application_system ,
            balance ,
            exp_date
          )
          VALUES
          (
            mov_ig_dep_tx_rec.dep_action_item_task_id ,
            --objid,
            --IG_DEPEND2IG_TRANS,
            mov_ig_dep_tx_rec.dep_trans_prof_key ,
            mov_ig_dep_tx_rec.dep_carrier_id ,
            mov_ig_dep_tx_rec.dep_order_type ,
            (SELECT MIN
            FROM gw1.ig_transaction
            WHERE action_item_id = ig_trans_rec.action_item_id
            AND ROWNUM           < 2
            ) , --cwl 4/11/12 CR20546
            --dep_MIN, -- after carrier response
            mov_ig_dep_tx_rec.dep_esn ,
            mov_ig_dep_tx_rec.dep_esn_hex ,
            mov_ig_dep_tx_rec.dep_old_esn ,
            mov_ig_dep_tx_rec.dep_old_esn_hex ,
            mov_ig_dep_tx_rec.dep_pin ,
            mov_ig_dep_tx_rec.dep_phone_manf ,
            mov_ig_dep_tx_rec.dep_end_user ,
            mov_ig_dep_tx_rec.dep_account_num ,
            mov_ig_dep_tx_rec.dep_market_code ,
            mov_ig_dep_tx_rec.dep_rate_plan ,
            mov_ig_dep_tx_rec.dep_ld_provider ,
            mov_ig_dep_tx_rec.dep_dealer_code ,
            mov_ig_dep_tx_rec.dep_transmission_method ,
            mov_ig_dep_tx_rec.dep_fax_num ,
            mov_ig_dep_tx_rec.dep_fax_num2 ,
            mov_ig_dep_tx_rec.dep_online_num ,
            mov_ig_dep_tx_rec.dep_online_num2 ,
            mov_ig_dep_tx_rec.dep_email ,
            mov_ig_dep_tx_rec.dep_network_login ,
            mov_ig_dep_tx_rec.dep_network_password ,
            mov_ig_dep_tx_rec.dep_system_login ,
            mov_ig_dep_tx_rec.dep_system_password ,
            mov_ig_dep_tx_rec.dep_template ,
            mov_ig_dep_tx_rec.dep_fax_batch_size ,
            mov_ig_dep_tx_rec.dep_fax_batch_q_time ,
            mov_ig_dep_tx_rec.dep_expidite ,
            mov_ig_dep_tx_rec.dep_technology_flag ,
            mov_ig_dep_tx_rec.dep_voice_mail ,
            mov_ig_dep_tx_rec.dep_voice_mail_package ,
            mov_ig_dep_tx_rec.dep_caller_id ,
            mov_ig_dep_tx_rec.dep_caller_id_package ,
            mov_ig_dep_tx_rec.dep_call_waiting ,
            mov_ig_dep_tx_rec.dep_call_waiting_package ,
            mov_ig_dep_tx_rec.dep_sms ,
            mov_ig_dep_tx_rec.dep_sms_package ,
            mov_ig_dep_tx_rec.dep_tux_iti_server ,
            mov_ig_dep_tx_rec.dep_q_transaction ,
            mov_ig_dep_tx_rec.dep_com_port ,
            mov_ig_dep_tx_rec.dep_transaction_id ,
            --GW1.TRANS_ID_SEQ.NEXTVAL transaction_id,
            --( select GW1.TRANS_ID_SEQ.NEXTVAL + (power (2, 28))from DUAL) transaction_id
            'Q' ,
            mov_ig_dep_tx_rec.dep_status_message ,
            mov_ig_dep_tx_rec.dep_digital_feature ,
            mov_ig_dep_tx_rec.dep_digital_feature_code ,
            mov_ig_dep_tx_rec.dep_state_field ,
            mov_ig_dep_tx_rec.dep_zip_code ,
            (SELECT msid
            FROM gw1.ig_transaction
            WHERE action_item_id = ig_trans_rec.action_item_id
            AND ROWNUM           < 2
            ) , --cwl 4/11/12 CR20546
            --dep_msid,-- after carrier response
            mov_ig_dep_tx_rec.dep_iccid ,
            mov_ig_dep_tx_rec.dep_old_min ,
            mov_ig_dep_tx_rec.dep_ota_type ,
            mov_ig_dep_tx_rec.dep_rate_center_no ,
            mov_ig_dep_tx_rec.dep_application_system ,
            mov_ig_dep_tx_rec.dep_balance ,
            mov_ig_dep_tx_rec.dep_exp_date
          );
        COMMIT;
        DELETE
        FROM gw1.ig_dependent_transaction
        WHERE parent_action_item_id = ig_trans_rec.action_item_id;
        COMMIT;
        /*
        1) After inserting into IG_TX and deleteing from IG_DEPENDENT_TX above
        2) NO need to insert into IG_TRANSACTION_BUCKETS as order type here will be 'R' and NOT 'PAP','PCR','ACR'
        3) NO need to insert into gw1.IG_TRANSACTION_ADDL_INFO as order type here will be 'R' and NOT 'EPIR'
        4) YES update table task with the rate plan written to IG_transaction from dependent table
        */
        UPDATE table_task
        SET x_rate_plan = mov_ig_dep_tx_rec.dep_rate_plan
        WHERE task_id   = mov_ig_dep_tx_rec.dep_action_item_task_id;
        COMMIT;
      END IF;
      CLOSE mov_ig_dep_tx_curs;

      -- CR33548 MOM Action Item  start  --- CR35007 FIX
          IF call_trans_rec.x_action_type = '3'
           THEN
            SP_QUEUED_CBO_SERVICE(ig_trans_rec.action_item_id, 'C', lb_commit);
            IF lb_commit THEN
            commit;
           END IF;
          END IF;
        -- CR33548 MOM Action Item  end    -- CR35007 FIX

    -- CR44652 BOGO Changes
      --
      /* -- CR44787 commenting BOGO Changes
      BEGIN
         BOGO_PKG.sp_validate_and_apply_bogo
         ( i_transaction_id => ig_trans_rec.transaction_id,
         o_response => o_response );
         --rollback;
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
      */
      --
   --CR43254 FOTA
      BEGIN
         IF ig_trans_rec.order_type <> 'FOTA'
         THEN

         sa.FOTA_SERVICE_PKG.PROCESS_FOTA_CAMP_TRANS (ip_transaction_id => ig_trans_rec.transaction_id
                        ,ip_call_trans_objid => NULL
                        ,op_err_code      => fota_error_code
                        ,op_err_msg       => fota_error_msg
                        );
         END IF;

      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
      --CR43254 FOTA
      -- CR47564 WFM changes starts..
      contact_pkg.p_update_contact_pin  ( i_esn               =>  ig_trans_rec.esn,
                                          i_ig_order_type     =>  ig_trans_rec.order_type,
                                          i_ig_status         =>  l_final_ig_status,
                                          i_ig_transaction_id =>  ig_trans_rec.transaction_id,
                                          o_error_code        =>  l_error_code,
                                          o_error_msg         =>  l_error_msg);

        --CR47564  WFM changes  calling Enqueue Transaction Package
      enqueue_transactions_pkg.enqueue_transaction (i_esn               => ig_trans_rec.esn           ,
                                                      i_ig_order_type     => ig_trans_rec.order_type    ,
                                                      i_ig_transaction_id => ig_trans_rec.transaction_id,
                                                      o_response          => o_response
                                                      );

       ild_transaction_pkg.p_update_table_x_ild_tran (i_esn          =>    ig_trans_rec.esn ,
                                                      i_order_type   =>    ig_trans_rec.order_type,
                                                      i_min          =>    ig_trans_rec.msid,
                                                      o_err_num      =>    l_error_code,
                                                      o_err_string   =>    l_error_msg
                                                      );
      --Update x_account_group service_plan_id with the ESN service plan objid for Non-Shared Group Plan
      IF sa.customer_info.get_shared_group_flag ( i_esn => ig_trans_rec.esn ) = 'N' THEN
        -- get the service plan and group ID
        gt                 := sa.group_type ( i_esn => ig_trans_rec.esn );
        gt.service_plan_id := gt.get_service_plan_objid ( i_esn => ig_trans_rec.esn );

        -- if the service plan was found
        IF gt.service_plan_id IS NOT NULL THEN
          -- instantiate values
          gt := sa.group_type ( i_group_objid => gt.group_objid, i_service_plan_id => gt.service_plan_id);
          -- call method to update the missing service plan
          g := gt.upd;
        END IF;

      END IF;

        -- CR47564 WFM changes ends.

      --If the order type is deactivation, update the projected LIFELINE enrollment end date in ll_subscribers table
      BEGIN
        IF call_trans_rec.x_action_type = '2'
        THEN
          UPDATE sa.ll_subscribers
          SET    projected_deenrollment = SYSDATE + 45,
		 lastmodified = SYSDATE,
                 last_modified_event = 'ESN/MIN DEACTIVATION'
          WHERE  current_min = call_trans_rec.x_min
          AND    NVL(enrollment_status, 'ENROLLED') <> 'DEENROLLED';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          o_ll_red_err := SQLCODE;
          o_ll_red_err_msg := SQLERRM;
          toss_util_pkg.insert_error_tab_proc('Deactivation of Lifeline enrolled ESN' ,call_trans_rec.objid ,'IGATE_IN3' ,'Error while updating the projected LIFELINE enrollment end date in ll_subscribers table. ErrCode -'||o_ll_red_err||'**ErrMsg-'||o_ll_red_err_msg);
      END;

      --CR49915 commented the call to Redemption logic. mdave, 07/31/2017
	  -- CR49915 Lifeline for other Brands - WFM , logic for redemption, mdave, 06/22/2017
		/*	BEGIN
				IF call_trans_rec.x_action_type = '6' THEN
						IF SA.LL_ENROLLMENT_EXIST_FUN(call_trans_rec.x_min) THEN
						   SA.LL_SUBSCRIBER_PKG.LL_REDEMPTION_TRANSACTION(call_trans_rec.objid,call_trans_rec.x_service_id,call_trans_rec.x_min, o_ll_red_err, o_ll_red_err_msg);
							IF o_ll_red_err IS NOT NULL or o_ll_red_err_msg IS NOT NULL THEN
								toss_util_pkg.insert_error_tab_proc('Lifeline Redemption' ,call_trans_rec.objid ,'LL_SUBSCRIBER_PKG.LL_REDEMPTION_TRANSACTION' ,'ErrCode -'||o_ll_red_err||'**ErrMsg-'||o_ll_red_err_msg);
							END IF;
						END IF;

				END IF;
			EXCEPTION
				WHEN OTHERS THEN
				NULL;
			END; */
		-- END CR49915 Lifeline for other Brands - WFM , logic for redemption, mdave, 06/22/2017

		-- CR49915 Lifeline for other Brands - WFM , logic for min change, mdave, 06/22/2017
			BEGIN
				IF ig_trans_rec.order_type IN ('A','MINC') THEN
						IF sa.LL_ENROLLMENT_EXIST_FUN(ig_trans_rec.old_min) THEN
						   sa.LL_SUBSCRIBER_PKG.LL_MINC_TRANSACTION(ig_trans_rec.transaction_id, o_ll_minc_err, o_ll_minc_err_msg);
							IF o_ll_minc_err IS NOT NULL OR o_ll_minc_err_msg IS NOT NULL THEN
								toss_util_pkg.insert_error_tab_proc('Lifeline MIN change' ,call_trans_rec.objid ,'LL_SUBSCRIBER_PKG.LL_MINC_TRANSACTION' ,'ErrCode -'||o_ll_minc_err||'**ErrMsg-'||o_ll_minc_err_msg);
							END IF;
						END IF;
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
				NULL;
			END;
		-- END CR49915 Lifeline for other Brands - WFM , logic for min change, mdave, 06/22/2017

		-- CR49915 Lifeline for other Brands - WFM , logic for ESN change, mdave, 06/27/2017
			BEGIN
				IF ig_trans_rec.order_type ='E' THEN
						IF sa.LL_ENROLLMENT_EXIST_FUN(ig_trans_rec.msid) THEN
						   sa.LL_SUBSCRIBER_PKG.LL_ESN_CHANGE_TRANSACTION(ig_trans_rec.transaction_id, o_ll_esnc_err, o_ll_esnc_err_msg);
							IF o_ll_esnc_err IS NOT NULL OR o_ll_esnc_err_msg IS NOT NULL THEN
								toss_util_pkg.insert_error_tab_proc('Lifeline ESN change' ,call_trans_rec.objid ,'LL_SUBSCRIBER_PKG.LL_ESN_CHANGE_TRANSACTION' ,'ErrCode -'||o_ll_esnc_err||'**ErrMsg-'||o_ll_esnc_err_msg);
							END IF;
						END IF;
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
				NULL;
			END;
		-- END CR49915 Lifeline for other Brands - WFM , logic for esn change, mdave, 06/27/2017
		  -- CR49058 changes starts..
          --  update the actual MIN in vas
		  -- Processing all succeeded procs to update and handling sta
            vas_management_pkg.p_update_vas_min   ( i_esn           =>  ig_trans_rec.esn,
                                                    i_min           =>  ig_trans_rec.min,
                                                    i_order_type    =>  ig_trans_rec.order_type,
                                                    o_error_code    =>  c_error_code,
                                                    o_error_msg     =>  c_error_msg
                                                  );
          -- CR49058 changes ends.
    END IF;
    -- NET10_PAYGO ENDS
  END LOOP;
  IF toss_util_pkg.insert_interface_jobs_fun(l_program_name ,l_start_date ,SYSDATE ,l_recs_processed ,'SUCCESS' ,l_program_name) THEN
    COMMIT;
  END IF;
END;

--CR54061 - New procedure to process order types that do not require complete IN3 processing
PROCEDURE rta_lite ( p_div IN NUMBER DEFAULT 1 ,
                     p_rem IN NUMBER DEFAULT 0 )
IS
  --
  CURSOR get_ig_trans IS
    SELECT *
    FROM  (SELECT /*+ USE_NL(a t) */  a.* , a.rowid
           FROM  table_task t,
                 gw1.ig_transaction a
           WHERE t.task_id                     = a.action_item_id
           AND   a.status                     IN ('E' ,'W')
           AND   MOD(a.transaction_id, p_div)  = p_rem
           AND   a.order_type IN (SELECT x_ig_order_type
                                  FROM   x_ig_order_type
                                  WHERE  PROCESS_IGATE_IN3_LITE_FLAG = 'Y')
           AND NOT EXISTS(SELECT 1
                          FROM  sa.x_ig_order_type iot
                          WHERE a.order_type            = iot.x_ig_order_type
                          AND   iot.safelink_batch_flag = 'Y')
           AND NOT (a.status = 'E' AND a.status_message = 'CREATE SIM EXCHANGE CASE'));

  CURSOR newer_ig_curs(c_action_item_id IN VARCHAR2) IS
    SELECT b.objid newer_task_objid
    FROM   gw1.ig_transaction a,
           table_task b,
           table_x_call_trans ct1
    WHERE  a.action_item_id    = c_action_item_id
    AND    a.status           IN ('E','EE','F','FF','HW','C')
    AND    a.order_type       IN (SELECT x_ig_order_type FROM x_ig_order_type WHERE newer_trans_flag ='Y' )
    AND    b.task_id           = a.action_item_id
    AND NOT EXISTS  (SELECT 1
                     FROM   table_gbst_elm eg
                     WHERE  eg.objid            =  b.type_task2gbst_elm
                     AND    UPPER(title)       IN ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS'))
    AND ct1.objid              = b.x_task2x_call_trans
    AND EXISTS (SELECT /*+ USE_INVISIBLE_INDEXES */    1
                FROM  gw1.ig_transaction c,
                      table_task d,
                      table_x_call_trans ct2
                WHERE c.esn              = a.esn
                AND   c.order_type      IN (SELECT x_ig_order_type FROM x_ig_order_type WHERE newer_trans_flag ='Y')
                AND   d.task_id          = c.action_item_id
                AND NOT EXISTS  (SELECT 1
                                 FROM table_gbst_elm eg
                                 WHERE eg.objid    = d.type_task2gbst_elm
                                 AND UPPER(title) IN ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS'))
                AND ct2.objid           = d.x_task2x_call_trans
                AND ct2.x_transact_date > ct1.x_transact_date );

  CURSOR older_ig_curs(c_action_item_id IN VARCHAR2) IS
    SELECT /*+ USE_INVISIBLE_INDEXES ORDERED */
           d.objid older_task_objid,
           c.transaction_id
    FROM gw1.ig_transaction a,
         table_task b,
         table_x_call_trans ct1,
         gw1.ig_transaction c,
         table_task d ,
         table_x_call_trans ct2
    WHERE 1                  = 1
    AND a.action_item_id     = c_action_item_id
    AND a.order_type        IN (SELECT x_ig_order_type FROM x_ig_order_type WHERE newer_trans_flag   ='Y')
    AND b.task_id            = a.action_item_id
    AND NOT EXISTS             (SELECT 1
                                FROM table_gbst_elm eg
                                WHERE eg.objid    = b.type_task2gbst_elm
                                AND UPPER(title) IN ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS'))
    AND ct1.objid            = b.x_task2x_call_trans
    AND c.esn                = a.esn
    AND c.STATUS            IN ('E','EE','F','FF','HW','C')
    AND c.order_type        IN (SELECT x_ig_order_type FROM x_ig_order_type WHERE newer_trans_flag   ='Y')
    AND d.task_id            = c.action_item_id
    AND NOT EXISTS             (SELECT 1
                                FROM TABLE_GBST_ELM eg
                                WHERE eg.objid    = D.TYPE_TASK2GBST_ELM
                                AND UPPER(TITLE) IN ('BALANCE INQUIRY','PRL INQUIRY','INTERNAL PORT STATUS'))
    AND ct2.objid            = d.x_task2x_call_trans
    AND ct2.x_transact_date  < ct1.x_transact_date;

  newer_ig_rec  newer_ig_curs%rowtype;
  older_ig_rec  older_ig_curs%rowtype;
  ig_status     gw1.ig_transaction.status%TYPE;
  hold          NUMBER;
  l_error_msg   VARCHAR2(2000);
  l_error_code  NUMBER;

-- Start of Main Section
BEGIN
  -- Loop through all
  FOR ig_trans_rec IN get_ig_trans
  LOOP

    -- Reset IG transaction status
    ig_status := NULL;

    -- Get current status of the IG row
    BEGIN
      SELECT status
      INTO   ig_status
      FROM   gw1.ig_transaction
      WHERE  transaction_id = ig_trans_rec.transaction_id;
    EXCEPTION
       WHEN others THEN
         CONTINUE; -- Continue to next iteration
    END;

    -- Making sure the STATUS was not set to SUCCESSFUL by another process
    IF ig_status = 'S' THEN

      CONTINUE; -- Continue to next iteration

    END IF;

    -- Find a newer IG transaction row
    OPEN newer_ig_curs(ig_trans_rec.action_item_id);
    FETCH newer_ig_curs INTO newer_ig_rec;
    IF newer_ig_curs%FOUND THEN

      igate.sp_close_action_item(newer_ig_rec.newer_task_objid ,0 ,hold);

      UPDATE gw1.ig_transaction
      SET status         = 'TF',
          status_message = 'NEWER TRANSACTION FOUND'
      WHERE ROWID        = ig_trans_rec.ROWID;

      DELETE FROM gw1.ig_transaction_features
      WHERE  transaction_id = ig_trans_rec.transaction_id;
      COMMIT;

      CLOSE newer_ig_curs;

      CONTINUE;
    END IF;
    CLOSE newer_ig_curs;


    FOR older_ig_rec IN older_ig_curs(ig_trans_rec.action_item_id)
    LOOP
      BEGIN

        igate.sp_close_action_item(older_ig_rec.older_task_objid ,0 ,hold);

        UPDATE gw1.ig_transaction
        SET status           = 'TF',
            status_message   = 'NEWER TRANSACTION FOUND'
        WHERE transaction_id = older_ig_rec.transaction_id;

        DELETE FROM gw1.ig_transaction_features
        WHERE transaction_id = older_ig_rec.transaction_id;

        COMMIT;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

    END LOOP;

    -- Fail the IG transaction row when there is an error (E)
    IF ig_status = 'E' THEN

       BEGIN

          INSERT
          INTO gw1.ig_failed_log
          (
            action_item_id ,
            carrier_id ,
            order_type ,
            MIN ,
            esn ,
            esn_hex ,
            old_esn ,
            old_esn_hex ,
            pin ,
            phone_manf ,
            end_user ,
            account_num ,
            market_code ,
            rate_plan ,
            ld_provider ,
            sequence_num ,
            dealer_code ,
            transmission_method ,
            fax_num ,
            online_num ,
            email ,
            network_login ,
            network_password ,
            system_login ,
            system_password ,
            template ,
            com_port ,
            status ,
            status_message ,
            trans_prof_key ,
            q_transaction ,
            fax_num2 ,
            creation_date ,
            update_date ,
            blackout_wait ,
            transaction_id ,
            technology_flag ,
            voice_mail ,
            voice_mail_package ,
            caller_id ,
            caller_id_package ,
            call_waiting ,
            call_waiting_package ,
            digital_feature_code ,
            state_field ,
            zip_code ,
            msid ,
            new_msid_flag ,
            sms ,
            sms_package ,
            iccid ,
            old_min ,
            digital_feature ,
            ota_type ,
            rate_center_no ,
            application_system ,
            subscriber_update ,
            download_date ,
            prl_number ,
            amount ,
            balance ,
            LANGUAGE ,
            exp_date ,
            logged_date ,
            logged_by
          )
          VALUES
          (
            ig_trans_rec.action_item_id ,
            ig_trans_rec.carrier_id ,
            ig_trans_rec.order_type ,
            ig_trans_rec.min ,
            ig_trans_rec.esn ,
            ig_trans_rec.esn_hex ,
            ig_trans_rec.old_esn ,
            ig_trans_rec.old_esn_hex ,
            ig_trans_rec.pin ,
            ig_trans_rec.phone_manf ,
            ig_trans_rec.end_user ,
            ig_trans_rec.account_num ,
            ig_trans_rec.market_code ,
            ig_trans_rec.rate_plan ,
            ig_trans_rec.ld_provider ,
            ig_trans_rec.sequence_num ,
            ig_trans_rec.dealer_code ,
            ig_trans_rec.transmission_method ,
            ig_trans_rec.fax_num ,
            ig_trans_rec.online_num ,
            ig_trans_rec.email ,
            ig_trans_rec.network_login ,
            ig_trans_rec.network_password ,
            ig_trans_rec.system_login ,
            ig_trans_rec.system_password ,
            ig_trans_rec.template ,
            ig_trans_rec.com_port ,
            ig_trans_rec.status ,
            ig_trans_rec.status_message ,
            ig_trans_rec.trans_prof_key ,
            ig_trans_rec.q_transaction ,
            ig_trans_rec.fax_num2 ,
            ig_trans_rec.creation_date ,
            ig_trans_rec.update_date ,
            ig_trans_rec.blackout_wait ,
            ig_trans_rec.transaction_id ,
            ig_trans_rec.technology_flag ,
            ig_trans_rec.voice_mail ,
            ig_trans_rec.voice_mail_package ,
            ig_trans_rec.caller_id ,
            ig_trans_rec.caller_id_package ,
            ig_trans_rec.call_waiting ,
            ig_trans_rec.call_waiting_package ,
            ig_trans_rec.digital_feature_code ,
            ig_trans_rec.state_field ,
            ig_trans_rec.zip_code ,
            ig_trans_rec.msid ,
            ig_trans_rec.new_msid_flag ,
            ig_trans_rec.sms ,
            ig_trans_rec.sms_package ,
            ig_trans_rec.iccid ,
            ig_trans_rec.old_min ,
            ig_trans_rec.digital_feature ,
            ig_trans_rec.ota_type ,
            ig_trans_rec.rate_center_no ,
            ig_trans_rec.application_system ,
            ig_trans_rec.subscriber_update ,
            ig_trans_rec.download_date ,
            ig_trans_rec.prl_number ,
            ig_trans_rec.amount ,
            ig_trans_rec.balance ,
            ig_trans_rec.language ,
            ig_trans_rec.exp_date ,
            SYSDATE ,
            'igate_in3_rta_lite'
          );

          UPDATE gw1.ig_transaction
          SET status  = 'F'
          WHERE ROWID = ig_trans_rec.ROWID;

          COMMIT;

          -- Continue to next iteration
          CONTINUE;

       EXCEPTION
          WHEN OTHERS THEN
             NULL;
       END;
    END IF;

    -- Set the IG transaction to successful
    IF ig_status = 'W' THEN
       BEGIN

          UPDATE gw1.ig_transaction
          SET status  = 'S'
          WHERE ROWID = ig_trans_rec.ROWID;

          --
          send_thresholds_to_tmo ( i_transaction_id    =>  ig_trans_rec.transaction_id ,
                                   i_call_trans_objid  =>  NULL                   ,
                                   o_errorcode         =>  l_error_code  ,
                                   o_errormsg          =>  l_error_msg );
          COMMIT;


          -- Continue to next iteration
          CONTINUE;
       EXCEPTION
          WHEN OTHERS THEN
             NULL;
       END;
    END IF;

  END LOOP; -- get_ig_trans

  -- Save
  COMMIT;

END rta_lite;
END IGATE_IN3;
/