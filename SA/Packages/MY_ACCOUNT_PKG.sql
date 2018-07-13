CREATE OR REPLACE PACKAGE sa."MY_ACCOUNT_PKG" as
function need_verification(p_esn in varchar2,p_xmin out varchar2 ) return varchar2;
function set_verified(p_esn in varchar2) return number;
function unset_verified(p_esn in varchar2) return number;
procedure get_account_info(p_restricted_use in number,
                           p_org_id in varchar2,
                           p_login_name in varchar2,
                           p_error out number,
                           result_set out sys_refcursor);
end;
/