CREATE OR REPLACE FUNCTION sa."ADFCRM_VERIFY_TECH" (
      ip_zipcode         VARCHAR2,
      ip_phone_part_num  VARCHAR2,
      ip_sim_part_num VARCHAR2)
    RETURN VARCHAR2
  IS
  BEGIN
    sa.nap_SERVICE_pkg.get_list( ip_zipcode, NULL, ip_phone_part_num, NULL, ip_sim_part_num, NULL);
    IF sa.nap_SERVICE_pkg.big_tab.count>0 THEN
      RETURN 'HAS COVERAGE';
    ELSE
      RETURN 'NO COVERAGE';
    END IF;
  END ADFCRM_VERIFY_TECH;
/