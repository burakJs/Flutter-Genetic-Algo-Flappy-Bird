# Genetic Flappy Bird 🦅

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A self-learning Flappy Bird implementation using Neural Networks and Genetic Algorithms, built with Flutter. Watch birds evolve and learn to play the game through generations!

## 🎮 Demo

[Demo video will be added here]

## ✨ Features

- 🧬 Neural Network & Genetic Algorithm implementation
- 🎯 Real-time evolution visualization
- 📊 Generation statistics and performance metrics
- ⚡ Adjustable simulation speed (1x to 5x)
- 🔄 Automatic generation progression
- 📱 Responsive design for all screen sizes

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.x or higher)
- Dart SDK (3.x or higher)
- Git

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/genetic_flappy_bird.git
```

2. Navigate to project directory
```bash
cd genetic_flappy_bird
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## 🧠 How It Works

The project combines Neural Networks and Genetic Algorithms to create self-learning birds:

1. Each bird has its own neural network that decides when to jump
2. Neural Network Inputs:
   - Bird's vertical position
   - Bird's velocity
   - Distance to next pipe
   - Height of pipe gap
3. Birds that survive longer have higher fitness scores
4. Best performing birds are selected for breeding
5. New generation inherits and mutates traits from successful parents

## 🎮 Controls

- **Start Button**: Begin the evolution process
- **Speed Control**: Toggle between different simulation speeds (1x-5x)
- **Back Button**: Return to home screen

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Original Flappy Bird game by Dong Nguyen
- Flutter and Dart teams for the amazing framework
- Neural Network and Genetic Algorithm research community 