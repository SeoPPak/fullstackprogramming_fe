import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/record.dart';
import '../../../providers/record_provider.dart';
import '../../record_detail/record_detail_screen.dart';

class RecordListItem extends StatelessWidget {
  final RecordList record;

  const RecordListItem({
    required this.record,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(record.record.rname),
        subtitle: Text(record.record.timeStamp),
        trailing: Text(
          '${record.totalPrice.toString()}원',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordDetailScreen(rid: record.record.rid),
            ),
          );

          if (context.mounted) {
            context.read<RecordProvider>().fetchRecords();
          }
        },
      ),
    );
  }
}