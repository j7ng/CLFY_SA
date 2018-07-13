CREATE OR REPLACE TRIGGER sa."TRG_X_PRICING_BIUD"
   BEFORE INSERT OR UPDATE OR DELETE
   ON sa.table_x_pricing
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

--
   INSERT INTO x_pricing_hist
               (objid,
                x_start_date,
                x_end_date,
                x_web_link,
                x_web_description,
                x_retail_price,
                x_type,
                x_pricing2part_num,
                x_fin_priceline_id,
                x_sp_web_description,
                pricing_hist2pricing, x_pricing_hist2user, x_change_date,
                osuser,
                triggering_record_type
               )
        VALUES (seq_x_pricing_hist.NEXTVAL,
                DECODE (v_action, 'I', :NEW.x_start_date, :OLD.x_start_date),
                DECODE (v_action, 'I', :NEW.x_end_date, :OLD.x_end_date),
                DECODE (v_action, 'I', :NEW.x_web_link, :OLD.x_web_link),
                DECODE (v_action,
                        'I', :NEW.x_web_description,
                        :OLD.x_web_description
                       ),
                DECODE (v_action,
                        'I', :NEW.x_retail_price,
                        :OLD.x_retail_price
                       ),
                DECODE (v_action, 'I', :NEW.x_type, :OLD.x_type),
                DECODE (v_action,
                        'I', :NEW.x_pricing2part_num,
                        :OLD.x_pricing2part_num
                       ),
                DECODE (v_action,
                        'I', :NEW.x_fin_priceline_id,
                        :OLD.x_fin_priceline_id
                       ),
                DECODE (v_action,
                        'I', :NEW.x_sp_web_description,
                        :OLD.x_sp_web_description
                       ),
                :OLD.objid,                        -- objid of Table_X_Pricing
                           v_userid,                    -- objid of Table_User
                                    SYSDATE,
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
                             'TRG_X_PRICING_BIUD'
                            );
END;
/