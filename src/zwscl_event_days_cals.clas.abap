CLASS zcl_event_days_cals DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_event_days_cals IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    " 1. Sprawdź, czy framework prosi o obliczenie pola 'DAYSTOSTART'
    " (Nazwa pola musi być wielkimi literami)
    CHECK line_exists( it_requested_calc_elements[ table_line = 'DAYSTOSTART' ] ).

    " 2. Przygotowanie danych wejściowych
    " Tutaj pobieramy to, co zwrócił CDS (czyli surowe dane z bazy)
    DATA: lt_original_data TYPE STANDARD TABLE OF ZI_EVENT_WS WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).

    " 3. Pobranie daty systemowej w sposób bezpieczny dla chmury
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    " 4. Pętla po wierszach tabeli
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<ls_row>).

      " --- ZABEZPIECZENIE PRZED DUMPEM ---
      " Jeśli data startu jest pusta (00000000), nie wykonuj odejmowania!
      IF <ls_row>-StartDate IS INITIAL.
        <ls_row>-DaysToStart = ''. " Pusty tekst
        CONTINUE. " Idź do następnego wiersza
      ENDIF.

      " 5. Obliczenie różnicy dni
      DATA(lv_diff) = <ls_row>-StartDate - lv_today.

      " 6. Logika wyświetlania tekstu
      IF lv_diff = 0.
        <ls_row>-DaysToStart = 'Dzisiaj'.

      ELSEIF lv_diff < 0.
        <ls_row>-DaysToStart = 'Zakończone'.

      ELSE.
        " FORMATOWANIE: |...| pozwala wstawiać zmienne i spacje
        " Wynik np.: "Za 5 dni"
        <ls_row>-DaysToStart = |Za { lv_diff } dni|.
      ENDIF.

    ENDLOOP.

    " 7. Zwrócenie obliczonych danych do UI
    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    " Ta metoda mówi frameworkowi:
    " "Żeby obliczyć DAYSTOSTART, musisz najpierw pobrać z bazy STARTDATE"

    IF line_exists( it_requested_calc_elements[ table_line = 'DAYSTOSTART' ] ).
      APPEND 'STARTDATE' TO et_requested_orig_elements.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
