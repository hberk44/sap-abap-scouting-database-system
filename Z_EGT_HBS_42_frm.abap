CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,
      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_toolbar.
    DATA: ls_button TYPE stb_button.

    CLEAR ls_button.
    ls_button-function  = 'DEL_SEL'.          " Fonksiyon kodu
    ls_button-icon      = icon_delete_row.    " Çöp kutusu ikonu
    ls_button-quickinfo = 'Seçili Oyuncuları Sil'.
    ls_button-text      = 'Sil'.
    ls_button-butn_type = 0.
    APPEND ls_button TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'DEL_SEL'.
        PERFORM delete_selected_players.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: lt_joined TYPE TABLE OF ty_alv.

  " JOIN ile verileri birleştir
  SELECT p~player_name, p~player_age, p~player_team,
         p~player_position, p~player_nation,
         s~player_match, s~assists, s~goals,
         s~passes_all, s~performance
    FROM zplayer AS p
    INNER JOIN zplayer_stats AS s
      ON p~player_name = s~player_name
    WHERE p~player_name IN @s_pname
      AND p~player_age IN @s_page
      AND p~player_team IN @s_pteam
      AND p~player_position IN @s_posi
      AND p~player_nation IN @s_nation
      AND s~player_match IN @s_pmatch
      AND s~passes_all IN @s_pass
      AND s~goals IN @s_goal
      AND s~assists IN @s_assist
      AND s~performance IN @s_perf
    INTO CORRESPONDING FIELDS OF TABLE @gt_alv.

  LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<gfs_alv>).
    PERFORM calculate_performance USING <gfs_alv>-goals
                                        <gfs_alv>-assists
                                        <gfs_alv>-passes_all
                                        <gfs_alv>-player_match
                              CHANGING <gfs_alv>-performance.
  ENDLOOP.

  " boş gol değerlerini 0 yap
  LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<gfs_update>)
    WHERE goals IS INITIAL.
    <gfs_update>-goals = '0'.
  ENDLOOP.

  " Hücre renklendirme
  LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<gfs_baller>).

    " Performans < 50 ise yeşil
    IF <gfs_baller>-performance LT 50.
      CLEAR gs_cell_clr.
      gs_cell_clr-fname = 'PERFORMANCE'.
      gs_cell_clr-color-col = '6'. " yeşil
      gs_cell_clr-color-int = '0'.
      gs_cell_clr-color-inv = '0'.
      APPEND gs_cell_clr TO <gfs_baller>-cell_clr.

      CLEAR gs_cell_clr.
      gs_cell_clr-fname = 'PLAYER_NAME'.
      gs_cell_clr-color-col = '6'.
      gs_cell_clr-color-int = '0'.
      gs_cell_clr-color-inv = '0'.
      APPEND gs_cell_clr TO <gfs_baller>-cell_clr.
    ENDIF.

    " Yaş > 41 ise mor
    IF <gfs_baller>-player_age GT 41.
      CLEAR gs_cell_clr.
      gs_cell_clr-fname = 'PLAYER_NAME'.
      gs_cell_clr-color-col = '6'. " mor
      gs_cell_clr-color-int = '0'.
      gs_cell_clr-color-inv = '0'.
      APPEND gs_cell_clr TO <gfs_baller>-cell_clr.

      CLEAR gs_cell_clr.
      gs_cell_clr-fname = 'PLAYER_AGE'.
      gs_cell_clr-color-col = '6'.
      gs_cell_clr-color-int = '0'.
      gs_cell_clr-color-inv = '0'.
      APPEND gs_cell_clr TO <gfs_baller>-cell_clr.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM display_alv .
*
*  IF go_alv IS INITIAL.
*    CREATE OBJECT go_cont
*      EXPORTING
*        container_name = 'CC_ALV'.
*
*    CREATE OBJECT go_alv
*      EXPORTING
*        i_parent = go_cont.
*
*    PERFORM set_fc.
*    PERFORM set_layout.
*
*    CALL METHOD go_alv->set_table_for_first_display
*      EXPORTING
*        is_layout       = gs_layout
*      CHANGING
*        it_outtab       = gt_alv
*        it_fieldcatalog = gt_fc.
*
*  ELSE.
*    CALL METHOD go_alv->refresh_table_display.
*  ENDIF.


