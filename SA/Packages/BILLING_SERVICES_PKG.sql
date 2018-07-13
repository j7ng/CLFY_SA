CREATE OR REPLACE package sa.billing_services_pkg
is

--for TAS
function hpp_next_charge_date (i_esn in varchar2) return date;

Procedure sp_enrolled_no_account (i_pgm_class in VARCHAR2);

end billing_services_pkg;
/