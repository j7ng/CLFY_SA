CREATE TABLE sa.x_rule_message_master (
  objid NUMBER,
  x_rule_msg_web VARCHAR2(255 BYTE),
  x_rule_msg_webcsr VARCHAR2(255 BYTE),
  x_rule_msg_net10_web VARCHAR2(255 BYTE),
  x_rule_msg_net10_web_espn VARCHAR2(255 BYTE),
  x_rule_msg_net10_webcsr VARCHAR2(255 BYTE),
  x_rule_msg_web_espn VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  x_rule_msg_name VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_rule_message_master ADD SUPPLEMENTAL LOG GROUP dmtsora1677503072_0 (objid, x_rule_msg_name, x_rule_msg_net10_web, x_rule_msg_net10_webcsr, x_rule_msg_net10_web_espn, x_rule_msg_web, x_rule_msg_webcsr, x_rule_msg_web_espn, x_update_stamp, x_update_status, x_update_user) ALWAYS;