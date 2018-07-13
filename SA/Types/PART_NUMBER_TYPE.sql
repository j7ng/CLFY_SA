CREATE OR REPLACE TYPE sa.part_number_type
IS
 OBJECT
 ( part_number_objid              NUMBER        ,
   notes                          VARCHAR2(255) ,
   description                    VARCHAR2(255) ,
   s_description                  VARCHAR2(255) ,
   domain                         VARCHAR2(40)  ,
   s_domain                       VARCHAR2(40)  ,
   part_number                    VARCHAR2(30)  ,
   s_part_number                  VARCHAR2(30)  ,
   model_num                      VARCHAR2(20)  ,
   s_model_num                    VARCHAR2(20)  ,
   active                         VARCHAR2(20)  ,
   std_warranty                   NUMBER        ,
   warr_start_key                 NUMBER        ,
   unit_measure                   VARCHAR2(8)   ,
   sn_track                       NUMBER        ,
   family                         VARCHAR2(20)  ,
   line                           VARCHAR2(20)  ,
   repair_type                    VARCHAR2(20)  ,
   part_type                      VARCHAR2(20)  ,
   weight                         VARCHAR2(20)  ,
   dimension                      VARCHAR2(20)  ,
   dom_serialno                   NUMBER        ,
   dom_uniquesn                   NUMBER        ,
   dom_catalogs                   NUMBER        ,
   dom_boms                       NUMBER        ,
   dom_at_site                    NUMBER        ,
   dom_at_parts                   NUMBER        ,
   dom_at_domain                  NUMBER        ,
   dom_pt_used_bom                NUMBER        ,
   dom_pt_used_dom                NUMBER        ,
   dom_pt_used_warn               NUMBER        ,
   incl_domain                    VARCHAR2(40)  ,
   is_sppt_prog                   NUMBER        ,
   prog_type                      NUMBER        ,
   dom_literature                 NUMBER        ,
   p_standalone                   NUMBER        ,
   p_as_parent                    NUMBER        ,
   p_as_child                     NUMBER        ,
   dom_is_service                 NUMBER        ,
   dev                            NUMBER        ,
   struct_type                    NUMBER        ,
   x_manufacturer                 VARCHAR2(20)  ,
   x_retailcost                   NUMBER(8,2)   ,
   x_redeem_days                  NUMBER        ,
   x_redeem_units                 NUMBER        ,
   x_dll                          NUMBER        ,
   x_programmable_flag            NUMBER        ,
   x_card_type                    VARCHAR2(20)  ,
   x_purch_qty                    NUMBER        ,
   x_purch_card                   NUMBER        ,
   x_technology                   VARCHAR2(20)  ,
   x_upc                          VARCHAR2(30)  ,
   x_web_description              VARCHAR2(255) ,
   x_display_seq                  NUMBER        ,
   x_web_card_desc                VARCHAR2(100) ,
   x_card_plan                    VARCHAR2(30)  ,
   x_wholesale_price              NUMBER(8,2)   ,
   x_sp_web_card_desc             VARCHAR2(100) ,
   x_product_code                 VARCHAR2(10)  ,
   x_sourcesystem                 VARCHAR2(30)  ,
   x_restricted_use               NUMBER        ,
   x_cardless_bundle              VARCHAR2(30)  ,
   part_num2part_class            NUMBER        ,
   part_num2domain                NUMBER        ,
   part_num2site                  NUMBER        ,
   x_exch_digital2part_num        NUMBER        ,
   part_num2default_preload       NUMBER        ,
   part_num2x_promotion           NUMBER        ,
   x_extd_warranty                NUMBER        ,
   x_ota_allowed                  VARCHAR2(10)  ,
   x_ota_dll                      VARCHAR2(10)  ,
   x_ild_type                     NUMBER        ,
   x_data_capable                 NUMBER        ,
   x_conversion                   NUMBER(19,4)  ,
   x_meid_phone                   NUMBER        ,
   part_num2x_data_config         NUMBER        ,
   part_num2bus_org               NUMBER        ,
   device_lock_state              VARCHAR2(30)  ,
   response                       VARCHAR2(1000),
   CONSTRUCTOR FUNCTION part_number_type RETURN SELF AS  RESULT,
   CONSTRUCTOR FUNCTION part_number_type ( i_part_number_objid IN NUMBER ) RETURN SELF AS RESULT,
   MEMBER FUNCTION retrieve ( i_part_number IN VARCHAR2 ) RETURN part_number_type,
   MEMBER FUNCTION exist ( i_part_number IN VARCHAR2,
                           i_domain IN VARCHAR2 ) RETURN BOOLEAN
 );
