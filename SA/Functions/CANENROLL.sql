CREATE OR REPLACE FUNCTION sa."CANENROLL" (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   CANENROLL                                                  */
/*                                                                                            */
/* Purpose      :   Validates for enrollment                                      */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*  1.1      03/14/2007 Ramu         Added Changes for BP Customer One Time Programs          */
/*  1.2/1.3  05/15/08   VAdapa       Merged TF_REL_04 changes with the production copy
/*                                   as of 05/15/08                                              */
/*                      Ramu      Added comments for new exceptions being handled          */
/*                          and changed cursor program_already_enrolled_cur          */
/*                          to optimize it.
/*  1.4/1.5/1.6      07/01/08   Ramu/Nabil   NET10 Unlimited Changes                                  */
/*  1.7/1.8                     Ramu         CR7326                                     */
/*1.9                       12/10/09         CR11593 No need to execute step 1C
/*************************************************************************************************/
   p_web_user            IN   NUMBER,                           -- Web User Id
   p_esn                 IN   VARCHAR2,
                                       -- ESN Number attempting the enrollment
   p_program_to_enroll   IN   NUMBER,      -- program objid in which to enroll
   p_check_esn_flag      IN   NUMBER
         DEFAULT 0 -- Value whether to check the ESN level restrictions or not
)
   RETURN NUMBER
IS
   /* Return values:
           status_id: This sends the current status of the phone (+ve) number
           8001     : ESN is prevented from future enrollment
           8002     : Carrier market restricted / not permitted
           8003     : Carrier parent restricted / not permitted
           8004     : Handset restricted / not permitted
           8005     : Technology not permitted
           8006     : Program in which enrollment is attempted does not exist
           8007     : This ESN is in cooling period
           8008     : ESN is not valid
           -100     : Current ESN status does not permit enrollment
           8009     : ESN Part Status is not active. (This should not occur typically)
        8010     : ESN status NEW not allowed by the program
           8011     : ESN status PASTDUE not allowed by the program
           8012     : ESN is not a valid NET10 ESN
           8013     : ESN is transferred out. Program enrollments not possible.
           8014     : ESN has pending OTA transactions. Enrollment prevented.
           8015     : This ESN is not OTA Enabled.
           8016     : This ESN or Carrier is not OTA Enabled.
           8017     : This ESN is not in valid membership group
   */

   /* Error Codes:
         7501            : This customer's group enrollment is being processed.  Additional serial numbers cannot be added until the enrollment is completed.
         7502            : This customer is already enrolled in this program
         7503            : This customer cannot be enrolled in both programs at the same time.  They are not combinable.
         7504            : This program cannot be combined with another program
         7505            : This program cannot be combined with another program
         7506            : This secondary serial number can be added once the primary serial number is enrolled
         7507            : This enrollment cannot be processed.  The customer has reached the maximum amount of phones that is allowed for enrollment.
         7508            : 'Additional phone not in the enrollment window'
         7509            : The customer has reached the maximum amount of times that they can be enrolled in the same program at the same time.
         7510            : This additional phone cannot be enrolled at this time.  The customer may call to enroll 3 days before or 3 days after their next payment.
         7511            : 'This ESN is still receiving benefits. Cannot enroll'
       7512            :  This ESN is not enrolled in any ValuePlan/ Autopay. Cannot Enroll
       7513            :  This ESN is not enrolled in Unlimited Plan. Cannot Enroll
       --7514            :  This ESN is still receiving NET10 Unlimited plan benefits. Cannot Enroll
            1            : 'Primary phone for the group is not available. Add this phone as primary'
            1            : 'OK to enroll as primary (first enrollment)'
            2            : 'OK to enroll as primary (second enrollment)'
            3            : 'Primary phone for the group is "Enrolled" status. Add this phone as secondary. This is after the cycle date'
            4            : 'Primary phone for the group is "Enrolled" status. Add this phone as secondary. This is before the cycle date'
     */
   v_no_of_additional_phones   NUMBER;
   v_no_of_phones_enrolled     NUMBER;
   v_count                     NUMBER;
   v_combine_self_flag         NUMBER;
   v_combine_others_flag       NUMBER;
   v_addtional_esn_allowed     NUMBER;
   v_program_type              VARCHAR2 (10);            -- INDIVIDUAL, GROUP
   v_permitted_list            VARCHAR2 (4000);
                    -- a string holding all the objids of combinable programs
   v_already_enrolled          NUMBER          := 1; -- By default - enrolled
   v_temp_program_id           VARCHAR2 (100);
   l_next_charge_date          DATE;
   l_prev_charge_date          DATE;
   l_add_phone_window          NUMBER;             -- Additional phone window
   l_primary_program_id        NUMBER;       -- Program ID of the primary ESN
   l_bus_org                   NUMBER;
   l_error_flag                NUMBER;
   l_error_message             VARCHAR2 (255);
   bp_counter                  NUMBER          := 0;
                                    -- Added for BPCustomer One Time Programs
   enroll_bp_counter           NUMBER          := 0;
                                    -- Added for BPCustomer One Time Programs

