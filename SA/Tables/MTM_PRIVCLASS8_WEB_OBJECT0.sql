CREATE TABLE sa.mtm_privclass8_web_object0 (
  privclass2web_object NUMBER NOT NULL,
  web_object2privclass NUMBER NOT NULL
);
ALTER TABLE sa.mtm_privclass8_web_object0 ADD SUPPLEMENTAL LOG GROUP dmtsora436287915_0 (privclass2web_object, web_object2privclass) ALWAYS;