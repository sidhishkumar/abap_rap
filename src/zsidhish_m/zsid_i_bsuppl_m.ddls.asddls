@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZSID_I_BSUPPL_M
  as select from zsid_db_bsuppl
  association        to parent ZSID_I_BOOKING_M as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                   and $projection.BookingId = _Booking.BookingId
  association [1..1] to /DMO/I_Supplement       as _Supplement     on  $projection.SupplementId = _Supplement.SupplementID
  association [*]    to /DMO/I_SupplementText   as _SupplementText on  $projection.SupplementId     = _SupplementText.SupplementID
                                                                   

  association [1]    to ZSID_I_TRAVEL_M         as _Travel         on  $projection.TravelId = _Travel.TravelId
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Supplement,
      _SupplementText,
      _Booking,
      _Travel
}