FORM display_alv .


  IF go_alv IS INITIAL.

    CREATE OBJECT go_cont
      EXPORTING
        container_name = 'CC_ALV'.

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_cont.
    DATA(lo_handler) = NEW lcl_event_handler( ).
    SET HANDLER lo_handler->handle_toolbar     FOR go_alv.
    SET HANDLER lo_handler->handle_user_command FOR go_alv.
    PERFORM set_fc.
    PERFORM set_layout.


    " ALV veriyi ekle
    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_alv
        it_fieldcatalog = gt_fc.



  ELSE.
    CALL METHOD go_alv->refresh_table_display.
  ENDIF.

ENDFORM.




*&---------------------------------------------------------------------*
*& Form set_fc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc .

  CLEAR gt_fc.

  " zplayer
  PERFORM add_field USING 'PLAYER_NAME' 'Oyuncu Adı' 'CHAR' '40' ''.
  PERFORM add_field USING 'PLAYER_AGE' 'Yaş' 'NUMC' '3' ''.
  PERFORM add_field USING 'PLAYER_TEAM' 'Takım' 'CHAR' '30' ''.
  PERFORM add_field USING 'PLAYER_POSITION' 'Pozisyon' 'CHAR' '20' ''.
  PERFORM add_field USING 'PLAYER_NATION' 'Milliyet' 'CHAR' '30' ''.


  " zplayer_stats
  PERFORM add_field USING 'PLAYER_MATCH' 'Maç' 'NUMC' '10'  '' .
  PERFORM add_field USING 'ASSISTS' 'Asist' 'NUMC' '10'  '' .
  PERFORM add_field USING 'GOALS' 'Gol' 'NUMC' '10'  '' .
  PERFORM add_field USING 'PASSES_ALL' 'Pas' 'NUMC' '10'  '' .
  PERFORM add_field USING 'PERFORMANCE' 'Performans' 'NUMC' '10'  '' .




ENDFORM.






*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .

  gs_layout-zebra = abap_true.
  gs_layout-cwidth_opt = abap_false.
  gs_layout-ctab_fname = 'CELL_CLR'.
  gs_layout-edit_mode = abap_true.
  gs_layout-sel_mode = 'D'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form add_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_      text
