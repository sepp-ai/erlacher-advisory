/**
 * Content Validation and Management Utility
 * Ensures content consistency and helps manage expressions across languages
 */
class ContentValidator {
    constructor() {
        this.config = null;
        this.validationErrors = [];
        this.validationWarnings = [];
    }

    /**
     * Load configuration
     */
    async loadConfig() {
        try {
            const response = await fetch('content/config.json');
            this.config = await response.json();
        } catch (error) {
            console.error('Failed to load content configuration:', error);
            throw error;
        }
    }

    /**
     * Validate content structure
     */
    validateContentStructure(content, language) {
        const errors = [];
        const warnings = [];

        // Check required sections
        this.config.contentValidation.requiredSections.forEach(section => {
            if (!content[section]) {
                errors.push(`Missing required section: ${section} in ${language}`);
            }
        });

        // Check required fields within sections
        Object.entries(this.config.contentValidation.requiredFields).forEach(([section, fields]) => {
            if (content[section]) {
                fields.forEach(field => {
                    if (!content[section][field]) {
                        errors.push(`Missing required field: ${section}.${field} in ${language}`);
                    }
                });
            }
        });

        return { errors, warnings };
    }

    /**
     * Validate expression consistency across languages
     */
    validateExpressionConsistency(deContent, enContent) {
        const errors = [];
        const warnings = [];

        // Check shared expressions
        if (this.config.contentControl.sharedExpressions.enabled) {
            this.config.contentControl.sharedExpressions.expressions.forEach(expression => {
                const deValue = this.getNestedValue(deContent, expression);
                const enValue = this.getNestedValue(enContent, expression);
                
                if (deValue !== enValue) {
                    warnings.push(`Shared expression '${expression}' differs between languages: "${deValue}" vs "${enValue}"`);
                }
            });
        }

        // Check explicit expressions
        Object.entries(this.config.expressionControl.explicitExpressions).forEach(([category, terms]) => {
            terms.de.forEach((term, index) => {
                const enTerm = terms.en[index];
                if (term !== enTerm) {
                    warnings.push(`Explicit expression mismatch in ${category}: "${term}" vs "${enTerm}"`);
                }
            });
        });

        return { errors, warnings };
    }

    /**
     * Get nested value from object using dot notation
     */
    getNestedValue(obj, path) {
        return path.split('.').reduce((current, key) => {
            return current && current[key] !== undefined ? current[key] : null;
        }, obj);
    }

    /**
     * Validate content completeness
     */
    validateContentCompleteness(deContent, enContent) {
        const errors = [];
        const warnings = [];

        // Check if all sections exist in both languages
        const deSections = Object.keys(deContent);
        const enSections = Object.keys(enContent);

        const missingInEn = deSections.filter(section => !enSections.includes(section));
        const missingInDe = enSections.filter(section => !deSections.includes(section));

        missingInEn.forEach(section => {
            errors.push(`Section '${section}' missing in English content`);
        });

        missingInDe.forEach(section => {
            errors.push(`Section '${section}' missing in German content`);
        });

        return { errors, warnings };
    }

    /**
     * Validate specific expressions
     */
    validateSpecificExpressions(content, language) {
        const errors = [];
        const warnings = [];

        // Check for placeholder text
        const placeholderPatterns = [
            /\[.*?\]/g,
            /\{.*?\}/g,
            /TODO:/gi,
            /FIXME:/gi,
            /placeholder/gi
        ];

        const contentString = JSON.stringify(content);
        placeholderPatterns.forEach(pattern => {
            const matches = contentString.match(pattern);
            if (matches) {
                warnings.push(`Found placeholder patterns in ${language}: ${matches.join(', ')}`);
            }
        });

        // Check for empty or very short content
        this.checkEmptyContent(content, language, errors, warnings);

        return { errors, warnings };
    }

    /**
     * Check for empty or very short content
     */
    checkEmptyContent(content, language, errors, warnings) {
        const checkValue = (value, path) => {
            if (typeof value === 'string') {
                if (!value.trim()) {
                    errors.push(`Empty content found in ${language}: ${path}`);
                } else if (value.trim().length < 3) {
                    warnings.push(`Very short content found in ${language}: ${path} ("${value}")`);
                }
            } else if (Array.isArray(value)) {
                if (value.length === 0) {
                    warnings.push(`Empty array found in ${language}: ${path}`);
                }
                value.forEach((item, index) => {
                    checkValue(item, `${path}[${index}]`);
                });
            } else if (typeof value === 'object' && value !== null) {
                Object.entries(value).forEach(([key, val]) => {
                    checkValue(val, `${path}.${key}`);
                });
            }
        };

        Object.entries(content).forEach(([section, sectionContent]) => {
            checkValue(sectionContent, section);
        });
    }

