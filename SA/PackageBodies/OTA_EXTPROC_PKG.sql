CREATE OR REPLACE PACKAGE BODY sa."OTA_EXTPROC_PKG"
IS
/************************************************************************************************
|    Copyright   Tracfone  Wireless Inc. All rights reserved
|
| NAME     :     OTA_EXTPROC_PKG
| PURPOSE  :     Calls external procedures written in "C" language, so called DLLs
| FREQUENCY:
| PLATFORMS:     Oracle 8.1.7 and above
|
| REVISIONS:
| VERSION  DATE        WHO              PURPOSE
| -------  ---------- -----             ------------------------------------------------------
| 1.0      12/01/04   Novak Lalovic     Initial creation
|          05/19/05   Novak Lalovic     Modification:
|                                       Added 4 new DLL external function calls to call_dll proc
|                                       DLL number 10 = PSMSMotorola120Unix (V120 and V60 phones)
|                                       DLL number 12 = PSMSNokia1221Unix
|                                       DLL number 13 = PSMSNokia2285Unix
|                                       DLL number 17 = PSMSMotorola343Unix
| 1.1     06/27/05   Shaowei Luo        All changes in the program are commented as CR4169
| 1.2     07/27/05   Novak Lalovic      Deleted piece of code from parse_acknowledgment procedure
|                                       which was unecessarily inserting records into ERROR_TABLE table
|                                       when cursor variables p_inquiry_rs_out and p_redemption_rs_out
|                           had an open cursor status.
| 1.3     08/31/05   Novak Lalovic      Added new DLL number: 18 to the DLL_LIST and call_dll procedure
|                                       DLL number 18 = PSMSNokia2126Unix
|                                       CR# 4336
| 1.4     02/15/06   Hernan Mendez      Added 5 new DLL esternal function calls to call_dll proc
|                                       DLL number 19 = PSMSNokia1221Unix
|                                       DLL number 20 = PSMSMotorola139Unix
|                                       DLL number 21 = PSMSNokia1600Unix
 1.5   03/14/06   Andrew Borja      CR4811 changes
 1.6   04/10/06     Vani Adapa      CR4981_4982 Added DLL calls to C261 and V176 models
 1.7   05/17/06      Vani Adapa     Same version
 1.8/1.9   066/13/06     CL/VA       Fix more OPEN_CURSORS issue
 1.10  08/01/2006   Hernan Mendez   Added 1 new DLL external funtion calls to call_dll proc
                                        DLL number 26 = PSMSLG3280Unix
| 1.11 09/18/06    VAdapa               Added check to send OTA message to any phone whose dll >21
| 1.12 01/15/07		 Hernan Mendez		Added 2 new DLL external funtion calls to call_dll proc
|                    						  		                   DLL number 25 = PSMSLG1500Unix
|                                       							   DLL number 27 = PSMSmotorola370unix
| 1.13 02/12/07		 HM/IC		 	  Added 2 new DLLS
| 1.14 03/06/07  	 IC DLL_LIST made larger to 100
| 1.15 05/15/07  	 IC			 	  		 Added 2 new DLLS 28, 29
| 1.16 05/15/07  	 HM			 	  		 Added 2 new DLLS 30, 32
| 1.17 02/13/08  	 HM			 	  		 Added 1 new DLLS 31
| 1.18 11/18/08  	 HM			 	  		 Added 1 new DLL
|                                            DLL number 37 = PSMSSamT301GUnix
| 1.19 01/08/09  	 HM			 	  		 Added 1 new DLL
|                                            DLL number 38 = PSMSMotoEM326GUnix
| 1.20 01/20/09  	 HM			 	  		 Added 1 new DLL
|                                            DLL number 40 = PSMSLg410GUnix
| 1.21 06/09/09  	 HM			 	  		 Added 1 new DLL
|                                            DLL number 41 = PSMSLg290Cunix
| 1.22 07/06/09  	 HM			 	  		 Added 1 new DLL
|                                            DLL number 42 = PSMSSamR451CUnix
| 1.23 07/30/09  	 HM			 	  		 Added 1 new DLL
|                                            DLL number 43 = PSMSSamT401GUnix
|
| REVISIONS IN NEW_PLSQL
|
| VERSION  DATE        WHO              PURPOSE
| -------  ---------- -----             ------------------------------------------------------
| 1.10-11 08/27/09     NGuada CR11670   BRAND_SEP Separate the Brand and Source System TO BE RELEASED WITH OR AFTER HANDSETS
| 1.12    09/03/09     VAdata           Latest
| 1.14    12/09/09  	 HM		Addded 3 new DLLs 44,45,46
| 1.15    12/09/09  	 		CR12569
|************************************************************************************************/

   /****
   Package level private variables
   ****/
   e_invalid_int_dll_to_use   EXCEPTION;
   -- Important: put all dll numbers from IF ... ELSIF statement below here in this list:
--CR4981_4982 start
   dll_list          constant varchar2 (150)
                  := '10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 26, 27, 28, 29, 30, 31, 32, 37, 38, 40, 41, 42, 43,44,45,46,47';

--    dll_list          CONSTANT VARCHAR2 (60)
--                               := '10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21';
--CR4981_4982 end
   /*****
   Private functions and procedures
   *****/
   PROCEDURE call_dll (
      p_int_dll_to_use     IN       NUMBER,
      p_ins                IN OUT   pltosl,
      p_outs               IN OUT   sltopl,
      p_error_number_out   IN OUT   NUMBER
   )
   IS
   BEGIN
      IF p_int_dll_to_use = 10
      THEN
         -- V120 and V60 phones:
         p_error_number_out := psmsmotorola120unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 12
      THEN
         p_error_number_out := psmsnokia1221unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 13
      THEN
         p_error_number_out := psmsnokia2285unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 14
      THEN
         p_error_number_out := psmsnokia1100unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 15
      THEN
         p_error_number_out := psmsmotorola150unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 16
      THEN
         p_error_number_out := psmsmotorola170unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 17
      THEN
         p_error_number_out := psmsmotorola343unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 18
      THEN
         p_error_number_out := psmsnokia2126unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 19
      THEN
         p_error_number_out := psmsnokia1112unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 20
      THEN
         p_error_number_out := psmsmotorola139unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 21
      THEN
         p_error_number_out := psmsnokia1600unix (p_ins, p_outs);
--CR4981_4982 start
      ELSIF p_int_dll_to_use = 22
      THEN
         p_error_number_out := psmsmotorola261unix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 23
      THEN
         p_error_number_out := psmsmotorola261unix (p_ins, p_outs);
         --p_error_number_out := psmsmotorola176unix (p_ins, p_outs);
--CR4981_4982 end
--CR5955 start
      ELSIF p_int_dll_to_use = 25
      THEN
         p_error_number_out := psmslg1500unix (p_ins, p_outs);
--CR5955 end
--CR5484 start
      ELSIF p_int_dll_to_use = 26
      THEN
         p_error_number_out := psmslg3280unix (p_ins, p_outs);
--CR5484 end
--CR5955 dll 27
      ELSIF p_int_dll_to_use = 27
      THEN
         p_error_number_out := psmsmotorola370unix (p_ins, p_outs);
----CR6049 dll 28 and 29
      ELSIF p_int_dll_to_use = 28
      THEN
         p_error_number_out := psmslg200cunix (p_ins, p_outs);
      ELSIF p_int_dll_to_use = 29
      THEN
         p_error_number_out := psmsok126cunix (p_ins, p_outs);
----CR dll 30 and 31
      ELSIF p_int_dll_to_use = 30
      THEN
         p_error_number_out := psmslg400gunix (p_ins, p_outs);
----CR dll 30
----CR dll 31
      ELSIF p_int_dll_to_use = 31
      THEN
         p_error_number_out := psmslg600gunix (p_ins, p_outs);
----CR dll 31
----CR dll 32
      ELSIF p_int_dll_to_use = 32
      THEN
         p_error_number_out := psmsmotorola175unix (p_ins, p_outs);
----CR dll 32
----CR dll 37
      ELSIF p_int_dll_to_use = 37
      THEN
         p_error_number_out := psmssamt301gunix (p_ins, p_outs);
----CR dll 37
----CR dll 38
      ELSIF p_int_dll_to_use = 38
      THEN
         p_error_number_out := psmsmotoem326gunix (p_ins, p_outs);
----CR dll 38
----CR dll 40
      ELSIF p_int_dll_to_use = 40
      THEN
         p_error_number_out := psmslg410gunix (p_ins, p_outs);
----CR dll 40
----CR dll 41
      ELSIF p_int_dll_to_use = 41
      THEN
         p_error_number_out := psmslg290cunix (p_ins, p_outs);
----CR dll 41
----CR dll 42
      ELSIF p_int_dll_to_use = 42
      THEN
         p_error_number_out := psmssamr451cunix (p_ins, p_outs);
----CR dll 42
----CR dll 43
      ELSIF p_int_dll_to_use = 43
      THEN
         p_error_number_out := psmssamt401gunix (p_ins, p_outs);
