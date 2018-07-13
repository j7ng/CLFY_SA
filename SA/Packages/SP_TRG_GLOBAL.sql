CREATE OR REPLACE PACKAGE sa.sp_trg_global  AS
  v_index NUMBER;
  TYPE v_rec_t IS RECORD( contact_objid NUMBER,
                          road_ftp_objid NUMBER,
                          service_id VARCHAR2(30));
  TYPE v_rec_tab_t IS TABLE OF v_rec_t
  INDEX BY BINARY_INTEGER;
  v_rec_tab v_rec_tab_t;
END sp_trg_global;
/