    /**
     * Comprehensive validation
     */
    async validateAll(deContent, enContent) {
        if (!this.config) {
            await this.loadConfig();
        }

        this.validationErrors = [];
        this.validationWarnings = [];

        // Validate structure
        const deStructure = this.validateContentStructure(deContent, 'German');
        const enStructure = this.validateContentStructure(enContent, 'English');

        // Validate completeness
        const completeness = this.validateContentCompleteness(deContent, enContent);

        // Validate expression consistency
        const consistency = this.validateExpressionConsistency(deContent, enContent);

        // Validate specific expressions
        const deExpressions = this.validateSpecificExpressions(deContent, 'German');
        const enExpressions = this.validateSpecificExpressions(enContent, 'English');

        // Combine all results
        this.validationErrors = [
            ...deStructure.errors,
            ...enStructure.errors,
            ...completeness.errors,
            ...consistency.errors,
            ...deExpressions.errors,
            ...enExpressions.errors
        ];

        this.validationWarnings = [
            ...deStructure.warnings,
            ...enStructure.warnings,
            ...completeness.warnings,
            ...consistency.warnings,
            ...deExpressions.warnings,
            ...enExpressions.warnings
        ];

        return {
            isValid: this.validationErrors.length === 0,
            errors: this.validationErrors,
            warnings: this.validationWarnings
        };
    }

    /**
     * Get validation report
     */
    getValidationReport() {
        return {
            isValid: this.validationErrors.length === 0,
            errorCount: this.validationErrors.length,
            warningCount: this.validationWarnings.length,
            errors: this.validationErrors,
            warnings: this.validationWarnings,
            summary: {
                totalIssues: this.validationErrors.length + this.validationWarnings.length,
                criticalIssues: this.validationErrors.length,
                minorIssues: this.validationWarnings.length
            }
        };
    }

    /**
     * Suggest content improvements
     */
    suggestImprovements(deContent, enContent) {
        const suggestions = [];

        // Check for missing translations
        const deKeys = this.getAllKeys(deContent);
        const enKeys = this.getAllKeys(enContent);

        const missingInEn = deKeys.filter(key => !enKeys.includes(key));
        const missingInDe = enKeys.filter(key => !deKeys.includes(key));

        if (missingInEn.length > 0) {
            suggestions.push({
                type: 'missing_translation',
                language: 'English',
                keys: missingInEn,
                description: 'These keys are missing in English content'
            });
        }

        if (missingInDe.length > 0) {
            suggestions.push({
                type: 'missing_translation',
                language: 'German',
                keys: missingInDe,
                description: 'These keys are missing in German content'
            });
        }

        // Check for inconsistent terminology
        const terminologySuggestions = this.checkTerminologyConsistency(deContent, enContent);
        suggestions.push(...terminologySuggestions);

        return suggestions;
    }

    /**
     * Get all keys from nested object
     */
    getAllKeys(obj, prefix = '') {
        const keys = [];
        Object.entries(obj).forEach(([key, value]) => {
            const fullKey = prefix ? `${prefix}.${key}` : key;
            keys.push(fullKey);
            
            if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
                keys.push(...this.getAllKeys(value, fullKey));
            }
        });
        return keys;
    }

    /**
     * Check terminology consistency
     */
    checkTerminologyConsistency(deContent, enContent) {
        const suggestions = [];
        const contentString = JSON.stringify({ de: deContent, en: enContent });

        // Check for inconsistent business terms
        const businessTerms = this.config.expressionControl.explicitExpressions.business_terms;
        businessTerms.de.forEach((deTerm, index) => {
            const enTerm = businessTerms.en[index];
            const deCount = (contentString.match(new RegExp(deTerm, 'g')) || []).length;
            const enCount = (contentString.match(new RegExp(enTerm, 'g')) || []).length;
            
            if (deCount !== enCount) {
                suggestions.push({
                    type: 'terminology_inconsistency',
                    term: { de: deTerm, en: enTerm },
                    counts: { de: deCount, en: enCount },
                    description: `Inconsistent usage of business term: ${deTerm}/${enTerm}`
                });
            }
        });

        return suggestions;
    }

    /**
     * Export validation report
     */
    exportValidationReport() {
        const report = this.getValidationReport();
        const timestamp = new Date().toISOString();
        
        return {
            timestamp,
            report,
            config: this.config,
            recommendations: this.validationErrors.length > 0 ? 
                'Fix critical errors before deploying' : 
                'Content is ready for deployment'
        };
    }
}

// Export for use in other scripts
window.ContentValidator = ContentValidator; 