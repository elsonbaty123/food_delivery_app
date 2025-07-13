import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    required this.title,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.settings),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('تغيير المظهر'),
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
            PopupMenuItem(
              child: const Text('تغيير اللغة'),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false).toggleLocale();
              },
            ),
          ],
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
