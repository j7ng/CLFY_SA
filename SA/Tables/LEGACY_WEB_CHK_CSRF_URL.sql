CREATE TABLE sa.legacy_web_chk_csrf_url (
  objid NUMBER NOT NULL,
  brand VARCHAR2(20 BYTE) NOT NULL,
  chk_csrf_url VARCHAR2(250 BYTE) NOT NULL,
  isactive VARCHAR2(1 BYTE),
  CONSTRAINT legacy_web_chk_csrf_url_pk PRIMARY KEY (objid)
);
COMMENT ON COLUMN sa.legacy_web_chk_csrf_url.objid IS 'Unique id to maintain records.';
COMMENT ON COLUMN sa.legacy_web_chk_csrf_url.brand IS 'At moment NET10.';
COMMENT ON COLUMN sa.legacy_web_chk_csrf_url.chk_csrf_url IS 'Check cross site request forgery url.';
COMMENT ON COLUMN sa.legacy_web_chk_csrf_url.isactive IS 'Yes/No or Active/In-Active status to enforce the check.';