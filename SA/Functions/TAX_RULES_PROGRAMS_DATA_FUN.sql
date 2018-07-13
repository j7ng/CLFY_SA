CREATE OR REPLACE FUNCTION sa."TAX_RULES_PROGRAMS_DATA_FUN" ( P_PE_OBJID IN VARCHAR2)
RETURN VARCHAR2
IS

--------------------------------------------------------------------------------------------
--$RCSfile: TAX_RULES_PROGRAMS_DATA_FUN.SQL,v $
--$Revision: 1.2 $
--$Author: icanavan $
--$Date: 2014/04/10 16:38:50 $
--$ $Log: TAX_RULES_PROGRAMS_DATA_FUN.SQL,v $
--$ Revision 1.2  2014/04/10 16:38:50  icanavan
--$ new function
--$
--$ Revision 1.1  2014/04/03 17:21:48  ICANAVAN
--$ CR27269 TO CALCULATE TAXES BASED ON THE DATA CARD
--$
--------------------------------------------------------------------------------------------
    --X_HOME_ALERT_NON_SALES  NOT NULL NUMBER
    --X_DATA_NON_SALES        NOT NULL NUMBER
    --X_NON_SHIPPING          NOT NULL NUMBER
    --X_CAR_CONNECT_NON_SALES NOT NULL NUMBER

cursor data_tax_cur (P_PE_objid NUMBER ) is
  SELECT pn.part_number --, pp.*, e.*
    FROM  table_part_num pn, x_program_parameters pp, x_program_enrolled e
   WHERE 1=1
     AND (pn.objid = pp.prog_param2prtnum_monfee
       OR pn.objid = pp.prog_param2prtnum_enrlfee
         OR pn.objid = pp.prog_param2prtnum_grpmonfee
           OR pn.objid = pp.prog_param2prtnum_grpenrlfee)
          AND e.pgm_enroll2pgm_parameter = pp.objid
          AND (pn.x_card_type='DATA CARD')
          AND rownum < 2
          AND e.objid = P_PE_OBJID ; --41256291;  --1340665945 --

          data_TAX_REC  data_TAX_CUR%ROWTYPE ;

cursor find_data_flag_cur (P_PE_OBJID VARCHAR2) is
select tax.x_zipcode, x_data_non_sales
  from x_program_enrolled pe, table_web_user wu, table_contact c, table_x_sales_tax tax
  where pe.pgm_enroll2web_user=wu.objid
    and wu.web_user2contact = c.objid
    and c.zipcode = tax.x_zipcode
    and x_eff_dt < sysdate
    and rownum < 2
    and pe.objid = P_PE_OBJID ;

    find_data_flag_rec find_data_flag_cur%rowtype ;

    v_data_tax_rule      VARCHAR2 (30) DEFAULT 'NORMAL TAX';
    v_tax_specifications NUMBER DEFAULT 3 ;

  BEGIN
    OPEN data_tax_cur (P_PE_OBJID) ;
   FETCH data_tax_cur INTO data_tax_rec ;
    IF data_tax_cur%FOUND THEN
      CLOSE data_tax_cur;
    ELSE
      CLOSE data_tax_cur ;
      RETURN 'FULL TAX' ;
    END IF;

    OPEN find_data_flag_cur (P_PE_OBJID) ;
   FETCH find_data_flag_cur INTO find_data_flag_rec;
      IF find_data_flag_cur%FOUND THEN
          CLOSE find_data_flag_cur;
          v_tax_specifications := find_data_flag_rec.x_data_non_sales ;
    ELSE
      CLOSE find_data_flag_cur ;
      RETURN 'FULL TAX' ;
    END IF;
    IF v_tax_specifications    = 1 THEN
      v_data_tax_rule              := 'NO TAX' ;
    elsif v_tax_specifications = 0 THEN
      v_data_tax_rule              := 'SALES TAX ONLY' ;
    ELSE
      v_data_tax_rule := 'FULL TAX' ;
    END IF ;
    RETURN v_data_tax_rule;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END tax_rules_programs_data_fun;
/