/*
  CURSOR fetch_enrolled_programs_by_esn ( c_esn IN NUMBER  ) IS
    select

  */
   CURSOR combinable_with_others_cur (c_program_id IN NUMBER)
   IS
      /* If program A is combinable with 'B', we are not assuming that 'B' is automatically
         combinable with 'A' */
      SELECT TO_CHAR (program_param_objid)              --pgm_parameter_objid
        FROM x_mtm_program_combine
       WHERE program_combine_objid = c_program_id
      UNION
      SELECT TO_CHAR (program_combine_objid)
        FROM x_mtm_program_combine
       WHERE program_param_objid = c_program_id
      --3rd union added for Net10 Unlimited Plan
      UNION
      SELECT TO_CHAR (x_program_parameters.objid)
        FROM x_program_enrolled INNER JOIN x_program_parameters
             ON (pgm_enroll2pgm_parameter = x_program_parameters.objid)
       WHERE x_combine_self > 0 AND x_esn = p_esn;

   /* Fetch the program ids of all the enrolled program */
   CURSOR program_already_enrolled_cur (c_esn IN VARCHAR2)
   IS
      SELECT TO_CHAR (pgm_enroll2pgm_parameter)
        FROM x_program_enrolled
       WHERE x_esn = c_esn
         AND x_enrollment_status IN
                ('ENROLLED',
                 'SUSPEND',
                 'ENROLLMENTSCHEDULED',
                 'ENROLLMENTPENDING'
                );
/* Fetch the program ids of all the enrolled program */
BEGIN
   -- STEP 0: Check esn status flags
   IF (p_check_esn_flag <> 0)
   THEN
      -- Call the ESN status check procedure
      esn_status_enroll_eligible (p_program_to_enroll,
                                  p_esn,
                                  p_web_user,
                                  l_error_flag,
                                  l_error_message
                                 );

      -- Error codes are 8001 to 8016 / -100 / current status code
      IF (l_error_flag <> 0)
      THEN
         RETURN l_error_flag;
      END IF;
   END IF;

-- STEP 1:
---------------------------------------------------------------------------------------------------------
/* Fetch all the records for the given ESN and program. If any of the statuses of the program
   is not in favorable state, reject this new enrollment */

   -- objid, program_enroll2web_user, x_esn, x_enrollment_status
   SELECT COUNT (*)
     INTO v_count
     FROM x_program_enrolled
    WHERE x_esn = p_esn
      AND pgm_enroll2pgm_parameter = p_program_to_enroll
      AND x_enrollment_status IN
                    ('SUSPENDED', 'ENROLLMENTPENDING', 'ENROLLMENTSCHEDULED');

   /* If even one record comes up with the status in these, reject the new enrollment being requested */
   IF (v_count <> 0)
   THEN
      RETURN 7501;
   END IF;

   -- Check if the ESN is still receiving benefits.
   -- Check if the ESN is still receiving benefits.
   SELECT COUNT (*)
     INTO v_count
     FROM x_program_enrolled
    WHERE x_esn = p_esn
      AND pgm_enroll2pgm_parameter = p_program_to_enroll
      AND x_enrollment_status IN ('DEENROLLED')
      AND pgm_enroll2web_user = p_web_user
      AND x_tot_grace_period_given = 1;

   /* If even one record comes up with the status in these, reject the new enrollment being requested */
   IF (v_count <> 0)
   THEN
      RETURN 7511;                               -- Still receiving benefits.
   END IF;

