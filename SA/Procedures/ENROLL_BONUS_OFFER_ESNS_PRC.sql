CREATE OR REPLACE PROCEDURE sa."ENROLL_BONUS_OFFER_ESNS_PRC" AS
  /******************************************************************************/
  /* Copyright . 2006 Tracfone Wireless Inc. All rights reserved */
  /* */
  /* Name : enroll_bonus_offer_esns */
  /* */
  /* Purpose : This procedure enrolls the given list of esns by churn group
  /* in the bonus minutes offer */
  /* */
  /* PARAMETERS: */
  /* Platforms : Oracle 8.0.6 AND newer versions */
  /* Revisions : */
  /* Version Date Who Purpose */
  /* ------- -------- ------- ---------------------------------------------- */
  /* 1.0 08/04/2006 VAdapa Initial revision */
  /* 1.1 08/06/2006 Jing Tong Modified to insert the #of records to process */
  /******************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: ENROLL_BONUS_OFFER_ESNS_PRC.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2012/04/03 15:13:36 $
  --$ $Log: ENROLL_BONUS_OFFER_ESNS_PRC.sql,v $
  --$ Revision 1.2  2012/04/03 15:13:36  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  CURSOR c_promo_esn IS
    SELECT a.rowid
          ,a.*
      FROM bonus_retention_offer_esns a
     WHERE enroll_yn = 'N';

  CURSOR c_esn(ip_esn IN VARCHAR2) IS
    SELECT objid
      FROM table_part_inst pi
     WHERE pi.part_serial_no = ip_esn;

  c_esn_rec             c_esn%ROWTYPE;
  v_ins                 NUMBER := 0;
  v_promo_group_objid_1 NUMBER;
  v_promo_group_objid_2 NUMBER;
  v_promo_group_objid   NUMBER;
  v_promo_group_enddt_1 DATE;
  v_promo_group_enddt_2 DATE;
  v_promo_group_enddt   DATE;
  v_start               DATE := SYSDATE;
  v_end                 DATE;
  v_time_used           NUMBER(10
                              ,2);
  v_exists              NUMBER := 0;
  v_exists_tot          NUMBER := 0;
  v_start_date          DATE := TRUNC(SYSDATE);
  v_action              VARCHAR2(255);
  v_key                 VARCHAR2(255);
  v_procedure_name      VARCHAR2(255) := 'ENROLL_RETENTION_OFFER_ESNS_PRC';
  l_start_date          DATE := SYSDATE;
  l_recs_processed      NUMBER := 0;
BEGIN
  v_action := 'Get Promo Group Objid for Offer A';

  BEGIN
    SELECT objid
          ,x_end_date
      INTO v_promo_group_objid_1
          ,v_promo_group_enddt_1
      FROM table_x_promotion_group
     WHERE group_name = 'BONUS_RETN_GROUP_A'
       AND SYSDATE BETWEEN x_start_date AND x_end_date;
  EXCEPTION
    WHEN others THEN
      insert_error_tab_proc(v_action
                           ,'BONUS_RETN_GROUP_A'
                           ,v_procedure_name
                           ,'Promo Group Not found');
      RETURN;
  END;

  v_action := 'Get Promo Group Objid for Offer B';

  BEGIN
    SELECT objid
          ,x_end_date
      INTO v_promo_group_objid_2
          ,v_promo_group_enddt_2
      FROM table_x_promotion_group
     WHERE group_name = 'BONUS_RETN_GROUP_B'
       AND SYSDATE BETWEEN x_start_date AND x_end_date;
  EXCEPTION
    WHEN others THEN
      insert_error_tab_proc(v_action
                           ,'BONUS_RETN_GROUP_B'
                           ,v_procedure_name
                           ,'Promo Group Not found');
      RETURN;
  END;

  FOR c_promo_esn_rec IN c_promo_esn LOOP
    v_promo_group_objid := NULL;
    l_recs_processed    := l_recs_processed + 1;

    IF c_promo_esn_rec.bonus_offer = 'PAST_DUE' THEN
      v_promo_group_objid := v_promo_group_objid_1;
      v_promo_group_enddt := v_promo_group_enddt_1;
    ELSIF c_promo_esn_rec.bonus_offer = 'FAMILY_DOLLAR' THEN
      v_promo_group_objid := v_promo_group_objid_2;
      v_promo_group_enddt := v_promo_group_enddt_2;
    ELSE
      v_promo_group_objid := NULL;
      v_promo_group_enddt := NULL;
    END IF;

    IF v_promo_group_objid IS NULL THEN
      RETURN;
    END IF;

    OPEN c_esn(c_promo_esn_rec.esn);

    FETCH c_esn
      INTO c_esn_rec;

    IF c_esn%FOUND THEN
      v_exists := 0;
      v_key    := c_promo_esn_rec.esn;
      v_action := 'Check Esn existence in Table_x_Group2esn';

      SELECT COUNT(1)
        INTO v_exists
        FROM table_x_group2esn
       WHERE groupesn2part_inst = c_esn_rec.objid
         AND groupesn2x_promo_group + 0 = v_promo_group_objid;

      IF v_exists = 0 THEN
        v_action := 'Insert into Table_x_Group2esn';

        INSERT INTO table_x_group2esn
          (objid
          ,x_annual_plan
          ,groupesn2part_inst
          ,groupesn2x_promo_group
          ,x_end_date
          ,x_start_date
          ,groupesn2x_promotion)
        VALUES
          (seq('x_group2esn')
          ,0
          ,c_esn_rec.objid
          ,v_promo_group_objid
          ,v_promo_group_enddt
          ,v_start_date
          ,NULL);

        v_ins    := v_ins + 1;
        v_action := 'Update Source Table as Y (Success)';

        UPDATE bonus_retention_offer_esns
           SET enroll_yn = 'Y'
              ,enroll_dt = SYSDATE
         WHERE ROWID = c_promo_esn_rec.rowid;
      ELSE
        v_action := 'Update Source Table as E (Exists)';

        UPDATE bonus_retention_offer_esns
           SET enroll_yn = 'E'
              ,enroll_dt = SYSDATE
         WHERE ROWID = c_promo_esn_rec.rowid;
      END IF;

      IF MOD(v_ins
            ,1000) = 0 THEN
        COMMIT;
      END IF;
    ELSE
      v_action := 'Update Source Table as N (Not Found)';

      UPDATE bonus_retention_offer_esns
         SET enroll_yn = 'F'
            ,enroll_dt = SYSDATE
       WHERE ROWID = c_promo_esn_rec.rowid;
    END IF;

    CLOSE c_esn;
    --
    -- CR16379 Start kacosta 03/09/2012
    DECLARE
      --
      l_i_error_code    INTEGER := 0;
      l_v_error_message VARCHAR2(32767) := 'SUCCESS';
      --
    BEGIN
      --
      promotion_pkg.expire_double_if_esn_is_triple(p_esn           => c_promo_esn_rec.esn
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
                                            ,l_start_date
                                            ,SYSDATE
                                            ,l_recs_processed
                                            ,'SUCCESS'
                                            ,v_procedure_name) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK;
    insert_error_tab_proc(v_action
                         ,v_key
                         ,v_procedure_name);
END enroll_bonus_offer_esns_prc;
/