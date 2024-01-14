import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../model/form.dart';

class FormController {
  static const String url =
      "https://script.google.com/macros/s/AKfycbzXwA47UVWt22xH0_2xmOr2-8OPPCQSsvAgdlveNui_S0M9WSqTQzl9vINqVH97eIAa/exec";

  static const STATUS_SUCCESS = "SUCCESS";

  void submitForm(
      FeedbackForm feedbackForm, void Function(String) callback) async {
    try {
      final response = await http.post(Uri.parse(url), body: feedbackForm.toJson());

      if (response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        final redirectResponse = await http.get(Uri.parse(redirectUrl!));

        callback(convert.jsonDecode(redirectResponse.body)['status']);
      } else {
        callback(convert.jsonDecode(response.body)['status']);
      }
    } catch (e) {
      print(e);
    }
  }
}
