import '../mock/mock_receipt.dart';
import '../models/receipt.dart';

class ExpenseService {
  Future<Receipt> getScannedReceipt() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Receipt.fromJson(mockScannedReceiptData);
  }

  Future<List<Receipt>> getRecentReceipts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockRecentReceipts
        .map((receipt) => Receipt.fromJson(receipt))
        .toList();
  }

  Future<bool> confirmReceiptSplit(Receipt receipt) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return true;
  }
}