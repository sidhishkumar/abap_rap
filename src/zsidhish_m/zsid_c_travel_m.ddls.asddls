@EndUserText.label: 'Travel Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZSID_C_TRAVEL_M
  provider contract transactional_query
  as projection on ZSID_I_TRAVEL_M
{
  key TravelId,
      @ObjectModel.text: {
          element: [ 'AgencyName' ]  }
      @Consumption.valueHelpDefinition: [{ entity.element: 'AgencyID' , entity.name: '/DMO/I_Agency'}]
      AgencyId,
      _Agency.Name       as AgencyName,
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity.element: 'CustomerID' , entity.name: '/DMO/I_Customer'}]

      CustomerId,
      _Customer.FirstName,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity.element: 'Currency' , entity.name: 'I_Currency'}]
      CurrencyCode,
      Description,
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      @Consumption.valueHelpDefinition: [{ entity.element: 'OverallStatus' , entity.name: '/DMO/I_Overall_Status_VH'}]
      OverallStatus,
      _Status._Text.Text as OverallStatusText : localized,
     
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZSID_C_BOOKING_M,
      _Currency,
      _Customer,
      _Status
}
