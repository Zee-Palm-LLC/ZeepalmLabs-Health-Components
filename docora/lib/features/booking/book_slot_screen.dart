import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_images.dart';
import '../../core/data/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../home/components/custom_icon_btn.dart';
import '../home/components/custom_shade.dart';
import 'booking_success_screen.dart';
import 'booking_widgets.dart';

class _TimeSlot {
  const _TimeSlot({
    required this.label,
    required this.period,
    this.available = true,
  });

  final String label;
  final int period; // 0 morning, 1 afternoon, 2 evening
  final bool available;
}

class BookSlotScreen extends StatefulWidget {
  const BookSlotScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  State<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends State<BookSlotScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  int _period = 0; // 0 all, 1 morning, 2 afternoon, 3 evening
  int? _slotIndex;
  int _visitType = 0; // 0 clinic, 1 video
  late final AnimationController _entrance;

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static const _allSlots = [
    _TimeSlot(label: '09:00 AM', period: 0),
    _TimeSlot(label: '09:30 AM', period: 0),
    _TimeSlot(label: '10:00 AM', period: 0, available: false),
    _TimeSlot(label: '10:30 AM', period: 0),
    _TimeSlot(label: '11:00 AM', period: 0),
    _TimeSlot(label: '11:30 AM', period: 0, available: false),
    _TimeSlot(label: '01:00 PM', period: 1),
    _TimeSlot(label: '01:30 PM', period: 1),
    _TimeSlot(label: '02:00 PM', period: 1, available: false),
    _TimeSlot(label: '02:30 PM', period: 1),
    _TimeSlot(label: '03:30 PM', period: 1),
    _TimeSlot(label: '04:00 PM', period: 1),
    _TimeSlot(label: '05:00 PM', period: 2),
    _TimeSlot(label: '05:30 PM', period: 2, available: false),
    _TimeSlot(label: '06:00 PM', period: 2),
    _TimeSlot(label: '06:30 PM', period: 2),
    _TimeSlot(label: '07:00 PM', period: 2),
    _TimeSlot(label: '08:00 PM', period: 2),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime(2026, 8, 20);
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = now;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  List<_TimeSlot> get _visibleSlots {
    if (_period == 0) return _allSlots;
    return _allSlots.where((s) => s.period == _period - 1).toList();
  }

  int _availableCount(int periodFilter) {
    if (periodFilter == 0) {
      return _allSlots.where((s) => s.available).length;
    }
    return _allSlots
        .where((s) => s.period == periodFilter - 1 && s.available)
        .length;
  }

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[_selectedDate.weekday - 1]}, '
        '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
  }

  String get _monthTitle {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  List<DateTime?> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // Sunday = 0
    final cells = <DateTime?>[];
    for (var i = 0; i < startWeekday; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(month.year, month.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isPast(DateTime day) {
    final today = DateTime(2026, 8, 20);
    return day.isBefore(today);
  }

  void _confirm() {
    if (_slotIndex == null) return;
    final slots = _visibleSlots;
    final slot = slots[_slotIndex!];
    final periodNames = ['Morning', 'Afternoon', 'Evening'];
    Get.to(
      () => BookingSuccessScreen(
        doctor: widget.doctor,
        dateLabel: _formattedDate,
        timeLabel: slot.label,
        periodLabel: periodNames[slot.period],
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final canBook = _slotIndex != null &&
        _slotIndex! < _visibleSlots.length &&
        _visibleSlots[_slotIndex!].available;
    final cells = _daysInMonth(_focusedMonth);
    final slots = _visibleSlots;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leadingWidth: 56.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: CustomIconBtn(
            icon: Iconsax.arrow_left_2,
            onTap: () => Get.back(),
          ),
        ),
        title: Text(
          'Select Schedule',
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const CustomShade(height: 120),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: BookingFadeSlide(
                    animation: _entrance,
                    begin: 0,
                    end: 0.28,
                    child: const BookingStepBar(step: 2),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      BookingFadeSlide(
                        animation: _entrance,
                        begin: 0.06,
                        end: 0.4,
                        child: _DoctorHeroCard(doctor: d),
                      ),
                      SizedBox(height: 14.h),

                      // Visit type
                      BookingFadeSlide(
                        animation: _entrance,
                        begin: 0.1,
                        end: 0.45,
                        child: _VisitTypeSelector(
                          selected: _visitType,
                          onChanged: (v) => setState(() => _visitType = v),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Calendar card
                      BookingFadeSlide(
                        animation: _entrance,
                        begin: 0.14,
                        end: 0.55,
                        child: _CalendarCard(
                          monthTitle: _monthTitle,
                          weekdayLabels: _weekdayLabels,
                          cells: cells,
                          selectedDate: _selectedDate,
                          isSameDay: _isSameDay,
                          isPast: _isPast,
                          onPrev: () => setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month - 1,
                            );
                            _slotIndex = null;
                          }),
                          onNext: () => setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month + 1,
                            );
                            _slotIndex = null;
                          }),
                          onSelect: (day) {
                            if (_isPast(day)) return;
                            setState(() {
                              _selectedDate = day;
                              _slotIndex = null;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Period filter
                      BookingFadeSlide(
                        animation: _entrance,
                        begin: 0.2,
                        end: 0.6,
                        child: _PeriodFilterBar(
                          selected: _period,
                          counts: [
                            _availableCount(0),
                            _availableCount(1),
                            _availableCount(2),
                            _availableCount(3),
                          ],
                          onChanged: (v) => setState(() {
                            _period = v;
                            _slotIndex = null;
                          }),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Time header
                      Row(
                        children: [
                          Text(
                            'Available times',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '${slots.where((s) => s.available).length} open',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _LegendDot(color: AppColors.primary, label: 'Selected'),
                          SizedBox(width: 12.w),
                          _LegendDot(color: Colors.white, label: 'Available', bordered: true),
                          SizedBox(width: 12.w),
                          _LegendDot(
                            color: AppColors.border,
                            label: 'Booked',
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Time slots grid
                      BookingFadeSlide(
                        animation: _entrance,
                        begin: 0.28,
                        end: 0.72,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: _TimeSlotGrid(
                            key: ValueKey(
                              '${_selectedDate.day}-$_period-$_visitType',
                            ),
                            slots: slots,
                            selectedIndex: _slotIndex,
                            onSelect: (i) {
                              if (!slots[i].available) return;
                              setState(() => _slotIndex = i);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Live summary
                      BookingFadeSlide(
                        animation: _entrance,
                        begin: 0.35,
                        end: 0.85,
                        child: _BookingSummaryCard(
                          doctor: d,
                          dateLabel: _formattedDate,
                          timeLabel: canBook
                              ? slots[_slotIndex!].label
                              : 'Select a time',
                          visitType: _visitType == 0 ? 'Clinic visit' : 'Video call',
                          fee: d.fee,
                          ready: canBook,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      BookingPrimaryButton(
                        label: canBook
                            ? 'Confirm Appointment'
                            : 'Choose date & time',
                        enabled: canBook,
                        icon: Iconsax.calendar_tick,
                        onTap: canBook ? _confirm : null,
                      ),
                      SizedBox(height: 28.h),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitTypeSelector extends StatelessWidget {
  const _VisitTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          _VisitChip(
            icon: Iconsax.hospital,
            label: 'Clinic Visit',
            selected: selected == 0,
            onTap: () => onChanged(0),
          ),
          _VisitChip(
            icon: Iconsax.video,
            label: 'Video Call',
            selected: selected == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _VisitChip extends StatelessWidget {
  const _VisitChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 11.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF4A9AFF), AppColors.primary],
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: selected ? Colors.white : AppColors.muted,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.monthTitle,
    required this.weekdayLabels,
    required this.cells,
    required this.selectedDate,
    required this.isSameDay,
    required this.isPast,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  final String monthTitle;
  final List<String> weekdayLabels;
  final List<DateTime?> cells;
  final DateTime selectedDate;
  final bool Function(DateTime, DateTime) isSameDay;
  final bool Function(DateTime) isPast;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                monthTitle,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              _MonthNavBtn(icon: Iconsax.arrow_left_2, onTap: onPrev),
              SizedBox(width: 6.w),
              _MonthNavBtn(icon: Iconsax.arrow_right_3, onTap: onNext),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              for (final w in weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          for (var row = 0; row < cells.length / 7; row++) ...[
            if (row > 0) SizedBox(height: 4.h),
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      day: cells[row * 7 + col],
                      selected: cells[row * 7 + col] != null &&
                          isSameDay(cells[row * 7 + col]!, selectedDate),
                      past: cells[row * 7 + col] != null &&
                          isPast(cells[row * 7 + col]!),
                      onTap: cells[row * 7 + col] == null
                          ? null
                          : () => onSelect(cells[row * 7 + col]!),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthNavBtn extends StatelessWidget {
  const _MonthNavBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 14.sp, color: AppColors.primary),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.past,
    required this.onTap,
  });

  final DateTime? day;
  final bool selected;
  final bool past;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return SizedBox(height: 40.h);
    }

    final weekend = day!.weekday == DateTime.saturday ||
        day!.weekday == DateTime.sunday;

    return GestureDetector(
      onTap: past ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 40.h,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A9AFF), AppColors.primary],
                )
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3.h),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${day!.day}',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: past
                  ? AppColors.muted.withValues(alpha: 0.45)
                  : selected
                      ? Colors.white
                      : weekend
                          ? AppColors.body
                          : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodFilterBar extends StatelessWidget {
  const _PeriodFilterBar({
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final int selected;
  final List<int> counts;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Iconsax.calendar_1, 'All'),
    (Iconsax.sun_1, 'Morning'),
    (Iconsax.sun, 'Afternoon'),
    (Iconsax.moon, 'Evening'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 88.w,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: active
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4A9AFF), AppColors.primary],
                      )
                    : null,
                color: active ? null : Colors.white,
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : AppColors.border.withValues(alpha: 0.7),
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: Offset(0, 5.h),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _items[i].$1,
                    size: 16.sp,
                    color: active ? Colors.white : AppColors.primary,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _items[i].$2,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.ink,
                    ),
                  ),
                  Text(
                    '${counts[i]} slots',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: active
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.bordered = false,
  });

  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: bordered
                ? Border.all(color: AppColors.border, width: 1.2)
                : null,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _TimeSlotGrid extends StatelessWidget {
  const _TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_TimeSlot> slots;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (var i = 0; i < slots.length; i++)
          _TimeSlotChip(
            slot: slots[i],
            selected: selectedIndex == i,
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  const _TimeSlotChip({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final _TimeSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 16.w * 2 - 8.w * 2) / 3;

    return GestureDetector(
      onTap: slot.available ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: width,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A9AFF), AppColors.primary],
                )
              : null,
          color: selected
              ? null
              : slot.available
                  ? Colors.white
                  : AppColors.border.withValues(alpha: 0.35),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : slot.available
                    ? AppColors.border.withValues(alpha: 0.8)
                    : Colors.transparent,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: Offset(0, 5.h),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              slot.label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : slot.available
                        ? AppColors.ink
                        : AppColors.muted,
                decoration:
                    slot.available ? null : TextDecoration.lineThrough,
                decorationColor: AppColors.muted,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              slot.available
                  ? (selected ? 'Selected' : '30 min')
                  : 'Booked',
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: selected
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({
    required this.doctor,
    required this.dateLabel,
    required this.timeLabel,
    required this.visitType,
    required this.fee,
    required this.ready,
  });

  final DoctorModel doctor;
  final String dateLabel;
  final String timeLabel;
  final String visitType;
  final double fee;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white,
        border: Border.all(
          color: ready
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: ready
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.receipt_1, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                'Appointment summary',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              if (ready)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Ready',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          _SummaryRow(icon: Iconsax.calendar_1, label: 'Date', value: dateLabel),
          SizedBox(height: 8.h),
          _SummaryRow(icon: Iconsax.clock, label: 'Time', value: timeLabel),
          SizedBox(height: 8.h),
          _SummaryRow(icon: Iconsax.video, label: 'Type', value: visitType),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(
              height: 1,
              color: AppColors.border.withValues(alpha: 0.8),
            ),
          ),
          Row(
            children: [
              Text(
                'Consultation fee',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.body,
                ),
              ),
              const Spacer(),
              Text(
                '\$${fee.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.muted),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: AppColors.muted,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _DoctorHeroCard extends StatelessWidget {
  const _DoctorHeroCard({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A9AFF),
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: ClipOval(
              child: SizedBox(
                width: 56.w,
                height: 56.w,
                child: doctor.imageUrl != null
                    ? AppImage(path: doctor.imageUrl!, fit: BoxFit.cover)
                    : ColoredBox(color: doctor.avatarColor),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  doctor.specialty,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Iconsax.star, size: 12.sp, color: AppColors.star),
                    SizedBox(width: 3.w),
                    Flexible(
                      child: Text(
                        '${doctor.rating}  ·  ${doctor.hospital}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
