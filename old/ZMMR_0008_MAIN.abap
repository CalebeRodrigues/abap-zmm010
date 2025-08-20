*-----------------------------------------------------------------------
* Include: ZMMR_0008_MAIN
*-----------------------------------------------------------------------




*&---------------------------------------------------------------------*
*&      Form  ZF_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM zf_seleciona_dados.

  REFRESH gt_zmms002.

  IF rb_lv2pe IS INITIAL.
*Comentado por LuísMagalhães - 12.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
*    "De pedido para xxxx
*    SELECT a~matnr, meins, werks, lgort, charg, sobkz, vbeln, posnr, kalab, a~ersda
*    FROM mska AS a
*    INNER JOIN mara AS b
*    ON b~matnr = a~matnr
*    INTO TABLE @DATA(gt_mska)
*    WHERE a~matnr IN @s_matnr
*    AND   werks EQ @p_werks
*    AND   vbeln IN @s_vbeln
*    AND   charg IN @s_charg
*    AND   kalab NE @space.
*Comentado por LuísMagalhães - 12.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim
*Inserido por LuísMagalhães - 12.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
    IF NOT rb_dp2dp IS INITIAL.
      "De livre para XXX
      SELECT a~matnr, meins, werks, lgort, charg, clabs, a~ersda
        FROM mchb AS a
       INNER JOIN mara AS b
          ON b~matnr = a~matnr
        INTO TABLE @DATA(gt_mchb)
       WHERE a~matnr IN @s_matnr
         AND werks   EQ @p_werks
         AND charg   IN @s_charg
         AND clabs   NE @space.
    ELSE.
      "De pedido para xxxx
      SELECT a~matnr, meins, werks, lgort, charg, sobkz, vbeln, posnr, kalab, a~ersda
        FROM mska AS a
       INNER JOIN mara AS b
          ON b~matnr = a~matnr
        INTO TABLE @DATA(gt_mska)
       WHERE a~matnr IN @s_matnr
         AND werks   EQ @p_werks
         AND vbeln   IN @s_vbeln
         AND charg   IN @s_charg
         AND kalab   NE @space.
    ENDIF.
*Inserido por LuísMagalhães - 12.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim
  ELSE.
    "De livre para XXX
    SELECT a~matnr, meins, werks, lgort, charg, clabs, a~ersda
    FROM mchb AS a
    INNER JOIN mara AS b
    ON b~matnr = a~matnr
    INTO TABLE @gt_mchb
    WHERE a~matnr IN @s_matnr
    AND   werks EQ @p_werks
    AND   charg IN @s_charg
    AND   clabs NE @space.
  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE s000(00)
    WITH 'Dados não encontrados.'(003)
    DISPLAY LIKE gc_message_type-e.
  ELSE.
    LOOP AT gt_mska ASSIGNING FIELD-SYMBOL(<fs_mska>).
      APPEND INITIAL LINE TO gt_zmms002 ASSIGNING FIELD-SYMBOL(<fs_0021>).
      <fs_0021>-matnr = <fs_mska>-matnr.
      SELECT SINGLE maktx INTO <fs_0021>-maktx FROM makt
          WHERE spras = sy-langu AND matnr = <fs_0021>-matnr.
      <fs_0021>-meins = <fs_mska>-meins.
      <fs_0021>-werks = <fs_mska>-werks.
      <fs_0021>-lgort = <fs_mska>-lgort.
      <fs_0021>-lgort_move = <fs_mska>-lgort.
      <fs_0021>-charg = <fs_mska>-charg.
      <fs_0021>-sobkz = <fs_mska>-sobkz.
      <fs_0021>-vbeln = <fs_mska>-vbeln.
      <fs_0021>-posnr = <fs_mska>-posnr.
      <fs_0021>-kalab = <fs_mska>-kalab.
      <fs_0021>-kalab_chg = <fs_mska>-kalab.
      <fs_0021>-ersda = <fs_mska>-ersda.
    ENDLOOP.

    LOOP AT gt_mchb ASSIGNING FIELD-SYMBOL(<fs_mchb>).
      APPEND INITIAL LINE TO gt_zmms002 ASSIGNING <fs_0021>.
      <fs_0021>-matnr = <fs_mchb>-matnr.
      SELECT SINGLE maktx INTO <fs_0021>-maktx FROM makt
          WHERE spras = sy-langu AND matnr = <fs_0021>-matnr.
      <fs_0021>-meins = <fs_mchb>-meins.
      <fs_0021>-werks = <fs_mchb>-werks.
      <fs_0021>-lgort = <fs_mchb>-lgort.
      <fs_0021>-lgort_move = <fs_mchb>-lgort.
      <fs_0021>-charg = <fs_mchb>-charg.
      <fs_0021>-kalab = <fs_mchb>-clabs.
      <fs_0021>-kalab_chg = <fs_mchb>-clabs.
      <fs_0021>-ersda = <fs_mchb>-ersda.
    ENDLOOP.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_MONTA_ALV
