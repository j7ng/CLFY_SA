CREATE OR REPLACE PROCEDURE sa."SEND_MAIL_WITH_ATTACHMENT"
( p_mail_host               IN VARCHAR2
 ,p_port                    IN INTEGER
---CR22037 REMOVE DEFAULTS
-- p_mail_host               IN VARCHAR2 DEFAULT 'MIACAS1'
-- ,p_port                    IN INTEGER DEFAULT 25
 ---CR22037 REMOVE DEFAULTS
 ,p_subject_text            IN VARCHAR2
 ,p_message_from            IN VARCHAR2 DEFAULT 'noreply@tracfone.com'
 ,p_send_to                 IN VARCHAR2
 ,p_message_text            IN VARCHAR2
 ,p_attachment_name         IN VARCHAR2
 ,p_attachment_text         IN CLOB
 ,p_attachment_context_type IN VARCHAR2 DEFAULT 'Content-Type: text/plain;'
 ,p_debug                   IN BOOLEAN DEFAULT FALSE
 ,p_error_code              OUT INTEGER
 ,p_error_message           OUT VARCHAR2
) IS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SEND_MAIL_WITH_ATTACHMENT.sql,v $
  --$Revision: 1.4 $
  --$Author: oarbab $
  --$Date: 2014/04/17 01:01:29 $
  --$ $Log: SEND_MAIL_WITH_ATTACHMENT.sql,v $
  --$ Revision 1.4  2014/04/17 01:01:29  oarbab
  --$ CR22388_close the connection if end file is reached
  --$
  --$ Revision 1.3  2012/10/22 19:56:42  lsatuluri
  --$ CR22037 Create parameter for Mail Host Server name
  --$
  --$ Revision 1.2  2011/11/28 22:49:04  kacosta
  --$ CR15759 Warranty Exchange Alerts
  --$
  --$ Revision 1.1  2011/11/22 16:02:19  kacosta
  --$ CR15759 Warranty Exchange Alerts
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  l_cv_subprogram_name CONSTANT VARCHAR2(61) := 'send_mail_with_attachment';
  l_b_debug               BOOLEAN := FALSE;
  l_conn_email_connection utl_smtp.connection;
  l_i_error_code          INTEGER := 0;
  l_i_offset              INTEGER := 24573;
  l_v_carriage_return     VARCHAR2(2) := utl_tcp.crlf;
  l_v_error_message       VARCHAR2(32767) := 'SUCCESS';
  l_v_position            VARCHAR2(32767) := l_cv_subprogram_name || '.1';
  l_v_note                VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
  --
  V_HOST  VARCHAR2(255); -----CR22037
