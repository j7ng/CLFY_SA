CREATE OR REPLACE PROCEDURE sa."SP_GET_ESN_PROMO_DEF" (
   p_esn            IN       VARCHAR2,
   p_act_type       IN       NUMBER,
   p_soure_system   IN       VARCHAR2,
   p_promo_id       OUT      VARCHAR2,
   p_phrase         OUT      VARCHAR2,
   p_tts_english    OUT      VARCHAR2,
   p_tts_spanish    OUT      VARCHAR2,
   p_score          OUT      VARCHAR2,
   p_promo_type     OUT      VARCHAR2,
   p_promo_pos      OUT      NUMBER,
   p_result         OUT      NUMBER,
   p_msg            OUT      VARCHAR2
)
AS
   /************************************************************************************************|
       |    Copyright   Tracfone  Wireless Inc. All rights reserved                                       |
       |                                                                                                  |
       | NAME     :       SP_GET_ESN_PROMO_SCORE  procedure                                             |
       | PURPOSE  :                                                                                    |
       | FREQUENCY:                                                                                       |
       | PLATFORMS:                                                                                    |
       |                                                                                                  |
       | REVISIONS:                                                                                       |
       | VERSION  DATE        WHO              PURPOSE                                                 |
       | -------  ---------- -----             ------------------------------------------------------    |
       | 1.0      08/10/05   HM                Initial revision                                         |
       | 1.1      09/21/05   HM                Flash Message use
       | 1.2      07/28/06   NG                CR4902 - Call alert_pkg
       | 1.3      11/07/06   CL                CR5631 changes
       | 1.4      12/05/06   NG                CR5772-2
       | 1.5      01/12/07   HM                CR5522 Add TTS Strings
       | 1.6      01/12/07   HM                CR5522 Add TTS Strings
       | 1.6      01/12/07   HM                CR5522 Add TTS Strings
       | 1.7      07/12/07   HM                CR6049 Q2 Handsets
       |
       | NEW_PLSQL NEW STRUCTURE
       | 1.0/1.1      08/31/09 NGuada BRAND_SEP Separate the Brand and Source System
       |                          incorporate use of new table TABLE_BUS_ORG to retrieve
       |                          brand information that was previously identified by the fields
       |                          x_restricted_use and/or amigo from table_part_num
       | 1.2 - 1.3    07/12/10  Pmistry  get_alert
       | 1.4          06/03/11  ICanavan CR16379 / CR16344 triple minute promo
       |************************************************************************************************/
   CURSOR c_scoring_esn_promos
   IS
      SELECT pse.x_esn, pse.x_score, psm.x_efective_date,
             psm.x_expiration_date, psm.x_script, psm.x_promo_pos,
             psm.x_promo_type
        FROM x_promo_marketing psm, x_scoring_esn pse
       WHERE 1 = 1
         AND psm.x_efective_date <= SYSDATE
         AND psm.x_act_type = p_act_type
         AND UPPER (psm.x_soure_system) = UPPER (p_soure_system)
         AND UPPER (psm.x_score) = UPPER (pse.x_score)
         AND UPPER (pse.x_promo_flag) <> '1'
         AND pse.x_esn = p_esn;

/*
      SELECT pse.x_esn, pse.x_score, psm.x_efective_date,
             psm.x_expiration_date, psm.x_script, psm.x_promo_pos,
             psm.x_promo_type
        FROM x_scoring_esn pse,
             x_promo_marketing psm
       WHERE UPPER (pse.x_esn) = UPPER (TRIM (p_esn))
         AND UPPER (pse.x_score) = UPPER (psm.x_score)
         AND psm.x_act_type = p_act_type
         AND UPPER (psm.x_soure_system) = UPPER (p_soure_system)
         AND UPPER (pse.x_promo_flag) <> '1'
         AND psm.x_efective_date <= SYSDATE;
*/

   --    CURSOR c_flash
