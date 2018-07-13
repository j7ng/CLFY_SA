CREATE OR REPLACE PACKAGE sa."INBOUND_BILLER_PKG" as
  procedure main_prc         (
                           p_cycleNumber   varchar2,
                           p_createDate    varchar2,
                           p_accountNumber varchar2,
                           p_enrollDate    varchar2,
                           p_paymentMode   number,
                           p_accountStatus number,
                           p_status        varchar2,
                           p_firstName     varchar2 DEFAULT NULL,
                           p_lastName      varchar2 DEFAULT NULL,
                           p_address       varchar2 DEFAULT NULL,
                           p_city          varchar2 DEFAULT NULL,
                           p_state         varchar2 DEFAULT NULL,
                           p_zipcode       varchar2 DEFAULT NULL,
                           p_contactPhone  varchar2 DEFAULT NULL,
                           p_msg       OUT varchar2,
                           c_p_status  OUT varchar2
                          );
end inbound_biller_pkg;
/