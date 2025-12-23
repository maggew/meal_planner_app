import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/login/widgets/login_body.dart';

@RoutePage()
class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBackground(
      scaffoldBody: LoginBody(),
    );
  }
}
// class LoginPage extends StatefulWidget {
//   @override
//   State<LoginPage> createState() => _LoginPage();
// }
//
// class _LoginPage extends State<LoginPage> {
//   String email = "";
//   String password = "";
//
//   Auth auth = new Auth();
//
//   GlobalKey<FormState> _formCheck = new GlobalKey();
//
//   //Screen is locked to portraitUp mode
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//     return Stack(
//       children: [
//         Container(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           color: Colors.white,
//           child: Opacity(
//             opacity: 0.7,
//             child: RotatedBox(
//               quarterTurns: 3,
//               child: FittedBox(
//                 fit: BoxFit.fill,
//                 child: Image(
//                   image: AssetImage('assets/images/background.png'),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Scaffold(
//           backgroundColor: Colors.transparent,
//           body: ,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