*&---------------------------------------------------------------------*
FORM zf_monta_alv.

*  IF o_docking IS INITIAL.
  IF g_grid IS INITIAL.

    "Cria os Objetos
    PERFORM zf_cria_objetos.

    "Monta o Layout
    PERFORM zf_monta_layout CHANGING g_layout.

    "Monta o FIELDCAT
    PERFORM zf_monta_fieldcat.

    "Exclui botões
    PERFORM zf_exclude_tb_functions CHANGING t_exclude.

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        i_save               = 'A'
        is_layout            = g_layout
        it_toolbar_excluding = t_exclude
      CHANGING
        it_fieldcatalog      = g_fieldcat
        it_outtab            = gt_zmms002[].

    CREATE OBJECT event_receiver.
    SET HANDLER event_receiver->handle_user_command  FOR g_grid.
    SET HANDLER event_receiver->handle_toolbar       FOR g_grid.
    SET HANDLER event_receiver->handle_hotspot_click FOR g_grid.

  ENDIF.

*  CALL METHOD g_grid->set_toolbar_interactive.
*  CALL METHOD g_grid->check_changed_data.
*
  CALL METHOD g_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_CRIA_OBJETOS
*&---------------------------------------------------------------------*
FORM zf_cria_objetos.

  CREATE OBJECT g_grid
    EXPORTING
      i_parent = cl_gui_custom_container=>default_screen.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_MONTA_LAYOUT
*&---------------------------------------------------------------------*
FORM zf_monta_layout CHANGING gs_layout TYPE lvc_s_layo.

  gs_layout-sel_mode   = 'A'.
  gs_layout-no_rowmark = abap_false.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-no_toolbar = abap_false.
*  gs_layout-box_fname  = 'CHECK'.  "

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_MONTA_FIELDCAT
*&---------------------------------------------------------------------*
FORM zf_monta_fieldcat.

  DATA: lt_fieldcat TYPE lvc_t_fcat,
        wa_field    LIKE LINE OF lt_fieldcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZMMS002'
    CHANGING
      ct_fieldcat            = lt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 0
      program_error          = 0
      OTHERS                 = 0.

  g_fieldcat[] = lt_fieldcat[] .

  DELETE g_fieldcat
  WHERE fieldname EQ 'MANDT'.

  IF rb_lv2pe  IS NOT INITIAL.
    DELETE g_fieldcat WHERE fieldname EQ 'VBELN'.
    DELETE g_fieldcat WHERE fieldname EQ 'POSNR'.
    DELETE g_fieldcat WHERE fieldname EQ 'SOBKZ'.
  ENDIF.

  IF rb_pe2lv IS NOT INITIAL.
    DELETE g_fieldcat WHERE fieldname EQ 'VBELN_TO'.
    DELETE g_fieldcat WHERE fieldname EQ 'POSNR_TO'.
  ENDIF.

  READ TABLE g_fieldcat
  ASSIGNING FIELD-SYMBOL(<fsl_field>)
  WITH KEY fieldname = 'FLAG'.

  IF <fsl_field> IS ASSIGNED.
    <fsl_field>-checkbox = abap_true.
    <fsl_field>-edit     = abap_true.
    <fsl_field>-coltext  = 'Sel.'.
  ENDIF.

  READ TABLE g_fieldcat
  ASSIGNING <fsl_field>
  WITH KEY fieldname = 'KALAB_CHG'.

  IF <fsl_field> IS ASSIGNED.
