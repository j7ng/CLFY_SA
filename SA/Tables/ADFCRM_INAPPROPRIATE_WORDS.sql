CREATE TABLE sa.adfcrm_inappropriate_words (
  word VARCHAR2(100 BYTE) NOT NULL CHECK (WORD = UPPER(WORD)),
  word_language VARCHAR2(50 BYTE) CHECK (WORD_LANGUAGE = UPPER(WORD_LANGUAGE)),
  PRIMARY KEY (word)
);
COMMENT ON TABLE sa.adfcrm_inappropriate_words IS 'This table is used to store inappropriate.';
COMMENT ON COLUMN sa.adfcrm_inappropriate_words.word IS 'Inappropriate word';
COMMENT ON COLUMN sa.adfcrm_inappropriate_words.word_language IS 'Word language';