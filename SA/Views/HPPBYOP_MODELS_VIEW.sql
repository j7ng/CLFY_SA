CREATE OR REPLACE FORCE VIEW sa.hppbyop_models_view (manufacturer,"MODEL") AS
SELECT manufacturer,
    model
  FROM
    (SELECT manufacturer,
      model ,
      0 AS sort_seq
    FROM x_byop_models
    WHERE manufacturer = 'APPLE'
    UNION
    SELECT 'LG' AS manufacturer, 'G2' AS model , 0 AS sort_seq FROM dual
    UNION
    SELECT 'NOKIA' AS manufacturer, 'LUMIA 521' AS model , 0 AS sort_seq FROM dual
    UNION
    SELECT 'OTHER' AS manufacturer, 'OTHER' AS model , 2 AS sort_seq FROM dual
    UNION
    SELECT 'SAMSUNG'  AS manufacturer,
      'GALAXY NOTE 3' AS model ,
      0               AS sort_seq
    FROM dual
    UNION
    SELECT 'SAMSUNG' AS manufacturer,
      'GALAXY S III' AS model ,
      0              AS sort_seq
    FROM dual
    UNION
    SELECT 'SAMSUNG' AS manufacturer,
      'GALAXY S4'    AS model ,
      0              AS sort_seq
    FROM dual
	 UNION
    SELECT 'APPLE' AS manufacturer, 'OTHER' AS model , 1 AS sort_seq FROM dual
	 UNION
    SELECT 'LG' AS manufacturer, 'OTHER' AS model , 1 AS sort_seq FROM dual
	 UNION
    SELECT 'NOKIA' AS manufacturer, 'OTHER' AS model , 1 AS sort_seq FROM dual
	 UNION
    SELECT 'SAMSUNG' AS manufacturer, 'OTHER' AS model , 1 AS sort_seq FROM dual
    ORDER BY sort_seq,
      manufacturer
    );