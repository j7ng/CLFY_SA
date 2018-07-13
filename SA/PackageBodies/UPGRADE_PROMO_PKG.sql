CREATE OR REPLACE PACKAGE BODY sa.UPGRADE_PROMO_PKG
IS
 --********************************************************************************
 --$RCSfile: UPGRADE_PROMO_PKG_PKB.sql,v $
 --$Revision: 1.13 $
 --$Author: mshah $
 --$Date: 2017/11/29 23:36:17 $
 --$ $Log: UPGRADE_PROMO_PKG_PKB.sql,v $
 --$ Revision 1.13  2017/11/29 23:36:17  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.12  2017/11/29 02:02:18  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.11  2017/11/27 23:07:47  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.10  2017/11/27 14:53:39  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.9  2017/11/27 14:22:17  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.8  2017/11/21 19:20:41  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.7  2017/11/13 20:30:40  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.6  2017/11/09 22:20:13  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.5  2015/10/21 21:16:43  skota
 --$ chnages for CR37795
 --$
 --$ Revision 1.4  2015/10/16 20:47:06  skota
 --$ modified the error messages
 --$
 --$ Revision 1.3  2015/10/13 22:24:28  skota
 --$ modified
 --$
 --$ Revision 1.2  2015/10/05 19:29:36  skota
 --$ modified
 --$
 --********************************************************************************
/* ***************************************************************************/
/* Copyright Tracfone Wireless Inc. All rights reserved                      */
/*                                                                           */
/* Name         :   UPGRADE_PROMO_PKG                                      */
/* Purpose      :   Initial development for giving promotions for TRACFONE                                                        */
/*                  Upgrade Promotion for 2G to 3G and returning the         */
/*                  promotion units/access days                              */
/*                                                                           */
/* Version  Date      Who      Purpose                                       */
/* -------  --------  -------  ----------------------------------------------*/
/* 1.0     08/14/2015 Srini Kota    Initial revision                         */
/* ***************************************************************************/

v_package_name CONSTANT VARCHAR2 (80) := 'UPGRADE_PROMO_PKG.';


/* *************************************************************************/
/* Procedure Name:     SP_TF_UPGRADE_PROMO
/* Description   :     TRACFONE UPGRADE promotion for 2G TO 3G
                       PPE TO PPE
					   PPE TO NON PPE
/**************************************************************************/
PROCEDURE SP_TF_UPGRADE_PROMO (
		 ip_from_esn           IN VARCHAR2,
		 ip_to_esn             IN VARCHAR2,
		 op_units		      OUT NUMBER,
		 op_days              OUT NUMBER,
		 op_error_code        OUT NUMBER,
		 op_error_msg         OUT VARCHAR2
	    )
