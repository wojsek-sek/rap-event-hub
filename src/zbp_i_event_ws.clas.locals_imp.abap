CLASS lhc_registration DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateOccupiedSeats FOR DETERMINE ON SAVE
      IMPORTING keys FOR Registration~calculateOccupiedSeats.

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

ENDCLASS.

CLASS LHC_ZI_EVENT_WS DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZiEventWs
        RESULT result,
      validateDates FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZiEventWs~validateDates.
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

ENDCLASS.