BEGIN
  --

  l_b_debug := NVL(p_debug
                  ,FALSE);
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_mail_host              : ' || NVL(p_mail_host
                                                             ,'Value is null'));
    dbms_output.put_line('p_subject_text           : ' || NVL(p_subject_text
                                                             ,'Value is null'));
    dbms_output.put_line('p_message_from           : ' || NVL(p_message_from
                                                             ,'Value is null'));
    dbms_output.put_line('p_send_to                : ' || NVL(p_send_to
                                                             ,'Value is null'));
    dbms_output.put_line('p_message_text           : ' || NVL(SUBSTR(p_message_text
                                                                    ,1
                                                                    ,250)
                                                             ,'Value is null'));
    dbms_output.put_line('p_attachment_name        : ' || NVL(p_attachment_name
                                                             ,'Value is null'));
    dbms_output.put_line('p_attachment_text        : ' || NVL(SUBSTR(p_attachment_text
                                                                    ,1
                                                                    ,250)
                                                             ,'Value is null'));
    dbms_output.put_line('p_attachment_context_type: ' || NVL(p_attachment_context_type
                                                             ,'Value is null'));
    --
  END IF;
  --
  l_v_position := l_cv_subprogram_name || '.2';
  l_v_note     := 'Opening connection';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  l_conn_email_connection := utl_smtp.open_connection(host => p_mail_host
                                                     ,port => p_port);
  --
  l_v_position := l_cv_subprogram_name || '.3';
  l_v_note     := 'Performing handshaking with smtp server';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  utl_smtp.helo(c      => l_conn_email_connection
               ,domain => p_mail_host);
  --
  l_v_position := l_cv_subprogram_name || '.4';
  l_v_note     := 'Setting message from';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  utl_smtp.mail(c      => l_conn_email_connection
               ,sender => p_message_from);
  --
  l_v_position := l_cv_subprogram_name || '.5';
  l_v_note     := 'Setting message to';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  utl_smtp.rcpt(c         => l_conn_email_connection
               ,recipient => p_send_to);
  --
  l_v_position := l_cv_subprogram_name || '.6';
  l_v_note     := 'Generating body';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  utl_smtp.open_data(c => l_conn_email_connection);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'Date: ' || TO_CHAR(SYSDATE
                                                 ,'Dy, DD Mon YYYY hh24:mi:ss') || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'From: ' || p_message_from || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'Subject: ' || p_subject_text || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'To: ' || p_send_to || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'MIME-Version: 1.0' || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'Content-Type: multipart/mixed;' || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => ' boundary="-----SECBOUND"' || l_v_carriage_return || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => '-------SECBOUND' || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'Content-Type: text/html;' || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'Content-Transfer_Encoding: 7bit' || l_v_carriage_return || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => p_message_text || l_v_carriage_return || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => '-------SECBOUND' || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => p_attachment_context_type || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => ' name="' || p_attachment_name || '"' || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'Content-Transfer_Encoding: 8bit' || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => 'Content-Disposition: attachment;' || l_v_carriage_return);
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => ' filename="' || p_attachment_name || '"' || l_v_carriage_return || l_v_carriage_return);
  --
  FOR idx IN 0 .. TRUNC((dbms_lob.getlength(p_attachment_text) - 1) / l_i_offset) LOOP
    --
    utl_smtp.write_data(c    => l_conn_email_connection
                       ,data => dbms_lob.substr(p_attachment_text
                                               ,l_i_offset
                                               ,idx * l_i_offset + 1));
    --
  END LOOP;
  --
  utl_smtp.write_data(c    => l_conn_email_connection
                     ,data => l_v_carriage_return || l_v_carriage_return || '-------SECBOUND--');
  utl_smtp.close_data(c => l_conn_email_connection);
  --
  l_v_position := l_cv_subprogram_name || '.7';
  l_v_note     := 'Close connection';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  utl_smtp.quit(c => l_conn_email_connection);
  --
  l_v_position := l_cv_subprogram_name || '.8';
  l_v_note     := 'End executing ' || l_cv_subprogram_name;
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                   ,'Value is null'));
    dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                   ,'Value is null'));
    --
  END IF;
  --
  p_error_code    := l_i_error_code;
  p_error_message := l_v_error_message;
  --
EXCEPTION
------------ CR22388 --------------
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(c => l_conn_email_connection);
    EXCEPTION
      WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR THEN
        NULL; -- When the SMTP server is down or unavailable, we don't have
              -- a connection to the server. The QUIT call will raise an
              -- exception that we can ignore.
    END;
------------ CR22388 --------------
  WHEN others THEN
	utl_smtp.quit(c => l_conn_email_connection); --  CR22388
  --
    p_error_code    := SQLCODE;
    p_error_message := SQLERRM;
    --
    l_v_position := l_cv_subprogram_name || '.9';
    l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                     ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                     ,'Value is null'));
      --
    END IF;
    --
    ota_util_pkg.err_log(p_action       => l_v_note
                        ,p_error_date   => SYSDATE
                        ,p_key          => p_subject_text
                        ,p_program_name => l_v_position
                        ,p_error_text   => p_error_message);
END send_mail_with_attachment;
/