/*  ------------------------------------------------------------------------------------------------------
     Step 1A: For New BP Customer Changes .... Ramu 03/14/2007
*/  ------------------------------------------------------------------------------------------------------
   SELECT COUNT (*)
     INTO bp_counter
     FROM x_mtm_permitted_esnstatus
    WHERE program_param_objid = p_program_to_enroll
      AND esn_status_objid IN (SELECT objid
                                 FROM table_x_code_table
                                WHERE x_code_name IN ('BP CUSTOMER'));

   -- If this is a regular Bundle
   IF (bp_counter <> 0)
   THEN
      SELECT COUNT (*)
        INTO enroll_bp_counter
        FROM x_program_enrolled enroll, x_program_parameters param
       WHERE enroll.x_esn = p_esn
         AND enroll.pgm_enroll2web_user = p_web_user
         AND enroll.pgm_enroll2pgm_parameter = param.objid
         AND (   param.x_prog_class IS NULL
              OR param.x_prog_class NOT IN ('UNLIMITED', 'ULBUNDLE')
             )
         AND enroll.x_enrollment_status IN
                     ('ENROLLED', 'ENROLLMENTPENDING', 'ENROLLMENTSCHEDULED');

      IF (enroll_bp_counter = 0)
      THEN
         RETURN 7512;
      END IF;
   END IF;

 /*  ------------------------------------------------------------------------------------------------------
     Step 1B: For Net10 Unlimited Changes .... Ramu 06/25/2008
*/  ------------------------------------------------------------------------------------------------------
   SELECT COUNT (*)
     INTO bp_counter
     FROM x_mtm_permitted_esnstatus
    WHERE program_param_objid = p_program_to_enroll
      AND esn_status_objid IN (SELECT objid
                                 FROM table_x_code_table
                                WHERE x_code_name IN ('NTUMP CUSTOMER'));

   -- if this is a Net10 Unlimited Bundle
   IF (bp_counter <> 0)
   THEN
      SELECT COUNT (*)
        INTO enroll_bp_counter
        FROM x_program_enrolled enroll, x_program_parameters param
       WHERE enroll.x_esn = p_esn
         AND enroll.pgm_enroll2web_user = p_web_user
         AND enroll.pgm_enroll2pgm_parameter = param.objid
         AND param.x_prog_class = 'UNLIMITED'
         AND x_enrollment_status IN ('ENROLLED');

      IF (enroll_bp_counter = 0)
      THEN
         RETURN 7513;
      END IF;
   END IF;

/*
  ------------------------------------ END OF STEP 1A ----------------------------------------------------
*/
--CR11593 No need to execute this step
--  /*  ------------------------------------------------------------------------------------------------------
--      Step 1C: For Net10 Unlimited Changes .... Ramu 07/15/2008
-- */  ------------------------------------------------------------------------------------------------------
--    SELECT COUNT (*)
--      INTO v_count
--      FROM table_site_part
--     WHERE x_service_id = p_esn
--       AND part_status || '' = 'Active'
--       AND site_part2x_plan IN (SELECT objid
--                                  FROM table_x_click_plan
--                                 WHERE x_click_type = 'UNLIMITED')
--       AND EXISTS (
--              SELECT 1
--                FROM x_program_enrolled enroll, x_program_parameters param
--               WHERE x_esn = p_esn
--                 AND x_enrollment_status IN ('DEENROLLED', 'READYTOREENROLL')
--                 AND param.x_prog_class = 'UNLIMITED'
--                 AND param.objid = enroll.pgm_enroll2pgm_parameter);

--    IF (v_count <> 0)
--    THEN
--       RETURN 7514;
--    END IF;

--    /*
--      ------------------------------------ END OF STEP 1C ----------------------------------------------------
   --*/
   --CR11593 No need to execute this step

   /* ---------------------------------------------------------------------------------------------------------
       Get the program definition parameters. ( CombineWithSelf, GroupProgram )
   */
   SELECT x_type, x_combine_self, x_combine_other,
          x_grp_esn_count, x_add_ph_window, prog_param2bus_org
     INTO v_program_type, v_combine_self_flag, v_combine_others_flag,
          v_addtional_esn_allowed, l_add_phone_window, l_bus_org
     FROM x_program_parameters
    WHERE objid = p_program_to_enroll;

   /*
   STEP 2: If any one row returns 'ENROLLED', the customer is assumed to be already enrolled into the program
   ----------------------------------------------------------------------------------------------------------
       NOTE: Needs some modifications. To be revisited later.
   */
   SELECT COUNT (*)
     INTO v_count
     FROM x_program_enrolled
    WHERE x_esn = p_esn
      AND pgm_enroll2pgm_parameter = p_program_to_enroll
      AND x_enrollment_status IN ('ENROLLED');

   /* If even one record comes up with the status in these, reject the new enrollment being requested */
   IF (v_count = 0)
   THEN
      /* Customer is not enrolled */
      v_already_enrolled := 0;
   ELSE
      /* Since the customer is already enrolled, check for combine with self flag for the program */
      IF (NVL (v_combine_self_flag, 0) = 0)
      THEN                                    -- cannot be combined with self
         RETURN 7502;
      ELSIF (v_count >= v_combine_self_flag)
      THEN           -- Check if we have reached the max comb. with self count
         RETURN 7509;
