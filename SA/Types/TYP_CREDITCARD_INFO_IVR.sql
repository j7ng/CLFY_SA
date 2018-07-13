CREATE OR REPLACE TYPE sa.typ_creditcard_info_ivr AS OBJECT
(   masked_card_number VARCHAR2(250),
    card_type          VARCHAR2(50) ,
    exp_date           VARCHAR2(50) ,
    security_code      VARCHAR2(255),
    cvv                NUMBER       ,
    cc_enc_number      VARCHAR2(255),
    key_enc_number     VARCHAR2(255),
    cc_enc_algorithm   VARCHAR2(128),
    key_enc_algorithm  VARCHAR2(255),
    CC_ENC_CERT        VARCHAR2(64) ,
	pymnt_src_objid    NUMBER       ,
    billing_zip_code   VARCHAR2(20) ,
    constructor FUNCTION typ_creditcard_info_ivr RETURN SELF AS RESULT
);
/