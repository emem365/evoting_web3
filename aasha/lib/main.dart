import 'package:aasha/register.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const AppWidget()
  );
}

class AppWidget extends StatelessWidget {
  const AppWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF292929), brightness: Brightness.dark, textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)),
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 5)),
        builder: (context, snap) {
          if(snap.connectionState == ConnectionState.waiting){
            return const SplashScreen();
          } else {
            return const Register();
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height/2-200,),
            Image.asset('assets/icon-fg.png', width: MediaQuery.of(context).size.width/2,),
            Text('AASHA', style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white70),),
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF7CFDF2),),),),
            Text('FROM',style: Theme.of(context).textTheme.overline?.copyWith(color: Colors.white70)),
            Text('Team Omae Wa Mou Shindeiru',style: Theme.of(context).textTheme.overline?.copyWith(color: Colors.white70)),
            const SizedBox(height: 32,),
          ],
        ),
      ),
    );
  }
}