CREATE OR REPLACE PACKAGE BODY sa.DYNAMIC_TRANSACTION_PKG
AS
/*************************************************************************************************/
/*    Copyright   2014 Tracfone  Wireless Inc. All rights reserved                               */
/*                                                                                               */
/* NAME:         DYNAMIC_TRANSACTION_PKG                                                         */
/* PURPOSE:      Package to get dynamic transaction summary for given set of records             */
/* FREQUENCY:                                                                                    */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                                */
/*                                                                                               */
/* REVISIONS:                                                                                    */
/* VERSION  DATE       WHO         PURPOSE                                                       */
/* -------  ---------- -----       --------------------------------------------------------------*/
/*  1.0     01/23/2017 sgangineni  Package to ge the dynamic transactions summary for            */
/*                                 given set of records                                          */
/*************************************************************************************************/

   /**********************************************************************************************/
   /*    Copyright   2014 Tracfone  Wireless Inc. All rights reserved                            */
   /*                                                                                            */
   /* NAME:         DYNAMIC_TRANSACTION_SUMMARY                                                  */
   /* PURPOSE:      To return dynamic transaction summary details for a single record input      */
   /* FREQUENCY:                                                                                 */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                             */
   /*                                                                                            */
   /* REVISIONS:                                                                                 */
   /* VERSION  DATE       WHO         PURPOSE                                                    */
   /* -------  ---------- -----       -----------------------------------------------------------*/
   /*  1.0     02/02/2017 sgangineni  CR35913 To return dynamic transaction summary details for  */
   /*                                 a single record input                                      */
   /**********************************************************************************************/
   PROCEDURE DYNAMIC_TRANSACTION_SUMMARY (p_source_system               IN    dynamic_trans_sum_params.source_system%TYPE,
                                          p_brand                       IN    dynamic_trans_sum_params.brand_name%TYPE,
                                          p_language                    IN    dynamic_trans_sum_params.language%TYPE DEFAULT 'ENG',
                                          p_esn                         IN    table_part_inst.part_serial_no%TYPE,
                                          p_transaction_type            IN    dynamic_trans_sum_params.transaction_type%TYPE,
                                          p_retention_type              IN    dynamic_trans_sum_params.retention_type%TYPE,
                                          p_program_id                  IN    x_program_enrolled.pgm_enroll2pgm_parameter%TYPE,
                                          p_acc_num_name_reg_name       IN    dynamic_trans_sum_params.param_name%TYPE,
                                          p_acc_num_name_10_dollar_name IN    dynamic_trans_sum_params.param_name%TYPE,
                                          p_reactivation_flag           IN    VARCHAR2 DEFAULT 'FALSE',
                                          p_confirmation_message        OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_transaction_script          OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_expire_dt                   OUT   DATE,
                                          p_next_refill_date            OUT   DATE,
                                          p_acc_num_name_reg            OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_acc_num_name_10_dollar      OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_cards_in_reserve            OUT   INTEGER,
                                          p_more_info                   OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_device_name                 OUT   table_x_contact_part_inst.x_esn_nick_name%TYPE,
                                          p_group_id                    OUT   x_account_group_member.account_group_id%TYPE,
                                          p_group_name                  OUT   x_account_group.account_group_name%TYPE,
                                          p_err_code                    OUT   NUMBER,
                                          p_err_msg                     OUT   VARCHAR2
                                         )
   AS
      err_code    NUMBER;
      err_msg     VARCHAR2(4000);

      CURSOR confirmation_message_cur
      IS
         SELECT param_value FROM dynamic_trans_sum_params
          WHERE source_system = p_source_system
            AND brand_name = p_brand
            AND transaction_type = p_transaction_type
            AND language = p_language
            AND param_name = 'CONFIRMATION_MESSAGE';
      confirmation_message_rec confirmation_message_cur%rowtype;

      CURSOR transaction_script_cur
      IS
         SELECT param_value FROM dynamic_trans_sum_params
          WHERE source_system = p_source_system
            AND brand_name = p_brand
            AND transaction_type = p_transaction_type
            AND retention_type = p_retention_type
            AND language = p_language
            AND param_name = 'TRANSACTION_SCRIPT';
      transaction_script_rec transaction_script_cur%rowtype;

      CURSOR access_number_cur (c_access_number_name dynamic_trans_sum_params.param_name%TYPE)
      IS
         SELECT param_value FROM dynamic_trans_sum_params
          WHERE source_system = p_source_system
            AND brand_name = p_brand
            AND param_name = c_access_number_name;
      access_number_rec access_number_cur%rowtype;

      CURSOR esn_expire_date_cur
      IS
         SELECT x_expire_dt FROM table_site_part
          WHERE part_status ||'' = 'Active'
            AND x_service_id = p_esn;
      esn_expire_date_rec esn_expire_date_cur%rowtype;

      CURSOR next_refill_date_hpp_cur
      IS
         SELECT x_charge_date,
                x_next_charge_date
           FROM (SELECT pe.x_charge_date, pe.x_next_charge_date
                   FROM x_program_enrolled pe,
                        x_program_parameters pp
                  WHERE pe.x_esn = p_esn
                    AND pe.x_enrollment_status NOT IN ('DEENROLLED',
                                                       'ENROLLMENTFAILED',
                                                       'READYTOREENROLL')
                    AND (pe.x_next_charge_date IS NOT NULL
                         OR pe.x_next_delivery_date IS NOT NULL)
                    AND pp.objid = pe.pgm_enroll2pgm_parameter
                    AND NVL(pp.x_prog_class,' ')  = 'WARRANTY'
                    AND pe.pgm_enroll2pgm_parameter= p_program_id
                  ORDER BY pe.x_enrolled_date DESC)
          WHERE ROWNUM < 2 ;
      next_refill_date_hpp_rec next_refill_date_hpp_cur%rowtype;

      CURSOR next_refill_date_cur
      IS
         SELECT x_charge_date,
                x_next_charge_date
           FROM (SELECT pe.x_charge_date,
                        pe.x_next_charge_date
                   FROM x_program_enrolled pe,
                        x_program_parameters pp
                  WHERE pe.x_esn = p_esn
                    AND pe.x_enrollment_status NOT IN ('DEENROLLED',
                                                       'ENROLLMENTFAILED',
                                                       'READYTOREENROLL')
                    AND (pe.x_next_charge_date IS NOT NULL
                         OR pe.x_next_delivery_date IS NOT NULL)
                    AND pp.objid = pe.pgm_enroll2pgm_parameter
                    AND nvl(pp.x_prog_class,' ')  != 'WARRANTY'
                    AND pe.pgm_enroll2pgm_parameter= p_program_id
                  ORDER BY pe.x_enrolled_date DESC)
          WHERE ROWNUM < 2 ;
      next_refill_date_rec next_refill_date_cur%rowtype;

      CURSOR cards_in_reserve_cur
      IS
         SELECT count(*) counter FROM table_part_inst
          WHERE x_domain||'' = 'REDEMPTION CARDS'
            AND x_part_inst_status ||'' = '400'
            AND part_to_esn2part_inst IN (SELECT objid
                                            FROM table_part_inst
                                           WHERE part_serial_no = p_esn );
      cards_in_reserve_rec cards_in_reserve_cur%rowtype;

      CURSOR get_device_nick_name_cur
      IS
         SELECT cpi.x_esn_nick_name
           FROM table_x_contact_part_inst cpi,
                table_part_inst pi
          WHERE cpi.x_contact_part_inst2part_inst = pi.objid
            AND cpi.x_esn_nick_name IS NOT NULL
            AND pi.part_serial_no = p_esn
            AND ROWNUM < 2;
      get_device_nick_name_rec get_device_nick_name_cur%rowtype;

      -- CR43248 added below cursor
      CURSOR get_group_detail_cur
      IS
         SELECT xagm.account_group_id,
                xag.account_group_name
           FROM (SELECT MAX(agm.objid) objid
                   FROM x_account_group_member agm
                  WHERE agm.esn = p_esn
                    AND agm.status <> 'EXPIRED'
                    AND SYSDATE BETWEEN agm.start_date
                                    AND NVL(agm.end_date,SYSDATE)) agm1,
                x_account_group_member xagm,
                x_account_group        xag
          WHERE xag.objid = xagm.account_group_id
            AND agm1.objid = xagm.objid
            AND xagm.esn = p_esn;
      get_group_detail_rec get_group_detail_cur%rowtype;

      CURSOR more_info_cur
      IS
         SELECT param_value
           FROM dynamic_trans_sum_params
          WHERE brand_name = p_brand
            AND param_name = 'MORE_INFO';
      more_info_rec more_info_cur%rowtype;
      ln_queued_service_days    NUMBER;
      queued_cards            customer_queued_card_tab := customer_queued_card_tab();
      l_expire_dt             DATE; --CR49696
   BEGIN
      --CONFIRMATION_MESSAGE
      OPEN confirmation_message_cur;
      FETCH confirmation_message_cur INTO confirmation_message_rec;

      IF confirmation_message_cur%found
      THEN
         p_confirmation_message := confirmation_message_rec.param_value;
      END IF;
      CLOSE confirmation_message_cur;

      --TRANSACTION_SCRIPT
      OPEN transaction_script_cur;
      FETCH transaction_script_cur INTO transaction_script_rec;

      IF transaction_script_cur%found
      THEN
         p_transaction_script := transaction_script_rec.param_value;
      END IF;
      CLOSE transaction_script_cur;

      --ESN_EXPIRE_DATE
      --CR49696 changes start
      /*OPEN esn_expire_date_cur;
      FETCH esn_expire_date_cur INTO esn_expire_date_rec;

      IF esn_expire_date_cur%found
      THEN
        queued_cards := SA.customer_info.get_esn_queued_cards (i_esn => p_esn);

        SELECT NVL(SUM(queued_days),0)
        INTO   ln_queued_service_days
        FROM   TABLE(CAST(queued_cards AS customer_queued_card_tab));

         p_expire_dt := esn_expire_date_rec.x_expire_dt + ln_queued_service_days;
      ELSE
         p_expire_dt := TRUNC(SYSDATE);
      END IF;
      CLOSE esn_expire_date_cur;*/

      queued_cards := sa.customer_info.get_esn_queued_cards (i_esn => p_esn);

      SELECT NVL(SUM(queued_days),0)
      INTO   ln_queued_service_days
      FROM   TABLE(CAST(queued_cards AS customer_queued_card_tab));

      l_expire_dt  := TRUNC(sa.customer_info.get_expiration_date ( i_esn => p_esn ));

      IF l_expire_dt < TRUNC(SYSDATE)
      THEN
        p_expire_dt := TRUNC(SYSDATE) + ln_queued_service_days;
      ELSE
        p_expire_dt := l_expire_dt + ln_queued_service_days;
      END IF;
      --CR49696 changes end

      --NEXT_REFILL_DATE
      IF nvl(p_transaction_type,'AAA') = 'ENROLLMENT_HPP'
      THEN
         OPEN next_refill_date_hpp_cur;
         FETCH next_refill_date_hpp_cur INTO next_refill_date_hpp_rec;

         IF next_refill_date_hpp_cur%found
         THEN
            p_next_refill_date := next_refill_date_hpp_rec.x_next_charge_date;
         END IF;
         CLOSE next_refill_date_hpp_cur;
      ELSE
         OPEN next_refill_date_cur;
         FETCH next_refill_date_cur INTO next_refill_date_rec;

         IF next_refill_date_cur%found
         THEN
            p_next_refill_date := next_refill_date_rec.x_next_charge_date;
         END IF;
         CLOSE next_refill_date_cur;
      END IF;

      --ACCESS_NUMBER
      IF nvl(p_acc_num_name_reg_name,'NA') != 'NA'
      THEN
         OPEN access_number_cur(p_acc_num_name_reg_name);
         FETCH access_number_cur INTO access_number_rec;

         IF access_number_cur%found
         THEN
            p_acc_num_name_reg := access_number_rec.param_value;
         END IF;
         CLOSE access_number_cur;
      END IF;

      IF nvl(p_acc_num_name_10_dollar_name,'NA') != 'NA'
      THEN
         OPEN access_number_cur(p_acc_num_name_10_dollar_name);
         FETCH access_number_cur INTO access_number_rec;

         IF access_number_cur%found
         THEN
            p_acc_num_name_10_dollar := access_number_rec.param_value;
         END IF;
         CLOSE access_number_cur;
      END IF;

      --CARDS_IN_RESERVE
      OPEN cards_in_reserve_cur;
      FETCH cards_in_reserve_cur INTO cards_in_reserve_rec;

      IF cards_in_reserve_cur%found
      THEN
         p_cards_in_reserve := cards_in_reserve_rec.counter;
      END IF;
      CLOSE cards_in_reserve_cur;

      -- Device Nick Name
      OPEN get_device_nick_name_cur;
      FETCH get_device_nick_name_cur INTO get_device_nick_name_rec;

      IF get_device_nick_name_cur%found
         AND get_device_nick_name_rec.x_esn_nick_name IS NOT NULL
      THEN
         p_device_name := get_device_nick_name_rec.x_esn_nick_name;
      END IF;
      CLOSE get_device_nick_name_cur;

      -- CR43248 Added GROUP ID AND GROUP NAME, changes starts..
      OPEN get_group_detail_cur;
      FETCH get_group_detail_cur INTO get_group_detail_rec;

      IF get_group_detail_cur%FOUND
      THEN
         p_group_id    := get_group_detail_rec.account_group_id;
         p_group_name  := get_group_detail_rec.account_group_name;
      END IF;
      CLOSE get_group_detail_cur;
      -- CR43248 Added GROUP ID AND GROUP NAME, changes ends

      -- More Info
      -- If the Deactivation Flag value is TRUE then get More Info
      IF upper(p_reactivation_flag) = 'TRUE'
      THEN
         OPEN more_info_cur;
         FETCH more_info_cur INTO more_info_rec;

         IF more_info_cur%found
         THEN
            p_more_info := more_info_rec.param_value;
         END IF;
         CLOSE more_info_cur;
      ELSE
         p_more_info := NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_err_code := SQLCODE;
         p_err_code := SUBSTR(SQLERRM, 1, 2000);
   END DYNAMIC_TRANSACTION_SUMMARY;

   /***************************************************************************************************/
   /*   Copyright   2014 Tracfone  Wireless Inc. All rights reserved                                  */
   /*                                                                                                 */
   /* NAME:         GET_DYNAMIC_TRANS_SUMMARY                                                         */
   /* PURPOSE:      To return dynamic transaction summary details in array                            */
   /* FREQUENCY:                                                                                      */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                                  */
   /*                                                                                                 */
   /* REVISIONS:                                                                                      */
   /* VERSION  DATE       WHO         PURPOSE                                                         */
   /* -------  ---------- -----       ----------------------------------------------------------------*/
   /*  1.0     01/23/2017 sgangineni  CR47564 To return dynamic transaction summary details in array  */
   /***************************************************************************************************/
   PROCEDURE GET_DYNAMIC_TRANS_SUMMARY (io_dynamic_trans_sum_tbl  IN OUT   GET_DYNAMIC_TRANS_SUMMARY_TAB,
                                        o_err_code                OUT      VARCHAR2,
                                        o_err_msg                 OUT      VARCHAR2)
   IS
   --
   BEGIN
      -- Input Validation
      IF io_dynamic_trans_sum_tbl IS NULL
      THEN
         o_err_code := '101';
         o_err_msg := 'Input array does not have values to get dynamic transactions summary';
         RETURN;
      END IF;

      -- Update op_esn_plan_partnum_det_tab variables
      FOR i IN io_dynamic_trans_sum_tbl.first .. io_dynamic_trans_sum_tbl.last
      LOOP
         --Call the procedure dynamic_transaction_summary for each record in the array
        -- BEGIN
            DYNAMIC_TRANSACTION_SUMMARY (p_source_system                =>  io_dynamic_trans_sum_tbl(i).source_system,
                                         p_brand                       	=>  io_dynamic_trans_sum_tbl(i).brand,
                                         p_language                    	=>  io_dynamic_trans_sum_tbl(i).language,
                                         p_esn                         	=>  io_dynamic_trans_sum_tbl(i).esn,
                                         p_transaction_type            	=>  io_dynamic_trans_sum_tbl(i).transaction_type,
                                         p_retention_type              	=>  io_dynamic_trans_sum_tbl(i).retention_type,
                                         p_program_id                  	=>  io_dynamic_trans_sum_tbl(i).program_id,
                                         p_acc_num_name_reg_name       	=>  io_dynamic_trans_sum_tbl(i).acc_num_name_reg_name,
                                         p_acc_num_name_10_dollar_name 	=>  io_dynamic_trans_sum_tbl(i).acc_num_name_10_dollar_name,
                                         p_reactivation_flag           	=>  io_dynamic_trans_sum_tbl(i).reactivation_flag,
                                         p_confirmation_message        	=>  io_dynamic_trans_sum_tbl(i).confirmation_message,
                                         p_transaction_script          	=>  io_dynamic_trans_sum_tbl(i).transaction_script,
                                         p_expire_dt                   	=>  io_dynamic_trans_sum_tbl(i).serv_end_date,
                                         p_next_refill_date            	=>  io_dynamic_trans_sum_tbl(i).next_refill_date,
                                         p_acc_num_name_reg            	=>  io_dynamic_trans_sum_tbl(i).acc_num_name_reg,
                                         p_acc_num_name_10_dollar      	=>  io_dynamic_trans_sum_tbl(i).acc_num_name_10_dollar,
                                         p_cards_in_reserve            	=>  io_dynamic_trans_sum_tbl(i).cards_in_reserve,
                                         p_more_info                   	=>  io_dynamic_trans_sum_tbl(i).more_info,
                                         p_device_name                 	=>  io_dynamic_trans_sum_tbl(i).device_name,
                                         p_group_id                    	=>  io_dynamic_trans_sum_tbl(i).group_id,
                                         p_group_name                  	=>  io_dynamic_trans_sum_tbl(i).group_name,
                                         p_err_code                     =>  io_dynamic_trans_sum_tbl(i).err_code,
                                         p_err_msg                      =>  io_dynamic_trans_sum_tbl(i).err_msg
                                        );

            --Calculate the service end date using the input service days
            --io_dynamic_trans_sum_tbl(i).serv_end_date := TRUNC(SYSDATE + NVL(io_dynamic_trans_sum_tbl(i).service_days, 0));

            --If the retention type is ADD_TO_RESERVE, consider that also into the reserved cards count
            IF io_dynamic_trans_sum_tbl(i).retention_type = 'ADD_TO_RESERVE'
            THEN
               io_dynamic_trans_sum_tbl(i).cards_in_reserve  := io_dynamic_trans_sum_tbl(i).cards_in_reserve + 1;
            END IF;
       --  EXCEPTION
       --     WHEN OTHERS
       --     THEN
       --        io_dynamic_trans_sum_tbl(i).err_code := sqlcode;
       --        io_dynamic_trans_sum_tbl(i).err_msg := substr(sqlerrm, 1, 2000);
       --  END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_err_code  := sqlcode;
         o_err_msg   := substr(sqlerrm, 1, 2000);
   END GET_DYNAMIC_TRANS_SUMMARY;

  /***************************************************************************************************/
  /*   Copyright   2014 Tracfone  Wireless Inc. All rights reserved                                  */
  /*                                                                                                 */
  /* NAME:         GET_ESN_QUEUED_CARD_DAYS                                                          */
  /* PURPOSE:      To return the total no of days for all the queued cards of given ESN/MINs         */
  /* FREQUENCY:                                                                                      */
  /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                                  */
  /*                                                                                                 */
  /* REVISIONS:                                                                                      */
  /* VERSION  DATE       WHO         PURPOSE                                                         */
  /* -------  ---------- -----       ----------------------------------------------------------------*/
  /*  1.0     05/04/2017 sgangineni  CR49721 To return queued card days of multiple ESNs in array    */
  /***************************************************************************************************/
  PROCEDURE GET_ESN_QUEUED_CARD_DAYS (io_esn_min_queue_card_det_tbl  IN OUT   esn_min_queue_card_det_tab,
                                      o_err_code                        OUT   VARCHAR2,
                                      o_err_msg                         OUT   VARCHAR2)
  IS
    c   sa.customer_type := sa.customer_type( );
  BEGIN
    IF io_esn_min_queue_card_det_tbl IS NULL
    THEN
      o_err_code := '201';
      o_err_msg := 'INPUT ARRAY IS NULL';
      RETURN;
    END IF;

    FOR i IN 1..io_esn_min_queue_card_det_tbl.count
    LOOP
      IF io_esn_min_queue_card_det_tbl(i).esn IS NULL AND io_esn_min_queue_card_det_tbl(i).min IS NULL
      THEN
        io_esn_min_queue_card_det_tbl(i).err_code := '202';
        io_esn_min_queue_card_det_tbl(i).err_msg := 'BOTH ESN AND MIN CANNOT BE NULL';
      ELSIF io_esn_min_queue_card_det_tbl(i).esn IS NULL
      THEN
        c.esn := customer_info.get_esn ( i_min => io_esn_min_queue_card_det_tbl(i).min );

        IF c.esn IS NULL
        THEN
          io_esn_min_queue_card_det_tbl(i).err_code := '203';
          io_esn_min_queue_card_det_tbl(i).err_msg := 'ESN COULD NOT BE FOUND FOR GIVEN MIN:'||io_esn_min_queue_card_det_tbl(i).min;
        END IF;
      ELSE
        c.esn := io_esn_min_queue_card_det_tbl(i).esn;
      END IF;

      IF c.esn IS NOT NULL
      THEN
        IF io_esn_min_queue_card_det_tbl(i).pin_to_exclude IS NOT NULL
        THEN
          io_esn_min_queue_card_det_tbl(i).queue_card_days := (sa.customer_info.get_esn_queue_card_days (i_esn => c.esn) -
                                                               sa.customer_info.get_esn_pin_redeem_days (i_esn => c.esn, i_pin => io_esn_min_queue_card_det_tbl(i).pin_to_exclude));
        ELSE
          io_esn_min_queue_card_det_tbl(i).queue_card_days := sa.customer_info.get_esn_queue_card_days (i_esn => c.esn);
        END IF;
        io_esn_min_queue_card_det_tbl(i).err_code := '0';
        io_esn_min_queue_card_det_tbl(i).err_msg := 'SUCCESS';
      END IF;
    END LOOP;

    o_err_code := '0';
    o_err_msg := 'SUCCESS';
  EXCEPTION
    WHEN OTHERS
    THEN
       o_err_code  := SQLCODE;
       o_err_msg   := SUBSTR(SQLERRM, 1, 2000);
  END GET_ESN_QUEUED_CARD_DAYS;
 PROCEDURE get_dynamic_transaction(
    i_source_system               IN dynamic_trans_sum_params.source_system%TYPE,
    i_brand                       IN dynamic_trans_sum_params.brand_name%TYPE,
    i_language                    IN dynamic_trans_sum_params.language%TYPE DEFAULT 'ENG',
    i_esn                         IN table_part_inst.part_serial_no%TYPE,
    i_transaction_type            IN dynamic_trans_sum_params.transaction_type%TYPE,
    i_retention_type              IN dynamic_trans_sum_params.retention_type%TYPE,
    i_program_id                  IN x_program_enrolled.pgm_enroll2pgm_parameter%TYPE,
    i_acc_num_name_reg_name       IN dynamic_trans_sum_params.param_name%TYPE,
    i_acc_num_name_10_dollar_name IN dynamic_trans_sum_params.param_name%TYPE,
    i_reactivation_flag           IN VARCHAR2 DEFAULT 'FALSE',
    o_confirmation_message OUT dynamic_trans_sum_params.param_value%TYPE,
    o_transaction_script OUT dynamic_trans_sum_params.param_value%TYPE,
    o_expire_dt OUT DATE,
    o_next_refill_date OUT DATE,
    o_acc_num_name_reg OUT dynamic_trans_sum_params.param_value%TYPE,
    o_acc_num_name_10_dollar OUT dynamic_trans_sum_params.param_value%TYPE,
    o_cards_in_reserve OUT INTEGER,
    o_more_info OUT dynamic_trans_sum_params.param_value%TYPE,
    o_device_name OUT table_x_contact_part_inst.x_esn_nick_name%TYPE,
    o_group_id OUT x_account_group_member.account_group_id%TYPE,
    o_group_name OUT x_account_group.account_group_name%TYPE,
    o_forecast_date OUT DATE,
    o_next_refill_date_hpp OUT DATE)
