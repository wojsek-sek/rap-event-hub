CLASS zcl_setup_num_range_ws DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_setup_num_range_ws IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lv_object TYPE c LENGTH 10 VALUE 'ZNR_EID_WS'.

    TRY.

        cl_numberrange_intervals=>create(
          EXPORTING
            object    = lv_object
            interval = VALUE #( ( nrrangenr  = '01'
                                   fromnumber = '00000001'
                                   tonumber   = '99999999'
                                   procind    = 'I' ) )
        ).

        out->write( 'Sukces! Przedział 01 został utworzony.' ).

      CATCH cx_number_ranges INTO DATA(lx_range).
        out->write( |Błąd: { lx_range->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
