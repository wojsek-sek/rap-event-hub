CLASS zcl_fill_timeframe_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fill_timeframe_data IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DELETE FROM ZTFRAME_WS.
    DELETE FROM ZTFRAME_WS_TXT.

    DATA: lt_tframe TYPE TABLE OF ZTFRAME_WS.

    lt_tframe = VALUE #(
    ( time = 'PAST' )
    ( time = 'TODAY' )
    ( time = 'PFX' )
    ( time = 'SFX' )
     ).

     INSERT ztframe_ws FROM TABLE @lt_tframe.

     DATA lt_tframe_txt TYPE TABLE OF ZTFRAME_WS_TXT.

     lt_tframe_txt = VALUE #(
     ( time_code = 'PAST'  language = 'L' text = 'Zakończony' )
     ( time_code = 'TODAY' language = 'L' text = 'DZIŚ!' )
     ( time_code = 'PFX'   language = 'L' text = 'Za ' )
     ( time_code = 'SFX'   language = 'L' text = ' dni' )
     ( time_code = 'PAST'  language = 'E' text = 'Finished' )
     ( time_code = 'TODAY' language = 'E' text = 'TODAY!' )
     ( time_code = 'PFX'   language = 'E' text = 'In ' )
     ( time_code = 'SFX'   language = 'E' text = ' days' )
     ).

     INSERT ztframe_ws_txt FROM TABLE @lt_tframe_txt.

     out->write( 'Dane wygenerowane' ).


  ENDMETHOD.
ENDCLASS.
