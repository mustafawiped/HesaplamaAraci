import 'package:flutter/material.dart';
import 'package:hesaplamaaraci/transactions/dbcommands.dart';
import 'package:hesaplamaaraci/transactions/transactiontype.dart';
import 'package:hesaplamaaraci/transactions/warnings.dart';

class debiscreen extends StatefulWidget {
  @override
  _debiscreenState createState() => _debiscreenState();
}

class _debiscreenState extends State<debiscreen> {
  double sonuc = 0;
  bool textDurum = false;
  Color colorTheme = Color.fromARGB(255, 255, 132, 0);
  String GucSecilenItem = "kW";
  String hesaplanma = "m³/h";
  bool seceneklerDurum = false;

  void hesaplaDebi() async {
    double guc = double.tryParse(gucController.text) ?? 0;
    double basmaYuksekligi =
        double.tryParse(basmaYuksekligiController.text) ?? 0;
    double hidrolikVerim = double.tryParse(hidrolikVerimController.text) ?? 0;
    double motorVerim = double.tryParse(motorVerimController.text) ?? 0;

    if (gucController.text.isEmpty ||
        basmaYuksekligiController.text.isEmpty ||
        hidrolikVerimController.text.isEmpty ||
        motorVerimController.text.isEmpty) {
      Alertler.dialogBilgi(context, "Lütfen boş yer bırakmayınız.", colorTheme);
    } else {
      guc = (GucSecilenItem == "W")
          ? guc / 1000
          : (GucSecilenItem == "hp")
              ? guc / 1.341
              : guc;
      sonuc = ((hidrolikVerim / 100) * (motorVerim / 100) * 367.2 * guc) /
          basmaYuksekligi;
      sonuc = (hesaplanma == "I/s") ? sonuc * 3600.0 / 1000.0 : sonuc;
      sonuc = double.parse(sonuc.toStringAsFixed(2));
      DBCommands dbCommands = DBCommands();
      await dbCommands.initializeDatabase();
      await dbCommands.insertData("Debi Hesaplaması",
          "Güç: $guc | Basma Yüksekliği: $basmaYuksekligi | Hidrolik Verim: $hidrolikVerim | Motor Verimi: $motorVerim | Sonuç: $sonuc $hesaplanma");
      await dbCommands.closeDatabase();
      Alertler.snakeBilgi(
          context,
          "debi: $sonuc $hesaplanma kopyalamak ister misin?",
          colorTheme,
          sonuc.toString());
      setState(() {
        seceneklerDurum = true;
        textDurum = true;
      });
    }
  }

  void kontrol() async {
    String sharedKontrol = await Shareds.sharedCek("debiscreen");
    if (sharedKontrol != "Değer Bulunamadı") {
      String sharedKontrol2 = await Shareds.sharedCek("debiG");
      if (sharedKontrol2 == "true") {
        setState(() {
          seceneklerDurum = true;
        });
        hesaplanma = sharedKontrol;
      } else {
        List<String> liste = ["m³/h", "I/s"];
        List<String> sonuclar = await Alertler.secenekBilgi(
            context, "Çıktı Değeri", liste, colorTheme, "m³/h", false);
        if (sonuclar.isNotEmpty) {
          hesaplanma = sonuclar[0];
          Shareds.sharedEkleGuncelle("debiscreen", sonuclar[0]);
          Shareds.sharedEkleGuncelle("debiG", sonuclar[1]);
        }
      }
    } else {
      List<String> liste = ["m³/h", "I/s"];
      List<String> sonuclar = await Alertler.secenekBilgi(
          context, "Çıktı Değeri", liste, colorTheme, "m³/h", false);
      if (sonuclar.isNotEmpty) {
        hesaplanma = sonuclar[0];
        Shareds.sharedEkleGuncelle("debiscreen", sonuclar[0]);
        Shareds.sharedEkleGuncelle("debiG", sonuclar[1]);
      }
    }
  }

  TextEditingController gucController = TextEditingController();
  TextEditingController basmaYuksekligiController = TextEditingController();
  TextEditingController hidrolikVerimController = TextEditingController();
  TextEditingController motorVerimController = TextEditingController();

  @override
  void dispose() {
    gucController.dispose();
    basmaYuksekligiController.dispose();
    hidrolikVerimController.dispose();
    motorVerimController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    kontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debi'),
        backgroundColor: colorTheme,
        actions: seceneklerDurum
            ? [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        title: const Text('Çıktı Değerini Değiştir'),
                        onTap: () async {
                          Navigator.pop(context);
                          List<String> liste = ["m³/h", "I/s"];
                          List<String> sonuclar = await Alertler.secenekBilgi(
                              context,
                              "Çıktı Değeri",
                              liste,
                              colorTheme,
                              hesaplanma,
                              seceneklerDurum);
                          if (sonuclar.isNotEmpty) {
                            hesaplanma = sonuclar[0];
                            Shareds.sharedEkleGuncelle(
                                "debiscreen", sonuclar[0]);
                            Shareds.sharedEkleGuncelle("debiG", sonuclar[1]);
                            if (gucController.text.isNotEmpty &&
                                basmaYuksekligiController.text.isNotEmpty &&
                                hidrolikVerimController.text.isNotEmpty &&
                                motorVerimController.text.isNotEmpty)
                              hesaplaDebi();
                          }
                        },
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ]
            : [],
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
                            value: GucSecilenItem,
                            items:
                                <String>['kW', 'W', 'hp'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                GucSecilenItem = newValue!;
                                if (gucController.text.isNotEmpty &&
                                    basmaYuksekligiController.text.isNotEmpty &&
                                    hidrolikVerimController.text.isNotEmpty &&
                                    motorVerimController.text.isNotEmpty)
                                  hesaplaDebi();
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
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 255, 132, 0)),
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
                                    color: Color.fromARGB(255, 255, 132, 0)),
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
                                    color: Color.fromARGB(255, 255, 151, 23)),
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
                                    color: Color.fromARGB(255, 255, 132, 0)),
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
                  hesaplaDebi();
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
                  'Toplam: $sonuc $hesaplanma',
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
