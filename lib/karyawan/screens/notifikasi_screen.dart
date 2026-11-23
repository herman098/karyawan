import 'package:flutter/material.dart';

import 'package:qnex/karyawan/dummy_data/karyawan_dummy.dart';
import 'package:qnex/karyawan/state/karyawan_store.dart';
import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/karyawan_back_button.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = KaryawanScope.of(context);
    final notifications = store.notifications;
    final compactHeader = MediaQuery.sizeOf(context).width < 400;

    return Scaffold(
      backgroundColor: KaryawanColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KaryawanSpacing.screen,
            16,
            KaryawanSpacing.screen,
            24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Row(
                    children: [
                      KaryawanBackButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifikasi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KaryawanTextStyles.headline.copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      if (store.hasUnreadNotifications)
                        if (compactHeader)
                          IconButton(
                            tooltip: 'Tandai semua dibaca',
                            onPressed: store.markAllRead,
                            icon: const Icon(
                              Icons.done_all_rounded,
                              color: KaryawanColors.brownDark,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: store.markAllRead,
                            style: TextButton.styleFrom(
                              foregroundColor: KaryawanColors.brownDark,
                              textStyle: KaryawanTextStyles.label.copyWith(
                                color: KaryawanColors.brownDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Tandai semua dibaca'),
                          ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Expanded(
                    child: notifications.isEmpty
                        ? const _EmptyNotifications()
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: notifications.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 11),
                            itemBuilder: (context, index) {
                              return _NotificationCard(
                                notification: notifications[index],
                                isRead: store.readStates[index],
                                onTap: () => store.markRead(index),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isRead,
    required this.onTap,
  });

  final SampleNotification notification;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = switch (notification.type) {
      NotificationType.stock => KaryawanColors.dangerAccent,
      NotificationType.transaction => KaryawanColors.success,
      NotificationType.info => KaryawanColors.brown,
    };
    final iconBackground = switch (notification.type) {
      NotificationType.stock => KaryawanColors.dangerBackground,
      NotificationType.transaction => KaryawanColors.successBackground,
      NotificationType.info => KaryawanColors.warningBackground,
    };

    return Material(
      color: KaryawanColors.surface,
      borderRadius: BorderRadius.circular(KaryawanRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isRead
                ? KaryawanColors.surface
                : KaryawanColors.orangeTint.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(KaryawanRadii.card),
            border: Border.all(color: KaryawanColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(KaryawanRadii.icon),
                ),
                child: Icon(notification.icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: KaryawanTextStyles.body.copyWith(
                              color: KaryawanColors.heading,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        AnimatedScale(
                          scale: isRead ? 0 : 1,
                          duration: const Duration(milliseconds: 220),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: KaryawanColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: KaryawanTextStyles.label.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time,
                      style: KaryawanTextStyles.label.copyWith(
                        fontSize: 11,
                        color: KaryawanColors.mutedBrown,
                      ),
                    ),
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

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: KaryawanColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: KaryawanColors.border),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: KaryawanColors.brown,
              size: 31,
            ),
          ),
          const SizedBox(height: 14),
          Text('Semua sudah tenang', style: KaryawanTextStyles.sectionTitle),
          const SizedBox(height: 5),
          Text(
            'Belum ada notifikasi untuk ditampilkan.',
            style: KaryawanTextStyles.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
