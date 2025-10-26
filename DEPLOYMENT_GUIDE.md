# 🚀 TrustSeal Flutter App - Vercel Deployment Guide

## ⚠️ **Important: Flutter Web on Vercel**

Since TrustSeal is a **Flutter web app** (not a Node.js app), you'll need special configuration for Vercel deployment.

---

## 📋 **Vercel Configuration**

### **Option 1: Using vercel.json (Recommended)**

I've already created `vercel.json` with the correct configuration:

```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "installCommand": "flutter pub get",
  "devCommand": "flutter run -d web-server --web-port 3002"
}
```

### **Vercel Dashboard Settings:**

Don't use the Node.js settings shown in your screenshot. Instead:

#### **Root Directory:**
- ❌ Don't set to "lib"
- ✅ Leave it empty (use project root)

#### **Build and Output Settings:**
Turn ON the toggles and configure:

1. **Build Command:**
   ```
   Toggle: ON
   Command: flutter build web --release
   ```

2. **Output Directory:**
   ```
   Toggle: ON
   Directory: build/web
   ```

3. **Install Command:**
   ```
   Toggle: ON
   Command: flutter pub get
   ```

---

## 🚨 **Critical Requirements**

### **1. You Need Flutter on Vercel**

Vercel doesn't have Flutter installed by default. You have two options:

#### **Option A: Use Flutter Build GitHub Action** (Recommended)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main, master]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build web
        run: flutter build web --release
      
      - name: Deploy to Vercel
        uses: vercel/action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

#### **Option B: Use Vercel with Docker** (Advanced)

Add `vercel-docker.json`:

```json
{
  "builds": [
    {
      "src": "pubspec.yaml",
      "use": "@vercel/docker",
      "config": {
        "dockerfile": "Dockerfile"
      }
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ]
}
```

---

## 🐳 **Dockerfile for Vercel** (If Using Docker)

Create `Dockerfile`:

```dockerfile
FROM ubuntu:22.04

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    libgtk-3-0 \
    libltdl7 \
    libblkid1 \
    libmount1 \
    libpcre2-8-0 \
    libseccomp2 \
    libselinux1 \
    libstdc++6 \
    libuuid1 \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_VERSION=3.0.0
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz | tar -C /usr/local -xJ

# Set working directory
WORKDIR /app

# Copy pubspec
COPY pubspec.yaml ./
COPY pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source
COPY . .

# Build web
RUN flutter build web --release

# Expose port (for Vercel)
EXPOSE 8080

# Serve built files
CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]
```

---

## 🌐 **Better Alternative: Deploy to Firebase Hosting**

For Flutter web apps, **Firebase Hosting** is much easier than Vercel:

### **Quick Firebase Deploy:**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (select Hosting)
firebase init

# Build Flutter web
flutter build web --release

# Deploy
firebase deploy --only hosting
```

Firebase automatically detects Flutter and handles the build!

---

## 🎯 **Recommended Solution**

Since you're using **Flutter web**, I recommend:

### **Use Firebase Hosting** instead of Vercel

**Why?**
- ✅ Built-in Flutter support
- ✅ Automatic build detection
- ✅ Simpler configuration
- ✅ Better for Dart/Flutter apps
- ✅ Free tier is generous

### **Steps:**

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login**
   ```bash
   firebase login
   ```

3. **Initialize Project**
   ```bash
   flutter pub global activate firebase_tools
   firebase init hosting
   ```

4. **Build & Deploy**
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

That's it! Much simpler than Vercel for Flutter apps.

---

## 🔧 **Vercel Alternative Config**

If you must use Vercel, here's what to do in the dashboard:

### **Project Settings:**

**Root Directory:** (Leave empty or set to `.`)

**Build & Output Settings:**

1. **Build Command:**
   - Toggle: **ON**
   - Command: `flutter build web --release`

2. **Output Directory:**
   - Toggle: **ON**
   - Directory: `build/web`

3. **Install Command:**
   - Toggle: **ON**
   - Command: `flutter pub get`

4. **Development Command:**
   - Toggle: **ON**
   - Command: `flutter run -d web-server`

### **Environment Variables:**

Add any needed environment variables:
- `BACKEND_URL` (if different from default)
- `API_BASE_URL`
- `FLUTTER_WEB_CI=true`

---

## ✅ **Summary**

The settings in your screenshot are for **Node.js/JavaScript apps**.

For **Flutter web**, you need:

- ✅ Flutter installed on build environment
- ✅ Custom build command: `flutter build web --release`
- ✅ Output directory: `build/web`
- ✅ Framework detection disabled

### **Easiest Path Forward:**
1. Use **Firebase Hosting** (recommended for Flutter)
2. Or use **GitHub Actions + Vercel**
3. Or configure Vercel with Docker

**Should I set up Firebase Hosting for you instead?** It's much simpler! 🚀

