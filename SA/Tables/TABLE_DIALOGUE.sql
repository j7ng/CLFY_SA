CREATE TABLE sa.table_dialogue (
  objid NUMBER,
  dev NUMBER,
  title VARCHAR2(255 BYTE),
  s_title VARCHAR2(255 BYTE),
  id_number VARCHAR2(40 BYTE),
  creation_time DATE,
  last_update DATE,
  arch_ind NUMBER,
  dialogue2condition NUMBER,
  dialogue_orig2user NUMBER,
  dialogue_owner2user NUMBER,
  dialogue_wip2wipbin NUMBER,
  dialogue_currq2queue NUMBER,
  dialogue_prevq2queue NUMBER,
  dialogue_sts2gbst_elm NUMBER,
  dialogue_pty2gbst_elm NUMBER
);
ALTER TABLE sa.table_dialogue ADD SUPPLEMENTAL LOG GROUP dmtsora521470368_0 (arch_ind, creation_time, dev, dialogue2condition, dialogue_currq2queue, dialogue_orig2user, dialogue_owner2user, dialogue_prevq2queue, dialogue_pty2gbst_elm, dialogue_sts2gbst_elm, dialogue_wip2wipbin, id_number, last_update, objid, s_title, title) ALWAYS;
COMMENT ON TABLE sa.table_dialogue IS 'Records a series of communications which comprise a dialogue';
COMMENT ON COLUMN sa.table_dialogue.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_dialogue.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_dialogue.title IS 'Dialogue title or subject';
COMMENT ON COLUMN sa.table_dialogue.id_number IS 'Unique dialogue number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_dialogue.creation_time IS 'Date and time the dialogue was created';
COMMENT ON COLUMN sa.table_dialogue.last_update IS 'Date and time the dialogue was modified';
COMMENT ON COLUMN sa.table_dialogue.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_dialogue.dialogue2condition IS 'The condition of the dialogue';
COMMENT ON COLUMN sa.table_dialogue.dialogue_orig2user IS 'The user who originated the dialogue';
COMMENT ON COLUMN sa.table_dialogue.dialogue_owner2user IS 'The user who owns the dialogue';
COMMENT ON COLUMN sa.table_dialogue.dialogue_wip2wipbin IS 'The WIPbin containing the dialogue';
COMMENT ON COLUMN sa.table_dialogue.dialogue_currq2queue IS 'The queue to which the dialogue is dispatched';
COMMENT ON COLUMN sa.table_dialogue.dialogue_prevq2queue IS 'The queue from which the dialogue was accepted; for temporary accept';
COMMENT ON COLUMN sa.table_dialogue.dialogue_sts2gbst_elm IS 'Status of the dialogue';
COMMENT ON COLUMN sa.table_dialogue.dialogue_pty2gbst_elm IS 'Priority of the dialogue';