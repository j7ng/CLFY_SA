CREATE OR REPLACE PACKAGE sa.POSA_KMART_161_PKG AS
/*****************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved           */
/*                                                                           */
/* NAME:                                                                     */
/* PURPOSE:                                                                  */
/* FREQUENCY:    ad hoc                                                      */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                            */
/*                                                                           */
/* REVISIONS:                                                                */
/*   VERSION  DATE        WHO               PURPOSE                          */
/*  -------  ----------  ---------------   --------------------------------  */
/*     1.0   07/24/01    SL                Create an posa 161 bytes file for */
/*                                         Kmart                             */
/*                                                                           */
/*     1.1   09/17/01    SL                Phoenix Project                   */
/*                                         Reading data from posa_swp_loc_ac */
/*                                         t_card                            */
/*                                                                           */
/*                                         instead of topp_oci_redeem_interf */
/*     1.2   11/02/01    SL                Fix: cost/sell value in header do */
/*                                         es not                            */
/*                                         match total of cost/sell in       */
/*                                                                           */
/*     1.3   01/24/02    Miguel Leon       Changes table posa_swp_loc_act_car*/
/*                                         to x_posa_card                    */
/*****************************************************************************/
procedure create_161_file ( p_start_date date,
			                p_end_date date,
                            p_date_adjust number);
END POSA_KMART_161_PKG;
/