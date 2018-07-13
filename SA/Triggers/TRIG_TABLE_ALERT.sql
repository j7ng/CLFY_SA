CREATE OR REPLACE TRIGGER sa."TRIG_TABLE_ALERT"
BEFORE INSERT OR UPDATE ON sa.TABLE_ALERT
referencing old as old new as new
FOR EACH ROW
DECLARE
    ip_brand_name varchar2(30);
    ip_carrier_id VARCHAR2(10);
    ip_script_type VARCHAR2(4000);
    ip_script_id VARCHAR2(4000);
    ip_part_class VARCHAR2(4000);
    op_objid varchar2(30);
    op_description varchar2(1000);
    op_script_text varchar2(4000);
    op_publish_by varchar2(30);
    op_publish_date date;
    OP_SM_LINK VARCHAR2(300);
    IP_LANGUAGE VARCHAR2(30);
    ip_sourcesystem     varchar2(30);
  BEGIN
    IF :NEW.HOT = 1 AND
       :NEW.X_WEB_TEXT_ENGLISH IS NULL AND
       :NEW.X_WEB_TEXT_SPANISH IS NULL
    THEN
       begin
          SELECT SCRIPT_TYPE, SCRIPT_ID
          INTO ip_script_type, ip_script_id
          FROM   sa.ADFCRM_SOLUTION
          where solution_name = 'ALERT_DEFAULT_SCRIPT';
       exception
          WHEN no_data_found THEN
              ip_script_type := '#####';
              ip_script_id := '#####';
       END;

       if (ip_script_id   <> '#####' and
           ip_script_type <> '#####' )
       then
           ip_sourcesystem := 'TAS';
           ip_brand_name := 'GENERIC';
           ip_carrier_id := null;

           ip_language := 'ENGLISH';

          SCRIPTS_PKG.GET_SCRIPT_PRC(
            ip_sourcesystem => ip_sourcesystem,
            ip_brand_name => ip_brand_name,
            ip_script_type => ip_script_type,
            IP_SCRIPT_ID => IP_SCRIPT_ID,
            ip_language => ip_language,
            ip_carrier_id => ip_carrier_id,
            ip_part_class => ip_part_class,
            op_objid => op_objid,
            op_description => op_description,
            op_script_text => op_script_text,
            op_publish_by => op_publish_by,
            op_publish_date => op_publish_date,
            op_sm_link => op_sm_link
          );

          if op_script_text not like 'SCRIPT MISSING%' then
             :NEW.X_WEB_TEXT_ENGLISH := op_script_text;
          END IF;

          ip_language := 'SPANISH';

          SCRIPTS_PKG.GET_SCRIPT_PRC(
            ip_sourcesystem => ip_sourcesystem,
            ip_brand_name => ip_brand_name,
            ip_script_type => ip_script_type,
            IP_SCRIPT_ID => IP_SCRIPT_ID,
            ip_language => ip_language,
            ip_carrier_id => ip_carrier_id,
            ip_part_class => ip_part_class,
            op_objid => op_objid,
            op_description => op_description,
            op_script_text => op_script_text,
            op_publish_by => op_publish_by,
            op_publish_date => op_publish_date,
            op_sm_link => op_sm_link
          );

          if op_script_text not like 'SCRIPT MISSING%' then
             :NEW.x_web_text_spanish := op_script_text;
          END IF;
       END IF;
    END IF;
END;
/