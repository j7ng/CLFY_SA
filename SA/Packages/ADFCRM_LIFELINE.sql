CREATE OR REPLACE package sa.ADFCRM_LIFELINE
AS
  TYPE get_ll_enrollment_details_rec IS RECORD (objid                    NUMBER,
                                                x_program_name           VARCHAR2(40),
                                                x_program_desc           VARCHAR2(1000),
                                                x_enrollment_status      VARCHAR2(30),
                                                allow_de_enroll          VARCHAR2(30)
                                               );

  type get_ll_enrollment_details_tab is table of get_ll_enrollment_details_rec;

  FUNCTION get_lid (i_esn VARCHAR2,
                    i_min VARCHAR2) RETURN  VARCHAR2;

  FUNCTION get_ll_enrollment_details ( i_esn        IN    VARCHAR2,
                                       i_min        IN    VARCHAR2,
                                       i_lid        IN    VARCHAR2,
                                       i_language   IN    VARCHAR2
                                     )
  RETURN get_ll_enrollment_details_tab pipelined;
END ADFCRM_LIFELINE;
/