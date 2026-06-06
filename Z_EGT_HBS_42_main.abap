REPORT Z_EGT_HBS_42.

INCLUDE Z_EGT_HBS_42_top.
INCLUDE Z_EGT_HBS_42_sel.
INCLUDE Z_EGT_HBS_42_frm.
INCLUDE Z_EGT_HBS_42_pai.
INCLUDE Z_EGT_HBS_42_pbo.

START-OF-SELECTION.

AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'ADD'.
      CALL SELECTION-SCREEN 0200 STARTING AT 10 5.
      IF sy-subrc = 0.
        PERFORM add_player.
      ENDIF.

    WHEN 'DEL'.
      CALL SELECTION-SCREEN 0200 STARTING AT 10 5.
      IF sy-subrc = 0.
        PERFORM delete_player.
      ENDIF.
  ENDCASE.

    CASE sy-ucomm.
  WHEN 'EXC'.
      CALL SELECTION-SCREEN 0300 STARTING AT 10 5.
      IF sy-subrc = 0.
        PERFORM add_from_excel.
      ENDIF.

ENDCASE.


PERFORM get_data.
PERFORM display_alv.

call SCREEN 0100.