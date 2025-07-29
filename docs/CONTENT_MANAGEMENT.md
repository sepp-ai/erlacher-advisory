# Content Management System

This document explains how to use the modular content management system for your advisory website.

## Overview

The content management system separates content from code, giving you explicit control over:
- Which expressions are used in both languages
- Content structure and validation
- Language-specific vs. shared content
- Expression consistency across languages

## File Structure

```
content/
├── de.json          # German content
├── en.json          # English content
└── config.json      # Configuration and validation rules

js/
├── content-manager.js    # Main content management system
└── content-validator.js  # Content validation utility
```

## How It Works

### 1. Content Files (`de.json`, `en.json`)

These files contain all your website content organized by sections:

```json
{
  "meta": {
    "title": "Your page title",
    "description": "Your page description"
  },
  "navigation": {
    "logo": "🧠 AI Strategy",
    "advisory": "Beratung"
  },
  "hero": {
    "title": {
      "highlight": "Data & AI Strategie",
      "subtitle": "Beratung"
    }
  }
  // ... more sections
}
```

### 2. Configuration (`config.json`)

Controls how content is managed and validated:

```json
{
  "languageSettings": {
    "defaultLanguage": "de",
    "availableLanguages": ["de", "en"]
  },
  "contentControl": {
    "sharedExpressions": {
      "enabled": true,
      "expressions": ["logo", "email", "calendly_link"]
    }
  }
}
```

## Key Features

### Explicit Expression Control

You can define which expressions should be:
- **Shared**: Same in both languages (e.g., logo, email)
- **Language-specific**: Different in each language (e.g., navigation text)
- **Conditional**: Based on specific rules

### Content Validation

The system automatically validates:
- Required sections and fields
- Expression consistency
- Content completeness
- Terminology consistency

### Easy Content Updates

To update content, simply edit the JSON files:

```json
// In de.json
"hero": {
  "title": {
    "highlight": "Neue KI Strategie",  // Updated German text
    "subtitle": "Beratung"
  }
}

// In en.json  
"hero": {
  "title": {
    "highlight": "New AI Strategy",    // Updated English text
    "subtitle": "Advisory"
  }
}
```

## Managing Expressions

### 1. Shared Expressions

These remain the same across languages:

```json
// config.json
"sharedExpressions": {
  "enabled": true,
  "expressions": [
    "logo",
    "email",
    "calendly_link",
    "linkedin_link"
  ]
}
```

### 2. Language-Specific Expressions

These can differ between languages:

```json
// config.json
"languageSpecificExpressions": {
  "enabled": true,
  "expressions": [
    "navigation",
    "hero_content",
    "services",
    "assessment"
  ]
}
```

### 3. Explicit Expression Control

Define specific terms that should be consistent:

```json
// config.json
"explicitExpressions": {
  "business_terms": {
    "de": ["KI-Strategie", "Enterprise AI", "C-Level"],
    "en": ["AI Strategy", "Enterprise AI", "C-Level"],
    "description": "Business terminology that should be consistent"
  }
}
```

## Content Validation

### Automatic Validation

The system validates content on load:

```javascript
// The content manager automatically validates content
const contentManager = new ContentManager();
await contentManager.init(); // This includes validation
```

### Manual Validation

You can also validate content manually:

```javascript
const validator = new ContentValidator();
await validator.loadConfig();

const validation = await validator.validateAll(deContent, enContent);
console.log(validation.isValid); // true/false
console.log(validation.errors);  // Array of errors
console.log(validation.warnings); // Array of warnings
```

### Validation Rules

The system checks for:
- Missing required sections
- Missing required fields
- Expression consistency
- Content completeness
- Placeholder text
- Empty content

## Adding New Content

### 1. Add to JSON Files

Add new content to both language files:

```json
// In de.json and en.json
"newSection": {
  "title": "New Section Title",
  "description": "New section description",
  "items": [
    {
      "title": "Item 1",
      "description": "Item 1 description"
    }
  ]
}
```

### 2. Update Configuration

Add validation rules in `config.json`:

```json
"requiredSections": [
  "meta",
  "navigation", 
  "hero",
  "newSection"  // Add your new section
],
"requiredFields": {
  "newSection": ["title", "description", "items"]
}
```

### 3. Update Content Manager

Add update method in `content-manager.js`:

```javascript
updateNewSection(newSectionContent) {
  const section = document.querySelector('#newSection');
  if (section) {
    const title = section.querySelector('h2');
    const description = section.querySelector('p');
    if (title) title.textContent = newSectionContent.title;
    if (description) description.textContent = newSectionContent.description;
  }
}
```

## Best Practices

### 1. Content Organization

- Keep related content together in sections
- Use consistent naming conventions
- Group similar content types

### 2. Expression Management

- Use shared expressions for brand elements
- Keep business terminology consistent
- Allow natural language differences

### 3. Validation

- Run validation before deploying
- Fix critical errors immediately
- Review warnings for potential issues

### 4. Content Updates

- Update both language files together
- Test language switching after updates
- Validate content after major changes

## Troubleshooting

### Common Issues

1. **Content not updating**: Check if content manager is initialized
2. **Validation errors**: Review required fields in config
3. **Language switching issues**: Verify content structure matches

### Debug Mode

Enable debug logging:

```javascript
// In browser console
localStorage.setItem('contentDebug', 'true');
// Reload page to see detailed logs
```

### Validation Reports

Get detailed validation reports:

```javascript
const validator = new ContentValidator();
const report = validator.exportValidationReport();
console.log(report);
```

## Migration from Old System

If you're migrating from the old `data-de`/`data-en` system:

1. Extract content from HTML attributes
2. Organize into JSON structure
3. Update configuration
4. Test language switching
5. Remove old attributes from HTML

## Support

For issues or questions:
1. Check validation reports
2. Review configuration settings
3. Verify content structure
4. Test in both languages

The system is designed to be self-documenting and provide clear error messages to help you maintain content consistency. 