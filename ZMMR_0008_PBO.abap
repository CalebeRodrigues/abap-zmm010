*-----------------------------------------------------------------------
* Include: ZMMR_0008_PBO
*-----------------------------------------------------------------------


*-----------------------------------------------------------------------
* Module STATUS_9000 OUTPUT
*-----------------------------------------------------------------------
MODULE status_9000 OUTPUT.

  SET PF-STATUS 'STATUS_9000'.

  IF rb_lv2pe IS NOT INITIAL.
    SET TITLEBAR 'TITLE_9000'.
  ENDIF.

  IF rb_pe2lv IS NOT INITIAL.
    SET TITLEBAR 'TITLE_9000_PELV'.
  ENDIF.

  IF rb_pe2pe IS NOT INITIAL.
    SET TITLEBAR 'TITLE_9000_PEPE'.
  ENDIF.

*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
  IF NOT rb_dp2dp IS INITIAL.
    SET TITLEBAR 'TITLE_9000_DPDP'.
  ENDIF.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim

* Calebe Rodrigues - TI SR Embalagens (19/08/2025) - INÍCIO PATCH M2M
  PERFORM zf_seleciona_dados.  "mantém o comportamento atual

  IF rb_ma2ma = abap_true.
    " Quando for Material→Material, monta nosso ALV específico
    PERFORM alv_m2m_pbo.                         " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  ELSE.
    " Demais modalidades seguem no ALV padrão já existente
    PERFORM zf_monta_alv.                        " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  ENDIF.
* Calebe Rodrigues - TI SR Embalagens (19/08/2025) - FIM PATCH M2M

ENDMODULE.
*

*-----------------------------------------------------------------------
* PBO - cria ALV de entrada em massa M2M
* Calebe Rodrigues - TI SR Embalagens (19/08/2025
*-----------------------------------------------------------------------
FORM alv_m2m_pbo .
  DATA lv_txt TYPE c LENGTH 80.                             " Calebe Rodrigues - TI SR Embalagens (19/08/2025

  " Container docking no topo (simples)
  IF o_docking IS INITIAL.                                  " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    CREATE OBJECT o_docking
      EXPORTING
        side  = cl_gui_docking_container=>dock_at_top
        ratio = 95.
  ENDIF.

  IF g_grid IS INITIAL.                                     " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    CREATE OBJECT g_grid
      EXPORTING
        i_parent = o_docking.

    " Fieldcat e layout
    PERFORM build_fcat_transf.                              " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    CLEAR g_layout.
    g_layout-zebra      = 'X'.
    g_layout-cwidth_opt = 'X'.

    IF gt_transf IS INITIAL.
      APPEND INITIAL LINE TO gt_transf.
      lv_txt = TEXT-010.                                                         " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      MESSAGE lv_txt TYPE 'S' DISPLAY LIKE 'I'.                                  " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    ENDIF.

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = ''
        is_layout        = g_layout
      CHANGING
        it_outtab        = gt_transf
        it_fieldcatalog  = g_fieldcat.

*    -- Registra handlers do ALV (toolbar, user_command, hotspot)
    IF g_grid IS BOUND.                                                " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      IF event_receiver IS INITIAL.                                    " Calebe Rodrigues - TI SR Embalagens (19/08/2025
        CREATE OBJECT event_receiver.                                   " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      ENDIF.                                                            " Calebe Rodrigues - TI SR Embalagens (19/08/2025

      SET HANDLER event_receiver->handle_toolbar        FOR g_grid.     " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      SET HANDLER event_receiver->handle_user_command   FOR g_grid.     " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      SET HANDLER event_receiver->handle_hotspot_click  FOR g_grid.     " Calebe Rodrigues - TI SR Embalagens (19/08/2025

      CALL METHOD g_grid->set_toolbar_interactive.                      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    ENDIF.                                                              " Calebe Rodrigues - TI SR Embalagens (19/08/2025

    CALL METHOD g_grid->set_ready_for_input
      EXPORTING i_ready_for_input = 1.                      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  ENDIF.
ENDFORM.