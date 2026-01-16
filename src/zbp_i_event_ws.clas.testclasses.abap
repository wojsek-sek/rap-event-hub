*"* use this source file for your ABAP unit test classes
CLASS ltc_event_tests DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA:
      co_bdef TYPE string VALUE 'ZI_EVENT_WS'.

    METHODS:
      validate_dates_error FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltc_event_tests IMPLEMENTATION.

  METHOD validate_dates_error.

    DATA(today) = cl_abap_context_info=>get_system_date( ).

    DATA: events_to_create TYPE TABLE FOR CREATE ZI_EVENT_WS.

    events_to_create = VALUE #( (
        %cid      = 'TEST_CID_1'
        EventId   = 'TEST-ERR'
        StartDate = today + 10
        EndDate   = today
        Status    = 'O'
    ) ).

    " Używamy EML (Entity Manipulation Language) - jakby user klikał w Fiori

    " (Create)
    MODIFY ENTITIES OF ZI_EVENT_WS
      ENTITY ZiEventWs
      CREATE FIELDS ( EventId StartDate EndDate Status )
      WITH events_to_create
      MAPPED   DATA(mapped)
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    " (Trigger Validations)
    COMMIT ENTITIES
      RESPONSE OF ZI_EVENT_WS
      FAILED   DATA(failed_commit)
      REPORTED DATA(reported_commit).

    " (Assert)

    cl_abap_unit_assert=>assert_not_initial(
      act = failed_commit-zieventws
      msg = 'System pozwolił zapisać błędne daty! Walidacja nie działa.'
    ).

  ENDMETHOD.

ENDCLASS.
