import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_model.dart';
import '../models/deposit_model.dart';
import '../services/archive_service.dart';

final archiveServiceProvider = Provider<ArchiveService>((ref) => ArchiveService());

class ArchiveNotifier extends AsyncNotifier<({List<LoanModel> loans, List<DepositModel> deposits})> {
  @override
  Future<({List<LoanModel> loans, List<DepositModel> deposits})> build() async {
    return ref.read(archiveServiceProvider).getArchive();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final archiveProvider = AsyncNotifierProvider<ArchiveNotifier, ({List<LoanModel> loans, List<DepositModel> deposits})>(
  ArchiveNotifier.new,
);
