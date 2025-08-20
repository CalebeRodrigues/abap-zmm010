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