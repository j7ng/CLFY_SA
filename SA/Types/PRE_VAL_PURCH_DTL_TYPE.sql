CREATE OR REPLACE TYPE sa.pre_val_purch_dtl_type AS OBJECT
(objid                        number       ,
 part_numbers                 varchar2(30) ,
 card_qty                     number(4,0)  ,
 esn                          varchar2(20) ,
 program_type                 varchar2(30) ,
 program_name                 varchar2(40) ,
 cc_schedule_date             varchar2(30) ,
 count_esn_primary            varchar2(3)  ,
 count_esn_secondary          varchar2(3)  ,
 cc_scheduled                 varchar2(30) ,
 preval_purch2promotion       number       ,
 promo_code                   varchar2(10) ,
 preval_pur_dtl2program       number       ,
 preval_pur_dtl2pre_purch_hdr number       ,
 idn_user_change_last         varchar2(50) ,
 dte_change_last              DATE         ,
 CONSTRUCTOR FUNCTION pre_val_purch_dtl_type RETURN SELF AS RESULT
)
/