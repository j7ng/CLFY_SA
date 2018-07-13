CREATE OR REPLACE FUNCTION sa."TAX_RULES_FUN" ( P_esn IN VARCHAR2)
     RETURN VARCHAR2
     IS

--------------------------------------------------------------------------------------------
--$RCSfile: TAX_RULES_FUN.sql,v $
--$Revision: 1.2 $
--$Author: icanavan $
--$Date: 2014/04/09 20:13:01 $
--$ $Log: TAX_RULES_FUN.sql,v $
--$ Revision 1.2  2014/04/09 20:13:01  icanavan
--$ change default value of tax specifications variable to 3
--$
--$ Revision 1.1  2014/04/03 21:28:44  vtummalpally
--$ TO CALCULATE TAXES BASED ON THE MODEL
--$
--$ Revision 1.1  2014/04/03 17:21:48  ICANAVAN
--$ CR27269 TO CALCULATE TAXES BASED ON THE MODEL
--$
--------------------------------------------------------------------------------------------
    --X_HOME_ALERT_NON_SALES  NOT NULL NUMBER
    --X_DATA_NON_SALES        NOT NULL NUMBER
    --X_NON_SHIPPING          NOT NULL NUMBER
    --X_CAR_CONNECT_NON_SALES NOT NULL NUMBER

    CURSOR c1
    IS
      SELECT pc.name
      FROM table_part_class pc,
           table_part_num pn,
           table_mod_level ml,
           table_part_inst pi
      WHERE pi.n_part_inst2part_mod = ml.objid
      AND ml.part_info2part_num     = pn.objid
      AND pn.part_num2part_class    = pc.objid
      AND pi.part_serial_no         = P_esn; --'100000000013246789' ;

    r1 c1%ROWTYPE;

    CURSOR c2
    IS
      SELECT tax.x_zipcode,
             x_home_alert_non_sales,
             x_car_connect_non_sales
      FROM   x_program_enrolled pe,
             table_web_user wu,
             table_contact c,
             table_x_sales_tax tax
      WHERE pe.pgm_enroll2web_user = wu.objid
      AND wu.web_user2contact      = c.objid
      AND c.zipcode                = tax.x_zipcode
      AND x_eff_dt                 < SYSDATE
      AND pe.x_esn                 = P_esn -- '100000000013246789'
      AND ROWNUM                   < 2;

    r2 c2%ROWTYPE;
    v_tax_rule           VARCHAR2 (30) DEFAULT 'NORMAL TAX';
    v_tax_specifications NUMBER DEFAULT 3;
    v_model_type         VARCHAR2 (30);
  BEGIN
    OPEN c1;
      FETCH c1 INTO r1;
    IF c1%FOUND THEN
      CLOSE c1;
      v_model_type := get_param_by_name_fun (r1.name, 'MODEL_TYPE');
    ELSE
      CLOSE c1;
      RETURN 'FULL TAX' ;
    END IF;

    OPEN c2;
     FETCH c2 INTO r2;
    IF c2%FOUND THEN
      CLOSE c2;
      IF v_model_type         = 'HOME ALERT' THEN
        v_tax_specifications := r2.x_home_alert_non_sales;
      END IF;
      IF v_model_type         = 'CAR CONNECT' THEN
        v_tax_specifications := r2.x_car_connect_non_sales;
      END IF;
    ELSE
      CLOSE c2 ;
      RETURN 'FULL TAX' ;
    END IF;
    IF v_tax_specifications    = 1 THEN
      v_tax_rule              := 'NO TAX' ;
    elsif v_tax_specifications = 0 THEN
      v_tax_rule              := 'SALES TAX ONLY' ;
    ELSE
      v_tax_rule := 'FULL TAX' ;
    END IF ;
    RETURN v_tax_rule;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END ;
/