CREATE OR REPLACE PROCEDURE sa."GET_DYNAMIC_TRANS_SUMMARY" (
    p_source_system               IN dynamic_trans_sum_params.source_system%TYPE,
    p_brand                       IN dynamic_trans_sum_params.brand_name%TYPE,
    p_language                    IN dynamic_trans_sum_params.language%TYPE DEFAULT 'ENG',
    p_esn                         IN table_part_inst.part_serial_no%TYPE,
    p_transaction_type            IN dynamic_trans_sum_params.transaction_type%TYPE,
    p_retention_type              IN dynamic_trans_sum_params.retention_type%TYPE,
    p_program_id                  IN x_program_enrolled.pgm_enroll2pgm_parameter%TYPE,
    p_acc_num_name_reg_name       IN dynamic_trans_sum_params.param_name%TYPE,
    p_acc_num_name_10_dollar_name IN dynamic_trans_sum_params.param_name%TYPE,
    p_reactivation_flag           IN VARCHAR2 DEFAULT 'FALSE',
    p_confirmation_message        OUT dynamic_trans_sum_params.param_value%TYPE,
    p_transaction_script          OUT dynamic_trans_sum_params.param_value%TYPE,
    p_expire_dt                   OUT DATE,
    p_next_refill_date            OUT DATE,
    p_acc_num_name_reg            OUT dynamic_trans_sum_params.param_value%TYPE,
    p_acc_num_name_10_dollar      OUT dynamic_trans_sum_params.param_value%TYPE,
    p_cards_in_reserve            OUT INTEGER,
    p_more_info                   OUT dynamic_trans_sum_params.param_value%TYPE,
    p_device_name                 OUT table_x_contact_part_inst.x_esn_nick_name%TYPE,
    p_group_id                    OUT x_account_group_member.account_group_id%TYPE,
    p_group_name                  OUT x_account_group.account_group_name%TYPE)
