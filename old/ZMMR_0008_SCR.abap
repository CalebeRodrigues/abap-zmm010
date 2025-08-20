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
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Inicio
            rb_dp2dp TYPE flag RADIOBUTTON GROUP m1.
*Inserido por LuísMagalhães - 08.08.2019 - CH. 8000023352 Alterações ZMM009 - Fim
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.
*