-- This program does not allow combinable with self more than v_combine_self times
      END IF;

      IF (v_program_type = 'GROUP')
      THEN
         RETURN 7503;
      END IF;

      IF (v_combine_others_flag = 0)
      THEN                        -- cannot be combined with any other program
         RETURN 7504;
      END IF;
   END IF;

   /*
   STEP 3: Get the list of other programs by ESN, enrolled. Check for combinable with the program set.
   ----------------------------------------------------------------------------------------------------------
   Logic: Get all the permitted enrollment programs into a string.
          Fetch the enrolled records and check for the existance of the program in the permitted list
   */
   DBMS_OUTPUT.put_line ('Before combinable program check');

   ---  Get the list of allowed combinable program
   OPEN combinable_with_others_cur (p_program_to_enroll);

   LOOP
      FETCH combinable_with_others_cur
       INTO v_temp_program_id;

      EXIT WHEN combinable_with_others_cur%NOTFOUND;
      v_permitted_list := v_permitted_list || ',' || v_temp_program_id;
   END LOOP;

   CLOSE combinable_with_others_cur;

        -- At this time, v_permitted list can either be null, or has a list
--        dbms_output.put_line( 'Permitted Enrollment Programs :: ' || substr(v_permitted_list,1,255) );

   --- Get the list of other programs already enrolled by ESN
   --- Even if one program says cannot be combined with others - reject
   SELECT COUNT (*)
     INTO v_count
     FROM x_program_parameters
    WHERE objid IN (
             SELECT pgm_enroll2pgm_parameter
               FROM x_program_enrolled
              WHERE x_esn = p_esn
                AND pgm_enroll2web_user = p_web_user
                AND x_enrollment_status IN
                       ('ENROLLED',
                        'SUSPENDED',
                        'ENROLLMENTPENDING',
                        'ENROLLMENTSCHEDULED'
                       )
                AND prog_param2bus_org = l_bus_org)
      AND x_combine_other = 0;

--          dbms_output.put_line(v_permitted_list || ' : ' || to_char(v_count));
   IF ((v_count > 0) AND (v_permitted_list IS NULL))
   THEN
      DBMS_OUTPUT.put_line
                 ('Other program has cannot be combined with other flag set ');
      l_error_flag := 7505;
      RETURN l_error_flag;
   END IF;

   l_error_flag := 0;

   OPEN program_already_enrolled_cur (p_esn);

   LOOP
      FETCH program_already_enrolled_cur
       INTO v_temp_program_id;

      EXIT WHEN program_already_enrolled_cur%NOTFOUND;
      -- check if the program id fetched, exists in the program list defined above (v_permitted_list)
      DBMS_OUTPUT.put_line (   'Check for program id: '
                            || v_temp_program_id
                            || INSTR (v_permitted_list, v_temp_program_id)
                           );

      IF (INSTR (v_permitted_list, v_temp_program_id) = 0)
      THEN
          -- error condition :: program cannot be combined
         --the following was commented out for Net10 Unlimited Plan 6/24/08
         --if(v_combine_self_flag =0) then
         l_error_flag := 7505;
         --end if;
         EXIT;
      END IF;
   END LOOP;

   CLOSE program_already_enrolled_cur;

   DBMS_OUTPUT.put_line ('After checking for already enrolled');

   IF (l_error_flag <> 0)
   THEN
      RETURN l_error_flag;
   END IF;

   -- OK to proceed.
   IF (v_already_enrolled = 1)
   THEN
      RETURN 2;
   END IF;

   DBMS_OUTPUT.put_line ('Group program check');

   IF (v_program_type = 'GROUP')
   THEN
      /* Get the primary enrollment record for the given webaccount/program.
          Check the status for valid enrollment.
          if OK, enroll as additional */

      /* BUG: Check if there is at least one program in enrolled status */
      SELECT COUNT (*)
        INTO v_count
        FROM x_program_enrolled
       WHERE pgm_enroll2web_user = p_web_user
         AND pgm_enroll2pgm_parameter = p_program_to_enroll
         AND x_is_grp_primary = 1
         AND x_enrollment_status IN ('ENROLLED');

      IF (v_count = 0)
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM x_program_enrolled
          WHERE pgm_enroll2web_user = p_web_user
            AND pgm_enroll2pgm_parameter = p_program_to_enroll
            AND x_is_grp_primary = 1
            AND x_enrollment_status IN
                    ('SUSPENDED', 'ENROLLMENTPENDING', 'ENROLLMENTSCHEDULED'
                                                                            --,'DEENROLLED'     //Bug 752
                    );

         IF (v_count <> 0)
         THEN
            RETURN 7506;
         END IF;
      END IF;

      DBMS_OUTPUT.put_line ('Group program - checking for before/after ');

      -- Since we are not checking count(*), there will be an exception raised where there are no
      -- records found. So put this into a block
      BEGIN
         SELECT x_charge_date, x_next_charge_date
           INTO l_prev_charge_date, l_next_charge_date
           FROM x_program_enrolled
          WHERE pgm_enroll2web_user = p_web_user
            AND pgm_enroll2pgm_parameter = p_program_to_enroll
            AND x_is_grp_primary = 1
            AND x_enrollment_status IN ('ENROLLED');
                                             --Only 0/1 record will be present
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
-- any exception raised here, typically there would be no record. allow primary enrollment
            RETURN 1;                             -- allow primary enrollment
         WHEN OTHERS
         THEN
