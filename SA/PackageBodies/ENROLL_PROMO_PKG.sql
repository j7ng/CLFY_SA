CREATE OR REPLACE PACKAGE BODY sa."ENROLL_PROMO_PKG"
IS
 /***************************************************************************************************************
 * Package Name: SA.ENROLL_PROMO_PKG
 * Description: The package is called by Clarify
 * tote and register promo during enrollment process.
 *
 * Created by: PM
 * Date: 02/03/2012
 *
 * History
 * -------------------------------------------------------------------------------------------------------------------------------------
 * 02/03/2012 PM Initial Version CR15373
 * 06/05/2012 CL 1.5 CR19467
 * 07/09/2012 CL 1.7 CR19467
 * 07/17/2012 CL 1.8/1.9 CR19467
 * 07/23/2012 CL 1.11/1.12 CR19567/CR20008
 * 07/26/2012 CL 1.13 "EME Fix for Open Cursor Issue"
 * 08/23/2012 YM 1.14 CR20399 Net10 Promo logic
 * 10/10/2012 CL/YM 1.18/1.19 CR20399 Net10 promo logic fixed re-enrollemnt NET10
 * 10/10/2012 CL/YM 1.18/1.19 CR20399 Net10 promo logic fixed re-enrollemnt NET10
 * 10/12/2012 CL/YM 1.20/1.21/1.22 CR21192 /CR21964
 *************************************************************************************************************************************/
 /*************************************************************************************************************************************
 * $RCSfile: ENROLL_PROMO_PKB.sql,v $
 * $Revision: 1.71 $
 * $Author: mshah $
 * $Date: 2017/06/21 13:29:18 $
 * $ CR49229 Promo Engine Enhancement to calculate discount amount based on promotion discount percentage
 * $
 * $Revision: 1.71 $
 * $Author: mshah $
 * $Date: 2017/06/21 13:29:18 $
 * $ $Log: ENROLL_PROMO_PKB.sql,v $
 * $ Revision 1.71  2017/06/21 13:29:18  mshah
 * $ CR51609 - Promo Engine Post Implementation fixes
 * $
 * $ Revision 1.70  2017/05/19 16:50:59  nkandagatla
 * $ Promo engine enhancement to calculate promotion discount amount using discount percentage.
 * $
 * $ Revision 1.67 2017/02/24 23:16:03 abustos
 * $ CR47566 Modify sp_transfer_promo_enrollment to only update old_esn to new when status ENROLLED
 * $
 * $ Revision 1.66 2016/09/16 20:25:49 rpednekar
 * $ CR44499
 * $
 * $ Revision 1.65 2016/08/26 19:44:27 rpednekar
 * $ CR44499
 * $
 * $ Revision 1.64 2016/08/23 19:52:19 rpednekar
 * $ CR44499 - Procedures modified.
 * $
 * $ Revision 1.63 2016/06/23 18:22:13 rpednekar
 * $ CR42785 - Added comment to new parameter
 * $
 * $ Revision 1.62 2016/06/08 21:10:29 rpednekar
 * $ CR42785 - Added new parameter p_ignore_attached_promo in procedure sp_get_eligible_promo and sp_get_eligible_promo_esn3
 * $
 * $ Revision 1.59 2016/02/04 17:05:33 clinder
 * $ CR40843
 * $
 * $ Revision 1.58 2015/12/11 17:59:47 rpednekar
 * $ CR39845 - Closed cursor
 * $
 * $ Revision 1.57 2015/12/10 17:21:20 rpednekar
 * $ CR39845 - Modified procedure sp_get_eligible_promo.
 * $
 * $ Revision 1.56 2015/12/09 19:06:15 jarza
 * $ CR39833 update
 * $
 * $ Revision 1.54 2015/10/20 15:50:01 rpednekar
 * $ CR38165 - TRACFONE conditon added in brand name for promotion
 * $
 * $ Revision 1.53 2015/08/21 21:46:41 rpednekar
 * $ Condition for TOTAL_WIRELESS has been added CR36105
 * $
 * $ Revision 1.49 2015/05/20 18:14:19 arijal
 * $ CR33426 ...$0 RECURRING PAYMENT
 * $
 * $ Revision 1.48 2015/02/05 17:04:10 vmadhawnadella
 * $ ADDED LOGIC FOR SM-AUTOREUP
 * $
 * $ Revision 1.47 2015/01/26 17:53:08 vmadhawnadella
 * $ ADD LOGIC FOR SM_AUTOREUP
 * $
 * $ Revision 1.46 2014/09/10 16:32:29 rramachandran
 * $ CR26084 - ST Promo Engine Start Date Failure
 * $
 * $ Revision 1.45 2014/09/04 19:48:24 rramachandran
 * $ CR26084 - ST Promo Engine Start Date Failure
 * $
 * $ Revision 1.44 2014/08/29 13:52:36 rramachandran
 * $ CR26084 - ST Promo Engine Start Date Failure
 * $
 * $ Revision 1.43 2014/08/29 13:27:58 rramachandran
 * $ CR26084 - ST Promo Engine Start Date Failure
 * $
 * $ Revision 1.42 2014/08/28 14:32:56 rramachandran
 * $ CR26084 - ST Promo Engine Start Date Failure
 * $
 * $ Revision 1.41 2014/08/25 22:21:51 rramachandran
 * $ CR26084 - ST Promo Engine Start Date Failure
 * $
 * $ Revision 1.40 2014/01/30 19:46:02 ymillan
 * $ CR20492
 * $
 * $ Revision 1.32 2013/07/09 19:12:06 lsatuluri
 * $ Merged with latest in production.
 * $
 * $ Revision 1.30 2013/04/26 15:45:37 lsatuluri
 * $ CR23395 NET10 AutoRefill payment not granting discount
 * $
 * $ Revision 1.29 2013/04/26 15:42:31 lsatuluri
 * $ CR23395
 * $
 * $ Revision 1.28 2012/12/11 20:10:31 mmunoz
 * $ CR22380 Handset Protection, Master:CR18994
 * $
 * $ Revision 1.27 2012/12/04 23:52:44 mmunoz
 * $ CR22380 Handset Protection
 * $
 * $ Revision 1.26 2012/11/05 16:24:12 kacosta
 * $ CR22152 ST Promo Logic Enrollment Issue
 * $
 * $ Revision 1.25 2012/10/23 18:52:47 kacosta
 * $ CR22152 ST Promo Logic Enrollment Issue
 * $
 * $ Revision 1.24 2012/10/18 12:43:10 kacosta
 * $ CR22152 ST Promo Logic Enrollment Issue
 * $
 * $ Revision 1.23 2012/10/18 12:36:30 kacosta
 * $ CR22152 ST Promo Logic Enrollment Issue
 * $
 *
 *************************************************************************************************************************************/
 PROCEDURE sp_get_eligible_promo(
 p_esn IN VARCHAR2 ,
 p_program_objid IN NUMBER ,
 p_process IN VARCHAR2 ,
 p_promo_objid OUT NUMBER ,
 p_promo_code OUT VARCHAR2 ,
 p_script_id OUT VARCHAR2 ,
 p_error_code OUT NUMBER ,
 p_error_msg OUT VARCHAR2
 ,p_ignore_attached_promo IN VARCHAR2 DEFAULT 'N'	--CR42785 This flag is Y in CBO service register promo
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
 WHERE 1 = 1
 AND part_serial_no = p_esn
 --and x_part_inst_status = '52'
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num
 AND bo.objid = pn.part_num2bus_org;
 rec_esn_detail cur_esn_detail%ROWTYPE;
 CURSOR cur_program_detail
 IS
 SELECT * FROM x_program_parameters WHERE 1 = 1 AND objid = p_program_objid;
 rec_program_detail cur_program_detail%ROWTYPE;
 CURSOR cur_enrolled_promo(c_brand_name VARCHAR2)
 IS
 SELECT pr.x_script_id ,
 p.x_promo_code ,
 grp2esn.*
 FROM x_enroll_promo_grp2esn grp2esn ,
 table_x_promotion p ,
 x_enroll_promo_rule pr ,
 table_bus_org bo
 WHERE 1 = 1
 AND grp2esn.x_esn = p_esn
 AND p.objid = grp2esn.promo_objid
 AND EXISTS
 (SELECT pe.x_enrollment_status
 FROM x_program_enrolled pe
 WHERE objid = grp2esn.program_enrolled_objid
 AND x_esn = p_esn
 AND pe.x_enrollment_status = 'ENROLLED'
 )
 AND pr.promo_objid = grp2esn.promo_objid
 AND bo.objid = p.promotion2bus_org
 AND bo.org_id = c_brand_name
 ORDER BY pr.x_priority;
 rec_enrolled_promo cur_enrolled_promo%ROWTYPE;
 CURSOR cur_eligible_promo ( c_brand_name IN VARCHAR2 ,c_part_inst_status IN VARCHAR2 )
 IS
 SELECT pr.x_script_id ,
 p.x_promo_code ,
 grp2esn.*
 FROM x_enroll_promo_grp2esn grp2esn ,
 table_x_promotion p ,
 x_enroll_promo_rule pr ,
 table_bus_org bo
 WHERE 1 = 1
 AND grp2esn.x_esn = p_esn
 AND p.objid = grp2esn.promo_objid
 AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
 AND NOT EXISTS
 (SELECT pe.x_enrollment_status
 FROM x_program_enrolled pe
 WHERE objid = grp2esn.program_enrolled_objid
 AND x_esn = p_esn
 AND pe.x_enrollment_status = 'ENROLLED'
 )
 AND pr.promo_objid = grp2esn.promo_objid
 AND bo.objid = p.promotion2bus_org
 AND bo.org_id = c_brand_name
 ORDER BY pr.x_priority;
 rec_eligible_promo cur_eligible_promo%ROWTYPE;
 CURSOR cur_active_promos(c_brand_name VARCHAR2)
 IS
 SELECT pr.x_script_id ,
 pr.x_priority ,
 p.*
 FROM table_x_promotion p ,
 table_bus_org bo ,
 x_enroll_promo_rule pr
 WHERE 1 = 1
 AND x_promo_type = 'BPEnrollment'
 AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
 AND bo.objid = p.promotion2bus_org
 AND bo.org_id = c_brand_name
 AND pr.promo_objid = p.objid
 ORDER BY pr.x_priority;

	--CR39845 Start
		CURSOR esn_promo_curs
		IS
		SELECT pp.objid pp_objid
		FROM x_program_enrolled pe
		,x_program_parameters pp
		WHERE pe.x_esn 		= 	p_esn
		AND pe.pgm_enroll2pgm_parameter		= 	pp.objid
		AND pp.objid 		= 	p_program_objid
		AND pe.x_enrollment_status		=	'ENROLLED'
		;
		rec_esn_promo		esn_promo_curs%ROWTYPE;


	--CR39845 End

 l_promo_check NUMBER;
 l_promo_objid table_x_promotion.objid%TYPE;
 v_error_message VARCHAR2(1000);
 is_holiday_promo	NUMBER	:=	0;	--CR44499
 BEGIN
 p_error_code := 0;
 p_error_msg := 'Success';
 -- Active ESN Validation.
 dbms_output.put_line('p_esn:' || p_esn);
 dbms_output.put_line('p_program_objid:' || p_program_objid);
 dbms_output.put_line('p_process:' || p_process);
 OPEN cur_esn_detail;
 FETCH cur_esn_detail INTO rec_esn_detail;
 IF cur_esn_detail%NOTFOUND THEN
 p_error_code := 301;
 p_error_msg := sa.get_code_fun('SA.ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
 CLOSE cur_esn_detail;
 RETURN;
 END IF;
 CLOSE cur_esn_detail;
 -- Program Check.
 dbms_output.put_line('rec_esn_detail.brand_name:' || rec_esn_detail.brand_name);
 --Currently Enrolled active promotion.
 IF rec_esn_detail.brand_name IN ('STRAIGHT_TALK','SIMPLE_MOBILE' ,'TOTAL_WIRELESS' -- CR36105
	,'TRACFONE'		-- CR38105
	,'TELCEL'		-- CR42644
 ) THEN
 --old stright talk logic


	IF NVL(p_ignore_attached_promo,'N') = 'Y'
	THEN

		GOTO PROMO_ENGINE;
	END IF;


	--CR39845 Start
	OPEN esn_promo_curs;
	FETCH esn_promo_curs INTO	rec_esn_promo;


	IF esn_promo_curs%FOUND OR p_program_objid IS NULL
	THEN
	CLOSE esn_promo_curs;
	--CR39845 End

	 OPEN cur_enrolled_promo(rec_esn_detail.brand_name);
	 FETCH cur_enrolled_promo INTO rec_enrolled_promo;
	 IF cur_enrolled_promo%FOUND AND rec_enrolled_promo.promo_objid IS NOT NULL THEN
		p_promo_objid := rec_enrolled_promo.promo_objid;
		p_promo_code := rec_enrolled_promo.x_promo_code;
		p_script_id := rec_enrolled_promo.x_script_id;
		CLOSE cur_enrolled_promo;
		dbms_output.put_line('found cur_enrolled_promo');
		RETURN;
	 END IF;
	 CLOSE cur_enrolled_promo;
	 -- Eligible ESN driven active promotion.
	 OPEN cur_eligible_promo(rec_esn_detail.brand_name ,rec_esn_detail.x_part_inst_status);
	 FETCH cur_eligible_promo INTO rec_eligible_promo;
	 IF cur_eligible_promo%FOUND AND rec_enrolled_promo.promo_objid IS NOT NULL THEN
		p_promo_objid := rec_enrolled_promo.promo_objid;
		p_promo_code                                                 := rec_enrolled_promo.x_promo_code;
		p_script_id                                                  := rec_enrolled_promo.x_script_id;
		CLOSE cur_eligible_promo;
		dbms_output.put_line('found cur_eligible_promo');
		RETURN;
	      END IF;
	      CLOSE cur_eligible_promo;


	ELSE

		CLOSE esn_promo_curs;


	END IF;	--CR39845


      <<PROMO_ENGINE>>

      OPEN cur_program_detail;
      FETCH cur_program_detail INTO rec_program_detail;
      IF cur_program_detail%NOTFOUND THEN
        p_error_code := 302;
        p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
        CLOSE cur_program_detail;
        RETURN;
      END IF;
      CLOSE cur_program_detail;

      -- Program driven active promotion.
      dbms_output.put_line('rec_esn_detail.brand_name:' || rec_esn_detail.brand_name);
      FOR rec_active_promos IN cur_active_promos(rec_esn_detail.brand_name)
      LOOP
	--CR44499
	SELECT COUNT(1)
	INTO	is_holiday_promo
	FROM sa.TABLE_X_HOLIDAY_PROMOTION
	WHERE x_holiday_promo_objid	=	rec_active_promos.objid
	;

	IF  is_holiday_promo	>	0
	THEN
		IF PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION(	p_esn ,
										rec_active_promos.objid
										)	<> 1
		THEN
			CONTINUE;	-- HOLIDAY PROMO NOT APPLICABLE.
		END IF;

	END IF;
	--CR44499


        IF rec_active_promos.x_sql_statement IS NOT NULL AND p_program_objid IS NOT NULL AND p_process IS NOT NULL THEN
          --      dbms_output.put_line('x_sql_statement');
          l_promo_check := sf_promo_check(rec_active_promos.objid ,p_esn ,p_program_objid ,p_process);
          --      dbms_output.put_line('x_sql_statement2');
          IF TO_NUMBER(l_promo_check) > 0 THEN
            p_promo_objid            := rec_active_promos.objid;
            p_promo_code             := rec_active_promos.x_promo_code;
            p_script_id              := rec_active_promos.x_script_id;
            dbms_output.put_line('rec_active_promos.objid:' || rec_active_promos.objid);
            dbms_output.put_line('rec_active_promos.X_SCRIPT_ID:' || rec_active_promos.x_script_id);
            dbms_output.put_line('rec_active_promos.x_priority:' || rec_active_promos.x_priority);
            dbms_output.put_line('p_esn:' || p_esn);
            dbms_output.put_line('p_program_objid:' || p_program_objid);
            dbms_output.put_line('REC_ACTIVE_PROMOS.objid:' || rec_active_promos.objid);
            dbms_output.put_line('p_process:' || p_process);
            RETURN;
          ELSE
            dbms_output.put_line('promo fails:' || l_promo_check);
            --return 'FALSE';
          END IF;
        END IF;
      END LOOP;
      --NEW NET10 logic
    ELSIF rec_esn_detail.brand_name = 'NET10' AND p_program_objid IS NULL THEN
      OPEN cur_enrolled_promo(rec_esn_detail.brand_name);
      FETCH cur_enrolled_promo INTO rec_enrolled_promo;
      IF cur_enrolled_promo%FOUND AND rec_enrolled_promo.promo_objid IS NOT NULL THEN
        p_promo_objid                                                := rec_enrolled_promo.promo_objid;
        p_promo_code                                                 := rec_enrolled_promo.x_promo_code;
        p_script_id                                                  := rec_enrolled_promo.x_script_id;
        CLOSE cur_enrolled_promo;
        dbms_output.put_line('found cur_enrolled_promo');
        RETURN;
      END IF;
      CLOSE cur_enrolled_promo;
      -- Eligible ESN driven active promotion.
      OPEN cur_eligible_promo(rec_esn_detail.brand_name ,rec_esn_detail.x_part_inst_status);
      FETCH cur_eligible_promo INTO rec_eligible_promo;
      IF cur_eligible_promo%FOUND AND rec_enrolled_promo.promo_objid IS NOT NULL THEN
        p_promo_objid                                                := rec_enrolled_promo.promo_objid;
        p_promo_code                                                 := rec_enrolled_promo.x_promo_code;
        p_script_id                                                  := rec_enrolled_promo.x_script_id;
        CLOSE cur_eligible_promo;
        dbms_output.put_line('found cur_eligible_promo');
        RETURN;
      END IF;
      CLOSE cur_eligible_promo;
    ELSIF rec_esn_detail.brand_name = 'NET10' THEN
      OPEN cur_program_detail;
      FETCH cur_program_detail INTO rec_program_detail;
      IF cur_program_detail%NOTFOUND THEN
        p_error_code := 302;
        p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
        CLOSE cur_program_detail;
        RETURN;
      END IF;
      CLOSE cur_program_detail;
      -- Program driven active promotion.
      dbms_output.put_line('rec_esn_detail.brand_name:' || rec_esn_detail.brand_name);
      FOR rec_active_promos IN cur_active_promos(rec_esn_detail.brand_name)
      LOOP

	--CR44499
	SELECT COUNT(1)
	INTO	is_holiday_promo
	FROM sa.TABLE_X_HOLIDAY_PROMOTION
	WHERE x_holiday_promo_objid	=	rec_active_promos.objid
	;

	IF  is_holiday_promo	>	0
	THEN
		IF PKG_FLIP_ENROLLED_ESN_PROMO.VALIDATE_HOLIDAY_PROMOTION(	p_esn ,
										rec_active_promos.objid
										)	<> 1
		THEN
			CONTINUE;	-- HOLIDAY PROMO NOT APPLICABLE.
		END IF;

	END IF;
	--CR44499

        IF rec_active_promos.x_sql_statement IS NOT NULL AND p_program_objid IS NOT NULL AND p_process IS NOT NULL THEN
          --      dbms_output.put_line('x_sql_statement');
          l_promo_check := sf_promo_check(rec_active_promos.objid ,p_esn ,p_program_objid ,p_process);
          --      dbms_output.put_line('x_sql_statement2');
          IF TO_NUMBER(l_promo_check) > 0 THEN
            p_promo_objid            := rec_active_promos.objid;
            p_promo_code             := rec_active_promos.x_promo_code;
            p_script_id              := rec_active_promos.x_script_id;
            dbms_output.put_line('rec_active_promos.objid:' || rec_active_promos.objid);
            dbms_output.put_line('rec_active_promos.X_SCRIPT_ID:' || rec_active_promos.x_script_id);
            dbms_output.put_line('rec_active_promos.x_priority:' || rec_active_promos.x_priority);
            dbms_output.put_line('p_esn:' || p_esn);
            dbms_output.put_line('p_program_objid:' || p_program_objid);
            dbms_output.put_line('REC_ACTIVE_PROMOS.objid:' || rec_active_promos.objid);
            dbms_output.put_line('p_process:' || p_process);
            RETURN;
          ELSE
            dbms_output.put_line('promo fails:' || l_promo_check);
            --return 'FALSE';
          END IF;
        END IF;
      END LOOP;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    v_error_message := SQLERRM;
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
        SUBSTR(v_error_message
        ||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),1,4000),
        sysdate,
        'GET ELIGIBLE PROMO BASED ON PROGRAM ='
        ||P_PROGRAM_OBJID,
        p_esn,
        'ENROLL_PROMO_PKB.SP_GET_ELIGIBLE_PROMO'
      );
    COMMIT;
  END sp_get_eligible_promo;
  PROCEDURE sp_register_esn_promo
    (
      p_esn                    IN VARCHAR2 ,
      p_promo_objid            IN NUMBER ,
      p_program_enrolled_objid IN NUMBER ,
      p_error_code OUT NUMBER ,
      p_error_msg OUT VARCHAR2
    )
  IS

  LV_HOLIDAY_PROMO_COUNT	NUMBER;		--CR44499
  is_holiday_promo		NUMBER;		--CR44499

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
        --AND x_part_inst_status = '52' --23395
        --AND x_part_inst_status in( '52','50')   --23395 add 50
      AND ml.objid = pi.n_part_inst2part_mod
      AND pn.objid = ml.part_info2part_num
      AND bo.objid = pn.part_num2bus_org;
    rec_esn_detail cur_esn_detail%ROWTYPE;
    CURSOR cur_promo
    IS
      SELECT p.* ,
        (SELECT pr.x_priority
        FROM x_enroll_promo_rule pr
        WHERE pr.promo_objid = p.objid
        ) x_priority ,
      (SELECT pg.objid
      FROM table_x_promotion_mtm mp ,
        table_x_promotion_group pg
      WHERE 1                        = 1
      AND pg.objid                   = mp.x_promo_mtm2x_promo_group
      AND mp.x_promo_mtm2x_promotion = p.objid
      ) pg_objid
    FROM table_x_promotion p
    WHERE SYSDATE BETWEEN p.x_start_date AND p.x_end_date
    AND p.objid = p_promo_objid;
    rec_promo cur_promo%ROWTYPE;
    CURSOR cur_program_enrolled
    IS
      SELECT * FROM x_program_enrolled WHERE objid = p_program_enrolled_objid;
    rec_program_enrolled cur_program_enrolled%ROWTYPE;
    CURSOR cur_promo_enrollment(c_brand_name IN VARCHAR2)
    IS
      SELECT p.x_promo_code ,
        grp2esn.* ,
        pr.x_priority promo_rule_priority
      FROM x_enroll_promo_grp2esn grp2esn ,
        table_x_promotion p ,
        x_enroll_promo_rule pr
      WHERE 1   = 1
      AND x_esn = p_esn
        --and nvl(grp2esn.program_enrolled_objid, p_program_enrolled_objid) = p_program_enrolled_objid
      AND grp2esn.program_enrolled_objid = p_program_enrolled_objid
      AND p.objid                        = grp2esn.promo_objid
      AND pr.promo_objid                 = grp2esn.promo_objid
      ORDER BY pr.x_priority;
    rec_promo_enrollment cur_promo_enrollment%ROWTYPE;


  BEGIN
    p_error_code := 0;
    p_error_msg  := 'Success';
    -- Active ESN Check.
    OPEN cur_esn_detail;
    FETCH cur_esn_detail INTO rec_esn_detail;
    IF cur_esn_detail%NOTFOUND THEN
      p_error_code := 301;
      p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
      CLOSE cur_esn_detail;
      RETURN;
    END IF;
    CLOSE cur_esn_detail;
    dbms_output.put_line('esn pass');
    OPEN cur_promo;
    FETCH cur_promo INTO rec_promo;
    IF cur_promo%NOTFOUND THEN
      CLOSE cur_promo;
      p_error_code := 303;
      p_error_msg  := 'Invalid Promo';
      RETURN;
    END IF;
    CLOSE cur_promo;
    dbms_output.put_line('promo pass');
    OPEN cur_program_enrolled;
    FETCH cur_program_enrolled INTO rec_program_enrolled;
    IF cur_program_enrolled%NOTFOUND THEN
      CLOSE cur_program_enrolled;
      p_error_code := 304;
      p_error_msg  := 'Invalid Program Enrollment ID';
      RETURN;
    END IF;
    CLOSE cur_program_enrolled;
    dbms_output.put_line('enrolled');
    OPEN cur_promo_enrollment(rec_esn_detail.brand_name);
    FETCH cur_promo_enrollment INTO rec_promo_enrollment;

    --- CR44499 START

	SELECT COUNT(1)
	INTO	is_holiday_promo
	FROM 	sa.TABLE_X_HOLIDAY_PROMOTION
	WHERE 	x_holiday_promo_objid	=	p_promo_objid
	;

	IF  is_holiday_promo	>	0
	THEN

		LV_HOLIDAY_PROMO_COUNT	:=	 PKG_FLIP_ENROLLED_ESN_PROMO.GET_ENR_HOLIDAY_PROMO_COUNT(p_esn,p_promo_objid);

	END IF;

    --- CR44499 END

    IF cur_promo_enrollment%NOTFOUND THEN
      dbms_output.put_line('cur_promo_enrollment%notfound');
      dbms_output.put_line('insert into x_enroll_promo_grp2esn ');
      INSERT
      INTO x_enroll_promo_grp2esn
        (
          objid ,
          x_esn_driven ,
          x_esn ,
          promo_group_objid ,
          promo_objid ,
          program_enrolled_objid ,
          x_start_date ,
          x_end_date ,
          x_priority
	  ,x_holiday_promo_balance
        )
        VALUES
        (
          sa.seq_enroll_promo_grp2esn.nextval ,
          'Y' ,
          p_esn ,
          rec_promo.pg_objid ,
          p_promo_objid ,
          p_program_enrolled_objid ,
          rec_program_enrolled.x_enrolled_date ,
          NULL ,
          rec_promo.x_priority
	  ,NVL(LV_HOLIDAY_PROMO_COUNT,0)	--CR44499
        );
    ELSE
      dbms_output.put_line('cur_promo_enrollment%found, update X_ENROLL_PROMO_GRP2ESN ');
      UPDATE x_enroll_promo_grp2esn
      SET x_esn_driven         = 'Y' ,
        promo_group_objid      = rec_promo.pg_objid ,
        promo_objid            = p_promo_objid ,
        program_enrolled_objid = p_program_enrolled_objid ,
        x_start_date           = rec_program_enrolled.x_enrolled_date ,
        x_end_date             = NULL , -- CR20399
        x_priority             = rec_promo.x_priority
