CREATE TABLE sa.web_agent_login (
  user_id VARCHAR2(50 BYTE) NOT NULL,
  "PASSWORD" VARCHAR2(30 BYTE) NOT NULL
);
ALTER TABLE sa.web_agent_login ADD SUPPLEMENTAL LOG GROUP dmtsora991919551_0 ("PASSWORD", user_id) ALWAYS;