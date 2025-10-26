# 🚀 GitHub Actions + Vercel - Quick Setup

## ✅ **What I've Created for You**

1. **`.github/workflows/deploy.yml`** - Automated deployment workflow
2. **`GITHUB_ACTIONS_SETUP.md`** - Complete setup guide
3. **`vercel.json`** - Vercel configuration (already configured)

---

## 🎯 **Quick Start (3 Steps)**

### **Step 1: Get Vercel Secrets**

Go to Vercel and get these:

1. **VERCEL_TOKEN**:
   - https://vercel.com/account/tokens
   - Create new token
   - Copy it (you won't see it again!)

2. **VERCEL_ORG_ID**:
   - Your Vercel dashboard
   - Settings → General
   - Copy "Team ID"

3. **VERCEL_PROJECT_ID**:
   - Go to your project in Vercel
   - Settings → General  
   - Copy "Project ID"

---

### **Step 2: Add to GitHub Secrets**

1. Go to: https://github.com/yourusername/trustseal_app/settings/secrets/actions

2. Click "New repository secret"

3. Add these 3 secrets:
   - Name: `VERCEL_TOKEN` | Value: [your token]
   - Name: `VERCEL_ORG_ID` | Value: [your org ID]
   - Name: `VERCEL_PROJECT_ID` | Value: [your project ID]

---

### **Step 3: Push to GitHub**

```bash
git add .github/workflows/deploy.yml
git add vercel.json install_and_build.sh
git add GITHUB_ACTIONS_SETUP.md

git commit -m "Add GitHub Actions deployment to Vercel"

git push origin main
```

That's it! 🎉 The workflow will automatically:
- ✅ Install Flutter
- ✅ Build your app
- ✅ Deploy to Vercel

---

## 📋 **How It Works**

### **What Happens on Push:**

1. **GitHub Actions Triggers**
   - Runs on every push to `main`
   - Runs on pull requests

2. **Setup Phase**
   - Checks out your code
   - Installs Flutter 3.0
   - Installs dependencies

3. **Build Phase**
   - Runs tests (optional)
   - Builds Flutter web app
   - Creates `build/web` directory

4. **Deploy Phase**
   - Uses Vercel CLI action
   - Uploads to Vercel
   - Your app goes live!

---

## 🎯 **No Manual Configuration Needed**

The workflow handles everything:
- ✅ Flutter installation
- ✅ Dependency management
- ✅ Building web app
- ✅ Deploying to Vercel
- ✅ Environment setup

---

## 📖 **Full Guide**

For detailed instructions, see:
- **`GITHUB_ACTIONS_SETUP.md`** - Complete setup guide

---

**Just add the 3 secrets to GitHub and push! That's all you need!** 🚀

