CREATE OR REPLACE TRIGGER sa."TRG_CHECK_EMAIL_PHONE" BEFORE INSERT
OR UPDATE ON sa.TABLE_CONTACT REFERENCING OLD
AS
OLD NEW AS NEW FOR EACH ROW
DECLARE
   v_email VARCHAR2(200);
   v_phone VARCHAR2(20);
   v_old_email VARCHAR2(200);
   v_old_phone VARCHAR2(200);
   v_cnt_bad_word        number := 0;
-- Modified this trigger to populate update_stamp for every insert or update on table_contact
-- Modified by V.Shimoga
-- Date: 2/8/05
BEGIN
   :new.x_ss_number := NULL; --Make SSN column NULL
   v_email := :NEW.e_mail;
   v_phone := :NEW.phone;
   v_old_email := :old.e_mail;
   v_old_phone := :old.phone;
   IF (NVL(LTRIM(RTRIM(UPPER(v_email))), 'XX') <> NVL(LTRIM(RTRIM(UPPER(
   v_old_email))), 'XX'))
   AND (v_email IS NOT NULL)
   THEN
      sp_valid_contact_email(v_email);
      :NEW.e_mail := v_email;
   END IF;
   IF (NVL(LTRIM(RTRIM(UPPER(v_phone))), 'XX') <> NVL(LTRIM(RTRIM(UPPER(
   v_old_phone))), 'XX'))
   AND (v_phone IS NOT NULL)
   THEN
      sp_valid_contact_phone(v_phone);
      -- CR53454 Added condition to avoid INVALID_CONTACT_PHONES.
      IF v_phone IS NOT NULL AND NOT ( check_x_parameter ( p_v_x_param_name => 'INVALID_CONTACT_PHONES',
                                                           p_v_x_param_value => v_phone ) )
      THEN
         :NEW.phone := v_phone;
      ELSE
         :NEW.phone := :NEW.x_cust_id;
      END IF;
   END IF;
   :NEW.update_stamp := SYSDATE;
   IF :new.X_DATEOFBIRTH < to_date('01/01/0003','MM/DD/YYYY') then
            :new.X_DATEOFBIRTH := to_date('01/01/1753','MM/DD/YYYY');
    END IF;
  --CR51513 Clean up inappropriate words
  BEGIN
    --Check compound word when it is broken into first and last name.
    select count(*)
    into v_cnt_bad_word
    from sa.adfcrm_inappropriate_words
    where (instr(:new.s_first_name||' '||:new.s_last_name,word) > 0 and
                (word = :new.s_first_name||' '||:new.s_last_name or
                 instr(:new.s_first_name||' '||:new.s_last_name,word||' ') > 0 or
                 instr(:new.s_first_name||' '||:new.s_last_name,' '||word) > 0 or
                 instr(:new.s_first_name||' '||:new.s_last_name,' '||word||' ') > 0
                )
          )
    or --compound word is entered with no spaces.
          (instr(:new.s_first_name||' '||:new.s_last_name,replace(word,' ','')) > 0 and
                (replace(word,' ','') = :new.s_first_name||' '||:new.s_last_name or
                 instr(:new.s_first_name||' '||:new.s_last_name,replace(word,' ','')||' ') > 0 or
                 instr(:new.s_first_name||' '||:new.s_last_name,' '||replace(word,' ','')) > 0 or
                 instr(:new.s_first_name||' '||:new.s_last_name,' '||replace(word,' ','')||' ') > 0
                )
          )
        ;

    if v_cnt_bad_word > 0 then
        :new.first_name := 'NO FIRST NAME';
        :new.s_first_name := 'NO FIRST NAME';
        :new.last_name := 'NO LAST NAME';
        :new.s_last_name := 'NO LAST NAME';
    end if;

    if v_cnt_bad_word = 0 then
        select count(*)
        into v_cnt_bad_word
        from sa.adfcrm_inappropriate_words
       where (instr(:new.s_first_name,word) > 0 and
                (word = :new.s_first_name or
                 instr(:new.s_first_name,word||' ') > 0 or
                 instr(:new.s_first_name,' '||word) > 0 or
                 instr(:new.s_first_name,' '||word||' ') > 0
                )
              )
        or --compound word is entered with no spaces.
              (instr(:new.s_first_name,replace(word,' ','')) > 0 and
                (replace(word,' ','') = :new.s_first_name or
                 instr(:new.s_first_name,replace(word,' ','')||' ') > 0 or
                 instr(:new.s_first_name,' '||replace(word,' ','')) > 0 or
                 instr(:new.s_first_name,' '||replace(word,' ','')||' ') > 0
                )
              )
        ;

        if v_cnt_bad_word > 0 then
            :new.first_name := 'NO FIRST NAME';
            :new.s_first_name := 'NO FIRST NAME';
        end if;

        v_cnt_bad_word := 0;
        select count(*)
        into v_cnt_bad_word
        from sa.adfcrm_inappropriate_words
        where (instr(:new.s_last_name,word) > 0 and
                (word = :new.s_last_name or
                 instr(:new.s_last_name,word||' ') > 0 or
                 instr(:new.s_last_name,' '||word) > 0 or
                instr(:new.s_last_name,' '||word||' ') > 0
                )
              )
        or --compound word is entered with no spaces.
              (instr(:new.s_last_name,replace(word,' ','')) > 0 and
                (replace(word,' ','') = :new.s_last_name or
                 instr(:new.s_last_name,replace(word,' ','')||' ') > 0 or
                 instr(:new.s_last_name,' '||replace(word,' ','')) > 0 or
                 instr(:new.s_last_name,' '||replace(word,' ','')||' ') > 0
                )
              )
        ;

        if v_cnt_bad_word > 0 then
            :new.last_name := 'NO LAST NAME';
            :new.s_last_name := 'NO LAST NAME';
        end if;
    end if;
  END;
END;
/