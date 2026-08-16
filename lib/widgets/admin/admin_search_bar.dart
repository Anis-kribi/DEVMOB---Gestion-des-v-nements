import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// A premium search bar with an optional filter popup button.
///
/// Used in both the Users tab and Events tab of the Admin Dashboard.
class AdminSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final Widget? filterButton;

  const AdminSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.filterButton,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final hasText = controller.text.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: appTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: appTheme.dividerColor,
                width: 1.0,
              ),
              boxShadow: appTheme.softShadow,
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                color: appTheme.textPrimaryColor,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: appTheme.textSecondaryColor,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: appTheme.textSecondaryColor,
                  size: 20,
                ),
                suffixIcon: hasText
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: appTheme.textSecondaryColor,
                          size: 18,
                        ),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                          onClear?.call();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
              ),
            ),
          ),
        ),
        if (filterButton != null) ...[
          const SizedBox(width: 8),
          filterButton!,
        ],
      ],
    );
  }
}

/// A styled filter icon button with an active badge indicator.
class AdminFilterButton extends StatelessWidget {
  final bool isActive;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext) itemBuilder;
  final ValueChanged<dynamic> onSelected;
  final String tooltip;

  const AdminFilterButton({
    super.key,
    required this.isActive,
    required this.itemBuilder,
    required this.onSelected,
    this.tooltip = 'Filtrer',
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryColor.withOpacity(0.15)
            : appTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isActive
              ? AppTheme.primaryColor.withOpacity(0.40)
              : appTheme.dividerColor,
          width: 1.0,
        ),
        boxShadow: appTheme.softShadow,
      ),
      child: PopupMenuButton<dynamic>(
        tooltip: tooltip,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.tune_rounded,
              color: isActive
                  ? AppTheme.primaryColor
                  : appTheme.textSecondaryColor,
              size: 20,
            ),
            if (isActive)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        onSelected: onSelected,
        itemBuilder: itemBuilder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        elevation: 8,
      ),
    );
  }
}
