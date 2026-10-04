class ReceiptItem {
  final String id;
  String title;
  double price;
  int quantity;
  List<String> assignedMemberIds;

  ReceiptItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1,
    required this.assignedMemberIds,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      assignedMemberIds: (json['assignedMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'assignedMemberIds': assignedMemberIds,
    };
  }
}

class Receipt {
  final String id;
  final String merchantName;
  final String timestamp;
  final int peopleCount;
  final List<ReceiptItem> items;
  final List<ReceiptMemberSplit> memberSplits; // Dynamic list from backend/service
  final String paidByMemberName;
  final String paidByMemberAvatar;

  Receipt({
    required this.id,
    required this.merchantName,
    required this.timestamp,
    required this.peopleCount,
    required this.items,
    required this.memberSplits,
    required this.paidByMemberName,
    required this.paidByMemberAvatar,
  });

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      merchantName: json['merchantName'] as String,
      timestamp: json['timestamp'] as String,
      peopleCount: json['peopleCount'] as int? ?? 3,
      items: (json['items'] as List<dynamic>)
          .map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      memberSplits: (json['memberSplits'] as List<dynamic>?)
              ?.map((e) => ReceiptMemberSplit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      paidByMemberName: json['paidByMemberName'] as String? ?? 'Alex Ramses',
      paidByMemberAvatar: json['paidByMemberAvatar'] as String? ?? 'AR',
    );
  }
}

class ReceiptMemberSplit {
  final String id;
  final String name;
  final int colorHex;
  int splitPercentage;

  ReceiptMemberSplit({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.splitPercentage,
  });

  factory ReceiptMemberSplit.fromJson(Map<String, dynamic> json) {
    return ReceiptMemberSplit(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['colorHex'] as int? ?? 0xFF66BB6A,
      splitPercentage: json['splitPercentage'] as int? ?? 33,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'splitPercentage': splitPercentage,
      };
}