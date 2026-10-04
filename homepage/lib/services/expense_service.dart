import '../mock/mock_receipt.dart';
import '../models/receipt.dart';

class ExpenseService {
  Future<List<Receipt>> getRecentReceipts() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return mockRecentReceipts.map(Receipt.fromJson).toList();
  }

  Future<Receipt> getScannedReceipt() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Receipt.fromJson(mockScannedReceiptData);
  }

  Future<bool> confirmReceiptSplit(Receipt receipt) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return true;
  }
}
