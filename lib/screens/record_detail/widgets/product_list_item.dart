import 'package:flutter/material.dart';
import '../../../models/record.dart';

class ProductListItem extends StatelessWidget {
  final String rid;
  final DBProduct product;
  final VoidCallback onEditPressed;

  const ProductListItem({
    required this.rid,
    required this.product,
    required this.onEditPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.pname),
      subtitle: Text('수량: ${product.amount}개'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${product.price}원',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEditPressed,
          ),
        ],
      ),
      onTap: () => _showProductDetailDialog(context),
    );
  }

  void _showProductDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.pname),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('수량: ${product.amount}개'),
            Text('단가: ${product.price}원'),
            Text('총액: ${product.price * product.amount}원'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
