// คลาส Worker ใช้แทนข้อมูลของคนงาน 1 คน
class Worker {
  // ---------- ฟิลด์ของคลาส ----------
  final String id;           // รหัสเฉพาะของคนงาน (MongoDB สร้างให้: _id)
  final String name;         // ชื่อคนงาน
  final int age;             // อายุคนงาน
  final String position;     // ตำแหน่ง (เช่น ช่างเหล็ก)
  final String experience;   // ประสบการณ์ (เช่น 10 ปี)

  // ---------- Constructor ----------
  // สร้างอินสแตนซ์ของ Worker จากข้อมูลที่ระบุ
  Worker({
    required this.id,
    required this.name,
    required this.age,
    required this.position,
    required this.experience,
  });

  // ---------- ฟังก์ชัน factory สำหรับสร้างจาก JSON ----------
  // ใช้ตอนรับข้อมูล JSON จาก API และแปลงเป็น object Worker
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['_id'],                 // ดึง id จาก MongoDB (_id)
      name: json['name'],              // ชื่อ
      age: json['age'],                // อายุ
      position: json['position'],      // ตำแหน่ง
      experience: json['experience'],  // ประสบการณ์
    );
  }
}