AS
  err_code VARCHAR2(4000) ;
  err_msg  VARCHAR2(4000) ;
  v_count  NUMBER:=0;
  v_program_id x_program_enrolled.pgm_enroll2pgm_parameter%TYPE;
BEGIN

    BEGIN
          SELECT pe.pgm_enroll2pgm_parameter  INTO v_program_id
          FROM   sa.x_program_enrolled   pe,
          	     sa.x_program_parameters PP
          WHERE  pe.x_esn = i_esn
          AND    pe.x_next_charge_date >= TRUNC(SYSDATE)
          AND    pe.x_is_grp_primary = 1
          AND    pe.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
          AND    pp.objid = pe.pgm_enroll2pgm_parameter
          AND    NVL(pp.x_prog_class,'X') not in ('ONDEMAND','WARRANTY');
    EXCEPTION
    WHEN OTHERS THEN
      v_program_id:=NULL;
    END;

  sa.get_dynamic_trans_summary(p_source_system=>i_source_system,
							  p_brand=>i_brand,
							  p_language=>i_language,
							  p_esn=>i_esn,
							  p_transaction_type=>i_transaction_type,
							  p_retention_type=>i_retention_type,
							  p_program_id=>nvl(i_program_id,v_program_id),
							  p_acc_num_name_reg_name=>i_acc_num_name_reg_name,
							  p_acc_num_name_10_dollar_name=>i_acc_num_name_10_dollar_name,
							  p_reactivation_flag=>i_reactivation_flag,
							  p_confirmation_message=>o_confirmation_message,
							  p_transaction_script=>o_transaction_script,
							  p_expire_dt=>o_expire_dt,
							  p_next_refill_date=>o_next_refill_date,
							  p_acc_num_name_reg=>o_acc_num_name_reg,
							  p_acc_num_name_10_dollar=>o_acc_num_name_10_dollar,
							  p_cards_in_reserve=>o_cards_in_reserve,
							  p_more_info=>o_more_info,
							  p_device_name=>o_device_name,
							  p_group_id=>o_group_id,
							  p_group_name=>o_group_name);
  o_forecast_date :=customer_info.get_service_forecast_due_date(i_esn=>i_esn);
  IF v_program_id IS NOT NULL AND o_cards_in_reserve>0 THEN
  o_next_refill_date:=o_forecast_date;
  END IF;

