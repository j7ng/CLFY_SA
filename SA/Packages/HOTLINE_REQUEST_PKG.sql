CREATE OR REPLACE PACKAGE sa.hotline_request_pkg AS

PROCEDURE  create_hotline_esn_request ( in_esn              in  varchar2,
                                        in_rqsttype         in  varchar2,
                                        in_user             in  varchar2,
                                        out_err_num         out number,
                                        out_err_msg         out varchar2
                                      );


PROCEDURE  create_hotline_sms        (in_min              in  varchar2,
                                      in_rqsttype         in  varchar2,
                                      in_short_code       in  varchar2,
                                      in_sms_msg          in  varchar2,
                                      in_user             in  varchar2,
                                      out_err_num         out number,
                                      out_err_msg         out varchar2
                                      );


end hotline_request_pkg;
/