--	,x_holiday_promo_balance	       = NVL(x_holiday_promo_balance,0) + NVL(LV_HOLIDAY_PROMO_COUNT,0)	--CR44499
      WHERE objid              = rec_promo_enrollment.objid;
    END IF;
    -- ym/cl 07/9/2012
    UPDATE x_program_enrolled
    SET pgm_enroll2x_promotion = p_promo_objid
    WHERE objid                = p_program_enrolled_objid
    AND x_esn                  = p_esn; ---CR23395
    --AND NVL(pgm_enroll2x_promotion ---CR23395
    -- ,0) = 0;
    sa.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO --CR34962
    ( p_esn , p_promo_objid , p_program_enrolled_objid , p_error_code , p_error_msg ) ;
    CLOSE cur_promo_enrollment;
    COMMIT;
  END sp_register_esn_promo;
  PROCEDURE sp_validate_promo(
      p_esn           IN VARCHAR2 ,
      p_program_objid IN NUMBER ,
      p_process       IN VARCHAR2 ,
      p_promo_objid   IN OUT NUMBER ,
      p_promo_code OUT VARCHAR2 ,
      p_enroll_type OUT VARCHAR2 ,
      p_enroll_amount OUT NUMBER ,
      p_enroll_units OUT NUMBER ,
      p_enroll_days OUT NUMBER ,
      p_error_code OUT NUMBER ,
      p_error_msg OUT VARCHAR2 )
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
    CURSOR cur_promo_detail(c_brand_name VARCHAR2)
    IS
      SELECT pg.objid promo_grp_objid ,
        p.*
      FROM table_x_promotion p ,
        table_x_promotion_mtm mtm ,
        table_x_promotion_group pg ,
        table_bus_org bo
      WHERE 1                         = 1
      AND p.objid                     = p_promo_objid
      AND mtm.x_promo_mtm2x_promotion = p.objid
      AND pg.objid                    = mtm.x_promo_mtm2x_promo_group
      AND bo.objid                    = p.promotion2bus_org
      AND bo.org_id                   = c_brand_name;
    rec_promo_detail cur_promo_detail%ROWTYPE;
    CURSOR cur_esn_registered_promo(c_brand_name IN VARCHAR2)
    IS
      SELECT grp2esn.objid grp2esn_objid ,
        grp2esn.x_esn ,
        pr.* ,
        p.x_promo_type ,
        p.x_promo_code ,
        p.x_dollar_retail_cost ,
        p.x_start_date ,
        p.x_end_date ,
        p.x_usage ,
        grp2esn.x_start_date program_enroll_date ,
        /*
        nvl(  (select x_enrollment_date
        from   x_program_enrolled
        where  x_esn =  p_esn
        and    x_enrollment_status in ('ENROLLED', 'ENROLLMENTSCHEDULED') )
        , sysdate) program_enroll_date,
        */
        NVL(
        (SELECT MAX(x_rqst_date)
        FROM x_program_enrolled pe ,
          x_program_purch_dtl dtl ,
          x_program_purch_hdr hdr ,
          x_program_discount_hist hist
        WHERE 1                            = 1
        AND dtl.pgm_purch_dtl2pgm_enrolled = pe.objid
        AND hdr.objid                      = dtl.pgm_purch_dtl2prog_hdr
        AND hist.pgm_discount2prog_hdr     = hdr.objid
        AND hist.pgm_discount2x_promo      = p.objid
        AND hdr.x_status NOT              IN ('FAILED' ,'FAILPROCESSED' ,'VALIDATIONFAILED')
        AND pe.x_esn                       = p_esn
        ) ,SYSDATE - 31) last_usage_date ,
        sf_promo_check(p.objid ,p_esn ,0 , -- Passing 0 to avoid program check.
        p_process) fun_check
      FROM x_enroll_promo_grp2esn grp2esn ,
        table_x_promotion p ,
        x_enroll_promo_rule pr
      WHERE 1                 = 1
      AND x_esn               = p_esn
      AND grp2esn.promo_objid = p_promo_objid
      AND 1                   =
        CASE
          WHEN c_brand_name = 'STRAIGHT_TALK' --CR20399
          AND SYSDATE BETWEEN grp2esn.x_start_date AND NVL(grp2esn.x_end_date ,SYSDATE + 1)
          THEN 1
          WHEN c_brand_name = 'SIMPLE_MOBILE' --CR31853
          AND SYSDATE BETWEEN grp2esn.x_start_date AND NVL(grp2esn.x_end_date ,SYSDATE + 1)
          THEN 1
          WHEN c_brand_name = 'NET10'
          THEN 1
          WHEN grp2esn.x_start_date IS NOT NULL -- CR36105
          AND SYSDATE BETWEEN grp2esn.x_start_date AND NVL(grp2esn.x_end_date ,SYSDATE + 1)
          THEN 1
          ELSE 0
        END
        --   and    sysdate between grp2esn.x_start_date and nvl(grp2esn.x_end_date, sysdate + 1)
      AND grp2esn.program_enrolled_objid IS NOT NULL
      AND p.objid                         = grp2esn.promo_objid
        --and    sysdate          between p.x_start_date and p.x_end_date
      AND pr.promo_objid = grp2esn.promo_objid
      ORDER BY pr.x_priority;
      rec_esn_registered_promo cur_esn_registered_promo%ROWTYPE;
      CURSOR cur_promo_grp_hist_check(c_brand_name IN VARCHAR2)
      IS
        SELECT 1
        FROM x_enroll_promo_grp2esn grp2esn ,
          x_enroll_promo_grp2esn_hist grp2esn_hist
        WHERE grp2esn.x_esn     = p_esn
        AND grp2esn.promo_objid = p_promo_objid
        AND 1                   =
          CASE
            WHEN (c_brand_name      = 'STRAIGHT_TALK'
            AND grp2esn.x_end_date IS NULL)
            THEN 1
            WHEN (c_brand_name      = 'SIMPLE_MOBILE'
            AND grp2esn.x_end_date IS NULL)
            THEN 1
            WHEN (c_brand_name                  = 'NET10'
            AND grp2esn_hist.x_action_type NOT IN ('Deenrollment'))
            THEN 1
            WHEN grp2esn.x_end_date IS NULL
            THEN -- CR36105
              1
            ELSE 0
          END --CR20399
          --and   grp2esn.x_end_date                is null
        AND grp2esn.program_enrolled_objid IS NOT NULL
        AND grp2esn.objid                   = grp2esn_hist.promo_grp2esn_objid;
      rec_promo_grp_hist_check cur_promo_grp_hist_check%ROWTYPE;
      CURSOR cur_promo_grp_disc_hist(c_brand_name IN VARCHAR2) IS
        SELECT /*+ ORDERED */
               NVL(MIN(grp2esn_hist.x_start_date), TRUNC(SYSDATE) -30) enrollment_start_date ,
               NVL(SUM(DECODE(NVL(disc_hist.pgm_discount2x_promo ,0) ,p_promo_objid ,1 ,0)), 0) applied_promo_count
          FROM x_enroll_promo_grp2esn      grp2esn2,
               x_enroll_promo_grp2esn_hist grp2esn_hist,
               x_program_purch_dtl         dtl,
               x_program_purch_hdr         hdr,
               x_program_discount_hist     disc_hist
         WHERE 1 = 1
           and grp2esn2.x_esn                   = p_esn
           AND grp2esn_hist.promo_grp2esn_objid = grp2esn2.objid
           AND EXISTS (SELECT 1
                         FROM x_enroll_promo_grp2esn grp2esn
                        WHERE grp2esn.x_esn       = p_esn
                          AND grp2esn.objid       = grp2esn_hist.promo_grp2esn_objid
                          AND grp2esn.program_enrolled_objid IS NOT NULL
                          AND grp2esn.promo_objid = p_promo_objid
                          AND 1                   = CASE WHEN (c_brand_name      = 'STRAIGHT_TALK'
                                                          AND grp2esn.x_end_date IS NULL) THEN
                                                           1
                                                         WHEN (c_brand_name      = 'SIMPLE_MOBILE'
                                                          AND grp2esn.x_end_date IS NULL) THEN
                                                           1
                                                         WHEN (c_brand_name                  = 'NET10'
                                                          AND grp2esn_hist.x_action_type NOT IN ('Deenrollment')) THEN
                                                           1
                                                         WHEN grp2esn.x_end_date IS NULL THEN
                                                           1
                                                         ELSE 0
                                                    END)
           AND dtl.pgm_purch_dtl2pgm_enrolled     = grp2esn_hist.program_enrolled_objid
           AND hdr.objid                          = dtl.pgm_purch_dtl2prog_hdr
           AND disc_hist.pgm_discount2prog_hdr(+) = hdr.objid;
      rec_promo_grp_disc_hist cur_promo_grp_disc_hist%ROWTYPE;
      CURSOR cur_promo_disc_hist(c_brand_name IN VARCHAR2)
      IS
        SELECT MIN(pe.x_enrolled_date) enrollment_start_date ,
          SUM(DECODE(NVL(disc_hist.pgm_discount2x_promo ,0) ,p_promo_objid ,1 ,0)) applied_promo_count
        FROM x_enroll_promo_grp2esn grp2esn ,
          x_program_enrolled pe ,
          x_program_purch_dtl dtl ,
          x_program_purch_hdr hdr ,
          x_program_discount_hist disc_hist
        WHERE 1                 = 1
        AND grp2esn.x_esn       = p_esn
        AND grp2esn.promo_objid = p_promo_objid
        AND 1                   =
          CASE
            WHEN (c_brand_name      = 'STRAIGHT_TALK'
            AND grp2esn.x_end_date IS NULL)
            THEN 1
            WHEN (c_brand_name      = 'SIMPLE_MOBILE'
            AND grp2esn.x_end_date IS NULL)
            THEN 1
            WHEN c_brand_name = 'NET10'
            THEN 1
            WHEN grp2esn.x_end_date IS NULL
            THEN 1
            ELSE 0
          END --CR20399
          --   and   grp2esn.x_end_date                    is null
        AND grp2esn.program_enrolled_objid    IS NOT NULL
        AND pe.x_esn                           = grp2esn.x_esn
        AND dtl.pgm_purch_dtl2pgm_enrolled     = pe.objid
        AND hdr.objid                          = dtl.pgm_purch_dtl2prog_hdr
        AND disc_hist.pgm_discount2prog_hdr(+) = hdr.objid;
      rec_promo_disc_hist cur_promo_disc_hist%ROWTYPE;
      l_promo_objid        NUMBER;
      l_promo_code         VARCHAR2(200);
      l_error_code         NUMBER;
      l_error_msg          VARCHAR2(200);
      l_enroll_start_date  DATE;
      l_promo_discount_cnt NUMBER;
      l_discount_amount    NUMBER;
      l_enrolled_period    NUMBER;
      l_result              NUMBER;  --CR49229
    BEGIN
      p_error_code := 0;
      p_error_msg  := 'Success';
      -- ESN Validation.
      dbms_output.put_line('p_esn:' || p_esn);
      OPEN cur_esn_detail;
      FETCH cur_esn_detail INTO rec_esn_detail;
      IF cur_esn_detail%NOTFOUND THEN
        p_error_code := 301;
        p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
        CLOSE cur_esn_detail;
        RETURN;
      END IF;
      dbms_output.put_line('ESN Validation. ');
      CLOSE cur_esn_detail;
      -- Promo Validation.
      dbms_output.put_line('rec_esn_detail.brand_name:' || rec_esn_detail.brand_name);
      OPEN cur_promo_detail(rec_esn_detail.brand_name);
      FETCH cur_promo_detail INTO rec_promo_detail;
      IF cur_promo_detail%NOTFOUND THEN
        dbms_output.put_line('cur_promo_detail%notfound');
        p_error_code := 303;
        p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
        CLOSE cur_promo_detail;
        RETURN;
      END IF;
      dbms_output.put_line('Promo Validation. ');
      CLOSE cur_promo_detail;
      -- All Active Promo registed with ESN based on priority.
      FOR rec_esn_registered_promo IN cur_esn_registered_promo(rec_esn_detail.brand_name)
      LOOP
        dbms_output.put_line('inside look for all active promo registed with ESN based on priority  ');
        --l_enrolled_period := round(to_number(trunc(sysdate) - trunc(rec_esn_registered_promo.program_enroll_date)),0);
        l_discount_amount := rec_esn_registered_promo.x_dollar_retail_cost;
        dbms_output.put_line('discount  = ' || l_discount_amount);
        ----------********
        -- 1. Transfer Check Flag.
        IF NVL(rec_esn_registered_promo.x_transfer_check ,'N') = 'Y' THEN
          dbms_output.put_line('p_esn:' || p_esn);
          dbms_output.put_line('p_promo_objid:' || p_promo_objid);
          OPEN cur_promo_grp_hist_check(rec_esn_detail.brand_name);
          FETCH cur_promo_grp_hist_check INTO rec_promo_grp_hist_check;
          IF cur_promo_grp_hist_check%FOUND THEN
            dbms_output.put_line('promo_grup_hist');
            OPEN cur_promo_grp_disc_hist(rec_esn_detail.brand_name);
            FETCH cur_promo_grp_disc_hist INTO rec_promo_grp_disc_hist;
            CLOSE cur_promo_grp_disc_hist;
            l_enroll_start_date  := rec_promo_grp_disc_hist.enrollment_start_date;
            l_promo_discount_cnt := rec_promo_grp_disc_hist.applied_promo_count;
            l_enrolled_period    := ROUND(TO_NUMBER(TRUNC(SYSDATE) - TRUNC(l_enroll_start_date)) / 30 ,0);
          ELSE
            OPEN cur_promo_disc_hist(rec_esn_detail.brand_name);
            FETCH cur_promo_disc_hist INTO rec_promo_disc_hist;
            IF cur_promo_disc_hist%NOTFOUND THEN
              dbms_output.put_line('cur_promo_disc_hist%notfound');
            END IF;
            CLOSE cur_promo_disc_hist;
            dbms_output.put_line('if not found disc history ');
            l_enroll_start_date  := rec_promo_disc_hist.enrollment_start_date;
            l_promo_discount_cnt := rec_promo_disc_hist.applied_promo_count;
            l_enrolled_period    := ROUND(TO_NUMBER(TRUNC(SYSDATE) - TRUNC(l_enroll_start_date)) / 30 ,0);
            dbms_output.put_line('trunc(l_enroll_start_date):' || TRUNC(l_enroll_start_date));
            dbms_output.put_line('1:' || TO_NUMBER(TRUNC(SYSDATE) - TRUNC(l_enroll_start_date)));
          END IF;
          CLOSE cur_promo_grp_hist_check;
        ELSIF NVL(rec_esn_registered_promo.x_transfer_check ,'N') = 'N' THEN
          dbms_output.put_line('not transfer flag  ');
          OPEN cur_promo_disc_hist(rec_esn_detail.brand_name);
          FETCH cur_promo_disc_hist INTO rec_promo_disc_hist;
          CLOSE cur_promo_disc_hist;
          l_enroll_start_date  := rec_promo_disc_hist.enrollment_start_date;
          l_promo_discount_cnt := rec_promo_disc_hist.applied_promo_count;
          l_enrolled_period    := ROUND(TO_NUMBER(TRUNC(SYSDATE) - TRUNC(l_enroll_start_date)) / 30 ,0);
        END IF;
        -- 2. Promo cycle start check.
        -- At the time of enrollment and promo cycle starts after enrollment not at the time of enrollment.
        IF NVL(rec_esn_registered_promo.x_promo_cycle_start ,1) = 1
          --CR22152 Start Kacosta 10/15/2012
          --AND l_enrolled_period = 0 THEN
          AND UPPER(p_process) LIKE 'ENROLL%' THEN
          --CR22152 End Kacosta 10/15/2012
          l_discount_amount := NULL;
          dbms_output.put_line('l_discount_amount := NULL :1:' || rec_esn_registered_promo.x_promo_cycle_start);
          EXIT;
        END IF;
        -- 3. Promo Usge check.
        IF rec_esn_registered_promo.x_usage IS NOT NULL AND l_promo_discount_cnt >= rec_esn_registered_promo.x_usage THEN
          -- Promo already used for max no of time it allowed.
          l_discount_amount := NULL;
          dbms_output.put_line('Promo already used for max no of time it allowed.');
          EXIT;
        END IF;
        dbms_output.put_line('l_enrolled_period ' || TO_CHAR(l_enrolled_period));
        dbms_output.put_line(' frequency duration ' || TO_CHAR(rec_esn_registered_promo.x_frequency_duration));
        -- 4. Frequency Duration ( it should be > 0 )
        IF MOD(l_enrolled_period ,rec_esn_registered_promo.x_frequency_duration) = 0 THEN
          /* if
          increment by = 0 then Discount Amt from promotion + 0 ( Fix Amount Discount).
          increment by = null then Discount Amt from promotion + Total Discount provided (Discount increased by promo discount)
          increment by > 0 then Increment By + total Increment By provided.
          */
          dbms_output.put_line('inside discount');
          IF NVL(rec_esn_registered_promo.x_calculation_type ,0) = 1 THEN
            l_discount_amount                                   := l_discount_amount * (l_enrolled_period / rec_esn_registered_promo.x_frequency_duration);
            dbms_output.put_line('x_calculation_type validation ');
          ELSE
            IF rec_esn_registered_promo.x_increment_by > 0 THEN
              dbms_output.put_line('x_increment by >0');
              l_discount_amount := rec_esn_registered_promo.x_increment_by + NVL(rec_esn_registered_promo.x_increment_by ,rec_esn_registered_promo.x_dollar_retail_cost) * l_promo_discount_cnt;
            ELSE
              dbms_output.put_line('x_increment by <=0');
              l_discount_amount := l_discount_amount + NVL(rec_esn_registered_promo.x_increment_by ,rec_esn_registered_promo.x_dollar_retail_cost) * l_promo_discount_cnt;
            END IF;
          END IF;
        ELSE
          -- If calculation type = 1 then provide the discount amount (Cumulative Calculation).
          dbms_output.put_line(' acumulative calculation');
          dbms_output.put_line(' x_calculation_type ' || TO_CHAR(rec_esn_registered_promo.x_calculation_type));
          IF NVL(rec_esn_registered_promo.x_calculation_type ,0) = 0 THEN
            dbms_output.put_line('l_discount_amount is null, x_calculation_type = 0');
            l_discount_amount := NULL;
            EXIT;
          ELSE
            BEGIN
              dbms_output.put_line(' x_calculation_type <> 0');
              SELECT DECODE(l_promo_discount_cnt ,0 ,1 ,l_promo_discount_cnt)
              INTO l_promo_discount_cnt
              FROM dual;
              dbms_output.put_line('l_promo_discount_cnt' || TO_CHAR(l_promo_discount_cnt));
            EXCEPTION
            WHEN OTHERS THEN
              l_promo_discount_cnt := 0;
            END;
            l_discount_amount := l_discount_amount * l_promo_discount_cnt;
            dbms_output.put_line('l_discount_amount' || TO_CHAR(l_discount_amount));
            EXIT;
          END IF;
        END IF;
        IF l_discount_amount > rec_esn_registered_promo.x_max_discount THEN
          l_discount_amount := rec_esn_registered_promo.x_max_discount;
          dbms_output.put_line('l_discount_amount > max: ' || TO_CHAR(l_discount_amount));
        END IF;
        IF l_discount_amount >= 0 THEN
          EXIT;
        END IF;
      END LOOP;
      dbms_output.put_line('l_discount_amoun end loop: ' || TO_CHAR(l_discount_amount));
      IF NVL(l_discount_amount ,0) > 0 THEN
        p_promo_objid             := rec_promo_detail.objid;
        p_promo_code              := rec_promo_detail.x_promo_code;
        p_enroll_type             := rec_promo_detail.x_promo_type;
        p_enroll_amount           := l_discount_amount;
        p_enroll_units            := rec_promo_detail.x_units;
        p_enroll_days             := rec_promo_detail.x_access_days;
        --CR23128
      ELSE
        p_promo_objid   := rec_promo_detail.objid;
        p_promo_code    := rec_promo_detail.x_promo_code;
        p_enroll_type   := rec_promo_detail.x_promo_type;
       -- p_enroll_amount := l_discount_amount; --CR49229
        p_enroll_units  := rec_promo_detail.x_units;
        p_enroll_days   := rec_promo_detail.x_access_days;

 -- START CR49229

        get_discount_amount(p_esn,
                            p_promo_objid,
                            null,
                            l_discount_amount,
                            l_result);

        p_enroll_amount := NVL(l_discount_amount,0); --51609 NVL Added

