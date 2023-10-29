import 'package:get_it/get_it.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/filters_service.dart';
import 'package:myevents/backend/notification_api.dart';
import 'package:myevents/models/ad_dir_model.dart';
import 'package:myevents/models/ad_edit_model.dart';
import 'package:myevents/models/banquet_model.dart';
import 'package:myevents/models/booking_models/create_booking_model.dart';
import 'package:myevents/models/dir_page_model.dart';
import 'package:myevents/models/dynamic_tabs/dynamic_tab_model.dart';
import 'package:myevents/models/global_model.dart';
import 'package:myevents/models/profile_model.dart';
import 'package:myevents/models/resort_model.dart';
import 'package:myevents/models/service_models/edit_service_model.dart';
import 'package:myevents/models/service_models/service_list_model.dart';
import 'package:myevents/models/share_button_model.dart';
import 'package:myevents/models/trending_model.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<BackendService>(() => BackendService());
  locator.registerLazySingleton<FilterService>(() => FilterService());
  locator.registerLazySingleton<GlobalModel>(() => GlobalModel());
  locator.registerFactory<ProfileModel>(() => ProfileModel());
  locator.registerFactory<AdDirModel>(() => AdDirModel());
  locator.registerFactory<TrendingModel>(() => TrendingModel());
  locator.registerFactory<BanquetModel>(() => BanquetModel());
  locator.registerFactory<ResortModel>(() => ResortModel());
  locator.registerFactory<AdEditModel>(() => AdEditModel());
  locator.registerFactory<DirPageModel>(() => DirPageModel());
  locator.registerFactory<EditServiceModel>(() => EditServiceModel());
  locator.registerFactory<DynamicTabModel>(() => DynamicTabModel());
  locator.registerFactory<ServiceListModel>(() => ServiceListModel());
  locator.registerFactory<SaveAdButtonModel>(() => SaveAdButtonModel());
  locator.registerFactory<CreateBookingModel>(() => CreateBookingModel());
  locator
      .registerFactory<SaveServiceButtonModel>(() => SaveServiceButtonModel());
  locator.registerLazySingleton<NotificationAPI>(() => NotificationAPI());
}