/
CREATE OR REPLACE TYPE BODY sa.part_number_type
AS
CONSTRUCTOR FUNCTION part_number_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END part_number_type;
--
CONSTRUCTOR FUNCTION part_number_type ( i_part_number_objid IN NUMBER ) RETURN SELF AS RESULT AS
BEGIN

  IF i_part_number_objid IS NULL THEN
    SELF.response := 'PART NUMBER OBJID IS NULL';
    RETURN;
  END IF;

  --Query the table
  SELECT part_number_type ( objid                    ,
                            notes                    ,
                            description              ,
                            s_description            ,
                            domain                   ,
                            s_domain                 ,
                            part_number              ,
                            s_part_number            ,
                            model_num                ,
                            s_model_num              ,
                            active                   ,
                            std_warranty             ,
                            warr_start_key           ,
                            unit_measure             ,
                            sn_track                 ,
                            family                   ,
                            line                     ,
                            repair_type              ,
                            part_type                ,
                            weight                   ,
                            dimension                ,
                            dom_serialno             ,
                            dom_uniquesn             ,
                            dom_catalogs             ,
                            dom_boms                 ,
                            dom_at_site              ,
                            dom_at_parts             ,
                            dom_at_domain            ,
                            dom_pt_used_bom          ,
                            dom_pt_used_dom          ,
                            dom_pt_used_warn         ,
                            incl_domain              ,
                            is_sppt_prog             ,
                            prog_type                ,
                            dom_literature           ,
                            p_standalone             ,
                            p_as_parent              ,
                            p_as_child               ,
                            dom_is_service           ,
                            dev                      ,
                            struct_type              ,
                            x_manufacturer           ,
                            x_retailcost             ,
                            x_redeem_days            ,
                            x_redeem_units           ,
                            x_dll                    ,
                            x_programmable_flag      ,
                            x_card_type              ,
                            x_purch_qty              ,
                            x_purch_card             ,
                            x_technology             ,
                            x_upc                    ,
                            x_web_description        ,
                            x_display_seq            ,
                            x_web_card_desc          ,
                            x_card_plan              ,
                            x_wholesale_price        ,
                            x_sp_web_card_desc       ,
                            x_product_code           ,
                            x_sourcesystem           ,
                            x_restricted_use         ,
                            x_cardless_bundle        ,
                            part_num2part_class      ,
                            part_num2domain          ,
                            part_num2site            ,
                            x_exch_digital2part_num  ,
                            part_num2default_preload ,
                            part_num2x_promotion     ,
                            x_extd_warranty          ,
                            x_ota_allowed            ,
                            x_ota_dll                ,
                            x_ild_type               ,
                            x_data_capable           ,
                            x_conversion             ,
                            x_meid_phone             ,
                            part_num2x_data_config   ,
                            part_num2bus_org         ,
                            device_lock_state        ,
                            null                   --response
                          )
  INTO  SELF
  FROM  sa.table_part_num
  WHERE objid = i_part_number_objid;

  SELF.response := 'SUCCESS';

  RETURN;

EXCEPTION
WHEN OTHERS
THEN
   SELF.response := 'PART NUMBER DATA NOT FOUND' || SUBSTR(SQLERRM,1,100);
   SELF.part_number_objid := i_part_number_objid;
   RETURN;
