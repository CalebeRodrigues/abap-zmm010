*-----------------------------------------------------------------------
* Include: ZMMR_0008_C01
*-----------------------------------------------------------------------



*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS:
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm
                    sender,

      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object
                    e_interactive,

      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id
                    e_column_id
                    es_row_no.


ENDCLASS.                    "lcl_event_receiver DEFINITION


*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_user_command.

    DATA: v_answer TYPE c.

    FREE: gt_rows, gt_ZMMS002_sel.

    g_grid->check_changed_data( ).

    CLEAR: vg_matnr.

    CALL METHOD g_grid->get_selected_rows
      IMPORTING
        et_index_rows = gt_rows.

    IF gt_rows[] IS INITIAL .
      MESSAGE 'Selecionar pelo menos uma linha!'
      TYPE 'I'.
      RETURN.
    ENDIF.

    READ TABLE gt_rows
    ASSIGNING FIELD-SYMBOL(<fs_rows>)
    INDEX 1.

    CASE e_ucomm.
      WHEN 'TR_SAL'.
        DATA(vl_erro) = abap_false.

        CALL METHOD g_grid->check_changed_data.

        LOOP AT gt_rows ASSIGNING FIELD-SYMBOL(<fsl_row>).
          READ TABLE gt_ZMMS002
          ASSIGNING FIELD-SYMBOL(<fsl_0026>)
          INDEX <fsl_row>-index.

          "Regra nao é valida para transferencia de PE para Livre
          IF  <fsl_0026>-vbeln_to IS INITIAL
          AND rb_pe2lv IS INITIAL.
*Comentado por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
*            MESSAGE 'Informar OV/Item em todas as linhas selecionadas!'
*            TYPE 'I'.
*            vl_erro = abap_true.
*            EXIT.
*Comentado por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
            IF rb_dp2dp IS INITIAL.
              MESSAGE 'Informar OV/Item em todas as linhas selecionadas!'
              TYPE 'I'.
              vl_erro = abap_true.
              EXIT.
            ENDIF.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim
          ENDIF.

          APPEND INITIAL LINE TO gt_ZMMS002_sel ASSIGNING FIELD-SYMBOL(<fsl_0026_sel>).
          <fsl_0026_sel> = <fsl_0026>.
        ENDLOOP.

        CHECK vl_erro IS INITIAL.

        PERFORM zf_gerar_mov.

        CLEAR e_ucomm.
        CALL METHOD g_grid->refresh_table_display( ).
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ENTER1'.

      WHEN 'ASS_OV'.
        READ TABLE gt_ZMMS002 ASSIGNING <fsl_0026> INDEX <fs_rows>-index.
        IF <fsl_0026> IS ASSIGNED.
          vg_matnr = <fsl_0026>-matnr.
        ENDIF.

        CALL SCREEN '9001' STARTING AT 5 5.

        LOOP AT gt_rows ASSIGNING <fsl_row>.
          READ TABLE gt_ZMMS002
          ASSIGNING <fsl_0026>
          INDEX <fsl_row>-index.
          <fsl_0026>-vbeln_to = vbap-vbeln.
          <fsl_0026>-posnr_to = vbap-posnr.
        ENDLOOP.

        CALL METHOD g_grid->refresh_table_display( ).

      WHEN 'ASS_DEP'.
        READ TABLE gt_ZMMS002 ASSIGNING <fsl_0026> INDEX <fs_rows>-index.
        IF <fsl_0026> IS ASSIGNED.
          vg_matnr = <fsl_0026>-matnr.
        ENDIF.

        mard-werks = p_werks.

        CALL SCREEN '9002' STARTING AT 5 5.

        LOOP AT gt_rows ASSIGNING <fsl_row>.
          READ TABLE gt_ZMMS002
          ASSIGNING <fsl_0026>
          INDEX <fsl_row>-index.
          <fsl_0026>-lgort_move = mard-lgort.
        ENDLOOP.

        CALL METHOD g_grid->refresh_table_display( ).

      WHEN '&F15' OR '&F12'.  "'END'.
*            SET SCREEN 0.
        LEAVE SCREEN.

      WHEN '&F03'.  "'BACK'.
*            SET SCREEN 0.
        LEAVE SCREEN.

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.                           "handle_user_command


  METHOD handle_toolbar.

    DATA ls_toolbar TYPE stb_button.

*   append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

*   append an icon to show booking table
*   Botão refresh
    IF rb_pe2lv IS INITIAL.
      READ TABLE e_object->mt_toolbar
      INTO ls_toolbar
      WITH KEY function = 'ASS_OV'.

      IF sy-subrc IS NOT INITIAL.
        CLEAR ls_toolbar.
        MOVE 'ASS_OV'           TO ls_toolbar-function.
        MOVE  icon_change_text  TO ls_toolbar-icon.          "table ICON
        MOVE 'Associar OV'(111) TO ls_toolbar-quickinfo.
        MOVE 'Associar OV'(112) TO ls_toolbar-text.
        MOVE ' '                TO ls_toolbar-disabled.
        APPEND ls_toolbar       TO e_object->mt_toolbar.
      ENDIF.
    ENDIF.

    READ TABLE e_object->mt_toolbar
    INTO ls_toolbar
    WITH KEY function = 'TR_SAL'.

    IF sy-subrc IS NOT INITIAL.
      CLEAR ls_toolbar.
      MOVE 'TR_SAL'                     TO ls_toolbar-function.
      MOVE  icon_fast_entry             TO ls_toolbar-icon.          "table ICON
      MOVE 'Tranferencia de Saldo'(111) TO ls_toolbar-quickinfo.
      MOVE 'Tranferencia de Saldo'(112) TO ls_toolbar-text.
      MOVE ' '                          TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

    READ TABLE e_object->mt_toolbar
    INTO ls_toolbar
    WITH KEY function = 'ASS_DEP'.

    IF sy-subrc IS NOT INITIAL.
      CLEAR ls_toolbar.
      MOVE 'ASS_DEP'                    TO ls_toolbar-function.
      MOVE  icon_fast_entry             TO ls_toolbar-icon.          "table ICON
      MOVE 'Associar Dep.'(111)           TO ls_toolbar-quickinfo.
      MOVE 'Associar Dep.'(112)           TO ls_toolbar-text.
      MOVE ' '                          TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
    IF NOT rb_dp2dp IS INITIAL.
      DELETE e_object->mt_toolbar WHERE function EQ 'ASS_OV'.
    ENDIF.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim

  ENDMETHOD.                    "handle_toolbar

  METHOD handle_hotspot_click.

    "

  ENDMETHOD.

ENDCLASS.
*