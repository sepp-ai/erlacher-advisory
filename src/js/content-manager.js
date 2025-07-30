/**
 * Content Management System
 * Handles loading and switching between German and English content
 */
class ContentManager {
    constructor() {
        this.currentLanguage = 'de'; // Default to German
        this.content = {};
        this.isLoaded = false;
    }

    /**
     * Initialize the content manager
     */
    async init() {
        try {
            console.log('🔄 Initializing Content Manager...');
            await this.loadContent();
            this.isLoaded = true;
            console.log('✅ Content loaded successfully');
            this.updatePageContent();
            console.log('✅ Page content updated');
            this.setupLanguageSwitcher();
            console.log('✅ Language switcher setup complete');
            console.log('🎉 Content Manager initialized successfully!');
        } catch (error) {
            console.error('❌ Failed to initialize content manager:', error);
        }
    }

    /**
     * Load content from JSON files
     */
    async loadContent() {
        try {
            console.log('📂 Loading content files...');
            
            // Check if files exist first
            const deResponse = await fetch('src/content/de.json');
            const enResponse = await fetch('src/content/en.json');
            
            if (!deResponse.ok) {
                throw new Error(`Failed to load German content: ${deResponse.status} - ${deResponse.statusText}`);
            }
            if (!enResponse.ok) {
                throw new Error(`Failed to load English content: ${enResponse.status} - ${enResponse.statusText}`);
            }
            
            const [deContent, enContent] = await Promise.all([
                deResponse.json(),
                enResponse.json()
            ]);
            
            // Validate content structure
            this.validateContent(deContent, 'German');
            this.validateContent(enContent, 'English');
            
            console.log('📄 German content loaded');
            console.log('📄 English content loaded');
            
            this.content = {
                de: deContent,
                en: enContent
            };
            console.log('📚 Content loaded successfully:', Object.keys(this.content));
        } catch (error) {
            console.error('❌ Failed to load content:', error);
            console.error('❌ This might be due to missing content files or server issues');
            
            // Show user-friendly error message
            this.showContentError(error.message);
            throw error;
        }
    }

    /**
     * Validate content structure
     */
    validateContent(content, language) {
        const requiredSections = ['meta', 'navigation', 'hero', 'expertise', 'companies', 'assessment', 'about', 'cta', 'contact', 'footer'];
        const missingSections = requiredSections.filter(section => !content[section]);
        
        if (missingSections.length > 0) {
            throw new Error(`Missing required sections in ${language} content: ${missingSections.join(', ')}`);
        }
    }

