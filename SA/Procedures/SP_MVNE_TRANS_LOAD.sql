CREATE OR REPLACE PROCEDURE sa."SP_MVNE_TRANS_LOAD"
IS
CURSOR main_cur IS
    SELECT *
    FROM sa.x_mvne_trans_stg_load;


    v_return NUMBER;
    l_pin_part_num VARCHAR2(100);
    l_soft_pin NUMBER;
    l_smp_number VARCHAR2(100);
    l_err_msg VARCHAR2(100);
    l_inv_bin_objid NUMBER:=0;

    l_city VARCHAR2(50);
    l_state VARCHAR2(10);

    l_process_step VARCHAR2(100);
    v_state          VARCHAR2(30);
    v_brand          VARCHAR2(30);

  BEGIN
    FOR cur IN main_cur LOOP

    BEGIN

    l_pin_part_num :=null;
    l_soft_pin :=null;
    l_smp_number :=null;
    l_city :=null;
    l_state :=null;
    v_state :=null;
    v_brand :=null;
    v_return :=null;

      L_PROCESS_STEP := 'Budget transaction load :Fetching tracfone part number';
      IF cur.x_mvne_part_num IS NOT NULL AND cur.x_trans_type  IN ('redemption','reactivation','activation') THEN
          BEGIN
              SELECT x_state INTO v_state FROM TABLE_X_ZIP_CODE WHERE x_zip =cur.X_ZIPCODE;
                  IF v_state                ='CA' THEN
                   v_brand := 'NET10' ;--NT MOd
                   ELSE
                    v_brand := 'TRACFONE';--TF mod
                   END IF;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
              v_brand := 'TRACFONE';
          END;

         BEGIN
          SELECT
             x_tf_partnum INTO l_pin_part_num
         from x_mvne_partnum_mapping where x_mvne_partnum=cur.x_mvne_part_num and brand =v_brand;
         EXCEPTION WHEN
            OTHERS THEN
             l_pin_part_num :=NULL;
         END;
      END IF;

      BEGIN
      SELECT
         x_city,
         x_state
      INTO
         l_city,
         l_state
       FROM table_x_zip_code
       WHERE x_zip = cur.x_zipcode    ;
       EXCEPTION WHEN OTHERS
       THEN  NULL;
       END;
       l_process_step := 'Budget transaction load :Fetching pin dealer';
    BEGIN
          SELECT objid
      INTO l_inv_bin_objid
      FROM table_inv_bin
      WHERE bin_name IN (select x_param_value from table_x_parameters where x_param_name ='BUDGET_DEALER');
    EXCEPTION WHEN
         OTHERS THEN
           l_inv_bin_objid := 0;
        END;

        l_process_step := 'Budget transaction load :calling soft pin ';

        IF l_pin_part_num IS NOT NULL THEN
         v_return := getsoftpin(
                                ip_pin_part_num  => l_pin_part_num,
                                ip_inv_bin_objid => l_inv_bin_objid,
                                op_soft_pin      => l_soft_pin,
                                op_smp_number    => l_smp_number,
                                op_err_msg       => l_err_msg
                                 );

          IF v_return <> 0 THEN
      l_process_step := 'Budget transaction load :soft pinreturned error';
                  sp_insert_error(i_esn          => cur.x_esn     ,
                                      i_sim          => cur.x_current_sim,
                                      i_zipcode      => cur.x_zipcode,
                                      i_process_step => l_process_step,
                                      i_error_code   => v_return,
                                      i_error_string => l_err_msg);
          END IF;


        END IF;


        l_process_step := 'Budget transaction load :Insert x_budget_trans_stg ';

        INSERT INTO sa.x_mvne_transaction_stg
        (
        objid                     ,
        x_esn                     ,
        x_current_sim          ,
        x_new_sim          ,
        x_current_min             ,
        x_new_min                 ,
        x_trans_type              ,
        x_mvne_part_num         ,
        x_tf_part_num  ,
        x_deact_reason            ,
        x_zipcode                 ,
        x_current_plan               ,
    x_new_plan     ,
        x_state               ,
        x_email               ,
        x_first_name               ,
        x_last_name               ,
        x_city               ,
        x_address1               ,
        x_source_system           ,
        x_status                  ,
        x_red_code                ,
        x_insert_date  ,
    x_batch_id,
    x_transaction_id
        )
        VALUES
        (
        sa.seq_x_mvne_transaction_stg.nextval,
        cur.x_esn                        ,
        cur.x_current_sim             ,
        cur.x_new_sim                 ,
        cur.x_current_min                ,
        cur.x_new_min                    ,
        cur.x_trans_type                 ,
        cur.x_mvne_part_num            ,
        l_pin_part_num                   ,
        cur.x_deact_reason               ,
        cur.x_zipcode                    ,
        cur.x_current_plan                  ,
    cur.x_new_plan   ,
        l_state               ,
        cur.x_email               ,
        cur.x_esn               ,
        cur.x_esn              ,
        l_city              ,
        cur.x_address1               ,
        'Budget'                         ,
        'Pending'                        ,
        l_soft_pin                       ,
        sysdate,
    cur.x_batch_id,
    cur.x_transaction_id
        );

       COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
          sp_insert_error(i_esn          => cur.x_esn      ,
                          i_sim          => cur.x_current_sim,
                          i_zipcode      => cur.x_zipcode,
                          i_process_step => l_process_step,
                          i_error_code   => sqlcode,
                          i_error_string => 'Oracle Error: '||sqlerrm);

    END;
    END LOOP;
END;
/