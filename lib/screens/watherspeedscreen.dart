import 'package:flutter/material.dart';
import 'package:hesaplamaaraci/transactions/dbcommands.dart';
import 'package:hesaplamaaraci/transactions/warnings.dart';

class watherspeedscreen extends StatefulWidget {
  @override
  waterspeedState createState() => waterspeedState();
}

class waterspeedState extends State<watherspeedscreen>
    with SingleTickerProviderStateMixin {
  Color colorTheme = Color.fromARGB(255, 0, 255, 174);
  double sonuc = 0;
  bool textDurum = false;
  String debiDegeri = "m³/h";
  bool seceneklerDurum = false;

  TextEditingController debiController = TextEditingController();
  TextEditingController boruCapiController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void hesaplaIslem() async {
    double debi = double.tryParse(debiController.text) ?? 0;
    double borucapi = double.tryParse(boruCapiController.text) ?? 0;

    if (debiController.text.isEmpty || boruCapiController.text.isEmpty) {
      Alertler.dialogBilgi(context, "Lütfen boş yer bırakmayınız.", colorTheme);
      return;
    } else {
      if (debiDegeri == "I/s") {
        debi = debi * 3600.0 / 1000.0;
      } else if (debiDegeri == "m³/h") {
        debi = debi / 3600.0;
      }
      sonuc = debi / borucapi;
      sonuc = double.parse(sonuc.toStringAsFixed(2));
      DBCommands dbCommands = DBCommands();
      await dbCommands.initializeDatabase();
      await dbCommands.insertData("Su Hızı Hesaplaması",
          "Debi: $debi | Boru Çapı: $borucapi | Sonuç: $sonuc m/sn");
      await dbCommands.closeDatabase();
      // ignore: use_build_context_synchronously
      Alertler.snakeBilgi(
          context,
          "Su Hızı: $sonuc m/sn kopyalamak ister misin?",
          colorTheme,
          sonuc.toString());
      setState(() {
        textDurum = true;
        seceneklerDurum = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Hızı'),
        backgroundColor: colorTheme,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset('assets/images/debi.png'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Debi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: debiDegeri,
                            items: <String>['m³/h', 'I/s', 'm³/sn']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                debiDegeri = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 120,
                        child: TextField(
                          controller: debiController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 255, 174)),
                              )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                            'assets/images/frictionloss/borucapi.png'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Boru Çapı',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: 'm',
                            items: <String>['m'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 120,
                        child: TextField(
                          controller: boruCapiController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 255, 174)),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  hesaplaIslem();
                },
                child: Text('Hesapla'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  backgroundColor: colorTheme,
                ),
              ),
              const SizedBox(height: 20),
              if (textDurum)
                Text(
                  'Toplam: $sonuc m/sn',
                  style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
