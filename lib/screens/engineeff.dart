import 'package:flutter/material.dart';
import 'package:hesaplamaaraci/transactions/dbcommands.dart';
import 'package:hesaplamaaraci/transactions/warnings.dart';

class engineeff extends StatefulWidget {
  @override
  _engineeffState createState() => _engineeffState();
}

class _engineeffState extends State<engineeff> {
  double sonuc = 0;
  bool showResult = false;
  String debiDegeri = "m³/h";
  String gucDegeri = "kW";
  Color colorTheme = Color.fromARGB(255, 4, 0, 220);

  void hesaplaIslem() async {
    double debi = double.tryParse(debiController.text) ?? 0;
    double guc = double.tryParse(gucController.text) ?? 0;
    double basmaYuksekligi =
        double.tryParse(basmaYuksekligiController.text) ?? 0;
    double hidrolikVerim = double.tryParse(hidrolikVerimController.text) ?? 0;

    if (gucController.text.isEmpty ||
        debiController.text.isEmpty ||
        basmaYuksekligiController.text.isEmpty ||
        hidrolikVerimController.text.isEmpty) {
      Alertler.dialogBilgi(context, "Lütfen boş yer bırakmayınız.", colorTheme);
      return;
    }

    sonuc = debi + guc + basmaYuksekligi + hidrolikVerim;
    Alertler.snakeBilgi(
        context,
        "Motor Verimi: %$sonuc kopyalamak ister misin?",
        colorTheme,
        sonuc.toString());

    DBCommands dbCommands = DBCommands();
    await dbCommands.initializeDatabase();
    await dbCommands.insertData("Motor V. Hesaplaması",
        "Güç: $guc | Debi: $debi | Basma Yüksekliği: $basmaYuksekligi | Hidrolik Verim: $hidrolikVerim | Sonuç: %$sonuc");
    await dbCommands.closeDatabase();

    setState(() {
      showResult = true;
    });
  }

  TextEditingController debiController = TextEditingController();
  TextEditingController gucController = TextEditingController();
  TextEditingController basmaYuksekligiController = TextEditingController();
  TextEditingController hidrolikVerimController = TextEditingController();

  @override
  void dispose() {
    debiController.dispose();
    gucController.dispose();
    basmaYuksekligiController.dispose();
    hidrolikVerimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motor Verimi"),
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
                        child: Image.asset("assets/images/debi.png"),
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
                                    color: Color.fromARGB(255, 4, 0, 220)),
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
                                    color: Color.fromARGB(255, 4, 0, 220)),
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
                        child: Image.asset('assets/images/basmayuksekligi.png'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Basma Y.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: 'mSS',
                            items: <String>['mSS'].map((String value) {
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
                          controller: basmaYuksekligiController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 4, 0, 220)),
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
                        child: Image.asset('assets/images/hidrolikverim.png'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Hidrolik V.',
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
                          controller: hidrolikVerimController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 4, 0, 220)),
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
                  'Toplam: $sonuc',
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
