CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_CASE" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_CASE_PKB.sql,v $
--$Revision: 1.142 $
--$Author: syenduri $
--$Date: 2018/05/29 22:23:29 $
--$ $Log: ADFCRM_CASE_PKB.sql,v $
--$ Revision 1.142  2018/05/29 22:23:29  syenduri
--$ CR57188 - Added replace for ste to apt and suite to apt
--$
--$ Revision 1.141  2018/05/25 14:46:12  mmunoz
--$ CR57660 Added description of issue in ticket detail
--$
--$ Revision 1.139  2018/05/15 22:21:44  syenduri
--$ CR57188 - Corrected regexp_replace text
--$
--$ Revision 1.138  2018/05/15 21:50:00  mmunoz
--$ CR57660 Restore Denied Exchange Case Creation
--$
--$ Revision 1.137  2018/05/15 15:21:16  syenduri
--$ CR57188 - Used regexp_replace more precisely to detect and emliminate special characters
--$
--$ Revision 1.136  2018/05/11 16:36:45  syenduri
--$ CR57188: Done changes to eleminate special characters in address
--$
--$ Revision 1.135  2018/05/10 15:51:11  syenduri
--$ Merge REL956 version into REL957
--$
--$ Revision 1.134  2018/05/04 17:07:21  syenduri
--$ CR56717 : Done changes to consider Transaction Day into count for Delivery Date Calculation.
--$
--$ Revision 1.132  2018/04/27 19:55:55  syenduri
--$ CR567171 - Removed IN Param for GENERATE_ORDER_ID
--$
--$ Revision 1.131  2018/04/26 22:06:40  pkapaganty
--$ CR57442 Update Cases Not to Reopen
--$ Added logic to Case reopen to use the flags X_BLOC_REOPEN and X_REOPEN_DAYS_CHECK
--$
--$ Revision 1.130  2018/04/19 14:19:30  syenduri
--$ CR56717 : Shipping Options Script Change
--$
--$ Revision 1.129  2018/04/18 22:47:11  syenduri
--$ CR56717 : Modified script for shipping options
--$
--$ Revision 1.128  2018/04/13 21:08:50  syenduri
--$ CR56717 - TAS Overnight Ship Exchange Option
--$
--$ Revision 1.127  2018/04/12 18:40:17  pkapaganty
--$ CR57651 SL Dummy Part Number Process Modification
--$
--$ Revision 1.126  2018/03/08 20:32:13  mmunoz
--$ CR55349 TAS SL Phone Exchange Improvements, added if v_pn_domain = 'PHONES' when open sl_part_num_cur
--$
--$ Revision 1.125  2018/02/28 22:43:15  pkapaganty
--$ CR53035 All Brands  TAS   General Information interactions without an Account
--$ Updated create_interaction3 to accept brand.
--$
--$ Revision 1.124  2018/02/21 23:07:47  mmunoz
--$ Fix to add the agent in table_interact when no contact associated with an ESN
--$
--$ Revision 1.123  2018/02/08 15:19:25  pkapaganty
--$ CR55349 TAS SL Phone Exchange Improvements - To retreive a  Dummy part number for SL phones.
--$
--$ Revision 1.121  2018/01/05 18:59:06  pkapaganty
--$ Fix for new Interaction not saving the channel.
--$
--$ Revision 1.120  2018/01/05 18:29:55  nguada
--$ *** empty log message ***
--$
--$ Revision 1.119  2017/12/06 13:48:40  pkapaganty
--$ CR54891 TAS Case Reopen Restriction Logic
--$     Created a new procedure to check if case can be created based on esn and case type,title details. It will check for existing case on ESN and see if it can be reopened.
--$
--$ Revision 1.118  2017/11/03 17:52:40  nguada
--$ Merged version CR54247
--$
--$ Revision 1.116  2017/10/06 19:16:23  mmunoz
--$ CR52928 replacing # and unit for apt  in case address, function  is_fraud_detected
--$
--$ Revision 1.115  2017/10/06 18:03:54  mmunoz
--$ CR52928 replacing ||  in case address, function  is_fraud_detected
--$
--$ Revision 1.114  2017/10/05 22:18:27  mmunoz
--$ CR52928 Checking address line 2 in  is_fraud_detected
--$
--$ Revision 1.113  2017/09/27 16:37:34  mmunoz
--$ CR52928 Block Shipments to Fraud related addresses
--$
--$ Revision 1.112  2017/09/22 22:27:19  mmunoz
--$ CR53515 Air Time Cases Autoclose
--$
--$ Revision 1.111  2017/06/26 16:57:38  pkapaganty
--$ CR49310
--$
--$ Revision 1.110  2017/06/20 21:25:48  hcampano
--$ CR51506	- Fix Migration Campaign Exchange Options
--$
--$ Revision 1.109  2017/06/16 21:11:27  mmunoz
--$ CR49638 Enforce Carriersimpref Validation, checking invalid part number
--$
--$ Revision 1.108  2017/05/18 15:03:40  mmunoz
--$ CR49638 Enforce Carriersimpref Validation and CR49600 Block Sprint SIM Exchange
--$
--$ Revision 1.107  2017/04/19 20:21:24  hcampano
--$ REL859_TAS - Change to unable/unable logic - CR45121
--$
--$ Revision 1.106  2017/04/18 18:10:37  hcampano
--$ REL859_TAS - Change to unable/unable logic - CR45121
--$
--$ Revision 1.105  2017/04/18 14:01:30  hcampano
--$ REL859_TAS - CR47983 - Assign Part Numbers to Case TypesTitles (Reintroduced)
--$
--$ Revision 1.104  2017/04/14 17:54:29  nguada
--$ Bug fixes repl_part_num
--$
--$ Revision 1.103  2017/04/07 18:13:14  nguada
--$ CR Rolledback CR47983
--$
--$ Revision 1.97  2017/02/15 21:08:42  mmunoz
--$ CR46924 For some Warranty cases check if Warranty days expired
--$
--$ Revision 1.96  2017/02/08 15:22:09  mmunoz
--$ CR47337 : Added function auto_close_case
--$
--$ Revision 1.95  2017/01/25 15:41:00  mmunoz
--$ CR45525 removed update for case detail ACTIVATION_ZIP_CODE
--$
--$ Revision 1.94  2017/01/23 19:25:30  mmunoz
--$ CR47448 Exclude Handset Protection Cases from the Subsidy Check
--$
--$ Revision 1.93  2017/01/10 19:24:46  mmunoz
--$ CR47303: Use the Safelink subsidy cost for Safelink phones (regardless of the base brand).
--$
--$ Revision 1.92  2016/12/27 19:52:35  nguada
--$ CR45525 12/27/2016
--$
--$ Revision 1.91  2016/12/22 18:55:58  nguada
--$ CR46448
--$
--$ Revision 1.90  2016/12/08 19:41:14  mmunoz
--$ CR46571
--$
--$ Revision 1.89  2016/12/06 19:32:11  nguada
--$ CR46571
--$
--$ Revision 1.88  2016/12/05 18:16:51  nguada
--$ CR46571
--$
--$ Revision 1.87  2016/12/05 18:05:01  nguada
--$ CR46571
--$
--$ Revision 1.86  2016/12/02 22:31:39  nguada
--$ CR46733  bug fix
--$
--$ Revision 1.85  2016/11/30 23:20:37  nguada
--$
--$ CR46571  req changes + new message
--$
--$ Revision 1.84  2016/11/30 21:14:52  mmunoz
--$ CR46733 Subsidy Evaluation for Warranty Exchanges
--$
--$ Revision 1.83  2016/11/25 19:15:50  nguada
--$ CR46733 Subsidy Evaluation for Warranty Exchanges
--$
--$ Revision 1.82  2016/11/15 18:29:08  nguada
--$ BAU-258
--$ CR46513 Restore warranty exchange for out of warranty phones
--$
--$ Revision 1.81  2016/10/14 20:44:12  amishra
--$ Merging changes from 1.79 with 1.80
--$
--$ Revision 1.80  2016/10/05 16:51:03  mmunoz
--$ CR43561: Including org_id=GENERIC for RETAILER logic, merged with rev 1.76 (CR43207)
--$
--$ Revision: 1.79 $
--$ Author: nguada $
--$ Date: 2016/10/04 20:48:10 $
--$ $Log: ADFCRM_CASE_PKB.sql,v $
--$ Revision 1.142  2018/05/29 22:23:29  syenduri
--$ CR57188 - Added replace for ste to apt and suite to apt
--$
--$ Revision 1.141  2018/05/25 14:46:12  mmunoz
--$ CR57660 Added description of issue in ticket detail
--$
--$ Revision 1.139  2018/05/15 22:21:44  syenduri
--$ CR57188 - Corrected regexp_replace text
--$
--$ Revision 1.138  2018/05/15 21:50:00  mmunoz
--$ CR57660 Restore Denied Exchange Case Creation
--$
--$ Revision 1.137  2018/05/15 15:21:16  syenduri
--$ CR57188 - Used regexp_replace more precisely to detect and emliminate special characters
--$
--$ Revision 1.136  2018/05/11 16:36:45  syenduri
--$ CR57188: Done changes to eleminate special characters in address
--$
--$ Revision 1.135  2018/05/10 15:51:11  syenduri
--$ Merge REL956 version into REL957
--$
--$ Revision 1.134  2018/05/04 17:07:21  syenduri
--$ CR56717 : Done changes to consider Transaction Day into count for Delivery Date Calculation.
--$
--$ Revision 1.132  2018/04/27 19:55:55  syenduri
--$ CR567171 - Removed IN Param for GENERATE_ORDER_ID
--$
--$ Revision 1.131  2018/04/26 22:06:40  pkapaganty
--$ CR57442 Update Cases Not to Reopen
--$ Added logic to Case reopen to use the flags X_BLOC_REOPEN and X_REOPEN_DAYS_CHECK
--$
--$ Revision 1.130  2018/04/19 14:19:30  syenduri
--$ CR56717 : Shipping Options Script Change
--$
--$ Revision 1.129  2018/04/18 22:47:11  syenduri
--$ CR56717 : Modified script for shipping options
--$
--$ Revision 1.128  2018/04/13 21:08:50  syenduri
--$ CR56717 - TAS Overnight Ship Exchange Option
--$
--$ Revision 1.127  2018/04/12 18:40:17  pkapaganty
--$ CR57651 SL Dummy Part Number Process Modification
--$
--$ Revision 1.126  2018/03/08 20:32:13  mmunoz
--$ CR55349 TAS SL Phone Exchange Improvements, added if v_pn_domain = 'PHONES' when open sl_part_num_cur
--$
--$ Revision 1.125  2018/02/28 22:43:15  pkapaganty
--$ CR53035 All Brands  TAS   General Information interactions without an Account
--$ Updated create_interaction3 to accept brand.
--$
--$ Revision 1.124  2018/02/21 23:07:47  mmunoz
--$ Fix to add the agent in table_interact when no contact associated with an ESN
--$
--$ Revision 1.123  2018/02/08 15:19:25  pkapaganty
--$ CR55349 TAS SL Phone Exchange Improvements - To retreive a  Dummy part number for SL phones.
--$
--$ Revision 1.121  2018/01/05 18:59:06  pkapaganty
--$ Fix for new Interaction not saving the channel.
--$
--$ Revision 1.120  2018/01/05 18:29:55  nguada
--$ *** empty log message ***
--$
--$ Revision 1.119  2017/12/06 13:48:40  pkapaganty
--$ CR54891 TAS Case Reopen Restriction Logic
--$     Created a new procedure to check if case can be created based on esn and case type,title details. It will check for existing case on ESN and see if it can be reopened.
--$
--$ Revision 1.118  2017/11/03 17:52:40  nguada
--$ Merged version CR54247
--$
--$ Revision 1.116  2017/10/06 19:16:23  mmunoz
--$ CR52928 replacing # and unit for apt  in case address, function  is_fraud_detected
--$
--$ Revision 1.115  2017/10/06 18:03:54  mmunoz
--$ CR52928 replacing ||  in case address, function  is_fraud_detected
--$
--$ Revision 1.114  2017/10/05 22:18:27  mmunoz
--$ CR52928 Checking address line 2 in  is_fraud_detected
--$
--$ Revision 1.113  2017/09/27 16:37:34  mmunoz
--$ CR52928 Block Shipments to Fraud related addresses
--$
--$ Revision 1.112  2017/09/22 22:27:19  mmunoz
--$ CR53515 Air Time Cases Autoclose
--$
--$ Revision 1.111  2017/06/26 16:57:38  pkapaganty
--$ CR49310
--$
--$ Revision 1.110  2017/06/20 21:25:48  hcampano
--$ CR51506	- Fix Migration Campaign Exchange Options
--$
--$ Revision 1.109  2017/06/16 21:11:27  mmunoz
--$ CR49638 Enforce Carriersimpref Validation, checking invalid part number
--$
--$ Revision 1.108  2017/05/18 15:03:40  mmunoz
--$ CR49638 Enforce Carriersimpref Validation and CR49600 Block Sprint SIM Exchange
--$
--$ Revision 1.107  2017/04/19 20:21:24  hcampano
--$ REL859_TAS - Change to unable/unable logic - CR45121
--$
--$ Revision 1.106  2017/04/18 18:10:37  hcampano
--$ REL859_TAS - Change to unable/unable logic - CR45121
--$
--$ Revision 1.105  2017/04/18 14:01:30  hcampano
--$ REL859_TAS - CR47983 - Assign Part Numbers to Case TypesTitles (Reintroduced)
--$
--$ Revision 1.104  2017/04/14 17:54:29  nguada
--$ Bug fixes repl_part_num
--$
--$ Revision 1.103  2017/04/07 18:13:14  nguada
--$ CR Rolledback CR47983
--$
--$ Revision 1.97  2017/02/15 21:08:42  mmunoz
--$ CR46924 For some Warranty cases check if Warranty days expired
--$
--$ Revision 1.96  2017/02/08 15:22:09  mmunoz
--$ CR47337 : Added function auto_close_case
--$
--$ Revision 1.95  2017/01/25 15:41:00  mmunoz
--$ CR45525 removed update for case detail ACTIVATION_ZIP_CODE
--$
--$ Revision 1.94  2017/01/23 19:25:30  mmunoz
--$ CR47448 Exclude Handset Protection Cases from the Subsidy Check
--$
--$ Revision 1.93  2017/01/10 19:24:46  mmunoz
--$ CR47303: Use the Safelink subsidy cost for Safelink phones (regardless of the base brand).
--$
--$ Revision 1.92  2016/12/27 19:52:35  nguada
--$ CR45525 12/27/2016
--$
--$ Revision 1.91  2016/12/22 18:55:58  nguada
--$ CR46448
--$
--$ Revision 1.90  2016/12/08 19:41:14  mmunoz
--$ CR46571
--$
--$ Revision 1.89  2016/12/06 19:32:11  nguada
--$ CR46571
--$
--$ Revision 1.88  2016/12/05 18:16:51  nguada
--$ CR46571
--$
--$ Revision 1.87  2016/12/05 18:05:01  nguada
--$ CR46571
--$
--$ Revision 1.86  2016/12/02 22:31:39  nguada
--$ CR46733  bug fix
--$
--$ Revision 1.85  2016/11/30 23:20:37  nguada
--$
--$ CR46571  req changes + new message
--$
--$ Revision 1.84  2016/11/30 21:14:52  mmunoz
--$ CR46733 Subsidy Evaluation for Warranty Exchanges
--$
--$ Revision 1.83  2016/11/25 19:15:50  nguada
--$ CR46733 Subsidy Evaluation for Warranty Exchanges
--$
--$ Revision 1.82  2016/11/15 18:29:08  nguada
--$ BAU-258
--$ CR46513 Restore warranty exchange for out of warranty phones
--$
--$ Revision 1.81  2016/10/14 20:44:12  amishra
--$ Merging changes from 1.79 with 1.80
--$
--$ Revision 1.79  2016/10/04 20:48:10  nguada
--$ CR45794
--$
--$ Revision 1.78  2016/10/03 14:38:29  nguada
--$ CR45794 Refurb Warranty Exchage Logic
--$
--$ Revision 1.77  2016/09/29 14:21:37  amishra
--$ CR44443
--$
--$ Revision 1.76  2016/09/23 15:12:27  nguada
--$ 43207 bug fix changes missing from validate_part_request
--$
--$ Revision 1.75  2016/09/20 22:09:25  mmunoz
--$ CR43561	 TAS ? Enhance iPhone HPP Case creation. Added replacement logic for RETAILER
--$
--$ Revision 1.74  2016/09/16 15:44:15  nguada
--$ TAS_2016_21A
--$
--$ Revision 1.71  2016/09/15 22:32:30  mmunoz
--$ CR42725 New procedure upd_case_detail_flag
--$
--$ Revision 1.70  2016/09/15 22:06:40  nguada
--$ Block phone warehouse cases passed 1 yer for new 90 days for refurb.
--$
--$ Revision 1.69  2016/09/13 18:15:10  nguada
--$ CR45227
--$
--$ Revision 1.68  2016/09/12 21:02:39  nguada
--$ CR45227
--$
--$ Revision 1.66  2016/09/02 17:27:41  nguada
--$ CR45227
--$
--$ Revision 1.65  2016/07/25 19:22:10  nguada
--$ CR42535: TAS SIM Case Creation with Sim Reserved - Populate Part Num
--$
--$ Revision 1.64  2016/06/02 13:27:13  nguada
--$ CR42470
--$
--$ Revision 1.63  2016/05/02 15:58:05  mmunoz
--$ CR42603 : Changes in get_repl_part_number for UNLOCK exchange
--$
--$ Revision 1.62  2016/04/20 15:15:15  hcampano
--$ CR40993 - 2G Migration Project - Simplified Activation
--$
--$ Revision 1.61  2016/04/19 21:35:37  nguada
--$ CR42431
--$
--$ Revision 1.60  2016/04/19 20:37:44  hcampano
--$ CR40993 - 2G Migration Project - Simplified Activation
--$
--$ Revision 1.59  2016/03/23 14:29:46  mmunoz
--$ CR41450 updated procedure get_repl_part_number to add case for UNLOCK
--$
--$ Revision 1.58  2016/03/18 14:07:51  mmunoz
--$ CR41450 Replacing USE_EXCH_TYPE for UNLOCK
--$
--$ Revision 1.57  2016/03/14 15:32:14  mmunoz
--$ CR39592 Unlocking exchange Safelink - 41450
--$
--$ Revision 1.56  2015/10/27 17:12:25  nguada
--$ CR38782 Validate ESN before calling 1052
--$
--$ Revision 1.55  2015/08/12 22:20:31  nguada
--$ overload create_case
--$
--$ Revision 1.54  2015/08/12 21:48:07  nguada
--$ Domain fix added
--$
--$ Revision 1.53  2015/08/04 20:12:14  nguada
--$ Batch ticket added
--$
--$ Revision 1.52  2015/07/27 21:44:07  nguada
--$ 36566	Interactions enhancements
--$
--$ Revision 1.51  2015/07/21 20:16:10  nguada
--$ CR36566  Interactions enhancements
--$
--$ Revision 1.50  2015/06/30 20:13:35  hcampano
--$ CR34349 - New domain type "ALL" for certain cases that need to have both sim and phones returned during the case creation. TAS_2015_13
--$
--$ Revision 1.49  2015/06/30 16:51:29  nguada
--$ 2g 3G fixes to get_repl_part_number
--$
--$ Revision 1.45  2015/06/02 16:37:15  mmunoz
--$ CR32930 : updated function add_case_dtl_records to populate ACTIVATION_DATE
--$
--$ Revision 1.44  2015/05/26 15:30:38  hcampano
--$ Additional fix of code.
--$
--$ Revision 1.43  2015/05/22 20:29:02  hcampano
--$ CODE Review fix
--$
--$ Revision 1.42  2015/05/14 12:14:18  nguada
--$ Address validation bug fix,  moved inside Warehouse Only validation.
--$
--$ Revision 1.41  2015/05/12 17:18:48  nguada
--$ verify_5g_exception merged in from TAS_2015_08.
--$
--$ Revision 1.40  2015/05/05 14:55:54  mmunoz
--$ Merge TAS_2015_08 with TAS_2015_09 and TAS_2015_10
--$
--$ Revision 1.39  2015/04/29 19:31:30  nguada
--$ verify_5g_exception bug fix
--$
--$ Revision 1.38  2015/04/29 17:09:39  nguada
--$ TAS_2015_08 needs merge with 09 and 10
--$
--$ Revision 1.33  2014/12/24 16:00:23  hcampano
--$ Uncommented COMPENSATE_REWARD_POINTS body. for TAS_2015_01 release
--$
--$ Revision 1.32  2014/12/17 16:05:08  hcampano
--$ *** empty log message ***
--$
--$ Revision 1.31  2014/12/17 15:47:00  mmunoz
--$ Case status changes to BadAddress to have part request in status ONHOLD.
--$
--$ Revision 1.30  2014/12/03 18:41:20  nguada
--$ Change type, title for reward points case
--$
--$ Revision 1.29  2014/12/01 19:12:16  hcampano
--$ TAS_2014_11 - Rewards Points
--$
--$ Revision 1.28  2014/11/13 17:38:24  mmunoz
--$ calling function getServPlanGroupType
--$
--$ Revision 1.27  2014/10/24 18:52:09  mmunoz
--$ Change in getWtyExchangeCase
--$
--$ Revision 1.26  2014/10/17 22:01:15  mmunoz
--$ CR 30728 a?? Added logic to check if warranty exchange case already exists
--$
--$ Revision 1.25  2014/09/22 21:45:18  nguada
--$ TAS_2014_09
--$
--$ Revision 1.24  2014/08/28 15:02:19  nguada
--$ Bug fix on units transfer function
--$
--$ Revision 1.23  2014/08/27 19:23:52  hcampano
--$ Fixed defect. TAS_2014_07
--$
--$ Revision 1.22  2014/08/26 21:05:57  nguada
--$ Skip units update if unlimited
--$
--$ Revision 1.19  2014/08/07 17:00:53  mmunoz
--$ updated get_esn_info
--$
--$ Revision 1.18  2014/08/07 16:51:08  mmunoz
--$ changes in cursor get_esn_info
--$
--$ Revision 1.17  2014/08/05 21:37:37  mmunoz
--$ Changes in cursor get_esn_info
--$
--$ Revision 1.16  2014/08/01 15:56:40  mmunoz
--$ updated function isWtyExchangeEligible
--$
--$ Revision 1.15  2014/07/31 20:13:42  mmunoz
--$ updated isWtyExchangeEligible
--$
--$ Revision 1.14  2014/07/31 17:19:32  mmunoz
--$ update function isWtyExchangeEligible
--$
--$ Revision 1.13  2014/07/31 15:32:59  mmunoz
--$ updated function isWtyExchangeEligible
--$
--$ Revision 1.12  2014/07/31 15:02:35  mmunoz
--$ added function isWtyExchangeEligible
--$
--$ Revision 1.11  2014/07/18 20:37:46  mmunoz
--$ CR29798 Warranty Rules for Defective Exchange Cases
--$
--$ Revision 1.10  2014/07/10 20:44:55  mmunoz
--$ removed function merge_case_dtl_record
--$
--$ Revision 1.9  2014/07/09 14:16:20  mmunoz
--$ added function merge_case_dtl_record
--$
--$ Revision 1.8  2014/06/30 14:45:42  mmunoz
--$ update the line regardless of the x_status when objid is provided
--$
--$ Revision 1.7  2014/06/12 21:58:06  mmunoz
--$ added updateShippingAddress
--$
--$ Revision 1.6  2014/06/12 21:06:33  mmunoz
--$ Added first name and last name in create case
--$
--$ Revision 1.5  2014/06/11 14:01:44  mmunoz
--$ Added part_request_objid in batch_update
--$
--$ Revision 1.4  2014/04/16 21:05:34  hcampano
--$ CR27873 - Display Correct Exchange Options for Exchange Cases. changed package to show results regardless of lhs menu setting
--$
--$ Revision 1.3  2014/04/01 20:36:55  hcampano
--$ CR27873 - Display Correct Exchange Options for Exchange Cases
--$
--$ Revision 1.2  2014/02/27 21:18:53  hcampano
--$ CR27644 - New batch reopen to exeption (TAS)
--$
--$ Revision 1.1  2013/12/06 19:55:04  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------
  CURSOR get_part_inst (
    ip_esn  in  varchar2
  ) IS
    SELECT pi.objid,
           pi.part_serial_no,
           pi.x_part_inst_status,
           pn.part_number,
           pi.x_part_inst2site_part,
           pi.x_part_inst2contact,
           pn.part_num2bus_org,
           pn.part_num2part_class,
           pc.name part_class_name,
           --phone age is based on the initial activation date or the first activation after the phone was refurbished
           trunc(sysdate - nvl(DECODE(nvl(refurb_yes.is_refurb,0),0,nonrefurb_act_date.init_act_date,refurb_act_date.init_act_date),sysdate)) phone_age,
           (DECODE(nvl(refurb_yes.is_refurb,0)
                    ,0
                    ,nonrefurb_act_date.init_act_date
                    ,refurb_act_date.init_act_date)) initial_activation,
           DECODE(nvl(refurb_yes.is_refurb,0)
                    ,0
                    ,0
                    ,1)  x_refurb_flag,
           sa.get_param_by_name_fun(pc.name,'SUBSIDY_COST') subsidy_cost,  --this returns 'NOT FOUND', if the parameter does not exist
           sa.get_param_by_name_fun(pc.name,'OPERATING_SYSTEM') operating_system
    FROM   sa.TABLE_PART_INST pi,
           sa.TABLE_MOD_LEVEL ml,
           sa.TABLE_PART_NUM pn,
           sa.TABLE_PART_CLASS pc,
           (SELECT x_service_id, COUNT(1) is_refurb
                from table_site_part sp_a
               WHERE sp_a.x_service_id = ip_esn
                 AND sp_a.x_refurb_flag = 1
			group by x_service_id) refurb_yes
            ,(SELECT x_service_id, MIN(install_date) init_act_date
                from table_site_part sp_b
               WHERE sp_b.x_service_id = ip_esn
                 AND sp_b.part_status || '' IN ('Active'
                                               ,'Inactive')
                AND NVL(sp_b.x_refurb_flag
                        ,0) <> 1
			group by x_service_id) refurb_act_date
            ,(SELECT x_service_id, MIN(install_date) init_act_date
                from table_site_part sp_c
               WHERE sp_c.x_service_id = ip_esn
                 AND sp_c.part_status || '' IN ('Active'
                                               ,'Inactive')
			  group by x_service_id) nonrefurb_act_date
    WHERE  pi.part_serial_no = ip_esn
    AND    pi.x_domain = 'PHONES'
    AND    ml.objid = pi.n_part_inst2part_mod
    AND    pn.objid = ml.part_info2part_num
    AND    pc.objid = pn.part_num2part_class
	and    refurb_yes.x_service_id (+) = pi.part_serial_no
	and    refurb_act_date.x_service_id (+) = pi.part_serial_no
	and    nonrefurb_act_date.x_service_id (+) = pi.part_serial_no
    ;

--------------------------------------------------------------------------------
function check_carriersimpref (phone_part_number in varchar2, sim_part_number in varchar2)
return varchar2 as
    --CR49638 Enforce Carriersimpref Validation
    cursor check_carriersimpref (ph_part_number varchar2, sim_part_number varchar2) is
    select
        pn.part_number,
        pn.x_dll
    from
        table_part_num pn,
        carriersimpref csp
    where 1 =1
        and pn.part_number = ph_part_number
        and pn.domain = 'PHONES'
        and pn.x_dll <= csp.max_dll_exch
        and pn.x_dll >= csp.min_dll_exch
        and csp.sim_profile = sim_part_number
    ;
    rec check_carriersimpref%rowtype;
    v_message varchar2(200) := 'Valid';
begin
    if sim_part_number is null
    then
       v_message := 'Missing Part Number';
    else
       open check_carriersimpref(phone_part_number,sim_part_number);
       fetch check_carriersimpref into rec;
       if check_carriersimpref%notfound then
          v_message := 'SIM Exchange profile not valid';
       else
          --CR49600 Block Sprint SIM Exchange
          if rec.x_dll = -29 then
           v_message := 'Transaction cannot be completed at this time. Sprint SIM Exchange';
          end if;
       end if;
       close check_carriersimpref;
    end if;
    --dbms_output.put_line('***  check_carriersimpref : '||v_message||'  phone_part_number: '||phone_part_number||'  sim_part_number: '||sim_part_number);
    return v_message;
