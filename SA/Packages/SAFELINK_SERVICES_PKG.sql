CREATE OR REPLACE PACKAGE sa."SAFELINK_SERVICES_PKG" is
 /*
 CR# 31300
 Created Date: 01/8/2015
 */

PROCEDURE p_upd_service_plan (
i_esn                      IN VARCHAR2,
i_pgm_enroll2pgm_parameter IN NUMBER,
i_site_part_id             IN VARCHAR2 DEFAULT NULL,
o_err_no                   OUT NUMBER,
o_err_msg                  OUT VARCHAR2) ;
 procedure p_process_contactedit_job(
 ip_process_days in number default 3,
 op_err_num out number,
 op_err_string out varchar2);

 procedure p_load_e911_tax_recon_data ( --CR30286 ( CR29021 )
 in_rundays in number default 1,
 op_err_num out number,
 op_err_string out varchar2
 );

 PROCEDURE p_deenroll_job(
 ip_esn IN VARCHAR2,
 ip_source_system IN VARCHAR2,
 ip_deenroll_reason IN VARCHAR2,
 op_err_no out NUMBER,
 op_err_msg out VARCHAR2 );

PROCEDURE p_deneroll_job(
 ip_esn IN VARCHAR2,
 ip_lid IN NUMBER,
 ip_reason IN VARCHAR2,
 ip_phone_part_num IN VARCHAR2,
 ip_enroll_objid IN NUMBER,
 op_err_no OUT NUMBER,
 op_err_msg OUT VARCHAR2);

--- FOR CR31989 VMN
 PROCEDURE p_process_deenroll_job
 (
 ip_process_days in number default 3,
 op_err_no out number,
 op_err_msg out varchar2
 );

 PROCEDURE p_process_annual_verify_job(
 ip_process_days in number default 0,
 op_err_num out NUMBER,
 op_err_string out VARCHAR2);

 PROCEDURE p_process_program_change_job
 (
 ip_process_days IN NUMBER DEFAULT 0,
 op_err_num out NUMBER,
 op_err_string out VARCHAR2
 );

 PROCEDURE p_process_plan_transfer_job
 (
 ip_process_days IN NUMBER DEFAULT 0,
 op_err_num out NUMBER,
 op_err_string out VARCHAR2
 );

procedure create_job_instance (
 ip_job_name	     IN  x_job_master.x_job_name%TYPE,
 ip_status           IN  x_job_run_details.x_status%TYPE,
 ip_job_run_mode     IN  x_job_run_details.x_job_run_mode%TYPE DEFAULT NULL,
 ip_seq_name         IN  VARCHAR2,
 ip_owner_name       IN  x_job_run_details.owner_name%TYPE DEFAULT NULL,
 ip_reason           IN  x_job_run_details.x_reason%TYPE DEFAULT NULL,
 ip_status_code      IN  x_job_run_details.x_status_code%TYPE DEFAULT NULL,
 ip_sub_sourcesystem IN  x_job_run_details.x_sub_sourcesystem%TYPE DEFAULT NULL,
 op_job_run_objid    OUT x_job_run_details.objid%TYPE
 );

 procedure update_job_instance (
 ip_job_run_objid    IN  x_job_run_details.objid%TYPE,
 ip_owner_name       IN  x_job_run_details.owner_name%TYPE DEFAULT NULL,
 ip_reason           IN  x_job_run_details.x_reason%TYPE DEFAULT NULL,
 ip_status           IN  x_job_run_details.x_status%TYPE,
 ip_status_code      IN  x_job_run_details.x_status_code%TYPE DEFAULT NULL,
 ip_sub_sourcesystem IN  x_job_run_details.x_sub_sourcesystem%TYPE DEFAULT NULL
 );
-- FOR SA UPGRADE CR38927
PROCEDURE p_program_transfer(
 p_web_objid       IN table_web_user.objid%TYPE,     -- WebUser ObjID
 p_s_esn           IN x_program_enrolled.x_esn%TYPE, -- ESN from which programs need to be transferred.
 p_t_esn           IN x_program_enrolled.x_esn%TYPE,     -- ESN to which the programs need to be transferred to.
 p_pe_objid        IN x_program_enrolled.objid%TYPE,
 p_lid             IN x_sl_subs.lid%TYPE,
 p_from_pgm_objid  IN x_program_parameters.objid%TYPE,
 op_result         OUT NUMBER,
 op_msg            OUT VARCHAR2
);
-- FOR SA UPGRADE CR38927
-- CR43878 Changes starts
PROCEDURE p_x_sl_subs_import
                  ( ip_process_days     IN  VARCHAR2,
                    o_err_no            OUT NUMBER,
                    o_err_msg           OUT VARCHAR2 );
--
PROCEDURE p_enroll_transfer_job(
                  i_esn               IN  VARCHAR2 ,
                  i_lid               IN  VARCHAR2 ,
                  i_state             IN  VARCHAR2 DEFAULT NULL,
                  i_enroll_pgm_name   IN  VARCHAR2 ,
                  o_err_no            OUT NUMBER   ,
                  o_err_msg           OUT VARCHAR2 );
--
PROCEDURE p_process_enroll_transfer_job(
    ip_process_days IN NUMBER,
    op_err_no       OUT NUMBER,
    op_err_msg      OUT VARCHAR2 );
-- Exposing the below existing procedure as public
PROCEDURE get_first_last_name
  (
    ip_lid       IN NUMBER,
    ip_Full_Name IN VARCHAR2,
    op_first_name OUT VARCHAR2,
    op_last_name OUT VARCHAR2
  );
-- CR43878 Changes ends

--CR43143 Changes starts
procedure update_last_av_date
 (
   o_err_msg  OUT VARCHAR2
 );

--CR44770
	PROCEDURE p_deenroll_bkp_job(
		i_max_rows_limit        IN NUMBER DEFAULT 100000 ,
		i_commit_every_rows     IN NUMBER DEFAULT 5000 ,
		i_bulk_collection_limit IN NUMBER DEFAULT 200 );

  -- CR42459
   PROCEDURE ld_sl_cbo_queue_job (o_op_error_code OUT varchar2,
                                  o_op_error_msg  OUT varchar2);

PROCEDURE update_sp_plan(i_esn        IN  VARCHAR,
                         i_tsp_objid  IN  NUMBER,
                         o_err_code   OUT NUMBER,
                         o_err_msg    OUT VARCHAR2) ;

end safelink_services_pkg;
/