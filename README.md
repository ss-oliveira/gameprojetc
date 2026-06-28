# Tibia RPG Mobile - Godot

Um RPG vertical com mapa infinito baseado na temática de Tibia, desenvolvido em Godot para Android.

## 🎮 Características

- **Mapa Infinito**: Sistema chunk-based que carrega/descarrega áreas dinamicamente
- **Visão Vertical**: Câmera que segue o personagem do horizonte
- **Combate Automático**: Inimigos e jogador atacam automaticamente
- **Geração Procedural**: Mundos gerados aleatoriamente com diferentes biomas
- **Offline**: Progresso salvo localmente no dispositivo
- **Temática Tibia**: Criaturas, items e ambientes inspirados em Tibia

## 📋 Requisitos

- **Godot 4.x** (ou versão compatível)
- **Android SDK** para build mobile
- **Git** para controle de versão

## 🚀 Instalação

1. Clone o repositório:
```bash
git clone https://github.com/ss-oliveira/gameprojetc.git
cd gameprojetc
```

2. Abra em Godot:
   - Abra o Godot Engine
   - Selecione "Import" e navegue até a pasta do projeto
   - Clique em "Import & Edit"

3. Configure para Android:
   - File → Export
   - Adicione uma preset do Android
   - Configure o SDK path

## 📁 Estrutura do Projeto

```
gameprojetc/
├── src/
│   ├── player/              # Scripts do personagem
│   ├── enemies/             # Scripts de inimigos
│   ├── world/               # Geração de mundo e chunks
│   ├── ui/                  # Interface do usuário
│   ├── combat/              # Sistema de combate
│   ├── items/               # Sistema de items
│   ├── saves/               # Sistema de save/load
│   └── utils/               # Funções utilitárias
├── assets/
│   ├── sprites/             # Spritesets de personagens e criaturas
│   ├── tilesets/            # Tiles do mapa
│   ├── music/               # Músicas de fundo
│   └── sfx/                 # Efeitos sonoros
├── scenes/
│   ├── main.tscn            # Cena principal
│   ├── player.tscn          # Cena do jogador
│   ├── enemy.tscn           # Cena de inimigos
│   ├── chunk.tscn           # Cena de chunk
│   └── ui/                  # Cenas de interface
├── export/                  # Configurações de export
└── project.godot            # Arquivo de configuração do Godot
```

## 🎯 Sistemas Principais

### Sistema de Chunks
- Cada chunk representa uma área 256x256 pixels
- Carregamento dinâmico baseado na posição do jogador
- Descarregamento de chunks distantes para otimização

### Combate Automático
- Inimigos atacam automaticamente quando em range
- Dano baseado em stats (ATK vs DEF)
- Sistema de cooldown entre ataques

### Geração de Mundo
- Chunks gerados proceduralmente
- Diferentes biomas (floresta, caverna, cemitério, etc)
- Spawn de inimigos por zona

## 🎨 Assets

Os assets devem ser adicionados em:
- `assets/sprites/` - Personagens e criaturas
- `assets/tilesets/` - Mapa e elementos do cenário
- `assets/music/` - Trilha sonora
- `assets/sfx/` - Efeitos sonoros

## 💾 Salvamento

O jogo salva automaticamente:
- Posição do personagem
- Level e experiência
- Inventário
- Configurações

Os dados são armazenados em `user://` (dados locais do dispositivo)

## 🔧 Desenvolvimento

### Branches
- `main` - Versão estável
- `develop` - Desenvolvimento ativo
- `feature/*` - Novas funcionalidades
- `bugfix/*` - Correções de bugs

### Commit Messages
```
tipo(escopo): descrição

feat(world): adiciona geração procedural de chunks
fix(combat): corrige cálculo de dano crítico
docs(readme): atualiza instruções de instalação
```

## 📱 Build para Android

```bash
# Exportar APK
godot --export-debug "Android Debug" gameprojetc.apk

# Ou via Godot Editor
# File → Export → Android
```

## 🐛 Issues e Contribuições

Abra uma issue para reportar bugs ou sugerir features.

## 📜 Licença

MIT License - Veja LICENSE para mais detalhes

## 👨‍💻 Desenvolvedor

**ss-oliveira**

---

**Última atualização**: Junho 2026
