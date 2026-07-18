# Notia - Deployment Guide

Complete setup instructions for deploying Notia backend and running the mobile app.

## Architecture Overview

```
┌─────────────────┐
│  Flutter App    │  ← Voice capture, local SQLite
│  (iOS/Android)  │
└────────┬────────┘
         │ HTTPS
         ↓
┌─────────────────┐
│  Railway API    │  ← FastAPI + Claude
│  (Python)       │
└─────────────────┘
```

## Part 1: Deploy Backend to Railway

### Prerequisites
- GitHub account
- Railway account (free tier works for MVP)
- Anthropic API key

### Step 1: Push Code to GitHub

```bash
cd /data/workspace/notia
git init
git add .
git commit -m "Initial Notia MVP"

# Create new repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/notia.git
git push -u origin main
```

### Step 2: Deploy to Railway

1. Go to [railway.app](https://railway.app)
2. Click **"New Project"** → **"Deploy from GitHub repo"**
3. Select your `notia` repository
4. Railway will detect the Python app in `/backend`

### Step 3: Configure Environment Variables

In Railway dashboard:
1. Click your project → **Variables** tab
2. Add:
   - **Key:** `ANTHROPIC_API_KEY`
   - **Value:** `sk-ant-api03-...` (your Claude API key)

### Step 4: Set Root Directory (Important!)

Railway needs to know the backend is in a subdirectory:

1. Go to **Settings** tab
2. Under **Build & Deploy**:
   - **Root Directory:** `backend`
3. Click **Save**

### Step 5: Deploy

Railway auto-deploys. Watch the logs for:
```
✓ Build successful
✓ Deployment live
```

Your API will be at: `https://your-project-name.railway.app`

### Step 6: Test Backend

```bash
# Check health
curl https://your-project-name.railway.app/health

# Test categorization
curl -X POST https://your-project-name.railway.app/api/categorize \
  -H "Content-Type: application/json" \
  -d '{"text": "Buy groceries tomorrow", "is_developed": false}'
```

Expected response:
```json
{
  "category": "To-Do",
  "confidence": 0.85,
  "suggested_tags": null
}
```

## Part 2: Build & Run Flutter App

### Prerequisites
- Flutter SDK 3.0+ ([install guide](https://docs.flutter.dev/get-started/install))
- Xcode (for iOS) or Android Studio (for Android)

### Step 1: Configure API URL

Edit `app/lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-project-name.railway.app';
```

### Step 2: Install Dependencies

```bash
cd notia/app
flutter pub get
```

### Step 3: Run on Device/Simulator

**iOS:**
```bash
open -a Simulator  # Start iOS simulator
flutter run
```

**Android:**
```bash
# Start Android emulator first, then:
flutter run
```

**Physical Device:**
```bash
flutter devices  # Find your device
flutter run -d <device-id>
```

## Part 3: Testing the Full Flow

1. **Open app** → Should see empty notes list
2. **Tap "Capture"** button
3. **Tap microphone** → Speak: "Buy milk tomorrow"
4. **Tap "Save Note"**
5. **Check notes list** → Note appears immediately
6. **Wait 2-3 seconds** → Category updates to "To-Do"

### Expected Behavior

✅ Note saves instantly (even if offline)  
✅ Category shows "Categorizing..." initially  
✅ Category updates in background  
✅ Can browse/search notes  

## Troubleshooting

### Backend Issues

**"Application failed to respond"**
- Check Railway logs: Project → **Deployments** → Click latest deployment
- Verify `ANTHROPIC_API_KEY` is set
- Ensure root directory is `backend`

**"Module not found" errors**
- Railway should auto-install from `requirements.txt`
- Check build logs for pip errors

**CORS errors from app**
- Backend has CORS enabled for all origins (Phase 1)
- In production, restrict to your domain

### App Issues

**Speech recognition doesn't work**
- iOS: Grant microphone permission in Settings
- Android: Ensure Google app is installed
- Test with typed input first

**"Failed to categorize note"**
- Note still saves! Category will be "Uncategorized"
- Check backend URL in `api_service.dart`
- Test backend health endpoint manually

**Build errors**
```bash
flutter clean
flutter pub get
flutter run
```

## Cost Estimates (Phase 1)

### Railway
- **Free tier:** 500 hours/month, $5 credit
- **Paid:** ~$5-10/month for basic usage
- Your usage: Likely free tier is sufficient

### Claude API
- **Cost:** ~$3 per 1M input tokens, $15 per 1M output tokens
- **Your usage:** 
  - Average note: ~50 tokens input, ~10 tokens output
  - 100 notes/day = ~$0.03/day = **~$1/month**

### Total: $0-6/month for Phase 1

## Next Steps

### Phase 1.5: Home Screen Widget
- Add Android/iOS widget for instant capture
- One-tap voice recording from home screen
- No app launch required

### Phase 2: Smart Organization
- Hierarchical categories
- Project assignment
- Weekly consolidation agent

### Phase 3: Agent Layer
- Follow-up questions for developed notes
- Chat threads per note
- Digest/nudge system

## Security Checklist (Before Production)

- [ ] Restrict CORS origins in backend
- [ ] Add rate limiting to API
- [ ] Implement user authentication
- [ ] Encrypt sensitive data at rest
- [ ] Use HTTPS only (Railway does this automatically)
- [ ] Review API key permissions (Anthropic dashboard)

## Monitoring

### Railway Dashboard
- Watch **Metrics** for CPU/memory usage
- Check **Deployments** for uptime
- Review **Logs** for errors

### App Analytics (Future)
- Firebase Analytics
- Crashlytics
- User feedback system

## Support

**Backend issues:** Check Railway logs first  
**App issues:** Run `flutter doctor -v`  
**API issues:** Test with `curl` commands above

---

## Quick Reference

**Backend health check:**
```bash
curl https://your-app.railway.app/health
```

**Railway logs:**
```bash
# Install Railway CLI
npm i -g @railway/cli
railway login
railway logs
```

**Flutter logs:**
```bash
flutter logs
```

**Restart everything:**
```bash
# Backend: Push to GitHub (Railway auto-deploys)
git push

# App: Stop and restart
flutter run
```
