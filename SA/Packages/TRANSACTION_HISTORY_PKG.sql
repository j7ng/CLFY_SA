CREATE OR REPLACE PACKAGE sa.transaction_history_pkg
AS
/********************************************************************
--$RCSfile: transaction_history_pkg.sql,v $
--$Revision: 1.6 $
--$Author: vlaad $
--$Date: 2017/06/21 22:03:01 $
--$ $Log: transaction_history_pkg.sql,v $
--$ Revision 1.6  2017/06/21 22:03:01  vlaad
--$ Added new procedure to get last CC trans
--$
--$ Revision 1.5  2017/04/18 16:12:20  smeganathan
--$ Merged with WFM production release
--$
--$ Revision 1.4  2016/11/14 19:47:29  smeganathan
--$ CR44680 changes to get the service plan descriptions for Tracfone brand
--$
--$ Revision 1.3  2015/08/26 22:15:38  smeganathan
--
--$ Revision 1.1  2015/07/15 10:00:00  sethiraj
--$ CR35913 My Accounts APP - Phase II
--$
*********************************************************************/
--
-- CR44680 Changes Starts..
FUNCTION fn_get_script_text_by_scriptid(ip_sourcesystem   IN VARCHAR2,
                                        ip_brand_name     IN VARCHAR2,
                                        ip_language       IN VARCHAR2 DEFAULT 'ENGLISH', -- CR48846
                                        ip_script_id      IN VARCHAR2)
RETURN VARCHAR2;
--
PROCEDURE get_script_id(
    ip_part_number    IN  VARCHAR2,
    p_script_id1      OUT VARCHAR2,
    p_script_id2      OUT VARCHAR2);
-- CR44680 Changes Ends
--
PROCEDURE get_transaction_history(
    ip_esn                    IN  VARCHAR2,
    ip_brand                  IN  VARCHAR2,
    out_transaction_hist_cur  OUT sys_refcursor,
    p_err_num                 OUT NUMBER ,
    p_err_string              OUT VARCHAR2 );
--
--CR48643 NT Activation mobile channel
PROCEDURE get_last_cc_transaction(
    i_esn                    IN  VARCHAR2,
    i_paymnt_src_id          IN  NUMBER,
    o_transaction_id         OUT VARCHAR2,
    o_transaction_date       OUT DATE,
    o_total_amount           OUT NUMBER,
    o_tax_amount             OUT NUMBER,
    o_err_num                OUT NUMBER,
    o_err_msg                OUT VARCHAR2  );
END transaction_history_pkg;
-- ANTHILL_TEST PLSQL/SA/Packages/transaction_history_pkg.sql 	CR48846: 1.6
/