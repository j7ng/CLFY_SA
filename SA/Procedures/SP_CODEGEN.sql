CREATE OR REPLACE PROCEDURE sa.SP_CODEGEN
/*************************************************************************************/
/* NAME     :       Sp_Codegen
/* PURPOSE  :       Procedure to generate Tracfone Codes
/*
/* REVISION  DATE        WHO             PURPOSE
/* --------  ---------- --------------   ---------------------------------------------
/* 1.0                                   Initial Release
/* 1.5       04/08/2005 Gerald Pintado   Added create or replace function call (EncodeMotC343Unix) for
/*                                       the new C343 handset.
/* 1.6       09/16/05   Natalio Guada    CR4336 - Added create or replace function call (EncodeNokia2126Unix) for the new Nokia 2126 handset
/* 1.7       02/06/06   Vani Adapa      CR4977, CR4978, CR4979 - New calls for the new models (1112,C139,1600)
/* 1.8       02/14/06   Hernan Mendez    New calls for the new models (C261, V176)
/* 1.8       03/10/06   Vani Adapa      Commented the calls for data phonr models (C261, V176)
/* 1.9/1.10  04/10/06   Vani Adapa      Removed the comments the calls for data phonr models (C261, V176)
/* 1.11       08/01/06 Hernan Mendez     CR5484 New call for LG3280, DLL#=26
/* 1.12       01/15/07 Hernan Mendez     New call for LG1500 -> DLL#=25 and W370 -> DLL#=27
/* 1.13       05/10/07 Ingrid Canavan     New call for LG200C -> DLL#=28 and KYOK126C  -> DLL#=29
/* 1.14       12/03/07 Hernan mendez     New call for LG400C - DLL#=30 and Motorola W175 -> DLL#=32
/* 1.15       02/13/08 Hernan mendez     New call for LG600C - DLL#=31
/* 1.16       11/18/08 Hernan mendez     New call for Samsung T301G - DLL#=37
/* 1.16       01/08/09 Hernan mendez     New call for Samsung T301G - DLL#=38
/* 1.17       01/20/09 Hernan mendez     New call for Samsung T301G - DLL#=40
/* 1.18       06/09/09 Hernan Mendez    New call for LG 100C/220C/290C - DLL#=41
/* 1.19       07/06/09 Hernan Mendez    New call for Samsung R451C - DLL#=42
/* 1.20       07/30/09 Hernan Mendez    New call for Samsung T401G - DLL#=43
/* 1.21       11/16/09 Hernan Mendez    New call for Samsung T105G/T155G - DLL#=44
/* 1.22       11/16/09 Hernan Mendez    New call for Samsung R355C - DLL#=45
/* 1.23       12/09/09 Hernan Mendez    New call for LG 320G - DLL#=46 - change procedute paramater to DOUBLE PRECISION to match functions definition
/* 1.7       02/17/2010                   CR12569
/* 1.8      08/18/10   Jimmy Angarita   CR13375   */
/* 1.9       9/10/10 Hernan Mendez    New call for LG 900G - DLL#49; LG 231C - DLL#50; Samsung T255G - DLL#=53
/*1.4        10/08/2010     NGuada  CR13085                    *
/*************************************************************************************/
(
   command_flag       IN       VARCHAR2,
   roam_flag          IN       VARCHAR2,
   rhours             IN       VARCHAR2,
   counter            IN       VARCHAR2,
   odacc              IN       VARCHAR2,
   debsn              IN       VARCHAR2,
   gommand            IN       VARCHAR2,
   intdlltouse        IN       VARCHAR2,
   esn                IN       VARCHAR2,
   SEQUENCE           IN       DOUBLE PRECISION,
   phone_technology   IN       DOUBLE PRECISION,
   dllcode            IN       DOUBLE PRECISION,
   data1              IN       DOUBLE PRECISION,
   data2              IN       DOUBLE PRECISION,
   data3              IN       DOUBLE PRECISION,
   data4              IN       DOUBLE PRECISION,
   data5              IN       DOUBLE PRECISION,
   data6              IN       DOUBLE PRECISION,
   data7              IN       DOUBLE PRECISION,
   data8              IN       DOUBLE PRECISION,
   data9              IN       VARCHAR2,
   data10             IN       DOUBLE PRECISION,
   data11             IN       VARCHAR2,
   gcode_return       OUT      VARCHAR2,
   error_num          OUT      NUMBER
)
AS
   v_iccid   VARCHAR2 (30) := '0';                          -- Dummy variable
