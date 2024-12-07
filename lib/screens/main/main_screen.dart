// lib/screens/main/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../analysis/analysis_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/record_provider.dart';
import '../../services/camera_service.dart';
import 'widgets/record_list_item.dart';
import '../profile/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 가계부 탭으로 돌아올 때 데이터 새로고침
    if (index == 0) {
      _refreshRecords();
    }
  }

  Future<void> _refreshRecords() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      await context.read<RecordProvider>().fetchRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('가계부'),
            centerTitle: true,
          ),
          body: authProvider.isAuthenticated
              ? _buildMainContent()
              : const LoginScreen(),
          bottomNavigationBar: authProvider.isAuthenticated
              ? BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: '가계부',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: '분석',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'My',
              ),
            ],
          )
              : null,
        );
      },
    );
  }

  Widget _buildMainContent() {
    final List<Widget> screens = [
      const RecordsScreen(),
      const AnalysisScreen(),
      const ProfileScreen(),
    ];

    return screens[_selectedIndex];
  }
}

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecords();  // 화면이 다시 표시될 때마다 데이터 로드
  }

  Future<void> _loadRecords() async {
    if (!mounted) return;
    await context.read<RecordProvider>().fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            _buildRecordList(context, provider),
            _buildAddButton(context),
          ],
        );
      },
    );
  }

  Widget _buildRecordList(BuildContext context, RecordProvider provider) {
    if (provider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.errorMessage ?? '데이터를 불러오는데 실패했습니다.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecords,  // 재시도 버튼
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (provider.records.isEmpty) {
      return const Center(
        child: Text('등록된 영수증이 없습니다.\n우측 하단의 + 버튼을 눌러 영수증을 추가해보세요.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,  // 당겨서 새로고침
      child: ListView.builder(
        itemCount: provider.records.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final record = provider.records[index];
          return RecordListItem(record: record);
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: () => _showReceiptOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }


  Future<void> _showReceiptOptions(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('영수증 사진 촬영'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('영수증 사진 불러오기'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null || !context.mounted) return;

    final cameraService = CameraService();
    final recordProvider = context.read<RecordProvider>();

    try {
      List<int>? imageBytes;
      if (result == 'camera') {
        imageBytes = await cameraService.captureReceipt();
      } else {
        imageBytes = await cameraService.pickReceiptImage();
      }

      if (imageBytes != null && context.mounted) {
        final success = await recordProvider.uploadReceipt(imageBytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? '영수증이 등록되었습니다.' : '영수증 등록에 실패했습니다.',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('영수증 처리 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}