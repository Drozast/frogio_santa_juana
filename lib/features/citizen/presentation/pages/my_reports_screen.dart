import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/report_entity.dart';
import '../widgets/report_list_item.dart';
import 'create_report_screen.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  bool _isLoading = true;
  late List<ReportEntity> _reports;
  String _filter = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 2));
    
    // Datos de ejemplo
    _reports = _getMockReports();
    
    setState(() {
      _isLoading = false;
    });
  }

  List<ReportEntity> _getMockReports() {
    return [
      ReportEntity(
        id: '1',
        title: 'Luminaria dañada en Calle Principal',
        description: 'La luminaria está completamente apagada desde hace una semana.',
        category: 'Alumbrado Público',
        location: const LocationData(
          latitude: -37.0415,
          longitude: -73.1586,
          address: 'Calle Principal 123, Coronel',
        ),
        citizenId: 'user123',
        muniId: 'muni1',
        status: 'En Proceso',
        imageUrls: ['https://example.com/img1.jpg'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        historyLog: [
          HistoryLogItem(
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            status: 'Enviada',
            userId: 'user123',
          ),
          HistoryLogItem(
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            status: 'En Proceso',
            comment: 'Se ha asignado a un técnico',
            userId: 'admin1',
          ),
        ],
      ),
      ReportEntity(
        id: '2',
        title: 'Basura acumulada en plaza',
        description: 'Hay basura acumulada en la plaza del barrio.',
        category: 'Basura',
        location: const LocationData(
          latitude: -37.0420,
          longitude: -73.1590,
          address: 'Plaza Central, Coronel',
        ),
        citizenId: 'user123',
        muniId: 'muni1',
        status: 'Completada',
        imageUrls: ['https://example.com/img2.jpg'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        historyLog: [
          HistoryLogItem(
            timestamp: DateTime.now().subtract(const Duration(days: 10)),
            status: 'Enviada',
            userId: 'user123',
          ),
          HistoryLogItem(
            timestamp: DateTime.now().subtract(const Duration(days: 8)),
            status: 'En Proceso',
            comment: 'Programada limpieza',
            userId: 'admin1',
          ),
          HistoryLogItem(
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            status: 'Completada',
            comment: 'Se realizó la limpieza de la plaza',
            userId: 'admin1',
          ),
        ],
      ),
      ReportEntity(
        id: '3',
        title: 'Bache en calle Los Pinos',
        description: 'Hay un bache grande que dificulta el tránsito.',
        category: 'Calles y Veredas',
        location: const LocationData(
          latitude: -37.0430,
          longitude: -73.1600,
          address: 'Calle Los Pinos 456, Coronel',
        ),
        citizenId: 'user123',
        muniId: 'muni1',
        status: 'Pendiente',
        imageUrls: ['https://example.com/img3.jpg'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        historyLog: [
          HistoryLogItem(
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            status: 'Enviada',
            userId: 'user123',
          ),
        ],
      ),
    ];
  }

  List<ReportEntity> _getFilteredReports() {
    if (_filter == 'Todas') {
      return _reports;
    }
    return _reports.where((report) => report.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Denuncias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateReportScreen()),
          ).then((_) => _loadReports());
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
        color: AppTheme.primaryColor,
        child: _isLoading
            ? _buildLoadingList()
            : _getFilteredReports().isEmpty
                ? _buildEmptyState()
                : _buildReportsList(),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.report_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _filter == 'Todas'
                ? 'No tienes denuncias'
                : 'No tienes denuncias con estado "$_filter"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Crear Nueva Denuncia'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateReportScreen()),
              ).then((_) => _loadReports());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    final filteredReports = _getFilteredReports();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ReportListItem(
            report: report,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportDetailScreen(reportId: report.id),
                ),
              ).then((_) => _loadReports());
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Todas'),
              _buildFilterOption('Pendiente'),
              _buildFilterOption('En Proceso'),
              _buildFilterOption('Completada'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String status) {
    return ListTile(
      title: Text(status),
      leading: Radio<String>(
        value: status,
        groupValue: _filter,
        activeColor: AppTheme.primaryColor,
        onChanged: (value) {
          setState(() {
            _filter = value!;
          });
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          _filter = status;
        });
        Navigator.pop(context);
      },
    );
  }
}