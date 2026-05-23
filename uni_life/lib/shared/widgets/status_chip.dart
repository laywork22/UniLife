import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/enums.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;

  factory StatusChip.forExam(ExamStatus s,
      {VoidCallback? onTap, bool selected = false}) {
    final cfg = switch (s) {
      ExamStatus.prossimo => _ChipCfg('Prossimo', AppColors.info, Icons.schedule),
      ExamStatus.completato =>
        _ChipCfg('Completato', AppColors.success, Icons.check),
      ExamStatus.annullato =>
        _ChipCfg('Annullato', Colors.grey, Icons.close),
    };
    return StatusChip(
      label: cfg.label,
      color: cfg.color,
      icon: cfg.icon,
      onTap: onTap,
      selected: selected,
    );
  }

  factory StatusChip.forPriority(Priority p) {
    final cfg = switch (p) {
      Priority.alta => _ChipCfg('Alta', AppColors.danger, Icons.flag),
      Priority.media => _ChipCfg('Media', AppColors.warning, Icons.flag),
      Priority.bassa => _ChipCfg('Bassa', AppColors.info, Icons.flag),
    };
    return StatusChip(
      label: cfg.label,
      color: cfg.color,
      icon: cfg.icon,
    );
  }

  factory StatusChip.forCourse(CourseStatus s) {
    final cfg = s == CourseStatus.inCorso
        ? _ChipCfg('In corso', AppColors.primary, Icons.menu_book)
        : _ChipCfg('Superato', AppColors.success, Icons.task_alt);
    return StatusChip(label: cfg.label, color: cfg.color, icon: cfg.icon);
  }

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color : color.withValues(alpha: 0.12);
    final fg = selected ? Colors.white : color;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipCfg {
  final String label;
  final Color color;
  final IconData icon;
  _ChipCfg(this.label, this.color, this.icon);
}
