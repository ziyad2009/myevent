import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/app_languages.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/filters_service.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/localization.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/global_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/phone_sign_in.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/viewstate.dart';
import 'package:myevents/widgets/main_page.dart';
import 'package:provider/provider.dart';

void main() async {
  setupLocator();
  AppLanguage appLanguage = AppLanguage();
  WidgetsFlutterBinding.ensureInitialized();
  await appLanguage.fetchLocale();
  BackendService backendService = locator<BackendService>();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await appLanguage.fetchLocale();
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.

  // TODO: Comment the below line in profile/production build
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MyApp(
    appLanguage: appLanguage,
    client: backendService.clientFor(),
  ));
}

class MyApp extends StatelessWidget {
  final AppLanguage appLanguage;
  final ValueNotifier<GraphQLClient> client;

  MyApp({this.appLanguage, this.client});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(
        builder: (context, model, child) => StreamProvider<UserBasic>(
          initialData: UserBasic.initial(),
          create: (context) => locator<BackendService>().userController.stream,
          child: GraphQLProvider(
            client: client,
            child: BotToastInit(
                child: StreamProvider<Filter>(
              initialData: Filter(
                  filterValues: {"field": {}}, priceSortDecending: false),
              create: (context) =>
                  locator<FilterService>().filterController.stream,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorObservers: [BotToastNavigatorObserver()],
                supportedLocales: [
                  Locale('en', 'US'),
                  Locale('ar', ''),
                ],
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                title: 'My Events',
                theme: ThemeData(
                    primaryColor: primaryColor,
                    fontFamily: 'Tajawal',
                    accentColor: primaryColor),
                home: ParentWidget(),
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<GlobalModel>(
      onModelReady: (model) async {
        await model.attemptLogin();
        GraphQLProvider.of(context).value = model.afterAuthClient();
      },
      builder: (context, model, child) {
        if (model.state == ViewState.Busy)
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "lib/assets/myevents_logo.png",
                  height: 240,
                  width: 128,
                ),
                SizedBox(
                  height: 50,
                ),
                CircularProgressIndicator(),
              ],
            ),
          );
        return model.result == 200 ? MainPage() : PhoneSignIn();
      },
    );
  }
}
