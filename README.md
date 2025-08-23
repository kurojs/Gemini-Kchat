# Gemini-Kchat

Gemini-Kchat is a KDE Plasma plasmoid that integrates Google's Gemini AI directly into your desktop environment. Chat with Gemini using the Google AI Studio API without leaving your desktop.

## Features

- 👾 Direct integration with Google's Gemini AI
- 💬 Quick chat interface directly from your plasma panel
- ♨️ Native KDE Plasma integration with system theme
- ⏱️ Fast and lightweight
- 🔧 Easy configuration

![Gemini-Kchat Screenshot](https://imgur.com/cByeWLQ.png)

## Installation

1. Download the ZIP file from GitHub (it will be named `Gemini-Kchat-main.zip`)
2. Extract the ZIP file
3. Move the extracted `Gemini-Kchat-main` folder to `~/.local/share/plasma/plasmoids/`
4. **Important**: The folder name should remain `Gemini-Kchat-main` (don't rename it)
5. Right-click on your plasma panel → "Add Widgets..."
6. Search for "Gemini-Kchat" and add it to your panel

## Configuration

1. Right-click on the Gemini-Kchat widget
2. Select "Configure Gemini-Kchat..."
3. **Important**: Enter your Google AI Studio API key in the configuration dialog

**Note**: The widget will not work until you configure your API key. You'll see a reminder message in the chat area if the API key is missing.

## Getting Your API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the key and paste it in the plasmoid configuration

## Usage

- Click on the Gemini-Kchat icon in your panel to open the chat interface
- Type your questions or messages and press Enter to send
- Chat history is maintained during the session

## Requirements

- KDE Plasma 6.0 or later
- Google AI Studio API key

## Development

Based on the original ChatQT plasmoid by Denys Madureira, modified and enhanced by kuro to work with Google's Gemini AI instead of local Ollama models.

## License

This project is licensed under the GNU Lesser General Public License v2.1 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit pull requests, report issues, or suggest new features.

## Support

If you encounter any issues or have questions:
1. Check the existing issues on GitHub
2. Create a new issue with detailed information about your problem
3. Include your KDE Plasma version and system information

## Acknowledgments

- Original ChatQT plasmoid by [Denys Madureira](https://github.com/DenysMb/ChatQT-Plasmoid)
- Google AI Studio for providing the Gemini API
- KDE community for the excellent Plasma framework
