CREATE OR REPLACE PACKAGE BODY sa.imei_pkg AS

PROCEDURE insert_imei_mismatch( i_imei_rec              IN  sa.x_imei_mismatch%ROWTYPE,
                                o_error_code            OUT VARCHAR2,
                                o_err_msg               OUT VARCHAR2
                              )

AS

BEGIN

	BEGIN
		INSERT
		INTO sa.x_imei_mismatch
			(
			objid                ,
			min                  ,
			iccid                ,
			old_esn              ,
			old_esn_status       ,
			new_esn              ,
			new_esn_status       ,
			old_esn_brand        ,
			new_esn_brand        ,
			old_esn_device_type  ,
			new_esn_device_type  ,
			old_esn_manufacturer ,
			new_esn_manufacturer ,
			old_esn_technology   ,
			new_esn_technology   ,
			old_esn_rate_plan    ,
			old_esn_service_plan ,
			old_esn_cos          ,
			old_esn_carrier      ,
			new_esn_carrier      ,
			zipcode              ,
           		carrier_response     ,
			status_result        ,
			status_desc
			)
		VALUES
			(
			i_imei_rec.objid                ,
			i_imei_rec.min                  ,
			i_imei_rec.iccid                ,
			i_imei_rec.old_esn              ,
			i_imei_rec.old_esn_status       ,
			i_imei_rec.new_esn              ,
			i_imei_rec.new_esn_status       ,
			i_imei_rec.old_esn_brand        ,
			i_imei_rec.new_esn_brand        ,
			i_imei_rec.old_esn_device_type  ,
			i_imei_rec.new_esn_device_type  ,
			i_imei_rec.old_esn_manufacturer ,
			i_imei_rec.new_esn_manufacturer ,
			i_imei_rec.old_esn_technology   ,
			i_imei_rec.new_esn_technology   ,
			i_imei_rec.old_esn_rate_plan    ,
			i_imei_rec.old_esn_service_plan ,
			i_imei_rec.old_esn_cos          ,
			i_imei_rec.old_esn_carrier      ,
			i_imei_rec.new_esn_carrier      ,
			i_imei_rec.zipcode              ,
			i_imei_rec.carrier_response     ,
			i_imei_rec.status_result        ,
			i_imei_rec.status_desc
			);


		COMMIT;

    EXCEPTION
        WHEN OTHERS THEN NULL;

            o_error_code	:=	'99';
            o_err_msg	:=	'Insert failed for objid of x_imei_mismatch table :'||i_imei_rec.objid ||'-'||SQLERRM;

            dbms_output.put_line('ERROR_STACK: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
            dbms_output.put_line('ERROR_BACKTRACE: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

	END;

    o_error_code  :=	'0';
    o_err_msg	  :=	'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN NULL;

        o_error_code	:=	'99';
        o_err_msg	:=	'Insert failed for objid of x_imei_mismatch table :'||i_imei_rec.objid ||'-'||SQLERRM;

        dbms_output.put_line('ERROR_STACK: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        dbms_output.put_line('ERROR_BACKTRACE: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

END insert_imei_mismatch;

--CR56516
PROCEDURE validate_imei_mismatch(
                                  i_esn               IN x_imei_mismatch.new_esn%TYPE,
                                  i_min               IN x_imei_mismatch.min%TYPE,
                                  o_error_code        OUT VARCHAR2,
                                  o_err_msg           OUT VARCHAR2,
                                  i_carrier_response  IN x_imei_mismatch.carrier_response%TYPE DEFAULT NULL
                                )
AS
    cst                     sa.customer_type   := sa.customer_type();
    cst_min                 sa.customer_type   := sa.customer_type();
    s                       sa.customer_type   := sa.customer_type(i_esn);
    cst_new_esn             sa.customer_type   := sa.customer_type();
    cst_carrier             sa.customer_type   := sa.customer_type();
    l_imei_rec              x_imei_mismatch%ROWTYPE;
    l_old_esn_sub_brand     x_imei_mismatch.old_esn_brand%TYPE;
    l_new_esn_sub_brand     x_imei_mismatch.new_esn_brand%TYPE;
    l_inv_bin_objid         table_part_inst.part_inst2inv_bin%TYPE;
    l_site_part_objid       table_site_part.objid%TYPE;
    l_old_esn_carrier_objid table_x_carrier.objid%TYPE;
    l_null                  VARCHAR2(10) := 'NULL';
    l_count                 NUMBER := 0;
    l_iteration_count       NUMBER := 0;
    l_part_number           VARCHAR2(30);
    l_repl_tech             VARCHAR2(30);
    l_sim_profile           VARCHAR2(30);
    l_part_serial_no        VARCHAR2(30);
    l_msg                   VARCHAR2(1000);
    l_pref_parent           VARCHAR2(30);
    l_pref_carrier_objid    VARCHAR2(30);
    l_char                  VARCHAR2(10) := '/';

BEGIN

    l_iteration_count := l_iteration_count + 1;  --1
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    BEGIN
        SELECT COUNT(1)
          INTO l_count
          FROM x_imei_mismatch imei
         WHERE 1=1
           AND MIN                  = i_min
           AND new_esn              = i_esn
           AND TRUNC(created_date) >= TRUNC(SYSDATE);

    EXCEPTION
        WHEN OTHERS THEN
            l_count := 0;
            o_error_code	:=	'99';
            o_err_msg	:=	'Exception raised in No logging required for MIN block';

    END;

    IF l_count > 0 THEN

        dbms_output.put_line('No logging required for MIN:' ||i_min||','||'ESN:'||i_esn  );

        o_error_code	:=	'0';
        o_err_msg	:=	'SUCCESS';
        -- No logging was required and duplicate record already exist for the IMEI and MIN.
        RETURN;

    END IF;

    --Retrieve old_esn Info based on MIN.
    cst_min := cst.retrieve_min ( i_min => i_min );

    l_imei_rec.old_esn                := cst_min.esn                  ;
    l_imei_rec.min                    := cst_min.min                  ;
    l_imei_rec.iccid                  := cst_min.iccid                ;
    l_imei_rec.old_esn_status         := cst_min.esn_part_inst_status;
    l_old_esn_carrier_objid           := cst_min.carrier_objid       ;
    l_inv_bin_objid                   := cst_min.inv_bin_objid       ;
    l_imei_rec.old_esn_brand          := cst_min.bus_org_id          ;
    l_old_esn_sub_brand               := cst_min.get_sub_brand       ;
    l_site_part_objid                 := cst_min.site_part_objid     ;
    l_imei_rec.old_esn_carrier        := cst_min.short_parent_name    ;
    l_imei_rec.zipcode                := cst_min.zipcode              ;
    l_imei_rec.old_esn_device_type    := cst_min.device_type  ;
    l_imei_rec.old_esn_manufacturer   := cst_min.phone_manufacturer;
    l_imei_rec.old_esn_technology     := cst_min.technology;
    l_imei_rec.old_esn_rate_plan      := cst_min.rate_plan;
    l_imei_rec.old_esn_service_plan   := cst_min.service_plan_objid;
    l_imei_rec.old_esn_cos            := cst_min.cos;
    l_imei_rec.objid                  := sa.sequ_x_imei_mismatch.nextval;
    l_imei_rec.carrier_response       := i_carrier_response;

    --Retrieve new_esn Info.
    cst_new_esn                 := s.retrieve;

    l_imei_rec.new_esn                := cst_new_esn.esn;
    l_imei_rec.new_esn_status         := cst_new_esn.esn_part_inst_status;
    l_imei_rec.new_esn_brand          := cst_new_esn.bus_org_id          ;
    l_new_esn_sub_brand               := cst_new_esn.get_sub_brand          ;
    l_imei_rec.new_esn_device_type    := cst_new_esn.device_type  ;
    l_imei_rec.new_esn_manufacturer   := cst_new_esn.phone_manufacturer;
    l_imei_rec.new_esn_technology     := cst_new_esn.technology;
    l_imei_rec.new_esn_carrier        := cst_new_esn.short_parent_name    ;
    l_imei_rec.status_result          := 'No further updates are necessary' ;

    dbms_output.put_line('l_imei_rec.min   => ' ||l_imei_rec.min   );
    dbms_output.put_line('l_imei_rec.old_esn  => ' ||l_imei_rec.old_esn  );
    dbms_output.put_line('l_imei_rec.new_esn  => ' ||l_imei_rec.new_esn  );
    --dbms_output.put_line('l_old_esn_sub_brand  => ' ||l_old_esn_sub_brand  );
    --dbms_output.put_line('l_new_esn_sub_brand  => ' ||l_new_esn_sub_brand  );


    l_iteration_count := l_iteration_count + 1;  --2
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --Compare old_esn and new_esn.
    IF l_imei_rec.old_esn = l_imei_rec.new_esn THEN

        l_imei_rec.status_desc       := 'Same phone as on records';

        insert_imei_mismatch( i_imei_rec       =>  l_imei_rec    ,
                              o_error_code     =>  o_error_code ,
                              o_err_msg        =>  o_err_msg
                            );

        RETURN;
    END IF;

    l_iteration_count := l_iteration_count + 1;  --3
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --Compare old_esn and new_esn.
    IF l_imei_rec.old_esn IS NULL THEN

        l_imei_rec.status_desc       := 'Old Phone not in DB';

        insert_imei_mismatch( i_imei_rec       =>  l_imei_rec    ,
                              o_error_code     =>  o_error_code ,
                              o_err_msg        =>  o_err_msg
                            );

        RETURN;
    END IF;

    l_iteration_count := l_iteration_count + 1;  --4
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --Verify whether new_esn exists in CLFY DB.
    IF NVL(l_imei_rec.old_esn_brand,'X') <> NVL(l_imei_rec.new_esn_brand, 'X')
        AND NVL(l_imei_rec.new_esn_brand, 'X') = 'X' THEN

        l_imei_rec.status_desc       := 'New Phone not in DB'
                                ;

        insert_imei_mismatch( i_imei_rec   =>  l_imei_rec   ,
                              o_error_code =>  o_error_code ,
                              o_err_msg    =>  o_err_msg
                            );

        RETURN;
    END IF;

    l_iteration_count := l_iteration_count + 1;  --5
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --Verify If there exists ESN sub brands, if then compare sub Brands of old and new ESNs.
    IF l_old_esn_sub_brand IS NOT NULL THEN

        IF l_old_esn_sub_brand <> NVL(l_new_esn_sub_brand, 'X') THEN

            IF l_new_esn_sub_brand IS NOT NULL THEN
                l_imei_rec.old_esn_brand := l_imei_rec.old_esn_brand||l_char||l_old_esn_sub_brand;
                l_imei_rec.new_esn_brand := l_imei_rec.new_esn_brand||l_char||l_new_esn_sub_brand;
                l_imei_rec.status_desc   := 'New Phone Brand not Eligible';
            ELSE
                l_imei_rec.old_esn_brand := l_imei_rec.old_esn_brand||l_char||l_old_esn_sub_brand;
                l_imei_rec.status_desc := 'New Phone Brand not Eligible';
            END IF; --IF l_new_esn_sub_brand IS NOT NULL THEN


            insert_imei_mismatch( i_imei_rec   =>  l_imei_rec   ,
                                  o_error_code =>  o_error_code ,
                                  o_err_msg    =>  o_err_msg
                                );
            RETURN;

        END IF; --IF l_old_esn_sub_brand <> NVL(l_new_esn_sub_brand, 'X') THEN

    END IF; --IF l_old_esn_sub_brand IS NOT NULL THEN

    --Verify If there exists sub brands both old and new ESNs.
    IF l_old_esn_sub_brand IS NOT NULL
    	AND l_new_esn_sub_brand IS NOT NULL THEN

	l_imei_rec.old_esn_brand := l_imei_rec.old_esn_brand||l_char||l_old_esn_sub_brand;
	l_imei_rec.new_esn_brand	:= l_imei_rec.new_esn_brand||l_char||l_new_esn_sub_brand;

    END IF;

    l_iteration_count := l_iteration_count + 1;  --6
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --Verify Brands of old and new ESNs.
    IF NVL(l_imei_rec.old_esn_brand,'X') <> NVL(l_imei_rec.new_esn_brand, 'X') THEN

        l_imei_rec.status_desc       := 'New Phone Brand not Eligible';

            insert_imei_mismatch( i_imei_rec   =>  l_imei_rec   ,
                                  o_error_code =>  o_error_code ,
                                  o_err_msg    =>  o_err_msg
                                );

        RETURN;
    END IF;

    l_iteration_count := l_iteration_count + 1;  --7
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --Verify old and new ESNs with the valid status for device change Update.
    IF (NVL(l_imei_rec.old_esn_status, '0') <> '52'
        OR NVL(l_imei_rec.new_esn_status, '0') NOT IN ('50' , '51', '54', '150') ) THEN

        l_imei_rec.status_desc       :=  'New Phone Status not Eligible' ;

            insert_imei_mismatch( i_imei_rec   =>  l_imei_rec   ,
                                  o_error_code =>  o_error_code ,
                                  o_err_msg    =>  o_err_msg
                                );

        RETURN;
    END IF;

    l_iteration_count := l_iteration_count + 1;  --8
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --Verify nap_digital with the new_esn info.
    BEGIN
        sa.nap_digital( p_zip                => l_imei_rec.zipcode,
                        p_esn                => l_imei_rec.new_esn,
                        p_commit             => 'N',
                        p_language           => 'English',
                        P_SIM                => l_imei_rec.iccid,
                        p_source             => 'API',
                        p_upg_flag           => 'N',
                        p_repl_part          => l_part_number, --op var
                        p_repl_tech          => l_repl_tech,  --op var
                        p_sim_profile        => l_sim_profile, --op var
                        p_part_serial_no     => l_part_serial_no, --op var
                        P_MSG                => l_msg, --op var
                        p_pref_parent        => l_pref_parent, --op var
                        p_pref_carrier_objid => l_pref_carrier_objid --op var
                        );

    EXCEPTION
    WHEN OTHERS THEN NULL;

        o_error_code	:=	'99';
        o_err_msg	:=	'Exception raised in nap_digital block';

    END;

    l_iteration_count := l_iteration_count + 1;  --9
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --If pref_carrier_objid is NULL, log the results.
    IF l_pref_carrier_objid IS NULL THEN

        l_imei_rec.status_desc       := 'New Phone Carrier not Eligible' ;

            insert_imei_mismatch( i_imei_rec   =>  l_imei_rec   ,
                                  o_error_code =>  o_error_code ,
                                  o_err_msg    =>  o_err_msg
                                );
    RETURN;
    END IF;

    l_iteration_count := l_iteration_count + 1;  --10
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    IF l_pref_carrier_objid IS NOT NULL
	AND l_imei_rec.new_esn_carrier IS NULL THEN
        BEGIN

            SELECT p.x_parent_name parent_name
              INTO l_imei_rec.new_esn_carrier
              FROM table_x_parent p,
                   table_x_carrier_group cg,
                   table_x_carrier c
             WHERE c.objid = l_pref_carrier_objid
               AND c.carrier2carrier_group = cg.objid
               AND cg.x_carrier_group2x_parent = p.objid;

        EXCEPTION WHEN OTHERS THEN
            l_imei_rec.new_esn_carrier := NULL;

        END;

        IF  l_imei_rec.new_esn_carrier IS NOT NULL THEN
            l_imei_rec.new_esn_carrier := cst_carrier.get_short_parent_name ( i_parent_name => l_imei_rec.new_esn_carrier );
        END IF;

        dbms_output.put_line('l_imei_rec.new_esn_carrier  => ' ||l_imei_rec.new_esn_carrier  );
        dbms_output.put_line('l_imei_rec.old_esn_carrier  => ' ||l_imei_rec.old_esn_carrier  );

        IF NVL(l_imei_rec.old_esn_carrier,'X') <> NVL(l_imei_rec.new_esn_carrier,'X') THEN

            l_imei_rec.status_desc       := 'New Phone Carrier not Eligible';

            insert_imei_mismatch( i_imei_rec   =>  l_imei_rec   ,
                                  o_error_code =>  o_error_code ,
                                  o_err_msg    =>  o_err_msg
                                );
            RETURN;
        END IF;	--IF NVL(l_old_esn_carrier,'X') <> NVL(l_new_esn_carrier,'X') THEN
    END IF; --IF l_pref_carrier_objid IS NOT NULL THEN


    l_iteration_count := l_iteration_count + 1;  --11
    dbms_output.put_line('l_iteration_count  => ' ||l_iteration_count  );

    --After all validations, log the results with the QUEUED status for old and new_esn info.
    IF l_imei_rec.old_esn IS NOT NULL
        AND l_imei_rec.new_esn IS NOT NULL
        THEN
            l_imei_rec.status_result     := 'Eligible for Update' ;
            l_imei_rec.status_desc       := 'Eligible for Update' ;
            insert_imei_mismatch( i_imei_rec  	       =>  l_imei_rec   ,
                                  o_error_code         =>  o_error_code ,
                                  o_err_msg            =>  o_err_msg
                                );
        RETURN;

    END IF;

    o_error_code	:=	'0';
    o_err_msg	    :=	'SUCCESS';

EXCEPTION
WHEN OTHERS THEN NULL;

    o_error_code	:=	'99';
    o_err_msg	:=	'Exception raised in validate_imei_mismatch proc :'||'-'||SQLERRM;

    dbms_output.put_line('ERROR_STACK: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
    dbms_output.put_line('ERROR_BACKTRACE: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

END  validate_imei_mismatch;

END imei_pkg;
/