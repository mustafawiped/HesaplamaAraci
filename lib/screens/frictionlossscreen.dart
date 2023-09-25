import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesaplamaaraci/transactions/dbcommands.dart';
import 'package:hesaplamaaraci/transactions/warnings.dart';

class FrictionLossScreen extends StatefulWidget {
  @override
  FrictionLossScreenState createState() => FrictionLossScreenState();
}

class FrictionLossScreenState extends State<FrictionLossScreen> {
  double sonuc = 0;
  bool showResult = false;
  String debiDegeri = "m³/h";
  String boruCapiDegeri = "mm";
  String secilenItem = "Alüminyum";
  String boruUdegeri = "m";
  String secilenResim = 'assets/images/frictionloss/aluminyum.png';
  Color colorTheme = Color.fromARGB(255, 0, 176, 220);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void hesaplaIslem() async {
    double debi = double.tryParse(debiController.text) ?? 0;
    double boruCapi = double.tryParse(boruCapiController.text) ?? 0;
    double boruUzunlugu = double.tryParse(boruUzunluguController.text) ?? 0;
    double sicaklik = double.tryParse(sicaklikController.text) ?? 0;

    if (boruCapiController.text.isEmpty ||
        debiController.text.isEmpty ||
        boruUzunluguController.text.isEmpty ||
        sicaklikController.text.isEmpty) {
      Alertler.dialogBilgi(context, "Lütfen boş yer bırakmayınız.", colorTheme);
      return;
    }

    // debiyi m3/s e dönüştürdük, boru çapını milimetreye, boru uzunluğunu metreye ve sürtünme kaybı katsaısını aldık.
    if (debiDegeri == "I/s") debi = debi * 3600.0 / 1000.0;
    if (boruCapiDegeri == "in") boruCapi = boruCapi * 25.4;
    if (boruUdegeri == "ft") {
      boruUzunlugu = boruUzunlugu * 0.3048;
    } else if (boruUdegeri == "km")
      boruUzunlugu = boruUzunlugu * 1000;
    // ignore: curly_braces_in_flow_control_structures
    else if (boruUdegeri == "miles") boruUzunlugu = boruUzunlugu * 1609.34;
    double surtunmeKaybiKatSayisi = surtunmeKaybi[secilenItem]!.toDouble();
    debi = (debi / 3.6) * 60;
    //

    // Hesaplamalar..
    double Pm = 6.05 *
        (pow(debi, 1.85) /
            (pow(surtunmeKaybiKatSayisi, 1.85) * pow(boruCapi, 4.87))) *
        pow(10, 5);
    print("pm: $Pm");
    print("debi: $debi");
    print("surtunmekaybi: $surtunmeKaybiKatSayisi");
    print("çap: $boruCapi");
    print("uzunluk: $boruUzunlugu");
    sonuc = Pm * boruUzunlugu * 10.43;
    sonuc = double.parse(sonuc.toStringAsFixed(4));
    Alertler.snakeBilgi(
        context,
        "Sürtünme Kaybı: $sonuc m kopyalamak ister misin?",
        colorTheme,
        sonuc.toString());
    DBCommands dbCommands = DBCommands();
    await dbCommands.initializeDatabase();
    await dbCommands.insertData("Sürtünme K. Hesaplaması",
        "Boru Çapı: $boruCapi | Debi: $debi | Boru Uzunluğu: $boruUzunlugu | Sıcaklık: $sicaklik | Sonuç: $sonuc");
    await dbCommands.closeDatabase();

    setState(() {
      showResult = true;
    });
  }

  TextEditingController debiController = TextEditingController();
  TextEditingController boruCapiController = TextEditingController();
  TextEditingController boruUzunluguController = TextEditingController();
  TextEditingController sicaklikController = TextEditingController();

  @override
  void dispose() {
    debiController.dispose();
    boruCapiController.dispose();
    boruUzunluguController.dispose();
    sicaklikController.dispose();
    super.dispose();
  }

  Map<String, String> spinnerResimleri = {
    'Alüminyum': 'assets/images/frictionloss/aluminyum.png',
    'Asbest': 'assets/images/frictionloss/asbest.png',
    'Bakır': 'assets/images/frictionloss/bakir.png',
    'Bitümlü çelik': 'assets/images/frictionloss/bitumlucelik.png',
    'Bitümlü demir': 'assets/images/frictionloss/bitumludemir.png',
    'Galvanizli çelik': 'assets/images/frictionloss/galvanizlicelik.png',
    'Orta pürüzlü beton': 'assets/images/frictionloss/oratpuruzbeton.png',
    'Paslanmaz çelik': 'assets/images/frictionloss/paslanmazcelik.png',
    'Pik demir': 'assets/images/frictionloss/pikdemir.png',
    'Pirinç': 'assets/images/frictionloss/pirinc.png',
    'Polietilen': 'assets/images/frictionloss/polietilen.png',
    'Pürüzsüz beton': 'assets/images/frictionloss/puruzsuzbeton.png',
    'Pürüzlü beton': 'assets/images/frictionloss/puruzlubeton.jpg',
    'PVC': 'assets/images/frictionloss/pvc.png',
  };

  Map<String, int> surtunmeKaybi = {
    'Alüminyum': 120,
    'Asbest': 10,
    'Bakır': 10,
    'Bitümlü çelik': 10,
    'Bitümlü demir': 10,
    'Galvanizli çelik': 10,
    'Orta pürüzlü beton': 10,
    'Paslanmaz çelik': 10,
    'Pik demir': 10,
    'Pirinç': 10,
    'Polietilen': 10,
    'Pürüzsüz beton': 10,
    'Pürüzlü beton': 10,
    'PVC': 10,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sürtünme Kaybı",
          style: TextStyle(color: Colors.white),
        ),
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
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.asset(secilenResim),
                  ),
                  SizedBox(width: 16),
                  Container(
                    width: 220,
                    child: DropdownButton<String>(
                      value: secilenItem,
                      isExpanded: true,
                      hint: Text('Seçenekleri seçin'),
                      onChanged: (String? newValue) {
                        setState(() {
                          secilenItem = newValue!;
                          secilenResim = spinnerResimleri[newValue] ??
                              'assets/images/frictionloss/aluminyum.png';
                        });
                      },
                      items: <String>[
                        'Alüminyum',
                        'Asbest',
                        'Bakır',
                        'Bitümlü çelik',
                        'Bitümlü demir',
                        'Galvanizli çelik',
                        'Orta pürüzlü beton',
                        'Paslanmaz çelik',
                        'Pik demir',
                        'Pirinç',
                        'Polietilen',
                        'Pürüzsüz beton',
                        'Pürüzlü beton',
                        'PVC',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
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
                                    color: Color.fromARGB(255, 0, 176, 220)),
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
                            value: boruCapiDegeri,
                            items: <String>['mm', 'in'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                boruCapiDegeri = newValue!;
                              });
                            },
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
                                    color: Color.fromARGB(255, 0, 176, 220)),
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
                        child: Image.asset(
                            'assets/images/frictionloss/boruuzunlugu.png'),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Boru Uz.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: boruUdegeri,
                            items: <String>['m', 'ft', 'km', 'miles']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                boruUdegeri = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 120,
                        child: TextField(
                          controller: boruUzunluguController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 176, 220)),
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
                            'assets/images/frictionloss/sicaklikolcer.png'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Sıcaklık',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: '°C',
                            items: <String>['°C'].map((String value) {
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
                          controller: sicaklikController,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Sayı girin',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 176, 220)),
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
                  'Toplam: $sonuc m',
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
