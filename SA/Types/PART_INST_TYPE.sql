CREATE OR REPLACE TYPE sa."PART_INST_TYPE" AS OBJECT
------------------------------------------------------------------------
--$RCSfile: part_inst_type_spec.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/29 20:42:36 $
--$ $Log: part_inst_type_spec.sql,v $
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
(
  part_inst_objid            NUMBER        ,
  part_good_qty              NUMBER        ,
  part_bad_qty               NUMBER        ,
  part_serial_no             VARCHAR2(30)  ,
  part_mod                   VARCHAR2(10)  ,
  part_bin                   VARCHAR2(20)  ,
  last_pi_date               DATE          ,
  pi_tag_no                  VARCHAR2(8)   ,
  last_cycle_ct              DATE          ,
  next_cycle_ct              DATE          ,
  last_mod_time              DATE          ,
  last_trans_time            DATE          ,
  transaction_id             VARCHAR2(20)  ,
  date_in_serv               DATE          ,
  warr_end_date              DATE          ,
  repair_date                DATE          ,
  part_status                VARCHAR2(40)  ,
  pick_request               VARCHAR2(255) ,
  good_res_qty               NUMBER        ,
  bad_res_qty                NUMBER        ,
  dev                        NUMBER        ,
  insert_date                DATE          ,
  sequence                   NUMBER        ,
  creation_date              DATE          ,
  po_num                     VARCHAR2(30)  ,
  red_code                   VARCHAR2(30)  ,
  domain                     VARCHAR2(20)  ,
  deactivation_flag          NUMBER        ,
  reactivation_flag          NUMBER        ,
  cool_end_date              DATE          ,
  part_inst_status           VARCHAR2(20)  ,
  npa                        VARCHAR2(10)  ,
  nxx                        VARCHAR2(10)  ,
  ext                        VARCHAR2(10)  ,
  order_number               VARCHAR2(40)  ,
  part_inst2inv_bin          NUMBER        ,
  n_part_inst2part_mod       NUMBER        ,
  fulfill2demand_dtl         NUMBER        ,
  part_inst2x_pers           NUMBER        ,
  part_inst2x_new_pers       NUMBER        ,
  part_inst2carrier_mkt      NUMBER        ,
  created_by2user            NUMBER        ,
  status2x_code_table        NUMBER        ,
  part_to_esn2part_inst      NUMBER        ,
  part_inst2site_part        NUMBER        ,
  ld_processed               VARCHAR2(10)  ,
  dtl2part_inst              NUMBER        ,
  eco_new2part_inst          NUMBER        ,
  hdr_ind                    NUMBER        ,
  msid                       VARCHAR2(30)  ,
  part_inst2contact          NUMBER        ,
  iccid                      VARCHAR2(30)  ,
  clear_tank                 NUMBER        ,
  port_in                    NUMBER        ,
  hex_serial_no              VARCHAR2(30)  ,
  parent_part_serial_no      VARCHAR2(30)  ,
  wf_mac_id                  VARCHAR2(50)  ,
  cpo_manufacturer           VARCHAR2(240) ,
  response                   VARCHAR2(1000),
  numeric_value              NUMBER        ,
  varchar2_value             VARCHAR2(1000),
  CONSTRUCTOR FUNCTION part_inst_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION part_inst_type ( i_part_inst_objid IN NUMBER) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION part_inst_type ( i_esn IN VARCHAR2) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_part_inst_type IN part_inst_type ) RETURN part_inst_type,
  MEMBER FUNCTION ins RETURN part_inst_type,
  MEMBER FUNCTION upd ( i_part_inst_objid IN NUMBER) RETURN BOOLEAN
);
/
CREATE OR REPLACE TYPE BODY sa."PART_INST_TYPE" AS
------------------------------------------------------------------------
--$RCSfile: part_inst_type.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/29 20:42:36 $
--$ $Log: part_inst_type.sql,v $
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
CONSTRUCTOR FUNCTION part_inst_type RETURN SELF AS RESULT AS
BEGIN
 RETURN;
