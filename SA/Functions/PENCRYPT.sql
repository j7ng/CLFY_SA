CREATE OR REPLACE FUNCTION sa.PENCRYPT (PWD IN VARCHAR2) RETURN VARCHAR2 IS
/*********************************************************************************************/
/* Name         :   PENCRYPT                                                                 */
/*                                                                                           */
/* Purpose      :   PASSWORD ENCRYPTION                                                      */
/*                                                                                           */
/* Platforms    :   ORACLE                                                                   */
/*                                                                                           */
/* Author       :   SRINIVAS C KARUMURI                                                      */
/*                                                                                           */
/* Date         :   10-04-2011                                                               */
/*                                                                                           */
/* VERSION  DATE        WHO          PURPOSE                                                 */
/* -------  ----------  -----        --------------------------------------------            */
/*  1.0                              Initial  Revision                                       */
/*********************************************************************************************/
    PEN VARCHAR2(100);
  BEGIN
    PEN:=SYS.dbms_crypto.HASH(UTL_RAW.CAST_TO_RAW(PWD), DBMS_CRYPTO.HASH_SH1);
    RETURN UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(PEN));
  END;
/