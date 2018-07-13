CREATE TABLE sa.arch_x_tracking_visitor (
  objid NUMBER,
  x_visitor_id NUMBER,
  x_visitor_visit_count NUMBER,
  x_visitor_date DATE,
  x_visitor_status VARCHAR2(20 BYTE),
  x_visitor_order_id VARCHAR2(30 BYTE),
  x_visitor_amount NUMBER(19,2),
  x_track_visitor2x_track_acct NUMBER,
  x_track_visitor2x_track_site NUMBER,
  x_track_visitor2x_track_camp NUMBER,
  x_track_visitor2x_track_elem NUMBER,
  x_track_visitor2x_track_pos NUMBER,
  x_track_visitor2x_target NUMBER,
  x_track_visitor2x_status NUMBER
);
ALTER TABLE sa.arch_x_tracking_visitor ADD SUPPLEMENTAL LOG GROUP dmtsora1921529119_0 (objid, x_track_visitor2x_status, x_track_visitor2x_target, x_track_visitor2x_track_acct, x_track_visitor2x_track_camp, x_track_visitor2x_track_elem, x_track_visitor2x_track_pos, x_track_visitor2x_track_site, x_visitor_amount, x_visitor_date, x_visitor_id, x_visitor_order_id, x_visitor_status, x_visitor_visit_count) ALWAYS;