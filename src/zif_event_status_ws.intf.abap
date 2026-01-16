INTERFACE zif_event_status_ws
  PUBLIC .

  CONSTANTS:
    BEGIN OF status,
      open      TYPE c LENGTH 1 VALUE 'O', " Otwarty
      full      TYPE c LENGTH 1 VALUE 'F', " Pełny
      done      TYPE c LENGTH 1 VALUE 'D', " Zakończony
      cancelled TYPE c LENGTH 1 VALUE 'X', " Anulowany
    END OF status.

ENDINTERFACE.
