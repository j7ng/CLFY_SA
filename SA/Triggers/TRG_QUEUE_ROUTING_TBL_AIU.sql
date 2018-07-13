CREATE OR REPLACE TRIGGER sa.trg_queue_routing_tbl_aiu before
   INSERT OR UPDATE
    ON sa.queue_routing_tbl REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
    DECLARE missing_queues VARCHAR2(500);
        v_tq varchar2(200);
  BEGIN
    :new.source_type   := upper(:new.source_type);
    :new.source_tbl    := upper(:new.source_tbl);
    :new.source_status := upper(:new.source_status);
    :new.step_complete := upper(:new.step_complete);
    v_tq := '"'||REPLACE(:new.target_queues, ',', '","')||'"' ;
    FOR i IN (WITH qu AS
                  (SELECT 'CLFY_'
                          ||upper(trim(column_value))
                          ||'_Q' name
                     FROM xmltable(v_tq))
     SELECT qu.name
       FROM qu,
            all_queues a
      WHERE a.name(+)   = qu.name
        AND a.name IS NULL
    )
    LOOP
      missing_queues := missing_queues||','|| i.name;
    END LOOP;
    IF missing_queues IS NOT NULL THEN
      raise_application_error(-20039, 'No queues '||SUBSTR(missing_queues, 2)||
      chr(10) ||' Please add them first ');
    END IF;
  END;
/