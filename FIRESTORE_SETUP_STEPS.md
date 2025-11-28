# Firestore Database Setup - Required Steps

Your Flutter app is fully configured for Firebase, but you need to complete these steps in the Firebase Console to make the database work.

## 🔴 Critical Steps (Must Complete):

### Step 1: Create Firestore Database

1. Go to: https://console.firebase.google.com/project/attendance-88ca6/firestore
2. Click **"Create database"** button
3. Choose **"Start in test mode"** (for development)
4. Select your **region** (choose closest to your location)
5. Click **"Enable"**

⏱️ This takes 1-2 minutes to provision.

### Step 2: Configure Security Rules

After the database is created, go to the **"Rules"** tab and replace the content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Students collection
    match /students/{studentId} {
      allow read, write: if true;
    }

    // Teachers collection
    match /teachers/{teacherId} {
      allow read, write: if true;
    }

    // Attendance collection
    match /attendance/{attendanceId} {
      allow read, write: if true;
    }

    // Participation collection
    match /participation/{participationId} {
      allow read, write: if true;
    }
  }
}
```

Click **"Publish"** to save the rules.

⚠️ **Note**: These rules allow unrestricted access. For production, you should add proper authentication and validation.

### Step 3: Verify Database Structure

After enabling Firestore, you should see these collections (they'll be created automatically when you add the first document):

- `students` - Student records with UID, name, grade/section
- `teachers` - Teacher records with name and subject
- `attendance` - Daily attendance records linked to students
- `participation` - IoT button participation requests

## 🧪 Testing the Database:

### Option 1: Run on Windows (Recommended for Testing)

```bash
flutter run -d windows
```

Once the app starts:
1. Click the **+** button on the Teachers Portal
2. Click **"Add Student"**
3. Generate a UID and enter student details
4. Click **"Add Student"**

Go to Firebase Console → Firestore Database, and you should see the new student in the `students` collection!

### Option 2: Manually Add Test Data

In Firebase Console → Firestore Database:

1. Click **"Start collection"**
2. Collection ID: `students`
3. Add a document with these fields:
   - `uid` (string): "TEST001"
   - `full_name` (string): "Test Student"
   - `grade_section` (string): "Grade 10-A"
   - `created_at` (timestamp): [current time]

## 📱 Current App Features:

Once Firestore is enabled, you can use:

### ✅ Enrollment Management
- **Add Students**: Generate unique UIDs, enter student details
- **Add Teachers**: Add teacher name and subject
- **View Enrolled Students**: Real-time list with search and filter

### ✅ Attendance Tracking
- **Daily Attendance**: View attendance for any date
- **Simulate UID Scan**: Test IoT scanner by selecting a student
- **Present/Absent Status**: Auto-marks absent if no scan
- **Time Tracking**: Records exact scan time

### ✅ Participation System
- **IoT Button Simulation**: Simulate table button presses
- **Accept/Decline**: Teachers can approve participation requests
- **Real-time Notifications**: Get alerts for new requests
- **Status Tracking**: Pending/Accepted/Declined states

### ✅ Reports (Coming Next)
- Attendance reports by date range
- Participation statistics
- PDF export for ISO compliance

## 🔍 Troubleshooting:

### If you see "Permission Denied" errors:
- Make sure you published the security rules in Step 2
- Check that the rules allow `read, write: if true`

### If data isn't appearing:
- Check Firebase Console → Firestore to verify data was saved
- Refresh the app (pull-to-refresh on list screens)
- Check browser console for errors (if running on web)

### If the app crashes on startup:
- Verify `google-services.json` is in `android/app/` directory
- Run `flutter clean && flutter pub get`
- Rebuild the app

## 📊 Database Schema:

### Students Collection
```
students/{studentId}
  - uid: string (unique, for IoT scanner)
  - full_name: string
  - grade_section: string (optional)
  - created_at: timestamp
```

### Teachers Collection
```
teachers/{teacherId}
  - full_name: string
  - subject: string (optional)
  - created_at: timestamp
```

### Attendance Collection
```
attendance/{attendanceId}
  - student_id: string (reference to student)
  - uid: string (for quick lookup)
  - date: timestamp
  - time_scanned: timestamp (optional)
  - status: string ("present" or "absent")
```

### Participation Collection
```
participation/{participationId}
  - table_number: number
  - student_id: string (optional)
  - request_time: timestamp
  - status: string ("pending", "accepted", or "declined")
  - teacher_id: string (optional)
  - approval_time: timestamp (optional)
```

## ✅ Next Steps After Setup:

1. ✅ Enable Firestore Database (Step 1)
2. ✅ Configure Security Rules (Step 2)
3. 🧪 Test by adding a student via the app
4. 📝 Complete the Reports screen implementation
5. 🎨 Set up Android emulator or physical device for mobile testing
6. 🚀 Deploy and test IoT hardware integration

---

**Need Help?** Check the Firebase Console logs at:
https://console.firebase.google.com/project/attendance-88ca6/overview
