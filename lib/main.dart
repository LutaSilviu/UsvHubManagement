import 'dart:developer';
import 'dart:ffi' show DynamicLibrary, DynamicLibraryExtension, Int32;
import 'dart:ui';

import 'package:usv_hub_management/core/background.dart';
import 'package:usv_hub_management/core/consts.dart';
import 'package:usv_hub_management/features/add_events/presentation/pages/event_home_page.dart';
import 'package:usv_hub_management/features/add_events/presentation/providers/event_provider.dart';
import 'package:usv_hub_management/features/add_students/presentation/pages/students_home_page.dart';
import 'package:usv_hub_management/features/add_students/presentation/provider/students_page_provider.dart';
import 'package:usv_hub_management/features/add_teacher/presentation/pages/teachers_home_page.dart';
import 'package:usv_hub_management/features/add_teacher/presentation/provider/home_page_provider.dart';
import 'package:usv_hub_management/features/login/presentation/pages/login_page.dart';
import 'package:usv_hub_management/features/login/presentation/provider/login_provider.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/pages/add_course_page.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/provider/departament_home_provider.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/pages/departament_home_page.dart';
import 'package:usv_hub_management/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

enum Operations { add, subtract, multiply, divide }

void setDpiAwareness() {
  final shcore = DynamicLibrary.open('Shcore.dll');
  final setProcessDpiAwareness =
      shcore.lookupFunction<Int32 Function(Int32), int Function(int)>(
          'SetProcessDpiAwareness');

  // Set process DPI awareness to "Per-Monitor DPyI Aware"
  setProcessDpiAwareness(2);
}

//flutter pub run build_runner watch --delete-conflicting-outputs
int getScreenWidth() {
  final hdc = GetDC(NULL);
  final dpi = GetDeviceCaps(hdc, LOGPIXELSX);
  log('DPI: $dpi');
  ReleaseDC(NULL, hdc);

  return GetSystemMetricsForDpi(SM_CXSCREEN, dpi);
}

int getScreenHeight() {
  final hdc = GetDC(NULL);
  final dpi = GetDeviceCaps(hdc, LOGPIXELSY);
  ReleaseDC(NULL, hdc);

  return GetSystemMetricsForDpi(SM_CYSCREEN, dpi);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBtIoiPaA98ubDHOKIwAtxutKuvmeORtAI",
      authDomain: "usv-hub.firebaseapp.com",
      projectId: "usv-hub",
      storageBucket: "usv-hub.appspot.com",
      messagingSenderId: "511355181571",
      appId: "1:511355181571:web:caeb2559d25a3ea4d24c36",
      measurementId: "G-MW33NV1B65",
    ),
  );

  setDpiAwareness();
  configureDependencies();

  final int screenWidth = getScreenWidth();
  final int screenHeight = getScreenHeight();

  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('Usv Hub Management');
    await windowManager.setBackgroundColor(Colors.transparent);

    // Set the window size to full screen
    await windowManager.setPosition(Offset.zero);

    // Disable resizing and hide title bar
    // await windowManager.maximize();
    await windowManager
        .setMinimumSize(Size(screenWidth.toDouble(), screenHeight.toDouble()));
    await windowManager
        .setSize(Size(screenWidth.toDouble(), screenHeight.toDouble()));
    // Dezactivează maximizarea
    //await windowManager.setMaximizable(false);

    // Dezactivează minimizarea
    //await windowManager.setMinimizable(false);

    // Dezactivează redimensionarea
    // await windowManager.setResizable(false);

    await windowManager.setTitleBarStyle(TitleBarStyle.normal);

    // Set the window to full screen (makes the window cover the entire screen)
    //await windowManager.setFullScreen(true);

    // Show the window
    await windowManager.show();
  });
  //remove debug banner

  runApp(const MyApp());
}

