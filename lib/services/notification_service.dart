import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meal_planner/core/utils/time_formatter.dart';
import 'package:timezone/timezone.dart' as tz;

const _groupKey = 'timer_group';
const _timerGroupChannelId = 'timer_group_channel';
const _timerGroupChannelName = 'Laufende Koch-Timer';

class NotificationService {
  static NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  @visibleForTesting
  static set instance(NotificationService value) => _instance = value;

  static const int summaryNotificationId = 99999;

  static int notificationIdForKey(String key) => key.hashCode.abs() % 90000;
  static int alarmNotificationIdForKey(String key) =>
      90001 + (key.hashCode.abs() % 90000);

  NotificationService._()
      : _plugin = FlutterLocalNotificationsPlugin(),
        _audioPlayer = AudioPlayer() {
    // Auto-resume alarm if the system interrupts playback
    // (e.g. notification shade pull-down causing audio focus loss)
    _audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (_isPlaying && playerState != PlayerState.playing) {
        _audioPlayer.resume();
      }
    });
  }

  @visibleForTesting
  NotificationService.forTesting({
    required FlutterLocalNotificationsPlugin plugin,
    required AudioPlayer audioPlayer,
  })  : _plugin = plugin,
        _audioPlayer = audioPlayer;

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer;

  void Function(String payload)? onNotificationTapped;
  void Function(String actionId)? onNotificationActionReceived;

  Future<void> initialize({
    void Function(NotificationResponse)? onBackgroundResponse,
  }) async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
    _initialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    if (actionId != null) {
      onNotificationActionReceived?.call(actionId);
      return;
    }

    final payload = response.payload;
    if (payload == null) return;
    onNotificationTapped?.call(payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;

    // Vorherige Notification mit gleicher ID canceln falls vorhanden
    await _plugin.cancel(id: id);

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_alarm_channel_v3',
          'Koch-Timer Alarm',
          channelDescription: 'Alarm wenn ein Koch-Timer abgelaufen ist',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('timer_alarm'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final canSchedule = await android?.canScheduleExactNotifications();
    if (canSchedule == false) {
      await android?.requestExactAlarmsPermission();
    }
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> playAlarmSound() async {
    if (_isPlaying) return;
    _isPlaying = true;
    // Use alarm audio stream so the sound is not interrupted by
    // notification shade, audio focus changes, or silent mode
    await _audioPlayer.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        usageType: AndroidUsageType.alarm,
        contentType: AndroidContentType.sonification,
        audioFocus: AndroidAudioFocus.gainTransientExclusive,
      ),
    ));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setSourceAsset('sounds/timer.mp3');
    await _audioPlayer.resume();
  }

  Future<void> stopAlarmSound() async {
    _isPlaying = false;
    await _audioPlayer.stop();
  }

  Future<void> showSummaryNotification({
    required int timerCount,
    DateTime? nearestEndTime,
  }) async {
    final hasChronometer = nearestEndTime != null;

    await _plugin.show(
      id: summaryNotificationId,
      title: '$timerCount Timer aktiv',
      body: hasChronometer ? 'Nächster läuft ab...' : '$timerCount Timer aktiv',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _timerGroupChannelId,
          _timerGroupChannelName,
          channelDescription: 'Zeigt laufende Koch-Timer an',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: hasChronometer,
          usesChronometer: hasChronometer,
          chronometerCountDown: hasChronometer,
          when: nearestEndTime?.millisecondsSinceEpoch,
          groupKey: _groupKey,
          setAsGroupSummary: true,
        ),
      ),
    );
  }

  Future<void> showTimerChildNotification({
    required String key,
    required String recipeTitle,
    required String label,
    required bool isPaused,
    DateTime? endTime,
    int? pausedRemainingSeconds,
  }) async {
    final id = notificationIdForKey(key);
    final hasChronometer = !isPaused && endTime != null;
    final body = isPaused ? '$label: ${formatSeconds(pausedRemainingSeconds ?? 0)} ⏸' : label;

    final pauseAction = AndroidNotificationAction(
      'pause:$key',
      'Pausieren',
      showsUserInterface: false,
      cancelNotification: false,
    );
    final resumeAction = AndroidNotificationAction(
      'resume:$key',
      'Fortsetzen',
      showsUserInterface: false,
      cancelNotification: false,
    );
    final cancelAction = AndroidNotificationAction(
      'cancel:$key',
      'Beenden',
      showsUserInterface: false,
      cancelNotification: true,
    );

    await _plugin.show(
      id: id,
      title: recipeTitle,
      body: body,
      payload: key,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _timerGroupChannelId,
          _timerGroupChannelName,
          channelDescription: 'Zeigt laufende Koch-Timer an',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: hasChronometer,
          usesChronometer: hasChronometer,
          chronometerCountDown: hasChronometer,
          when: endTime?.millisecondsSinceEpoch,
          groupKey: _groupKey,
          actions: isPaused ? [resumeAction, cancelAction] : [pauseAction, cancelAction],
        ),
      ),
    );
  }

  Future<void> cancelTimerChildNotification(String key) async {
    await _plugin.cancel(id: notificationIdForKey(key));
  }

  Future<void> cancelSummaryNotification() async {
    await _plugin.cancel(id: summaryNotificationId);
  }

  Future<Set<int>> getActiveNotificationIds() async {
    final active = await _plugin.getActiveNotifications();
    return active.map((n) => n.id).whereType<int>().toSet();
  }

  /// Shows a persistent notification for a finished timer.
  /// Uses the timer's notificationId so tapping it triggers the same handler.
  Future<void> showTimerFinishedNotification({
    required int id,
    required String recipeTitle,
    required String timerName,
    required String payload,
  }) async {
    await _plugin.show(
      id: id,
      title: recipeTitle,
      body: timerName,
      payload: payload,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_alarm_channel_v3',
          'Koch-Timer Alarm',
          channelDescription: 'Alarm wenn ein Koch-Timer abgelaufen ist',
          importance: Importance.max,
          priority: Priority.high,
          autoCancel: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