end check_carriersimpref;
--------------------------------------------------------------------------------

  function accept_case (case_objid in varchar2,
                               user_objid in varchar2,
                               wipbin_objid in varchar2) return varchar2
  as
    p_error_no varchar2(200);
    p_error_str varchar2(200);
    v_message varchar2(200);
    n_cnt number:=0;
  begin

    select count(*)
    into   n_cnt
    from   table_case ca, table_condition co
    where ca.case_state2condition=co.objid
    and ca.objid = case_objid
    and co.title = 'Open';

    if n_cnt = 1 then
       v_message:= 'Case already accepted by other user';
    else
       apex_crm_pkg.accept_case_to_wipbin(
         p_case_objid => case_objid,
         p_user_objid => user_objid,
         p_wipbin_objid => wipbin_objid,
         p_error_no => p_error_no,
         p_error_str => p_error_str);
         v_message:= p_error_str;
    end if;

    return  v_message;

  end accept_case;
--------------------------------------------------------------------------------
  function add_case_dtl_records (p_case_id in varchar2) return varchar2
  as
    cursor c1 is
    select table_case.objid,table_x_case_conf_dtl.x_field_name
    from sa.table_x_case_conf_hdr,sa.table_x_case_conf_dtl,sa.table_x_mtm_case_hdr_dtl,sa.table_case
    where mtm_conf2conf_dtl=table_x_case_conf_dtl.objid
    and mtm_conf2conf_hdr=table_x_case_conf_hdr.objid
    and table_x_case_conf_hdr.x_case_type =table_case.x_case_type
    and table_x_case_conf_hdr.x_title =table_case.title
    and table_case.id_number = p_case_id
    and not exists (select d2.objid from sa.table_x_case_detail d2 where d2.detail2case=table_case.objid
                    and d2.x_name = table_x_case_conf_dtl.x_field_name);

    v_value varchar2(30);

    function get_install_date(p_case_id varchar2)
    return varchar2
    as
      install_date date;
      n_is_refurb number;
      part_serial_no varchar2(30);

    begin
      select x_esn
      into part_serial_no
      from table_case
      where id_number = p_case_id;

      select count(1)
      into   n_is_refurb
      from   table_site_part sp_a
      where  sp_a.x_service_id = part_serial_no
      and    sp_a.x_refurb_flag = 1;

      if n_is_refurb = 0 then
        select min(install_date)
        into   install_date
        from   sa.table_site_part
        where  x_service_id = part_serial_no
        and    part_status || '' in ('Active','Inactive');
      else
        select min(install_date)
        into   install_date
        from   table_site_part sp_b
        where  sp_b.x_service_id = part_serial_no
        and    sp_b.part_status || '' in ('Active','Inactive')
        and    nvl(sp_b.x_refurb_flag,0) <> 1;
      end if;

      return to_char(install_date,'mm/dd/yyyy');
    exception
      when others then
        return null;
    end get_install_date;

  begin


     for r1 in c1 loop

        if r1.x_field_name= 'ACTIVATION_DATE' then
           v_value := get_install_date(p_case_id);
        else
           v_value := null;
        end if;

        insert into sa.table_x_case_detail (objid,x_name,x_value,detail2case)
        values (sa.seq('x_case_detail'),r1.x_field_name,v_value,r1.objid);

        commit;

     end loop;

     return 'COMPLETED';

  exception
     when others then return sqlerrm;

  end add_case_dtl_records;
--------------------------------------------------------------------------------
  function assign_case (p_user_objid in varchar2,
                               p_login_name in varchar2,
                               p_case_objid in varchar2,
                               p_case_id in varchar2) return varchar2
  as
    v_condition number:=2;
    v_wip_objid number;
    v_out_msg varchar2(200);
    v_note    varchar2(200);
  begin
    if p_case_objid is not null and p_user_objid is not null then
        select user_default2wipbin
        into v_wip_objid
        from table_user
        where objid = p_user_objid;

        update table_condition
         set condition=2,
             wipbin_time= sysdate,
             title='Open',
             s_title = 'OPEN'
         where objid = p_case_objid;

        update table_case
         set case_owner2user=p_user_objid,
             case_wip2wipbin=v_wip_objid,
             case_prevq2queue=null,
             case_currq2queue=null
         where objid = p_case_objid;

         v_note:=p_case_id||' to '||p_login_name||' WIP default';

        insert into table_act_entry
        (objid,act_code,entry_time,addnl_info,proxy,removed,
        focus_type,focus_lowid,entry_name2gbst_elm,act_entry2case,act_entry2user)
        values (sa.seq('act_entry'),10500, sysdate,v_note,'',0,0,0, 268435781, p_case_objid, p_user_objid);

        commit;
        v_out_msg:='Case assigned';
        return v_out_msg;
    else
          v_out_msg:='Missing parameters, case could not be assigned';
          return v_out_msg;
    end if;

  exception
    when others then
      v_out_msg:='ERROR - '||sqlerrm;
      return v_out_msg;
  end assign_case;
--------------------------------------------------------------------------------
  function call_1052 (esn in varchar2,
                             error in varchar2 ,
                             user_objid in varchar2) return varchar2
  as
    result varchar2(4000);
    username varchar2(30);

    cursor c1 is
    select '1'
    from sa.table_part_inst
    where part_serial_no = esn
    and x_domain = 'PHONES';
    r1 c1%rowtype;

  begin
    select login_name
    into username
    from sa.table_user
    where objid = user_objid;

    OPEN c1;
    FETCH c1 INTO r1;
    IF c1%found THEN
      CLOSE c1;
      BEGIN
        sa.apex_fix_errors.call_1052( esn => esn, error => error, ip_user => username, result => result );
        IF result IS NULL THEN
          RETURN 'Please open a System Error case for IT TOSS and specify ''CHECK THE BRAND''.';
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        RETURN SUBSTR('Error on call_1052 (esn:'||esn||',error:'||error||',username:'||username||',result:'||result||', errmsg:'||sqlerrm,0,4000);
      END;
    ELSE
      CLOSE c1;
      result := 'ESN is not found in the System';
    END IF;

    return result;

    exception when others then
       return 'User not found for objid ('||user_objid||')';
  end call_1052;
--------------------------------------------------------------------------------
  function can_accept (case_objid in varchar2,
                              user_objid in varchar2,
                              owner_objid in varchar2,
                              queue_objid in varchar2,
                              condition in varchar2) return varchar2
  as

    n_cnt   number;
    n_user  table_user.objid%type      := user_objid;
    n_queue table_queue.objid%type     := queue_objid;
    v_cond  table_condition.title%type := condition;
    v_result varchar2(10):= 'false';
  begin

    select count(q.title)
    into   n_cnt
    from   table_queue q,
           (select queue2user q_objid
            from   mtm_queue4_user23
            where  user_assigned2queue = n_user
            and    queue2user = n_queue
              union
            select queue_supvr2user q_objid
            from   mtm_queue5_user24
            where  supvr_assigned2queue = n_user
            and    queue_supvr2user = n_queue) mtm
    where   q.objid = mtm.q_objid;

    if (v_cond = 'Open-Dispatch' or
        v_cond = 'Open-Reject' or
        v_cond = 'Open-Forward')
    and (n_cnt >= 1 or owner_objid = user_objid) then
      v_result:= 'true';
    end if;

    return v_result;

  end can_accept;
--------------------------------------------------------------------------------
  function case_forward (case_objid in varchar2,
                                user_objid in varchar2,
                                queue_objid in varchar2,
                                queue_title in varchar2,
                                reason in varchar2) return varchar2
  as

    cursor c2
    is
      select title
      from table_queue
      where objid in
        (select case_currq2queue from table_case where objid = case_objid
        );
    r2 c2%rowtype;

    v_add_info varchar2(200);
    p_error_no varchar2(200);
    p_error_str varchar2(200);
    v_message varchar2(200):='Case Forwarded';
  begin

    if case_objid is not null and queue_objid is not null then
      open c2;
      fetch c2 into r2;
      close c2;

      v_add_info:='from Queue '||r2.title||' to Queue '||queue_title;

      update table_condition
      set condition=34,
        title      ='Open-Forward',
        s_title    = 'OPEN-FORWARD'
      where objid = (select case_state2condition from table_case where objid = case_objid);

      update table_case set case_currq2queue = queue_objid
      where objid =case_objid ;

      insert
      into table_act_entry
        (
          objid,
          act_code,
          entry_time,
          addnl_info,
          proxy,
          removed,
          focus_type,
          focus_lowid,
          entry_name2gbst_elm,
          act_entry2case,
          act_entry2user,
          act_entry2reject_msg
        )
        values
        (
          sa.seq('act_entry'),
          1100,
          sysdate-(1/86400) , -- 1 sec less
          v_add_info,
          '',
          0,0,0,268435633,
          case_objid,
          user_objid,
          0
        );

       commit;

       if  reason is not null then
          sa.clarify_case_pkg.log_notes(
          p_case_objid => case_objid,
          p_user_objid => user_objid,
          p_notes => reason,
          p_action_type => 'Forward',
          p_error_no => p_error_no,
          p_error_str => p_error_str );
          v_message := v_message||' '||p_error_str;
       end if;

    end if;

    commit;

    return v_message;

  end case_forward;
--------------------------------------------------------------------------------
  function case_return_to_sender (case_objid in varchar2,
                                         user_objid in varchar2,
                                         reason in varchar2) return varchar2
  as
  -- return to sender
    cursor c1
    is
      select objid,
        title
      from table_wipbin
      where objid =
        (select case_wip2wipbin from table_case where objid = case_objid
        );
    r1 c1%rowtype;
    cursor c2
    is
      select title
      from table_queue
      where objid in
        (select case_currq2queue from table_case where objid = case_objid
        );
    r2 c2%rowtype;

    v_add_info varchar2(200);
    p_error_no varchar2(200);
    p_error_str varchar2(200);
    v_message varchar2(200);
  begin
    if case_objid is not null then
      open c1;
      fetch c1 into r1;
      close c1;
      open c2;
      fetch c2 into r2;
      close c2;

      v_add_info:='from Queue '||r2.title||' to WIP '||r1.title;
      update table_condition
      set condition=18,
        title      ='Open-Reject',
        s_title    = 'OPEN-REJECT'
      where objid = (select case_state2condition from table_case where objid = case_objid);
      update table_case set case_currq2queue = null where objid = case_objid ;
      insert
      into table_act_entry
        (
          objid,
          act_code,
          entry_time,
          addnl_info,
          proxy,
          removed,
          focus_type,
          focus_lowid,
          entry_name2gbst_elm,
          act_entry2case,
          act_entry2user,
          act_entry2reject_msg
        )
        values
        (
          sa.seq('act_entry'),
          2600,
          sysdate-(1/86400) , -- 1 sec less
          v_add_info,
          '',
          0,0,0,268435645,
          case_objid,
          user_objid,
          0
        );

       commit;

       if reason is not null then
          sa.clarify_case_pkg.log_notes(
          p_case_objid => case_objid,
          p_user_objid => user_objid,
          p_notes => reason,
          p_action_type => 'Return to sender',
          p_error_no => p_error_no,
          p_error_str => p_error_str );
          v_message:= p_error_str;
       end if;

    end if;

    return v_message;
  end case_return_to_sender;
--------------------------------------------------------------------------------
  function case_yank (case_objid in varchar2,
                             user_objid in varchar2) return varchar2
  as
    n_new_owner_objid         varchar2(30) := user_objid;
    n_case_objid              varchar2(30) := case_objid;
    v_new_owner_name          varchar2(30);
    n_wipbin_objid            number;
    n_ele_objid               table_gbst_elm.objid%type;
    n_rank                    table_gbst_elm.rank%type;
    v_title                   table_condition.title%type;
    v_s_title                 table_condition.s_title%type;
    n_case_state2condition    table_condition.objid%type;
    v_act_entry_msg           varchar2(300);
    v_out_msg                 varchar2(300);
  begin

     -- YANK DATA
     begin
       select objid,
              rank
       into   n_ele_objid,
              n_rank
       from   table_gbst_elm
       where  s_title = 'YANKED';
    exception when others then
      v_out_msg := 'Unable to obtain the Yank data in table_gbst_elm';
      goto finish_proc;
    end;

    -- IDENTIFY THE NEW OWNER'S WIPBIN
    begin
      select user_default2wipbin,
             login_name
      into   n_wipbin_objid,
             v_new_owner_name
      from   table_user
      where  objid = n_new_owner_objid;

      v_act_entry_msg := 'Yanked by '||v_new_owner_name||' into WIPbin default.';

    exception when others then
      v_out_msg := 'User has no WIPBIN';
      goto finish_proc;
    end;

    -- GET THE CONDITION OBJID
    begin
      select objid,
             title,
             s_title
      into   n_case_state2condition,
             v_title,
             v_s_title
      from   table_condition
      where  objid = (select case_state2condition
                      from   table_case
                      where  objid = n_case_objid);

    exception when others then
      v_out_msg := 'Case has no condition';
      goto finish_proc;
    end;

    -- UPDATE THE WIPBIN TIME IN TABLE_CONDITION
    begin
      update table_condition
      set   condition = 2,
            title = 'Open',
            s_title = 'OPEN',
            wipbin_time = sysdate --to_date(sysdate, 'MM/DD/YYYY HH24:MI:SS')
      where  objid       = n_case_state2condition;

    exception when others then
      v_out_msg := 'Unable to update table_condition';
      goto finish_proc;
    end;

    -- UPDATE TABLE_CASE
    begin
      update table_case
      set    case_owner2user  = n_new_owner_objid,
             case_prevq2queue = null,
             case_currq2queue = null,
             case_wip2wipbin  = n_wipbin_objid
      where objid             = n_case_objid;

    exception when others then
      v_out_msg := 'Unable to update table_case';
      goto finish_proc;
    end;

    -- UPDATE TABLE_ACT_ENTRY
    begin
      insert into table_act_entry
        (objid,
         act_code,
         entry_time,
         addnl_info,
         proxy,
         removed,
         focus_type,
         focus_lowid,
         entry_name2gbst_elm,
         act_entry2case,
         act_entry2user)
      values
        (sa.seq('act_entry'),
         n_rank,
         sysdate,
         v_act_entry_msg,
         '',
         0, -- NO IDEA
         0, -- NO IDEA
         0, -- NO IDEA
         n_ele_objid,
         n_case_objid,
         n_new_owner_objid);

    exception when others then
      v_out_msg := 'Unable to create record in table_act_entry';
      goto finish_proc;
    end;

    <<finish_proc>>
    if v_out_msg is null then
      commit;
      v_out_msg := v_act_entry_msg;
    else
      rollback;
      v_out_msg := 'ERROR - '||v_out_msg;
    end if;
    return v_out_msg;
  exception
    when others then
      v_out_msg := 'ERROR - '||sqlerrm;
      return v_out_msg;
  end case_yank;
--------------------------------------------------------------------------------
  function close_case (p_case_objid varchar2,
                              p_user_objid varchar2,
                              p_resolution varchar2,
                              p_status varchar2,
                              p_notes varchar2) return varchar2
  as
    p_error_no varchar2(200);
    p_error_str varchar2(200);
    v_message varchar2(200);
  begin

    sa.clarify_case_pkg.log_notes(
      p_case_objid => p_case_objid,
      p_user_objid => p_user_objid,
      p_notes => p_notes,
      p_action_type => 'Close',
      p_error_no => p_error_no,
      p_error_str => p_error_str
    );


    sa.clarify_case_pkg.close_case(
      p_case_objid => p_case_objid,
      p_user_objid => p_user_objid,
      p_source => 'APEX_CRM',
      p_resolution => p_resolution,
      p_status => p_status,
      p_error_no => p_error_no,
      p_error_str => p_error_str
    );

    v_message:='Case Closed';
    return v_message;
  exception
     when others then
      v_message := substr('ERROR - '||sqlerrm,1,200);
      return v_message;
  end close_case;
--------------------------------------------------------------------------------
  procedure auto_close_case (
                            p_case_type varchar2,
                            p_case_title varchar2,
                            p_case_objid varchar2,
                            p_user_objid varchar2,
                            p_resolution varchar2,
                            p_status varchar2,
                            p_notes varchar2)
  as
    p_error_no varchar2(200);
    p_error_str varchar2(200);
    v_message varchar2(4000);
    v_auto_close number(1);  --CR53515
    v_warehouse number(1);
  begin
     begin
	   select nvl(auto_close,0), nvl(x_warehouse,0)
	   into v_auto_close, v_warehouse
	   from sa.table_x_case_conf_hdr
	   where x_case_type = p_case_type
	   and x_title = p_case_title;
     exception
	   when others then v_auto_close := 0;
     end;

     --CR52928	Block Shipments to Fraud related addresses
     if v_warehouse = 1 and is_fraud_detected(p_case_objid) = 'true' then
		v_message :=
		close_case(
		  p_case_objid => p_case_objid,
		  p_user_objid => p_user_objid,
		  p_resolution => p_resolution,
		  p_status => 'Fraud',
		  p_notes => 'Closed automatically. Fraud related address'
		  );
     else
	--Tickets that need to be auto close
	--if p_case_type = 'Denied Exchange'
	if v_auto_close = 1
	then
		v_message :=
		close_case(
		  p_case_objid => p_case_objid,
		  p_user_objid => p_user_objid,
		  p_resolution => p_resolution,
		  p_status => p_status,
		  p_notes => p_notes
		  );
        end if;
     end if;

  exception
     when others then
		v_message := substr('ERROR - '||sqlerrm,1,4000);
		dbms_output.put_line('auto_close_case :'||v_message);
  end auto_close_case;
--------------------------------------------------------------------------------
  function close_case_in_bulk(ip_user_name varchar2,
                                     ip_reason varchar2,
                                     ip_case_id_str varchar2)
  return varchar2
  as

    str varchar2(4000) := ip_case_id_str;
    ctr number := 1;
    pos number := 1;
    old_pos number := 0;

    case_id varchar2(255);
    e_objid number;
    user_name varchar2(30);
    user_objid number;
    v_out_msg varchar2(300);

    v_status varchar2(100);
    v_message varchar2(200);
    v_error_no varchar2(200);
    v_error_str varchar2(200);

    v_ttl_cnt pls_integer :=0;
    v_err_cnt pls_integer :=0;

  begin
    if ip_case_id_str is null then
      return 'Nothing Processed. Please select a case id.';
    end if;
    -- ADD A TRAILING COMMA AND IF ONE IS ALREADY IN THE STRING REMOVE IT.
    str := str||',';
    str := replace(str,',,',',');

    select login_name,objid
    into   user_name,user_objid
    from   table_user
    where  s_login_name = upper(ip_user_name);

    while(pos<>0)
    loop
      pos := instr(str,',',1,ctr);
      ctr:= ctr +1;
      if trim(substr(str,old_pos+1,pos-old_pos-1)) is not null then
        case_id := trim(substr(str,old_pos+1,pos-old_pos-1));

        begin
          select elm_objid
          into   e_objid
          from   table_x_qry_case_view
          where  id_number = case_id;

          igate.sp_close_case(p_case_id => case_id,
                              p_user_login_name => user_name,
                              p_source => 'ADF Case Maintenance',
                              p_resolution_code => '',
                              p_status => v_status, -- out
                              p_msg => v_message); -- out

          sa.clarify_case_pkg.log_notes(p_case_objid => e_objid,
                                        p_user_objid => user_objid,
                                        p_notes => ip_reason,
                                        p_action_type => 'Close',
                                        p_error_no => v_error_no,
                                        p_error_str => v_error_str);

          if v_status = 'F' then
            v_err_cnt := v_err_cnt+1;
          end if;
        exception
          when others then
            v_err_cnt := v_err_cnt+1;
        end;
      end if;
      old_pos := pos;
    end loop;

    commit;

    dbms_output.put_line('v_ttl_cnt: '||v_ttl_cnt);
    dbms_output.put_line('v_err_cnt: '||v_err_cnt);

    v_out_msg := '('||to_char(ctr-2)||') Cases processed. ('||to_char((ctr-2)-v_err_cnt)||') Cases Closed.';
    dbms_output.put_line('v_out_msg: '||v_out_msg);
    return v_out_msg;

  end close_case_in_bulk;
--------------------------------------------------------------------------------
  function close_ind_task(ip_task_objid number,
                                 ip_user varchar2) return varchar2
  as
    v_out_msg varchar2(200);

    -- TASK CASES
    cursor c2 (t_objid number) is
    select id_number
    from   table_case c,
           table_x_call_trans ct,
           table_task tt
    where  tt.objid =  t_objid
    and    tt.x_task2x_call_trans = ct.objid
    and    c.x_esn = ct.x_service_id
    and    c.x_min = ct.x_min;

  begin
    -- CLOSE TASK
    sa.apex_crm_pkg.sp_apex_close_action_item(ip_task_objid, -- task objid
                                              0,
                                              ip_user,
                                              v_out_msg);
    commit;

    for r2 in c2(ip_task_objid) -- task objid
    loop
      sa.igate.sp_close_case(p_case_id => r2.id_number,
                             p_user_login_name => ip_user,
                             p_source => 'Action Item Maintenance',
                             p_resolution_code => null,
                             p_status => v_out_msg,
                             p_msg => v_out_msg);
    end loop;
    commit;

    return 'Closed Action Item - '||ip_task_objid;

  exception
    when others then
      return 'ERROR - Problem Closing Task - '||ip_task_objid;
  end close_ind_task;
--------------------------------------------------------------------------------
  function  create_case (p_case_type varchar2,
                                p_case_title varchar2,
                                p_case_status varchar2,
                                p_case_priority varchar2,
                                p_case_source varchar2,
                                p_case_poc varchar2,
                                p_case_issue varchar2,
                                p_contact_objid varchar2,
                                p_first_name varchar2,
                                p_last_name varchar2,
                                p_user_objid varchar2,
                                p_esn varchar2,
                                p_case_part_req varchar2,
                                p_case_notes varchar2)
return varchar2
  as

begin

return create_case (p_case_type => p_case_type,
                    p_case_title => p_case_title,
                    p_case_status => p_case_status,
                    p_case_priority => p_case_priority,
                    p_case_source => p_case_source,
                    p_case_poc => p_case_poc,
                    p_case_issue => p_case_issue,
                    p_contact_objid => p_contact_objid,
                    p_first_name => p_first_name,
                    p_last_name => p_last_name,
                    p_user_objid => p_user_objid,
                    p_esn => p_esn,
                    p_case_part_req => p_case_part_req,
                    p_case_notes => p_case_notes,
                    p_case_details => null);

end;


  function  create_case (p_case_type varchar2,
                                p_case_title varchar2,
                                p_case_status varchar2,
                                p_case_priority varchar2,
                                p_case_source varchar2,
                                p_case_poc varchar2,
                                p_case_issue varchar2,
                                p_contact_objid varchar2,
                                p_first_name varchar2,
                                p_last_name varchar2,
                                p_user_objid varchar2,
                                p_esn varchar2,
                                p_case_part_req varchar2,
                                p_case_notes varchar2,
                                p_case_details varchar2)
  return varchar2
  as
    v_f_name varchar2(30);
    v_l_name varchar2(30);
    v_phone varchar2(20);
    v_email varchar2(80);
    v_addr varchar2(200);
    v_city varchar2(30);
    v_st varchar2(40);
    v_zip varchar2(20);
    v_id_number varchar2(200);
    v_part_req varchar2(400);
    op_case_objid number;
    op_error_no varchar2(200);
    op_error_str varchar2(200);
    op_out_msg varchar2(400);
    v_c_dtl_rslt varchar2(200);
    is_wh_case number;
    w_cnt number;
    v_domain_type varchar2(100);
    ph_part_number varchar2(100);
    isWtyExchEligibleFlag varchar2(100);
    v_5g_exception varchar2(30);

    FUNCTION verify_5g_exception(
        p_esn       IN VARCHAR2,
        p_case_type IN VARCHAR2,
        p_title     IN VARCHAR2 )
      RETURN VARCHAR2
    IS
      P_SERVICE_PLAN_OBJID VARCHAR2(30);
      P_SERVICE_TYPE       VARCHAR2(200);
      P_PROGRAM_TYPE       VARCHAR2(200);
      P_NEXT_CHARGE_DATE DATE;
      P_PROGRAM_UNITS         NUMBER;
      P_PROGRAM_DAYS          NUMBER;
      P_ERROR_NUM             NUMBER;
      P_SERVICE_PLAN_PROPERTY VARCHAR2(30) :='EXCEPTIONS';
      P_SERVICE_PLAN_VALUE    VARCHAR2(30) :='5G EXCEPTION';
      P_return                VARCHAR2(200):='CONTINUE';
    BEGIN
      IF p_case_type = 'Data Issues' AND p_title = 'CDMA 5G Exception' THEN
        sa.PHONE_PKG.GET_PROGRAM_INFO( P_ESN => P_ESN, P_SERVICE_PLAN_OBJID => P_SERVICE_PLAN_OBJID, P_SERVICE_TYPE => P_SERVICE_TYPE, P_PROGRAM_TYPE => P_PROGRAM_TYPE, P_NEXT_CHARGE_DATE => P_NEXT_CHARGE_DATE, P_PROGRAM_UNITS => P_PROGRAM_UNITS, P_PROGRAM_DAYS => P_PROGRAM_DAYS, P_ERROR_NUM => P_ERROR_NUM );
        IF nvl(sa.GET_SERV_PLAN_VALUE(IP_PLAN_OBJID => P_SERVICE_PLAN_OBJID,IP_PROPERTY_NAME => P_SERVICE_PLAN_PROPERTY),'NA') <> P_SERVICE_PLAN_VALUE THEN
          p_return  :='BLOCK';
        END IF;
      END IF;
      RETURN p_return;
    END;

  begin
    isWtyExchEligibleFlag := isWtyExchangeEligible(p_esn,null,p_case_title,p_case_type);
    --Begin CR29798 Warranty Rules for Defective Exchange Cases
    if p_esn is not null and isWtyExchEligibleFlag <> 'true'
    then
       return isWtyExchEligibleFlag;   --procedure stops here ESN is not eligible for Warranty Exchange or case already open
    end if;
    --End CR29798 Warranty Rules for Defective Exchange Cases

    -- Check 5G Exception
    v_5g_exception:=verify_5g_exception(p_esn=>p_esn,p_case_type=>p_case_type,p_title=>p_case_title);
    if v_5g_exception = 'BLOCK' then
       return 'Error: Serial Number does not qualify for 5G Exception Case';
    end if;
    -- End 5G Exception

    -- CASE SHOULD BE CREATED
    -- GET CONTACT ADDRESS


    begin
      select first_name,
             last_name,
             phone,
             e_mail,
             address_1 ||' '||address_2 address,
             city,
             state,
             zipcode
      into   v_f_name,
             v_l_name,
             v_phone,
             v_email,
             v_addr,
             v_city,
             v_st,
             v_zip
      from   sa.table_contact
      where  objid = p_contact_objid;
    exception
      when others then
      -- IF ADD INFO DOESN'T RETURN, CONTINUE
        null;
    end;

    begin
       --validate Sugested address
       if v_zip is not null then
         select x_city
         into v_city
         from table_x_sales_tax
         where x_zipcode = v_zip
         and x_state = v_st
         and rownum<2;
       end if;

    exception
       --null out suggestion if zip and stete don't match
       when others then
       v_st := null;
       v_addr:=null;
       v_city:=null;
       v_zip:=null;
    end;

	-- Create case with the name provided
	if p_first_name is not null
	then
	   v_f_name := p_first_name;
	   v_l_name := p_last_name;
	end if;

    -- GRABBING THE CASE HEADER INFO IF IT'S NOT A WAREHOUSE CASE THEN
    -- IGNORE ANY PART REQUEST
    begin
    select count(x_warehouse) w_cnt, max(pn_domain_type) domain_type
    into   w_cnt, v_domain_type
    from   sa.table_x_case_conf_hdr
    where  1=1
    and    x_warehouse = 1
    and    x_title = p_case_title
    and    x_case_type = p_case_type;

