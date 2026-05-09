import 'package:usv_hub_management/core/background.dart';
import 'package:usv_hub_management/core/consts.dart';
import 'package:usv_hub_management/features/add_teacher/domain/entities/user_entity.dart';
import 'package:usv_hub_management/features/view_departaments/presentation/provider/add_course_provider.dart';
import 'package:usv_hub_management/injection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({
    super.key,
    required this.departamentId,
    required this.semesterId,
  });

  final String departamentId;
  final String semesterId;
  @override
  AddCoursePageState createState() => AddCoursePageState();
}

class AddCoursePageState extends State<AddCoursePage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Background(
        child: ChangeNotifierProvider(
          create: (context) => getIt<AddCourseProvider>()
            ..getTeachers(widget.departamentId)
            ..setSemesterId(widget.semesterId),
          builder: (context, child) => const BodyWidget(),
        ),
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({super.key});

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  final _formKey = GlobalKey<FormState>(); // Cheia formularului
  final _formKey2 = GlobalKey<FormState>(); // Cheia formularului
  final classTypeKey = GlobalKey<SplitButtonState>();
  final classFreqKey = GlobalKey<SplitButtonState>();
  final dayOfWeekKey = GlobalKey<SplitButtonState>();

  @override
  void initState() {
    context.read<AddCourseProvider>().addListener(showErrorFunc);
    super.initState();
  }

  void showErrorFunc() async {
    if (context.read<AddCourseProvider>().getErrorMessage != null) {
      String message = context.read<AddCourseProvider>().getErrorMessage!;
      if (mounted) {
        context.read<AddCourseProvider>().clearErrorMessage();
      }
      await displayInfoBar(context, builder: (_, close) {
        return InfoBar(
          title: const Text('You can not do that :/'),
          content: Text(
            message,
            style: const TextStyle(color: AppColors.black),
          ),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.warning,
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;
    return Consumer<AddCourseProvider>(
      builder: (context, provider, child) => provider.isLoading != null &&
              provider.isLoading!
          ? const Center(
              child: ProgressBar(),
            )
          : Center(
              child: Container(
                height: h * 0.8,
                width: w * 0.8,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min, // Optimizează pe înălțime
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(w * 0.01),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(FluentIcons.chrome_back),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(w * 0.05),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InfoLabel(
                                      label: 'Enter the title for the course:',
                                      labelStyle: const TextStyle(
                                        color: AppColors.black,
                                      ),
                                      child: TextBox(
                                        placeholder: 'Title',
                                        expands: false,
                                        onChanged: (value) =>
                                            provider.setTitle(value),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    InfoLabel(
                                      label: 'Enter the number of credits:',
                                      labelStyle: const TextStyle(
                                        color: AppColors.black,
                                      ),
                                      child: NumberBox(
                                          placeholder: 'Credits',
                                          value: provider.getCredits,
                                          onChanged: (value) {
                                            provider.setCredits(value);
                                          }),
                                    ),
                                    const SizedBox(height: 16),
                                    InfoLabel(
                                      label: 'Set the number of courses:',
                                      labelStyle: const TextStyle(
                                        color: AppColors.black,
                                      ),
                                      child: NumberBox(
                                        value: provider.getNoOfCourses,
                                        placeholder: 'Number of courses',
                                        onChanged: (value) =>
                                            provider.setNoOfCourses(value),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    InfoLabel(
                                      label: 'Select a teacher:',
                                      labelStyle: const TextStyle(
                                        color: AppColors.black,
                                      ),
                                      child: AutoSuggestBox<UserEntity>(
                                          placeholder: 'Select a teacher',
                                          items: provider.getProfesors.map((e) {
                                            return AutoSuggestBoxItem<
                                                UserEntity>(
                                              value: e,
                                              label: e.name,
                                              child: Text(
                                                e.name,
                                                style: const TextStyle(
                                                    color: AppColors.black),
                                              ),
                                            );
                                          }).toList(),
                                          onSelected: (item) {
                                            provider
                                                .setProfesorId(item.value!.id);
                                          }),
                                    ),
                                    const SizedBox(height: 16),
                                    InfoLabel(
                                      label: 'Select a assistent:',
                                      labelStyle: const TextStyle(
                                        color: AppColors.black,
                                      ),
                                      child: AutoSuggestBox<UserEntity>(
                                          placeholder: 'Select a teacher',
                                          items: provider.getProfesors.map((e) {
                                            return AutoSuggestBoxItem<
                                                UserEntity>(
                                              value: e,
                                              label: e.name,
                                              child: Text(
                                                e.name,
                                                style: const TextStyle(
                                                    color: AppColors.black),
                                              ),
                                            );
                                          }).toList(),
                                          onSelected: (item) {
                                            provider
                                                .setAssistentId(item.value!.id);
                                          }),
                                    ),
                                    const SizedBox(height: 16),
                                    InfoLabel(
                                      label: 'Add a schedule:',
                                      labelStyle: const TextStyle(
                                        color: AppColors.black,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(FluentIcons.add,
                                            size: 15.0),
                                        onPressed: () {
                                          provider.setAddButtonClicked();
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: w * 0.4,
                                      height: h * 0.025,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: provider.getSchedule.length,
                                        itemBuilder: (_, index) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: w * 0.001),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: h * 0.0005,
                                                      color: AppColors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: AppColors.white
                                                      .withValues(alpha: 0.8)),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: h * 0.0015,
                                                  horizontal: h * 0.005),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      provider
                                                          .getSchedule[index][
                                                              AppFields
                                                                  .classWhereHeld]
                                                          .toString(),
                                                      style: const TextStyle(
                                                          color:
                                                              AppColors.black)),
                                                  IconButton(
                                                      icon: const Icon(
                                                          FluentIcons.remove),
                                                      onPressed: () {
                                                        provider.removeSchedule(
                                                            index);
                                                      })
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Button(
                                          child: const Text('Add course'),
                                          onPressed: () async {
                                            await provider.addCourse();
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: w * 0.05, vertical: w * 0.07),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey2,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: provider.getAddButtonClicked
                                    ? [
                                        InfoLabel(
                                          label: 'Select a type',
                                          labelStyle: const TextStyle(
                                            color: AppColors.black,
                                          ),
                                          child: EnumDropdown(
                                            splitButtonKey: classTypeKey,
                                            enu: ClassType.values,
                                            onSelected: (value) {
                                              provider.setClassType(
                                                value as ClassType,
                                              );
                                            },
                                            textValue: provider
                                                .getClassType?.stringValue,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        InfoLabel(
                                          label: 'Set a classroom:',
                                          labelStyle: const TextStyle(
                                            color: AppColors.black,
                                          ),
                                          child: TextBox(
                                              placeholder: 'Classroom',
                                              onChanged: (value) => {
                                                    provider.setClassWhereHeld(
                                                        value)
                                                  }),
                                        ),
                                        const SizedBox(height: 16),
                                        InfoLabel(
                                          label: 'Select course frequency:',
                                          labelStyle: const TextStyle(
                                            color: AppColors.black,
                                          ),
                                          child: EnumDropdown(
                                            splitButtonKey: classFreqKey,
                                            enu: CourseFrequency.values,
                                            onSelected: (value) {
                                              provider.setCourseFrequency(
                                                value as CourseFrequency,
                                              );
                                            },
                                            textValue: provider
                                                .getCourseFrequency
                                                ?.stringValue,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        InfoLabel(
                                          label: 'Select the day of the week:',
                                          labelStyle: const TextStyle(
                                            color: AppColors.black,
                                          ),
                                          child: EnumDropdown(
                                            splitButtonKey: dayOfWeekKey,
                                            enu: DayOfWeek.values,
                                            onSelected: (value) {
                                              provider.setDayOfWeek(
                                                value as DayOfWeek,
                                              );
                                            },
                                            textValue: provider
                                                .getDayOfWeek?.stringValue,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        InfoLabel(
                                          label: 'Select the starting hour:',
                                          labelStyle: const TextStyle(
                                            color: AppColors.black,
                                          ),
                                          child: TimePicker(
                                            selected:
                                                provider.getSelectedStartHour,
                                            onChanged: (time) {
                                              provider
                                                  .setSelectedStartHour(time);
                                            },
                                            hourFormat: HourFormat.HH,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        InfoLabel(
                                          label: 'Select the ending hour:',
                                          labelStyle: const TextStyle(
                                            color: AppColors.black,
                                          ),
                                          child: TimePicker(
                                            selected:
                                                provider.getSelectedEndHour,
                                            onChanged: (time) {
                                              provider.setSelectedEndHour(time);
                                            },
                                            hourFormat: HourFormat.HH,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Button(
                                              child: const Text('Add schedule'),
                                              onPressed: () {
                                                provider.addSchedule();
                                              },
                                            ),
                                          ],
                                        )
                                      ]
                                    : []),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class EnumDropdown extends StatelessWidget {
  const EnumDropdown({
    super.key,
    required this.splitButtonKey,
    required this.enu,
    required this.onSelected,
    required this.textValue,
  });

  final GlobalKey<SplitButtonState> splitButtonKey;
  final List<Enum> enu;
  final Function(Enum) onSelected;
  final String? textValue;

  @override
  Widget build(BuildContext context) {
    return SplitButton(
      key: splitButtonKey,
      flyout: FlyoutContent(
        constraints: const BoxConstraints(maxWidth: 200.0),
        child: Wrap(
          direction: Axis.vertical,
          runSpacing: 10.0,
          spacing: 8.0,
          children: enu.map((value) {
            return Button(
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.all(4.0),
                ),
              ),
              onPressed: () {
                onSelected(value);
              },
              child: Text(value.name),
            );
          }).toList(),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: const BorderRadiusDirectional.horizontal(
            start: Radius.circular(4.0),
          ),
        ),
        padding:
            const EdgeInsets.only(left: 8.0, right: 15, top: 4.0, bottom: 4.0),
        child: Text(textValue == null ? "Select" : textValue!,
            style: const TextStyle(color: AppColors.black)),
      ),
    );
  }
}