    /**
     * Show content error to user
     */
    showContentError(message) {
        // Create error notification
        const errorDiv = document.createElement('div');
        errorDiv.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #ef4444;
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 8px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            z-index: 10000;
            max-width: 500px;
            text-align: center;
            font-family: inherit;
        `;
        errorDiv.innerHTML = `
            <strong>Content Loading Error</strong><br>
            ${message}<br>
            <small>Please refresh the page or contact support.</small>
        `;
        
        document.body.appendChild(errorDiv);
        
        // Remove after 10 seconds
        setTimeout(() => {
            if (errorDiv.parentNode) {
                errorDiv.remove();
            }
        }, 10000);
    }

    /**
     * Switch language
     */
    switchLanguage(lang) {
        if (!this.content[lang]) {
            console.error(`Language ${lang} not available`);
            return;
        }

        this.currentLanguage = lang;
        this.updatePageContent();
        this.updateLanguageButtons();
        this.updateMetaTags();
        
        // Store current language for other scripts
        window.currentLanguage = lang;
    }

    /**
     * Update all page content with current language
     */
    updatePageContent() {
        if (!this.isLoaded) return;

        const content = this.content[this.currentLanguage];
        
        // Update navigation
        this.updateNavigation(content.navigation);
        
        // Update hero section
        this.updateHero(content.hero);
        
        // Update expertise section
        this.updateExpertise(content.expertise);
        
        // Update companies section
        this.updateCompanies(content.companies);
        
        // Update assessment section
        this.updateAssessment(content.assessment);
        
        // Update about section
        this.updateAbout(content.about);
        
        // Update CTA section
        this.updateCTA(content.cta);
        
        // Update contact section
        this.updateContact(content.contact);
        
        // Update footer
        this.updateFooter(content.footer);
    }

    /**
     * Update navigation content
     */
    updateNavigation(navContent) {
        // Logo
        const logo = document.querySelector('.logo-text');
        if (logo) logo.textContent = navContent.logo;

        // Navigation links
        const navLinks = document.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            const href = link.getAttribute('href');
            if (href === '#expertise') link.textContent = navContent.expertise;
            else if (href === '#about') link.textContent = navContent.about;
            else if (href === '#contact') link.textContent = navContent.contact;
        });
    }

    /**
     * Update hero section content
     */
    updateHero(heroContent) {
        // Hero title
        const heroTitle = document.querySelector('.hero-title');
        if (heroTitle) {
            const highlight = heroTitle.querySelector('.highlight');
            const subtitle = heroTitle.querySelector('span:not(.highlight)');
            if (highlight) highlight.textContent = heroContent.title.highlight;
            if (subtitle) subtitle.textContent = heroContent.title.subtitle;
        }

        // Hero subtitle
        const heroSubtitle = document.querySelector('.hero-subtitle');
        if (heroSubtitle) heroSubtitle.textContent = heroContent.subtitle;

        // CTA buttons
        const ctaButtons = document.querySelectorAll('.hero-cta .btn');
        if (ctaButtons[0]) ctaButtons[0].textContent = heroContent.cta.primary;
        if (ctaButtons[1]) ctaButtons[1].textContent = heroContent.cta.secondary;

        // Hero card
        const heroCard = document.querySelector('.hero-card');
        if (heroCard) {
            const cardTitle = heroCard.querySelector('h3');
            const cardDesc = heroCard.querySelector('p');
            if (cardTitle) cardTitle.textContent = heroContent.card.title;
            if (cardDesc) cardDesc.textContent = heroContent.card.description;
        }
    }

    /**
     * Update expertise section content
     */
    updateExpertise(expertiseContent) {
        // Section header
        const sectionHeader = document.querySelector('#expertise .section-header');
        if (sectionHeader) {
            const title = sectionHeader.querySelector('h2');
            const subtitle = sectionHeader.querySelector('p');
            if (title) title.textContent = expertiseContent.title;
            if (subtitle) subtitle.textContent = expertiseContent.subtitle;
        }

        // Expertise cards
        const expertiseCards = document.querySelectorAll('.expertise-card');
        expertiseCards.forEach((card, index) => {
            const expertise = expertiseContent.items[index];
            if (!expertise) return;

            const icon = card.querySelector('.expertise-icon');
            const title = card.querySelector('h3');
            const description = card.querySelector('p');
            const highlight = card.querySelector('.expertise-highlight');

            if (icon) icon.textContent = expertise.icon;
            if (title) title.textContent = expertise.title;
            if (description) description.textContent = expertise.description;
            if (highlight) highlight.textContent = expertise.highlight;
        });
    }

    /**
     * Update companies section content
     */
    updateCompanies(companiesContent) {
        // Section header
        const sectionHeader = document.querySelector('#companies .section-header');
        if (sectionHeader) {
            const title = sectionHeader.querySelector('h2');
            const subtitle = sectionHeader.querySelector('p');
            if (title) title.textContent = companiesContent.title;
            if (subtitle) subtitle.textContent = companiesContent.subtitle;
        }

        // Companies grid
        const companiesGrid = document.querySelector('.companies-grid');
        if (companiesGrid && companiesContent.categories) {
            companiesGrid.innerHTML = companiesContent.categories.map(category => `
                <div class="career-category">
                    <div class="category-header">
                        <h3>${category.title}</h3>
                        <p>${category.description}</p>
                    </div>
                    <div class="companies-list">
                        ${category.companies.map(company => `
                            <div class="company-item">
                                <div class="company-logo">
                                    <img src="${company.logo}" alt="${company.name} logo" onerror="this.style.display='none'">
                                </div>
                                <div class="company-info">
                                    <h4>${company.name}</h4>
                                    <p class="company-role">${company.role}</p>
                                    <p class="company-period">${company.period}</p>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `).join('');
        }
    }

