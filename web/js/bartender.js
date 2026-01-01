document.addEventListener('DOMContentLoaded', () => {
    const chatHistory = document.getElementById('chat-history');
    const userInput = document.getElementById('user-input');
    const sendBtn = document.getElementById('send-btn');

    // Conversation history to maintain context
    let conversationHistory = [];

    // Initialize with system prompt
    if (CONFIG && CONFIG.bartender && CONFIG.bartender.systemPrompt) {
        conversationHistory.push({
            role: "user",
            parts: [{ text: CONFIG.bartender.systemPrompt }]
        });
        conversationHistory.push({
             role: "model",
             parts: [{ text: "Understood. I am ready to act as a bartender." }]
        });
    }

    // Check for API Key
    const apiKey = localStorage.getItem('gemini_api_key');
    if (!apiKey) {
        // Create the link element
        const link = document.createElement('a');
        link.href = '/settings.html';
        link.textContent = 'You need a key to get into this bar...';
        // Apply inline styles to match chat text (override default link styles)
        link.style.color = 'inherit';
        link.style.textDecoration = 'none';
        link.style.cursor = 'pointer';

        const div = document.createElement('div');
        div.classList.add('message', 'bot-message');
        div.appendChild(link);

        chatHistory.appendChild(div);

        userInput.disabled = true;
        sendBtn.disabled = true;
        return;
    } else {
        // Key exists, show welcome message
        appendMessage('bot', 'Bar’s open. Tell me what you’re drinking or show me what’s on your shelf.');
    }

    sendBtn.addEventListener('click', handleUserMessage);
    userInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            handleUserMessage();
        }
    });

    async function handleUserMessage() {
        const text = userInput.value.trim();
        if (!text) return;

        // Clear input
        userInput.value = '';

        // Add user message to UI
        appendMessage('user', text);

        // Add to history
        conversationHistory.push({
            role: "user",
            parts: [{ text: text }]
        });

        // Show loading state
        const loadingId = appendLoading();

        try {
            const responseText = await callGeminiAPI(conversationHistory);

            // Remove loading
            removeLoading(loadingId);

            // Add bot response to UI
            appendMessage('bot', responseText);

            // Add to history
            conversationHistory.push({
                role: "model",
                parts: [{ text: responseText }]
            });

        } catch (error) {
            removeLoading(loadingId);
            console.error(error);
            appendMessage('bot', `Sorry, I encountered an error: ${error.message}. Please check your API key in Settings.`);
        }
    }

    async function callGeminiAPI(history) {
        const modelId = (CONFIG && CONFIG.bartender && CONFIG.bartender.modelId) ? CONFIG.bartender.modelId : 'gemini-1.5-flash';
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelId}:generateContent?key=${apiKey}`;

        const payload = {
            contents: history
        };

        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error?.message || 'Unknown error');
        }

        const data = await response.json();

        if (data.candidates && data.candidates.length > 0 && data.candidates[0].content && data.candidates[0].content.parts) {
            return data.candidates[0].content.parts[0].text;
        } else {
            return "I'm not sure what to say.";
        }
    }

    function appendMessage(sender, text) {
        const div = document.createElement('div');
        div.classList.add('message');
        div.classList.add(sender === 'user' ? 'user-message' : 'bot-message');

        if (sender === 'bot') {
            // Render Markdown for bot messages
            div.innerHTML = marked.parse(text);
        } else {
            div.textContent = text;
        }

        chatHistory.appendChild(div);
        scrollToBottom();
    }

    function appendLoading() {
        const id = 'loading-' + Date.now();
        const div = document.createElement('div');
        div.id = id;
        div.classList.add('message', 'bot-message');
        div.innerHTML = '<span class="spinner"></span> Mixing...';
        chatHistory.appendChild(div);
        scrollToBottom();
        return id;
    }

    function removeLoading(id) {
        const el = document.getElementById(id);
        if (el) el.remove();
    }

    function scrollToBottom() {
        chatHistory.scrollTop = chatHistory.scrollHeight;
    }
});
