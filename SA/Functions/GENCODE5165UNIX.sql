CREATE OR REPLACE FUNCTION sa.GenCode5165Unix(
                                        command_flag in pls_integer,
                                        roam_flag    in pls_integer,
                                        rhours       in pls_integer,
                                        counter      in pls_integer,
                                        odacc        in pls_integer,
                                        debsn        in pls_integer,
                                        Gommand      in varchar2)
  return string
as
   language C
   library libGenCode5165Unix
   name "Entry5165_Unix"
   parameters (
               command_flag int,
               roam_flag    int,
               rhours       int,
               counter      int,
               odacc        int,
               debsn        int,
               Gommand      string,
               RETURN       string);
/