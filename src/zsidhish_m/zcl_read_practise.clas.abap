CLASS zcl_read_practise DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES : if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_read_practise IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.


*   Read case 1 Short Form  ******************************************
    READ ENTITY zsid_i_travel_m
         FROM VALUE #(  (  %key-TravelId = '4133'
                           %control = VALUE #( AgencyId   = if_abap_behv=>mk-on
                                               CustomerId = if_abap_behv=>mk-on
                                               BeginDate  = if_abap_behv=>mk-on
                                     )
                         )

                      )
         RESULT  DATA(li_result_short)
         FAILED DATA(li_failed_short).

    out->write( 'Read Case 1 Short form' ).
    IF  li_failed_short IS NOT INITIAL.
      out->write( 'Read Failed' ).
    ELSE.
      out->write( li_result_short ).
    ENDIF.

*   Read Case 2 Short form    ***************************************
    READ ENTITY zsid_i_travel_m
    FIELDS ( AgencyId CustomerId BeginDate )
    WITH VALUE #(  (  %key-TravelId = '4133' )  )
    RESULT  li_result_short
    FAILED li_failed_short.

    out->write( 'Read Case 2 Short form' ).
    IF  li_failed_short IS NOT INITIAL.
      out->write( 'Read Failed' ).
    ELSE.
      out->write( li_result_short ).
    ENDIF.

*   Read Case 3 Short Form    *****************************************
    READ ENTITY zsid_i_travel_m
    ALL FIELDS
    WITH VALUE #(  (  %key-TravelId = '4133' ) (  %key-TravelId = '4132' ) )
    RESULT  li_result_short
    FAILED li_failed_short.


    out->write( 'Read Case 3 Short form' ).
    IF  li_failed_short IS NOT INITIAL.
      out->write( 'Read Failed' ).
    ELSE.
      out->write( li_result_short ).
    ENDIF.

*   Read Short form with Association *******************************
    READ ENTITY zsid_i_travel_m
    BY \_Booking
    ALL FIELDS
    WITH VALUE #(  (  %key-TravelId = '4133' ) (  %key-TravelId = '4132' ) )
    RESULT  DATA(li_result_short_asso)
    FAILED li_failed_short.


    out->write( 'Read Short form with Association' ).
    IF  li_failed_short IS NOT INITIAL.
      out->write( 'Read Failed' ).
    ELSE.
      out->write( li_result_short_asso ).
    ENDIF.

**********************************************************************
*   dynamic multiple entities -- 1
    DATA : li_optab  TYPE abp_behv_retrievals_tab,
           li_travel TYPE TABLE FOR READ IMPORT zsid_i_travel_m,
           li_result TYPE TABLE FOR READ RESULT zsid_i_travel_m.

    out->write( 'Read table Dynamically' ).
    li_travel = VALUE #( (  %key-TravelId = '4133'
                    %control = VALUE #( AgencyId   = if_abap_behv=>mk-on
                                        CustomerId = if_abap_behv=>mk-on
                                        BeginDate  = if_abap_behv=>mk-on
                              )
                  )

               ).


    li_optab = VALUE #( ( op = if_abap_behv=>op-r
                          entity_name = 'ZSID_I_TRAVEL_M'
                          instances = REF #( li_travel )
                          results   = REF #( li_result )

    ) ).

    READ ENTITIES
    OPERATIONS li_optab
    FAILED DATA(li_failed_dy).


    IF  li_failed_dy IS NOT INITIAL.
      out->write( 'Read Failed dynamic' ).
    ELSE.
      out->write( li_result ).
    ENDIF.


******************************************************
    out->write( 'Read Dynamic Assocication' ).
    DATA : li_booking        TYPE TABLE FOR READ IMPORT zsid_i_travel_m\_Booking,
           li_booking_result TYPE TABLE FOR READ RESULT zsid_i_travel_m\_Booking.

    CLEAR : li_travel, li_optab, li_failed_dy.

    li_travel = VALUE #( (  %key-TravelId = '4133'
                        %control = VALUE #( AgencyId   = if_abap_behv=>mk-on
                                            CustomerId = if_abap_behv=>mk-on
                                            BeginDate  = if_abap_behv=>mk-on
                                  )
                      )

                   ).
    li_booking = VALUE #( (  %key-TravelId = '4133'

                        %control = VALUE #( TravelId   = if_abap_behv=>mk-on
                                            CustomerId = if_abap_behv=>mk-on
                                            BookingId  = if_abap_behv=>mk-on
                                            FlightDate  = if_abap_behv=>mk-on
                                  )
                      )

                   ).

    li_optab = VALUE #( ( op = if_abap_behv=>op-r
                          entity_name = 'ZSID_I_TRAVEL_M'
                          instances = REF #( li_travel )
                          results   = REF #( li_result )
                          )

                         ( op = if_abap_behv=>op-r-read_ba
                          entity_name = 'ZSID_I_TRAVEL_M'
                          sub_name    = '_BOOKING'
                          instances = REF #( li_booking )
                          results   = REF #( li_booking_result )
                          )
    ).

    READ ENTITIES
    OPERATIONS li_optab
    FAILED li_failed_dy.


    IF  li_failed_dy IS NOT INITIAL.
      out->write( 'Read Failed dynamic' ).
    ELSE.
      out->write( li_result ).
      out->write( li_booking_result ).
    ENDIF.


  ENDMETHOD.

ENDCLASS.
