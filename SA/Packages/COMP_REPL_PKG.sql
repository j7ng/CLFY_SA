CREATE OR REPLACE PACKAGE sa."COMP_REPL_PKG" is
-----------------------------------------------------------------------
procedure getCompHistory(ip_esn in varchar2,
                         ip_csr in varchar2,
                         ip_brand_name in varchar2,
                         op_unit_list out sys_refcursor);
-----------------------------------------------------------------------
PROCEDURE validate_comp_repl_limits (
    ip_esn          IN  VARCHAR2, -- ESN in flow
    ip_agent        IN  VARCHAR2, -- signed in agent
    ip_type         IN  VARCHAR2, -- REPL|COMP
    ip_voice_units  IN  NUMBER,   -- selected from flow
    ip_data_units   IN  NUMBER,   -- selected from flow
    ip_sms_units    IN  NUMBER,   -- selected from flow
    ip_days         IN  NUMBER,   -- selected from flow
    ip_sup_login    IN  VARCHAR2, -- signed supervisor override
    op_error_num    OUT NUMBER);
-----------------------------------------------------------------------
end;
/