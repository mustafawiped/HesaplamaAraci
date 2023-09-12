import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Alertler {
  static void dialogBilgi(
      BuildContext context, String icerik, Color arkaplanrengi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: arkaplanrengi,
          title: const Text(
            'Uyarı',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            icerik,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Tamam',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void snakeBilgi(BuildContext context, String message,
      Color arkaplanrengi, String kopyalanacak) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: arkaplanrengi,
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'Kopyala',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: kopyalanacak));
          },
        ),
      ),
    );
  }

  static Future<List<String>> secenekBilgi(
      BuildContext context,
      String title,
      List<String> items,
      Color arkaplanrengi,
      String secilideger,
      bool seciliDurum) async {
    String selectedValue = secilideger;
    bool showAgain = seciliDurum;

    List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: arkaplanrengi,
              title: Text(
                title,
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Seçili Değer:',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: selectedValue,
                        dropdownColor: arkaplanrengi,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                        },
                        items: items.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: showAgain,
                        side: BorderSide(color: Colors.white),
                        checkColor: arkaplanrengi,
                        fillColor: MaterialStateProperty.all(Colors.white),
                        onChanged: (bool? newValue) {
                          setState(() {
                            showAgain = newValue!;
                          });
                        },
                      ),
                      const Text(
                        'Bir daha gösterme',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'Tamam',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pop([selectedValue, showAgain.toString()]);
                  },
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? [];
  }
}
