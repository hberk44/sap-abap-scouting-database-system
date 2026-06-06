
TABLES: zplayer_stats, zplayer.
CLASS lcl_event_handler DEFINITION DEFERRED.
DATA:
  go_alv  TYPE REF TO cl_gui_alv_grid,
  go_cont TYPE REF TO cl_gui_custom_container,
  go_event TYPE REF TO lcl_event_handler.

TYPES: BEGIN OF ty_alv,
         player_name     TYPE zplayer-player_name,
         player_age      TYPE zplayer-player_age,
         player_team     TYPE zplayer-player_team,
         player_position TYPE zplayer-player_position,
         player_nation   TYPE zplayer-player_nation,
         player_match    TYPE zplayer_stats-player_match,
         passes_all      TYPE zplayer_stats-passes_all,
         goals           TYPE zplayer_stats-goals,
         assists         TYPE zplayer_stats-assists,
         performance     TYPE zplayer_stats-performance,
         cell_clr        TYPE lvc_t_scol,
       END OF ty_alv.

DATA:
  gt_alv        TYPE TABLE OF ty_alv,
  gs_layout     TYPE lvc_s_layo,
  gs_cell_clr   TYPE lvc_s_scol,
  gt_fc         TYPE lvc_t_fcat,
  gs_fc          TYPE lvc_s_fcat.

TYPES: BEGIN OF gty_table,
  PLAYER_NAME        TYPE ZPLAYER_NAME_DE,
  PLAYER_AGE         TYPE ZPLAYER_AGE_DE,
  PLAYER_POSITION    TYPE ZPLAYER_POSITION_DE,
  PLAYER_TEAM        TYPE ZPLAYER_TEAM_DE,
  PLAYER_NATION      TYPE ZPLAYER_NATIONALITY_DE,
  player_match       TYPE zplayer_stats-player_match,
  passes_all         TYPE zplayer_stats-passes_all,
  goals              TYPE zplayer_stats-goals,
  assists            TYPE zplayer_stats-assists,
  performance        TYPE zplayer_stats-performance,

  END OF gty_table.

  DATA:gt_table TYPE TABLE OF gty_table,
       gt_raw_data TYPE TRUXS_T_TEXT_DATA.

DATA: GT_TABLE_TMP TYPE TABLE OF ZPLAYER.