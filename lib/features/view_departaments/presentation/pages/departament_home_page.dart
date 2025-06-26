import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:usv_hub_management/core/background.dart';
import 'package:usv_hub_management/core/consts.dart';
import 'package:usv_hub_management/features/view_departaments/domain/entities/course_entity.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/pages/edit_departament_dialog.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/provider/departament_home_provider.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/provider/edit_departament_provider.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/widgets/display_info_container.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/widgets/select_semester_widget.dart';
import 'package:usv_hub_management/injection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DepartamentHomePage extends StatefulWidget {
  const DepartamentHomePage({super.key});

  @override
  State<DepartamentHomePage> createState() => _DepartamentHomePageState();
}

class _DepartamentHomePageState extends State<DepartamentHomePage> {
  late DepartamentHomeProvider _provider;
  @override
  void initState() {
    _provider = context.read<DepartamentHomeProvider>();
    _provider.addListener(showDialogIfError);
    super.initState();
  }

  void showDialogIfError() async {
    if (context.read<DepartamentHomeProvider>().errorMessage != null) {
      await showDialog<String>(
        context: context,
        builder: (dialogCtx) => ContentDialog(
          title: const Text('An error occurred'),
          content: Text(
            context.read<DepartamentHomeProvider>().errorMessage!,
          ),
          actions: [
            FilledButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.pop(dialogCtx),
            ),
          ],
        ),
      );
      if (mounted) {
        context.read<DepartamentHomeProvider>().setErrorMessage(null);
      }
    }
  }

  @override
  void dispose() {
    // Remove the listener
    _provider.removeListener(showDialogIfError);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Background(
      child: ScaffoldPage(content: Consumer<DepartamentHomeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: ProgressBar());
          }
          return ResponsiveBuilder(
            builder:
                (BuildContext context, SizingInformation sizingInformation) {
              if (sizingInformation.isDesktop) {
                return Padding(
                  padding: EdgeInsets.all(w * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextBox(
                                    placeholder: 'Search departament',
                                    expands: false,
                                    onChanged: (value) {},
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      color: AppColors.white,
                                      FluentIcons.search),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          // Row(
                          //   children: [
                          //     Padding(
                          //       padding: EdgeInsets.only(right: w * 0.01),
                          //       child: FilledButton(
                          //         style: ButtonStyle(
                          //           backgroundColor:
                          //               WidgetStateProperty.resolveWith(
                          //                   (states) {
                          //             if (states.isHovered) {
                          //               return AppColors.onTertiaryContainer
                          //                   .withValues(1);
                          //             }
                          //             if (states.isPressed) {
                          //               return AppColors.onTertiaryContainer
                          //                   .withValues(alpha: 0.5);
                          //             }
                          //             return AppColors.onTertiaryContainer
                          //                 .withValues(alpha: 0.5);
                          //           }),
                          //         ),
                          //         child: const Text("Add a new Faculty"),
                          //         onPressed: () {},
                          //       ),
                          //     ),
                          //     CustomButton(
                          //         w: w,
                          //         onPressed: () {},
                          //         title: 'Add a new Departament',
                          //         color: AppColors.onTertiaryContainer),
                          //   ],
                          // ),
                        ],
                      ),
                      SizedBox(height: h * 0.015),
                      DepartamentRow(provider: provider),
                      SizedBox(height: h * 0.015),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          provider.getSelectedDepartament() != null
                              ? SelectSemester(
                                  w: w,
                                  h: h,
                                  lenght: provider.getSemesterLenght(),
                                  onTap: (int index) async {
                                    provider.setSelectedSemester(index);
                                    await provider.getCoursesFromRepo();
                                  },
                                  selectedSemester: provider.selectedSemester,
                                  getTitle: (int index) {
                                    return provider
                                        .getSemester(index)
                                        .semesterNumber
                                        .toString();
                                  },
                                )
                              : Container(),
                          provider.getSelectedSemesterEntity() != null &&
                                  provider.getSelectedDepartament() != null &&
                                  provider.selectedCourse != null
                              ? Container(
                                  // decoration: BoxDecoration(
                                  //   color: AppColors.secondary,
                                  //   borderRadius: BorderRadius.circular(10),
                                  // ),
                                  height: h > 600 ? h * 0.65 : h * 0.6,
                                  width: w > 800 ? w * 0.4 : w * 0.3,
                                  padding: EdgeInsets.all(w * 0.01),
                                  alignment: Alignment.topLeft,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        DisplayInfoContainer(
                                          infoToDisplay: provider
                                              .getSelectedCourseEntity()!
                                              .title,
                                          whatToDisplay: "Course Title",
                                          icon: FluentIcons.publish_course,
                                        ),
                                        DisplayInfoContainer(
                                          infoToDisplay: provider
                                              .getSelectedDepartament()!
                                              .name,
                                          whatToDisplay: "Departament",
                                          icon: FluentIcons.office_forms_logo,
                                        ),
                                        DisplayInfoContainer(
                                          infoToDisplay: provider
                                              .getSelectedSemesterEntity()!
                                              .semesterNumber
                                              .toString(),
                                          whatToDisplay: "Semester",
                                          icon: FluentIcons.calendar,
                                        ),
                                        DisplayInfoContainer(
                                          infoToDisplay: provider
                                              .getSelectedCourseEntity()!
                                              .courseCredits
                                              .toString(),
                                          whatToDisplay: "Number of credits",
                                          icon: FluentIcons.number,
                                        ),
                                        DisplayInfoContainer(
                                          infoToDisplay: provider.teacherName!,
                                          whatToDisplay: "Professor",
                                          icon: FontAwesomeIcons.userTie,
                                        ),
                                        DisplayInfoContainer(
                                          infoToDisplay:
                                              provider.assistentName ?? '',
                                          whatToDisplay: "Assistent",
                                          icon: FontAwesomeIcons.userTie,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          provider.getSelectedSemesterEntity() != null &&
                                  provider.getSelectedDepartament() != null
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: w * 0.01),
                                      child: FilledButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith(
                                                  (states) {
                                            if (states.isHovered) {
                                              return AppColors
                                                  .onTertiaryContainer
                                                  .withValues(alpha: 1);
                                            }
                                            if (states.isPressed) {
                                              return AppColors
                                                  .onTertiaryContainer
                                                  .withValues(alpha: 0.5);
                                            }
                                            return AppColors.onTertiaryContainer
                                                .withValues(alpha: 0.5);
                                          }),
                                        ),
                                        child: const Text("Add a new Course"),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRouteConst.addCourse,
                                            arguments: {
                                              AppFields.departamentId: provider
                                                  .getSelectedDepartament()!
                                                  .id,
                                              AppFields.semesterId: provider
                                                  .getSelectedSemesterEntity()!
                                                  .id,
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: w > 1000 ? w * 0.15 : w * 0.25,
                                      height: h > 600 ? h * 0.65 : h * 0.6,
                                      child: ListView.builder(
                                        itemCount: provider.courses.length,
                                        itemBuilder: (_, index) {
                                          bool isSelected =
                                              provider.selectedCourse == index;
                                          CourseEntity course =
                                              provider.courses[index];
                                          return ListTile(
                                            title: Text(
                                              course.title,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? AppColors.white
                                                    : AppColors.white
                                                        .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            subtitle: Text(
                                              course.courseCredits.toString(),
                                              style: TextStyle(
                                                color: isSelected
                                                    ? AppColors.white
                                                    : AppColors.white
                                                        .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            onPressed: () async {
                                              provider.setSelectedCourse(index);
                                              provider.getNames();
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return Container(
                color: AppColors.red,
                height: h,
              );
            },
          );
        },
      )),
    );
  }
}

class DepartamentRow extends StatelessWidget {
  const DepartamentRow({super.key, required this.provider});

  final DepartamentHomeProvider provider;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.departaments.length,
        itemBuilder: (context, index) {
          final departament = provider.departaments[index];
          final isSelected = provider.selectedDepartamentIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () async {
                provider.setSelectedDepartament(index);
                await provider.getSemesters();
              },
              child: Container(
                padding: EdgeInsets.all(width * 0.005),
                width: width * 0.2,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.onPrimary : AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      departament.name,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    if (isSelected)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.isHovered) {
                                  return AppColors.onSecondary
                                      .withValues(alpha: 0.5);
                                }
                                if (states.isPressed) {
                                  return AppColors.onSecondary;
                                }
                                return AppColors.onSecondary;
                              }),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(FluentIcons.edit),
                                Text('Edit'),
                              ],
                            ),
                            onPressed: () {
                              // Your button action here
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return ChangeNotifierProvider(
                                        create: (_) =>
                                            getIt<EditDepartamentProvider>()
                                              ..setSemesters(
                                                  provider.semesters),
                                        builder: (context, child) =>
                                            const EditDepartamentDialog());
                                  });
                            },
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
