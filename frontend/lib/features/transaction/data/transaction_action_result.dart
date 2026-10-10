import '../../dashboard/data/dashboard_transaction_model.dart';

/// Hasil aksi dari halaman Edit / Hapus Transaksi
class TransactionActionResult {
  final String transactionId;
  final bool isDeleted;
  final DashboardTransaction? updatedTransaction;

  const TransactionActionResult.updated(this.transactionId, this.updatedTransaction)
      : isDeleted = false;

  const TransactionActionResult.deleted(this.transactionId)
      : isDeleted = true,
        updatedTransaction = null;
}
