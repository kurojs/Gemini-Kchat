import QtQuick 2.15

QtObject {
    id: syntaxHighlighter
    
    function colorToRgba(color, opacity) {
        if (typeof color === 'string') {
            if (color.startsWith('#')) {
                var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(color);
                if (result) {
                    return "rgba(" + parseInt(result[1], 16) + "," + 
                           parseInt(result[2], 16) + "," + 
                           parseInt(result[3], 16) + "," + opacity + ")";
                }
            }
            return color;
        }
        var r = Math.round(color.r * 255);
        var g = Math.round(color.g * 255);
        var b = Math.round(color.b * 255);
        return "rgba(" + r + "," + g + "," + b + "," + opacity + ")";
    }
    
    function escapeHtml(text) {
        return text.replace(/&/g, '&amp;')
                   .replace(/</g, '&lt;')
                   .replace(/>/g, '&gt;');
    }
    
    function cleanGarbageFromCode(code) {
        return code
            .replace(/^\d+\s+/gm, '')
            .replace(/^\d+\./gm, '')
            .trim();
    }
    
    function highlightCode(code, language, config) {
        function colorToString(color) {
            if (!color) return null;
            if (typeof color === 'string') return color;
            if (color.r !== undefined) {
                var r = Math.round(color.r * 255).toString(16).padStart(2, '0');
                var g = Math.round(color.g * 255).toString(16).padStart(2, '0');
                var b = Math.round(color.b * 255).toString(16).padStart(2, '0');
                return '#' + r + g + b;
            }
            return String(color);
        }
        
        var keywordColor = colorToString(config.codeKeywordColor) || '#569cd6';
        var stringColor = colorToString(config.codeStringColor) || '#ce9178';
        var commentColor = colorToString(config.codeCommentColor) || '#6a9955';
        var functionColor = colorToString(config.codeFunctionColor) || '#dcdcaa';
        var numberColor = colorToString(config.codeNumberColor) || '#b5cea8';
        var typeColor = colorToString(config.codeTypeColor) || '#4ec9b0';
        
        var result = code;
        
        var commentPlaceholders = [];
        
        if (language === 'python' || language === 'py') {
            result = result.replace(/"""[\s\S]*?"""/g, function(match) {
                var id = '___COMMENT_' + commentPlaceholders.length + '___';
                commentPlaceholders.push('<span style="color:' + commentColor + ';">' + escapeHtml(match) + '</span>');
                return id;
            });
            result = result.replace(/'''[\s\S]*?'''/g, function(match) {
                var id = '___COMMENT_' + commentPlaceholders.length + '___';
                commentPlaceholders.push('<span style="color:' + commentColor + ';">' + escapeHtml(match) + '</span>');
                return id;
            });
            result = result.replace(/#[^\n]*/g, function(match) {
                var id = '___COMMENT_' + commentPlaceholders.length + '___';
                commentPlaceholders.push('<span style="color:' + commentColor + ';">' + escapeHtml(match) + '</span>');
                return id;
            });
        } else {
            result = result.replace(/\/\/[^\n]*/g, function(match) {
                var id = '___COMMENT_' + commentPlaceholders.length + '___';
                commentPlaceholders.push('<span style="color:' + commentColor + ';">' + escapeHtml(match) + '</span>');
                return id;
            });
            result = result.replace(/\/\*[\s\S]*?\*\//g, function(match) {
                var id = '___COMMENT_' + commentPlaceholders.length + '___';
                commentPlaceholders.push('<span style="color:' + commentColor + ';">' + escapeHtml(match) + '</span>');
                return id;
            });
        }
        
        var stringPlaceholders = [];
        result = result.replace(/"(?:[^"\\]|\\.)*"/g, function(match) {
            var id = '___STRING_' + stringPlaceholders.length + '___';
            stringPlaceholders.push('<span style="color:' + stringColor + ';">' + escapeHtml(match) + '</span>');
            return id;
        });
        result = result.replace(/'(?:[^'\\]|\\.)*'/g, function(match) {
            var id = '___STRING_' + stringPlaceholders.length + '___';
            stringPlaceholders.push('<span style="color:' + stringColor + ';">' + escapeHtml(match) + '</span>');
            return id;
        });
        result = result.replace(/`(?:[^`\\]|\\.)*`/g, function(match) {
            var id = '___STRING_' + stringPlaceholders.length + '___';
            stringPlaceholders.push('<span style="color:' + stringColor + ';">' + escapeHtml(match) + '</span>');
            return id;
        });
        
        result = escapeHtml(result);
        
        var keywords = 'function|const|let|var|if|else|for|while|return|class|def|import|from|try|catch|finally|async|await|new|this|super|in|of|with|switch|case|break|continue|elif|pass|raise|except|as|assert|del|exec|global|lambda|nonlocal|not|or|and|is|yield|print';
        result = result.replace(new RegExp('\\b(' + keywords + ')\\b', 'g'), '<span style="color:' + keywordColor + ';">$1</span>');
        
        result = result.replace(/\b(\d+\.?\d*)\b/g, '<span style="color:' + numberColor + ';">$1</span>');
        
        result = result.replace(/\b([a-zA-Z_]\w*)(?=\.)/g, '<span style="color:' + typeColor + ';">$1</span>');
        
        result = result.replace(/\b([a-zA-Z_]\w*)(?=\()/g, '<span style="color:' + functionColor + ';">$1</span>');
        
        for (var i = 0; i < stringPlaceholders.length; i++) {
            result = result.replace('___STRING_' + i + '___', stringPlaceholders[i]);
        }
        
        for (var i = 0; i < commentPlaceholders.length; i++) {
            result = result.replace('___COMMENT_' + i + '___', commentPlaceholders[i]);
        }
        
        return result;
    }
    
    function wrapUnwrappedCode(text) {
        if (text.indexOf('```') !== -1) return text;

        var lines = text.split('\n');
        var codePatterns = [
            /^(export\s+)?(default\s+)?(async\s+)?function\s+\w+/,
            /^(export\s+)?(default\s+)?class\s+\w+/,
            /^(export\s+)?(const|let|var)\s+\w+\s*=\s*(\(|async\s+\(|function)/,
            /^(export\s+)?(default\s+)?(async\s+)?function\s*\(/,
            /^(import|from|require)\s/,
            /^(if|else|for|while|switch|try|catch|return|throw)\s*[({]/,
            /^\w+\s*:\s*(string|number|boolean|void|any|object|Array|Promise|unknown)\s*[=;,)]/,
            /^\s*(const|let|var)\s+\w+\s*:\s*\w+/,
            /^\s*\w+\.\w+\(/,
            /^\s*<\w+[\s>]/,
            /^\s*(public|private|protected)\s+(static\s+)?(async\s+)?\w+/,
            /^\s*@(import|inject|Component|Injectable|NgModule)/,
            /^\s*(func|def|class|interface|type|enum|struct|impl|pub|fn|mut)\s/,
            /^\s*\w+\s*=\s*\{/,
            /^\s*(print|console\.log|fmt\.Print|System\.out\.println)\s*[\(]/,
        ];

        var naturalPatterns = [
            /^[A-ZÁÉÍÓÚÑ][a-záéíóúñ]/,
            /[.!?]\s*$/,
            /\b(por favor|please|acá|aquí|tenés|tenemos|podes|podemos|esto es|esto es un|es una|es un|son|está|están|como|así|también|además|sin embargo|por lo tanto|en conclusión)\b/i,
            /\b(the|this|that|these|those|here|there|please|note|important|example|following)\b/i,
        ];

        var codeLines = 0;
        var langLines = {};
        var firstCodeIdx = -1;

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line === '' || line === '---' || /^#{1,6}\s/.test(line)) continue;

            var isCode = false;
            for (var p = 0; p < codePatterns.length; p++) {
                if (codePatterns[p].test(line)) { isCode = true; break; }
            }

            if (isCode) {
                codeLines++;
                if (firstCodeIdx === -1) firstCodeIdx = i;
                if (/^(import|from)\s/.test(line)) langLines['typescript'] = (langLines['typescript'] || 0) + 1;
                else if (/^(const|let|var|=>|\})\s/.test(line)) langLines['javascript'] = (langLines['javascript'] || 0) + 1;
                else if (/^(def|class|if __name__|elif|raise)\b/.test(line)) langLines['python'] = (langLines['python'] || 0) + 1;
                else if (/^(fn|let|pub|impl|struct|use)\s/.test(line)) langLines['rust'] = (langLines['rust'] || 0) + 1;
                else if (/^<\/?\w+/.test(line)) langLines['html'] = (langLines['html'] || 0) + 1;
                else if (/^[\.\#]/.test(line)) langLines['css'] = (langLines['css'] || 0) + 1;
            }
        }

        if (codeLines < 2) return text;

        var totalCode = codeLines;
        var totalLang = 0;
        for (var k in langLines) totalLang += langLines[k];
        if (totalLang > 0 && totalCode / lines.length < 0.4) return text;

        var bestLang = '';
        var bestCount = 0;
        for (var lang in langLines) {
            if (langLines[lang] > bestCount) { bestCount = langLines[lang]; bestLang = lang; }
        }

        var codeStart = firstCodeIdx;
        while (codeStart < lines.length && lines[codeStart].trim() === '') codeStart++;

        var before = lines.slice(0, codeStart).join('\n').trim();
        var code = lines.slice(codeStart).join('\n').trim();

        if (before) {
            return before + '\n\n```' + bestLang + '\n' + code + '\n```';
        }
        return '```' + bestLang + '\n' + code + '\n```';
    }

    function formatText(text, config) {
        var result = wrapUnwrappedCode(text);
        var codeBlocks = [];
        var blockIndex = 0;
        
        var codeBlockRegex = /```(\w*)\s*\n?([\s\S]*?)```/g;
        var matches = [];
        var match;
        
        while ((match = codeBlockRegex.exec(text)) !== null) {
            matches.push({
                fullMatch: match[0],
                language: match[1] || '',
                code: match[2],
                index: match.index
            });
        }
        
        for (var i = matches.length - 1; i >= 0; i--) {
            var m = matches[i];
            var placeholder = '___CODEBLOCK_' + i + '___';
            
            var cleanCode = cleanGarbageFromCode(m.code);
            
            var bgColor = colorToRgba(config.codeBackgroundColor, config.codeBackgroundOpacity);
            var fontFamily = config.codeFontFamily || 'Monospace';
            
            var highlighted = highlightCode(cleanCode, m.language, config);
            codeBlocks[i] = '<div style="background-color:' + bgColor + '; padding:12px; border-radius:6px; margin:8px 0; display:block; max-width:100%; box-sizing:border-box; overflow:hidden;"><pre style="margin:0; padding:0; white-space:pre-wrap; word-wrap:break-word; font-family:\'' + fontFamily + '\', monospace; font-size:0.9em; line-height:1.5; overflow-wrap:break-word; max-width:100%;">' + highlighted + '</pre></div>';
            
            result = result.substring(0, m.index) + placeholder + result.substring(m.index + m.fullMatch.length);
            blockIndex++;
        }
        
        for (var i = 0; i < blockIndex; i++) {
            result = result.replace('___CODEBLOCK_' + i + '___', codeBlocks[i]);
        }
        
        var linkColor = config.linkColor || '#4a9eff';
        
        result = result.replace(/\[([^\]]+)\]\(([^)]+)\)/g, function(match, text, url) {
            return '<a href="' + url + '" style="color:' + linkColor + '; text-decoration:underline;">' + text + '</a>';
        });
        
        result = result.replace(/(https?:\/\/[^\s<"]+?)(?=\s|<|$)/g, function(match) {
            return '<a href="' + match + '" style="color:' + linkColor + '; text-decoration:underline;">' + match + '</a>';
        });
        
        var lines = result.split('\n');
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            
            var headerMatch = line.match(/^(#{1,6})\s+(.+)$/);
            if (headerMatch) {
                var level = headerMatch[1].length;
                var headerText = headerMatch[2];
                var sizes = ['1.8em', '1.5em', '1.3em', '1.1em', '1.0em', '0.9em'];
                var size = sizes[level - 1] || '1.0em';
                lines[i] = '<div style="font-size:' + size + '; font-weight:bold; margin:12px 0 8px 0;">' + headerText + '</div>';
                continue;
            }
            
            if (line.match(/^---+$/)) {
                lines[i] = '<hr style="border:none; border-top:1px solid rgba(255,255,255,0.2); margin:12px 0;">';
                continue;
            }
        }
        result = lines.join('\n');
        
        result = result.replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>');
        result = result.replace(/\*([^*]+)\*/g, '<i>$1</i>');
        
        result = result.replace(/`([^`\n]+)`/g, '<code style="font-family:monospace; font-size:0.9em; background-color:rgba(255,255,255,0.1); padding:2px 4px; border-radius:3px;">$1</code>');
        
        result = result.replace(/\n/g, '<br>');
        
        return result;
    }
}