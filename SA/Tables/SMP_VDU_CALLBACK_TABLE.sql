CREATE TABLE sa.smp_vdu_callback_table (
  mas_manager VARCHAR2(32 BYTE)
);
ALTER TABLE sa.smp_vdu_callback_table ADD SUPPLEMENTAL LOG GROUP dmtsora478879142_0 (mas_manager) ALWAYS;