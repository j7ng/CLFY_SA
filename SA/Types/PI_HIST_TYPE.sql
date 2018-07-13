CREATE OR REPLACE TYPE sa."PI_HIST_TYPE" AS OBJECT
------------------------------------------------------------------------
--$RCSfile: pi_hist_type_spec.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/30 18:25:23 $
--$ $Log: pi_hist_type_spec.sql,v $
--$ Revision 1.1  2016/11/30 18:25:23  vnainar
--$ CR44729 New files added
--$
--$
--$
-------------------------------------------------------------------------
(
  pi_hist_objid              NUMBER        ,
  status_hist2code_table     NUMBER        ,
  change_date                DATE          ,
  change_reason              VARCHAR2(30)  ,
  cool_end_date              DATE          ,
  creation_date              DATE          ,
  deactivation_flag          NUMBER        ,
  domain                     VARCHAR2(20)  ,
  ext                        VARCHAR2(10)  ,
  insert_date                DATE          ,
  npa                        VARCHAR2(10)  ,
  nxx                        VARCHAR2(10)  ,
  old_ext                    VARCHAR2(10)  ,
  old_npa                    VARCHAR2(10)  ,
  old_nxx                    VARCHAR2(10)  ,
  part_bin                   VARCHAR2(20)  ,
  part_inst_status           VARCHAR2(20)  ,
  part_mod                   VARCHAR2(10)  ,
  part_serial_no             VARCHAR2(30)  ,
  part_status                VARCHAR2(40)  ,
  pi_hist2carrier_mkt        NUMBER        ,
  pi_hist2inv_bin            NUMBER        ,
  pi_hist2part_inst          NUMBER        ,
  pi_hist2part_mod           NUMBER        ,
  pi_hist2user               NUMBER        ,
  pi_hist2new_pers           NUMBER        ,
  pi_hist2pers               NUMBER        ,
  po_num                     VARCHAR2(30)  ,
  reactivation_flag          NUMBER        ,
  red_code                   VARCHAR2(30)  ,
  sequence                   NUMBER        ,
  warr_end_date              DATE          ,
  dev                        NUMBER        ,
  fulfill_hist2demand_dtl    NUMBER        ,
  part_to_esn_hist2part_inst NUMBER        ,
  bad_res_qty                NUMBER        ,
  date_in_serv               DATE          ,
  good_res_qty               NUMBER        ,
  last_cycle_ct              DATE          ,
  last_mod_time              DATE          ,
  last_pi_date               DATE          ,
  last_trans_time            DATE          ,
  next_cycle_ct              DATE          ,
  order_NUMBER               VARCHAR2(40)  ,
  part_bad_qty               NUMBER        ,
  part_good_qty              NUMBER        ,
  pi_tag_no                  VARCHAR2(8)   ,
  pick_request               VARCHAR2(255) ,
  repair_date                DATE          ,
  transaction_id             VARCHAR2(20)  ,
  pi_hist2site_part          NUMBER        ,
  msid                       VARCHAR2(30)  ,
  pi_hist2contact            NUMBER        ,
  iccid                      VARCHAR2(30)  ,
  response                   VARCHAR2(1000),
  numeric_value              NUMBER        ,
  varchar2_value             VARCHAR2(1000),
  CONSTRUCTOR FUNCTION pi_hist_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION pi_hist_type ( i_pi_hist_objid IN NUMBER) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_pi_hist_type IN pi_hist_type ) RETURN pi_hist_type,
  MEMBER FUNCTION ins RETURN pi_hist_type,
  MEMBER FUNCTION upd ( i_pi_hist_objid IN NUMBER) RETURN BOOLEAN,
  MEMBER FUNCTION upd RETURN pi_hist_type
);
/
CREATE OR REPLACE TYPE BODY sa."PI_HIST_TYPE" AS
------------------------------------------------------------------------
--$RCSfile: pi_hist_type.sql,v $
--$Revision: 1.2 $
--$Author: vnainar $
--$Date: 2017/02/07 18:40:09 $
--$ $Log: pi_hist_type.sql,v $
--$ Revision 1.2  2017/02/07 18:40:09  vnainar
--$ reset objid to null in case of error in ins method
--$
--$ Revision 1.1  2016/11/30 18:25:23  vnainar
--$ CR44729 New files added
--$
--$
--$
-------------------------------------------------------------------------

  CONSTRUCTOR FUNCTION pi_hist_type RETURN SELF AS RESULT AS
  BEGIN
    -- TODO: Implementation required for FUNCTION pi_hist_type.pi_hist_type
    RETURN;
  END pi_hist_type;

  CONSTRUCTOR FUNCTION pi_hist_type ( i_pi_hist_objid IN NUMBER) RETURN SELF AS RESULT AS
  BEGIN
		IF i_pi_hist_objid is NOT NULL THEN
		SELF.response := 'PI HIST ID NOT PASSED';
		END IF;

		--Query the table
		select pi_hist_type ( objid                      ,
                          status_hist2x_code_table   ,
                          x_change_date              ,
                          x_change_reason            ,
                          x_cool_end_date            ,
                          x_creation_date            ,
                          x_deactivation_flag        ,
                          x_domain                   ,
                          x_ext                      ,
                          x_insert_date              ,
                          x_npa                      ,
                          x_nxx                      ,
                          x_old_ext                  ,
                          x_old_npa                  ,
                          x_old_nxx                  ,
                          x_part_bin                 ,
                          x_part_inst_status         ,
                          x_part_mod                 ,
                          x_part_serial_no           ,
                          x_part_status              ,
                          x_pi_hist2carrier_mkt      ,
                          x_pi_hist2inv_bin          ,
                          x_pi_hist2part_inst        ,
                          x_pi_hist2part_mod         ,
                          x_pi_hist2user             ,
                          x_pi_hist2x_new_pers       ,
                          x_pi_hist2x_pers           ,
                          x_po_num                   ,
                          x_reactivation_flag        ,
                          x_red_code                 ,
                          x_sequence                 ,
                          x_warr_end_date            ,
                          dev                        ,
                          fulfill_hist2demand_dtl    ,
                          part_to_esn_hist2part_inst ,
                          x_bad_res_qty              ,
                          x_date_in_serv             ,
                          x_good_res_qty             ,
                          x_last_cycle_ct            ,
                          x_last_mod_time            ,
                          x_last_pi_date             ,
                          x_last_trans_time          ,
                          x_next_cycle_ct            ,
                          x_order_number             ,
                          x_part_bad_qty             ,
                          x_part_good_qty            ,
                          x_pi_tag_no                ,
                          x_pick_request             ,
                          x_repair_date              ,
                          x_transaction_id           ,
                          x_pi_hist2site_part        ,
                          x_msid                     ,
                          x_pi_hist2contact          ,
                          x_iccid                    ,
                          null                       ,
                          null                       ,
                          null
                         )
		INTO SELF
		FROM TABLE_X_PI_HIST
		WHERE objid= i_pi_hist_objid;
		--G5

		SELF.response := 'SUCCESS';

		RETURN;

  EXCEPTION
  WHEN OTHERS THEN
  SELF.response := 'PI HIST ID NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
  SELF.pi_hist_objid := i_pi_hist_objid;



    RETURN;
  END pi_hist_type;

  MEMBER FUNCTION exist RETURN BOOLEAN AS
  BEGIN
    -- TODO: Implementation required for FUNCTION pi_hist_type.exist
    RETURN NULL;
  END exist;


  MEMBER FUNCTION ins RETURN pi_hist_type AS
  ht   pi_hist_type := SELF;
  i    pi_hist_type;
