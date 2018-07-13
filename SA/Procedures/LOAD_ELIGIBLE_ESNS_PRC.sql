CREATE OR REPLACE PROCEDURE sa."LOAD_ELIGIBLE_ESNS_PRC"
(
  p_group_name IN VARCHAR2
 ,p_end_date   IN DATE
) IS
  /**************************************************************************************
  * Procedure Name: load_eligible_esns_prc
  * Description : Load esns data into Group2Esn table
  * Created by : Vani Adapa
  * Date : 04/16/2004
  *
  * History
  * -------------------------------------------------------------
  * 04/16/04 VA Initial Release
  *************************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: LOAD_ELIGIBLE_ESNS_PRC.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2012/04/03 15:13:36 $
  --$ $Log: LOAD_ELIGIBLE_ESNS_PRC.sql,v $
  --$ Revision 1.2  2012/04/03 15:13:36  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  CURSOR c_esn IS
    SELECT pi.part_serial_no serial_no
          ,pi.objid          pi_objid
          ,tmp.rowid         tmp_rowid
      FROM table_part_inst pi
          ,tmp_promo_esns  tmp
     WHERE tmp.esn = pi.part_serial_no;

  v_ins               NUMBER := 0;
  v_promo_group_objid NUMBER;
  v_start             DATE := SYSDATE;
  v_start_date        DATE := TRUNC(SYSDATE);
  v_exists            NUMBER := 0;
  v_action            VARCHAR2(4000);
  v_serial_num        VARCHAR2(20);
  v_procedure_name    VARCHAR2(50) := 'SA.LOAD_ELIGIBLE_ESNS_PRC';
BEGIN

  v_action := 'Promo Group Check';

  BEGIN
    SELECT objid
      INTO v_promo_group_objid
      FROM table_x_promotion_group
     WHERE group_name = p_group_name;
  EXCEPTION
    WHEN others THEN
      toss_util_pkg.insert_error_tab_proc(v_action
                                         ,p_group_name
                                         ,v_procedure_name);
      RETURN;
  END;

  v_action := 'Insert into Group2Esn';

  FOR c_esn_rec IN c_esn LOOP

    BEGIN
      v_serial_num := c_esn_rec.serial_no;
      v_exists     := 0;
      SELECT COUNT(1)
        INTO v_exists
        FROM table_x_group2esn
       WHERE groupesn2part_inst = c_esn_rec.pi_objid
         AND groupesn2x_promo_group + 0 = v_promo_group_objid;

      IF v_exists = 0 THEN
        INSERT INTO table_x_group2esn
          (objid
          ,x_annual_plan
          ,groupesn2part_inst
          ,groupesn2x_promo_group
          ,x_end_date
          ,x_start_date)
        VALUES
          (seq('x_group2esn')
          ,0
          ,c_esn_rec.pi_objid
          ,v_promo_group_objid
          ,p_end_date
          ,v_start_date);

        v_ins := v_ins + 1;
      END IF;

      IF MOD(v_ins
            ,1000) = 0 THEN
        COMMIT;
      END IF;
    EXCEPTION
      WHEN others THEN
        toss_util_pkg.insert_error_tab_proc('Inner Loop :' || v_action
                                           ,v_serial_num
                                           ,v_procedure_name);
        COMMIT;
    END;
    --
    -- CR16379 Start kacosta 03/09/2012
    DECLARE
      --
      l_i_error_code    INTEGER := 0;
      l_v_error_message VARCHAR2(32767) := 'SUCCESS';
      --
    BEGIN
      --
      promotion_pkg.expire_double_if_esn_is_triple(p_esn           => c_esn_rec.serial_no
                                                  ,p_error_code    => l_i_error_code
                                                  ,p_error_message => l_v_error_message);
      --
      IF (l_i_error_code <> 0) THEN
        --
        dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with error: ' || l_v_error_message);
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
  END LOOP;

  COMMIT;

  IF toss_util_pkg.insert_interface_jobs_fun(v_procedure_name
                                            ,v_start
                                            ,SYSDATE
                                            ,v_ins
                                            ,'SUCCESS'
                                            ,v_procedure_name) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN others THEN
    toss_util_pkg.insert_error_tab_proc(v_action
                                       ,NULL
                                       ,v_procedure_name);

    IF toss_util_pkg.insert_interface_jobs_fun(v_procedure_name
                                              ,v_start
                                              ,SYSDATE
                                              ,v_ins
                                              ,'FAILED'
                                              ,v_procedure_name) THEN
      COMMIT;
    END IF;
END load_eligible_esns_prc;
/