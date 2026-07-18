# Notia Quick Start

## 🚀 Get Running in 3 Steps

### 1️⃣ Deploy Backend (5 minutes)

```bash
cd /data/workspace/notia
git init
git add .
git commit -m "Initial Notia MVP"

# Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/notia.git
git push -u origin main
```

**Railway Setup:**
1. Go to [railway.app](https://railway.app)
2. New Project → Deploy from GitHub → Select `notia`
3. Settings → Root Directory: `backend`
4. Variables → Add: `ANTHROPIC_API_KEY=sk-ant-...`
5. Wait for deployment ✅

**Test:**
```bash
curl https://your-app.railway.app/health
```

### 2️⃣ Configure Flutter App (2 minutes)

Edit `app/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-app.railway.app';
```

### 3️⃣ Run App (3 minutes)

```bash
cd app
flutter pub get
flutter run
```

## ✅ You Should See

1. Empty notes list with "Tap + to capture" message
2. Tap **Capture** → Opens voice/text screen
3. Tap **mic icon** → Speak or type a note
4. Tap **Save** → Note appears instantly
5. Wait 2-3 seconds → Category updates automatically

## 🐛 Quick Fixes

**Backend not responding:**
```bash
# Check Railway logs in dashboard
# Verify ANTHROPIC_API_KEY is set
# Test: curl https://your-app.railway.app/health
```

**Flutter build errors:**
```bash
flutter clean && flutter pub get && flutter run
```

**Speech not working:**
- iOS: Settings → Notia → Allow Microphone
- Android: Install Google app for speech services

**Can't connect to backend:**
- Check URL in `api_service.dart`
- Android emulator: use `http://10.0.2.2:8000` for localhost
- iOS simulator: use `http://localhost:8000` for localhost

## 📚 Full Documentation

- `STATUS.md` - What's built and what's next
- `DEPLOYMENT.md` - Detailed deployment guide
- `backend/README.md` - Backend API docs
- `app/README.md` - Flutter app docs

## 🎯 First Test

1. Say: "Buy groceries tomorrow"
2. Should categorize as: **To-Do**

3. Say: "What if we built an AI-powered note app?"
4. Should categorize as: **Business Idea**

5. Say: "The unexamined life is not worth living"
6. Should categorize as: **Philosophical**

## 🆘 Need Help?

1. Check `DEPLOYMENT.md` troubleshooting section
2. Run `flutter doctor -v` for Flutter issues
3. Check Railway deployment logs for backend issues
4. Test backend independently: `curl <url>/api/categorize -X POST -H "Content-Type: application/json" -d '{"text":"test"}'`

---

**Next:** After Phase 1 works, we'll add the home screen widget (Phase 1.5) for true one-tap capture!