    /**
     * Update assessment section content
     */
    updateAssessment(assessmentContent) {
        // Section header
        const sectionHeader = document.querySelector('#assessment .section-header');
        if (sectionHeader) {
            const title = sectionHeader.querySelector('h2');
            const subtitle = sectionHeader.querySelector('p');
            if (title) title.textContent = assessmentContent.title;
            if (subtitle) subtitle.textContent = assessmentContent.subtitle;
        }

        // Challenge cards
        const challengeCards = document.querySelectorAll('.challenge-card');
        challengeCards.forEach((card, index) => {
            const challenge = assessmentContent.challenges[index];
            if (!challenge) return;

            const cardTitle = card.querySelector('.challenge-header h3');
            const situationTitle = card.querySelector('.situation h4');
            const situationText = card.querySelector('.situation p');
            const complicationTitle = card.querySelector('.complication h4');
            const complicationText = card.querySelector('.complication p');
            const solutionTitle = card.querySelector('.solution h4');
            const solutionText = card.querySelector('.solution p');

            if (cardTitle) cardTitle.textContent = challenge.title;
            if (situationTitle) situationTitle.textContent = challenge.situation.title;
            if (situationText) situationText.textContent = challenge.situation.text;
            if (complicationTitle) complicationTitle.textContent = challenge.complication.title;
            if (complicationText) complicationText.textContent = challenge.complication.text;
            if (solutionTitle) solutionTitle.textContent = challenge.solution.title;
            if (solutionText) solutionText.textContent = challenge.solution.text;
        });

        // Assessment CTA
        const assessmentCTA = document.querySelector('.assessment-cta');
        if (assessmentCTA) {
            const ctaTitle = assessmentCTA.querySelector('h3');
            const ctaSubtitle = assessmentCTA.querySelector('p');
            const ctaButton = assessmentCTA.querySelector('.btn');
            
            if (ctaTitle) ctaTitle.textContent = assessmentContent.cta.title;
            if (ctaSubtitle) ctaSubtitle.textContent = assessmentContent.cta.subtitle;
            if (ctaButton) ctaButton.textContent = assessmentContent.cta.button;
        }
    }

    /**
     * Update about section content
     */
    updateAbout(aboutContent) {
        // About title and description
        const aboutTitle = document.querySelector('#about h2');
        const aboutDesc = document.querySelector('.about-description');
        if (aboutTitle) aboutTitle.textContent = aboutContent.title;
        if (aboutDesc) aboutDesc.textContent = aboutContent.description;

        // Expertise items
        const expertiseItems = document.querySelectorAll('.expertise-item span');
        expertiseItems.forEach((item, index) => {
            if (aboutContent.expertise[index]) {
                item.textContent = aboutContent.expertise[index];
            }
        });

        // Stats
        const stats = document.querySelectorAll('.stat');
        stats.forEach((stat, index) => {
            const statData = aboutContent.stats[index];
            if (statData) {
                const number = stat.querySelector('.stat-number');
                const label = stat.querySelector('.stat-label');
                if (number) number.textContent = statData.number;
                if (label) label.textContent = statData.label;
            }
        });
    }

    /**
     * Update CTA section content
     */
    updateCTA(ctaContent) {
        const ctaSection = document.querySelector('#book .cta-content');
        if (ctaSection) {
            const title = ctaSection.querySelector('h2');
            const subtitle = ctaSection.querySelector('p');
            const buttons = ctaSection.querySelectorAll('.btn');
            
            if (title) title.textContent = ctaContent.title;
            if (subtitle) subtitle.textContent = ctaContent.subtitle;
            if (buttons[0]) buttons[0].textContent = ctaContent.buttons.primary;
            if (buttons[1]) buttons[1].textContent = ctaContent.buttons.secondary;
        }
    }

