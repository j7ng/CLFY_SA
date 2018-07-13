CREATE OR REPLACE PACKAGE BODY sa."OTA_SEND_LAST_ACK_SPEC_PKG" IS

	/************************************************************************************************|
	|    Copyright   Tracfone  Wireless Inc. All rights reserved
	|
	| NAME     :       OTA_SEND_LAST_ACK_SPEC_PKG  package
	| PURPOSE  :
	| FREQUENCY:
	| PLATFORMS:
	|
	| REVISIONS:
	| VERSION  DATE        WHO              PURPOSE
	| -------  ---------- -----             ------------------------------------------------------
	| 1.0      03/11/05   Novak Lalovic     Initial revision
	|          03/23/05   Novak Lalovic     Added procedure get_resend_psms_codes
	|          03/24/05   Novak Lalovic     Added copyright and revision version info to this file
	| 1.1      06/13/05   Novak Lalovic     Modified:
	|                                       Procedure get_resend_psms_codes was changed to allow
	|                                       redemption PSMS messages to be resent to the phones
	| 1.2      07/18/05   Novak Lalovic     Modified procedure get_resend_psms_codes:
	|                                       The query was changed to not look into the table TABLE_X_OTA_TRANS_DTL
	|                                       anymore to see if the inquiry to get the last acknowledgment code
	|                                       was sent to the phone.
	|                                       The following condition was removed from the cursor's where clause,
	|                                       and everything else remained the same:
	|                                       AND	EXISTS
	|                                      (SELECT   1
       |                                       FROM     TABLE_X_OTA_TRANS_DTL otd_ack
       |                                       WHERE	otd_ack.X_SENT_DATE   < SYSDATE - ( .000694444 * p_time_period_in )
       |                                       AND	otd_ack.X_RECEIVED_DATE IS NULL
       |                                       AND	otd_ack.x_action_type = ota_util_pkg.OTA_SEND_LAST_ACK
       |                                       AND	otd_ack.x_ota_trans_dtl2x_ota_trans = ot.objid)
       |          07/18/05   Novak Lalovic     Modified procedure get_ota_pending_trans:
       |                                       Because we are not sending the inquries to the phones anymore in order to
       |                                       get the last acknowledgment code, I modified this procedure to return all
       |                                       pending transactions regardles of the last acknowledgment inquiry.
       |                                       The following condition was removed from the cursor's where clause
       |                                       and everything else remained the same:
       |                                       AND      NOT EXISTS
       |                                      (SELECT   1
       |                                       FROM     TABLE_X_OTA_TRANS_DTL otd_ack
       |                                       WHERE    otd_ack.x_ota_trans_dtl2x_ota_trans = ot.objid
       |                                       AND      otd_ack.x_action_type = ota_util_pkg.OTA_SEND_LAST_ACK)
       | 1.3      07/28/05   Novak Lalovic     Modified procedure get_resend_psms_codes:
       |                                       Added the following condition to the query to filter out
       |                                       the ota trans detail records that we just sent:
       |                                       AND    otd.X_SENT_DATE < SYSDATE - ( .000694444 * p_time_period_in )
       | 1.4      09/30/05   Novak Lalovic     Modified procedure get_resend_psms_codes for change record CR4582:
       |                                       In order to resend any PSP messages to the phone - not only
       |                                       the activations and redemptions we modified the where
       |                                       clause of cursor p_query_results_out
       |                                       Replaced the following conditions:
       |			                   AND otd.X_ACTION_TYPE IN ( ota_util_pkg.OTA_ACTIVATION
       |                                                                 , ota_util_pkg.OTA_REDEMPTION )
       |                                       AND otd.X_OTA_TRANS_DTL2X_OTA_TRANS = ot.OBJID
       |                                       With this condition:
	|		                          AND otd.OBJID = ( SELECT MIN(otd2.objid)
       |                                                          FROM   TABLE_X_OTA_TRANS_DTL otd2
       |                                                          WHERE  otd2.X_OTA_TRANS_DTL2X_OTA_TRANS = ot.OBJID )
       | 1.5       12/06/07   Joseph Amalraj    Changed cursor p_query_results_out get_resend_psms_codes procedure
        |                                       added ordered hint and changed order of the tables in the query
	|************************************************************************************************/

	/******************************************************************
	| Refer to package spec for detailed description of this procedure|
	******************************************************************/
	PROCEDURE get_ota_pending_trans  (p_action_type_in		IN VARCHAR2
					, p_time_period_in		IN NUMBER -- number of minutes
					, p_query_results_out	OUT 	ota_extproc_pkg.REF_CUR_TYPE) IS

	BEGIN

		/*
		|  Get ALL OTA Pending transactions FOR the specified action TYPE (activation, redemption...)
		|  that are older then the specified time period (60 minutes is default in CBO program)
		*/

		OPEN p_query_results_out FOR
			SELECT OT.OBJID  ot_objid
			     , OTD.OBJID otd_objid
			     , OT.X_MIN
			     , OT.X_ESN
			     , OT.X_COUNTER
			     , PI.X_SEQUENCE
			     , PN.X_DLL
			     , OTA_EXTPROC_PKG.get_last_sent_ack_func(ot.X_ESN			-- ESN
			     					    , 3 			-- Technology
				  				    , pi.X_SEQUENCE		-- Phone sequence
				  				    , 'Y'			-- SEND LAST ACK flag
				  				    , pn.X_DLL) last_sent_ack	-- Phone DLL number
			FROM TABLE_X_OTA_TRANS_DTL	otd
			    ,TABLE_PART_NUM		pn
			    ,TABLE_MOD_LEVEL		ml
			    ,TABLE_PART_INST		pi
			    ,TABLE_X_OTA_TRANSACTION	ot
			WHERE otd.X_SENT_DATE < SYSDATE - ( .000694444 * p_time_period_in ) -- p_time_period_in is in minutes
			AND ot.objid = otd.x_ota_trans_dtl2x_ota_trans
			AND pn.objid = ml.part_info2part_num
			AND ml.objid = pi.n_part_inst2part_mod
			AND pi.x_domain = 'PHONES'
			AND pi.part_serial_no = ot.x_esn
			AND ot.x_status = 'OTA PENDING'
			AND ot.x_action_type LIKE NVL(p_action_type_in, '%'); -- to use index

		-- .000694444 = (1/24)/60 = 1 minute

		/*
		|  IMPORTANT: CURSOR p_query_results_out must be closed in the calling program
		|	      or we will eventually get too many cursors opened error
		*/

	EXCEPTION
		WHEN OTHERS THEN
			ota_util_pkg.ERR_LOG
				(p_action 	=> 'Getting the OTA pending transactions'
				,p_program_name => 'OTA_SEND_LAST_ACK_SPEC_PKG.get_ota_pending_trans'
			  	,p_error_text 	=> SQLERRM);
			RAISE_APPLICATION_ERROR(-20002, 'Procedure failed with error: '||SQLERRM);

	END get_ota_pending_trans;

	/******************************************************************
	| Refer to package spec for detailed description of this procedure|
	******************************************************************/
	PROCEDURE get_resend_psms_codes  (p_action_type_in             IN VARCHAR2
                                       , p_time_period_in             IN NUMBER -- number of minutes
                                       , p_query_results_out         OUT ota_extproc_pkg.REF_CUR_TYPE) IS

	BEGIN

		/*
		|  Get ALL PSMS codes that need to be resent to the phones FOR the specified
		|  action TYPE (activation, redemption...)
		|  The transactions are older then the specified time period (this is determined in the CBO program)
		*/

		OPEN p_query_results_out FOR
			SELECT /*+ ordered */ ot.OBJID		         ot_objid
			      , otd.OBJID	                otd_objid
			      , ot.X_MIN
			      , ot.X_ESN
			      , ot.X_COUNTER
			      , pi.X_SEQUENCE
			      , pn.X_DLL
			      , otd.X_PSMS_TEXT
			FROM 	TABLE_X_OTA_TRANSACTION	   ot
				,TABLE_X_OTA_TRANS_DTL	   otd
				,TABLE_PART_INST 	 	   pi
			        ,TABLE_MOD_LEVEL		   ml
				,TABLE_PART_NUM		   pn
			WHERE  otd.X_RESENT_DATE              IS NULL
			AND	otd.X_RECEIVED_DATE            IS NULL
			AND	otd.OBJID                       = ( SELECT MIN(otd2.objid)
			                                           FROM   TABLE_X_OTA_TRANS_DTL otd2
			                                           WHERE  otd2.X_OTA_TRANS_DTL2X_OTA_TRANS = ot.OBJID )
			AND    otd.X_SENT_DATE                 < SYSDATE - ( .000694444 * p_time_period_in )
			AND	pn.OBJID                        = ml.PART_INFO2PART_NUM
			AND	ml.OBJID                        = pi.N_PART_INST2PART_MOD
			AND	pi.X_DOMAIN                     = 'PHONES'
			AND	pi.PART_SERIAL_NO               = ot.X_ESN
			AND    (ot.X_ACTION_TYPE LIKE p_action_type_in or p_action_type_in IS NULL)
			AND	ot.X_STATUS                     = 'OTA PENDING';

		-- .000694444 = (1/24)/60 = 1 minute

		/*
		|  IMPORTANT: CURSOR p_query_results_out must be closed in the calling program
		|	      or we will eventually get too many cursors opened error
		*/

	EXCEPTION
		WHEN OTHERS THEN
			ota_util_pkg.ERR_LOG
				(p_action 	=> 'Getting the OTA PSMS text to be resent to the phones'
				,p_program_name => 'OTA_SEND_LAST_ACK_SPEC_PKG.get_resend_psms_codes'
			  	,p_error_text 	=> SQLERRM);
			RAISE_APPLICATION_ERROR(-20002, 'Procedure failed with error: '||SQLERRM);

	END get_resend_psms_codes;


END;
/