import 'package:blue_print/features/roles/teacher/presentation/widgets/subjects.dart';
import 'package:flutter/cupertino.dart';

class Labs extends StatelessWidget {
  const Labs({super.key});

  @override
  Widget build(BuildContext context) {

    List<Subjects> _buildGridCards(int count) {
      List<Subjects> cards = List.generate(
        count,
            (int index) {
          return Subjects(onPressed: (){}, text1: 'Subject Name-(CO-XXXX)', text2: 'X-year & Y-sem');
        },
      );
      return cards;
    }

    return GridView.count(
        crossAxisCount: 1,
        padding: const EdgeInsets.all(16.0),
        childAspectRatio: 14/5,
        children: _buildGridCards(4) // Replace
    );
  }
}
