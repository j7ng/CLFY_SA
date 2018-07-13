CREATE OR REPLACE PACKAGE sa.imei_pkg
AS
  --------------------------------------------------------------------------------
--CR56516
PROCEDURE validate_imei_mismatch(
                                  i_esn               IN x_imei_mismatch.new_esn%TYPE,
                                  i_min               IN x_imei_mismatch.min%TYPE,
                                  o_error_code        OUT VARCHAR2,
                                  o_err_msg           OUT VARCHAR2,
                                  i_carrier_response  IN x_imei_mismatch.carrier_response%TYPE DEFAULT NULL
                                );

END imei_pkg;
/