CREATE OR REPLACE PROCEDURE sa."BILLING_RUNTIMEPROMO"
   (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_RUNTIMEPROMO														 */
/*                                                                                          	 */
/* Purpose      :   To delivers the bonus minutes associated with the program					 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   01-19-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
    p_red_code01      IN table_part_inst.x_red_code%TYPE,
    p_red_code02      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_red_code03      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_red_code04      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_red_code05      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_red_code06      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_red_code07      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_red_code08      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_red_code09      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_red_code10      IN table_part_inst.x_red_code%TYPE DEFAULT NULL,
    p_esn             IN x_program_enrolled.x_esn%TYPE,
--    p_web_user      IN table_web_user.objid%TYPE,
    p_bonus_units   OUT NUMBER,
    p_error_code    OUT NUMBER,
    p_error_message OUT varchar2
   )
   IS

   /*
        This program delivers the bonus minutes associated with the program. At any time, this expects
        upto 10 redemption cards.

        This program checks for enrollment into the program for the benefits to be delivered.

        ASSUMPTION: 1. This is called from the existing runtime package.
                    2. If a customer is enrolled into new autopay programs from the billing platform,
                       then the customer is not active in the old autopay programs.
   */


   l_part_num      table_part_num.objid%TYPE;       -- Part Number for the redemption card.
   l_max_units     table_x_promotion.x_units%TYPE := 0;
   l_units         table_x_promotion.x_units%TYPE;

   CURSOR program_bonus_c ( c_red_part_num01 NUMBER, c_red_part_num02 NUMBER, c_red_part_num03 NUMBER, c_red_part_num04 NUMBER, c_red_part_num05 NUMBER,
                            c_red_part_num06 NUMBER, c_red_part_num07 NUMBER, c_red_part_num08 NUMBER, c_red_part_num09 NUMBER, c_red_part_num10 NUMBER
                           )
   IS

         select a.REDCARD_PROMO_OBJID, b.objid, b.x_esn, b.PGM_ENROLL2SITE_PART, b.PGM_ENROLL2PART_INST, b.PGM_ENROLL2PGM_PARAMETER, null Units
         from   X_MTM_PGM_REDCARD_BONUS a,
                (
                   select objid, x_esn, PGM_ENROLL2SITE_PART, PGM_ENROLL2PART_INST, PGM_ENROLL2PGM_PARAMETER
                   from   x_program_enrolled
                   where
                    --    PGM_ENROLL2WEB_USER = c_web_user  and -- For Redemption, WebID is not known.
                          x_esn = p_esn
                   and    x_enrollment_status = 'ENROLLED'
                   and    ( x_wait_exp_date is null   or x_wait_exp_date < trunc(sysdate) )        -- Should not be in wait period.
                 ) b
         where  a.PROGRAM_PARAM_OBJID = b.PGM_ENROLL2PGM_PARAMETER
           and  a.REDCARD_PARTNUM_OBJID in
                        (
                            c_red_part_num01, c_red_part_num02, c_red_part_num03, c_red_part_num04, c_red_part_num05,
                            c_red_part_num06, c_red_part_num07, c_red_part_num08, c_red_part_num09, c_red_part_num10
                         )
           order by
                    a.REDCARD_PROMO_OBJID;

    v_program_bonus_rec     program_bonus_c%ROWTYPE;

    TYPE max_bonus_table_type is TABLE OF program_bonus_c%ROWTYPE INDEX BY BINARY_INTEGER;

    v_max_program_bonus_table   max_bonus_table_type;       -- Table holding the max. benefits for each redemption card

    v_max_program_bonus_rec program_bonus_c%ROWTYPE;         -- Record holding the program that gives max. bonus

    l_red_part_num01    NUMBER;
    l_red_part_num02    NUMBER;
    l_red_part_num03    NUMBER;
    l_red_part_num04    NUMBER;
    l_red_part_num05    NUMBER;
    l_red_part_num06    NUMBER;
    l_red_part_num07    NUMBER;
    l_red_part_num08    NUMBER;
    l_red_part_num09    NUMBER;
    l_red_part_num10    NUMBER;


    ---- indexing variables
    l_table_index               NUMBER := 0;
    l_current_redcard_objid     NUMBER := 0;

    ---- Total Benefits
    l_total_bonus_units         NUMBER := 0;

BEGIN
    p_bonus_units := 0;

    l_red_part_num01 := BILLING_GETREDEEMPARTOBJID ( p_red_code01 );

    if ( p_red_code02 is not null ) then
            l_red_part_num02 := BILLING_GETREDEEMPARTOBJID ( p_red_code02 );
    end if;
    if ( p_red_code03 is not null ) then
            l_red_part_num03 := BILLING_GETREDEEMPARTOBJID ( p_red_code03 );
    end if;
    if ( p_red_code04 is not null ) then
            l_red_part_num04 := BILLING_GETREDEEMPARTOBJID ( p_red_code04 );
    end if;
    if ( p_red_code05 is not null ) then
            l_red_part_num05 := BILLING_GETREDEEMPARTOBJID ( p_red_code05 );
    end if;
    if ( p_red_code06 is not null ) then
            l_red_part_num06 := BILLING_GETREDEEMPARTOBJID ( p_red_code06 );
    end if;
    if ( p_red_code07 is not null ) then
            l_red_part_num07 := BILLING_GETREDEEMPARTOBJID ( p_red_code07 );
    end if;
    if ( p_red_code08 is not null ) then
            l_red_part_num08 := BILLING_GETREDEEMPARTOBJID ( p_red_code08 );
    end if;
    if ( p_red_code09 is not null ) then
            l_red_part_num09 := BILLING_GETREDEEMPARTOBJID ( p_red_code09 );
    end if;
    if ( p_red_code10 is not null ) then
            l_red_part_num10 := BILLING_GETREDEEMPARTOBJID ( p_red_code10 );
    end if;


    /* Check if the customer is enrolled into any autopay programs which has bonus for the given redemption card*/
    dbms_output.put_line('Redemption Card objids : ' || to_char(l_red_part_num01) );

    OPEN  program_bonus_c(   l_red_part_num01, l_red_part_num02, l_red_part_num03, l_red_part_num04, l_red_part_num05,
                             l_red_part_num06, l_red_part_num07, l_red_part_num08, l_red_part_num09, l_red_part_num10);   --,    p_web_user); //WebUserId is not known
    LOOP
        FETCH program_bonus_c INTO v_program_bonus_rec;
        EXIT WHEN program_bonus_c%NOTFOUND;
        dbms_output.put_line('Fetched Redemption Promocode : ' || v_program_bonus_rec.REDCARD_PROMO_OBJID);

        -- Table Index processing
        if ( l_current_redcard_objid != v_program_bonus_rec.REDCARD_PROMO_OBJID ) then
            l_table_index := l_table_index + 1;
            v_max_program_bonus_table ( l_table_index ) := v_program_bonus_rec;
            l_max_units := 0;
            dbms_output.put_line('Processing over for ' || v_program_bonus_rec.objid );
        end if;

        -- Get the details for the promocode. The only check that needs to be made is the expiry dates.
        -- Get the promo that gives the max. benefits in terms of units.
        BEGIN
            select X_UNITS
            into   l_units
            from   table_x_promotion
            where  objid = v_program_bonus_rec.REDCARD_PROMO_OBJID
              and  sysdate between x_start_date and x_end_date;

            dbms_output.put_line('Got units ' || to_char(l_units) || ' Current max units ' || to_char(l_max_units) || 'ESN : ' || v_program_bonus_rec.x_esn  );
            if ( l_units > l_max_units ) then
                    l_max_units := l_units;
                    v_program_bonus_rec.units := l_units;
                    v_max_program_bonus_table(l_table_index) := v_program_bonus_rec;
            end if;

         EXCEPTION
                WHEN NO_DATA_FOUND then
                    NULL;           --- Do nothing.. We are trying to find the max units.
        END;

    END LOOP;
    CLOSE program_bonus_c;

    if (l_table_index = 0 ) then
        p_error_code := 8002;
        p_error_message := 'No bonus redemption records available';
        return;
    end if;


    ------- For all the items in the array list, delivery the bonus minutes.
    FOR i in 1 .. l_table_index LOOP
        insert into x_program_error_log ( x_source, x_error_msg, x_description )
        values ( 'BILLING_RUNTIMEPROMO','Runtime','Inserting promocode ' || to_char(v_max_program_bonus_table(i).REDCARD_PROMO_OBJID) || ' into table_pending_redemption');

        ------- Insert the record into table_x_pending_redemption.
        insert into table_x_pending_redemption ( objid, PEND_RED2X_PROMOTION, X_PEND_RED2SITE_PART, X_PEND_TYPE )
        values ( SEQ('x_pending_redemption'),
                 v_max_program_bonus_table(i).REDCARD_PROMO_OBJID,
                 v_max_program_bonus_table(i).PGM_ENROLL2SITE_PART,
                 'BPRedemption'
                );
        --- BPBonusRedemption is put for testing purposes only. TODO: Move to the regular status later.

       INSERT INTO table_x_promo_hist
                     (objid,
                      promo_hist2x_promotion)
              VALUES (seq ('x_promo_hist'),
                      v_max_program_bonus_table(i).REDCARD_PROMO_OBJID) ;

        l_total_bonus_units := l_total_bonus_units + v_max_program_bonus_table(i).Units;

    END LOOP;



    /* As per discussion with Ashutosh, this is not required in Runtime promo.
    ------- If the phone is OTA Enabled, drop record into table_x_gencode.
    if ( BILLING_ISOTAENABLED(v_max_program_bonus_rec.x_esn) = 1 ) then
        dbms_output.put_line('Dropping record into x_program_gencode for ESN ' ||v_max_program_bonus_rec.x_esn );
        insert into x_program_gencode ( objid, x_esn, x_insert_date, x_status )
                  values ( billing_seq('x_program_gencode'), v_max_program_bonus_rec.x_esn, sysdate, 'INSERTED');

    end if;
    */
    commit;
    p_error_code := 0;
    p_error_message := 'Your most recent airtime redemption has qualified you for promotions.' || l_total_bonus_units || 'free units have been added to your phone.' ;
    p_bonus_units := l_total_bonus_units;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_error_code := 8001;
        p_error_message := 'Redemption card is not valid';
            insert into x_program_error_log ( x_source, x_description )
            values ( 'BILLING_RUNTIMEPROMO','No data found error' );

        return;
    WHEN OTHERS THEN
        p_error_code := -100;
        p_error_message := sqlcode || substr(sqlerrm,1,100);--'Database Error';
            insert into x_program_error_log ( x_source, x_description )
            values ( 'BILLING_RUNTIMEPROMO',p_error_message );

        --rollback;
        return;
END; -- Procedure BILLING_RUNTIMEPROMO
/