END ;
CONSTRUCTOR FUNCTION part_inst_type ( i_part_inst_objid IN NUMBER) RETURN SELF AS RESULT AS
BEGIN
	IF i_part_inst_objid is NOT NULL THEN
	SELF.response := 'PART INST ID NOT PASSED';
	END IF;

	--Query the table
	select part_inst_type ( objid                      ,
	                        part_good_qty              ,
	                        part_bad_qty               ,
	                        part_serial_no             ,
	                        part_mod                   ,
	                        part_bin                   ,
	                        last_pi_date               ,
	                        pi_tag_no                  ,
	                        last_cycle_ct              ,
	                        next_cycle_ct              ,
	                        last_mod_time              ,
	                        last_trans_time            ,
	                        transaction_id             ,
	                        date_in_serv               ,
	                        warr_end_date              ,
	                        repair_date                ,
	                        part_status                ,
	                        pick_request               ,
	                        good_res_qty               ,
	                        bad_res_qty                ,
	                        dev                        ,
	                        x_insert_date              ,
	                        x_sequence                 ,
	                        x_creation_date            ,
	                        x_po_num                   ,
	                        x_red_code                 ,
	                        x_domain                   ,
	                        x_deactivation_flag        ,
	                        x_reactivation_flag        ,
	                        x_cool_end_date            ,
	                        x_part_inst_status         ,
	                        x_npa                      ,
	                        x_nxx                      ,
	                        x_ext                      ,
	                        x_order_number             ,
	                        part_inst2inv_bin          ,
	                        n_part_inst2part_mod       ,
	                        fulfill2demand_dtl         ,
	                        part_inst2x_pers           ,
	                        part_inst2x_new_pers       ,
	                        part_inst2carrier_mkt      ,
	                        created_by2user            ,
	                        status2x_code_table        ,
	                        part_to_esn2part_inst      ,
	                        x_part_inst2site_part      ,
	                        x_ld_processed             ,
	                        dtl2part_inst              ,
	                        eco_new2part_inst          ,
	                        hdr_ind                    ,
	                        x_msid                     ,
	                        x_part_inst2contact        ,
	                        x_iccid                    ,
	                        x_clear_tank               ,
	                        x_port_in                  ,
	                        x_hex_serial_no            ,
	                        x_parent_part_serial_no    ,
	                        x_wf_mac_id                ,
	                        cpo_manufacturer           ,
                                null                       ,
                                null                       ,
                                null
                    )
	INTO SELF
	FROM table_part_inst
	WHERE objid= i_part_inst_objid;
	--G5

	SELF.response := 'SUCCESS';

	RETURN;

EXCEPTION
  WHEN OTHERS THEN
   SELF.response := 'PI HIST ID NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
   SELF.part_inst_objid := i_part_inst_objid;
   RETURN;
END part_inst_type;

CONSTRUCTOR FUNCTION part_inst_type ( i_esn IN VARCHAR2) RETURN SELF AS RESULT AS
BEGIN
 IF i_esn is NOT NULL THEN
   SELF.response := 'ESN NOT PASSED';
 END IF;

		--Query the table
 SELECT part_inst_type ( objid                      ,
                         part_good_qty              ,
                         part_bad_qty               ,
                         part_serial_no             ,
                         part_mod                   ,
                         part_bin                   ,
                         last_pi_date               ,
                         pi_tag_no                  ,
                         last_cycle_ct              ,
                         next_cycle_ct              ,
                         last_mod_time              ,
                         last_trans_time            ,
                         transaction_id             ,
                         date_in_serv               ,
                         warr_end_date              ,
                         repair_date                ,
                         part_status                ,
                         pick_request               ,
                         good_res_qty               ,
                         bad_res_qty                ,
                         dev                        ,
                         x_insert_date              ,
                         x_sequence                 ,
                         x_creation_date            ,
                         x_po_num                   ,
                         x_red_code                 ,
                         x_domain                   ,
                         x_deactivation_flag        ,
                         x_reactivation_flag        ,
                         x_cool_end_date            ,
                         x_part_inst_status         ,
                         x_npa                      ,
                         x_nxx                      ,
                         x_ext                      ,
                         x_order_number             ,
                         part_inst2inv_bin          ,
                         n_part_inst2part_mod       ,
                         fulfill2demand_dtl         ,
                         part_inst2x_pers           ,
                         part_inst2x_new_pers       ,
                         part_inst2carrier_mkt      ,
                         created_by2user            ,
                         status2x_code_table        ,
                         part_to_esn2part_inst      ,
                         x_part_inst2site_part      ,
                         x_ld_processed             ,
                         dtl2part_inst              ,
                         eco_new2part_inst          ,
                         hdr_ind                    ,
                         x_msid                     ,
                         x_part_inst2contact        ,
                         x_iccid                    ,
                         x_clear_tank               ,
                         x_port_in                  ,
                         x_hex_serial_no            ,
                         x_parent_part_serial_no    ,
                         x_wf_mac_id                ,
                         cpo_manufacturer           ,
                         null                       ,
                         null                       ,
                         null
             )
 INTO SELF
 FROM table_part_inst
 WHERE part_serial_no= i_esn;
 --G5

 SELF.response := 'SUCCESS';

   RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response   := 'PART INST NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.part_serial_no := i_esn;

      --
      RETURN;
END;
MEMBER FUNCTION exist RETURN BOOLEAN AS
BEGIN
 RETURN NULL;
