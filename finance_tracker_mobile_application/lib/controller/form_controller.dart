// import 'dart:convert' as convert;
// import 'package:http/http.dart' as http;
// import '../model/form.dart';

// class FormController {
//   static const String url =
//       "https://script.google.com/macros/s/AKfycbzXwA47UVWt22xH0_2xmOr2-8OPPCQSsvAgdlveNui_S0M9WSqTQzl9vINqVH97eIAa/exec";

//   // ignore: constant_identifier_names
//   static const STATUS_SUCCESS = "SUCCESS";

//   void submitForm(
//       FeedbackForm feedbackForm, void Function(String) callback) async {
//     try {
//       final response =
//           await http.post(Uri.parse(url), body: feedbackForm.toJson());

//       if (response.statusCode == 302) {
//         final redirectUrl = response.headers['location'];
//         final redirectResponse = await http.get(Uri.parse(redirectUrl!));

//         callback(convert.jsonDecode(redirectResponse.body)['status']);
//       } else {
//         callback(convert.jsonDecode(response.body)['status']);
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<List<FeedbackForm>> getFeedbackList() async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         var jsonFeedback = convert.jsonDecode(response.body) as List;
//         return jsonFeedback.map((json) => FeedbackForm.fromJson(json)).toList();
//       } else {
//         throw Exception(
//             'Failed to load feedback list. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in getFeedbackList: $e');
//       throw Exception('Failed to load feedback list. Error: $e');
//     }
//   }
// }

import 'dart:convert' as convert;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/form.dart';

class FormController {
  static const String url =
      "https://script.googleusercontent.com/macros/echo?user_content_key=YF9Z3q7HzY7McelvypVTLUsLcc_33jYsIR-fWmQG9lPslAbBc3z94iMMzNH0XoOotgpsuXC0N37zve3hEil4AcHlIzraYwbxm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnM9pK3tkHq74SGd0Z1gqrd9kdniaQZ_G-LvqRgrvmpaJId8SqEVm-LTUPd2TCnYG7uSzZ8Z6QsZ3UgFNtnaezPf8w7JfSeCGGQ&lib=M6Y8hTv9DUzw4MgEgfKiJ9RJS-FelNKUK";

  // ignore: constant_identifier_names
  static const STATUS_SUCCESS = "SUCCESS";

  Future<FeedbackForm> getFeedback() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = convert.jsonDecode(response.body);
        return FeedbackForm.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load feedback. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getFeedback: $e');
      throw Exception('Failed to load feedback. Error: $e');
    }
  }
}
