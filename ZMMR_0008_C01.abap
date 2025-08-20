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

*-----------------------------------------------------------------------
* Utilitários M2M em massa (ajuste de tipos)
* Calebe Rodrigues - TI SR Embalagens (19/08/2025
*-----------------------------------------------------------------------
FORM add_text_msg USING iv_type    TYPE symsgty
                        iv_message     TYPE ty_msg120.            " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  DATA ls_ret TYPE bapiret2.
  CLEAR ls_ret.
  ls_ret-type    = iv_type.
  ls_ret-id      = gc_msgid.
  ls_ret-message = iv_message.
  APPEND ls_ret TO gt_ret.
ENDFORM.


FORM validate_line USING    is_row TYPE ty_transf
                   CHANGING cv_ok  TYPE abap_bool.           " Calebe Rodrigues - TI SR Embalagens (19/08/2025
DATA: lv_dummy TYPE char1,
      lv_msg   TYPE ty_msg120.       " era STRING  -> compatível com add_text_msg

  cv_ok = abap_true.

  " a) Centro válido
  SELECT SINGLE werks FROM t001w INTO @lv_dummy WHERE werks = @is_row-werks.
  IF sy-subrc <> 0.
    CONCATENATE 'Centro' is_row-werks 'inexistente.' INTO lv_msg SEPARATED BY space.
    PERFORM add_text_msg USING gc_message_type-e lv_msg.      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    cv_ok = abap_false.
  ENDIF.

  " b) Depósito válido (se informado)
  IF is_row-lgort IS NOT INITIAL.
    SELECT SINGLE lgort FROM t001l INTO @lv_dummy
           WHERE werks = @is_row-werks AND lgort = @is_row-lgort.
    IF sy-subrc <> 0.
      CONCATENATE 'Depósito' is_row-lgort 'não existe no centro' is_row-werks
             INTO lv_msg SEPARATED BY space.
      PERFORM add_text_msg USING gc_message_type-e lv_msg.
      cv_ok = abap_false.
    ENDIF.
  ENDIF.

  " c) Materiais origem/destino
  SELECT SINGLE matnr FROM mara INTO @lv_dummy WHERE matnr = @is_row-mat_orig.
  IF sy-subrc <> 0.
    CONCATENATE 'Material origem' is_row-mat_orig 'inexistente.' INTO lv_msg SEPARATED BY space.
    PERFORM add_text_msg USING gc_message_type-e lv_msg.      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    cv_ok = abap_false.
  ENDIF.

  SELECT SINGLE matnr FROM mara INTO @lv_dummy WHERE matnr = @is_row-mat_dest.
  IF sy-subrc <> 0.
    CONCATENATE 'Material destino' is_row-mat_dest 'inexistente.' INTO lv_msg SEPARATED BY space.
    PERFORM add_text_msg USING gc_message_type-e lv_msg.      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    cv_ok = abap_false.
  ENDIF.

  " d) UM obrigatória
  IF is_row-meins IS INITIAL.
    CONCATENATE 'Unidade de medida não informada para' is_row-mat_orig
           INTO lv_msg SEPARATED BY space.
    PERFORM add_text_msg USING gc_message_type-e lv_msg.
    cv_ok = abap_false.
  ENDIF.

  " e) Quantidade > 0
  IF is_row-menge IS INITIAL OR is_row-menge <= 0.
    CONCATENATE 'Quantidade inválida para' is_row-mat_orig '→' is_row-mat_dest
           INTO lv_msg SEPARATED BY space.
    PERFORM add_text_msg USING gc_message_type-e lv_msg.
    cv_ok = abap_false.
  ENDIF.

ENDFORM.                                                     " Calebe Rodrigues - TI SR Embalagens (19/08/2025)


FORM build_item USING    is_row  TYPE ty_transf
                CHANGING cs_item TYPE bapi2017_gm_item_create. " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  FIELD-SYMBOLS: <f_any> TYPE any.

  CLEAR cs_item.
  cs_item-material   = is_row-mat_orig.
  cs_item-plant      = is_row-werks.
  cs_item-stge_loc   = is_row-lgort.
  cs_item-batch      = is_row-charg.
  cs_item-move_type  = gc_movtype_309.
  cs_item-entry_qnt  = is_row-menge.
  cs_item-entry_uom  = is_row-meins.

  IF is_row-sobkz IS NOT INITIAL.
    cs_item-spec_stock = is_row-sobkz.
    cs_item-reserv_no  = is_row-vbeln.
    cs_item-res_item   = is_row-posnr.
  ENDIF.

  " Material de destino - tentar campos conforme release
  ASSIGN COMPONENT 'MATERIAL_NEW'        OF STRUCTURE cs_item TO <f_any>.
  IF sy-subrc = 0. <f_any> = is_row-mat_dest. RETURN. ENDIF.

  ASSIGN COMPONENT 'MATERIAL_LONG_NEW'   OF STRUCTURE cs_item TO <f_any>.
  IF sy-subrc = 0. <f_any> = is_row-mat_dest. RETURN. ENDIF.

  ASSIGN COMPONENT 'MATERIAL_EXTERNAL_NEW' OF STRUCTURE cs_item TO <f_any>.
  IF sy-subrc = 0. <f_any> = is_row-mat_dest. RETURN. ENDIF.

  ASSIGN COMPONENT 'MATERIAL_GUID_NEW'   OF STRUCTURE cs_item TO <f_any>.
  IF sy-subrc = 0. <f_any> = is_row-mat_dest. RETURN. ENDIF.

  " Se nenhum campo existir: registrar aviso para diagnóstico
  PERFORM add_text_msg USING gc_message_type-e
    'Campo do material de destino (*_NEW) não encontrado no release.'.
ENDFORM.                                                     " Calebe Rodrigues - TI SR Embalagens (19/08/2025

*-----------------------------------------------------------------------
* Fim dos utilitários M2M
* Calebe Rodrigues - TI SR Embalagens (19/08/2025
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Fieldcat do ALV M2M - versão sem macro (ajuste de assinatura)
* Calebe Rodrigues - TI SR Embalagens (19/08/2025
*-----------------------------------------------------------------------
FORM add_fcat USING
      iv_fieldname TYPE lvc_fname          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      iv_coltext   TYPE scrtext_l          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      iv_outlen    TYPE i                  " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      iv_edit      TYPE c.                 " Calebe Rodrigues - TI SR Embalagens (19/08/2025

  DATA ls_fcat TYPE lvc_s_fcat.                                          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  CLEAR ls_fcat.                                                         " Calebe Rodrigues - TI SR Embalagens (19/08/2025

  ls_fcat-fieldname = iv_fieldname.                                      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  ls_fcat-coltext   = iv_coltext.                                        " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  ls_fcat-scrtext_l = iv_coltext.                                        " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  ls_fcat-outputlen = iv_outlen.                                         " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  IF iv_edit = 'X'.                                                      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
    ls_fcat-edit = 'X'.                                                  " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  ENDIF.                                                                 " Calebe Rodrigues - TI SR Embalagens (19/08/2025

  APPEND ls_fcat TO g_fieldcat.                                          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
ENDFORM.                                                                 " Calebe Rodrigues - TI SR Embalagens (19/08/2025

*-----------------------------------------------------------------------
* Adiciona coluna ícone no fieldcat
* Calebe Rodrigues - TI SR Embalagens (19/08/2025
*-----------------------------------------------------------------------
FORM add_fcat_icon USING iv_fieldname TYPE lvc_fname
                         iv_coltext   TYPE scrtext_l
                         iv_outlen    TYPE i.
  DATA ls_fcat TYPE lvc_s_fcat.
  CLEAR ls_fcat.
  ls_fcat-fieldname = iv_fieldname.
  ls_fcat-coltext   = iv_coltext.
  ls_fcat-scrtext_l = iv_coltext.
  ls_fcat-outputlen = iv_outlen.
  ls_fcat-icon      = 'X'.  " mostra @..@                           " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  APPEND ls_fcat TO g_fieldcat.
ENDFORM.

*-----------------------------------------------------------------------
* Montagem do fieldcat M2M
* Calebe Rodrigues - TI SR Embalagens (19/08/2025
*-----------------------------------------------------------------------
FORM build_fcat_transf .
  REFRESH g_fieldcat.                                                    " Calebe Rodrigues - TI SR Embalagens (19/08/2025

  PERFORM add_fcat USING 'MAT_ORIG' 'Material Origem'   18 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'MAT_DEST' 'Material Destino'  18 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'WERKS'    'Centro'             4 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'LGORT'    'Depósito'           4 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'CHARG'    'Lote'              10 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'MENGE'    'Qtd'               13 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'MEINS'    'UM'                 3 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'SOBKZ'    'EstqEsp'            1 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'VBELN'    'Pedido'            10 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat USING 'POSNR'    'Item'               6 'X'.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat_icon USING 'STATUS_ICON' 'Sts' 3.          " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  PERFORM add_fcat      USING 'STATUS_MSG'  'Mensagem' 60 ' '. " Calebe Rodrigues - TI SR Embalagens (19/08/2025
ENDFORM.

*-----------------------------------------------------------------------
* Validação "silenciosa" para uso no upload/validar (sem jogar em gt_ret)
* Retorna ok/nok e uma mensagem curta
* Calebe Rodrigues - TI SR Embalagens (19/08/2025
*-----------------------------------------------------------------------
FORM validate_line_silent USING    is_row TYPE ty_transf
                          CHANGING cv_ok  TYPE abap_bool
                                   cv_msg TYPE ty_msg120.    " Calebe Rodrigues - TI SR Embalagens (19/08/2025

  DATA: lv_dummy TYPE char1.
  DATA: lv_msg   TYPE ty_msg120.                             " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  cv_ok = abap_true.
  CLEAR cv_msg.

  " Regras rápidas antes de acessar DB
  IF is_row-mat_orig IS INITIAL OR is_row-mat_dest IS INITIAL.
    cv_ok = abap_false.  cv_msg = 'Informe material origem e destino.'.
    RETURN.
  ENDIF.

  IF is_row-mat_orig = is_row-mat_dest.
    cv_ok = abap_false.  cv_msg = 'Origem e destino não podem ser iguais.'.
    RETURN.
  ENDIF.

  IF is_row-werks IS INITIAL.
    cv_ok = abap_false.  cv_msg = 'Informe o centro (WERKS).'.
    RETURN.
  ENDIF.

  IF is_row-menge IS INITIAL OR is_row-menge <= 0.
    cv_ok = abap_false.  cv_msg = 'Quantidade deve ser > 0.'.
    RETURN.
  ENDIF.

  " Checagens simples no dicionário
  SELECT SINGLE matnr FROM mara INTO @lv_dummy WHERE matnr = @is_row-mat_orig.
  IF sy-subrc <> 0.
    cv_ok = abap_false.  CONCATENATE 'Material origem' is_row-mat_orig 'inexistente.' INTO cv_msg SEPARATED BY space.
    RETURN.
  ENDIF.

  SELECT SINGLE matnr FROM mara INTO @lv_dummy WHERE matnr = @is_row-mat_dest.
  IF sy-subrc <> 0.
    cv_ok = abap_false.  CONCATENATE 'Material destino' is_row-mat_dest 'inexistente.' INTO cv_msg SEPARATED BY space.
    RETURN.
  ENDIF.

  IF is_row-lgort IS NOT INITIAL.
    SELECT SINGLE lgort FROM t001l INTO @lv_dummy
      WHERE werks = @is_row-werks AND lgort = @is_row-lgort.
    IF sy-subrc <> 0.
      cv_ok = abap_false.
      CONCATENATE 'Depósito' is_row-lgort 'não existe no centro' is_row-werks INTO cv_msg SEPARATED BY space.
      RETURN.
    ENDIF.
  ENDIF.

  " OK
  cv_msg = 'Pronto para postar.'.
ENDFORM.