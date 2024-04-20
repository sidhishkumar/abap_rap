CLASS zcl_sid_modify_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES : if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sid_modify_eml IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA li_book TYPE TABLE FOR CREATE zsid_i_travel_m\_Booking .

*    MODIFY ENTITY zsid_i_travel_m
*    CREATE FROM VALUE #( (
*
*     %cid = 'cid1'
*     %data-BeginDate = '20241212'
*     %control-BeginDate = if_abap_behv=>mk-on
*     ) )
*
*     CREATE BY \_Booking
*     FROM VALUE #( (
*
*      %cid_ref = 'cid1'
*      %target = VALUE #( ( %cid = 'cid11'
*                           %data-bookingdate = '20241111'
*                           %control-bookingdate = if_abap_behv=>mk-on
*                        )  )
*
*      ) )
*
*     FAILED FINAL(li_failed_final)
*     REPORTED FINAL(li_reported_final)
*     MAPPED FINAL(li_mapped_final).
*
*     COMMIT ENTITIES.
*
*    IF  li_failed_final IS NOT INITIAL.
*      out->write( li_failed_final ).
*
*    ENDIF.


*   Creating with auto fill CID but we can not used it with association
    MODIFY ENTITY zsid_i_travel_m
    CREATE AUTO FILL CID WITH VALUE #( (
     %data-BeginDate = '20241212'
     %control-BeginDate = if_abap_behv=>mk-on
     ) ).


* Delete Operations
    MODIFY ENTITY zsid_i_travel_m
    DELETE FROM VALUE #( ( %key-TravelId = '00004339' ) ( %key-TravelId = '00004340' ) )
    FAILED DATA(li_failed)
    MAPPED DATA(li_mapped)
    REPORTED DATA(li_reported).


* Update Entity

    MODIFY ENTITIES OF zsid_i_travel_m
    ENTITY zsid_i_travel_m
    UPDATE FIELDS ( begindate )
    WITH VALUE #( (
              %key-TravelId = '00004339'
              %data-BeginDate = '20231212'

     ) )
     MAPPED DATA(li_mapped_update)
     FAILED DATA(li_failed_update)
     REPORTED DATA(li_reported_update).

*   this form having the performance issue
    MODIFY ENTITY zsid_i_travel_m
    UPDATE SET FIELDS WITH
    VALUE #( ( %key-TravelId = '00004339'
              %data-BeginDate = '20231212'
           ) ).

    COMMIT ENTITIES.


  ENDMETHOD.

ENDCLASS.
