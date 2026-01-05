CLASS zcl_generate_data_ws DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_generate_data_ws IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DELETE FROM zaevent_ws.
    DELETE FROM zareg_ws.
    DELETE FROM zevent_ws_d.
    DELETE FROM zareg_ws_d.

    DATA: it_events TYPE TABLE OF zaevent_ws.
    DATA: it_registrations TYPE TABLE OF zareg_ws.

    TRY.
        DATA(lv_event_uuid) = cl_system_uuid=>create_uuid_x16_static( ).

        it_events = VALUE #(
            ( event_uuid     = lv_event_uuid
              event_id       = 'EV-001'
              title          = 'SAP RAP Workshop 2024'
              location       = 'Warszawa, Biuro SAP'
              start_date     = '20240520'
              end_date       = '20240522'
              status         = 'P' " Published
              max_seats      = 20
              occupied_seats = 0 )

            ( event_uuid     = cl_system_uuid=>create_uuid_x16_static( )
              event_id       = 'EV-002'
              title          = 'Frontend Fiori Summit'
              location       = 'Online (Teams)'
              start_date     = '20240615'
              end_date       = '20240615'
              status         = 'D' " Draft
              max_seats      = 500
              occupied_seats = 0 )

            ( event_uuid     = cl_system_uuid=>create_uuid_x16_static( )
              event_id       = 'EV-003'
              title          = 'AI in ABAP Cloud'
              location       = 'Kraków'
              start_date     = '20240901'
              end_date       = '20240905'
              status         = 'X' " Cancelled
              max_seats      = 10
              occupied_seats = 0 )
        ).

        it_registrations = VALUE #(
        ( regist_uuid   = cl_system_uuid=>create_uuid_x16_static( )
          event_uuid    = lv_event_uuid
          first_name    = 'Jan'
          last_name     = 'Kowalski'
          email         = 'jan.k@test.com'
          booking_date  = '20240901'
          ticket_code   = 'TICKET-001' )

        ( regist_uuid   = cl_system_uuid=>create_uuid_x16_static( )
          event_uuid    = lv_event_uuid
          first_name    = 'Anna'
          last_name     = 'Nowak'
          email         = 'anna.n@test.com'
          booking_date  = '20240902'
          ticket_code   = 'TICKET-002' )
        ).

      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

    INSERT zaevent_ws FROM TABLE @it_events.
    INSERT zareg_ws FROM TABLE @it_registrations.

    out->write( |Wstawiono { sy-dbcnt } rekordów do tabeli Event!| ).

  ENDMETHOD.
ENDCLASS.
