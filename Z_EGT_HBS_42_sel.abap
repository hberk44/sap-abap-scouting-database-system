SELECTION-SCREEN SKIP 5.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  s_pname  FOR zplayer_stats-player_name,
  s_pmatch FOR zplayer_stats-player_match,
  s_pass   FOR zplayer_stats-passes_all,
  s_goal   FOR zplayer_stats-goals,
  s_assist FOR zplayer_stats-assists,
  s_perf   FOR zplayer_stats-performance,
  s_page   FOR zplayer-player_age,
  s_pteam  FOR zplayer-player_team,
  s_posi   FOR zplayer-player_position,
  s_nation FOR zplayer-player_nation.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
  SELECTION-SCREEN PUSHBUTTON  /6(30) add USER-COMMAND add .
  SELECTION-SCREEN SKIP 1.
  SELECTION-SCREEN PUSHBUTTON  /6(30) del USER-COMMAND del.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF SCREEN 0200 AS WINDOW TITLE t0200.

  PARAMETERS: pi_name  TYPE zplayer-player_name,
              pi_age   TYPE zplayer-player_age,
              pi_team  TYPE zplayer-player_team,
              pi_posi  TYPE zplayer-player_position,
              pi_nat   TYPE zplayer-player_nation,
              pi_matc  TYPE zplayer_stats-player_match,
              pi_pass  TYPE zplayer_stats-passes_all,
              pi_goal  TYPE zplayer_stats-goals,
              pi_assi  TYPE zplayer_stats-assists.


SELECTION-SCREEN END OF SCREEN 0200.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
SELECTION-SCREEN SKIP 1.
  SELECTION-SCREEN PUSHBUTTON  /6(30) exc USER-COMMAND exc.
SELECTION-SCREEN END OF BLOCK b3.


SELECTION-SCREEN BEGIN OF SCREEN 0300 AS WINDOW TITLE text-003.
  SELECTION-SCREEN SKIP 1.
  PARAMETERS: p_file TYPE rlgrap-filename.

SELECTION-SCREEN END OF SCREEN 0300.


INITIALIZATION.
  add = 'Oyuncu Ekle/Add Player'.
  del = 'Oyuncu Sil/Delete Player'.
  exc = 'Excelden ekle/ Load from excel'.