AS
  /**********************************************************************************************/
  /*    Copyright   2014 Tracfone  Wireless Inc. All rights reserved                            */
  /*                                                                                            */
  /* NAME:         GET_DYNAMIC_TRANS_SUMMARY                                                    */
  /* PURPOSE:      To return dynamic transaction summary details                                */
  /* FREQUENCY:                                                                                 */
  /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                             */
  /*                                                                                            */
  /* REVISIONS:                                                                                 */
  /* VERSION  DATE        WHO              PURPOSE                                              */
  /* -------  ---------- -----     ------------------------------------------------------------ */
  /*  1.0     07/17/2015 sethiraj  CR35913 To return dynamic transaction summary details        */
  /**********************************************************************************************/
  --
  err_code VARCHAR2(4000) ;
  err_msg VARCHAR2(4000) ;
  --
	CURSOR confirmation_message_cur IS
	SELECT param_value FROM dynamic_trans_sum_params
	WHERE source_system = p_source_system
		  AND brand_name = p_brand
	    AND transaction_type = p_transaction_type
	    AND language = p_language
	    AND param_name = 'CONFIRMATION_MESSAGE';
	confirmation_message_rec confirmation_message_cur%rowtype;
	--
	CURSOR transaction_script_cur IS
	SELECT param_value FROM dynamic_trans_sum_params
	WHERE source_system = p_source_system
		  AND brand_name = p_brand
      AND transaction_type = p_transaction_type
		  AND retention_type = p_retention_type
      AND language = p_language
      AND param_name = 'TRANSACTION_SCRIPT';
	transaction_script_rec transaction_script_cur%rowtype;
  --
  CURSOR access_number_cur (c_access_number_name dynamic_trans_sum_params.param_name%TYPE) IS
	SELECT param_value FROM dynamic_trans_sum_params
		  WHERE source_system = p_source_system
		  AND brand_name = p_brand
           AND param_name = c_access_number_name;
	access_number_rec access_number_cur%rowtype;
	--

	--
	CURSOR next_refill_date_hpp_cur IS
	SELECT x_charge_date, x_next_charge_date FROM
		  (SELECT pe.x_charge_date, pe.x_next_charge_date
          FROM x_program_enrolled pe,
          x_program_parameters pp
          WHERE pe.x_esn                 = p_esn
          AND pe.x_enrollment_status NOT IN
                            ('DEENROLLED',
                             'ENROLLMENTFAILED',
                             'READYTOREENROLL')
          AND (pe.x_next_charge_date    IS NOT NULL
          OR pe.x_next_delivery_date    IS NOT NULL)
          AND pp.objid                   = pe.pgm_enroll2pgm_parameter
          AND nvl(pp.x_prog_class,' ')  = 'WARRANTY'
          AND pe.pgm_enroll2pgm_parameter= p_program_id
          ORDER BY pe.x_enrolled_date DESC)
	WHERE ROWNUM < 2 ;
  next_refill_date_hpp_rec next_refill_date_hpp_cur%rowtype;
  --
  CURSOR next_refill_date_cur IS
	SELECT x_charge_date, x_next_charge_date FROM
		  (SELECT pe.x_charge_date, pe.x_next_charge_date
          FROM x_program_enrolled pe,
          x_program_parameters pp
          WHERE pe.x_esn                 = p_esn
          AND pe.x_enrollment_status NOT IN
                            ('DEENROLLED',
                             'ENROLLMENTFAILED',
                             'READYTOREENROLL')
          AND (pe.x_next_charge_date    IS NOT NULL
          OR pe.x_next_delivery_date    IS NOT NULL)
          AND pp.objid                   = pe.pgm_enroll2pgm_parameter
          AND nvl(pp.x_prog_class,' ')  != 'WARRANTY'
          AND pe.pgm_enroll2pgm_parameter= p_program_id
          ORDER BY pe.x_enrolled_date DESC)
	WHERE ROWNUM < 2 ;
  next_refill_date_rec next_refill_date_cur%rowtype;
	--
	CURSOR cards_in_reserve_cur IS
	SELECT count(*) counter FROM table_part_inst
		  WHERE x_domain||'' = 'REDEMPTION CARDS'
         AND x_part_inst_status ||'' = '400'
         AND part_to_esn2part_inst IN
			(SELECT objid FROM table_part_inst WHERE part_serial_no = p_esn );
	cards_in_reserve_rec cards_in_reserve_cur%rowtype;
  --
  CURSOR get_device_nick_name_cur IS
  SELECT cpi.x_esn_nick_name
  FROM table_x_contact_part_inst cpi , table_part_inst pi
        WHERE cpi.x_contact_part_inst2part_inst = pi.objid
          AND cpi.x_esn_nick_name IS NOT NULL
          AND pi.part_serial_no = p_esn
          AND ROWNUM < 2;
   get_device_nick_name_rec get_device_nick_name_cur%rowtype;
  --
  -- CR43248 added below cursor
  CURSOR get_group_detail_cur
  IS
  SELECT xagm.account_group_id,
         xag.account_group_name
  FROM   (SELECT  MAX(agm.objid) objid
          FROM    x_account_group_member agm
          WHERE   agm.esn     =   p_esn
          AND     agm.status  <>  'EXPIRED'
          AND     SYSDATE BETWEEN agm.start_date AND NVL(agm.end_date,SYSDATE)) agm1,
         x_account_group_member xagm,
         x_account_group        xag
  WHERE  xag.objid    =   xagm.account_group_id
  AND    agm1.objid   =   xagm.objid
  AND    xagm.esn     =   p_esn;
  get_group_detail_rec get_group_detail_cur%rowtype;
  --
  CURSOR more_info_cur IS
	SELECT param_value FROM dynamic_trans_sum_params
      WHERE brand_name = p_brand
        AND param_name = 'MORE_INFO';
	more_info_rec more_info_cur%rowtype;
  --