IS

   v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name||'SP_TF_UPGRADE_PROMO';
   V_SAFELINK       NUMBER := 0;
    CURSOR cur_from_esn_detail (p_esn VARCHAR2) IS
      SELECT  pi.part_serial_no,
	          pi.x_part_inst_status,
			  pn.x_technology,
			  pi.objid,
              bo.org_id
        FROM table_part_inst pi
            ,table_mod_level ml
            ,table_part_num  pn
            ,table_bus_org   bo
       WHERE 1 = 1
         AND part_serial_no = p_esn
         and  x_part_inst_status = '52'  --for active from_esn only
         AND ml.objid = pi.n_part_inst2part_mod
         AND pn.objid = ml.part_info2part_num
         AND bo.objid = pn.part_num2bus_org;

    rec_from_esn_detail cur_from_esn_detail%ROWTYPE;

      CURSOR cur_to_esn_detail (p_esn VARCHAR2) IS
      SELECT  pi.part_serial_no,
	          pi.x_part_inst_status,
			  pn.x_technology,
			  pi.objid,
              bo.org_id
        FROM table_part_inst pi
            ,table_mod_level ml
            ,table_part_num  pn
            ,table_bus_org   bo
       WHERE 1 = 1
         AND part_serial_no = p_esn
         --and  x_part_inst_status = '52'
         AND ml.objid = pi.n_part_inst2part_mod
         AND pn.objid = ml.part_info2part_num
         AND bo.objid = pn.part_num2bus_org;

    rec_to_esn_detail cur_to_esn_detail%ROWTYPE;

    CURSOR cur_eligible_promo IS
       SELECT p.objid,p.x_promo_code, p.X_UNITS, p.x_access_days
            ,p.x_promo_type
        FROM table_x_group2esn grp2esn
            ,table_x_promotion      p
            , table_part_inst pi
         WHERE 1 = 1
         AND grp2esn.groupesn2part_inst = PI.OBJID
         AND pi.PART_SERIAL_NO = ip_from_esn
         AND p.objid = grp2esn.GROUPESN2X_PROMOTION
		 AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
		 AND SYSDATE BETWEEN grp2esn.x_start_date AND grp2esn.x_end_date
         AND X_PROMO_TYPE = 'Upgrade'; -- returning units for upgrade promo only
    rec_eligible_promo cur_eligible_promo%ROWTYPE;

	CURSOR CUR_UPG_PHONE_GEN IS
   select ppv.PARAM_VALUE
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_part_class pc ,
      table_bus_org bo,
      PC_PARAMS_VIEW PPV
    WHERE 1                     = 1
    AND pi.part_serial_no       = ip_to_esn
    AND pi.x_domain             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.part_num2part_class  = pc.objid
    AND pn.part_num2bus_org     = bo.objid
    and ppv.part_class = pc.name
    and PPV.PARAM_NAME ='PHONE_GEN';

	REC_UPG_PHONE_GEN CUR_UPG_PHONE_GEN%ROWTYPE;

	CURSOR CUR_2GPROMO_HIST
	IS SELECT * FROM sa.X_2GPROMO_HIST_FLAG WHERE X_ESN = ip_from_esn;

	REC_2GPROMO_HIST CUR_2GPROMO_HIST%ROWTYPE;
	v_error_message   varchar2(1000);
	--l_table_site_objid VARCHAR2(20);
	l_part_inst_objid  VARCHAR2(20);
	l_cnt              NUMBER(10);
    --Exception variables
	no_data_excep EXCEPTION;
	error_excep   EXCEPTION;

BEGIN
   op_units := 0;
   op_days  := 0;

-- check if 3x exists starts
   sa.UPGRADE_PROMO_PKG.transfer_3x_promo(ip_from_esn, ip_to_esn, op_error_code, op_error_msg);
