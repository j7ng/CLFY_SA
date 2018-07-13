CREATE OR REPLACE PACKAGE sa.mformation_pkg AS

 --------------------------------------------------------------------------------------------
 --$RCSfile: mformation_pkg.sql,v $
  --$Revision: 1.8 $
  --$Author: vnainar $
  --$Date: 2015/08/24 21:53:19 $
  --$ $Log: mformation_pkg.sql,v $
  --$ Revision 1.8  2015/08/24 21:53:19  vnainar
  --$ CR30457
  --$
  --$ Revision 1.7  2015/03/25 15:40:29  jpena
  --$ CR30440
  --$
  --$ Revision 1.6  2015/03/16 20:02:09  jpena
  --$ mformation changes
  --$
  --$ Revision 1.60  2015/02/09 22:33:53  jpena
  --$ CR32596 - Mformation Changes
  --$
  --------------------------------------------------------------------------------------------

/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         mformation_pkg                                               */
/* PURPOSE:      Perform all mformation related actions                       */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 11g AND newer versions.                               */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION   DATE        WHO       PURPOSE                                    */
/* -------   ---------- ---------  -----------------------------------------  */
/*  1.0      02/16/2015 Juda Pena  Initial  Revision                          */
/******************************************************************************/
/******************************************************************************/

-- Added on 02/16/2015 by Juda Pena to determine the template and other information based on the provided min
PROCEDURE get_min_data ( i_min                   IN  VARCHAR2,
                         o_template              OUT VARCHAR2,
                         o_esn                   OUT VARCHAR2,
                         o_line_part_inst_status OUT VARCHAR2,
                         o_zip_code              OUT VARCHAR2,
                         o_phone_manufacturer    OUT VARCHAR2,
                         o_min_found_flag        OUT VARCHAR2,
                         o_rate_plan             OUT VARCHAR2,
                         o_bus_org_id            OUT VARCHAR2,
                         o_contact_objid         OUT NUMBER,
                         i_debug_flag            IN  BOOLEAN DEFAULT FALSE);

-- Added on 02/16/2015 by Juda Pena to create an ig transaction record for a request from w3ci (mformation)
PROCEDURE create_w3ci_apn_ig ( i_min                IN  VARCHAR2 ,  -- VARCHAR2(30)
                               i_rate_plan          IN  VARCHAR2 DEFAULT NULL,  -- OPTIONAL
                               i_carrier_name       IN  VARCHAR2 DEFAULT NULL,  -- OPTIONAL
                               o_err_code           OUT NUMBER   ,
                               o_err_msg            OUT VARCHAR2 ,
                               i_debug_flag         IN  BOOLEAN DEFAULT FALSE);

-- Added on 02/16/2015 by Juda Pena to create an ig transaction record
PROCEDURE create_ig_transaction ( i_ig_rec     IN  ig_transaction%ROWTYPE,
                                  o_err_code   OUT NUMBER   ,
                                  o_err_msg    OUT VARCHAR2 ,
                                  i_debug_flag IN  BOOLEAN DEFAULT FALSE);

-- Added on 02/16/2015 by Juda Pena to wrap the functionality to duplicate an ig transaction record for a request from w3ci (mformation) for CR30440
PROCEDURE clone_ig_trans_wrapper ( i_transaction_id IN NUMBER );

-- Added on 02/16/2015 by Juda Pena to duplicate an ig transaction record for a request from w3ci (mformation) for CR30440
PROCEDURE clone_ig_trans ( i_transaction_id IN  NUMBER   ,
                           o_err_code       OUT NUMBER   ,
                           o_err_msg        OUT VARCHAR2 ,
                           i_debug_flag     IN  BOOLEAN DEFAULT FALSE);

-- Added on 02/16/2015 by Juda Pena to wrap the functionality to duplicate an ig transaction record for a request from w3ci (mformation) for CR30440
PROCEDURE clone_port_ig_trans_wrapper ( i_esn IN VARCHAR2 );

-- Added on 02/16/2015 by Juda Pena to duplicate an ig transaction record for a request from w3ci (mformation) for CR30440
PROCEDURE clone_port_ig_trans ( i_esn            IN  VARCHAR2   ,
                                o_err_code       OUT NUMBER ,
                                o_err_msg        OUT VARCHAR2 ,
                                i_debug_flag     IN  BOOLEAN DEFAULT FALSE);

-- Added on 02/16/2015 by Juda Pena to log procedure calls and parameters on ERROR_TABLE
PROCEDURE log_error ( i_error_text   IN VARCHAR2,
                      i_error_date   IN DATE,
                      i_action       IN VARCHAR2,
                      i_key          IN VARCHAR2,
                      i_program_name IN VARCHAR2);
PROCEDURE create_w3ci_apn_ig_soa
(
i_min                IN  VARCHAR2 ,  -- VARCHAR2(30)
i_rate_plan          IN  VARCHAR2 DEFAULT NULL,  -- OPTIONAL
i_carrier_name       IN  VARCHAR2 DEFAULT NULL,  -- OPTIONAL
o_err_code           OUT NUMBER   ,
o_err_msg            OUT VARCHAR2);
END MFORMATION_PKG;
/