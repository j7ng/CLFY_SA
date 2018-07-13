CREATE OR REPLACE TRIGGER sa.trg_biur_x_subscriber_spr
BEFORE UPDATE OR DELETE ON sa.X_SUBSCRIBER_SPR REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
BEGIN

--------------------------------------------------------------------------------------------
  --RCSfile: trg_biur_x_subscriber_spr.sql
  --Author: Kedar Parkhi
  --Date: 04/23/2015
  --------------------------------------------------------------------------------------------
  IF UPDATING AND ( :old.pcrf_esn != :new.pcrf_esn or
                    :old.pcrf_min != :new.pcrf_min or
                    :old.service_plan_id != :new.service_plan_id or
                    :old.propagate_flag != :new.propagate_flag or
                    :old.pcrf_cos != :new.pcrf_cos or
                    :old.pcrf_base_ttl != :new.pcrf_base_ttl or
                    :old.future_ttl != :new.future_ttl or
                    :old.pcrf_last_redemption_date != :new.pcrf_last_redemption_date or
                    NVL(:old.curr_throttle_policy_id,9999) != NVL(:new.curr_throttle_policy_id,9999)
                  )
        OR DELETING
  THEN
    INSERT
            INTO   sa.x_subscriber_spr_hist
           ( objid,
             subscriber_spr_objid,
             change_date ,
             pcrf_min ,
             pcrf_esn ,
             pcrf_subscriber_id ,
             pcrf_group_id ,
             pcrf_parent_name ,
             service_plan_id ,
             pcrf_cos ,
             pcrf_base_ttl ,
             pcrf_last_redemption_date ,
             brand ,
             phone_manufacturer ,
             phone_model ,
             content_delivery_format ,
             denomination ,
             conversion_factor ,
             dealer_id ,
             rate_plan ,
             propagate_flag ,
             pcrf_transaction_id ,
             service_plan_type ,
             queued_days ,
             language ,
             contact_objid ,
             web_user_objid ,
             part_inst_status ,
             wf_mac_id ,
             expired_usage_date ,
             insert_timestamp ,
             update_timestamp ,
             subscriber_status_code ,
             curr_throttle_policy_id,
             curr_throttle_eff_date,
             future_ttl
           )
    VALUES
    ( sa.sequ_subscriber_spr_hist.NEXTVAL ,
      :OLD.objid ,
      SYSDATE ,
      :OLD.pcrf_min ,
      :OLD.pcrf_esn ,
      :OLD.pcrf_subscriber_id ,
      :OLD.pcrf_group_id ,
      :OLD.pcrf_parent_name ,
      :OLD.service_plan_id ,
      :OLD.pcrf_cos ,
      :OLD.pcrf_base_ttl ,
      :OLD.pcrf_last_redemption_date ,
      :OLD.brand ,
      :OLD.phone_manufacturer ,
      :OLD.phone_model ,
      :OLD.content_delivery_format ,
      :OLD.denomination ,
      :OLD.conversion_factor ,
      :OLD.dealer_id ,
      :OLD.rate_plan ,
      :OLD.propagate_flag ,
      :OLD.pcrf_transaction_id ,
      :OLD.service_plan_type ,
      :OLD.queued_days ,
      :OLD.language ,
      :OLD.contact_objid ,
      :OLD.web_user_objid ,
      :OLD.part_inst_status ,
      :OLD.wf_mac_id ,
      :OLD.expired_usage_date ,
      SYSDATE,
      SYSDATE,
      :OLD.subscriber_status_code ,
      :OLD.curr_throttle_policy_id,
      :OLD.curr_throttle_eff_date,
      :OLD.future_ttl
    );
  END IF;
END;
/