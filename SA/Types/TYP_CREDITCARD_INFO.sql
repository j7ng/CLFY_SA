CREATE OR REPLACE type sa.typ_creditcard_info as object
(   masked_card_number VARCHAR2(250),
    card_type          VARCHAR2(50),
    exp_date           VARCHAR2(50),
    security_code      VARCHAR2(255),
    cvv                NUMBER,
    cc_enc_number     VARCHAR2(255),
    key_enc_number    VARCHAR2(255),
    cc_enc_algorithm  VARCHAR2(128),
    key_enc_algorithm VARCHAR2(255),
    CC_ENC_CERT       VARCHAR2(64),
    constructor function typ_creditcard_info return self as result
)
/
CREATE OR REPLACE type body sa.typ_creditcard_info is
 constructor function typ_creditcard_info return self as result is
 begin
    return;
 end;
end;
/