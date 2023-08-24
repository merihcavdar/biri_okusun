import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: const Text(
            "Maximiles Black\'i Tanıyın. Onunla hedef tutturma, uçuş tablosu gibi zorluklarla uğraşmadan nereye, ne kadara uçacağınızın kararını siz verirsiniz. Maximiles Black\'e Maximum Mobil, İşCep uygulamalarımız ve Şubelerimiz üzerinden başvurabilirsiniz. Hayal kurmanın sınırının olmadığı, harcadıkça ayrıcalık kazandığınız ayrıcalıklarla dolu bir dünyayı Maximiles Black ile keşfedin. Maximiles Black ile yapacağınız alışverişlerden, varlık birikiminize göre artan oranlarda MaxiMil kazanabilir, size özel ayrıcalıkların keyfini yaşayabilirsiniz. Üstelik Maximiles Black’in sundukları bunlarla sınırlı değil. Karmaşık mil hesaplarıyla uğraştırmadan, tüm alışverişlerinizde MaxiMil kazandırarak bölge ve yolcu kotaları olmadan kolayca uçmanızı sağlayan Maximiles Black, sahip olduğu Maximum özellikleri ile puan, taksit ve indirim fırsatlarından da yararlanmanızı sağlıyor.",
            style: TextStyle(
              fontSize: 22.0,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(FontAwesomeIcons.play),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
