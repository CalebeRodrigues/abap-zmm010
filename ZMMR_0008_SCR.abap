*-----------------------------------------------------------------------
* Include: ZMMR_0008_SCR
*-----------------------------------------------------------------------

SELECTION-SCREEN BEGIN OF BLOCK b1
WITH FRAME TITLE TEXT-001.  "Selecione os dados
PARAMETERS p_werks TYPE vbap-werks OBLIGATORY.
SELECT-OPTIONS: s_matnr FOR mska-matnr,
                s_vbeln FOR mska-vbeln,
                s_charg FOR mska-charg.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b2
WITH FRAME TITLE TEXT-002 NO INTERVALS.  "Tipo de Transferência
PARAMETERS: rb_lv2pe TYPE flag RADIOBUTTON GROUP m1,  "Livre para Pedido
            rb_pe2lv TYPE flag RADIOBUTTON GROUP m1,  "Pedido para Livre
            rb_pe2pe TYPE flag RADIOBUTTON GROUP m1,  "Pedido para Pedido
            rb_dp2dp TYPE flag RADIOBUTTON GROUP m1,  "Depósito para Depósito
            rb_ma2ma TYPE flag RADIOBUTTON GROUP m1. "Material para Material
SELECTION-SCREEN END OF BLOCK b2.

"--- Campos que só aparecem quando Material para Material for escolhido
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
PARAMETERS: mat_orig TYPE matnr MODIF ID M2M,
            mat_dest TYPE matnr MODIF ID M2M.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN END OF BLOCK b1.

*-----------------------------------------------------------------------
* Lógica para esconder/mostrar
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'M2M'.
      IF rb_ma2ma = abap_true.
        screen-active = '1'. "mostra os campos
      ELSE.
        screen-active = '0'. "esconde os campos
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.