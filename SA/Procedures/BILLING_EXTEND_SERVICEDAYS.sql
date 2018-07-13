CREATE OR REPLACE PROCEDURE sa."BILLING_EXTEND_SERVICEDAYS"
   (
        p_esn           IN  VARCHAR2,
        p_days          IN  NUMBER,
        p_limit_days    IN  NUMBER,
        op_result       OUT NUMBER,
        op_msg          OUT VARCHAR2)
   IS
   /*
        This utility procedure extends the service days upto a max. of days specified
        in the parameter.
        This is used in cases when
                - Grace Period is extended
                - Cycle date is changed
                - There is a voluntary de-enrollment
       p_limit_days is the condition when this procedure becomes application.
       e.g. if p_limit_days < 2 then given 4 days of service.
   */
   l_result                 NUMBER;
   l_msg                    VARCHAR2(255);

   l_current_exp_date       DATE;
   l_new_exp_date           DATE;
   l_site_objid             NUMBER;

BEGIN

    /*
            Get the expiry date for the given ESN.
            This ESN has to be active, since we are trying to extend the service days
            such that it does not go past_due
    */

    BEGIN
           SELECT x_expire_dt, objid
             INTO l_current_exp_date, l_site_objid
             FROM table_site_part
            WHERE x_service_id IN (p_esn)
              AND part_status = 'Active';
     EXCEPTION
            WHEN NO_DATA_FOUND THEN
            /* -----------
                Catch the exception for only NO_DATA_FOUND
             ------------- */
                op_result := 7801;
                op_msg    := 'No record found for the given esn ' || p_esn || 'in Active State ';
                return;
     END;


    -- Validate the input parameter.
     IF ( p_days is null or p_days < 0 ) THEN
        op_result       := 7802;
        op_msg          := 'Invalid extension parameter passed for extension - ' || to_char ( p_days);
     END IF;

     /* ---
            Service days will be extended, only if it current expiry date falls within the
            number of days from now.
            Check for the limiting conditions.
     */
     /* --------- Additional assumption
            if p_limit_days is null, then assume p_days = p_limit_days
     */

     if ( l_current_exp_date < (sysdate + NVL(p_limit_days,p_days)) ) then
         l_new_exp_date := sysdate + p_days;
     end if;

     IF ( l_current_exp_date < l_new_exp_date ) THEN

            --------- Service days can be extended.-------------------------
             UPDATE table_site_part
                SET x_expire_dt = l_new_exp_date
              WHERE objid = l_site_objid;

             UPDATE table_part_inst
                SET WARR_END_DATE =  l_new_exp_date
              WHERE PART_SERIAL_NO IN ( p_esn )
                AND PART_STATUS = 'Active';
            ----------------------------------------------------------------
                 op_result := 1;
                 op_msg    := to_char(l_new_exp_date - l_current_exp_date);
     END IF;

     op_result := 0;
     op_msg    := 'No need to extend service days';

EXCEPTION
    WHEN OTHERS THEN
        op_result       := -100;
        op_msg          := 'Exception - ' || SQLERRM;
        RAISE ;
END; -- Procedure BILLING_EXTEND_SERVICEDAYS
/