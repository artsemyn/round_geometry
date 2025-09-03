import 'dart:io';
import 'package:http/http.dart' as http;

class ConvertService {
  final String endpoint; // Web/Desktop: http://127.0.0.1:8000/convert
                         // Android emulator: http://10.0.2.2:8000/convert
  ConvertService(this.endpoint);

  Future<List<int>> convertGlbToStl(File glb) async {
    final req = http.MultipartRequest('POST', Uri.parse(endpoint));
    req.files.add(await http.MultipartFile.fromPath('file', glb.path));
    final res = await req.send();
    if (res.statusCode != 200) {
      throw Exception(await res.stream.bytesToString());
    }
    return await res.stream.toBytes();
  }
}