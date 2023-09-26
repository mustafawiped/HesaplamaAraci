import 'package:flutter/material.dart';
import 'package:hesaplamaaraci/transactions/dbcommands.dart';
import 'package:hesaplamaaraci/transactions/warnings.dart';

class headscreen extends StatefulWidget {
  @override
  _headscreenState createState() => _headscreenState();
}

class _headscreenState extends State<headscreen> {
  double sonuc = 0;
  bool showResult = false;
  String debiDegeri = "m³/h";
  String gucDegeri = "kW";
  Color colorTheme = Color.fromARGB(255, 84, 220, 0);

  void hesaplaIslem() async {
    double debi = double.tryParse(debiController.text) ?? 0;
    double guc = double.tryParse(gucController.text) ?? 0;
    double hidrolikVerim = double.tryParse(hidrolikVerimController.text) ?? 0;
    double motorVerim = double.tryParse(motorVerimController.text) ?? 0;

    if (gucController.text.isEmpty ||
        debiController.text.isEmpty ||
        hidrolikVerimController.text.isEmpty ||
        motorVerimController.text.isEmpty) {
      Alertler.dialogBilgi(context, "Lütfen boş yer bırakmayınız.", colorTheme);
      return;
    }

    debi = (debiDegeri == "I/s") ? debi * 3600.0 / 1000.0 : debi;
    guc = (gucDegeri == "W")
        ? guc / 1000
        : (gucDegeri == "hp")
            ? guc / 1.341
            : guc;
    sonuc = ((hidrolikVerim / 100) * (motorVerim / 100) * 367.2 * guc) / debi;
    sonuc = double.parse(sonuc.toStringAsFixed(2));
    Alertler.snakeBilgi(
        context,
        "Basma Yüksekliği: $sonuc mSS kopyalamak ister misin?",
        colorTheme,
        sonuc.toString());

    DBCommands dbCommands = DBCommands();
    await dbCommands.initializeDatabase();
    await dbCommands.insertData("Basma Y. Hesaplaması",
        "● Güç: $guc \n● Debi: $debi \n● Hidrolik Verim: $hidrolikVerim \n● Motor Verimi: $motorVerim \n➤ Sonuç: $sonuc mSS");
    await dbCommands.closeDatabase();

    setState(() {
      showResult = true;
    });
  }

  TextEditingController debiController = TextEditingController();
  TextEditingController gucController = TextEditingController();
  TextEditingController hidrolikVerimController = TextEditingController();
  TextEditingController motorVerimController = TextEditingController();

  @override
  void dispose() {
    debiController.dispose();
    gucController.dispose();
    hidrolikVerimController.dispose();
    motorVerimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basma Yüksekliği'),
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
                            items: <String>['m³/h', 'I/s'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                debiDegeri = newValue!;
                                if (gucController.text.isNotEmpty &&
                                    debiController.text.isNotEmpty &&
                                    hidrolikVerimController.text.isNotEmpty &&
                                    motorVerimController.text.isNotEmpty)
                                  hesaplaIslem();
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
                                    color: Color.fromARGB(255, 84, 220, 0)),
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
                        child: Image.asset('assets/images/guc.png'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Güç',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: gucDegeri,
                            items:
                                <String>['kW', 'W', 'hp'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                gucDegeri = newValue!;
                                if (gucController.text.isNotEmpty &&
                                    debiController.text.isNotEmpty &&
                                    hidrolikVerimController.text.isNotEmpty &&
                                    motorVerimController.text.isNotEmpty)
                                  hesaplaIslem();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 120,
                        child: TextField(
                          controller: gucController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 84, 220, 0)),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset('assets/images/hidrolikverim.png'),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Hidrolik V.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: '%',
                            items: <String>['%'].map((String value) {
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
                          controller: hidrolikVerimController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 84, 220, 0)),
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
                        child: Image.asset('assets/images/motor.png'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Motor V.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: '%',
                            items: <String>['%'].map((String value) {
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
                          controller: motorVerimController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 84, 220, 0)),
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
              if (showResult)
                Text(
                  'Toplam: $sonuc mSS',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
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