----CR dll 43
----CR dll 44
      ELSIF p_int_dll_to_use = 44
      THEN
         p_error_number_out := psmssamt105gunix (p_ins, p_outs);
----CR dll 44
----CR dll 45
      ELSIF p_int_dll_to_use = 45
      THEN
         p_error_number_out := psmssamr355cunix (p_ins, p_outs);
----CR dll 45
----CR dll 46
      ELSIF p_int_dll_to_use = 46
      THEN
         p_error_number_out := psmslg320gunix (p_ins, p_outs);
----CR dll 46
----CR dll 47
      ELSIF p_int_dll_to_use = 47
      THEN
         p_error_number_out := psmsmotow408gunix (p_ins, p_outs);
----CR dll 47
      ELSE
         RAISE e_invalid_int_dll_to_use;
      END IF;
   END call_dll;

   FUNCTION process_error_number (p_error_num IN NUMBER, p_error_code IN NUMBER)
      RETURN NUMBER
   IS
      n_return_value   NUMBER;
   BEGIN
      IF p_error_num = 1
      THEN
         -- this error indicates that there was a problem when we called DLL
         n_return_value := -1;
      ELSIF p_error_num = 0
      THEN
         -- this error indicates that DLL was called successfuly
         -- but it couldn't process our request and returned an error
         -- if there was no error generated by DLL, the value of p_error_code will be NULL
         n_return_value := p_error_code;
      ELSE
         -- this condition shouldn't happen under normal circumstances
         -- DLL function call should allways return 0 or 1
         n_return_value := NVL (p_error_code, p_error_num);
      END IF;

      RETURN n_return_value;
   END process_error_number;

   /*****
   Public functions and procedures
   *****/
   /***** Marketing stuff *****/
   -- active procedure
   PROCEDURE send_marketing_psms (
      p_esn_in             IN       VARCHAR2,
      p_sequence_in        IN       NUMBER,
      p_technology_in      IN       NUMBER,
      p_transid_in         IN       NUMBER,
      p_message_in         IN       VARCHAR2,
      p_int_dll_to_use     IN       NUMBER,
      p_error_number_out   OUT      NUMBER,
      p_message_out        OUT      VARCHAR2
   )
   IS
      ins           pltosl;
      outs          sltopl;
      n_error_num   NUMBER;
      command_cur   ota_extproc_pkg.ref_cur_type;
      command_rec   ota_extproc_pkg.command_rec_type;
   BEGIN
      -- initialize objects
      -- (it is better to have constructor member function called "initialize" for this thing)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      -- populate ins object with the values of input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (p_esn_in);
      ins.seq_struct := pl_sequence_structure (p_sequence_in);
      ins.tech_struct := pl_technology_structure (p_technology_in);
      ins.transid_struct := pl_transid_structure (p_transid_in);

