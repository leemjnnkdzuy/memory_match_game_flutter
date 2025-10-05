import 'package:flutter/material.dart';

class AccountInfoWidget extends StatelessWidget {
  final String? id;
  final String? email;
  final String? language;
  final String? bio;

  const AccountInfoWidget({
    super.key,
    this.id,
    this.email,
    this.language,
    this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin tài khoản',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.circle,
            label: 'ID người dùng',
            value: id ?? 'Không xác định',
          ),

          if (email?.isNotEmpty == true && language?.isNotEmpty == true)
            SizedBox(height: 12),

          if (email?.isNotEmpty == true)
            _buildInfoRow(icon: Icons.email, label: 'Email', value: email!),

          if (email?.isNotEmpty == true && language?.isNotEmpty == true)
            SizedBox(height: 12),

          if (language?.isNotEmpty == true)
            _buildInfoRow(
              icon: Icons.language,
              label: 'Ngôn ngữ',
              value: language!,
            ),

          if (bio != null && bio!.isNotEmpty) ...[
            SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Tiểu sử:',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 32),
                  child: Text(
                    bio!,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color.fromARGB(179, 0, 0, 0),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 0, 0, 0), size: 20),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 8,
              color: valueColor ?? const Color.fromARGB(179, 0, 0, 0),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
