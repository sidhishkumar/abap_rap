CLASS lhc_ZSID_I_TRAVEL_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys
      REQUEST requested_authorizations
      FOR zsid_i_travel_m RESULT result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zsid_i_travel_m~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zsid_i_travel_m~copytravel.

    METHODS recalculatetotprice FOR MODIFY
      IMPORTING keys FOR ACTION zsid_i_travel_m~recalculatetotprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zsid_i_travel_m~rejecttravel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zsid_i_travel_m RESULT result.
    METHODS validate_customer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zsid_i_travel_m~validate_customer.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zsid_i_travel_m~calculatetotalprice.
    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zsid_i_travel_m\_booking.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zsid_i_travel_m.

ENDCLASS.

CLASS lhc_ZSID_I_TRAVEL_M IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lt_entities) = entities .
    DELETE lt_entities WHERE TravelId IS NOT INITIAL.

    DATA : li_travel_m TYPE TABLE FOR MAPPED EARLY zsid_i_travel_m,
           ls_travel_m LIKE LINE OF li_travel_m.

    DATA(lv_qty) = lines( lt_entities ).
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            =  '/DMO/TRV_M'
            quantity          =  CONV #( lv_qty )
          IMPORTING
            number            =  DATA(lv_number)
            returncode        =  DATA(lv_code)
            returned_quantity =  DATA(lv_return_quantity)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).

        LOOP AT entities INTO DATA(ls_entity).

          APPEND VALUE #( %cid = ls_entity-%cid
                          %key = ls_entity-%key
           )
           TO  mapped-zsid_i_travel_m.

          APPEND VALUE #( %cid = ls_entity-%cid
                          %msg = lo_error
           ) TO reported-zsid_i_travel_m.

        ENDLOOP.
        EXIT.
    ENDTRY.
    ASSERT lv_return_quantity = lv_qty.


    DATA(lv_current_number) = lv_number - lv_qty.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).
      lv_current_number = lv_current_number + 1.
      ls_travel_m = VALUE #( %cid = <fs_entity>-%cid TravelId = lv_current_number ).

      APPEND ls_travel_m TO mapped-zsid_i_travel_m.
    ENDLOOP.

  ENDMETHOD.


  METHOD earlynumbering_cba_Booking.

    DATA : li_booking     TYPE TABLE FOR CREATE zsid_i_travel_m\_booking,
           lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m BY \_Booking
    FROM CORRESPONDING #( entities )
    LINK DATA(li_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_group_entity>)
                         GROUP BY <fs_group_entity>-travelid.

      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                                   FOR ls_link IN li_link_data USING KEY entity
                                       WHERE ( source-travelid = <fs_group_entity>-travelid  )
                                   NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
                                                                       THEN ls_link-target-BookingId
                                                                       ELSE lv_max )

        ).

      lv_max_booking = REDUCE #( INIT lv_max = lv_max_booking
                                 FOR ls_entity IN entities USING KEY entity
                                 WHERE ( travelid = <fs_group_entity>-travelid  )
                                  FOR ls_booking IN ls_entity-%target
                                 NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_booking-BookingId
                                                                       THEN ls_booking-BookingId
                                                                       ELSE lv_max )

     ).


      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>)
                                      USING KEY entity
                                      WHERE TravelId = <fs_group_entity>-TravelId.
        LOOP AT  <ls_entity>-%target ASSIGNING FIELD-SYMBOL(<ls_booking>) .
          APPEND CORRESPONDING #( <ls_booking> ) TO mapped-zsid_i_booking_m
            ASSIGNING FIELD-SYMBOL(<ls_map_new_booking>).
          IF <ls_booking>-BookingId IS INITIAL.
            lv_max_booking += 10.
            <ls_map_new_booking>-BookingId = lv_max_booking.

          ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.



  METHOD copyTravel.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_without_cid>) WITH KEY %cid = ''.
    ASSERT <ls_without_cid> IS NOT ASSIGNED.

    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(li_travel_read)
    FAILED DATA(li_travel_failled).

    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m BY \_Booking
    ALL FIELDS WITH
    CORRESPONDING #( li_travel_read )
    RESULT DATA(li_booking_read)
    FAILED DATA(li_booking_failed).

    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_booking_m BY \_BookingSupplement
    ALL FIELDS WITH CORRESPONDING #( li_booking_read )
    RESULT DATA(li_bsuppl_read)
    FAILED DATA(li_failled_suppl).


    DATA : li_travel  TYPE TABLE FOR CREATE zsid_i_travel_m,
           li_booking TYPE TABLE FOR CREATE zsid_i_travel_m\_Booking,
           li_bsuppl  TYPE TABLE FOR CREATE zsid_i_booking_m\_BookingSupplement.

    LOOP AT li_travel_read ASSIGNING FIELD-SYMBOL(<ls_travel_r>).

