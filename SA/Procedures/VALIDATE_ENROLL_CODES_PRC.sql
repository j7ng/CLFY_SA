CREATE OR REPLACE PROCEDURE sa."VALIDATE_ENROLL_CODES_PRC" (
                            P_enroll_code in varchar2,
                            P_esn in varchar2,
                            p_source_system in varchar2,
                            p_program_type in varchar2,
                            p_language in varchar2 DEFAULT 'English',
                            P_error out integer,
                            P_promo_message out varchar2,
                            p_amount out varchar2

)
IS

 /*****************************************************************
  * Package Name: VALIDATE_ENROLL_CODE_PRC
  * Description : The package is called from the Web/IVR to check if the user qualifies
  *               for a zero enrollment fee while registering to Autopay/Hrbrid/Deactivation
  *               programs
  *
  * Created by  : TCS
  * Date        :  07/02/2002
  * History     :
  *********************************************************************/
  CURSOR promotion_c IS
  SELECT *
    FROM table_x_promotion
   WHERE x_promo_code = p_enroll_code
     AND x_promo_type = 'Enrollment';

  v_promo_message  varchar2(255);
  v_site_objid     number;
  v_promo_rec      promotion_c%ROWTYPE;
  v_sql_text long;
  v_cursorid integer;
  v_bind_var varchar2(50) ;
  v_chars varchar2(10);
  v_rc integer;
  v_amount number(10,2);

BEGIN
     p_amount := 0;
     p_error := '0';
     --Check that the ESN is valid
     BEGIN
          SELECT objid
            INTO v_site_objid
            FROM table_site_part
           WHERE x_service_id = p_esn
             AND part_status = 'Active';
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
           p_error := '1';
           p_promo_message := 'Esn '||p_esn || ' not found';
           RETURN;
     END;

     --Get the promotion record
     OPEN promotion_c;
     FETCH promotion_c INTO v_promo_rec;

     IF promotion_c%NOTFOUND THEN
        p_error := '2';
        p_promo_message := 'Promo Code '||p_enroll_code || ' not found';
        RETURN;
     END IF;

     CLOSE promotion_c;

     --Check if the promotion code is valid today
     IF sysdate NOT BETWEEN v_promo_rec.x_start_date AND v_promo_rec.x_end_date
     THEN
         p_error := '3';
         p_promo_message := 'This Promotional code is not available at this time';
         RETURN;
     END IF;

     --All other checks will be made using the x_sql_statement column
     --Run this SQL and check if any rows are returned. If so, the ESN
     --qualified for the promo code
     v_sql_text := v_promo_rec.x_sql_statement;
     IF v_sql_text IS NOT NULL THEN
	      BEGIN
	           v_cursorid := dbms_sql.open_cursor;

	  	dbms_sql.parse(v_cursorid,v_sql_text ,dbms_sql.v7);
  	       v_bind_var := ':esn';


             IF nvl(instr(v_sql_text,v_bind_var),0) > 0 THEN
          	    dbms_sql.bind_variable(v_cursorid,rtrim(ltrim(v_bind_var)),p_esn);
             END IF;


	  	       v_bind_var := ':source_system';
             IF nvl(instr(v_sql_text,v_bind_var),0) > 0 THEN
          	    dbms_sql.bind_variable(v_cursorid,rtrim(ltrim(v_bind_var)),p_source_system);

           END IF;



             v_bind_var := ':program_type';

             IF nvl(instr(v_sql_text,v_bind_var),0) > 0 THEN

          	    dbms_sql.bind_variable(v_cursorid,rtrim(ltrim(v_bind_var)),p_program_type);
             END IF;

             v_rc:=dbms_sql.execute(v_cursorid);
	           IF ( dbms_sql.fetch_rows(v_cursorid) <= 0) then
		            p_error := '4';
                p_promo_message := 'You do not qualify for this Promotion';
                RETURN;
	           END IF;
             dbms_sql.close_cursor(v_cursorid);
	      EXCEPTION
	      WHEN others THEN
		         IF dbms_sql.is_open(v_cursorid) THEN
	      		    dbms_sql.close_cursor(v_cursorid);
	           END IF;
	           p_error := '5';

             p_promo_message := 'Could not open cursor';

             RETURN;
        END;
     END IF;

     --The ESN qualified for the promotion code, return the promotional text in English/Spanish
     p_error := '0';
     v_amount := v_promo_rec.x_dollar_retail_cost;
     p_amount := v_amount;
     IF p_language = 'English' THEN
        p_promo_message := v_promo_rec.x_promotion_text;
     ELSE
     --This will be changed to the column for Spanish text later.
        p_promo_message := v_promo_rec.x_promotion_text;
     END IF;
END;
/