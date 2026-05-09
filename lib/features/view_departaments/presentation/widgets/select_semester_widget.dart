import 'package:usv_hub_management/core/consts.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SelectSemester extends StatelessWidget {
  const SelectSemester({
    super.key,
    required this.h,
    required this.lenght,
    required this.onTap,
    required this.selectedSemester,
    required this.getTitle,
    required this.w,
  });

  final double h;
  final double w;
  final int lenght;
  final Function(int) onTap;
  final int? selectedSemester;
  final String Function(int) getTitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w * 0.2,
      height: h > 600 ? h * 0.65 : h * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Semesters',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: h * 0.01,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: lenght, // ,
                itemBuilder: (_, index) {
                  return ListTile(
                    tileColor: selectedSemester == index
                        ? WidgetStatePropertyAll(
                            AppColors.onPrimary.withValues(alpha: 0.5),
                          )
                        : const WidgetStatePropertyAll(
                            AppColors.primaryFixed,
                          ),
                    title: Text(
                      "Semestrul ${getTitle(index)}", // provider.getSemester(index).semesterNumber.toString(),
                    ),
                    onPressed: () {
                      onTap(index);
                    },
                  );

                  //   return GestureDetector(

                  //     child: Card(
                  //         margin: EdgeInsets.symmetric(vertical: h * 0.005),
                  //         backgroundColor:  == index //
                  //             ? AppColors.onSecondary
                  //             : AppColors.secondary,
                  //         child: ),
                  //   );
                }),
          ),
        ],
      ),
    );
  }
}
