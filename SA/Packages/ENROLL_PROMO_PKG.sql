CREATE OR REPLACE PACKAGE sa."ENROLL_PROMO_PKG" is
procedure sp_swap_program(p_esn                         in     varchar2,
                          p_old_program_objid           in     number,
                          p_new_program_objid           in     number,
                          p_error_code                  out    number,
                          p_error_msg                   out    varchar2  );
procedure sp_get_eligible_promo ( p_esn                         in      varchar2,
                                  p_program_objid               in      number,
                                  p_process                     in      varchar2,
                                  p_promo_objid                 out     number,
                                  p_promo_code                  out     varchar2,
                                  p_script_id                   out     varchar2,
                                  p_error_code                  out     number,
                                  p_error_msg                   out     varchar2
				  ,p_ignore_attached_promo 	IN 	VARCHAR2 DEFAULT 'N'
				  );

procedure sp_register_esn_promo ( p_esn                         in      varchar2,
                                  p_promo_objid                 in      number,
                                  p_program_enrolled_objid      in      number,
                                  p_error_code                  out     number,
                                  p_error_msg                   out     varchar2  );
procedure sp_register_esn_promo2 ( p_esn                         in      varchar2,
                                  p_promo_objid                 in      number,
                                  p_error_code                  out     number,
                                  p_error_msg                   out     varchar2  );

procedure sp_validate_promo     ( p_esn                         in      varchar2,
                                  p_program_objid               in      number,
                                  p_process                     in      varchar2,
                                  p_promo_objid                 in out  number,
                                  p_promo_code                                                          out     varchar2,
                                  p_enroll_type                 out     varchar2,
                                  p_enroll_amount               out     number,
                                  p_enroll_units                out     number,
                                  p_enroll_days                 out     number,
                                  p_error_code                  out     number,
                                  p_error_msg                   out     varchar2  );

function sf_promo_check         ( p_promo_objid                 in      number,
                                  p_esn                         in      varchar2,
                                  p_program_objid               in      number,
                                  p_process                     in      varchar2 ) return number;

procedure sp_transfer_promo_enrollment  ( p_case_objid          in    number,
                                          p_new_esn             in    varchar2,
                                          --p_program_objid       in    number,
                                          p_error_code          out   number,
                                          p_error_msg           out   varchar2  );

procedure sp_deenroll_promo_enrollment  ( p_esn                         in    varchar2,
                                          p_program_enrolled_objid      in      number,
                                          p_enrollment_flag             in varchar2,
                                          p_error_code                  out   number,
                                          p_error_msg                   out   varchar2  );

procedure sp_get_eligible_promo_esn ( p_esn                         in      varchar2,
                                  p_promo_objid                 out     number,
                                  p_promo_code                  out     varchar2,
                                  p_script_id                   out     varchar2,
                                  p_error_code                  out     number,
                                  p_error_msg                   out     varchar2  );
procedure sp_get_eligible_promo_esn2 ( p_esn                         in      varchar2,
                                  p_promo_objid                 out     number,
                                  p_promo_code                  out     varchar2,
                                  p_script_id                   out     varchar2,
                                  p_error_code                  out     number,
                                  p_error_msg                   out     varchar2  );
procedure sp_get_eligible_promo_esn3 ( p_esn                         in      varchar2,
                                      p_program_objid               in number,
                                  p_promo_objid                 out     number,
                                  p_promo_code                  out     varchar2,
                                  p_script_id                   out     varchar2,
                                  p_error_code                  out     number,
                                  p_error_msg                   out     varchar2
				  ,p_ignore_attached_promo 	IN 	VARCHAR2  DEFAULT 'N'
				  );
procedure get_discount_amount (
    p_esn               IN VARCHAR2,
    p_promo_objid       IN VARCHAR2,
    p_retail_price      IN VARCHAR2,
    p_discount_amount   OUT NUMBER,
    p_result            OUT NUMBER
);
end enroll_promo_pkg;
/