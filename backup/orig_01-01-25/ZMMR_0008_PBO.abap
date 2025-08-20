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

  PERFORM zf_seleciona_dados.
  PERFORM zf_monta_alv.

ENDMODULE.
*