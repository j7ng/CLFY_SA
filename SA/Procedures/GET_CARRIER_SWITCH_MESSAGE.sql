CREATE OR REPLACE PROCEDURE sa."GET_CARRIER_SWITCH_MESSAGE" (
    i_source_esn    IN VARCHAR2 ,
    i_target_esn    IN VARCHAR2 ,
    i_zipcode       IN VARCHAR2 ,
    i_sim           IN VARCHAR2 ,
    i_to_carrier_id IN VARCHAR2,
    o_warning_flag OUT VARCHAR2 ,
    op_er_cd OUT VARCHAR2,
    op_msg OUT VARCHAR2 )
IS
  n_ct customer_type := customer_type ();
  o_ct customer_type := customer_type ();
  c_warning_flag         VARCHAR2(1);
  c_repl_part            VARCHAR2(200);
  c_repl_tech            VARCHAR2(200);
  c_sim_profile          VARCHAR2(200);
  c_part_serial_no       VARCHAR2(200);
  c_msg                  VARCHAR2(200);
  v_to_short_parent_name VARCHAR2(30);
  pref_parent            VARCHAR2(100);
  pref_carrier_objid     VARCHAR2(100);
BEGIN
  -- call the retrieve method for the source esn
  o_ct := o_ct.retrieve ( i_esn => i_source_esn );
  --
  IF o_ct.short_parent_name IS NULL THEN
    op_msg                  := 'SOURCE PARENT NAME NOT FOUND';
    op_er_cd                := '1';
    o_warning_flag          := NULL;
    RETURN;
  END IF;
  --
  --New logic Vishnu Start
  IF i_to_carrier_id IS NOT NULL THEN
    BEGIN
      SELECT sa.util_pkg.get_short_parent_name(x_parent_name) short_parent_name
      INTO v_to_short_parent_name
      FROM table_x_parent p,
        table_x_carrier_group cg,
        table_x_carrier carr
      WHERE p.objid         = cg.x_carrier_group2x_parent
      AND cg.objid          = carr.carrier2carrier_group
      AND carr.x_carrier_id = i_to_carrier_id;
    EXCEPTION
    WHEN OTHERS THEN
      op_msg         := 'Short parent not found for to carrier: ' || SQLERRM;
      op_er_cd       := '-100';
      o_warning_flag := NULL;
      --RETURN;
    END;
  END IF;
  --New logic Vishnu END
  IF i_to_carrier_id IS NULL THEN
    -- call nap digital
    -- call the retrieve method for the target esn
    -- n_ct := n_ct.retrieve ( i_esn => i_target_esn );
    nap_digital ( p_zip => i_zipcode ,            -- VARCHAR2                IN
    p_esn => i_target_esn ,                       -- VARCHAR2                IN
    p_commit => 'N' ,                             -- VARCHAR2                IN     DEFAULT
    p_language => NULL ,                          -- VARCHAR2                IN     DEFAULT
    p_sim => i_sim ,                              -- VARCHAR2                IN
    p_source => 'WEB',                            -- VARCHAR2                DEFAULT
    p_upg_flag => NULL ,                          -- VARCHAR2                IN     DEFAULT
    p_repl_part => c_repl_part ,                  -- VARCHAR2                OUT
    p_repl_tech => c_repl_tech ,                  -- VARCHAR2                OUT
    p_sim_profile => c_sim_profile ,              -- VARCHAR2                OUT
    p_part_serial_no => c_part_serial_no ,        -- VARCHAR2                OUT
    p_msg => c_msg ,                              -- VARCHAR2                OUT
    p_pref_parent => pref_parent ,                -- VARCHAR2                OUT
    p_pref_carrier_objid => pref_carrier_objid ); -- VARCHAR2                OUT
    -- what will happen with different nap output responses
    -- ???
    BEGIN
      SELECT sa.util_pkg.get_short_parent_name ( i_parent_name => x_parent_name ) short_parent_name
      INTO v_to_short_parent_name
      FROM sa.table_x_parent
      WHERE x_parent_id = pref_parent ;
    EXCEPTION
    WHEN OTHERS THEN
      op_msg         := 'PARENT NOT FOUND TO ESN AT NAP LEVEL: ' || SQLERRM;
      op_er_cd       := '-100';
      o_warning_flag := NULL;
      RETURN;
    END;
  END IF;
  BEGIN
    SELECT WARNING_FLAG
    INTO o_warning_flag
    FROM sa.X_CARRIER_SWITCH_MAPPING
    WHERE SOURCE_PARENT = o_ct.short_parent_name
    AND TARGET_PARENT   = v_to_short_parent_name;
  EXCEPTION
  WHEN no_data_found THEN
    op_er_cd       := '2';
    op_msg         := 'MAPPING NOT FOUND';
    o_warning_flag := NULL;
    RETURN;
  WHEN OTHERS THEN
    op_msg         := 'MAPPING NOT FOUND: ' || SQLERRM;
    op_er_cd       := '3';
    o_warning_flag := NULL;
    RETURN;
  END;
  op_msg   := 'SUCCESS';
  op_er_cd := '0';
END;
/