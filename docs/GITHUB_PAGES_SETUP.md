# GitHub Pages Setup Guide

This guide will walk you through setting up your AI Strategy Advisor website on GitHub Pages.

## 🚀 Quick Setup (5 minutes)

### Step 1: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the **"+"** button in the top right → **"New repository"**
3. Name your repository: `erlacher-advisory`
4. Make it **Public** (required for free GitHub Pages)
5. **Don't** initialize with README (we already have one)
6. Click **"Create repository"**

### Step 2: Upload Your Files

#### Option A: Using GitHub Web Interface
1. In your new repository, click **"uploading an existing file"**
2. Drag and drop all files from your local folder:
   - `index.html`
   - `styles.css`
   - `script.js`
   - `README.md`
   - `.gitignore`
   - `package.json`
   - `.github/` folder
3. Add commit message: `"Initial website upload"`
4. Click **"Commit changes"**

#### Option B: Using Git Commands (Recommended)
```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial website upload"

# Add remote repository
git remote add origin https://github.com/sepp-ai/erlacher-advisory.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **"Settings"** tab
3. Scroll down to **"Pages"** section (in left sidebar)
4. Under **"Source"**, select **"Deploy from a branch"**
5. Choose **"gh-pages"** branch
6. Click **"Save"**

### Step 4: Wait for Deployment

- GitHub Actions will automatically build and deploy your site
- Check the **"Actions"** tab to see deployment progress
- Your site will be available at: `https://sepp-ai.github.io/erlacher-advisory`

## 🔧 Custom Domain Setup (Optional)

### Step 1: Buy a Domain
- Purchase a domain from providers like:
  - [Namecheap](https://namecheap.com)
  - [GoDaddy](https://godaddy.com)
  - [Google Domains](https://domains.google)

### Step 2: Configure DNS
1. In your domain provider's DNS settings, add these records:
   ```
   Type: CNAME
   Name: @
   Value: YOUR_USERNAME.github.io
   ```

### Step 3: Add Custom Domain to GitHub Pages
1. Go to repository **Settings** → **Pages**
2. In **"Custom domain"** field, enter your domain
3. Check **"Enforce HTTPS"**
4. Click **"Save"**

### Step 4: Update Website Files
Update these files with your custom domain:

**In `index.html`:**
```html
<!-- Note: Social media meta tags have been removed as this site focuses on LinkedIn only -->
```

**In `package.json`:**
```json
"homepage": "https://yourdomain.com"
```

## 📝 Update Your Information

Before deploying, update these files with your actual information:

### 1. Contact Information (`index.html`)
```html
<!-- Replace these with your actual details -->
<a href="mailto:your-actual-email@domain.com">your-actual-email@domain.com</a>
<a href="https://linkedin.com/in/your-profile" target="_blank">Connect on LinkedIn</a>
<a href="https://calendly.com/your-calendly" target="_blank">Schedule a Meeting</a>
```

### 2. Repository Information (`package.json`)
```json
{
  "author": "Roman Erlacher",
  "repository": {
    "url": "https://github.com/sepp-ai/erlacher-advisory.git"
  },
  "homepage": "https://sepp-ai.github.io/erlacher-advisory"
}
```

## 🔄 Making Updates

### Option A: GitHub Web Interface
1. Go to your repository
2. Click on the file you want to edit
3. Click the pencil icon (Edit)
4. Make your changes
5. Scroll down and click **"Commit changes"**

### Option B: Git Commands
```bash
# Pull latest changes
git pull origin main

# Make your changes to files

# Add and commit changes
git add .
git commit -m "Update website content"

# Push to GitHub
git push origin main
```

## 🎯 GitHub Pages Features

### Automatic Deployment
- Every push to `main` branch triggers automatic deployment
- Check **"Actions"** tab for deployment status
- Site updates within 2-5 minutes

### HTTPS by Default
- All GitHub Pages sites use HTTPS
- No additional SSL certificate needed

### Custom 404 Page
Create a `404.html` file for custom error pages:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Page Not Found</title>
</head>
<body>
    <h1>Page Not Found</h1>
    <p>Sorry, the page you're looking for doesn't exist.</p>
    <a href="/">Go Home</a>
</body>
</html>
```

## 🚨 Troubleshooting

### Site Not Loading
1. Check **"Actions"** tab for deployment errors
2. Verify branch name is `gh-pages`
3. Wait 5-10 minutes for initial deployment

### Custom Domain Not Working
1. Check DNS settings (CNAME record)
2. Wait up to 24 hours for DNS propagation
3. Verify domain is added in GitHub Pages settings

### Images Not Loading
1. Ensure image paths are relative (not absolute)
2. Check file names match exactly (case-sensitive)
3. Verify images are committed to repository

## 📊 Analytics Setup

### Google Analytics
Add this to `index.html` before `</head>`:
```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## 🎉 Success!

Your website will be live at:
- **GitHub Pages URL**: `https://sepp-ai.github.io/erlacher-advisory`
- **Custom Domain** (if configured): `https://yourdomain.com`

The site will automatically update whenever you push changes to the `main` branch!

---

**Need help?** Check the main `README.md` for more detailed information about the website features and customization options. 