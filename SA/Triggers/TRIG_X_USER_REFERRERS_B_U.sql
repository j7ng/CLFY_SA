CREATE OR REPLACE TRIGGER sa.trig_x_user_referrers_b_u
BEFORE UPDATE OF
x_referrer_id,
x_program_id,
x_ref_promo_code
ON sa.x_user_referrers
FOR EACH ROW
DECLARE
l_desc  VARCHAR2(200):= NULL;
l_flag_insert VARCHAR2(1):= 'N';
BEGIN
    IF NVL(:NEW.x_cashcard_da,0) != NVL(:OLD.x_cashcard_da,0) THEN
        l_flag_insert:= 'T';
        l_desc := 'Change on x_cashcard_da';
    END IF;
    IF NVL(:NEW.x_cashcard_proxy,0) != NVL(:OLD.x_cashcard_proxy,0) THEN
        l_flag_insert:= 'T';
        IF l_desc IS NULL THEN
           l_desc :='Change on x_cashcard_proxy';
        ELSE
            l_desc :=l_desc||', x_cashcard_proxy';
        END IF;
    END IF;
    IF NVL(:NEW.x_cashcard_person_id,0) != NVL(:OLD.x_cashcard_person_id,0) THEN
        l_flag_insert:= 'T';
        IF l_desc IS NULL THEN
           l_desc :='Change on x_cashcard_person_id';
        ELSE
            l_desc :=l_desc||', x_cashcard_person_id';
        END IF;
    END IF;
    IF NVL(:NEW.x_client_acnt_id,0) != NVL(:OLD.x_client_acnt_id,0) THEN
        l_flag_insert:= 'T';
        IF l_desc IS NULL THEN
           l_desc :='Change on x_client_acnt_id';
        ELSE
            l_desc :=l_desc||', x_client_acnt_id';
        END IF;
    END IF;
    IF NVL(:NEW.x_client_acnt_num,0) != NVL(:OLD.x_client_acnt_num,0) THEN
        l_flag_insert:= 'T';
        IF l_desc IS NULL THEN
           l_desc :='Change on x_client_acnt_num';
        ELSE
            l_desc :=l_desc||', x_client_acnt_num';
        END IF;
    END IF;
    IF NVL(:NEW.x_payout_option,0) != NVL(:OLD.x_payout_option,0) THEN
        l_flag_insert:= 'T';
        IF l_desc IS NULL THEN
           l_desc :='Change on x_payout_option';
        ELSE
            l_desc :=l_desc||', x_payout_option';
        END IF;
    END IF;

    IF l_flag_insert = 'T' THEN
        INSERT INTO x_referral_events (objid,
                                       x_cashcard_da,
                                       x_cashcard_proxy,
                                       x_cashcard_person_id,
                                       x_client_acnt_id,
                                       x_client_acnt_num,
                                       x_payout_option,
                                       x_event_desc,
                                       x_create_date,
                                       x_event2user_referrers)
             VALUES (sa.sequ_user_referrers_trig.NEXTVAL,
                     :old.x_cashcard_da,
                     :old.x_cashcard_proxy,
                     :old.x_cashcard_person_id,
                     :old.x_client_acnt_id,
                     :old.x_client_acnt_num,
                     :old.x_payout_option,
                     l_desc,
                     SYSDATE,
                     :old.objid);
    END IF;
END;
-- rel Feb 05/2014 PLSQL/SA/Triggers/trig_x_user_referrers.sql 	CR25065: 1.1
/