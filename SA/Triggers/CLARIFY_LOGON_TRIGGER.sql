CREATE OR REPLACE TRIGGER sa.CLARIFY_LOGON_TRIGGER
AFTER LOGON ON DATABASE
DECLARE
--Declare a cursor to find out the program
    --the user is connecting with.
    CURSOR user_prog IS
          SELECT  program FROM v$session
          -- WHERE   audsid=sys_context('USERENV','SESSIONID');
          WHERE   sid = SYS_CONTEXT('USERENV','SID');

    --Assign the cursor to a PL/SQL record.
    user_rec user_prog%ROWTYPE;
    BEGIN
        OPEN user_prog;
        FETCH user_prog INTO user_rec;
        IF user_rec.program IN ('clarify.exe')
        THEN
           -- execute immediate 'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 1''';
          --  execute immediate 'alter session set events = ''942 trace name errorstack forever, level 10''';
            execute immediate 'alter session set optimizer_mode = rule';
        END IF;
        CLOSE user_prog;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/