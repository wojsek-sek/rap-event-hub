CLASS zcl_fill_status_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_fill_status_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DELETE FROM zstatus_ws.
    DELETE FROM zstatus_txt_ws.

    DATA: lt_statuses TYPE TABLE OF zstatus_ws.
    lt_statuses = VALUE #(
      ( status_id = 'O' )
      ( status_id = 'X' )
      ( status_id = 'F' )
      ( status_id = 'D' )
    ).
    INSERT zstatus_ws FROM TABLE @lt_statuses.

    DATA: lt_texts TYPE TABLE OF zstatus_txt_ws.
    lt_texts = VALUE #(
      ( status_id = 'O' language = 'L' description = 'Otwarty' )
      ( status_id = 'X' language = 'L' description = 'Anulowany' )
      ( status_id = 'F' language = 'L' description = 'Zakończony' )
      ( status_id = 'D' language = 'L' description = 'Odmowiony' )
      ( status_id = 'O' language = 'E' description = 'Open' )
      ( status_id = 'X' language = 'E' description = 'Cancelled' )
      ( status_id = 'F' language = 'E' description = 'Finished' )
      ( status_id = 'D' language = 'E' description = 'Declined' )
    ).
    INSERT zstatus_txt_ws FROM TABLE @lt_texts.

    out->write( 'Dane konfiguracyjne zostały załadowane poprawnie.' ).

  ENDMETHOD.
ENDCLASS.
