CREATE OR REPLACE PROCEDURE sa."ESN_STATUS_ENROLL_ELIGIBLE" (
  /*************************************************************************************************/
  /*                                                                                            */
  /* Name         :   esn_status_enroll_eligible                                       */
  /*                                                                                            */
  /* Purpose      :   This procedures checks for the enrollment eligibility in a program.          */
  /*                                                                                            */
  /*                                                                                            */
  /* Platforms    :   Oracle 9i                                                                 */
  /*                                                                                            */
  /* Author       :   RSI                                                                          */
  /*                                                                                            */
  /* Date         :   01-19-2006                                                    */
  /* REVISIONS:                                                                              */
  /* VERSION  DATE        WHO          PURPOSE                                                  */
  /* -------  ----------  -----        --------------------------------------------             */
  /*  1.0                              Initial  Revision                                        */
  /*  1.1      04/20/2008  Ramu        Added logic for Restricting Non-OTA Phones (ESN or Carrier) */
  /*                                   CR7340 changes merged with production copy as of 05/15/08   */
  /* 1.2/1.3   07/15/08    Ramu        CR7605                                                      */
  /* 1.4/1.5               Ramu        CR7326                                                     */
  /* 1.6       08/27/09    NGuada      BRAND_SEP Separate the Brand and Source System
  /*                                   incorporate use of new table TABLE_BUS_ORG to retrieve
  /*                                   brand information that was previously identified by the fields
  /*                                   x_restricted_use and/or amigo from table_part_num
  /*1.7/1.8    09/01/09     VAdapa Latest
                                         Added comments and fixed the reference of bus_org
  /*1.2        10/03/11     PMistry    CR17003 Net10 Sprint changes for LG 45, 55 can enroll with Unlimited program only.
  /*************************************************************************************************/
     p_program_id         x_program_enrolled.pgm_enroll2pgm_parameter%TYPE,
     p_esn                x_program_enrolled.x_esn%TYPE,
     p_webuser_id         x_program_enrolled.pgm_enroll2web_user%TYPE,
     op_result      OUT   NUMBER,
     op_msg         OUT   VARCHAR2
  )
  IS
     /* Return values:
             status_id: This sends the current status of the phone (+ve) number
             8001     : This serial number is not allowed to be used in future enrollments
             8002     : This program is not being offered in the customer's coverage area
             8003     : This program is not being offered in the customer's coverage area
             8004     : The customer's phone model is not eligible to enroll in this program.
             8005     : The customer's phone model is not eligible to enroll in this program.
             8006     : Program in which enrollment is attempted does not exist
             8007     : This ESN is in cooling period
             8008     : ESN is not valid
             -100     : Any other exception
             8009     : The customer's serial number is not active.  The phone must be active in order to enroll in this program
             8010     : ESN status NEW not allowed by the program
             8011     : ESN status PASTDUE not allowed by the program
             8012     : ESN is not a valid NET10 ESN
             8013     : ESN is transferred out. Program enrollments not possible.
             8014     : ESN has pending OTA transactions. Enrollment prevented.
             8015     : This ESN is not OTA Enabled.                  -- CR7340 .. Ramu
             8016     : This ESN Carrier is not OTA Enabled.          -- CR7340 .. Ramu
             8017     : This ESN is not in required Membership Group  -- CR7326 .. Ramu
     */
     -- Sample data: ESN: 010447000635244,
     l_coll_exp_date       DATE;
     v_date                DATE                                 DEFAULT SYSDATE;
     l_count               NUMBER;
     l_esn                 VARCHAR2 (30);
     l_technology          table_part_num.x_technology%TYPE;
     l_status_objid        NUMBER;
     l_status              table_x_code_table.x_code_name%TYPE;
     l_model_objid         NUMBER;
     l_model               table_part_class.x_model_number%TYPE;

     -- BRAND_SEP
     --l_bus_org             table_part_num.x_restricted_use%TYPE;
     l_bus_org             table_bus_org.org_id%TYPE;
     -- If this is 3 then the ESN is a Net10 ESN
     l_ota_allowed         table_part_num.x_ota_allowed%TYPE; -- CR7340 .. Ramu
     v_carr_objid          NUMBER;
     v_carr_parent_objid   NUMBER;
     l_handset_value       x_program_parameters.x_handset_value%TYPE;
     l_carrmarket_value    x_program_parameters.x_carrmkt_value%TYPE;
     l_carrparent_value    x_program_parameters.x_carrparent_value%TYPE;
     l_membership_value    x_program_parameters.x_membership_value%TYPE;
     l_prog_bus_org        table_bus_org.s_name%TYPE;
     l_group_name          table_x_promotion_group.group_name%TYPE;
     l_membership_name     x_program_membership.x_membership_name%TYPE;
     l_membership_group    x_program_membership.x_membership_group%TYPE;
     l_membership_code     x_program_membership.x_membership_code%TYPE;
     V_B2B_COUNT NUMBER:=0;
  BEGIN
     /* Get the ESN properties - If no records are found here, exception raised, and return 8008.*/

     dbms_output.put_line('l_handset_value1'||l_handset_value);
     BEGIN
        SELECT phone.part_serial_no esn,
              pn.x_technology technology,
               code.objid statusobjid,
               code.x_code_name,
               model.objid modelobjid,
               model.x_model_number model,
               --pn.x_restricted_use, --BRAND_SEP
               bo.org_id, --BRAND_SEP
               NVL (pn.x_ota_allowed, 'N')        -- Modified for CR7340 .. Ramu
          INTO l_esn,
               l_technology,
               l_status_objid, l_status,
               l_model_objid, l_model,
               l_bus_org,
               l_ota_allowed
          FROM table_part_class model,
               table_part_num pn,
               table_mod_level ml,
               table_x_code_table code,
               table_part_inst phone,
               table_bus_org bo
         WHERE model.objid = pn.part_num2part_class
           AND ml.part_info2part_num = pn.objid
           AND phone.n_part_inst2part_mod = ml.objid
           AND code.objid = phone.status2x_code_table
           AND phone.part_serial_no IN (p_esn)
           AND phone.x_domain = 'PHONES'
           AND pn.part_num2bus_org=bo.objid;
     EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
           op_result := 8008;
           op_msg := 'ESN is not valid';
           RETURN;
        WHEN OTHERS
        THEN
           RAISE;
     END;
  dbms_output.put_line('l_handset_value2'||l_handset_value);
     -- New changes for CR7326 .. Ramu
     -- Checking if this ESN needs any membership validation or not
     SELECT x_membership_value
       INTO l_membership_value
       FROM x_program_parameters
      WHERE objid = p_program_id;

     IF (l_membership_value <> 'NONE')
     THEN
        BEGIN
           SELECT pg.group_name
             INTO l_group_name
             FROM table_x_group2esn ge,
                  table_part_inst pi,
                  table_x_promotion_group pg
            WHERE 1 = 1
              AND pi.part_serial_no = p_esn
              AND ge.x_end_date > SYSDATE
              AND ge.groupesn2x_promo_group = pg.objid
              AND ge.groupesn2part_inst = pi.objid
              AND EXISTS (SELECT 1
                            FROM x_mtm_program_membership
                           WHERE program_param_objid = p_program_id)
              AND ROWNUM < 2;
        EXCEPTION
           WHEN NO_DATA_FOUND
           THEN
              op_result := 8017;
              op_msg := 'ESN is not in required membership group';
              RETURN;
           WHEN OTHERS
           THEN
              RAISE;
        END;

        BEGIN
           SELECT mem.x_membership_name, mem.x_membership_group,
                  mem.x_membership_code
             INTO l_membership_name, l_membership_group,
                  l_membership_code
             FROM x_program_membership mem, x_mtm_program_membership mtm
            WHERE 1 = 1
              AND mem.x_membership_id = mtm.member_objid
              AND mtm.program_param_objid = p_program_id
              AND EXISTS (
                     SELECT 1
                       FROM x_program_parameters
                      WHERE x_membership_value <> 'NONE'
                            AND objid = p_program_id);
        EXCEPTION
           WHEN NO_DATA_FOUND
           THEN
              op_result := 8017;
              op_msg := 'ESN is not in required membership group';
              RETURN;
           WHEN OTHERS
           THEN
              RAISE;
        END;
     END IF;

     DBMS_OUTPUT.put_line (   'Retrieved : ESN => '
                           || TO_CHAR (l_esn)
                           || '  Technology => '
                           || l_technology
                           || ' Status => '
                           || l_status
                           || ' Model => '
                           || l_model
                          );

  dbms_output.put_line('l_handset_value3'||l_handset_value);
     -- Added new changes for CR7340
      -- If the restriction needed only for ESN, use the variable flag l_ota_allowed.
      -- If the restriction needed for ESN and Carrier as well, use the billing_isotaenabled() function
  /*
     IF (l_ota_allowed = 'N')
     THEN
        -- CR17003 Net10 SPRINT New android phone for Net10 spring is not ota allowed and it is the only CDMA phone right now in Net10 with ota not allowed.
        if L_TECHNOLOGY = 'CDMA' and L_BUS_ORG = 'NET10' then
            null;
        else
              op_result := 8015;                  -- This is not an OTA Enabled Phone
              op_msg := 'Your Phone Model does not allow this plan (not ota capable)';
        --BRAND_SEP
              /*IF (l_bus_org = 'NET10')
              THEN                                             -- This is a Net10 ESN
                 op_msg :=
                    'The Phone Model you are trying to enroll is not Easy Minutes Plan capable.';
              ELSE
                 op_msg :=
                    'The Phone Model you are trying to enroll is not Value Plan capable.';
              END IF;

        --BRAND_SEP
              return;
        end if;
     END IF;

     -- If the above returns 'Y', then check for carrier
     IF (billing_isotaenabled (p_esn) = 0)
     THEN
        -- CR17003 Net10 SPRINT New android phone for Net10 spring is not ota allowed and it is the only CDMA phone right now in Net10 with ota not allowed.
        if L_TECHNOLOGY = 'CDMA' and L_BUS_ORG = 'NET10' then
            null;
        else
            op_result := 8016;                -- This is not an OTA Enabled Carrier
            op_msg := 'Your phone coverage does not allow this plan (ota not available)';
            --BRAND_SEP
            /*IF (l_bus_org = 'NET10')
            THEN                                             -- This is a Net10 ESN
               op_msg := 'Your phone coverage does not provide Easy Minutes Plan';
            ELSE
               op_msg := 'Your phone coverage does not provide Value Plan';
            END IF;

            --BRAND_SEP
            return;
        end if;
     End If;
  */

     -- End of new changes for CR7340
      /*
          Get the program parameters - Hybrid Model
          Values: 'PERMITTED','RESTRICTED','NONE'
      */
      dbms_output.put_line('p_program_id'||p_program_id);
     BEGIN
        SELECT x_handset_value, x_carrmkt_value, x_carrparent_value,
               x_membership_value,
               (SELECT org_id --s_name --BRAND_SEP
                  FROM table_bus_org
                 WHERE objid = prog_param2bus_org)   --,technology is not hybrid
          INTO l_handset_value, l_carrmarket_value, l_carrparent_value,
               l_membership_value,
               l_prog_bus_org
          FROM x_program_parameters
         WHERE objid = p_program_id;
     EXCEPTION
        WHEN OTHERS
        THEN
           op_result := 8006;
           op_msg :=
                 'The program in which enrollment is attempted does not exist.';
           RETURN;
     END;

  dbms_output.put_line('l_handset_value4'||l_handset_value);
     DBMS_OUTPUT.put_line
        (   'Program Paramters retrieved(Handset,CarrierMarket,CarrierParent,BusOrg): =>'
         || l_handset_value
         || ','
         || l_carrmarket_value
         || ','
         || l_carrparent_value
         || ','
         || l_bus_org
        );
     /* Check if the ESN is a Net10 ESN and the program is a NET10 program */
     DBMS_OUTPUT.put_line ('ESN business org ' || l_bus_org);
  --BRAND_SEP
     IF l_bus_org <> l_prog_bus_org then
        op_result := 8001;
        op_msg := 'ESN and program belong to different brands ';
        RETURN;
     END IF;
     /*IF (l_bus_org = 3)
     THEN                                                 -- This is a Net10 ESN
        IF (l_prog_bus_org != 'NET10')
        THEN
           op_result := 8001;
           -- ESN is Net10 and the program trying to enroll is not NET10.
           op_msg :=
                 'ESN is Net10 ESN and the program trying to enroll is '
              || l_prog_bus_org
              || ' program.';
           RETURN;
        END IF;
     ELSE                                              -- This is a tracfone ESN
        IF (l_prog_bus_org != 'TRACFONE')
        THEN
           op_result := 8001;
           op_msg :=
                 'ESN is Tracfone ESN and the program trying to enroll is '
              || l_prog_bus_org
              || ' program.';
           RETURN;
        END IF;
     END IF;
     */
    --BRAND_SEP
    dbms_output.put_line('l_handset_value5'||l_handset_value);
     /* ------ New Requirement: 08/23/2006: Prevent Enrollment if there are any pending codes */
     SELECT COUNT (*)
       INTO l_count
       FROM table_x_ota_transaction b,
            (SELECT *
               FROM (                -- select for picking up the lastest record
                     SELECT   objid, x_action_type, x_min, x_action_text,
                              x_result
                         FROM table_x_call_trans
                        WHERE x_service_id = p_esn
  --Cr7506 07/15/08
           --    AND x_action_text IN ('ACTIVATION', 'REACTIVATION')
                          AND (x_min LIKE 'T%' OR x_result = 'OTA PENDING')
                     ORDER BY x_transact_date DESC)
              WHERE ROWNUM < 2) a
      WHERE a.objid = b.x_ota_trans2x_call_trans
        AND b.x_status IN ('OTA PENDING', 'OTA SEND')
        AND b.x_transaction_date IS NOT NULL;

     IF (l_count > 0)
     THEN
        op_result := 8014;
        --- Pending OTA transactions exist. Do not allow enrollment.
        op_msg := 'ESN has pending OTA transactions. Enrollment prevented.';
        RETURN;
     END IF;

  /* ------------------------------------------------------------------------------------- */

     /*
         if ( l_bus_org = 3 and l_prog_bus_org != 'NET10' )     then --- Net10 ESN
                                     -- Check if the program trying to Enroll is a NET10 program. Else return an error.
                 -- By default, we are assuming that the NET10 check should suffice.
         else if (  l_prog_bus_org != 'TRACFONE' ) then
              end if;
         end if;
     */
        /*
         a.   Check ESN is not in cooling period for the program
         b.   Check ESN with the status defined by the program.
           If it fails, return status of the ESN so that user can be redirected to re-activation or redemption page
         c.   Check ESN is not prevented from future enrollment
         d.   Check for Carrier, Carrier Market, Handset, technology
         */

     -- Cooling period check cannot be done at this time, since it is associated with the program.
     /*
     if ( p_webuser_id is null ) then
         select count(*) into l_count
         from   X_PROGRAM_ENROLLED
         where
     --           PGM_ENROLL2WEB_USER = p_webuser_id    and          // Bug Fix: Many times webuser id will not be available.
                  x_esn               in ( p_esn)
           and    PGM_ENROLL2PGM_PARAMETER = p_program_id
           and    x_enrollment_status in ('DEENROLLED');
     else
         select count(*) into l_count
         from   X_PROGRAM_ENROLLED
         where
                  PGM_ENROLL2WEB_USER = p_webuser_id
           and    x_esn               in ( p_esn)
           and    PGM_ENROLL2PGM_PARAMETER = p_program_id
           and    x_enrollment_status in ('DEENROLLED')
           and    x_tot_grace_period_given != 1;         -- No deenroll at cycle date flag.
     end if;
     */
     SELECT COUNT (*)
       INTO l_count
       FROM x_program_enrolled
      WHERE x_esn IN (p_esn)
        AND pgm_enroll2pgm_parameter = p_program_id
        AND x_enrollment_status IN ('DEENROLLED')
        AND TRUNC (x_cooling_exp_date) > TRUNC (SYSDATE)
        AND NVL (x_tot_grace_period_given, 0) != 1;

     IF (l_count <> 0)
     THEN
        -- ESN is in cooling period.
        op_result := 8007;
        op_msg := 'ESN is in cooling period';
        RETURN;
     END IF;
  dbms_output.put_line('l_handset_value6'||l_handset_value);
     -- Check if the ESN is enrolled in any program that is SUSPENDED.
     SELECT COUNT (*)
       INTO l_count
       FROM x_program_enrolled
      WHERE x_esn IN (p_esn)
        AND (x_enrollment_status = 'SUSPENDED' OR x_wait_exp_date IS NOT NULL);

     IF (l_count <> 0)
     THEN
        -- ESN is in cooling period.
        op_result := 8001;
        op_msg := 'ESN is suspended from future enrollment';
        RETURN;
     END IF;

     -- Check ESN with the status defined by the program.
     SELECT COUNT (*)
       INTO l_count
       FROM x_mtm_permitted_esnstatus
      WHERE program_param_objid = p_program_id
        AND esn_status_objid = l_status_objid;

     DBMS_OUTPUT.put_line ('Got the permitted ESN Status');
  dbms_output.put_line('l_handset_value7'||l_handset_value);
     IF (l_count = 0)
     THEN
        IF (l_status = 'NEW')
        THEN
           op_result := 8010;
        ELSIF (l_status = 'PASTDUE')
        THEN
           op_result := 8011;
        ELSE
           op_result := 8009;
        END IF;

        op_msg :=
              l_status
           || ' : '
           || 'The ESN status '
           || l_status
           || ' is not permitted for this program';
        RETURN;
     END IF;

     --    c.   Check ESN is not prevented from future enrollment
     SELECT COUNT (*)
       INTO l_count
       FROM x_metrics_block_status
      WHERE x_esn = p_esn AND block_status2web_user = p_webuser_id;

     DBMS_OUTPUT.put_line (   'Got the Metrics Block status: Count: '
                           || TO_CHAR (l_count)
                          );

     IF (l_count <> 0)
     THEN
        op_result := 8001;
        op_msg := 'The ESN is prevented from future enrollment';
        RETURN;
     END IF;

  dbms_output.put_line('l_handset_value8'||l_handset_value);

     --    d.    Check if the ESN is blocked from enrolling into the current program
     SELECT COUNT (*)
       INTO l_count
       FROM x_metrics_block_status
      WHERE x_esn = p_esn
        AND block_status2pgm_enroll = p_program_id
        AND block_status2web_user = p_webuser_id;

     DBMS_OUTPUT.put_line (   'Got the Metrics Block status: Count: '
                           || TO_CHAR (l_count)
                          );

     IF (l_count <> 0)
     THEN
        op_result := 8001;
        op_msg := 'ESN/Program is prevented from future enrollment';
        RETURN;
     END IF;

  dbms_output.put_line('l_handset_value9'||l_handset_value);
     --   Get the Carrier details only if the status is ACTIVE.

     BEGIN
     select COUNT(*) INTO V_B2B_COUNT
     from x_program_parameters
     where objid=p_program_id
     and x_program_name like '%B2B%';
   EXCEPTION
   WHEN OTHERS THEN
   V_B2B_COUNT :=0;
   END;

  IF V_B2B_COUNT = 0 THEN
     IF (l_status != 'ACTIVE')
     THEN
        op_result := 8009;
        op_msg := l_status;
     END IF;


     --    d.   Check for Carrier, Carrier Market, Handset, technology
     --      Carrier: => This query will work only if the ESN is 'Active'
     --                  IF NO Records are not, return 'ESN' is not active
     BEGIN
        SELECT carrier.objid carrobjid, carrparent.objid carrparentid
          INTO v_carr_objid, v_carr_parent_objid
          FROM table_x_parent carrparent,
               table_x_carrier_group carrgroup,
               table_x_carrier carrier,
               table_part_inst line,
               table_site_part sp
         WHERE carrparent.objid = carrgroup.x_carrier_group2x_parent
           AND carrgroup.objid = carrier.carrier2carrier_group
           AND line.part_inst2carrier_mkt = carrier.objid
           AND line.part_serial_no = sp.x_min
           AND line.x_domain = 'LINES'
           AND x_service_id IN (p_esn)                     --('010447000635244')
           AND sp.part_status = 'Active';
     EXCEPTION
        WHEN OTHERS
        THEN
           op_result := 8009;
           op_msg := l_status;
           RETURN;
     END;

  dbms_output.put_line('l_handset_value10'||l_handset_value);

     DBMS_OUTPUT.put_line (   'Carrier Market: Count: '
                           || TO_CHAR (l_count)
                           || ' Hybrid '
                           || l_carrmarket_value
                          );

     SELECT COUNT (*)
       INTO l_count
       FROM x_mtm_program_carrmkt
      WHERE program_param_objid = p_program_id AND carrier_objid = v_carr_objid;

  dbms_output.put_line('l_handset_value11'||l_handset_value);
  --    l_handset_value, l_carrmarket_value, l_carrparent_value
     IF (l_carrmarket_value = 'RESTRICTED')
     THEN
        IF (l_count <> 0)
        THEN
           -- this is a restricted market
           op_result := 8002;
           op_msg := 'Carrier Market Restricted';
           RETURN;
        END IF;
     END IF;
     dbms_output.put_line('l_handset_value12'||l_handset_value);

     IF (l_carrmarket_value = 'PERMITTED')
     THEN
        IF (l_count = 0)
        THEN
           -- No records found in the permitted list
           op_result := 8002;
           op_msg := 'Carrier Market Not Permitted';
           RETURN;
        END IF;
     END IF;
     dbms_output.put_line('l_handset_value13'||l_handset_value);

      -- For NONE we are ok to proceed.
  ---------------------------------------------------------------------------------------
     SELECT COUNT (*)
       INTO l_count
       FROM x_mtm_program_carrparent
      WHERE program_param_objid = p_program_id
        AND carr_parent_objid = v_carr_parent_objid;




     DBMS_OUTPUT.put_line (   'Carrier Parent: Count: '
                           || TO_CHAR (l_count)
                           || ' Hybrid '
                           || l_carrparent_value
                          );

  dbms_output.put_line('l_handset_value14'||l_handset_value);
     --    l_handset_value,
     IF (l_carrparent_value = 'RESTRICTED')
     THEN
        IF (l_count <> 0)
        THEN
           -- this is a restricted market
           op_result := 8003;
           op_msg := 'Carrier Parent Restricted';
           RETURN;
        END IF;
     END IF;

  dbms_output.put_line('l_handset_value15'||l_handset_value);
     IF (l_carrparent_value = 'PERMITTED')
     THEN
        IF (l_count = 0)
        THEN
           -- No records found in the permitted list
           op_result := 8003;
           op_msg := 'Carrier Parent Not Permitted';
           RETURN;
        END IF;
     END IF;
    END IF;----FOR b2B
  ---------------------------------------------------------------------------------------------------------------
  dbms_output.put_line('sdfl_count11='||l_count);
  dbms_output.put_line('p_program_id='||p_program_id);
  dbms_output.put_line('l_model_objid='||l_model_objid);

     SELECT COUNT (*)
       INTO l_count
       FROM x_mtm_program_handset
      WHERE program_param_objid = p_program_id
        AND part_class_objid = l_model_objid;

        dbms_output.put_line('sdfl_count12='||l_count);

     DBMS_OUTPUT.put_line (   'Handset: Count: '
                           || TO_CHAR (l_count)
                           || ' Hybrid '
                           || l_handset_value
                          );

  dbms_output.put_line('l_handset_value 16'||l_handset_value);

  dbms_output.put_line('l_handset_value17'||l_handset_value);

     IF (l_handset_value = 'RESTRICTED')
     THEN
        IF (l_count <> 0)
        THEN
           -- this is a restricted market
           op_result := 8004;
           op_msg := 'Handset Restricted';
           RETURN;
        END IF;
     END IF;

     dbms_output.put_line('sdfl_count1'||l_count);

     IF (l_handset_value = 'PERMITTED')
     THEN
        IF (l_count = 0)
        THEN
           -- No records found in the permitted list
           op_result := 8004;
           op_msg := 'Handset Not Permitted';
           RETURN;
        END IF;
     END IF;

  /*-- CR17003 Start NET10 SPRINT - Only Unlimited plans are valid for Sprint net10 (CDMA with OTA not allowed)
     IF (l_handset_value = 'NONE' and l_technology = 'CDMA' and l_bus_org = 'NET10' and  l_ota_allowed = 'N' )
     then
        IF (l_count <> 0)
        THEN
           -- No records found in the permitted list
           op_result := 8004;
           op_msg := 'Handset Not Permitted';
           RETURN;
        END IF;
     END IF;
  -- CR17003 End NET10 SPRINT
  */
  ----------------------------------------------------------------------------------------------

     -- For technology it always a permitted list.
     SELECT COUNT (*)
       INTO l_count
       FROM x_mtm_program_technology
      WHERE program_param_objid = p_program_id AND x_technology = l_technology;

     DBMS_OUTPUT.put_line (   'Technology: Count: '
                           || TO_CHAR (l_count)
                           || ' Technology '
                           || l_technology
                          );

     IF (l_count = 0)
     THEN
        -- this is not a permitted technology
        op_result := 8005;
        op_msg := 'Technology not permitted';
        RETURN;
     END IF;

  -- New Changes for Simplified Enrollment Project
  ---------------------------------------------------------------------------------------------------------------
  ----------------------------------- SEP requirement to validate membership group ---------------------------
  -- 1. If the Membership group is Annual Plan or Double Min For Life
  --    Check the ESN existence on table_x_group2esn
  -- 2. If the Membership group is Pay as you go .. check for atleast one successful redemption on table_x_purch_hdr
  -- 3. If the Membership group is ValuePlan or ValuePlan Bundle or EasyMinutes Plan or EasyMinutes Bundle
  --    or Buy Now or Service Plan or SafeLink or Unlimited Plan or Unlimited Bundle ..
  --    check for enrollment record on x_program_enrolled
     IF (l_membership_code = 'PAY_GO')
     THEN                                                           -- If Pay go
        SELECT COUNT (*)
          INTO l_count
          FROM table_x_purch_hdr
         WHERE x_ics_rflag IN ('ACCEPT', 'SOK') AND x_esn = p_esn;
     END IF;

     IF (l_membership_code IN ('BP_PLAN', 'BP_BUNDLE'))
     THEN                                        -- If any Value plan, Easy Plan
        SELECT COUNT (*)
          INTO l_count
          FROM x_program_enrolled
         WHERE x_esn = p_esn AND x_enrollment_status = 'ENROLLED';
     ELSE                                                  -- If any other group
        SELECT COUNT (*)
          INTO l_count
          FROM x_program_membership mem, x_mtm_program_membership mtm
         WHERE 1 = 1
           AND mem.x_membership_id = mtm.member_objid
           AND mem.x_membership_code = l_group_name;
     END IF;

     DBMS_OUTPUT.put_line (   'Membership : Count: '
                           || TO_CHAR (l_count)
                           || ' Group '
                           || l_membership_code
                          );

     IF (l_membership_value = 'RESTRICTED')
     THEN
        IF (l_count <> 0)
        THEN
           -- this is a restricted membership
           op_result := 8017;
           op_msg := 'Membership Restricted';
           RETURN;
        END IF;
     END IF;

     IF (l_membership_value = 'PERMITTED')
     THEN
        IF (l_count = 0)
        THEN
           -- No records found in the permitted list
           op_result := 8017;
           op_msg := 'Membership Not Permitted';
           RETURN;
        END IF;
     END IF;

  ---------------------------------------------------------------------------------------------------------
     /* Check if the ESN is in transferred out status */
     /* Assumption - ESN will always belong to only one account. */
     /*
       select count(*) into l_count
       from   table_x_contact_part_inst
       where  X_CONTACT_PART_INST2PART_INST = ( select objid from table_part_inst
                                                 where PART_SERIAL_NO = p_esn
                                                   and part_status = 'Active' )
          and X_TRANSFER_FLAG = 1;

       if ( l_count <> 0 ) then
            -- this is not a permitted technology
           op_result := 8013;
           op_msg    := 'ESN is transferred out. Program enrollments not possible.';
           return;
       end if;

      */
     op_result := 0;                                                  -- Success
     op_msg := 'Success';
     RETURN;
  EXCEPTION
     WHEN OTHERS
     THEN
        op_result := -100;
        op_msg :=
              'ESN not in correct state ('
           || l_status
           || ') for enrollment. Investigate further.';
  end esn_status_enroll_eligible;
/