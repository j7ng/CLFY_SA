CREATE OR REPLACE PROCEDURE sa."SP_ACTIVATION"
/********************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved
/*
/* Name         :   sp_activation
/* Platforms    :   Oracle 8.0.6 AND newer versions
/* Date         :   09/28/1999
/* Revisions    :
/*
/* Version  Date        Who       Purpose
/* -------  --------    -------   --------------------------------------
/*  1.0	    09/28/1999        	  Initial Release
/*  1.1     10/12/2005  Gerald    CR4579 - Added CarrierRules by Technology
/********************************************************************************/
(
 var_insert_or_update IN VARCHAR2,
 var_part_status IN VARCHAR2,
 var_phone IN VARCHAR2,
 var_esn IN VARCHAR2,
 var_cust_id IN VARCHAR2,
 var_carrier_id IN NUMBER,
 var_dealer_id IN VARCHAR2,
 var_action IN NUMBER,
 var_reason_code IN VARCHAR2,
 var_line_worked IN VARCHAR2,
 var_line_worked_by IN VARCHAR2,
 var_line_worked_dt IN DATE,
 var_islocked IN VARCHAR2,
 var_locked_by IN VARCHAR2,
 var_action_type_id IN NUMBER,
 var_ig_status IN VARCHAR2,
 var_ig_error IN VARCHAR2,
 var_cust_pin IN VARCHAR2,
 var_phone_manufacturer IN VARCHAR2,
 var_initial_act_date IN DATE,
 var_end_user_name IN VARCHAR2
 )
IS

CURSOR cur_carrier(c_tech in varchar2)
IS
    SELECT x_line_return_days
    FROM table_x_carrier_rules cr,
         table_x_carrier ca
    WHERE cr.objid = DECODE(c_tech,'GSM',ca.carrier2rules_GSM, --CR4579
                       'TDMA',ca.carrier2rules_TDMA,
                       'CDMA',ca.carrier2rules_CDMA,
                              ca.carrier2rules)
    AND  ca.x_carrier_id = var_carrier_id;

CURSOR c2
IS
    SELECT 1
    FROM  x_min_esn_change
    WHERE x_min = var_phone;


--CR4579 Added Cursor to get ESN technology
CURSOR cur_esn(c_esn in varchar2)
is
   SELECT x_technology
     FROM table_part_inst a,
          table_mod_level b,
          table_part_num c
    WHERE c.objid = b.part_info2part_num
      and b.objid = a.n_part_inst2part_mod
      and a.part_serial_no = c_esn;


rec_esn                 cur_esn%ROWTYPE; --CR4579

var_flag                NUMBER;
var_action_loc          VARCHAR2(1);
var_min                 NUMBER;
rec_carrier             cur_carrier%ROWTYPE;
local_var_action        NUMBER;
v_procedure_name        VARCHAR2(80):= '.SP_ACTIVATION()';


BEGIN

  OPEN cur_esn(var_esn);
  FETCH cur_esn INTO rec_esn;
  CLOSE cur_esn;

  OPEN cur_carrier(rec_esn.x_technology);  -- CR4579 Added technology to cur_carrier
  FETCH cur_carrier INTO rec_carrier;

  IF rec_carrier.x_line_return_days = 1
  THEN

        local_var_Action := 1;
  ELSIF rec_carrier.x_line_return_days = 0
  THEN

        local_var_action := 0;
  ELSE

        local_var_action := var_action;
  END IF;
  CLOSE cur_carrier;

  IF var_part_status = 'Active'
  THEN

        var_action_loc := 'A';
  ELSIF (var_part_status = 'Inactive' AND local_var_action = 1)
  THEN

        var_action_loc := 'D';
  ELSE
        var_action_loc := 'S';
  END IF;

   var_flag := 0;

   IF var_action_loc = 'S'
   THEN

     IF var_esn is not null
     THEN

        INSERT INTO x_min_esn_change (X_TRANSACTION_ID,
                                      X_ATTACHED_DATE,
                                      X_MIN,
                                      X_OLD_ESN,
                                      X_DETACH_DT,
                                      X_NEW_ESN)
                              VALUES (seq_x_transact_id.nextval + (power(2,28)),
                                      NULL,
                                      var_phone,
                                      var_esn,
                                      sysdate,
                                      NULL);

       ELSE

         /* Insert the error into error_table */

                    INSERT INTO error_table (error_text,
                                             error_date,
                                             action,
                                             key,
                                             program_name)
                       VALUES     ('UPDATE X_MIN_ESN_CHANGE, NULL ESN',
                                   sysdate,
                                   NVL (var_esn, var_phone),
                                   'NULL ESN has been sent to this procedure',
                                   v_procedure_name
                                  );
      END IF;
  END IF;

   OPEN c2;
   FETCH c2 INTO var_min;
   IF (c2%found AND var_action_loc = 'A')
   THEN
            --------------------------
             /* update esn_change */
            --------------------------
      IF var_esn is not null
      THEN

        UPDATE x_min_esn_change
        SET    X_ATTACHED_DATE = sysdate,
               X_NEW_ESN       = var_esn
        WHERE  x_min           = var_phone
        AND    X_ATTACHED_DATE is null
        AND    X_NEW_ESN is null;

      ELSE

         /* Insert the error into error_table */

           INSERT INTO error_table (error_text,
                                    error_date,
                                    action,
                                    key,
                                    program_name)
                VALUES            ('UPDATE X_MIN_ESN_CHANGE, NULL ESN',
                                   sysdate,
                                   NVL (var_esn, var_phone),
                                   'NULL ESN has been sent to this procedure',
                                   v_procedure_name
                                  );

      END IF;

    END IF;
   CLOSE c2;

 EXCEPTION
   WHEN others THEN

         /* Insert the error into error_table */

           INSERT INTO error_table (error_text,
                                    error_date,
                                    action,
                                    key,
                                    program_name)
                VALUES            ('UPDATE X_MIN_ESN_CHANGE, NULL ESN',
                                   sysdate,
                                   NVL (var_esn, var_phone),
                                   'NULL ESN has been sent to this procedure',
                                   v_procedure_name
                                  );

END SP_ACTIVATION;
/