*    <fsl_field>-checkbox = abap_true.
    <fsl_field>-edit     = abap_true.
    <fsl_field>-coltext  = 'Qtd.Transf.Assoc.'.
  ENDIF.

*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
  IF NOT rb_dp2dp IS INITIAL.
    DELETE g_fieldcat WHERE fieldname EQ 'VBELN'.
    DELETE g_fieldcat WHERE fieldname EQ 'POSNR'.
    DELETE g_fieldcat WHERE fieldname EQ 'SOBKZ'.
    DELETE g_fieldcat WHERE fieldname EQ 'VBELN_TO'.
    DELETE g_fieldcat WHERE fieldname EQ 'POSNR_TO'.
  ENDIF.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
FORM zf_exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.

  DATA ls_exclude TYPE ui_func.  " Function code

  "Copiar linha
  APPEND INITIAL LINE TO pt_exclude ASSIGNING FIELD-SYMBOL(<fs_exclude>).
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_copy_row.

  "Deletar linha
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_delete_row.

  "Adicionar linha
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_append_row.

  "Inserir nova linha
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_insert_row.

  "Mover linha
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_move_row.

  "Atualizar
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_refresh.

  "Recortar
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_cut.

  "Copiar
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_copy.

  "Colar
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_mb_paste.

  "Colar
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_paste.

  "Colar nova linha
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.

  "Desfazer
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_loc_undo.

  "Checar entrada
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_check.

  "Detalhes
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_detail.

  "Gráfico
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_graph.

  "Informação
  UNASSIGN <fs_exclude>.
  APPEND INITIAL LINE TO pt_exclude ASSIGNING <fs_exclude>.
  <fs_exclude> = cl_gui_alv_grid=>mc_fc_info.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_TRATA_MSG
*&---------------------------------------------------------------------*
FORM zf_trata_msg TABLES pt_ret STRUCTURE bapiret2.

  "Introduzir nome correto para <...>.
  DATA it_ret2 TYPE TABLE OF bapiret2.

  CHECK pt_ret[] IS NOT INITIAL.

  it_ret2[] = pt_ret[].

*  DATA(r_msg) = NEW cl_ism_bapireturn_handling( ).
*
*  r_msg->display(
*     EXPORTING
**   IT_MSG    =
*    it_return =  it_ret2   " IS-M: BAPIRET2 Table
*    iv_xpos   = 5
*    iv_ypos   = 5
*).

  CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
    TABLES
      it_return = it_ret2[].

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_GERAR_MOV
*&---------------------------------------------------------------------*
FORM zf_gerar_mov.

*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
  DATA: lt_fields TYPE TABLE OF sval.

  DATA: lv_returncode.

  CLEAR: lt_fields[].

  APPEND INITIAL LINE TO lt_fields ASSIGNING FIELD-SYMBOL(<fs_fields>).

  <fs_fields>-tabname   = 'BAPI2017_GM_HEAD_01'.
  <fs_fields>-fieldname = 'PSTNG_DATE'.
  <fs_fields>-value     = sy-datum.

  CLEAR: lv_returncode.
  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = 'Definir data de lançamento'
    IMPORTING
      returncode      = lv_returncode
    TABLES
      fields          = lt_fields
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim

  DATA vl_res.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Transferência'
      text_question         = 'Confirmar transferência de estoque?'
      text_button_1         = 'Sim'
      text_button_2         = 'Não'
      default_button        = '2'
      display_cancel_button = space
    IMPORTING
      answer                = vl_res
* TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  CHECK vl_res EQ '1'.

  DATA: wa_header TYPE bapi2017_gm_head_01,
        wa_doc    TYPE bapi2017_gm_head_ret.
  DATA: it_ret_mov TYPE STANDARD TABLE OF bapiret2.

