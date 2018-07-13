CREATE OR REPLACE TYPE sa.typ_esn_info_rec IS object
  ( Esn         varchar2(30),
    MIN         varchar2(30),
    nick_name   varchar2(30),
    esn_status  varchar2(40),
    ota_flag    varchar2(30),
    buyer_id    varchar2(50),
    buyer_type  varchar2(25),
    org_name    varchar2(80),
    plan_name   varchar2(50),
    plan_desc   varchar2(250),
    esn_part_number varchar2(30))
/