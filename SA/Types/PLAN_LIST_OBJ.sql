CREATE OR REPLACE type sa.PLAN_LIST_OBJ
 -------------->> this affects SA.ENROLLMENT_PKG.getenrollmentdetails
IS object ( planid                number,
            plan_part_number      varchar2(50),
            plan_name             varchar2(40),
            PLAN_DESCRIPTION      varchar2(1000),
            PLAN_TYPE             varchar2(30),
            paymentsourceid       number,
            payment_type          varchar2(20),
            payment_status        varchar2(10),
            credit_card_no        varchar2(255),
            credit_card_exp       varchar2(10),
            bank_accnt_no         varchar2(400),
            NEXT_CHARGE_DATE      date,
            enrollment_status     varchar2(30),
            auto_refill_max_limit number
           )
/