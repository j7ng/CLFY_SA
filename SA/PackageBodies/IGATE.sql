CREATE OR REPLACE PACKAGE BODY sa."IGATE"
AS
 /*---------------------------------------------------------------------------------------------------------------x
 | Copyright Tracfone Wireless Inc. All rights reserved
 |
 | NAME : SA.Igate package
 | PURPOSE :
 | FREQUENCY:
 | PLATFORMS:
 |
 | REVISIONS:
 | VERSION DATE WHO PURPOSE
 | ------- ---------- ----- ------------------------------------------------------
 | 01/04/05 Novak Lalovic Modified packaged procedures:
 | sp_close_action_item
 | sp_create_action_item and
 | sp_insert_ig_transaction FOR "Over The Air"
 | project (OTA).
 | a) In SP_CREATE_ACTION_ITEM procedure:
 | We populate column X_OTA_TYPE in TABLE_TASK with
 | value 'Queued' - ONLY if current record in
 | TABLE_X_CALL_TRANS is set to 'OTA Activation'
 | (column X_OTA_TYPE) and if carrier is OTA enabled.
 | b) In SP_INSERT_IG_TRANSACTION procedure:
 | We populate column OTA_TYPE in IG_TRANSACTION table
 | with value 'Y' - ONLY if current record in
 | TABLE_X_CALL_TRANS is set to 'OTA Activation'
 | (column X_OTA_TYPE) and if carrier is OTA enabled.
 | c) In SP_CLOSE_ACTION_ITEM procedure:
 | We populate column X_OTA_TYPE in TABLE_TASK with
 | value:
 | 'Success' if p_status = 0 (0 = 'Succeeded')
 | 'Failed' if p_status <> 0 (1 = 'Failed - Closed',
 | 2 = 'Failed - Retail ESN'
 | 3 = 'Failed - NTN')
 | We update TABLE_X_OTA_TRANSACTION and set the value
 | of X_STATUS column to OTA SEND if the transaction
 | is not completed yet
 | 03/23/05 Novak Lalovic Modified packaged procedure SP_CLOSE_ACTION_ITEM:
 | We fail OTA transaction when SA.IGATE transaction
 | fails with status 3 (Failed - NTN)
 | 1.23 03/24/05 Novak Lalovic Modified packaged procedure SP_CLOSE_ACTION_ITEM:
 | Update column last_trans_time on TABLE_PART_INST
 | (MIN record) with SYSDATE for Failed NTN transaction
 | functionality.
 | Added the PVCS revision version number to the file
 | header.
 | 1.25 03/24/05 Novak Lalovic Synchronized the revision version number here
 | and in PVCS to be the same
 | 1.25 03/24/05 Novak Lalovic Synchronized the revision version number here
 | and in PVCS to be the same
 | 1.27 04/14/05 Gerald Pintado CR3895 - Prevent Dummy ESN(010999999999999) from being
 | inserted into ig_transaction
 | 1.28 04/29/05 SL CR3918 - Cingular Single SIM
 | add two columns to ig_transaction
 | source x_cingular_mrkt_info
 | 1.29 04/14/05 Gerald Pintado CR3380 - Added GSM Transmission Profiles.
 | 1.30 06/06/05 Gerald Pintado CR4070-1 - Prevent Dummy ESN(010999999999993) from being
 | inserted into ig_transaction
 | 1.35 10/12/05 Gerald Pintado CR4579 - Allow Carrier Rules by Technology
 | 1.36 11/17/05 Gonzalo Carena CR4749 - Prevent dummy ESNs (010999999991810) tracfone
 | (010999999991820) tracfone
 | (010999999991830) tracfone
 | (010999999991910) net10
 | (010999999991920) net10
 | (010999999991930) net10
 | 1.37 12/15/05 Gonzalo Carena CR4831 - Set expired RUT cases to "Expired" instead of
 | "Closed".
 | from being inserted into ig_transaction
 | 1.38 10/16/05 Novak Lalovic Changes for Cingular Next Available project
 | 1.39 12/30/05 Novak Lalovic Changes for Cingular Next Available project:
 | Added public procedure reopen_case_proc.
 | Procedure is called from SA.IGATE_IN3.RTA_IN to reopen case
 | when carrier with no Tracfone inventory returns message
 | "No Line Available"
 | 1.40 01/04/06 Novak Lalovic Changes for Cingular Next Available project:
 | Modified reopen_case_proc: Add column title to the list
 | of columns to update when updating table_condition.
 | Also changed the text for case_history notes
 | when updating table_case in the same procedure.
 | 1.41 01/05/06 Novak Lalovic Changes for Cingular Next Available project:
 | Added input parameter p_notes to reopen_case_proc
 | procedure to make it more generic. The value will be passed in
 | from the calling program (SA.IGATE_IN3.RTA_IN) instead of
 | to be hardcoded in the procedure.
 | 1.41 01/06/06 Novak Lalovic Changes for Cingular Next Available project:
 | Modified Update table_case statement in reopen_case_proc.
 | Changed the way of how to set the value for case_history column.
 | Modified Update table_condition statement. Added column
 | CONDITION to the list of columns to update and set it's value to 2.
 | 1.41 01/10/06 Novak Lalovic Changes for Cingular Next Available project:
 | The following changes were made in reopen_case_proc procedure:
 | Removed statement to update queue column from update table_case statement.
 | Added case_wip2wipbin column to update table_case statement.
 | Added call to sp_dispatch_case procedure at the end of reopen_case_proc.
 | Added COMMIT statement at the very end of reopen_case_proc.
 | 1.41.1.0 05/09/06 Novak Lalovic Merged changes for:
 | CR4749 and CR5202
 | into CR4588 version.
 | 1.41.1.1 05/10/06 Novak Lalovic Added check for Cingular Next Available flag in sp_insert_ig_transaction.
 | If this flag is turned ON (column value is set to 1) in table_x_parent,
 | we will use the values from columns in x_cingular_mrkt_info table
 | to populate the following columns in ig_transaction table:
 | account_num, market_code, dealer_code, submarketid
 | 1.41.1.2 05/17/06 Vani Adapa CR4981_4982 changes (get the carrier features based on the
 | data_capable flag associated to the esns' part number)
 | 1.41.1.3 05/17/06 Vani Adapa Removed CR4981_82 changes and modified for CR4588
 | Inserting template value into ig_transaction from X_CIMGULAR_MRKT_INFO table
 | for MINC or a Next Available carrier
 | 1.41.1.4 05/17/06 Vani Adapa Merged CR4981_4982 changes
 | 1.41.1.5 05/17/06 Vani Adapa Removed CR4981_4982 changes - Added another fix for CR4588
 | For next available carrier, check should be made if the carrier is in
 | x_next_avail_carrier table and if the order_type='A', then insert the
 | template value from X_CINGULAR_MRKT_INFO
 | 1.41.1.6 05/17/06 Vani Adapa Merged CR4981_4982 changes
 | 1.41.1.7 05/18/06 Vani Adapa Removed CR4981_4982 changes and modified CR4588 to get the template
 | from the new field that is added to X_CINGULAR_MRKT_INFO
 | 1.41.1.8 05/18/06 Vani Adapa Merged CR4981_4982 changes with revision 1.45.1.7
 | 1.37.1.3 06/08/06 Vani Adapa CR5349 - Fix for OPEN_CURSORS
 | 1.41.1.9 05/18/06 Novak Lalovic CR4947
 | Modified INSERT INTO IG_TRANSACTION statement in sp_insert_ig_transaction
 | procedure. From now on ICCID column will be pupulated by X_ICCID from
 | TABLE_SITE_PART instead of X_ICCID in TABLE_X_CALL_TRANS because X_ICCID
 | column in TABLE_X_CALL_TRANS is sometimes NULL.
 | The column ICCID must never be NULL in table IG_TRANSACTION.
 1.41.1.10/1.41.1.11 VAdapa No changes, just the revision
 1.41.1.12 VAdapa Removed the extra close cursor
 | 05/23/06 Novak Lalovic GSM Enhancement project:
 | Added new optional input parameter p_application_system to
 | sp_determine_trans_method and sp_insert_ig_transaction procedures.
 | In both procedures, the value of p_application_system parameter
 | defaults to 'IG' if it is not passed in from the calling programs.
 | 1.41.1.13 07/05/06 NLalovic Merged latest code from production into GSM Enhancement project.
 | 1.41.1.15 07/25/06 NLalovic Created wrapper procedure sp_determine_trans_method to call existing proc
 | sp_determine_trans_method from the Clarify software. OUT parameter in the
 | procedure declaration has to be the last parametar or the procedure can't be
 | called from Clarify.
 | 1.41.1.16/1.17 07/26/06 VAdapa Added meaningful notes to CASE_HISTORY if the case is sucessfully closed.
 | 1.41.1.18 07/31/06 NLalovic Merged CR4902 code (GSM Enhancement) into CR4947 code (T-Mobile status messages)
 | 1.41.1.19 09/08/06 Tianyuan Zhou CR5512 - OVIS Data Prevent Dummy CDMA ESN(02599999999) from being
 /* inserted into ig_transaction
 / 1.41.1.20 01/24/07 VAdapa CR5569-9 EME to remove table_num_scheme ref
 / 1.41.1.20.1.0 04/04/07 VAdapa Cr6125 - Dobson changes
 / 1.41.1.20.1.1 05/09/07 VAdapa Same as in CLFYSIT2 (CR6103 changes)
 / 1.45 06/29/07 VAdapa CR6004
 / 1.46 07/10/07 VAdapa Same as in CLFYSIT2 (with CR6004 -2 changes)
 / 1.47-1.48 07/11/07 ABarrera CR6254 Meid changes. Adding meid hex value using a function to retrieve it
 from table_part_inst or calculate it using meiddectohex function.
 / 1.49 12/06/07 JAmalraj Added hint for function based index IND_ORDER_TYPE3 for cursors o_type_curs
 and o_type_curs2
 x----------------------------------------------------------------------------------
 /* NEW PVCS STRUCTURE /NEW_PLSQL?CODE */
 /*1.0 03/31/08 VAdapa Initial Version (Production copy as of 03/31/08)
 /*1.1 03/31/08 VAdapa CR7387 - SIMC Fixes
 AS
 /*---------------------------------------------------------------------------------------------------------------x
 | Copyright Tracfone Wireless Inc. All rights reserved
 |
 | NAME : SA.Igate package
 | PURPOSE :
 | FREQUENCY:
 | PLATFORMS:
 |
 | REVISIONS:
 | VERSION DATE WHO PURPOSE
 | ------- ---------- ----- ------------------------------------------------------
 | 01/04/05 Novak Lalovic Modified packaged procedures:
 | sp_close_action_item
 | sp_create_action_item and
 | sp_insert_ig_transaction FOR "Over The Air"
 | project (OTA).
 | a) In SP_CREATE_ACTION_ITEM procedure:
 | We populate column X_OTA_TYPE in TABLE_TASK with
 | value 'Queued' - ONLY if current record in
 | TABLE_X_CALL_TRANS is set to 'OTA Activation'
 | (column X_OTA_TYPE) and if carrier is OTA enabled.
 | b) In SP_INSERT_IG_TRANSACTION procedure:
 | We populate column OTA_TYPE in IG_TRANSACTION table
 | with value 'Y' - ONLY if current record in
 | TABLE_X_CALL_TRANS is set to 'OTA Activation'
 | (column X_OTA_TYPE) and if carrier is OTA enabled.
 | c) In SP_CLOSE_ACTION_ITEM procedure:
 | We populate column X_OTA_TYPE in TABLE_TASK with
 | value:
 | 'Success' if p_status = 0 (0 = 'Succeeded')
 | 'Failed' if p_status <> 0 (1 = 'Failed - Closed',
 | 2 = 'Failed - Retail ESN'
 | 3 = 'Failed - NTN')
 | We update TABLE_X_OTA_TRANSACTION and set the value
 | of X_STATUS column to OTA SEND if the transaction
 | is not completed yet
 | 03/23/05 Novak Lalovic Modified packaged procedure SP_CLOSE_ACTION_ITEM:
 | We fail OTA transaction when SA.IGATE transaction
 | fails with status 3 (Failed - NTN)
 | 1.23 03/24/05 Novak Lalovic Modified packaged procedure SP_CLOSE_ACTION_ITEM:
 | Update column last_trans_time on TABLE_PART_INST
 | (MIN record) with SYSDATE for Failed NTN transaction
 | functionality.
 | Added the PVCS revision version number to the file
 | header.
 | 1.25 03/24/05 Novak Lalovic Synchronized the revision version number here
 | and in PVCS to be the same
 | 1.25 03/24/05 Novak Lalovic Synchronized the revision version number here
 | and in PVCS to be the same
 | 1.27 04/14/05 Gerald Pintado CR3895 - Prevent Dummy ESN(010999999999999) from being
 | inserted into ig_transaction
 | 1.28 04/29/05 SL CR3918 - Cingular Single SIM
 | add two columns to ig_transaction
 | source x_cingular_mrkt_info
 | 1.29 04/14/05 Gerald Pintado CR3380 - Added GSM Transmission Profiles.
 | 1.30 06/06/05 Gerald Pintado CR4070-1 - Prevent Dummy ESN(010999999999993) from being
 | inserted into ig_transaction
 | 1.35 10/12/05 Gerald Pintado CR4579 - Allow Carrier Rules by Technology
 | 1.36 11/17/05 Gonzalo Carena CR4749 - Prevent dummy ESNs (010999999991810) tracfone
 | (010999999991820) tracfone
 | (010999999991830) tracfone
 | (010999999991910) net10
 | (010999999991920) net10
 | (010999999991930) net10
 | 1.37 12/15/05 Gonzalo Carena CR4831 - Set expired RUT cases to "Expired" instead of
 | "Closed".
 | from being inserted into ig_transaction
 | 1.38 10/16/05 Novak Lalovic Changes for Cingular Next Available project
 | 1.39 12/30/05 Novak Lalovic Changes for Cingular Next Available project:
 | Added public procedure reopen_case_proc.
 | Procedure is called from IGATE_IN3.RTA_IN to reopen case
 | when carrier with no Tracfone inventory returns message
 | "No Line Available"
 | 1.40 01/04/06 Novak Lalovic Changes for Cingular Next Available project:
 | Modified reopen_case_proc: Add column title to the list
 | of columns to update when updating table_condition.
 | Also changed the text for case_history notes
 | when updating table_case in the same procedure.
 | 1.41 01/05/06 Novak Lalovic Changes for Cingular Next Available project:
 | Added input parameter p_notes to reopen_case_proc
 | procedure to make it more generic. The value will be passed in
 | from the calling program (IGATE_IN3.RTA_IN) instead of
 | to be hardcoded in the procedure.
 | 1.41 01/06/06 Novak Lalovic Changes for Cingular Next Available project:
 | Modified Update table_case statement in reopen_case_proc.
 | Changed the way of how to set the value for case_history column.
 | Modified Update table_condition statement. Added column
 | CONDITION to the list of columns to update and set it's value to 2.
 | 1.41 01/10/06 Novak Lalovic Changes for Cingular Next Available project:
 | The following changes were made in reopen_case_proc procedure:
 | Removed statement to update queue column from update table_case statement.
 | Added case_wip2wipbin column to update table_case statement.
 | Added call to sp_dispatch_case procedure at the end of reopen_case_proc.
 | Added COMMIT statement at the very end of reopen_case_proc.
 | 1.41.1.0 05/09/06 Novak Lalovic Merged changes for:
 | CR4749 and CR5202
 | into CR4588 version.
 | 1.41.1.1 05/10/06 Novak Lalovic Added check for Cingular Next Available flag in sp_insert_ig_transaction.
 | If this flag is turned ON (column value is set to 1) in table_x_parent,
 | we will use the values from columns in x_cingular_mrkt_info table
 | to populate the following columns in ig_transaction table:
 | account_num, market_code, dealer_code, submarketid
 | 1.41.1.2 05/17/06 Vani Adapa CR4981_4982 changes (get the carrier features based on the
 | data_capable flag associated to the esns' part number)
 | 1.41.1.3 05/17/06 Vani Adapa Removed CR4981_82 changes and modified for CR4588
 | Inserting template value into ig_transaction from X_CIMGULAR_MRKT_INFO table
 | for MINC or a Next Available carrier
 | 1.41.1.4 05/17/06 Vani Adapa Merged CR4981_4982 changes
 | 1.41.1.5 05/17/06 Vani Adapa Removed CR4981_4982 changes - Added another fix for CR4588
 | For next available carrier, check should be made if the carrier is in
 | x_next_avail_carrier table and if the order_type='A', then insert the
 | template value from X_CINGULAR_MRKT_INFO
 | 1.41.1.6 05/17/06 Vani Adapa Merged CR4981_4982 changes
 | 1.41.1.7 05/18/06 Vani Adapa Removed CR4981_4982 changes and modified CR4588 to get the template
 | from the new field that is added to X_CINGULAR_MRKT_INFO
 | 1.41.1.8 05/18/06 Vani Adapa Merged CR4981_4982 changes with revision 1.45.1.7
 | 1.37.1.3 06/08/06 Vani Adapa CR5349 - Fix for OPEN_CURSORS
 | 1.41.1.9 05/18/06 Novak Lalovic CR4947
 | Modified INSERT INTO IG_TRANSACTION statement in sp_insert_ig_transaction
 | procedure. From now on ICCID column will be pupulated by X_ICCID from
 | TABLE_SITE_PART instead of X_ICCID in TABLE_X_CALL_TRANS because X_ICCID
 | column in TABLE_X_CALL_TRANS is sometimes NULL.
 | The column ICCID must never be NULL in table IG_TRANSACTION.
 1.41.1.10/1.41.1.11 VAdapa No changes, just the revision
 1.41.1.12 VAdapa Removed the extra close cursor
 | 05/23/06 Novak Lalovic GSM Enhancement project:
 | Added new optional input parameter p_application_system to
 | sp_determine_trans_method and sp_insert_ig_transaction procedures.
 | In both procedures, the value of p_application_system parameter
 | defaults to 'IG' if it is not passed in from the calling programs.
 | 1.41.1.13 07/05/06 NLalovic Merged latest code from production into GSM Enhancement project.
 | 1.41.1.15 07/25/06 NLalovic Created wrapper procedure sp_determine_trans_method to call existing proc
 | sp_determine_trans_method from the Clarify software. OUT parameter in the
 | procedure declaration has to be the last parametar or the procedure can't be
 | called from Clarify.
 | 1.41.1.16/1.17 07/26/06 VAdapa Added meaningful notes to CASE_HISTORY if the case is sucessfully closed.
 | 1.41.1.18 07/31/06 NLalovic Merged CR4902 code (GSM Enhancement) into CR4947 code (T-Mobile status messages)
 | 1.41.1.19 09/08/06 Tianyuan Zhou CR5512 - OVIS Data Prevent Dummy CDMA ESN(02599999999) from being
 /* inserted into ig_transaction
 / 1.41.1.20 01/24/07 VAdapa CR5569-9 EME to remove table_num_scheme ref
 / 1.41.1.20.1.0 04/04/07 VAdapa Cr6125 - Dobson changes
 / 1.41.1.20.1.1 05/09/07 VAdapa Same as in CLFYSIT2 (CR6103 changes)
 / 1.45 06/29/07 VAdapa CR6004
 / 1.46 07/10/07 VAdapa Same as in CLFYSIT2 (with CR6004 -2 changes)
 / 1.47-1.48 07/11/07 ABarrera CR6254 Meid changes. Adding meid hex value using a function to retrieve it
 from table_part_inst or calculate it using meiddectohex function.
 / 1.49 12/06/07 JAmalraj Added hint for function based index IND_ORDER_TYPE3 for cursors o_type_curs
 and o_type_curs2
 x----------------------------------------------------------------------------------
 /* NEW PVCS STRUCTURE /NEW_PLSQL?CODE */
 /*1.0 03/31/08 VAdapa Initial Version (Production copy as of 03/31/08)
 /*1.1 03/31/08 VAdapa CR7387 - SIMC Fixes
 /*1.2 08/22/08 CLindner CR7691 Net10 Rate Plan
 /*1.3 08/26/08 ICanavan CR7320 att order type data using next available table
 /*1.4.1.0 10/13/08 NGuada CR8013 TMO 500K-Portin WebCSR - Phase 5
 /*1.4.1.1 10/23/08 NGuada CR8013 TMO 500K-Portin WebCSR - Phase 5
 /*1.4.1.2 10/23/08 NGuada CR8013 TMO 500K-Portin WebCSR - Phase 5
 /*1.4.1.3 10/27/08 NGuada CR8013 TMO 500K-Portin WebCSR - Phase 5
 /*1.5/1.6 09/08/08 VAdapa CR7814_CDMA_NAVAIL
 /*1.7 10/30/08 ICanavan Merge
 /*1.8 04/24/09 CLindner CR8663 WALMART SURE PAY SWITCH BASEED
 /*1.10 06/10/09 Clinder CR8396
 /*1.11 06/11/09 Clinder STUL
 /*1.12 08/27/09 NGuada BRAND_SEP Separate the Brand and Source System
 /*1.13 10/02/09 SKuthadi CR11527 ST_BUNDLE_II
 /*1.14 10/07/09 ICanavan CR11527 ST_BUNDLE_II
 /*1.15-18 10/12/09 SKuthadi ST_BUNDLE_II merge with production */
 /*1.19 10/16/09 CR12020
 /*1.20-21 11/10/09 SKuthadi CR12155 ST_BUNDLE_III
 /*1.21.1.0 -
 /*1.21.1.1 12/03/09 SKuthadi CR12396 -- insert into addl info table for EPIR only
 /*1.24 02/15/10 CWL CR12874 */
 /*1.25 03/11/10 Skuthadi CR13035 CR12218 -- NTUL new carrrier id T-MOBILE UNLIMITED*/
 /*x----------------------------------------------------------------------------------x*/
 /* 1.1-1.3 ??? ??? */
 /* 1.4-1.8 05/10/10 Skuthadi CR11971 ST GSM */
 /* 1.9 06/22/10 Skuthadi CR12852 Website redesign (WSRD) new case titles
 ST_GSM_II to get old esn from case tales instead of interaction tables
 /* 1.10 07/12/10 Skuthadi ST_GSM_II to insert into new osp_account
 /* 1.11 07/17/10 Skuthadi IPI for straight talk */
 /* 1.12 07/23/10 Skuthadi IG_TX_ADDL_INFO table populated from case and Contact attributes */
 /* 1.15 07/26/10 Pmistry CR13531 Populating IG_TRANSACTION_BUCKET table and new order type 'PAP', 'PCR' and 'ACR' in IG_TRANSACTION
 CR13348 Straight Talk Rate Plan Selection*/
 /* 1.16 08/29/10 Skuthadi CR13094 Rate Plan Change NET10MC */
 /* 1.17 08/31/10 Pmistry CR13531,CR13348 added x_service_plan_id check in rate plan query*/
 /* 1.18 09/15/10 Skuthadi CR13094 Rate Plan Change NET10MC for A, R*/
 /* 1.19 09/16/10 Pmistry CR13531 for ST, and ordertype SIMC and MINC we need to go by site part for Rate plan*/
 /* 1.20 09/17/10 Pmistry CR13531 for ST, and ordertype EC we need to go by site part for Rate plan*/
 /* 1.23 09/28/10 Pmistry CR13890 2 new order type Credit Unlimited and ESN Change Unlimited and
 /* 1.27 10/08/10 NGuada CR13085 Universal Branding
 if Template is SUREPAY and Order type is A-Activation then treate it as AP except for the Order Type*/
 /* 1.30 01/04/11 KAcosta CR14799 In the sp_insert_ig_transaction procedure added a check to see if the ICCID value exists on the site part record
 If it does not exists then retrieve it from the part inst record*/
 /* 1.31 02/17/11 Pmistry CR15565 NT Megacard and 750 Card Rate Plan Selection Update for other features
 /* 1.38 04/18/11 Pmistry CR16193 T528 Rate Plan change */
 /* 1.39 02/24/11 Pmistry CR15035 New Order Type Function and Template Selection for IG_Transaction Population */
 /* 1.40 04/15/11 Skuthadi CR15035 NET10_PAYGO ACTIVATION ENGINE */
 /* 05/17/11 Skuthadi CR15035 NET10_PAYGO Added order type 'E' for checking previous IG_TX in past 1 hr cursor */
 /* 1.41 05/26/11 Skuthadi CR15035 NET10_PAYGO Added PIR,EPIR,IPI for dependent tx rules */
 /* 1.42 06/01/11 Skuthadi CR15035 NET10_PAYGO Merged with prod (data speed change) */
 /* 1.44 06/20/11 CLindner CR15146 CR15144 CR15317 */
 /* 1.45 08/05/11 Pmistry CR17415 PPIR - Partial Beenfits for PIR */
 /* 1.46 08/16/11 Skuthadi CR16308 SPRINT */
 /* 1.49 10/11/11 Pmistry CR17793 ST Upgrade Fix to Remove PPIR */
 /* 1.54 01/25/12 Pmistry/Ymillan CR19552 BYOP (BACKEND RELEASE) */
 /* 1.55 02/08/12 CLindner CR19847 TUNE SA.IGATE */
 /* 1.57/1.58 03/20/2012 YMillan CR19853 NET10 ILD */
 /* 1.67 06/21/2012 ICanavan CR20451 | CR20854: Add TELCEL Brand */
 /* 1.68 02/21/2013 ICanavan CR15434 PORT AUTOMATION */
 /* 1.69 02/25/2013 YMillan CR22487 NET10 homephone */
 ---------------------------------------------------------------------------------------------
 --$RCSfile: IGATE.sql,v $
 --$Revision: 1.481 $
 --$Author: smacha $
 --$Date: 2018/03/27 21:15:56 $
 --$ $Log: IGATE.sql,v $
 --$ Revision 1.481  2018/03/27 21:15:56  smacha
 --$ Merged to CR52744.
 --$
 --$ Revision 1.478  2018/03/19 14:48:06  mdave
 --$ CR55066 hotspot fix in benefit curs
 --$
 --$ Revision 1.477  2018/03/16 22:30:43  mdave
 --$ CR55066
 --$
 --$ Revision 1.476  2018/03/14 15:00:09  smacha
 --$ Merged to REL953 changes.
 --$
 --$ Revision 1.471  2018/03/05 22:31:14  smacha
 --$ Removed dbms_output for ST bucket logic.
 --$
 --$ Revision 1.465  2018/02/23 16:10:11  sgangineni
 --$ CR56512 - Merged with CR52744 changes for 3/20 BAU release
 --$
 --$ Revision 1.464  2018/02/22 21:16:23  spagidala
 --$ Removed error log insert statements
 --$
 --$ Revision 1.458  2018/02/15 19:31:23  spagidala
 --$ Commented error table insert statements
 --$
 --$ Revision 1.457  2018/02/14 23:14:36  smacha
 --$ Merged CR52744 to the latest ver.
 --$
 --$ Revision 1.456  2018/02/07 19:06:44  jcheruvathoor
 --$ CR55886	SafeLink and TracFone Androids are missing Expire Date in Data Units Bucket TMO
 --$
 --$ Revision 1.454  2018/02/02 15:44:53  tbaney
 --$ Added set define off.
 --$
 --$ Revision 1.453  2018/02/02 15:35:12  tbaney
 --$ Merged with production copy.
 --$
 --$ Revision 1.449  2018/01/19 16:44:03  tpathare
 --$ Merged with SM-MLD CR52120
 --$
 --$ Revision 1.444  2018/01/02 15:23:24  abustos
 --$ CR53300 - UnMerge with CR52744
 --$
 --$ Revision 1.435  2017/12/12 16:46:14  abustos
 --$ Correct CR52698 SIMPLE_MOBILE
 --$
 --$ Revision 1.432  2017/12/06 17:26:38  abustos
 --$ Merge with 12/6 prod release
 --$
 --$ Revision 1.426  2017/11/30 22:11:22  tpathare
 --$ Block outbound ig_transaction_buckets on BI, UI.
 --$
 --$ Revision 1.423  2017/11/24 19:26:34  tpathare
 --$ Block outbound ig_transaction_buckets on BI, UI.
 --$
 --$ Revision 1.420  2017/11/20 22:45:54  smacha
 --$ Modified TMO code changes for CR51707.
 --$
 --$ Revision 1.419  2017/11/17 22:31:22  smacha
 --$ Modified CR51707 TMO rate_center_no logic.
 --$
 --$ Revision 1.418  2017/11/15 16:51:13  smacha
 --$ Merged to CR52905.
 --$
 --$ Revision 1.415  2017/11/08 17:05:36  tpathare
 --$ Block outbound ig_transaction_buckets on BI, UI.
 --$
 --$ Revision 1.404  2017/08/31 19:56:11  jcheruvathoor
 --$ CR50242	Port Admin Tool - Claro
 --$
 --$ Revision 1.386  2017/07/14 15:22:52  skota
 --$ Modified
 --$
 --$ Revision 1.385  2017/07/11 22:44:05  skota
 --$ make changes for sm and gsm compensation ans replacement
 --$
 --$ Revision 1.381  2017/07/05 15:59:23  skota
 --$ Modified for the error logging for invalid cursor
 --$
 --$ Revision 1.380  2017/07/05 14:31:25  skota
 --$ Make changes for the AWOP gsm flow for the buckets provisioning
 --$
 --$ Revision 1.378  2017/07/03 16:44:08  skota
 --$ Make chnages for GSM  bucktes population for replacement and awop
 --$
 --$ Revision 1.377  2017/06/30 13:50:57  skota
 --$ Changes made for the AWOP bukcets creation
 --$
 --$ Revision 1.375  2017/06/27 18:51:48  skota
 --$ Make changes for SM and GSM compensation and replacemenrt
 --$
 --$ Revision 1.374  2017/06/27 13:26:18  smeganathan
 --$ CR51296 merged with 6/27 prod release
 --$
 --$ Revision 1.372  2017/06/20 18:12:50  smeganathan
 --$ merged with 6/20 production release
 --$
 --$ Revision 1.370  2017/06/13 21:26:54  smeganathan
 --$ Changes in sending the benefit type for WALLET bucket ID
 --$
 --$ Revision 1.369  2017/06/13 17:36:22  nkandagatla
 --$ Remove warning entries from error table for igatesfgetcarrfeat
 --$
 --$ Revision 1.367  2017/06/06 17:57:48  smeganathan
 --$ Merged code with 6/6 production release
 --$
 --$ Revision 1.366  2017/06/05 20:41:42  tpathare
 --$ Changes to procedure CREATE_SUI_BUCKETS.
 --$
 --$ Revision 1.356  2017/05/08 17:50:59  smeganathan
 --$ Expire old WFM data addons during reactivation
 --$
 --$ Revision 1.355  2017/05/08 16:54:50  smeganathan
 --$ Expire old WFM data addons during reactivation
 --$
 --$ Revision 1.364  2017/06/01 20:46:38  smeganathan
 --$ Added logic to populate discount code in x_esn_promo_hist table
 --$
 --$ Revision 1.354  2017/05/08 16:02:13  smeganathan
 --$ Expire old WFM data addons during reactivation
 --$
 --$ Revision 1.353  2017/05/05 23:04:38  smeganathan
 --$ Expire old WFM data addons during reactivation
 --$
 --$ Revision 1.352  2017/05/04 21:51:21  smeganathan
 --$ Expire old WFM data addons during reactivation
 --$
 --$ Revision 1.351  2017/04/28 20:42:18  smeganathan
 --$ Added brand condition while updating end date in x_account_group_benefit table
 --$
 --$ Revision 1.350  2017/04/27 19:06:06  smeganathan
 --$ Hardcoded line status to Active during Activation or Reactivation or Redemption to get the active carrier profile
 --$
 --$ Revision 1.349  2017/04/20 14:58:16  smeganathan
 --$ added code to update expiry date for ADD on cards in x_account_group_benefit table in create_ig_transaction_buckets procedure
 --$
 --$ Revision 1.348  2017/04/19 22:05:08  smeganathan
 --$ added code to update expiry date for ADD on cards in x_account_group_benefit table in create_ig_transaction_buckets procedure
 --$
 --$ Revision 1.347  2017/04/17 15:56:57  smeganathan
 --$ CR49087 added conditions to insert into ig_transaction_features table
 --$
 --$ Revision 1.346  2017/04/14 22:10:24  smeganathan
 --$ fixes in create_ig_transaction_buckets
 --$
 --$ Revision 1.345  2017/04/14 20:04:37  smeganathan
 --$ fixes in create_ig_transaction_buckets
 --$
 --$ Revision 1.344  2017/04/14 17:48:36  smeganathan
 --$ Merged CR49087 and CR49490  changes with CR49470 and EME CR49389
 --$
 --$ Revision 1.343  2017/04/14 15:30:16  smeganathan
 --$ CR49087 changes in create_ig_transaction_buckets to get add on data for BI
 --$
 --$ Revision 1.342  2017/04/12 18:46:37  smeganathan
 --$ Changes in get_ig_transaction_features function
 --$
 --$ Revision 1.341  2017/04/12 17:37:56  smeganathan
 --$ Changes in get_ig_transaction_features function
 --$
 --$ Revision 1.340  2017/04/11 22:08:53  abustos
 --$ CR49470 - Changes for DATA Saver
 --$
 --$ Revision 1.339  2017/04/11 16:34:27  abustos
 --$ EME CR49389 - Configure new rate plans to deliver buckets. TF_4G_TB_MBB_PP_1Q, TF_TB_MBB_PP_1P
 --$
 --$ Revision 1.338  2017/04/06 19:48:41  sgangineni
 --$ CR47564 - WFM code merge with Rel_854 SUI changes
 --$
 --$ Revision 1.337  2017/04/05 22:40:15  smeganathan
 --$ Code fix in create_ig_transaction_buckets
 --$
 --$ Revision 1.332  2017/03/23 16:04:47  sgangineni
 --$ CR47564 - WFM Changes
 --$
 --$ Revision 1.320  2017/03/08 16:18:15  smeganathan
 --$ Merge WFM changes with 3/8 production release
 --$
 --$ Revision 1.319  2017/03/03 21:55:34  smeganathan
 --$ CR47564 changes to update cf_profile_id in ig_transaction in the procedure insert_ig_transaction_features
 --$
 --$ Revision 1.318  2017/03/01 02:25:46  sgangineni
 --$ CR47564 - WFM Changes - Added new calling argument in_red_code to SP_SET_CALL_TRANS_EXT calls
 --$
 --$ Revision 1.316  2017/02/28 20:43:17  smeganathan
 --$ added exceptions while inserting gtt for discount list
 --$
 --$ Revision 1.312  2017/02/21 18:50:25  smeganathan
 --$ Merge WFM changes with 2/21 production release
 --$
 --$ Revision 1.313  2017/02/27 15:41:54  vyegnamurthy
 --$ CR47587 merge with prod
 --$
 --$ Revision 1.311  2017/02/17 15:21:53  tbaney
 --$ Merged with 47881.
 --$
 --$ Revision 1.310  2017/02/16 20:24:38  smeganathan
 --$ Merge WFM changes with 2/16 production release
 --$
 --$ Revision 1.307  2017/02/13 22:24:45  smeganathan
 --$ CR47564 changes in get_ig_transaction_features
 --$
 --$ Revision 1.306  2017/02/13 16:10:17  vnainar
 --$ CR47564 procedure create_ig_transaction_buckets modified to populate benefit type from service plan features
 --$
 --$ Revision 1.305  2017/02/09 19:56:21  vyegnamurthy
 --$ Merger with prod and CR46950 47881
 --$
 --$ Revision 1.304  2017/02/09 16:09:23  smeganathan
 --$ Merged CR47564 changes with 2/9 prod release
 --$
 --$ Revision 1.303  2017/02/08 23:41:03  smeganathan
 --$ CR47564 changes for WFM discounts
 --$
 --$ Revision 1.302  2017/02/08 19:41:30  rpednekar
 --$ CR48114 - Added power (2,28) back in transaction id sequence.
 --$
 --$ Revision 1.301  2017/02/08 16:36:33  smeganathan
 --$ Merged CR47564 changes with 2/8 prod release
 --$
 --$ Revision 1.300  2017/02/07 20:58:30  smeganathan
 --$ WFM Discount changes
 --$
 --$ Revision 1.297  2017/02/02 20:44:05  sraman
 --$ CR 47564 - WFM - Begin- Change service plan if customer is on talk and text but has an add-on
 --$
 --$ Revision 1.296  2017/02/02 20:00:15  sraman
 --$ CR 47564 - WFM - Begin- Change service plan if customer is on talk and text but has an add-on
 --$
 --$ Revision 1.295  2017/01/26 17:34:11  rpednekar
 --$ CR47743 - Commented adding power(2,28) in transaction id sequence.
 --$
 --$ Revision 1.294  2017/01/24 22:15:37  smeganathan
 --$ overloading sp_set_action_item_ig_trans with discount codes in table type
 --$
 --$ Revision 1.292  2017/01/23 15:38:15  rpednekar
 --$ CR46807 - Replaced Private global variable with out parameter.
 --$
 --$ Revision 1.291  2017/01/17 15:09:23  vlaad
 --$ Merged with 1/17 Prod release
 --$
 --$ Revision 1.278  2016/12/14 17:33:16  rpednekar
 --$ CR45740 - Changes to data saver flags
 --$
 --$ Revision 1.276  2016/12/12 22:09:24  rpednekar
 --$ CR45740 - SUI changes.
 --$
 --$ Revision 1.273  2016/12/09 14:58:57  rpednekar
 --$ CR45740 - SUI chagnes for data saver and CR46960 changes for data promotion
 --$
 --$ Revision 1.269  2016/12/01 17:31:37  rpednekar
 --$ CR45740
 --$
 --$ Revision 1.261  2016/11/16 21:11:08  rpednekar
 --$ CR46315 - All merged
 --$
 --$ Revision 1.258  2016/11/15 23:10:03  vlaad
 --$ Merged with CR46315 and CR46357 and CR42459 (SUI)
 --$
 --$ Revision 1.257  2016/11/15 20:03:09  rpednekar
 --$ CR46315
 --$
 --$ Revision 1.256  2016/11/15 17:39:02  rpednekar
 --$ CR46315
 --$
 --$ Revision 1.253  2016/11/14 23:25:43  rpednekar
 --$ CR46315
 --$
 --$ Revision 1.246  2016/11/11 18:05:05  rpednekar
 --$ CR46315
 --$
 --$ Revision 1.237  2016/10/25 19:34:35  vyegnamurthy
 --$ Production merge
 --$
 --$ Revision 1.225 2016/10/03 14:11:42 vyegnamurthy
 --$ CR44801
 --$
 --$ Revision 1.223 2016/09/26 21:09:00 clinder
 --$ CR44221
 --$
 --$ Revision 1.220 2016/08/05 18:30:05 clinder
 --$ CR44221
 --$
 --$ Revision 1.219 2016/07/28 12:58:49 clinder
 --$ CR44291
 --$
 --$ Revision 1.218 2016/07/26 21:53:25 clinder
 --$ CR44291
 --$
 --$ Revision 1.217 2016/07/26 21:37:59 clinder
 --$ CR44291
 --$
 --$ Revision 1.216 2016/07/20 22:29:52 clinder
 --$ CR44291
 --$
 --$ Revision 1.215 2016/07/20 20:57:37 clinder
 --$ CR44291
 --$
 --$ Revision 1.214 2016/07/07 20:21:10 abustos
 --$ EME add rate plans to bi transaction
 --$
 --$ Revision 1.213 2016/06/27 21:03:56 clinder
 --$ CR40522
 --$
 --$ Revision 1.212 2016/06/16 19:49:25 clinder
 --$ CR40522
 --$
 --$ Revision 1.211 2016/06/14 22:17:40 clinder
 --$ CR40522
 --$
 --$ Revision 1.210 2016/06/13 15:45:51 clinder
 --$ CR40522
 --$
 --$ Revision 1.209 2016/06/13 13:05:47 clinder
 --$ CR40522
 --$
 --$ Revision 1.208 2016/06/10 15:52:47 clinder
 --$ CR40522
 --$
 --$ Revision 1.207 2016/06/09 16:22:05 clinder
 --$ CR40522
 --$
 --$ Revision 1.206 2016/05/11 21:09:26 jpena
 --$ Added new function calls to avoid hard-coding.
 --$
 --$ Revision 1.203 2016/03/17 21:36:33 vnainar
 --$ CR39197 code merged with CR41433
 --$
 --$ Revision 1.202 2016/03/03 19:58:37 vnainar
 --$ CR41433 CR39267 code commented
 --$
 --$ Revision 1.201 2016/03/03 19:46:54 vyegnamurthy
 --$ CR41433 SL VZ upgrades
 --$
 --$ Revision 1.200 2016/02/15 21:28:41 vnainar
 --$ CR39197 defect 202 fix order type EC added
 --$
 --$ Revision 1.199 2016/02/04 13:21:19 snulu
 --$ For CR39197- Production Merge
  --$
  --$ Revision 1.198  2016/02/01 07:25:47  usivaraman
  --$ CR39197 - Detach ICC Id
  --$
  --$ Revision 1.197  2016/01/12 21:34:05  jpena
  --$ Fix for choosing the correct rate plan. Post-production issue.
  --$
  --$ Revision 1.196  2015/12/29 19:13:52  vnainar
  --$ CR38927 merged with 1.195 version
  --$
  --$ Revision 1.195  2015/12/17 18:59:34  ddevaraj
  --$ CR38551
  --$
  --$ Revision 1.174  2015/09/28 13:19:23  vnainar
  --$ CR30925 language field logic updated
  --$
  --$ Revision 1.173  2015/09/24 15:34:14  vnainar
  --$ CR30457 changes for language field
  --$
  --$ Revision 1.171  2015/09/21 15:50:19  vyegnamurthy
  --$ CR30457
  --$
  --$ Revision 1.169  2015/09/11 20:24:26  pvenkata
  --$ CR33090-E911--DIGITAL_FEATURE = Y ,DIGITAL_FEATURE_CODE = WFC
  --$
  --$ Revision 1.168  2015/08/25 14:03:12  pvenkata
  --$ CR33090
  --$
  --$ Revision 1.167  2015/08/06 17:33:16  rpednekar
  --$ Commented one condition in cursors cu_bucket_details and cu_bkt_dtl_without_case_dtl
  --$
  --$ Revision 1.166  2015/07/28 20:51:13  rpednekar
  --$ Changes done for CR36735 added conditions before inserting  into ig_transaction_buckets table.
  --$
  --$ Revision 1.165  2015/07/17 20:36:30  jpena
  --$ changes to remove debugging on igate for migration.
  --$
  --$ Revision 1.162  2015/06/24 17:57:49  clinder
  --$ CR35468
  --$
  --$ Revision 1.161  2015/06/23 19:06:37  clinder
  --$ CR35468
  --$
  --$ Revision 1.160  2015/06/23 14:41:36  vyegnamurthy
  --$ CR35468
  --$
  --$ Revision 1.159  2015/06/10 18:38:23  pvenkata
  --$ CR33844-CPO
  --$
  --$ Revision 1.150  2015/05/12 23:36:44  pvenkata
  --$ FIX for CSI
  --$
  --$ Revision 1.148  2015/05/12 21:14:57  pvenkata
  --$ Eliminate the Negative Buckets
  --$
  --$ Revision 1.147  2015/05/12 15:56:41  vyegnamurthy
  --$ *** empty log message ***
  --$
  --$ Revision 1.146  2015/05/11 19:55:55  pvenkata
  --$ NO -ve buckets for the TF andoids
  --$
  --$ Revision 1.145  2015/05/09 18:49:00  pvenkata
  --$ Avoiding the negative buckets for the TF
  --$
  --$ Revision 1.144  2015/05/06 21:06:16  vyegnamurthy
  --$ Modified FUNCTION sf_get_carr_feat (Fix for Defect 1732)
  --$
  --$ Revision 1.143  2015/05/05 20:13:31  vyegnamurthy
  --$ Added the logic to populate the language column in IG_TRANSACTION table
  --$
  --$ Revision 1.142  2015/05/04 20:13:50  vyegnamurthy
  --$ Updated the script to change DATA bucket values to display in MB
  --$
  --$ Revision 1.138  2015/04/21 10:50:44  arijal
  --$ CR29587 ATT
  --$
  --$ Revision 1.137  2015/04/20 19:07:42  arijal
  --$ CR29587 ATT
  --$
  --$ Revision 1.136  2015/04/10 16:32:21  arijal
  --$ CR29587 ATT
  --$
  --$ Revision 1.135  2015/04/07 15:02:25  arijal
  --$ CR29587 ATT
  --$
  --$ Revision 1.134  2015/04/06 18:19:56  arijal
  --$ CR29587 ATT
  --$
  --$ Revision 1.133  2015/04/02 18:13:59  arijal
  --$ CR29587 ATT
  --$
  --$ Revision 1.131  2015/03/10 18:35:41  arijal
  --$ CR30864_SOC Removal
  --$
  --$ Revision 1.130  2015/03/07 00:38:27  arijal
  --$ CR30864_SOC Removal
  --$
  --$ Revision 1.129  2015/03/06 21:51:50  clinder
  --$ CR32465
  --$
  --$ Revision 1.127  2015/02/04 15:30:25  clinder
  --$ CR32463
  --$
  --$ Revision 1.126  2015/01/26 22:29:38  clinder
  --$ CR31242
  --$
  --$ Revision 1.125  2014/12/16 19:16:58  clinder
  --$ CR31242
  --$
  --$ Revision 1.124  2014/10/22 16:18:01  clinder
  --$ CR30648
  --$
  --$ Revision 1.123  2014/10/20 19:49:13  clinder
  --$ CR30648
  --$
  --$ Revision 1.122  2014/10/14 17:44:10  cpannala
  --$ CR24865
  --$
  --$ Revision 1.120  2014/10/08 16:27:51  ahabeeb
  --$ CR31128
  --$
  --$ Revision 1.119  2014/10/08 16:27:07  ahabeeb
  --$ CR31128
  --$
  --$ Revision 1.118  2014/10/08 16:15:49  ahabeeb
  --$ CR31128
  --$
  --$ Revision 1.115  2014/09/03 16:09:58  clinder
  --$ CR30338
  --$
  --$ Revision 1.114  2014/09/03 14:28:17  clinder
  --$ CR30338
  --$
  --$ Revision 1.113  2014/09/02 13:33:00  clinder
  --$ CR30338
  --$
  --$ Revision 1.112  2014/08/28 16:17:49  clinder
  --$ CR30338
  --$
  --$ Revision 1.111  2014/06/06 22:03:10  clinder
  --$ CR25988
  --$
  --$ Revision 1.110  2014/06/06 19:59:44  clinder
  --$ CR25988
  --$
  --$ Revision 1.109  2014/05/29 22:55:38  clinder
  --$ CR25988
  --$
  --$ Revision 1.108  2014/05/28 20:59:00  clinder
  --$ CR25988
  --$
  --$ Revision 1.107  2014/05/06 12:50:32  clinder
  --$ CR25846
  --$
  --$ Revision 1.106  2014/05/05 16:20:30  clinder
  --$ CR25846
  --$
  --$ Revision 1.105  2014/04/30 20:51:35  clinder
  --$ CR25846
  --$
  --$ Revision 1.104  2014/03/25 13:34:31  clinder
  --$ CR25846
  --$
  --$ Revision 1.102  2014/01/14 20:58:25  ymillan
  --$ CR27273
  --$
  --$ Revision 1.101  2014/01/14 17:51:00  ymillan
  --$ CR27273
  --$
  --$ Revision 1.99  2014/01/14 17:09:06  ymillan
  --$ CR27273 change order and add cursor paygo for to get rate plan
  --$
  --$ Revision 1.98  2014/01/10 21:36:05  ymillan
  --$ net10 paygo rate plan incorrect
  --$
  --$ Revision 1.97  2013/12/10 14:09:25  clinder
  --$ CR26493
  --$
  --$ Revision 1.96  2013/10/03 14:37:44  clinder
  --$ CR25000
  --$
  --$ Revision 1.95  2013/09/27 21:55:27  clinder
  --$ CR25000
  --$
  --$ Revision 1.94  2013/09/27 20:54:54  clinder
  --$ CR25000
  --$
  --$ Revision 1.93  2013/09/16 18:54:17  clinder
  --$ CR25954
  --$
  --$ Revision 1.92  2013/09/10 22:22:16  mvadlapally
  --$ CR23513 Tf Surepay
  --$
  --$ Revision 1.91  2013/09/10 14:27:01  mvadlapally
  --$ CR23513 TF Surepay
  --$
  --$ Revision 1.88  2013/09/06 16:08:20  mvadlapally
  --$ CR23513 TF Surepay  Modified IG trans buckets expiration date to NULL
  --$
  --$ Revision 1.84  2013/08/31 18:36:15  mvadlapally
  --$ CR23513 TF Surepay change  along with 1.82 changes
  --$
  --$ Revision 1.71  2013/06/18 21:28:54  ymillan
  --$ CR22467
  --$
  --$ Revision 1.70  2013/05/31 19:54:14  ymillan
  --$ CR22467
  --$
  --$ Revision 1.69  2013/02/26 19:44:31  ymillan
  --$ CR22487 NET10 HOMEPHONE
  --$
  --$ Revision 1.68  2013/02/21 19:05:08  icanavan
  --$ change cursor and insert for port automation
  --$
  --$ Revision 1.67  2012/11/16 20:35:44  icanavan
  --$ ACME merge with production
  --$
  --$ Revision 1.65  2012/10/08 21:11:11  kacosta
  --$ CR22266 Igate is creating duplicate action items for CDMA next available
  --$
  --$ Revision 1.64  2012/08/17 15:19:16  icanavan
  --$ added the slash telcel
  --$
  --$ Revision 1.63  2012/07/26 15:46:16  icanavan
  --$ TELCEL DEV1 7/26
  --$
  --$ Revision 1.58  2012/03/22 12:59:02  ymillan
  --$ CR19853
  --$
  --$ Revision 1.57  2012/03/21 21:06:20  ymillan
  --$ CR19853
  --$
  --$ Revision 1.56  2012/02/09 21:35:16  kacosta
  --$ CR19803 Modify SP Close Case package
  --$
  --$ Revision 1.55  2012/02/08 21:17:26  ymillan
  --$ CR19847
  --$
  --$ Revision 1.54  2012/01/27 20:25:45  ymillan
  --$ CR19552 BYOP
  --$
  --$ Revision 1.53  2011/11/15 15:15:28  kacosta
  --$ CR18794 Core Rate Plan Engine Enhancement
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  /*---------------------------------------------------------------------------------------------------------------x
  |                                                                                                               |
  |   x *** CODING STANDARDS *** -----------------------------------------------------------------------------x   |
  |   |CURSORS:          All cursor names must end with suffix "_curs"                                        |   |
  |   |CURSOR RECORDS:   All cursor record variable names must end with suffix "_rec".                        |   |
  |   |VARIABLES:        All other variable names must start with prefix "l_[datatype abbriviation]_"         |   |
  |   |                  i.e. "l_n_" for number variables, "l_c_" for char and varchar,                       |   |
  |   |                  "l_b_" for boolean etc                                                               |   |
  |   |PACKAGE LEVEL VARIABLES: Use prefix  "g_" in front of the name of each package level variable,         |   |
  |   |                  including cursors. "g" stands for GLOBAL.                                            |   |
  |   |PROCEDURES:       All stored procedure names must start with prefix "sp_". RTA_IN is just an           |   |
  |   |                  exception from the rule because it was created long before the coding standards.     |   |
  |   |FUNCTIONS:        All stored function names must start with prefix "f_"                                |   |
  |   |INPUT PARAMETERS: All input parameters to procs and funcs must start with prefix "p_"                  |   |
  |   |                  All input parameters to cursors must start with prefix "c_"                          |   |
  |   |PROCEDURE STARTS: The following comment lines are used to separate start of each procedure from        |   |
  |   |                  the rest of the code to enhance code readability and maintenance:                    |   |
  |   |                  ----------------------------------------                                             |   |
  |   |                  -- ********************************** --                                             |   |
  |   |                  ----------------------------------------                                             |   |
  |   |PROCEDURE CALLS:  The following comment lines are used to separate procedure calls from                |   |
  |   |                  the rest of the code to enhance code readability and maintenance:                    |   |
  |   |                  ---------------------------                                                          |   |
  |   |                  -- *** [procedure_name]                                                              |   |
  |   |                  ---------------------------                                                          |   |
  |   |CURSOR DECLARATION: The following comment lines are used to separate declaration of each cursor        |   |
  |   |                 from the rest of the code to enhance code readability and maintenance:                |   |
  |   |                 -------                                                                               |   |
  |   |                 -- * --                                                                               |   |
  |   |                 -------                                                                               |   |
  |   |RETURN STATEMENTS: The following comment lines are used to separate "RETURN;" statements inside        |   |
  |   |                 the stored procedures from the rest of the code to enhance code readability           |   |
  |   |                 and maintenance:                                                                      |   |
  |   |                 ------------------------                                                              |   |
  |   |                 -- * EXIT PROCEDURE * --                                                              |   |
  |   |                 ------------------------                                                              |   |
  |   |KEY WORDS:       All SQL and PL/SQL key words must be in UPPER case                                    |   |
  |   |DATA ELEMENTS:   The names of all data elements must be in LOWER case                                  |   |
  |   |                 Use underscore "_" between the words in the names for all data elements:              |   |
  |   |                 cursors, records, variables, procedure names... everything.                           |   |
  |   |NOTE:                                                                                                  |   |
  |   |Please use every chance you get to standardize the code in this package using the above standards.     |   |
  |   |If you are working on a specific procedure, take an extra time and standardize it.                     |   |
  |   x-------------------------------------------------------------------------------------------------------x   |
  |                                                                                                               |
  x---------------------------------------------------------------------------------------------------------------*/
  /* SPRINT -- template will be table driven
  -- will be table driven
  cursor surepay_curs(c_esn in varchar2) is
  select 1 cnt
  from table_part_num  pn,
  table_mod_level ml,
  table_part_inst pi,
  table_bus_org   bo
  WHERE 1=1
  and pn.part_num2bus_org    = bo.objid
  and bo.org_id              = 'STRAIGHT_TALK'
  and pn.x_technology        = 'CDMA'         ---CR13085
  and pn.objid               = ml.part_info2part_num
  AND ml.objid               = pi.n_part_inst2part_mod
  and pi.part_serial_no      = c_esn;
  surepay_rec surepay_curs%rowtype;
  */
--cr40522
 private_global_task_objid number := null;
--cr40522
 CURSOR task_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_task WHERE objid = c_objid;
  --
  CURSOR case_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_case WHERE objid = c_objid;
  --
  CURSOR task2_curs(c_task_id IN NUMBER)
  IS
    SELECT * FROM table_task WHERE task_id = c_task_id;
  --
  CURSOR task3_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_task WHERE x_task2x_call_trans = c_objid;
  --
  CURSOR order_type_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_order_type WHERE objid = c_objid;
  --
  CURSOR trans_profile_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_trans_profile WHERE objid = c_objid;
  --
  CURSOR carrier_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_carrier WHERE objid = c_objid;
  --
  CURSOR carrier_group_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_carrier_group WHERE objid = c_objid;
  --
  CURSOR parent_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_parent WHERE objid = c_objid;
  --
  CURSOR call_trans_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_call_trans WHERE objid = c_objid;
  --
  CURSOR site_part_curs(c_objid IN NUMBER)
  IS
    SELECT sp.*,
      (SELECT pi.n_part_inst2part_mod --CR25000
      FROM table_part_inst pi
      WHERE pi.part_serial_no = sp.x_service_id
      ) n_part_inst2part_mod
  FROM table_site_part sp
  WHERE objid = c_objid;
  --
  --CR20451 | CR20854: Add TELCEL Brand  added the org_flow 1 is TF 2 is NT 3 is ST and TC
  CURSOR part_num_curs(c_objid IN NUMBER)
  IS
    SELECT pn.* ,
      NVL(
      (SELECT to_number(v.x_param_value)
      FROM table_x_part_class_values v,
        table_x_part_class_params n
      WHERE 1                 =1
      AND v.value2part_class  = pn.part_num2part_class
      AND v.value2class_param = n.objid
      AND n.x_param_name      = 'DATA_SPEED'
      AND rownum              <2
      ),NVL(pn.x_data_capable, 0)) data_speed,
      /*CR25772 change x_data_capable to data_speed */
      bo.org_id ,
      bo.org_flow
    FROM table_part_num pn ,
      table_mod_level ml ,
      table_bus_org bo
    WHERE pn.objid          = ml.part_info2part_num
    AND ml.objid            = c_objid
    AND pn.part_num2bus_org = bo.objid;
    --
    CURSOR user_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_user WHERE objid = c_objid;
    --
    CURSOR hr_curs(c_objid IN NUMBER)
    IS
      SELECT wh.*
      FROM table_work_hr wh ,
        table_wk_work_hr wwh
      WHERE wh.work_hr2wk_work_hr = wwh.objid
      AND wwh.objid               = c_objid;
    --
    CURSOR condition_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_condition WHERE objid = c_objid;
    --
    CURSOR queue_curs(c_title IN VARCHAR2)
    IS
      SELECT * FROM table_queue WHERE title = c_title;
    --
    CURSOR queue2_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_queue WHERE objid = c_objid;
    --
    CURSOR user2_curs(c_login_name IN VARCHAR2)
    IS
      SELECT * FROM table_user WHERE s_login_name = UPPER(c_login_name);
    --
    CURSOR employee_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_employee WHERE employee2user = c_objid;
    --
    CURSOR gbst_lst_curs(c_title IN VARCHAR2)
    IS
      SELECT * FROM table_gbst_lst WHERE title LIKE c_title;
    --
    CURSOR gbst_elm_curs ( c_objid IN NUMBER ,c_title IN VARCHAR2 )
    IS
      SELECT *
      FROM table_gbst_elm
      WHERE gbst_elm2gbst_lst = c_objid
      AND title LIKE c_title;
    --
    CURSOR gbst_elm_curs2(c_objid IN NUMBER)
    IS
      SELECT * FROM table_gbst_elm WHERE objid = c_objid;
    --
    CURSOR code_curs(c_code_name IN VARCHAR2)
    IS
      SELECT * FROM table_x_code_table WHERE x_code_name LIKE c_code_name;
    --
    CURSOR current_user_curs
    IS
      SELECT USER FROM dual;
    --
    /* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
    CURSOR provider_curs (c_objid IN NUMBER)
    IS
    SELECT *
    FROM TABLE_X_LD_PROVIDER
    WHERE objid = c_objid;
    --*/
    CURSOR part_inst_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_part_inst WHERE x_part_inst2site_part = c_objid;
    --
    CURSOR part_inst2_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_part_inst WHERE objid = c_objid;
    --
    CURSOR wipbin_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_wipbin WHERE wipbin_owner2user = c_objid;
    --
    /* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
    --  wipbin_rec wipbin_curs%rowtype;
    --    CURSOR contact6_curs (c_objid IN NUMBER)
    --    IS
    --       SELECT *
    --         FROM MTM_SITE_PART22_CONTACT6
    --        WHERE site_part2contact = c_objid;
    */
    --
    CURSOR contact_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_contact WHERE objid = c_objid;
    --
    CURSOR contact_role_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_contact_role WHERE contact_role2site = c_objid;
    --
    CURSOR site_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_site WHERE objid = c_objid;
    --
    CURSOR address_curs(c_objid IN NUMBER)
    IS
      SELECT * FROM table_address WHERE objid = c_objid;
    --
    CURSOR site2_curs(c_objid IN NUMBER)
    IS
      SELECT s.*
      FROM table_site s ,
        table_inv_bin ib
      WHERE s.site_id = ib.bin_name
      AND ib.objid    = c_objid;
    --
    --/* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
    --    CURSOR click_plan_hist_curs (c_objid IN NUMBER)
    --    IS
    --       SELECT *
    --         FROM TABLE_X_CLICK_PLAN_HIST
    --        WHERE plan_hist2site_part = c_objid;
    --/* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
    --    CURSOR click_plan_curs (c_objid IN NUMBER)
    --    IS
    --       SELECT *
    --         FROM TABLE_X_CLICK_PLAN
    --        WHERE objid = c_objid;
    --
    /* Clean-up, this cursor is OBSOLETE, removing the reference of this cursor in the code Feb 01, 2011
    CURSOR account_hist_curs (c_objid IN NUMBER)
    IS
    SELECT *
    FROM TABLE_X_ACCOUNT_HIST
    WHERE account_hist2part_inst = c_objid;
    --
    CURSOR account_curs (c_objid IN NUMBER)
    IS
    SELECT *
    FROM TABLE_X_ACCOUNT
    WHERE objid = c_objid;
    --
    */
    --CR4981_4982 Start
    -- GSM2 START
    --    CURSOR carrier_features_curs (c_objid IN NUMBER, p_tech IN VARCHAR2)
    --    IS
    --     SELECT *
    --     FROM table_x_carrier_features
    --     WHERE x_feature2x_carrier = c_objid
    --     AND x_technology = p_tech;
    -- GSM2 END
    --cwl 6/20/11  CR15146 CR15144 CR15317
    CURSOR alt_carrier_features_curs(c_objid IN NUMBER)
    IS
      SELECT cf.*
      FROM table_x_carrier_features cf
      WHERE x_feature2x_carrier = c_objid;
    --cwl 6/20/11
    CURSOR carrier_features_curs ( c_objid IN NUMBER ,p_tech IN VARCHAR2 ,p_brand_name IN VARCHAR2 ,p_data IN NUMBER )
    IS
      SELECT cf.*
      FROM table_x_carrier_features cf ,
        table_bus_org bo
      WHERE x_feature2x_carrier = c_objid
      AND x_technology          = p_tech
      AND bo.objid              = cf.x_features2bus_org
      AND bo.org_id             = p_brand_name
      AND x_data                = NVL(p_data ,0);
    --CR4981_4982 End
    --CR4579
    CURSOR c_get_part_inst(c_serial_no IN VARCHAR2)
    IS
      SELECT * FROM table_part_inst WHERE part_serial_no = c_serial_no;
    -- CR4579 End
    /*
    -- SPRINT STARTS
    CURSOR get_parent_curs (c_objid IN NUMBER)
    IS
    SELECT p.*
    FROM TABLE_X_PARENT p, TABLE_X_CARRIER_GROUP g, TABLE_X_CARRIER c
    WHERE p.objid = g.x_carrier_group2x_parent
    AND g.objid = c.carrier2carrier_group
    AND c.objid = c_objid ;                   --p_x_call_trans2carrier;
    get_parent_rec            get_parent_curs%ROWTYPE;
    -- SPRINT ENDS
    */


 --CR55859 - Function to check whether buckets values should be inserted for hotspot and byot devices.
 FUNCTION get_hotspot_buckets_flag ( i_bus_org    IN table_x_carrier_features.x_features2bus_org%TYPE,
                                     i_parent_id  IN table_x_parent.x_parent_id%TYPE,
                                     i_rate_plan  IN table_x_carrier_features.x_rate_plan%TYPE ) RETURN VARCHAR2
 IS

   l_count  NUMBER := 0;
   l_return VARCHAR2(1) := 'N';

 BEGIN

    SELECT COUNT(1)
      INTO l_count
      FROM table_x_carrier_features feat,
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c,
           x_rate_plan rp
     WHERE 1=1
       AND c.objid  = X_FEATURE2X_CARRIER
       AND c.carrier2carrier_group     = cg.objid
       AND cg.x_carrier_group2x_parent = p.objid
       AND rp.x_rate_plan = feat.x_rate_plan
       AND x_is_swb_carrier = 1
       AND rp.hotspot_buckets_flag = 'Y'
       AND feat.x_rate_plan = i_rate_plan
       AND feat.X_FEATURES2BUS_ORG = i_bus_org
       AND x_parent_id = i_parent_id;

    IF l_count > 0 THEN
        l_return := 'Y';
    ELSE
        l_return := 'N';
    END IF;

    dbms_output.put_line('get_hotspot_buckets_flag - l_return:'||l_return );
    RETURN l_return;

 EXCEPTION
  WHEN OTHERS THEN
      RETURN 'N';
 END get_hotspot_buckets_flag;


 --CR52905 - Function to check if bucket is active in ig_buckets.
 FUNCTION get_ig_buckets_active_flag ( in_rate_plan  IN VARCHAR2,
                                       in_bucket_id  IN VARCHAR2 ) RETURN VARCHAR2
 IS
   c_active_flag ig_buckets.active_flag%TYPE;
 BEGIN
    -- Get the active flag
    SELECT active_flag
    INTO c_active_flag
    FROM ig_buckets
    WHERE rate_plan = in_rate_plan
    AND bucket_id   = in_bucket_id;

    RETURN c_active_flag;

 EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    RETURN 'Y';
  WHEN OTHERS THEN
    RETURN 'N';
 END get_ig_buckets_active_flag;

 --CR52905 - Function to check if buckets should be created for the IG order type
 FUNCTION get_create_buckets_flag (in_order_type IN VARCHAR2) RETURN VARCHAR2
 IS
   c_create_buckets_flag  x_ig_order_type.create_buckets_flag%TYPE;
 BEGIN
    --Get the bucket creation flag
   SELECT NVL(create_buckets_flag, 'YES')
   INTO c_create_buckets_flag
   FROM x_ig_order_type
   WHERE x_programme_name = 'SP_INSERT_IG_TRANSACTION'
   AND   x_ig_order_type  = in_order_type
   AND   ROWNUM = 1;

   RETURN c_create_buckets_flag;

 EXCEPTION
  WHEN OTHERS THEN
    RETURN 'YES';
 END get_create_buckets_flag;

--CR46315
	FUNCTION sf_promo_check(
	p_promo_objid   	IN VARCHAR2 ,
	p_esn           	IN VARCHAR2 ,
	p_service_plan_id  	IN VARCHAR2,
	p_transaction		IN VARCHAR2
	)
	RETURN NUMBER
	IS
		CURSOR cur_promo_detail
		IS
		SELECT * FROM table_x_promotion WHERE objid = p_promo_objid;
		rec_promo_detail cur_promo_detail%ROWTYPE;
		l_sql_statement VARCHAR2(4000);
		l_cursor        INTEGER;
		l_result_cursor INTEGER;
		l_bind_var      VARCHAR2(200);
		l_counter       VARCHAR2(200);
	BEGIN
		OPEN cur_promo_detail;
		FETCH cur_promo_detail INTO rec_promo_detail;
		CLOSE cur_promo_detail;
		dbms_output.put_line('1');
		IF rec_promo_detail.x_sql_statement IS NOT NULL THEN
		-- Open Cursor.
		l_sql_statement := rec_promo_detail.x_sql_statement;
		dbms_output.put_line('2:' || rec_promo_detail.x_sql_statement);
		l_cursor := dbms_sql.open_cursor;
		-- Parse SQL Statement.
		dbms_sql.parse(l_cursor ,l_sql_statement ,dbms_sql.v7);
		dbms_output.put_line('3');
		-- Bind Variables.
		l_bind_var                                   := ':p_esn';
		IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
		dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_esn);
		END IF;
		l_bind_var := ':p_service_plan_id';
		dbms_output.put_line('4');
		IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
		dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_service_plan_id);
		END IF;
		l_bind_var := ':p_transaction';
		dbms_output.put_line('5');
		IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
		dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_transaction);
		END IF;
		l_bind_var := ':promo_objid';
		dbms_output.put_line('6');
		IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
		dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_promo_objid);
		END IF;
		-- describe defines
		dbms_sql.define_column(l_cursor ,1 ,l_counter ,10);
		dbms_output.put_line('7');
		-- Execute SQL.
		l_result_cursor := dbms_sql.execute(l_cursor);
		-- Fetch result.
		dbms_output.put_line('8');
		IF NVL(dbms_sql.fetch_rows(l_cursor) ,0) > 0 THEN
		dbms_sql.column_value(l_cursor ,1 ,l_counter);
		dbms_output.put_line('9:' || l_counter);
		END IF;
		dbms_sql.close_cursor(l_cursor); --CL EM "Open Cursor Issue" 07/26/2012
		-----------===============
		END IF;
		IF TO_NUMBER(l_counter) > 0 THEN
		RETURN 1;
		ELSE
		RETURN 0;
		END IF;
	END sf_promo_check;
PROCEDURE SP_GET_ELIGIBLE_PROMO
(p_promo_type			VARCHAR2
,p_esn				VARCHAR2
,p_calltrans_objid		VARCHAR2
,p_action_type			VARCHAR2
,p_ig_order_type		VARCHAR2
,op_promo_code		OUT	VARCHAR2
,op_promo_objid		OUT	VARCHAR2
,op_error_code		OUT	VARCHAR2
,op_error_msg		OUT	VARCHAR2
)
IS
	CURSOR cur_esn_detail
	IS
	SELECT bo.org_id brand_name ,
	pi.*
	FROM table_part_inst pi ,
	table_mod_level ml ,
	table_part_num pn ,
	table_bus_org bo
	WHERE 1            = 1
	AND part_serial_no = p_esn
	--and    x_part_inst_status = '52'
	AND ml.objid = pi.n_part_inst2part_mod
	AND pn.objid = ml.part_info2part_num
	AND bo.objid = pn.part_num2bus_org;
	rec_esn_detail cur_esn_detail%ROWTYPE;
	CURSOR cur_active_promos(c_brand_name VARCHAR2)
	IS
	SELECT 	p.*
	FROM table_x_promotion p ,
	table_bus_org bo
	WHERE 1          = 1
	AND x_promo_type = 	p_promo_type
	AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
	AND bo.objid       = p.promotion2bus_org
	AND bo.org_id      = c_brand_name
	;
	lv_service_plan_objid	NUMBER;
	lv_transaction_type	VARCHAR2(100);
	l_promo_check		NUMBER;
BEGIN
	OPEN cur_esn_detail;
	FETCH cur_esn_detail INTO rec_esn_detail;
	IF cur_esn_detail%NOTFOUND THEN
		dbms_output.put_line('ESN details not found');
		CLOSE cur_esn_detail;
		RETURN;
	END IF;
	CLOSE cur_esn_detail;
	BEGIN
	SELECT svp.objid
	INTO	lv_service_plan_objid
	FROM table_x_call_trans ct
	,table_part_inst pi
	,table_site_part sp
	,x_service_plan_site_part spsp
	,x_service_plan svp
	WHERE     1	=	1
	AND ct.x_service_id = pi.part_serial_no
	AND ct.objid	=	p_calltrans_objid
	AND pi.x_part_inst2site_part = sp.objid
	AND spsp.x_service_plan_id = svp.objid
	and spsp.table_site_part_id = sp.objid
	AND ROWNUM = 1
	;
	EXCEPTION WHEN OTHERS
	THEN
		lv_service_plan_objid	:=	NULL;
	END;
	IF 	p_ig_order_type IN ( 'A','AP','E') AND p_action_type = '1'
	THEN
		lv_transaction_type	:=	'ACTIVATION';
	ELSIF	p_ig_order_type IN ( 'A','AP','E') AND p_action_type = '3'
	THEN
		lv_transaction_type	:=	'REACTIVATION';
	ELSIF	 p_action_type = '6'
	THEN
		lv_transaction_type	:=	'REDEMPTION';
	ELSIF   p_ig_order_type IN ('PIR','IPI','EPIR','E') AND lv_service_plan_objid IS NOT NULL
	THEN
		lv_transaction_type	:=	'PORT-IN';
	END IF;
	FOR rec_active_promos IN cur_active_promos(rec_esn_detail.brand_name)
	LOOP
		IF rec_active_promos.x_sql_statement IS NOT NULL THEN
	--      dbms_output.put_line('x_sql_statement');
		l_promo_check := sf_promo_check(rec_active_promos.objid ,p_esn ,lv_service_plan_objid ,lv_transaction_type);
	--      dbms_output.put_line('x_sql_statement2');
		IF TO_NUMBER(l_promo_check) > 0 THEN
		op_promo_objid            := rec_active_promos.objid;
		op_promo_code             := rec_active_promos.x_promo_code;
			dbms_output.put_line('rec_active_promos.objid:' || rec_active_promos.objid);
			dbms_output.put_line('p_esn:' || p_esn);
			dbms_output.put_line('REC_ACTIVE_PROMOS.objid:' || rec_active_promos.objid);
		RETURN;
		ELSE
		dbms_output.put_line('promo fails:' || l_promo_check);
		END IF;
		END IF;
	END LOOP;
EXCEPTION WHEN OTHERS
THEN
NULL;
END SP_GET_ELIGIBLE_PROMO;
PROCEDURE SP_INS_ESN_PROMO_HIST(IP_ESN			IN 	VARCHAR2
				,IP_CALLTRANS_ID	IN 	VARCHAR2
				,IP_PROMO_OBJID         IN 	VARCHAR2
				,IP_EXPIRATION_DATE     IN 	VARCHAR2
				,IP_BUCKET_ID           IN 	VARCHAR2
				,OP_ERROR_CODE          OUT 	VARCHAR2
				,OP_ERROR_MSG           OUT 	VARCHAR2
				)
IS
BEGIN
	OP_ERROR_CODE	:=	'0';
	INSERT INTO sa.X_ESN_PROMO_HIST
	(OBJID
	,ESN
	,PROMO_HIST2CALL_TRANS
	,PROMO_HIST2X_PROMOTION
	,INSERT_TIMESTAMP
	,EXPIRATION_DATE
	,BUCKET_ID
	)
	VALUES
	(sa.sequ_esn_promo_hist_objid.nextval
	,IP_ESN
	,IP_CALLTRANS_ID
	,IP_PROMO_OBJID
	,SYSDATE
	,IP_EXPIRATION_DATE
	,IP_BUCKET_ID
	);
EXCEPTION WHEN OTHERS
THEN
	OP_ERROR_CODE	:=	'99';
	OP_ERROR_MSG	:=	'Exception SP_INS_ESN_PROMO_HIST '
					||sqlerrm
					;
END;
PROCEDURE update_promo_hist(IP_ESN 			VARCHAR2
			,OP_ERROR_CODE          OUT 	VARCHAR2
			,OP_ERROR_MSG           OUT 	VARCHAR2
			)
IS
ctp      case_type := case_type();
ct       case_type := case_type();
BEGIN
	OP_ERROR_CODE	:=	'0';
          ctp := case_type ();
          ct  := case_type ();
          -- call case type member function to get the latest case data
          ct := ctp.get ( i_esn        => IP_ESN ,
                          i_case_title => '%PHONE%UPGRADE%' );
          IF ct.reference_esn IS NOT NULL
	  THEN
		INSERT INTO sa.X_ESN_PROMO_HIST
		(OBJID
		,ESN
		,PROMO_HIST2CALL_TRANS
		,PROMO_HIST2X_PROMOTION
		,INSERT_TIMESTAMP
		,EXPIRATION_DATE
		,BUCKET_ID
		)
		SELECT
		sa.sequ_esn_promo_hist_objid.nextval
		,IP_ESN
		,PROMO_HIST2CALL_TRANS
		,PROMO_HIST2X_PROMOTION
		,SYSDATE
		,EXPIRATION_DATE
		,BUCKET_ID
		FROM sa.X_ESN_PROMO_HIST
		WHERE ESN = ct.reference_esn
		AND NVL(EXPIRATION_DATE,SYSDATE + 1)	> SYSDATE
		;
		UPDATE sa.X_ESN_PROMO_HIST
		SET EXPIRATION_DATE = SYSDATE
		WHERE ESN = ct.reference_esn
		AND NVL(EXPIRATION_DATE,SYSDATE + 1)	> SYSDATE
		;
	  END IF;
EXCEPTION WHEN OTHERS
THEN
	OP_ERROR_CODE	:=	'99';
	OP_ERROR_MSG	:=	SQLERRM;
END;
--CR46315

    -- Forward declaration starts
  PROCEDURE sp_insert_ig_trans_buckets(
      in_ig_transaction_id IN ig_transaction.transaction_id%TYPE,
      in_ig_rate_plan      IN ig_transaction.rate_plan%TYPE,
      in_ig_bucket_type    IN ig_buckets.bucket_type%TYPE,
      in_bucket_balance    IN NUMBER,
      out_bucket_created  OUT BOOLEAN,
      in_order_type        IN VARCHAR2 DEFAULT NULL --- Added by Rahul for CR
                  );
    -- Forward declaration ends
    ----------------------------------------------------------------------------------------------------
  PROCEDURE sp_create_action_item(
      p_contact_objid     IN NUMBER ,
      p_call_trans_objid  IN NUMBER ,
      p_order_type        IN VARCHAR2 ,
      p_bypass_order_type IN NUMBER ,
      p_case_code         IN NUMBER ,
      p_status_code OUT NUMBER ,
      p_action_item_objid OUT NUMBER )
  IS
    ----------------------------------------------------------------------------------------------------
    --
    r_get_part_inst c_get_part_inst%ROWTYPE; --CR4579
    call_trans_rec call_trans_curs%ROWTYPE;
    site_part_rec site_part_curs%ROWTYPE;
    part_inst_rec part_inst_curs%ROWTYPE;
    site_rec site_curs%ROWTYPE;
    part_num_rec part_num_curs%ROWTYPE;
    user_rec user_curs%ROWTYPE;
    user2_rec user2_curs%ROWTYPE;
    gbst_lst1_rec gbst_lst_curs%ROWTYPE;
    gbst_elm1_rec gbst_elm_curs%ROWTYPE;
    gbst_lst2_rec gbst_lst_curs%ROWTYPE;
    gbst_elm2_rec gbst_elm_curs%ROWTYPE;
    gbst_lst3_rec gbst_lst_curs%ROWTYPE;
    gbst_elm3_rec gbst_elm_curs%ROWTYPE;
    gbst_lst4_rec gbst_lst_curs%ROWTYPE;
    gbst_elm4_rec gbst_elm_curs%ROWTYPE;
    wipbin_rec wipbin_curs%ROWTYPE;
    current_user_rec current_user_curs%ROWTYPE;
    employee_rec employee_curs%ROWTYPE;
    contact_rec contact_curs%ROWTYPE;
    carrier_rec carrier_curs%ROWTYPE;
    carrier_group_rec carrier_group_curs%ROWTYPE;
    l_order_type       VARCHAR2(100);
    boolupgrade        BOOLEAN;
    l_order_type_objid NUMBER;
    trans_profile_rec trans_profile_curs%ROWTYPE;
    order_type_rec order_type_curs%ROWTYPE;
    transstr            VARCHAR2(100);
    l_action_item_id    VARCHAR2(100);
    notesstr            VARCHAR2(1000);
    titlestr            VARCHAR2(1000):= NULL;
    l_condition_objid   NUMBER;
    l_act_entry_objid   NUMBER;
    l_task_objid        NUMBER;
    straddlinfo         VARCHAR2(1000);
    hold                NUMBER;
    hold2               VARCHAR2(200);
    cnt                 NUMBER := 0;
    l_bypass_order_type NUMBER := 0; --CR52744
    l_carrier           table_x_carrier.x_mkt_submkt_name%TYPE := NULL; --CR52744
    l_volte_flag        VARCHAR2(1) := 'N'; --CR52744
    --
    -- OTA flag:
    --
    c_ota_type    VARCHAR2(30);
    l_tasktype_ot VARCHAR2(20); --SIMC FIX
    -- NET10_PAYGO STARTS
    l_is_st_esn NUMBER                                          := 0;
    l_cf_rate_plan sa.table_x_carrier_features.x_rate_plan%TYPE := '';
    l_ig_rate_plan sa.table_x_carrier_features.x_rate_plan%TYPE := '';
    l_cf_objid sa.table_x_carrier_features.objid%TYPE;
    l_new_template gw1.ig_transaction.template%TYPE := '-1';
    carr_feature_rec carrier_features_curs%ROWTYPE;
    -- NET10_PAYGO ENDS
    CURSOR parent_curs_local(p_objid IN NUMBER)
    IS
      SELECT p.*
      FROM table_x_parent p ,
        table_x_carrier_group g ,
        table_x_carrier c
      WHERE p.objid = g.x_carrier_group2x_parent
      AND g.objid   = c.carrier2carrier_group
      AND c.objid   = p_objid; --p_x_call_trans2carrier;
    parent_rec parent_curs_local%ROWTYPE;
    --EME to remove table_num_scheme ref
    new_act_id_format VARCHAR2(100) := NULL;
    --End EME
    --CR6103-2 Begin
    CURSOR c_dummy_data(c_esn IN VARCHAR2)
    IS
      SELECT x_esn FROM x_dummy_data WHERE x_esn = c_esn;
    rec_dummy_data c_dummy_data%ROWTYPE;
    ----------------------------------------------------------------------------------------------------
  BEGIN
    --
    cnt := cnt + 1; --1
    dbms_output.put_line('cnt: call trans check initiated (return status 3 to FE if not found) : ' || cnt);
    OPEN call_trans_curs(p_call_trans_objid);
    FETCH call_trans_curs INTO call_trans_rec;
    IF call_trans_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE call_trans_curs;
     -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE call_trans_curs;
    dbms_output.put_line('cnt:' || cnt || ' call_trans_rec.objid:' || call_trans_rec.objid);
    cnt := cnt + 1; --2
    dbms_output.put_line('cnt: site part check initiated (return if not found) : ' || cnt);
    OPEN site_part_curs(call_trans_rec.call_trans2site_part);
    FETCH site_part_curs INTO site_part_rec;
    IF site_part_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE site_part_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE site_part_curs;
    dbms_output.put_line('cnt:' || cnt || 'site part found, site_part_rec.objid:' || site_part_rec.objid);
    --Clean-up, removed the reference of these cursors contact6_curs, part_inst_curs from this part of the code Feb 01,2011, as it is already commented
    cnt := cnt + 1; --3
    dbms_output.put_line('cnt: site check initiated (return if not found) : ' || cnt);
    OPEN site_curs(site_part_rec.site_part2site);
    FETCH site_curs INTO site_rec;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
    CLOSE site_curs;
    --
    OPEN c_get_part_inst(site_part_rec.x_service_id);
    FETCH c_get_part_inst INTO r_get_part_inst;
    IF c_get_part_inst%notfound THEN
      p_status_code := 3;
      CLOSE c_get_part_inst;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE c_get_part_inst;
    --
    cnt := cnt + 1; --4
    dbms_output.put_line('cnt: part num check initiated (return if not found) : ' || cnt);
    OPEN part_num_curs(r_get_part_inst.n_part_inst2part_mod);
    FETCH part_num_curs INTO part_num_rec;
    IF part_num_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE part_num_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE part_num_curs;
    --Clean-up, removed the reference of these cursors click_plan_hist_curs, click_plan_curs from this part of the code Feb 01,2011, as it is already commented
    cnt := cnt + 1; --5
    dbms_output.put_line('cnt: user check initiated (return if not found) ' || cnt);
    OPEN user_curs(call_trans_rec.x_call_trans2user);
    FETCH user_curs INTO user_rec;
    IF user_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE user_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE user_curs;
    --Clean-up, removed the reference of these cursors task3_curs,account_hist_curs,  account_curs from this part of the code Feb 01,2011, as it is already commented
    cnt := cnt + 1; --6
    dbms_output.put_line('cnt: gbst lst (Activity Name) check initiated (return if not found) :  ' || cnt);
    OPEN gbst_lst_curs('Activity Name');
    FETCH gbst_lst_curs INTO gbst_lst4_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE gbst_lst_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    cnt := cnt + 1; --7
    dbms_output.put_line('cnt: gbst elm (Create Action Item) check initiated (return if not found) : ' || cnt);
    OPEN gbst_elm_curs(gbst_lst4_rec.objid ,'Create Action Item');
    FETCH gbst_elm_curs INTO gbst_elm4_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE gbst_elm_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    cnt := cnt + 1; --8
    dbms_output.put_line('cnt: gbst lst (Open Action Item) check initiated (return if not found) :' || cnt);
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst3_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE gbst_lst_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    cnt := cnt + 1; --9
    dbms_output.put_line('cnt: gbst elm (Created) check initiated (return if not found) : ' || cnt);
    OPEN gbst_elm_curs(gbst_lst3_rec.objid ,'Created');
    FETCH gbst_elm_curs INTO gbst_elm3_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE gbst_elm_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    cnt := cnt + 1; --10
    dbms_output.put_line('cnt: gbst lst (Task Type) check initiated (return if not found) ' || cnt);
    OPEN gbst_lst_curs('Task Type');
    FETCH gbst_lst_curs INTO gbst_lst2_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE gbst_lst_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    cnt := cnt + 1; --11
    dbms_output.put_line('cnt: gbst elm (l_tasktype_ot) check initiated (return if not found) ' || cnt);
    IF p_order_type  = 'Return' THEN
      l_tasktype_ot := 'Deactivation';
    ELSIF p_order_type IN ('SIMC' ,'EC' ,'SI') THEN
      l_tasktype_ot := 'SIM Change';
    ELSIF p_order_type IN ('Act Payment Partial Buckets') THEN
      l_tasktype_ot := 'Activation Payment';
    ELSIF p_order_type IN ('Partial Buckets') THEN
      l_tasktype_ot := 'Credit';
    ELSE
      l_tasktype_ot := p_order_type;
    END IF;
    OPEN gbst_elm_curs(gbst_lst2_rec.objid ,l_tasktype_ot);
    FETCH gbst_elm_curs INTO gbst_elm2_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE gbst_elm_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    cnt := cnt + 1; --12
    dbms_output.put_line('cnt: gbst lst (Task Priority) check initiated (return if not found) ' || cnt);
    OPEN gbst_lst_curs('Task Priority');
    FETCH gbst_lst_curs INTO gbst_lst1_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE gbst_lst_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    cnt := cnt + 1; --13
    dbms_output.put_line('cnt: gbst elm (High) check initiated (return if not found)' || cnt);
    OPEN gbst_elm_curs(gbst_lst1_rec.objid ,'High');
    FETCH gbst_elm_curs INTO gbst_elm1_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE gbst_elm_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    cnt := cnt + 1; --14
    dbms_output.put_line('cnt: current user check initiated (assign appsrv user if not found) : ' || cnt);
    OPEN current_user_curs;
    FETCH current_user_curs INTO current_user_rec;
    IF current_user_curs%NOTFOUND THEN
      current_user_rec.user := 'appsrv'; -- changed from appsvr
   END IF;
    CLOSE current_user_curs;
    dbms_output.put_line('cnt:' || cnt || ' current_user_rec.user:' || current_user_rec.user);
    --
    cnt := cnt + 1; --15
    dbms_output.put_line('cnt: appsrv user check initiated (return if not found) : ' || cnt);
    OPEN user2_curs(current_user_rec.user);
    FETCH user2_curs INTO user2_rec;
    IF user2_curs%NOTFOUND THEN
      CLOSE user2_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      OPEN user2_curs('appsrv');
      FETCH user2_curs INTO user2_rec;
      IF user2_curs%NOTFOUND THEN
        p_status_code := 3;
        CLOSE user2_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        RETURN;
      END IF;
      CLOSE user2_curs;
    ELSE
      CLOSE user2_curs;
    END IF;
    --
    cnt := cnt + 1; --16
    dbms_output.put_line('cnt: wipbin check initiated (return if not found) ' || cnt);
    OPEN wipbin_curs(user2_rec.objid);
    FETCH wipbin_curs INTO wipbin_rec;
    IF wipbin_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE wipbin_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE wipbin_curs;
    --
    cnt := cnt + 1; --17
    dbms_output.put_line('cnt: employee check initiated (return if not found) ' || cnt);
    OPEN employee_curs(user2_rec.objid);
    FETCH employee_curs INTO employee_rec;
    IF employee_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE employee_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE employee_curs;
    --
    cnt := cnt + 1; --18
    dbms_output.put_line('cnt: contact check initiated (return if not found) ' || cnt);
    OPEN contact_curs(p_contact_objid);
    FETCH contact_curs INTO contact_rec;
    IF contact_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE contact_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE contact_curs;
    --
    cnt := cnt + 1; --19
    dbms_output.put_line('cnt: carrier check initiated (return if not found) ' || cnt);
    OPEN carrier_curs(call_trans_rec.x_call_trans2carrier);
    FETCH carrier_curs INTO carrier_rec;
    IF carrier_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE carrier_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE carrier_curs;
    --
    cnt := cnt + 1; --20
    dbms_output.put_line('cnt: carrier group check initiated (return if not found) ' || cnt);
    OPEN carrier_group_curs(carrier_rec.carrier2carrier_group);
    FETCH carrier_group_curs INTO carrier_group_rec;
    IF carrier_group_curs%NOTFOUND THEN
      p_status_code := 3;
      CLOSE carrier_group_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      RETURN;
    END IF;
    CLOSE carrier_group_curs;
    --
    IF contact_rec.x_new_esn = call_trans_rec.x_service_id OR p_order_type = 'Suspend' THEN
      IF contact_rec.mdbk    = 'UPGRADE' THEN
        cnt                 := cnt + 1; --21
        dbms_output.put_line('cnt: gbst elm (High - Upgrade) check initiated (return if not found) : ' || cnt);
        OPEN gbst_elm_curs(gbst_lst1_rec.objid ,'High - Upgrade');
        FETCH gbst_elm_curs INTO gbst_elm1_rec;
        IF gbst_elm_curs%NOTFOUND THEN
          p_status_code := 3;
          CLOSE gbst_elm_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
          RETURN;
        END IF;
        CLOSE gbst_elm_curs;
      END IF;
      IF p_order_type IN ('Activation' ,'ESN Change') THEN
        UPDATE table_contact
        SET x_new_esn = NULL ,
          mdbk        = NULL
        WHERE objid   = contact_rec.objid;
      END IF;
    END IF;
    --
    cnt := cnt + 1; --22
    dbms_output.put_line('cnt: get order type call initiated : ' || cnt);
    c_ota_type := NULL;
    --
    IF call_trans_rec.x_ota_type = ota_util_pkg.ota_activation THEN
      OPEN parent_curs_local(carrier_rec.objid);
      FETCH parent_curs_local INTO parent_rec;
      IF parent_curs_local%notfound THEN
        p_status_code := 3;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        CLOSE parent_curs_local;
        RETURN;
      ELSE
        IF UPPER(parent_rec.x_ota_carrier) = 'Y' THEN
          c_ota_type                      := ota_util_pkg.ota_queued;
        ELSE
          c_ota_type := SUBSTR('1NL' || carrier_rec.objid ,1 ,10);
        END IF;
      END IF;
      CLOSE parent_curs_local;
    END IF;
    dbms_output.put_line('c_ota_type:'||c_ota_type);
    cnt := cnt + 1; --27
    dbms_output.put_line('cnt:' || cnt || 'order_type_rec.X_ORDER_TYPE2X_TRANS_PROFILE:' || order_type_rec.x_order_type2x_trans_profile);

    --CR52744
    l_bypass_order_type := call_trans_rec.x_action_type; --CR52744
    l_carrier := UPPER(carrier_rec.x_mkt_submkt_name); --CR52744

    --CR52744, Get l_bypass_order_type only for verizon activations and reactivations.
    --If l_volte_flag ='Y',Then considered as HD, No HD validation required with the carrier_flags then,l_bypass_order_type is NULL.
    --If Non-HD VZN,then do further validation for the carrier act and react flags, if flag = '1' Then allow act and react for Non-HD VZN.
    IF l_carrier LIKE 'VERIZON%' AND l_bypass_order_type in (1,3) THEN
        l_volte_flag := sa.util_pkg.get_volte_flag(part_num_rec.part_number);
	    dbms_output.put_line ('Verify VOLTE Check -l_volte_flag:'||l_volte_flag);
  	    IF l_volte_flag = 'N' THEN
            l_bypass_order_type := l_bypass_order_type;
	    ELSE
            l_bypass_order_type := NULL;
	    END IF;
    ELSE
       l_bypass_order_type := NULL;
    END IF;
    --
    --ECR25704 create action item without order_type if bypass flag set
    --CR52744, Added new input parameter(l_bypass_order_type) to validate HD and Non_HD for Verizon of sp_get_ordertype.
    dbms_output.put_line ('Before_l_bypass_order_type :'||l_bypass_order_type);
    dbms_output.put_line ('l_carrier :'||l_carrier);
    sp_get_ordertype(site_part_rec.x_min ,p_order_type ,carrier_rec.objid ,part_num_rec.x_technology , l_order_type_objid,l_bypass_order_type);
    dbms_output.put_line ('After_sp_get_ordertype,l_order_type_objid :'||l_order_type_objid);
    --
    IF l_order_type_objid    IS NULL AND NVL(p_bypass_order_type,0) = 1 THEN
      titlestr               := ' FAILED ' || UPPER(p_order_type) || ' FOR ' || UPPER(carrier_rec.x_mkt_submkt_name);
    elsif l_order_type_objid IS NULL THEN
      p_status_code          := 3;
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'l_order_type_objid is null',
          sysdate,
          'sp_get_ordertype('
          ||site_part_rec.x_min
          ||','
          ||p_order_type
          ||','
          ||carrier_rec.objid
          ||','
          || part_num_rec.x_technology
          ||','
          || l_order_type_objid
          ||')' ,
          p_call_trans_objid,
          'igate.sp_create_action_item'
        );
      RETURN;
    END IF;
    --
    cnt := cnt+1;
    dbms_output.put_line('cnt:' || cnt || 'l_order_type_objid:' || l_order_type_objid);
    OPEN order_type_curs(l_order_type_objid);
    FETCH order_type_curs INTO order_type_rec;
    IF order_type_curs%NOTFOUND AND NVL(p_bypass_order_type,0) = 1 THEN
      titlestr                                                := ' FAILED ' || UPPER(p_order_type) || ' FOR ' || UPPER(carrier_rec.x_mkt_submkt_name);
    ELSIF order_type_curs%NOTFOUND THEN
      p_status_code := 3;
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'order_type_curs%NOTFOUND',
          sysdate,
          'order_type_curs('
          ||l_order_type_objid
          ||')' ,
          p_call_trans_objid,
          'igate.sp_create_action_item'
        );
      CLOSE order_type_curs;
      RETURN;
    END IF;
    CLOSE order_type_curs;
    --
    OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
    FETCH trans_profile_curs INTO trans_profile_rec;
    dbms_output.put_line('trans_profile_rec.objid:' || trans_profile_rec.objid);
    IF trans_profile_curs%FOUND THEN
      IF trans_profile_rec.x_gsm_transmit_method  IS NOT NULL THEN
        transstr                                  := trans_profile_rec.x_gsm_transmit_method;
      elsif trans_profile_rec.x_d_transmit_method IS NOT NULL THEN
        transstr                                  := trans_profile_rec.x_d_transmit_method;
      elsif trans_profile_rec.x_transmit_method   IS NOT NULL THEN
        transstr                                  := trans_profile_rec.x_transmit_method;
      elsIF NVL(p_bypass_order_type,0)             = 1 THEN
        transstr                                  := NULL;
      ELSE
        p_status_code := 3;
        CLOSE trans_profile_curs;
        INSERT
        INTO error_table
          (
            ERROR_TEXT,
            ERROR_DATE,
            ACTION,
            KEY,
            PROGRAM_NAME
          )
          VALUES
          (
            'all transmit methods are null',
            sysdate,
            'trans_profile_curs('
            ||order_type_rec.x_order_type2x_trans_profile
            ||')' ,
            p_call_trans_objid,
            'igate.sp_create_action_item'
          );
        RETURN;
      END IF;
    ELSIF trans_profile_curs%NOTFOUND AND NVL(p_bypass_order_type,0)                          = 1 THEN
      titlestr                                                                               := ' FAILED ' || UPPER(p_order_type) || ' FOR ' || UPPER(carrier_rec.x_mkt_submkt_name);
      IF p_order_type IN ('Return', 'Deactivation' ,'Suspend') AND NVL(p_bypass_order_type,0) =0 THEN
        p_status_code                                                                        := 2;
      ELSE
        p_status_code := 1;
      END IF;
    ELSE
      CLOSE trans_profile_curs;
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'trans_profile_curs%NOTFOUND',
          sysdate,
          'trans_profile_curs('
          ||order_type_rec.x_order_type2x_trans_profile
          ||')' ,
          p_call_trans_objid,
          'igate.sp_create_action_item'
        );
      RETURN;
    END IF;
    dbms_output.put_line('c_ota_type = ' || c_ota_type);
    CLOSE trans_profile_curs;
    --
    cnt := cnt + 1; --26
    dbms_output.put_line('cnt: insert into TABLE_CONDITION initiated :' || cnt);
    cnt := cnt + 1; --27
    dbms_output.put_line('cnt: Build the Task Entry initiated :' || cnt);
    OPEN c_dummy_data(site_part_rec.x_service_id);
    FETCH c_dummy_data INTO rec_dummy_data;
    IF c_dummy_data%NOTFOUND THEN
       CLOSE c_dummy_data;
       cnt := cnt + 1; --28
      IF titlestr IS NULL THEN
        titlestr  := UPPER(carrier_rec.x_mkt_submkt_name) || ' ' || UPPER(p_order_type);
      END IF;
      notesstr := ':  ********** New Action Item *********** :' || CHR(10) || CHR(13) || ' ActionTitle:  ' || titlestr || CHR(10) || CHR(13) || 'Originator: ' || USER || CHR(10) || CHR(13) || ' Create Time: ' || SYSDATE;
      cnt := cnt + 1; --29
      SELECT seq('condition') INTO l_condition_objid FROM dual;
      cnt := cnt + 1; --30
      INSERT
      INTO table_condition
        (
          objid ,
          condition ,
          wipbin_time ,
          title ,
          s_title ,
          sequence_num
        )
        VALUES
        (
          l_condition_objid ,
          268435456 ,
          SYSDATE ,
          'Not Started' ,
          'NOT STARTED' ,
          0
        );
      --
      cnt := cnt + 1; --31
      SELECT seq('task') INTO p_action_item_objid FROM dual;
      cnt := cnt + 1; --32
      dbms_output.put_line('p_action_item_objid:' || p_action_item_objid);
      SELECT sa.sequ_action_item_id.nextval INTO l_action_item_id FROM dual;
      cnt := cnt + 1; --33
      dbms_output.put_line('l_action_item_id:' || l_action_item_id);
      --
      INSERT
      INTO table_task
        (
          objid ,
          task_id ,
          s_task_id ,
          title ,
          s_title ,
          notes ,
          start_date ,
          x_original_method ,
          x_current_method ,
          x_queued_flag ,
          task_priority2gbst_elm ,
          task_sts2gbst_elm ,
          type_task2gbst_elm ,
          task2contact ,
          task_wip2wipbin ,
          x_task2x_call_trans ,
          task_state2condition ,
          task_originator2user ,
          task_owner2user ,
          x_task2x_order_type ,
          active ,
          x_ota_type
        )
        VALUES
        (
          p_action_item_objid ,
          l_action_item_id ,
          l_action_item_id ,
          titlestr
          || DECODE(p_case_code ,100 ,':CASE' ,NULL) ,
          UPPER(titlestr
          || DECODE(p_case_code ,100 ,':CASE' ,NULL)) ,
          notesstr ,
          SYSDATE ,
          transstr ,
          transstr ,
          '1' , -- hard code 1 as per alan reancianto 8/27/02
          -- in the cb code we had queued flag as 0 and 1
          -- since queued flag has been set to 1 the action item
          -- will no be sent to Intergate-Sent queue
          -- all items will be sent Intergate queue only
          gbst_elm1_rec.objid ,
          gbst_elm3_rec.objid ,
          gbst_elm2_rec.objid ,
          contact_rec.objid ,
          wipbin_rec.objid ,
          call_trans_rec.objid ,
          l_condition_objid ,
          user2_rec.objid ,
          user2_rec.objid ,
          order_type_rec.objid ,
          1 , --always 1
          c_ota_type
        );
        cnt := cnt + 1; --34
      --
      IF titlestr LIKE 'FAILED%' THEN
        sp_dispatch_task(l_task_objid ,'Line Management Re-work' ,hold);
      END IF;
    ELSE
      CLOSE c_dummy_data;
    END IF;

    --CLOSE c_dummy_data;
  EXCEPTION
   WHEN OTHERS THEN
   ota_util_pkg.err_log(p_action => 'failure at cnt no ('||cnt||')', p_error_date => SYSDATE, p_key => p_call_trans_objid, p_program_name => 'igate.sp_create_action_item', p_error_text => sqlerrm);
  END sp_create_action_item;
  ----------------------------------------------------------------------------------------------------
  FUNCTION f_create_case
    (
      p_call_trans_objid IN NUMBER ,
      p_task_objid       IN NUMBER ,
      p_queue_name       IN VARCHAR2 ,
      p_type             IN VARCHAR2 ,
      p_title            IN VARCHAR2
    )
    RETURN NUMBER
  IS
    l_case_objid NUMBER;
  BEGIN
    sp_create_case(p_call_trans_objid ,p_task_objid ,p_queue_name ,p_type ,p_title ,l_case_objid);
    RETURN l_case_objid;
  END;
  ----------------------------------------------------------------------------------------------------
PROCEDURE sp_create_case
  (
    p_call_trans_objid IN NUMBER ,
    p_task_objid       IN NUMBER ,
    p_queue_name       IN VARCHAR2 ,
    p_type             IN VARCHAR2 ,
    p_title            IN VARCHAR2 ,
    p_case_objid OUT NUMBER
  )
IS
  call_trans_rec call_trans_curs%ROWTYPE;
  site_part_rec site_part_curs%ROWTYPE;
  contact_rec contact_curs%ROWTYPE;
  part_inst_rec part_inst_curs%ROWTYPE;
  site_rec site_curs%ROWTYPE;
  user_rec user_curs%ROWTYPE;
  gbst_lst1_rec gbst_lst_curs%ROWTYPE;
  gbst_elm1_rec gbst_elm_curs%ROWTYPE;
  gbst_lst2_rec gbst_lst_curs%ROWTYPE;
  gbst_elm2_rec gbst_elm_curs%ROWTYPE;
  gbst_lst3_rec gbst_lst_curs%ROWTYPE;
  gbst_elm3_rec gbst_elm_curs%ROWTYPE;
  gbst_lst4_rec gbst_lst_curs%ROWTYPE;
  gbst_elm4_rec gbst_elm_curs%ROWTYPE;
  gbst_lst5_rec gbst_lst_curs%ROWTYPE;
  gbst_elm5_rec gbst_elm_curs%ROWTYPE;
  current_user_rec current_user_curs%ROWTYPE;
  user2_rec user2_curs%ROWTYPE;
  address_rec address_curs%ROWTYPE;
  employee_rec employee_curs%ROWTYPE;
  contact_role_rec contact_role_curs%ROWTYPE;
  carrier_rec carrier_curs%ROWTYPE;
  part_num_rec part_num_curs%ROWTYPE;
  site2_rec site2_curs%ROWTYPE;
  task_rec task_curs%ROWTYPE;
  condition_rec condition_curs%ROWTYPE;
  task_user_rec user_curs%ROWTYPE;
  wipbin_rec wipbin_curs%ROWTYPE;
  l_condition_objid NUMBER;
  l_case_objid      NUMBER;
  l_act_entry_objid NUMBER;
  l_case_id         VARCHAR2(30);
  hold              NUMBER;
  cnt               NUMBER := 0;
  --EME to remove table_num_scheme ref
  new_case_id_format VARCHAR2(100) := NULL;
  --EME to remove table_num_scheme ref
BEGIN
  --
  --
  cnt := cnt + 1; --1
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  OPEN call_trans_curs(p_call_trans_objid);
  FETCH call_trans_curs INTO call_trans_rec;
  IF call_trans_curs%NOTFOUND THEN
    CLOSE call_trans_curs;
    RETURN;
  END IF;
  CLOSE call_trans_curs;
  --
  cnt := cnt + 1; --2
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%NOTFOUND THEN
    CLOSE site_part_curs;
    RETURN;
  END IF;
  CLOSE site_part_curs;
  --
  cnt := cnt + 1; --3
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  --    open contact6_curs(site_part_rec.objid);
  --      fetch contact6_curs into contact6_rec;
  --      if contact6_curs%notfound then
  --        return;
  --      end if;
  --    close contact6_curs;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('sp_create_case:' || cnt || ' site_part_rec.objid:' || site_part_rec.objid);
  --
  --
  OPEN part_inst_curs(site_part_rec.objid);
  FETCH part_inst_curs INTO part_inst_rec;
  IF part_inst_curs%NOTFOUND THEN
    CLOSE part_inst_curs;
    RETURN;
  END IF;
  CLOSE part_inst_curs;
  --
  cnt := cnt + 1; --5
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN site_curs(site_part_rec.site_part2site);
  FETCH site_curs INTO site_rec;
  IF site_curs%NOTFOUND THEN
    CLOSE site_curs;
    RETURN;
  END IF;
  CLOSE site_curs;
  --
  cnt := cnt + 1; --6
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN user_curs(call_trans_rec.x_call_trans2user);
  FETCH user_curs INTO user_rec;
  IF user_curs%NOTFOUND THEN
    CLOSE user_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user_curs;
  --
  cnt := cnt + 1; --7
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN address_curs(site_rec.cust_primaddr2address);
  FETCH address_curs INTO address_rec;
  IF address_curs%NOTFOUND THEN
    CLOSE address_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE address_curs;
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Response Priority Code');
  FETCH gbst_lst_curs INTO gbst_lst1_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst1_rec.objid ,'High');
  FETCH gbst_elm_curs INTO gbst_elm1_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Case Type');
  FETCH gbst_lst_curs INTO gbst_lst2_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst2_rec.objid ,'Problem');
  FETCH gbst_elm_curs INTO gbst_elm2_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Not Started');
  FETCH gbst_lst_curs INTO gbst_lst3_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst3_rec.objid ,'Not Started');
  FETCH gbst_elm_curs INTO gbst_elm3_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --14
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  IF current_user_curs%NOTFOUND THEN
    current_user_rec.user := 'appsrv'; -- changed from appsvr
  END IF;
  CLOSE current_user_curs;
  --
  cnt := cnt + 1; --15
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN user2_curs(current_user_rec.user);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%NOTFOUND THEN
    CLOSE user2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  cnt := cnt + 1; --16
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN wipbin_curs(user2_rec.objid);
  FETCH wipbin_curs INTO wipbin_rec;
  IF wipbin_curs%NOTFOUND THEN
    CLOSE wipbin_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE wipbin_curs;
  --
  cnt := cnt + 1; --17
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst4_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --18
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst4_rec.objid ,'Create');
  FETCH gbst_elm_curs INTO gbst_elm4_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --19
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_lst_curs('Problem Severity Level');
  FETCH gbst_lst_curs INTO gbst_lst5_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --20
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN gbst_elm_curs(gbst_lst5_rec.objid ,'High');
  FETCH gbst_elm_curs INTO gbst_elm5_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --21
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%NOTFOUND THEN
    CLOSE employee_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  cnt := cnt + 1; --22
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN contact_role_curs(site_rec.objid);
  FETCH contact_role_curs INTO contact_role_rec;
  IF contact_role_curs%NOTFOUND THEN
    CLOSE contact_role_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE contact_role_curs;
  --
  cnt := cnt + 1; --23
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN contact_curs(contact_role_rec.contact_role2contact);
  FETCH contact_curs INTO contact_rec;
  IF contact_curs%NOTFOUND THEN
    CLOSE contact_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE contact_curs;
  --
  cnt := cnt + 1; --24
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN carrier_curs(call_trans_rec.x_call_trans2carrier);
  FETCH carrier_curs INTO carrier_rec;
  IF carrier_curs%NOTFOUND THEN
    CLOSE carrier_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE carrier_curs;
  --
  cnt := cnt + 1; --25
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN part_num_curs(site_part_rec.site_part2part_info);
  FETCH part_num_curs INTO part_num_rec;
  IF part_num_curs%NOTFOUND THEN
    CLOSE part_num_curs; --CR4579
    RETURN;
  END IF;
  CLOSE part_num_curs;
  --
  cnt := cnt + 1; --26
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN site2_curs(part_inst_rec.part_inst2inv_bin);
  FETCH site2_curs INTO site2_rec;
  IF site2_curs%NOTFOUND THEN
    CLOSE site2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE site2_curs;
  --
  cnt := cnt + 1; --27
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%NOTFOUND THEN
    CLOSE task_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE task_curs;
  --
  cnt := cnt + 1; --28
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN condition_curs(task_rec.task_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%NOTFOUND THEN
    CLOSE condition_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE condition_curs;
  --
  cnt := cnt + 1; --29
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  OPEN user_curs(task_rec.task_owner2user);
  FETCH user_curs INTO task_user_rec;
  IF user_curs%NOTFOUND THEN
    CLOSE user_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user_curs;
  --
  cnt := cnt + 1; --30
  dbms_output.put_line('sp_create_case:' || cnt || 'condition_Rec.title:' || condition_rec.title);
  --
  --
  /* If condition_Rec.title= 'Closed Action Item' AND
  p_Title <> 'Inactive Features' Then */
  --01/17/03
  IF condition_rec.title = 'Closed Action Item' AND p_title NOT IN ('Inactive Features' ,'Non Tracfone #') THEN
    RETURN;
  END IF;
  --
  cnt := cnt + 1;
  dbms_output.put_line('sp_create_case:' || cnt);
  --
  --
  --04/10/03 select seq_condition.nextval +(power(2,28)) into l_condition_objid from dual;
  SELECT seq('condition')
  INTO l_condition_objid
  FROM dual;
  --
  INSERT
  INTO table_condition
    (
      objid ,
      condition ,
      title ,
      wipbin_time ,
      sequence_num
    )
    VALUES
    (
      l_condition_objid ,
      2 ,
      'Open' ,
      SYSDATE ,
      0
    );
  --
  -- 04/10/03 select seq_case.nextval +(power(2,28)) into l_case_objid from dual;
  SELECT seq('case')
  INTO l_case_objid
  FROM dual;
  --
  p_case_objid := l_case_objid;
  --EME to remove table_num_scheme ref
  --
  --       SELECT     next_value
  --             INTO l_case_id
  --             FROM table_num_scheme
  --            WHERE NAME = 'Case ID'
  --       FOR UPDATE;
  --
  -- -- after you get it update the sequence
  --       UPDATE table_num_scheme
  --          SET next_value = next_value + 1
  --        WHERE NAME = 'Case ID';
  --
  --       COMMIT;
  --cwl CR12874
  SELECT sa.sequ_case_id.nextval
  INTO l_case_id
  FROM dual;
  --      sa.Next_Id ('Case ID', l_case_id, new_case_id_format);
  --cwl CR12874
  --EME to remove table_num_scheme ref
  --
  INSERT
  INTO table_case
    (
      objid ,
      x_case_type ,
      title ,
      s_title ,
      phone_num ,
      ownership_stmp ,
      modify_stmp ,
      id_number ,
      creation_time ,
      case_history ,
      x_carrier_id ,
      x_esn ,
      x_min ,
      x_carrier_name ,
      x_text_car_id ,
      x_phone_model ,
      x_retailer_name ,
      case2address ,
      case_reporter2site ,
      case_reporter2contact ,
      calltype2gbst_elm ,
      case_owner2user ,
      case_originator2user ,
      case_wip2wipbin ,
      casests2gbst_elm ,
      respprty2gbst_elm ,
      respsvrty2gbst_elm ,
      case_state2condition ,
      internal_case ,
      yank_flag
    )
    VALUES
    (
      l_case_objid ,
      p_type ,
      p_title ,
      UPPER(p_title) ,
      contact_rec.phone ,
      SYSDATE ,
      SYSDATE ,
      l_case_id ,
      --App.GenerateID("Case ID"),
      SYSDATE ,
      '*** CASE' ,
      carrier_rec.x_carrier_id ,
      site_part_rec.x_service_id ,
      site_part_rec.x_min ,
      carrier_rec.x_mkt_submkt_name ,
      TO_CHAR(carrier_rec.x_carrier_id) ,
      SUBSTR(part_num_rec.description ,1 ,30) ,
      site2_rec.name ,
      address_rec.objid ,
      site_rec.objid ,
      contact_rec.objid ,
      gbst_elm2_rec.objid ,
      task_user_rec.objid ,
      task_user_rec.objid ,
      wipbin_rec.objid ,
      gbst_elm3_rec.objid ,
      gbst_elm1_rec.objid ,
      gbst_elm5_rec.objid ,
      l_condition_objid ,
      0 ,
      0
    );
  -- 04/10/03 select seq_act_entry.nextval +(power(2,28)) into l_act_entry_objid from dual;
  SELECT seq('act_entry')
  INTO l_act_entry_objid
  FROM dual;
  --
  INSERT
  INTO table_act_entry
    (
      objid ,
      act_code ,
      entry_time ,
      addnl_info ,
      act_entry2case ,
      act_entry2user ,
      entry_name2gbst_elm
    )
    VALUES
    (
      l_act_entry_objid ,
      600 ,
      SYSDATE ,
      ' Contact = '
      || contact_rec.first_name
      || ' '
      || contact_rec.last_name
      || ', Priority = '
      || gbst_elm1_rec.title
      || ', Status = '
      || gbst_elm3_rec.title
      || '.' ,
      l_case_objid ,
      user2_rec.objid ,
      gbst_elm4_rec.objid
    );

/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
  INSERT INTO table_time_bomb
    ( objid ,
      escalate_time ,
      end_time ,
      focus_lowid ,
      focus_type ,
      time_period ,
      flags ,
      cmit_creator2employee
    )
    VALUES
    ( seq('time_bomb') ,
      SYSDATE - (365 * 10) ,
      SYSDATE ,
      l_case_objid ,
      0 ,
      l_act_entry_objid ,
      589826 ,
      employee_rec.objid
    );
*/
  --
  IF p_task_objid > 0 THEN
    sp_dispatch_case(l_case_objid ,p_queue_name ,hold);
  END IF;
  --
  p_case_objid := l_case_objid;
  COMMIT;
END sp_create_case;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_close_action_item
  (
    p_task_objid IN NUMBER ,
    p_status     IN NUMBER ,
    p_dummy_out OUT NUMBER
  )
IS
  gbst_elm_title VARCHAR2(100);
  gbst_elm_rec gbst_elm_curs%ROWTYPE;
  gbst_elm2_rec gbst_elm_curs%ROWTYPE;
  gbst_lst_rec gbst_lst_curs%ROWTYPE;
  gbst_lst2_rec gbst_lst_curs%ROWTYPE;
  user2_rec user2_curs%ROWTYPE;
  current_user_rec current_user_curs%ROWTYPE;
  task_rec task_curs%ROWTYPE;
  condition_rec condition_curs%ROWTYPE;
  employee_rec employee_curs%ROWTYPE;
  queue2_rec queue2_curs%ROWTYPE;
  act_entry_objid NUMBER;
  cnt             NUMBER := 0;
  -- OTA flag:
  c_ota_type table_task.x_ota_type%TYPE;
  -- Fail OTA transaction when IGATE transaction fails with status 3 (Failed - NTN)
PROCEDURE fail_ota_trans
  (
    p_x_task2x_call_trans IN NUMBER
  )
IS
  -- ------------------------------------ --
  -- "NTN" stands for Non Tracfone Number --
  -- ------------------------------------ --
  CURSOR x_code_hist_cur
  IS
    SELECT x_sequence
    FROM table_x_code_hist
    WHERE code_hist2call_trans = p_x_task2x_call_trans
    ORDER BY objid ASC;
  x_code_hist_rec x_code_hist_cur%ROWTYPE;
  CURSOR x_call_trans_cur
  IS
    SELECT x_service_id ,
      x_min ,
      ROWID
    FROM table_x_call_trans
    WHERE objid = p_x_task2x_call_trans;
  x_call_trans_rec x_call_trans_cur%ROWTYPE;
BEGIN
  -- 1) fail ota trans
  UPDATE table_x_ota_transaction
  SET x_status                   = 'Failed - NTN'
  WHERE x_ota_trans2x_call_trans = p_x_task2x_call_trans
  AND x_action_type              = '1'; -- activation
  -- 2) fail code hist
  OPEN x_code_hist_cur;
  FETCH x_code_hist_cur INTO x_code_hist_rec;
  IF x_code_hist_cur%FOUND THEN
    UPDATE table_x_code_hist
    SET x_code_accepted        = 'Failed NTN'
    WHERE code_hist2call_trans = p_x_task2x_call_trans;
  END IF;
  CLOSE x_code_hist_cur;
  -- 3) fail call trans
  OPEN x_call_trans_cur;
  FETCH x_call_trans_cur INTO x_call_trans_rec;
  IF x_call_trans_cur%FOUND THEN
    UPDATE table_x_call_trans
    SET x_result = 'Failed' ,
      x_reason   = 'Failed - NTN'
    WHERE ROWID  = x_call_trans_rec.rowid;
  END IF;
  CLOSE x_call_trans_cur;
  -- 4) put the old sequence to ESN
  UPDATE table_part_inst
  SET x_sequence       = x_code_hist_rec.x_sequence
  WHERE part_serial_no = x_call_trans_rec.x_service_id
  AND x_domain         = 'PHONES';
  -- 5) update MIN as NTN so it will not be picked up again for any ESN
  UPDATE table_part_inst
  SET x_part_inst_status = '60' -- NTN
    ,
    last_trans_time     = SYSDATE ,
    status2x_code_table =
    (SELECT objid FROM table_x_code_table WHERE x_code_number = '60'
    )
  WHERE part_serial_no = x_call_trans_rec.x_min
  AND x_domain         = 'LINES';
  -- COMMIT is executed at the end of main procedure - sp_close_action_item
END fail_ota_trans;
--
BEGIN
  p_dummy_out := 1;
  SELECT DECODE(p_status ,0 ,'Succeeded' ,1 ,'Failed - Closed' ,2 ,'Failed - Retail ESN' ,3 ,'Failed - NTN')
  INTO gbst_elm_title
  FROM dual;
  -- set OTA flag:
  IF gbst_elm_title = 'Succeeded' THEN
    c_ota_type     := ota_util_pkg.ota_success;
  ELSE
    c_ota_type := ota_util_pkg.ota_failed;
  END IF;
  --
  cnt := cnt + 1; --1
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  IF current_user_curs%NOTFOUND THEN
    current_user_rec.user := 'appsrv'; -- changed from appsvr
  END IF;
  CLOSE current_user_curs;
  --
  cnt := cnt + 1; --2
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%NOTFOUND THEN
    p_dummy_out := 2; --no task found
    CLOSE task_curs;
    RETURN;
  END IF;
  CLOSE task_curs;
 -- handle Failed - NTN transactions for OTA:
  IF p_status = 3 AND task_rec.x_ota_type IS NOT NULL THEN
    fail_ota_trans(task_rec.x_task2x_call_trans);
  END IF;
  --
  cnt := cnt + 1; --3
  dbms_output.put_line('sp_Close_Action_Item:' || cnt || ' task_rec.task_state2condition:' || task_rec.task_state2condition);
  --
  OPEN condition_curs(task_rec.task_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%NOTFOUND THEN
    p_dummy_out := 3; -- no condition found
    CLOSE condition_curs;
    RETURN;
  ELSE
    IF condition_rec.title = 'Closed Action Item' THEN
      CLOSE condition_curs;
      RETURN;
    END IF;
  END IF;
  CLOSE condition_curs;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN user2_curs(current_user_rec.user);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%NOTFOUND THEN
    CLOSE user2_curs;
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  cnt := cnt + 1; --5
  dbms_output.put_line('sp_Close_Action_Item:' || cnt || ' task_rec.task_currq2queue:' || task_rec.task_currq2queue);
  --
  --    open queue2_curs(task_rec.task_currq2queue);
  --      fetch queue2_curs into queue2_rec;
  --      if queue2_curs%notfound then
  --        return;
  --      end if;
  --    close queue2_curs;
  --
  cnt := cnt + 1; --6
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN gbst_lst_curs('Closed Action Item');
  FETCH gbst_lst_curs INTO gbst_lst_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    p_dummy_out := 4; --no gbst_lst found
    CLOSE gbst_lst_curs;
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --7
  dbms_output.put_line('sp_Close_Action_Item:' || cnt || 'gbst_lst_rec.objid,gbst_elm_title:' || gbst_lst_rec.objid || ':' || gbst_elm_title);
  --
  OPEN gbst_elm_curs(gbst_lst_rec.objid ,gbst_elm_title);
  FETCH gbst_elm_curs INTO gbst_elm_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    p_dummy_out := 5; --no gbst_elm found
    CLOSE gbst_elm_curs;
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('gbst_elm_rec.objid:' || gbst_elm_rec.objid);
  dbms_output.put_line('gbst_elm_rec.title:' || gbst_elm_rec.title);
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst2_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs;
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('sp_Close_Action_Item:' || cnt || ' gbst_lst_rec.objid:' || gbst_lst_rec.objid);
  --
  OPEN gbst_elm_curs(gbst_lst2_rec.objid ,'Close Action Item');
  FETCH gbst_elm_curs INTO gbst_elm2_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs;
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%NOTFOUND THEN
    p_dummy_out := 6; --no employee record found
    CLOSE employee_curs;
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  UPDATE table_condition
  SET condition  = 8192 ,
    wipbin_time  = SYSDATE ,
    title        = 'Closed Action Item' ,
    s_title      = 'CLOSED ACTION ITEM' ,
    sequence_num = 0
  WHERE objid    = condition_rec.objid;
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  dbms_output.put_line('gbst_elm_rec.objid:' || gbst_elm_rec.objid);
  dbms_output.put_line('gbst_elm_rec.title:' || gbst_elm_rec.title);
  UPDATE table_task
  SET comp_date       = SYSDATE ,
    active            = 1 ,
    task_sts2gbst_elm = gbst_elm_rec.objid ,
    task_wip2wipbin   = NULL ,
    task_currq2queue  = NULL ,
    -- set OTA type
    x_ota_type = c_ota_type
  WHERE objid  = task_rec.objid;
  -- OTA x_status update
  -- UPDATE table_x_ota_transaction SET x_status to value 'OTA SEND'
  -- Java program will be looking for this value in this table every 30 seconds
  -- to send activation PSMS message to the phone over the air
  IF c_ota_type = ota_util_pkg.ota_success THEN
    -- We want to make sure to update our OTA transaction
    -- only if it is not completed yet
    -- If IGATE process was too late and didn't finish on time
    -- but in the mean time customer called and our transaction was completed by the
    -- WEBSCR or IVR we don't want to update that traqnsaction here
    UPDATE table_x_ota_transaction
    SET x_status                   = ota_util_pkg.ota_send
    WHERE x_ota_trans2x_call_trans = task_rec.x_task2x_call_trans
    AND UPPER(x_status)           <> 'COMPLETED';
  END IF;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  -- 04/10/03 select seq_act_entry.nextval +(power(2,28))
  SELECT seq('act_entry')
  INTO act_entry_objid
  FROM dual;
  --
  cnt := cnt + 1; --14
  dbms_output.put_line('sp_Close_Action_Item:' || cnt);
  --
  INSERT
  INTO table_act_entry
    (
      objid ,
      act_code ,
      entry_time ,
      addnl_info ,
      removed ,
      focus_type ,
      focus_lowid ,
      act_entry2task ,
      act_entry2user ,
      entry_name2gbst_elm
    )
    VALUES
    (
      act_entry_objid ,
      332871994 ,
      SYSDATE ,
      'Closed at '
      || SYSDATE ,
      0 ,
      5080 ,
      task_rec.objid ,
      task_rec.objid ,
      user2_rec.objid ,
      gbst_elm_rec.objid
    );

/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
  INSERT INTO table_time_bomb
    ( objid ,
      escalate_time ,
      end_time ,
      focus_lowid ,
      focus_type ,
      time_period ,
      flags ,
      left_repeat ,
      cmit_creator2employee
    )
    VALUES
    ( seq('time_bomb') ,
      TO_DATE('01/01/1753' ,'dd/mm/yyyy') ,
      SYSDATE ,
      task_rec.objid ,
      5080 ,
      act_entry_objid ,
      333053954 ,
      0 ,
      employee_rec.objid
    );
*/

  COMMIT;
END sp_close_action_item;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_dispatch_task
  (
    p_task_objid IN NUMBER ,
    p_queue_name IN VARCHAR2 ,
    p_dummy_out OUT NUMBER
  )
IS
  user_rec user_curs%ROWTYPE;
  l_queue_name      VARCHAR2(100) := p_queue_name;
  l_queue_objid     NUMBER;
  l_act_entry_objid NUMBER;
  current_user_rec current_user_curs%ROWTYPE;
  task_rec task_curs%ROWTYPE;
  condition_rec condition_curs%ROWTYPE;
  queue_rec queue_curs%ROWTYPE;
  queue_rec2 queue_curs%ROWTYPE;
  code_rec code_curs%ROWTYPE;
  user2_rec user2_curs%ROWTYPE;
  employee_rec employee_curs%ROWTYPE;
  gbst_lst_rec gbst_lst_curs%ROWTYPE;
  gbst_elm_rec gbst_elm_curs%ROWTYPE;
  --new
  gbst_elm2_rec gbst_elm_curs2%ROWTYPE;
  gbst_elm2_rec2 gbst_elm_curs2%ROWTYPE;
  queue2_rec2 queue2_curs%ROWTYPE;
  queue2_rec3 queue2_curs%ROWTYPE;
  part_num_rec part_num_curs%ROWTYPE;
  call_trans_rec call_trans_curs%ROWTYPE;
  parent_rec parent_curs%ROWTYPE;
  carrier_group_rec carrier_group_curs%ROWTYPE;
  carrier_rec carrier_curs%ROWTYPE;
  site_part_rec site_part_curs%ROWTYPE;
  strtechnology VARCHAR2(100);
  boolholddeac  BOOLEAN;
  ------------------------------------------------
  CURSOR part_inst3_curs(c_min IN VARCHAR2)
  IS
    SELECT * FROM table_part_inst WHERE part_serial_no = c_min;
  part_inst3_rec part_inst3_curs%ROWTYPE;
  ------------------------------------------------
  CURSOR esn_call_trans_curs(c_esn IN VARCHAR2)
  IS
    SELECT *
    FROM table_x_call_trans
    WHERE x_service_id = c_esn
      --03/17/03 Clarify Upgrade refurbished phone
      --or x_service_id = c_esn||'R')
    AND x_action_type = '99'
    ORDER BY x_transact_date DESC;
  esn_call_trans_rec esn_call_trans_curs%ROWTYPE;
  esn_task_rec task_curs%ROWTYPE;
  esn_curr_queue_rec queue2_curs%ROWTYPE;
  esn_prev_queue_rec queue2_curs%ROWTYPE;
  part_inst_rec part_inst_curs%ROWTYPE;
  part_inst2_rec part_inst2_curs%ROWTYPE;
  hold       NUMBER;
  cnt        NUMBER := 0;
  temp_queue BOOLEAN;
BEGIN
  p_dummy_out := 1;
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  IF current_user_curs%NOTFOUND THEN
    current_user_rec.user := 'appsrv'; -- changed from appsvr
  END IF;
  CLOSE current_user_curs;
  --
  IF l_queue_name = 'Please Specify' THEN
    l_queue_name := 'Line Activation NoOrdTyp';
  END IF;
  --
  cnt := cnt + 1; --1
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN queue_curs(l_queue_name);
  FETCH queue_curs INTO queue_rec;
  IF queue_curs%FOUND THEN
    l_queue_objid := queue_rec.objid;
    CLOSE queue_curs;
  ELSE
    CLOSE queue_curs;
    OPEN code_curs('DEFAULT QUEUE');
    FETCH code_curs INTO code_rec;
    IF code_curs%NOTFOUND THEN
      CLOSE code_curs;
      RETURN;
    ELSE
      OPEN queue_curs(code_rec.x_text);
      FETCH queue_curs INTO queue_rec2;
      IF queue_curs%NOTFOUND THEN
        CLOSE queue_curs;
        CLOSE code_curs;
        RETURN;
      ELSE
        l_queue_objid := queue_rec2.objid;
      END IF;
      CLOSE queue_curs;
    END IF;
    CLOSE code_curs;
  END IF;
  --
  cnt := cnt + 1; --2
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%NOTFOUND THEN
    CLOSE task_curs;
    RETURN;
  END IF;
  CLOSE task_curs;
  --
  cnt := cnt + 1; --3
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN condition_curs(task_rec.task_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%NOTFOUND THEN
    CLOSE condition_curs;
    RETURN;
  END IF;
  CLOSE condition_curs;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  IF condition_rec.title = 'Closed Action Item' THEN
    RETURN;
  END IF;
  --
  cnt := cnt + 1; --5
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN call_trans_curs(task_rec.x_task2x_call_trans);
  FETCH call_trans_curs INTO call_trans_rec;
  IF call_trans_curs%NOTFOUND THEN
    CLOSE call_trans_curs;
    RETURN;
  END IF;
  CLOSE call_trans_curs;
  --
  cnt := cnt + 1; --6
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  dbms_output.put_line('sp_dispatch_task:' || cnt || ' call_trans_rec.x_service_id:' || call_trans_rec.x_service_id);
  dbms_output.put_line('sp_dispatch_task:' || cnt || ' call_trans_rec.x_min:' || call_trans_rec.x_min);
  --
  OPEN carrier_curs(call_trans_rec.x_call_trans2carrier);
  FETCH carrier_curs INTO carrier_rec;
  IF carrier_curs%NOTFOUND THEN
    CLOSE carrier_curs;
    RETURN;
  END IF;
  CLOSE carrier_curs;
  --
  cnt := cnt + 1; --7
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN carrier_group_curs(carrier_rec.carrier2carrier_group);
  FETCH carrier_group_curs INTO carrier_group_rec;
  IF carrier_group_curs%NOTFOUND THEN
    CLOSE carrier_group_curs;
    RETURN;
  END IF;
  CLOSE carrier_group_curs;
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN parent_curs(carrier_group_rec.x_carrier_group2x_parent);
  FETCH parent_curs INTO parent_rec;
  IF parent_curs%NOTFOUND THEN
    CLOSE parent_curs;
    RETURN;
  END IF;
  CLOSE parent_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN queue2_curs(parent_rec.x_parent2temp_queue);
  FETCH queue2_curs INTO queue2_rec2;
  IF queue2_curs%NOTFOUND THEN
    temp_queue := FALSE;
  ELSE
    temp_queue := TRUE;
  END IF;
  CLOSE queue2_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%NOTFOUND THEN
    CLOSE site_part_curs;
    RETURN;
 END IF;
  CLOSE site_part_curs;
  --
  dbms_output.put_line('sp_dispatch_task a:' || cnt || ' site_part_rec.objid:' || site_part_rec.objid);
  --
  ------------------------------------------------------------------
  -- new cursors for 9/27
  ------------------------------------------------------------------
  OPEN part_inst_curs(site_part_rec.objid);
  FETCH part_inst_curs INTO part_inst_rec;
  --      if part_inst_curs%notfound then
  --        close part_inst_curs;
  --        return;
  --      end if;
  CLOSE part_inst_curs;
  --
  dbms_output.put_line('sp_dispatch_task b:' || cnt);
  --
  OPEN part_inst2_curs(part_inst_rec.part_to_esn2part_inst);
  FETCH part_inst2_curs INTO part_inst2_rec;
  --      if part_inst2_curs%notfound then
  --        close part_inst2_curs;
  --        return;
  --      end if;
  CLOSE part_inst2_curs;
  -- new code cwl oct 2 2002
  OPEN part_inst3_curs(site_part_rec.x_min);
  FETCH part_inst3_curs INTO part_inst2_rec;
  CLOSE part_inst3_curs;
  ------------------------------------------------------------------
  -- new cursors for 9/27
  ------------------------------------------------------------------
  --
  dbms_output.put_line('sp_dispatch_task c:' || cnt);
  --
  --CR4579
  IF part_num_curs%ISOPEN THEN
    CLOSE part_num_curs;
  END IF;
  OPEN part_num_curs(site_part_rec.site_part2part_info);
  FETCH part_num_curs INTO part_num_rec;
  IF part_num_curs%NOTFOUND THEN
    CLOSE part_num_curs;
    RETURN;
  END IF;
  CLOSE part_num_curs;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('sp_dispatch_task:' || cnt || ' task_rec.task_currq2queue:' || task_rec.task_currq2queue);
  --
  OPEN queue2_curs(task_rec.task_currq2queue);
  FETCH queue2_curs INTO queue2_rec3;
  --      if queue2_curs%notfound then
  --        close queue2_curs;
  --        return;
  --      end if;
  CLOSE queue2_curs;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('sp_dispatch_task:' || cnt || ' task_rec.task_currq2queue:' || task_rec.task_currq2queue);
  --
  OPEN gbst_elm_curs2(task_rec.task_currq2queue);
  FETCH gbst_elm_curs2 INTO gbst_elm2_rec;
  --      if gbst_elm_curs2%notfound then
  --        close gbst_elm_curs2;
  --        return;
  --      end if;
  CLOSE gbst_elm_curs2;
  --
  --
  OPEN gbst_elm_curs2(task_rec.type_task2gbst_elm);
  FETCH gbst_elm_curs2 INTO gbst_elm2_rec2;
  IF gbst_elm_curs2%NOTFOUND THEN
    CLOSE gbst_elm_curs2;
    RETURN;
  END IF;
  CLOSE gbst_elm_curs2;
  --
  cnt := cnt + 1; --14
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  --
  --------Detrmine Technology
  --    strTechnology = Part_Num_rec.x_technology;
  ------------------------------------------------------------------
  -- new cursors for 9/27
  ------------------------------------------------------------------
  --    if Parent_rec.x_hold_digital_deac=1 and Part_Num_rec.x_technology <> 'ANALOG' then
  --dbms_output.put_line('sp_dispatch_task:'||'digital bool true and x_tech != ANALOG');
  --      boolHoldDeac := True;
  --    end if;
  --    if Parent_rec.x_hold_analog_deac=1 and Part_Num_rec.x_technology = 'ANALOG' then
  --dbms_output.put_line('sp_dispatch_task:'||'analog bool true and x_tech != ANALOG');
  --      boolHoldDeac := True;
  --    end if;
  --
  --if boolholddeac = true then
  --  dbms_output.put_line('boolholddeac:true');
  --else
  --  dbms_output.put_line('boolholddeac:false');
  --end if;
  ------------------------------------------------------------------
  -- new cursors for 9/27
  ------------------------------------------------------------------
  dbms_output.put_line('Call_Trans_rec.x_action_type:' || call_trans_rec.x_action_type);
  dbms_output.put_line('Queue2_rec2.title :' || queue2_rec2.title);
  dbms_output.put_line('Queue2_rec3.title :' || queue2_rec3.title);
  dbms_output.put_line('gbst_elm2_rec2.title :' || gbst_elm2_rec2.title);
  IF
    -- new cursors for 9/27
    --       boolHoldDeac and
    temp_queue AND part_inst2_rec.x_part_inst_status IN ('37' ,'39') AND call_trans_rec.x_action_type = '99' AND NVL(queue2_rec2.title ,'1') <> NVL(queue2_rec3.title ,'2') AND gbst_elm2_rec2.title IN ('Suspend' ,'Deactivation') THEN
    dbms_output.put_line('update_task');
    UPDATE table_task
    SET task_prevq2queue = l_queue_objid
    WHERE objid          = task_rec.objid;
    --
    l_queue_objid := queue2_rec2.objid;
    --
  ELSIF temp_queue AND call_trans_rec.x_action_type IN ('1' ,'3') THEN
    dbms_output.put_line('don t update_task 1');
    OPEN esn_call_trans_curs(call_trans_rec.x_service_id);
    FETCH esn_call_trans_curs INTO esn_call_trans_rec;
    IF esn_call_trans_curs%FOUND THEN
      -------------------------------------------------------------------
      CLOSE esn_call_trans_curs;
      dbms_output.put_line('don t update_task 2');
      OPEN task3_curs(esn_call_trans_rec.objid);
      FETCH task3_curs INTO esn_task_rec;
      IF task3_curs%NOTFOUND THEN
        CLOSE task3_curs;
      ELSE
        CLOSE task3_curs;
        dbms_output.put_line('don t update_task 3');
        OPEN queue2_curs(esn_task_rec.task_currq2queue);
        FETCH queue2_curs INTO esn_curr_queue_rec;
        CLOSE queue2_curs;
        dbms_output.put_line('don t update_task 4');
        OPEN queue2_curs(esn_task_rec.task_prevq2queue);
        FETCH queue2_curs INTO esn_prev_queue_rec;
        CLOSE queue2_curs;
        dbms_output.put_line('don t update_task 5');
        dbms_output.put_line('don t update_task: Queue2_rec2.title:' || queue2_rec2.title);
        dbms_output.put_line('don t update_task: esn_curr_queue_rec.title:' || esn_curr_queue_rec.title);
        IF queue2_rec2.title = esn_curr_queue_rec.title THEN
          dbms_output.put_line('don t update_task: call_trans_rec.x_min:' || TRANSLATE(call_trans_rec.x_min ,' ' ,'*'));
          dbms_output.put_line('don t update_task: esn_call_trans_rec.x_min:' || TRANSLATE(esn_call_trans_rec.x_min ,' ' ,'*'));
          IF LTRIM(RTRIM(call_trans_rec.x_min)) = LTRIM(RTRIM(esn_call_trans_rec.x_min)) THEN
            dbms_output.put_line('don t update_task:sp_Close_Action_Item');
            sp_close_action_item(esn_task_rec.objid ,0 ,hold);
            sp_close_action_item(p_task_objid ,0 ,hold);
            COMMIT;
            RETURN;
          END IF;
        ELSE
          dbms_output.put_line('don t update_task:sp_Dispatch_Task');
          sp_dispatch_task(esn_task_rec.objid ,esn_prev_queue_rec.title ,hold);
        END IF;
      END IF;
    ELSE
      CLOSE esn_call_trans_curs;
    END IF;
  END IF;
  ----------------NEG END
  --
  cnt := cnt + 1; --15
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  --
  OPEN user2_curs(current_user_rec.user);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%NOTFOUND THEN
    CLOSE user2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  cnt := cnt + 1; --16
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%NOTFOUND THEN
    CLOSE employee_curs; --CR4579
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  cnt := cnt + 1; --17
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs; --CR4579
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  cnt := cnt + 1; --18
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Dispatch');
  FETCH gbst_elm_curs INTO gbst_elm_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs; --CR4579
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  cnt := cnt + 1; --19
  dbms_output.put_line('sp_dispatch_task:' || cnt);
  --
  UPDATE table_condition
  SET condition = 536870920 ,
    title       = 'Open Action Item-Dispatch' ,
    s_title     = 'OPEN ACTION ITEM-DISPATCH'
  WHERE objid   = condition_rec.objid;
  --
  IF condition_rec.queue_time IS NULL THEN
    UPDATE table_condition
    SET queue_time = SYSDATE
    WHERE objid    = condition_rec.objid;
  END IF;
  --
  UPDATE table_task
  SET task_currq2queue = l_queue_objid
  WHERE objid          = task_rec.objid;
  --
  -- 04/10/03 select SEQ_ACT_ENTRY.nextval +(power(2,28)) into l_act_entry_objid from dual;
  SELECT seq('act_entry')
  INTO l_act_entry_objid
  FROM dual;
  --
  INSERT
  INTO table_act_entry
    (
      objid ,
      act_code ,
      entry_time ,
      addnl_info ,
      proxy ,
      removed ,
      focus_lowid ,
      act_entry2task ,
      act_entry2user ,
      entry_name2gbst_elm
    )
    VALUES
    (
      l_act_entry_objid ,
      900 ,
      SYSDATE ,
      'Dispatched to Queue '
      || l_queue_name
      || '.' ,
      current_user_rec.user ,
      0 ,
      task_rec.objid ,
      task_rec.objid ,
      user2_rec.objid ,
      gbst_elm_rec.objid
    );
  --

/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
  INSERT INTO table_time_bomb
    ( objid ,
      escalate_time ,
      end_time ,
      focus_lowid ,
      focus_type ,
      time_period ,
      flags ,
      left_repeat ,
      cmit_creator2employee
    )
    VALUES
    ( seq('time_bomb') ,
      TO_DATE('01/01/1753' ,'dd/mm/yyyy') ,
      SYSDATE ,
      task_rec.objid ,
      5080 ,
      l_act_entry_objid ,
      655362 ,
      0 ,
      employee_rec.objid
    );
*/

  COMMIT;
END sp_dispatch_task;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_determine_trans_method
  (
    p_action_item_objid IN NUMBER ,
    p_order_type        IN VARCHAR2 ,
    p_trans_method      IN VARCHAR2 ,
    p_destination_queue OUT NUMBER ,
    p_application_system IN VARCHAR2 DEFAULT 'IG', -- GSM Enhancement
    in_service_days      IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_voice_units       IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_text_units        IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_data_units        IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_free_service_days IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_free_voice_units  IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_free_text_units   IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_free_data_units   IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL
  )
IS

  r_get_part_inst c_get_part_inst%ROWTYPE; --CR4579
  l_order_type_objid NUMBER;
  gbst_lst_rec gbst_lst_curs%ROWTYPE;
  gbst_elm_rec gbst_elm_curs%ROWTYPE;
  task2_rec task2_curs%ROWTYPE;
  call_trans_rec call_trans_curs%ROWTYPE;
  carrier_rec carrier_curs%ROWTYPE;
  site_part_rec site_part_curs%ROWTYPE;
  part_num_rec part_num_curs%ROWTYPE;
  user_rec user_curs%ROWTYPE;
  part_inst_rec part_inst_curs%ROWTYPE;
  gbst_elm_rec2 gbst_elm_curs2%ROWTYPE;
  order_type_rec order_type_curs%ROWTYPE;
  trans_profile_rec trans_profile_curs%ROWTYPE;
  boolupgrade   BOOLEAN;
  queuestr      VARCHAR2(100);
  technologystr VARCHAR2(1);
  methodstr     VARCHAR2(100);
  str_ordertype VARCHAR2(100);
  hold          NUMBER;
  cnt           NUMBER := 0;
  --------------------------------------------------------------
  CURSOR test_verizon1_curs(c_task_objid IN NUMBER)
  IS
    SELECT c.title
    FROM table_condition c ,
      table_task t
    WHERE c.objid = task_state2condition
    AND c.title LIKE 'Closed Action Item%'
    AND t.objid = c_task_objid;
  test_verizon1_rec test_verizon1_curs%ROWTYPE;
  --------------------------------------------------------------
  CURSOR test_verizon2_curs(c_task_objid IN NUMBER)
  IS
    SELECT q.title
    FROM table_queue q ,
      table_task t
    WHERE q.objid = task_currq2queue
    AND q.title LIKE 'Verizon Deac Queue%'
    AND t.objid = c_task_objid;
  test_verizon2_rec test_verizon2_curs%ROWTYPE;
  --------------------------------------------------------------
  CURSOR check_for_previous_task_curs
  IS
    SELECT 1 col1
    FROM gw1.ig_transaction ig ,
      table_task t
    WHERE ig.action_item_id = t.task_id
    AND t.objid             = p_action_item_objid;
  check_for_previous_task_rec check_for_previous_task_curs%ROWTYPE;
BEGIN
  --
  cnt := cnt + 1; --1
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN task_curs(p_action_item_objid);
  FETCH task_curs INTO task2_rec;
  IF task_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
    CLOSE task_curs;
    RETURN;
  END IF;
  CLOSE task_curs;
  --
  cnt := cnt + 1; --2
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN call_trans_curs(task2_rec.x_task2x_call_trans);
  FETCH call_trans_curs INTO call_trans_rec;
  IF call_trans_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
    CLOSE call_trans_curs;
    RETURN;
  END IF;
  CLOSE call_trans_curs;
  --
  cnt := cnt + 1; --3
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
    CLOSE site_part_curs;
    RETURN;
  END IF;
  CLOSE site_part_curs;
  --
  cnt := cnt + 1; --4
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN carrier_curs(call_trans_rec.x_call_trans2carrier);
  FETCH carrier_curs INTO carrier_rec;
  IF carrier_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
    CLOSE carrier_curs;
    RETURN;
  END IF;
  CLOSE carrier_curs;
  cnt := cnt + 1; --5
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt || ' site_part_rec.SITE_PART2PART_INFO:' || site_part_rec.site_part2part_info);
  --
  --CR4579
  OPEN c_get_part_inst(site_part_rec.x_service_id);
  FETCH c_get_part_inst INTO r_get_part_inst;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
  CLOSE c_get_part_inst;
  IF part_num_curs%ISOPEN THEN
    CLOSE part_num_curs;
  END IF;
  --CR4579 END
  -- CR4579
  OPEN part_num_curs(r_get_part_inst.n_part_inst2part_mod);
  FETCH part_num_curs INTO part_num_rec;
  IF part_num_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
    CLOSE part_num_curs;
    sp_dispatch_task(task2_rec.objid ,'Line Management Re-work' ,hold);
    RETURN;
  ELSE
    technologystr := SUBSTR(part_num_rec.x_technology ,1 ,1);
  END IF;
  CLOSE part_num_curs;
  --
  cnt := cnt + 1; --6
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  sp_get_ordertype(site_part_rec.x_min ,p_order_type ,carrier_rec.objid ,part_num_rec.x_technology , l_order_type_objid);
  IF NVL(l_order_type_objid,0) = 0 THEN
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        'nvl(l_order_type_objid,0) = 0',
        sysdate,
        'sp_get_ordertype('
        ||site_part_rec.x_min
        ||','
        ||p_order_type
        ||','
        ||carrier_rec.objid
        ||','
        ||part_num_rec.x_technology
        ||','
        ||l_order_type_objid
        ||')' ,
        p_action_item_objid,
        'igate.sp_determine_trans_method'
      );
  END IF;
  --
  dbms_output.put_line('l_order_type_objid:' || l_order_type_objid);
  cnt := cnt + 1; --7
  dbms_output.put_line('f_check_blackout:' || cnt);
  --
  --black check removed CR25988
  --
  cnt := cnt + 1; --8
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN user_curs(call_trans_rec.x_call_trans2user);
  FETCH user_curs INTO user_rec;
  IF user_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
    CLOSE user_curs;
    RETURN;
  END IF;
  CLOSE user_curs;
  --
  cnt := cnt + 1; --9
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  --  OPEN part_inst_curs(site_part_rec.objid);
  --  FETCH part_inst_curs INTO part_inst_rec;
  --not being used by this proceduere oct 2 2002 cwl
  --      if part_inst_curs%notfound then
  --        close part_inst_curs;
  --        return;
  --      end if;
  --  if part_inst_curs%notfound then
  --    insert into error_table( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
  --    values( 'part_inst_curs%notfound',sysdate,'part_inst_curs('||site_part_rec.objid||')' ,p_action_item_objid,'igate.sp_determine_trans_method');
  --   end if;
  --  CLOSE part_inst_curs;
  --
  cnt := cnt + 1; --10
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  OPEN gbst_elm_curs2(task2_rec.task_priority2gbst_elm);
  FETCH gbst_elm_curs2 INTO gbst_elm_rec2;
  IF gbst_elm_curs2%NOTFOUND THEN
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        'gbst_elm_curs2%NOTFOUND',
        sysdate,
        'gbst_elm_curs2('
        ||task2_rec.task_priority2gbst_elm
        ||')' ,
        p_action_item_objid,
        'igate.sp_determine_trans_method'
      );
    CLOSE gbst_elm_curs2;
    RETURN;
  ELSE
    IF gbst_elm_rec2.title = 'High - Upgrade' THEN
      boolupgrade         := TRUE;
    ELSE
      boolupgrade := FALSE;
    END IF;
  END IF;
  CLOSE gbst_elm_curs2;
  --
  cnt := cnt + 1; --11
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  dbms_output.put_line('l_order_type_objid:' || l_order_type_objid);
  --
  OPEN order_type_curs(l_order_type_objid);
  FETCH order_type_curs INTO order_type_rec;
  IF order_type_curs%NOTFOUND THEN
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        'order_type_curs%NOTFOUND',
        sysdate,
        'order_type_curs('
        ||l_order_type_objid
        ||')' ,
        p_action_item_objid,
        'igate.sp_determine_trans_method'
      );
    CLOSE order_type_curs;
    RETURN;
  ELSE
    str_ordertype    := sf_get_ig_order_type('SP_DETERMINE_TRANS_METHOD' ,task2_rec.objid ,order_type_rec.x_order_type);
    IF str_ordertype IS NULL THEN
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'str_ordertype is null',
          sysdate,
          'sf_get_ig_order_type(SP_DETERMINE_TRANS_METHOD,'
          ||task2_rec.objid
          ||','
          ||order_type_rec.x_order_type
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
    END IF;
    -- CR15035 Order Type Function End
  END IF;
  CLOSE order_type_curs;
  --
  cnt := cnt + 1; --12
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt || ' order_type_rec.X_ORDER_TYPE2X_TRANS_PROFILE:' || order_type_rec.x_order_type2x_trans_profile);
  --
  OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
  FETCH trans_profile_curs INTO trans_profile_rec;
  IF trans_profile_curs%NOTFOUND THEN
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        'trans_profile_curs%NOTFOUND',
        sysdate,
        'trans_profile_curs('
        ||order_type_rec.x_order_type2x_trans_profile
        ||')' ,
        p_action_item_objid,
        'igate.sp_determine_trans_method'
      );
    IF p_order_type IN ('Deactivation' ,'Suspend') THEN
      queuestr := 'Line Management Re-work';
    ELSE
      queuestr := 'Line Activation NoOrdTyp';
    END IF;
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    --
    p_destination_queue := 4;
    --
    CLOSE trans_profile_curs;
    RETURN;
  ELSE
    IF trans_profile_rec.x_exception = 1 THEN
      sp_dispatch_task(task2_rec.objid ,trans_profile_rec.x_exception_queue ,hold);
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'trans_profile_rec.x_exception = 1 ',
          sysdate,
          'sp_dispatch_task('
          ||task2_rec.objid
          ||','
          ||trans_profile_rec.x_exception_queue
          ||','
          ||hold
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
      CLOSE trans_profile_curs;
      RETURN;
    END IF;
    IF p_trans_method IS NULL THEN
      IF technologystr = 'G' --CR3380
        THEN
        methodstr         := trans_profile_rec.x_gsm_transmit_method;
      ELSIF technologystr <> 'A' THEN
        methodstr         := trans_profile_rec.x_d_transmit_method;
      ELSE
        methodstr := trans_profile_rec.x_transmit_method;
      END IF;
    ELSE
      methodstr := p_trans_method;
    END IF;
  END IF;
  CLOSE trans_profile_curs;
  --
  cnt := cnt + 1; --13
  dbms_output.put_line('sp_Determine_Trans_Method:' || cnt);
  --
  IF str_ordertype IN ('A' ,'E') THEN
    IF part_num_rec.x_technology     = 'ANALOG' AND boolupgrade = FALSE THEN
      queuestr                      := trans_profile_rec.x_default_queue;
    ELSIF part_num_rec.x_technology  = 'GSM' --CR3380
      AND boolupgrade                = FALSE THEN
      queuestr                      := trans_profile_rec.x_gsm_act;
    ELSIF part_num_rec.x_technology <> 'ANALOG' AND boolupgrade = FALSE THEN
      queuestr                      := trans_profile_rec.x_digital_act;
    END IF;
  ELSIF str_ordertype IN ('S' ,'D' ,'R') THEN
    IF part_num_rec.x_technology     = 'ANALOG' AND boolupgrade = FALSE THEN
     queuestr                      := trans_profile_rec.x_analog_deact;
    ELSIF part_num_rec.x_technology  = 'GSM' --CR3380
      AND boolupgrade                = FALSE THEN
      queuestr                      := trans_profile_rec.x_gsm_deact;
    ELSIF part_num_rec.x_technology <> 'ANALOG' AND boolupgrade = FALSE THEN
      queuestr                      := trans_profile_rec.x_digital_deact;
    END IF;
  END IF;
  IF boolupgrade THEN
    queuestr := trans_profile_rec.x_upgrade;
  END IF;
  --CR3327-1 - Set the queue name for Int Port Approval
  IF str_ordertype = 'IPA' THEN
    queuestr      := 'Internal Port Approval';
  END IF;
  IF queuestr IS NULL OR queuestr = 'Please Specify' THEN
    queuestr  := 'Line Management Re-work';
  END IF;
  --    If TransMethod is not null Then
  --        MethodStr := TransMethod;
  --    End If;
  --
  IF methodstr IN ('AOL' ,'EMAIL' ,'FAX') THEN
    IF boolupgrade AND str_ordertype = 'S' AND methodstr <> 'AOL' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'boolupgrade AND str_ordertype = S AOL EMAIL FAX',
          sysdate,
          'sp_close_action_item('
          ||task2_rec.objid
          ||',0,'
          ||hold
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
      RETURN;
    END IF;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent AOL');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    ------------------------------------------------------------------
    sp_dispatch_task(task2_rec.objid ,'Intergate' ,hold);
    --
    --check to make sure new que is not Verizon Deac Queue and line not past due oct 4
    --
    OPEN test_verizon1_curs(task2_rec.objid);
    FETCH test_verizon1_curs INTO test_verizon1_rec;
    IF test_verizon1_curs%FOUND THEN
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'test_verizon1_curs%FOUND',
          sysdate,
          'test_verizon1_curs('
          ||task2_rec.objid
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
      CLOSE test_verizon1_curs;
      COMMIT;
      RETURN;
    END IF;
    CLOSE test_verizon1_curs;
    --
    OPEN test_verizon2_curs(task2_rec.objid);
    FETCH test_verizon2_curs INTO test_verizon2_rec;
    IF test_verizon2_curs%FOUND THEN
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'test_verizon2_curs%FOUND',
          sysdate,
          'test_verizon2_curs('
          ||task2_rec.objid
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
      CLOSE test_verizon2_curs;
      COMMIT;
      RETURN;
    END IF;
    CLOSE test_verizon2_curs;
    --
    --end check of verizon
    --
    --dbms_output.put_line('Before Insert 1');
    --dbms_output.put_line('Task OBJID:'||to_char(task2_rec.objid));
    OPEN check_for_previous_task_curs;
    FETCH check_for_previous_task_curs INTO check_for_previous_task_rec;
    IF check_for_previous_task_curs%NOTFOUND THEN
      dbms_output.put_line('Before Insert 2');


      sp_insert_ig_transaction(p_task_objid => task2_rec.objid, p_order_type_objid => l_order_type_objid, p_status => hold, p_application_system => p_application_system, -- GSM Enhancement
      in_service_days => in_service_days, in_voice_units => in_voice_units, in_text_units => in_text_units, in_data_units => in_data_units,
      in_free_service_days => in_free_service_days, in_free_voice_units => in_free_voice_units, in_free_text_units => in_free_text_units, in_free_data_units => in_free_data_units); --added for TMO Safelink Upgrades




      dbms_output.put_line('After Insert status:' || hold);
    END IF;
    CLOSE check_for_previous_task_curs;
    OPEN check_for_previous_task_curs;
    FETCH check_for_previous_task_curs INTO check_for_previous_task_rec;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
    CLOSE check_for_previous_task_curs;
    ------------------------------------------------------------------
    IF methodstr           = 'AOL' THEN
      p_destination_queue := 8;
    ELSIF methodstr        = 'FAX' THEN
      p_destination_queue := 9;
    ELSIF methodstr        = 'EMAIL' THEN
      p_destination_queue := 10;
    END IF;
    --
  ELSIF methodstr IN ('ICI') THEN
    IF boolupgrade AND str_ordertype = 'S' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'boolupgrade AND str_ordertype = S ICI',
          sysdate,
          'sp_close_action_item('
          ||task2_rec.objid
          ||',0,'
          ||hold
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
      RETURN;
    END IF;
    --
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    --
    IF trans_profile_rec.x_ici_system = 'ICI CALL IN' THEN
      p_destination_queue            := 11;
    ELSE
      p_destination_queue := 6;
    END IF;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent ICI');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    --
  ELSIF methodstr IN ('ECI') THEN
    IF boolupgrade AND str_ordertype = 'S' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'boolupgrade AND str_ordertype = S ECI',
          sysdate,
          'sp_close_action_item('
          ||task2_rec.objid
          ||',0,'
          ||hold
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
      RETURN;
    END IF;
    --sp_Open_Action_Item(Task2_Rec.task_id);
    p_destination_queue := 7;
    --
  ELSIF methodstr IN ('MANUAL - EMAIL') THEN
    IF boolupgrade AND str_ordertype = 'S' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'boolupgrade AND str_ordertype = S MANUAL - EMAIL',
          sysdate,
          'sp_close_action_item('
          ||task2_rec.objid
          ||',0,'
          ||hold
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
      RETURN;
    END IF;
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    p_destination_queue := 7;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent Manual');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    --
  ELSIF methodstr IN ('MANUAL - FAX') THEN
    --
    IF boolupgrade AND str_ordertype = 'S' THEN
      sp_close_action_item(task2_rec.objid ,0 ,hold);
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'boolupgrade AND str_ordertype = S MANUAL - FAX',
          sysdate,
          'sp_close_action_item('
          ||task2_rec.objid
          ||',0,'
          ||hold
          ||')' ,
          p_action_item_objid,
          'igate.sp_determine_trans_method'
        );
      RETURN;
    END IF;
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    --
    p_destination_queue := 7;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent Manual');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
    --
  ELSE
    --
    queuestr := 'Line Activation NoOrdTyp';
    sp_dispatch_task(task2_rec.objid ,queuestr ,hold);
    --
    p_destination_queue := 7;
    --
    OPEN gbst_lst_curs('Open Action Item');
    FETCH gbst_lst_curs INTO gbst_lst_rec;
    IF gbst_lst_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_lst_curs;
      RETURN;
    END IF;
    CLOSE gbst_lst_curs;
    --
    OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Sent Manual');
    FETCH gbst_elm_curs INTO gbst_elm_rec;
    IF gbst_elm_curs%NOTFOUND THEN
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      CLOSE gbst_elm_curs;
      RETURN;
    END IF;
    CLOSE gbst_elm_curs;
    --
    UPDATE table_task
    SET task_sts2gbst_elm = gbst_elm_rec.objid
    WHERE objid           = task2_rec.objid;
  END IF;
  dbms_output.put_line('sp_determine_trans_method: before commit');
  COMMIT;
END sp_determine_trans_method;

-- Function to determine the unit value when applicable for Straight Talk
FUNCTION get_unit_value ( i_task_objid in number, i_bucket_name in varchar2) RETURN number is
CURSOR c_get_bucket_value IS
   SELECT /*+ use_invisible_indexes */
          spfvdef2.value_name   BUCKET_VALUE
   FROM                  x_serviceplanfeaturevalue_def spfvdef,
                                  x_serviceplanfeature_value spfv,
                                  x_service_plan_feature spf,
                                  x_serviceplanfeaturevalue_def spfvdef2,
                                  x_service_plan sp,
                                  x_service_plan_site_part spsp,
                                  table_site_part tsp,
                                  ig_transaction ig,
                                  table_task tt
   WHERE  1 = 1
   AND    tt.objid = i_task_objid
   AND    tt.task_id = ig.action_item_id
   AND    ig.esn = tsp.x_service_id
   AND    tsp.OBJID = spsp.TABLE_SITE_PART_ID
   AND    spsp.x_service_plan_id = sp.objid
   AND    spf.sp_feature2service_plan = sp.objid
   AND    spf.sp_feature2rest_value_def = spfvdef.objid
   AND    spf.objid = spfv.spf_value2spf
   AND    SPFVDEF2.OBJID = SPFV.VALUE_REF
   AND    SPFVDEF.VALUE_NAME = i_bucket_name;
  bucket_value_rec c_get_bucket_value%ROWTYPE;
BEGIN
  open c_get_bucket_value;
  fetch c_get_bucket_value into bucket_value_rec;
  close c_get_bucket_value;
  RETURN bucket_value_rec.bucket_value;
exception when others then
   RETURN NULL;
END get_unit_value;
---------------------------------------------------------------------------------------------
--Added by phaneendra on 5/19/15 for the CR33844.
  FUNCTION fn_cpo_source(p_esn IN VARCHAR2)  RETURN varchar2
IS
var_source TABLE_PART_NUM.X_SOURCESYSTEM%TYPE;
BEGIN
SELECT pn.X_SOURCESYSTEM
INTO var_source
FROM TABLE_PART_INST PI,TABLE_MOD_LEVEL ML,TABLE_PART_NUM PN,table_part_class PC
WHERE PI.PART_SERIAL_NO= NVL(p_esn,0)
AND PI.N_PART_INST2PART_MOD= ML.OBJID
AND ML.PART_INFO2PART_NUM=PN.OBJID
AND PN.part_num2part_class = pc.objid;

RETURN var_source;

EXCEPTION
WHEN OTHERS THEN
RETURN NULL;
END fn_cpo_source;

----------------------------------------------------------------------------------------------------
/* FUNCTION sf_get_slcarr_id(
    p_carr_feat_objid IN NUMBER ,
    p_ppe_flag        IN NUMBER )RETURN NUMBER; */
--CR45249 added function to get msid flag for SUI
FUNCTION get_msid_value (
                          i_order_type   IN VARCHAR2,
                          i_esn          IN VARCHAR2,
                          i_min          IN VARCHAR2 )   RETURN VARCHAR2
 IS
  c_msid_flag  VARCHAR2(1);
  c_msid       VARCHAR2(100);
BEGIN
  BEGIN
    SELECT update_msid_flag
    INTO   c_msid_flag
    FROM   x_ig_order_type
    WHERE  x_ig_order_type = i_order_type
    AND    update_msid_flag is not null
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
     c_msid_flag := 'N';
  END;
    IF c_msid_flag = 'Y' THEN
      BEGIN
         SELECT pi_esn.x_msid
         INTO   c_msid
         FROM   table_part_inst pi_esn,
                table_part_inst pi_min
         WHERE  pi_esn.part_serial_no = i_esn
         AND    pi_esn.x_domain = 'PHONES'
         AND    pi_min.part_to_esn2part_inst = pi_esn.objid
         AND    pi_min.x_domain = 'LINES';
         RETURN c_msid;
      EXCEPTION
       WHEN OTHERS THEN
        RETURN i_min;
      END;
    ELSE
      RETURN i_min;
    END IF;
END;
--CR54864
PROCEDURE sp_ig_trans_payload( p_task_objid         NUMBER,
                               p_order_type_objid   NUMBER,
                               p_application_system VARCHAR2,
                               in_service_days      VARCHAR2,
                               in_voice_units       VARCHAR2,
                               in_text_units        VARCHAR2,
                               in_data_units        VARCHAR2,
                               in_free_service_days VARCHAR2,
                               in_free_voice_units  VARCHAR2,
                               in_free_text_units   VARCHAR2,
                               in_free_data_units   VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR c1 IS
    SELECT 1 col1
      FROM table_x_order_type ot,
           x_ig_trans_payload_setup igsu
     WHERE ot.objid = p_order_type_objid
       AND igsu.x_order_type = ot.x_order_type;
  c1_rec c1%ROWTYPE;
BEGIN
  OPEN c1;
    FETCH c1 INTO c1_rec;
    IF c1%FOUND THEN
      INSERT INTO x_ig_trans_payload( task_objid,
                                      order_type_objid,
                                      application_system,
                                      service_days,
                                      voice_units,
                                      text_units,
                                      data_units,
                                      free_service_days,
                                      free_voice_units,
                                      free_text_units,
                                      free_data_units  )
                              VALUES( p_task_objid,
                                      p_order_type_objid,
                                      p_application_system,
                                      in_service_days,
                                      in_voice_units,
                                      in_text_units,
                                      in_data_units,
                                      in_free_service_days,
                                      in_free_voice_units,
                                      in_free_text_units,
                                      in_free_data_units  );
      COMMIT;
    END IF;
  CLOSE c1;
END;

PROCEDURE sp_insert_ig_transaction(
    p_task_objid       IN NUMBER , ---1744451399
    p_order_type_objid IN NUMBER ,  --268902509
    p_status OUT NUMBER ,
    p_application_system IN VARCHAR2 DEFAULT 'IG', -- GSM Enhancement
    in_service_days      IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_voice_units       IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_text_units        IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_data_units        IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_free_service_days IN   ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL, --added for Safelink TMO Upgrades
    in_free_voice_units  IN   ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_free_text_units   IN   ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
    in_free_data_units   IN   ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL)
IS
  CURSOR same_rate_plan_curs(c_call_trans_objid IN NUMBER)
  IS
    SELECT ig.rate_plan
    FROM table_task tt,
      gw1.ig_transaction ig
    WHERE tt.X_TASK2X_CALL_TRANS = c_call_trans_objid
    AND ig.action_item_id        = tt.task_id
    ORDER BY tt.objid DESC,
      tt.start_date DESC;
  same_rate_plan_rec same_rate_plan_curs%rowtype;
  --
  CURSOR task_curs(c_task_objid IN NUMBER)
  IS
    SELECT * FROM table_task WHERE objid = c_task_objid;
  task_rec task_curs%ROWTYPE;
  --
  CURSOR cur_case_dtl(c_call_tran_objid NUMBER)
  IS
    SELECT c.x_case_type ,
      c.title ,
      c.objid case_objid
    FROM table_case c ,
      table_x_case_detail cd
    WHERE cd.detail2case = c.objid
    AND c.objid         IN
      (SELECT MAX(c.objid) ----CR13085
      FROM table_case c ,
        table_x_call_trans ct ,
        table_x_case_detail cd
      WHERE c.x_esn      = ct.x_service_id
      AND cd.detail2case = c.objid
      AND ct.objid       = c_call_tran_objid
      AND creation_time >= SYSDATE - 1 / 48
      AND c.x_case_type           IN ('Units') --CR17415 PM 08/02/2011 'Port In' added for PPIR order type. -- CR17793 to remove PPIR
      AND c.title                 IN ('Compensation Service Plan' ,'Replacement Units' ,'Replacement Service Plan')
      AND cd.x_name               IN ('SERVICE_DAYS' ,'VOICE_UNITS' ,'DATA_UNITS' ,'SMS_UNITS')
      )
  AND cd.x_name  = 'SERVICE_PLAN'
  AND cd.x_value = 'All You Need'
  ORDER BY c.objid DESC;
  case_dtl_rec cur_case_dtl%ROWTYPE;
  -- CR17793 Start PM 11/07/2011
  CURSOR cur_pir_case_dtl(c_call_tran_objid NUMBER)
  IS
    SELECT c.x_case_type ,
      c.title ,
      c.objid case_objid
    FROM table_case c ,
      table_x_case_detail cd
    WHERE cd.detail2case = c.objid
    AND c.objid         IN
      (SELECT MAX(c.objid) ----CR13085
      FROM table_case c ,
        table_x_call_trans ct ,
        table_x_case_detail cd
      WHERE c.x_esn        = ct.x_service_id
      AND cd.detail2case   = c.objid
      AND ct.objid         = c_call_tran_objid
      AND ct.x_action_type = '111'
      AND creation_time BETWEEN SYSDATE - 30 AND SYSDATE
      AND ((c.x_case_type = 'Port In'
      AND c.title        IN ('ST Auto Internal')))
      AND cd.x_name      IN ('SERVICE_DAYS' ,'VOICE_UNITS' ,'DATA_UNITS' ,'SMS_UNITS')
      )
  AND cd.x_name  = 'SERVICE_PLAN'
  AND cd.x_value = 'All You Need'
  ORDER BY c.objid DESC;
  --
  CURSOR cu_bucket_details ( c_esn VARCHAR2 ,c_rate_plan VARCHAR2 ,c_case_objid NUMBER )
  IS
    SELECT *
    FROM
      (SELECT NULL bucket_id ,
        cd.x_name ,
        cd.x_value ,
        DECODE(cd.x_name ,'SERVICE_DAYS' ,1 ,2) sort_order
      FROM table_x_case_detail cd ,
        table_case c
      WHERE cd.detail2case = c.objid
      AND c.x_esn          = c_esn
      AND x_name          IN ('SERVICE_DAYS')
      AND c.objid          = c_case_objid
      ORDER BY c.creation_time DESC
      )
  WHERE ROWNUM < 2
  UNION
  SELECT DECODE(cd.x_name ,'SERVICE_DAYS' ,NULL ,bkt.bucket_id) bucket_id ,
    cd.x_name ,
   cd.x_value,
                /* CR35468
    TO_CHAR(DECODE(cd.x_name ,'DATA_UNITS' ,DECODE(UPPER(bkt.measure_unit) ,'KB' ,((cd.x_value * 1024) * 1024) -- Converting MB into Byte
    ,cd.x_value) ,'VOICE_UNITS' ,(cd.x_value                                                   * 60)           -- Converting Min into Seconds
    ,cd.x_value)) ,
                                */
    DECODE(cd.x_name ,'SERVICE_DAYS' ,1 ,2) sort_order
  FROM table_x_case_detail cd ,
    (SELECT *
    FROM
      (SELECT *
      FROM table_case
      WHERE x_esn = c_esn
      AND objid   = c_case_objid
      ORDER BY creation_time DESC
      )
    WHERE ROWNUM < 2
    ) c ,
    (SELECT bucket_id ,
      measure_unit ,
      bucket_desc ,
      bucket_type ,
      rate_plan ,
      (SELECT COUNT(1)
      FROM gw1.ig_buckets bkt2
      WHERE bkt2.bucket_type = bkt1.bucket_type
      AND bkt2.rate_plan     = bkt1.rate_plan
      ) cnt
    FROM gw1.ig_buckets bkt1
    ) bkt
  WHERE cd.detail2case = c.objid
  AND cd.x_name        = bkt.bucket_type
  AND bkt.rate_plan    = c_rate_plan
  AND x_name          IN ('VOICE_UNITS' ,'DATA_UNITS' ,'SMS_UNITS')
  --AND bkt.bucket_desc  = DECODE(bkt.bucket_type ,'DATA_UNITS' ,DECODE(cnt ,0 ,bkt.bucket_desc ,1 ,bkt.bucket_desc ,'Unlimited Data') ,bkt.bucket_desc)  Commented by Rahul for CR36735 after introduction of active flag
  ORDER BY 4;
  -- For Case Attribute which are created with value 0.
  CURSOR cu_bkt_dtl_without_case_dtl ( c_esn VARCHAR2 ,c_rate_plan VARCHAR2 ,c_case_objid NUMBER )
  IS
    SELECT NULL bucket_id ,
      'SERVICE_DAYS' x_name ,
      0 x_value ,
      1 sort_order
    FROM
      (SELECT 'SERVICE_DAYS' x_name FROM dual
    MINUS
    SELECT x_name
    FROM table_x_case_detail
    WHERE detail2case = c_case_objid
    AND x_name       IN ('SERVICE_DAYS')
      )
    UNION
    SELECT DECODE(cd.x_name ,'SERVICE_DAYS' ,NULL ,bkt.bucket_id) bucket_id ,
      cd.x_name ,
      --cd.x_value,
      0 x_value ,
      DECODE(cd.x_name ,'SERVICE_DAYS' ,1 ,2) sort_order
    FROM
      (SELECT 'SERVICE_DAYS' x_name FROM dual
      UNION
      SELECT 'VOICE_UNITS' FROM dual
      UNION
      SELECT 'DATA_UNITS' FROM dual
      UNION
      SELECT 'SMS_UNITS' FROM dual
      MINUS
      SELECT x_name
      FROM table_x_case_detail
      WHERE detail2case = c_case_objid
      AND x_name       IN ('SERVICE_DAYS' ,'VOICE_UNITS' ,'DATA_UNITS' ,'SMS_UNITS')
      ) cd ,
      (SELECT bucket_id ,
        measure_unit ,
        bucket_desc ,
        bucket_type ,
        rate_plan ,
        (SELECT COUNT(1)
        FROM gw1.ig_buckets bkt2
        WHERE bkt2.bucket_type = bkt1.bucket_type
        AND bkt2.rate_plan     = bkt1.rate_plan
        ) cnt
      FROM gw1.ig_buckets bkt1
      ) bkt
    WHERE cd.x_name     = bkt.bucket_type
    AND bkt.rate_plan   = c_rate_plan
    --AND bkt.bucket_desc = DECODE(bkt.bucket_type ,'DATA_UNITS' ,DECODE(cnt ,0 ,bkt.bucket_desc ,1 ,bkt.bucket_desc ,'Unlimited Data') ,bkt.bucket_desc) Commented by Rahul for CR36735 after introduction of active flag
    ORDER BY 4;
    --
    CURSOR chk_need_dep_igtx_curs(c_esn VARCHAR2)
    IS
      SELECT
        /*+ use_invisible_indexes */
        *
      FROM gw1.ig_transaction
      WHERE esn         = c_esn
      AND order_type               IN ('A' ,'E' ,'IPI' ,'PIR' ,'EPIR') --CR17415 PM 08/02/2011 'Port In' added for PPIR order type. -- CR17793 to remove PPIR
      AND status NOT               IN ('S' ,'F')
      AND creation_date > = SYSDATE - 1 / 24;
    chk_need_dep_igtx_rec chk_need_dep_igtx_curs%ROWTYPE;
    CURSOR contact_curs(c_contact_objid IN NUMBER)
    IS
      SELECT tc.* FROM table_contact tc WHERE tc.objid = c_contact_objid;
    contact_rec contact_curs%ROWTYPE;
    CURSOR address_curs(c_contact_objid IN NUMBER)
    IS
      SELECT a.*
      FROM table_contact_role cr,
        table_site s,
        table_address a
      WHERE cr.contact_role2contact = c_contact_objid
      AND s.objid                   = cr.contact_role2site
      AND a.objid                   = cust_primaddr2address;
    address_rec address_curs%rowtype;
    CURSOR c1
    IS
      SELECT ig.*
      FROM gw1.ig_transaction ig,
        table_task t
      WHERE 1               =1
      AND ig.action_item_id = t.task_id
      AND t.objid           = p_task_objid;
    c1_rec c1%rowtype;
    CURSOR ld_curs(c_call_trans_objid IN NUMBER)
    IS
      SELECT rsid,
        x_value
      FROM x_switchbased_transaction st
      WHERE st.x_sb_trans2x_call_trans = c_call_trans_objid;
    ld_rec ld_curs%rowtype;
    --
    CURSOR order_type_curs(c_objid IN NUMBER)
    IS
      SELECT ot.*
        --sf_get_ig_order_type('SP_INSERT_IG_TRANSACTION' ,task_rec.objid ,order_type_rec.x_order_type) new_order_type
      FROM table_x_order_type ot
      WHERE ot.objid = c_objid;
   order_type_rec order_type_curs%ROWTYPE;
    --
    CURSOR trans_profile_curs(c_objid IN NUMBER, c_tech IN VARCHAR2)
    IS
      SELECT objid,
        DECODE(c_tech,'GSM',x_gsm_trans_template,'CDMA',x_d_trans_template,x_transmit_template) template,
        DECODE(c_tech,'GSM',x_gsm_transmit_method,'CDMA',x_d_transmit_method,x_transmit_method) transmit_method,
        DECODE(c_tech,'GSM',x_gsm_fax_number,'CDMA',x_d_fax_number,x_fax_number) fax_number,
        DECODE(c_tech,'GSM',x_gsm_fax_num2,'CDMA',x_d_fax_num2,x_fax_num2) fax_num2,
        DECODE(c_tech,'GSM',x_gsm_online_number,'CDMA',x_d_online_number,x_online_number) online_number,
        DECODE(c_tech,'GSM',x_gsm_online_num2,'CDMA',x_d_online_num2,x_online_num2) online_num2,
        DECODE(c_tech,'GSM',x_gsm_email,'CDMA',x_d_email,x_email) email,
        DECODE(c_tech,'GSM',x_gsm_network_login,'CDMA',x_d_network_login,x_network_login) network_login,
        DECODE(c_tech,'GSM',x_gsm_network_password,'CDMA',x_d_network_password,x_network_password) network_password,
        DECODE(c_tech,'GSM',x_system_login,'CDMA',x_d_system_login,x_system_login) system_login,
        DECODE(c_tech,'GSM',x_system_password,'CDMA',x_d_system_password,x_system_password) system_password,
        DECODE(c_tech,'GSM',x_gsm_batch_delay_max,'CDMA',x_d_batch_delay_max,x_batch_delay_max) batch_delay_max,
        DECODE(c_tech,'GSM',x_gsm_batch_quantity,'CDMA',x_d_batch_quantity,x_batch_quantity) batch_quantity
      FROM table_x_trans_profile
      WHERE objid = c_objid;
    trans_profile_rec trans_profile_curs%ROWTYPE;
    --
    CURSOR carrier_curs(c_objid IN NUMBER)
    IS
      SELECT c.*,
        NVL(
        (SELECT 1
        FROM sa.x_next_avail_carrier nac
        WHERE nac.x_carrier_id = c.x_carrier_id
        AND rownum             < 2
        ),0) x_next_avail_carrier
      FROM table_x_carrier c
      WHERE objid = c_objid;
      carrier_rec carrier_curs%ROWTYPE;
      --
      CURSOR carrier_group_curs(c_objid IN NUMBER)
      IS
        SELECT * FROM table_x_carrier_group WHERE objid = c_objid;
      carrier_group_rec carrier_group_curs%ROWTYPE;
      --
      CURSOR parent_curs(c_objid IN NUMBER)
      IS
        SELECT * FROM table_x_parent WHERE objid = c_objid;
      parent_rec parent_curs%ROWTYPE;
      --
      CURSOR c_nap_rc(p_zipcode IN VARCHAR2)
      IS
        SELECT * FROM sa.x_cingular_mrkt_info WHERE zip = p_zipcode AND ROWNUM < 2;
      c_nap_rc_rec c_nap_rc%ROWTYPE;

      --CR51707.
      CURSOR c_tmo_ngp_rc(p_zipcode IN VARCHAR2)
      IS
        SELECT *
          FROM (SELECT *
                  FROM sa.x_tmo_zip_ngp
                 WHERE x_zip = p_zipcode
              ORDER BY x_priority )
         WHERE ROWNUM <2;

      c_tmo_ngp_rec c_tmo_ngp_rc%ROWTYPE;
      --
      --CR46950 added logic to avoid multiple rows returning. and pi.x_domain = 'LINES' and rownum < 2
      CURSOR call_trans_curs(c_objid IN NUMBER)
      IS
        SELECT ct.* ,
          (SELECT pi.x_msid FROM table_part_inst pi WHERE pi.part_serial_no = ct.x_min and pi.x_domain = 'LINES' and rownum < 2
          ) msid,
        DECODE(ct.x_ota_type,ota_util_pkg.ota_activation,'Y',NULL) ota_activation
      FROM table_x_call_trans ct
      WHERE ct.objid = c_objid;
      call_trans_rec call_trans_curs%ROWTYPE;

      CURSOR site_part_curs(c_objid IN NUMBER)
      IS
        SELECT CAST(sp.x_min AS VARCHAR2(30)) x_min,
          sp.x_service_id,
          sp.x_expire_dt,
          sp.cmmtmnt_end_dt,  -- CR42459 Added cmmtmnt_end_dt for COALESCE(site_part_rec.cmmtmnt_end_dt,site_part_rec.x_expire_dt)
          CAST(sp.x_pin AS VARCHAR2(30)) x_pin,
          sp.x_zipcode,
          sp.site_part2part_info,
          (SELECT pi.part_inst2carrier_mkt
          FROM table_part_inst pi
          WHERE pi.part_serial_no = sp.x_min
          AND pi.x_domain         = 'LINES'
          ) part_inst2carrier_mkt,
        (SELECT pi.n_part_inst2part_mod
        FROM table_part_inst pi
        WHERE pi.part_serial_no = sp.x_service_id
        AND pi.x_domain         = 'PHONES'
        ) n_part_inst2part_mod,
        (
        CASE
          WHEN sp.x_iccid IS NULL
          THEN
            (SELECT pi.x_iccid
            FROM table_part_inst pi
            WHERE pi.part_serial_no = sp.x_service_id
            AND pi.x_domain         = 'PHONES'
            )
          ELSE sp.x_iccid
        END) iccid
      FROM table_site_part sp
      WHERE objid = c_objid;
      site_part_rec site_part_curs%ROWTYPE;
      --
      CURSOR alt_min_curs(c_esn IN VARCHAR2, c_order_type IN VARCHAR2)
      IS
        SELECT c.s_title,
          (SELECT cd.x_value l_account
          FROM table_x_case_detail cd
          WHERE cd.x_name
            || ''                     IN ('CURRENT_MIN')
          AND cd.detail2case = c.objid + 0
          AND rownum         <2
          ) MIN ,
        (SELECT cd.x_value l_account
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('ACCOUNT')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) account ,
        (SELECT cd.x_value l_first_name
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('NAME')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) first_name ,
        (SELECT cd.x_value l_last_name
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('LAST_NAME')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) last_name ,
        (SELECT cd.x_value l_add1
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('ADDRESS_1')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) add1 ,
        (SELECT cd.x_value l_add2
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('ADDRESS_2')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) add2 ,
        (SELECT cd.x_value l_zip
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('ZIP_CODE')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) zip ,
        (SELECT cd.x_value l_account
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('PIN')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) pin,
        (SELECT cd.x_value l_curr_addr_house_number
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_HOUSE_NUMBER')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_house_number,
        (SELECT cd.x_value l_curr_addr_direction
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_DIRECTION')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_direction,
        (SELECT cd.x_value l_curr_addr_street_name
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_STREET_NAME')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_street_name,
        (SELECT cd.x_value l_curr_addr_street_type
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_STREET_TYPE')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_street_type,
        (SELECT cd.x_value l_curr_addr_unit
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_UNIT')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_unit
      FROM table_case c
      WHERE 1=1
      AND c.x_case_type
        || ''     = 'Port In'
      AND c.x_esn = c_esn
      ORDER BY c.creation_time DESC;
      alt_min_rec alt_min_curs%ROWTYPE;
      --
      CURSOR part_num_curs(c_objid IN NUMBER)
      IS
        SELECT pn.* ,
          DECODE(org_flow,'3',1,0) straight_talk_flag,
          bo.org_id ,
          bo.objid bus_org_objid,
          bo.org_flow,
          NVL(
          (SELECT to_number(v.x_param_value)
          FROM table_x_part_class_values v,
            table_x_part_class_params n
          WHERE 1                 =1
          AND v.value2part_class  = pn.part_num2part_class
          AND v.value2class_param = n.objid
          AND n.x_param_name      = 'DATA_SPEED'
          AND rownum              <2
          ),NVL(x_data_capable,0)) data_speed,
                                  (SELECT to_number(v.x_param_value)
            FROM table_x_part_class_values v,
                table_x_part_class_params n
           WHERE 1                 =1
             AND v.value2part_class  = pn.part_num2part_class
             AND v.value2class_param = n.objid
             AND n.x_param_name      = 'NON_PPE'
             AND rownum              <2) PPE_FLAG --CR38927 SL UPGRADE
        FROM table_part_num pn ,
          table_mod_level ml ,
          table_bus_org bo
        WHERE pn.objid          = ml.part_info2part_num
        AND ml.objid            = c_objid
        AND pn.part_num2bus_org = bo.objid;
        part_num_rec part_num_curs%ROWTYPE;
        --
        CURSOR carrier_features_curs1 ( c_objid IN NUMBER ,c_tech IN VARCHAR2 ,c_bus_org_objid IN NUMBER ,c_data_speed IN NUMBER,c_order_type IN VARCHAR2 )
        IS
          SELECT cf.*,
            1 col1
          FROM table_x_carrier_features cf
          WHERE x_feature2x_carrier = c_objid
          AND cf.x_technology       = c_tech
          AND cf.x_features2bus_org = c_bus_org_objid
          AND cf.x_data             = c_data_speed;
        CURSOR carrier_features_curs2 ( c_objid IN NUMBER ,c_tech IN VARCHAR2 ,c_bus_org_objid IN NUMBER ,c_data_speed IN NUMBER,c_order_type IN VARCHAR2 )
        IS
          SELECT cf.*,
            2 col1
          FROM table_x_carrier_features cf
          WHERE EXISTS
            (SELECT 1
            FROM table_x_carrier c,
              table_x_carrier_group cg,
              table_x_carrier_group cg2,
              table_x_carrier c2
            WHERE c.objid                    = c_objid
            AND cg.objid                     = c.carrier2carrier_group
            AND cg2.X_CARRIER_GROUP2X_PARENT = cg.X_CARRIER_GROUP2X_PARENT
            AND c2.carrier2carrier_group     = cg2.objid
            AND c2.objid                     = cf.X_FEATURE2X_CARRIER
            )
        AND cf.x_technology       = c_tech
        AND cf.X_FEATURES2BUS_ORG =
          (SELECT bo.objid
          FROM table_bus_org bo
          WHERE bo.org_id = 'NET10'
          AND bo.objid    = c_bus_org_objid
          )
        AND cf.x_data = c_data_speed;
        CURSOR carrier_features_curs3 ( c_objid IN NUMBER ,c_tech IN VARCHAR2 ,c_bus_org_objid IN NUMBER ,c_data_speed IN NUMBER,c_order_type IN VARCHAR2 )
        IS
          SELECT cf.*,
            3 col1
          FROM table_x_carrier_features cf
          WHERE x_feature2x_carrier = c_objid
          AND c_order_type         IN ('D','S');
        carr_feature_rec1 carrier_features_curs1%ROWTYPE;
        --
        CURSOR carrier_features_curs ( c_objid IN NUMBER)
        IS
         SELECT cf.*,
            DECODE(cf.x_voicemail ,1 ,'Y' ,'N') voice_mail,
            cf.x_vm_code voice_mail_package,
            DECODE(cf.x_caller_id ,1 ,'Y' ,'N') caller_id,
            cf.x_id_code caller_id_package,
            DECODE(cf.x_call_waiting ,1 ,'Y' ,'N') call_waiting,
            cf.x_cw_code call_waiting_package,
            DECODE(cf.x_sms ,1 ,'Y' ,'N') sms,
            cf.x_sms_code sms_package,
            DECODE(cf.x_dig_feature ,1 ,'Y' ,'N') digital_feature,
            cf.x_digital_feature digital_feature_code,
            DECODE(cf.x_mpn ,1 ,'Y' ,'N') mpn,
            cf.x_mpn_code mpn_code,
            cf.x_pool_name pool_name,
            (
            CASE
              WHEN cf.X_SWITCH_BASE_RATE IS NOT NULL
              THEN 1
              ELSE 0
            END) non_ppe
          FROM table_x_carrier_features cf
          WHERE cf.objid = c_objid;
        carr_feature_rec carrier_features_curs%ROWTYPE;
        --
        CURSOR old_esn_curs(c_esn IN VARCHAR2, c_org_id IN VARCHAR2)
        IS
          SELECT cd.x_value esn,
            c.creation_time c_date
          FROM table_x_case_detail cd ,
            table_case c
          WHERE cd.detail2case = c.objid + 0
          AND c.x_esn          = c_esn
          AND cd.x_name
            || ''             = 'REFERENCE_ESN'
          AND 'STRAIGHT_TALK' = c_org_id
        UNION
        SELECT x_old_esn esn,
          X_DETACH_DT c_date
        FROM x_min_esn_change
        WHERE x_new_esn      = c_esn
        AND 'STRAIGHT_TALK' != c_org_id
        ORDER BY c_date DESC;
        old_esn_rec old_esn_curs%ROWTYPE;
        --
        CURSOR old_min_curs(ip_service_id IN VARCHAR2)
        IS
          SELECT x_min
          FROM table_site_part
          WHERE x_service_id = ip_service_id
          AND part_status    = 'Inactive'
          AND x_min NOT LIKE 'T%'
          ORDER BY service_end_dt DESC;
        old_min_rec old_min_curs%ROWTYPE;
        CURSOR new_transaction_id_curs
        IS
          SELECT gw1.trans_id_seq.nextval + (POWER(2 ,28)) transaction_id FROM dual;
          --SELECT gw1.trans_id_seq.nextval transaction_id FROM dual;			-- Modified for CR47743 Commented and reverted for CR48114
        new_transaction_id_rec new_transaction_id_curs%rowtype;

---CR46315
	CURSOR cur_promo_data(c_site_part_objid IN NUMBER,
	c_parent_name 		in varchar2,
	c_non_ppe 		in number,
	c_rate_plan 		in varchar2
	,c_promo_data_feat_name	in varchar2
	)
	IS
	SELECT sp.objid,
	REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 1) col1,
	REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 2) col2,
	REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3) col3,
	REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 4) col4
	,def.display_name	sp_feature_bucket_name		--CR46315
	FROM x_service_plan_site_part spsp,
	x_service_plan sp,
	x_service_plan_feature spf,
	x_serviceplanfeaturevalue_def def,
	x_serviceplanfeature_value value,
	x_serviceplanfeaturevalue_def def2
	WHERE 1                         =1
	AND spsp.table_site_part_id     = c_site_part_objid
	AND sp.objid                    = spsp.x_service_plan_id
	AND spf.SP_FEATURE2SERVICE_PLAN = sp.objid
	AND def.objid                   = spf.sp_feature2rest_value_def
	AND def.display_name            =  c_promo_data_feat_name	---'BUCKET_PROMO_DATA' For simple mobile 40, 50 and 55 plans
	AND value.spf_value2spf         = spf.objid
	AND def2.objid                  = value.VALUE_REF
	and exists(select 1
			from gw1.ig_buckets ib
			where ib.BUCKET_ID = REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3)
			and ib.rate_plan = c_rate_plan)
	and (case when c_parent_name like '%VERIZON%' then
		'VER'
		when c_parent_name like 'AT%'then
		'ATT'
		when c_parent_name like '%CINGULAR%'then
		'ATT'
		when c_parent_name like '%SPRINT%'then
		'SPR'
		when c_parent_name like 'T_MOB%'then
		'TMO'
		else
		'XXX'
		end )= substr(def2.value_name,1,3)
	and c_non_ppe =1
  --CR56512 changes start
  UNION
  SELECT spe.sp_objid,
         REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 1) col1,
         REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 2) col2,
         REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3) col3,
         REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 4) col4 ,
         'CARRIER_BUCKET' sp_feature_bucket_name
  FROM   x_service_plan_ext spe,
         x_service_plan_site_part spsp
  WHERE  spsp.table_site_part_id = c_site_part_objid
  AND    spsp.x_service_plan_id    = spe.sp_objid
	AND EXISTS(SELECT 1
             FROM   gw1.ig_buckets ib
             WHERE  ib.BUCKET_ID = REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3)
             AND    ib.rate_plan = c_rate_plan);
  --CR56512 changes end
	rec_promo_data cur_promo_data%rowtype;


CURSOR CUR_SP_FEATURE_VALUE (I_SP_OBJID 		IN VARCHAR2
				, I_SP_FEATURE_NAME	IN VARCHAR2)
IS
SELECT def2.VALUE_NAME
FROM x_service_plan sp,
     x_service_plan_feature spf,
     x_serviceplanfeaturevalue_def def,
     x_serviceplanfeature_value value,
     x_serviceplanfeaturevalue_def def2
WHERE spf.SP_FEATURE2SERVICE_PLAN = sp.objid
AND def.objid                   = spf.sp_feature2rest_value_def
AND def.display_name            =  I_SP_FEATURE_NAME
AND value.spf_value2spf         = spf.objid
AND sp.objid			= I_SP_OBJID
AND value.spf_value2spf         = spf.objid
AND def2.objid                  = value.VALUE_REF
;

REC_SP_FEATURE_VALUE	CUR_SP_FEATURE_VALUE%ROWTYPE;

---CR46315


        CURSOR benefit_curs(c_site_part_objid  in number,
                            c_parent_name      in varchar2,
                            c_non_ppe          in number,
                            c_rate_plan        in varchar2,
                            c_call_trans_objid in number)
        IS
          SELECT sp.objid,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 1) col1,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 2) col2,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3) col3,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 4) col4
	    ,def.display_name	sp_feature_bucket_name		--CR46315
          FROM x_service_plan_site_part spsp,
            x_service_plan sp,
            x_service_plan_feature spf,
            x_serviceplanfeaturevalue_def def,
            x_serviceplanfeature_value value,
            x_serviceplanfeaturevalue_def def2
          WHERE 1                         =1
          AND spsp.table_site_part_id     = c_site_part_objid
          AND sp.objid                    = spsp.x_service_plan_id
          AND spf.SP_FEATURE2SERVICE_PLAN = sp.objid
          AND def.objid                   = spf.sp_feature2rest_value_def
          AND def.display_name           like  'CARRIER_BUCKET%'
          AND value.spf_value2spf         = spf.objid
          AND def2.objid                  = value.VALUE_REF
          and exists(select 1
                       from gw1.ig_buckets ib
                       where ib.BUCKET_ID = REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3)
                         and ib.rate_plan = c_rate_plan)
          and not exists(select 1
                         from   table_x_call_trans ct
                         where  ct.objid = c_call_trans_objid
                         and    ct.x_reason in ('COMPENSATION', 'REPLACEMENT', 'AWOP', 'ADD_ON') -- CR55066, mdave, 03082018
                         and    sa.customer_info.get_bus_org_id(i_esn => ct.x_service_id) IN ('SIMPLE_MOBILE')) --CR52698
          and (case when c_parent_name like '%VERIZON%' then
                      'VER'
                    when c_parent_name like 'AT%'then
                      'ATT'
                    when c_parent_name like '%CINGULAR%'then
                      'ATT'
                    when c_parent_name like '%SPRINT%'then
                      'SPR'
                    when c_parent_name like 'T_MOB%'then
                      'TMO'
                    else
                      'XXX'
                    end )= substr(def2.value_name,1,3)
           and c_non_ppe =1
           --CR56512 changes start
           UNION
           SELECT spe.sp_objid,
                  REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 1) col1,
                  REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 2) col2,
                  REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3) col3,
                  REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 4) col4 ,
                  'CARRIER_BUCKET' sp_feature_bucket_name
           FROM   x_service_plan_ext spe,
                  x_service_plan_site_part spsp
           WHERE  spsp.table_site_part_id = c_site_part_objid
           AND    spsp.x_service_plan_id    = spe.sp_objid
           AND EXISTS(SELECT 1
                      FROM  gw1.ig_buckets ib
                      WHERE ib.BUCKET_ID = REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3)
                      AND   ib.rate_plan = c_rate_plan)
          --CR56512 changes end
		   UNION
		  --CR55066, for Simple Mobile hotspot bucket creating. Springfarm sends bucket values for hotspot devices
		  SELECT
			sp.objid,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 1) col1,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 2) col2,
            mv.DATA_BUCKET_NAME                           col3,
            mv.DATA_BUCKET_VALUE                          col4
	    ,def.display_name	sp_feature_bucket_name
          FROM
          --x_service_plan_site_part spsp,
            x_service_plan sp,
            x_service_plan_feature spf,
            x_serviceplanfeaturevalue_def def,
            x_serviceplanfeature_value value,
            x_serviceplanfeaturevalue_def def2,
            sa.service_plan_feat_pivot_mv mv
          WHERE 1                         =1
          and sp.objid = MV.SERVICE_PLAN_OBJID
         -- AND spsp.table_site_part_id     = c_site_part_objid
          AND sp.objid                    in (select sa.get_service_plan_id ( f_esn      => (select txsp.x_service_id from table_site_part txsp where txsp.objid = c_site_part_objid),
                                                                   f_red_code => rd.x_red_code )
                                                   from sa.table_x_red_card rd, sa.table_x_call_trans ct
                                                   where rd.RED_CARD2CALL_TRANS = ct.objid
                                                   and ct.objid = c_call_trans_objid)
          AND spf.SP_FEATURE2SERVICE_PLAN = sp.objid
          AND def.objid                   = spf.sp_feature2rest_value_def
          AND value.spf_value2spf         = spf.objid
          AND def2.objid                  = value.VALUE_REF
          and exists(select 1
                       from gw1.ig_buckets ib
                       where ib.BUCKET_ID = def2.value_name
                         and ib.rate_plan = c_rate_plan)
          and  exists(select 1
                         from   table_x_call_trans ct
                         where  ct.objid = c_call_trans_objid
                         and    ct.x_reason in ('ADD_ON')
                         and    sa.customer_info.get_bus_org_id(i_esn => ct.x_service_id) IN ('SIMPLE_MOBILE')
                         and sa.device_util_pkg.is_hotspots((select txsp.x_service_id from table_site_part txsp where txsp.objid = c_site_part_objid)) = 0 ); --CR55066, to capture Simple mobile hotspot buckets
          -- End CR55066
        benefit_test_rec benefit_curs%rowtype;


        --CR30864 - Safelink IVR SOC Removal
        CURSOR check_sl_curs(c_esn IN table_x_call_trans.x_service_id%TYPE)
        IS
          SELECT slcur.*
        FROM x_sl_currentvals slcur, x_program_enrolled pe
        WHERE 1 = 1
        AND slcur.x_current_esn = c_esn
        AND slcur.x_current_esn = pe.x_esn
        AND pe.x_enrollment_status = 'ENROLLED';
        check_sl_rec check_sl_curs%ROWTYPE;
        --CR30864 - Safelink IVR SOC Removal

                                    -- CR29587 ATT Carrier Switch
        CURSOR bucket_curs (c_rate_plan in varchar2,
                            c_site_part_objid IN NUMBER,
                            c_voice_units ig_transaction_buckets.bucket_balance%TYPE,
                            c_text_units ig_transaction_buckets.bucket_balance%TYPE,
                            c_data_units ig_transaction_buckets.bucket_balance%TYPE) IS
         SELECT DISTINCT
                socs.x_soc_id bucket_id,
                decode(socs.x_soc, 'VOICE', c_voice_units, 'MESSAGE', c_text_units, 'DATA', c_data_units *1024) bucket_value,
                decode(socs.x_soc, 'VOICE', c_voice_units, 'MESSAGE', c_text_units, 'DATA', c_data_units *1024) bucket_balance
        FROM    adfcrm_serv_plan_feat_matview spf, x_service_plan_site_part spsp,
                x_mtm_socs socs
        WHERE  1=1
        AND spsp.table_site_part_id = c_site_part_objid
        AND spf.sp_objid = spsp.x_service_plan_id
        AND socs.x_rate_plan = c_rate_plan
        AND spf.fea_value = socs.x_soc;
        bucket_info_rec bucket_curs%rowtype;

        CURSOR NET10_HOTSPOT_BUCKETS  (c_table_site_part_id IN NUMBER,  --CR47587
                                       c_rate_plan VARCHAR2,
                                       c_action_item_id IN VARCHAR2 ) IS
        SELECT DISTINCT                          /*+ use_invisible_indexes */
                        sp.objid,
                        sp.mkt_name,
                        sp.description,
                        spfvdef.value_name,
                        spfvdef2.value_name property_value,
                        igb.bucket_id,ig.rate_plan,ig.transaction_id
           FROM x_serviceplanfeaturevalue_def spfvdef,
                x_serviceplanfeature_value spfv,
                x_service_plan_feature spf,
                x_serviceplanfeaturevalue_def spfvdef2,
                x_service_plan sp,
                x_service_plan_site_part spsp,
                ig_transaction ig,
                ig_buckets igb
          WHERE     1 = 1
            AND ig.action_item_id = c_action_item_id        --'1484769007'
            AND ig.rate_plan=igb.rate_plan
            AND igb.ACTIVE_FLAG='Y'
            AND ig.action_item_id = c_action_item_id
            AND spsp.table_site_part_id = c_table_site_part_id --1642705406
            and igb.rate_plan =  c_rate_plan --'TF_4G_FTE_4GMBB'
            AND spsp.x_service_plan_id = sp.objid
            AND spf.sp_feature2service_plan = sp.objid
            AND spf.sp_feature2rest_value_def = spfvdef.objid
            AND spf.objid = spfv.spf_value2spf
            AND SPFVDEF2.OBJID = SPFV.VALUE_REF
            AND spfvdef.value_name in( 'SERVICE DAYS','DATA')
            ;

        -- CR29587 ATT Carrier Switch

                                -- CR33864 ATT Carrier Switch populate Language field in IG_TRANSACTION start
                                CURSOR c_get_lang (c_action_item_id IN VARCHAR2)
                                                IS
                                                SELECT DISTINCT /*+ use_invisible_indexes */
                                                                   sp.objid,
                                                                   sp.mkt_name,
                   sp.description,
                   spfvdef.value_name,
                   spfvdef2.value_name property_value
              FROM x_serviceplanfeaturevalue_def spfvdef,
                                                                   x_serviceplanfeature_value spfv,
                                           x_service_plan_feature spf,
                                           x_serviceplanfeaturevalue_def spfvdef2,
                                           x_service_plan sp,
                                           x_service_plan_site_part spsp,
                                           table_site_part tsp,
                                           ig_transaction ig,
                                           table_task tt
             WHERE 1 = 1
                                                --AND    tt.objid = '1863578109'
               AND ig.action_item_id = c_action_item_id--'1484769007'
                                                   AND tt.task_id = ig.action_item_id
                                                   AND ig.esn = tsp.x_service_id
                                       AND tsp.OBJID = spsp.TABLE_SITE_PART_ID
                                       AND spsp.x_service_plan_id = sp.objid
                                       AND spf.sp_feature2service_plan = sp.objid
                                       AND spf.sp_feature2rest_value_def = spfvdef.objid
                                       AND spf.objid = spfv.spf_value2spf
                                       AND SPFVDEF2.OBJID = SPFV.VALUE_REF
                                       AND spfvdef.value_name ='BENEFIT_TYPE';

          CURSOR  c_get_e911( ip_esn IN VARCHAR2)
          IS
          SELECT ta.*
          FROM sa.X_E911_ESN  E911,sa.TABLE_ADDRESS TA
          WHERE 1=1
          AND E911.ESN2E911ADDRESS=ta.address2e911
          AND E911.X_ESN= ip_esn;


   --c_get_lang_rec c_get_lang%rowtype;

   -- CR33864 ATT Carrier Switch populate Language field in IG_TRANSACTION end

   order_type                 VARCHAR2(200);
   tmo_flex_order_type        VARCHAR2(200);
   l_carr_feat_objid          NUMBER;
   v_raw_benefit              BOOLEAN := FALSE;

   v_in_voice_units           ig_transaction_buckets.bucket_balance%TYPE := NULL;
   v_in_text_units            ig_transaction_buckets.bucket_balance%TYPE := NULL;
   v_in_data_units            ig_transaction_buckets.bucket_balance%TYPE := NULL;
   l_bus_org_id               varchar2(30);
   e911_rec                   c_get_e911%ROWTYPE;
   v_LANGUAGE                 ig_transaction.LANGUAGE%TYPE;
   l_error_message            varchar2(1000);

   lv_data_promo_code         table_x_promotion.x_promo_code%type;             --CR46315
   lv_multi_data_promo_code   table_x_promotion.x_promo_code%type;             --CR46315
   lv_multi_data_promo_objid  table_x_promotion.objid%type;                    --CR46315
   lv_data_promo_objid        table_x_promotion.objid%type;                    --CR46315
   lv_promo_error_code        VARCHAR2(2);                                     --CR46315
   lv_promo_error_msg         VARCHAR2(300);                                   --CR46315
   lv_data_multiplier         NUMBER := 1;                                     --CR46315
   lv_promo_error_text        VARCHAR2(2000);                                  --CR46315
   lv_sp_promo_bucket_feat    x_serviceplanfeaturevalue_def.display_name%type; --CR46315
   lv_data_bucket_value       VARCHAR2(30);                                    --CR46315
   lv_bucket_active_days      NUMBER;                                          --CR46315
   lv_promo_bucket_expr_date  DATE;                                            --CR46315
   lv_multi_data_bucket_id    VARCHAR2(30 BYTE);                               --CR46315
   o_response                 VARCHAR2(1000);
   v_get_lang                 VARCHAR2(100);
   -- CR45740
   LV_DATA_SAVER              ig_transaction.data_saver%type;
   LV_DATA_SAVER_CODE         ig_transaction.data_saver_code%type;
   LV_NON_DATA_SAVER_CNT      NUMBER;
   -- CR45740
   v_bucket_value             ig_transaction_buckets.bucket_value%TYPE;         --CR47587
   V_EXPIRATION_DATE          ig_transaction_buckets.expiration_date%TYPE;      --CR47587
   o_error_code               NUMBER;                                           --CR48373
   o_error_message            VARCHAR2(300);                                    --CR48373
   c_skip_insert_flag         VARCHAR2(1) :=  'Y' ;                             --CR49087
   c_create_buckets_flag      x_ig_order_type.create_buckets_flag%TYPE;         --CR52905
   l_switch_base_rate         table_x_carrier_features.x_switch_base_rate%TYPE; --CRC87016
   l_rc_number                ig_transaction.rate_center_no%TYPE := NULL; --CR51707
   v_exp_upd_flg              VARCHAR2(1) ;                             --CR55886
   cust_type                  sa.customer_type;                         --CR55886

BEGIN
  --CR54864
  sp_ig_trans_payload( p_task_objid         ,
                       p_order_type_objid   ,
                       p_application_system ,
                       in_service_days      ,
                       in_voice_units       ,
                       in_text_units        ,
                       in_data_units        ,
                       in_free_service_days ,
                       in_free_voice_units  ,
                       in_free_text_units   ,
                       in_free_data_units   );

    --private_global_task_objid := p_task_objid;
    --
    OPEN task_curs(p_task_objid);
      FETCH task_curs INTO task_rec;
      IF task_curs%NOTFOUND THEN
        p_status := 1;
        CLOSE task_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        RETURN;
      END IF;
    CLOSE task_curs;
    --
    dbms_output.put_line('task_rec.x_task2x_order_type:'||task_rec.x_task2x_order_type);
    --
    OPEN order_type_curs(NVL(p_order_type_objid,task_rec.x_task2x_order_type));
      FETCH order_type_curs INTO order_type_rec;
      IF order_type_curs%NOTFOUND THEN
        p_status := 2;
        CLOSE order_type_curs;
        INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
        VALUES ( 'order_type_curs%NOTFOUND', sysdate, 'order_type_curs(' ||p_order_type_objid ||')' , p_task_objid, 'igate.sp_insert_ig_transaction');
        RETURN;
      END IF;
    CLOSE order_type_curs;
    --
    dbms_output.put_line('order_type_rec.x_order_type:'||order_type_rec.x_order_type);
    dbms_output.put_line('order_type_rec.objid:'||order_type_rec.objid);
    dbms_output.put_line('task_rec.objid:'||task_rec.objid);
    --
    order_type    := sf_get_ig_order_type('SP_INSERT_IG_TRANSACTION' ,task_rec.objid ,order_type_rec.x_order_type);
    IF order_type IS NULL THEN
      INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
      VALUES ( 'order_type is null', sysdate, 'sf_get_ig_order_type(' ||'SP_INSERT_IG_TRANSACTION,' ||task_rec.objid ||',' || order_type_rec.x_order_type
              ||')' , p_task_objid, 'igate.sp_insert_ig_transaction');
      RETURN;
    END IF;
    dbms_output.put_line('order_type:'||order_type);

    --CR52905 Get the bucket creation flag for the order type
    c_create_buckets_flag := get_create_buckets_flag ( in_order_type => order_type );

   --
    OPEN carrier_curs(order_type_rec.x_order_type2x_carrier);
      FETCH carrier_curs INTO carrier_rec;
      IF carrier_curs%NOTFOUND THEN
        p_status := 3;
        CLOSE carrier_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        RETURN;
      END IF;
    CLOSE carrier_curs;
    dbms_output.put_line('carrier_rec.x_mkt_submkt_name:'||carrier_rec.x_mkt_submkt_name);
    --
    OPEN carrier_group_curs(carrier_rec.carrier2carrier_group);
      FETCH carrier_group_curs INTO carrier_group_rec;
      IF carrier_group_curs%NOTFOUND THEN
        p_status := 4;
        CLOSE carrier_group_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        RETURN;
      END IF;
    CLOSE carrier_group_curs;
    --
    OPEN parent_curs(carrier_group_rec.X_CARRIER_GROUP2X_PARENT);
      FETCH parent_curs INTO parent_rec;
      IF parent_curs%NOTFOUND THEN
        p_status := 5;
        CLOSE parent_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        RETURN;
      END IF;
    CLOSE parent_curs;
    dbms_output.put_line('parent_rec.x_parent_name:'||parent_rec.x_parent_name);
    dbms_output.put_line('parent_rec.objid:'||parent_rec.objid);
    --
    OPEN call_trans_curs(task_rec.x_task2x_call_trans);
      FETCH call_trans_curs INTO call_trans_rec;
      IF call_trans_curs%NOTFOUND THEN
        p_status := 6;
        CLOSE call_trans_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        RETURN;
      END IF;
    CLOSE call_trans_curs;
    dbms_output.put_line('call_trans_rec.X_CALL_TRANS2CARRIER:'||call_trans_rec.X_CALL_TRANS2CARRIER);
    dbms_output.put_line('call_trans_rec.x_action_type:'||call_trans_rec.x_action_type);
    dbms_output.put_line('call_trans_rec.ota_activation:'||call_trans_rec.ota_activation);
    dbms_output.put_line('call_trans_rec.call_trans2site_part:'||call_trans_rec.call_trans2site_part);
    --
    OPEN site_part_curs(call_trans_rec.call_trans2site_part);
      FETCH site_part_curs INTO site_part_rec;
      IF site_part_curs%NOTFOUND THEN
        p_status := 7;
        CLOSE site_part_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        RETURN;
      END IF;
    CLOSE site_part_curs;
    dbms_output.put_line('site_part_rec.x_min:'||site_part_rec.x_min);
    dbms_output.put_line('site_part_rec.x_service_id:'||site_part_rec.x_service_id);
    dbms_output.put_line('site_part_rec.x_pin:'||site_part_rec.x_pin);
    --
    IF call_trans_rec.x_action_type IN ('1' ,'2' ,'3') THEN
      OPEN old_min_curs(call_trans_rec.x_service_id);
        FETCH old_min_curs INTO old_min_rec;
        IF old_min_curs%NOTFOUND THEN
          dbms_output.put_line('old_min_curs%NOTFOUND');
        ELSE
          dbms_output.put_line('old_min_rec.x_min:'|| old_min_rec.x_min);
        END IF;
      CLOSE old_min_curs;
    END IF;
    --
    IF order_type IN ('EPIR', 'PIR') THEN                                      --'PIC' ,'EPIC',
      OPEN alt_min_curs(site_part_rec.x_service_id, order_type);
        FETCH alt_min_curs INTO alt_min_rec;
        IF alt_min_curs%NOTFOUND THEN
          dbms_output.put_line('alt_min_curs%NOTFOUND');
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        ELSE
          IF alt_min_rec.min    IS NOT NULL AND order_type IN ('EPIR', 'PIR') THEN
            site_part_rec.x_min := alt_min_rec.min;
          END IF;
          IF alt_min_rec.pin IS NOT NULL AND order_type = 'EPIR' THEN
            dbms_output.put_line('change site_part_rec.x_pin:'||site_part_rec.x_pin);
            site_part_rec.x_pin := alt_min_rec.pin;
          END IF;
        END IF;
      CLOSE alt_min_curs;
      dbms_output.put_line('site_part_rec.x_min changed to:'|| alt_min_rec.min||' because of ordertype:'|| order_type_rec.x_order_type);
      dbms_output.put_line('order_type:'||order_type);
      dbms_output.put_line('alt_min_rec.s_title:'||alt_min_rec.s_title);
      dbms_output.put_line('alt_min_rec.first_name:'||alt_min_rec.first_name);
      dbms_output.put_line('alt_min_rec.last_name:'||alt_min_rec.last_name);
      dbms_output.put_line('alt_min_rec.account:'||alt_min_rec.account);
      dbms_output.put_line('alt_min_rec.add1:'||alt_min_rec.add1);
      dbms_output.put_line('alt_min_rec.add2:'||alt_min_rec.add2);
      dbms_output.put_line('alt_min_rec.pin:'||alt_min_rec.pin);
      dbms_output.put_line('alt_min_rec.zip:'||alt_min_rec.zip);
    END IF;
    --
    dbms_output.put_line('site_part_rec.site_part2part_info:'||site_part_rec.site_part2part_info);
    dbms_output.put_line('site_part_rec.n_part_inst2part_mod:'||site_part_rec.n_part_inst2part_mod);
    OPEN part_num_curs(NVL(site_part_rec.n_part_inst2part_mod,site_part_rec.site_part2part_info));
      FETCH part_num_curs INTO part_num_rec;
      IF part_num_curs%NOTFOUND THEN
        p_status := 9;
        CLOSE part_num_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        RETURN;
      END IF;
    CLOSE part_num_curs;
    dbms_output.put_line('site_part_rec.x_zipcode:'|| site_part_rec.x_zipcode );
    --
    OPEN old_esn_curs(site_part_rec.x_service_id,part_num_rec.org_id);
      FETCH old_esn_curs INTO old_esn_rec;
      IF old_esn_curs%NOTFOUND THEN
        dbms_output.put_line('old_esn_curs%NOTFOUND');
      ELSE
        dbms_output.put_line('old_esn_rec.esn:'||old_esn_rec.esn);
      END IF;
    CLOSE old_esn_curs;
    --
    OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile,part_num_rec.x_technology);
      FETCH trans_profile_curs INTO trans_profile_rec;
      IF trans_profile_curs%NOTFOUND THEN
        p_status := 10;
        CLOSE trans_profile_curs;
        INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
        VALUES ( 'trans_profile_curs%NOTFOUND', sysdate, 'trans_profile_curs(' ||order_type_rec.x_order_type2x_trans_profile ||','
            || part_num_rec.x_technology ||')' , p_task_objid, 'igate.sp_insert_ig_transaction');
        RETURN;
      END IF;
    CLOSE trans_profile_curs;
    --
    IF part_num_rec.x_technology = 'GSM' AND parent_rec.x_parent_id IN ('6' ,'71' ,'76','1000000266') AND NVL(parent_rec.x_next_available,0) = 1
       AND carrier_rec.x_next_avail_carrier = 1 THEN
      dbms_output.put_line('cingular order_type');
      OPEN c_nap_rc(site_part_rec.x_zipcode );
        FETCH c_nap_rc INTO c_nap_rc_rec;
        IF c_nap_rc%notfound THEN
          dbms_output.put_line('NOT FOUND c_nap_rc:'||site_part_rec.x_zipcode);
          INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
          VALUES ( 'c_nap_rc%NOTFOUND', sysdate, 'c_nap_rc(' ||site_part_rec.x_zipcode ||')' , p_task_objid, 'igate.sp_insert_ig_transaction');
        ELSE
          order_type_rec.x_ld_account_num := c_nap_rc_rec.account_num;
          order_type_rec.x_market_code    := c_nap_rc_rec.market_code;
          order_type_rec.x_dealer_code    := c_nap_rc_rec.dealer_code;
          trans_profile_rec.template      := c_nap_rc_rec.template;
        END IF;
      CLOSE c_nap_rc;
    END IF;

	--CR51707.
	IF upper(parent_rec.x_parent_name) LIKE 'T_MOB%' THEN

	   OPEN c_tmo_ngp_rc(site_part_rec.x_zipcode );
	   FETCH c_tmo_ngp_rc INTO c_tmo_ngp_rec;

	      IF c_tmo_ngp_rc%NOTFOUND THEN

		 dbms_output.put_line('NOT FOUND c_tmo_ngp_rc:'||site_part_rec.x_zipcode);

      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
	      END IF;

	   CLOSE c_tmo_ngp_rc;

	END IF;
    --
    -- TF Surepay CR23513
    IF part_num_rec.org_id                                                  = 'TRACFONE' THEN
      IF sa.device_util_pkg.get_smartphone_fun(call_trans_rec.x_service_id) = 0 AND trans_profile_rec.template = 'RSS' THEN
        trans_profile_rec.template                                         := 'SUREPAY';
      END IF;
    END IF;
    --
    IF (order_type IN ('E' ,'PIR' ,'EPIR' ,'IPI') AND NVL(part_num_rec.STRAIGHT_TALK_flag,0) = 1)
	OR order_type IN ('AP' ,'PAP' ,'CR' ,'CRU' ,'EU' ,'PCR' ,'ACR' ,'DB')
	OR get_safelink_batch_flag(i_order_type=>order_type) ='Y' --CR52803 enable new order type similar to CR-Credit
	OR (order_type = 'A' AND trans_profile_rec.template = 'SUREPAY') THEN
      OPEN ld_curs(call_trans_rec.objid);
        FETCH ld_curs INTO ld_rec;
      CLOSE ld_curs;
    ELSE
      ld_rec.rsid := carrier_rec.x_ld_pic_code;
    END IF;
    dbms_output.put_line('ld_rec.rsid:'||ld_rec.rsid);
    dbms_output.put_line('ld_rec.x_value:'||ld_rec.x_value);
    dbms_output.put_line('carrier_rec.x_ld_pic_code:'||carrier_rec.x_ld_pic_code);
    --
    dbms_output.put_line('carrier_rec.objid:' || carrier_rec.objid);
    dbms_output.put_line('part_num_rec.x_technology:' || part_num_rec.x_technology);
    dbms_output.put_line('part_num_rec.data_speed:' || part_num_rec.data_speed);
    dbms_output.put_line('part_num_rec.bus_org_objid:' || part_num_rec.bus_org_objid);
    --
    dbms_output.put_line('order_type_rec.x_dealer_code:'||order_type_rec.x_dealer_code);
    dbms_output.put_line('part_num_rec.part_number:' || part_num_rec.part_number);
    dbms_output.put_line('part_num_rec.org_id:' || part_num_rec.org_id);
    dbms_output.put_line('part_num_rec.x_data_capable:' || part_num_rec.x_data_capable);
    --
    v_LANGUAGE:= sa.get_lang(task_rec.task_id);
    dbms_output.put_line  ('Language value for '||task_rec.task_id ||'is'|| v_LANGUAGE);
    --
    OPEN new_transaction_id_curs;
      FETCH new_transaction_id_curs INTO new_transaction_id_rec;
      IF new_transaction_id_curs%NOTFOUND THEN
        CLOSE new_transaction_id_curs;
        INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
        VALUES ( 'new_transaction_id_curs%NOTFOUND', sysdate, 'new_transaction_id_curs' , p_task_objid, 'igate.sp_insert_ig_transaction');
        RETURN;
      END IF;
    CLOSE new_transaction_id_curs;
    --CR40522
    -- cwl 7/7/2016
    --if order_type not in ( 'RMHL', 'S', 'SI', 'SIMC', 'UI', 'VD', 'VP', 'IPRL',  'I', 'IDD', 'E911', 'D', 'DI', 'APN', 'BI', 'F') then
    -- if order_type not in ( 'RMHL', 'S', 'SI', 'SIMC', 'UI', 'VD', 'VP', 'IPRL',  'I', 'IDD', 'E911', 'D', 'DI', 'APN', 'F') then
    -- CR45298 SUI allowing features for order type UI
     if order_type not in ( 'RMHL', 'S', 'SI', 'SIMC', 'VD', 'VP', 'IPRL',  'I', 'IDD', 'E911', 'D', 'DI', 'APN', 'F') then
      OPEN carrier_features_curs1(carrier_rec.objid ,part_num_rec.x_technology ,part_num_rec.bus_org_objid ,part_num_rec.data_speed, order_type);
        FETCH carrier_features_curs1 INTO carr_feature_rec1;
        IF carrier_features_curs1%NOTFOUND THEN
          carr_feature_rec1.objid := NULL;
		  --CODE Changes for CR55230
          --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
          --VALUES ( 'carrier_features_curs1%NOTFOUND', sysdate, 'carrier_features_curs1(' || carrier_rec.objid ||',' || part_num_rec.x_technology ||','
          --   || part_num_rec.bus_org_objid ||',' || part_num_rec.data_speed ||',' || order_type ||')', p_task_objid, 'igate.sp_insert_ig_transaction');
		  --CODE Changes for CR55230
        END IF;
      CLOSE carrier_features_curs1;
      --
      IF carr_feature_rec1.objid IS NULL THEN
        OPEN carrier_features_curs2(carrier_rec.objid ,part_num_rec.x_technology ,part_num_rec.bus_org_objid ,part_num_rec.data_speed, order_type);
          FETCH carrier_features_curs2 INTO carr_feature_rec1;
          IF carrier_features_curs2%NOTFOUND THEN
            carr_feature_rec1.objid := NULL;
			--CODE Changes for CR55230
            --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
            --VALUES ( 'carrier_features_curs2%NOTFOUND FOR NET10', sysdate, 'carrier_features_curs2(' || carrier_rec.objid ||',' || part_num_rec.x_technology ||','
            --  || part_num_rec.bus_org_objid ||',' || part_num_rec.data_speed ||',' || order_type ||')', p_task_objid, 'igate.sp_insert_ig_transaction');
			--CODE Changes for CR55230
          END IF;
        CLOSE carrier_features_curs2;
      END IF;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      --
      dbms_output.put_line('carr_features_rec1.col1:'||carr_feature_rec1.col1);
      dbms_output.put_line('pre sf_get_carr_feat:'|| carr_feature_rec1.objid);
      dbms_output.put_line('order_type:'||order_type);
      dbms_output.put_line('part_num_rec.STRAIGHT_TALK_flag:'|| part_num_rec.STRAIGHT_TALK_flag );
      dbms_output.put_line('call_trans_rec.call_trans2site_part:'||call_trans_rec.call_trans2site_part);
      dbms_output.put_line('call_trans_rec.x_service_id:'||call_trans_rec.x_service_id);
      dbms_output.put_line ('call_trans_rec.x_call_trans2carrier:'||call_trans_rec.x_call_trans2carrier);
      dbms_output.put_line('carr_feature_rec1.objid:'|| carr_feature_rec1.objid );
      dbms_output.put_line('part_num_rec.data_speed:'||part_num_rec.data_speed);
      dbms_output.put_line('trans_profile_rec.template:'|| trans_profile_rec.template );
      --
      l_carr_feat_objid := sf_get_carr_feat(order_type , --P_ORDER_TYPE
          part_num_rec.STRAIGHT_TALK_flag,                   --l_st_esn_count ,                                   --P_ST_ESN_FLAG
          call_trans_rec.call_trans2site_part ,              --P_SITE_PART_OBJID
          call_trans_rec.x_service_id ,                      --P_ESN
          call_trans_rec.x_call_trans2carrier ,              --P_CARRIER_OBJID
          null, --carr_feature_rec1.objid ,                          --P_CARR_FEATURE_OBJID
          part_num_rec.data_speed ,                          --P_DATA_CAPABLE
          trans_profile_rec.template ,                       --P_TEMPLATE
          NULL                                               --P_SERVICE_PLAN_ID
	  ,p_task_objid						--CR46807
          );
      dbms_output.put_line('post sf_get_carr_feat:'|| l_carr_feat_objid);
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
      --CR30338
      IF carr_feature_rec.non_ppe = 1 AND upper(parent_rec.x_parent_name) LIKE 'T_MOB%' AND order_type_rec.x_order_type = 'Credit' THEN
        tmo_flex_order_type      := sf_get_ig_order_type('TMO_FLEX' ,task_rec.objid ,order_type_rec.x_order_type);
        IF NVL(tmo_flex_order_type ,'NONE FOUND') IN ('CR','ACR','PCR') THEN
          order_type := tmo_flex_order_type;
        ELSE
          INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
          VALUES ( 'tmo_flex_order_type=' ||tmo_flex_order_type, sysdate, 'sf_get_ig_order_type(''TMO_FLEX'' ,' ||task_rec.objid ||','
                  ||order_type_rec.x_order_type ||')', p_task_objid, 'igate.sp_insert_ig_transaction');
        END IF;
      END IF;
      --CR30338
      OPEN carrier_features_curs (NVL(l_carr_feat_objid,NVL(carr_feature_rec1.objid,-100)));
        FETCH carrier_features_curs INTO carr_feature_rec;
        IF carrier_features_curs%notfound THEN
          CLOSE carrier_features_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
          RETURN;
        END IF;
      CLOSE carrier_features_curs;

      --CR45740
	IF order_type IN ('E','A','PAP','AP','EU')	-- Activation related order types also used during upgrade
	THEN

		sa.PROMOTION_PKG.UPDATE_PROMO_HIST(call_trans_rec.x_service_id
				,lv_promo_error_code
				,lv_promo_error_msg
				);
	END IF;

/* Commenting as part of SUI On Demand
CR48373

	BEGIN

		SELECT COUNT(1)
		INTO LV_NON_DATA_SAVER_CNT
		FROM X_ESN_PROMO_HIST PROMO_HIST
		WHERE PROMO_HIST.ESN = site_part_rec.x_service_id
		AND PROMO_HIST.PROMO_HIST2X_PROMOTION  = (SELECT OBJID	FROM TABLE_X_PROMOTION
								WHERE 1 = 1
								AND X_PROMO_CODE = 'RDS')
		AND NVL(PROMO_HIST.EXPIRATION_DATE,SYSDATE + 1)		>	SYSDATE
		;


	EXCEPTION WHEN OTHERS
	THEN

		LV_NON_DATA_SAVER_CNT	:=	0;

	END;




	IF NVL(carr_feature_rec.data_saver,'0') = '1'
	THEN
		IF LV_NON_DATA_SAVER_CNT		<>	'0'
		THEN

			LV_DATA_SAVER			:=	'N';
			LV_DATA_SAVER_CODE		:=	carr_feature_rec.data_saver_code;

		ELSE

			LV_DATA_SAVER			:= 	'Y';
			LV_DATA_SAVER_CODE		:=  	carr_feature_rec.data_saver_code;
		END IF;

	ELSIF carr_feature_rec.data_saver	=	'0'
	THEN

		LV_DATA_SAVER			:=	'N';
		LV_DATA_SAVER_CODE		:=	carr_feature_rec.data_saver_code;


	ELSE

		LV_DATA_SAVER			:=	NULL;
		LV_DATA_SAVER_CODE		:=	NULL;



	END IF;

*/
      --- get data saver information from the new procedure
      get_data_saver_information ( i_esn                      => site_part_rec.x_service_id ,
                                   i_carrier_features_objid   => carr_feature_rec.objid   ,
                                   o_data_saver_flag          => lv_data_saver,
                                   o_data_saver_code          => lv_data_saver_code );
--CR48373 END

      --CR45740
      --
      IF order_type='R' AND call_trans_rec.x_action_type = '6' AND part_num_rec.org_id != 'NET10' THEN
        OPEN same_rate_plan_curs(call_trans_rec.objid);
          FETCH same_rate_plan_curs INTO same_rate_plan_rec;
          IF same_rate_plan_curs%found AND carr_feature_rec.x_rate_plan = same_rate_plan_rec.rate_plan THEN
            CLOSE same_rate_plan_curs;
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
            RETURN;
          END IF;
        CLOSE same_rate_plan_curs;
      END IF;

	  --CR51707
	  IF upper(parent_rec.x_parent_name) LIKE 'T_MOB%' THEN

	     l_rc_number := c_tmo_ngp_rec.x_ngp;
	     dbms_output.put_line('TMO Rate center :'||l_rc_number);

	  ELSE
	     l_rc_number := c_nap_rc_rec.rc_number;
		 dbms_output.put_line('Other carrier Rate center :'||l_rc_number);
	  END IF;
      --
      OPEN chk_need_dep_igtx_curs(call_trans_rec.x_service_id);
        FETCH chk_need_dep_igtx_curs INTO chk_need_dep_igtx_rec;
        IF chk_need_dep_igtx_curs%FOUND AND chk_need_dep_igtx_rec.rate_plan != carr_feature_rec.x_rate_plan THEN
          INSERT INTO gw1.ig_dependent_transaction (
              objid ,
              dep_transaction_id , -- same objid sequence which is used for IG_TX as eventually this record will be moved to IG_TX
              dep_action_item_task_id ,
              dep_trans_prof_key ,
              dep_carrier_id ,
              dep_state_field ,
              dep_order_type ,
              dep_old_min ,
              dep_min ,
              dep_msid ,
              dep_zip_code ,
              dep_iccid ,
              dep_esn ,
              dep_esn_hex ,
              dep_old_esn ,
              dep_old_esn_hex ,
              dep_account_num ,
              dep_market_code ,
              dep_dealer_code ,
              dep_template ,
              dep_transmission_method ,
              dep_fax_num ,
              dep_fax_num2 ,
              dep_online_num ,
              dep_online_num2 ,
              dep_email ,
              dep_network_login ,
              dep_network_password ,
              dep_system_login ,
              dep_system_password ,
              dep_fax_batch_size ,
              dep_fax_batch_q_time ,
              dep_voice_mail ,
              dep_voice_mail_package ,
              dep_caller_id ,
              dep_caller_id_package ,
              dep_call_waiting ,
              dep_call_waiting_package ,
              dep_sms ,
              dep_sms_package ,
              dep_digital_feature ,
              dep_digital_feature_code ,
              x_mpn,
              x_mpn_code,
              x_pool_name,
              dep_rate_plan ,
              dep_end_user ,
              dep_pin ,
              dep_phone_manf ,
              dep_technology_flag ,
              dep_expidite ,
              dep_ld_provider ,
              dep_tux_iti_server ,
              dep_q_transaction ,
              dep_com_port ,
              dep_status , -- for now we have only 'S'
              dep_status_message ,
              dep_ota_type ,
              dep_rate_center_no ,
              dep_application_system ,
              dep_balance ,
              -- extra values
              dep_creation_date ,
              dep_update_date ,
              dep_blackout_wait ,
              ig_depend2ig_trans , -- transaction _id of IG_TX
              parent_action_item_id
	      ,dep_data_saver		--CR45740
	      ,dep_data_saver_code	--CR45740
              )
              SELECT
              gw1.sequ_ig_tx_dependent.nextval,
              new_transaction_id_rec.transaction_id,
              task_rec.task_id ,
              trans_profile_rec.objid ,
              carrier_rec.x_carrier_id ,
              carrier_rec.x_state ,
              'R',
              old_min_rec.x_min,
              site_part_rec.x_min,
              get_msid_value(i_order_type => order_type, i_esn => site_part_rec.x_service_id, i_min => site_part_rec.x_min),
              site_part_rec.x_zipcode ,
              site_part_rec.iccid,
              site_part_rec.x_service_id,
              sa.igate.f_get_hex_esn(site_part_rec.x_service_id),
              old_esn_rec.esn,
              sa.igate.f_get_hex_esn( old_esn_rec.esn),
              order_type_rec.x_ld_account_num,
              order_type_rec.x_market_code,
              order_type_rec.x_dealer_code,
              trans_profile_rec.template,
              trans_profile_rec.transmit_method,
              trans_profile_rec.fax_number,
              trans_profile_rec.fax_num2,
              trans_profile_rec.online_number,
              trans_profile_rec.online_num2,
              trans_profile_rec.email,
              trans_profile_rec.network_login,
              trans_profile_rec.network_password,
              trans_profile_rec.system_login,
              trans_profile_rec.system_password,
              trans_profile_rec.batch_delay_max,
              trans_profile_rec.batch_quantity,
              carr_feature_rec.voice_mail ,
              carr_feature_rec.voice_mail_package ,
              carr_feature_rec.caller_id ,
              carr_feature_rec.caller_id_package ,
              carr_feature_rec.call_waiting ,
              carr_feature_rec.call_waiting_package ,
              carr_feature_rec.sms ,
              carr_feature_rec.sms_package ,
              carr_feature_rec.digital_feature ,
              carr_feature_rec.digital_feature_code ,
              carr_feature_rec.mpn ,
              carr_feature_rec.mpn_code ,
              carr_feature_rec.pool_name,
              carr_feature_rec.x_rate_plan,
              call_trans_rec.x_call_trans2user,
              site_part_rec.x_pin,
              part_num_rec.x_manufacturer,
              SUBSTR(part_num_rec.x_technology ,1 ,1) ,
              task_rec.x_expedite,
              ld_rec.rsid,
              NULL,
              'Y' ,
              'Queued' ,
              'Q',
              NULL ,
              call_trans_rec.ota_activation,
              l_rc_number, --CR51707
              p_application_system,
              ld_rec.x_value,
              -- extra values
              sysdate,
              sysdate,
              sysdate,
              chk_need_dep_igtx_rec.transaction_id ,
              chk_need_dep_igtx_rec.action_item_id
	      ,lv_data_saver		--CR45740
	      ,lv_data_saver_code	--CR45740
              FROM DUAL
              ;
        END IF;
      CLOSE chk_need_dep_igtx_curs;
    end if;
    IF order_type ='E911' THEN
      carr_feature_rec.digital_feature      := 'Y';
      carr_feature_rec.digital_feature_code := 'WFC';
    END IF;
    --
    INSERT INTO gw1.ig_transaction (
            transaction_id,
            action_item_id ,
            trans_prof_key ,
            carrier_id ,
            state_field ,
            order_type ,
            old_min ,
            MIN ,
            msid ,
            zip_code ,
            iccid ,
            esn ,
            esn_hex ,
            old_esn ,
            old_esn_hex ,
            account_num ,
            market_code ,
            dealer_code ,
            template ,
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
            fax_batch_size ,
            fax_batch_q_time ,
            voice_mail ,
            voice_mail_package ,
            caller_id ,
            caller_id_package ,
            call_waiting ,
            call_waiting_package ,
            sms ,
            sms_package ,
            digital_feature ,
            digital_feature_code ,
            X_MPN,
            X_MPN_CODE,
            X_POOL_NAME,
            rate_plan ,
            end_user ,
            pin,
            phone_manf ,
            technology_flag ,
            expidite ,
            ld_provider,
            tux_iti_server ,
            q_transaction,
            com_port ,
            status ,
            status_message ,
            ota_type ,
            rate_center_no ,     -- 04/29/05
            application_system , -- GSM Enhancement
            balance,
            LANGUAGE,
            data_saver,			--CR45740
            data_saver_code,		--CR45740
            carrier_feature_objid --CR48373
          )
    SELECT
            new_transaction_id_rec.transaction_id,
            task_rec.task_id ,
            trans_profile_rec.objid ,
            carrier_rec.x_carrier_id ,
            carrier_rec.x_state ,
            order_type,
            old_min_rec.x_min,
            site_part_rec.x_min,
            get_msid_value(i_order_type => order_type, i_esn => site_part_rec.x_service_id, i_min => site_part_rec.x_min),
            site_part_rec.x_zipcode ,
            site_part_rec.iccid,
            site_part_rec.x_service_id,
            sa.igate.f_get_hex_esn(site_part_rec.x_service_id),
            old_esn_rec.esn,
            sa.igate.f_get_hex_esn( old_esn_rec.esn),
            order_type_rec.x_ld_account_num,
            order_type_rec.x_market_code,
            order_type_rec.x_dealer_code,
            trans_profile_rec.template,
            trans_profile_rec.transmit_method,
            trans_profile_rec.fax_number,
            trans_profile_rec.fax_num2,
            trans_profile_rec.online_number,
            trans_profile_rec.online_num2,
            trans_profile_rec.email,
            trans_profile_rec.network_login,
            trans_profile_rec.network_password,
            trans_profile_rec.system_login,
            trans_profile_rec.system_password,
            trans_profile_rec.batch_delay_max,
            trans_profile_rec.batch_quantity,
            carr_feature_rec.voice_mail ,
            carr_feature_rec.voice_mail_package ,
            carr_feature_rec.caller_id ,
            carr_feature_rec.caller_id_package ,
            carr_feature_rec.call_waiting ,
            carr_feature_rec.call_waiting_package ,
            carr_feature_rec.sms ,
            carr_feature_rec.sms_package ,
            carr_feature_rec.digital_feature ,
            carr_feature_rec.digital_feature_code ,
            carr_feature_rec.mpn ,
            carr_feature_rec.mpn_code ,
            carr_feature_rec.pool_name,
            carr_feature_rec.x_rate_plan,
            call_trans_rec.x_call_trans2user,
            site_part_rec.x_pin,
            part_num_rec.x_manufacturer,
            SUBSTR(part_num_rec.x_technology ,1 ,1) ,
            task_rec.x_expedite,
            ld_rec.rsid,
            NULL,
            'Y' ,
            'Queued' ,
            'Q',
            NULL ,
            call_trans_rec.ota_activation,
            l_rc_number, --CR51707
            p_application_system,
            ld_rec.x_value,
	    v_LANGUAGE
	    ,lv_data_saver		--CR45740
	    ,lv_data_saver_code		--CR45740
            ,carr_feature_rec.objid --CR48373
          FROM DUAL;
dbms_output.put_line('carr_feature_rec.objid  :' ||carr_feature_rec.objid );
    -- if transaction was created successfully
    IF SQL%ROWCOUNT > 0 THEN
        -- set output response as null
      o_response := NULL;
        BEGIN
          -- CRC87016 Changes starts..
          -- Get the switch base rate and apply for a switch based trnsaction
          -- if CBO doesn't populate switch base rate in x_switchbased_transaction
          BEGIN
            SELECT  x_switch_base_rate
            INTO    l_switch_base_rate
            FROM    table_x_carrier_features
            WHERE   objid             = carr_feature_rec.objid
            AND     x_is_swb_carrier  = 1;
          EXCEPTION
            WHEN OTHERS THEN
              l_switch_base_rate  :=  0;
          END;
          --
          IF NVL(l_switch_base_rate,0)  > 0
          THEN
            --
            UPDATE  x_switchbased_transaction
            SET     x_value   =  l_switch_base_rate
            WHERE   x_sb_trans2x_call_trans = call_trans_rec.objid;
            --
            UPDATE  ig_transaction
            SET     balance   =  l_switch_base_rate
            WHERE   transaction_id  = new_transaction_id_rec.transaction_id;
            --
          END IF;
          -- CRC87016 Changes ends
          -- CR45249
          --create the ig transaction features (if applicable)
          IF NVL(carr_feature_rec.use_cf_extension_flag,'N') = 'Y'
          THEN
            -- CR49087 skip insert into ig_transaction_features table based on the order type
            c_skip_insert_flag    :=  CASE WHEN order_type = 'PFR'
                                           THEN 'N'
                                           ELSE 'Y'
                                      END;
            --
            igate.insert_ig_transaction_features (  i_transaction_id         => new_transaction_id_rec.transaction_id ,
                                                    i_carrier_features_objid => carr_feature_rec.objid                ,
                                                    i_skip_insert_flag       => c_skip_insert_flag,                     -- CR49087
                                                    o_response               => o_response                            );
          --
          END IF;
          DBMS_OUTPUT.PUT_LINE('insert_ig_transaction_features: o_response => ' || o_response);
          --
        END;
    END IF;
    --Added by phaneendra on 5/19/15 for the CR33844
    IF fn_cpo_source(site_part_rec.x_service_id )='CPO' THEN
      UPDATE ig_transaction
         SET phone_manf='CPO'
       WHERE action_item_id=task_rec.task_id;
      dbms_output.put_line  ('Phone Manufacture for CPO '||site_part_rec.x_service_id );
    ELSE
      dbms_output.put_line  ('Phone Manufacture is not a  CPO ');
      NULL;
    END IF;
    --
    IF order_type = 'E911' THEN
      OPEN  c_get_e911(site_part_rec.x_service_id);
        FETCH c_get_e911 INTO e911_rec;
        if c_get_e911%found then
          INSERT INTO gw1.ig_transaction_addl_info ( TRANSACTION_ID, ADDRESS_1, ADDRESS_2, CITY, STATE, ZIP_CODE)
          VALUES( new_transaction_id_rec.transaction_id, e911_rec.s_address, e911_rec.address_2, e911_rec.s_city, e911_rec.s_state, e911_rec.zipcode);
        end if;
      CLOSE c_get_e911;
    END IF;
    ---- CR33864 ATT Carrier Switch populate Language field in IG_TRANSACTION END
    --CR40522
    IF order_type = 'EPIR' THEN
      OPEN contact_curs(task_rec.task2contact);
        FETCH contact_curs INTO contact_rec;
        IF contact_curs%found THEN
          dbms_output.put_line('contact_rec.objid:'||contact_rec.objid);
          dbms_output.put_line('contact_rec.first_name:'||contact_rec.first_name);
          dbms_output.put_line('contact_rec.last_name:'||contact_rec.last_name);
          dbms_output.put_line('contact_rec.x_ss_number:'||contact_rec.x_ss_number);
          dbms_output.put_line('contact_rec.ADDRESS_1:'||contact_rec.ADDRESS_1);
          dbms_output.put_line('contact_rec.ADDRESS_2:'||contact_rec.ADDRESS_2);
          dbms_output.put_line('contact_rec.CITY:'||contact_rec.city);
          dbms_output.put_line('contact_rec.STATE:'||contact_rec.state);
          dbms_output.put_line('contact_rec.ZIPCODE:'||contact_rec.zipcode);
        -- else
      -- Removed error table insert statement : CR55771 : spagidala on 2018/02/22
        end if;
      CLOSE contact_curs;
      INSERT INTO gw1.ig_transaction_addl_info (
             OSP_ACCOUNT,
              CURR_ADDR_HOUSE_NUMBER,
              CURR_ADDR_DIRECTION,
              CURR_ADDR_STREET_NAME,
              CURR_ADDR_STREET_TYPE,
              CURR_ADDR_UNIT,
              TRANSACTION_ID,
              FIRST_NAME,
              MIDDLE_INITIAL,
              LAST_NAME,
              SUFFIX,
              PREFIX,
              SSN_LAST_4,
              ADDRESS_1,
              ADDRESS_2,
              CITY,
              STATE,
              ZIP_CODE,
              COUNTRY)
      VALUES (
              alt_min_rec.account,
              alt_min_rec.CURR_ADDR_HOUSE_NUMBER,
              alt_min_rec.CURR_ADDR_DIRECTION,
              alt_min_rec.CURR_ADDR_STREET_NAME,
              alt_min_rec.CURR_ADDR_STREET_TYPE,
              alt_min_rec.CURR_ADDR_UNIT,
              new_transaction_id_rec.transaction_id,
              alt_min_rec.first_name,
              NULL,
              alt_min_rec.last_name,
              NULL,
              NULL,
              contact_rec.x_ss_number,
              alt_min_rec.add1,
              alt_min_rec.add2,
              contact_rec.city,
              contact_rec.state,
              alt_min_rec.zip,
              contact_rec.country
            );
    END IF;

    --CR46315
	/* Moved up, before inserting into ig_transaction
	IF order_type IN ('E','A','PAP','AP','EU')	-- Activation related order types also used during upgrade
	THEN

		update_promo_hist(call_trans_rec.x_service_id
				,lv_promo_error_code
				,lv_promo_error_msg
				);
	END IF;
	*/
	BEGIN


		lv_data_multiplier	:=	1;

		sa.PROMOTION_PKG.SP_GET_ELIGIBLE_DATA_PROMO
		('HL_MULTI_DATA'
		,call_trans_rec.x_service_id
		,call_trans_rec.objid
		,call_trans_rec.x_action_type
		,order_type
		,lv_multi_data_promo_code
		,lv_multi_data_promo_objid
		,lv_promo_error_code
		,lv_promo_error_msg
		);

	EXCEPTION WHEN OTHERS
	THEN
		lv_multi_data_promo_code := NULL;

	END;

	IF lv_multi_data_promo_code IS NOT NULL
	THEN

		BEGIN

			SELECT NVL(X_UNITS,1)
			INTO lv_data_multiplier
			FROM TABLE_X_PROMOTION
			WHERE X_PROMO_CODE = lv_multi_data_promo_code
			AND X_PROMO_TYPE = 'HL_MULTI_DATA'
			;

		EXCEPTION WHEN OTHERS
		THEN
			lv_data_multiplier	:=	1;
		END;

	END IF;


	BEGIN




		sa.PROMOTION_PKG.SP_GET_ELIGIBLE_DATA_PROMO
		('HL_DATA_PROMO'
		,call_trans_rec.x_service_id
		,call_trans_rec.objid
		,call_trans_rec.x_action_type
		,order_type
		,lv_data_promo_code
		,lv_data_promo_objid
		,lv_promo_error_code
		,lv_promo_error_msg
		);

	EXCEPTION WHEN OTHERS
	THEN
		lv_data_promo_code := NULL;

	END;

	IF lv_data_promo_code IS NOT NULL
	THEN

		BEGIN

			SELECT X_PROMO_TECHNOLOGY , X_ACCESS_DAYS
			INTO lv_sp_promo_bucket_feat, lv_bucket_active_days
			FROM TABLE_X_PROMOTION
			WHERE X_PROMO_CODE = lv_data_promo_code
			AND X_PROMO_TYPE = 'HL_DATA_PROMO'
			;

		EXCEPTION WHEN OTHERS
		THEN
			lv_sp_promo_bucket_feat	:=	NULL;
		END;

	END IF;


	 --CR46315

    --CR52905 - Check added to block OUTBOUND buckets for BI transactions
  IF c_create_buckets_flag IN ('YES','SUI') -- #1
  THEN
    --
    benefit_test_rec.objid := null;
    --
    open benefit_curs (call_trans_rec.call_trans2site_part,
                       parent_rec.x_parent_name,
                       carr_feature_rec.non_ppe,
                       carr_feature_rec.x_rate_plan,
                       call_trans_rec.objid);
      fetch benefit_curs into benefit_test_rec;
    close benefit_curs;
    --
    if benefit_test_rec.objid is not null then
      dbms_output.put_line('ORDER_TYPE:'||ORDER_TYPE);
      FOR benefit_rec IN benefit_curs (call_trans_rec.call_trans2site_part,
                                       parent_rec.x_parent_name,
                                       carr_feature_rec.non_ppe,
                                       carr_feature_rec.x_rate_plan,
                                       call_trans_rec.objid) LOOP

        --CR46315
        IF lv_multi_data_promo_code	IS NOT NULL AND benefit_rec.sp_feature_bucket_name IN ('CARRIER_BUCKET','CARRIER_BUCKET_SHARED')	-- Multiply regular data.
        THEN

         lv_data_bucket_value		:=	benefit_rec.col4 * NVL(lv_data_multiplier,1);
         lv_multi_data_bucket_id		:=	benefit_rec.col3;

        ELSE

         lv_data_bucket_value	:=	benefit_rec.col4;

        END IF;
        --CR46315

        --IF NVL(get_ig_trans_buckets_ins_flag(CARR_FEATURE_REC.X_RATE_PLAN,ORDER_TYPE,benefit_rec.col3),'N') = 'Y' then --added by Rahul for CR36735
        IF get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => benefit_rec.col3) = 'Y' THEN --CR52905
          BEGIN
            INSERT INTO ig_transaction_buckets
                      ( transaction_id,
                        bucket_id,
                        recharge_date,
                        bucket_balance,
                        bucket_value,
                        expiration_date,
                        direction)
            VALUES (
                        new_transaction_id_rec.transaction_id,
                        benefit_rec.col3,
                        SYSDATE,
                        lv_data_bucket_value, --CR46315
                        lv_data_bucket_value, --CR46315
                        COALESCE(site_part_rec.cmmtmnt_end_dt,site_part_rec.x_expire_dt),
                        'OUTBOUND');
          EXCEPTION WHEN dup_val_on_index THEN
            NULL;
          END;
        END IF;
      END LOOP;
    ELSIF (in_voice_units IS NOT NULL) OR (in_text_units IS NOT NULL) OR (in_data_units IS NOT NULL) THEN
      dbms_output.put_line('in_voice_units:'||in_voice_units);
      IF sign(in_voice_units) < 0  AND  trans_profile_rec.template='CSI_TLG' THEN
        dbms_output.put_line('-ve buckets in_voice_units:' );
        NULL;
      ELSE
       IF sa.customer_info.get_bus_org_id(i_esn => call_trans_rec.x_service_id) = 'SIMPLE_MOBILE' AND call_trans_rec.x_reason in ('REPLACEMENT', 'AWOP') THEN
        NULL;
       ELSE
        SP_INSERT_IG_TRANS_BUCKETS(NEW_TRANSACTION_ID_REC.TRANSACTION_ID, CARR_FEATURE_REC.X_RATE_PLAN, 'VOICE_UNITS', IN_VOICE_UNITS, V_RAW_BENEFIT,ORDER_TYPE);
       END IF;

      END IF;
      IF sign(in_text_units) < 0 AND  trans_profile_rec.template='CSI_TLG' THEN
        dbms_output.put_line('-ve buckets in_text_units:' );
        NULL;
      ELSE
       IF sa.customer_info.get_bus_org_id(i_esn => call_trans_rec.x_service_id) = 'SIMPLE_MOBILE' AND call_trans_rec.x_reason in ('REPLACEMENT', 'AWOP') THEN
         NULL;
       ELSE
        SP_INSERT_IG_TRANS_BUCKETS(NEW_TRANSACTION_ID_REC.TRANSACTION_ID, CARR_FEATURE_REC.X_RATE_PLAN, 'SMS_UNITS', IN_TEXT_UNITS, V_RAW_BENEFIT,ORDER_TYPE);
       END IF;
      END IF;
      IF sign( in_data_units)< 0 AND  trans_profile_rec.template ='CSI_TLG' THEN
        dbms_output.put_line('-ve buckets in_data_units:' );
        NULL;
      ELSE
         IF sa.customer_info.get_bus_org_id(i_esn => call_trans_rec.x_service_id) = 'SIMPLE_MOBILE' AND call_trans_rec.x_reason in ('REPLACEMENT', 'AWOP') THEN
                   sp_awop_ig_transaction_buckets ( i_esn                    => call_trans_rec.x_service_id ,
                                                    i_ig_transaction_id      => new_transaction_id_rec.transaction_id,
                                                    i_call_trans_objid       => call_trans_rec.objid,
                                                    i_site_part_objid        => call_trans_rec.call_trans2site_part,
                                                    i_ig_rate_plan           => carr_feature_rec.x_rate_plan,
                                                    i_order_type             => order_type,
                                                    i_bucket_expiration_date => site_part_rec.x_expire_dt ,
                                                    i_non_ppe                => carr_feature_rec.non_ppe   ,
                                                    i_bucket_value           => in_data_units    ,
                                                    i_parent_name            => parent_rec.x_parent_name);
         ELSE
           SP_INSERT_IG_TRANS_BUCKETS(NEW_TRANSACTION_ID_REC.TRANSACTION_ID, CARR_FEATURE_REC.X_RATE_PLAN, 'DATA_UNITS', (IN_DATA_UNITS), V_RAW_BENEFIT,ORDER_TYPE);
         END IF;
      END IF;
    elsIF order_type  IN ('PAP' ,'PCR' ,'ACR') AND (NOT v_raw_benefit) THEN
      OPEN cur_case_dtl(task_rec.x_task2x_call_trans);
        FETCH cur_case_dtl INTO case_dtl_rec;
        IF cur_case_dtl%notfound THEN
          OPEN cur_pir_case_dtl(task_rec.x_task2x_call_trans);
            FETCH cur_pir_case_dtl INTO case_dtl_rec;
          CLOSE cur_pir_case_dtl;
        END IF;
      CLOSE cur_case_dtl;
      FOR bucket_rec IN cu_bucket_details(site_part_rec.x_service_id ,carr_feature_rec.x_rate_plan , case_dtl_rec.case_objid) LOOP
        dbms_output.put_line('detail found');
        dbms_output.put_line('bucket_rec.bucket_id:'|| bucket_rec.bucket_id);
        dbms_output.put_line('bucket_rec.x_name:'|| bucket_rec.x_name);
        dbms_output.put_line('bucket_rec.x_value:'||bucket_rec.x_value);
		--CR52986 - ST $30 Card Upgrades from PPE to Non PPE Feature Phone (ZTE Z233VL)  (Main change CR52254)
		--mdave, 08/10/2017
		--Added a new column to table X_RATE_PLAN to identify if data buckets for the rate plan needs conversion from KB to MB
		--Based on column value, below code would calculate data_units for the rate_plans being passed
		-- commneted existing TFREVBULKTIER_D rate plan condition. The rate plan has flag value set in table X_RATE_PLAN
		/*if carr_feature_rec.x_rate_plan = 'TFREVBULKTIER_D' and bucket_rec.x_name = 'DATA_UNITS' then*/
		if get_calculate_data_units_flag(carr_feature_rec.x_rate_plan) and bucket_rec.x_name = 'DATA_UNITS' then
		--END CR52986
          if bucket_rec.x_value < 0 then
            bucket_rec.x_value := 0;
          elsif bucket_rec.x_value >= 0 and bucket_rec.x_value <= 100 then
            bucket_rec.x_value := bucket_rec.x_value *1024;
          elsif bucket_rec.x_value > 100 and bucket_rec.x_value <= 1024 *100 then
            bucket_rec.x_value := bucket_rec.x_value;
          elsif bucket_rec.x_value > 1024 *100 then
            bucket_rec.x_value := 1024 *100;
          else
            bucket_rec.x_value := 0;
          end if;
        end if;
        if carr_feature_rec.x_rate_plan = 'TFREVBULKTIER_D' and bucket_rec.x_name = 'SMS_UNITS' then
          bucket_rec.x_value := 99999;
        end if;
        --IF NVL(get_ig_trans_buckets_ins_flag(CARR_FEATURE_REC.X_RATE_PLAN,ORDER_TYPE,bucket_rec.bucket_id),'N') = 'Y' then --added by Rahul for CR36735
        IF get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => bucket_rec.bucket_id) = 'Y' THEN --CR52905
          BEGIN
            INSERT INTO gw1.ig_transaction_buckets(
                transaction_id ,
                bucket_id ,
                recharge_date ,
                bucket_balance ,
                bucket_value ,
                expiration_date,
                direction)
            VALUES (
                new_transaction_id_rec.transaction_id,
                bucket_rec.bucket_id ,
                NULL ,
                DECODE(bucket_rec.bucket_id ,NULL ,NULL ,bucket_rec.x_value) ,
                DECODE(bucket_rec.bucket_id ,NULL ,NULL ,bucket_rec.x_value) ,
                COALESCE(site_part_rec.cmmtmnt_end_dt,site_part_rec.x_expire_dt),
                'OUTBOUND');-- CR23513 TF surepay
          EXCEPTION WHEN dup_val_on_index THEN
            NULL;
          END;
        END IF;
      END LOOP;
      --
      FOR bucket_rec IN cu_bkt_dtl_without_case_dtl    ( site_part_rec.x_service_id ,carr_feature_rec.x_rate_plan , case_dtl_rec.case_objid) LOOP
        dbms_output.put_line( 'detail NOT found');
        dbms_output.put_line('bucket_rec.bucket_id:'|| bucket_rec.bucket_id);
        dbms_output.put_line('bucket_rec.x_name:'|| bucket_rec.x_name);
        dbms_output.put_line('bucket_rec.x_value:'||bucket_rec.x_value);
        --IF NVL(get_ig_trans_buckets_ins_flag(CARR_FEATURE_REC.X_RATE_PLAN,ORDER_TYPE,bucket_rec.bucket_id),'N') = 'Y' then --added by Rahul for CR36735
        IF get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => bucket_rec.bucket_id) = 'Y' --CR52905
        THEN
          BEGIN
            INSERT INTO gw1.ig_transaction_buckets (
                transaction_id ,
                bucket_id ,
                recharge_date ,
                bucket_balance ,
                bucket_value ,
                expiration_date,
                direction)
            VALUES (
                new_transaction_id_rec.transaction_id,
                bucket_rec.bucket_id ,
                NULL ,
                DECODE(bucket_rec.bucket_id ,NULL ,NULL ,bucket_rec.x_value) ,
                DECODE(bucket_rec.bucket_id ,NULL ,NULL ,bucket_rec.x_value) ,
                COALESCE(site_part_rec.cmmtmnt_end_dt,site_part_rec.x_expire_dt),
                'OUTBOUND');-- CR23513 TF surepay
          EXCEPTION WHEN dup_val_on_index THEN
            NULL;
          END;
        END IF;
      END LOOP;
    END IF;

    -- CR 46581 GO SMART
    -- CALL procedure to create wallet buckets (if applicable)
    create_ig_transaction_buckets ( i_esn                        => call_trans_rec.x_service_id,
                                    i_ig_transaction_id          => new_transaction_id_rec.transaction_id,
                                    i_call_trans_objid           => call_trans_rec.objid,
                                    i_site_part_objid            => call_trans_rec.call_trans2site_part,
                                    i_rate_plan                  => carr_feature_rec.x_rate_plan,
                                    i_order_type                 => order_type,
                                    i_bucket_expiration_date     => site_part_rec.x_expire_dt,
                                    i_bucket_value               => in_data_units,
                                    i_non_ppe                    => carr_feature_rec.non_ppe,
                                    i_parent_name                => parent_rec.x_parent_name);
    --CR46315

  END IF; --CR52905 - IF c_create_buckets_flag IN ('YES', 'SUI') -- #1

  --CR48373
  IF p_application_system = 'SUI'
  THEN
        create_sui_buckets ( i_esn                       => call_trans_rec.x_service_id,
                             i_transaction_id            => new_transaction_id_rec.transaction_id,
                             o_error_code                => o_error_code,
                             o_error_message             => o_error_message);
  END IF;

  IF lv_multi_data_promo_code	IS NOT NULL
  THEN

     sa.PROMOTION_PKG.SP_INS_ESN_PROMO_HIST(
          call_trans_rec.x_service_id --IP_ESN
         ,call_trans_rec.objid        --IP_CALLTRANS_ID
         ,lv_multi_data_promo_objid   --IP_PROMO_OBJID
         ,NULL                        --IP_EXPIRATION_DATE
         ,lv_multi_data_bucket_id     --IP_BUCKET_ID
         ,lv_promo_error_code         --OP_ERROR_CODE
         ,lv_promo_error_msg          --OP_ERROR_MSG
         );

  END IF;

  IF lv_data_promo_code IS NOT NULL AND lv_sp_promo_bucket_feat IS NOT NULL
  THEN

  OPEN cur_promo_data(call_trans_rec.call_trans2site_part,
                      parent_rec.x_parent_name,
                      carr_feature_rec.non_ppe,
                      carr_feature_rec.x_rate_plan,
                      lv_sp_promo_bucket_feat
                     );
  fetch cur_promo_data into rec_promo_data;

  IF cur_promo_data%FOUND
  THEN

    lv_promo_bucket_expr_date := SYSDATE + lv_bucket_active_days;

    --CR52905 - Check if buckets are to be created for current order type and if the bucket is active in ig_buckets
    --IF NVL(get_ig_trans_buckets_ins_flag(CARR_FEATURE_REC.X_RATE_PLAN,ORDER_TYPE,rec_promo_data.col3),'N') = 'Y' --CR52905
    IF c_create_buckets_flag IN ('YES', 'SUI') --#2
    THEN
       IF get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => rec_promo_data.col3) = 'Y'
       THEN

          INSERT
          INTO ig_transaction_buckets
            (
              transaction_id,
              bucket_id,
              recharge_date,
              bucket_balance,
              bucket_value,
              expiration_date,
              direction,
              bucket_type
            )
            VALUES
            (
              new_transaction_id_rec.transaction_id,
              rec_promo_data.col3,
              SYSDATE,
              rec_promo_data.COL4, --CR46315
              rec_promo_data.COL4, --CR46315
              lv_promo_bucket_expr_date,
              'OUTBOUND',
              'DATA_UNITS'
            );

       END IF;
    END IF; -- CR52905 - IF c_create_buckets_flag IN ('YES', 'SUI')  --#2

    sa.PROMOTION_PKG.SP_INS_ESN_PROMO_HIST(
        call_trans_rec.x_service_id  --IP_ESN
       ,call_trans_rec.objid         --IP_CALLTRANS_ID
       ,lv_data_promo_objid          --IP_PROMO_OBJID
       ,lv_promo_bucket_expr_date    --IP_EXPIRATION_DATE
       ,rec_promo_data.col3          --IP_BUCKET_ID
       ,lv_promo_error_code          --OP_ERROR_CODE
       ,lv_promo_error_msg           --OP_ERROR_MSG
       );

  END IF;
   --CR52803 enable  new order type similar to CR-Credit
  ELSIF 	(order_type IN ('ACR','PCR','E','A','PAP','AP','CR','CRU','EU','R') OR get_safelink_batch_flag(i_order_type=>order_type) ='Y')
  THEN

   IF c_create_buckets_flag IN ('YES', 'SUI') --CR52905 --#3
   THEN
     FOR REC_PROMO_BUCKET_TRANSFER IN
     (SELECT PROMO_HIST.EXPIRATION_DATE
            ,P.X_PROMO_TECHNOLOGY
            ,PROMO_HIST.BUCKET_ID
     FROM X_ESN_PROMO_HIST PROMO_HIST,TABLE_X_PROMOTION P
     WHERE ESN                                         = call_trans_rec.x_service_id
     AND   PROMO_HIST.PROMO_HIST2X_PROMOTION           = P.OBJID
     AND   P.X_PROMO_TYPE                              = 'HL_DATA_PROMO'
     AND   NVL(PROMO_HIST.EXPIRATION_DATE,SYSDATE - 1) > SYSDATE
     )
     LOOP

       OPEN CUR_SP_FEATURE_VALUE (benefit_test_rec.objid,'BIZ LINE'); -- To check if it is SIMPLE MOBILE DATA PLAN

       FETCH CUR_SP_FEATURE_VALUE INTO REC_SP_FEATURE_VALUE;

       IF REC_SP_FEATURE_VALUE.VALUE_NAME	= 'SIMPLE MOBILE'
       THEN

         lv_promo_bucket_expr_date	:=	REC_PROMO_BUCKET_TRANSFER.EXPIRATION_DATE;

         --IF NVL(get_ig_trans_buckets_ins_flag(CARR_FEATURE_REC.X_RATE_PLAN,ORDER_TYPE,REC_PROMO_BUCKET_TRANSFER.BUCKET_ID),'N') = 'Y'
         IF get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => REC_PROMO_BUCKET_TRANSFER.BUCKET_ID) = 'Y' --CR52905
         THEN

            INSERT
            INTO ig_transaction_buckets
              (
                transaction_id,
                bucket_id,
                recharge_date,
                bucket_balance,
                bucket_value,
                expiration_date,
                direction ,
                benefit_type ,
                bucket_type
              )
              VALUES
              (
                new_transaction_id_rec.transaction_id,
                REC_PROMO_BUCKET_TRANSFER.BUCKET_ID,
                SYSDATE,
                0,
                0 ,
                lv_promo_bucket_expr_date ,
                'OUTBOUND' ,
                'TRANSFER' ,
                'DATA_UNITS'
              );

         END IF;

       END IF;

     END LOOP;

   END IF; -- CR52905 - IF c_create_buckets_flag IN ('YES', 'SUI') --#3
 END IF;
 --close cur_promo_data;


  dbms_output.put_line  ('carr_feature_rec.X_FEATURES2BUS_ORG :'||carr_feature_rec.X_FEATURES2BUS_ORG);
  dbms_output.put_line  ('parent_rec.x_parent_id :'||parent_rec.x_parent_id);
  dbms_output.put_line  ('carr_feature_rec.x_rate_plan :'||carr_feature_rec.x_rate_plan);
  IF c_create_buckets_flag IN ('YES', 'SUI') --CR52905 --#4
  THEN
    --CR47587 START
    --CR55859,Modified logic for hotspot, BYOT devices of NET10 and STRAIGHT_TALK Brands.
    IF get_hotspot_buckets_flag(carr_feature_rec.X_FEATURES2BUS_ORG,
                                parent_rec.x_parent_id,
                                carr_feature_rec.x_rate_plan) = 'Y' THEN
       FOR net10_rec IN NET10_HOTSPOT_BUCKETS (call_trans_rec.call_trans2site_part,
                                               carr_feature_rec.x_rate_plan,
                                               task_rec.task_id)
       LOOP
        --IF NVL(get_ig_trans_buckets_ins_flag(CARR_FEATURE_REC.X_RATE_PLAN,ORDER_TYPE,net10_rec.bucket_id),'N') = 'Y' then
        IF get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => net10_rec.bucket_id) = 'Y' THEN --CR52905
         IF net10_rec.VALUE_NAME='DATA' then v_bucket_value:= net10_rec.PROPERTY_VALUE * 1024;
         --ELSIF net10_rec.VALUE_NAME='SERVICE DAYS' then v_expiration_date:= sysdate+net10_rec.PROPERTY_VALUE;
         END IF;

         BEGIN
             INSERT
               INTO ig_transaction_buckets
                 (
                  transaction_id,
                  bucket_id,
                  recharge_date,
                  bucket_balance,
                  bucket_value,
                  expiration_date,
                  direction
                 )
            VALUES
                (
                 net10_rec.transaction_id,
                 net10_rec.bucket_id,
                 SYSDATE,
                 v_bucket_value,
                 v_bucket_value,
                 site_part_rec.x_expire_dt,
                 'OUTBOUND'
                );
            dbms_output.put_line  ('ST and NET10 Buckets');
          EXCEPTION
             WHEN DUP_VAL_ON_INDEX
             THEN
                NULL;
          END;
        END IF;
       END LOOP;

    END IF;
    --CR47587 END

    --CR46315
    -- CR29587 ATT Carrier Switch
    IF carr_feature_rec.x_is_swb_carrier = 1 AND call_trans_rec.x_action_type in ('1','3','6') AND
      parent_rec.x_parent_id IN (55,78,77, 76,71,6,7,63,1000000266, 66,1000000267,5,75,38) then --'T-MOBILE%', 'AT%T%', 'VERIZON%'
      dbms_output.put_line  ('NEW ATT CODE MESS 1');
      --
      IF part_num_rec.org_id = 'STRAIGHT_TALK' THEN
        dbms_output.put_line  ('NEW ATT CODE MESS 4');
        v_in_voice_units := get_unit_value ( i_task_objid => p_task_objid, i_bucket_name => 'VOICE');
        v_in_text_units := get_unit_value ( i_task_objid => p_task_objid, i_bucket_name => 'SMS');
        v_in_data_units := get_unit_value ( i_task_objid => p_task_objid, i_bucket_name => 'DATA');
        --v_in_data_units :=v_in_data_units * 1024;
        FOR socs_rec IN bucket_curs ( carr_feature_rec.x_rate_plan,
                                    call_trans_rec.call_trans2site_part,
                                    v_in_voice_units,
                                    v_in_text_units,
                                    v_in_data_units) LOOP
          dbms_output.put_line  ('NEW ATT CODE MESS 5');
          --IF NVL(get_ig_trans_buckets_ins_flag(CARR_FEATURE_REC.X_RATE_PLAN,ORDER_TYPE,socs_rec.bucket_id),'N') = 'Y' then --added by Rahul for CR36735
          IF get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => socs_rec.bucket_id) = 'Y' THEN --CR52905
            BEGIN
              INSERT INTO  ig_transaction_buckets (
                      transaction_id,
                      bucket_id,
                      recharge_date,
                      bucket_balance,
                      bucket_value,
                      expiration_date,
                      direction)
              VALUES ( new_transaction_id_rec.transaction_id,
                      socs_rec.bucket_id,
                      SYSDATE,
                      socs_rec.bucket_value,
                      socs_rec.bucket_value,
                      COALESCE(site_part_rec.cmmtmnt_end_dt,site_part_rec.x_expire_dt),
                      'OUTBOUND');
            EXCEPTION WHEN dup_val_on_index THEN
              NULL;
            END;
          END IF;
          dbms_output.put_line  ('NEW ATT CODE MESS 6');
        END LOOP;
      ELSE
        IF sign(in_voice_units) =-1 or sign(in_text_units)=-1 or sign( in_data_units)=-1 THEN
          dbms_output.put_line  ('NEW ATT CODE MESS ');
          null;
        else
          FOR socs_rec IN bucket_curs (carr_feature_rec.x_rate_plan, call_trans_rec.call_trans2site_part, in_voice_units, in_text_units, in_data_units)   LOOP
            --IF NVL(get_ig_trans_buckets_ins_flag(CARR_FEATURE_REC.X_RATE_PLAN,ORDER_TYPE,socs_rec.bucket_id),'N') = 'Y' then --added by Rahul for CR36735
            IF get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => socs_rec.bucket_id) = 'Y' THEN --CR52905
              BEGIN
                INSERT INTO ig_transaction_buckets (
                          transaction_id,
                          bucket_id,
                          recharge_date,
                          bucket_balance,
                          bucket_value,
                          expiration_date,
                          direction)
                VALUES (
                          new_transaction_id_rec.transaction_id,
                          socs_rec.bucket_id,
                          SYSDATE,
                          socs_rec.bucket_value,
                          socs_rec.bucket_value,
                          COALESCE(site_part_rec.cmmtmnt_end_dt,site_part_rec.x_expire_dt),
                          'OUTBOUND');
              EXCEPTION WHEN dup_val_on_index THEN
                NULL;
              END;
            END IF; -- get_ig_buckets_active_flag(in_rate_plan => CARR_FEATURE_REC.X_RATE_PLAN, in_bucket_id => socs_rec.bucket_id) = 'Y' THEN --CR52905
          END LOOP;
        end if; -- IF sign(in_voice_units) =-1 or sign(in_text_units)=-1 or sign( in_data_units)=-1
      END IF; -- IF org_id = 'STRAIGHT_TALK' THEN
    END IF;  -- IF carr_feature_rec.x_is_swb_carrier = 1 AND call_trans_rec.x_action_type in ('1','3','6')
    -- CR29587 ATT Carrier Switch
    -- CR30860 TMO Safelink upgrades
    FOR x_rec IN (SELECT in_free_voice_units bucket_value,'FREE_VOICE_UNITS' bucket_type FROM DUAL  where in_free_voice_units IS NOT NULL
                  UNION ALL
                  SELECT in_free_text_units bucket_value,'FREE_SMS_UNITS' bucket_type FROM DUAL where in_free_text_units IS NOT NULL
                  UNION ALL
                  SELECT in_free_data_units bucket_value,'FREE_DATA_UNITS' bucket_type  FROM DUAL where in_free_data_units IS NOT NULL ) LOOP
      sp_insert_ig_trans_buckets(new_transaction_id_rec.transaction_id,carr_feature_rec.x_rate_plan,x_rec.bucket_type,x_rec.bucket_value,v_raw_benefit,order_type);
    END LOOP;

 END IF; -- CR52905 - IF c_create_buckets_flag IN ('YES', 'SUI') --#4

   --Need to uncomment after CR39197 release CR39197
    IF order_type IN ('SIMC','EC') THEN  --EC added for defect 202
      sa.sp_detach_iccid(site_part_rec.x_service_id,site_part_rec.iccid);
    END IF;
    -- CR30860 TMO Safelink upgrades
    UPDATE table_task
       SET x_rate_plan = carr_feature_rec.x_rate_plan -- CR15565 Commented on 02/17/2011 l_rateplan-- carr_feature_rec.x_rate_plan   ---CR13085
     WHERE objid     = p_task_objid;
    --
    IF c_create_buckets_flag IN ('YES', 'SUI') --#5 --CR52905
    THEN
      IF (v_language = 'TRANSFER' OR v_language = 'UPGRADE') THEN
        UPDATE ig_transaction_buckets
           set benefit_type =v_language
         WHERE transaction_id = new_transaction_id_rec.transaction_id
           AND direction='OUTBOUND';
      END IF;
      --
      -- CR42459 Check to see if benefit type is populated.
      --         If null then set to get_lang function.
      --
        BEGIN
           SELECT sa.get_lang(action_item_id)
             INTO v_get_lang
             FROM ig_transaction
            WHERE transaction_id = new_transaction_id_rec.transaction_id
              AND  ROWNUM =1;
        EXCEPTION
           WHEN OTHERS THEN
              v_get_lang:=NULL;
        END;
        UPDATE ig_transaction_buckets
           set benefit_type = NVL(benefit_type,v_get_lang)
         WHERE transaction_id = new_transaction_id_rec.transaction_id
           AND direction='OUTBOUND';
        -- CR51593 changes starts
        IF sa.util_pkg.get_short_parent_name(sa.util_pkg.get_parent_name(site_part_rec.x_service_id)) = 'TMO' THEN
		   --Fix for CR55886 starts
		   cust_type := sa.customer_type(i_esn => site_part_rec.x_service_id);
           cust_type := cust_type.get_safelink_attributes;
		   v_exp_upd_flg := 'N';
		   IF cust_type.safelink_flag = 'Y' OR part_num_rec.org_id = 'TRACFONE' THEN
		      v_exp_upd_flg := 'Y';
		   END IF;
		   --Fix for CR55886 ends
           dbms_output.put_line  ('Updating Bucket Type for TMO '||new_transaction_id_rec.transaction_id);
           UPDATE ig_transaction_buckets igb
           SET bucket_type = NVL(bucket_type,(SELECT bucket_type
                                 FROM gw1.ig_buckets ib
                                WHERE ib.bucket_id = igb.bucket_id
                                  AND rate_plan    = carr_feature_rec.x_rate_plan
                                  AND ROWNUM < 2
                                  )
                  )
			    ,expiration_date = NVL(expiration_date,(CASE WHEN v_exp_upd_flg = 'Y' AND bucket_type = 'DATA_UNITS'
			                                                THEN
                                                            COALESCE(site_part_rec.cmmtmnt_end_dt,site_part_rec.x_expire_dt)
                                                       END )
									 )	   --Fix for CR55886
            WHERE transaction_id = new_transaction_id_rec.transaction_id
           AND direction='OUTBOUND';
        END IF;
        -- CR51593 Changes Ends
    END IF; -- CR52905 - IF c_create_buckets_flag IN ('YES', 'SUI') --#5
    COMMIT;
    dbms_output.put_line  ('Language value for '||task_rec.task_id ||'is'|| v_LANGUAGE||' vget_lang: '||v_get_lang);
exception when others then
        p_status := 20;
        l_error_message := sqlcode||sqlerrm;
        INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
        VALUES ( 'unbound error', sysdate, l_error_message , p_task_objid, 'igate.sp_insert_ig_transaction');
END sp_insert_ig_transaction;
      ----------------------------------------------------------------------------------------------------
      -- CR6254 Start MEID retrieving
      ---------------------------------------------------------------------------------------------------
FUNCTION f_get_hex_esn( p_esn VARCHAR2)
      RETURN VARCHAR2
    IS
      new_hex_meid VARCHAR2(30) := NULL;
      meid         NUMBER       :=0 ;
      CURSOR part_inst_curs
      IS
        SELECT nvl(pn.X_MEID_PHONE,0) x_meid_phone,
               pi.x_hex_serial_no
        FROM table_part_num pn,
          table_mod_level ml,
          table_part_inst pi
        WHERE 1               = 1
        AND pn.objid          = ml.part_info2part_num
        AND ml.objid          = pi.n_part_inst2part_mod
        AND pi.part_serial_no = P_ESN ;
    part_inst_rec part_inst_curs%rowtype;
    BEGIN
      open part_inst_curs;
        fetch part_inst_curs into part_inst_rec;
        if part_inst_curs%notfound then
          close part_inst_curs;
          return null;
          --new_hex_meid := null;
        end if;
      close part_inst_curs;
      if part_inst_rec.x_hex_serial_no is not null then
        new_hex_meid:=  part_inst_rec.x_hex_serial_no;
      elsif part_inst_rec.x_meid_phone = 1 and length(p_esn) = 15 and  sa.Lte_service_pkg.IS_ESN_LTE_CDMA(p_esn) = 1 then
        new_hex_meid:=  p_esn;
      elsif part_inst_rec.x_meid_phone = 1 then
        new_hex_meid:=  sa.meiddectohex(p_esn);
      else
        new_hex_meid:= get_hex(p_esn);
      end if;
      return new_hex_meid;
    END;

    -- Exit function f_get_hex_meid
    -- CR6254 End
    ----------------------------------------------------------------------------------------------------
  PROCEDURE sp_get_hex(
      p_esn IN VARCHAR2 ,
      p_hex_esn OUT VARCHAR2 )
  IS
  BEGIN
    p_hex_esn := get_hex(p_esn);
  END;
  ----------------------------------------------------------------------------------------------------
FUNCTION get_hex(
    p_esn IN VARCHAR2)
  RETURN VARCHAR2
IS
  esn_number NUMBER;
  var1       VARCHAR2(100) := NULL;
  var2       VARCHAR2(100) := NULL;
  hex_esn    VARCHAR2(30)  := NULL;
FUNCTION hex(
    p_str IN VARCHAR2)
  RETURN VARCHAR2
IS
  in_string  NUMBER        := p_str;
  bin_string VARCHAR2(100) := NULL;
  hex_string VARCHAR2(100) := NULL;
BEGIN
  FOR i IN 0 .. 35
  LOOP
    IF in_string                                   - POWER(2 ,(35 - i)) >= 0 THEN
      in_string                       := in_string - POWER(2 ,(35 - i));
      bin_string                      := bin_string || '1';
    ELSE
      bin_string := bin_string || '0';
    END IF;
  END LOOP;
  FOR i IN 0 .. 8
  LOOP
    dbms_output.put_line(SUBSTR(bin_string ,(i * 4) + 1 ,4));
    IF SUBSTR(bin_string ,(i                   * 4) + 1 ,4) = '0000' THEN
      hex_string                                           := hex_string || '0';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '0001' THEN
      hex_string                                           := hex_string || '1';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '0010' THEN
      hex_string                                           := hex_string || '2';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '0011' THEN
      hex_string                                           := hex_string || '3';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '0100' THEN
      hex_string                                           := hex_string || '4';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '0101' THEN
      hex_string                                           := hex_string || '5';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '0110' THEN
      hex_string                                           := hex_string || '6';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '0111' THEN
      hex_string                                           := hex_string || '7';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '1000' THEN
      hex_string                                           := hex_string || '8';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '1001' THEN
      hex_string                                           := hex_string || '9';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '1010' THEN
      hex_string                                           := hex_string || 'A';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '1011' THEN
      hex_string                                           := hex_string || 'B';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '1100' THEN
      hex_string                                           := hex_string || 'C';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '1101' THEN
      hex_string                                           := hex_string || 'D';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '1110' THEN
      hex_string                                           := hex_string || 'E';
    ELSIF SUBSTR(bin_string ,(i * 4) + 1 ,4)                = '1111' THEN
      hex_string                                           := hex_string || 'F';
    END IF;
  END LOOP;
  hex_string := LTRIM(hex_string ,'0');
  RETURN hex_string;
END;
BEGIN
  dbms_output.put_line('esn:' || p_esn);
  --    esn_number := to_number(substr(p_esn,1,11));
  var1 := hex(SUBSTR(p_esn ,1 ,3));
  dbms_output.put_line('var1:' || var1);
  var2 := hex(SUBSTR(p_esn ,4 ,8));
  dbms_output.put_line('var2:' || var2);
  hex_esn := var1 || var2;
  dbms_output.put_line('hex_esn:' || hex_esn);
  RETURN hex_esn;
END;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_check_blackout(
    p_task_objid       IN NUMBER ,
    p_order_type_objid IN NUMBER ,
    p_black_out_code OUT NUMBER )
IS
BEGIN
  p_black_out_code := f_check_blackout(p_task_objid ,p_order_type_objid);
END;
----------------------------------------------------------------------------------------------------
FUNCTION f_check_blackout(
    p_task_objid       IN NUMBER ,
    p_order_type_objid IN NUMBER )
  RETURN NUMBER
IS
  l_seconds_from_sunday NUMBER := (SYSDATE - TRUNC(SYSDATE - TO_NUMBER(TO_CHAR(SYSDATE ,'d')) + 1)) * 24 * 60 * 60;
  l_work_wk_objid       NUMBER;
  task_rec task_curs%ROWTYPE;
  call_trans_rec call_trans_curs%ROWTYPE;
  carrier_rec carrier_curs%ROWTYPE;
  site_part_rec site_part_curs%ROWTYPE;
  order_type_rec order_type_curs%ROWTYPE;
  trans_profile_rec trans_profile_curs%ROWTYPE;
BEGIN
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%NOTFOUND THEN
    CLOSE task_curs;
    RETURN 2;
  END IF;
  CLOSE task_curs;
  --
  OPEN order_type_curs(p_order_type_objid);
  FETCH order_type_curs INTO order_type_rec;
  IF order_type_curs%NOTFOUND THEN
    CLOSE order_type_curs;
    RETURN 5;
  END IF;
  CLOSE order_type_curs;
  --
  OPEN call_trans_curs(task_rec.x_task2x_call_trans);
  FETCH call_trans_curs INTO call_trans_rec;
  IF call_trans_curs%NOTFOUND THEN
    CLOSE call_trans_curs;
    RETURN 3;
  END IF;
  CLOSE call_trans_curs;
  --
  OPEN carrier_curs(order_type_rec.x_order_type2x_carrier);
  FETCH carrier_curs INTO carrier_rec;
  IF carrier_curs%NOTFOUND THEN
    CLOSE carrier_curs;
    RETURN 4;
  END IF;
  CLOSE carrier_curs;
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%NOTFOUND THEN
    CLOSE site_part_curs;
    RETURN 9;
  END IF;
  CLOSE site_part_curs;
  IF LTRIM(site_part_rec.state_value) IS NULL THEN
    site_part_rec.state_value         := 'ANALOG';
  END IF;
  --
  OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile);
  FETCH trans_profile_curs INTO trans_profile_rec;
  IF trans_profile_curs%NOTFOUND THEN
    CLOSE trans_profile_curs;
    RETURN 6;
  END IF;
  CLOSE trans_profile_curs;
  --
  IF site_part_rec.state_value = 'ANALOG' THEN
    l_work_wk_objid           := trans_profile_rec.x_trans_profile2wk_work_hr;
  ELSE
    l_work_wk_objid := trans_profile_rec.d_trans_profile2wk_work_hr;
  END IF;
  FOR hr_rec IN hr_curs(l_work_wk_objid)
  LOOP
    IF l_seconds_from_sunday BETWEEN hr_rec.start_time AND hr_rec.end_time THEN
      RETURN 1;
    END IF;
  END LOOP;
  RETURN 0;
  --
END f_check_blackout;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_get_ordertype(
    p_min           IN VARCHAR2 ,
    p_order_type    IN VARCHAR2 ,
    p_carrier_objid IN NUMBER ,
    p_technology    IN VARCHAR2 ,
    p_order_type_objid   OUT NUMBER,
    p_bypass_order_type  IN NUMBER DEFAULT NULL --CR52744
    )
IS
  l_order_type VARCHAR2(100) := p_order_type;
  CURSOR o_type_curs ( c_npa IN VARCHAR2 ,c_nxx IN VARCHAR2 ,c_order_type IN VARCHAR2 ,c_carrier_objid IN NUMBER )
  IS
    SELECT
      /*+ index ( ot IND_ORDER_TYPE3 ) */
      ot.*
    FROM table_x_order_type ot ,
      table_x_carrier c
    WHERE ot.x_order_type2x_carrier = c.objid
    AND NVL(ot.x_npa ,-1)           = c_npa
    AND NVL(ot.x_nxx ,-1)           = c_nxx
    AND ot.x_order_type             = c_order_type
    AND c.objid                     = c_carrier_objid;
  o_type_rec o_type_curs%ROWTYPE;
  CURSOR o_type_curs2 ( c_npa IN VARCHAR2 ,c_nxx IN VARCHAR2 ,c_order_type IN VARCHAR2 ,c_carrier_objid IN NUMBER )
  IS
    SELECT
      /*+ index ( ot IND_ORDER_TYPE3 ) */
      ot.*
    FROM table_x_order_type ot ,
      table_x_carrier c
    WHERE ot.x_order_type2x_carrier = c.objid
    AND NVL(ot.x_npa ,-1)           = -1
    AND NVL(ot.x_nxx ,-1)           = -1
    AND ot.x_order_type             = c_order_type
    AND c.objid                     = c_carrier_objid;
  o_type_rec2 o_type_curs2%ROWTYPE;
  CURSOR rules_curs ( c_carrier_objid IN NUMBER ,c_tech IN VARCHAR2 )
  IS
    SELECT x_mkt_submkt_name x_carrier,cr.*
    FROM table_x_carrier_rules cr ,
      table_x_carrier c
      --CR4579 Commented Out: WHERE cr.objid = c.carrier2rules
    WHERE cr.objid = DECODE(c_tech ,'GSM' ,c.carrier2rules_gsm ,'TDMA' ,c.carrier2rules_tdma ,'CDMA' ,c.carrier2rules_cdma ,c.carrier2rules)
    AND c.objid    = c_carrier_objid;
  rules_rec rules_curs%ROWTYPE;

  --CR52744
  CURSOR reserve_line_curs ( p_min IN VARCHAR2 )
  IS
    SELECT pi_min.*
      FROM table_part_inst pi_esn,
           table_part_inst pi_min
     WHERE 1=1
     --and pi_esn.part_serial_no =  '100000007666919'
       AND pi_esn.x_domain              = 'PHONES'
       AND pi_min.part_serial_no        = p_min
       AND pi_min.part_to_esn2part_inst = pi_esn.objid
       AND pi_min.x_domain              = 'LINES'
       AND pi_min.x_part_inst_status in ('37' , '39' , '73')
       ;

  reserve_line_rec reserve_line_curs%ROWTYPE;

  cnt                    NUMBER := 0;
  l_allow_non_hd_acts    table_x_carrier_rules.allow_non_hd_acts%TYPE := NULL; --CR52744
  l_allow_non_hd_reacts  table_x_carrier_rules.allow_non_hd_reacts%TYPE := NULL; --CR52744
  l_carrier              table_x_carrier.x_mkt_submkt_name%TYPE := NULL; --CR52744
BEGIN
  --
  dbms_output.put_line('Begin PROCEDURE sp_get_ordertype');
  dbms_output.put_line('p_bypass_order_type:'||p_bypass_order_type);
  dbms_output.put_line('p_carrier_objid:' || p_carrier_objid);
  dbms_output.put_line('p_technology:' || p_technology);
  cnt := cnt + 1;

  --CR52744
  IF p_bypass_order_type IS NOT NULL THEN
    dbms_output.put_line('p_bypass_order_type IS NOT NULL:'||p_bypass_order_type);
  --Get Carrier and Non-HD flag for MIN.
  OPEN rules_curs(p_carrier_objid ,p_technology);
  FETCH rules_curs INTO rules_rec;
       IF rules_curs%FOUND THEN
          l_allow_non_hd_acts := rules_rec.allow_non_hd_acts;
          l_allow_non_hd_reacts := rules_rec.allow_non_hd_reacts;
          l_carrier := UPPER(rules_rec.x_carrier);
          dbms_output.put_line('l_allow_non_hd_acts:' || l_allow_non_hd_acts);
          dbms_output.put_line('l_allow_non_hd_reacts:' || l_allow_non_hd_reacts);
          dbms_output.put_line('l_carrier:' || l_carrier);
	  dbms_output.put_line('rules_rec.objid:' || rules_rec.objid);
       END IF;
  CLOSE rules_curs;

  --Verify and Don't allow Activations for Verzion Non-HD MIN.
  IF l_carrier LIKE 'VERIZON%' THEN
    IF NVL(p_bypass_order_type,0) = 1 AND NVL(l_allow_non_hd_acts,0) = 0
	  THEN
           p_order_type_objid := 0;
	   dbms_output.put_line('Dont allow Activation for Non-HD of VERIZON');
	   RETURN;
    END IF;
  END IF;

  --CR52744
  --Verify and Don't allow Reactivations for Verzion Non-HD MIN with Reserved line (Queued PIN).
  IF p_bypass_order_type = 3
     AND l_carrier LIKE 'VERIZON%'  THEN
     dbms_output.put_line('Validate Reactivation Process:');
  OPEN reserve_line_curs(p_min);
  FETCH reserve_line_curs INTO reserve_line_rec;

  IF reserve_line_curs%NOTFOUND THEN
    IF NVL(l_allow_non_hd_reacts,0) = 0 THEN
	  dbms_output.put_line('Dont allow Reactivations of reserve_line_curs%NOTFOUND:');
	  p_order_type_objid := 0;
	  RETURN;
    END IF;
  END IF;

  CLOSE reserve_line_curs;
  END IF;--CR52744
  END IF; --IF p_bypass_order_type IS NOT NULL THEN CR52744
  cnt := cnt + 1;
  --dbms_output.put_line('sp_get_ordertype:' || cnt);
  --
  IF p_order_type = 'Return' THEN
    l_order_type := 'Deactivation';
  ELSE
    l_order_type := p_order_type;
  END IF;
  --
  cnt := cnt + 1;
  --dbms_output.put_line('sp_get_ordertype:' || cnt);
  --
  OPEN o_type_curs(SUBSTR(p_min ,1 ,3) ,SUBSTR(p_min ,4 ,3) ,l_order_type ,p_carrier_objid);
  FETCH o_type_curs INTO o_type_rec;
  IF o_type_curs%FOUND THEN
    p_order_type_objid := o_type_rec.objid;
    CLOSE o_type_curs;
    RETURN;
  END IF;
  CLOSE o_type_curs;
  --
  cnt := cnt + 1;
  --dbms_output.put_line('sp_get_ordertype:' || cnt);
  --dbms_output.put_line('sp_get_ordertype:' || cnt || ' l_order_type:' || l_order_type);
  --dbms_output.put_line('sp_get_ordertype:' || cnt || ' p_carrier_objid:' || p_carrier_objid);
  --
  OPEN o_type_curs2(NULL ,NULL ,l_order_type ,p_carrier_objid);
  FETCH o_type_curs2 INTO o_type_rec2;
  IF o_type_curs2%NOTFOUND THEN
    p_order_type_objid := 0;
    --
    cnt := cnt + 1;
    --dbms_output.put_line('1sp_get_ordertype:' || cnt);
    --
  ELSE
    OPEN rules_curs(p_carrier_objid ,p_technology);
    FETCH rules_curs INTO rules_rec;
    IF rules_curs%FOUND THEN
      dbms_output.put_line('2sp_get_ordertype rules found:' || cnt);
      IF rules_rec.x_npa_nxx_flag > 0 THEN
        p_order_type_objid       := o_type_rec2.objid;
      ELSE
        p_order_type_objid := 0;
      END IF;
    ELSE
      --dbms_output.put_line('1sp_get_ordertype rules not found:' || cnt);
      p_order_type_objid := 0;
    END IF;
    CLOSE rules_curs;
    --
    cnt := cnt + 1;
    --dbms_output.put_line('2sp_get_ordertype:' || cnt);
    --
  END IF;
  CLOSE o_type_curs2;
   --CR52744
   IF o_type_curs%ISOPEN THEN
   CLOSE o_type_curs ;
   END IF ;

   IF o_type_curs2%ISOPEN THEN
   CLOSE o_type_curs2 ;
   END IF ;

   IF rules_curs%ISOPEN THEN
   CLOSE rules_curs ;
   END IF ;

   IF reserve_line_curs%ISOPEN THEN
   CLOSE reserve_line_curs ;
   END IF ;

EXCEPTION WHEN OTHERS THEN

   --CR52744
   IF o_type_curs%ISOPEN THEN
   CLOSE o_type_curs ;
   END IF ;

   IF o_type_curs2%ISOPEN THEN
   CLOSE o_type_curs2 ;
   END IF ;

   IF rules_curs%ISOPEN THEN
   CLOSE rules_curs ;
   END IF ;

   IF reserve_line_curs%ISOPEN THEN
   CLOSE reserve_line_curs ;
   END IF ;

END sp_get_ordertype;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_dispatch_queue(
    p_task_objid IN NUMBER ,
    p_queue_name IN VARCHAR2 ,
    p_dummy_out OUT NUMBER )
IS
  l_queue_name VARCHAR2(100) := p_queue_name;
  current_user_rec current_user_curs%ROWTYPE;
  task_rec task_curs%ROWTYPE;
  condition_rec condition_curs%ROWTYPE;
  queue_rec queue_curs%ROWTYPE;
  user2_rec user2_curs%ROWTYPE;
  employee_rec employee_curs%ROWTYPE;
  gbst_lst_rec gbst_lst_curs%ROWTYPE;
  gbst_elm_rec gbst_elm_curs%ROWTYPE;
  code_rec code_curs%ROWTYPE;
BEGIN
  p_dummy_out    := 1;
  IF l_queue_name = 'Please Specify' THEN
    l_queue_name := 'Line Activation NoOrdTyp';
  END IF;
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  CLOSE current_user_curs;
  --
  OPEN task_curs(p_task_objid);
  FETCH task_curs INTO task_rec;
  IF task_curs%NOTFOUND THEN
    CLOSE task_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE task_curs;
  --
  OPEN condition_curs(task_rec.task_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%NOTFOUND THEN
    CLOSE condition_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE condition_curs;
  --
  OPEN queue_curs(l_queue_name);
  FETCH queue_curs INTO queue_rec;
  IF queue_curs%NOTFOUND THEN
    CLOSE queue_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE queue_curs;
  --
  OPEN user2_curs(current_user_rec.user);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%NOTFOUND THEN
    CLOSE user2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%NOTFOUND THEN
    CLOSE employee_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Dispatch');
  FETCH gbst_elm_curs INTO gbst_elm_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  OPEN code_curs('DEFAULT QUEUE');
  FETCH code_curs INTO code_rec;
  IF code_curs%NOTFOUND THEN
    CLOSE code_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE code_curs;
  --
END sp_dispatch_queue;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_dispatch_case(
    p_case_objid IN NUMBER ,
    p_queue_name IN VARCHAR2 ,
    p_dummy_out OUT NUMBER )
IS
  current_user_rec current_user_curs%ROWTYPE;
  case_rec case_curs%ROWTYPE;
  condition_rec condition_curs%ROWTYPE;
  user2_rec user2_curs%ROWTYPE;
  employee_rec employee_curs%ROWTYPE;
  gbst_lst_rec gbst_lst_curs%ROWTYPE;
  gbst_elm_rec gbst_elm_curs%ROWTYPE;
  queue_rec queue_curs%ROWTYPE;
  l_act_entry_objid NUMBER;
  hold              NUMBER;
BEGIN
  p_dummy_out := 1;
  ----------------------------------------------------------------------------------------------------
  OPEN queue_curs(p_queue_name);
  FETCH queue_curs INTO queue_rec;
  IF queue_curs%NOTFOUND THEN
    CLOSE queue_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE queue_curs;
  --
  OPEN current_user_curs;
  FETCH current_user_curs INTO current_user_rec;
  IF current_user_curs%NOTFOUND THEN
    current_user_rec.user := 'appsrv'; -- changed from appsvr
  END IF;
  CLOSE current_user_curs;
  --
  OPEN case_curs(p_case_objid);
  FETCH case_curs INTO case_rec;
  IF case_curs%NOTFOUND THEN
    CLOSE case_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE case_curs;
  --
  OPEN condition_curs(case_rec.case_state2condition);
  FETCH condition_curs INTO condition_rec;
  IF condition_curs%NOTFOUND THEN
    CLOSE condition_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE condition_curs;
  --
  OPEN user2_curs(current_user_rec.user);
  FETCH user2_curs INTO user2_rec;
  IF user2_curs%NOTFOUND THEN
    CLOSE user2_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE user2_curs;
  --
  OPEN employee_curs(user2_rec.objid);
  FETCH employee_curs INTO employee_rec;
  IF employee_curs%NOTFOUND THEN
    CLOSE employee_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE employee_curs;
  --
  OPEN gbst_lst_curs('Activity Name');
  FETCH gbst_lst_curs INTO gbst_lst_rec;
  IF gbst_lst_curs%NOTFOUND THEN
    CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_lst_curs;
  --
  OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Dispatch');
  FETCH gbst_elm_curs INTO gbst_elm_rec;
  IF gbst_elm_curs%NOTFOUND THEN
    CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
    RETURN;
  END IF;
  CLOSE gbst_elm_curs;
  --
  --Updates the Condition Record
  UPDATE table_condition
  SET condition = 10 ,
    queue_time  = SYSDATE ,
    title       = 'Open-Dispatch' ,
    s_title     = 'OPEN-DISPATCH'
  WHERE objid   = condition_rec.objid;
  UPDATE table_case
  SET case_currq2queue = queue_rec.objid
  WHERE objid          = p_case_objid;
  --Build the Activity Entry
  -- 04/10/03 select seq_act_entry.nextval +(power(2,28)) into l_act_entry_objid from dual;
  SELECT seq('act_entry')
  INTO l_act_entry_objid
  FROM dual;
  --
  INSERT
  INTO table_act_entry
    (
      objid ,
      act_code ,
      entry_time ,
      addnl_info ,
      proxy ,
      removed ,
      act_entry2case ,
      act_entry2user ,
      entry_name2gbst_elm
    )
    VALUES
    (
      l_act_entry_objid ,
      900 ,
      SYSDATE ,
      ' Dispatched to Queue '
      || p_queue_name ,
      current_user_rec.user ,
      0 ,
      p_case_objid ,
      user2_rec.objid ,
      gbst_elm_rec.objid
    );

/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
  --Build The time_bomb entry
 INSERT INTO table_time_bomb
    ( objid ,
      title ,
      escalate_time ,
      end_time ,
      focus_lowid ,
      focus_type ,
      suppl_info ,
      time_period ,
      flags ,
      left_repeat ,
      report_title ,
      property_set ,
      users ,
      cmit_creator2employee
    )
    VALUES
    ( seq('time_bomb') ,
      NULL ,
      TO_DATE('01/01/1753' ,'dd/mm/yyyy') ,
      SYSDATE ,
      p_case_objid ,
      0 ,
      NULL ,
      l_act_entry_objid ,
      655362 ,
      0 ,
      NULL ,
      NULL ,
      NULL ,
      employee_rec.objid
    );
*/

END;
----------------------------------------------------------------------------------------------------
PROCEDURE sp_close_case
  (
    p_case_id         VARCHAR2 ,
    p_user_login_name VARCHAR2 ,
    p_source          VARCHAR2 ,
    p_resolution_code VARCHAR2 ,
    p_status OUT VARCHAR2 ,
    p_msg OUT VARCHAR2
  )
IS
  v_current_date DATE := SYSDATE;
  v_case_id table_case.id_number%TYPE;
  v_user_objid NUMBER;
  CURSOR c_case
  IS
    SELECT c.* --, q.title queue_title
    FROM       --table_queue q,
      table_case c
      --    WHERE q.objid = case_currq2queue
      --    AND
    WHERE id_number = v_case_id;
  rec_case c_case%ROWTYPE;
  CURSOR c_condition(c_condition_objid NUMBER)
  IS
    SELECT * FROM table_condition WHERE objid = c_condition_objid;
  rec_condition c_condition%ROWTYPE;
  CURSOR c_subcase
  IS
    SELECT *
    FROM table_case2sub_cls
    WHERE (case_id = v_case_id)
    ORDER BY close_date DESC;
  CURSOR c_gbst_elm ( c_gbst_lst_title VARCHAR2 ,c_gbst_elm_title VARCHAR2 )
  IS
    SELECT ge.title elm_title ,
      ge.objid elm_objid ,
      ge.rank ,
      gl.title lst_title ,
      gl.objid lst_objid
    FROM table_gbst_elm ge ,
      table_gbst_lst gl
    WHERE 1      = 1
    AND ge.title = c_gbst_elm_title
    AND gl.objid = ge.gbst_elm2gbst_lst
    AND gl.title = c_gbst_lst_title;
  CURSOR c_task ( c_esn VARCHAR2 ,c_min VARCHAR2 )
  IS
    SELECT t.*
    FROM table_condition c ,
      table_task t ,
      table_x_call_trans ct
    WHERE c.s_title
      || ''                   <> 'CLOSED ACTION ITEM'
    AND t.task_state2condition = c.objid
    AND ct.objid               = t.x_task2x_call_trans
    AND ct.x_action_type
      || ''            IN ('1' ,'2' ,'3' ,'5')
    AND ct.x_min        = c_min
    AND ct.x_service_id = c_esn;
  --CR4902
  CURSOR get_param_curs
  IS
    SELECT x_param_value
    FROM table_x_parameters
    WHERE x_param_name = 'CLOSE_CASE_SUCCESS';
  get_param_rec get_param_curs%ROWTYPE;
  v_succ_notes VARCHAR2(2000);
  --CR4902
  v_seq_close_case      NUMBER;
  v_seq_act_entry       NUMBER;
  v_seq_time_bomb       NUMBER;
  v_resolution_gbst     VARCHAR2(80) := 'Resolution Code';
  v_resolution_default  VARCHAR2(80) := 'Carri Problem Solved';
  v_resolution_code     VARCHAR2(80);
  v_addl_info           VARCHAR2(255);
  v_actl_phone_time     NUMBER := 0;
  v_sub_actl_phone_time NUMBER := 0;
  v_sub_calc_phone_time NUMBER := 0;
  v_calc_phone_time     NUMBER := 0;
  v_tot_actl_phone_time NUMBER := 0;
  v_case_history        VARCHAR2(32000);
  rec_case_sts_closed c_gbst_elm%ROWTYPE;
  rec_act_caseclose c_gbst_elm%ROWTYPE;
  rec_act_accept c_gbst_elm%ROWTYPE;
  rec_resolution_code c_gbst_elm%ROWTYPE;
  hold NUMBER;
BEGIN
  v_case_id         := RTRIM(LTRIM(p_case_id));
  v_resolution_code := p_resolution_code;
  v_resolution_code := RTRIM(LTRIM(NVL(v_resolution_code ,' ')));
  --CR4902
  OPEN get_param_curs;
  FETCH get_param_curs INTO get_param_rec;
  IF get_param_curs%FOUND THEN
    v_succ_notes := get_param_rec.x_param_value;
  ELSE
    v_succ_notes := NULL;
  END IF;
  CLOSE get_param_curs;
  --CR4902
  OPEN c_case;
  FETCH c_case INTO rec_case;
  IF c_case%NOTFOUND THEN
    p_status := 'F';
    p_msg    := 'CASE ' || NVL(p_case_id ,'<NULL>') || ' not found';
    CLOSE c_case;
    RETURN;
  END IF;
  CLOSE c_case;
  dbms_output.put_line('CASE ' || v_case_id || ' found.');
  --CR25000
  UPDATE sa.x_esn_ber_place_holder
  SET x_reserved_flag    = NULL,
    x_last_reserved_date = NULL
  WHERE x_reserved_flag  =rec_case.x_esn;
  --CR25000
  BEGIN
    SELECT objid
    INTO v_user_objid
    FROM table_user
    WHERE s_login_name = UPPER(p_user_login_name);
  EXCEPTION
  WHEN OTHERS THEN
    p_status := 'F';
    p_msg    := 'User login name ' || p_user_login_name || ' not found.';
    RETURN;
  END;
  dbms_output.put_line('User login name ' || p_user_login_name || ' found.');
  dbms_output.put_line('length of resolution code: ' || LENGTH(v_resolution_code));
  --IF length(v_resolution_code) < 1 or v_resolution_code is null THEN
  IF NVL(LENGTH(v_resolution_code) ,0) < 1 THEN
    v_resolution_code                 := v_resolution_default;
  END IF;
  -- CR4831 -- by pass Resolution Code check if  p_resolution_code = 'Expired'
  IF p_resolution_code = 'Expired' THEN
    OPEN c_gbst_elm('Closed' ,'Expired');
    FETCH c_gbst_elm INTO rec_resolution_code;
  ELSE
    OPEN c_gbst_elm(v_resolution_gbst ,v_resolution_code);
    FETCH c_gbst_elm INTO rec_resolution_code;
  END IF;
  -- CR4831
  IF c_gbst_elm%NOTFOUND THEN
    p_status := 'F';
    p_msg    := 'Resolution code ' || v_resolution_code || ' is not valid';
    CLOSE c_gbst_elm;
    RETURN;
  END IF;
  CLOSE c_gbst_elm;
  dbms_output.put_line('Resolution code: ' || v_resolution_code);
  OPEN c_condition(NVL(rec_case.case_state2condition ,0));
  FETCH c_condition INTO rec_condition;
  IF c_condition%NOTFOUND THEN
    p_status := 'F';
    p_msg    := 'CONDITION FOR CASE ' || v_case_id || ' not found.';
    CLOSE c_condition;
    RETURN;
  END IF;
  CLOSE c_condition;
  dbms_output.put_line('CONDITION objid FOR ' || v_case_id || ' is ' || rec_condition.objid);
  IF rec_condition.s_title LIKE 'CLOSED%' THEN
    p_status := 'F';
    p_msg    := 'Case ' || p_case_id || ' is already closed.';
    RETURN;
  END IF;
  -- CR4831 - Set as expired / Closed in case the 'p_resolution_code' = 'Expired'
  IF p_resolution_code = 'Expired' THEN
    OPEN c_gbst_elm('Closed' ,'Expired');
    FETCH c_gbst_elm INTO rec_case_sts_closed;
  ELSE
    OPEN c_gbst_elm('Closed' ,'Closed');
    FETCH c_gbst_elm INTO rec_case_sts_closed;
  END IF;
  -- CR4831
  IF c_gbst_elm%NOTFOUND THEN
    p_status := 'F';
    p_msg    := 'Status for closed case not found';
    CLOSE c_gbst_elm;
    RETURN;
  END IF;
  CLOSE c_gbst_elm;
  dbms_output.put_line('Status for closed case found');
  OPEN c_gbst_elm('Activity Name' ,'Case Close');
  FETCH c_gbst_elm INTO rec_act_caseclose;
  IF c_gbst_elm%NOTFOUND THEN
    p_status := 'F';
    p_msg    := 'Activity code for closed case not found';
    CLOSE c_gbst_elm;
    RETURN;
  END IF;
  CLOSE c_gbst_elm;
  OPEN c_gbst_elm('Activity Name' ,'Accept');
  FETCH c_gbst_elm INTO rec_act_accept;
  IF c_gbst_elm%NOTFOUND THEN
    p_status := 'F';
    p_msg    := 'Activity code for accepting case not found';
    CLOSE c_gbst_elm;
    RETURN;
  END IF;
  CLOSE c_gbst_elm;
  dbms_output.put_line('Activity code for closed case not found');
  dbms_output.put_line('Start to close case:');
  IF rec_case.hangup_time IS NOT NULL THEN
    v_actl_phone_time     := (rec_case.hangup_time - rec_case.creation_time) * 24 * 60 * 60;
    IF v_actl_phone_time  IS NULL OR v_actl_phone_time < 0 THEN
      v_actl_phone_time   := 0;
    END IF;
  ELSE
    v_actl_phone_time := 0;
  END IF;
  FOR c_subcase_rec IN c_subcase
  LOOP
    v_sub_actl_phone_time := v_sub_actl_phone_time + NVL(c_subcase_rec.actl_phone_time ,0);
    v_sub_calc_phone_time := v_sub_calc_phone_time + NVL(c_subcase_rec.calc_phone_time ,0);
  END LOOP;
  v_actl_phone_time     := ROUND(v_actl_phone_time + v_sub_actl_phone_time);
  v_calc_phone_time     := ROUND(v_actl_phone_time + v_sub_calc_phone_time);
  v_tot_actl_phone_time := ROUND(v_actl_phone_time);
  dbms_output.put_line('actl_phone_time: ' || v_actl_phone_time);
  dbms_output.put_line('calc_phone_time: ' || v_calc_phone_time);
  dbms_output.put_line('v_tot_actl_phone_time: ' || v_tot_actl_phone_time);
  -- find related TASK
  FOR c_task_rec IN c_task(rec_case.x_esn ,rec_case.x_min)
  LOOP
    dbms_output.put_line('Related ACTION ITEM FOUND, TASK_ID: ' || c_task_rec.task_id);
    dbms_output.put_line('c_task_rec.objid:' || c_task_rec.objid);
    sp_close_action_item(c_task_rec.objid ,0 ,hold);
  END LOOP;
  BEGIN
    UPDATE table_condition
    SET condition = 4 ,
      title       = 'Closed' ,
      s_title     = 'CLOSED'
    WHERE objid   = rec_condition.objid;
    --
    --    FOR upd_condition_rec IN ( SELECT rowid from table_condition
    --                               WHERE objid = rec_condition.objid for update nowait)
    --    LOOP
    --      UPDATE TABLE_CONDITION
    --      SET condition = 4, title='Closed', s_title='CLOSED'
    --      WHERE rowid = upd_condition_rec.rowid;
    --      AND   (  ( (mod(condition,16) >= 8) or (mod(condition,64) >= 32)
    --                   or (mod(condition,1024) >= 512)) );
    --      IF SQL%ROWCOUNT <=0 THEN
    --        p_status := 'F';
    --        p_msg := 'The record may have been changed, please refresh and try again.';
    --        RETURN;
    --      END IF;
    --    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'F';
    p_msg    := SUBSTR('Unable to update condition for case id ' || v_case_id || SQLERRM ,1 ,255);
    RETURN;
  END;
  dbms_output.put_line('Condition for Case id ' || v_case_id || ' updated.');
  v_case_history := rec_case.case_history;
  v_case_history := v_case_history || CHR(10) || '*** CASE CLOSE ' ||
  --CR3221 Start
  --         TO_CHAR (v_current_date, 'DD/MM/YY HH:MI:SS AM ') ||
  TO_CHAR(v_current_date ,'MM/DD/YYYY HH:MI:SS AM ') ||
  --CR3221 End
  p_user_login_name || ' FROM source "' || p_source || '"' || CHR(10) || v_succ_notes; --CR4902
  BEGIN
    UPDATE table_case
    SET case_currq2queue = NULL ,
      case_wip2wipbin    = NULL ,
      case_owner2user    = v_user_objid ,
      casests2gbst_elm   = rec_case_sts_closed.elm_objid ,
      case_history       = v_case_history
    WHERE objid          = rec_case.objid;
    --    FOR upd_rec_case IN (select rowid from table_case
    --                        where objid = rec_case.objid for update nowait)
    --    LOOP
    --     UPDATE table_case set case_currq2queue = NULL
    --                          ,case_wip2wipbin = NULL
    --                          ,case_owner2user = v_user_objid
    --                          ,casests2gbst_elm = rec_case_sts_closed.elm_objid
    --                          ,case_history = v_case_history
    --     WHERE rowid = upd_rec_case.rowid;
    --    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'F';
    p_msg    := SUBSTR('Unable to update case record for case id ' || v_case_id || ': ' || SQLERRM ,1 ,255);
    RETURN;
  END;
  dbms_output.put_line('Case record updated.');
  -- 04/10/03 SELECT SEQ_act_entry.nextval + power(2,28) INTO v_seq_act_entry from dual;
  SELECT seq('act_entry')
  INTO v_seq_act_entry
  FROM dual;
  --SELECT SEQ_time_bomb.nextval INTO v_seq_time_bomb;
  v_addl_info := 'Status = Closed, Resolution Code =' || v_resolution_code || ' State = Open.';
  dbms_output.put_line('table_act_entry record: ' || CHR(10));
  dbms_output.put_line('OBJID : ' || v_seq_act_entry);
  dbms_output.put_line('ACT_CODE : ' || rec_act_caseclose.rank);
  dbms_output.put_line('ENTRY_TIME : ' || v_current_date);
  dbms_output.put_line('ADDNL_INFO : ' || v_addl_info);
  dbms_output.put_line('ENTRY_NAME2GBST_ELM : ' || rec_act_caseclose.elm_objid);
  dbms_output.put_line('ACT_ENTRY2CASE : ' || rec_case.objid);
  dbms_output.put_line('ACT_ENTRY2USER : ' || v_user_objid);
  BEGIN
    INSERT
    INTO table_act_entry
      (
        objid ,
        act_code ,
        entry_time ,
        addnl_info ,
        proxy ,
        removed ,
        focus_type ,
        focus_lowid ,
        entry_name2gbst_elm ,
        act_entry2case ,
        act_entry2user
      )
      VALUES
      (
        v_seq_act_entry ,
        rec_act_caseclose.rank ,
        v_current_date ,
        v_addl_info ,
        '' ,
        0 ,
        0 ,
        0 ,
        rec_act_caseclose.elm_objid ,
        rec_case.objid ,
        v_user_objid
      );
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'F';
    p_msg    := SUBSTR('Unable to create new activity record: ' || SQLERRM ,1 ,255);
    RETURN;
  END;
  -- 04/10/03 SELECT SEQ_close_case.nextval + power(2,28) INTO v_seq_close_case FROM dual;
  SELECT seq('close_case')
  INTO v_seq_close_case
  FROM dual;
  dbms_output.put_line('table_close_case record: ' || v_seq_close_case || CHR(10));
  dbms_output.put_line('OBJID : ' || v_seq_close_case);
  dbms_output.put_line('close_date : ' || v_current_date);
  dbms_output.put_line('actl_phone_time : ' || v_actl_phone_time);
  dbms_output.put_line('calc_phone_time : ' || v_calc_phone_time);
  dbms_output.put_line('tot_actl_phone_time : ' || v_tot_actl_phone_time);
  dbms_output.put_line('cls_old_stat2gbst_elm : ' || rec_case.casests2gbst_elm);
  dbms_output.put_line('cls_new_stat2gbst_elm : ' || rec_case_sts_closed.elm_objid);
  dbms_output.put_line('close_rsolut2gbst_elm : ' || rec_resolution_code.elm_objid);
  dbms_output.put_line('last_close2case : ' || rec_case.objid);
  dbms_output.put_line('closer2employee : ' || v_user_objid);
  dbms_output.put_line('close_case2act_entry : ' || v_seq_act_entry);
  BEGIN
    INSERT
    INTO table_close_case
      (
        objid ,
        close_date ,
        actl_phone_time ,
        calc_phone_time ,
        actl_rsrch_time ,
        calc_rsrch_time ,
        used_unit ,
        summary ,
        tot_actl_phone_time ,
        tot_actl_rsrch_time ,
        actl_bill_exp ,
        actl_nonbill ,
        calc_bill_exp ,
        calc_nonbill ,
        tot_actl_bill ,
        tot_actl_nonb ,
        bill_time ,
        nonbill_time ,
        previous_closed ,
        cls_old_stat2gbst_elm ,
        cls_new_stat2gbst_elm ,
        close_rsolut2gbst_elm ,
        last_close2case ,
        closer2employee ,
        close_case2act_entry
      )
      VALUES
      (
        v_seq_close_case ,
        v_current_date ,
        v_actl_phone_time ,
        v_calc_phone_time ,
        0 ,
        0 ,
        0.000000 ,
        '' ,
        v_tot_actl_phone_time ,
        0 ,
        0.0 ,
        0.0 ,
        0.0 ,
        0.0 ,
        0.0 ,
        0.0 ,
        0 ,
        0 ,
        TO_DATE('01/01/1753 00:00:00' ,'MM/DD/YYYY HH24:MI:SS') ,
        rec_case.casests2gbst_elm ,
        rec_case_sts_closed.elm_objid ,
        rec_resolution_code.elm_objid ,
        rec_case.objid ,
        v_user_objid ,
        v_seq_act_entry
      );
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_status := 'F';
    p_msg    := SUBSTR('Unable to create new close case record: ' || SQLERRM ,1 ,255);
    RETURN;
  END;
  --rollback;
  COMMIT;
  p_status := 'S';
  p_msg    := 'Completed sucessfully';
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  p_status := 'F';
  p_msg    := SUBSTR('Unexpected error detected when trying to close case ' || v_case_id || ': ' || SQLERRM ,1 ,255);
END sp_close_case;
----------------------------------------------------------------------------------------------------
PROCEDURE reopen_case_proc
  (
    p_case_objid      IN NUMBER ,
    p_queue_name      IN VARCHAR2 ,
    p_notes           IN VARCHAR2 ,
    p_user_login_name IN VARCHAR2 ,
    p_error_message OUT VARCHAR2
  )
IS
  -- To get Case and Condition of the Case
  CURSOR c_case
  IS
    SELECT cs.rowid case_rowid ,
      cs.objid case_objid ,
      cs.case_history case_history ,
      cnd.s_title condition_s_title ,
      cnd.objid condition_objid
    FROM table_case cs ,
      table_condition cnd
    WHERE cnd.objid = cs.case_state2condition
    AND cs.objid    = p_case_objid;
  rec_case c_case%ROWTYPE;
  -- To get objid from table_gbst_elm
  CURSOR c_act_entry
  IS
    SELECT objid
    FROM table_gbst_elm
    WHERE s_title         = 'REOPEN'
    AND gbst_elm2gbst_lst = 268435579;
  rec_act_entry c_act_entry%ROWTYPE;
  -- To get the current User
  CURSOR c_user
  IS
    SELECT objid FROM table_user WHERE s_login_name = UPPER(p_user_login_name);
  c_user_objid table_user.objid%TYPE;
  -- local variables
  long_case_history table_case.case_history%TYPE;
  n_dummy_out NUMBER;
BEGIN
  -- input proc params:
  -- p_queue_name := 'LINE MANAGEMENT';
  p_error_message := '';
  -- get Gbst_elm record.
  OPEN c_act_entry;
  FETCH c_act_entry INTO rec_act_entry;
  IF c_act_entry%NOTFOUND THEN
    p_error_message := 'ACT ENTRY TYPE for REOPEN not found';
    CLOSE c_act_entry;
    -------
    -- * --
    -------
    RETURN;
  END IF;
  CLOSE c_act_entry;
  -- get Case details.
  OPEN c_case;
  FETCH c_case INTO rec_case;
  IF c_case%NOTFOUND THEN
    p_error_message := 'Case not found';
    CLOSE c_case;
    -------
    -- * --
    -------
    RETURN;
  ELSE
    -- Check if the case is still open
    IF rec_case.condition_s_title <> 'CLOSED' THEN
      p_error_message             := 'Case is Still Open';
      CLOSE c_case; --Fix OPEN_CURSORS
      -------
      -- * --
      -------
      RETURN;
    END IF;
    CLOSE c_case; --Fix OPEN_CURSORS
    -- Get the user info
    OPEN c_user;
    FETCH c_user INTO c_user_objid;
    IF c_user%NOTFOUND THEN
      p_error_message := 'Unable to reopen case. User login name ' || p_user_login_name || ' not found in table_user.';
      CLOSE c_user;
      -------
      -- * --
      -------
      RETURN;
    END IF;
    CLOSE c_user;
    -- Update table case
    long_case_history := rec_case.case_history;
    long_case_history := long_case_history || CHR(10) || CHR(13) || '*** Notes ' || SYSDATE || ' ' || p_notes;
    UPDATE table_case
    SET case_history   = long_case_history ,
      casests2gbst_elm =
      (SELECT objid
      FROM table_gbst_elm
      WHERE s_title         = 'PENDING'
      AND gbst_elm2gbst_lst = 268435562
      ) ,
      case_wip2wipbin =
      (SELECT objid
      FROM table_wipbin
      WHERE s_title         = 'DEFAULT'
      AND wipbin_owner2user =
        (SELECT objid FROM table_user WHERE s_login_name = 'SA'
        )
      )
    WHERE ROWID = rec_case.case_rowid;
    -- Update table condition
    UPDATE table_condition
    SET s_title = 'OPEN' ,
      title     = 'Open' ,
      condition = 2
    WHERE objid = rec_case.condition_objid;
    -- Insert act_entry to leave log of the 'no Line Available'
    INSERT
    INTO table_act_entry
      (
        objid ,
        act_code ,
        entry_time ,
        addnl_info ,
        act_entry2case ,
        act_entry2user ,
        entry_name2gbst_elm
      )
      VALUES
      (
        seq('act_entry') ,
        2400 ,
        SYSDATE ,
        'with Condition of Open and Status of Pending.' ,
        rec_case.case_objid ,
        c_user_objid ,
        rec_act_entry.objid
      );
    -- Dispatch the case (this procedure will, among other things, update queue name on table_case...)
    sp_dispatch_case(rec_case.case_objid ,p_queue_name ,n_dummy_out);
    COMMIT;
  END IF; -- ...IF c_case%NOTFOUND
END reopen_case_proc;
PROCEDURE call_sp_determine_trans_method
  (
    p_action_item_objid  IN NUMBER ,
    p_order_type         IN VARCHAR2 ,
   p_trans_method       IN VARCHAR2 ,
    p_application_system IN VARCHAR2 DEFAULT 'IG' ,
    p_destination_queue OUT NUMBER
  )
IS
pragma autonomous_transaction;
BEGIN
  /*
  |  Wrapper procedure to call sp_determine_trans_method from the Clarify software.
  |  OUT parameter in the procedure declaration has to be the last parametar or
  |  the procedure can't be called from Clarify.
  */
  sp_determine_trans_method(p_action_item_objid => p_action_item_objid ,
                            p_order_type => p_order_type ,
                            p_trans_method => p_trans_method ,
                            p_application_system => p_application_system ,
                            p_destination_queue => p_destination_queue);
commit;
END call_sp_determine_trans_method;
--CR40522

FUNCTION sf_get_carr_feat
  (
    p_order_type         IN VARCHAR2 ,
    p_st_esn_flag        IN VARCHAR2 ,
    p_site_part_objid    IN NUMBER ,
    p_esn                IN VARCHAR2 ,
    p_carrier_objid      IN NUMBER ,
    p_carr_feature_objid IN NUMBER ,
    p_data_capable       IN VARCHAR2 ,
    p_template           IN VARCHAR2 ,
    p_service_plan_id    IN NUMBER DEFAULT NULL
--    ,p_action_item_id    in varchar2
  ) RETURN NUMBER IS

  RETURN_VAR	NUMBER;

  BEGIN

	RETURN_VAR	:=	IGATE.sf_get_carr_feat	  (
							    p_order_type         ,
							    p_st_esn_flag        ,
							    p_site_part_objid    ,
							    p_esn                ,
							    p_carrier_objid      ,
							    p_carr_feature_objid ,
							    p_data_capable       ,
							    p_template           ,
							    p_service_plan_id
							--    ,p_action_item_id
							    ,NULL
							  );

	RETURN RETURN_VAR;

  EXCEPTION WHEN OTHERS
  THEN
  NULL;
  END sf_get_carr_feat;


FUNCTION sf_get_carr_feat
  (
    p_order_type         IN VARCHAR2 ,
    p_st_esn_flag        IN VARCHAR2 ,
    p_site_part_objid    IN NUMBER ,
    p_esn                IN VARCHAR2 ,
    p_carrier_objid      IN NUMBER ,
    p_carr_feature_objid IN NUMBER ,
    p_data_capable       IN VARCHAR2 ,
    p_template           IN VARCHAR2 ,
    p_service_plan_id    IN NUMBER DEFAULT NULL
--    ,p_action_item_id    in varchar2
    ,p_task_objid	IN VARCHAR2	--CR46807
  ) RETURN NUMBER IS
  cursor device_curs is
    select /*+ ORDERED */
           bo.org_id,
           bo.objid bo_objid,
           pn.x_technology,
           sp.x_service_id esn,
           nvl((select to_number(v.x_param_value)
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'DATA_SPEED'
                   and rownum <2),nvl(x_data_capable,0)) data_speed,
           nvl((select v.x_param_value
                 from table_x_part_class_values v,
                      table_x_part_class_params n
                where 1=1
                  and v.value2part_class     = pn.part_num2part_class
                  and v.value2class_param    = n.objid
                  and n.x_param_name         = 'DEVICE_TYPE'
                  and rownum <2),'FEATURE_PHONE') device_type
      from
            table_site_part sp
           ,table_mod_level ml
           ,table_part_num pn
           ,table_bus_org bo
     where 1=1
       and sp.objid = p_site_part_objid
       and ml.objid = sp.site_part2part_info
       and pn.objid = ml.part_info2part_num
       and bo.objid = pn.part_num2bus_org;
  device_rec device_curs%rowtype;
  cursor device_curs2(c_esn in varchar2) is
    select /*+ ORDERED */
           bo.org_id,
           bo.objid bo_objid,
           pn.x_technology,
           pi.part_serial_no esn,
           nvl((select to_number(v.x_param_value)
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'DATA_SPEED'
                   and rownum <2),nvl(x_data_capable,0)) data_speed,
           nvl((select v.x_param_value
                 from table_x_part_class_values v,
                      table_x_part_class_params n
                where 1=1
                  and v.value2part_class     = pn.part_num2part_class
                  and v.value2class_param    = n.objid
                  and n.x_param_name         = 'DEVICE_TYPE'
                  and rownum <2),'FEATURE_PHONE') device_type
      from
            table_part_inst pi
           ,table_mod_level ml
           ,table_part_num pn
           ,table_bus_org bo
     where 1=1
       and pi.part_serial_no = c_esn
       and pi.x_domain = 'PHONES'
       and ml.objid = pi.n_part_inst2part_mod
       and pn.objid = ml.part_info2part_num
       and bo.objid = pn.part_num2bus_org;
--
  cursor service_plan_mkt_curs(c_service_plan_id in number) is
    select mkt_name, cast('SAFELINK' as varchar2(100)) plan_type
      from x_service_plan
     where objid = c_service_plan_id
       and upper(mkt_name) like '%SAFELINK%';
  service_plan_mkt_rec service_plan_mkt_curs%rowtype;
  cursor service_plan_curs(c_site_part_objid in number) is
    select 1 col1,
           sysdate date_col1,
           spsp.x_service_plan_id,
           xsp.mkt_name
      from  x_service_plan_site_part spsp
           ,x_service_plan xsp
     where 1=1
      and spsp.table_site_part_id = c_site_part_objid
      and xsp.objid               = spsp.x_service_plan_id
    union
    select 2 col1,
           sp2.install_date date_col1,
           spsp.x_service_plan_id,
           xsp.mkt_name
      from  table_site_part sp
           ,table_site_part sp2
           ,x_service_plan_site_part spsp
           ,x_service_plan xsp
     where 1=1
      and sp.objid                = c_site_part_objid
      and sp2.x_service_id        = sp.x_service_id
      and spsp.table_site_part_id = sp2.objid
      and xsp.objid               = spsp.x_service_plan_id
    order by col1 asc,date_col1 desc;
  service_plan_rec service_plan_curs%rowtype;
--
  cursor tw_service_plan_curs(c_esn in varchar2) is
    select ag.service_plan_id
      FROM x_account_group_member agm,
           x_account_group ag
     WHERE 1        = 1
       AND agm.esn  = c_esn
       AND ag.objid = agm.account_group_id;
  tw_service_plan_rec tw_service_plan_curs%rowtype;
--
  cursor multi_rate_plan_curs(c_esn in varchar2,
                              c_service_plan_id in number) is
    SELECT x_priority
      FROM x_multi_rate_plan_esns
     WHERE x_esn             = c_esn
       AND x_service_plan_id = c_service_plan_id;
  multi_rate_plan_rec multi_rate_plan_curs%rowtype;
--
  cursor parent_curs(c_carrier_objid in number,
                     c_technology    in varchar2,
                     c_org_id        in varchar2,
	             c_plan_type     in varchar2) is
    select /*+ ORDERED */
           pa.x_parent_name,
           case when c_org_id = 'NET10' and c_technology = 'GSM' and pa.x_parent_name like 'T-MOB%' and c_plan_type = 'SAFELINK' then
                  'T-MOBILE SAFELINK'
                when c_org_id = 'NET10' and c_technology = 'GSM' and pa.x_parent_name like 'T-MOB%' and c_plan_type != 'SAFELINK' then
                  'T-MOBILE'
                when c_org_id = 'NET10' and c_technology = 'GSM' and (pa.x_parent_name like 'AT%' or pa.x_parent_name like 'CING%') and c_plan_type = 'SAFELINK' then
                  'AT&T SAFELINK'
                when c_org_id = 'NET10' and c_technology = 'GSM' and pa.x_parent_name like 'AT%' and c_plan_type  != 'SAFELINK' then
                  'CINGULAR'
                when c_org_id = 'NET10' and c_technology = 'CDMA' and pa.x_parent_name like 'SPRINT%' then
                  'SPRINT_NET10'
                when c_org_id = 'NET10' and c_technology = 'CDMA' and pa.x_parent_name like 'VERIZ%' and c_plan_type = 'SAFELINK' then
                  'VERIZON SAFELINK'
                when c_org_id = 'NET10' and c_technology = 'CDMA' and pa.x_parent_name like 'VERIZ%' and c_plan_type != 'SAFELINK' then
                  'VERIZON WIRELESS'
                when c_org_id = 'NET10' and c_technology = 'CDMA' and pa.x_parent_name like 'CLARO%' and c_plan_type = 'SAFELINK' then
                  'CLARO SAFELINK'
                when c_org_id = 'NET10' and c_technology = 'CDMA' and pa.x_parent_name like 'CLARO%' and c_plan_type != 'SAFELINK' then
                  'CLARO'
                else
                  pa.x_parent_name
                end nt_parent_name,
           case when c_org_id = 'TOTAL_WIRELESS' and c_technology = 'CDMA' and pa.x_parent_name like 'VER%' then
                  'VERIZON WIRELESS'
                else
                  pa.x_parent_name
                end tw_parent_name,
           case when c_org_id = 'SIMPLE_MOBILE' and c_technology = 'GSM' and pa.x_parent_name like 'T-MOB%' then
                  'T-MOBILE SIMPLE'
                else
                  pa.x_parent_name
                end sm_parent_name,
           case when c_org_id = 'STRAIGHT_TALK' and c_technology = 'GSM' and (pa.x_parent_name like 'AT&T%' or pa.x_parent_name like 'CING%') then
                  'AT&T PREPAY PLATFORM'
                when c_org_id = 'STRAIGHT_TALK' and c_technology = 'CDMA' and (pa.x_parent_name like 'AT&T%' or pa.x_parent_name like 'CING%') then
                  'VERIZON PREPAY PLATFORM'
                when c_org_id = 'STRAIGHT_TALK' and c_technology = 'GSM' and (pa.x_parent_name like 'SPR%' or pa.x_parent_name like 'VER%') then
                  'AT&T PREPAY PLATFORM'
                when c_org_id = 'STRAIGHT_TALK' and pa.x_parent_name like 'VERIZON%' then
                  'VERIZON PREPAY PLATFORM'
                when c_org_id = 'STRAIGHT_TALK' and pa.x_parent_name like 'T-MOB%' then
                  'T-MOBILE PREPAY PLATFORM'
                else
                  pa.x_parent_name
                end st_parent_name,
--CR44221
           case when c_org_id = 'TRACFONE' and c_technology = 'GSM' and (pa.x_parent_name like 'AT%' or pa.x_parent_name like 'CING%') and c_plan_type = 'SAFELINK' then
                  'AT&T SAFELINK'
                when c_org_id = 'TRACFONE' and c_technology = 'GSM' and (pa.x_parent_name like 'AT%' or pa.x_parent_name like 'CING%') and c_plan_type != 'SAFELINK' then
                  'CINGULAR'
                when c_org_id = 'TRACFONE' and c_technology = 'GSM' and pa.x_parent_name like 'T_M%' and c_plan_type = 'SAFELINK' then
                  'T-MOBILE SAFELINK'
                when c_org_id = 'TRACFONE' and c_technology = 'GSM' and pa.x_parent_name like 'T_M%' and c_plan_type != 'SAFELINK' then
                  'T-MOBILE'
                when c_org_id = 'TRACFONE' and c_technology = 'CDMA' and pa.x_parent_name like 'CLARO%' and c_plan_type = 'SAFELINK' then
                  'CLARO SAFELINK'
                when c_org_id = 'TRACFONE' and c_technology = 'CDMA' and pa.x_parent_name like 'CLARO%' and c_plan_type != 'SAFELINK' then
                  'CLARO'
                when c_org_id = 'TRACFONE' and c_technology = 'CDMA' and pa.x_parent_name like 'VER%' and c_plan_type = 'SAFELINK' then
                  'VERIZON SAFELINK'
                when c_org_id = 'TRACFONE' and c_technology = 'CDMA' and pa.x_parent_name like 'VER%' and c_plan_type != 'SAFELINK' then
                  'VERIZON WIRELESS'
                else
                  pa.x_parent_name
                end tf_parent_name,
           decode(pa.x_parent_name,'AT&T SAFELINK','CINGULAR'
                                  ,'AT&T PREPAY PLATFORM','CINGULAR'
                                  ,'T-MOBILE SAFELINK','T-MOBILE'
                                  ,'VERIZON SAFELINK', 'VERIZON WIRELESS'
                                  ,'VERIZON PREPAY PLATFORM','VERIZON WIRELESS'
                                  ,'DOBSON CELLULAR','CINGULAR'
                                  ,pa.x_parent_name) alt_parent_name
      from  table_x_carrier ca
           ,table_x_carrier_group cg
           ,table_x_parent pa
     where 1=1
       and ca.objid = c_carrier_objid
       AND cg.objid = ca.carrier2carrier_group
       and pa.objid = cg.x_carrier_group2x_parent;
  parent_rec parent_curs%rowtype;
--
  cursor mkt_rate_plan_curs(c_service_plan_id in number,
                            c_data_speed      in number,
                            c_priority        in number,
                            c_carrier_objid   in varchar2) is
    select /* ORDERED */
            xcf.objid cf_objid
           ,xcf.x_rate_plan
           ,mtm.priority
      from
            table_x_carrier_features xcf
           ,mtm_sp_carrierfeatures mtm
     where 1=1
       AND xcf.x_feature2x_carrier       = c_carrier_objid
       AND xcf.x_data                    = c_data_speed
       AND mtm.x_carrier_features_id     = xcf.objid
       AND mtm.x_service_plan_id         = c_service_plan_id
       AND mtm.priority                  in(1, c_priority)
    union
    select /* ORDERED */
            xcf.objid cf_objid
           ,xcf.x_rate_plan
           ,mtm.priority
      from  table_x_carrier_features xcf
           ,mtm_sp_carrierfeatures_dflt mtm
     where 1=1
       AND xcf.x_feature2x_carrier       = c_carrier_objid
       AND xcf.x_data                    = c_data_speed
       AND mtm.x_carrier_features_id     = xcf.objid
       AND mtm.x_service_plan_id         = c_service_plan_id
       AND mtm.priority                  in(1, c_priority)
     order by priority desc;
  rate_plan_rec   mkt_rate_plan_curs%rowtype;
  cursor rate_plan_curs(c_service_plan_id in number,
                        c_data_speed      in number,
                        c_priority        in number,
                        c_parent_name     in varchar2) is
    select /* ORDERED */
            xcf.objid cf_objid
           ,xcf.x_rate_plan
           ,mtm.priority
      from  table_x_parent pa
           ,table_x_carrier_group cg2
           ,table_x_carrier ca2
           ,table_x_carrier_features xcf
           ,mtm_sp_carrierfeatures mtm
     where 1=1
       and pa.x_parent_name              = c_parent_name
       and cg2.x_carrier_group2x_parent  = pa.objid
       AND ca2.carrier2carrier_group     = cg2.objid
      -- and ca2.objid != 268467960 --CR 44291 CR44801 Budget rate plan change
       AND xcf.x_feature2x_carrier       = ca2.objid
       AND xcf.x_data                    = c_data_speed
       AND mtm.x_carrier_features_id     = xcf.objid
       AND mtm.x_service_plan_id         = c_service_plan_id
       AND mtm.priority                  in(1, c_priority)
    union
    select /* ORDERED */
            xcf.objid cf_objid
           ,xcf.x_rate_plan
           ,mtm.priority
      from  table_x_parent pa
           ,table_x_carrier_group cg2
           ,table_x_carrier ca2
           ,table_x_carrier_features xcf
           ,mtm_sp_carrierfeatures_dflt mtm
     where 1=1
       and pa.x_parent_name              = c_parent_name
       and cg2.x_carrier_group2x_parent  = pa.objid
       AND ca2.carrier2carrier_group     = cg2.objid
      -- and ca2.objid != 268467960 --CR 44291 CR44801 Budget rate plan change
       AND xcf.x_feature2x_carrier       = ca2.objid
       AND xcf.x_data                    = c_data_speed
       AND mtm.x_carrier_features_id     = xcf.objid
       AND mtm.x_service_plan_id         = c_service_plan_id
       AND mtm.priority                  in(1, c_priority)
     order by priority desc;
  cursor rate_plan_curs2(c_service_plan_id in number,
                         c_data_speed      in number,
                         c_priority        in number,
                         c_parent_name     in varchar2) is
    select /* ORDERED */
            xcf.objid cf_objid
           ,xcf.x_rate_plan
           ,mtm.priority
      from  table_x_parent pa
           ,table_x_carrier_group cg2
           ,table_x_carrier ca2
           ,table_x_carrier_features xcf
           ,mtm_sp_carrierfeatures mtm
     where 1=1
       and pa.x_parent_name              = c_parent_name
       and cg2.x_carrier_group2x_parent  = pa.objid
       AND ca2.carrier2carrier_group     = cg2.objid
       --and ca2.objid != 268467960 --CR 44291  CR44801 Budget rate plan change
       AND xcf.x_feature2x_carrier       = ca2.objid
       AND xcf.x_data                    = c_data_speed
       AND mtm.x_carrier_features_id     = xcf.objid
       AND mtm.x_service_plan_id         = c_service_plan_id
    union
    select /* ORDERED */
            xcf.objid cf_objid
           ,xcf.x_rate_plan
           ,mtm.priority
      from  table_x_parent pa
           ,table_x_carrier_group cg2
           ,table_x_carrier ca2
           ,table_x_carrier_features xcf
           ,mtm_sp_carrierfeatures_dflt mtm
     where 1=1
       and pa.x_parent_name              = c_parent_name
       and cg2.x_carrier_group2x_parent  = pa.objid
       AND ca2.carrier2carrier_group     = cg2.objid
       --and ca2.objid != 268467960 --CR 44291  CR44801 Budget rate plan change
       AND xcf.x_feature2x_carrier       = ca2.objid
       AND xcf.x_data                    = c_data_speed
       AND mtm.x_carrier_features_id     = xcf.objid
       AND mtm.x_service_plan_id         = c_service_plan_id
     order by priority asc;
--
  cursor family_text2data_test_curs(c_esn in varchar2) is
    select (select objid
              from sa.x_service_plan sp3
             where sp3.mkt_name = 'TW 1 Line with Data') service_plan
      from sa.x_account_group_member agm,
           sa.x_account_group ag--,
           --sa.x_service_plan sp  CR44718
     where agm.ESN = c_esn
       and ag.objid = agm.ACCOUNT_GROUP_ID
       --and sp.objid = ag.SERVICE_PLAN_ID  CR44718
       --and sp.mkt_name  in ( 'TW Talk and Text Only','TW TALK AND TEXT ONLY AR 379') CR44718
	   and exists ( select 1    --CR44718
                  from x_service_plan_site_part spsp,
                       sa.x_service_plan sp
                 where spsp.TABLE_SITE_PART_ID = p_site_part_objid --table site part objid
                   and sp.objid = spsp.X_SERVICE_PLAN_ID
                   and sp.mkt_name  in ( 'TW Talk and Text Only','TW TALK AND TEXT ONLY AR 379'))
       AND EXISTS ( SELECT 1
                      FROM sa.x_account_group_benefit agb,
                           sa.x_service_plan sp2
                     WHERE agb.account_group_id = ag.objid
                       AND UPPER(agb.status) <> 'EXPIRED'
                       AND sp2.objid = agb.service_plan_id
                       -- use service plan feature (service_plan_group) to identify data add on cards
                       AND EXISTS ( SELECT 1
                                      FROM sa.service_plan_feat_pivot_mv
                                     WHERE service_plan_objid = sp2.objid
                                       AND service_plan_group = 'ADD_ON_DATA'));
  family_text2data_test_rec family_text2data_test_curs%rowtype;

--
  cursor input_cf_curs is
    SELECT xcf.objid cf_objid
      FROM table_x_carrier_features xcf
     WHERE 1       = 1
      AND xcf.objid = p_carr_feature_objid;
  input_cf_rec input_cf_curs%rowtype;
--
  cursor case_curs(c_esn in varchar2) is
    select 2 col1,
           c.CREATION_TIME case_date,
           (SELECT cd.x_value
              FROM table_x_case_detail cd
             WHERE cd.x_name = 'RATE_PLAN'
               AND cd.detail2case = c.objid
               AND rownum < 2) rate_plan,
           (SELECT cd.x_value
              FROM table_x_case_detail cd
             WHERE cd.x_name = 'NEW_SERVICE_PLAN_ID'
               AND cd.detail2case = c.objid
               AND rownum < 2) NEW_SERVICE_PLAN_ID
      FROM table_case c
      WHERE 1=1
      AND c.x_case_type || ''     = 'Port In'
      AND c.x_esn = c_esn
      ORDER BY col1 asc, case_date desc;
  case_rec case_curs%rowtype;
--
  cursor card_service_plan_curs(c_esn    in varchar2,
                                c_org_id in varchar2) is
      SELECT pn_pin.part_number pin_part_number
             ,decode(pi_esn.x_part_inst_status ,'40',2,'42',3,'43',4,'400',5) col1
             ,xsp.objid x_service_plan_id
             ,xsp.DESCRIPTION sp_desc
             ,pi_esn.x_insert_date col2
        FROM
             table_part_inst pi_esn
             ,table_mod_level ml_esn
             ,table_part_num  pn_esn
             ,table_part_inst pi_pin
             ,table_mod_level ml_pin
             ,table_part_num  pn_pin
	     ,table_bus_org bo_pin
             ,sa.MTM_PARTCLASS_X_SPF_VALUE_DEF B
             ,sa.x_serviceplanfeaturevalue_def a
             ,sa.mtm_partclass_x_spf_value_def d
             ,sa.x_serviceplanfeaturevalue_def c
             ,sa.X_SERVICEPLANFEATURE_VALUE SPFV
             ,sa.x_service_plan_feature spf
             ,sa.x_service_plan xsp
       WHERE 1                            = 1
         AND pi_esn.part_serial_no        = c_esn
         AND pi_esn.x_domain              = 'PHONES'
         AND ml_esn.objid                 = pi_esn.n_part_inst2part_mod
         AND pn_esn.objid                 = ml_esn.part_info2part_num
         AND pi_pin.part_to_esn2part_inst = pi_esn.objid
         AND pi_pin.x_part_inst_status    in ( '40','42','43','400')
         and pi_pin.x_domain              like 'RED%'
         AND ml_pin.objid                 = pi_pin.n_part_inst2part_mod
         AND pn_pin.objid                 = ml_pin.part_info2part_num
	 and bo_pin.objid                 = pn_pin.part_num2bus_org
	 and bo_pin.org_id                = c_org_id
         AND b.part_class_id              = PN_pin.PART_NUM2PART_CLASS
         and A.OBJID                      = B.SPFEATUREVALUE_DEF_ID
         AND D.PART_CLASS_ID              = PN_esn.PART_NUM2PART_CLASS
         AND C.OBJID                      = D.SPFEATUREVALUE_DEF_ID
         AND a.value_name                 = c.value_name
         AND SPFV.VALUE_REF               = a.objid
         AND SPF.OBJID                    = SPFV.SPF_VALUE2SPF
         AND xsp.objid                    = spf.sp_feature2service_plan
      union
      SELECT pn_pin.part_number pin_part_number
             ,1 col1
             ,xsp.objid x_service_plan_id
             ,xsp.DESCRIPTION sp_desc
             ,ct.x_transact_date col2
        FROM
             table_part_inst pi_esn
             ,table_x_call_trans ct
             ,table_x_red_card pi_pin
             ,table_mod_level ml_pin
             ,table_part_num  pn_pin
	     ,table_bus_org bo_pin
             ,table_mod_level ml_esn
             ,table_part_num  pn_esn
             ,sa.MTM_PARTCLASS_X_SPF_VALUE_DEF B
             ,sa.x_serviceplanfeaturevalue_def a
             ,sa.mtm_partclass_x_spf_value_def d
             ,sa.x_serviceplanfeaturevalue_def c
             ,sa.X_SERVICEPLANFEATURE_VALUE SPFV
             ,sa.x_service_plan_feature spf
             ,sa.x_service_plan xsp
       WHERE 1                          = 1
         and pi_esn.part_serial_no        = c_esn
         and pi_esn.x_domain              = 'PHONES'
         and ct.x_service_id              = pi_esn.part_serial_no
         and ct.x_result                  in ('Pending', 'Completed')
         and pi_pin.RED_CARD2CALL_TRANS   = ct.objid
         and pi_pin.x_result              in ('Pending', 'Completed')
         AND ml_pin.objid                 = pi_pin.X_RED_CARD2PART_MOD
         AND pn_pin.objid                 = ml_pin.part_info2part_num
	 and bo_pin.objid                 = pn_pin.part_num2bus_org
	 and bo_pin.org_id                = c_org_id
         AND ml_esn.objid                 = pi_esn.n_part_inst2part_mod
         AND pn_esn.objid                 = ml_esn.part_info2part_num
         AND b.part_class_id              = PN_pin.PART_NUM2PART_CLASS
         and A.OBJID                      = B.SPFEATUREVALUE_DEF_ID
         AND D.PART_CLASS_ID              = PN_esn.PART_NUM2PART_CLASS
         AND C.OBJID                      = D.SPFEATUREVALUE_DEF_ID
         AND a.value_name                 = c.value_name
         AND SPFV.VALUE_REF               = a.objid
         AND SPF.OBJID                    = SPFV.SPF_VALUE2SPF
         AND xsp.objid                    = spf.sp_feature2service_plan
      order by col1 asc,col2 desc;
  card_service_plan_rec card_service_plan_curs%rowtype;
--
  cursor sprint_curs(c_device_type in varchar2) is
    select cf.objid cf_objid
           ,cf.x_rate_plan
	   ,1 priority
      from TABLE_X_CARRIER_FEATURES cf
     where cf.x_rate_plan = decode(c_device_type,'FEATURE_PHONE','TRFPLAN1','TRFPLAN6');
--
  CURSOR carrier_features_curs1 ( c_objid IN NUMBER ,
                                  c_tech IN VARCHAR2 ,
                                  c_bus_org_objid IN NUMBER ,
                                  c_data_speed IN NUMBER,
                                  c_parent_name in varchar2,
                                  c_alt_parent_name in varchar2 ) IS
    SELECT  1 col1
           ,cf.objid cf_objid
           ,cf.x_rate_plan
           ,1 priority
      FROM table_x_carrier_features cf
     WHERE x_feature2x_carrier   = c_objid
       AND cf.x_technology       = c_tech
       AND cf.x_features2bus_org = c_bus_org_objid
       AND cf.x_data             = c_data_speed
     union
    SELECT  2 col1
           ,cf.objid cf_objid
           ,cf.x_rate_plan
           ,1 priority
       FROM
            table_x_parent pa2,
            table_x_carrier_group cg2,
            table_x_carrier c2,
            table_x_carrier_features cf
      WHERE 1=1
        and pa2.x_parent_name            = c_parent_name
        AND cg2.X_CARRIER_GROUP2X_PARENT = pa2.objid
        AND c2.carrier2carrier_group     = cg2.objid
        AND cf.X_FEATURE2X_CARRIER       = c2.objid
        AND cf.x_technology              = c_tech
        AND cf.X_FEATURES2BUS_ORG        = c_bus_org_objid
        AND cf.x_data                    = c_data_speed
     union
    SELECT  3 col1
           ,cf.objid cf_objid
           ,cf.x_rate_plan
           ,1 priority
       FROM
            table_x_parent pa2,
            table_x_carrier_group cg2,
            table_x_carrier c2,
            table_x_carrier_features cf
      WHERE 1=1
        and pa2.x_parent_name            = c_alt_parent_name
        AND cg2.X_CARRIER_GROUP2X_PARENT = pa2.objid
        AND c2.carrier2carrier_group     = cg2.objid
        AND cf.X_FEATURE2X_CARRIER       = c2.objid
        AND cf.x_technology              = c_tech
        AND cf.X_FEATURES2BUS_ORG        = c_bus_org_objid
        AND cf.x_data                    = c_data_speed
     order by col1 asc;
  carrier_features_rec1 carrier_features_curs1%rowtype;
--
  l_service_plan_id number;
  l_parent_name1 varchar2(100);
  l_parent_name2 varchar2(100);
  v_cnt number; --CR47881
begin
  if p_carrier_objid is null then
    if p_task_objid is not null then
      INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
      VALUES ( 'p_carrier_objid is null', sysdate, 'p_carrier_objid is null',p_task_objid,'igate.sf_get_carr_feat');
    end if;
    dbms_output.put_line('p_carrier_objid is null');
    return null;
  elsif p_site_part_objid is null then
    if p_task_objid is not null then
      INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
      VALUES ( 'p_site_part_objid is null', sysdate, 'p_site_part_objid is null',p_task_objid,'igate.sf_get_carr_feat');
    end if;
    dbms_output.put_line('p_site_part_objid is null and p_esn is null');
    return null;
  end if;
--
  open device_curs;
    fetch device_curs into device_rec;
    if device_curs%notfound or device_rec.org_id = 'GENERIC' then
      open device_curs2(p_esn);
        fetch device_curs2 into device_rec;
        if device_curs2%notfound then
          close device_curs2;
          close device_curs;
          dbms_output.put_line('non generic device_curs%notfound');
          if p_task_objid is not null then
            INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
            VALUES ( 'device_curs%notfound and device_curs2%notfound', sysdate, 'p_site_part_objid:'||p_site_part_objid||'and p_esn:'||p_esn||' do not return a part_number',p_task_objid,'igate.sf_get_carr_feat');
          end if;
          return null;
        elsif device_rec.org_id = 'GENERIC' then
          close device_curs2;
          close device_curs;
          dbms_output.put_line('generic device_curs%found');
          if p_task_objid is not null then
            INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
            VALUES ( 'generic device_curs2%notfound', sysdate, 'device_curs2('||p_esn||')',p_task_objid,'igate.sf_get_carr_feat');
          end if;
          return null;
        end if;
      close device_curs2;
    end if;
  close device_curs;
--
  if device_rec.org_id = 'TRACFONE' and device_rec.device_type = 'FEATURE_PHONE' then
    --CR42459 Check for Service plans
    open service_plan_curs(p_site_part_objid);
      fetch service_plan_curs into service_plan_rec;
      IF service_plan_curs%FOUND THEN
        BEGIN
          select 1 INTO v_cnt --CR47881 Check the brand START
          from ADFCRM_SERV_PLAN_FEAT_MATVIEW
          where SP_OBJID =service_plan_rec.x_service_plan_id
          and FEA_NAME ='BIZ LINE'
          and FEA_VALUE ='TF';
        EXCEPTION
          WHEN OTHERS THEN v_cnt :=0;
        END;
        IF v_cnt =1 THEN
          l_service_plan_id := service_plan_rec.x_service_plan_id;
        ELSE
          l_service_plan_id := -1;
        END IF;  --CR47881 Check the brand START
      ELSE l_service_plan_id := -1;
      END IF;
    close service_plan_curs;
   --CR42459 End Check for Service plans
  elsif p_service_plan_id is not null then
    l_service_plan_id := p_service_plan_id;
  elsif device_rec.org_id = 'TRACFONE' and device_rec.device_type != 'FEATURE_PHONE' then
    open service_plan_curs(p_site_part_objid);
      fetch service_plan_curs into service_plan_rec;
      if service_plan_curs%found then
        l_service_plan_id := service_plan_rec.x_service_plan_id;
      else
        l_service_plan_id := -2;
      end if;
    close service_plan_curs;
  elsif device_rec.org_id = 'NET10' and device_rec.device_type = 'FEATURE_PHONE' then
    open service_plan_curs(p_site_part_objid);
      fetch service_plan_curs into service_plan_rec;
      if service_plan_curs%found then
        l_service_plan_id := service_plan_rec.x_service_plan_id;
      else
        l_service_plan_id := -3;
      end if;
    close service_plan_curs;
  elsif device_rec.org_id not in ('GENERIC') then
    open service_plan_curs(p_site_part_objid);
      fetch service_plan_curs into service_plan_rec;
      if service_plan_curs%found then
        l_service_plan_id := service_plan_rec.x_service_plan_id;
      end if;
    close service_plan_curs;
  end if;
--
  if l_service_plan_id is null and device_rec.org_id = 'TOTAL_WIRELESS' then
    open tw_service_plan_curs(device_rec.esn);
      fetch tw_service_plan_curs into tw_service_plan_rec;
      if tw_service_plan_curs%found then
        l_service_plan_id := tw_service_plan_rec.service_plan_id;
        if p_task_objid is not null then
          --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
          --VALUES
		dbms_output.put_line( 'WARNING service_plan_site_part%notfound using substitute'|| sysdate|| 'tw_service_plan_curs('||device_rec.esn||')'||
                   p_task_objid||'igate.sf_get_carr_feat');
        end if;
        dbms_output.put_line('total_wireless:'||l_service_plan_id);
      end if;
    close tw_service_plan_curs;
  end if;
--
  if l_service_plan_id is null then
    open case_curs(device_rec.esn);
      fetch case_curs into case_rec;
      if case_curs%found and case_rec.new_service_plan_id is not null then
        l_service_plan_id := case_rec.new_service_plan_id;
        if p_task_objid is not null then
          --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
          --VALUES
		 dbms_output.put_line( 'WARNING service_plan_site_part%notfound using substitute'|| sysdate||'case_curs('||device_rec.esn||')'||
                   p_task_objid||'igate.sf_get_carr_feat');
        end if;
      end if;
    close case_curs;
  end if;
--
  if l_service_plan_id is null then
    open card_service_plan_curs(device_rec.esn,device_rec.org_id);
      fetch card_service_plan_curs into card_service_plan_rec;
      if card_service_plan_curs%found then
        l_service_plan_id := card_service_plan_rec.x_service_plan_id;
        if p_task_objid is not null then
          --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
         -- VALUES
		  dbms_output.put_line( 'WARNING service_plan_site_part%notfound using substitute'|| sysdate|| 'card_service_plan_curs('||device_rec.esn||')'||
                   p_task_objid||'igate.sf_get_carr_feat');
        end if;
      end if;
    close card_service_plan_curs;
  end if;
--CR31242
  IF device_rec.org_id = 'TOTAL_WIRELESS' THEN
    open family_text2data_test_curs(device_rec.esn);
      fetch family_text2data_test_curs into family_text2data_test_rec;
      if family_text2data_test_curs%found then
	      l_service_plan_id := family_text2data_test_rec.service_plan;
      end if;
    close family_text2data_test_curs;
  END IF;
--CR31242
  open multi_rate_plan_curs(device_rec.esn,
                            l_service_plan_id);
    fetch multi_rate_plan_curs into multi_rate_plan_rec;
    if multi_rate_plan_curs%notfound then
      multi_rate_plan_rec.x_priority := 1;
    end if;
  close multi_rate_plan_curs;
--
  open service_plan_mkt_curs(l_service_plan_id);
    fetch service_plan_mkt_curs into service_plan_mkt_rec;
    if service_plan_mkt_curs%found then
      service_plan_mkt_rec.plan_type := 'SAFELINK';
    else
      service_plan_mkt_rec.plan_type := 'NOT SAFELINK';
    end if;
  close service_plan_mkt_curs;
--
  open parent_curs(p_carrier_objid,device_rec.x_technology,device_rec.org_id,service_plan_mkt_rec.plan_type);
    fetch parent_curs into parent_rec;
    if parent_curs%notfound then
      close parent_curs;
      dbms_output.put_line('parent_curs%notfound:'|| p_carrier_objid||':'||device_rec.x_technology||':'||device_rec.org_id||':'||l_service_plan_id);
      return null;
    end if;
  close parent_curs;
--/*
  dbms_output.put_line('parent_rec.x_parent_name:'||parent_rec.x_parent_name);
  dbms_output.put_line('device_rec.x_technology:'||device_rec.x_technology);
  dbms_output.put_line('device_rec.data_speed:'||device_rec.data_speed);
  dbms_output.put_line('device_rec.org_id:'||device_rec.org_id);
  dbms_output.put_line('device_rec.device_type:'||device_rec.device_type);
--*/
--CR 44291
  if device_rec.org_id != 'NET10' --or (device_rec.org_id = 'NET10' and p_carrier_objid = 268467960) CR44801 Budget rate plan change
  then
    open mkt_rate_plan_curs( l_service_plan_id,
                             device_rec.data_speed,
                             multi_rate_plan_rec.x_priority,
                             p_carrier_objid);
      fetch mkt_rate_plan_curs into rate_plan_rec;
      if mkt_rate_plan_curs%found then
        close mkt_rate_plan_curs;
        return rate_plan_rec.cf_objid;
      end if;
    close mkt_rate_plan_curs;
  end if;
  if device_rec.org_id = 'NET10' then
    l_parent_name1 := parent_rec.x_parent_name;
    l_parent_name1 := parent_rec.nt_parent_name;
  elsif device_rec.org_id = 'TOTAL_WIRELESS' then
    l_parent_name1 := parent_rec.x_parent_name;
    l_parent_name1 := parent_rec.tw_parent_name;
  elsif device_rec.org_id = 'SIMPLE_MOBLE' then
    l_parent_name1 := parent_rec.x_parent_name;
    l_parent_name1 := parent_rec.sm_parent_name;
  elsif device_rec.org_id = 'STRAIGHT_TALK' then
    l_parent_name1 := parent_rec.x_parent_name;
    l_parent_name1 := parent_rec.st_parent_name;
  elsif device_rec.org_id = 'TRACFONE' then --CR44221
    l_parent_name1 := parent_rec.x_parent_name;
    l_parent_name1 := parent_rec.tf_parent_name;
  else
    l_parent_name1 := parent_rec.x_parent_name;
    l_parent_name1 := parent_rec.alt_parent_name;
  end if;
  <<retestserviceplan>>
  open rate_plan_curs( l_service_plan_id,
                       device_rec.data_speed,
                       multi_rate_plan_rec.x_priority,
                       l_parent_name1);
    fetch rate_plan_curs into rate_plan_rec;
    if rate_plan_curs%found then
      if p_task_objid is not null and device_rec.org_id != 'NET10' then
       -- INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
       -- VALUES
		dbms_output.put_line( 'WARNING rate_plan found using parent'|| sysdate||'rate_plan_curs( '||l_service_plan_id||','|| device_rec.data_speed||','||
                  multi_rate_plan_rec.x_priority||','|| l_parent_name1||')'|| p_task_objid||'igate.sf_get_carr_feat');
      end if;
      close rate_plan_curs;
      return rate_plan_rec.cf_objid;
    end if;
  close rate_plan_curs;
  open rate_plan_curs2( l_service_plan_id,
                        device_rec.data_speed,
                        multi_rate_plan_rec.x_priority,
                        l_parent_name1);
    fetch rate_plan_curs2 into rate_plan_rec;
    if rate_plan_curs2%found then
      if p_task_objid is not null and device_rec.org_id != 'NET10' then
        --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
       -- VALUES
		dbms_output.put_line( 'WARNING rate_plan found using parent(no priority=1)'|| sysdate|| 'rate_plan_curs2( '||l_service_plan_id||','|| device_rec.data_speed||','||
                multi_rate_plan_rec.x_priority||','|| l_parent_name1||')'|| p_task_objid||'igate.sf_get_carr_feat');
      end if;
      close rate_plan_curs2;
      return rate_plan_rec.cf_objid;
    end if;
  close rate_plan_curs2;
  if l_parent_name1 != l_parent_name2 then
    open rate_plan_curs( l_service_plan_id,
                         device_rec.data_speed,
                         multi_rate_plan_rec.x_priority,
                         l_parent_name2);
      fetch rate_plan_curs into rate_plan_rec;
      if rate_plan_curs%found then
        if p_task_objid is not null then
          --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
         -- VALUES
		  dbms_output.put_line( 'WARNING rate_plan found using substitute parent'|| sysdate|| 'rate_plan_curs( '||l_service_plan_id||','|| device_rec.data_speed||','||
                  multi_rate_plan_rec.x_priority||','|| l_parent_name2||')'|| p_task_objid||'igate.sf_get_carr_feat');
        end if;
        close rate_plan_curs;
        return rate_plan_rec.cf_objid;
      end if;
    close rate_plan_curs;
    open rate_plan_curs2( l_service_plan_id,
                          device_rec.data_speed,
                          multi_rate_plan_rec.x_priority,
                          l_parent_name2);
      fetch rate_plan_curs2 into rate_plan_rec;
      if rate_plan_curs2%found then
        if p_task_objid is not null and device_rec.org_id != 'NET10' then
          --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
          --VALUES
		  dbms_output.put_line( 'WARNING rate_plan found using substitute parent(no priority=1)'|| sysdate|| 'rate_plan_curs2( '||l_service_plan_id||','|| device_rec.data_speed||','||
                  multi_rate_plan_rec.x_priority||','|| l_parent_name1||')'|| p_task_objid||'igate.sf_get_carr_feat');
        end if;
        close rate_plan_curs2;
        return rate_plan_rec.cf_objid;
      end if;
    close rate_plan_curs2;
  end if;
  if device_rec.org_id = 'TRACFONE' and device_rec.device_type != 'FEATURE_PHONE' and l_service_plan_id != -2 then
    l_service_plan_id := -2;
    goto retestserviceplan;
  elsif device_rec.org_id = 'NET10' and device_rec.device_type = 'FEATURE_PHONE' and l_service_plan_id != -3 then
    l_service_plan_id := -3;
    goto retestserviceplan;
  end if;
  if rate_plan_rec.cf_objid is null and parent_rec.x_parent_name like '%SPRINT%' then
   dbms_output.put_line('SPRINT:'||device_rec.device_type);
    open sprint_curs(device_rec.device_type);
      fetch sprint_curs into rate_plan_rec;
      if sprint_curs%found then
        if p_task_objid is not null then
          --INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
          --VALUES
		  dbms_output.put_line( 'WARNING using default SPRINT rate_plan'|| sysdate||'sprint_curs('|| device_rec.device_type||')'|| p_task_objid||'igate.sf_get_carr_feat');
        end if;
        close sprint_curs;
        return rate_plan_rec.cf_objid;
      end if;
    close sprint_curs;
  end if;
--
  if rate_plan_rec.cf_objid is null then
    open carrier_features_curs1 ( p_carrier_objid ,device_rec.x_technology ,device_rec.bo_objid ,device_rec.data_speed,l_parent_name1,l_parent_name2);
      fetch carrier_features_curs1 into carrier_features_rec1;
      if carrier_features_curs1%found then
        if p_task_objid is not null then
         -- INSERT INTO error_table ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
          --VALUES
		  dbms_output.put_line( 'WARNING using default rate_plan'|| sysdate||
                   'carrier_features_curs1 ('|| p_carrier_objid ||','||device_rec.x_technology||','||device_rec.bo_objid||','||
                   device_rec.data_speed||','||l_parent_name1||','||l_parent_name2||')'|| p_task_objid||'igate.sf_get_carr_feat');
        end if;
        close carrier_features_curs1;
        return carrier_features_rec1.cf_objid;
      end if;
    close carrier_features_curs1;
  end if;
--

  dbms_output.put_line( device_rec.org_id||':'||l_service_plan_id||':'|| device_rec.data_speed||':'|| multi_rate_plan_rec.x_priority||':'|| l_parent_name1||':'||
                      device_rec.device_type
--		||':'||p_action_item_id
                    );

  if p_carr_feature_objid is not null then
    open input_cf_curs;
      fetch input_cf_curs into input_cf_rec;
      if input_cf_curs%found then
        close input_cf_curs;
        return p_carr_feature_objid;
      else
        close input_cf_curs;
        return null;
      end if;
    close input_cf_curs;
  else
    return null;
  end if;
END sf_get_carr_feat;
----------------------------------------------------------------------------------------------------
FUNCTION get_ig_transaction(
    in_action_item_id IN ig_transaction.action_item_id%TYPE,
    in_task_objid     IN ig_transaction.action_item_id%TYPE)
  RETURN ig_transaction%ROWTYPE
IS
  --
  CURSOR ig_trans_cur
  IS
    SELECT ig.*
    FROM ig_transaction ig
    WHERE ig.action_item_id = in_action_item_id;
  --
  CURSOR ig_trans_from_task_cur
  IS
    SELECT *
    FROM
      (SELECT ig.*
      FROM gw1.ig_transaction ig,
        table_task tt
      WHERE 1               =1
      AND ig.action_item_id = tt.task_id
        ||''
      AND tt.objid = in_task_objid
      ORDER BY creation_date DESC
      )
  WHERE ROWNUM <2;
  --
  ig_trans_rec ig_transaction%ROWTYPE;
  --
BEGIN
  --
  IF (in_action_item_id IS NOT NULL) THEN
    OPEN ig_trans_cur;
    FETCH ig_trans_cur INTO ig_trans_rec;
    CLOSE ig_trans_cur;
  ELSIF (in_task_objid IS NOT NULL) THEN
    OPEN ig_trans_from_task_cur;
    FETCH ig_trans_from_task_cur
    INTO ig_trans_rec;
    CLOSE ig_trans_from_task_cur;
  END IF;
  --
  RETURN ig_trans_rec;
END get_ig_transaction;
-- MVadlapally CR23513 TracFone SurePay for Android -- new Procedure
PROCEDURE sp_insert_ig_trans_buckets(
    in_ig_transaction_id IN ig_transaction.transaction_id%TYPE,
    in_ig_rate_plan      IN ig_transaction.rate_plan%TYPE,
    in_ig_bucket_type    IN ig_buckets.bucket_type%TYPE,
    in_bucket_balance    IN NUMBER,
    out_bucket_created   OUT BOOLEAN,
    in_order_type        IN VARCHAR2 DEFAULT NULL --- Added by Rahul for CR
    )
IS
  --
    insert_flag               VARCHAR2(1) := 'Y';           -- Added by Rahul for CR36735
    active_count              NUMBER;                       -- Added by Rahul for CR36735
    v_bucket_balance          NUMBER;
    v_get_lang                VARCHAR2(100);
    v_benefit_type            VARCHAR2(100);
    v_bucket_expiration_date  DATE;
    v_service_plan_id         sa.x_service_plan.objid%type;
    v_esn                     ig_transaction.esn%type;
    n_benefit_extra_days      NUMBER  := 0;                 --CR52803
    c_safelink_batch_flag     VARCHAR2(10);                 --CR52803
    n_bucket_counter          NUMBER := 0;                  --CR52905
    v_trans_reason            VARCHAR2(50);                 --CR53300

BEGIN

  --CR52905 Check if buckets are to be created for input order type
  IF get_create_buckets_flag(in_order_type => in_order_type) = 'NO'
  THEN
    out_bucket_created := FALSE;
    RETURN;
  END IF;
  --
  IF (in_ig_transaction_id IS NOT NULL) THEN
    --CR53300 Get the trans reason - logic for TFSL REPL/COMP/AWOP
    BEGIN
      SELECT ct.x_reason
        INTO v_trans_reason
      FROM   table_task tt,
             table_x_call_trans ct,
             ig_transaction ig
      WHERE  tt.task_id             = ig.action_item_id
        AND  tt.x_task2x_call_trans = ct.objid
        AND  ig.transaction_id      = in_ig_transaction_id;
    EXCEPTION
    WHEN OTHERS THEN
      v_trans_reason := NULL;
    END;
    --
    FOR rec_ig_bkts IN
    (SELECT bucket_id,
      bucket_type,
      measure_unit,
      bucket_desc
    FROM ig_buckets
    WHERE bucket_type = in_ig_bucket_type
    AND rate_plan     = in_ig_rate_plan
                )
    LOOP
      --
        /*CR30457 TMO Carrier switch changes to check the bucket measuring unit start*/
        IF rec_ig_bkts.BUCKET_TYPE IN ('DATA_UNITS','FREE_DATA_UNITS') and rec_ig_bkts.MEASURE_UNIT='mb'
        THEN v_bucket_balance:=in_bucket_balance;
        ELSIF rec_ig_bkts.BUCKET_TYPE IN ('DATA_UNITS','FREE_DATA_UNITS') and rec_ig_bkts.MEASURE_UNIT='kb' THEN
        v_bucket_balance:= in_bucket_balance*1024;
        ELSE v_bucket_balance:=in_bucket_balance;
        END IF;
        /*CR30457 TMO Carrier switch changes to check the bucket measuring unit end*/

        --CR38927 safelink upgrade changes

        BEGIN
          SELECT sa.get_lang(action_item_id)
          INTO   v_get_lang
          FROM   ig_transaction
          WHERE  transaction_id = in_ig_transaction_id
          AND    ROWNUM =1;
        EXCEPTION
          WHEN OTHERS THEN
            v_get_lang:=NULL;
        END;

        v_benefit_type := v_get_lang;

        --CR5300 Modify logic to not sweep FREE buckets during Comp/Repl
        IF (v_get_lang ='STACK' AND  rec_ig_bkts.bucket_type LIKE 'FREE%') THEN
          IF NOT ((v_trans_reason = 'Compensation') OR (v_trans_reason = 'Replacement' AND v_bucket_balance = 0)) THEN
            v_benefit_type := 'SWEEP_ADD';
          END IF;
        END IF;

        IF (v_get_lang ='SWEEP_ADD' AND  rec_ig_bkts.bucket_type NOT LIKE 'FREE%') THEN
          v_benefit_type := 'STACK';
        END IF;

        -- CR45249 added by vlaad for SUI PFR PayGO plans to succeed
        IF ( in_order_type = 'PFR' AND in_bucket_balance = 0 ) THEN
          v_benefit_type := 'TRANSFER';
        END IF;

        IF (rec_ig_bkts.bucket_type LIKE 'FREE%' AND v_bucket_balance IS NOT NULL )
        THEN

          c_safelink_batch_flag := get_safelink_batch_flag(i_order_type => in_order_type); --CR52803 Enable new order type for safelink batch similar to CR-Credit

          IF (in_order_type ='CR' OR c_safelink_batch_flag ='Y') THEN
          --CR52803 calculate  n_benefit_extra_days
            IF c_safelink_batch_flag ='Y' THEN
             BEGIN
               n_benefit_extra_days  :=  NVL(TO_NUMBER(get_param_value(i_param_name => 'SL_MONTHLY_BENEFIT_EXTRA_DAYS')),0);
             EXCEPTION
             WHEN OTHERS THEN
               n_benefit_extra_days := 0;
             END;
            END IF;
            --CR52803 calculate  n_benefit_extra_days

            BEGIN
              SELECT TRUNC(pe.x_next_delivery_date)  + NVL(n_benefit_extra_days,0) --CR52803 parameter configuration added for extra benefit days
              INTO   v_bucket_expiration_date
              FROM   x_program_enrolled pe,
                     x_program_parameters pr
              WHERE  pe.x_esn IN (SELECT esn from ig_transaction where transaction_id = in_ig_transaction_id)
              AND    pe.pgm_enroll2pgm_parameter = pr.objid
              AND    pr.x_prog_class='LIFELINE'
              AND    pe.x_enrollment_status ='ENROLLED';
            EXCEPTION
            WHEN OTHERS THEN
              v_bucket_expiration_date := LAST_DAY(TRUNC(SYSDATE)) + NVL(n_benefit_extra_days,0) ;
            END;
          ELSE
            v_bucket_expiration_date := LAST_DAY(TRUNC(SYSDATE));
          END IF;

        END IF;

        IF (rec_ig_bkts.bucket_type NOT LIKE 'FREE%') THEN
          v_bucket_expiration_date := NULL;
        END IF;
        --CR38927 safelink upgrade changes
        /*IF v_get_lang IS NULL THEN
          IF rec_ig_bkts.bucket_type like 'FREE%' THEN
             v_benefit_type := 'SWEEP_ADD';
          ELSE
             v_benefit_type := 'STACK';
          END IF;
          END IF;*/

        --IF NVL(get_ig_trans_buckets_ins_flag(in_ig_rate_plan,in_order_type,rec_ig_bkts.bucket_id),'N') = 'Y'  -- Added by Rahul for CR36735
        IF get_ig_buckets_active_flag(in_rate_plan => in_ig_rate_plan, in_bucket_id => rec_ig_bkts.bucket_id) = 'Y' --CR52905
        THEN
          BEGIN
            INSERT
            INTO ig_transaction_buckets
            (
              transaction_id,
              bucket_id,
              recharge_date,
              bucket_balance,
              bucket_value,
              expiration_date,
              direction,
              benefit_type,
              bucket_type
            )
            VALUES
            ( in_ig_transaction_id,
              rec_ig_bkts.bucket_id,
              SYSDATE,
              v_bucket_balance,
              v_bucket_balance,
              v_bucket_expiration_date,
              /*CASE WHEN rec_ig_bkts.bucket_type LIKE 'FREE%'
              THEN last_day(trunc(sysdate))
              ELSE
              NULL --TO_DATE('2050/12/31', 'yyyy/mm/dd') ,
              END,*/
              'OUTBOUND',
              v_benefit_type,
              rec_ig_bkts.bucket_type
            );
          EXCEPTION
            WHEN dup_val_on_index THEN
            NULL;
          END;

          n_bucket_counter := n_bucket_counter + SQL%ROWCOUNT; --CR52905

        END IF;
        --out_bucket_created := (sql%rowcount <> 0); --
      --
    END LOOP ;

    out_bucket_created := CASE WHEN n_bucket_counter > 0 THEN TRUE ELSE FALSE END; --CR52905
    --
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
  ota_util_pkg.err_log(p_action => 'Insert into ig_transaction_buckets failed.', p_error_date => SYSDATE, p_key => in_ig_transaction_id, p_program_name => 'igate.sp_insert_ig_trans_buckets', p_error_text => sqlerrm);
END sp_insert_ig_trans_buckets;
----------------------------------------------------------------------------------------------------
PROCEDURE set_action_item_ig_trans
  (
    in_contact_objid      IN NUMBER,
    in_call_trans_objid   IN NUMBER,
    in_order_type         IN VARCHAR2,
    in_bypass_order_type  IN NUMBER,
    in_case_code          IN NUMBER,
    in_trans_method       IN VARCHAR2,
    in_application_system IN VARCHAR2 DEFAULT 'IG',
    in_service_days       IN ig_transaction_buckets.bucket_balance%TYPE,
    in_voice_units        IN ig_transaction_buckets.bucket_balance%TYPE,
    in_text_units         IN ig_transaction_buckets.bucket_balance%TYPE,
    in_data_units         IN ig_transaction_buckets.bucket_balance%TYPE,
    out_ai_status_code OUT NUMBER,
    out_destination_queue OUT NUMBER,
    out_ig_tran_status OUT NUMBER,
    out_action_item_objid OUT NUMBER,
    out_action_item_id OUT ig_transaction.action_item_id%TYPE,
    out_errorcode OUT VARCHAR2,
    out_errormsg OUT VARCHAR2
  )
IS
  --
  v_location VARCHAR2(1000);
  ig_trans_rec ig_transaction%ROWTYPE;
  --
BEGIN
  --
  v_location := 'Executing sp_create_action_item from igate.set_action_item_ig_trans';
  sp_create_action_item(p_contact_objid => in_contact_objid, p_call_trans_objid => in_call_trans_objid, p_order_type => in_order_type, p_bypass_order_type => in_bypass_order_type, p_case_code => in_case_code, p_status_code => out_ai_status_code, p_action_item_objid => out_action_item_objid);
  --
  IF (out_action_item_objid IS NOT NULL) THEN
    -- creates IG Trans record too
    v_location := 'Executing sp_determine_trans_method from igate.set_action_item_ig_trans';
    sp_determine_trans_method(p_action_item_objid => out_action_item_objid, p_order_type => in_order_type, p_trans_method => in_trans_method,
    p_destination_queue => out_destination_queue, p_application_system => in_application_system, in_service_days => in_service_days,
    in_voice_units => in_voice_units, in_text_units => in_text_units, in_data_units => in_data_units);

    --
    ig_trans_rec       := get_ig_transaction(NULL, out_action_item_objid);
    out_action_item_id := ig_trans_rec.action_item_id;
    --
    out_errorcode := '0';
    out_errormsg  := 'Success';
    --
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
  out_errorcode := SQLCODE;
  out_errormsg  := SQLERRM;
  ota_util_pkg.err_log(p_action => v_location, p_error_date => SYSDATE, p_key => in_call_trans_objid, p_program_name => 'igate.set_action_item_ig_trans', p_error_text => sqlerrm);
END set_action_item_ig_trans;
-- Wrapper procedure
PROCEDURE sp_set_action_item_ig_trans
  (
    in_contact_objid      IN NUMBER,
    in_call_trans_objid   IN NUMBER,
    in_order_type         IN VARCHAR2,
    in_bypass_order_type  IN NUMBER,
    in_case_code          IN NUMBER,
    in_trans_method       IN VARCHAR2,
    in_application_system IN VARCHAR2 DEFAULT 'IG',
    in_service_days       IN ig_transaction_buckets.bucket_balance%TYPE,
    in_voice_units        IN ig_transaction_buckets.bucket_balance%TYPE,
    in_text_units         IN ig_transaction_buckets.bucket_balance%TYPE,
    in_data_units         IN ig_transaction_buckets.bucket_balance%TYPE,
    out_ai_status_code OUT NUMBER,
    out_destination_queue OUT NUMBER,
    out_ig_tran_status OUT NUMBER,
    out_action_item_objid OUT NUMBER,
    out_action_item_id OUT ig_transaction.action_item_id%TYPE,
    out_errorcode OUT VARCHAR2,
    out_errormsg OUT VARCHAR2
  )
IS
BEGIN
  set_action_item_ig_trans(in_contact_objid => in_contact_objid, in_call_trans_objid => in_call_trans_objid, in_order_type => in_order_type, in_bypass_order_type => in_bypass_order_type, in_case_code => in_case_code, in_trans_method => in_trans_method,
    in_application_system => in_application_system,in_service_days => in_service_days, in_voice_units => in_voice_units,
    in_text_units => in_text_units, in_data_units => in_data_units, out_ai_status_code => out_ai_status_code,
    out_destination_queue => out_destination_queue, out_ig_tran_status => out_ig_tran_status,
    out_action_item_objid => out_action_item_objid, out_action_item_id => out_action_item_id, out_errorcode => out_errorcode,
    out_errormsg => out_errormsg);

END sp_set_action_item_ig_trans;
--  CR47564 changes starts..
--  Overloaded wrapper procedure which accepts discount code list additionally
PROCEDURE sp_set_action_item_ig_trans
  (
    in_contact_objid      IN NUMBER,
    in_call_trans_objid   IN NUMBER,
    in_order_type         IN VARCHAR2,
    in_bypass_order_type  IN NUMBER,
    in_case_code          IN NUMBER,
    in_trans_method       IN VARCHAR2,
    in_application_system IN VARCHAR2 DEFAULT 'IG',
    in_service_days       IN ig_transaction_buckets.bucket_balance%TYPE,
    in_voice_units        IN ig_transaction_buckets.bucket_balance%TYPE,
    in_text_units         IN ig_transaction_buckets.bucket_balance%TYPE,
    in_data_units         IN ig_transaction_buckets.bucket_balance%TYPE,
    in_discount_code_list IN  discount_code_tab,
    out_ai_status_code    OUT NUMBER,
    out_destination_queue OUT NUMBER,
    out_ig_tran_status    OUT NUMBER,
    out_action_item_objid OUT NUMBER,
    out_action_item_id    OUT ig_transaction.action_item_id%TYPE,
    out_errorcode         OUT VARCHAR2,
    out_errormsg          OUT VARCHAR2
  )
IS
BEGIN
--
  IF in_discount_code_list  IS NOT NULL
  THEN
    IF in_discount_code_list.COUNT > 0
    THEN
      BEGIN
        MERGE INTO sa.table_x_call_trans_ext ctext
        USING (SELECT NULL                                 objid ,                        --objid
                      in_call_trans_objid                  call_trans_ext2call_trans ,    --call_trans_ext2call_trans
                      in_service_days                      x_total_days ,                 --x_total_days
                      in_text_units                        x_total_sms_units ,            --x_total_sms_units
                      in_data_units                        x_total_data_units ,           --x_total_data_units
                      SYSDATE                              insert_date ,                  --insert_date
                      SYSDATE                              update_date ,                  --update_date
                      NULL                                 account_group_id ,             --account_group_id
                      NULL                                 master_flag ,                  --master_flag
                      NULL                                 service_plan_id ,              --service_plan_id
                      NULL                                 TRANSACTION_COS ,              --TRANSACTION_COS
                      NULL                                 ild_bucket_sent_flag ,         --ild_bucket_sent_flag
                      NULL                                 intl_bucket_sent_flag ,        --intl_bucket_sent_flag
                      NULL                                 smp,                           --smp
                      NULL                                 bucket_id_list ,               --bucket_id_list
                      in_discount_code_list                discount_code_list             --discount_code_list
               FROM DUAL
              ) ctext1
        ON (ctext.call_trans_ext2call_trans = ctext1.call_trans_ext2call_trans)
        WHEN MATCHED THEN
          UPDATE SET x_total_days = ctext1.x_total_days,
                     x_total_sms_units  = ctext1.x_total_sms_units,
                     x_total_data_units = ctext1.x_total_data_units,
                     insert_date        = SYSDATE,
                     update_date        = SYSDATE,
                     discount_code_list = ctext1.discount_code_list
        WHEN NOT MATCHED
          THEN INSERT ( objid,
                        call_trans_ext2call_trans,
                        x_total_days,
                        x_total_sms_units,
                        x_total_data_units,
                        insert_date,
                        update_date,
                        account_group_id,
                        master_flag,
                        service_plan_id,
                        TRANSACTION_COS,
                        ild_bucket_sent_flag,
                        intl_bucket_sent_flag,
                        smp,
                        bucket_id_list,
                        discount_code_list
                      )
               VALUES ( sequ_table_x_call_trans_ext.NEXTVAL,
                        ctext1.call_trans_ext2call_trans,
                        ctext1.x_total_days,
                        ctext1.x_total_sms_units,
                        ctext1.x_total_data_units,
                        SYSDATE,
                        SYSDATE,
                        ctext1.account_group_id,
                        ctext1.master_flag,
                        ctext1.service_plan_id,
                        ctext1.TRANSACTION_COS,
                        ctext1.ild_bucket_sent_flag,
                        ctext1.intl_bucket_sent_flag,
                        ctext1.smp,
                        ctext1.bucket_id_list,
                        ctext1.discount_code_list
                      );
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
  END IF;
  --
  set_action_item_ig_trans( in_contact_objid        => in_contact_objid,
                            in_call_trans_objid     => in_call_trans_objid,
                            in_order_type           => in_order_type,
                            in_bypass_order_type    => in_bypass_order_type,
                            in_case_code            => in_case_code,
                            in_trans_method         => in_trans_method,
                            in_application_system   => in_application_system,
                            in_service_days         => in_service_days,
                            in_voice_units          => in_voice_units,
                            in_text_units           => in_text_units,
                            in_data_units           => in_data_units,
                            out_ai_status_code      => out_ai_status_code,
                            out_destination_queue   => out_destination_queue,
                            out_ig_tran_status      => out_ig_tran_status,
                            out_action_item_objid   => out_action_item_objid,
                            out_action_item_id      => out_action_item_id,
                            out_errorcode           => out_errorcode,
                            out_errormsg            => out_errormsg);
  --
--
END sp_set_action_item_ig_trans;
--  CR47564 changes ends.
PROCEDURE setup_ig_transaction
  (
    in_contact_objid      IN NUMBER,
    in_call_trans_objid   IN NUMBER,
    in_order_type         IN VARCHAR2,
    in_bypass_order_type  IN NUMBER,
    in_case_code          IN NUMBER,
    in_trans_method       IN VARCHAR2,
    in_application_system IN VARCHAR2 DEFAULT 'IG',
    in_service_days       IN ig_transaction_buckets.bucket_balance%TYPE,
    in_voice_units        IN ig_transaction_buckets.bucket_balance%TYPE,
    in_text_units         IN ig_transaction_buckets.bucket_balance%TYPE,
    in_data_units         IN ig_transaction_buckets.bucket_balance%TYPE,
    in_free_service_days  IN ig_transaction_buckets.bucket_balance%TYPE,
    in_free_voice_units   IN ig_transaction_buckets.bucket_balance%TYPE,
    in_free_text_units    IN ig_transaction_buckets.bucket_balance%TYPE,
    in_free_data_units    IN ig_transaction_buckets.bucket_balance%TYPE,
    out_ai_status_code OUT NUMBER,
    out_destination_queue OUT NUMBER,
    out_ig_tran_status OUT NUMBER,
    out_action_item_objid OUT NUMBER,
    out_action_item_id OUT ig_transaction.action_item_id%TYPE,
    out_errorcode OUT VARCHAR2,
    out_errormsg OUT VARCHAR2
  )
IS
v_location VARCHAR2(1000);
  ig_trans_rec ig_transaction%ROWTYPE;
BEGIN

  v_location := 'Executing setup_ig_transaction';
  sp_create_action_item(p_contact_objid => in_contact_objid, p_call_trans_objid => in_call_trans_objid, p_order_type => in_order_type, p_bypass_order_type => in_bypass_order_type, p_case_code => in_case_code, p_status_code => out_ai_status_code, p_action_item_objid => out_action_item_objid);
  --
  IF (out_action_item_objid IS NOT NULL) THEN
    -- creates IG Trans record too
    v_location := 'Executing sp_determine_trans_method from igate.setup_ig_transaction';

    sp_determine_trans_method(p_action_item_objid     => out_action_item_objid,
                              p_order_type            => in_order_type,
                              p_trans_method          => in_trans_method,
                              p_destination_queue     => out_destination_queue,
                              p_application_system    => in_application_system,
                              in_service_days         => in_service_days,
                              in_voice_units          => in_voice_units,
                              in_text_units           => in_text_units,
                              in_data_units           => in_data_units,
                              in_free_service_days    => in_free_service_days,
                              in_free_voice_units     => in_free_voice_units,
                              in_free_text_units      => in_free_text_units,
                              in_free_data_units      => in_free_data_units
                              );

    --
    ig_trans_rec       := get_ig_transaction(NULL, out_action_item_objid);
    out_action_item_id := ig_trans_rec.action_item_id;
    --
    out_errorcode := '0';
    out_errormsg  := 'Success';
    --
  END IF;
EXCEPTION
WHEN OTHERS THEN
 out_errorcode := SQLCODE;
  out_errormsg  := SQLERRM;
  ota_util_pkg.err_log(p_action => v_location, p_error_date => SYSDATE, p_key => in_call_trans_objid, p_program_name => 'igate.setup_ig_transaction', p_error_text => sqlerrm);
END setup_ig_transaction;
-------------------------------------------------------------------------------------------------------------
-- Function added to get the ig transaction features from profile configuration (for CR45249)
FUNCTION get_ig_transaction_features ( i_transaction_id         IN NUMBER ,
                                       i_carrier_features_objid IN NUMBER ) RETURN ig_transaction_features_tab DETERMINISTIC IS
  ig   ig_transaction_type;
  i    ig_transaction_type := ig_transaction_type ();
  igf  ig_transaction_features_tab := ig_transaction_features_tab();
  c    customer_type               := customer_type ();
  --
  c_throttle_status_code      VARCHAR2(2);
  n_policy_id                 NUMBER;
  c_line_status_code          VARCHAR2(2);
  c_data_suspended_flag       VARCHAR2(1);
  c_data_saver                gw1.ig_transaction.data_saver%TYPE;
  c_data_saver_code           gw1.ig_transaction.data_saver_code%TYPE;
  n_carrier_feature_objid     NUMBER;
  c_ancillary_status_code     sa.X_RP_ANCILLARY_CODE.ancillary_code%TYPE;
  c_discount_list             VARCHAR2(4000);
  c_call_trans_action_type    table_x_call_trans.x_action_type%TYPE;  -- CR49893
  l_discount_code_list        sa.discount_code_tab := sa.discount_code_tab() ; -- CR48480
  l_error_code                VARCHAR2(1000); -- CR48480
  l_error_msg                 VARCHAR2(1000); -- CR48480
  l_promo_objid               table_x_promotion.objid%TYPE; -- CR48480
  n_rp_ext_objid              NUMBER; --CR48260
  n_rp_profile_id             NUMBER; --CR48260
  c_use_cf_extension_flag     table_x_carrier_features.use_cf_extension_flag%TYPE; --CR48260
BEGIN

  -- ig transaction id is a mandatory attribute
  IF i_transaction_id IS NULL
  THEN
    RETURN igf;
  END IF;

  -- call constructor to get the ig transaction attributes
  ig := ig_transaction_type ( i_transaction_id => i_transaction_id );

  -- make sure the ig transaction is created before moving forward
  IF ig.transaction_id IS NULL THEN
    RETURN NULL;
  END IF;

  -- esn must be present to derive the throttle status and/or line status
  IF ig.esn IS NULL THEN
    RETURN NULL;
  END IF;
  --

  -- set the carrier feature objid from ig (when not passed)
  IF i_carrier_features_objid IS NULL THEN
    n_carrier_feature_objid := ig.carrier_feature_objid;
  END IF;
  --
  --CR48260 changes starts..
  -- validation to check cf extension flag
  BEGIN
      SELECT  NVL(cf.use_cf_extension_flag,'N')
      INTO    c_use_cf_extension_flag
      FROM    table_x_carrier_features cf
      WHERE   cf.objid = NVL(i_carrier_features_objid,n_carrier_feature_objid);
  EXCEPTION
    WHEN OTHERS THEN
      c_use_cf_extension_flag :=  'N';
  END;
  --
  IF c_use_cf_extension_flag  = 'N'
  THEN
    RETURN NULL;
  END IF;
  --CR48260 changes ends.
  -- CR49490 changes starts..
  -- If the profile id is updated in ig_transaction, get the features from x_cf_extension_config table
  IF ig.cf_profile_id IS NOT NULL
  THEN
    --
    BEGIN
      SELECT  ce.throttle_status_code
      INTO    c_throttle_status_code
      FROM    sa.x_rp_extension_link cel,
              sa.x_rp_extension ce
      WHERE   cel.rp_extension_objid    = ce.objid
      AND     cel.carrier_feature_objid = ig.carrier_feature_objid
      AND     cel.profile_id            = ig.cf_profile_id;
     EXCEPTION
      WHEN OTHERS THEN
        -- if the above select query fails for any reason, we will proceed with NULL value
        c_throttle_status_code := NULL;
    END;

    -- get the features directly from the profile used to create the ig in the first place
    --CR48260 changes end
    /*SELECT ig_transaction_features_type ( NULL, -- carrier_features_objid
                                          i_transaction_id        ,
                                          cc.feature_name         ,
                                          cc.feature_value        ,
                                          cc.feature_requirement  , -- feature_requirement (ADD, REM, OPT)
                                          c_throttle_status_code  , --
                                          cc.toggle_flag          , --
                                          cc.display_sui_flag     ,
                                          cc.restrict_sui_flag    ,
                                          cc.profile_id           )
    BULK COLLECT
    INTO   igf
    FROM   x_rp_extension_config cc
    WHERE  1 = 1
    AND    cc.profile_id  = ig.cf_profile_id
    AND    cc.toggle_flag = 'Y';*/

    SELECT ig_transaction_features_type ( NULL, -- carrier_features_objid
                                          i_transaction_id        ,--i_transaction_id
                                          feature_name         ,
                                          feature_value        ,
                                          feature_requirement  , -- feature_requirement (ADD, REM, OPT)
                                          c_throttle_status_code  , --c_throttle_status_code
                                          toggle_flag          , --
                                          display_sui_flag     ,
                                          restrict_sui_flag    ,
                                          profile_id           )
    BULK COLLECT
    INTO igf
    FROM (SELECT  NULL, -- carrier_features_objid
                  NULL        ,
                  cc.feature_name         ,
                  cc.feature_value        ,
                  cc.feature_requirement  , -- feature_requirement (ADD, REM, OPT)
                  NULL                    , -- throttle status code
                  cc.toggle_flag          , --
                  cc.display_sui_flag     ,
                  cc.restrict_sui_flag    ,
                  cc.profile_id
          FROM   x_rp_extension_config cc
          WHERE  1 = 1
          AND    cc.profile_id  = ig.cf_profile_id
          AND    cc.toggle_flag = 'Y'
          AND    NOT EXISTS ( SELECT 1
                              FROM   x_rp_ancillary_code_config acc
                              WHERE  acc.profile_id       = ig.cf_profile_id
                              AND    acc.extension_objid  = ig.rp_ext_objid
                              AND    acc.feature_value    = cc.feature_value
                              AND    acc.toggle_flag      = 'Y')
          UNION
          SELECT NULL, -- carrier_features_objid
                 NULL        ,
                 cc.feature_name         ,
                 cc.feature_value        ,
                 cc.feature_requirement  , -- feature_requirement (ADD, REM, OPT)
                 NULL                    , -- throttle status code
                 cc.toggle_flag          , --
                 cc.display_sui_flag     ,
                 cc.restrict_sui_flag    ,
                 cc.profile_id
          FROM   x_rp_ancillary_code_config cc
          WHERE  1 = 1
          AND    cc.profile_id      = ig.cf_profile_id
          AND    cc.extension_objid = ig.rp_ext_objid
          AND    cc.toggle_flag     = 'Y');
    --CR48260 changes end

    -- just making sure the table type is not null before asking for igf.count
    IF igf IS NOT NULL THEN
      -- return and exit
      IF igf.COUNT > 0
      THEN
        RETURN(igf);
      END IF;
    END IF;

  END IF;
  -- CR49490 changes ends.

  -- CR47564 changes starts..
  --CR48260 changes start
  BEGIN
    SELECT  LISTAGG (c.discount_code, ',')
                        WITHIN GROUP (ORDER BY c.discount_code)
    INTO    c_discount_list
    FROM    sa.table_x_call_trans_ext b, TABLE(b.discount_code_list) c
    WHERE b.call_trans_ext2call_trans  = ig.call_trans_objid;
  EXCEPTION WHEN OTHERS THEN
    c_discount_list := NULL;
  END;
  -- CR47564 changes ends.
  -- CR48480  Changes Starts..
  BEGIN
    SELECT sa.discount_code_type(c.discount_code)
    BULK COLLECT
    INTO   l_discount_code_list
    FROM   sa.table_x_call_trans_ext b, TABLE(b.discount_code_list) c
    WHERE  b.call_trans_ext2call_trans  = ig.call_trans_objid;
  EXCEPTION
    WHEN OTHERS THEN
      l_discount_code_list  := NULL;
  END;
  --CR48260 changes end
  -- CR48480  Changes Ends.
  -- get the throttled customer flag
  BEGIN
    SELECT policy_id
    INTO   n_policy_id
    FROM   ( SELECT x_policy_id policy_id
             FROM   w3ci.table_x_throttling_cache
             WHERE  x_esn = ig.esn
             AND    x_status IN ('P','A')
             ORDER BY objid DESC
           )
    WHERE  ROWNUM = 1;
   EXCEPTION
    WHEN others THEN
      n_policy_id := NULL;
  END;

  -- if the customer is throttled (or data was suspended)
  IF n_policy_id IS NOT NULL THEN
    -- get the data suspended flag from the policy
    BEGIN
      SELECT NVL(data_suspended_flag,'N')
      INTO   c_data_suspended_flag
      FROM   w3ci.table_x_throttling_policy
      WHERE  objid = n_policy_id;
     EXCEPTION
      WHEN others THEN
        c_data_suspended_flag := 'N';
    END;
    -- if the data was suspended set the flag as data suspended
    IF c_data_suspended_flag = 'Y' THEN
      c_throttle_status_code := 'DS';
    ELSE
      -- set as throttled
      c_throttle_status_code := 'TH';
    END IF;
  ELSE
    -- set as not throttled
    c_throttle_status_code := 'NT';
  END IF;

  -- determine if the esn is active or inactive
  --
  -- CR49893 changes starts..
  BEGIN
    SELECT  x_action_type
    INTO    c_call_trans_action_type
    FROM    table_x_call_trans
    WHERE   objid = ig.call_trans_objid;
  EXCEPTION
    WHEN OTHERS THEN
      c_call_trans_action_type := NULL;
  END;
  -- CR49893 changes ends.
  --
  /* LINE can be Inactive during ACTIVATION / REACTIVATION / REDEMPTION, so
     hardcoding the line status  to ACTIVE to pick the active profile */
  --
  IF c_call_trans_action_type IN ('1','3','6')
  THEN
    c_line_status_code := 'AC';
  ELSE
    BEGIN
      SELECT CASE
               WHEN count_active > 0 THEN 'AC'
               ELSE 'IN'
             END line_status_code
      INTO   c_line_status_code
      FROM   ( SELECT COUNT(1) count_active
               FROM   table_site_part
               WHERE  x_service_id = ig.esn
               AND    part_status = 'Active'
             );
     EXCEPTION
      WHEN others THEN
        c_line_status_code := 'IN';
    END;
  END IF;
  -- logic for data saver: CR45740
  IF c_line_status_code	= 'AC' AND
     (NVL(ig.data_saver,'N') = 'Y' OR ig.order_type = 'ADS')
  THEN
    BEGIN
      SELECT line_status_code
      INTO   c_line_status_code
      FROM   sa.x_rp_line_status
      WHERE  description = 'ACTIVE DATA SAVER';
     EXCEPTION
      WHEN OTHERS THEN
        c_line_status_code := 'AC';
    END;
  ELSIF c_line_status_code	=	'IN' AND
        (NVL(ig.data_saver,'N') = 'Y' OR ig.order_type = 'ADS')
  THEN
    BEGIN
      SELECT line_status_code
      INTO   c_line_status_code
      FROM   sa.x_rp_line_status
      WHERE  description = 'INACTIVE DATA SAVER';
     EXCEPTION
      WHEN OTHERS THEN
        c_line_status_code := 'IN';
    END;
  END IF;
  -- CR45740

  -- CR47564 changes starts..
  -- Get ancillary status code
  BEGIN
    SELECT  ancillary_code
    INTO    c_ancillary_status_code
    FROM    sa.x_rp_ancillary_code_discount
    WHERE   brm_equivalent = c_discount_list;
   EXCEPTION
    WHEN OTHERS THEN
      --c_ancillary_status_code := 'ND'; -- no discounts
      c_ancillary_status_code := 'NOD4U'; -- no discounts
  END;
  -- CR47564 changes ends.
  -- CR48480 Changes Starts..
  --
  IF NVL(c_ancillary_status_code ,'NOD4U') <>  'NOD4U'  AND
     l_discount_code_list IS NOT NULL
  THEN
    --
    c.expiration_date  :=  c.get_expiration_date ( i_esn =>  ig.esn);
    -- get promo objid
    BEGIN  -- check whether esn is enrolled in AutoRefil
      SELECT  pgm_enroll2x_promotion
      INTO    l_promo_objid
      FROM    x_program_enrolled   pe,
              x_program_parameters pp
      WHERE   pe.x_esn                    = ig.esn
      AND     pe.pgm_enroll2pgm_parameter = pp.objid
      AND     NVL(pp.x_prog_class, 'X') NOT IN ('HMO', 'ONDEMAND', 'WARRANTY', 'LOWBALANCE')
      AND     pe.x_enrollment_status         = 'ENROLLED';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT  p.objid promo_objid
          INTO    l_promo_objid
          FROM    table_x_promotion p,
                  table_x_discount_hist dh,
                  table_x_purch_hdr ph,
                  table_x_purch_dtl pd,
                  table_x_red_card   rc,
                  table_x_call_trans ct
          WHERE   1 = 1
          AND     dh.x_disc_hist2x_promo     = p.objid
          AND     dh.x_disc_hist2x_purch_hdr = ph.objid
          AND     ct.x_service_id            = ph.x_esn
          AND     ct.objid                   = ig.call_trans_objid
          AND     rc.red_card2call_trans     = ct.objid
          AND     pd.x_smp                   = rc.x_smp
          AND     pd.x_red_card_number       = rc.x_red_code
          AND     pd.x_purch_dtl2x_purch_hdr = ph.objid
          AND     ph.x_esn                   = ig.esn;
        EXCEPTION
          WHEN OTHERS THEN
            l_promo_objid := NULL;
        END;
      WHEN OTHERS THEN
        l_promo_objid := NULL;
    END;
    --
    sa.promotion_pkg.sp_ins_esn_promo_hist(	ip_esn              =>  ig.esn,
                                            ip_calltrans_id     =>  ig.call_trans_objid,
                                            ip_promo_objid      =>  l_promo_objid,
                                            ip_expiration_date  =>  c.expiration_date,
                                            ip_bucket_id        =>  NULL,
                                            op_error_code       =>  l_error_code,
                                            op_error_msg        =>  l_error_msg,
                                            ip_discount_list    =>  l_discount_code_list
                                            );
    --
  END IF;
  -- CR48480 Changes Ends
  --
  --CR48260 changes start
  BEGIN
    SELECT re.objid, rel.profile_id
    INTO   n_rp_ext_objid, n_rp_profile_id
    FROM   x_rp_extension re,
           x_rp_extension_link rel
    WHERE  re.line_status_code        = c_line_status_code
    AND    re.throttle_status_code    = c_throttle_status_code
    AND    re.ancillary_code          = c_ancillary_status_code
    AND    rel.rp_extension_objid     = re.objid
    AND    rel.carrier_feature_objid  = NVL(i_carrier_features_objid,n_carrier_feature_objid);
  EXCEPTION
    WHEN OTHERS THEN
      n_rp_ext_objid  :=  NULL;
      n_rp_profile_id :=  NULL;
  END;
  --
  --Update the features extension objid and profile id to the IG transaction
  UPDATE gw1.ig_transaction
  SET    rp_ext_objid       =  n_rp_ext_objid,
         cf_profile_id      =  n_rp_profile_id
  WHERE  transaction_id     =  i_transaction_id;
  --
  /*SELECT ig_transaction_features_type ( NULL, -- carrier_features_objid
                                        i_transaction_id        ,
                                        cc.feature_name         ,
                                        cc.feature_value        ,
                                        cc.feature_requirement  , -- feature_requirement (ADD, REM, OPT)
                                        ce.throttle_status_code , --
                                        cc.toggle_flag          , --
                                        cc.display_sui_flag     ,
                                        cc.restrict_sui_flag    ,
                                        cf.profile_id           )
  BULK COLLECT
  INTO   igf
  FROM   x_cf_extension_link cl,
         x_cf_extension ce,
         x_cf_extension_config  cc,
         x_cf_profile cf
  WHERE  1 = 1
  AND    cl.carrier_feature_objid = NVL(i_carrier_features_objid,n_carrier_feature_objid)
  AND    cl.cf_extension_objid    = ce.objid
  AND    ce.line_status_code      = c_line_status_code
  AND    ce.throttle_status_code  = c_throttle_status_code
  AND    ce.ancillary_status_code = c_ancillary_status_code
  AND    cl.profile_id            = cf.profile_id
  AND    cf.profile_id            = cc.profile_id
  AND    cc.toggle_flag           = 'Y';*/

  SELECT ig_transaction_features_type ( NULL                    , -- carrier_features_objid
                                        i_transaction_id        ,
                                        feature_name            ,
                                        feature_value           ,
                                        feature_requirement     , -- feature_requirement (ADD, REM, OPT)
                                        c_throttle_status_code  , --
                                        toggle_flag             , --
                                        display_sui_flag        ,
                                        restrict_sui_flag       ,
                                        profile_id              )
  BULK COLLECT
  INTO   igf
  FROM ( SELECT NULL                    , -- carrier_features_objid
                NULL                    ,
                cc.feature_name         ,
                cc.feature_value        ,
                cc.feature_requirement  , -- feature_requirement (ADD, REM, OPT)
                NULL                    , -- throttle status code
                cc.toggle_flag          , --
                cc.display_sui_flag     ,
                cc.restrict_sui_flag    ,
                cc.profile_id
         FROM   x_rp_extension_config  cc
         WHERE  1 = 1
         AND    cc.profile_id  = n_rp_profile_id
         AND    cc.toggle_flag = 'Y'
         AND    NOT EXISTS (  SELECT 1
                              FROM   x_rp_ancillary_code_config acc
                              WHERE  acc.profile_id       = n_rp_profile_id
                              AND    acc.extension_objid  = n_rp_ext_objid
                              AND    acc.feature_value    = cc.feature_value
                              AND    acc.toggle_flag      = 'Y')
         UNION
         SELECT NULL                    , -- carrier_features_objid
                NULL                    ,
                cc.feature_name         ,
                cc.feature_value        ,
                cc.feature_requirement  , -- feature_requirement (ADD, REM, OPT)
                NULL                    , -- throttle status code
                cc.toggle_flag          , --
                cc.display_sui_flag     ,
                cc.restrict_sui_flag    ,
                cc.profile_id
         FROM   x_rp_ancillary_code_config  cc
         WHERE  1 = 1
         AND    cc.toggle_flag           = 'Y'
         AND    cc.extension_objid       = n_rp_ext_objid
         AND    cc.profile_id            = n_rp_profile_id);
  --CR48260 changes end
  --
  RETURN(igf);
  --
 EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE ( 'get_ig_transaction_features : ' || SQLERRM );
     RETURN NULL;
END get_ig_transaction_features;
--
-------------------------------------------------------------------------------------------------------------
-- Procedure added for CR45249
PROCEDURE insert_ig_transaction_features ( i_transaction_id         IN  NUMBER,
                                           i_carrier_features_objid IN  NUMBER,
                                           i_skip_insert_flag       IN  VARCHAR2, -- CR49087
                                           o_response               OUT VARCHAR2 ) IS
  igft  ig_transaction_features_tab;
  igf   ig_transaction_features_type := ig_transaction_features_type();
  ig    ig_transaction_features_type := ig_transaction_features_type();
  --
  n_count_igft      NUMBER;
BEGIN
  --
  IF i_transaction_id IS NULL THEN
    o_response := 'IG TRANSACTION ID NOT PASSED';
    RETURN;
  END IF;
  /*IF i_carrier_features_objid IS NULL THEN
    o_response := 'CARRIER FEATURES ID IS NOT PASSED';
    RETURN;
  EN IF;*/
  -- get the feature list for a particular carrier feature objid
  igft := igate.get_ig_transaction_features ( i_transaction_id         => i_transaction_id         ,
                                              i_carrier_features_objid => i_carrier_features_objid );
  --
  IF igft IS NULL THEN
    o_response := 'FEATURES NOT APPLICABLE';
    RETURN;
  END IF;
  --
  IF igft.COUNT = 0 THEN
    o_response := 'NO FEATURES AVAILABLE';
    RETURN;
  END IF;
  --
  IF igft.COUNT > 0 THEN
    --
    FOR i IN 1 .. igft.COUNT LOOP
      -- instantiate values
      igf := sa.ig_transaction_features_type ( i_transaction_features_objid => igft(i).transaction_features_objid,
                                               i_transaction_id             => igft(i).transaction_id            ,
                                               i_feature_name               => igft(i).feature_name              ,
                                               i_feature_value              => igft(i).feature_value             ,
                                               i_feature_requirement        => igft(i).feature_requirement       ,
                                               i_throttle_status_code       => igft(i).throttle_status_code      ,
                                               i_toggle_flag                => igft(i).toggle_flag               ,
                                               i_display_sui_flag           => igft(i).display_sui_flag          ,
                                               i_restrict_sui_flag          => igft(i).restrict_sui_flag         ,
                                               i_cf_profile_id              => igft(i).cf_profile_id );
      -- call insert method
      -- CR49087 added condition to insert
      IF i_skip_insert_flag = 'N'
      THEN
        ig := ig.ins ( i_igf => igf );
      END IF;
      DBMS_OUTPUT.PUT_LINE ( 'ig.response: ' || ig.response );
    END LOOP;
    -- get the count of the available features
    SELECT COUNT(1)
    INTO   n_count_igft
    FROM   TABLE(CAST(igft AS ig_transaction_features_tab));
    --
    -- update ig transaction with the new carrier features count
    UPDATE gw1.ig_transaction
    SET    cf_extension_count =  n_count_igft
    WHERE  transaction_id     =  i_transaction_id;
    --
  END IF;
  o_response := 'SUCCESS';
 EXCEPTION
   WHEN others THEN
     o_response := 'UNHANDLED EXCEPTION INSERTING FEATURES: ' || SQLERRM;
     DBMS_OUTPUT.PUT_LINE ( o_response );
END insert_ig_transaction_features;
-------------------------------------------------------------------------------------------------------------
-- Procedure added for CR45249
PROCEDURE insert_ig_trans_carr_response ( i_transaction_id         IN NUMBER,
                                          i_xml_response           IN XMLTYPE,
                                          i_ig_transaction_status  IN VARCHAR2 DEFAULT NULL,
                                          o_response               OUT VARCHAR2 ) IS
 BEGIN
  --
   IF i_transaction_id IS NULL THEN
     o_response := 'IG TRANSACTION ID NOT PASSED';
     RETURN;
   END IF;
   IF i_xml_response IS NULL THEN
     o_response := 'RESPONSE XML NOT PASSED';
     RETURN;
   END IF;
   INSERT INTO ig_trans_carrier_response
   (
    objid,
    transaction_id,
    xml_response,
    ig_transaction_status,
    insert_timestamp,
    update_timestamp
   )
   VALUES
   (
    seq_ig_trans_carrier_response.nextval,  --objid,
    i_transaction_id, -- transaction_id,
    i_xml_response, --xml_response,
    i_ig_transaction_status, --ig_transaction_status,
    SYSDATE,
    SYSDATE
   );
  o_response := 'SUCCESS';
 EXCEPTION
  WHEN dup_val_on_index THEN
    o_response := 'DUPLICATE IG TRANSACTION ID '||SQLERRM;
  WHEN others THEN
    o_response := 'UNHANDLED EXCEPTION INSERTING FEATURES: ' || SQLERRM;
END insert_ig_trans_carr_response;
-- CR 46581 LOCAL PROCEDURE ADDED FOR GO SMART
PROCEDURE insert_ig_transaction_buckets ( i_ig_transaction_id      IN  NUMBER  ,
                                          i_bucket_id              IN  VARCHAR2,
                                          i_bucket_value           IN  VARCHAR2,
                                          i_bucket_balance         IN  VARCHAR2,
                                          i_bucket_expiration_date IN  DATE    ,
                                          i_benefit_type           IN  VARCHAR2 )
IS
BEGIN
  IF i_ig_transaction_id IS NULL OR i_bucket_id IS NULL THEN
  -- NO NEED TO INSERT AN ORPHAN ROW, RETURN AS IS
    RETURN;
  END IF;
  INSERT INTO gw1.ig_transaction_buckets
              ( transaction_id,
                bucket_id,
                recharge_date,
                bucket_balance,
                bucket_value,
                expiration_date,
                direction,
                benefit_type )
  VALUES
              ( i_ig_transaction_id,
                i_bucket_id,
                SYSDATE,
                i_bucket_balance,
                i_bucket_value,
                i_bucket_expiration_date,
                'OUTBOUND',
                i_benefit_type  );
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
END  insert_ig_transaction_buckets;

-- CR46581 ADDING NEW PROCEDURE TO CREATE WALLET BUCKETS IF NEEDED


PROCEDURE create_ig_transaction_buckets ( i_esn                     IN  VARCHAR2 ,
                                          i_ig_transaction_id       IN  NUMBER   ,
                                          i_call_trans_objid        IN  NUMBER   ,
                                          i_site_part_objid         IN  NUMBER   ,
                                          i_rate_plan               IN  VARCHAR2 ,
                                          i_order_type              IN  VARCHAR2 ,
                                          i_bucket_expiration_date  IN  DATE     ,
                                          i_bucket_value            IN NUMBER DEFAULT NULL,
                                          i_non_ppe                 IN NUMBER  DEFAULT NULL,
                                          i_parent_name             in varchar2  DEFAULT NULL) IS

  c_add_on_flag               sa.x_ig_order_type.addon_cash_card_flag%TYPE;
  err_code                    VARCHAR2(4000);
  err_msg                     VARCHAR2(4000);
  -- CR47564 Start
  n_service_plan_id           NUMBER;
  n_bucket_id_count           NUMBER := 0;
  bucket_id_list              sa.ig_transaction_bucket_tab := sa.ig_transaction_bucket_tab();
  cst                         sa.customer_type             := sa.customer_type();               -- CR49087
  rc                          sa.red_card_type             := sa.red_card_type();               -- CR49721
  c_call_trans_action_type    table_x_call_trans.x_action_type%TYPE;                            -- CR49721
  c_call_trans_reason         table_x_call_trans.x_reason%TYPE;
  l_expire_addons             sa.addon_bucket_details_tab  := sa.addon_bucket_details_tab();
  -- CR47564 End
  c_reset_buckets_flag        VARCHAR2(1) := 'N';                                               -- CR55567
  c_brand                     sa.table_bus_org.org_id%TYPE;                                     -- CR55567
  -- CR47852
  CURSOR sm_benefit_curs(   c_site_part_objid  in number,
                            c_parent_name      in varchar2,
                            c_non_ppe          in number,
                            c_rate_plan        in varchar2,
                            c_call_trans_objid in number)
        IS
          SELECT sp.objid,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 1) col1,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 2) col2,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3) col3,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 4) col4
	    ,def.display_name	sp_feature_bucket_name		--CR46315
          FROM x_service_plan_site_part spsp,
            x_service_plan sp,
            x_service_plan_feature spf,
            x_serviceplanfeaturevalue_def def,
            x_serviceplanfeature_value value,
            x_serviceplanfeaturevalue_def def2
          WHERE 1                         =1
          AND spsp.table_site_part_id     = c_site_part_objid
          AND sp.objid                    = spsp.x_service_plan_id
          AND spf.SP_FEATURE2SERVICE_PLAN = sp.objid
          AND def.objid                   = spf.sp_feature2rest_value_def
          AND def.display_name           like  'CARRIER_BUCKET%'
          AND value.spf_value2spf         = spf.objid
          AND def2.objid                  = value.VALUE_REF
          and exists(select 1
                       from gw1.ig_buckets ib
                       where ib.BUCKET_ID = REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3)
                         and ib.rate_plan = c_rate_plan)
          and (case when c_parent_name like '%VERIZON%' then
                      'VER'
                    when c_parent_name like 'AT%'then
                      'ATT'
                    when c_parent_name like '%CINGULAR%'then
                      'ATT'
                    when c_parent_name like '%SPRINT%'then
                      'SPR'
                    when c_parent_name like 'T_MOB%'then
                      'TMO'
                    else
                      'XXX'
                    end )= substr(def2.value_name,1,3)
           and c_non_ppe =1
          --CR56512 changes start
          UNION
          SELECT spe.sp_objid,
                 REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 1) col1,
                 REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 2) col2,
                 REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3) col3,
                 REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 4) col4 ,
                 'CARRIER_BUCKET' sp_feature_bucket_name
          FROM   x_service_plan_ext spe,
                 x_service_plan_site_part spsp
          WHERE  spsp.table_site_part_id = c_site_part_objid
          AND    spsp.x_service_plan_id    = spe.sp_objid
          AND EXISTS(SELECT 1
                     FROM  gw1.ig_buckets ib
                     WHERE ib.BUCKET_ID = REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3)
                     AND   ib.rate_plan = c_rate_plan);
          --CR56512 changes end

BEGIN
  -- check the order type
  BEGIN
    SELECT NVL(addon_cash_card_flag,'N')  addon_cash_card_flag
    INTO   c_add_on_flag
    FROM   x_ig_order_type
    WHERE  x_ig_order_type    = i_order_type
    AND    x_programme_name   = 'SP_INSERT_IG_TRANSACTION'
    AND    ROWNUM = 1;
  EXCEPTION
    WHEN OTHERS THEN
      c_add_on_flag := 'N';
  END;
/*  CR52905 - Commented out to block OUTBOUND buckets for BI transactions
  -- CR49087 Changes starts..
  IF i_order_type   =   'BI'
  THEN
    -- if Order type is BI,pick up ALL buckets from base service plan and add on cards
    FOR bucket_rec IN ( SELECT data_bucket_name,
                               data_bucket_value,
                               sms_bucket_name,
                               sms_bucket_value,
                               voice_bucket_name,
                               voice_bucket_value,
                               ild_bucket_name,
                               ild_bucket_value,
                               intl_bucket_name,
                               intl_bucket_value,
                               ild_benefit_type,  -- CR51296
                               mv.benefit_type -- CR51296
                        FROM   x_service_plan_site_part   spsp,
                               service_plan_feat_pivot_mv mv
                        WHERE  spsp.table_site_part_id = i_site_part_objid
                        AND    mv.service_plan_objid   = spsp.x_service_plan_id
                        AND    EXISTS ( SELECT 1
                                        FROM   ig_buckets igb
                                        WHERE  igb.bucket_id IN ( mv.ild_bucket_name,
                                                                  mv.intl_bucket_name,
                                                                  data_bucket_name,
                                                                  sms_bucket_name,
                                                                  voice_bucket_name
                                                                )
                                        AND    igb.rate_plan = i_rate_plan
                                        AND    igb.active_flag = 'Y'
                                      )
                        UNION
                        -- get all the active data add ons for that subscriber
                        SELECT  ad.data_bucket_name,
                                ad.data_bucket_value,
                                sms_bucket_name,
                                sms_bucket_value,
                                voice_bucket_name,
                                voice_bucket_value,
                                ild_bucket_name,
                                ild_bucket_value,
                                intl_bucket_name,
                                intl_bucket_value,
                                ild_benefit_type,  -- CR51296
                                (CASE WHEN NVL(mv1.benefit_type_flag,'N') = 'Y'
                                      THEN mv1.benefit_type
                                      ELSE  NULL
                                 END)   benefit_type
                        FROM    service_plan_feat_pivot_mv mv1,
                                (SELECT service_plan_objid,
                                        data_bucket_name,
                                        TO_CHAR(SUM(data_bucket_value)) data_bucket_value
                                 FROM   TABLE(cst.get_add_on_details (i_esn  => i_esn))
                                 GROUP  BY service_plan_objid, data_bucket_name) ad
                        WHERE   ad.service_plan_objid = mv1.service_plan_objid
                        AND     EXISTS ( SELECT 1
                                         FROM   ig_buckets igb1
                                         WHERE  igb1.bucket_id IN ( mv1.data_bucket_name)
                                         AND    igb1.rate_plan = i_rate_plan
                                         AND    igb1.active_flag = 'Y'
                                       )
                      )
    LOOP
      -- CREATE DATA BUCKET
      IF ( bucket_rec.data_bucket_name IS NOT NULL AND bucket_rec.data_bucket_value IS NOT NULL )
      THEN
        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => bucket_rec.data_bucket_name,
                                        i_bucket_value           => bucket_rec.data_bucket_value,
                                        i_bucket_balance         => bucket_rec.data_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => bucket_rec.benefit_type);--CR47654 benefit_type derived from service plan
      END IF;
      -- CREATE VOICE BUCKET
      IF ( bucket_rec.voice_bucket_name IS NOT NULL AND bucket_rec.voice_bucket_value IS NOT NULL )
      THEN
        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => bucket_rec.voice_bucket_name,
                                        i_bucket_value           => bucket_rec.voice_bucket_value,
                                        i_bucket_balance         => bucket_rec.voice_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => bucket_rec.benefit_type );--CR47654 benefit_type derived from service plan
      END IF;
      -- CREATE SMS BUCKET
      IF ( bucket_rec.sms_bucket_name IS NOT NULL AND bucket_rec.sms_bucket_value IS NOT NULL )
      THEN
        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => bucket_rec.sms_bucket_name,
                                        i_bucket_value           => bucket_rec.sms_bucket_value,
                                        i_bucket_balance         => bucket_rec.sms_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => bucket_rec.benefit_type); --CR47654 benefit_type derived from service plan
      END IF;
      --- CREATE WALLETICA
      IF ( bucket_rec.ild_bucket_name IS NOT NULL AND bucket_rec.ild_bucket_value IS NOT NULL  ) THEN
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id               ,
                                        i_bucket_id              => bucket_rec.ild_bucket_name ,
                                        i_bucket_value           => bucket_rec.ild_bucket_value,
                                        i_bucket_balance         => bucket_rec.ild_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => bucket_rec.benefit_type);--CR47654 benefit_type derived from service plan
      dbms_output.put_line('ild_bucket_value:'||bucket_rec.ild_bucket_value);
      END IF;
      -- INSERT WALLETPB FOR BASE PLAN
      IF ( bucket_rec.intl_bucket_name IS NOT NULL AND bucket_rec.intl_bucket_value IS NOT NULL ) THEN
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                      i_bucket_id                => bucket_rec.intl_bucket_name,
                                      i_bucket_value             => bucket_rec.intl_bucket_value,
                                      i_bucket_balance           => bucket_rec.intl_bucket_value,
                                      i_bucket_expiration_date   => i_bucket_expiration_date,
                                      i_benefit_type             => NVL(bucket_rec.ild_benefit_type, bucket_rec.benefit_type)); --CR51296 benefit_type derived from service plan feature
      END IF;
    END LOOP;
    --
    RETURN;
    --
  END IF;*/
  -- CR49087 Changes ends.
  --
  -- CR49721 Changes starts..
  BEGIN
    SELECT  x_action_type, x_reason
    INTO    c_call_trans_action_type, c_call_trans_reason --CR47852
    FROM    table_x_call_trans
    WHERE   objid = i_call_trans_objid;
  EXCEPTION
    WHEN OTHERS THEN
      c_call_trans_action_type := NULL;
  END;
  --
  -- While reactivation excluding MIN Change, expire existing ADD ONS
  --
  IF i_order_type IN ('A','E')   AND
     c_call_trans_action_type IN ('3') AND
     customer_info.get_bus_org_id(i_esn => i_esn) IN ('WFM', 'SIMPLE_MOBILE')
  THEN
    --
    l_expire_addons :=  rc.expire_addons(i_esn  =>  i_esn);
    --
    IF l_expire_addons IS NOT NULL
    THEN
      FOR each_rec IN (SELECT *
                       FROM TABLE(l_expire_addons))
      LOOP
        -- create an OUTBOUND record in IG to send the DELETE to carrier
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => each_rec.bucket_name,
                                        i_bucket_value           => 0,
                                        i_bucket_balance         => 0,
                                        i_bucket_expiration_date => each_rec.expiration_date,
                                        i_benefit_type           => each_rec.benefit_type );
      END LOOP;
    END IF;
  END IF;
  -- CR49721 Changes ends.
  --
  -- if the order type is for the cash card add on

  -- Compensation
  -- CR47852
  IF ( c_call_trans_reason  IN  ('COMPENSATION') and sa.customer_info.get_bus_org_id (i_esn => i_esn) = 'SIMPLE_MOBILE' ) THEN

     /*NEED TO CREATE COMPENSATION ADDON BUCKETS WITH EXTENDING THE BASE PLAN BUCKETS DATES AS PART OF COMPENSATION TRANSACTION
       NEW ORDER TYPE WILL CREATE FOR COMPENSATION AS (STK) WITH STACK BUCKETS */

    BEGIN
      -- if PIN is redeemed for the transaction, get it from PIN and ESN
      SELECT sa.get_service_plan_id ( f_esn      => i_esn,
                                      f_red_code => rd.x_red_code )
      INTO   n_service_plan_id
      FROM   table_x_red_card rd
      WHERE  rd.red_card2call_trans = i_call_trans_objid
      AND    ROWNUM = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           n_service_plan_id := customer_info.get_service_plan_objid ( i_esn => i_esn);
      WHEN OTHERS THEN
        NULL;
    END;

    -- GO SMART
    IF  sa.customer_info.get_sub_brand_by_esn (i_esn => i_esn) = 'GO_SMART' THEN
        FOR comp_add_on_rec in (SELECT  'Y' comp_addon,  -- compensation
                                        mv.data_bucket_name,
                                        mv.data_bucket_value,
                                        mv.sms_bucket_name,
                                        mv.sms_bucket_value,
                                        mv.voice_bucket_name,
                                        mv.voice_bucket_value,
                                        mv.ild_bucket_name,
                                        mv.ild_bucket_value,
                                        mv.intl_bucket_name,
                                        mv.intl_bucket_value,
                                        mv.ild_benefit_type,
                                        mv.benefit_type
                                 FROM   sa.service_plan_feat_pivot_mv mv
                                 WHERE  mv.service_plan_objid = n_service_plan_id
                                 AND    EXISTS ( SELECT 1
                                                 FROM   ig_buckets igb
                                                 WHERE  igb.bucket_id   IN ( mv.ild_bucket_name, mv.intl_bucket_name, data_bucket_name, sms_bucket_name, voice_bucket_name )
                                                 AND    igb.rate_plan   = i_rate_plan
                                                 AND    igb.active_flag = 'Y' )

                                UNION
                                SELECT 'N' COMP_ADDON,  -- base plan
                                       data_bucket_name,
                                       data_bucket_value,
                                       sms_bucket_name,
                                       sms_bucket_value,
                                       voice_bucket_name,
                                       voice_bucket_value,
                                       ild_bucket_name,
                                       ild_bucket_value,
                                       intl_bucket_name,
                                       intl_bucket_value,
                                       ild_benefit_type,
                                       mv.benefit_type
                                FROM   x_service_plan_site_part   spsp,
                                       service_plan_feat_pivot_mv mv
                                WHERE  spsp.table_site_part_id = i_site_part_objid
                                AND    mv.service_plan_objid   = spsp.x_service_plan_id
                                AND    EXISTS ( SELECT 1
                                                FROM   ig_buckets igb
                                                WHERE  igb.bucket_id IN ( mv.ild_bucket_name,
                                                                          mv.intl_bucket_name,
                                                                          data_bucket_name,
                                                                          sms_bucket_name,
                                                                          voice_bucket_name
                                                                        )
                                                AND    igb.rate_plan = i_rate_plan
                                                AND    igb.active_flag = 'Y')
                              )
        LOOP

          -- CREATE DATA BUCKET
          IF ( comp_add_on_rec.data_bucket_name IS NOT NULL AND comp_add_on_rec.data_bucket_value IS NOT NULL )
          THEN
             -- set the base plan bucket to 0
             if comp_add_on_rec.comp_addon = 'N' then
                comp_add_on_rec.data_bucket_value := 0;
             end if;
             --
             insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                             i_bucket_id              => comp_add_on_rec.data_bucket_name,
                                             i_bucket_value           => comp_add_on_rec.data_bucket_value,
                                             i_bucket_balance         => comp_add_on_rec.data_bucket_value,
                                             i_bucket_expiration_date => i_bucket_expiration_date,
                                             i_benefit_type           => 'STACK');
          END IF;

          -- CREATE VOICE BUCKET
          IF ( comp_add_on_rec.voice_bucket_name IS NOT NULL AND comp_add_on_rec.voice_bucket_value IS NOT NULL )
          THEN

            insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                            i_bucket_id              => comp_add_on_rec.voice_bucket_name,
                                            i_bucket_value           =>  0,
                                            i_bucket_balance         =>  0,
                                            i_bucket_expiration_date => i_bucket_expiration_date,
                                            i_benefit_type           => 'STACK' );
          END IF;

          -- CREATE SMS BUCKET
          IF ( comp_add_on_rec.sms_bucket_name IS NOT NULL AND comp_add_on_rec.sms_bucket_value IS NOT NULL )
          THEN

            insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                            i_bucket_id              => comp_add_on_rec.sms_bucket_name,
                                            i_bucket_value           => 0,
                                            i_bucket_balance         => 0,
                                            i_bucket_expiration_date => i_bucket_expiration_date,
                                            i_benefit_type           => 'STACK');
          END IF;

          --- CREATE WALLETICA
          IF ( comp_add_on_rec.ild_bucket_name IS NOT NULL AND comp_add_on_rec.ild_bucket_value IS NOT NULL  ) THEN
            insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id               ,
                                            i_bucket_id              => comp_add_on_rec.ild_bucket_name ,
                                            i_bucket_value           => 0,
                                            i_bucket_balance         => 0,
                                            i_bucket_expiration_date => i_bucket_expiration_date,
                                            i_benefit_type           => 'STACK');

            BEGIN
              IF TO_NUMBER(comp_add_on_rec.ild_bucket_value) > 0 THEN
                --
                n_bucket_id_count := n_bucket_id_count + 1;
                bucket_id_list.extend;
                bucket_id_list(n_bucket_id_count) := sa.ig_transaction_bucket_type ( comp_add_on_rec.ild_bucket_name );

              END IF;
             EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;

          END IF;

          -- INSERT WALLETPB FOR BASE PLAN
          IF ( comp_add_on_rec.intl_bucket_name IS NOT NULL AND comp_add_on_rec.intl_bucket_value IS NOT NULL ) THEN
            insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                          i_bucket_id                => comp_add_on_rec.intl_bucket_name,
                                          i_bucket_value             => 0,
                                          i_bucket_balance           => 0,
                                          i_bucket_expiration_date   => i_bucket_expiration_date,
                                          i_benefit_type             => 'STACK');
            BEGIN
              IF TO_NUMBER(comp_add_on_rec.intl_bucket_value) > 0 THEN
                --
                n_bucket_id_count := n_bucket_id_count + 1;
                bucket_id_list.extend;
                bucket_id_list(n_bucket_id_count) := sa.ig_transaction_bucket_type ( comp_add_on_rec.intl_bucket_name );

              END IF;
            EXCEPTION
             WHEN OTHERS THEN
                NULL;
            END;
          END IF;

        END LOOP;

   ELSE -- simple mobile compensation
        -- compenastion buckets
         FOR sm_comp_addon_rec in (SELECT mv.data_bucket_name,
                                          mv.data_bucket_value,
                                          mv.sms_bucket_name,
                                          mv.sms_bucket_value,
                                          mv.voice_bucket_name,
                                          mv.voice_bucket_value,
                                          mv.ild_bucket_name,
                                          mv.ild_bucket_value,
                                          mv.intl_bucket_name,
                                          mv.intl_bucket_value,
                                          mv.ild_benefit_type,
                                          mv.benefit_type
                                    FROM  sa.service_plan_feat_pivot_mv mv
                                    WHERE mv.service_plan_objid = n_service_plan_id
                                    AND   EXISTS ( SELECT 1
                                                   FROM   ig_buckets igb
                                                   WHERE  igb.bucket_id   IN ( mv.ild_bucket_name, mv.intl_bucket_name, data_bucket_name, sms_bucket_name, voice_bucket_name )
                                                   AND    igb.rate_plan   = i_rate_plan
                                                   AND    igb.active_flag = 'Y' ) )
         LOOP
           --
           IF ( sm_comp_addon_rec.data_bucket_name IS NOT NULL AND sm_comp_addon_rec.data_bucket_value IS NOT NULL ) THEN
            --
            insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                            i_bucket_id              => sm_comp_addon_rec.data_bucket_name,
                                            i_bucket_value           => sm_comp_addon_rec.data_bucket_value,
                                            i_bucket_balance         => sm_comp_addon_rec.data_bucket_value,
                                            i_bucket_expiration_date => i_bucket_expiration_date,
                                            i_benefit_type           => sm_comp_addon_rec.benefit_type);
           END IF;
         END LOOP;

         -- base plan bucktes
         FOR sm_base_plan_rec in sm_benefit_curs (i_site_part_objid,
                                                  i_parent_name,
                                                  i_non_ppe,
                                                  i_rate_plan,
                                                  i_call_trans_objid)
         LOOP
            insert_ig_transaction_buckets   ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                              i_bucket_id              => sm_base_plan_rec.col3,
                                              i_bucket_value           => 0,
                                              i_bucket_balance         => 0,
                                              i_bucket_expiration_date => i_bucket_expiration_date,
                                              i_benefit_type           => 'STACK');
         END LOOP;

   END IF;

 ELSE --NON COMPENSATION

  IF c_add_on_flag = 'Y' THEN
    -- CR47564 changes starts..
    -- move the service plan id from the select below in FOR LOOP
    -- Get the service plan id of the pin
    BEGIN
      -- if PIN is redeemed for the transaction, get it from PIN and ESN
      SELECT sa.get_service_plan_id ( f_esn      => i_esn,
                                      f_red_code => rd.x_red_code )
      INTO   n_service_plan_id
      FROM   table_x_red_card rd
      WHERE  rd.red_card2call_trans = i_call_trans_objid
      AND    ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- if pin is not redeemed for the transaction, get the plan from the ESN
        n_service_plan_id := customer_info.get_service_plan_objid ( i_esn => i_esn);
      WHEN OTHERS THEN
        NULL;
    END;
    -- CR47564 changes ends.
    --
    -- CR49696 changes starts..
    -- Update the expiry date for the ADD ON DATA, if end date is null
    UPDATE  x_account_group_benefit
    SET     end_date          =   i_bucket_expiration_date
    WHERE   call_trans_id     =   i_call_trans_objid
    AND     end_date          IS NULL
    AND     customer_info.get_bus_org_id(i_esn => i_esn) = 'WFM'; -- CR49893 restrict it to WFM only
    -- CR49696 changes ends.
    --
    -- IF ORDER TYPE SUPPORTS ADD ON CASH CARD REDEMPTION, GET THE SERVICE PLAN ID FROM ADD ON CARD / BASE PLAN
    -- CREATE BUCKETS BASED ON THE SERVICE PLAN CONFIGURATION (ADD ON CARD / BASE PLAN REDEMPTION)
    FOR add_on_rec in ( SELECT  mv.data_bucket_name,
                                mv.data_bucket_value,
                                mv.sms_bucket_name,
                                mv.sms_bucket_value,
                                mv.voice_bucket_name,
                                mv.voice_bucket_value,
                                mv.ild_bucket_name,
                                mv.ild_bucket_value,
                                mv.intl_bucket_name,
                                mv.intl_bucket_value,
                                mv.benefit_type_flag, -- CR51296
                                mv.ild_benefit_type,  -- CR51296
                                mv.benefit_type, -- CR51296
								mv.expire_previous_add_on   --  CR55066 , mdave, BI usage calculation for SM/ GS add-on
                         FROM   sa.service_plan_feat_pivot_mv mv
                         WHERE  mv.service_plan_objid = n_service_plan_id  --CR47654
                         AND    EXISTS ( SELECT 1
                                         FROM   ig_buckets igb
                                         WHERE  igb.bucket_id   IN ( mv.ild_bucket_name, mv.intl_bucket_name, data_bucket_name, sms_bucket_name, voice_bucket_name )
                                         AND    igb.rate_plan   = i_rate_plan
                                         AND    igb.active_flag = 'Y' ) )
    LOOP
	--CR55066 , mdave, BI usage calculation for SM/ GS add-on
		IF add_on_rec.expire_previous_add_on = 'Y'
			  THEN
				UPDATE  sa.x_account_group_benefit
				SET     status   = 'EXPIRED',
						reason   = 'EXPIRED DUE TO SWEEP ADD OF SAME ADD ON PLAN',
						end_date = SYSDATE
				WHERE   call_trans_id     <>   i_call_trans_objid
				AND     service_plan_id   =   n_service_plan_id
				AND     end_date          IS NULL
				AND     account_group_id  =   ( SELECT  agm.account_group_id
												FROM    sa.x_account_group_member agm
												WHERE   agm.esn       =  i_esn
												AND     agm.end_date  IS NULL
											  );
				--
		END IF;
		-- end CR55066 , mdave, BI usage calculation for SM/ GS add-on

      -- CREATE DATA BUCKET
      IF ( add_on_rec.data_bucket_name IS NOT NULL AND add_on_rec.data_bucket_value IS NOT NULL )
      THEN
        -- CR47852
        IF c_call_trans_reason in ('AWOP', 'REPLACEMENT') THEN
            add_on_rec.data_bucket_value := i_bucket_value;
        END IF;

        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => add_on_rec.data_bucket_name,
                                        i_bucket_value           => add_on_rec.data_bucket_value,
                                        i_bucket_balance         => add_on_rec.data_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => add_on_rec.benefit_type ); --CR47654 benefit_type derived from service plan when applicable
      END IF;
      -- CREATE VOICE BUCKET
      IF ( add_on_rec.voice_bucket_name IS NOT NULL AND add_on_rec.voice_bucket_value IS NOT NULL )
      THEN
        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => add_on_rec.voice_bucket_name,
                                        i_bucket_value           => add_on_rec.voice_bucket_value,
                                        i_bucket_balance         => add_on_rec.voice_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => add_on_rec.benefit_type); --CR47654 benefit_type derived from service plan when applicable
      END IF;
      -- CREATE SMS BUCKET
      IF ( add_on_rec.sms_bucket_name IS NOT NULL AND add_on_rec.sms_bucket_value IS NOT NULL )
      THEN
        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => add_on_rec.sms_bucket_name,
                                        i_bucket_value           => add_on_rec.sms_bucket_value,
                                        i_bucket_balance         => add_on_rec.sms_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => add_on_rec.benefit_type  ); --CR47654 benefit_type derived from service plan when applicable
      END IF;
      --- CREATE WALLETICA
      IF ( add_on_rec.ild_bucket_name IS NOT NULL AND add_on_rec.ild_bucket_value IS NOT NULL  ) THEN
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id               ,
                                        i_bucket_id              => add_on_rec.ild_bucket_name ,
                                        i_bucket_value           => add_on_rec.ild_bucket_value,
                                        i_bucket_balance         => add_on_rec.ild_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => add_on_rec.benefit_type );--CR47654 benefit_type derived from service plan when applicable
        -- CALL CONVERT BO TO SQL PACKAGE TO UPDATE CALL TRANS EXTENSION
        -- CR47564 Changes start
        -- Removed the below call to sp_set_call_trans_ext
        BEGIN
          IF TO_NUMBER(add_on_rec.ild_bucket_value) > 0 THEN
            --
            n_bucket_id_count := n_bucket_id_count + 1;
            bucket_id_list.extend;
            bucket_id_list(n_bucket_id_count) := sa.ig_transaction_bucket_type ( add_on_rec.ild_bucket_name );
            -- CR47564 changes end
          END IF;
         EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        dbms_output.put_line('ild_bucket_value:'||add_on_rec.ild_bucket_value);
      END IF;

      -- CREATE WALLETPB
      IF ( add_on_rec.intl_bucket_name IS NOT NULL AND add_on_rec.intl_bucket_value IS NOT NULL ) THEN
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id,
                                        i_bucket_id              => add_on_rec.intl_bucket_name,
                                        i_bucket_value           => add_on_rec.intl_bucket_value,
                                        i_bucket_balance         => add_on_rec.intl_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => ( CASE WHEN NVL(add_on_rec.benefit_type_flag,'N') ='Y'
                                                                      THEN add_on_rec.benefit_type
                                                                      ELSE add_on_rec.ild_benefit_type
                                                                      END)); -- CR51296
          dbms_output.put_line('add_on_rec.intl_bucket_value:'||add_on_rec.intl_bucket_value);
        -- CR47564 Changes start
        -- Removed the below call to sp_set_call_trans_ext
        BEGIN
          IF TO_NUMBER(add_on_rec.intl_bucket_value) > 0 THEN
            --
            n_bucket_id_count := n_bucket_id_count + 1;
            bucket_id_list.extend;
            bucket_id_list(n_bucket_id_count) := sa.ig_transaction_bucket_type ( add_on_rec.intl_bucket_name );
            -- CR47564 changes end
          END IF;
         EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
    END LOOP;

  ELSE

    --CR55567 - For WFM, SIMPLE_MOBILE, check if it is an ESN Change order type
    IF i_order_type = 'E'
    THEN
       BEGIN
          --Get the brand
          SELECT x_param_value
           INTO  c_brand
          FROM   table_x_parameters
          WHERE x_param_name = 'IGATE_RESET_BUCKETS_ESN_CHANGE_BRANDS'
          AND   x_param_value = sa.customer_info.get_bus_org_id(i_esn => i_esn);
       EXCEPTION
          WHEN OTHERS THEN
             c_brand := NULL;
       END;

       IF c_brand IS NOT NULL
       THEN
         BEGIN
           --Check if buckets have to be reset
           SELECT 'Y'
           INTO  c_reset_buckets_flag
           FROM  ig_transaction ig,
                 table_task tt,
                 table_x_order_type ot
           WHERE ig.transaction_id       = i_ig_transaction_id
           AND   ig.action_item_id       = tt.task_id
           AND   tt.x_task2x_order_type  = ot.objid
           AND   ot.x_order_type        IN (SELECT x_param_value
                                            FROM   table_x_parameters
                                            WHERE  x_param_name = 'IGATE_RESET_BUCKETS_ORDER_TYPES');
         EXCEPTION
           WHEN OTHERS THEN
              c_reset_buckets_flag := 'N';
         END;
       END IF; -- IF c_brand IS NOT NULL
    END IF; -- IF i_order_type = 'E'

    -- CR55567 - For SM, WFM and GoSmart upgrades set buckets to TRANSFER, 0 to stop resetting to full benefits
    -- if not an add on cash card redemption transaction (order type), then pick up ALL buckets from base service plan
    FOR bucket_rec IN ( SELECT data_bucket_name,
                               CASE WHEN c_reset_buckets_flag = 'Y' THEN '0' ELSE data_bucket_value END data_bucket_value,
                               sms_bucket_name,
                               CASE WHEN c_reset_buckets_flag = 'Y' THEN '0' ELSE sms_bucket_value END sms_bucket_value,
                               voice_bucket_name,
                               CASE WHEN c_reset_buckets_flag = 'Y' THEN '0' ELSE voice_bucket_value END voice_bucket_value,
                               ild_bucket_name,
                               CASE WHEN c_reset_buckets_flag = 'Y' THEN '0' ELSE ild_bucket_value END ild_bucket_value,
                               intl_bucket_name,
                               CASE WHEN c_reset_buckets_flag = 'Y' THEN '0' ELSE intl_bucket_value END intl_bucket_value,
                               CASE WHEN c_reset_buckets_flag = 'Y' THEN 'TRANSFER' ELSE ild_benefit_type END ild_benefit_type,  -- CR51296
                               CASE WHEN c_reset_buckets_flag = 'Y' THEN 'TRANSFER' ELSE mv.benefit_type END benefit_type        -- CR51296
                        FROM   x_service_plan_site_part   spsp,
                               service_plan_feat_pivot_mv mv
                        WHERE  spsp.table_site_part_id = i_site_part_objid
                        AND    mv.service_plan_objid   = spsp.x_service_plan_id
                        AND    EXISTS ( SELECT 1
                                        FROM   ig_buckets igb
                                        WHERE  igb.bucket_id IN ( mv.ild_bucket_name,
                                                                  mv.intl_bucket_name,
                                                                  data_bucket_name,
                                                                  sms_bucket_name,
                                                                  voice_bucket_name
                                                                )
                                        AND    igb.rate_plan = i_rate_plan
                                        AND    igb.active_flag = 'Y'
                                      ) )
    LOOP
      -- CREATE DATA BUCKET
      IF ( bucket_rec.data_bucket_name IS NOT NULL AND bucket_rec.data_bucket_value IS NOT NULL )
      THEN
        --CR47852
        if c_call_trans_reason in ('AWOP', 'REPLACEMENT') THEN
            bucket_rec.data_bucket_value := i_bucket_value;
        end if;

        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => bucket_rec.data_bucket_name,
                                        i_bucket_value           => bucket_rec.data_bucket_value,
                                        i_bucket_balance         => bucket_rec.data_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => bucket_rec.benefit_type);--CR47654 benefit_type derived from service plan
      END IF;
      -- CREATE VOICE BUCKET
      IF ( bucket_rec.voice_bucket_name IS NOT NULL AND bucket_rec.voice_bucket_value IS NOT NULL )
      THEN
        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => bucket_rec.voice_bucket_name,
                                        i_bucket_value           => bucket_rec.voice_bucket_value,
                                        i_bucket_balance         => bucket_rec.voice_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => bucket_rec.benefit_type );--CR47654 benefit_type derived from service plan
      END IF;
      -- CREATE SMS BUCKET
      IF ( bucket_rec.sms_bucket_name IS NOT NULL AND bucket_rec.sms_bucket_value IS NOT NULL )
      THEN
        -- CALL PROCEDURE TO INSERT BUCKET RECORD
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                        i_bucket_id              => bucket_rec.sms_bucket_name,
                                        i_bucket_value           => bucket_rec.sms_bucket_value,
                                        i_bucket_balance         => bucket_rec.sms_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => bucket_rec.benefit_type); --CR47654 benefit_type derived from service plan
      END IF;
      --- CREATE WALLETICA
      IF ( bucket_rec.ild_bucket_name IS NOT NULL AND bucket_rec.ild_bucket_value IS NOT NULL  ) THEN
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id               ,
                                        i_bucket_id              => bucket_rec.ild_bucket_name ,
                                        i_bucket_value           => bucket_rec.ild_bucket_value,
                                        i_bucket_balance         => bucket_rec.ild_bucket_value,
                                        i_bucket_expiration_date => i_bucket_expiration_date,
                                        i_benefit_type           => bucket_rec.benefit_type);--CR47654 benefit_type derived from service plan
        -- CR47564 Changes start
        -- Removed the below call to sp_set_call_trans_ext
        BEGIN
          IF TO_NUMBER(bucket_rec.ild_bucket_value) > 0 THEN
            --
            n_bucket_id_count := n_bucket_id_count + 1;
            bucket_id_list.extend;
            bucket_id_list(n_bucket_id_count) := sa.ig_transaction_bucket_type ( bucket_rec.ild_bucket_name );
            -- CR47564 changes end
          END IF;
         EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      dbms_output.put_line('ild_bucket_value:'||bucket_rec.ild_bucket_value);
      END IF;
      -- INSERT WALLETPB FOR BASE PLAN
      IF ( bucket_rec.intl_bucket_name IS NOT NULL AND bucket_rec.intl_bucket_value IS NOT NULL ) THEN
        insert_ig_transaction_buckets ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                      i_bucket_id                => bucket_rec.intl_bucket_name,
                                      i_bucket_value             => bucket_rec.intl_bucket_value,
                                      i_bucket_balance           => bucket_rec.intl_bucket_value,
                                      i_bucket_expiration_date   => i_bucket_expiration_date,
                                      i_benefit_type             => bucket_rec.ild_benefit_type); --CR51296 benefit_type derived from service plan feature
        -- CR47564 Changes start
        -- Removed the below call to sp_set_call_trans_ext
        BEGIN
          IF TO_NUMBER(bucket_rec.intl_bucket_value) > 0 THEN
            --
            n_bucket_id_count := n_bucket_id_count + 1;
            bucket_id_list.extend;
            bucket_id_list(n_bucket_id_count) := sa.ig_transaction_bucket_type ( bucket_rec.intl_bucket_name );
            --CR47564 changes end
          END IF;
         EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
    END LOOP;
  END IF;
 END IF;
  --
  -- CR47564 Changes start
  IF bucket_id_list IS NOT NULL
  THEN
    IF bucket_id_list.COUNT > 0
    THEN
      -- Call convert bo to sql package to save the WALLET bucket ids list in call trans extension
      convert_bo_to_sql_pkg.sp_set_call_trans_ext ( in_calltranobj   => i_call_trans_objid,
                                                    in_total_days    => NULL,
                                                    in_total_text    => NULL,
                                                    in_total_data    => NULL,
                                                    out_err_code     => err_code,
                                                    out_err_msg      => err_msg,
                                                    i_bucket_id_list => bucket_id_list);
    END IF;
  END IF;
  -- CR47564 Changes end
 EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line(SQLERRM);
    ota_util_pkg.err_log( p_action        => 'Insert into ig_transaction_buckets failed.',
                          p_error_date    => SYSDATE,
                          p_key           => i_ig_transaction_id,
                          p_program_name  => 'igate.create_ig_transaction_buckets',
                          p_error_text    => sqlerrm);
END create_ig_transaction_buckets;


PROCEDURE sp_awop_ig_transaction_buckets ( i_esn                     IN  VARCHAR2 ,
                                           i_ig_transaction_id       IN  NUMBER   ,
                                           i_call_trans_objid        IN  NUMBER   ,
                                           i_site_part_objid         IN  NUMBER   ,
                                           i_ig_rate_plan            IN  VARCHAR2 ,
                                           i_order_type              IN  VARCHAR2 ,
                                           i_bucket_expiration_date  IN  DATE     ,
                                           i_non_ppe                 IN  NUMBER   ,
                                           i_bucket_value            IN  NUMBER   ,
                                           i_parent_name             IN  VARCHAR2 ) IS
  v_get_lang VARCHAR2(40);
  v_bucket_value NUMBER;
  CURSOR benefit_curs(c_site_part_objid  in number,
                      c_parent_name      in varchar2,
                      c_non_ppe          in number,
                      c_rate_plan        in varchar2,
                      c_call_trans_objid in number )
        IS
      SELECT sp.objid,
             REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 1) col1,
             REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 2) col2,
             REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3) col3,
             REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 4) col4,
             def.display_name	sp_feature_bucket_name		--CR46315
       FROM  x_service_plan_site_part spsp,
             x_service_plan sp,
             x_service_plan_feature spf,
             x_serviceplanfeaturevalue_def def,
             x_serviceplanfeature_value value,
             x_serviceplanfeaturevalue_def def2
      WHERE  1                         =1
      AND    spsp.table_site_part_id     = c_site_part_objid
      AND    sp.objid                    = spsp.x_service_plan_id
      AND    spf.SP_FEATURE2SERVICE_PLAN = sp.objid
      AND    def.objid                   = spf.sp_feature2rest_value_def
      AND    def.display_name           like  'CARRIER_BUCKET%'
      AND    value.spf_value2spf         = spf.objid
      AND    def2.objid                  = value.VALUE_REF
      and   exists(select 1
                   from gw1.ig_buckets ib
                   where ib.BUCKET_ID = REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3)
                     and ib.rate_plan = c_rate_plan)
      and   (case when c_parent_name like '%VERIZON%' then 'VER'
                when c_parent_name like 'AT%'then 'ATT'
                when c_parent_name like '%CINGULAR%'then 'ATT'
                when c_parent_name like '%SPRINT%'then 'SPR'
                when c_parent_name like 'T_MOB%'then   'TMO'
                else  'XXX'
                end )= substr(def2.value_name,1,3)
       and c_non_ppe =1
      --CR56512 changes start
      UNION
      SELECT spe.sp_objid,
             REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 1) col1,
             REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 2) col2,
             REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3) col3,
             REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 4) col4 ,
             'CARRIER_BUCKET' sp_feature_bucket_name
      FROM   x_service_plan_ext spe,
             x_service_plan_site_part spsp
      WHERE  spsp.table_site_part_id = c_site_part_objid
      AND    spsp.x_service_plan_id    = spe.sp_objid
      AND EXISTS(SELECT 1
                 FROM  gw1.ig_buckets ib
                 WHERE ib.BUCKET_ID = REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3)
                 AND   ib.rate_plan = c_rate_plan);
      --CR56512 changes end
    benefit_test_rec benefit_curs%rowtype;

begin

 IF i_ig_transaction_id is null  then
    RETURN;
 END IF;

 IF sa.customer_info.get_bus_org_id(i_esn => i_esn) = 'SIMPLE_MOBILE' THEN
    -- benifit type
    BEGIN
       SELECT sa.get_lang(action_item_id)
       INTO   v_get_lang
       FROM   ig_transaction
       WHERE  transaction_id = i_ig_transaction_id
       AND    ROWNUM =1;
    EXCEPTION
       WHEN OTHERS THEN
         v_get_lang:=NULL;
    END;

   FOR benefit_rec in benefit_curs (i_site_part_objid,
                                    i_parent_name,
                                    i_non_ppe,
                                    i_ig_rate_plan,
                                    i_call_trans_objid)
   LOOP
     IF benefit_rec.col2 = 'DOMDR' then
        v_bucket_value := benefit_rec.col4;
     ELSE
        v_bucket_value := i_bucket_value;
     END IF;

     insert_ig_transaction_buckets   ( i_ig_transaction_id      => i_ig_transaction_id  ,
                                       i_bucket_id              => benefit_rec.col3,
                                       i_bucket_value           => v_bucket_value,
                                       i_bucket_balance         => v_bucket_value,
                                       i_bucket_expiration_date => i_bucket_expiration_date,
                                       i_benefit_type           => v_get_lang);
   end LOOP;

 END IF;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line(SQLERRM);
    sa.ota_util_pkg.err_log( p_action        => 'Insert into ig_transaction_buckets failed in awop.',
                          p_error_date    => SYSDATE,
                          p_key           => i_ig_transaction_id,
                          p_program_name  => 'igate.sp_awop_ig_transaction_buckets',
                          p_error_text    => sqlerrm);
END sp_awop_ig_transaction_buckets;


--New procedure to get data_saver
PROCEDURE get_data_saver_information ( i_esn                      IN VARCHAR2 ,
                                       i_carrier_features_objid   IN NUMBER   ,
                                       o_data_saver_flag          OUT VARCHAR2,
                                       o_data_saver_code          OUT VARCHAR2 )
IS
n_non_data_saver_check  NUMBER;
n_data_saver_flag       table_x_carrier_features.data_saver%TYPE;
--c_data_saver_code       table_x_carrier_features.data_saver_code%TYPE;
BEGIN
   --GET DATASAVER FLAG AND CODE FOR THE CARRIER FEATURE RECORD
   BEGIN
     SELECT data_saver,
            data_saver_code
     INTO   n_data_saver_flag,
            o_data_saver_code
     FROM   table_x_carrier_features
     WHERE  objid =  i_carrier_features_objid;
   EXCEPTION
     WHEN OTHERS THEN
       n_data_saver_flag := NULL;
   END;
   IF n_data_saver_flag = 1 THEN
   --DATA SAVER IS ON AT CARRIER FEATURES LEVEL
     --CHECK IF DATASAVER WAS EVER TURNED OFF FOR THIS ACCOUNT
     BEGIN
       SELECT COUNT(1)
       INTO   n_non_data_saver_check
       FROM   x_esn_promo_hist promo_hist
       WHERE  promo_hist.esn = i_esn
       AND    promo_hist.promo_hist2x_promotion  = ( SELECT xp.objid
                                                     FROM   table_x_promotion xp
                                                     WHERE  1 = 1
                                                     AND    x_promo_code = 'RDS' )
       AND NVL(promo_hist.expiration_date,SYSDATE + 1)  > SYSDATE;
     EXCEPTION
       WHEN OTHERS
       THEN
         n_non_data_saver_check := 0;
     END;
     IF n_non_data_saver_check = 0
     THEN --DATA SAVER IS ON AT CARRIER FEATURE LEVEL AND WAS NEVER TURNED OFF
     -- RETURN THE FLAG AS "Y". DATA_SAVER_CODE IS ALREADY POPULATED
       o_data_saver_flag := 'Y';
       RETURN;
     ELSE --DATA SAVER IS ON AT CARRIER FEATURE LEVEL
     -------BUT WAS TURNED OFF. HENCE SEND THE FLAG BACK AS "N"
     -------DATA SAVER CODE IS ALREADY POPULATED
       o_data_saver_flag := 'N';
       RETURN;
     END IF;
   ELSIF   n_data_saver_flag = 0
   THEN --DATA SAVER IS TURNED OFF AT CARRIER FEATURE LEVEL
   --SEND BACK DATA SAVER FLAG AS "N". DATA SAVER CODE IS ALREADY POPULATED
     o_data_saver_flag := 'N';
     RETURN;
   ELSE
   --DATA SAVER IS NOT EVEN DEFINED AT FEATURES LEVEL
   -- IN THIS CASE, RETURN BOTH CODE AND FLAG AS NULL
     o_data_saver_flag := NULL;
     o_data_saver_code := NULL;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
     o_data_saver_flag := NULL;
     o_data_saver_code := NULL;
END get_data_saver_information;

--Procedure create_sui_buckets added for CR48373
PROCEDURE create_sui_buckets ( i_esn               IN VARCHAR2,
                               i_transaction_id    IN NUMBER,
                               o_error_code        OUT VARCHAR2,
                               o_error_message     OUT VARCHAR2)
IS
   n_upgrade_count         NUMBER;
   n_upgrade_lookback_days NUMBER;
   cust_type               customer_type;
   cust_type1              customer_type;
   ig                      sa.ig_transaction_type;
   igb_current             ig_transaction_buckets_tab;
   igb_previous            ig_transaction_buckets_tab;
   igb_last                ig_transaction_buckets_tab;               --CR49734
   p_rate_plan             ig_transaction.rate_plan%TYPE;
   c_benefit_type          VARCHAR2(50);
   c_buckets_flag          x_ig_order_type.create_buckets_flag%TYPE; --CR52905
   c_free_sms_value        table_x_parameters.x_param_value%TYPE;    --CR52905
   --Commented since values already retrieved in ig_transaction_type --CR52905
   --c_rate_plan             ig_transaction.rate_plan%TYPE;
   --c_order_type            ig_transaction.order_type%TYPE; -- CR49734 - Added order_type to check order_type

BEGIN

    cust_type := customer_type(i_esn => i_esn);
    cust_type1 := customer_type(i_esn => i_esn);

    cust_type.service_plan_objid := cust_type.get_service_plan_objid(i_esn);

    cust_type1 := cust_type1.get_safelink_attributes;
    cust_type.safelink_flag := cust_type1.safelink_flag;

    cust_type1 := cust_type1.get_service_plan_attributes;
    cust_type.service_plan_group := cust_type1.service_plan_group;

    ig := ig_transaction_type (i_transaction_id => i_transaction_id);

    --CR52905 - Get the buckets creation flag for the IG order type
    c_buckets_flag := get_create_buckets_flag(in_order_type => ig.order_type);

    --CR52905 Get the value for Free SMS
    BEGIN
       SELECT x_param_value
       INTO   c_free_sms_value
       FROM   table_x_parameters
       WHERE  x_param_name = 'UNLIMITED_FREE_SMS_VALUE';

    EXCEPTION
       WHEN OTHERS THEN
       -- DEFAULT TO 99999
       c_free_sms_value := '99999';
    END ;


    BEGIN
     -- GET THE LAST "X" DAYS NUMBER
       SELECT TO_NUMBER(x_param_value)
       INTO   n_upgrade_lookback_days
       FROM   table_x_parameters
       WHERE  x_param_name = 'SUI_UPGRADE_LOOKBACK_DAYS';

    EXCEPTION
       WHEN OTHERS THEN
       -- DEFAULT TO 7 DAYS
       n_upgrade_lookback_days := 7;
    END ;

    -- CHECK IF THERE WAS AN UPGRADE IN LAST "X" DAYS
    -- CR52905 Changed the check for call trans action_type to use new flag from table_x_code_table. Removed table task.
    BEGIN

     SELECT COUNT (1)
      INTO   n_upgrade_count
      FROM   table_x_call_trans
      WHERE  x_service_id         = i_esn
      AND    x_action_type       IN (SELECT x_code_number
                                       FROM table_x_code_table
                                      WHERE get_sui_last_trans_flag = 'Y')
      AND    x_transact_date     >= TRUNC(SYSDATE) - n_upgrade_lookback_days;

    EXCEPTION
      WHEN OTHERS THEN
        n_upgrade_count := 0;
    END;

    -- CR49734 Moved last transaction fetch to the top of the procedure
    -- GET BUCKETS FROM LAST TRANSACTION
    BEGIN
        SELECT ig_transaction_buckets_type ( transaction_id   =>  b.transaction_id,
                                             bucket_id        =>  b.bucket_id,
                                             recharge_date    =>  b.recharge_date,
                                             bucket_balance   =>  b.bucket_balance,
                                             bucket_value     =>  b.bucket_balance,
                                             expiration_date  =>  b.expiration_date,
                                             direction        =>  b.direction,
                                             benefit_type     =>  b.benefit_type,
                                             bucket_type      =>  b.bucket_type )
        BULK COLLECT
        INTO   igb_last
        FROM
            ( SELECT /*+ use_invisible_indexes*/ igbt.*,
                  max(ig.creation_date) over (partition by ig.esn) max_create_date,
                  ig.creation_date
              FROM   ig_transaction_buckets igbt,
                     ig_transaction ig,
                     table_task tt,
                     table_x_call_trans cte
              WHERE  ig.esn                 = i_esn
              AND    ig.status              IN ('S', 'W') --CR52905
              AND    ig.transaction_id      = igbt.transaction_id
              AND    igbt.direction         = 'OUTBOUND'
              AND    tt.task_id             = ig.action_item_id
              AND    tt.x_task2x_call_trans = cte.objid
              --AND    cte.x_action_type     IN ('1', '3', '6', '111') --CR52905
              AND    cte.x_action_type     IN (SELECT x_code_number
                                                 FROM table_x_code_table
                                                WHERE get_sui_last_trans_flag = 'Y')
              AND    igbt.bucket_value != '0') b -- CR49734 Added filter to ignore 0 value buckets
        WHERE creation_date = max_create_date;
    EXCEPTION
       WHEN OTHERS
          THEN
             igb_last := ig_transaction_buckets_tab();
    END;

    -- Fetch bucket information for previous UI --CR52905 - Moved to top
    BEGIN
        SELECT ig_transaction_buckets_type ( transaction_id   =>  b.transaction_id,
                                             bucket_id        =>  b.bucket_id,
                                             recharge_date    =>  b.recharge_date,
                                             bucket_balance   =>  b.bucket_balance,
                                             bucket_value     =>  b.bucket_value,
                                             expiration_date  =>  b.expiration_date,
                                             direction        =>  b.direction,
                                             benefit_type     =>  b.benefit_type,
                                             bucket_type      =>  b.bucket_type )
        BULK COLLECT
        INTO   igb_previous
        FROM
            ( SELECT /*+ use_invisible_indexes*/ igbt.*,
                     max(ig.creation_date) over (partition by ig.esn) max_create_date,
                     ig.creation_date
              FROM   ig_transaction_buckets igbt,
                     ig_transaction ig
              WHERE  ig.esn = i_esn
              AND    ig.status = 'S'
              AND    ig.order_type = 'UI'
              AND    ig.transaction_id = igbt.transaction_id
              AND    igbt.direction    = 'INBOUND') b
        WHERE creation_date = max_create_date;
    EXCEPTION
       WHEN OTHERS
          THEN
             igb_previous := ig_transaction_buckets_tab();
    END;

    --CR52905 Set Transaction found flag in GTT
    IF n_upgrade_count > 0 --AND igb_last.COUNT > 0
    THEN
      BEGIN
         INSERT
         INTO   gtt_sui_bi_buckets_check
         VALUES (i_transaction_id, 'Y');
      EXCEPTION
        WHEN OTHERS THEN
        NULL;
      END;
    ELSE
      BEGIN
         INSERT
         INTO   gtt_sui_bi_buckets_check
         VALUES (i_transaction_id, 'N');
      EXCEPTION
        WHEN OTHERS THEN
        NULL;
      END;
    END IF;

    IF n_upgrade_count > 0 OR cust_type.service_plan_group = 'PAY_GO' OR cust_type.safelink_flag = 'Y'
    THEN
        IF cust_type.safelink_flag = 'Y'
        THEN
            BEGIN
                SELECT ig_transaction_buckets_type ( transaction_id   =>  ig.transaction_id,
                                                     bucket_id        =>  b.bucket_id,
                                                     recharge_date    =>  SYSDATE,
                                                     bucket_balance   =>  CASE WHEN b.bucket_value = '0' THEN NVL(igbt.bucket_value, '0') ELSE b.bucket_value END, --CR52905
                                                     bucket_value     =>  CASE WHEN b.bucket_value = '0' THEN NVL(igbt.bucket_value, '0') ELSE b.bucket_value END, --CR49734
                                                     expiration_date  =>  igbt.expiration_date, -- CR49734 - Replaced NULL with value from ig_transaction_buckets for last transaction
                                                     direction        =>  'OUTBOUND',
                                                     benefit_type     =>  NVL(igbt.benefit_type, 'TRANSFER'), -- CR49734 - TRANSFER if NULL
                                                     bucket_type      =>  b.bucket_type )
                BULK COLLECT
                INTO   igb_current
                FROM
               ( SELECT igb.bucket_id, CASE WHEN igb.bucket_type = 'FREE_DATA_UNITS'
                                                THEN sp.data
                                             --CR52905 - Provision unlimited SMS bucket for Safelink
                                             WHEN igb.bucket_type = 'FREE_SMS_UNITS'
                                                THEN c_free_sms_value --sp.sms
                                             WHEN igb.bucket_type = 'FREE_VOICE_UNITS'
                                                THEN sp.voice
                                             ELSE '0'
                                         END bucket_value,
                          igb.bucket_type
                  FROM ig_buckets igb,(SELECT data, voice, sms
                                       FROM  service_plan_feat_pivot_mv
                                       WHERE service_plan_objid = cust_type.service_plan_objid) sp
                  WHERE   igb.active_flag = 'Y'
                  AND igb.rate_plan = ig.rate_plan) b
                  LEFT OUTER JOIN TABLE(igb_last) igbt ON b.bucket_id = igbt.bucket_id; -- CR49734 -- Using values from last transaaction

            EXCEPTION
              WHEN OTHERS
              THEN
                   igb_current := ig_transaction_buckets_tab();
            END;

        ELSE--cust_type.safelink_flag = 'Y'

           -- Get Benefit type for rate plan
           BEGIN

              SELECT benefit_type
              INTO   c_benefit_type
              FROM   service_plan_feat_pivot_mv
              WHERE  service_plan_objid = cust_type.service_plan_objid;

           EXCEPTION
           WHEN OTHERS THEN
               NULL;
           END;

           -- USE BUCKETS FROM LAST TRANSACTION  -- CR49734
           IF igb_last.COUNT > 0
           THEN
              BEGIN
                  SELECT ig_transaction_buckets_type ( transaction_id   =>  b.transaction_id,
                                                       bucket_id        =>  b.bucket_id,
                                                       recharge_date    =>  b.recharge_date,
                                                       bucket_balance   =>  b.bucket_balance,
                                                       bucket_value     =>  b.bucket_balance,
                                                       expiration_date  =>  b.expiration_date,
                                                       direction        =>  b.direction,
                                                       benefit_type     =>  c_benefit_type, -- CR49734 - Benefit Type from Service Plan
                                                       bucket_type      =>  b.bucket_type )
                  BULK COLLECT
                  INTO   igb_current
                  FROM   TABLE(igb_last) b ;
              EXCEPTION
                 WHEN OTHERS
                    THEN
                       igb_current := ig_transaction_buckets_tab();
              END;
           ELSE
              BEGIN
                SELECT ig_transaction_buckets_type ( transaction_id   =>  ig.transaction_id,
                                                     bucket_id        =>  b.bucket_id,
                                                     recharge_date    =>  SYSDATE,
                                                     bucket_balance   =>  '0',
                                                     bucket_value     =>  '0',
                                                     expiration_date  =>  NULL,
                                                     direction        =>  'OUTBOUND',
                                                     benefit_type     =>  'TRANSFER',
                                                     bucket_type      =>  b.bucket_type )
                BULK COLLECT
                INTO   igb_current
                FROM
                   (SELECT igb.bucket_id, igb.bucket_type
                    FROM   ig_buckets igb
                    WHERE  igb.active_flag = 'Y'
                    AND    igb.rate_plan = ig.rate_plan) b;
              EXCEPTION
                WHEN OTHERS
                   THEN
                      igb_current := ig_transaction_buckets_tab();
              END;
           END IF; --igb_last.COUNT > 0

        END IF; --IF cust_type.safelink_flag = 'Y'

        IF igb_current IS NOT NULL
        THEN

          IF igb_current.COUNT > 0
          THEN

             DELETE FROM ig_transaction_buckets WHERE transaction_id = ig.transaction_id AND direction = 'OUTBOUND';

             -- NOW CREATE BUCKETS
             FOR bucket_loop IN igb_current.FIRST..igb_current.LAST
             LOOP

                 igate.insert_ig_transaction_buckets ( i_ig_transaction_id      => ig.transaction_id,
                                                       i_bucket_id              => igb_current(bucket_loop).bucket_id,
                                                       i_bucket_value           => igb_current(bucket_loop).bucket_value,
                                                       i_bucket_balance         => NULL,
                                                       i_bucket_expiration_date => igb_current(bucket_loop).expiration_date,
                                                       i_benefit_type           => igb_current(bucket_loop).benefit_type );

             END LOOP;

          END IF;--IF igb_current.COUNT > 0
        END IF;--IF igb_current IS NOT NULL

    ELSE--IF n_upgrade_count > 0 OR cust_type.service_plan_group = 'PAY_GO' OR cust_type.safelink_flag = 'Y'

        BEGIN
    --CR48373 Provisioning Fix
            SELECT ig_transaction_buckets_type ( transaction_id   =>  b.transaction_id,
                                                 bucket_id        =>  b.bucket_id,
                                                 recharge_date    =>  b.recharge_date,
                                                 bucket_balance   =>  b.bucket_balance,
                                                 bucket_value     =>  b.bucket_value,
                                                 expiration_date  =>  b.expiration_date,
                                                 direction        =>  b.direction,
                                                 benefit_type     =>  b.benefit_type,
                                                 bucket_type      =>  b.bucket_type )
            BULK COLLECT
            INTO   igb_current
            FROM
                 ( SELECT igbt.*
                   FROM   ig_transaction_buckets igbt
                   WHERE  igbt.transaction_id =i_transaction_id
                   AND igbt.bucket_value != '0') b; -- CR49734 Added filter to ignore 0 value buckets
        END;
    END IF;--IF n_upgrade_count > 0 OR cust_type.service_plan_group = 'PAY_GO' OR cust_type.safelink_flag = 'Y'


    -- CR49734 Fetch rate plan for Last Transaction or previous UI based on order type
     --IF c_order_type = 'UI' THEN -- CR52905
    IF ig.order_type = 'UI' THEN
       --Fetch rate plan from customers service plan for UI transactions --CR52905
       p_rate_plan := service_plan.f_get_esn_rate_plan ( p_esn => i_esn);

    ELSE
       -- Fetch rate plan from previous UI for PFR transactions
       BEGIN
          SELECT rate_plan
          INTO   p_rate_plan
          FROM   ig_transaction
          WHERE  transaction_id = igb_previous(1).transaction_id;
       EXCEPTION
            WHEN others THEN
                NULL;
       END;
     END IF;

    --IF c_rate_plan = p_rate_plan -- CR52905
    IF ig.rate_plan = p_rate_plan
    THEN

       -- CR49734 - Replaced Loop with INTERSECT and replaced last UI logic with last transaction
       IF igb_current IS NOT NULL
       THEN

          UPDATE  ig_transaction_buckets
          SET     bucket_value = '0',
                  benefit_type = 'TRANSFER'
          WHERE   transaction_id = i_transaction_id
          AND     bucket_id in (SELECT bucket_id FROM TABLE(igb_current)
                                INTERSECT
                                SELECT bucket_id FROM TABLE(igb_previous));

       END IF; -- IF igb_current IS NOT NULL THEN

    ELSE -- ig.rate_plan = p_rate_plan

       IF igb_current IS NOT NULL
       THEN

          FOR igb_cur_loop IN igb_current.FIRST..igb_current.LAST
          LOOP

              IF cust_type.safelink_flag = 'Y'
              THEN

                  IF igb_current(igb_cur_loop).bucket_type IN ('FREE_DATA_UNITS', 'FREE_SMS_UNITS', 'FREE_VOICE_UNITS')
                  THEN
                      UPDATE  ig_transaction_buckets
                      SET     benefit_type = 'SWEEP_ADD'
                      WHERE   transaction_id = igb_current(igb_cur_loop).transaction_id
                      AND     bucket_id = igb_current(igb_cur_loop).bucket_id;
                  ELSE
                      UPDATE  ig_transaction_buckets
                      SET     benefit_type = 'STACK'  -- CR49734 - Changed to STACK from TRANSFER, 0
                      WHERE   transaction_id = igb_current(igb_cur_loop).transaction_id
                      AND     bucket_id = igb_current(igb_cur_loop).bucket_id;
                  END IF;
              ELSE --cust_type.safelink_flag = 'Y'

                  UPDATE  ig_transaction_buckets
                  SET     benefit_type = c_benefit_type
                  WHERE   transaction_id = igb_current(igb_cur_loop).transaction_id
                  AND     bucket_id = igb_current(igb_cur_loop).bucket_id;

              END IF; --cust_type.safelink_flag = 'Y'

          END LOOP; --igb_cur_loop

       END IF;--IF igb_current IS NOT NULL

    END IF; --ig.rate_plan = p_rate_plan

    --CR48373 Provisioning Fix End

    --CR52905 Move buckets to SUI table if buckets creation flag is SUI
    IF c_buckets_flag = 'SUI'
    THEN
       BEGIN
          INSERT INTO ig_sui_transaction_buckets
            ( transaction_id,
              bucket_id,
              recharge_date,
              bucket_balance,
              bucket_value,
              expiration_date,
              direction,
              benefit_type,
              bucket_type,
              bucket_usage,
              insert_timestamp
            )
          SELECT transaction_id,
                 bucket_id,
                 recharge_date,
                 bucket_balance,
                 bucket_value,
                 expiration_date,
                 direction,
                 benefit_type,
                 bucket_type,
                 bucket_usage,
                 SYSDATE
          FROM  ig_transaction_buckets
          WHERE transaction_id = i_transaction_id
          AND   direction = 'OUTBOUND';
       EXCEPTION
       WHEN OTHERS
       THEN
         o_error_code := '100';
         o_error_message := 'ERROR INSERTING INTO SUI TRANSACTION BUCKETS: ' || SQLERRM;
         RETURN;
       END;

        IF SQL%ROWCOUNT > 0
        THEN
           DELETE FROM  ig_transaction_buckets
           WHERE  transaction_id = i_transaction_id
           AND   direction = 'OUTBOUND';
        END IF;

    END IF;

    --CR52905 Update to fix buckets with benefit_type SWEEP_ADD and bucket_value 0
    IF c_buckets_flag = 'YES'
    THEN
       UPDATE  ig_transaction_buckets
          SET  benefit_type = 'STACK'
        WHERE  transaction_id = i_transaction_id
          AND  direction      = 'OUTBOUND'
          AND  benefit_type   = 'SWEEP_ADD'
          AND  bucket_value   = '0';
    END IF;

    o_error_code:='0';
    o_error_message:='Success';

EXCEPTION
    WHEN OTHERS THEN
        o_error_code    := SQLCODE;
        o_error_message := SQLERRM;

END create_sui_buckets;

--CR50029
--New procedure to retieve additional attributes from IG for SUI specific CBO call
PROCEDURE get_ig_attributes_sui(i_esn             IN VARCHAR2 ,
                                i_ord_type        IN VARCHAR2 ,
                                o_ig_rec          OUT sys_refcursor,
                                o_error_code      OUT VARCHAR2,
                                o_error_message   OUT VARCHAR2 )
IS
BEGIN
   --X_MPN , Rate_plan ,
   o_error_code := '0';
   o_error_message := 'Success';
   BEGIN --{
     OPEN o_ig_rec FOR
	 SELECT ig.*
       FROM gw1.ig_transaction ig
      WHERE esn        = i_esn
	    AND order_type = i_ord_type
        AND transaction_id = (SELECT /*+ use_invisible_indexes */ MAX(transaction_id)
                                FROM gw1.ig_transaction
                               WHERE esn = i_esn
							     AND order_type = i_ord_type
                                 --AND order_type <> 'APN'
						     );
   EXCEPTION
     WHEN OTHERS THEN
		   BEGIN--{
			   OPEN o_ig_rec FOR
			   SELECT   igh.*
			   FROM   gw1.ig_transaction_history igh,
					  sa.table_x_call_trans ct,
					  sa.table_task tt
			  WHERE   1=1
				AND   ct.x_service_id  = i_esn
				AND   tt.x_task2x_call_trans = ct.objid
				AND   igh.action_item_id = tt.task_id;

		   EXCEPTION WHEN OTHERS THEN
		   o_error_code := '-1';
		   o_error_message := 'Could not find IG record';
		   END;--}
   END;--}
END get_ig_attributes_sui;
-- CR52986, function to get the data_units conversion from KB to MB flag based on column value on table x_rate_plan
-- mdave, 08/10/2017
FUNCTION get_calculate_data_units_flag ( i_rate_plan IN VARCHAR2 ) RETURN BOOLEAN DETERMINISTIC
IS
  c_flag VARCHAR2(1);
BEGIN
  IF i_rate_plan IS NULL THEN
    RETURN FALSE;
  END IF;

  BEGIN
    SELECT DISTINCT NVL(calculate_data_units_flag,'N')
    INTO   c_flag
    FROM   sa.x_rate_plan
    WHERE  x_rate_plan = i_rate_plan;
   EXCEPTION
    WHEN others THEN
      c_flag := 'N';
  END;

  RETURN(CASE c_flag WHEN 'Y' THEN TRUE ELSE FALSE END);

 EXCEPTION
   WHEN OTHERS THEN
     RETURN FALSE; -- return false.
END get_calculate_data_units_flag;

--CR52803 new function added
FUNCTION get_safelink_batch_flag(i_order_type IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
   c_safelink_batch_flag VARCHAR2(1);
BEGIN

   SELECT NVL(safelink_batch_flag,'N')  safelink_batch_flag
   INTO   c_safelink_batch_flag
   FROM   x_ig_order_type
   WHERE  x_ig_order_type    = i_order_type
   AND    x_programme_name   = 'SP_INSERT_IG_TRANSACTION'
   AND    ROWNUM = 1;

   RETURN c_safelink_batch_flag;

   EXCEPTION
 WHEN OTHERS THEN
   RETURN 'N';
END get_safelink_batch_flag;
--CR52803 new function added

-- CR50242
PROCEDURE sp_get_ig_values(
							p_esn                IN  VARCHAR2 ,
							p_order_type         IN  VARCHAR2 ,
							p_application_system IN  VARCHAR2 DEFAULT 'IG',
							o_ig_rec             OUT SYS_REFCURSOR,
							p_status             OUT VARCHAR2,
							p_ret_msg            OUT VARCHAR2
                          )
IS

 p_task_objid           NUMBER;
 p_order_type_objid     NUMBER;
  CURSOR get_taskid_cur IS
  SELECT tt.*
      FROM table_task tt,
	       table_x_order_type ot ,
		   table_x_call_trans ct
      WHERE ct.X_SERVICE_ID      = p_esn
      and tt.x_task2x_order_type = ot.objid
      and tt.x_task2x_call_trans = ct.objid
      --and ot.x_order_type        = p_order_type
	  AND ROWNUM < 2;
	--tt_rec get_taskid_cur%rowtype;

  CURSOR same_rate_plan_curs(c_call_trans_objid IN NUMBER)
  IS
    SELECT ig.rate_plan
    FROM table_task tt,
      gw1.ig_transaction ig
    WHERE tt.X_TASK2X_CALL_TRANS = c_call_trans_objid
    AND ig.action_item_id        = tt.task_id
    ORDER BY tt.objid DESC,
      tt.start_date DESC;
  same_rate_plan_rec same_rate_plan_curs%rowtype;
  --
  CURSOR task_curs(c_task_objid IN NUMBER)
  IS
    SELECT * FROM table_task WHERE objid = c_task_objid;
  task_rec task_curs%ROWTYPE;
  --
  CURSOR cur_case_dtl(c_call_tran_objid NUMBER)
  IS
    SELECT c.x_case_type ,
      c.title ,
      c.objid case_objid
    FROM table_case c ,
      table_x_case_detail cd
    WHERE cd.detail2case = c.objid
    AND c.objid         IN
      (SELECT MAX(c.objid)
      FROM table_case c ,
        table_x_call_trans ct ,
        table_x_case_detail cd
      WHERE c.x_esn      = ct.x_service_id
      AND cd.detail2case = c.objid
      AND ct.objid       = c_call_tran_objid
      AND creation_time >= SYSDATE - 1 / 48
      AND c.x_case_type           IN ('Units')
      AND c.title                 IN ('Compensation Service Plan' ,'Replacement Units' ,'Replacement Service Plan')
      AND cd.x_name               IN ('SERVICE_DAYS' ,'VOICE_UNITS' ,'DATA_UNITS' ,'SMS_UNITS')
      )
  AND cd.x_name  = 'SERVICE_PLAN'
  AND cd.x_value = 'All You Need'
  ORDER BY c.objid DESC;
  case_dtl_rec cur_case_dtl%ROWTYPE;
  CURSOR cur_pir_case_dtl(c_call_tran_objid NUMBER)
  IS
    SELECT c.x_case_type ,
      c.title ,
      c.objid case_objid
    FROM table_case c ,
      table_x_case_detail cd
    WHERE cd.detail2case = c.objid
    AND c.objid         IN
      (SELECT MAX(c.objid)
      FROM table_case c ,
        table_x_call_trans ct ,
        table_x_case_detail cd
      WHERE c.x_esn        = ct.x_service_id
      AND cd.detail2case   = c.objid
      AND ct.objid         = c_call_tran_objid
      AND ct.x_action_type = '111'
      AND creation_time BETWEEN SYSDATE - 30 AND SYSDATE
      AND ((c.x_case_type = 'Port In'
      AND c.title        IN ('ST Auto Internal')))
      AND cd.x_name      IN ('SERVICE_DAYS' ,'VOICE_UNITS' ,'DATA_UNITS' ,'SMS_UNITS')
      )
  AND cd.x_name  = 'SERVICE_PLAN'
  AND cd.x_value = 'All You Need'
  ORDER BY c.objid DESC;
  --
  CURSOR cu_bucket_details ( c_esn VARCHAR2 ,c_rate_plan VARCHAR2 ,c_case_objid NUMBER )
  IS
    SELECT *
    FROM
      (SELECT NULL bucket_id ,
        cd.x_name ,
        cd.x_value ,
        DECODE(cd.x_name ,'SERVICE_DAYS' ,1 ,2) sort_order
      FROM table_x_case_detail cd ,
        table_case c
      WHERE cd.detail2case = c.objid
      AND c.x_esn          = c_esn
      AND x_name          IN ('SERVICE_DAYS')
      AND c.objid          = c_case_objid
      ORDER BY c.creation_time DESC
      )
  WHERE ROWNUM < 2
  UNION
  SELECT DECODE(cd.x_name ,'SERVICE_DAYS' ,NULL ,bkt.bucket_id) bucket_id ,
    cd.x_name ,
   cd.x_value,
    DECODE(cd.x_name ,'SERVICE_DAYS' ,1 ,2) sort_order
  FROM table_x_case_detail cd ,
    (SELECT *
    FROM
      (SELECT *
      FROM table_case
      WHERE x_esn = c_esn
      AND objid   = c_case_objid
      ORDER BY creation_time DESC
      )
    WHERE ROWNUM < 2
    ) c ,
    (SELECT bucket_id ,
      measure_unit ,
      bucket_desc ,
      bucket_type ,
      rate_plan ,
      (SELECT COUNT(1)
      FROM gw1.ig_buckets bkt2
      WHERE bkt2.bucket_type = bkt1.bucket_type
      AND bkt2.rate_plan     = bkt1.rate_plan
      ) cnt
    FROM gw1.ig_buckets bkt1
    ) bkt
  WHERE cd.detail2case = c.objid
  AND cd.x_name        = bkt.bucket_type
  AND bkt.rate_plan    = c_rate_plan
  AND x_name          IN ('VOICE_UNITS' ,'DATA_UNITS' ,'SMS_UNITS')
  ORDER BY 4;
  -- For Case Attribute which are created with value 0.
  CURSOR cu_bkt_dtl_without_case_dtl ( c_esn VARCHAR2 ,c_rate_plan VARCHAR2 ,c_case_objid NUMBER )
  IS
    SELECT NULL bucket_id ,
      'SERVICE_DAYS' x_name ,
      0 x_value ,
      1 sort_order
    FROM
      (SELECT 'SERVICE_DAYS' x_name FROM dual
    MINUS
    SELECT x_name
    FROM table_x_case_detail
    WHERE detail2case = c_case_objid
    AND x_name       IN ('SERVICE_DAYS')
      )
    UNION
    SELECT DECODE(cd.x_name ,'SERVICE_DAYS' ,NULL ,bkt.bucket_id) bucket_id ,
      cd.x_name ,
      0 x_value ,
      DECODE(cd.x_name ,'SERVICE_DAYS' ,1 ,2) sort_order
    FROM
      (SELECT 'SERVICE_DAYS' x_name FROM dual
      UNION
      SELECT 'VOICE_UNITS' FROM dual
      UNION
      SELECT 'DATA_UNITS' FROM dual
      UNION
      SELECT 'SMS_UNITS' FROM dual
      MINUS
      SELECT x_name
      FROM table_x_case_detail
      WHERE detail2case = c_case_objid
      AND x_name       IN ('SERVICE_DAYS' ,'VOICE_UNITS' ,'DATA_UNITS' ,'SMS_UNITS')
      ) cd ,
      (SELECT bucket_id ,
        measure_unit ,
        bucket_desc ,
        bucket_type ,
        rate_plan ,
        (SELECT COUNT(1)
        FROM gw1.ig_buckets bkt2
        WHERE bkt2.bucket_type = bkt1.bucket_type
        AND bkt2.rate_plan     = bkt1.rate_plan
        ) cnt
      FROM gw1.ig_buckets bkt1
      ) bkt
    WHERE cd.x_name     = bkt.bucket_type
    AND bkt.rate_plan   = c_rate_plan
    ORDER BY 4;
    --
    CURSOR chk_need_dep_igtx_curs(c_esn VARCHAR2)
    IS
      SELECT
        /*+ use_invisible_indexes */
        *
      FROM gw1.ig_transaction
      WHERE esn         = c_esn
      AND order_type               IN ('A' ,'E' ,'IPI' ,'PIR' ,'EPIR') --CR17415 PM 08/02/2011 'Port In' added for PPIR order type. -- CR17793 to remove PPIR
      AND status NOT               IN ('S' ,'F')
      AND creation_date > = SYSDATE - 1 / 24;
    chk_need_dep_igtx_rec chk_need_dep_igtx_curs%ROWTYPE;
    CURSOR contact_curs(c_contact_objid IN NUMBER)
    IS
      SELECT tc.* FROM table_contact tc WHERE tc.objid = c_contact_objid;
    contact_rec contact_curs%ROWTYPE;
    CURSOR address_curs(c_contact_objid IN NUMBER)
    IS
      SELECT a.*
      FROM table_contact_role cr,
        table_site s,
        table_address a
      WHERE cr.contact_role2contact = c_contact_objid
      AND s.objid                   = cr.contact_role2site
      AND a.objid                   = cust_primaddr2address;
    address_rec address_curs%rowtype;
    CURSOR c1
    IS
      SELECT ig.*
      FROM gw1.ig_transaction ig,
        table_task t
      WHERE 1               =1
      AND ig.action_item_id = t.task_id
      AND t.objid           = p_task_objid;
    c1_rec c1%rowtype;
    CURSOR ld_curs(c_call_trans_objid IN NUMBER)
    IS
      SELECT rsid,
        x_value
      FROM x_switchbased_transaction st
      WHERE st.x_sb_trans2x_call_trans = c_call_trans_objid;
    ld_rec ld_curs%rowtype;
    --
    CURSOR order_type_curs(c_objid IN NUMBER)
    IS
      SELECT ot.*
      FROM table_x_order_type ot
      WHERE ot.objid = c_objid;
   order_type_rec order_type_curs%ROWTYPE;
    --
    CURSOR trans_profile_curs(c_objid IN NUMBER, c_tech IN VARCHAR2)
    IS
      SELECT objid,
        DECODE(c_tech,'GSM',x_gsm_trans_template,'CDMA',x_d_trans_template,x_transmit_template) template,
        DECODE(c_tech,'GSM',x_gsm_transmit_method,'CDMA',x_d_transmit_method,x_transmit_method) transmit_method,
        DECODE(c_tech,'GSM',x_gsm_fax_number,'CDMA',x_d_fax_number,x_fax_number) fax_number,
        DECODE(c_tech,'GSM',x_gsm_fax_num2,'CDMA',x_d_fax_num2,x_fax_num2) fax_num2,
        DECODE(c_tech,'GSM',x_gsm_online_number,'CDMA',x_d_online_number,x_online_number) online_number,
        DECODE(c_tech,'GSM',x_gsm_online_num2,'CDMA',x_d_online_num2,x_online_num2) online_num2,
        DECODE(c_tech,'GSM',x_gsm_email,'CDMA',x_d_email,x_email) email,
        DECODE(c_tech,'GSM',x_gsm_network_login,'CDMA',x_d_network_login,x_network_login) network_login,
        DECODE(c_tech,'GSM',x_gsm_network_password,'CDMA',x_d_network_password,x_network_password) network_password,
        DECODE(c_tech,'GSM',x_system_login,'CDMA',x_d_system_login,x_system_login) system_login,
        DECODE(c_tech,'GSM',x_system_password,'CDMA',x_d_system_password,x_system_password) system_password,
        DECODE(c_tech,'GSM',x_gsm_batch_delay_max,'CDMA',x_d_batch_delay_max,x_batch_delay_max) batch_delay_max,
        DECODE(c_tech,'GSM',x_gsm_batch_quantity,'CDMA',x_d_batch_quantity,x_batch_quantity) batch_quantity
      FROM table_x_trans_profile
      WHERE objid = c_objid;
    trans_profile_rec trans_profile_curs%ROWTYPE;
    --
    CURSOR carrier_curs(c_objid IN NUMBER)
    IS
      SELECT c.*,
        NVL(
        (SELECT 1
        FROM sa.x_next_avail_carrier nac
        WHERE nac.x_carrier_id = c.x_carrier_id
        AND rownum             < 2
        ),0) x_next_avail_carrier
      FROM table_x_carrier c
      WHERE objid = c_objid;
      carrier_rec carrier_curs%ROWTYPE;
      --
      CURSOR carrier_group_curs(c_objid IN NUMBER)
      IS
        SELECT * FROM table_x_carrier_group WHERE objid = c_objid;
      carrier_group_rec carrier_group_curs%ROWTYPE;
      --
      CURSOR parent_curs(c_objid IN NUMBER)
      IS
        SELECT * FROM table_x_parent WHERE objid = c_objid;
      parent_rec parent_curs%ROWTYPE;
      --
      CURSOR c_nap_rc(p_zipcode IN VARCHAR2)
      IS
        SELECT * FROM sa.x_cingular_mrkt_info WHERE zip = p_zipcode AND ROWNUM < 2;
      c_nap_rc_rec c_nap_rc%ROWTYPE;
      --
      CURSOR call_trans_curs(c_objid IN NUMBER)
      IS
        SELECT ct.* ,
          (SELECT pi.x_msid FROM table_part_inst pi WHERE pi.part_serial_no = ct.x_min and pi.x_domain = 'LINES' and rownum < 2
          ) msid,
        DECODE(ct.x_ota_type,ota_util_pkg.ota_activation,'Y',NULL) ota_activation
      FROM table_x_call_trans ct
      WHERE ct.objid = c_objid;
      call_trans_rec call_trans_curs%ROWTYPE;

      CURSOR site_part_curs(c_objid IN NUMBER)
      IS
        SELECT CAST(sp.x_min AS VARCHAR2(30)) x_min,
          sp.x_service_id,
          sp.x_expire_dt,
          sp.cmmtmnt_end_dt,
          CAST(sp.x_pin AS VARCHAR2(30)) x_pin,
          sp.x_zipcode,
          sp.site_part2part_info,
          (SELECT pi.part_inst2carrier_mkt
          FROM table_part_inst pi
          WHERE pi.part_serial_no = sp.x_min
          AND pi.x_domain         = 'LINES'
          ) part_inst2carrier_mkt,
        (SELECT pi.n_part_inst2part_mod
        FROM table_part_inst pi
        WHERE pi.part_serial_no = sp.x_service_id
        AND pi.x_domain         = 'PHONES'
        ) n_part_inst2part_mod,
        (
        CASE
          WHEN sp.x_iccid IS NULL
          THEN
            (SELECT pi.x_iccid
            FROM table_part_inst pi
            WHERE pi.part_serial_no = sp.x_service_id
            AND pi.x_domain         = 'PHONES'
            )
          ELSE sp.x_iccid
        END) iccid
      FROM table_site_part sp
      WHERE objid = c_objid;
      site_part_rec site_part_curs%ROWTYPE;
      --
      CURSOR alt_min_curs(c_esn IN VARCHAR2, c_order_type IN VARCHAR2)
      IS
        SELECT c.s_title,
          (SELECT cd.x_value l_account
          FROM table_x_case_detail cd
          WHERE cd.x_name
            || ''                     IN ('CURRENT_MIN')
          AND cd.detail2case = c.objid + 0
          AND rownum         <2
          ) MIN ,
        (SELECT cd.x_value l_account
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('ACCOUNT')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) account ,
        (SELECT cd.x_value l_first_name
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('NAME')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) first_name ,
        (SELECT cd.x_value l_last_name
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('LAST_NAME')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) last_name ,
        (SELECT cd.x_value l_add1
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('ADDRESS_1')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) add1 ,
        (SELECT cd.x_value l_add2
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('ADDRESS_2')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) add2 ,
        (SELECT cd.x_value l_zip
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('ZIP_CODE')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) zip ,
        (SELECT cd.x_value l_account
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('PIN')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) pin,
        (SELECT cd.x_value l_curr_addr_house_number
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_HOUSE_NUMBER')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_house_number,
        (SELECT cd.x_value l_curr_addr_direction
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_DIRECTION')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_direction,
        (SELECT cd.x_value l_curr_addr_street_name
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_STREET_NAME')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_street_name,
        (SELECT cd.x_value l_curr_addr_street_type
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_STREET_TYPE')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_street_type,
        (SELECT cd.x_value l_curr_addr_unit
        FROM table_x_case_detail cd
        WHERE cd.x_name
          || ''                     IN ('CURR_ADDR_UNIT')
        AND cd.detail2case = c.objid + 0
        AND rownum         <2
        ) curr_addr_unit
      FROM table_case c
      WHERE 1=1
      AND c.x_case_type
        || ''     = 'Port In'
      AND c.x_esn = c_esn
      ORDER BY c.creation_time DESC;
      alt_min_rec alt_min_curs%ROWTYPE;
      --
      CURSOR part_num_curs(c_objid IN NUMBER)
      IS
        SELECT pn.* ,
          DECODE(org_flow,'3',1,0) straight_talk_flag,
          bo.org_id ,
          bo.objid bus_org_objid,
          bo.org_flow,
          NVL(
          (SELECT to_number(v.x_param_value)
          FROM table_x_part_class_values v,
            table_x_part_class_params n
          WHERE 1                 =1
          AND v.value2part_class  = pn.part_num2part_class
          AND v.value2class_param = n.objid
          AND n.x_param_name      = 'DATA_SPEED'
          AND rownum              <2
          ),NVL(x_data_capable,0)) data_speed,
                                  (SELECT to_number(v.x_param_value)
            FROM table_x_part_class_values v,
                table_x_part_class_params n
           WHERE 1                 =1
             AND v.value2part_class  = pn.part_num2part_class
             AND v.value2class_param = n.objid
             AND n.x_param_name      = 'NON_PPE'
             AND rownum              <2) PPE_FLAG
        FROM table_part_num pn ,
          table_mod_level ml ,
          table_bus_org bo
        WHERE pn.objid          = ml.part_info2part_num
        AND ml.objid            = c_objid
        AND pn.part_num2bus_org = bo.objid;
        part_num_rec part_num_curs%ROWTYPE;
        --
        CURSOR carrier_features_curs1 ( c_objid IN NUMBER ,c_tech IN VARCHAR2 ,c_bus_org_objid IN NUMBER ,c_data_speed IN NUMBER,c_order_type IN VARCHAR2 )
        IS
          SELECT cf.*,
            1 col1
          FROM table_x_carrier_features cf
          WHERE x_feature2x_carrier = c_objid
          AND cf.x_technology       = c_tech
          AND cf.x_features2bus_org = c_bus_org_objid
          AND cf.x_data             = c_data_speed;
        CURSOR carrier_features_curs2 ( c_objid IN NUMBER ,c_tech IN VARCHAR2 ,c_bus_org_objid IN NUMBER ,c_data_speed IN NUMBER,c_order_type IN VARCHAR2 )
        IS
          SELECT cf.*,
            2 col1
          FROM table_x_carrier_features cf
          WHERE EXISTS
            (SELECT 1
            FROM table_x_carrier c,
              table_x_carrier_group cg,
              table_x_carrier_group cg2,
              table_x_carrier c2
            WHERE c.objid                    = c_objid
            AND cg.objid                     = c.carrier2carrier_group
            AND cg2.X_CARRIER_GROUP2X_PARENT = cg.X_CARRIER_GROUP2X_PARENT
            AND c2.carrier2carrier_group     = cg2.objid
            AND c2.objid                     = cf.X_FEATURE2X_CARRIER
            )
        AND cf.x_technology       = c_tech
        AND cf.X_FEATURES2BUS_ORG =
          (SELECT bo.objid
          FROM table_bus_org bo
          WHERE bo.org_id = 'NET10'
          AND bo.objid    = c_bus_org_objid
          )
        AND cf.x_data = c_data_speed;
        CURSOR carrier_features_curs3 ( c_objid IN NUMBER ,c_tech IN VARCHAR2 ,c_bus_org_objid IN NUMBER ,c_data_speed IN NUMBER,c_order_type IN VARCHAR2 )
        IS
          SELECT cf.*,
            3 col1
          FROM table_x_carrier_features cf
          WHERE x_feature2x_carrier = c_objid
          AND c_order_type         IN ('D','S');
        carr_feature_rec1 carrier_features_curs1%ROWTYPE;
        --
        CURSOR carrier_features_curs ( c_objid IN NUMBER)
        IS
         SELECT cf.*,
            DECODE(cf.x_voicemail ,1 ,'Y' ,'N') voice_mail,
            cf.x_vm_code voice_mail_package,
            DECODE(cf.x_caller_id ,1 ,'Y' ,'N') caller_id,
            cf.x_id_code caller_id_package,
            DECODE(cf.x_call_waiting ,1 ,'Y' ,'N') call_waiting,
            cf.x_cw_code call_waiting_package,
            DECODE(cf.x_sms ,1 ,'Y' ,'N') sms,
            cf.x_sms_code sms_package,
            DECODE(cf.x_dig_feature ,1 ,'Y' ,'N') digital_feature,
            cf.x_digital_feature digital_feature_code,
            DECODE(cf.x_mpn ,1 ,'Y' ,'N') mpn,
            cf.x_mpn_code mpn_code,
            cf.x_pool_name pool_name,
            (
            CASE
              WHEN cf.X_SWITCH_BASE_RATE IS NOT NULL
              THEN 1
              ELSE 0
            END) non_ppe
          FROM table_x_carrier_features cf
          WHERE cf.objid = c_objid;
        carr_feature_rec carrier_features_curs%ROWTYPE;
        --
        CURSOR old_esn_curs(c_esn IN VARCHAR2, c_org_id IN VARCHAR2)
        IS
          SELECT cd.x_value esn,
            c.creation_time c_date
          FROM table_x_case_detail cd ,
            table_case c
          WHERE cd.detail2case = c.objid + 0
          AND c.x_esn          = c_esn
          AND cd.x_name
            || ''             = 'REFERENCE_ESN'
          AND 'STRAIGHT_TALK' = c_org_id
        UNION
        SELECT x_old_esn esn,
          X_DETACH_DT c_date
        FROM x_min_esn_change
        WHERE x_new_esn      = c_esn
        AND 'STRAIGHT_TALK' != c_org_id
        ORDER BY c_date DESC;
        old_esn_rec old_esn_curs%ROWTYPE;
        --
        CURSOR old_min_curs(ip_service_id IN VARCHAR2)
        IS
          SELECT x_min
          FROM table_site_part
          WHERE x_service_id = ip_service_id
          AND part_status    = 'Inactive'
          AND x_min NOT LIKE 'T%'
          ORDER BY service_end_dt DESC;
        old_min_rec old_min_curs%ROWTYPE;
        CURSOR new_transaction_id_curs
        IS
          SELECT gw1.trans_id_seq.nextval + (POWER(2 ,28)) transaction_id FROM dual;
        new_transaction_id_rec new_transaction_id_curs%rowtype;


	CURSOR cur_promo_data(c_site_part_objid IN NUMBER,
	c_parent_name 		in varchar2,
	c_non_ppe 		in number,
	c_rate_plan 		in varchar2
	,c_promo_data_feat_name	in varchar2
	)
	IS
	SELECT sp.objid,
	REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 1) col1,
	REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 2) col2,
	REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3) col3,
	REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 4) col4
	,def.display_name	sp_feature_bucket_name
	FROM x_service_plan_site_part spsp,
	x_service_plan sp,
	x_service_plan_feature spf,
	x_serviceplanfeaturevalue_def def,
	x_serviceplanfeature_value value,
	x_serviceplanfeaturevalue_def def2
	WHERE 1                         =1
	AND spsp.table_site_part_id     = c_site_part_objid
	AND sp.objid                    = spsp.x_service_plan_id
	AND spf.SP_FEATURE2SERVICE_PLAN = sp.objid
	AND def.objid                   = spf.sp_feature2rest_value_def
	AND def.display_name            =  c_promo_data_feat_name	---'BUCKET_PROMO_DATA' For simple mobile 40, 50 and 55 plans
	AND value.spf_value2spf         = spf.objid
	AND def2.objid                  = value.VALUE_REF
	and exists(select 1
			from gw1.ig_buckets ib
			where ib.BUCKET_ID = REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3)
			and ib.rate_plan = c_rate_plan)
	and (case when c_parent_name like '%VERIZON%' then
		'VER'
		when c_parent_name like 'AT%'then
		'ATT'
		when c_parent_name like '%CINGULAR%'then
		'ATT'
		when c_parent_name like '%SPRINT%'then
		'SPR'
		when c_parent_name like 'T_MOB%'then
		'TMO'
		else
		'XXX'
		end )= substr(def2.value_name,1,3)
	and c_non_ppe =1
  --CR56512 changes start
  UNION
  SELECT spe.sp_objid,
         REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 1) col1,
         REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 2) col2,
         REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3) col3,
         REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 4) col4 ,
         'CARRIER_BUCKET' sp_feature_bucket_name
  FROM   x_service_plan_ext spe,
         x_service_plan_site_part spsp
  WHERE  spsp.table_site_part_id = c_site_part_objid
  AND    spsp.x_service_plan_id    = spe.sp_objid
  AND EXISTS(SELECT 1
             FROM  gw1.ig_buckets ib
             WHERE ib.BUCKET_ID = REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3)
             AND   ib.rate_plan = c_rate_plan);
	rec_promo_data cur_promo_data%rowtype;


CURSOR CUR_SP_FEATURE_VALUE (I_SP_OBJID 		IN VARCHAR2
				, I_SP_FEATURE_NAME	IN VARCHAR2)
IS
SELECT def2.VALUE_NAME
FROM x_service_plan sp,
     x_service_plan_feature spf,
     x_serviceplanfeaturevalue_def def,
     x_serviceplanfeature_value value,
     x_serviceplanfeaturevalue_def def2
WHERE spf.SP_FEATURE2SERVICE_PLAN = sp.objid
AND def.objid                   = spf.sp_feature2rest_value_def
AND def.display_name            =  I_SP_FEATURE_NAME
AND value.spf_value2spf         = spf.objid
AND sp.objid			= I_SP_OBJID
AND value.spf_value2spf         = spf.objid
AND def2.objid                  = value.VALUE_REF
;

REC_SP_FEATURE_VALUE	CUR_SP_FEATURE_VALUE%ROWTYPE;
--
        CURSOR benefit_curs(c_site_part_objid  in number,
                            c_parent_name      in varchar2,
                            c_non_ppe          in number,
                            c_rate_plan        in varchar2,
                            c_call_trans_objid in number)
        IS
          SELECT sp.objid,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 1) col1,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 2) col2,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3) col3,
            REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 4) col4
	    ,def.display_name	sp_feature_bucket_name
          FROM x_service_plan_site_part spsp,
            x_service_plan sp,
            x_service_plan_feature spf,
            x_serviceplanfeaturevalue_def def,
            x_serviceplanfeature_value value,
            x_serviceplanfeaturevalue_def def2
          WHERE 1                         =1
          AND spsp.table_site_part_id     = c_site_part_objid
          AND sp.objid                    = spsp.x_service_plan_id
          AND spf.SP_FEATURE2SERVICE_PLAN = sp.objid
          AND def.objid                   = spf.sp_feature2rest_value_def
          AND def.display_name           like  'CARRIER_BUCKET%'
          AND value.spf_value2spf         = spf.objid
          AND def2.objid                  = value.VALUE_REF
          and exists(select 1
                       from gw1.ig_buckets ib
                       where ib.BUCKET_ID = REGEXP_SUBSTR(def2.value_name, '[^ ]+', 1, 3)
                         and ib.rate_plan = c_rate_plan)
          and not exists(select 1
                           from table_x_call_trans
                          where objid = c_call_trans_objid
                            and x_reason in ('COMPENSATION', 'REPLACEMENT', 'AWOP'))
          and (case when c_parent_name like '%VERIZON%' then
                      'VER'
                    when c_parent_name like 'AT%'then
                      'ATT'
                    when c_parent_name like '%CINGULAR%'then
                      'ATT'
                    when c_parent_name like '%SPRINT%'then
                      'SPR'
                    when c_parent_name like 'T_MOB%'then
                      'TMO'
                    else
                      'XXX'
                    end )= substr(def2.value_name,1,3)
           and c_non_ppe =1
          --CR56512 changes start
          UNION
          SELECT spe.sp_objid,
                 REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 1) col1,
                 REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 2) col2,
                 REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3) col3,
                 REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 4) col4 ,
                 'CARRIER_BUCKET' sp_feature_bucket_name
          FROM   x_service_plan_ext spe,
                 x_service_plan_site_part spsp
          WHERE  spsp.table_site_part_id = c_site_part_objid
          AND    spsp.x_service_plan_id    = spe.sp_objid
          AND EXISTS(SELECT 1
                     FROM  gw1.ig_buckets ib
                     WHERE ib.BUCKET_ID = REGEXP_SUBSTR(spe.claro_carrier_bucket, '[^ ]+', 1, 3)
                     AND   ib.rate_plan = c_rate_plan);
          --CR56512 changes end
        benefit_test_rec benefit_curs%rowtype;
        --Safelink IVR SOC Removal
        CURSOR check_sl_curs(c_esn IN table_x_call_trans.x_service_id%TYPE)
        IS
          SELECT slcur.*
        FROM x_sl_currentvals slcur, x_program_enrolled pe
        WHERE 1 = 1
        AND slcur.x_current_esn = c_esn
        AND slcur.x_current_esn = pe.x_esn
        AND pe.x_enrollment_status = 'ENROLLED';
        check_sl_rec check_sl_curs%ROWTYPE;
        -- Safelink IVR SOC Removal

        --  ATT Carrier Switch
        CURSOR bucket_curs (c_rate_plan in varchar2,
                            c_site_part_objid IN NUMBER,
                            c_voice_units ig_transaction_buckets.bucket_balance%TYPE,
                            c_text_units ig_transaction_buckets.bucket_balance%TYPE,
                            c_data_units ig_transaction_buckets.bucket_balance%TYPE) IS
         SELECT DISTINCT
                socs.x_soc_id bucket_id,
                decode(socs.x_soc, 'VOICE', c_voice_units, 'MESSAGE', c_text_units, 'DATA', c_data_units *1024) bucket_value,
                decode(socs.x_soc, 'VOICE', c_voice_units, 'MESSAGE', c_text_units, 'DATA', c_data_units *1024) bucket_balance
        FROM    adfcrm_serv_plan_feat_matview spf, x_service_plan_site_part spsp,
                x_mtm_socs socs
        WHERE  1=1
        AND spsp.table_site_part_id = c_site_part_objid
        AND spf.sp_objid = spsp.x_service_plan_id
        AND socs.x_rate_plan = c_rate_plan
        AND spf.fea_value = socs.x_soc;
        bucket_info_rec bucket_curs%rowtype;

        CURSOR NET10_HOTSPOT_BUCKETS  (c_table_site_part_id IN NUMBER,
                                       c_rate_plan VARCHAR2,
                                       c_action_item_id IN VARCHAR2 ) IS
        SELECT DISTINCT                          /*+ use_invisible_indexes */
                        sp.objid,
                        sp.mkt_name,
                        sp.description,
                        spfvdef.value_name,
                        spfvdef2.value_name property_value,
                        igb.bucket_id,ig.rate_plan,ig.transaction_id
           FROM x_serviceplanfeaturevalue_def spfvdef,
                x_serviceplanfeature_value spfv,
                x_service_plan_feature spf,
                x_serviceplanfeaturevalue_def spfvdef2,
                x_service_plan sp,
                x_service_plan_site_part spsp,
                ig_transaction ig,
                ig_buckets igb
          WHERE     1 = 1
            AND ig.action_item_id = c_action_item_id        --'1484769007'
            AND ig.rate_plan=igb.rate_plan
            AND igb.ACTIVE_FLAG='Y'
            AND ig.action_item_id = c_action_item_id
            AND spsp.table_site_part_id = c_table_site_part_id --1642705406
            and igb.rate_plan =  c_rate_plan --'TF_4G_FTE_4GMBB'
            AND spsp.x_service_plan_id = sp.objid
            AND spf.sp_feature2service_plan = sp.objid
            AND spf.sp_feature2rest_value_def = spfvdef.objid
            AND spf.objid = spfv.spf_value2spf
            AND SPFVDEF2.OBJID = SPFV.VALUE_REF
            AND spfvdef.value_name in( 'SERVICE DAYS','DATA')
            ;
        --  ATT Carrier Switch

        --  ATT Carrier Switch populate Language field in IG_TRANSACTION start
                                CURSOR c_get_lang (c_action_item_id IN VARCHAR2)
                                                IS
                                                SELECT DISTINCT /*+ use_invisible_indexes */
                                                                   sp.objid,
                                                                   sp.mkt_name,
                   sp.description,
                   spfvdef.value_name,
                   spfvdef2.value_name property_value
              FROM x_serviceplanfeaturevalue_def spfvdef,
                                                                   x_serviceplanfeature_value spfv,
                                           x_service_plan_feature spf,
                                           x_serviceplanfeaturevalue_def spfvdef2,
                                           x_service_plan sp,
                                           x_service_plan_site_part spsp,
                                           table_site_part tsp,
                                           ig_transaction ig,
                                           table_task tt
             WHERE 1 = 1
               AND ig.action_item_id = c_action_item_id
                                                   AND tt.task_id = ig.action_item_id
                                                   AND ig.esn = tsp.x_service_id
                                       AND tsp.OBJID = spsp.TABLE_SITE_PART_ID
                                       AND spsp.x_service_plan_id = sp.objid
                                       AND spf.sp_feature2service_plan = sp.objid
                                       AND spf.sp_feature2rest_value_def = spfvdef.objid
                                       AND spf.objid = spfv.spf_value2spf
                                       AND SPFVDEF2.OBJID = SPFV.VALUE_REF
                                       AND spfvdef.value_name ='BENEFIT_TYPE';

          CURSOR  c_get_e911( ip_esn IN VARCHAR2)
          IS
          SELECT ta.*
          FROM sa.X_E911_ESN  E911,sa.TABLE_ADDRESS TA
          WHERE 1=1
          AND E911.ESN2E911ADDRESS=ta.address2e911
          AND E911.X_ESN= ip_esn;

    --  ATT Carrier Switch populate Language field in IG_TRANSACTION end

        order_type          VARCHAR2(200);
        tmo_flex_order_type VARCHAR2(200);
        l_carr_feat_objid   NUMBER;
        v_raw_benefit       BOOLEAN := FALSE;

    v_in_voice_units       ig_transaction_buckets.bucket_balance%TYPE := NULL;
    v_in_text_units        ig_transaction_buckets.bucket_balance%TYPE := NULL;
    v_in_data_units        ig_transaction_buckets.bucket_balance%TYPE  := NULL;
    l_bus_org_id           varchar2(30);
   e911_rec                c_get_e911%ROWTYPE;
   v_LANGUAGE                                                                ig_transaction.LANGUAGE%TYPE;
   l_error_message varchar2(1000);

   lv_data_promo_code		table_x_promotion.x_promo_code%type;
   lv_multi_data_promo_code		table_x_promotion.x_promo_code%type;
   lv_multi_data_promo_objid		table_x_promotion.objid%type;
   lv_data_promo_objid		table_x_promotion.objid%type;
   lv_promo_error_code		VARCHAR2(2);
   lv_promo_error_msg		VARCHAR2(300);
   lv_data_multiplier		NUMBER	:=	1;
   lv_promo_error_text		VARCHAR2(2000);
   lv_sp_promo_bucket_feat	x_serviceplanfeaturevalue_def.display_name%type;
   lv_data_bucket_value		VARCHAR2(30);
   lv_bucket_active_days			NUMBER;
   lv_promo_bucket_expr_date		DATE;
   lv_multi_data_bucket_id	VARCHAR2(30 BYTE);
   o_response             VARCHAR2(1000);
   v_get_lang                     VARCHAR2(100);
   -- CR45740
   LV_DATA_SAVER		ig_transaction.data_saver%type;
   LV_DATA_SAVER_CODE		ig_transaction.data_saver_code%type;
   LV_NON_DATA_SAVER_CNT	NUMBER;
   -- CR45740
   v_bucket_value ig_transaction_buckets.bucket_value%TYPE;
   V_EXPIRATION_DATE ig_transaction_buckets.expiration_date%TYPE;
   o_error_code         NUMBER;
   o_error_message      VARCHAR2(300);
   c_skip_insert_flag       VARCHAR2(1) :=  'Y' ;
   l_prl_number              VARCHAR2(50) ;
   l_bil_mkt                 VARCHAR2(50) ;
   l_bil_sub_mkt             VARCHAR2(50) ;

BEGIN
    OPEN get_taskid_cur ;
	FETCH get_taskid_cur INTO task_rec;
	IF get_taskid_cur%NOTFOUND THEN
        p_status := 1;
        p_ret_msg := 'No Task Found';
		CLOSE get_taskid_cur;
        RETURN;
      END IF;
    CLOSE get_taskid_cur;
	p_task_objid        := task_rec.objid;
    p_order_type_objid  := task_rec.x_task2x_order_type;

	--
    /*OPEN task_curs(p_task_objid);
      FETCH task_curs INTO task_rec;
      IF task_curs%NOTFOUND THEN
        p_status := 1;
        p_ret_msg := 'No Task Found';
		CLOSE task_curs;
        RETURN;
      END IF;
    CLOSE task_curs;*/
    --
    dbms_output.put_line('task_rec.x_task2x_order_type:'||task_rec.x_task2x_order_type);
    --
    OPEN order_type_curs(NVL(p_order_type_objid,task_rec.x_task2x_order_type));
      FETCH order_type_curs INTO order_type_rec;
      IF order_type_curs%NOTFOUND THEN
        p_status := 2;
        p_ret_msg := 'No Order Type Found';
		CLOSE order_type_curs;
        RETURN;
      END IF;
    CLOSE order_type_curs;
    --
    dbms_output.put_line('order_type_rec.x_order_type:'||order_type_rec.x_order_type);
    dbms_output.put_line('order_type_rec.objid:'||order_type_rec.objid);
    dbms_output.put_line('task_rec.objid:'||task_rec.objid);
    --
    order_type    := sf_get_ig_order_type('SP_INSERT_IG_TRANSACTION' ,task_rec.objid ,order_type_rec.x_order_type);
    IF order_type IS NULL THEN
      p_status := 0;
      p_ret_msg := 'sf_get_ig_order_type call Failed';
      RETURN;
    END IF;
    dbms_output.put_line('order_type:'||order_type);
	dbms_output.put_line('x_order_type2x_carrier:'||order_type_rec.x_order_type2x_carrier);
   --
    OPEN carrier_curs(order_type_rec.x_order_type2x_carrier);
      FETCH carrier_curs INTO carrier_rec;
      IF carrier_curs%NOTFOUND THEN
        p_status := 3;
        p_ret_msg := 'carrier_curs Not Found';
		CLOSE carrier_curs;
        RETURN;
      END IF;
    CLOSE carrier_curs;
    dbms_output.put_line('carrier_rec.carrier2carrier_group:'||carrier_rec.carrier2carrier_group);
    --
    OPEN carrier_group_curs(carrier_rec.carrier2carrier_group);
      FETCH carrier_group_curs INTO carrier_group_rec;
      IF carrier_group_curs%NOTFOUND THEN
        p_status := 4;
		p_ret_msg := 'carrier_group_curs Not Found';
        CLOSE carrier_group_curs;
        RETURN;
      END IF;
    CLOSE carrier_group_curs;
    --
    dbms_output.put_line('carrier_group_rec.X_CARRIER_GROUP2X_PARENT:'||carrier_group_rec.X_CARRIER_GROUP2X_PARENT);
	OPEN parent_curs(carrier_group_rec.X_CARRIER_GROUP2X_PARENT);
      FETCH parent_curs INTO parent_rec;
      IF parent_curs%NOTFOUND THEN
        p_status := 5;
		p_ret_msg := 'parent_curs Not Found';
        CLOSE parent_curs;
        RETURN;
      END IF;
    CLOSE parent_curs;
    dbms_output.put_line('parent_rec.x_parent_name:'||parent_rec.x_parent_name);
    dbms_output.put_line('parent_rec.objid:'||parent_rec.objid);
	dbms_output.put_line('task_rec.x_task2x_call_trans:'||task_rec.x_task2x_call_trans);
    --
    OPEN call_trans_curs(task_rec.x_task2x_call_trans);
      FETCH call_trans_curs INTO call_trans_rec;
      IF call_trans_curs%NOTFOUND THEN
        p_status := 6;
		p_ret_msg := 'call_trans_curs Not Found';
        CLOSE call_trans_curs;
        RETURN;
      END IF;
    CLOSE call_trans_curs;
    dbms_output.put_line('call_trans_rec.X_CALL_TRANS2CARRIER:'||call_trans_rec.X_CALL_TRANS2CARRIER);
    dbms_output.put_line('call_trans_rec.x_action_type:'||call_trans_rec.x_action_type);
    dbms_output.put_line('call_trans_rec.ota_activation:'||call_trans_rec.ota_activation);
    dbms_output.put_line('call_trans_rec.call_trans2site_part:'||call_trans_rec.call_trans2site_part);
    --
    OPEN site_part_curs(call_trans_rec.call_trans2site_part);
      FETCH site_part_curs INTO site_part_rec;
      IF site_part_curs%NOTFOUND THEN
        p_status := 7;
		p_ret_msg := 'site_part_curs Not Found';
        CLOSE site_part_curs;
        RETURN;
      END IF;
    CLOSE site_part_curs;
    dbms_output.put_line('site_part_rec.x_min:'||site_part_rec.x_min);
    dbms_output.put_line('site_part_rec.x_service_id:'||site_part_rec.x_service_id);
    dbms_output.put_line('site_part_rec.x_pin:'||site_part_rec.x_pin);
	dbms_output.put_line('call_trans_rec.x_action_type:'||call_trans_rec.x_action_type);
    --
    IF call_trans_rec.x_action_type IN ('1' ,'2' ,'3') THEN
      OPEN old_min_curs(call_trans_rec.x_service_id);
        FETCH old_min_curs INTO old_min_rec;
        IF old_min_curs%NOTFOUND THEN
          dbms_output.put_line('old_min_curs%NOTFOUND');
        ELSE
          dbms_output.put_line('old_min_rec.x_min:'|| old_min_rec.x_min);
        END IF;
      CLOSE old_min_curs;
    END IF;
    --
     dbms_output.put_line('order_type:'||order_type);
	IF order_type IN ('EPIR', 'PIR') THEN                                      --'PIC' ,'EPIC',
      OPEN alt_min_curs(site_part_rec.x_service_id, order_type);
        FETCH alt_min_curs INTO alt_min_rec;
        IF alt_min_curs%NOTFOUND THEN
          dbms_output.put_line('alt_min_curs%NOTFOUND');
        ELSE
          IF alt_min_rec.min    IS NOT NULL AND order_type IN ('EPIR', 'PIR') THEN
            site_part_rec.x_min := alt_min_rec.min;
          END IF;
          IF alt_min_rec.pin IS NOT NULL AND order_type = 'EPIR' THEN
            dbms_output.put_line('change site_part_rec.x_pin:'||site_part_rec.x_pin);
            site_part_rec.x_pin := alt_min_rec.pin;
          END IF;
        END IF;
      CLOSE alt_min_curs;
      dbms_output.put_line('site_part_rec.x_min changed to:'|| alt_min_rec.min||' because of ordertype:'|| order_type_rec.x_order_type);
      dbms_output.put_line('order_type:'||order_type);
      dbms_output.put_line('alt_min_rec.s_title:'||alt_min_rec.s_title);
      dbms_output.put_line('alt_min_rec.first_name:'||alt_min_rec.first_name);
      dbms_output.put_line('alt_min_rec.last_name:'||alt_min_rec.last_name);
      dbms_output.put_line('alt_min_rec.account:'||alt_min_rec.account);
      dbms_output.put_line('alt_min_rec.add1:'||alt_min_rec.add1);
      dbms_output.put_line('alt_min_rec.add2:'||alt_min_rec.add2);
      dbms_output.put_line('alt_min_rec.pin:'||alt_min_rec.pin);
      dbms_output.put_line('alt_min_rec.zip:'||alt_min_rec.zip);
    END IF;
    --
    dbms_output.put_line('site_part_rec.site_part2part_info:'||site_part_rec.site_part2part_info);
    dbms_output.put_line('site_part_rec.n_part_inst2part_mod:'||site_part_rec.n_part_inst2part_mod);
    OPEN part_num_curs(NVL(site_part_rec.n_part_inst2part_mod,site_part_rec.site_part2part_info));
      FETCH part_num_curs INTO part_num_rec;
      IF part_num_curs%NOTFOUND THEN
        p_status := 9;
		p_ret_msg := 'part_num_curs Not Found';
        CLOSE part_num_curs;
        RETURN;
      END IF;
    CLOSE part_num_curs;
    dbms_output.put_line('site_part_rec.x_zipcode:'|| site_part_rec.x_zipcode );
	dbms_output.put_line('part_num_rec.org_id:'|| part_num_rec.org_id );
    --
    OPEN old_esn_curs(site_part_rec.x_service_id,part_num_rec.org_id);
      FETCH old_esn_curs INTO old_esn_rec;
      IF old_esn_curs%NOTFOUND THEN
        dbms_output.put_line('old_esn_curs%NOTFOUND');
      ELSE
        dbms_output.put_line('old_esn_rec.esn:'||old_esn_rec.esn);
      END IF;
    CLOSE old_esn_curs;
    --
    OPEN trans_profile_curs(order_type_rec.x_order_type2x_trans_profile,part_num_rec.x_technology);
      FETCH trans_profile_curs INTO trans_profile_rec;
      IF trans_profile_curs%NOTFOUND THEN
        p_status := 10;
		p_ret_msg := 'trans_profile_curs Not Found';
        CLOSE trans_profile_curs;
        RETURN;
      END IF;
    CLOSE trans_profile_curs;
    --
    dbms_output.put_line('part_num_rec.x_technology:'||part_num_rec.x_technology);
	dbms_output.put_line('parent_rec.x_parent_id:'||parent_rec.x_parent_id);
	dbms_output.put_line('carrier_rec.x_next_avail_carrier:'||carrier_rec.x_next_avail_carrier);
	dbms_output.put_line('site_part_rec.x_zipcode:'||site_part_rec.x_zipcode);
	dbms_output.put_line('parent_rec.x_next_available:'||NVL(parent_rec.x_next_available,0));
	IF part_num_rec.x_technology = 'GSM' AND parent_rec.x_parent_id IN ('6' ,'71' ,'76','1000000266') AND NVL(parent_rec.x_next_available,0) = 1
       AND carrier_rec.x_next_avail_carrier = 1 THEN
      dbms_output.put_line('cingular order_type');
      OPEN c_nap_rc(site_part_rec.x_zipcode );
        FETCH c_nap_rc INTO c_nap_rc_rec;
        IF c_nap_rc%notfound THEN
          dbms_output.put_line('NOT FOUND c_nap_rc:'||site_part_rec.x_zipcode);
        ELSE
          order_type_rec.x_ld_account_num := c_nap_rc_rec.account_num;
          order_type_rec.x_market_code    := c_nap_rc_rec.market_code;
          order_type_rec.x_dealer_code    := c_nap_rc_rec.dealer_code;
          trans_profile_rec.template      := c_nap_rc_rec.template;
        END IF;
      CLOSE c_nap_rc;
    END IF;
    --
    IF part_num_rec.org_id                                                  = 'TRACFONE' THEN
      IF sa.device_util_pkg.get_smartphone_fun(call_trans_rec.x_service_id) = 0 AND trans_profile_rec.template = 'RSS' THEN
        trans_profile_rec.template                                         := 'SUREPAY';
      END IF;
    END IF;
    --
	dbms_output.put_line('call_trans_rec.objid:'||call_trans_rec.objid);
    IF (order_type IN ('E' ,'PIR' ,'EPIR' ,'IPI') AND NVL(part_num_rec.STRAIGHT_TALK_flag,0) = 1)
	OR order_type IN ('AP' ,'PAP' ,'CR' ,'CRU' ,'EU' ,'PCR' ,'ACR' ,'DB')
	OR (order_type = 'A' AND trans_profile_rec.template = 'SUREPAY') THEN
      OPEN ld_curs(call_trans_rec.objid);
        FETCH ld_curs INTO ld_rec;
      CLOSE ld_curs;
    ELSE
      ld_rec.rsid := carrier_rec.x_ld_pic_code;
    END IF;
    dbms_output.put_line('ld_rec.rsid:'||ld_rec.rsid);
    dbms_output.put_line('ld_rec.x_value:'||ld_rec.x_value);
    dbms_output.put_line('carrier_rec.x_ld_pic_code:'||carrier_rec.x_ld_pic_code);
    --
    dbms_output.put_line('carrier_rec.objid:' || carrier_rec.objid);
    dbms_output.put_line('part_num_rec.x_technology:' || part_num_rec.x_technology);
    dbms_output.put_line('part_num_rec.data_speed:' || part_num_rec.data_speed);
    dbms_output.put_line('part_num_rec.bus_org_objid:' || part_num_rec.bus_org_objid);
    --
    dbms_output.put_line('order_type_rec.x_dealer_code:'||order_type_rec.x_dealer_code);
    dbms_output.put_line('part_num_rec.part_number:' || part_num_rec.part_number);
    dbms_output.put_line('part_num_rec.org_id:' || part_num_rec.org_id);
    dbms_output.put_line('part_num_rec.x_data_capable:' || part_num_rec.x_data_capable);
    --
    v_LANGUAGE:= sa.get_lang(task_rec.task_id);
    dbms_output.put_line  ('Language value for '||task_rec.task_id ||'is'|| v_LANGUAGE);
    --
    OPEN new_transaction_id_curs;
      FETCH new_transaction_id_curs INTO new_transaction_id_rec;
      IF new_transaction_id_curs%NOTFOUND THEN
        CLOSE new_transaction_id_curs;
        p_status := 11;
		p_ret_msg := 'new_transaction_id_curs Not Found';
        RETURN;
      END IF;
    CLOSE new_transaction_id_curs;
     if order_type not in ( 'RMHL', 'S', 'SI', 'SIMC', 'VD', 'VP', 'IPRL',  'I', 'IDD', 'E911', 'D', 'DI', 'APN', 'F') then
      OPEN carrier_features_curs1(carrier_rec.objid ,part_num_rec.x_technology ,part_num_rec.bus_org_objid ,part_num_rec.data_speed, order_type);
        FETCH carrier_features_curs1 INTO carr_feature_rec1;
        IF carrier_features_curs1%NOTFOUND THEN
          carr_feature_rec1.objid := NULL;
           p_status := 12;
		   p_ret_msg := 'carrier_features_curs1 Not Found';
        END IF;
      CLOSE carrier_features_curs1;
      --
      IF carr_feature_rec1.objid IS NULL THEN
        OPEN carrier_features_curs2(carrier_rec.objid ,part_num_rec.x_technology ,part_num_rec.bus_org_objid ,part_num_rec.data_speed, order_type);
          FETCH carrier_features_curs2 INTO carr_feature_rec1;
          IF carrier_features_curs2%NOTFOUND THEN
            carr_feature_rec1.objid := NULL;
            p_status := 13;
		    p_ret_msg := 'carrier_features_curs2 Not Found';
          END IF;
        CLOSE carrier_features_curs2;
      END IF;
      --
      IF carr_feature_rec1.objid IS NULL THEN
        dbms_output.put_line('carr_feature_rec1.objid:'||carr_feature_rec1.objid);
      END IF;
      --
      dbms_output.put_line('carr_features_rec1.col1:'||carr_feature_rec1.col1);
      dbms_output.put_line('pre sf_get_carr_feat:'|| carr_feature_rec1.objid);
      dbms_output.put_line('order_type:'||order_type);
      dbms_output.put_line('part_num_rec.STRAIGHT_TALK_flag:'|| part_num_rec.STRAIGHT_TALK_flag );
      dbms_output.put_line('call_trans_rec.call_trans2site_part:'||call_trans_rec.call_trans2site_part);
      dbms_output.put_line('call_trans_rec.x_service_id:'||call_trans_rec.x_service_id);
      dbms_output.put_line ('call_trans_rec.x_call_trans2carrier:'||call_trans_rec.x_call_trans2carrier);
      dbms_output.put_line('carr_feature_rec1.objid:'|| carr_feature_rec1.objid );
      dbms_output.put_line('part_num_rec.data_speed:'||part_num_rec.data_speed);
      dbms_output.put_line('trans_profile_rec.template:'|| trans_profile_rec.template );
      --
      l_carr_feat_objid := sf_get_carr_feat(order_type , --P_ORDER_TYPE
          part_num_rec.STRAIGHT_TALK_flag,                   --l_st_esn_count ,                                   --P_ST_ESN_FLAG
          call_trans_rec.call_trans2site_part ,              --P_SITE_PART_OBJID
          call_trans_rec.x_service_id ,                      --P_ESN
          call_trans_rec.x_call_trans2carrier ,              --P_CARRIER_OBJID
          null, --carr_feature_rec1.objid ,                          --P_CARR_FEATURE_OBJID
          part_num_rec.data_speed ,                          --P_DATA_CAPABLE
          trans_profile_rec.template ,                       --P_TEMPLATE
          NULL                                               --P_SERVICE_PLAN_ID
	  ,p_task_objid
          );
      dbms_output.put_line('post sf_get_carr_feat:'|| l_carr_feat_objid);
      IF l_carr_feat_objid IS NULL THEN
        p_status := 14;
		p_ret_msg := 'l_carr_feat_objid Not Found';
      END IF;
      --
      IF carr_feature_rec.non_ppe = 1 AND upper(parent_rec.x_parent_name) LIKE 'T_MOB%' AND order_type_rec.x_order_type = 'Credit' THEN
        tmo_flex_order_type      := sf_get_ig_order_type('TMO_FLEX' ,task_rec.objid ,order_type_rec.x_order_type);
        IF NVL(tmo_flex_order_type ,'NONE FOUND') IN ('CR','ACR','PCR') THEN
          order_type := tmo_flex_order_type;
        ELSE
          p_status := 15;
		  p_ret_msg := 'TMO Not Found';
        END IF;
      END IF;
      --
      OPEN carrier_features_curs (NVL(l_carr_feat_objid,NVL(carr_feature_rec1.objid,-100)));
        FETCH carrier_features_curs INTO carr_feature_rec;
        IF carrier_features_curs%notfound THEN
          CLOSE carrier_features_curs;
          p_status := 16;
		  p_ret_msg := 'carrier_features_curs Not Found';
          RETURN;
        END IF;
      CLOSE carrier_features_curs;
     --
	/*IF order_type IN ('E','A','PAP','AP','EU')	-- Activation related order types also used during upgrade
	THEN

		SA.PROMOTION_PKG.UPDATE_PROMO_HIST(call_trans_rec.x_service_id
				,lv_promo_error_code
				,lv_promo_error_msg
				);
	END IF;*/


      --- get data saver information from the new procedure
      get_data_saver_information ( i_esn                      => site_part_rec.x_service_id ,
                                   i_carrier_features_objid   => carr_feature_rec.objid   ,
                                   o_data_saver_flag          => lv_data_saver,
                                   o_data_saver_code          => lv_data_saver_code );


     --
      IF order_type='R' AND call_trans_rec.x_action_type = '6' AND part_num_rec.org_id != 'NET10' THEN
        OPEN same_rate_plan_curs(call_trans_rec.objid);
          FETCH same_rate_plan_curs INTO same_rate_plan_rec;
          IF same_rate_plan_curs%found AND carr_feature_rec.x_rate_plan = same_rate_plan_rec.rate_plan THEN
            CLOSE same_rate_plan_curs;
            p_status := 16;
		    p_ret_msg := 'same_rate_plan_curs  Found';
            RETURN;
          END IF;
        CLOSE same_rate_plan_curs;
      END IF;
      --

    end if;
    IF order_type ='E911' THEN
      carr_feature_rec.digital_feature      := 'Y';
      carr_feature_rec.digital_feature_code := 'WFC';
    END IF;
    --
	-- Getting PRL_NUMBER for IG to ATT
	BEGIN
	SELECT prl_number
      INTO l_prl_number
	  FROM gw1.ig_transaction ig
	 WHERE esn        = p_esn
	   AND order_type = p_order_type
	   AND action_item_id = (SELECT MAX(action_item_id)
	                           FROM gw1.ig_transaction ig1
							  WHERE ig1.esn        = ig.esn
                                AND ig1.order_type = ig.order_type
							 );
	EXCEPTION
	WHEN OTHERS THEN
	l_prl_number := NULL;
	END;
	-- Getting Billing Submarket and Billing market values .
	BEGIN
		SELECT mkt,submarketid
		  INTO l_bil_mkt,l_bil_sub_mkt
		  FROM sa.x_cingular_mrkt_info
		 WHERE zip   = site_part_rec.x_zipcode  ;
	EXCEPTION
	WHEN OTHERS THEN
		l_bil_mkt := NULL;
		l_bil_sub_mkt := NULL;
	END;
	--
    OPEN o_ig_rec FOR
    SELECT
            new_transaction_id_rec.transaction_id            TRANSACTION_ID,
            task_rec.task_id                                 ACTION_ITEM_ID ,
            trans_profile_rec.objid                          TRANS_PROF_KEY ,
            carrier_rec.x_carrier_id                         CARRIER_ID ,
            carrier_rec.x_state                              STATE_FIELD ,
            order_type                                       ORDER_TYPE ,
            old_min_rec.x_min                                OLD_MIN ,
            site_part_rec.x_min                              MIN ,
            get_msid_value(i_order_type => order_type, i_esn => site_part_rec.x_service_id, i_min => site_part_rec.x_min) MSID ,
            site_part_rec.x_zipcode                          ZIP_CODE ,
            site_part_rec.iccid                              ICCID ,
            site_part_rec.x_service_id                       ESN ,
            sa.igate.f_get_hex_esn(site_part_rec.x_service_id) ESN_HEX ,
            old_esn_rec.esn                                  OLD_ESN ,
            sa.igate.f_get_hex_esn( old_esn_rec.esn)         OLD_ESN_HEX ,
            order_type_rec.x_ld_account_num                  ACCOUNT_NUM ,
            order_type_rec.x_market_code                     MARKET_CODE ,
            order_type_rec.x_dealer_code                     DEALER_CODE ,
            trans_profile_rec.template                       TEMPLATE ,
            trans_profile_rec.transmit_method                TRANSMISSION_METHOD ,
            trans_profile_rec.fax_number                     FAX_NUM ,
            trans_profile_rec.fax_num2                       FAX_NUM2 ,
            trans_profile_rec.online_number                  ONLINE_NUM ,
            trans_profile_rec.online_num2                    ONLINE_NUM2 ,
            trans_profile_rec.email                          EMAIL ,
            trans_profile_rec.network_login                  NETWORK_LOGIN ,
            trans_profile_rec.network_password               NETWORK_PASSWORD ,
            trans_profile_rec.system_login                   SYSTEM_LOGIN ,
            trans_profile_rec.system_password                SYSTEM_PASSWORD ,
            trans_profile_rec.batch_delay_max                FAX_BATCH_SIZE ,
            trans_profile_rec.batch_quantity                 FAX_BATCH_Q_TIME ,
            carr_feature_rec.voice_mail                      VOICE_MAIL ,
            carr_feature_rec.voice_mail_package              VOICE_MAIL_PACKAGE ,
            carr_feature_rec.caller_id                       CALLER_ID ,
            carr_feature_rec.caller_id_package               CALLER_ID_PACKAGE ,
            carr_feature_rec.call_waiting                    CALL_WAITING ,
            carr_feature_rec.call_waiting_package            CALL_WAITING_PACKAGE ,
            carr_feature_rec.sms                             SMS ,
            carr_feature_rec.sms_package                     SMS_PACKAGE ,
            carr_feature_rec.digital_feature                 DIGITAL_FEATURE ,
            carr_feature_rec.digital_feature_code            DIGITAL_FEATURE_CODE ,
            carr_feature_rec.mpn                             X_MPN,
            carr_feature_rec.mpn_code                        X_MPN_CODE,
            carr_feature_rec.pool_name                       X_POOL_NAME,
            carr_feature_rec.x_rate_plan                     RATE_PLAN ,
            call_trans_rec.x_call_trans2user                 RATE_PLAN ,
            site_part_rec.x_pin                              PIN,
            part_num_rec.x_manufacturer                      PHONE_MANF ,
            SUBSTR(part_num_rec.x_technology ,1 ,1)          TECHNOLOGY_FLAG ,
            task_rec.x_expedite                              EXPIDITE ,
            ld_rec.rsid                                      LD_PROVIDER ,
            NULL                                             TUX_ITI_SERVER ,
            'Y'                                              Q_TRANSACTION,
            'Queued'                                         COM_PORT ,
            'Q'                                              STATUS ,
            NULL                                             STATUS_MESSAGE ,
            call_trans_rec.ota_activation                    OTA_TYPE ,
            c_nap_rc_rec.rc_number                           RATE_CENTER_NO ,
            p_application_system                             APPLICATION_SYSTEM ,
            ld_rec.x_value                                   BALANCE,
	        v_LANGUAGE                                       LANGUAGE,
	        lv_data_saver                                    DATA_SAVER,
	        lv_data_saver_code                               DATA_SAVER_CODE,
            carr_feature_rec.objid                           CARRIER_FEATURE_OBJID,
            l_prl_number                                     PRL_NUMBER,
            l_bil_mkt                                        BILL_MKT,
            l_bil_sub_mkt 			                         BILL_SUB_MKT
          FROM DUAL;
         dbms_output.put_line('carr_feature_rec.objid  :' ||carr_feature_rec.objid );
    -- if derivation was created successfully
      p_status := 0;
	  p_ret_msg := 'Success';

exception when others then
        p_status  := -1;
		p_ret_msg := 'Exception :'||SQLERRM;

END sp_get_ig_values;

  --CR52120 changes start
  FUNCTION  get_ig_features ( i_profile_id IN  NUMBER ) RETURN  ig_transaction_features_tab
  IS
    igf  ig_transaction_features_tab := ig_transaction_features_tab();
  BEGIN
    SELECT ig_transaction_features_type ( NULL,             --transaction_features_objid
                                          NULL,             --transaction_id
                                          cc.feature_name,  --feature_name
                                          cc.feature_value, --feature_value
                                          NULL,             --feature_requirement
                                          NULL,             --throttle_status_code
                                          NULL,             --toggle_flag
                                          NULL,             --response
                                          NULL,             --display_sui_flag
                                          NULL,             --restrict_sui_flag
                                          cc.profile_id     --cf_profile_id
                                        )
    BULK COLLECT
    INTO   igf
    FROM   x_rp_extension_config cc
    WHERE  1 = 1
    AND    cc.profile_id  = i_profile_id
    AND    cc.toggle_flag = 'Y';

    RETURN (igf);
  EXCEPTION
    WHEN others THEN
      DBMS_OUTPUT.PUT_LINE ( 'get_ig_transaction_features : ' || SQLERRM );
      RETURN NULL;
  END get_ig_features;
  --CR52120 changes end
END igate;
/