-- check if 3x exists ends

	    -- Active ip_from_esn Validation.
     OPEN cur_from_esn_detail (ip_from_esn);
    FETCH cur_from_esn_detail
      INTO rec_from_esn_detail;
    IF cur_from_esn_detail%NOTFOUND THEN
	  op_error_code := '2';
	  op_error_msg  := 'FROM ESN not found';
     dbms_output.put_line('Invalid ESN');
      CLOSE cur_from_esn_detail;
      RETURN;
	ELSE
	  OPEN CUR_2GPROMO_HIST;
	  FETCH CUR_2GPROMO_HIST
         INTO REC_2GPROMO_HIST;
	  IF CUR_2GPROMO_HIST%FOUND THEN
		 op_error_code := '6';
		 op_error_msg  := 'Upgrade promo utilized already';
		 dbms_output.put_line('Upgrade promo utilized already');
		 CLOSE CUR_2GPROMO_HIST;
		 CLOSE cur_from_esn_detail;
		 RETURN;
	  END IF;
    END IF;
    CLOSE CUR_2GPROMO_HIST;
    CLOSE cur_from_esn_detail;


	-- checking to_esn validation and  generation like 2G or 3G
	Open cur_to_esn_detail(ip_to_esn);
	FETCH cur_to_esn_detail INTO rec_to_esn_detail;
		IF cur_to_esn_detail%NOTFOUND THEN
			op_error_code := '3';
			op_error_msg  := 'TO_ESN not found';
			dbms_output.put_line('Upgrade ESN info not found');
			CLOSE cur_to_esn_detail;
			RETURN;
		ELSE
		  OPEN CUR_UPG_PHONE_GEN;
		  fetch CUR_UPG_PHONE_GEN into rec_UPG_PHONE_GEN;
			IF CUR_UPG_PHONE_GEN%NOTFOUND THEN
				op_error_code := '3';
				op_error_msg  := 'TO_ESN not found';
		        dbms_output.put_line ('The upgrade phone info not found');
				CLOSE CUR_UPG_PHONE_GEN;
				CLOSE cur_to_esn_detail;
		        RETURN;
	        ELSE
	             IF  NVL(rec_UPG_PHONE_GEN.PARAM_VALUE,'2G') = '2G' THEN
		             DBMS_OUTPUT.PUT_LINE('NOT ELIGIBLE FOR UPGRADE');
                     op_error_code := '4';
	                 op_error_msg  := 'The given '|| ip_to_esn|| 'is 2G';
                     CLOSE CUR_UPG_PHONE_GEN;
					 CLOSE cur_to_esn_detail;
					 RETURN;
		         ELSE
			        --checking from esn is enrolled for upgrade promotion.
			         OPEN cur_eligible_promo;
			           FETCH cur_eligible_promo
				       INTO rec_eligible_promo;

			            IF cur_eligible_promo%FOUND AND rec_eligible_promo.x_promo_code IS NOT NULL THEN
							op_units := rec_eligible_promo.X_UNITS;
							op_days  := rec_eligible_promo.x_access_days;
							op_error_code := '0';
							op_error_msg  := 'Success';
							dbms_output.put_line('found cur_eligible_promo');

							--To loading TO_ESN promotions in table_x_pending_redemption
							BEGIN
								l_cnt := NULL;
								-- l_table_site_objid := NULL;
								l_part_inst_objid  := NULL;

								  SELECT OBJID
									INTO l_part_inst_objid
									FROM TABLE_PART_INST
								   WHERE PART_SERIAL_NO = ip_to_esn
									 AND X_DOMAIN = 'PHONES';
								 --Insert into table_x_pending_redemption
								  SELECT COUNT (1)
									INTO l_cnt
									FROM table_x_pending_redemption
								   WHERE pend_red2x_promotion = rec_eligible_promo.objid
									 AND pend_redemption2esn  = l_part_inst_objid;

									IF l_cnt = 0 THEN
										 INSERT INTO table_x_pending_redemption
													 (OBJID,
													  pend_red2x_promotion,
													  pend_redemption2esn,
													  x_pend_type,
													  x_granted_from2x_call_trans)
											  VALUES  (sa.SEQ('x_pending_redemption'),
													  rec_eligible_promo.objid,
													  l_part_inst_objid,
													  'REPL',
													  NULL);
									END IF;

									COMMIT;

							EXCEPTION
								WHEN NO_DATA_FOUND THEN
								 RAISE no_data_excep;

								WHEN OTHERS THEN
								 RAISE error_excep;

							    END;

						ELSE
						     op_error_code := '5';
						     op_error_msg  := 'Promo code not found';
							 CLOSE cur_eligible_promo;
							 CLOSE CUR_UPG_PHONE_GEN;
							 CLOSE cur_to_esn_detail;
							 RETURN;
                        END IF;
				    CLOSE cur_eligible_promo;
		           END IF;
            END IF;
        CLOSE CUR_UPG_PHONE_GEN;
	    END IF;
	    CLOSE cur_to_esn_detail;

  EXCEPTION
       WHEN no_data_excep THEN
	    sa.toss_util_pkg.insert_error_tab_proc (
                  'Inner Block Error -When no data found',
                  ip_to_esn,
                  v_procedure_name );
			op_error_code := '1';
			op_error_msg  := 'Failed';

	   WHEN error_excep THEN
		sa.toss_util_pkg.insert_error_tab_proc (
                  'Inner Block Error -When others',
                  ip_to_esn,
                  v_procedure_name );
			op_error_code := '1';
			op_error_msg  := 'Failed';

       WHEN OTHERS THEN
        sa.toss_util_pkg.insert_error_tab_proc (
                  'Block Error -When others',
                   ip_to_esn,
                   v_procedure_name );
			op_error_code := '1';
			op_error_msg  := 'Failed';

  END SP_TF_UPGRADE_PROMO;


