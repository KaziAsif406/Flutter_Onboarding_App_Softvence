# Alarm Notification Troubleshooting Guide

## If You're Not Getting Alarm Notifications

Follow these steps to ensure alarm notifications are working:

### Step 1: Check Device Notification Settings

**1. Check Notification Permission**
- Go to Settings > Apps > App_onboarding (or your app name)
- Find "Notifications" or "App Notifications"
- Ensure notifications are **enabled** for the app

**2. Check Sound & Vibration**
- Settings > Sound & Vibration
- Make sure the device is not in Silent/Do Not Disturb mode
- Ensure notification volume is not muted
- Check that vibration is enabled (if you want vibration feedback)

**3. Check Do Not Disturb / Battery Saver**
- If "Do Not Disturb" is enabled, alarms might still work but notifications may be silent
- Disable Battery Saver mode while testing

### Step 2: Verify Notification Channel Settings

On Android 8.0+, notification channels control how notifications behave:

1. Go to Settings > Apps > App_onboarding
2. Tap "Notifications"
3. Find the "Alarm Notifications" channel
4. Ensure:
   - Notifications are turned ON
   - Sound is enabled  
   - Vibration is enabled
   - Importance is set to HIGH or MAX

### Step 3: Test Notification System

To verify the notification system is working at all:

1. Create an alarm
2. Set it for 1-2 minutes from the current time
3. **Keep the app in the background** (minimize but don't fully close)
4. Watch for the notification to appear

### Step 4: Check Android Version

**Android 12+**: The app will use inexact alarms (within ~15 minute window) if exact alarm permission is denied. Notifications should still work, just with less precision.

**Android 13+**: The app will request POST_NOTIFICATIONS permission when you open it. Make sure to grant this permission when prompted.

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| No sound | Check device volume, check channel settings, disable Do Not Disturb |
| No vibration | Enable vibration in Settings > Sound & Vibration |
| No visual notification | Check notification permission in app settings |
| Notification appears but late | Device might be in deep sleep/battery saver mode |
| Notification never appears | Restart the app and device, check all permissions |

### Testing Checklist

- [ ] App notifications are enabled in Settings
- [ ] Notification channel (Alarm Notifications) is enabled in app info
- [ ] Device is not in Silent or Do Not Disturb mode
- [ ] Device volume is turned up
- [ ] Battery Saver mode is disabled
- [ ] App is installed from a clean build (flutter clean && flutter run)
- [ ] You've granted all required permissions:
  - POST_NOTIFICATIONS (Android 13+)
  - SCHEDULE_EXACT_ALARM (if using exact alarms)
  - VIBRATE

### Known Limitations

1. **Simulator**: Notification delivery on simulators is unreliable. Test on a real device.
2. **Inexact Alarms**: On devices where exact alarms aren't permitted, notifications may arrive within a 15-minute window of the scheduled time.
3. **Deep Sleep**: If the device is in deep sleep with aggressive battery optimizations, notifications might be delayed.
4. **App Closure**: Very aggressive task killing might prevent scheduled notifications.

### Device-Specific Notes

**Samsung Devices**: Check Battery Optimization and Sleeping Apps settings
- Settings > Battery > App Power Management
- Remove the app from Optimized Apps list

**Xiaomi Devices**: Check MIUI Battery Settings  
- Settings > Battery & Device Care
- Allow app to run in background

**OnePlus Devices**: Check Startup Manager
- Settings > Apps > Startup Manager
- Allow the app to start up

### If Nothing Works

1. **Restart your device** - Many notification issues resolve with a restart
2. **Reinstall the app**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
3. **Check device time**: Ensure device time is correct (alarms are based on system time)
4. **Check device storage**: Low storage can prevent notifications from working
5. **Update the app**: Ensure you have the latest version with all fixes

## For Developers

To debug notification issues:

1. Check logcat for notification-related messages:
   ```bash
   flutter logs | grep -i notification
   ```

2. Test instant notifications:
   - The app can send an instant test notification
   - Use this to verify the notification channel is working

3. Verify timezone setup:
   - Alarms use local device timezone
   - Ensure device timezone is set correctly in Settings

## Technical Details

- **Notification Channel**: `alarm_channel` with MAX importance
- **Schedule Mode**: Exact alarms when possible, inexact alarms as fallback
- **Sound**: System default notification sound
- **Vibration**: Enabled with pattern [0, 500, 250, 500] (Android)
- **Full-screen Intent**: Enabled to wake device screen

---

If you continue to have issues, ensure your device meets all the requirements above and that your app has all necessary permissions granted.
