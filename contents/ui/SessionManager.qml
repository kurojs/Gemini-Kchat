import QtQuick
import Qt.labs.settings

Item {
    id: sessionManager
    visible: false

    property var sessions: []
    property string currentSessionId: ""
    property var currentMessages: []
    property var messagesStore: ({})

    signal sessionsUpdated()

    Settings {
        id: storage
        property string sessionsData: ""
        property string lastSessionId: ""
    }

    function getTimestampTitle() {
        return new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '')
    }

    function persist() {
        storage.sessionsData = JSON.stringify({ sessions: sessions, messages: messagesStore })
        if (currentSessionId) {
            storage.lastSessionId = currentSessionId
        }
    }

    function init() {
        var data = null
        try {
            data = JSON.parse(storage.sessionsData)
        } catch(e) {}

        sessions = (data && data.sessions) ? data.sessions : []
        messagesStore = (data && data.messages) ? data.messages : {}
        currentMessages = []

        if (storage.lastSessionId && storage.lastSessionId !== "") {
            currentSessionId = storage.lastSessionId
            if (messagesStore[currentSessionId]) {
                currentMessages = messagesStore[currentSessionId]
            }
        }

        loadSessions()
    }

    function loadSessions() {
        sessionsUpdated()
    }

    function createSession() {
        var timestamp = getTimestampTitle()
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
        currentMessages = messages
        messagesStore[currentSessionId] = messages

        var found = false
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id === currentSessionId) {
                sessions[i].model = model
                sessions[i].timestamp = timestamp
                found = true
                break
            }
        }

        if (!found) {
            sessions.unshift({
                id: currentSessionId,
                title: getTimestampTitle(),
                model: model,
                timestamp: timestamp
            })
        }

        sessions.sort(function(a, b) { return b.timestamp - a.timestamp })
        persist()
        loadSessions()
    }

    function loadSession(sessionId) {
        var session = null

        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id === sessionId) {
                session = sessions[i]
                break
            }
        }

        if (session) {
            currentSessionId = session.id
            currentMessages = messagesStore[sessionId] || []
            return {
                id: session.id,
                title: session.title,
                model: session.model,
                timestamp: session.timestamp,
                messages: currentMessages
            }
        }

        return null
    }

    function deleteSession(sessionId) {
        var newSessions = []
        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id !== sessionId) {
                newSessions.push(sessions[i])
            }
        }
        sessions = newSessions
        delete messagesStore[sessionId]

        if (currentSessionId === sessionId) {
            createSession()
        }

        persist()
        loadSessions()
    }

    function updateSessionTitle(sessionId, newTitle) {
        if (!newTitle || newTitle.trim() === "") {
            newTitle = getTimestampTitle()
        }

        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id === sessionId) {
                sessions[i].title = newTitle
                break
            }
        }

        persist()
        loadSessions()
    }

    function getCurrentSessionTitle() {
        if (sessions.length === 0) {
            return getTimestampTitle()
        }

        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].id === currentSessionId) {
                return sessions[i].title
            }
        }

        return getTimestampTitle()
    }
}