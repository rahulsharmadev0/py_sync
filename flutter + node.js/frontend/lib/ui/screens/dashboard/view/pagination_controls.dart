import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink(); // Don't show pagination if only one page
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous page button
          if (currentPage > 1)
            _buildPageButton(
              context,
              icon: Icons.arrow_back_ios,
              onTap: () => onPageChanged(currentPage - 1),
            ),

          // First page
          if (currentPage > 3)
            _buildPageButton(context, page: 1, onTap: () => onPageChanged(1)),

          // Ellipsis if needed
          if (currentPage > 3) _buildPageIndicator(),

          // Pages around current page
          for (int i = _startPage; i <= _endPage; i++)
            _buildPageButton(
              context,
              page: i,
              isSelected: i == currentPage,
              onTap: () => onPageChanged(i),
            ),

          // Ellipsis if needed
          if (currentPage < totalPages - 2) _buildPageIndicator(),

          // Last page
          if (currentPage < totalPages - 2)
            _buildPageButton(
              context,
              page: totalPages,
              onTap: () => onPageChanged(totalPages),
            ),

          // Next page button
          if (currentPage < totalPages)
            _buildPageButton(
              context,
              icon: Icons.arrow_forward_ios,
              onTap: () => onPageChanged(currentPage + 1),
            ),
        ],
      ),
    );
  }

  int get _startPage => math.max(1, math.min(currentPage - 1, totalPages - 2));
  int get _endPage => math.min(totalPages, math.max(currentPage + 1, 3));

  Widget _buildPageButton(
    BuildContext context, {
    int? page,
    IconData? icon,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? null : Border.all(color: Colors.black26),
        ),
        child: Center(
          child:
              icon != null
                  ? Icon(
                    icon,
                    size: 14,
                    color: isSelected ? Colors.white : Colors.black54,
                  )
                  : Text(
                    '$page',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: const Text(
        '...',
        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
      ),
    );
  }
}
