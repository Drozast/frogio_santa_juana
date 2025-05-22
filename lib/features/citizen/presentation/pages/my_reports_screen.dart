// lib/features/citizen/presentation/pages/my_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';
import '../widgets/report_list_item.dart';
import 'create_report_screen.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final String userId;
  
  const MyReportsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late ReportBloc _reportBloc;

  @override
  void initState() {
    super.initState();
    _reportBloc = di.sl<ReportBloc>();
    _loadReports();
  }

  void _loadReports() {
    _reportBloc.add(LoadReportsEvent(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _reportBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Denuncias'),
          actions: [
            BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(context),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreateReportScreen(userId: widget.userId)),
            ).then((_) => _loadReports());
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async => _loadReports(),
          color: AppTheme.primaryColor,
          child: BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state is ReportLoading) {
                return _buildLoadingList();
              } else if (state is ReportsLoaded) {
                return state.filteredReports.isEmpty
                    ? _buildEmptyState(state.currentFilter)
                    : _buildReportsList(state.filteredReports);
              } else if (state is ReportError) {
                return _buildErrorState(state.message);
              } else {
                return _buildLoadingList();
              }
            },
          ),
        ),
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

  Widget _buildEmptyState(String filter) {
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
            filter == 'Todas'
                ? 'No tienes denuncias'
                : 'No tienes denuncias con estado "$filter"',
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
                MaterialPageRoute(builder: (_) => CreateReportScreen(userId: widget.userId)),
              ).then((_) => _loadReports());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<dynamic> reports) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadReports,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final reportBloc = BlocProvider.of<ReportBloc>(context);
    final currentState = reportBloc.state;
    String currentFilter = 'Todas';
    
    if (currentState is ReportsLoaded) {
      currentFilter = currentState.currentFilter;
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(context, 'Todas', currentFilter),
              _buildFilterOption(context, 'Pendiente', currentFilter),
              _buildFilterOption(context, 'En Proceso', currentFilter),
              _buildFilterOption(context, 'Completada', currentFilter),
              _buildFilterOption(context, 'Rechazada', currentFilter),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String status, String currentFilter) {
    final reportBloc = BlocProvider.of<ReportBloc>(context);
    
    return ListTile(
      title: Text(status),
      leading: Radio<String>(
        value: status,
        groupValue: currentFilter,
        activeColor: AppTheme.primaryColor,
        onChanged: (value) {
          if (value != null) {
            reportBloc.add(FilterReportsEvent(filter: value));
            Navigator.pop(context);
          }
        },
      ),
      onTap: () {
        reportBloc.add(FilterReportsEvent(filter: status));
        Navigator.pop(context);
      },
    );
  }
}