dbms_output.put_line('w_cnt: '||w_cnt||'v_domain_type: '||v_domain_type);
    --CR49600 Block Sprint SIM Exchange
    --CR49638 Enforce Carriersimpref Validation
    if w_cnt > 0 and nvl(v_domain_type,'unknown') = 'SIM CARDS' then
        begin
            select pn.part_number
            into ph_part_number
            FROM   sa.TABLE_PART_INST pi,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_NUM pn
            WHERE  pi.part_serial_no = p_esn
            AND    pi.x_domain = 'PHONES'
            AND    ml.objid = pi.n_part_inst2part_mod
            AND    pn.objid = ml.part_info2part_num;
        exception
            when others then null;
        end;

       op_error_str := check_carriersimpref (ph_part_number, p_case_part_req);
dbms_output.put_line('ph_part_number: '||ph_part_number||'  p_case_part_req: '||p_case_part_req||'  check_carriersimpref : '||op_error_str);
       if op_error_str <> 'Valid' then
           op_error_no := '-210';
           op_error_str := 'Error No: '||op_error_no||' Error Str: '||op_error_str;
           return op_error_str;   --procedure stops here
       end if;
    end if;

	--CHECK CUSTOMER FIRST NAME AND LAST NAME FOR WAREHOUSE CASES
	if w_cnt > 0 and
	   not ( v_f_name is not null and regexp_like(v_f_name,'^[a-zA-Z ]+$') and
			(v_l_name is null or (v_l_name is not null and regexp_like(v_l_name,'^[a-zA-Z ]+$')) )
		    )
	then
	   --Customer first name or last name is invalid
	   return '-101';   --procedure stops here
	end if;

    if w_cnt > 0 then
      v_part_req := p_case_part_req;
    else
      v_part_req := null;
    end if;
    exception
       when others then
       v_part_req :=null;
    end;
    -- CREATE CASE
    begin
      sa.clarify_case_pkg.create_case (P_TITLE => p_case_title,
                                    P_CASE_TYPE => p_case_type,
                                    P_STATUS => p_case_status,
                                    P_PRIORITY => p_case_priority,
                                    P_ISSUE => p_case_issue,
                                    P_SOURCE => p_case_source,
                                    P_POINT_CONTACT => p_case_poc,
                                    P_CREATION_TIME => sysdate,
                                    P_TASK_OBJID => null,
                                    P_CONTACT_OBJID => p_contact_objid,
                                    P_USER_OBJID => p_user_objid,
                                    P_ESN => p_esn,
                                    P_PHONE_NUM => v_phone,
                                    P_FIRST_NAME => v_f_name,
                                    P_LAST_NAME => v_l_name,
                                    P_E_MAIL => v_email,
                                    P_DELIVERY_TYPE => null,
                                    P_ADDRESS => v_addr,
                                    P_CITY => v_city,
                                    P_STATE => v_st,
                                    P_ZIPCODE => v_zip,
                                    P_REPL_UNITS => null,
                                    P_FRAUD_OBJID => null,
                                    P_CASE_DETAIL => null,
                                    P_PART_REQUEST => v_part_req,
                                    P_ID_NUMBER => v_id_number,
                                    P_CASE_OBJID => op_case_objid,
                                    P_ERROR_NO => op_error_no,
                                    P_ERROR_STR => op_error_str);

      -- IF CASE CREATION IS SUCCESS, LOG NOTES AND INSERT CASE DETAILS
      -- IF UNABLE TO LOG NOTES OR DETAILS JUST RETURN THE CASE ID NUMBER
      -- CASE DETAILS IMPLEMENTED DIFF, DUE TO ADF LIMITATION


      if v_id_number is null then
        -- LOG NOTES
        return 'Error No: '||nvl(op_error_no,'')||' Error Str: '||nvl(op_error_str,'');
      else
        begin
          sa.clarify_case_pkg.log_notes (P_CASE_OBJID => op_case_objid,
                                      P_USER_OBJID => p_user_objid,
                                      P_NOTES => p_case_notes,
                                      P_ACTION_TYPE => 'Agent Added Notes : ',
                                      P_ERROR_NO => op_error_no,
                                      P_ERROR_STR => op_error_str);

          v_c_dtl_rslt := add_case_dtl_records(v_id_number);

                  -- CASE DETAILS
          sa.clarify_case_pkg.update_case_dtl(op_case_objid,p_user_objid,p_case_details,op_error_no,op_error_str);

        exception
          when others then
            null;
        end;

		auto_close_case (   p_case_type ,
                            p_case_title ,
                            op_case_objid ,
                            p_user_objid ,
                            null ,
                            'Closed' ,
                            'Closed automatically');

        return v_id_number;
      end if;

    exception
      when others then
        -- IF ANY ERRORS END
        return 'Error while creating case';
    end;

  end create_case;