-- END CR49229

      END IF;
    END sp_validate_promo;
      FUNCTION sf_promo_check(
          p_promo_objid   IN NUMBER ,
          p_esn           IN VARCHAR2 ,
          p_program_objid IN NUMBER ,
          p_process       IN VARCHAR2 )
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
          l_bind_var := ':p_program_id';
          dbms_output.put_line('4');
          IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
            dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_program_objid);
          END IF;
          l_bind_var := ':process';
          dbms_output.put_line('5');
          IF NVL(INSTR(l_sql_statement ,l_bind_var) ,0) > 0 THEN
            dbms_sql.bind_variable(l_cursor ,l_bind_var ,p_process);
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
    PROCEDURE sp_transfer_promo_enrollment(
        p_case_objid IN NUMBER ,
        p_new_esn    IN VARCHAR2 ,
        --p_program_objid       in    number,
        p_error_code OUT NUMBER ,
        p_error_msg OUT VARCHAR2 )
    IS
      CURSOR cur_case_detail
      IS
        SELECT s_title ,
          x_model ,
          x_case_type ,
          x_esn
        FROM table_case
        WHERE objid = p_case_objid;
      rec_case_detail cur_case_detail%ROWTYPE;
      CURSOR cur_esn_detail(c_esn VARCHAR2)
      IS
        SELECT bo.org_id brand_name ,
          pi.part_serial_no ,
          pi.x_part_inst_status ,
          pn.part_number ,
          pe.objid enrolled_objid ,
          pe.x_enrollment_status enrolled_status ,
          pe.x_enrolled_date ,
          pe.pgm_enroll2site_part site_part ,
          pe.pgm_enroll2part_inst part_inst ,
          pe.pgm_enroll2contact contact
        FROM table_part_inst pi ,
          table_mod_level ml ,
          table_part_num pn ,
          table_bus_org bo ,
          x_program_enrolled pe
        WHERE 1               = 1
        AND pi.part_serial_no = c_esn
        AND ml.objid          = pi.n_part_inst2part_mod
        AND pn.objid          = ml.part_info2part_num
        AND bo.objid          = pn.part_num2bus_org
        AND pe.x_esn(+)       = pi.part_serial_no;
      rec_old_esn_detail cur_esn_detail%ROWTYPE;
      rec_new_esn_detail cur_esn_detail%ROWTYPE;
      CURSOR cur_esn_registered_promo ( c_esn VARCHAR2 ,c_brand_name IN VARCHAR2 )
      IS
        SELECT grp2esn.objid grp2esn_objid ,
          grp2esn.x_esn ,
          pr.* ,
          p.x_promo_type ,
          p.x_promo_code ,
          p.x_dollar_retail_cost ,
          p.x_start_date ,
          p.x_end_date ,
          p.x_usage ,
          NULL program_enroll_date
        FROM x_enroll_promo_grp2esn grp2esn ,
          table_x_promotion p ,
          x_enroll_promo_rule pr
        WHERE 1   = 1
        AND x_esn = c_esn
        AND 1     =
          CASE
            WHEN c_brand_name                                                           IN ('STRAIGHT_TALK','SIMPLE_MOBILE') --CR20399 and CR31853
            AND SYSDATE BETWEEN grp2esn.x_start_date AND NVL(grp2esn.x_end_date ,SYSDATE + 1)
            THEN 1
            WHEN c_brand_name = 'NET10'
            THEN 1
            WHEN grp2esn.x_start_date IS NOT NULL -- CR36105
            AND SYSDATE BETWEEN grp2esn.x_start_date AND NVL(grp2esn.x_end_date ,SYSDATE + 1)
            THEN 1
            ELSE 0
          END
          --and    grp2esn.promo_objid    = p_promo_objid
          --     and    sysdate between grp2esn.x_start_date and nvl(grp2esn.x_end_date, sysdate + 1)
        AND p.objid = grp2esn.promo_objid
          --and    sysdate          between p.x_start_date and p.x_end_date
        AND pr.promo_objid = grp2esn.promo_objid
        ORDER BY pr.x_priority;
      rec_esn_registered_promo cur_esn_registered_promo%ROWTYPE;
      CURSOR cur_act_promo_enrollment ( c_esn VARCHAR2 ,c_brand_name IN VARCHAR2 )
      IS
        SELECT *
        FROM x_enroll_promo_grp2esn
        WHERE 1   = 1
        AND x_esn = c_esn
        AND 1     =
          CASE
            WHEN c_brand_name                            IN ('STRAIGHT_TALK','SIMPLE_MOBILE') --CR20399 and --CR31853
            AND SYSDATE BETWEEN NVL(x_start_date ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1)
            THEN 1
            WHEN c_brand_name = 'NET10'
            THEN 1
            WHEN SYSDATE BETWEEN NVL(x_start_date -- CR36105
              ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1)
            THEN 1
            ELSE 0
          END
        AND 1 = 1;
      --   and    sysdate between nvl(x_start_date, sysdate - 1) and nvl(x_end_date,sysdate + 1);
      rec_act_promo_enrollment cur_act_promo_enrollment%ROWTYPE;
      p_promo_objid table_x_promotion.objid%TYPE;
      p_promo_code table_x_promotion.x_promo_code%TYPE;
      l_upgrade_flag VARCHAR2(1) := 'N';
      --
      --CR22152 Start Kacosta 10/15/2012
      CURSOR get_port_in_case_old_esn_curs ( c_n_case_objid table_case.objid%TYPE ,c_v_new_esn table_case.x_esn%TYPE )
      IS
        SELECT xcd.x_value old_esn
        FROM table_case tbc
        JOIN table_x_case_detail xcd
        ON tbc.objid    = xcd.detail2case
        WHERE tbc.objid = c_n_case_objid
        AND tbc.x_esn   = c_v_new_esn
        AND xcd.x_name  = 'CURRENT_ESN';
      --
      get_port_in_case_old_esn_rec get_port_in_case_old_esn_curs%ROWTYPE;
      --
      l_v_old_esn table_part_inst.part_serial_no%TYPE;
      --CR22152 End Kacosta 10/15/2012
      --
      v_promo_objid   NUMBER;
      v_promo_code    VARCHAR2(100);
      v_script_id     VARCHAR2(100);
      v_error_code    NUMBER;
      v_error_msg     VARCHAR2(1000);
      v_error_message VARCHAR2(1000);
    BEGIN
      p_error_code := 0;
      p_error_msg  := 'Success';
      -- Get old ESN from case.
      OPEN cur_case_detail;
      FETCH cur_case_detail INTO rec_case_detail;
      IF cur_case_detail%NOTFOUND THEN
        p_error_code := 305;
        p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
        CLOSE cur_case_detail;
        RETURN;
      END IF;
      CLOSE cur_case_detail;
      --
      --CR22152 Start Kacosta 10/15/2012
      IF (rec_case_detail.x_case_type = 'Port In') THEN
        --
        IF get_port_in_case_old_esn_curs%ISOPEN THEN
          --
          CLOSE get_port_in_case_old_esn_curs;
          --
        END IF;
        --
        OPEN get_port_in_case_old_esn_curs(c_n_case_objid => p_case_objid ,c_v_new_esn => p_new_esn);
        FETCH get_port_in_case_old_esn_curs INTO get_port_in_case_old_esn_rec;
        CLOSE get_port_in_case_old_esn_curs;
        --
        IF (get_port_in_case_old_esn_rec.old_esn IS NOT NULL) THEN
          --
          l_v_old_esn := get_port_in_case_old_esn_rec.old_esn;
          --
        ELSE
          --
          l_v_old_esn := rec_case_detail.x_esn;
          --
        END IF;
        --
      ELSE
        --
        l_v_old_esn := rec_case_detail.x_esn;
        --
      END IF;
      --CR22152 End Kacosta 10/15/2012
      --
      IF (   (rec_case_detail.x_case_type = 'Port In'       AND rec_case_detail.s_title = 'INTERNAL')
          OR (rec_case_detail.x_case_type = 'Phone Upgrade' AND rec_case_detail.s_title = 'ST PHONE UPGRADE')
          OR (rec_case_detail.x_case_type = 'Phone Upgrade' AND rec_case_detail.s_title = 'PHONE UPGRADE')
          OR (rec_case_detail.x_case_type = 'Port In'       AND rec_case_detail.s_title = 'INTERNAL SIM EXCHANGE')
          OR (rec_case_detail.x_case_type = 'Port In'       AND rec_case_detail.s_title = 'INTERNAL TECH EXCHANGE')
          OR (rec_case_detail.x_case_type = 'Port In'       AND rec_case_detail.s_title = 'ST AUTO INTERNAL')
          OR (rec_case_detail.x_case_type = 'Units'         AND rec_case_detail.s_title = 'UNIT TRANSFER') ) THEN
        l_upgrade_flag                 := 'Y';
      END IF;
      -- Old ESN Check
      --
      --CR22152 Start Kacosta 10/15/2012
      --OPEN cur_esn_detail(rec_case_detail.x_esn);
      OPEN cur_esn_detail(l_v_old_esn);
      --CR22152 End Kacosta 10/15/2012
      --
      FETCH cur_esn_detail
      INTO rec_old_esn_detail;
      IF cur_esn_detail%NOTFOUND THEN
        p_error_code := 301;
        p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
        CLOSE cur_esn_detail;
        RETURN;
      END IF;
      CLOSE cur_esn_detail;
      -- New ESN Check
      OPEN cur_esn_detail(p_new_esn);
      FETCH cur_esn_detail INTO rec_new_esn_detail;
      IF cur_esn_detail%NOTFOUND THEN
        p_error_code := 301;
        p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
        CLOSE cur_esn_detail;
        RETURN;
      END IF;
      CLOSE cur_esn_detail;
      IF l_upgrade_flag = 'Y' THEN
        FOR rec_act_promo_enrollment IN cur_act_promo_enrollment(rec_old_esn_detail.part_serial_no ,rec_new_esn_detail.brand_name)
        LOOP
          INSERT
          INTO x_enroll_promo_grp2esn_hist
            (
              objid ,
              x_start_date ,
              x_end_date ,
              x_action_date ,
              x_action_type ,
              x_esn ,
              promo_grp2esn_objid ,
              promo_objid ,
              program_enrolled_objid
            )
            VALUES
            (
              sa.seq_enroll_promo_grp2esn_hist.nextval ,
              rec_act_promo_enrollment.x_start_date ,
              rec_act_promo_enrollment.x_end_date ,
              SYSDATE ,
              'Handset transfer' ,
              rec_act_promo_enrollment.x_esn ,
              rec_act_promo_enrollment.objid ,
              rec_act_promo_enrollment.promo_objid ,
              rec_act_promo_enrollment.program_enrolled_objid
            );
          UPDATE x_enroll_promo_grp2esn_hist
          SET x_esn                = p_new_esn ,
            x_start_date           = rec_new_esn_detail.x_enrolled_date ,
            program_enrolled_objid = rec_new_esn_detail.enrolled_objid
          WHERE objid              = rec_act_promo_enrollment.objid;
        END LOOP;
      END IF;
      UPDATE x_enroll_promo_grp2esn
      SET x_esn = p_new_esn
        --CR22152 Start Kacosta 10/15/2012
        --WHERE x_esn = rec_case_detail.x_esn;
      WHERE x_esn = l_v_old_esn;
      --CR22152 End Kacosta 10/15/2012
      UPDATE x_program_enrolled pe
      SET x_esn              = p_new_esn ,
        pgm_enroll2site_part = rec_new_esn_detail.site_part , --CR20399
        pgm_enroll2part_inst = rec_new_esn_detail.part_inst , --CR20399
        pgm_enroll2contact   = rec_new_esn_detail.contact     --CR20399
        --CR22152 Start Kacosta 10/15/2012
        --WHERE x_esn = rec_case_detail.x_esn;
      WHERE x_esn = l_v_old_esn
        --CR47566 Only update the old esn to new when status is ENROLLED
        AND x_enrollment_status = 'ENROLLED'
        --CR22380 Handset protection, adding NOT EXISTS check to exclude programs which are not eligible for transferring.
      AND NOT EXISTS
        (SELECT 'X'
        FROM table_x_parameters xp,
          x_program_parameters pp
        WHERE xp.X_PARAM_NAME = 'NOT ELIGIBLE FOR TRANSFERRING'
        AND xp.x_param_value  = pp.x_prog_class
        AND pp.objid          = pe.pgm_enroll2pgm_parameter
        ) ;
      --CR22152 End Kacosta 10/15/2012
      --RRS CR26084
      FOR i IN
      (SELECT objid
      FROM x_program_parameters
      WHERE objid IN
        (SELECT pgm_enroll2pgm_parameter
        FROM x_program_enrolled
        WHERE x_esn = p_new_esn
        )
      )
      LOOP
        enroll_promo_pkg.sp_get_eligible_promo(p_new_esn ,i.objid ,'ENROLLMENT' ,v_promo_objid ,v_promo_code ,v_script_id ,v_error_code ,v_error_msg);
        IF v_error_msg = 'SUCCESS' THEN
          UPDATE X_PROGRAM_ENROLLED
          SET pgm_enroll2x_promotion   = v_promo_objid
          WHERE X_ESN                  = P_NEW_ESN
          AND pgm_enroll2pgm_parameter = i.objid;
        END IF;
      END LOOP;
      --RRS CR26084
    EXCEPTION
    WHEN OTHERS THEN
      v_error_message := SQLERRM;
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
          SUBSTR(v_error_message
          ||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),1,4000),
          sysdate,
          'SP TRANSFER PROMO ENROLLMENT ',
          p_new_esn,
          'ENROLL_PROMO_PKB.sp_transfer_promo_enrollment'
        );
      COMMIT;
    END sp_transfer_promo_enrollment;
  PROCEDURE sp_deenroll_promo_enrollment
    (
      p_esn                    IN VARCHAR2 ,
      p_program_enrolled_objid IN NUMBER ,
      p_enrollment_flag        IN VARCHAR2 ,
      p_error_code OUT NUMBER ,
      p_error_msg OUT VARCHAR2
    )
  IS
    CURSOR cur_program_enroll_detail
    IS
      SELECT pe.* ,
        (SELECT org_id
        FROM table_bus_org tb ,
          x_program_parameters pp
        WHERE tb.objid = pp.prog_param2bus_org
        AND pp.objid   = pe.pgm_enroll2pgm_parameter
        ) brand_name
    FROM x_program_enrolled pe
    WHERE objid = p_program_enrolled_objid
    AND x_esn   = p_esn;
    rec_program_enroll_detail cur_program_enroll_detail%ROWTYPE;
    --CR20399 Net10 promo logic
    CURSOR cur_act_promo_enrollment(c_brand_name IN VARCHAR2)
    IS
      SELECT pe.* ,
        NVL(
        (SELECT pr.promo_id
        FROM x_promotion_relation pr
        WHERE 1                  = 1
        AND pr.relationship_type = 'REPLACEMENT'
        AND pr.related_promo_id  = pe.promo_objid
        AND ROWNUM               < 2
        ) ,0) is_replacement ,
        NVL(
        (SELECT pr2.related_promo_id
        FROM x_promotion_relation pr ,
          x_promotion_relation pr2
        WHERE 1                   = 1
        AND pr2.promo_id          = pr.promo_id
        AND pr2.relationship_type = 'REPLACEMENT'
        AND pr.related_promo_id   = pe.promo_objid
        AND pr.relationship_type  = 'REPLACEMENT'
        AND ROWNUM                < 2
        ) ,0) is_parent
      FROM x_enroll_promo_grp2esn pe
      WHERE 1                    = 1
      AND x_esn                  = p_esn
      AND program_enrolled_objid = p_program_enrolled_objid
      AND 1                      =
        CASE
          WHEN c_brand_name                            IN ('STRAIGHT_TALK','SIMPLE_MOBILE')--CR31853
          AND SYSDATE BETWEEN NVL(x_start_date ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1)
          THEN 1
          WHEN c_brand_name = 'NET10'
          THEN 1
          WHEN SYSDATE BETWEEN NVL(x_start_date --CR36105
            ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1)
          THEN 1
          ELSE 0
        END;
      --and    sysdate between nvl(x_start_date, sysdate - 1) and nvl(x_end_date,sysdate + 1);
      rec_act_promo_enrollment cur_act_promo_enrollment%ROWTYPE;
      /** web objid associated to ESN account **/
      CURSOR webxesn_cur(v_esn VARCHAR2)
      IS
        SELECT web.objid
        FROM table_part_inst pi ,
          table_x_contact_part_inst cpi ,
          table_web_user web
        WHERE pi.part_serial_no             = v_esn
        AND pi.objid                        = cpi.x_contact_part_inst2part_inst
        AND cpi.x_contact_part_inst2contact = web.web_user2contact;
      webxesn_rec webxesn_cur%ROWTYPE;
      /** list of ESN in the same account except origigal ESN enrolled in promo replacement**/
      CURSOR esnsxacc_cur ( v_web NUMBER ,v_esn VARCHAR2 ,v_enr_promo NUMBER ,v_promo NUMBER ,c_brand_name VARCHAR2 )
      IS
        SELECT pi.part_serial_no ,
          ge.*
        FROM table_part_inst pi ,
          table_x_contact_part_inst cpi ,
          table_web_user web ,
          x_enroll_promo_grp2esn ge
        WHERE web.objid                     = v_web
        AND pi.objid                        = cpi.x_contact_part_inst2part_inst
        AND cpi.x_contact_part_inst2contact = web.web_user2contact
        AND ge.x_esn                        = pi.part_serial_no
        AND (ge.promo_objid                 = v_promo
        OR ge.promo_objid                  IN
          (SELECT promo_id
          FROM x_promotion_relation r2
          WHERE r2.relationship_type = 'REPLACEMENT'
          AND r2.related_promo_id   IN
            (SELECT promo_id
            FROM x_promotion_relation
            WHERE related_promo_id = v_promo --replacement
            AND relationship_type  = 'PARENT_CHILD'
            AND promo_id NOT      IN (v_enr_promo)
            )
          ))                             -- promo esn deenrolled
        AND pi.x_part_inst_status = '52' --CR20399
        AND 1                     =
          CASE
            WHEN c_brand_name                            IN ('STRAIGHT_TALK','SIMPLE_MOBILE')--CR31853
            AND SYSDATE BETWEEN NVL(x_start_date ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1)
            THEN 1
            WHEN c_brand_name = 'NET10'
            THEN 1
            WHEN SYSDATE BETWEEN NVL(x_start_date -- CR36105
              ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1)
            THEN 1
            ELSE 0
          END
          --    and sysdate between nvl(x_start_date, sysdate - 1) and nvl(x_end_date,sysdate + 1)
        AND pi.part_serial_no NOT IN (v_esn);
        esnsxacc_rec esnsxacc_cur%ROWTYPE;
        FUNCTION replace_promo(
            f_promo_objid IN NUMBER)
          RETURN NUMBER
        IS
          CURSOR promo_curs
          IS
            SELECT related_promo_id
            FROM x_promotion_relation
            WHERE promo_id        = f_promo_objid
            AND relationship_type = 'REPLACEMENT';
          promo_rec promo_curs%ROWTYPE;
        BEGIN
          OPEN promo_curs;
          FETCH promo_curs INTO promo_rec;
          CLOSE promo_curs;
          RETURN promo_rec.related_promo_id;
        END;
      BEGIN
        p_error_code := 0;
        p_error_msg  := 'Success';
        OPEN cur_program_enroll_detail;
        FETCH cur_program_enroll_detail INTO rec_program_enroll_detail;
        IF cur_program_enroll_detail%NOTFOUND THEN
          p_error_code := 304;
          p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
          CLOSE cur_program_enroll_detail;
          RETURN;
        END IF;
        CLOSE cur_program_enroll_detail;
        IF p_enrollment_flag = 'Y' THEN
			UPDATE x_program_enrolled pe
               SET x_enrollment_status = 'READYTOREENROLL',--'DEENROLLED' --CR20399
				   x_exp_date = NULL,
                   x_cooling_exp_date = NULL,
                   x_next_delivery_date = NULL,
                   x_next_charge_date = NULL,
                   x_grace_period = NULL,
                   x_cooling_period = NULL,
                   x_service_days = NULL,
                   x_wait_exp_date = NULL,
                   x_tot_grace_period_given = NULL,
                   x_update_stamp = sysdate
          WHERE objid             = p_program_enrolled_objid
          AND x_esn               = p_esn
            --AND NVL(pgm_enroll2x_promotion,0) = 0; ??  CR22380 begin
          AND NOT EXISTS
            (SELECT 'X'
            FROM X_PROGRAM_PARAMETERS PP
            WHERE PP.X_PROG_CLASS = 'WARRANTY'
            AND PP.OBJID          = PE.PGM_ENROLL2PGM_PARAMETER
            ); --CR22380 end
        END IF;
        UPDATE x_enroll_promo_grp2esn
        SET x_end_date =
          CASE
            WHEN rec_program_enroll_detail.brand_name = 'NET10'
            THEN --Cr20399
              NULL
            ELSE SYSDATE
          END
        WHERE 1                    = 1
        AND x_esn                  = p_esn
        AND program_enrolled_objid = p_program_enrolled_objid
        AND SYSDATE BETWEEN NVL(x_start_date ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1);
        --- CR20399 NET10 promo logic
        -- check if ESN is net10 and ESN have any other ESN enrolled in promo unlimited in the same account and ESN is enrolled in parent promotion
        --
        OPEN cur_act_promo_enrollment(rec_program_enroll_detail.brand_name);
        FETCH cur_act_promo_enrollment INTO rec_act_promo_enrollment;
        -- check record in group2esn_promo for ESN
        IF cur_act_promo_enrollment%NOTFOUND THEN
          p_error_code := 304;
          p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
          CLOSE cur_act_promo_enrollment;
          RETURN;
        END IF;
        CLOSE cur_act_promo_enrollment;
        IF rec_program_enroll_detail.brand_name = 'NET10' AND (1 = sa.check_unl_family(p_esn ,rec_program_enroll_detail.pgm_enroll2pgm_parameter)) AND (rec_act_promo_enrollment.is_parent > 0) THEN
          dbms_output.put_line('ESN is primary need to exchange for other family');
          OPEN webxesn_cur(p_esn);
          FETCH webxesn_cur INTO webxesn_rec;
          -- check web objid for account
          IF webxesn_cur%NOTFOUND THEN
            p_error_code := 304;
            p_error_msg  := sa.get_code_fun('ENROLL_PROMO_PKG' ,p_error_code ,'ENGLISH');
            CLOSE webxesn_cur;
            dbms_output.put_line('ESN without account ');
            RETURN;
          END IF;
          CLOSE webxesn_cur;
          dbms_output.put_line('ESN with account');
          dbms_output.put_line('replacement :' || TO_CHAR(rec_act_promo_enrollment.is_replacement));
          dbms_output.put_line('brand_name :' || rec_program_enroll_detail.brand_name);
          dbms_output.put_line('web objid  :' || TO_CHAR(webxesn_rec.objid));
          dbms_output.put_line('p_esn' || TO_CHAR(p_esn));
          dbms_output.put_line('is_parent' || TO_CHAR(rec_act_promo_enrollment.is_parent));
          ---  get first esn in the list of esn associated to the account with replacement promo
          OPEN esnsxacc_cur(webxesn_rec.objid ,p_esn ,rec_act_promo_enrollment.is_parent ,rec_act_promo_enrollment.is_replacement ,rec_program_enroll_detail.brand_name);
          FETCH esnsxacc_cur INTO esnsxacc_rec;
          -- check if alter esn is enrolled in unl or unl ILD
          dbms_output.put_line('alter new esn: ' || esnsxacc_rec.part_serial_no);
          IF esnsxacc_cur%FOUND THEN
            dbms_output.put_line('ESN will be exchange for family with replacement');
            -- deenrolled ESN alter from the promo
            UPDATE x_enroll_promo_grp2esn
            SET x_end_date             = SYSDATE
            WHERE 1                    = 1
            AND x_esn                  = esnsxacc_rec.part_serial_no
            AND program_enrolled_objid = esnsxacc_rec.program_enrolled_objid
            AND SYSDATE BETWEEN NVL(x_start_date ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1);
            --
            INSERT
            INTO x_enroll_promo_grp2esn_hist
              (
                objid ,
                x_start_date ,
                x_end_date ,
                x_action_date ,
                x_action_type ,
                x_esn ,
                promo_grp2esn_objid ,
                promo_objid ,
                program_enrolled_objid
		,x_holiday_promo_balance	--CR44499
              )
              VALUES
              (
                sa.seq_enroll_promo_grp2esn_hist.nextval ,
                esnsxacc_rec.x_start_date ,
                esnsxacc_rec.x_end_date ,
                SYSDATE ,
                'Deenrollment' ,
                esnsxacc_rec.part_serial_no ,
                esnsxacc_rec.objid ,
                esnsxacc_rec.promo_objid ,
                esnsxacc_rec.program_enrolled_objid
		,esnsxacc_rec.x_holiday_promo_balance	--CR44499
              );
            dbms_output.put_line('new_esn ' || TO_CHAR(esnsxacc_rec.part_serial_no));
            dbms_output.put_line('is parent' || TO_CHAR(rec_act_promo_enrollment.is_parent));
            dbms_output.put_line('enrolled_objid new esn' || TO_CHAR(esnsxacc_rec.program_enrolled_objid));
            dbms_output.put_line('objid replacement : ' || TO_CHAR(replace_promo(esnsxacc_rec.promo_objid)));
            -- enrolled new ESN into promo replacement
            sa.enroll_promo_pkg.sp_register_esn_promo(esnsxacc_rec.part_serial_no ,
            --  rec_act_promo_enrollment.is_parent,
            (replace_promo(esnsxacc_rec.promo_objid)) ,esnsxacc_rec.program_enrolled_objid ,p_error_code ,p_error_msg);
          END IF;
          CLOSE esnsxacc_cur;
        END IF;
        COMMIT;
        --- end CR20399
      END sp_deenroll_promo_enrollment;
      PROCEDURE sp_get_eligible_promo_esn
        (
          p_esn IN VARCHAR2 ,
          p_promo_objid OUT NUMBER ,
          p_promo_code OUT VARCHAR2 ,
          p_script_id OUT VARCHAR2 ,
          p_error_code OUT NUMBER ,
          p_error_msg OUT VARCHAR2
        )
      IS
        CURSOR esn_promo_curs2
        IS
          SELECT pp.objid pp_objid
          FROM table_site_part sp ,
            x_service_plan_site_part spsp ,
            x_service_plan plan ,
            mtm_sp_x_program_param mtm ,
            x_program_parameters pp
          WHERE x_service_id          = p_esn
          AND spsp.table_site_part_id = sp.objid
          AND plan.objid              = spsp.x_service_plan_id
          AND mtm.x_sp2program_param  = pp.objid
          AND mtm.program_para2x_sp   = plan.objid
          AND pp.objid               IN
            (SELECT DISTINCT (program_objid) FROM x_enroll_promo_extra
            ); --CR20399
        CURSOR esn_promo_curs3
        IS
          SELECT pp.objid pp_objid
          FROM x_program_enrolled pe ,
            x_program_parameters pp
          WHERE pe.x_esn = p_esn
          AND pe.x_enrollment_status
            || ''      = 'ENROLLED'
          AND pp.objid = pe.pgm_enroll2pgm_parameter
          AND EXISTS
            (SELECT 1
            FROM table_bus_org bo
            WHERE org_id = 'NET10'
            AND objid    = pp.prog_param2bus_org
            );
        v_error_message VARCHAR2(1000);
      BEGIN
        sp_get_eligible_promo(p_esn ,NULL , --esn_promo_rec.pp_objid,
        NULL ,                              --'RECURRING',
        p_promo_objid ,p_promo_code ,p_script_id ,p_error_code ,p_error_msg);
        IF p_promo_objid IS NOT NULL THEN
          dbms_output.put_line('1 p_promo_objid:' || p_promo_objid);
          p_error_code := 0;
          p_error_msg  := 'SUCCESS';
          RETURN;
        END IF;
        FOR esn_promo_rec IN esn_promo_curs2
        LOOP
          sp_get_eligible_promo(p_esn ,esn_promo_rec.pp_objid ,'ENROLLMENT' ,p_promo_objid ,p_promo_code ,p_script_id ,p_error_code ,p_error_msg);
          IF p_promo_objid IS NOT NULL THEN
            dbms_output.put_line('2 p_promo_objid:' || p_promo_objid);
            p_error_code := 0;
            p_error_msg  := 'SUCCESS';
            RETURN;
          END IF;
        END LOOP;
        FOR esn_promo_rec IN esn_promo_curs3
        LOOP
          sp_get_eligible_promo(p_esn ,esn_promo_rec.pp_objid ,'ENROLLMENT' ,p_promo_objid ,p_promo_code ,p_script_id ,p_error_code ,p_error_msg);
          IF p_promo_objid IS NOT NULL THEN
            dbms_output.put_line('3 p_promo_objid:' || p_promo_objid);
            p_error_code := 0;
            p_error_msg  := 'SUCCESS';
            RETURN;
          END IF;
        END LOOP;
        p_error_code := 306;
        p_error_msg  := 'not enrolled in program';
      EXCEPTION
      WHEN OTHERS THEN
        v_error_message := SQLERRM;
        p_error_code    := 1000;
        p_error_msg     := 'Exception =' || v_error_message;
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
            SUBSTR(v_error_message
            ||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),1,4000),
            sysdate,
            'GET ELIGIBLE PROMO ',
            p_esn,
            'ENROLL_PROMO_PKB.SP_GET_ELIGIBLE_PROMO_ESN'
          );
        COMMIT;
      END;
    PROCEDURE sp_get_eligible_promo_esn3
      (
        p_esn           IN VARCHAR2 ,
        p_program_objid IN NUMBER ,
        p_promo_objid OUT NUMBER ,
        p_promo_code OUT VARCHAR2 ,
        p_script_id OUT VARCHAR2 ,
        p_error_code OUT NUMBER ,
        p_error_msg OUT VARCHAR2
	,p_ignore_attached_promo IN VARCHAR2  DEFAULT 'N' -- CR42785 This flag is Y in CBO service register promo
      )
    IS
      CURSOR esn_status_curs
      IS
        SELECT x_part_inst_status FROM table_part_inst WHERE part_serial_no = p_esn;
      esn_status_rec esn_status_curs%ROWTYPE;
      CURSOR esn_promo_curs
      IS
        SELECT pp.objid pp_objid
        FROM table_site_part sp ,
          x_service_plan_site_part spsp ,
          x_service_plan plan ,
          mtm_sp_x_program_param mtm ,
          x_program_parameters pp
        WHERE x_service_id          = p_esn
        AND spsp.table_site_part_id = sp.objid
        AND plan.objid              = spsp.x_service_plan_id
        AND mtm.x_sp2program_param  = pp.objid
        AND mtm.program_para2x_sp   = plan.objid
        AND pp.objid                = p_program_objid
        AND pp.objid               IN
          (SELECT DISTINCT (program_objid) FROM x_enroll_promo_extra
          ); --CR20399
      --       and exists (select pe.x_enrollment_status
      --                     from x_program_enrolled pe
      --                    where objid  = p_program_objid
      --                      and x_esn  = p_esn
      --                      and pe.x_enrollment_status = 'ENROLLED');
      --AND pp.X_PROGRAM_NAME in ( 'Straight Talk Unlimited','Straight Talk',
      --'UNLIMITED 30-DAY MONTHLY PLAN', 'UNLIMITED 30-DAY MONTHLY PLAN ILD');  --CR20399
      --'Straight Talk 90',
      --'Straight Talk 180',
      --'Straight Talk 365');
      CURSOR esn_promo_curs2
      IS
        SELECT pp.objid pp_objid
        FROM x_service_plan plan ,
          mtm_sp_x_program_param mtm ,
          x_program_parameters pp
        WHERE 1                    = 1
        AND mtm.x_sp2program_param = pp.objid
        AND mtm.program_para2x_sp  = plan.objid
        AND pp.objid               = p_program_objid
        AND pp.objid              IN
          (SELECT DISTINCT (program_objid) FROM x_enroll_promo_extra
          ); --CR20399
      -- AND pp.X_PROGRAM_NAME in ( 'Straight Talk Unlimited','Straight Talk',
      -- 'UNLIMITED 30-DAY MONTHLY PLAN', 'UNLIMITED 30-DAY MONTHLY PLAN ILD'); --CR20399
    BEGIN
      sp_get_eligible_promo(p_esn ,p_program_objid ,'RECURRING' ,p_promo_objid ,p_promo_code ,p_script_id ,p_error_code ,p_error_msg
      ,NVL(p_ignore_attached_promo, 'N')
      );
      IF p_promo_objid IS NOT NULL THEN
        dbms_output.put_line('1 p_promo_objid:' || p_promo_objid);
        RETURN;
      END IF;
      OPEN esn_status_curs;
      FETCH esn_status_curs INTO esn_status_rec;
      IF esn_status_rec.x_part_inst_status != '52' THEN
        FOR esn_promo_rec IN esn_promo_curs2
        LOOP
          sp_get_eligible_promo(p_esn ,esn_promo_rec.pp_objid ,'ENROLLMENT' ,p_promo_objid ,p_promo_code ,p_script_id ,p_error_code ,p_error_msg
	  ,NVL(p_ignore_attached_promo, 'N')
	  );
          IF p_promo_objid IS NOT NULL THEN
            dbms_output.put_line('2 p_promo_objid:' || p_promo_objid);
            CLOSE esn_status_curs;
            RETURN;
          END IF;
        END LOOP;
      ELSE
        FOR esn_promo_rec IN esn_promo_curs
        LOOP
          sp_get_eligible_promo(p_esn ,esn_promo_rec.pp_objid ,'ENROLLMENT' ,p_promo_objid ,p_promo_code ,p_script_id ,p_error_code ,p_error_msg
	  ,NVL(p_ignore_attached_promo, 'N')
	  );
          IF p_promo_objid IS NOT NULL THEN
            dbms_output.put_line('2 p_promo_objid:' || p_promo_objid);
            CLOSE esn_status_curs;
            RETURN;
          END IF;
        END LOOP;
      END IF;
      CLOSE esn_status_curs;
      p_error_code := 306;
      p_error_msg  := 'not enrolled in program';
    END;
  PROCEDURE sp_get_eligible_promo_esn2(
      p_esn IN VARCHAR2 ,
      p_promo_objid OUT NUMBER ,
      p_promo_code OUT VARCHAR2 ,
      p_script_id OUT VARCHAR2 ,
      p_error_code OUT NUMBER ,
      p_error_msg OUT VARCHAR2 )
  IS
  BEGIN
    p_error_code := 306;
    p_error_msg  := 'not enrolled in program';
    sp_get_eligible_promo(p_esn ,NULL , --esn_promo_rec.pp_objid,
    NULL ,                              --'RECURRING',
    p_promo_objid ,p_promo_code ,p_script_id ,p_error_code ,p_error_msg);
  END;
  PROCEDURE sp_register_esn_promo2(
      p_esn         IN VARCHAR2 ,
      p_promo_objid IN NUMBER ,
      p_error_code OUT NUMBER ,
      p_error_msg OUT VARCHAR2 )
  AS
    pragma autonomous_transaction;
    CURSOR esn_promo_curs
    IS
      SELECT objid
      FROM x_program_enrolled
      WHERE x_esn             = p_esn
      AND x_enrollment_status = 'ENROLLED'
        --CR22152 Start Kacosta 11/5/2012
      ORDER BY x_insert_date DESC;
    --CR22152 End Kacosta 11/5/2012
  BEGIN
    p_error_code := 306;
    p_error_msg  := 'not enrolled in program';
    FOR esn_promo_rec IN esn_promo_curs
    LOOP
      sp_register_esn_promo(p_esn ,p_promo_objid ,esn_promo_rec.objid ,p_error_code ,p_error_msg);
      EXIT;
    END LOOP;
  END;
  PROCEDURE sp_swap_program(
      p_esn               IN VARCHAR2 ,
      p_old_program_objid IN NUMBER ,
      p_new_program_objid IN NUMBER ,
      p_error_code OUT NUMBER ,
      p_error_msg OUT VARCHAR2 )
  IS
    CURSOR cur_act_program_enrollment
    IS
      SELECT *
      FROM x_enroll_promo_grp2esn
      WHERE 1                    = 1
      AND x_esn                  = p_esn
      AND program_enrolled_objid = p_old_program_objid
      AND SYSDATE BETWEEN NVL(x_start_date ,SYSDATE - 1) AND NVL(x_end_date ,SYSDATE + 1);
    rec_act_program_enrollment cur_act_program_enrollment%ROWTYPE;
  BEGIN
    OPEN cur_act_program_enrollment;
    FETCH cur_act_program_enrollment INTO rec_act_program_enrollment;
    IF cur_act_program_enrollment%NOTFOUND THEN
      p_error_code := 307;
      p_error_msg  := 'program not active';
    END IF;
    INSERT
    INTO x_enroll_promo_grp2esn_hist
      (
        objid ,
        x_start_date ,
        x_end_date ,
        x_action_date ,
        x_action_type ,
        x_esn ,
        promo_grp2esn_objid ,
        promo_objid ,
        program_enrolled_objid
      )
      VALUES
      (
        sa.seq_enroll_promo_grp2esn_hist.nextval ,
        rec_act_program_enrollment.x_start_date ,
        rec_act_program_enrollment.x_end_date ,
        SYSDATE ,
        'swap program' ,
        rec_act_program_enrollment.x_esn ,
        rec_act_program_enrollment.objid ,
        rec_act_program_enrollment.promo_objid ,
        rec_act_program_enrollment.program_enrolled_objid
      );
    UPDATE x_enroll_promo_grp2esn_hist
    SET program_enrolled_objid = p_new_program_objid
    WHERE promo_grp2esn_objid  = rec_act_program_enrollment.objid;
    UPDATE x_enroll_promo_grp2esn
    SET program_enrolled_objid = p_new_program_objid
    WHERE objid                = rec_act_program_enrollment.objid;
    CLOSE cur_act_program_enrollment;
    p_error_code := 0;
    p_error_msg  := 'Success';
  END;