--      IF p_int_dll_to_use IN (22, 23)
      IF p_int_dll_to_use > 21                                        --CR5484
      THEN
         ins.commandmsg_struct := pl_command_struct_array ();

         OPEN command_cur FOR    ' Select 1,309,0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             '''
                              || p_message_in
                              || ''', null, null ,null ,null ,null ,null ,null ,null ,null from dual';

         LOOP
            FETCH command_cur
             INTO command_rec;

            EXIT WHEN command_cur%NOTFOUND;
            ins.commandmsg_struct.EXTEND;
            ins.commandmsg_struct (command_cur%ROWCOUNT) :=
               pl_command_structure (command_rec.command,
                                     command_rec.first_double,
                                     command_rec.second_double,
                                     command_rec.third_double,
                                     command_rec.fourth_double,
                                     command_rec.fifth_double,
                                     command_rec.sixth_double,
                                     command_rec.serventh_double,
                                     command_rec.eight_double,
                                     command_rec.ninth_double,
                                     command_rec.tenth_double,
                                     command_rec.first_string,
                                     command_rec.second_string,
                                     command_rec.third_string,
                                     command_rec.fourth_string,
                                     command_rec.fifth_string,
                                     command_rec.sixth_string,
                                     command_rec.seventh_string,
                                     command_rec.eighth_string,
                                     command_rec.ninth_string,
                                     command_rec.tenth_string
                                    );
         END LOOP;

         CLOSE command_cur;
--      ins.commandmsg_struct := pl_command_struct_array(
--             ' Select 1,309,1, 2, 0, 0, 0, 0, 0, 0, 0, 0,
--             '' '', ''invalid redemption card'', null ,null ,null ,null ,null ,null ,null ,null from dual');
      ELSE
         ins.marketingmsg_struct := pl_marketing_structure (p_message_in);
      END IF;

      -- initialize out patameter
      outs.psmscode_struct := pl_psms_code_structure ('init');
      -- execute DLL:
      call_dll (p_int_dll_to_use, ins, outs, n_error_num);
      -- populate output parameters:
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);
      p_message_out := outs.psmscode_struct.psms_code;
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
            (p_action            => 'Sending marketing PSMS message',
             p_program_name      => 'OTA_EXTPROC_PKG.send_marketing_psms',
             p_error_text        =>    'Invalid value of p_int_dll_to_use passed to the procedure. Value: '
                                    || p_int_dll_to_use
                                    || '. Expected: '
                                    || dll_list
            );

--06/13/06
         IF command_cur%ISOPEN
         THEN
            CLOSE command_cur;
         END IF;

--06/13/06
         raise_application_error
            (-20001,
                'Procedure failed with error: '
             || 'Invalid value of int_dll_to_use passed to the procedure. Value: '
             || p_int_dll_to_use
             || '. Expected: '
             || dll_list
            );
      WHEN OTHERS
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
                    (p_action            => 'Sending marketing PSMS message',
                     p_program_name      => 'OTA_EXTPROC_PKG.send_marketing_psms',
                     p_error_text        => SQLERRM
                    );

--06/13/06
         IF command_cur%ISOPEN
         THEN
            CLOSE command_cur;
         END IF;

--06/13/06
         raise_application_error (-20002,
                                  'Procedure failed with error: ' || SQLERRM
                                 );
   END send_marketing_psms;

   /***** Card redemption stuff *****/
   -- active procedure - passes record set to the calling program instead of oracle object
   PROCEDURE send_redemption_psms (
      p_esn_in                  IN       VARCHAR2,
      p_sequence_in             IN       NUMBER,
      p_technology_in           IN       NUMBER DEFAULT 3,
      p_transid_in              IN       NUMBER,
      p_command_struct_sql_in   IN       VARCHAR2,
      p_inquiry_struct_sql_in   IN       VARCHAR2,
      p_int_dll_to_use          IN       NUMBER,
      p_cmdcode_rs_out          OUT      ota_extproc_pkg.ref_cur_type,
      p_message_out             OUT      VARCHAR2,
      p_error_number_out        OUT      NUMBER
   )
   IS
      -- DLL parameters
      ins             pltosl;
      outs            sltopl;
      -- SQL cursor for command structure (IN)
      command_cur     ota_extproc_pkg.ref_cur_type;
      command_rec     ota_extproc_pkg.command_rec_type;
      -- SQL cursor for inquiry structure (IN)
      inquiry_cur     ota_extproc_pkg.ref_cur_type;
      inquiry_rec     ota_extproc_pkg.inquiry_rec_type;
      -- SQL cursor for gencode structure (OUT)
      gencode_cur     ota_extproc_pkg.ref_cur_type;
      gencode_rec     cmdcode_rec_type;
      cmdcode_array   pl_comcode_array;
      n_error_num     NUMBER;
   BEGIN
      -- initialize objects
      -- (it is better to have constructor member function called "initialize" for this thing)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      -- populate ins object with the values of input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (p_esn_in);
      ins.seq_struct := pl_sequence_structure (p_sequence_in);
      ins.tech_struct := pl_technology_structure (p_technology_in);
      ins.transid_struct := pl_transid_structure (p_transid_in);
      -- This is SOLUTION to pass complex data structure from Java CBO to PL/SQL
         -- We have to pass data in this way bacuse Web Logic server 6.1 doesn't support
         -- passing OBJECTS from Java to PL/SQL and vice versa
         -- That feature is available in Web Logic version 8.1
      -- command message structure (IN parameter)
      -- initialize varray with 0 elements
      ins.commandmsg_struct := pl_command_struct_array ();

      OPEN command_cur FOR p_command_struct_sql_in;

      LOOP
         FETCH command_cur
          INTO command_rec;

         EXIT WHEN command_cur%NOTFOUND;
         ins.commandmsg_struct.EXTEND;
         ins.commandmsg_struct (command_cur%ROWCOUNT) :=
            pl_command_structure (command_rec.command,
                                  command_rec.first_double,
                                  command_rec.second_double,
                                  command_rec.third_double,
                                  command_rec.fourth_double,
                                  command_rec.fifth_double,
                                  command_rec.sixth_double,
                                  command_rec.serventh_double,
                                  command_rec.eight_double,
                                  command_rec.ninth_double,
                                  command_rec.tenth_double,
                                  command_rec.first_string,
                                  command_rec.second_string,
                                  command_rec.third_string,
                                  command_rec.fourth_string,
                                  command_rec.fifth_string,
                                  command_rec.sixth_string,
                                  command_rec.seventh_string,
                                  command_rec.eighth_string,
                                  command_rec.ninth_string,
                                  command_rec.tenth_string
                                 );
      END LOOP;

      CLOSE command_cur;

      -- inquiry message structure (IN parameter)
      -- this structure is not varray - only 1 record is expected
      OPEN inquiry_cur FOR p_inquiry_struct_sql_in;

      FETCH inquiry_cur
       INTO inquiry_rec;

      ins.inquirymsg_struct :=
         pl_inquiry_structure (inquiry_rec.first_string,
                               inquiry_rec.second_string,
                               inquiry_rec.third_string,
                               inquiry_rec.fourth_string,
                               inquiry_rec.fifth_string,
                               inquiry_rec.sixth_string,
                               inquiry_rec.seventh_string,
                               inquiry_rec.eighth_string,
                               inquiry_rec.ninth_string,
                               inquiry_rec.tenth_string
                              );

      CLOSE inquiry_cur;

      -- initialize out parameters
      outs.psmscode_struct := pl_psms_code_structure (' ');
      outs.cmdcode_struct :=
         pl_comcode_array (pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' ')
                          );
      -- execute DLL:
      call_dll (p_int_dll_to_use, ins, outs, n_error_num);
      -- populate output parameters:
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);

      -- populate output parameter from object outs
      -- convert object structure to cur ref so that calling java class can receive it as a record set
      -- cmdcode_array := outs.CMDCODE_STRUCT;
      OPEN p_cmdcode_rs_out FOR
         SELECT *
           FROM TABLE (CAST (outs.cmdcode_struct AS pl_comcode_array));

      p_message_out := outs.psmscode_struct.psms_code;
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
            (p_action            => 'Sending redemption PSMS message',
             p_program_name      => 'OTA_EXTPROC_PKG.send_redemption_psms',
             p_error_text        =>    'Invalid value of p_int_dll_to_use passed to the procedure. Value: '
                                    || p_int_dll_to_use
                                    || '. Expected: '
                                    || dll_list
            );

--06/13/06
         IF command_cur%ISOPEN
         THEN
            CLOSE command_cur;
         END IF;

         IF inquiry_cur%ISOPEN
         THEN
            CLOSE inquiry_cur;
         END IF;

         IF p_cmdcode_rs_out%ISOPEN
         THEN
            CLOSE p_cmdcode_rs_out;
         END IF;

--06/13/06
         raise_application_error
            (-20001,
                'Procedure failed with error: '
             || 'Invalid value of int_dll_to_use passed to the procedure. Value: '
             || p_int_dll_to_use
             || '. Expected: '
             || dll_list
            );
      WHEN OTHERS
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
                   (p_action            => 'Sending redemption PSMS message',
                    p_program_name      => 'OTA_EXTPROC_PKG.send_redemption_psms',
                    p_error_text        => SQLERRM
                   );

--06/13/06
         IF command_cur%ISOPEN
         THEN
            CLOSE command_cur;
         END IF;

         IF inquiry_cur%ISOPEN
         THEN
            CLOSE inquiry_cur;
         END IF;

         IF p_cmdcode_rs_out%ISOPEN
         THEN
            CLOSE p_cmdcode_rs_out;
         END IF;

--06/13/06
         raise_application_error (-20002,
                                  'Procedure failed with error: ' || SQLERRM
                                 );
   END send_redemption_psms;

   -- Inactive procedure (needs to be used when we upgrade our Web Logic server to higher version)
   PROCEDURE send_redemption_psms_obj (
      p_esn_in                    IN       VARCHAR2,
      p_sequence_in               IN       NUMBER,
      p_technology_in             IN       NUMBER DEFAULT 3,
      p_transid_in                IN       NUMBER,
      p_command_struct_array_in   IN       pl_command_struct_array,
      p_inquiry_structure_in      IN       pl_inquiry_structure,
      p_int_dll_to_use            IN       NUMBER,
      p_error_number_out          OUT      NUMBER,
      p_gencode_out               OUT      VARCHAR2,
      p_message_out               OUT      VARCHAR2
   )
   IS
      ins           pltosl;
      outs          sltopl;
      n_error_num   NUMBER;
   BEGIN
      -- initialize objects
      -- (it is better to have constructor member function called "initialize" for this thing)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      -- populate ins object with the values of input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (p_esn_in);
      ins.seq_struct := pl_sequence_structure (p_sequence_in);
      ins.tech_struct := pl_technology_structure (p_technology_in);
      ins.transid_struct := pl_transid_structure (p_transid_in);
      -- passing inq object from java CBO
      ins.inquirymsg_struct := p_inquiry_structure_in;
      -- passing command object array from java CBO
      ins.commandmsg_struct := p_command_struct_array_in;
      -- initialize out parameters
      outs.psmscode_struct := pl_psms_code_structure (' ');
      outs.cmdcode_struct :=
         pl_comcode_array (pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' ')
                          );
      -- execute DLL:
      call_dll (p_int_dll_to_use, ins, outs, n_error_num);
      -- populate output parameters:
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);
      p_gencode_out := outs.cmdcode_struct (1).gencode;
      p_message_out := outs.psmscode_struct.psms_code;
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
            (p_action            => 'Sending redemption PSMS message',
             p_program_name      => 'OTA_EXTPROC_PKG.send_redemption_psms',
             p_error_text        =>    'Invalid value of p_int_dll_to_use passed to the procedure. Value: '
                                    || p_int_dll_to_use
                                    || '. Expected: '
                                    || dll_list
            );
         raise_application_error
            (-20001,
                'Procedure failed with error: '
             || 'Invalid value of int_dll_to_use passed to the procedure. Value: '
             || p_int_dll_to_use
             || '. Expected: '
             || dll_list
            );
      WHEN OTHERS
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
                   (p_action            => 'Sending redemption PSMS message',
                    p_program_name      => 'OTA_EXTPROC_PKG.send_redemption_psms',
                    p_error_text        => SQLERRM
                   );
         raise_application_error (-20001,
                                  'Procedure failed with error: ' || SQLERRM
                                 );
   END send_redemption_psms_obj;

   /***** Acknowledgment stuff *****/
   /***** Acknowledgment stuff *****/
   -- active procedure - passes record set to the calling program instead of oracle object
   PROCEDURE parse_acknowledgment (
      p_message_in          IN       VARCHAR2,
      p_min_in              IN       VARCHAR2
                                             -- 06/27/05 not used, p_technology_in      IN NUMBER   DEFAULT 3 CR4169
   ,
      p_esn_out             OUT      VARCHAR2,
      p_sequence_out        OUT      NUMBER,
      p_transid_out         OUT      NUMBER,
      p_ack_code_out        OUT      NUMBER,
      p_inquiry_rs_out      OUT      ota_extproc_pkg.ref_cur_type,
      p_redemption_rs_out   OUT      ota_extproc_pkg.ref_cur_type,
      p_error_number_out    OUT      NUMBER,
      p_x_dll_out           OUT      NUMBER,
      p_restricted_use      OUT      NUMBER
   )
   IS
      -- error number generated in C program (wraper for engeneering DLL program)
      -- 0 = Success, 1 = Failure
      n_error_num_dll_call   NUMBER;
      -- error number generated inside of this procedure
      -- This number will contain negative values to differentiate it from C program errors
      -- Values
      /*
      | -100
      */
      n_error_num_local      NUMBER;
      ins                    pltosl;
      outs                   sltopl;
      inquiry_array          pl_inquirack_array;
      inquiry_cur            ota_extproc_pkg.ref_cur_type;
      redemption_struct      pl_redemption_structure;
      redemption_cur         ota_extproc_pkg.ref_cur_type;
      terminate_procedure    EXCEPTION;

      -- for the redemption and all other actions except activation:
      -- esn must be active to proceed
      CURSOR esn_redemp_cur (p_min IN VARCHAR2)
      IS
         SELECT tpiesn.part_serial_no esn, tpiesn.x_sequence, tpn.x_dll,
                tpiesn.part_inst2carrier_mkt, tpn.objid,
                tpn.x_restricted_use, tpiesn.x_part_inst_status,
                DECODE
                      (tpn.x_technology,
                       'ANALOG', '0'   -- 06/27/05 replace '1' with '0' CR4169
                                    ,
                       'CDMA', '2',
                       'TDMA', '1'     -- 06/27/05 replace '2' with '1' CR4169
                                  ,
                       'GSM', '3'
                      ) technology
           FROM table_mod_level tml,
                table_part_num tpn,
                table_x_code_table txctmin,
                table_x_code_table txctesn,
                table_part_inst tpimin,
                table_part_inst tpiesn
          WHERE tpn.objid = tml.part_info2part_num
            AND tml.objid = tpiesn.n_part_inst2part_mod
            AND tpiesn.objid = tpimin.part_to_esn2part_inst
            AND tpimin.x_part_inst_status = txctmin.x_code_number
            AND tpiesn.x_part_inst_status = txctesn.x_code_number
            AND tpiesn.x_domain = 'PHONES'
            AND tpimin.x_domain = 'LINES'
            AND txctmin.x_code_number IN
                   (ota_util_pkg.msid_update,
                    ota_util_pkg.line_active,
                    ota_util_pkg.pending_ac_change
                   )
            AND txctesn.x_code_name = 'ACTIVE'
            AND tpimin.part_serial_no = p_min;

      esn_redemp_rec         esn_redemp_cur%ROWTYPE;

      -- for the activation
      -- esn and min cannot be active at this time
      CURSOR esn_activation_cur (p_min IN VARCHAR2)
      IS
         SELECT tpiesn.part_serial_no esn, tpiesn.x_sequence, tpn.x_dll,
                tpiesn.part_inst2carrier_mkt, tpn.objid, tpn.x_restricted_use,
                tpiesn.x_part_inst_status,
                DECODE
                     (tpn.x_technology,
                      'ANALOG', '0'    -- 06/27/05 replace '1' with '0' CR4169
                                   ,
                      'CDMA', '2',
                      'TDMA', '1'     -- 06/27/05 replace '2' with '1'  CR4169
                                 ,
                      'GSM', '3'
                     ) technology
           FROM table_mod_level tml,
                table_part_num tpn,
                table_x_code_table txctesn,
                table_x_code_table txctmin,
                table_part_inst tpimin,
                table_part_inst tpiesn
          WHERE tpn.objid = tml.part_info2part_num
            AND tml.objid = tpiesn.n_part_inst2part_mod
            AND tpiesn.objid = tpimin.part_to_esn2part_inst
            AND tpimin.x_part_inst_status = txctmin.x_code_number
            AND tpiesn.x_part_inst_status = txctesn.x_code_number
            AND tpiesn.x_domain = 'PHONES'
            AND tpimin.x_domain = 'LINES'
            AND tpimin.part_serial_no = p_min;

      esn_activation_rec     esn_activation_cur%ROWTYPE;
      -- for esn_rec to work: the record structure of esn_activation_rec and esn_redemp_rec must be the same
      esn_rec                esn_activation_cur%ROWTYPE;

      FUNCTION is_redemption (p_min_in IN VARCHAR2)
         RETURN BOOLEAN
      IS
         b_return_value   BOOLEAN := FALSE;
      BEGIN
         OPEN esn_redemp_cur (p_min_in);

         FETCH esn_redemp_cur
          INTO esn_redemp_rec;

         IF esn_redemp_cur%NOTFOUND
         THEN
            esn_redemp_rec.esn := ota_util_pkg.dummy_esn;
            esn_redemp_rec.x_sequence := ota_util_pkg.dummy_sequence;
         ELSE
            b_return_value := TRUE;
         END IF;

         CLOSE esn_redemp_cur;

         RETURN b_return_value;
      --06/14/06
      EXCEPTION
         WHEN OTHERS
         THEN
            IF esn_redemp_cur%ISOPEN
            THEN
               CLOSE esn_redemp_cur;
            END IF;

            esn_redemp_rec.esn := ota_util_pkg.dummy_esn;
            esn_redemp_rec.x_sequence := ota_util_pkg.dummy_sequence;
            RETURN FALSE;
      --06/14/06
      END is_redemption;

      FUNCTION is_activation (p_min IN VARCHAR2)
         RETURN BOOLEAN
      IS
         -- determines if we have an activation and OTA PENDING
         CURSOR c_call_trans (p_min VARCHAR2, p_esn VARCHAR2)
         IS
            SELECT   x_action_type, x_result
                FROM table_x_call_trans
               WHERE x_action_type = ota_util_pkg.activation
                 --AND    x_result  = 'OTA PENDING'--CR4811
                 AND x_min = p_min
                 AND x_service_id = p_esn
            ORDER BY objid DESC;

         c_call_trans_rec   c_call_trans%ROWTYPE;
         b_return_value     BOOLEAN                := FALSE;
      BEGIN
         OPEN esn_activation_cur (p_min);

         FETCH esn_activation_cur
          INTO esn_activation_rec;

         IF esn_activation_cur%FOUND
         THEN
            OPEN c_call_trans (p_min, esn_activation_rec.esn);

            FETCH c_call_trans
             INTO c_call_trans_rec;

            IF c_call_trans%FOUND
            THEN
               b_return_value := TRUE;
            END IF;

            CLOSE c_call_trans;
         END IF;

         CLOSE esn_activation_cur;

         RETURN b_return_value;
      --06/14/06
      EXCEPTION
         WHEN OTHERS
         THEN
            IF esn_activation_cur%ISOPEN
            THEN
               CLOSE esn_activation_cur;
            END IF;

            RETURN FALSE;
      --06/14/06
      END is_activation;
   BEGIN
      -- initialization (need constructor member function called "initialize" for this)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      outs.inquiryack_struct :=
         pl_inquirack_array (pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     )
                            );

      -- try to get esn info:
      IF is_redemption (p_min_in)
      THEN
         -- we have redemption in place
         esn_rec := esn_redemp_rec;
      ELSE
         IF NOT is_activation (p_min_in)
         THEN
            /* TERMINATE procedure here */
            --
            -- no matching data found in database for given MIN
            -- unable to process request
            --
            n_error_num_local := -100;
            RAISE terminate_procedure;
         END IF;

         -- we have activation in place
         esn_rec := esn_activation_rec;
      END IF;

      --populate input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (esn_rec.esn);
      ins.ack_struct := pl_ack_structure (p_message_in);

      -- we don't use the value of input parameter p_technology_in anymore to populate the structure ins.TECH_STRUCT
      -- instead, we are getting the value for ins.TECH_STRUCT from database: TABLE_PART_NUM.X_TECHNOLOGY
      -- and decoding it in the following way:
      -- 'ANALOG' is decoded to '0'
             -- 'CDMA' to              '2'
             -- 'TDMA' also to         '1'
             -- and 'GSM' to           '3'
             -- because DLL is expecting numeric value

      -- 06/27/05 CR4169 if technology is ANALOG terminate the process
      IF esn_rec.technology = 'ANALOG'
      THEN
         n_error_num_local := -600;
         RAISE terminate_procedure;
      END IF;

      --ins.TECH_STRUCT    := PL_TECHNOLOGY_STRUCTURE(p_technology_in);
      ins.tech_struct := pl_technology_structure (esn_rec.technology);
      -- END 06/27/05  CR4169
      ins.seq_struct := pl_sequence_structure (esn_rec.x_sequence);
      ins.transid_struct := pl_transid_structure (0);
      -- populate 4 out parameters:
      p_esn_out := esn_rec.esn;
      p_sequence_out := esn_rec.x_sequence;
      p_x_dll_out := esn_rec.x_dll;
      p_restricted_use := esn_rec.x_restricted_use;
      -- execute DLL:
      call_dll (p_x_dll_out, ins, outs, n_error_num_dll_call);
      -- return 3 more out parameters:
      p_error_number_out :=
         process_error_number (n_error_num_dll_call,
                               outs.errorcode_struct.ERROR_CODE
                              );
      p_transid_out := outs.transid_struct.transid;
      p_ack_code_out := outs.ackreturn_struct.first_string;

      -- convert object to cur ref so that calling java class can receive it as record set
      -- inquiry rs
      -- 06/27/05 CR4169 due problem in v60, v120 we need to null inquiry if code is accepted by phone
      IF p_x_dll_out = 10 AND TO_NUMBER (p_ack_code_out) > 0
      THEN
         outs.inquiryack_struct :=
            pl_inquirack_array (pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        )
                               );
      END IF;

      -- end 06/27/05 CR4169
      inquiry_array := outs.inquiryack_struct;

      OPEN p_inquiry_rs_out FOR
         SELECT *
           FROM TABLE (CAST (inquiry_array AS pl_inquirack_array));

      -- redemption rs
      redemption_struct := outs.redemption_struct;

      OPEN p_redemption_rs_out FOR
         SELECT REPLACE (redemption_struct.first_string,
                         '''',
                         ''''''
                        ) AS first_string,
                REPLACE
                   (redemption_struct.first_denomination,
                    '''',
                    ''''''
                   ) AS first_denomination,
                REPLACE
                     (redemption_struct.first_promo_code,
                      '''',
                      ''''''
                     ) AS first_promo_code,
                REPLACE (redemption_struct.second_string,
                         '''',
                         ''''''
                        ) AS second_string,
                REPLACE
                   (redemption_struct.second_denomination,
                    '''',
                    ''''''
                   ) AS second_denomination,
                REPLACE
                   (redemption_struct.second_promo_code,
                    '''',
                    ''''''
                   ) AS second_promo_code,
                REPLACE (redemption_struct.third_string,
                         '''',
                         ''''''
                        ) AS third_string,
                REPLACE
                   (redemption_struct.third_denomination,
                    '''',
                    ''''''
                   ) AS third_denomination,
                REPLACE
                     (redemption_struct.third_promo_code,
                      '''',
                      ''''''
                     ) AS third_promo_code
           FROM DUAL;

      p_error_number_out := NVL (p_error_number_out, n_error_num_local);
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         -- invalid X_DLL number and because of that we didn't call C program
         p_error_number_out := -500;

