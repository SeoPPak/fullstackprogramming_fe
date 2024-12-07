import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/record.dart';
import '../../providers/record_provider.dart';
import 'widgets/product_list_item.dart';

class RecordDetailScreen extends StatefulWidget {
  final String rid;

  const RecordDetailScreen({
    required this.rid,
    super.key,
  });

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordProvider>().fetchRecordDetail(widget.rid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증 상세'),
      ),
      body: Consumer<RecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final record = provider.selectedRecord;
          if (record == null) {
            return const Center(child: Text('데이터를 불러올 수 없습니다.'));
          }

          return ListView(
            children: [
              // 영수증 기본 정보
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              record.record.rname,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showRecordEditDialog(context, record.record),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '날짜: ${record.record.timeStamp}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 가게 정보
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '가게 정보',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showMartEditDialog(context, record.mart, record.record.rid),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('가게명: ${record.mart.martName}'),
                        Text('주소: ${record.mart.martAddress}'),
                        Text('전화번호: ${record.mart.tel}'),
                      ],
                    ),
                  ),
                ),
              ),

              // 구매 상품 목록
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '구매 상품 목록',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Divider(height: 1),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: record.product.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ProductListItem(
                            rid: record.record.rid,
                            product: record.product[index],
                            onEditPressed: () => _showProductEditDialog(
                              context,
                              record.record.rid,
                              record.product[index],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 총액 정보
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('총 구매 금액'),
                            Text(
                              '${record.totalPrice}원',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Future<void> _showRecordEditDialog(
      BuildContext context,
      DBRecord record,
      ) async {
    final nameController = TextEditingController(text: record.rname);
    final dateController = TextEditingController(text: record.timeStamp);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가계부 정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '영수증 이름'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: '날짜'),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<RecordProvider>();
              final success = await provider.updateRecord(
                record.rid,
                nameController.text,
                dateController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '수정되었습니다.' : '수정에 실패했습니다.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _showProductEditDialog(
      BuildContext context,
      String rid,
      DBProduct product,
      ) async {
    final priceController = TextEditingController(text: product.price.toString());
    final amountController = TextEditingController(text: product.amount.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('상품 정보 수정\n${product.pname}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: '가격'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '수량'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<RecordProvider>();
              final success = await provider.updateProduct(
                rid,
                product.pname,
                int.parse(priceController.text),
                int.parse(amountController.text),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '수정되었습니다.' : '수정에 실패했습니다.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMartEditDialog(BuildContext context, DBMart mart, String rid) async {  // rid 매개변수 추가
    final nameController = TextEditingController(text: mart.martName);
    final addressController = TextEditingController(text: mart.martAddress);
    final telController = TextEditingController(text: mart.tel);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가게 정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '가게명'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: '주소'),
            ),
            TextField(
              controller: telController,
              decoration: const InputDecoration(labelText: '전화번호'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<RecordProvider>();
              final success = await provider.updateMart(
                rid,  // record.record.rid 대신 rid 사용
                nameController.text,
                addressController.text,
                telController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '수정되었습니다.' : '수정에 실패했습니다.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}