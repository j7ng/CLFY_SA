CREATE OR REPLACE FUNCTION sa."BILLING_ISOTAENABLED" (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_ISOTAENABLED                                          */
/*                                                                                            */
/* Purpose      :   Validates Phone and the carrier is OTA enabled for delivery of benefits      */
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
/*  1.1                             CR7340                                                             */
/*  1.2                             CR8663 changes       */
/*  1.3                             CR8663_IV update cursor       */
/* 1.4                               Correct CR# CR10766
/*************************************************************************************************/
                                  p_esn table_part_inst.part_serial_no%TYPE)
   RETURN NUMBER
IS
   /*
    This function checks if the Phone and the carrier is OTA enabled for automatic delivery of benefits
   */
   l_return   NUMBER;
-- Local variable for holding return values
BEGIN
   -- Check to see if the phone is OTA Enabled.
   /* Updated query is used.
    SELECT DECODE(PN.X_OTA_ALLOWED,'Y',1,0) OTAENABLED
    into   l_return
    FROM TABLE_PART_NUM PN, TABLE_MOD_LEVEL ML,TABLE_PART_INST PHONE
    WHERE
        ML.PART_INFO2PART_NUM = PN.OBJID
    AND PHONE.N_PART_INST2PART_MOD = ML.OBJID
    AND PHONE.PART_SERIAL_NO IN (p_esn)
    AND PHONE.X_DOMAIN = 'PHONES';
   */
   /*    SELECT DECODE(PN.X_OTA_ALLOWED,'Y',1,0) OTAENABLED
    into   l_return
    FROM   TABLE_X_CONTACT_PART_INST CONPI,
           TABLE_PART_CLASS          MODEL,
           TABLE_PART_NUM               PN,
           TABLE_MOD_LEVEL              ML,
           TABLE_X_CODE_TABLE         CODE,
           TABLE_PART_INST            PHONE
    WHERE
           CONPI.X_CONTACT_PART_INST2PART_INST = PHONE.OBJID
      AND  MODEL.OBJID = PN.PART_NUM2PART_CLASS
      AND  ML.PART_INFO2PART_NUM = PN.OBJID
      AND  PHONE.N_PART_INST2PART_MOD = ML.OBJID
      AND  CODE.OBJID = PHONE.STATUS2X_CODE_TABLE
      AND  PHONE.PART_SERIAL_NO IN (p_esn)
      AND  PHONE.X_DOMAIN = 'PHONES';
   */
   -- STRAIGHT TALK .. CR8663, CR8663_IV CR10766
   SELECT COUNT (*)
     INTO l_return
     FROM x_program_enrolled pe, x_program_parameters pp
    WHERE pe.x_esn = p_esn
      AND pp.objid = pe.pgm_enroll2pgm_parameter
      AND pe.x_enrollment_status = 'ENROLLED'
      AND pp.x_prog_class = 'SWITCHBASE';

   IF (l_return > 0)
   THEN
      RETURN 1;
   END IF;

   -- If above check for Straight Talk is TRUE, no need to go further down
   -- End of STRAIGHT TALK .. CR8663
   -- CR23513 TFSurepay added TRACFONE per Ramu
   SELECT decode (pn.x_ota_allowed, 'Y', 1, decode(bo.org_id,'TRACFONE', 1, 0)) otaenabled
    INTO l_return
    FROM table_part_num pn, table_mod_level ml, table_part_inst phone, table_bus_org bo
   WHERE 1 = 1
    AND phone.part_serial_no IN (p_esn)
    AND phone.x_domain = 'PHONES'
    AND ml.part_info2part_num = pn.objid
    AND phone.n_part_inst2part_mod = ml.objid
    AND pn.part_num2bus_org = bo.objid;

   IF (l_return = 1)
   THEN
      -- TO check CARRIER OTA ENABLE
      SELECT DECODE (carrparent.x_ota_carrier, 'Y', 1, 0) otacarrier
        INTO l_return
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
         AND x_service_id IN (p_esn)
         AND sp.part_status = 'Active';

      RETURN (l_return);
-- Return the value returned by the query
   END IF;

   RETURN 0;                                                -- Not OTA enabled
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN 0;
   WHEN OTHERS
   THEN
      RETURN -100;
END;                                          -- Function BILLING_ISOTAENABLED
/