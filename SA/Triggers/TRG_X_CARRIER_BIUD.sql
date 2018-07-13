CREATE OR REPLACE TRIGGER sa."TRG_X_CARRIER_BIUD"
   BEFORE INSERT OR UPDATE OR DELETE
   ON sa.table_x_carrier
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
   v_action   VARCHAR2 (1);
   v_osuser   VARCHAR2 (50);
   v_userid   VARCHAR2 (30);
BEGIN
   IF INSERTING
   THEN
      v_action := 'I';
   ELSIF UPDATING
   THEN
      v_action := 'U';
   ELSE
      v_action := 'D';
   END IF;

--cwl 01-dec-09
--    SELECT objid, SYS_CONTEXT ('USERENV', 'OS_USER')
--      INTO v_userid, v_osuser
--      FROM table_user
--     WHERE UPPER (login_name) = UPPER (USER);
   SELECT objid, SYS_CONTEXT ('USERENV', 'OS_USER')
     INTO v_userid, v_osuser
     FROM table_user
    WHERE s_login_name = UPPER (USER);

--cwl 01-dec-09
   INSERT INTO x_carrier_hist
               (objid,
                x_carrier_id,
                x_mkt_submkt_name,
                x_submkt_of,
                x_city,
                x_state,
                x_tapereturn_charge,
                x_country_code,
                x_activeline_percent,
                x_status,
                x_ld_provider,
                x_ld_account,
                x_ld_pic_code,
                x_rate_plan,
                x_dummy_esn,
                x_bill_date,
                x_voicemail,
                x_vm_code,
                x_vm_package,
                x_caller_id,
                x_id_code,
                x_id_package,
                x_call_waiting,
                x_cw_code,
                x_cw_package,
                x_react_technology,
                x_react_analog,
                x_act_technology,
                x_act_analog,
                x_digital_rate_plan,
                x_digital_feature,
                x_prl_preloaded,
                carrier2carrier_group,
                tapereturn_addr2address,
                carrier2provider,
                x_carrier2address,
                carrier2personality,
                carrier2rules,
                carrier2x_carr_script,
                x_special_mkt,
                x_new_analog_plan,
                x_new_digital_plan,
                x_sms,
                x_sms_code,
                x_sms_package,
                carrier_hist2carrier, x_carrier_hist2user, x_change_date,
                osuser,
                triggering_record_type
               )
        VALUES (seq_x_carrier_hist.NEXTVAL,
                DECODE (v_action, 'I', :NEW.x_carrier_id, :OLD.x_carrier_id),
                DECODE (v_action,
                        'I', :NEW.x_mkt_submkt_name,
                        :OLD.x_mkt_submkt_name
                       ),
                DECODE (v_action, 'I', :NEW.x_submkt_of, :OLD.x_submkt_of),
                DECODE (v_action, 'I', :NEW.x_city, :OLD.x_city),
                DECODE (v_action, 'I', :NEW.x_state, :OLD.x_state),
                DECODE (v_action,
                        'I', :NEW.x_tapereturn_charge,
                        :OLD.x_tapereturn_charge
                       ),
                DECODE (v_action,
                        'I', :NEW.x_country_code,
                        :OLD.x_country_code
                       ),
                DECODE (v_action,
                        'I', :NEW.x_activeline_percent,
                        :OLD.x_activeline_percent
                       ),
                DECODE (v_action, 'I', :NEW.x_status, :OLD.x_status),
                DECODE (v_action, 'I', :NEW.x_ld_provider, :OLD.x_ld_provider),
                DECODE (v_action, 'I', :NEW.x_ld_account, :OLD.x_ld_account),
                DECODE (v_action, 'I', :NEW.x_ld_pic_code, :OLD.x_ld_pic_code),
                DECODE (v_action, 'I', :NEW.x_rate_plan, :OLD.x_rate_plan),
                DECODE (v_action, 'I', :NEW.x_dummy_esn, :OLD.x_dummy_esn),
                DECODE (v_action, 'I', :NEW.x_bill_date, :OLD.x_bill_date),
                DECODE (v_action, 'I', :NEW.x_voicemail, :OLD.x_voicemail),
                DECODE (v_action, 'I', :NEW.x_vm_code, :OLD.x_vm_code),
                DECODE (v_action, 'I', :NEW.x_vm_package, :OLD.x_vm_package),
                DECODE (v_action, 'I', :NEW.x_caller_id, :OLD.x_caller_id),
                DECODE (v_action, 'I', :NEW.x_id_code, :OLD.x_id_code),
                DECODE (v_action, 'I', :NEW.x_id_package, :OLD.x_id_package),
                DECODE (v_action,
                        'I', :NEW.x_call_waiting,
                        :OLD.x_call_waiting
                       ),
                DECODE (v_action, 'I', :NEW.x_cw_code, :OLD.x_cw_code),
                DECODE (v_action, 'I', :NEW.x_cw_package, :OLD.x_cw_package),
                DECODE (v_action,
                        'I', :NEW.x_react_technology,
                        :OLD.x_react_technology
                       ),
                DECODE (v_action,
                        'I', :NEW.x_react_analog,
                        :OLD.x_react_analog
                       ),
                DECODE (v_action,
                        'I', :NEW.x_act_technology,
                        :OLD.x_act_technology
                       ),
                DECODE (v_action, 'I', :NEW.x_act_analog, :OLD.x_act_analog),
                DECODE (v_action,
                        'I', :NEW.x_digital_rate_plan,
                        :OLD.x_digital_rate_plan
                       ),
                DECODE (v_action,
                        'I', :NEW.x_digital_feature,
                        :OLD.x_digital_feature
                       ),
                DECODE (v_action,
                        'I', :NEW.x_prl_preloaded,
                        :OLD.x_prl_preloaded
                       ),
                DECODE (v_action,
                        'I', :NEW.carrier2carrier_group,
                        :OLD.carrier2carrier_group
                       ),
                DECODE (v_action,
                        'I', :NEW.tapereturn_addr2address,
                        :OLD.tapereturn_addr2address
                       ),
                DECODE (v_action,
                        'I', :NEW.carrier2provider,
                        :OLD.carrier2provider
                       ),
                DECODE (v_action,
                        'I', :NEW.x_carrier2address,
                        :OLD.x_carrier2address
                       ),
                DECODE (v_action,
                        'I', :NEW.carrier2personality,
                        :OLD.carrier2personality
                       ),
                DECODE (v_action, 'I', :NEW.carrier2rules, :OLD.carrier2rules),
                DECODE (v_action,
                        'I', :NEW.carrier2x_carr_script,
                        :OLD.carrier2x_carr_script
                       ),
                DECODE (v_action, 'I', :NEW.x_special_mkt, :OLD.x_special_mkt),
                DECODE (v_action,
                        'I', :NEW.x_new_analog_plan,
                        :OLD.x_new_analog_plan
                       ),
                DECODE (v_action,
                        'I', :NEW.x_new_digital_plan,
                        :OLD.x_new_digital_plan
                       ),
                DECODE (v_action, 'I', :NEW.x_sms, :OLD.x_sms),
                DECODE (v_action, 'I', :NEW.x_sms_code, :OLD.x_sms_code),
                DECODE (v_action, 'I', :NEW.x_sms_package, :OLD.x_sms_package),
                :OLD.objid, v_userid, SYSDATE,
                v_osuser,
                DECODE (v_action,
                        'I', 'INSERT',
                        'U', 'UPDATE',
                        'D', 'DELETE'
                       )
               );
EXCEPTION
   WHEN OTHERS
   THEN
      insert_error_tab_proc ('Exception caught ' || SQLERRM,
                             '',
                             'TRG_X_CARRIER_BIUD'
                            );
END;
/