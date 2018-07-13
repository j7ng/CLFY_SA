CREATE OR REPLACE PROCEDURE sa.INVALID_ROAD_RED_PRC IS
/******************************************************************************/
/* Copyright (R) 2002 Tracfone Wireless Inc. All rights reserved              */
/*                                                                            */
/* Name         :   Invalid_Road_Red_prc                                      */
/* Purpose      :   This procedure inserts roadside cards that were redeemed  */
/*                  with no assiged retailer into the invalid_road_red table  */
/*                                                                            */
/* Parameters   :   NONE                                                      */
/* Platforms    :   Oracle 8.0.6 AND newer versions                           */
/* Author      :   Miguel Leon                                                */
/* Revisions	:                                                             */
/* Version  Date       Who       Purpose                                      */
/* ------   --------   -------   -------------------------------------------- */
/* 1.0      02/18/02   Mleon     Initial Revision                             */
/*                                                                            */
/******************************************************************************/


 CURSOR invalid_red_cur IS
    SELECT rf.*
	 FROM x_road_ftp rf,
	      table_site ts,
		  table_inv_bin ib,
		  table_x_road_inst ri
	 WHERE
	     rf.trans_type = 'N'  --- only looking for activations
     AND ri.PART_SERIAL_NO = rf.PART_SERIAL_NO
	 AND ri.X_PART_INST_STATUS = '41'
	-- AND rf.ROAD_DEALER_OBJID = ts.objid
	 AND ri.road_inst2inv_bin = ri.objid
	 AND ib.BIN_NAME = ts.site_id
	 AND ts.site_type || '' in ('DIST','MANF')
	 AND ts.type = 3;

/* EXPLAIN PLAN
SELECT STATEMENT    [RULE] Cost=0 Rows=0 Bytes=0
  NESTED LOOPS
    NESTED LOOPS
      TABLE ACCESS BY INDEX ROWID TABLE_SITE
        INDEX RANGE SCAN IND_TYPE
      TABLE ACCESS BY INDEX ROWID TABLE_X_ROAD_INST
        INDEX RANGE SCAN TABLE_X_ROAD_INST_IDX_N2
    TABLE ACCESS BY INDEX ROWID X_ROAD_FTP
      INDEX RANGE SCAN X_ROAD_FTP_IDX_N2
*/


 v_serial_num VARCHAR2(30) := NULL;
 v_action VARCHAR2(200) := NULL;
 v_procedure_name CONSTANT  VARCHAR2(30) := 'INVALID_ROAD_RED_PRC';

BEGIN

 FOR invalid_red_rec IN  invalid_red_cur LOOP

  v_serial_num := invalid_red_rec.part_serial_no;

  BEGIN
     v_action := 'Inserting in invalid_road_ftp';

	    INSERT INTO sa.X_ROAD_INVALID_REDEMPTION
		VALUES(
invalid_red_rec.OBJID,
invalid_red_rec.SERVICE_ID,
invalid_red_rec.PART_SERIAL_NO,
invalid_red_rec.PROGRAM_NAME,
invalid_red_rec.FIRST_NAME,
invalid_red_rec.LAST_NAME,
invalid_red_rec.ADDRESS_1,
invalid_red_rec.ADDRESS_2,
invalid_red_rec.CITY,
invalid_red_rec.STATE,
invalid_red_rec.ZIPCODE,
invalid_red_rec.PHONE,
invalid_red_rec.E_MAIL,
invalid_red_rec.INFO_REQD,
invalid_red_rec.TRANS_TYPE,
invalid_red_rec.ACTIVATION_DATE,
invalid_red_rec.SERVICE_START_DATE,
invalid_red_rec.SERVICE_END_DATE,
invalid_red_rec.DEACTIVATION_DATE,
invalid_red_rec.DEACT_REASON,
invalid_red_rec.TERM,
invalid_red_rec.WHOLESALE_COST,
invalid_red_rec.CARD_PLAN,
invalid_red_rec.CARD_TYPE,
invalid_red_rec.WHOLESALE_REFUND,
invalid_red_rec.CUSTOMER_REFUND,
invalid_red_rec.REFUND_PERCENT,
invalid_red_rec.FTP_CREATE_STATUS,
invalid_red_rec.FTP_CREATE_DATE,
invalid_red_rec.ORAFIN_POST,
invalid_red_rec.DEP1_FIRST_NAME,
invalid_red_rec.DEP1_LAST_NAME,
invalid_red_rec.DEP2_FIRST_NAME,
invalid_red_rec.DEP2_LAST_NAME,
invalid_red_rec.DEP3_FIRST_NAME,
invalid_red_rec.DEP3_LAST_NAME,
invalid_red_rec.DEP4_FIRST_NAME,
invalid_red_rec.DEP4_LAST_NAME,
invalid_red_rec.DEPENDENT_COUNT,
invalid_red_rec.PROMO_OBJID,
invalid_red_rec.PROMO_CODE,
invalid_red_rec.CALL_TRANS_OBJID,
invalid_red_rec.SOURCESYSTEM,
invalid_red_rec.ROAD_DEALER_OBJID,
invalid_red_rec.ROAD_DEALER_ID,
invalid_red_rec.ROAD_DEALER_NAME,
invalid_red_rec.ROAD_PART_NUM_OBJID,
invalid_red_rec.ROAD_PART_NUMBER,
invalid_red_rec.ROAD_PART_DESCRIPTION,
invalid_red_rec.ROAD_PART_RETAILCOST,
invalid_red_rec.USER_OBJID,
invalid_red_rec.USER_LOGIN_NAME,
invalid_red_rec.USER_FIRST_NAME,
invalid_red_rec.USER_LAST_NAME,
'N',
NULL,
invalid_red_rec.LAST_UPDATE_DATE,
invalid_red_rec.LAST_UPDATED_BY) ; -- validated date





  EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN

         /** Expecting to hit duplicate values          **/
         /** Reason :redemptions might be invalid       **/
         /** for a long time ( dealer id might still be **/
         /** DIST and MANF type ) NOT UPDATED           **/
            NULL;

     WHEN OTHERS THEN
	       Toss_Util_Pkg.insert_error_tab_proc (
         'Inner Block:'||v_action,
         v_serial_num,
         v_procedure_name
      );
      COMMIT;


  END;

  COMMIT;

 END LOOP;

EXCEPTION

    WHEN OTHERS THEN
      Toss_Util_Pkg.insert_error_tab_proc (
         v_action,
         v_serial_num,
         v_procedure_name
      );
      COMMIT;


END;
/