BEGIN
  i := ht.ins ( i_pi_hist_type => ht );
  RETURN i;

END ins;


  MEMBER FUNCTION ins ( i_pi_hist_type IN pi_hist_type ) RETURN pi_hist_type AS
  ht  pi_hist_type := i_pi_hist_type;
  BEGIN
  IF ht.pi_hist_objid IS NULL THEN
    ht.pi_hist_objid  := sa.sequ_x_pi_hist.nextval;
  END IF;

  --Assign Time stamp attributes
  IF ht.insert_date IS NULL THEN
   ht.insert_date  := SYSDATE;
  END IF;

  IF  ht.creation_date  IS NULL THEN
   ht.creation_date  := SYSDATE;
  END IF;

          INSERT
          INTO TABLE_X_PI_HIST
          (
         objid,
         status_hist2x_code_table   ,
         x_change_date              ,
         x_change_reason            ,
         x_cool_end_date            ,
         x_creation_date            ,
         x_deactivation_flag        ,
         x_domain                   ,
         x_ext                      ,
         x_insert_date              ,
         x_npa                      ,
         x_nxx                      ,
         x_old_ext                  ,
         x_old_npa                  ,
         x_old_nxx                  ,
         x_part_bin                 ,
         x_part_inst_status         ,
         x_part_mod                 ,
         x_part_serial_no           ,
         x_part_status              ,
         x_pi_hist2carrier_mkt      ,
         x_pi_hist2inv_bin          ,
         x_pi_hist2part_inst        ,
         x_pi_hist2part_mod         ,
         x_pi_hist2user             ,
         x_pi_hist2x_new_pers       ,
         x_pi_hist2x_pers           ,
         x_po_num                   ,
         x_reactivation_flag        ,
         x_red_code                 ,
         x_sequence                 ,
         x_warr_end_date            ,
         dev                        ,
         fulfill_hist2demand_dtl    ,
         part_to_esn_hist2part_inst ,
         x_bad_res_qty              ,
         x_date_in_serv             ,
         x_good_res_qty             ,
         x_last_cycle_ct            ,
         x_last_mod_time            ,
         x_last_pi_date             ,
         x_last_trans_time          ,
         x_next_cycle_ct            ,
         x_order_number             ,
         x_part_bad_qty             ,
         x_part_good_qty            ,
         x_pi_tag_no                ,
         x_pick_request             ,
         x_repair_date              ,
         x_transaction_id           ,
         x_pi_hist2site_part        ,
         x_msid                     ,
         x_pi_hist2contact          ,
         x_iccid
          )
          VALUES
          (
         ht.pi_hist_objid              ,
         ht.status_hist2code_table     ,
         ht.change_date                ,
         ht.change_reason              ,
         ht.cool_end_date              ,
         ht.creation_date              ,
         ht.deactivation_flag          ,
         ht.domain                     ,
         ht.ext                        ,
         ht.insert_date                ,
         ht.npa                        ,
         ht.nxx                        ,
         ht.old_ext                    ,
         ht.old_npa                    ,
         ht.old_nxx                    ,
         ht.part_bin                   ,
         ht.part_inst_status           ,
         ht.part_mod                   ,
         ht.part_serial_no             ,
         ht.part_status                ,
         ht.pi_hist2carrier_mkt        ,
         ht.pi_hist2inv_bin            ,
         ht.pi_hist2part_inst          ,
         ht.pi_hist2part_mod           ,
         ht.pi_hist2user               ,
         ht.pi_hist2new_pers           ,
         ht.pi_hist2pers               ,
         ht.po_num                     ,
         ht.reactivation_flag          ,
         ht.red_code                   ,
         ht.sequence                   ,
         ht.warr_end_date              ,
         ht.dev                        ,
         ht.fulfill_hist2demand_dtl    ,
         ht.part_to_esn_hist2part_inst ,
         ht.bad_res_qty                ,
         ht.date_in_serv               ,
         ht.good_res_qty               ,
         ht.last_cycle_ct              ,
         ht.last_mod_time              ,
         ht.last_pi_date               ,
         ht.last_trans_time            ,
         ht.next_cycle_ct              ,
         ht.order_NUMBER               ,
         ht.part_bad_qty               ,
         ht.part_good_qty              ,
         ht.pi_tag_no                  ,
         ht.pick_request               ,
         ht.repair_date                ,
         ht.transaction_id             ,
         ht.pi_hist2site_part          ,
         ht.msid                       ,
         ht.pi_hist2contact            ,
         ht.iccid
         );

  -- set Success Response
  ht.response  := CASE WHEN ht.response IS NULL THEN 'SUCCESS' ELSE ht.response || '|SUCCESS' END;
  RETURN ht;
EXCEPTION
WHEN OTHERS THEN
  ht.response := ht.response || '|ERROR INSERTING TABLE_X_PI_HIST RECORD: ' || SUBSTR(SQLERRM,1,100);
  ht.pi_hist_objid  := NULL; --reset objid to null in case of error
  --
  RETURN ht;

END ins;

  MEMBER FUNCTION upd ( i_pi_hist_objid IN NUMBER) RETURN BOOLEAN AS
  BEGIN
    -- TODO: Implementation required for FUNCTION pi_hist_type.upd
    RETURN NULL;
  END upd;

  MEMBER FUNCTION upd RETURN pi_hist_type AS
  BEGIN
    -- TODO: Implementation required for FUNCTION pi_hist_type.upd
    RETURN NULL;
  END upd;

END;
/