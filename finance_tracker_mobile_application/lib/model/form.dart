/// FeedbackForm is a data class which stores data fields of Feedback.
// class FeedbackForm {
//   String name;
//   String email;
//   String mobileNo;
//   String feedback;

//   FeedbackForm(this.name, this.email, this.mobileNo, this.feedback);

//   factory FeedbackForm.fromJson(dynamic json) {
//     return FeedbackForm("${json['name']}", "${json['email']}",
//         "${json['mobileNo']}", "${json['feedback']}");
//   }

  // // Method to make GET parameters.
  // Map toJson() => {
  //       'name': name,
  //       'email': email,
  //       'mobileNo': mobileNo,
  //       'feedback': feedback
  //     };
// }

class FeedbackForm {
  final int actualBalance;
  final int foodBudget;
  final int foodSpent;

  FeedbackForm({
    required this.actualBalance,
    required this.foodBudget,
    required this.foodSpent,
  });

  factory FeedbackForm.fromJson(Map<String, dynamic> json) {
    return FeedbackForm(
      actualBalance: json['actualBalance'] ?? 0,
      foodBudget: json['foodBudget'] ?? 0,
      foodSpent: json['foodSpent'] ?? 0,
    );
  }
}

  // Method to make GET parameters.
  // Map toJson() => {
  //       'actualBalance': actualBalance,
  //       'foodBudget': foodBudget,
  //       'foodSpent': foodSpent,
  //     };