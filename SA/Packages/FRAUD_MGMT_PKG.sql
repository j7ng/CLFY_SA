CREATE OR REPLACE PACKAGE sa."FRAUD_MGMT_PKG" AS
PROCEDURE getfraudattributes(
        in_entityid     IN        VARCHAR2,
        io_key_tbl      IN OUT    KEYS_TBL,
        out_err_num     OUT       NUMBER,
        out_err_msg     OUT       VARCHAR2);
------------------------------------------------------------------------------------
PROCEDURE setfraudattributes(
    in_entityid IN VARCHAR2,
    io_key_tbl  IN keys_tbl,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2 );
------------------------------------------------------------------------------------
PROCEDURE deletefraudattributes(
    in_entityid IN VARCHAR2,
    io_key_tbl  IN keys_tbl,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2 );
------------------------------------------------------------------------------------
PROCEDURE searchfraudentity(
    in_entityid IN VARCHAR2,
    in_max_rec  in number default 300,
    io_key_tbl OUT keys_tbl,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2 );
------------------------------------------------------------------------------------
procedure tasupdatefraudparams(p_x_entity_name sa.x_fraud_entity.x_entity_name%type,
                                 p_x_key_name sa.x_fraud_keys.x_key_name%type,
                                 p_x_key_value sa.x_fraud_key_values.x_key_value%type,
                                 p_x_value_status sa.x_fraud_key_values.x_value_status%type,
                                 op_out_num out NUMBER,
                                 op_out_msg out varchar2);
--------------------------------------------------------------------------------
END Fraud_Mgmt_Pkg;
/