*      APPEND INITIAL LINE TO li_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
*      <ls_travel>-%cid = keys[ KEY entity TravelId = <ls_travel_r>-%key-TravelId ]-%cid.
*      <ls_travel>-%data = CORRESPONDING #( <ls_travel_r> except TravelId ).

      APPEND VALUE #( %cid = keys[ KEY entity TravelId = <ls_travel_r>-%key-TravelId ]-%cid
                      %data = CORRESPONDING #( <ls_travel_r> EXCEPT TravelId )
       ) TO li_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-EndDate  = cl_abap_context_info=>get_system_date(  ) + 30.
      <ls_travel>-OverallStatus = 'O'.


*      Filling booking table via association
      APPEND VALUE #( %cid_ref = <ls_travel>-%cid )
      TO li_booking ASSIGNING FIELD-SYMBOL(<ls_booking>).

      LOOP AT li_booking_read ASSIGNING FIELD-SYMBOL(<ls_booking_read>)
                                        USING KEY entity
                                        WHERE TravelId = <ls_travel_r>-TravelId .


        APPEND VALUE #(  %cid = <ls_travel>-%cid && <ls_booking_read>-BookingId
                          %data = CORRESPONDING #( <ls_booking_read> EXCEPT travelid )

         ) TO <ls_booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_n>).
        <ls_booking_n>-BookingStatus = 'N'.

