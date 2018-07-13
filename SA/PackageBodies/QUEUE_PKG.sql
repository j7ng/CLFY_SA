CREATE OR REPLACE PACKAGE BODY sa.queue_pkg
   IS
--------------------------------------------------------------------------------------------
--$RCSfile: queue_pkb.sql,v $
--$Revision: 1.14 $
--$Author: akhan $
--$Date: 2016/05/16 21:20:58 $
--$ $Log: queue_pkb.sql,v $
--$ Revision 1.14  2016/05/16 21:20:58  akhan
--$ updated queue filter logic
--$
--$ Revision 1.13  2016/05/13 20:34:35  akhan
--$ oracle version compatibility bug resolved
--$
--$ Revision 1.12  2016/05/13 18:53:36  aganesan
--$ CR41846
--$
--$ Revision 1.11  2016/01/11 19:31:47  akhan
--$ Fixed a bug
--$
--$ Revision 1.10  2016/01/08 16:23:36  akhan
--$ removed unnecessary code
--$
--$ Revision 1.9  2016/01/08 16:18:56  akhan
--$ Added delay parameter
--$
--$ Revision 1.8  2016/01/07 18:41:26  gravella
--$ For Loyality rewards points for ST
--$
--$ Revision 1.5  2015/12/18 19:52:28  nmuthukkaruppan
--$ Adding Grants
--$
--$ Revision 1.4  2015/12/10 17:22:48  akhan
--$ passing uppe_case queue_name
--$
--$ Revision 1.3  2015/12/07 16:43:11  akhan
--$ updated cvs header
--$
--$ Revision 1.2  2015/12/07 16:42:07  akhan
--$ Checkin latest code
--------------------------------------------------------------------------------------------
function message_allowed_on_queue(io_q_payload q_payload_t,allowed_brands in varchar2 ,allowed_source_types in varchar2, allowed_events in varchar2) return boolean is
function instr_all(base_str in varchar2, what in varchar2) return boolean is
  final_base_str varchar2(500);
  found number;
begin
     select concat('"', concat(replace(base_str ,',','","'),'"'))
     into final_base_str
     from dual;

     select count(*)
      into found
      from (
      select trim(column_value) cv
      from xmltable(final_base_str)) a
      where a.cv = what;
    if found > 0 then
      return true;
    else
      return false;
    end if;
end;
begin

   if (allowed_brands = 'ALL' or instr_all(allowed_brands,io_q_payload.brand))
       and ((allowed_source_types = 'ALL' or instr_all(allowed_source_types,io_q_payload.source_type))
       or (allowed_events = 'ALL' or instr_all(allowed_events,io_q_payload.event_name))) then
      return true;
   else
      return false;
   end if;
end;

--------------------------------------------------------------------------------------------
  PROCEDURE add_nameval_elmt(ip_name IN     VARCHAR2,
                              ip_val  IN     VARCHAR2,
                              nv_tab  IN OUT q_nameval_tab)
--------------------------------------------------------------------------------------------
   IS
   BEGIN

     IF NOT add_nameval_elmt(ip_name,
                             ip_val,
                             nv_tab) THEN
       NULL; -- do something later

     END IF;

   END add_nameval_elmt;


--------------------------------------------------------------------------------------------
   FUNCTION add_nameval_elmt(ip_name IN     VARCHAR2,
                             ip_val  IN     VARCHAR2,
                             nv_tab  IN OUT q_nameval_tab)
     RETURN BOOLEAN
--------------------------------------------------------------------------------------------
   IS
     elmt q_nameval_ty := q_nameval_ty(ip_name,
                                       ip_val);
   BEGIN
     nv_tab.extend;
     nv_tab(nv_tab.count) := elmt;

     RETURN TRUE;

   EXCEPTION

   WHEN OTHERS THEN

     RETURN FALSE;

   END add_nameval_elmt;


--------------------------------------------------------------------------------------------
   FUNCTION enq(i_q_name     IN      VARCHAR2,
               io_q_payload  IN  OUT q_payload_t,
               o_op_msg          OUT VARCHAR2,
               ip_delay     IN      number default 0, --delay in seconds(before available for dqueue)
               ip_priority  in      number default 1
               )     RETURN BOOLEAN   IS
--------------------------------------------------------------------------------------------


     enqueue_options            dbms_aq.enqueue_options_t;
     message_properties         dbms_aq.message_properties_t;
     message_handle             RAW(16);
     q_type                     queue_type_tbl.q_type%TYPE;
     v_enq_transform            queue_type_tbl.enq_transformation%type;
     v_allowed_brands           queue_type_tbl.allowed_brands%type;
     v_allowed_events           queue_type_tbl.allowed_events%type;
     v_allowed_source_types     queue_type_tbl.allowed_source_types%type;

   BEGIN

     begin
        SELECT qtt.q_type,enq_transformation, allowed_brands, allowed_events,allowed_source_types
        INTO q_type,v_enq_transform, v_allowed_brands, v_allowed_events,v_allowed_source_types
        FROM queue_type_tbl  qtt
        WHERE upper(qtt.q_name)  = upper(substr(i_q_name,instr(i_q_name,'.')+1));
     exception
         when NO_DATA_FOUND then
            o_op_msg := 'Queue not found :'||i_q_name ;
            return false;
     end;

     IF ( q_type                     != 'BUFFERED') THEN
        enqueue_options.delivery_mode := dbms_aq.persistent;
        enqueue_options.visibility    := dbms_aq.on_commit;
     else
       -- Buffered is set as default
       enqueue_options.delivery_mode := dbms_aq.buffered;
       enqueue_options.visibility    := dbms_aq.immediate;
     END IF;
     enqueue_options.transformation := v_enq_transform;
     message_properties.delay := ip_delay;
     message_properties.priority:= ip_priority;

     if message_allowed_on_queue(io_q_payload,
                                 v_allowed_brands,
                                 v_allowed_source_types,
                                 v_allowed_events) then
       dbms_aq.enqueue(queue_name => i_q_name,
                     enqueue_options => enqueue_options,
                     message_properties => message_properties,
                     payload => io_q_payload,
                     msgid => message_handle);
     end if;
     o_op_msg := 'success';

     RETURN TRUE;

   EXCEPTION

   WHEN OTHERS THEN

     o_op_msg := sqlerrm;
     RETURN FALSE;

   END enq;

