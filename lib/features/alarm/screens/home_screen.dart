import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/index.dart';
import '../../location/models/location_model.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';

class HomeScreen extends StatefulWidget {
  final LocationModel? selectedLocation;

  const HomeScreen({super.key, this.selectedLocation});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<AlarmModel> _alarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    setState(() => _isLoading = true);
    try {
      final alarms = await AlarmService.getAllAlarms();
      setState(() {
        _alarms = alarms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading alarms: $e')));
      }
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    // Pick date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryPurple,
              surface: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // Pick time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryPurple,
              surface: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // Combine date and time
    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Add alarm
    try {
      await AlarmService.addAlarm(selectedDateTime);
      await _loadAlarms();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alarm added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding alarm: $e')));
      }
    }
  }

  Future<void> _toggleAlarm(AlarmModel alarm) async {
    try {
      await AlarmService.toggleAlarm(alarm.id, !alarm.isEnabled);
      await _loadAlarms();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error toggling alarm: $e')));
      }
    }
  }

  Future<void> _deleteAlarm(String alarmId) async {
    try {
      await AlarmService.deleteAlarm(alarmId);
      await _loadAlarms();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Alarm deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting alarm: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Location Section
              Text(
                AppStrings.selectedLocation,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),

              SizedBox(height: AppDimensions.paddingMedium),

              // Location Display or Add Button
              Container(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkSecondary,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusLarge,
                  ),
                  border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primaryPurple,
                      size: 24,
                    ),
                    SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      child: Text(
                        widget.selectedLocation?.displayName ??
                            'Add your location',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeMedium,
                          fontWeight: FontWeight.w400,
                          color: widget.selectedLocation != null
                              ? AppColors.textWhite
                              : AppColors.textGreySecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.paddingXLarge),

              // Alarms Section
              Text(
                AppStrings.upcomingAlarms,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),

              SizedBox(height: AppDimensions.paddingMedium),

              // Alarms List
              if (_isLoading)
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingXLarge,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPurple,
                    ),
                  ),
                )
              else if (_alarms.isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingXLarge,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppStrings.noAlarms,
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGreySecondary,
                    ),
                  ),
                )
              else
                Column(
                  children: _alarms.map((alarm) {
                    final timeFormat = DateFormat('h:mm a');
                    final dateFormat = DateFormat('EEE d MMM yyyy');

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: AppDimensions.paddingLarge,
                      ),
                      padding: EdgeInsets.all(AppDimensions.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDarkSecondary,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusLarge,
                        ),
                        border: Border.all(
                          color: AppColors.primaryPurple.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeFormat.format(alarm.dateTime),
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontSizeXLarge,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.paddingSmall),
                                Text(
                                  dateFormat.format(alarm.dateTime),
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontSizeMedium,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppDimensions.paddingMedium),
                          Switch(
                            value: alarm.isEnabled,
                            onChanged: (_) => _toggleAlarm(alarm),
                            activeColor: AppColors.primaryPurple,
                            inactiveThumbColor: AppColors.indicatorInactive,
                          ),
                          SizedBox(width: AppDimensions.paddingSmall),
                          GestureDetector(
                            onTap: () => _deleteAlarm(alarm.id),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textGreySecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickDateTime,
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add, color: AppColors.textWhite),
      ),
    );
  }
}
