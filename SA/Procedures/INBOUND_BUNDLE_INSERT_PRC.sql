CREATE OR REPLACE PROCEDURE sa."INBOUND_BUNDLE_INSERT_PRC"
AS
    l_bundle2part_inst     table_part_inst.objid%TYPE := NULL;
    l_esn_objid            table_part_inst.objid%TYPE := NULL;
    l_pin_objid            table_part_inst.objid%TYPE := NULL;
    l_red_code             table_part_inst.x_red_code%TYPE := NULL;
    l_seq                  NUMBER := NULL;
    l_count                NUMBER := 0;
    l_esn_pin_cnt          NUMBER := 0;
    l_cnt_updated          NUMBER := 0;
	l_status2x_code_table  table_x_code_table.objid%TYPE := NULL;
    l_program_name     VARCHAR2(100) := 'Inbound_bundle_insert_prc';


    --Retrieve the TW Bundled serial numbers from OFS.
    CURSOR C1 IS
    SELECT  *
      FROM tf_of_r7_inv_v r7
     WHERE 1=1
       AND NOT EXISTS ( SELECT 1
                         FROM table_x_bundle tb,
                              table_part_inst inst
                        WHERE tb.bundle2part_inst   = inst.objid
                          AND r7.x_bundle_code    = tb.x_bundle_code
                          AND inst.part_serial_no = r7.tf_serial_number
                     );

    BEGIN

       BEGIN

	    --Clean up data in tf_of_r7_inv_v.
	    DELETE FROM tf_of_r7_inv_v;
	    COMMIT;

	    INSERT
	      INTO sa.tf_of_r7_inv_v
            SELECT r7s.tf_serial_number,
                   cr7.primary_item,
                   r7s.primary_item part_num,
                   cr7.file_id x_bundle_code,
                   cr7.record_type,
                   cr7.ff_reference,
                   cr7.license_plate,
                   r7s.process_date
              FROM tf.tf_cr7@ofsprd cr7,
                   tf.tf_r7_serial@ofsprd r7s
             WHERE cr7.file_id = r7s.file_id
             -- AND r7s.file_id IN ( '000079442201707287952900011' )
              AND r7s.primary_item IN ('TWLGL58VCP' , 'TWN40035CL')
              AND TRUNC(r7s.process_date)>= TRUNC(SYSDATE)-1
        ;
	COMMIT;

	BEGIN
	   SELECT objid
             INTO l_status2x_code_table
             FROM table_x_code_table code
            WHERE 1 = 1
              AND code.x_code_number = '400';

	EXCEPTION WHEN OTHERS THEN
	    l_status2x_code_table := 805330212;
	END;

        EXCEPTION WHEN OTHERS THEN
            dbms_output.put_line( ' Error occured while inserting data -'||SQLCODE||'-'||SQLERRM);

	        sa.toss_util_pkg.insert_error_tab_proc (SQLERRM, --ip_action
                                                        'Error occured while inserting data', --ip_key
                                                        l_program_name, --ip_program_name
                                                        'Error occured while inserting data -'||SQLCODE||'-'||SQLERRM   --ip_error_text
                                                        );
        END;




    FOR i IN C1
    LOOP

        l_seq := sequ_x_bundle.nextval + 1;
        l_count := 0;
        l_esn_pin_cnt := 0;
        l_red_code := 0;
        l_cnt_updated := 0;
        l_esn_objid := NULL;
        l_pin_objid := NULL;
        l_bundle2part_inst := NULL;

        dbms_output.put_line( ' i.tf_serial_number:'||i.tf_serial_number);
        dbms_output.put_line( ' i.x_bundle_code:'||i.x_bundle_code);

        BEGIN
	    --Based on OFS Serial Numbers specific to bundled data, Verify CLFY side, Whether that Records exists or not.
            SELECT inst.objid,
                   x_red_code
              INTO l_bundle2part_inst,
		   l_red_code
              FROM table_part_inst inst
             WHERE part_serial_no = i.tf_serial_number
               AND NOT EXISTS ( SELECT 1
                                  FROM table_x_bundle bi
                                 WHERE bi.bundle2part_inst = inst.objid );

        EXCEPTION WHEN OTHERS THEN
	    l_bundle2part_inst := NULL;
	    l_red_code := NULL;

            --Insert into log table If there was no record found.
	    sa.toss_util_pkg.insert_error_tab_proc (SQLERRM, --ip_action
                                                    i.tf_serial_number, --ip_key
                                                    l_program_name, --ip_program_name
                                                    'No data found for l_bundle2part_inst'||l_bundle2part_inst
                                                    ||',tf_serial_number:'||i.tf_serial_number --ip_error_text
                                                    );
	    commit;

            dbms_output.put_line( ' No data found for l_bundle2part_inst:'||l_bundle2part_inst);
            dbms_output.put_line( ' No data found for i.tf_serial_number:'||i.tf_serial_number);
        END;


        IF l_bundle2part_inst is NOT NULL THEN

	    --Insert into bundled table.
            INSERT
              INTO table_x_bundle
                (
                 OBJID           ,
                 BUNDLE2PART_INST,
                 X_BUNDLE_CODE,
                 STATUS
                )
            VALUES
                (
                 l_seq,
                 l_bundle2part_inst,
                 i.x_bundle_code,
                 NULL
                );

            dbms_output.put_line( 'l_bundle2part_inst is NOT NULL and total rows inserted into table_x_bundle:'||SQL%ROWCOUNT);

	    --Verify Number of records exist in CLFY side based on bundled code.
            SELECT COUNT(1)
              INTO l_count
              FROM table_x_bundle tb
             WHERE 1 = 1
               AND x_bundle_code = i.x_bundle_code;

            dbms_output.put_line( ' total l_count in table_x_bundle for x_bundle_code:'||l_count);

            IF l_count > 1 THEN

		--If there will be records exist in bundled table specific to bundled data, then verify PIN marriage to ESN.
                SELECT COUNT(1)
                  INTO l_esn_pin_cnt
                  FROM table_x_bundle tb,
                       table_part_inst tpi
                 WHERE 1= 1
                   AND tb.bundle2part_inst = tpi.objid
                   AND tb.x_bundle_code = i.x_bundle_code
                   AND x_red_code IS NULL
                   AND EXISTS(SELECT 1
                                FROM table_part_inst inst,
                                     table_part_inst inst_rc
                               WHERE inst.objid            = inst_rc.part_to_esn2part_inst
                                 AND tb.bundle2part_inst = inst.objid
                                 AND inst_rc.x_domain           = 'REDEMPTION CARDS'
                                 AND inst_rc.x_part_inst_status = '400'
                );

	        --If There was no PIN marriage to ESN for specific bundled data, Then l_esn_pin_cnt = 0.
                IF l_esn_pin_cnt = 0 THEN

                    BEGIN
                        --Get the PIN objid for specific bundled data.
                        SELECT tpi.objid
                          INTO l_pin_objid
                          FROM table_x_bundle tb,
                               table_part_inst tpi
                         WHERE 1= 1
                           AND tb.bundle2part_inst = tpi.objid
                           AND x_bundle_code = i.x_bundle_code
                           AND x_red_code IS NOT NULL
                           AND ROWNUM < 2 ;

                        dbms_output.put_line( ' l_pin_objid:'||l_pin_objid);

                    EXCEPTION WHEN OTHERS THEN
                        l_pin_objid := NULL;


			sa.toss_util_pkg.insert_error_tab_proc (SQLERRM, --ip_action
                                                                i.tf_serial_number, --ip_key
                                                                l_program_name, --ip_program_name
                                                                ' l_pin_objid is NULL and i.x_bundle_code:'||i.x_bundle_code
                                                                ||',tf_serial_number:'||i.tf_serial_number  --ip_error_text
                                                                );
			commit;


                    END;

                    BEGIN
                        --Get the ESN objid for specific bundled data.
                        SELECT tpi.objid
                          INTO l_esn_objid
                          FROM table_x_bundle tb,
                               table_part_inst tpi
                         WHERE 1= 1
                           AND tb.bundle2part_inst = tpi.objid
                           AND x_bundle_code = i.x_bundle_code
                           AND x_red_code IS NULL
                           AND ROWNUM < 2 ;

                        dbms_output.put_line( ' l_esn_objid:'||l_esn_objid);

                    EXCEPTION WHEN OTHERS THEN
                        l_esn_objid := NULL;

			sa.toss_util_pkg.insert_error_tab_proc (SQLERRM, --ip_action
                                                                i.tf_serial_number, --ip_key
                                                                l_program_name, --ip_program_name
                                                                ' l_esn_objid is NULL and i.x_bundle_code:'||i.x_bundle_code
                                                                ||',tf_serial_number:'||i.tf_serial_number   --ip_error_text
                                                               );
			commit;

                    END;

		   --if there was no PIN marriage to ESN, and if l_pin_objid and l_esn_objid is not NULL then do PIN marriage to ESN.
                    IF l_pin_objid IS NOT NULL
                        AND l_esn_objid IS NOT NULL THEN

                        UPDATE table_part_inst
                           SET x_part_inst_status = '400',
                               part_to_esn2part_inst = l_esn_objid,
		               status2x_code_table = l_status2x_code_table
                        WHERE objid = l_pin_objid;

                        l_cnt_updated := SQL%ROWCOUNT;

                        dbms_output.put_line( ' Total rows updated in part_inst:'||l_cnt_updated);

                        IF l_cnt_updated > 0 THEN

			    -- After PIN marriage, Update Bundled table with pin2esn_flag as 'Y'.
                            UPDATE table_x_bundle
                            SET pin2esn_flag = 'Y'
                            WHERE bundle2part_inst = l_esn_objid;

                            dbms_output.put_line( ' table_x_bundle updated row count:'||SQL%ROWCOUNT
                            ||' - l_esn_objid :'||l_esn_objid);

                        END IF; --IF l_cnt_updated > 0 THEN

                   END IF; --IF l_pin_objid IS NOT NULL

                END IF; --IF l_esn_pin_cnt = 0 THEN

            END IF; --IF l_count > 1 THEN

        END IF;  --IF l_bundle2part_inst is NOT NULL THEN

        COMMIT;

    END LOOP; --FOR i IN C1

EXCEPTION WHEN OTHERS THEN

    dbms_output.put_line( ' Error occured -'||SQLCODE||'-'||SQLERRM);

	sa.toss_util_pkg.insert_error_tab_proc (SQLERRM, --ip_action
                                                'Error occured', --ip_key
                                                l_program_name, --ip_program_name
                                                'Error occured -'||SQLCODE||'-'||SQLERRM   --ip_error_text
                                                );

END Inbound_bundle_insert_prc;
/