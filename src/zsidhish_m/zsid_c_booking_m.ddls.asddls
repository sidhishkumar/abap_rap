@EndUserText.label: 'Booking projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZSID_C_BOOKING_M
  as projection on ZSID_I_BOOKING_M
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'LastName' ]
      @Consumption.valueHelpDefinition: [{ entity.element: 'CustomerID' , entity.name: '/DMO/I_Customer'}]
      CustomerId,
      _Customer.LastName,
      @ObjectModel.text.element: [ 'Name' ]
      @Consumption.valueHelpDefinition: [{ entity.element: 'AirlineID' , entity.name: '/DMO/I_Carrier'}]
      CarrierId,
      _Carrier.Name,
      @Consumption.valueHelpDefinition: [{ entity.element: 'ConnectionID' , entity.name: '/DMO/I_Flight',
                                            additionalBinding: [{ element: 'ConnectionID' , localElement: 'ConnectionId'},
                                                                { element: 'AirlineID', localElement: 'CarrierId'},
                                                                { element: 'CurrencyCode', localElement: 'CurrencyCode'}

                                            ]

      }]
      ConnectionId,
      @Consumption.valueHelpDefinition: [{ entity.element: 'FlightDate' , entity.name: '/DMO/I_Flight'}]
      FlightDate,
      FlightPrice,
      @Consumption.valueHelpDefinition: [{ entity.element: 'Currency' , entity.name: 'I_Currency'}]
      CurrencyCode,
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      @Consumption.valueHelpDefinition: [{ entity.element: 'OverallStatus' , entity.name: '/DMO/I_Overall_Status_VH'}]
      BookingStatus,
      _BookingStatus._Text.Text as BookingStatusText : localized,
      LastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement : redirected to composition child ZSID_C_BSUPPL_M,
      _Carrier,
      _Connection,
      _Currency,
      _Customer,
      _Travel            : redirected to parent ZSID_C_TRAVEL_M
}