*       Filling Booking Supplement
        APPEND VALUE #( %cid_ref = <ls_booking_n>-%cid )
        TO li_bsuppl ASSIGNING FIELD-SYMBOL(<ls_booking_supplement>).

        LOOP AT li_bsuppl_read ASSIGNING FIELD-SYMBOL(<bsuppl>)
                          USING KEY entity
                          WHERE TravelId = <ls_booking_read>-TravelId
                          AND BookingId =  <ls_booking_read>-BookingId.
          APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_read>-BookingId && <bsuppl>-BookingSupplementId
                          %data = CORRESPONDING #( <bsuppl> EXCEPT TravelId BookingId )
           ) TO <ls_booking_supplement>-%target.

        ENDLOOP.


      ENDLOOP.
    ENDLOOP.



    MODIFY ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m
    CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description  )
    WITH li_travel

    ENTITY zsid_i_travel_m
    CREATE BY \_Booking
    FIELDS ( BookingId BookingDate ConnectionId CarrierId  FlightDate FlightPrice CurrencyCode BookingStatus )
    WITH li_booking

    ENTITY zsid_i_booking_m
    CREATE BY \_BookingSupplement
    FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
    WITH li_bsuppl
    MAPPED DATA(li_mapped).

    mapped-zsid_i_travel_m = li_mapped-zsid_i_travel_m.





  ENDMETHOD.

  METHOD reCalculateTotPrice.

    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(li_travel).

    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m BY \_Booking
    FIELDS ( FlightPrice CurrencyCode )
    WITH CORRESPONDING #( li_travel )
    RESULT DATA(li_booking).


    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_booking_m BY \_BookingSupplement
    FIELDS ( Price CurrencyCode )
    WITH CORRESPONDING #( li_booking )
    RESULT DATA(li_bsupplement).

    TYPES : BEGIN OF ty_total,
            price TYPE /dmo/price,
            curr TYPE /dmo/currency_code,
            END OF ty_total.

    data : li_total TYPE TABLE of ty_total.

    LOOP AT li_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).



    ENDLOOP.


  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF zsid_i_travel_m IN LOCAL MODE
     ENTITY zsid_i_travel_m
     UPDATE FIELDS ( OverallStatus )
     WITH VALUE #( FOR ls_key IN keys (  %tky = ls_key-%tky
                                         %data-OverallStatus = 'X'
     )  )
     REPORTED DATA(li_reported).


    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m
    ALL FIELDS WITH
    CORRESPONDING #( keys  )
    RESULT DATA(li_travel).

    result = VALUE #( FOR ls_travel IN li_travel ( %tky = ls_travel-%tky
                                                   %param = ls_travel ) ).
  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_key IN keys (  %tky = ls_key-%tky
                                        %data-OverallStatus = 'A'
    )  )
    REPORTED DATA(li_reported).


    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m
    ALL FIELDS WITH
    CORRESPONDING #( keys  )
    RESULT DATA(li_travel).

    result = VALUE #( FOR ls_travel IN li_travel ( %tky = ls_travel-%tky
                                                   %param = ls_travel ) ).




  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(li_result_travel).

    result = VALUE #( FOR ls_travel IN li_result_travel
                       ( %tky = ls_travel-%tky
                         %features-%action-acceptTravel = COND #( WHEN  ls_travel-OverallStatus = 'A'
                                                                         THEN if_abap_behv=>fc-o-disabled
                                                                        ELSE  if_abap_behv=>fc-o-enabled )
                         %features-%action-rejectTravel = COND #( WHEN  ls_travel-OverallStatus = 'X'
                                                                         THEN if_abap_behv=>fc-o-disabled
                                                                        ELSE  if_abap_behv=>fc-o-enabled )
                         %features-%assoc-_Booking      = COND #( WHEN  ls_travel-OverallStatus = 'X'
                                                                         THEN if_abap_behv=>fc-o-disabled
                                                                        ELSE  if_abap_behv=>fc-o-enabled )

                       )

                    ).


  ENDMETHOD.

  METHOD validate_customer.


    READ ENTITY IN LOCAL MODE zsid_i_travel_m
    FIELDS ( TravelId CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(li_travel).

    DATA : li_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.


    li_cust = CORRESPONDING #( li_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).
    DELETE li_cust WHERE customer_id IS INITIAL.
    SELECT
    FROM /dmo/customer
    FIELDS customer_id
    FOR ALL ENTRIES IN @li_travel
    WHERE customer_id = @li_travel-CustomerId
    INTO TABLE @DATA(li_cust_db).
    IF sy-subrc IS INITIAL.
    ENDIF.
    LOOP AT li_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-CustomerId IS INITIAL
       OR NOT line_exists( li_cust_db[ customer_id = <ls_travel>-CustomerId ]  ).

        APPEND VALUE #( %tky = <ls_travel>-%tky ) TO failed-zsid_i_travel_m.

        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages( textid       = /dmo/cm_flight_messages=>customer_unkown
                                                             customer_id = <ls_travel>-CustomerId
                                                             severity    = if_abap_behv_message=>severity-error )
                        %element-customerId = if_abap_behv=>mk-on
         )
        TO reported-zsid_i_travel_m.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculateTotalPrice.
    MODIFY ENTITIES OF zsid_i_travel_m IN LOCAL MODE
    ENTITY zsid_i_travel_m
    EXECUTE reCalculateTotPrice
    FROM CORRESPONDING #( keys ).
  ENDMETHOD.

ENDCLASS.
