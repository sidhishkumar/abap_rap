CLASS lhc_zsid_i_bsuppl_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zsid_i_bsuppl_m~calculateTotalPrice.

ENDCLASS.

CLASS lhc_zsid_i_bsuppl_m IMPLEMENTATION.

  METHOD calculateTotalPrice.

    DATA : li_travel TYPE STANDARD TABLE OF zsid_i_travel_m WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    li_travel = CORRESPONDING #( keys DISCARDING DUPLICATES  MAPPING TravelId = TravelId ).
     MODIFY ENTITIES OF zsid_i_travel_m IN LOCAL MODE
     ENTITY zsid_i_travel_m
     EXECUTE reCalculateTotPrice
     FROM CORRESPONDING #( li_travel ).


  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
