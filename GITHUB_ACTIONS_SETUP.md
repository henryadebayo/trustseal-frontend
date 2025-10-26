# 🚀 GitHub Actions + Vercel Setup Guide

This guide will walk you through setting up automated deployment of TrustSeal from GitHub to Vercel.

---

## 📋 **Step-by-Step Setup**

### **Step 1: Get Vercel Secrets**

You need to get these from your Vercel dashboard:

1. **Go to Vercel Dashboard**
   - Navigate to: https://vercel.com/dashboard
   
2. **Select or Create Project**
   - Create a new project for TrustSeal
   - Link it to your GitHub repository
   
3. **Get Project Details**
   - Go to: Settings → General
   - Copy:
     - **Project ID**
     - **Team/Org ID**
   
4. **Get Access Token**
   - Go to: https://vercel.com/account/tokens
   - Create a new token
   - Copy the token (you won't see it again!)

---

### **Step 2: Add GitHub Secrets**

You need to add these secrets to your GitHub repository:

1. **Go to GitHub Repository**
   - Navigate to: https://github.com/yourusername/trustseal_app
   
2. **Go to Settings**
   - Click "Settings" tab in repository
   
3. **Go to Secrets**
   - Settings → Secrets and variables → Actions
   
4. **Add Repository Secrets**
   Click "New repository secret" and add:

   **Secret 1: VERCEL_TOKEN**
   - Name: `VERCEL_TOKEN`
   - Value: Your Vercel access token (from Step 1)

   **Secret 2: VERCEL_ORG_ID**
   - Name: `VERCEL_ORG_ID`
   - Value: Your Vercel Team/Org ID

   **Secret 3: VERCEL_PROJECT_ID**
   - Name: `VERCEL_PROJECT_ID`
   - Value: Your Vercel Project ID

---

### **Step 3: Push to GitHub**

Commit and push the GitHub Actions workflow:

```bash
# Add the new files
git add .github/workflows/deploy.yml
git add vercel.json

# Commit
git commit -m "Add GitHub Actions deployment workflow"

# Push to trigger first deployment
git push origin main
```

---

### **Step 4: Monitor Deployment**

1. **Watch GitHub Actions**
   - Go to: GitHub → Actions tab
   - You'll see "Deploy TrustSeal to Vercel" workflow running
   - Click on it to see progress

2. **Watch Vercel Dashboard**
   - Go to: https://vercel.com/dashboard
   - You'll see a new deployment in progress
   - Wait for it to complete

3. **Get Your URL**
   - Once deployed, you'll get a URL like: `https://trustseal-app.vercel.app`
   - This is your live app!

---

## 🔧 **What the Workflow Does**

### **Automatic Deployment Process:**

1. **Trigger**: On every push to `main` or `master` branch
2. **Checkout**: Clone your code
3. **Setup Flutter**: Install Flutter 3.0 on Ubuntu
4. **Install Dependencies**: Run `flutter pub get`
5. **Run Tests**: Execute test suite (optional)
6. **Build Web**: Run `flutter build web --release`
7. **Deploy to Vercel**: Upload built files to Vercel
8. **Done**: Your app is live!

---

## 🎯 **Manual Deployment Options**

### **Option 1: Vercel CLI** (Recommended for Testing)

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Link project
vercel link

# Deploy
vercel --prod
```

### **Option 2: Vercel Dashboard**

1. Go to https://vercel.com/dashboard
2. Click "Import Project"
3. Connect GitHub repository
4. Configure settings (from vercel.json)
5. Click "Deploy"

### **Option 3: Vercel Git Integration**

1. Connect GitHub repo in Vercel dashboard
2. Configure build settings
3. Every push to main branch auto-deploys

---

## ⚙️ **Configuration Details**

### **What Gets Deployed:**

- ✅ **Build Output**: `build/web` directory
- ✅ **Static Files**: All HTML, CSS, JS from Flutter build
- ✅ **Configuration**: `vercel.json` settings
- ✅ **Environment**: Any env vars you set in Vercel dashboard

### **Build Settings in Vercel:**

After first deployment, you can update in Vercel dashboard:

**Build & Development Settings:**
- Build Command: (Managed by GitHub Actions)
- Output Directory: `build/web`
- Install Command: Not needed (done in GitHub Actions)
- Development Command: `flutter run -d web-server`

**Environment Variables:**
Add any backend URLs or API keys:
- `BACKEND_URL`: Your backend API URL
- `API_BASE_URL`: API base URL
- `FLUTTER_WEB_CI`: `true`

---

## 🐛 **Troubleshooting**

### **GitHub Actions Fails**

**Error: "Flutter not found"**
- ✅ Already handled in workflow
- Uses subosito/flutter-action

**Error: "Secrets not found"**
- ✅ Check that you added all 3 secrets to GitHub
- Verify secret names are exact

**Error: "Vercel token invalid"**
- ✅ Recreate Vercel token
- Update `VERCEL_TOKEN` secret

### **Build Fails**

**Error: "Build command not found"**
- ✅ Workflow uses custom build script
- Should work automatically

**Error: "Output directory not found"**
- ✅ Verify `build/web` exists after build
- Check Flutter build logs

### **Deployment Fails**

**Error: "Project not found"**
- ✅ Verify VERCEL_PROJECT_ID is correct
- Check VERCEL_ORG_ID is correct

**Error: "Unauthorized"**
- ✅ Check VERCEL_TOKEN is valid
- Recreate token if expired

---

## ✅ **Verification Checklist**

After deployment:

- [ ] GitHub Actions workflow completes successfully
- [ ] Vercel deployment shows "Ready" status
- [ ] App loads at your Vercel URL
- [ ] Backend connection works
- [ ] Authentication works
- [ ] All features functional

---

## 🚀 **Next Steps**

### **Custom Domain**

1. Go to Vercel project settings
2. Add your custom domain
3. Update DNS records
4. Wait for SSL certificate

### **Environment Variables**

Add to Vercel dashboard:
- `BACKEND_URL`: Backend API URL
- `API_BASE_URL`: API base URL
- Any other env vars needed

### **Continuous Deployment**

- ✅ Every push to `main` auto-deploys
- ✅ Pull requests get preview deployments
- ✅ All deployments are versioned

---

## 📞 **Support**

If you encounter issues:

1. Check GitHub Actions logs
2. Check Vercel deployment logs
3. Review vercel.json configuration
4. Check Flutter build locally first

---

**Your setup is ready! Push to GitHub and watch it deploy! 🎉**

