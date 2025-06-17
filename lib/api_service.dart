import 'dart:convert'; // สำหรับแปลงข้อมูล JSON เป็น Dart object และกลับกัน
import 'package:http/http.dart' as http; // ใช้สำหรับเรียก API HTTP request
import 'worker_model.dart'; // นำเข้าโมเดล Worker

// URL หลักของ API (เปลี่ยนตาม platform เช่น Android Emulator ใช้ 10.0.2.2)
const String baseUrl = 'http://10.0.2.2:5000/api/workers';

// คลาสสำหรับเรียกใช้งาน API ต่าง ๆ (CRUD)
class ApiService {

  // ---------------- GET ----------------
  // ดึงรายชื่อคนงานทั้งหมดจาก backend
  static Future<List<Worker>> getWorkers() async {
    final response = await http.get(Uri.parse(baseUrl)); // เรียก GET /api/workers

    if (response.statusCode == 200) {
      // แปลง JSON เป็น List<Worker>
      List jsonList = json.decode(response.body);
      return jsonList.map((e) => Worker.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load workers'); // กรณีเกิดข้อผิดพลาด
    }
  }

  // ---------------- POST ----------------
  // เพิ่มข้อมูลคนงานใหม่
  static Future<void> addWorker(Worker worker) async {
    final response = await http.post(
      Uri.parse(baseUrl), // POST /api/workers
      headers: {'Content-Type': 'application/json'}, // กำหนด header เป็น JSON
      body: json.encode({ // แปลงข้อมูลเป็น JSON
        'name': worker.name,
        'age': worker.age,
        'position': worker.position,
        'experience': worker.experience,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add worker'); // ถ้า status code ไม่ใช่ 200 ให้ throw error
    }
  }

  // ---------------- PUT ----------------
  // แก้ไขข้อมูลคนงาน (ระบุ id คนงาน)
  static Future<void> updateWorker(Worker worker) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${worker.id}'), // PUT /api/workers/{id}
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': worker.name,
        'age': worker.age,
        'position': worker.position,
        'experience': worker.experience,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update worker');
    }
  }

  // ---------------- DELETE ----------------
  // ลบคนงาน (ระบุ id)
  static Future<void> deleteWorker(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id')); // DELETE /api/workers/{id}

    if (response.statusCode != 200) {
      throw Exception('Failed to delete worker');
    }
  }
}
