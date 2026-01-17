# Gemini-Kchat

Gemini-Kchat is a KDE Plasma plasmoid that integrates Google Gemini AI directly into your desktop. Chat with Gemini using the Google AI Studio API without leaving your workspace.

## Features

**Core Integration**
- Direct integration with Google Gemini AI
- Quick chat interface accessible from your Plasma panel
- Native KDE Plasma integration with system theme support
- Fast and lightweight architecture

**Model Support**
- Multiple Gemini model selection through dropdown menu
- Supported models:
  - Gemini 3 Pro (Preview)
  - Gemini 3 Flash (Preview)
  - Deep Research Pro (Preview)
  - Gemma 3 27B Instruct
  - Gemini 2.5 Flash (Recommended)
  - Gemini 2.5 Pro
  - Gemini 2.5 Flash-Lite
  - Gemini 2.0 Flash
  - Gemini 2.0 Flash-Lite

**Customization**
- Markdown rendering with syntax highlighting for code blocks
- Customizable system prompts
- Full color and theme customization
- Typography options (font family, size)
- Configurable UI elements (buttons, scrollbars, placeholders)
- Custom icon support

### Screenshots

<table>
  <tr>
    <td><img src="https://i.imgur.com/suUtute.png" alt="Chat Interface Light"></td>
  </tr>
</table>

---

## Installation

### Method 1: Using .plasmoid file (Recommended)

1. Download the latest `gemini-kchat.plasmoid` file from the [Releases](../../releases) page
2. Install via command line:
   ```bash
   kpackagetool6 -i gemini-kchat.plasmoid
   ```
3. Right-click on your Plasma panel → "Add Widgets..."
4. Search for "Gemini-Kchat" and add it to your panel

### Method 2: Manual Installation

1. Download the source code ZIP from the [Releases](../../releases) page
2. Extract and install:
   ```bash
   unzip gemini-kchat-vX.X.zip
   cd Gemini-Kchat
   kpackagetool6 -i contents --packageroot ~/.local/share/plasma/plasmoids/ -t Plasma/Applet
   ```
3. Right-click on your Plasma panel → "Add Widgets..."
4. Search for "Gemini-Kchat" and add it to your panel

### Updating

To update to a newer version:
```bash
kpackagetool6 -u gemini-kchat.plasmoid
```

---

## Configuration

### Initial Setup

1. Right-click on the Gemini-Kchat widget
2. Select "Configure Gemini-Kchat..."
3. **Important**: Enter your Google AI Studio API key in the "General" tab
4. Select your preferred Gemini model from the dropdown
5. Customize your agent with colors, typography and interface options

### Configuration Options

<table>
  <tr>
    <td width="50%">
      <b>General Settings & Model Selection</b><br>
      <img src="https://i.imgur.com/LgM9TNc.png" alt="API Key and Model Selection">
    </td>
    <td width="50%">
      <b>AI Personality Prompt</b><br>
      <img src="https://i.imgur.com/mDfDAKu.png" alt="Custom System Prompt">
    </td>
  </tr>
  <tr>
    <td>
      <b>Appearance & Colors</b><br>
      <img src="https://i.imgur.com/Y0ZtGWd.png" alt="General Appearance">
    </td>
    <td>
      <b>Code Block Formatting</b><br>
      <img src="https://i.imgur.com/bKgqKnP.png" alt="Code Syntax Highlighting">
    </td>
  </tr>
  <tr>
    <td>
      <b>Typography</b><br>
      <img src="https://i.imgur.com/F2dkfna.png" alt="Font Settings">
    </td>
    <td>
      <b>UI Elements</b><br>
      <img src="https://i.imgur.com/EtZWPi8.png" alt="UI Elements Configuration">
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <b>Custom Plasmoid Icon</b><br>
      <img src="https://i.imgur.com/jVBgLn7.png" alt="Custom Icon Settings">
    </td>
  </tr>
</table>

> **Note**: The widget will not work until you configure your API key. You'll see a reminder message in the chat area if the API key is missing.

### Getting Your API Key

To use Gemini-Kchat, you need a Google AI Studio API key (it's free!):

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key" or "Get API Key"
4. Select or create a Google Cloud project
5. Copy the generated API key
6. Paste it in the Gemini-Kchat configuration settings

> **Important**: Keep your API key secure and never share it publicly. The API key is stored locally in your KDE configuration.

---

## Usage

Click on the Gemini-Kchat icon in your panel and start chatting with Gemini. Simple as that.

---

## Requirements

- KDE Plasma 6.0 or later
- Google AI Studio API key

---

## Troubleshooting

> **⚠️ Rate Limit Errors**
> 
> If you encounter rate limit errors, make sure you have a valid API key. Generally, API keys work well with the free tier on models like Gemini 2.5 Flash or Gemma 3 27B Instruct. Other models may require billing to be enabled on your Google Cloud project.

---

## License

This project is licensed under the GNU Lesser General Public License v2.1 - see the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions are welcome! Please feel free to submit pull requests, report issues, or suggest new features.

---

## Acknowledgments

- Inspired by ChatQT plasmoid by [Denys Madureira](https://github.com/DenysMb/ChatQT-Plasmoid)
- Google AI Studio for providing the Gemini API
- KDE community for the excellent Plasma framework
