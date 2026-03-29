import QtQuick
import QtQuick.LocalStorage

QtObject {
    id: sessionManager
    
    property var sessions: []
    property string currentSessionId: ""
    property var currentMessages: []
    
    signal sessionsUpdated()
    
    function getDatabase() {
        return LocalStorage.openDatabaseSync("GeminiKchatSessions", "1.0", "Gemini Kchat Sessions", 1000000)
    }
    
    function init() {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS sessions(id TEXT PRIMARY KEY, title TEXT, model TEXT, timestamp INTEGER, messages TEXT)')
        })
        loadSessions()
    }
    
    function loadSessions() {
        sessions = []
        var db = getDatabase()
        
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT id, title, model, timestamp FROM sessions ORDER BY timestamp DESC')
            for (var i = 0; i < result.rows.length; i++) {
                sessions.push({
                    id: result.rows.item(i).id,
                    title: result.rows.item(i).title,
                    model: result.rows.item(i).model,
                    timestamp: result.rows.item(i).timestamp
                })
            }
        })
        
        sessionsUpdated()
    }
    
    function createSession() {
        var timestamp = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
        var id = Date.now().toString()
        
        currentSessionId = id
        currentMessages = []
        
        return {
            id: id,
            title: timestamp,
            model: "",
            timestamp: Date.now(),
            messages: []
        }
    }
    
    function saveSession(model, messages) {
        if (!currentSessionId) {
            var session = createSession()
            currentSessionId = session.id
        }
        
        if (messages.length === 0) {
            return
        }
        
        var timestamp = Date.now()
        var title = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
        var messagesJson = JSON.stringify(messages)
        
        var db = getDatabase()
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT id FROM sessions WHERE id = ?', [currentSessionId])
            if (result.rows.length === 0) {
                tx.executeSql('INSERT INTO sessions (id, title, model, timestamp, messages) VALUES (?, ?, ?, ?, ?)',
                             [currentSessionId, title, model, timestamp, messagesJson])
            } else {
                tx.executeSql('UPDATE sessions SET model = ?, timestamp = ?, messages = ? WHERE id = ?',
                             [model, timestamp, messagesJson, currentSessionId])
            }
        })
        
        loadSessions()
    }
    
    function loadSession(sessionId) {
        var db = getDatabase()
        var session = null
        
        db.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM sessions WHERE id = ?', [sessionId])
            if (result.rows.length > 0) {
                var row = result.rows.item(0)
                session = {
                    id: row.id,
                    title: row.title,
                    model: row.model,
                    timestamp: row.timestamp,
                    messages: JSON.parse(row.messages)
                }
                currentSessionId = session.id
                currentMessages = session.messages
            }
        })
        
        return session
    }
    
    function deleteSession(sessionId) {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM sessions WHERE id = ?', [sessionId])
        })
        
        if (currentSessionId === sessionId) {
            createSession()
        }
        
        loadSessions()
    }
    
    function updateSessionTitle(sessionId, newTitle) {
        if (!newTitle || newTitle.trim() === "") {
            newTitle = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
        }
        
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('UPDATE sessions SET title = ? WHERE id = ?', [newTitle, sessionId])
        })
        
        loadSessions()
    }
    
    function getCurrentSessionTitle() {
        if (sessions.length === 0) {
            return new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
        }
        
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id === currentSessionId) {
                return sessions[i].title
            }
        }
        
        return new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
    }
}