--06/13/06
         IF p_inquiry_rs_out%ISOPEN
         THEN
            CLOSE p_inquiry_rs_out;
         END IF;

         IF p_redemption_rs_out%ISOPEN
         THEN
            CLOSE p_redemption_rs_out;
         END IF;

--06/13/06
         ota_util_pkg.err_log
            (p_action            => 'Parsing OTA acknowledgment message',
             p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment',
             p_key               => p_min_in,
             p_error_text        =>    p_error_number_out
                                    || ' Invalid value for p_x_dll_out found. Value: '
                                    || p_x_dll_out
                                    || '. Expected: '
                                    || dll_list
            );
      WHEN terminate_procedure
      THEN
         -- just exit the procedure gracefuly
         p_error_number_out := NVL (p_error_number_out, n_error_num_local);

--06/13/06
         IF p_inquiry_rs_out%ISOPEN
         THEN
            CLOSE p_inquiry_rs_out;
         END IF;

         IF p_redemption_rs_out%ISOPEN
         THEN
            CLOSE p_redemption_rs_out;
         END IF;

--06/13/06
         ota_util_pkg.err_log
            (p_action            => 'Parsing OTA acknowledgment message',
             p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment',
             p_key               => p_min_in,
             p_error_text        =>    n_error_num_local
                                    || ' No matching data found in database for given MIN '
                                    || p_min_in
                                    || '. Stored procedure terminated.'
            );
      WHEN OTHERS
      THEN
         -- unexpected error
         p_error_number_out := -600;