/* *************************************************************************/
/* Procedure Name:     SP_NONPPE_PROMO_HIST
/* Description   :     To load NON PPE promotions to PROMO_HIST
/**************************************************************************/
 PROCEDURE SP_NONPPE_PROMO_HIST
   (
         ip_from_esn           IN VARCHAR2,
		 ip_to_esn             IN VARCHAR2,
		 op_error_code       OUT NUMBER,
		 op_error_msg        OUT VARCHAR2
   )
  IS
  CURSOR cur_ph is
  SELECT * FROM TABLE_PART_INST WHERE PART_SERIAL_NO = ip_to_esn;
  REC_PH    CUR_PH%ROWTYPE;

  CURSOR   cur_eligible_promo IS
  SELECT p.objid,p.x_promo_code, p.X_UNITS, p.x_access_days
            ,p.x_promo_type
        FROM table_x_group2esn grp2esn
            ,table_x_promotion      p
            , table_part_inst pi
         WHERE 1 = 1
         AND grp2esn.groupesn2part_inst = PI.OBJID
         AND pi.PART_SERIAL_NO = ip_from_esn
         AND p.objid = grp2esn.GROUPESN2X_PROMOTION
		 AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
		 AND SYSDATE BETWEEN grp2esn.x_start_date AND grp2esn.x_end_date
         AND X_PROMO_TYPE = 'Upgrade';
  rec_eligible_promo cur_eligible_promo%ROWTYPE;

  CURSOR cur_non_ppe is
  select ppv.PARAM_VALUE
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_part_class pc ,
      table_bus_org bo,
      PC_PARAMS_VIEW PPV
    WHERE 1                     = 1
    AND pi.part_serial_no       = ip_to_esn
    AND pi.x_domain             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.part_num2part_class  = pc.objid
    AND pn.part_num2bus_org     = bo.objid
    and ppv.part_class = pc.name
    and PPV.PARAM_NAME ='NON_PPE';

	rec_non_ppe cur_non_ppe%ROWTYPE;

	CURSOR CUR_CALL_TRANS
	IS
	SELECT * FROM TABLE_X_CALL_TRANS WHERE X_SERVICE_ID = ip_to_esn;
	REC_CALL_TRANS CUR_CALL_TRANS%ROWTYPE;

	 v_procedure_name CONSTANT VARCHAR2 (200) := v_package_name||'SP_TF_UPGRADE_PROMO';
	 l_cnt PLS_INTEGER;
  BEGIN
    OPEN cur_ph;
	FETCH CUR_PH INTO REC_PH;
	IF CUR_PH%NOTFOUND THEN
		 op_error_code := '2';
		 op_error_msg  := 'INVALID ESN';
		 CLOSE CUR_PH;
		 RETURN;
	END IF;
	CLOSE cur_ph;

	OPEN cur_non_ppe;
	FETCH cur_non_ppe INTO REC_NON_PPE;

	 OPEN CUR_CALL_TRANS;
	 FETCH CUR_CALL_TRANS INTO REC_CALL_TRANS;

	  OPEN cur_eligible_promo;
	 FETCH CUR_ELIGIBLE_PROMO INTO REC_ELIGIBLE_PROMO;

	 IF cur_non_ppe%FOUND THEN
	    IF REC_NON_PPE.PARAM_VALUE = 1 THEN
		        SELECT COUNT (1)
                        INTO l_cnt
                        FROM TABLE_X_PROMO_HIST
                       WHERE PROMO_HIST2X_CALL_TRANS = REC_CALL_TRANS.objid
                         AND PROMO_HIST2X_PROMOTION  = REC_ELIGIBLE_PROMO.OBJID;
		       IF l_cnt = 0 THEN
				INSERT INTO sa.TABLE_X_PROMO_HIST
						(OBJID,
						 PROMO_HIST2X_CALL_TRANS,
						 PROMO_HIST2X_PROMOTION,
						 GRANTED_FROM2X_CALL_TRANS,
						 UPDATE_STAMP
						)
				VALUES(
					   sa.seq('x_promo_hist'),
					   REC_CALL_TRANS.objid,
					   REC_ELIGIBLE_PROMO.OBJID,
					   NULL,
					   SYSDATE
					  );
				  COMMIT;
			  END IF;
		   END IF;
	 ELSE
	   op_error_code := '3';
	   op_error_msg  := 'THE NON PPE INFO NOT FOUND';
	   CLOSE cur_non_ppe;
	   CLOSE CUR_CALL_TRANS;
	   CLOSE cur_eligible_promo;
	   RETURN;
	END IF;
	 CLOSE cur_non_ppe;
	   CLOSE CUR_CALL_TRANS;
	   CLOSE cur_eligible_promo;
	   op_error_code := '0';
	   op_error_msg  := 'SUCCESS';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	 sa.toss_util_pkg.insert_error_tab_proc (
                  'Block Error -When no data found',
                  ip_to_esn,
                  v_procedure_name );
			op_error_code := '1';
			op_error_msg  := 'Failed';
   WHEN OTHERS THEN
	sa.toss_util_pkg.insert_error_tab_proc (
			  'Block Error -When others',
			   ip_to_esn,
			   v_procedure_name );
		op_error_code := '1';
		op_error_msg  := 'Failed';