*&      --> P_      text
*&      --> P_      text
*&      --> P_      text
*&      --> P_      text
*&---------------------------------------------------------------------*
FORM add_field USING p_fieldname p_text p_datatype p_length p_key.
  CLEAR gs_fc.
  gs_fc-fieldname = p_fieldname.  " alan adı
  gs_fc-reptext   = p_text.       " kısa başlık
  gs_fc-coltext   = p_text.       " sütun başlığı
  gs_fc-scrtext_m = p_text.       " orta uzunlukta başlık
  gs_fc-scrtext_s = p_text.       " kısa başlık
  gs_fc-scrtext_l = p_text.       " uzun başlık
  gs_fc-datatype  = p_datatype.   " veri tipi
  gs_fc-outputlen = p_length.     " sütun genişliği
  gs_fc-key       = p_key.        " anahtar alan mı
  APPEND gs_fc TO gt_fc.          " listeye ekle
ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_player
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_player .

  DATA: ls_player       TYPE zplayer,
        ls_player_stats TYPE zplayer_stats,
        lv_performance  TYPE i.

  IF pi_name IS INITIAL OR
     pi_age  IS INITIAL OR
     pi_team IS INITIAL OR
     pi_posi IS INITIAL OR
     pi_nat  IS INITIAL OR
     pi_matc IS INITIAL OR
     pi_pass IS INITIAL OR
     pi_goal IS INITIAL OR
     pi_assi IS INITIAL.

    MESSAGE 'Tüm alanlar doldurulmalıdır' TYPE 'E'.

  ENDIF.

  PERFORM calculate_performance USING pi_goal
                                      pi_assi
                                      pi_pass
                                      pi_matc
                           CHANGING lv_performance.

  " zplayer ekle
  ls_player-player_name     = pi_name.
  ls_player-player_age      = pi_age.
  ls_player-player_team     = pi_team.
  ls_player-player_position = pi_posi.
  ls_player-player_nation   = pi_nat.

  INSERT zplayer FROM ls_player.

  IF sy-subrc = 0.
    MESSAGE 'Oyuncu ana tabloya eklendi' TYPE 'S'.
  ELSE.
    MESSAGE 'Oyuncu eklenemedi (zplayer)!' TYPE 'E'.
    EXIT.
  ENDIF.

  " zplayer_stats ekle
  ls_player_stats-player_name   = pi_name. " foreign key
  ls_player_stats-player_match  = pi_matc.
  ls_player_stats-passes_all    = pi_pass.
  ls_player_stats-goals         = pi_goal.
  ls_player_stats-assists       = pi_assi.
  ls_player_stats-performance   = 0.

  INSERT zplayer_stats FROM ls_player_stats.

  IF sy-subrc = 0.
    MESSAGE 'Oyuncu istatistiklere eklendi' TYPE 'S'.
  ELSE.
    MESSAGE 'Oyuncu eklenemedi ' TYPE 'E'.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form delete_player
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_player .

  DELETE FROM zplayer_stats WHERE player_name = @pi_name.

  DELETE FROM zplayer WHERE player_name = @pi_name.
  CALL METHOD go_alv->refresh_table_display.

  IF sy-subrc = 0.
    MESSAGE 'Oyuncu silindi' TYPE 'S'.

  ELSE.
    MESSAGE 'Oyuncu bulunamadı' TYPE 'I'.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form calculate_performance
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <GFS_ALV>_GOALS
*&      --> <GFS_ALV>_ASSISTS
*&      --> <GFS_ALV>_PASSES_ALL
*&      --> <GFS_ALV>_PLAYER_MATCH
*&      <-- <GFS_ALV>_PERFORMANCE
*&---------------------------------------------------------------------*
FORM calculate_performance USING p_goals       TYPE i
                                 p_assists     TYPE i
                                 p_passes      TYPE i
                                 p_matches     TYPE i
                      CHANGING   p_performance TYPE i.

  DATA: lv_temp TYPE f.

  " Maç başına performans hesaplama
  IF p_matches > 0.
    lv_temp = ( ( p_goals * 50 ) + ( p_assists * 30 ) + ( p_passes / 10 ) ) / p_matches.

    " Sonucu performans olarak ata
    p_performance = lv_temp.
  ELSE.
    p_performance = 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_from_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_from_excel .


  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
      i_line_header        = 'X' "Yüklenen excel dosyasında sütün isimlerimi alma.
      i_tab_raw_data       = gt_raw_data
      i_filename           = p_file
    TABLES
      i_tab_converted_data = gt_table
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  MOVE-CORRESPONDING gt_table TO gt_table_tmp.
  MODIFY zplayer FROM TABLE gt_table_tmp.
  COMMIT WORK AND WAIT.
  IF sy-subrc EQ 0.
    MESSAGE 'KAYITLAR ATILDI!' TYPE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_selected_players
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_selected_players.
  DATA: lt_rows TYPE lvc_t_row,
        ls_row  TYPE lvc_s_row,
        lv_index TYPE sy-tabix.


  CALL METHOD go_alv->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  LOOP AT lt_rows INTO ls_row.
    lv_index = ls_row-index.
    READ TABLE gt_alv INDEX lv_index ASSIGNING FIELD-SYMBOL(<fs>).
    IF sy-subrc = 0.
      " DB’den sil
      DELETE FROM zplayer_stats WHERE player_name = <fs>-player_name.
      DELETE FROM zplayer       WHERE player_name = <fs>-player_name.
    ENDIF.
  ENDLOOP.

  CALL METHOD go_alv->refresh_table_display.
  MESSAGE 'Seçilen oyuncular silindi' TYPE 'S'.
ENDFORM.