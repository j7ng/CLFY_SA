CREATE OR REPLACE PACKAGE sa.queue_pkg is

--------------------------------------------------------------------------------------------
--$RCSfile: queue_pkg.sql,v $
--$Revision: 1.9 $
--$Author: aganesan $
--$Date: 2016/05/13 18:50:53 $
--$ $Log: queue_pkg.sql,v $
--$ Revision 1.9  2016/05/13 18:50:53  aganesan
--$ CR41846
--$
--$ Revision 1.8  2016/01/11 19:29:26  akhan
--$ Corrected a bug
--$
--$ Revision 1.7  2016/01/08 16:14:40  akhan
--$ introduced a delay parameter
--$
--$ Revision 1.6  2016/01/07 18:42:23  gravella
--$ For Loyality rewards points for ST
--$
--$ Revision 1.3  2015/12/07 16:43:50  akhan
--$ updated CVS header
--$
--$ Revision 1.2  2015/12/07 16:41:33  akhan
--$ Checkin n latest code
--------------------------------------------------------------------------------------------
   PROCEDURE add_nameval_elmt(ip_name IN     VARCHAR2,
                              ip_val  IN     VARCHAR2,
                              nv_tab  IN OUT q_nameval_tab);

   FUNCTION add_nameval_elmt(ip_name IN     VARCHAR2,
                             ip_val  IN     VARCHAR2,
                             nv_tab  IN OUT q_nameval_tab) RETURN BOOLEAN;

   FUNCTION enq(i_q_name     IN      VARCHAR2,
                io_q_payload IN  OUT q_payload_t,
                o_op_msg         OUT VARCHAR2,
                ip_delay     IN      number default 0,--delay in seconds(before available for dqueue)
                ip_priority  in      number default 1
                ) RETURN BOOLEAN;

   FUNCTION dq(i_q_name     IN      VARCHAR2,
               io_q_payload IN  OUT q_payload_t,
               o_op_msg         OUT VARCHAR2) RETURN BOOLEAN;


   FUNCTION dq(i_q_name         IN  VARCHAR2,
               o_q_payload      OUT  q_payload_t,
               o_op_msg         OUT VARCHAR2,
               i_consumer_name  IN  VARCHAR2 default null,
               i_dq_mode        IN  VARCHAR2 default 'REMOVE'
               )
     RETURN BOOLEAN;


   FUNCTION read_nameval(nv_tab IN q_nameval_tab) RETURN q_nameval_tab PIPELINED;


END queue_pkg;
/