CREATE OR REPLACE PROCEDURE sa.SEND_MAIL (
  subject_txt    in varchar2,
  msg_from   IN varchar2,
  send_to    IN varchar2,
  message_txt    IN varchar2,
  result OUT varchar2  )
IS
---------------------------------------------------------------------------------------------
--$RCSfile: SEND_MAIL.sql,v $
--$Revision: 1.4 $
--$Author: akhan $
--$Date: 2013/11/18 16:14:17 $
--$Log: SEND_MAIL.sql,v $
--Revision 1.4  2013/11/18 16:14:17  akhan
--Added cvs header and close cursor
--
---------------------------------------------------------------------------------------------
  msg_to      varchar2(80);
  msg_subject varchar2(300);
  msg_text    varchar2(10000);
  c  utl_tcp.connection;
  rc integer;
  Host_name   varchar2(255) :='MIACAS1' ;   ---CR22037
  port_num    varchar2(255):='25';   ---CR22037

BEGIN

  msg_to        := send_to;
  msg_subject := Subject_txt;
  msg_text      := message_txt;


/**
 -----CR22037
 SELECT x_param_value 
   FROM TABLE_X_PARAMETERS where x_param_name='MAILHOST';

SELECT x_param_value-- into port_num
  FROM sa.table_x_parameters where x_param_name='PORT';
**/
   c := utl_tcp.open_connection(Host_name,port_num);
 -- c := utl_tcp.open_connection('SMTP.TRACFONE.COM','25');      -- DPExchange MailHost ip_address
  ---CR22037
  dbms_output.put_line(utl_tcp.get_line(c, TRUE));
  rc := utl_tcp.write_line(c, 'HELO');
  dbms_output.put_line(utl_tcp.get_line(c, TRUE));
  rc := utl_tcp.write_line(c, 'MAIL FROM: '||msg_from);
  dbms_output.put_line(utl_tcp.get_line(c, TRUE));
  rc := utl_tcp.write_line(c, 'RCPT TO: '||msg_to);
  dbms_output.put_line(utl_tcp.get_line(c, TRUE));
  rc := utl_tcp.write_line(c, 'DATA');                 -- Start message body

  rc := utl_tcp.write_line(c, 'Content-Type: text/html');        ----- 1ST BODY PART. EMAIL TEXT MESSAGE


  dbms_output.put_line(utl_tcp.get_line(c, TRUE));
  rc := utl_tcp.write_line(c, 'From: '||msg_from);
  rc := utl_tcp.write_line(c, 'Subject: '||msg_subject);
  rc := utl_tcp.write_line(c, 'To: '||msg_to);
  rc := utl_tcp.write_line(c, '');
  rc := utl_tcp.write_line(c, msg_text);
  rc := utl_tcp.write_line(c, '.');                    -- End of message body
  dbms_output.put_line(utl_tcp.get_line(c, TRUE));
  rc := utl_tcp.write_line(c, 'QUIT');
  dbms_output.put_line(utl_tcp.get_line(c, TRUE));
  utl_tcp.close_connection(c);                         -- Close the connection
EXCEPTION
  when others then
  utl_tcp.close_connection(c);
       raise_application_error(
           -20000, 'Unable to send e-mail message from pl/sql because of: '||
           sqlerrm);
end;
/