CREATE OR REPLACE PACKAGE BODY sa."SAFELINK_MAINTENANCE_PKG" AS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SAFELINK_MAINTENANCE_PKG_BODY.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2012/04/03 14:43:38 $
  --$Log: SAFELINK_MAINTENANCE_PKG_BODY.sql,v $
  --Revision 1.2  2012/04/03 14:43:38  kacosta
  --CR16379 Triple Minutes Cards
  --
  --Revision 1.1  2012/03/02 19:35:58  kacosta
  --CR19754 Safelink Family Plan
  --
  --
  ---------------------------------------------------------------------------------------------
  --
  -- Private Package Variables
  --
  l_cv_package_name CONSTANT VARCHAR2(30) := 'safelink_maintenance_pkg';
  --
  -- Private Functions
  --
  -- Private Procedures
  --
  --********************************************************************************
  -- Procedure to validate if ESN is valid for referral benefits enrollment
  -- Procedure was created for CR19754
  --********************************************************************************
  --
  PROCEDURE valid_for_referral_enrollment
  (
    p_enrolled_esn       IN sa.x_sl_referral_benefits_plan.enrolled_esn%TYPE
   ,p_safelink_min       IN sa.table_part_inst.part_serial_no%TYPE
   ,p_enrolled_esn_objid OUT sa.table_part_inst.objid%TYPE
   ,p_safelink_esn       OUT sa.x_sl_referral_benefits_plan.safelink_esn%TYPE
   ,p_error_code         OUT PLS_INTEGER
   ,p_error_message      OUT VARCHAR2
  ) IS
    --
    CURSOR get_enrolled_esn_curs(c_enrolled_esn sa.x_sl_referral_benefits_plan.enrolled_esn%TYPE) IS
      SELECT tpi_esn.objid esn_objid
            ,tpi_esn.x_part_inst_status esn_status_number
            ,CASE
               WHEN xpp.objid IS NOT NULL THEN
                'Y'
               ELSE
                'N'
             END lifeline_esn
        FROM sa.table_part_inst tpi_esn
        LEFT OUTER JOIN sa.x_program_enrolled xpe
          ON tpi_esn.part_serial_no = xpe.x_esn
         AND xpe.x_enrollment_status = 'ENROLLED'
        LEFT OUTER JOIN sa.x_program_parameters xpp
          ON xpe.pgm_enroll2pgm_parameter = xpp.objid
         AND xpp.x_prog_class = 'LIFELINE'
       WHERE tpi_esn.part_serial_no = c_enrolled_esn
         AND tpi_esn.x_domain = 'PHONES';
    --
    get_enrolled_esn_rec get_enrolled_esn_curs%ROWTYPE;
    --
    CURSOR check_already_enrolled_curs(c_enrolled_esn sa.x_sl_referral_benefits_plan.enrolled_esn%TYPE) IS
      SELECT 'Y' already_enrolled
        FROM sa.x_sl_referral_benefits_plan rbp
       WHERE rbp.enrolled_esn = c_enrolled_esn
         AND SYSDATE BETWEEN rbp.start_enrolled_date AND rbp.end_enrolled_date;
    --
    check_already_enrolled_rec check_already_enrolled_curs%ROWTYPE;
    --
    CURSOR get_safelink_esn_curs(c_safelink_min sa.table_part_inst.part_serial_no%TYPE) IS
      SELECT tpi_esn.part_serial_no esn
            ,tpi_esn.x_part_inst_status esn_status_number
            ,CASE
               WHEN xpp.objid IS NOT NULL THEN
                'Y'
               ELSE
                'N'
             END esn_current_enrolled
        FROM sa.table_part_inst tpi_min
        JOIN sa.table_part_inst tpi_esn
          ON tpi_min.part_to_esn2part_inst = tpi_esn.objid
        LEFT OUTER JOIN sa.x_program_enrolled xpe
          ON tpi_esn.part_serial_no = xpe.x_esn
         AND xpe.x_enrollment_status = 'ENROLLED'
        LEFT OUTER JOIN sa.x_program_parameters xpp
          ON xpe.pgm_enroll2pgm_parameter = xpp.objid
         AND xpp.x_prog_class = 'LIFELINE'
       WHERE tpi_min.part_serial_no = c_safelink_min
         AND tpi_min.x_domain = 'LINES'
         AND tpi_esn.x_domain = 'PHONES';
    --
    get_safelink_esn_rec get_safelink_esn_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.valid_for_referral_enrollment';
    l_ex_business_error EXCEPTION;
    l_i_error_code    PLS_INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_enrolled_esn: ' || NVL(p_enrolled_esn
                                                    ,'Value is null'));
      dbms_output.put_line('p_safelink_min: ' || NVL(p_safelink_min
                                                    ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Verifying input parameters';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (p_enrolled_esn IS NULL) THEN
      --
      l_i_error_code    := 1;
      l_v_error_message := 'ESN to enroll parameter value is null';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    IF (p_safelink_min IS NULL) THEN
      --
      l_i_error_code    := 2;
      l_v_error_message := 'SafeLink MIN parameter value is null';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Verifying ESN to enroll';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF get_enrolled_esn_curs%ISOPEN THEN
      --
      CLOSE get_enrolled_esn_curs;
      --
    END IF;
    --
    OPEN get_enrolled_esn_curs(c_enrolled_esn => p_enrolled_esn);
    FETCH get_enrolled_esn_curs
      INTO get_enrolled_esn_rec;
    CLOSE get_enrolled_esn_curs;
    --
    IF (get_enrolled_esn_rec.esn_objid IS NULL) THEN
      --
      l_i_error_code    := 3;
      l_v_error_message := 'ESN to enroll is not found';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    IF (get_enrolled_esn_rec.esn_status_number <> '52') THEN
      --
      l_i_error_code    := 4;
      l_v_error_message := 'ESN to enroll is not active';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    IF (get_enrolled_esn_rec.lifeline_esn = 'Y') THEN
      --
      l_i_error_code    := 9;
      l_v_error_message := 'ESN to enroll is enrolled in SafeLink program';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    IF check_already_enrolled_curs%ISOPEN THEN
      --
      CLOSE check_already_enrolled_curs;
      --
    END IF;
    --
    OPEN check_already_enrolled_curs(c_enrolled_esn => p_enrolled_esn);
    FETCH check_already_enrolled_curs
      INTO check_already_enrolled_rec;
    CLOSE check_already_enrolled_curs;
    --
    IF (check_already_enrolled_rec.already_enrolled = 'Y') THEN
      --
      l_i_error_code    := 5;
      l_v_error_message := 'ESN to enroll is already enrolled';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.4';
    l_v_note     := 'Verifying SafeLink ESN';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF get_safelink_esn_curs%ISOPEN THEN
      --
      CLOSE get_safelink_esn_curs;
      --
    END IF;
    --
    OPEN get_safelink_esn_curs(c_safelink_min => p_safelink_min);
    FETCH get_safelink_esn_curs
      INTO get_safelink_esn_rec;
    CLOSE get_safelink_esn_curs;
    --
    IF (get_safelink_esn_rec.esn IS NULL) THEN
      --
      l_i_error_code    := 6;
      l_v_error_message := 'SafeLink ESN is not found';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    IF (get_safelink_esn_rec.esn_status_number <> '52') THEN
      --
      l_i_error_code    := 7;
      l_v_error_message := 'SafeLink ESN is not active';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    IF (get_safelink_esn_rec.esn_current_enrolled <> 'Y') THEN
      --
      l_i_error_code    := 8;
      l_v_error_message := 'SafeLink ESN is not enrolled in SafeLink';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.5';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_enrolled_esn_objid: ' || NVL(TO_CHAR(get_enrolled_esn_rec.esn_objid)
                                                          ,'Value is null'));

      dbms_output.put_line('p_safelink_esn      : ' || NVL(get_safelink_esn_rec.esn
                                                          ,'Value is null'));
      dbms_output.put_line('p_error_code        : ' || NVL(TO_CHAR(l_i_error_code)
                                                          ,'Value is null'));
      dbms_output.put_line('p_error_message     : ' || NVL(l_v_error_message
                                                          ,'Value is null'));
      --
    END IF;
    --
    p_enrolled_esn_objid := get_enrolled_esn_rec.esn_objid;
    p_safelink_esn       := get_safelink_esn_rec.esn;
    p_error_code         := l_i_error_code;
    p_error_message      := l_v_error_message;
    --
  EXCEPTION
    WHEN l_ex_business_error THEN
      --
      ROLLBACK;
      --
      p_enrolled_esn_objid := NULL;
      p_safelink_esn       := NULL;
      p_error_code         := l_i_error_code;
      p_error_message      := l_v_error_message;
      --
      l_v_position := l_cv_subprogram_name || '.6';
      l_v_note     := 'End executing with business error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      IF get_enrolled_esn_curs%ISOPEN THEN
        --
        CLOSE get_enrolled_esn_curs;
        --
      END IF;
      --
      IF check_already_enrolled_curs%ISOPEN THEN
        --
        CLOSE check_already_enrolled_curs;
        --
      END IF;
      --
      IF get_safelink_esn_curs%ISOPEN THEN
        --
        CLOSE get_safelink_esn_curs;
        --
      END IF;
      --
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_enrolled_esn_objid := NULL;
      p_safelink_esn       := NULL;
      p_error_code         := SQLCODE;
      p_error_message      := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.7';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => NULL
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
      IF get_enrolled_esn_curs%ISOPEN THEN
        --
        CLOSE get_enrolled_esn_curs;
        --
      END IF;
      --
      IF check_already_enrolled_curs%ISOPEN THEN
        --
        CLOSE check_already_enrolled_curs;
        --
      END IF;
      --
      IF get_safelink_esn_curs%ISOPEN THEN
        --
        CLOSE get_safelink_esn_curs;
        --
      END IF;
      --
  END valid_for_referral_enrollment;
  --
  -- Public Functions
  --
  -- Public Procedures
  --
  --********************************************************************************
  -- Procedure to enrolled non-SafeLink ESN to the SafeLink Family Plan
  -- Procedure was created for CR19754
  --********************************************************************************
  --
  PROCEDURE referral_benefits_enrollment
  (
    p_enrolled_esn                IN sa.x_sl_referral_benefits_plan.enrolled_esn%TYPE
   ,p_safelink_min                IN sa.table_part_inst.part_serial_no%TYPE
   ,p_enrolled_into_double_minute OUT VARCHAR2
   ,p_error_code                  OUT PLS_INTEGER
   ,p_error_message               OUT VARCHAR2
  ) IS
    --
    CURSOR get_promo_info_curs IS
      SELECT txp.objid                     promotion_objid
            ,xpm.x_promo_mtm2x_promo_group promotion_group_objid
            ,xpg.group_name                promotion_group
        FROM sa.table_x_promotion txp
        JOIN sa.table_x_promotion_mtm xpm
          ON txp.objid = xpm.x_promo_mtm2x_promotion
        JOIN sa.table_x_promotion_group xpg
          ON xpm.x_promo_mtm2x_promo_group = xpg.objid
       WHERE txp.x_promo_code = 'RTDBL000';
    --
    get_promo_info_rec get_promo_info_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.referral_benefits_enrollment';
    l_ex_business_error EXCEPTION;
    l_d_start_enrolled_date        DATE := SYSDATE;
    l_d_end_enrolled_date          DATE := TO_DATE('12/31/2055 11:59:59 PM'
                                                  ,'MM/DD/YYYY HH:MI:SS AM');
    l_i_error_code                 PLS_INTEGER := 0;
    l_i_enrolled_esn_objid         sa.table_part_inst.objid%TYPE;
    l_v_error_message              VARCHAR2(32767) := 'SUCCESS';
    l_v_position                   VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note                       VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_v_safelink_esn               sa.x_sl_referral_benefits_plan.safelink_esn%TYPE;
    l_v_benefits_enrolled          sa.x_sl_referral_benefits_plan.benefits_enrolled%TYPE;
    l_v_enrolled_into_double_minut VARCHAR2(1) := 'N';
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_enrolled_esn: ' || NVL(p_enrolled_esn
                                                    ,'Value is null'));
      dbms_output.put_line('p_safelink_min: ' || NVL(p_safelink_min
                                                    ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Validate ESN to enroll and SafeLink ESN by calling valid_for_referral_enrollment procedure';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    valid_for_referral_enrollment(p_enrolled_esn       => p_enrolled_esn
                                 ,p_safelink_min       => p_safelink_min
                                 ,p_enrolled_esn_objid => l_i_enrolled_esn_objid
                                 ,p_safelink_esn       => l_v_safelink_esn
                                 ,p_error_code         => l_i_error_code
                                 ,p_error_message      => l_v_error_message);
    --
    IF (l_i_error_code <> 0) THEN
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Check if ESN to enroll can be enrolled into Double Minute Program';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (sa.get_dblmin_usage_fun(ip_esn        => p_enrolled_esn
                               ,ip_promocode  => 'RTDBL000'
                               ,ip_promounits => 0
                               ,ip_chkpromo   => 'YES') = 0)
       AND (sa.get_dblmin_usage_fun(ip_esn        => p_enrolled_esn
                                   ,ip_promocode  => 'RTX3X000'
                                   ,ip_promounits => 0
                                   ,ip_chkpromo   => 'YES') = 0) THEN
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'Enroll ESN to enroll into Double Minute Program';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF get_promo_info_curs%ISOPEN THEN
        --
        CLOSE get_promo_info_curs;
        --
      END IF;
      --
      OPEN get_promo_info_curs;
      FETCH get_promo_info_curs
        INTO get_promo_info_rec;
      CLOSE get_promo_info_curs;
      --
      INSERT INTO sa.table_x_group2esn
        (objid
        ,x_annual_plan
        ,groupesn2part_inst
        ,groupesn2x_promo_group
        ,x_end_date
        ,x_start_date
        ,groupesn2x_promotion)
      VALUES
        (sa.seq('x_group2esn')
        ,1
        ,l_i_enrolled_esn_objid
        ,get_promo_info_rec.promotion_group_objid
        ,l_d_end_enrolled_date
        ,l_d_start_enrolled_date
        ,get_promo_info_rec.promotion_objid);
      --
      INSERT INTO sa.table_x_group_hist
        (objid
        ,x_start_date
        ,x_end_date
        ,x_action_date
        ,x_action_type
        ,x_annual_plan
        ,grouphist2part_inst
        ,grouphist2x_promo_group
        ,x_old_esn)
      VALUES
        (sa.seq('x_group_hist')
        ,l_d_start_enrolled_date
        ,l_d_end_enrolled_date
        ,l_d_start_enrolled_date
        ,'ACTIVATION'
        ,1
        ,l_i_enrolled_esn_objid
        ,get_promo_info_rec.promotion_group_objid
        ,NULL);
      --
      l_v_enrolled_into_double_minut := 'Y';
      l_v_benefits_enrolled          := l_v_benefits_enrolled || get_promo_info_rec.promotion_group;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.5';
    l_v_note     := 'Update x_sl_referral_benefits_plan table for ESN to enrolled (pseudo re-enrollment)';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    UPDATE sa.x_sl_referral_benefits_plan
       SET safelink_esn        = l_v_safelink_esn
          ,start_enrolled_date = l_d_start_enrolled_date
          ,end_enrolled_date   = l_d_end_enrolled_date
          ,benefits_enrolled   = l_v_benefits_enrolled
     WHERE enrolled_esn = p_enrolled_esn;
    --
    IF (SQL%ROWCOUNT = 0) THEN
      --
      l_v_position := l_cv_subprogram_name || '.6';
      l_v_note     := 'Insert into x_sl_referral_benefits_plan table';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      INSERT INTO sa.x_sl_referral_benefits_plan
        (objid
        ,enrolled_esn
        ,safelink_esn
        ,start_enrolled_date
        ,end_enrolled_date
        ,benefits_enrolled)
      VALUES
        (sa.seq_sl_referral_benefits_plan.nextval
        ,p_enrolled_esn
        ,l_v_safelink_esn
        ,l_d_start_enrolled_date
        ,l_d_end_enrolled_date
        ,l_v_benefits_enrolled);
      --
    END IF;
    --
    COMMIT;
    --
    l_v_position := l_cv_subprogram_name || '.7';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                     ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                     ,'Value is null'));
      --
    END IF;
    --
    p_enrolled_into_double_minute := l_v_enrolled_into_double_minut;
    p_error_code                  := l_i_error_code;
    p_error_message               := l_v_error_message;
    --
    -- CR16379 Start kacosta 03/09/2012
    DECLARE
      --
      l_i_error_code_block    INTEGER := 0;
      l_v_error_message_block VARCHAR2(32767) := 'SUCCESS';
      --
    BEGIN
      --
      promotion_pkg.expire_double_if_esn_is_triple(p_esn           => p_enrolled_esn
                                                  ,p_error_code    => l_i_error_code_block
                                                  ,p_error_message => l_v_error_message_block);
      --
      IF (l_i_error_code_block <> 0) THEN
        --
        dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with error: ' || l_v_error_message_block);
        --
      END IF;
      --
    EXCEPTION
      WHEN others THEN
        --
        dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with Oracle error: ' || SQLCODE);
        --
    END;
    -- CR16379 End kacosta 03/09/2012
    --
  EXCEPTION
    WHEN l_ex_business_error THEN
      --
      ROLLBACK;
      --
      p_enrolled_into_double_minute := NULL;
      p_error_code                  := l_i_error_code;
      p_error_message               := l_v_error_message;
      --
      l_v_position := l_cv_subprogram_name || '.8';
      l_v_note     := 'End executing with business error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      IF get_promo_info_curs%ISOPEN THEN
        --
        CLOSE get_promo_info_curs;
        --
      END IF;
      --
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_enrolled_into_double_minute := NULL;
      p_error_code                  := SQLCODE;
      p_error_message               := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.9';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
        dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                       ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => NULL
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
      IF get_promo_info_curs%ISOPEN THEN
        --
        CLOSE get_promo_info_curs;
        --
      END IF;
      --
  END referral_benefits_enrollment;
  --
END safelink_maintenance_pkg;
/