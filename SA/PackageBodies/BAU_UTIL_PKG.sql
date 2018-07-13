CREATE OR REPLACE PACKAGE BODY sa."BAU_UTIL_PKG" AS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: BAU_UTIL_PKG_BODY.sql,v $
  --$Revision: 1.8 $
  --$Author: akuthadi $
  --$Date: 2013/10/24 18:52:35 $
  --$Log: BAU_UTIL_PKG_BODY.sql,v $
  --Revision 1.8  2013/10/24 18:52:35  akuthadi
  --Modified get_account_association to handle ST appropriately
  --
  --Revision 1.7  2013/10/18 21:09:51  akuthadi
  --CR24606 - Added new function get_account_association
  --
  --Revision 1.6  2013/08/22 16:21:09  akuthadi
  --new function get_pin_part_class
  --
  --Revision 1.5  2011/10/26 14:37:43  kacosta
  --CR17076 NET10 Runtime Promotion
  --
  --Revision 1.3  2011/05/27 15:02:51  kacosta
  --CR15158 Added get_esn_brand functions
  --
  --Revision 1.2  2011/04/04 15:41:05  kacosta
  --CR15687 ST Updates for My Account Access from WEB
  --
  ---------------------------------------------------------------------------------------------
  --
  -- Private Package Variables
  --
  l_cv_package_name CONSTANT VARCHAR2(30) := 'bau_util_pkg';
  --
  -- Public Functions
  --
  --********************************************************************************
  -- Function to retrieve a long column from a table
  --********************************************************************************
  --
  FUNCTION select_from_long_column
  (
    p_table_name  all_tables.table_name%TYPE
   ,p_column_name all_tab_columns.column_name%TYPE
   ,p_rowid       ROWID
  ) RETURN VARCHAR2 IS
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.get_esn_brand';
    l_i_error_code    PLS_INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_v_sql_statement VARCHAR2(32767);
    l_v_long_value    VARCHAR2(32767);
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_table_name : ' || NVL(p_table_name
                                                   ,'Value is null'));
      dbms_output.put_line('p_column_name: ' || NVL(p_column_name
                                                   ,'Value is null'));
      dbms_output.put_line('p_rowid      : ' || NVL(ROWIDTOCHAR(p_rowid)
                                                   ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Retrieve long value';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    l_v_sql_statement := 'SELECT ' || p_column_name || ' FROM ' || p_table_name || ' WHERE rowid = CHARTOROWID(''' || ROWIDTOCHAR(p_rowid) || ''')';
    --
    EXECUTE IMMEDIATE l_v_sql_statement
      INTO l_v_long_value;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Returning long value';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    RETURN l_v_long_value;
    --
  EXCEPTION
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
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
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_table_name || '.' || p_column_name
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      RAISE;
      --
  END select_from_long_column;
  --
  --********************************************************************************
  -- Function to retrieve the brand of a ESN
  -- Procedure was created for CR15158
  --********************************************************************************
  --
  FUNCTION get_esn_brand(p_esn table_part_inst.part_serial_no%TYPE) RETURN VARCHAR2 AS
    --
    CURSOR get_esn_brand_curs(c_esn table_part_inst.part_serial_no%TYPE) IS
      SELECT tbo_esn.org_id esn_brand
        FROM table_part_inst tpi_esn
        JOIN table_mod_level tml_esn
          ON tpi_esn.n_part_inst2part_mod = tml_esn.objid
        JOIN table_part_num tpn_esn
          ON tml_esn.part_info2part_num = tpn_esn.objid
        JOIN table_bus_org tbo_esn
          ON tpn_esn.part_num2bus_org = tbo_esn.objid
       WHERE tpi_esn.part_serial_no = c_esn;
    --
    get_esn_brand_rec get_esn_brand_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.get_esn_brand';
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
      dbms_output.put_line('p_esn: ' || NVL(p_esn
                                           ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Retrieve ESN brand';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    OPEN get_esn_brand_curs(c_esn => p_esn);
    FETCH get_esn_brand_curs
      INTO get_esn_brand_rec;
    CLOSE get_esn_brand_curs;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Returning ESN brand';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    RETURN get_esn_brand_rec.esn_brand;
    --
  EXCEPTION
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
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
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      RAISE;
      --
  END get_esn_brand;
  --
  --********************************************************************************
  -- Function to retrieve the brand of a ESN
  -- Procedure was created for CR15158
  --********************************************************************************
  --
  FUNCTION get_esn_brand(p_esn_objid table_part_inst.objid%TYPE) RETURN VARCHAR2 AS
    --
    CURSOR get_esn_part_serial_no_curs(c_n_esn_objid table_part_inst.objid%TYPE) IS
      SELECT tpi.part_serial_no
        FROM table_part_inst tpi
       WHERE tpi.objid = c_n_esn_objid;
    --
    get_esn_part_serial_no_rec get_esn_part_serial_no_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.get_esn_brand';
    l_i_error_code    PLS_INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_v_esn_brand     table_bus_org.org_id%TYPE;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn: ' || NVL(TO_CHAR(p_esn_objid)
                                           ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'OPEN get_esn_part_serial_no_curs';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    OPEN get_esn_part_serial_no_curs(c_n_esn_objid => p_esn_objid);
    FETCH get_esn_part_serial_no_curs
      INTO get_esn_part_serial_no_rec;
    CLOSE get_esn_part_serial_no_curs;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Calling get_esn_brand';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    l_v_esn_brand := get_esn_brand(p_esn => get_esn_part_serial_no_rec.part_serial_no);
    --
    l_v_position := l_cv_subprogram_name || '.4';
    l_v_note     := 'Returning ESN brand';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    RETURN l_v_esn_brand;
    --
  EXCEPTION
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
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
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => TO_CHAR(p_esn_objid)
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      IF get_esn_part_serial_no_curs%ISOPEN THEN
        --
        CLOSE get_esn_part_serial_no_curs;
        --
      END IF;
      --
      RAISE;
      --
  END get_esn_brand;
  --
  --********************************************************************************
  -- Function to retrieve the brand of a ESN
  -- Procedure was created for CR15158
  --********************************************************************************
  --
  FUNCTION get_esn_brand_objid(p_esn table_part_inst.part_serial_no%TYPE) RETURN table_bus_org.objid%TYPE AS
    --
    CURSOR get_esn_brand_objid_curs(c_esn table_part_inst.part_serial_no%TYPE) IS
      SELECT tbo_esn.objid esn_brand_objid
        FROM table_part_inst tpi_esn
        JOIN table_mod_level tml_esn
          ON tpi_esn.n_part_inst2part_mod = tml_esn.objid
        JOIN table_part_num tpn_esn
          ON tml_esn.part_info2part_num = tpn_esn.objid
        JOIN table_bus_org tbo_esn
          ON tpn_esn.part_num2bus_org = tbo_esn.objid
       WHERE tpi_esn.part_serial_no = c_esn;
    --
    get_esn_brand_objid_rec get_esn_brand_objid_curs%ROWTYPE;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.get_esn_brand_objid';
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
      dbms_output.put_line('p_esn: ' || NVL(p_esn
                                           ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Retrieve ESN brand objid';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    OPEN get_esn_brand_objid_curs(c_esn => p_esn);
    FETCH get_esn_brand_objid_curs
      INTO get_esn_brand_objid_rec;
    CLOSE get_esn_brand_objid_curs;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Returning ESN brand objid';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    RETURN get_esn_brand_objid_rec.esn_brand_objid;
    --
  EXCEPTION
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
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
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      RAISE;
      --
  END get_esn_brand_objid;
  --
  --********************************************************************************
  -- Function to check if a string is a number
  -- Procedure was created for CR15687
  --********************************************************************************
  --
  FUNCTION isnumber(p_char_value VARCHAR2) RETURN NUMBER AS
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.isnumber';
    l_i_error_code    PLS_INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_n_numeric_value NUMBER;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_char_value: ' || NVL(p_char_value
                                                  ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Validating if value is numeric';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    l_n_numeric_value := p_char_value;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Returning; value is numeric';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    RETURN 1;
    --
  EXCEPTION
    WHEN value_error THEN
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'Returning; value is not numeric';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      RETURN 0;
      --
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
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
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_char_value
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      RAISE;
      --
  END isnumber;
  --
  --********************************************************************************
  -- Function to encrypt password
  -- Procedure was created for CR15687
  --********************************************************************************
  --
  FUNCTION encrypt_password(p_string_to_encrypt IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'PasswordEncryption.encryptPassword (java.lang.String) return java.lang.String';
  --
  --********************************************************************************
  -- Function to decrypt password
  -- Procedure was created for CR15687
  --********************************************************************************
  --
  FUNCTION decrypt_password(p_string_to_decrypt IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'PasswordEncryption.decryptPassword (java.lang.String) return java.lang.String';
  --
  -- Public Procedures
  --
  --********************************************************************************
  -- Procedure to correct active ESN with missing contact
  -- Procedure was created for CR12842
  --********************************************************************************
  --
  PROCEDURE fix_null_active_esn_contact
  (
    p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --
    CURSOR null_active_esn_contact_curs IS
      SELECT DISTINCT tpi_esn.objid            part_inst_objid
                     ,tcr.contact_role2contact contact_objid
        FROM table_contact_role tcr
            ,table_site_part    tsp
            ,table_part_inst    tpi_esn
            ,table_x_call_trans xct
       WHERE xct.x_transact_date >= TRUNC(SYSDATE - 1)
         AND xct.x_result <> 'Completed'
         AND xct.x_service_id = tpi_esn.part_serial_no
         AND tpi_esn.x_part_inst_status = '52'
         AND tpi_esn.x_domain = 'PHONES'
         AND tpi_esn.x_part_inst2contact IS NULL
         AND tpi_esn.part_serial_no = tsp.x_service_id
         AND tsp.part_status = 'Active'
         AND tsp.site_part2site = tcr.contact_role2site;
    --
    TYPE null_active_esn_contact_rectyp IS RECORD(
       part_inst_objid table_part_inst.objid%TYPE
      ,contact_objid   table_contact_role.contact_role2contact%TYPE);
    --
    TYPE null_active_esn_contact_tab IS TABLE OF null_active_esn_contact_rectyp;
    --
    null_active_esn_contact_rec null_active_esn_contact_tab;
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.fix_null_active_esn_contact';
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
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Retrieve active ESNs without contact';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF null_active_esn_contact_curs%ISOPEN THEN
      --
      CLOSE null_active_esn_contact_curs;
      --
    END IF;
    --
    OPEN null_active_esn_contact_curs;
    --
    FETCH null_active_esn_contact_curs BULK COLLECT
      INTO null_active_esn_contact_rec;
    CLOSE null_active_esn_contact_curs;
    --
    l_v_position := l_cv_subprogram_name || '.3';
    l_v_note     := 'Update active ESNs without contact with contact';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    FORALL idx IN 1 .. null_active_esn_contact_rec.count
      UPDATE table_part_inst
         SET x_part_inst2contact = null_active_esn_contact_rec(idx).contact_objid
       WHERE objid = null_active_esn_contact_rec(idx).part_inst_objid;
    --
    COMMIT;
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
      IF null_active_esn_contact_curs%ISOPEN THEN
        --
        CLOSE null_active_esn_contact_curs;
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => NULL
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END fix_null_active_esn_contact;
  --
  FUNCTION get_pin_part_class(in_pin  IN  table_part_inst.x_red_code%TYPE) RETURN table_part_class.NAME%TYPE IS
   --
   CURSOR pi_cur IS
   SELECT pc.NAME
    FROM table_part_class pc, table_part_num pn,table_part_inst pi,
         table_mod_level ml,table_bus_org bo
   WHERE 1=1
    AND pi.x_red_code = in_pin
    AND pi.x_domain = 'REDEMPTION CARDS'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num = pn.objid
    AND pn.domain = 'REDEMPTION CARDS'
    AND pn.part_num2bus_org = bo.objid
    AND pn.part_num2part_class = pc.objid;
   --
   CURSOR rc_cur IS
   SELECT pc.NAME
    FROM table_x_red_card rc, table_mod_level ml, table_part_num pn,
         table_part_class pc, table_bus_org bo
   WHERE rc.x_red_code = in_pin
    AND pn.domain = 'REDEMPTION CARDS'
    AND ml.objid = rc.x_red_card2part_mod
    AND ml.part_info2part_num = pn.objid
    AND pc.objid = pn.part_num2part_class
    AND pn.part_num2bus_org = bo.objid;
   --
   v_pc_name  table_part_class.NAME%TYPE;
   --
  BEGIN
    IF (in_pin IS NOT NULL) THEN
      -- PRE REDEMPTION
      OPEN pi_cur;
      FETCH pi_cur INTO v_pc_name;
      CLOSE pi_cur;

      IF (v_pc_name IS NULL) THEN
        -- POST REDEMPTION
        OPEN rc_cur;
        FETCH rc_cur INTO v_pc_name;
        CLOSE rc_cur;
      END IF;
      --
    END IF;
    RETURN v_pc_name;
  END get_pin_part_class;

  -- CR#24606  - Mobile Billing Guest Checkout
  -- ASKuthadi: Currently this new API will determine if the account if DUMMY, REAL or NO account exists.
  FUNCTION get_account_association (in_web_user_objid IN NUMBER) RETURN VARCHAR2
  IS
   CURSOR cur_web_user IS
   SELECT upper(s_login_name) s_login_name
    FROM table_web_user
   WHERE objid = in_web_user_objid;
   rec_web_user  cur_web_user%rowtype;
   --
   v_account_type  VARCHAR2(25) := 'NONE';
   v_sln_no_dom    table_web_user.s_login_name%TYPE;
   --
  BEGIN
    --
    IF in_web_user_objid IS NOT NULL THEN
      --
      OPEN cur_web_user;
      FETCH cur_web_user INTO rec_web_user;
      CLOSE cur_web_user;
      --
      IF rec_web_user.s_login_name IS NOT NULL THEN
        --
        IF ((instr(rec_web_user.s_login_name, '@TELCEL') > 0) OR       -- different flavours @TELCEL.COM and @TELCELAMERICA.COM
            (instr(rec_web_user.s_login_name, '@TRACFONE') > 0) OR     -- Tracfone will not have any web user account, but adding to support legacy data
            (instr(rec_web_user.s_login_name, '@NET10.COM') > 0) OR
            (instr(rec_web_user.s_login_name, '@STRAIGHT') > 0) OR     -- different flavours based on channel, STRAIGHTTALK.COM, STRAIGHT_TALK.COM, STRAIGHTTALKWIRELESS.COM, etc.,
            (instr(rec_web_user.s_login_name, '@SIMPLEMOBILE.COM') > 0)) THEN
            --
            v_sln_no_dom := substr(rec_web_user.s_login_name, 1, instr(rec_web_user.s_login_name, '@') - 1);  -- O/P: 268435461703317902
            --
            IF REGEXP_LIKE(v_sln_no_dom, '^[0-9]+$') THEN
              v_account_type  := 'DUMMY_ACCOUNT';
            ELSE
              v_account_type  := 'REAL_ACCOUNT';
            END IF;
            --
        ELSIF REGEXP_LIKE(rec_web_user.s_login_name, '^[0-9]+$') THEN
            v_account_type  := 'DUMMY_ACCOUNT';
        ELSE
            v_account_type  := 'REAL_ACCOUNT';
        END IF;
        --
      END IF; -- s_login_name is NULL
      --
    END IF;  -- in_web_user_objid is NULL
    --
    RETURN v_account_type;
    --
  END get_account_association;

END bau_util_pkg;
/