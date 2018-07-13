CREATE OR REPLACE TRIGGER sa.trg_x_rp_ancillary_code_disc
BEFORE INSERT OR UPDATE ON sa.x_rp_ancillary_code_discount REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
--
DECLARE
--
  l_disc_array        dbms_utility.lname_array;
  l_disc_count        NUMBER :=0;
  v_tab_arrary        sa.discount_code_tab := sa.discount_code_tab();
--
BEGIN
  --
  DBMS_OUTPUT.PUT_LINE (':new.brm_equivalent --> '|| :new.brm_equivalent);
  --
  dbms_utility.comma_to_table
        ( list   => :new.brm_equivalent
        , tablen => l_disc_count
        , tab    => l_disc_array);
  DBMS_OUTPUT.PUT_LINE ('l_disc_count        --> '|| l_disc_count);
  --
  FOR idx IN 1..l_disc_array.count
  LOOP
    v_tab_arrary.extend;
    v_tab_arrary(v_tab_arrary.last) := sa.discount_code_type (l_disc_array(idx) );
  END LOOP;

  SELECT LISTAGG (c.discount_code, ',')
         WITHIN GROUP (ORDER BY c.discount_code)
  INTO  :new.brm_equivalent
  FROM TABLE(v_tab_arrary) c;
  --
  DBMS_OUTPUT.PUT_LINE (':new.brm_equivalent --> '|| :new.brm_equivalent);
  --
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
-- ANTHILL_TEST PLSQL/SA/Triggers/trg_x_rp_ancillary_code_disc.sql 	CR52120: 1.3
/