PROCEDURE get_discount_amount (
    p_esn               IN VARCHAR2,   ---ESN
    p_promo_objid       IN VARCHAR2,   ---Promotion OBJID
    p_retail_price      IN VARCHAR2,   ---Price for the enrolled service plan
    p_discount_amount   OUT NUMBER,    ---Dollar Discount Amount
    p_result            OUT NUMBER     ---Status
) IS

    v_price              NUMBER;
    v_discount_percent   NUMBER;
    v_discount_amount    NUMBER;

    -- Fetch the record. Only one record will be available.
   -- If no records found, then the pricing is not available for the part num.
    CURSOR price_cur IS
        SELECT
            tp.*
        FROM
            table_x_pricing tp
        WHERE
                tp.x_pricing2part_num IN (
                    SELECT
                        xpp.prog_param2prtnum_monfee
                    FROM
                        x_program_parameters xpp
                    WHERE
                            xpp.x_is_recurring = '1'
                        AND
                            xpp.objid IN (
                                SELECT
                                    pgm_enroll2pgm_parameter
                                FROM
                                    x_program_enrolled pe
                                WHERE
                                        pe.pgm_enroll2x_promotion = p_promo_objid
                                    AND
                                        pe.x_esn = p_esn
                            )
                )
            AND
                SYSDATE BETWEEN tp.x_start_date AND tp.x_end_date;

    price_rec            price_cur%rowtype;
   -- Fetch the record. Only one record will be available.
   -- If no records found, then the promocode is invalid
    CURSOR percent_cur IS
        SELECT
            txp.x_discount_percent,
            txp.x_discount_amount
        FROM
            table_x_promotion txp
        WHERE
            txp.objid = p_promo_objid;

    percent_rec          percent_cur%rowtype;
