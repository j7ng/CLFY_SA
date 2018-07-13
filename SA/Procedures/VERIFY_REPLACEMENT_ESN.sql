CREATE OR REPLACE PROCEDURE sa."VERIFY_REPLACEMENT_ESN" (
   p_in_esn VARCHAR2,
   p_in_zip VARCHAR2,
   p_out_number OUT VARCHAR2,
   p_msg OUT VARCHAR2
)
IS
/* **************************************************************************************
   * Copyright ) 2004 Tracfone  Wireless Inc. All rights reserved                          *
   * Purpose   :   CR3338 - This procedure is used to verify if the ESN technology and frequency    *
   *               match the zipcode                                                       *
   * Author    :   TCS                                                                     *
   * Date      :   11/15/04                                                                *
   *****************************************************************************************/
   global_phone_frequency NUMBER := 0;
   global_phone_frequency2 NUMBER := 0;
   blnTechFound BOOLEAN := FALSE;
   CURSOR csrPhoneTech
   IS
   SELECT x_technology
   FROM table_part_num PN, table_mod_level ML, table_part_inst PI
   WHERE PN.Objid = ML.Part_Info2part_Num
   AND ML.OBJID = PI.N_PART_INST2PART_MOD
   AND PI.Part_Serial_No = p_in_esn;
   v_technology table_part_num.x_technology%TYPE;
   CURSOR csrZipTech
   IS
   SELECT tab2.cdma_tech ctech,
      tab2.tdma_tech ttech,
      tab2.gsm_tech gtech,
      cp.new_rank
   FROM carrierpref cp, table_x_carrier CA, (
      SELECT DISTINCT b.state,
         b.county,
         b.carrier_id,
         b.cdma_tech,
         b.tdma_tech,
         b.gsm_tech
      FROM npanxx2carrierzones b, (
         SELECT DISTINCT a.zone,
            a.st,
            a.sim_profile
         FROM carrierzones a
         WHERE a.zip = p_in_zip)tab1
      WHERE b.zone = tab1.zone
      AND b.state = tab1.st)tab2
   WHERE cp.county = tab2.county
   AND cp.st = tab2.state
   AND cp.carrier_id = tab2.carrier_id
   AND CA.x_carrier_Id = tab2.carrier_id
   AND CA.x_Status = 'ACTIVE'
   ORDER BY new_rank;
   recZipTech csrZipTech%ROWTYPE;
   CURSOR csrPhoneFreq
   IS
   SELECT MAX (DECODE (f.x_frequency, 800, 800, 0)) phone_frequency,
      MAX (DECODE (f.x_frequency, 1900, 1900, 0)) phone_frequency2
   FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num pn,
   table_mod_level ml, table_part_inst pi
   WHERE pf.x_frequency2part_num = f.objid
   AND pn.objid = pf.part_num2x_frequency
   AND pn.objid = ml.part_info2part_num
   AND ml.objid = pi.n_part_inst2part_mod
   AND pi.part_serial_no = p_in_esn
   AND pi.x_domain = 'PHONES';
   CURSOR csrZipCarrierFreq
   IS
   SELECT ca.objid,
      ca.x_carrier_id,
      ca.x_react_analog,
      ca.x_react_technology ca_react_technology,
      ca.x_act_analog,
      ca.x_act_technology ca_act_technology,
      pt.x_technology pref_technology,
      f.x_frequency,
      pt.x_technology
   FROM table_x_frequency f, mtm_x_frequency2_x_pref_tech1 f2pt,
   table_x_pref_tech pt, table_x_carrier ca, table_x_carrierdealer c, (
      SELECT DISTINCT b.carrier_id
      FROM npanxx2carrierzones b, carrierzones a
      WHERE b.frequency1 IN (1900, 800)
      AND ( b.tdma_tech = v_technology
      OR b.cdma_tech = v_technology
      OR b.gsm_tech = v_technology)
      AND b.zone = a.zone
      AND b.state = a.st
      AND a.zip = p_in_zip)tab1
   WHERE f.objid = f2pt.x_frequency2x_pref_tech
   AND f.x_frequency IN (global_phone_frequency, global_phone_frequency2)
   AND f2pt.x_pref_tech2x_frequency = pt.objid
   AND pt.x_pref_tech2x_carrier = ca.objid
   AND pt.x_technology = v_technology
   AND ca.x_carrier_id = c.x_carrier_id
   AND ca.x_status = 'ACTIVE'
   AND c.x_dealer_id = 'DEFAULT'
   AND c.x_carrier_id = tab1.carrier_id
   ORDER BY f.x_frequency DESC;
   recZipCarrierFreq csrZipCarrierFreq%ROWTYPE;
BEGIN
   p_out_number := 'S';
   p_msg := '';
   --Get Phone technology
   OPEN csrPhoneTech;
   FETCH csrPhoneTech
   INTO v_technology;
   CLOSE csrPhoneTech;
   --Loop through avaialable technologies in the zipcode and check if the phone technology is available
   FOR recZipTech IN csrZipTech
   LOOP
      IF recZipTech.ctech
      IS
      NOT NULL
      AND recZipTech.ctech = v_technology
      THEN
         blnTechFound := TRUE;
         EXIT;
      ELSE
         IF recZipTech.ttech
         IS
         NOT NULL
         AND recZipTech.ttech = v_technology
         THEN
            blnTechFound := TRUE;
            EXIT;
         ELSE
            IF recZipTech.gtech
            IS
            NOT NULL
            AND recZipTech.gtech = v_technology
            THEN
               blnTechFound := TRUE;
               EXIT;
            END IF;
         END IF;
      END IF;
   END LOOP;
   --Technology not available at zipcode
   IF NOT blnTechFound
   THEN
      p_out_number := 'F';
      p_msg := 'No carrier found for technology.';
      RETURN;
   END IF;
   --Get the phone frequency
   OPEN csrPhoneFreq;
   FETCH csrPhoneFreq
   INTO global_phone_frequency, global_phone_frequency2;
   CLOSE csrPhoneFreq;
   DBMS_OUTPUT.put_line('global_phone_frequency = ' || global_phone_frequency
   || 'global_phone_frequency2 = ' || global_phone_frequency2);
   --Check if phone frequency is available at zipcode
   OPEN csrZipCarrierFreq;
   FETCH csrZipCarrierFreq
   INTO recZipCarrierFreq;
   IF csrZipCarrierFreq%NOTFOUND
   THEN
      p_out_number := 'F';
      p_msg := 'No carrier found for technology.';
      RETURN;
   END IF;
   CLOSE csrZipCarrierFreq;
   RETURN;
END;
/