END;
MEMBER FUNCTION ins ( i_part_inst_type IN part_inst_type ) RETURN part_inst_type AS
pi  part_inst_type := i_part_inst_type;
BEGIN
  IF pi.part_inst_objid IS NULL THEN
    pi.part_inst_objid  := sa.sequ_part_inst.nextval;
  END IF;

  pi.last_pi_date    :=  to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM');
  pi.last_cycle_ct   :=  to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM');
  pi.next_cycle_ct   :=  to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM');
  pi.last_mod_time   :=  to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM');
  pi.last_trans_time :=  to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM');
  Pi.date_in_serv    :=  to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM');
  pi.repair_date     :=  to_timestamp('01-JAN-53','DD-MON-RR HH.MI.SSXFF AM');


 INSERT
  INTO table_part_inst
    (objid                    ,
     part_good_qty            ,
     part_bad_qty             ,
     part_serial_no           ,
     part_mod                 ,
     part_bin                 ,
     last_pi_date             ,
     pi_tag_no                ,
     last_cycle_ct            ,
     next_cycle_ct            ,
     last_mod_time            ,
     last_trans_time          ,
     transaction_id           ,
     date_in_serv             ,
     warr_end_date            ,
     repair_date              ,
     part_status              ,
     pick_request             ,
     good_res_qty             ,
     bad_res_qty              ,
     dev                      ,
     x_insert_date            ,
     x_sequence               ,
     x_creation_date          ,
     x_po_num                 ,
     x_domain                 ,
     x_deactivation_flag      ,
     x_reactivation_flag      ,
     x_cool_end_date          ,
     x_part_inst_status       ,
     x_npa                    ,
     x_nxx                    ,
     x_ext                    ,
     x_order_number           ,
     part_inst2inv_bin        ,
     n_part_inst2part_mod     ,
     fulfill2demand_dtl       ,
     part_inst2x_pers         ,
     part_inst2x_new_pers     ,
     part_inst2carrier_mkt    ,
     created_by2user          ,
     status2x_code_table      ,
     part_to_esn2part_inst    ,
     x_part_inst2site_part    ,
     x_ld_processed           ,
     dtl2part_inst            ,
     eco_new2part_inst        ,
     hdr_ind                  ,
     x_msid                   ,
     x_part_inst2contact      ,
     x_iccid                  ,
     x_clear_tank             ,
     x_port_in                ,
     x_hex_serial_no          ,
     x_parent_part_serial_no  ,
     x_wf_mac_id              ,
		 cpo_manufacturer
     )
     VALUES
     (
      pi.part_inst_objid         ,
      pi.part_good_qty           ,
      pi.part_bad_qty            ,
      pi.part_serial_no          ,
      pi.part_mod                ,
      pi.part_bin                ,
      pi.last_pi_date            ,
      pi.pi_tag_no               ,
      pi.last_cycle_ct           ,
      pi.next_cycle_ct           ,
      pi.last_mod_time           ,
      pi.last_trans_time         ,
      pi.transaction_id          ,
      pi.date_in_serv            ,
      pi.warr_end_date           ,
      pi.repair_date             ,
      pi.part_status             ,
      pi.pick_request            ,
      pi.good_res_qty            ,
      pi.bad_res_qty             ,
      pi.dev                     ,
      pi.insert_date             ,
      pi.sequence                ,
      pi.creation_date           ,
      pi.po_num                  ,
      pi.domain                  ,
      pi.deactivation_flag       ,
      pi.reactivation_flag       ,
      pi.cool_end_date           ,
      pi.part_inst_status        ,
      pi.npa                     ,
      pi.nxx                     ,
      pi.ext                     ,
      pi.order_number            ,
      pi.part_inst2inv_bin       ,
      pi.n_part_inst2part_mod    ,
      pi.fulfill2demand_dtl      ,
      pi.part_inst2x_pers        ,
      pi.part_inst2x_new_pers    ,
      pi.part_inst2carrier_mkt   ,
      pi.created_by2user         ,
      pi.status2x_code_table     ,
      pi.part_to_esn2part_inst   ,
      pi.part_inst2site_part     ,
      pi.ld_processed            ,
      pi.dtl2part_inst           ,
      pi.eco_new2part_inst       ,
      pi.hdr_ind                 ,
      pi.msid                    ,
      pi.part_inst2contact       ,
      pi.iccid                   ,
      pi.clear_tank              ,
      pi.port_in                 ,
      pi.hex_serial_no           ,
      pi.parent_part_serial_no   ,
      pi.wf_mac_id               ,
      pi.cpo_manufacturer
     );

  -- set Success Response
  pi.response  := CASE WHEN pi.response IS NULL THEN 'SUCCESS' ELSE pi.response || '|SUCCESS' END;
    RETURN pi;
EXCEPTION
WHEN OTHERS THEN
  pi.response := pi.response || '|ERROR INSERTING PROGRAM PURCH DTL RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN pi;

END;
MEMBER FUNCTION ins RETURN part_inst_type AS
  pi   part_inst_type := SELF;
  i    part_inst_type;
BEGIN
  i := pi.ins ( i_part_inst_type => pi );
  RETURN i;
END;

MEMBER FUNCTION upd ( i_part_inst_objid IN NUMBER) RETURN BOOLEAN AS
BEGIN
 RETURN NULL;
END;

END;
/