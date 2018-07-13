CREATE OR REPLACE PACKAGE sa."ADFCRM_UNLOCK_BUYBACK_PKG" AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */

 procedure VERIFY_ELEGIBILITY(p_esn         in   varchar2,
                              p_min         in   varchar2,
                              p_overwrite   in  varchar2 DEFAULT 'false',
                              p_result      out varchar2, -- (NOT ELIGIBLE, UNLOCKED, BUY BACK, UNLOCKABLE)
                              p_trade_value out number,
                              p_paid_days   out number,
                              p_active_days out number,
                              p_err_code    out varchar2,
                              p_err_msg     out varchar2);

 procedure VERIFY_ELEGIBILITY(p_esn         in   varchar2,
                              p_min         in   varchar2,
                              p_overwrite   in  varchar2 DEFAULT 'false',
                              p_source_system in varchar2 DEFAULT 'WEB',       -- CR39592 PMistry 03/07/2016 added new parameter for FCC project
                              p_result      out varchar2, -- (NOT ELIGIBLE, UNLOCKED, BUY BACK, UNLOCKABLE)
                              p_trade_value out number,
                              p_paid_days   out number,
                              p_active_days out number,
                              p_err_code    out varchar2,
                              p_err_msg     out varchar2,
							  p_login_name  in  varchar2);

 procedure CREATE_REQUEST(p_esn in varchar2,
                          p_min in varchar2,
                          p_overwrite in varchar2 DEFAULT 'false',
                          p_login_name in varchar2 DEFAULT 'CBO',
                          p_source_system in varchar2 DEFAULT 'TAS',
                          p_first_name in varchar2,
                          p_last_name in varchar2,
                          p_address_1 in varchar2,
                          p_address_2 in varchar2,
                          p_city in varchar2,
                          p_state in varchar2,
                          p_zipcode in varchar2,
                          p_email in varchar2,
                          p_contact_phone in varchar2,
                          p_airbill in varchar2, --ELECTRONIC, PHYSICAL
                          p_keep_service in varchar2 DEFAULT 'false',   --CR39592 PMistry 03/03/2016 FCC SL UNLOCK
                          p_repl_part_number in out varchar2,           --CR39592 PMistry 03/03/2016 FCC SL UNLOCK
                          p_coupon in varchar2 DEFAULT '', --CR44455 Upgrade credit
                          p_id_number out varchar2,
                          p_err_code out varchar2,
                          p_err_msg  out varchar2);



procedure UNLOCKING_CODE_REQUEST(
                                p_esn              in      varchar2,
                                p_min              in      varchar2,
                                p_login_name       in      varchar2 DEFAULT 'CBO',
                                p_sourcesystem     in      varchar2,
                                p_regen_flag       in      varchar2,
                                p_ota_trans_id     in      varchar2,
                                p_first_name       in      varchar2,
                                p_last_name        in      varchar2,
                                p_email            in      varchar2,
                                p_address          in      varchar2,
                                p_city             in      varchar2,
                                p_state            in      varchar2,
                                p_zipcode          in      varchar2,
                                p_contact_phone    in      varchar2,
                                p_overwrite        in      varchar2,
                                p_unlocking_code1  in out  varchar2,
								                p_unlocking_code2  in out  varchar2,
								                p_unlocking_code3  in out  varchar2,
                                p_gencode          in out  varchar2,  --Comma delimited output from SP_CODEGEN.
                                p_spccode          in out  varchar2,
                                p_id_number        in out  varchar2,
                                p_call_trans       in out  varchar2,
                                p_err_code         out     varchar2,
                                p_err_msg          out     varchar2 );


procedure  UNLOCK_SPC_ENCRYPT_PRC (
                                  p_esn                    in out  varchar2,
                                  p_po                     out     varchar2,
                                  p_spc                    out     varchar2,
                                  p_encryptedcode1         out     varchar2,
                                  p_encryptedcode2         out     varchar2,
                                  p_encryptedcode3         out     varchar2,
                                  p_encryptedsessionkey    out     varchar2,
                                  p_cryptocert             out     varchar2,
                                  p_keytransportalgorithm  out     varchar2,
                                  p_decryptalgorithm       out     varchar2,
		                           p_unlock_status          out     varchar2,
                                  p_err_code               out     varchar2,
                                  p_err_msg                out     varchar2) ;

FUNCTION REPROCESS_COUNT_FN ( p_case_id in varchar2) return varchar2;

function unlock_case_fn( p_esn in varchar2 , p_min in varchar2 ) return varchar2;

--CR39303 - New procedure to update email and reprocess count
PROCEDURE UNLOCK_REPROCESS_PRC (p_case_id in varchar2,p_esn in varchar2,p_email in varchar2,p_err_code out varchar2,p_err_msg out varchar2);
--CR39303 ends

  -- CR39592 Start PMistry 03/16/2016 Added new procedure.
  procedure get_part_reqst_dtl ( i_esn               IN     varchar2,
                                 i_min               IN     varchar2,
                                 i_case_type         IN     varchar2,
                                 i_domain            IN     varchar2  DEFAULT 'PHONES',
                                 out_refcursor      OUT    SYS_REFCURSOR ,
                                 out_error_no       OUT    varchar2,
                                 out_error_str      OUT    varchar2);

  -- CR39592 End


END ADFCRM_UNLOCK_BUYBACK_PKG;
-- ANTHILL_TEST PLSQL/SA/Packages/ADFCRM_UNLOCK_BUYBACK_PKG.sql
/