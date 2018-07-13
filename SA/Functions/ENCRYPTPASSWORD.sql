CREATE OR REPLACE FUNCTION sa."ENCRYPTPASSWORD" (plainPassword IN VARCHAR2) RETURN VARCHAR2
as language java
NAME 'encryptpassword.Encryption.encryptPassword (java.lang.String) return java.lang.String';
/