END SP_NONPPE_PROMO_HIST;

PROCEDURE INSERT_2GPROMO_HIST
(
IP_ESN 					 IN VARCHAR2,
IP_PROMOHIST2X_PROMOTION IN NUMBER,
op_error_code            OUT NUMBER,
op_error_msg             OUT VARCHAR2
)
IS
p_objid NUMBER;
v_error_message   varchar2(1000);
BEGIN
p_objid := sa.SEQU_2G_HIST.NEXTVAL;
INSERT INTO sa.X_2GPROMO_HIST_FLAG
(OBJID,
X_ESN,
PROMOFLAG2X_PROMOTION,
UPDATE_STAMP)
VALUES
(p_objid,
 IP_ESN,
 IP_PROMOHIST2X_PROMOTION,
 SYSDATE
 );
 COMMIT;
op_error_code := 0;
op_error_msg := 'SUCCESS';
EXCEPTION
 WHEN OTHERS THEN
 op_error_code := 1;
 op_error_msg  := 'Unexpected error while inserting record into x_2gpromo_hist_flag';

   v_error_message := SQLERRM;
                    insert into error_table
                                ( ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
                         values
                                ( SUBSTR(v_error_message||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),1,4000),sysdate,
                                'Error while insert into x_2gpromo_hist_flag',IP_ESN,'UPGRADE_PROMO_PKG.INSERT_2GPROMO_HIST');
                  COMMIT;


 END INSERT_2GPROMO_HIST;


-------------------------------------
PROCEDURE transfer_3x_promo
(
		 ip_from_esn           IN VARCHAR2,
		 ip_to_esn             IN VARCHAR2,
		 op_error_code         OUT NUMBER,
		 op_error_msg          OUT VARCHAR2
)
IS
   V_SAFELINK       NUMBER := 0;

  CURSOR cur_transfer_promo IS
  SELECT txp.objid txp_objid, txpg.objid txpg_objid
  FROM   table_x_promotion txp,
         table_x_promotion_group txpg,
         table_x_promotion_mtm txpm
  WHERE  txp.x_promo_type = 'Transfer'
  AND    txpm.X_PROMO_MTM2X_PROMO_GROUP = txpg.objid
  AND    txpm.X_PROMO_MTM2X_PROMOTION   = txp.objid
  AND    txp.X_END_DATE > SYSDATE
  AND    txp.PROMOTION2BUS_ORG = sa.util_pkg.get_bus_org_objid(ip_from_esn);

