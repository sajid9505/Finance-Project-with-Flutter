import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../model/form.dart';

class FormController {
  static const String url =
      "https://script.google.com/macros/s/AKfycbzXwA47UVWt22xH0_2xmOr2-8OPPCQSsvAgdlveNui_S0M9WSqTQzl9vINqVH97eIAa/exec";

  // ignore: constant_identifier_names
  static const STATUS_SUCCESS = "SUCCESS";

  void submitForm(
      FeedbackForm feedbackForm, void Function(String) callback) async {
    try {
      final response =
          await http.post(Uri.parse(url), body: feedbackForm.toJson());

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

// /// Async function which loads feedback from endpoint URL and returns List.
// Future<List<FeedbackForm>> getFeedbackList() async {
//   return await http.get(URL).then((response) {
//     var jsonFeedback = convert.jsonDecode(response.body) as List;
//     return jsonFeedback.map((json) => FeedbackForm.fromJson(json)).toList();
//   });
// }

  Future<List<FeedbackForm>> getFeedbackList() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonFeedback = convert.jsonDecode(response.body) as List;
        return jsonFeedback.map((json) => FeedbackForm.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load feedback list. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getFeedbackList: $e');
      throw Exception('Failed to load feedback list. Error: $e');
    }
  }
}
