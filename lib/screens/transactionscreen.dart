import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesaplamaaraci/transactions/dbcommands.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  Color colorTheme = Color.fromARGB(255, 0, 0, 0);
  DBCommands _dbCommands = DBCommands();
  late Future<List<Map<String, dynamic>>> _futureData;
  List<Map<String, dynamic>>? _transactionList;

  @override
  void initState() {
    super.initState();
    _futureData = _fetchData();
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    await _dbCommands.initializeDatabase();
    List<Map<String, dynamic>> data = await _dbCommands.getAllData();
    setState(() {
      _transactionList = data;
    });
    return data;
  }

  @override
  void dispose() {
    _dbCommands.closeDatabase();
    super.dispose();
  }

  void _deleteSelectedData(int id) async {
    await _dbCommands.deleteData(id);
    setState(() {
      _transactionList = _transactionList!
          .where((transaction) => transaction['id'] != id)
          .toList();
    });
  }

  void _copySelectedData(String sonuc) {
    List<String> satirlar = sonuc.split('\n');
    String sonucSatiri = satirlar.last; // Son satırı alın
    String copy = sonucSatiri.split('Sonuç: ')[1].split(' m')[0];
    copy = copy.replaceAll(' m/sn', '');
    copy = copy.replaceAll('%', '');
    copy = copy.replaceAll(' mSS', '');
    copy = copy.replaceAll(' m³/h', '');
    copy = copy.replaceAll(' I/s', '');
    copy = copy.replaceAll(' kW', '');
    copy = copy.replaceAll(' W', '');
    copy = copy.replaceAll(' hp', '');
    Clipboard.setData(ClipboardData(text: copy));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İşlem Geçmişi"),
        backgroundColor: colorTheme,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("Veriler alınırken hata oluştu"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: _transactionList!.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactionList![index];
                      final id = transaction['id'];
                      final islem = transaction['islem'];
                      final sonuc = transaction['sonuc'];
                      return ListTile(
                        title: Text(
                          islem!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          sonuc!,
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteSelectedData(id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                _copySelectedData(sonuc);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Tüm Verileri Sil"),
                          content: Text(
                              "Tüm verileri silmek istediğinize emin misiniz?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "İptal",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await _dbCommands.deleteAllData();
                                setState(() {
                                  _transactionList = [];
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Sil",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    "Tüm Verileri Sil",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size(300, 30)),
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
