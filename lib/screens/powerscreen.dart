import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesaplamaaraci/transactions/dbcommands.dart';
import 'package:hesaplamaaraci/transactions/transactiontype.dart';
import 'package:hesaplamaaraci/transactions/warnings.dart';

class powerscreen extends StatefulWidget {
  @override
  _powerscreenState createState() => _powerscreenState();
}

class _powerscreenState extends State<powerscreen> {
  double sonuc = 0;
  bool textDurum = false;
  String debiDegeri = "m³/h";
  Color colorTheme = Color.fromARGB(255, 255, 64, 129);
  String hesaplanma = "kW";
  bool seceneklerDurum = false;

  void hesaplaIslem() async {
    double debi = double.tryParse(debiController.text) ?? 0;
    double basmaYuksekligi =
        double.tryParse(basmaYuksekligiController.text) ?? 0;
    double hidrolikVerim = double.tryParse(hidrolikVerimController.text) ?? 0;
    double motorVerim = double.tryParse(motorVerimController.text) ?? 0;

    if (debiController.text.isEmpty ||
        basmaYuksekligiController.text.isEmpty ||
        hidrolikVerimController.text.isEmpty ||
        motorVerimController.text.isEmpty) {
      Alertler.dialogBilgi(context, "Lütfen boş yer bırakmayınız.", colorTheme);
      return;
    } else {
      if (debiDegeri == "m³/h") {
        //metreküp / saat ise
        sonuc = (debi * basmaYuksekligi * hidrolikVerim * motorVerim) / 367;
      } else if (debiDegeri == "I/s") {
        // metre / saniye ise
        double debiM3h = debi * 3.6;
        sonuc = (debiM3h * basmaYuksekligi * hidrolikVerim * motorVerim) / 367;
      } else {
        Alertler.dialogBilgi(context, "Geçersiz debi birimi", colorTheme);
        return;
      }
      DBCommands dbCommands = DBCommands();
      await dbCommands.initializeDatabase();
      await dbCommands.insertData("Güç Hesaplaması",
          "Debi: $debi | Basma Yüksekliği: $basmaYuksekligi | Hidrolik Verim: $hidrolikVerim | Motor Verimi: $motorVerim | Sonuç: $sonuc $hesaplanma");
      await dbCommands.closeDatabase();
      Alertler.snakeBilgi(
          context,
          "Güç: $sonuc $hesaplanma kopyalamak ister misin?",
          colorTheme,
          sonuc.toString());
      setState(() {
        textDurum = true;
        seceneklerDurum = true;
      });
    }
  }

  void kontrol() async {
    String sharedKontrol = await Shareds.sharedCek("powerscreen");
    if (sharedKontrol != "Değer Bulunamadı") {
      String sharedKontrol2 = await Shareds.sharedCek("powerG");
      if (sharedKontrol2 == "true") {
        setState(() {
          seceneklerDurum = true;
        });
        hesaplanma = sharedKontrol;
      } else {
        List<String> liste = ["kW", "W", "hp"];
        List<String> sonuclar = await Alertler.secenekBilgi(
            context, "Çıktı Değeri", liste, colorTheme, "kW", false);
        if (sonuclar.isNotEmpty) {
          hesaplanma = sonuclar[0];
          Shareds.sharedEkleGuncelle("powerscreen", sonuclar[0]);
          Shareds.sharedEkleGuncelle("powerG", sonuclar[1]);
        }
      }
    } else {
      List<String> liste = ["kW", "W", "hp"];
      List<String> sonuclar = await Alertler.secenekBilgi(
          context, "Çıktı Değeri", liste, colorTheme, "kW", false);
      if (sonuclar.isNotEmpty) {
        hesaplanma = sonuclar[0];
        Shareds.sharedEkleGuncelle("powerscreen", sonuclar[0]);
        Shareds.sharedEkleGuncelle("powerG", sonuclar[1]);
      }
    }
  }

  TextEditingController debiController = TextEditingController();
  TextEditingController basmaYuksekligiController = TextEditingController();
  TextEditingController hidrolikVerimController = TextEditingController();
  TextEditingController motorVerimController = TextEditingController();

  @override
  void initState() {
    super.initState();
    kontrol();
  }

  @override
  void dispose() {
    debiController.dispose();
    basmaYuksekligiController.dispose();
    hidrolikVerimController.dispose();
    motorVerimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güç'),
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
                          List<String> liste = ["kW", "W", "hp"];
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
                                "powerscreen", sonuclar[0]);
                            Shareds.sharedEkleGuncelle("powerG", sonuclar[1]);
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
                                borderSide:
                                    BorderSide(color: Colors.pinkAccent),
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
                                borderSide:
                                    BorderSide(color: Colors.pinkAccent),
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
                                borderSide:
                                    BorderSide(color: Colors.pinkAccent),
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
                                borderSide:
                                    BorderSide(color: Colors.pinkAccent),
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
                  'Toplam: $sonuc',
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
