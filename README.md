# 🧠 AI Strategy Advisory Website

A modern, multilingual website for AI strategy consulting services, built with HTML, CSS, and JavaScript. Features a comprehensive content management system, accessibility compliance, automated deployment workflow, and full legal compliance for EU/Austrian requirements.

## 🚀 **Quick Start**

### Prerequisites
- Git
- Modern web browser
- Node.js (optional, for development)

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd erlacher-advisory

# Open in browser
open index.html
```

## 📁 **Project Structure**

```
erlacher-advisory/
├── 📄 index.html              # Main website file
├── 📁 src/                    # Source code
│   ├── 📁 css/
│   │   └── styles.css         # Main stylesheet
│   ├── 📁 js/
│   │   ├── script.js          # Main JavaScript
│   │   ├── content-manager.js # Content management system
│   │   └── content-validator.js # Content validation
│   └── 📁 content/
│       ├── de.json           # German content
│       ├── en.json           # English content
│       └── config.json       # Content configuration
├── 📁 scripts/               # Deployment scripts
│   └── deploy.sh             # Comprehensive deployment script
├── 📁 docs/                  # Documentation
├── 📁 logs/                  # Deployment and error logs
├── 📁 assets/                # Static assets (images, etc.)
├── 📄 CNAME                  # Custom domain configuration
├── 📄 package.json           # Project configuration
├── 📄 LICENSE                # License information
├── 📄 .gitignore            # Git ignore rules
├── 📄 privacy-policy.html    # Privacy policy (GDPR compliant)
├── 📄 legal-notice.html      # Legal notice (Austrian requirements)
└── 📄 cookie-policy.html     # Cookie policy
```

## 🌐 **Features**

### **Multilingual Support**
- German and English content
- Dynamic language switching
- SEO-optimized meta tags
- Proper language attributes

### **Content Management**
- JSON-based content system
- Centralized content management
- Content validation
- Easy content updates

### **Accessibility (A11y)**
- ARIA labels and roles
- Keyboard navigation
- Skip links
- High contrast mode support
- Reduced motion support
- Screen reader compatibility

### **Performance Optimized**
- Debounced scroll events
- Optimized CSS and JavaScript
- Efficient DOM manipulation
- Lazy loading support

### **Responsive Design**
- Mobile-first approach
- Tablet and desktop optimized
- Flexible layouts
- Touch-friendly interactions

### **Legal Compliance**
- GDPR compliant privacy policy
- Austrian legal notice (Impressum)
- Cookie policy
- Data protection by design
- No tracking or analytics
- Secure contact forms

## 🚀 **Deployment**

### **Comprehensive Deployment (Recommended)**
```bash
# Full deployment with validation, backup, and rollback
./scripts/deploy.sh
```

### **Validation Only**
```bash
# Check if code is ready for deployment
./scripts/deploy.sh --validate-only
```

### **Quick Deployment (Skip Validation)**
```bash
# Deploy without validation (use with caution)
./scripts/deploy.sh --skip-validation
```

### **Help and Options**
```bash
# Show all available options
./scripts/deploy.sh --help
```

## 📚 **Documentation**

### **Deployment Guide**
- [Complete Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
- [Sustainable Deployment Solution](docs/SUSTAINABLE_DEPLOYMENT_SOLUTION.md)
- [GitHub Pages Setup](docs/GITHUB_PAGES_SETUP.md)

### **Content Management**
- [Content Management Guide](docs/CONTENT_MANAGEMENT.md)
- [Optimization Summary](docs/OPTIMIZATION_SUMMARY.md)

## 🔧 **Development**

### **Local Development**
1. Clone the repository
2. Open `index.html` in a browser
3. Make changes to files in `src/`
4. Test locally
5. Run validation: `./scripts/deploy.sh --validate-only`
6. Deploy: `./scripts/deploy.sh`

### **Content Updates**
1. Edit files in `src/content/`
2. Update German content: `src/content/de.json`
3. Update English content: `src/content/en.json`
4. Update configuration: `src/content/config.json`
5. Test language switching
6. Deploy changes

### **Styling Updates**
1. Edit `src/css/styles.css`
2. Test responsive design
3. Validate accessibility
4. Deploy changes

### **JavaScript Updates**
1. Edit files in `src/js/`
2. Test functionality
3. Check browser compatibility
4. Deploy changes

## 🌐 **Live Website**

- **URL**: https://www.erlacher-advisory.com
- **Languages**: German (DE) and English (EN)
- **Platform**: GitHub Pages
- **Domain**: Custom domain configured

## 📊 **Performance Metrics**

### **Optimization Results**
- **CSS Size**: 21KB (optimized)
- **JavaScript Size**: 16KB (optimized)
- **Load Time**: < 2 seconds
- **Accessibility Score**: 100/100
- **Performance Score**: 95/100

### **Browser Support**
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers

## 🔒 **Security & Privacy**

### **Data Protection**
- **HTTPS**: Enabled via GitHub Pages
- **No Tracking**: No analytics or tracking scripts
- **Privacy Compliant**: Full GDPR compliance
- **Austrian Law**: Compliant with Austrian legal requirements
- **Secure Forms**: Contact form with validation
- **Data Minimization**: Only necessary data collected

### **Legal Documents**
- [Privacy Policy](privacy-policy.html) - GDPR compliant
- [Legal Notice](legal-notice.html) - Austrian requirements
- [Cookie Policy](cookie-policy.html) - Cookie compliance

### **Data Processing**
- **Contact Form**: Data processed only for communication
- **No Storage**: No persistent data storage
- **No Cookies**: No tracking cookies used
- **Transparency**: Clear information about data processing

## 🤝 **Contributing**

### **Development Workflow**
1. Create feature branch
2. Make changes
3. Test locally
4. Run validation
5. Create pull request
6. Deploy after review

### **Code Standards**
- Semantic HTML
- Accessible design
- Mobile-first CSS
- Clean JavaScript
- Comprehensive documentation
- Legal compliance

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 **Support**

For support or questions:
- **Email**: roman.erlacher@gmail.com
- **Website**: https://www.erlacher-advisory.com
- **Documentation**: See `docs/` folder

## 🎯 **Roadmap**

### **Planned Features**
- [ ] Advanced analytics integration (GDPR compliant)
- [ ] Blog functionality
- [ ] Case studies section
- [ ] Client testimonials
- [ ] Advanced contact forms
- [ ] Newsletter integration (with consent)

### **Technical Improvements**
- [ ] CSS minification
- [ ] JavaScript bundling
- [ ] Image optimization
- [ ] CDN integration
- [ ] Advanced caching
- [ ] Performance monitoring

---

**Built with ❤️ for sustainable, accessible, and legally compliant web development** 