--06/13/06
         IF p_inquiry_rs_out%ISOPEN
         THEN
            CLOSE p_inquiry_rs_out;
         END IF;

         IF p_redemption_rs_out%ISOPEN
         THEN
            CLOSE p_redemption_rs_out;
         END IF;

--06/13/06
         ota_util_pkg.err_log
                    (p_action            => 'Parsing OTA acknowledgment message',
                     p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment',
                     p_key               => p_min_in,
                     p_error_text        => p_error_number_out || ' '
                                            || SQLERRM
                    );
   END parse_acknowledgment;

   -- Inactive procedure - needs to be used once when we upgrade Web Logic server to the higher version
   PROCEDURE parse_acknowledgment_obj (
      p_message_in           IN       VARCHAR2,
      p_min_in               IN       VARCHAR2,
      p_technology_in        IN       NUMBER DEFAULT 3,
      p_esn_out              OUT      VARCHAR2,
      p_sequence_out         OUT      NUMBER,
      p_transid_out          OUT      NUMBER,
      p_ack_code_out         OUT      NUMBER,
      p_inquiry_obj_out      OUT      pl_inquirack_array,
      p_redemption_obj_out   OUT      pl_redemption_structure,
      p_error_number_out     OUT      NUMBER,
      p_x_dll_out            OUT      NUMBER,
      p_restricted_use       OUT      NUMBER
   )
   IS
      n_error_num               NUMBER;
      n_error_code              NUMBER;
      ins                       pltosl;
      outs                      sltopl;
      inquiry_array             pl_inquirack_array;
      inquiry_cur               ota_extproc_pkg.ref_cur_type;
      dummy_esn        CONSTANT VARCHAR2 (15)            := '111111111111111';
      -- 15 digits number for technology GSM
      dummy_sequence   CONSTANT NUMBER                       := 0;

      CURSOR esn_cur (p_min IN VARCHAR2)
      IS
         SELECT tpiesn.part_serial_no esn, tpiesn.x_sequence, tpn.x_dll,
                tpiesn.part_inst2carrier_mkt, tpn.objid,
                tpn.x_restricted_use
           FROM table_mod_level tml,
                table_part_num tpn,
                table_x_code_table txct1,
                table_x_code_table txct2,
                table_part_inst tpimin,
                table_part_inst tpiesn
          WHERE tpn.objid = tml.part_info2part_num
            AND tml.objid = tpiesn.n_part_inst2part_mod
            AND tpiesn.objid = tpimin.part_to_esn2part_inst
            AND tpimin.x_part_inst_status = txct1.x_code_number
            AND tpiesn.x_part_inst_status = txct2.x_code_number
            AND tpiesn.x_domain = 'PHONES'
            AND tpimin.x_domain = 'LINES'
            AND txct1.x_code_name = 'ACTIVE'
            AND txct2.x_code_name = 'ACTIVE'
            AND tpimin.part_serial_no = p_min;

      esn_rec                   esn_cur%ROWTYPE;

      PROCEDURE get_esn (p_min_in IN VARCHAR2)
      IS
      BEGIN
         OPEN esn_cur (p_min_in);

         FETCH esn_cur
          INTO esn_rec;

         IF esn_cur%NOTFOUND
         THEN
            esn_rec.esn := dummy_esn;
            esn_rec.x_sequence := dummy_sequence;
         END IF;

         CLOSE esn_cur;
      END get_esn;
   BEGIN
      -- initialization (need constructor member function called "initialize" for this)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      outs.inquiryack_struct :=
         pl_inquirack_array (pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     )
                            );
      outs.redemption_struct :=
         pl_redemption_structure (' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
      -- get esn info:
      get_esn (p_min_in);
      --populate input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (esn_rec.esn);
      ins.ack_struct := pl_ack_structure (p_message_in);
      ins.tech_struct := pl_technology_structure (p_technology_in);
      ins.seq_struct := pl_sequence_structure (esn_rec.x_sequence);
      -- execute DLL:
      call_dll (esn_rec.x_dll, ins, outs, n_error_num);
      -- return 7 out parameters:
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);
      p_transid_out := outs.transid_struct.transid;
      p_ack_code_out := outs.ackreturn_struct.first_string;
      p_esn_out := esn_rec.esn;
      p_sequence_out := esn_rec.x_sequence;
      p_x_dll_out := esn_rec.x_dll;
      p_restricted_use := esn_rec.x_restricted_use;
      -- execute DLL:
      call_dll (p_x_dll_out, ins, outs, n_error_num);
      -- populate output parameters:
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);
      -- In this procedure we will pass a varray directly to the calling java class:
      p_inquiry_obj_out := outs.inquiryack_struct;
      p_redemption_obj_out := outs.redemption_struct;
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
            (p_action            => 'Parsing OTA acknowledgment message',
             p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment_obj',
             p_error_text        =>    'Invalid value for p_x_dll_out found. Value: '
                                    || p_x_dll_out
                                    || '. Expected: '
                                    || dll_list
            );
         raise_application_error
                            (-20001,
                                'Procedure failed with error: '
                             || 'Invalid value for p_x_dll_out found. Value: '
                             || p_x_dll_out
                             || '.Expected: '
                             || dll_list
                            );
      WHEN OTHERS
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
               (p_action            => 'Parsing OTA acknowledgment message',
                p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment_obj',
                p_error_text        => SQLERRM
               );
         raise_application_error (-20001,
                                  'Procedure failed with error: ' || SQLERRM
                                 );
   END parse_acknowledgment_obj;


   -- active procedure - passes record set to the calling program instead of oracle object
   PROCEDURE parse_acknowledgment (
      p_message_in          IN       VARCHAR2,
      p_min_in              IN       VARCHAR2
                                             -- 06/27/05 not used, p_technology_in      IN NUMBER   DEFAULT 3 CR4169
   ,
      p_esn_out             OUT      VARCHAR2,
      p_sequence_out        OUT      NUMBER,
      p_transid_out         OUT      NUMBER,
      p_ack_code_out        OUT      NUMBER,
      p_inquiry_rs_out      OUT      ota_extproc_pkg.ref_cur_type,
      p_redemption_rs_out   OUT      ota_extproc_pkg.ref_cur_type,
      p_error_number_out    OUT      NUMBER,
      p_x_dll_out           OUT      NUMBER,
      p_brand_name          OUT      VARCHAR2
   )
   IS
      -- error number generated in C program (wraper for engeneering DLL program)
      -- 0 = Success, 1 = Failure
      n_error_num_dll_call   NUMBER;
      -- error number generated inside of this procedure
      -- This number will contain negative values to differentiate it from C program errors
      -- Values
      /*
      | -100
      */
      n_error_num_local      NUMBER;
      ins                    pltosl;
      outs                   sltopl;
      inquiry_array          pl_inquirack_array;
      inquiry_cur            ota_extproc_pkg.ref_cur_type;
      redemption_struct      pl_redemption_structure;
      redemption_cur         ota_extproc_pkg.ref_cur_type;
      terminate_procedure    EXCEPTION;

      -- for the redemption and all other actions except activation:
      -- esn must be active to proceed
      CURSOR esn_redemp_cur (p_min IN VARCHAR2)
      IS
         SELECT tpiesn.part_serial_no esn, tpiesn.x_sequence, tpn.x_dll,
                tpiesn.part_inst2carrier_mkt, tpn.objid,
                tpiesn.x_part_inst_status,
                DECODE
                      (tpn.x_technology,
                       'ANALOG', '0'   -- 06/27/05 replace '1' with '0' CR4169
                                    ,
                       'CDMA', '2',
                       'TDMA', '1'     -- 06/27/05 replace '2' with '1' CR4169
                                  ,
                       'GSM', '3'
                      ) technology,
                bo.ORG_ID
           FROM table_mod_level tml,
                table_part_num tpn,
                table_x_code_table txctmin,
                table_x_code_table txctesn,
                table_part_inst tpimin,
                table_part_inst tpiesn,
                table_bus_org bo
          WHERE tpn.objid = tml.part_info2part_num
            AND tml.objid = tpiesn.n_part_inst2part_mod
            AND tpiesn.objid = tpimin.part_to_esn2part_inst
            AND tpimin.x_part_inst_status = txctmin.x_code_number
            AND tpiesn.x_part_inst_status = txctesn.x_code_number
            AND tpiesn.x_domain = 'PHONES'
            AND tpimin.x_domain = 'LINES'
            AND txctmin.x_code_number IN
                   (ota_util_pkg.msid_update,
                    ota_util_pkg.line_active,
                    ota_util_pkg.pending_ac_change
                   )
            AND txctesn.x_code_name = 'ACTIVE'
            AND tpimin.part_serial_no = p_min
            and bo.OBJID = tpn.part_num2bus_org;

      esn_redemp_rec         esn_redemp_cur%ROWTYPE;

      -- for the activation
      -- esn and min cannot be active at this time
      CURSOR esn_activation_cur (p_min IN VARCHAR2)
      IS
         SELECT tpiesn.part_serial_no esn, tpiesn.x_sequence, tpn.x_dll,
                tpiesn.part_inst2carrier_mkt, tpn.objid,
                tpiesn.x_part_inst_status,
                DECODE
                     (tpn.x_technology,
                      'ANALOG', '0'    -- 06/27/05 replace '1' with '0' CR4169
                                   ,
                      'CDMA', '2',
                      'TDMA', '1'     -- 06/27/05 replace '2' with '1'  CR4169
                                 ,
                      'GSM', '3'
                     ) technology,
                     bo.org_id
           FROM table_mod_level tml,
                table_part_num tpn,
                table_x_code_table txctesn,
                table_x_code_table txctmin,
                table_part_inst tpimin,
                table_part_inst tpiesn,
                table_bus_org bo
          WHERE tpn.objid = tml.part_info2part_num
            AND tml.objid = tpiesn.n_part_inst2part_mod
            AND tpiesn.objid = tpimin.part_to_esn2part_inst
            AND tpimin.x_part_inst_status = txctmin.x_code_number
            AND tpiesn.x_part_inst_status = txctesn.x_code_number
            AND tpiesn.x_domain = 'PHONES'
            AND tpimin.x_domain = 'LINES'
            AND tpimin.part_serial_no = p_min
            AND bo.objid = tpn.part_num2bus_org;

      esn_activation_rec     esn_activation_cur%ROWTYPE;
      -- for esn_rec to work: the record structure of esn_activation_rec and esn_redemp_rec must be the same
      esn_rec                esn_activation_cur%ROWTYPE;

      FUNCTION is_redemption (p_min_in IN VARCHAR2)
         RETURN BOOLEAN
      IS
         b_return_value   BOOLEAN := FALSE;
      BEGIN
         OPEN esn_redemp_cur (p_min_in);

         FETCH esn_redemp_cur
          INTO esn_redemp_rec;

         IF esn_redemp_cur%NOTFOUND
         THEN
            esn_redemp_rec.esn := ota_util_pkg.dummy_esn;
            esn_redemp_rec.x_sequence := ota_util_pkg.dummy_sequence;
         ELSE
            b_return_value := TRUE;
         END IF;

         CLOSE esn_redemp_cur;

         RETURN b_return_value;
      --06/14/06
      EXCEPTION
         WHEN OTHERS
         THEN
            IF esn_redemp_cur%ISOPEN
            THEN
               CLOSE esn_redemp_cur;
            END IF;

            esn_redemp_rec.esn := ota_util_pkg.dummy_esn;
            esn_redemp_rec.x_sequence := ota_util_pkg.dummy_sequence;
            RETURN FALSE;
      --06/14/06
      END is_redemption;

      FUNCTION is_activation (p_min IN VARCHAR2)
         RETURN BOOLEAN
      IS
         -- determines if we have an activation and OTA PENDING
         CURSOR c_call_trans (p_min VARCHAR2, p_esn VARCHAR2)
         IS
            SELECT   x_action_type, x_result
                FROM table_x_call_trans
               WHERE x_action_type = ota_util_pkg.activation
                 --AND    x_result  = 'OTA PENDING'--CR4811
                 AND x_min = p_min
                 AND x_service_id = p_esn
            ORDER BY objid DESC;

         c_call_trans_rec   c_call_trans%ROWTYPE;
         b_return_value     BOOLEAN                := FALSE;
      BEGIN
         OPEN esn_activation_cur (p_min);

         FETCH esn_activation_cur
          INTO esn_activation_rec;

         IF esn_activation_cur%FOUND
         THEN
            OPEN c_call_trans (p_min, esn_activation_rec.esn);

            FETCH c_call_trans
             INTO c_call_trans_rec;

            IF c_call_trans%FOUND
            THEN
               b_return_value := TRUE;
            END IF;

            CLOSE c_call_trans;
         END IF;

         CLOSE esn_activation_cur;

         RETURN b_return_value;
      --06/14/06
      EXCEPTION
         WHEN OTHERS
         THEN
            IF esn_activation_cur%ISOPEN
            THEN
               CLOSE esn_activation_cur;
            END IF;

            RETURN FALSE;
      --06/14/06
      END is_activation;
   BEGIN
      -- initialization (need constructor member function called "initialize" for this)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      outs.inquiryack_struct :=
         pl_inquirack_array (pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     )
                            );

      -- try to get esn info:
      IF is_redemption (p_min_in)
      THEN
         -- we have redemption in place
         esn_rec := esn_redemp_rec;
      ELSE
         IF NOT is_activation (p_min_in)
         THEN
            /* TERMINATE procedure here */
            --
            -- no matching data found in database for given MIN
            -- unable to process request
            --
            n_error_num_local := -100;
            RAISE terminate_procedure;
         END IF;

         -- we have activation in place
         esn_rec := esn_activation_rec;
      END IF;

      --populate input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (esn_rec.esn);
      ins.ack_struct := pl_ack_structure (p_message_in);

      -- we don't use the value of input parameter p_technology_in anymore to populate the structure ins.TECH_STRUCT
      -- instead, we are getting the value for ins.TECH_STRUCT from database: TABLE_PART_NUM.X_TECHNOLOGY
      -- and decoding it in the following way:
      -- 'ANALOG' is decoded to '0'
             -- 'CDMA' to              '2'
             -- 'TDMA' also to         '1'
             -- and 'GSM' to           '3'
             -- because DLL is expecting numeric value

      -- 06/27/05 CR4169 if technology is ANALOG terminate the process
      IF esn_rec.technology = 'ANALOG'
      THEN
         n_error_num_local := -600;
         RAISE terminate_procedure;
      END IF;

      --ins.TECH_STRUCT    := PL_TECHNOLOGY_STRUCTURE(p_technology_in);
      ins.tech_struct := pl_technology_structure (esn_rec.technology);
      -- END 06/27/05  CR4169
      ins.seq_struct := pl_sequence_structure (esn_rec.x_sequence);
      ins.transid_struct := pl_transid_structure (0);
      -- populate 4 out parameters:
      p_esn_out := esn_rec.esn;
      p_sequence_out := esn_rec.x_sequence;
      p_x_dll_out := esn_rec.x_dll;
      p_brand_name := esn_rec.org_id;
      -- execute DLL:
      call_dll (p_x_dll_out, ins, outs, n_error_num_dll_call);
      -- return 3 more out parameters:
      p_error_number_out :=
         process_error_number (n_error_num_dll_call,
                               outs.errorcode_struct.ERROR_CODE
                              );
      p_transid_out := outs.transid_struct.transid;
      p_ack_code_out := outs.ackreturn_struct.first_string;

      -- convert object to cur ref so that calling java class can receive it as record set
      -- inquiry rs
      -- 06/27/05 CR4169 due problem in v60, v120 we need to null inquiry if code is accepted by phone
      IF p_x_dll_out = 10 AND TO_NUMBER (p_ack_code_out) > 0
      THEN
         outs.inquiryack_struct :=
            pl_inquirack_array (pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        ),
                                pl_inquiryack_structure (' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' ',
                                                         ' '
                                                        )
                               );
      END IF;

      -- end 06/27/05 CR4169
      inquiry_array := outs.inquiryack_struct;

      OPEN p_inquiry_rs_out FOR
         SELECT *
           FROM TABLE (CAST (inquiry_array AS pl_inquirack_array));

      -- redemption rs
      redemption_struct := outs.redemption_struct;

      OPEN p_redemption_rs_out FOR
         SELECT REPLACE (redemption_struct.first_string,
                         '''',
                         ''''''
                        ) AS first_string,
                REPLACE
                   (redemption_struct.first_denomination,
                    '''',
                    ''''''
                   ) AS first_denomination,
                REPLACE
                     (redemption_struct.first_promo_code,
                      '''',
                      ''''''
                     ) AS first_promo_code,
                REPLACE (redemption_struct.second_string,
                         '''',
                         ''''''
                        ) AS second_string,
                REPLACE
                   (redemption_struct.second_denomination,
                    '''',
                    ''''''
                   ) AS second_denomination,
                REPLACE
                   (redemption_struct.second_promo_code,
                    '''',
                    ''''''
                   ) AS second_promo_code,
                REPLACE (redemption_struct.third_string,
                         '''',
                         ''''''
                        ) AS third_string,
                REPLACE
                   (redemption_struct.third_denomination,
                    '''',
                    ''''''
                   ) AS third_denomination,
                REPLACE
                     (redemption_struct.third_promo_code,
                      '''',
                      ''''''
                     ) AS third_promo_code
           FROM DUAL;

      p_error_number_out := NVL (p_error_number_out, n_error_num_local);
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         -- invalid X_DLL number and because of that we didn't call C program
         p_error_number_out := -500;

--06/13/06
         IF p_inquiry_rs_out%ISOPEN
         THEN
            CLOSE p_inquiry_rs_out;
         END IF;

         IF p_redemption_rs_out%ISOPEN
         THEN
            CLOSE p_redemption_rs_out;
         END IF;

--06/13/06
         ota_util_pkg.err_log
            (p_action            => 'Parsing OTA acknowledgment message',
             p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment',
             p_key               => p_min_in,
             p_error_text        =>    p_error_number_out
                                    || ' Invalid value for p_x_dll_out found. Value: '
                                    || p_x_dll_out
                                    || '. Expected: '
                                    || dll_list
            );
      WHEN terminate_procedure
      THEN
         -- just exit the procedure gracefuly
         p_error_number_out := NVL (p_error_number_out, n_error_num_local);

--06/13/06
         IF p_inquiry_rs_out%ISOPEN
         THEN
            CLOSE p_inquiry_rs_out;
         END IF;

         IF p_redemption_rs_out%ISOPEN
         THEN
            CLOSE p_redemption_rs_out;
         END IF;

--06/13/06
         ota_util_pkg.err_log
            (p_action            => 'Parsing OTA acknowledgment message',
             p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment',
             p_key               => p_min_in,
             p_error_text        =>    n_error_num_local
                                    || ' No matching data found in database for given MIN '
                                    || p_min_in
                                    || '. Stored procedure terminated.'
            );
      WHEN OTHERS
      THEN
         -- unexpected error
         p_error_number_out := -600;

--06/13/06
         IF p_inquiry_rs_out%ISOPEN
         THEN
            CLOSE p_inquiry_rs_out;
         END IF;

         IF p_redemption_rs_out%ISOPEN
         THEN
            CLOSE p_redemption_rs_out;
         END IF;

--06/13/06
         ota_util_pkg.err_log
                    (p_action            => 'Parsing OTA acknowledgment message',
                     p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment',
                     p_key               => p_min_in,
                     p_error_text        => p_error_number_out || ' '
                                            || SQLERRM
                    );
   END parse_acknowledgment;

   -- Inactive procedure - needs to be used once when we upgrade Web Logic server to the higher version
   PROCEDURE parse_acknowledgment_obj (
      p_message_in           IN       VARCHAR2,
      p_min_in               IN       VARCHAR2,
      p_technology_in        IN       NUMBER DEFAULT 3,
      p_esn_out              OUT      VARCHAR2,
      p_sequence_out         OUT      NUMBER,
      p_transid_out          OUT      NUMBER,
      p_ack_code_out         OUT      NUMBER,
      p_inquiry_obj_out      OUT      pl_inquirack_array,
      p_redemption_obj_out   OUT      pl_redemption_structure,
      p_error_number_out     OUT      NUMBER,
      p_x_dll_out            OUT      NUMBER,
      p_brand_name           OUT      VARCHAR2
   )
   IS
      n_error_num               NUMBER;
      n_error_code              NUMBER;
      ins                       pltosl;
      outs                      sltopl;
      inquiry_array             pl_inquirack_array;
      inquiry_cur               ota_extproc_pkg.ref_cur_type;
      dummy_esn        CONSTANT VARCHAR2 (15)            := '111111111111111';
      -- 15 digits number for technology GSM
      dummy_sequence   CONSTANT NUMBER                       := 0;

-- BRAND_SEP use table_bus_org

      CURSOR esn_cur (p_min IN VARCHAR2)
      IS
         SELECT tpiesn.part_serial_no esn, tpiesn.x_sequence, tpn.x_dll,
                tpiesn.part_inst2carrier_mkt, tpn.objid,
                bo.ORG_ID
           FROM table_mod_level tml,
                table_part_num tpn,
                table_x_code_table txct1,
                table_x_code_table txct2,
                table_part_inst tpimin,
                table_part_inst tpiesn,
                table_bus_org bo
          WHERE tpn.objid = tml.part_info2part_num
            AND tml.objid = tpiesn.n_part_inst2part_mod
            AND tpiesn.objid = tpimin.part_to_esn2part_inst
            AND tpimin.x_part_inst_status = txct1.x_code_number
            AND tpiesn.x_part_inst_status = txct2.x_code_number
            AND tpiesn.x_domain = 'PHONES'
            AND tpimin.x_domain = 'LINES'
            AND txct1.x_code_name = 'ACTIVE'
            AND txct2.x_code_name = 'ACTIVE'
            AND tpimin.part_serial_no = p_min
            AND bo.objid = tpn.PART_NUM2BUS_ORG;

      esn_rec                   esn_cur%ROWTYPE;

      PROCEDURE get_esn (p_min_in IN VARCHAR2)
      IS
      BEGIN
         OPEN esn_cur (p_min_in);

         FETCH esn_cur
          INTO esn_rec;

         IF esn_cur%NOTFOUND
         THEN
            esn_rec.esn := dummy_esn;
            esn_rec.x_sequence := dummy_sequence;
         END IF;

         CLOSE esn_cur;
      END get_esn;
   BEGIN
      -- initialization (need constructor member function called "initialize" for this)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      outs.inquiryack_struct :=
         pl_inquirack_array (pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     ),
                             pl_inquiryack_structure (' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' ',
                                                      ' '
                                                     )
                            );
      outs.redemption_struct :=
         pl_redemption_structure (' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
      -- get esn info:
      get_esn (p_min_in);
      --populate input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (esn_rec.esn);
      ins.ack_struct := pl_ack_structure (p_message_in);
      ins.tech_struct := pl_technology_structure (p_technology_in);
      ins.seq_struct := pl_sequence_structure (esn_rec.x_sequence);
      -- execute DLL:
      call_dll (esn_rec.x_dll, ins, outs, n_error_num);
      -- return 7 out parameters:
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);
      p_transid_out := outs.transid_struct.transid;
      p_ack_code_out := outs.ackreturn_struct.first_string;
      p_esn_out := esn_rec.esn;
      p_sequence_out := esn_rec.x_sequence;
      p_x_dll_out := esn_rec.x_dll;

      -- BRAND_SEP

      p_brand_name := esn_rec.org_id;
      -- execute DLL:
      call_dll (p_x_dll_out, ins, outs, n_error_num);
      -- populate output parameters:
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);
      -- In this procedure we will pass a varray directly to the calling java class:
      p_inquiry_obj_out := outs.inquiryack_struct;
      p_redemption_obj_out := outs.redemption_struct;
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
            (p_action            => 'Parsing OTA acknowledgment message',
             p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment_obj',
             p_error_text        =>    'Invalid value for p_x_dll_out found. Value: '
                                    || p_x_dll_out
                                    || '. Expected: '
                                    || dll_list
            );
         raise_application_error
                            (-20001,
                                'Procedure failed with error: '
                             || 'Invalid value for p_x_dll_out found. Value: '
                             || p_x_dll_out
                             || '.Expected: '
                             || dll_list
                            );
      WHEN OTHERS
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
               (p_action            => 'Parsing OTA acknowledgment message',
                p_program_name      => 'OTA_EXTPROC_PKG.parse_acknowledgment_obj',
                p_error_text        => SQLERRM
               );
         raise_application_error (-20001,
                                  'Procedure failed with error: ' || SQLERRM
                                 );
   END parse_acknowledgment_obj;

   /***** Command stuff *****/
   PROCEDURE send_command (
      p_esn_in                  IN       VARCHAR2,
      p_sequence_in             IN       NUMBER,
      p_technology_in           IN       NUMBER DEFAULT 3,
      p_transid_in              IN       NUMBER,
      p_command_struct_sql_in   IN       VARCHAR2,
      p_string_value_in         IN       NUMBER,
      p_int_dll_to_use          IN       NUMBER,
      p_error_number_out        OUT      NUMBER,
      p_cmdcode_rs_out          OUT      ota_extproc_pkg.ref_cur_type,
      p_message_out             OUT      VARCHAR2
   )
   IS
      ins           pltosl;
      outs          sltopl;
      command_cur   ota_extproc_pkg.ref_cur_type;
      command_rec   ota_extproc_pkg.command_rec_type;
      n_error_num   NUMBER;
   BEGIN
      -- initialize objects
      -- (it is better to have constructor member function called "initialize" for this thing)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      -- populate ins object with the values of input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (p_esn_in);
      ins.seq_struct := pl_sequence_structure (p_sequence_in);
      ins.tech_struct := pl_technology_structure (p_technology_in);
      ins.transid_struct := pl_transid_structure (p_transid_in);
      -- initialize varray with 0 elements
      ins.commandmsg_struct := pl_command_struct_array ();

      OPEN command_cur FOR p_command_struct_sql_in;

      LOOP
         FETCH command_cur
          INTO command_rec;

         EXIT WHEN command_cur%NOTFOUND;
         ins.commandmsg_struct.EXTEND;
         ins.commandmsg_struct (command_cur%ROWCOUNT) :=
            pl_command_structure (command_rec.command,
                                  command_rec.first_double,
                                  command_rec.second_double,
                                  command_rec.third_double,
                                  command_rec.fourth_double,
                                  command_rec.fifth_double,
                                  command_rec.sixth_double,
                                  command_rec.serventh_double,
                                  command_rec.eight_double,
                                  command_rec.ninth_double,
                                  command_rec.tenth_double,
                                  command_rec.first_string,
                                  command_rec.second_string,
                                  command_rec.third_string,
                                  command_rec.fourth_string,
                                  command_rec.fifth_string,
                                  command_rec.sixth_string,
                                  command_rec.seventh_string,
                                  command_rec.eighth_string,
                                  command_rec.ninth_string,
                                  command_rec.tenth_string
                                 );
      END LOOP;

      CLOSE command_cur;

      outs.psmscode_struct := pl_psms_code_structure (' ');
      outs.cmdcode_struct :=
         pl_comcode_array (pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' ')
                          );
      -- execute DLL:
      call_dll (p_int_dll_to_use, ins, outs, n_error_num);
      -- populate OUT parameters
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);

      OPEN p_cmdcode_rs_out FOR
         SELECT *
           FROM TABLE (CAST (outs.cmdcode_struct AS pl_comcode_array));

      p_message_out := outs.psmscode_struct.psms_code;
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
            (p_action            => 'Sending PSMS command message',
             p_program_name      => 'OTA_EXTPROC_PKG.send_command_psms',
             p_error_text        =>    'Invalid value of p_int_dll_to_use passed to the procedure. Value: '
                                    || p_int_dll_to_use
                                    || '. Expected: '
                                    || dll_list
            );

--06/13/06
         IF command_cur%ISOPEN
         THEN
            CLOSE command_cur;
         END IF;

         IF p_cmdcode_rs_out%ISOPEN
         THEN
            CLOSE p_cmdcode_rs_out;
         END IF;

--06/13/06
         raise_application_error
            (-20001,
                'Procedure failed with error: '
             || 'Invalid value of int_dll_to_use passed to the procedure. Value: '
             || p_int_dll_to_use
             || '. Expected: '
             || dll_list
            );
      WHEN OTHERS
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
                   (p_action            => 'Sending redemption PSMS message',
                    p_program_name      => 'OTA_EXTPROC_PKG.send_redemption_psms',
                    p_error_text        => SQLERRM
                   );

--06/13/06
         IF command_cur%ISOPEN
         THEN
            CLOSE command_cur;
         END IF;

         IF p_cmdcode_rs_out%ISOPEN
         THEN
            CLOSE p_cmdcode_rs_out;
         END IF;

--06/13/06
         raise_application_error (-20002,
                                  'Procedure failed with error: ' || SQLERRM
                                 );
   END send_command;

   PROCEDURE send_command_obj (
      p_esn_in             IN       VARCHAR2,
      p_sequence_in        IN       NUMBER,
      p_technology_in      IN       NUMBER DEFAULT 3,
      p_transid_in         IN       NUMBER,
      p_command_obj_in     IN       pl_command_struct_array,
      p_string_value_in    IN       NUMBER,
      p_int_dll_to_use     IN       NUMBER,
      p_error_number_out   OUT      NUMBER,
      p_cmdcode_obj_out    OUT      pl_comcode_array,
      p_psmscode_obj_out   OUT      pl_psms_code_structure
   )
   IS
      ins           pltosl;
      outs          sltopl;
      n_error_num   NUMBER;
   BEGIN
      -- initialize objects
      -- (it is better to have constructor member function called "initialize" for this thing)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      -- populate ins object with the values of input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (p_esn_in);
      ins.tech_struct := pl_technology_structure (p_technology_in);
      ins.seq_struct := pl_sequence_structure (p_sequence_in);
      ins.transid_struct := pl_transid_structure (0);
      ins.commandmsg_struct := p_command_obj_in;
      -- initialize out parameters
      outs.psmscode_struct := pl_psms_code_structure (' ');
      outs.cmdcode_struct :=
         pl_comcode_array (pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' '),
                           pl_gencode_structure (0, ' ')
                          );
      -- execute DLL:
      call_dll (p_int_dll_to_use, ins, outs, n_error_num);
      -- populate OUT parameters
      p_error_number_out :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);
      p_cmdcode_obj_out := outs.cmdcode_struct;
      p_psmscode_obj_out := outs.psmscode_struct;
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
            (p_action            => 'Sending PSMS command message',
             p_program_name      => 'OTA_EXTPROC_PKG.send_command_psms_obj',
             p_error_text        =>    'Invalid value of p_int_dll_to_use passed to the procedure. Value: '
                                    || p_int_dll_to_use
                                    || '. Expected: '
                                    || dll_list
            );
         raise_application_error
            (-20001,
                'Procedure failed with error: '
             || 'Invalid value of int_dll_to_use passed to the procedure. Value: '
             || p_int_dll_to_use
             || '. Expected: '
             || dll_list
            );
      WHEN OTHERS
      THEN
         p_error_number_out := 1;
         ota_util_pkg.err_log
                  (p_action            => 'Sending PSMS command message',
                   p_program_name      => 'OTA_EXTPROC_PKG.send_command_psms_obj',
                   p_error_text        => SQLERRM
                  );
         raise_application_error (-20002,
                                  'Procedure failed with error: ' || SQLERRM
                                 );
   END send_command_obj;

   FUNCTION get_last_sent_ack_func (
      p_esn_in           IN   VARCHAR2,
      p_technology_in    IN   NUMBER DEFAULT 3,
      p_sequence_in      IN   NUMBER,
      p_send_last_in     IN   VARCHAR2 DEFAULT 'Y',
      p_int_dll_to_use   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      ins              pltosl;
      outs             sltopl;
      n_error_num      NUMBER;
      c_return_value   VARCHAR2 (255);
   BEGIN
      -- initialize objects
      -- (it is better to have constructor member function called "initialize" for this thing)
      ins :=
         pltosl (NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL
                );
      outs := sltopl (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
      -- populate ins object with the values of input parameters:
      ins.esn_imei_struct := pl_esn_imei_structure (p_esn_in);
      ins.seq_struct := pl_sequence_structure (p_sequence_in);
      ins.tech_struct := pl_technology_structure (p_technology_in);
      ins.sendlast_struct := pl_sendlastack_structure (p_send_last_in);
      ins.transid_struct := pl_transid_structure (0);
      -- initialize out structure:
      outs.psmscode_struct := pl_psms_code_structure (' ');
      -- execute DLL:
      call_dll (p_int_dll_to_use, ins, outs, n_error_num);
      -- populate OUT parameters
      n_error_num :=
          process_error_number (n_error_num, outs.errorcode_struct.ERROR_CODE);
      c_return_value := outs.psmscode_struct.psms_code;

      IF n_error_num = 0
      THEN
         RETURN c_return_value;
      ELSE
         RETURN 'ERROR ' || n_error_num;
      END IF;
   EXCEPTION
      WHEN e_invalid_int_dll_to_use
      THEN
         n_error_num := -100;
         ota_util_pkg.err_log
            (p_action            => 'Getting the last sent acknowledgment from the phone',
             p_program_name      => 'OTA_EXTPROC_PKG.get_last_sent_ack_func',
             p_error_text        =>    'Invalid value of p_int_dll_to_use passed to the procedure. Value: '
                                    || p_int_dll_to_use
                                    || '. Expected: '
                                    || dll_list
            );
         RETURN 'ERROR ' || n_error_num;
      WHEN OTHERS
      THEN
         n_error_num := -101;
         ota_util_pkg.err_log
            (p_action            => 'Getting the last sent acknowledgment from the phone',
             p_program_name      => 'OTA_EXTPROC_PKG.get_last_sent_ack_func',
             p_error_text        => SQLERRM
            );
         RETURN 'ERROR ' || n_error_num;
   END get_last_sent_ack_func;
END;
                                                           -- package body
/