    /**
     * Update contact section content
     */
    updateContact(contactContent) {
        // Section header
        const sectionHeader = document.querySelector('#contact .section-header');
        if (sectionHeader) {
            const title = sectionHeader.querySelector('h2');
            const subtitle = sectionHeader.querySelector('p');
            if (title) title.textContent = contactContent.title;
            if (subtitle) subtitle.textContent = contactContent.subtitle;
        }

        // Contact info
        const contactItems = document.querySelectorAll('.contact-item');
        contactItems.forEach((item, index) => {
            const contactInfo = contactContent.info[index];
            if (contactInfo) {
                const title = item.querySelector('h4');
                const link = item.querySelector('a');
                if (title) title.textContent = contactInfo.title;
                if (link) {
                    link.textContent = contactInfo.link;
                    link.href = contactInfo.href;
                    
                    // Handle protected email links
                    if (contactInfo.protected) {
                        link.setAttribute('data-email-protected', 'true');
                        link.href = '#';
                    }
                }
            }
        });


    }

    /**
     * Update footer content
     */
    updateFooter(footerContent) {
        const footer = document.querySelector('.footer');
        if (footer) {
            const logo = footer.querySelector('.logo-text');
            const description = footer.querySelector('.footer-brand p');
            const links = footer.querySelectorAll('.footer-links a');
            const copyright = footer.querySelector('.footer-bottom p');

            if (logo) logo.textContent = footerContent.brand.logo;
            if (description) description.textContent = footerContent.brand.description;
            if (copyright) copyright.textContent = footerContent.copyright;

            links.forEach((link, index) => {
                const linkData = footerContent.links[index];
                if (linkData) {
                    link.textContent = linkData.text;
                    link.href = linkData.href;
                }
            });

            // Update legal links
            const legalLinks = footer.querySelectorAll('.legal-links a');
            if (footerContent.legal && legalLinks.length >= 3) {
                legalLinks[0].textContent = footerContent.legal.privacy;
                legalLinks[1].textContent = footerContent.legal.legal;
                legalLinks[2].textContent = footerContent.legal.cookies;
            }
        }
    }

    /**
     * Update language switcher buttons
     */
    updateLanguageButtons() {
        const langButtons = document.querySelectorAll('.lang-btn');
        langButtons.forEach(btn => {
            btn.classList.remove('active');
            btn.setAttribute('aria-pressed', 'false');
            
            if (btn.dataset.lang === this.currentLanguage) {
                btn.classList.add('active');
                btn.setAttribute('aria-pressed', 'true');
            }
        });
    }

    /**
     * Update meta tags
     */
    updateMetaTags() {
        const content = this.content[this.currentLanguage];
        if (!content) return;

        // Update title
        document.title = content.meta.title;

        // Update meta description
        const metaDesc = document.querySelector('meta[name="description"]');
        if (metaDesc) metaDesc.content = content.meta.description;

        // Update meta keywords
        const metaKeywords = document.querySelector('meta[name="keywords"]');
        if (metaKeywords) metaKeywords.content = content.meta.keywords;


    }

    /**
     * Setup language switcher event listeners
     */
    setupLanguageSwitcher() {
        const langButtons = document.querySelectorAll('.lang-btn');
        langButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                const lang = btn.dataset.lang;
                this.switchLanguage(lang);
            });
        });
    }

    /**
     * Get notification message for current language
     */
    getNotificationMessage(type) {
        const content = this.content[this.currentLanguage];
        if (!content || !content.notifications) return '';
        
        return content.notifications[type] || '';
    }

    /**
     * Get current language
     */
    getCurrentLanguage() {
        return this.currentLanguage;
    }

    /**
     * Check if content is loaded
     */
    isContentLoaded() {
        return this.isLoaded;
    }
}

// Export for use in other scripts
window.ContentManager = ContentManager; 