BEGIN --{
op_error_code := 0;
op_error_msg  := '';
 --Call to transfer 3x minutes
   SELECT COUNT(*)
   INTO   V_SAFELINK
   FROM   sa.X_SL_CURRENTVALS     CUR,
          sa.X_PROGRAM_ENROLLED   PE,
          sa.X_PROGRAM_PARAMETERS PP
   WHERE  1                      = 1
   AND    PE.X_ESN               = CUR.X_CURRENT_ESN
   AND    PE.X_ENROLLMENT_STATUS = 'ENROLLED'
   AND    CUR.X_CURRENT_ESN      = ip_from_esn
   AND    PP.OBJID               = PE.PGM_ENROLL2PGM_PARAMETER
   AND    PP.X_PROG_CLASS        = 'LIFELINE'
   AND    ROWNUM                 <2;

  IF V_SAFELINK = 0
  THEN --{
   FOR i IN cur_transfer_promo
   LOOP --{
    IF device_util_pkg.get_smartphone_fun(ip_from_esn) = 0 --Check from phone -- PPE or SP
    THEN --{ FROM is SMART PHONE
     IF (
         (sa.promotion_pkg.sf_promo_check(i.txp_objid, 'p_esn', ip_from_esn)) > 0
          OR
         (NVL(sa.BLOCK_TRIPLE_BENEFITS(ip_from_esn), 'N') = 'N')
        )
     THEN --{
     IF device_util_pkg.get_smartphone_fun(ip_to_esn) = 0
     THEN --{

      INSERT INTO TABLE_X_GROUP2ESN
      (
            OBJID,
            X_ANNUAL_PLAN,
            GROUPESN2PART_INST,
            GROUPESN2X_PROMO_GROUP,
            X_END_DATE,
            X_START_DATE,
            GROUPESN2X_PROMOTION
      )
      (
       SELECT
            sa.seq ('x_group2esn'),
            0,
            (SELECT objid from table_part_inst where part_serial_no = ip_to_esn  and x_domain = 'PHONES' and rownum = 1),
            i.txpg_objid,
            TO_DATE('12/01/2055','mm/dd/yyyy'),
            SYSDATE,
            i.txp_objid
       FROM DUAL
       WHERE NOT EXISTS       (
                               SELECT 1
                               FROM   TABLE_X_GROUP2ESN
                               WHERE  GROUPESN2PART_INST = (SELECT objid from table_part_inst where part_serial_no = ip_to_esn and x_domain = 'PHONES' and rownum = 1)
                               AND    GROUPESN2X_PROMOTION = i.txp_objid
                              )
      );
      END IF; --}
      UPDATE  TABLE_X_GROUP2ESN
      SET     X_END_DATE           = SYSDATE-1
      WHERE   GROUPESN2PART_INST   = (SELECT objid FROM table_part_inst WHERE part_serial_no = ip_from_esn)
      AND     GROUPESN2X_PROMOTION = i.txp_objid
      AND     X_END_DATE           >= SYSDATE;

     END IF; --}

    ELSE --}{ FROM is FEATURE PHONE
     IF (sa.promotion_pkg.sf_promo_check(i.txp_objid, 'p_esn', ip_from_esn)) > 0
     THEN --{
      IF device_util_pkg.get_smartphone_fun(ip_to_esn) = 0 --Check to phone -- PPE or SP
      THEN --{

        INSERT INTO TABLE_X_GROUP2ESN
        (
              OBJID,
              X_ANNUAL_PLAN,
              GROUPESN2PART_INST,
              GROUPESN2X_PROMO_GROUP,
              X_END_DATE,
              X_START_DATE,
              GROUPESN2X_PROMOTION
        )
      (
       SELECT
            sa.seq ('x_group2esn'),
            0,
            (SELECT objid from table_part_inst where part_serial_no = ip_to_esn  and x_domain = 'PHONES' and rownum = 1),
            i.txpg_objid,
            TO_DATE('12/01/2055','mm/dd/yyyy'),
            SYSDATE,
            i.txp_objid
       FROM DUAL
       WHERE NOT EXISTS       (
                               SELECT 1
                               FROM   TABLE_X_GROUP2ESN
                               WHERE  GROUPESN2PART_INST = (SELECT objid from table_part_inst where part_serial_no = ip_to_esn  and x_domain = 'PHONES' and rownum = 1)
                               AND    GROUPESN2X_PROMOTION = i.txp_objid
                              )
      );

       ELSIF device_util_pkg.get_smartphone_fun(ip_to_esn) = 1
       THEN --}{

          INSERT INTO TABLE_X_GROUP2ESN
          (
                OBJID,
                X_ANNUAL_PLAN,
                GROUPESN2PART_INST,
                GROUPESN2X_PROMO_GROUP,
                X_END_DATE,
                X_START_DATE,
                GROUPESN2X_PROMOTION
          )
          (SELECT
                 sa.seq ('x_group2esn'),
                 0,
                 (SELECT objid from table_part_inst where part_serial_no = ip_to_esn  and x_domain = 'PHONES' and rownum = 1),
                 GROUPESN2X_PROMO_GROUP,
                 TO_DATE('12/01/2055','mm/dd/yyyy'),
                 SYSDATE,
                 GROUPESN2X_PROMOTION
           FROM  TABLE_X_GROUP2ESN g2e,
                 TABLE_X_PROMOTION txp
           WHERE g2e.GROUPESN2PART_INST = (SELECT objid FROM table_part_inst WHERE part_serial_no = ip_from_esn  and x_domain = 'PHONES' and rownum = 1)
           AND   g2e.GROUPESN2X_PROMOTION = txp.objid
           AND   txp.X_PROMO_CODE IN ('X3XMN_ACT','RTX3X000') --TRIPLE MINUTE
           AND   NOT EXISTS
                          (SELECT 1
                           FROM    TABLE_X_GROUP2ESN g2e_to
                           WHERE   g2e_to.GROUPESN2PART_INST = (SELECT objid FROM table_part_inst WHERE part_serial_no = ip_to_esn  and x_domain = 'PHONES' and rownum = 1)
                           AND     g2e_to.GROUPESN2X_PROMOTION = txp.objid)
          );

       END IF; --}
        UPDATE  TABLE_X_GROUP2ESN
        SET     X_END_DATE           = SYSDATE-1
        WHERE   GROUPESN2PART_INST   = (SELECT objid FROM table_part_inst WHERE part_serial_no = ip_from_esn  and x_domain = 'PHONES' and rownum = 1)
        AND     GROUPESN2X_PROMOTION = i.txp_objid
        AND     X_END_DATE           >= SYSDATE;
      END IF; --}
    END IF; --}
   END LOOP; --}
  END IF; --}
EXCEPTION
WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('in transfer_3x_promo main exception due to: '||sqlerrm);
 op_error_code := 1;
 op_error_msg  := 'Failed due to error in transfer_3x_promo '||SUBSTR(sqlerrm, 1,100);
 util_pkg.insert_error_tab(
                           i_action       => 'Failed during trasfering 3X promotion during upgrade.',
                           i_key          => ip_to_esn,
                           i_program_name => 'UPGRADE_PROMO_PKG.transfer_3x_promo',
                           i_error_text   => 'Error while transfering 3X promotion due to '||SUBSTR(SQLERRM, 1, 100)
                          );

END transfer_3x_promo; --}
-------------------------------------

END UPGRADE_PROMO_PKG;
/