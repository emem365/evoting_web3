import 'package:aasha/blockchain_service.dart';
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

  Future<bool> isUserRegisted() async {
    final bs = BlockchainService.instance;
    await bs.init();
    return bs.isUserRegistered();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF292929), brightness: Brightness.dark, textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)),
      home: FutureBuilder<bool>(
        future: isUserRegisted(),
        builder: (context, snap) {
          if(snap.hasData){
            if(snap.data ?? false){
              return Material(child: Center(child: Text('NextPage')),);
            } else {
              return const Register();
            }
          }
          return const SplashScreen();
          // if(snap.connectionState == ConnectionState.waiting){
            
          // } 
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