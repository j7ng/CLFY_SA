CREATE TABLE sa.table_search_limits (
  objid NUMBER,
  source_object NUMBER,
  "SCOPE" VARCHAR2(20 BYTE),
  auto_search_on NUMBER,
  user_read_limit NUMBER,
  user_time_limit NUMBER,
  sys_read_limit NUMBER,
  sys_time_limit NUMBER,
  dev NUMBER,
  search_limits2user NUMBER(*,0)
);
ALTER TABLE sa.table_search_limits ADD SUPPLEMENTAL LOG GROUP dmtsora53202923_0 (auto_search_on, dev, objid, "SCOPE", search_limits2user, source_object, sys_read_limit, sys_time_limit, user_read_limit, user_time_limit) ALWAYS;