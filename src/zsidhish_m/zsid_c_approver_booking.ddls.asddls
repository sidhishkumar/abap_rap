@EndUserText.label: 'Approver Booking Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI.headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    typeImageUrl: 'www.google.com'


}
define view entity ZSID_C_APPROVER_BOOKING
  as projection on ZSID_I_BOOKING_M
{


  key TravelId,
      @UI.lineItem: [{ position: 10 }]
  key BookingId,
      @UI.lineItem: [{ position: 20 }]
      BookingDate,
      @UI.lineItem: [{ position: 30 }]
      CustomerId,
      @UI.lineItem: [{ position: 40 }]
      CarrierId,
      @UI.lineItem: [{ position: 50 }]
      ConnectionId,
      @UI.lineItem: [{ position: 60 }]
      FlightDate,
      @UI.lineItem: [{ position: 70 }]
      FlightPrice,
      @UI.lineItem: [{ position: 80 }]
      CurrencyCode,
      @UI.lineItem: [{ position: 90 }]
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement,
      _Carrier,
      _Connection,
      _Currency,
      _Customer,
      _Travel : redirected to parent ZSID_C_APPROVER_TRAVEL
}