END part_number_type;
--
MEMBER FUNCTION retrieve( i_part_number IN VARCHAR2 ) RETURN part_number_type AS
  pnt part_number_type := part_number_type();
BEGIN
  IF i_part_number IS NULL THEN
    pnt.response := 'PART NUMBER IS NULL';
    RETURN pnt;
  END IF;

  -- Query the table
  SELECT part_number_type ( objid                    ,
                            notes                    ,
                            description              ,
                            s_description            ,
                            domain                   ,
                            s_domain                 ,
                            part_number              ,
                            s_part_number            ,
                            model_num                ,
                            s_model_num              ,
                            active                   ,
                            std_warranty             ,
                            warr_start_key           ,
                            unit_measure             ,
                            sn_track                 ,
                            family                   ,
                            line                     ,
                            repair_type              ,
                            part_type                ,
                            weight                   ,
                            dimension                ,
                            dom_serialno             ,
                            dom_uniquesn             ,
                            dom_catalogs             ,
                            dom_boms                 ,
                            dom_at_site              ,
                            dom_at_parts             ,
                            dom_at_domain            ,
                            dom_pt_used_bom          ,
                            dom_pt_used_dom          ,
                            dom_pt_used_warn         ,
                            incl_domain              ,
                            is_sppt_prog             ,
                            prog_type                ,
                            dom_literature           ,
                            p_standalone             ,
                            p_as_parent              ,
                            p_as_child               ,
                            dom_is_service           ,
                            dev                      ,
                            struct_type              ,
                            x_manufacturer           ,
                            x_retailcost             ,
                            x_redeem_days            ,
                            x_redeem_units           ,
                            x_dll                    ,
                            x_programmable_flag      ,
                            x_card_type              ,
                            x_purch_qty              ,
                            x_purch_card             ,
                            x_technology             ,
                            x_upc                    ,
                            x_web_description        ,
                            x_display_seq            ,
                            x_web_card_desc          ,
                            x_card_plan              ,
                            x_wholesale_price        ,
                            x_sp_web_card_desc       ,
                            x_product_code           ,
                            x_sourcesystem           ,
                            x_restricted_use         ,
                            x_cardless_bundle        ,
                            part_num2part_class      ,
                            part_num2domain          ,
                            part_num2site            ,
                            x_exch_digital2part_num  ,
                            part_num2default_preload ,
                            part_num2x_promotion     ,
                            x_extd_warranty          ,
                            x_ota_allowed            ,
                            x_ota_dll                ,
                            x_ild_type               ,
                            x_data_capable           ,
                            x_conversion             ,
                            x_meid_phone             ,
                            part_num2x_data_config   ,
                            part_num2bus_org         ,
                            device_lock_state        ,
                            null                   --response
	  					            )
  INTO  pnt
  FROM  sa.table_part_num
  WHERE part_number = i_part_number;

  pnt.response := 'SUCCESS';

  RETURN pnt;

EXCEPTION
WHEN OTHERS
THEN
   pnt.response    := 'PART NUMBER DATA NOT FOUND' || SUBSTR(SQLERRM,1,100);
   pnt.part_number := i_part_number;
   RETURN pnt;
END retrieve;

MEMBER FUNCTION exist ( i_part_number IN VARCHAR2 ,
                        i_domain      IN VARCHAR2 ) RETURN BOOLEAN AS
  n_count    NUMBER;
BEGIN
  --
  IF ( i_part_number IS NULL OR i_domain IS NULL ) THEN
    RETURN FALSE;
  END IF;

  -- Query the table
  SELECT COUNT(1)
  INTO   n_count
  FROM   sa.table_part_num
  WHERE  part_number = i_part_number
  AND    domain = i_domain;

  --
  RETURN (CASE WHEN (n_count > 0) THEN TRUE ELSE FALSE END);

END exist;

END;
-- ANTHILL_TEST PLSQL/SA/Types/part_number_type_body.sql 	CR54805: 1.2
/