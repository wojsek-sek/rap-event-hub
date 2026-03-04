CLASS lhc_registration DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateOccupiedSeats FOR DETERMINE ON SAVE
      IMPORTING keys FOR Registration~calculateOccupiedSeats.
    METHODS validateAvability FOR VALIDATE ON SAVE
      IMPORTING keys FOR Registration~validateAvability.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Registration RESULT result.

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

  METHOD get_instance_features.
    READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
    ENTITY Registration BY \_Event
    FIELDS ( status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(events)
    LINK DATA(reg_links).

    LOOP AT reg_links INTO DATA(ls_child_key).
        DATA(lv_edit) = if_abap_behv=>fc-o-enabled.

        READ TABLE events INTO DATA(ls_event) WITH KEY %tky = ls_child_key-target-%tky.

        IF sy-subrc = 0 AND ls_event-Status = zif_event_status_ws=>status-cancelled.
            lv_edit = if_abap_behv=>fc-o-disabled.
        ENDIF.

        INSERT VALUE #(
            %tky = ls_child_key-source-%tky
            %update = lv_edit
            %delete = lv_edit
        ) INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS LHC_ZI_EVENT_WS DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      get_instance_authorizations FOR INSTANCE AUTHORIZATION IMPORTING keys
      REQUEST requested_authorizations FOR ziEventws RESULT result,
      validateDates FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZiEventWs~validateDates,
      initEventValues FOR DETERMINE ON MODIFY
            IMPORTING keys FOR ZiEventWs~initEventValues,
      get_instance_features FOR INSTANCE FEATURES
            IMPORTING keys REQUEST requested_features FOR ZiEventWs RESULT result,
      cancelEvent FOR MODIFY
            IMPORTING keys FOR ACTION ZiEventWs~cancelEvent RESULT result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
            IMPORTING REQUEST requested_authorizations FOR ZiEventWs RESULT result.

ENDCLASS.

CLASS LHC_ZI_EVENT_WS IMPLEMENTATION.

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
            FIELDS ( EventID OccupiedSeats MaxSeats )
            WITH CORRESPONDING #( keys )
            RESULT DATA(events).

         IF events IS NOT INITIAL.

            DATA lt_update TYPE TABLE FOR UPDATE ZI_EVENT_WS.
            DATA: lv_max_event_id TYPE zaevent_ws-event_id,
                  lv_next_id TYPE i.

            READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
                ENTITY ZiEventWs BY \_Registrations
                FROM CORRESPONDING #( events )
                RESULT DATA(registrations).

            MODIFY ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
                ENTITY ZiEventWs
                UPDATE
                FIELDS ( OccupiedSeats MaxSeats Status )
                WITH VALUE #(
                    FOR event IN events (
                        %tky = event-%tky
                        OccupiedSeats = lines( registrations )
                        MaxSeats      = cond #( when event-MaxSeats is initial
                                               then 10
                                               else event-MaxSeats )
                        Status        = zif_event_status_ws=>status-open
                     )
                    ).

            LOOP AT events INTO DATA(ls_event) WHERE EventID IS INITIAL.

             " Clean the retrieved MAX ID to keep only digits using Regex
             " This prevents dumps when encountering dirty data like 'evt-01'
              REPLACE ALL OCCURRENCES OF PCRE '[^0-9]' IN lv_max_event_id WITH ''.

              " Safely convert to integer and increment
              IF lv_max_event_id IS INITIAL.
                lv_next_id = 1.
              ELSE.
                lv_next_id = lv_max_event_id + 1.
              ENDIF.

              " Format the new ID with a standard prefix using String Templates
              " Example output: EVT-000002
              DATA(lv_formatted_id) = |EVT-{ lv_next_id WIDTH = 6 ALIGN = RIGHT PAD = '0' }|.

              " Add the formatted ID to the update table
              APPEND VALUE #( %tky    = ls_event-%tky
                              EventID = lv_formatted_id )
                     TO lt_update.
            ENDLOOP.

            " 3. Update the entities with the new EventID via EML (Entity Manipulation Language)
            IF lt_update IS NOT INITIAL.
              MODIFY ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
                     ENTITY ZiEventWs
                     UPDATE FIELDS ( EventID ) WITH lt_update
                     REPORTED DATA(ls_reported).

              LOOP AT ls_reported-zieventws INTO DATA(ls_msg).
                APPEND CORRESPONDING #( ls_msg ) TO reported-zieventws.
              ENDLOOP.
            ENDIF.
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
                    WHEN event-status = zif_event_status_ws=>status-cancelled
                    THEN if_abap_behv=>fc-o-disabled
                    ELSE if_abap_behv=>fc-o-enabled
                 )
                 %delete = COND #(
                    WHEN event-status = zif_event_status_ws=>status-cancelled OR event-status IS INITIAL
                    THEN if_abap_behv=>fc-o-enabled
                    ELSE if_abap_behv=>fc-o-disabled
                 )
                 %update = COND #(
                    WHEN event-status = zif_event_status_ws=>status-cancelled
                    THEN if_abap_behv=>fc-o-disabled
                    ELSE if_abap_behv=>fc-o-enabled
                 )
                 %assoc-_Registrations = COND #(
                    WHEN event-status = zif_event_status_ws=>status-cancelled
                    THEN if_abap_behv=>fc-o-disabled
                    ELSE if_abap_behv=>fc-o-enabled
                 )
               ) ).

  ENDMETHOD.

  METHOD cancelEvent.

    READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
    ENTITY ziEventws
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(events).

    result = VALUE #( FOR event IN events (
                         %tky   = event-%tky
                         %param = event
                      ) ).

    MODIFY ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
        ENTITY ziEventws
        UPDATE
        FIELDS ( status cancelreason )
        WITH VALUE #( FOR key IN keys (
                        %tky   = key-%tky
                        status = zif_event_status_ws=>status-cancelled
                        CancelReason = key-%param-reason
                     ) )
        FAILED failed
        REPORTED reported.

    ENDMETHOD.

  METHOD GET_INSTANCE_AUTHORIZATIONS.
    READ ENTITIES OF ZI_EVENT_WS IN LOCAL MODE
         ENTITY ziEventws
         FIELDS ( LOCALCreatedBy )
         WITH CORRESPONDING #( keys )
         RESULT DATA(events).

    LOOP AT events INTO DATA(event).
        DATA(lv_update_auth) = if_abap_behv=>auth-unauthorized.
        DATA(lv_delete_auth) = if_abap_behv=>auth-unauthorized.

        IF event-LocalCreatedBy IS INITIAL OR event-LocalCreatedBy = sy-uname.
            lv_update_auth = if_abap_behv=>auth-allowed.
            lv_delete_auth = if_abap_behv=>auth-allowed.
        ENDIF.

        APPEND VALUE #(
               %tky = event-%tky
               %update = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
                            THEN lv_update_auth
                            ELSE if_abap_behv=>auth-allowed )
               %delete = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
                            THEN lv_update_auth
                            ELSE if_abap_behv=>auth-allowed )
         ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.

    DATA(lv_create_auth) = if_abap_behv=>auth-allowed.

    "if pfcg_auth(...) = false -> lv_create_auth = unauthorized.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.

      IF lv_create_auth = if_abap_behv=>auth-allowed.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
      ENDIF.

    ENDIF.
  ENDMETHOD.


ENDCLASS.
