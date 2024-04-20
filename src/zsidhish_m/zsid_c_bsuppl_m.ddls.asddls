@EndUserText.label: 'Booking Supplement Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZSID_C_BSUPPL_M
  as projection on ZSID_I_BSUPPL_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: [ 'SupplementDescription' ]
      SupplementId,
      _SupplementText.Description as SupplementDescription : localized,
      Price,
      @Consumption.valueHelpDefinition: [{ entity.element: 'Currency' , entity.name: 'I_Currency'}]
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZSID_C_BOOKING_M,
      _Supplement,
      _SupplementText,
      _Travel  : redirected to ZSID_C_TRAVEL_M
}