--    IS
--    SELECT ta.X_IVR_SCRIPT_ID as Ivr_scriptID
--    FROM TABLE_PART_INST pi, TABLE_ALERT ta, x_promo_ivr xpi
--    WHERE pi.x_domain = 'PHONES'
--           AND pi.PART_SERIAL_NO = UPPER(TRIM(p_esn))
--           AND ta.ALERT2CONTRACT = pi.objid
--           AND ta.START_DATE <= SYSDATE
--           AND ta.END_DATE >= SYSDATE
--           AND ta.ACTIVE = 1
--        AND (ta.TYPE = p_act_type or ta.TYPE = '0')
--           AND ta.X_IVR_SCRIPT_ID = xpi.X_SCRIPT;
   CURSOR c_esn
   IS
      SELECT pi.objid, bo.org_id            --pn.x_restricted_use -- BRAND_SEP
        FROM table_part_num pn,
             table_mod_level ml,
             table_part_inst pi,
             table_bus_org bo
       WHERE 1 = 1
         AND ml.part_info2part_num = pn.objid
         AND pi.n_part_inst2part_mod = ml.objid
         AND pi.part_serial_no = TRIM (p_esn)
         AND pn.part_num2bus_org = bo.objid;

   c_scoring_esn_promos_rec   c_scoring_esn_promos%ROWTYPE;
   c_esn_rec                  c_esn%ROWTYPE;
--    c_flash_script c_flash%ROWTYPE;
   l_autopay_cnt              NUMBER                         := 0;
   l_annual_cnt               NUMBER                         := 0;
   l_dbl_min_cnt              NUMBER                         := 0;
   l_pend_cnt                 NUMBER                         := 0;
   l_err                      VARCHAR2 (400);
   title                      VARCHAR2 (80);                    -- Alert Title
   csr_text                   VARCHAR2 (2000);    -- Text to be used in WEBCSR
   eng_text                   VARCHAR2 (2000);             -- Web Text English
   spa_text                   VARCHAR2 (2000);             -- Web Text Spanish
   ivr_scr_id                 VARCHAR2 (20);                  -- IVR script ID
   tts_english                VARCHAR2 (2000);       -- Text to Speech English
   tts_spanish                VARCHAR2 (2000);       -- Text to Speech Spanish
   hot                        VARCHAR2 (10);
   -- 0 Let customer continue, 1 Transfer
   err                        VARCHAR2 (200);                  -- Error Number
   msg                        VARCHAR2 (200);           -- Additional Messages
BEGIN
   p_result := 1;
--    OPEN c_flash;
--    FETCH c_flash
--    INTO c_flash_script;
--    CLOSE c_flash;
--    IF c_flash_script.Ivr_scriptID IS NOT NULL
--    THEN
--      p_result := 0;
--      p_msg := 'Flash Alert asociated to this ESN: '||p_esn;
--      p_promo_id := c_flash_script.Ivr_scriptID;
--      p_score := 'AA';
--      p_promo_type := '1';
--      p_promo_pos := '1';
--       RETURN;
--    END IF;
--CR4902
   ALERT_PKG.GET_ALERT (P_ESN,
                        0,                                    -- Step Added by Pmistry on 07/08/2010 as per Vani's Request.
						p_soure_system,                       --channel CR35705
                        title,                                  -- Alert Title
                        csr_text,                 -- Text to be used in WEBCSR
                        eng_text,                          -- Web Text English
                        spa_text,                          -- Web Text Spanish
                        ivr_scr_id,                           -- IVR script ID
                        tts_english,                 -- Text to Speech English
                        tts_spanish,                 -- Text to Speech Spanish
                        hot,            -- 0 Let customer continue, 1 Transfer
                        err,                                   -- Error Number
                        msg
                       );                               -- Additional Messages

