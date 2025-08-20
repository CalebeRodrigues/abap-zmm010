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
*MODULE user_command_9000 INPUT.

*  "

*

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

*-----------------------------------------------------------------------
* PAI 9000 - Executa M2M em massa a partir do ALV
* Calebe Rodrigues - TI SR Embalagens (19/08/2025
*-----------------------------------------------------------------------
MODULE user_command_9000 INPUT.                                        " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  DATA lv_lines TYPE i.                                                " Calebe Rodrigues - TI SR Embalagens (19/08/2025

  CASE sy-ucomm.                                                       " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    WHEN 'CSVU'.  " Upload CSV   " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      IF rb_ma2ma = abap_true.
        PERFORM upload_csv_transf.                                    " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      ENDIF.

    WHEN 'CSVV'.  " Validar buffer " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      IF rb_ma2ma = abap_true.
        PERFORM validate_buffer_transf.                               " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      ENDIF.

    WHEN 'CSVT'.  " Baixar template " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      IF rb_ma2ma = abap_true.
        PERFORM download_csv_template.                                " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      ENDIF.
    WHEN 'EXEC' OR 'ONLI'.  "use o FCODE real do seu botão Executar    " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      IF rb_ma2ma = abap_true.                                         " Calebe Rodrigues - TI SR Embalagens (19/08/2025

        IF g_grid IS BOUND.                                            " Calebe Rodrigues - TI SR Embalagens (19/08/2025
          CALL METHOD g_grid->check_changed_data.                      " salva edições do ALV  Calebe Rodrigues - TI SR Embalagens (19/08/2025
        ENDIF.                                                         " Calebe Rodrigues - TI SR Embalagens (19/08/2025

        " Remove linhas totalmente em branco                           " Calebe Rodrigues - TI SR Embalagens (19/08/2025
        DELETE gt_transf WHERE mat_orig IS INITIAL
                           AND mat_dest IS INITIAL
                           AND werks    IS INITIAL
                           AND lgort    IS INITIAL
                           AND charg    IS INITIAL
                           AND menge    IS INITIAL
                           AND meins    IS INITIAL
                           AND sobkz    IS INITIAL
                           AND vbeln    IS INITIAL
                           AND posnr    IS INITIAL.                    " Calebe Rodrigues - TI SR Embalagens (19/08/2025

        DESCRIBE TABLE gt_transf LINES lv_lines.                       " Calebe Rodrigues - TI SR Embalagens (19/08/2025
        IF lv_lines = 0.                                               " Calebe Rodrigues - TI SR Embalagens (19/08/2025
          PERFORM add_text_msg USING gc_message_type-e                 " Calebe Rodrigues - TI SR Embalagens (19/08/2025
                                     'Nenhuma linha para processar.'.  " Calebe Rodrigues - TI SR Embalagens (19/08/2025
        ELSE.                                                          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
          PERFORM post_mass.                                           " chama BAPI em loop     Calebe Rodrigues - TI SR Embalagens (19/08/2025
          IF g_grid IS BOUND.                                          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
            CALL METHOD g_grid->refresh_table_display.                 " opcional: atualizar    Calebe Rodrigues - TI SR Embalagens (19/08/2025
          ENDIF.                                                       " Calebe Rodrigues - TI SR Embalagens (19/08/2025
        ENDIF.                                                         " Calebe Rodrigues - TI SR Embalagens (19/08/2025

      ELSE.
        " Aqui segue o seu fluxo atual para os demais tipos            " Calebe Rodrigues - TI SR Embalagens (19/08/2025
        " PERFORM zf_user_command.  " (se existir)                     " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      ENDIF.

    WHEN 'BACK' OR 'CANC' OR 'EXIT'.                                   " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      LEAVE PROGRAM.                                                   " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  ENDCASE.                                                             " Calebe Rodrigues - TI SR Embalagens (19/08/2025

  CLEAR sy-ucomm.                                                      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
ENDMODULE.                                                             " Calebe Rodrigues - TI SR Embalagens (19/08/2025