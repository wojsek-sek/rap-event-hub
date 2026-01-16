CLASS zcl_event_stats_query_ws DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_event_stats_query_ws IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_results TYPE TABLE OF ZI_EVENT_STATS_WS.

      SELECT FROM zaevent_ws
        FIELDS status, COUNT( * ) AS eventcount
        GROUP BY status
        INTO CORRESPONDING FIELDS OF TABLE @lt_results.

      DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
      DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).

      io_response->set_data( lt_results ).

    ENDIF.

    IF io_request->IS_TOTAL_NUMB_OF_REC_REQUESTED( ).

      SELECT FROM zaevent_ws
        FIELDS status
        GROUP BY status
        INTO TABLE @DATA(lt_groups).

      io_response->set_total_number_of_records( lines( lt_groups ) ).

    ENDIF.
  ENDMETHOD.
ENDCLASS.
