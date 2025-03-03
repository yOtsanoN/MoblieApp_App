import 'package:moblieapp_app/model/cateitem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moblieapp_app/model/moblieappitem.dart';
import 'package:moblieapp_app/provider/cateprovider.dart';
import 'package:moblieapp_app/provider/moblieappitemprovider.dart';
import 'package:moblieapp_app/database/moblieappDB.dart';
import 'formScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => MoblieAppItemProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MoblieApp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'MoblieApp'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false)
          .insertDummyCategories();
      Provider.of<MoblieAppItemProvider>(context, listen: false).initData();
      Provider.of<CategoryProvider>(context, listen: false).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Text(
              "รายการ MoblieApp",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildMoblieAppItemList(context)),
            Divider(),
            //Expanded(child: _buildBrandList(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return FormScreen();
          }));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
Widget _buildMoblieAppItemList(BuildContext context) {
  return Consumer<MoblieAppItemProvider>(
    builder: (context, provider, child) {
      if (provider.items.isEmpty) {
        return const Center(
          child: Text(
            'ไม่มีรายการ MoblieApp',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          Moblieappitem data = provider.items[index];

          // หา Cateitem จาก CategoryProvider โดยใช้ cateID
          Cateitem? category = Provider.of<CategoryProvider>(context, listen: false)
              .categories
              .firstWhere(
                (category) => category.cateID == data.cate.cateID,
                orElse: () => Cateitem(cateID: 0, title: 'ไม่พบหมวดหมู่')
              );

          return _buildListItem(
            title: data.title,
            subtitle:
                '${category.title} | ปีที่เปิดตัว: ${data.date?.toLocal().toString().split(' ')[0]} | คะแนน: ${data.score}',
            leadingText: data.title.substring(0, 1), // ใช้อักษรแรกของชื่อแอป
            onDelete: () => provider.deleteItem(data.keyID ?? 0),
            onTap: () {
              // Navigating to EditScreen
            },
          );
        },
      );
    },
  );
}


/*test Brand
  Widget _buildBrandList(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (context, provider, child) {
        int itemCount = provider.brandItems.length;
        if (itemCount == 0) {
          return const Center(
              child: Text('ไม่มีรายการ Brand', style: TextStyle(fontSize: 20)));
        }
        return ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            BrandItem data = provider.brandItems[index];
            return _buildListItem(
              title: data.Brand_Name,
              subtitle:
                  '${data.Brand_ID} ก่อตั้งปี: ${data.Founded_Year} | ประเทศ: ${data.Country}',
              onDelete: () => provider.deleteBrandItem(data.Brand_ID ?? 0),
              onTap: () {
                /*
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return EditScreen(item: data);
                }))*/
                ;
              }, leadingText: '',
            );
          },
        );
      },
    );
  }

*/
  Widget _buildListItem({
    required String title,
    required String subtitle,
    required String leadingText,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }) {
    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Text(
              leadingText,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              _showDeleteConfirmation(context, title, onDelete);
            },
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, String title, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text('คุณต้องการลบ "$title" ใช่หรือไม่?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child:
                  const Text('ลบรายการ', style: TextStyle(color: Colors.red)),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
