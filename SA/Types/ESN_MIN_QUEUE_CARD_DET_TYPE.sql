CREATE OR REPLACE TYPE sa.esn_min_queue_card_det_type  AS OBJECT
					(esn                        VARCHAR2(30),
					 min                       	VARCHAR2(20),
           pin_to_exclude             VARCHAR2(30),
					 queue_card_days            NUMBER,
					 err_code							      VARCHAR2(100),
					 err_msg								    VARCHAR2(4000),
					-- Constructor used to initialize the entire type
					constructor function esn_min_queue_card_det_type  return self as result
					);
/