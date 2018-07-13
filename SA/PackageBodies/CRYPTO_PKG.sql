CREATE OR REPLACE PACKAGE BODY sa.CRYPTO_PKG
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
        out_err_msg            OUT VARCHAR2)
    IS
        CURSOR c_get_key
        IS
            SELECT x_public_key,
                   x_private_key,
                   x_exp_date
              FROM x_keystore
             WHERE     x_vendor_id = in_vendorid
                   AND x_source_system = in_source_sys
                   AND x_brand_name = in_brand
                   AND x_appid = in_appid
                   AND x_encrypt_method = in_encrypt_method
                   AND x_encrypt_std = in_encrypt_std;

        r_get_key   c_get_key%ROWTYPE;
        v_proc_name          VARCHAR2(80)    := 'CRYPTO_PKG.GET_KEY';
    BEGIN
        IF     in_vendorid IS NOT NULL
           AND in_source_sys IS NOT NULL
           AND in_brand IS NOT NULL
           AND in_appid IS NOT NULL
           AND in_encrypt_method IS NOT NULL
           AND in_encrypt_std IS NOT NULL
        THEN
           OPEN c_get_key;
           FETCH c_get_key INTO r_get_key;
              IF c_get_key%FOUND
                THEN
                    out_public_key := r_get_key.x_public_key;
                    out_private_key := r_get_key.x_private_key;
                    out_keyexp_dt := r_get_key.x_exp_date;
              ELSE
                    out_err_num := 800;
                    out_err_msg := sa.get_code_fun('WALMART_MONTHLY_PLANS_PKG', '800','ENGLISH'); -- CURSOR NOT FOUND
              END IF;
           CLOSE c_get_key;

           out_err_num := 0;
        ELSE
            out_err_num := 801;
            out_err_msg := sa.get_code_fun('CRYPTO_PKG', '801','ENGLISH'); -- INPUT CANNOT BE NULL
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            out_err_num := SQLCODE;
            out_err_msg := SUBSTR (SQLERRM, 1, 200);
            ota_util_pkg.err_log (
                'vendor ID: '||in_vendorid||' in_source_sys: '||in_source_sys||' in_appid: '||in_appid ||' in_encrypt_method: '||in_encrypt_method||' in_encrypt_std: '|| in_encrypt_std,
                SYSDATE,
                'Main Exception',
                v_proc_name,
                'ERR: '||TO_CHAR(SQLCODE)||' ERR MSG : '||SUBSTR(SQLERRM, 1, 200)
                );
    END;

    PROCEDURE get_keystore ( out_key_tab      OUT SYS_REFCURSOR,
                             out_err_num      OUT NUMBER,
                             out_err_msg      OUT VARCHAR2)
    IS
            v_proc_name          VARCHAR2(80)    := 'CRYPTO_PKG.GET_KEYSTORE';
    BEGIN
        OPEN out_key_tab FOR
            SELECT x_vendor_id,
                   x_source_system,
                   x_brand_name,
                   x_appid,
                   x_encrypt_method,
                   x_encrypt_std,
                   x_key_pswd,
                   x_eff_date,
                   x_exp_date
              FROM x_keystore
             WHERE x_key_pswd IS NOT NULL;
           out_err_num := 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            out_err_num := SQLCODE;
            out_err_msg := SUBSTR (SQLERRM, 1, 200);
            ota_util_pkg.err_log (
                '',
                SYSDATE,
                'Main Exception',
                v_proc_name,
                'ERR: '||TO_CHAR(SQLCODE)||' ERR MSG : '||SUBSTR(SQLERRM, 1, 200)
                );
    END;

END;
/