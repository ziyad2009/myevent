const String updateUser = r'''mutation updateProfile($fields: updateUserInput!)
{
  updateUser(input: $fields)
  {
    user{
      id
    __typename
    username
    email
    fullName
    phone
    shortBio
    __typename
    username
    email
    fullName
    phone
    shortBio
    aboutDescription
    facebookLink
    websiteLink
    profilePicture{
      id
      url
    }
    coverImage{
      id
      url
    }
    aboutDescription
    aboutImages{
      id
      url
    }
    }
  }
}''';

const String createUserAd = r'''mutation createAd($input: createUserAdInput!){
  createUserAd(input: $input) {
    userAd{
      id
    __typename
    title
    createdAt
    adStatus
    sellerDesignation
   seller
  {
    id
    __typename
    username
    email
    fullName
    phone
    shortBio
    firebaseID
    aboutDescription
    facebookLink
    websiteLink
    profilePicture{
      id
      url
    }
    coverImage{
      id
      url
    }
  }
    price
    description
    venueLat
    venueLon
    venueAddress
    accommodation
    area
    availableTill
    venueTypes{
      id
      typeName
      typeIcon{
        id
        url
      }
    }
    timeStart
    timeEnd
    perkList{
      id
      perkName
    }
    unavailableDates{
      id
      unavailable
    }
    adImages{
      id
      url
    }
    }
  }
}''';

const String createReview =
    r'''mutation createreview($fields: createReviewInput!)
{
  createReview(input: $fields)
  {
    review{
      id
      __typename
      content
      stars
      reviewer{
        id
      fullName
      username
      shortBio
      phone
      profilePicture{
        id
        url
      }
      }
    }
  }
}''';

const String updateUserAd =
    r'''mutation mutateSingleAd($field: updateUserAdInput!)
{
  updateUserAd(input: $field)
  {
    userAd{
       id
    __typename
    title
    createdAt
    adStatus
   seller
  {
    id
    __typename
    username
    email
    fullName
    phone
    shortBio
    aboutDescription
    facebookLink
    websiteLink
    profilePicture{
      id
      url
    }
    coverImage{
      id
      url
    }
  }
    price
    description
    accommodation
    area
    timeStart
    timeEnd
    venueLat
    venueLon
    venueAddress
    perkList{
      id
      perkName
    }
    venueTypes{
      id
      typeName
      typeIcon{
        id
        url
      }
    }
    adImages{
      id
      url
    }
    }
  }
}''';

const String createSupport =
    r'''mutation createsupport($field: createSupportInput!){
  createSupport(input: $field)
  {
    support{
      id
    }
  }
}''';

const String deleteAd = r'''mutation deleteuserad($field: deleteUserAdInput!) {
  deleteUserAd(input: $field)
  {
    userAd
    {
      id
    }
  }
}''';

const String deleteService =
    r'''mutation deleteServicead($field: deleteServiceInput!) {
  deleteService(input: $field)
  {
    service
    {
      id
    }
  }
}''';

const String createOfflineDate =
    r'''mutation offlineDate($field: createOfflineDateInput!) {
  createOfflineDate(input: $field){
    offlineDate{
      id
      unavailable
    }
  }
}''';

const String deleteOfflineDate =
    r'''mutation offlineDate($field: deleteOfflineDateInput!) {
  deleteOfflineDate(input: $field){
    offlineDate{
      id
      unavailable
    }
  }
}''';

const String createServiceAd =
    r'''mutation createServiceAd($input: createServiceInput!)
{
  createService(input: $input)
  {
    service{
      id
      __typename
      name
      description
      createdAt
      updatedAt
      perkList{
        id
        perkName
      }
    	isPremium
      serviceLat
      serviceLon
      serviceAddress
      pricePerDay
      provider
  		{
    	id
      __typename
      username
      email
      fullName
      phone
      shortBio
      firebaseID
      aboutDescription
      facebookLink
      websiteLink
      profilePicture{
      id
      url
    	}
    	coverImage{
      	id
      	url
    	}
  	}
    	servicePhotos{
        id
        url
      }
      serviceFeatureImage{
        id
        url
      }
      serviceVideo{
        id
        url
      }
    }
  }
}''';

const String updateService =
    r'''mutation updateServiceAd($input: updateServiceInput!)
{
  updateService(input: $input)
  {
    service{
      id
      __typename
      name
      description
      createdAt
      updatedAt
      perkList{
        id
        perkName
      }
    	isPremium
      serviceLat
      serviceLon
      serviceAddress
      pricePerDay
      provider
  		{
    	id
      __typename
      username
      email
      fullName
      phone
      shortBio
      firebaseID
      aboutDescription
      facebookLink
      websiteLink
      profilePicture{
      id
      url
    	}
    	coverImage{
      	id
      	url
    	}
  	}
    	servicePhotos{
        id
        url
      }
      serviceFeatureImage{
        id
        url
      }
      serviceVideo{
        id
        url
      }
    }
  }
}''';

const String createVenueBooking =
    r'''mutation createVenueBooking($field: createBookingInput!)
{
  createBooking(input: $field)
  {
    booking{
      id
    }
  }
}''';

const String createServiceBooking =
    r'''mutation createServiceBooking($field: createServiceBookingInput!)
{
  createServiceBooking(input: $field)
  {
    serviceBooking{
      id
    }
  }
}''';

const String updateServiceBooking =
    r'''mutation updateServiceBooking($field: updateServiceBookingInput!)
{
  updateServiceBooking(input: $field)
  {
    serviceBooking{
      id
    }
  }
}''';

const String updateVenueBooking =
    r'''mutation createVenueBooking($field: updateBookingInput!)
{
  updateBooking(input: $field)
  {
    booking{
      id
    }
  }
}''';

const String increaseVenueAdViewCount =
    r'''mutation increaseVenueViewCount($field: updateUserAdInput!)
{
  updateUserAd(input: $field)
  {
    userAd{
      id
    }
  }
}''';

const String increaseServiceAdViewCount =
    r'''mutation increaseServiceViewCount($field: updateServiceInput!)
{
  updateService(input: $field)
  {
    service{
      id
    }
  }
}''';
