CLASS zcl_sid_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES : if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sid_data_generator IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DELETE FROM : zsid_db_travel,
                  zsid_db_booking,
                  zsid_db_bsuppl.

    COMMIT WORK AND WAIT.

    INSERT zsid_db_travel FROM (
       SELECT * FROM /dmo/travel_m
    ).

    INSERT zsid_db_booking FROM (
       SELECT * FROM /dmo/booking_m
    ).

    INSERT zsid_db_bsuppl FROM (
     SELECT * FROM /dmo/booksuppl_m
    ).

    COMMIT WORK AND WAIT.

  ENDMETHOD.

ENDCLASS.
