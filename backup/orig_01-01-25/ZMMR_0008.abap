*-----------------------------------------------------------------------
* Report ZMMR_0008
*-----------------------------------------------------------------------


REPORT zmmr_0008.

INCLUDE zmmr_0008_top.
INCLUDE zmmr_0008_scr.
INCLUDE zmmr_0008_c01.
INCLUDE zmmr_0008_main.
INCLUDE zmmr_0008_pbo.
INCLUDE zmmr_0008_pai.

START-OF-SELECTION.
  CALL SCREEN '9000'.
*