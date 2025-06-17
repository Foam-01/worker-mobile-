import 'package:flutter/material.dart';
import 'worker_model.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp()); // เรียกใช้งานแอป โดยเริ่มต้นจาก MyApp
}

// วิดเจ็ตหลักของแอป ใช้กำหนดธีม และกำหนดหน้าเริ่มต้น
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workers List', // ชื่อของแอป
      theme: ThemeData(primarySwatch: Colors.blue), // กำหนดธีมสีหลัก
      home: const WorkerListPage(), // หน้าหลักของแอป
    );
  }
}

// หน้าแสดงรายชื่อคนงาน (สามารถเปลี่ยนแปลงข้อมูลได้)
class WorkerListPage extends StatefulWidget {
  const WorkerListPage({super.key});

  @override
  _WorkerListPageState createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  late Future<List<Worker>> _futureWorkers; // ตัวแปรเก็บข้อมูลคนงานที่โหลดมาจาก API

  @override
  void initState() {
    super.initState();
    _loadWorkers(); // โหลดข้อมูลคนงานเมื่อเริ่มต้นแอป
  }

  // โหลดข้อมูลจาก API (Method: GET)
  void _loadWorkers() {
    _futureWorkers = ApiService.getWorkers();
  }

  // รีโหลดข้อมูลคนงานใหม่
  void _refresh() {
    setState(() {
      _loadWorkers();
    });
  }

  // แสดงฟอร์มเพิ่ม/แก้ไขคนงาน
  void _showWorkerForm({Worker? worker}) {
    final isEditing = worker != null;

    final nameController = TextEditingController(text: worker?.name ?? '');
    final ageController = TextEditingController(text: worker?.age.toString() ?? '');
    final positionController = TextEditingController(text: worker?.position ?? '');
    final experienceController = TextEditingController(text: worker?.experience ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'แก้ไขคนงาน' : 'เพิ่มคนงาน'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อ'),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'อายุ'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'ตำแหน่ง'),
              ),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(labelText: 'ประสบการณ์'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final age = int.tryParse(ageController.text.trim()) ?? 0;
              final position = positionController.text.trim();
              final experience = experienceController.text.trim();

              if (name.isEmpty || age == 0 || position.isEmpty || experience.isEmpty) {
                // ตรวจสอบว่ากรอกข้อมูลครบหรือยัง
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')),
                );
                return;
              }

              if (isEditing) {
                // กรณีแก้ไขคนงาน (Method: PUT)
                final updatedWorker = Worker(
                  id: worker!.id,
                  name: name,
                  age: age,
                  position: position,
                  experience: experience,
                );
                await ApiService.updateWorker(updatedWorker);
              } else {
                // กรณีเพิ่มคนงานใหม่ (Method: POST)
                final newWorker = Worker(
                  id: '', // backend จะเป็นผู้กำหนด id เอง
                  name: name,
                  age: age,
                  position: position,
                  experience: experience,
                );
                await ApiService.addWorker(newWorker);
              }

              Navigator.pop(context); // ปิด dialog
              _refresh(); // โหลดข้อมูลใหม่
            },
            child: Text(isEditing ? 'บันทึก' : 'เพิ่ม'),
          ),
        ],
      ),
    );
  }

  // ลบคนงานออกจากระบบ (Method: DELETE)
  Future<void> _deleteWorker(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบคนงาน'),
        content: const Text('ต้องการลบคนงานนี้หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.deleteWorker(id);
      _refresh(); // โหลดข้อมูลใหม่หลังจากลบ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workers List'),
      ),
      body: FutureBuilder<List<Worker>>(
        future: _futureWorkers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // กำลังโหลด
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // แสดง error ถ้ามี
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูลคนงาน')); // ถ้าไม่มีข้อมูล
          }

          final workers = snapshot.data!;
          return ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return ListTile(
                title: Text(worker.name),
                subtitle: Text('${worker.position}, อายุ ${worker.age} ปี\nประสบการณ์: ${worker.experience}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showWorkerForm(worker: worker), // แก้ไขข้อมูล
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteWorker(worker.id), // ลบข้อมูล
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWorkerForm(), // ปุ่มเพิ่มข้อมูล
        child: const Icon(Icons.add),
      ),
    );
  }
}