--CR4902
   IF ivr_scr_id IS NOT NULL
   THEN
      p_result := 0;
      p_msg := 'Flash Alert asociated to this ESN: ' || p_esn;
      p_phrase := ivr_scr_id;
      p_tts_english := tts_english;
      p_tts_spanish := tts_spanish;
      p_promo_id := ivr_scr_id;
      p_score := 'AA';
      p_promo_type := hot;
      p_promo_pos := '1';
      RETURN;
   END IF;

   OPEN c_scoring_esn_promos;

   FETCH c_scoring_esn_promos
    INTO c_scoring_esn_promos_rec;

   CLOSE c_scoring_esn_promos;

   IF c_scoring_esn_promos_rec.x_script IS NULL
   THEN
      p_result := 1;
      p_msg := 'Has no promo assigned to this ESN ' || p_esn;
      RETURN;
   ELSIF TRUNC (SYSDATE) > c_scoring_esn_promos_rec.x_expiration_date
   THEN
      p_result := 1;
      p_msg :=
            'Promotion group asigned already Expired'
         || c_scoring_esn_promos_rec.x_script;
      RETURN;
   END IF;

   OPEN c_esn;

   FETCH c_esn
    INTO c_esn_rec;

   CLOSE c_esn;

   IF c_esn_rec.objid IS NULL
   THEN
      p_result := 1;
      p_msg := 'Invalid ESN ' || p_esn;
      RETURN;
   END IF;

   SELECT COUNT (1)
     INTO l_autopay_cnt
     FROM table_x_autopay_details
    WHERE 1 = 1 AND x_status = 'A' AND x_esn = p_esn;

   IF l_autopay_cnt > 0
   THEN
      p_result := 1;
      p_msg := 'Already Autopay member';
      RETURN;
   END IF;

   SELECT COUNT (1)
     INTO l_annual_cnt
     FROM table_part_num pn,
          table_mod_level ml,
          table_x_red_card rc,
          table_x_call_trans ct
    WHERE 1 = 1
      AND pn.x_redeem_days = 365
      AND ml.part_info2part_num = pn.objid
      AND rc.x_red_card2part_mod = ml.objid
      AND ct.objid = rc.red_card2call_trans
      AND ct.x_result = 'Completed'
      AND ct.x_service_id = p_esn
      AND ct.x_transact_date + 0 >= SYSDATE - 365;

   IF l_annual_cnt > 0
   THEN
      p_result := 1;
      p_msg := 'Already redeemed annual card or double card in last 365 days';
      RETURN;
   END IF;

   SELECT COUNT (1)
     INTO l_dbl_min_cnt
     FROM table_x_group2esn
    WHERE groupesn2part_inst = (SELECT objid
                                  FROM table_part_inst
                                 WHERE part_serial_no = p_esn)
      AND groupesn2x_promo_group IN (
             SELECT objid
               FROM table_x_promotion_group
              WHERE group_name IN
                       ('52293_GRP1',
                        '52293_GRP2',
                        '52312_GRP',
                        'DBLMIN_ADVAN_GRP',
                        'DBLMIN_GRP',
                        'DBLMN_3390_GRP',
                        'X3XMN_GRP'  -- CR16379 / CR16344
                       ))
      AND x_end_date > SYSDATE;

   IF l_dbl_min_cnt > 0
   THEN
      p_result := 1;
      p_msg := 'Already Double Minute member';
      RETURN;
   END IF;

   SELECT COUNT (1)
     INTO l_pend_cnt
     FROM table_x_pending_redemption p
    WHERE x_pend_red2site_part =
             (SELECT objid
                FROM table_site_part
               WHERE x_service_id = p_esn
                 AND part_status || '' = 'Active'
                 AND ROWNUM = 1)
      AND x_pend_type IN ('Runtime', 'Promocode');

   IF l_pend_cnt > 0
   THEN
      p_result := 1;
      p_msg := 'PENDing promotion exists';
      RETURN;
   END IF;

   COMMIT;
   p_promo_id := c_scoring_esn_promos_rec.x_script;
   p_score := c_scoring_esn_promos_rec.x_score;
   p_promo_type := c_scoring_esn_promos_rec.x_promo_type;
   p_promo_pos := c_scoring_esn_promos_rec.x_promo_pos;
   p_result := 0;
   p_msg := 'ESN qualify for ivr promotion';
EXCEPTION
   WHEN OTHERS
   THEN
      l_err := SUBSTR (SQLERRM, 1, 400);
      p_result := 99;
      p_msg := 'SQL error ';
END;
/