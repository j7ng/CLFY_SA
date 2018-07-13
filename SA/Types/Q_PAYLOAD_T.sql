CREATE OR REPLACE type sa.q_payload_t
AS object
(
    source_type   VARCHAR2(80), --queue_routing_tbl
    source_tbl    VARCHAR2(80), --queue_routing_tbl
    source_status VARCHAR2(80), --queue_routing_tbl
    esn           VARCHAR2(30),
    MIN           VARCHAR2(30),
    brand         VARCHAR2(30),
    event_name    VARCHAR2(30),
    nameval       q_nameval_tab,
    step_complete VARCHAR2(30) --queue_routing_tbl
);
/