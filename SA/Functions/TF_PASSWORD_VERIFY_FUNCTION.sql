CREATE OR REPLACE FUNCTION sa.tf_password_verify_function
 (username varchar2,
 password varchar2,
 old_password varchar2)
 RETURN boolean IS
 n boolean;
 m integer;
 differ integer;
 isdigit boolean;
 ischar boolean;
 ispunct boolean;
 iscap boolean;
 digitarray varchar2(20);
 punctarray varchar2(25);
 chararray varchar2(52);
BEGIN
 digitarray:= '0123456789';
 chararray:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
 punctarray:='!"#$%&()..*+,-/:;<=>?_';
 --
 --Check if the password is same as the username
 IF password = username THEN
  raise_application_error(-20001, 'Password same as user');
 END IF;
 --
 --Check for the minimum length of the password
 IF length(password) < 8 THEN
  raise_application_error(-20002, 'Password length less than 8');
 END IF;
 --Check if the password is too simple. A dictionary of words may be
 --maintained and a check may be made so as not to allow the words
 --that are too simple for the password.
 IF NLS_LOWER(password) IN ('welcome', 'database', 'account', 'user',
 'password', 'oracle', 'computer', 'abcdef') THEN
  raise_application_error(-20002, 'Password too simple');
 END IF;
 --Check if the password contains at least one letter,
 --one digit and one punctuation mark.
 --1. Check for the digit
 --You may delete 1. and replace with 2. or 3.
 isdigit:=FALSE;
 m := length(password);
 FOR i IN 1..10 LOOP
  FOR j IN 1..m LOOP
  IF substr(password,j,1) = substr(digitarray,i,1) THEN
   isdigit:=TRUE;
   GOTO findchar;
  END IF;
  END LOOP;
 END LOOP;
 IF isdigit = FALSE THEN
  raise_application_error(-20003, 'Password should \
  contain at least one digit, one character, one capital letter  and one punctuation');
 END IF;
 --
 --2. Check for the character
 --
 <<findchar>>
 ischar:=FALSE;
 FOR i IN 1..length(chararray) LOOP
  FOR j IN 1..m LOOP
  IF substr(password,j,1) = substr(chararray,i,1) THEN
   ischar:=TRUE;
   GOTO findpunct;
  END IF;
  END LOOP;
 END LOOP;
 IF ischar = FALSE THEN
  raise_application_error(-20003, 'Password should \
  contain at least one digit, one character, one capital letter and one punctuation');
 END IF;
 --
 --3. Check for the punctuation
 --
 <<findpunct>>
 ispunct:=FALSE;
 FOR i IN 1..length(punctarray) LOOP
  FOR j IN 1..m LOOP
  IF substr(password,j,1) = substr(punctarray,i,1) THEN
   ispunct:=TRUE;
   GOTO checkcase;
  END IF;
  END LOOP;
 END LOOP;
 IF ispunct = FALSE THEN
  raise_application_error(-20003, 'Password should \
  contain at least one digit, one character, one capital letter and one punctuation');
 END IF;
 --
 --4. Check for capital letter in password
 --
 <<checkcase>>
 iscap:=FALSE;
 FOR i IN 1..length(chararray) LOOP
  FOR j IN 1..m LOOP
   IF substr(password,j,1) = UPPER(substr(chararray,i,1)) THEN
   iscap:=TRUE;
  GOTO endsearch;
  END IF;
  END LOOP;
 END LOOP;
 IF iscap = FALSE THEN
  raise_application_error(-20003, 'Password should \
  contain at least one digit, one character, one capital letter and one punctuation');
 END IF;
 <<endsearch>>
 --Check if the password is blank
 IF old_password = '' THEN
  raise_application_error(-20004, 'Old password is null');
 END IF;
RETURN(TRUE);
END;
/