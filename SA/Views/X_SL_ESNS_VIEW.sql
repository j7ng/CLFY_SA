CREATE OR REPLACE FORCE VIEW sa.x_sl_esns_view (combo,lid,x_esn) AS
SELECT DISTINCT LID||','||X_ESN, LID, X_ESN from sa.X_SL_HIST;