BEGIN
	--CONFIRMATION_MESSAGE
	OPEN confirmation_message_cur;
	FETCH confirmation_message_cur INTO confirmation_message_rec;
	IF confirmation_message_cur%found THEN
		p_confirmation_message := confirmation_message_rec.param_value;
    END IF;
	CLOSE confirmation_message_cur;
	--
	--TRANSACTION_SCRIPT
	OPEN transaction_script_cur;
	FETCH transaction_script_cur INTO transaction_script_rec;
	IF transaction_script_cur%found THEN
		p_transaction_script := transaction_script_rec.param_value;
    END IF;
	CLOSE transaction_script_cur;
	--
	--ESN_EXPIRE_DATE

  p_expire_dt:=sa.customer_info.get_expiration_date(i_esn=>p_esn); --CR53217 to get the expiration date for any status
	--
	--NEXT_REFILL_DATE
  IF nvl(p_transaction_type,'AAA') = 'ENROLLMENT_HPP' THEN
      OPEN next_refill_date_hpp_cur;
      FETCH next_refill_date_hpp_cur INTO next_refill_date_hpp_rec;
      IF next_refill_date_hpp_cur%found THEN
        p_next_refill_date := next_refill_date_hpp_rec.x_next_charge_date;
      END IF;
      CLOSE next_refill_date_hpp_cur;
  ELSE
        OPEN next_refill_date_cur;
      FETCH next_refill_date_cur INTO next_refill_date_rec;
      IF next_refill_date_cur%found THEN
        p_next_refill_date := next_refill_date_rec.x_next_charge_date;
      END IF;
      CLOSE next_refill_date_cur;
  END IF;
	--
	--ACCESS_NUMBER
  IF nvl(p_acc_num_name_reg_name,'NA') != 'NA' THEN
    OPEN access_number_cur(p_acc_num_name_reg_name);
    FETCH access_number_cur INTO access_number_rec;
    IF access_number_cur%found THEN
       p_acc_num_name_reg := access_number_rec.param_value;
    END IF;
    CLOSE access_number_cur;
  END IF;
  --
  IF nvl(p_acc_num_name_10_dollar_name,'NA') != 'NA' THEN
    OPEN access_number_cur(p_acc_num_name_10_dollar_name);
    FETCH access_number_cur INTO access_number_rec;
    IF access_number_cur%found THEN
       p_acc_num_name_10_dollar := access_number_rec.param_value;
    END IF;
    CLOSE access_number_cur;
  END IF;
	--
	--CARDS_IN_RESERVE
	OPEN cards_in_reserve_cur;
	FETCH cards_in_reserve_cur INTO cards_in_reserve_rec;
	IF cards_in_reserve_cur%found THEN
		p_cards_in_reserve := cards_in_reserve_rec.counter;
	END IF;
	CLOSE cards_in_reserve_cur;
  --
  -- Device Nick Name
  OPEN get_device_nick_name_cur;
  FETCH get_device_nick_name_cur INTO get_device_nick_name_rec;
  IF get_device_nick_name_cur%found AND get_device_nick_name_rec.x_esn_nick_name IS NOT NULL THEN
    p_device_name := get_device_nick_name_rec.x_esn_nick_name;
  END IF;
  CLOSE get_device_nick_name_cur;
  --
  -- CR43248 Added GROUP ID AND GROUP NAME, changes starts..
  OPEN get_group_detail_cur;
  FETCH get_group_detail_cur INTO get_group_detail_rec;
  IF get_group_detail_cur%FOUND THEN
    p_group_id    := get_group_detail_rec.account_group_id;
    p_group_name  := get_group_detail_rec.account_group_name;
  END IF;
  CLOSE get_group_detail_cur;
  -- CR43248 Added GROUP ID AND GROUP NAME, changes ends
  --
  -- More Info
  -- If the Deactivation Flag value is TRUE then get More Info
  IF upper(p_reactivation_flag) = 'TRUE' THEN
    OPEN more_info_cur;
    FETCH more_info_cur INTO more_info_rec;
    IF more_info_cur%found THEN
      p_more_info := more_info_rec.param_value;
    END IF;
    CLOSE more_info_cur;
  ELSE
    p_more_info := NULL;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      err_code := sqlcode;
      err_msg := substr(sqlerrm, 1, 200);
      INSERT INTO error_table (error_text,error_date,action,KEY,program_name)
      VALUES (err_code,SYSDATE,err_msg,p_language,'GET_DYNAMIC_TRANS_SUMMARY');
END; -- GET_DYNAMIC_TRANSACTION_SUMMARY
/