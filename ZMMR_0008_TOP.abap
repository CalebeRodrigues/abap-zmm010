*-----------------------------------------------------------------------
* Include: ZMMR_0008_TOP
*-----------------------------------------------------------------------


TABLES:
  ZMMS002,
  mska,
  vbap,
  mard.

DATA:
  gt_ZMMS002     TYPE TABLE OF ZMMS002,
  gt_ZMMS002_sel TYPE TABLE OF ZMMS002,
  gt_rows        TYPE lvc_t_row,
  it_item_mov    TYPE TABLE OF bapi2017_gm_item_create.

DATA:
  wa_ZMMS002 TYPE ZMMS002.

DATA:
  vg_erro  TYPE flag,
  vg_matnr TYPE mara-matnr.

CONSTANTS:
  c_x        TYPE c VALUE 'X',
  abap_true  TYPE abap_bool VALUE 'X',
  abap_false TYPE abap_bool VALUE ' '.

CONSTANTS:
  BEGIN OF gc_message_type,
    e TYPE syst_msgty VALUE 'E',
    i TYPE syst_msgty VALUE 'I',
    s TYPE syst_msgty VALUE 'S',
  END OF gc_message_type.

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA:
  g_grid             TYPE REF TO cl_gui_alv_grid,
  g_custom_container TYPE REF TO cl_gui_custom_container,
  g_fieldcat         TYPE        lvc_t_fcat,
  g_layout           TYPE        lvc_s_layo,
  t_exclude          TYPE        ui_functions,                   "Function Code Table
  event_receiver     TYPE REF TO lcl_event_receiver,
  o_docking          TYPE REF TO cl_gui_docking_container,       "Docking Container
  o_split            TYPE REF TO cl_gui_easy_splitter_container, "Splitter
  o_top_container    TYPE REF TO cl_gui_container,               "Top Container
  o_bottom_container TYPE REF TO cl_gui_container,               "Bottom Container
  o_document         TYPE REF TO cl_dd_document,                 "Doc
  timer              TYPE REF TO cl_gui_timer.
*

"-----------------------------------------------------------------------
" Bloco M2M em massa - declarações globais
" Calebe Rodrigues - TI SR Embalagens (19/08/2025
"-----------------------------------------------------------------------

TYPES: BEGIN OF ty_transf,                                              " Calebe Rodrigues - TI SR Embalagens (19/08/2025
         mat_orig TYPE matnr,                                           " Material origem       Calebe Rodrigues - TI SR Embalagens (19/08/2025
         mat_dest TYPE matnr,                                           " Material destino      Calebe Rodrigues - TI SR Embalagens (19/08/2025
         werks    TYPE werks_d,                                         " Centro                Calebe Rodrigues - TI SR Embalagens (19/08/2025
         lgort    TYPE lgort_d,                                         " Depósito (opcional)   Calebe Rodrigues - TI SR Embalagens (19/08/2025
         charg    TYPE charg_d,                                         " Lote (opcional)       Calebe Rodrigues - TI SR Embalagens (19/08/2025
         menge    TYPE menge_d,                                         " Quantidade            Calebe Rodrigues - TI SR Embalagens (19/08/2025
         meins    TYPE meins,                                           " UM                    Calebe Rodrigues - TI SR Embalagens (19/08/2025
         sobkz    TYPE sobkz,                                           " Estoque especial      Calebe Rodrigues - TI SR Embalagens (19/08/2025
         vbeln    TYPE vbeln_va,                                        " Pedido (se aplicável) Calebe Rodrigues - TI SR Embalagens (19/08/2025
         posnr    TYPE posnr_va,                                        " Item do pedido        Calebe Rodrigues - TI SR Embalagens (19/08/2025
         status_icon TYPE icon_d,            " ícone verde/vermelho     Calebe Rodrigues - TI SR Embalagens (19/08/2025
         status_msg  TYPE c LENGTH 120,      " mensagem da validação    Calebe Rodrigues - TI SR Embalagens (19/08/2025
         status_type TYPE syst_msgty,        " 'S' / 'E' / 'W'          Calebe Rodrigues - TI SR Embalagens (19/08/2025
       END OF ty_transf.                                                " Calebe Rodrigues - TI SR Embalagens (19/08/2025

" Tipo de mensagem 120
TYPES ty_msg120 TYPE c LENGTH 120.     " Calebe Rodrigues - TI SR Embalagens (19/08/2025

DATA: gt_transf TYPE STANDARD TABLE OF ty_transf WITH DEFAULT KEY,      " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      gs_transf TYPE ty_transf.                                         " Calebe Rodrigues - TI SR Embalagens (19/08/2025

DATA: gt_ret TYPE STANDARD TABLE OF bapiret2,                           " Calebe Rodrigues - TI SR Embalagens (19/08/2025
      gs_ret TYPE bapiret2.                                             " Calebe Rodrigues - TI SR Embalagens (19/08/2025

DATA gv_commit_errors TYPE i.                                           " Calebe Rodrigues - TI SR Embalagens (19/08/2025

CONSTANTS:
  gc_movtype_309     TYPE bwart      VALUE '309',                 " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  gc_gmcode_transfer TYPE c LENGTH 2 VALUE '04',   " Calebe Rodrigues - TI SR Embalagens (19/08/2025
  gc_msgid           TYPE symsgid    VALUE 'ZMM'.                 " Calebe Rodrigues - TI SR Embalagens (19/08/2025

"-----------------------------------------------------------------------
" Fim do bloco M2M em massa
" Calebe Rodrigues - TI SR Embalagens (19/08/2025
"-----------------------------------------------------------------------