BEGIN
   error_num := 0;

   IF intdlltouse = '1'
   THEN
      gcode_return :=
         Gencode30aunix (command_flag,
                         roam_flag,
                         rhours,
                         counter,
                         odacc,
                         debsn,
                         NVL (gommand, '          ')
                        );
   ELSIF intdlltouse = '2'
   THEN
      gcode_return :=
         Gencodemunix (command_flag,
                       roam_flag,
                       rhours,
                       counter,
                       odacc,
                       debsn,
                       NVL (gommand, '          ')
                      );
   ELSIF intdlltouse = '3'
   THEN
      gcode_return :=
         Gencodenunix (command_flag,
                       roam_flag,
                       rhours,
                       counter,
                       odacc,
                       debsn,
                       NVL (gommand, '          ')
                      );
   ELSIF intdlltouse = '4'
   THEN
      gcode_return :=
         Gencoden2unix (command_flag,
                        roam_flag,
                        rhours,
                        counter,
                        odacc,
                        debsn,
                        NVL (gommand, '          ')
                       );
   ELSIF intdlltouse = '5'
   THEN
      gcode_return :=
         Gencoden8unix (command_flag,
                        roam_flag,
                        rhours,
                        counter,
                        odacc,
                        debsn,
                        NVL (gommand, '          ')
                       );
   ELSIF intdlltouse = '6'
   THEN
      gcode_return :=
         Gencode5165unix (command_flag,
                          roam_flag,
                          rhours,
                          counter,
                          odacc,
                          debsn,
                          NVL (gommand, '          ')
                         );
   ELSIF intdlltouse = '7'
   THEN
      gcode_return :=
         Gencode5180iunix (command_flag,
                           roam_flag,
                           rhours,
                           counter,
                           odacc,
                           debsn,
                           NVL (gommand, '          ')
                          );
   ELSIF intdlltouse = '8'
   THEN
      gcode_return :=
         Gencode5125unix (command_flag,
                          roam_flag,
                          rhours,
                          counter,
                          odacc,
                          debsn,
                          NVL (gommand, '          ')
                         );
   ELSIF intdlltouse = '10'
   THEN
      error_num :=
         Encodemot120unix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
   ELSIF intdlltouse = '11'
   THEN
      error_num :=
         Encodenokia3390unix (esn,
                              SEQUENCE,
                              phone_technology,
                              dllcode,
                              data1,
                              data2,
                              data3,
                              data4,
                              data5,
                              data6,
                              data7,
                              data8,
                              data9,
                              data10,
                              data11,
                              gcode_return
                             );
   ELSIF intdlltouse = '12'
   THEN
      error_num :=
         Encodenokia1221unix (esn,
                              SEQUENCE,
                              phone_technology,
                              dllcode,
                              data1,
                              data2,
                              data3,
                              data4,
                              data5,
                              data6,
                              data7,
                              data8,
                              data9,
                              data10,
                              data11,
                              gcode_return
                             );
   ELSIF intdlltouse = '13'
   THEN
      error_num :=
         Encodenokia2285unix (esn,
                              SEQUENCE,
                              phone_technology,
                              dllcode,
                              data1,
                              data2,
                              data3,
                              data4,
                              data5,
                              data6,
                              data7,
                              data8,
                              data9,
                              data10,
                              data11,
                              gcode_return
                             );
   ELSIF intdlltouse = '14'
   THEN
      error_num :=
         Encodenokia1100unix (esn,
                              SEQUENCE,
                              phone_technology,
                              dllcode,
                              data1,
                              data2,
                              data3,
                              data4,
                              data5,
                              data6,
                              data7,
                              data8,
                              data9,
                              data10,
                              data11,
                              gcode_return
                             );
   ELSIF intdlltouse = '15'
   THEN
      error_num :=
         Encodemotc155unix (esn,
                            v_iccid,
                            SEQUENCE,
                            phone_technology,
                            dllcode,
                            data1,
                            data2,
                            data3,
                            data4,
                            data5,
                            data6,
                            data7,
                            data8,
                            data9,
                            data10,
                            data11,
                            gcode_return
                           );
   ELSIF intdlltouse = '16'
   THEN
      error_num :=
         Encodemotv170unix (esn,
                            v_iccid,
                            SEQUENCE,
                            phone_technology,
                            dllcode,
                            data1,
                            data2,
                            data3,
                            data4,
                            data5,
                            data6,
                            data7,
                            data8,
                            data9,
                            data10,
                            data11,
                            gcode_return
                           );
   ELSIF intdlltouse = '17'
   THEN
      error_num :=
         Encodemotc343unix (esn,
                            v_iccid,
                            SEQUENCE,
                            phone_technology,
                            dllcode,
                            data1,
                            data2,
                            data3,
                            data4,
                            data5,
                            data6,
                            data7,
                            data8,
                            data9,
                            data10,
                            data11,
                            gcode_return
                           );
   ELSIF intdlltouse = '18'
   THEN
      error_num :=
         Encodenokia2126unix (esn,
                              SEQUENCE,
                              phone_technology,
                              dllcode,
                              data1,
                              data2,
                              data3,
                              data4,
                              data5,
                              data6,
                              data7,
                              data8,
                              data9,
                              data10,
                              data11,
                              gcode_return
                             );
   ELSIF intdlltouse = '19'
   THEN
      error_num :=
         Encodenokia1112unix (esn,
                              SEQUENCE,
                              phone_technology,
                              dllcode,
                              data1,
                              data2,
                              data3,
                              data4,
                              data5,
                              data6,
                              data7,
                              data8,
                              data9,
                              data10,
                              data11,
                              gcode_return
                             );
   ELSIF intdlltouse = '20'
   THEN
      error_num :=
         Encodemotc139unix (esn,
                            SEQUENCE,
                            phone_technology,
                            dllcode,
                            data1,
                            data2,
                            data3,
                            data4,
                            data5,
                            data6,
                            data7,
                            data8,
                            data9,
                            data10,
                            data11,
                            gcode_return
                           );
   ELSIF intdlltouse = '21'
   THEN
      error_num :=
         Encodenokia1600unix (esn,
                              SEQUENCE,
                              phone_technology,
                              dllcode,
                              data1,
                              data2,
                              data3,
                              data4,
                              data5,
                              data6,
                              data7,
                              data8,
                              data9,
                              data10,
                              data11,
                              gcode_return
                             );
   ELSIF intdlltouse = '22'
   THEN
      error_num :=
         Encodemotc261unix (esn,
                            SEQUENCE,
                            phone_technology,
                            dllcode,
                            data1,
                            data2,
                            data3,
                            data4,
                            data5,
                            data6,
                            data7,
                            data8,
                            data9,
                            data10,
                            data11,
                            gcode_return
                           );
   ELSIF intdlltouse = '23'
   THEN
      error_num :=
         Encodemotv176unix (esn,
                            SEQUENCE,
                            phone_technology,
                            dllcode,
                            data1,
                            data2,
                            data3,
                            data4,
                            data5,
                            data6,
                            data7,
                            data8,
                            data9,
                            data10,
                            data11,
                            gcode_return
                           );
   ELSIF intdlltouse = '25'
   THEN
      error_num :=
         Encodelg1500unix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
	 ELSIF intdlltouse = '26'
   THEN
      error_num :=
         Encodelg3280unix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
   ELSIF intdlltouse = '27'
   THEN
      error_num :=
         Encodemotow370Unix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
   ELSIF intdlltouse = '28'
   THEN
      error_num :=
         Encodelg200cunix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
   ELSIF intdlltouse = '29'
   THEN
      error_num :=
         Encodekyocerak126cunix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
   ELSIF intdlltouse = '30'
   THEN
      error_num :=
         Encodelg400gunix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
   ELSIF intdlltouse = '31'
   THEN
      error_num :=
         EncodeLG600Cunix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
   ELSIF intdlltouse = '32'
   THEN
      error_num :=
         Encodemotow175unix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
   ELSIF intdlltouse = '37'
   THEN
      error_num :=
         EncodeSamT301GUnix (esn,
                            v_iccid,
                            SEQUENCE,
                            phone_technology,
                            dllcode,
                            data1,
                            data2,
                            data3,
                            data4,
                            data5,
                            data6,
                            data7,
                            data8,
                            data9,
                            data10,
                            data11,
                            gcode_return
                           );
   ELSIF intdlltouse = '38'
   THEN
      error_num :=
         EncodeMotoEM326Gunix (esn,
                           V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '40'
   THEN
      error_num :=
         EncodeLG410GUnix (esn,
                           V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '41'
   THEN
      error_num :=
         EncodeLG290CUnix (esn,
                           V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '42'
   THEN
      error_num :=
         EncodeSamR451CUnix (esn,
                           V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '43'
   THEN
      error_num :=
         EncodeSamT401GUnix (esn,
                           V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '44'
   THEN
      error_num :=
         EncodeSamT105GUnix (esn,
                           V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '45'
   THEN
      error_num :=
         EncodeSamR355CUnix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '46'
   THEN
      error_num :=
         EncodeLg320GUnix (esn,
						   V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
  ELSIF intdlltouse = '47'         --CR13581
   THEN
      error_num :=
         EncodeMotoW408GUnix (esn,
						   V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '49'       ----------CR13085
   THEN
      error_num :=
         EncodeLg900GUnix (esn,
						   V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '50'
   THEN
      error_num :=
         EncodeLg231CUnix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '52'
   THEN
      error_num :=
         EncodeSamR335CUnix (esn,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );
 ELSIF intdlltouse = '53'
   THEN
      error_num :=
         EncodeSamT255GUnix (esn,
						   V_ICCID,
                           SEQUENCE,
                           phone_technology,
                           dllcode,
                           data1,
                           data2,
                           data3,
                           data4,
                           data5,
                           data6,
                           data7,
                           data8,
                           data9,
                           data10,
                           data11,
                           gcode_return
                          );	   ------------CR13085
 END IF;
--EXCEPTION WHEN OTHERS THEN
--  error_num := 1;
END;
/