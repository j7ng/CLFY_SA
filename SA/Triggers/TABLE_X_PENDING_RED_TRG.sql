CREATE OR REPLACE TRIGGER sa.TABLE_X_PENDING_RED_TRG
	AFTER INSERT OR DELETE OR UPDATE
	OF REDEEM_IN2CALL_TRANS, X_GRANTED_FROM2X_CALL_TRANS
	ON sa.TABLE_X_PENDING_REDEMPTION 	REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO X_PENDING_REDEMPTION_DET
			(pend_red_det2pend_red,
			pend_red2x_promotion,
			x_pend_red2site_part,
			x_pend_type,
			pend_redemption2esn,
			x_case_id,
			x_granted_from2x_call_trans,
			redeem_in2call_trans,
			process_flag,
			PEND_RED2PROG_PURCH_HDR)
		values
			(:new.objid,
			:new.pend_red2x_promotion,
			:new.x_pend_red2site_part,
			:new.x_pend_type,
			:new.pend_redemption2esn,
			:new.x_case_id,
			:new.x_granted_from2x_call_trans,
			:new.redeem_in2call_trans,
			'I',
			:new.PEND_RED2PROG_PURCH_HDR);
	ELSIF DELETING then
		INSERT INTO X_PENDING_REDEMPTION_DET
			(pend_red_det2pend_red,
			pend_red2x_promotion,
			x_pend_red2site_part,
			x_pend_type,
			pend_redemption2esn,
			x_case_id,
			x_granted_from2x_call_trans,
			redeem_in2call_trans,
			process_flag,
			PEND_RED2PROG_PURCH_HDR)
		values
			(:old.objid,
			:old.pend_red2x_promotion,
			:old.x_pend_red2site_part,
			:old.x_pend_type,
			:old.pend_redemption2esn,
			:old.x_case_id,
			:old.x_granted_from2x_call_trans,
			:old.redeem_in2call_trans,
			'D',
			:old.PEND_RED2PROG_PURCH_HDR);
	ELSIF UPDATING then
		INSERT INTO X_PENDING_REDEMPTION_DET
			(pend_red_det2pend_red,
			pend_red2x_promotion,
			x_pend_red2site_part,
			x_pend_type,
			pend_redemption2esn,
			x_case_id,
			x_granted_from2x_call_trans,
			redeem_in2call_trans,
			process_flag,
			PEND_RED2PROG_PURCH_HDR)
		values
			(:old.objid,
			:old.pend_red2x_promotion,
			:old.x_pend_red2site_part,
			:old.x_pend_type,
			:old.pend_redemption2esn,
			:old.x_case_id,
			:new.x_granted_from2x_call_trans,
			:new.redeem_in2call_trans,
			'U',
			:old.PEND_RED2PROG_PURCH_HDR);
	END IF;
END;
/