*Comentado por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
*  wa_header-pstng_date = sy-datum.
*Comentado por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
  READ TABLE lt_fields INTO DATA(ls_fields) INDEX 1.
  IF sy-subrc IS INITIAL.
    wa_header-pstng_date = ls_fields-value.
    IF wa_header-pstng_date IS INITIAL.
      wa_header-pstng_date = sy-datum.
    ENDIF.
  ENDIF.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim
  wa_header-doc_date   = sy-datum.
  wa_header-header_txt = |TRANSFERENCIA DE CENTROS| .

  PERFORM zf_preencher_itens_move.

  CHECK it_item_mov[] IS NOT INITIAL.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = wa_header
      goodsmvt_code    = '04'
    IMPORTING
      goodsmvt_headret = wa_doc
    TABLES
      goodsmvt_item    = it_item_mov
      return           = it_ret_mov.

  IF wa_doc IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    it_ret_mov = VALUE #( ( type = 'S' message = |Documento: { wa_doc-mat_doc } - { wa_doc-doc_year }| ) ).

    PERFORM zf_trata_msg TABLES it_ret_mov.
  ELSE.
    PERFORM zf_trata_msg TABLES it_ret_mov.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_PREENCHER_ITENS_MOVE
*&---------------------------------------------------------------------*
FORM zf_preencher_itens_move.

  DATA: vl_move  TYPE bwart,  "Tipo de movimento (administração de estoques)
        vl_sobkz TYPE sobkz.  "Código de estoque especial

* ==>> BEGIN >> changed by Norberto Silva in 21.11.2018
  DATA:
    lv_param_1 TYPE tvarvc-low,
    lv_param_2 TYPE tvarvc-low,
    lv_param_3 TYPE tvarvc-low.

  SELECT SINGLE low
  INTO lv_param_1
  FROM tvarvc
  WHERE name EQ 'ZMM009_MOV_LIVRE_PARA_PEDIDO'
  AND   type EQ 'P'.

  SELECT SINGLE low
  INTO lv_param_2
  FROM tvarvc
  WHERE name EQ 'ZMM009_MOV_PEDIDO_PARA_LIVRE'
  AND   type EQ 'P'.

  SELECT SINGLE low
  INTO lv_param_3
  FROM tvarvc
  WHERE name EQ 'ZMM009_MOV_PEDIDO_PARA_PEDIDO'
  AND   type EQ 'P'.
* <<== END   << changed by Norberto Silva in 21.11.2018

*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
  SELECT SINGLE low
    FROM tvarvc
    INTO @DATA(lv_param_4)
   WHERE name EQ 'ZMM009_MOV_DEP_PARA_DEP'
     AND type EQ 'P'.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim

  CLEAR it_item_mov.
  LOOP AT gt_zmms002_sel ASSIGNING FIELD-SYMBOL(<fs_lotes>). " WHERE flag is NOT INITIAL.
    CLEAR: vl_sobkz,
           vl_move.

    "Verifica se Lote já tinha no OP
    IF rb_lv2pe IS NOT INITIAL.  "Livre para Pedido
* ==>> BEGIN >> changed by Norberto Silva in 21.11.2018
*      vl_move  = '413'.  "TE dep.->ordem cli.
*      vl_sobkz = ' '.    "
**     vl_move  = '412'.  "ET dep.->dep.
**     vl_sobkz = 'E'.    "Estoque individual
      vl_move  = lv_param_1.
      vl_sobkz = ' '.
* <<== END   << changed by Norberto Silva in 21.11.2018
    ENDIF.

    IF rb_pe2lv IS NOT INITIAL.  "Pedido para Livre
* ==>> BEGIN >> changed by Norberto Silva in 21.11.2018
*     vl_move  = '411'.  "TE depósito->depós.
*     vl_sobkz = 'E'.    "
      vl_move  = lv_param_2.
*Comentado por LuísMagalhães - 12.08.2019 - CH. 8000023878 ZMM009 - NÃO TRANSFERE DE PEDIDO P LIVRE - Inicio
*      vl_sobkz = 'E'.
*Comentado por LuísMagalhães - 12.08.2019 - CH. 8000023878 ZMM009 - NÃO TRANSFERE DE PEDIDO P LIVRE - Fim
* <<== END   << changed by Norberto Silva in 21.11.2018
    ENDIF.

    IF rb_pe2pe IS NOT INITIAL.  "Pedido para Pedido
* ==>> BEGIN >> changed by Norberto Silva in 21.11.2018
*      vl_move  = '413'.  "TE dep.->ordem cli.
*      vl_sobkz = 'E'.    "Estoque individual
      vl_move  = lv_param_3.
      vl_sobkz = 'E'.
