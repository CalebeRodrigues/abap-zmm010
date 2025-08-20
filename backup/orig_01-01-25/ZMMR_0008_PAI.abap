*-----------------------------------------------------------------------
* Include: ZMMR_0008_PAI
*-----------------------------------------------------------------------


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_exit INPUT.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F15' OR '&F12'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  "

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  CASE sy-ucomm.
    WHEN 'BT_OK'.
      PERFORM zf_validar_ov_input USING vg_matnr
                                        vg_erro.

      CHECK vg_erro IS INITIAL.
      LEAVE TO SCREEN 0.

    WHEN 'BT_NO'.
      CLEAR: vbap-posnr,
             vbap-vbeln.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  CASE sy-ucomm.
    WHEN 'BT_OK'.
      PERFORM zf_validar_dep_input USING vg_matnr
                                         vg_erro.

      CHECK vg_erro IS INITIAL.
      LEAVE TO SCREEN 0.

    WHEN 'BT_NO'.
      CLEAR: mard-lgort.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*