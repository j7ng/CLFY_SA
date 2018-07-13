CREATE OR REPLACE PACKAGE sa.UPGRADE_PROMO_PKG
IS
 --********************************************************************************
 --$RCSfile: UPGRADE_PROMO_PKG_PKS.sql,v $
 --$Revision: 1.4 $
 --$Author: mshah $
 --$Date: 2017/11/29 02:03:39 $
 --$ $Log: UPGRADE_PROMO_PKG_PKS.sql,v $
 --$ Revision 1.4  2017/11/29 02:03:39  mshah
 --$ CR53985 - Tracfone 3X benefit with Upgrade
 --$
 --$ Revision 1.3  2015/10/21 21:36:23  skota
 --$ for CR37795
 --$
 --$ Revision 1.2  2015/10/05 19:28:40  skota
 --$ change naming convetions
 --$
 --********************************************************************************
/* ***************************************************************************/
/* Copyright Tracfone Wireless Inc. All rights reserved                      */
/*                                                                           */
/* Name         :   UPGRADE_PROMO_PKG                                      */
/* Purpose      :   Initial development for giving promotions for TRACFONE                                                        */
/*                  Upgrade Promotion for 2G to 3G and returning the         */
/*                  promotion units/access days                              */
/*                                                                           */
/* Version  Date      Who      Purpose                                       */
/* -------  --------  -------  ----------------------------------------------*/
/* 1.0     08/14/2015 Srini Kota    Initial revision                         */
/* ***************************************************************************/



PROCEDURE SP_TF_UPGRADE_PROMO (
		 ip_from_esn           IN VARCHAR2,
		 ip_to_esn             IN VARCHAR2,
		 op_units		    OUT NUMBER,
		 op_days           OUT NUMBER,
		 op_error_code       OUT NUMBER,
		 op_error_msg        OUT VARCHAR2
	    );

PROCEDURE SP_NONPPE_PROMO_HIST (
		 ip_from_esn           IN VARCHAR2,
		 ip_to_esn             IN VARCHAR2,
		 op_error_code       OUT NUMBER,
		 op_error_msg        OUT VARCHAR2
		);

PROCEDURE INSERT_2GPROMO_HIST (
		IP_ESN 					 IN VARCHAR2,
		IP_PROMOHIST2X_PROMOTION IN NUMBER,
		op_error_code            OUT NUMBER,
		op_error_msg             OUT VARCHAR2
		);

PROCEDURE transfer_3x_promo
(
		 ip_from_esn           IN VARCHAR2,
		 ip_to_esn             IN VARCHAR2,
		 op_error_code         OUT NUMBER,
		 op_error_msg          OUT VARCHAR2
);

END UPGRADE_PROMO_PKG;
/