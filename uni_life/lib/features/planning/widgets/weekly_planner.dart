import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/study_session.dart';

/// Vista a griglia settimanale: ore × giorni. Le sessioni di studio
/// sono mostrate come tasselli colorati posizionati sulla fascia oraria.
class WeeklyPlanner extends StatelessWidget {
  const WeeklyPlanner({
    super.key,
    required this.weekStart,
    required this.sessions,
    this.startHour = 8,
    this.endHour = 22,
    this.onTapSession,
  });

  final DateTime weekStart;
  final List<StudySession> sessions;
  final int startHour;
  final int endHour;
  final ValueChanged<StudySession>? onTapSession;

  @override
  Widget build(BuildContext context) {
    final hours = endHour - startHour;
    const cellHeight = 28.0;
    const hourColWidth = 44.0;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: SizedBox(
          width: hourColWidth + 7 * 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: hourColWidth),
                  for (int i = 0; i < 7; i++)
                    SizedBox(
                      width: 90,
                      child: Column(
                        children: [
                          Text(
                            AppDateUtils.weekday(
                                weekStart.add(Duration(days: i))),
                            style: TextStyle(
                                fontSize: 12, color: mutedColor),
                          ),
                          Text(
                            '${weekStart.add(Duration(days: i)).day}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: cellHeight * hours,
                child: Stack(
                  children: [
                    // Griglia di sfondo
                    Column(
                      children: List.generate(hours, (h) {
                        return Row(
                          children: [
                            SizedBox(
                              width: hourColWidth,
                              child: Text(
                                '${startHour + h}:00',
                                style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 11),
                              ),
                            ),
                            for (int i = 0; i < 7; i++)
                              Container(
                                width: 90,
                                height: cellHeight,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        color: AppColors.divider, width: 0.5),
                                    right: BorderSide(
                                        color: AppColors.divider, width: 0.5),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                    // Tasselli sessione
                    ...sessions.map((s) {
                      final dayIndex = s.date.difference(weekStart).inDays;
                      if (dayIndex < 0 || dayIndex > 6) {
                        return const SizedBox.shrink();
                      }
                      final startMinutes =
                          s.startTime.hour * 60 + s.startTime.minute;
                      final top =
                          ((startMinutes - startHour * 60) / 60) * cellHeight;
                      final durationMin = s.endTime.difference(s.startTime).inMinutes;
                      final height = (durationMin / 60) * cellHeight;
                      return Positioned(
                        top: top,
                        left: hourColWidth + dayIndex * 90 + 2,
                        width: 86,
                        height: height.clamp(cellHeight - 6, double.infinity),
                        child: Material(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: onTapSession == null
                                ? null
                                : () => onTapSession!(s),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                s.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
