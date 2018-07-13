CREATE OR REPLACE PACKAGE sa.benefits_pkg
  IS
    /*===============================================================================================*/
    /*                                                                                               */
    /* Purpose: BENIFITS_PKG handles objects which give benifits for an ESN                          */
    /* REVISIONS  DATE          WHO            PURPOSE                                               */
    /* --------------------------------------------------------------------------------------------- */
    /*            05/10/2014    MVadlapally     Initial                                              */
    /*===============================================================================================*/

      /* To reserve a pin for an esn before activation  */
      PROCEDURE sp_preactive_reserve_pin (
          in_esn            IN     table_part_inst.part_serial_no%TYPE,
          in_pin_part_num   IN     table_part_inst.part_serial_no%TYPE,
          in_inv_bin_objid  IN     table_inv_bin.objid%TYPE,
          out_soft_pin      OUT    table_x_cc_red_inv.x_red_card_number%TYPE,
          out_smp_number    OUT    table_x_cc_red_inv.x_smp%TYPE,
          out_err_num       OUT    NUMBER,
          out_err_msg       OUT    VARCHAR2,
          in_consumer       IN     table_x_cc_red_inv.x_consumer%TYPE DEFAULT NULL); --CR54533
END;
/