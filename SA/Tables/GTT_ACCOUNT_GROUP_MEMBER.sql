CREATE GLOBAL TEMPORARY TABLE sa.gtt_account_group_member (
  agm_objid NUMBER(22) NOT NULL,
  agm_esn VARCHAR2(30 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT gtt_account_group_member_pk PRIMARY KEY (agm_objid)
)
ON COMMIT DELETE ROWS;