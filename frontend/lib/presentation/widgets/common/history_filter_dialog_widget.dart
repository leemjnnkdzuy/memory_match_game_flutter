import 'package:flutter/material.dart';
import '../custom/custom_button.dart';

class HistoryFilterDialog extends StatefulWidget {
  final String? selectedDifficulty;
  final bool? selectedIsWin;
  final String? selectedType;
  final Function(String?, bool?, String?) onApply;
  final VoidCallback onClear;

  const HistoryFilterDialog({
    super.key,
    this.selectedDifficulty,
    this.selectedIsWin,
    this.selectedType,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<HistoryFilterDialog> createState() => _HistoryFilterDialogState();
}

class _HistoryFilterDialogState extends State<HistoryFilterDialog> {
  String? _selectedDifficulty;
  bool? _selectedIsWin;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.selectedDifficulty;
    _selectedIsWin = widget.selectedIsWin;
    _selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'LỌC LỊCH SỬ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loại trận đấu
                    _buildSectionTitle('LOẠI TRẬN ĐẤU'),
                    const SizedBox(height: 8),
                    _buildTypeOption('Tất cả', null),
                    _buildTypeOption('Offline', 'offline'),
                    _buildTypeOption('Online', 'online'),

                    // Chỉ hiển thị độ khó và kết quả nếu không phải online
                    if (_selectedType != 'online') ...[
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),

                      // Độ khó
                      _buildSectionTitle('ĐỘ KHÓ'),
                      const SizedBox(height: 8),
                      _buildDifficultyDropdown(),

                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),

                      // Kết quả
                      _buildSectionTitle('KẾT QUẢ'),
                      const SizedBox(height: 8),
                      _buildResultOption('Tất cả', null),
                      _buildResultOption('Thắng', true),
                      _buildResultOption('Thua', false),
                    ],
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(top: BorderSide(color: Colors.black, width: 3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      type: CustomButtonType.warning,
                      onPressed: () {
                        widget.onClear();
                        Navigator.pop(context);
                      },
                      child: const Text('Xóa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      type: CustomButtonType.normal,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      type: CustomButtonType.primary,
                      onPressed: () {
                        widget.onApply(
                          _selectedDifficulty,
                          _selectedIsWin,
                          _selectedType,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 3, color: Colors.black);
  }

  Widget _buildTypeOption(String label, String? value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
          // Reset difficulty and result when switching to online
          if (value == 'online') {
            _selectedDifficulty = null;
            _selectedIsWin = null;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.black,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade700 : Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultOption(String label, bool? value) {
    final isSelected = _selectedIsWin == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIsWin = value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.black,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade700 : Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyDropdown() {
    const difficultyMap = {
      null: 'Tất cả',
      'veryEasy': 'Rất dễ',
      'easy': 'Dễ',
      'normal': 'Bình thường',
      'medium': 'Trung bình',
      'hard': 'Khó',
      'superHard': 'Rất khó',
      'insane': 'Cực khó',
      'expert': 'Chuyên gia',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: DropdownButton<String?>(
        value: _selectedDifficulty,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text('Chọn độ khó'),
        items: difficultyMap.entries.map((entry) {
          return DropdownMenuItem<String?>(
            value: entry.key,
            child: Text(
              entry.value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedDifficulty = value);
        },
      ),
    );
  }
}
