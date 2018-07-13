CREATE OR REPLACE PACKAGE sa."MONEY_CARD_PKG" is

  procedure validate_money_card_cc( p_credit_card_no      in      varchar2,
                                    p_brand_name          in	    varchar2,
                                    p_process             in      varchar2,
                                    --P_PROMO_GRP_OBJID     OUT     NUMBER,
                                    p_promo_grpdtl_objid  out     number,
                                    p_promo_objid         out     number,
                                    p_promo_code          out     varchar2,
                                    p_error_code          out     number,
                                    p_error_msg           out     varchar2);

  procedure validate_money_card_promo ( p_esn             in        varchar2,
                                        p_cc_objid			  in	      number,
                                        p_process         in        varchar2,
                                        p_promo_code      in        varchar2 default null,
                                        p_promo_objid			out       number,
                                        p_enroll_type     out       varchar2,
                                        p_enroll_amount   out       number,
                                        p_enroll_units    out       number,
                                        p_enroll_days     out       number,
                                        p_error_code      out       number,
                                        p_error_msg       out       varchar2 );

  procedure register_money_card ( p_esn				            in	      varchar2,
                                  p_brand_name            in        varchar2,
                                  p_cc_objid			        in	      number,
                                  --p_promo_grp_objid       in        number,
                                  p_promo_grpdtl_objid    in        number,
                                  p_process               in        varchar2,
                                  p_error_code      		  out       number,
                                  p_error_msg			        out       varchar2);


  procedure modify_usage  ( p_purch_hdr_id                in        number,
                            p_error_code      		        out       number,
                            p_error_msg			              out       varchar2);

  function sf_promo_check ( p_promo_id   in number default null,
                            p_process    in varchar2 ) return varchar2;

  procedure web_user_discount ( p_web_user_id             in        number,
                                p_discount_amount         out       number,
                                p_error_code      		    out       number,
                                p_error_msg			          out       varchar2 );


  --function sf_WEB_USER_DISCOUNT ( P_WEB_USER_ID             IN        NUMBER ) return number;
  procedure validate_money_card_ccid( p_cc_id               in      number,
                                      p_brand_name          in	    varchar2,
                                      p_process             in      varchar2,
                                      --P_PROMO_GRP_OBJID     OUT     NUMBER,
                                      p_promo_grpdtl_objid  out     number,
                                      p_promo_objid         out     number,
                                      p_promo_code          out     varchar2,
                                      p_error_code          out     number,
                                      p_error_msg           out     varchar2);


end money_card_pkg;
/