BEGIN
SELECT
                x_next_charge_date INTO o_next_refill_date_hpp
           FROM (SELECT pe.x_charge_date, pe.x_next_charge_date
                   FROM x_program_enrolled pe,
                        x_program_parameters pp
                  WHERE pe.x_esn = i_esn
                    AND pe.x_enrollment_status NOT IN ('DEENROLLED',
                                                       'ENROLLMENTFAILED',
                                                       'READYTOREENROLL')
                    AND (pe.x_next_charge_date IS NOT NULL
                         OR pe.x_next_delivery_date IS NOT NULL)
                    AND pp.objid = pe.pgm_enroll2pgm_parameter
                    AND NVL(pp.x_prog_class,' ')  = 'WARRANTY'
                    AND pe.pgm_enroll2pgm_parameter= nvl(i_program_id,v_program_id)
                  ORDER BY pe.x_enrolled_date DESC)
          WHERE ROWNUM < 2 ;
EXCEPTION
WHEN OTHERS THEN
o_next_refill_date_hpp:=null;
END;
EXCEPTION
WHEN OTHERS THEN
  err_code := SQLCODE;
  err_msg  := SUBSTR(sqlerrm, 1, 200);
END get_dynamic_transaction;
END DYNAMIC_TRANSACTION_PKG;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/DYNAMIC_TRANSACTION_PKB.sql 	CR53217: 1.21

-- ANTHILL_TEST PLSQL/SA/PackageBodies/DYNAMIC_TRANSACTION_PKB.sql 	CR53217: 1.22

-- ANTHILL_TEST PLSQL/SA/PackageBodies/DYNAMIC_TRANSACTION_PKB.sql 	CR53217: 1.23

-- ANTHILL_TEST PLSQL/SA/PackageBodies/DYNAMIC_TRANSACTION_PKB.sql 	CR53217: 1.24
/