-- More than one record found with primary for the enrollment.
-- This should not occur typically. However, incase of combinable with self, this situation may occur.
            NULL;       -- Do not do anything .. continue further processing.
      END;

      DBMS_OUTPUT.put_line ('Group program - after checking for before/after ');

      IF (SQL%ROWCOUNT <> 0)
      THEN      -- Primary program found in the enrolled state. Check further.
         -- Check if we have reached the max. number of additional phones
         DBMS_OUTPUT.put_line
                          ('Group program - check for Max. Additional Phone ');

         SELECT COUNT (*)
           INTO v_count
           FROM x_program_enrolled
          WHERE pgm_enroll2web_user = p_web_user
            AND pgm_enroll2pgm_parameter = p_program_to_enroll
            AND x_is_grp_primary = 0
            AND x_enrollment_status IN
                     ('ENROLLED', 'ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING');

         DBMS_OUTPUT.put_line (   'Group program - Phones Allowed '
                               || TO_CHAR (v_addtional_esn_allowed)
                               || '. Currently Enrolled: '
                               || TO_CHAR (v_count)
                              );

         IF (v_addtional_esn_allowed > v_count)
         THEN
-- Check for additional enrollment window.
------------------------------------------------------------------------------------------------------
            IF (l_add_phone_window IS NOT NULL)
            THEN
               -- Check with the next enrollment date
               IF ((l_next_charge_date - l_add_phone_window) < SYSDATE)
               THEN
                  -- Before the next cycle date. OK
                  RETURN 4;
                  -- OK to enroll as additional phone. Before the cycle date.
               ELSE
                  IF (l_prev_charge_date < SYSDATE)
                  THEN               -- Sanity check for data inconsistencies
                     IF ((l_prev_charge_date + l_add_phone_window) > SYSDATE
                        )
                     THEN
                        -- Prev cycle has just passed. Allow enrollment
                        RETURN 3;
                   -- OK to enroll as additional phone. After the cycle date.
                     ELSE
                        RETURN 7508;              -- Not in enrollment window
                     END IF;
                  END IF;
               END IF;
            ELSE
               RETURN 7510;
-- Phone can be enrolled. However, no enrollment window specified for the program.
            END IF;

----------------------------------------------------------------------------------------------------------
            RETURN 7508;                           -- Not in enrollment window
         ELSE
            RETURN 7507;
                  -- Max. number of additional phones reached. Cannot enroll.
         END IF;
      ELSE
         RETURN 1;
      END IF;
   ELSE
      RETURN 1;
   END IF;

   RETURN -100;                            -- This condition should not occur.
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM);
      RETURN -100;                        -- This condition should not occur.
END;                                                     -- Function CANENROLL
/