BEGIN

p_discount_amount := 0; --51609
p_result := 0;          --51609

    OPEN percent_cur;
    FETCH percent_cur INTO percent_rec;
    --IF percent_cur%NOTFOUND THEN
    --  CLOSE percent_cur;
    v_discount_amount := percent_rec.x_discount_amount;
    v_discount_percent := percent_rec.x_discount_percent;
    CLOSE percent_cur;
    OPEN price_cur;
    FETCH price_cur INTO price_rec;
   --IF price_cur%NOTFOUND THEN
   -- CLOSE price_cur;
    v_price := price_rec.x_retail_price;
    CLOSE price_cur;
    IF
        nvl(
            p_retail_price,
            0
        ) = 0
    THEN
        IF
            nvl(
                v_discount_amount,
                0
            ) > 0
        THEN
            p_discount_amount := TO_CHAR(v_discount_amount);
        ELSIF nvl(
            v_discount_percent,
            0
        ) > 0 THEN
            p_discount_amount := TO_CHAR(v_discount_percent / 100 * v_price);
            p_discount_amount := p_discount_amount;
            p_result := 0; --'succesful';
            dbms_output.put_line('Discount Amount is :' || p_discount_amount);
            dbms_output.put_line('Result is :' || p_result);
        END IF;
    ELSIF nvl(
        p_retail_price,
        0
    ) > 0 THEN
        IF
            nvl(
                v_discount_amount,
                0
            ) > 0
        THEN
            p_discount_amount := TO_CHAR(v_discount_amount);
        ELSIF nvl(
            v_discount_percent,
            0
        ) > 0 THEN
            v_price := p_retail_price;
            p_discount_amount := TO_CHAR(v_discount_percent / 100 * v_price);
        END IF;

        p_discount_amount := p_discount_amount;
        p_result := 0; --'succesful';
        dbms_output.put_line('Discount Amount is :' || p_discount_amount);
        dbms_output.put_line('Result is :' || p_result);
    ELSE
        p_discount_amount := 0;
        p_result :=-1; --'not found';
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        p_discount_amount := 0;
        p_result := sqlcode; --'fail exception';
        return;
END;

END enroll_promo_pkg;
/