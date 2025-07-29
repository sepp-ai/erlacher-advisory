// Email Protection System
// Prevents email scraping while maintaining compliance

class EmailProtector {
    constructor() {
        this.email = 'roman.erlacher@gmail.com';
        this.encodedEmail = this.encodeEmail(this.email);
        this.init();
    }

    // Simple encoding to prevent basic scraping
    encodeEmail(email) {
        return btoa(email.split('').reverse().join(''));
    }

    // Decode email when needed
    decodeEmail(encoded) {
        return atob(encoded).split('').reverse().join('');
    }

    // Show email only when user interacts
    showEmail(element) {
        if (element.dataset.protected === 'true') {
            element.textContent = this.email;
            element.href = `mailto:${this.email}`;
            element.dataset.protected = 'false';
        }
    }

    // Initialize protection
    init() {
        // Protect all email links
        document.querySelectorAll('[data-email-protected]').forEach(element => {
            element.dataset.protected = 'true';
            element.textContent = 'E-Mail anzeigen';
            element.href = '#';
            element.addEventListener('click', (e) => {
                e.preventDefault();
                this.showEmail(element);
            });
        });

        // Protect legal document emails
        document.querySelectorAll('.protected-email').forEach(element => {
            const email = element.dataset.email;
            if (email) {
                element.addEventListener('click', (e) => {
                    e.preventDefault();
                    element.textContent = email;
                    element.style.cursor = 'default';
                });
                element.style.cursor = 'pointer';
                element.style.textDecoration = 'underline';
                element.style.color = '#3498db';
            }
        });

        // Protect contact form error messages
        this.protectErrorMessages();
    }

    // Protect error messages in forms
    protectErrorMessages() {
        // Store original error messages
        window.originalErrorMessages = {
            de: 'Entschuldigung, es gab einen Fehler. Bitte verwenden Sie das Kontaktformular.',
            en: 'Sorry, there was an error. Please use the contact form.'
        };
    }

    // Get protected email for forms (only when form is submitted)
    getEmailForForm() {
        return this.email;
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.emailProtector = new EmailProtector();
}); 