* <<== END   << changed by Norberto Silva in 21.11.2018
    ENDIF.

*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
    IF NOT rb_dp2dp IS INITIAL.
      vl_move  = lv_param_4.
      vl_sobkz = ''.
    ENDIF.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim

    APPEND INITIAL LINE TO it_item_mov ASSIGNING FIELD-SYMBOL(<fs_item>).

    IF <fs_item> IS ASSIGNED.
      <fs_item>-material   = <fs_lotes>-matnr.
      <fs_item>-plant      = <fs_lotes>-werks.
      <fs_item>-batch      = <fs_lotes>-charg.
      <fs_item>-stge_loc   = <fs_lotes>-lgort.  "LGORT_ORI.
      <fs_item>-entry_qnt  = <fs_lotes>-kalab_chg.  "<fs_lotes>-kalab.  "Quantidade
      <fs_item>-entry_uom  = <fs_lotes>-meins.  "Quantidade
      <fs_item>-move_stloc = <fs_lotes>-lgort_move.  "lgort.  "Deposito destino
      <fs_item>-move_mat   = <fs_lotes>-matnr.  "Material
      <fs_item>-move_plant = <fs_lotes>-werks.  "Centro
      <fs_item>-move_batch = <fs_lotes>-charg.  "Lote destino

      IF  <fs_lotes>-vbeln_to IS NOT INITIAL
      AND rb_lv2pe IS INITIAL.  "Livre para Pedido
        <fs_item>-sales_ord  = <fs_lotes>-vbeln_to.
        <fs_item>-s_ord_item = <fs_lotes>-posnr_to.
      ENDIF.

      <fs_item>-move_type  = vl_move.
      <fs_item>-spec_stock = vl_sobkz.

      IF rb_lv2pe IS INITIAL.  "Livre para Pedido
        <fs_item>-val_sales_ord  = <fs_lotes>-vbeln.
        <fs_item>-val_s_ord_item = <fs_lotes>-posnr.
      ELSE.
        <fs_item>-val_sales_ord  = <fs_lotes>-vbeln_to.
        <fs_item>-val_s_ord_item = <fs_lotes>-posnr_to.
      ENDIF.

*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
      IF NOT rb_dp2dp IS INITIAL.
        CLEAR: <fs_item>-val_sales_ord,
               <fs_item>-val_s_ord_item.
      ENDIF.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim
    ENDIF.
  ENDLOOP.

ENDFORM.    "ZF_PREENCHER_ITENS_MOVE


*&---------------------------------------------------------------------*
*&      Form  ZF_VALIDAR_OV_INPUT
*&---------------------------------------------------------------------*
FORM zf_validar_ov_input USING p_matnr
                               p_erro.

  p_erro = abap_true.

  IF vbap-vbeln IS INITIAL.
    MESSAGE 'Preencher Ordem de venda.'
    TYPE 'S'
    DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  IF vbap-posnr IS INITIAL.
    MESSAGE 'Preencher Item da ordem de venda.'
    TYPE 'S'
    DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  "Seleciona material para ver se é compativel
  SELECT SINGLE matnr FROM vbap
  INTO @DATA(vl_matnr)
  WHERE vbeln EQ @vbap-vbeln
  AND   posnr EQ @vbap-posnr.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE 'OV/Item não encontrado!'
    TYPE 'S'
    DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

*  IF p_matnr NE vl_matnr.
*    MESSAGE |Material { p_matnr } difere da OV/Item: { vl_matnr }|
*    TYPE 'I'.
*    RETURN.
*  ENDIF.

  CLEAR p_erro.

ENDFORM.
*
*&---------------------------------------------------------------------*
*&      Form  ZF_VALIDAR_DEP_INPUT
*&---------------------------------------------------------------------*
FORM zf_validar_dep_input USING p_matnr
                                p_erro.

  p_erro = abap_true.

  IF mard-lgort IS INITIAL.
    MESSAGE 'Preencher Depósito'
    TYPE 'S'
    DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  "Seleciona material para ver se é compativel
  SELECT COUNT(*) FROM t001l
  WHERE werks EQ p_werks
    AND lgort EQ mard-lgort.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE 'Depósito não encontrado!'
    TYPE 'S'
    DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  CLEAR p_erro.

ENDFORM.