class CustomScrollBehavior extends FluentScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      builder: (_) {
        return FluentApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: CustomScrollBehavior(),
          theme: FluentThemeData(
            brightness: Brightness.light,
            accentColor: Colors.orange,
            typography: Typography.raw(
              display: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              body: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              caption: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.orange,
            typography: Typography.raw(
              display: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              body: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              caption: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (_) => getIt<DepartamentHomeProvider>()),
              ChangeNotifierProvider(
                create: (_) => getIt<HomePageProvider>(),
              ),
              ChangeNotifierProvider(
                create: (_) => getIt<EventProvider>(),
              ),
              ChangeNotifierProvider(
                  create: (_) => getIt<StudentPageProvider>()),
              ChangeNotifierProvider(
                  create: (_) => getIt<LoginProvider>()..checkLogin()),
            ],
            builder: (context, child) {
              return Background(
                child: Consumer<LoginProvider>(
                    builder: (context, LoginProvider loginProvider, _) {
                  if (loginProvider.isLogedIn) {
                    return const MyHomePage();
                  } else {
                    return const LoginPage();
                  }
                }),
              );
            },
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  int index = 0;
  final viewKey = GlobalKey();

  @override
  void initState() {
    windowManager.addListener(this);
    getAllData();
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> getAllData() async {
    if (mounted) {
      await context.read<DepartamentHomeProvider>().getDepartaments();
    }
    if (mounted) {
      await context.read<HomePageProvider>().getDepartaments();
    }
    if (mounted) {
      await context.read<StudentPageProvider>().getDepartaments();
    }
    if (mounted) {
      await context.read<EventProvider>().getDepartaments();
    }
  }

  Future<void> clearProviders() async {
    if (mounted) {
      await context.read<DepartamentHomeProvider>().clear();
    }
    if (mounted) {
      await context.read<HomePageProvider>().clear();
    }
    if (mounted) {
      await context.read<StudentPageProvider>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      key: viewKey,
      pane: NavigationPane(
          selected: index,
          onChanged: (i) => setState(() {
                index = i;
              }),
          displayMode: PaneDisplayMode.compact,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text('Home'),
              body: Navigator(
                onGenerateRoute: (settings) {
                  if (settings.name == AppRouteConst.addCourse) {
                    Map<String, String> map =
                        settings.arguments! as Map<String, String>;
                    return FluentPageRoute(
                      builder: (context) => AddCoursePage(
                        departamentId: map[AppFields.departamentId]!,
                        semesterId: map[AppFields.semesterId]!,
                      ),
                    );
                  }
                  return FluentPageRoute(
                    builder: (context) => const DepartamentHomePage(),
                  );
                },
              ),
            ),
            PaneItem(
              icon: const FaIcon(FontAwesomeIcons.userTie),
              title: const Text('Teachers'),
              body: const TeachersHomePage(),
            ),
            PaneItem(
                //use Font Awsome Icons for the icon,
                icon: const FaIcon(FontAwesomeIcons.userGraduate),
                title: const Text('Students'),
                body: const StudentsHomePage()),
            PaneItem(
                //use Font Awsome Icons for the icon,
                icon: const FaIcon(FontAwesomeIcons.calendar),
                title: const Text('Events'),
                body: const EventHomePage()),
            PaneItem(
              //use Font Awsome Icons for the icon,
              icon: const FaIcon(FluentIcons.leave),
              title: const Text('Logout'),
              onTap: () async {
                await clearProviders();
                if (context.mounted) {
                  Provider.of<LoginProvider>(context, listen: false).logout();
                }
              },
              body: const Background(child: SizedBox()),
            ),
            PaneItem(
              //use Font Awsome Icons for the icon,
              icon: const FaIcon(FluentIcons.cancel),
              title: const Text('Close App'),
              onTap: () {
                windowManager.close();
              },
              body: const Background(child: SizedBox()),
            ),
          ]),
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      showDialog(
          context: context.mounted ? context : viewKey.currentContext!,
          builder: (_) {
            return ContentDialog(
                title: const Text('Confirm close'),
                content: const Text('Are you sure want to close the app?'),
                actions: [
                  FilledButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      Navigator.pop(context);
                      windowManager.destroy();
                    },
                  ),
                  FilledButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ]);
          });
    }
  }
}

//flutter pub run build_runner watch --delete-conflicting-outputs
