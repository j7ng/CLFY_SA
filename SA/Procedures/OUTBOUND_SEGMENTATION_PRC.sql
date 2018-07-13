CREATE OR REPLACE PROCEDURE sa.outbound_segmentation_prc
                            (p_in_date IN DATE DEFAULT NULL)
IS
CURSOR subscribe_c IS
SELECT *
FROM table_x_call_trans c
WHERE c.x_action_type = '82'
AND trunc(c.x_transact_date) = trunc(p_in_date)
AND c.x_result = 'Completed';

CURSOR unsubscribe_c IS
SELECT *
FROM table_x_call_trans c
WHERE c.x_action_type = '83'
AND trunc(c.x_transact_date) = trunc(p_in_date)
AND c.x_result = 'Completed';

CURSOR autopay_dtl_c(esn number) IS
SELECT *
FROM table_x_autopay_details
WHERE x_esn = esn;

subscribe_rec subscribe_c%ROWTYPE;
unsubscribe_rec subscribe_c%ROWTYPE;
autopay_rec autopay_dtl_c%ROWTYPE;
v_part_num varchar2(30);
v_segment_name varchar2(20);

BEGIN
    FOR subscribe_rec IN subscribe_c
    LOOP
        OPEN autopay_dtl_c(subscribe_rec.x_service_id);
        FETCH autopay_dtl_c INTO autopay_rec;
        CLOSE autopay_dtl_c;

        IF autopay_rec.x_program_type = 2 THEN
           v_part_num := 'APPAUTOREG';
           v_segment_name := 'AUTOPAY';
        ELSE
             IF autopay_rec.x_program_type = 3 THEN
                v_part_num := 'APPBONUSREG';
                v_segment_name := 'BONUS';
             ELSE
                  IF autopay_rec.x_program_type = 4 THEN
                     v_part_num := 'APPDEACTREG';
                     v_segment_name := 'DEACTIVATION';
                  END IF;
             END IF;
        END IF;

        INSERT INTO X_SEGMENTATION
        (segmentation_id,
         segmentation_name,
         action_type,
         action_date,
         esn,
         toss_part_num)
        VALUES
        (seq_x_segmentation.nextval,
        v_segment_name,
        'Enrollment',
        autopay_rec.x_start_date,
        autopay_rec.x_esn,
        v_part_num);

        COMMIT;
   END LOOP;

   FOR unsubscribe_rec IN unsubscribe_c
    LOOP
        OPEN autopay_dtl_c(unsubscribe_rec.x_service_id);
        FETCH autopay_dtl_c INTO autopay_rec;
        CLOSE autopay_dtl_c;

        IF autopay_rec.x_program_type = 2 THEN
           v_part_num := 'APPAUTOREG';
           v_segment_name := 'AUTOPAY';
        ELSE
             IF autopay_rec.x_program_type = 3 THEN
                v_part_num := 'APPBONUSREG';
                v_segment_name := 'BONUS';
             ELSE
                  IF autopay_rec.x_program_type = 4 THEN
                     v_part_num := 'APPDEACTREG';
                     v_segment_name := 'DEACTIVATION';
                  END IF;
             END IF;
        END IF;

        INSERT INTO X_SEGMENTATION
        (segmentation_id,
         segmentation_name,
         action_type,
         action_date,
         esn,
         toss_part_num)
        VALUES
        (seq_x_segmentation.nextval,
        v_segment_name,
        'Cancellation',
        autopay_rec.x_end_date,
        autopay_rec.x_esn,
        v_part_num);
   END LOOP;

   COMMIT;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Could not retrieve Autopay_details record for ESN: ' ||  subscribe_rec.x_service_id);
        ROLLBACK;
   WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error while running the procedure');
        ROLLBACK;
END;
/