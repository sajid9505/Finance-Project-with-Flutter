import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptData {
  final double? amount;
  final DateTime? date;
  final String? description;
  final String? category;

  ReceiptData({this.amount, this.date, this.description, this.category});
}

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<ReceiptData> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognized = await _textRecognizer.processImage(inputImage);
    final text = recognized.text;
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    return ReceiptData(
      amount: _extractAmount(lines),
      date: _extractDate(lines),
      description: _extractMerchant(lines),
      category: _extractCategory(lines),
    );
  }

  void dispose() => _textRecognizer.close();

  // Find the largest dollar amount — usually the total
  double? _extractAmount(List<String> lines) {
    final pattern = RegExp(r'\$?\s*(\d{1,6}[.,]\d{2})\b');
    double? largest;
    for (final line in lines) {
      for (final match in pattern.allMatches(line)) {
        final raw = match.group(1)!.replaceAll(',', '');
        final value = double.tryParse(raw);
        if (value != null && (largest == null || value > largest)) {
          largest = value;
        }
      }
    }
    return largest;
  }

  // Parse common date formats from receipt
  DateTime? _extractDate(List<String> lines) {
    final patterns = [
      RegExp(r'(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{2,4})'),
      RegExp(r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{2,4})', caseSensitive: false),
    ];
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };

    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            if (pattern == patterns[0]) {
              int day = int.parse(match.group(1)!);
              int month = int.parse(match.group(2)!);
              int year = int.parse(match.group(3)!);
              if (year < 100) year += 2000;
              if (day > 12 && month <= 12) {
                return DateTime(year, month, day);
              } else if (month <= 12 && day <= 31) {
                return DateTime(year, month, day);
              }
            } else {
              int day = int.parse(match.group(1)!);
              int month = months[match.group(2)!.toLowerCase().substring(0, 3)] ?? 1;
              int year = int.parse(match.group(3)!);
              if (year < 100) year += 2000;
              return DateTime(year, month, day);
            }
          } catch (_) {}
        }
      }
    }
    return null;
  }

  // Try to find the merchant name from the first few lines
  String? _extractMerchant(List<String> lines) {
    // Skip lines that look like addresses, phone numbers, or are too short
    final skipPattern = RegExp(r'^\d+$|^\+?\d[\d\s\-]{7,}$|^(tel|ph|fax|abn|acn)[\s:]', caseSensitive: false);
    for (final line in lines.take(5)) {
      if (line.length >= 3 && !skipPattern.hasMatch(line)) {
        return _toTitleCase(line);
      }
    }
    return null;
  }

  String? _extractCategory(List<String> lines) {
    final fullText = lines.join(' ').toLowerCase();
    return _matchCategory(fullText);
  }

  String? _matchCategory(String text) {
    final grocery = [
      'woolworths', 'coles', 'aldi', 'iga', 'foodland', 'spar', 'harris farm',
      'shwapno', 'meena bazar', 'agora', 'unimart', 'nandan', 'lavender',
    ];
    final foodDining = [
      'mcdonald', 'kfc', 'subway', 'hungry jack', 'domino', 'pizza hut',
      'nando', 'grill\'d', 'red rooster', 'oporto', 'guzman', 'roll\'d',
      'boost juice', 'gloria jean', 'coffee club', 'starbucks',
      'restaurant', 'cafe', 'diner', 'bistro', 'bakery', 'takeaway',
      'sultan\'s dine', 'fakruddin', 'kacchi bhai', 'star kabab',
      'foodpanda', 'pathao food', 'shohoz food',
    ];
    final transport = [
      'uber', 'ola', 'didi', 'taxi', 'bp', 'shell', 'caltex', 'ampol',
      '7-eleven', 'opal', 'myki', 'bus', 'train', 'ferry',
      'qantas', 'virgin', 'jetstar', 'pathao', 'shohoz', 'cng', 'brtc',
    ];
    final utilities = [
      'agl', 'origin energy', 'energyaustralia', 'sydney water',
      'melbourne water', 'telstra', 'optus', 'vodafone', 'tpg',
      'aussie broadband', 'desco', 'dpdc', 'wasa', 'titas gas',
      'grameenphone', 'robi', 'banglalink', 'airtel',
    ];
    final health = [
      'chemist warehouse', 'priceline', 'terry white', 'doctor',
      'hospital', 'dentist', 'physio', 'medicare',
      'square hospital', 'united hospital', 'apollo', 'labaid',
      'ibn sina', 'popular diagnostic',
    ];
    final shopping = [
      'jb hi-fi', 'harvey norman', 'kmart', 'target', 'big w', 'myer',
      'david jones', 'cotton on', 'uniqlo', 'h&m', 'amazon', 'ebay',
      'bunnings', 'officeworks',
      'aarong', 'yellow', 'richman', 'sailor', 'cats eye', 'bata',
      'apex', 'walton', 'daraz',
    ];
    final entertainment = [
      'event cinemas', 'hoyts', 'village cinemas', 'gym',
      'fitness first', 'anytime fitness', 'f45',
      'star cineplex', 'blockbuster cinemas',
    ];
    final subscriptions = [
      'netflix', 'spotify', 'apple', 'google play', 'disney', 'stan',
      'amazon prime', 'youtube', 'adobe', 'microsoft', 'icloud',
    ];
    final housing = [
      'rent', 'mortgage', 'real estate', 'domain',
    ];

    if (_anyMatch(text, grocery)) return 'Grocery';
    if (_anyMatch(text, foodDining)) return 'Food & Dining';
    if (_anyMatch(text, transport)) return 'Transport';
    if (_anyMatch(text, utilities)) return 'Utilities';
    if (_anyMatch(text, health)) return 'Health';
    if (_anyMatch(text, shopping)) return 'Shopping';
    if (_anyMatch(text, entertainment)) return 'Entertainment';
    if (_anyMatch(text, subscriptions)) return 'Subscriptions';
    if (_anyMatch(text, housing)) return 'Housing';
    return null;
  }

  bool _anyMatch(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  String _toTitleCase(String s) {
    return s
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
