CREATE TABLE sa.aq$_clfy_rtc_qtbl_l (
  msgid RAW(16),
  subscriber# NUMBER,
  "NAME" VARCHAR2(512 BYTE),
  address# NUMBER,
  dequeue_time TIMESTAMP WITH TIME ZONE,
  transaction_id VARCHAR2(30 BYTE),
  dequeue_user VARCHAR2(128 BYTE),
  flags RAW(1)
);