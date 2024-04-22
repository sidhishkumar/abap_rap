CLASS lhc_zsid_i_booking_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zsid_i_booking_m\_Bookingsupplement.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zsid_i_booking_m RESULT result.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zsid_i_booking_m~calculatetotalprice.

ENDCLASS.

CLASS lhc_zsid_i_booking_m IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_booking_m BY \_BookingSupplement
    FROM CORRESPONDING #( entities )
    LINK DATA(li_link_data).


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>)
                         GROUP BY <booking_group>-%tky.


*     get highest booking supplement id from DB for the corresponding booking
      DATA(lv_max_booking_supplement) =  REDUCE #( INIT lv_max = CONV /dmo/booking_supplement_id( 0 )
                                                 FOR ls_entity IN li_link_data USING KEY entity
                                                 WHERE (     source-TravelId = <booking_group>-TravelId
                                                         AND source-BookingId = <booking_group>-BookingId )
                                                   NEXT lv_max = COND /dmo/booking_supplement_id( WHEN ls_entity-target-BookingSupplementId > lv_max
                                                                                                        THEN ls_entity-target-BookingSupplementId
                                                                                                        ELSE lv_max )


             ) .


*      Get highest booking supplement id from the incoming entities
      lv_max_booking_supplement =  REDUCE #( INIT lv_max = lv_max_booking_supplement
                                             FOR entity IN entities USING KEY entity
                                                                    WHERE ( TravelId     = <booking_group>-TravelId
                                                                           AND BookingId = <booking_group>-BookingId )
                                              FOR target IN entity-%target
                                              NEXT lv_max = COND /dmo/booking_supplement_id( WHEN target-BookingSupplementId > lv_max
                                                                                                  THEN  target-BookingSupplementId
                                                                                                  ELSE lv_max )


       ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>)
                                 USING KEY entity
                                 WHERE TravelId = <booking_group>-%tky-TravelId
                                 AND BookingId = <booking_group>-%tky-BookingId .

        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booking_supplement>).

          APPEND CORRESPONDING #( <booking_supplement> ) TO mapped-zsid_i_bsuppl_m ASSIGNING FIELD-SYMBOL(<mapped_booking_supp>).
          IF <mapped_booking_supp>-BookingSupplementId IS INITIAL.
            lv_max_booking_supplement += 1.
            <mapped_booking_supp>-BookingSupplementId = lv_max_booking_supplement.

          ENDIF.

        ENDLOOP.


      ENDLOOP.


    ENDLOOP.



  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m BY \_Booking
    FIELDS ( TravelId BookingId BookingStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(li_booking_result).

    result = VALUE #( FOR ls_result IN li_booking_result (
                         %tky = ls_result-%tky
                         %features-%assoc-_BookingSupplement = COND #( WHEN  ls_result-BookingStatus = 'X'
                                                                         THEN if_abap_behv=>fc-o-disabled
                                                                        ELSE  if_abap_behv=>fc-o-enabled )

    )  ).


  ENDMETHOD.

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
