CLASS lhc_registration DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateOccupiedSeats FOR DETERMINE ON SAVE
      IMPORTING keys FOR Registration~calculateOccupiedSeats.
    METHODS validateAvability FOR VALIDATE ON SAVE
      IMPORTING keys FOR Registration~validateAvability.

ENDCLASS.

CLASS lhc_registration IMPLEMENTATION.

  METHOD calculateOccupiedSeats.

  READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
    ENTITY Registration BY \_Event
    FROM CORRESPONDING #( keys )
    RESULT DATA(events).

   SORT events BY eventuuid.
   DELETE ADJACENT DUPLICATES FROM events COMPARING eventuuid.

   LOOP AT events INTO DATA(event).

    "Liczymy rejestracji dla tego konkretnego Eventu
    "Czytamy relację (Event -> Rejestracje)
    READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
      ENTITY ZiEventws BY \_Registrations
      FROM VALUE #( ( %tky = event-%tky ) )
      RESULT DATA(registrations).

    "Aktualizuj licznik w Evencie
    MODIFY ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
      ENTITY ziEventws
      UPDATE
      FIELDS ( occupiedSeats )
      WITH VALUE #( ( %tky           = event-%tky
                      occupiedSeats = lines( registrations ) ) ). " lines() zwraca liczbę wierszy

  ENDLOOP.

  ENDMETHOD.

  METHOD validateAvability.

     READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
        ENTITY Registration
        BY \_EVENT
        FIELDS ( OccupiedSeats MaxSeats )
        WITH CORRESPONDING #( keys )
        RESULT DATA(events)
        LINK DATA(reg_event_links).

        IF events IS NOT INITIAL.
            LOOP AT events INTO DATA(event).
                IF event-MaxSeats > 0 AND ( event-OccupiedSeats + 1 > event-MaxSeats ).
                    LOOP AT reg_event_links INTO DATA(link_reg) WHERE target-%tky = event-%tky.
                        APPEND VALUE #( %tky = link_reg-source-%tky ) TO failed-registration.

                        APPEND VALUE #(
                         %tky = link_reg-source-%tky
                         %msg = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text = |Brak wolnych miejsc w wydarzeniu { event-Title }!|
                            )
                         ) TO reported-registration.

                    ENDLOOP.
                ENDIF.
            ENDLOOP.
        ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS LHC_ZI_EVENT_WS DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZiEventWs
        RESULT result,
      validateDates FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZiEventWs~validateDates,
      initEventValues FOR DETERMINE ON MODIFY
            IMPORTING keys FOR ZiEventWs~initEventValues,
      get_instance_features FOR INSTANCE FEATURES
            IMPORTING keys REQUEST requested_features FOR ZiEventWs RESULT result.

          METHODS cancelEvent FOR MODIFY
            IMPORTING keys FOR ACTION ZiEventWs~cancelEvent RESULT result.
ENDCLASS.

CLASS LHC_ZI_EVENT_WS IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD validateDates.

  READ ENTITIES OF ZI_Event_WS IN LOCAL MODE
       ENTITY ZiEventWs
       FIELDS ( startDate endDate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(events).

  LOOP AT events INTO DATA(event).

    IF event-endDate < event-startDate.

      APPEND VALUE #( %tky = event-%tky ) TO failed-zieventws.

      "wiadomość do UI (REPORTED) - to wyświetla popup/tekst
      APPEND VALUE #( %tky               = event-%tky
                      %state_area        = 'VALIDATE_DATES' " Identyfikator czyszczenia błędów
                      %msg               = new_message_with_text(
                                             severity = if_abap_behv_message=>severity-error
                                             text     = 'Data zakończenia musi być późniejsza niż data rozpoczęcia!'
                                           )
                      %element-startDate = if_abap_behv=>mk-on " Podświetl pole na czerwono
                      %element-endDate   = if_abap_behv=>mk-on
                    ) TO reported-zieventws.

    ENDIF.
  ENDLOOP.

  ENDMETHOD.

  METHOD initEventValues.

        READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
            ENTITY ZiEventWS
            FIELDS ( OccupiedSeats MaxSeats )
            WITH CORRESPONDING #( keys )
            RESULT DATA(events).

         IF events IS NOT INITIAL.

            READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
                ENTITY ZiEventWs BY \_Registrations
                FROM CORRESPONDING #( events )
                RESULT DATA(registrations).

            MODIFY ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
                ENTITY ZiEventWs
                UPDATE
                FIELDS ( OccupiedSeats MaxSeats )
                WITH VALUE #(
                    FOR event IN events (
                        %tky = event-%tky
                        OccupiedSeats = lines( registrations )
                        MaxSeats      = cond #( when event-MaxSeats is initial
                                               then 10
                                               else event-MaxSeats )
                     )
                    ).

         ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.

  READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
      ENTITY ziEventws
      FIELDS ( status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(events).

      "ENABLED / DISABLED
      result = VALUE #( FOR event IN events (
                 %tky = event-%tky
                 %action-cancelEvent = COND #(
                    WHEN event-status = 'X'
                    THEN if_abap_behv=>fc-o-disabled
                    ELSE if_abap_behv=>fc-o-enabled
                 )
               ) ).
  ENDMETHOD.

  METHOD cancelEvent.

    MODIFY ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
        ENTITY ziEventws
        UPDATE
        FIELDS ( status )
        WITH VALUE #( FOR key IN keys (
                        %tky   = key-%tky
                        status = 'X'
                     ) )
        FAILED failed
        REPORTED reported.

      READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
        ENTITY ziEventws
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(events).

      " 3. Przekazanie wyniku do frameworka
      result = VALUE #( FOR event IN events (
                          %tky   = event-%tky
                          %param = event
                       ) ).
  ENDMETHOD.

ENDCLASS.