--------------------------------------------------------------------------------------------
   FUNCTION dq(i_q_name         IN  VARCHAR2,
               o_q_payload      OUT  q_payload_t,
               o_op_msg         OUT VARCHAR2,
               i_consumer_name  IN  VARCHAR2  default null,
               i_dq_mode          IN  VARCHAR2 default 'REMOVE')
     RETURN BOOLEAN   IS
--------------------------------------------------------------------------------------------

     dequeue_options            dbms_aq.dequeue_options_t;
     message_properties         dbms_aq.message_properties_t;
     message_handle             RAW(16);
     q_type                     queue_type_tbl.q_type%TYPE;
     v_dec_transform            QUEUE_TYPE_TBL.DEQ_TRANSFORMATION%TYPE;
   BEGIN

     BEGIN
       SELECT qtt.q_type,qtt.DEQ_TRANSFORMATION
       INTO q_type, v_dec_transform
       FROM queue_type_tbl  qtt
       WHERE upper(qtt.q_name)  = upper(substr(i_q_name,instr(i_q_name,'.')+1));

     EXCEPTION WHEN OTHERS THEN
        o_op_msg := 'Queue not found :'||i_q_name;
        RETURN FALSE;
     END;

     -- Buffered is set as default
     dequeue_options.consumer_name := i_consumer_name;
 --    dequeue_options.wait          := dbms_aq.no_wait;
     dequeue_options.navigation    := dbms_aq.first_message;

     IF ( q_type                     != 'BUFFERED') THEN
         dequeue_options.visibility    := dbms_aq.on_commit;
         dequeue_options.delivery_mode := dbms_aq.persistent;
     else
         dequeue_options.delivery_mode := dbms_aq.buffered;
         dequeue_options.visibility    := dbms_aq.immediate;
     end if;

     IF ( i_dq_mode = 'REMOVE') THEN
        dequeue_options.dequeue_mode := DBMS_AQ.REMOVE;
     ELSIF ( i_dq_mode = 'BROWSE') THEN
        dequeue_options.dequeue_mode := DBMS_AQ.BROWSE;
     ELSIF ( i_dq_mode = 'LOCKED') THEN
        dequeue_options.dequeue_mode := DBMS_AQ.LOCKED;
     END IF;

     DBMS_AQ.DEQUEUE(queue_name => i_q_name,
                     dequeue_options => dequeue_options,
                     message_properties => message_properties,
                     payload => o_q_payload,
                     msgid =>  message_handle);


     o_op_msg := 'success';
     commit;
     RETURN TRUE;

  EXCEPTION
      WHEN OTHERS THEN
       o_op_msg := sqlerrm;
       COMMIT;
       RETURN FALSE;

   END dq;

--------------------------------------------------------------------------------------------
   FUNCTION dq(i_q_name     IN      VARCHAR2,
               io_q_payload IN  OUT q_payload_t,
               o_op_msg         OUT VARCHAR2)
     RETURN BOOLEAN   IS
--------------------------------------------------------------------------------------------

     dequeue_options            dbms_aq.dequeue_options_t;
     message_properties         dbms_aq.message_properties_t;
     message_handle             RAW(16);
     q_type                     queue_type_tbl.q_type%TYPE;

   BEGIN

     BEGIN

        SELECT qtt.q_type
          INTO q_type
          FROM queue_type_tbl  qtt
         WHERE upper(qtt.q_name)  = upper(substr(i_q_name,instr(i_q_name,'.')+1));

     EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Add entry to queue_type_tbl'||i_q_name||' not found');
        RETURN FALSE;
     END;

     -- Buffered is set as default
     dequeue_options.consumer_name := NULL;
     dequeue_options.wait          := dbms_aq.no_wait;
     dequeue_options.delivery_mode := dbms_aq.buffered;
     dequeue_options.visibility    := dbms_aq.immediate;
     dequeue_options.navigation    := dbms_aq.first_message;

     IF ( q_type                     != 'BUFFERED') THEN

       dequeue_options.visibility    := dbms_aq.on_commit;
       dequeue_options.delivery_mode := dbms_aq.persistent;

     END IF;

     DBMS_AQ.DEQUEUE(queue_name => i_q_name,
                     dequeue_options => dequeue_options,
                     message_properties => message_properties,
                     payload => io_q_payload,
                     msgid =>  message_handle);

     o_op_msg := 'success';

     RETURN TRUE;

   EXCEPTION
      WHEN OTHERS THEN

       o_op_msg := sqlerrm;
       RETURN FALSE;

   END dq;

--------------------------------------------------------------------------------------------
   FUNCTION read_nameval(nv_tab IN q_nameval_tab)
            RETURN q_nameval_tab pipelined   IS
--------------------------------------------------------------------------------------------
     nv_elm q_nameval_ty;
   BEGIN

     FOR i IN 1..nv_tab.count
     LOOP
       nv_elm := nv_tab(i);
       pipe row(nv_elm);

     END LOOP;

      END read_nameval;



END queue_pkg;
/