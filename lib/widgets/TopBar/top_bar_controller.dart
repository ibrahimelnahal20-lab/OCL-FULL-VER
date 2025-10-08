// lib/widgets/TopBar/top_bar_controller.dart - النسخة النهائية

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TopBarController extends GetxController {
  final box = GetStorage();

  // هذه المتغيرات ستحمل البيانات في ذاكرة التطبيق
  RxString loggedInUsername = ''.obs;
  RxString userType = 'user'.obs;
  RxString userImageUrl = ''.obs;
  RxInt userId = 0.obs; // <-- إضافة: متغير لمعرف المستخدم

  @override
  void onInit() {
    super.onInit();
    // عند بدء تشغيل الكنترولر، قم بتحميل البيانات من الذاكرة المستدامة
    _loadUserData();
  }

  /// **تم تعديل هذه الدالة لتقرأ البيانات الصحيحة**
  void _loadUserData() {
    // أهم شيء: تحقق إذا كان المستخدم مسجلاً دخوله بالفعل (عبر وجود التوكن)
    final token = box.read('token');

    if (token != null) {
      // إذا كان هناك توكن، قم بتحميل باقي البيانات المحفوظة
      userId.value = box.read('userId') ?? 0; // <-- إضافة: تحميل معرف المستخدم
      loggedInUsername.value = box.read('saved_username') ?? '';
      userType.value = box.read('saved_userType') ?? 'user';
      userImageUrl.value = box.read('saved_imageUrl') ?? '';
    } else {
      // إذا لم يكن هناك توكن، تأكد من أن الحالة هي زائر
      userType.value = 'guest';
    }
  }

  /// **تم تعديل دوال الحفظ لتستخدم نفس المفاتيح الموحدة**
  void setUsername(String username) {
    if (username.isNotEmpty) {
      loggedInUsername.value = username;
      box.write('saved_username', username);
    }
  }

  void setUserType(String type) {
    if (type.isNotEmpty) {
      userType.value = type;
      box.write('saved_userType', type);
    }
  }

  void setUserImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      userImageUrl.value = imageUrl;
      box.write('saved_imageUrl', imageUrl);
    }
  }

  void setUserId(int id) {
    if (id > 0) {
      userId.value = id;
      box.write('userId', id);
    }
  }

  /// عند الدخول كزائر، امسح بيانات المستخدم الحقيقي
  void loginAsGuest() {
    userType.value = 'guest';
    box.write('userType', 'guest'); // يمكنك استخدام هذا لاحقاً

    // امسح البيانات الأخرى
    loggedInUsername.value = '';
    userImageUrl.value = '';
    box.remove('saved_username');
    box.remove('saved_imageUrl');
    box.remove('token'); // امسح التوكن أيضاً
    box.remove('userId'); // <-- إضافة: مسح معرف المستخدم
  }

  /// عند تسجيل الخروج، يتم مسح كل شيء من LoginController
  /// هذه الدالة يمكن استخدامها فقط لتحديث الواجهة إذا لزم الأمر
  void clearUI() {
    loggedInUsername.value = '';
    userImageUrl.value = '';
    userType.value = 'user'; // العودة للوضع الافتراضي
    userId.value = 0; // <-- إضافة: إعادة تعيين معرف المستخدم
  }
}