--------------------------------------------------------------------------------
  function create_case_wo_account (p_case_conf_objid varchar2,
                                          p_case_issue varchar2,
                                          p_source varchar2,
                                          p_first_name varchar2,
                                          p_last_name varchar2,
                                          p_phone varchar2,
                                          p_email varchar2,
                                          p_brand varchar2,
                                          p_user_objid varchar2,
                                          p_case_notes varchar2,
                                          p_case_details varchar2)
  return varchar2
  as
    v_c_objid number;
    v_err_code varchar2(200);
    v_err_msg  varchar2(200);
    v_case_objid varchar2(30);
    v_id_number varchar2(30);
    v_case_status varchar2(30):='Pending';
    v_case_priority varchar2(30):='low';
    v_case_poc varchar2(30);
    v_sourcesystem varchar2(30):='TAS';
    v_zipcode varchar2(10):='33122';
    v_queue varchar2(50);

    cursor contact_cur is
    select * from sa.table_contact
    where s_first_name = upper(trim(p_first_name))
    and s_last_name = upper(trim(p_last_name))
    and phone = upper(trim(p_phone));

    contact_rec contact_cur%rowtype;

    cursor case_conf_cur is
    select * from sa.table_x_case_conf_hdr
    where objid = p_case_conf_objid;

    case_conf_rec case_conf_cur%rowtype;

    cursor case_cur (contact_objid varchar,case_conf_objid varchar2) is
    select c.id_number
    from table_case c,table_x_case_conf_hdr conf,table_condition cond
    where c.case_reporter2contact = contact_objid
    and conf.objid = case_conf_objid
    and c.x_case_type = conf.x_case_type
    and c.title = conf.x_title
    and c.case_state2condition = cond.objid
    and cond.s_title <> 'CLOSED';

    case_rec case_cur%rowtype;


   cursor default_queue_cur is
      select table_queue.title
      from table_x_case_dispatch_conf
            ,table_x_case_conf_hdr
            ,table_queue
       where dispatch2conf_hdr = table_x_case_conf_hdr.objid
       and table_x_case_dispatch_conf.priority2gbst_elm=-1
       and table_x_case_dispatch_conf.status2gbst_elm=-1
       and table_x_case_conf_hdr.objid = p_case_conf_objid
       and table_queue.objid = table_x_case_dispatch_conf.dispatch2queue;

   default_queue_rec default_queue_cur%rowtype;


  begin

    if p_first_name is null or
       p_last_name is null or
       p_phone is null or
       p_email is null then
       return 'Error: Missing Contact Parameters';

    end if;

    open case_conf_cur;
    fetch case_conf_cur into case_conf_rec;
    if case_conf_cur%notfound then
       close case_conf_cur;
       return 'Error: Missing Case Conf Objid';
    end if;
    close case_conf_cur;

    open contact_cur;
    fetch contact_cur into contact_rec;

    if contact_cur%notfound then
      close contact_cur;

      sa.contact_pkg.createcontact_prc(p_esn => null,
                                    p_first_name => p_first_name,
                                    p_last_name => p_last_name,
                                    p_middle_name => null,
                                    p_phone => p_phone,
                                    p_add1 => null,
                                    p_add2 => null,
                                    p_fax => null,
                                    p_city => null,
                                    p_st => null,
                                    p_zip => v_zipcode,
                                    p_email => p_email,
                                    p_email_status => 0,
                                    p_roadside_status => 0,
                                    p_no_name_flag => 0,
                                    p_no_phone_flag => 0,
                                    p_no_address_flag => 1,
                                    p_sourcesystem => v_sourcesystem,
                                    p_brand_name => p_brand,
                                    p_do_not_email => 1,
                                    p_do_not_phone => 1,
                                    p_do_not_mail => 1,
                                    p_do_not_sms => 1,
                                    p_ssn => null,
                                    p_dob => null,
                                    p_do_not_mobile_ads => 1,
                                    p_contact_objid => v_c_objid,
                                    p_err_code => v_err_code,
                                    p_err_msg => v_err_msg);

    else
       close contact_cur;
       v_c_objid:=contact_rec.objid;
    end if;


    open case_cur (v_c_objid,p_case_conf_objid);
    fetch case_cur into case_rec;
    if case_cur%found then
       close case_cur;
       return 'Error: Similar Case Already Open. Id: '||case_rec.id_number;
    end if;
    close case_cur;

    -- CREATE CASE
    sa.clarify_case_pkg.create_case (p_title => case_conf_rec.x_title,
                                    p_case_type => case_conf_rec.x_case_type,
                                    p_status => v_case_status,
                                    p_priority => v_case_priority,
                                    p_issue => p_case_issue,
                                    p_source => p_source,
                                    p_point_contact => v_case_poc,
                                    p_creation_time => sysdate,
                                    p_task_objid => null,
                                    p_contact_objid => v_c_objid,
                                    p_user_objid => p_user_objid,
                                    p_esn => null,
                                    p_phone_num => null,
                                    p_first_name => null,
                                    p_last_name => null,
                                    p_e_mail => null,
                                    p_delivery_type => null,
                                    p_address => null,
                                    p_city => null,
                                    p_state => null,
                                    p_zipcode => null,
                                    p_repl_units => null,
                                    p_fraud_objid => null,
                                    p_case_detail => null,
                                    p_part_request => null,
                                    p_id_number => v_id_number,
                                    p_case_objid => v_case_objid,
                                    p_error_no => v_err_code,
                                    p_error_str => v_err_msg);



      if v_id_number is not null then
        begin
        -- LOG NOTES
        sa.clarify_case_pkg.log_notes (p_case_objid => v_case_objid, p_user_objid => p_user_objid, p_notes => p_case_notes, p_action_type => 'Agent Added Notes : ', p_error_no => v_err_code, p_error_str => v_err_msg);
        -- CASE DETAILS
        sa.clarify_case_pkg.update_case_dtl(v_case_objid,p_user_objid,p_case_details,v_err_code,v_err_msg);
        --DISPATCH

        open default_queue_cur;
        fetch default_queue_cur into default_queue_rec;
        if default_queue_cur%found then
          v_queue := default_queue_rec.title;
        end if;
        close default_queue_cur;
        sa.clarify_case_pkg.dispatch_case ( p_case_objid => v_case_objid ,p_user_objid => p_user_objid ,p_queue_name => v_queue ,p_error_no => v_err_code ,p_error_str => v_err_msg );
        exception  when others then null;
        end;
      else

        return 'Error No: '||v_err_code||' Error Str: '||v_err_msg;

      end if;

    return v_id_number;

  exception
    when others then
      -- IF ANY ERRORS END
      return 'Error while creating case';
  end create_case_wo_account;

  function create_interaction3(p_c_objid number,
                                     p_reason varchar2,
                                     p_detail varchar2,
                                     p_notes varchar2,
                                     p_rslt varchar2,
                                     p_user varchar2,
                                     p_esn  varchar2,
                                     p_channel varchar2,
									 p_brand varchar2) return varchar2
  as
    v_reason_1                table_hgbst_elm.title%type;
    v_reason_2                table_hgbst_elm.title%type;
    v_reason_3                table_hgbst_elm.title%type;
    v_call_rslt               table_hgbst_elm.title%type;
    v_c_f_name                varchar2(30);
    v_c_l_name                varchar2(30);
    v_c_phone                 varchar2(20);
    v_c_email                 varchar2(80);
    v_c_zip                   varchar2(20);
    n_user_objid              number;
    v_user_name               varchar2(30);
    n_tab_phone_log_objid     number;         -- table_phone_log objid
    n_tab_interact_objid      number;         -- table_interact objid
    n_interaction_id          number;         -- interaction id
    n_tab_interact_txt_objid  number;         -- table_interact_txt objid
    v_datadump                varchar2(4000); -- info we don't need
	v_type                    VARCHAR2(50); -- this column is used to hold BRAND

  begin
    ---------------------------------
    -- INITIALZE VARIABLES
    ---------------------------------

    v_reason_1:=p_reason;
    v_reason_2:=p_detail;
	v_reason_3:=p_channel;
    v_call_rslt:=p_rslt;
	v_type := NVL(p_brand,'Letter');
    ---------------------------------
    -- GET CONTACT and AGENT INFORMATION
    ---------------------------------
    begin
      select first_name,
             last_name,
             phone,
             e_mail,
             zipcode
      into   v_c_f_name,
             v_c_l_name,
             v_c_phone,
             v_c_email,
             v_c_zip
      from   table_contact
      where  1=1
      and    objid = p_c_objid;

    exception
      when others then
          null; --CR44443
        --return 'ERROR - Not able to obtain the contact or agent information';
    end;

    begin
      select objid,
             login_name
      into   n_user_objid,
             v_user_name
      from   table_user
      where  s_login_name = upper(p_user);

    exception
      when others then
          v_user_name := 'UNKNOWN';
    end;
    ------------------------------------------------------------------------------
    -- CREATE (TABLE_PHONE_LOG and TABLE_INTERACT OBJIDS) AND INTERACTION ID
    ------------------------------------------------------------------------------
    begin
      select obj_num
      into   n_tab_phone_log_objid
      from   adp_tbl_oid
      where  type_id = 28;

      select obj_num
      into   n_tab_interact_objid
      from   adp_tbl_oid
      where  type_id = 5225;

      sa.next_id('Interaction ID',n_interaction_id,v_datadump);

      select obj_num
      into   n_tab_interact_txt_objid
      from   adp_tbl_oid
      where  type_id = 5226;
    exception
      when others then
        return 'ERROR - Not able to create the required objid or the interaction_id';
    end;

    ------------------------------------------------------------------------------
    -- CREATE PHONE LOG
    ------------------------------------------------------------------------------
    begin
      insert into table_phone_log
        (objid,
         creation_time,
         stop_time,
         notes,
         site_time,
         internal,
         commitment,
         due_date,
         action_type,
         phone_custmr2contact,
         phone_owner2user,
         old_phone_stat2gbst_elm,
         new_phone_stat2gbst_elm)
      values
        (n_tab_phone_log_objid,
         sysdate, --d_start_time,
         sysdate, --d_end_time,
         p_notes,
         to_date('01-JAN-53 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
         '',
         '',
         to_date('01-JAN-53 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
         'Inbound'||':'||'Letter',
         p_c_objid,
         n_user_objid,
         268435478, -- 268435478 (NO IDEA WHERE THIS VALUE COMES FROM BUT, IT SEEMS LIKE A STATIC VALUE)
         268435478); -- 268435478 (NO IDEA WHERE THIS VALUE COMES FROM BUT, IT SEEMS LIKE A STATIC VALUE)

    exception
      when others then
        return 'ERROR - While inserting phone log - '||sqlerrm;
    end;

    ------------------------------------------------------------------------------
    -- CREATE INTERACTION
    ------------------------------------------------------------------------------
    begin
      insert into table_interact
        (objid,
         interact_id,
         create_date,
         inserted_by,
         external_id,
         direction,
         type,
         s_type,
         origin,
         product,
         s_product,
         reason_1,
         s_reason_1,
         reason_2,
         s_reason_2,
         reason_3,
         s_reason_3,
         result,
         done_in_one,
         fee_based,
         wait_time,
         system_time,
         entered_time,
         pay_option,
         title,
         s_title,
         start_date,
         end_date,
         last_name,
         s_last_name,
         first_name,
         s_first_name,
         phone,
         fax_number,
         email,
         s_email,
         zipcode,
         arch_ind,
         agent,
         s_agent,
         serial_no,
         mobile_phone,
         x_service_type,
         interact2contact,
         interact2user)
      values
        (n_tab_interact_objid,
         n_interaction_id,
         sysdate,
         v_user_name,
         '',
         'Inbound',
         v_type,
         upper(v_type),
         'Customer',
         'None',
         'NONE',
         substr(v_reason_1,1,20),
         substr(upper(v_reason_1),1,20),
         v_reason_2,
         upper(v_reason_2),
         v_reason_3,
         upper(v_reason_3),
         v_call_rslt,
         0,
         0,
         0,
         0,
         0,
         substr(v_reason_1,1,20),
         '',
         '',
         sysdate,
         sysdate,
         v_c_l_name,
         upper(v_c_l_name),
         v_c_f_name,
         upper(v_c_f_name),
         v_c_phone,
         '',
         v_c_email,
         upper(v_c_email),
         v_c_zip,
         0,
         v_user_name,
         UPPER(V_USER_NAME),
         nvl(p_esn,''),
         '',
         'Wireless',
         p_c_objid,
         n_user_objid);

      insert into table_interact_txt
        (objid,
         notes,
         interact_txt2interact)
      values
        (n_tab_interact_txt_objid,
         p_notes,
         n_tab_interact_objid);

    exception
      when others then
        return 'ERROR - Unable to create interaction '||sqlerrm;
    end;

    commit;

    return 'Created Interaction';

  exception
    when others then
      return 'ERROR - Unable to complete create interaction call '||sqlerrm;
  end create_interaction3;


    function create_interaction2(p_c_objid number,
                                     p_reason varchar2,
                                     p_detail varchar2,
                                     p_notes varchar2,
                                     p_rslt varchar2,
                                     p_user varchar2,
                                     p_esn  varchar2) return varchar2
  as
    v_reason_1                table_hgbst_elm.title%type;
    v_reason_2                table_hgbst_elm.title%type;
    v_call_rslt               table_hgbst_elm.title%type;
    v_c_f_name                varchar2(30);
    v_c_l_name                varchar2(30);
    v_c_phone                 varchar2(20);
    v_c_email                 varchar2(80);
    v_c_zip                   varchar2(20);
    n_user_objid              number;
    v_user_name               varchar2(30);
    n_tab_phone_log_objid     number;         -- table_phone_log objid
    n_tab_interact_objid      number;         -- table_interact objid
    n_interaction_id          number;         -- interaction id
    n_tab_interact_txt_objid  number;         -- table_interact_txt objid
    v_datadump                varchar2(4000); -- info we don't need

  begin
    ---------------------------------
    -- INITIALZE VARIABLES
    ---------------------------------

    v_reason_1:=p_reason;
    v_reason_2:=p_detail;
    v_call_rslt:=p_rslt;
    ---------------------------------
    -- GET CONTACT and AGENT INFORMATION
    ---------------------------------
    begin
      select first_name,
             last_name,
             phone,
             e_mail,
             zipcode
      into   v_c_f_name,
             v_c_l_name,
             v_c_phone,
             v_c_email,
             v_c_zip
      from   table_contact
      where  1=1
      and    objid = p_c_objid;

      select objid,
             login_name
      into   n_user_objid,
             v_user_name
      from   table_user
      where  s_login_name = upper(p_user);

    exception
      when others then
		null; --CR44443
        --return 'ERROR - Not able to obtain the contact or agent information';
    end;

    ------------------------------------------------------------------------------
    -- CREATE (TABLE_PHONE_LOG and TABLE_INTERACT OBJIDS) AND INTERACTION ID
    ------------------------------------------------------------------------------
    begin
      select obj_num
      into   n_tab_phone_log_objid
      from   adp_tbl_oid
      where  type_id = 28;

      select obj_num
      into   n_tab_interact_objid
      from   adp_tbl_oid
      where  type_id = 5225;

      sa.next_id('Interaction ID',n_interaction_id,v_datadump);

      select obj_num
      into   n_tab_interact_txt_objid
      from   adp_tbl_oid
      where  type_id = 5226;
    exception
      when others then
        return 'ERROR - Not able to create the required objid or the interaction_id';
    end;

    ------------------------------------------------------------------------------
    -- CREATE PHONE LOG
    ------------------------------------------------------------------------------
    begin
      insert into table_phone_log
        (objid,
         creation_time,
         stop_time,
         notes,
         site_time,
         internal,
         commitment,
         due_date,
         action_type,
         phone_custmr2contact,
         phone_owner2user,
         old_phone_stat2gbst_elm,
         new_phone_stat2gbst_elm)
      values
        (n_tab_phone_log_objid,
         sysdate, --d_start_time,
         sysdate, --d_end_time,
         p_notes,
         to_date('01-JAN-53 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
         '',
         '',
         to_date('01-JAN-53 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
         'Inbound'||':'||'Letter',
         p_c_objid,
         n_user_objid,
         268435478, -- 268435478 (NO IDEA WHERE THIS VALUE COMES FROM BUT, IT SEEMS LIKE A STATIC VALUE)
         268435478); -- 268435478 (NO IDEA WHERE THIS VALUE COMES FROM BUT, IT SEEMS LIKE A STATIC VALUE)

    exception
      when others then
        return 'ERROR - While inserting phone log - '||sqlerrm;
    end;

    ------------------------------------------------------------------------------
    -- CREATE INTERACTION
    ------------------------------------------------------------------------------
    begin
      insert into table_interact
        (objid,
         interact_id,
         create_date,
         inserted_by,
         external_id,
         direction,
         type,
         s_type,
         origin,
         product,
         s_product,
         reason_1,
         s_reason_1,
         reason_2,
         s_reason_2,
         reason_3,
         s_reason_3,
         result,
         done_in_one,
         fee_based,
         wait_time,
         system_time,
         entered_time,
         pay_option,
         title,
         s_title,
         start_date,
         end_date,
         last_name,
         s_last_name,
         first_name,
         s_first_name,
         phone,
         fax_number,
         email,
         s_email,
         zipcode,
         arch_ind,
         agent,
         s_agent,
         serial_no,
         mobile_phone,
         x_service_type,
         interact2contact,
         interact2user)
      values
        (n_tab_interact_objid,
         n_interaction_id,
         sysdate,
         v_user_name,
         '',
         'Inbound',
         'Letter',
         'LETTER',
         'Customer',
         'None',
         'NONE',
         substr(v_reason_1,1,20),
         substr(upper(v_reason_1),1,20),
         v_reason_2,
         upper(v_reason_2),
         '',
         '',
         v_call_rslt,
         0,
         0,
         0,
         0,
         0,
         substr(v_reason_1,1,20),
         '',
         '',
         sysdate,
         sysdate,
         v_c_l_name,
         upper(v_c_l_name),
         v_c_f_name,
         upper(v_c_f_name),
         v_c_phone,
         '',
         v_c_email,
         upper(v_c_email),
         v_c_zip,
         0,
         v_user_name,
         UPPER(V_USER_NAME),
         nvl(p_esn,''),
         '',
         'Wireless',
         p_c_objid,
         n_user_objid);

      insert into table_interact_txt
        (objid,
         notes,
         interact_txt2interact)
      values
        (n_tab_interact_txt_objid,
         p_notes,
         n_tab_interact_objid);

    exception
      when others then
        return 'ERROR - Unable to create interaction '||sqlerrm;
    end;

    commit;

    return 'Created Interaction';

  exception
    when others then
      return 'ERROR - Unable to complete create interaction call '||sqlerrm;
  end create_interaction2;



--------------------------------------------------------------------------------
  function create_interaction(p_c_objid number,
                                     p_reason_objid number,
                                     p_detail_objid number,
                                     p_notes varchar2,
                                     P_RSLT number,
                                     P_USER varchar2,
                                     p_esn  varchar2 )
  return varchar2
  as
    v_reason_1                table_hgbst_elm.title%type;
    v_reason_2                table_hgbst_elm.title%type;
    v_call_rslt               table_hgbst_elm.title%type;
    v_c_f_name                varchar2(30);
    v_c_l_name                varchar2(30);
    v_c_phone                 varchar2(20);
    v_c_email                 varchar2(80);
    v_c_zip                   varchar2(20);
    n_user_objid              number;
    v_user_name               varchar2(30);
    n_tab_phone_log_objid     number;         -- table_phone_log objid
    n_tab_interact_objid      number;         -- table_interact objid
    n_interaction_id          number;         -- interaction id
    n_tab_interact_txt_objid  number;         -- table_interact_txt objid
    v_datadump                varchar2(4000); -- info we don't need

  begin
    ---------------------------------
    -- INITIALZE VARIABLES
    ---------------------------------
    begin
      select title
      into   v_reason_1
      from   table_hgbst_elm
      where  objid = p_reason_objid;

      select title
      into   v_reason_2
      from   table_hgbst_elm
      where  objid = nvl(p_detail_objid,268444636);

      select title
      into   v_call_rslt
      from   table_hgbst_elm
      where  objid = p_rslt;

    exception
      when others then
        return 'ERROR - Not able to initialize reason, detail or call result objid';
    end;

    ---------------------------------
    -- GET CONTACT and AGENT INFORMATION
    ---------------------------------
    begin
      select first_name,
             last_name,
             phone,
             e_mail,
             zipcode
      into   v_c_f_name,
             v_c_l_name,
             v_c_phone,
             v_c_email,
             v_c_zip
      from   table_contact
      where  1=1
      and    objid = p_c_objid;

      select objid,
             login_name
      into   n_user_objid,
             v_user_name
      from   table_user
      where  s_login_name = upper(p_user);

    exception
      when others then
        return 'ERROR - Not able to obtain the contact or agent information';
    end;

    ------------------------------------------------------------------------------
    -- CREATE (TABLE_PHONE_LOG and TABLE_INTERACT OBJIDS) AND INTERACTION ID
    ------------------------------------------------------------------------------
    begin
      select obj_num
      into   n_tab_phone_log_objid
      from   adp_tbl_oid
      where  type_id = 28;

      select obj_num
      into   n_tab_interact_objid
      from   adp_tbl_oid
      where  type_id = 5225;

      sa.next_id('Interaction ID',n_interaction_id,v_datadump);

      select obj_num
      into   n_tab_interact_txt_objid
      from   adp_tbl_oid
      where  type_id = 5226;
    exception
      when others then
        return 'ERROR - Not able to create the required objid or the interaction_id';
    end;

    ------------------------------------------------------------------------------
    -- CREATE PHONE LOG
    ------------------------------------------------------------------------------
    begin
      insert into table_phone_log
        (objid,
         creation_time,
         stop_time,
         notes,
         site_time,
         internal,
         commitment,
         due_date,
         action_type,
         phone_custmr2contact,
         phone_owner2user,
         old_phone_stat2gbst_elm,
         new_phone_stat2gbst_elm)
      values
        (n_tab_phone_log_objid,
         sysdate, --d_start_time,
         sysdate, --d_end_time,
         p_notes,
         to_date('01-JAN-53 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
         '',
         '',
         to_date('01-JAN-53 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
         'Inbound'||':'||'Letter',
         p_c_objid,
         n_user_objid,
         268435478, -- 268435478 (NO IDEA WHERE THIS VALUE COMES FROM BUT, IT SEEMS LIKE A STATIC VALUE)
         268435478); -- 268435478 (NO IDEA WHERE THIS VALUE COMES FROM BUT, IT SEEMS LIKE A STATIC VALUE)

    exception
      when others then
        return 'ERROR - While inserting phone log - '||sqlerrm;
    end;

    ------------------------------------------------------------------------------
    -- CREATE INTERACTION
    ------------------------------------------------------------------------------
    begin
      insert into table_interact
        (objid,
         interact_id,
         create_date,
         inserted_by,
         external_id,
         direction,
         type,
         s_type,
         origin,
         product,
         s_product,
         reason_1,
         s_reason_1,
         reason_2,
         s_reason_2,
         reason_3,
         s_reason_3,
         result,
         done_in_one,
         fee_based,
         wait_time,
         system_time,
         entered_time,
         pay_option,
         title,
         s_title,
         start_date,
         end_date,
         last_name,
         s_last_name,
         first_name,
         s_first_name,
         phone,
         fax_number,
         email,
         s_email,
         zipcode,
         arch_ind,
         agent,
         s_agent,
         serial_no,
         mobile_phone,
         x_service_type,
         interact2contact,
         interact2user)
      values
        (n_tab_interact_objid,
         n_interaction_id,
         sysdate,
         v_user_name,
         '',
         'Inbound',
         'Letter',
         'LETTER',
         'Customer',
         'None',
         'NONE',
         v_reason_1,
         upper(v_reason_1),
         v_reason_2,
         upper(v_reason_2),
         '',
         '',
         v_call_rslt,
         0,
         0,
         0,
         0,
         0,
         v_reason_1,
         '',
         '',
         sysdate,
         sysdate,
         v_c_l_name,
         upper(v_c_l_name),
         v_c_f_name,
         upper(v_c_f_name),
         v_c_phone,
         '',
         v_c_email,
         upper(v_c_email),
         v_c_zip,
         0,
         v_user_name,
         UPPER(V_USER_NAME),
         nvl(p_esn,''),
         '',
         'Wireless',
         p_c_objid,
         n_user_objid);

      insert into table_interact_txt
        (objid,
         notes,
         interact_txt2interact)
      values
        (n_tab_interact_txt_objid,
         p_notes,
         n_tab_interact_objid);

    exception
      when others then
        return 'ERROR - Unable to create interaction '||sqlerrm;
    end;

    return 'Created Interaction';

  exception
    when others then
      return 'ERROR - Unable to complete create interaction call '||sqlerrm;
  end create_interaction;
--------------------------------------------------------------------------------
  function create_sim_case (p_user_objid varchar2,
                                   p_esn varchar2,
                                   p_phone_model varchar2,
                                   p_sim_profile varchar2,
                                   p_contact_objid varchar2,
                                   p_issue varchar2) return varchar2
  as
    v_id_number varchar2(30);  --New Case ID
    v_case_objid varchar2(30); --New Case Objid
    v_technology varchar2(10);
    v_title varchar2(30);
    v_part varchar2(30);
    v_hist varchar2(500);
    v_priority varchar2(30);
    v_error_no varchar2(200);
    v_error_str varchar2(200);
    n_cnt number;
    v_message varchar2(200);
    u_objid number;
  begin
    begin
      u_objid := p_user_objid;
    exception
      when others then
        begin
          select objid
          into   u_objid
          from   table_user
          where  s_login_name = upper(p_user_objid);
        exception
          when others then
            return 'User not found';
        end;
    end;

  if p_issue = '' then
     v_message := 'Select Issue';
     return v_message;
  end if;

  select title
  into v_priority
  from table_gbst_elm
  where gbst_elm2gbst_lst in (select objid from table_gbst_lst
                              where title = 'Response Priority Code')
  and state = 2;

  if p_phone_model <> 'SIM Only' then

     select x_technology,part_number
     into v_technology,v_part
     from table_part_num
     where part_number = p_phone_model;

     --CR49600 Block Sprint SIM Exchange
     --CR49638 Enforce Carriersimpref Validation
     v_message := check_carriersimpref(p_phone_model, p_sim_profile);
     dbms_output.put_line('p_phone_model: '||p_phone_model||'  p_sim_profile: '||p_sim_profile||'  check_carriersimpref : '||v_message);
     if v_message <> 'Valid' then
        return v_message;
     end if;
  end if;

  if p_contact_objid is null then
  v_message := 'ESN has not contact associated, case can not be created';
     return v_message;
  end if;

  if p_issue = '' or p_issue = null then
     v_message := 'Please select the Issue';
     return v_message;
  end if;

  if p_phone_model = '' or p_phone_model=null then
     v_message := 'Please select Phone Model';
     return v_message;
  end if;

  if p_phone_model = 'SIM Only' and (p_sim_profile='' or p_sim_profile = null) then
     v_message := 'Please select SIM Profile';
     return v_message;
  else
     if v_technology = 'GSM' and (p_sim_profile = 'Select SIM'  or p_sim_profile = null or p_sim_profile = '') then
        v_message := 'Please select SIM Profile';
        return v_message;
     end if;
  end if;

  if p_sim_profile = 'SIM Only' then
     v_part:=p_sim_profile;
  else
    if p_sim_profile <>  'Select SIM' then
        v_part:=v_part||'||'||p_sim_profile;
     end if;
  end if;

  if  v_part is not null then
      v_title:= 'Digital Exchange';
  else
      v_title := 'SIM Card Exchange';
  end if;

  begin
    select count(*)
    into   n_cnt
    from   table_extactcase ecase,
           table_contact c
    where  1=1
    and    ecase.contact_objid = c.objid
    and    ecase.x_esn = p_esn
    and    ecase.x_case_type = 'Technology Exchange'
    and    ecase.title in ('Digital Exchange','SIM Card Exchange')
    and    ecase.condition like 'Open%';

    if n_cnt > 0 then
      v_message := 'A Technology Exchange case already exists';
     return v_message;
    end if;
  end;

   v_hist := 'Technology Exchange Case: ' || v_title;
   v_hist := v_hist ||chr(10);
   v_hist := v_hist ||'ESN: '||p_esn;
   v_hist := v_hist ||chr(10);

   if v_title = 'Technology Exchange' then
      v_hist := v_hist || 'Units may need to be tranfer to replacement ESN';
   end if;

   sa.clarify_case_pkg.create_case(
      p_title => v_title,
      p_case_type => 'Technology Exchange',
      p_status => 'Pending',  --'BadAddress',
      p_priority => v_priority,
      p_issue => p_issue,
      p_source => 'APEX',
      p_point_contact => 'APEX',
      p_creation_time => sysdate,
      p_task_objid => 0,
      p_contact_objid => p_contact_objid,
      p_user_objid => u_objid,
      p_esn => p_esn,
      p_phone_num => null,
      p_first_name => null,
      p_last_name => null,
      p_e_mail => null,
      p_delivery_type => null,
      p_address => null,
      p_city => null,
      p_state => null,
      p_zipcode => null,
      p_repl_units => 0,
      p_fraud_objid => 0,
      p_case_detail => null,
      p_part_request => v_part,
      p_id_number => v_id_number,
      p_case_objid => v_case_objid,
      p_error_no => v_error_no,
      p_error_str => v_error_str);

     if v_error_no = '0' then
	    --2014/12/17 Case status changes to BadAddress to have part request in status ONHOLD.
	    sa.clarify_case_pkg.update_status (v_case_objid,u_objid,'BadAddress','',v_error_no,v_error_str);

        sa.clarify_case_pkg.dispatch_case(
          p_case_objid => v_case_objid,
          p_user_objid => u_objid,
          p_queue_name => 'Warehouse Exception',
          p_error_no => v_error_no,
          p_error_str => v_error_str);

          if v_error_no = '0' then
             v_message := 'Case Created: '||v_id_number;
          else
             v_message := 'Dispatch Failed: '||v_error_str;
          end if;
     else
        v_message := 'Case Creation Failed: '||v_error_str;
     end if;

     --CR52928 Block Shipments to Fraud related addresses
     auto_close_case
          ('Technology Exchange' ,
          v_title ,
          v_case_objid ,
          u_objid ,
          null,
          'Closed' ,
          'Closed automatically');

     return v_message;

  exception
    when others then
      v_message := 'Case Creation Failed';
      return v_message;
  end create_sim_case;
--------------------------------------------------------------------------------
  function log_task_note(ip_task_objid number,
                                ip_note_title varchar2,
                                ip_note_detail varchar2,
                                ip_user varchar2)
  return varchar2
  as
    n_objid number;
    u_objid number;
    v_out_msg varchar2(100) := 'Note logged Successfully';
  begin

    begin
      u_objid := ip_user;
    exception
      when others then
        begin
          select objid
          into   u_objid
          from   table_user
          where  s_login_name = upper(ip_user);
        exception
          when others then
            u_objid := null;
        end;
    end;

    if ip_task_objid is null or u_objid is null then
      return 'ERROR - While logging task note - Missing task objid '||ip_task_objid||' or user objid/name '||ip_user;
    end if;

    insert into table_notes_log
     (objid,
      creation_time,
      description,
      commitment,
      due_date,
      task_notes2task,
      notes_owner2user)
    values
      (sa.seq('notes_log'),
      sysdate,
      ip_note_detail,
      ip_note_title,
      sysdate,
      ip_task_objid,
      u_objid) returning objid into n_objid;

    insert into table_act_entry
     (objid,
      act_code,
      entry_time,
      addnl_info,
      removed,
      focus_type,
      focus_lowid,
      entry_name2gbst_elm,
      act_entry2task,
      act_entry2user,
      act_entry2notes_log)
    values
     (sa.seq('act_entry'),
      1700,
      sysdate,
      ip_note_detail,
      0,
      27,
      582335368,
      268435639,
      ip_task_objid,
      u_objid,
      n_objid);

    commit;

    return v_out_msg;

  exception
    when others then
      return 'ERROR - While logging task note - '||sqlerrm;
  end log_task_note;
--------------------------------------------------------------------------------
  function logistics_batch_update (ip_user     varchar2,
                                   ip_rec_type varchar2) return varchar2
  is
    new_status varchar2(30);
    cursor user_cur
    is
      select objid from table_user where s_login_name = upper(ip_user);
    user_rec user_cur%rowtype;
    cursor batch_cur
    is
      select ROWID,REC_TYPE,APP_USER,CASE_ID,ESN,TRACKING_NO,STATUS,NEW_MODEL,FF_CENTER,COURIER,SHIPPING_METHOD,NOTE,CASE_STATUS,ACTION_ITEM_ID,PART_REQUEST_OBJID,CASE_TYPE,CASE_TITLE
      from sa.x_crm_batch_file_temp
      where status = 'PENDING'
      and rec_type = ip_rec_type
      and app_user = ip_user;
    batch_rec batch_cur%rowtype;
    cursor case_cur (case_id varchar2)
    is
      select objid from table_case where id_number = case_id;
    case_rec case_cur%rowtype;

    cursor esn_cur (esn varchar2) is
    select x_part_inst2contact
    from sa.table_part_inst
    where part_serial_no = esn
    and x_domain = 'PHONES'
    and x_part_inst2contact is not null;

    esn_rec esn_cur%rowtype;

    cursor new_status_cur
    is
      select *
      from table_x_code_table
      where x_code_name = 'EXCHANGE'
      and x_code_type   = 'PS';
    new_status_rec new_status_cur%rowtype;

    cursor get_case_part_info (p_pr_objid number, p_id_number varchar2)
    is
    select c.objid case_objid,
           c.x_model, c.x_esn, c.id_number,
           pr.objid part_request_objid,
           pr.x_status part_request_status,
           pr.x_repl_part_num,
           pr.x_part_num_domain
    from table_case c, table_x_part_request pr
    where c.objid = pr.request2case
    and pr.objid = nvl(p_pr_objid,
                       (select max(objid)
                        from   table_x_part_request
                        where request2case in (select objid from table_case where id_number = p_id_number)
                        and x_status in ('PENDING', 'ONHOLD', 'INCOMPLETE')  --CR24971
                        and nvl(x_quantity,1) = 1
                        )
                      )
    ;

    get_case_part_rec get_case_part_info%rowtype;

    cursor get_new_part_info (p_new_part_number varchar2)
    is
    select part_number, domain
    from table_part_num
    where s_part_number = upper(p_new_part_number);

    get_new_part_rec get_new_part_info%rowtype;
    f_counter   number:=0; -- Failures
    c_counter   number:=0; -- Successes
    v_result    varchar2(200);
    v_error_no  varchar2(200);
    v_error_str varchar2(200);
    v_case_objid varchar2(30);
    v_id_number varchar2(30);

    rec_count   number:=0;
  begin
    open user_cur;
    fetch user_cur into user_rec;
    if user_cur%notfound then
      close user_cur;
      return 'Process Failed: Invalid User';
    end if;
    close user_cur;
    for batch_rec in batch_cur
    loop
      if ip_rec_type            = 'PART_REQUEST_UPDATE' then
        new_status             := 'PROCESSED';
        if batch_rec.new_model is null then
          new_status           :='Model Missing';
        end if;
        if batch_rec.ff_center is null then
          new_status           :='FF Missing';
        end if;
        if batch_rec.shipping_method is null then
          new_status                 :='Shipping Method Missing';
        end if;
        if batch_rec.courier is null then
          new_status         :='Courier Missing';
        end if;

        open get_case_part_info(batch_rec.part_request_objid,batch_rec.case_id);
        fetch get_case_part_info into get_case_part_rec;
        close get_case_part_info;

        open get_new_part_info(batch_rec.new_model);
        fetch get_new_part_info into get_new_part_rec;
        if get_new_part_info%NOTFOUND then
           new_status := 'Invalid Part Number';
        end if;
        close get_new_part_info;

        --CR49600 Block Sprint SIM Exchange
        --CR49638 Enforce Carriersimpref
        if get_new_part_rec.domain = 'SIM CARDS' then
          v_result := check_carriersimpref(get_case_part_rec.x_model, get_new_part_rec.part_number);
          if v_result <> 'Valid' then
             new_status         :=v_result;
          end if;
        end if;

        if new_status = 'PROCESSED' then
          update table_x_part_request
          set x_ff_center     = batch_rec.ff_center,
            x_status          = decode(x_status,'INCOMPLETE','PENDING',x_status),
            x_shipping_method = batch_rec.shipping_method,
            x_repl_part_num   = get_new_part_rec.part_number,
            x_courier         = batch_rec.courier,
            x_part_num_domain = get_new_part_rec.domain
          where 1             =1
          and nvl(x_quantity,1) = 1
          and objid = get_case_part_rec.part_request_objid;
        end if;
        if sql%rowcount > 0 then
          --write activity log CR49638 Enforce Carriersimpref
          begin
             sa.adfcrm_internal.write_log(ip_call_id => null,
                                         ip_esn => get_case_part_rec.x_esn,
                                         ip_cust_id => null,
                                         ip_smp => null,
                                         ip_agent => ip_user,
                                         ip_flow_name => 'Part Request Batch Update',
                                         ip_flow_description => 'Part Request Batch Update, Domain:'||get_new_part_rec.domain,
                                         ip_status => 'Success',
                                         ip_permission_name => 'BATCH_PROCESSING_PG',
                                         ip_reason => 'Id number:'||get_case_part_rec.id_number||' New Part Number:'||get_new_part_rec.part_number
                                         );
          end;
          c_counter    := c_counter+1; -- Successes
        else
          f_counter := f_counter+1; -- Failures
        end if;
        update sa.x_crm_batch_file_temp
        set status    = new_status
        where case_id = batch_rec.case_id
        and status    = 'PENDING'
        and rec_type  = 'PART_REQUEST_UPDATE';
      end if;
      if ip_rec_type = 'REFURBISH' then
        sa.sp_clarify_refurb_prc( ip_esn => batch_rec.esn, ip_reset_date => sysdate - 10, ip_order_num => null, ip_user_objid => user_rec.objid, -- IS GLOBAL VARIABLE NOW CAPTURED ON PAGE 1000
        ip_mod_objid => null, ip_bin_objid => null, ip_action_type => 'REFURBISHED', ip_initial_pi_status => '150', ip_caller_program => 'MANUAL REFURB', ip_ship_date => null, op_result => v_result );
        if instr(v_result,'Fail')=0 then
          c_counter             := c_counter+1;
        else
          f_counter := f_counter+1;
        end if;
        update sa.x_crm_batch_file_temp
        set status     = v_result
        where rec_type = 'REFURBISH'
        and app_user   = ip_user
        and status     = 'PENDING'
        and esn        = batch_rec.esn;
      end if;
      if ip_rec_type = 'REOPEN_EXCEPTION' or
         ip_rec_type = 'REOPEN_BADADDRESS'
      then
        update_reopen_whcase_prc(ipv_case_id => batch_rec.case_id,
                                 ipv_user_objid => user_rec.objid, -- IS GLOBAL VARIABLE NOW INIT'D ON PG 1000
                                 ipv_new_status => ip_rec_type,
                                 opv_error_no => v_error_no,
                                 opv_error_str => v_error_str);

        if v_error_no = '0' then
          update sa.x_crm_batch_file_temp
          set status    = 'PROCESSED'
          where case_id = batch_rec.case_id
          and app_user  = ip_user
          and rec_type  = ip_rec_type;
          c_counter    := c_counter+1;
        else
          update sa.x_crm_batch_file_temp
          set status    = v_error_str
          where case_id = batch_rec.case_id
          and app_user  = ip_user
          and rec_type  = ip_rec_type;
          f_counter    := f_counter+1;
        end if;
      end if;
      if ip_rec_type = 'RECEIVED' then
        open case_cur(batch_rec.case_id);
        fetch case_cur into case_rec;
        if case_cur%found then
          sa.clarify_case_pkg.advance_exchange (strcaseobjid => case_rec.objid, stroldesn => batch_rec.esn, struserobjid => user_rec.objid, p_error_no => v_error_no, p_error_str => v_error_str);
        else
          v_error_no  := '1';
          v_error_str := 'Case Not Found';
        end if;
        close case_cur;
        if v_error_no = '0' then
          update sa.x_crm_batch_file_temp
          set status    = 'PROCESSED'
          where case_id = batch_rec.case_id
          and esn       = batch_rec.esn
          and status    = 'PENDING'
          and rec_type  = 'RECEIVED'
          and app_user  = ip_user;
          c_counter    := c_counter+1;
        else
          update sa.x_crm_batch_file_temp
          set status    = v_error_str
          where case_id = batch_rec.case_id
          and esn       = batch_rec.esn
          and status    = 'PENDING'
          and rec_type  = 'RECEIVED'
          and app_user  = ip_user;
          f_counter    := f_counter+1;
        end if;
      end if;
      if ip_rec_type = 'SHIP' then
        open case_cur(batch_rec.case_id);
        fetch case_cur into case_rec;
        if case_cur%found then
          sa.clarify_case_pkg.part_request_ship( strcaseobjid => case_rec.objid, strnewesn => batch_rec.esn, strtracking => batch_rec.tracking_no, struserobjid => user_rec.objid, -- IS GLOBAL NOW INIT'D ON P1000
          p_error_no => v_error_no, p_error_str => v_error_str);
        else
          v_error_no  := '1';
          v_error_str := 'Case Not Found';
        end if;
        if v_error_no = '0' then
          update sa.x_crm_batch_file_temp
          set status    = 'PROCESSED'
          where case_id = batch_rec.case_id
          and esn       = batch_rec.esn
          and status    = 'PENDING'
          and rec_type  = 'SHIP';
          c_counter    := c_counter+1;
        else
          update sa.x_crm_batch_file_temp
          set status    = v_error_str
          where case_id = batch_rec.case_id
          and esn       = batch_rec.esn
          and status    = 'PENDING'
          and rec_type  = 'SHIP';
          f_counter    := f_counter+1;
        end if;
        close case_cur;
      end if;
      if ip_rec_type = 'ESN_STATUS_UPDATE' then
        update table_part_inst
        set x_part_inst_status  = new_status_rec.x_code_number,
          status2x_code_table   = new_status_rec.objid
        where part_serial_no    = batch_rec.esn
        and x_domain            = 'PHONES'
        and x_part_inst_status in ('51','54');
        rec_count              := sql%rowcount ;
        if rec_count            > 0 then
          v_error_str          := 'PROCESSED';
          sa.insert_pi_hist_prc( ip_user_objid => user_rec.objid, ip_min => batch_rec.esn, ip_old_npa => null, ip_old_nxx => null, ip_old_ext => null, ip_reason => 'APEX BATCH UPDATE', ip_out_val => v_error_str);
          c_counter := c_counter+1;
        else
          v_error_str := 'Not Found or Invalid Status';
          f_counter   := f_counter+1;
        end if;
        update sa.x_crm_batch_file_temp
        set status   = v_error_str
        where esn    = batch_rec.esn
        and status   = 'PENDING'
        and rec_type = 'ESN_STATUS_UPDATE';
      end if;
      if ip_rec_type = 'CLOSE_CASE' then
        open case_cur(batch_rec.case_id);
        fetch case_cur into case_rec;
        if case_cur%found then
          sa.clarify_case_pkg.log_notes( p_case_objid => case_rec.objid, p_user_objid => user_rec.objid, p_notes => batch_rec.note, p_action_type => null, p_error_no => v_error_no, p_error_str => v_error_str );
          sa.clarify_case_pkg.close_case( p_case_objid => case_rec.objid, p_user_objid => user_rec.objid, p_source => 'TAS', p_resolution => null, p_status => null, p_error_no => v_error_no, p_error_str => v_error_str );
        else
          v_error_no  := '1';
          v_error_str := 'Case Not Found';
        end if;
        if v_error_no = '0' then
          update sa.x_crm_batch_file_temp
          set status    = 'PROCESSED'
          where case_id = batch_rec.case_id
          and status    = 'PENDING'
          and rec_type  = 'CLOSE_CASE';
          c_counter    := c_counter+1;
        else
          update sa.x_crm_batch_file_temp
          set status    = v_error_str
          where case_id = batch_rec.case_id
          and status    = 'PENDING'
          and rec_type  = 'CLOSE_CASE';
          f_counter    := f_counter+1;
        end if;
        close case_cur;
      end if;
      if ip_rec_type = 'STATUS_UPDATE' then
        open case_cur(batch_rec.case_id);
        fetch case_cur into case_rec;
        if case_cur%found then
          sa.clarify_case_pkg.update_status( p_case_objid => case_rec.objid, p_user_objid => user_rec.objid, p_new_status => batch_rec.case_status, p_status_notes => batch_rec.note, p_error_no => v_error_no, p_error_str => v_error_str );
        else
          v_error_no  := '1';
          v_error_str := 'Case Not Found';
        end if;
        if v_error_no = '0' then
          update sa.x_crm_batch_file_temp
          set status    = 'PROCESSED'
          where case_id = batch_rec.case_id
          and status    = 'PENDING'
          and rec_type  = 'STATUS_UPDATE';
          c_counter    := c_counter+1;
        else
          update sa.x_crm_batch_file_temp
          set status    = v_error_str
          where case_id = batch_rec.case_id
          and status    = 'PENDING'
          and rec_type  = 'STATUS_UPDATE';
          f_counter    := f_counter+1;
        end if;
        close case_cur;
      end if;
      if ip_rec_type = 'LOG_NOTES' then
        open case_cur(batch_rec.case_id);
        fetch case_cur into case_rec;
        if case_cur%found then
          sa.clarify_case_pkg.log_notes( p_case_objid => case_rec.objid, p_user_objid => user_rec.objid, p_notes => batch_rec.note, p_action_type => null, p_error_no => v_error_no, p_error_str => v_error_str );
        else
          v_error_no  := '1';
          v_error_str := 'Case Not Found';
        end if;
        if v_error_no = '0' then
          update sa.x_crm_batch_file_temp
          set status    = 'PROCESSED'
          where case_id = batch_rec.case_id
          and status    = 'PENDING'
          and rec_type  = 'LOG_NOTES';
          c_counter    := c_counter+1;
        else
          update sa.x_crm_batch_file_temp
          set status    = v_error_str
          where case_id = batch_rec.case_id
          and status    = 'PENDING'
          and rec_type  = 'LOG_NOTES';
          f_counter    := f_counter+1;
        end if;
        close case_cur;
      end if;

    if ip_rec_type = 'BATCH_CREATE_TICKET' then
       v_id_number := '';
       open esn_cur(batch_rec.esn);
       fetch esn_cur into esn_rec;
       if esn_cur%found then

            sa.clarify_case_pkg.create_case (P_TITLE => batch_rec.case_title,
                                          P_CASE_TYPE => batch_rec.case_type,
                                          P_STATUS => 'Pending',
                                          P_PRIORITY => 'Low',
                                          P_ISSUE => 'BATCH',
                                          P_SOURCE => 'TAS',
                                          P_POINT_CONTACT => null,
                                          P_CREATION_TIME => sysdate,
                                          P_TASK_OBJID => null,
                                          P_CONTACT_OBJID => esn_rec.x_part_inst2contact,
                                          P_USER_OBJID => user_rec.objid,
                                          P_ESN => batch_rec.esn,
                                          P_PHONE_NUM => null,
                                          P_FIRST_NAME => null,
                                          P_LAST_NAME => null,
                                          P_E_MAIL => null,
                                          P_DELIVERY_TYPE => null,
                                          P_ADDRESS => NULL,
                                          P_CITY => null,
                                          P_STATE => null,
                                          P_ZIPCODE => null,
                                          P_REPL_UNITS => null,
                                          P_FRAUD_OBJID => null,
                                          P_CASE_DETAIL => null,
                                          P_PART_REQUEST => null,
                                          P_ID_NUMBER => v_id_number,
                                          P_CASE_OBJID => v_case_objid,
                                          P_ERROR_NO => v_error_no,
                                          P_ERROR_STR => v_error_str);

             if v_error_no = '0' then

                sa.CLARIFY_CASE_PKG.DISPATCH_CASE(
                  P_CASE_OBJID => v_case_objid,
                  P_USER_OBJID => user_rec.objid,
                  P_QUEUE_NAME => null,
                  P_ERROR_NO => v_error_no,
                  P_ERROR_STR => v_error_str
                );
             end if;

        else
            v_error_no  := '5';
            v_error_str := 'No Contact Found';
        end if;
        close esn_cur;

        if v_error_no = '0' then
          update sa.x_crm_batch_file_temp
          set status    = 'PROCESSED', case_id=v_id_number
          where esn = batch_rec.esn
          and status    = 'PENDING'
          and rec_type  = 'BATCH_CREATE_TICKET';
          c_counter    := c_counter+1;
        else
          update sa.x_crm_batch_file_temp
          set status    = v_error_str, case_id=v_id_number
          where esn = batch_rec.esn
          and status    = 'PENDING'
          and rec_type  = 'BATCH_CREATE_TICKET';
          f_counter    := f_counter+1;
        end if;

    end if;

    end loop;
    commit;
    return ' Updated: '||c_counter||' of '||to_char(c_counter+f_counter);
  end logistics_batch_update;
--------------------------------------------------------------------------------
  function part_request_ship (case_objid in varchar2,
                                     user_objid in varchar2) return varchar2
  as
    cursor pending_pr_cur is
    select * from table_x_part_request
    where request2case = case_objid
    and x_status = 'PENDING';

    missing_tracking boolean:=false;
    missing_serial boolean:=false;

    p_error_no varchar2(1000);
    p_error_str varchar2(1000);
    message varchar2(1000):='Nothing Pending';

  begin

    for pending_pr_rec in pending_pr_cur loop
      if pending_pr_rec.x_tracking_no is null then
         missing_tracking:=true;
      end if;
      if pending_pr_rec.x_part_serial_no is null then
         missing_serial:=true;
      end if;

    end loop;
    commit;

    if missing_tracking then
       message := 'One or More Tracking numbers are missing';
       return message;
    end if;
    if missing_serial then
       message := 'Serial Number is missing from request';
       return message;

    end if;

    for pending_pr_rec in pending_pr_cur loop

      sa.clarify_case_pkg.part_request_ship(
       strcaseobjid => case_objid,
       strnewesn => pending_pr_rec.x_part_serial_no,
       strtracking => pending_pr_rec.x_tracking_no,
       struserobjid => user_objid,
       p_error_no => p_error_no,
       p_error_str => p_error_str);

       message := p_error_str;

    end loop;
    return message;
  end part_request_ship;
--------------------------------------------------------------------------------
  function validate_part_request (p_pr_objid in varchar2,
                                         p_part_number in varchar2,
                                         p_serial_number in varchar2,
                                         p_ff_center in varchar2,
                                         p_courier in varchar2,
                                         p_method in varchar2,
                                         p_tracking in varchar2) return varchar2
  as
    p_error_no varchar2(200);
    p_error_str varchar2(200);
    v_message varchar2(200);
    n_cnt number:=0;
    v_ff_center varchar2(30);
    v_status varchar2(30);
    v_error_no varchar2(200);
    v_error_str varchar2(200);
    v_ff_overwrite number:=0;

    cursor c1 is
    select part_number,domain
    from   table_part_num
    where  part_number = p_part_number;

    r1 c1%rowtype;

    cursor c2 is
    SELECT e.title, c.objid case_objid, c.case_owner2user,
           c.x_model,
           pr.x_status part_request_status,
           pr.x_repl_part_num,
           pr.x_part_num_domain
    FROM table_gbst_elm e, table_case c, table_x_part_request pr
    WHERE e.objid = c.casests2gbst_elm
    and c.objid = pr.request2case
    and pr.objid = p_pr_objid;

    r2 c2%rowtype;


  begin

     --Status of the Case
     open c2;
     fetch c2 into r2;
     if c2%found then
        v_status := r2.title;
     else
        v_status := 'Not Found';
     end if;
     close c2;


     --select count(*)
     --into n_cnt
     --from table_x_part_request
     --where objid = p_pr_objid
     --and x_status in ('PENDING','INCOMPLETE','ONHOLD');

     --if n_cnt = 0 then
     if r2.part_request_status not in ('PENDING','INCOMPLETE','ONHOLD')
     then
        v_message := p_pr_objid||'Status does not allow update';
        return v_message;
     end if;
     v_message := 'Valid';

     open c1;
     fetch c1 into r1;
     if c1%found then
--        if r1.domain = 'SIM CARDS' then
--            v_message := check_carriersimpref(r2.x_model, r2.x_repl_part_num);
--        end if;
--
--        if v_message = 'Valid' then
            update table_x_part_request
            set x_status = 'PENDING',
                x_part_num_domain = r1.domain,
                x_problem = ''
            where objid = p_pr_objid;

            commit;
--        end if;
     end if;
     close c1;

    if v_message = 'Valid' then
     if p_part_number is not null then

         select count(*)
         into n_cnt
         from sa.table_x_ff_center ff,
              sa.mtm_part_num22_x_ff_center2 mtm,
              sa.table_part_num pn,
              sa.table_x_part_request pr
         where pr.objid = p_pr_objid
         and pr.x_ff_center = ff.x_ff_code
         and mtm.ff_center2part_num = ff.objid
         and mtm.part_num2ff_center = pn.objid
         and pn.part_number = p_part_number;

		 select nvl(dev,0)
		 into v_ff_overwrite
		 from sa.table_x_part_request
		 where objid = p_pr_objid;
		 -- using DEV=5 to flag ff overwrite

         if n_cnt=0 and v_ff_overwrite<>5 then

   		    v_message := p_part_number||' not available at selected FF Center';
            update table_x_part_request
            set x_status = 'INCOMPLETE',
                x_problem = v_message
            where objid = p_pr_objid;

            commit;

         else
            v_message := 'SUCCESS';
            if v_status = 'Exception' then
               begin
               sa.CLARIFY_CASE_PKG.UPDATE_STATUS(
                    P_CASE_OBJID => r2.case_objid,
                    P_USER_OBJID => r2.case_owner2user,
                    P_NEW_STATUS => 'Exception Released',
                    P_STATUS_NOTES => 'Part Number Updated',
                    P_ERROR_NO => v_error_no,
                    P_ERROR_STR => v_error_str );
                exception
                   when others then null;
                end;
            end if;

         end if;

         return  v_message;
      else
         v_message := 'Missing Part Number';
         return v_message;
      end if;
     else
        return v_message;
     end if;

  end validate_part_request;
--------------------------------------------------------------------------------
FUNCTION IS_REFURB_ESN
(
  IP_ESN IN VARCHAR2
) RETURN NUMBER AS
   -- 0 False --> New Phone
   -- 1 True --> Refurb Phone
   CURSOR get_refurb_cnt
   IS
   SELECT x_refurb_flag
   FROM table_site_part sp_a
   WHERE sp_a.x_service_id = ip_esn
   AND sp_a.x_refurb_flag = 1;
   get_refurb_cnt_rec get_refurb_cnt%ROWTYPE;

CURSOR get_refurb_150
   IS
   SELECT *
   FROM table_part_inst
   WHERE part_serial_no = ip_esn
   AND x_part_inst_status = '150' ;
   get_refurb_150_rec get_refurb_150%ROWTYPE;

   CURSOR get_refurb_desc
   IS
   select pn.part_number, pn.description
     from table_part_inst pi, table_part_num pn, table_mod_level ml,table_part_class pc
    where pi.n_part_inst2part_mod = ml.objid
      and ml.part_info2part_num=pn.objid
      and pn.part_num2part_class=pc.objid
      and pi.PART_SERIAL_NO = ip_esn
      and UPPER(pn.description) like '%REFURB%' ;
      get_refurb_desc_rec get_refurb_desc  %ROWTYPE;


BEGIN

  open get_refurb_cnt;
  fetch get_refurb_cnt into get_refurb_cnt_rec;
  if get_refurb_cnt%found then
     close get_refurb_cnt;
     return 1;
  else
    close get_refurb_cnt;
  end if;

  open get_refurb_150;
  fetch get_refurb_150 into get_refurb_150_rec;
  if get_refurb_150%found then
     close get_refurb_150;
     return 1;
  else
    close get_refurb_150;
  end if;

  open get_refurb_desc;
  fetch get_refurb_desc into get_refurb_desc_rec;
  if get_refurb_desc%found then
     close get_refurb_desc;
     return 1;
  else
    close get_refurb_desc;
  end if;

  return 0;

END IS_REFURB_ESN;
--------------------------------------------------------------------------------
procedure update_reopen_whcase_prc(ipv_case_id         varchar2,
                                   ipv_user_objid      varchar2,
                                   ipv_new_status      varchar2,
                                   opv_error_no   out  varchar2,
                                   opv_error_str  out  varchar2)
as
  -- FUNCTIONALITY TAKEN FROM ORIGINAL PROCEDURE (update_reopen_whcase_prc)
  c_objid number;
begin

  if ipv_new_status is null or ipv_user_objid is null then
    opv_error_no := 2;
    opv_error_str := 'User objid ('||ipv_user_objid||') and Status ('||ipv_new_status||') is required';
    return;
  end if;

  select objid
  into   c_objid
  from   table_case
  where  id_number = ipv_case_id;

  -- REOPEN THE CASE
  sa.clarify_case_pkg.reopen_case(c_objid,ipv_user_objid,opv_error_no,opv_error_str);

  -- UPDATE THE STATUS (TYPICAL STATUS USED TO REOPEN CASES - 'BadAddress') ('Exception' WAS ADDED FOR THIS RELEASE)
  if opv_error_no = '0' then
    if ipv_new_status = 'REOPEN_EXCEPTION' then
      sa.clarify_case_pkg.update_status (c_objid,ipv_user_objid,'Exception','',opv_error_no,opv_error_str);
    end if;
    if ipv_new_status = 'REOPEN_BADADDRESS' then
      sa.clarify_case_pkg.update_status (c_objid,ipv_user_objid,'BadAddress','',opv_error_no,opv_error_str);
    end if;
  end if;

  opv_error_str := 'Success';

exception
  when no_data_found then
    opv_error_no := '1';
    opv_error_str := 'Case not found';
  when others then
    opv_error_no := '1';
    opv_error_str := sqlerrm;
end update_reopen_whcase_prc;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CR27873 -- START DISPLAY CORRECT EXCHANGE OPTIONS FOR EXCHANGE CASES
--------------------------------------------------------------------------------
  procedure get_hdr_domain(ip_case_type varchar2,
                           ip_case_title varchar2,
                           op_case_hdr_domain out varchar2)
  as
  begin
    execute immediate ' select pn_domain_type from table_x_case_conf_hdr' ||
                      ' where  1=1 '||
                      --' and    x_avail_lhs_menu = ''1'''||
                      ' and    s_x_case_type = upper(:a)'||
                      ' and    s_x_title = upper(:b)'
    into op_case_hdr_domain using ip_case_type,ip_case_title;
  exception
    when others then
      dbms_output.put_line('ERROR CASE DOES NOT HAVE A DOMAIN ASSOCIATION - '||upper(sqlerrm));
  end;
--------------------------------------------------------------------------------
  procedure get_esn_info (ip_esn varchar2,
                          opv_curr_pn out varchar2,
                          opv_device_type out varchar2,
                          opv_bus_org_id out varchar2,
                          opn_bus_org_objid out number)
  as
  begin
      select pn.part_number, sa.get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => 'DEVICE_TYPE'), b.org_id, b.objid
      into   opv_curr_pn, opv_device_type, opv_bus_org_id,opn_bus_org_objid
      from   table_part_inst pi,
             table_mod_level m,
             table_part_num pn,
             table_part_class pc,
             table_bus_org b
      where  pi.n_part_inst2part_mod = m.objid
      and    m.part_info2part_num = pn.objid
      and    pn.part_num2part_class = pc.objid
      and    pn.part_num2bus_org = b.objid
      and    pi.part_serial_no = ip_esn;

      dbms_output.put_line('ESN: '||ip_esn);
      dbms_output.put_line('BUS ORG: '||opv_bus_org_id);
      dbms_output.put_line('PART NUMBER: '||opv_curr_pn);
      dbms_output.put_line('DEVICE TYPE: '||opv_device_type);

    exception
      when others then
        dbms_output.put_line('ERROR OBTAINING ESN INFORMATION - '||upper(sqlerrm));
  end get_esn_info;
--------------------------------------------------------------------------------
  function days_in_use(ip_esn varchar2)
  return number
  as
    n_days number;
  begin
    -- CALCULATE DAYS IN USE
    select nvl((select *
                from (select nvl(trunc(sysdate)-install_date,0) days_in_use
                      from table_site_part
                      where x_service_id = ip_esn
                      and part_status in ('Active','Inactive','CarrierPending')
                      and nvl(x_refurb_flag,0) = 0
                      order by install_date asc)
                 where rownum <2),0) days_in_use
    into n_days
    from dual;

    return n_days;
  end days_in_use;
--------------------------------------------------------------------------------
  function get_air_bill_pn(ip_part_number varchar2)
  return varchar2
  as
    v_ab_pn table_x_class_exch_options.x_airbil_part_number%type;
  begin
    select x_airbil_part_number
    into   v_ab_pn
    from   table_part_num,
           table_x_class_exch_options
    where  part_num2part_class = source2part_class
    and    part_number = ip_part_number
    and    x_airbil_part_number is not null
    and    rownum < 2;

    return v_ab_pn;
  exception
    when others then
      return null;
  end;
--------------------------------------------------------------------------------
   procedure return_nothing(op_recordset out sys_refcursor)
   is
     stmt varchar2(4000);
   begin
     stmt := 'select null inventory_type, null part_number, null technology, null brand, null airbill, null domain from dual where rownum <1';
     open op_recordset for stmt;
   end return_nothing;
--------------------------------------------------------------------------------
  procedure get_sim_replacement_part_org(ip_org_id varchar2,
                                     ip_org_objid number,
                                     ip_part_number Varchar2,
                                     op_recordset out sys_refcursor)
  is
  begin
    open op_recordset for
    -- QUERY FOR BYOP SIM
    select distinct 'SIM >> '||carrier_name inventory_type,
           sim_profile part_number,
           pn.x_technology technology,
           bo.org_id brand,
           null airbill,
           'SIM CARDS' domain
    from   carriersimpref spref,
           table_part_num pn,
           table_part_num simpn,
           table_bus_org bo
    where  pn.x_dll >= spref.min_dll_exch
    and    pn.x_dll <= spref.max_dll_exch
    and    pn.part_number = ip_part_number --:part_number
    and    spref.sim_profile = simpn.part_number
    and    simpn.part_num2bus_org = bo.objid
	and    nvl(pn.x_extd_warranty,1)=1 -- Available for Exchange
    and    pn.x_dll<=0
    and    spref.sim_profile != 'NA'
    union
    -- QUERY FOR GENERIC SIM
    select distinct 'SIM >> '||carrier_name inventory_type,
           sim_profile part_number,
           pn.x_technology technology,
           ip_org_id /*:p_org_id*/ brand,
           null airbill,
           'SIM CARDS' domain
    from   carriersimpref spref,
           table_part_num pn
    where  pn.x_dll >= spref.min_dll_exch
    and    pn.x_dll <= spref.max_dll_exch
    and    pn.part_number = ip_part_number --:part_number
	and    nvl(pn.x_extd_warranty,1)=1 -- Available for Exchange
    and    pn.x_dll > 0
    and    spref.sim_profile != 'NA'
    union
    -- QUERY FOR LTE (CDMA SPRINT PHONES W/SIM CARD)
    select distinct 'SIM >> '||carrier_name inventory_type,
           sim_profile part_number,
           pn.x_technology technology,
           ip_org_id /*:p_org_id*/ brand,
           null airbill,
           'SIM CARDS' domain
    from   carriersimpref spref,
           table_part_num pn,
           table_part_num simpn
    where  pn.x_dll >= spref.min_dll_exch
    and    pn.x_dll <= spref.max_dll_exch
    and    pn.part_number = ip_part_number --:part_number
    and    spref.sim_profile = simpn.part_number
	and    nvl(pn.x_extd_warranty,1)=1 -- Available for Exchange
    and    pn.x_dll<=0
    and    spref.sim_profile != 'NA';

  end;
--------------------------------------------------------------------------------
  procedure get_sim_sql(ip_org_id varchar2,
                        ip_org_objid number,
                        ip_part_number Varchar2,
                        op_recordset out sys_refcursor)
  is
    stmt varchar2(4000);
  begin
    open op_recordset for
    -- QUERY FOR BYOP SIM
    select distinct 'SIM >> '||carrier_name inventory_type,
           sim_profile part_number,
           pn.x_technology technology,
           bo.org_id brand,
           null airbill,
           'SIM CARDS' domain
    from   carriersimpref spref,
           table_part_num pn,
           table_part_num simpn,
           table_bus_org bo
    where  pn.x_dll >= spref.min_dll_exch
    and    pn.x_dll <= spref.max_dll_exch
    and    pn.part_number = ip_part_number
    and    spref.sim_profile = simpn.part_number
    and    simpn.part_num2bus_org = bo.objid
	and    nvl(pn.x_extd_warranty,1)=1 -- Available for Exchange
    and    pn.x_dll<=0
    and    spref.sim_profile != 'NA'
    union
    -- QUERY FOR GENERIC SIM
    select distinct 'SIM >> '||carrier_name inventory_type,
           sim_profile part_number,
           pn.x_technology technology,
           ip_org_id brand,
           null airbill,
           'SIM CARDS' domain
    from   carriersimpref spref,
           table_part_num pn
    where  pn.x_dll >= spref.min_dll_exch
    and    pn.x_dll <= spref.max_dll_exch
    and    pn.part_number = ip_part_number
	and    nvl(pn.x_extd_warranty,1)=1 -- Available for Exchange
    and    pn.x_dll > 0
    and    spref.sim_profile != 'NA'
    union
    -- QUERY FOR LTE (CDMA SPRINT PHONES W/SIM CARD)
    select distinct 'SIM >> '||carrier_name inventory_type,
           sim_profile part_number,
           pn.x_technology technology,
           ip_org_id brand,
           null airbill,
           'SIM CARDS' domain
    from   carriersimpref spref,
           table_part_num pn,
           table_part_num simpn
    where  pn.x_dll >= spref.min_dll_exch
    and    pn.x_dll <= spref.max_dll_exch
    and    pn.part_number = ip_part_number
    and    spref.sim_profile = simpn.part_number
	and    nvl(pn.x_extd_warranty,1)=1 -- Available for Exchange
    and    pn.x_dll<=0
    and    spref.sim_profile != 'NA';

  end;
--------------------------------------------------------------------------------
  procedure get_phone_sql(ip_device_type varchar2,
                          ip_org_id varchar2,
                          ip_org_objid number,
                          ip_part_number Varchar2,
                          ip_esn varchar2,
                          op_recordset out sys_refcursor)
  is
    stmt varchar2(4000);
    n_days_in_use number;
    n_refurb_esn number;
    v_airbill_pn table_x_class_exch_options.x_airbil_part_number%type;
    v_dev_type_sql varchar2(300);
  begin

    n_days_in_use := days_in_use(ip_esn => ip_esn);
    v_airbill_pn := get_air_bill_pn(ip_part_number => ip_part_number);
    n_refurb_esn := sa.adfcrm_case.is_refurb_esn(ip_esn);

    dbms_output.put_line('ORG OBJID: '||ip_org_objid);
    dbms_output.put_line('DAYS IN USE: '||n_days_in_use);
    dbms_output.put_line('REFUB ESN: '||n_refurb_esn);

    if ip_device_type = 'FEATURE_PHONE' or
       ip_device_type = 'SMARTPHONE'
    then
      v_dev_type_sql := ' and    get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => ''DEVICE_TYPE'') in (''FEATURE_PHONE'',''SMARTPHONE'')'||chr(10);
    else
      v_dev_type_sql := ' and    get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => ''DEVICE_TYPE'') = '''||ip_device_type||''''||chr(10);
    end if;

    stmt := ' select distinct ''NEW PHONE'' inventory_type , '||chr(10)||
            '        table_part_num.part_number, '||chr(10)||
            '        table_part_num.x_technology technology, '||chr(10)||
            '        '''||ip_org_id||''' brand, '||chr(10)||
            '        '''||v_airbill_pn||''' airbill, '||chr(10)||
            '        ''PHONES'' domain '||chr(10)||
            ' from   table_part_num, '||chr(10)||
            '        table_x_class_exch_options, '||chr(10)||
            '        table_part_class pc '||chr(10)||
            ' where  1=1 '||chr(10)||
            ' and    table_part_num.part_num2part_class = pc.objid '||chr(10)||
            v_dev_type_sql ||
            ' and    '||n_days_in_use||' < x_days_for_used_part '||chr(10)||
            ' and    table_x_class_exch_options.x_new_part_num = table_part_num.part_number '||chr(10)||
            ' and    table_part_num.part_num2bus_org = '''||ip_org_objid||''' '||chr(10)||
            ' and    '||n_refurb_esn||' = 0  '||chr(10)||
            ' and    table_x_class_exch_options.x_exch_type not in (''RETAILER'',''UNLOCK'')'||chr(10)||
            ' union '||chr(10)||
            ' select distinct ''REFURBISHED PHONE'' inventory_type , '||chr(10)||
            '        table_part_num.part_number, '||chr(10)||
            '        table_part_num.x_technology technology, '||chr(10)||
            '        '''||ip_org_id||''' brand, '||chr(10)||
            '        '''||v_airbill_pn||''' airbill, '||chr(10)||
            '        ''PHONES'' domain '||chr(10)||
            ' from   table_part_num, '||chr(10)||
            '        table_x_class_exch_options, '||chr(10)||
            '        table_part_class pc '||chr(10)||
            ' where  1=1 '||chr(10)||
            ' and    table_part_num.part_num2part_class = pc.objid '||chr(10)||
            v_dev_type_sql ||
            ' and    ('||n_days_in_use||' >= x_days_for_used_part  '||chr(10)||
            ' or     '||n_refurb_esn||' = 1) '||chr(10)||
            ' and    table_x_class_exch_options.x_used_part_num = table_part_num.part_number '||chr(10)||
            ' and    table_part_num.part_num2bus_org = '''||ip_org_objid||''' '||chr(10)||
            ' and    table_x_class_exch_options.x_exch_type not in (''RETAILER'',''UNLOCK'')'||chr(10);

    dbms_output.put_line('STMT: '||stmt);
    open op_recordset for stmt;
  exception
    when others then
      dbms_output.put_line(sqlerrm);
  end;
--------------------------------------------------------------------------------
--CR43561 TAS ? Enhance iPhone HPP Case creation
  procedure get_phone_by_repl_logic_sql(ip_device_type varchar2,
                          ip_org_id varchar2,
                          ip_org_objid number,
                          ip_part_number Varchar2,
                          ip_esn varchar2,
                          ip_repl_logic varchar2,
                          op_recordset out sys_refcursor)
  is
    stmt varchar2(4000);
    n_days_in_use number;
    n_refurb_esn number;
    v_airbill_pn table_x_class_exch_options.x_airbil_part_number%type;
    v_dev_type_sql varchar2(300);
    v_generic_objid number;
  begin

    if ip_repl_logic = 'RETAILER' then
        begin
            select objid into v_generic_objid from sa.table_bus_org where org_id = 'GENERIC';
        exception
            when others then v_generic_objid := -1;
        end;
    else
       v_generic_objid := -1;
    end if;

    n_days_in_use := days_in_use(ip_esn => ip_esn);
    v_airbill_pn := get_air_bill_pn(ip_part_number => ip_part_number);
    n_refurb_esn := sa.adfcrm_case.is_refurb_esn(ip_esn);

    dbms_output.put_line('ORG OBJID: '||ip_org_objid);
    dbms_output.put_line('DAYS IN USE: '||n_days_in_use);
    dbms_output.put_line('REFUB ESN: '||n_refurb_esn);

    if ip_device_type = 'FEATURE_PHONE' or
       ip_device_type = 'SMARTPHONE'
    then
      v_dev_type_sql := ' and    get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => ''DEVICE_TYPE'') in (''FEATURE_PHONE'',''SMARTPHONE'')'||chr(10);
    else
      v_dev_type_sql := ' and    get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => ''DEVICE_TYPE'') = '''||ip_device_type||''''||chr(10);
    end if;

    stmt := ' select distinct ''NEW PHONE'' inventory_type , '||chr(10)||
            '        table_part_num.part_number, '||chr(10)||
            '        table_part_num.x_technology technology, '||chr(10)||
            '        '''||ip_org_id||''' brand, '||chr(10)||
            '        '''||v_airbill_pn||''' airbill, '||chr(10)||
            '        ''PHONES'' domain '||chr(10)||
            ' from   table_part_num, '||chr(10)||
            '        table_x_class_exch_options, '||chr(10)||
            '        table_part_class pc '||chr(10)||
            ' where  1=1 '||chr(10)||
            ' and    table_part_num.part_num2part_class = pc.objid '||chr(10)||
            v_dev_type_sql ||
            ' and    '||n_days_in_use||' < x_days_for_used_part '||chr(10)||
            ' and    table_x_class_exch_options.x_new_part_num = table_part_num.part_number '||chr(10)||
            ' and    table_part_num.part_num2bus_org in ('''||ip_org_objid||''','''||v_generic_objid||''') '||chr(10)||
            ' and    '||n_refurb_esn||' = 0  '||chr(10)||
            ' and    table_x_class_exch_options.x_exch_type='''||ip_repl_logic||''' '||chr(10)||
            ' union '||chr(10)||
            ' select distinct ''REFURBISHED PHONE'' inventory_type , '||chr(10)||
            '        table_part_num.part_number, '||chr(10)||
            '        table_part_num.x_technology technology, '||chr(10)||
            '        '''||ip_org_id||''' brand, '||chr(10)||
            '        '''||v_airbill_pn||''' airbill, '||chr(10)||
            '        ''PHONES'' domain '||chr(10)||
            ' from   table_part_num, '||chr(10)||
            '        table_x_class_exch_options, '||chr(10)||
            '        table_part_class pc '||chr(10)||
            ' where  1=1 '||chr(10)||
            ' and    table_part_num.part_num2part_class = pc.objid '||chr(10)||
            v_dev_type_sql ||
            ' and    ('||n_days_in_use||' >= x_days_for_used_part  '||chr(10)||
            ' or     '||n_refurb_esn||' = 1) '||chr(10)||
            ' and    table_x_class_exch_options.x_used_part_num = table_part_num.part_number '||chr(10)||
            ' and    table_part_num.part_num2bus_org in ('''||ip_org_objid||''','''||v_generic_objid||''') '||chr(10)||
            ' and    table_x_class_exch_options.x_exch_type='''||ip_repl_logic||''' '||chr(10);

    --dbms_output.put_line('STMT: '||stmt);
    open op_recordset for stmt;
  exception
    when others then
      dbms_output.put_line(sqlerrm);
  end;
--------------------------------------------------------------------------------
  procedure get_unlock_phone_sql(ip_device_type varchar2,
                          ip_org_id varchar2,
                          ip_org_objid number,
                          ip_part_number Varchar2,
                          ip_esn varchar2,
                          op_recordset out sys_refcursor)
  is
    stmt varchar2(4000);
    n_days_in_use number;
    n_refurb_esn number;
    v_airbill_pn table_x_class_exch_options.x_airbil_part_number%type;
    v_dev_type_sql varchar2(300);
  begin

    n_days_in_use := days_in_use(ip_esn => ip_esn);
    v_airbill_pn := get_air_bill_pn(ip_part_number => ip_part_number);
    n_refurb_esn := sa.adfcrm_case.is_refurb_esn(ip_esn);

    dbms_output.put_line('ORG OBJID: '||ip_org_objid);
    dbms_output.put_line('DAYS IN USE: '||n_days_in_use);
    dbms_output.put_line('REFUB ESN: '||n_refurb_esn);

    if ip_device_type = 'FEATURE_PHONE' or
       ip_device_type = 'SMARTPHONE'
    then
      v_dev_type_sql := ' and    get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => ''DEVICE_TYPE'') in (''FEATURE_PHONE'',''SMARTPHONE'')'||chr(10);
    else
      v_dev_type_sql := ' and    get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => ''DEVICE_TYPE'') = '''||ip_device_type||''''||chr(10);
    end if;

    stmt := ' select distinct ''NEW PHONE'' inventory_type , '||chr(10)||
            '        table_part_num.part_number, '||chr(10)||
            '        table_part_num.x_technology technology, '||chr(10)||
            '        '''||ip_org_id||''' brand, '||chr(10)||
            '        '''||v_airbill_pn||''' airbill, '||chr(10)||
            '        ''PHONES'' domain '||chr(10)||
            ' from   table_part_num, '||chr(10)||
            '        table_x_class_exch_options, '||chr(10)||
            '        table_part_class pc '||chr(10)||
            ' where  1=1 '||chr(10)||
            ' and    table_part_num.part_num2part_class = pc.objid '||chr(10)||
            v_dev_type_sql ||
            ' and    '||n_days_in_use||' < x_days_for_used_part '||chr(10)||
            ' and    table_x_class_exch_options.x_new_part_num = table_part_num.part_number '||chr(10)||
            ' and    table_part_num.part_num2bus_org = '''||ip_org_objid||''' '||chr(10)||
            ' and    '||n_refurb_esn||' = 0  '||chr(10)||
            ' and    table_x_class_exch_options.x_exch_type=''UNLOCK'''||chr(10)||
            ' union '||chr(10)||
            ' select distinct ''REFURBISHED PHONE'' inventory_type , '||chr(10)||
            '        table_part_num.part_number, '||chr(10)||
            '        table_part_num.x_technology technology, '||chr(10)||
            '        '''||ip_org_id||''' brand, '||chr(10)||
            '        '''||v_airbill_pn||''' airbill, '||chr(10)||
            '        ''PHONES'' domain '||chr(10)||
            ' from   table_part_num, '||chr(10)||
            '        table_x_class_exch_options, '||chr(10)||
            '        table_part_class pc '||chr(10)||
            ' where  1=1 '||chr(10)||
            ' and    table_part_num.part_num2part_class = pc.objid '||chr(10)||
            v_dev_type_sql ||
            ' and    ('||n_days_in_use||' >= x_days_for_used_part  '||chr(10)||
            ' or     '||n_refurb_esn||' = 1) '||chr(10)||
            ' and    table_x_class_exch_options.x_used_part_num = table_part_num.part_number '||chr(10)||
            ' and    table_part_num.part_num2bus_org = '''||ip_org_objid||''' '||chr(10)||
            ' and    table_x_class_exch_options.x_exch_type=''UNLOCK'''||chr(10);

    --dbms_output.put_line('STMT: '||stmt);
    open op_recordset for stmt;
  exception
    when others then
      dbms_output.put_line(sqlerrm);
  end;
--------------------------------------------------------------------------------
  procedure get_all_sql(ip_device_type varchar2,
                          ip_org_id varchar2,
                          ip_org_objid number,
                          ip_part_number varchar2,
                          ip_esn varchar2,
                          op_recordset out sys_refcursor
                          )
  is
    stmt varchar2(4000);
    n_days_in_use number;
    n_refurb_esn number;
    v_airbill_pn table_x_class_exch_options.x_airbil_part_number%type;
    v_dev_type_sql varchar2(300);
  begin

    n_days_in_use := days_in_use(ip_esn => ip_esn);
    v_airbill_pn := get_air_bill_pn(ip_part_number => ip_part_number);
    n_refurb_esn := sa.adfcrm_case.is_refurb_esn(ip_esn);

    dbms_output.put_line('ORG OBJID: '||ip_org_objid);
    dbms_output.put_line('DAYS IN USE: '||n_days_in_use);
    dbms_output.put_line('REFUB ESN: '||n_refurb_esn);

    if ip_device_type = 'FEATURE_PHONE' or
       ip_device_type = 'SMARTPHONE'
    then
      v_dev_type_sql := ' and    get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => ''DEVICE_TYPE'') in (''FEATURE_PHONE'',''SMARTPHONE'')'||chr(10);
    else
      v_dev_type_sql := ' and    get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter => ''DEVICE_TYPE'') = '''||ip_device_type||''''||chr(10);
    end if;

    stmt := ' select distinct ''NEW PHONE'' inventory_type , '||chr(10)||
            '        table_part_num.part_number, '||chr(10)||
            '        table_part_num.x_technology technology, '||chr(10)||
            '        '''||ip_org_id||''' brand, '||chr(10)||
            '        '''||v_airbill_pn||''' airbill, '||chr(10)||
            '        ''PHONES'' domain '||chr(10)||
            ' from   table_part_num, '||chr(10)||
            '        table_x_class_exch_options, '||chr(10)||
            '        table_part_class pc '||chr(10)||
            ' where  1=1 '||chr(10)||
            ' and    table_part_num.part_num2part_class = pc.objid '||chr(10)||
            v_dev_type_sql ||
            ' and    '||n_days_in_use||' < x_days_for_used_part '||chr(10)||
            ' and    table_x_class_exch_options.x_new_part_num = table_part_num.part_number '||chr(10)||
            ' and    table_part_num.part_num2bus_org = '''||ip_org_objid||''' '||chr(10)||
            ' and    '||n_refurb_esn||' = 0  '||chr(10)||
            ' and    table_x_class_exch_options.x_exch_type<>''RETAILER'''||chr(10)||
            ' union '||chr(10)||
            ' select distinct ''REFURBISHED PHONE'' inventory_type , '||chr(10)||
            '        table_part_num.part_number, '||chr(10)||
            '        table_part_num.x_technology technology, '||chr(10)||
            '        '''||ip_org_id||''' brand, '||chr(10)||
            '        '''||v_airbill_pn||''' airbill, '||chr(10)||
            '        ''PHONES'' domain '||chr(10)||
            ' from   table_part_num, '||chr(10)||
            '        table_x_class_exch_options, '||chr(10)||
            '        table_part_class pc '||chr(10)||
            ' where  1=1 '||chr(10)||
            ' and    table_part_num.part_num2part_class = pc.objid '||chr(10)||
            v_dev_type_sql ||
            ' and    ('||n_days_in_use||' >= x_days_for_used_part  '||chr(10)||
            ' or     '||n_refurb_esn||' = 1) '||chr(10)||
            ' and    table_x_class_exch_options.x_used_part_num = table_part_num.part_number '||chr(10)||
            ' and    table_part_num.part_num2bus_org = '''||ip_org_objid||''' '||chr(10)||
            ' and    table_x_class_exch_options.x_exch_type<>''RETAILER'''||chr(10);

    stmt := stmt||' union
  -- QUERY FOR BYOP SIM
  select distinct ''SIM >> ''||carrier_name inventory_type,
         sim_profile part_number,
         simpn.x_technology technology,
         bo.org_id brand,
         null airbill,
         ''SIM CARDS'' domain
  from   carriersimpref spref,
         table_part_num pn,
         table_part_num simpn,
         table_bus_org bo
  where  pn.x_dll >= spref.min_dll_exch
  and    pn.x_dll <= spref.max_dll_exch
  and    pn.part_number = '''||ip_part_number||'''
  and    spref.sim_profile = simpn.part_number
  and    simpn.part_num2bus_org = bo.objid
  and    pn.x_dll<=0
  and    spref.sim_profile != ''NA''
  union
  -- QUERY FOR GENERIC SIM
  select distinct ''SIM >> ''||carrier_name inventory_type,
         sim_profile part_number,
         pn.x_technology technology,
         '''||ip_org_id||''' brand,
         null airbill,
         ''SIM CARDS'' domain
  from   carriersimpref spref,
         table_part_num pn
  where  pn.x_dll >= spref.min_dll_exch
  and    pn.x_dll <= spref.max_dll_exch
  and    pn.part_number = '''||ip_part_number||'''
  and    pn.x_dll > 0
  and    spref.sim_profile != ''NA''
  union
  -- QUERY FOR LTE (CDMA SPRINT PHONES W/SIM CARD)
  select distinct ''SIM >> ''||carrier_name inventory_type,
         sim_profile part_number,
         simpn.x_technology technology,
         '''||ip_org_id||''' brand,
         null airbill,
         ''SIM CARDS'' domain
  from   carriersimpref spref,
         table_part_num pn,
         table_part_num simpn
  where  pn.x_dll >= spref.min_dll_exch
  and    pn.x_dll <= spref.max_dll_exch
  and    pn.part_number = '''||ip_part_number||'''
  and    spref.sim_profile = simpn.part_number
  and    pn.x_dll<=0
  and    spref.sim_profile != ''NA''';
  --  dbms_output.put_line('STMT: '||stmt);
  open op_recordset for stmt;
  exception
    when others then
      dbms_output.put_line(sqlerrm);
  end get_all_sql;
--------------------------------------------------------------------------------
  procedure get_default_exchange_sql(ip_case_conf_hdr in number,
                          ip_repl_logic in varchar2,
                          ip_device_type in varchar2,
                          ip_org_id in varchar2,
                          ip_org_objid in number,
                          ip_part_number in varchar2,
                          ip_esn in varchar2,
                          ip_domain in varchar2,
                          op_recordset out sys_refcursor)
  is
     --CR47983 Assign Part Numbers to Case Types/Titles
    rc sys_refcursor;
    n_days_in_use number;
    n_refurb_esn number;
    v_generic_objid number;
    v_dev_type_sql varchar2(300);
  begin

    n_days_in_use := days_in_use(ip_esn => ip_esn);
    n_refurb_esn := sa.adfcrm_case.is_refurb_esn(ip_esn);
    dbms_output.put_line('ORG OBJID: '||ip_org_objid|| 'ORG ID: '||ip_org_id);
    dbms_output.put_line('DAYS IN USE: '||n_days_in_use);
    dbms_output.put_line('REFUB ESN: '||n_refurb_esn);

    -- ALWAYS COLLECT THE GENERIC BUS ORG
    begin
        select objid into v_generic_objid from sa.table_bus_org where org_id = 'GENERIC';
    exception
        when others then v_generic_objid := -1;
    end;

    if ip_domain is not null and
       ip_repl_logic is not null and
       ip_device_type is not null then
      open op_recordset for
      select distinct 'NEW PHONE' inventory_type ,
              pn.part_number,
              pn.x_technology technology,
              ip_org_id brand,
              x_airbil_part_number airbill,
              ip_domain domain
      from   sa.table_x_case_exch_options exch,
              sa.table_part_num  pn,
              (select pc.pc_objid, pc.part_class, pc.param_value device_type
              from sa.pc_params_view pc
              where param_name = 'DEVICE_TYPE') pc
      where exch.source2conf_hdr = ip_case_conf_hdr
      and  n_days_in_use < nvl(exch.x_days_for_used_part,999999999)
      and    n_refurb_esn = 0
      and   exch.x_new_part_num = pn.part_number
      and   pn.part_num2bus_org in (ip_org_objid,v_generic_objid)
      and    nvl(exch.x_exch_type,'unknown') = ip_repl_logic
      and    pc.pc_objid (+) = pn.part_num2part_class
      and    ((ip_domain = 'PHONES' and ip_device_type in ('FEATURE_PHONE','SMARTPHONE','BYOP') and pc.device_type in ('FEATURE_PHONE','SMARTPHONE','BYOP')) or
              (ip_domain = 'PHONES' and ip_device_type not in ('FEATURE_PHONE','SMARTPHONE','BYOP') and pc.device_type = ip_device_type) or
              (ip_domain <> 'PHONES')
             )
      UNION
      select distinct 'REFURBISHED PHONE' inventory_type ,
              pn.part_number,
              pn.x_technology technology,
              ip_org_id brand,
              x_airbil_part_number airbill,
              ip_domain domain
      from   sa.table_x_case_exch_options exch,
              sa.table_part_num  pn,
              (select pc.pc_objid, pc.part_class, pc.param_value device_type
              from sa.pc_params_view pc
              where param_name = 'DEVICE_TYPE') pc
      where exch.source2conf_hdr = ip_case_conf_hdr
      and  (n_days_in_use >= nvl(exch.x_days_for_used_part,999999999) or n_refurb_esn = 1)
      and   exch.x_new_part_num = pn.part_number
      and   pn.part_num2bus_org in (ip_org_objid,v_generic_objid)
      and    nvl(exch.x_exch_type,'unknown') = ip_repl_logic
      and    pc.pc_objid (+) = pn.part_num2part_class
      and    ((ip_domain = 'PHONES' and ip_device_type in ('FEATURE_PHONE','SMARTPHONE','BYOP') and pc.device_type in ('FEATURE_PHONE','SMARTPHONE','BYOP')) or
              (ip_domain = 'PHONES' and ip_device_type not in ('FEATURE_PHONE','SMARTPHONE','BYOP') and pc.device_type = ip_device_type) or
              (ip_domain <> 'PHONES')
             );
    end if;

  exception
    when others then
      dbms_output.put_line(sqlerrm);
end get_default_exchange_sql;
--------------------------------------------------------------------------------
  function avail_repl_part_num (ip_case_header_domain varchar2,
                                ip_esn Varchar2)
  return tab_replacement_part_num pipelined
  is
     rc sys_refcursor;
     i number := 0;
     v_curr_pn varchar2(30);
     v_device_type varchar2(30);
     v_bus_org_id varchar2(30);
     n_bus_org_objid number;
  begin

    dbms_output.put_line('DOMAIN: '||ip_case_header_domain);

    get_esn_info (ip_esn => ip_esn,
                  opv_curr_pn => v_curr_pn,
                  opv_device_type => v_device_type,
                  opv_bus_org_id => v_bus_org_id,
                  opn_bus_org_objid => n_bus_org_objid);

    if ip_case_header_domain = 'PHONES' then
      get_phone_sql(ip_device_type => v_device_type,
                    ip_org_id => v_bus_org_id,
                    ip_org_objid => n_bus_org_objid,
                    ip_part_number => v_curr_pn,
                    ip_esn => ip_esn,
                    op_recordset => rc);

    elsif ip_case_header_domain = 'SIM CARDS' then
      get_sim_sql(ip_org_id => v_bus_org_id,
                  ip_org_objid => n_bus_org_objid,
                  ip_part_number => v_curr_pn,
                  op_recordset => rc);
    elsif ip_case_header_domain = 'ALL' then
      get_all_sql(ip_device_type => v_device_type,
                  ip_org_id => v_bus_org_id,
                  ip_org_objid => n_bus_org_objid,
                  ip_part_number => v_curr_pn,
                  ip_esn => ip_esn,
                  op_recordset => rc);
    else
      return_nothing(op_recordset => rc);
    end if;

  loop
    fetch rc into replacement_part_num_reslt;
    exit when rc%notfound;
    pipe row(replacement_part_num_reslt);
  end loop;
end avail_repl_part_num;
--------------------------------------------------------------------------------
-- OVERLOADED - PASS CASE TYPE/TILE + ESN
--------------------------------------------------------------------------------
  function avail_repl_part_num (ip_case_type varchar2,
                                ip_case_title varchar2,
                                ip_esn Varchar2)
  return tab_replacement_part_num pipelined
  is
     rc sys_refcursor;
     i number := 0;
     v_curr_pn varchar2(30);
     v_device_type varchar2(30);
     v_bus_org_id varchar2(30);
     n_bus_org_objid number;
     case_hdr   SYS_REFCURSOR;
     v_case_hdr_objid sa.table_x_case_conf_hdr.objid%type;
     v_case_hdr_domain sa.table_x_case_conf_hdr.pn_domain_type%type := 'unknown';
     v_case_hdr_logic  sa.table_x_case_conf_hdr.x_repl_logic%type := 'unknown';
  begin

    --get_hdr_domain(ip_case_type =>ip_case_type,
    --               ip_case_title =>ip_case_title,
    --               op_case_hdr_domain => v_case_hdr_domain);
    open case_hdr for  select objid, nvl(pn_domain_type,'unknown'), nvl(x_repl_logic,'unknown')
                       from   sa.table_x_case_conf_hdr chdr
                       where s_x_title = upper(ip_case_title)
                       and    s_x_case_type = upper(ip_case_type)
                       ;
    fetch case_hdr into v_case_hdr_objid, v_case_hdr_domain, v_case_hdr_logic;
    close case_hdr;

    dbms_output.put_line('CASE TYPE: '||ip_case_type);
    dbms_output.put_line('CASE TITLE: '||ip_case_title);
    dbms_output.put_line('CASE DOMAIN: '||v_case_hdr_domain);

    get_esn_info (ip_esn => ip_esn,
                  opv_curr_pn => v_curr_pn,
                  opv_device_type => v_device_type,
                  opv_bus_org_id => v_bus_org_id,
                  opn_bus_org_objid => n_bus_org_objid);


    --CR47983 Begin
    select count(*)
    into i
    from sa.table_x_case_exch_options
    where source2conf_hdr = v_case_hdr_objid;
    --CR47983 End

    if i > 0 then
    --CR47983 Has default exchange
      get_default_exchange_sql (ip_device_type => v_device_type,
                                ip_org_id => v_bus_org_id,
                                ip_org_objid => n_bus_org_objid,
                                ip_part_number => v_curr_pn,
                                ip_esn => ip_esn,
                                ip_repl_logic => v_case_hdr_logic,
                                ip_domain => v_case_hdr_domain,
                                ip_case_conf_hdr => v_case_hdr_objid,
                                op_recordset => rc);
    elsif v_case_hdr_domain = 'PHONES' then
    --CR47983 No default exchange
      if v_case_hdr_logic in ('UNLOCK','RETAILER') then
        get_phone_by_repl_logic_sql
                      (ip_device_type => v_device_type,
                      ip_org_id => v_bus_org_id,
                      ip_org_objid => n_bus_org_objid,
                      ip_part_number => v_curr_pn,
                      ip_esn => ip_esn,
                      ip_repl_logic => v_case_hdr_logic,
                      op_recordset => rc);
      else
        get_phone_sql(ip_device_type => v_device_type,
                      ip_org_id => v_bus_org_id,
                      ip_org_objid => n_bus_org_objid,
                      ip_part_number => v_curr_pn,
                      ip_esn => ip_esn,
                      op_recordset => rc);
      end if;
    elsif v_case_hdr_domain = 'SIM CARDS' then
    --CR47983 No default exchange and not PHONES
      get_sim_sql(ip_org_id => v_bus_org_id,
                  ip_org_objid => n_bus_org_objid,
                  ip_part_number => v_curr_pn,
                  op_recordset => rc);
    elsif v_case_hdr_domain = 'ALL' then
    --CR47983 No default exchange and not SIM CARDS
      get_all_sql(ip_device_type => v_device_type,
                  ip_org_id => v_bus_org_id,
                  ip_org_objid => n_bus_org_objid,
                  ip_part_number => v_curr_pn,
                  ip_esn => ip_esn,
                  op_recordset => rc);
    else
      return_nothing(op_recordset => rc);
    end if;

    loop
       fetch rc into replacement_part_num_reslt;
       exit when rc%notfound;
       pipe row(replacement_part_num_reslt);
    end loop;

end avail_repl_part_num;

--------------------------------------------------------------------------------
-- CR27873 -- END DISPLAY CORRECT EXCHANGE OPTIONS FOR EXCHANGE CASES
--------------------------------------------------------------------------------

  procedure get_repl_part_number (ip_case_conf_objid in varchar2,
                                         ip_case_type       in varchar2,
                                         ip_title           in varchar2,
                                         ip_esn             in varchar2,
                                         ip_sim             in varchar2,
                                         ip_repl_logic      in out varchar2, -- NULL, NAP_DIGITAL,  DEFECTIVE_PHONE, DEFECTIVE_SIM, GOODWILL
                                         ip_zipcode         in out varchar2,
                                         op_part_number out varchar2,
                                         op_sim_profile out varchar2,
                                         op_sim_suffix out varchar2)
  is
    i                  number := 0;
    n_case_conf_objid  number;
    repl_tech          varchar2(30);
    part_serial_no     varchar2(30);
    msg                varchar2(200);
    pref_parent        varchar2(100);
    pref_carrier_objid number;
    repl_logic         varchar2(50);
    v_curr_tech        varchar2(10);
    v_status           varchar2(10);
    v_model            varchar2(100);
    v_curr_sim_prof    varchar2(30);
    v_curr_min         varchar2(30);
    v_curr_carrier_id  number;
    v_curr_parent_id   number;
    v_curr_zip_code    varchar2(30);
    v1_port            varchar2(30);
    v1_carr_id         number;
    v1_parent_id       number;
    v1_case_conf       number;
    v1_repl_part       varchar2(30);
    v1_repl_sim_prof   varchar2(30);
    v1_repl_units      number;
    v1_repl_days       number;
    v1_issue           varchar2(100);
    v2_port            varchar2(100);
    v2_carr_id         number;
    v2_parent_id       number;
    v2_case_conf       number;
    v2_repl_part       varchar2(30);
    v2_repl_sim_prof   varchar2(30);
    v2_repl_units      number;
    v2_repl_days       number;
    v2_issue           varchar2(100);
    v2_bribe_units     number;
    v_error_num        varchar2(200);
    v_error_msg        varchar2(200);
    v_sp_status        varchar2(50):='Inactive';
    v_pn_domain        varchar2(50);
    v_sim              varchar2(30);
    rc sys_refcursor;
    v_curr_pn varchar2(30);
    v_device_type varchar2(30);
    v_bus_org_id varchar2(30);
    n_bus_org_objid number;
	v_unable_unable_case number:=0;
	v_unable_pref_parent varchar2(50);

    cursor latest_service_cur
    is
      select * from table_site_part
      where x_service_id = ip_esn
      order by install_date desc;

    latest_service_rec latest_service_cur%rowtype;

    cursor case_conf_cur
    is
      select * from table_x_case_conf_hdr where objid = ip_case_conf_objid;

    case_conf_rec case_conf_cur%rowtype;

    cursor case_conf_cur2
    is
      select *
      from table_x_case_conf_hdr
      where x_case_type = ip_case_type
      and x_title       = ip_title;

    case_conf_rec2 case_conf_cur2%rowtype;

    cursor part_num_cur (c_part_num varchar2)
    is
      select * from table_part_num where part_number = c_part_num;

    part_num_rec part_num_cur%rowtype;

  --SL Part Number Selection SQL
  CURSOR sl_part_num_cur
  IS
    SELECT exc.repl_part_number,exc.sim_suffix
    FROM sa.table_x_parent p,
      sa.table_x_carrier_group g,
      sa.table_x_carrier c,
      sa.table_part_inst lpi,
      sa.table_part_inst epi,
      sa.pc_params_view pc,
      sa.table_mod_level ml,
      sa.table_part_num pn,
      sa.adfcrm_safelink_exchange exc,
      sa.table_bus_org bo
    WHERE sa.adfcrm_safelink.get_lid(ip_esn) IS NOT NULL
    AND ip_esn                               = epi.part_serial_no
    AND epi.x_domain                          = 'PHONES'
    AND epi.n_part_inst2part_mod              = ml.objid
    AND ml.part_info2part_num                 = pn.objid
    AND pn.part_num2bus_org                   = bo.objid
    AND pn.part_num2part_class                = pc.PC_OBJID
    AND pc.param_name                         = 'DEVICE_TYPE'
    AND pc.param_value                        = exc.device_type
    AND bo.org_id                             = exc.brand
    AND lpi.part_to_esn2part_inst             = epi.objid
    AND lpi.x_domain                          = 'LINES'
    AND lpi.x_part_inst_status               IN ('13','37','39')
    AND lpi.part_inst2carrier_mkt             = c.objid
    AND c.carrier2carrier_group               = g.objid
    AND g.x_carrier_group2x_parent            = p.objid
    AND p.x_queue_name                        = exc.carrier;

    sl_part_num_rec sl_part_num_cur%rowtype;
  begin
    op_part_number:=null;
    op_sim_profile:=null;
    op_sim_suffix := null;

    if ip_esn is null then
      return;
    end if;

    if ip_case_conf_objid is null and (ip_case_type is null or ip_title is null) and ip_repl_logic is null then
      return;
    end if;

    if instr(ip_repl_logic,'UNABLE') > 0 then
       v_unable_unable_case:=2;
    end if;


    if ip_repl_logic         is not null then -- ADDED THIS BACK IN
      repl_logic             := ip_repl_logic; -- ADDED THIS BACK IN
    elsif ip_case_conf_objid is not null then
      open case_conf_cur;
      fetch case_conf_cur into case_conf_rec;
      if case_conf_cur%found then
        n_case_conf_objid := case_conf_rec.objid;
        repl_logic := case_conf_rec.x_repl_logic;
        v_pn_domain:= case_conf_rec.PN_DOMAIN_TYPE;
      end if;
      close case_conf_cur;
	  if ip_repl_logic is null and case_conf_rec.x_case_type = 'Technology Exchange' and case_conf_rec.x_title = 'Digital Exchange' then
	     v_unable_unable_case:=1;
	  end if;
    else
      open case_conf_cur2;
      fetch case_conf_cur2 into case_conf_rec2;
      if case_conf_cur2%found then
        n_case_conf_objid := case_conf_rec2.objid;
        repl_logic := case_conf_rec2.x_repl_logic;
        v_pn_domain:= case_conf_rec2.PN_DOMAIN_TYPE;
      end if;
      close case_conf_cur2;
	  if ip_repl_logic is null and case_conf_rec.x_case_type = 'Technology Exchange' and case_conf_rec.x_title = 'Digital Exchange' then
	     v_unable_unable_case:=1;
	  end if;
    end if;

        if v_unable_unable_case= 1 then	  -- first pass for unable unable alternative logic
		ip_repl_logic:= 'UNABLE';
    		return;
	end if;

    if v_unable_unable_case=2 then  -- second pass for unable unable alternative logic
		--determine pref carrier
		v_unable_pref_parent:= SUBSTR(ip_repl_logic,instr(ip_repl_logic,'[')+1,instr(ip_repl_logic,']')-instr(ip_repl_logic,'[')-1);
		IF ip_zipcode       IS NULL THEN
		  OPEN latest_service_cur;
		  FETCH latest_service_cur INTO latest_service_rec;
		  IF latest_service_cur%found THEN
			ip_zipcode:=latest_service_rec.x_zipcode;
		  END IF;
		  CLOSE latest_service_cur;
		  IF ip_zipcode   IS NULL THEN
			ip_repl_logic := NULL;
			RETURN;
		  END IF;
		END IF;
		sa.adfcrm_unable_exch_selection(ip_esn => ip_esn, ip_zipcode => ip_zipcode, ip_pref_parent => v_unable_pref_parent, op_repl_part => op_part_number, op_repl_sim_prof => op_sim_profile, op_repl_sim_suffix => op_sim_suffix);
		ip_repl_logic := NULL;
		RETURN;
	END IF;

    if repl_logic is null or repl_logic not in ('MIGRATION','NAP_DIGITAL','DEFECTIVE_PHONE','DEFECTIVE_SIM','GOODWILL','UNLOCK','RETAILER') then --CR41450 including UNLOCK, CR43561 including RETAILER
      return;
    end if;

	if v_pn_domain = 'PHONES' then
    --CR55349 TAS SL Phone Exchange Improvements
    open sl_part_num_cur;
    fetch sl_part_num_cur into sl_part_num_rec;
    if sl_part_num_cur%found then
        op_part_number := sl_part_num_rec.repl_part_number;
		op_sim_suffix := sl_part_num_rec.sim_suffix;
        ip_repl_logic := NULL;
        return;
    end if;
    close sl_part_num_cur;
    end if;

    --CR47983 Begin
    select count(*)
    into i
    from sa.table_x_case_exch_options
    where source2conf_hdr = n_case_conf_objid;

    get_esn_info (ip_esn => ip_esn,
              opv_curr_pn => v_curr_pn,
              opv_device_type => v_device_type,
              opv_bus_org_id => v_bus_org_id,
              opn_bus_org_objid => n_bus_org_objid);

    DBMS_OUTPUT.PUT_LINE(' ip_case_conf_hdr = ' || n_case_conf_objid||
                         ' ip_repl_logic    = ' || coalesce(repl_logic,'unknown')||
                         ' ip_device_type   = ' || v_device_type ||
                         ' ip_org_id        = ' || v_bus_org_id ||
                         ' ip_org_objid     = ' || n_bus_org_objid ||
                         ' ip_part_number   = ' || v_curr_pn ||
                         ' ip_esn           = ' || ip_esn ||
                         ' ip_domain        = ' || v_pn_domain
                          );
    --CR47983 End

    if i > 0 then
      --CR47983 Begin
      get_default_exchange_sql(ip_case_conf_hdr => nvl(case_conf_rec.objid,case_conf_rec2.objid),
                            ip_repl_logic => coalesce(case_conf_rec.x_repl_logic,case_conf_rec2.x_repl_logic,'unknown'),
                            ip_device_type => v_device_type,
                            ip_org_id => v_bus_org_id,
                            ip_org_objid => n_bus_org_objid,
                            ip_part_number => v_curr_pn,
                            ip_esn => ip_esn,
                            ip_domain => nvl(case_conf_rec.pn_domain_type,case_conf_rec2.pn_domain_type),
                            op_recordset => rc);
      fetch rc into replacement_part_num_reslt;
      close rc;
      op_part_number := replacement_part_num_reslt.part_number;
      --CR47983 End
    elsif repl_logic = 'RETAILER' and v_pn_domain = 'PHONES' then --CR43561

        get_phone_by_repl_logic_sql
                      (ip_device_type => v_device_type,
                      ip_org_id => v_bus_org_id,
                      ip_org_objid => n_bus_org_objid,
                      ip_part_number => v_curr_pn,
                      ip_esn => ip_esn,
                      ip_repl_logic => repl_logic,
                      op_recordset => rc);

         fetch rc into replacement_part_num_reslt;
         close rc;
         op_part_number := replacement_part_num_reslt.part_number;

    elsif repl_logic = 'NAP_DIGITAL' then

       open latest_service_cur;
       fetch latest_service_cur into latest_service_rec;
       if latest_service_cur%found then
          if ip_zipcode is null then
             ip_zipcode:=latest_service_rec.x_zipcode;
          end if;
          v_sp_status:=latest_service_rec.part_status;
       end if;
       close latest_service_cur;

       if ip_zipcode is null then
          return;
       end if;

      if v_sp_status <> 'Active' then
          if (v_pn_domain = 'ALL' and instr(ip_title,'SIM') > 0) or v_pn_domain = 'SIM CARDS'  then
               v_sim := null;
          else
               v_sim:= ip_sim;
          end if;
          nap_digital( p_zip => ip_zipcode, p_esn => ip_esn, p_commit => 'N', p_language => 'English', p_sim => v_sim, p_source => 'TAS', p_upg_flag => 'N', p_repl_part => op_part_number, p_repl_tech => repl_tech, p_sim_profile => op_sim_profile, p_part_serial_no => part_serial_no, p_msg => msg, p_pref_parent => pref_parent, p_pref_carrier_objid => pref_carrier_objid );
      else
          if (v_pn_domain = 'ALL' and instr(ip_title,'SIM') > 0) or v_pn_domain = 'SIM CARDS'  then
             repl_logic:='DEFECTIVE_SIM';
          else
             repl_logic:= 'DEFECTIVE_PHONE';
          end if;
          sa.defective_phone_sim_prc( ip_esn => ip_esn, ip_zipcode => ip_zipcode, ip_action => repl_logic, op_curr_tech => v_curr_tech, op_status => v_status, op_model => v_model, op_curr_sim_prof => v_curr_sim_prof, op_curr_min => v_curr_min, op_curr_carrier_id => v_curr_carrier_id, op_curr_parent_id => v_curr_parent_id, op_curr_zip_code => v_curr_zip_code, op1_port => v1_port, op1_carr_id => v1_carr_id, op1_parent_id => v1_parent_id, op1_case_conf => v1_case_conf, op1_repl_part => op_part_number, op1_repl_sim_prof => op_sim_profile, op1_repl_units => v1_repl_units, op1_repl_days => v1_repl_days, op1_issue => v1_issue, op2_port => v2_port, op2_carr_id => v2_carr_id, op2_parent_id => v2_parent_id, op2_case_conf => v2_case_conf, op2_repl_part => v2_repl_part, op2_repl_sim_prof => v2_repl_sim_prof, op2_repl_units => v2_repl_units, op2_repl_days => v2_repl_days, op2_issue => v2_issue, op2_bribe_units => v2_bribe_units, op_error_num => v_error_num, op_error_msg => v_error_msg );
      end if;
    else
      sa.defective_phone_sim_prc( ip_esn => ip_esn, ip_zipcode => ip_zipcode, ip_action => repl_logic, op_curr_tech => v_curr_tech, op_status => v_status, op_model => v_model, op_curr_sim_prof => v_curr_sim_prof, op_curr_min => v_curr_min, op_curr_carrier_id => v_curr_carrier_id, op_curr_parent_id => v_curr_parent_id, op_curr_zip_code => v_curr_zip_code, op1_port => v1_port, op1_carr_id => v1_carr_id, op1_parent_id => v1_parent_id, op1_case_conf => v1_case_conf, op1_repl_part => op_part_number, op1_repl_sim_prof => op_sim_profile, op1_repl_units => v1_repl_units, op1_repl_days => v1_repl_days, op1_issue => v1_issue, op2_port => v2_port, op2_carr_id => v2_carr_id, op2_parent_id => v2_parent_id, op2_case_conf => v2_case_conf, op2_repl_part => v2_repl_part, op2_repl_sim_prof => v2_repl_sim_prof, op2_repl_units => v2_repl_units, op2_repl_days => v2_repl_days, op2_issue => v2_issue, op2_bribe_units => v2_bribe_units, op_error_num => v_error_num, op_error_msg => v_error_msg );
    end if;

    if op_sim_profile is not null then
      open part_num_cur (op_sim_profile);
      fetch part_num_cur into part_num_rec;
      if part_num_cur%found then
        op_sim_suffix := part_num_rec.prog_type;
      end if;
      close part_num_cur;
      if op_part_number is null and repl_logic != 'UNLOCK' then  --CR41450 checking UNLOCK
          op_part_number := op_sim_profile;
      end if;
    end if;

  end get_repl_part_number;
--------------------------------------------------------------------------------
   procedure updateShippingAddress (
                            p_contact_objid varchar2,
                            p_case_id varchar2,
                            p_add_1 in varchar2,
                            p_add_2 in varchar2,
                            p_city in varchar2,
                            p_st in varchar2,
                            p_zip in varchar2,
                            p_country in varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2
   ) is
     cursor contact_cur is
	 	select s.cust_primaddr2address, s.cust_shipaddr2address, s.cust_billaddr2address
        from
               table_contact c,
               table_contact_role cr,
               table_site s
        where  c.objid = p_contact_objid
        and    cr.contact_role2contact  = c.objid
        and    cr.primary_site = 1
        And    S.Objid  = Cr.Contact_Role2site;
    contact_rec  contact_cur%rowtype;
    v_units varchar2(200);

   begin

    --CR42431 NGUADA START 04/19/2016
    DECLARE
      v_owner_objid varchar2(30);
      v_case_objid  varchar2(30);
      v_error_no    VARCHAR2(200);
      v_error_str   VARCHAR2(200);
    BEGIN

      SELECT case_owner2user
      INTO v_owner_objid
      FROM sa.table_case, sa.table_gbst_elm
      WHERE table_case.objid = p_case_id
      and table_case.casests2gbst_elm = table_gbst_elm.objid
      and table_gbst_elm.title = 'BadAddress';

      sa.CLARIFY_CASE_PKG.UPDATE_STATUS( P_CASE_OBJID => p_case_id, P_USER_OBJID => v_owner_objid, P_NEW_STATUS => 'Address Updated', P_STATUS_NOTES => 'Status Change due to Address Update', P_ERROR_NO => v_error_no, P_ERROR_STR => v_error_str );
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
   --CR42431 NGUADA END 04/19/2016

     p_err_code := '0';
	   p_err_msg := 'Success';
     open contact_cur;
	 fetch contact_cur into contact_rec;
	 if contact_cur%found then
	    if contact_rec.cust_shipaddr2address is not null then
			sa.adfcrm_internal.address (p_add_1,
								p_add_2,
								p_city,
								p_st,
								p_zip,
								p_country,
								contact_rec.cust_shipaddr2address, --p_address_objid in out number,  -- null--> Create / not null --> Update Address
								p_err_code,
								p_err_msg);
		end if;
	 end if;
	 close contact_cur;

   end;
--------------------------------------------------------------------------------
    procedure create_denied_exchange_ticket(p_user_objid in varchar2, p_esn in varchar2, p_contact_objid in varchar2, p_detail in varchar2)
    is
        v_case_type sa.table_case.x_case_type%type := 'Denied Exchange';
        v_case_title sa.table_case.title%type := 'Out of Warranty';
        v_id_number varchar2(200):='NOT FOUND';
        v_user_objid number;
        op_case_objid number;
        op_error_no varchar2(4000);
        op_error_str varchar2(4000);
    begin
        if p_user_objid is not null
        then
            v_user_objid := p_user_objid;
        else
            select objid
            into v_user_objid
            from sa.table_user
            where s_login_name = 'SA';
        end if;
        -- CREATE CASE
        begin
          sa.clarify_case_pkg.create_case (P_TITLE => v_case_title,
                                        P_CASE_TYPE => v_case_type,
                                        P_STATUS => null,
                                        P_PRIORITY => null,
                                        P_ISSUE => null,
                                        P_SOURCE => null,
                                        P_POINT_CONTACT => null,
                                        P_CREATION_TIME => sysdate,
                                        p_task_objid => null,
                                        P_CONTACT_OBJID => p_contact_objid,
                                        P_USER_OBJID => v_user_objid,
                                        P_ESN => p_esn,
                                        P_PHONE_NUM => null,
                                        P_FIRST_NAME => null,
                                        P_LAST_NAME => null,
                                        P_E_MAIL => null,
                                        P_DELIVERY_TYPE => null,
                                        P_ADDRESS => null,
                                        P_CITY => null,
                                        P_STATE => null,
                                        P_ZIPCODE => null,
                                        P_REPL_UNITS => null,
                                        P_FRAUD_OBJID => null,
                                        P_CASE_DETAIL => p_detail,
                                        P_PART_REQUEST => null,
                                        P_ID_NUMBER => v_id_number,
                                        P_CASE_OBJID => op_case_objid,
                                        P_ERROR_NO => op_error_no,
                                        p_error_str => op_error_str);
    dbms_output.put_line('Error No: '||nvl(op_error_no,'')||' Error Str: '||nvl(op_error_str,''));

          if v_id_number is null then
            -- LOG NOTES
            dbms_output.put_line('Error No: '||nvl(op_error_no,'')||' Error Str: '||nvl(op_error_str,''));
          else
            auto_close_case (   v_case_type ,
                                v_case_title ,
                                op_case_objid ,
                                v_user_objid ,
                                null ,
                                'Closed' ,
                                'Closed automatically');
          end if;

        exception
          when others then
            -- IF ANY ERRORS END
            dbms_output.put_line('Error while creating case '||sqlcode);
        end;
    end;
--------------------------------------------------------------------------------
FUNCTION isWtyExchangeEligible(
    p_esn             IN VARCHAR2 ,
    p_case_conf_objid IN VARCHAR2 ,
    p_case_title      IN VARCHAR2 ,
    p_case_type       IN VARCHAR2)
  RETURN VARCHAR2
IS
  eligible VARCHAR2(30);
  get_part_inst_rec get_part_inst%rowtype;
  w_cnt                  NUMBER :=0;
  cust_redem             NUMBER :=0;
  v_case_type            VARCHAR2(30);
  v_case_title           VARCHAR2(80);
  v_case_conf_objid      VARCHAR2(30);
  v_new_stock_max_age    NUMBER;
  v_refurb_stock_max_age NUMBER;
  v_sl_max_age           NUMBER;
  v_subsidy_cost         NUMBER:=0;
  v_domain               VARCHAR2(30);
  v_skip_subsidy_check   NUMBER:=0;
  v_issue_detail         VARCHAR2(500);
BEGIN
  v_case_type       := p_case_type;
  v_case_title      := p_case_title;
  v_case_conf_objid :=p_case_conf_objid;
  w_cnt             := 0;

  --CR46513 START NGUADA 11/15/16
  BEGIN
    SELECT x_param_value
    INTO v_new_stock_max_age
    FROM sa.table_x_parameters
    WHERE x_param_name = 'ADFCRM_FREE_EXCH_AGE_NEW_STOCK';
  EXCEPTION
  WHEN OTHERS THEN
    v_new_stock_max_age:=99999;
  END;
  BEGIN
    SELECT x_param_value
    INTO v_refurb_stock_max_age
    FROM sa.table_x_parameters
    WHERE x_param_name = 'ADFCRM_FREE_EXCH_AGE_REFURB_STOCK';
  EXCEPTION
  WHEN OTHERS THEN
    v_refurb_stock_max_age:=99999;
  END;
  BEGIN
    SELECT x_param_value
    INTO v_sl_max_age
    FROM sa.table_x_parameters
    WHERE x_param_name = 'ADFCRM_FREE_EXCH_AGE_SAFELINK';
  EXCEPTION
  WHEN OTHERS THEN
    v_sl_max_age:=99999;
  END;
  --CR46513 END NGUADA 11/15/16
  IF p_esn IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('ESN Null');
    RETURN 'true';

  END IF;
  IF p_case_conf_objid IS NOT NULL THEN
    BEGIN
      SELECT NVL(x_warehouse,0),
        x_case_type,
        x_title,
        objid,
        pn_domain_type,
        skip_subsidy_check
      INTO w_cnt,
        v_case_type,
        v_case_title,
        v_case_conf_objid,
        v_domain,
        v_skip_subsidy_check
      FROM sa.table_x_case_conf_hdr
      WHERE 1            =1
      AND objid          = p_case_conf_objid;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
  elsif p_case_title IS NOT NULL AND p_case_type IS NOT NULL THEN
    BEGIN
      SELECT NVL(x_warehouse,0),
        x_case_type,
        x_title,
        objid,
        pn_domain_type,
        skip_subsidy_check
      INTO w_cnt,
        v_case_type,
        v_case_title,
        v_case_conf_objid,
        v_domain,
        v_skip_subsidy_check
      FROM sa.table_x_case_conf_hdr
      WHERE 1            =1
      AND x_title        = p_case_title
      AND x_case_type    = p_case_type;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
  END IF;

    OPEN get_part_inst(p_esn);
    FETCH get_part_inst INTO get_part_inst_rec;
    IF get_part_inst%notfound THEN
      CLOSE get_part_inst;
      RETURN 'false';
    END IF;
    CLOSE get_part_inst;

  if  sa.adfcrm_safelink.get_lid(p_esn) is not null
  then
      BEGIN
        SELECT arpu_amount*arpu_multiplier
        INTO v_subsidy_cost
        FROM sa.table_bus_org
        WHERE org_id = 'SAFELINK';
      EXCEPTION
      WHEN OTHERS THEN
        v_subsidy_cost:=9999;
        NULL;
      END;
  else
      BEGIN
        SELECT arpu_amount*arpu_multiplier
        INTO v_subsidy_cost
        FROM sa.table_bus_org
        WHERE objid = get_part_inst_rec.part_num2bus_org;
      EXCEPTION
      WHEN OTHERS THEN
        v_subsidy_cost:=9999;
        NULL;
      END;
  end if;

  DBMS_OUTPUT.PUT_LINE('Subsidy Cost: '||v_subsidy_cost );
  BEGIN
    SELECT NVL(SUM(red.red_amount),0)
    INTO cust_redem
    FROM TABLE( sa.ADFCRM_GET_REDEMPTION.get_summary(p_esn,get_part_inst_rec.initial_activation,'en')) red
    WHERE red_parent = 'PAID REDEMPTIONS';

    DBMS_OUTPUT.PUT_LINE('Cust Redem: '||cust_redem );
  EXCEPTION
    WHEN OTHERS THEN
       cust_redem:=0;
  END;
  eligible := '-102'; --"ESN is not eligible for Warranty Exchange"
    --CR46924 March-2017 begin
    --the warranty period provided to any customer, regardless of number of exchanges, is 365 days from activation date of an original phone
    if v_case_type = 'Warranty' and w_cnt > 0 and v_domain = 'PHONES' and upper(v_case_title) != 'DIAGNOSE COVERAGE'
       and nvl(sa.clarify_case_pkg.get_warranty_days_left(p_esn),0) <= 0
    then
        DBMS_OUTPUT.PUT_LINE('ESN '||p_esn||' Warranty days expired, Case Type/Title: '||v_case_type||'/'||v_case_title);
        --CR57660 Restore Denied Exchange Case Creation;
        v_issue_detail := substr('DESCRIPTION_OF_ISSUE||'||'Warranty days expired, Case Type/Title: '||v_case_type||'/'||v_case_title,1,500);
        create_denied_exchange_ticket(null,p_esn,get_part_inst_rec.x_part_inst2contact,v_issue_detail);
        return eligible;
    end if;
    --CR46924 March-2017 End

  --Begin CR29798 Warranty Rules for Defective Exchange Cases
  if v_domain = 'PHONES' and w_cnt > 0  then
  IF v_case_type ='Warranty' THEN

    IF get_part_inst_rec.operating_system NOT IN ('NOT FOUND','ANDROID') AND getWtyExchangeCase(p_esn) <> 'NOT FOUND' THEN
      eligible                                := '-200'; --CR30728  "An open warranty exchange case already exists for this device."
    ELSE
      --if get_part_inst_rec.subsidy_cost in ('NOT FOUND','0')
      --The dollar value of the customer?s redemptions equals or exceeds the handset?s subsidy value configured
      --then
      -- eligible := 'true';
      IF get_part_inst_rec.x_part_inst_status IN ('50','150') --New or Refurbished
        THEN
        eligible := 'true';
        DBMS_OUTPUT.PUT_LINE('New or Refub Status');
      elsif --the phone does not need to be status Active (it could be used or past due as well) get_part_inst_rec.x_part_inst_status = '52' and
        --CR46513 START NGUADA 11/15/16
        (get_part_inst_rec.x_refurb_flag                             = 0 AND get_part_inst_rec.phone_age <= v_new_stock_max_age)    --It was activated from status New, within the last 365 days
        OR (get_part_inst_rec.x_refurb_flag                          = 1 AND get_part_inst_rec.phone_age <= v_refurb_stock_max_age) --It was activated from status Refurbished, within the last 90 days
        OR (sa.ADFCRM_CUST_SERVICE.IS_PHONE_SAFELINK(IP_ESN => p_esn)=1 AND get_part_inst_rec.phone_age <= v_sl_max_age)
        --CR46513 END NGUADA 11/15/16
        THEN
        DBMS_OUTPUT.PUT_LINE('New or Refurb or Safelink Age OK:'||get_part_inst_rec.phone_age);
        eligible := 'true';
      end if;

    END IF;
  ELSE --w_cnt = 0

    --Not a Warranty Case Type + REDEMPTION >= SUBSIDY COST ? Pass
    IF get_part_inst_rec.operating_system NOT IN ('NOT FOUND','ANDROID') AND getWtyExchangeCase(p_esn) <> 'NOT FOUND' THEN
      eligible                                := '-200'; --CR30728  "An open warranty exchange case already exists for this device."
    ELSE
      DBMS_OUTPUT.PUT_LINE('Not a Warranty Case');
      IF cust_redem >= v_subsidy_cost or v_skip_subsidy_check = 1 THEN
         DBMS_OUTPUT.PUT_LINE('Cust Redem > Subsidy Cost');
         eligible    := 'true';
      ELSE
         DBMS_OUTPUT.PUT_LINE('Cust Redem < Subsidy Cost');
         eligible    := '-103';  ---ESN is not eligible for Exchange ? Subsidy not met
        --CR57660 Restore Denied Exchange Case Creation;
        v_issue_detail := substr('DESCRIPTION_OF_ISSUE||'||'Have not met subsidy requirement, Case Type/Title: '||v_case_type||'/'||v_case_title,1,500);
        create_denied_exchange_ticket(null,p_esn,get_part_inst_rec.x_part_inst2contact,v_issue_detail);
      END IF;
    END IF;
    -- End Not Warranty Case
  END IF;
  ELSE
    -- NOt a PHONE Domain Case
    eligible := 'true';
    DBMS_OUTPUT.PUT_LINE('NOT PHONE DOMAIN OR NOT WAREHOUSE=1 CASE');
  END IF;
  --End CR29798 Warranty Rules for Defective Exchange Cases

  --Phone Gen Exception
  SELECT COUNT('1')
  INTO w_cnt
  FROM Table_X_Part_Class_Values ,
    Table_X_Part_Class_Params
  WHERE value2part_class = get_part_inst_rec.part_num2part_class
  AND Value2class_Param  = Table_X_Part_Class_Params.Objid
  AND x_param_name       = 'PHONE_GEN'
  AND x_param_value      = '2G';

  IF w_cnt               >0 THEN
    DBMS_OUTPUT.PUT_LINE('PHONE_GEN=2G');
    eligible            := 'true';
  END IF;

  RETURN eligible; --If false the error for CREATE_CASE function is -102 ESN is not eligible for Warranty Exchange
END isWtyExchangeEligible;
--------------
-- TAS_2017_07
--------------

--CR49301
FUNCTION isESNSubsidyEligible(
    p_esn             IN VARCHAR2)
  RETURN VARCHAR2
IS
  eligible VARCHAR2(30);
    get_part_inst_rec get_part_inst%rowtype;
  cust_redem             NUMBER :=0;
  v_subsidy_cost         NUMBER:=0;

BEGIN

    OPEN get_part_inst(p_esn);
    FETCH get_part_inst INTO get_part_inst_rec;
    IF get_part_inst%notfound THEN
      CLOSE get_part_inst;
      RETURN 'false';
    END IF;
    CLOSE get_part_inst;

  if  sa.adfcrm_safelink.get_lid(p_esn) is not null
  then
      BEGIN
        SELECT arpu_amount*arpu_multiplier
        INTO v_subsidy_cost
        FROM sa.table_bus_org
        WHERE org_id = 'SAFELINK';
      EXCEPTION
      WHEN OTHERS THEN
        v_subsidy_cost:=9999;
        NULL;
      END;
  else
      BEGIN
        SELECT arpu_amount*arpu_multiplier
        INTO v_subsidy_cost
        FROM sa.table_bus_org
        WHERE objid = get_part_inst_rec.part_num2bus_org;
      EXCEPTION
      WHEN OTHERS THEN
        v_subsidy_cost:=9999;
        NULL;
      END;
  end if;

  DBMS_OUTPUT.PUT_LINE('Subsidy Cost: '||v_subsidy_cost );
  BEGIN
    SELECT NVL(SUM(red.red_amount),0)
    INTO cust_redem
    FROM TABLE( sa.ADFCRM_GET_REDEMPTION.get_summary(p_esn,get_part_inst_rec.initial_activation,'en')) red
    WHERE red_parent = 'PAID REDEMPTIONS';

    DBMS_OUTPUT.PUT_LINE('Cust Redem: '||cust_redem );
  EXCEPTION
    WHEN OTHERS THEN
       cust_redem:=0;
  END;

  IF cust_redem >= v_subsidy_cost THEN
         DBMS_OUTPUT.PUT_LINE('Cust Redem > Subsidy Cost');
         eligible    := 'true';
      ELSE
         DBMS_OUTPUT.PUT_LINE('Cust Redem < Subsidy Cost');
         eligible    := '-103';  ---ESN is not eligible for Exchange ? Subsidy not met
      END IF;
  dbms_output.put_line('Pradeep Subsidy eligible:'||eligible);

  RETURN eligible;
END isESNSubsidyEligible;

   function update_replacement_units (p_case_id varchar2) return varchar2 is

      -- p_case_id in this
      cursor c1 is
      select ca.objid,cd.x_value, ca.x_esn
      from sa.table_case ca, sa.table_x_case_detail cd
      where ca.id_number = p_case_id
      and cd.detail2case = ca.objid
      and x_name = 'UNITS_TO_TRANSFER';

      r1 c1%rowtype;

      cursor c2 (p_esn varchar2) is
      select
         sa.adfcrm_serv_plan.getServPlanGroupType(xsp.x_service_plan_id)  plan_group
      from table_site_part tsp, x_service_plan_site_part xsp
      where tsp.x_service_id = p_esn
      and tsp.part_status in ('Active','CarrierPending')
      and tsp.objid = xsp.table_site_part_id;

      r2 c2%rowtype;

      v_return varchar2(200):='0';
   begin

      if p_case_id is not null then
         open c1;
         fetch c1 into r1;
         if c1%found then
            open c2(r1.x_esn);
            fetch c2 into r2;
            if c2%found then
               if r2.plan_group <> 'UNLIMITED' then
                 update sa.table_case
                 set x_replacement_units = to_number(r1.x_value)
                 where objid = r1.objid;
                 commit;
                 v_return := r1.x_value;
               end if;
           else
               update sa.table_case
               set x_replacement_units = to_number(r1.x_value)
               where objid = r1.objid;
               commit;
               v_return := r1.x_value;
           end if;
           close c2;
         end if;
         close c1;
      end if;
      return v_return;
   exception
      when others then
         return '0';
   end update_replacement_units;

function get_orgid_from_case (p_case_id varchar2) return varchar2 is

cursor c1 is
select org_id
from sa.table_case ca,
     sa.table_part_inst pi,
     sa.table_mod_level ml,
     sa.table_part_num pn,
     sa.table_bus_org bo
where ca.id_number = p_case_id
and   pi.part_serial_no = ca.x_esn
and   pi.x_domain = 'PHONES'
and   pi.n_part_inst2part_mod = ml.objid
and   ml.part_info2part_num = pn.objid
and   pn.part_num2bus_org = bo.objid;
r1 c1%rowtype;
v_org_id varchar2(30):='NOT FOUND';
begin

  if p_case_id is not null then
     open c1;
     fetch c1 into r1;
     v_org_id := r1.org_id;
     close c1;
  end if;
  return v_org_id;

end;

function get_esn_from_case (p_case_id varchar2) return varchar2 is

cursor c1 is
select ca.x_esn
from sa.table_case ca,
     sa.table_part_inst pi
where ca.id_number = p_case_id
and   pi.part_serial_no = ca.x_esn
and   pi.x_domain = 'PHONES';

r1 c1%rowtype;
v_esn varchar2(30):='NOT FOUND';
begin

  if p_case_id is not null then
     open c1;
     fetch c1 into r1;
     v_esn := r1.x_esn;
     close c1;
  end if;
  return v_esn;

end;

function getWtyExchangeCase (p_esn varchar2) return varchar2 is

cursor c1 (ip_esn varchar2) is
select c.x_esn, c.ID_NUMBER, ge.title
from  sa.table_case c,
      sa.table_gbst_elm ge,
      sa.table_x_case_conf_hdr cc
WHERE c.x_esn = ip_esn
and ge.objid = c.casests2gbst_elm
and ge.title <>  'Closed'
and cc.x_title = c.title
and cc.x_case_type = c.x_case_type
and cc.x_warehouse = 1
order by id_number desc;

r1 c1%rowtype;
v_id_number varchar2(100):='NOT FOUND';
begin

  if p_esn is not null then
     open c1(p_esn);
     fetch c1 into r1;
     v_id_number := nvl(r1.id_number,'NOT FOUND');
     close c1;
  end if;
  return v_id_number;

end getWtyExchangeCase;

--------------
--TAS_2014_11
--------------
function compensate_reward_points (ip_esn  varchar2,
                                   ip_action varchar2,  --ADD, DEDUCT
                                   ip_points varchar2,
                                   ip_service_plan_objid varchar2,
                                   ip_reason varchar2,
                                   ip_notes varchar2,
                                   ip_contact_objid varchar2,
                                   ip_user_objid varchar2) return varchar2 is

  V_POINTS NUMBER;
  V_AMOUNT NUMBER;
  V_OUT_ERR_CODE NUMBER;
  V_OUT_ERR_MSG  VARCHAR2(200);
  V_ID_NUMBER VARCHAR2(30);
  V_CASE_OBJID NUMBER;
  V_ERROR_NO VARCHAR2(30);
  V_ERROR_STR VARCHAR2(200);
  v_reward_objid NUMBER;
  v_return  varchar2(200);
  v_notes varchar2(500);

begin

  sa.REWARD_POINTS_PKG.P_COMPENSATE_REWARD_POINTS(
    IN_KEY => 'ESN',
    IN_VALUE => ip_esn,
    IN_POINTS => ip_points,
    IN_POINTS_CATEGORY => 'REWARD_POINTS',
    IN_POINTS_ACTION => ip_action,
    IN_USER_OBJID => ip_user_objid,
    IN_COMPENSATE_REASON => ip_reason ||chr(10)||ip_notes,
    IN_SERVICE_PLAN_OBJID => ip_service_plan_objid,
    OUT_TOTAL_POINTS => V_POINTS,
    inout_transaction_id => v_reward_objid,
    OUT_ERR_CODE => V_OUT_ERR_CODE,
    OUT_ERR_MSG => V_OUT_ERR_MSG
  );

  if V_OUT_ERR_CODE = 0 then
  sa.clarify_case_pkg.create_case (P_TITLE => 'Upgrade Points',
                                P_CASE_TYPE => 'Units',
                                P_STATUS => 'Pending',
                                P_PRIORITY => 'Low',
                                P_ISSUE => ip_reason,
                                P_SOURCE => 'TAS',
                                P_POINT_CONTACT => null,
                                P_CREATION_TIME => sysdate,
                                P_TASK_OBJID => null,
                                P_CONTACT_OBJID => ip_contact_objid,
                                P_USER_OBJID => ip_user_objid,
                                P_ESN => ip_esn,
                                P_PHONE_NUM =>  null,
                                P_FIRST_NAME => null,
                                P_LAST_NAME => null,
                                P_E_MAIL => null,
                                P_DELIVERY_TYPE => null,
                                P_ADDRESS => null,
                                P_CITY => null,
                                P_STATE => null,
                                P_ZIPCODE => null,
                                P_REPL_UNITS => null,
                                P_FRAUD_OBJID => null,
                                P_CASE_DETAIL => 'REWARD_TRANS_ID||'||to_char(v_reward_objid),
                                P_PART_REQUEST => null,
                                P_ID_NUMBER => v_id_number,
                                P_CASE_OBJID => v_case_objid,
                                P_ERROR_NO => v_error_no,
                                P_ERROR_STR => v_error_str);

   if v_error_no = '0' then

       v_notes := V_POINTS||' POINT(S) '||ip_action||'ED'||CHR(10);
       v_notes := v_notes ||' Reward Transaction Objid: '||v_reward_objid||CHR(10);
       v_notes := v_notes ||' Reason: '||ip_reason||CHR(10);
       v_notes := v_notes ||ip_notes;


       sa.clarify_case_pkg.log_notes( v_case_objid
                                     ,ip_user_objid
                                     ,v_notes
                                     ,null
                                     ,v_error_no
                                     ,v_error_str
                                    );

       sa.clarify_case_pkg.close_case ( v_case_objid
                                      ,ip_user_objid
                                      ,'TAS'
                                      ,null
                                      ,null
                                      ,v_error_no
                                      ,v_error_str
                                      );

     end if;

     v_return:='SUCCESS: '||V_POINTS||' POINT(S) '||ip_action||'ED';
  else
     v_return:='ERROR: '||V_OUT_ERR_CODE||' '||V_OUT_ERR_MSG;
  end if;

  return v_return;

end compensate_reward_points;

-----------------------------------------------------------------------------------------------------------------------------
--New procedure create_case for CR32682 TAS - Warranty Cases - Case Creation Enhancements
-----------------------------------------------------------------------------------------------------------------------------
  procedure create_case (p_case_type in varchar2,
                                p_case_title in varchar2,
                                p_case_status in varchar2,
                                p_case_priority in varchar2,
                                p_case_source in varchar2,
                                p_case_poc in varchar2,
                                p_case_issue in varchar2,
                                p_contact_objid in varchar2,
                                p_first_name in varchar2,
                                p_last_name in varchar2,
                                p_user_objid in varchar2,
                                p_esn in varchar2,
                                p_case_part_req in varchar2,
                                p_case_notes in varchar2,
                                p_phone in varchar2,
                                p_email in varchar2,
                                p_addr in varchar2,
                                p_city in varchar2,
                                p_country in varchar2,
                                p_st in varchar2,
                                p_zip in varchar2,
                                op_id_number out varchar2,
                                op_error_num out varchar2,
                                op_error_msg out varchar2)
  IS
    v_id_number varchar2(200);
    v_part_req varchar2(400);
    op_case_objid number;
    op_error_no varchar2(200);
    op_error_str varchar2(4000);
    op_out_msg varchar2(400);
    v_c_dtl_rslt varchar2(200);
    is_wh_case number;
    w_cnt number;
    v_domain_type varchar2(100);
    ph_part_number varchar2(100);
    isWtyExchEligibleFlag varchar2(100);
    v_5g_exception varchar2(30);

    FUNCTION verify_5g_exception(
        p_esn       IN VARCHAR2,
        p_case_type IN VARCHAR2,
        p_title     IN VARCHAR2 )
      RETURN VARCHAR2
    IS
      P_SERVICE_PLAN_OBJID VARCHAR2(30);
      P_SERVICE_TYPE       VARCHAR2(200);
      P_PROGRAM_TYPE       VARCHAR2(200);
      P_NEXT_CHARGE_DATE DATE;
      P_PROGRAM_UNITS         NUMBER;
      P_PROGRAM_DAYS          NUMBER;
      P_ERROR_NUM             NUMBER;
      P_SERVICE_PLAN_PROPERTY VARCHAR2(30) :='EXCEPTIONS';
      P_SERVICE_PLAN_VALUE    VARCHAR2(30) :='5G EXCEPTION';
      P_return                VARCHAR2(200):='CONTINUE';
    BEGIN
      IF p_case_type = 'Data Issues' AND p_title = 'CDMA 5G Exception' THEN
        sa.PHONE_PKG.GET_PROGRAM_INFO( P_ESN => P_ESN, P_SERVICE_PLAN_OBJID => P_SERVICE_PLAN_OBJID, P_SERVICE_TYPE => P_SERVICE_TYPE, P_PROGRAM_TYPE => P_PROGRAM_TYPE, P_NEXT_CHARGE_DATE => P_NEXT_CHARGE_DATE, P_PROGRAM_UNITS => P_PROGRAM_UNITS, P_PROGRAM_DAYS => P_PROGRAM_DAYS, P_ERROR_NUM => P_ERROR_NUM );
        IF nvl(sa.GET_SERV_PLAN_VALUE(IP_PLAN_OBJID => P_SERVICE_PLAN_OBJID,IP_PROPERTY_NAME => P_SERVICE_PLAN_PROPERTY),'NA') <> P_SERVICE_PLAN_VALUE THEN
          p_return  :='BLOCK';
        END IF;
      END IF;
      RETURN p_return;
    END;
  begin
    isWtyExchEligibleFlag := isWtyExchangeEligible(p_esn,null,p_case_title,p_case_type);

    --Begin CR29798 Warranty Rules for Defective Exchange Cases
    if p_esn is not null and isWtyExchEligibleFlag <> 'true'
    then
       -- error returned by function  isWtyExchangeEligible
       -- -102 ESN is not eligible for Warranty Exchange
       -- -200 An open warranty exchange case already exists for this device.
       op_error_num := isWtyExchEligibleFlag;
       op_error_msg := 'Error No: '||nvl(op_error_num,'')||' Error Str: '||
                      CASE isWtyExchEligibleFlag
                      WHEN '-102' THEN 'ESN is not eligible for Warranty Exchange'
                      WHEN '-200' THEN 'An open warranty exchange case already exists for this device.'
                      ELSE ''
                      END;
       return;   --procedure stops here ESN is not eligible for Warranty Exchange or case already open
    end if;
    --End CR29798 Warranty Rules for Defective Exchange Cases

    -- GRABBING THE CASE HEADER INFO IF IT'S NOT A WAREHOUSE CASE THEN
    -- IGNORE ANY PART REQUEST
    begin
    select count(x_warehouse), max(pn_domain_type)
    into   w_cnt, v_domain_type
    from   sa.table_x_case_conf_hdr
    where  1=1
    and    x_warehouse = 1
    and    x_title = p_case_title
    and    x_case_type = p_case_type;
dbms_output.put_line('************************** w_cnt: '||w_cnt||'  v_domain_type: '||v_domain_type);
    --CR49600 Block Sprint SIM Exchange
    --CR49638 Enforce Carriersimpref Validation
    if w_cnt > 0 and nvl(v_domain_type,'unknown') = 'SIM CARDS' then
        begin
            select pn.part_number
            into ph_part_number
            FROM   sa.TABLE_PART_INST pi,
                   sa.TABLE_MOD_LEVEL ml,
                   sa.TABLE_PART_NUM pn
            WHERE  pi.part_serial_no = p_esn
            AND    pi.x_domain = 'PHONES'
            AND    ml.objid = pi.n_part_inst2part_mod
            AND    pn.objid = ml.part_info2part_num;
        exception
            when others then null;
        end;

       op_error_msg := check_carriersimpref (ph_part_number, p_case_part_req);
dbms_output.put_line('************************** create_case  ph_part_number: '||ph_part_number||'  p_case_part_req: '||p_case_part_req||'  check_carriersimpref : '||op_error_msg);
       if op_error_msg <> 'Valid' then
           op_error_num := '-210';
           op_error_msg := 'Error No: '||op_error_num||' Error Str: '||op_error_msg;
           return;   --procedure stops here
       end if;
    end if;

    --CHECK CUSTOMER FIRST NAME AND LAST NAME FOR WAREHOUSE CASES
    if w_cnt > 0 and
       not ( p_first_name is not null and regexp_like(p_first_name,'^[a-zA-Z ]+$') and
            (p_last_name is null or (p_last_name is not null and regexp_like(p_last_name,'^[a-zA-Z ]+$')) )
            )
    then
       op_error_num := '-101';
       op_error_msg := 'Error No: '||op_error_num||' Error Str: '||'Customer first name or last name is invalid';
       return;   --procedure stops here
    end if;

    if w_cnt > 0 then
		sa.ADFCRM_TRANSACTIONS.validate_address(p_addr,
								null,
								p_city,
								p_st,
								p_zip,
								nvl(p_country,'USA'),
								op_error_no,
								op_error_str);

		if op_error_no != '0' then
			op_error_num := op_error_no;
			op_error_msg := 'Error No: '||nvl(op_error_num,'')||' Error Str: '||nvl(op_error_str,'');
			return;
		end if;
    end if;


    -- Check 5G Exception
    v_5g_exception:=verify_5g_exception(p_esn=>p_esn,p_case_type=>p_case_type,p_title=>p_case_title);
    if v_5g_exception = 'BLOCK' then
       op_error_num := '-110';
       op_error_msg := 'Error No: '||op_error_num||' Error: Serial Number does not qualify for 5G Exception Case';
       return;
    end if;
    -- End 5G Exception

    if w_cnt > 0 then
      v_part_req := p_case_part_req;
    else
      v_part_req := null;
    end if;
    exception
       when others then
       dbms_output.put_line('*** ADFCRM_CASE.CREATE_CASE Exception: '||substr(sqlerrm,1,100));
       v_part_req :=null;
    end;
    -- CREATE CASE
    begin
      sa.clarify_case_pkg.create_case (P_TITLE => p_case_title,
                                    P_CASE_TYPE => p_case_type,
                                    P_STATUS => p_case_status,
                                    P_PRIORITY => p_case_priority,
                                    P_ISSUE => p_case_issue,
                                    P_SOURCE => p_case_source,
                                    P_POINT_CONTACT => p_case_poc,
                                    P_CREATION_TIME => sysdate,
                                    P_TASK_OBJID => null,
                                    P_CONTACT_OBJID => p_contact_objid,
                                    P_USER_OBJID => p_user_objid,
                                    P_ESN => p_esn,
                                    P_PHONE_NUM => p_phone,
                                    P_FIRST_NAME => p_first_name,
                                    P_LAST_NAME => p_last_name,
                                    P_E_MAIL => p_email,
                                    P_DELIVERY_TYPE => null,
                                    P_ADDRESS => p_addr,
                                    P_CITY => p_city,
                                    P_STATE => p_st,
                                    P_ZIPCODE => p_zip,
                                    P_REPL_UNITS => null,
                                    P_FRAUD_OBJID => null,
                                    P_CASE_DETAIL => null,
                                    P_PART_REQUEST => v_part_req,
                                    P_ID_NUMBER => v_id_number,
                                    P_CASE_OBJID => op_case_objid,
                                    P_ERROR_NO => op_error_no,
                                    P_ERROR_STR => op_error_str);

      -- IF CASE CREATION IS SUCCESS, LOG NOTES AND INSERT CASE DETAILS
      -- IF UNABLE TO LOG NOTES OR DETAILS JUST RETURN THE CASE ID NUMBER
      -- CASE DETAILS IMPLEMENTED DIFF, DUE TO ADF LIMITATION


      if v_id_number is null then
        -- LOG NOTES
        op_error_num := op_error_no;
        op_error_msg := 'Error No: '||nvl(op_error_no,'')||' Error Str: '||nvl(op_error_str,'');
        return;
      else
        begin
          sa.clarify_case_pkg.log_notes (P_CASE_OBJID => op_case_objid,
                                      P_USER_OBJID => p_user_objid,
                                      P_NOTES => p_case_notes,
                                      P_ACTION_TYPE => 'Agent Added Notes : ',
                                      P_ERROR_NO => op_error_no,
                                      P_ERROR_STR => op_error_str);

          v_c_dtl_rslt := add_case_dtl_records(v_id_number);

        exception
          when others then
            null;
        end;

        op_id_number := v_id_number;
        op_error_num := '0';
        op_error_msg := 'Ticket has been created successfully';
        -- Dispatch the case CR48681
        sa.CLARIFY_CASE_PKG.DISPATCH_CASE(
                  P_CASE_OBJID => op_case_objid,
                  P_USER_OBJID => p_user_objid,
                  P_QUEUE_NAME => null,
                  P_ERROR_NO => op_error_no,
                  P_ERROR_STR => op_error_str
                );
          if op_error_no <> '0' then
             op_error_num := op_error_no;
             op_error_msg := 'Ticket has been created but dispatch Failed: '||op_error_str;
          end if;
--        return;
      end if;

      --CR52928 Block Shipments to Fraud related addresses
     auto_close_case
          (p_case_type ,
          p_case_title ,
          op_case_objid ,
          p_user_objid ,
          null,
          'Closed' ,
          'Closed automatically');

    exception
      when others then
        op_error_num := sqlcode;
        op_error_msg := 'Error No: '||nvl(sqlcode,'')||' Error Str: '||'Error while creating case :'||sqlerrm;
        return;
    end;

  end create_case;

  -----------------------------------------------------------------
--CR42725 New procedure del_case_dtl_records
procedure del_case_dtl_record(ip_case_objid varchar2, ip_attr_name varchar2) is
begin
   delete from sa.table_x_case_detail cd
   where cd.detail2case = ip_case_objid
   and  cd.x_name = ip_attr_name;
exception
   when others then null;
end del_case_dtl_record;

--CR42725 New procedure upd_case_detail_flag
procedure upd_case_detail_flag(ip_id_number varchar2, ip_user_objid varchar2) is
    cursor failed_attr (ip_case_objid number) is
        select objid, x_name, x_value
        from sa.table_x_case_detail
        where detail2case = ip_case_objid
        and x_name like 'FAILED_%';

    cursor attr_by_name (ip_case_objid number, p_name in varchar2) is
        select objid, x_name, x_value
        from sa.table_x_case_detail
        where detail2case = ip_case_objid
        and  x_name = p_name;
    ip_case_objid number;
    v_condition_title sa.table_condition.title%type;
    v_user_objid varchar2(50);
    op_error_no varchar2(200);
    op_error_str varchar2(4000);
    v_case_detail varchar2(4000) := '';
    v_dtl_upd_cnt number;
begin
    v_dtl_upd_cnt := 0;
    begin
       select c.objid, cond.title
       into ip_case_objid, v_condition_title
       from sa.table_case c, table_condition cond
       where c.id_number = ip_id_number
       and cond.objid = c.case_state2condition;
    exception
       when others then return;
    end;

    IF v_condition_title = 'Closed' THEN
        return;
    end if;

    v_user_objid := ip_user_objid;
    if v_user_objid is null then
       select objid
       into v_user_objid
       from sa.table_user
       where s_login_name = 'SA';
    end if;
    for rec1 in failed_attr(ip_case_objid)
    loop
        for rec2 in attr_by_name(ip_case_objid,replace(rec1.x_name,'FAILED_',''))
        loop
            if nvl(rec1.x_value,'empty') = nvl(rec2.x_value,'empty') then
                --Dev=1, Attribute with the prefix FAILED should not be shown in TAS
                update sa.table_x_case_detail
                set dev = 1
                where objid = rec1.objid
                and detail2case = ip_case_objid
                and x_name = rec1.x_name
                and nvl(dev,0) != 1;

                --Dev=2, if there is a matching attribute with the prefix FAILED
                --meaning the value is missing or wrong info
                update sa.table_x_case_detail
                set dev = 2
                where objid = rec2.objid
                and detail2case = ip_case_objid
                and x_name = rec2.x_name
                and nvl(dev,0) != 2;
            else
                --Value was updated, remove failed attribute and remove mark from original
                v_dtl_upd_cnt := v_dtl_upd_cnt+1;
                v_case_detail := v_case_detail||rec2.x_name||':'||rec1.x_value||' ';

                del_case_dtl_record(ip_case_objid,rec1.x_name);

                update sa.table_x_case_detail
                set dev = 0
                where objid = rec2.objid
                and detail2case = ip_case_objid
                and x_name = rec2.x_name
                and nvl(dev,0) = 2;
            end if;
        end loop;
    end loop;
    if v_dtl_upd_cnt > 0 then
        --check if any FAILED attribute.
        select count(*)
        into v_dtl_upd_cnt
        from sa.table_x_case_detail
        where detail2case = ip_case_objid
        and x_name like 'FAILED_%';

        if v_dtl_upd_cnt = 0 then
            update sa.table_case
            set case_type_lvl3 = 'Pending'
            where objid = ip_case_objid
            and x_case_type in ('Port In','Port Out')
            and case_type_lvl3 = 'Missing/Wrong Info';
       end if;
       --Add note
       sa.clarify_case_pkg.log_notes (P_CASE_OBJID => ip_case_objid,
                                      P_USER_OBJID => v_user_objid,
                                      P_NOTES => 'Attributes have been updated, previous value '||v_case_detail,
                                      P_ACTION_TYPE => 'Agent Added Notes : ',
                                      P_ERROR_NO => op_error_no,
                                      P_ERROR_STR => op_error_str);
    end if;
    commit;
end upd_case_detail_flag;

-------------------------------------------------------------------------------------
--New function is_fraud_detected CR52928 Block Shipments to Fraud related addresses
function is_fraud_detected (p_case_objid number)
return varchar2 is
    v_cnt number := 0;
begin
    select count(*)
    into v_cnt
    from sa.table_case c,
         sa.x_fraud_address f
    where c.objid = p_case_objid
    and f.zipcode = c.alt_zipcode
    and clean_text_to_compare(f.state) = clean_text_to_compare(c.alt_state)
    and clean_text_to_compare(f.city) = clean_text_to_compare(c.alt_city)
    and clean_text_to_compare(f.address_1||f.address_2) = clean_text_to_compare(c.alt_address);

    if v_cnt > 0 then
       return 'true';
    else
       return 'false';
    end if;
end is_fraud_detected;

PROCEDURE fetchExistingCaseObjId(
    p_case_conf_id IN VARCHAR2,
    p_case_type  IN VARCHAR2,
    p_case_title IN VARCHAR2,
    p_esn        IN VARCHAR2,
    op_case_obj_id OUT VARCHAR2,
    op_case_id_num out varchar2,
    op_error_num OUT VARCHAR2,
    op_error_msg OUT VARCHAR2)
IS
  v_case_title VARCHAR2(80);
  v_case_type  VARCHAR2(30);
  CURSOR Cur_OldCase
  IS
    SELECT TableCase.OBJID caseObjId, TableCase.id_number id_number
    FROM TABLE_CASE TableCase,
      TABLE_EXTACTCASE TableExtactcase
    WHERE TableCase.id_number        = TableExtactcase.ID_NUMBER
    AND TableExtactcase.X_ESN        = p_esn
    AND upper(TableCase.S_TITLE)     = upper(v_case_title)
    AND upper(TableCase.X_CASE_TYPE) = upper(v_case_type)
    order by TableCase.creation_time desc;

  rec_OldCase Cur_OldCase%rowtype;

    CURSOR Cur_CaseConfHdr
  IS
    SELECT confHdr.objid,
      confHdr.x_case_type,
      confHdr.s_x_case_type,
      confHdr.x_title,
      confHdr.s_x_title,
      confHdr.X_BLOCK_REOPEN,
      confHdr.X_REOPEN_DAYS_CHECK
    FROM sa.TABLE_X_CASE_CONF_HDR confHdr
    WHERE  confHdr.OBJID         =p_case_conf_id ;

  rec_CaseConfHdr Cur_CaseConfHdr%rowtype;

BEGIN
  v_case_type     := p_case_type;
  v_case_title    := p_case_title;

  IF p_case_conf_id IS NULL AND (p_case_type IS NULL OR p_case_title IS NULL) THEN
    op_error_num  := '-1';
    op_error_msg  := 'Case conf header obj id or case type and case title are required to fetch existing case obj id.';
    RETURN;
  END IF;

  IF p_esn       IS NULL THEN
    op_error_num := '-1';
    op_error_msg := 'Device ESN is required to fetch existing case obj id.';
    RETURN;
  END IF;

  if p_case_conf_id is not null and (p_case_type IS NULL OR p_case_title IS NULL) then
      OPEN Cur_CaseConfHdr;
      FETCH Cur_CaseConfHdr INTO rec_CaseConfHdr;
      IF Cur_CaseConfHdr%found THEN
          v_case_title       := rec_CaseConfHdr.s_x_title;
          v_case_type        := rec_CaseConfHdr.s_x_case_type;
      END IF;
      CLOSE Cur_CaseConfHdr;
  end if;

  OPEN Cur_OldCase;
  FETCH Cur_OldCase INTO rec_OldCase;
  IF Cur_OldCase%notfound THEN -- there is no similar old case found, so we can create new case
    op_error_num := '-1';
    op_error_msg := 'Existing case is not found.';
  ELSE -- similar old case which can be reopened is found. cannot create new case.
    op_case_obj_id   := rec_OldCase.caseObjId;
    op_case_id_num := rec_OldCase.id_number;
    op_error_num := '0';
  END IF;
  CLOSE Cur_OldCase;

END fetchExistingCaseObjId;

--API to check if case of input types can be created. Case OBJ ID or  (case type and case title) are mandatory to find if case can be created along with ESN
PROCEDURE can_create_case(
    p_case_objid IN VARCHAR2,
    p_case_type  IN VARCHAR2,
    p_case_title IN VARCHAR2,
    p_esn        IN VARCHAR2,
    op_can_create_case OUT VARCHAR2,
    op_case_id OUT VARCHAR2,
    op_error_num OUT VARCHAR2,
    op_error_msg OUT VARCHAR2)
IS
  v_case_title       VARCHAR2(80);
  v_case_type        VARCHAR2(30);
  v_case_reopen      NUMBER;
  v_case_reopen_days NUMBER;

  CURSOR Cur_OldCase
  IS
    SELECT TableCase.OBJID,
      TableCase.CREATION_TIME,
      TableCase.ID_NUMBER
    FROM TABLE_CASE TableCase,
      TABLE_EXTACTCASE TableExtactcase
    WHERE TableCase.id_number        = TableExtactcase.ID_NUMBER
    AND TableExtactcase.X_ESN        = p_esn
    AND TableCase.S_TITLE            = v_case_title
    AND upper(TableCase.X_CASE_TYPE) = v_case_type
    AND TableCase.CREATION_TIME      > sysdate-v_case_reopen_days;

  rec_OldCase Cur_OldCase%rowtype;

  CURSOR Cur_CaseConfHdr
  IS
    SELECT confHdr.objid,
      confHdr.x_case_type,
      confHdr.s_x_case_type,
      confHdr.x_title,
      confHdr.s_x_title,
      confHdr.X_BLOCK_REOPEN,
      confHdr.X_REOPEN_DAYS_CHECK
    FROM sa.TABLE_X_CASE_CONF_HDR confHdr
    WHERE (p_case_objid     IS NULL
    AND confHdr.S_X_CASE_TYPE=upper(v_case_type)
    AND confHdr.S_X_TITLE    =upper(v_case_title))
    OR confHdr.OBJID         =p_case_objid ;

  rec_CaseConfHdr Cur_CaseConfHdr%rowtype;

BEGIN
  op_can_create_case   := 'Y';
  op_error_num         := 0;
  v_case_type          := p_case_type;
  v_case_title         := p_case_title;

  IF p_case_objid      IS NULL AND (p_case_type IS NULL OR p_case_title IS NULL) THEN
    op_can_create_case := 'N';
    op_error_num       := -1;
    op_error_msg       := 'Case conf header obj id or case type and case title are required to verify if case can be created.';
    RETURN;
  END IF;

  IF p_esn       IS NULL THEN
    op_error_num := -1;
    op_error_msg := 'Device ESN is required to verify if case can be created.';
    RETURN;
  END IF;

  OPEN Cur_CaseConfHdr;
  FETCH Cur_CaseConfHdr INTO rec_CaseConfHdr;
  IF Cur_CaseConfHdr%found THEN
    v_case_reopen      := rec_CaseConfHdr.X_BLOCK_REOPEN;
    v_case_reopen_days := rec_CaseConfHdr.X_REOPEN_DAYS_CHECK;
    v_case_title       := rec_CaseConfHdr.s_x_title;
    v_case_type        := rec_CaseConfHdr.s_x_case_type;
    --check if case can be created.
    IF(v_case_reopen      = 1) THEN -- case cannot be reopened, so we can create new case
      op_can_create_case := 'Y';
      op_error_num       := 0;
    ELSE
      IF(v_case_reopen = 0) THEN -- case can be reopened
        OPEN Cur_OldCase;
        FETCH Cur_OldCase INTO rec_OldCase;
        IF Cur_OldCase%notfound THEN -- there is no similar old case found, so we can create new case
          op_can_create_case := 'Y';
          op_error_num       := 0;
        ELSE -- similar old case which can be reopened is found. cannot create new case.
          op_can_create_case := 'N';
          op_case_id         := rec_OldCase.ID_NUMBER;
          op_error_num       := -1;
          op_error_msg       := 'Existing case '|| rec_OldCase.ID_NUMBER ||' can be re-opened. Cannot create a new case of same type.';
        END IF;
		CLOSE Cur_OldCase;
      END IF;
    END IF;
  ELSE
    op_can_create_case := 'N';
    op_error_num       := -1;
    op_error_msg       := 'Selected Case type:' || v_case_type|| ' and case title:'|| v_case_title || ' not found.';
  END IF;
  CLOSE Cur_CaseConfHdr;
  RETURN;
END can_create_case;

-------------------------------------------------------------------------------------
-- CR56717 - TAS Overnight Ship Exchange Option
-------------------------------------------------------------------------------------
FUNCTION delivery_date_calculation(
    ip_business_days INTEGER,
    ip_date_format   VARCHAR2)
  RETURN VARCHAR2
IS
  delivery_date VARCHAR2(200);
  v_date_format VARCHAR2(40);

BEGIN
  IF ip_date_format IS NULL THEN
    v_date_format   := 'mm/dd/yyyy';
  ELSE
    v_date_format := ip_date_format;
  END IF;
  IF ip_business_days IS NOT NULL THEN
    -- sysdate-1 : to consider trasnaction day into count
    SELECT TO_CHAR( sysdate-1 + MAX(rnum), v_date_format) calc_delivery_date
    INTO delivery_date
    FROM
      (SELECT level rnum FROM dual CONNECT BY level <= 365 ORDER BY 1
      )
    WHERE rownum                        <= ip_business_days
    AND TO_CHAR(sysdate+rnum, 'dy') NOT IN ('sat','sun');
  END IF;
  dbms_output.put_line (' delivery_date ::::' || delivery_date);
  RETURN delivery_date;

EXCEPTION
WHEN OTHERS THEN
  delivery_date:='ERROR - '|| sqlerrm;
  RETURN delivery_date;
END delivery_date_calculation;


FUNCTION exchange_shipping_options(
    ip_domain_type          VARCHAR2,
    ip_is_address_po_box    VARCHAR2,
    ip_delivery_date_format VARCHAR2)
  RETURN exch_shipping_options_tab pipelined
IS

  exch_shipping_options_rslt exchange_shipping_options_rec;
  free_min_business_days     INTEGER;
  free_max_business_days     INTEGER;
  free_est_min_delivery_date VARCHAR2(200);
  free_est_max_delivery_date VARCHAR2(200);
  free_delivery_option       VARCHAR2(1000);
  expedit_business_days      INTEGER;
  expedit_est_delivery_date  VARCHAR2(200);
  expedit_delivery_option    VARCHAR2(1000);
  expedit_dollar_value       VARCHAR2(20);

BEGIN

  SELECT X_MIN_DELIVERY_DAYS
  INTO free_min_business_days
  FROM TABLE_X_EXCH_SHIPPING_DTL
  WHERE x_shipping_category = 'FREE'
  AND x_domain_type         = ip_domain_type;

  SELECT X_MAX_DELIVERY_DAYS
  INTO free_max_business_days
  FROM TABLE_X_EXCH_SHIPPING_DTL
  WHERE x_shipping_category = 'FREE'
  AND x_domain_type         = ip_domain_type;

  SELECT sa.ADFCRM_CASE.delivery_date_calculation(free_min_business_days, ip_delivery_date_format)
  INTO free_est_min_delivery_date
  FROM dual;

  SELECT sa.ADFCRM_CASE.delivery_date_calculation(free_max_business_days,ip_delivery_date_format)
  INTO free_est_max_delivery_date
  FROM dual;

  SELECT X_MAX_DELIVERY_DAYS
  INTO expedit_business_days
  FROM TABLE_X_EXCH_SHIPPING_DTL
  WHERE x_shipping_category = 'EXPEDITE'
  AND x_is_address_po_box   = ip_is_address_po_box
  AND x_domain_type         = ip_domain_type;

  SELECT sa.ADFCRM_CASE.delivery_date_calculation(expedit_business_days,ip_delivery_date_format)
  INTO expedit_est_delivery_date
  FROM dual;

  SELECT X_SHIPPING_PRICE
  INTO expedit_dollar_value
  FROM TABLE_X_EXCH_SHIPPING_DTL
  WHERE x_shipping_category = 'EXPEDITE'
  AND x_is_address_po_box   = ip_is_address_po_box
  AND x_domain_type         = ip_domain_type;

  free_delivery_option     := 'FREE Shipping (' || free_min_business_days ||' -' || free_max_business_days || ' Business Days) Estimated delivery date range: ' || free_est_min_delivery_date || ' , ' || free_est_max_delivery_date || ' approximately.';
  expedit_delivery_option  := 'Expedite Shipping $'||expedit_dollar_value||' (' || expedit_business_days ||' Business Days) Estimated delivery date: ' || expedit_est_delivery_date ;
  dbms_output.put_line (' free_delivery_option ::::' || free_delivery_option);
  dbms_output.put_line (' expedit_delivery_option ::::' || expedit_delivery_option);

  exch_shipping_options_rslt.shipping_option   := free_delivery_option;
  exch_shipping_options_rslt.shipping_category := 'FREE';
  pipe row (exch_shipping_options_rslt);

  exch_shipping_options_rslt.shipping_option   := expedit_delivery_option;
  exch_shipping_options_rslt.shipping_category := 'EXPEDITE';
  pipe row (exch_shipping_options_rslt);

EXCEPTION
WHEN OTHERS THEN
  exch_shipping_options_rslt.shipping_option   := 'ERROR : While getting Shipping Options';
  exch_shipping_options_rslt.shipping_category := 'N/A';
  pipe row (exch_shipping_options_rslt);
  RETURN;
END exchange_shipping_options;

----------------------------------------------------------------------

FUNCTION generate_order_id
  RETURN VARCHAR2
IS
  v_order_id VARCHAR2(100);

BEGIN

  SELECT SEQU_ORDER_ID.nextval ORDER_ID INTO v_order_id FROM dual;
  RETURN v_order_id;

EXCEPTION
WHEN OTHERS THEN
  v_order_id :='-1';
  RETURN v_order_id;

END generate_order_id;

----------------------------------------------------------------------

FUNCTION clean_text_to_compare(
    p_text VARCHAR2)
  RETURN VARCHAR2
IS
  v_cleaned_text VARCHAR2(4000);
BEGIN
  SELECT regexp_replace( REPLACE( REPLACE( REPLACE( REPLACE( lower( p_text ) ,'unit','apt') ,'apartment','apt') ,'suite','apt') ,'ste','apt') ,'(*[ [:space:][:punct:] ]*)','') cleaned_text
  INTO v_cleaned_text
  FROM dual;

  RETURN v_cleaned_text;
EXCEPTION
WHEN OTHERS THEN
  v_cleaned_text := 'NotCleaned';
  RETURN v_cleaned_text;

END clean_text_to_compare;


end adfcrm_case;
/