CREATE OR REPLACE PACKAGE sa.crypto_pkg
IS
    /*===============================================================================================*/
    /*                                                                                               */
    /* Purpose: To maintain vendor public and Private keys.                                          */
    /* REVISIONS  DATE       WHO            PURPOSE                                                  */
    /* --------------------------------------------------------------------------------------------- */
    /*            2/14/2013 MVadlapally  Initial                                                     */
    /*===============================================================================================*/



    PROCEDURE get_key (
        in_vendorid         IN     x_keystore.x_vendor_id%TYPE,
        in_source_sys       IN     x_keystore.x_source_system%TYPE,
        in_brand            IN     x_keystore.x_brand_name%TYPE,
        in_appid            IN     x_keystore.x_appid%TYPE,
        in_encrypt_method   IN     x_keystore.x_encrypt_method%TYPE,
        in_encrypt_std      IN     x_keystore.x_encrypt_std%TYPE,
        out_public_key         OUT x_keystore.x_public_key%TYPE,
        out_private_key        OUT x_keystore.x_private_key%TYPE,
        out_keyexp_dt          OUT x_keystore.x_exp_date%TYPE,
        out_err_num            OUT NUMBER,
        out_err_msg            OUT VARCHAR2);

    PROCEDURE get_keystore (out_key_tab      OUT SYS_REFCURSOR,
                            out_err_num      OUT NUMBER,
                            out_err_msg      OUT VARCHAR2);
END;
/