CREATE OR REPLACE PACKAGE BODY sa."BAU_MAINTENANCE_PKG" IS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: BAU_MAINTENANCE_PKB.sql,v $
  --$Revision: 1.4 $
  --$Author: icanavan $
  --$Date: 2012/08/20 17:30:45 $
  --$ $Log: BAU_MAINTENANCE_PKB.sql,v $
  --$ Revision 1.4  2012/08/20 17:30:45  icanavan
  --$ Add change for Telcel
  --$
  --$ Revision 1.3  2012/07/12 15:42:26  kacosta
  --$ CR21179 Deactivation Issue/CR21077 Error 119 Active Service Not Found
  --$
  --$ Revision 1.2  2012/06/25 14:27:13  kacosta
  --$ CR21179 Deactivation Issue
  --$
  --$ Revision 1.1  2012/06/15 19:16:46  kacosta
  --$ CR21077 Error 119 Active Service Not Found
  --$
  --$
  ---------------------------------------------------------------------------------------------
  -- Private Package Variables
  --
  l_cv_package_name CONSTANT VARCHAR2(30) := 'bau_maintenance_pkg';
  --
  -- Private Functions
  --
  PROCEDURE insert_npanxx
  (
    p_min           IN sa.table_part_inst.part_serial_no%TYPE
   ,p_carrier_id    IN sa.table_x_carrier.x_carrier_id%TYPE
   ,p_zipcode       IN sa.table_site_part.x_zipcode%TYPE
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    CURSOR l_cur_carrier_npanxx
    (
      c_v_min        sa.table_part_inst.part_serial_no%TYPE
     ,c_n_carrier_id sa.table_x_carrier.x_carrier_id%TYPE
     ,c_v_zipcode    sa.table_site_part.x_zipcode%TYPE
    ) IS
      SELECT DISTINCT SUBSTR(c_v_min
                            ,1
                            ,3) npa
                     ,SUBSTR(c_v_min
                            ,4
                            ,3) nxx
                     ,ncz.carrier_id
                     ,MIN(ncz.carrier_name) carrier_name
                     ,'0' lead_time
                     ,'0' target_level
                     ,MIN(ncz.ratecenter) ratecenter
                     ,ncz.state
                     ,'PORT CALL_CENTER' carrier_id_description
                     ,ncz.zone
                     ,MIN(ncz.county) county
                     ,MIN(ncz.marketid) marketid
                     ,MIN(ncz.mrkt_area) mrkt_area
                     ,MIN(ncz.sid) sid
                     ,CASE
                        WHEN ncz.gsm_tech = 'GSM' THEN
                         'GSM'
                        WHEN ncz.cdma_tech = 'CDMA' THEN
                         'CDMA'
                        ELSE
                         NULL
                      END technology
                     ,MIN(ncz.frequency1) frequency1
                     ,MIN(ncz.frequency2) frequency2
                     ,MIN(ncz.bta_mkt_number) bta_mkt_number
                     ,MIN(ncz.bta_mkt_name) bta_mkt_name
                     ,NULL tdma_tech
                     ,CASE
                        WHEN ncz.gsm_tech = 'GSM' THEN
                         'GSM'
                        WHEN ncz.cdma_tech = 'CDMA' THEN
                         'NULL'
                        ELSE
                         NULL
                      END gsm_tech
                     ,CASE
                        WHEN ncz.cdma_tech = 'CDMA' THEN
                         'CDMA'
                        ELSE
                         NULL
                      END cdma_tech
                     ,CASE
                        WHEN (ncz.carrier_name LIKE 'AT%T%' OR ncz.carrier_name LIKE 'CING%') THEN
                         'G0410'
                        WHEN ncz.carrier_name LIKE 'T-MO%' THEN
                         'G0260'
                        ELSE
                         ''
                      END mnc_v
        FROM sa.npanxx2carrierzones ncz
        JOIN sa.carrierzones crz
          ON ncz.zone = crz.zone
         AND ncz.state = crz.st
       WHERE 1 = 1
         AND ncz.carrier_id = c_n_carrier_id
         AND EXISTS (SELECT 1
                FROM sa.table_x_carrier txc
               WHERE txc.x_carrier_id = ncz.carrier_id
                 AND txc.x_status = 'ACTIVE')
         AND crz.zip = c_v_zipcode
         AND ROWNUM <= 1
       GROUP BY ncz.npa
               ,ncz.nxx
               ,ncz.carrier_id
               ,ncz.carrier_name
               ,ncz.state
               ,ncz.zone
               ,CASE
                  WHEN ncz.gsm_tech = 'GSM' THEN
                   'GSM'
                  WHEN ncz.cdma_tech = 'CDMA' THEN
                   'CDMA'
                  ELSE
                   NULL
                END
               ,CASE
                  WHEN ncz.gsm_tech = 'GSM' THEN
                   'GSM'
                  WHEN ncz.cdma_tech = 'CDMA' THEN
                   'NULL'
                  ELSE
                   NULL
                END
               ,CASE
                  WHEN ncz.cdma_tech = 'CDMA' THEN
                   'CDMA'
                  ELSE
                   NULL
                END
               ,CASE
                  WHEN (ncz.carrier_name LIKE 'AT%T%' AND ncz.carrier_name LIKE 'CING%') THEN
                   'G0410'
                  WHEN (ncz.carrier_name LIKE 'T-MO%') THEN
                   'G0260'
                  ELSE
                   ''
                END;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.insert_npanxx';
    l_ex_business_error EXCEPTION;
    l_i_error_code       PLS_INTEGER := 0;
    l_rec_carrier_npanxx l_cur_carrier_npanxx%ROWTYPE;
    l_v_error_message    VARCHAR2(32767) := 'SUCCESS';
    l_v_position         VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note             VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_min       : ' || NVL(p_min
                                                  ,'Value is null'));
      dbms_output.put_line('p_carrier_id: ' || NVL(TO_CHAR(p_carrier_id)
                                                  ,'Value is null'));
      dbms_output.put_line('p_zipcode   : ' || NVL(p_zipcode
                                                  ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get carrier npanxx based on carrier, zipcode and min';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF l_cur_carrier_npanxx%ISOPEN THEN
      --
      CLOSE l_cur_carrier_npanxx;
      --
    END IF;
    --
    OPEN l_cur_carrier_npanxx(c_v_min        => p_min
                             ,c_n_carrier_id => p_carrier_id
                             ,c_v_zipcode    => p_zipcode);
    FETCH l_cur_carrier_npanxx
      INTO l_rec_carrier_npanxx;
    CLOSE l_cur_carrier_npanxx;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Check if carrier npanxx was found';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (l_rec_carrier_npanxx.npa IS NOT NULL) THEN
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'Insert new carrier npanxx insert into npanxx2carrierzones';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      INSERT INTO npanxx2carrierzones
      VALUES
        (l_rec_carrier_npanxx.npa
        ,l_rec_carrier_npanxx.nxx
        ,l_rec_carrier_npanxx.carrier_id
        ,l_rec_carrier_npanxx.carrier_name
        ,l_rec_carrier_npanxx.lead_time
        ,l_rec_carrier_npanxx.target_level
        ,l_rec_carrier_npanxx.ratecenter
        ,l_rec_carrier_npanxx.state
        ,l_rec_carrier_npanxx.carrier_id_description
        ,l_rec_carrier_npanxx.zone
        ,l_rec_carrier_npanxx.county
        ,l_rec_carrier_npanxx.marketid
        ,l_rec_carrier_npanxx.mrkt_area
        ,l_rec_carrier_npanxx.sid
        ,l_rec_carrier_npanxx.technology
        ,l_rec_carrier_npanxx.frequency1
        ,l_rec_carrier_npanxx.frequency2
        ,l_rec_carrier_npanxx.bta_mkt_number
        ,l_rec_carrier_npanxx.bta_mkt_name
        ,l_rec_carrier_npanxx.tdma_tech
        ,l_rec_carrier_npanxx.gsm_tech
        ,l_rec_carrier_npanxx.cdma_tech
        ,l_rec_carrier_npanxx.mnc_v);
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
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                     ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                     ,'Value is null'));
      --
    END IF;
    --
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN l_ex_business_error THEN
      --
      ROLLBACK;
      --
      p_error_code    := l_i_error_code;
      p_error_message := l_v_error_message;
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
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
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
                          ,p_key          => p_min
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END;
  --
  --********************************************************************************
  -- Procedure to fix site part information based on ig transaction
  --********************************************************************************
  --
  PROCEDURE insert_min
  (
    p_min           IN sa.table_part_inst.part_serial_no%TYPE
   ,p_esn           IN sa.table_part_inst.part_serial_no%TYPE
   ,p_msid          IN sa.table_site_part.x_msid%TYPE
   ,p_carrier_id    IN sa.table_x_carrier.x_carrier_id%TYPE
   ,p_expire_date   IN sa.table_site_part.x_expire_dt%TYPE
   ,p_zipcode       IN sa.table_site_part.x_zipcode%TYPE
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --
    CURSOR l_cur_esn_objid(c_v_esn IN sa.table_part_inst.part_serial_no%TYPE) IS
      SELECT tpi_esn.objid              esn_objid
            ,tpi_esn.x_part_inst_status esn_status_number
        FROM sa.table_part_inst tpi_esn
       WHERE tpi_esn.part_serial_no = c_v_esn
         AND tpi_esn.x_domain = 'PHONES';
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.insert_min';
    l_ex_business_error EXCEPTION;
    l_i_error_code    PLS_INTEGER := 0;
    l_n_carrier_id    sa.table_x_carrier.x_carrier_id%TYPE;
    l_rec_esn_objid   l_cur_esn_objid%ROWTYPE;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_v_carrier_name  sa.table_x_carrier.x_mkt_submkt_name%TYPE;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_min        : ' || NVL(p_min
                                                   ,'Value is null'));
      dbms_output.put_line('p_esn        : ' || NVL(p_esn
                                                   ,'Value is null'));
      dbms_output.put_line('p_msid       : ' || NVL(p_msid
                                                   ,'Value is null'));
      dbms_output.put_line('p_carrier_id : ' || NVL(TO_CHAR(p_carrier_id)
                                                   ,'Value is null'));
      dbms_output.put_line('p_expire_date: ' || NVL(TO_CHAR(p_expire_date
                                                           ,'MM/DD/YYYY HH:MI:SS AM')
                                                   ,'Value is null'));
      dbms_output.put_line('p_zipcode    : ' || NVL(p_zipcode
                                                   ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get ESN objid and status';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF l_cur_esn_objid%ISOPEN THEN
      --
      CLOSE l_cur_esn_objid;
      --
    END IF;
    --
    OPEN l_cur_esn_objid(c_v_esn => p_esn);
    FETCH l_cur_esn_objid
      INTO l_rec_esn_objid;
    CLOSE l_cur_esn_objid;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Check if ESN objid and status was found';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (l_rec_esn_objid.esn_objid IS NOT NULL) THEN
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'Yes, ESN objid and status was found; check if the ESN is not Active';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF (l_rec_esn_objid.esn_status_number <> '52') THEN
        --
        l_v_position := l_cv_subprogram_name || '.5';
        l_v_note     := 'ESN is not Active; update ESN part inst to Active';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        UPDATE sa.table_part_inst
           SET x_part_inst_status  = '52'
              ,status2x_code_table = 988
         WHERE objid = l_rec_esn_objid.esn_objid;
        --
      END IF;
      --
      l_v_position := l_cv_subprogram_name || '.6';
      l_v_note     := 'Update MIN to Active';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      UPDATE sa.table_part_inst
         SET part_to_esn2part_inst = l_rec_esn_objid.esn_objid
            ,x_part_inst_status    = '13'
            ,status2x_code_table   = 960
       WHERE part_serial_no = p_min
         AND x_domain = 'LINES';
      --
      l_v_position := l_cv_subprogram_name || '.7';
      l_v_note     := 'Was MIN updated to Active';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF (SQL%ROWCOUNT = 0) THEN
        --
        l_v_position := l_cv_subprogram_name || '.8';
        l_v_note     := 'No, MIN was not updated to Active; calling toppapp.line_insert_pkg.line_validation ';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        toppapp.line_insert_pkg.line_validation(ip_msid         => p_msid
                                               ,ip_min          => p_min
                                               ,ip_carrier_id   => p_carrier_id
                                               ,ip_file_name    => 'CRM_APP_SUPPORT'
                                               ,ip_file_type    => '1'
                                               ,ip_expire_date  => NVL(TO_CHAR(p_expire_date
                                                                              ,'MM/DD/YYYY')
                                                                      ,'NA')
                                               ,op_carrier_id   => l_n_carrier_id
                                               ,op_carrier_name => l_v_carrier_name
                                               ,op_result       => l_i_error_code
                                               ,op_msg          => l_v_error_message);
        --
        l_v_position := l_cv_subprogram_name || '.9';
        l_v_note     := 'Check toppapp.line_insert_pkg.line_validation error code';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF (l_i_error_code = 102) THEN
          --
          l_v_position := l_cv_subprogram_name || '.10';
          l_v_note     := 'Error code is 102 (Does not have a valid NPA/NXX in LUTS); calling insert_npanxx';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          insert_npanxx(p_min           => p_min
                       ,p_carrier_id    => p_carrier_id
                       ,p_zipcode       => p_zipcode
                       ,p_error_code    => l_i_error_code
                       ,p_error_message => l_v_error_message);
          --
          IF (l_i_error_code <> 0) THEN
            --
            RAISE l_ex_business_error;
            --
          END IF;
          --
          l_v_position := l_cv_subprogram_name || '.11';
          l_v_note     := 'Calling toppapp.line_insert_pkg.line_validation again';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          toppapp.line_insert_pkg.line_validation(ip_msid         => p_msid
                                                 ,ip_min          => p_min
                                                 ,ip_carrier_id   => p_carrier_id
                                                 ,ip_file_name    => 'CRM_APP_SUPPORT'
                                                 ,ip_file_type    => '1'
                                                 ,ip_expire_date  => NVL(TO_CHAR(p_expire_date
                                                                                ,'MM/DD/YYYY')
                                                                        ,'NA')
                                                 ,op_carrier_id   => l_n_carrier_id
                                                 ,op_carrier_name => l_v_carrier_name
                                                 ,op_result       => l_i_error_code
                                                 ,op_msg          => l_v_error_message);
          --
          IF (l_i_error_code <> 1) THEN
            --
            IF (l_i_error_code = 0) THEN
              --
              l_i_error_code    := SQLERRM;
              l_v_error_message := l_v_error_message || SQLCODE;
              --
            END IF;
            --
            RAISE l_ex_business_error;
            --
          ELSE
            --
            l_i_error_code    := 0;
            l_v_error_message := 'SUCCESS';
            --
          END IF;
          --
        ELSIF (l_i_error_code <> 1) THEN
          --
          IF (l_i_error_code = 0) THEN
            --
            l_i_error_code    := SQLERRM;
            l_v_error_message := l_v_error_message || SQLCODE;
            --
          END IF;
          --
          RAISE l_ex_business_error;
          --
        ELSE
          --
          l_i_error_code    := 0;
          l_v_error_message := 'SUCCESS';
          --
        END IF;
        --
        l_v_position := l_cv_subprogram_name || '.12';
        l_v_note     := 'Update MIN to Active again';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        UPDATE sa.table_part_inst
           SET part_to_esn2part_inst = l_rec_esn_objid.esn_objid
              ,x_part_inst_status    = '13'
              ,status2x_code_table   = 960
         WHERE part_serial_no = p_min
           AND x_domain = 'LINES';
        --
      END IF;
      --
      IF (SQL%ROWCOUNT = 1) THEN
        --
        UPDATE sa.table_part_inst
           SET part_to_esn2part_inst = NULL
         WHERE part_to_esn2part_inst = l_rec_esn_objid.esn_objid
           AND part_serial_no <> p_min
           AND x_domain = 'LINES';
        --
      ELSIF (SQL%ROWCOUNT = 0) THEN
        --
        l_i_error_code    := 4;
        l_v_error_message := 'Unable able to update MIN to Active';
        --
        RAISE l_ex_business_error;
        --
      ELSE
        --
        l_i_error_code    := 5;
        l_v_error_message := 'Updated too many MINs to Active';
        --
        RAISE l_ex_business_error;
        --
      END IF;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.13';
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
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN l_ex_business_error THEN
      --
      ROLLBACK;
      --
      p_error_code    := l_i_error_code;
      p_error_message := l_v_error_message;
      --
      l_v_position := l_cv_subprogram_name || '.14';
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
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.15';
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
                          ,p_key          => p_min
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END insert_min;
  --
  --********************************************************************************
  -- Procedure to fix site part information based on ig transaction
  --********************************************************************************
  --
  PROCEDURE check_ig_transaction
  (
    p_site_part_objid IN sa.table_site_part.objid%TYPE
   ,p_esn             IN sa.table_part_inst.part_serial_no%TYPE
   ,p_install_date    IN sa.table_site_part.install_date%TYPE
   ,p_expire_date     IN sa.table_site_part.x_expire_dt%TYPE
   ,p_zipcode         IN sa.table_site_part.x_zipcode%TYPE
   ,p_error_code      OUT PLS_INTEGER
   ,p_error_message   OUT VARCHAR2
  ) IS
    --
    CURSOR l_cur_call_trans_igt_info
    (
      c_n_site_part_objid IN sa.table_x_call_trans.call_trans2site_part%TYPE
     ,c_d_install_date    IN sa.table_x_call_trans.x_transact_date%TYPE
    ) IS
      SELECT igt.action_item_id igt_action_item_id
            ,igt.min            igt_min
            ,igt.msid           igt_msid
            ,igt.carrier_id     igt_carrier_id
        FROM sa.table_x_call_trans xct
        JOIN sa.table_task tbt
          ON xct.objid = tbt.x_task2x_call_trans
        JOIN gw1.ig_transaction igt
          ON tbt.task_id = igt.action_item_id
       WHERE xct.call_trans2site_part = c_n_site_part_objid
         AND xct.x_transact_date >= c_d_install_date
         AND xct.x_action_type <> '2'
         AND xct.x_result = 'Completed'
         AND xct.x_transact_date <= igt.creation_date
         AND igt.status = 'S'
         AND igt.order_type NOT IN ('S'
                                   ,'D')
         AND igt.creation_date = (SELECT MAX(igt_max_xact.creation_date)
                                    FROM sa.table_x_call_trans xct_max_xact
                                    JOIN sa.table_task tbt_max_xact
                                      ON xct_max_xact.objid = tbt_max_xact.x_task2x_call_trans
                                    JOIN gw1.ig_transaction igt_max_xact
                                      ON tbt_max_xact.task_id = igt_max_xact.action_item_id
                                   WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                     AND xct_max_xact.x_transact_date >= c_d_install_date
                                     AND xct_max_xact.x_action_type <> '2'
                                     AND xct_max_xact.x_result = 'Completed'
                                     AND xct_max_xact.x_transact_date <= igt_max_xact.creation_date
                                     AND igt_max_xact.status = 'S'
                                     AND igt_max_xact.order_type NOT IN ('S'
                                                                        ,'D'));
    --
    CURSOR l_cur_call_trans_igth_info
    (
      c_n_site_part_objid IN sa.table_x_call_trans.call_trans2site_part%TYPE
     ,c_d_install_date    IN sa.table_x_call_trans.x_transact_date%TYPE
    ) IS
      SELECT igh.action_item_id igh_action_item_id
            ,igh.min            igh_min
            ,igh.msid           igh_msid
            ,igh.carrier_id     igh_carrier_id
        FROM sa.table_x_call_trans xct
        JOIN sa.table_task tbt
          ON xct.objid = tbt.x_task2x_call_trans
        JOIN gw1.ig_transaction_history igh
          ON tbt.task_id = igh.action_item_id
       WHERE xct.call_trans2site_part = c_n_site_part_objid
         AND xct.x_transact_date >= c_d_install_date
         AND xct.x_action_type <> '2'
         AND xct.x_result = 'Completed'
         AND xct.x_transact_date <= igh.creation_date
         AND igh.status = 'S'
         AND igh.order_type NOT IN ('S'
                                   ,'D')
         AND igh.creation_date = (SELECT MAX(igh_max_xact.creation_date)
                                    FROM sa.table_x_call_trans xct_max_xact
                                    JOIN sa.table_task tbt_max_xact
                                      ON xct_max_xact.objid = tbt_max_xact.x_task2x_call_trans
                                    JOIN gw1.ig_transaction_history igh_max_xact
                                      ON tbt_max_xact.task_id = igh_max_xact.action_item_id
                                   WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                     AND xct_max_xact.x_transact_date >= c_d_install_date
                                     AND xct_max_xact.x_action_type <> '2'
                                     AND xct_max_xact.x_result = 'Completed'
                                     AND xct_max_xact.x_transact_date <= igh_max_xact.creation_date
                                     AND igh_max_xact.status = 'S'
                                     AND igh_max_xact.order_type NOT IN ('S'
                                                                        ,'D'));
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.check_ig_transaction';
    l_ex_business_error EXCEPTION;
    l_i_error_code             PLS_INTEGER := 0;
    l_rec_call_trans_igt_info  l_cur_call_trans_igt_info%ROWTYPE;
    l_rec_call_trans_igth_info l_cur_call_trans_igth_info%ROWTYPE;
    l_v_error_message          VARCHAR2(32767) := 'SUCCESS';
    l_v_position               VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note                   VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_site_part_objid: ' || NVL(TO_CHAR(p_site_part_objid)
                                                       ,'Value is null'));
      dbms_output.put_line('p_esn            : ' || NVL(p_esn
                                                       ,'Value is null'));
      dbms_output.put_line('p_install_date   : ' || NVL(TO_CHAR(p_install_date
                                                               ,'MM/DD/YYYY HH:MI:SS PM')
                                                       ,'Value is null'));
      dbms_output.put_line('p_expire_date    : ' || NVL(TO_CHAR(p_expire_date
                                                               ,'MM/DD/YYYY HH:MI:SS PM')
                                                       ,'Value is null'));
      dbms_output.put_line('p_zipcode        : ' || NVL(p_zipcode
                                                       ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get latest ig transaction for the site part record';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF l_cur_call_trans_igt_info%ISOPEN THEN
      --
      CLOSE l_cur_call_trans_igt_info;
      --
    END IF;
    --
    OPEN l_cur_call_trans_igt_info(c_n_site_part_objid => p_site_part_objid
                                  ,c_d_install_date    => p_install_date);
    FETCH l_cur_call_trans_igt_info
      INTO l_rec_call_trans_igt_info;
    CLOSE l_cur_call_trans_igt_info;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Check if the latest ig transaction for the site part record was found';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (l_rec_call_trans_igt_info.igt_action_item_id IS NULL) THEN
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'No, the latest ig transaction for the site part record was not found';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'Get latest ig transaction history for the site part record';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      OPEN l_cur_call_trans_igth_info(c_n_site_part_objid => p_site_part_objid
                                     ,c_d_install_date    => p_install_date);
      FETCH l_cur_call_trans_igth_info
        INTO l_rec_call_trans_igth_info;
      CLOSE l_cur_call_trans_igth_info;
      --
      l_rec_call_trans_igt_info := l_rec_call_trans_igth_info;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.6';
    l_v_note     := 'Check if either the latest ig transaction or the latest ig transaction history for the site part record was not found';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (l_rec_call_trans_igt_info.igt_action_item_id IS NOT NULL) THEN
      --
      l_v_position := l_cv_subprogram_name || '.7';
      l_v_note     := 'Latest ig transaction for the site part record was found; check if the ig transaction min is not a Tnumber';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF (l_rec_call_trans_igt_info.igt_min NOT LIKE 'T%') THEN
        --
        l_v_position := l_cv_subprogram_name || '.8';
        l_v_note     := 'The ig transaction min is not a Tnumber; update site part record to Active';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        UPDATE sa.table_site_part
           SET x_min       = l_rec_call_trans_igt_info.igt_min
              ,x_msid      = l_rec_call_trans_igt_info.igt_msid
              ,part_status = 'Active'
         WHERE objid = p_site_part_objid;
        --
        l_v_position := l_cv_subprogram_name || '.9';
        l_v_note     := 'The ig transaction min is not a Tnumber; update call trans min for site part record';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        UPDATE sa.table_x_call_trans
           SET x_min = l_rec_call_trans_igt_info.igt_min
         WHERE call_trans2site_part = p_site_part_objid
           AND x_transact_date >= p_install_date
           AND x_min <> l_rec_call_trans_igt_info.igt_min;
        --
        l_v_position := l_cv_subprogram_name || '.10';
        l_v_note     := 'Update Failed call trans to Completed for site part record';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        UPDATE sa.table_x_call_trans
           SET x_result = 'Completed'
         WHERE call_trans2site_part = p_site_part_objid
           AND x_transact_date >= p_install_date
           AND x_action_type IN ('1'
                                ,'3')
           AND UPPER(x_result) = 'FAILED';
        --
        l_v_position := l_cv_subprogram_name || '.11';
        l_v_note     := 'If the ig transaction contain a valid carrier call insert_min';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF (NVL(l_rec_call_trans_igt_info.igt_carrier_id
               ,0) <> 0) THEN
          --
          l_v_position := l_cv_subprogram_name || '.12';
          l_v_note     := 'Calling insert_min';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          insert_min(p_min           => l_rec_call_trans_igt_info.igt_min
                    ,p_esn           => p_esn
                    ,p_msid          => l_rec_call_trans_igt_info.igt_msid
                    ,p_carrier_id    => l_rec_call_trans_igt_info.igt_carrier_id
                    ,p_expire_date   => p_expire_date
                    ,p_zipcode       => p_zipcode
                    ,p_error_code    => l_i_error_code
                    ,p_error_message => l_v_error_message);
          --
          IF (l_i_error_code <> 0) THEN
            --
            RAISE l_ex_business_error;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
    ELSE
      --
      l_i_error_code    := 3;
      l_v_error_message := 'The latest ig transaction or ig_transaction history for the site part record was not found';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.13';
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
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN l_ex_business_error THEN
      --
      ROLLBACK;
      --
      p_error_code    := l_i_error_code;
      p_error_message := l_v_error_message;
      --
      l_v_position := l_cv_subprogram_name || '.14';
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
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.15';
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
                          ,p_key          => TO_CHAR(p_site_part_objid)
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END check_ig_transaction;
  --
  -- Public Procedures
  --
  --********************************************************************************
  -- Procedure to fix min for esn
  --********************************************************************************
  --
  PROCEDURE fix_site_part_for_esn
  (
    p_esn           IN sa.table_part_inst.part_serial_no%TYPE
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --
    CURSOR l_cur_esn_act_carpnd_site_part(c_v_esn sa.table_site_part.x_service_id%TYPE) IS
      SELECT tsp.objid site_part_objid
            ,tsp.x_service_id site_part_esn
            ,tsp.x_min site_part_min
            ,tsp.x_msid site_part_msid
            ,tsp.part_status site_part_status
            ,tsp.install_date site_part_install_date
            ,CASE
               WHEN (NVL(TRUNC(tsp.x_expire_dt)
                        ,TO_DATE('01/01/1753'
                                ,'MM/DD/YYYY')) = TO_DATE('01/01/1753'
                                                          ,'MM/DD/YYYY')) THEN
                NULL
               ELSE
                TRUNC(tsp.x_expire_dt)
             END site_part_expire_date
            ,tsp.x_zipcode site_part_zipcode
        FROM sa.table_site_part tsp
       WHERE tsp.objid = (SELECT MAX(tsp_max.objid)
                            FROM sa.table_site_part tsp_max
                           WHERE tsp_max.x_service_id = c_v_esn
                             AND tsp_max.part_status IN ('Active'
                                                        ,'CarrierPending')
                             AND tsp_max.install_date = (SELECT MAX(tsp_max_install.install_date)
                                                           FROM sa.table_site_part tsp_max_install
                                                          WHERE tsp_max_install.x_service_id = c_v_esn
                                                            AND tsp_max_install.part_status IN ('Active'
                                                                                               ,'CarrierPending')));
    --
    CURSOR l_cur_max_call_trans_due_date(c_n_site_part_objid sa.table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT TRUNC(x_new_due_date) call_trans_due_date
        FROM sa.table_x_call_trans xct
       WHERE xct.objid = (SELECT MAX(xct_max.objid)
                            FROM sa.table_x_call_trans xct_max
                           WHERE xct_max.call_trans2site_part = c_n_site_part_objid
                             AND xct_max.x_action_type IN ('1'
                                                          ,'3'
                                                          ,'6')
                             AND xct_max.x_result = 'Completed'
                             AND NVL(TRUNC(xct_max.x_new_due_date)
                                    ,TO_DATE('01/01/1753'
                                            ,'MM/DD/YYYY')) > TO_DATE('01/01/1753'
                                                                     ,'MM/DD/YYYY')
                             AND xct_max.x_transact_date = (SELECT MAX(xct_max_xact.x_transact_date)
                                                              FROM sa.table_x_call_trans xct_max_xact
                                                             WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                                               AND xct_max_xact.x_action_type IN ('1'
                                                                                                 ,'3'
                                                                                                 ,'6')
                                                               AND xct_max_xact.x_result = 'Completed'
                                                               AND NVL(TRUNC(xct_max_xact.x_new_due_date)
                                                                      ,TO_DATE('01/01/1753'
                                                                              ,'MM/DD/YYYY')) > TO_DATE('01/01/1753'
                                                                                                       ,'MM/DD/YYYY')));
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.fix_site_part_for_esn';
    l_ex_business_error EXCEPTION;
    l_i_error_code                 PLS_INTEGER := 0;
    l_rec_esn_act_carpnd_site_part l_cur_esn_act_carpnd_site_part%ROWTYPE;
    l_rec_max_call_trans_due_date  l_cur_max_call_trans_due_date%ROWTYPE;
    l_v_error_message              VARCHAR2(32767) := 'SUCCESS';
    l_v_position                   VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note                       VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn: ' || NVL(p_esn
                                           ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get latest ESN Active or CarrierPending site part record';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF l_cur_esn_act_carpnd_site_part%ISOPEN THEN
      --
      CLOSE l_cur_esn_act_carpnd_site_part;
      --
    END IF;
    --
    OPEN l_cur_esn_act_carpnd_site_part(c_v_esn => p_esn);
    FETCH l_cur_esn_act_carpnd_site_part
      INTO l_rec_esn_act_carpnd_site_part;
    CLOSE l_cur_esn_act_carpnd_site_part;
    --
    IF (l_rec_esn_act_carpnd_site_part.site_part_objid IS NULL) THEN
      --
      l_i_error_code    := 1;
      l_v_error_message := 'No Active or CarrierPending site part record for ESN';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Get site part due date from call trans';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF l_cur_max_call_trans_due_date%ISOPEN THEN
      --
      CLOSE l_cur_max_call_trans_due_date;
      --
    END IF;
    --
    OPEN l_cur_max_call_trans_due_date(c_n_site_part_objid => l_rec_esn_act_carpnd_site_part.site_part_objid);
    FETCH l_cur_max_call_trans_due_date
      INTO l_rec_max_call_trans_due_date;
    CLOSE l_cur_max_call_trans_due_date;
    --
    IF (l_rec_max_call_trans_due_date.call_trans_due_date IS NULL) THEN
      --
      l_i_error_code    := 2;
      l_v_error_message := 'No site part due date from call trans';
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.4';
    l_v_note     := 'Check if the site part expire date needs to be updated';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (l_rec_esn_act_carpnd_site_part.site_part_expire_date IS NULL) THEN
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'Updating site part expire date with call trans next due date';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      UPDATE sa.table_site_part
         SET x_expire_dt = l_rec_max_call_trans_due_date.call_trans_due_date
       WHERE objid = l_rec_esn_act_carpnd_site_part.site_part_objid;
      --
      l_rec_esn_act_carpnd_site_part.site_part_expire_date := l_rec_max_call_trans_due_date.call_trans_due_date;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.6';
    l_v_note     := 'Calling check_ig_transaction to update site part based on the ig transaction';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    check_ig_transaction(p_site_part_objid => l_rec_esn_act_carpnd_site_part.site_part_objid
                        ,p_esn             => l_rec_esn_act_carpnd_site_part.site_part_esn
                        ,p_install_date    => l_rec_esn_act_carpnd_site_part.site_part_install_date
                        ,p_expire_date     => l_rec_esn_act_carpnd_site_part.site_part_expire_date
                        ,p_zipcode         => l_rec_esn_act_carpnd_site_part.site_part_zipcode
                        ,p_error_code      => l_i_error_code
                        ,p_error_message   => l_v_error_message);
    --
    IF (l_i_error_code <> 0) THEN
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.7';
    l_v_note     := 'Update other Active and CarrierPending site part for ESN to Inactive';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    UPDATE sa.table_site_part
       SET part_status = 'Inactive'
     WHERE x_service_id = l_rec_esn_act_carpnd_site_part.site_part_esn
       AND part_status IN ('Active'
                          ,'CarrierPending')
       AND objid <> l_rec_esn_act_carpnd_site_part.site_part_objid;
    --
    l_v_position := l_cv_subprogram_name || '.8';
    l_v_note     := 'Update ESN Active site part expire and warranty date';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    UPDATE sa.table_site_part
       SET x_expire_dt   = l_rec_max_call_trans_due_date.call_trans_due_date
          ,warranty_date = l_rec_max_call_trans_due_date.call_trans_due_date
     WHERE objid = l_rec_esn_act_carpnd_site_part.site_part_objid
       AND x_expire_dt < l_rec_max_call_trans_due_date.call_trans_due_date
       AND part_status = 'Active';
    --
    l_v_position := l_cv_subprogram_name || '.9';
    l_v_note     := 'Update ESN part inst to site part reference';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    UPDATE sa.table_part_inst
       SET x_part_inst2site_part = l_rec_esn_act_carpnd_site_part.site_part_objid
     WHERE part_serial_no = l_rec_esn_act_carpnd_site_part.site_part_esn
       AND x_domain = 'PHONES';
    --
    l_v_position := l_cv_subprogram_name || '.10';
    l_v_note     := 'Update ESN warranty end date if the site part is Active';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    UPDATE sa.table_part_inst
       SET warr_end_date = l_rec_max_call_trans_due_date.call_trans_due_date
     WHERE part_serial_no = l_rec_esn_act_carpnd_site_part.site_part_esn
       AND x_domain = 'PHONES'
       AND EXISTS (SELECT 1
              FROM sa.table_site_part tsp
             WHERE tsp.objid = l_rec_esn_act_carpnd_site_part.site_part_objid
               AND tsp.part_status = 'Active');
    --
    COMMIT;
    --
    l_v_position := l_cv_subprogram_name || '.11';
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
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN l_ex_business_error THEN
      --
      ROLLBACK;
      --
      p_error_code    := l_i_error_code;
      p_error_message := l_v_error_message;
      --
      l_v_position := l_cv_subprogram_name || '.12';
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
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.13';
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
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END fix_site_part_for_esn;
  --
  --CR21179 Start kacosta 06/20/2012
  --********************************************************************************
  -- Procedure to fix site part with due dates of 1/1/1753 for an esn
  --********************************************************************************
  --
  PROCEDURE fix_esn_1753_due_dates
  (
    p_esn           IN table_site_part.x_service_id%TYPE
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --

    CURSOR esn_site_parts_curs(c_v_esn table_site_part.x_service_id%TYPE) IS
      SELECT tsp.objid site_part_objid
            ,tsp.x_service_id site_part_esn
            ,tsp.x_min site_part_min
            ,tsp.install_date site_part_install_date
            ,NVL(TRUNC(tsp.warranty_date)
                ,TO_DATE('01/01/1753'
                        ,'MM/DD/YYYY')) site_part_warranty_date
            ,tbo.org_id brand
            ,tbo.org_flow org_flow --CR20451 | CR20854: Add TELCEL Brand
        FROM table_site_part tsp
        JOIN table_part_inst tpi_esn
          ON tsp.x_service_id = tpi_esn.part_serial_no
        JOIN table_mod_level tml
          ON tpi_esn.n_part_inst2part_mod = tml.objid
        JOIN table_part_num tpn
          ON tml.part_info2part_num = tpn.objid
        JOIN table_bus_org tbo
          ON tpn.part_num2bus_org = tbo.objid
       WHERE tsp.x_service_id = c_v_esn
         AND NVL(tsp.part_status
                ,'Obsolete') = 'Active'
         AND NVL(tsp.x_expire_dt
                ,TO_DATE('01/01/1753'
                        ,'MM/DD/YYYY')) = TO_DATE('01/01/1753'
                                                 ,'MM/DD/YYYY')
         AND tpi_esn.x_domain = 'PHONES'
       ORDER BY tsp.install_date;
    --
    esn_site_parts_rec esn_site_parts_curs%ROWTYPE;
    --
    CURSOR last_call_trans_curs(c_n_site_part_objid table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT xct.objid call_trans_objid
            ,xct.x_transact_date call_trans_transact_date
            ,xct.x_action_type call_trans_action_type
            ,NVL(TRUNC(xct.x_new_due_date)
                ,TO_DATE('01/01/1753'
                        ,'MM/DD/YYYY')) call_trans_new_due_date
            ,xct.x_result call_trans_result
        FROM table_x_call_trans xct
       WHERE xct.objid = (SELECT MAX(xct_max.objid)
                            FROM table_x_call_trans xct_max
                           WHERE xct_max.call_trans2site_part = c_n_site_part_objid
                             AND xct_max.x_transact_date = (SELECT MAX(xct_max_xact.x_transact_date)
                                                              FROM table_x_call_trans xct_max_xact
                                                             WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid));
    --
    last_call_trans_rec last_call_trans_curs%ROWTYPE;
    --
    CURSOR last_completed_call_trans_curs(c_n_site_part_objid table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT xct.objid call_trans_objid
        FROM table_x_call_trans xct
       WHERE xct.objid = (SELECT MAX(xct_max.objid)
                            FROM table_x_call_trans xct_max
                           WHERE xct_max.call_trans2site_part = c_n_site_part_objid
                             AND xct_max.x_result = 'Completed'
                             AND xct_max.x_transact_date = (SELECT MAX(xct_max_xact.x_transact_date)
                                                              FROM table_x_call_trans xct_max_xact
                                                             WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                                               AND xct_max_xact.x_result = 'Completed'));
    --
    last_completed_call_trans_rec last_completed_call_trans_curs%ROWTYPE;
    --
    CURSOR last_other_call_trans_curs
    (
      c_n_site_part_objid table_x_call_trans.call_trans2site_part%TYPE
     ,c_v_esn             table_x_call_trans.x_service_id%TYPE
     ,c_v_min             table_x_call_trans.x_min%TYPE
    ) IS
      SELECT xct.objid         call_trans_objid
            ,xct.x_action_type call_trans_action_type
            ,xct.x_result      call_trans_result
        FROM table_x_call_trans xct
       WHERE xct.objid = (SELECT MAX(xct_max.objid)
                            FROM table_x_call_trans xct_max
                           WHERE xct_max.x_service_id = c_v_esn
                             AND xct_max.x_min = c_v_min
                             AND xct_max.call_trans2site_part <> c_n_site_part_objid
                             AND xct_max.x_transact_date = (SELECT MAX(xct_max_xact.x_transact_date)
                                                              FROM table_x_call_trans xct_max_xact
                                                             WHERE xct_max_xact.x_service_id = c_v_esn
                                                               AND xct_max_xact.x_min = c_v_min
                                                               AND xct_max_xact.call_trans2site_part <> c_n_site_part_objid));
    --
    last_other_call_trans_rec last_other_call_trans_curs%ROWTYPE;
    --
    CURSOR other_actve_site_part_curs
    (
      c_n_site_part_objid table_x_call_trans.call_trans2site_part%TYPE
     ,c_v_esn             table_x_call_trans.x_service_id%TYPE
     ,c_v_min             table_x_call_trans.x_min%TYPE
    ) IS
      SELECT 'Yes' other_site_part
            ,MAX(xct.x_transact_date) max_call_trans_transact_date
        FROM table_site_part tsp_other
        LEFT OUTER JOIN table_x_call_trans xct
          ON tsp_other.objid = xct.call_trans2site_part
         AND xct.x_result = 'Completed'
       WHERE tsp_other.x_service_id = c_v_esn
         AND tsp_other.x_min = c_v_min
         AND tsp_other.objid <> c_n_site_part_objid
         AND NVL(tsp_other.part_status
                ,'Obsolete') = 'Active'
         AND NVL(TRUNC(tsp_other.x_expire_dt)
                ,TO_DATE('01/01/1753'
                        ,'MM/DD/YYYY')) > TO_DATE('01/01/1753'
                                                 ,'MM/DD/YYYY')
       GROUP BY 1;
    --
    other_actve_site_part_rec other_actve_site_part_curs%ROWTYPE;
    --
    CURSOR redemption_cards_curs(c_v_esn table_part_inst.part_serial_no%TYPE) IS
      SELECT COUNT(tpi_red_card.objid) number_of_red_cards
        FROM table_part_inst tpi_esn
        JOIN table_part_inst tpi_red_card
          ON tpi_esn.objid = tpi_red_card.part_to_esn2part_inst
        JOIN table_mod_level tml_red_card
          ON tpi_red_card.n_part_inst2part_mod = tml_red_card.objid
        JOIN table_part_num tpn_red_card
          ON tml_red_card.part_info2part_num = tpn_red_card.objid
       WHERE tpi_esn.part_serial_no = c_v_esn
         AND tpi_esn.x_domain = 'PHONES'
         AND tpi_red_card.x_part_inst_status = '400'
         AND tpi_red_card.x_domain = 'REDEMPTION CARDS';
    --
    redemption_cards_rec redemption_cards_curs%ROWTYPE;
    --
    CURSOR prior_queue_call_trans_curs(c_n_site_part_objid table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT xct.x_action_type call_trans_action_type
        FROM table_x_call_trans xct
       WHERE xct.objid = (SELECT MAX(xct_max.objid)
                            FROM table_x_call_trans xct_max
                           WHERE xct_max.call_trans2site_part = c_n_site_part_objid
                             AND xct_max.x_action_type IN ('1'
                                                          ,'3'
                                                          ,'6')
                             AND xct_max.x_result = 'Completed'
                             AND xct_max.x_transact_date = (SELECT MAX(xct_max_xact.x_transact_date)
                                                              FROM table_x_call_trans xct_max_xact
                                                             WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                                               AND xct_max_xact.x_action_type IN ('1'
                                                                                                 ,'3'
                                                                                                 ,'6')
                                                               AND xct_max_xact.x_result = 'Completed'
                                                               AND xct_max_xact.x_transact_date < (SELECT MAX(xct_last_xact.x_transact_date)
                                                                                                     FROM table_x_call_trans xct_last_xact
                                                                                                    WHERE xct_last_xact.call_trans2site_part = c_n_site_part_objid
                                                                                                      AND xct_last_xact.x_action_type = '401'
                                                                                                      AND xct_last_xact.x_result = 'Completed')));
    --
    prior_queue_call_trans_rec prior_queue_call_trans_curs%ROWTYPE;
    --
    CURSOR prior_call_trans_curs
    (
      c_n_site_part_objid table_x_call_trans.call_trans2site_part%TYPE
     ,c_v_esn             table_x_call_trans.x_service_id%TYPE
     ,c_v_min             table_x_call_trans.x_min%TYPE
    ) IS
      SELECT xct.objid call_trans_objid
            ,xct.x_action_type call_trans_action_type
            ,xct.x_result call_trans_result
            ,xct.x_reason call_reason
            ,tsp.objid site_part_objid
            ,NVL(tsp.x_expire_dt
                ,TO_DATE('01/01/1753'
                        ,'MM/DD/YYYY')) site_part_expire_date
        FROM table_x_call_trans xct
        JOIN table_site_part tsp
          ON xct.call_trans2site_part = tsp.objid
       WHERE xct.objid = (SELECT MAX(xct_max.objid)
                            FROM table_x_call_trans xct_max
                           WHERE xct_max.x_service_id = c_v_esn
                             AND xct_max.x_min = c_v_min
                             AND xct_max.x_result = 'Completed'
                             AND xct_max.x_transact_date = (SELECT MAX(xct_max_xact.x_transact_date)
                                                              FROM table_x_call_trans xct_max_xact
                                                             WHERE xct_max_xact.x_service_id = c_v_esn
                                                               AND xct_max_xact.x_min = c_v_min
                                                               AND xct_max_xact.x_result = 'Completed'
                                                               AND xct_max_xact.x_transact_date < (SELECT MAX(xct_last_xact.x_transact_date)
                                                                                                     FROM table_x_call_trans xct_last_xact
                                                                                                    WHERE xct_last_xact.call_trans2site_part = c_n_site_part_objid
                                                                                                      AND xct_last_xact.x_result = 'Completed')));
    --
    prior_call_trans_rec prior_call_trans_curs%ROWTYPE;
    --
    CURSOR last_valid_new_due_date_curs(c_n_site_part_objid table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT xct.x_new_due_date call_trans_new_due_date
        FROM table_x_call_trans xct
       WHERE xct.objid = (SELECT MAX(xct_max.objid)
                            FROM table_x_call_trans xct_max
                           WHERE xct_max.call_trans2site_part = c_n_site_part_objid
                             AND NVL(xct_max.x_new_due_date
                                    ,TO_DATE('01/01/1753'
                                            ,'MM/DD/YYYY')) > TO_DATE('01/01/1753'
                                                                     ,'MM/DD/YYYY')
                             AND xct_max.x_result = 'Completed'
                             AND xct_max.x_transact_date = (SELECT MAX(xct_max_xact.x_transact_date)
                                                              FROM table_x_call_trans xct_max_xact
                                                             WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                                               AND NVL(xct_max_xact.x_new_due_date
                                                                      ,TO_DATE('01/01/1753'
                                                                              ,'MM/DD/YYYY')) > TO_DATE('01/01/1753'
                                                                                                       ,'MM/DD/YYYY')
                                                               AND xct_max_xact.x_result = 'Completed'));
    --
    last_valid_new_due_date_rec last_valid_new_due_date_curs%ROWTYPE;
    --
    CURSOR service_plan_curs(c_n_site_part_objid x_service_plan_site_part.table_site_part_id%TYPE) IS
      SELECT 1 service_plan
        FROM x_service_plan_site_part psp
       WHERE psp.table_site_part_id = c_n_site_part_objid
         AND ROWNUM <= 1;
    --
    service_plan_rec service_plan_curs%ROWTYPE;
    --
    CURSOR redeemed_card_days_curs(c_n_call_trans_objid table_x_call_trans.objid%TYPE) IS
      SELECT xrc.x_red_date redeemed_card_days
        FROM table_x_red_card xrc
       WHERE xrc.red_card2call_trans = c_n_call_trans_objid
         AND xrc.x_result = 'Completed';
    --
    redeemed_card_days_rec redeemed_card_days_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := 'service_deactivation_code.fix_esn_1753_due_dates';
    l_b_updated_site_part BOOLEAN;
    l_i_error_code        PLS_INTEGER := 0;
    l_v_error_message     VARCHAR2(32767) := 'SUCCESS';
    l_v_position          VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note              VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn   : ' || NVL(p_esn
                                              ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get ESN Active site parts with null or 1/1/1753 due dates';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF esn_site_parts_curs%ISOPEN THEN
      --
      CLOSE esn_site_parts_curs;
      --
    END IF;
    --
    OPEN esn_site_parts_curs(c_v_esn => p_esn);
    --
    LOOP
      --
      FETCH esn_site_parts_curs
        INTO esn_site_parts_rec;
      --
      EXIT WHEN esn_site_parts_curs%NOTFOUND;
      --
      l_b_updated_site_part := FALSE;
      --
      l_v_position := l_cv_subprogram_name || '.3';
      l_v_note     := 'Get site part last call trans record';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF last_call_trans_curs%ISOPEN THEN
        --
        CLOSE last_call_trans_curs;
        --
      END IF;
      --
      OPEN last_call_trans_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid);
      FETCH last_call_trans_curs
        INTO last_call_trans_rec;
      CLOSE last_call_trans_curs;
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'Evaluate site part last call trans record';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      -- If there is no call trans record and if there is no call trans for ESN/MIN combination then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TABLE_SITE_PART.WARRANTY_DATE (if valid) else SYSDATE
      --   b. From Paula?s analysis scenario ID# 0
      -- or
      -- If there is no call trans record and for ESN/MIN combination the last call trans record is a `DEACTIVATION? (action type `2?) then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TABLE_SITE_PART.WARRANTY_DATE (if valid) else SYSDATE
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        IF (last_call_trans_rec.call_trans_objid IS NULL) THEN
          --
          l_v_position := l_cv_subprogram_name || '.5';
          l_v_note     := 'No call trans records; check if ESN/MIN has call trans records';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF last_other_call_trans_curs%ISOPEN THEN
            --
            CLOSE last_other_call_trans_curs;
            --
          END IF;
          --
          OPEN last_other_call_trans_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid
                                         ,c_v_esn             => esn_site_parts_rec.site_part_esn
                                         ,c_v_min             => esn_site_parts_rec.site_part_min);
          FETCH last_other_call_trans_curs
            INTO last_other_call_trans_rec;
          CLOSE last_other_call_trans_curs;
          --
          l_v_position := l_cv_subprogram_name || '.6';
          l_v_note     := 'Check if no other call trans record or last other call trans record is deactivation';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF (last_other_call_trans_rec.call_trans_objid IS NULL) THEN
            --
            l_v_position := l_cv_subprogram_name || '.7';
            l_v_note     := 'No other call trans record; set expire date to warranty date or sysdate';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            UPDATE table_site_part
               SET x_expire_dt = CASE
                                   WHEN esn_site_parts_rec.site_part_warranty_date > TO_DATE('01/01/1753'
                                                                                            ,'MM/DD/YYYY') THEN
                                    esn_site_parts_rec.site_part_warranty_date
                                   ELSE
                                    TRUNC(SYSDATE)
                                 END
             WHERE objid = esn_site_parts_rec.site_part_objid;
            --
            l_b_updated_site_part := TRUE;
            --
          ELSIF (last_other_call_trans_rec.call_trans_action_type = '2' AND last_other_call_trans_rec.call_trans_result = 'Completed') THEN
            --
            l_v_position := l_cv_subprogram_name || '.8';
            l_v_note     := 'Last other call trans record is a deactivation; set expire date to warranty date or sysdate';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            UPDATE table_site_part
               SET x_expire_dt = CASE
                                   WHEN esn_site_parts_rec.site_part_warranty_date > TO_DATE('01/01/1753'
                                                                                            ,'MM/DD/YYYY') THEN
                                    esn_site_parts_rec.site_part_warranty_date
                                   ELSE
                                    TRUNC(SYSDATE)
                                 END
             WHERE objid = esn_site_parts_rec.site_part_objid;
            --
            l_b_updated_site_part := TRUE;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      -- If there is no valid X_NEW_DUE_DATE from a call trans record, for the ESN/MIN combination there is an `Active? site part with a valid TABLE_SITE_PART.X_EXPIRE_DT and the ?other? site part has a call trans record after the last site part call trans record then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TRUNC(SYSDATE)
      --   b. From Paula?s analysis scenario ID# 1
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        l_v_position := l_cv_subprogram_name || '.9';
        l_v_note     := 'Get last valid new due date';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF last_valid_new_due_date_curs%ISOPEN THEN
          --
          CLOSE last_valid_new_due_date_curs;
          --
        END IF;
        --
        OPEN last_valid_new_due_date_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid);
        FETCH last_valid_new_due_date_curs
          INTO last_valid_new_due_date_rec;
        CLOSE last_valid_new_due_date_curs;
        --
        l_v_position := l_cv_subprogram_name || '.10';
        l_v_note     := 'Is there last valid new due date';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF (last_valid_new_due_date_rec.call_trans_new_due_date IS NULL) THEN
          --
          l_v_position := l_cv_subprogram_name || '.11';
          l_v_note     := 'No there last valid new due date; get other active site part';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF other_actve_site_part_curs%ISOPEN THEN
            --
            CLOSE other_actve_site_part_curs;
            --
          END IF;
          --
          OPEN other_actve_site_part_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid
                                         ,c_v_esn             => esn_site_parts_rec.site_part_esn
                                         ,c_v_min             => esn_site_parts_rec.site_part_min);
          FETCH other_actve_site_part_curs
            INTO other_actve_site_part_rec;
          CLOSE other_actve_site_part_curs;
          --
          l_v_position := l_cv_subprogram_name || '.12';
          l_v_note     := 'Is there other active site part with call trans record after site part call trans record';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF (other_actve_site_part_rec.other_site_part IS NOT NULL AND other_actve_site_part_rec.max_call_trans_transact_date > last_call_trans_rec.call_trans_transact_date) THEN
            --
            UPDATE table_site_part
               SET x_expire_dt = TRUNC(SYSDATE)
             WHERE objid = esn_site_parts_rec.site_part_objid;
            --
            l_b_updated_site_part := TRUE;
            --
          END IF;
        END IF;
        --
      END IF;
      --
      -- If the last call trans record is a `DEACTIVATION? (action type `2?) call trans record then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = {to call trans record deactivation date}
      --   b. From Paula?s analysis scenario ID# 2
      --
      IF (last_call_trans_rec.call_trans_action_type = '2' AND last_call_trans_rec.call_trans_result = 'Completed') THEN
        --
        l_v_position := l_cv_subprogram_name || '.13';
        l_v_note     := 'Last call trans record is a deactivation; set expire date to deactivation date';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        UPDATE table_site_part
           SET x_expire_dt = TRUNC(last_call_trans_rec.call_trans_transact_date)
         WHERE objid = esn_site_parts_rec.site_part_objid;
        --
        l_b_updated_site_part := TRUE;
        --
      END IF;
      --
      --  If the last call trans record is a `QUEUED? (action type `401?) call trans record and there is no redemption between the last `ACTIVATION? (action type `1?) or `REACTIVATION? (action type `3?)  call trans record and the `QUEUED? (action type `401?) call trans record then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TABLE_SITE_PART.INSTALL_DATE + 30
      --   b. From Paula?s analysis scenario ID# 5
      -- or
      -- If the last call trans record is a `QUEUED? (action type `401?) call trans record and there is a redemption between the last `ACTIVATION? (action type `1?) or `REACTIVATION? (action type `3?)  call trans record and the `QUEUED? (action type `401?) call trans record then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TABLE_SITE_PART.INSTALL_DATE + redeemed card days +30
      --   b. From Paula?s analysis scenario ID# 5
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        IF (last_call_trans_rec.call_trans_action_type = '401' AND last_call_trans_rec.call_trans_result = 'Completed') THEN
          --
          l_v_position := l_cv_subprogram_name || '.14';
          l_v_note     := 'Last call trans record is queued; get prior call trans prior to the queue call trans';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF prior_queue_call_trans_curs%ISOPEN THEN
            --
            CLOSE prior_queue_call_trans_curs;
            --
          END IF;
          --
          OPEN prior_queue_call_trans_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid);
          FETCH prior_queue_call_trans_curs
            INTO prior_queue_call_trans_rec;
          CLOSE prior_queue_call_trans_curs;
          --
          IF (prior_queue_call_trans_rec.call_trans_action_type IN ('1'
                                                                   ,'3')) THEN
            --
            l_v_position := l_cv_subprogram_name || '.15';
            l_v_note     := 'Prior call trans is activation or reactivation; set expire date to install date plus 30';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            UPDATE table_site_part
               SET x_expire_dt = esn_site_parts_rec.site_part_install_date + 30
             WHERE objid = esn_site_parts_rec.site_part_objid;
            --
            l_b_updated_site_part := TRUE;
            --
          ELSE
            --
            l_v_position := l_cv_subprogram_name || '.16';
            l_v_note     := 'Prior call trans is redemption; set expire date to install date plus number of queued cards times 30';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF redemption_cards_curs%ISOPEN THEN
              --
              CLOSE redemption_cards_curs;
              --
            END IF;
            --
            OPEN redemption_cards_curs(c_v_esn => esn_site_parts_rec.site_part_esn);
            FETCH redemption_cards_curs
              INTO redemption_cards_rec;
            CLOSE redemption_cards_curs;
            --
            UPDATE table_site_part
               SET x_expire_dt = esn_site_parts_rec.site_part_install_date + (NVL(redemption_cards_rec.number_of_red_cards
                                                                                 ,0) + 1 * 30)
             WHERE objid = esn_site_parts_rec.site_part_objid;
            --
            l_b_updated_site_part := TRUE;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      -- If the last `ACTIVATION? (action type `1?), `REACTIVATION? (action type `3?), or `REDEMPTION? (action type `6?) call trans record but X_NEW_DUE_DATE not valid,
      --  and prior call trans is deactivation and reason not in PASTDUE or SENDCARRDEACT
      --  and prior site part expire date is greater than site part install date  then
      --   a.  TABLE_SITE_PART.X_EXPIRE_DT = Prior TABLE_SITE_PART.X_EXPIRE_DT
      --   b.  From Paula?s analysis scenario ID# 6
      -- OR
      -- If the last `ACTIVATION? (action type `1?), `REACTIVATION? (action type `3?), or `REDEMPTION? (action type `6?) call trans record but X_NEW_DUE_DATE not valid,
      --  and prior call trans is deactivation and reason in PASTDUE or SENDCARRDEACT then
      --   a.  TABLE_SITE_PART.X_EXPIRE_DT = Prior TABLE_SITE_PART.INSTALLED_DATE
      --   b.  From Paula?s analysis scenario ID# 7
      -- OR
      -- If the last `ACTIVATION? (action type `1?), `REACTIVATION? (action type `3?), or `REDEMPTION? (action type `6?) call trans record but X_NEW_DUE_DATE not valid,
      --  and no prior call trans record then
      --   a.  TABLE_SITE_PART.X_EXPIRE_DT = Prior TABLE_SITE_PART.INSTALLED_DATE
      --   b.  From Paula?s analysis scenario ID# 7
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        IF (last_call_trans_rec.call_trans_action_type IN ('1'
                                                          ,'3'
                                                          ,'6') AND last_call_trans_rec.call_trans_new_due_date = TO_DATE('01/01/1753'
                                                                                                                          ,'MM/DD/YYYY') AND last_call_trans_rec.call_trans_result = 'Completed') THEN
          --
          l_v_position := l_cv_subprogram_name || '.17';
          l_v_note     := 'Last call trans record is an activation, reactivation or redemption and the new due date is not valid; get redeemed card';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF redeemed_card_days_curs%ISOPEN THEN
            --
            CLOSE redeemed_card_days_curs;
            --
          END IF;
          --
          OPEN redeemed_card_days_curs(c_n_call_trans_objid => last_call_trans_rec.call_trans_objid);
          FETCH redeemed_card_days_curs
            INTO redeemed_card_days_rec;
          CLOSE redeemed_card_days_curs;
          --
          l_v_position := l_cv_subprogram_name || '.18';
          l_v_note     := 'Are there are redeemed cards';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF (redeemed_card_days_rec.redeemed_card_days IS NULL) THEN
            --
            l_v_position := l_cv_subprogram_name || '.19';
            l_v_note     := 'No there are redeemed cards; get prior call trans';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF prior_call_trans_curs%ISOPEN THEN
              --
              CLOSE prior_call_trans_curs;
              --
            END IF;
            --
            OPEN prior_call_trans_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid
                                      ,c_v_esn             => esn_site_parts_rec.site_part_esn
                                      ,c_v_min             => esn_site_parts_rec.site_part_min);
            FETCH prior_call_trans_curs
              INTO prior_call_trans_rec;
            CLOSE prior_call_trans_curs;
            --
            l_v_position := l_cv_subprogram_name || '.20';
            l_v_note     := 'Is prior call trans deactivation';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF (prior_call_trans_rec.call_trans_action_type = '2' AND prior_call_trans_rec.call_trans_result = 'Completed') THEN
              --
              l_v_position := l_cv_subprogram_name || '.20';
              l_v_note     := 'Yes prior call trans deactivation';
              --
              IF l_b_debug THEN
                --
                dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                                ,' MM/DD/YYYY HH:MI:SS AM'));
                --
              END IF;
              --
              IF (prior_call_trans_rec.call_reason NOT IN ('PASTDUE'
                                                          ,'SENDCARRDEACT') AND prior_call_trans_rec.site_part_expire_date > esn_site_parts_rec.site_part_install_date) THEN
                --
                l_v_position := l_cv_subprogram_name || '.21';
                l_v_note     := 'Not past due or send carr deact and prior site part expire date is greater than site part install date; set expire date to prior expire date';
                --
                IF l_b_debug THEN
                  --
                  dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                                  ,' MM/DD/YYYY HH:MI:SS AM'));
                  --
                END IF;
                --
                UPDATE table_site_part
                   SET x_expire_dt = prior_call_trans_rec.site_part_expire_date
                 WHERE objid = esn_site_parts_rec.site_part_objid;
                --
                l_b_updated_site_part := TRUE;
                --
              ELSIF (prior_call_trans_rec.call_reason IN ('PASTDUE'
                                                         ,'SENDCARRDEACT') OR (last_call_trans_rec.call_trans_action_type = '3' AND prior_call_trans_rec.call_trans_objid IS NULL)) THEN
                --
                l_v_position := l_cv_subprogram_name || '.22';
                l_v_note     := 'past due or send carr deact or no prior call trans; set expire date to install date';
                --
                IF l_b_debug THEN
                  --
                  dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                                  ,' MM/DD/YYYY HH:MI:SS AM'));
                  --
                END IF;
                --
                UPDATE table_site_part
                   SET x_expire_dt = esn_site_parts_rec.site_part_install_date
                 WHERE objid = esn_site_parts_rec.site_part_objid;
                --
                l_b_updated_site_part := TRUE;
                --
              END IF;
              --
            END IF;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      -- If the last `REDEMPTION? (action type `6?) call trans record but X_NEW_DUE_DATE not valid,
      --  and prior call trans is reactivation and proir site part is not equal to site part
      --  and prior site part expire date is valid  then
      --   a.  TABLE_SITE_PART.X_EXPIRE_DT = Prior TABLE_SITE_PART.X_EXPIRE_DT
      --   b.  From Paula?s analysis scenario ID# 8
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        IF (last_call_trans_rec.call_trans_action_type = '6' AND last_call_trans_rec.call_trans_new_due_date = TO_DATE('01/01/1753'
                                                                                                                      ,'MM/DD/YYYY') AND last_call_trans_rec.call_trans_result = 'Completed') THEN
          --
          l_v_position := l_cv_subprogram_name || '.23';
          l_v_note     := 'Last call trans record is redemption and the new due date is not valid; get redeemed card';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF redeemed_card_days_curs%ISOPEN THEN
            --
            CLOSE redeemed_card_days_curs;
            --
          END IF;
          --
          OPEN redeemed_card_days_curs(c_n_call_trans_objid => last_call_trans_rec.call_trans_objid);
          FETCH redeemed_card_days_curs
            INTO redeemed_card_days_rec;
          CLOSE redeemed_card_days_curs;
          --
          IF (redeemed_card_days_rec.redeemed_card_days IS NULL) THEN
            --
            l_v_position := l_cv_subprogram_name || '.24';
            l_v_note     := 'Get prior call trans';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF prior_call_trans_curs%ISOPEN THEN
              --
              CLOSE prior_call_trans_curs;
              --
            END IF;
            --
            OPEN prior_call_trans_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid
                                      ,c_v_esn             => esn_site_parts_rec.site_part_esn
                                      ,c_v_min             => esn_site_parts_rec.site_part_min);
            FETCH prior_call_trans_curs
              INTO prior_call_trans_rec;
            CLOSE prior_call_trans_curs;
            --
            l_v_position := l_cv_subprogram_name || '.24';
            l_v_note     := 'Is prior call trans reactivation and prior site part not site part and prior site part expire date is valid';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF (prior_call_trans_rec.call_trans_action_type = '3' AND prior_call_trans_rec.call_trans_result = 'Completed' AND prior_call_trans_rec.site_part_objid <> esn_site_parts_rec.site_part_objid AND prior_call_trans_rec.site_part_expire_date > TO_DATE('01/01/1753'
                                                                                                                                                                                                                                                                  ,'MM/DD/YYYY')) THEN
              --
              l_v_position := l_cv_subprogram_name || '.25';
              l_v_note     := 'Yes prior call trans reactivation and prior site part not site part and prior site part expire date is valid; set expire date to prior site part';
              --
              IF l_b_debug THEN
                --
                dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                                ,' MM/DD/YYYY HH:MI:SS AM'));
                --
              END IF;
              --
              UPDATE table_site_part
                 SET x_expire_dt = prior_call_trans_rec.site_part_expire_date
               WHERE objid = esn_site_parts_rec.site_part_objid;
              --
              l_b_updated_site_part := TRUE;
              --
            END IF;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      --
      --  If the last `ACTIVATION? (action type `1?), `REACTIVATION? (action type `3?), or `REDEMPTION? (action type `6?) call trans record has a valid X_NEW_DUE_DATE then
      --   a.  TABLE_SITE_PART.X_EXPIRE_DT = TABLE_X_CALL_TRANS.X_NEW_DUE_DATE
      --   b.  From Paula?s analysis scenario ID# 10
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        IF (last_call_trans_rec.call_trans_action_type IN ('1'
                                                          ,'3'
                                                          ,'6') AND last_call_trans_rec.call_trans_new_due_date > TO_DATE('01/01/1753'
                                                                                                                          ,'MM/DD/YYYY') AND last_call_trans_rec.call_trans_result = 'Completed') THEN
          --
          l_v_position := l_cv_subprogram_name || '.26';
          l_v_note     := 'Last call trans record is an activation, reactivation or redemption and the new due date is valid; set expire date to new due date';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          UPDATE table_site_part
             SET x_expire_dt = last_call_trans_rec.call_trans_new_due_date
           WHERE objid = esn_site_parts_rec.site_part_objid;
          --
          l_b_updated_site_part := TRUE;
          --
        END IF;
        --
      END IF;
      --
      -- If there is completed call trans record and warranty date is valid then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TABLE_SITE_PART.WARRANTY_DATE
      --   b. From Paula?s analysis scenario ID# 11
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        l_v_position := l_cv_subprogram_name || '.27';
        l_v_note     := 'Check if has complete call trans and valid warranty date';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        IF last_completed_call_trans_curs%ISOPEN THEN
          --
          CLOSE last_completed_call_trans_curs;
          --
        END IF;
        --
        OPEN last_completed_call_trans_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid);
        FETCH last_completed_call_trans_curs
          INTO last_completed_call_trans_rec;
        CLOSE last_completed_call_trans_curs;
        --
        IF (last_completed_call_trans_rec.call_trans_objid IS NOT NULL AND esn_site_parts_rec.site_part_warranty_date > TO_DATE('01/01/1753'
                                                                                                                               ,'MM/DD/YYYY')) THEN
          --
          l_v_position := l_cv_subprogram_name || '.28';
          l_v_note     := 'Yes has complete call trans and valid warranty date; update to warranty date';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          UPDATE table_site_part
             SET x_expire_dt = esn_site_parts_rec.site_part_warranty_date
           WHERE objid = esn_site_parts_rec.site_part_objid;
          --
          l_b_updated_site_part := TRUE;
          --
        END IF;
        --
      END IF;
      --
      -- If the ESN is a Straight Talk ESN with an `ACTIVATION? (action type `1?) call trans record but with no valid new due date then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TABLE_X_CALL_TRANS.X_TRANSACT_DATE + 30
      --   b. From Paula?s analysis scenario ID# 14
      -- or
      -- If the ESN has only an `ACTIVATION? (action type `1?) call trans record but has no valid new due date, no valid warranty date and not associated with a pin or service plan then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TABLE_X_CALL_TRANS.X_TRANSACT_DATE + 2
      --   b. From Paula?s analysis scenario ID# 15
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        IF (last_call_trans_rec.call_trans_action_type = '1' AND last_call_trans_rec.call_trans_new_due_date = TO_DATE('01/01/1753'
                                                                                                                      ,'MM/DD/YYYY') AND last_call_trans_rec.call_trans_result = 'Completed') THEN
          --
          l_v_position := l_cv_subprogram_name || '.29';
          l_v_note     := 'Last call trans is activation but no valid new due date';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          --CR20451 | CR20854: Add TELCEL Brand
          --IF (esn_site_parts_rec.brand = 'STRAIGHT_TALK') THEN
          IF (esn_site_parts_rec.ORG_FLOW = '3') THEN
            --
            l_v_position := l_cv_subprogram_name || '.30';
            --l_v_note     := 'Last call trans is activation but no valid new due date and straight talk; set expire date to transact date + 30';
            l_v_note     := 'Last call trans is activation but no valid new due date and straight talk flow; set expire date to transact date + 30';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            UPDATE table_site_part
               SET x_expire_dt = TRUNC(last_call_trans_rec.call_trans_transact_date) + 30
             WHERE objid = esn_site_parts_rec.site_part_objid;
            --
            l_b_updated_site_part := TRUE;
            --
          ELSE
            --
            l_v_position := l_cv_subprogram_name || '.31';
            l_v_note     := 'Get redeemed card days';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF redeemed_card_days_curs%ISOPEN THEN
              --
              CLOSE redeemed_card_days_curs;
              --
            END IF;
            --
            OPEN redeemed_card_days_curs(c_n_call_trans_objid => last_call_trans_rec.call_trans_objid);
            FETCH redeemed_card_days_curs
              INTO redeemed_card_days_rec;
            CLOSE redeemed_card_days_curs;
            --
            IF (redeemed_card_days_rec.redeemed_card_days IS NULL) THEN
              --
              IF (esn_site_parts_rec.brand = 'TRACFONE') THEN
                --
                l_v_position := l_cv_subprogram_name || '.32';
                l_v_note     := 'Tracfone no pin; set expire date to transact date + 2';
                --
                IF l_b_debug THEN
                  --
                  dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                                  ,' MM/DD/YYYY HH:MI:SS AM'));
                  --
                END IF;
                --
                UPDATE table_site_part
                   SET x_expire_dt = TRUNC(last_call_trans_rec.call_trans_transact_date) + 2
                 WHERE objid = esn_site_parts_rec.site_part_objid;
                --
                l_b_updated_site_part := TRUE;
                --
              ELSE
                --
                IF service_plan_curs%ISOPEN THEN
                  --
                  CLOSE service_plan_curs;
                  --
                END IF;
                --
                OPEN service_plan_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid);
                FETCH service_plan_curs
                  INTO service_plan_rec;
                CLOSE service_plan_curs;
                --
                IF (service_plan_rec.service_plan IS NULL) THEN
                  --
                  l_v_position := l_cv_subprogram_name || '.33';
                  l_v_note     := 'Net10 no pin and no service pin; set expire date to transact date + 2';
                  --
                  IF l_b_debug THEN
                    --
                    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
                    --
                  END IF;
                  --
                  UPDATE table_site_part
                     SET x_expire_dt = TRUNC(last_call_trans_rec.call_trans_transact_date) + 2
                   WHERE objid = esn_site_parts_rec.site_part_objid;
                  --
                  l_b_updated_site_part := TRUE;
                  --
                END IF;
                --
              END IF;
              --
            END IF;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      -- If all call trans records are `Failed?, if there is no call trans for ESN/MIN combination or the last other call trans is 'deactivation'  then
      --   a. TABLE_SITE_PART.X_EXPIRE_DT = TABLE_SITE_PART.WARRANTY_DATE (if valid) else SYSDATE
      --
      IF (NOT l_b_updated_site_part) THEN
        --
        IF (last_call_trans_rec.call_trans_result = 'Failed') THEN
          --
          l_v_position := l_cv_subprogram_name || '.34';
          l_v_note     := 'Last call trans record failed; check last completed call trans record';
          --
          IF l_b_debug THEN
            --
            dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                            ,' MM/DD/YYYY HH:MI:SS AM'));
            --
          END IF;
          --
          IF last_completed_call_trans_curs%ISOPEN THEN
            --
            CLOSE last_completed_call_trans_curs;
            --
          END IF;
          --
          OPEN last_completed_call_trans_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid);
          FETCH last_completed_call_trans_curs
            INTO last_completed_call_trans_rec;
          CLOSE last_completed_call_trans_curs;
          --
          IF (last_completed_call_trans_rec.call_trans_objid IS NULL) THEN
            --
            l_v_position := l_cv_subprogram_name || '.35';
            l_v_note     := 'No completed call trans record; get last other call trans record';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF last_other_call_trans_curs%ISOPEN THEN
              --
              CLOSE last_other_call_trans_curs;
              --
            END IF;
            --
            OPEN last_other_call_trans_curs(c_n_site_part_objid => esn_site_parts_rec.site_part_objid
                                           ,c_v_esn             => esn_site_parts_rec.site_part_esn
                                           ,c_v_min             => esn_site_parts_rec.site_part_min);
            FETCH last_other_call_trans_curs
              INTO last_other_call_trans_rec;
            CLOSE last_other_call_trans_curs;
            --
            l_v_position := l_cv_subprogram_name || '.36';
            l_v_note     := 'Check if no other call trans record or last other call trans record is deactivation';
            --
            IF l_b_debug THEN
              --
              dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                              ,' MM/DD/YYYY HH:MI:SS AM'));
              --
            END IF;
            --
            IF ((last_other_call_trans_rec.call_trans_objid IS NULL OR (last_other_call_trans_rec.call_trans_action_type = '2' AND last_other_call_trans_rec.call_trans_result = 'Completed')) AND other_actve_site_part_rec.other_site_part IS NULL) THEN
              --
              l_v_position := l_cv_subprogram_name || '.37';
              l_v_note     := 'No other call trans record; Set expire date to warranty date or sysdate';
              --
              IF l_b_debug THEN
                --
                dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                                ,' MM/DD/YYYY HH:MI:SS AM'));
                --
              END IF;
              --
              UPDATE table_site_part
                 SET x_expire_dt = CASE
                                     WHEN esn_site_parts_rec.site_part_warranty_date > TO_DATE('01/01/1753'
                                                                                              ,'MM/DD/YYYY') THEN
                                      esn_site_parts_rec.site_part_warranty_date
                                     ELSE
                                      TRUNC(SYSDATE)
                                   END
               WHERE objid = esn_site_parts_rec.site_part_objid;
              --
              l_b_updated_site_part := TRUE;
              --
            ELSIF (last_other_call_trans_rec.call_trans_action_type = '2' AND last_other_call_trans_rec.call_trans_result = 'Completed') THEN
              --
              l_v_position := l_cv_subprogram_name || '.38';
              l_v_note     := 'Last other call trans record is deactivation; Set expire date to warranty date or sysdate';
              --
              IF l_b_debug THEN
                --
                dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                                ,' MM/DD/YYYY HH:MI:SS AM'));
                --
              END IF;
              --
              UPDATE table_site_part
                 SET x_expire_dt = CASE
                                     WHEN esn_site_parts_rec.site_part_warranty_date > TO_DATE('01/01/1753'
                                                                                              ,'MM/DD/YYYY') THEN
                                      esn_site_parts_rec.site_part_warranty_date
                                     ELSE
                                      TRUNC(SYSDATE)
                                   END
               WHERE objid = esn_site_parts_rec.site_part_objid;
              --
              l_b_updated_site_part := TRUE;
              --
            END IF;
            --
          END IF;
          --
        END IF;
        --
      END IF;
      --
      COMMIT;
      --
    END LOOP;
    --
    CLOSE esn_site_parts_curs;
    --
    l_v_position := l_cv_subprogram_name || '.39';
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
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.40';
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
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END fix_esn_1753_due_dates;
  --********************************************************************************
  -- Procedure to site part with due dates of 1/1/1753
  --********************************************************************************
  --
  PROCEDURE fix_1753_due_dates
  (
    p_bus_org_id    IN table_bus_org.org_id%TYPE DEFAULT NULL
   ,p_mod_divisor   IN NUMBER DEFAULT 1
   ,p_mod_remainder IN NUMBER DEFAULT 0
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --
    CURSOR site_parts_1753_due_date_curs
    (
      c_v_bus_org_id    table_bus_org.org_id%TYPE
     ,c_n_mod_divisor   NUMBER DEFAULT 1
     ,c_n_mod_remainder NUMBER DEFAULT 0
    ) IS
      SELECT /*+ ORDERED INDEX(tsp sp_status_exp_dt_idx)*/
      DISTINCT tsp.x_service_id site_part_esn
        FROM table_site_part tsp
        JOIN table_part_inst tpi_esn
          ON tsp.x_service_id = tpi_esn.part_serial_no
        JOIN table_mod_level tml
          ON tpi_esn.n_part_inst2part_mod = tml.objid
        JOIN table_part_num tpn
          ON tml.part_info2part_num = tpn.objid
        JOIN table_bus_org tbo
          ON tpn.part_num2bus_org = tbo.objid
       WHERE 1 = 1
         AND NVL(tsp.part_status
                ,'Obsolete') = 'Active'
         AND NVL(tsp.x_expire_dt
                ,TO_DATE('01/01/1753'
                        ,'MM/DD/YYYY')) = TO_DATE('01/01/1753'
                                                 ,'MM/DD/YYYY')
         AND MOD(tsp.objid
                ,NVL(c_n_mod_divisor
                    ,1)) = NVL(c_n_mod_remainder
                              ,0)
         AND tpi_esn.x_domain = 'PHONES'
         AND tbo.org_id = NVL(c_v_bus_org_id
                             ,tbo.org_id);
    --
    site_parts_1753_due_date_rec site_parts_1753_due_date_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := 'service_deactivation_code.fix_1753_due_dates';
    l_exc_business_failure EXCEPTION;
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
      dbms_output.put_line('p_bus_org_id   : ' || NVL(p_bus_org_id
                                                     ,'Value is null'));
      dbms_output.put_line('p_mod_divisor  : ' || NVL(TO_CHAR(p_mod_divisor)
                                                     ,'Value is null'));
      dbms_output.put_line('p_mod_remainder: ' || NVL(TO_CHAR(p_mod_remainder)
                                                     ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get Active site parts with null or 1/1/1753 due dates';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF site_parts_1753_due_date_curs%ISOPEN THEN
      --
      CLOSE site_parts_1753_due_date_curs;
      --
    END IF;
    --
    OPEN site_parts_1753_due_date_curs(c_v_bus_org_id    => p_bus_org_id
                                      ,c_n_mod_divisor   => p_mod_divisor
                                      ,c_n_mod_remainder => p_mod_remainder);
    --
    LOOP
      --
      FETCH site_parts_1753_due_date_curs
        INTO site_parts_1753_due_date_rec;
      --
      EXIT WHEN site_parts_1753_due_date_curs%NOTFOUND;
      --
      BEGIN
        --
        l_v_position := l_cv_subprogram_name || '.3';
        l_v_note     := 'Calling fix_esn_1753_due_dates for ESN';
        --
        IF l_b_debug THEN
          --
          dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                          ,' MM/DD/YYYY HH:MI:SS AM'));
          --
        END IF;
        --
        l_i_error_code := 0;
        --
        fix_esn_1753_due_dates(p_esn           => site_parts_1753_due_date_rec.site_part_esn
                              ,p_error_code    => l_i_error_code
                              ,p_error_message => l_v_error_message);
        --
        IF (l_i_error_code <> 0) THEN
          --
          RAISE l_exc_business_failure;
          --
        END IF;
      EXCEPTION
        WHEN l_exc_business_failure THEN
          --
          ota_util_pkg.err_log(p_action       => l_v_note
                              ,p_error_date   => SYSDATE
                              ,p_key          => site_parts_1753_due_date_rec.site_part_esn
                              ,p_program_name => l_v_position
                              ,p_error_text   => p_error_message);
          --
          l_i_error_code := 0;
          --
        WHEN others THEN
          --
          RAISE;
          --
      END;
      --
    END LOOP;
    --
    CLOSE site_parts_1753_due_date_curs;
    --
    l_v_position := l_cv_subprogram_name || '.4';
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
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_bus_org_id
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
      l_v_position := l_cv_subprogram_name || '.5';
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
  END fix_1753_due_dates;
  --CR21179 End Kacosta 06/20/2012
--
END bau_maintenance_pkg;
/